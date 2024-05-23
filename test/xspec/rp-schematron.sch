<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="http://www.java.com/" xmlns:file="java.io.File" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:meca="http://manuscriptexchange.org" queryBinding="xslt2">
    
    <title>eLife reviewed preprint schematron</title>

    <ns uri="http://www.niso.org/schemas/ali/1.0/" prefix="ali"/>
    <ns uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
    <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <ns uri="http://www.w3.org/2001/XInclude" prefix="xi"/>
    <ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
    <ns uri="http://saxon.sf.net/" prefix="saxon"/>
    <ns uri="http://purl.org/dc/terms/" prefix="dc"/>
    <ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <ns uri="https://elifesciences.org/namespace" prefix="e"/>
    <ns uri="java.io.File" prefix="file"/>
    <ns uri="http://www.java.com/" prefix="java"/>
    <ns uri="http://manuscriptexchange.org" prefix="meca"/>

    <xsl:function name="e:get-name" as="xs:string">
    <xsl:param name="name"/>
    <xsl:choose>
      <xsl:when test="$name/given-names[1] and $name/surname[1] and $name/suffix[1]">
        <xsl:value-of select="concat($name/given-names[1],' ',$name/surname[1],' ',$name/suffix[1])"/>
      </xsl:when>
      <xsl:when test="not($name/given-names[1]) and $name/surname[1] and $name/suffix[1]">
        <xsl:value-of select="concat($name/surname[1],' ',$name/suffix[1])"/>
      </xsl:when>
      <xsl:when test="$name/given-names[1] and $name/surname[1] and not($name/suffix[1])">
        <xsl:value-of select="concat($name/given-names[1],' ',$name/surname[1])"/>
      </xsl:when>
      <xsl:when test="not($name/given-names[1]) and $name/surname[1] and not($name/suffix[1])">
        <xsl:value-of select="$name/surname[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'No elements present'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  

    <pattern id="article-title-checks-pattern">
    <rule context="article-meta/title-group/article-title" id="article-title-checks">
        <report test=". = upper-case(.)" role="error" id="article-title-all-caps">Article title is in all caps - <value-of select="."/>. Please change to sentence case.</report>
     </rule>
  </pattern>

    <pattern id="author-contrib-checks-pattern">
    <rule context="article-meta/contrib-group[count(aff) gt 1]/contrib[@contrib-type='author' and not(collab)]" id="author-contrib-checks">
        <assert test="xref[@ref-type='aff']" role="error" id="author-contrb-no-aff-xref">Author <value-of select="e:get-name(name[1])"/> has no affiliation.</assert>
     </rule>
  </pattern>
  <pattern id="name-tests-pattern">
    <rule context="contrib-group//name" id="name-tests">
    	<assert test="count(surname) = 1" role="error" id="surname-test-1">Each name must contain only one surname.</assert>
	  
	   <report test="count(given-names) gt 1" role="error" id="given-names-test-1">Each name must contain only one given-names element.</report>
	  
	   <assert test="given-names" role="warning" id="given-names-test-2">This name - <value-of select="."/> - does not contain a given-name. Please check with eLife staff that this is correct.</assert>
	   </rule>
  </pattern>
  <pattern id="surname-tests-pattern">
    <rule context="contrib-group//name/surname" id="surname-tests">
		
	  <report test="not(*) and (normalize-space(.)='')" role="error" id="surname-test-2">surname must not be empty.</report>
		
    <report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" role="error" id="surname-test-3">surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	  <assert test="matches(.,&quot;^[\p{L}\p{M}\s'’\.-]*$&quot;)" role="error" id="surname-test-4">surname should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <report test="matches(.,'^\p{Ll}') and not(matches(.,'^de[rn]? |^van |^von |^el |^te[rn] '))" role="warning" id="surname-test-5">surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</report>
	  
	  <report test="matches(.,'^\p{Zs}')" role="error" id="surname-test-6">surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\p{Zs}$')" role="error" id="surname-test-7">surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	    
	    <report test="matches(.,'^[A-Z]{1,2}\.?\p{Zs}') and (string-length(.) gt 3)" role="warning" id="surname-test-8">surname looks to start with initial - '<value-of select="."/>'. Should '<value-of select="substring-before(.,' ')"/>' be placed in the given-names field?</report>
	    
	    <report test="matches(.,'[\(\)\[\]]')" role="warning" id="surname-test-9">surname contains brackets - '<value-of select="."/>'. Should the bracketed text be placed in the given-names field instead?</report>
	  </rule>
  </pattern>
  <pattern id="given-names-tests-pattern">
    <rule context="name/given-names" id="given-names-tests">
	   <report test="not(*) and (normalize-space(.)='')" role="error" id="given-names-test-3">given-names must not be empty.</report>
		
    	<report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" role="error" id="given-names-test-4">given-names must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript) - '<value-of select="."/>'.</report>
		
      <assert test="matches(.,&quot;^[\p{L}\p{M}\(\)\s'’\.-]*$&quot;)" role="error" id="given-names-test-5">given-names should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <assert test="matches(.,'^\p{Lu}')" role="warning" id="given-names-test-6">given-names doesn't begin with a capital letter - '<value-of select="."/>'. Is this correct?</assert>
	  
    <report test="matches(.,'^\p{Zs}')" role="error" id="given-names-test-8">given-names starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
    <report test="matches(.,'\p{Zs}$')" role="error" id="given-names-test-9">given-names ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'[A-Za-z]\.? [Dd]e[rn]?$')" role="warning" id="given-names-test-10">given-names ends with de, der, or den - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
		
	  <report test="matches(.,'[A-Za-z]\.? [Vv]an$')" role="warning" id="given-names-test-11">given-names ends with ' van' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z]\.? [Vv]on$')" role="warning" id="given-names-test-12">given-names ends with ' von' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z]\.? [Ee]l$')" role="warning" id="given-names-test-13">given-names ends with ' el' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(.,'[A-Za-z]\.? [Tt]e[rn]?$')" role="warning" id="given-names-test-14">given-names ends with te, ter, or ten - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(normalize-space(.),'[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]|[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]$|^[A-za-z]\p{Zs}[A-za-z]$')" role="info" id="given-names-test-15">given-names contains initials with spaces. Ensure that the space(s) is removed between initials - '<value-of select="."/>'.</report>
      
      <report test="matches(.,'[\(\)\[\]]')" role="warning" id="pre-given-names-test-16">given-names contains brackets - '<value-of select="."/>'. This will be flagged by Crossref (although will not actually cause any significant problems). Please add the following author query: Please confirm whether you are happy to remove the brackets around (one of) your given names - '<value-of select="."/>'. This will cause minor issues at Crossref, although they can be retained if desired.</report>
      
      <report test="matches(.,'[\(\)\[\]]')" role="warning" id="final-given-names-test-16">given-names contains brackets - '<value-of select="."/>'. This will be flagged by Crossref (although will not actually cause any significant problems).</report>
		
	   </rule>
  </pattern>
  <pattern id="name-child-tests-pattern">
    <rule context="contrib-group//name/*" id="name-child-tests">
      <assert test="local-name() = ('surname','given-names','suffix')" role="error" id="disallowed-child-assert">
        <value-of select="local-name()"/> is not supported as a child of name.</assert>
    </rule>
  </pattern>
  <pattern id="orcid-name-checks-pattern">
    <rule context="article/front/article-meta/contrib-group[1]" id="orcid-name-checks">
      <let name="names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="indistinct-names" value="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      <let name="orcids" value="for $x in contrib[@contrib-type='author']/contrib-id[@contrib-id-type='orcid'] return substring-after($x,'orcid.org/')"/>
      <let name="indistinct-orcids" value="for $orcid in distinct-values($orcids) return $orcid[count($orcids[. = $orcid]) gt 1]"/>
      
      <assert test="empty($indistinct-names)" role="warning" id="duplicate-author-test">There is more than one author with the following name(s) - <value-of select="if (count($indistinct-names) gt 1) then concat(string-join($indistinct-names[position() != last()],', '),' and ',$indistinct-names[last()]) else $indistinct-names"/> - which is very likely be incorrect.</assert>
      
      <assert test="empty($indistinct-orcids)" role="error" id="duplicate-orcid-test">There is more than one author with the following ORCiD(s) - <value-of select="if (count($indistinct-orcids) gt 1) then concat(string-join($indistinct-orcids[position() != last()],', '),' and ',$indistinct-orcids[last()]) else $indistinct-orcids"/> - which must be incorrect.</assert>
      
    </rule>
  </pattern>

    <pattern id="journal-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='journal']" id="journal-ref-checks">
        <assert test="source" role="error" id="journal-ref-source">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" role="error" id="journal-ref-article-title">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>
     </rule>
  </pattern>

    <pattern id="ref-list-checks-pattern">
    <rule context="ref-list" id="ref-list-checks">
        <let name="labels" value="./ref/label"/>
        <let name="indistinct-labels" value="for $label in distinct-values($labels) return $label[count($labels[. = $label]) gt 1]"/>
        <assert test="empty($indistinct-labels)" role="error" id="indistinct-ref-labels">Duplicate labels in reference list - <value-of select="string-join($indistinct-labels,'; ')"/>. Have there been typesetting errors?</assert>
     </rule>
  </pattern>

     <pattern id="ref-year-checks-pattern">
    <rule context="ref//year" id="ref-year-checks">
        <report test="matches(.,'\d') and not(matches(.,'^\d{4}[a-z]?$'))" role="error" id="ref-year-value-1">Ref with id <value-of select="ancestor::ref/@id"/> has a year element with the value '<value-of select="."/>' which contains a digit (or more) but is not a year.</report>

        <assert test="matches(.,'\d')" role="warning" id="ref-year-value-2">Ref with id <value-of select="ancestor::ref/@id"/> has a year element which does not contain a digit. Is it correct? (it's acceptable for this element to contain 'no date' or equivalent non-numerical information relating to year of publication)</assert>
     </rule>
  </pattern>

    <pattern id="ref-name-checks-pattern">
    <rule context="mixed-citation//name | mixed-citation//string-name" id="ref-name-checks">
        <assert test="surname" role="error" id="ref-surname">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) does not have a surname element.</assert>
     </rule>
  </pattern>

    <pattern id="ref-etal-checks-pattern">
    <rule context="mixed-citation[person-group]//etal" id="ref-etal-checks">
        <assert test="parent::person-group" role="error" id="ref-etal-1">If the etal element is included in a reference, and that reference has a person-group element, then the etal should also be included in the person-group element. But this one is a child of <value-of select="parent::*/name()"/>.</assert>
     </rule>
  </pattern>

    <pattern id="ref-pub-id-checks-pattern">
    <rule context="ref//pub-id[@pub-id-type='doi']" id="ref-pub-id-checks">
        <assert test="matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')" role="error" id="ref-doi-conformance">&lt;pub-id pub-id="doi"&gt; in reference (id=<value-of select="ancestor::ref/@id"/>) does not contain a valid DOI: '<value-of select="."/>'.</assert>
     </rule>
  </pattern>

    <pattern id="strike-checks-pattern">
    <rule context="strike" id="strike-checks">
        <report test="." role="warning" id="strike-warning">strike element is present. Is this tracked change formatting that's been erroneously retained? Should this text be deleted?</report>
     </rule>
  </pattern>

    <pattern id="underline-checks-pattern">
    <rule context="underline" id="underline-checks">
        <report test="string-length(.) gt 20" role="warning" id="underline-warning">underline element contains more than 20 characters. Is this tracked change formatting that's been erroneously retained?</report>
     </rule>
  </pattern>

    <pattern id="fig-child-checks-pattern">
    <rule context="fig/*" id="fig-child-checks">
        <let name="supported-fig-children" value="('label','caption','graphic','alternatives','permissions')"/>
        <assert test="name()=$supported-fig-children" role="error" id="fig-child-conformance">
        <value-of select="name()"/> is not supported as a child of &lt;fig&gt;.</assert>
     </rule>
  </pattern>

    <pattern id="table-wrap-child-checks-pattern">
    <rule context="table-wrap/*" id="table-wrap-child-checks">
        <let name="supported-table-wrap-children" value="('label','caption','graphic','alternatives','table','permissions','table-wrap-foot')"/>
        <assert test="name()=$supported-table-wrap-children" role="error" id="table-wrap-child-conformance">
        <value-of select="name()"/> is not supported as a child of &lt;table-wrap&gt;.</assert>
     </rule>
  </pattern>

    <pattern id="list-checks-pattern">
    <rule context="list" id="list-checks">
        <let name="supported-list-types" value="('bullet','simple','order','alpha-lower','alpha-uppper','roman-lower','roman-upper')"/>
        <assert test="@list-type=$supported-list-types" role="error" id="list-type-conformance">&lt;list&gt; element must have a list-type attribute with one of the supported values: <value-of select="string-join($supported-list-types,'; ')"/>.<value-of select="if (./@list-type) then concat(' list-type ',@list-type,' is not supported.') else ()"/>
      </assert>
     </rule>
  </pattern>

    <pattern id="title-checks-pattern">
    <rule context="title" id="title-checks">
        <report test="upper-case(.)=." role="warning" id="title-upper-case">Content of &lt;title&gt; element is entirely in upper case: Is that correct? '<value-of select="."/>'</report>

        <report test="lower-case(.)=." role="warning" id="title-lower-case">Content of &lt;title&gt; element is entirely in lower-case case: Is that correct? '<value-of select="."/>'</report>
     </rule>
  </pattern>

    <pattern id="general-article-meta-checks-pattern">
    <rule context="article/front/article-meta" id="general-article-meta-checks">
        <assert test="article-id[@pub-id-type='doi']" role="error" id="article-id">article-meta must contain at least one DOI - a &lt;article-id pub-id-type="doi"&gt; element.</assert>

        <assert test="count(article-version)=1" role="error" id="article-version-1">article-meta must contain one (and only one) &lt;article-version&gt; element.</assert>

        <assert test="count(contrib-group)=1" role="error" id="article-contrib-group">article-meta must contain one (and only one) &lt;contrib-group&gt; element.</assert>
      </rule>
  </pattern>
  <pattern id="article-version-checks-pattern">
    <rule context="article/front/article-meta/article-version" id="article-version-checks">
        <assert test="matches(.,'^1\.\d+$')" role="error" id="article-version-2">article-must be in the format 1.x (e.g. 1.11). This one is '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="digest-title-checks-pattern">
    <rule context="title" id="digest-title-checks">
        <report test="matches(lower-case(.),'^\s*(elife\s)?digest\s*$')" role="error" id="digest-flag">
        <value-of select="parent::*/name()"/> element has a title containing 'digest' - <value-of select="."/>. If this is referring to an plain language summary written by the authors it should be renamed to plain language summary (or similar) in order to not suggest to readers this was written by the features team.</report>
      </rule>
  </pattern>

    <pattern id="preformat-checks-pattern">
    <rule context="preformat" id="preformat-checks">
        <report test="." role="warning" id="preformat-flag">Please check whether the content in this preformat element has been captured crrectly (and is rendered approriately).</report>
     </rule>
  </pattern>

    <pattern id="code-checks-pattern">
    <rule context="code" id="code-checks">
        <report test="." role="warning" id="code-flag">Please check whether the content in this code element has been captured crrectly (and is rendered approriately).</report>
     </rule>
  </pattern>

    <pattern id="unallowed-symbol-tests-pattern">
    <rule context="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link" id="unallowed-symbol-tests">
      
      <report test="contains(.,'�')" role="error" id="replacement-character-presence">
        <name/> element contains the replacement character '�' which is not allowed.</report>
      
      <report test="contains(.,'')" role="error" id="junk-character-presence">
        <name/> element contains a junk character '' which should be replaced.</report>
      
      <report test="contains(.,'︎')" role="error" id="junk-character-presence-2">
        <name/> element contains a junk character '︎' which should be replaced or deleted.</report>

      <report test="contains(.,'□')" role="error" id="junk-character-presence-3">
        <name/> element contains a junk character '□' which should be replaced or deleted.</report>
      
      <report test="contains(.,'¿')" role="warning" id="inverterted-question-presence">
        <name/> element contains an inverted question mark '¿' which should very likely be replaced/removed.</report>
      
      <report test="some $x in self::*[not(local-name() = ('monospace','code'))]/text() satisfies matches($x,'\(\)|\[\]')" role="warning" id="empty-parentheses-presence">
        <name/> element contains empty parentheses ('[]', or '()'). Is there a missing citation within the parentheses? Or perhaps this is a piece of code that needs formatting?</report>
      
      <report test="matches(.,'&amp;#x\d')" role="warning" id="broken-unicode-presence">
        <name/> element contains what looks like a broken unicode - <value-of select="."/>.</report>
      
      <report test="contains(.,'&#x9D;')" role="error" id="operating-system-command-presence">
        <name/> element contains an operating system command character '&#x9D;' (unicode string: &amp;#x9D;) which should very likely be replaced/removed. - <value-of select="."/>
      </report>

      <report test="matches(lower-case(.),&quot;(^|\s)((i am|i'm) an? ai (language)? model|as an ai (language)? model,? i('m|\s)|(here is|here's) an? (possible|potential)? introduction (to|for) your topic|(here is|here's) an? (abstract|introduction|results|discussion|methods)( section)? for you|certainly(,|!)? (here is|here's)|i'm sorry,?( but)? i (don't|can't)|knowledge (extend|cutoff)|as of my last update|regenerate response)&quot;)" role="warning" id="ai-response-presence-1">
        <name/> element contains what looks like a response from an AI chatbot after it being provided a prompt. Is that correct? Should the content be adjusted?</report>
    </rule>
  </pattern>

    <pattern id="arxiv-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id)='arxiv']" id="arxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='arXiv'" role="error" id="arxiv-journal-id">arXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'arXiv'.</assert>

      <assert test="journal-title-group/journal-title='arXiv'" role="error" id="arxiv-journal-title">arXiv preprints must have a &lt;journal-title&gt; element with the value 'arXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='arXiv'" role="error" id="arxiv-abbrev-journal-title">arXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'arXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="issn[@pub-type='epub']='2331-8422'" role="error" id="arxiv-issn">arXiv preprints must have a &lt;issn pub-type="epub"&gt; element with the value '2331-8422'.</assert>

      <assert test="publisher/publisher-name='Cornell University'" role="error" id="arxiv-publisher">arXiv preprints must have a &lt;publisher-name&gt; element with the value 'Cornell University', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="arxiv-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id)='arxiv']]/article-meta/article-id[@pub-id-type='doi']" id="arxiv-doi-checks">
        <assert test="matches(.,'^10\.48550/arXiv\.\d{4,5}\.\d{4,5}$')" role="error" id="arxiv-doi-conformance">arXiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '10\.48550/arXiv\.\d{4,}\.\d{4,5}'. In other words, the current DOI listed is not a valid arXiv DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="res-square-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id)='rs']" id="res-square-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='RS'" role="error" id="res-square-journal-id">Research Square preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'RS'.</assert>

      <assert test="journal-title-group/journal-title='Research Square'" role="error" id="res-square-journal-title">Research Square preprints must have a &lt;journal-title&gt; element with the value 'Research Square' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='rs'" role="error" id="res-square-abbrev-journal-title">Research Square preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'rs' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="issn[@pub-type='epub']='2693-5015'" role="error" id="res-square-issn">Research Square preprints must have a &lt;issn pub-type="epub"&gt; element with the value '2693-5015'.</assert>

      <assert test="publisher/publisher-name='Research Square'" role="error" id="res-square-publisher">Research Square preprints must have a &lt;publisher-name&gt; element with the value 'Research Square', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="res-square-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id)='rs']]/article-meta/article-id[@pub-id-type='doi']" id="res-square-doi-checks">
        <assert test="matches(.,'^10\.21203/rs\.3\.rs-\d+/v\d$')" role="error" id="res-square-doi-conformance">Research Square preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.21203/rs\.3\.rs-\d+/v\d$'. In other words, the current DOI listed is not a valid Research Square DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="psyarxiv-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id)='psyarxiv']" id="psyarxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='PsyArXiv'" role="error" id="psyarxiv-journal-id">PsyArXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'PsyArXiv'.</assert>

      <assert test="journal-title-group/journal-title='PsyArXiv'" role="error" id="psyarxiv-journal-title">PsyArXiv preprints must have a &lt;journal-title&gt; element with the value 'PsyArXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='PsyArXiv'" role="error" id="psyarxiv-abbrev-journal-title">PsyArXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'PsyArXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Center for Open Science'" role="error" id="psyarxiv-publisher">PsyArXiv preprints must have a &lt;publisher-name&gt; element with the value 'Center for Open Science', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="psyarxiv-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id)='psyarxiv']]/article-meta/article-id[@pub-id-type='doi']" id="psyarxiv-doi-checks">
        <assert test="matches(.,'^10\.31234/osf\.io/[\da-z]+$')" role="error" id="psyarxiv-doi-conformance">PsyArXiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.31234/osf\.io/[\da-z]+$'. In other words, the current DOI listed is not a valid PsyArXiv DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="osf-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id)='osf preprints']" id="osf-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='OSF Preprints'" role="error" id="osf-journal-id">Preprints on OSF must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'OSF Preprints'.</assert>

      <assert test="journal-title-group/journal-title='OSF Preprints'" role="error" id="osf-journal-title">Preprints on OSF must have a &lt;journal-title&gt; element with the value 'OSF Preprints' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='OSF pre.'" role="error" id="osf-abbrev-journal-title">Preprints on OSF must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'OSF pre.' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Center for Open Science'" role="error" id="osf-publisher">Preprints on OSF must have a &lt;publisher-name&gt; element with the value 'Center for Open Science', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="osf-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id)='osf preprints']]/article-meta/article-id[@pub-id-type='doi']" id="osf-doi-checks">
        <assert test="matches(.,'^10\.31219/osf\.io/[\da-z]+$')" role="error" id="osf-doi-conformance">Preprints on OSF must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10/.31219/osf\.io/[\da-z]+$'. In other words, the current DOI listed is not a valid OSF Preprints DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="ecoevorxiv-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id)='ecoevorxiv']" id="ecoevorxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='EcoEvoRxiv'" role="error" id="ecoevorxiv-journal-id">EcoEvoRxiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'EcoEvoRxiv'.</assert>

      <assert test="journal-title-group/journal-title='EcoEvoRxiv'" role="error" id="ecoevorxiv-journal-title">EcoEvoRxiv preprints must have a &lt;journal-title&gt; element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='EcoEvoRxiv'" role="error" id="ecoevorxiv-abbrev-journal-title">EcoEvoRxiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)'" role="error" id="ecoevorxiv-publisher">EcoEvoRxiv preprints must have a &lt;publisher-name&gt; element with the value 'Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="ecoevorxiv-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id)='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi']" id="ecoevorxiv-doi-checks">
        <assert test="matches(.,'^10.32942/[A-Z\d]+$')" role="error" id="ecoevorxiv-doi-conformance">EcoEvoRxiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10.32942/[A-Z\d]+$'. In other words, the current DOI listed is not a valid EcoEvoRxiv DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="authorea-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id)='authorea']" id="authorea-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='Authorea'" role="error" id="authorea-journal-id">Authorea preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'Authorea'.</assert>

      <assert test="journal-title-group/journal-title='Authorea'" role="error" id="authorea-journal-title">Authorea preprints must have a &lt;journal-title&gt; element with the value 'Authorea' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='Authorea'" role="error" id="authorea-abbrev-journal-title">Authorea preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'Authorea' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Authorea, Inc'" role="error" id="authorea-publisher">Authorea preprints must have a &lt;publisher-name&gt; element with the value 'Authorea, Inc', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="authorea-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id)='authorea']]/article-meta/article-id[@pub-id-type='doi']" id="authorea-doi-checks">
        <assert test="matches(.,'^10\.22541/au\.\d+\.\d+/v\d$')" role="error" id="authorea-doi-conformance">Authorea preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.22541/au\.\d+\.\d+/v\d$'. In other words, the current DOI listed is not a valid Authorea DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <!-- Checks for the manifest file in the meca package.
          For validation in oXygen this assumes the manifest file is in a parent folder of the xml file being validated and named as manifest.xml
          For validation via BaseX, there is a separate file - meca-manifest-schematron.sch
     -->
    
    
<pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::article-meta/title-group/article-title" role="error" id="article-title-checks-xspec-assert">article-meta/title-group/article-title must be present.</assert>
      <assert test="descendant::article-meta/contrib-group[count(aff) gt 1]/contrib[@contrib-type='author' and not(collab)]" role="error" id="author-contrib-checks-xspec-assert">article-meta/contrib-group[count(aff) gt 1]/contrib[@contrib-type='author' and not(collab)] must be present.</assert>
      <assert test="descendant::contrib-group//name" role="error" id="name-tests-xspec-assert">contrib-group//name must be present.</assert>
      <assert test="descendant::contrib-group//name/surname" role="error" id="surname-tests-xspec-assert">contrib-group//name/surname must be present.</assert>
      <assert test="descendant::name/given-names" role="error" id="given-names-tests-xspec-assert">name/given-names must be present.</assert>
      <assert test="descendant::contrib-group//name/*" role="error" id="name-child-tests-xspec-assert">contrib-group//name/* must be present.</assert>
      <assert test="descendant::article/front/article-meta/contrib-group[1]" role="error" id="orcid-name-checks-xspec-assert">article/front/article-meta/contrib-group[1] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='journal']" role="error" id="journal-ref-checks-xspec-assert">mixed-citation[@publication-type='journal'] must be present.</assert>
      <assert test="descendant::ref-list" role="error" id="ref-list-checks-xspec-assert">ref-list must be present.</assert>
      <assert test="descendant::ref//year" role="error" id="ref-year-checks-xspec-assert">ref//year must be present.</assert>
      <assert test="descendant::mixed-citation//name  or descendant:: mixed-citation//string-name" role="error" id="ref-name-checks-xspec-assert">mixed-citation//name | mixed-citation//string-name must be present.</assert>
      <assert test="descendant::mixed-citation[person-group]//etal" role="error" id="ref-etal-checks-xspec-assert">mixed-citation[person-group]//etal must be present.</assert>
      <assert test="descendant::ref//pub-id[@pub-id-type='doi']" role="error" id="ref-pub-id-checks-xspec-assert">ref//pub-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::underline" role="error" id="underline-checks-xspec-assert">underline must be present.</assert>
      <assert test="descendant::fig/*" role="error" id="fig-child-checks-xspec-assert">fig/* must be present.</assert>
      <assert test="descendant::table-wrap/*" role="error" id="table-wrap-child-checks-xspec-assert">table-wrap/* must be present.</assert>
      <assert test="descendant::list" role="error" id="list-checks-xspec-assert">list must be present.</assert>
      <assert test="descendant::title" role="error" id="title-checks-xspec-assert">title must be present.</assert>
      <assert test="descendant::article/front/article-meta" role="error" id="general-article-meta-checks-xspec-assert">article/front/article-meta must be present.</assert>
      <assert test="descendant::article/front/article-meta/article-version" role="error" id="article-version-checks-xspec-assert">article/front/article-meta/article-version must be present.</assert>
      <assert test="descendant::title" role="error" id="digest-title-checks-xspec-assert">title must be present.</assert>
      <assert test="descendant::p or descendant::td or descendant::th or descendant::title or descendant::xref or descendant::bold or descendant::italic or descendant::sub or descendant::sc or descendant::named-content or descendant::monospace or descendant::code or descendant::underline or descendant::fn or descendant::institution or descendant::ext-link" role="error" id="unallowed-symbol-tests-xspec-assert">p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id)='arxiv']" role="error" id="arxiv-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id)='arxiv'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id)='arxiv']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="arxiv-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id)='arxiv']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id)='rs']" role="error" id="res-square-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id)='rs'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id)='rs']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="res-square-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id)='rs']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id)='psyarxiv']" role="error" id="psyarxiv-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id)='psyarxiv'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id)='psyarxiv']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="psyarxiv-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id)='psyarxiv']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id)='osf preprints']" role="error" id="osf-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id)='osf preprints'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id)='osf preprints']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="osf-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id)='osf preprints']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id)='ecoevorxiv']" role="error" id="ecoevorxiv-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id)='ecoevorxiv'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id)='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="ecoevorxiv-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id)='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id)='authorea']" role="error" id="authorea-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id)='authorea'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id)='authorea']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="authorea-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id)='authorea']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
    </rule>
  </pattern>
</schema>