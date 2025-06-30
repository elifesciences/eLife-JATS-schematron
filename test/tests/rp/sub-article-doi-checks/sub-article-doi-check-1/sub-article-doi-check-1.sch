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
  <xsl:template match="." mode="customCopy">
    
    <xsl:copy copy-namespaces="no">
      
      <xsl:for-each select="@*">
        <xsl:variable name="default-attributes" select="('toggle')"/>
        <xsl:if test="not(name()=$default-attributes)">
          <xsl:attribute name="{name()}">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates select="*|text()|comment()|processing-instruction()" mode="customCopy"/>
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
                        <given-names>
                <xsl:value-of select="substring-before($author-name,' ')"/>
              </given-names>
                        <xsl:text> </xsl:text>
                        <surname>
                <xsl:value-of select="substring-after($author-name,' ')"/>
              </surname>
                    </string-name>
                </xsl:when>
                <xsl:when test="matches($author-name,'^[\p{L}\p{P}\s’]+\s[\p{Lu}\.]+$')">
                    <string-name xmlns="">
                        <surname>
                <xsl:value-of select="string-join(tokenize($author-name,' ')[position() != last()],' ')"/>
              </surname>
                        <xsl:text> </xsl:text>
                        <given-names>
                <xsl:value-of select="tokenize($author-name,' ')[last()]"/>
              </given-names>
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
  </sqf:fixes>
  <pattern id="sub-article-doi-checks-pattern">
    <rule context="sub-article/front-stub/article-id[@pub-id-type='doi']" id="sub-article-doi-checks">
      <let name="article-version-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi' and @specific-use='version']"/>
      <assert test="matches(.,'^10\.7554/eLife\.\d{5,6}\.\d\.sa\d$')" role="error" id="sub-article-doi-check-1">[sub-article-doi-check-1] The DOI for this sub-article does not match the permitted format: <value-of select="."/>.</assert>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::sub-article/front-stub/article-id[@pub-id-type='doi']" role="error" id="sub-article-doi-checks-xspec-assert">sub-article/front-stub/article-id[@pub-id-type='doi'] must be present.</assert>
    </rule>
  </pattern>
</schema>