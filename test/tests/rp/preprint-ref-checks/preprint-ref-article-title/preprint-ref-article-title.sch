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
  <pattern id="preprint-ref-checks-pattern">
    <rule context="mixed-citation[@publication-type='preprint']" id="preprint-ref-checks">
      <assert test="article-title" role="error" id="preprint-ref-article-title">[preprint-ref-article-title] This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::mixed-citation[@publication-type='preprint']" role="error" id="preprint-ref-checks-xspec-assert">mixed-citation[@publication-type='preprint'] must be present.</assert>
    </rule>
  </pattern>
</schema>