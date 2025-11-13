<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:file="java.io.File" xmlns:java="http://www.java.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" queryBinding="xslt2">

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
	<!-- Added in case we want to validate the presence of ancillary files -->
  <ns uri="java.io.File" prefix="file"/>
  <ns uri="http://www.java.com/" prefix="java"/>

  <!--=== Global Variables ===-->
  <!-- Features specific values included here for convenience -->
  <let name="features-subj" value="('Feature Article', 'Insight', 'Editorial')"/>
  <let name="features-article-types" value="('article-commentary','editorial','discussion')"/>
  <let name="research-subj" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Scientific Correspondence', 'Review Article')"/>
  
  <!-- Notice type articles -->
  <let name="notice-article-types" value="('correction','retraction','expression-of-concern')"/>
  <let name="notice-display-types" value="('Correction','Retraction','Expression of Concern')"/>
  
  <!-- All article types -->
  <let name="allowed-article-types" value="('research-article','review-article',$features-article-types, $notice-article-types)"/>
  <let name="allowed-disp-subj" value="($research-subj, $features-subj,$notice-display-types)"/> 
  
  <let name="MSAs" value="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
  
  <let name="rors" value="'rors.xml'"/>
  <!-- Grant DOI enabling -->
  <let name="wellcome-funder-ids" value="('http://dx.doi.org/10.13039/100010269','http://dx.doi.org/10.13039/100004440','https://ror.org/029chgv08')"/>
  <let name="known-grant-funder-ids" value="('http://dx.doi.org/10.13039/100000936','http://dx.doi.org/10.13039/501100002241','http://dx.doi.org/10.13039/100000913','http://dx.doi.org/10.13039/501100002428','http://dx.doi.org/10.13039/100000968','https://ror.org/006wxqw41','https://ror.org/00097mb19','https://ror.org/03dy4aq19','https://ror.org/013tf3c58','https://ror.org/013kjyp64')"/>
  <let name="eu-horizon-fundref-ids" value="('http://dx.doi.org/10.13039/100018693','http://dx.doi.org/10.13039/100018694','http://dx.doi.org/10.13039/100018695','http://dx.doi.org/10.13039/100018696','http://dx.doi.org/10.13039/100018697','http://dx.doi.org/10.13039/100018698','http://dx.doi.org/10.13039/100018699','http://dx.doi.org/10.13039/100018700','http://dx.doi.org/10.13039/100018701','http://dx.doi.org/10.13039/100018702','http://dx.doi.org/10.13039/100018703','http://dx.doi.org/10.13039/100018704','http://dx.doi.org/10.13039/100018705','http://dx.doi.org/10.13039/100018706','http://dx.doi.org/10.13039/100018707','http://dx.doi.org/10.13039/100019180','http://dx.doi.org/10.13039/100019185','http://dx.doi.org/10.13039/100019186','http://dx.doi.org/10.13039/100019187','http://dx.doi.org/10.13039/100019188')"/>
  <let name="grant-doi-exception-funder-ids" value="($wellcome-funder-ids,$known-grant-funder-ids,$eu-horizon-fundref-ids)"/>  

  <!--=== Custom functions ===-->
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
      <!-- specific exception -->
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
  
  <!-- generates a string from a reference which is used to determine the position the reference should have in the ref list -->
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
  
  <!-- invoked in e:ref-list-string -->
  <xsl:function name="e:get-collab-or-surname" as="xs:string?">
    <xsl:param name="collab-or-name"/>
    <xsl:choose>
      <xsl:when test="$collab-or-name/name()='collab'">
        <xsl:value-of select="e:stripDiacritics(replace(lower-case($collab-or-name),'\.',''))"/>
      </xsl:when>
      <xsl:when test="$collab-or-name/surname">
        <xsl:value-of select="e:stripDiacritics(replace(lower-case($collab-or-name/surname[1]),'[-‐‑–—]','-'))"/>
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
        <xsl:variable name="cite" select="replace(e:citation-format1(./element-citation[1]),'\p{Pd}','-')"/>
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
        <!-- Shouldn't occur in eLife content -->
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
  
  <!-- Global variable included here for convenience -->
  <let name="research-organisms" value="'research-organisms.xml'"/>
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
      <!-- author count is 3+ -->
      <xsl:otherwise>
        <xsl:variable name="is-equal-contrib" select="if ($contrib-group/contrib[@contrib-type='author'][1]/@equal-contrib='yes') then true() else false()"/>
        <xsl:choose>
          <xsl:when test="$is-equal-contrib">
            <!-- when there's more than one first author -->
            <xsl:variable name="equal-contrib-rid" select="$contrib-group/contrib[@contrib-type='author'][1]/xref[starts-with(@rid,'equal-contrib')]/@rid"/>
            <xsl:variable name="first-authors" select="$contrib-group/contrib[@contrib-type='author' and @equal-contrib='yes' and xref[@rid=$equal-contrib-rid] and not(preceding-sibling::contrib[not(xref[@rid=$equal-contrib-rid])])]"/>
            <xsl:choose>
              <!-- when there are 3 authors total, and they're all equal contrib -->
              <xsl:when test="$author-count = 3 and count($first-authors) = 3">
                <xsl:value-of select="concat(e:get-surname($contrib-group/contrib[@contrib-type='author'][1]),                   ', ',                   e:get-surname($contrib-group/contrib[@contrib-type='author'][2]),                   ' and ',                   e:get-surname($contrib-group/contrib[@contrib-type='author'][3]))"/>
              </xsl:when>
              <!-- when there are more than 3 first authors (and more than 3 authors total) -->
              <xsl:when test="count($first-authors) gt 3">
                <xsl:variable name="first-auth-string" select="string-join(for $auth in $contrib-group/contrib[@contrib-type='author'][position() lt 4] return e:get-surname($auth),', ')"/>
                <xsl:value-of select="concat($first-auth-string,' et al')"/>
              </xsl:when>
              <!-- when there are 3 or fewer first authors (and more than 3 authors total) -->
              <xsl:otherwise>
                <xsl:variable name="first-auth-string" select="string-join(for $auth in $first-authors return e:get-surname($auth),', ')"/>
                <xsl:value-of select="concat($first-auth-string,' et al')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- when there's one first author -->
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

  <!-- Funders may have internal grant DOIs or indistinct conventions for award IDs
            this function is an attempt to account for this to better match award ids with grant DOIs -->
   <xsl:function name="e:alter-award-id">
    <xsl:param name="award-id-elem" as="xs:string"/>
    <xsl:param name="funder-id" as="xs:string"/>
    <xsl:choose>
      <!-- Wellcome -->
      <xsl:when test="$funder-id=$wellcome-funder-ids">
        <xsl:value-of select="if (contains(lower-case($award-id-elem),'/z')) then replace(substring-before(lower-case($award-id-elem),'/z'),'[^\d]','')          else if (contains(lower-case($award-id-elem),'_z')) then replace(substring-before(lower-case($award-id-elem),'_z'),'[^\d]','')         else if (matches($award-id-elem,'[^\d]') and matches($award-id-elem,'\d')) then replace($award-id-elem,'[^\d]','')         else $award-id-elem"/>
      </xsl:when>
      <!-- GBMF -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000936','https://ror.org/006wxqw41')">
        <!-- GBMF grant DOIs are registered like so: GBMF0000 -->
        <xsl:value-of select="if (matches($award-id-elem,'^\d+(\.\d+)?$')) then concat('GBMF',$award-id-elem)          else if (not(matches(upper-case($award-id-elem),'^GBMF'))) then concat('GBMF',replace($award-id-elem,'[^\d\.]',''))          else upper-case($award-id-elem)"/>
      </xsl:when>
      <!-- Japan Science and Technology Agency -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/501100002241','https://ror.org/00097mb19')">
        <!-- JSTA grant DOIs are registered like so: GBMF0000 -->
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JPMJ[A-Z0-9]+\s*$') and not(matches(upper-case($award-id-elem),'^JPMJ[A-Z0-9]+$'))) then concat('JPMJ',upper-case(replace(substring-after($award-id-elem,'JPMJ'),'\s+$','')))         else upper-case($award-id-elem)"/>
      </xsl:when>
      <!-- James S McDonnell Foundation -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000913','https://ror.org/03dy4aq19')">
        <!-- JSMF grant DOIs are registered like so: 220020527, 2020-1543, 99-55, 91-8 -->
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JSMF2\d+$')) then substring-after($award-id-elem,'JSMF')         else replace($award-id-elem,'[^\d\-]','')"/>
      </xsl:when>
      <!-- Austrian Science Fund -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/501100002428','https://ror.org/013tf3c58')">
        <!-- ASF grant DOIs are registered in many ways: PAT8306623, EFP45, J1974, Z54 -->
        <xsl:value-of select="if (matches($award-id-elem,'\d\-')) then replace(substring-before($award-id-elem,'-'),'[^A-Z\d]','')         else replace($award-id-elem,'[^A-Z\d]','')"/>
      </xsl:when>
      <!-- American Heart Association -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000968','https://ror.org/013kjyp64')">
        <!-- ASF grant DOIs are registered in many ways: 24CDA1264317, 23SCEFIA1157994, 24POST1187422 -->
        <xsl:value-of select="if (matches($award-id-elem,'[a-z]\s+\([A-Z\d]+\)')) then substring-before(substring-after($award-id-elem,'('),')')         else $award-id-elem"/>
      </xsl:when>
      <!-- Fundação para a Ciência e a Tecnologia -->
      <xsl:when test="$funder-id=('http://dx.doi.org/10.13039/100000968','https://ror.org/013kjyp64')">
        <!-- FCT grant DOIs are registered in many ways: CEECINST/00152/2018/CP1570/CT0004, DL 57/2016/CP1381/CT0002, 2022.03592.PTDC, PTDC/MED-PAT/0959/2021 -->
        <xsl:value-of select="if (contains(upper-case($award-id-elem),'2020')) then concat('2020',replace(substring-after($award-id-elem,'2020'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2021')) then concat('2021',replace(substring-after($award-id-elem,'2021'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2022')) then concat('2022',replace(substring-after($award-id-elem,'2022'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2023')) then concat('2023',replace(substring-after($award-id-elem,'2023'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'2024')) then concat('2024',replace(substring-after($award-id-elem,'2024'),'[^A-Z0-9\.]',''))         else if (contains(upper-case($award-id-elem),'CEEC')) then concat('CEEC',replace(substring-after(upper-case($award-id-elem),'CEEC'),'[^A-Z0-9/]',''))         else if (contains(upper-case($award-id-elem),'PTDC/')) then concat('PTDC/',replace(substring-after(upper-case($award-id-elem),'PTDC/'),'[^A-Z0-9/\-]',''))         else if (contains(upper-case($award-id-elem),'DL 57/')) then concat('DL 57/',replace(substring-after(upper-case($award-id-elem),'DL 57/'),'[^A-Z0-9/\-]',''))         else $award-id-elem"/>
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
  
  <!-- returns integer for day of week 1 = Monday, 2 = Tuesday etc. -->
  <xsl:function name="e:get-weekday" as="xs:integer?">
    <xsl:param name="date" as="xs:anyAtomicType?"/>
    <xsl:sequence select="       if (empty($date)) then ()       else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7       "/>
  </xsl:function>
  
  <!-- Modification of http://www.xsltfunctions.com/xsl/functx_line-count.html -->
  <xsl:function name="e:line-count" as="xs:integer">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:sequence select="count(tokenize($arg,'(\r\n?|\n\r?)'))"/>
  </xsl:function>
 
  <!-- Taken from here https://stackoverflow.com/questions/2917655/how-do-i-check-for-the-existence-of-an-external-file-with-xsl -->
  
  
  
  
 <pattern id="research-article-pattern"><rule context="article[@article-type='research-article']" id="research-article">
	  <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
	  <let name="is-prc" value="e:is-prc(.)"/>
	  
	  <report test="if ($is-prc) then ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='referee-report'])      else ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])" role="warning" flag="dl-ar" id="test-r-article-d-letter"><value-of select="if ($is-prc) then 'Public reviews and recomendations for the authors' else 'A decision letter'"/> should almost always be present for research articles. This one doesn't have one. Check that this is correct.</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#final-test-r-article-d-letter-feat" test="$disp-channel = 'Feature Article' and not(sub-article[@article-type='decision-letter'])" role="warning" flag="dl-ar" id="final-test-r-article-d-letter-feat">A decision letter should be present for research articles. Feature template 5s almost always have a decision letter, but this one does not. Is that correct?</report>
		
	  <report test="$disp-channel != 'Scientific Correspondence' and not(sub-article[@article-type=('reply','author-comment')])" role="warning" flag="dl-ar" id="test-r-article-a-reply">Author response should usually be present for research articles, but this one does not have one. Is that correct?</report>
	  
	  <report test="count(sub-article[@article-type=('reply','author-comment')]) gt 1" role="error" flag="dl-ar" id="test-r-article-a-reply-2">There cannot be more than one author response. This article has <value-of select="count(sub-article[@article-type=('reply','author-comment')])"/>.</report>
	  
	  <report test="count(sub-article[@article-type='editor-report']) gt 1" role="error" flag="dl-ar" id="editor-report-2">There cannot be more than one eLife Assessment or Editor's evaluation. This one has <value-of select="count(sub-article[@article-type='editor-report'])"/>.</report>
	
	</rule></pattern><pattern id="research-article-sub-article-pattern"><rule context="article[@article-type='research-article' and sub-article]" id="research-article-sub-article">
     <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
     
     <report test="$disp-channel != 'Scientific Correspondence' and not(sub-article[not(@article-type=('reply','author-comment'))])" flag="dl-ar" role="error" id="r-article-sub-articles"><value-of select="$disp-channel"/> type articles cannot have only an Author response. The following combinations of peer review-material are permitted: Editor's evaluation, Decision letter, and Author response; Decision letter, and Author response; Editor's evaluation and Decision letter; Editor's evaluation and Author response; or Decision letter.</report>
     
   </rule></pattern>

  

  

  
  
  

   	
  
  <pattern id="ar-fig-tests-pattern"><rule context="fig[ancestor::sub-article[@article-type=('reply','author-comment')]]" id="ar-fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(ancestor::body//fig)"/>
      <let name="pos" value="$count - count(following::fig)"/>
      <let name="no" value="substring-after(@id,'fig')"/>
      <let name="id-based-label" value="concat('Author response image ',$no,'.')"/>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#ar-fig-test-2" test="if ($article-type = ($features-article-types,$notice-article-types)) then ()         else not(label)" role="error" flag="dl-ar" id="ar-fig-test-2">Author Response fig must have a label.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#pre-ar-fig-test-3" test="graphic" role="warning" flag="dl-ar" id="pre-ar-fig-test-3">Author Response fig does not have graphic. Ensure author query is added asking for file.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#pre-ar-fig-position-test" test="$no = string($pos)" role="warning" flag="dl-ar" id="pre-ar-fig-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR images it is placed in position <value-of select="$pos"/>.</assert>
      
      

      
    </rule></pattern><pattern id="disp-quote-tests-pattern"><rule context="disp-quote" id="disp-quote-tests">
      <let name="subj" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="ancestor::sub-article[not(@article-type=('reply','author-comment'))]" role="warning" flag="dl-ar" id="disp-quote-test-1">Content is tagged as a display quote, which is almost definitely incorrect, since it's within peer review material that is not an author response - <value-of select="."/></report>
      
      
    </rule></pattern>
  
  <pattern id="dl-video-specific-pattern"><rule context="sub-article[@article-type=('decision-letter','referee-report')]/body//media[@mimetype='video']" id="dl-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video' and ancestor::sub-article/@article-type=('decision-letter','referee-report')])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      <assert test="$no = string($pos)" role="warning" flag="dl-ar" id="pre-dl-video-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other DL videos it is placed in position <value-of select="$pos"/>.</assert>
      
      
    </rule></pattern><pattern id="ar-video-specific-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//media[@mimetype='video']" id="ar-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      <assert test="$no = string($pos)" role="warning" flag="dl-ar" id="pre-ar-video-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
      
      
    </rule></pattern>
  
  
  
  <pattern id="rep-fig-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]//fig" id="rep-fig-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-test-2" test="label" role="error" flag="dl-ar" id="resp-fig-test-2">fig must have a label.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#reply-fig-test-2" test="matches(label[1],'^Author response image [0-9]{1,3}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" role="error" flag="dl-ar" id="reply-fig-test-2">fig label in author response must be in the format 'Author response image 1.', or 'Chemical Structure 1.', or 'Scheme 1.'.</assert>
      
    </rule></pattern><pattern id="dec-fig-tests-pattern"><rule context="sub-article[@article-type='decision-letter']//fig" id="dec-fig-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#dec-fig-test-1" test="label" role="error" flag="dl-ar" id="dec-fig-test-1">fig must have a label.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#dec-fig-test-2" test="matches(label[1],'^Decision letter image [0-9]{1,3}\.$')" role="error" flag="dl-ar" id="dec-fig-test-2">fig label in author response must be in the format 'Decision letter image 1.'.</assert>
      
    </rule></pattern>
  
  
  
  <pattern id="ed-eval-title-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/title-group" id="ed-eval-title-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-title-test" test="article-title = (&quot;Editor's evaluation&quot;,'eLife assessment','eLife Assessment')" role="error" flag="dl-ar" id="ed-eval-title-test">A sub-article[@article-type='editor-report'] must have the title "eLife Assessment" or "Editor's evaluation". Currently it is <value-of select="article-title"/>.</assert>
    </rule></pattern><pattern id="dec-letter-title-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/title-group" id="dec-letter-title-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-title-test" test="article-title = 'Decision letter'" role="error" flag="dl-ar" id="dec-letter-title-test">title-group must contain article-title which contains 'Decision letter'. Currently it is <value-of select="article-title"/>.</assert>
    </rule></pattern><pattern id="reply-title-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/front-stub/title-group" id="reply-title-tests">
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-title-test" test="article-title = 'Author response'" role="error" flag="dl-ar" id="reply-title-test">title-group must contain article-title which contains 'Author response'. Currently it is <value-of select="article-title"/>.</assert>
      
    </rule></pattern>
  
  <pattern id="rep-fig-ids-pattern"><rule context="sub-article//fig[not(@specific-use='child-fig')]" id="rep-fig-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-id-test" test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')" role="error" flag="dl-ar" id="resp-fig-id-test">fig in decision letter/author response must have @id in the format respfig0, or sa0fig0. <value-of select="@id"/> does not conform to this.</assert>
    </rule></pattern><pattern id="rep-fig-sup-ids-pattern"><rule context="sub-article//fig[@specific-use='child-fig']" id="rep-fig-sup-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-sup-id-test" test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')" role="error" flag="dl-ar" id="resp-fig-sup-id-test">figure supplement in decision letter/author response must have @id in the format respfig0s0 or sa0fig0s0. <value-of select="@id"/> does not conform to this.</assert>
      
    </rule></pattern><pattern id="disp-formula-ids-pattern"><rule context="disp-formula" id="disp-formula-ids">
      
      
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#sub-disp-formula-id-test" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-disp-formula-id-test">disp-formula @id must be in the format 'sa0equ0' when in a sub-article.  <value-of select="@id"/> does not conform to this.</report>
    </rule></pattern><pattern id="mml-math-ids-pattern"><rule context="disp-formula/mml:math" id="mml-math-ids">
      
      
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#sub-mml-math-id-test" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-mml-math-id-test">mml:math @id in disp-formula must be in the format 'sa0m0'.  <value-of select="@id"/> does not conform to this.</report>
    </rule></pattern><pattern id="resp-table-wrap-ids-pattern"><rule context="sub-article//table-wrap" id="resp-table-wrap-ids">
 
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#resp-table-wrap-id-test" test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$')         else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')" role="warning" flag="dl-ar" id="resp-table-wrap-id-test">table-wrap @id in a sub-article must be in the format 'resptable0' or 'sa0table0' if it has a label, or in the format 'respinlinetable0' or 'sa0inlinetable0' if it does not.</assert>
    </rule></pattern>
  
  
  
  
  
  
  
  <pattern id="dec-letter-reply-tests-pattern"><rule context="article/sub-article" id="dec-letter-reply-tests">
      <let name="is-prc" value="e:is-prc(.)"/>
      <let name="sub-article-types" value="('editor-report','referee-report','author-comment','decision-letter','reply')"/>
      <let name="sub-article-count" value="count(parent::article/sub-article)"/>
      <let name="id-convention" value="if (@article-type='editor-report') then 'sa0'         else if (@article-type='decision-letter') then 'sa1'         else if (@article-type='reply') then 'sa2'         else if (@article-type='author-comment') then concat('sa',$sub-article-count - 1)         else concat('sa',count(preceding-sibling::sub-article))"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-1" test="@article-type=$sub-article-types" role="error" flag="dl-ar" id="dec-letter-reply-test-1">sub-article must must have an article-type which is equal to one of the following values: <value-of select="string-join($sub-article-types,'; ')"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-2" test="@id = $id-convention" role="error" flag="dl-ar" id="dec-letter-reply-test-2">sub-article id is <value-of select="@id"/> when based on it's article-type and position it should be <value-of select="$id-convention"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-3" test="count(front-stub) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-3">sub-article must contain one and only one front-stub.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-4" test="count(body) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-4">sub-article must contain one and only one body.</assert>
      
      <report test="not($is-prc) and @article-type='referee-report'" role="error" flag="dl-ar" id="sub-article-1">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'decision-letter'.</report>
      
      <report test="not($is-prc) and @article-type='author-comment'" role="error" flag="dl-ar" id="sub-article-2">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'response'.</report>
      
      <report test="$is-prc and @article-type='decision-letter'" role="error" flag="dl-ar" id="sub-article-3">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in PRC articles. Provided this is in fact a PRC article, the article-type should be 'referee-report'.</report>
      
      <report test="$is-prc and @article-type='reply'" role="error" flag="dl-ar" id="sub-article-4">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'author-comment'.</report>
      
    </rule></pattern><pattern id="dec-letter-reply-content-tests-pattern"><rule context="article/sub-article//p" id="dec-letter-reply-content-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-5" test="matches(.,'&lt;[/]?[Aa]uthor response')" role="error" flag="dl-ar" id="dec-letter-reply-test-5"><value-of select="ancestor::sub-article/@article-type"/> paragraph contains what looks like pseudo-code - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-6" test="matches(.,'&lt;\p{Zs}?/?\p{Zs}?[a-z]*\p{Zs}?/?\p{Zs}?&gt;')" role="warning" flag="dl-ar" id="dec-letter-reply-test-6"><value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be pseudo-code or tags which should likely be removed - <value-of select="."/>.</report>
    </rule></pattern><pattern id="dec-letter-reply-content-tests-2-pattern"><rule context="article/sub-article//p[not(ancestor::disp-quote)]" id="dec-letter-reply-content-tests-2">
      <let name="regex" value="'\p{Zs}([Oo]ffensive|[Oo]ffended|[Uu]nproff?essional|[Rr]ude|[Cc]onflict\p{Zs}[Oo]f\p{Zs}[Ii]nterest|([Aa]re|[Aa]m)\p{Zs}[Ss]hocked|[Ss]trongly\p{Zs}[Dd]isagree)[^\p{L}]'"/>
      
      <!-- Need to improve messaging -->
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-7" test="matches(.,$regex)" role="warning" flag="dl-ar" id="dec-letter-reply-test-7"><value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be inflammatory or offensive language. eLife: please check it to see if it is language that should be removed. This paragraph was flagged because of the phrase(s) <value-of select="string-join(tokenize(.,'\p{Zs}')[matches(.,concat('^',substring-before(substring-after($regex,'\p{Zs}'),'[^\p{L}]')))],'; ')"/> in <value-of select="."/>.</report>
    </rule></pattern><pattern id="ed-eval-front-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub" id="ed-eval-front-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="ed-eval-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-2" test="count(contrib-group) = 1" role="error" flag="dl-ar" id="ed-eval-front-test-2">editor report front-stub must contain 1 (and only 1) contrib-group element. This one has <value-of select="count(contrib-group)"/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-3" test="count(related-object) gt 1" role="error" flag="dl-ar" id="ed-eval-front-test-3">editor report front-stub must contain 1 or 0 related-object elements. This one has <value-of select="count(related-object)"/>.</report>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-4" test="e:is-prc(.) and not($article-type='review-article') and not(kwd-group[@kwd-group-type='evidence-strength'])" role="error" flag="dl-ar" id="ed-eval-front-test-4">eLife Assessment front-stub does not contain a strength term keyword group, which must be incorrect.</report>
      
      <report test="e:is-prc(.) and $article-type='review-article' and kwd-group[@kwd-group-type='evidence-strength']" role="error" flag="dl-ar" id="ed-eval-front-test-4b">eLife Assessment front-stub contains a strength term keyword group, but this is a PRC Review article (which don't use the terms), so this must be incorrect.</report>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-5" test="e:is-prc(.) and not($article-type='review-article') and not(kwd-group[@kwd-group-type='claim-importance'])" role="warning" flag="dl-ar" id="ed-eval-front-test-5">eLife Assessment front-stub does not contain a significance term keyword group, which is very unusual. Is that correct?</report>
      
      <report test="e:is-prc(.) and $article-type='review-article' and kwd-group[@kwd-group-type='claim-importance']" role="error" flag="dl-ar" id="ed-eval-front-test-5b">eLife Assessment front-stub contains a significance term keyword group, but this is a PRC Review article (which don't use the terms), so this must be incorrect.</report>
    </rule></pattern><pattern id="ed-eval-front-child-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/*" id="ed-eval-front-child-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-child-test-1" test="name()=('article-id','title-group','contrib-group','kwd-group','related-object')" role="error" flag="dl-ar" id="ed-eval-front-child-test-1"><name/> element is not allowed in the front-stub for an editor report. Only the following elements are permitted: article-id, title-group, contrib-group, kwd-group, related-object.</assert>
    </rule></pattern><pattern id="ed-eval-contrib-group-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/contrib-group" id="ed-eval-contrib-group-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-contrib-group-test-1" test="count(contrib[@contrib-type='author']) = 1" role="error" flag="dl-ar" id="ed-eval-contrib-group-test-1">editor report contrib-group must contain 1 contrib[@contrib-type='author'].</assert>
    </rule></pattern><pattern id="ed-eval-author-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/contrib-group/contrib[@contrib-type='author' and name]" id="ed-eval-author-tests">
      <let name="rev-ed-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section'][1]/contrib[@contrib-type='editor'][1]/name[1])"/>
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-author-test-1" test="$name = $rev-ed-name" role="error" flag="dl-ar" id="ed-eval-author-test-1">The author of the editor report must be the same as the Reviewing editor for the article. The Reviewing editor is <value-of select="$rev-ed-name"/>, but the editor evaluation author is <value-of select="$name"/>.</assert>
    </rule></pattern><pattern id="ed-eval-rel-obj-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/related-object" id="ed-eval-rel-obj-tests">
      <let name="event-preprint-doi" value="for $x in ancestor::article//article-meta/pub-history/event[1]/self-uri[@content-type='preprint'][1]/@xlink:href                                         return substring-after($x,'.org/')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-1" test="matches(@id,'^sa0ro\d$')" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-1">related-object in editor's evaluation must have an id in the format sa0ro1. <value-of select="@id"/> does not meet this convention.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-2" test="@object-id-type='id'" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-2">related-object in editor's evaluation must have an object-id-type="id" attribute.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-3" test="@link-type='continued-by'" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-3">related-object in editor's evaluation must have a link-type="continued-by" attribute.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-4" test="matches(@object-id,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-4">related-object in editor's evaluation must have an object-id attribute which is a doi. '<value-of select="@object-id"/>' is not a valid doi.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-5" test="@object-id = $event-preprint-doi" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-5">related-object in editor's evaluation must have an object-id attribute whose value is the same as the preprint doi in the article's pub-history. object-id '<value-of select="@object-id"/>' is not the same as the preprint doi in the event history, '<value-of select="$event-preprint-doi"/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-6" test="@xlink:href = (         concat('https://sciety.org/articles/activity/',@object-id),         concat('https://sciety.org/articles/',@object-id)         )" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-6">related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the object-id attribute value (which must be a doi). '<value-of select="@xlink:href"/>' is not equal to <value-of select="concat('https://sciety.org/articles/activity/',@object-id)"/>. Which is correct?</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-7" test="@xlink:href = (         concat('https://sciety.org/articles/activity/',$event-preprint-doi),         concat('https://sciety.org/articles/',$event-preprint-doi)         )" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-7">related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the preprint doi in the article's pub-history. xlink:href '<value-of select="@xlink:href"/>' is not the same as '<value-of select="concat('https://sciety.org/articles/activity/',$event-preprint-doi)"/>'. Which is correct?</assert>
      
    </rule></pattern><pattern id="ed-report-kwd-group-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group" id="ed-report-kwd-group">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-1" test="@kwd-group-type=('claim-importance','evidence-strength')" role="error" flag="dl-ar" id="ed-report-kwd-group-1">kwd-group in <value-of select="parent::*/title-group/article-title"/> must have the attribute kwd-group-type with the value 'claim-importance' or 'evidence-strength'. This one does not.</assert>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-3" test="@kwd-group-type='claim-importance' and count(kwd) gt 1" role="error" flag="dl-ar" id="ed-report-kwd-group-3"><value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is not permitted, please check which single importance keyword should be used.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-2" test="@kwd-group-type='evidence-strength' and count(kwd) = 2" role="warning" flag="dl-ar" id="ed-report-kwd-group-2"><value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. Please check this is correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-4" test="@kwd-group-type='evidence-strength' and count(kwd) gt 2" role="error" flag="dl-ar" id="ed-report-kwd-group-4"><value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is incorrect.</report>
      
    </rule></pattern><pattern id="ed-report-claim-kwds-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='claim-importance']/kwd" id="ed-report-claim-kwds">
      <let name="allowed-vals" value="('Landmark', 'Fundamental', 'Important', 'Valuable', 'Useful')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-claim-kwd-1" test=".=$allowed-vals" role="error" flag="dl-ar" id="ed-report-claim-kwd-1">Keyword contains <value-of select="."/>, but it is in a 'claim-importance' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/></assert>
      
    </rule></pattern><pattern id="ed-report-evidence-kwds-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='evidence-strength']/kwd" id="ed-report-evidence-kwds">
      <let name="wos-go-vals" value="('Exceptional', 'Compelling', 'Convincing', 'Solid')"/>
      <let name="wos-no-go-vals" value="('Incomplete', 'Inadequate')"/>
      <let name="allowed-vals" value="($wos-go-vals,$wos-no-go-vals)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-evidence-kwd-1" test=".=$allowed-vals" role="error" flag="dl-ar" id="ed-report-evidence-kwd-1">Keyword contains <value-of select="."/>, but it is in an 'evidence-strength' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/></assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-evidence-kwd-2" test=".=$wos-no-go-vals and parent::*/kwd[.=$wos-go-vals]" role="warning" flag="dl-ar" id="ed-report-evidence-kwd-2">There is both an <value-of select="."/> and <value-of select="string-join(parent::*/kwd[.=$wos-go-vals],'; ')"/> kwd in the kwd-group for strength of evidence. Should <value-of select="."/> be unbolded or changed to a different word in the Assessment and removed as a keyword?</report>
    </rule></pattern><pattern id="ed-report-kwds-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group/kwd" id="ed-report-kwds">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-1" test="preceding-sibling::kwd = ." role="error" flag="dl-ar" id="ed-report-kwd-1">Keyword contains <value-of select="."/>, there is another kwd with that value witin the same kwd-group, so this one is either incorrect or superfluous and should be deleted.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-2" test="some $x in ancestor::sub-article[1]/body/p//bold satisfies contains(lower-case($x),lower-case(.))" role="error" flag="dl-ar" id="ed-report-kwd-2">Keyword contains <value-of select="."/>, but this term is not bolded in the text of the <value-of select="ancestor::front-stub/title-group/article-title"/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-3" test="*" role="error" flag="dl-ar" id="ed-report-kwd-3">Keywords in <value-of select="ancestor::front-stub/title-group/article-title"/> cannot contain elements, only text. This one has: <value-of select="string-join(distinct-values(*/name()),'; ')"/>.</report>
      
    </rule></pattern><pattern id="dec-letter-front-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub" id="dec-letter-front-tests">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="dec-letter-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-2" test="$count gt 0" role="error" flag="dl-ar" id="dec-letter-front-test-2">decision letter front-stub must contain at least 1 contrib-group element.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-3" test="$count gt 2" role="error" flag="dl-ar" id="dec-letter-front-test-3">decision letter front-stub contains more than 2 contrib-group elements.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-4" test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'(All|The) reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/|doi.org/10.24072/pci.evolbiol')])" role="warning" flag="dl-ar" id="dec-letter-front-test-4">decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviewing editor) anonymous? The text 'The reviewers have opted to remain anonymous' or 'The reviewer has opted to remain anonymous' is not present and there is no link to Review commons or a Peer Community in Evolutionary Biology doi in the decision letter.</report>
    </rule></pattern><pattern id="dec-letter-editor-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]" id="dec-letter-editor-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-editor-test-1" test="count(contrib[@contrib-type='editor']) = 1" role="warning" flag="dl-ar" id="dec-letter-editor-test-1">First contrib-group in decision letter must contain 1 and only 1 editor (contrib[@contrib-type='editor']).</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-editor-test-2" test="contrib[not(@contrib-type) or @contrib-type!='editor']" role="warning" flag="dl-ar" id="dec-letter-editor-test-2">First contrib-group in decision letter contains a contrib which is not marked up as an editor (contrib[@contrib-type='editor']).</report>
    </rule></pattern><pattern id="dec-letter-editor-tests-2-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]/contrib[@contrib-type='editor']" id="dec-letter-editor-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role[1]"/>
      <!--<let name="top-role" value="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[e:get-name(name[1])=$name]/role"/>-->
      <!--<let name="top-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[role=$role]/name[1])"/>-->
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-editor-test-3" test="$role=('Reviewing Editor','Senior and Reviewing Editor')" role="error" flag="dl-ar" id="dec-letter-editor-test-3">Editor in decision letter front-stub must have the role 'Reviewing Editor' or 'Senior and Reviewing Editor'. <value-of select="$name"/> has '<value-of select="$role"/>'.</assert>
      
      <!--<report test="($top-name!='') and ($top-name!=$name)"
        role="error"
        id="dec-letter-editor-test-5">In decision letter <value-of select="$name"/> is a <value-of select="$role"/>, but in the top-level article details <value-of select="$top-name"/> is the <value-of select="$role"/>.</report>-->
    </rule></pattern><pattern id="dec-letter-reviewer-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]" id="dec-letter-reviewer-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-1" test="count(contrib[@contrib-type='reviewer']) gt 0" role="error" flag="dl-ar" id="dec-letter-reviewer-test-1">Second contrib-group in decision letter must contain a reviewer (contrib[@contrib-type='reviewer']).</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-2" test="contrib[not(@contrib-type) or @contrib-type!='reviewer']" role="error" flag="dl-ar" id="dec-letter-reviewer-test-2">Second contrib-group in decision letter contains a contrib which is not marked up as a reviewer (contrib[@contrib-type='reviewer']).</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-6" test="count(contrib[@contrib-type='reviewer']) gt 5" role="warning" flag="dl-ar" id="dec-letter-reviewer-test-6">Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</report>
    </rule></pattern><pattern id="dec-letter-reviewer-tests-2-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]/contrib[@contrib-type='reviewer']" id="dec-letter-reviewer-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-3" test="role='Reviewer'" role="error" flag="dl-ar" id="dec-letter-reviewer-test-3">Reviewer in decision letter front-stub must have the role 'Reviewer'. <value-of select="$name"/> has '<value-of select="role"/>'.</assert>
    </rule></pattern><pattern id="dec-letter-body-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/body" id="dec-letter-body-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-body-test-1" test="child::*[1]/local-name() = 'boxed-text'" role="error" flag="dl-ar" id="dec-letter-body-test-1">First child element in decision letter is not boxed-text. This is certainly incorrect.</assert>
    </rule></pattern><pattern id="dec-letter-body-p-tests-pattern"><rule context="sub-article[@article-type=('decision-letter','referee-report')]/body//p" id="dec-letter-body-p-tests">  
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-body-test-2" test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])" role="error" flag="dl-ar" id="dec-letter-body-test-2">The text 'Review Commons' in '<value-of select="."/>' must contain an embedded link pointing to https://www.reviewcommons.org/.</report>
      
      <report see="https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-body-test-3" test="contains(lower-case(.),'reviewed and recommended by peer community in evolutionary biology') and not(child::ext-link[matches(@xlink:href,'doi.org/10.24072/pci.evolbiol')])" role="error" flag="dl-ar" id="dec-letter-body-test-3">The decision letter indicates that this article was reviewed by PCI evol bio, but there is no doi link with the prefix '10.24072/pci.evolbiol' which must be incorrect.</report>
    </rule></pattern><pattern id="dec-letter-box-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/body/boxed-text[1]" id="dec-letter-box-tests">  
      <let name="permitted-text-1" value="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below.$'"/>
      <let name="permitted-text-2" value="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below. We also include an acceptance summary that explains what the editors found interesting or important about the work.$'"/>
      <let name="permitted-text-3" value="'^In the interests of transparency, eLife publishes the most substantive revision requests and the accompanying author responses.$'"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-box-test-1" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2,'|',$permitted-text-3))" role="warning" flag="dl-ar" id="dec-letter-box-test-1">The text at the top of the decision letter is not correct - '<value-of select="."/>'. It has to be one of the three paragraphs which are permitted (see the GitBook page for these paragraphs).</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-box-test-2" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[contains(@xlink:href,'sciety.org/') and .='public reviews'])" role="error" flag="dl-ar" id="dec-letter-box-test-2">At the top of the decision letter, the text 'public reviews' must contain an embedded link to Sciety where the public review for this article's preprint is located.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-box-test-3" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[.='the preprint'])" role="error" flag="dl-ar" id="dec-letter-box-test-3">At the top of the decision letter, the text 'the preprint' must contain an embedded link to this article's preprint.</report>
    </rule></pattern><pattern id="decision-missing-table-tests-pattern"><rule context="sub-article[@article-type='decision-letter']" id="decision-missing-table-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#decision-missing-table-test" test="contains(.,'letter table') and not(descendant::table-wrap[label])" role="warning" flag="dl-ar" id="decision-missing-table-test">A decision letter table is referred to in the text, but there is no table in the decision letter with a label.</report>
    </rule></pattern><pattern id="reply-front-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/front-stub" id="reply-front-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="reply-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
    </rule></pattern><pattern id="reply-body-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body" id="reply-body-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-body-test-1" test="count(disp-quote[@content-type='editor-comment']) = 0" role="warning" flag="dl-ar" id="reply-body-test-1">author response doesn't contain a disp-quote. This is very likely to be incorrect. Please check the original file.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-body-test-2" test="count(p) = 0" role="error" flag="dl-ar" id="reply-body-test-2">author response doesn't contain a p. This has to be incorrect.</report>
    </rule></pattern><pattern id="reply-disp-quote-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//disp-quote" id="reply-disp-quote-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-disp-quote-test-1" test="@content-type='editor-comment'" role="warning" flag="dl-ar" id="reply-disp-quote-test-1">disp-quote in author reply does not have @content-type='editor-comment'. This is almost certainly incorrect.</assert>
    </rule></pattern><pattern id="reply-missing-disp-quote-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//p[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests">
      <let name="free-text" value="replace(         normalize-space(string-join(for $x in self::*/text() return $x,''))         ,' ','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-missing-disp-quote-test-1" test="(count(*)=1) and (child::italic) and ($free-text='')" role="warning" flag="dl-ar" id="reply-missing-disp-quote-test-1">para in author response is entirely in italics, but not in a display quote. Is this a quote which has been processed incorrectly?</report>
    </rule></pattern><pattern id="reply-missing-disp-quote-tests-2-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]//italic[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests-2">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-missing-disp-quote-test-2" test="string-length(.) ge 50" role="warning" flag="dl-ar" id="reply-missing-disp-quote-test-2">A long piece of text is in italics in an Author response paragraph. Should it be captured as a display quote in a separate paragraph? '<value-of select="."/>' in '<value-of select="ancestor::*[local-name()='p'][1]"/>'</report>
    </rule></pattern><pattern id="reply-missing-table-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]" id="reply-missing-table-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-missing-table-test" test="contains(.,'response table') and not(descendant::table-wrap[label])" role="warning" flag="dl-ar" id="reply-missing-table-test">An author response table is referred to in the text, but there is no table in the response with a label.</report>
    </rule></pattern><pattern id="sub-article-ext-link-tests-pattern"><rule context="sub-article//ext-link" id="sub-article-ext-link-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#paper-pile-test" test="contains(@xlink:href,'paperpile.com')" role="error" flag="dl-ar" id="paper-pile-test">In the <value-of select="if (ancestor::sub-article[@article-type='reply']) then 'author response' else 'decision letter'"/> the text '<value-of select="."/>' has an embedded hyperlink to <value-of select="@xlink:href"/>. The hyperlink should be removed (but the text retained).</report>
    </rule></pattern><pattern id="sub-article-ref-p-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body/*[last()][name()='p']" id="sub-article-ref-p-tests">
      
      <report see="https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#sub-article-ref-p-test" test="count(tokenize(lower-case(.),'doi\p{Zs}?:')) gt 2" role="warning" flag="dl-ar" id="sub-article-ref-p-test">The last paragraph of the author response looks like it contains various references. Should each reference be split out into its own paragraph? <value-of select="."/></report>
    </rule></pattern><pattern id="sub-article-dl-image-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/body//bold" id="sub-article-dl-image-tests">
      
      <report test="matches(.,'[Dd]ecision letter image \d')" role="error" flag="dl-ar" id="sub-article-dl-image-1">Decision letter contains bold text that mentions an image: <value-of select="."/>. This should be changed to a citation (and if the decision letter image is missing, then it should be added).</report>
      
      <report test="matches(.,'[Dd]ecision letter table \d')" role="error" flag="dl-ar" id="sub-article-dl-image-2">Decision letter contains bold text that mentions an table: <value-of select="."/>. This should be changed to a citation (and if the decision letter table is missing, then it should be added).</report>
    </rule></pattern><pattern id="sub-article-pr-image-tests-pattern"><rule context="sub-article[@article-type='referee-report']/body//bold" id="sub-article-pr-image-tests">
      
      <report test="matches(.,'[Rr]eview image \d')" role="error" flag="dl-ar" id="sub-article-pr-image-1">Public review contains bold text that mentions an image: <value-of select="."/>. This should be changed to a citation (and if the review image is missing, then it should be added).</report>
      
      <report test="matches(.,'[Rr]eview table \d')" role="error" flag="dl-ar" id="sub-article-pr-image-2">Public review contains bold text that mentions an table: <value-of select="."/>. This should be changed to a citation (and if the review table is missing, then it should be added).</report>
    </rule></pattern><pattern id="sub-article-ar-image-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//bold" id="sub-article-ar-image-tests">
      
      <report test="matches(.,'[Aa]uthor response image \d')" role="error" flag="dl-ar" id="sub-article-ar-image-1">Author response contains bold text that mentions an image: <value-of select="."/>. This should be changed to a citation (and if the author response image is missing, then it should be added).</report>
      
      <report test="matches(.,'[Aa]uthor response table \d')" role="error" flag="dl-ar" id="sub-article-ar-image-2">Author response contains bold text that mentions an table: <value-of select="."/>. This should be changed to a citation (and if the author response table is missing, then it should be added).</report>
    </rule></pattern><pattern id="sub-article-gen-image-tests-pattern"><rule context="sub-article/body//bold[not(matches(.,'[Dd]ecision letter (image|table) \d|[Rr]eview (image|table) \d|[Aa]uthor response (image|table) \d'))]" id="sub-article-gen-image-tests">
      
      <report test="matches(.,'image \d')" role="error" flag="dl-ar" id="sub-article-gen-image-1"><value-of select="ancestor::sub-article/front-stub//article-title"/> contains bold text that mentions an image: <value-of select="."/>. Is there a missing image?</report>
      
      <report test="matches(.,'table \d')" role="error" flag="dl-ar" id="sub-article-gen-image-2"><value-of select="ancestor::sub-article/front-stub//article-title"/> contains bold text that mentions a table: <value-of select="."/>. Is there a missing table?</report>
    </rule></pattern>
  
  <pattern id="ref-report-front-pattern"><rule context="sub-article[@article-type='referee-report']/front-stub" id="ref-report-front">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="ref-report-front-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert test="$count = 1" role="error" flag="dl-ar" id="ref-report-front-2">sub-article front-stub must contain one, and only one contrib-group elements.</assert>
    </rule></pattern><pattern id="sub-article-contrib-tests-pattern"><rule context="sub-article[@article-type=('editor-report','referee-report','author-comment')]/front-stub/contrib-group/contrib" id="sub-article-contrib-tests">
      
      <assert test="@contrib-type='author'" role="error" flag="dl-ar" id="sub-article-contrib-test-1">contrib inside sub-article with article-type '<value-of select="ancestor::sub-article/@article-type"/>' must have the attribute contrib-type='author'.</assert>
      
      <assert test="name or anonymous or collab" role="error" flag="dl-ar" id="sub-article-contrib-test-2">sub-article contrib must have either a child name or a child anonymous element.</assert>
      
      <report test="(name and anonymous) or (collab and anonymous) or (name and collab)" role="error" flag="dl-ar" id="sub-article-contrib-test-3">sub-article contrib can only have a child name element or a child anonymous element or a child collab element (with descendant group members as required), it cannot have more than one of these elements. This has <value-of select="string-join(for $x in *[name()=('name','anonymous','collab')] return concat('a ',$x/name()),' and ')"/>.</report>
      
      <assert test="role" role="error" flag="dl-ar" id="sub-article-contrib-test-4">contrib inside sub-article with article-type '<value-of select="ancestor::sub-article/@article-type"/>' must have a child role element.</assert>
      
    </rule></pattern><pattern id="sub-article-role-tests-pattern"><rule context="sub-article/front-stub/contrib-group/contrib/role" id="sub-article-role-tests">
      <let name="sub-article-type" value="ancestor::sub-article[1]/@article-type"/>
      <let name="sub-title" value="ancestor::sub-article[1]/front-stub[1]/title-group[1]/article-title[1]"/>
      
      <report test="lower-case($sub-title)='recommendations for authors' and not(parent::contrib/preceding-sibling::contrib) and not(@specific-use='editor')" role="error" flag="dl-ar" id="sub-article-role-test-1">The role element for the first contributor in <value-of select="$sub-title"/> must have the attribute specific-use='editor'.</report>
      
      <report test="$sub-article-type='referee-report' and (lower-case($sub-title)!='recommendations for authors' or parent::contrib/preceding-sibling::contrib) and not(@specific-use='referee')" role="error" flag="dl-ar" id="sub-article-role-test-2">The role element for this contributor must have the attribute specific-use='referee'.</report>
      
      <report test="$sub-article-type='author-comment' and not(@specific-use='author')" role="error" flag="dl-ar" id="sub-article-role-test-3">The role element for contributors in the author response must have the attribute specific-use='author'.</report>
      
      <report test="@specific-use='author' and .!='Author'" role="error" flag="dl-ar" id="sub-article-role-test-4">A role element with the attribute specific-use='author' must contain the text 'Author'. This one has '<value-of select="."/>'.</report>
      
      <report test="@specific-use='editor' and not(.=('Senior and Reviewing Editor','Reviewing Editor'))" role="error" flag="dl-ar" id="sub-article-role-test-5">A role element with the attribute specific-use='editor' must contain the text 'Senior and Reviewing Editor' or 'Reviewing Editor'. This one has '<value-of select="."/>'.</report>
      
      <report test="@specific-use='referee' and .!='Reviewer'" role="error" flag="dl-ar" id="sub-article-role-test-6">A role element with the attribute specific-use='referee' must contain the text 'Reviewer'. This one has '<value-of select="."/>'.</report>
      
    </rule></pattern><pattern id="ref-report-editor-tests-pattern"><rule context="sub-article[@article-type='referee-report']/front-stub[lower-case(title-group[1]/article-title[1])='recommendations for authors']" id="ref-report-editor-tests">
      
      <assert test="count(descendant::contrib[role[@specific-use='editor']]) = 1" role="error" flag="dl-ar" id="ref-report-editor-1">The Recommendations for authors must contain 1 and only 1 editor (a contrib with a role[@specific-use='editor']). This one has <value-of select="count(descendant::contrib[role[@specific-use='editor']])"/>.</assert>
      
      <assert test="count(descendant::contrib[role[@specific-use='referee']]) &gt; 0" role="error" flag="dl-ar" id="ref-report-reviewer-1">The Recommendations for authors must contain 1 or more reviewers (a contrib with a role[@specific-use='referee']). This one has 0.</assert>
    </rule></pattern><pattern id="ref-report-reviewer-tests-pattern"><rule context="sub-article[@article-type='referee-report' and contains(lower-case(front-stub[1]/title-group[1]/article-title[1]),'public review')]/front-stub" id="ref-report-reviewer-tests">
      
      <assert test="count(descendant::contrib[role[@specific-use='referee']])=1" role="error" flag="dl-ar" id="ref-report-reviewer-test-1">A public review must contain a single contributor which is a reviewer (a contrib with a child role[@specific-use='referee']). This one contains <value-of select="count(descendant::contrib[role[@specific-use='referee']])"/>.</assert>
      
      <report test="descendant::contrib[not(role[@specific-use='referee'])]" role="error" flag="dl-ar" id="ref-report-reviewer-test-2">A public review cannot contain a contributor which is not a reviewer (i.e. a contrib without a child role[@specific-use='referee']).</report>
    </rule></pattern>
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 <pattern id="feature-template-tests-pattern"><rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]" id="feature-template-tests">
     <let name="template" value="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
     <let name="type" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-1" test="($template = ('1','2','3')) and child::sub-article" role="error" flag="dl-ar" id="feature-template-test-1"><value-of select="$type"/> is a template <value-of select="$template"/> but it has a decision letter or author response, which cannot be correct, as only template 5s are allowed these.</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-2" test="($template = '5') and not(@article-type='research-article')" role="error" flag="dl-ar" id="feature-template-test-2"><value-of select="$type"/> is a template <value-of select="$template"/> so the article element must have a @article-type="research-article". Instead the @article-type="<value-of select="@article-type"/>".</report>
     
     
     
     
     
     
     
     
     
     
     
     
     
     
   </rule></pattern>
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
</schema>