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
  <pattern id="symbol-checks">
    <rule context="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link" id="unallowed-symbol-tests">
      <report test="contains(.,'&#x9D;')" role="error" id="operating-system-command-presence">
        <name/> element contains an operating system command character '&#x9D;' (unicode string: &amp;#x9D;) which should very likely be replaced/removed. - <value-of select="."/>
      </report>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::p or descendant::td or descendant::th or descendant::title or descendant::xref or descendant::bold or descendant::italic or descendant::sub or descendant::sc or descendant::named-content or descendant::monospace or descendant::code or descendant::underline or descendant::fn or descendant::institution or descendant::ext-link" role="error" id="unallowed-symbol-tests-xspec-assert">p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link must be present.</assert>
    </rule>
  </pattern>
</schema>