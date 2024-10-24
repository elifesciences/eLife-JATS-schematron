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
    
    <xsl:function name="e:isbn-sum" as="xs:integer">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="string-length($s) = 10">
        <xsl:variable name="d1" select="number(substring($s,1,1)) * 10"/>
        <xsl:variable name="d2" select="number(substring($s,2,1)) * 9"/>
        <xsl:variable name="d3" select="number(substring($s,3,1)) * 8"/>
        <xsl:variable name="d4" select="number(substring($s,4,1)) * 7"/>
        <xsl:variable name="d5" select="number(substring($s,5,1)) * 6"/>
        <xsl:variable name="d6" select="number(substring($s,6,1)) * 5"/>
        <xsl:variable name="d7" select="number(substring($s,7,1)) * 4"/>
        <xsl:variable name="d8" select="number(substring($s,8,1)) * 3"/>
        <xsl:variable name="d9" select="number(substring($s,9,1)) * 2"/>
        <xsl:variable name="d10" select="number(substring($s,10,1)) * 1"/>
        <xsl:value-of select="number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7 + $d8 + $d9 + $d10) mod 11"/>
      </xsl:when>
      <xsl:when test="string-length($s) = 13">
        <xsl:variable name="d1" select="number(substring($s,1,1))"/>
        <xsl:variable name="d2" select="number(substring($s,2,1)) * 3"/>
        <xsl:variable name="d3" select="number(substring($s,3,1))"/>
        <xsl:variable name="d4" select="number(substring($s,4,1)) * 3"/>
        <xsl:variable name="d5" select="number(substring($s,5,1))"/>
        <xsl:variable name="d6" select="number(substring($s,6,1)) * 3"/>
        <xsl:variable name="d7" select="number(substring($s,7,1))"/>
        <xsl:variable name="d8" select="number(substring($s,8,1)) * 3"/>
        <xsl:variable name="d9" select="number(substring($s,9,1))"/>
        <xsl:variable name="d10" select="number(substring($s,10,1)) * 3"/>
        <xsl:variable name="d11" select="number(substring($s,11,1))"/>
        <xsl:variable name="d12" select="number(substring($s,12,1)) * 3"/>
        <xsl:variable name="d13" select="number(substring($s,13,1))"/>
        <xsl:value-of select="number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7 + $d8 + $d9 + $d10 + $d11 + $d12 + $d13) mod 10"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number('1')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

    <xsl:function name="e:is-valid-issn" as="xs:boolean">
      <xsl:param name="s" as="xs:string"/>
      <xsl:choose>
        <xsl:when test="not(matches($s,'^\d{4}\-\d{3}[\dX]$'))">
          <xsl:value-of select="false()"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="d1" select="number(substring($s,1,1)) * 8"/>
            <xsl:variable name="d2" select="number(substring($s,2,1)) * 7"/>
            <xsl:variable name="d3" select="number(substring($s,3,1)) * 6"/>
            <xsl:variable name="d4" select="number(substring($s,4,1)) * 5"/>
            <xsl:variable name="d5" select="number(substring($s,6,1)) * 4"/>
            <xsl:variable name="d6" select="number(substring($s,7,1)) * 3"/>
            <xsl:variable name="d7" select="number(substring($s,8,1)) * 2"/>
            <xsl:variable name="calc" select="11 - (number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7) mod 11)"/>
            <xsl:variable name="check" select="if (substring($s,9,1)='X') then 10 else number(substring($s,9,1))"/>
            <xsl:value-of select="$calc = $check"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>
    
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

  

     <pattern id="biorender-tests-pattern">
    <rule context="article" id="biorender-tests">
      <!-- exclude ref list and figures from this check -->
      <let name="article-text" value="string-join(for $x in self::*/*[local-name() = 'body' or local-name() = 'back']//*           return           if ($x/ancestor::ref-list) then ()           else if ($x/ancestor::caption[parent::fig] or $x/ancestor::permissions[parent::fig]) then ()           else $x/text(),'')"/>

       <report test="matches(lower-case($article-text),'biorend[eo]r')" role="warning" id="biorender-check">Article text contains a reference to bioRender. Any figures created with bioRender should include a sentence in the caption in the format: "Created with BioRender.com/{figure-code}".</report>

      </rule>
  </pattern>

    <pattern id="article-title-checks-pattern">
    <rule context="article-meta/title-group/article-title" id="article-title-checks">
        <report test=". = upper-case(.)" role="error" id="article-title-all-caps">Article title is in all caps - <value-of select="."/>. Please change to sentence case.</report>
       
       <report test="matches(.,'[*¶†‡§¥⁑╀◊♯࿎ł#]$')" role="warning" id="article-title-check-1">Article title ends with a '<value-of select="substring(.,string-length(.))"/>' character: '<value-of select="."/>'. Is this a note indicator? If so, since notes are not supported in EPP, this should be removed.</report>
     </rule>
  </pattern>
  <pattern id="article-title-children-checks-pattern">
    <rule context="article-meta/title-group/article-title/*" id="article-title-children-checks">
        <let name="permitted-children" value="('italic','sup','sub')"/>
       
        <assert test="name()=$permitted-children" role="error" id="article-title-children-check-1">
        <name/> is not supported as a child of article title. Please remove this element (and any child content, as appropriate).</assert>
        
        <report test="normalize-space(.)=''" role="error" id="article-title-children-check-2">Child elements of article-title must contain text content. This <name/> element is empty.</report>
     </rule>
  </pattern>

    <pattern id="author-contrib-checks-pattern">
    <rule context="article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)]" id="author-contrib-checks">
        <assert test="xref[@ref-type='aff']" role="error" id="author-contrb-no-aff-xref">Author <value-of select="e:get-name(name[1])"/> has no affiliation.</assert>
     </rule>
  </pattern>
  <pattern id="author-corresp-checks-pattern">
    <rule context="contrib[@contrib-type='author']" id="author-corresp-checks">
        <report test="@corresp='yes' and not(email) and not(xref[@ref-type='corresp'])" role="error" id="author-corresp-no-email">Author <value-of select="e:get-name(name[1])"/> has the attribute corresp="yes", but they do not have a child email element or an xref with the attribute ref-type="corresp".</report>
        
        <report test="not(@corresp='yes') and (email or xref[@ref-type='corresp'])" role="error" id="author-email-no-corresp">Author <value-of select="e:get-name(name[1])"/> does not have the attribute corresp="yes", but they have a child email element or an xref with the attribute ref-type="corresp".</report>
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
		
	  <report test="matches(.,'^\p{Ll}') and not(matches(.,'^de[lrn]? |^van |^von |^el |^te[rn] |^d[ai] '))" role="warning" id="surname-test-5">surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</report>
	  
	  <report test="matches(.,'^\p{Zs}')" role="error" id="surname-test-6">surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\p{Zs}$')" role="error" id="surname-test-7">surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	    
	    <report test="matches(.,'^[A-Z]{1,2}\.?\p{Zs}') and (string-length(.) gt 3)" role="warning" id="surname-test-8">surname looks to start with initial - '<value-of select="."/>'. Should '<value-of select="substring-before(.,' ')"/>' be placed in the given-names field?</report>
	    
	    <report test="matches(.,'[\(\)\[\]]')" role="warning" id="surname-test-9">surname contains brackets - '<value-of select="."/>'. Should the bracketed text be placed in the given-names field instead?</report>

      <report test="matches(.,'\s') and not(matches(lower-case(.),'^de[lrn]? |^v[ao]n |^el |^te[rn] |^l[ae] |^zur |^d[ia] '))" role="warning" id="surname-test-10">surname contains space(s) - '<value-of select="."/>'. Has it been captured correctly? Should any namee be moved to given-names?</report>
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
		
      <report test="matches(.,'^[\p{Lu}\s]+$')" role="warning" id="given-names-test-16">given-names for author is made up only of uppercase letters (and spaces) '<value-of select="."/>'. Are they initials? Should the authors full given-names be introduced instead?</report>
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
  <pattern id="affiliation-checks-pattern">
    <rule context="aff" id="affiliation-checks">
      <let name="country-count" value="count(descendant::country)"/>
      
      <report test="$country-count lt 1" role="warning" id="aff-no-country">Affiliation does not contain a country element: <value-of select="."/>
      </report>

      <report test="$country-count gt 1" role="error" id="aff-multiple-country">Affiliation contains more than one country element: <value-of select="string-join(descendant::country,'; ')"/> in <value-of select="."/>
      </report>

      <report test="count(descendant::institution) gt 1" role="warning" id="aff-multiple-institution">Affiliation contains more than one institution element: <value-of select="string-join(descendant::institution,'; ')"/> in <value-of select="."/>
      </report>
    
    </rule>
  </pattern>

    <pattern id="journal-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='journal']" id="journal-ref-checks">
        <assert test="source" role="error" id="journal-ref-source">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" role="error" id="journal-ref-article-title">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>

        <report test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|vol|and|pp?|in|is[sb]n)[:\.]?'))]" role="warning" id="journal-ref-text-content">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has untagged textual content - <value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|vol|and|pp?|in|is[sb]n)[:\.]?'))],'; ')"/>. Is it tagged correctly?</report>
     </rule>
  </pattern>
  <pattern id="journal-source-checks-pattern">
    <rule context="mixed-citation[@publication-type='journal']/source" id="journal-source-checks">
      <let name="preprint-regex" value="'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra'"/>
       
       <report test="matches(lower-case(.),$preprint-regex)" role="warning" id="journal-source-1">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source which suggests it might be a preprint - <value-of select="."/>. Is it tagged correctly?</report>
       

       <report test="matches(lower-case(.),'^i{1,3}\.\s') and parent::*/article-title" role="warning" id="journal-source-2">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that starts with a roman numeral. Is part of the article-title captured in source? Source = <value-of select="."/>.</report>
     </rule>
  </pattern>

    <pattern id="preprint-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='preprint']" id="preprint-ref-checks">
        <assert test="source" role="error" id="preprint-ref-source">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" role="error" id="preprint-ref-article-title">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>

        <report test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))]" role="warning" id="preprint-ref-text-content">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has untagged textual content - <value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))],'; ')"/>. Is it tagged correctly?</report>
     </rule>
  </pattern>

    <pattern id="book-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='book']" id="book-ref-checks">
        <assert test="source" role="error" id="book-ref-source">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>
       
       <report test="count(source) gt 1" role="error" id="book-ref-source-2">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has more than 1 source element.</report>
       
       <report test="not(chapter-title) and person-group[@person-group-type='editor']" role="warning" id="book-ref-editor">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has an editor person-group but no chapter-title element. Have all the details been captured correctly?</report>
       
       <report test="not(chapter-title) and publisher-name[italic]" role="warning" id="book-ref-pub-name-1">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a publisher-name with italics and no chapter-title element. Have all the details been captured correctly?</report>
     </rule>
  </pattern>
  <pattern id="book-ref-source-checks-pattern">
    <rule context="mixed-citation[@publication-type='book']/source" id="book-ref-source-checks">
        
        <report test="matches(lower-case(.),'^chapter\s|\s+chapter\s+')" role="warning" id="book-source-1">The source in book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) contains 'chapter' - <value-of select="."/>. Are the details captured correctly?</report>
        
        <report test="matches(lower-case(.),'\.\s+in:\s+')" role="warning" id="book-source-2">The source in book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) contains '. In: ' - <value-of select="."/>. Are the details captured correctly?</report>
      </rule>
  </pattern>

    <pattern id="ref-list-checks-pattern">
    <rule context="ref-list" id="ref-list-checks">
        <let name="labels" value="./ref/label"/>
        <let name="indistinct-labels" value="for $label in distinct-values($labels) return $label[count($labels[. = $label]) gt 1]"/>
        <assert test="empty($indistinct-labels)" role="error" id="indistinct-ref-labels">Duplicate labels in reference list - <value-of select="string-join($indistinct-labels,'; ')"/>. Have there been typesetting errors?</assert>

        <report test="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')] and ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))]" role="warning" id="ref-label-types">This ref-list has labels in the format '<value-of select="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')][1]"/>' as well as labels in the format '<value-of select="ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))][1]"/>'. Is that correct?</report>
     </rule>
  </pattern>
  <pattern id="ref-numeric-label-checks-pattern">
    <rule context="ref-list[ref/label[matches(.,'^\p{P}*\d+\p{P}*$')] and not(ref/label[not(matches(.,'^\p{P}*\d+\p{P}*$'))])]/ref[label]" id="ref-numeric-label-checks">
        <let name="numeric-label" value="number(replace(./label[1],'[^\d]',''))"/>
        <let name="pos" value="count(parent::ref-list/ref[label]) - count(following-sibling::ref[label])"/>
        <assert test="$numeric-label = $pos" role="warning" id="ref-label-1">ref with id <value-of select="@id"/> has the label <value-of select="$numeric-label"/>, but according to its position it should be labelled as number <value-of select="$pos"/>. Has there been a processing error?</assert>
     </rule>
  </pattern>
  <pattern id="ref-label-checks-pattern">
    <rule context="ref-list[ref/label]/ref" id="ref-label-checks">
        <report test="not(label) and (preceding-sibling::ref[label] or following-sibling::ref[label])" role="warning" id="ref-label-2">ref with id <value-of select="@id"/> doesn't have a label, but other refs within the same ref-list do. Has there been a processing error?</report>
     </rule>
  </pattern>

     <pattern id="ref-year-checks-pattern">
    <rule context="ref//year" id="ref-year-checks">
        <report test="matches(.,'\d') and not(matches(.,'^\d{4}[a-z]?$'))" role="error" id="ref-year-value-1">Ref with id <value-of select="ancestor::ref/@id"/> has a year element with the value '<value-of select="."/>' which contains a digit (or more) but is not a year.</report>

        <assert test="matches(.,'\d')" role="warning" id="ref-year-value-2">Ref with id <value-of select="ancestor::ref/@id"/> has a year element which does not contain a digit. Is it correct? (it's acceptable for this element to contain 'no date' or equivalent non-numerical information relating to year of publication)</assert>
        
        <report test="matches(.,'^\d{4}[a-z]?$') and number(replace(.,'[^\d]','')) lt 1800" role="warning" id="ref-year-value-3">Ref with id <value-of select="ancestor::ref/@id"/> has a year element which is less than 1800, which is almost certain to be incorrect: <value-of select="."/>.</report>
     </rule>
  </pattern>

    <pattern id="ref-name-checks-pattern">
    <rule context="mixed-citation//name | mixed-citation//string-name" id="ref-name-checks">
        <assert test="surname" role="error" id="ref-surname">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) does not have a surname element.</assert>
     </rule>
  </pattern>
  <pattern id="ref-name-space-checks-pattern">
    <rule context="mixed-citation//given-names | mixed-citation//surname" id="ref-name-space-checks">
        <report test="matches(.,'^\p{Z}+')" role="error" id="ref-name-space-start">
        <name/> element cannot start with space(s). This one (in ref with id=<value-of select="ancestor::ref/@id"/>) does: '<value-of select="."/>'.</report>

        <report test="matches(.,'\p{Z}+$')" role="error" id="ref-name-space-end">
        <name/> element cannot end with space(s). This one (in ref with id=<value-of select="ancestor::ref/@id"/>) does: '<value-of select="."/>'.</report>
     </rule>
  </pattern>

    <pattern id="collab-checks-pattern">
    <rule context="collab" id="collab-checks">
        <report test="matches(.,'^\p{Z}+')" role="error" id="collab-check-1">collab element cannot start with space(s). This one does: <value-of select="."/>
      </report>

        <report test="matches(.,'\p{Z}+$')" role="error" id="collab-check-2">collab element cannot end with space(s). This one does: <value-of select="."/>
      </report>

        <assert test="normalize-space(.)=." role="warning" id="collab-check-3">collab element seems to contain odd spacing. Is it correct? '<value-of select="."/>'</assert>
     </rule>
  </pattern>

    <pattern id="ref-etal-checks-pattern">
    <rule context="mixed-citation[person-group]//etal" id="ref-etal-checks">
        <assert test="parent::person-group" role="error" id="ref-etal-1">If the etal element is included in a reference, and that reference has a person-group element, then the etal should also be included in the person-group element. But this one is a child of <value-of select="parent::*/name()"/>.</assert>
     </rule>
  </pattern>

    <pattern id="ref-comment-checks-pattern">
    <rule context="comment" id="ref-comment-checks">
        <report test="ancestor::mixed-citation" role="warning" id="ref-comment-1">Reference (with id=<value-of select="ancestor::ref/@id"/>) contains a comment element. Is this correct? <value-of select="."/>
      </report>
     </rule>
  </pattern>

    <pattern id="ref-pub-id-checks-pattern">
    <rule context="ref//pub-id" id="ref-pub-id-checks">
        <report test="@pub-id-type='doi' and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))" role="error" id="ref-doi-conformance">&lt;pub-id pub-id="doi"&gt; in reference (id=<value-of select="ancestor::ref/@id"/>) does not contain a valid DOI: '<value-of select="."/>'.</report>
      
        <assert test="@pub-id-type" role="error" id="pub-id-check-1">
        <name/> does not have a pub-id-type attribute.</assert>

        <report test="ancestor::mixed-citation[@publication-type='journal'] and not(@pub-id-type=('doi','pmid','pmcid','issn'))" role="error" id="pub-id-check-2">
        <name/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','issn'.</report>

        <report test="ancestor::mixed-citation[@publication-type='book'] and not(@pub-id-type=('doi','pmid','pmcid','isbn'))" role="error" id="pub-id-check-3">
        <name/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','isbn'.</report>

        <report test="ancestor::mixed-citation[@publication-type='preprint'] and not(@pub-id-type=('doi','pmid','pmcid','arxiv'))" role="error" id="pub-id-check-4">
        <name/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','arxiv'.</report>

        <report test="ancestor::mixed-citation[@publication-type='web']" role="error" id="pub-id-check-5">Web reference (with id <value-of select="ancestor::ref/@id"/>) has a <name/> <value-of select="if (@pub-id-type) then concat('with a pub-id-type ',@pub-id-type) else 'with no pub-id-type'"/> (<value-of select="."/>). This must be incorrect. Either the publication-type for the reference needs changing, or the pub-id should be changed to another element.</report>
     </rule>
  </pattern>
  <pattern id="isbn-conformity-pattern">
    <rule context="ref//pub-id[@pub-id-type='isbn']|isbn" id="isbn-conformity">
        <let name="t" value="translate(.,'-','')"/>
        <let name="sum" value="e:isbn-sum($t)"/>
      
        <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#isbn-conformity-test" test="$sum = 0" role="error" id="isbn-conformity-test">pub-id contains an invalid ISBN - '<value-of select="."/>'. Should it be captured as another type of pub-id?</assert>
      </rule>
  </pattern>
  <pattern id="issn-conformity-pattern">
    <rule context="ref//pub-id[@pub-id-type='issn']|issn" id="issn-conformity">
        <assert test="e:is-valid-issn(.)" role="error" id="issn-conformity-test">pub-id contains an invalid ISSN - '<value-of select="."/>'. Should it be captured as another type of pub-id?</assert>
      </rule>
  </pattern>

    <pattern id="ref-person-group-checks-pattern">
    <rule context="ref//person-group" id="ref-person-group-checks">
      
        <assert test="normalize-space(@person-group-type)!=''" role="error" id="ref-person-group-type">
        <name/> must have a person-group-type attribute with a non-empty value.</assert>
        
        <report test="./@person-group-type = preceding-sibling::person-group/@person-group-type" role="warning" id="ref-person-group-type-2">
        <name/>s within a reference should be distinct. There are numerous person-groups with the person-group-type <value-of select="@person-group-type"/> within this reference (id=<value-of select="ancestor::ref/@id"/>).</report>
        
        <report test="ancestor::mixed-citation[@publication-type='book'] and not(normalize-space(@person-group-type)=('','author','editor'))" role="warning" id="ref-person-group-type-book">This <name/> inside a book reference has the person-group-type '<value-of select="@person-group-type"/>'. Is that correct?</report>
        
        <report test="ancestor::mixed-citation[@publication-type=('journal','data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')] and not(normalize-space(@person-group-type)=('','author'))" role="warning" id="ref-person-group-type-other">This <name/> inside a <value-of select="ancestor::mixed-citation/@publication-type"/> reference has the person-group-type '<value-of select="@person-group-type"/>'. Is that correct?</report>
     </rule>
  </pattern>
  
    <pattern id="ref-checks-pattern">
    <rule context="ref" id="ref-checks">
        <assert test="mixed-citation or element-citation" role="error" id="ref-empty">
        <name/> does not contain either a mixed-citation or an element-citation element.</assert>
        
        <assert test="normalize-space(@id)!=''" role="error" id="ref-id">
        <name/> must have an id attribute with a non-empty value.</assert>
     </rule>
  </pattern>
  
    <pattern id="mixed-citation-checks-pattern">
    <rule context="mixed-citation" id="mixed-citation-checks">
        <let name="publication-type-values" value="('journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')"/>
        <let name="name-elems" value="('name','string-name','collab','on-behalf-of','etal')"/>
        
        <report test="normalize-space(.)=('','.')" role="error" id="mixed-citation-empty-1">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) is empty.</report>
        
        <report test="not(normalize-space(.)=('','.')) and (string-length(normalize-space(.)) lt 6)" role="warning" id="mixed-citation-empty-2">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) only contains <value-of select="string-length(normalize-space(.))"/> characters.</report>
        
        <assert test="normalize-space(@publication-type)!=''" role="error" id="mixed-citation-publication-type-presence">
        <name/> must have a publication-type attribute with a non-empty value.</assert>
        
        <report test="normalize-space(@publication-type)!='' and not(@publication-type=$publication-type-values)" role="warning" id="mixed-citation-publication-type-flag">
        <name/> has publication-type="<value-of select="@publication-type"/>" which is not one of the known/supported types: <value-of select="string-join($publication-type-values,'; ')"/>.</report>
        
        <report test="@publication-type='other'" role="warning" id="mixed-citation-other-publication-flag">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) has a publication-type='other'. Is that correct?</report>

        <report test="*[name()=$name-elems]" role="error" id="mixed-citation-person-group-flag-1">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) has child name elements (<value-of select="string-join(distinct-values(*[name()=$name-elems]/name()),'; ')"/>). These all need to be placed in a person-group element with the appropriate person-group-type attribute.</report>

        <assert test="person-group[@person-group-type='author']" role="warning" id="mixed-citation-person-group-flag-2">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) does not have an author person-group. Is that correct?</assert>
     </rule>
  </pattern>

    <pattern id="back-tests-pattern">
    <rule context="back" id="back-tests">

       <assert test="ref-list" role="error" id="no-ref-list">This preprint has no reference list (as a child of back), which must be incorrect.</assert>

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
      
        <report test="matches(lower-case(.),'www\.|(f|ht)tp|^link\s|\slink\s')" role="warning" id="underline-link-warning">Should this underline element be a link (ext-link) instead? <value-of select="."/>
      </report>

        <report test="replace(.,'[\s\.]','')='&gt;'" role="warning" id="underline-gt-warning">underline element contains a greater than symbol (<value-of select="."/>). Should this a greater than or equal to symbol instead (≥)?</report>

        <report test="replace(.,'[\s\.]','')='&lt;'" role="warning" id="underline-lt-warning">underline element contains a less than symbol (<value-of select="."/>). Should this a less than or equal to symbol instead (≤)?</report>
     </rule>
  </pattern>

    <pattern id="fig-checks-pattern">
    <rule context="fig" id="fig-checks">
        <assert test="graphic" role="error" id="fig-graphic-conformance">
        <value-of select="if (label) then label else name()"/> does not have a child graphic element, which must be incorrect.</assert>
     </rule>
  </pattern>
  <pattern id="fig-child-checks-pattern">
    <rule context="fig/*" id="fig-child-checks">
        <let name="supported-fig-children" value="('label','caption','graphic','alternatives','permissions')"/>
        <assert test="name()=$supported-fig-children" role="error" id="fig-child-conformance">
        <name/> is not supported as a child of &lt;fig&gt;.</assert>
     </rule>
  </pattern>
  <pattern id="fig-label-checks-pattern">
    <rule context="fig/label" id="fig-label-checks">
        <report test="normalize-space(.)=''" role="error" id="fig-wrap-empty">Label for fig is empty. Either remove the elment or add the missing content.</report>
        
        <report test="matches(lower-case(.),'^\s*(video|movie)')" role="warning" id="fig-label-video">Label for figure ('<value-of select="."/>') starts with text that suggests its a video. Should this content be captured as a video instead of a figure?</report>
        
        <report test="matches(lower-case(.),'^\s*table')" role="warning" id="fig-label-table">Label for figure ('<value-of select="."/>') starts with table. Should this content be captured as a table instead of a figure?</report>
     </rule>
  </pattern>

    <pattern id="table-wrap-checks-pattern">
    <rule context="table-wrap" id="table-wrap-checks">
        <!-- adjust when support is added for HTML tables -->
        <assert test="graphic or alternatives[graphic]" role="error" id="table-wrap-content-conformance">
        <value-of select="if (label) then label else name()"/> does not have a child graphic element, which must be incorrect.</assert>
     </rule>
  </pattern>
  <pattern id="table-wrap-child-checks-pattern">
    <rule context="table-wrap/*" id="table-wrap-child-checks">
        <let name="supported-table-wrap-children" value="('label','caption','graphic','alternatives','table','permissions','table-wrap-foot')"/>
        <assert test="name()=$supported-table-wrap-children" role="error" id="table-wrap-child-conformance">
        <value-of select="name()"/> is not supported as a child of &lt;table-wrap&gt;.</assert>
     </rule>
  </pattern>
  <pattern id="table-wrap-label-checks-pattern">
    <rule context="table-wrap/label" id="table-wrap-label-checks">
        <report test="normalize-space(.)=''" role="error" id="table-wrap-empty">Label for table is empty. Either remove the elment or add the missing content.</report>
        
        <report test="matches(lower-case(.),'^\s*fig')" role="warning" id="table-wrap-label-fig">Label for table ('<value-of select="."/>') starts with text that suggests its a figure. Should this content be captured as a figure instead of a table?</report>
     </rule>
  </pattern>
  
    <pattern id="supplementary-material-checks-pattern">
    <rule context="supplementary-material" id="supplementary-material-checks">
        
        <!-- Temporary error while no support for supplementary-material in EPP 
                sec sec-type="supplementary-material" is stripped from XML via xslt -->
        <assert test="ancestor::sec[@sec-type='supplementary-material']" role="error" id="supplementary-material-temp-test">supplementary-material element is not placed within a &lt;sec sec-type="supplementary-material"&gt;. There is currently no support for supplementary-material in RPs. Please either move the supplementary-material under an existing &lt;sec sec-type="supplementary-material"&gt; or add a new &lt;sec sec-type="supplementary-material"&gt; around this an any other supplementary-material.</assert>
        
        <assert test="media" role="error" id="supplementary-material-test-1">supplementary-material does not have a child media. It must either have a file or be deleted.</assert>
        
        <report test="count(media) gt 1" role="error" id="supplementary-material-test-2">supplementary-material has <value-of select="count(media)"/> child media elements. Each file must be wrapped in its own supplementary-material.</report>
      </rule>
  </pattern>
  <pattern id="supplementary-material-child-checks-pattern">
    <rule context="supplementary-material/*" id="supplementary-material-child-checks">
        <let name="permitted-children" value="('label','caption','media')"/>
        
        <assert test="name()=$permitted-children" role="error" id="supplementary-material-child-test-1">
        <name/> is not supported as a child of supplementary-material. The only permitted children are: <value-of select="string-join($permitted-children,'; ')"/>.</assert>
      </rule>
  </pattern>

    <pattern id="disp-formula-checks-pattern">
    <rule context="disp-formula" id="disp-formula-checks">
          <!-- adjust when support is added for mathML -->
          <assert test="graphic or alternatives[graphic]" role="error" id="disp-formula-content-conformance">
        <value-of select="if (label) then concat('Equation ',label) else name()"/> does not have a child graphic element, which must be incorrect.</assert>
      </rule>
  </pattern>
  <pattern id="inline-formula-checks-pattern">
    <rule context="inline-formula" id="inline-formula-checks">
          <!-- adjust when support is added for mathML -->
          <assert test="inline-graphic or alternatives[inline-graphic]" role="error" id="inline-formula-content-conformance">
        <value-of select="name()"/> does not have a child inline-graphic element, which must be incorrect.</assert>
      </rule>
  </pattern>
  <pattern id="disp-equation-alternatives-checks-pattern">
    <rule context="alternatives[parent::disp-formula]" id="disp-equation-alternatives-checks">
          <assert test="graphic and mml:math" role="error" id="disp-equation-alternatives-conformance">alternatives element within <value-of select="parent::*/name()"/> must have both a graphic (or numerous graphics) and mathml representation of the equation. This one does not.</assert>
      </rule>
  </pattern>
  <pattern id="inline-equation-alternatives-checks-pattern">
    <rule context="alternatives[parent::inline-formula]" id="inline-equation-alternatives-checks">
          <assert test="inline-graphic and mml:math" role="error" id="inline-equation-alternatives-conformance">alternatives element within <value-of select="parent::*/name()"/> must have both an inline-graphic (or numerous graphics) and mathml representation of the equation. This one does not.</assert>
      </rule>
  </pattern>

    <pattern id="list-checks-pattern">
    <rule context="list" id="list-checks">
        <let name="supported-list-types" value="('bullet','simple','order','alpha-lower','alpha-upper','roman-lower','roman-upper')"/>
        <assert test="@list-type=$supported-list-types" role="error" id="list-type-conformance">&lt;list&gt; element must have a list-type attribute with one of the supported values: <value-of select="string-join($supported-list-types,'; ')"/>.<value-of select="if (./@list-type) then concat(' list-type ',@list-type,' is not supported.') else ()"/>
      </assert>
     </rule>
  </pattern>
  
     <pattern id="graphic-checks-pattern">
    <rule context="graphic|inline-graphic" id="graphic-checks">
        <let name="link" value="lower-case(@xlink:href)"/>
        <let name="file" value="tokenize($link,'\.')[last()]"/>
        <let name="image-file-types" value="('tif','tiff','gif','jpg','jpeg','png')"/>
        
        <assert test="normalize-space(@xlink:href)!=''" role="error" id="graphic-check-1">
        <name/> must have an xlink:href attribute. This one does not.</assert>
        
        <assert test="$file=$image-file-types" role="error" id="graphic-check-2">
        <name/> must have an xlink:href attribute that ends with an image file type extension. <value-of select="if ($file!='') then $file else @xlink:href"/> is not one of <value-of select="string-join($image-file-types,', ')"/>.</assert>
        
        <report test="contains(@mime-subtype,'tiff') and not($file=('tif','tiff'))" role="error" id="graphic-test-1">
        <name/> has tiff mime-subtype but filename does not end with '.tif' or '.tiff'. This cannot be correct.</report>
        
        <assert test="normalize-space(@mime-subtype)!=''" role="error" id="graphic-test-2">
        <name/> must have a mime-subtype attribute.</assert>
      
        <report test="contains(@mime-subtype,'jpeg') and not($file=('jpg','jpeg'))" role="error" id="graphic-test-3">
        <name/> has jpeg mime-subtype but filename does not end with '.jpg' or '.jpeg'. This cannot be correct.</report>
        
        <assert test="@mimetype='image'" role="error" id="graphic-test-4">
        <name/> must have a @mimetype='image'.</assert>
        
        <report test="@mime-subtype='png' and $file!='png'" role="error" id="graphic-test-5">
        <name/> has png mime-subtype but filename does not end with '.png'. This cannot be correct.</report>
        
        <report test="preceding::graphic/@xlink:href/lower-case(.) = $link or preceding::inline-graphic/@xlink:href/lower-case(.) = $link" role="error" id="graphic-test-6">Image file for <value-of select="if (parent::fig/label) then parent::fig/label else 'graphic'"/> (<value-of select="@xlink:href"/>) is the same as the one used for another graphic or inline-graphic.</report>
        
        <report test="@mime-subtype='gif' and $file!='gif'" role="error" id="graphic-test-7">
        <name/> has gif mime-subtype but filename does not end with '.gif'. This cannot be correct.</report>
     </rule>
  </pattern>
  
      <pattern id="media-checks-pattern">
    <rule context="media" id="media-checks">
        <let name="link" value="@xlink:href"/>
      
      <assert test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,15}$')" role="error" id="media-test-3">media must have an @xlink:href which contains a file reference.</assert>
        
      <report test="preceding::media/@xlink:href = $link" role="error" id="media-test-10">Media file for <value-of select="if (parent::*/label) then parent::*/label else 'media'"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="if (preceding::media[@xlink:href=$link][1]/parent::*/label) then preceding::media[@xlink:href=$link][1]/parent::*/label         else 'another file'"/>.</report>
        
      <report test="text()" role="error" id="media-test-12">Media element cannot contain text. This one has <value-of select="string-join(text(),'')"/>.</report>
        
      <report test="*" role="error" id="media-test-13">Media element cannot contain child elements. This one has the following element(s) <value-of select="string-join(*/name(),'; ')"/>.</report>
     </rule>
  </pattern>
  
    <pattern id="sec-checks-pattern">
    <rule context="sec" id="sec-checks">

        <report test="@sec-type='supplementary-material' and *[not(name()=('label','title','supplementary-material'))]" role="warning" id="sec-supplementary-material">&lt;sec sec-type='supplementary-material'&gt; contains elements other than supplementary-material: <value-of select="string-join(*[not(name()=('label','title','supplementary-material'))]/name(),'; ')"/>. These will currently be stripped from the content rendered on EPP. Should they be moved out of the section or is that OK?'</report>

        <assert test="*[not(name()=('label','title','sec-meta'))]" role="error" id="sec-empty">sec element is not populated with any content. Either there's a mistake or the section should be removed.</assert>
     </rule>
  </pattern>

    <pattern id="title-checks-pattern">
    <rule context="title" id="title-checks">
        <report test="upper-case(.)=." role="warning" id="title-upper-case">Content of &lt;title&gt; element is entirely in upper case: Is that correct? '<value-of select="."/>'</report>

        <report test="lower-case(.)=." role="warning" id="title-lower-case">Content of &lt;title&gt; element is entirely in lower-case case: Is that correct? '<value-of select="."/>'</report>
     </rule>
  </pattern>
  <pattern id="title-toc-checks-pattern">
    <rule context="article/body/sec/title|article/back/sec/title" id="title-toc-checks">
        <report test="xref" role="error" id="toc-title-contains-citation">
        <name/> element contains a citation and will appear within the table of contents on EPP. This will cause images not to load. Please either remove the citaiton or make it plain text.</report>
      </rule>
  </pattern>

    <pattern id="p-bold-checks-pattern">
    <rule context="p[not(ancestor::sub-article) and (count(*)=1) and (child::bold or child::italic)]" id="p-bold-checks">
        <let name="free-text" value="replace(normalize-space(string-join(for $x in self::*/text() return $x,'')),' ','')"/>
        <report test="$free-text=''" role="warning" id="p-all-bold">Content of p element is entirely in <value-of select="child::*[1]/local-name()"/> - '<value-of select="."/>'. Is this correct?</report>
      </rule>
  </pattern>

    <pattern id="general-article-meta-checks-pattern">
    <rule context="article/front/article-meta" id="general-article-meta-checks">
        <let name="is-reviewed-preprint" value="parent::front/journal-meta/lower-case(journal-id[1])='elife'"/>
        <let name="distinct-emails" value="distinct-values((descendant::contrib[@contrib-type='author']/email, author-notes/corresp/email))"/>
        <let name="distinct-email-count" value="count($distinct-emails)"/>
        <let name="corresp-authors" value="distinct-values(for $name in descendant::contrib[@contrib-type='author' and @corresp='yes']/name[1] return e:get-name($name))"/>
        <let name="corresp-author-count" value="count($corresp-authors)"/>
        
        <assert test="article-id[@pub-id-type='doi']" role="error" id="article-id">article-meta must contain at least one DOI - a &lt;article-id pub-id-type="doi"&gt; element.</assert>

        <report test="article-version[not(@article-version-type)] or article-version-alternatives/article-version[@article-version-type='preprint-version']" role="info" id="article-version-flag">This is preprint version <value-of select="if (article-version-alternatives/article-version[@article-version-type='preprint-version']) then article-version-alternatives/article-version[@article-version-type='preprint-version'] else article-version[not(@article-version-type)]"/>.</report>

        <report test="not($is-reviewed-preprint) and not(count(article-version)=1)" role="error" id="article-version-1">article-meta in preprints must contain one (and only one) &lt;article-version&gt; element.</report>
        
        <report test="$is-reviewed-preprint and not(count(article-version-alternatives)=1)" role="error" id="article-version-3">article-meta in reviewed preprints must contain one (and only one) &lt;article-version-alternatives&gt; element.</report>

        <assert test="count(contrib-group)=1" role="error" id="article-contrib-group">article-meta must contain one (and only one) &lt;contrib-group&gt; element.</assert>
        
        <assert test="(descendant::contrib[@contrib-type='author' and email]) or (descendant::contrib[@contrib-type='author']/xref[@ref-type='corresp']/@rid=./author-notes/corresp/@id)" role="error" id="article-no-emails">This preprint has no emails for corresponding authors, which must be incorrect.</assert>
        
        <assert test="$corresp-author-count=$distinct-email-count" role="warning" id="article-email-corresp-author-count-equivalence">The number of corresponding authors (<value-of select="$corresp-author-count"/>: <value-of select="string-join($corresp-authors,'; ')"/>) is not equal to the number of distinct email addresses (<value-of select="$distinct-email-count"/>: <value-of select="string-join($distinct-emails,'; ')"/>). Is this correct?</assert>

        <report test="$corresp-author-count=$distinct-email-count and author-notes/corresp" role="warning" id="article-corresp">The number of corresponding authors and distinct emails is the same, but a match between them has been unable to be made. As its stands the corresp will display on EPP: <value-of select="author-notes/corresp"/>.</report>
      </rule>
  </pattern>
  <pattern id="author-notes-checks-pattern">
    <rule context="article/front/article-meta/author-notes" id="author-notes-checks">
        <report test="count(corresp) gt 1" role="error" id="multiple-corresp">author-notes contains <value-of select="count(corresp)"/> corresp elements. There should only be one. Either these can be collated into one corresp or one of these is a footnote which has been incorrectly captured.</report>
     </rule>
  </pattern>
  <pattern id="article-version-checks-pattern">
    <rule context="article/front/article-meta//article-version" id="article-version-checks">
        
        <report test="parent::article-meta and not(@article-version-type) and not(matches(.,'^1\.\d+$'))" role="error" id="article-version-2">article-version must be in the format 1.x (e.g. 1.11). This one is '<value-of select="."/>'.</report>
        
        <report test="parent::article-version-alternatives and not(@article-version-type=('publication-state','preprint-version'))" role="error" id="article-version-4">article-version placed within article-meta-alternatives must have an article-version-type attribute with either the value 'publication-state' or 'preprint-version'.</report>
        
        <report test="@article-version-type='preprint-version' and not(matches(.,'^1\.\d+$'))" role="error" id="article-version-5">article-version with the attribute article-version-type="preprint-version" must contain text in the format 1.x (e.g. 1.11). This one has '<value-of select="."/>'.</report>
        
        <report test="@article-version-type='publication-state' and .!='reviewed preprint'" role="error" id="article-version-6">article-version with the attribute article-version-type="publication-state" must contain the text 'reviewed preprint'. This one has '<value-of select="."/>'.</report>
        
        <report test="./@article-version-type = preceding-sibling::article-version/@article-version-type" role="error" id="article-version-7">article-version must be distinct. There is one or more article-version elements with the article-version-type <value-of select="@article-version-type"/>.</report>
        
        <report test="@*[name()!='article-version-type']" role="error" id="article-version-11">The only attribute permitted on <name/> is article-version-type. This one has the following unallowed attribute(s): <value-of select="string-join(@*[name()!='article-version-type']/name(),'; ')"/>.</report>
      </rule>
  </pattern>
  <pattern id="article-version-alternatives-checks-pattern">
    <rule context="article/front/article-meta/article-version-alternatives" id="article-version-alternatives-checks">
        <assert test="count(article-version)=2" role="error" id="article-version-8">article-version-alternatives must contain 2 and only 2 article-version elements. This one has '<value-of select="count(article-version)"/>'.</assert>
        
        <assert test="article-version[@article-version-type='preprint-version']" role="error" id="article-version-9">article-version-alternatives must contain a &lt;article-version article-version-type="preprint-version"&gt;.</assert>
        
        <assert test="article-version[@article-version-type='publication-state']" role="error" id="article-version-10">article-version-alternatives must contain a &lt;article-version article-version-type="publication-state"&gt;.</assert>
      </rule>
  </pattern>
  <pattern id="preprint-pub-checks-pattern">
    <rule context="article/front/article-meta/pub-date[@pub-type='epub']/year" id="preprint-pub-checks">
        <assert test=".=('2024','2025')" role="warning" id="preprint-pub-date-1">This preprint version was posted in <value-of select="."/>. Is it the correct version that corresponds to the version submitted to eLife?</assert>
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

    <pattern id="uri-checks-pattern">
    <rule context="uri" id="uri-checks">
        <report test="." role="error" id="uri-flag">The uri element is not permitted. Instead use ext-link with the attribute link-type="uri".</report>
     </rule>
  </pattern>

    <pattern id="xref-checks-pattern">
    <rule context="xref" id="xref-checks">
        <let name="allowed-attributes" value="('ref-type','rid')"/>

        <report test="@*[not(name()=$allowed-attributes)]" role="warning" id="xref-attributes">This xref element has the following attribute(s) which are not supported: <value-of select="string-join(@*[not(name()=$allowed-attributes)]/name(),'; ')"/>.</report>

        <report test="parent::xref" role="error" id="xref-parent">This xref element containing '<value-of select="."/>' is a child of another xref. Nested xrefs are not supported - it must be either stripped or moved so that it is a child of another element.</report>
     </rule>
  </pattern>

    <pattern id="ext-link-tests-pattern">
    <rule context="ext-link[@ext-link-type='uri']" id="ext-link-tests">
      
      <!-- Needs further testing. Presume that we want to ensure a url follows certain URI schemes. -->
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)\[\]+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')" role="warning" id="url-conformance-test">@xlink:href doesn't look like a URL - '<value-of select="@xlink:href"/>'. Is this correct?</assert>
      
      <report test="matches(@xlink:href,'^(ftp|sftp)://\S+:\S+@')" role="warning" id="ftp-credentials-flag">@xlink:href contains what looks like a link to an FTP site which contains credentials (username and password) - '<value-of select="@xlink:href"/>'. If the link without credentials works (<value-of select="concat(substring-before(@xlink:href,'://'),'://',substring-after(@xlink:href,'@'))"/>), then please replace it with that.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#htqb8-url-fullstop-report" test="matches(@xlink:href,'\.$')" role="error" id="url-fullstop-report">'<value-of select="@xlink:href"/>' - Link ends in a full stop which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hjtq3-url-space-report" test="matches(@xlink:href,'[\p{Zs}]')" role="error" id="url-space-report">'<value-of select="@xlink:href"/>' - Link contains a space which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hyyhg-ext-link-text" test="(.!=@xlink:href) and matches(.,'https?:|ftp:')" role="warning" id="ext-link-text">The text for a URL is '<value-of select="."/>' (which looks like a URL), but it is not the same as the actual embedded link, which is '<value-of select="@xlink:href"/>'.</report>

      <report test="matches(@xlink:href,'^https?://(dx\.)?doi\.org/[^1][^0]?')" role="error" id="ext-link-doi-check">Embedded URL within text starts with the DOI prefix, but it is not a valid doi - <value-of select="@xlink:href"/>.</report>

    <report test="not(ancestor::fig/permissions[contains(.,'phylopic')]) and matches(@xlink:href,'phylopic\.org')" role="warning" id="phylopic-link-check">This link is to phylopic.org, which is a site where silhouettes/images are typically reproduced from. Please check whether any figures contain reproduced images from this site, and if so whether permissions have been obtained and/or copyright statements are correctly included.</report>

    <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#ext-link-child-test-5" test="contains(@xlink:href,'datadryad.org/review?')" role="warning" id="ext-link-child-test-5">ext-link looks like it points to a review dryad dataset - <value-of select="."/>. Should it be updated?</report>

    <report test="contains(@xlink:href,'paperpile.com')" role="error" id="paper-pile-test">This paperpile hyperlink should be removed: '<value-of select="@xlink:href"/>' embedded in the text '<value-of select="."/>'.</report>
    </rule>
  </pattern>
  <pattern id="ext-link-tests-2-pattern">
    <rule context="ext-link" id="ext-link-tests-2">
      <assert test="@ext-link-type='uri'" role="error" id="ext-link-type-test-1">ext-link must have the attribute ext-link-type="uri". This one does not. It contains the text: <value-of select="."/>
      </assert>
    </rule>
  </pattern>

    <pattern id="footnote-checks-pattern">
    <rule context="fn-group[fn]" id="footnote-checks">
        <assert test="ancestor::notes" role="error" id="body-footnote">This preprint has footnotes appended to the content. EPP cannot render these, so they need adding to the text.</assert>
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

    <pattern id="ed-report-front-stub-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub" id="ed-report-front-stub">
      
      <assert test="kwd-group[@kwd-group-type='evidence-strength']" role="warning" id="ed-report-str-kwd-presence">eLife Assessment does not have a strength keyword group. Is that correct?</assert>

      <assert test="kwd-group[@kwd-group-type='claim-importance']" role="warning" id="ed-report-sig-kwd-presence">eLife Assessment does not have a significance keyword group. Is that correct?</assert>
    </rule>
  </pattern>
  <pattern id="ed-report-kwd-group-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group" id="ed-report-kwd-group">
      
      <assert test="@kwd-group-type=('claim-importance','evidence-strength')" role="error" id="ed-report-kwd-group-1">kwd-group in <value-of select="parent::*/title-group/article-title"/> must have the attribute kwd-group-type with the value 'claim-importance' or 'evidence-strength'. This one does not.</assert>

      <report test="@kwd-group-type='claim-importance' and count(kwd) gt 1" role="error" id="ed-report-kwd-group-3">
        <value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is not permitted, please check which single importance keyword should be used.</report>
      
      <report test="@kwd-group-type='evidence-strength' and count(kwd) gt 1" role="warning" id="ed-report-kwd-group-2">
        <value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is unusual, please check this is correct.</report>
      
    </rule>
  </pattern>
  <pattern id="ed-report-kwds-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group/kwd" id="ed-report-kwds">
      
        <report test="preceding-sibling::kwd = ." role="error" id="ed-report-kwd-1">Keyword contains <value-of select="."/>, there is another kwd with that value witin the same kwd-group, so this one is either incorrect or superfluous and should be deleted.</report>
      
        <assert test="some $x in ancestor::sub-article[1]/body/p//bold satisfies contains(lower-case($x),lower-case(.))" role="error" id="ed-report-kwd-2">Keyword contains <value-of select="."/>, but this term is not bolded in the text of the <value-of select="ancestor::front-stub/title-group/article-title"/>.</assert>
      
        <report test="*" role="error" id="ed-report-kwd-3">Keywords in <value-of select="ancestor::front-stub/title-group/article-title"/> cannot contain elements, only text. This one has: <value-of select="string-join(distinct-values(*/name()),'; ')"/>.</report>
    </rule>
  </pattern>
  <pattern id="ed-report-claim-kwds-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='claim-importance']/kwd" id="ed-report-claim-kwds">
      <let name="allowed-vals" value="('Landmark', 'Fundamental', 'Important', 'Valuable', 'Useful')"/>
      
      <assert test=".=$allowed-vals" role="error" id="ed-report-claim-kwd-1">Keyword contains <value-of select="."/>, but it is in a 'claim-importance' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/>
      </assert>
      
    </rule>
  </pattern>
  <pattern id="ed-report-evidence-kwds-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='evidence-strength']/kwd" id="ed-report-evidence-kwds">
      <let name="allowed-vals" value="('Exceptional', 'Compelling', 'Convincing', 'Solid', 'Incomplete', 'Inadequate')"/>
      
      <assert test=".=$allowed-vals" role="error" id="ed-report-evidence-kwd-1">Keyword contains <value-of select="."/>, but it is in a 'claim-importance' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/>
      </assert>
    </rule>
  </pattern>
  <pattern id="ed-report-bold-terms-pattern">
    <rule context="sub-article[@article-type='editor-report']/body/p[1]//bold" id="ed-report-bold-terms">
      <let name="allowed-vals" value="('landmark', 'fundamental', 'important', 'valuable', 'useful', 'exceptional', 'compelling', 'convincing', 'convincingly', 'solid', 'incomplete', 'incompletely', 'inadequate', 'inadequately')"/>
      <let name="generated-kwd" value="concat(upper-case(substring(.,1,1)),replace(lower-case(substring(.,2)),'ly$',''))"/>
      
      <assert test="lower-case(.)=$allowed-vals" role="error" id="ed-report-bold-terms-1">Bold phrase in eLife Assessment - <value-of select="."/> - is not one of the permitted terms from the vocabulary. Should the bold formatting be removed? These are currently bolded terms <value-of select="string-join($allowed-vals,', ')"/>
      </assert>

      <report test="lower-case(.)=$allowed-vals and not($generated-kwd=ancestor::sub-article/front-stub/kwd-group/kwd)" role="error" id="ed-report-bold-terms-2">Bold phrase in eLife Assessment - <value-of select="."/> - is one of the permitted vocabulary terms, but there's no corresponding keyword in the metadata (in a kwd-group in the front-stub).</report>
    </rule>
  </pattern>

    <pattern id="arxiv-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id[1])='arxiv']" id="arxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='arXiv'" role="error" id="arxiv-journal-id">arXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'arXiv'.</assert>

      <assert test="journal-title-group/journal-title='arXiv'" role="error" id="arxiv-journal-title">arXiv preprints must have a &lt;journal-title&gt; element with the value 'arXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='arXiv'" role="error" id="arxiv-abbrev-journal-title">arXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'arXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="issn[@pub-type='epub']='2331-8422'" role="error" id="arxiv-issn">arXiv preprints must have a &lt;issn pub-type="epub"&gt; element with the value '2331-8422'.</assert>

      <assert test="publisher/publisher-name='Cornell University'" role="error" id="arxiv-publisher">arXiv preprints must have a &lt;publisher-name&gt; element with the value 'Cornell University', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="arxiv-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id[1])='arxiv']]/article-meta/article-id[@pub-id-type='doi']" id="arxiv-doi-checks">
        <assert test="matches(.,'^10\.48550/arXiv\.\d{4,5}\.\d{4,5}$')" role="error" id="arxiv-doi-conformance">arXiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '10\.48550/arXiv\.\d{4,}\.\d{4,5}'. In other words, the current DOI listed is not a valid arXiv DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="res-square-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id[1])='rs']" id="res-square-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='RS'" role="error" id="res-square-journal-id">Research Square preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'RS'.</assert>

      <assert test="journal-title-group/journal-title='Research Square'" role="error" id="res-square-journal-title">Research Square preprints must have a &lt;journal-title&gt; element with the value 'Research Square' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='rs'" role="error" id="res-square-abbrev-journal-title">Research Square preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'rs' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="issn[@pub-type='epub']='2693-5015'" role="error" id="res-square-issn">Research Square preprints must have a &lt;issn pub-type="epub"&gt; element with the value '2693-5015'.</assert>

      <assert test="publisher/publisher-name='Research Square'" role="error" id="res-square-publisher">Research Square preprints must have a &lt;publisher-name&gt; element with the value 'Research Square', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="res-square-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id[1])='rs']]/article-meta/article-id[@pub-id-type='doi']" id="res-square-doi-checks">
        <assert test="matches(.,'^10\.21203/rs\.3\.rs-\d+/v\d$')" role="error" id="res-square-doi-conformance">Research Square preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.21203/rs\.3\.rs-\d+/v\d$'. In other words, the current DOI listed is not a valid Research Square DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="psyarxiv-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id[1])='psyarxiv']" id="psyarxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='PsyArXiv'" role="error" id="psyarxiv-journal-id">PsyArXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'PsyArXiv'.</assert>

      <assert test="journal-title-group/journal-title='PsyArXiv'" role="error" id="psyarxiv-journal-title">PsyArXiv preprints must have a &lt;journal-title&gt; element with the value 'PsyArXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='PsyArXiv'" role="error" id="psyarxiv-abbrev-journal-title">PsyArXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'PsyArXiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Center for Open Science'" role="error" id="psyarxiv-publisher">PsyArXiv preprints must have a &lt;publisher-name&gt; element with the value 'Center for Open Science', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="psyarxiv-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id[1])='psyarxiv']]/article-meta/article-id[@pub-id-type='doi']" id="psyarxiv-doi-checks">
        <assert test="matches(.,'^10\.31234/osf\.io/[\da-z]+$')" role="error" id="psyarxiv-doi-conformance">PsyArXiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.31234/osf\.io/[\da-z]+$'. In other words, the current DOI listed is not a valid PsyArXiv DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="osf-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id[1])='osf preprints']" id="osf-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='OSF Preprints'" role="error" id="osf-journal-id">Preprints on OSF must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'OSF Preprints'.</assert>

      <assert test="journal-title-group/journal-title='OSF Preprints'" role="error" id="osf-journal-title">Preprints on OSF must have a &lt;journal-title&gt; element with the value 'OSF Preprints' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='OSF pre.'" role="error" id="osf-abbrev-journal-title">Preprints on OSF must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'OSF pre.' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Center for Open Science'" role="error" id="osf-publisher">Preprints on OSF must have a &lt;publisher-name&gt; element with the value 'Center for Open Science', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="osf-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id[1])='osf preprints']]/article-meta/article-id[@pub-id-type='doi']" id="osf-doi-checks">
        <assert test="matches(.,'^10\.31219/osf\.io/[\da-z]+$')" role="error" id="osf-doi-conformance">Preprints on OSF must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10/.31219/osf\.io/[\da-z]+$'. In other words, the current DOI listed is not a valid OSF Preprints DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="ecoevorxiv-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id[1])='ecoevorxiv']" id="ecoevorxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='EcoEvoRxiv'" role="error" id="ecoevorxiv-journal-id">EcoEvoRxiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'EcoEvoRxiv'.</assert>

      <assert test="journal-title-group/journal-title='EcoEvoRxiv'" role="error" id="ecoevorxiv-journal-title">EcoEvoRxiv preprints must have a &lt;journal-title&gt; element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='EcoEvoRxiv'" role="error" id="ecoevorxiv-abbrev-journal-title">EcoEvoRxiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)'" role="error" id="ecoevorxiv-publisher">EcoEvoRxiv preprints must have a &lt;publisher-name&gt; element with the value 'Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="ecoevorxiv-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id[1])='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi']" id="ecoevorxiv-doi-checks">
        <assert test="matches(.,'^10.32942/[A-Z\d]+$')" role="error" id="ecoevorxiv-doi-conformance">EcoEvoRxiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10.32942/[A-Z\d]+$'. In other words, the current DOI listed is not a valid EcoEvoRxiv DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <pattern id="authorea-journal-meta-checks-pattern">
    <rule context="article/front/journal-meta[lower-case(journal-id[1])='authorea']" id="authorea-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='Authorea'" role="error" id="authorea-journal-id">Authorea preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'Authorea'.</assert>

      <assert test="journal-title-group/journal-title='Authorea'" role="error" id="authorea-journal-title">Authorea preprints must have a &lt;journal-title&gt; element with the value 'Authorea' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='Authorea'" role="error" id="authorea-abbrev-journal-title">Authorea preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'Authorea' inside a &lt;journal-title-group&gt; element.</assert>

      <assert test="publisher/publisher-name='Authorea, Inc'" role="error" id="authorea-publisher">Authorea preprints must have a &lt;publisher-name&gt; element with the value 'Authorea, Inc', inside a &lt;publisher&gt; element.</assert>
     </rule>
  </pattern>
  <pattern id="authorea-doi-checks-pattern">
    <rule context="article/front[journal-meta[lower-case(journal-id[1])='authorea']]/article-meta/article-id[@pub-id-type='doi']" id="authorea-doi-checks">
        <assert test="matches(.,'^10\.22541/au\.\d+\.\d+/v\d$')" role="error" id="authorea-doi-conformance">Authorea preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.22541/au\.\d+\.\d+/v\d$'. In other words, the current DOI listed is not a valid Authorea DOI: '<value-of select="."/>'.</assert>
      </rule>
  </pattern>

    <!-- Checks for the manifest file in the meca package.
          For validation in oXygen this assumes the manifest file is in a parent folder of the xml file being validated and named as manifest.xml
          For validation via BaseX, there is a separate file - meca-manifest-schematron.sch
     -->
    
    
<pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::article" role="error" id="biorender-tests-xspec-assert">article must be present.</assert>
      <assert test="descendant::article-meta/title-group/article-title" role="error" id="article-title-checks-xspec-assert">article-meta/title-group/article-title must be present.</assert>
      <assert test="descendant::article-meta/title-group/article-title/*" role="error" id="article-title-children-checks-xspec-assert">article-meta/title-group/article-title/* must be present.</assert>
      <assert test="descendant::article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)]" role="error" id="author-contrib-checks-xspec-assert">article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)] must be present.</assert>
      <assert test="descendant::contrib[@contrib-type='author']" role="error" id="author-corresp-checks-xspec-assert">contrib[@contrib-type='author'] must be present.</assert>
      <assert test="descendant::contrib-group//name" role="error" id="name-tests-xspec-assert">contrib-group//name must be present.</assert>
      <assert test="descendant::contrib-group//name/surname" role="error" id="surname-tests-xspec-assert">contrib-group//name/surname must be present.</assert>
      <assert test="descendant::name/given-names" role="error" id="given-names-tests-xspec-assert">name/given-names must be present.</assert>
      <assert test="descendant::contrib-group//name/*" role="error" id="name-child-tests-xspec-assert">contrib-group//name/* must be present.</assert>
      <assert test="descendant::article/front/article-meta/contrib-group[1]" role="error" id="orcid-name-checks-xspec-assert">article/front/article-meta/contrib-group[1] must be present.</assert>
      <assert test="descendant::aff" role="error" id="affiliation-checks-xspec-assert">aff must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='journal']" role="error" id="journal-ref-checks-xspec-assert">mixed-citation[@publication-type='journal'] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='journal']/source" role="error" id="journal-source-checks-xspec-assert">mixed-citation[@publication-type='journal']/source must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='preprint']" role="error" id="preprint-ref-checks-xspec-assert">mixed-citation[@publication-type='preprint'] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='book']" role="error" id="book-ref-checks-xspec-assert">mixed-citation[@publication-type='book'] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='book']/source" role="error" id="book-ref-source-checks-xspec-assert">mixed-citation[@publication-type='book']/source must be present.</assert>
      <assert test="descendant::ref-list" role="error" id="ref-list-checks-xspec-assert">ref-list must be present.</assert>
      <assert test="descendant::ref-list[ref/label[matches(.,'^\p{P}*\d+\p{P}*$')] and not(ref/label[not(matches(.,'^\p{P}*\d+\p{P}*$'))])]/ref[label]" role="error" id="ref-numeric-label-checks-xspec-assert">ref-list[ref/label[matches(.,'^\p{P}*\d+\p{P}*$')] and not(ref/label[not(matches(.,'^\p{P}*\d+\p{P}*$'))])]/ref[label] must be present.</assert>
      <assert test="descendant::ref-list[ref/label]/ref" role="error" id="ref-label-checks-xspec-assert">ref-list[ref/label]/ref must be present.</assert>
      <assert test="descendant::ref//year" role="error" id="ref-year-checks-xspec-assert">ref//year must be present.</assert>
      <assert test="descendant::mixed-citation//name  or descendant:: mixed-citation//string-name" role="error" id="ref-name-checks-xspec-assert">mixed-citation//name | mixed-citation//string-name must be present.</assert>
      <assert test="descendant::mixed-citation//given-names  or descendant:: mixed-citation//surname" role="error" id="ref-name-space-checks-xspec-assert">mixed-citation//given-names | mixed-citation//surname must be present.</assert>
      <assert test="descendant::collab" role="error" id="collab-checks-xspec-assert">collab must be present.</assert>
      <assert test="descendant::mixed-citation[person-group]//etal" role="error" id="ref-etal-checks-xspec-assert">mixed-citation[person-group]//etal must be present.</assert>
      <assert test="descendant::comment" role="error" id="ref-comment-checks-xspec-assert">comment must be present.</assert>
      <assert test="descendant::ref//pub-id" role="error" id="ref-pub-id-checks-xspec-assert">ref//pub-id must be present.</assert>
      <assert test="descendant::ref//pub-id[@pub-id-type='isbn'] or descendant::isbn" role="error" id="isbn-conformity-xspec-assert">ref//pub-id[@pub-id-type='isbn']|isbn must be present.</assert>
      <assert test="descendant::ref//pub-id[@pub-id-type='issn'] or descendant::issn" role="error" id="issn-conformity-xspec-assert">ref//pub-id[@pub-id-type='issn']|issn must be present.</assert>
      <assert test="descendant::ref//person-group" role="error" id="ref-person-group-checks-xspec-assert">ref//person-group must be present.</assert>
      <assert test="descendant::ref" role="error" id="ref-checks-xspec-assert">ref must be present.</assert>
      <assert test="descendant::mixed-citation" role="error" id="mixed-citation-checks-xspec-assert">mixed-citation must be present.</assert>
      <assert test="descendant::back" role="error" id="back-tests-xspec-assert">back must be present.</assert>
      <assert test="descendant::underline" role="error" id="underline-checks-xspec-assert">underline must be present.</assert>
      <assert test="descendant::fig" role="error" id="fig-checks-xspec-assert">fig must be present.</assert>
      <assert test="descendant::fig/*" role="error" id="fig-child-checks-xspec-assert">fig/* must be present.</assert>
      <assert test="descendant::fig/label" role="error" id="fig-label-checks-xspec-assert">fig/label must be present.</assert>
      <assert test="descendant::table-wrap" role="error" id="table-wrap-checks-xspec-assert">table-wrap must be present.</assert>
      <assert test="descendant::table-wrap/*" role="error" id="table-wrap-child-checks-xspec-assert">table-wrap/* must be present.</assert>
      <assert test="descendant::table-wrap/label" role="error" id="table-wrap-label-checks-xspec-assert">table-wrap/label must be present.</assert>
      <assert test="descendant::supplementary-material" role="error" id="supplementary-material-checks-xspec-assert">supplementary-material must be present.</assert>
      <assert test="descendant::supplementary-material/*" role="error" id="supplementary-material-child-checks-xspec-assert">supplementary-material/* must be present.</assert>
      <assert test="descendant::disp-formula" role="error" id="disp-formula-checks-xspec-assert">disp-formula must be present.</assert>
      <assert test="descendant::inline-formula" role="error" id="inline-formula-checks-xspec-assert">inline-formula must be present.</assert>
      <assert test="descendant::alternatives[parent::disp-formula]" role="error" id="disp-equation-alternatives-checks-xspec-assert">alternatives[parent::disp-formula] must be present.</assert>
      <assert test="descendant::alternatives[parent::inline-formula]" role="error" id="inline-equation-alternatives-checks-xspec-assert">alternatives[parent::inline-formula] must be present.</assert>
      <assert test="descendant::list" role="error" id="list-checks-xspec-assert">list must be present.</assert>
      <assert test="descendant::graphic or descendant::inline-graphic" role="error" id="graphic-checks-xspec-assert">graphic|inline-graphic must be present.</assert>
      <assert test="descendant::media" role="error" id="media-checks-xspec-assert">media must be present.</assert>
      <assert test="descendant::sec" role="error" id="sec-checks-xspec-assert">sec must be present.</assert>
      <assert test="descendant::title" role="error" id="title-checks-xspec-assert">title must be present.</assert>
      <assert test="descendant::article/body/sec/title or descendant::article/back/sec/title" role="error" id="title-toc-checks-xspec-assert">article/body/sec/title|article/back/sec/title must be present.</assert>
      <assert test="descendant::p[not(ancestor::sub-article) and (count(*)=1) and (child::bold or child::italic)]" role="error" id="p-bold-checks-xspec-assert">p[not(ancestor::sub-article) and (count(*)=1) and (child::bold or child::italic)] must be present.</assert>
      <assert test="descendant::article/front/article-meta" role="error" id="general-article-meta-checks-xspec-assert">article/front/article-meta must be present.</assert>
      <assert test="descendant::article/front/article-meta/author-notes" role="error" id="author-notes-checks-xspec-assert">article/front/article-meta/author-notes must be present.</assert>
      <assert test="descendant::article/front/article-meta//article-version" role="error" id="article-version-checks-xspec-assert">article/front/article-meta//article-version must be present.</assert>
      <assert test="descendant::article/front/article-meta/article-version-alternatives" role="error" id="article-version-alternatives-checks-xspec-assert">article/front/article-meta/article-version-alternatives must be present.</assert>
      <assert test="descendant::article/front/article-meta/pub-date[@pub-type='epub']/year" role="error" id="preprint-pub-checks-xspec-assert">article/front/article-meta/pub-date[@pub-type='epub']/year must be present.</assert>
      <assert test="descendant::title" role="error" id="digest-title-checks-xspec-assert">title must be present.</assert>
      <assert test="descendant::xref" role="error" id="xref-checks-xspec-assert">xref must be present.</assert>
      <assert test="descendant::ext-link[@ext-link-type='uri']" role="error" id="ext-link-tests-xspec-assert">ext-link[@ext-link-type='uri'] must be present.</assert>
      <assert test="descendant::ext-link" role="error" id="ext-link-tests-2-xspec-assert">ext-link must be present.</assert>
      <assert test="descendant::fn-group[fn]" role="error" id="footnote-checks-xspec-assert">fn-group[fn] must be present.</assert>
      <assert test="descendant::p or descendant::td or descendant::th or descendant::title or descendant::xref or descendant::bold or descendant::italic or descendant::sub or descendant::sc or descendant::named-content or descendant::monospace or descendant::code or descendant::underline or descendant::fn or descendant::institution or descendant::ext-link" role="error" id="unallowed-symbol-tests-xspec-assert">p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link must be present.</assert>
      <assert test="descendant::sub-article[@article-type='editor-report']/front-stub" role="error" id="ed-report-front-stub-xspec-assert">sub-article[@article-type='editor-report']/front-stub must be present.</assert>
      <assert test="descendant::sub-article[@article-type='editor-report']/front-stub/kwd-group" role="error" id="ed-report-kwd-group-xspec-assert">sub-article[@article-type='editor-report']/front-stub/kwd-group must be present.</assert>
      <assert test="descendant::sub-article[@article-type='editor-report']/front-stub/kwd-group/kwd" role="error" id="ed-report-kwds-xspec-assert">sub-article[@article-type='editor-report']/front-stub/kwd-group/kwd must be present.</assert>
      <assert test="descendant::sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='claim-importance']/kwd" role="error" id="ed-report-claim-kwds-xspec-assert">sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='claim-importance']/kwd must be present.</assert>
      <assert test="descendant::sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='evidence-strength']/kwd" role="error" id="ed-report-evidence-kwds-xspec-assert">sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='evidence-strength']/kwd must be present.</assert>
      <assert test="descendant::sub-article[@article-type='editor-report']/body/p[1]//bold" role="error" id="ed-report-bold-terms-xspec-assert">sub-article[@article-type='editor-report']/body/p[1]//bold must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id[1])='arxiv']" role="error" id="arxiv-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id[1])='arxiv'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id[1])='arxiv']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="arxiv-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id[1])='arxiv']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id[1])='rs']" role="error" id="res-square-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id[1])='rs'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id[1])='rs']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="res-square-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id[1])='rs']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id[1])='psyarxiv']" role="error" id="psyarxiv-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id[1])='psyarxiv'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id[1])='psyarxiv']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="psyarxiv-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id[1])='psyarxiv']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id[1])='osf preprints']" role="error" id="osf-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id[1])='osf preprints'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id[1])='osf preprints']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="osf-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id[1])='osf preprints']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id[1])='ecoevorxiv']" role="error" id="ecoevorxiv-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id[1])='ecoevorxiv'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id[1])='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="ecoevorxiv-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id[1])='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/journal-meta[lower-case(journal-id[1])='authorea']" role="error" id="authorea-journal-meta-checks-xspec-assert">article/front/journal-meta[lower-case(journal-id[1])='authorea'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta[lower-case(journal-id[1])='authorea']]/article-meta/article-id[@pub-id-type='doi']" role="error" id="authorea-doi-checks-xspec-assert">article/front[journal-meta[lower-case(journal-id[1])='authorea']]/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
    </rule>
  </pattern>
</schema>