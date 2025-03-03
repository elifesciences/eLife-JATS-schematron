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
            <xsl:variable name="remainder" select="number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7) mod 11"/>
            <xsl:variable name="calc" select="if ($remainder=0) then 0 else (11 - $remainder)"/>
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
      
      <xsl:otherwise>
        <xsl:variable name="is-equal-contrib" select="if ($contrib-group/contrib[@contrib-type='author'][1]/@equal-contrib='yes') then true() else false()"/>
        
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
  <pattern id="underline-checks-pattern">
    <rule context="underline" id="underline-checks">
      <report test="not(ancestor::sub-article) and matches(.,'(^|\s)([Tt]able|[Tt]bl)[\.\s]')" role="warning" id="underline-check-2">[underline-check-2] Content of underline element suggests it's intended to be a table or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::underline" role="error" id="underline-checks-xspec-assert">underline must be present.</assert>
    </rule>
  </pattern>
</schema>