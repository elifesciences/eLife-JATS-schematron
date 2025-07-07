<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:meca="http://manuscriptexchange.org" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:file="java.io.File" xmlns:java="http://www.java.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" queryBinding="xslt2">
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
  <let name="rors" value="'../../../../../src/rors.xml'"/>
  <let name="wellcome-ror-ids" value="('https://ror.org/029chgv08')"/>
  <let name="known-grant-funder-ror-ids" value="('https://ror.org/006wxqw41','https://ror.org/00097mb19','https://ror.org/03dy4aq19','https://ror.org/013tf3c58','https://ror.org/013kjyp64')"/>
  <let name="grant-doi-exception-funder-ids" value="($wellcome-ror-ids,$known-grant-funder-ror-ids)"/>
  <xsl:function name="e:alter-award-id">
    <xsl:param name="award-id-elem" as="xs:string"/>
    <xsl:param name="ror-id" as="xs:string"/>
    <xsl:choose>
      
      <xsl:when test="$ror-id='https://ror.org/006wxqw41'">
        
        <xsl:value-of select="if (matches($award-id-elem,'^\d+(\.\d+)?$')) then concat('GBMF',$award-id-elem)          else if (not(matches(upper-case($award-id-elem),'^GBMF'))) then concat('GBMF',replace($award-id-elem,'[^\d\.]',''))          else upper-case($award-id-elem)"/>
      </xsl:when>
      
      <xsl:when test="$ror-id='https://ror.org/00097mb19'">
        
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JPMJ[A-Z0-9]+\s*$') and not(matches(upper-case($award-id-elem),'^JPMJ[A-Z0-9]+$'))) then concat('JPMJ',upper-case(replace(substring-after($award-id-elem,'JPMJ'),'\s+$','')))         else upper-case($award-id-elem)"/>
      </xsl:when>
      
      <xsl:when test="$ror-id='https://ror.org/03dy4aq19'">
        
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JSMF2\d+$')) then substring-after($award-id-elem,'JSMF')         else replace($award-id-elem,'[^\d\-]','')"/>
      </xsl:when>
      
      <xsl:when test="$ror-id='https://ror.org/013tf3c58'">
        
        <xsl:value-of select="if (matches($award-id-elem,'\d\-')) then replace(substring-before($award-id-elem,'-'),'[^A-Z\d]','')         else replace($award-id-elem,'[^A-Z\d]','')"/>
      </xsl:when>
      
      <xsl:when test="$ror-id='https://ror.org/013kjyp64'">
        
        <xsl:value-of select="if (matches($award-id-elem,'[a-z]\s+\([A-Z\d]+\)')) then substring-before(substring-after($award-id-elem,'('),')')         else $award-id-elem"/>
      </xsl:when>
      
      <xsl:when test="$ror-id='https://ror.org/013kjyp64'">
        
        <xsl:value-of select="if (contains(upper-case($award-id-elem),'2020')) then concat('2020',replace(substring-after($award-id-elem,'2020'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2021')) then concat('2021',replace(substring-after($award-id-elem,'2021'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2022')) then concat('2022',replace(substring-after($award-id-elem,'2022'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2023')) then concat('2023',replace(substring-after($award-id-elem,'2023'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2024')) then concat('2024',replace(substring-after($award-id-elem,'2024'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'CEEC')) then concat('CEEC',replace(substring-after(upper-case($award-id-elem),'CEEC'),'[^A-Z0-9/]',''))         else if (contains(upper-case($award-id-elem),'PTDC/')) then concat('PTDC/',replace(substring-after(upper-case($award-id-elem),'PTDC/'),'[^A-Z0-9/\-]',''))         else if (contains(upper-case($award-id-elem),'DL 57/')) then concat('DL 57/',replace(substring-after(upper-case($award-id-elem),'DL 57/'),'[^A-Z0-9/\-]',''))         else $award-id-elem"/>
      </xsl:when>
      
      <xsl:when test="$ror-id=('https://ror.org/0472cxd90','https://ror.org/00k4n6c32')">
        
        <xsl:value-of select="if (matches($award-id-elem,'[a-z]\s+\(\d+\)')) then substring-before(substring-after($award-id-elem,'('),')')         else if (matches($award-id-elem,'\d{6,9}')) then replace($award-id-elem,'[^\d]','')         else $award-id-elem"/>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:value-of select="$award-id-elem"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:toLowerCase" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:variable name="exceptions">
      <list>
        <case lower="elife">eLife</case>
        <case lower="cryo-em">cryo-EM</case>
      </list>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="matches(normalize-space(lower-case($s)),'^([1-4]d|rna|dna|mri|hiv|tor|aids|covid-19|covid)$')">
        <xsl:value-of select="upper-case($s)"/>
      </xsl:when>
      <xsl:when test="normalize-space(lower-case($s))=$exceptions//*:case/@*:lower">
        <xsl:variable name="new-s" select="$exceptions//*:case[@*:lower=normalize-space(lower-case($s))][1]/text()"/>
        <xsl:value-of select="replace($s,normalize-space($s),$new-s)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="lower-case($s)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:toSentenceCase" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:variable name="exceptions">
      <list>
        <case lower="elife">eLife</case>
        <case lower="cryo-em">Cryo-EM</case>
      </list>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains(normalize-space($s),' ')">
        <xsl:variable name="token1" select="substring-before(normalize-space($s),' ')"/>
        <xsl:variable name="token2" select="substring-after(normalize-space($s),$token1)"/>
          <xsl:value-of select="concat(               e:toSentenceCase($token1),               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\p{Zs}') return e:toLowerCase($x),' ')               )"/>
      </xsl:when>
      <xsl:when test="normalize-space(lower-case($s))=$exceptions//*:case/@*:lower">
        <xsl:variable name="new-s" select="$exceptions//*:case[@*:lower=normalize-space(lower-case($s))][1]/text()"/>
        <xsl:value-of select="replace($s,normalize-space($s),$new-s)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(upper-case(substring($s, 1, 1)), lower-case(substring($s, 2)))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:template match="." mode="customCopy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()" mode="customCopy"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template name="copy-non-default-attribute" match="@*" mode="customCopy">
    <xsl:variable name="default-attributes">
      <mapping>
        <attribute name="toggle" default="yes"/>
        <attribute name="orientation" default="portrait"/>
        <attribute name="position" default="float"/>
        <attribute name="name-style" default="western"/>
      </mapping>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="name()=$default-attributes//*:mapping/*:attribute/@*:name">
        <xsl:variable name="name" select="name()"/>
        <xsl:variable name="default" select="$default-attributes//*:mapping/*:attribute[@*:name=$name]/@*:default"/>
        <xsl:if test=".!=$default">
          <xsl:attribute name="{$name}">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="{name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="." mode="sentenceCase">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="customCopy"/>
      <xsl:for-each select="node()|comment()|processing-instruction()">
        <xsl:choose>
          <xsl:when test="self::comment() or self::processing-instruction()">
            <xsl:apply-templates mode="customCopy" select="."/>
          </xsl:when>
          <xsl:when test="self::text()">
            <xsl:value-of select="e:toSentenceCase(.)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="lowerCase"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="." mode="lowerCase">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="customCopy"/>
      <xsl:for-each select="node()|comment()|processing-instruction()">
        <xsl:choose>
          <xsl:when test="self::comment() or self::processing-instruction()">
            <xsl:apply-templates mode="customCopy" select="."/>
          </xsl:when>
          <xsl:when test="self::text()">
            <xsl:value-of select="e:toLowerCase(.)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="lowerCase"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  <xsl:template name="tag-author-list">
      <xsl:param name="author-string"/>
      <xsl:variable name="cleaned-author-list" select="normalize-space(replace(replace($author-string,'[\.,]$',''),'\.\s+','.'))"/>
      <xsl:variable name="author-list">
        <xsl:choose>
            <xsl:when test="matches(concat($cleaned-author-list,','),'^([\p{L}\p{P}\s’]+,\s[\p{Lu}\.]+,)$')">
                <xsl:variable name="all-comma-separated-parts" select="tokenize(normalize-space($author-string), ',')"/>
                <xsl:for-each select="$all-comma-separated-parts[position() mod 2 = 1]">
                  <xsl:variable name="original-index-of-current-odd-part" select="(position() * 2) - 1"/>
                  <xsl:variable name="original-index-of-next-even-part" select="position() * 2"/>
                  <xsl:variable name="part-before-comma" select="normalize-space($all-comma-separated-parts[$original-index-of-current-odd-part])"/>
                  <xsl:variable name="part-after-comma" select="normalize-space($all-comma-separated-parts[$original-index-of-next-even-part])"/>
                  <xsl:value-of select="concat($part-before-comma, ' ', $part-after-comma)"/>
                  <xsl:if test="position() != (count($all-comma-separated-parts) div 2)">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$cleaned-author-list"/>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="tokenize($author-list,', ')">
        <xsl:variable name="author-name" select="normalize-space(.)"/>
        <xsl:if test="string-length($author-name) &gt; 0">
            <xsl:choose>
                <xsl:when test="matches($author-name,'^[\p{Lu}\.]+\s[\p{L}\p{P}\s’]+$')">
                    <string-name xmlns="">
                        <xsl:analyze-string select="$author-name" regex="{'^([\p{Lu}\s\.]+)\s+([\p{L}\p{P}\s’]+)$'}">
                            <xsl:matching-substring>
                                <given-names>
                    <xsl:value-of select="regex-group(1)"/>
                  </given-names>
                                <xsl:text> </xsl:text>
                                <surname>
                    <xsl:value-of select="regex-group(2)"/>
                  </surname>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </string-name>
                </xsl:when>
                <xsl:when test="matches($author-name,'^[\p{L}\p{P}\s’]+\s[\p{Lu}\.]+$')">
                    <string-name xmlns="">
                        <xsl:analyze-string select="$author-name" regex="{'^([\p{L}\p{P}\s’]+)\s+([\p{Lu}\s\.]+)$'}">
                            <xsl:matching-substring>
                                <surname>
                    <xsl:value-of select="regex-group(1)"/>
                  </surname>
                                <xsl:text> </xsl:text>
                                <given-names>
                    <xsl:value-of select="regex-group(2)"/>
                  </given-names>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </string-name>
                </xsl:when>
                <xsl:otherwise>
                    <string-name xmlns="">
                        <surname>
                <xsl:value-of select="$author-name"/>
              </surname>
                    </string-name>
                  </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </xsl:template>
  <xsl:template name="get-first-sentence">
    <xsl:param name="nodes"/>
    <xsl:param name="buffer" select="()"/>
    <xsl:choose>
      <xsl:when test="not($nodes)">
        <xsl:apply-templates select="$buffer" mode="customCopy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-node" select="$nodes[1]"/>
        <xsl:variable name="remaining-nodes" select="$nodes[position() &gt; 1]"/>
        <xsl:choose>
          <xsl:when test="$current-node instance of text()">
            <xsl:variable name="text-content" select="$current-node"/>
            <xsl:choose>
              <xsl:when test="matches($text-content, '.*[\.!?]\s+')">
                <xsl:variable name="first-part" select="replace(replace($text-content, '(.*?[\.!?]\s+)(.*)', '$1'),'\s+$','')"/>
                <xsl:apply-templates select="$buffer, $first-part" mode="customCopy"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="get-first-sentence">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="buffer" select="$buffer, $current-node"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$current-node instance of element()">
            <xsl:variable name="temp-buffer">
              <xsl:copy-of select="$buffer"/>
              <xsl:element name="{$current-node/name()}" namespace="">
                <xsl:apply-templates select="$current-node/@*" mode="customCopy"/>
                <xsl:call-template name="get-first-sentence">
                  <xsl:with-param name="nodes" select="$current-node/node()"/>
                  <xsl:with-param name="buffer" select="()"/> 
                </xsl:call-template>
              </xsl:element>
            </xsl:variable>
            <xsl:call-template name="get-first-sentence">
              <xsl:with-param name="nodes" select="$remaining-nodes"/>
              <xsl:with-param name="buffer" select="$temp-buffer/* | $temp-buffer/text()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="get-first-sentence">
              <xsl:with-param name="nodes" select="$remaining-nodes"/>
              <xsl:with-param name="buffer" select="$buffer, $current-node"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="get-remaining-sentences">
    <xsl:param name="nodes"/>
    <xsl:param name="first-sentence-completed" select="false()"/>
    <xsl:param name="buffer" select="()"/>
    <xsl:choose>
      <xsl:when test="not($nodes) and $first-sentence-completed">
        <xsl:apply-templates select="$buffer" mode="customCopy"/>
      </xsl:when>
      <xsl:when test="not($nodes)">
        <xsl:sequence select="()"/> 
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-node" select="$nodes[1]"/>
        <xsl:variable name="remaining-nodes" select="$nodes[position() &gt; 1]"/>
        <xsl:choose>
          <xsl:when test="$current-node instance of text()">
            <xsl:variable name="text-content" select="$current-node"/>
            <xsl:choose>
              <xsl:when test="matches($text-content, '.*[.!?]\s+') and not($first-sentence-completed)">
                <xsl:variable name="remaining-part" select="replace($text-content, '.*?[\.!?]\s+(.*)', '$1')"/>
                <xsl:call-template name="get-remaining-sentences">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="first-sentence-completed" select="true()"/>
                  <xsl:with-param name="buffer" select="$buffer, $remaining-part"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="$first-sentence-completed">
                <xsl:call-template name="get-remaining-sentences">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="first-sentence-completed" select="true()"/>
                  <xsl:with-param name="buffer" select="$buffer, $current-node"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="get-remaining-sentences">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="first-sentence-completed" select="$first-sentence-completed"/>
                  <xsl:with-param name="buffer" select="$buffer"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$current-node instance of element()">
            <xsl:choose>
              <xsl:when test="$first-sentence-completed">
                <xsl:variable name="temp-buffer">
                  <xsl:apply-templates select="$buffer" mode="customCopy"/>
                  <xsl:apply-templates select="$current-node" mode="customCopy"/>
                </xsl:variable>
                <xsl:call-template name="get-remaining-sentences">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="first-sentence-completed" select="true()"/>
                  <xsl:with-param name="buffer" select="$temp-buffer/* | $temp-buffer/text()"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="element-result">
                  <xsl:call-template name="get-remaining-sentences">
                    <xsl:with-param name="nodes" select="$current-node/node()"/>
                    <xsl:with-param name="first-sentence-completed" select="$first-sentence-completed"/>
                    <xsl:with-param name="buffer" select="()"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="string-length($element-result) &gt; 0">
                    <xsl:variable name="temp-buffer">
                      <xsl:copy-of select="$buffer" copy-namespaces="no"/>
                      <xsl:element name="{$current-node/name()}" namespace="">
                        <xsl:apply-templates select="$current-node/@*" mode="customCopy"/>
                        <xsl:sequence select="$element-result"/>
                      </xsl:element>
                    </xsl:variable>
                    <xsl:call-template name="get-remaining-sentences">
                      <xsl:with-param name="nodes" select="$remaining-nodes"/>
                      <xsl:with-param name="first-sentence-completed" select="true()"/> <xsl:with-param name="buffer" select="$temp-buffer/* | $temp-buffer/text()"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="get-remaining-sentences">
                      <xsl:with-param name="nodes" select="$remaining-nodes"/>
                      <xsl:with-param name="first-sentence-completed" select="$first-sentence-completed"/>
                      <xsl:with-param name="buffer" select="$buffer"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$first-sentence-completed">
                <xsl:call-template name="get-remaining-sentences">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="first-sentence-completed" select="true()"/>
                  <xsl:with-param name="buffer" select="$buffer, $current-node"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="get-remaining-sentences">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="first-sentence-completed" select="$first-sentence-completed"/>
                  <xsl:with-param name="buffer" select="$buffer"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <sqf:fixes>
    <sqf:fix id="delete-elem">
      <sqf:description>
        <sqf:title>Delete element</sqf:title>
      </sqf:description>
      <sqf:delete match="."/>
    </sqf:fix>
    
    <sqf:fix id="strip-tags">
      <sqf:description>
        <sqf:title>Strip the tags</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xsl:apply-templates mode="customCopy" select="node()"/>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-fig-xref">
      <sqf:description>
        <sqf:title>Change to figure xref</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xref xmlns="" ref-type="fig" rid="dummy">
          <xsl:apply-templates mode="customCopy" select="node()"/>
        </xref>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-supp-xref">
      <sqf:description>
        <sqf:title>Change to supp xref</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xref xmlns="" ref-type="supplementary-material" rid="dummy">
          <xsl:apply-templates mode="customCopy" select="node()"/>
        </xref>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-to-ext-link">
      <sqf:description>
        <sqf:title>Change to ext-link</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <ext-link xmlns="" ext-link-type="uri">
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="."/>
          </xsl:attribute>
          <xsl:apply-templates mode="customCopy" select="node()"/>
        </ext-link>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-p-to-title">
      <sqf:description>
        <sqf:title>Change the p to title</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*" mode="customCopy"/>
          <xsl:element name="title">
            <xsl:apply-templates select="p[1]/text()|p[1]/*|p[1]/comment()|p[1]/processing-instruction()" mode="customCopy"/>
          </xsl:element>
          <xsl:text>
</xsl:text>
          <xsl:apply-templates select="p[position() gt 1]|text()[position() gt 1]|comment()|processing-instruction()" mode="customCopy"/>
        </xsl:copy>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-move-sentence-to-title">
      <sqf:description>
        <sqf:title>Make first sentence the title</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*" mode="customCopy"/>
          <title xmlns="">
            <xsl:call-template name="get-first-sentence">
              <xsl:with-param name="nodes" select="p/node()"/>
            </xsl:call-template>
          </title>
          <xsl:text>
</xsl:text>
          <xsl:variable name="remaining-content">
            <xsl:call-template name="get-remaining-sentences">
              <xsl:with-param name="nodes" select="p/node()"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:if test="$remaining-content">
            <p xmlns="">
              <xsl:sequence select="$remaining-content"/>
            </p>
          </xsl:if>
        </xsl:copy>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-normalize-space">
      <sqf:description>
        <sqf:title>Normalize spacing</sqf:title>
      </sqf:description>
      <sqf:replace match="." use-when="not(*)">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*" mode="customCopy"/>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:copy>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-sentence-case">
      <sqf:description>
        <sqf:title>Change to sentence case</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xsl:apply-templates mode="sentenceCase" select="."/>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-to-preprint-ref" use-when="matches(lower-case(./source[1]),'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra') or matches(pub-id[@pub-id-type='doi'][1],'^10\.(1101|48550|31234|31219|21203|26434|32942|2139|22541)/')">
          <sqf:description>
            <sqf:title>Change to preprint ref</sqf:title>
          </sqf:description>
          <sqf:replace match=".">
            <xsl:copy copy-namespaces="no">
              <xsl:apply-templates select="@*[name()!='publication-type']" mode="customCopy"/>
              <xsl:attribute name="publication-type">preprint</xsl:attribute>
              <xsl:choose>
                <xsl:when test="not(./source) and ./article-title and ./pub-id[@pub-id-type='doi' and normalize-space(.)!='']">
                  <xsl:variable name="doi" select="pub-id[@pub-id-type='doi'][1]"/>
                  <xsl:for-each select="node()">
                    <xsl:choose>
                      <xsl:when test="./name()='article-title'">
                        <article-title xmlns="">
                          <xsl:value-of select="."/>
                        </article-title>
                        <xsl:text>, </xsl:text>
                        <source xmlns="">
                          <xsl:choose>
                            <xsl:when test="matches($doi,'^10\.1101/')">
                              <xsl:text>bioRxiv/medRxiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.48550/')">
                              <xsl:text>arXiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.31234/')">
                              <xsl:text>PsyArXiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.31219/')">
                              <xsl:text>OSF Preprints</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.21203/')">
                              <xsl:text>Research Square</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.26434/')">
                              <xsl:text>ChemRxiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.32942/')">
                              <xsl:text>EcoEvoRxiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.2139/')">
                              <xsl:text>SSRN</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.22541/')">
                              <xsl:text>Authorea</xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                          </xsl:choose>
                        </source>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="./source[not(matches(.,'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra'))] and not(article-title) and not(count(source) gt 1) and ./pub-id[@pub-id-type='doi' and matches(.,'^10\.(1101|48550|31234|31219|21203|26434|32942|2139|22541)/')]">
                  <xsl:variable name="doi" select="pub-id[@pub-id-type='doi'][1]"/>
                  <xsl:for-each select="node()">
                    <xsl:choose>
                      <xsl:when test="./name()='source'">
                        <article-title xmlns="">
                          <xsl:value-of select="."/>
                        </article-title>
                        <xsl:text>, </xsl:text>
                        <source xmlns="">
                          <xsl:choose>
                            <xsl:when test="matches($doi,'^10\.1101/')">
                              <xsl:text>bioRxiv/medRxiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.48550/')">
                              <xsl:text>arXiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.31234/')">
                              <xsl:text>PsyArXiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.31219/')">
                              <xsl:text>OSF Preprints</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.21203/')">
                              <xsl:text>Research Square</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.26434/')">
                              <xsl:text>ChemRxiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.32942/')">
                              <xsl:text>EcoEvoRxiv</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.2139/')">
                              <xsl:text>SSRN</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($doi,'^10\.22541/')">
                              <xsl:text>Authorea</xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                          </xsl:choose>
                        </source>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:apply-templates select="." mode="customCopy"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="node()">
                    <xsl:choose>
                      <xsl:when test="./name()='source'">
                        <xsl:variable name="lc" select="lower-case(.)"/>
                        <xsl:copy copy-namespaces="no">
                          <xsl:apply-templates select="@*" mode="customCopy"/>
                          <xsl:choose>
                            <xsl:when test="matches($lc,'biorxiv')">
                              <xsl:value-of select="'bioRxiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'africarxiv')">
                              <xsl:value-of select="'AfricArXiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'arxiv')">
                              <xsl:value-of select="'arXiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'cell\s+sneak\s+peak')">
                              <xsl:value-of select="'Cell Sneak Peak'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'chemrxiv')">
                              <xsl:value-of select="'ChemRxiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'chinaxiv')">
                              <xsl:value-of select="'ChinaXiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'eartharxiv')">
                              <xsl:value-of select="'EarthArXiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'medrxiv')">
                              <xsl:value-of select="'medRxiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'osf\s+preprints')">
                              <xsl:value-of select="'OSF preprints'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'paleorxiv')">
                              <xsl:value-of select="'PaleorXiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'peerj\s+preprints')">
                              <xsl:value-of select="'PeerJ Preprints'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'preprints\.org')">
                              <xsl:value-of select="'preprints.org'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'psyarxiv')">
                              <xsl:value-of select="'PsyArXiv'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'research\s+square')">
                              <xsl:value-of select="'Research Square'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'scielo\s+preprints')">
                              <xsl:value-of select="'SciELO Preprints'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'ssrn')">
                              <xsl:value-of select="'SSRN'"/>
                            </xsl:when>
                            <xsl:when test="matches($lc,'vixra')">
                              <xsl:value-of select="'viXra'"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:apply-templates select="." mode="customCopy"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:copy>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:apply-templates select="." mode="customCopy"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:copy>
          </sqf:replace>
        </sqf:fix>
  </sqf:fixes>
  <pattern id="award-group-tests-pattern">
    <rule context="funding-group/award-group" id="award-group-tests">
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-2" test="funding-source" role="error" id="award-group-test-2">[award-group-test-2] award-group must contain a funding-source.</assert>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::funding-group/award-group" role="error" id="award-group-tests-xspec-assert">funding-group/award-group must be present.</assert>
    </rule>
  </pattern>
</schema>