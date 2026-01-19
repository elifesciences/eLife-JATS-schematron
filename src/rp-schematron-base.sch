<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:java="http://www.java.com/"
   xmlns:file="java.io.File"
   xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
   xmlns:mml="http://www.w3.org/1998/Math/MathML"
   xmlns:meca="http://manuscriptexchange.org"
   xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
   xmlns:cache="java:org.elifesciences.validator.ApiCache"
   xmlns:xi="http://www.w3.org/2001/XInclude"
   queryBinding="xslt2">
    
    <title>eLife reviewed preprint schematron</title>

    <ns uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
    <ns uri="http://www.w3.org/2001/XInclude" prefix="xi"/>
    <ns uri="http://saxon.sf.net/" prefix="saxon"/>
    <ns uri="http://purl.org/dc/terms/" prefix="dc"/>
    <ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <ns uri="https://elifesciences.org/namespace" prefix="e"/>
    <ns uri="java.io.File" prefix="file"/>
    <ns uri="http://www.java.com/" prefix="java"/>
    <ns uri="java:org.elifesciences.validator.ApiCache" prefix="cache"/>
    <ns uri="http://manuscriptexchange.org" prefix="meca"/>
    <ns uri="http://www.w3.org/2001/XInclude" prefix="xi"/>
    
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
              <xsl:variable name="digit" select="if ($char = 'X') then 10
                                                 else xs:integer($char)"/>
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
    <xsl:if test="translate(string($value), '0123456789', '') = '' and number($value) > 0">
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
  
  <let name="research-organisms" value="'research-organisms.xml'"/>
  <let name="species-regex" value="string-join(doc($research-organisms)//*:organism[@type='species']/@regex,'|')"/>
  <let name="genus-regex" value="string-join(doc($research-organisms)//*:organism[@type='genus']/@regex,'|')"/>
  <let name="org-regex" value="string-join(($species-regex,$genus-regex),'|')"/>
  
  <let name="rors" value="'rors.xml'"/>
  <!-- Grant DOI enabling -->
  <let name="wellcome-funder-ids" value="('http://dx.doi.org/10.13039/100010269','http://dx.doi.org/10.13039/100004440','https://ror.org/029chgv08')"/>
  <let name="known-grant-funder-ids" value="('http://dx.doi.org/10.13039/100000936','http://dx.doi.org/10.13039/501100002241','http://dx.doi.org/10.13039/100000913','http://dx.doi.org/10.13039/501100002428','http://dx.doi.org/10.13039/100000968','https://ror.org/006wxqw41','https://ror.org/00097mb19','https://ror.org/03dy4aq19','https://ror.org/013tf3c58','https://ror.org/013kjyp64')"/>
  <let name="eu-horizon-fundref-ids" value="('http://dx.doi.org/10.13039/100018693','http://dx.doi.org/10.13039/100018694','http://dx.doi.org/10.13039/100018695','http://dx.doi.org/10.13039/100018696','http://dx.doi.org/10.13039/100018697','http://dx.doi.org/10.13039/100018698','http://dx.doi.org/10.13039/100018699','http://dx.doi.org/10.13039/100018700','http://dx.doi.org/10.13039/100018701','http://dx.doi.org/10.13039/100018702','http://dx.doi.org/10.13039/100018703','http://dx.doi.org/10.13039/100018704','http://dx.doi.org/10.13039/100018705','http://dx.doi.org/10.13039/100018706','http://dx.doi.org/10.13039/100018707','http://dx.doi.org/10.13039/100019180','http://dx.doi.org/10.13039/100019185','http://dx.doi.org/10.13039/100019186','http://dx.doi.org/10.13039/100019187','http://dx.doi.org/10.13039/100019188')"/>
  <let name="grant-doi-exception-funder-ids" value="($wellcome-funder-ids,$known-grant-funder-ids,$eu-horizon-fundref-ids)"/>  
  
  <!-- Funders may have internal grant DOIs or indistinct conventions for award IDs
            this function is an attempt to account for this to better match award ids with grant DOIs -->
   <xsl:function name="e:alter-award-id">
    <xsl:param name="award-id-elem" as="xs:string"/>
    <xsl:param name="funder-id" as="xs:string*"/>
    <xsl:choose>
      <!-- Wellcome -->
      <xsl:when test="$funder-id=$wellcome-funder-ids">
        <xsl:value-of select="if (contains(lower-case($award-id-elem),'/z')) then replace(substring-before(lower-case($award-id-elem),'/z'),'[^\d]','') 
        else if (contains(lower-case($award-id-elem),'_z')) then replace(substring-before(lower-case($award-id-elem),'_z'),'[^\d]','')
        else if (matches($award-id-elem,'[^\d]') and matches($award-id-elem,'\d')) then replace($award-id-elem,'[^\d]','')
        else $award-id-elem"/>
      </xsl:when>
      <!-- GBMF -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000936','https://ror.org/006wxqw41')">
        <!-- GBMF grant DOIs are registered like so: GBMF0000 -->
        <xsl:value-of select="if (matches($award-id-elem,'^\d+(\.\d+)?$')) then concat('GBMF',$award-id-elem)
         else if (not(matches(upper-case($award-id-elem),'^GBMF'))) then concat('GBMF',replace($award-id-elem,'[^\d\.]',''))
         else upper-case($award-id-elem)"/>
      </xsl:when>
      <!-- Japan Science and Technology Agency -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/501100002241','https://ror.org/00097mb19')">
        <!-- JSTA grant DOIs are registered like so: GBMF0000 -->
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JPMJ[A-Z0-9]+\s*$') and not(matches(upper-case($award-id-elem),'^JPMJ[A-Z0-9]+$'))) then concat('JPMJ',upper-case(replace(substring-after($award-id-elem,'JPMJ'),'\s+$','')))
        else upper-case($award-id-elem)"/>
      </xsl:when>
      <!-- James S McDonnell Foundation -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000913','https://ror.org/03dy4aq19')">
        <!-- JSMF grant DOIs are registered like so: 220020527, 2020-1543, 99-55, 91-8 -->
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JSMF2\d+$')) then substring-after($award-id-elem,'JSMF')
        else replace($award-id-elem,'[^\d\-]','')"/>
      </xsl:when>
      <!-- Austrian Science Fund -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/501100002428','https://ror.org/013tf3c58')">
        <!-- ASF grant DOIs are registered in many ways: PAT8306623, EFP45, J1974, Z54 -->
        <xsl:value-of select="if (matches($award-id-elem,'\d\-')) then replace(substring-before($award-id-elem,'-'),'[^A-Z\d]','')
        else replace($award-id-elem,'[^A-Z\d]','')"/>
      </xsl:when>
      <!-- American Heart Association -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000968','https://ror.org/013kjyp64')">
        <!-- ASF grant DOIs are registered in many ways: 24CDA1264317, 23SCEFIA1157994, 24POST1187422 -->
        <xsl:value-of select="if (matches($award-id-elem,'[a-z]\s+\([A-Z\d]+\)')) then substring-before(substring-after($award-id-elem,'('),')')
        else $award-id-elem"/>
      </xsl:when>
      <!-- Fundação para a Ciência e a Tecnologia -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000968','https://ror.org/013kjyp64')">
        <!-- FCT grant DOIs are registered in many ways: CEECINST/00152/2018/CP1570/CT0004, DL 57/2016/CP1381/CT0002, 2022.03592.PTDC, PTDC/MED-PAT/0959/2021 -->
        <xsl:value-of select="if (contains(upper-case($award-id-elem),'2020')) then concat('2020',replace(substring-after($award-id-elem,'2020'),'[^A-Z0-9\.]',''))
        else if (contains(upper-case($award-id-elem),'2021')) then concat('2021',replace(substring-after($award-id-elem,'2021'),'[^A-Z0-9\.]',''))
        else if (contains(upper-case($award-id-elem),'2022')) then concat('2022',replace(substring-after($award-id-elem,'2022'),'[^A-Z0-9\.]',''))
        else if (contains(upper-case($award-id-elem),'2023')) then concat('2023',replace(substring-after($award-id-elem,'2023'),'[^A-Z0-9\.]',''))
        else if (contains(upper-case($award-id-elem),'2024')) then concat('2024',replace(substring-after($award-id-elem,'2024'),'[^A-Z0-9\.]',''))
        else if (contains(upper-case($award-id-elem),'CEEC')) then concat('CEEC',replace(substring-after(upper-case($award-id-elem),'CEEC'),'[^A-Z0-9/]',''))
        else if (contains(upper-case($award-id-elem),'PTDC/')) then concat('PTDC/',replace(substring-after(upper-case($award-id-elem),'PTDC/'),'[^A-Z0-9/\-]',''))
        else if (contains(upper-case($award-id-elem),'DL 57/')) then concat('DL 57/',replace(substring-after(upper-case($award-id-elem),'DL 57/'),'[^A-Z0-9/\-]',''))
        else $award-id-elem"/>
      </xsl:when>
      <!-- 
          H2020 European Research Council
          H2020 Marie Skłodowska-Curie Actions
          H2020 LEIT Information and Communication Technologies
          H2020 Innovation In SMEs
          H2020 Health
          H2020 energy
          H2020 Transport
          HORIZON EUROPE Marie Sklodowska-Curie Actions
          HORIZON EUROPE European Research Council
       -->
      <xsl:when test="$funder-id=('https://ror.org/0472cxd90','https://ror.org/00k4n6c32',$eu-horizon-fundref-ids,'http://dx.doi.org/10.13039/100010663','http://dx.doi.org/10.13039/100010665','http://dx.doi.org/10.13039/100010669','http://dx.doi.org/10.13039/100010675','http://dx.doi.org/10.13039/100010677','http://dx.doi.org/10.13039/100010679','http://dx.doi.org/10.13039/100010680','http://dx.doi.org/10.13039/100018694','http://dx.doi.org/10.13039/100019180')">
        <!-- ERC grant DOIs are registered as numbers: 694640, 101002163 -->
        <xsl:value-of select="replace($award-id-elem,'\D','')"/>
      </xsl:when>
      <!-- H2020 European Research Council -->
      <xsl:otherwise>
        <xsl:value-of select="$award-id-elem"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="java:file-exists" xmlns:file="java.io.File" as="xs:boolean">
    <xsl:param name="file" as="xs:string"/>
    <xsl:param name="base-uri" as="xs:string"/>
    
    <xsl:variable name="absolute-uri" select="resolve-uri($file, $base-uri)" as="xs:anyURI"/>
    <xsl:sequence select="file:exists(file:new($absolute-uri))"/>
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
          <xsl:value-of select="concat(
              e:toSentenceCase($token1),
              ' ',
              string-join(for $x in tokenize(substring-after($token2,' '),'\p{Zs}') return e:toLowerCase($x),' ')
              )"/>
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
  
  <xsl:function name="e:analyze-string" as="element()">
    <xsl:param name="node"/>
    <xsl:param name="regex" as="xs:string"/>
    <analyze-string-result>
      <xsl:analyze-string select="$node" regex="{$regex}">
        <xsl:matching-substring>
          <match><xsl:value-of select="."/></match>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <non-match><xsl:value-of select="."/></non-match>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </analyze-string-result>
  </xsl:function>
  
  <xsl:function name="e:org-conform" as="element()">
    <xsl:param name="node" as="node()"/>
    <result>
      <xsl:variable name="species-check-result" select="e:org-conform-helper($node,'species')"/>
      <xsl:choose>
        <xsl:when test="exists($species-check-result)">
          <xsl:sequence select="$species-check-result"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="genus-check-result" select="e:org-conform-helper($node,'genus')"/>
          <xsl:choose>
            <xsl:when test="exists($genus-check-result)">
              <xsl:sequence select="$species-check-result"/>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </result>
  </xsl:function>
  
  <xsl:function name="e:org-conform-helper" as="element()*">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="organism-type" as="xs:string"/>
    <xsl:variable name="s" select="replace(lower-case(string($node)),'drosophila genetic resource center|bloomington drosophila stock center|drosophila genomics resource center','')"/>
    <xsl:for-each select="doc($research-organisms)//*:organism[@type=$organism-type]">
      <xsl:variable name="name" select="."/>
      <xsl:variable name="text-matches">
        <xsl:analyze-string select="$s" regex="{./@regex}">
          <xsl:matching-substring>
            <match><xsl:value-of select="."/></match>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <xsl:variable name="text-count" select="count($text-matches//*:match)"/>
      <xsl:variable name="italic-count" as="xs:integer">
        <xsl:choose>
          <xsl:when test="$node instance of text()">
            <xsl:value-of select="0"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="count($node//*:italic[contains(.,$name)])"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$text-count gt $italic-count">
        <organism text-count="{$text-count}" italic-count="{$italic-count}"><xsl:value-of select="$name"/></organism>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>
  
  <xsl:function name="e:assessment-term-to-number">
      <xsl:param name="term"/>
        <xsl:choose>
          <!-- Strength -->
          <xsl:when test="lower-case($term) = 'inadequate'">
            <xsl:sequence select="-2"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'incomplete'">
            <xsl:sequence select="-1"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'solid'">
            <xsl:sequence select="1"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'convincing'">
            <xsl:sequence select="2"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'compelling'">
            <xsl:sequence select="3"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'exceptional'">
            <xsl:sequence select="4"/>
          </xsl:when>
          <!-- Significance -->
          <xsl:when test="lower-case($term) = 'useful'">
            <xsl:sequence select="1"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'valuable'">
            <xsl:sequence select="2"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'important'">
            <xsl:sequence select="3"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'fundamental'">
            <xsl:sequence select="4"/>
          </xsl:when>
          <xsl:when test="lower-case($term) = 'landmark'">
            <xsl:sequence select="5"/>
          </xsl:when>
          <!-- Default -->
          <xsl:otherwise>
            <xsl:sequence select="-9"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
  
  <!-- ===== QUICK FIXES ===== -->
  
  <!-- Excludes namespace(s) -->
  <xsl:template match="." mode="customCopy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()" mode="customCopy"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Excludes default JATS attributes -->
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
  
  <!-- This is a complete mess but it works ¯\_(ツ)_/¯ -->
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
        <xsl:if test="string-length($author-name) > 0">
            <xsl:choose>
                <xsl:when test="matches($author-name,'^[\p{Lu}\.]+\s[\p{L}\p{P}\s’]+$')">
                    <string-name xmlns="">
                        <xsl:analyze-string select="$author-name" regex="{'^([\p{Lu}\s\.]+)\s+([\p{L}\p{P}\s’]+)$'}">
                            <xsl:matching-substring>
                                <given-names xmlns=""><xsl:value-of select="regex-group(1)"/></given-names>
                                <xsl:text> </xsl:text>
                                <surname xmlns=""><xsl:value-of select="regex-group(2)"/></surname>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </string-name>
                </xsl:when>
                <xsl:when test="matches($author-name,'^[\p{L}\p{P}\s’]+\s[\p{Lu}\.]+$')">
                    <string-name xmlns="">
                        <xsl:analyze-string select="$author-name" regex="{'^([\p{L}\p{P}\s’]+)\s+([\p{Lu}\s\.]+)$'}">
                            <xsl:matching-substring>
                                <surname xmlns=""><xsl:value-of select="regex-group(1)"/></surname>
                                <xsl:text> </xsl:text>
                                <given-names xmlns=""><xsl:value-of select="regex-group(2)"/></given-names>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </string-name>
                </xsl:when>
                <xsl:otherwise>
                    <string-name xmlns="">
                        <surname xmlns=""><xsl:value-of select="$author-name"/></surname>
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
    <xsl:variable name="org-regex" select="string-join(doc('research-organisms.xml')//*:organism/@regex,'|')"/>
    <xsl:choose>
      <xsl:when test="not($nodes)">
        <xsl:apply-templates select="$buffer" mode="customCopy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-node" select="$nodes[1]"/>
        <xsl:variable name="remaining-nodes" select="$nodes[position() > 1]"/>
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
            <xsl:choose>
              <!-- Ignore (full stops in) research organisms when finding first sentence -->
              <xsl:when test="matches(normalize-space(lower-case($current-node)),concat('^',$org-regex,'$'))">
                <xsl:call-template name="get-first-sentence">
                  <xsl:with-param name="nodes" select="$remaining-nodes"/>
                  <xsl:with-param name="buffer" select="$buffer, $current-node"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="inner-result">
                  <xsl:call-template name="get-first-sentence">
                    <xsl:with-param name="nodes" select="$current-node/node()"/>
                    <xsl:with-param name="buffer" select="()"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="found-in-element" select="count($inner-result/*| $inner-result/text()) > 0 and matches(string($inner-result), '.*[\.!?]')"/>
                <xsl:variable name="temp-element">
                  <xsl:element name="{$current-node/name()}" namespace="{$current-node/namespace-uri()}">
                    <xsl:apply-templates select="$current-node/@*" mode="customCopy"/>
                    <xsl:copy-of select="$inner-result/node()"/>
                  </xsl:element>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$found-in-element">
                    <xsl:apply-templates select="$buffer, $temp-element" mode="customCopy"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="get-first-sentence">
                      <xsl:with-param name="nodes" select="$remaining-nodes"/>
                      <xsl:with-param name="buffer" select="$buffer, $temp-element"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
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
    <xsl:variable name="org-regex" select="string-join(doc('research-organisms.xml')//*:organism/@regex,'|')"/>
    <xsl:choose>
      <xsl:when test="not($nodes) and $first-sentence-completed">
        <xsl:apply-templates select="$buffer" mode="customCopy"/>
      </xsl:when>
      <xsl:when test="not($nodes)">
        <xsl:sequence select="()"/> 
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-node" select="$nodes[1]"/>
        <xsl:variable name="remaining-nodes" select="$nodes[position() > 1]"/>
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
                <!-- Ignore (full stops in) research organisms when determining sentences -->
                <xsl:choose>
                  <xsl:when test="matches(normalize-space(lower-case($current-node)),concat('^',$org-regex,'$'))">
                    <xsl:call-template name="get-remaining-sentences">
                      <xsl:with-param name="nodes" select="$remaining-nodes"/>
                      <xsl:with-param name="first-sentence-completed" select="$first-sentence-completed"/>
                      <xsl:with-param name="buffer" select="$buffer"/>
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
                      <xsl:when test="string-length($element-result) > 0">
                        <xsl:variable name="temp-buffer">
                          <xsl:copy-of select="$buffer" copy-namespaces="no"/>
                          <xsl:element name="{$current-node/name()}" namespace="{$current-node/namespace-uri()}">
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

  <xsl:template name="deep-replace">
    <xsl:param name="regex" as="xs:string"/>
    <xsl:param name="nodes"/>
    <xsl:param name="buffer" select="()"/>
    <xsl:choose>
      <xsl:when test="not($nodes)">
        <xsl:apply-templates select="$buffer" mode="customCopy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-node" select="$nodes[1]"/>
        <xsl:variable name="remaining-nodes" select="$nodes[position() > 1]"/>
        <xsl:choose>
          <xsl:when test="$current-node instance of text()">
            <xsl:variable name="fixed-text" select="replace($current-node, $regex, '')"/>
            <xsl:call-template name="deep-replace">
              <xsl:with-param name="regex" select="$regex"/>
              <xsl:with-param name="nodes" select="$remaining-nodes"/>
              <xsl:with-param name="buffer" select="$buffer, $fixed-text"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$current-node instance of element()">
            <xsl:variable name="recurse-result">
              <xsl:call-template name="deep-replace">
                <xsl:with-param name="regex" select="$regex"/>
                <xsl:with-param name="nodes" select="$current-node/node()"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="temp-buffer">
              <xsl:copy-of select="$buffer" copy-namespaces="no"/>
              <xsl:element name="{$current-node/name()}" namespace="{$current-node/namespace-uri()}">
                <xsl:apply-templates select="$current-node/@*" mode="customCopy"/>
                <xsl:sequence select="$recurse-result"/>
              </xsl:element>
            </xsl:variable>
            <xsl:call-template name="deep-replace">
              <xsl:with-param name="regex" select="$regex"/>
              <xsl:with-param name="nodes" select="$remaining-nodes"/> 
              <xsl:with-param name="buffer" select="$temp-buffer/* | $temp-buffer/text()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="deep-replace">
              <xsl:with-param name="regex" select="$regex"/>
              <xsl:with-param name="nodes" select="$remaining-nodes"/>
             <xsl:with-param name="buffer" select="$buffer, $current-node"/>
            </xsl:call-template>
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
        <xref xmlns="" ref-type="fig" rid="dummy"><xsl:apply-templates mode="customCopy" select="node()"/></xref>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-supp-xref">
      <sqf:description>
        <sqf:title>Change to supp xref</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xref xmlns="" ref-type="supplementary-material" rid="dummy"><xsl:apply-templates mode="customCopy" select="node()"/></xref>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="replace-to-ext-link">
      <sqf:description>
        <sqf:title>Change to ext-link</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <ext-link xmlns="" ext-link-type="uri">
          <xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
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
          <xsl:copy-of select="namespace-node()"/>
          <xsl:apply-templates select="@*" mode="customCopy"/>
          <xsl:element name="title">
            <xsl:apply-templates select="p[1]/text()|p[1]/*|p[1]/comment()|p[1]/processing-instruction()" mode="customCopy"/>
          </xsl:element>
          <xsl:text>&#xa;</xsl:text>
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
          <xsl:copy-of select="namespace-node()"/>
          <xsl:apply-templates select="@*" mode="customCopy"/>
          <title xmlns="">
            <xsl:call-template name="get-first-sentence">
              <xsl:with-param name="nodes" select="p/node()"/>
            </xsl:call-template>
          </title>
          <xsl:text>&#xa;</xsl:text>
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
          <xsl:copy-of select="namespace-node()"/>
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
    
    <sqf:fix id="replace-to-preprint-ref" use-when="matches(lower-case(./source[1]),'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra') or matches(pub-id[@pub-id-type='doi'][1],'^10\.(1101|64898|48550|31234|31219|21203|26434|32942|2139|22541)/')">
          <sqf:description>
            <sqf:title>Change to preprint ref</sqf:title>
          </sqf:description>
          <sqf:replace match=".">
            <xsl:copy copy-namespaces="no">
              <xsl:copy-of select="namespace-node()"/>
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
                            <xsl:when test="matches($doi,'^10\.(1101|64898)/')">
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
                <xsl:when test="./source[not(matches(.,'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra'))] and not(article-title) and not(count(source) gt 1) and ./pub-id[@pub-id-type='doi' and matches(.,'^10\.(1101|64898|48550|31234|31219|21203|26434|32942|2139|22541)/')]">
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
                            <xsl:when test="matches($doi,'^10\.(1101|64898)/')">
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
    
    <sqf:fix id="convert-to-confproc">
      <sqf:description>
        <sqf:title>Convert to conference proceedings</sqf:title>
      </sqf:description>
      <sqf:replace match="parent::mixed-citation">
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="namespace-node()"/>
          <xsl:apply-templates select="@*[name()!='publication-type']" mode="customCopy"/>
          <xsl:attribute name="publication-type">confproc</xsl:attribute>
          <xsl:for-each select="node()|comment()|processing-instruction()">
            <xsl:choose>
              <xsl:when test=". instance of element() and name()='chapter-title'">
                <article-title xmlns="">
                  <xsl:apply-templates select="node()" mode="customCopy"/>
                </article-title>
              </xsl:when>
              <xsl:when test=". instance of element() and name()='source'">
                <conf-name xmlns="">
                  <xsl:apply-templates select="node()" mode="customCopy"/>
                </conf-name>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="." mode="customCopy"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:copy>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="move-quote-characters">
      <sqf:description>
        <sqf:title>Move the quotes</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xsl:text>“</xsl:text>
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="namespace-node()"/>
          <xsl:apply-templates select="@*" mode="customCopy"/>
          <xsl:call-template name="deep-replace">
            <xsl:with-param name="regex" select="'[“”&quot;]|\.[“”&quot;]?$'"/>
            <xsl:with-param name="nodes" select="node()"/>
          </xsl:call-template>
        </xsl:copy>
        <xsl:if test="matches(.,'\.[“”&quot;]?$')">
          <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:text>”</xsl:text>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="delete-quote-characters">
      <sqf:description>
        <sqf:title>Delete the quotes</sqf:title>
      </sqf:description>
      <sqf:replace match=".">
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="namespace-node()"/>
          <xsl:apply-templates select="@*" mode="customCopy"/>
          <xsl:call-template name="deep-replace">
            <xsl:with-param name="regex" select="'[“”&quot;]|\.[“”&quot;]?$'"/>
            <xsl:with-param name="nodes" select="node()"/>
          </xsl:call-template>
        </xsl:copy>
        <xsl:if test="matches(.,'\.[“”&quot;]?$')">
          <xsl:text>.</xsl:text>
        </xsl:if>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="add-grant-doi">
      <sqf:description>
        <sqf:title>Replace with grant DOI</sqf:title>
      </sqf:description>
      <sqf:replace match="award-id[1]">
        <xsl:variable name="funder-id" select="parent::award-group/funding-source/institution-wrap/institution-id"/>
        <xsl:variable name="award-id" select="e:alter-award-id(.,$funder-id)"/>
        <award-id xmlns="" award-id-type="doi">
          <xsl:value-of select="document('rors.xml')//*:ror[*:id=$funder-id]/*:grant[@award=$award-id][1]/@doi"/>              
        </award-id>
      </sqf:replace>
    </sqf:fix>
    
    <sqf:fix id="label-to-title">
      <sqf:description>
        <sqf:title>Change label to title</sqf:title>
      </sqf:description>
      <sqf:replace match="label[1]">
        <title><xsl:apply-templates select="node()|comment()|processing-instruction()" mode="customCopy"/></title>
      </sqf:replace>
        </sqf:fix>
  </sqf:fixes>
  

     <pattern id="article">
      <rule context="article[front/journal-meta/lower-case(journal-id[1])='elife']" id="article-tests">
      <!-- exclude ref list and figures from this check -->
      <let name="article-text" value="string-join(for $x in self::*/*[local-name() = 'body' or local-name() = 'back']//*
          return
          if ($x/ancestor::ref-list) then ()
          else if ($x/ancestor::caption[parent::fig] or $x/ancestor::permissions[parent::fig]) then ()
          else $x/text(),'')"/>
      <let name="is-revised-rp" value="if (descendant::article-meta/pub-history/event/self-uri[@content-type='reviewed-preprint']) then true() else false()"/>
        <let name="rp-version" value="replace(descendant::article-meta[1]/article-id[@specific-use='version'][1],'^.*\.','')"/>

       <report test="not($is-revised-rp) and matches(lower-case($article-text),'biorend[eo]r')" 
        role="warning" 
        id="biorender-check-v1">Article text contains a reference to bioRender. Any figures created with bioRender should include a sentence in the caption in the format: "Created with BioRender.com/{figure-code}".</report>
        
        <report test="$is-revised-rp and matches(lower-case($article-text),'biorend[eo]r')" 
        role="warning" 
        id="biorender-check-revised">Article text contains a reference to bioRender. Any figures created with bioRender should include a sentence in the caption in the format: "Created with BioRender.com/{figure-code}". Since this is a revised RP, check to see if the first (or a previous) version had bioRender links.</report>
        
        <assert test="sub-article[@article-type='editor-report']" 
          role="error" 
          id="no-assessment">A Reviewed Preprint must have an eLife Assessment, but this one does not.</assert>
        
        <assert test="sub-article[@article-type='referee-report']" 
          role="error" 
          id="no-public-review">A Reviewed Preprint must have at least one Public Review, but this one does not.</assert>

        <report test="$is-revised-rp and not(sub-article[@article-type='author-comment'])" 
        role="warning" 
        id="no-author-response-1">Revised Reviewed Preprint (version <value-of select="$rp-version"/>) does not have an author response, which is unusual. Is that correct?</report>
        
        <report test="not($is-revised-rp) and (number($rp-version) gt 1) and not(sub-article[@article-type='author-comment'])" 
        role="warning" 
        id="no-author-response-2">Revised Reviewed Preprint (version <value-of select="$rp-version"/>) does not have an author response, which is unusual. Is that correct?</report>
        
        <report test="count(sub-article[@article-type='author-comment']) gt 1" 
        role="error" 
        id="author-response-2">A Reviewed Preprint cannot have more than one author response. This one has <value-of select="count(sub-article[@article-type='author-comment'])"/>.</report>
        
        <report test="count(sub-article[@article-type='editor-report']) gt 1" 
        role="error" 
        id="assessment-2">A Reviewed Preprint cannot have more than one eLife Assessment. This one has <value-of select="count(sub-article[@article-type='author-comment'])"/>.</report>

      </rule>
    </pattern>

    <pattern id="article-title">
     <rule context="article-meta/title-group/article-title" id="article-title-checks">
        <report test=". = upper-case(.)" 
        role="error"
        id="article-title-all-caps">Article title is in all caps - <value-of select="."/>. Please change to sentence case.</report>
       
       <report test="matches(.,'[*¶†‡§¥⁑╀◊♯࿎ł#]$')" 
        role="warning" 
        id="article-title-check-1">Article title ends with a '<value-of select="substring(.,string-length(.))"/>' character: '<value-of select="."/>'. Is this a note indicator? If so, since notes are not supported in EPP, this should be removed.</report>
     </rule>
      
      <rule context="article-meta/title-group/article-title/*" id="article-title-children-checks">
        <let name="permitted-children" value="('italic','sup','sub')"/>
       
        <assert test="name()=$permitted-children" 
          role="error"
          sqf:fix="delete-elem"
          id="article-title-children-check-1"><name/> is not supported as a child of article title. Please remove this element (and any child content, as appropriate).</assert>
        
        <report test="normalize-space(.)=''" 
          role="error"
          sqf:fix="delete-elem"
          id="article-title-children-check-2">Child elements of article-title must contain text content. This <name/> element is empty.</report>
     </rule>
    </pattern>

    <pattern id="author-checks">
     <rule context="article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)]" id="author-contrib-checks">
        <assert test="xref[@ref-type='aff']" 
        role="error" 
        id="author-contrb-no-aff-xref">Author <value-of select="e:get-name(name[1])"/> has no affiliation.</assert>
     </rule>
      
      <rule context="contrib[@contrib-type='author']" id="author-corresp-checks">
        <report test="@corresp='yes' and not(email) and not(xref[@ref-type='corresp'])" 
          role="error" 
          id="author-corresp-no-email">Author <value-of select="e:get-name(name[1])"/> has the attribute corresp="yes", but they do not have a child email element or an xref with the attribute ref-type="corresp".</report>
        
        <report test="not(@corresp='yes') and (email or xref[@ref-type='corresp'])" 
          role="error" 
          id="author-email-no-corresp">Author <value-of select="e:get-name(name[1])"/> does not have the attribute corresp="yes", but they have a child email element or an xref with the attribute ref-type="corresp".</report>
        
        <report test="(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and not(@equal-contrib='yes')" 
          role="error" 
          id="author-equal-contrib-1">Author <value-of select="e:get-name(name[1])"/> does not have the attribute equal-contrib="yes", but they have a child xref element that points to a footnote with the fn-type 'equal'.</report>
        
        <report test="not(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and @equal-contrib='yes'" 
          role="error" 
          id="author-equal-contrib-2">Author <value-of select="e:get-name(name[1])"/> has the attribute equal-contrib="yes", but they do not have a child xref element that points to a footnote with the fn-type 'equal'.</report>
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
		
	  <report test="normalize-space(.)=''" 
        role="error" 
        id="surname-test-2">surname must not be empty.</report>
		
    <report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" 
        role="error" 
        id="surname-test-3">surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	  <assert test="matches(.,&quot;^[\p{L}\p{M}\s'’\.-]*$&quot;)" 
        role="error" 
        id="surname-test-4">surname should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <report test="matches(.,'^\p{Ll}') and not(matches(.,'^de[lrn]? |^van |^von |^el |^te[rn] |^d[ai] '))" 
        role="warning" 
        id="surname-test-5">surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</report>
	  
	  <report test="matches(.,'^\p{Zs}')" 
        role="error" 
        sqf:fix="replace-normalize-space"
        id="surname-test-6">surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\p{Zs}$')" 
        role="error" 
        sqf:fix="replace-normalize-space"
        id="surname-test-7">surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	    
	    <report test="matches(.,'^[A-Z]{1,2}\.?\p{Zs}') and (string-length(.) gt 3)" 
        role="warning" 
        id="surname-test-8">surname looks to start with initial - '<value-of select="."/>'. Should '<value-of select="substring-before(.,' ')"/>' be placed in the given-names field?</report>
	    
	    <report test="matches(.,'[\(\)\[\]]')" 
	      role="warning" 
	      id="surname-test-9">surname contains brackets - '<value-of select="."/>'. Should the bracketed text be placed in the given-names field instead?</report>

      <report test="matches(.,'\s') and not(matches(lower-case(.),'^de[lrn]? |^v[ao]n |^el |^te[rn] |^l[ae] |^zur |^d[ia] '))" 
	      role="warning" 
	      id="surname-test-10">surname contains space(s) - '<value-of select="."/>'. Has it been captured correctly? Should any name be moved to given-names?</report>
	  </rule>

    <rule context="name/given-names" id="given-names-tests">
	   <report test="normalize-space(.)=''" 
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
        sqf:fix="replace-normalize-space"
        id="given-names-test-8">given-names starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
    <report test="matches(.,'\p{Zs}$')" 
        role="error" 
        sqf:fix="replace-normalize-space"
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
		
      <report test="matches(.,'^[\p{Lu}\s]+$')" 
        role="warning" 
        id="given-names-test-16">given-names for author is made up only of uppercase letters (and spaces) '<value-of select="."/>'. Are they initials? Should the authors full given-names be introduced instead?</report>
	   </rule>

    <rule context="contrib-group//name/*" id="name-child-tests">
      <assert test="local-name() = ('surname','given-names','suffix')" 
        role="error" 
        id="disallowed-child-assert"><value-of select="local-name()"/> is not supported as a child of name.</assert>
    </rule>

    <rule context="article/front/article-meta/contrib-group[1]" id="orcid-name-checks">
      <let name="names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="indistinct-names" value="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      <let name="orcids" value="for $x in contrib[@contrib-type='author']/contrib-id[@contrib-id-type='orcid'] return substring-after($x,'orcid.org/')"/>
      <let name="indistinct-orcids" value="for $orcid in distinct-values($orcids) return $orcid[count($orcids[. = $orcid]) gt 1]"/>
      
      <assert test="empty($indistinct-names)" 
        role="warning" 
        id="duplicate-author-test">There is more than one author with the following name(s) - <value-of select="if (count($indistinct-names) gt 1) then concat(string-join($indistinct-names[position() != last()],', '),' and ',$indistinct-names[last()]) else $indistinct-names"/> - which is very likely be incorrect.</assert>
      
      <assert test="empty($indistinct-orcids)" 
        role="error" 
        id="duplicate-orcid-test">There is more than one author with the following ORCiD(s) - <value-of select="if (count($indistinct-orcids) gt 1) then concat(string-join($indistinct-orcids[position() != last()],', '),' and ',$indistinct-orcids[last()]) else $indistinct-orcids"/> - which must be incorrect.</assert>
      
    </rule>
      
     <rule context="contrib-id[@contrib-id-type='orcid']" id="orcid-tests">
       
	     <assert test="matches(.,'^http[s]?://orcid.org/[\d]{4}-[\d]{4}-[\d]{4}-[\d]{3}[0-9X]$')" 
          role="error" 
          id="orcid-test-2">contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL in the format 'https://orcid.org/0000-0000-0000-0000'</assert>
	  
	     <assert test="e:is-valid-orcid(.)" 
          role="error" 
          id="orcid-test-4">contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL. <value-of select="."/> is not a valid ORCID URL.</assert>
		
		</rule>

    <rule context="aff" id="affiliation-checks">
      <let name="id" value="@id"/>
      <let name="country-count" value="count(descendant::country)"/>
      <let name="city-count" value="count(descendant::city)"/>
      
      <report test="$country-count lt 1" 
        role="warning"
        sqf:fix="add-ror-country"
        id="aff-no-country">Affiliation does not contain a country element: <value-of select="."/></report>

      <report test="$country-count gt 1" 
        role="error" 
        id="aff-multiple-country">Affiliation contains more than one country element: <value-of select="string-join(descendant::country,'; ')"/> in <value-of select="."/></report>
      
      <report test="(count(descendant::institution-id) le 1) and $city-count lt 1" 
        role="warning" 
        sqf:fix="add-ror-city"
        id="aff-no-city">Affiliation does not contain a city element: <value-of select="."/></report>

      <report test="$city-count gt 1" 
        role="error" 
        id="aff-city-country">Affiliation contains more than one city element: <value-of select="string-join(descendant::country,'; ')"/> in <value-of select="."/></report>

      <report test="count(descendant::institution) gt 1" 
        role="warning" 
        id="aff-multiple-institution">Affiliation contains more than one institution element: <value-of select="string-join(descendant::institution,'; ')"/> in <value-of select="."/></report>
      
      <report test="count(descendant::institution-id) gt 1" 
        role="error" 
        sqf:fix="pick-aff-ror-1 pick-aff-ror-2 pick-aff-ror-3"
        id="aff-multiple-ids">Affiliation contains more than one institution-id element: <value-of select="string-join(descendant::institution-id,'; ')"/> in <value-of select="."/></report>
      
      <report test="ancestor::article//journal-meta/lower-case(journal-id[1])='elife' and count(institution-wrap) = 0" 
        role="warning" 
        id="aff-no-wrap">Affiliation doesn't have an institution-wrap element (the container for institution name and id). Is that correct?</report>
      
      <report test="institution-wrap[not(institution-id)] and not(ancestor::contrib-group[@content-type='section']) and not(ancestor::sub-article)" 
        role="error" 
        id="aff-has-wrap-no-id">aff contains institution-wrap, but that institution-wrap does not have a child institution-id. institution-wrap should only be used when there is an institution-id for the institution.</report>
      
      <report test="institution-wrap[not(institution)]" 
        role="error" 
        id="aff-has-wrap-no-inst">aff contains institution-wrap, but that institution-wrap does not have a child institution.</report>
      
      <report test="count(descendant::institution-wrap) gt 1" 
        role="error" 
        id="aff-mutliple-wraps">Affiliation contains more than one institution-wrap element: <value-of select="string-join(descendant::institution-wrap/*,'; ')"/> in <value-of select="."/></report>
      
      <assert test="ancestor::contrib-group" 
        role="error" 
        id="aff-ancestor">aff elements must be a descendant of contrib-group. This one is not.</assert>
      
      <assert test="parent::contrib-group or parent::contrib" 
        role="error" 
        id="aff-parent">aff elements must be a child of either contrib-group or contrib. This one is a child of <value-of select="parent::*/name()"/>.</assert>

      <report test="matches(lower-case(.),'(present|current) (address|institution)')" 
        role="error" 
        id="present-address-aff">There is a present address in this affiliation (<value-of select="."/>), it should be added as a present address in the author-notes section instead.</report>
      
      <report test="($id='' or not(@id)) and parent::contrib-group[not(@content-type) and parent::article-meta]" 
        role="error" 
        id="aff-id">aff elements placed within the author contrib-group in article-meta must have an id. This one does not.</report>
      
      <report test="parent::contrib-group[not(@content-type) and parent::article-meta and not(descendant::xref[@rid=$id])]" 
        role="error" 
        id="aff-no-link">Author aff element does not have an xref pointing to it. Either there's a missing link between an author and this affiliation or it should be removed (or changed to an author note if a present address).</report>
      
      <report test="ancestor::contrib-group[@content-type='section'] and not(parent::contrib)" 
        role="error" 
        id="editor-aff-placement">Editor aff elements should be placed as a direct child of the editor contrib element. This one is a child of <value-of select="parent::*/name()"/>.</report>
      
      <sqf:fix id="pick-aff-ror-1">
        <sqf:description>
          <sqf:title>Pick ROR option 1</sqf:title>
        </sqf:description>
        <sqf:delete match="institution-wrap/comment()|
          institution-wrap/institution-id[position() != 1]|
          institution-wrap/text()[following-sibling::institution and position()!=2]"/>
      </sqf:fix>
      
      <sqf:fix id="pick-aff-ror-2">
        <sqf:description>
          <sqf:title>Pick ROR option 2</sqf:title>
        </sqf:description>
        <sqf:delete match="institution-wrap/comment()|
          institution-wrap/institution-id[position() != 2]|
          institution-wrap/text()[following-sibling::institution and position()!=3]"/>
      </sqf:fix>
      
      <sqf:fix id="pick-aff-ror-3" use-when="count(descendant::institution-id) gt 2">
        <sqf:description>
          <sqf:title>Pick ROR option 3</sqf:title>
        </sqf:description>
        <sqf:delete match="institution-wrap/comment()|
          institution-wrap/institution-id[position() != 3]|
          institution-wrap/text()[following-sibling::institution and position()!=4]"/>
      </sqf:fix>
      
      <sqf:fix id="add-ror-city">
        <sqf:description>
          <sqf:title>Add city from ROR record</sqf:title>
        </sqf:description>
        <sqf:replace match="institution-wrap/following-sibling::text()[1]" use-when="institution-wrap[1]/institution-id[@institution-id-type='ror']">
          <xsl:variable name="ror" select="ancestor::aff/institution-wrap[1]/institution-id[@institution-id-type='ror']"/>
          <xsl:variable name="ror-record-city" select="document('rors.xml')//*:ror[*:id=$ror]/*:city/data()"/>
          <xsl:text>, </xsl:text>
          <city xmlns=""><xsl:value-of select="$ror-record-city"/></city>
          <xsl:text>, </xsl:text>
        </sqf:replace>
      </sqf:fix>
      
      <sqf:fix id="add-ror-country">
        <sqf:description>
          <sqf:title>Add country from ROR record</sqf:title>
        </sqf:description>
        <sqf:add match="." position="last-child" use-when="institution-wrap[1]/institution-id[@institution-id-type='ror']">
          <xsl:variable name="ror" select="institution-wrap[1]/institution-id[@institution-id-type='ror'][1]"/>
          <xsl:variable name="ror-record-country" select="document('rors.xml')//*:ror[*:id=$ror]/*:country[1]"/>
          <xsl:if test="not(ends-with(.,', '))">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:element name="country">
            <xsl:attribute name="country">
              <xsl:value-of select="$ror-record-country/@country"/>
            </xsl:attribute>
            <xsl:value-of select="$ror-record-country"/>
          </xsl:element>
        </sqf:add>
      </sqf:fix>
    </rule>
      
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//aff/country" id="country-tests">
      <let name="text" value="self::*/text()"/>
      <let name="countries" value="'countries.xml'"/>
      <let name="city" value="parent::aff/descendant::city[1]"/>
      <let name="valid-country" value="document($countries)/countries/country[text() = $text]"/>
      
      <assert test="$valid-country" 
        role="warning" 
        id="gen-country-test">affiliation contains a country which is not in the list of standardised countriy names - <value-of select="."/>. Is that OK? For a list of allowed countries, refer to https://github.com/elifesciences/eLife-JATS-schematron/blob/master/src/countries.xml.</assert>
      
      <report test="not(@country = $valid-country/@country)" 
        role="warning" 
        id="gen-country-iso-3166-test">country does not have a 2 letter ISO 3166-1 @country value. Should it be @country='<value-of select="$valid-country/@country"/>'?.</report>
      
      <report test="(. = 'Singapore') and ($city != 'Singapore')" 
        role="error" 
        id="singapore-test-1"><value-of select="ancestor::aff/@id"/> has 'Singapore' as its country but '<value-of select="$city"/>' as its city, which must be incorrect.</report>
      
      <report test="(. != 'Taiwan') and  (matches(lower-case($city),'ta[i]?pei|tai\p{Zs}?chung|kaohsiung|taoyuan|tainan|hsinchu|keelung|chiayi|changhua|jhongli|tao-yuan|hualien'))" 
        role="warning" 
        id="taiwan-test">Affiliation has a Taiwanese city - <value-of select="$city"/> - but its country is '<value-of select="."/>'. Please check the original preprint/manuscript. If it has 'Taiwan' as the country in the original manuscript then ensure it is changed to 'Taiwan'.</report>
      
      <report test="(. != 'Republic of Korea') and  (matches(lower-case($city),'chuncheon|gyeongsan|daejeon|seoul|daegu|gwangju|ansan|goyang|suwon|gwanju|ochang|wonju|jeonnam|cheongju|ulsan|inharo|chonnam|miryang|pohang|deagu|gwangjin-gu|gyeonggi-do|incheon|gimhae|gyungnam|muan-gun|chungbuk|chungnam|ansung|cheongju-si'))" 
        role="warning" 
        id="s-korea-test">Affiliation has a South Korean city - <value-of select="$city"/> - but its country is '<value-of select="."/>', instead of 'Republic of Korea'.</report>
      
      <report test="replace(.,'\p{P}','') = 'Democratic Peoples Republic of Korea'" 
        role="warning" 
        id="n-korea-test">Affiliation has '<value-of select="."/>' as its country which is very likely to be incorrect.</report>
    </rule>
      
      <rule context="aff[ancestor::contrib-group[not(@*)]/parent::article-meta]//institution-wrap" id="aff-institution-wrap-tests">
      <let name="display" value="string-join(parent::aff//*[not(local-name()=('label','institution-id','institution-wrap','named-content','city'))],', ')"/>
      
      <assert test="institution-id and institution[not(@*)]" 
        role="error" 
        id="aff-institution-wrap-test-1">If an affiliation has an institution wrap, then it must have both an institution-id and an institution. If there is no ROR for this institution, then it should be captured as a single institution element without institution-wrap. This institution-wrap does not have both elements - <value-of select="$display"/></assert>
      
      <assert test="parent::aff" 
        role="error" 
        id="aff-institution-wrap-test-2">institution-wrap must be a child of aff. This one has <value-of select="parent::*/name()"/> as its parent.</assert>
      
      <report test="count(institution-id)=1 and text()" 
        role="error"
        sqf:fix="delete-comments-and-whitespace"
        id="aff-institution-wrap-test-3">institution-wrap cannot contain text. It can only contain elements.</report>
      
      <assert test="count(institution[not(@*)]) = 1" 
        role="error" 
        id="aff-institution-wrap-test-5">institution-wrap must contain 1 and only 1 institution elements. This one has <value-of select="count(institution[not(@*)])"/>.</assert>
      
      <sqf:fix id="delete-comments-and-whitespace" use-when="comment() or text()">
        <sqf:description>
          <sqf:title>Delete comments and/or whitespace</sqf:title>
        </sqf:description>
        <sqf:delete match=".//comment()|./text()[normalize-space(.)='']"/>
      </sqf:fix>
    </rule>
      
      <rule context="aff//institution-id" id="aff-institution-id-tests">
      
      <assert test="@institution-id-type='ror'" 
        role="error" 
        sqf:fix="add-ror-institution-id-type"
        id="aff-institution-id-test-1">institution-id in aff must have the attribute institution-id-type="ror".</assert>
      
      <assert test="matches(.,'^https?://ror\.org/[a-z0-9]{9}$')" 
        role="error" 
        id="aff-institution-id-test-2">institution-id in aff must a value which is a valid ROR id. '<value-of select="."/>' is not a valid ROR id.</assert>
      
      <report test="*" 
        role="error" 
        id="aff-institution-id-test-3">institution-id in aff cannot contain elements, only text (which is a valid ROR id). This one contains the following element(s): <value-of select="string-join(*/name(),'; ')"/>.</report>
        
      <report test="matches(.,'^http://')" 
        role="error" 
        id="aff-institution-id-test-4">institution-id in aff must use the https protocol. This one uses http - '<value-of select="."/>'.</report>
        
        <sqf:fix id="add-ror-institution-id-type">
          <sqf:description>
            <sqf:title>Add ror institution-id-type attribute</sqf:title>
          </sqf:description>
          <sqf:add target="institution-id-type" node-type="attribute">ror</sqf:add>
        </sqf:fix>
      </rule>
      
      <rule context="aff[count(institution-wrap/institution-id[@institution-id-type='ror'])=1]" id="aff-ror-tests">
      <let name="rors" value="'rors.xml'"/>
      <let name="ror" value="institution-wrap[1]/institution-id[@institution-id-type='ror'][1]"/>
      <let name="matching-ror" value="document($rors)//*:ror[*:id=$ror]"/>
      <let name="display" value="string-join(descendant::*[not(local-name()=('label','institution-id','institution-wrap','named-content','city','country'))],', ')"/>
      
      <assert test="exists($matching-ror)"
        role="error" 
        id="aff-ror">Affiliation (<value-of select="$display"/>) has a ROR id - <value-of select="$ror"/> - but it does not look like a correct one.</assert>
      
      <report test="(city or ancestor::contrib[@contrib-type='author' and not(ancestor::sub-article)]) and exists($matching-ror) and not(contains(city[1],$matching-ror/*:city[1]))"
        role="warning" 
        id="aff-ror-city">Affiliation has a ROR id, but its city is not the same one as in the ROR data. Is that OK? ROR has '<value-of select="$matching-ror/*:city"/>', but the affiliation city is <value-of select="city[1]"/>.</report>
      
      <report test="(country or ancestor::contrib[@contrib-type='author' and not(ancestor::sub-article)]) and exists($matching-ror) and not(contains(country[1],$matching-ror/*:country[1]))"
        role="warning" 
        id="aff-ror-country">Affiliation has a ROR id, but its country is not the same one as in the ROR data. Is that OK? ROR has '<value-of select="$matching-ror/*:country"/>', but the affiliation country is <value-of select="country[1]"/>.</report>
        
      <report test="$matching-ror[@status='withdrawn']"
        role="error" 
        id="aff-ror-status">Affiliation has a ROR id, but the ROR id's status is withdrawn. Withdrawn RORs should not be used. Should one of the following be used instead?: <value-of select="string-join(for $x in $matching-ror/*:relationships/* return concat('(',$x/name(),') ',$x/*:id,' ',$x/*:label),'; ')"/>.</report>
      
    </rule>
    </pattern>
  
  <pattern id="editor-checks">
    <rule context="article/front/article-meta/contrib-group[@content-type='section']" id="test-editor-contrib-group">
      
      <assert test="count(contrib[@contrib-type='senior_editor']) = 1" 
        role="error" 
        id="editor-conformance-1">contrib-group[@content-type='section'] must contain one (and only 1) Senior Editor (contrib[@contrib-type='senior_editor']).</assert>
      
      <assert test="count(contrib[@contrib-type='editor']) = 1" 
        role="warning" 
        id="editor-conformance-2">contrib-group[@content-type='section'] should contain one (and only 1) Reviewing Editor (contrib[@contrib-type='editor']). This one doesn't which is almost definitely incorrect and needs correcting.</assert>
      
    </rule>
    
    <rule context="article/front/article-meta/contrib-group[@content-type='section']/contrib" id="test-editors-contrib">
      <let name="name" value="if (name) then e:get-name(name[1]) else ''"/>
      <let name="role" value="role[1]"/>
      <let name="author-contribs" value="ancestor::article-meta/contrib-group[1]/contrib[@contrib-type='author']"/>
      <let name="matching-author-names" value="for $contrib in $author-contribs return if (e:get-name($contrib/name[1])=$name) then e:get-name($contrib) else ()"/>
      
      <report test="(@contrib-type='senior_editor') and ($role!='Senior Editor')" 
        role="error" 
        id="editor-conformance-3"><value-of select="$name"/> has a @contrib-type='senior_editor' but their role is not 'Senior Editor' (<value-of select="$role"/>), which is incorrect.</report>
      
      <report test="(@contrib-type='editor') and ($role!='Reviewing Editor')" 
        role="error" 
        id="editor-conformance-4"><value-of select="$name"/> has a @contrib-type='editor' but their role is not 'Reviewing Editor' (<value-of select="$role"/>), which is incorrect.</report>

      <assert test="count($matching-author-names)=0" 
        role="error" 
        id="editor-conformance-5"><value-of select="$name"/> is listed both as an author and as a <value-of select="$role"/>, which must be incorrect.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hjuk3-contrib-test-2" 
    	  test="(count(xref[@ref-type='aff']) + count(aff) = 0)" 
        role="warning" 
        id="contrib-test-2">The <value-of select="if (role) then role[1] else 'editor contrib'"/> doesn't have an affiliation - <value-of select="$name"/> - is this correct? Please check eJP or ask Editorial for the correct affiliation to be added in eJP.</report>
      
      <report test="$name=''" 
        role="error" 
        id="editor-check-1">The <value-of select="if (role) then role[1] else 'editor contrib'"/> doesn't have a name element, which must be incorrect. Please check eJP or ask Editorial for the correct affiliation to be added in eJP.</report>
      
    </rule>
  </pattern>

    <pattern id="journal-ref">
     <rule context="mixed-citation[@publication-type='journal']" id="journal-ref-checks">
       <let name="text-regex" value="'^[\p{Z}\p{P}]+((jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\p{Z}?\d?\d?|doi|pmid|epub|vol|no|and|pp?|in|is[sb]n)[:\.]?'"/>
       
        <assert test="source" 
        role="error" 
        id="journal-ref-source">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" 
        role="error" 
        id="journal-ref-article-title">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>
       
        <report test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),$text-regex))]" 
        role="warning" 
        id="journal-ref-text-content">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has untagged textual content - <value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),$text-regex))],'; ')"/>. Is it tagged correctly?</report>
       
       <report test="person-group[@person-group-type='editor']" 
        role="warning" 
        id="journal-ref-editor">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has an editor person-group. This info isn;t typically included in journal refs. Is it really a journal ref? Does it really contain editors?</report>
       
       <report test="(fpage or lpage) and elocation-id" 
        role="error" 
        id="journal-ref-page-elocation-id">This journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has both an elocation-id (<value-of select="elocation-id[1]"/>), and an fpage or lpage (<value-of select="string-join(*[name()=('fpage','lpage')],'; ')"/>), which cannot be correct.</report>
       
       <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-6-7" 
        test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1 or count(comment) gt 1" 
        role="error" 
        id="err-elem-cit-journal-6-7">The following elements may not occur more than once in a &lt;mixed-citation&gt;: &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, and &lt;comment&gt;In press&lt;/comment&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/> &lt;fpage&gt;, <value-of select="count(lpage)"/> &lt;lpage&gt;, <value-of select="count(elocation-id)"/> &lt;elocation-id&gt;, and <value-of select="count(comment)"/> &lt;comment&gt; elements.</report>
     </rule>

     <rule context="mixed-citation[@publication-type='journal']/source" id="journal-source-checks">
      <let name="preprint-regex" value="'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra'"/>
       
       <report test="matches(lower-case(.),$preprint-regex)" 
        role="warning" 
        id="journal-source-1">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source which suggests it might be a preprint - <value-of select="."/>. Is it tagged correctly?</report>
       

       <report test="matches(lower-case(.),'^i{1,3}\.\s') and parent::*/article-title" 
        role="warning" 
        sqf:fix="fix-source-article-title-3"
        id="journal-source-2">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that starts with a roman numeral. Is part of the article-title captured in source? Source = <value-of select="."/>.</report>

       <report test="matches(lower-case(.),'^(symposium|conference|meeting|workshop)\s|\s?(symposium|conference|meeting|workshop)\s?|\s(symposium|conference|meeting|workshop)$')" 
        role="warning" 
        sqf:fix="convert-to-confproc"
        id="journal-source-3">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has the following source, '<value-of select="."/>'. Should it be captured as a conference proceeding instead?</report>
       
       <report test="matches(lower-case(.),'^in[^a-z]')" 
        role="warning" 
        id="journal-source-4">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that starts with 'In ', '<value-of select="."/>'. Should that text be moved out of the source? And is it a different type of reference?</report>
       
       <report test="matches(.,'[“”&quot;]')" 
        role="warning" 
        sqf:fix="delete-quote-characters"
        id="journal-source-5">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains speech quotes - <value-of select="."/>. Is that correct?</report>
       
       <report test="count(tokenize(.,'\.\s')) gt 1 and parent::mixed-citation/article-title and not(matches(lower-case(.),'^i{1,3}\.\s')) and not(matches(lower-case(replace(.,'\.','')),'^((eur|world|scand|jove)?\s?j(pn)?|nat(ure reviews)?|(bio)?phys|proc|sci|annu?|physio(l|ther)|comput|commun|e(c|th)ol|exp|front|hum|phil|clin|theor|infect|trop|(matrix |micro)?biol|(trends |acs )?(bio)?ch[ei]m|vet|int|mult|math|quan?t|(micro)?circ|percept|(acs )?synth|endocr|artif|mem|spat|rheum|hepatol|(cancer )?immunol|semin|oncol|(slas )?discov|sociol|arterioscler|invest|(cell )?rep|vis|philos|(trends )?(cogn|cardiovasc)|rev|bull|(ieee )?trans|(plos )?comp(ut)?|prog|adv|cereb|crit|nucl?|(nar )?genom|emerg|arch|br|eur|transbound|dev|am|curr|psych(o([ln]|som|ther)|iatr)?|(bmc|sleep)?\s?med|(methods|cell |embo )?mo(ti)?l|(brain )?(behav|stim|struct)|(brain|genome|diabetes)?\s?res|(acta )?neur[ao](l|sci|biol|path|psychopharmacol)?|(diabetes )?metab|(methods|trends)\s??ecol|)(\s|$)'))" 
        role="warning"
        sqf:fix="fix-source-article-title"
        id="journal-source-6">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains more than one sentence - <value-of select="."/>. Should some of the content be moved into the article-title?</report>
       
       <report test="count(tokenize(.,'\.\s')) gt 1 and not(parent::mixed-citation/article-title) and not(matches(lower-case(.),'^i{1,3}\.\s'))" 
        role="warning"
        sqf:fix="fix-source-article-title-2"
        id="journal-source-7">Journal reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains more than one sentence - <value-of select="."/>. Should some of the content be moved into a new article-title?</report>
       
       <sqf:fix id="fix-source-article-title">
         <sqf:description>
           <sqf:title>Move first sentence to article title</sqf:title>
         </sqf:description>
         <sqf:replace match="parent::mixed-citation/article-title">
           <xsl:copy copy-namespaces="no">
             <xsl:apply-templates select="@*|node()" mode="customCopy"/>
             <xsl:if test="not(matches(.,'\.\s*$'))">
               <xsl:text>. </xsl:text>
             </xsl:if>
             <xsl:variable name="first-sentence">
               <xsl:call-template name="get-first-sentence">
                 <xsl:with-param name="nodes" select="parent::mixed-citation/source/node()"/>
               </xsl:call-template>
             </xsl:variable>
             <xsl:for-each select="$first-sentence">
               <xsl:choose>
                 <xsl:when test=". instance of text() and matches(.,'\.s*$')">
                   <xsl:value-of select="replace(.,'\.s*$','')"/>
                 </xsl:when>
                 <xsl:otherwise>
                   <xsl:sequence select="."/>
                 </xsl:otherwise>
               </xsl:choose>
             </xsl:for-each>
           </xsl:copy>
         </sqf:replace>
         <sqf:replace match=".">
           <xsl:copy copy-namespaces="no">
             <xsl:apply-templates select="@*" mode="customCopy"/>
             <xsl:call-template name="get-remaining-sentences">
               <xsl:with-param name="nodes" select="node()"/>
             </xsl:call-template>
           </xsl:copy>
         </sqf:replace>
       </sqf:fix>
       
       <sqf:fix id="fix-source-article-title-2">
         <sqf:description>
           <sqf:title>Move first sentence to article title</sqf:title>
         </sqf:description>
         <sqf:replace match=".">
           <article-title xmlns="">
             <xsl:variable name="first-sentence">
               <xsl:call-template name="get-first-sentence">
                 <xsl:with-param name="nodes" select="node()"/>
               </xsl:call-template>
             </xsl:variable>
             <xsl:for-each select="$first-sentence">
               <xsl:choose>
                 <xsl:when test=". instance of text() and matches(.,'\.s*$')">
                   <xsl:value-of select="replace(.,'\.s*$','')"/>
                 </xsl:when>
                 <xsl:otherwise>
                   <xsl:sequence select="."/>
                 </xsl:otherwise>
               </xsl:choose>
             </xsl:for-each>
           </article-title>
           <xsl:text>. </xsl:text>
           <xsl:copy copy-namespaces="no">
             <xsl:apply-templates select="@*" mode="customCopy"/>
             <xsl:call-template name="get-remaining-sentences">
               <xsl:with-param name="nodes" select="node()"/>
             </xsl:call-template>
           </xsl:copy>
         </sqf:replace>
       </sqf:fix>
       
       <sqf:fix id="fix-source-article-title-3">
         <sqf:description>
           <sqf:title>Move content to article title</sqf:title>
         </sqf:description>
         <sqf:replace match="parent::mixed-citation/article-title">
           <xsl:copy copy-namespaces="no">
             <xsl:apply-templates select="@*|node()" mode="customCopy"/>
             <xsl:if test="not(matches(.,'\.\s*$'))">
               <xsl:text>. </xsl:text>
             </xsl:if>
             <xsl:value-of select="string-join(tokenize(parent::mixed-citation/source[1],'\.\s?')[position() le 2],'. ')"/>
           </xsl:copy>
         </sqf:replace>
         <sqf:replace match=".">
           <xsl:copy copy-namespaces="no">
             <xsl:apply-templates select="@*" mode="customCopy"/>
             <xsl:value-of select="string-join(tokenize(.,'\.\s?')[position() ge 3],'. ')"/>
           </xsl:copy>
         </sqf:replace>
       </sqf:fix>
     </rule>
      
      <rule context="mixed-citation[@publication-type='journal']/fpage" id="journal-fpage-checks">
        <report test="parent::mixed-citation[not(issue)] and preceding-sibling::*[1]/name()='volume' and preceding-sibling::node()[1][. instance of text() and matches(.,'^\s*[\.,]?\(\s*$')] and following-sibling::node()[1][. instance of text() and matches(.,'^\s*[\.,]?\)')]" 
        role="warning"
        sqf:fix="replace-fpage-to-issue"
        id="journal-fpage-1">fpage in journal reference (with <value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) is surrounded by brackets and follows the volume. Is it the issue number instead?</report>
        
        <sqf:fix id="replace-fpage-to-issue">
          <sqf:description>
            <sqf:title>Change to issue</sqf:title>
          </sqf:description>
          <sqf:replace match=".">
            <issue xmlns="">
              <xsl:apply-templates select="node()|comment()|processing-instruction()" mode="customCopy"/>
            </issue>
          </sqf:replace>
        </sqf:fix>
      </rule>
    </pattern>

    <pattern id="preprint-ref">
     <rule context="mixed-citation[@publication-type='preprint']" id="preprint-ref-checks">
        <assert test="source" 
        role="error" 
        sqf:fix="replace-to-preprint-ref"
        id="preprint-ref-source">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>

        <assert test="article-title" 
        role="error" 
        id="preprint-ref-article-title">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>

        <report test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))]" 
        role="warning" 
        id="preprint-ref-text-content">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has untagged textual content - <value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))],'; ')"/>. Is it tagged correctly?</report>
       
       <report test="volume" 
        role="error" 
        id="preprint-ref-volume">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a volume - <value-of select="volume"/>. That information is either tagged incorrectly, or the publication-type is wrong.</report>
       
       <report test="lpage" 
        role="error" 
        id="preprint-ref-lpage">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has an lpage element - <value-of select="lpage"/>. That information is either tagged incorrectly, or the publication-type is wrong.</report>
       
       <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-6-7" 
        test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1 or count(comment) gt 1" 
        role="error" 
        id="err-elem-cit-preprint-6-7">The following elements may not occur more than once in a &lt;mixed-citation&gt;: &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, and &lt;comment&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/> &lt;fpage&gt;, <value-of select="count(lpage)"/> &lt;lpage&gt;, <value-of select="count(elocation-id)"/> &lt;elocation-id&gt;, and <value-of select="count(comment)"/> &lt;comment&gt; elements.</report>
       
       <report test="elocation-id and fpage" 
        role="error" 
        id="preprint-ref-fpage-elocation-id">This preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has both fpage (<value-of select="fpage"/>) and elocation-id (<value-of select="elocation-id"/>) elements which must be wrong.</report>
     </rule>
      
      <rule context="mixed-citation[@publication-type='preprint']/source" id="preprint-source-checks">
        <let name="lc" value="lower-case(.)"/>
        <report test="matches($lc,'^(\.\s*)?in[^a-z]')" 
        role="warning" 
        id="preprint-source">Preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that starts with 'In ', '<value-of select="."/>'. Should that text be moved out of the source? And is it a different type of reference?</report>
        
        <report test="matches(.,'[“”&quot;]')" 
        role="warning" 
        sqf:fix="delete-quote-characters"
        id="preprint-source-2">Preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains speech quotes - <value-of select="."/>. Is that correct?</report>
        
        <report test="matches($lc,'biorxiv') and matches($lc,'medrxiv')" 
        role="error" 
        id="preprint-source-3">Preprint reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains both bioRxiv and medRxiv, which must be wrong.</report>
      </rule>
    </pattern>

    <pattern id="book-ref">
     <rule context="mixed-citation[@publication-type='book']" id="book-ref-checks">
        <assert test="source" 
        role="error" 
        id="book-ref-source">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no source element.</assert>
       
       <report test="count(source) gt 1" 
        role="error" 
        id="book-ref-source-2">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has more than 1 source element.</report>
       
       <report test="not(chapter-title) and person-group[@person-group-type='editor']" 
        role="warning" 
        id="book-ref-editor">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has an editor person-group but no chapter-title element. Have all the details been captured correctly?</report>
       
       <report test="chapter-title and not(person-group[@person-group-type='editor'])" 
        role="warning" 
        id="book-ref-editor-2">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a chapter-title but no person-group element with the person-group-type editor. Have all the details been captured correctly?</report>
       
       <report test="not(chapter-title) and publisher-name[italic]" 
        role="warning" 
        id="book-ref-pub-name-1">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a publisher-name with italics and no chapter-title element. Have all the details been captured correctly?</report>
       
       <report test="descendant::article-title" 
        role="error" 
        id="book-ref-article-title">This book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a descendant article-title. This cannot be correct. It should either be a source or chapter-title (or something else entirely).</report>
       
       <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hbbs8-err-elem-cit-book-36-2"
        test="lpage and not (fpage)" 
        role="error" 
        id="err-elem-cit-book-36-2">If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; but not &lt;fpage&gt;.</report>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hgboy-err-elem-cit-book-36-6"
        test="count(lpage) &gt; 1 or count(fpage) &gt; 1" 
        role="error" 
        id="err-elem-cit-book-36-6">At most one &lt;lpage&gt; and one &lt;fpage&gt; are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(lpage)"/> &lt;lpage&gt; elements and <value-of select="count(fpage)"/> &lt;fpage&gt; elements.</report>
     </rule>
      
      <rule context="mixed-citation[@publication-type='book']/source" id="book-ref-source-checks">
        
        <report test="matches(lower-case(.),'^chapter\s|\s+chapter\s+')" 
        role="warning" 
        id="book-source-1">The source in book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) contains 'chapter' - <value-of select="."/>. Are the details captured correctly?</report>
        
        <report test="matches(lower-case(.),'^(\.\s*)?in[^a-z]|\.\s+in:\s+')" 
        role="warning" 
        id="book-source-2">The source in book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) contains 'In: ' - <value-of select="."/>. Are the details captured correctly?</report>

        <report test="matches(lower-case(.),'^(symposium|conference|proc\.|proceeding|meeting|workshop)|\s(symposium|conference|proc\.|proceeding|meeting|workshop)\s|(symposium|conference|proc\.|proceeding|meeting|workshop)$')" 
        role="warning"
        sqf:fix="convert-to-confproc"
        id="book-source-3">Book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has the following source, '<value-of select="."/>'. Should it be captured as a conference proceeding instead?</report>
        
        <report test="matches(.,'[“”&quot;]')" 
        role="warning" 
        sqf:fix="delete-quote-characters"
        id="book-source-4">Book reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has a source that contains speech quotes - <value-of select="."/>. Is that correct?</report>
      </rule>
    </pattern>
  
  <pattern id="confproc-ref">
     <rule context="mixed-citation[@publication-type='confproc']" id="confproc-ref-checks">
        <assert test="conf-name" 
        role="error" 
        id="confproc-ref-conf-name">This conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no conf-name element.</assert>
       
       <report test="count(conf-name) gt 1" 
        role="error" 
        id="confproc-ref-conf-name-2">This conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has more than 1 conf-name element.</report>
       
       <assert test="article-title" 
        role="warning" 
        id="confproc-ref-article-title">This conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) has no article-title element.</assert>
     </rule>
    
    <rule context="mixed-citation[@publication-type='confproc']/conf-name" id="confproc-conf-name-checks">
      <report test="matches(lower-case(.),'^(\.\s*)?in[^a-z]')" 
        role="warning" 
        id="confproc-conf-name">The conf-name in conference reference (<value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>) starts with 'In: ' - <value-of select="."/>. Are the details captured correctly?</report>
    </rule>
  </pattern>

    <pattern id="ref-labels">
     <rule context="ref-list" id="ref-list-checks">
        <let name="labels" value="./ref/label"/>
        <let name="indistinct-labels" value="for $label in distinct-values($labels) return $label[count($labels[. = $label]) gt 1]"/>
        <assert test="empty($indistinct-labels)" 
          role="error" 
          id="indistinct-ref-labels">Duplicate labels in reference list - <value-of select="string-join($indistinct-labels,'; ')"/>. Have there been typesetting errors?</assert>

        <report test="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')] and ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))]" 
          role="warning" 
          id="ref-label-types">This ref-list has labels in the format '<value-of select="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')][1]"/>' as well as labels in the format '<value-of select="ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))][1]"/>'. Is that correct?</report>
       
       <report test="parent::back and preceding-sibling::ref-list[parent::back]" 
        role="warning" 
        id="multiple-ref-list">This is the <value-of select="e:get-ordinal(count(preceding-sibling::ref-list[parent::back]) + 1)"/> reference list that is a child of back, which is possibly incorrect. Most commonly <value-of select="e:get-ordinal(count(preceding-sibling::ref-list[parent::back]) + 1)"/> reference list would be included within a appendix or methods section. Is there an appendix that this should be placed?</report>
     </rule>

      <rule context="ref-list[ref/label[matches(.,'^\p{P}*\d+\p{P}*$')] and not(ref/label[not(matches(.,'^\p{P}*\d+\p{P}*$'))])]/ref[label]" id="ref-numeric-label-checks">
        <let name="numeric-label" value="number(replace(./label[1],'[^\d]',''))"/>
        <let name="pos" value="count(parent::ref-list/ref[label]) - count(following-sibling::ref[label])"/>
        <assert test="$numeric-label = $pos" 
          role="warning" 
          id="ref-label-1">ref with id <value-of select="@id"/> has the label <value-of select="$numeric-label"/>, but according to its position it should be labelled as number <value-of select="$pos"/>. Has there been a processing error?</assert>
     </rule>

      <rule context="ref-list[ref/label]/ref" id="ref-label-checks">
        <report test="not(label) and not(contains(@id,'dataref')) and (preceding-sibling::ref[label] or following-sibling::ref[label])" 
          role="warning" 
          id="ref-label-2">ref with id <value-of select="@id"/> doesn't have a label, but other refs within the same ref-list do. Has there been a processing error?</report>
     </rule>
    </pattern>

     <pattern id="ref-year">
      <rule context="ref//year" id="ref-year-checks">
        <report test="matches(.,'\d') and not(matches(.,'^\d{4}[a-z]?$'))"
          role="error" 
          id="ref-year-value-1">Ref with id <value-of select="ancestor::ref/@id"/> has a year element with the value '<value-of select="."/>' which contains a digit (or more) but is not a year.</report>

        <assert test="matches(.,'\d')"
          role="warning" 
          id="ref-year-value-2">Ref with id <value-of select="ancestor::ref/@id"/> has a year element which does not contain a digit. Is it correct? (it's acceptable for this element to contain 'no date' or equivalent non-numerical information relating to year of publication)</assert>
        
        <report test="matches(.,'^\d{4}[a-z]?$') and number(replace(.,'[^\d]','')) lt 1800"
          role="warning" 
          id="ref-year-value-3">Ref with id <value-of select="ancestor::ref/@id"/> has a year element which is less than 1800, which is almost certain to be incorrect: <value-of select="."/>.</report>
     </rule>
     </pattern>

    <pattern id="ref-names">
      <rule context="mixed-citation//name | mixed-citation//string-name" id="ref-name-checks">
        <assert test="surname" 
        role="error" 
        id="ref-surname"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) does not have a surname element.</assert>
        
        <report test="name()='string-name' and text()[not(matches(.,'^[\s\p{P}]*$'))]" 
        role="error" 
        id="ref-string-name-text"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) has child text containing content. This content should either be tagged or moved into a different appropriate tag, as appropriate.</report>
     </rule>

      <rule context="mixed-citation//given-names | mixed-citation//surname" id="ref-name-space-checks">
        <report test="matches(.,'^\p{Z}+')" 
          role="error"
          sqf:fix="replace-normalize-space"
          id="ref-name-space-start"><name/> element cannot start with space(s). This one (in ref with id=<value-of select="ancestor::ref/@id"/>) does: '<value-of select="."/>'.</report>

        <report test="matches(.,'\p{Z}+$')" 
          role="error"
          sqf:fix="replace-normalize-space"
          id="ref-name-space-end"><name/> element cannot end with space(s). This one (in ref with id=<value-of select="ancestor::ref/@id"/>) does: '<value-of select="."/>'.</report>
        
        <report test="normalize-space(.)=''" 
          role="error" 
          id="ref-name-empty"><name/> element must not be empty.</report>
     </rule>
    </pattern>

    <pattern id="collab">
      <rule context="collab" id="collab-checks">
        <report test="matches(.,'^\p{Z}+')" 
        role="error" 
        sqf:fix="replace-normalize-space"
        id="collab-check-1">collab element cannot start with space(s). This one does: <value-of select="."/></report>

        <report test="matches(.,'\p{Z}+$')" 
        role="error" 
        sqf:fix="replace-normalize-space"
        id="collab-check-2">collab element cannot end with space(s). This one does: <value-of select="."/></report>

        <assert test="normalize-space(.)=." 
        role="warning" 
        sqf:fix="replace-normalize-space"
        id="collab-check-3">collab element seems to contain odd spacing. Is it correct? '<value-of select="."/>'</assert>
        
        <report test="matches(.,'^[\p{Z}\p{N}\p{P}]*$')" 
        role="warning" 
        id="collab-check-4">collab element consists only of spaces, punctuation and/or numbers (or is empty) - '<value-of select="."/>'. Is it really a collab?</report>
        
        <report test="contains(.,',') and contains(.,'.') or count(tokenize(.,',')) gt 2" 
        role="warning" 
        sqf:fix="replace-collab-to-string-name"
        id="collab-check-5">collab element contains '<value-of select="."/>'. Is it really a collab?</report>
        
        <sqf:fix id="replace-collab-to-string-name">
          <sqf:description>
            <sqf:title>Change to string name</sqf:title>
          </sqf:description>
          <sqf:replace match=".">
            <xsl:call-template name="tag-author-list">
              <xsl:with-param name="author-string" select="."/>
            </xsl:call-template>
          </sqf:replace>
        </sqf:fix>
     </rule>
    </pattern>

    <pattern id="ref-etal">
      <rule context="mixed-citation[person-group]//etal" id="ref-etal-checks">
        <assert test="parent::person-group" 
        role="error" 
        id="ref-etal-1">If the etal element is included in a reference, and that reference has a person-group element, then the etal should also be included in the person-group element. But this one is a child of <value-of select="parent::*/name()"/>.</assert>
     </rule>
    </pattern>

    <pattern id="ref-comment">
      <rule context="comment" id="ref-comment-checks">
        <report test="ancestor::mixed-citation" 
        role="warning" 
        id="ref-comment-1">Reference (with id=<value-of select="ancestor::ref/@id"/>) contains a comment element. Is this correct? <value-of select="."/></report>
     </rule>
    </pattern>

    <pattern id="ref-pub-id">
      <rule context="ref//pub-id" id="ref-pub-id-checks">
        <report test="@pub-id-type='doi' and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))" 
        role="error" 
        id="ref-doi-conformance">&lt;pub-id pub-id="doi"> in reference (id=<value-of select="ancestor::ref/@id"/>) does not contain a valid DOI: '<value-of select="."/>'.</report>
        
        <report test="(@pub-id-type='pmid') and not(matches(.,'^\d{3,10}$'))" 
        role="error" 
        id="ref-pmid-conformance">pub-id is tagged as a pmid, but it is not a number made up of between 3 and 10 digits - <value-of select="."/>. The id must be either incorrect or have the wrong pub-id-type.</report>
        
        <report test="(@pub-id-type='pmcid') and not(matches(.,'^PMC[0-9]{5,15}$'))" 
        role="error" 
        id="ref-pmcid-conformance">pub-id is tagged as a pmcid, but it is not a valid PMCID ('PMC' followed by 5+ digits) - <value-of select="."/>. The id must be either incorrect or have the wrong pub-id-type.</report>
        
        <report test="(@pub-id-type='arxiv') and not(matches(.,'^(\d{2}(0[1-9]|1[0-2])\.\d{4,5}|\d{2}(0[1-9]|1[0-2])\d{3})$'))" 
        role="error" 
        id="ref-arxiv-conformance">pub-id is tagged as an arxiv id, but it is not a valid arxiv id (a number in the format yymm.nnnnn or yymmnnn) - <value-of select="."/>. The id must be either incorrect or have the wrong pub-id-type.</report>
      
        <assert test="@pub-id-type" 
          role="error" 
          id="pub-id-check-1"><name/> does not have a pub-id-type attribute.</assert>

        <report test="ancestor::mixed-citation[@publication-type='journal'] and not(@pub-id-type=('doi','pmid','pmcid','issn'))" 
          role="error" 
          id="pub-id-check-2"><name/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','issn'.</report>

        <report test="ancestor::mixed-citation[@publication-type='book'] and not(@pub-id-type=('doi','pmid','pmcid','isbn'))" 
          role="error" 
          id="pub-id-check-3"><name/> is within a book reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','isbn'.</report>

        <report test="ancestor::mixed-citation[@publication-type='preprint'] and not(@pub-id-type=('doi','pmid','pmcid','arxiv'))" 
          role="error" 
          id="pub-id-check-4"><name/> is within a preprint reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','arxiv'.</report>

        <report test="ancestor::mixed-citation[@publication-type='web']" 
          role="error" 
          id="pub-id-check-5">Web reference (with id <value-of select="ancestor::ref/@id"/>) has a <name/> <value-of select="if (@pub-id-type) then concat(' with a pub-id-type ',@pub-id-type) else 'with no pub-id-type'"/> (<value-of select="."/>). This must be incorrect. Either the publication-type for the reference needs changing, or the pub-id should be changed to another element.</report>
        
        <report test="@pub-id-type='doi' and ancestor::mixed-citation[@publication-type=('journal','book','preprint')] and matches(following-sibling::text()[1],'^[\.\s]?[\.\s]?[/&lt;&gt;:\d\+\-]')" 
          role="warning" 
          id="pub-id-check-6">doi in <value-of select="ancestor::mixed-citation/@publication-type"/> ref is followd by text - '<value-of select="following-sibling::text()[1]"/>'. Should that text be part of the DOI or tagged in some other way?</report>

        <report test="@pub-id-type='doi' and matches(lower-case(.),'file|figure|table')" 
          role="warning" 
          id="doi-superfluous">This DOI (<value-of select="."/>) looks like it relates to supplementary material instead of an overall article. Should this be changed to the article DOI instead?</report>
     </rule>

      <rule context="ref//pub-id[@pub-id-type='isbn']|isbn" id="isbn-conformity">
        <let name="t" value="translate(.,'-','')"/>
      
        <assert test="e:is-valid-isbn($t)" 
          role="error" 
          id="isbn-conformity-test"><name/> element contains an invalid ISBN - '<value-of select="."/>'. Should it be captured as another type of id?</assert>
      </rule>
      
      <rule context="ref//pub-id[@pub-id-type='issn']|issn" id="issn-conformity">
        <assert test="e:is-valid-issn(.)" 
          role="error" 
          id="issn-conformity-test"><name/> element contains an invalid ISSN - '<value-of select="."/>'. Should it be captured as another type of id?</assert>
      </rule>
    </pattern>

    <pattern id="ref-person-group">
      <rule context="ref//person-group" id="ref-person-group-checks">
      
        <assert test="normalize-space(@person-group-type)!=''" 
          role="error" 
          id="ref-person-group-type"><name/> must have a person-group-type attribute with a non-empty value.</assert>
        
        <report test="./@person-group-type = preceding-sibling::person-group/@person-group-type" 
          role="warning" 
          id="ref-person-group-type-2"><name/>s within a reference should be distinct. There are numerous person-groups with the person-group-type <value-of select="@person-group-type"/> within this reference (id=<value-of select="ancestor::ref/@id"/>).</report>
        
        <report test="ancestor::mixed-citation[@publication-type='book'] and not(normalize-space(@person-group-type)=('','author','editor'))" 
          role="warning" 
          id="ref-person-group-type-book">This <name/> inside a book reference has the person-group-type '<value-of select="@person-group-type"/>'. Is that correct?</report>
        
        <report test="ancestor::mixed-citation[@publication-type=('journal','data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')] and not(normalize-space(@person-group-type)=('','author'))" 
          role="warning" 
          id="ref-person-group-type-other">This <name/> inside a <value-of select="ancestor::mixed-citation/@publication-type"/> reference has the person-group-type '<value-of select="@person-group-type"/>'. Is that correct?</report>
        
        <assert test="collab or string-name or name" 
          role="error" 
          id="ref-person-group-type-content"><name/> must contain at least one collab, string-name or name element. This one (within reference id=<value-of select="ancestor::ref/@id"/>) does not.</assert>
     </rule>
    </pattern>
  
    <pattern id="ref">
      <rule context="ref" id="ref-checks">
        <assert test="mixed-citation or element-citation" 
        role="error" 
        id="ref-empty"><name/> does not contain either a mixed-citation or an element-citation element.</assert>
        
        <assert test="normalize-space(@id)!=''" 
        role="error" 
        id="ref-id"><name/> must have an id attribute with a non-empty value.</assert>
        
        <assert test="mixed-citation or element-citation" 
        role="error" 
        id="ref-no-citations"><name/> must contain a child mixed-citation or element-citation. This one (with id=<value-of select="@id"/>) does not.</assert>

        <report test="(count(mixed-citation) + count(element-citation)) gt 1" 
        role="error" 
        sqf:fix="replace-to-distinct-refs"
        id="ref-extra-citations"><name/> cannot contain more that one citation element (mixed-citation or element-citation). This one (with id=<value-of select="ancestor::ref/@id"/>) has <value-of select="count(mixed-citation) + count(element-citation)"/>.</report>
        
        <sqf:fix id="replace-to-distinct-refs">
          <sqf:description>
            <sqf:title>Capture each mixed-citation in its own ref</sqf:title>
          </sqf:description>
          <sqf:replace match=".">
            <xsl:variable name="ref-id" select="./@id"/>
            <xsl:variable name="ref-label" select="normalize-space(./label[1])"/>
            <xsl:copy>
              <xsl:apply-templates select="@*|label|*[name()=('mixed-citation','element-citation')][1]" mode="customCopy"/>
            </xsl:copy>
            <xsl:for-each select="./*[name()=('mixed-citation','element-citation')][position() gt 1]">
              <xsl:variable name="letter" select="codepoints-to-string(xs:integer(96 + number(position())))"/>
              <xsl:text>&#xa;</xsl:text> 
              <ref xmlns="">
                <xsl:attribute name="id" select="concat($ref-id,$letter)"/>
                <xsl:if test="matches($ref-label,'^\d+\.?$')">
                  <label xmlns="">
                    <xsl:value-of select="concat(replace($ref-label,'\D',''),$letter,'.')"/>
                  </label>
                </xsl:if>
                 <xsl:copy copy-namespaces="no">
                   <xsl:apply-templates select="@*[name()!='id']|*|text()|processing-instruction()|comment()" mode="customCopy"/>
                 </xsl:copy>
               </ref>
            </xsl:for-each>
          </sqf:replace>
        </sqf:fix>
     </rule>
      
      <rule context="ref/*" id="ref-child-checks">
        <let name="allowed-children" value="('label','mixed-citation','element-citation')"/>
        
        <assert test="name()=$allowed-children" 
        role="error" 
        id="ref-child"><name/> is not supported in ref. Only the following elements are permittted: <value-of select="string-join($allowed-children,'; ')"/>.</assert>
        
        <report test="name()='element-citation'" 
        role="warning" 
        id="ref-element-citation">mixed-citation is typically used for references in Reviewed preprints instead of <name/>. Please check this refeerence displays as corrceted.</report>
      </rule>
    </pattern>
  
  <pattern id="ref-article-title">
      <rule context="ref//article-title" id="ref-article-title-checks">
        <report test="matches(.,'^\s*[“”&quot;]|[“”&quot;]\.*$')" 
          role="warning" 
          sqf:fix="move-quote-characters delete-quote-characters"
          id="ref-article-title-1"><name/> in ref starts or ends with speech quotes - <value-of select="."/>. Is that correct?.</report>
        
        <report test="upper-case(.)=." 
          role="warning" 
          sqf:fix="replace-sentence-case"
          id="ref-article-title-2"><name/> in ref is entirely in upper case - <value-of select="."/>. Is that correct?</report>
        
        <report test="matches(.,'\?[^\s\p{P}]')" 
          role="warning" 
          id="ref-article-title-3"><name/> in ref contains a question mark which may potentially be the result of a processing error - <value-of select="."/>. Should it be repalced with other characters?</report>
        
        <report test="matches(.,'\p{Ps}') and not(matches(.,'\p{Pe}'))" 
          role="warning" 
          id="ref-article-title-4"><name/> in ref contains an opening bracket - <value-of select="replace(.,'[^\p{Ps}]','')"/> - but it does not contain a closing bracket. Is that correct?</report>
        
        <report test="matches(.,'\p{Pe}') and not(matches(.,'\p{Ps}'))" 
          role="warning" 
          id="ref-article-title-5"><name/> in ref contains a closing bracket - <value-of select="replace(.,'[^\p{Pe}]','')"/> - but it does not contain an opening bracket. Is that correct?</report>

        <report test="contains(lower-case(.),'[internet]')" 
          role="warning" 
          id="article-title-internet">This title includes the text '[I(i)nternet]'. This is probably superfluous and should be deleted.</report>
      </rule>
  </pattern>
  
  <pattern id="ref-chapter-title">
      <rule context="ref//chapter-title" id="ref-chapter-title-checks">
        <report test="matches(.,'^\s*[“”&quot;]|[“”&quot;]\.*$')" 
          role="warning" 
          sqf:fix="move-quote-characters delete-quote-characters"
          id="ref-chapter-title-1"><name/> in ref starts or ends with speech quotes - <value-of select="."/>. Is that correct?.</report>
        
        <report test="matches(.,'\?[^\s\p{P}]')" 
          role="warning" 
          id="ref-chapter-title-2"><name/> in ref contains a question mark which may potentially be the result of a processing error - <value-of select="."/>. Should it be repalced with other characters?</report>
        
        <report test="matches(.,'\p{Ps}') and not(matches(.,'\p{Pe}'))" 
          role="warning" 
          id="ref-chapter-title-3"><name/> in ref contains an opening bracket - <value-of select="replace(.,'[^\p{Ps}]','')"/> - but it does not contain a closing bracket. Is that correct?</report>
        
        <report test="matches(.,'\p{Pe}') and not(matches(.,'\p{Ps}'))" 
          role="warning" 
          id="ref-chapter-title-4"><name/> in ref contains a closing bracket - <value-of select="replace(.,'[^\p{Pe}]','')"/> - but it does not contain an opening bracket. Is that correct?</report>

        <report test="contains(lower-case(.),'[internet]')" 
          role="warning" 
          id="chapter-title-internet">This title includes the text '[I(i)nternet]'. This is probably superfluous and should be deleted.</report>
      </rule>
  </pattern>
  
  <pattern id="ref-source">
      <rule context="ref//source" id="ref-source-checks">
        <report test="matches(.,'\?[^\s\p{P}]')" 
          role="warning" 
          id="ref-source-1"><name/> in ref contains a question mark which may potentially be the result of a processing error - <value-of select="."/>. Should it be repalced with other characters?</report>
        
        <report test="matches(.,'\p{Ps}') and not(matches(.,'\p{Pe}'))" 
          role="warning" 
          id="ref-source-2"><name/> in ref contains an opening bracket - <value-of select="replace(.,'[^\p{Ps}]','')"/> - but it does not contain a closing bracket. Is that correct?</report>
        
        <report test="matches(.,'\p{Pe}') and not(matches(.,'\p{Ps}'))" 
          role="warning" 
          id="ref-source-3"><name/> in ref contains a closing bracket - <value-of select="replace(.,'[^\p{Pe}]','')"/> - but it does not contain an opening bracket. Is that correct?</report>

        <report test="contains(lower-case(.),'[internet]')" 
          role="warning" 
          id="source-internet">This source includes the text '[I(i)nternet]'. This is probably superfluous and should be deleted.</report> 
        </rule>
  </pattern>
  
    <pattern id="mixed-citation">
      <rule context="mixed-citation" id="mixed-citation-checks">
        <let name="publication-type-values" value="('journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')"/>
        <let name="name-elems" value="('name','string-name','collab','on-behalf-of','etal')"/>
        
        <report test="normalize-space(.)=('','.')" 
          role="error" 
          id="mixed-citation-empty-1"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) is empty.</report>
        
        <report test="not(normalize-space(.)=('','.')) and (string-length(normalize-space(.)) lt 6)" 
          role="warning" 
          id="mixed-citation-empty-2"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) only contains <value-of select="string-length(normalize-space(.))"/> characters.</report>
        
        <assert test="normalize-space(@publication-type)!=''" 
          role="error"
          sqf:fix="replace-to-preprint-ref"
          id="mixed-citation-publication-type-presence"><name/> must have a publication-type attribute with a non-empty value.</assert>
        
        <report test="normalize-space(@publication-type)!='' and not(@publication-type=$publication-type-values)" 
          role="warning"
          sqf:fix="replace-to-preprint-ref"
          id="mixed-citation-publication-type-flag"><name/> has publication-type="<value-of select="@publication-type"/>" which is not one of the known/supported types: <value-of select="string-join($publication-type-values,'; ')"/>.</report>
        
        <report test="@publication-type='other'" 
          role="warning" 
          sqf:fix="replace-to-preprint-ref"
          id="mixed-citation-other-publication-flag"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) has a publication-type='other'. Is that correct?</report>

        <report test="*[name()=$name-elems]" 
          role="error" 
          id="mixed-citation-person-group-flag-1"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) has child name elements (<value-of select="string-join(distinct-values(*[name()=$name-elems]/name()),'; ')"/>). These all need to be placed in a person-group element with the appropriate person-group-type attribute.</report>

        <assert test="person-group[@person-group-type='author']" 
          role="warning" 
          id="mixed-citation-person-group-flag-2"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) does not have an author person-group. Is that correct?</assert>
        
        <report test="parent::ref/label[.!=''] and starts-with(.,parent::ref[1]/label[1])" 
          role="error" 
          id="mixed-citation-label"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) starts with the reference label.</report>
      </rule>
      
      <rule context="mixed-citation/*" id="mixed-citation-child-checks">
        <report test="normalize-space(.)=''" 
          role="error" 
          id="mixed-citation-child-1"><name/> in reference (id=<value-of select="ancestor::ref/@id"/>) is empty, which cannot be correct.</report>
      </rule>
    </pattern>
  
  <pattern id="comment">
      <rule context="comment" id="comment-checks">
        <assert test="parent::mixed-citation"
          role="error" 
          id="comment-1"><name/> is only supported within mixed-citation, but this one is in <value-of select="parent::*/name()"/>.</assert>
        
        <assert test="matches(lower-case(.),'^((in|under) (preparation|press|review)|submitted)$')"
          role="warning" 
          id="comment-2"><name/> contains the content '<value-of select="."/>'. Is the tagging correct?</assert>
      </rule>
  </pattern>

    <pattern id="back">
      <rule context="back" id="back-tests">

       <assert test="ref-list" 
        role="error" 
        id="no-ref-list">This preprint has no reference list (as a child of back), which must be incorrect.</assert>
      </rule>
    </pattern>
  
  <pattern id="ack">
      <rule context="ack" id="ack-tests">
       <assert test="*[not(name()=('label','title'))]" 
        role="error"
        sqf:fix="delete-elem"
        id="ack-no-content">Acknowledgements doesn't contain any content. Should it be removed?</assert>
        
        <report test="preceding::ack" 
        role="warning"
        sqf:fix="delete-elem"
        id="ack-dupe">This ack element follows another one. Should there really be more than one Acknowledgements?</report>

        <report test="not(title[1][.='Acknowledgements'])" 
          role="error" 
          id="ack-misspelled">[ack-misspelled] The Acknowledgements section is misspelled, please correct.</report>
      </rule>
    </pattern>

    <pattern id="strike">
     <rule context="strike" id="strike-checks">
        <report test="." 
        role="warning" 
        sqf:fix="strip-tags"
        id="strike-warning">strike element is present. Is this tracked change formatting that's been erroneously retained? Should this text be deleted?</report>
     </rule>
    </pattern>

    <pattern id="underline">
     <rule context="underline" id="underline-checks">
        <report test="string-length(.) gt 20" 
        role="warning" 
        sqf:fix="strip-tags"
        id="underline-warning">underline element contains more than 20 characters. Is this tracked change formatting that's been erroneously retained?</report>
      
        <report test="matches(lower-case(.),'www\.|(f|ht)tp|^link\s|\slink\s')" 
        role="warning" 
        sqf:fix="replace-to-ext-link strip-tags"
        id="underline-link-warning">Should this underline element be a link (ext-link) instead? <value-of select="."/></report>

        <report test="replace(.,'[\s\.]','')='&gt;'" 
        role="warning" 
        sqf:fix="add-ge-symbol strip-tags"
        id="underline-gt-warning">underline element contains a greater than symbol (<value-of select="."/>). Should this a greater than or equal to symbol instead (&#x2265;)?</report>

        <report test="replace(.,'[\s\.]','')='&lt;'" 
        role="warning" 
        sqf:fix="add-le-symbol strip-tags"
        id="underline-lt-warning">underline element contains a less than symbol (<value-of select="."/>). Should this a less than or equal to symbol instead (&#x2264;)?</report>
       
        <report test="not(ancestor::sub-article) and matches(.,'(^|\s)[Ff]ig(\.|ure)?')"
          role="warning" 
          sqf:fix="replace-fig-xref replace-supp-xref strip-tags"
          id="underline-check-1">Content of underline element suggests it's intended to be a figure citation: <value-of select="."/>. Either replace it with an xref or remove the underline formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|\s)([Tt]able|[Tt]bl)[\.\s]')"
          role="warning" 
          sqf:fix="replace-fig-xref replace-supp-xref strip-tags"
          id="underline-check-2">Content of underline element suggests it's intended to be a table or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the underline formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|\s)([Vv]ideo|[Mm]ovie)')"
          role="warning"
          sqf:fix="replace-fig-xref replace-supp-xref strip-tags"
          id="underline-check-3">Content of underline element suggests it's intended to be a video or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the underline formatting, as appropriate.</report>
       
       <sqf:fix id="add-ge-symbol">
         <sqf:description>
           <sqf:title>Change to ≥</sqf:title>
         </sqf:description>
         <sqf:replace match=".">
           <xsl:text>&#x2265;</xsl:text>
         </sqf:replace>
       </sqf:fix>
       
       <sqf:fix id="add-le-symbol">
         <sqf:description>
           <sqf:title>Change to ≤</sqf:title>
         </sqf:description>
         <sqf:replace match=".">
           <xsl:text>&#x2264;</xsl:text>
         </sqf:replace>
       </sqf:fix>
     </rule>
    </pattern>
  
  <pattern id="bold">
     <rule context="bold" id="bold-checks">
        <report test="not(ancestor::sub-article) and matches(.,'(^|[\s\(\[])[Ff]ig(\.|ure)?')"
          role="warning" 
          sqf:fix="strip-tags replace-fig-xref replace-supp-xref"
          id="bold-check-1">Content of bold element suggests it's intended to be a figure citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|[\s\(\[])([Tt]able|[Tt]bl)[\.\s]')"
          role="warning"
          sqf:fix="strip-tags replace-fig-xref replace-supp-xref"
          id="bold-check-2">Content of bold element suggests it's intended to be a table or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
       
       <report test="not(ancestor::sub-article) and matches(.,'(^|[\s\(\[])([Vv]ideo|[Mm]ovie)')"
          role="warning"
          sqf:fix="strip-tags replace-fig-xref replace-supp-xref"
          id="bold-check-3">Content of bold element suggests it's intended to be a video or supplementary file citation: <value-of select="."/>. Either replace it with an xref or remove the bold formatting, as appropriate.</report>
      </rule>
   </pattern>
  
  <pattern id="sc">
     <rule context="sc" id="sc-checks">
        <report test="."
          role="warning"
          sqf:fix="strip-tags strip-tags-all-caps"
          id="sc-check-1">Content is in small caps - <value-of select="."/> - This formatting is not supported on EPP. Consider removing it or replacing the content with other formatting or (if necessary) different glyphs/characters in order to retain the original meaning.</report>
       
       <sqf:fix id="strip-tags-all-caps">
         <sqf:description>
           <sqf:title>Strip the tags and GO ALL CAPS</sqf:title>
         </sqf:description>
         <sqf:replace match=".">
           <xsl:value-of select="upper-case(.)"/>
         </sqf:replace>
       </sqf:fix>
      </rule>
   </pattern>

    <pattern id="fig">
     <rule context="fig" id="fig-checks">
        <assert test="graphic" 
        role="error" 
        id="fig-graphic-conformance"><value-of select="if (label) then label else name()"/> does not have a child graphic element, which must be incorrect.</assert>
       
       <report test="not(label) and parent::sec and preceding-sibling::title and not(following-sibling::*)" 
        role="warning" 
        id="fig-sec-wrapper">Unlablled figure is entirely wrapped in a sec with a title. Is the sec redundant and the title actually the label (or title) for the figure?</report>
     </rule>

     <rule context="fig/*" id="fig-child-checks">
        <let name="supported-fig-children" value="('label','caption','graphic','alternatives','permissions','attrib')"/>
        <assert test="name()=$supported-fig-children" 
        role="error"
        sqf:fix="delete-elem"
        id="fig-child-conformance"><name/> is not supported as a child of &lt;fig>.</assert>
     </rule>
      
      <rule context="fig/label" id="fig-label-checks">
        <report test="normalize-space(.)=''" 
          role="error"
          sqf:fix="delete-elem"
          id="fig-wrap-empty">Label for fig is empty. Either remove the elment or add the missing content.</report>
        
        <report test="matches(lower-case(.),'^\s*(video|movie)')" 
          role="warning" 
          id="fig-label-video">Label for figure ('<value-of select="."/>') starts with text that suggests its a video. Should this content be captured as a video instead of a figure?</report>
        
        <report test="matches(lower-case(.),'^\s*table')" 
          role="warning" 
          id="fig-label-table">Label for figure ('<value-of select="."/>') starts with table. Should this content be captured as a table instead of a figure?</report>
     </rule>
      
      <rule context="fig/caption/title" id="fig-title-checks">
        <let name="sentence-count" value="count(tokenize(replace(replace(replace(lower-case(.),$org-regex,''),'[\p{Zs}]$',''),' vs.',''),'\. '))"/>
        <report test="parent::caption/p and matches(lower-case(.),'\.\p{Z}*\p{P}?a(\p{Z}*[\p{Pd},&amp;]\p{Z}*[b-z])?\p{P}?\p{Z}*$')" 
          role="warning" 
          id="fig-title-1">Title for figure ('<value-of select="ancestor::fig/label"/>') potentially ends with a panel label. Should it be moved to the start of the next paragraph? <value-of select="."/></report>
        
        <report test="$sentence-count gt 1" 
          role="warning" 
          id="fig-title-2">Title for <value-of select="replace(ancestor::fig[1]/label[1],'\.$','')"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption?</report>
     </rule>
      
      <rule context="fig/caption" id="fig-caption-checks">
        <let name="label" value="if (ancestor::fig/label) then ancestor::fig[1]/label[1] else 'unlabelled figure'"/>
        <let name="is-revised-rp" value="if (ancestor::article//article-meta/pub-history/event/self-uri[@content-type='reviewed-preprint']) then true() else false()"/>
        
        <report test="not($is-revised-rp) and matches(lower-case(.),'biorend[eo]r') and not(descendant::ext-link[matches(lower-case(@*:href),'biorender.com/[a-z\d]')])" 
        role="warning" 
        id="fig-biorender-check-v1">Caption for <value-of select="$label"/> mentions bioRender, but it does not contain a BioRender figure link in the format "BioRender.com/{figure-code}".</report>
        
        <report test="$is-revised-rp and matches(lower-case(.),'biorend[eo]r') and not(descendant::ext-link[matches(lower-case(@*:href),'biorender.com/[a-z\d]')])" 
        role="warning" 
        id="fig-biorender-check-revised">Caption for <value-of select="$label"/> mentions bioRender, but it does not contain a BioRender figure link in the format "BioRender.com/{figure-code}". Since this is a revised RP, check to see if the first (or a previous) version had bioRender links.</report>
        
        <report test="not(title) and (count(p) gt 1)" 
          role="warning" 
          sqf:fix="replace-p-to-title"
          id="fig-caption-1">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple paragraphs. Is the first paragraph actually the title?</report>
        
        <report test="not(title) and (count(p)=1) and (count(tokenize(p[1],'\.\p{Z}')) gt 1) and not(matches(lower-case(p[1]),'^\p{Z}*\p{P}?(a|a[–—\-][b-z]|i)\p{P}'))" 
          role="warning" 
          sqf:fix="replace-move-sentence-to-title"
          id="fig-caption-2">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple sentences in the legend. Is the first sentence actually the title?</report>
        
        <report test="not(title) and (count(p)=1) and not(count(tokenize(p[1],'\.\p{Z}')) gt 1)" 
          role="warning"
          sqf:fix="replace-p-to-title"
          id="fig-caption-3">Caption for <value-of select="$label"/> doesn't have a title, but it does have a paragraph. Is the paragraph actually the title?</report>
     </rule>
    </pattern>

    <pattern id="table-wrap">
     <rule context="table-wrap" id="table-wrap-checks">
        <!-- adjust when support is added for HTML tables -->
        <assert test="graphic or alternatives[graphic]" 
        role="error" 
        id="table-wrap-content-conformance"><value-of select="if (label) then label else name()"/> does not have a child graphic element, which must be incorrect.</assert>
       
       <report test="not(label) and parent::sec and preceding-sibling::title and not(following-sibling::*)" 
        role="warning" 
        id="table-wrap-sec-wrapper">Unlablled table is entirely wrapped in a sec with a title. Is the sec redundant and the title actually the label (or title) for the table?</report>
     </rule>

     <rule context="table-wrap/*" id="table-wrap-child-checks">
        <let name="supported-table-wrap-children" value="('label','caption','graphic','alternatives','table','permissions','table-wrap-foot')"/>
        <assert test="name()=$supported-table-wrap-children" 
        role="error" 
        sqf:fix="delete-elem"
        id="table-wrap-child-conformance"><value-of select="name()"/> is not supported as a child of &lt;table-wrap>.</assert>
     </rule>
      
      <rule context="table-wrap/label" id="table-wrap-label-checks">
        <report test="normalize-space(.)=''" 
          role="error" 
          sqf:fix="delete-elem"
          id="table-wrap-empty">Label for table is empty. Either remove the elment or add the missing content.</report>
        
        <report test="matches(lower-case(.),'^\s*fig')" 
          role="warning" 
          id="table-wrap-label-fig">Label for table ('<value-of select="."/>') starts with text that suggests its a figure. Should this content be captured as a figure instead of a table?</report>
     </rule>
      
      <rule context="table-wrap/caption" id="table-wrap-caption-checks">
        <let name="label" value="if (ancestor::table-wrap/label) then ancestor::table-wrap[1]/label[1] else 'inline table'"/>
        
        <report test="not(title) and (count(p) gt 1)" 
          role="warning" 
          sqf:fix="replace-p-to-title"
          id="table-wrap-caption-1">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple paragraphs. Is the first paragraph actually the title?</report>
        
        <report test="not(title) and (count(p)=1) and (count(tokenize(p[1],'\.\p{Z}')) gt 1)" 
          role="warning"
          sqf:fix="replace-move-sentence-to-title"
          id="table-wrap-caption-2">Caption for <value-of select="$label"/> doesn't have a title, but there are mutliple sentences in the legend. Is the first sentence actually the title?</report>
        
        <report test="not(title) and (count(p)=1) and not(count(tokenize(p[1],'\.\p{Z}')) gt 1)" 
          role="warning"
          sqf:fix="replace-p-to-title"
          id="table-wrap-caption-3">Caption for <value-of select="$label"/> doesn't have a title, but it does have a paragraph. Is the paragraph actually the title?</report>
      </rule>
      
      <rule context="table-wrap/caption/title" id="table-wrap-title-checks">
        <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\p{Zs}]$',''),'\. '))"/>
        
        <report test="$sentence-count gt 1" 
          role="warning" 
          id="table-wrap-title-1">Title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption?</report>
     </rule>
    </pattern>
  
    <pattern id="supplementary-material">
      <rule context="supplementary-material" id="supplementary-material-checks">
        <assert test="ancestor::sec[@sec-type='supplementary-material']"
          role="warning" 
          id="supplementary-material-temp-test">supplementary-material element is not placed within a &lt;sec sec-type="supplementary-material">. Is that correct?.</assert>
        
        <assert test="media"
          role="error" 
          sqf:fix="delete-elem"
          id="supplementary-material-test-1">supplementary-material does not have a child media. It must either have a file or be deleted.</assert>
        
        <report test="count(media) gt 1"
          role="error" 
          id="supplementary-material-test-2">supplementary-material has <value-of select="count(media)"/> child media elements. Each file must be wrapped in its own supplementary-material.</report>
      </rule>
      
      <rule context="supplementary-material/*" id="supplementary-material-child-checks">
        <let name="permitted-children" value="('label','caption','media')"/>
        
        <assert test="name()=$permitted-children"
          role="error" 
          sqf:fix="delete-elem"
          id="supplementary-material-child-test-1"><name/> is not supported as a child of supplementary-material. The only permitted children are: <value-of select="string-join($permitted-children,'; ')"/>.</assert>
      </rule>
    </pattern>

    <pattern id="equation">
      <rule context="disp-formula" id="disp-formula-checks">
          <!-- adjust when support is added for mathML -->
          <assert test="graphic or alternatives[graphic]" 
          role="error" 
          id="disp-formula-content-conformance"><value-of select="if (label) then concat('Equation ',label) else name()"/> does not have a child graphic element, which must be incorrect.</assert>
        
        <assert test="@id" 
          role="error" 
          id="disp-formula-id-conformance"><value-of select="name()"/> does not have a id attribute, which must be incorrect.</assert>
      </rule>
      
       <rule context="inline-formula" id="inline-formula-checks">
          <!-- adjust when support is added for mathML -->
          <assert test="inline-graphic or alternatives[inline-graphic]" 
          role="error" 
          id="inline-formula-content-conformance"><value-of select="name()"/> does not have a child inline-graphic element, which must be incorrect.</assert>
         
         <assert test="@id" 
          role="error" 
          id="inline-formula-id-conformance"><value-of select="name()"/> does not have a id attribute, which must be incorrect.</assert>
      </rule>
      
        <rule context="alternatives[parent::disp-formula]" id="disp-equation-alternatives-checks">
          <assert test="graphic and *:math" 
          role="error" 
          id="disp-equation-alternatives-conformance">alternatives element within <value-of select="parent::*/name()"/> must have both a graphic (or numerous graphics) and mathml representation of the equation. This one does not.</assert>
      </rule>
      
        <rule context="alternatives[parent::inline-formula]" id="inline-equation-alternatives-checks">
          <assert test="inline-graphic and *:math" 
          role="error" 
          id="inline-equation-alternatives-conformance">alternatives element within <value-of select="parent::*/name()"/> must have both an inline-graphic (or numerous graphics) and mathml representation of the equation. This one does not.</assert>
      </rule>
    </pattern>

    <pattern id="list">
     <rule context="list" id="list-checks">
        <let name="supported-list-types" value="('bullet','simple','order','alpha-lower','alpha-upper','roman-lower','roman-upper')"/>
        <assert test="@list-type=$supported-list-types" 
        role="error" 
        id="list-type-conformance">&lt;list> element must have a list-type attribute with one of the supported values: <value-of select="string-join($supported-list-types,'; ')"/>.<value-of select="if (./@list-type) then concat(' list-type ',@list-type,' is not supported.') else ()"/></assert>
     </rule>
    </pattern>
  
     <pattern id="graphic">
      <rule context="graphic|inline-graphic" id="graphic-checks">
        <let name="link" value="lower-case(@*:href)"/>
        <let name="file" value="tokenize($link,'\.')[last()]"/>
        <let name="image-file-types" value="('tif','tiff','gif','jpg','jpeg','png')"/>
        
        <assert test="normalize-space(@*:href)!=''" 
          role="error" 
          id="graphic-check-1"><name/> must have an xlink:href attribute. This one does not.</assert>
        
        <assert test="$file=$image-file-types" 
          role="error" 
          id="graphic-check-2"><name/> must have an xlink:href attribute that ends with an image file type extension. <value-of select="if ($file!='') then $file else @*:href"/> is not one of <value-of select="string-join($image-file-types,', ')"/>.</assert>
        
        <report test="contains(@mime-subtype,'tiff') and not($file=('tif','tiff'))" 
          role="error" 
          id="graphic-test-1"><name/> has tiff mime-subtype but filename does not end with '.tif' or '.tiff'. This cannot be correct.</report>
        
        <assert test="normalize-space(@mime-subtype)!=''" 
         role="error" 
         id="graphic-test-2"><name/> must have a mime-subtype attribute.</assert>
      
        <report test="contains(@mime-subtype,'jpeg') and not($file=('jpg','jpeg'))" 
         role="error" 
         id="graphic-test-3"><name/> has jpeg mime-subtype but filename does not end with '.jpg' or '.jpeg'. This cannot be correct.</report>
        
        <assert test="@mimetype='image'" 
          role="error" 
          id="graphic-test-4"><name/> must have a @mimetype='image'.</assert>
        
        <report test="@mime-subtype='png' and $file!='png'" 
         role="error" 
         id="graphic-test-5"><name/> has png mime-subtype but filename does not end with '.png'. This cannot be correct.</report>
        
        <report test="not(ancestor::sub-article) and preceding::graphic/@*:href/lower-case(.) = $link or preceding::inline-graphic/@*:href/lower-case(.) = $link" 
          role="error" 
          id="graphic-test-6">Image file for <value-of select="if (parent::fig/label) then parent::fig/label else 'graphic'"/> (<value-of select="@*:href"/>) is the same as the one used for another graphic or inline-graphic.</report>
        
        <report test="ancestor::sub-article and preceding::graphic/@*:href/lower-case(.) = $link or preceding::inline-graphic/@*:href/lower-case(.) = $link" 
          role="warning" 
          id="graphic-test-9">Image file in sub-article for <value-of select="if (parent::fig/label) then parent::fig/label else 'graphic'"/> (<value-of select="@*:href"/>) is the same as the one used for another graphic or inline-graphic. Is that correct?</report>
        
        <report test="@mime-subtype='gif' and $file!='gif'" 
         role="error" 
         id="graphic-test-7"><name/> has gif mime-subtype but filename does not end with '.gif'. This cannot be correct.</report>
     </rule>
       
       <rule context="graphic" id="graphic-placement">
         <assert test="parent::fig or parent::table-wrap or parent::disp-formula or parent::alternatives[parent::table-wrap or parent::disp-formula]" 
          role="error" 
          id="graphic-test-8"><name/> can only be placed as a child of fig, table-wrap, disp-formula or alternatives (alternatives must in turn must be a child of either table-wrap or disp-formula). This one is a child of <value-of select="parent::*/name()"/></assert>
       </rule>
       
       <rule context="inline-graphic" id="inline-checks">
         <assert test="parent::inline-formula or parent::alternatives[parent::inline-formula] or ancestor::caption[parent::fig or parent::table-wrap]" 
          role="warning" 
          id="inline-graphic-test-1"><name/> is usually placed either in inline-formula (or alternatives which in turn is a child of inline-formula), or in the caption for a figure or table. This one is not (its a child of <value-of select="parent::*/name()"/>). Is that OK?</assert>
       </rule>
       
     </pattern>
  
      <pattern id="media">
      <rule context="media" id="media-checks">
        <let name="link" value="@*:href"/>
      
      <assert test="matches(@*:href,'\.[\p{L}\p{N}]{1,15}$')" 
        role="error" 
        id="media-test-3">media must have an @xlink:href which contains a file reference.</assert>
        
      <report test="preceding::media/@*:href = $link" 
        role="error" 
        id="media-test-10">Media file for <value-of select="if (parent::*/label) then parent::*/label else 'media'"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="if (preceding::media[@*:href=$link][1]/parent::*/label) then preceding::media[@*:href=$link][1]/parent::*/label
        else 'another file'"/>.</report>
        
      <report test="text()" 
        role="error" 
        id="media-test-12">Media element cannot contain text. This one has <value-of select="string-join(text(),'')"/>.</report>
        
      <report test="*" 
        role="error" 
        id="media-test-13">Media element cannot contain child elements. This one has the following element(s) <value-of select="string-join(*/name(),'; ')"/>.</report>
        
      <assert test="parent::supplementary-material" 
        role="error" 
        id="media-test-1">media element should only be placed as a child of supplementary-material. This one has the parent <value-of select="parent::*/name()"/></assert>
     </rule>
       
     </pattern>
  
    <pattern id="sec">
      <rule context="sec" id="sec-checks">

        <report test="@sec-type='supplementary-material' and *[not(name()=('label','title','supplementary-material'))]" 
          role="warning" 
          id="sec-supplementary-material">&lt;sec sec-type='supplementary-material'> contains elements other than supplementary-material: <value-of select="string-join(*[not(name()=('label','title','supplementary-material'))]/name(),'; ')"/>. These will currently be stripped from the content rendered on EPP. Should they be moved out of the section or is that OK?'</report>
        
        <report test="@sec-type='supplementary-material' and not(supplementary-material)" 
          role="error" 
          id="sec-supplementary-material-2">&lt;sec sec-type="supplementary-material"> must contain at least one &lt;supplementary-material> element, but this one does not. If this section contains captions, then these should be added to the appropriate &lt;supplementary-material>. If the files are not present in the article at all, the captions should be removed (or the files added as new &lt;supplementary-material>).</report>
        
        <report test="not(@sec-type=('additional-information','supplementary-material')) and not(descendant::supplementary-material or descendant::fig or descendant::table-wrap) and title[1][matches(lower-case(.),'(supporting|supplementary|supplemental|ancillary|additional) (information|files|material)')]" 
          role="warning" 
          id="sec-supplementary-material-3">sec has a title suggesting its content might relate to additional files, but it doesn't contain a supplementary-material element. If this section contains captions for supplementary files, then these should be added to the appropriate &lt;supplementary-material>. If the files are not present in the article at all, the captions should be removed (or the files added as new &lt;supplementary-material>).</report>
        
        <report test="@sec-type='supplementary-material' and not(title) and not(parent::back)" 
          role="warning" 
          id="sec-supplementary-material-4">&lt;sec sec-type='supplementary-material'> does not have a title element. Is that correct?</report>
        
        <report test="@sec-type='supplementary-material' and not(title) and parent::back" 
          role="error" 
          id="sec-supplementary-material-5">&lt;sec sec-type='supplementary-material'> does not have a title element.</report>
        
        <report test="@sec-type='supplementary-material' and title and title!='Additional files' and parent::back" 
          role="error" 
          id="sec-supplementary-material-6">&lt;sec sec-type='supplementary-material'> has a title element, but it is not 'Additional files'.</report>

        <assert test="*[not(name()=('label','title','sec-meta'))]" 
          role="error" 
          id="sec-empty">sec element is not populated with any content. Either there's a mistake or the section should be removed.</assert>
        <report test="@sec-type='data-availability' and (preceding::sec[@sec-type='data-availability'] or ancestor::sec[@sec-type='data-availability'])" 
          role="warning" 
          id="sec-data-availability">sec has the sec-type 'data-availability', but there is one or more other secs with this same sec-type. Are they duplicates?</report>
        
        <report test="@sec-type='data-availability' and (not(p) or p[normalize-space(.)='' or matches(normalize-space(lower-case(.)),'^(not (available|applicable)|n/a)\.?$')])" 
          role="warning" 
          id="sec-data-availability-empty">Data availability section isn't populated with any meaningful content. Should it be removed?</report>
        
        <report test="title[1][matches(lower-case(.),'(compete?t?ing|conflicts?[\s-]of)[\s-]interest|disclosure|declaration|disclaimer')] and ancestor::article//article-meta/author-notes/fn[@fn-type='coi-statement']" 
          role="warning" 
          id="sec-coi">sec has a title suggesting it's a competing interest statement, but there is also a competing interest statement in author-notes. Are they duplicates? COI statements should be captured within author-notes, so this section should likely be deleted.</report>
        
        <report test="title[1][matches(lower-case(.),'(compete?t?ing|conflicts?[\s-]of)[\s-]interest|disclosure|declaration|disclaimer')] and not(ancestor::article//article-meta/author-notes/fn[@fn-type='coi-statement'])" 
          role="warning" 
          id="sec-coi-2">sec has a title suggesting it's a competing interest statement. COI statements should be captured within author-notes, so this content should be moved into fn with the fn-type="coi-statement" within author-notes.</report>
        
        <report test="@sec-type='ethics-statement' and (preceding::sec[@sec-type='ethics-statement'] or ancestor::sec[@sec-type='ethics-statement'])" 
          role="error" 
          id="sec-ethics">sec has the sec-type 'ethics-statement', but there is one or more other secs with this same sec-type. Are they duplicates? There can only be one section with this sec-type (although it can have subsections with further distinctions that have separate 'ethics-...' sec-types - e.g. "ethics-approval-human", "ethics-approval-animal" etc.)</report>
        
        <report test="def-list and not(*[not(name()=('label','title','sec-meta','def-list'))])" 
          role="error" 
          id="sec-def-list">sec element only contains a child def-list. This is therefore a glossary, not a sec.</report>
        
        <report test="glossary and not(*[not(name()=('label','title','sec-meta','glossary'))])" 
          role="warning" 
          id="sec-glossary">sec element only contains a child glossary. Is it a redundant sec (which should be deleted)? Or perhaps it indicates the structure/hierarchy has been incorrectly captured.</report>
        
        <report test="label and not(title)" 
          role="error"
          sqf:fix="label-to-title"
          id="sec-label-no-title">sec element has a label but not title. This is not correct. Please capture the label as the title.</report>
        
        <report test="(not(@sec-type='supplementary')) and not(sec) and not(p[*[not(name()=('fig','table-wrap'))]]) and (descendant::fig or descendant::table-wrap) and (not(title) or title[1][matches(lower-case(.),'^supplement| supplement')])" 
          role="warning"
          id="sec-supplementary">sec element <value-of select="if (not(title)) then 'without title' else concat('(',title[1],')')"/> only contains figures and tables but it doesn't have a sec-type="supplementary" attribute. Is this correct? (This attribute is used to assist with PDF generation).</report>
     </rule>
      
      <rule context="sec[(parent::body or parent::back) and title]" id="top-sec-checks">
        <let name="top-sec-phrases" value="('(results?|conclusions?)( (and|&amp;) discussion)?',
            'discussion( (and|&amp;) (results?|conclusions?))?')"/>
        <let name="methods-phrases" value="('(materials? (and|&amp;)|experimental)?\s?methods?( details?|summary|(and|&amp;) materials?)?',
            '(supplement(al|ary)? )?materials( (and|&amp;) correspondence)?',
            '(model|methods?)(( and| &amp;) (results|materials?))?')"/>
        <let name="methods-regex" value="concat('^(',string-join($methods-phrases,'|'),')$')"/>
        <let name="sec-regex" value="concat('^(',string-join(($top-sec-phrases,$methods-phrases),'|'),')$')"/>
               
        <report test="parent::body and not(matches(lower-case(title[1]),$sec-regex)) and preceding-sibling::sec/title[1][matches(lower-case(.),$methods-regex)]" 
          role="warning" 
          id="top-sec-1">Section with the title '<value-of select="title[1]"/>' is a child of body. Should it be a child of another section (e.g. methods) or placed within back (perhaps within an 'Additional infomation' section)?</report>
        
        <report test="matches(label[1],'\d+\.\s?\d')" 
          role="warning" 
          id="top-sec-2">Section that is placed as a child of <value-of select="parent::*/name()"/> has a label which suggests it should be a subsection: <value-of select="label[1]"/>.</report>
      </rule>
      
      <rule context="sec/label" id="sec-label-checks">
        <report test="matches(.,'[2-4]D')" 
          role="warning" 
          sqf:fix="move-to-title delete-elem"
          id="sec-label-1">Label for section contains 2D or similar - '<value-of select="."/>'. Is it really a label? Or just part of the title?</report>
        
        <report test="normalize-space(.)=''" 
          role="error" 
          sqf:fix="delete-elem"
          id="sec-label-2">Section label is empty. This is not permitted.</report>
        
        <sqf:fix id="move-to-title" use-when="parent::sec/title">
          <sqf:description>
            <sqf:title>Move to title</sqf:title>
          </sqf:description>
          <sqf:replace match="parent::sec/title">
            <xsl:copy copy-namespaces="no">
              <xsl:copy-of select="namespace-node()"/>
              <xsl:apply-templates select="@*" mode="customCopy"/>
              <xsl:apply-templates select="parent::sec/label/node()" mode="customCopy"/>
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="node()|comment()|processing-instruction()" mode="customCopy"/>
            </xsl:copy>
          </sqf:replace>
          <sqf:delete match="."/>
        </sqf:fix>
      </rule>
    </pattern>
  
  <pattern id="app">
    <rule context="app" id="app-checks">
      <report test="label and not(title)" 
          role="error"
          sqf:fix="label-to-title"
          id="app-label-no-title">app element has a label but not title. This is not correct. Please capture the label as the title.</report>
    </rule>
  </pattern>

    <pattern id="title">
     <rule context="title" id="title-checks">
        <report test="upper-case(.)=." 
        role="warning" 
        sqf:fix="replace-sentence-case"
        id="title-upper-case">Content of &lt;title> element is entirely in upper case: Is that correct? '<value-of select="."/>'</report>

        <report test="lower-case(.)=." 
        role="warning"
        sqf:fix="replace-sentence-case"
        id="title-lower-case">Content of &lt;title> element is entirely in lower-case case: Is that correct? '<value-of select="."/>'</report>
     </rule>
      
<!-- Top level section titles that will appear in the table of contents -->
      <rule context="article/body/sec/title|article/back/sec/title" id="title-toc-checks">
        <report test="xref" 
          role="error" 
          id="toc-title-contains-citation"><name/> element contains a citation and will appear within the table of contents on EPP. This will cause images not to load. Please either remove the citaiton or make it plain text.</report>
      </rule>
    </pattern>

    <pattern id="p">
      <rule context="p[not(ancestor::sub-article or ancestor::def) and (count(*)=1) and (child::bold or child::italic)]" id="p-bold-checks">
        <let name="free-text" value="replace(normalize-space(string-join(for $x in self::*/text() return $x,'')),' ','')"/>
        <report test="$free-text=''"
        role="warning" 
        id="p-all-bold">Content of p element is entirely in <value-of select="child::*[1]/local-name()"/> - '<value-of select="."/>'. Is this correct?</report>
      </rule>
      
      <rule context="article[descendant::xref[@ref-type='bibr'][matches(.,'\p{L}')]]//p[not(ancestor::sub-article) and not(ancestor::ack)]" id="p-ref-checks">
        <let name="text" value="string-join(for $x in self::*/(*|text())
                                            return if ($x/local-name()='xref') then ()
                                                   else if ($x//*:p) then ($x/text())
                                                   else string($x),'')"/>
        <let name="missing-ref-regex" value="'\p{Lu}\p{L}\p{L}+( et al\.?)?\p{P}?\s*\p{Ps}?([1][7-9][0-9][0-9]|[2][0-2][0-9][0-9])'"/>
        
        <report test="matches($text,$missing-ref-regex)" 
        role="warning" 
        id="missing-ref-in-text-test"><name/> element contains possible citation which is unlinked or a missing reference - search - <value-of select="string-join(e:analyze-string($text,$missing-ref-regex)//*:match,'; ')"/></report>
      </rule>
      
      <rule context="article//p[not(ancestor::sub-article) and not(ancestor::ack)]" id="p-file-ref-checks">
        <let name="text" value="lower-case(string-join(for $x in self::*/(*|text())
                                            return if ($x/local-name()='xref') then ()
                                                   else if ($x//*:p) then ($x/text())
                                                   else string($x),''))"/>
        <let name="missing-file-regex" value="'\s(fig(\.|ure)?|table|file|movie|video)s?(\s+supp(\.|l[ae]m[ae]nt(ary|al)?)?s?)?\s+s?\d'"/>
        
        <report test="matches($text,$missing-file-regex)" 
        role="warning" 
        id="missing-file-in-text-test"><name/> element contains possible unlinked citation to a figure, table or file - search - <value-of select="string-join(e:analyze-string($text,$missing-file-regex)//*:match,'; ')"/></report>
      </rule>
    </pattern>
  
  <pattern id="p-td-th">
    
    <rule context="p|td|th" id="p-td-th-checks">
      <let name="rrid-link-count" value="count(descendant::ext-link[matches(@*:href,'identifiers\.org/RRID(:|/).*')])"/>
      <let name="rrid-text-count" value="number(count(
        for $x in tokenize(.,'RRID\p{Zs}?#?\p{Zs}?:|RRID AB_[\d]+|RRID CVCL_[\d]+|RRID SCR_[\d]+|RRID ISMR_JAX')
        return $x)) -1"/>
      <let name="link-strip-text" value="string-join(for $x in (*[not(matches(local-name(),'^ext-link$|^contrib-id$|^license_ref$|^institution-id$|^email$|^xref$|^monospace$'))]|text()) return $x,'')"/>
      <let name="url-text" value="string-join(for $x in tokenize($link-strip-text,' ')
        return   if (matches($x,'^https?:..(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%_\+.~#?&amp;//=]*)|^ftp://.|^git://.|^tel:.|^mailto:.|\.org[\p{Zs}]?|\.com[\p{Zs}]?|\.co.uk[\p{Zs}]?|\.us[\p{Zs}]?|\.net[\p{Zs}]?|\.edu[\p{Zs}]?|\.gov[\p{Zs}]?|\.io[\p{Zs}]?')) then $x
        else (),'; ')"/>
      <let name="organisms" value="if (matches(lower-case(.),$org-regex)) then (e:org-conform(.)) else ()"/>
      
      <report see="https://elifeproduction.slab.com/posts/rri-ds-5k19v560#rrid-test" 
        test="($rrid-text-count gt $rrid-link-count)" 
        role="warning" 
        id="rrid-test">'<name/>' element contains what looks like <value-of select="$rrid-text-count - $rrid-link-count"/> unlinked RRID(s). These should always be linked using 'https://identifiers.org/RRID:'. Element begins with <value-of select="substring(.,1,15)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hrt08-ring-diacritic-symbol-test"
        test="matches(.,'˚') and not(descendant::p[matches(.,'˚')]) and not(descendant::td[matches(.,'˚')]) and not(descendant::th[matches(.,'˚')])" 
        role="warning" 
        id="ring-diacritic-symbol-test">'<name/>' element contains the ring above symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hlvnh-unlinked-url"
        test="not(descendant::p or descendant::td or descendant::th or descendant::title) and not(ancestor::sub-article or child::element-citation) and not(ancestor::fn-group[@content-type='ethics-information']) and not($url-text = '')" 
        role="warning" 
        id="unlinked-url">'<name/>' element contains possible unlinked urls. Check - <value-of select="$url-text"/></report>
      
      <report test="matches(.,'user-?name\s*:|password\s*:') or (matches(.,'\suser-?name\s') and matches(.,'\spassword\s'))" 
        role="warning" 
        id="user-name-password"><name/> contains what may be a username and password - <value-of select="."/>. If these are access ceredentials for a dataset depositsed by the authors, it should be made publicly available (unless approved by editors) and the credentials removed/deleted.</report>
    </rule>
    
  </pattern>

    <pattern id="article-metadata">
      <rule context="article/front/article-meta" id="general-article-meta-checks">
        <let name="is-reviewed-preprint" value="parent::front/journal-meta/lower-case(journal-id[1])='elife'"/>
        <let name="distinct-emails" value="distinct-values((descendant::contrib[@contrib-type='author']/email, author-notes/corresp/email))"/>
        <let name="distinct-email-count" value="count($distinct-emails)"/>
        <let name="corresp-authors" value="distinct-values(for $name in descendant::contrib[@contrib-type='author' and @corresp='yes']/name[1] return e:get-name($name))"/>
        <let name="corresp-author-count" value="count($corresp-authors)"/>
        
        <assert test="article-id[@pub-id-type='doi']"
        role="error" 
        id="article-id">article-meta must contain at least one DOI - a &lt;article-id pub-id-type="doi"> element.</assert>

        <report test="article-version[not(@article-version-type)] or article-version-alternatives/article-version[@article-version-type='preprint-version']"
          role="info" 
          id="article-version-flag">This is preprint version <value-of select="if (article-version-alternatives/article-version[@article-version-type='preprint-version']) then article-version-alternatives/article-version[@article-version-type='preprint-version'] else article-version[not(@article-version-type)]"/>.</report>

        <report test="not($is-reviewed-preprint) and not(count(article-version)=1)" 
          role="error" 
          id="article-version-1">article-meta in preprints must contain one (and only one) &lt;article-version> element.</report>
        
        <report test="$is-reviewed-preprint and not(count(article-version-alternatives)=1)" 
          role="error" 
          id="article-version-3">article-meta in reviewed preprints must contain one (and only one) &lt;article-version-alternatives> element.</report>

        <assert test="count(contrib-group)=(1,2)" 
        role="error" 
        id="article-contrib-group">article-meta must contain either one or two &lt;contrib-group> elements. This one contains <value-of select="count(contrib-group)"/>.</assert>
        
        <assert test="(descendant::contrib[@contrib-type='author' and email]) or (descendant::contrib[@contrib-type='author']/xref[@ref-type='corresp']/@rid=./author-notes/corresp/@id)" 
        role="error" 
        id="article-no-emails">This preprint has no emails for corresponding authors, which must be incorrect.</assert>
        
        <assert test="$corresp-author-count=$distinct-email-count" 
          role="warning" 
          id="article-email-corresp-author-count-equivalence">The number of corresponding authors (<value-of select="$corresp-author-count"/>: <value-of select="string-join($corresp-authors,'; ')"/>) is not equal to the number of distinct email addresses (<value-of select="$distinct-email-count"/>: <value-of select="string-join($distinct-emails,'; ')"/>). Is this correct?</assert>

        <report test="$corresp-author-count=$distinct-email-count and author-notes/corresp" 
          role="warning" 
          id="article-corresp">The number of corresponding authors and distinct emails is the same, but a match between them has been unable to be made. As its stands the corresp will display on EPP: <value-of select="author-notes/corresp"/>.</report>

        <report test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='publisher-id'])=1)" 
          role="error" 
          id="article-id-1">Reviewed preprints must have one (and only one) publisher-id. This one has <value-of select="count(article-id[@pub-id-type='publisher-id'])"/>.</report>
      
        <report test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='doi'])=2)" 
          role="error" 
          id="article-id-2">Reviewed preprints must have two DOIs. This one has <value-of select="count(article-id[@pub-id-type='doi'])"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(volume)=1)" 
          role="error" 
          id="volume-presence">Reviewed preprints must have (and only one) volume. This one has <value-of select="count(volume)"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(elocation-id)=1)" 
          role="error" 
          id="elocation-id-presence">Reviewed preprints must have (and only one) elocation-id. This one has <value-of select="count(elocation-id)"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(history)=1)" 
          role="error" 
          id="history-presence">Reviewed preprints must have (and only one) history. This one has <value-of select="count(history)"/>.</report>
        
        <report test="$is-reviewed-preprint and not(count(pub-history)=1)" 
          role="error" 
          id="pub-history-presence">Reviewed preprints must have (and only one) pub-history. This one has <value-of select="count(pub-history)"/>.</report>
      </rule>

         <rule context="article/front/article-meta/article-id" id="general-article-id-checks">
            <assert test="@pub-id-type=('publisher-id','doi')" 
              role="error" 
              id="article-id-3">article-id must have a pub-id-type with a value of 'publisher-id' or 'doi'. This one has <value-of select="if (@publisher-id) then @publisher-id else 'no publisher-id attribute'"/>.</assert>
         </rule>
      
      <rule context="article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='publisher-id']" id="publisher-article-id-checks">
        <assert test="matches(.,'^1?\d{5}$')" 
          role="error" 
          id="publisher-id-1">article-id with the attribute pub-id-type="publisher-id" must contain the 5 or 6 digit manuscript tracking number. This one contains <value-of select="."/>.</assert>
      </rule>
      
      <rule context="article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='doi']" id="article-dois">
      <let name="article-id" value="parent::article-meta[1]/article-id[@pub-id-type='publisher-id'][1]"/>
      <let name="latest-rp-doi" value="parent::article-meta/pub-history/event[position()=last()]/self-uri[@content-type='reviewed-preprint']/@*:href"/>
      <let name="latest-rp-doi-version" value="if ($latest-rp-doi) then replace($latest-rp-doi,'^.*\.','')
                                               else '0'"/>
      
      <assert test="starts-with(.,'10.7554/eLife.')" 
        role="error" 
        id="prc-article-dois-1">Article level DOI must start with '10.7554/eLife.'. Currently it is <value-of select="."/></assert>
      
      <report test="not(@specific-use) and substring-after(.,'10.7554/eLife.') != $article-id" 
        role="error" 
        id="prc-article-dois-2">Article level concept DOI must be a concatenation of '10.7554/eLife.' and the article-id. Currently it is <value-of select="."/></report>
      
      <report test="@specific-use and not(contains(.,$article-id))" 
        role="error" 
        id="prc-article-dois-3">Article level specific version DOI must contain the article-id (<value-of select="$article-id"/>). Currently it does not <value-of select="."/></report>
      
      <report test="@specific-use and not(matches(.,'^10.7554/eLife\.\d{5,6}\.\d$'))" 
        role="error" 
        id="prc-article-dois-4">Article level specific version DOI must be in the format 10.7554/eLife.00000.0. Currently it is <value-of select="."/></report>
      
      <report test="not(@specific-use) and (preceding-sibling::article-id[@pub-id-type='doi'] or following-sibling::article-id[@pub-id-type='doi' and not(@specific-use)])" 
        role="error" 
        id="prc-article-dois-5">Article level concept DOI must be first in article-meta, and there can only be one. This concept DOI has a preceding DOI or following concept DOI.</report>
      
      <report test="@specific-use and (following-sibling::article-id[@pub-id-type='doi'] or preceding-sibling::article-id[@pub-id-type='doi' and @specific-use])" 
        role="error" 
        id="prc-article-dois-6">Article level version DOI must be second in article-meta. This version DOI has a following sibling DOI or a preceding version specific DOI.</report>
      
      <report test="@specific-use and @specific-use!='version'" 
        role="error" 
        id="prc-article-dois-7">Article DOI has a specific-use attribute value <value-of select="@specific-use"/>. The only permitted value is 'version'.</report>
      
      <report test="@specific-use and number(substring-after(.,concat($article-id,'.'))) != (number($latest-rp-doi-version)+1)" 
        role="error" 
        id="final-prc-article-dois-8">The version DOI for this Reviewed preprint version needs to end with a number that is one more than whatever number the last published reviewed preprint version DOI ends with. This version DOI ends with <value-of select="substring-after(.,concat($article-id,'.'))"/> (<value-of select="."/>), whereas <value-of select="if ($latest-rp-doi-version='0') then 'there is no previous reviewed preprint version in the pub-history' else concat('the latest reviewed preprint DOI in the publication history ends with ',$latest-rp-doi-version,' (',$latest-rp-doi,')')"/>. Either there is a missing reviewed preprint publication event in the publication history, or the version DOI is incorrect.</report>
      
      </rule>
      
      <rule context="article/front/article-meta/author-notes" id="author-notes-checks">
        <report test="count(corresp) gt 1" 
          role="error" 
          id="multiple-corresp">author-notes contains <value-of select="count(corresp)"/> corresp elements. There should only be one. Either these can be collated into one corresp or one of these is a footnote which has been incorrectly captured.</report>
     </rule>

      <rule context="article/front/article-meta/author-notes/fn" id="author-notes-fn-checks">
        <let name="id" value="@id"/>
        <let name="known-types" value="('abbr','con','coi-statement','deceased','equal','financial-disclosure','presented-at','present-address','supported-by')"/>
        <report test="@fn-type='present-address' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)" 
          role="error" 
          id="author-fn-1">Present address type footnote (id=<value-of select="$id"/>) in author-notes is not linked to from any specific author, which must be a mistake. "<value-of select="."/>"</report>
        
        <report test="@fn-type='equal' and (count(ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id]) lt 2)" 
          role="error" 
          id="author-fn-2">Equal author type footnote (id=<value-of select="$id"/>) in author-notes is linked to from <value-of select="count(ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id])"/> author(s), which must be a mistake. "<value-of select="."/>"</report>
        
        <report test="@fn-type='deceased' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)" 
          role="error" 
          id="author-fn-3">Deceased type footnote (id=<value-of select="$id"/>) in author-notes is not linked to from any specific author, which must be a mistake. "<value-of select="."/>"</report>
        
        <report test="@fn-type=('abbr','con','coi-statement','financial-disclosure','presented-at','supported-by') and (ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)" 
          role="warning" 
          id="author-fn-4"><value-of select="@fn-type"/> type footnote (id=<value-of select="$id"/>) in author-notes usually contains content that relates to all authors instead of a subset. This one however is linked to from <value-of select="ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id]"/> author(s) (<value-of select="string-join(for $x in ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id] return e:get-name($x/name[1]),'; ')"/>). "<value-of select="."/>"</report>
        
        <report test="@fn-type and not(@fn-type=$known-types)" 
          role="warning" 
          id="author-fn-5">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>' which is not one of the known values (<value-of select="string-join($known-types,'; ')"/>). Should it be changed to be one of the values? "<value-of select="."/>"</report>
        
        <report test="@fn-type=('abbr','con','coi-statement','financial-disclosure','presented-at','supported-by') and @fn-type = preceding-sibling::fn/@fn-type" 
          role="warning" 
          id="author-fn-6">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>', but there's another footnote with that same type. Are two separate notes necessary? Are they duplicates?</report>
        
        <report test="@fn-type='coi-statement' and preceding-sibling::fn[@fn-type='financial-disclosure']" 
          role="warning" 
          id="author-fn-7">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>', but there's another footnote with the type 'financial-disclosure'. Are two separate notes necessary? Are they duplicates?</report>
        
        <report test="@fn-type='financial-disclosure' and preceding-sibling::fn[@fn-type='coi-statement']" 
          role="warning" 
          id="author-fn-8">footnote with id <value-of select="$id"/> has the fn-type '<value-of select="@fn-type"/>', but there's another footnote with the type 'coi-statement'. Are two separate notes necessary? Are they duplicates?</report>
        
        <report test="label[matches(.,'[\d\p{L}]')]" 
          role="warning" 
          id="author-fn-9">footnote with id <value-of select="$id"/> has a label that contains a letter or number '<value-of select="label[1]"/>'. If they are part of a sequence that also includes affiliation labels this will look odd on EPP (as affiliation labels are not rendered). Should they be replaced with symbols? eLife's style is to follow this sequence: *, †, ‡, §, ¶, **, ††, ‡‡, §§, ¶¶, etc.</report>
     </rule>

      <rule context="article/front/article-meta//article-version" id="article-version-checks">
        
        <report test="parent::article-meta and not(@article-version-type) and not(matches(.,'^1\.\d+$'))" 
          role="error" 
          id="article-version-2">article-version must be in the format 1.x (e.g. 1.11). This one is '<value-of select="."/>'.</report>
        
        <report test="parent::article-version-alternatives and not(@article-version-type=('publication-state','preprint-version'))" 
          role="error" 
          id="article-version-4">article-version placed within article-meta-alternatives must have an article-version-type attribute with either the value 'publication-state' or 'preprint-version'.</report>
        
        <report test="@article-version-type='preprint-version' and not(matches(.,'^1\.\d+$'))" 
          role="error" 
          id="article-version-5">article-version with the attribute article-version-type="preprint-version" must contain text in the format 1.x (e.g. 1.11). This one has '<value-of select="."/>'.</report>
        
        <report test="@article-version-type='publication-state' and .!='reviewed preprint'" 
          role="error" 
          id="article-version-6">article-version with the attribute article-version-type="publication-state" must contain the text 'reviewed preprint'. This one has '<value-of select="."/>'.</report>
        
        <report test="./@article-version-type = preceding-sibling::article-version/@article-version-type" 
          role="error" 
          id="article-version-7">article-version must be distinct. There is one or more article-version elements with the article-version-type <value-of select="@article-version-type"/>.</report>
        
        <report test="@*[name()!='article-version-type']" 
          role="error" 
          id="article-version-11">The only attribute permitted on <name/> is article-version-type. This one has the following unallowed attribute(s): <value-of select="string-join(@*[name()!='article-version-type']/name(),'; ')"/>.</report>
      </rule>
      
      <rule context="article/front/article-meta/article-version-alternatives" id="article-version-alternatives-checks">
        <assert test="count(article-version)=2" 
          role="error" 
          id="article-version-8">article-version-alternatives must contain 2 and only 2 article-version elements. This one has '<value-of select="count(article-version)"/>'.</assert>
        
        <assert test="article-version[@article-version-type='preprint-version']" 
          role="error" 
          id="article-version-9">article-version-alternatives must contain a &lt;article-version article-version-type="preprint-version">.</assert>
        
        <assert test="article-version[@article-version-type='publication-state']" 
          role="error" 
          id="article-version-10">article-version-alternatives must contain a &lt;article-version article-version-type="publication-state">.</assert>
      </rule>
      
      <rule context="article/front[journal-meta/journal-id='elife']/article-meta[matches(replace(article-id[@specific-use='version'][1],'^.*\.',''),'^\d\d?$') and matches(descendant::article-version[@article-version-type='preprint-version'][1],'^1\.\d+$')]" id="rp-and-preprint-version-checks">
        <let name="preprint-version" value="number(substring-after(descendant::article-version[@article-version-type='preprint-version'][1],'.'))"/>
        <let name="rp-version" value="number(replace(article-id[@specific-use='version'][1],'^.*\.',''))"/>
        
        <assert test="$rp-version le $preprint-version" 
          role="error" 
          id="article-version-12">This is Reviewed Preprint version <value-of select="$rp-version"/>, but according to the article-version, it's based on preprint version <value-of select="$preprint-version"/>. This cannot be correct.</assert>
      </rule>

      <rule context="article/front/article-meta/pub-date[@pub-type='epub']/year" id="preprint-pub-checks">
        <assert test=".=('2024','2025')" 
          role="warning" 
          id="preprint-pub-date-1">This preprint version was posted in <value-of select="."/>. Is it the correct version that corresponds to the version submitted to eLife?</assert>
      </rule>

      <rule context="article/front/article-meta/contrib-group/contrib" id="contrib-checks">
        <report test="parent::contrib-group[not(preceding-sibling::contrib-group)] and @contrib-type!='author'" 
          role="error" 
          id="contrib-1">Contrib with the type '<value-of select="@contrib-type"/>' is present in author contrib-group (the first contrib-group within article-meta). This is not correct.</report>

        <report test="parent::contrib-group[not(preceding-sibling::contrib-group)] and not(@contrib-type)" 
          role="error" 
          id="contrib-2">Contrib without the attribute contrib-type="author" is present in author contrib-group (the first contrib-group within article-meta). This is not correct.</report>

        <report test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type)" 
          role="error" 
          id="contrib-3">The second contrib-group in article-meta should (only) contain Reviewing and Senior Editors. This contrib is placed in that group, but it does not have a contrib-type. Add the correct contrib-type for the Editor.</report>

        <report test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type=('editor','senior_editor'))" 
          role="error" 
          id="contrib-4">The second contrib-group in article-meta should (only) contain Reviewing and Senior Editors. This contrib is placed in that group, but it has the contrib-type <value-of select="@contrib-type"/>.</report>
      </rule>
      
      <rule context="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/volume" id="volume-test">
        <let name="is-first-version" value="if (ancestor::article-meta/article-id[@specific-use='version' and ends-with(.,'.1')]) then true()
                                          else if (not(ancestor::article-meta/pub-history[event[date[@date-type='reviewed-preprint']]])) then true()
                                          else false()"/>
        <let name="pub-date" value=" if (not($is-first-version)) then parent::article-meta/pub-history[1]/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]
         else if (ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic']) then ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic'][1]/year[1]
         else string(year-from-date(current-date()))"/>
      
        <report test=".='' or (. != (number($pub-date) - 2011))" 
          role="error" 
          id="volume-test-1">volume is incorrect. It should be <value-of select="number($pub-date) - 2011"/>.</report>
      </rule>
      
      <rule context="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/elocation-id" id="elocation-id-test">
        <let name="msid" value="parent::article-meta/article-id[@pub-id-type='publisher-id']"/>
        
        <assert test="matches(.,'^RP\d{5,6}$')" 
          role="error" 
          id="elocation-id-test-1">The content of elocation-id must 'RP' followed by a 5 or 6 digit MSID. This is not in that format: <value-of select="."/>.</assert>
        
        <report test="$msid and not(.=concat('RP',$msid))" 
          role="error" 
          id="elocation-id-test-2">The content of elocation-id must 'RP' followed by the 5 or 6 digit MSID (<value-of select="$msid"/>). This is not in that format (<value-of select="."/> != <value-of select="concat('RP',$msid)"/>).</report>
      </rule>
      
      <rule context="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/history" id="history-tests">
      
        <assert test="count(date[@date-type='sent-for-review']) = 1" 
          role="error" 
          id="prc-history-date-test-1">history must contain one (and only one) date[@date-type='sent-for-review'] in Reviewed preprints.</assert>
      
        <report test="date[@date-type!='sent-for-review' or not(@date-type)]" 
          role="error" 
          id="prc-history-date-test-2">Reviewed preprints can only have sent-for-review dates in their history. This one has a <value-of select="if (date[@date-type!='sent-for-review']) then date[@date-type!='sent-for-review']/@date-type else 'undefined'"/> date.</report>
      
    </rule>
      
      <rule context="article[front[journal-meta/lower-case(journal-id[1])='elife']]//pub-history" id="pub-history-tests">
        <let name="version-from-doi" value="replace(ancestor::article-meta[1]/article-id[@pub-id-type='doi' and @specific-use='version'][1],'^.*\.','')"/>
        <let name="is-revised-rp" value="if ($version-from-doi=('','1')) then false() else true()"/>
      
      <assert test="parent::article-meta" 
        role="error" 
        id="pub-history-parent"><name/> is only allowed to be captured as a child of article-meta. This one is a child of <value-of select="parent::*/name()"/>.</assert>
      
      <assert test="count(event) ge 1" 
        role="error" 
        id="pub-history-events-1"><name/> in Reviewed Preprints must have at least one event element. This one has <value-of select="count(event)"/> event elements.</assert>
      
      <report test="count(event[self-uri[@content-type='preprint']]) != 1" 
        role="error" 
        id="pub-history-events-2"><name/> must contain one, and only one preprint event (an event with a self-uri[@content-type='preprint'] element). This one has <value-of select="count(event[self-uri[@content-type='preprint']])"/> preprint event elements.</report>
      
      <report test="$is-revised-rp and (count(event[self-uri[@content-type='reviewed-preprint']]) != (number($version-from-doi) - 1))" 
        role="error" 
        id="pub-history-events-3">The <name/> for revised reviewed preprints must have one event (with a self-uri[@content-type='reviewed-preprint'] element) element for each of the previous reviewed preprint versions. There are <value-of select="count(event[self-uri[@content-type='reviewed-preprint']])"/> reviewed preprint publication events in pub-history,. but since this is reviewed preprint version <value-of select="$version-from-doi"/> there should be <value-of select="number($version-from-doi) - 1"/>.</report>
      
      <report test="count(event[self-uri[@content-type='reviewed-preprint']]) gt 3" 
        role="warning" 
        id="pub-history-events-4"><name/> has <value-of select="count(event[self-uri[@content-type='reviewed-preprint']])"/> reviewed preprint event elements, which is unusual. Is this correct?</report>
    </rule>
      
      <rule context="event" id="event-tests">
      <let name="date" value="date[1]/@iso-8601-date"/>
      
      <assert test="event-desc" 
        role="error" 
        id="event-test-1"><name/> must contain an event-desc element. This one does not.</assert>
      
      <assert test="date[@date-type=('preprint','reviewed-preprint')]" 
        role="error" 
        id="event-test-2"><name/> must contain a date element with the attribute date-type="preprint" or date-type="reviewed-preprint". This one does not.</assert>
      
      <assert test="self-uri" 
        role="error" 
        id="event-test-3"><name/> must contain a self-uri element. This one does not.</assert>
        
        <report test="following-sibling::event[date[@iso-8601-date lt $date]]" 
          role="error" 
          id="event-test-4">Events in pub-history must be ordered chronologically in descending order. This event has a date (<value-of select="$date"/>) which is later than the date of a following event (<value-of select="preceding-sibling::event[date[@iso-8601-date lt $date]][1]"/>).</report>
      
      <report test="date and self-uri and date[1]/@date-type != self-uri[1]/@content-type" 
        role="error" 
        id="event-test-5">This event in pub-history has a date with the date-type <value-of select="date[1]/@date-type"/>, but a self-uri with the content-type <value-of select="self-uri[1]/@content-type"/>. These values should be the same, so one (or both of them) are incorrect.</report>
    </rule>
      
      <rule context="event/*" id="event-child-tests">
      <let name="allowed-elems" value="('event-desc','date','self-uri')"/>
      
      <assert test="name()=$allowed-elems" 
        role="error" 
        id="event-child"><name/> is not allowed in an event element. The only permitted children of event are <value-of select="string-join($allowed-elems,', ')"/>.</assert>
    </rule>
      
      <rule context="event[date[@date-type='reviewed-preprint']/@iso-8601-date != '']" id="rp-event-tests">
      <let name="rp-link" value="self-uri[@content-type='reviewed-preprint']/@*:href"/>
      <let name="rp-version" value="replace($rp-link,'^.*\.','')"/>
      <let name="rp-pub-date" value="date[@date-type='reviewed-preprint']/@iso-8601-date"/>
      <let name="sent-for-review-date" value="ancestor::article-meta/history/date[@date-type='sent-for-review']/@iso-8601-date"/>
      <let name="preprint-pub-date" value="parent::pub-history/event/date[@date-type='preprint']/@iso-8601-date"/>
      <let name="later-rp-events" value="parent::pub-history/event[date[@date-type='reviewed-preprint'] and replace(self-uri[@content-type='reviewed-preprint'][1]/@*:href,'^.*\.','') gt $rp-version]"/>
      
      <report test="($preprint-pub-date and $preprint-pub-date != '') and
        $preprint-pub-date ge $rp-pub-date"
        role="error" 
        id="rp-event-test-1">Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than the preprint posted date (<value-of select="$preprint-pub-date"/>), which must be incorrect.</report>
      
      <report test="($sent-for-review-date and $sent-for-review-date != '') and
        $sent-for-review-date ge $rp-pub-date"
        role="error" 
        id="rp-event-test-2">Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than the sent for review date (<value-of select="$sent-for-review-date"/>), which must be incorrect.</report>
      
      <report test="$later-rp-events/date/@iso-8601-date = $rp-pub-date"
        role="error" 
        id="rp-event-test-3">Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than publication date for a later reviewed preprint version date (<value-of select="$later-rp-events/date/@iso-8601-date[. = $rp-pub-date]"/> for version(s) <value-of select="$later-rp-events/self-uri[@content-type='reviewed-preprint'][1]/@*:href/replace(.,'^.*\.','')"/>). This must be incorrect.</report>
        
      <assert test="self-uri[@content-type='editor-report']"
        role="error" 
        id="rp-event-test-4">The event-desc for Reviewed preprint publication events must have a &lt;self-uri content-type="editor-report"> (which has a DOI link to the eLife Assessment for that version).</assert>
        
     <assert test="self-uri[@content-type='referee-report']"
        role="error" 
        id="rp-event-test-5">The event-desc for Reviewed preprint publication events must have at least one &lt;self-uri content-type="referee-report"> (which has a DOI link to a public review for that version).</assert>
    </rule>
      
      <rule context="event-desc" id="event-desc-tests">
      
      <report test="parent::event/self-uri[1][@content-type='preprint'] and .!='Preprint posted'" 
        role="error" 
        id="event-desc-content"><name/> that's a child of a preprint event must contain the text 'Preprint posted'. This one does not (<value-of select="."/>).</report>
      
      <report test="parent::event/self-uri[1][@content-type='reviewed-preprint'] and .!=concat('Reviewed preprint v',replace(parent::event[1]/self-uri[1][@content-type='reviewed-preprint']/@*:href,'^.*\.',''))" 
        role="error" 
        id="event-desc-content-2"><name/> that's a child of a Reviewed preprint event must contain the text 'Reviewed preprint v' followwd by the verison number for that Reviewed preprint version. This one does not (<value-of select="."/> != <value-of select="concat('Reviewed preprint v',replace(parent::event[1]/self-uri[1][@content-type='reviewed-preprint']/@*:href,'^.*\.',''))"/>).</report>
      
      <report test="*" 
        role="error" 
        id="event-desc-elems"><name/> cannot contain elements. This one has the following: <value-of select="string-join(distinct-values(*/name()),', ')"/>.</report>
      
    </rule>
      
      <rule context="event/date" id="event-date-tests">
      
      <assert test="day and month and year" 
        role="error" 
        id="event-date-child"><name/> in event must have a day, month and year element. This one does not.</assert>
      
      <assert test="@date-type=('preprint','reviewed-preprint')" 
        role="error" 
        id="event-date-type"><name/> in event must have a date-type attribute with the value 'preprint' or 'reviewed-preprint'.</assert>
    </rule>
      
      <rule context="event/self-uri" id="event-self-uri-tests">
      <let name="article-id" value="ancestor::article-meta/article-id[@pub-id-type='publisher-id']"/>
      
      <assert test="@content-type=('preprint','reviewed-preprint','editor-report','referee-report','author-comment')" 
        role="error" 
        id="event-self-uri-content-type"><name/> in event must have the attribute content-type="preprint" or content-type="reviewed-preprint". This one does not.</assert>
      
      <report test="@content-type=('preprint','reviewed-preprint') and (* or normalize-space(.)!='')" 
        role="error" 
        id="event-self-uri-content-1"><name/> with the content-type <value-of select="@content-type"/> must not have any child elements or text. This one does.</report>
        
      <report test="@content-type='editor-report' and (* or not(matches(.,'^eLife [Aa]ssessment$')))" 
        role="error" 
        id="event-self-uri-content-2"><name/> with the content-type <value-of select="@content-type"/> must not have any child elements, and contain the text 'eLife Assessment'. This one does not.</report>
        
      <report test="@content-type='referee-report' and (* or .='')" 
        role="error" 
        id="event-self-uri-content-3"><name/> with the content-type <value-of select="@content-type"/> must not have any child elements, and contain the title of the public review as text. This self-uri either has child elements or it is empty.</report>
        
      <report test="@content-type='author-comment' and (* or not(matches(.,'^Author [Rr]esponse:?\s?$')))" 
        role="error" 
        id="event-self-uri-content-4"><name/> with the content-type <value-of select="@content-type"/> must not have any child elements, and contain the title of the text 'Author response'. This one does not.</report>
      
      <assert test="matches(@*:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;&lt;&gt;//=]*)$')" 
        role="error" 
        id="event-self-uri-href-1"><name/> in event must have an xlink:href attribute containing a link to the preprint. This one does not have a valid URI - <value-of select="@*:href"/>.</assert>
      
      <report test="matches(lower-case(@*:href),'(bio|med)rxiv')" 
        role="error" 
        id="event-self-uri-href-2"><name/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. bioRxiv and medRxiv preprint have dois, and this one points to one of those, but it is not a doi - <value-of select="@*:href"/>.</report>
      
      <assert test="matches(@*:href,'https?://(dx.doi.org|doi.org)/')" 
        role="warning" 
        id="event-self-uri-href-3"><name/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. This one is not a doi - <value-of select="@*:href"/>. Please check whether there is a doi that can be used instead.</assert>
      
      <report test="@content-type='reviewed-preprint' and not(matches(@*:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]$'))" 
        role="error" 
        id="event-self-uri-href-4"><name/> in event has the attribute content-type="reviewed-preprint", but the xlink:href attribute does not contain an eLife version specific DOI - <value-of select="@*:href"/>.</report>
      
      <report test="(@content-type!='reviewed-preprint' or not(@content-type)) and matches(@*:href,'^https://doi.org/10.7554/eLife.\d+\.\d$')" 
        role="error" 
        id="event-self-uri-href-5"><name/> in event does not have the attribute content-type="reviewed-preprint", but the xlink:href attribute contains an eLife version specific DOI - <value-of select="@*:href"/>. If it's a preprint event, the link should be to a preprint. If it's an event for reviewed preprint publication, then it should have the attribute content-type!='reviewed-preprint'.</report>
      
      <report test="@content-type='reviewed-preprint' and not(contains(@*:href,$article-id))" 
        role="error" 
        id="event-self-uri-href-6"><name/> in event the attribute content-type="reviewed-preprint", but the xlink:href attribute value (<value-of select="@*:href"/>) does not contain the article id (<value-of select="$article-id"/>) which must be incorrect, since this should be the version DOI for the reviewed preprint version.</report>
        
      <report test="@content-type=('editor-report','referee-report','author-comment') and not(matches(@*:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]\.sa\d+$'))" 
        role="error" 
        id="event-self-uri-href-7"><name/> in event has the attribute content-type="<value-of select="@content-type"/>", but the xlink:href attribute does not contain an eLife peer review DOI - <value-of select="@*:href"/>.</report>
    </rule>
      
       <rule context="funding-group" id="funding-group-presence-tests">
        <report test="." 
          role="warning" 
          id="funding-group-presence">This Reviewed preprint contains a funding-group. Please check the details carefully and correct, as necessary.</report>
       </rule>
      
      <rule context="funding-group" id="funding-group-tests">
        
        <report test="preceding-sibling::funding-group" 
          role="error" 
          id="multiple-funding-group-presence">There cannot be more than one funding-group element in article-meta.</report>
        
        <assert test="award-group or funding-statement" 
          role="error" 
          id="funding-group-empty">funding-group must contain at least either am award-group or a funding-statement element. This one has neither</assert>
      </rule>
      
      <rule context="funding-group/award-group" id="award-group-tests">
        <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-2" 
          test="funding-source" 
          role="error" 
          id="award-group-test-2">award-group must contain a funding-source.</assert>
        
        <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-4" 
          test="count(award-id) gt 1" 
          role="error" 
          id="award-group-test-4">award-group may contain one and only one award-id.</report>
        
        <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-5" 
          test="funding-source/institution-wrap" 
          role="error" 
          id="award-group-test-5">funding-source must contain an institution-wrap.</assert>
        
        <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-6" 
          test="count(funding-source/institution-wrap/institution) = 0" 
          role="error" 
          id="award-group-test-6">Every piece of funding must have an institution. &lt;award-group id="<value-of select="@id"/>"&gt; does not have one.</report>
        
        <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-8" 
          test="count(funding-source/institution-wrap/institution) gt 1" 
          role="error" 
          id="award-group-test-8">Every piece of funding must only have 1 institution. &lt;award-group id="<value-of select="@id"/>"&gt; has <value-of select="count(funding-source/institution-wrap/institution)"/> - <value-of select="string-join(funding-source/institution-wrap/institution,', ')"/>.</report>
        
        <report test="count(funding-source/institution-wrap/institution-id) gt 1" 
        role="error" 
        sqf:fix="pick-funding-ror-1 pick-funding-ror-2 pick-funding-ror-3"
        id="award-group-multiple-ids">Funding contains more than one institution-id element: <value-of select="string-join(descendant::institution-id,'; ')"/> in <value-of select="."/></report>
        
        <sqf:fix id="pick-funding-ror-1">
        <sqf:description>
          <sqf:title>Pick ROR option 1</sqf:title>
        </sqf:description>
        <sqf:delete match="descendant::institution-wrap/comment()|
          descendant::institution-wrap/institution-id[position() != 1]|
          descendant::institution-wrap/text()[not(position()=(1,last()))]"/>
      </sqf:fix>
      
      <sqf:fix id="pick-funding-ror-2">
        <sqf:description>
          <sqf:title>Pick ROR option 2</sqf:title>
        </sqf:description>
        <sqf:delete match="descendant::institution-wrap/comment()|
          descendant::institution-wrap/institution-id[position() != 2]|
          descendant::institution-wrap/text()[not(position()=(1,last()))]"/>
      </sqf:fix>
      
      <sqf:fix id="pick-funding-ror-3" use-when="count(descendant::institution-id) gt 2">
        <sqf:description>
          <sqf:title>Pick ROR option 3</sqf:title>
        </sqf:description>
        <sqf:delete match="descendant::institution-wrap/comment()|
          descendant::institution-wrap/institution-id[position() != 3]|
          descendant::institution-wrap/text()[not(position()=(1,last()))]"/>
      </sqf:fix>
      </rule>
      
      <rule context="funding-group/award-group[award-id[not(@award-id-type='doi') and normalize-space(.)!=''] and funding-source/institution-wrap[count(institution-id)=1]/institution-id[not(.=$grant-doi-exception-funder-ids)]]" id="general-grant-doi-tests">
        <let name="award-id" value="award-id"/>
        <let name="funder-id" value="funding-source/institution-wrap/institution-id"/>
        <let name="funder-entry" value="document($rors)//*:ror[*:id[@type='ror']=$funder-id]"/>
        <let name="mints-grant-dois" value="$funder-entry/@grant-dois='yes'"/>
        <!-- Consider alternatives to exact match as this is no better than simply using Crossref's API -->
        <let name="grant-matches" value="if (not($mints-grant-dois)) then ()
          else $funder-entry//*:grant[@award=$award-id]"/>
	  
        <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#grant-doi-test-1" 
          test="$grant-matches"
	         role="warning" 
	         id="grant-doi-test-1">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id"/>) which could potentially be replaced with a grant DOI. The following grant DOIs are possibilities: <value-of select="string-join(for $grant in $grant-matches return concat('https://doi.org/',$grant/@doi),'; ')"/>.</report>

        <!-- If the funder has minted 30+ grant DOIs but there isn't an exact match throw a warning -->
        <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#grant-doi-test-2" 
          test="$mints-grant-dois and (count($funder-entry//*:grant) gt 29) and not($grant-matches)"
	         role="warning" 
	         id="grant-doi-test-2">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id"/>). The award id hasn't exactly matched the details of a known grant DOI, but the funder is known to mint grant DOIs (for example in the format <value-of select="$funder-entry/descendant::*:grant[1]/@doi"/> for ID <value-of select="$funder-entry/descendant::*:grant[1]/@award"/>). Does the award ID in the article contain a number/string within it that can be used to find a match here: https://api.crossref.org/works?filter=type:grant,award.number:[insert-grant-number]</report>
      
	   </rule>
      
      <rule context="funding-group/award-group[not(award-id) and funding-source/institution-wrap[count(institution-id)=1]/institution-id]" id="general-funding-no-award-id-tests">
        <let name="funder-id" value="funding-source/institution-wrap/institution-id"/>
        <let name="funder-entry" value="document($rors)//*:ror[*:id[@type='ror']=$funder-id]"/>
        <let name="grant-doi-count" value="count($funder-entry//*:grant)"/>
      
        <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#grant-doi-test-3" 
          test="$grant-doi-count gt 29"
	         role="warning" 
	         id="grant-doi-test-3">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has no award-id, but the funder is known to mint grant DOIs (for example in the format <value-of select="$funder-entry/descendant::*:grant[1]/@doi"/> for ID <value-of select="$funder-entry/descendant::*:grant[1]/@award"/>). Is there a missing grant DOI or award ID for this funding?</report>
      </rule>
      
      <rule context="funding-group/award-group[award-id[not(@award-id-type='doi')] and funding-source/institution-wrap/institution-id=$wellcome-funder-ids]" id="wellcome-grant-doi-tests">
      <let name="grants" value="document($rors)//*:ror[*:id=$wellcome-funder-ids]/*:grant"/>
      <let name="award-id-elem" value="award-id"/>
      <let name="award-id" value="e:alter-award-id($award-id-elem,$wellcome-funder-ids[last()])"/> 
      <let name="grant-matches" value="if ($award-id='') then ()
        else $grants[@award=$award-id]"/>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#wellcome-grant-doi-test-1"
        test="$grant-matches"
        role="warning" 
        sqf:fix="add-grant-doi"
        id="wellcome-grant-doi-test-1">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>) which could potentially be replaced with a grant DOI. The following grant DOIs are possibilities: <value-of select="string-join(for $grant in $grant-matches return concat('https://doi.org/',$grant/@doi),'; ')"/>.</report>

      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#wellcome-grant-doi-test-2"
        test="$grant-matches"
        role="warning" 
        id="wellcome-grant-doi-test-2">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>). The award id hasn't exactly matched the details of a known grant DOI, but the funder is known to mint grant DOIs (for example in the format <value-of select="$grants[1]/@doi"/> for ID <value-of select="$grants[1]/@award"/>). Does the award ID in the article contain a number/string within it that can be used to find a match here: https://api.crossref.org/works?filter=type:grant,award.number:[insert-grant-number]</assert>
    </rule>
      
      <rule context="funding-group/award-group[award-id[not(@award-id-type='doi')] and funding-source/institution-wrap/institution-id=($eu-horizon-fundref-ids,'https://ror.org/00k4n6c32')]" id="eu-horizon-grant-doi-tests">
      <let name="eu-comission-ror-id" value="'https://ror.org/00k4n6c32'"/>
      <let name="funder-id" value="funding-source/institution-wrap/institution-id"/>
      <let name="grants" value="document($rors)//*:ror[*:id[@type='ror']=$eu-comission-ror-id]/*:grant"/>
      <let name="award-id" value="e:alter-award-id(award-id[1],$funder-id)"/> 
      <let name="grant-matches" value="if ($award-id='') then ()
        else $grants[@award=$award-id]"/>
      
      <report test="$grant-matches"
        role="warning" 
        sqf:fix="add-grant-doi"
        id="eu-horizon-grant-doi-test-1">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="award-id[1]"/>) which could potentially be replaced with a grant DOI. The following grant DOIs are possibilities: <value-of select="string-join(for $grant in $grant-matches return concat('https://doi.org/',$grant/@doi),'; ')"/>.</report>

      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#wellcome-grant-doi-test-2"
        test="$grant-matches"
        role="warning" 
        id="eu-horizon-grant-doi-test-2">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="award-id[1]"/>). The award id hasn't exactly matched the details of a known grant DOI, but the funder is known to mint grant DOIs (for example in the format <value-of select="$grants[1]/@doi"/> for ID <value-of select="$grants[1]/@award"/>). Does the award ID in the article contain a number/string within it that can be used to find a match here: https://api.crossref.org/works?filter=type:grant,award.number:[insert-grant-number]</assert>
    </rule>

    <rule context="funding-group/award-group[award-id[not(@award-id-type='doi')] and funding-source/institution-wrap/institution-id=$known-grant-funder-ids]" id="known-grant-funder-grant-doi-tests">
      <let name="funder-id" value="funding-source/institution-wrap/institution-id"/>
      <let name="grants" value="document($rors)//*:ror[*:id[@type=('ror','fundref')]=$funder-id]/*:grant"/>
      <let name="award-id-elem" value="award-id"/>
      <!-- Make use of custom function to try and account for variations within funder conventions -->
      <let name="award-id" value="e:alter-award-id($award-id-elem,$funder-id)"/>
      <let name="grant-matches" value="if ($award-id='') then ()
        else $grants[@award=$award-id]"/>
    
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#known-grant-funder-grant-doi-test-1"
        test="$grant-matches"
        role="warning"
        sqf:fix="add-grant-doi"
        id="known-grant-funder-grant-doi-test-1">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>) which could potentially be replaced with a grant DOI. The following grant DOIs are possibilities: <value-of select="string-join(for $grant in $grant-matches return concat('https://doi.org/',$grant/@doi),'; ')"/>.</report>

      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#known-grant-funder-grant-doi-test-2"
        test="$grant-matches"
        role="warning" 
        id="known-grant-funder-grant-doi-test-2">Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>). The award id hasn't exactly matched the details of a known grant DOI, but the funder is known to mint grant DOIs (for example in the format <value-of select="$grants[1]/@doi"/> for ID <value-of select="$grants[1]/@award"/>). Does the award ID in the article contain a number/string within it that can be used to find a match here: https://api.crossref.org/works?filter=type:grant,award.number:[insert-grant-number]</assert>

    </rule>
    
    <rule context="funding-group/award-group/award-id" id="award-id-tests">
      <let name="id" value="parent::award-group/@id"/>
      <let name="funder-id" value="parent::award-group/descendant::institution-id[1]"/>
      <let name="funder-name" value="parent::award-group/descendant::institution[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-1" 
        test="matches(.,',|;')" 
        role="warning" 
        id="award-id-test-1">Funding entry with id <value-of select="$id"/> has a comma or semi-colon in the award id. Should this be separated out into several funding entries? - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-2" 
        test="matches(.,'^\p{Zs}?[Nn][/]?[\.]?[Aa][.]?\p{Zs}?$')" 
        role="error" 
        id="award-id-test-2">Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-3" 
        test="matches(.,'^\p{Zs}?[Nn]one[\.]?\p{Zs}?$')" 
        role="error" 
        id="award-id-test-3">Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-4" 
        test="matches(.,'&amp;#x\d')" 
        role="warning" 
        id="award-id-test-4">Award id contains what looks like a broken unicode - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-5" 
          test="matches(.,'http[s]?://d?x?\.?doi.org/')" 
        role="error" 
        id="award-id-test-5">Award id contains a DOI link - <value-of select="."/>. If the award ID is for a grant DOI it should contain the DOI without the https://... protocol (e.g. 10.37717/220020477).</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-6" 
          test=". = preceding::award-id[parent::award-group/descendant::institution-id[1] = $funder-id]" 
        role="error" 
        id="award-id-test-6">Funding entry has an award id - <value-of select="."/> - which is also used in another funding entry with the same institution ID. This must be incorrect. Either the funder ID or the award ID is wrong, or it is a duplicate that should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-7" 
          test=". = preceding::award-id[parent::award-group/descendant::institution[1] = $funder-name]" 
        role="error" 
        id="award-id-test-7">Funding entry has an award id - <value-of select="."/> - which is also used in another funding entry with the same funder name. This must be incorrect. Either the funder name or the award ID is wrong, or it is a duplicate that should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-8" 
          test=".!='' and . = preceding::award-id[parent::award-group[not(descendant::institution[1] = $funder-name) and not(descendant::institution-id[1] = $funder-id)]]" 
        role="warning" 
        id="award-id-test-8">Funding entry has an award id - <value-of select="."/> - which is also used in another funding entry with a different funder. Has there been a mistake with the award id? If the grant was awarded jointly by two funders, then this capture is correct and should be retained.</report>
      
      <report test="normalize-space(.)=''" 
        role="error" 
        id="award-id-test-9">award-id cannot be empty. Either add the missing content or remove it.</report>
      
      <report test="not(@award-id-type='doi') and matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')" 
        role="error" 
        id="award-id-test-10">award-id contains a DOI (<value-of select="."/>), but it does not have the attribute award-id-type="doi".</report>
      
      <report test="matches(lower-case(.),'\s+(and|&amp;)\s+')" 
        role="warning" 
        id="award-id-test-11">award-id contains 'and' or an ampersand - <value-of select="."/>. Each separate award needs its own funding entry. If these are two separate grant numbers, please split them out.</report>
      
      <report test="@award-id-type='doi' and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))" 
        role="error" 
        id="award-id-test-12">award-id has the attribute award-id-type="doi" but it does not contain a valid DOI (<value-of select="."/>).</report>
      
      <report test="matches(lower-case(.),'grant')" 
        role="warning" 
        id="award-id-test-13">award-id contains the phrase 'grant' (<value-of select="."/>). Should it be removed?</report>
    </rule>
      
      <rule context="funding-source//institution-id" id="funding-institution-id-tests">
      
      <assert test="@institution-id-type=('ror','FundRef')" 
        role="error" 
        id="funding-institution-id-test-1">institution-id in funding must have the attribute institution-id-type with a value of either "ror" or "FundRef".</assert>
      
      <assert test="matches(.,'^(https?://ror\.org/[a-z0-9]{9}|http[s]?://d?x?\.?doi.org/10.13039/\d*)$')"
        role="error" 
        sqf:fix="delete-elem"
        id="funding-institution-id-test-2">institution-id in funding must a value which is either a valid ROR id or open funder registry DOI. This one has '<value-of select="."/>'.</assert>
      
      <report test="*" 
        role="error" 
        id="funding-institution-id-test-3">institution-id in funding cannot contain elements, only text (which is a valid ROR id). This one contains the following element(s): <value-of select="string-join(*/name(),'; ')"/>.</report>    
      
    </rule>
      
      <rule context="funding-source//institution-wrap" id="funding-institution-wrap-tests">
      
      <report test="count(institution-id)=1 and (normalize-space(string-join(text(),''))!='' or comment())" 
        role="error" 
        id="funding-institution-wrap-test-3">institution-wrap cannot contain text content or comments. It can only contain elements and whitespace.</report>  
        
    </rule>
      
      <rule context="funding-source[count(institution-wrap/institution-id[@institution-id-type='ror'])=1]" id="funding-ror-tests">
      <let name="rors" value="'rors.xml'"/>
      <let name="ror" value="institution-wrap[1]/institution-id[@institution-id-type='ror'][1]"/>
      <let name="matching-ror" value="document($rors)//*:ror[*:id=$ror]"/>
      
      <assert test="exists($matching-ror)"
        role="error" 
        id="funding-ror">Funding (<value-of select="institution-wrap[1]/institution[1]"/>) has a ROR id - <value-of select="$ror"/> - but it does not look like a correct one.</assert>
        
      <report test="$matching-ror[@status='withdrawn']"
        role="error" 
        id="funding-ror-status">Funding has a ROR id, but the ROR id's status is withdrawn. Withdrawn RORs should not be used. Should one of the following be used instead?: <value-of select="string-join(for $x in $matching-ror/*:relationships/* return concat('(',$x/name(),') ',$x/*:id,' ',$x/*:label),'; ')"/>.</report>
      
    </rule>
    </pattern>

    <pattern id="abstracts">
      <rule context="abstract[parent::article-meta]" id="abstract-checks">
        <let name="allowed-types" value="('structured','plain-language-summary','teaser','summary','graphical','video')"/>
        <!-- The only elements you'd expect to be permitted in an impact statement -->
        <let name="impact-statement-elems" value="('title','p','italic','bold','sup','sub','sc','monospace','xref')"/>
        <let name="word-count" value="count(for $x in tokenize(normalize-space(replace(.,'\p{P}','')),' ') return $x)"/>
        <report test="preceding::abstract[not(@abstract-type) and not(@xml:lang)] and not(@abstract-type) and not(@xml:lang)" 
          role="error" 
          id="abstract-test-1">There should only be one abstract without an abstract-type attribute (for the common-garden abstract) or xml:lang attirbute (for common-garden abstract in a language other than english). This asbtract does not have an abstract-type, but there is also a preceding abstract without an abstract-type or xml:lang. One of these needs to be given an abstract-type with the allowed values ('structured' for a syrctured abstract with sections; 'plain-language-summary' for a digest or author provided plain summary; 'teaser' for an impact statement; 'summary' for a general summary that's in addition to the common-garden abstract; 'graphical' for a graphical abstract).</report>

        <report test="@abstract-type and not(@abstract-type=$allowed-types)" 
          role="error" 
          id="abstract-test-2">abstract has an abstract-type (<value-of select="@abstract-type"/>), but it's not one of the permiited values: <value-of select="string-join($allowed-types,'; ')"/>.</report>
        
        <report test="matches(lower-case(title[1]),'funding')" 
          role="error" 
          id="abstract-test-3">abstract has a title that indicates it contains funding information (<value-of select="title[1]"/>) If this is funding information, it should be captured as a section in back or as part of an (if existing) structured abstract.</report>
        
        <report test="matches(lower-case(title[1]),'data')" 
          role="error" 
          id="abstract-test-4">abstract has a title that indicates it contains a data availability statement (<value-of select="title[1]"/>) If this is a data availability statement, it should be captured as a section in back.</report>
        
        <report test="descendant::fig and not(@abstract-type='graphical')" 
          role="error" 
          id="abstract-test-5">abstract has a descendant fig, but it does not have the attribute abstract-type="graphical". If it is a graphical abstract, it should have that type. If it's not a graphical abstract the content should be moved out of &lt;abstract></report>
        
        <report test="@abstract-type=$allowed-types and ./@abstract-type = preceding-sibling::abstract/@abstract-type" 
          role="warning" 
          id="abstract-test-6">abstract has the abstract-type '<value-of select="@abstract-type"/>', which is a permitted value, but it is not the only abstract with that type. It is very unlikely that two abstracts with the same abstract-type are required.</report>
        
        <report test="@abstract-type='teaser' and descendant::*[not(name()=$impact-statement-elems)]" 
          role="error" 
          id="abstract-test-7">abstract has the abstract-type 'teaser', meaning it is equivalent to an impact statement, but it has the following descendant elements, which prove it needs a different type <value-of select="string-join(distinct-values(descendant::*[not(name()=$impact-statement-elems)]/name()),'; ')"/>.</report>
        
        <report test="@abstract-type='teaser' and $word-count gt 60" 
          role="warning" 
          id="abstract-test-8">abstract has the abstract-type 'teaser', meaning it is equivalent to an impact statement, but it has greater than 60 words (<value-of select="$word-count"/>).</report>
        
        <report test="@abstract-type='teaser' and count(p) gt 1" 
          role="error" 
          id="abstract-test-9">abstract has the abstract-type 'teaser', meaning it is equivalent to an impact statement, but it has <value-of select="count(p)"/> paragraphs (whereas an impact statement would have only one paragraph).</report>
        
        <report test="@abstract-type='video' and not(descendant::*[name()=('ext-link','media','supplementary-file')])" 
          role="error" 
          id="abstract-test-10">abstract has the abstract-type 'video', but it does not have a media, supplementary-material or ext-link element. The abstract-type must be incorrect.</report>
      </rule>
      
      <rule context="abstract[parent::article-meta]/*" id="abstract-child-checks">
        <let name="allowed-children" value="('label','title','sec','p','fig','list')"/>
        <assert test="name()=$allowed-children" 
          role="error" 
          id="abstract-child-test-1"><name/> is not permitted within abstract.</assert>
      </rule>
      
      <rule context="abstract[@xml:lang]" id="abstract-lang-checks">
        <let name="xml-lang-value" value="@xml:lang"/>
        <let name="languages" value="'languages.xml'"/>
        <let name="subtag-description" value="string-join(document($languages)//*:item[@subtag=$xml-lang-value]/*:description,' / ')"/>
        <assert test="$subtag-description!=''" 
          role="error" 
          id="abstract-lang-test-1">The xml:lang attribute on <name/> must contain one of the IETF RFC 5646 subtags. '<value-of select="@xml:lang"/>' is not one of these values.</assert>
        
        <report test="$subtag-description!=''" 
          role="warning" 
          id="abstract-lang-test-2"><name/> has an xml:lang attribute with the value '<value-of select="$xml-lang-value"/>', which corresponds to the following language: <value-of select="$subtag-description"/>. Please check this is correct.</report>
      </rule>
    </pattern>

    <pattern id="permissions">
      <!-- All license types -->
	<rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions" id="front-permissions-tests">
	  <let name="author-contrib-group" value="ancestor::article-meta/contrib-group[1]"/>
	  <let name="copyright-holder" value="e:get-copyright-holder($author-contrib-group)"/>
	  <let name="license-type" value="license/@*:href"/>
	
	  <assert see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-4" 
	      test="*:free_to_read" 
        role="error" 
        id="permissions-test-4">permissions must contain an ali:free_to_read element.</assert>
	
	  <assert test="license" 
        role="error" 
        id="permissions-test-5">permissions must contain license.</assert>
	  
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-9" 
	    test="$license-type = ('http://creativecommons.org/publicdomain/zero/1.0/', 'https://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by/4.0/')" 
        role="error" 
        id="permissions-test-9">license does not have an @xlink:href which is equal to 'https://creativecommons.org/publicdomain/zero/1.0/' or 'https://creativecommons.org/licenses/by/4.0/'.</assert>
	  
	  <report see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-info" 
	      test="license" 
        role="info" 
        id="permissions-info">This article is licensed under a<value-of select="
	    if (contains($license-type,'publicdomain/zero')) then ' CC0 1.0'
	    else if (contains($license-type,'by/4.0')) then ' CC BY 4.0'
	    else if (contains($license-type,'by/3.0')) then ' CC BY 3.0'
	    else 'n unknown'"/> license. <value-of select="$license-type"/></report>
	
	</rule>
    
    <!-- CC BY licenses -->
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@*:href,'creativecommons.org/licenses/by/')]" id="cc-by-permissions-tests">
      <let name="author-contrib-group" value="ancestor::article-meta/contrib-group[1]"/>
      <let name="copyright-holder" value="e:get-copyright-holder($author-contrib-group)"/>
      <let name="license-type" value="license/@*:href"/>
      <let name="is-first-version" value="if (ancestor::article-meta/article-id[@specific-use='version' and ends-with(.,'.1')]) then true()
                                          else if (not(ancestor::article-meta/pub-history[event[date[@date-type='reviewed-preprint']]])) then true()
                                          else false()"/>
      <!-- dirty - needs doing based on first date rather than just position? -->
      <let name="authoritative-year" value="if (ancestor::article-meta/pub-date[@date-type='original-publication']) then ancestor::article-meta/pub-date[@date-type='original-publication'][1]/year[1]
        else if (not($is-first-version)) then ancestor::article-meta/pub-history/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]
        else string(year-from-date(current-date()))"/>
      
      <assert see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-1" 
        test="copyright-statement" 
        role="error" 
        id="permissions-test-1">permissions must contain copyright-statement in CC BY licensed articles.</assert>
      
      <assert see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-2" 
        test="matches(copyright-year[1],'^[0-9]{4}$')" 
        role="error" 
        id="permissions-test-2">permissions must contain copyright-year in the format 0000 in CC BY licensed articles. Currently it is <value-of select="copyright-year"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-3" 
        test="copyright-holder" 
        role="error" 
        id="permissions-test-3">permissions must contain copyright-holder in CC BY licensed articles.</assert>
      
      <assert see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-6" 
        test="copyright-year = $authoritative-year" 
        role="error" 
        id="permissions-test-6">copyright-year must match the year of first reviewed preprint publication date. Currently copyright-year=<value-of select="copyright-year"/> and authoritative pub-date=<value-of select="$authoritative-year"/>.</assert>
      
      <assert see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-7" 
        test="copyright-holder = $copyright-holder" 
        role="error" 
        id="permissions-test-7">copyright-holder is incorrect. If the article has one author then it should be their surname (or collab name). If it has two authors it should be the surname (or collab name) of the first, then ' &amp; ' and then the surname (or collab name) of the second. If three or more, it should be the surname (or collab name) of the first, and then ' et al'. Currently it's '<value-of select="copyright-holder"/>' when based on the author list it should be '<value-of select="$copyright-holder"/>'.</assert>
      
      <assert see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-8" 
        test="copyright-statement = concat('© ',copyright-year,', ',copyright-holder)" 
        role="error" 
        id="permissions-test-8">copyright-statement must contain a concatenation of '© ', copyright-year, and copyright-holder. Currently it is <value-of select="copyright-statement"/> when according to the other values it should be <value-of select="concat('© ',copyright-year,', ',copyright-holder)"/></assert>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#hztjj-permissions-test-16" 
          test="ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')]" 
        role="warning" 
        id="permissions-test-16">This article is CC-BY, but one or more of the authors are affiliated with the NIH (<value-of select="string-join(for $x in ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')] return $x,'; ')"/>). Should it be CC0 instead?</report>
      
      <let name="nih-rors" value="('https://ror.org/01cwqze88','https://ror.org/03jh5a977','https://ror.org/04r5s4b52','https://ror.org/04byxyr05','https://ror.org/02xey9a22','https://ror.org/040gcmg81','https://ror.org/04pw6fb54','https://ror.org/00190t495','https://ror.org/03wkg3b53','https://ror.org/012pb6c26','https://ror.org/00baak391','https://ror.org/043z4tv69','https://ror.org/006zn3t30','https://ror.org/00372qc85','https://ror.org/004a2wv92','https://ror.org/00adh9b73','https://ror.org/00j4k1h63','https://ror.org/04q48ey07','https://ror.org/04xeg9z08','https://ror.org/01s5ya894','https://ror.org/01y3zfr79','https://ror.org/049v75w11','https://ror.org/02jzrsm59','https://ror.org/04mhx6838','https://ror.org/00fq5cm18','https://ror.org/0493hgw16','https://ror.org/04vfsmv21','https://ror.org/00fj8a872','https://ror.org/0060t0j89','https://ror.org/01jdyfj45')"/>
      <report test="ancestor::article-meta/contrib-group[1]/aff[count(descendant::institution-id) = 1 and descendant::institution-id=$nih-rors]" 
        role="warning" 
        id="permissions-test-17">This article is CC-BY, but one or more of the authors are affiliated with the NIH (<value-of select="string-join(for $x in ancestor::article-meta/contrib-group[1]/aff[count(descendant::institution-id) = 1 and descendant::institution-id=$nih-rors] return $x,'; ')"/>). Should it be CC0 instead?</report>
      
    </rule>
    
    <!-- CC0 licenses -->
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@*:href,'creativecommons.org/publicdomain/zero')]" id="cc-0-permissions-tests">
      <let name="license-type" value="license/@*:href"/>
      
      <report see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-1" 
        test="copyright-statement" 
        role="error" 
        id="cc-0-test-1">This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-statement (<value-of select="copyright-statement"/>) which is not correct.</report>
      
      <report see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-2" 
        test="copyright-year" 
        role="error" 
        id="cc-0-test-2">This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-year (<value-of select="copyright-year"/>) which is not correct.</report>
      
      <report see ="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-3" 
        test="copyright-holder" 
        role="error" 
        id="cc-0-test-3">This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-holder (<value-of select="copyright-holder"/>) which is not correct.</report>
      
    </rule>
	
	<rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license" id="license-tests">
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-1" 
	      test="*:license_ref" 
        role="error" 
        id="license-test-1">license must contain ali:license_ref.</assert>
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-2" 
	      test="count(license-p) = 1" 
        role="error" 
        id="license-test-2">license must contain one and only one license-p.</assert>
	
	</rule>
    
    <rule context="front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license/license-p" id="license-p-tests">
      <let name="license-link" value="parent::license/@*:href"/>
      <let name="license-type" value="if (contains($license-link,'//creativecommons.org/publicdomain/zero/1.0/')) then 'cc0' else if (contains($license-link,'//creativecommons.org/licenses/by/4.0/')) then 'ccby' else ('unknown')"/>
      
      <let name="cc0-text" value="'This is an open-access article, free of all copyright, and may be freely reproduced, distributed, transmitted, modified, built upon, or otherwise used by anyone for any lawful purpose. The work is made available under the Creative Commons CC0 public domain dedication.'"/>
      <let name="ccby-text" value="'This article is distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use and redistribution provided that the original author and source are credited.'"/>
      
      <report test="($license-type='ccby') and .!=$ccby-text" 
        role="error" 
        id="license-p-test-1">The text in license-p is incorrect (<value-of select="."/>). Since this article is CCBY licensed, the text should be <value-of select="$ccby-text"/>.</report>
      
      <report test="($license-type='cc0') and .!=$cc0-text" 
        role="error" 
        id="license-p-test-2">The text in license-p is incorrect (<value-of select="."/>). Since this article is CC0 licensed, the text should be <value-of select="$cc0-text"/>.</report>
      
    </rule>
    
    <rule context="permissions/license[@*:href]/license-p" id="license-link-tests">
      <let name="license-link" value="parent::license/@*:href"/>
      
      <assert test="some $x in ext-link satisfies $x/@*:href = $license-link" 
        role="error" 
        id="license-p-test-3">If a license element has an xlink:href attribute, there must be a link in license-p that matches the link in the license/@xlink:href attribute. License link: <value-of select="$license-link"/>. Links in the license-p: <value-of select="string-join(ext-link/@*:href,'; ')"/>.</assert>
    </rule>
    
    <rule context="permissions/license[*:license_ref]/license-p" id="license-ali-ref-link-tests">
      <let name="ali-ref" value="parent::license/*:license_ref"/>
      
      <assert test="some $x in ext-link satisfies $x/@*:href = $ali-ref" 
        role="error" 
        id="license-p-test-4">If a license contains an ali:license_ref element, there must be a link in license-p that matches the link in the ali:license_ref element. ali:license_ref link: <value-of select="$ali-ref"/>. Links in the license-p: <value-of select="string-join(ext-link/@*:href,'; ')"/>.</assert>
    </rule>
      
      <rule context="fig[not(descendant::permissions)]|media[@mimetype='video' and not(descendant::permissions)]|table-wrap[not(descendant::permissions)]|supplementary-material[not(descendant::permissions)]" id="fig-permissions-check">
      <let name="label" value="replace(label[1],'\.','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-1" 
        test="matches(caption[1],'[Rr]eproduced from')" 
        role="warning" 
        id="reproduce-test-1">The caption for <value-of select="$label"/> contains the text 'reproduced from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-2" 
        test="matches(caption[1],'[Rr]eproduced [Ww]ith [Pp]ermission')" 
        role="warning" 
        id="reproduce-test-2">The caption for <value-of select="$label"/> contains the text 'reproduced with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-3" 
        test="matches(caption[1],'[Aa]d[ao]pted (from|with)')" 
        role="warning" 
        id="reproduce-test-3">The caption for <value-of select="$label"/> contains the text 'adapted from ...', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-4" 
        test="matches(caption[1],'[Rr]eprinted from')" 
        role="warning" 
        id="reproduce-test-4">The caption for <value-of select="$label"/> contains the text 'reprinted from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-5" 
        test="matches(caption[1],'[Rr]eprinted [Ww]ith [Pp]ermission')" 
        role="warning" 
        id="reproduce-test-5">The caption for <value-of select="$label"/> contains the text 'reprinted with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-6" 
        test="matches(caption[1],'[Mm]odified from')" 
        role="warning" 
        id="reproduce-test-6">The caption for <value-of select="$label"/> contains the text 'modified from', but has no permissions. Is this correct?</report>
      
      <report test="matches(caption[1],'[Mm]odified [Ww]ith')" 
        role="warning" 
        id="reproduce-test-7">The caption for <value-of select="$label"/> contains the text 'modified with', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-8" 
        test="matches(caption[1],'[Uu]sed [Ww]ith [Pp]ermission')" 
        role="warning" 
        id="reproduce-test-8">The caption for <value-of select="$label"/> contains the text 'used with permission', but has no permissions. Is this correct?</report>
        
      <report test="matches(caption[1],'[Cc]ourtesy|[Pp]roprietary')" 
        role="warning" 
        id="reproduce-test-9">The caption for <value-of select="$label"/> contains the text 'courtesy' or 'proprietary', but has no permissions. Is this correct?</report>
    </rule>
    </pattern>
  
  <pattern id="related-object">
    <rule context="related-object[@content-type or @document-id]" id="clintrial-related-object">
      <let name="registries" value="'clinical-trial-registries.xml'"/>
      
      <assert test="@source-type='clinical-trials-registry'" 
        role="error"
        id="clintrial-related-object-2"><name/> must have an @source-type='clinical-trials-registry'.</assert>
      
      <assert test="@source-id!=''" 
        role="error" 
        id="clintrial-related-object-3"><name/> must have an @source-id with a non-empty value.</assert>
      
      <assert test="@source-id-type='registry-name'" 
        role="error" 
        id="clintrial-related-object-4"><name/> must have an @source-id-type='registry-name'.</assert>
      
      <assert test="@document-id-type='clinical-trial-number'" 
        role="error" 
        id="clintrial-related-object-5"><name/> must have an @document-id-type='clinical-trial-number'.</assert>
      
      <assert test="@document-id[not(matches(.,'\p{Zs}'))]" 
        role="error" 
        id="clintrial-related-object-6"><name/> must have an @document-id with a value that does not contain a space character.</assert>
      
      <assert test="@*:href[not(matches(.,'\p{Zs}'))]" 
        role="error" 
        id="clintrial-related-object-7"><name/> must have an @xlink:href with a value that does not contain a space character.</assert>
      
      <assert test="@document-id = ." 
        role="warning" 
        id="clintrial-related-object-8"><name/> has an @document-id '<value-of select="@document-id"/>'. But this is not the text of the related-object, which is likely incorrect - <value-of select="."/>.</assert>
      
      <assert test="some $x in document($registries)/registries/registry satisfies ($x/subtitle/string()=@source-id)" 
        role="warning" 
        id="clintrial-related-object-11"><name/> @source-id value should almost always be one of the subtitles of the Crossref clinical trial registries. "<value-of select="@source-id"/>" is not one of the following <value-of select="string-join(for $x in document($registries)/registries/registry return concat('&quot;',$x/subtitle/string(),'&quot; (',$x/doi/string(),')'),', ')"/>. Is that correct?</assert>
      
      <report test="@source-id='ClinicalTrials.gov' and not(@*:href=(concat('https://clinicaltrials.gov/study/',@document-id),concat('https://clinicaltrials.gov/show/',@document-id)))" 
        role="error"
        id="clintrial-related-object-12">ClinicalTrials.gov trial links are in the format https://clinicaltrials.gov/show/{number}. This <name/> has the link '<value-of select="@*:href"/>', which based on the clinical trial registry (<value-of select="@source-id"/>) and @document-id (<value-of select="@document-id"/>) is not right. Either the xlink:href is wrong (should it be <value-of select="concat('https://clinicaltrials.gov/study/',@document-id)"/> instead?) or the @document-id value is wrong, or the @source-id value is incorrect (or all/some combination of these).</report>

      <report test="ends-with(@*:href,'.')" 
        role="error" 
        id="clintrial-related-object-14"><name/> has a @xlink:href attribute value which ends with a full stop, which is not correct - '<value-of select="@*:href"/>'.</report>
      
      <assert test="@*:href!=''"
        role="error" 
        id="clintrial-related-object-17"><name/> must have an @xlink:href attribute with a non-empty value. This one does not.</assert>

      <report test="ends-with(@document-id,'.')" 
        role="error" 
        id="clintrial-related-object-15"><name/> has an @document-id attribute value which ends with a full stop, which is not correct - '<value-of select="@document-id"/>'.</report>

      <report test="ends-with(.,'.')" 
        role="error" 
        id="clintrial-related-object-16">Content within <name/> element ends with a full stop, which is not correct - '<value-of select="."/>'.</report>
      
      <assert test="@content-type=('pre-results','results','post-results')" 
        role="error" 
        id="clintrial-related-object-18"><name/> must have a content-type attribute with one of the following values: pre-results, results, or post-results.</assert>
      
      <assert test="ancestor::abstract or parent::article-meta" 
        role="error" 
        id="clintrial-related-object-parent-1"><name/> element must either be a descendant of abstract or a child or article-meta. This one is not.</assert>
      
      <report test="ancestor::abstract and not(parent::p/parent::sec/parent::abstract)" 
        role="error" 
        id="clintrial-related-object-parent-2">If <name/> is a descendant of abstract, then it must be placed within a p element that is part of a subsection (i.e. it must be within a structured abstract). This one is not.</report>
      
      <report test="ancestor::abstract[sec] and not(parent::p/parent::sec/title[matches(lower-case(.),'clinical trial')])" 
        role="warning" 
        id="clintrial-related-object-parent-3"><name/> is a descendant of (a sturctured) abstract, but it's not within a section that has a title indicating it's a clinical trial number. Is that right?</report>
    </rule>
  </pattern>
  
  <pattern id="notes">
    <rule context="front/notes" id="notes-checks">
      <report test="fn-group[not(@content-type='summary-of-updates')] or notes[not(@notes-type='disclosures')]" 
        role="warning"
        sqf:fix="delete-elem"
        id="notes-check-1">When present, the notes element should only be used to contain an author revision summary (an fn-group with the content-type 'summary-of-updates'). This notes element contains other content. Is it redundant? Or should the content be moved elsewhere? (coi statements should be in author-notes; clinical trial numbers should be included as a related-object in a structured abstract (if it already exists) or as related-object in article-meta; data/code/ethics/funding statements can be included in additional information in new or existing section(s), as appropriate)</report>
      
      <report test="*[not(name()=('fn-group','notes'))]" 
        role="error"
        sqf:fix="delete-elem"
        id="notes-check-2">When present, the notes element should only be used to contain an author revision summary (an fn-group with the content-type 'summary-of-updates'). This notes element contains the following element(s): <value-of select="string-join(distinct-values(*[not(name()=('fn-group','notes'))]/name()),'; ')"/>). Are these redundant? Or should the content be moved elsewhere? (coi statements should be in author-notes; clinical trial numbers should be included as a related-object in a structured abstract (if it already exists) or as related-object in article-meta; data/code/ethics/funding statements can be included in additional information in new or existing section(s), as appropriate; anstract shpould be captured as abstracts with the appropriate type)</report>
    </rule>
  </pattern>

    <pattern id="digest">
      <rule context="title" id="digest-title-checks">
        <report test="matches(lower-case(.),'^\s*(elife\s)?digest\s*$')" 
        role="error" 
        id="digest-flag"><value-of select="parent::*/name()"/> element has a title containing 'digest' - <value-of select="."/>. If this is referring to an plain language summary written by the authors it should be renamed to plain language summary (or similar) in order to not suggest to readers this was written by the features team.</report>
      </rule>
    </pattern>

    <pattern id="preformat">
     <rule context="preformat" id="preformat-checks">
        <report test="." 
        role="warning" 
        id="preformat-flag">Please check whether the content in this preformat element has been captured correctly (and is rendered approriately).</report>
     </rule>
    </pattern>

    <pattern id="code">
     <rule context="code" id="code-checks">
        <report test="." 
        role="warning" 
        id="code-flag">Please check whether the content in this code element has been captured correctly (and is rendered approriately).</report>
     </rule>
    </pattern>

    <pattern id="uri">
     <rule context="uri" id="uri-checks">
        <report test="." 
        role="error"
        sqf:fix="replace-to-ext-link"
        id="uri-flag">The uri element is not permitted. Instead use ext-link with the attribute link-type="uri".</report>
     </rule>
    </pattern>
  
  <pattern id="inline-media">
     <rule context="inline-media" id="inline-media-checks">
        <report test="." 
        role="error"
        id="inline-media-flag">The inline-media element is not permitted. Instead use inline-graphic for images or supplementary-material for downloadable files.</report>
     </rule>
    </pattern>
  
  <pattern id="disp-quote">
     <rule context="disp-quote" id="disp-quote-checks">
        <assert test="ancestor::sub-article[@article-type='author-comment']" 
        role="warning" 
        id="disp-quote-1">Display quotes are uncommon in eLife content outside the author response. Please check whether this content has been captured correctly (and is rendered approriately).</assert>
       
       <report test="ancestor::sub-article[@article-type='author-comment'] and not(@content-type='editor-comment')" 
        role="error" 
        id="disp-quote-2">Display quotes in the author response must have the attribute content-type="editor-comment". This one does not.</report>
     </rule>
    </pattern>

    <pattern id="xref">
     <rule context="xref" id="xref-checks">
        <let name="allowed-attributes" value="('ref-type','rid')"/>

        <report test="@*[not(name()=$allowed-attributes)]" 
        role="warning" 
        id="xref-attributes">This xref element has the following attribute(s) which are not supported: <value-of select="string-join(@*[not(name()=$allowed-attributes)]/name(),'; ')"/>.</report>

        <report test="parent::xref" 
        role="error" 
        sqf:fix="strip-tags"
        id="xref-parent">This xref element containing '<value-of select="."/>' is a child of another xref. Nested xrefs are not supported - it must be either stripped or moved so that it is a child of another element.</report>
     </rule>
      
      <rule context="xref[@ref-type='bibr']" id="ref-citation-checks">
        <let name="rid" value="@rid"/>
        
        <assert test="ancestor::article//*[@id=$rid]/name()='ref'" 
          role="error" 
          id="ref-cite-target">This reference citation points to a <value-of select="ancestor::article//*[@id=$rid]/name()"/> element. This cannot be right. Either the rid value is wrong or the ref-type is incorrect.</assert>
        
        <report test="((sup[matches(.,'^\d+$')] and .=sup) or (matches(.,'^\d+$') and ancestor::sup)) and (preceding::text()[1][matches(lower-case(.),'([×x⋅]\s?[0-9]|10)$')] or ancestor::sup/preceding::text()[1][matches(lower-case(.),'([×x⋅]\s?[0-9]|10)$')])"
          role="warning" 
          sqf:fix="strip-tags"
          id="ref-cite-superscript-0">This reference citation contains superscript number(s), but is preceed by a formula. Should the xref be removed and the superscript numbers be retained (as an exponent)?</report>
        
        <!-- match text that ends with an SI unit commonly followed by a superscript number-->
        <report test="((sup[matches(.,'^\d+$')] and .=sup) or (matches(.,'^\d+$') and ancestor::sup)) and preceding::text()[1][matches(lower-case(.),'\d\s*([YZEPTGMkhdacm]?m|mm|cm|km|[µμ]m|nm|pm|fm|am|zm|ym)$')]"
          role="warning" 
          sqf:fix="strip-tags"
          id="ref-cite-superscript-1">This reference citation contains superscript number(s), but is preceed by an SI unit abbreviation. Should the xref be removed and the superscript numbers be retained?</report>
        
        <!-- incorrect citations for atomic notation -->
        <report test="(.='2' and (sup or ancestor::sup)) and preceding::text()[1][matches(.,'(^|\s)(B[ar]|C[alou]?|Fe?|H[eg]?|I|M[gn]|N[ai]?|O|Pb?|S|Zn)$')]"
          role="warning" 
          sqf:fix="strip-tags"
          id="ref-cite-superscript-2">This reference citation contains superscript number(s), but is preceed by text that suggests it's part of atomic notation. Should the xref be removed and the superscript numbers be retained?</report>
        
        <report test="(.='3' and (sup or ancestor::sup)) and preceding::text()[1][matches(.,'(^|\s)(As|Bi|NI|O|P|Sb)$')]"
          role="warning" 
          sqf:fix="strip-tags"
          id="ref-cite-superscript-3">This reference citation contains superscript number(s), but is preceed by text that suggests it's part of atomic notation. Should the xref be removed and the superscript numbers be retained?</report>
     </rule>
      
      <rule context="xref[@ref-type='fig' and @rid]" id="fig-xref-conformance">
        <let name="pre-text" value="replace(preceding-sibling::text()[1],'[—–‒]+','-')"/>
        <let name="post-text" value="replace(following-sibling::text()[1],'[—–‒]+','-')"/>
        
        <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-3"
        test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')" 
        role="warning" 
        id="fig-xref-test-3">There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
        
        <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-8"
        test="matches($pre-text,'their $')" 
        role="warning" 
        sqf:fix="strip-tags"
        id="fig-xref-test-8">Figure citation is preceded by 'their'. Does this refer to a figure in other content (and as such should be captured as plain text)? - '<value-of select="concat($pre-text,.)"/>'.</report>
        
        <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-9"
        test="matches($post-text,'^ of [\p{Lu}][\p{Ll}]+[\-]?[\p{Ll}]? et al[\.]?')" 
        role="warning" 
        sqf:fix="strip-tags"
        id="fig-xref-test-9">Is this figure citation a reference to a figure from other content (and as such should be captured instead as plain text)? - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-10"
        test="matches($post-text,'^[\p{Zs}]?[\p{Zs}\p{P}][\p{Zs}]?[Ff]igure supplement')" 
        role="error" 
        id="fig-xref-test-10">Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to a Figure supplement - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-11"
        test="matches($post-text,'^[\p{Zs}]?[\p{Zs}—\-][\p{Zs}]?[Vv]ideo')" 
        role="warning" 
        id="fig-xref-test-11">Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to a video supplement - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-12"
        test="matches($post-text,'^[\p{Zs}]?[\p{Zs}—\-][\p{Zs}]?[Ss]ource')" 
        role="warning" 
        id="fig-xref-test-12">Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-13"
        test="matches($post-text,'^[\p{Zs}]?[Ss]upplement|^[\p{Zs}]?[Ff]igure [Ss]upplement|^[\p{Zs}]?[Ss]ource|^[\p{Zs}]?[Vv]ideo')" 
        role="warning" 
        id="fig-xref-test-13">Figure citation is followed by text which suggests it could be an incomplete citation - <value-of select="concat(.,$post-text)"/>'. Is this OK?</report>
        
        <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-16"
        test="matches($pre-text,'[Ss]uppl?[\.]?\p{Zs}?$|[Ss]upp?l[ea]mental\p{Zs}?$|[Ss]upp?l[ea]mentary\p{Zs}?$|[Ss]upp?l[ea]ment\p{Zs}?$')" 
        role="warning" 
        id="fig-xref-test-16">Figure citation - '<value-of select="."/>' - is preceded by the text '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>' - should it be a figure supplement citation instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-17"
        test="matches(.,'[A-Z]$') and matches($post-text,'^\p{Zs}?and [A-Z] |^\p{Zs}?and [A-Z]\.')" 
        role="warning" 
        id="fig-xref-test-17">Figure citation - '<value-of select="."/>' - is followed by the text '<value-of select="substring($post-text,1,7)"/>' - should this text be included in the link text too (i.e. '<value-of select="concat(.,substring($post-text,1,6))"/>')?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-18"
        test="matches($post-text,'^\-[A-Za-z0-9]')" 
        role="warning" 
        id="fig-xref-test-18">Figure citation - '<value-of select="."/>' - is followed by the text '<value-of select="substring($post-text,1,10)"/>' - should some or all of that text be included in the citation text?</report>
        
      </rule>
    </pattern>

    <pattern id="ext-link">
    <rule context="ext-link[@ext-link-type='uri']" id="ext-link-tests">
      
      <!-- Needs further testing. Presume that we want to ensure a url follows certain URI schemes. -->
      <assert test="matches(@*:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)\[\]+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')" 
        role="warning" 
        id="url-conformance-test">@xlink:href doesn't look like a URL - '<value-of select="@*:href"/>'. Is this correct?</assert>
      
      <report test="matches(@*:href,'^(ftp|sftp)://\S+:\S+@')" 
        role="warning" 
        id="ftp-credentials-flag">@xlink:href contains what looks like a link to an FTP site which contains credentials (username and password) - '<value-of select="@*:href"/>'. If the link without credentials works (<value-of select="concat(substring-before(@*:href,'://'),'://',substring-after(@*:href,'@'))"/>), then please replace it with that.</report>
      
      <report test="matches(@*:href,'\.$')" 
        role="error"
        id="url-fullstop-report">'<value-of select="@*:href"/>' - Link ends in a full stop which is incorrect.</report>
      
      <report test="matches(@*:href,'[\p{Zs}]')" 
        role="error" 
        id="url-space-report">'<value-of select="@*:href"/>' - Link contains a space which is incorrect.</report>
      
      <report test="(.!=@*:href) and matches(.,'https?:|ftp:')" 
        role="warning" 
        id="ext-link-text">The text for a URL is '<value-of select="."/>' (which looks like a URL), but it is not the same as the actual embedded link, which is '<value-of select="@*:href"/>'.</report>

      <report test="matches(@*:href,'^https?://(dx\.)?doi\.org/[^1][^0]?')" 
        role="error" 
        id="ext-link-doi-check">Embedded URL within text starts with the DOI prefix, but it is not a valid doi - <value-of select="@*:href"/>.</report>

    <report test="not(ancestor::fig/permissions[contains(.,'phylopic')]) and matches(@*:href,'phylopic\.org')" 
        role="warning" 
        id="phylopic-link-check">This link is to phylopic.org, which is a site where silhouettes/images are typically reproduced from. Please check whether any figures contain reproduced images from this site, and if so whether permissions have been obtained and/or copyright statements are correctly included.</report>

    <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#ext-link-child-test-5" 
        test="contains(@*:href,'datadryad.org/review?')" 
        role="warning" 
        id="ext-link-child-test-5">ext-link looks like it points to a review dryad dataset - <value-of select="."/>. Should it be updated?</report>
      
      <report test="not(contains(@*:href,'datadryad.org/review?')) and not(matches(@*:href,'^https?://doi.org/')) and contains(@*:href,'datadryad.org')" 
        role="error" 
        id="ext-link-child-test-6">ext-link points to a dryad dataset, but it is not a DOI - <value-of select="@*:href"/>. Replace this with the Dryad DOI.</report>

    <report test="contains(@*:href,'paperpile.com')"
        role="error"
        sqf:fix="delete-elem"
        id="paper-pile-test">This paperpile hyperlink should be removed: '<value-of select="@*:href"/>' embedded in the text '<value-of select="."/>'.</report>
    </rule>

    <rule context="ext-link" id="ext-link-tests-2">
      <assert test="@ext-link-type='uri'" 
        role="error" 
        id="ext-link-type-test-1">ext-link must have the attribute ext-link-type="uri". This one does not. It contains the text: <value-of select="."/></assert>
    </rule>
    </pattern>

    <pattern id="footnotes">
      <rule context="fn-group[fn]" id="footnote-checks">
        <assert test="ancestor::notes"
          role="error" 
          id="body-footnote">This preprint has footnotes appended to the content. EPP cannot render these, so they need adding to the text.</assert>
      </rule> 
    </pattern>

    <pattern id="symbol-checks">
      <rule context="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link|ref" id="unallowed-symbol-tests">
      
      <report test="contains(.,'�')" 
        role="error" 
        id="replacement-character-presence"><name/> element contains the replacement character '�' which is not allowed.</report>
      
      <report test="contains(.,'')" 
        role="error" 
        id="junk-character-presence"><name/> element contains a junk character '' which should be replaced.</report>
      
      <report test="contains(.,'&#xfe0e;')" 
        role="error" 
        id="junk-character-presence-2"><name/> element contains a junk character '&#xfe0e;' which should be replaced or deleted.</report>

      <report test="contains(.,'□')" 
        role="error" 
        id="junk-character-presence-3"><name/> element contains a junk character '□' which should be replaced or deleted.</report>
        
      <report test="contains(.,'⍰')" 
        role="error" 
        id="junk-character-presence-4"><name/> element contains a junk character '⍰' which should be replaced or deleted.</report>
      
      <report test="contains(.,'¿')" 
        role="warning" 
        id="inverterted-question-presence"><name/> element contains an inverted question mark '¿' which should very likely be replaced/removed.</report>
      
      <report test="(name()!='ref') and (some $x in self::*[not(local-name() = ('monospace','code'))]/text() satisfies matches($x,'\(\)|\[\]'))" 
        role="warning" 
        id="empty-parentheses-presence"><name/> element contains empty parentheses ('[]', or '()'). Is there a missing citation within the parentheses? Or perhaps this is a piece of code that needs formatting?</report>
      
      <report test="matches(.,'&amp;#x\d')" 
        role="warning" 
        id="broken-unicode-presence"><name/> element contains what looks like a broken unicode - <value-of select="."/>.</report>
        
      <report test="contains(.,'&#x02213;')" 
        role="warning" 
        id="broken-unicode-presence-2"><name/> element contains a Minus-or-Plus Sign (&#x02213;). Is this intended to be an ampersand (with a missing 'a' in the entity reference - &amp;mp;)? <value-of select="."/></report>
      
      <report test="contains(.,'&#x9D;')" 
        role="error" 
        id="operating-system-command-presence"><name/> element contains an operating system command character '&#x9D;' (unicode string: &amp;#x9D;) which should very likely be replaced/removed. - <value-of select="."/></report>

      <report test="matches(lower-case(.),&quot;(^|\s)((i am|i&apos;m) an? ai (language)? model|as an ai (language)? model,? i(&apos;m|\s)|(here is|here&apos;s) an? (possible|potential)? introduction (to|for) your topic|(here is|here&apos;s) an? (abstract|introduction|results|discussion|methods)( section)? for you|certainly(,|!)? (here is|here&apos;s)|i&apos;m sorry,?( but)? i (don&apos;t|can&apos;t)|knowledge (extend|cutoff)|as of my last update|regenerate response)&quot;)" 
        role="warning" 
        id="ai-response-presence-1"><name/> element contains what looks like a response from an AI chatbot after it being provided a prompt. Is that correct? Should the content be adjusted?</report>
        
      <report test="matches(., '[&#xFB00;-&#xFB06;]')" 
        role="error" 
        id="ligature-presence-1"><name/> element contains the following latin ligature character(s) that need replacing with the regular latin character(s): <value-of select="string-join(distinct-values(e:analyze-string(.,'[&#xFB00;-&#xFB06;]')//*:match),'; ')"/>.</report>
        
      <report test="matches(., '[&#x0530;-&#x06FF;&#x0700;-&#x097F;&#x0E00;-&#x0FFF;]')" 
        role="warning" 
        id="non-roman-script-presence-1"><name/> element contains the following non-roman script character(s): <value-of select="string-join(distinct-values(e:analyze-string(.,'[&#x0530;-&#x06FF;&#x0700;-&#x097F;&#x0E00;-&#x0FFF;]')//*:match),'; ')"/>. It is unusual for these characters to be present in eLife content. Are they correct?</report>
    </rule>
    
    </pattern>

    <pattern id="assessment-checks">

      <rule context="sub-article[@article-type='editor-report']/front-stub" id="ed-report-front-stub">
        <let name="article-type" value="ancestor::article/@article-type"/>
        
        <report test="not($article-type='review-article') and not(kwd-group[@kwd-group-type='evidence-strength'])" 
          role="warning" 
          id="ed-report-str-kwd-presence">eLife Assessment does not have a strength keyword group. Is that correct?</report>
        
        <report test="$article-type='review-article' and kwd-group[@kwd-group-type='evidence-strength']" 
          role="error" 
          id="ed-report-str-kwd-review-presence">eLife Assessment in a Review article cannot have a strength keyword group.</report>
        
        <report test="not($article-type='review-article') and not(kwd-group[@kwd-group-type='claim-importance'])" 
          role="warning" 
          id="ed-report-sig-kwd-presence">eLife Assessment does not have a significance keyword group. Is that correct?</report>
        
        <report test="$article-type='review-article' and kwd-group[@kwd-group-type='claim-importance']" 
          role="error" 
          id="ed-report-sig-kwd-review-presence">eLife Assessment in a Review article cannot have a significance keyword group.</report>
        
    </rule>

      <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group" id="ed-report-kwd-group">
      
      <assert test="@kwd-group-type=('claim-importance','evidence-strength')" 
        role="error" 
        id="ed-report-kwd-group-1">kwd-group in <value-of select="parent::*/title-group/article-title"/> must have the attribute kwd-group-type with the value 'claim-importance' or 'evidence-strength'. This one does not.</assert>

      <report test="@kwd-group-type='claim-importance' and count(kwd) gt 1" 
        role="error" 
        id="ed-report-kwd-group-3"><value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is not permitted, please check which single importance keyword should be used.</report>
      
      <report test="@kwd-group-type='evidence-strength' and count(kwd) = 2" 
        role="warning" 
        id="ed-report-kwd-group-2"><value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. Please check this is correct.</report>
        
      <report test="@kwd-group-type='evidence-strength' and count(kwd) gt 2" 
        role="error" 
        id="ed-report-kwd-group-4"><value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is incorrect.</report>
      
    </rule>

      <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group/kwd" id="ed-report-kwds">
      
        <report test="preceding-sibling::kwd = ."
          role="error"
          id="ed-report-kwd-1">Keyword contains <value-of select="."/>, there is another kwd with that value within the same kwd-group, so this one is either incorrect or superfluous and should be deleted.</report>
      
        <assert test="some $x in ancestor::sub-article[1]/body/p//bold satisfies contains(lower-case($x),lower-case(.))"
          role="error"
          id="ed-report-kwd-2">Keyword contains <value-of select="."/>, but this term is not bolded in the text of the <value-of select="ancestor::front-stub/title-group/article-title"/>.</assert>
      
        <report test="*"
          role="error"
          id="ed-report-kwd-3">Keywords in <value-of select="ancestor::front-stub/title-group/article-title"/> cannot contain elements, only text. This one has: <value-of select="string-join(distinct-values(*/name()),'; ')"/>.</report>
    </rule>

    <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='claim-importance']/kwd" id="ed-report-claim-kwds">
      <let name="allowed-vals" value="('Landmark', 'Fundamental', 'Important', 'Valuable', 'Useful')"/>
      
      <assert test=".=$allowed-vals"
        role="error" 
        id="ed-report-claim-kwd-1">Keyword contains <value-of select="."/>, but it is in a 'claim-importance' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/></assert>
      
    </rule>
    
    <rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='evidence-strength']/kwd" id="ed-report-evidence-kwds">
      <let name="allowed-vals" value="('Exceptional', 'Compelling', 'Convincing', 'Solid', 'Incomplete', 'Inadequate')"/>
      
      <assert test=".=$allowed-vals"
        role="error" 
        id="ed-report-evidence-kwd-1">Keyword contains <value-of select="."/>, but it is in an 'evidence-strength' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/></assert>
    </rule>
      
      <rule context="sub-article[@article-type='editor-report']/body" id="ed-report-body-checks">
        <report test="contains(lower-case(.),'this review article') and not(ancestor::article/@article-type='review-article')"
        role="warning" 
        id="ed-report-body-1">eLife Assessment contains the phrase 'This Review Article', but the article-type on the root article element is '<value-of select="ancestor::article[1]/@article-type"/>'. Should the article-type on the article element be changed to 'review-article'?</report>
      </rule>

    <rule context="sub-article[@article-type='editor-report']/body/p[1]//bold" id="ed-report-bold-terms">
      <let name="str-kwds" value="('exceptional', 'compelling', 'convincing', 'convincingly', 'solid', 'incomplete', 'incompletely', 'inadequate', 'inadequately')"/>
      <let name="sig-kwds" value="('landmark', 'fundamental', 'important', 'valuable', 'useful')"/>
      <let name="allowed-vals" value="($str-kwds,$sig-kwds)"/>
      <let name="normalized-kwd" value="replace(lower-case(.),'ly$','')"/>
      <let name="title-case-kwd" value="concat(upper-case(substring($normalized-kwd,1,1)),lower-case(substring($normalized-kwd,2)))"/>
      <let name="preceding-text" value="string-join(preceding-sibling::node(),'')"/>
      
      <assert test="lower-case(.)=$allowed-vals"
        role="error" 
        id="ed-report-bold-terms-1">Bold phrase in eLife Assessment - <value-of select="."/> - is not one of the permitted terms from the vocabulary. Should the bold formatting be removed? These are currently bolded terms <value-of select="string-join($allowed-vals,', ')"/></assert>

      <report test="lower-case(.)=$allowed-vals and not($title-case-kwd=ancestor::sub-article/front-stub/kwd-group/kwd)"
        role="error" 
        id="ed-report-bold-terms-2">Bold phrase in eLife Assessment - <value-of select="."/> - is one of the permitted vocabulary terms, but there's no corresponding keyword in the metadata (in a kwd-group in the front-stub).</report>

      <report test="preceding-sibling::bold[replace(lower-case(.),'ly$','') = $normalized-kwd]"
        role="warning" 
        id="ed-report-bold-terms-3">There is more than one of the same <value-of select="if (replace(lower-case(.),'ly$','')=$str-kwds) then 'strength' else 'significance'"/> keywords in the assessment - <value-of select="$normalized-kwd"/>. This is very likely to be incorrect.</report>
      
      <report test="(lower-case(.)=$allowed-vals) and matches($preceding-text,'\smore\s*$')"
        role="warning" 
        id="ed-report-bold-terms-4">Assessment keyword (<value-of select="."/>) is preceded by 'more'. Has the keyword been deployed correctly?</report>
      
      <report test="(lower-case(.)=$str-kwds) and matches($preceding-text,'\spotentially\s*$')"
        role="warning" 
        id="ed-report-bold-terms-5">Assessment strength keyword (<value-of select="."/>) is preceded by 'potentially'. Has the keyword been deployed correctly?</report>
    </rule>

    </pattern>

    <pattern id="author-response-checks">
      <rule context="sub-article[@article-type='author-comment']//fig/label" id="ar-image-labels">
        <assert test="matches(.,'^Author response image \d\d?\.$')" 
          role="error" 
          id="ar-image-label-1">Label for figures in the author response must be in the format 'Author response image 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
      
      <rule context="sub-article[@article-type='author-comment']//table-wrap/label" id="ar-table-labels">
        <assert test="matches(.,'^Author response table \d\d?\.$')" 
          role="error" 
          id="ar-table-label-1">Label for tables in the author response must be in the format 'Author response table 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
    </pattern>
  
    <pattern id="public-review-checks">
      <rule context="sub-article[@article-type='referee-report']//fig/label" id="pr-image-labels">
        <assert test="matches(.,'^Review image \d\d?\.$')" 
          role="error" 
          id="pr-image-label-1">Label for figures in public reviews must be in the format 'Review image 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
      
      <rule context="sub-article[@article-type='referee-report']//table-wrap/label" id="pr-table-labels">
        <assert test="matches(.,'^Review table \d\d?\.$')" 
          role="error" 
          id="pr-table-label-1">Label for tables in public reviews must be in the format 'Review table 0.' This one is not: '<value-of select="."/>'</assert>
      </rule>
    </pattern>

    <pattern id="sub-article-checks">
      <rule context="sub-article/front-stub/title-group/article-title" id="sub-article-title-checks">
        <let name="type" value="ancestor::sub-article/@article-type"/>
        
        <report test="$type='editor-report' and not(matches(.,'^eLife [aA]ssessment$'))" 
          role="error" 
          id="sub-article-title-check-1">The title of an <value-of select="$type"/> type sub-article should be 'eLife Assessment'. This one is: <value-of select="."/></report>
        
        <report test="$type='referee-report' and not(matches(.,'^Reviewer #\d\d? \([Pp]ublic [Rr]eview\):?$|^Joint [Pp]ublic [Rr]eview:?$'))" 
          role="error" 
          id="sub-article-title-check-2">The title of a <value-of select="$type"/> type sub-article should be in one of the following formats: 'Reviewer #0 (public review)' or 'Joint public review'. This one is: <value-of select="."/></report>
        
        <report test="$type='author-comment' and not(matches(.,'^Author [Rr]esponse:?$'))" 
          role="error" 
          id="sub-article-title-check-3">The title of a <value-of select="$type"/> type sub-article should be 'Author response'. This one is: <value-of select="."/></report>
      </rule>
      
      <rule context="sub-article/front-stub" id="sub-article-front-stub-checks">       
        <assert test="count(article-id[@pub-id-type='doi']) = 1" 
          role="error" 
          id="sub-article-front-stub-check-1">Sub-article must have one (and only one) &lt;article-id pub-id-type="doi"> element. This one does not.</assert>
        
        <assert test="title-group" 
          role="error" 
          id="sub-article-front-stub-check-2">Sub-article must have one (and only one) &lt;title-group> element. This one does not.</assert>
        
        <assert test="count(contrib-group) = 1" 
          role="error" 
          id="sub-article-front-stub-check-3">Sub-article must have one (and only one) &lt;contrib-group> element. This one does not.</assert>
      </rule>
      
      <rule context="sub-article/front-stub/article-id[@pub-id-type='doi']" id="sub-article-doi-checks">       
        <let name="article-version-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi' and @specific-use='version']"/>
        <assert test="matches(.,'^10\.7554/eLife\.\d{5,6}\.\d\.sa\d$')" 
          role="error" 
          id="sub-article-doi-check-1">The DOI for this sub-article does not match the permitted format: <value-of select="."/>.</assert>
        
        <assert test="starts-with(.,$article-version-doi)" 
          role="error" 
          id="sub-article-doi-check-2">The DOI for this sub-article (<value-of select="."/>) does not start with the version DOI for the Reviewed Preprint (<value-of select="$article-version-doi"/>).</assert>
      </rule>
      
      <rule context="sub-article/body//p" id="sub-article-p-checks">
        <report test="bold[matches(lower-case(.),'(image|table)')] and (inline-graphic or graphic or ext-link[inline-graphic or graphic])" 
          role="error" 
          id="sub-article-bold-image-1">p element contains both bold text (a label for an image or table) and a graphic. These should be in separate paragraphs (so that they are correctly processed into fig or table-wrap).</report>
        
        <report test="bold[matches(lower-case(.),'(author response|review) (image|table)')]" 
          role="error" 
          id="sub-article-bold-image-2">p element contains bold text which looks like a label for an image or table. Since it's not been captured as a figure in the XML, it might either be misformatted in Kotahi/Hypothesis or there's a processing bug.</report>
        
        <report test="matches(.,'\$?\$.*?\$\$?')" 
          role="warning" 
          id="sub-article-tex-1">sub-article contains what looks like potential latex: <value-of select="string-join(distinct-values(e:analyze-string(.,'\$?\$.*?\$\$?')//*:match),'; ')"/>. If this is maths it should either be represented in plain unicode or as an image.</report>
        
        <report test="not(matches(.,'\$?\$.*?\$\$?')) and matches(.,'\\[a-z]+\p{Ps}')" 
          role="warning" 
          id="sub-article-tex-2">sub-article contains what looks like potential latex: <value-of select="string-join(distinct-values(e:analyze-string(.,'\\[a-z]+\p{Ps}')//*:match),'; ')"/>. If this is maths it should either be represented in plain unicode or as an image.</report>
      </rule>
      
      <rule context="sub-article/body//ext-link" id="sub-article-ext-links">
        <report test="not(inline-graphic) and matches(lower-case(@*:href),'imgur\.com')" 
          role="warning" 
          id="ext-link-imgur">ext-link in sub-article directs to imgur.com - <value-of select="@*:href"/>. Is this a figure or table (e.g. Author response image X) that should be captured semantically appropriately in the XML?</report>
        
        <report test="inline-graphic" 
          role="error" 
          id="ext-link-inline-graphic">ext-link in sub-article has a child inline-graphic. Is this a figure or table (e.g. Author response image X) that should be captured semantically appropriately in the XML?</report>
      </rule>
    </pattern>

    <pattern id="arxiv-metadata">
     <rule context="article/front/journal-meta[lower-case(journal-id[1])='arxiv']" id="arxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='arXiv'" 
        role="error" 
        id="arxiv-journal-id">arXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"> element with the value 'arXiv'.</assert>

      <assert test="journal-title-group/journal-title='arXiv'" 
        role="error" 
        id="arxiv-journal-title">arXiv preprints must have a &lt;journal-title> element with the value 'arXiv' inside a &lt;journal-title-group> element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='arXiv'" 
        role="error" 
        id="arxiv-abbrev-journal-title">arXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"> element with the value 'arXiv' inside a &lt;journal-title-group> element.</assert>

      <assert test="issn[@pub-type='epub']='2331-8422'" 
        role="error" 
        id="arxiv-issn">arXiv preprints must have a &lt;issn pub-type="epub"> element with the value '2331-8422'.</assert>

      <assert test="publisher/publisher-name='Cornell University'" 
        role="error" 
        id="arxiv-publisher">arXiv preprints must have a &lt;publisher-name> element with the value 'Cornell University', inside a &lt;publisher> element.</assert>
     </rule>

      <rule context="article/front[journal-meta[lower-case(journal-id[1])='arxiv']]/article-meta/article-id[@pub-id-type='doi']" id="arxiv-doi-checks">
        <assert test="matches(.,'^10\.48550/arXiv\.\d{4,5}\.\d{4,5}$')" 
         role="error" 
         id="arxiv-doi-conformance">arXiv preprints must have a &lt;article-id pub-id-type="doi"> element with a value that matches the regex '10\.48550/arXiv\.\d{4,}\.\d{4,5}'. In other words, the current DOI listed is not a valid arXiv DOI: '<value-of select="."/>'.</assert>
      </rule>
    </pattern>

    <pattern id="res-square-metadata">
     <rule context="article/front/journal-meta[lower-case(journal-id[1])='rs']" id="res-square-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='RS'" 
        role="error" 
        id="res-square-journal-id">Research Square preprints must have a &lt;journal-id journal-id-type="publisher-id"> element with the value 'RS'.</assert>

      <assert test="journal-title-group/journal-title='Research Square'" 
        role="error" 
        id="res-square-journal-title">Research Square preprints must have a &lt;journal-title> element with the value 'Research Square' inside a &lt;journal-title-group> element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='rs'" 
        role="error" 
        id="res-square-abbrev-journal-title">Research Square preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"> element with the value 'rs' inside a &lt;journal-title-group> element.</assert>

      <assert test="issn[@pub-type='epub']='2693-5015'" 
        role="error" 
        id="res-square-issn">Research Square preprints must have a &lt;issn pub-type="epub"> element with the value '2693-5015'.</assert>

      <assert test="publisher/publisher-name='Research Square'" 
        role="error" 
        id="res-square-publisher">Research Square preprints must have a &lt;publisher-name> element with the value 'Research Square', inside a &lt;publisher> element.</assert>
     </rule>

      <rule context="article/front[journal-meta[lower-case(journal-id[1])='rs']]/article-meta/article-id[@pub-id-type='doi']" id="res-square-doi-checks">
        <assert test="matches(.,'^10\.21203/rs\.3\.rs-\d+/v\d$')" 
         role="error" 
         id="res-square-doi-conformance">Research Square preprints must have a &lt;article-id pub-id-type="doi"> element with a value that matches the regex '^10\.21203/rs\.3\.rs-\d+/v\d$'. In other words, the current DOI listed is not a valid Research Square DOI: '<value-of select="."/>'.</assert>
      </rule>
    </pattern>

    <pattern id="psyarxiv-metadata">
     <rule context="article/front/journal-meta[lower-case(journal-id[1])='psyarxiv']" id="psyarxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='PsyArXiv'" 
        role="error" 
        id="psyarxiv-journal-id">PsyArXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"> element with the value 'PsyArXiv'.</assert>

      <assert test="journal-title-group/journal-title='PsyArXiv'" 
        role="error" 
        id="psyarxiv-journal-title">PsyArXiv preprints must have a &lt;journal-title> element with the value 'PsyArXiv' inside a &lt;journal-title-group> element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='PsyArXiv'" 
        role="error" 
        id="psyarxiv-abbrev-journal-title">PsyArXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"> element with the value 'PsyArXiv' inside a &lt;journal-title-group> element.</assert>

      <assert test="publisher/publisher-name='Center for Open Science'" 
        role="error" 
        id="psyarxiv-publisher">PsyArXiv preprints must have a &lt;publisher-name> element with the value 'Center for Open Science', inside a &lt;publisher> element.</assert>
     </rule>

      <rule context="article/front[journal-meta[lower-case(journal-id[1])='psyarxiv']]/article-meta/article-id[@pub-id-type='doi']" id="psyarxiv-doi-checks">
        <assert test="matches(.,'^10\.31234/osf\.io/[\da-z]+(_v\d+)?$')" 
         role="error" 
         id="psyarxiv-doi-conformance">PsyArXiv preprints must have a &lt;article-id pub-id-type="doi"> element with a value that matches the regex '^10\.31234/osf\.io/[\da-z]+(_v\d+)?$'. In other words, the current DOI listed is not a valid PsyArXiv DOI: '<value-of select="."/>'.</assert>
      </rule>
    </pattern>

    <pattern id="osf-metadata">
     <rule context="article/front/journal-meta[lower-case(journal-id[1])='osf preprints']" id="osf-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='OSF Preprints'" 
        role="error" 
        id="osf-journal-id">Preprints on OSF must have a &lt;journal-id journal-id-type="publisher-id"> element with the value 'OSF Preprints'.</assert>

      <assert test="journal-title-group/journal-title='OSF Preprints'" 
        role="error" 
        id="osf-journal-title">Preprints on OSF must have a &lt;journal-title> element with the value 'OSF Preprints' inside a &lt;journal-title-group> element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='OSF pre.'" 
        role="error" 
        id="osf-abbrev-journal-title">Preprints on OSF must have a &lt;abbrev-journal-title abbrev-type="publisher"> element with the value 'OSF pre.' inside a &lt;journal-title-group> element.</assert>

      <assert test="publisher/publisher-name='Center for Open Science'" 
        role="error" 
        id="osf-publisher">Preprints on OSF must have a &lt;publisher-name> element with the value 'Center for Open Science', inside a &lt;publisher> element.</assert>
     </rule>

      <rule context="article/front[journal-meta[lower-case(journal-id[1])='osf preprints']]/article-meta/article-id[@pub-id-type='doi']" id="osf-doi-checks">
        <assert test="matches(.,'^10\.31219/osf\.io/[\da-z]+(_v\d+)?$')" 
         role="error" 
         id="osf-doi-conformance">Preprints on OSF must have a &lt;article-id pub-id-type="doi"> element with a value that matches the regex '^10/.31219/osf\.io/[\da-z]+(_v\d+)?$'. In other words, the current DOI listed is not a valid OSF Preprints DOI: '<value-of select="."/>'.</assert>
      </rule>
    </pattern>

    <pattern id="ecoevorxiv-metadata">
     <rule context="article/front/journal-meta[lower-case(journal-id[1])='ecoevorxiv']" id="ecoevorxiv-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='EcoEvoRxiv'" 
        role="error" 
        id="ecoevorxiv-journal-id">EcoEvoRxiv preprints must have a &lt;journal-id journal-id-type="publisher-id"> element with the value 'EcoEvoRxiv'.</assert>

      <assert test="journal-title-group/journal-title='EcoEvoRxiv'" 
        role="error" 
        id="ecoevorxiv-journal-title">EcoEvoRxiv preprints must have a &lt;journal-title> element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group> element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='EcoEvoRxiv'" 
        role="error" 
        id="ecoevorxiv-abbrev-journal-title">EcoEvoRxiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"> element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group> element.</assert>

      <assert test="publisher/publisher-name='Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)'" 
        role="error" 
        id="ecoevorxiv-publisher">EcoEvoRxiv preprints must have a &lt;publisher-name> element with the value 'Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)', inside a &lt;publisher> element.</assert>
     </rule>

      <rule context="article/front[journal-meta[lower-case(journal-id[1])='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi']" id="ecoevorxiv-doi-checks">
        <assert test="matches(.,'^10.32942/[A-Z\d]+$')" 
         role="error" 
         id="ecoevorxiv-doi-conformance">EcoEvoRxiv preprints must have a &lt;article-id pub-id-type="doi"> element with a value that matches the regex '^10.32942/[A-Z\d]+$'. In other words, the current DOI listed is not a valid EcoEvoRxiv DOI: '<value-of select="."/>'.</assert>
      </rule>
    </pattern>

    <pattern id="authorea-metadata">
     <rule context="article/front/journal-meta[lower-case(journal-id[1])='authorea']" id="authorea-journal-meta-checks">
        <assert test="journal-id[@journal-id-type='publisher-id']='Authorea'" 
        role="error" 
        id="authorea-journal-id">Authorea preprints must have a &lt;journal-id journal-id-type="publisher-id"> element with the value 'Authorea'.</assert>

      <assert test="journal-title-group/journal-title='Authorea'" 
        role="error" 
        id="authorea-journal-title">Authorea preprints must have a &lt;journal-title> element with the value 'Authorea' inside a &lt;journal-title-group> element.</assert>

      <assert test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='Authorea'" 
        role="error" 
        id="authorea-abbrev-journal-title">Authorea preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"> element with the value 'Authorea' inside a &lt;journal-title-group> element.</assert>

      <assert test="publisher/publisher-name='Authorea, Inc'" 
        role="error" 
        id="authorea-publisher">Authorea preprints must have a &lt;publisher-name> element with the value 'Authorea, Inc', inside a &lt;publisher> element.</assert>
     </rule>

      <rule context="article/front[journal-meta[lower-case(journal-id[1])='authorea']]/article-meta/article-id[@pub-id-type='doi']" id="authorea-doi-checks">
        <assert test="matches(.,'^10\.22541/au\.\d+\.\d+/v\d$')" 
         role="error" 
         id="authorea-doi-conformance">Authorea preprints must have a &lt;article-id pub-id-type="doi"> element with a value that matches the regex '^10\.22541/au\.\d+\.\d+/v\d$'. In other words, the current DOI listed is not a valid Authorea DOI: '<value-of select="."/>'.</assert>
      </rule>
    </pattern>
  
  <pattern id="processing-instructions">
    <rule context="processing-instruction('fig-class')" id="fig-class-pi-checks">
      <let name="supported-values" value="('full', 'half', 'quarter')"/>
      <let name="next-node-name" value="following-sibling::node()[not(self::text())][1]/name()"/>
      
      <assert test="$next-node-name=('fig','table-wrap')" 
         role="error" 
         id="fig-class-pi-1">'fig-class' processing-instructions must be placed directly before a fig or table-wrap element. This is placed before a <value-of select="$next-node-name"/> element.</assert>
      
      <assert test="normalize-space(.)=$supported-values" 
         role="error" 
         id="fig-class-pi-2">'fig-class' processing-instructions must contain one of the following values: <value-of select="string-join($supported-values,'; ')"/>. '<value-of select="."/>' is not supported.</assert>
    </rule>
    
    <rule context="processing-instruction('fig-width')" id="fig-width-pi-checks">
      <let name="supported-values" value="for $x in (1 to 12) return concat(string($x * 10),'%')"/>
      <let name="next-node-name" value="following-sibling::node()[not(self::text())][1]/name()"/>
      
      <assert test="$next-node-name=('fig','table-wrap')" 
         role="error" 
         id="fig-width-pi-1">'fig-width' processing-instructions must be placed directly before a fig or table-wrap element. This is placed before a <value-of select="$next-node-name"/> element.</assert>
      
      <assert test="normalize-space(.)=$supported-values" 
         role="error" 
         id="fig-width-pi-2">'fig-width' processing-instructions must contain a positive percentage value that is a multiple of 10, with 120 being the maximum (e.g. 120%). '<value-of select="."/>' is not supported.</assert>
    </rule>
    
    <rule context="processing-instruction('math-size')" id="math-size-pi-checks">
      <let name="next-node-name" value="following-sibling::node()[not(self::text())][1]/name()"/>
      
      <assert test="$next-node-name=('disp-formula','inline-formula')" 
         role="error" 
         id="math-size-pi-1">'math-size' processing-instructions must be placed directly before a disp-formula or inline-formula element. This is placed before a <value-of select="$next-node-name"/> element.</assert>
      
      <assert test="matches(normalize-space(.),'^([1-4]?[0-9](\.[5])?|50)$')" 
         role="error" 
         id="math-size-pi-2">'math-size' processing-instructions must contain a number greater than 0 and less than 50, 
      and must be either a whole number (integer) or a half-number (e.g., 1.5, 2.5). <value-of select="normalize-space(.)"/> is not.</assert>
    </rule>
    
    <rule context="processing-instruction('page-break')" id="page-break-pi-checks">
      <let name="allowed-parents" value="('article','body','back','sec','app','ack','boxed-text','statement','def-list','list','glossary','disp-quote')"/>
      
      <assert test="parent::*/name()=$allowed-parents" 
         role="error" 
         id="page-break-pi-1">'page-break' cannot be placed inside a <value-of select="parent::*/name()"/> element. It should be placed in one of the following: <value-of select="string-join($allowed-parents,'; ')"/></assert>
      
      <assert test="normalize-space(.)=''" 
         role="error" 
         id="page-break-pi-2">'page-break' processing-instructions must be empty. This one has the value <value-of select="."/>.</assert>
    </rule>
    
    <rule context="processing-instruction()" id="all-pi-checks">
      <let name="allowed-names" value="('fig-class','fig-width','math-size','page-break')"/>
      
      <!-- To do: remove 'oxygen', which is only included here to circumvent test suite errors -->
      <assert test="name()=($allowed-names,'oxygen')" 
         role="error" 
         id="all-pi-1">'<value-of select="name()"/>' is not an allowed processing-instruction. The only ones that can be used are: <value-of select="string-join($allowed-names,'; ')"/></assert>
    </rule>
  </pattern>
  
  <!-- These are purely for oXygen validation -->
    <pattern>
        <rule context="article[descendant::article-meta/pub-history/event/self-uri[@content-type='reviewed-preprint']]/sub-article[@article-type='editor-report']/front-stub" flag="local-only" id="assessment-api-check">
          <let name="article-id" value="ancestor::article//article-meta/article-id[@pub-id-type='publisher-id']"/>
          <let name="rp-version" value="replace(descendant::article-meta[1]/article-id[@specific-use='version'][1],'^.*\.','')"/>
          <let name="prev-version" value="if (matches($rp-version,'^\d$')) then number($rp-version) - 1
            else 1"/>
          <let name="epp-response" value="if ($article-id and $prev-version) then parse-json(cache:getRPData($article-id,string($prev-version)))
                                          else ('')"/>
          <let name="epp-assessment-data" value="if ($epp-response) then $epp-response?elifeAssessment else ()"/>
          <let name="prev-strength-terms" value="if ($epp-assessment-data) then $epp-assessment-data?strength?* else ()"/>
          <let name="prev-strength-rank" value="if ($prev-strength-terms) then sum(for $term in $prev-strength-terms[.!=''] return e:assessment-term-to-number($term))
            else ()"/>
          <let name="prev-significance-terms" value="if ($epp-assessment-data) then $epp-assessment-data?significance?* else ()"/>
          <let name="prev-significance-rank" value="if ($prev-significance-terms) then sum(for $term in $prev-significance-terms[.!=''] return e:assessment-term-to-number($term))
            else ()"/>
          
          <let name="curr-strength-terms" value="kwd-group[@kwd-group-type='evidence-strength']/kwd"/>
          <let name="curr-strength-rank" value="sum(for $term in $curr-strength-terms
            return e:assessment-term-to-number($term))"/>
          <let name="curr-significance-terms" value="kwd-group[@kwd-group-type='claim-importance']/kwd"/>
          <let name="curr-significance-rank" value="sum(for $term in $curr-significance-terms
            return e:assessment-term-to-number($term))"/>
          
          <report test="kwd-group[@kwd-group-type='evidence-strength']/kwd and ($prev-strength-rank gt $curr-strength-rank)" 
            role="warning" 
            id="str-kwd-api-check">Str: <value-of select="$prev-strength-terms"/>. Sig: <value-of select="$prev-significance-terms"/></report>
          
          <report test="kwd-group[@kwd-group-type='claim-importance']/kwd and ($prev-significance-rank gt $curr-significance-rank)" 
            role="warning" 
            id="sig-kwd-api-check">Str: <value-of select="$prev-strength-terms"/>. Sig: <value-of select="$prev-significance-terms"/></report>
      </rule>
    </pattern>

    <!-- Checks for the manifest file in the meca package.
          For validation in oXygen this assumes the manifest file is in a parent folder of the xml file being validated and named as manifest.xml
          For validation via BaseX, there is a separate file - meca-manifest-schematron.sch
     -->
    <pattern id="meca-manifest-checks">
     <rule context="root()" id="manifest-checks">
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
      
      <let name="missing-files" value="for $file in distinct-values($manifest-files) return if (not(java:file-exists($file, $parent-folder))) then $file else ()"/>
      <!-- the id is this for convenience -->
      <assert test="empty($missing-files)" 
        role="error" 
        id="graphic-media-presence">The following files referenced in the manifest.xml file are not present in the folder: <value-of select="$missing-files"/></assert>
     </rule>

    </pattern>
    
</schema>