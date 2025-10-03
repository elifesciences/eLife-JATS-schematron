<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="http://www.java.com/" xmlns:file="java.io.File" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:mml="http://www.w3.org/1998/Math/MathML" queryBinding="xslt2">
  <title>eLife Schematron</title>
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
  <let name="features-subj" value="('Feature Article', 'Insight', 'Editorial')"/>
  <let name="features-article-types" value="('article-commentary','editorial','discussion')"/>
  <let name="research-subj" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Scientific Correspondence', 'Review Article')"/>
  <let name="notice-article-types" value="('correction','retraction','expression-of-concern')"/>
  <let name="notice-display-types" value="('Correction','Retraction','Expression of Concern')"/>
  <let name="allowed-article-types" value="('research-article','review-article',$features-article-types, $notice-article-types)"/>
  <let name="allowed-disp-subj" value="($research-subj, $features-subj,$notice-display-types)"/>
  <let name="MSAs" value="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
  <let name="rors" value="'../../../../../src/rors.xml'"/>
  <let name="wellcome-funder-ids" value="('http://dx.doi.org/10.13039/100010269','http://dx.doi.org/10.13039/100004440','https://ror.org/029chgv08')"/>
  <let name="known-grant-funder-ids" value="('http://dx.doi.org/10.13039/100000936','http://dx.doi.org/10.13039/501100002241','http://dx.doi.org/10.13039/100000913','http://dx.doi.org/10.13039/501100002428','http://dx.doi.org/10.13039/100000968','https://ror.org/006wxqw41','https://ror.org/00097mb19','https://ror.org/03dy4aq19','https://ror.org/013tf3c58','https://ror.org/013kjyp64')"/>
  <let name="eu-horizon-fundref-ids" value="('http://dx.doi.org/10.13039/100018693','http://dx.doi.org/10.13039/100018694','http://dx.doi.org/10.13039/100018695','http://dx.doi.org/10.13039/100018696','http://dx.doi.org/10.13039/100018697','http://dx.doi.org/10.13039/100018698','http://dx.doi.org/10.13039/100018699','http://dx.doi.org/10.13039/100018700','http://dx.doi.org/10.13039/100018701','http://dx.doi.org/10.13039/100018702','http://dx.doi.org/10.13039/100018703','http://dx.doi.org/10.13039/100018704','http://dx.doi.org/10.13039/100018705','http://dx.doi.org/10.13039/100018706','http://dx.doi.org/10.13039/100018707','http://dx.doi.org/10.13039/100019180','http://dx.doi.org/10.13039/100019185','http://dx.doi.org/10.13039/100019186','http://dx.doi.org/10.13039/100019187','http://dx.doi.org/10.13039/100019188')"/>
  <let name="grant-doi-exception-funder-ids" value="($wellcome-funder-ids,$known-grant-funder-ids,$eu-horizon-fundref-ids)"/>
  <xsl:function name="e:is-prc" as="xs:boolean">
    <xsl:param name="elem" as="node()"/>
    <xsl:choose>
      <xsl:when test="$elem/name()='article'">
        <xsl:choose>
          <xsl:when test="$elem//article-meta/custom-meta-group/custom-meta[meta-name='publishing-route']/meta-value='prc'">
            <xsl:value-of select="true()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()"/>
          </xsl:otherwise>  
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="e:is-prc($elem/ancestor::article[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:get-version" as="xs:string">
    <xsl:param name="elem" as="node()"/>
    <xsl:choose>
      <xsl:when test="$elem/name()='article'">
        <xsl:value-of select="e:get-version-helper($elem)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="e:get-version-helper($elem/ancestor::article[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:get-version-helper" as="xs:string">
    <xsl:param name="article" as="node()"/>
    <xsl:choose>
      <xsl:when test="$article//article-meta/custom-meta-group/custom-meta[meta-name='schema-version']/meta-value">
        <xsl:value-of select="$article//article-meta/custom-meta-group/custom-meta[meta-name='schema-version']/meta-value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'1'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:titleCaseToken" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="contains($s,'-')">
        <xsl:value-of select="concat(           upper-case(substring(substring-before($s,'-'), 1, 1)),           lower-case(substring(substring-before($s,'-'),2)),           '-',           upper-case(substring(substring-after($s,'-'), 1, 1)),           lower-case(substring(substring-after($s,'-'),2)))"/>
      </xsl:when>
      <xsl:when test="lower-case($s)='elife'">
        <xsl:value-of select="'eLife'"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('and','or','the','an','of','in','as','at','by','for','a','to','up','but','yet')">
        <xsl:value-of select="lower-case($s)"/>
      </xsl:when>
      <xsl:when test="matches(lower-case($s),'^rna$|^dna$|^mri$|^hiv$|^tor$|^aids$|^covid-19$|^covid$')">
        <xsl:value-of select="upper-case($s)"/>
      </xsl:when>
      <xsl:when test="matches(lower-case($s),'[1-4]d')">
        <xsl:value-of select="upper-case($s)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(upper-case(substring($s, 1, 1)), lower-case(substring($s, 2)))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:titleCase" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      
      <xsl:when test="lower-case($s)='protein kinase a'">
        <xsl:value-of select="'Protein Kinase A'"/>
      </xsl:when>
      <xsl:when test="contains($s,' ')">
        <xsl:variable name="token1" select="substring-before($s,' ')"/>
        <xsl:variable name="token2" select="substring-after($s,$token1)"/>
        <xsl:choose>
          <xsl:when test="lower-case($token1)='elife'">
            <xsl:value-of select="concat('eLife',               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\p{Zs}') return e:titleCaseToken($x),' ')               )"/>
          </xsl:when>
          <xsl:when test="matches(lower-case($token1),'^rna$|^dna$|^mri$|^hiv$|^tor$|^aids$|^covid-19$|^covid$')">
            <xsl:value-of select="concat(upper-case($token1),               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\p{Zs}') return e:titleCaseToken($x),' ')               )"/>
          </xsl:when>
          <xsl:when test="matches(lower-case($token1),'[1-4]d')">
            <xsl:value-of select="concat(upper-case($token1),               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\p{Zs}') return e:titleCaseToken($x),' ')               )"/>
          </xsl:when>
          <xsl:when test="contains($token1,'-')">
            <xsl:value-of select="string-join(for $x in tokenize($s,'\p{Zs}') return e:titleCaseToken($x),' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(               concat(upper-case(substring($token1, 1, 1)), lower-case(substring($token1, 2))),               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\p{Zs}') return e:titleCaseToken($x),' ')               )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="lower-case($s)='elife'">
        <xsl:value-of select="'eLife'"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('and','or','the','an','of')">
        <xsl:value-of select="lower-case($s)"/>
      </xsl:when>
      <xsl:when test="matches(lower-case($s),'^rna$|^dna$|^mri$|^hiv$|^tor$|^aids$|^covid-19$|^covid$')">
        <xsl:value-of select="upper-case($s)"/>
      </xsl:when>
      <xsl:when test="matches(lower-case($s),'[1-4]d')">
        <xsl:value-of select="upper-case($s)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="e:titleCaseToken($s)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:article-type2title" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$s = 'Replication Study'">
        <xsl:value-of select="'Replication Study:'"/>
      </xsl:when>
      <xsl:when test="$s = 'Registered Report'">
        <xsl:value-of select="'Registered report:'"/>
      </xsl:when>
      <xsl:when test="$s = 'Correction'">
        <xsl:value-of select="'Correction:'"/>
      </xsl:when>
      <xsl:when test="$s = 'Retraction'">
        <xsl:value-of select="'Retraction:'"/>
      </xsl:when>
      <xsl:when test="$s = 'Expression of Concern'">
        <xsl:value-of select="'Expression of concern:'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undefined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:sec-type2title" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$s = 'intro'">
        <xsl:value-of select="'Introduction'"/>
      </xsl:when>
      <xsl:when test="$s = 'results'">
        <xsl:value-of select="'Results'"/>
      </xsl:when>
      <xsl:when test="$s = 'discussion'">
        <xsl:value-of select="'Discussion'"/>
      </xsl:when>
      <xsl:when test="$s = 'materials|methods'">
        <xsl:value-of select="'Materials and methods'"/>
      </xsl:when>
      <xsl:when test="$s = 'results|discussion'">
        <xsl:value-of select="'Results and discussion'"/>
      </xsl:when>
      <xsl:when test="$s = 'methods'">
        <xsl:value-of select="'Methods'"/>
      </xsl:when>
      <xsl:when test="$s = 'model'">
        <xsl:value-of select="'Model'"/>
      </xsl:when>
      <xsl:when test="$s = 'additional-information'">
        <xsl:value-of select="'Additional information'"/>
      </xsl:when>
      <xsl:when test="$s = 'supplementary-material'">
        <xsl:value-of select="'Additional files'"/>
      </xsl:when>
      <xsl:when test="$s = 'data-availability'">
        <xsl:value-of select="'Data availability'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undefined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:fig-id-type" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="matches($s,'^fig[0-9]{1,3}$')">
        <xsl:value-of select="'Figure'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^fig[0-9]{1,3}s[0-9]{1,3}$')">
        <xsl:value-of select="'Figure supplement'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^box[0-9]{1,3}fig[0-9]{1,3}$')">
        <xsl:value-of select="'Box figure'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^app[0-9]{1,3}fig[0-9]{1,3}$')">
        <xsl:value-of select="'Appendix figure'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^app[0-9]{1,3}fig[0-9]{1,3}s[0-9]{1,3}$')">
        <xsl:value-of select="'Appendix figure supplement'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')">
        <xsl:value-of select="'Author response figure'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^C[0-9]{1,3}$|^chem[0-9]{1,3}$')">
        <xsl:value-of select="'Chemical structure'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^app[0-9]{1,3}C[0-9]{1,3}$|^app[0-9]{1,3}chem[0-9]{1,3}$')">
        <xsl:value-of select="'Appendix chemical structure'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^S[0-9]{1,3}$|^scheme[0-9]{1,3}$')">
        <xsl:value-of select="'Scheme'"/>
      </xsl:when>
      <xsl:when test="matches($s,'^app[0-9]{1,3}S[0-9]{1,3}$|^app[0-9]{1,3}scheme[0-9]{1,3}$')">
        <xsl:value-of select="'Appendix scheme'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undefined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:stripDiacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="replace(replace(replace(translate(normalize-unicode($string,'NFD'),'ƀȼđɇǥħɨıɉꝁłøɍŧɏƶ','bcdeghiijklortyz'),'[\p{M}’]',''),'æ','ae'),'ß','ss')"/>
  </xsl:function>
  <xsl:function name="e:ref-list-string" as="xs:string">
    <xsl:param name="ref"/>
    <xsl:choose>
      <xsl:when test="$ref/element-citation[1]/person-group[1]/* and $ref/element-citation[1]/year">
        <xsl:value-of select="concat(           replace(e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[1]),'\p{Zs}',''),           ' ',           $ref/element-citation[1]/year[1],           ' ',           string-join(for $x in $ref/element-citation[1]/person-group[1]/*[position()=(2,3)]           return replace(e:get-collab-or-surname($x),'\p{Zs}',''),' ')           )"/>
      </xsl:when>
      <xsl:when test="$ref/element-citation/person-group[1]/*">
        <xsl:value-of select="concat(           replace(e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[1]),'\p{Zs}',''),           ' 9999 ',           string-join(for $x in $ref/element-citation[1]/person-group[1]/*[position()=(2,3)]           return replace(e:get-collab-or-surname($x),'\p{Zs}',''),' ')           )"/>
      </xsl:when>
      <xsl:when test="$ref/element-citation/year">
        <xsl:value-of select="concat(' ',$ref/element-citation[1]/year[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'zzzzz 9999'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:ref-list-string2" as="xs:string">
    <xsl:param name="ref"/>
    <xsl:choose>
      <xsl:when test="$ref/element-citation[1]/year and count($ref/element-citation[1]/person-group[1]/*) = 2">
        <xsl:value-of select="concat(           e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[1]),           ' ',           e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[2]),           ' ',           $ref/element-citation[1]/year[1])"/>
      </xsl:when>
      <xsl:when test="$ref/element-citation/person-group[1]/* and $ref/element-citation[1]/year">
        <xsl:value-of select="concat(           e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[1]),           ' ',           $ref/element-citation[1]/year[1])"/>
      </xsl:when>
      <xsl:when test="$ref/element-citation/person-group[1]/*">
        <xsl:value-of select="concat(           e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[1]),           ' 9999 ')"/>
      </xsl:when>
      <xsl:when test="$ref/element-citation/year">
        <xsl:value-of select="concat(' ',$ref/element-citation[1]/year[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'zzzzz 9999'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:get-collab-or-surname" as="xs:string?">
    <xsl:param name="collab-or-name"/>
    <xsl:choose>
      <xsl:when test="$collab-or-name/name()='collab'">
        <xsl:value-of select="e:stripDiacritics(replace(lower-case($collab-or-name),'\.',''))"/>
      </xsl:when>
      <xsl:when test="$collab-or-name/surname">
        <xsl:value-of select="e:stripDiacritics(lower-case($collab-or-name/surname[1]))"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:cite-name-text" as="xs:string">
    <xsl:param name="person-group"/>
    <xsl:choose>
      <xsl:when test="(count($person-group/*) = 1) and $person-group/name">
        <xsl:value-of select="$person-group/name/surname[1]"/>
      </xsl:when>
      <xsl:when test="(count($person-group/*) = 1) and $person-group/collab">
        <xsl:value-of select="$person-group/collab"/>
      </xsl:when>
      <xsl:when test="(count($person-group/*) = 2) and (count($person-group/name) = 1) and $person-group/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($person-group/collab,' and ',$person-group/name/surname[1])"/>
      </xsl:when>
      <xsl:when test="(count($person-group/*) = 2) and (count($person-group/name) = 1) and $person-group/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($person-group/name/surname[1],' and ',$person-group/collab)"/>
      </xsl:when>
      <xsl:when test="(count($person-group/*) = 2) and (count($person-group/name) = 2)">
        <xsl:value-of select="concat($person-group/name[1]/surname[1],' and ',$person-group/name[2]/surname[1])"/>
      </xsl:when>
      <xsl:when test="(count($person-group/*) = 2) and (count($person-group/collab) = 2)">
        <xsl:value-of select="concat($person-group/collab[1],' and ',$person-group/collab[2])"/>
      </xsl:when>
      <xsl:when test="(count($person-group/*) ge 2) and $person-group/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($person-group/collab[1], ' et al.')"/>
      </xsl:when>
      <xsl:when test="(count($person-group/*) ge 2) and $person-group/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($person-group/name[1]/surname[1], ' et al.')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undetermined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:citation-format1" as="xs:string">
    <xsl:param name="element-citation"/>
    <xsl:choose>
      <xsl:when test="$element-citation/person-group and $element-citation//year">
        <xsl:value-of select="concat(e:cite-name-text($element-citation/person-group[1]),', ',$element-citation/descendant::year[1])"/>
      </xsl:when>
      <xsl:when test="$element-citation/person-group and not($element-citation//year)">
        <xsl:value-of select="concat(e:cite-name-text($element-citation/person-group[1]),', ')"/>
      </xsl:when>
      <xsl:when test="not($element-citation/person-group) and $element-citation//year">
        <xsl:value-of select="concat('et al., ',$element-citation/descendant::year[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="', '"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:citation-format2" as="xs:string">
    <xsl:param name="element-citation"/>
    <xsl:choose>
      <xsl:when test="$element-citation/person-group and $element-citation//year">
        <xsl:value-of select="concat(e:cite-name-text($element-citation/person-group[1]),' (',$element-citation/descendant::year[1],')')"/>
      </xsl:when>
      <xsl:when test="$element-citation/person-group and not($element-citation//year)">
        <xsl:value-of select="concat(e:cite-name-text($element-citation/person-group[1]),' ()')"/>
      </xsl:when>
      <xsl:when test="not($element-citation/person-group) and $element-citation//year">
        <xsl:value-of select="concat('et al. (',$element-citation/descendant::year[1],')')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="', '"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:ref-cite-list">
    <xsl:param name="ref-list" as="node()"/>
    <xsl:element name="list">
      <xsl:for-each select="$ref-list/ref[element-citation[year]]">
        <xsl:variable name="cite" select="e:citation-format1(./element-citation[1])"/>
        <xsl:element name="item">
          <xsl:attribute name="id">
            <xsl:value-of select="./@id"/>
          </xsl:attribute>
          <xsl:attribute name="no-suffix">
            <xsl:value-of select="replace($cite,'[A-Za-z]$','')"/>
          </xsl:attribute>
          <xsl:value-of select="$cite"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:function>
  <xsl:function name="e:non-distinct-citations">
    <xsl:param name="cite-list" as="node()"/>
    <xsl:element name="list">
    <xsl:for-each select="$cite-list//*:item">
      <xsl:variable name="cite" select="./string()"/>
      <xsl:choose>
        <xsl:when test="./preceding::*:item/string() = $cite">
          <xsl:element name="item">
            <xsl:attribute name="id">
              <xsl:value-of select="./@id"/>
            </xsl:attribute>
            <xsl:value-of select="$cite"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="not(matches($cite,'[A-Za-z]$')) and (./preceding::*:item/@no-suffix/string() = $cite)">
          <xsl:element name="item">
            <xsl:attribute name="id">
              <xsl:value-of select="./@id"/>
            </xsl:attribute>
          <xsl:value-of select="$cite"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="not(matches($cite,'[A-Za-z]$')) and ./following::*:item/@no-suffix/string() = $cite">
          <xsl:element name="item">
            <xsl:attribute name="id">
              <xsl:value-of select="./@id"/>
            </xsl:attribute>
          <xsl:value-of select="$cite"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:for-each>
    </xsl:element>
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
  <xsl:function name="e:get-collab">
    <xsl:param name="collab"/>
    <xsl:for-each select="$collab/(*|text())">
      <xsl:choose>
        <xsl:when test="./name()='contrib-group'"/>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>
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
        <xsl:variable name="check" select="if (substring($id,string-length($id))) then 10                                                                            else number(substring($id,string-length($id)))"/>
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
        <xsl:variable name="digit" select="if ($char = 'X') then 10                                            else xs:integer($char)"/>
        <xsl:variable name="new-total" select="($total + $digit) * 2"/>
        <xsl:value-of select="e:orcid-calculate-total($digits, $index+1, $new-total)"/>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:function>
  <xsl:function name="e:escape-for-regex" as="xs:string">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:sequence select="replace($arg,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
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
  <let name="research-organisms" value="'../../../../../src/research-organisms.xml'"/>
  <let name="species-regex" value="string-join(doc($research-organisms)//*:organism[@type='species']/@regex,'|')"/>
  <let name="genus-regex" value="string-join(doc($research-organisms)//*:organism[@type='genus']/@regex,'|')"/>
  <let name="org-regex" value="string-join(($species-regex,$genus-regex),'|')"/>
  <let name="sec-title-regex" value="string-join(     for $x in tokenize($org-regex,'\|')     return concat('^',$x,'$')     ,'|')"/>
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
            <match>
              <xsl:value-of select="."/>
            </match>
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
        <organism text-count="{$text-count}" italic-count="{$italic-count}">
          <xsl:value-of select="$name"/>
        </organism>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>
  <xsl:function name="e:code-check">
    <xsl:param name="s" as="xs:string"/>
    <xsl:element name="code">
      <xsl:if test="contains($s,'github')">
        <xsl:element name="match">
        <xsl:value-of select="'github '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="contains($s,'gitlab')">
        <xsl:element name="match">
        <xsl:value-of select="'gitlab '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="contains($s,'git.exeter.ac.uk')">
        <xsl:element name="match">
          <xsl:value-of select="'git.exeter.ac.uk '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="contains($s,'codeplex')">
        <xsl:element name="match">
        <xsl:value-of select="'codeplex '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="contains($s,'sourceforge')">
        <xsl:element name="match">
        <xsl:value-of select="'sourceforge '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="contains($s,'bitbucket')">
        <xsl:element name="match">
        <xsl:value-of select="'bitbucket '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="contains($s,'assembla ')">
        <xsl:element name="match">
        <xsl:value-of select="'assembla '"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:function>
  <xsl:function name="e:get-xrefs">
    <xsl:param name="article"/>
    <xsl:param name="object-id"/>
    <xsl:param name="object-type"/>
    <xsl:variable name="object-no" select="number(replace($object-id,'[^0-9]',''))"/>
    <xsl:variable name="object-regex" select="concat($object-no,',?\s','|',$object-no,'$')"/>
    <xsl:element name="matches">
      <xsl:for-each select="$article//xref[(@ref-type=$object-type) and not(ancestor::caption) and not(ancestor::table-wrap)]">
        <xsl:variable name="rid-no" select="number(replace(./@rid,'[^0-9]',''))"/>
        <xsl:variable name="text-no-string" select="tokenize(normalize-space(replace(.,'[^0-9]',' ')),'\p{Z}|\p{Pd}')[last()]"/>
        <xsl:variable name="text-no" select="if ($text-no-string='') then 0 else number($text-no-string)"/>
        <xsl:choose>
          <xsl:when test="./@rid = $object-id">
            <xsl:element name="match">
              <xsl:attribute name="sec-id">
                <xsl:value-of select="./ancestor::sec[1]/@id"/>
              </xsl:attribute>
              <xsl:value-of select="self::*"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="contains(./@rid,'app')"/>
          <xsl:when test="($rid-no lt $object-no) and (./following-sibling::text()[1] = '–') and (./following-sibling::*[1]/name()='xref') and (number(replace(replace(./following-sibling::xref[1]/@rid,'\-','.'),'[a-z]','')) gt number($object-no))">
            <xsl:element name="match">
              <xsl:attribute name="sec-id">
                <xsl:value-of select="./ancestor::sec[1]/@id"/>
              </xsl:attribute>
              <xsl:value-of select="self::*"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="($rid-no lt $object-no) and contains(lower-case(.),'videos') and (matches(.,$object-regex) or ($text-no gt $object-no))">
            <xsl:element name="match">
              <xsl:attribute name="sec-id">
                <xsl:value-of select="./ancestor::sec[1]/@id"/>
              </xsl:attribute>
              <xsl:value-of select="self::*"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:function>
  <xsl:function name="e:get-iso-pub-date">
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="$element/ancestor-or-self::article//article-meta/pub-date[(@date-type='publication') or (@date-type='pub')]/month">
        <xsl:variable name="pub-date" select="$element/ancestor-or-self::article//article-meta/pub-date[(@date-type='publication') or (@date-type='pub')]"/>
        <xsl:value-of select="concat($pub-date/year,'-',$pub-date/month,'-',$pub-date/day)"/>
      </xsl:when>
      <xsl:otherwise/>
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
                <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author']/collab[1]/text()[1],' and ',$contrib-group/contrib[@contrib-type='author']/collab[2]/text()[1])"/>
              </xsl:when>
              <xsl:when test="$contrib-group/contrib[@contrib-type='author'][1]/collab">
                <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/collab[1]/text()[1],' and ',$contrib-group/contrib[@contrib-type='author'][2]/name[1]/surname[1])"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/name[1]/surname[1],' and ',$contrib-group/contrib[@contrib-type='author'][2]/collab[1]/text()[1])"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/name[1]/surname[1],' and ',$contrib-group/contrib[@contrib-type='author'][2]/name[1]/surname[1])"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:variable name="is-equal-contrib" select="if ($contrib-group/contrib[@contrib-type='author'][1]/@equal-contrib='yes') then true() else false()"/>
        <xsl:choose>
          <xsl:when test="$is-equal-contrib">
            
            <xsl:variable name="equal-contrib-rid" select="$contrib-group/contrib[@contrib-type='author'][1]/xref[starts-with(@rid,'equal-contrib')]/@rid"/>
            <xsl:variable name="first-authors" select="$contrib-group/contrib[@contrib-type='author' and @equal-contrib='yes' and xref[@rid=$equal-contrib-rid] and not(preceding-sibling::contrib[not(xref[@rid=$equal-contrib-rid])])]"/>
            <xsl:choose>
              
              <xsl:when test="$author-count = 3 and count($first-authors) = 3">
                <xsl:value-of select="concat(e:get-surname($contrib-group/contrib[@contrib-type='author'][1]),                   ', ',                   e:get-surname($contrib-group/contrib[@contrib-type='author'][2]),                   ' and ',                   e:get-surname($contrib-group/contrib[@contrib-type='author'][3]))"/>
              </xsl:when>
              
              <xsl:when test="count($first-authors) gt 3">
                <xsl:variable name="first-auth-string" select="string-join(for $auth in $contrib-group/contrib[@contrib-type='author'][position() lt 4] return e:get-surname($auth),', ')"/>
                <xsl:value-of select="concat($first-auth-string,' et al')"/>
              </xsl:when>
              
              <xsl:otherwise>
                <xsl:variable name="first-auth-string" select="string-join(for $auth in $first-authors return e:get-surname($auth),', ')"/>
                <xsl:value-of select="concat($first-auth-string,' et al')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          
          <xsl:otherwise>
            <xsl:value-of select="concat(e:get-surname($contrib-group/contrib[@contrib-type='author'][1]),' et al')"/>
          </xsl:otherwise>
        </xsl:choose>
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
  <xsl:function name="e:insight-box" as="element()">
    <xsl:param name="box" as="xs:string"/>
    <xsl:param name="cite-text" as="xs:string"/>
    <xsl:variable name="box-text" select="substring-after(substring-after($box,'article'),' ')"/> 
    
    <xsl:element name="list">
      <xsl:for-each select="tokenize($cite-text,'\p{Zs}')">
        <xsl:choose>
          <xsl:when test="contains($box-text,.)"/>
          <xsl:otherwise>
            <xsl:element name="item">
              <xsl:attribute name="type">cite</xsl:attribute>
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="tokenize($box-text,'\p{Zs}')">
        <xsl:choose>
          <xsl:when test="contains($cite-text,.)"/>
          <xsl:otherwise>
            <xsl:element name="item">
              <xsl:attribute name="type">box</xsl:attribute>
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:element>
  </xsl:function>
  <let name="latin-regex" value="'in\p{Zs}+vitro|ex\p{Zs}+vitro|in\p{Zs}+vivo|ex\p{Zs}+vivo|a\p{Zs}+priori|a\p{Zs}+posteriori|de\p{Zs}+novo|in\p{Zs}+utero|in\p{Zs}+natura|in\p{Zs}+situ|in\p{Zs}+planta|in\p{Zs}+cellulo|rete\p{Zs}+mirabile|nomen\p{Zs}+novum| sensu |ad\p{Zs}+libitum|in\p{Zs}+ovo'"/>
  <xsl:function name="e:get-latin-terms" as="element()">
    <xsl:param name="article" as="element()"/>
    <xsl:param name="regex" as="xs:string"/>
    
    <xsl:variable name="roman-text" select="lower-case(       string-join(for $x in $article/*[local-name() = 'body' or local-name() = 'back']//*       return       if ($x/ancestor-or-self::sec[@sec-type='additional-information']) then ()       else if ($x/ancestor-or-self::ref-list) then ()       else if ($x/local-name() = 'italic') then ()       else $x/text(),' '))"/>
    <xsl:variable name="italic-text" select="lower-case(string-join($article//*:italic[not(ancestor::ref-list) and not(ancestor::sec[@sec-type='additional-information'])],' '))"/>
    
    
    <xsl:element name="result">
      <xsl:choose>
        <xsl:when test="matches($roman-text,$regex)">
          <xsl:element name="list">
            <xsl:attribute name="list-type">roman</xsl:attribute>
            <xsl:for-each select="tokenize($regex,'\|')">
              <xsl:variable name="display" select="replace(replace(.,'\\p\{Zs\}\+',' '),'^ | $','')"/>
              <xsl:element name="match">
                <xsl:attribute name="count">
                  <xsl:value-of select="count(tokenize($roman-text,.)) - 1"/>
                </xsl:attribute>
                <xsl:value-of select="$display"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="list">
            <xsl:attribute name="list-type">roman</xsl:attribute>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="matches($italic-text,$regex)">
          <xsl:element name="list">
            <xsl:attribute name="list-type">italic</xsl:attribute>
            <xsl:for-each select="tokenize($regex,'\|')">
              <xsl:variable name="display" select="replace(.,'\\p\{Zs\}\+',' ')"/>
              <xsl:element name="match">
                <xsl:attribute name="count">
                  <xsl:value-of select="count(tokenize($italic-text,.)) - 1"/>
                </xsl:attribute>
                <xsl:value-of select="$display"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="list">
            <xsl:attribute name="list-type">italic</xsl:attribute>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:function>
  <xsl:function name="e:print-latin-terms" as="xs:string">
    <xsl:param name="list" as="element()"/>
    <xsl:value-of select="string-join(       for $term in $list//*:match[@count != '0']        return if (number($term/@count) gt 1) then concat($term/@count,' instances of ',$term)       else concat($term/@count,' instance of ',$term)       ,', ')"/>
  </xsl:function>
  <xsl:function name="e:list-panels">
    <xsl:param name="caption" as="xs:string"/>
    <xsl:element name="list">
      <xsl:for-each select="tokenize($caption,'\.\p{Zs}+')">
        <xsl:if test="matches(.,'^[B-K]\p{P}?[A-K]?\.?\p{Zs}+')">
          <xsl:element name="item">
            <xsl:attribute name="token">
              <xsl:value-of select="substring-before(.,' ')"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:element>
  </xsl:function>
  <xsl:function name="e:alter-award-id">
    <xsl:param name="award-id-elem" as="xs:string"/>
    <xsl:param name="funder-id" as="xs:string"/>
    <xsl:choose>
      
      <xsl:when test="$funder-id=$wellcome-funder-ids">
        <xsl:value-of select="if (contains(lower-case($award-id-elem),'/z')) then replace(substring-before(lower-case($award-id-elem),'/z'),'[^\d]','')          else if (contains(lower-case($award-id-elem),'_z')) then replace(substring-before(lower-case($award-id-elem),'_z'),'[^\d]','')         else if (matches($award-id-elem,'[^\d]') and matches($award-id-elem,'\d')) then replace($award-id-elem,'[^\d]','')         else $award-id-elem"/>
      </xsl:when>
      
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000936','https://ror.org/006wxqw41')">
        
        <xsl:value-of select="if (matches($award-id-elem,'^\d+(\.\d+)?$')) then concat('GBMF',$award-id-elem)          else if (not(matches(upper-case($award-id-elem),'^GBMF'))) then concat('GBMF',replace($award-id-elem,'[^\d\.]',''))          else upper-case($award-id-elem)"/>
      </xsl:when>
      
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/501100002241','https://ror.org/00097mb19')">
        
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JPMJ[A-Z0-9]+\s*$') and not(matches(upper-case($award-id-elem),'^JPMJ[A-Z0-9]+$'))) then concat('JPMJ',upper-case(replace(substring-after($award-id-elem,'JPMJ'),'\s+$','')))         else upper-case($award-id-elem)"/>
      </xsl:when>
      
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000913','https://ror.org/03dy4aq19')">
        
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JSMF2\d+$')) then substring-after($award-id-elem,'JSMF')         else replace($award-id-elem,'[^\d\-]','')"/>
      </xsl:when>
      
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/501100002428','https://ror.org/013tf3c58')">
        
        <xsl:value-of select="if (matches($award-id-elem,'\d\-')) then replace(substring-before($award-id-elem,'-'),'[^A-Z\d]','')         else replace($award-id-elem,'[^A-Z\d]','')"/>
      </xsl:when>
      
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000968','https://ror.org/013kjyp64')">
        
        <xsl:value-of select="if (matches($award-id-elem,'[a-z]\s+\([A-Z\d]+\)')) then substring-before(substring-after($award-id-elem,'('),')')         else $award-id-elem"/>
      </xsl:when>
      
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000968','https://ror.org/013kjyp64')">
        
        <xsl:value-of select="if (contains(upper-case($award-id-elem),'2020')) then concat('2020',replace(substring-after($award-id-elem,'2020'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2021')) then concat('2021',replace(substring-after($award-id-elem,'2021'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2022')) then concat('2022',replace(substring-after($award-id-elem,'2022'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2023')) then concat('2023',replace(substring-after($award-id-elem,'2023'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2024')) then concat('2024',replace(substring-after($award-id-elem,'2024'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'CEEC')) then concat('CEEC',replace(substring-after(upper-case($award-id-elem),'CEEC'),'[^A-Z0-9/]',''))         else if (contains(upper-case($award-id-elem),'PTDC/')) then concat('PTDC/',replace(substring-after(upper-case($award-id-elem),'PTDC/'),'[^A-Z0-9/\-]',''))         else if (contains(upper-case($award-id-elem),'DL 57/')) then concat('DL 57/',replace(substring-after(upper-case($award-id-elem),'DL 57/'),'[^A-Z0-9/\-]',''))         else $award-id-elem"/>
      </xsl:when>
      
      <xsl:when test="$funder-id=('https://ror.org/0472cxd90','https://ror.org/00k4n6c32',$eu-horizon-fundref-ids,'http://dx.doi.org/10.13039/100010663','http://dx.doi.org/10.13039/100010665','http://dx.doi.org/10.13039/100010669','http://dx.doi.org/10.13039/100010675','http://dx.doi.org/10.13039/100010677','http://dx.doi.org/10.13039/100010679','http://dx.doi.org/10.13039/100010680','http://dx.doi.org/10.13039/100018694','http://dx.doi.org/10.13039/100019180')">
        
        <xsl:value-of select="replace($award-id-elem,'\D','')"/>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:value-of select="$award-id-elem"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="e:get-weekday" as="xs:integer?">
    <xsl:param name="date" as="xs:anyAtomicType?"/>
    <xsl:sequence select="       if (empty($date)) then ()       else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7       "/>
  </xsl:function>
  <xsl:function name="e:line-count" as="xs:integer">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:sequence select="count(tokenize($arg,'(\r\n?|\n\r?)'))"/>
  </xsl:function>
  <pattern id="house-style">
    <rule context="sec[@sec-type='data-availability']//element-citation/person-group[@person-group-type='author']//given-names" id="data-ref-given-names">
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-ref-given-names-test-1" test="string-length(.) gt 4" role="warning" id="data-ref-given-names-test-1">Given names should always be initialised. Ref contains a given names with a string longer than 4 characters - '<value-of select="."/>' in <value-of select="concat(preceding-sibling::surname[1],' ',.)"/>. Is this a surname captured as given names? Or a fully spelt out given names?</report>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::sec[@sec-type='data-availability']//element-citation/person-group[@person-group-type='author']//given-names" role="error" id="data-ref-given-names-xspec-assert">sec[@sec-type='data-availability']//element-citation/person-group[@person-group-type='author']//given-names must be present.</assert>
    </rule>
  </pattern>
</schema>