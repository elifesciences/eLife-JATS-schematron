<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:java="http://www.java.com/"
   xmlns:file="java.io.File"
   xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
   xmlns:mml="http://www.w3.org/1998/Math/MathML"
   xmlns:meca="http://manuscriptexchange.org"
   queryBinding="xslt2">
    
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

    <pattern id="article-title">
     <rule context="article-meta/title-group/article-title" id="article-title-checks">
        <report test=". = upper-case(.)" 
        role="error" 
        id="article-title-all-caps">Article title is in all caps - <value-of select="."/>. Please change to sentence case.</report>
     </rule>
    </pattern>

    <pattern id="author-checks">
     <rule context="article-meta/contrib-group[count(aff gt 1)]/contrib[@contrib-type='author' and not(collab)]" id="author-contrib-checks">
        <assert test="xref[@ref-type='aff']" 
        role="error" 
        id="author-contrb-no-aff-xref">Author <value-of select="e:get-name(name[1])"/> has no affiliation.</assert>
     </rule>
    
     <rule context="contrib-group//name" id="name-tests">
    	<assert test="count(surname) = 1"
        role="error" 
        id="surname-test-1">Each name must contain only one surname.</assert>
	  
	   <report test="count(given-names) gt 1" 
        role="error" 
        id="given-names-test-1">Each name must contain only one given-names element.</report>
	  
	   <assert test="given-names" 
        role="warning" 
        id="given-names-test-2">This name - <value-of select="."/> - does not contain a given-name. Please check with eLife staff that this is correct.</assert>
	   </rule>

    <rule context="contrib-group//name/surname" id="surname-tests">
		
	  <report test="not(*) and (normalize-space(.)='')" 
        role="error" 
        id="surname-test-2">surname must not be empty.</report>
		
    <report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" 
        role="error" 
        id="surname-test-3">surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	  <assert test="matches(.,&quot;^[\p{L}\p{M}\s'’\.-]*$&quot;)" 
        role="error" 
        id="surname-test-4">surname should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <report test="matches(.,'^\p{Ll}') and not(matches(.,'^de[rn]? |^van |^von |^el |^te[rn] '))" 
        role="warning" 
        id="surname-test-5">surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</report>
	  
	  <report test="matches(.,'^\p{Zs}')" 
        role="error" 
        id="surname-test-6">surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\p{Zs}$')" 
        role="error" 
        id="surname-test-7">surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	    
	    <report test="matches(.,'^[A-Z]{1,2}\.?\p{Zs}') and (string-length(.) gt 3)" 
        role="warning" 
        id="surname-test-8">surname looks to start with initial - '<value-of select="."/>'. Should '<value-of select="substring-before(.,' ')"/>' be placed in the given-names field?</report>
	    
	    <report test="matches(.,'[\(\)\[\]]')" 
	      role="warning" 
	      id="surname-test-9">surname contains brackets - '<value-of select="."/>'. Should the bracketed text be placed in the given-names field instead?</report>
	  </rule>

    <rule context="name/given-names" id="given-names-tests">
	   <report test="not(*) and (normalize-space(.)='')" 
        role="error" 
        id="given-names-test-3">given-names must not be empty.</report>
		
    	<report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" 
        role="error" 
        id="given-names-test-4">given-names must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript) - '<value-of select="."/>'.</report>
		
      <assert test="matches(.,&quot;^[\p{L}\p{M}\(\)\s'’\.-]*$&quot;)" 
        role="error" 
        id="given-names-test-5">given-names should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <assert test="matches(.,'^\p{Lu}')" 
        role="warning" 
        id="given-names-test-6">given-names doesn't begin with a capital letter - '<value-of select="."/>'. Is this correct?</assert>
	  
    <report test="matches(.,'^\p{Zs}')" 
        role="error" 
        id="given-names-test-8">given-names starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
    <report test="matches(.,'\p{Zs}$')" 
        role="error" 
        id="given-names-test-9">given-names ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'[A-Za-z]\.? [Dd]e[rn]?$')" 
        role="warning" 
        id="given-names-test-10">given-names ends with de, der, or den - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
		
	  <report test="matches(.,'[A-Za-z]\.? [Vv]an$')" 
        role="warning" 
        id="given-names-test-11">given-names ends with ' van' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z]\.? [Vv]on$')" 
        role="warning" 
        id="given-names-test-12">given-names ends with ' von' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z]\.? [Ee]l$')" 
        role="warning" 
        id="given-names-test-13">given-names ends with ' el' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(.,'[A-Za-z]\.? [Tt]e[rn]?$')" 
        role="warning" 
        id="given-names-test-14">given-names ends with te, ter, or ten - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(normalize-space(.),'[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]|[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]$|^[A-za-z]\p{Zs}[A-za-z]$')" 
        role="info" 
        id="given-names-test-15">given-names contains initials with spaces. Ensure that the space(s) is removed between initials - '<value-of select="."/>'.</report>
      
      <report test="matches(.,'[\(\)\[\]]')" 
        role="warning" 
        id="pre-given-names-test-16">given-names contains brackets - '<value-of select="."/>'. This will be flagged by Crossref (although will not actually cause any significant problems). Please add the following author query: Please confirm whether you are happy to remove the brackets around (one of) your given names - '<value-of select="."/>'. This will cause minor issues at Crossref, although they can be retained if desired.</report>
      
      <report test="matches(.,'[\(\)\[\]]')" 
        role="warning" 
        id="final-given-names-test-16">given-names contains brackets - '<value-of select="."/>'. This will be flagged by Crossref (although will not actually cause any significant problems).</report>
		
	   </rule>

    <rule context="contrib-group//name/*" id="name-child-tests">
      <assert test="local-name() = ('surname','given-names','suffix')" 
        role="error" 
        id="disallowed-child-assert"><value-of select="local-name()"/> is not supported as a child of name.</assert>
    </rule>
    </pattern>

    <pattern id="journal-ref">
     <rule context="mixed-citation[@publication-type='journal']" id="journal-ref-checks">
        <assert test="source" 
        role="error" 
        id="journal-ref-source">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" 
        role="error" 
        id="journal-ref-article-title">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>
     </rule>
    </pattern>

    <pattern id="ref-labels">
     <rule context="ref-list" id="ref-list-checks">
        <let name="labels" value="./ref/label"/>
        <let name="indistinct-labels" value="for $label in distinct-values($labels) return $label[count($labels[. = $label]) gt 1]"/>
        <assert test="empty($indistinct-labels)" 
        role="error" 
        id="indistinct-ref-labels">Duplicate labels in reference list - <value-of select="string-join($indistinct-labels,'; ')"/>. Have there been typesetting errors?</assert>
     </rule>
    </pattern>

    <pattern id="strike">
     <rule context="strike" id="strike-checks">
        <report test="." 
        role="warning" 
        id="strike-warning">strike element is present. Is this tracked change formatting that's been erroneously retained? Should this text be deleted?</report>
     </rule>
    </pattern>

    <pattern id="underline">
     <rule context="underline" id="underline-checks">
        <report test="string-length(.) gt 20" 
        role="warning" 
        id="underline-warning">underline element contains more than 20 characters. Is this tracked change formatting that's been erroneously retained?</report>
     </rule>
    </pattern>

    <!-- Checks for the manifest file in the meca package.
          For validation in oXygen this assumes the manifest file is in a parent folder of the xml file being validated and named as manifest.xml
          For validation via BaseX, there is a separate file - meca-manifest-schematron.sch
     -->
    <pattern id="meca-manifest-checks">
     <rule context="root()">
      <let name="xml-folder" value="substring-before(base-uri(),tokenize(base-uri(.), '/')[last()])"/>
      <let name="parent-folder" value="substring-before($xml-folder,tokenize(replace($xml-folder,'/$',''), '/')[last()])"/>
      <let name="manifest-path" value="concat($parent-folder,'manifest.xml')"/>
      <let name="manifest" value="document($manifest-path)"/>

      <let name="manifest-files" value="$manifest//meca:instance/@href"/>
      <let name="indistinct-files" value="for $file in distinct-values($manifest-files) return $file[count($manifest-files[. = $file]) > 1]"/>
      <assert test="empty($indistinct-files)"
        role="error"
        flag="manifest"
        id="indistinct-files-presence">The manifest.xml file for this article has the following files referred to numerous times within separate items: <value-of select="string-join($indistinct-files,'; ')"/>.</assert>

      <let name="allowed-types" value="('article','figure','equation','inlineequation','inlinefigure','table','supplement','video','transfer-details','x-hw-directives')"/>
      <let name="unallowed-items" value="$manifest//meca:item[not(@type) or not(@type=$allowed-types)]"/>
      <assert test="empty($unallowed-items)"
        role="error"
        flag="manifest"
        id="item-type-conformance">The manifest.xml file for this article has item elements with unallowed item types. Here are the unsupported item types: <value-of select="distinct-values($unallowed-items/@type)"/></assert>
     </rule>
    </pattern>
    
</schema>