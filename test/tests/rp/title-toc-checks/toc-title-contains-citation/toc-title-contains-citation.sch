<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:meca="http://manuscriptexchange.org" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:file="java.io.File" xmlns:java="http://www.java.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" queryBinding="xslt2">
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
  <pattern id="title-toc-checks-pattern">
    <rule context="article/body/sec/title|article/back/sec/title" id="title-toc-checks">
      <report test="xref" role="error" id="toc-title-contains-citation">[toc-title-contains-citation] <name/> element contains a citation and will appear within the table of contents on EPP. This will cause images not to load. Please either remove the citaiton or make it plain text.</report>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::article/body/sec/title or descendant::article/back/sec/title" role="error" id="title-toc-checks-xspec-assert">article/body/sec/title|article/back/sec/title must be present.</assert>
    </rule>
  </pattern>
</schema>