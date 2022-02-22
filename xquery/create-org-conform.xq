declare namespace xsl='http://www.w3.org/1999/XSL/Transform';
let $org-regex := replace(doc('../src/schematron.sch')//*:let[@name="org-regex"]/@value,"^'|'$",'')

return <xsl:function name="e:org-conform" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>{
      for $x in tokenize($org-regex,'\|')
      let $t := "'"||replace(replace(upper-case(substring($x,1,1))||substring($x,2),'\\p\{Zs\}\?',' '),'\\\.','.')||"'"
      return <xsl:when test="{("matches($s,'"||$x||"')")}">
        <xsl:value-of select="{$t}"/>
      </xsl:when>
    }<xsl:otherwise>
        <xsl:value-of select="'undefined'"/>
      </xsl:otherwise></xsl:choose>
  </xsl:function>