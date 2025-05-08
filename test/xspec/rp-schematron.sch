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
    
    <xsl:function name="e:is-valid-isbn" as="xs:boolean">
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
        <xsl:variable name="sum" select="number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7 + $d8 + $d9 + $d10) mod 11"/>
        <xsl:value-of select="$sum = 0"/>
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
        <xsl:variable name="sum" select="number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7 + $d8 + $d9 + $d10 + $d11 + $d12 + $d13) mod 10"/>
        <xsl:value-of select="$sum = 0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
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
            <xsl:variable name="remainder" select="number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7) mod 11"/>
            <xsl:variable name="calc" select="if ($remainder=0) then 0 else (11 - $remainder)"/>
            <xsl:variable name="check" select="if (substring($s,9,1)='X') then 10 else number(substring($s,9,1))"/>
            <xsl:value-of select="$calc = $check"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>
  
    <xsl:function name="e:is-valid-orcid" as="xs:boolean">
      <xsl:param name="id" as="xs:string"/>
      <xsl:variable name="digits" select="replace(upper-case($id),'[^\dX]','')"/>
      <xsl:choose>
        <xsl:when test="string-length($digits) != 16">
            <xsl:value-of select="false()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="total" select="e:orcid-calculate-total($digits, 1, 0)"/>
          <xsl:variable name="remainder" select="$total mod 11"/>
          <xsl:variable name="result" select="(12 - $remainder) mod 11"/>
          <xsl:variable name="check" select="if (substring($id,string-length($id))) then 10                                                                             else number(substring($id,string-length($id)))"/>
          <xsl:value-of select="$result = $check"/>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:function>
  
    <xsl:function name="e:orcid-calculate-total" as="xs:integer">
        <xsl:param name="digits" as="xs:string"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="total" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string-length($digits) le $index">
                <xsl:value-of select="$total"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="char" select="substring($digits, $index + 1, 1)"/>
              <xsl:variable name="digit" select="if ($char = 'X') then 10                                                  else xs:integer($char)"/>
                <xsl:variable name="new-total" select="($total + $digit) * 2"/>
                <xsl:value-of select="e:orcid-calculate-total($digits, $index+1, $new-total)"/>
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
  
  <xsl:function name="e:get-copyright-holder">
    <xsl:param name="contrib-group"/>
    <xsl:variable name="author-count" select="count($contrib-group/contrib[@contrib-type='author'])"/>
    <xsl:choose>
      <xsl:when test="$author-count lt 1"/>
      <xsl:when test="$author-count = 1">
        <xsl:choose>
          <xsl:when test="$contrib-group/contrib[@contrib-type='author']/collab">
            <xsl:value-of select="$contrib-group/contrib[@contrib-type='author']/collab[1]/text()[1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$contrib-group/contrib[@contrib-type='author']/name[1]/surname[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$author-count = 2">
        <xsl:choose>
          <xsl:when test="$contrib-group/contrib[@contrib-type='author']/collab">
            <xsl:choose>
              <xsl:when test="$contrib-group/contrib[@contrib-type='author'][1]/collab and $contrib-group/contrib[@contrib-type='author'][2]/collab">
                <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author']/collab[1]/text()[1],' &amp; ',$contrib-group/contrib[@contrib-type='author']/collab[2]/text()[1])"/>
              </xsl:when>
              <xsl:when test="$contrib-group/contrib[@contrib-type='author'][1]/collab">
                <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/collab[1]/text()[1],' &amp; ',$contrib-group/contrib[@contrib-type='author'][2]/name[1]/surname[1])"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/name[1]/surname[1],' &amp; ',$contrib-group/contrib[@contrib-type='author'][2]/collab[1]/text()[1])"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/name[1]/surname[1],' &amp; ',$contrib-group/contrib[@contrib-type='author'][2]/name[1]/surname[1])"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- author count is 3+ -->
      <xsl:otherwise>
        <xsl:variable name="is-equal-contrib" select="if ($contrib-group/contrib[@contrib-type='author'][1]/@equal-contrib='yes') then true() else false()"/>
        <!-- VORs have logic to account for mutliple first authors
              RPs do not currently do this-->
        <xsl:value-of select="concat(e:get-surname($contrib-group/contrib[@contrib-type='author'][1]),' et al')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="e:get-surname" as="text()">
    <xsl:param name="contrib"/>
    <xsl:choose>
      <xsl:when test="$contrib/collab">
        <xsl:value-of select="$contrib/collab[1]/text()[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$contrib//name[1]/surname[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="e:get-ordinal" as="xs:string">
    <xsl:param name="value" as="xs:integer?"/>
    <xsl:if test="translate(string($value), '0123456789', '') = '' and number($value) &gt; 0">
      <xsl:variable name="mod100" select="$value mod 100"/>
      <xsl:variable name="mod10" select="$value mod 10"/>
      <xsl:choose>
        <xsl:when test="$mod100 = 11 or $mod100 = 12 or $mod100 = 13">
          <xsl:value-of select="concat($value,'th')"/>
        </xsl:when>
        <xsl:when test="$mod10 = 1">
          <xsl:value-of select="concat($value,'st')"/>
        </xsl:when>
        <xsl:when test="$mod10 = 2">
          <xsl:value-of select="concat($value,'nd')"/>
        </xsl:when>
        <xsl:when test="$mod10 = 3">
          <xsl:value-of select="concat($value,'rd')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($value,'th')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:function>

  

     <pattern id="article-tests-pattern">
    <rule context="article[front/journal-meta/lower-case(journal-id[1])='elife']" id="article-tests">
      <!-- exclude ref list and figures from this check -->
      <let name="article-text" value="string-join(for $x in self::*/*[local-name() = 'body' or local-name() = 'back']//*           return           if ($x/ancestor::ref-list) then ()           else if ($x/ancestor::caption[parent::fig] or $x/ancestor::permissions[parent::fig]) then ()           else $x/text(),'')"/>
      <let name="is-revised-rp" value="if (descendant::article-meta/pub-history/event/self-uri[@content-type='reviewed-preprint']) then true() else false()"/>
        <let name="rp-version" value="replace(descendant::article-meta[1]/article-id[@specific-use='version'][1],'^.*\.','')"/>

       <report test="not($is-revised-rp) and matches(lower-case($article-text),'biorend[eo]r')" role="warning" id="biorender-check-v1">Article text contains a reference to bioRender. Any figures created with bioRender should include a sentence in the caption in the format: "Created with BioRender.com/{figure-code}".</report>
        
        <report test="$is-revised-rp and matches(lower-case($article-text),'biorend[eo]r')" role="warning" id="biorender-check-revised">Article text contains a reference to bioRender. Any figures created with bioRender should include a sentence in the caption in the format: "Created with BioRender.com/{figure-code}". Since this is a revised RP, check to see if the first (or a previous) version had bioRender links.</report>
        
        <assert test="sub-article[@article-type='editor-report']" role="error" id="no-assessment">A Reviewed Preprint must have an eLife Assessment, but this one does not.</assert>
        
        <assert test="sub-article[@article-type='referee-report']" role="error" id="no-public-review">A Reviewed Preprint must have at least one Public Review, but this one does not.</assert>

        <report test="$is-revised-rp and not(sub-article[@article-type='author-comment'])" role="warning" id="no-author-response-1">Revised Reviewed Preprint (version <value-of select="$rp-version"/>) does not have an author response, which is unusual. Is that correct?</report>
        
        <report test="not($is-revised-rp) and (number($rp-version) gt 1) and not(sub-article[@article-type='author-comment'])" role="warning" id="no-author-response-2">Revised Reviewed Preprint (version <value-of select="$rp-version"/>) does not have an author response, which is unusual. Is that correct?</report>

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
        
        <report test="(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and not(@equal-contrib='yes')" role="error" id="author-equal-contrib-1">Author <value-of select="e:get-name(name[1])"/> does not have the attribute equal-contrib="yes", but they have a child xref element that points to a footnote with the fn-type 'equal'.</report>
        
        <report test="not(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and @equal-contrib='yes'" role="error" id="author-equal-contrib-2">Author <value-of select="e:get-name(name[1])"/> has the attribute equal-contrib="yes", but they do not have a child xref element that points to a footnote with the fn-type 'equal'.</report>
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
  <pattern id="orcid-tests-pattern">
    <rule context="contrib-id[@contrib-id-type='orcid']" id="orcid-tests">
       
	     <assert test="matches(.,'^http[s]?://orcid.org/[\d]{4}-[\d]{4}-[\d]{4}-[\d]{3}[0-9X]$')" role="error" id="orcid-test-2">contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL in the format 'https://orcid.org/0000-0000-0000-0000'</assert>
	  
	     <assert test="e:is-valid-orcid(.)" role="error" id="orcid-test-4">contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL. <value-of select="."/> is not a valid ORCID URL.</assert>
		
		</rule>
  </pattern>
  <pattern id="affiliation-checks-pattern">
    <rule context="aff" id="affiliation-checks">
      <let name="country-count" value="count(descendant::country)"/>
      <let name="city-count" value="count(descendant::city)"/>
      
      <report test="$country-count lt 1" role="warning" id="aff-no-country">Affiliation does not contain a country element: <value-of select="."/>
      </report>

      <report test="$country-count gt 1" role="error" id="aff-multiple-country">Affiliation contains more than one country element: <value-of select="string-join(descendant::country,'; ')"/> in <value-of select="."/>
      </report>
      
      <report test="$city-count lt 1" role="warning" id="aff-no-city">Affiliation does not contain a city element: <value-of select="."/>
      </report>

      <report test="$city-count gt 1" role="error" id="aff-city-country">Affiliation contains more than one city element: <value-of select="string-join(descendant::country,'; ')"/> in <value-of select="."/>
      </report>

      <report test="count(descendant::institution) gt 1" role="warning" id="aff-multiple-institution">Affiliation contains more than one institution element: <value-of select="string-join(descendant::institution,'; ')"/> in <value-of select="."/>
      </report>
      
      <report test="count(descendant::institution-id) gt 1" role="error" id="aff-multiple-ids">Affiliation contains more than one institution-id element: <value-of select="string-join(descendant::institution-id,'; ')"/> in <value-of select="."/>
      </report>
      
      <report test="ancestor::article//journal-meta/lower-case(journal-id[1])='elife' and count(institution-wrap) = 0" role="warning" id="aff-no-wrap">Affiliation doesn't have an institution-wrap element (the container for institution name and id). Is that correct?</report>
      
      <report test="institution-wrap[not(institution-id)] and not(ancestor::contrib-group[@content-type='section']) and not(ancestor::sub-article)" role="error" id="aff-has-wrap-no-id">aff contains institution-wrap, but that institution-wrap does not have a child institution-id. institution-wrap should only be used when there is an institution-id for the institution.</report>
      
      <report test="institution-wrap[not(institution)]" role="error" id="aff-has-wrap-no-inst">aff contains institution-wrap, but that institution-wrap does not have a child institution.</report>
      
      <report test="count(descendant::institution-wrap) gt 1" role="error" id="aff-mutliple-wraps">Affiliation contains more than one institution-wrap element: <value-of select="string-join(descendant::institution-wrap/*,'; ')"/> in <value-of select="."/>
      </report>
      
      <assert test="ancestor::contrib-group" role="error" id="aff-ancestor">aff elements must be a descendant of contrib-group. This one is not.</assert>
      
      <assert test="parent::contrib-group or parent::contrib" role="error" id="aff-parent">aff elements must be a child of either contrib-group or contrib. This one is a child of <value-of select="parent::*/name()"/>.</assert>
    </rule>
  </pattern>
  <pattern id="country-tests-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//aff/country" id="country-tests">
      <let name="text" value="self::*/text()"/>
      <let name="countries" value="'countries.xml'"/>
      <let name="city" value="parent::aff/descendant::city[1]"/>
      <let name="valid-country" value="document($countries)/countries/country[text() = $text]"/>
      
      <assert test="$valid-country" role="warning" id="gen-country-test">affiliation contains a country which is not in the list of standardised countriy names - <value-of select="."/>. Is that OK? For a list of allowed countries, refer to https://github.com/elifesciences/eLife-JATS-schematron/blob/master/src/countries.xml.</assert>
      
      <report test="not(@country = $valid-country/@country)" role="warning" id="gen-country-iso-3166-test">country does not have a 2 letter ISO 3166-1 @country value. Should it be @country='<value-of select="$valid-country/@country"/>'?.</report>
      
      <report test="(. = 'Singapore') and ($city != 'Singapore')" role="error" id="singapore-test-1">
        <value-of select="ancestor::aff/@id"/> has 'Singapore' as its country but '<value-of select="$city"/>' as its city, which must be incorrect.</report>
      
      <report test="(. != 'Taiwan') and  (matches(lower-case($city),'ta[i]?pei|tai\p{Zs}?chung|kaohsiung|taoyuan|tainan|hsinchu|keelung|chiayi|changhua|jhongli|tao-yuan|hualien'))" role="warning" id="taiwan-test">Affiliation has a Taiwanese city - <value-of select="$city"/> - but its country is '<value-of select="."/>'. Please check the original preprint/manuscript. If it has 'Taiwan' as the country in the original manuscript then ensure it is changed to 'Taiwan'.</report>
      
      <report test="(. != 'Republic of Korea') and  (matches(lower-case($city),'chuncheon|gyeongsan|daejeon|seoul|daegu|gwangju|ansan|goyang|suwon|gwanju|ochang|wonju|jeonnam|cheongju|ulsan|inharo|chonnam|miryang|pohang|deagu|gwangjin-gu|gyeonggi-do|incheon|gimhae|gyungnam|muan-gun|chungbuk|chungnam|ansung|cheongju-si'))" role="warning" id="s-korea-test">Affiliation has a South Korean city - <value-of select="$city"/> - but its country is '<value-of select="."/>', instead of 'Republic of Korea'.</report>
      
      <report test="replace(.,'\p{P}','') = 'Democratic Peoples Republic of Korea'" role="warning" id="n-korea-test">Affiliation has '<value-of select="."/>' as its country which is very likely to be incorrect.</report>
    </rule>
  </pattern>
  <pattern id="aff-institution-wrap-tests-pattern">
    <rule context="aff[ancestor::contrib-group[not(@*)]/parent::article-meta]//institution-wrap" id="aff-institution-wrap-tests">
      <let name="display" value="string-join(parent::aff//*[not(local-name()=('label','institution-id','institution-wrap','named-content','city'))],', ')"/>
      
      <assert test="institution-id and institution[not(@*)]" role="error" id="aff-institution-wrap-test-1">If an affiliation has an institution wrap, then it must have both an institution-id and an institution. If there is no ROR for this institution, then it should be captured as a single institution element without institution-wrap. This institution-wrap does not have both elements - <value-of select="$display"/>
      </assert>
      
      <assert test="parent::aff" role="error" id="aff-institution-wrap-test-2">institution-wrap must be a child of aff. This one has <value-of select="parent::*/name()"/> as its parent.</assert>
      
      <report test="count(institution-id)=1 and text()" role="error" id="aff-institution-wrap-test-3">institution-wrap cannot contain text. It can only contain elements.</report>
      
      <assert test="count(institution[not(@*)]) = 1" role="error" id="aff-institution-wrap-test-5">institution-wrap must contain 1 and only 1 institution elements. This one has <value-of select="count(institution[not(@*)])"/>.</assert>
      
    </rule>
  </pattern>
  <pattern id="aff-institution-id-tests-pattern">
    <rule context="aff//institution-id" id="aff-institution-id-tests">
      
      <assert test="@institution-id-type='ror'" role="error" id="aff-institution-id-test-1">institution-id in aff must have the attribute institution-id-type="ror".</assert>
      
      <assert test="matches(.,'^https?://ror\.org/[a-z0-9]{9}$')" role="error" id="aff-institution-id-test-2">institution-id in aff must a value which is a valid ROR id. '<value-of select="."/>' is not a valid ROR id.</assert>
      
      <report test="*" role="error" id="aff-institution-id-test-3">institution-id in aff cannot contain elements, only text (which is a valid ROR id). This one contains the following element(s): <value-of select="string-join(*/name(),'; ')"/>.</report>
        
      <report test="matches(.,'^http://')" role="error" id="aff-institution-id-test-4">institution-id in aff must use the https protocol. This one uses http - '<value-of select="."/>'.</report>    
      
    </rule>
  </pattern>
  <pattern id="aff-ror-tests-pattern">
    <rule context="aff[count(institution-wrap/institution-id[@institution-id-type='ror'])=1]" id="aff-ror-tests">
      <let name="rors" value="'rors.xml'"/>
      <let name="ror" value="institution-wrap[1]/institution-id[@institution-id-type='ror'][1]"/>
      <let name="matching-ror" value="document($rors)//*:ror[*:id=$ror]"/>
      <let name="display" value="string-join(descendant::*[not(local-name()=('label','institution-id','institution-wrap','named-content','city','country'))],', ')"/>
      
      <assert test="exists($matching-ror)" role="error" id="aff-ror">Affiliation (<value-of select="$display"/>) has a ROR id - <value-of select="$ror"/> - but it does not look like a correct one.</assert>
      
      <report test="(city or ancestor::contrib[@contrib-type='author' and not(ancestor::sub-article)]) and exists($matching-ror) and not(contains(city[1],$matching-ror/*:city[1]))" role="warning" id="aff-ror-city">Affiliation has a ROR id, but its city is not the same one as in the ROR data. Is that OK? ROR has '<value-of select="$matching-ror/*:city"/>', but the affiliation city is <value-of select="city[1]"/>.</report>
      
      <report test="(country or ancestor::contrib[@contrib-type='author' and not(ancestor::sub-article)]) and exists($matching-ror) and not(contains(country[1],$matching-ror/*:country[1]))" role="warning" id="aff-ror-country">Affiliation has a ROR id, but its country is not the same one as in the ROR data. Is that OK? ROR has '<value-of select="$matching-ror/*:country"/>', but the affiliation country is <value-of select="country[1]"/>.</report>
        
      <report test="$matching-ror[@status='withdrawn']" role="error" id="aff-ror-status">Affiliation has a ROR id, but the ROR id's status is withdrawn. Withdrawn RORs should not be used. Should one of the following be used instead?: <value-of select="string-join(for $x in $matching-ror/*:relationships/* return concat('(',$x/name(),') ',$x/*:id,' ',$x/*:label),'; ')"/>.</report>
      
    </rule>
  </pattern>

    <pattern id="journal-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='journal']" id="journal-ref-checks">
        <assert test="source" role="error" id="journal-ref-source">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" role="error" id="journal-ref-article-title">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>

        <report test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+((jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\p{Z}?\d?\d?|doi|pmid|epub|vol|and|pp?|in|is[sb]n)[:\.]?'))]" role="warning" id="journal-ref-text-content">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has untagged textual content - <value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+((jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\p{Z}?\d?\d?|doi|pmid|epub|vol|and|pp?|in|is[sb]n)[:\.]?'))],'; ')"/>. Is it tagged correctly?</report>
       
       <report test="person-group[@person-group-type='editor']" role="warning" id="journal-ref-editor">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has an editor person-group. This info isn;t typically included in journal refs. Is it really a journal ref? Does it really contain editors?</report>
     </rule>
  </pattern>
  <pattern id="journal-source-checks-pattern">
    <rule context="mixed-citation[@publication-type='journal']/source" id="journal-source-checks">
      <let name="preprint-regex" value="'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra'"/>
       
       <report test="matches(lower-case(.),$preprint-regex)" role="warning" id="journal-source-1">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source which suggests it might be a preprint - <value-of select="."/>. Is it tagged correctly?</report>
       

       <report test="matches(lower-case(.),'^i{1,3}\.\s') and parent::*/article-title" role="warning" id="journal-source-2">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that starts with a roman numeral. Is part of the article-title captured in source? Source = <value-of select="."/>.</report>

       <report test="matches(lower-case(.),'^(symposium|conference|meeting|workshop)\s|\s?(symposium|conference|meeting|workshop)\s?|\s(symposium|conference|meeting|workshop)$')" role="warning" id="journal-source-3">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has the following source, '<value-of select="."/>'. Should it be captured as a conference proceeding instead?</report>
       
       <report test="matches(lower-case(.),'^in[^a-z]')" role="warning" id="journal-source-4">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that starts with 'In ', '<value-of select="."/>'. Should that text be moved out of the source? And is it a different type of reference?</report>
       
       <report test="matches(.,'[“”&quot;]')" role="warning" id="journal-source-5">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains speech quotes - <value-of select="."/>. Is that correct?</report>
     </rule>
  </pattern>

    <pattern id="preprint-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='preprint']" id="preprint-ref-checks">
        <assert test="source" role="error" id="preprint-ref-source">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" role="error" id="preprint-ref-article-title">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>

        <report test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))]" role="warning" id="preprint-ref-text-content">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has untagged textual content - <value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))],'; ')"/>. Is it tagged correctly?</report>
       
       <report test="volume" role="error" id="preprint-ref-volume">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a volume - <value-of select="volume"/>. That information is either tagged incorrectly, or the publication-type is wrong.</report>
       
       <report test="lpage" role="error" id="preprint-ref-lpage">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has an lpage element - <value-of select="lpage"/>. That information is either tagged incorrectly, or the publication-type is wrong.</report>
     </rule>
  </pattern>
  <pattern id="preprint-source-checks-pattern">
    <rule context="mixed-citation[@publication-type='preprint']/source" id="preprint-source-checks">
        <report test="matches(lower-case(.),'^(\.\s*)?in[^a-z]')" role="warning" id="preprint-source">Preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that starts with 'In ', '<value-of select="."/>'. Should that text be moved out of the source? And is it a different type of reference?</report>
        
        <report test="matches(.,'[“”&quot;]')" role="warning" id="preprint-source-2">Preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains speech quotes - <value-of select="."/>. Is that correct?</report>
      </rule>
  </pattern>

    <pattern id="book-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='book']" id="book-ref-checks">
        <assert test="source" role="error" id="book-ref-source">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>
       
       <report test="count(source) gt 1" role="error" id="book-ref-source-2">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has more than 1 source element.</report>
       
       <report test="not(chapter-title) and person-group[@person-group-type='editor']" role="warning" id="book-ref-editor">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has an editor person-group but no chapter-title element. Have all the details been captured correctly?</report>
       
       <report test="chapter-title and not(person-group[@person-group-type='editor'])" role="warning" id="book-ref-editor-2">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a chapter-title but no person-group element with the person-group-type editor. Have all the details been captured correctly?</report>
       
       <report test="not(chapter-title) and publisher-name[italic]" role="warning" id="book-ref-pub-name-1">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a publisher-name with italics and no chapter-title element. Have all the details been captured correctly?</report>
       
       <report test="descendant::article-title" role="error" id="book-ref-article-title">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a descendant article-title. This cannot be correct. It should either be a source or chapter-title (or something else entirely).</report>
     </rule>
  </pattern>
  <pattern id="book-ref-source-checks-pattern">
    <rule context="mixed-citation[@publication-type='book']/source" id="book-ref-source-checks">
        
        <report test="matches(lower-case(.),'^chapter\s|\s+chapter\s+')" role="warning" id="book-source-1">The source in book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) contains 'chapter' - <value-of select="."/>. Are the details captured correctly?</report>
        
        <report test="matches(lower-case(.),'^(\.\s*)?in[^a-z]|\.\s+in:\s+')" role="warning" id="book-source-2">The source in book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) contains 'In: ' - <value-of select="."/>. Are the details captured correctly?</report>

        <report test="matches(lower-case(.),'^(symposium|conference|proc\.?|proceeding|meeting|workshop)|\s?(symposium|conference|proc\.?|proceeding|meeting|workshop)\s?|(symposium|conference|proc\.?|proceeding|meeting|workshop)$')" role="warning" id="book-source-3">Book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has the following source, '<value-of select="."/>'. Should it be captured as a conference proceeding instead?</report>
        
        <report test="matches(.,'[“”&quot;]')" role="warning" id="book-source-4">Book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains speech quotes - <value-of select="."/>. Is that correct?</report>
      </rule>
  </pattern>
  
  <pattern id="confproc-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='confproc']" id="confproc-ref-checks">
        <assert test="conf-name" role="error" id="confproc-ref-conf-name">This conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no conf-name element.</assert>
       
       <report test="count(conf-name) gt 1" role="error" id="confproc-ref-conf-name-2">This conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has more than 1 conf-name element.</report>
       
       <assert test="article-title" role="warning" id="confproc-ref-article-title">This conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>
     </rule>
  </pattern>
  <pattern id="confproc-conf-name-checks-pattern">
    <rule context="mixed-citation[@publication-type='confproc']/conf-name" id="confproc-conf-name-checks">
      <report test="matches(lower-case(.),'^(\.\s*)?in[^a-z]')" role="warning" id="confproc-conf-name">The conf-name in conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) starts with 'In: ' - <value-of select="."/>. Are the details captured correctly?</report>
    </rule>
  </pattern>

    <pattern id="ref-list-checks-pattern">
    <rule context="ref-list" id="ref-list-checks">
        <let name="labels" value="./ref/label"/>
        <let name="indistinct-labels" value="for $label in distinct-values($labels) return $label[count($labels[. = $label]) gt 1]"/>
        <assert test="empty($indistinct-labels)" role="error" id="indistinct-ref-labels">Duplicate labels in reference list - <value-of select="string-join($indistinct-labels,'; ')"/>. Have there been typesetting errors?</assert>

        <report test="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')] and ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))]" role="warning" id="ref-label-types">This ref-list has labels in the format '<value-of select="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')][1]"/>' as well as labels in the format '<value-of select="ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))][1]"/>'. Is that correct?</report>
       
       <report test="parent::back and preceding-sibling::ref-list[parent::back]" role="warning" id="multiple-ref-list">This is the <value-of select="e:get-ordinal(count(preceding-sibling::ref-list[parent::back]) + 1)"/> reference list that is a child of back, which is possibly incorrect. Most commonly <value-of select="e:get-ordinal(count(preceding-sibling::ref-list[parent::back]) + 1)"/> reference list would be included within a appendix or methods section. Is there an appendix that this should be placed?</report>
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
        
        <report test="name()='string-name' and text()[not(matches(.,'^[\s\p{P}]*$'))]" role="error" id="ref-string-name-text">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) has child text containing content. This content should either be tagged or moved into a different appropriate tag, as appropriate.</report>
     </rule>
  </pattern>
  <pattern id="ref-name-space-checks-pattern">
    <rule context="mixed-citation//given-names | mixed-citation//surname" id="ref-name-space-checks">
        <report test="matches(.,'^\p{Z}+')" role="error" id="ref-name-space-start">
        <name/> element cannot start with space(s). This one (in ref with id=<value-of select="ancestor::ref/@id"/>) does: '<value-of select="."/>'.</report>

        <report test="matches(.,'\p{Z}+$')" role="error" id="ref-name-space-end">
        <name/> element cannot end with space(s). This one (in ref with id=<value-of select="ancestor::ref/@id"/>) does: '<value-of select="."/>'.</report>
        
        <report test="not(*) and (normalize-space(.)='')" role="error" id="ref-name-empty">
        <name/> element must not be empty.</report>
     </rule>
  </pattern>

    <pattern id="collab-checks-pattern">
    <rule context="collab" id="collab-checks">
        <report test="matches(.,'^\p{Z}+')" role="error" id="collab-check-1">collab element cannot start with space(s). This one does: <value-of select="."/>
      </report>

        <report test="matches(.,'\p{Z}+$')" role="error" id="collab-check-2">collab element cannot end with space(s). This one does: <value-of select="."/>
      </report>

        <assert test="normalize-space(.)=." role="warning" id="collab-check-3">collab element seems to contain odd spacing. Is it correct? '<value-of select="."/>'</assert>
        
        <report test="matches(.,'^[\p{Z}\p{N}\p{P}]*$')" role="warning" id="collab-check-4">collab element consists only of spaces, punctuation and/or numbers (or is empty) - '<value-of select="."/>'. Is it really a collab?</report>
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
        
        <report test="(@pub-id-type='pmid') and not(matches(.,'^\d{3,10}$'))" role="error" id="ref-pmid-conformance">pub-id is tagged as a pmid, but it is not a number made up of between 3 and 10 digits - <value-of select="."/>. The id must be either incorrect or have the wrong pub-id-type.</report>
        
        <report test="(@pub-id-type='pmcid') and not(matches(.,'^PMC[0-9]{5,15}$'))" role="error" id="ref-pmcid-conformance">pub-id is tagged as a pmcid, but it is not a valid PMCID ('PMC' followed by 5+ digits) - <value-of select="."/>. The id must be either incorrect or have the wrong pub-id-type.</report>
        
        <report test="(@pub-id-type='arxiv') and not(matches(.,'^(\d{2}(0[1-9]|1[0-2])\.\d{5}|\d{2}(0[1-9]|1[0-2])\d{3})$'))" role="error" id="ref-arxiv-conformance">pub-id is tagged as an arxiv id, but it is not a valid arxiv id (a number in the format yymm.nnnnn or yymmnnn) - <value-of select="."/>. The id must be either incorrect or have the wrong pub-id-type.</report>
      
        <assert test="@pub-id-type" role="error" id="pub-id-check-1">
        <name/> does not have a pub-id-type attribute.</assert>

        <report test="ancestor::mixed-citation[@publication-type='journal'] and not(@pub-id-type=('doi','pmid','pmcid','issn'))" role="error" id="pub-id-check-2">
        <name/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','issn'.</report>

        <report test="ancestor::mixed-citation[@publication-type='book'] and not(@pub-id-type=('doi','pmid','pmcid','isbn'))" role="error" id="pub-id-check-3">
        <name/> is within a book reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','isbn'.</report>

        <report test="ancestor::mixed-citation[@publication-type='preprint'] and not(@pub-id-type=('doi','pmid','pmcid','arxiv'))" role="error" id="pub-id-check-4">
        <name/> is within a preprint reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','arxiv'.</report>

        <report test="ancestor::mixed-citation[@publication-type='web']" role="error" id="pub-id-check-5">Web reference (with id <value-of select="ancestor::ref/@id"/>) has a <name/> <value-of select="if (@pub-id-type) then concat(' with a pub-id-type ',@pub-id-type) else 'with no pub-id-type'"/> (<value-of select="."/>). This must be incorrect. Either the publication-type for the reference needs changing, or the pub-id should be changed to another element.</report>
        
        <report test="@pub-id-type='doi' and ancestor::mixed-citation[@publication-type=('journal','book','preprint')] and matches(following-sibling::text()[1],'^[\.\s]?[\.\s]?[/&lt;&gt;:\d\+\-]')" role="warning" id="pub-id-check-6">doi in <value-of select="ancestor::mixed-citation/@publication-type"/> ref is followd by text - '<value-of select="following-sibling::text()[1]"/>'. Should that text be part of the DOI or tagged in some other way?</report>
     </rule>
  </pattern>
  <pattern id="isbn-conformity-pattern">
    <rule context="ref//pub-id[@pub-id-type='isbn']|isbn" id="isbn-conformity">
        <let name="t" value="translate(.,'-','')"/>
      
        <assert test="e:is-valid-isbn(.)" role="error" id="isbn-conformity-test">
        <name/> element contains an invalid ISBN - '<value-of select="."/>'. Should it be captured as another type of id?</assert>
      </rule>
  </pattern>
  <pattern id="issn-conformity-pattern">
    <rule context="ref//pub-id[@pub-id-type='issn']|issn" id="issn-conformity">
        <assert test="e:is-valid-issn(.)" role="error" id="issn-conformity-test">
        <name/> element contains an invalid ISSN - '<value-of select="."/>'. Should it be captured as another type of id?</assert>
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
  
  <pattern id="ref-article-title-checks-pattern">
    <rule context="ref//article-title" id="ref-article-title-checks">
        <report test="matches(.,'^\s*[“”&quot;]|[“”&quot;]\.*$')" role="warning" id="ref-article-title-1">
        <name/> in ref starts or ends with speech quotes - <value-of select="."/>. Is that correct?.</report>
        
        <report test="upper-case(.)=." role="warning" id="ref-article-title-2">
        <name/> in ref is entirely in upper case - <value-of select="."/>. Is that correct?</report>
        
        <report test="matches(.,'\?[^\s\p{P}]')" role="warning" id="ref-article-title-3">
        <name/> in ref contains a question mark which may potentially be the result of a processing error - <value-of select="."/>. Should it be repalced with other characters?</report>
        
        <report test="matches(.,'\p{Ps}') and not(matches(.,'\p{Pe}'))" role="warning" id="ref-article-title-4">
        <name/> in ref contains an opening bracket - <value-of select="replace(.,'[^\p{Ps}]','')"/> - but it does not contain a closing bracket. Is that correct?</report>
        
        <report test="matches(.,'\p{Pe}') and not(matches(.,'\p{Ps}'))" role="warning" id="ref-article-title-5">
        <name/> in ref contains a closing bracket - <value-of select="replace(.,'[^\p{Pe}]','')"/> - but it does not contain an opening bracket. Is that correct?</report>
      </rule>
  </pattern>
  
  <pattern id="ref-chapter-title-checks-pattern">
    <rule context="ref//chapter-title" id="ref-chapter-title-checks">
        <report test="matches(.,'^\s*[“”&quot;]|[“”&quot;]\.*$')" role="warning" id="ref-chapter-title-1">
        <name/> in ref starts or ends with speech quotes - <value-of select="."/>. Is that correct?.</report>
        
        <report test="matches(.,'\?[^\s\p{P}]')" role="warning" id="ref-chapter-title-2">
        <name/> in ref contains a question mark which may potentially be the result of a processing error - <value-of select="."/>. Should it be repalced with other characters?</report>
        
        <report test="matches(.,'\p{Ps}') and not(matches(.,'\p{Pe}'))" role="warning" id="ref-chapter-title-3">
        <name/> in ref contains an opening bracket - <value-of select="replace(.,'[^\p{Ps}]','')"/> - but it does not contain a closing bracket. Is that correct?</report>
        
        <report test="matches(.,'\p{Pe}') and not(matches(.,'\p{Ps}'))" role="warning" id="ref-chapter-title-4">
        <name/> in ref contains a closing bracket - <value-of select="replace(.,'[^\p{Pe}]','')"/> - but it does not contain an opening bracket. Is that correct?</report>
      </rule>
  </pattern>
  
  <pattern id="ref-source-checks-pattern">
    <rule context="ref//source" id="ref-source-checks">
        <report test="matches(.,'\?[^\s\p{P}]')" role="warning" id="ref-source-1">
        <name/> in ref contains a question mark which may potentially be the result of a processing error - <value-of select="."/>. Should it be repalced with other characters?</report>
        
        <report test="matches(.,'\p{Ps}') and not(matches(.,'\p{Pe}'))" role="warning" id="ref-source-2">
        <name/> in ref contains an opening bracket - <value-of select="replace(.,'[^\p{Ps}]','')"/> - but it does not contain a closing bracket. Is that correct?</report>
        
        <report test="matches(.,'\p{Pe}') and not(matches(.,'\p{Ps}'))" role="warning" id="ref-source-3">
        <name/> in ref contains a closing bracket - <value-of select="replace(.,'[^\p{Pe}]','')"/> - but it does not contain an opening bracket. Is that correct?</report>
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
        
        <report test="parent::ref/label[.!=''] and starts-with(.,parent::ref[1]/label[1])" role="error" id="mixed-citation-label">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) starts with the reference label.</report>
     </rule>
  </pattern>
  <pattern id="mixed-citation-child-checks-pattern">
    <rule context="mixed-citation/*" id="mixed-citation-child-checks">
        <report test="not(*) and (normalize-space(.)='')" role="error" id="mixed-citation-child-1">
        <name/> in reference (id=<value-of select="ancestor::ref/@id"/>) is empty, which cannot be correct.</report>
      </rule>
  </pattern>
  
  <pattern id="comment-checks-pattern">
    <rule context="comment" id="comment-checks">
        <assert test="parent::mixed-citation" role="error" id="comment-1">
        <name/> is only supported within mixed-citation, but this one is in <value-of select="parent::*/name()"/>.</assert>
        
        <assert test="matches(lower-case(.),'^((in|under) (preparation|press|review)|submitted)$')" role="warning" id="comment-2">
        <name/> contains the content '<value-of select="."/>'. Is the tagging correct?</assert>
      </rule>
  </pattern>

    <pattern id="back-tests-pattern">
    <rule context="back" id="back-tests">

       <assert test="ref-list" role="error" id="no-ref-list">This preprint has no reference list (as a child of back), which must be incorrect.</assert>
      </rule>
  </pattern>
  
  <pattern id="ack-tests-pattern">
    <rule context="ack" id="ack-tests">
       <assert test="*[not(name()=('label','title'))]" role="error" id="ack-no-content">Acknowledgements doesn't contain any content. Should it be removed?</assert>
        
        <report test="preceding::ack" role="warning" id="ack-dupe">This ack element follows another one. Should there really be more than one Acknowledgements?</report>
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
       
       
        <report test="not(ancestor::sub-article) and matches(.,'(^|\s)[Ff]ig(\.|ure)?')" role="warning" id="underline-check-1">Content of underline element suggests it's intended to be a figure citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|\s)([Tt]able|[Tt]bl)[\.\s]')" role="warning" id="underline-check-2">Content of underline element suggests it's intended to be a table or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|\s)([Vv]ideo|[Mm]ovie)')" role="warning" id="underline-check-3">Content of underline element suggests it's intended to be a video or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
     </rule>
  </pattern>
  
  <pattern id="bold-checks-pattern">
    <rule context="bold" id="bold-checks">
        <report test="not(ancestor::sub-article) and matches(.,'(^|\s)[Ff]ig(\.|ure)?')" role="warning" id="bold-check-1">Content of bold element suggests it's intended to be a figure citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|\s)([Tt]able|[Tt]bl)[\.\s]')" role="warning" id="bold-check-2">Content of bold element suggests it's intended to be a table or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|\s)([Vv]ideo|[Mm]ovie)')" role="warning" id="bold-check-3">Content of bold element suggests it's intended to be a video or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
      </rule>
  </pattern>
  
  <pattern id="sc-checks-pattern">
    <rule context="sc" id="sc-checks">
        <report test="." role="warning" id="sc-check-1">Content is in small caps - <value-of select="."/> - This formatting is not supported on EPP. Consider removing it or replacing the content with other formatting or (if necessary) different glyphs/characters in order to retain the original meaning.</report>
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
  <pattern id="fig-title-checks-pattern">
    <rule context="fig/caption[p]/title" id="fig-title-checks">
        <report test="matches(lower-case(.),'\.\p{Z}*\p{P}?a(\p{Z}*[\p{Pd},&amp;]\p{Z}*[b-z])?\p{P}?\p{Z}*$')" role="warning" id="fig-title-1">Title for figure ('<value-of select="ancestor::fig/label"/>') potentially ends with a panel label. Should it be moved to the start of the next paragraph? <value-of select="."/>
      </report>
     </rule>
  </pattern>
  <pattern id="fig-caption-checks-pattern">
    <rule context="fig/caption" id="fig-caption-checks">
        <let name="label" value="if (ancestor::fig/label) then ancestor::fig[1]/label[1] else 'unlabelled figure'"/>
        <let name="is-revised-rp" value="if (ancestor::article//article-meta/pub-history/event/self-uri[@content-type='reviewed-preprint']) then true() else false()"/>
        
        <report test="not($is-revised-rp) and matches(lower-case(.),'biorend[eo]r') and not(descendant::ext-link[matches(lower-case(@xlink:href),'biorender.com/[a-z\d]')])" role="warning" id="fig-biorender-check-v1">Caption for <value-of select="$label"/> mentions bioRender, but it does not contain a BioRender figure link in the format "BioRender.com/{figure-code}".</report>
        
        <report test="$is-revised-rp and matches(lower-case(.),'biorend[eo]r') and not(descendant::ext-link[matches(lower-case(@xlink:href),'biorender.com/[a-z\d]')])" role="warning" id="fig-biorender-check-revised">Caption for <value-of select="$label"/> mentions bioRender, but it does not contain a BioRender figure link in the format "BioRender.com/{figure-code}". Since this is a revised RP, check to see if the first (or a previous) version had bioRender links.</report>
        
        <report test="not(title) and (count(p) gt 1)" role="warning" id="fig-caption-1">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple paragraphs. Is the first paragraph actually the title?</report>
        
        <report test="not(title) and (count(p)=1) and (count(tokenize(p[1],'\.\p{Z}')) gt 1) and not(matches(lower-case(p[1]),'^\p{Z}*\p{P}?(a|a[–—\-][b-z]|i)\p{P}'))" role="warning" id="fig-caption-2">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple sentences in the legend. Is the first sentence actually the title?</report>
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
  <pattern id="table-wrap-caption-checks-pattern">
    <rule context="table-wrap/caption" id="table-wrap-caption-checks">
        <let name="label" value="if (ancestor::table-wrap/label) then ancestor::table-wrap[1]/label[1] else 'inline table'"/>
        
        <report test="not(title) and (count(p) gt 1)" role="warning" id="table-wrap-caption-1">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple paragraphs. Is the first paragraph actually the title?</report>
        
        <report test="not(title) and (count(p)=1) and (count(tokenize(p[1],'\.\p{Z}')) gt 1)" role="warning" id="table-wrap-caption-2">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple sentences in the legend. Is the first sentence actually the title?</report>
     </rule>
  </pattern>
  
    <pattern id="supplementary-material-checks-pattern">
    <rule context="supplementary-material" id="supplementary-material-checks">
        <assert test="ancestor::sec[@sec-type='supplementary-material']" role="warning" id="supplementary-material-temp-test">supplementary-material element is not placed within a &lt;sec sec-type="supplementary-material"&gt;. Is that correct?.</assert>
        
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
        
        <report test="not(ancestor::sub-article) and preceding::graphic/@xlink:href/lower-case(.) = $link or preceding::inline-graphic/@xlink:href/lower-case(.) = $link" role="error" id="graphic-test-6">Image file for <value-of select="if (parent::fig/label) then parent::fig/label else 'graphic'"/> (<value-of select="@xlink:href"/>) is the same as the one used for another graphic or inline-graphic.</report>
        
        <report test="ancestor::sub-article and preceding::graphic/@xlink:href/lower-case(.) = $link or preceding::inline-graphic/@xlink:href/lower-case(.) = $link" role="warning" id="graphic-test-9">Image file in sub-article for <value-of select="if (parent::fig/label) then parent::fig/label else 'graphic'"/> (<value-of select="@xlink:href"/>) is the same as the one used for another graphic or inline-graphic. Is that correct?</report>
        
        <report test="@mime-subtype='gif' and $file!='gif'" role="error" id="graphic-test-7">
        <name/> has gif mime-subtype but filename does not end with '.gif'. This cannot be correct.</report>
     </rule>
  </pattern>
  <pattern id="graphic-placement-pattern">
    <rule context="graphic" id="graphic-placement">
         <assert test="parent::fig or parent::table-wrap or parent::disp-formula or parent::alternatives[parent::table-wrap or parent::disp-formula]" role="error" id="graphic-test-8">
        <name/> can only be placed as a child of fig, table-wrap, disp-formula or alternatives (alternatives must in turn must be a child of either table-wrap or disp-formula). This one is a child of <value-of select="parent::*/name()"/>
      </assert>
       </rule>
  </pattern>
  <pattern id="inline-checks-pattern">
    <rule context="inline-graphic" id="inline-checks">
         <assert test="parent::inline-formula or parent::alternatives[parent::inline-formula] or ancestor::caption[parent::fig or parent::table-wrap]" role="warning" id="inline-graphic-test-1">
        <name/> is usually placed either in inline-formula (or alternatives which in turn is a child of inline-formula), or in the caption for a figure or table. This one is not (its a child of <value-of select="parent::*/name()"/>). Is that OK?</assert>
       </rule>
  </pattern>
  
      <pattern id="media-checks-pattern">
    <rule context="media" id="media-checks">
        <let name="link" value="@xlink:href"/>
      
      <assert test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,15}$')" role="error" id="media-test-3">media must have an @xlink:href which contains a file reference.</assert>
        
      <report test="preceding::media/@xlink:href = $link" role="error" id="media-test-10">Media file for <value-of select="if (parent::*/label) then parent::*/label else 'media'"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="if (preceding::media[@xlink:href=$link][1]/parent::*/label) then preceding::media[@xlink:href=$link][1]/parent::*/label         else 'another file'"/>.</report>
        
      <report test="text()" role="error" id="media-test-12">Media element cannot contain text. This one has <value-of select="string-join(text(),'')"/>.</report>
        
      <report test="*" role="error" id="media-test-13">Media element cannot contain child elements. This one has the following element(s) <value-of select="string-join(*/name(),'; ')"/>.</report>
        
      <assert test="parent::supplementary-material" role="error" id="media-test-1">media element should only be placed as a child of supplementary-material. This one has the parent <value-of select="parent::*/name()"/>
      </assert>
     </rule>
  </pattern>
  
    <pattern id="sec-checks-pattern">
    <rule context="sec" id="sec-checks">

        <report test="@sec-type='supplementary-material' and *[not(name()=('label','title','supplementary-material'))]" role="warning" id="sec-supplementary-material">&lt;sec sec-type='supplementary-material'&gt; contains elements other than supplementary-material: <value-of select="string-join(*[not(name()=('label','title','supplementary-material'))]/name(),'; ')"/>. These will currently be stripped from the content rendered on EPP. Should they be moved out of the section or is that OK?'</report>
        
        <report test="@sec-type='supplementary-material' and not(supplementary-material)" role="error" id="sec-supplementary-material-2">&lt;sec sec-type="supplementary-material"&gt; must contain at least one &lt;supplementary-material&gt; element, but this one does not. If this section contains captions, then these should be added to the appropriate &lt;supplementary-material&gt;. If the files are not present in the article at all, the captions should be removed (or the files added as new &lt;supplementary-material&gt;).</report>
        
        <report test="not(@sec-type=('additional-information','supplementary-material')) and not(descendant::supplementary-material or descendant::fig or descendant::table-wrap) and title[1][matches(lower-case(.),'(supporting|supplementary|supplemental|ancillary|additional) (information|files|material)')]" role="warning" id="sec-supplementary-material-3">sec has a title suggesting its content might relate to additional files, but it doesn't contain a supplementary-material element. If this section contains captions for supplementary files, then these should be added to the appropriate &lt;supplementary-material&gt;. If the files are not present in the article at all, the captions should be removed (or the files added as new &lt;supplementary-material&gt;).</report>

        <assert test="*[not(name()=('label','title','sec-meta'))]" role="error" id="sec-empty">sec element is not populated with any content. Either there's a mistake or the section should be removed.</assert>
        
        <report test="@sec-type='data-availability' and (preceding::sec[@sec-type='data-availability'] or ancestor::sec[@sec-type='data-availability'])" role="warning" id="sec-data-availability">sec has the sec-type 'data-availability', but there is one or more other secs with this same sec-type. Are they duplicates?</report>
        
        <report test="title[1][matches(lower-case(.),'(compete?t?ing|conflicts?[\s-]of)[\s-]interest|disclosure|declaration|disclaimer')] and ancestor::article//article-meta/author-notes/fn[@fn-type='coi-statement']" role="warning" id="sec-coi">sec has a title suggesting it's a competing interest statement, but there is also a competing interest statement in author-notes. Are they duplicates? COI statements should be captured within author-notes, so this section should likely be deleted.</report>
        
        <report test="title[1][matches(lower-case(.),'(compete?t?ing|conflicts?[\s-]of)[\s-]interest|disclosure|declaration|disclaimer')] and not(ancestor::article//article-meta/author-notes/fn[@fn-type='coi-statement'])" role="warning" id="sec-coi-2">sec has a title suggesting it's a competing interest statement. COI statements should be captured within author-notes, so this content should be moved into fn with the fn-type="coi-statement" within author-notes.</report>
        
        <report test="@sec-type='ethics-statement' and (preceding::sec[@sec-type='ethics-statement'] or ancestor::sec[@sec-type='ethics-statement'])" role="error" id="sec-ethics">sec has the sec-type 'ethics-statement', but there is one or more other secs with this same sec-type. Are they duplicates? There can only be one section with this sec-type (although it can have subsections with further distinctions that have separate 'ethics-...' sec-types - e.g. "ethics-approval-human", "ethics-approval-animal" etc.)</report>
        
        <report test="def-list and not(*[not(name()=('label','title','sec-meta','def-list'))])" role="error" id="sec-def-list">sec element only contains a child def-list. This is therefore a glossary, not a sec.</report>
        
        <report test="glossary and not(*[not(name()=('label','title','sec-meta','glossary'))])" role="warning" id="sec-glossary">sec element only contains a child glossary. Is it a redundant sec (which should be deleted)? Or perhaps it indicates the structure/hierarchy has been incorrectly captured.</report>
     </rule>
  </pattern>
  <pattern id="top-sec-checks-pattern">
    <rule context="sec[(parent::body or parent::back) and title]" id="top-sec-checks">
        <let name="top-sec-phrases" value="('(results?|conclusions?)( (and|&amp;) discussion)?',             'discussion( (and|&amp;) (results?|conclusions?))?')"/>
        <let name="methods-phrases" value="('(materials? (and|&amp;)|experimental)?\s?methods?( details?|summary|(and|&amp;) materials?)?',             '(supplement(al|ary)? )?materials( (and|&amp;) correspondence)?',             '(model|methods?)(( and| &amp;) (results|materials?))?')"/>
        <let name="methods-regex" value="concat('^(',string-join($methods-phrases,'|'),')$')"/>
        <let name="sec-regex" value="concat('^(',string-join(($top-sec-phrases,$methods-phrases),'|'),')$')"/>
               
        <report test="parent::body and not(matches(lower-case(title[1]),$sec-regex)) and preceding-sibling::sec/title[1][matches(lower-case(.),$methods-regex)]" role="warning" id="top-sec-1">Section with the title '<value-of select="title[1]"/>' is a child of body. Should it be a child of another section (e.g. methods) or placed within back (perhaps within an 'Additional infomation' section)?</report>
        
        <report test="matches(label[1],'\d+\.\s?\d')" role="warning" id="top-sec-2">Section that is placed as a child of <value-of select="parent::*/name()"/> has a label which suggests it should be a subsection: <value-of select="label[1]"/>.</report>
      </rule>
  </pattern>
  <pattern id="sec-label-checks-pattern">
    <rule context="sec/label" id="sec-label-checks">
        <report test="matches(.,'[2-4]D')" role="warning" id="sec-label-1">Label for section contains 2D or similar - '<value-of select="."/>'. Is it really a label? Or just part of the title?</report>
        
        <report test="normalize-space(.)=''" role="error" id="sec-label-2">Section label is empty. This is not permitted.</report>
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
  <pattern id="p-ref-checks-pattern">
    <rule context="p[not(ancestor::sub-article)]" id="p-ref-checks">
        <let name="text" value="string-join(for $x in self::*/(*|text())                                             return if ($x/local-name()='xref') then ()                                                    else string($x),'')"/>
        <let name="missing-ref-regex" value="'[A-Z][A-Za-z]+ et al\.?\p{P}?\s*\p{Ps}?([1][7-9][0-9][0-9]|[2][0-2][0-9][0-9])'"/>
        
        <report test="matches($text,$missing-ref-regex)" role="warning" id="missing-ref-in-text-test">
        <name/> element contains possible citation which is unlinked or a missing reference - search - <value-of select="concat(tokenize(substring-before($text,' et al'),' ')[last()],' et al ',tokenize(substring-after($text,' et al'),' ')[2])"/>
      </report>
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

        <assert test="count(contrib-group)=(1,2)" role="error" id="article-contrib-group">article-meta must contain either one or two &lt;contrib-group&gt; elements. This one contains <value-of select="count(contrib-group)"/>.</assert>
        
        <assert test="(descendant::contrib[@contrib-type='author' and email]) or (descendant::contrib[@contrib-type='author']/xref[@ref-type='corresp']/@rid=./author-notes/corresp/@id)" role="error" id="article-no-emails">This preprint has no emails for corresponding authors, which must be incorrect.</assert>
        
        <assert test="$corresp-author-count=$distinct-email-count" role="warning" id="article-email-corresp-author-count-equivalence">The number of corresponding authors (<value-of select="$corresp-author-count"/>: <value-of select="string-join($corresp-authors,'; ')"/>) is not equal to the number of distinct email addresses (<value-of select="$distinct-email-count"/>: <value-of select="string-join($distinct-emails,'; ')"/>). Is this correct?</assert>

        <report test="$corresp-author-count=$distinct-email-count and author-notes/corresp" role="warning" id="article-corresp">The number of corresponding authors and distinct emails is the same, but a match between them has been unable to be made. As its stands the corresp will display on EPP: <value-of select="author-notes/corresp"/>.</report>

        <report test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='publisher-id'])=1)" role="error" id="article-id-1">Reviewed preprints must have one (and only one) publisher-id. This one has <value-of select="count(article-id[@pub-id-type='publisher-id'])"/>.</report>
      
        <report test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='doi'])=2)" role="error" id="article-id-2">Reviewed preprints must have two DOIs. This one has <value-of select="count(article-id[@pub-id-type='doi'])"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(volume)=1)" role="error" id="volume-presence">Reviewed preprints must have (and only one) volume. This one has <value-of select="count(volume)"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(elocation-id)=1)" role="error" id="elocation-id-presence">Reviewed preprints must have (and only one) elocation-id. This one has <value-of select="count(elocation-id)"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(history)=1)" role="error" id="history-presence">Reviewed preprints must have (and only one) history. This one has <value-of select="count(history)"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(pub-history)=1)" role="error" id="pub-history-presence">Reviewed preprints must have (and only one) pub-history. This one has <value-of select="count(pub-history)"/>.</report>
      </rule>
  </pattern>
  <pattern id="general-article-id-checks-pattern">
    <rule context="article/front/article-meta/article-id" id="general-article-id-checks">
            <assert test="@pub-id-type=('publisher-id','doi')" role="error" id="article-id-3">article-id must have a pub-id-type with a value of 'publisher-id' or 'doi'. This one has <value-of select="if (@publisher-id) then @publisher-id else 'no publisher-id attribute'"/>.</assert>
         </rule>
  </pattern>
  <pattern id="publisher-article-id-checks-pattern">
    <rule context="article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='publisher-id']" id="publisher-article-id-checks">
        <assert test="matches(.,'^1?\d{5}$')" role="error" id="publisher-id-1">article-id with the attribute pub-id-type="publisher-id" must contain the 5 or 6 digit manuscript tracking number. This one contains <value-of select="."/>.</assert>
      </rule>
  </pattern>
  <pattern id="article-dois-pattern">
    <rule context="article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='doi']" id="article-dois">
      <let name="article-id" value="parent::article-meta[1]/article-id[@pub-id-type='publisher-id'][1]"/>
      <let name="latest-rp-doi" value="parent::article-meta/pub-history/event[position()=last()]/self-uri[@content-type='reviewed-preprint']/@xlink:href"/>
      <let name="latest-rp-doi-version" value="if ($latest-rp-doi) then replace($latest-rp-doi,'^.*\.','')                                                else '0'"/>
      
      <assert test="starts-with(.,'10.7554/eLife.')" role="error" id="prc-article-dois-1">Article level DOI must start with '10.7554/eLife.'. Currently it is <value-of select="."/>
      </assert>
      
      <report test="not(@specific-use) and substring-after(.,'10.7554/eLife.') != $article-id" role="error" id="prc-article-dois-2">Article level concept DOI must be a concatenation of '10.7554/eLife.' and the article-id. Currently it is <value-of select="."/>
      </report>
      
      <report test="@specific-use and not(contains(.,$article-id))" role="error" id="prc-article-dois-3">Article level specific version DOI must contain the article-id (<value-of select="$article-id"/>). Currently it does not <value-of select="."/>
      </report>
      
      <report test="@specific-use and not(matches(.,'^10.7554/eLife\.\d{5,6}\.\d$'))" role="error" id="prc-article-dois-4">Article level specific version DOI must be in the format 10.7554/eLife.00000.0. Currently it is <value-of select="."/>
      </report>
      
      <report test="not(@specific-use) and (preceding-sibling::article-id[@pub-id-type='doi'] or following-sibling::article-id[@pub-id-type='doi' and not(@specific-use)])" role="error" id="prc-article-dois-5">Article level concept DOI must be first in article-meta, and there can only be one. This concept DOI has a preceding DOI or following concept DOI.</report>
      
      <report test="@specific-use and (following-sibling::article-id[@pub-id-type='doi'] or preceding-sibling::article-id[@pub-id-type='doi' and @specific-use])" role="error" id="prc-article-dois-6">Article level version DOI must be second in article-meta. This version DOI has a following sibling DOI or a preceding version specific DOI.</report>
      
      <report test="@specific-use and @specific-use!='version'" role="error" id="prc-article-dois-7">Article DOI has a specific-use attribute value <value-of select="@specific-use"/>. The only permitted value is 'version'.</report>
      
      <report test="@specific-use and number(substring-after(.,concat($article-id,'.'))) != (number($latest-rp-doi-version)+1)" role="error" id="final-prc-article-dois-8">The version DOI for this Reviewed preprint version needs to end with a number that is one more than whatever number the last published reviewed preprint version DOI ends with. This version DOI ends with <value-of select="substring-after(.,concat($article-id,'.'))"/> (<value-of select="."/>), whereas <value-of select="if ($latest-rp-doi-version='0') then 'there is no previous reviewed preprint version in the pub-history' else concat('the latest reviewed preprint DOI in the publication history ends with ',$latest-rp-doi-version,' (',$latest-rp-doi,')')"/>. Either there is a missing reviewed preprint publication event in the publication history, or the version DOI is incorrect.</report>
      
      </rule>
  </pattern>
  <pattern id="author-notes-checks-pattern">
    <rule context="article/front/article-meta/author-notes" id="author-notes-checks">
        <report test="count(corresp) gt 1" role="error" id="multiple-corresp">author-notes contains <value-of select="count(corresp)"/> corresp elements. There should only be one. Either these can be collated into one corresp or one of these is a footnote which has been incorrectly captured.</report>
     </rule>
  </pattern>
  <pattern id="author-notes-fn-checks-pattern">
    <rule context="article/front/article-meta/author-notes/fn" id="author-notes-fn-checks">
        <let name="id" value="@id"/>
        <let name="known-types" value="('abbr','con','coi-statement','deceased','equal','financial-disclosure','presented-at','present-address','supported-by')"/>
        <report test="@fn-type='present-address' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)" role="error" id="author-fn-1">Present address type footnote (id=<value-of select="$id"/>) in author-notes is not linked to from any specific author, which must be a mistake. "<value-of select="."/>"</report>
        
        <report test="@fn-type='equal' and (count(ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id]) lt 2)" role="error" id="author-fn-2">Equal author type footnote (id=<value-of select="$id"/>) in author-notes is linked to from <value-of select="count(ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id])"/> author(s), which must be a mistake. "<value-of select="."/>"</report>
        
        <report test="@fn-type='deceased' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)" role="error" id="author-fn-3">Deceased type footnote (id=<value-of select="$id"/>) in author-notes is not linked to from any specific author, which must be a mistake. "<value-of select="."/>"</report>
        
        <report test="@fn-type=('abbr','con','coi-statement','financial-disclosure','presented-at','supported-by') and (ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)" role="warning" id="author-fn-4">
        <value-of select="@fn-type"/> type footnote (id=<value-of select="$id"/>) in author-notes usually contains content that relates to all authors instead of a subset. This one however is linked to from <value-of select="ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id]"/> author(s) (<value-of select="string-join(for $x in ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id] return e:get-name($x/name[1]),'; ')"/>). "<value-of select="."/>"</report>
        
        <report test="@fn-type and not(@fn-type=$known-types)" role="warning" id="author-fn-5">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>' which is not one of the known values (<value-of select="string-join($known-types,'; ')"/>). Should it be changed to be one of the values? "<value-of select="."/>"</report>
        
        <report test="@fn-type=('abbr','con','coi-statement','financial-disclosure','presented-at','supported-by') and @fn-type = preceding-sibling::fn/@fn-type" role="warning" id="author-fn-6">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>', but there's another footnote with that same type. Are two separate notes necessary? Are they duplicates?</report>
        
        <report test="@fn-type='coi-statement' and preceding-sibling::fn[@fn-type='financial-disclosure']" role="warning" id="author-fn-7">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>', but there's another footnote with the type 'financial-disclosure'. Are two separate notes necessary? Are they duplicates?</report>
        
        <report test="@fn-type='financial-disclosure' and preceding-sibling::fn[@fn-type='coi-statement']" role="warning" id="author-fn-8">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>', but there's another footnote with the type 'coi-statement'. Are two separate notes necessary? Are they duplicates?</report>
        
        <report test="label[matches(.,'[\d\p{L}]')]" role="warning" id="author-fn-9">footnote with id <value-of select="$id"/> has a label that contains a letter or number '<value-of select="label[1]"/>'. If they are part of a sequence that also includes affiliation labels this will look odd on EPP (as affiliation labels are not rendered). Should they be replaced with symbols? eLife's style is to follow this sequence: *, †, ‡, §, ¶, **, ††, ‡‡, §§, ¶¶, etc.</report>
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
  <pattern id="rp-and-preprint-version-checks-pattern">
    <rule context="article/front[journal-meta/journal-id='elife']/article-meta[matches(replace(article-id[@specific-use='version'][1],'^.*\.',''),'^\d\d?$') and matches(descendant::article-version[@article-version-type='preprint-version'][1],'^1\.\d+$')]" id="rp-and-preprint-version-checks">
        <let name="preprint-version" value="number(substring-after(descendant::article-version[@article-version-type='preprint-version'][1],'.'))"/>
        <let name="rp-version" value="number(replace(article-id[@specific-use='version'][1],'^.*\.',''))"/>
        
        <assert test="$rp-version le $preprint-version" role="error" id="article-version-12">This is Reviewed Preprint version <value-of select="$rp-version"/>, but according to the article-version, it's based on preprint version <value-of select="$preprint-version"/>. This cannot be correct.</assert>
      </rule>
  </pattern>
  <pattern id="preprint-pub-checks-pattern">
    <rule context="article/front/article-meta/pub-date[@pub-type='epub']/year" id="preprint-pub-checks">
        <assert test=".=('2024','2025')" role="warning" id="preprint-pub-date-1">This preprint version was posted in <value-of select="."/>. Is it the correct version that corresponds to the version submitted to eLife?</assert>
      </rule>
  </pattern>
  <pattern id="contrib-checks-pattern">
    <rule context="article/front/article-meta/contrib-group/contrib" id="contrib-checks">
        <report test="parent::contrib-group[not(preceding-sibling::contrib-group)] and @contrib-type!='author'" role="error" id="contrib-1">Contrib with the type '<value-of select="@contrib-type"/>' is present in author contrib-group (the first contrib-group within article-meta). This is not correct.</report>

        <report test="parent::contrib-group[not(preceding-sibling::contrib-group)] and not(@contrib-type)" role="error" id="contrib-2">Contrib without the attribute contrib-type="author" is present in author contrib-group (the first contrib-group within article-meta). This is not correct.</report>

        <report test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type)" role="error" id="contrib-3">The second contrib-group in article-meta should (only) contain Reviewing and Senior Editors. This contrib is placed in that group, but it does not have a contrib-type. Add the correct contrib-type for the Editor.</report>

        <report test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type=('editor','senior_editor'))" role="error" id="contrib-4">The second contrib-group in article-meta should (only) contain Reviewing and Senior Editors. This contrib is placed in that group, but it has the contrib-type <value-of select="@contrib-type"/>.</report>
      </rule>
  </pattern>
  <pattern id="volume-test-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/volume" id="volume-test">
        <let name="is-first-version" value="if (ancestor::article-meta/article-id[@specific-use='version' and ends-with(.,'.1')]) then true()                                           else if (not(ancestor::article-meta/pub-history[event[date[@date-type='reviewed-preprint']]])) then true()                                           else false()"/>
        <let name="pub-date" value=" if (not($is-first-version)) then parent::article-meta/pub-history[1]/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]          else if (ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic']) then ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic'][1]/year[1]          else string(year-from-date(current-date()))"/>
      
        <report test=".='' or (. != (number($pub-date) - 2011))" role="error" id="volume-test-1">volume is incorrect. It should be <value-of select="number($pub-date) - 2011"/>.</report>
      </rule>
  </pattern>
  <pattern id="elocation-id-test-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/elocation-id" id="elocation-id-test">
        <let name="msid" value="parent::article-meta/article-id[@pub-id-type='publisher-id']"/>
        
        <assert test="matches(.,'^RP\d{5,6}$')" role="error" id="elocation-id-test-1">The content of elocation-id must 'RP' followed by a 5 or 6 digit MSID. This is not in that format: <value-of select="."/>.</assert>
        
        <report test="$msid and not(.=concat('RP',$msid))" role="error" id="elocation-id-test-2">The content of elocation-id must 'RP' followed by the 5 or 6 digit MSID (<value-of select="$msid"/>). This is not in that format (<value-of select="."/> != <value-of select="concat('RP',$msid)"/>).</report>
      </rule>
  </pattern>
  <pattern id="history-tests-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/history" id="history-tests">
      
        <assert test="count(date[@date-type='sent-for-review']) = 1" role="error" id="prc-history-date-test-1">history must contain one (and only one) date[@date-type='sent-for-review'] in Reviewed preprints.</assert>
      
        <report test="date[@date-type!='sent-for-review' or not(@date-type)]" role="error" id="prc-history-date-test-2">Reviewed preprints can only have sent-for-review dates in their history. This one has a <value-of select="if (date[@date-type!='sent-for-review']) then date[@date-type!='sent-for-review']/@date-type else 'undefined'"/> date.</report>
      
    </rule>
  </pattern>
  <pattern id="pub-history-tests-pattern">
    <rule context="article[front[journal-meta/lower-case(journal-id[1])='elife']]//pub-history" id="pub-history-tests">
        <let name="version-from-doi" value="replace(ancestor::article-meta[1]/article-id[@pub-id-type='doi' and @specific-use='version'][1],'^.*\.','')"/>
        <let name="is-revised-rp" value="if ($version-from-doi=('','1')) then false() else true()"/>
      
      <assert test="parent::article-meta" role="error" id="pub-history-parent">
        <name/> is only allowed to be captured as a child of article-meta. This one is a child of <value-of select="parent::*/name()"/>.</assert>
      
      <assert test="count(event) ge 1" role="error" id="pub-history-events-1">
        <name/> in Reviewed Preprints must have at least one event element. This one has <value-of select="count(event)"/> event elements.</assert>
      
      <report test="count(event[self-uri[@content-type='preprint']]) != 1" role="error" id="pub-history-events-2">
        <name/> must contain one, and only one preprint event (an event with a self-uri[@content-type='preprint'] element). This one has <value-of select="count(event[self-uri[@content-type='preprint']])"/> preprint event elements.</report>
      
      <report test="$is-revised-rp and (count(event[self-uri[@content-type='reviewed-preprint']]) != (number($version-from-doi) - 1))" role="error" id="pub-history-events-3">The <name/> for revised reviewed preprints must have one event (with a self-uri[@content-type='reviewed-preprint'] element) element for each of the previous reviewed preprint versions. There are <value-of select="count(event[self-uri[@content-type='reviewed-preprint']])"/> reviewed preprint publication events in pub-history,. but since this is reviewed preprint version <value-of select="$version-from-doi"/> there should be <value-of select="number($version-from-doi) - 1"/>.</report>
      
      <report test="count(event[self-uri[@content-type='reviewed-preprint']]) gt 3" role="warning" id="pub-history-events-4">
        <name/> has <value-of select="count(event[self-uri[@content-type='reviewed-preprint']])"/> reviewed preprint event elements, which is unusual. Is this correct?</report>
    </rule>
  </pattern>
  <pattern id="event-tests-pattern">
    <rule context="event" id="event-tests">
      <let name="date" value="date[1]/@iso-8601-date"/>
      
      <assert test="event-desc" role="error" id="event-test-1">
        <name/> must contain an event-desc element. This one does not.</assert>
      
      <assert test="date[@date-type=('preprint','reviewed-preprint')]" role="error" id="event-test-2">
        <name/> must contain a date element with the attribute date-type="preprint" or date-type="reviewed-preprint". This one does not.</assert>
      
      <assert test="self-uri" role="error" id="event-test-3">
        <name/> must contain a self-uri element. This one does not.</assert>
        
        <report test="following-sibling::event[date[@iso-8601-date lt $date]]" role="error" id="event-test-4">Events in pub-history must be ordered chronologically in descending order. This event has a date (<value-of select="$date"/>) which is later than the date of a following event (<value-of select="preceding-sibling::event[date[@iso-8601-date lt $date]][1]"/>).</report>
      
      <report test="date and self-uri and date[1]/@date-type != self-uri[1]/@content-type" role="error" id="event-test-5">This event in pub-history has a date with the date-type <value-of select="date[1]/@date-type"/>, but a self-uri with the content-type <value-of select="self-uri[1]/@content-type"/>. These values should be the same, so one (or both of them) are incorrect.</report>
    </rule>
  </pattern>
  <pattern id="event-child-tests-pattern">
    <rule context="event/*" id="event-child-tests">
      <let name="allowed-elems" value="('event-desc','date','self-uri')"/>
      
      <assert test="name()=$allowed-elems" role="error" id="event-child">
        <name/> is not allowed in an event element. The only permitted children of event are <value-of select="string-join($allowed-elems,', ')"/>.</assert>
    </rule>
  </pattern>
  <pattern id="rp-event-tests-pattern">
    <rule context="event[date[@date-type='reviewed-preprint']/@iso-8601-date != '']" id="rp-event-tests">
      <let name="rp-link" value="self-uri[@content-type='reviewed-preprint']/@xlink:href"/>
      <let name="rp-version" value="replace($rp-link,'^.*\.','')"/>
      <let name="rp-pub-date" value="date[@date-type='reviewed-preprint']/@iso-8601-date"/>
      <let name="sent-for-review-date" value="ancestor::article-meta/history/date[@date-type='sent-for-review']/@iso-8601-date"/>
      <let name="preprint-pub-date" value="parent::pub-history/event/date[@date-type='preprint']/@iso-8601-date"/>
      <let name="later-rp-events" value="parent::pub-history/event[date[@date-type='reviewed-preprint'] and replace(self-uri[@content-type='reviewed-preprint'][1]/@xlink:href,'^.*\.','') gt $rp-version]"/>
      
      <report test="($preprint-pub-date and $preprint-pub-date != '') and         $preprint-pub-date ge $rp-pub-date" role="error" id="rp-event-test-1">Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than the preprint posted date (<value-of select="$preprint-pub-date"/>), which must be incorrect.</report>
      
      <report test="($sent-for-review-date and $sent-for-review-date != '') and         $sent-for-review-date ge $rp-pub-date" role="error" id="rp-event-test-2">Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than the sent for review date (<value-of select="$sent-for-review-date"/>), which must be incorrect.</report>
      
      <report test="$later-rp-events/date/@iso-8601-date = $rp-pub-date" role="error" id="rp-event-test-3">Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than publication date for a later reviewed preprint version date (<value-of select="$later-rp-events/date/@iso-8601-date[. = $rp-pub-date]"/> for version(s) <value-of select="$later-rp-events/self-uri[@content-type='reviewed-preprint'][1]/@xlink:href/replace(.,'^.*\.','')"/>). This must be incorrect.</report>
        
      <assert test="self-uri[@content-type='editor-report']" role="error" id="rp-event-test-4">The event-desc for Reviewed preprint publication events must have a &lt;self-uri content-type="editor-report"&gt; (which has a DOI link to the eLife Assessment for that version).</assert>
        
     <assert test="self-uri[@content-type='referee-report']" role="error" id="rp-event-test-5">The event-desc for Reviewed preprint publication events must have at least one &lt;self-uri content-type="referee-report"&gt; (which has a DOI link to a public review for that version).</assert>
    </rule>
  </pattern>
  <pattern id="event-desc-tests-pattern">
    <rule context="event-desc" id="event-desc-tests">
      
      <report test="parent::event/self-uri[1][@content-type='preprint'] and .!='Preprint posted'" role="error" id="event-desc-content">
        <name/> that's a child of a preprint event must contain the text 'Preprint posted'. This one does not (<value-of select="."/>).</report>
      
      <report test="parent::event/self-uri[1][@content-type='reviewed-preprint'] and .!=concat('Reviewed preprint v',replace(parent::event[1]/self-uri[1][@content-type='reviewed-preprint']/@xlink:href,'^.*\.',''))" role="error" id="event-desc-content-2">
        <name/> that's a child of a Reviewed preprint event must contain the text 'Reviewed preprint v' followwd by the verison number for that Reviewed preprint version. This one does not (<value-of select="."/> != <value-of select="concat('Reviewed preprint v',replace(parent::event[1]/self-uri[1][@content-type='reviewed-preprint']/@xlink:href,'^.*\.',''))"/>).</report>
      
      <report test="*" role="error" id="event-desc-elems">
        <name/> cannot contain elements. This one has the following: <value-of select="string-join(distinct-values(*/name()),', ')"/>.</report>
      
    </rule>
  </pattern>
  <pattern id="event-date-tests-pattern">
    <rule context="event/date" id="event-date-tests">
      
      <assert test="day and month and year" role="error" id="event-date-child">
        <name/> in event must have a day, month and year element. This one does not.</assert>
      
      <assert test="@date-type=('preprint','reviewed-preprint')" role="error" id="event-date-type">
        <name/> in event must have a date-type attribute with the value 'preprint' or 'reviewed-preprint'.</assert>
    </rule>
  </pattern>
  <pattern id="event-self-uri-tests-pattern">
    <rule context="event/self-uri" id="event-self-uri-tests">
      <let name="article-id" value="ancestor::article-meta/article-id[@pub-id-type='publisher-id']"/>
      
      <assert test="@content-type=('preprint','reviewed-preprint','editor-report','referee-report','author-comment')" role="error" id="event-self-uri-content-type">
        <name/> in event must have the attribute content-type="preprint" or content-type="reviewed-preprint". This one does not.</assert>
      
      <report test="@content-type=('preprint','reviewed-preprint') and (* or normalize-space(.)!='')" role="error" id="event-self-uri-content-1">
        <name/> with the content-type <value-of select="@content-type"/> must not have any child elements or text. This one does.</report>
        
      <report test="@content-type='editor-report' and (* or not(matches(.,'^eLife [Aa]ssessment$')))" role="error" id="event-self-uri-content-2">
        <name/> with the content-type <value-of select="@content-type"/> must not have any child elements, and contain the text 'eLife Assessment'. This one does not.</report>
        
      <report test="@content-type='referee-report' and (* or .='')" role="error" id="event-self-uri-content-3">
        <name/> with the content-type <value-of select="@content-type"/> must not have any child elements, and contain the title of the public review as text. This self-uri either has child elements or it is empty.</report>
        
      <report test="@content-type='author-comment' and (* or not(matches(.,'^Author [Rr]esponse:?\s?$')))" role="error" id="event-self-uri-content-4">
        <name/> with the content-type <value-of select="@content-type"/> must not have any child elements, and contain the title of the text 'Author response'. This one does not.</report>
      
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;&lt;&gt;//=]*)$')" role="error" id="event-self-uri-href-1">
        <name/> in event must have an xlink:href attribute containing a link to the preprint. This one does not have a valid URI - <value-of select="@xlink:href"/>.</assert>
      
      <report test="matches(lower-case(@xlink:href),'(bio|med)rxiv')" role="error" id="event-self-uri-href-2">
        <name/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. bioRxiv and medRxiv preprint have dois, and this one points to one of those, but it is not a doi - <value-of select="@xlink:href"/>.</report>
      
      <assert test="matches(@xlink:href,'https?://(dx.doi.org|doi.org)/')" role="warning" id="event-self-uri-href-3">
        <name/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. This one is not a doi - <value-of select="@xlink:href"/>. Please check whether there is a doi that can be used instead.</assert>
      
      <report test="@content-type='reviewed-preprint' and not(matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]$'))" role="error" id="event-self-uri-href-4">
        <name/> in event has the attribute content-type="reviewed-preprint", but the xlink:href attribute does not contain an eLife version specific DOI - <value-of select="@xlink:href"/>.</report>
      
      <report test="(@content-type!='reviewed-preprint' or not(@content-type)) and matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.\d$')" role="error" id="event-self-uri-href-5">
        <name/> in event does not have the attribute content-type="reviewed-preprint", but the xlink:href attribute contains an eLife version specific DOI - <value-of select="@xlink:href"/>. If it's a preprint event, the link should be to a preprint. If it's an event for reviewed preprint publication, then it should have the attribute content-type!='reviewed-preprint'.</report>
      
      <report test="@content-type='reviewed-preprint' and not(contains(@xlink:href,$article-id))" role="error" id="event-self-uri-href-6">
        <name/> in event the attribute content-type="reviewed-preprint", but the xlink:href attribute value (<value-of select="@xlink:href"/>) does not contain the article id (<value-of select="$article-id"/>) which must be incorrect, since this should be the version DOI for the reviewed preprint version.</report>
        
      <report test="@content-type=('editor-report','referee-report','author-comment') and not(matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]\.sa\d+$'))" role="error" id="event-self-uri-href-7">
        <name/> in event has the attribute content-type="<value-of select="@content-type"/>", but the xlink:href attribute does not contain an eLife peer review DOI - <value-of select="@xlink:href"/>.</report>
    </rule>
  </pattern>

    <pattern id="abstract-checks-pattern">
    <rule context="abstract[parent::article-meta]" id="abstract-checks">
        <let name="allowed-types" value="('structured','plain-language-summary','teaser','summary','graphical','video')"/>
        <!-- The only elements you'd expect to be permitted in an impact statement -->
        <let name="impact-statement-elems" value="('title','p','italic','bold','sup','sub','sc','monospace','xref')"/>
        <let name="word-count" value="count(for $x in tokenize(normalize-space(replace(.,'\p{P}','')),' ') return $x)"/>
        <report test="preceding::abstract[not(@abstract-type) and not(@xml:lang)] and not(@abstract-type) and not(@xml:lang)" role="error" id="abstract-test-1">There should only be one abstract without an abstract-type attribute (for the common-garden abstract) or xml:lang attirbute (for common-garden abstract in a language other than english). This asbtract does not have an abstract-type, but there is also a preceding abstract without an abstract-type or xml:lang. One of these needs to be given an abstract-type with the allowed values ('structured' for a syrctured abstract with sections; 'plain-language-summary' for a digest or author provided plain summary; 'teaser' for an impact statement; 'summary' for a general summary that's in addition to the common-garden abstract; 'graphical' for a graphical abstract).</report>

        <report test="@abstract-type and not(@abstract-type=$allowed-types)" role="error" id="abstract-test-2">abstract has an abstract-type (<value-of select="@abstract-type"/>), but it's not one of the permiited values: <value-of select="string-join($allowed-types,'; ')"/>.</report>
        
        <report test="matches(lower-case(title[1]),'funding')" role="error" id="abstract-test-3">abstract has a title that indicates it contains funding information (<value-of select="title[1]"/>) If this is funding information, it should be captured as a section in back or as part of an (if existing) structured abstract.</report>
        
        <report test="matches(lower-case(title[1]),'data')" role="error" id="abstract-test-4">abstract has a title that indicates it contains a data availability statement (<value-of select="title[1]"/>) If this is a data availability statement, it should be captured as a section in back.</report>
        
        <report test="descendant::fig and not(@abstract-type='graphical')" role="error" id="abstract-test-5">abstract has a descendant fig, but it does not have the attribute abstract-type="graphical". If it is a graphical abstract, it should have that type. If it's not a graphical abstract the content should be moved out of &lt;abstract&gt;</report>
        
        <report test="@abstract-type=$allowed-types and ./@abstract-type = preceding-sibling::abstract/@abstract-type" role="warning" id="abstract-test-6">abstract has the abstract-type '<value-of select="@abstract-type"/>', which is a permitted value, but it is not the only abstract with that type. It is very unlikely that two abstracts with the same abstract-type are required.</report>
        
        <report test="@abstract-type='teaser' and descendant::*[not(name()=$impact-statement-elems)]" role="error" id="abstract-test-7">abstract has the abstract-type 'teaser', meaning it is equivalent to an impact statement, but it has the following descendant elements, which prove it needs a different type <value-of select="string-join(distinct-values(descendant::*[not(name()=$impact-statement-elems)]/name()),'; ')"/>.</report>
        
        <report test="@abstract-type='teaser' and $word-count gt 60" role="warning" id="abstract-test-8">abstract has the abstract-type 'teaser', meaning it is equivalent to an impact statement, but it has greater than 60 words (<value-of select="$word-count"/>).</report>
        
        <report test="@abstract-type='teaser' and count(p) gt 1" role="error" id="abstract-test-9">abstract has the abstract-type 'teaser', meaning it is equivalent to an impact statement, but it has <value-of select="count(p)"/> paragraphs (whereas an impact statement would have only one paragraph).</report>
        
        <report test="@abstract-type='video' and not(descendant::*[name()=('ext-link','media','supplementary-file')])" role="error" id="abstract-test-10">abstract has the abstract-type 'video', but it does not have a media, supplementary-material or ext-link element. The abstract-type must be incorrect.</report>
      </rule>
  </pattern>
  <pattern id="abstract-child-checks-pattern">
    <rule context="abstract[parent::article-meta]/*" id="abstract-child-checks">
        <let name="allowed-children" value="('label','title','sec','p','fig','list')"/>
        <assert test="name()=$allowed-children" role="error" id="abstract-child-test-1">
        <name/> is not permitted within abstract.</assert>
      </rule>
  </pattern>
  <pattern id="abstract-lang-checks-pattern">
    <rule context="abstract[@xml:lang]" id="abstract-lang-checks">
        <let name="xml-lang-value" value="@xml:lang"/>
        <let name="languages" value="'languages.xml'"/>
        <let name="subtag-description" value="string-join(document($languages)//*:item[@subtag=$xml-lang-value]/*:description,' / ')"/>
        <assert test="$subtag-description!=''" role="error" id="abstract-lang-test-1">The xml:lang attribute on <name/> must contain one of the IETF RFC 5646 subtags. '<value-of select="@xml:lang"/>' is not one of these values.</assert>
        
        <report test="$subtag-description!=''" role="warning" id="abstract-lang-test-2">
        <name/> has an xml:lang attribute with the value '<value-of select="$xml-lang-value"/>', which corresponds to the following language: <value-of select="$subtag-description"/>. Please check this is correct.</report>
      </rule>
  </pattern>

    <pattern id="front-permissions-tests-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions" id="front-permissions-tests">
	  <let name="author-contrib-group" value="ancestor::article-meta/contrib-group[1]"/>
	  <let name="copyright-holder" value="e:get-copyright-holder($author-contrib-group)"/>
	  <let name="license-type" value="license/@xlink:href"/>
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-4" test="ali:free_to_read" role="error" id="permissions-test-4">permissions must contain an ali:free_to_read element.</assert>
	
	  <assert test="license" role="error" id="permissions-test-5">permissions must contain license.</assert>
	  
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-9" test="$license-type = ('http://creativecommons.org/publicdomain/zero/1.0/', 'https://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by/4.0/')" role="error" id="permissions-test-9">license does not have an @xlink:href which is equal to 'https://creativecommons.org/publicdomain/zero/1.0/' or 'https://creativecommons.org/licenses/by/4.0/'.</assert>
	  
	  <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-info" test="license" role="info" id="permissions-info">This article is licensed under a<value-of select="      if (contains($license-type,'publicdomain/zero')) then ' CC0 1.0'      else if (contains($license-type,'by/4.0')) then ' CC BY 4.0'      else if (contains($license-type,'by/3.0')) then ' CC BY 3.0'      else 'n unknown'"/> license. <value-of select="$license-type"/>
      </report>
	
	</rule>
  </pattern>
  <pattern id="cc-by-permissions-tests-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/licenses/by/')]" id="cc-by-permissions-tests">
      <let name="author-contrib-group" value="ancestor::article-meta/contrib-group[1]"/>
      <let name="copyright-holder" value="e:get-copyright-holder($author-contrib-group)"/>
      <let name="license-type" value="license/@xlink:href"/>
      <let name="is-first-version" value="if (ancestor::article-meta/article-id[@specific-use='version' and ends-with(.,'.1')]) then true()                                           else if (not(ancestor::article-meta/pub-history[event[date[@date-type='reviewed-preprint']]])) then true()                                           else false()"/>
      <!-- dirty - needs doing based on first date rather than just position? -->
      <let name="authoritative-year" value="if (ancestor::article-meta/pub-date[@date-type='original-publication']) then ancestor::article-meta/pub-date[@date-type='original-publication'][1]/year[1]         else if (not($is-first-version)) then ancestor::article-meta/pub-history/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]         else string(year-from-date(current-date()))"/>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-1" test="copyright-statement" role="error" id="permissions-test-1">permissions must contain copyright-statement in CC BY licensed articles.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-2" test="matches(copyright-year[1],'^[0-9]{4}$')" role="error" id="permissions-test-2">permissions must contain copyright-year in the format 0000 in CC BY licensed articles. Currently it is <value-of select="copyright-year"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-3" test="copyright-holder" role="error" id="permissions-test-3">permissions must contain copyright-holder in CC BY licensed articles.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-6" test="copyright-year = $authoritative-year" role="error" id="permissions-test-6">copyright-year must match the year of first reviewed preprint publication date. Currently copyright-year=<value-of select="copyright-year"/> and authoritative pub-date=<value-of select="$authoritative-year"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-7" test="copyright-holder = $copyright-holder" role="error" id="permissions-test-7">copyright-holder is incorrect. If the article has one author then it should be their surname (or collab name). If it has two authors it should be the surname (or collab name) of the first, then ' &amp; ' and then the surname (or collab name) of the second. If three or more, it should be the surname (or collab name) of the first, and then ' et al'. Currently it's '<value-of select="copyright-holder"/>' when based on the author list it should be '<value-of select="$copyright-holder"/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-8" test="copyright-statement = concat('© ',copyright-year,', ',copyright-holder)" role="error" id="permissions-test-8">copyright-statement must contain a concatenation of '© ', copyright-year, and copyright-holder. Currently it is <value-of select="copyright-statement"/> when according to the other values it should be <value-of select="concat('© ',copyright-year,', ',copyright-holder)"/>
      </assert>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#hztjj-permissions-test-16" test="ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')]" role="warning" id="permissions-test-16">This article is CC-BY, but one or more of the authors are affiliated with the NIH (<value-of select="string-join(for $x in ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')] return $x,'; ')"/>). Should it be CC0 instead?</report>
      
      <let name="nih-rors" value="('https://ror.org/01cwqze88','https://ror.org/03jh5a977','https://ror.org/04r5s4b52','https://ror.org/04byxyr05','https://ror.org/02xey9a22','https://ror.org/040gcmg81','https://ror.org/04pw6fb54','https://ror.org/00190t495','https://ror.org/03wkg3b53','https://ror.org/012pb6c26','https://ror.org/00baak391','https://ror.org/043z4tv69','https://ror.org/006zn3t30','https://ror.org/00372qc85','https://ror.org/004a2wv92','https://ror.org/00adh9b73','https://ror.org/00j4k1h63','https://ror.org/04q48ey07','https://ror.org/04xeg9z08','https://ror.org/01s5ya894','https://ror.org/01y3zfr79','https://ror.org/049v75w11','https://ror.org/02jzrsm59','https://ror.org/04mhx6838','https://ror.org/00fq5cm18','https://ror.org/0493hgw16','https://ror.org/04vfsmv21','https://ror.org/00fj8a872','https://ror.org/0060t0j89','https://ror.org/01jdyfj45')"/>
      <report test="ancestor::article-meta/contrib-group[1]/aff[count(descendant::institution-id) = 1 and descendant::institution-id=$nih-rors]" role="warning" id="permissions-test-17">This article is CC-BY, but one or more of the authors are affiliated with the NIH (<value-of select="string-join(for $x in ancestor::article-meta/contrib-group[1]/aff[count(descendant::institution-id) = 1 and descendant::institution-id=$nih-rors] return $x,'; ')"/>). Should it be CC0 instead?</report>
      
    </rule>
  </pattern>
  <pattern id="cc-0-permissions-tests-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/publicdomain/zero')]" id="cc-0-permissions-tests">
      <let name="license-type" value="license/@xlink:href"/>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-1" test="copyright-statement" role="error" id="cc-0-test-1">This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-statement (<value-of select="copyright-statement"/>) which is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-2" test="copyright-year" role="error" id="cc-0-test-2">This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-year (<value-of select="copyright-year"/>) which is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-3" test="copyright-holder" role="error" id="cc-0-test-3">This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-holder (<value-of select="copyright-holder"/>) which is not correct.</report>
      
    </rule>
  </pattern>
  <pattern id="license-tests-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license" id="license-tests">
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-1" test="ali:license_ref" role="error" id="license-test-1">license must contain ali:license_ref.</assert>
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-2" test="count(license-p) = 1" role="error" id="license-test-2">license must contain one and only one license-p.</assert>
	
	</rule>
  </pattern>
  <pattern id="license-p-tests-pattern">
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license/license-p" id="license-p-tests">
      <let name="license-link" value="parent::license/@xlink:href"/>
      <let name="license-type" value="if (contains($license-link,'//creativecommons.org/publicdomain/zero/1.0/')) then 'cc0' else if (contains($license-link,'//creativecommons.org/licenses/by/4.0/')) then 'ccby' else ('unknown')"/>
      
      <let name="cc0-text" value="'This is an open-access article, free of all copyright, and may be freely reproduced, distributed, transmitted, modified, built upon, or otherwise used by anyone for any lawful purpose. The work is made available under the Creative Commons CC0 public domain dedication.'"/>
      <let name="ccby-text" value="'This article is distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use and redistribution provided that the original author and source are credited.'"/>
      
      <report test="($license-type='ccby') and .!=$ccby-text" role="error" id="license-p-test-1">The text in license-p is incorrect (<value-of select="."/>). Since this article is CCBY licensed, the text should be <value-of select="$ccby-text"/>.</report>
      
      <report test="($license-type='cc0') and .!=$cc0-text" role="error" id="license-p-test-2">The text in license-p is incorrect (<value-of select="."/>). Since this article is CC0 licensed, the text should be <value-of select="$cc0-text"/>.</report>
      
    </rule>
  </pattern>
  <pattern id="license-link-tests-pattern">
    <rule context="permissions/license[@xlink:href]/license-p" id="license-link-tests">
      <let name="license-link" value="parent::license/@xlink:href"/>
      
      <assert test="some $x in ext-link satisfies $x/@xlink:href = $license-link" role="error" id="license-p-test-3">If a license element has an xlink:href attribute, there must be a link in license-p that matches the link in the license/@xlink:href attribute. License link: <value-of select="$license-link"/>. Links in the license-p: <value-of select="string-join(ext-link/@xlink:href,'; ')"/>.</assert>
    </rule>
  </pattern>
  <pattern id="license-ali-ref-link-tests-pattern">
    <rule context="permissions/license[ali:license_ref]/license-p" id="license-ali-ref-link-tests">
      <let name="ali-ref" value="parent::license/ali:license_ref"/>
      
      <assert test="some $x in ext-link satisfies $x/@xlink:href = $ali-ref" role="error" id="license-p-test-4">If a license contains an ali:license_ref element, there must be a link in license-p that matches the link in the ali:license_ref element. ali:license_ref link: <value-of select="$ali-ref"/>. Links in the license-p: <value-of select="string-join(ext-link/@xlink:href,'; ')"/>.</assert>
    </rule>
  </pattern>
  <pattern id="fig-permissions-check-pattern">
    <rule context="fig[not(descendant::permissions)]|media[@mimetype='video' and not(descendant::permissions)]|table-wrap[not(descendant::permissions)]|supplementary-material[not(descendant::permissions)]" id="fig-permissions-check">
      <let name="label" value="replace(label[1],'\.','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-1" test="matches(caption[1],'[Rr]eproduced from')" role="warning" id="reproduce-test-1">The caption for <value-of select="$label"/> contains the text 'reproduced from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-2" test="matches(caption[1],'[Rr]eproduced [Ww]ith [Pp]ermission')" role="warning" id="reproduce-test-2">The caption for <value-of select="$label"/> contains the text 'reproduced with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-3" test="matches(caption[1],'[Aa]dapted from|[Aa]dapted with')" role="warning" id="reproduce-test-3">The caption for <value-of select="$label"/> contains the text 'adapted from ...', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-4" test="matches(caption[1],'[Rr]eprinted from')" role="warning" id="reproduce-test-4">The caption for <value-of select="$label"/> contains the text 'reprinted from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-5" test="matches(caption[1],'[Rr]eprinted [Ww]ith [Pp]ermission')" role="warning" id="reproduce-test-5">The caption for <value-of select="$label"/> contains the text 'reprinted with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-6" test="matches(caption[1],'[Mm]odified from')" role="warning" id="reproduce-test-6">The caption for <value-of select="$label"/> contains the text 'modified from', but has no permissions. Is this correct?</report>
      
      <report test="matches(caption[1],'[Mm]odified [Ww]ith')" role="warning" id="reproduce-test-7">The caption for <value-of select="$label"/> contains the text 'modified with', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-8" test="matches(caption[1],'[Uu]sed [Ww]ith [Pp]ermission')" role="warning" id="reproduce-test-8">The caption for <value-of select="$label"/> contains the text 'used with permission', but has no permissions. Is this correct?</report>
    </rule>
  </pattern>
  
  <pattern id="clintrial-related-object-pattern">
    <rule context="related-object[@content-type or @document-id]" id="clintrial-related-object">
      <let name="registries" value="'clinical-trial-registries.xml'"/>
      
      <assert test="@source-type='clinical-trials-registry'" role="error" id="clintrial-related-object-2">
        <name/> must have an @source-type='clinical-trials-registry'.</assert>
      
      <assert test="@source-id!=''" role="error" id="clintrial-related-object-3">
        <name/> must have an @source-id with a non-empty value.</assert>
      
      <assert test="@source-id-type='registry-name'" role="error" id="clintrial-related-object-4">
        <name/> must have an @source-id-type='registry-name'.</assert>
      
      <assert test="@document-id-type='clinical-trial-number'" role="error" id="clintrial-related-object-5">
        <name/> must have an @document-id-type='clinical-trial-number'.</assert>
      
      <assert test="@document-id[not(matches(.,'\p{Zs}'))]" role="error" id="clintrial-related-object-6">
        <name/> must have an @document-id with a value that does not contain a space character.</assert>
      
      <assert test="@xlink:href[not(matches(.,'\p{Zs}'))]" role="error" id="clintrial-related-object-7">
        <name/> must have an @xlink:href with a value that does not contain a space character.</assert>
      
      <assert test="@document-id = ." role="warning" id="clintrial-related-object-8">
        <name/> has an @document-id '<value-of select="@document-id"/>'. But this is not the text of the related-object, which is likely incorrect - <value-of select="."/>.</assert>
      
      <assert test="some $x in document($registries)/registries/registry satisfies ($x/subtitle/string()=@source-id)" role="warning" id="clintrial-related-object-11">
        <name/> @source-id value should almost always be one of the subtitles of the Crossref clinical trial registries. "<value-of select="@source-id"/>" is not one of the following <value-of select="string-join(for $x in document($registries)/registries/registry return concat('&quot;',$x/subtitle/string(),'&quot; (',$x/doi/string(),')'),', ')"/>. Is that correct?</assert>
      
      <report test="@source-id='ClinicalTrials.gov' and not(@xlink:href=(concat('https://clinicaltrials.gov/study/',@document-id),concat('https://clinicaltrials.gov/show/',@document-id)))" role="error" id="clintrial-related-object-12">ClinicalTrials.gov trial links are in the format https://clinicaltrials.gov/show/{number}. This <name/> has the link '<value-of select="@xlink:href"/>', which based on the clinical trial registry (<value-of select="@source-id"/>) and @document-id (<value-of select="@document-id"/>) is not right. Either the xlink:href is wrong (should it be <value-of select="concat('https://clinicaltrials.gov/study/',@document-id)"/> instead?) or the @document-id value is wrong, or the @source-id value is incorrect (or all/some combination of these).</report>

      <report test="ends-with(@xlink:href,'.')" role="error" id="clintrial-related-object-14">
        <name/> has a @xlink:href attribute value which ends with a full stop, which is not correct - '<value-of select="@xlink:href"/>'.</report>
      
      <assert test="@xlink:href!=''" role="error" id="clintrial-related-object-17">
        <name/> must have an @xlink:href attribute with a non-empty value. This one does not.</assert>

      <report test="ends-with(@document-id,'.')" role="error" id="clintrial-related-object-15">
        <name/> has an @document-id attribute value which ends with a full stop, which is not correct - '<value-of select="@document-id"/>'.</report>

      <report test="ends-with(.,'.')" role="error" id="clintrial-related-object-16">Content within <name/> element ends with a full stop, which is not correct - '<value-of select="."/>'.</report>
      
      <assert test="@content-type=('pre-results','results','post-results')" role="error" id="clintrial-related-object-18">
        <name/> must have a content-type attribute with one of the following values: pre-results, results, or post-results.</assert>
      
      <assert test="ancestor::abstract or parent::article-meta" role="error" id="clintrial-related-object-parent-1">
        <name/> element must either be a descendant of abstract or a child or article-meta. This one is not.</assert>
      
      <report test="ancestor::abstract and not(parent::p/parent::sec/parent::abstract)" role="error" id="clintrial-related-object-parent-2">If <name/> is a descendant of abstract, then it must be placed within a p element that is part of a subsection (i.e. it must be within a structured abstract). This one is not.</report>
      
      <report test="ancestor::abstract[sec] and not(parent::p/parent::sec/title[matches(lower-case(.),'clinical trial')])" role="warning" id="clintrial-related-object-parent-3">
        <name/> is a descendant of (a sturctured) abstract, but it's not within a section that has a title indicating it's a clinical trial number. Is that right?</report>
      
    </rule>
  </pattern>
  
  <pattern id="notes-checks-pattern">
    <rule context="front/notes" id="notes-checks">
      <report test="fn-group[not(@content-type='summary-of-updates')] or notes[not(@notes-type='disclosures')]" role="warning" id="notes-check-1">When present, the notes element should only be used to contain an author revision summary (an fn-group with the content-type 'summary-of-updates'). This notes element contains other content. Is it redundant? Or should the content be moved elsewhere? (coi statements should be in author-notes; clinical trial numbers should be included as a related-object in a structured abstract (if it already exists) or as related-object in article-meta; data/code/ethics/funding statements can be included in additional information in new or existing section(s), as appropriate)</report>
      
      <report test="*[not(name()=('fn-group','notes'))]" role="error" id="notes-check-2">When present, the notes element should only be used to contain an author revision summary (an fn-group with the content-type 'summary-of-updates'). This notes element contains the following element(s): <value-of select="string-join(distinct-values(*[not(name()=('fn-group','notes'))]/name()),'; ')"/>). Are these redundant? Or should the content be moved elsewhere? (coi statements should be in author-notes; clinical trial numbers should be included as a related-object in a structured abstract (if it already exists) or as related-object in article-meta; data/code/ethics/funding statements can be included in additional information in new or existing section(s), as appropriate; anstract shpould be captured as abstracts with the appropriate type)</report>
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
  <pattern id="ref-citation-checks-pattern">
    <rule context="xref[@ref-type='bibr']" id="ref-citation-checks">
        <let name="rid" value="@rid"/>
        
        <assert test="ancestor::article//*[@id=$rid]/name()='ref'" role="error" id="ref-cite-target">This reference citation points to a <value-of select="ancestor::article//*[@id=$rid]/name()"/> element. This cannot be right. Either the rid value is wrong or the ref-type is incorrect.</assert>
        
        <report test="((sup[matches(.,'^\d+$')] and .=sup) or (matches(.,'^\d+$') and ancestor::sup)) and preceding::text()[1][matches(lower-case(.),'([×x⋅]\s?[0-9]|10)$')]" role="warning" id="ref-cite-superscript-0">This reference citation contains superscript number(s), but is preceed by a formula. Should the xref be removed and the superscript numbers be retained (as an exponent)?</report>
        
        <!-- match text that ends with an SI unit commonly followed by a superscript number-->
        <report test="((sup[matches(.,'^\d+$')] and .=sup) or (matches(.,'^\d+$') and ancestor::sup)) and preceding::text()[1][matches(lower-case(.),'\d\s*([YZEPTGMkhdacm]?m|mm|cm|km|[µμ]m|nm|pm|fm|am|zm|ym)$')]" role="warning" id="ref-cite-superscript-1">This reference citation contains superscript number(s), but is preceed by an SI unit abbreviation. Should the xref be removed and the superscript numbers be retained?</report>
        
        <!-- incorrect citations for atomic notation -->
        <report test="(.='2' and (sup or ancestor::sup)) and preceding::text()[1][matches(.,'(^|\s)(B[ar]|C[alou]?|Fe?|H[eg]?|I|M[gn]|N[ai]?|O|Pb?|S|Zn)$')]" role="warning" id="ref-cite-superscript-2">This reference citation contains superscript number(s), but is preceed by text that suggests it's part of atomic notation. Should the xref be removed and the superscript numbers be retained?</report>
        
        <report test="(.='3' and (sup or ancestor::sup)) and preceding::text()[1][matches(.,'(^|\s)(As|Bi|NI|O|P|Sb)$')]" role="warning" id="ref-cite-superscript-3">This reference citation contains superscript number(s), but is preceed by text that suggests it's part of atomic notation. Should the xref be removed and the superscript numbers be retained?</report>
     </rule>
  </pattern>

    <pattern id="ext-link-tests-pattern">
    <rule context="ext-link[@ext-link-type='uri']" id="ext-link-tests">
      
      <!-- Needs further testing. Presume that we want to ensure a url follows certain URI schemes. -->
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)\[\]+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')" role="warning" id="url-conformance-test">@xlink:href doesn't look like a URL - '<value-of select="@xlink:href"/>'. Is this correct?</assert>
      
      <report test="matches(@xlink:href,'^(ftp|sftp)://\S+:\S+@')" role="warning" id="ftp-credentials-flag">@xlink:href contains what looks like a link to an FTP site which contains credentials (username and password) - '<value-of select="@xlink:href"/>'. If the link without credentials works (<value-of select="concat(substring-before(@xlink:href,'://'),'://',substring-after(@xlink:href,'@'))"/>), then please replace it with that.</report>
      
      <report test="matches(@xlink:href,'\.$')" role="error" id="url-fullstop-report">'<value-of select="@xlink:href"/>' - Link ends in a full stop which is incorrect.</report>
      
      <report test="matches(@xlink:href,'[\p{Zs}]')" role="error" id="url-space-report">'<value-of select="@xlink:href"/>' - Link contains a space which is incorrect.</report>
      
      <report test="(.!=@xlink:href) and matches(.,'https?:|ftp:')" role="warning" id="ext-link-text">The text for a URL is '<value-of select="."/>' (which looks like a URL), but it is not the same as the actual embedded link, which is '<value-of select="@xlink:href"/>'.</report>

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
      
      <report test="@kwd-group-type='evidence-strength' and count(kwd) = 2" role="warning" id="ed-report-kwd-group-2">
        <value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. Please check this is correct.</report>
        
      <report test="@kwd-group-type='evidence-strength' and count(kwd) gt 2" role="error" id="ed-report-kwd-group-4">
        <value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is incorrect.</report>
      
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
      <let name="str-kwds" value="('exceptional', 'compelling', 'convincing', 'convincingly', 'solid', 'incomplete', 'incompletely', 'inadequate', 'inadequately')"/>
      <let name="sig-kwds" value="('landmark', 'fundamental', 'important', 'valuable', 'useful')"/>
      <let name="allowed-vals" value="($str-kwds,$sig-kwds)"/>
      <let name="normalized-kwd" value="replace(lower-case(.),'ly$','')"/>
      <let name="title-case-kwd" value="concat(upper-case(substring($normalized-kwd,1,1)),lower-case(substring($normalized-kwd,2)))"/>
      
      <assert test="lower-case(.)=$allowed-vals" role="error" id="ed-report-bold-terms-1">Bold phrase in eLife Assessment - <value-of select="."/> - is not one of the permitted terms from the vocabulary. Should the bold formatting be removed? These are currently bolded terms <value-of select="string-join($allowed-vals,', ')"/>
      </assert>

      <report test="lower-case(.)=$allowed-vals and not($title-case-kwd=ancestor::sub-article/front-stub/kwd-group/kwd)" role="error" id="ed-report-bold-terms-2">Bold phrase in eLife Assessment - <value-of select="."/> - is one of the permitted vocabulary terms, but there's no corresponding keyword in the metadata (in a kwd-group in the front-stub).</report>

      <report test="preceding-sibling::bold[replace(lower-case(.),'ly$','') = $normalized-kwd]" role="warning" id="ed-report-bold-terms-3">There is more than one of the same <value-of select="if (replace(lower-case(.),'ly$','')=$str-kwds) then 'strength' else 'significance'"/> keywords in the assessment - <value-of select="$normalized-kwd"/>. This is very likely to be incorrect.</report>
    </rule>
  </pattern>

    <pattern id="ar-image-labels-pattern">
    <rule context="sub-article[@article-type='author-comment']//fig/label" id="ar-image-labels">
        <assert test="matches(.,'^Author response image \d\d?\.$')" role="error" id="ar-image-label-1">Label for figures in the author response must be in the format 'Author response image 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
  </pattern>
  <pattern id="ar-table-labels-pattern">
    <rule context="sub-article[@article-type='author-comment']//table-wrap/label" id="ar-table-labels">
        <assert test="matches(.,'^Author response table \d\d?\.$')" role="error" id="ar-table-label-1">Label for tables in the author response must be in the format 'Author response table 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
  </pattern>
  
    <pattern id="pr-image-labels-pattern">
    <rule context="sub-article[@article-type='referee-report']//fig/label" id="pr-image-labels">
        <assert test="matches(.,'^Review image \d\d?\.$')" role="error" id="pr-image-label-1">Label for figures in public reviews must be in the format 'Review image 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
  </pattern>
  <pattern id="pr-table-labels-pattern">
    <rule context="sub-article[@article-type='referee-report']//table-wrap/label" id="pr-table-labels">
        <assert test="matches(.,'^Review table \d\d?\.$')" role="error" id="pr-table-label-1">Label for tables in public reviews must be in the format 'Review table 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
  </pattern>

    <pattern id="sub-article-title-checks-pattern">
    <rule context="sub-article/front-stub/title-group/article-title" id="sub-article-title-checks">
        <let name="type" value="ancestor::sub-article/@article-type"/>
        
        <report test="$type='editor-report' and not(matches(.,'^eLife [aA]ssessment$'))" role="error" id="sub-article-title-check-1">The title of an <value-of select="$type"/> type sub-article should be 'eLife Assessment'. This one is: <value-of select="."/>
      </report>
        
        <report test="$type='referee-report' and not(matches(.,'^Reviewer #\d\d? \([Pp]ublic [Rr]eview\):?$|^Joint [Pp]ublic [Rr]eview:?$'))" role="error" id="sub-article-title-check-2">The title of a <value-of select="$type"/> type sub-article should be in one of the following formats: 'Reviewer #0 (public review)' or 'Joint public review'. This one is: <value-of select="."/>
      </report>
        
        <report test="$type='author-comment' and not(matches(.,'^Author [Rr]esponse:?$'))" role="error" id="sub-article-title-check-3">The title of a <value-of select="$type"/> type sub-article should be 'Author response'. This one is: <value-of select="."/>
      </report>
      </rule>
  </pattern>
  <pattern id="sub-article-front-stub-checks-pattern">
    <rule context="sub-article/front-stub" id="sub-article-front-stub-checks">       
        <assert test="count(article-id[@pub-id-type='doi']) = 1" role="error" id="sub-article-front-stub-check-1">Sub-article must have one (and only one) &lt;article-id pub-id-type="doi"&gt; element. This one does not.</assert>
      </rule>
  </pattern>
  <pattern id="sub-article-doi-checks-pattern">
    <rule context="sub-article/front-stub/article-id[@pub-id-type='doi']" id="sub-article-doi-checks">       
        <let name="article-version-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi' and @specific-use='version']"/>
        <assert test="matches(.,'^10\.7554/eLife\.\d{5,6}\.\d\.sa\d$')" role="error" id="sub-article-doi-check-1">The DOI for this sub-article does not match the permitted format: <value-of select="."/>.</assert>
        
        <assert test="starts-with(.,$article-version-doi)" role="error" id="sub-article-doi-check-2">The DOI for this sub-article (<value-of select="."/>) does not start with the version DOI for the Reviewed Preprint (<value-of select="$article-version-doi"/>).</assert>
      </rule>
  </pattern>
  <pattern id="sub-article-bold-image-checks-pattern">
    <rule context="sub-article/body//p" id="sub-article-bold-image-checks">
        <report test="bold[matches(lower-case(.),'(image|table)')] and (inline-graphic or graphic or ext-link[inline-graphic or graphic])" role="error" id="sub-article-bold-image-1">p element contains both bold text (a label for an image or table) and a graphic. These should be in separate paragraphs (so that they are correctly processed into fig or table-wrap).</report>
        
        <report test="bold[matches(lower-case(.),'(author response|review) (image|table)')]" role="error" id="sub-article-bold-image-2">p element contains bold text which looks like a label for an image or table. Since it's not been captured as a figure in the XML, it might either be misformatted in Kotahi/Hypothesis or there's a processing bug.</report>
      </rule>
  </pattern>
  <pattern id="sub-article-ext-links-pattern">
    <rule context="sub-article/body//ext-link" id="sub-article-ext-links">
        <report test="not(inline-graphic) and matches(lower-case(@xlink:href),'imgur\.com')" role="warning" id="ext-link-imgur">ext-link in sub-article directs to imgur.com - <value-of select="@xlink:href"/>. Is this a figure or table (e.g. Author response image X) that should be captured semantically appropriately in the XML?</report>
        
        <report test="inline-graphic" role="error" id="ext-link-inline-graphic">ext-link in sub-article has a child inline-graphic. Is this a figure or table (e.g. Author response image X) that should be captured semantically appropriately in the XML?</report>
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
      <assert test="descendant::article[front/journal-meta/lower-case(journal-id[1])='elife']" role="error" id="article-tests-xspec-assert">article[front/journal-meta/lower-case(journal-id[1])='elife'] must be present.</assert>
      <assert test="descendant::article-meta/title-group/article-title" role="error" id="article-title-checks-xspec-assert">article-meta/title-group/article-title must be present.</assert>
      <assert test="descendant::article-meta/title-group/article-title/*" role="error" id="article-title-children-checks-xspec-assert">article-meta/title-group/article-title/* must be present.</assert>
      <assert test="descendant::article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)]" role="error" id="author-contrib-checks-xspec-assert">article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)] must be present.</assert>
      <assert test="descendant::contrib[@contrib-type='author']" role="error" id="author-corresp-checks-xspec-assert">contrib[@contrib-type='author'] must be present.</assert>
      <assert test="descendant::contrib-group//name" role="error" id="name-tests-xspec-assert">contrib-group//name must be present.</assert>
      <assert test="descendant::contrib-group//name/surname" role="error" id="surname-tests-xspec-assert">contrib-group//name/surname must be present.</assert>
      <assert test="descendant::name/given-names" role="error" id="given-names-tests-xspec-assert">name/given-names must be present.</assert>
      <assert test="descendant::contrib-group//name/*" role="error" id="name-child-tests-xspec-assert">contrib-group//name/* must be present.</assert>
      <assert test="descendant::article/front/article-meta/contrib-group[1]" role="error" id="orcid-name-checks-xspec-assert">article/front/article-meta/contrib-group[1] must be present.</assert>
      <assert test="descendant::contrib-id[@contrib-id-type='orcid']" role="error" id="orcid-tests-xspec-assert">contrib-id[@contrib-id-type='orcid'] must be present.</assert>
      <assert test="descendant::aff" role="error" id="affiliation-checks-xspec-assert">aff must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']//aff/country" role="error" id="country-tests-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']//aff/country must be present.</assert>
      <assert test="descendant::aff[ancestor::contrib-group[not(@*)]/parent::article-meta]//institution-wrap" role="error" id="aff-institution-wrap-tests-xspec-assert">aff[ancestor::contrib-group[not(@*)]/parent::article-meta]//institution-wrap must be present.</assert>
      <assert test="descendant::aff//institution-id" role="error" id="aff-institution-id-tests-xspec-assert">aff//institution-id must be present.</assert>
      <assert test="descendant::aff[count(institution-wrap/institution-id[@institution-id-type='ror'])=1]" role="error" id="aff-ror-tests-xspec-assert">aff[count(institution-wrap/institution-id[@institution-id-type='ror'])=1] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='journal']" role="error" id="journal-ref-checks-xspec-assert">mixed-citation[@publication-type='journal'] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='journal']/source" role="error" id="journal-source-checks-xspec-assert">mixed-citation[@publication-type='journal']/source must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='preprint']" role="error" id="preprint-ref-checks-xspec-assert">mixed-citation[@publication-type='preprint'] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='preprint']/source" role="error" id="preprint-source-checks-xspec-assert">mixed-citation[@publication-type='preprint']/source must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='book']" role="error" id="book-ref-checks-xspec-assert">mixed-citation[@publication-type='book'] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='book']/source" role="error" id="book-ref-source-checks-xspec-assert">mixed-citation[@publication-type='book']/source must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='confproc']" role="error" id="confproc-ref-checks-xspec-assert">mixed-citation[@publication-type='confproc'] must be present.</assert>
      <assert test="descendant::mixed-citation[@publication-type='confproc']/conf-name" role="error" id="confproc-conf-name-checks-xspec-assert">mixed-citation[@publication-type='confproc']/conf-name must be present.</assert>
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
      <assert test="descendant::ref//article-title" role="error" id="ref-article-title-checks-xspec-assert">ref//article-title must be present.</assert>
      <assert test="descendant::ref//chapter-title" role="error" id="ref-chapter-title-checks-xspec-assert">ref//chapter-title must be present.</assert>
      <assert test="descendant::ref//source" role="error" id="ref-source-checks-xspec-assert">ref//source must be present.</assert>
      <assert test="descendant::mixed-citation" role="error" id="mixed-citation-checks-xspec-assert">mixed-citation must be present.</assert>
      <assert test="descendant::mixed-citation/*" role="error" id="mixed-citation-child-checks-xspec-assert">mixed-citation/* must be present.</assert>
      <assert test="descendant::comment" role="error" id="comment-checks-xspec-assert">comment must be present.</assert>
      <assert test="descendant::back" role="error" id="back-tests-xspec-assert">back must be present.</assert>
      <assert test="descendant::ack" role="error" id="ack-tests-xspec-assert">ack must be present.</assert>
      <assert test="descendant::underline" role="error" id="underline-checks-xspec-assert">underline must be present.</assert>
      <assert test="descendant::bold" role="error" id="bold-checks-xspec-assert">bold must be present.</assert>
      <assert test="descendant::fig" role="error" id="fig-checks-xspec-assert">fig must be present.</assert>
      <assert test="descendant::fig/*" role="error" id="fig-child-checks-xspec-assert">fig/* must be present.</assert>
      <assert test="descendant::fig/label" role="error" id="fig-label-checks-xspec-assert">fig/label must be present.</assert>
      <assert test="descendant::fig/caption[p]/title" role="error" id="fig-title-checks-xspec-assert">fig/caption[p]/title must be present.</assert>
      <assert test="descendant::fig/caption" role="error" id="fig-caption-checks-xspec-assert">fig/caption must be present.</assert>
      <assert test="descendant::table-wrap" role="error" id="table-wrap-checks-xspec-assert">table-wrap must be present.</assert>
      <assert test="descendant::table-wrap/*" role="error" id="table-wrap-child-checks-xspec-assert">table-wrap/* must be present.</assert>
      <assert test="descendant::table-wrap/label" role="error" id="table-wrap-label-checks-xspec-assert">table-wrap/label must be present.</assert>
      <assert test="descendant::table-wrap/caption" role="error" id="table-wrap-caption-checks-xspec-assert">table-wrap/caption must be present.</assert>
      <assert test="descendant::supplementary-material" role="error" id="supplementary-material-checks-xspec-assert">supplementary-material must be present.</assert>
      <assert test="descendant::supplementary-material/*" role="error" id="supplementary-material-child-checks-xspec-assert">supplementary-material/* must be present.</assert>
      <assert test="descendant::disp-formula" role="error" id="disp-formula-checks-xspec-assert">disp-formula must be present.</assert>
      <assert test="descendant::inline-formula" role="error" id="inline-formula-checks-xspec-assert">inline-formula must be present.</assert>
      <assert test="descendant::alternatives[parent::disp-formula]" role="error" id="disp-equation-alternatives-checks-xspec-assert">alternatives[parent::disp-formula] must be present.</assert>
      <assert test="descendant::alternatives[parent::inline-formula]" role="error" id="inline-equation-alternatives-checks-xspec-assert">alternatives[parent::inline-formula] must be present.</assert>
      <assert test="descendant::list" role="error" id="list-checks-xspec-assert">list must be present.</assert>
      <assert test="descendant::graphic or descendant::inline-graphic" role="error" id="graphic-checks-xspec-assert">graphic|inline-graphic must be present.</assert>
      <assert test="descendant::graphic" role="error" id="graphic-placement-xspec-assert">graphic must be present.</assert>
      <assert test="descendant::inline-graphic" role="error" id="inline-checks-xspec-assert">inline-graphic must be present.</assert>
      <assert test="descendant::media" role="error" id="media-checks-xspec-assert">media must be present.</assert>
      <assert test="descendant::sec" role="error" id="sec-checks-xspec-assert">sec must be present.</assert>
      <assert test="descendant::sec[(parent::body or parent::back) and title]" role="error" id="top-sec-checks-xspec-assert">sec[(parent::body or parent::back) and title] must be present.</assert>
      <assert test="descendant::sec/label" role="error" id="sec-label-checks-xspec-assert">sec/label must be present.</assert>
      <assert test="descendant::title" role="error" id="title-checks-xspec-assert">title must be present.</assert>
      <assert test="descendant::article/body/sec/title or descendant::article/back/sec/title" role="error" id="title-toc-checks-xspec-assert">article/body/sec/title|article/back/sec/title must be present.</assert>
      <assert test="descendant::p[not(ancestor::sub-article) and (count(*)=1) and (child::bold or child::italic)]" role="error" id="p-bold-checks-xspec-assert">p[not(ancestor::sub-article) and (count(*)=1) and (child::bold or child::italic)] must be present.</assert>
      <assert test="descendant::p[not(ancestor::sub-article)]" role="error" id="p-ref-checks-xspec-assert">p[not(ancestor::sub-article)] must be present.</assert>
      <assert test="descendant::article/front/article-meta" role="error" id="general-article-meta-checks-xspec-assert">article/front/article-meta must be present.</assert>
      <assert test="descendant::article/front/article-meta/article-id" role="error" id="general-article-id-checks-xspec-assert">article/front/article-meta/article-id must be present.</assert>
      <assert test="descendant::article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='publisher-id']" role="error" id="publisher-article-id-checks-xspec-assert">article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='publisher-id'] must be present.</assert>
      <assert test="descendant::article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='doi']" role="error" id="article-dois-xspec-assert">article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::article/front/article-meta/author-notes" role="error" id="author-notes-checks-xspec-assert">article/front/article-meta/author-notes must be present.</assert>
      <assert test="descendant::article/front/article-meta/author-notes/fn" role="error" id="author-notes-fn-checks-xspec-assert">article/front/article-meta/author-notes/fn must be present.</assert>
      <assert test="descendant::article/front/article-meta//article-version" role="error" id="article-version-checks-xspec-assert">article/front/article-meta//article-version must be present.</assert>
      <assert test="descendant::article/front/article-meta/article-version-alternatives" role="error" id="article-version-alternatives-checks-xspec-assert">article/front/article-meta/article-version-alternatives must be present.</assert>
      <assert test="descendant::article/front[journal-meta/journal-id='elife']/article-meta[matches(replace(article-id[@specific-use='version'][1],'^.*\.',''),'^\d\d?$') and matches(descendant::article-version[@article-version-type='preprint-version'][1],'^1\.\d+$')]" role="error" id="rp-and-preprint-version-checks-xspec-assert">article/front[journal-meta/journal-id='elife']/article-meta[matches(replace(article-id[@specific-use='version'][1],'^.*\.',''),'^\d\d?$') and matches(descendant::article-version[@article-version-type='preprint-version'][1],'^1\.\d+$')] must be present.</assert>
      <assert test="descendant::article/front/article-meta/pub-date[@pub-type='epub']/year" role="error" id="preprint-pub-checks-xspec-assert">article/front/article-meta/pub-date[@pub-type='epub']/year must be present.</assert>
      <assert test="descendant::article/front/article-meta/contrib-group/contrib" role="error" id="contrib-checks-xspec-assert">article/front/article-meta/contrib-group/contrib must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/volume" role="error" id="volume-test-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/volume must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/elocation-id" role="error" id="elocation-id-test-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/elocation-id must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/history" role="error" id="history-tests-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/history must be present.</assert>
      <assert test="descendant::article[front[journal-meta/lower-case(journal-id[1])='elife']]//pub-history" role="error" id="pub-history-tests-xspec-assert">article[front[journal-meta/lower-case(journal-id[1])='elife']]//pub-history must be present.</assert>
      <assert test="descendant::event" role="error" id="event-tests-xspec-assert">event must be present.</assert>
      <assert test="descendant::event/*" role="error" id="event-child-tests-xspec-assert">event/* must be present.</assert>
      <assert test="descendant::event[date[@date-type='reviewed-preprint']/@iso-8601-date != '']" role="error" id="rp-event-tests-xspec-assert">event[date[@date-type='reviewed-preprint']/@iso-8601-date != ''] must be present.</assert>
      <assert test="descendant::event-desc" role="error" id="event-desc-tests-xspec-assert">event-desc must be present.</assert>
      <assert test="descendant::event/date" role="error" id="event-date-tests-xspec-assert">event/date must be present.</assert>
      <assert test="descendant::event/self-uri" role="error" id="event-self-uri-tests-xspec-assert">event/self-uri must be present.</assert>
      <assert test="descendant::abstract[parent::article-meta]" role="error" id="abstract-checks-xspec-assert">abstract[parent::article-meta] must be present.</assert>
      <assert test="descendant::abstract[parent::article-meta]/*" role="error" id="abstract-child-checks-xspec-assert">abstract[parent::article-meta]/* must be present.</assert>
      <assert test="descendant::abstract[@xml:lang]" role="error" id="abstract-lang-checks-xspec-assert">abstract[@xml:lang] must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']//permissions" role="error" id="front-permissions-tests-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']//permissions must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/licenses/by/')]" role="error" id="cc-by-permissions-tests-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/licenses/by/')] must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/publicdomain/zero')]" role="error" id="cc-0-permissions-tests-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/publicdomain/zero')] must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license" role="error" id="license-tests-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license must be present.</assert>
      <assert test="descendant::front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license/license-p" role="error" id="license-p-tests-xspec-assert">front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license/license-p must be present.</assert>
      <assert test="descendant::permissions/license[@xlink:href]/license-p" role="error" id="license-link-tests-xspec-assert">permissions/license[@xlink:href]/license-p must be present.</assert>
      <assert test="descendant::permissions/license[ali:license_ref]/license-p" role="error" id="license-ali-ref-link-tests-xspec-assert">permissions/license[ali:license_ref]/license-p must be present.</assert>
      <assert test="descendant::fig[not(descendant::permissions)] or descendant::media[@mimetype='video' and not(descendant::permissions)] or descendant::table-wrap[not(descendant::permissions)] or descendant::supplementary-material[not(descendant::permissions)]" role="error" id="fig-permissions-check-xspec-assert">fig[not(descendant::permissions)]|media[@mimetype='video' and not(descendant::permissions)]|table-wrap[not(descendant::permissions)]|supplementary-material[not(descendant::permissions)] must be present.</assert>
      <assert test="descendant::related-object[@content-type or @document-id]" role="error" id="clintrial-related-object-xspec-assert">related-object[@content-type or @document-id] must be present.</assert>
      <assert test="descendant::front/notes" role="error" id="notes-checks-xspec-assert">front/notes must be present.</assert>
      <assert test="descendant::title" role="error" id="digest-title-checks-xspec-assert">title must be present.</assert>
      <assert test="descendant::xref" role="error" id="xref-checks-xspec-assert">xref must be present.</assert>
      <assert test="descendant::xref[@ref-type='bibr']" role="error" id="ref-citation-checks-xspec-assert">xref[@ref-type='bibr'] must be present.</assert>
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
      <assert test="descendant::sub-article[@article-type='author-comment']//fig/label" role="error" id="ar-image-labels-xspec-assert">sub-article[@article-type='author-comment']//fig/label must be present.</assert>
      <assert test="descendant::sub-article[@article-type='author-comment']//table-wrap/label" role="error" id="ar-table-labels-xspec-assert">sub-article[@article-type='author-comment']//table-wrap/label must be present.</assert>
      <assert test="descendant::sub-article[@article-type='referee-report']//fig/label" role="error" id="pr-image-labels-xspec-assert">sub-article[@article-type='referee-report']//fig/label must be present.</assert>
      <assert test="descendant::sub-article[@article-type='referee-report']//table-wrap/label" role="error" id="pr-table-labels-xspec-assert">sub-article[@article-type='referee-report']//table-wrap/label must be present.</assert>
      <assert test="descendant::sub-article/front-stub/title-group/article-title" role="error" id="sub-article-title-checks-xspec-assert">sub-article/front-stub/title-group/article-title must be present.</assert>
      <assert test="descendant::sub-article/front-stub" role="error" id="sub-article-front-stub-checks-xspec-assert">sub-article/front-stub must be present.</assert>
      <assert test="descendant::sub-article/front-stub/article-id[@pub-id-type='doi']" role="error" id="sub-article-doi-checks-xspec-assert">sub-article/front-stub/article-id[@pub-id-type='doi'] must be present.</assert>
      <assert test="descendant::sub-article/body//p" role="error" id="sub-article-bold-image-checks-xspec-assert">sub-article/body//p must be present.</assert>
      <assert test="descendant::sub-article/body//ext-link" role="error" id="sub-article-ext-links-xspec-assert">sub-article/body//ext-link must be present.</assert>
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