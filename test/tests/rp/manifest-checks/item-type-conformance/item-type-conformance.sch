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
  <pattern id="meca-manifest-checks">
    <rule context="root()" id="manifest-checks">
      <let name="xml-folder" value="substring-before(base-uri(),tokenize(base-uri(.), '/')[last()])"/>
      <let name="parent-folder" value="substring-before($xml-folder,tokenize(replace($xml-folder,'/$',''), '/')[last()])"/>
      <let name="manifest-path" value="concat($parent-folder,'manifest.xml')"/>
      <let name="manifest" value="document($manifest-path)"/>
      <let name="manifest-files" value="$manifest//meca:instance/@href"/>
      <let name="indistinct-files" value="for $file in distinct-values($manifest-files) return $file[count($manifest-files[. = $file]) &gt; 1]"/>
      <let name="allowed-types" value="('article','figure','equation','inlineequation','inlinefigure','table','supplement','video','transfer-details','x-hw-directives')"/>
      <let name="unallowed-items" value="$manifest//meca:item[not(@type) or not(@type=$allowed-types)]"/>
      <assert test="empty($unallowed-items)" role="error" flag="manifest" id="item-type-conformance">The manifest.xml file for this article has item elements with unallowed item types. Here are the unsupported item types: <value-of select="distinct-values($unallowed-items/@type)"/>
      </assert>
      <let name="missing-files" value="for $file in distinct-values($manifest-files) return if (not(java:file-exists($file, $parent-folder))) then $file else ()"/>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::root()" role="error" id="manifest-checks-xspec-assert">root() must be present.</assert>
    </rule>
  </pattern>
</schema>