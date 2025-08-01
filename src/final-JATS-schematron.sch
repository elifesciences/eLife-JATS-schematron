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
  <let name="wellcome-fundref-ids" value="('http://dx.doi.org/10.13039/100010269','http://dx.doi.org/10.13039/100004440')"/>
  <let name="known-grant-funder-fundref-ids" value="('http://dx.doi.org/10.13039/100000936','http://dx.doi.org/10.13039/501100002241','http://dx.doi.org/10.13039/100000913','http://dx.doi.org/10.13039/501100002428','http://dx.doi.org/10.13039/100000968')"/>
  <let name="grant-doi-exception-funder-ids" value="($wellcome-fundref-ids,$known-grant-funder-fundref-ids)"/>  

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
  
  <!-- included for legacy reasons. This can be removed after migrating to new vendor platform -->
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
  
  <!-- invoked in e:ref-list-string -->
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
    <xsl:variable name="object-no" select="replace($object-id,'[^0-9]','')"/>
    <xsl:element name="matches">
      <xsl:for-each select="$article//xref[(@ref-type=$object-type) and not(ancestor::caption)]">
        <xsl:variable name="rid-no" select="replace(./@rid,'[^0-9]','')"/>
        <xsl:variable name="text-no" select="tokenize(normalize-space(replace(.,'[^0-9]',' ')),'\p{Zs}')[last()]"/>
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
          <xsl:when test="($rid-no lt $object-no) and contains(.,$object-no) and (contains(.,'Videos') or contains(.,'videos') and contains(.,'–'))">
            <xsl:element name="match">
              <xsl:attribute name="sec-id">
                <xsl:value-of select="./ancestor::sec[1]/@id"/>
              </xsl:attribute>
              <xsl:value-of select="self::*"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="($rid-no lt $object-no) and (contains(.,'Videos') or contains(.,'videos') and contains(.,'—')) and ($text-no gt $object-no)">
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

  <!-- Funders may have internal grant DOIs or indistinct conventions for award IDs
            this function is an attempt to account for this to better match award ids with grant DOIs -->
   <xsl:function name="e:alter-award-id">
    <xsl:param name="award-id-elem" as="xs:string"/>
    <xsl:param name="fundref-id" as="xs:string"/>
    <xsl:choose>
      <!-- GBMF -->
      <xsl:when test="$fundref-id='http://dx.doi.org/10.13039/100000936'">
        <!-- GBMF grant DOIs are registered like so: GBMF0000 -->
        <xsl:value-of select="if (matches($award-id-elem,'^\d+(\.\d+)?$')) then concat('GBMF',$award-id-elem)          else if (not(matches(upper-case($award-id-elem),'^GBMF'))) then concat('GBMF',replace($award-id-elem,'[^\d\.]',''))          else upper-case($award-id-elem)"/>
      </xsl:when>
      <!-- Japan Science and Technology Agency -->
      <xsl:when test="$fundref-id='http://dx.doi.org/10.13039/501100002241'">
        <!-- JSTA grant DOIs are registered like so: GBMF0000 -->
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JPMJ[A-Z0-9]+\s*$') and not(matches(upper-case($award-id-elem),'^JPMJ[A-Z0-9]+$'))) then concat('JPMJ',upper-case(replace(substring-after($award-id-elem,'JPMJ'),'\s+$','')))         else upper-case($award-id-elem)"/>
      </xsl:when>
      <!-- James S McDonnell Foundation -->
      <xsl:when test="$fundref-id='http://dx.doi.org/10.13039/100000913'">
        <!-- JSMF grant DOIs are registered like so: 220020527, 2020-1543, 99-55, 91-8 -->
        <xsl:value-of select="if (matches(upper-case($award-id-elem),'JSMF2\d+$')) then substring-after($award-id-elem,'JSMF')         else replace($award-id-elem,'[^\d\-]','')"/>
      </xsl:when>
      <!-- Austrian Science Fund -->
      <xsl:when test="$fundref-id='http://dx.doi.org/10.13039/501100002428'">
        <!-- ASF grant DOIs are registered in many ways: PAT8306623, EFP45, J1974, Z54 -->
        <xsl:value-of select="if (matches($award-id-elem,'\d\-')) then replace(substring-before($award-id-elem,'-'),'[^A-Z\d]','')         else replace($award-id-elem,'[^A-Z\d]','')"/>
      </xsl:when>
      <!-- American Heart Association -->
      <xsl:when test="$fundref-id='http://dx.doi.org/10.13039/100000968'">
        <!-- ASF grant DOIs are registered in many ways: 24CDA1264317, 23SCEFIA1157994, 24POST1187422 -->
        <xsl:value-of select="if (matches($award-id-elem,'[a-z]\s+\([A-Z\d]+\)')) then substring-before(substring-after($award-id-elem,'('),')')         else $award-id-elem"/>
      </xsl:when>
      <!-- Fundação para a Ciência e a Tecnologia -->
      <xsl:when test="$fundref-id='http://dx.doi.org/10.13039/100000968'">
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
      <xsl:when test="$fundref-id=('http://dx.doi.org/10.13039/100010663','http://dx.doi.org/10.13039/100010665','http://dx.doi.org/10.13039/100010669','http://dx.doi.org/10.13039/100010675','http://dx.doi.org/10.13039/100010677','http://dx.doi.org/10.13039/100010679','http://dx.doi.org/10.13039/100010680','http://dx.doi.org/10.13039/100018694','http://dx.doi.org/10.13039/100019180')">
        <!-- ERC grant DOIs are registered as numbers: 694640, 101002163 -->
        <xsl:value-of select="if (matches($award-id-elem,'[a-z]\s+\(\d+\)')) then substring-before(substring-after($award-id-elem,'('),')')         else if (matches($award-id-elem,'\d{6,9}')) then replace($award-id-elem,'[^\d]','')         else $award-id-elem"/>
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
  
  
  <pattern id="covid-prologue-pattern"><rule context="article[front/article-meta//article-title[matches(lower-case(.),'sars-cov-2|covid-19|coronavirus')]]" id="covid-prologue">
      
      <assert test="preceding::processing-instruction('covid-19-tdm')" role="warning" id="covid-processing-instruction">[covid-processing-instruction] The article title (<value-of select="front/article-meta//article-title"/>) suggests that this article should probably have the covid processing instruction - '&lt;?covid-19-tdm?&gt;' - but it does not. Should it?</assert>
      
    </rule></pattern>
  
 <pattern id="article-tests-pattern"><rule context="article" id="article-tests">
      <let name="line-count" value="e:line-count(.)"/>
      
	  <report test="@dtd-version" role="info" id="dtd-info">[dtd-info] DTD version is <value-of select="@dtd-version"/></report>
	  
	  <assert test="@article-type = $allowed-article-types" role="error" id="test-article-type">[test-article-type] article-type must be equal to 'article-commentary', 'correction', 'discussion', 'editorial', or 'research-article'. Currently it is <value-of select="@article-type"/></assert>
		
	  <assert test="count(front) = 1" role="error" id="test-article-front">[test-article-front] Article must have one child front. Currently there are <value-of select="count(front)"/></assert>
		
	  <assert test="count(body) = 1" role="error" id="test-article-body">[test-article-body] Article must have one child body. Currently there are <value-of select="count(body)"/></assert>
      
    <report test="(@article-type = ('article-commentary','discussion','editorial','research-article','review-article')) and count(back) != 1" role="error" id="test-article-back">[test-article-back] Article must have one child back. Currently there are <value-of select="count(back)"/></report>
		
      <report see="https://elifeproduction.slab.com/posts/code-blocks-947pcamv#line-count" test="not(descendant::code) and ($line-count gt 1)" role="error" id="line-count">[line-count] Articles without code blocks must only have one line in the xml. The xml for this article has <value-of select="$line-count"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#h3q4a-retraction-info" test="@article-type='retraction'" role="info" id="retraction-info">[retraction-info] Ensure that the PDF for the article which is being retracted (<value-of select="string-join(descendant::article-meta/related-article[@related-article-type='retracted-article']/@xlink:href,'; ')"/>) is also updated with a header saying it's been retracted.</report>
      
      <report test="@article-type!='research-article' and sub-article" role="error" id="non-r-article-sub-article">[non-r-article-sub-article] <value-of select="@article-type"/> type articles cannot have sub-articles (peer review materials).</report>
 	</rule></pattern><pattern id="research-article-pattern"><rule context="article[@article-type='research-article']" id="research-article">
	  <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
	  <let name="is-prc" value="e:is-prc(.)"/>
	  
	  <report test="if ($is-prc) then ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='referee-report'])      else ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])" role="warning" flag="dl-ar" id="test-r-article-d-letter">[test-r-article-d-letter] <value-of select="if ($is-prc) then 'Public reviews and recomendations for the authors' else 'A decision letter'"/> should almost always be present for research articles. This one doesn't have one. Check that this is correct.</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#final-test-r-article-d-letter-feat" test="$disp-channel = 'Feature Article' and not(sub-article[@article-type='decision-letter'])" role="warning" flag="dl-ar" id="final-test-r-article-d-letter-feat">[final-test-r-article-d-letter-feat] A decision letter should be present for research articles. Feature template 5s almost always have a decision letter, but this one does not. Is that correct?</report>
		
	  <report test="$disp-channel != 'Scientific Correspondence' and not(sub-article[@article-type=('reply','author-comment')])" role="warning" flag="dl-ar" id="test-r-article-a-reply">[test-r-article-a-reply] Author response should usually be present for research articles, but this one does not have one. Is that correct?</report>
	  
	  <report test="count(sub-article[@article-type=('reply','author-comment')]) gt 1" role="error" flag="dl-ar" id="test-r-article-a-reply-2">[test-r-article-a-reply-2] There cannot be more than one author response. This article has <value-of select="count(sub-article[@article-type=('reply','author-comment')])"/>.</report>
	  
	  <report test="count(sub-article[@article-type='editor-report']) gt 1" role="error" flag="dl-ar" id="editor-report-2">[editor-report-2] There cannot be more than one eLife Assessment or Editor's evaluation. This one has <value-of select="count(sub-article[@article-type='editor-report'])"/>.</report>
	
	</rule></pattern><pattern id="research-article-sub-article-pattern"><rule context="article[@article-type='research-article' and sub-article]" id="research-article-sub-article">
     <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
     
     <report test="$disp-channel != 'Scientific Correspondence' and not(sub-article[not(@article-type=('reply','author-comment'))])" flag="dl-ar" role="error" id="r-article-sub-articles">[r-article-sub-articles] <value-of select="$disp-channel"/> type articles cannot have only an Author response. The following combinations of peer review-material are permitted: Editor's evaluation, Decision letter, and Author response; Decision letter, and Author response; Editor's evaluation and Decision letter; Editor's evaluation and Author response; or Decision letter.</report>
     
   </rule></pattern>

  <pattern id="test-front-pattern"><rule context="article/front" id="test-front">
	 
  	  <assert test="count(journal-meta) = 1" role="error" id="test-front-jmeta">[test-front-jmeta] There must be one journal-meta that is a child of front. Currently there are <value-of select="count(journal-meta)"/></assert>
		  
  	  <assert test="count(article-meta) = 1" role="error" id="test-front-ameta">[test-front-ameta] There must be one article-meta that is a child of front. Currently there are <value-of select="count(article-meta)"/></assert>
	 
	 </rule></pattern>

  <pattern id="test-journal-meta-pattern"><rule context="article/front/journal-meta" id="test-journal-meta">
	 
		<assert test="journal-id[@journal-id-type='nlm-ta'] = 'elife'" role="error" id="test-journal-nlm">[test-journal-nlm] journal-id[@journal-id-type='nlm-ta'] must only contain 'elife'. Currently it is <value-of select="journal-id[@journal-id-type='nlm-ta']"/></assert>
		  
		<assert test="journal-id[@journal-id-type='publisher-id'] = 'eLife'" role="error" id="test-journal-pubid-1">[test-journal-pubid-1] journal-id[@journal-id-type='publisher-id'] must only contain 'eLife'. Currently it is <value-of select="journal-id[@journal-id-type='publisher-id']"/></assert>
	 
		<assert test="journal-title-group/journal-title = 'eLife'" role="error" id="test-journal-pubid-2">[test-journal-pubid-2] journal-meta must contain a journal-title-group with a child journal-title which must be equal to 'eLife'. Currently it is <value-of select="journal-id[@journal-id-type='publisher-id']"/></assert>
		  
		<assert test="issn = '2050-084X'" role="error" id="test-journal-pubid-3">[test-journal-pubid-3] ISSN must be 2050-084X. Currently it is <value-of select="issn"/></assert>
		  
		<assert test="issn[@publication-format='electronic'][@pub-type='epub']" role="error" id="test-journal-pubid-4">[test-journal-pubid-4] The journal issn element must have a @publication-format='electronic' and a @pub-type='epub'.</assert>
	    
	 </rule></pattern><pattern id="journal-id-pattern"><rule context="article/front/journal-meta/journal-id" id="journal-id">
      
      <assert test="@journal-id-type=('nlm-ta','publisher-id')" role="error" id="test-journal-id">[test-journal-id] The only journal-id-types permitted are 'nlm-ta' or 'publisher-id'. <value-of select="@journal-id-type"/> is not permitted.</assert>
    </rule></pattern>

  <pattern id="test-article-metadata-pattern"><rule context="article/front/article-meta" id="test-article-metadata">
    <let name="article-id" value="article-id[@pub-id-type='publisher-id'][1]"/>
    <let name="article-type" value="ancestor::article/@article-type"/>
    <let name="subj-type" value="descendant::subj-group[@subj-group-type='display-channel']/subject[1]"/>
    <let name="exceptions" value="('Insight',$notice-display-types)"/>
    <let name="no-digest" value="('Scientific Correspondence','Replication Study','Research Advance','Registered Report',$notice-display-types,$features-subj)"/>
    <let name="abs-count" value="count(abstract)"/>
    <let name="abs-standard-count" value="count(abstract[not(@abstract-type)])"/>
    <let name="digest-count" value="count(abstract[@abstract-type=('plain-language-summary','executive-summary')])"/>
    <let name="is-prc" value="e:is-prc(.)"/>
    
	<assert test="matches($article-id,'^\d{5,6}$')" role="error" id="test-article-id">[test-article-id] article-id must consist only of 5 or 6 digits. Currently it is <value-of select="article-id[@pub-id-type='publisher-id']"/></assert>
    
    <assert test="count(article-version) = 1" role="error" id="test-article-version-presence">[test-article-version-presence] There must be one article-version element in the article-meta. Currently there are <value-of select="count(article-version)"/></assert>
	   
     <assert test="count(article-categories) = 1" role="error" id="test-article-presence">[test-article-presence] There must be one article-categories element in the article-meta. Currently there are <value-of select="count(article-categories)"/></assert>
	   
    <assert test="title-group[article-title]" role="error" id="test-title-group-presence">[test-title-group-presence] title-group containing article-title must be present.</assert>
	   
    <assert test="pub-date[@publication-format='electronic'][@date-type='publication']" role="error" id="test-epub-date">[test-epub-date] There must be a child pub-date[@publication-format='electronic'][@date-type='publication'] in article-meta.</assert> 
	  
    <assert test="volume" role="error" id="test-volume-presence">[test-volume-presence] There must be a child volume in article-meta.</assert> 
		
    <assert test="matches(volume[1],'^[0-9]*$')" role="error" id="test-volume-contents">[test-volume-contents] volume must only contain a number.</assert> 
	   
    <assert test="elocation-id" role="error" id="test-elocation-presence">[test-elocation-presence] There must be a child elocation-id in article-meta.</assert>
		
    <report test="not($article-type = $notice-article-types) and not(self-uri)" role="error" id="test-self-uri-presence">[test-self-uri-presence] There must be a child self-uri in article-meta.</report>
		
    <report test="not($article-type = $notice-article-types) and not(self-uri[@content-type='pdf'])" role="error" id="test-self-uri-att">[test-self-uri-att] self-uri must have an @content-type="pdf"</report>
		
    <report test="not($article-type = $notice-article-types) and not(self-uri[starts-with(@xlink:href,concat('elife-', $article-id))])" role="error" id="test-self-uri-pdf-1">[test-self-uri-pdf-1] self-uri must have attribute xlink:href="elife-xxxxx.pdf" where xxxxx = the article-id. Currently it is <value-of select="self-uri/@xlink:href"/>. It should start with elife-<value-of select="$article-id"/>.</report>
    
    <report test="not($article-type = $notice-article-types) and not(self-uri[matches(@xlink:href, '^elife-[\d]{5,6}\.pdf$|^elife-[\d]{5,6}-v[0-9]{1,2}\.pdf$')])" role="error" id="test-self-uri-pdf-2">[test-self-uri-pdf-2] self-uri does not conform.</report>
		
    <report test="not($article-type = ($notice-article-types,'article-commentary','editorial')) and count(history) != 1" role="error" id="test-history-presence">[test-history-presence] There must be one and only one history element in the article-meta. Currently there are <value-of select="count(history)"/></report>
    
    <!-- Add this once all history is removed from insights
      
      <report test="($article-type = ($notice-article-types,'article-commentary')) and count(history) != 0" 
      role="error" 
      id="test-history-presence-2"><value-of select="$subj-type"/> cannot have a history element in the article-meta. Currently there are <value-of select="count(history)"/></report> -->
		  
    <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#test-permissions-presence" test="count(permissions) = 1" role="error" id="test-permissions-presence">[test-permissions-presence] There must be one and only one permissions element in the article-meta. Currently there are <value-of select="count(permissions)"/></assert>
		  
    <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#test-abstracts" test="not($article-type = $notice-article-types) and ($abs-count gt 2 or $abs-standard-count != 1 or $digest-count gt 1 or ($abs-count != $abs-standard-count + $digest-count))" role="error" id="test-abstracts">[test-abstracts] There must either be only one abstract or one abstract and one abstract[@abstract-type="plain-language-summary"]. No other variations are allowed.</report>
    
    <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#test-no-digest" test="($subj-type= $no-digest) and abstract[@abstract-type=('executive-summary','plain-language-summary')]" role="error" id="test-no-digest">[test-no-digest] '<value-of select="$subj-type"/>' cannot have a digest.</report>
	 
    <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#test-funding-group-presence" test="if ($article-type = $features-article-types) then ()       else if ($subj-type = ('Scientific Correspondence',$notice-display-types)) then ()       else count(funding-group) != 1" role="error" id="test-funding-group-presence">[test-funding-group-presence] There must be one and only one funding-group element in the article-meta. Currently there are <value-of select="count(funding-group)"/>.</report>
    
    
	   
    <report test="if ($subj-type = $exceptions) then ()       else count(custom-meta-group) != 1" role="error" id="final-test-custom-meta-group-presence">[final-test-custom-meta-group-presence] One custom-meta-group should be present in article-meta for all article types except Insights, Retractions, Corrections and Expressions of Concern.</report>
	   
    <report test="if ($subj-type = $notice-display-types) then ()       else count(kwd-group[@kwd-group-type='author-keywords']) != 1" role="error" id="test-auth-kwd-group-presence-1">[test-auth-kwd-group-presence-1] One author keyword group must be present in article-meta.</report>
    
    <report test="if ($subj-type = $notice-display-types) then (count(kwd-group[@kwd-group-type='author-keywords']) != 0)       else ()" role="error" id="test-auth-kwd-group-presence-2">[test-auth-kwd-group-presence-2] <value-of select="$subj-type"/> articles must not have any author keywords</report>
    
    <report test="count(kwd-group[@kwd-group-type='research-organism']) gt 1" role="error" id="test-ro-kwd-group-presence-1">[test-ro-kwd-group-presence-1] More than 1 Research organism keyword group is present in article-meta. This is incorrect.</report>
    
    <report test="if ($subj-type = ('Research Article', 'Research Advance', 'Replication Study', 'Research Communication'))       then (count(kwd-group[@kwd-group-type='research-organism']) = 0)       else ()" role="warning" id="test-ro-kwd-group-presence-2">[test-ro-kwd-group-presence-2] <value-of select="$subj-type"/> does not contain a Research Organism keyword group. Is this correct?</report>
    
    <report test="($subj-type=('Research Article','Research Advance','Tools and Resources','Short Report')) and (history/date[@date-type='received']/@iso-8601-date gt '2021-07-01') and not(pub-history[event[self-uri[@content-type='preprint']]])" role="warning" id="preprint-presence">[preprint-presence] This <value-of select="$subj-type"/> was received on '<value-of select="history/date[@date-type='received']/@iso-8601-date"/>' (after the preprint mandate) but does not have preprint information. Is that correct?</report>
   </rule></pattern><pattern id="article-dois-non-prc-pattern"><rule context="article[not(e:is-prc(.))]/front/article-meta/article-id[@pub-id-type='doi']" id="article-dois-non-prc">
      <let name="article-id" value="parent::article-meta/article-id[@pub-id-type='publisher-id'][1]"/>
      
      <assert test="starts-with(.,'10.7554/eLife.')" role="error" id="nprc-article-dois-1">[nprc-article-dois-1] Article level DOI must start with '10.7554/eLife.'. Currently it is <value-of select="."/></assert>
      
      <assert test="substring-after(.,'10.7554/eLife.') = $article-id" role="error" id="nprc-article-dois-2">[nprc-article-dois-2] Article level DOI must be a concatenation of '10.7554/eLife.' and the article-id. Currently it is <value-of select="."/></assert>
      
      <report test="preceding-sibling::article-id[@pub-id-type='doi']" role="error" id="nprc-article-dois-3">[nprc-article-dois-3] A non PRC article cannot have more than one DOI in article-meta.</report>
      
      <report test="@*[name()!='pub-id-type']" role="error" id="nprc-article-dois-4">[nprc-article-dois-4] The DOI article-id in a non PRC article cannot have any attributes others than pub-id-type. This one has the following unpermitted attributes: <value-of select="string-join(@*[name()!='pub-id-type']/name(),'; ')"/></report>
      
    </rule></pattern><pattern id="article-dois-prc-pattern"><rule context="article[e:is-prc(.)]/front/article-meta/article-id[@pub-id-type='doi']" id="article-dois-prc">
      <let name="article-id" value="parent::article-meta/article-id[@pub-id-type='publisher-id'][1]"/>
      <let name="latest-rp-doi" value="parent::article-meta/pub-history/event[position()=last()]/self-uri[@content-type='reviewed-preprint']/@xlink:href"/>
      <let name="latest-rp-doi-version" value="tokenize($latest-rp-doi,'\.')[last()]"/>
      
      <assert test="starts-with(.,'10.7554/eLife.')" role="error" id="prc-article-dois-1">[prc-article-dois-1] Article level DOI must start with '10.7554/eLife.'. Currently it is <value-of select="."/></assert>
      
      <report test="not(@specific-use) and substring-after(.,'10.7554/eLife.') != $article-id" role="error" id="prc-article-dois-2">[prc-article-dois-2] Article level concept DOI must be a concatenation of '10.7554/eLife.' and the article-id. Currently it is <value-of select="."/></report>
      
      <report test="@specific-use and not(contains(.,$article-id))" role="error" id="prc-article-dois-3">[prc-article-dois-3] Article level specific version DOI must contain the article-id (<value-of select="$article-id"/>). Currently it does not <value-of select="."/></report>
      
      <report test="@specific-use and not(matches(.,'^10.7554/eLife\.\d{5,6}\.\d$'))" role="error" id="prc-article-dois-4">[prc-article-dois-4] Article level specific version DOI must be in the format 10.7554/eLife.00000.0. Currently it is <value-of select="."/></report>
      
      <report test="not(@specific-use) and (preceding-sibling::article-id[@pub-id-type='doi'] or following-sibling::article-id[@pub-id-type='doi' and not(@specific-use)])" role="error" id="prc-article-dois-5">[prc-article-dois-5] Article level concept DOI must be first in article-meta, and there can only be one. This concept DOI has a preceding DOI or following concept DOI.</report>
      
      <report test="@specific-use and (following-sibling::article-id[@pub-id-type='doi'] or preceding-sibling::article-id[@pub-id-type='doi' and @specific-use])" role="error" id="prc-article-dois-6">[prc-article-dois-6] Article level version DOI must be second in article-meta. This version DOI has a following sibling DOI or a preceding version specific DOI.</report>
      
      <report test="@specific-use and @specific-use!='version'" role="error" id="prc-article-dois-7">[prc-article-dois-7] Article DOI has a specific-use attribute value <value-of select="@specific-use"/>. The only permitted value is 'version'.</report>
      
      <report test="@specific-use and number(substring-after(.,concat($article-id,'.'))) != (number($latest-rp-doi-version)+1)" role="error" id="final-prc-article-dois-8">[final-prc-article-dois-8] The version DOI for the VOR needs to end with a number that is one more than whatever number the latest reviewed preprint version DOI ends with. The VOR version DOI ends with <value-of select="substring-after(.,concat($article-id,'.'))"/> (<value-of select="."/>), whereas the latest reviewed preprint DOI in the publicaiton history ends with <value-of select="$latest-rp-doi-version"/> (<value-of select="$latest-rp-doi"/>). Either there is a missing reviewed preprint publication event in the publication history, or the VOR version DOI is incorrect.</report>
      
    </rule></pattern><pattern id="test-research-article-metadata-pattern"><rule context="article[@article-type='research-article']/front/article-meta" id="test-research-article-metadata">
   
    <assert test="contrib-group" role="error" id="test-contrib-group-presence-1">[test-contrib-group-presence-1] contrib-group (with no attributes containing authors) must be present (as a child of article-meta) for research articles.</assert>
     
     <assert test="contrib-group[@content-type='section']" role="error" id="test-contrib-group-presence-2">[test-contrib-group-presence-2] contrib-group[@content-type='section'] must be present (as a child of article-meta) for research articles (this is the contrib-group which contains reviewers and editors).</assert>
   
   </rule></pattern><pattern id="editorial-metadata-pattern"><rule context="article[@article-type='editorial']/front/article-meta" id="editorial-metadata">
      
      <report test="contrib-group[@content-type='section']" role="error" id="editorial-editors-presence">[editorial-editors-presence] Editorials cannot contain Editors and/or Reviewers. This one has a contrib-group[@content-type='section'] containing <value-of select="string-join(for $x in contrib-group[@content-type='section']/contrib return concat('&quot;',e:get-name($x/*[1][name()=('name','collab')]),'&quot;',' as ','&quot;',$x/role[1],'&quot;'),' and ')"/>.</report>
      
    </rule></pattern><pattern id="article-metadata-exceptions-pattern"><rule context="article[@article-type=('article-commentary',$notice-article-types)]/front/article-meta" id="article-metadata-exceptions">
      
      <report test="funding-group" role="error" id="funding-exception">[funding-exception] <value-of select="descendant::subj-group[@subj-group-type='display-channel'][1]/subject[1]"/>s cannot have funding, but this one has a funding-group element. Please remove it.</report>
      
    </rule></pattern><pattern id="article-version-pattern"><rule context="article-version" id="article-version">
      
      <assert test="parent::article-meta" role="error" id="article-version-test-1">[article-version-test-1] <name/> must be a child of article-meta. This one is a child of <value-of select="parent::*/name()"/>.</assert>
      
      <assert test="@article-version-type='publication-state'" role="error" id="article-version-test-2">[article-version-test-2] <name/> must a article-version-type="publication-state" attribute. This one does not.</assert>
      
      <report test="@*[name()!='article-version-type']" role="error" id="article-version-test-3">[article-version-test-3] The only attribute permitted on <name/> is article-version-type (with the value "publication-state"). This one has the following unallowed attribute(s): <value-of select="string-join(@*[name()!='article-version-type']/name(),'; ')"/>.</report>
      
      <assert test=".='version of record'" role="error" id="article-version-test-4">[article-version-test-4] <name/> must contain the text 'version of record'. This one contains '<value-of select="."/>'.</assert>
      
    </rule></pattern><pattern id="test-article-categories-pattern"><rule context="article-meta/article-categories" id="test-article-categories">
	 <let name="article-type" value="ancestor::article/@article-type"/>
   <let name="template" value="parent::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']) = 1" role="error" id="disp-subj-test">[disp-subj-test] There must be one subj-group[@subj-group-type='display-channel'] which is a child of article-categories. Currently there are <value-of select="count(article-categories/subj-group[@subj-group-type='display-channel'])"/>.</assert>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']/subject) = 1" role="error" id="disp-subj-test2">[disp-subj-test2] subj-group[@subj-group-type='display-channel'] must contain only one subject. Currently there are <value-of select="count(subj-group[@subj-group-type='display-channel']/subject)"/>.</assert>
    
     <report test="count(subj-group[@subj-group-type='heading']) gt 2" role="error" id="head-subj-test1">[head-subj-test1] article-categories must contain 0-2 subj-group[@subj-group-type='heading'] elements. Currently there are <value-of select="count(subj-group[@subj-group-type='heading']/subject)"/>.</report>
	   
     <report test="($article-type = ('research-article','review-article',$notice-article-types,'article-commentary')) and not($template ='5') and count(subj-group[@subj-group-type='heading']) lt 1" role="error" id="head-subj-test2">[head-subj-test2] article-categories must contain one and or two subj-group[@subj-group-type='heading'] elements. Currently there are 0.</report>
     
     <report test="($article-type = ('editorial','discussion')) and count(subj-group[@subj-group-type='heading']) lt 1" role="warning" id="head-subj-test3">[head-subj-test3] article-categories does not contain a subj-group[@subj-group-type='heading']. Is this correct?</report>
	   
     <assert test="count(subj-group[@subj-group-type='heading']/subject) = count(distinct-values(subj-group[@subj-group-type='heading']/subject))" role="error" id="head-subj-distinct-test">[head-subj-distinct-test] Where there are two headings, the content of one must not match the content of the other (each heading should be unique)</assert>
	</rule></pattern><pattern id="disp-channel-checks-pattern"><rule context="article-categories/subj-group[@subj-group-type='display-channel']/subject" id="disp-channel-checks">
    <let name="article-type" value="ancestor::article/@article-type"/> 
      <let name="research-disp-channels" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Scientific Correspondence')"/>
      
      <assert test=". = $allowed-disp-subj" role="error" id="disp-subj-value-test-1">[disp-subj-value-test-1] Content of the display channel should be one of the following: Research Article, Short Report, Tools and Resources, Research Advance, Registered Report, Replication Study, Research Communication, Feature Article, Insight, Editorial, Correction, Retraction . Currently it is <value-of select="."/>.</assert>
      
      <report test="($article-type = 'research-article') and not(.=($research-disp-channels,'Feature Article'))" role="error" id="disp-subj-value-test-2">[disp-subj-value-test-2] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be one of 'Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', or 'Scientific Correspondence' according to the article-type.</report>
      
      <report test="($article-type = 'article-commentary') and not(.='Insight')" role="error" id="disp-subj-value-test-3">[disp-subj-value-test-3] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Insight' according to the article-type.</report>
      
      <report test="($article-type = 'editorial') and not(.='Editorial')" role="error" id="disp-subj-value-test-4">[disp-subj-value-test-4] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Editorial' according to the article-type.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#h0zbc-disp-subj-value-test-5" test="($article-type = 'correction') and not(.='Correction')" role="error" id="disp-subj-value-test-5">[disp-subj-value-test-5] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Correction' according to the article-type.</report>
      
      <report test="($article-type = 'discussion') and not(.='Feature Article')" role="error" id="disp-subj-value-test-6">[disp-subj-value-test-6] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Feature Article' according to the article-type.</report>
      
      <report test="($article-type = 'review-article') and not(.='Review Article')" role="error" id="disp-subj-value-test-7">[disp-subj-value-test-7] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Review Article' according to the article-type.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#h7pnv-disp-subj-value-test-8" test="($article-type = 'retraction') and not(.='Retraction')" role="error" id="disp-subj-value-test-8">[disp-subj-value-test-8] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Retraction' according to the article-type.</report>
      
      <report test="($article-type = 'expression-of-concern') and not(.='Expression of Concern')" role="error" id="disp-subj-value-test-9">[disp-subj-value-test-9] Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Expression of Concern' according to the article-type.</report>
  </rule></pattern><pattern id="MSA-checks-pattern"><rule context="article-categories/subj-group[@subj-group-type='heading']/subject" id="MSA-checks">
      
      <assert test=". = $MSAs" role="error" id="head-subj-MSA-test">[head-subj-MSA-test] Content of the heading must match one of the MSAs.</assert>
    </rule></pattern><pattern id="head-subj-checks-pattern"><rule context="article-categories/subj-group[@subj-group-type='heading']" id="head-subj-checks">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert test="count(subject) = 1" role="error" id="head-subj-test-1">[head-subj-test-1] Each subj-group[@subj-group-type='heading'] must contain one and only one subject. This one contains <value-of select="count(subject)"/>.</assert>
    </rule></pattern><pattern id="test-title-group-pattern"><rule context="article/front/article-meta/title-group" id="test-title-group">
	  <let name="subj-type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
	  <let name="lc" value="normalize-space(lower-case(article-title[1]))"/>
	  <let name="title" value="replace(article-title[1],'\p{P}','')"/>
	  <let name="body" value="ancestor::front/following-sibling::body[1]"/>
	  <let name="tokens" value="string-join(for $x in tokenize($title,' ')[position() &gt; 1] return      if (matches($x,'^[A-Z]') and (string-length($x) gt 1) and matches($body,concat(' ',lower-case($x),' '))) then $x      else (),', ')"/>
	
    <report test="ends-with(replace(article-title[1],'\p{Z}',''),'.')" role="error" id="article-title-test-1">[article-title-test-1] Article title must not end with a full stop - '<value-of select="article-title"/>'.</report>  
   
    <report test="article-title[text() != ''] = lower-case(article-title[1])" role="warning" id="article-title-test-2">[article-title-test-2] Article title is entirely in lower case, is this correct? - <value-of select="article-title"/>.</report>
   
    <report test="article-title[text() != ''] = upper-case(article-title[1])" role="error" id="article-title-test-3">[article-title-test-3] Article title must not be entirely in upper case - <value-of select="article-title"/>.</report>
	  
	  <report test="not(article-title/*) and normalize-space(article-title[1])=''" role="error" id="article-title-test-4">[article-title-test-4] Article title must not be empty.</report>
	  
    <report test="article-title//mml:math" role="warning" id="article-title-test-5">[article-title-test-5] Article title contains maths. Is this correct?</report>
	  
    <report test="article-title//bold" role="error" id="article-title-test-6">[article-title-test-6] Article title must not contain bold.</report>
	  
	  <report test="article-title//underline" role="error" id="article-title-test-7">[article-title-test-7] Article title must not contain underline.</report>
	  
	  <report test="article-title//break" role="error" id="article-title-test-8">[article-title-test-8] Article title must not contain a line break (the element 'break').</report>
	  
	  <report test="matches(article-title[1],'-Based ')" role="error" id="article-title-test-9">[article-title-test-9] Article title contains the string '-Based '. this should be lower-case, '-based '. - <value-of select="article-title"/></report>
	  
	  <!-- exception for articles with structured abstracts -->
	  <report test="($subj-type = ('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Research Communication', 'Feature article', 'Insight', 'Editorial', 'Scientific Correspondence')) and not(ancestor::article-meta/abstract[not(@abstract-type) and sec]) and contains(article-title[1],':')" role="warning" id="article-title-test-10">[article-title-test-10] Article title contains a colon. This almost never allowed. - <value-of select="article-title"/></report>
	  
	  <report test="not($subj-type = ($notice-display-types,'Scientific Correspondence','Replication Study')) and matches($tokens,'[A-Za-z]')" role="warning" id="article-title-test-11">[article-title-test-11] Article title contains a capitalised word(s) which is not capitalised in the body of the article - <value-of select="$tokens"/> - is this correct? - <value-of select="article-title"/></report>
	  
	  <report test="matches(article-title[1],' [Bb]ased ') and not(matches(article-title[1],' [Bb]ased on '))" role="warning" id="article-title-test-12">[article-title-test-12] Article title contains the string ' based'. Should the preceding space be replaced by a hyphen - '-based'. - <value-of select="article-title"/></report>
	
	</rule></pattern><pattern id="review-article-title-tests-pattern"><rule context="article[@article-type='review-article']/front/article-meta/title-group/article-title[contains(.,': ')]" id="review-article-title-tests">
      <let name="pre-colon" value="substring-before(.,':')"/>
      <let name="post-colon" value="substring-after(.,': ')"/>
      
      <assert test="substring($pre-colon,1,1) = upper-case(substring($pre-colon,1,1))" role="error" id="review-article-title-1">[review-article-title-1] The first character in the title for a review article should be upper case. '<value-of select="substring($pre-colon,1,1)"/>' in '<value-of select="."/>'</assert>
      
      <assert test="substring($post-colon,1,1) = upper-case(substring($post-colon,1,1))" role="error" id="review-article-title-2">[review-article-title-2] The first character after the colon in the title for a review article should be upper case. '<value-of select="substring($post-colon,1,1)"/>' in '<value-of select="."/>'</assert>
    </rule></pattern><pattern id="test-contrib-group-pattern"><rule context="article/front/article-meta/contrib-group" id="test-contrib-group">
		
    <assert test="contrib" role="error" id="contrib-presence-test">[contrib-presence-test] contrib-group must contain at least one contrib.</assert>
		  
    <report test="count(contrib[@equal-contrib='yes']) = 1" role="error" id="equal-count-test">[equal-count-test] There is one contrib with the attribute equal-contrib='yes'. This cannot be correct. Either 2 or more contribs within the same contrib-group should have this attribute, or none. Check <value-of select="contrib[@equal-contrib='yes']/name"/></report>
	
	</rule></pattern><pattern id="auth-contrib-group-pattern"><rule context="article/front/article-meta/contrib-group[1]" id="auth-contrib-group">
      <let name="names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="indistinct-names" value="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      <let name="orcids" value="for $x in contrib[@contrib-type='author']/contrib-id[@contrib-id-type='orcid'] return substring-after($x,'orcid.org/')"/>
      <let name="indistinct-orcids" value="for $orcid in distinct-values($orcids) return $orcid[count($orcids[. = $orcid]) gt 1]"/>
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="non-contribs" value="('article-commentary', 'editorial', 'book-review', $notice-article-types)"/>
      
      <assert test="contrib[@contrib-type='author' and @corresp='yes']" role="error" id="corresp-presence-test">[corresp-presence-test] There must be at least one corresponding author (a contrib[@contrib-type='author' and @corresp='yes'] in the first contrib-group).</assert>
      
      <assert test="empty($indistinct-names)" role="warning" id="duplicate-author-test">[duplicate-author-test] There is more than one author with the following name(s) - <value-of select="if (count($indistinct-names) gt 1) then concat(string-join($indistinct-names[position() != last()],', '),' and ',$indistinct-names[last()]) else $indistinct-names"/> - which is very likely be incorrect.</assert>
      
      <report test="$article-type=$non-contribs and descendant::contrib[@contrib-type='author' and role]" role="error" id="non-contrib-contribs">[non-contrib-contribs] <value-of select="$article-type"/> type articles should not contain author contributions.</report>
      
    </rule></pattern><pattern id="test-editor-contrib-group-pattern"><rule context="article/front/article-meta/contrib-group[@content-type='section']" id="test-editor-contrib-group">
      
      <assert test="count(contrib[@contrib-type='senior_editor']) = 1" role="error" id="editor-conformance-1">[editor-conformance-1] contrib-group[@content-type='section'] must contain one (and only 1) Senior Editor (contrib[@contrib-type='senior_editor']).</assert>
      
      <assert test="count(contrib[@contrib-type='editor']) = 1" role="warning" id="editor-conformance-2">[editor-conformance-2] contrib-group[@content-type='section'] should contain one (and only 1) Reviewing Editor (contrib[@contrib-type='editor']). This one doesn't which is almost definitely incorrect and needs correcting.</assert>
      
    </rule></pattern><pattern id="test-editors-contrib-pattern"><rule context="article/front/article-meta/contrib-group[@content-type='section']/contrib" id="test-editors-contrib">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role[1]"/>
      <let name="author-contribs" value="ancestor::article-meta/contrib-group[1]/contrib[@contrib-type='author']"/>
      <let name="matching-author-names" value="for $contrib in $author-contribs return if (e:get-name($contrib/name[1])=$name) then e:get-name($contrib) else ()"/>
      
      <report test="(@contrib-type='senior_editor') and ($role!='Senior Editor')" role="error" id="editor-conformance-3">[editor-conformance-3] <value-of select="$name"/> has a @contrib-type='senior_editor' but their role is not 'Senior Editor' (<value-of select="$role"/>), which is incorrect.</report>
      
      <report test="(@contrib-type='editor') and ($role!='Reviewing Editor')" role="error" id="editor-conformance-4">[editor-conformance-4] <value-of select="$name"/> has a @contrib-type='editor' but their role is not 'Reviewing Editor' (<value-of select="$role"/>), which is incorrect.</report>

      <assert test="count($matching-author-names)=0" role="error" id="editor-conformance-5">[editor-conformance-5] <value-of select="$name"/> is listed both as an author and as a <value-of select="$role"/>, which must be incorrect.</assert>
      
    </rule></pattern><pattern id="auth-cont-tests-pattern"><rule context="article[@article-type=('research-article','review-article') and e:get-version(.)='1']//article-meta//contrib[(@contrib-type='author') and not(child::collab) and not(ancestor::collab)]" id="auth-cont-tests">
      
      <assert test="child::xref[@ref-type='fn' and matches(@rid,'^con[0-9]{1,3}$')]" role="warning" flag="version-1" id="auth-cont-test-1">[auth-cont-test-1] <value-of select="e:get-name(name[1])"/> has no contributions. Please ensure to query this with the authors.</assert>
    </rule></pattern><pattern id="duplicated-cont-tests-pattern"><rule context="article[e:get-version(.)='1']//article-meta//contrib[(@contrib-type='author') and xref[@ref-type='fn' and matches(@rid,'^con[0-9]{1,3}$')]]" id="duplicated-cont-tests">
      <let name="credit-regex" value="'^(conceptuali[sz]ation|data\s\p{Pd}?\s?curation|formal\sanalysis|funding\sacquisition|investigation|methodology|project\sadministration|resources|software|supervision|validation|visuali[sz]ation|writing\s\p{Pd}?\s?(original\sdraft|review\s(&amp;|and)\sediting))$'"/>
      <let name="cont-rid" value="xref[@ref-type='fn' and matches(@rid,'^con[0-9]{1,3}$')]/@rid"/>
      <let name="cont-fn" value="ancestor::article//back//fn[@id=$cont-rid]/p"/>
      <let name="con-vals" value="for $x in tokenize(string-join($cont-fn,', '),', ') return replace(lower-case($x),'\p{Zs}$|^\p{Zs}','')"/>
      <let name="indistinct-conts" value="for $val in distinct-values($con-vals)[matches(.,$credit-regex)] return $val[count($con-vals[. = $val]) gt 1]"/>
      
      <assert test="empty($indistinct-conts)" role="error" flag="version-1" id="dupe-cont-test-1">[dupe-cont-test-1] Author <value-of select="if (name) then e:get-name(name[1]) else if (collab) then (e:get-collab(collab[1])) else ('with no name')"/> has duplicated contributions which is incorrect. The indistinct contributions are: <value-of select="string-join($indistinct-conts,'; ')"/>.</assert>
    </rule></pattern><pattern id="auth-cont-tests-v2-pattern"><rule context="article[@article-type=('research-article','review-article') and e:get-version(.)!='1']//article-meta//contrib[(@contrib-type='author') and not(child::collab) and not(ancestor::collab)]" id="auth-cont-tests-v2">
      
      <assert test="role" role="warning" flag="version-2" id="auth-cont-test-1-v2">[auth-cont-test-1-v2] <value-of select="e:get-name(name[1])"/> has no contributions. Please ensure to query this with the authors.</assert>
      
      <report test="role and not(role[@vocab='credit'])" role="warning" flag="version-2" id="auth-cont-test-2-v2">[auth-cont-test-2-v2] <value-of select="e:get-name(name[1])"/> has no CRediT contributions. Is that correct?</report>
    </rule></pattern><pattern id="collab-cont-tests-pattern"><rule context="article[@article-type=('research-article','review-article') and e:get-version(.)='1']//article-meta//contrib[(@contrib-type='author') and child::collab]" id="collab-cont-tests">
      
      <assert test="child::xref[@ref-type='fn' and matches(@rid,'^con[0-9]{1,3}$')]" role="warning" flag="version-1" id="collab-cont-test-1">[collab-cont-test-1] <value-of select="e:get-collab(child::collab[1])"/> has no contributions. Please ensure to query this with the authors.</assert>
    </rule></pattern><pattern id="collab-cont-tests-v2-pattern"><rule context="article[@article-type=('research-article','review-article') and e:get-version(.)!='1']//article-meta//contrib[(@contrib-type='author') and child::collab]" id="collab-cont-tests-v2">
      
      
      
      <assert test="role" role="error" flag="version-2" id="final-collab-cont-test-1-v2">[final-collab-cont-test-1-v2] <value-of select="e:get-collab(child::collab[1])"/> has no contributions. Please ensure to query this with the authors.</assert>
      
      <report test="role and not(role[@vocab='credit'])" role="warning" flag="version-2" id="final-collab-cont-test-2-v2">[final-collab-cont-test-2-v2] <value-of select="e:get-collab(child::collab[1])"/> has no CRediT contributions. Is that correct?</report>
    </rule></pattern><pattern id="duplicated-cont-tests-v2-pattern"><rule context="article[e:get-version(.)!='1']//article-meta//contrib[@contrib-type='author']" id="duplicated-cont-tests-v2">
      <let name="roles" value="for $x in role return lower-case($x)"/>
      <let name="indistinct-conts" value="for $role in distinct-values($roles) return $role[count($roles[. = $role]) gt 1]"/>
     
      <assert test="empty($indistinct-conts)" role="error" id="dupe-cont-test-v2">[dupe-cont-test-v2] Author <value-of select="if (name) then e:get-name(name[1]) else if (collab) then (e:get-collab(collab[1])) else ('with no name')"/> has duplicated contributions - <value-of select="$indistinct-conts"/> - which is incorrect.</assert>
      
    </rule></pattern><pattern id="collab-tests-pattern"><rule context="article//article-meta/contrib-group[1]/contrib[@contrib-type='author']/collab/contrib-group" id="collab-tests">
      <let name="names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="indistinct-names" value="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      <let name="orcids" value="for $x in contrib[@contrib-type='author']/contrib-id[@contrib-id-type='orcid'] return substring-after($x,'orcid.org/')"/>
      <let name="indistinct-orcids" value="for $orcid in distinct-values($orcids) return $orcid[count($orcids[. = $orcid]) gt 1]"/>
      
      <assert test="empty($indistinct-names)" role="warning" id="duplicate-member-test">[duplicate-member-test] There is more than one member of the group author <value-of select="e:get-collab(parent::collab)"/> with the following name(s) - <value-of select="if (count($indistinct-names) gt 1) then concat(string-join($indistinct-names[position() != last()],', '),' and ',$indistinct-names[last()]) else $indistinct-names"/> - which is very likely incorrect.</assert>
      
      <assert test="empty($indistinct-orcids)" role="error" id="duplicate-member-orcid-test">[duplicate-member-orcid-test] There is more than one member of the group author <value-of select="e:get-collab(parent::collab)"/> with the following ORCiD(s) - <value-of select="if (count($indistinct-orcids) gt 1) then concat(string-join($indistinct-orcids[position() != last()],', '),' and ',$indistinct-orcids[last()]) else $indistinct-orcids"/> - which must be incorrect.</assert>
    </rule></pattern><pattern id="collab-tests-2-pattern"><rule context="article//article-meta/contrib-group[1][contrib[@contrib-type='author']/collab/contrib-group]" id="collab-tests-2">
      <let name="top-names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="members" value="for $member in contrib[@contrib-type='author']/collab/contrib-group/contrib[@contrib-type='author']/name[1]         return e:get-name($member)"/>
      <let name="auth-and-member" value="$top-names[.=$members]"/>
      
      <assert test="empty($auth-and-member)" role="warning" id="auth-and-member-test">[auth-and-member-test] Top level author(s) <value-of select="if (count($auth-and-member) gt 1) then concat(string-join($auth-and-member[position() != last()],', '),' and ',$auth-and-member[last()]) else $auth-and-member"/> are also a member of a group author. Is this correct?</assert>
    </rule></pattern><pattern id="author-xref-tests-pattern"><rule context="article-meta//contrib[@contrib-type='author']/xref" id="author-xref-tests">
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hzwb3-author-xref-test-1" test="(@ref-type='aff') and preceding-sibling::xref[not(@ref-type='aff')]" role="error" id="author-xref-test-1">[author-xref-test-1] Affiliation footnote links (xrefs) from authors must be the first type of link to be listed. For <value-of select="e:get-name(preceding-sibling::name[1])"/>, their affiliation link - <value-of select="."/> - appears after another non-affiliation link, when it should appear before it.</report>
      
      <report test="(@ref-type='fn') and contains(@rid,'equal') and preceding-sibling::xref[not(@ref-type='aff')]" role="error" id="author-xref-test-2">[author-xref-test-2] Equal contribution links from authors must appear after affiliation footnote links. For <value-of select="e:get-name(preceding-sibling::name[1])"/>, their equal contribution link (to <value-of select="idref(@rid)"/>) appears after another non-affiliation link, when it should appear before it.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hzwb3-author-xref-test-3" test="(@ref-type='fn') and contains(@rid,'pa') and following-sibling::xref[@ref-type='aff' or contains(@rid,'equal')]" role="error" id="author-xref-test-3">[author-xref-test-3] Present address type footnote links from authors must appear after affiliation and equal contribution links (if there is one). For <value-of select="e:get-name(preceding-sibling::name[1])"/>, their present address link (to <value-of select="idref(@rid)"/>) appears before an affiliation link or equal contribution link.</report>
      
      <report test="contains(@rid,'dataset')" role="error" id="author-xref-test-4">[author-xref-test-4] Author footnote links to datasets are not needed. Please remove this - &lt;xref <value-of select="string-join(for $x in self::*/@* return concat($x/name(),'=&quot;',$x,'&quot;'),' ')"/>/&gt;</report>
    </rule></pattern><pattern id="name-tests-pattern"><rule context="contrib-group//name" id="name-tests">
		
    	<assert test="count(surname) = 1" role="error" id="surname-test-1">[surname-test-1] Each name must contain only one surname.</assert>
	  
	  <report test="count(given-names) gt 1" role="error" id="given-names-test-1">[given-names-test-1] Each name must contain only one given-names element.</report>
	  
	  <assert test="given-names" role="warning" id="given-names-test-2">[given-names-test-2] This name - <value-of select="."/> - does not contain a given-name. Please check with eLife staff that this is correct.</assert>
	  
	</rule></pattern><pattern id="surname-tests-pattern"><rule context="contrib-group//name/surname" id="surname-tests">
		
	  <report test="normalize-space(.)=''" role="error" id="surname-test-2">[surname-test-2] surname must not be empty.</report>
		
    <report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" role="error" id="surname-test-3">[surname-test-3] surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	  <assert test="matches(.,&quot;^[\p{L}\p{M}\s'’-]*$&quot;)" role="error" id="surname-test-4">[surname-test-4] surname should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <report test="matches(.,'^\p{Ll}') and not(matches(.,'^de[lrn]? |^van |^von |^el |^te[rn] |^d[ai] '))" role="warning" id="surname-test-5">[surname-test-5] surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</report>
	  
	  <report test="matches(.,'^\p{Zs}')" role="error" id="surname-test-6">[surname-test-6] surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\p{Zs}$')" role="error" id="surname-test-7">[surname-test-7] surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	    
	    <report test="matches(.,'^[A-Z]{1,2}\p{Zs}') and (string-length(.) gt 3)" role="warning" id="surname-test-8">[surname-test-8] surname looks to start with initial - '<value-of select="."/>'. Should '<value-of select="substring-before(.,' ')"/>' be placed in the given-names field?</report>
	    
	    <report test="matches(.,'[\(\)\[\]]')" role="warning" id="surname-test-9">[surname-test-9] surname contains brackets - '<value-of select="."/>'. Should the bracketed text be placed in the given-names field instead?</report>
	    
	    <report test="matches(.,'\p{Zs}(III?|I?V)$')" role="warning" id="surname-test-10">[surname-test-10] surname ends with what might be roman numerals - '<value-of select="."/>'. Should these be placed in a suffix element instead?</report>
		
	  </rule></pattern><pattern id="given-names-tests-pattern"><rule context="name/given-names" id="given-names-tests">
		
	  <report test="normalize-space(.)=''" role="error" id="given-names-test-3">[given-names-test-3] given-names must not be empty.</report>
		
    	<report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" role="error" id="given-names-test-4">[given-names-test-4] given-names must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript) - '<value-of select="."/>'.</report>
		
      <assert test="matches(.,&quot;^[\p{L}\p{M}\(\)\s'’-]*$&quot;)" role="error" id="given-names-test-5">[given-names-test-5] given-names should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <assert test="matches(.,'^\p{Lu}')" role="warning" id="given-names-test-6">[given-names-test-6] given-names doesn't begin with a capital letter - '<value-of select="."/>'. Is this correct?</assert>
	  
    <report test="matches(.,'^[\p{L}]{1}\.$|^[\p{L}]{1}\.\p{Zs}?[\p{L}]{1}\.\p{Zs}?$')" role="error" id="given-names-test-7">[given-names-test-7] given-names contains initialised full stop(s) which is incorrect - <value-of select="."/></report>
	  
    <report test="matches(.,'^\p{Zs}')" role="error" id="given-names-test-8">[given-names-test-8] given-names starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
    <report test="matches(.,'\p{Zs}$')" role="error" id="given-names-test-9">[given-names-test-9] given-names ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'[A-Za-z] [Dd]e[rn]?$')" role="warning" id="given-names-test-10">[given-names-test-10] given-names ends with de, der, or den - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
		
	  <report test="matches(.,'[A-Za-z] [Vv]an$')" role="warning" id="given-names-test-11">[given-names-test-11] given-names ends with ' van' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z] [Vv]on$')" role="warning" id="given-names-test-12">[given-names-test-12] given-names ends with ' von' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z] [Ee]l$')" role="warning" id="given-names-test-13">[given-names-test-13] given-names ends with ' el' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(.,'[A-Za-z] [Tt]e[rn]?$')" role="warning" id="given-names-test-14">[given-names-test-14] given-names ends with te, ter, or ten - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(normalize-space(.),'[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]|[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]$|^[A-za-z]\p{Zs}[A-za-z]$')" role="info" id="given-names-test-15">[given-names-test-15] given-names contains initials with spaces. Ensure that the space(s) is removed between initials - '<value-of select="."/>'.</report>
		
	</rule></pattern><pattern id="suffix-tests-pattern"><rule context="contrib-group//name/suffix" id="suffix-tests">
      
      <assert test=".=('Jr', 'Jnr', 'Sr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')" role="error" id="suffix-assert">[suffix-assert] suffix can only have one of these values - 'Jr', 'Jnr', 'Sr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'.</assert>
      
      <report test="*" role="error" id="suffix-child-test">[suffix-child-test] suffix cannot have any child elements - <value-of select="*/local-name()"/></report>
      
    </rule></pattern><pattern id="name-child-tests-pattern"><rule context="contrib-group//name/*" id="name-child-tests">
      
      <assert test="local-name() = ('surname','given-names','suffix')" role="error" id="disallowed-child-assert">[disallowed-child-assert] <value-of select="local-name()"/> is not allowed as a child of name.</assert>
      
    </rule></pattern><pattern id="contrib-tests-pattern"><rule context="article-meta//contrib" id="contrib-tests">
	  <let name="type" value="@contrib-type"/>
	  <let name="subj-type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
	  <let name="aff-rid1" value="xref[@ref-type='aff'][1]/@rid"/>
	  <let name="inst1" value="ancestor::contrib-group//aff[@id = $aff-rid1]//institution[not(@content-type)][1]"/>
	  <let name="aff-rid2" value="xref[@ref-type='aff'][2]/@rid"/>
	  <let name="inst2" value="ancestor::contrib-group//aff[@id = $aff-rid2]//institution[not(@content-type)][1]"/>
	  <let name="aff-rid3" value="xref[@ref-type='aff'][3]/@rid"/>
	  <let name="inst3" value="ancestor::contrib-group//aff[@id = $aff-rid3]//institution[not(@content-type)][1]"/>
	  <let name="aff-rid4" value="xref[@ref-type='aff'][4]/@rid"/>
	  <let name="inst4" value="ancestor::contrib-group//aff[@id = $aff-rid4]//institution[not(@content-type)][1]"/>
	  <let name="aff-rid5" value="xref[@ref-type='aff'][5]/@rid"/>
	  <let name="inst5" value="ancestor::contrib-group//aff[@id = $aff-rid5]//institution[not(@content-type)][1]"/>
	  <let name="inst" value="concat($inst1,'*',$inst2,'*',$inst3,'*',$inst4,'*',$inst5)"/>
	  <let name="coi-rid" value="xref[starts-with(@rid,'conf')]/@rid"/>
	  <let name="coi" value="ancestor::article//fn[@id = $coi-rid]/p[1]"/>
	  <let name="comp-regex" value="' [Ii]nc[.]?| LLC| Ltd| [Ll]imited| [Cc]ompanies| [Cc]ompany| [Cc]o\.| Pharmaceutical[s]| [Pp][Ll][Cc]|AstraZeneca|Pfizer| R&amp;D'"/>
	  <let name="fn-rid" value="xref[starts-with(@rid,'fn')]/@rid"/>
	  <let name="fn" value="string-join(ancestor::article-meta//author-notes/fn[@id = $fn-rid]/p,'')"/>
	  <let name="name" value="if (child::collab[1]) then collab else if (child::name[1]) then e:get-name(child::name[1]) else ()"/>
		
		<!-- Subject to change depending of the affiliation markup of group authors and editors. Currently fires for individual group contributors and editors who do not have either a child aff or a child xref pointing to an aff.  -->
    	<report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hjuk3-contrib-test-1" test="if ($subj-type = $notice-display-types) then ()        else if (collab) then ()        else if (ancestor::collab) then ()        else if ($type != 'author') then ()        else count(xref[@ref-type='aff']) = 0" role="error" id="contrib-test-1">[contrib-test-1] Authors should have at least 1 link to an affiliation. <value-of select="$name"/> does not.</report>
	  
	  <report test="if ($subj-type = $notice-display-types) then ()            else if ($type != 'author') then ()            else if (collab) then ()            else if (ancestor::collab) then (count(xref[@ref-type='aff']) + count(aff) = 0)            else ()" role="warning" id="contrib-test-5">[contrib-test-5] Group author members should likely have an affiliation. <value-of select="$name"/> does not. Is this OK?</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hjuk3-contrib-test-2" test="($type = 'senior_editor') and (count(xref[@ref-type='aff']) + count(aff) = 0)" role="warning" id="contrib-test-2">[contrib-test-2] The <value-of select="role[1]"/> doesn't have an affiliation - <value-of select="$name"/> - is this correct? Exeter: If it is not present in the eJP output, please check with eLife production. Production: Please check eJP or ask Editorial for the correct affiliation.</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hjuk3-contrib-test-4" test="($type = 'editor') and (count(xref[@ref-type='aff']) + count(aff) = 0)" role="error" id="contrib-test-4">[contrib-test-4] The <value-of select="role[1]"/> (<value-of select="$name"/>) must have an affiliation. Exeter: If it is not present in the eJP output, please check with eLife production. Production: Please check eJP or ask Editorial for the correct affiliation.</report>
	  
	     <report test="name and collab" role="error" id="contrib-test-3">[contrib-test-3] author contains both a child name and a child collab. This is not correct.</report>
	  
	     <report test="if (collab) then ()         else count(name) != 1" role="error" id="name-test">[name-test] Contrib contains no collab but has <value-of select="count(name)"/> name(s). This is not correct.</report>
	  
	     <report test="self::*[@corresp='yes'][not(child::*:email)]" role="error" id="contrib-email-1">[contrib-email-1] Corresponding authors must have an email.</report>
	  
	  <report test="not(@corresp='yes') and (not(ancestor::collab/parent::contrib[@corresp='yes'])) and (child::email)" role="error" id="contrib-email-2">[contrib-email-2] Non-corresponding authors must not have an email.</report>
	  
	  <report test="(@contrib-type='author') and ($coi = 'No competing interests declared') and (matches($inst,$comp-regex))" role="warning" id="COI-test">[COI-test] <value-of select="$name"/> is affiliated with what looks like a company, but contains no COI statement. Is this correct?</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/deceased-status-8gs60uqk#deceased-test-1" test="matches($fn,'[Dd]eceased') and not(@deceased='yes')" role="error" id="deceased-test-1">[deceased-test-1] <value-of select="$name"/> has a linked footnote '<value-of select="$fn"/>', but not @deceased="yes" which is incorrect.</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/deceased-status-8gs60uqk#deceased-test-2" test="(@deceased='yes') and not(matches($fn,'[Dd]eceased'))" role="error" id="deceased-test-2">[deceased-test-2] <value-of select="$name"/> has the attribute deceased="yes", but no footnote which contains the text 'Deceased', which is incorrect.</report>
		
		</rule></pattern><pattern id="corresp-author-initial-tests-pattern"><rule context="article[@article-type=('research-article','review-article','discussion')]//article-meta[not(descendant::custom-meta[meta-name='Template']/meta-value='3')]/contrib-group[1][count(contrib[@contrib-type='author' and @corresp='yes']) gt 1]/contrib[@contrib-type='author' and @corresp='yes' and name]" id="corresp-author-initial-tests">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="normalized-name" value="e:stripDiacritics($name)"/>
      
      <report test="$normalized-name != $name" role="warning" id="corresp-author-initial-test">[corresp-author-initial-test] <value-of select="$name"/> has a name with letters that have diacritics, marks, or a name with special characters. Please ensure that their initials display correctly in the PDF in the 'For correspondence' section on the first page.</report>
      
    </rule></pattern><pattern id="author-children-tests-pattern"><rule context="article[e:get-version(.)='1']//article-meta//contrib[@contrib-type='author']/*" id="author-children-tests">
		  <let name="article-type" value="ancestor::article/@article-type"/> 
		  <let name="template" value="ancestor::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
			<let name="allowed-contrib-blocks" value="('name', 'collab', 'contrib-id', 'email', 'xref')"/>
		  <let name="allowed-contrib-blocks-features" value="($allowed-contrib-blocks, 'bio')"/>
		
		  <!-- Exception included for group authors -->
		  <assert test="if (ancestor::collab) then self::*[local-name() = ($allowed-contrib-blocks,'aff')]       else if ($template = '5') then self::*[local-name() = $allowed-contrib-blocks-features]       else if ($article-type = ($features-article-types,'expression-of-concern')) then self::*[local-name() = $allowed-contrib-blocks-features]       else self::*[local-name() = $allowed-contrib-blocks]" role="error" flag="version-1" id="author-children-test">[author-children-test] <value-of select="self::*/local-name()"/> is not allowed as a child of author.</assert>
		
		</rule></pattern><pattern id="author-children-tests-v2-pattern"><rule context="article[e:get-version(.)!='1']//article-meta//contrib[@contrib-type='author']/*" id="author-children-tests-v2">
      <let name="article-type" value="ancestor::article/@article-type"/> 
      <let name="template" value="ancestor::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
      <let name="allowed-contrib-blocks" value="('name', 'collab', 'contrib-id', 'email', 'xref','role')"/>
      <let name="allowed-contrib-blocks-features" value="($allowed-contrib-blocks, 'bio')"/>
      
      <!-- Exception included for group authors -->
      <assert test="if (ancestor::collab) then self::*[local-name() = ($allowed-contrib-blocks,'aff')]         else if ($template = '5') then self::*[local-name() = $allowed-contrib-blocks-features]         else if ($article-type = $features-article-types) then self::*[local-name() = $allowed-contrib-blocks-features]         else self::*[local-name() = $allowed-contrib-blocks]" role="error" flag="version-2" id="author-children-test-v2">[author-children-test-v2] <value-of select="self::*/local-name()"/> is not allowed as a child of author.</assert>
      
    </rule></pattern><pattern id="author-role-tests-pattern"><rule context="article[e:get-version(.)!='1']//article-meta//contrib[@contrib-type='author']/role[@vocab='credit']" id="author-role-tests">
      <let name="credit-roles" value="'credit-roles.xml'"/>
      <let name="vocab-term" value="@vocab-term"/>
      <let name="vocab-term-id" value="lower-case(@vocab-term-identifier)"/>
      <let name="credit-role" value="document($credit-roles)//*:item[(@term = $vocab-term) or (@uri = $vocab-term-id)]"/>
      
      <assert test="@vocab-identifier='http://credit.niso.org/'" role="error" id="credit-role-check-1">[credit-role-check-1] A CRediT taxonomy role must have a @vocab-identifier whose value is http://credit.niso.org/.</assert>
      
      <report test="not(@vocab-term-identifier) or ((count($credit-role) = 1) and ($vocab-term-id != $credit-role/@uri))" role="error" flag="version-2" id="credit-role-check-2">[credit-role-check-2] A CRediT taxonomy role must have a @vocab-term-identifier, the value of which must be the URL of the specific CRediT term. <value-of select="if (empty($credit-role)) then concat('It must be one of these - ',string-join(document($credit-roles)//*:item/@uri,', ')) else concat('In this case ',$credit-role/@uri,' (based on the @vocab-term of this role element)')"/>.</report>
      
      <report test="not(@vocab-term) or ((count($credit-role) = 1) and ($vocab-term != $credit-role/@term))" role="error" flag="version-2" id="credit-role-check-3">[credit-role-check-3] A CRediT taxonomy role must have a @vocab-term, the value of which must be one of the CRediT terms - <value-of select="if (empty($credit-role)) then string-join(document($credit-roles)//*:item/@term,', ')            else concat(' in this case ',$credit-role/@term,' (based on the @vocab-term-identifer of of this role element)')"/>.</report>
      
      <assert test="(count($credit-role) = 1) and $vocab-term=$credit-role/@term and $vocab-term-id= $credit-role/@uri" role="error" flag="version-2" id="credit-role-check-4">[credit-role-check-4] A CRediT taxonomy role must have a @vocab-term, whose value is a specific CRediT taxonomy term, and a @vocab-term-identifier, whose value is the URL for that corresponding CRediT term. <value-of select="concat('Either the @vocab-term - ', $vocab-term, ' - is incorrect and must be ', if ($credit-role[@uri=$vocab-term-id]) then $credit-role[@uri=$vocab-term-id]/@term else 'unknown', ', or the @vocab-term-identifier - ', $vocab-term-id,' - is incorrect and must be ', $credit-role[@term=$vocab-term]/@uri)"/>.</assert>
      
    </rule></pattern><pattern id="author-role-tests-2-pattern"><rule context="article[e:get-version(.)!='1']//article-meta//contrib[@contrib-type='author']/role[not(@vocab='credit')]" id="author-role-tests-2">
      <let name="vocab-term" value="@vocab-term"/>
      <let name="vocab-term-id" value="lower-case(@vocab-term-identifier)"/>
      
      <report test="@vocab-term or @vocab-term-identifier or @vocab-identifier" role="error" flag="version-2" id="author-role-check-1">[author-role-check-1] role with <value-of select="string-join(@*[name()=('vocab-term','vocab-term-identifier','vocab-identifier')]/name(),'; ')"/> attributes must have a vocab="credit" attribute. This one does not.</report>
      
      <report test="matches(lower-case(.),'^\p{Zs}*(conceptuali[sz]ation|data\p{Zs}+curation|formal\p{Zs}+analysis|funding\p{Zs}+acquisition|investigation|methodology|project\p{Zs}+administration|resources|software|supervision|validation|visualization|writing\p{Zs}+[-–—]\p{Zs}+original\p{Zs}+draft|writing\p{Zs}+[-–—]\p{Zs}+review(ing)?\p{Zs}+(&amp;|and)\p{Zs}+editing)\p{Zs}*$')" role="error" flag="version-2" id="author-role-check-2">[author-role-check-2] role with content '<value-of select="."/>' exactly matches one of the CRediT taxonomy terms, but it does not have a vocab="credit" attribute.</report>
      
    </rule></pattern><pattern id="orcid-tests-pattern"><rule context="contrib-id[@contrib-id-type='orcid']" id="orcid-tests">
	  <let name="text" value="."/>
		
    	<assert test="@authenticated='true'" role="error" id="orcid-test-1">[orcid-test-1] contrib-id[@contrib-id-type="orcid"] must have an @authenticated="true"</assert>
		
		<!-- Needs updating to only allow https when this is implemented -->
	  <assert test="matches(.,'^http[s]?://orcid.org/[\d]{4}-[\d]{4}-[\d]{4}-[\d]{3}[0-9X]$')" role="error" id="orcid-test-2">[orcid-test-2] contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL in the format 'https://orcid.org/0000-0000-0000-0000'</assert>
	  
	  
	  
	  <assert test="count(ancestor::contrib-group//contrib-id[@contrib-id-type='orcid' and .=$text]) = 1" role="error" id="final-orcid-test-3">[final-orcid-test-3] <value-of select="e:get-name(parent::*/name[1])"/>'s ORCiD is the same as another author's - <value-of select="."/>. Duplicated ORCiDs are not allowed. If it is clear who the ORCiD belongs to, remove the duplicate. If it is not clear please raise a query with production so that they can raise it with the authors.</assert>
		
		<assert test="e:is-valid-orcid(.)" role="error" id="orcid-test-4">[orcid-test-4] contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL. <value-of select="."/> is not a valid ORCID URL.</assert>
		
		</rule></pattern><pattern id="email-tests-pattern"><rule context="article-meta//email" id="email-tests">
		
    	<assert test="matches(upper-case(.),'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+$')" role="error" id="email-test">[email-test] email element must contain a valid email address. Currently it is <value-of select="self::*"/>.</assert>
		
	</rule></pattern><pattern id="history-tests-pattern"><rule context="article-meta[not(e:is-prc(.))]/history" id="history-tests">
	  
    	<assert test="date[@date-type='received']" role="error" id="history-date-test-1">[history-date-test-1] history must contain date[@date-type='received']</assert>
		
    	<assert test="date[@date-type='accepted']" role="error" id="history-date-test-2">[history-date-test-2] history must contain date[@date-type='accepted']</assert>
	  
	</rule></pattern><pattern id="prc-history-tests-pattern"><rule context="article-meta[e:is-prc(.)]/history" id="prc-history-tests">
      
      <assert test="date[@date-type='sent-for-review']" role="error" id="prc-history-date-test-1">[prc-history-date-test-1] history must contain date[@date-type='sent-for-review'] in PRC articles.</assert>
      
      <report test="date[@date-type!='sent-for-review' or not(@date-type)]" role="error" id="prc-history-date-test-2">[prc-history-date-test-2] PRC articles can only have sent-for-review dates in their history. This one has a <value-of select="if (date[@date-type!='sent-for-review']) then date[@date-type!='sent-for-review']/@date-type else 'undefined'"/> date.</report>
      
    </rule></pattern><pattern id="date-tests-pattern"><rule context="date" id="date-tests">
	  
	  <assert test="matches(day[1],'^[0-9]{2}$')" role="error" id="date-test-1">[date-test-1] date must contain day in the format 00. Currently it is '<value-of select="day"/>'.</assert>
	  
	  <assert test="matches(month[1],'^[0-9]{2}$')" role="error" id="date-test-2">[date-test-2] date must contain month in the format 00. Currently it is '<value-of select="month"/>'.</assert>
	  
	  <assert test="matches(year[1],'^[0-9]{4}$')" role="error" id="date-test-3">[date-test-3] date must contain year in the format 0000. Currently it is Currently it is '<value-of select="year"/>'.</assert>
		
    	<assert test="@iso-8601-date = concat(year[1],'-',month[1],'-',day[1])" role="error" id="date-test-4">[date-test-4] date must have an @iso-8601-date the value of which must be the values of the year-month-day elements. Currently it is <value-of select="@iso-8601-date"/>, when it should be <value-of select="concat(year,'-',month,'-',day)"/>.</assert>
	
	</rule></pattern><pattern id="day-tests-pattern"><rule context="day[not(parent::string-date)]" id="day-tests">
      
      <assert test="matches(.,'^[0][1-9]$|^[1-2][0-9]$|^[3][0-1]$')" role="error" id="day-conformity">[day-conformity] day must contain 2 digits which are between '01' and '31' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule></pattern><pattern id="month-tests-pattern"><rule context="month[not(parent::string-date)]" id="month-tests">
      
      <assert test="matches(.,'^[0][1-9]$|^[1][0-2]$')" role="error" id="month-conformity">[month-conformity] month must contain 2 digits which are between '01' and '12' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule></pattern><pattern id="year-article-meta-tests-pattern"><rule context="year[ancestor::article-meta]" id="year-article-meta-tests">
      
      <assert test="matches(.,'^[2]0[0-2][0-9]$')" role="error" id="year-article-meta-conformity">[year-article-meta-conformity] year in article-meta must contain 4 digits which match the regular expression '^[2]0[0-2][0-9]$' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule></pattern><pattern id="year-element-citation-tests-pattern"><rule context="year[ancestor::element-citation]" id="year-element-citation-tests">
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#final-year-element-citation-conformity" test="matches(.,'^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$')" role="error" id="final-year-element-citation-conformity">[final-year-element-citation-conformity] year in reference must contain content which matches the regular expression '^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$' - '<value-of select="."/>' doesn't meet this requirement. If there is no year, and this cannot be determined yourself, please query this with the authors.</assert>
      
    </rule></pattern><pattern id="pub-date-tests-pattern"><rule context="pub-date" id="pub-date-tests">
      <let name="allowed-attributes" value="('publication-format','date-type','iso-8601-date')"/>
      
      <assert test="parent::article-meta" role="error" id="pub-date-test-1">[pub-date-test-1] pub-date can only be a child of article-meta. This one is a child of <value-of select="parent::*/name()"/></assert>

      <report test="@*[not(name()=$allowed-attributes)]" role="error" id="pub-date-test-2">[pub-date-test-2] Only the following attributes are permitted on pub-date. This one has the following unallowed attributes: <value-of select="string-join(@*[not(name()=$allowed-attributes)]/name(),'; ')"/>.</report>

      <report test="@publication-format and @publication-format!='electronic'" role="error" id="pub-date-test-3">[pub-date-test-3] pub-date has the attribute publication-format, but the value is "<value-of select="@publication-format"/>". The only permitted value is "electronic".</report>

      <report test="@date-type and @date-type!='publication'" role="error" id="pub-date-test-4">[pub-date-test-4] pub-date has the attribute date-type, but the value is "<value-of select="@date-type"/>". The only permitted value is "publication".</report>

      <report test="preceding-sibling::pub-date" role="error" id="pub-date-test-5">[pub-date-test-5] There can only be one pub-date in article-meta. But this pub-date has a preceding one.</report>

      <assert test="@publication-format" role="error" id="pub-date-test-6">[pub-date-test-6] pub-date must have the attribute publication-format.</assert>

      <assert test="@date-type" role="error" id="pub-date-test-7">[pub-date-test-7] pub-date must have the attribute date-type.</assert>

      <assert test="matches(day[1],'^[0-9]{2}$')" role="error" id="final-pub-date-test-8">[final-pub-date-test-8] pub-date must contain day in the format 00. Currently it is '<value-of select="day"/>'.</assert>

      <assert test="matches(month[1],'^[0-9]{2}$')" role="error" id="final-pub-date-test-9">[final-pub-date-test-9] pub-date must contain month in the format 00. Currently it is '<value-of select="month"/>'.</assert>

      <assert test="matches(year[1],'^[0-9]{4}$')" role="error" id="final-pub-date-test-10">[final-pub-date-test-10] pub-date must contain year in the format 0000. Currently it is '<value-of select="year"/>'.</assert>
      
    </rule></pattern><pattern id="pub-date-child-tests-pattern"><rule context="pub-date/*" id="pub-date-child-tests">
      <let name="allowed-children" value="('day','month','year')"/>

    <assert test="name()=$allowed-children" role="error" id="pub-date-child-test-1">[pub-date-child-test-1] <value-of select="name()"/> is not allowed as a child of pub-date. The only permitted elements are <value-of select="string-join($allowed-children,'; ')"/>.</assert>

     </rule></pattern><pattern id="press-pub-date-pattern"><rule context="pub-date[not(@pub-type='collection') and day and month and year][concat(year[1],'-',month[1],'-',day[1]) gt format-date(current-date(), '[Y0001]-[M01]-[D01]')]" id="press-pub-date">
      <let name="date" value="concat(year[1],'-',month[1],'-',day[1])"/>
      
      <report test="e:get-weekday($date) != 2" role="warning" id="press-pub-date-check">[press-pub-date-check] The publication date for this article is in the future (<value-of select="$date"/>), but the day of publication is not a Tuesday (for Press). Is that correct?</report>
      
    </rule></pattern><pattern id="pub-history-tests-pattern"><rule context="pub-history" id="pub-history-tests">
      
      <assert test="parent::article-meta" role="error" id="pub-history-parent">[pub-history-parent] <name/> is only allowed to be captured as a child of article-meta. This one is a child of <value-of select="parent::*/name()"/>.</assert>
      
      <report test="not(e:is-prc(.)) and count(event) gt 1" role="error" id="pub-history-child">[pub-history-child] <name/> must have one, and only one, event element in non-PRC content. This one has <value-of select="count(event)"/>.</report>
      
      <report test="e:is-prc(.) and count(event) le 1" role="error" id="pub-history-events-1">[pub-history-events-1] <name/> in PRC articles must have more than one event element, at least one for the preprint, and at least one for the reviewed preprint (there may be numerous reviewed preprint events). This one has <value-of select="count(event)"/> event elements.</report>
      
      <report test="count(event[self-uri[@content-type='preprint']]) != 1" role="error" id="pub-history-events-2">[pub-history-events-2] <name/> must contain one, and only one preprint event (an event with a self-uri[@content-type='preprint'] element). This one has <value-of select="count(event[self-uri[@content-type='preprint']])"/> preprint event elements.</report>
      
      <report test="e:is-prc(.) and count(event[self-uri[@content-type='reviewed-preprint']]) lt 1" role="error" id="pub-history-events-3">[pub-history-events-3] <name/> in PRC articles must have at least one event element for reviewed preprint publication (an event with a self-uri[@content-type='reviewed-preprint'] element). This one has none.</report>
      
      <report test="e:is-prc(.) and count(event[self-uri[@content-type='reviewed-preprint']]) gt 3" role="warning" id="pub-history-events-4">[pub-history-events-4] <name/> has <value-of select="count(event[self-uri[@content-type='reviewed-preprint']])"/> reviewed preprint event elements, which is unusual. Is this correct?</report>
    </rule></pattern><pattern id="event-tests-pattern"><rule context="event" id="event-tests">
      <let name="date" value="date[1]/@iso-8601-date"/>
      
      <assert test="event-desc" role="error" id="event-test-1">[event-test-1] <name/> must contain an event-desc element. This one does not.</assert>
      
      <assert test="date[@date-type=('preprint','reviewed-preprint')]" role="error" id="event-test-2">[event-test-2] <name/> must contain a date element with the attribute date-type="preprint" or date-type="reviewed-preprint". This one does not.</assert>
      
      <assert test="self-uri" role="error" id="event-test-3">[event-test-3] <name/> must contain a self-uri element. This one does not.</assert>
        
        <report test="following-sibling::event[date[@iso-8601-date lt $date]]" role="error" id="event-test-4">[event-test-4] Events in pub-history must be ordered chronologically in descending order. This event has a date (<value-of select="$date"/>) which is later than the date of a following event (<value-of select="preceding-sibling::event[date[@iso-8601-date lt $date]][1]"/>).</report>
      
      <report test="date and self-uri and date[1]/@date-type != self-uri[1]/@content-type" role="error" id="event-test-5">[event-test-5] This event in pub-history has a date with the date-type <value-of select="date[1]/@date-type"/>, but a self-uri with the content-type <value-of select="self-uri[1]/@content-type"/>. These values should be the same, so one (or both of them) are incorrect.</report>
    </rule></pattern><pattern id="rp-event-tests-pattern"><rule context="event[date[@date-type='reviewed-preprint']/@iso-8601-date != '']" id="rp-event-tests">
      <let name="rp-link" value="self-uri[@content-type='reviewed-preprint']/@xlink:href"/>
      <let name="rp-version" value="replace($rp-link,'^.*\.','')"/>
      <let name="rp-pub-date" value="date[@date-type='reviewed-preprint']/@iso-8601-date"/>
      <let name="sent-for-review-date" value="ancestor::article-meta/history/date[@date-type='sent-for-review']/@iso-8601-date"/>
      <let name="preprint-pub-date" value="parent::pub-history/event/date[@date-type='preprint']/@iso-8601-date"/>
      <let name="later-rp-events" value="parent::pub-history/event[date[@date-type='reviewed-preprint'] and replace(self-uri[@content-type='reviewed-preprint'][1]/@xlink:href,'^.*\.','') gt $rp-version]"/>
      
      <report test="($preprint-pub-date and $preprint-pub-date != '') and         $preprint-pub-date ge $rp-pub-date" role="error" id="rp-event-test-1">[rp-event-test-1] Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than the preprint posted date (<value-of select="$preprint-pub-date"/>), which must be incorrect.</report>
      
      <report test="($sent-for-review-date and $sent-for-review-date != '') and         $sent-for-review-date ge $rp-pub-date" role="error" id="rp-event-test-2">[rp-event-test-2] Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than the sent for review date (<value-of select="$sent-for-review-date"/>), which must be incorrect.</report>
      
      <report test="$later-rp-events/date/@iso-8601-date = $rp-pub-date" role="error" id="rp-event-test-3">[rp-event-test-3] Reviewed preprint publication date (<value-of select="$rp-pub-date"/>) in the publication history (for RP version <value-of select="$rp-version"/>) is the same or an earlier date than publication date for a later reviewed preprint version date (<value-of select="$later-rp-events/date/@iso-8601-date[. = $rp-pub-date]"/> for version(s) <value-of select="$later-rp-events/self-uri[@content-type='reviewed-preprint'][1]/@xlink:href/replace(.,'^.*\.','')"/>). This must be incorrect.</report>
      
    </rule></pattern><pattern id="event-child-tests-pattern"><rule context="event/*" id="event-child-tests">
      <let name="allowed-elems" value="('event-desc','date','self-uri')"/>
      
      <assert test="name()=$allowed-elems" role="error" id="event-child">[event-child] <name/> is not allowed in an event element. The only permitted children of event are <value-of select="string-join($allowed-elems,', ')"/>.</assert>
    </rule></pattern><pattern id="event-desc-tests-pattern"><rule context="event-desc" id="event-desc-tests">
      
      <report test="not(matches(parent::event/self-uri[1]/@xlink:href,'elifesciences\.org|10.7554/e[lL]ife')) and not(starts-with(.,'This manuscript was published as a preprint at ') or .='This manuscript was published as a preprint.')" role="error" id="event-desc-content">[event-desc-content] <name/> that's a child of an event without an eLife DOI must contain the text 'This manuscript was published as a preprint at ' followed by the preprint server name. This one does not.</report>
      
      <report test="matches(parent::event/self-uri[1]/@xlink:href,'elifesciences\.org|10.7554/e[lL]ife') and not(.=('This manuscript was published as a reviewed preprint.','The reviewed preprint was revised.'))" role="error" id="event-desc-content-2">[event-desc-content-2] <name/> that's a child of an event with an eLife DOI must contain the text 'This manuscript was published as a reviewed preprint.' or 'The reviewed preprint was revised.'</report>
      
      <report test="*" role="error" id="event-desc-elems">[event-desc-elems] <name/> cannot contain elements. This one has the following: <value-of select="string-join(distinct-values(*/name()),', ')"/>.</report>
      
    </rule></pattern><pattern id="event-date-tests-pattern"><rule context="event/date" id="event-date-tests">
      
      <assert test="day and month and year" role="error" id="event-date-child">[event-date-child] <name/> in event must have a day, month and year element. This one does not.</assert>
      
      <assert test="@date-type=('preprint','reviewed-preprint')" role="error" id="event-date-type">[event-date-type] <name/> in event must have a date-type attribute with the value 'preprint' or 'reviewed-preprint'.</assert>
    </rule></pattern><pattern id="event-self-uri-tests-pattern"><rule context="event/self-uri" id="event-self-uri-tests">
      <let name="article-id" value="ancestor::article-meta/article-id[@pub-id-type='publisher-id']"/>
      
      <assert test="@content-type=('preprint','reviewed-preprint')" role="error" id="event-self-uri-content-type">[event-self-uri-content-type] <name/> in event must have the attribute content-type="preprint" or content-type="reviewed-preprint". This one does not.</assert>
      
      <assert test="not(*) and normalize-space(.)=''" role="error" id="event-self-uri-content">[event-self-uri-content] <name/> in event must be empty. This one contains elements and/or text.</assert>
      
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;&lt;&gt;//=]*)$')" role="error" id="event-self-uri-href-1">[event-self-uri-href-1] <name/> in event must have an xlink:href attribute containing a link to the preprint. This one does not have a valid URI - <value-of select="@xlink:href"/>.</assert>
      
      <report test="matches(lower-case(@xlink:href),'(bio|med)rxiv')" role="error" id="event-self-uri-href-2">[event-self-uri-href-2] <name/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. bioRxiv and medRxiv preprint have dois, and this one points to one of those, but it is not a doi - <value-of select="@xlink:href"/>.</report>
      
      <assert test="matches(@xlink:href,'https?://(dx.doi.org|doi.org)/')" role="warning" id="event-self-uri-href-3">[event-self-uri-href-3] <name/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. This one is not a doi - <value-of select="@xlink:href"/>. Please check whether there is a doi that can be used instead.</assert>
      
      <report test="@content-type='reviewed-preprint' and not(matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]$'))" role="error" id="event-self-uri-href-4">[event-self-uri-href-4] <name/> in event has the attribute content-type="reviewed-preprint", but the xlink:href attribute does not contain an eLife version specific DOI - <value-of select="@xlink:href"/>.</report>
      
      <report test="(@content-type!='reviewed-preprint' or not(@content-type)) and matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.\d$')" role="error" id="event-self-uri-href-5">[event-self-uri-href-5] <name/> in event does not have the attribute content-type="reviewed-preprint", but the xlink:href attribute contains an eLife version specific DOI - <value-of select="@xlink:href"/>. If it's a preprint event, the link should be to a preprint. If it's an event for reviewed preprint publication, then it should have the attribute content-type!='reviewed-preprint'.</report>
      
      <report test="@content-type='reviewed-preprint' and not(contains(@xlink:href,$article-id))" role="error" id="event-self-uri-href-6">[event-self-uri-href-6] <name/> in event the attribute content-type="reviewed-preprint", but the xlink:href attribute value (<value-of select="@xlink:href"/>) does not contain the article id (<value-of select="$article-id"/>) which must be incorrect, since this should be the version DOI for the reviewed preprint version.</report>
    </rule></pattern><pattern id="front-permissions-tests-pattern"><rule context="front//permissions" id="front-permissions-tests">
	  <let name="author-contrib-group" value="ancestor::article-meta/contrib-group[1]"/>
	  <let name="copyright-holder" value="e:get-copyright-holder($author-contrib-group)"/>
	  <let name="license-type" value="license/@xlink:href"/>
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-4" test="ali:free_to_read" role="error" id="permissions-test-4">[permissions-test-4] permissions must contain an ali:free_to_read element.</assert>
	
	<assert test="license" role="error" id="permissions-test-5">[permissions-test-5] permissions must contain license.</assert>
	  
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-9" test="$license-type = ('http://creativecommons.org/publicdomain/zero/1.0/', 'https://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by/4.0/')" role="error" id="permissions-test-9">[permissions-test-9] license does not have an @xlink:href which is equal to 'http://creativecommons.org/publicdomain/zero/1.0/' or 'http://creativecommons.org/licenses/by/4.0/'.</assert>
	  
	  <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-info" test="license" role="info" id="permissions-info">[permissions-info] This article is licensed under a<value-of select="      if (contains($license-type,'publicdomain/zero')) then ' CC0 1.0'      else if (contains($license-type,'by/4.0')) then ' CC BY 4.0'      else if (contains($license-type,'by/3.0')) then ' CC BY 3.0'      else 'n unknown'"/> license. <value-of select="$license-type"/></report>
	
	</rule></pattern><pattern id="cc-by-permissions-tests-pattern"><rule context="front//permissions[contains(license[1]/@xlink:href,'creativecommons.org/licenses/by/')]" id="cc-by-permissions-tests">
      <let name="author-contrib-group" value="ancestor::article-meta/contrib-group[1]"/>
      <let name="copyright-holder" value="e:get-copyright-holder($author-contrib-group)"/>
      <let name="license-type" value="license/@xlink:href"/>
      <let name="is-prc" value="e:is-prc(.)"/>
      <!-- dirty - needs doing based on first date rather than just position? -->
      <let name="authoritative-year" value="if ($is-prc) then ancestor::article-meta/pub-history/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]         else ancestor::article-meta/pub-date[@publication-format='electronic'][@date-type=('publication','pub')]/year[1]"/>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-1" test="copyright-statement" role="error" id="permissions-test-1">[permissions-test-1] permissions must contain copyright-statement in CC BY licensed articles.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-2" test="matches(copyright-year[1],'^[0-9]{4}$')" role="error" id="permissions-test-2">[permissions-test-2] permissions must contain copyright-year in the format 0000 in CC BY licensed articles. Currently it is <value-of select="copyright-year"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-3" test="copyright-holder" role="error" id="permissions-test-3">[permissions-test-3] permissions must contain copyright-holder in CC BY licensed articles.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-6" test="copyright-year = $authoritative-year" role="error" id="permissions-test-6">[permissions-test-6] copyright-year must match the year of first reviewed preprint publication under the new model or first publicaiton date in the old model. For this <value-of select="if ($is-prc) then 'new' else 'old'"/> model paper, currently copyright-year=<value-of select="copyright-year"/> and authoritative pub-date=<value-of select="$authoritative-year"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-7" test="copyright-holder = $copyright-holder" role="error" id="permissions-test-7">[permissions-test-7] copyright-holder is incorrect. If the article has one author then it should be their surname (or collab name). If it has two authors it should be the surname (or collab name) of the first, then ' and ' and then the surname (or collab name) of the second. If three or more, it should be the surname (or collab name) of the first, and then ' et al'. Currently it's '<value-of select="copyright-holder"/>' when based on the author list it should be '<value-of select="$copyright-holder"/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-8" test="copyright-statement = concat('© ',copyright-year,', ',copyright-holder)" role="error" id="permissions-test-8">[permissions-test-8] copyright-statement must contain a concatenation of '© ', copyright-year, and copyright-holder. Currently it is <value-of select="copyright-statement"/> when according to the other values it should be <value-of select="concat('© ',copyright-year,', ',copyright-holder)"/></assert>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#hztjj-permissions-test-16" test="ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')]" role="warning" id="permissions-test-16">[permissions-test-16] This article is CC-BY, but one or more of the authors are affiliated with the NIH (<value-of select="string-join(for $x in ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')] return $x,'; ')"/>). Should it be CC0 instead?</report>
      
      <let name="nih-rors" value="('https://ror.org/01cwqze88','https://ror.org/03jh5a977','https://ror.org/04r5s4b52','https://ror.org/04byxyr05','https://ror.org/02xey9a22','https://ror.org/040gcmg81','https://ror.org/04pw6fb54','https://ror.org/00190t495','https://ror.org/03wkg3b53','https://ror.org/012pb6c26','https://ror.org/00baak391','https://ror.org/043z4tv69','https://ror.org/006zn3t30','https://ror.org/00372qc85','https://ror.org/004a2wv92','https://ror.org/00adh9b73','https://ror.org/00j4k1h63','https://ror.org/04q48ey07','https://ror.org/04xeg9z08','https://ror.org/01s5ya894','https://ror.org/01y3zfr79','https://ror.org/049v75w11','https://ror.org/02jzrsm59','https://ror.org/04mhx6838','https://ror.org/00fq5cm18','https://ror.org/0493hgw16','https://ror.org/04vfsmv21','https://ror.org/00fj8a872','https://ror.org/0060t0j89','https://ror.org/01jdyfj45')"/>
      <report test="ancestor::article-meta/contrib-group[1]/aff[count(descendant::institution-id) = 1 and descendant::institution-id=$nih-rors]" role="warning" id="permissions-test-17">[permissions-test-17] This article is CC-BY, but one or more of the authors are affiliated with the NIH (<value-of select="string-join(for $x in ancestor::article-meta/contrib-group[1]/aff[count(descendant::institution-id) = 1 and descendant::institution-id=$nih-rors] return $x,'; ')"/>). Should it be CC0 instead?</report>
    </rule></pattern><pattern id="cc-0-permissions-tests-pattern"><rule context="front//permissions[contains(license[1]/@xlink:href,'creativecommons.org/publicdomain/zero')]" id="cc-0-permissions-tests">
      <let name="license-type" value="license/@xlink:href"/>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-1" test="copyright-statement" role="error" id="cc-0-test-1">[cc-0-test-1] This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-statement (<value-of select="copyright-statement"/>) which is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-2" test="copyright-year" role="error" id="cc-0-test-2">[cc-0-test-2] This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-year (<value-of select="copyright-year"/>) which is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-3" test="copyright-holder" role="error" id="cc-0-test-3">[cc-0-test-3] This is a CC0 licensed article (<value-of select="$license-type"/>), but there is a copyright-holder (<value-of select="copyright-holder"/>) which is not correct.</report>
      
    </rule></pattern><pattern id="license-tests-pattern"><rule context="front//permissions/license" id="license-tests">
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-1" test="ali:license_ref" role="error" id="license-test-1">[license-test-1] license must contain ali:license_ref.</assert>
	
	  <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-2" test="count(license-p) = 1" role="error" id="license-test-2">[license-test-2] license must contain one and only one license-p.</assert>
	
	</rule></pattern><pattern id="license-p-tests-pattern"><rule context="front//permissions/license/license-p" id="license-p-tests">
      <let name="license-link" value="parent::license/@xlink:href"/>
      <let name="license-type" value="if (contains($license-link,'//creativecommons.org/publicdomain/zero/1.0/')) then 'cc0' else if (contains($license-link,'//creativecommons.org/licenses/by/4.0/')) then 'ccby' else ('unknown')"/>
      
      <let name="cc0-text" value="'This is an open-access article, free of all copyright, and may be freely reproduced, distributed, transmitted, modified, built upon, or otherwise used by anyone for any lawful purpose. The work is made available under the Creative Commons CC0 public domain dedication.'"/>
      <let name="ccby-text" value="'This article is distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use and redistribution provided that the original author and source are credited.'"/>
      
      <report test="($license-type='ccby') and .!=$ccby-text" role="error" id="license-p-test-1">[license-p-test-1] The text in license-p is incorrect (<value-of select="."/>). Since this article is CCBY licensed, the text should be <value-of select="$ccby-text"/>.</report>
      
      <report test="($license-type='cc0') and .!=$cc0-text" role="error" id="license-p-test-2">[license-p-test-2] The text in license-p is incorrect (<value-of select="."/>). Since this article is CC0 licensed, the text should be <value-of select="$cc0-text"/>.</report>
      
    </rule></pattern><pattern id="license-link-tests-pattern"><rule context="permissions/license[@xlink:href]/license-p" id="license-link-tests">
      <let name="license-link" value="parent::license/@xlink:href"/>
      
      <assert see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hx30h-p-test-3" test="some $x in ext-link satisfies $x/@xlink:href = $license-link" role="error" id="license-p-test-3">[license-p-test-3] If a license element has an xlink:href attribute, there must be a link in license-p that matches the link in the license/@xlink:href attribute. License link: <value-of select="$license-link"/>. Links in the license-p: <value-of select="string-join(ext-link/@xlink:href,'; ')"/>.</assert>
    </rule></pattern><pattern id="license-ali-ref-link-tests-pattern"><rule context="permissions/license[ali:license_ref]/license-p" id="license-ali-ref-link-tests">
      <let name="ali-ref" value="parent::license/ali:license_ref"/>
      
      <assert test="some $x in ext-link satisfies $x/@xlink:href = $ali-ref" role="error" id="license-p-test-4">[license-p-test-4] If a license contains an ali:license_ref element, there must be a link in license-p that matches the link in the ali:license_ref element. ali:license_ref link: <value-of select="$ali-ref"/>. Links in the license-p: <value-of select="string-join(ext-link/@xlink:href,'; ')"/>.</assert>
    </rule></pattern><pattern id="abstract-tests-pattern"><rule context="front//abstract" id="abstract-tests">
	  <let name="article-type" value="ancestor::article/@article-type"/>
	
	  <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#abstract-test-2" test="(count(p) + count(sec[descendant::p])) lt 1" role="error" id="abstract-test-2">[abstract-test-2] At least 1 p element or sec element (with descendant p) must be present in abstract.</report>
	
	  <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#abstract-test-4" test="descendant::disp-formula" role="error" id="abstract-test-4">[abstract-test-4] abstracts cannot contain display formulas.</report>
	  
	  
	  
	  <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-abstract-test-5" test="child::sec and not(count(sec) = (5,6))" role="error" id="final-abstract-test-5">[final-abstract-test-5] If an abstract is structured, then it must have 5 or 6 sections depending on whether it is a clinical trial. An article without a clinical trial should have 5 sections, whereas one with a clinical trial should have 6.</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#abstract-test-6" test="matches(lower-case(.),'^\p{Zs}*abstract')" role="warning" id="abstract-test-6">[abstract-test-6] Abstract starts with the word 'Abstract', which is almost certainly incorrect - <value-of select="."/></report>
	  
	  <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#abstract-test-7" test="some $x in child::p satisfies (starts-with($x,'Background:') or starts-with($x,'Methods:') or starts-with($x,'Results:') or starts-with($x,'Conclusion:') or starts-with($x,'Trial registration:') or starts-with($x,'Clinical trial number:'))" role="warning" id="abstract-test-7">[abstract-test-7] Abstract looks like it should instead be captured as a structured abstract (using sections) - <value-of select="."/></report>
	  
	  <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#abstract-test-9" test="matches(.,'_{5}')" role="error" id="abstract-test-9">[abstract-test-9] Abstract contains a series of underscores directly next to each other. These are replacement characters input by the bot when the export from eJP contains an unknown or unsupported unicode character. Check the original abstract where these underscores are and ensure that they are replaced with whatever character should be present, or that the underscores are simply removed - <value-of select="."/>.</report>
		
    </rule></pattern><pattern id="medicine-abstract-tests-pattern"><rule context="article[@article-type='research-article']//article-meta[article-categories/subj-group[@subj-group-type='heading']/subject[. = ('Medicine','Epidemiology and Global Health')] and contains(title-group[1]/article-title[1],': ')]/abstract[not(@abstract-type)]" id="medicine-abstract-tests">
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#medicine-abstract-conformance" test="sec" role="warning" id="medicine-abstract-conformance">[medicine-abstract-conformance] Medicine articles with a colon in their title should likely have a structured abstract. If there is no note in eJP about this, either the colon in the title is incorrect, or the abstract should be changed to a structured format.</assert>
      
    </rule></pattern><pattern id="medicine-abstract-tests-2-pattern"><rule context="article[@article-type='research-article']//article-meta[article-categories[not(subj-group[@subj-group-type='display-channel']/subject[lower-case(.)='feature article'])]/subj-group[@subj-group-type='heading']/subject[. = ('Medicine','Epidemiology and Global Health')] and history/date[@date-type='received' and @iso-8601-date]]/abstract[not(@abstract-type) and not(sec)]" id="medicine-abstract-tests-2">
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#medicine-abstract-conformance-2" test="parent::article-meta/history/date[@date-type='received']/@iso-8601-date lt '2021-04-05'" role="warning" id="medicine-abstract-conformance-2">[medicine-abstract-conformance-2] <value-of select="parent::article-meta/article-categories/subj-group[@subj-group-type='heading']/subject[. = ('Medicine','Epidemiology and Global Health')]"/> articles submitted after 4th April 2021 should have a structured abstract, but this one does not. eLife: please check this with Editorial if there are no related notes from eJP. Exeter: Please flag this to the eLife Production team.</assert>
      
    </rule></pattern><pattern id="abstract-children-tests-pattern"><rule context="front//abstract/*" id="abstract-children-tests">
      <let name="allowed-elems" value="('p','sec','title')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#abstract-child-test-1" test="local-name() = $allowed-elems" role="error" id="abstract-child-test-1">[abstract-child-test-1] <name/> is not allowed as a child of abstract.</assert>
    </rule></pattern><pattern id="abstract-sec-titles-pattern"><rule context="abstract[not(@abstract-type)]/sec" id="abstract-sec-titles">
      <let name="pos" value="count(ancestor::abstract/sec) - count(following-sibling::sec)"/>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-1" test="($pos = 1) and (title != 'Background:')" role="error" id="clintrial-conformance-1">[clintrial-conformance-1] First section title is '<value-of select="title"/>' - but the only allowed value is 'Background:'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-2" test="($pos = 2) and (title != 'Methods:')" role="error" id="clintrial-conformance-2">[clintrial-conformance-2] Second section title is '<value-of select="title"/>' - but the only allowed value is 'Methods:'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-3" test="($pos = 3) and (title != 'Results:')" role="error" id="clintrial-conformance-3">[clintrial-conformance-3] Third section title is '<value-of select="title"/>' - but the only allowed value is 'Results:'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-4" test="($pos = 4) and (title != 'Conclusions:')" role="error" id="clintrial-conformance-4">[clintrial-conformance-4] Fourth section title is '<value-of select="title"/>' - but the only allowed value is 'Conclusions:'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-5" test="($pos = 6) and (title != 'Clinical trial number:')" role="error" id="clintrial-conformance-5">[clintrial-conformance-5] Sixth section title is '<value-of select="title"/>' - but the only allowed value is 'Clinical trial number:'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-6" test="($pos = 5) and (title != 'Funding:')" role="error" id="clintrial-conformance-6">[clintrial-conformance-6] Fifth section title is '<value-of select="title"/>' - but the only allowed value is 'Funding:'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-7" test="child::sec" role="error" id="clintrial-conformance-7">[clintrial-conformance-7] Nested secs are not allowed in abstracts. Sec with the id <value-of select="@id"/> and title '<value-of select="title"/>' has child sections.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-conformance-8" test="matches(@id,'^abs[1-9]$')" role="error" id="clintrial-conformance-8">[clintrial-conformance-8] <name/> must have an @id in the format 'abs1'. <value-of select="@id"/> does not conform to this convention.</assert>
      
      <!-- temporarily doing pre and final versions -->
      

      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-clintrial-conformance-9" test="starts-with(lower-case(title),'clinical trial number') and not(descendant::related-object[@document-id-type='clinical-trial-number'])" role="error" id="final-clintrial-conformance-9">[final-clintrial-conformance-9] A section with the title <value-of select="title"/> in the abstract must have at least one related-object element that contains all the information related to the clinical trial. This one does not.</report>
    </rule></pattern><pattern id="abstract-sec-title-content-pattern"><rule context="abstract[not(@abstract-type)]/sec/title" id="abstract-sec-title-content">
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#struct-abs-title-1" test="*" role="error" id="struct-abs-title-1">[struct-abs-title-1] A title in a structured abstract cannot contain a child element. It should only contain text. This title with the content '<value-of select="."/>' has the following element(s): <value-of select="string-join(*/name(),'; ')"/>.</report>
      
    </rule></pattern><pattern id="clintrial-related-object-pattern"><rule context="abstract[not(@abstract-type) and sec]//related-object" id="clintrial-related-object">
      <let name="registries" value="'clinical-trial-registries.xml'"/>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-1" test="ancestor::sec[title = 'Clinical trial number:']" role="error" id="clintrial-related-object-1">[clintrial-related-object-1] <name/> in abstract must be placed in a section whose title is 'Clinical trial number:'</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-2" test="@source-type='clinical-trials-registry'" role="error" id="clintrial-related-object-2">[clintrial-related-object-2] <name/> must have an @source-type='clinical-trials-registry'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-3" test="@source-id!=''" role="error" id="clintrial-related-object-3">[clintrial-related-object-3] <name/> must have an @source-id with a non-empty value.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-4" test="@source-id-type='registry-name'" role="error" id="clintrial-related-object-4">[clintrial-related-object-4] <name/> must have an @source-id-type='registry-name'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-5" test="@document-id-type='clinical-trial-number'" role="error" id="clintrial-related-object-5">[clintrial-related-object-5] <name/> must have an @document-id-type='clinical-trial-number'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-6" test="@document-id[not(matches(.,'\p{Zs}'))]" role="error" id="clintrial-related-object-6">[clintrial-related-object-6] <name/> must have an @document-id with a value that does not contain a space character.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-7" test="@xlink:href[not(matches(.,'\p{Zs}'))]" role="error" id="clintrial-related-object-7">[clintrial-related-object-7] <name/> must have an @xlink:href with a value that does not contain a space character.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-8" test="@document-id = ." role="warning" id="clintrial-related-object-8">[clintrial-related-object-8] <name/> has an @document-id '<value-of select="@document-id"/>'. But this is not the text of the related-object, which is likely incorrect - <value-of select="."/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-9" test="matches(@id,'^RO[1-9]')" role="error" id="clintrial-related-object-9">[clintrial-related-object-9] <name/> must have an @id in the format 'RO1'. '<value-of select="@id"/>' does not conform to this convention.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-10" test="parent::p" role="error" id="clintrial-related-object-10">[clintrial-related-object-10] <name/> in abstract must be a child of a &lt;p&gt; element.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-11" test="some $x in document($registries)/registries/registry satisfies ($x/subtitle/string()=@source-id)" role="warning" id="clintrial-related-object-11">[clintrial-related-object-11] <name/> @source-id value should almost always be one of the subtitles of the Crossref clinical trial registries. "<value-of select="@source-id"/>" is not one of the following <value-of select="string-join(for $x in document($registries)/registries/registry return concat('&quot;',$x/subtitle/string(),'&quot; (',$x/doi/string(),')'),', ')"/>. Is that correct?</assert>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-12" test="@source-id='ClinicalTrials.gov' and not(@xlink:href=(concat('https://clinicaltrials.gov/study/',@document-id),concat('https://clinicaltrials.gov/show/',@document-id)))" role="error" id="clintrial-related-object-12">[clintrial-related-object-12] ClinicalTrials.gov trial links are in the format https://clinicaltrials.gov/show/{number}. This <name/> has the link '<value-of select="@xlink:href"/>', which based on the clinical trial registry (<value-of select="@source-id"/>) and @document-id (<value-of select="@document-id"/>) is not right. Either the xlink:href is wrong (should it be <value-of select="concat('https://clinicaltrials.gov/study/',@document-id)"/> instead?) or the @document-id value is wrong, or the @source-id value is incorrect (or all/some combination of these).</report>

      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-14" test="ends-with(@xlink:href,'.')" role="error" id="clintrial-related-object-14">[clintrial-related-object-14] <name/> has a @xlink:href attribute value which ends with a full stop, which is not correct - '<value-of select="@xlink:href"/>'.</report>

      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-15" test="ends-with(@document-id,'.')" role="error" id="clintrial-related-object-15">[clintrial-related-object-15] <name/> has an @document-id attribute value which ends with a full stop, which is not correct - '<value-of select="@document-id"/>'.</report>

      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-16" test="ends-with(.,'.')" role="error" id="clintrial-related-object-16">[clintrial-related-object-16] Content within <name/> element ends with a full stop, which is not correct - '<value-of select="."/>'.</report>
      
    </rule></pattern><pattern id="clintrial-related-object-p-pattern"><rule context="abstract[not(@abstract-type)]/sec[//related-object[@document-id-type='clinical-trial-number']]" id="clintrial-related-object-p">
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#clintrial-related-object-13" test="count(descendant::related-object[@document-id-type='clinical-trial-number']) gt 3" role="warning" id="clintrial-related-object-13">[clintrial-related-object-13] There are <value-of select="count(descendant::related-object)"/> clinical trial numbers tagged in the structured abstract, which seems like a large number. Please check that this is correct and has not been mistagged.</report>
      
    </rule></pattern><pattern id="abstract-word-count-pattern"><rule context="front//abstract[not(@abstract-type) and not(sec)]" id="abstract-word-count">
      <let name="p-words" value="string-join(child::p[not(starts-with(.,'DOI:') or starts-with(.,'Editorial note:'))],' ')"/>
	    <let name="count" value="count(tokenize(normalize-space(replace($p-words,'\p{P}','')),' '))"/>
	     
      
	     
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-abstract-word-count-restriction" test="($count gt 300)" role="warning" id="final-abstract-word-count-restriction">[final-abstract-word-count-restriction] The abstract contains <value-of select="$count"/> words, when the usual upper limit is 300. Abstracts with more than 280 words should be checked with the eLife Editorial team.</report>
	   </rule></pattern><pattern id="aff-tests-pattern"><rule context="article-meta/contrib-group/aff" id="aff-tests">
      
    <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h5tdf-aff-test-1" test="parent::contrib-group//contrib//xref/@rid = @id" role="error" id="aff-test-1">[aff-test-1] aff elements that are direct children of contrib-group must have an xref in that contrib-group pointing to them.</assert>
    </rule></pattern><pattern id="author-aff-tests-pattern"><rule context="article-meta/contrib-group[not(@*)]//aff" id="author-aff-tests">
      <let name="display" value="string-join(descendant::*[not(local-name()=('label','institution-id','institution-wrap','named-content'))],', ')"/>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hdxya-final-auth-aff-test-1" test="country" role="error" id="final-auth-aff-test-1">[final-auth-aff-test-1] Author affiliations must have a country. This one does not - <value-of select="$display"/>.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hzqn1-final-auth-aff-test-2" test="addr-line[named-content[@content-type='city']]" role="error" id="final-auth-aff-test-2">[final-auth-aff-test-2] Author affiliations must have a city. This one does not - <value-of select="$display"/></assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h60a2-final-auth-aff-test-3" test="institution[not(@*)] or institution-wrap[institution[not(@*)]]" role="error" id="final-auth-aff-test-3">[final-auth-aff-test-3] Author affiliations (&lt;aff&gt;) must include an &gt;institution&gt; tag. This one (with the id <value-of select="@id"/>) does not - <value-of select="$display"/></assert>
    </rule></pattern><pattern id="aff-institution-wrap-tests-pattern"><rule context="aff//institution-wrap" id="aff-institution-wrap-tests">
      <let name="display" value="string-join(parent::aff//*[not(local-name()=('label','institution-id','institution-wrap','named-content'))],', ')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hx5tv-aff-institution-wrap-test-1" test="institution-id and institution[not(@*)]" role="error" id="aff-institution-wrap-test-1">[aff-institution-wrap-test-1] If an affiliation has an institution wrap, then it must have both an institution-id and an institution. If there is no ROR for this institution, then it should be captured as a single institution element without institution-wrap. This institution-wrap does not have both elements - <value-of select="$display"/></assert>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h07qo-aff-institution-wrap-test-2" test="parent::aff" role="error" id="aff-institution-wrap-test-2">[aff-institution-wrap-test-2] institution-wrap must be a child of aff. This one has <value-of select="parent::*/name()"/> as its parent.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h07qo-aff-institution-wrap-test-3" test="text()" role="error" id="aff-institution-wrap-test-3">[aff-institution-wrap-test-3] institution-wrap cannot contain text. It can only contain elements.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hjf05-aff-institution-wrap-test-4" test="count(institution-id) = 1" role="error" id="aff-institution-wrap-test-4">[aff-institution-wrap-test-4] institution-wrap must contain 1 and only 1 institution-id elements. This one has <value-of select="count(institution-id)"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hfnxv-aff-institution-wrap-test-5" test="count(institution[not(@*)]) = 1" role="error" id="aff-institution-wrap-test-5">[aff-institution-wrap-test-5] institution-wrap must contain 1 and only 1 institution elements. This one has <value-of select="count(institution[not(@*)])"/>.</assert>
      
    </rule></pattern><pattern id="aff-institution-id-tests-pattern"><rule context="aff//institution-id" id="aff-institution-id-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h9fxi-aff-institution-id-test-1" test="@institution-id-type='ror'" role="error" id="aff-institution-id-test-1">[aff-institution-id-test-1] institution-id in aff must have the attribute institution-id-type="ror".</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hqr61-aff-institution-id-test-2" test="matches(.,'^https?://ror\.org/[a-z0-9]{9}$')" role="error" id="aff-institution-id-test-2">[aff-institution-id-test-2] institution-id in aff must a value which is a valid ROR id. '<value-of select="."/>' is not a valid ROR id.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h6qq5-aff-institution-id-test-3" test="*" role="error" id="aff-institution-id-test-3">[aff-institution-id-test-3] institution-id in aff cannot contain elements, only text (which is a valid ROR id). This one contains the following element(s): <value-of select="string-join(*/name(),'; ')"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hqr61-aff-institution-id-test-2" test="matches(.,'^http://')" role="error" id="aff-institution-id-test-4">[aff-institution-id-test-4] institution-id in aff must use the https protocol. This one uses http - '<value-of select="."/>'.</report>
      
    </rule></pattern><pattern id="gen-aff-tests-pattern"><rule context="aff" id="gen-aff-tests">
      <let name="display" value="string-join(descendant::*[not(local-name()=('label','institution-id','institution-wrap','named-content'))],', ')"/>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hxnmu-gen-aff-test-1" test="count(institution[not(@*)]) + count(institution-wrap/institution[not(@*)]) gt 1" role="error" id="gen-aff-test-1">[gen-aff-test-1] Affiliations cannot have more than 1 top level institutions. <value-of select="$display"/> has <value-of select="count(institution[not(@*)]) + count(institution-wrap/institution[not(@*)])"/>.</report>
    
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hg0km-gen-aff-test-2" test="count(institution[@content-type='dept']) + count(institution-wrap/institution[@content-type='dept']) ge 1" role="warning" id="gen-aff-test-2">[gen-aff-test-2] Affiliation has <value-of select="count(institution[@content-type='dept']) + count(institution-wrap/institution[@content-type='dept'])"/> department field(s) - <value-of select="$display"/>. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hnan2-gen-aff-test-3" test="count(label) gt 1" role="error" id="gen-aff-test-3">[gen-aff-test-3] Affiliations cannot have more than 1 label. <value-of select="$display"/> has <value-of select="count(label)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h2vgk-gen-aff-test-4" test="count(addr-line) gt 1" role="error" id="gen-aff-test-4">[gen-aff-test-4] Affiliations cannot have more than 1 addr-line elements. <value-of select="$display"/> has <value-of select="count(addr-line)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hvgj9-gen-aff-test-5" test="count(country) gt 1" role="error" id="gen-aff-test-5">[gen-aff-test-5] Affiliations cannot have more than 1 country elements. <value-of select="$display"/> has <value-of select="count(country)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hf1l4-gen-aff-test-6" test="text()" role="error" id="gen-aff-test-6">[gen-aff-test-6] aff elements cannot contain text. They can only contain elements (label, institution, addr-line, country). This one (<value-of select="@id"/>) contains the text '<value-of select="string-join(text(),'')"/>'</report>
    </rule></pattern><pattern id="aff-child-tests-pattern"><rule context="aff/*" id="aff-child-tests">
      <let name="allowed-elems" value="('label','institution','institution-wrap','addr-line','country')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hrsm6-aff-child-conformity" test="name()=$allowed-elems" role="error" id="aff-child-conformity">[aff-child-conformity] <value-of select="name()"/> is not allowed as a child of &lt;aff&gt;.</assert>
      
    </rule></pattern><pattern id="aff-ror-tests-pattern"><rule context="aff[institution-wrap/institution-id[@institution-id-type='ror']]" id="aff-ror-tests">
      <let name="ror" value="institution-wrap[1]/institution-id[@institution-id-type='ror'][1]"/>
      <let name="matching-ror" value="document($rors)//*:ror[*:id[@type='ror']=$ror]"/>
      <let name="display" value="string-join(descendant::*[not(local-name()=('label','institution-id','institution-wrap','named-content'))],', ')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hentg-aff-ror" test="exists($matching-ror)" role="warning" id="aff-ror">[aff-ror] Affiliation (<value-of select="$display"/>) has a ROR id - <value-of select="$ror"/> - but it does not look like a correct one.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#htfjl-aff-ror-name" test="exists($matching-ror) and not(contains(institution-wrap[1]/institution[1],$matching-ror/*:name))" role="warning" id="aff-ror-name">[aff-ror-name] Affiliation has a ROR id, but it does not contain the name of the institution as captured in the ROR data within its institution. Is that OK? ROR has '<value-of select="$matching-ror/*:name"/>', but the institution is <value-of select="institution-wrap[1]/institution[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hm6cn-aff-ror-city" test="(addr-line/named-content[@content-type='city'] or ancestor::contrib[@contrib-type='author' and not(ancestor::sub-article)]) and exists($matching-ror) and not(contains(addr-line[1]/named-content[@content-type='city'][1],$matching-ror/*:city[1]))" role="warning" id="aff-ror-city">[aff-ror-city] Affiliation has a ROR id, but its city is not the same one as in the ROR data. Is that OK? ROR has '<value-of select="$matching-ror/*:city"/>', but the affiliation city is <value-of select="addr-line[1]/named-content[@content-type='city'][1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hux4f-aff-ror-country" test="(country or ancestor::contrib[@contrib-type='author' and not(ancestor::sub-article)]) and exists($matching-ror) and not(contains(country[1],$matching-ror/*:country[1]))" role="warning" id="aff-ror-country">[aff-ror-country] Affiliation has a ROR id, but its country is not the same one as in the ROR data. Is that OK? ROR has '<value-of select="$matching-ror/*:country"/>', but the affiliation country is <value-of select="country[1]"/>.</report>
      
      <report test="$matching-ror[@status='withdrawn']" role="error" id="aff-ror-status">[aff-ror-status] Affiliation has a ROR id, but the ROR id's status is withdrawn. Withdrawn RORs should not be used. Should one of the following be used instead?: <value-of select="string-join(for $x in $matching-ror/*:relationships/* return concat('(',$x/name(),') ',$x/*:id,' ',$x/*:label),'; ')"/>.</report>
      
    </rule></pattern><pattern id="addr-line-parent-test-pattern"><rule context="addr-line" id="addr-line-parent-test">
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hjjnh-addr-line-parent" test="parent::aff" role="error" id="addr-line-parent">[addr-line-parent] <value-of select="name()"/> is not allowed as a child of &lt;<value-of select="parent::*[1]/local-name()"/>&gt;.</assert>
    </rule></pattern><pattern id="addr-line-child-tests-pattern"><rule context="addr-line/*" id="addr-line-child-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h1gbm-addr-line-child-1" test="name()='named-content'" role="error" id="addr-line-child-1">[addr-line-child-1] <value-of select="name()"/> is not allowed as a child of &lt;addr-line&gt;.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hoyaj-addr-line-child-2" test="(name()='named-content') and not(@content-type='city')" role="error" id="addr-line-child-2">[addr-line-child-2] <value-of select="name()"/> in &lt;addr-line&gt; must have the attribute content-type="city". <value-of select="."/> does not.</report>
    </rule></pattern><pattern id="funding-group-tests-pattern"><rule context="article-meta/funding-group" id="funding-group-tests">
		
		<assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#funding-group-test-1" test="count(funding-statement) = 1" role="error" id="funding-group-test-1">[funding-group-test-1] One funding-statement should be present in funding-group.</assert>
		
		<report see="https://elifeproduction.slab.com/posts/funding-3sv64358#funding-group-test-2" test="count(award-group) = 0" role="warning" id="funding-group-test-2">[funding-group-test-2] There is no funding for this article. Is this correct?</report>
		
	  <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#funding-group-test-3" test="(count(award-group) = 0) and (funding-statement!='No external funding was received for this work.')" role="warning" id="funding-group-test-3">[funding-group-test-3] Is this funding-statement correct? - '<value-of select="funding-statement"/>' Usually it should be 'No external funding was received for this work.'</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#funding-group-test-4" test="(count(award-group) != 0) and not(matches(funding-statement[1],'^The funders? had no role in study design, data collection,? and interpretation, or the decision to submit the work for publication\.(\sFor the purpose of Open Access, the authors have applied a CC BY public copyright license to any Author Accepted Manuscript version arising from this submission\.|\sOpen access funding provided by Max Planck Society\.)?$'))" role="warning" id="funding-group-test-4">[funding-group-test-4] Is the funding-statement correct? There are funders, but the statement is '<value-of select="funding-statement[1]"/>'. If there are funders it should usually be 'The funders had no role in study design, data collection and interpretation, or the decision to submit the work for publication.'</report>
    </rule></pattern><pattern id="wellcome-fund-statement-tests-pattern"><rule context="article-meta/funding-group[descendant::institution[matches(lower-case(.),'wellcome') and not(matches(lower-case(.),'burroughs'))]]/funding-statement" id="wellcome-fund-statement-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#wellcome-fund-statement" test="matches(lower-case(.),'for the purpose of open access, the authors have applied a cc by public copyright license to any author accepted manuscript version arising from this submission\.')" role="warning" id="wellcome-fund-statement">[wellcome-fund-statement] This article has Wellcome funding declared, but the funding statement does not end with "For the purpose of Open Access, the authors have applied a CC BY public copyright license to any Author Accepted Manuscript version arising from this submission." is that correct? The funding statement is currently <value-of select="."/>.</assert>
      
    </rule></pattern><pattern id="max-planck-fund-statement-tests-pattern"><rule context="article-meta/funding-group/funding-statement[not(contains(lower-case(.),'open access funding provided by max planck society'))]" id="max-planck-fund-statement-tests">
      <let name="corresp-authors" value="ancestor::article-meta/contrib-group[1]/contrib[@contrib-type='author' and @corresp='yes']"/>
      <let name="nested-affs" value="$corresp-authors//aff//institution"/>
      <let name="corresp-author-rids" value="$corresp-authors/xref[@ref-type='aff']/@rid"/>
      <let name="group-affs" value="ancestor::article-meta/contrib-group[1]/aff[@id=$corresp-author-rids]//institution"/>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#max-planck-fund-statement" test="some $aff in ($nested-affs,$group-affs) satisfies matches(lower-case($aff),'^max[\p{Zs}-]+plan[ck]+|\p{Zs}max[\p{Zs}-]+plan[ck]+')" role="warning" id="max-planck-fund-statement">[max-planck-fund-statement] This article has a corresponding author that is affiliated with a Max Planck Institute, but the funding statement does not contain the text 'Open access funding provided by Max Planck Society.' Should it? The funding statement currently reads: <value-of select="."/>.</report>
      
    </rule></pattern><pattern id="award-group-tests-pattern"><rule context="funding-group/award-group" id="award-group-tests">
	  <let name="id" value="@id"/>
	  <let name="institution" value="funding-source[1]/institution-wrap[1]/institution[1]"/>
		
		<assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-2" test="funding-source" role="error" id="award-group-test-2">[award-group-test-2] award-group must contain a funding-source.</assert>
	  
		<assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-3" test="principal-award-recipient" role="warning" id="award-group-test-3">[award-group-test-3] award-group should almost always contain a principal-award-recipient. If it is not clear which author(s) are associated with this funding, please query with the authors, and only leave it without an author if appropriate.</assert>
		
		<report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-4" test="count(award-id) gt 1" role="error" id="award-group-test-4">[award-group-test-4] award-group may contain one and only one award-id.</report>
		
		<assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-5" test="funding-source/institution-wrap" role="error" id="award-group-test-5">[award-group-test-5] funding-source must contain an institution-wrap.</assert>
		
		<report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-6" test="count(funding-source/institution-wrap/institution) = 0" role="error" id="award-group-test-6">[award-group-test-6] Every piece of funding must have an institution. &lt;award-group id="<value-of select="@id"/>"&gt; does not have one.</report>
	  
	  <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-8" test="count(funding-source/institution-wrap/institution) gt 1" role="error" id="award-group-test-8">[award-group-test-8] Every piece of funding must only have 1 institution. &lt;award-group id="<value-of select="@id"/>"&gt; has <value-of select="count(funding-source/institution-wrap/institution)"/> - <value-of select="string-join(funding-source/institution-wrap/institution,', ')"/>.</report>
	  
	</rule></pattern><pattern id="general-grant-doi-tests-pattern"><rule context="funding-group/award-group[award-id[not(@award-id-type='doi')] and funding-source/institution-wrap/institution-id[not(.=$grant-doi-exception-funder-ids)]]" id="general-grant-doi-tests">
      <let name="award-id" value="award-id"/>
      <let name="funder-id" value="funding-source/institution-wrap/institution-id"/>
      <let name="funder-entry" value="document($rors)//*:ror[*:id[@type='fundref']=$funder-id]"/>
      <let name="mints-grant-dois" value="$funder-entry/@grant-dois='yes'"/>
      <!-- Consider alternatives to exact match as this is no better than simply using Crossref's API -->
      <let name="grant-matches" value="if (not($mints-grant-dois)) then ()         else $funder-entry//*:grant[@award=$award-id]"/>
	  
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#grant-doi-test-1" test="$grant-matches" role="warning" id="grant-doi-test-1">[grant-doi-test-1] Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id"/>) which could potentially be replaced with a grant DOI. The following grant DOIs are possibilities: <value-of select="string-join(for $grant in $grant-matches return concat('https://doi.org/',$grant/@doi),'; ')"/>.</report>

      <!-- If the funder has minted 30+ grant DOIs but there isn't an exact match throw a warning -->
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#grant-doi-test-2" test="$mints-grant-dois and (count($funder-entry//*:grant) gt 29) and not($grant-matches)" role="warning" id="grant-doi-test-2">[grant-doi-test-2] Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id"/>). The award id hasn't exactly matched the details of a known grant DOI, but the funder is known to mint grant DOIs (for example in the format <value-of select="$funder-entry/descendant::*:grant[1]/@doi"/> for ID <value-of select="$funder-entry/descendant::*:grant[1]/@award"/>). Does the award ID in the article contain a number/string within it that can be used to find a match here: https://api.crossref.org/works?filter=type:grant,award.number:[insert-grant-number]</report>
      
	</rule></pattern><pattern id="general-funding-no-award-id-tests-pattern"><rule context="funding-group/award-group[not(award-id) and funding-source/institution-wrap/institution-id]" id="general-funding-no-award-id-tests">
      <let name="funder-id" value="funding-source/institution-wrap/institution-id"/>
      <let name="funder-entry" value="document($rors)//*:ror[*:id[@type='fundref']=$funder-id]"/>
      <let name="grant-doi-count" value="count($funder-entry//*:grant)"/>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#grant-doi-test-3" test="$grant-doi-count gt 29" role="warning" id="grant-doi-test-3">[grant-doi-test-3] Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has no award-id, but the funder is known to mint grant DOIs (for example in the format <value-of select="$funder-entry/descendant::*:grant[1]/@doi"/> for ID <value-of select="$funder-entry/descendant::*:grant[1]/@award"/>). Is there a missing grant DOI or award ID for this funding?</report>
    </rule></pattern><pattern id="wellcome-grant-doi-tests-pattern"><rule context="funding-group/award-group[award-id[not(@award-id-type='doi')] and funding-source/institution-wrap/institution-id=$wellcome-fundref-ids]" id="wellcome-grant-doi-tests">
      <let name="grants" value="document($rors)//*:ror[*:id[@type='fundref']=$wellcome-fundref-ids]/*:grant"/>
      <let name="award-id-elem" value="award-id"/>
      <let name="award-id" value="if (contains(lower-case($award-id-elem),'/z')) then replace(substring-before(lower-case($award-id-elem),'/z'),'[^\d]','')          else if (contains(lower-case($award-id-elem),'_z')) then replace(substring-before(lower-case($award-id-elem),'_z'),'[^\d]','')         else if (matches($award-id-elem,'[^\d]') and matches($award-id-elem,'\d')) then replace($award-id-elem,'[^\d]','')         else $award-id-elem"/> 
      <let name="grant-matches" value="if ($award-id='') then ()         else $grants[@award=$award-id]"/>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#wellcome-grant-doi-test-1" test="$grant-matches" role="warning" id="wellcome-grant-doi-test-1">[wellcome-grant-doi-test-1] Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>) which could potentially be replaced with a grant DOI. The following grant DOIs are possibilities: <value-of select="string-join(for $grant in $grant-matches return concat('https://doi.org/',$grant/@doi),'; ')"/>.</report>

      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#wellcome-grant-doi-test-2" test="$grant-matches" role="warning" id="wellcome-grant-doi-test-2">[wellcome-grant-doi-test-2] Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>). The award id hasn't exactly matched the details of a known grant DOI, but the funder is known to mint grant DOIs (for example in the format <value-of select="$grants[1]/@doi"/> for ID <value-of select="$grants[1]/@award"/>). Does the award ID in the article contain a number/string within it that can be used to find a match here: https://api.crossref.org/works?filter=type:grant,award.number:[insert-grant-number]</assert>
    </rule></pattern><pattern id="known-grant-funder-grant-doi-tests-pattern"><rule context="funding-group/award-group[award-id[not(@award-id-type='doi')] and funding-source/institution-wrap/institution-id=$known-grant-funder-fundref-ids]" id="known-grant-funder-grant-doi-tests">
      <let name="fundref-id" value="funding-source/institution-wrap/institution-id"/>
      <let name="grants" value="document($rors)//*:ror[*:id[@type='fundref']=$fundref-id]/*:grant"/>
      <let name="award-id-elem" value="award-id"/>
      <!-- Make use of custom function to try and account for variations within funder conventions -->
      <let name="award-id" value="e:alter-award-id($award-id-elem,$fundref-id)"/>
      <let name="grant-matches" value="if ($award-id='') then ()         else $grants[@award=$award-id]"/>
    
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#known-grant-funder-grant-doi-test-1" test="$grant-matches" role="warning" id="known-grant-funder-grant-doi-test-1">[known-grant-funder-grant-doi-test-1] Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>) which could potentially be replaced with a grant DOI. The following grant DOIs are possibilities: <value-of select="string-join(for $grant in $grant-matches return concat('https://doi.org/',$grant/@doi),'; ')"/>.</report>

      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#known-grant-funder-grant-doi-test-2" test="$grant-matches" role="warning" id="known-grant-funder-grant-doi-test-2">[known-grant-funder-grant-doi-test-2] Funding entry from <value-of select="funding-source/institution-wrap/institution"/> has an award-id (<value-of select="$award-id-elem"/>). The award id hasn't exactly matched the details of a known grant DOI, but the funder is known to mint grant DOIs (for example in the format <value-of select="$grants[1]/@doi"/> for ID <value-of select="$grants[1]/@award"/>). Does the award ID in the article contain a number/string within it that can be used to find a match here: https://api.crossref.org/works?filter=type:grant,award.number:[insert-grant-number]</assert>

    </rule></pattern><pattern id="award-id-tests-pattern"><rule context="funding-group/award-group/award-id" id="award-id-tests">
      <let name="id" value="parent::award-group/@id"/>
      <let name="funder-id" value="parent::award-group/descendant::institution-id[1]"/>
      <let name="funder-name" value="parent::award-group/descendant::institution[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-1" test="matches(.,',|;')" role="warning" id="award-id-test-1">[award-id-test-1] Funding entry with id <value-of select="$id"/> has a comma or semi-colon in the award id. Should this be separated out into several funding entries? - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-2" test="matches(.,'^\p{Zs}?[Nn][/]?[\.]?[Aa][.]?\p{Zs}?$')" role="error" id="award-id-test-2">[award-id-test-2] Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-3" test="matches(.,'^\p{Zs}?[Nn]one[\.]?\p{Zs}?$')" role="error" id="award-id-test-3">[award-id-test-3] Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-4" test="matches(.,'&amp;#x\d')" role="warning" id="award-id-test-4">[award-id-test-4] Award id contains what looks like a broken unicode - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-5" test="matches(.,'http[s]?://d?x?\.?doi.org/')" role="error" id="award-id-test-5">[award-id-test-5] Award id contains a DOI link - <value-of select="."/>. If the award ID is for a grant DOI it should contain the DOI without the https://... protocol (e.g. 10.37717/220020477).</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-6" test=". = preceding::award-id[parent::award-group/descendant::institution-id[1] = $funder-id]" role="error" id="award-id-test-6">[award-id-test-6] Funding entry has an award id - <value-of select="."/> - which is also used in another funding entry with the same institution ID. This must be incorrect. Either the funder ID or the award ID is wrong, or it is a duplicate that should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-7" test=". = preceding::award-id[parent::award-group/descendant::institution[1] = $funder-name]" role="error" id="award-id-test-7">[award-id-test-7] Funding entry has an award id - <value-of select="."/> - which is also used in another funding entry with the same funder name. This must be incorrect. Either the funder name or the award ID is wrong, or it is a duplicate that should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-id-test-8" test=". = preceding::award-id[parent::award-group[not(descendant::institution[1] = $funder-name) and not(descendant::institution-id[1] = $funder-id)]]" role="warning" id="award-id-test-8">[award-id-test-8] Funding entry has an award id - <value-of select="."/> - which is also used in another funding entry with a different funder. Has there been a mistake with the award id? If the grant was awarded jointly by two funders, then this capture is correct and should be retained.</report>
      
    </rule></pattern><pattern id="institution-wrap-tests-pattern"><rule context="article-meta//award-group//institution-wrap" id="institution-wrap-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#institution-id-test" test="institution-id[@institution-id-type=('FundRef','ror')]" role="warning" id="institution-id-test">[institution-id-test] Whenever possible, a funder should have an insitution id (either a ROR or doi from the open funder registry). (institution-id with an allowed institution-id-type is not present in institution-wrap).</assert>
      
    </rule></pattern><pattern id="institution-id-tests-pattern"><rule context="article//award-group//institution-wrap/institution-id" id="institution-id-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#institution-id-test-2" test="@institution-id-type=('ror','FundRef')" role="error" id="institution-id-test-2">[institution-id-test-2] <name/> element must have the attribute institution-id-type with a value of "ror" (or for older content "FundRef").</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#institution-id-test-3" test="normalize-space(.) != ''" role="error" id="institution-id-test-3">[institution-id-test-3] The funding entry for <value-of select="parent::institution-wrap/institution"/> has an empty <name/> element, which is not allowed.</assert>
      
        <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#institution-id-test-4" test="*" role="error" id="institution-id-test-4">[institution-id-test-4] The <name/> element in funding entry for <value-of select="parent::institution-wrap/institution"/> contains child element(s) (<value-of select="string-join(distinct-values(*/name()),', ')"/>) which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#institution-id-test-5" test="@institution-id-type='FundRef' and (normalize-space(.) != '') and not(matches(.,'^http[s]?://d?x?\.?doi.org/10.13039/\d*$'))" role="error" id="institution-id-test-5">[institution-id-test-5] <name/> element in funding entry for <value-of select="parent::institution-wrap/institution"/> has the institution-id-type 'fundref' and contains the following text - <value-of select="."/> - which is not a fundref doi.</report>

      <report test=".=('http://dx.doi.org/10.13039/100004440','http://dx.doi.org/10.13039/100028897','http://dx.doi.org/10.13039/501100009053','http://dx.doi.org/10.13039/501100013372','http://dx.doi.org/10.13039/501100020194','http://dx.doi.org/10.13039/501100021773','http://dx.doi.org/10.13039/501100023312','http://dx.doi.org/10.13039/501100024310')" role="warning" id="wellcome-institution-id-test">[wellcome-institution-id-test] <name/> element in funding entry for <value-of select="parent::institution-wrap/institution"/> is <value-of select="."/>. This is an uncommon funder - should the funder be listed as 'Wellcome Trust' (http://dx.doi.org/10.13039/100010269) instead.</report>
      
      <report test=".=('http://dx.doi.org/10.13039/100001003','http://dx.doi.org/10.13039/100008349','http://dx.doi.org/10.13039/100016133','http://dx.doi.org/10.13039/100017346','http://dx.doi.org/10.13039/100019718','http://dx.doi.org/10.13039/100020968','http://dx.doi.org/10.13039/501100001645','http://dx.doi.org/10.13039/501100008454','http://dx.doi.org/10.13039/501100014089')" role="warning" id="boehringer-institution-id-test">[boehringer-institution-id-test] Please check funding for <value-of select="parent::institution-wrap/institution"/> carefully, as there are numerous similarly named, but different insitutions (e.g. Boehringer Ingelheim Stiftung; Boehringer Ingelheim Fonds; Boehringer Ingelheim; Boehringer Ingelheim [insert-country-name]).</report>
      
    </rule></pattern><pattern id="institution-id-doi-tests-pattern"><rule context="article//award-group//institution-wrap/institution-id[@institution-id-type='doi']" id="institution-id-doi-tests">
      
      <assert test="@vocab='open-funder-registry'" role="error" id="institution-id-test-6">[institution-id-test-6] <name/> in funding must have a vocab="open-funder-registry" attribute. This one does not.</assert>
      
      <assert test="@vocab-identifier='10.13039/open-funder-registry'" role="error" id="institution-id-test-7">[institution-id-test-7] <name/> in funding must have a vocab-identifier="10.13039/open-funder-registry" attribute. This one does not.</assert>
      
    </rule></pattern><pattern id="funding-ror-tests-pattern"><rule context="funding-source[institution-wrap/institution-id[@institution-id-type='ror']]" id="funding-ror-tests">
      <let name="rors" value="'rors.xml'"/>
      <let name="ror" value="institution-wrap[1]/institution-id[@institution-id-type='ror'][1]"/>
      <let name="matching-ror" value="document($rors)//*:ror[*:id=$ror]"/>
      
      <assert test="exists($matching-ror)" role="error" id="funding-ror">[funding-ror] Funding (<value-of select="institution-wrap[1]/institution[1]"/>) has a ROR id - <value-of select="$ror"/> - but it does not look like a correct one.</assert>
        
      <report test="$matching-ror[@status='withdrawn']" role="error" id="funding-ror-status">[funding-ror-status] Funding has a ROR id, but the ROR id's status is withdrawn. Withdrawn RORs should not be used. Should one of the following be used instead?: <value-of select="string-join(for $x in $matching-ror/*:relationships/* return concat('(',$x/name(),') ',$x/*:id,' ',$x/*:label),'; ')"/>.</report>
      
    </rule></pattern><pattern id="par-tests-pattern"><rule context="funding-group//principal-award-recipient" id="par-tests">
      <let name="authors" value="for $x in ancestor::article//article-meta/contrib-group[1]/contrib[@contrib-type='author']         return if ($x/name) then e:get-name($x/name[1])         else if ($x/collab) then e:get-collab($x/collab[1])         else ''"/>
      <let name="par-text" value="if (name) then e:get-name(name[1])         else if (string-name) then string-name         else if (institution) then institution         else e:get-collab(collab[1])"/>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#par-test-1" test="normalize-space(.)='' and not(*)" role="error" id="par-test-1">[par-test-1] <name/> cannot be empty.</report>
      
      <assert test="$par-text = $authors" role="error" id="par-test-2">[par-test-2] Author name in funding section (<value-of select="$par-text"/>) does not match any of the author names in the author list: <value-of select="string-join($authors,', ')"/>.</assert>
      
    </rule></pattern><pattern id="multi-par-tests-pattern"><rule context="funding-group//principal-award-recipient[count(name) gt 1]" id="multi-par-tests">
      <let name="names" value="for $name in name return e:get-name($name)"/>
      <let name="indistinct-names" value="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      
      <assert test="empty($indistinct-names)" role="error" id="multi-par-test-1">[multi-par-test-1] Funding entry from <value-of select="ancestor::award-group[1]/funding-source[1]/descendant::institution[1]"/> has duplicate author names associated - <value-of select="string-join($indistinct-names,';')"/>.</assert>
      
    </rule></pattern><pattern id="par-name-tests-pattern"><rule context="funding-group//principal-award-recipient/name" id="par-name-tests">
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#par-name-test-1" test="contains(.,'.')" role="error" id="par-name-test-1">[par-name-test-1] Author name in funding entry contains a full stop - <value-of select="e:get-name(.)"/>. Please remove the full stop.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#par-name-test-2" test="surname or given-names" role="error" id="par-name-test-2">[par-name-test-2] name in principal-award-recipient cannot be empty.</assert>
      
    </rule></pattern><pattern id="kwd-group-tests-pattern"><rule context="article-meta/kwd-group[not(@kwd-group-type='research-organism')]" id="kwd-group-tests">
      
      <assert test="@kwd-group-type='author-keywords'" role="error" id="kwd-group-type">[kwd-group-type] kwd-group must have a @kwd-group-type 'research-organism', or 'author-keywords'.</assert>
      
      <assert test="kwd" role="warning" id="non-ro-kwd-presence-test">[non-ro-kwd-presence-test] kwd-group must contain at least one kwd</assert>
    </rule></pattern><pattern id="ro-kwd-group-tests-pattern"><rule context="article-meta/kwd-group[@kwd-group-type='research-organism']" id="ro-kwd-group-tests">
	  
      <assert test="title = 'Research organism'" role="error" id="kwd-group-title">[kwd-group-title] kwd-group title is <value-of select="title"/>, which is wrong. It should be 'Research organism'.</assert>
      
      <assert test="kwd" role="warning" id="ro-kwd-presence-test">[ro-kwd-presence-test] kwd-group must contain at least one kwd</assert>
	
	</rule></pattern><pattern id="ro-kwd-tests-pattern"><rule context="article-meta/kwd-group[@kwd-group-type='research-organism']/kwd" id="ro-kwd-tests">
      
      <assert test="substring(.,1,1) = upper-case(substring(.,1,1))" role="error" id="kwd-upper-case">[kwd-upper-case] research-organism kwd elements should start with an upper-case letter.</assert>
      
      <report test="*[local-name() != 'italic']" role="error" id="kwd-child-test">[kwd-child-test] research-organism keywords cannot have child elements such as <value-of select="*/local-name()"/>.</report>
      
      <report test="preceding-sibling::kwd = ." role="error" id="kwd-dupe-test">[kwd-dupe-test] research-organism keywords must be distinct. This one containing <value-of select="."/> is not.</report>
      
    </rule></pattern><pattern id="custom-meta-group-tests-pattern"><rule context="article-meta/custom-meta-group" id="custom-meta-group-tests">
      <let name="type" value="parent::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="($type = $research-subj) and not(count(custom-meta[@specific-use='meta-only'])=(1,2))" role="error" id="custom-meta-presence">[custom-meta-presence] Only 1 or 2 custom-meta[@specific-use='meta-only'] elements are permitted in custom-meta-group for <value-of select="$type"/>. This one has <value-of select="count(custom-meta[@specific-use='meta-only'])"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#features-custom-meta-presence" test="($type = $features-subj) and not(count(custom-meta[@specific-use='meta-only']) = (2,3))" role="error" id="features-custom-meta-presence">[features-custom-meta-presence] 2 or 3 custom-meta[@specific-use='meta-only'] must be present in custom-meta-group for <value-of select="$type"/>. This one has <value-of select="count(custom-meta[@specific-use='meta-only'])"/>.</report>
      
    </rule></pattern><pattern id="custom-meta-tests-pattern"><rule context="article-meta/custom-meta-group/custom-meta" id="custom-meta-tests">
      <let name="type" value="ancestor::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="pos" value="count(parent::custom-meta-group/custom-meta) - count(following-sibling::custom-meta)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-1" test="count(meta-name) = 1" role="error" id="custom-meta-test-1">[custom-meta-test-1] One meta-name must be present in custom-meta.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-2" test="($type = ($research-subj,$notice-article-types)) and not(meta-name = ('Author impact statement','publishing-route'))" role="error" id="custom-meta-test-2">[custom-meta-test-2] The value of meta-name can only be 'Author impact statement' or 'publishing-route'. Currently it is <value-of select="meta-name"/>.</report>
      
      <report test="($type = ($research-subj,$notice-article-types)) and ($pos=2) and  (meta-name != 'publishing-route')" role="error" id="custom-meta-test-17">[custom-meta-test-17] The value of the 2nd meta-name can only be 'publishing-route'. Currently it is <value-of select="meta-name"/>.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-3" test="count(meta-value) = 1" role="error" id="custom-meta-test-3">[custom-meta-test-3] One meta-value must be present in custom-meta.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-14" test="($type = $features-subj) and ($pos=1) and  (meta-name != 'Author impact statement')" role="error" id="custom-meta-test-14">[custom-meta-test-14] The value of the 1st meta-name can only be 'Author impact statement'. Currently it is <value-of select="meta-name"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-15" test="($type = $features-subj) and ($pos=2) and  (meta-name != 'Template')" role="error" id="custom-meta-test-15">[custom-meta-test-15] The value of the 2nd meta-name can only be 'Template'. Currently it is <value-of select="meta-name"/>.</report>
      
      <report test="($type = $features-subj) and ($pos=3) and  (meta-name != 'publishing-route')" role="error" id="custom-meta-test-18">[custom-meta-test-18] The value of the 3rd meta-name can only be 'publishing-route'. Currently it is <value-of select="meta-name"/>.</report>
      
    </rule></pattern><pattern id="meta-value-tests-pattern"><rule context="article-meta/custom-meta-group/custom-meta[meta-name='Author impact statement']/meta-value" id="meta-value-tests">
      <let name="subj" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="count" value="count(for $x in tokenize(normalize-space(replace(.,'\p{P}','')),' ') return $x)"/>
      <let name="we-token" value="substring-before(substring-after(lower-case(.),' we '),' ')"/>
      <let name="verbs" value="('name', 'named', 'can', 'progress', 'progressed', 'explain', 'explained', 'found', 'founded', 'present', 'presented', 'have', 'describe', 'described', 'showed', 'report', 'reported', 'miss', 'missed', 'identify', 'identified', 'better', 'bettered', 'validate', 'validated', 'use', 'used', 'listen', 'listened', 'demonstrate', 'demonstrated', 'argue', 'argued', 'will', 'assess', 'assessed', 'are', 'may', 'observe', 'observed', 'find', 'found', 'previously', 'should', 'rely', 'relied', 'reflect', 'reflected', 'recognise', 'recognised', 'attend', 'attended', 'first', 'define', 'defined', 'here', 'need', 'needed')"/>
      
      <report test="not(child::*) and normalize-space(.)=''" role="error" id="custom-meta-test-4">[custom-meta-test-4] The value of meta-value cannot be empty</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-5" test="($count gt 40)" role="warning" id="custom-meta-test-5">[custom-meta-test-5] Impact statement contains more than 40 words (<value-of select="$count"/>). This is not allowed.</report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-custom-meta-test-6" test="matches(.,'[\.|\?]$')" role="error" id="final-custom-meta-test-6">[final-custom-meta-test-6] Impact statement must end with a full stop or question mark.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-7" test="matches(replace(.,' et al\. ',' et al '),'[\p{L}][\p{L}]+\. .*$|[\p{L}\p{N}][\p{L}\p{N}]+\? .*$|[\p{L}\p{N}][\p{L}\p{N}]+! .*$')" role="warning" id="custom-meta-test-7">[custom-meta-test-7] Impact statement appears to be made up of more than one sentence. Please check, as more than one sentence is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-8" test="not($subj = 'Replication Study') and matches(.,'[:;]')" role="warning" id="custom-meta-test-8">[custom-meta-test-8] Impact statement contains a colon or semi-colon, which is likely incorrect. It needs to be a proper sentence.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-custom-meta-test-9" test="lower-case($subj)!='scientific correspondence' and matches(.,'[Ww]e show|[Ww]e present|[Tt]his (study|paper|work)| et al\.')" role="error" id="final-custom-meta-test-9">[final-custom-meta-test-9] Impact statement contains a possessive phrase. This is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-10" test="matches(.,'^[\d]+$')" role="error" id="custom-meta-test-10">[custom-meta-test-10] Impact statement is comprised entirely of numbers, which must be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-11" test="matches(.,' [Oo]ur |^[Oo]ur ')" role="warning" id="custom-meta-test-11">[custom-meta-test-11] Impact statement contains 'our'. Is this possessive langauge relating to the article or research itself (which should be removed)?</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-13" test="matches(.,' study ') and not(matches(.,'[Tt]his study'))" role="warning" id="custom-meta-test-13">[custom-meta-test-13] Impact statement contains 'study'. Is this a third person description of this article? If so, it should be changed to not include this.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-rep-study-custom-meta-test" test="($subj = 'Replication Study') and not(matches(.,'^Editors[\p{Po}] Summary: '))" role="error" id="final-rep-study-custom-meta-test">[final-rep-study-custom-meta-test] Impact statement in Replication studies must begin with 'Editors' summary: '. This does not - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-test-16" test="$we-token = $verbs" role="warning" id="custom-meta-test-16">[custom-meta-test-16] Impact statement contains 'we' followed by a verb - '<value-of select="concat('we ',$we-token)"/>' in '<value-of select="."/>'. Is this possessive language relating to the article or research itself (which should be removed)?</report>
    </rule></pattern><pattern id="meta-value-child-tests-pattern"><rule context="article-meta/custom-meta-group/custom-meta/meta-value/*" id="meta-value-child-tests">
      <let name="allowed-elements" value="('italic','sup','sub')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#custom-meta-child-test-1" test="local-name() = $allowed-elements" role="error" id="custom-meta-child-test-1">[custom-meta-child-test-1] <name/> is not allowed in impact statement.</assert>
      
    </rule></pattern><pattern id="featmeta-value-tests-pattern"><rule context="article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value" id="featmeta-value-tests">
      <let name="type" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feat-custom-meta-test-1" test="child::*" role="error" id="feat-custom-meta-test-1">[feat-custom-meta-test-1] <value-of select="child::*[1]/name()"/> is not allowed in a Template type meta-value.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feat-custom-meta-test-2" test=". = ('1','2','3','4','5')" role="error" id="feat-custom-meta-test-2">[feat-custom-meta-test-2] Template type meta-value must one of '1','2','3','4', or '5'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feat-custom-meta-test-info" test=". = ('1','2','3','4','5')" role="info" id="feat-custom-meta-test-info">[feat-custom-meta-test-info] Template <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feat-custom-meta-test-3" test="($type='Insight') and (. != '1')" role="error" id="feat-custom-meta-test-3">[feat-custom-meta-test-3] <value-of select="$type"/> must be a template 1. Currently it is a template <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feat-custom-meta-test-4" test="($type='Editorial') and (. != '2')" role="error" id="feat-custom-meta-test-4">[feat-custom-meta-test-4] <value-of select="$type"/> must be a template 2. Currently it is a template <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feat-custom-meta-test-5" test="($type='Feature Article') and not(.=('3','4','5'))" role="error" id="feat-custom-meta-test-5">[feat-custom-meta-test-5] <value-of select="$type"/> must be a template 3, 4, or 5. Currently it is a template <value-of select="."/>.</report>
      
    </rule></pattern><pattern id="schema-value-tests-pattern"><rule context="article-meta/custom-meta-group/custom-meta[meta-name='schema-version']/meta-value" id="schema-value-tests">
      
      <assert test=".='2.0.0'" role="error" id="schema-custom-meta-test-1">[schema-custom-meta-test-1] The meta-value element for schema-version must have a value of '2.0.0'.</assert>
      
    </rule></pattern><pattern id="elocation-id-tests-pattern"><rule context="article-meta/elocation-id" id="elocation-id-tests">
      <let name="article-id" value="parent::article-meta/article-id[@pub-id-type='publisher-id'][1]"/>
      <let name="is-prc" value="e:is-prc(.)"/>
      
      <report test="not($is-prc) and . != concat('e' , $article-id)" role="error" id="test-elocation-conformance">[test-elocation-conformance] elocation-id is incorrect. In non-PRC articles its value should be a concatenation of 'e' and the article id, in this case <value-of select="concat('e',$article-id)"/>. Currently it is <value-of select="."/>.</report>
      
      <report test="$is-prc and . != concat('RP' , $article-id)" role="error" id="test-elocation-conformance-prc">[test-elocation-conformance-prc] elocation-id is incorrect. In PRC articles its value should be a concatenation of 'RP' and the article id, in this case <value-of select="concat('RP',$article-id)"/>. Currently it is <value-of select="."/>.</report>
    </rule></pattern><pattern id="related-object-tests-pattern"><rule context="related-object" id="related-object-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#related-object-ancestor" test="ancestor::abstract[not(@abstract-type)] or parent::front-stub/parent::sub-article[@article-type='editor-report']" role="error" id="related-object-ancestor">[related-object-ancestor] <name/> is not allowed outside of the main abstract (abstract[not(@abstract-type)]) or in the front-stub for an editor's evaluation.</assert>
    </rule></pattern>
  
  <pattern id="volume-test-pattern"><rule context="article-meta/volume" id="volume-test">
      <let name="is-prc" value="e:is-prc(.)"/>
      <!-- @date-type='pub' included for legacy content -->
      <let name="pub-date" value=" if ($is-prc) then parent::article-meta/pub-history[1]/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]         else parent::article-meta/pub-date[@publication-format='electronic'][@date-type=('publication','pub')]/year[1]"/>
      
      <report test=".='' or (. != (number($pub-date) - 2011))" role="error" id="volume-test-1">[volume-test-1] Journal volume is incorrect. It should be <value-of select="number($pub-date) - 2011"/>.</report>
    </rule></pattern>

  <pattern id="equal-author-tests-pattern"><rule context="article-meta//contrib[@contrib-type='author']" id="equal-author-tests">
    	
    <report test="@equal-contrib='yes' and not(xref[matches(@rid,'^equal-contrib[0-9]$')])" role="error" id="equal-author-test-1">[equal-author-test-1] Equal authors must contain an xref[@ref-type='fn'] with an @rid that starts with 'equal-contrib' and ends in a digit.</report>
    
    <report test="xref[matches(@rid,'^equal-contrib[0-9]$')] and not(@equal-contrib='yes')" role="error" id="equal-author-test-2">[equal-author-test-2] author contains an xref[@ref-type='fn'] with a 'equal-contrib0' type @rid, but the contrib has no @equal-contrib='yes'.</report>
		
		</rule></pattern> 	
  
  <pattern id="p-tests-pattern"><rule context="p" id="p-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <!--<report test="not(matches(.,'^[\p{Lu}\p{N}\p{Ps}\p{S}\p{Pi}\p{Z}]')) and not(parent::list-item) and not(parent::td)"
        role="error" 
        id="p-test-1">p element begins with '<value-of select="substring(.,1,1)"/>'. Is this OK? Usually it should begin with an upper-case letter, or digit, or mathematic symbol, or open parenthesis, or open quote. Or perhaps it should not be the beginning of a new paragraph?</report>-->
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hxspa-p-test-2" test="@*" role="error" id="p-test-2">[p-test-2] p element must not have any attributes.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h2ua5-p-test-5" test="((ancestor::article/@article-type = ('article-commentary', 'discussion', 'editorial', 'research-article', 'review-article')) and ancestor::body[parent::article]) and (descendant::*[1]/local-name() = 'bold') and not(ancestor::caption) and not(descendant::*[1]/preceding-sibling::text()) and matches(descendant::bold[1],'\p{L}') and (descendant::bold[1] != 'Related research article')" role="warning" id="p-test-5">[p-test-5] p element starts with bolded text - <value-of select="descendant::*[1]"/> - Should it be a header?</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hu208-p-test-6" test="(ancestor::body[parent::article]) and (string-length(.) le 100) and not(parent::*[local-name() = ('list-item','fn','td','th')]) and (preceding-sibling::*[1]/local-name() = 'p') and (string-length(preceding-sibling::p[1]) le 100) and not($article-type = $notice-article-types) and not((count(*) = 1) and child::supplementary-material)" role="warning" id="p-test-6">[p-test-6] Should this be captured as a list-item in a list? p element is less than 100 characters long, and is preceded by another p element less than 100 characters long.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hbssk-p-test-7" test="matches(.,'^\p{Zs}?•') and not(ancestor::sub-article)" role="warning" id="p-test-7">[p-test-7] p element starts with a bullet point. It is very likely that this should instead be captured as a list-item in a list[@list-type='bullet']. - <value-of select="."/></report>
    </rule></pattern><pattern id="p-text-tests-pattern"><rule context="p[not(inline-formula or disp-formula or code)]" id="p-text-tests">
      <let name="text-tokens" value="for $x in tokenize(.,' ') return if (matches($x,'±[Ss][Dd]|±standard|±SEM|±S\.E\.M|±s\.e\.m|\+[Ss][Dd]|\+standard|\+SEM|\+S\.E\.M|\+s\.e\.m')) then $x else ()"/>
      
      <assert test="count($text-tokens) = 0" role="error" id="p-test-3">[p-test-3] p element contains <value-of select="string-join($text-tokens,', ')"/> - The spacing is incorrect.</assert>
      
      

      <report test="(count(descendant::*:inline-graphic) ge 1) and normalize-space(.)=''" role="error" id="final-p-test-8">[final-p-test-8] p element contains one or more inline-graphics and no other text, which is not permitted.</report>
    </rule></pattern><pattern id="p-child-tests-pattern"><rule context="article//p/*" id="p-child-tests">
      <let name="allowed-p-blocks" value="('bold', 'sup', 'sub', 'sc', 'italic', 'underline', 'xref','inline-formula', 'disp-formula','supplementary-material', 'code', 'ext-link', 'named-content', 'inline-graphic', 'monospace', 'related-object', 'table-wrap','styled-content')"/>
      
      <assert test="if (ancestor::sec[@sec-type='data-availability']) then self::*/local-name() = ($allowed-p-blocks,'element-citation')  else self::*/local-name() = $allowed-p-blocks" role="error" id="allowed-p-test">[allowed-p-test] p element cannot contain <value-of select="self::*/local-name()"/>. Only the following elements are allowed - <value-of select="string-join($allowed-p-blocks,', ')"/>.</assert>
    </rule></pattern><pattern id="xref-target-tests-pattern"><rule context="xref" id="xref-target-tests">
      <let name="rid" value="tokenize(@rid,' ')[1]"/>
      <let name="target" value="self::*/ancestor::article//*[@id = $rid]"/>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hkftz-aff-xref-target-test" test="(@ref-type='aff') and ($target/local-name() != 'aff')" role="error" id="aff-xref-target-test">[aff-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='fn') and ($target/local-name() != 'fn')" role="error" id="fn-xref-target-test">[fn-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-target-test" test="(@ref-type='fig') and ($target/local-name() != 'fig')" role="error" id="fig-xref-target-test">[fig-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-target-test" test="(@ref-type='video') and (($target/local-name() != 'media') or not($target/@mimetype='video'))" role="error" id="vid-xref-target-test">[vid-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' must point to a media[@mimetype="video"] element. Either this links to the incorrect location or the xref/@ref-type is incorrect.</report>
      
      <report test="(@ref-type='bibr') and ($target/local-name() != 'ref')" role="error" id="bibr-xref-target-test">[bibr-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supplementary-material-xref-target-test" test="(@ref-type='supplementary-material') and ($target/local-name() != 'supplementary-material')" role="error" id="supplementary-material-xref-target-test">[supplementary-material-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#other-xref-target-test" test="(@ref-type='other') and not($target/local-name() = 'award-group')" role="error" id="other-xref-target-test">[other-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-target-test" test="(@ref-type='table') and ($target/local-name() != 'table-wrap') and ($target/local-name() != 'table')" role="error" id="table-xref-target-test">[table-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-fn-xref-target-test" test="(@ref-type='table-fn') and ($target/local-name() != 'fn')" role="error" id="table-fn-xref-target-test">[table-fn-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#box-xref-target-test" test="(@ref-type='box') and ($target/local-name() != 'boxed-text')" role="error" id="box-xref-target-test">[box-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='sec') and ($target/local-name() != 'sec')" role="error" id="sec-xref-target-test">[sec-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='app') and ($target/local-name() != 'app')" role="error" id="app-xref-target-test">[app-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='decision-letter') and ($target/local-name() != 'sub-article')" role="error" id="decision-letter-xref-target-test">[decision-letter-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#disp-formula-xref-target-test" test="(@ref-type='disp-formula') and ($target/local-name() != 'disp-formula')" role="error" id="disp-formula-xref-target-test">[disp-formula-xref-target-test] xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <assert test="@ref-type = ('aff', 'fn', 'fig', 'video', 'bibr', 'supplementary-material', 'other', 'table', 'table-fn', 'box', 'sec', 'app', 'decision-letter', 'disp-formula')" role="error" id="xref-ref-type-conformance">[xref-ref-type-conformance] @ref-type='<value-of select="@ref-type"/>' is not allowed . The only allowed values are 'aff', 'fn', 'fig', 'video', 'bibr', 'supplementary-material', 'other', 'table', 'table-fn', 'box', 'sec', 'app', 'decision-letter', 'disp-formula'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#xref-target-conformance" test="boolean($target) = false()" role="error" id="xref-target-conformance">[xref-target-conformance] xref with @ref-type='<value-of select="@ref-type"/>' points to an element with an @id='<value-of select="$rid"/>', but no such element exists.</report>
    </rule></pattern><pattern id="body-xref-tests-pattern"><rule context="body//xref" id="body-xref-tests">
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#empty-xref-test" test="not(child::*) and normalize-space(.)=''" role="error" id="empty-xref-test">[empty-xref-test] Empty xref in the body is not allowed. Its position is here in the text - "<value-of select="concat(preceding-sibling::text()[1],'*Empty xref*',following-sibling::text()[1])"/>".</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#semi-colon-xref-test" test="ends-with(.,';') or ends-with(.,'; ')" role="error" id="semi-colon-xref-test">[semi-colon-xref-test] xref ends with semi-colon - '<value-of select="."/>' - which is incorrect. The semi-colon should be placed after the link as 'normal' text.</report>
      
    </rule></pattern><pattern id="ext-link-tests-pattern"><rule context="ext-link[@ext-link-type='uri']" id="ext-link-tests">
      <let name="formatting-elems" value="('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')"/>
      <let name="parent" value="parent::*[1]/local-name()"/>
      <let name="form-children" value="string-join(         for $x in child::* return if ($x/local-name()=$formatting-elems) then $x/local-name()         else ()         ,', ')"/>
      <let name="non-form-children" value="string-join(         for $x in child::* return if ($x/local-name()=$formatting-elems) then ()         else ($x/local-name())         ,', ')"/>
      
      <!-- Not entirely sure if this works 
           Removed for now as it seems not to work
      <assert test="@xlink:href castable as xs:anyURI" 
        role="error"
        id="broken-uri-test">Broken URI in @xlink:href</assert>-->
      
      <!-- Needs further testing. Presume that we want to ensure a url follows certain URI schemes. -->
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)\[\]+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')" role="warning" id="url-conformance-test">[url-conformance-test] @xlink:href doesn't look like a URL - '<value-of select="@xlink:href"/>'. Is this correct?</assert>
      
      <report test="matches(@xlink:href,'^(ftp|sftp)://\S+:\S+@')" role="warning" id="ftp-credentials-flag">[ftp-credentials-flag] @xlink:href contains what looks like a link to an FTP site which contains credentials (username and password) - '<value-of select="@xlink:href"/>'. If the link without credentials works (<value-of select="concat(substring-before(@xlink:href,'://'),'://',substring-after(@xlink:href,'@'))"/>), then please replace it with that and notify the authors that you have done so. If the link without credentials does not work, please query with the authors in order to obtain a link without credentials.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#htqb8-url-fullstop-report" test="matches(@xlink:href,'\.$')" role="error" id="url-fullstop-report">[url-fullstop-report] '<value-of select="@xlink:href"/>' - Link ends in a full stop which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hjtq3-url-space-report" test="matches(@xlink:href,'[\p{Zs}]')" role="error" id="url-space-report">[url-space-report] '<value-of select="@xlink:href"/>' - Link contains a space which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#himma-ext-link-parent-test" test="(matches(.,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%,_\+.~#?&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.') and $parent = $formatting-elems)" role="warning" id="ext-link-parent-test">[ext-link-parent-test] ext-link - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which almost certainly unnecessary.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h5vog-ext-link-child-test" test="(matches(.,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%,_\+.~#?&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.') and ($form-children!=''))" role="error" id="ext-link-child-test">[ext-link-child-test] ext-link - <value-of select="."/> - has a formatting child element - <value-of select="$form-children"/> - which is not correct.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hce3u-ext-link-child-test-2" test="$non-form-children=''" role="error" id="ext-link-child-test-2">[ext-link-child-test-2] ext-link - <value-of select="."/> - has a non-formatting child element - <value-of select="$non-form-children"/> - which is not correct.</assert>
      
      <report test="matches(.,'^[Dd][Oo][Ii]:|^[Dd][Oo][Ii]\p{Zs}')" role="warning" id="ext-link-child-test-4">[ext-link-child-test-4] ext-link text - <value-of select="."/> - appears to start with the string 'Doi:' or 'Doi ' (or similar), which is unnecessary.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#ext-link-child-test-5" test="contains(@xlink:href,'datadryad.org/review?')" role="warning" id="ext-link-child-test-5">[ext-link-child-test-5] ext-link looks like it points to a review dryad dataset - <value-of select="."/>. Should it be updated?</report>
      
      <report test="not(contains(@xlink:href,'datadryad.org/review?')) and not(matches(@*:href,'^https?://doi.org/')) and contains(@*:href,'datadryad.org')" role="error" id="ext-link-child-test-6">[ext-link-child-test-6] ext-link points to a dryad dataset, but it is not a DOI - <value-of select="@xlink:href"/>. Replace this with the Dryad DOI.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hyyhg-ext-link-text" test="(.!=@xlink:href) and matches(.,'https?:|ftp:|www\.')" role="warning" id="ext-link-text">[ext-link-text] The text for a URL is '<value-of select="."/>' (which looks like a URL), but it is not the same as the actual embedded link, which is '<value-of select="@xlink:href"/>'.</report>

      <report test="contains(lower-case(@xlink:href),'kriyadocs.com')" role="error" id="kriya-ext-link">[kriya-ext-link] URL contains 'kriyadocs.com', so it looks like a link to kriya which must be incorrect - <value-of select="@xlink:href"/>.</report>

      <report test="contains(lower-case(@xlink:href),'dropbox.com')" role="warning" id="dropbox-link">[dropbox-link] URL looks like it links to dropbox.com - Link: <value-of select="@xlink:href"/>. If this is the author's content, should it be uploaded instead to a trusted repository?</report>

      <report test="matches(@xlink:href,'^https?://(dx\.)?doi\.org/[^1][^0]?')" role="error" id="ext-link-doi-check">[ext-link-doi-check] Embedded URL within text starts with the DOI prefix, but it is not a valid doi - <value-of select="@xlink:href"/>.</report>

    <report test="not(ancestor::fig/permissions[contains(.,'phylopic')]) and matches(@xlink:href,'phylopic\.org')" role="warning" id="phylopic-link-check">[phylopic-link-check] This link is to phylopic.org, which is a site where silhouettes/images are typically reproduced from. Please check whether any figures contain reproduced images from this site, and if so whether permissions have been obtained and/or copyright statements are correctly included.</report>
    </rule></pattern><pattern id="software-heritage-tests-pattern"><rule context="ref/element-citation[ext-link[1][contains(@xlink:href,'softwareheritage')]]" id="software-heritage-tests">
      <let name="version" value="replace(substring-after(ext-link[1]/@xlink:href,'anchor='),'(;path=.*)?/$','')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/archiving-code-zrfi30c5#software-heritage-test-2" test="matches(ext-link[1]/@xlink:href,'.*swh:.:dir.*origin=.*visit=.*anchor=.*')" role="error" id="software-heritage-test-2">[software-heritage-test-2] Software heritage links in references must be the directory link with contextual information. '<value-of select="ext-link[1]/@xlink:href"/>' is not a directory link with contextual information.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/archiving-code-zrfi30c5#software-heritage-test-3" test="version[1]=$version" role="error" id="software-heritage-test-3">[software-heritage-test-3] The version number for Software heritage references must be the revision SWHID without contextual information. '<value-of select="version[1]"/>' is not. Based on the link, the version should be '<value-of select="$version"/>'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/archiving-code-zrfi30c5#software-heritage-test-5" test="contains(ext-link[1]/@xlink:href,'[…]')" role="error" id="software-heritage-test-5">[software-heritage-test-5] A Software heritage link contains '[…]', meaning that the link has been copied incorrectly (it is truncated, and cannot be followed).</report>
      
    </rule></pattern><pattern id="software-heritage-cite-tests-pattern"><rule context="article[descendant::ref[descendant::ext-link[1][contains(@xlink:href,'softwareheritage')]]]//xref[@ref-type='bibr']" id="software-heritage-cite-tests">
      <let name="rid" value="@rid"/>
      <let name="ref" value="ancestor::article//ref[descendant::ext-link[1][contains(@xlink:href,'softwareheritage')] and @id=$rid]"/>
      <let name="origin" value="lower-case(substring-before(substring-after($ref/descendant::ext-link[1]/@xlink:href,'origin='),';'))"/>
      
      <report see="https://elifeproduction.slab.com/posts/archiving-code-zrfi30c5#software-heritage-test-4" test="$ref and not(preceding::xref[@rid=$rid]) and not(some $x in preceding-sibling::ext-link[position() le 3] satisfies replace(lower-case($x/@xlink:href),'/$','') = $origin)" role="warning" id="software-heritage-test-4">[software-heritage-test-4] The first citation for a Software heritage reference should follow the original link for the software. This Software heritage citation (<value-of select="."/>) is for a reference which has '<value-of select="$origin"/>' as its origin URL, but there is no link preceding the citation with that same URL.</report>
      
    </rule></pattern><pattern id="ext-link-tests-2-pattern"><rule context="ext-link[@ext-link-type='uri' and not(ancestor::sec[@sec-type='data-availability']) and not(parent::element-citation) and not(ancestor::table-wrap) and string-length(.) gt 59]" id="ext-link-tests-2">
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#ho1mi-ext-link-length" test=". = @xlink:href" role="info" id="ext-link-length">[ext-link-length] Consider embedding long URLs in text instead of displaying in full, where appropriate. This is a very long URL - <value-of select="."/>.</report>
      
    </rule></pattern><pattern id="fig-group-tests-pattern"><rule context="fig-group" id="fig-group-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-group-test-1" test="count(child::fig[not(@specific-use='child-fig')]) = 1" role="error" id="fig-group-test-1">[fig-group-test-1] fig-group must have one and only one main figure.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-group-test-2" test="not(child::fig[@specific-use='child-fig']) and not(descendant::media[@mimetype='video'])" role="error" id="fig-group-test-2">[fig-group-test-2] fig-group does not contain a figure supplement or a figure-level video, which must be incorrect.</report>
      
    </rule></pattern><pattern id="fig-group-child-tests-pattern"><rule context="fig-group/*" id="fig-group-child-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-group-child-test-1" test="local-name() = ('fig','media')" role="error" id="fig-group-child-test-1">[fig-group-child-test-1] <name/> is not allowed as a child of fig-group.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-group-child-test-2" test="(local-name() = 'media') and not(@mimetype='video')" role="error" id="fig-group-child-test-2">[fig-group-child-test-2] <name/> which is a child of fig-group, must have an @mimetype='video' - i.e. only video type media is allowed as a child of fig-group.</report>
      
    </rule></pattern><pattern id="fig-tests-pattern"><rule context="fig[not(ancestor::sub-article)]" id="fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-test-2" test="@position" role="error" id="fig-test-2">[fig-test-2] fig must have a @position.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-test-3" test="not($article-type = ($features-article-types,$notice-article-types)) and not(label)" role="error" id="fig-test-3">[fig-test-3] fig must have a label.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#feat-fig-test-3" test="($article-type = $features-article-types) and not(label)" role="warning" id="feat-fig-test-3">[feat-fig-test-3] fig doesn't have a label. Is this correct?</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#final-fig-test-4" test="not($article-type = ('discussion',$notice-article-types)) and not(caption)" role="error" id="final-fig-test-4">[final-fig-test-4] <value-of select="label"/> has no title or caption (caption element).</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#final-fig-test-5" test="not($article-type = ('discussion',$notice-article-types)) and not(caption/title)" role="error" id="final-fig-test-5">[final-fig-test-5] fig caption must have a title.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-test-6" test="not($article-type = $notice-article-types) and (matches(@id,'^fig[0-9]{1,3}$') and not(caption/p))" role="warning" id="fig-test-6">[fig-test-6] Figure does not have a legend, which is very unorthodox. Is this correct?</report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#final-fig-test-7" test="graphic" role="error" id="final-fig-test-7">[final-fig-test-7] fig must have a graphic.</assert>
    </rule></pattern><pattern id="ar-fig-tests-pattern"><rule context="fig[ancestor::sub-article[@article-type=('reply','author-comment')]]" id="ar-fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(ancestor::body//fig)"/>
      <let name="pos" value="$count - count(following::fig)"/>
      <let name="no" value="substring-after(@id,'fig')"/>
      <let name="id-based-label" value="concat('Author response image ',$no,'.')"/>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#ar-fig-test-2" test="if ($article-type = ($features-article-types,$notice-article-types)) then ()         else not(label)" role="error" flag="dl-ar" id="ar-fig-test-2">[ar-fig-test-2] Author Response fig must have a label.</report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#final-ar-fig-test-3" test="graphic" role="error" id="final-ar-fig-test-3">[final-ar-fig-test-3] Author Response fig must have a graphic.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#final-ar-fig-position-test" test="$no = string($pos)" role="error" id="final-ar-fig-position-test">[final-ar-fig-position-test] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR images it is placed in position <value-of select="$pos"/>.</assert>

      <report test="matches(label[1],'^Author response image \d+\.$') and (label[1]!=$id-based-label)" role="error" id="ar-fig-position-label-test">[ar-fig-position-label-test] Author response image has the label '<value-of select="label"/>', but the figure number in its id (<value-of select="$no"/> in <value-of select="@id"/>) suggests the label should be '<value-of select="$id-based-label"/>'. Which is correct?</report>
    </rule></pattern><pattern id="graphic-tests-pattern"><rule context="graphic|inline-graphic" id="graphic-tests">
      <let name="link" value="@xlink:href"/>
      <let name="file" value="lower-case($link)"/>
      
      <report test="contains(@mime-subtype,'tiff') and not(matches($file,'\.tif$|\.tiff$'))" role="error" id="graphic-test-1">[graphic-test-1] <name/> has tif mime-subtype but filename does not end with '.tif' or '.tiff'. This cannot be correct.</report>
      
      <report test="contains(@mime-subtype,'postscript') and not(ends-with($file,'.eps'))" role="error" id="graphic-test-2">[graphic-test-2] <name/> has postscript mime-subtype but filename does not end with '.eps'. This cannot be correct.</report>
      
      <report test="contains(@mime-subtype,'jpeg') and not(matches($file,'\.jpg$|\.jpeg$'))" role="error" id="graphic-test-3">[graphic-test-3] <name/> has jpeg mime-subtype but filename does not end with '.jpg' or '.jpeg'. This cannot be correct.</report>
      
      <!-- Should this just be image? application included because during proofing stages non-web image files are referenced, e.g postscript -->
      <assert test="@mimetype=('image','application')" role="error" id="graphic-test-4">[graphic-test-4] <name/> must have a @mimetype='image' or 'application'.</assert>
      
      <assert test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,6}$')" role="error" id="graphic-test-5">[graphic-test-5] <name/> must have an @xlink:href which contains a file reference.</assert>
      
      <report test="preceding::graphic/@xlink:href = $link" role="error" id="graphic-test-6">[graphic-test-6] Image file for <value-of select="if (name()='inline-graphic') then 'inline-graphic' else replace(parent::fig/label,'\.','')"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="replace(preceding::graphic[@xlink:href=$link][1]/parent::fig/label,'\.','')"/>.</report>
      
      <report test="contains($link,'&amp;')" role="error" id="graphic-test-8">[graphic-test-8] Image file-name for <value-of select="if (name()='inline-graphic') then 'inline-graphic' else replace(parent::fig/label,'\.','')"/> contains an ampersand - <value-of select="tokenize($link,'/')[last()]"/>. Please rename the file so that this ampersand is removed.</report>
    </rule></pattern><pattern id="media-tests-pattern"><rule context="media" id="media-tests">
      <let name="file" value="@mime-subtype"/>
      <let name="link" value="@xlink:href"/>
      
      <assert test="@mimetype=('video','application','text','image', 'audio','chemical')" role="error" id="media-test-1">[media-test-1] media must have @mimetype, the value of which has to be one of 'video','application','text','image', or 'audio', 'chemical'.</assert>
      
      <assert test="@mime-subtype" role="error" id="media-test-2">[media-test-2] media must have @mime-subtype.</assert>
      
      <assert test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,15}$')" role="error" id="media-test-3">[media-test-3] media must have an @xlink:href which contains a file reference.</assert>
      
      <report test="if ($file='octet-stream') then ()         else if ($file = 'msword') then not(matches(@xlink:href,'\.doc[x]?$'))         else if ($file = 'gif') then not(matches(@xlink:href,'\.mp4$|\.gif$'))         else if ($file = 'excel') then not(matches(@xlink:href,'\.xl[s|t|m][x|m|b]?$'))         else if ($file='x-m') then not(ends-with(@xlink:href,'.m'))         else if ($file='tab-separated-values') then not(ends-with(@xlink:href,'.tsv'))         else if ($file='jpeg') then not(matches(@xlink:href,'\.[Jj][Pp][Gg]$'))         else if ($file='tiff') then not(matches(@xlink:href,'\.tiff?$'))         else if ($file='postscript') then not(matches(@xlink:href,'\.[Aa][Ii]$|\.[Pp][Ss]$'))         else if ($file='x-tex') then not(ends-with(@xlink:href,'.tex'))         else if ($file='x-gzip') then not(ends-with(@xlink:href,'.gz'))         else if ($file='html') then not(ends-with(@xlink:href,'.html'))         else if ($file='x-wav') then not(ends-with(@xlink:href,'.wav'))         else if ($file='x-aiff') then not(ends-with(@xlink:href,'.aiff'))         else if ($file='x-macbinary') then not(ends-with(@xlink:href,'.bin'))         else if ($file='x-pdb') then not(ends-with(@xlink:href,'.pdb'))         else if ($file='fasta') then not(ends-with(@xlink:href,'.fasta'))         else if (@mimetype='text') then not(matches(@xlink:href,'\.txt$|\.py$|\.xml$|\.sh$|\.rtf$|\.c$|\.for$|\.pl$'))         else not(ends-with(@xlink:href,concat('.',$file)))" role="warning" id="media-test-4">[media-test-4] media must have a file reference in @xlink:href which is equivalent to its @mime-subtype.</report>      
      
      <report test="matches(label[1],'[Aa]nimation') and not(@mime-subtype='gif')" role="error" id="media-test-5">[media-test-5] <value-of select="label"/> media with animation type label must have a @mime-subtype='gif'.</report>    
      
      <report test="matches(@xlink:href,'\.doc[x]?$|\.pdf$|\.xlsx$|\.xml$|\.xlsx$|\.mp4$|\.gif$')  and (@mime-subtype='octet-stream')" role="warning" id="media-test-6">[media-test-6] media has @mime-subtype='octet-stream', but the file reference ends with a recognised mime-type. Is this correct?</report>      
      
      <report test="if (child::label) then not(matches(label[1],'^Video \d{1,4}\.$|^Figure \d{1,4}—video \d{1,4}\.$|^Figure \d{1,4}—animation \d{1,4}\.$|^Table \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—figure \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—animation \d{1,4}\.$|^Appendix \d{1,4}—figure \d{1,4}—animation \d{1,4}\.$|^Animation \d{1,4}\.$|^Decision letter video \d{1,4}\.$|^Review video \d{1,4}\.$|^Author response video \d{1,4}\.$'))         else ()" role="error" id="media-test-7">[media-test-7] media label does not conform to eLife's usual label format - <value-of select="label[1]"/>.</report>
      
      <report test="if (ancestor::sec[@sec-type='supplementary-material']) then ()         else if (@mimetype='video') then (not(label))         else ()" role="error" id="media-test-8">[media-test-8] video does not contain a label, which is incorrect.</report>
      
      <report test="matches(lower-case(@xlink:href),'\.xml$|\.html$|\.json$')" role="error" id="media-test-9">[media-test-9] media points to an xml, html or json file. This cannot be handled by Kriya currently. Please download the file, place it in a zip and replace the file with this zip (otherwise the file will be erroneously overwritten before publication).</report>
      
      <report test="preceding::media/@xlink:href = $link" role="error" id="media-test-10">[media-test-10] Media file for <value-of select="if (@mimetype='video') then replace(label,'\.','') else replace(parent::*/label,'\.','')"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="if (preceding::media[@xlink:href=$link][1]/@mimetype='video') then replace(preceding::media[@xlink:href=$link][1]/label,'\.','')         else replace(preceding::media[@xlink:href=$link][1]/parent::*/label,'\.','')"/>.</report>
      
      <report test="contains($link,'&amp;')" role="error" id="media-test-11">[media-test-11] Media filename for <value-of select="if (@mimetype='video') then replace(label,'\.','') else replace(parent::*/label,'\.','')"/> contains an ampersand - <value-of select="tokenize($link,'/')[last()]"/>. Please rename the file so that this ampersand is removed.</report>
      
      <report test="text()" role="error" id="media-test-12">[media-test-12] Media element cannot contain text. This one has <value-of select="string-join(text(),'')"/>.</report>
      
      <report test="not(@mimetype='video') and *" role="error" id="media-test-13">[media-test-13] Media element that is not a mimetype="video" cannot contain elements. This one has the following element(s) <value-of select="string-join(*/name(),'; ')"/>.</report>
    </rule></pattern><pattern id="file-extension-tests-pattern"><rule context="graphic[@xlink:href]|media[@xlink:href]" id="file-extension-tests">
      
      <assert test="matches(@xlink:href,'\.[a-z0-9]+$')" role="error" id="file-extension-conformance">[file-extension-conformance] The file extenstion for a file must be in lower case. This <name/> element has an xlink:href which does not end with a lowercase file extension (<value-of select="tokenize(@xlink:href,'\.')[last()]"/> in <value-of select="@xlink:href"/>).</assert>
      
    </rule></pattern><pattern id="video-test-pattern"><rule context="media[child::label]" id="video-test">
      
      
      
      <report test="not(ancestor::sub-article) and not(caption/title)" role="error" id="final-video-title">[final-video-title] <value-of select="replace(label,'\.$,','')"/> does not have a title, which is incorrect.</report>
      
      <report test="ancestor::sub-article and not(caption/title)" role="warning" id="final-video-title-sa">[final-video-title-sa] <value-of select="replace(label,'\.$,','')"/> does not have a title, which is incorrect.</report>
      
    </rule></pattern><pattern id="supplementary-material-tests-pattern"><rule context="supplementary-material" id="supplementary-material-tests">
      <let name="link" value="media[1]/@xlink:href"/>
      <let name="file" value="if (contains($link,'.')) then lower-case(tokenize($link,'\.')[last()]) else ()"/>
      <let name="code-files" value="('m','py','lib','jl','c','sh','for','cpproj','ipynb','mph','cc','rmd','nlogo','stan','wrl','pl','r','fas','ijm','llb','ipf','mdl','h')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-1" test="label" role="error" id="supplementary-material-test-1">[supplementary-material-test-1] supplementary-material must have a label.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-2" test="not(matches(label[1],'Transparent reporting form|MDAR checklist')) and not(caption)" role="warning" id="supplementary-material-test-2">[supplementary-material-test-2] <value-of select="label"/> is missing a title/caption - is this correct? (supplementary-material should have a child caption.)</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#final-supplementary-material-test-3" test="if (caption) then not(caption/title)         else ()" role="warning" id="final-supplementary-material-test-3">[final-supplementary-material-test-3] <value-of select="label"/> doesn't have a title. Is this correct?</report>
      
      		
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#final-supplementary-material-test-5" test="media" role="error" id="final-supplementary-material-test-5">[final-supplementary-material-test-5] <value-of select="label"/> is missing a file (supplementary-material must have a media).</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-6" test="matches(label[1],'^Inclusion in global research form$|^MDAR checklist$|^Transparent reporting form$|^Figure \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source data \d{1,4}\.$|^Table \d{1,4}—source data \d{1,4}\.$|^Video \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—source code \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source code \d{1,4}\.$|^Table \d{1,4}—source code \d{1,4}\.$|^Video \d{1,4}—source code \d{1,4}\.$|^Supplementary file \d{1,4}\.$|^Source data \d{1,4}\.$|^Source code \d{1,4}\.$|^Reporting standard \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—figure supplement \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—table \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—video \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—figure supplement \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—table \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—video \d{1,4}—source code \d{1,4}\.$|^Audio file \d{1,4}\.$|^Box \d{1,3}—figure \d{1,4}—source data \d{1,4}\.$')" role="error" id="supplementary-material-test-6">[supplementary-material-test-6] supplementary-material label (<value-of select="label"/>) does not conform to eLife's usual label format.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-7" test="(ancestor::sec[@sec-type='supplementary-material']) and (media[@mimetype='video'])" role="error" id="supplementary-material-test-7">[supplementary-material-test-7] supplementary-material in additional files sections cannot have a media element with the attribute mimetype='video'. This should be mimetype='application'</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-8" test="matches(label[1],'^Inclusion in global research form$|^MDAR checklist$|^Transparent reporting form$|^Supplementary file \d{1,4}\.$|^Source data \d{1,4}\.$|^Source code \d{1,4}\.$|^Reporting standard \d{1,4}\.$') and not(ancestor::sec[@sec-type='supplementary-material'])" role="error" id="supplementary-material-test-8">[supplementary-material-test-8] <value-of select="label"/> has an article level label but it is not captured in the additional files section - This must be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-9" test="count(media) gt 1" role="error" id="supplementary-material-test-9">[supplementary-material-test-9] <value-of select="label"/> has <value-of select="count(media)"/> media elements which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-10" test="matches(label[1],'^Reporting standard \d{1,4}\.$')" role="warning" id="supplementary-material-test-10">[supplementary-material-test-10] Article contains <value-of select="label"/> Please check with eLife - is this actually a reporting standard?</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#source-code-test-1" test="($file = $code-files) and not(matches(label[1],'[Ss]ource code \d{1,4}\.$'))" role="warning" id="source-code-test-1">[source-code-test-1] <value-of select="label"/> has a file which looks like code - <value-of select="$link"/>, but it's not labelled as code.</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-test-11" test="contains(lower-case(caption[1]/title[1]),'key resource')" role="warning" id="supplementary-material-test-11">[supplementary-material-test-11] <value-of select="if (self::*/label) then replace(label,'\.$','') else self::*/local-name()"/> has a title '<value-of select="caption[1]/title[1]"/>'. Is it a Key resources table? If so, it should be captured as a table in an appendix for the article.</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#source-code-test-2" test="contains(label[1],'ource code') and not(($file=('tar','gz','zip','tgz','rar')))" role="warning" id="source-code-test-2">[source-code-test-2] Source code files should always be zipped. The file type for <value-of select="if (self::*/label) then replace(label,'\.$','') else self::*/local-name()"/> is '<value-of select="$file"/>'. Please zip this file, and replace it with the zipped version.</report>
      
      <report test="not(ancestor::article/@article-type='correction') and not(parent::p/parent::caption/parent::*[name()=('fig','table-wrap','media')]         or parent::sec[@sec-type='supplementary-material'])" role="error" id="supp-mat-placement">[supp-mat-placement] supplementary-material must be either a child of a caption p for a fig, table or video, or it must be plaed in the additional files section (sec[@sec-type='supplementary-material']). This one with the label <value-of select="label[1]"/> is not.</report>
    </rule></pattern><pattern id="box-supp-tests-pattern"><rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]//supplementary-material/label" id="box-supp-tests"> 
      <let name="fig-label" value="replace(ancestor::fig[1]/label,'\.$','')"/>
      
      <assert test="matches(.,concat('^',$fig-label,'—(source data \d|source code \d)\.$'))" role="error" id="box-fig-sup-test-1">[box-fig-sup-test-1] label for supplementary-material for a fig inside boxed-text must begin with the label from its parent fig. '<value-of select="."/>' is not in one of the following formats: '<value-of select="concat($fig-label,'—source data 0')"/>' or '<value-of select="concat($fig-label,'—source code 0')"/>'.</assert>
    </rule></pattern><pattern id="back-supplementary-file-tests-pattern"><rule context="sec[@sec-type='supplementary-material']/supplementary-material[contains(label[1],'upplementary file')]" id="back-supplementary-file-tests">
      <let name="pos" value="count(parent::*/supplementary-material[contains(label[1],'upplementary file')]) - count(following::supplementary-material[contains(label[1],'upplementary file')])"/>
      <let name="no" value="substring-after(@id,'supp')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#back-supplementary-file-position" test="string($pos) = $no" role="error" id="back-supplementary-file-position">[back-supplementary-file-position] <value-of select="replace(label,'\.$','')"/> id ends with <value-of select="$no"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is mislabelled, the id is incorrect, or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#back-supplementary-file-id" test="matches(@id,'^supp\d{1,2}$')" role="error" id="back-supplementary-file-id">[back-supplementary-file-id] The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. Supplementary files need to have ids in the format 'supp0'.</assert>
      
    </rule></pattern><pattern id="back-source-data-tests-pattern"><rule context="sec[@sec-type='supplementary-material']/supplementary-material[contains(label[1],'ource data')]" id="back-source-data-tests">
      <let name="pos" value="count(parent::*/supplementary-material[contains(label[1],'ource data')]) - count(following-sibling::supplementary-material[contains(label[1],'ource data')])"/>
      <let name="no" value="substring-after(@id,'sdata')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#back-source-data-position" test="string($pos) = $no" role="error" id="back-source-data-position">[back-source-data-position] <value-of select="replace(label,'\.$','')"/> id ends with <value-of select="$no"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is mislabelled, the id is incorrect, or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#back-source-data-id" test="matches(@id,'^sdata\d{1,2}$')" role="error" id="back-source-data-id">[back-source-data-id] The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. Source data need to have ids in the format 'sdata0'.</assert>
      
    </rule></pattern><pattern id="back-source-code-tests-pattern"><rule context="sec[@sec-type='supplementary-material']/supplementary-material[contains(label[1],'ource code')]" id="back-source-code-tests">
      <let name="pos" value="count(parent::*/supplementary-material[contains(label[1],'ource code')]) - count(following-sibling::supplementary-material[contains(label[1],'ource code')])"/>
      <let name="no" value="substring-after(@id,'scode')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#back-source-code-position" test="string($pos) = $no" role="error" id="back-source-code-position">[back-source-code-position] <value-of select="replace(label,'\.$','')"/> id ends with <value-of select="$no"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is mislabelled, the id is incorrect, or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#back-source-code-id" test="matches(@id,'^scode\d{1,2}$')" role="error" id="back-source-code-id">[back-source-code-id] The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. Source code needs to have ids in the format 'scode0'.</assert>
      
    </rule></pattern><pattern id="source-data-specific-tests-pattern"><rule context="supplementary-material[(ancestor::fig) or (ancestor::media) or (ancestor::table-wrap)]" id="source-data-specific-tests">
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-data-test-1" test="matches(label[1],'^Figure \d{1,4}—source data \d{1,4}|^Appendix \d{1,4}—figure \d{1,4}—source data \d{1,4}') and (count(descendant::xref[@ref-type='fig'])=1) and (descendant::xref[(@ref-type='fig') and contains(.,'upplement')])" role="warning" id="fig-data-test-1">[fig-data-test-1] <value-of select="label"/> is figure level source data, but contains 1 figure citation which is a link to a figure supplement - should it be figure supplement level source data?</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-code-test-1" test="matches(label[1],'^Figure \d{1,4}—source code \d{1,4}|^Appendix \d{1,4}—figure \d{1,4}—source code \d{1,4}') and (count(descendant::xref[@ref-type='fig'])=1) and (descendant::xref[(@ref-type='fig') and contains(.,'upplement')])" role="warning" id="fig-code-test-1">[fig-code-test-1] <value-of select="label"/> is figure level source code, but contains 1 figure citation which is a link to a figure supplement - should it be figure supplement level source code?</report>
      
    </rule></pattern><pattern id="fig-source-data-tests-pattern"><rule context="fig//supplementary-material[not(ancestor::media) and contains(label[1],' data ')]" id="fig-source-data-tests">
      <let name="label" value="label[1]"/>
      <let name="fig-id" value="ancestor::fig[1]/@id"/>
      <let name="fig-label" value="replace(ancestor::fig[1]/label[1],'\.$','')"/>
      <let name="number" value="number(replace(substring-after($label,' data '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::fig[1]//supplementary-material[contains(label[1],' data ')])"/>
      <let name="pos" value="$sibling-count - count(following::supplementary-material[(ancestor::fig[1]/@id=$fig-id) and contains(label[1],' data ')])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-data-test-2" test="$number = $pos" role="error" id="fig-data-test-2">[fig-data-test-2] '<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-data-id" test="@id=concat($fig-id,'sdata',$pos)" role="error" id="fig-data-id">[fig-data-id] The id for figure level source data must be the id of its ancestor fig, followed by 'sdata', followed by its position relative to other source data for the same figure. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($fig-id,'sdata',$pos)"/>' instead.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-data-label" test="$label = concat($fig-label,'—source data ',$pos,'.')" role="error" id="fig-data-label">[fig-data-label] Figure source data label (<value-of select="$label"/>) is incorrect based on its position. Either it has been placed under the wrong figure or the label is incorrect. Should the label be <value-of select="concat($fig-label,'—source data ',$pos,'.')"/> instead?</assert>
    </rule></pattern><pattern id="fig-source-code-tests-pattern"><rule context="fig//supplementary-material[not(ancestor::media) and contains(label[1],' code ')]" id="fig-source-code-tests">
      <let name="label" value="label[1]"/>
      <let name="fig-id" value="ancestor::fig[1]/@id"/>
      <let name="fig-label" value="replace(ancestor::fig[1]/label[1],'\.$','')"/>
      <let name="number" value="number(replace(substring-after($label,' code '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::fig[1]//supplementary-material[contains(label[1],' code ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::fig[1]/@id=$fig-id) and contains(label[1],' code ')])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-code-test-2" test="$number = $pos" role="error" id="fig-code-test-2">[fig-code-test-2] '<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-code-id" test="@id=concat($fig-id,'scode',$pos)" role="error" id="fig-code-id">[fig-code-id] The id for figure level source code must be the id of its ancestor fig, followed by 'scode', followed by its position relative to other source data for the same figure. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($fig-id,'scode',$pos)"/>' instead.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#fig-code-label" test="$label = concat($fig-label,'—source code ',$pos,'.')" role="error" id="fig-code-label">[fig-code-label] Figure source data label (<value-of select="$label"/>) is incorrect based on its position. Either it has been placed under the wrong figure or the label is incorrect. Should the label be <value-of select="concat($fig-label,'—source code ',$pos,'.')"/> instead?</assert>
      
    </rule></pattern><pattern id="vid-source-data-tests-pattern"><rule context="media//supplementary-material[not(ancestor::fig) and contains(label[1],' data ')]" id="vid-source-data-tests">
      <let name="label" value="label[1]"/>
      <let name="vid-id" value="ancestor::media[1]/@id"/>
      <let name="vid-label" value="replace(ancestor::media[1]/label[1],'\.$','')"/>
      <let name="number" value="number(replace(substring-after($label,' data '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::media[1]//supplementary-material[contains(label[1],' data ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::media[1]/@id=$vid-id) and contains(label[1],' data ')])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#vid-data-test-2" test="$number = $pos" role="error" id="vid-data-test-2">[vid-data-test-2] '<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#vid-data-id" test="@id=concat($vid-id,'sdata',$pos)" role="error" id="vid-data-id">[vid-data-id] The id for video level source data must be the id of its ancestor video, followed by 'sdata', followed by its position relative to other source data for the same video. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($vid-id,'sdata',$pos)"/>' instead.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#vid-data-label" test="$label = concat($vid-label,'—source data ',$pos,'.')" role="error" id="vid-data-label">[vid-data-label] Video source data label (<value-of select="$label"/>) is incorrect based on its position. Either it has been placed under the wrong video or the label is incorrect. Should the label be <value-of select="concat($vid-label,'—source data ',$pos,'.')"/> instead?</assert>
    </rule></pattern><pattern id="vid-source-code-tests-pattern"><rule context="media//supplementary-material[not(ancestor::fig) and contains(label[1],' code ')]" id="vid-source-code-tests">
      <let name="label" value="label[1]"/>
      <let name="vid-id" value="ancestor::media[1]/@id"/>
      <let name="vid-label" value="replace(ancestor::media[1]/label[1],'\.$','')"/>
      <let name="number" value="number(replace(substring-after($label,' code '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::media[1]//supplementary-material[contains(label[1],' code ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::media[1]/@id=$vid-id) and contains(label[1],' code ')])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#vid-code-test-2" test="$number = $pos" role="error" id="vid-code-test-2">[vid-code-test-2] '<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#vid-code-id" test="@id=concat($vid-id,'scode',$pos)" role="error" id="vid-code-id">[vid-code-id] The id for video level source code must be the id of its ancestor video, followed by 'scode', followed by its position relative to other source data for the same video. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($vid-id,'scode',$pos)"/>' instead.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#vid-code-label" test="$label = concat($vid-label,'—source code ',$pos,'.')" role="error" id="vid-code-label">[vid-code-label] Video source code label (<value-of select="$label"/>) is incorrect based on its position. Either it has been placed under the wrong video or the label is incorrect. Should the label be <value-of select="concat($vid-label,'—source code ',$pos,'.')"/> instead?</assert>
    </rule></pattern><pattern id="table-source-data-tests-pattern"><rule context="table-wrap//supplementary-material[contains(label[1],' data ')]" id="table-source-data-tests">
      <let name="label" value="label[1]"/>
      <let name="table-id" value="ancestor::table-wrap[1]/@id"/>
      <let name="table-label" value="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/>
      <let name="number" value="number(replace(substring-after($label,' data '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::table-wrap[1]//supplementary-material[contains(label[1],' data ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::table-wrap[1]/@id=$table-id) and contains(label[1],' data ')])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#table-data-test-2" test="$number = $pos" role="error" id="table-data-test-2">[table-data-test-2] '<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#table-data-id" test="@id=concat($table-id,'sdata',$pos)" role="error" id="table-data-id">[table-data-id] The id for table level source data must be the id of its ancestor table-wrap, followed by 'sdata', followed by its position relative to other source data for the same table. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($table-id,'sdata',$pos)"/>' instead.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#table-data-label" test="$label = concat($table-label,'—source data ',$pos,'.')" role="error" id="table-data-label">[table-data-label] Table source data label (<value-of select="$label"/>) is incorrect based on its position. Either it has been placed under the wrong table or the label is incorrect. Should the label be <value-of select="concat($table-label,'—source data ',$pos,'.')"/> instead?</assert>
      
    </rule></pattern><pattern id="table-source-code-tests-pattern"><rule context="table-wrap//supplementary-material[contains(label[1],' code ')]" id="table-source-code-tests">
      <let name="label" value="label[1]"/>
      <let name="table-id" value="ancestor::table-wrap[1]/@id"/>
      <let name="table-label" value="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/>
      <let name="number" value="number(replace(substring-after($label,' code '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::table-wrap[1]//supplementary-material[contains(label[1],' code ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::table-wrap[1]/@id=$table-id) and contains(label[1],' code ')])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#table-code-test-2" test="$number = $pos" role="error" id="table-code-test-2">[table-code-test-2] '<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#table-code-id" test="@id=concat($table-id,'scode',$pos)" role="error" id="table-code-id">[table-code-id] The id for table level source code must be the id of its ancestor table, followed by 'scode', followed by its position relative to other source data for the same table. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($table-id,'scode',$pos)"/>' instead.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#table-code-label" test="$label = concat($table-label,'—source code ',$pos,'.')" role="error" id="table-code-label">[table-code-label] Table source code label (<value-of select="$label"/>) is incorrect based on its position. Either it has been placed under the wrong table or the label is incorrect. Should the label be <value-of select="concat($table-label,'—source code ',$pos,'.')"/> instead?</assert>
      
    </rule></pattern><pattern id="disp-formula-tests-pattern"><rule context="disp-formula" id="disp-formula-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#disp-formula-test-2" test="mml:math or alternatives/mml:math" role="error" id="disp-formula-test-2">[disp-formula-test-2] disp-formula must contain an mml:math element.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#disp-formula-test-3" test="parent::p" role="warning" id="disp-formula-test-3">[disp-formula-test-3] In the vast majority of cases disp-formula should be a child of p. <value-of select="label"/> is a child of <value-of select="parent::*/local-name()"/>. Is that correct?</assert>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#disp-formula-test-4" test="parent::p[not(parent::boxed-text[label]) and not(preceding-sibling::*[1]/name()='list')] and not(preceding-sibling::*) and (not(preceding-sibling::text()) or normalize-space(preceding-sibling::text()[1])='') and not(ancestor::list)" role="warning" id="disp-formula-test-4">[disp-formula-test-4] disp-formula should very rarely be placed as the first child of a p element with no content before it (ie. &lt;p&gt;&lt;disp-formula ...). Either capture it at the end of the previous paragraph or capture it as a child of <value-of select="parent::p/parent::*/local-name()"/></report>
    </rule></pattern><pattern id="inline-formula-tests-pattern"><rule context="inline-formula" id="inline-formula-tests">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <assert see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#inline-formula-test-1" test="mml:math or alternatives/mml:math" role="error" id="inline-formula-test-1">[inline-formula-test-1] inline-formula must contain an mml:math element.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#inline-formula-test-2" test="not($pre-text/following-sibling::*[1]/local-name()='disp-formula') and matches($pre-text,'[\p{L}\p{N}\p{M}]$')" role="warning" id="inline-formula-test-2">[inline-formula-test-2] There is no space between inline-formula and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),descendant::mml:math[1])"/> - Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#inline-formula-test-3" test="not($post-text/preceding-sibling::*[1]/local-name()='disp-formula') and matches($post-text,'^[\p{L}\p{N}\p{M}]')" role="warning" id="inline-formula-test-3">[inline-formula-test-3] There is no space between inline-formula and the following text - <value-of select="concat(descendant::mml:math[1],substring($post-text,1,15))"/> - Is this correct?</report>
      
      <assert see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#inline-formula-test-4" test="parent::p or parent::td or parent::th or parent::title" role="error" id="inline-formula-test-4">[inline-formula-test-4] <name/> must be a child of p, td, th or title. The formula containing <value-of select="."/> is a child of <value-of select="parent::*/local-name()"/></assert>
    </rule></pattern><pattern id="math-tests-pattern"><rule context="mml:math" id="math-tests">
      <let name="data" value="replace(normalize-space(.),'\p{Zs}','')"/>
      <let name="children" value="string-join(for $x in .//*[(local-name()!='mo') and (local-name()!='mn') and (normalize-space(.)!='')] return $x/local-name(),'')"/>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-1" test="$data = ''" role="error" id="math-test-1">[math-test-1] mml:math must not be empty.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-2" test="descendant::mml:merror" role="error" id="math-test-2">[math-test-2] math contains an mml:merror with '<value-of select="descendant::mml:merror[1]/*"/>'. This will almost certainly not render correctly.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-14" test="not(matches($data,'^±$|^±[\d]+$|^±[\d]+\.[\d]+$|^×$|^~$|^~[\d]+$|^~[\d]+\.[\d]+$|^%[\d]+$|^%[\d]+\.[\d]+$|^%$|^±\d+%$|^+\d+%$|^-\d+%$|^\d+%$|^±\d+$|^+\d+$|^-\d+$')) and ($children='')" role="warning" id="math-test-14">[math-test-14] mml:math only contains numbers and/or operators - '<value-of select="$data"/>'. Is it necessary for this to be set as a formula, or can it be captured with as normal text instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-3" test="$data = '±'" role="error" id="math-test-3">[math-test-3] mml:math only contains '±', which is unnecessary. Capture this as a normal text '±' instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-4" test="matches($data,'^±[\d]+$|^±[\d]+\.[\d]+$')" role="error" id="math-test-4">[math-test-4] mml:math only contains '±' followed by digits, which is unnecessary. Capture this as a normal text instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-5" test="$data = '×'" role="error" id="math-test-5">[math-test-5] mml:math only contains '×', which is unnecessary. Capture this as a normal text '×' instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-6" test="$data = '~'" role="error" id="math-test-6">[math-test-6] mml:math only contains '~', which is unnecessary. Capture this as a normal text '~' instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-7" test="matches($data,'^~[\d]+$|^~[\d]+\.[\d]+$')" role="error" id="math-test-7">[math-test-7] mml:math only contains '~' and digits, which is unnecessary. Capture this as a normal text instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-8" test="$data = 'μ'" role="warning" id="math-test-8">[math-test-8] mml:math only contains 'μ', which is likely unnecessary. Should this be captured as a normal text 'μ' instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-9" test="matches($data,'^[\d]+%$|^[\d]+\.[\d]+%$|^%$')" role="error" id="math-test-9">[math-test-9] mml:math only contains '%' and digits, which is unnecessary. Capture this as a normal text instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-12" test="matches($data,'^%$')" role="error" id="math-test-12">[math-test-12] mml:math only contains '%', which is unnecessary. Capture this as a normal text instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-10" test="$data = '°'" role="error" id="math-test-10">[math-test-10] mml:math only contains '°', which is likely unnecessary. This should be captured as a normal text '°' instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-11" test="contains($data,'○')" role="warning" id="math-test-11">[math-test-11] mml:math contains '○' (the white circle symbol). Should this be the degree symbol instead - '°', or '∘' (the ring operator symbol)?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-13" test="not(descendant::mml:msqrt) and not(descendant::mml:mroot) and not(descendant::mml:mfrac) and matches($data,'^±\d+%$|^+\d+%$|^-\d+%$|^\d+%$|^±\d+$|^+\d+$|^-\d+$')" role="warning" id="math-test-13">[math-test-13] mml:math only contains '<value-of select="."/>', which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-15" test="matches($data,'^Na[2]?\+$|^Ca2\+$|^K\+$|^Cu[2]?\+$|^Ag\+$|^Hg[2]?\+$|^H\+$|^Mg2\+$|^Ba2\+$|^Pb2\+$|^Fe2\+$|^Co2\+$|^Ni2\+$|^Mn2\+$|^Zn2\+$|^Al3\+$|^Fe3\+$|^Cr3\+$')" role="warning" id="math-test-15">[math-test-15] mml:math seems to only contain the formula for a cation - '<value-of select="."/>' - which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-16" test="matches($data,'^H\-$|^Cl\-$|^Br\-$|^I\-$|^OH\-$|^NO3\-$|^NO2\-$|^HCO3\-$|^HSO4\-$|^CN\-$|^MnO4\-$|^ClO[3]?\-$|^O2\-$|^S2\-$|^SO42\-$|^SO32\-$|^S2O32\-$|^SiO32\-$|^CO32\-$|^CrO42\-$|^Cr2O72\-$|^N3\-$|^P3\-$|^PO43\-$')" role="warning" id="math-test-16">[math-test-16] mml:math seems to only contain the formula for an anion - '<value-of select="."/>' - which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-17" test="child::mml:msqrt and matches($data,'^±\d+%$|^+\d+%$|^-\d+%$|^\d+%$|^±\d+$|^+\d+$|^-\d+$')" role="warning" id="math-test-17">[math-test-17] mml:math only contains number(s) and square root symbol(s) '<value-of select="."/>', which is likely unnecessary. Should this be captured as normal text instead? Such as <value-of select="concat('√',.)"/>?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-18" test="ancestor::abstract" role="warning" id="math-test-18">[math-test-18] abstract contains MathML (<value-of select="."/>). Is this necessary? MathML in abstracts may not render downstream, so if it can be represented using normal text/unicode, then please do so instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-test-19" test="descendant::mml:mi[(.='') and preceding-sibling::*[1][(local-name() = 'mi') and matches(.,'[A-Za-z]')] and following-sibling::*[1][(local-name() = 'mi') and matches(.,'[A-Za-z]')]]" role="warning" id="math-test-19">[math-test-19] Maths containing '<value-of select="."/>' has what looks like words or terms which need separating with a space. With it's current markup the space will not be preserved on the eLife website. Please add in the space(s) using the latext '\;' in the appropriate place(s), so that the space is preserved in the HTML.</report>
      
      <report test="matches(.,'\p{Zs}\p{Zs}\p{Zs}\p{Zs}+$') and not(matches(.,'\s\s\s\s+$'))" role="error" id="math-test-20">[math-test-20] <value-of select="parent::*/name()"/> ends with 4 or more spaces. These types of spaces may cause the equation to break over numerous lines in the HTML or shift the equation to the left. Please ensure they are removed.</report>
      
      <report test="matches(.,'^\p{Zs}\p{Zs}\p{Zs}\p{Zs}+') and not(matches(.,'^\s\s\s\s+'))" role="error" id="math-test-21">[math-test-21] <value-of select="parent::*/name()"/> starts with 4 or more spaces. These types of spaces may cause the equation to break over numerous lines in the HTML or shift the equation to the right. Please ensure they are removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#math-broken-unicode-test" test="matches(.,'(&amp;|§|§amp;)(#x?\d)?|[^\p{L}\p{N}][gl]t;')" role="warning" id="math-broken-unicode-test">[math-broken-unicode-test] Equation likely contains a broken unicode - <value-of select="."/>.</report>
    </rule></pattern><pattern id="math-descendant-tests-pattern"><rule context="mml:math//*[contains(@class,'font') and matches(.,'[A-Za-z]')]" id="math-descendant-tests">
      
      <assert test="@mathvariant" role="error" id="math-descendant-test-1">[math-descendant-test-1] Equation has character(s) - <value-of select="."/> - which have a font in a class element - <value-of select="@class"/> - but the element does not have a mathvariant attribute. This means that while the font will display in the PDF, it will not display on continuum. Either it needs a mathvariant attribute, or the specific unicode for that character in the script/font should be used.</assert>
      
    </rule></pattern><pattern id="mrow-tests-pattern"><rule context="mml:mrow" id="mrow-tests">
      
      <report test="not(*) and (normalize-space(.)='')" role="error" id="final-mrow-test-1">[final-mrow-test-1] mrow cannot be empty.</report>
      
    </rule></pattern><pattern id="math-overset-tests-pattern"><rule context="mml:mover" id="math-overset-tests">
      
      <report test="mml:mo='−'" role="warning" id="math-overset-bar-test">[math-overset-bar-test] <value-of select="ancestor::*[name()=('disp-formula','inline-formula')]/name()"/> contains character(s) that are overset by a minus sign (<value-of select="."/>). Has the latex \overset{}{} function been used, and should the \bar{} function (or \overline{} if covering numerous characters) be used instead?</report>
      
      <report test="(mml:mtext or mml:mi) and not(mml:mo or */mml:mo)" role="warning" id="math-overset-missing-test">[math-overset-missing-test] <value-of select="ancestor::*[name()=('disp-formula','inline-formula')]/name()"/> contains character(s) that have possibly missing character(s) directly above them (<value-of select="."/>). Has the \overset{}{} function been used, and if so should the appropriate equivalent latex function be used instead (such as \bar{}, \tilde{}, \dot{}, or \hat{})?</report>
      
    </rule></pattern><pattern id="math-mi-tests-pattern"><rule context="mml:mi" id="math-mi-tests">
      
      <report test="matches(.,'^\p{Zs}$')" role="error" id="math-mi-space-test">[math-mi-space-test] <name/> element contains only spaces. Has "\" been used for space in the tex editor, instead of "\,"?</report>
      
    </rule></pattern><pattern id="math-empty-child-tests-pattern"><rule context="mml:msub|mml:msup|mml:msubsup|mml:munder|mml:mover|mml:munderover" id="math-empty-child-tests">
      <let name="script-name" value="if (./local-name() = 'msub') then 'subscript'                                      else if (./local-name() = 'msup') then 'superscript'                                      else if (./local-name() = 'msubsup') then 'subscript'                                      else if (./local-name() = 'munder') then 'underscript'                                      else if (./local-name() = 'mover') then 'overscript'                                      else if (./local-name() = 'munderover') then 'underscript'                                      else 'second'"/>
      
      <report test="*[1][matches(.,'^\p{Z}*$')]" role="warning" id="math-empty-base-check">[math-empty-base-check] <name/> element should not have a missing or empty base expression.</report>

      <report test="*[2][matches(.,'^\p{Z}*$')]" role="error" id="math-empty-script-check">[math-empty-script-check] <name/> element must not have a missing or empty <value-of select="$script-name"/> expression.</report>

      <report test="local-name()=('msubsup','munderover') and *[3][matches(.,'^\p{Z}*$')]" role="error" id="math-empty-second-script-check">[math-empty-second-script-check] <name/> element must not have a missing or empty <value-of select="if (local-name()='msubsup') then 'superscript' else 'overscript'"/> expression.</report>
      
    </rule></pattern><pattern id="math-multiscripts-tests-pattern"><rule context="mml:mmultiscripts" id="math-multiscripts-tests">
      <!-- REVIST: should we allow mml:none here? -->
      <let name="empty-exceptions" value="('mprescripts','mrow','none')"/>    

      <assert test="count(*) ge 3" role="error" id="math-multiscripts-check-1">[math-multiscripts-check-1] <name/> element must at least 3 child elements. This one has <value-of select="count(*)"/>.</assert>

      <report test="*[not(local-name()=$empty-exceptions) and not(child::*) and normalize-space(.)='']" role="error" id="math-multiscripts-check-2">[math-multiscripts-check-2] <name/> element must not have an empty child element (with the following exceptions: <value-of select="string-join($empty-exceptions,'; ')"/>). This <name/> has <value-of select="count(*[not(local-name()=$empty-exceptions) and not(child::*) and normalize-space(.)=''])"/> empty child elements - <value-of select="string-join(distinct-values(*[not(local-name()=$empty-exceptions) and not(child::*) and normalize-space(.)='']/name()),';')"/>.</report>

      <assert test="mml:mprescripts" role="error" id="math-multiscripts-check-3">[math-multiscripts-check-3] <name/> element must have a child mml:mprescripts element. If the expressions are all correct, then a more conventional math element (e.g. mml:msub) should be used to capture this content.</assert>

    </rule></pattern><pattern id="tex-math-tests-pattern"><rule context="tex-math" id="tex-math-tests">
      <!-- Strip the document commands from the start and end -->
      <let name="document-stripped-text" value="replace(.,'^\\begin\{document.|\\end\{document.$','')"/>
      <!-- Remove the formula commands to find the actual expression -->
      <let name="formula-text" value="replace($document-stripped-text,'^\$\$|\$\$$','')"/>
      
      <assert test="parent::alternatives" role="error" id="tex-math-test-1">[tex-math-test-1] <name/> element is not allowed as a child of <value-of select="parent::*/name()"/>. It can only be captured as a child of alternatives.</assert>
      
      <assert test="starts-with(.,'\begin{document}')" role="error" id="tex-math-test-2">[tex-math-test-2] Content of <name/> element must start with '\begin{document}'. This one doesn't - <value-of select="."/></assert>
      
      <assert test="ends-with(.,'\end{document}')" role="error" id="tex-math-test-3">[tex-math-test-3] Content of <name/> element must end with '\end{document}'. This one doesn't - <value-of select="."/></assert>
      
      <report test="ancestor::disp-formula and (not(starts-with($document-stripped-text,'$$')) or not(ends-with($document-stripped-text,'$$')))" role="error" id="tex-math-test-4">[tex-math-test-4] If <name/> element is a descendant of disp-formula then the expression must be wrapped in two dollar signs, i.e. $$insert-formula-here$$. This one isn't - <value-of select="."/></report>
      
      <report test="ancestor::inline-formula and ((not(starts-with($document-stripped-text,'$')) or not(ends-with($document-stripped-text,'$'))) or starts-with($document-stripped-text,'$$') or ends-with($document-stripped-text,'$$'))" role="error" id="tex-math-test-5">[tex-math-test-5] If <name/> element is a descendant of inline-formula then the expression must be wrapped in single dollar signs, i.e. $insert-formula-here$. This one isn't - <value-of select="."/></report>
      
      <report test="ancestor::disp-formula and not(contains($formula-text,'\displaystyle'))" role="warning" id="tex-math-test-6">[tex-math-test-6] <name/> element in a disp-formula does not contain the \displaystyle command. Is that correct? <value-of select="$formula-text"/></report>
      
      <report test="ancestor::inline-formula and contains($formula-text,'\displaystyle')" role="warning" id="tex-math-test-7">[tex-math-test-7] <name/> element is in an inline-formula, and yet it contains the \displaystyle command. Is that correct? - <value-of select="."/></report>
      
      <report test="tokenize($formula-text,'\\?\\?\\(begin|end).array.')[(position() mod 2 = 0) and not(contains(.,'\\') or contains(.,'&amp;'))]" role="warning" id="tex-math-test-8">[tex-math-test-8] <name/> contains an array without horizontal or vertical spacing - <value-of select="string-join(tokenize($formula-text,'\\?\\?\\(begin|end).array.')[(position() mod 2 = 0) and not(contains(.,'\\') or contains(.,'&amp;'))],' ---- ')"/></report>
    </rule></pattern><pattern id="disp-formula-child-tests-pattern"><rule context="disp-formula/*" id="disp-formula-child-tests">
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#disp-formula-child-test-1" test="not(local-name()=('label','math','alternatives'))" role="error" id="disp-formula-child-test-1">[disp-formula-child-test-1] <name/> element is not allowed as a child of disp-formula.</report>
    </rule></pattern><pattern id="inline-formula-child-tests-pattern"><rule context="inline-formula/*" id="inline-formula-child-tests">
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#inline-formula-child-test-1" test="not(local-name()=('math','alternatives'))" role="error" id="inline-formula-child-test-1">[inline-formula-child-test-1] <name/> element is not allowed as a child of inline-formula.</report>
    </rule></pattern><pattern id="alternatives-tests-pattern"><rule context="alternatives" id="alternatives-tests">
      
      <assert test="parent::inline-formula or parent::disp-formula" role="error" id="alternatives-test-1">[alternatives-test-1] <name/> element is not allowed as a child of <value-of select="parent::*/name()"/>.</assert>
    </rule></pattern><pattern id="math-alternatives-tests-pattern"><rule context="alternatives[parent::inline-formula or parent::disp-formula]" id="math-alternatives-tests">
      
      <assert test="mml:math and tex-math" role="error" id="math-alternatives-test-1">[math-alternatives-test-1] <name/> element should ony be used in a formula if there is both a MathML representation and a LaTeX representation of the content. There is not both a child mml:math and tex-math element.</assert>
    </rule></pattern><pattern id="alternatives-child-tests-pattern"><rule context="alternatives/*" id="alternatives-child-tests">
      
      <report test="not(local-name()=('math','tex-math'))" role="error" id="alternatives-child-test-1">[alternatives-child-test-1] <name/> element is not allowed as a child of alternatives.</report>
    </rule></pattern><pattern id="table-wrap-tests-pattern"><rule context="table-wrap" id="table-wrap-tests">
      <let name="id" value="@id"/>
      <let name="lab" value="label[1]"/>
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-wrap-test-1" test="table" role="error" id="table-wrap-test-1">[table-wrap-test-1] table-wrap must have one table.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-wrap-test-2" test="count(table) &gt; 1" role="warning" id="table-wrap-test-2">[table-wrap-test-2] table-wrap has more than one table - Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-wrap-test-3" test="(contains($id,'inline')) and (normalize-space($lab) != '')" role="error" id="table-wrap-test-3">[table-wrap-test-3] table-wrap has an inline id <value-of select="$id"/> but it has a label - <value-of select="$lab"/>, which is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-wrap-test-4" test="(matches($id,'^table[0-9]{1,3}$')) and (normalize-space($lab) = '')" role="error" id="table-wrap-test-4">[table-wrap-test-4] table-wrap with id <value-of select="$id"/> has no label which is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-wrap-test-1" test="contains($id,'keyresource') and not(matches($lab,'^Key resources table$|^Appendix [0-9]{1,4}—key resources table$'))" role="error" id="kr-table-wrap-test-1">[kr-table-wrap-test-1] table-wrap has an id '<value-of select="$id"/>' but its label is not in the format 'Key resources table' or 'Appendix 0—key resources table', which is incorrect.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#final-table-wrap-cite-1" test="if (contains($id,'keyresource')) then ()         else if (contains($id,'inline')) then ()         else if ($article-type = ($features-article-types,$notice-article-types)) then ()         else if (ancestor::app or ancestor::sub-article) then ()         else not(ancestor::article//xref[tokenize(@rid,'\s') = $id])" role="warning" id="final-table-wrap-cite-1">[final-table-wrap-cite-1] There is no citation to <value-of select="$lab"/> Ensure this is added.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#feat-table-wrap-cite-1" test="if (contains($id,'inline')) then ()         else if ($article-type = $features-article-types) then (not(ancestor::article//xref[tokenize(@rid,'\s') = $id]))         else ()" role="warning" id="feat-table-wrap-cite-1">[feat-table-wrap-cite-1] There is no citation to <value-of select="if (label) then label else 'table.'"/> Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-not-tagged" test="not(matches($id,'keyresource|app[\d]{1,4}keyresource')) and matches(normalize-space(descendant::thead[1]),'[Rr]eagent\s?type\s?\(species\)\s?or resource\s?[Dd]esignation\s?[Ss]ource\s?or\s?reference\s?[Ii]dentifiers\s?[Aa]dditional\s?information')" role="warning" id="kr-table-not-tagged">[kr-table-not-tagged] <value-of select="$lab"/> has headings that are for a Key resources table, but it does not have an @id the format 'keyresource' or 'app0keyresource'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-not-tagged-2" test="matches(caption/title[1],'[Kk]ey [Rr]esource')" role="warning" id="kr-table-not-tagged-2">[kr-table-not-tagged-2] <value-of select="$lab"/> has the title <value-of select="caption/title[1]"/> but it is not tagged as a key resources table. Is this correct?</report>
      
    </rule></pattern><pattern id="table-title-tests-pattern"><rule context="table-wrap[not(ancestor::sub-article) and not(contains(@id,'keyresource')) and label]" id="table-title-tests">
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#final-table-title-test-1" test="caption/title" role="error" id="final-table-title-test-1">[final-table-title-test-1] <value-of select="replace(label[1],'\.$','')"/> does not have a title. Please ensure to query the authors for one.</assert>
    </rule></pattern><pattern id="table-title-tests-2-pattern"><rule context="table-wrap/caption/title" id="table-title-tests-2">
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\p{Zs}]$',''),'\. '))"/>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-title-test-2" test="not(*) and normalize-space(.)=''" role="error" id="table-title-test-2">[table-title-test-2] The title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> is empty which is not allowed.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-title-test-3" test="ends-with(.,'.') or ends-with(.,'?')" role="error" id="table-title-test-3">[table-title-test-3] The title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> does not end with a full stop which is incorrect - '<value-of select="."/>'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-title-test-4" test="ends-with(.,' vs.')" role="warning" id="table-title-test-4">[table-title-test-4] title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-title-test-5" test="string-length(.) gt 250" role="warning" id="table-title-test-5">[table-title-test-5] title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-title-test-6" test="$sentence-count gt 1" role="warning" id="table-title-test-6">[table-title-test-6] title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
      
      <report test="matches(.,'\p{Zs}$')" role="error" id="table-title-test-7">[table-title-test-7] The title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> ends with space(s) which is incorrect - '<value-of select="."/>'.</report>
    </rule></pattern><pattern id="kr-table-heading-tests-pattern"><rule context="table-wrap[contains(@id,'keyresource')]/table/thead[1]" id="kr-table-heading-tests">
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-1" test="count(tr[1]/th) != 5" role="warning" id="kr-table-header-1">[kr-table-header-1] Key resources tables should have 5 column headings (th elements) but this one has <value-of select="count(tr[1]/th)"/>. Either it is incorrectly typeset or the author will need to be queried in order to provide the table in the correct format.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-2" test="count(tr) gt 1" role="warning" id="kr-table-header-2">[kr-table-header-2] Key resources table has more than 1 row in its header, which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-3" test="count(tr) lt 1" role="warning" id="kr-table-header-3">[kr-table-header-3] Key resources table has no rows in its header, which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-4" test="tr[1]/th[1] and (normalize-space(tr[1]/th[1]) != 'Reagent type (species) or resource')" role="warning" id="kr-table-header-4">[kr-table-header-4] The first column header in a Key resources table is usually 'Reagent type (species) or resource' but this one has '<value-of select="tr[1]/th[1]"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-5" test="tr[1]/th[2] and (normalize-space(tr[1]/th[2]) != 'Designation')" role="warning" id="kr-table-header-5">[kr-table-header-5] The second column header in a Key resources table is usually 'Designation' but this one has '<value-of select="tr[1]/th[2]"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-6" test="tr[1]/th[3] and (normalize-space(tr[1]/th[3]) != 'Source or reference')" role="warning" id="kr-table-header-6">[kr-table-header-6] The third column header in a Key resources table is usually 'Source or reference' but this one has '<value-of select="tr[1]/th[3]"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-7" test="tr[1]/th[4] and (normalize-space(tr[1]/th[4]) != 'Identifiers')" role="warning" id="kr-table-header-7">[kr-table-header-7] The fourth column header in a Key resources table is usually 'Identifiers' but this one has '<value-of select="tr[1]/th[4]"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-header-8" test="tr[1]/th[5] and (normalize-space(tr[1]/th[5]) != 'Additional information')" role="warning" id="kr-table-header-8">[kr-table-header-8] The fifth column header in a Key resources table is usually 'Additional information' but this one has '<value-of select="tr[1]/th[5]"/>'.</report>
      
    </rule></pattern><pattern id="kr-table-body-tests-pattern"><rule context="table-wrap[contains(@id,'keyresource')]/table/tbody/tr/*" id="kr-table-body-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-body-1" test="local-name()='td'" role="error" id="kr-table-body-1">[kr-table-body-1] Table cell in KR table containing '<value-of select="."/>' is captured as a table header cell (<value-of select="local-name()"/>), which is not allowed. Ensure that this is changed to a normal table cell (td).</assert>
      
    </rule></pattern><pattern id="kr-table-first-column-tests-pattern"><rule context="table-wrap[contains(@id,'keyresource')]/table/tbody/tr/*[1]" id="kr-table-first-column-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#kr-table-first-column-1" test="matches(lower-case(.),'^gene|^strain|^genetic reagent|^cell line|^transfected construct|^biological sample|^antibody|^recombinant dna reagent|^sequence-based reagent|^peptide|^recombinant protein|^commercial (assay|kit)|^chemical compound|^drug|^software|^algorithm|^other')" role="warning" id="kr-table-first-column-1">[kr-table-first-column-1] A cell in the first column of the body of a key resources table should start with one of the standard values. '<value-of select="."/>' does not start with one of Gene; Strain, strain background; Genetic reagent; Cell line; Transfected construct; Biological sample; Antibody; Recombinant DNA reagent; Sequence-based reagent; Peptide, Recombinant protein; Commercial assay or kit; Chemical compound, drug; Software; Algorithm; Other.</assert>
      
    </rule></pattern><pattern id="kr-table-tests-pattern"><rule context="table-wrap[contains(@id,'keyresource')]" id="kr-table-tests">
      
      
      
      <report test="following::table-wrap[contains(@id,'keyresource') or contains(lower-case(label[1]),'key resources table')]" role="error" id="final-duplicate-kr-table-1">[final-duplicate-kr-table-1] There is more than one key resources table, which is not permitted.</report>
      
      <assert test="table/thead" role="error" id="kr-table-head-presence">[kr-table-head-presence] Key resources table must have a header (thead). This one does not have a header.</assert>
      
    </rule></pattern><pattern id="table-cell-tests-pattern"><rule context="table-wrap/table/tbody/tr/*[xref[@ref-type='bibr'] and matches(.,'[\(\)\[\]]')]|table-wrap/table/thead/tr/*[xref[@ref-type='bibr'] and matches(.,'[\(\)\[\]]')]" id="table-cell-tests">
      <let name="stripped-text" value="string-join(for $x in self::*/(text()|*)         return if (($x/local-name()='xref') and $x/@ref-type='bibr') then ()         else $x,'')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#table-cell-1" test="matches($stripped-text,'[\p{N}\p{L}]')" role="warning" id="table-cell-1">[table-cell-1] Table cell in <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> contains '<value-of select="."/>'. Are the brackets around the citation(s) unnecessary?</assert>
      
    </rule></pattern><pattern id="body-table-label-tests-pattern"><rule context="body//table-wrap/label" id="body-table-label-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#body-table-label-test-1" test="matches(.,'^Table \d{1,4}\.$|^Key resources table$|^Author response table \d{1,4}\.$|^Decision letter table \d{1,4}\.$|^Review table \d{1,4}\.$')" role="error" id="body-table-label-test-1">[body-table-label-test-1] <value-of select="."/> - Table label does not conform to the usual format.</assert>
      
    </rule></pattern><pattern id="app-table-label-tests-pattern"><rule context="app//table-wrap/label" id="app-table-label-tests">
      <let name="app" value="ancestor::app/title[1]"/>
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#app-table-label-test-1" test="matches(.,'^Appendix \d{1,4}—table \d{1,4}\.$|^Appendix \d{1,4}—key resources table$')" role="error" id="app-table-label-test-1">[app-table-label-test-1] <value-of select="."/> - Table label does not conform to the usual format.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#app-table-label-test-2" test="starts-with(.,$app)" role="error" id="app-table-label-test-2">[app-table-label-test-2] <value-of select="."/> - Table label does not begin with the title of the appendix it sits in. Either the table is in the incorrect appendix or the table has been labelled incorrectly.</assert>
      
    </rule></pattern><pattern id="table-tests-pattern"><rule context="table" id="table-tests">
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-test-1" test="count(tbody) = 0" role="error" id="table-test-1">[table-test-1] table must have at least one body (tbody).</report>
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-test-2" test="thead" role="warning" id="table-test-2">[table-test-2] table doesn't have a header (thead). Is this correct?</assert>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-test-3" test="thead and tbody/tr/th[not(following-sibling::td)] and count(descendant::tr) gt 45" role="warning" id="table-test-3">[table-test-3] <value-of select="if (ancestor::table-wrap[1]/label[1]) then replace(ancestor::table-wrap[1]/label[1],'\.$','') else 'Table'"/> has a main header (thead), but it also has a header or headers in the body and contains 45 or more rows. The main (first) header will as a result appear at the start of any new pages in the PDF. Is this correct? Or should the main header be moved down into the body (but still captured with &lt;th&gt; instead of &lt;td&gt;) so that this header does not appear on the subsequent pages?</report>
    </rule></pattern><pattern id="tbody-tests-pattern"><rule context="table/tbody" id="tbody-tests">
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#tbody-test-1" test="count(tr) = 0" role="error" id="tbody-test-1">[tbody-test-1] tbody must have at least one row (tr).</report>
    </rule></pattern><pattern id="thead-tests-pattern"><rule context="table/thead" id="thead-tests">
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#thead-test-1" test="count(tr) = 0" role="error" id="thead-test-1">[thead-test-1] thead must have at least one row (tr).</report>
    </rule></pattern><pattern id="tr-tests-pattern"><rule context="tr" id="tr-tests">
      <let name="count" value="count(th) + count(td)"/> 
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#tr-test-1" test="$count = 0" role="error" id="tr-test-1">[tr-test-1] row (tr) must contain at least one heading cell (th) or data cell (td).</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#tr-test-2" test="th and (parent::tbody)" role="warning" id="tr-test-2">[tr-test-2] table row in body contains a th element (a header). Please check that this is correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#tr-test-3" test="td and (parent::thead)" role="error" id="tr-test-3">[tr-test-3] table row in header contains a td element (table data), which is not allowed. Only th elements (table heading cells) are allowed in a row in the table header.</report>
    </rule></pattern><pattern id="td-child-tests-pattern"><rule context="td/*" id="td-child-tests">
      <let name="allowed-blocks" value="('bold','italic','sup','sub','sc','ext-link','xref', 'break', 'named-content', 'styled-content', 'monospace', 'code','inline-graphic','underline','inline-formula', 'list')"/> 
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#td-child-test" test="self::*/local-name() = $allowed-blocks" role="error" id="td-child-test">[td-child-test] td cannot contain <value-of select="self::*/local-name()"/>. Only the following elements are allowed - <value-of select="string-join($allowed-blocks,', ')"/>.</assert>
    </rule></pattern><pattern id="th-child-tests-pattern"><rule context="th/*" id="th-child-tests">
      <let name="allowed-blocks" value="('bold','italic','sup','sub','sc','underline','ext-link','xref', 'break', 'named-content', 'monospace','inline-formula','inline-graphic', 'list')"/> 
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#th-child-test-1" test="self::*/local-name() = ($allowed-blocks)" role="error" id="th-child-test-1">[th-child-test-1] th cannot contain <value-of select="self::*/local-name()"/>. Only the following elements are allowed - <value-of select="string-join($allowed-blocks,', ')"/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#th-child-test-2" test="name() = ('bold','underline') and . = ./parent::th" role="warning" id="th-child-test-2">[th-child-test-2] The content of this th element is entirely in <value-of select="name()"/> emphasis - <value-of select="."/>. Is this correct?</report>
    </rule></pattern><pattern id="th-tests-pattern"><rule context="th" id="th-tests">
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#th-row-test" test="following-sibling::td or preceding-sibling::td" role="warning" id="th-row-test">[th-row-test] Table header cell containing '<value-of select="."/>' has table data (not header) cells next to it on the same row. Is this correct? Should the whole row be header cells, or should this cell extend across the whole row?</report>
      
    </rule></pattern><pattern id="table-fn-label-tests-pattern"><rule context="table-wrap-foot//fn/p" id="table-fn-label-tests"> 
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-fn-label-test-1" test="not(matches(.,'^\p{Zs}?[*†‡§¶]')) and matches(.,'^\p{Zs}?[\p{Ps}]?[\da-z][\p{Pe}]?\p{Zs}+[\p{Lu}\d]')" role="warning" id="table-fn-label-test-1">[table-fn-label-test-1] Footnote starts with what might be a label which is not in line with house style - <value-of select="."/>. If it is a label, then it should changed to one of the allowed symbols, so that the order of labels in the footnotes follows this sequence *, †, ‡, §, ¶, **, ††, ‡‡, §§, ¶¶, etc.</report>
    </rule></pattern><pattern id="table-fn-tests-pattern"><rule context="table-wrap-foot//fn" id="table-fn-tests"> 
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-fn-test-1" test="label and not(@id)" role="error" id="table-fn-test-1">[table-fn-test-1] Table footnote with a label must have an id. This one has the label '<value-of select="label"/>' but no id.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-fn-test-2" test="@id and not(label)" role="error" id="table-fn-test-2">[table-fn-test-2] Table footnotes with an id must have a label (or the id should be removed). This one has the id '<value-of select="@id"/>' but no label. If a lable should not be present, then please remove the id.</report>
    </rule></pattern><pattern id="fn-tests-pattern"><rule context="fn[@id][not(@fn-type='other') and not(ancestor::table-wrap)]" id="fn-tests">
      
      <assert test="ancestor::article//xref/@rid = @id" role="error" id="fn-xref-presence-test">[fn-xref-presence-test] fn element with an id must have at least one xref element pointing to it.</assert>
    </rule></pattern><pattern id="list-tests-pattern"><rule context="list" id="list-tests">
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hzkm6-continued-from-test-1" test="@continued-from" role="error" id="continued-from-test-1">[continued-from-test-1] The continued-from attribute is not allowed for lists, since this is not supported by Continuum. Please use an alternative method to capture lists which are interrupted.</report>
      
    </rule></pattern><pattern id="list-item-tests-pattern"><rule context="list-item" id="list-item-tests">
      <let name="type" value="ancestor::list[1]/@list-type"/>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#ho2mz-bullet-test-1" test="($type='bullet') and matches(.,'^\p{Zs}?•')" role="error" id="bullet-test-1">[bullet-test-1] list-item is part of bullet list, but it also begins with a '•', which means that two will output. Remove the unnecessary '•' from the beginning of the list-item.</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hiw8e-bullet-test-2" test="($type='simple') and matches(.,'^\p{Zs}?•')" role="error" id="bullet-test-2">[bullet-test-2] list-item is part of simple list, but it begins with a '•'. Remove the unnecessary '•' and capture the list as a bullet type list.</report>
      
      <report test="($type='order') and matches(.,'^\p{Zs}?\d+')" role="warning" id="order-test-1">[order-test-1] list-item is part of an ordered list, but it begins with a number. Is this correct? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h8efq-alpha-lower-test-1" test="($type='alpha-lower') and matches(.,'^\p{Zs}?[a-h|j-w|y-z][\.|\)]? ')" role="warning" id="alpha-lower-test-1">[alpha-lower-test-1] list-item is part of an alpha-lower list, but it begins with a single lower-case letter. Is this correct? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hu39x-alpha-upper-test-1" test="($type='alpha-upper') and matches(.,'^\p{Zs}?[A-H|J-W|Y-Z][\.|\)]? ')" role="warning" id="alpha-upper-test-1">[alpha-upper-test-1] list-item is part of an alpha-upper list, but it begins with a single upper-case letter. Is this correct? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h6h2f-roman-lower-test-1" test="($type='roman-lower') and matches(.,'^\p{Zs}?(i|ii|iii|iv|v|vi|vii|viii|ix|x)[\.|\)]? ')" role="warning" id="roman-lower-test-1">[roman-lower-test-1] list-item is part of a roman-lower list, but it begins with a single roman-lower letter. Is this correct? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hixpt-roman-upper-test-1" test="($type='roman-upper') and matches(.,'^\p{Zs}?(I|II|III|IV|V|VI|VII|VIII|IX|X)[\.|\)]? ')" role="warning" id="roman-upper-test-1">[roman-upper-test-1] list-item is part of a roman-upper list, but it begins with a single roman-upper letter. Is this correct? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hweek-simple-test-1" test="($type='simple') and matches(.,'^\p{Zs}?[1-9][\.|\)]? ')" role="warning" id="simple-test-1">[simple-test-1] list-item is part of a simple list, but it begins with a number. Should the list-type be updated to ordered and this number removed? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hdued-simple-test-2" test="($type='simple') and matches(.,'^\p{Zs}?[a-h|j-w|y-z][\.|\)] ')" role="warning" id="simple-test-2">[simple-test-2] list-item is part of a simple list, but it begins with a single lower-case letter. Should the list-type be updated to 'alpha-lower' and this first letter removed? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h4a97-simple-test-3" test="($type='simple') and matches(.,'^\p{Zs}?[A-H|J-W|Y-Z][\.|\)] ')" role="warning" id="simple-test-3">[simple-test-3] list-item is part of a simple list, but it begins with a single upper-case letter. Should the list-type be updated to 'alpha-upper' and this first letter removed? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hv867-simple-test-4" test="($type='simple') and matches(.,'^\p{Zs}?(i|ii|iii|iv|v|vi|vii|viii|ix|x)[\.|\)]? ')" role="warning" id="simple-test-4">[simple-test-4] list-item is part of a simple list, but it begins with a single roman-lower letter. Should the list-type be updated to 'roman-lower' and this first letter removed? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h9cfo-simple-test-5" test="($type='simple') and matches(.,'^\p{Zs}?(I|II|III|IV|V|VI|VII|VIII|IX|X)[\.|\)]? ')" role="warning" id="simple-test-5">[simple-test-5] list-item is part of a simple list, but it begins with a single roman-upper letter. Should the list-type be updated to 'roman-upper' and this first letter removed? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hd4i0-list-item-test-1" test="matches(.,'^\p{Zs}?\p{Ll}[\p{Zs}\)\.]')" role="warning" id="list-item-test-1">[list-item-test-1] list-item begins with a single lowercase letter, is this correct? - <value-of select="."/></report>
    </rule></pattern><pattern id="general-video-pattern"><rule context="media[@mimetype='video'][matches(@id,'^video[0-9]{1,3}$')]" id="general-video">
      <let name="label" value="replace(label,'\.$','')"/>
      <let name="id" value="@id"/>
      <let name="xrefs" value="e:get-xrefs(ancestor::article,$id,'video')"/>
      <let name="sec1" value="ancestor::article/descendant::sec[@id = $xrefs//*/@sec-id][1]"/>
      <let name="sec-id" value="ancestor::sec[1]/@id"/>
      <let name="xref1" value="ancestor::article/descendant::xref[(@rid = $id) and not(ancestor::caption)][1]"/>
      <let name="xref-sib" value="$xref1/parent::*/following-sibling::*[1]/local-name()"/>
      
      
      
      <assert test="$xrefs//*:match" role="warning" id="final-video-cite">[final-video-cite] There is no citation to <value-of select="$label"/>. Ensure this is added.</assert>
      
      
      
      <report test="($xrefs//*:match) and ($sec-id != $sec1/@id)" role="error" id="final-video-placement-1">[final-video-placement-1] <value-of select="$label"/> does not appear in the same section as where it is first cited (sec with title '<value-of select="$sec1/title"/>'), which is incorrect.</report>
      
      <report test="($xref-sib = 'p') and ($xref1//following::media/@id = $id)" role="warning" id="video-placement-2">[video-placement-2] <value-of select="$label"/> appears after its first citation but not directly after its first citation. Is this correct?</report>
      
    </rule></pattern><pattern id="code-tests-pattern"><rule context="code" id="code-tests">
      
      <report see="https://elifeproduction.slab.com/posts/code-blocks-947pcamv#code-child-test" test="child::*" role="error" id="code-child-test">[code-child-test] code contains a child element, which will display in HTML with its tagging, i.e. '&lt;<value-of select="child::*[1]/name()"/><value-of select="if (child::*[1]/@*) then for $x in child::*[1]/@* return concat(' ',$x/name(),'=&quot;',$x/string(),'&quot;') else ()"/>&gt;<value-of select="child::*[1]"/>&lt;/<value-of select="child::*[1]/name()"/>&gt;'. Strip any child elements.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/code-blocks-947pcamv#code-parent-test" test="parent::p" role="error" id="code-parent-test">[code-parent-test] A code element must be contained in a p element. The code element (containing the content <value-of select="."/>) is contained in a <value-of select="parent::*/name()"/> element.</assert>
      
    </rule></pattern><pattern id="code-tests-2-pattern"><rule context="p[count(code) gt 1]/code[2]" id="code-tests-2">
      
      <report see="https://elifeproduction.slab.com/posts/code-blocks-947pcamv#code-sibling-test" test="normalize-space(preceding-sibling::text()[preceding-sibling::*[1]/local-name()='code'][1])=''" role="warning" id="code-sibling-test">[code-sibling-test] code element (containing the content <value-of select="."/>) is directly preceded by another code element (containing the content <value-of select="preceding::*[1]"/>). If the content is part of the same code block, then it should be captured using only 1 code element and line breaks added in the xml. If these are separate code blocks (uncommon, but possible), then this markup is fine.</report>
      
    </rule></pattern><pattern id="code-tests-3-pattern"><rule context="p[count(code) = 1]/code" id="code-tests-3">
      <let name="previous-parent" value="parent::p/preceding-sibling::*[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/code-blocks-947pcamv#code-sibling-test-2" test="$previous-parent/*[last()][(local-name()='code') and not(following-sibling::text())] and not(preceding-sibling::*) and not(preceding-sibling::text())" role="warning" id="code-sibling-test-2">[code-sibling-test-2] code element (containing the content <value-of select="."/>) is directly preceded by another code element (containing the content <value-of select="preceding::*[1]"/>). If the content is part of the same code block, then it should be captured using only 1 code element and line breaks added in the xml. If these are separate code blocks (uncommon, but possible), then this markup is fine.</report>
      
    </rule></pattern><pattern id="generic-label-tests-pattern"><rule context="fig/label|supplementary-material/label|media/label|table-wrap/label|boxed-text/label" id="generic-label-tests">
      <let name="label" value="replace(.,'\.$','')"/>
      <let name="label-2" value="replace(.,'\p{P}','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#label-fig-group-conformance-1" test="not(ancestor::fig-group) and parent::fig[@specific-use='child-fig']" role="error" id="label-fig-group-conformance-1">[label-fig-group-conformance-1] <value-of select="$label"/> is not placed in a &lt;fig-group&gt; element, which is incorrect. Either the label needs updating, or it needs moving into the &lt;fig-group&gt;.</report>
      
      <report test="not(ancestor::fig-group) and parent::media and matches(.,'[Ff]igure')" role="error" id="label-fig-group-conformance-2">[label-fig-group-conformance-2] <value-of select="$label"/> contains the string 'Figure' but it's not placed in a &lt;fig-group&gt; element, which is incorrect. Either the label needs updating, or it needs moving into the &lt;fig-group&gt;.</report>
      
      <report test="some $x in preceding::label satisfies (replace($x,'\p{P}','') = $label-2)" role="error" id="distinct-label-conformance">[distinct-label-conformance] Duplicated labels - <value-of select="$label"/> is present more than once in the text.</report>
      
    </rule></pattern><pattern id="equation-label-tests-pattern"><rule context="article[not(@article-type) or @article-type!='correction']//disp-formula/label" id="equation-label-tests">
      <let name="label-2" value="replace(.,'\p{P}','')"/>
      <let name="app-id" value="ancestor::app/@id"/>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#equation-label-conformance-1" test="(ancestor::app) and (some $x in preceding::disp-formula/label[ancestor::app[@id=$app-id]] satisfies (replace($x,'\p{P}','') = $label-2))" role="warning" id="equation-label-conformance-1">[equation-label-conformance-1] Duplicated display formula labels - <value-of select="."/> is present more than once in the same appendix. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#equation-label-conformance-2" test="(ancestor::body[parent::article]) and (some $x in preceding::disp-formula/label[ancestor::body[parent::article] and not(ancestor::fig)] satisfies (replace($x,'\p{P}','') = $label-2))" role="error" id="equation-label-conformance-2">[equation-label-conformance-2] Duplicated display formula labels - <value-of select="."/> is present more than once in the main body of the text.</report>
      
    </rule></pattern><pattern id="aff-label-tests-pattern"><rule context="aff/label" id="aff-label-tests">
      <let name="label-2" value="replace(.,'\p{P}','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hw7yy-aff-label-conformance-1" test="some $x in preceding::aff/label satisfies (replace($x,'\p{P}','') = $label-2)" role="error" id="aff-label-conformance-1">[aff-label-conformance-1] Duplicated affiliation labels - <value-of select="."/> is present more than once.</report>
    </rule></pattern><pattern id="disp-quote-tests-pattern"><rule context="disp-quote" id="disp-quote-tests">
      <let name="subj" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="ancestor::sub-article[not(@article-type=('reply','author-comment'))]" role="warning" flag="dl-ar" id="disp-quote-test-1">[disp-quote-test-1] Content is tagged as a display quote, which is almost definitely incorrect, since it's within peer review material that is not an author response - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hq129-disp-quote-test-2" test="not(ancestor::sub-article) and ($subj=($research-subj,$notice-article-types))" role="error" id="disp-quote-test-2">[disp-quote-test-2] Display quote in a <value-of select="$subj"/> is not allowed. Please capture as paragraph instead - '<value-of select="."/>'</report>
    </rule></pattern><pattern id="bracket-tests-pattern"><rule context="p[matches(.,'[\(\)\[\]]')]|th[matches(.,'[\(\)\[\]]')]|td[matches(.,'[\(\)\[\]]')]|title[matches(.,'[\(\)\[\]]')]" id="bracket-tests">
      <let name="open-curly" value="string-length(replace(.,'[^\(]',''))"/>
      <let name="close-curly" value="string-length(replace(.,'[^\)]',''))"/>
      <let name="open-square" value="string-length(replace(.,'[^\[]',''))"/>
      <let name="close-square" value="string-length(replace(.,'[^\]]',''))"/>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h29wm-bracket-test-1" test="$open-curly gt $close-curly" role="warning" id="bracket-test-1">[bracket-test-1] <name/> element contains more left '(' than right ')' parentheses (<value-of select="$open-curly"/> and <value-of select="$close-curly"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\(]','')) gt string-length(replace($sentence,'[^\)]',''))) then $sentence else (),' ---- ')"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h29wm-bracket-test-2" test="not(matches(.,'^\p{Zs}?(\d+|[A-Za-z]|[Ii]?[Xx]|[Ii]?[Vv]|[Vv]?[Ii]{1,3})\)')) and ($open-curly lt $close-curly)" role="warning" id="bracket-test-2">[bracket-test-2] <name/> element contains more right ')' than left '(' parentheses (<value-of select="$close-curly"/> and <value-of select="$open-curly"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\(]','')) lt string-length(replace($sentence,'[^\)]',''))) then $sentence else (),' ---- ')"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h29wm-bracket-test-3" test="$open-square gt $close-square" role="warning" id="bracket-test-3">[bracket-test-3] <name/> element contains more left '[' than right ']' square brackets (<value-of select="$open-square"/> and <value-of select="$close-square"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\[]','')) gt string-length(replace($sentence,'[^\]]',''))) then $sentence else (),' ---- ')"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h29wm-bracket-test-4" test="not(matches(.,'^\p{Zs}?(\d+|[A-Za-z]|[Ii]?[Xx]|[Ii]?[Vv]|[Vv]?[Ii]{1,3})\]')) and ($open-square lt $close-square)" role="warning" id="bracket-test-4">[bracket-test-4] <name/> element contains more right ']' than left '[' square brackets (<value-of select="$close-square"/> and <value-of select="$open-square"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\[]','')) lt string-length(replace($sentence,'[^\]]',''))) then $sentence else (),' ---- ')"/></report>

      <report test="matches(replace(.,'\\begin.document.*?\\end.document.',''),'[\(\[]\p{Zs}+')" role="warning" id="bracket-test-5">[bracket-test-5] <name/> element contains an opening bracket immediately followed by a space (e.g. '( ' or '[ '). Should the space be removed? <value-of select="."/></report>

      <report test="matches(replace(.,'\\begin.document.*?\\end.document.',''),'\p{Zs}+[\)\]]')" role="warning" id="bracket-test-6">[bracket-test-6] <name/> element contains a closing bracket immediately preceded by a space (e.g. ' )' or ' ]'). Should the space be removed? <value-of select="."/></report>
    </rule></pattern><pattern id="body-box-tests-pattern"><rule context="article/body//boxed-text[not(parent::body) or preceding-sibling::*]" id="body-box-tests">
      
      <assert test="matches(label[1],'^Box \d{1,2}\.$')" role="error" id="body-box-label-test">[body-box-label-test] <name/> element must have a label in the format "Box 0.".</assert>
      
    </rule></pattern><pattern id="app-box-tests-pattern"><rule context="app//boxed-text[not((parent::sec[parent::app] or parent::app) and preceding-sibling::*[1]/name()='title' or count(preceding-sibling::*) = (0,1))]" id="app-box-tests">
      <let name="app-title" value="ancestor::app[1]/title"/>
      
      <assert test="matches(label[1],'^Appendix \d{1,2}—box \d{1,2}\.$')" role="error" id="app-box-label-test">[app-box-label-test] <name/> element must have a label in the format "Appendix 0—box 0.".</assert>
      
      <assert test="starts-with(label[1],$app-title)" role="error" id="app-box-label-test-2">[app-box-label-test-2] <name/> label must start with the title for the appendix it sits in, <value-of select="$app-title"/>. This one does not - "<value-of select="label[1]"/>".</assert>
      
    </rule></pattern><pattern id="app-content-tests-pattern"><rule context="app[not(preceding-sibling::app) and not(following-sibling::app) and not(descendant::sec or descendant::table-wrap or descendant::fig or descendant::media[@mimetype='video'] or descendant::disp-formula)]" id="app-content-tests">
      
      <report test="count(descendant::p) = (0,1)" role="warning" id="app-little-content">[app-little-content] <value-of select="title"/> has no sibling appendices, contains no assets (figures, tables, videos, or display formula), and only has one paragraph. Does it need to be an appendix?</report>
      
    </rule></pattern><pattern id="attrib-tests-pattern"><rule context="attrib" id="attrib-tests">
      <let name="parent" value="parent::*/name()"/>
      <let name="allowed-parents" value="('fig','media','table-wrap','boxed-text','disp-quote')"/>
      
      <assert test="$parent=$allowed-parents" role="error" id="attrib-parent">[attrib-parent] attrib is a child of <value-of select="$parent"/>, which is not allowed. It can only be a child of the following elements: <value-of select="string-join($allowed-parents,'; ')"/></assert>
      
      <report test="preceding-sibling::attrib" role="warning" id="attrib-sibling">[attrib-sibling] attrib has a preceding sibling. Does the <value-of select="$parent"/> really need more than one attrib?</report>
      
      <assert test="* or normalize-space(.)!=''" role="error" id="attrib-content">[attrib-content] attrib cannot be empty.</assert>
      
    </rule></pattern><pattern id="attrib-child-tests-pattern"><rule context="attrib/*" id="attrib-child-tests">
      <let name="allowed-children" value="('ext-link', 'xref', 'inline-graphic', 'italic', 'sub', 'bold', 'sup')"/>
      
      <assert test="name()=$allowed-children" role="error" id="attrib-child">[attrib-child] <value-of select="name()"/> is not permitted as a child of attrib. Only the following elements are: <value-of select="string-join($allowed-children,'; ')"/></assert>
      
    </rule></pattern>
  
  <pattern id="body-video-specific-pattern"><rule context="article[not(@article-type = $notice-article-types)]/body//media[@mimetype='video']" id="body-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'][matches(label[1],'^Video [\d]+\.$')])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'][matches(label[1],'^Video [\d]+\.$')][ancestor::body])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      <let name="fig-label" value="replace(ancestor::fig-group/fig[1]/label,'\.$','—')"/>
      <let name="fig-pos" value="count(ancestor::fig-group//media[@mimetype='video'][starts-with(label[1],$fig-label)]) - count(following::media[@mimetype='video'][starts-with(label[1],$fig-label)])"/>
      
      
      
      <report test="not(ancestor::fig-group) and (matches(label[1],'[Vv]ideo')) and ($no != string($pos))" role="error" id="final-body-video-position-test-1">[final-body-video-position-test-1] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other videos it is placed in position <value-of select="$pos"/>.</report>
      
      <assert test="starts-with(label[1],$fig-label)" role="error" id="fig-video-label-test">[fig-video-label-test] <value-of select="label"/> does not begin with its parent figure label - <value-of select="$fig-label"/> - which is incorrect.</assert>
      
      <report test="(ancestor::fig-group) and ($no != string($fig-pos))" role="error" id="fig-video-position-test">[fig-video-position-test] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other fig-level videos it is placed in position <value-of select="$fig-pos"/>.</report>
      
      <report test="(not(ancestor::fig-group)) and (descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))])" role="warning" id="fig-video-check-1">[fig-video-check-1] <value-of select="label"/> contains a link to <value-of select="descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))][1]"/>, but it is not a captured as a child of that fig. Should it be captured as <value-of select="concat(descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))][1],'—video x')"/> instead?</report>
      
    </rule></pattern><pattern id="app-video-specific-pattern"><rule context="app//media[@mimetype='video' and not(ancestor::fig-group)]" id="app-video-specific">
      <let name="app-id" value="ancestor::app/@id"/>
      <let name="count" value="count(ancestor::app//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[(@mimetype='video') and (ancestor::app/@id = $app-id)])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      
      
      <assert test="$no = string($pos)" role="error" id="final-app-video-position-test">[final-app-video-position-test] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
    </rule></pattern><pattern id="app-fig-video-specific-pattern"><rule context="app//fig-group//media[@mimetype='video']" id="app-fig-video-specific">
      <let name="fig-id" value="ancestor::fig-group/fig[not(@specific-use='child-fig')]/@id"/>
      <let name="count" value="count(ancestor::fig-group//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[(@mimetype='video') and (ancestor::fig-group/fig[not(@specific-use='child-fig')]/@id = $fig-id)])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      
      
      <assert test="$no = string($pos)" role="error" id="final-app-fig-video-position-test">[final-app-fig-video-position-test] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
    </rule></pattern><pattern id="fig-video-specific-pattern"><rule context="fig-group/media[@mimetype='video']" id="fig-video-specific">
      
      <report test="following-sibling::fig" role="error" id="fig-video-position-test-2">[fig-video-position-test-2] <value-of select="replace(label,'\.$','')"/> is placed before <value-of select="following-sibling::fig[1]/label[1]"/> Figure level videos should always be placed after figures and figure supplements in their figure group.</report>
      
    </rule></pattern><pattern id="dl-video-specific-pattern"><rule context="sub-article[@article-type=('decision-letter','referee-report')]/body//media[@mimetype='video']" id="dl-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video' and ancestor::sub-article/@article-type=('decision-letter','referee-report')])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      
      
      <assert test="$no = string($pos)" role="error" id="final-dl-video-position-test">[final-dl-video-position-test] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other DL videos it is placed in position <value-of select="$pos"/>.</assert>
    </rule></pattern><pattern id="ar-video-specific-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//media[@mimetype='video']" id="ar-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      
      
      <assert test="$no = string($pos)" role="error" id="final-ar-video-position-test">[final-ar-video-position-test] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
    </rule></pattern><pattern id="video-labels-pattern"><rule context="media/label[matches(lower-case(.),'^video \d+\.$')]" id="video-labels">
      <let name="number" value="number(replace(.,'[^\d]',''))"/>
      
      <report test="$number != 1 and (not(preceding::media[matches(lower-case(*:label[1]),'^video \d+\.$')]) or (number(preceding::media[matches(lower-case(*:label[1]),'^video \d+\.$')][1]/label/replace(.,'[^\d]','')) != ($number - 1)))" role="error" id="video-label-1">[video-label-1] Video has the label '<value-of select="."/>', but there is no preceding video with the label number <value-of select="$number - 1"/>. Either they are not correctly ordered, or the label numbering is incorrect.</report>
      
    </rule></pattern><pattern id="fig-video-labels-pattern"><rule context="media/label[matches(lower-case(.),'^figure \d+—video \d+\.$')]" id="fig-video-labels">
      <let name="figure-string" value="substring-before(.,'—video')"/>
      <let name="number" value="number(replace(substring-after(.,'—video'),'[^\d]',''))"/>
      
      <report test="$number != 1 and (not(parent::media/preceding-sibling::media/label[contains(.,concat($figure-string,'—video'))]) or (number(parent::media/preceding-sibling::media[label[contains(.,concat($figure-string,'—video'))]][1]/label/replace(substring-after(.,'—'),'[^\d]','')) != ($number - 1)))" role="error" id="fig-video-label-1">[fig-video-label-1] Video has the label '<value-of select="."/>', but there is no preceding video with the label number <value-of select="concat($figure-string,'—video ',string($number - 1))"/>. Either they are not correctly ordered, or the label numbering is incorrect.</report>
      
    </rule></pattern><pattern id="animation-labels-pattern"><rule context="media/label[matches(lower-case(.),'^animation \d+\.$')]" id="animation-labels">
      <let name="number" value="number(replace(.,'[^\d]',''))"/>
      
      <report test="$number != 1 and (not(preceding::media[matches(lower-case(*:label[1]),'^animation \d+\.$')]) or (number(preceding::media[matches(lower-case(*:label[1]),'^animation \d+\.$')][1]/label/replace(.,'[^\d]','')) != ($number - 1)))" role="error" id="animation-label-1">[animation-label-1] Animation has the label '<value-of select="."/>', but there is no preceding animation with the label number <value-of select="$number - 1"/>. Either they are not correctly ordered, or the label numbering is incorrect.</report>
      
    </rule></pattern><pattern id="fig-animation-labels-pattern"><rule context="media/label[matches(lower-case(.),'^figure \d+—animation \d+\.$')]" id="fig-animation-labels">
      <let name="figure-string" value="substring-before(.,'—animation')"/>
      <let name="number" value="number(replace(substring-after(.,'—animation'),'[^\d]',''))"/>
      
      <report test="$number != 1 and (not(parent::media/preceding-sibling::media/label[contains(.,concat($figure-string,'—animation'))]) or (number(parent::media/preceding-sibling::media[label[contains(.,concat($figure-string,'—animation'))]][1]/label/replace(substring-after(.,'—'),'[^\d]','')) != ($number - 1)))" role="error" id="fig-animation-label-1">[fig-animation-label-1] Animation has the label '<value-of select="."/>', but there is no preceding animation with the label number <value-of select="concat($figure-string,'—animation ',string($number - 1))"/>. Either they are not correctly ordered, or the label numbering is incorrect.</report>
      
    </rule></pattern>
  
  <pattern id="body-table-pos-conformance-pattern"><rule context="article[not(@article-type=$notice-article-types)]/body//table-wrap[matches(@id,'^table[\d]+$')]" id="body-table-pos-conformance">
      <let name="count" value="count(ancestor::body//table-wrap[matches(@id,'^table[\d]+$')])"/>
      <let name="pos" value="$count - count(following::table-wrap[(matches(@id,'^table[\d]+$')) and (ancestor::body) and not(ancestor::sub-article)])"/>
      <let name="no" value="substring-after(@id,'table')"/>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#final-body-table-report" test="($no = string($pos))" role="error" id="final-body-table-report">[final-body-table-report] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other numbered tables it is placed in position <value-of select="$pos"/>.</assert>
      
    </rule></pattern><pattern id="app-table-pos-conformance-pattern"><rule context="article//app//table-wrap[matches(@id,'^app[\d]+table[\d]+$')]" id="app-table-pos-conformance">
      <let name="app-id" value="ancestor::app/@id"/>
      <let name="app-no" value="substring-after($app-id,'appendix-')"/>
      <let name="id-regex" value="concat('^app',$app-no,'table[\d]+$')"/>
      <let name="count" value="count(ancestor::app//table-wrap[matches(@id,$id-regex)])"/>
      <let name="pos" value="$count - count(following::table-wrap[matches(@id,$id-regex)])"/>
      <let name="no" value="substring-after(@id,concat($app-no,'table'))"/>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#final-app-table-report" test="($no = string($pos))" role="error" id="final-app-table-report">[final-app-table-report] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other numbered tables in the same appendix it is placed in position <value-of select="$pos"/>.</assert>
      
    </rule></pattern>
  
  <pattern id="fig-specific-tests-pattern"><rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]" id="fig-specific-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="id" value="@id"/>
      <let name="count" value="count(ancestor::article//fig[matches(label[1],'^Figure \d{1,4}\.$')])"/>
      <let name="pos" value="$count - count(following::fig[matches(label[1],'^Figure \d{1,4}\.$')])"/>
      <let name="no" value="substring-after($id,'fig')"/>
      <let name="pre-sib" value="preceding-sibling::*[1]"/>
      <let name="fol-sib" value="following-sibling::*[1]"/>
      <let name="lab" value="replace(label[1],'\.','')"/>
      <let name="first-cite" value="ancestor::article/body/descendant::xref[parent::p and not(ancestor::caption) and not(ancestor::table-wrap) and (@rid = $id)][1]"/>
      <let name="first-cite-parent" value="if ($first-cite/ancestor::list) then $first-cite/ancestor::list[last()] else $first-cite/parent::p"/>
      <!-- The names of elements in between the first citation parent, and the fig -->
      <let name="in-between-elements" value="distinct-values(         $first-cite-parent/following-sibling::*[@id=$id or (child::*[@id=$id] and local-name()='fig-group') or following::*[@id=$id] or following::*/*[@id=$id]]/local-name()         )"/>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-specific-test-1" test="label[contains(lower-case(.),'supplement')]" role="error" id="fig-specific-test-1">[fig-specific-test-1] fig label contains 'supplement', but it does not have a @specific-use='child-fig'. If it is a figure supplement it needs the attribute, if it isn't then it cannot contain 'supplement' in the label.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#final-fig-specific-test-2" test="if ($article-type = $notice-article-types) then ()         else if ($count = 0) then ()         else if (not(matches($id,'^fig[0-9]{1,3}$'))) then ()         else $no != string($pos)" role="error" id="final-fig-specific-test-2">[final-fig-specific-test-2] <value-of select="$lab"/> does not appear in sequence which is incorrect. Relative to the other figures it is placed in position <value-of select="$pos"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-specific-test-3" test="not($article-type = $notice-article-types) and ancestor::article//xref[@rid = $id] and  (empty($in-between-elements) or (some $x in $in-between-elements satisfies not($x=('fig-group','fig','media','table-wrap'))))" role="warning" id="fig-specific-test-3">[fig-specific-test-3] <value-of select="$lab"/> is cited, but does not appear directly after the paragraph citing it. Is that correct?</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#final-fig-specific-test-4" test="if ($article-type = ($features-article-types,$notice-article-types)) then ()         else if (contains($lab,'Chemical') or contains($lab,'Scheme')) then ()         else not(ancestor::article//xref[@rid = $id])" role="warning" id="final-fig-specific-test-4">[final-fig-specific-test-4] There is no citation to <value-of select="$lab"/> Ensure this is added.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#feat-fig-specific-test-4" test="if ($article-type = $features-article-types) then (not(ancestor::article//xref[@rid = $id]))         else ()" role="warning" id="feat-fig-specific-test-4">[feat-fig-specific-test-4] There is no citation to <value-of select="if (label) then label else 'figure.'"/> Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-specific-test-6" test="($fol-sib/local-name() = 'p') and ($fol-sib/*/local-name() = 'disp-formula') and (count($fol-sib/*[1]/preceding-sibling::text()) = 0) and (not(matches($pre-sib,'\.\p{Zs}*?$|\?\p{Zs}*?$|!\p{Zs}*?$')))" role="warning" id="fig-specific-test-6">[fig-specific-test-6] <value-of select="$lab"/> is immediately followed by a display formula, and preceded by a paragraph which does not end with punctuation. Should it should be moved after the display formula or after the para following the display formula?</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-specific-test-5" test="($fol-sib/local-name() = 'disp-formula') and (not(matches($pre-sib,'\.\p{Zs}*?$|\?\p{Zs}*?$|!\p{Zs}*?$')))" role="warning" id="fig-specific-test-5">[fig-specific-test-5] <value-of select="$lab"/> is immediately followed by a display formula, and preceded by a paragraph which does not end with punctuation. Should it should be moved after the display formula or after the para following the display formula?</report>
      
      <report test="not($article-type = $notice-article-types) and ancestor::article//xref[(ancestor::caption or ancestor::table-wrap) and @rid = $id] and not(ancestor::article//xref[(@rid = $id) and not(ancestor::caption) and not(ancestor::table-wrap)])" role="warning" id="fig-specific-test-7">[fig-specific-test-7] <value-of select="$lab"/> is only cited in a table or the caption of an object. Please ask the authors for citation in the main text.</report>
  
    </rule></pattern><pattern id="fig-label-tests-pattern"><rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]/label" id="fig-label-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-label-test-1" test="matches(.,'^Figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" role="error" id="fig-label-test-1">[fig-label-test-1] fig label must be in the format 'Figure 0.', 'Chemical structure 0.', or 'Scheme 0'.</assert>
    </rule></pattern><pattern id="fig-sup-tests-pattern"><rule context="article/body//fig[@specific-use='child-fig']" id="fig-sup-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(parent::fig-group/fig[@specific-use='child-fig'])"/>
      <let name="pos" value="$count - count(following-sibling::fig[@specific-use='child-fig'])"/>
      <let name="label-conforms" value="matches(label[1],'^Figure [\d]+—figure supplement [\d]+')"/>
      <let name="no" value="substring-after(@id,'s')"/>
      <let name="parent-fig-no" value="substring-after(parent::fig-group/fig[not(@specific-use='child-fig')][1]/@id,'fig')"/>
      <let name="label-no" value="replace(substring-after(label[1],'supplement'),'[^\d]','')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-sup-test-1" test="parent::fig-group" role="error" id="fig-sup-test-1">[fig-sup-test-1] fig supplement is not a child of fig-group. This cannot be correct.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-sup-test-2" test="$label-conforms" role="error" id="fig-sup-test-2">[fig-sup-test-2] fig in the body of the article which has a @specific-use='child-fig' must have a label in the format 'Figure 0—figure supplement 0.' (where 0 is one or more digits).</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-sup-test-3" test="starts-with(label[1],concat('Figure ',$parent-fig-no))" role="error" id="fig-sup-test-3">[fig-sup-test-3] <value-of select="label"/> does not start with the main figure number it is associated with - <value-of select="concat('Figure ',$parent-fig-no)"/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-sup-test-4" test="if ($article-type = $notice-article-types) then ()         else $no != string($pos)" role="error" id="fig-sup-test-4">[fig-sup-test-4] <value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other figures it is placed in position <value-of select="$pos"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-sup-test-5" test="if ($article-type = $notice-article-types) then ()         else ($label-conforms and ($label-no != string($pos)))" role="error" id="fig-sup-test-5">[fig-sup-test-5] <value-of select="label"/> is in position <value-of select="$pos"/>, which means either the label or the placement incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-sup-test-6" test="$label-conforms and ($no != $label-no)" role="error" id="fig-sup-test-6">[fig-sup-test-6] <value-of select="label"/> label ends with <value-of select="$label-no"/>, but the id (<value-of select="@id"/>) ends with <value-of select="$no"/>, so one must be incorrect.</report>
      
    </rule></pattern><pattern id="rep-fig-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]//fig" id="rep-fig-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-test-2" test="label" role="error" flag="dl-ar" id="resp-fig-test-2">[resp-fig-test-2] fig must have a label.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#reply-fig-test-2" test="matches(label[1],'^Author response image [0-9]{1,3}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" role="error" flag="dl-ar" id="reply-fig-test-2">[reply-fig-test-2] fig label in author response must be in the format 'Author response image 1.', or 'Chemical Structure 1.', or 'Scheme 1.'.</assert>
      
    </rule></pattern><pattern id="dec-fig-tests-pattern"><rule context="sub-article[@article-type='decision-letter']//fig" id="dec-fig-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#dec-fig-test-1" test="label" role="error" flag="dl-ar" id="dec-fig-test-1">[dec-fig-test-1] fig must have a label.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#dec-fig-test-2" test="matches(label[1],'^Decision letter image [0-9]{1,3}\.$')" role="error" flag="dl-ar" id="dec-fig-test-2">[dec-fig-test-2] fig label in author response must be in the format 'Decision letter image 1.'.</assert>
      
    </rule></pattern><pattern id="box-fig-tests-pattern"><rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]/label" id="box-fig-tests"> 
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#box-fig-test-1" test="matches(.,'^Box \d{1,4}—figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" role="error" id="box-fig-test-1">[box-fig-test-1] label for fig inside boxed-text must be in the format 'Box 1—figure 1.', or 'Chemical structure 1.', or 'Scheme 1'.</assert>
    </rule></pattern><pattern id="app-fig-tests-pattern"><rule context="article//app//fig[not(@specific-use='child-fig')]/label" id="app-fig-tests"> 
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-test-1" test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix [A-Z]—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$|^Appendix \d{1,4}—chemical structure \d{1,4}\.$|^Appendix \d{1,4}—scheme \d{1,4}\.$|^Appendix [A-Z]—chemical structure \d{1,4}\.$|^Appendix [A-Z]—scheme \d{1,4}\.$|^Appendix—chemical structure \d{1,4}\.$|^Appendix—scheme \d{1,4}\.$')" role="error" id="app-fig-test-1">[app-fig-test-1] label for fig inside appendix must be in the format 'Appendix 1—figure 1.', 'Appendix A—figure 1.', or 'Appendix 1—chemical structure 1.', or 'Appendix A—scheme 1'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-test-2" test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$') and not(starts-with(.,ancestor::app/title))" role="error" id="app-fig-test-2">[app-fig-test-2] label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure is placed in the incorrect appendix or the label is incorrect.</report>
    </rule></pattern><pattern id="app-fig-sup-tests-pattern"><rule context="article//app//fig[@specific-use='child-fig']/label" id="app-fig-sup-tests"> 
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-sup-test-1" test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}—figure supplement \d{1,4}\.$|^Appendix—figure \d{1,4}—figure supplement \d{1,4}\.$')" role="error" id="app-fig-sup-test-1">[app-fig-sup-test-1] label for fig inside appendix must be in the format 'Appendix 1—figure 1—figure supplement 1.'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-sup-test-2" test="starts-with(.,ancestor::app/title)" role="error" id="app-fig-sup-test-2">[app-fig-sup-test-2] label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure is placed in the incorrect appendix or the label is incorrect.</assert>
    </rule></pattern><pattern id="app-fig-pos-tests-pattern"><rule context="article//app//fig[not(@specific-use='child-fig')]" id="app-fig-pos-tests"> 
      <let name="id" value="@id"/>
      <let name="app-id" value="ancestor::app/@id"/>
      <let name="count" value="count(ancestor::app//fig[matches(label[1],'figure \d{1,4}\.$')])"/>
      <let name="pos" value="$count - count(following::fig[ancestor::app/@id = $app-id and matches(label[1],'figure \d{1,4}\.$')])"/>
      <let name="no" value="substring-after($id,'fig')"/>
      
      
      
      <report test="if ($count = 0) then ()         else if (not(matches($id,'^app[0-9]{1,3}fig[0-9]{1,3}$'))) then ()         else $no != string($pos)" role="error" id="final-app-fig-pos-test">[final-app-fig-pos-test] <value-of select="replace(label[1],'\.','')"/> does not appear in sequence which is incorrect. Relative to the other figures in the same appendix it is placed in position <value-of select="$pos"/>.</report>
      
    </rule></pattern><pattern id="fig-permissions-pattern"><rule context="permissions[not(parent::article-meta)]" id="fig-permissions">
      <let name="label" value="if (parent::*/label[1]) then replace(parent::*/label[1],'\.$','') else parent::*/local-name()"/>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-1" test="copyright-statement and (not(copyright-year) or not(copyright-holder))" role="error" id="fig-permissions-test-1">[fig-permissions-test-1] permissions for <value-of select="$label"/> has a copyright-statement, but not a copyright-year or copyright-holder which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-2" test="copyright-year and (not(copyright-statement) or not(copyright-holder))" role="error" id="fig-permissions-test-2">[fig-permissions-test-2] permissions for <value-of select="$label"/> has a copyright-year, but not a copyright-statement or copyright-holder which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-3" test="copyright-holder and (not(copyright-statement) or not(copyright-year))" role="error" id="fig-permissions-test-3">[fig-permissions-test-3] permissions for <value-of select="$label"/> has a copyright-holder, but not a copyright-statement or copyright-year which is incorrect.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-4" test="license/license-p" role="error" id="fig-permissions-test-4">[fig-permissions-test-4] permissions for <value-of select="$label"/> must contain a license-p element.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-5" test="count(copyright-statement) gt 1" role="error" id="fig-permissions-test-5">[fig-permissions-test-5] permissions for <value-of select="$label"/> has <value-of select="count(copyright-statement)"/> &lt;copyright-statement&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-6" test="count(copyright-holder) gt 1" role="error" id="fig-permissions-test-6">[fig-permissions-test-6] permissions for <value-of select="$label"/> has <value-of select="count(copyright-holder)"/> &lt;copyright-holder&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-7" test="count(copyright-year) gt 1" role="error" id="fig-permissions-test-7">[fig-permissions-test-7] permissions for <value-of select="$label"/> has <value-of select="count(copyright-year)"/> &lt;copyright-year&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-8" test="count(license) gt 1" role="error" id="fig-permissions-test-8">[fig-permissions-test-8] permissions for <value-of select="$label"/> has <value-of select="count(license)"/> &lt;license&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-9" test="(count(license) = 1) and not(license/license-p)" role="error" id="fig-permissions-test-9">[fig-permissions-test-9] permissions for <value-of select="$label"/> has a &lt;license&gt; element, but not &lt;license-p&gt; element, which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-10" test="count(license/license-p) gt 1" role="error" id="fig-permissions-test-10">[fig-permissions-test-10] permissions for <value-of select="$label"/> has <value-of select="count(license-p)"/> &lt;license-p&gt; elements, when there can only be 0 or 1.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-11" test="copyright-statement or license" role="error" id="fig-permissions-test-11">[fig-permissions-test-11] Asset level permissions must either have a &lt;copyright-statement&gt; and/or a &lt;license&gt; element, but those for <value-of select="$label"/> have neither.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-notification" test="." role="info" id="permissions-notification">[permissions-notification] <value-of select="$label"/> has permissions - '<value-of select="if (license/license-p) then license/license-p else if (copyright-statement) then copyright-statement else ()"/>'.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-parent" test="parent::*/local-name() = ('fig', 'media', 'table-wrap', 'boxed-text', 'supplementary-material')" role="error" id="permissions-parent">[permissions-parent] permissions is not allowed as a child of <value-of select="parent::*/local-name()"/></assert>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-14" test="copyright-statement" role="warning" id="fig-permissions-test-14">[fig-permissions-test-14] permissions for <value-of select="$label"/> does not contain a &lt;copyright-statement&gt; element. Is this correct? This would usually only be the case in CC0 licenses.</assert>
      
    </rule></pattern><pattern id="fig-permissions-2-pattern"><rule context="permissions[not(parent::article-meta) and copyright-year and copyright-holder]/copyright-statement" id="fig-permissions-2">
      <let name="label" value="if (parent::*/label[1]) then replace(parent::*/label[1],'\.$','') else parent::*/local-name()"/>
      <let name="text" value="concat('© ',parent::*/copyright-year[1],', ',parent::*/copyright-holder[1])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-15" test="contains(.,$text)" role="error" id="fig-permissions-test-15">[fig-permissions-test-15] The &lt;copyright-statement&gt; element in the permissions for <value-of select="$label"/> does not contain the text '<value-of select="$text"/>' (a concatenation of '© ', copyright-year, a comma and space, and copyright-holder).</assert>
    </rule></pattern><pattern id="permissions-2-pattern"><rule context="permissions[not(parent::article-meta) and copyright-statement and not(license[1]/ali:license_ref[1][contains(.,'creativecommons.org')]) and not(contains(license[1]/@xlink:href,'creativecommons.org'))]" id="permissions-2">
      <let name="label" value="if (parent::*/label[1]) then replace(parent::*/label[1],'\.$','') else parent::*/local-name()"/>
      
      <assert see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-12" test="matches(license[1]/license-p[1],'[Ff]urther reproduction of (this|these) (panels?|illustrations?) would need permission from the copyright holder\.$|[Ff]urther reproduction of this figure would (need|require) permission from the copyright holder\.$')" role="warning" id="fig-permissions-test-12">[fig-permissions-test-12] <value-of select="$label"/> permissions - the &lt;license-p&gt; for all rights reserved type permissions should usually end with 'further reproduction of this panel/illustration/figure would need permission from the copyright holder.', but <value-of select="$label"/>'s doesn't. Is this correct? (There is no 'https://creativecommons.org/' type link on the license element or in an ali:license_ref so presumed ARR.)</assert>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#fig-permissions-test-13" test="license//ext-link[contains(@xlink:href,'creativecommons.org')]" role="warning" id="fig-permissions-test-13">[fig-permissions-test-13] <value-of select="$label"/> permissions - the &lt;license-p&gt; contains a CC link, but the license does not have an ali:license_ref element, which is very likely incorrect.</report>
      
    </rule></pattern><pattern id="permissions-3a-pattern"><rule context="permissions[not(parent::article-meta)]//ali:license_ref" id="permissions-3a">
      <let name="article-license" value="ancestor::article//article-meta//permissions//ali:license_ref"/>
      <let name="label" value="if (ancestor::permissions[1]/parent::*/label[1]) then replace(ancestor::permissions[1]/parent::*/label[1],'\.$','') else ancestor::permissions[1]/parent::*/local-name()"/>
      
      <report test=".=$article-license" role="error" id="block-permish-ali-license">[block-permish-ali-license] ali:license_ref in permissions for <value-of select="$label"/> is the same as the license link for the article - <value-of select="."/> - which is incorrect.</report>
      
    </rule></pattern><pattern id="permissions-3b-pattern"><rule context="permissions[not(parent::article-meta)]//license-p//ext-link" id="permissions-3b">
      <let name="article-license" value="ancestor::article//article-meta//permissions//ali:license_ref"/>
      <let name="label" value="if (ancestor::permissions[1]/parent::*/label[1]) then replace(ancestor::permissions[1]/parent::*/label[1],'\.$','') else ancestor::permissions[1]/parent::*/local-name()"/>
      
      <report test=".=$article-license or @xlink:href=$article-license" role="error" id="block-permish-license-p-link">[block-permish-license-p-link] ext-link in license text in permissions for <value-of select="$label"/> is the same as the license link for the article - <value-of select="$article-license"/> - which is incorrect.</report>
      
    </rule></pattern><pattern id="permissions-3c-pattern"><rule context="permissions[not(parent::article-meta)]//license" id="permissions-3c">
      <let name="article-license" value="ancestor::article//article-meta//permissions//ali:license_ref"/>
      <let name="label" value="if (ancestor::permissions[1]/parent::*/label[1]) then replace(ancestor::permissions[1]/parent::*/label[1],'\.$','') else ancestor::permissions[1]/parent::*/local-name()"/>
      
      <report test="@xlink:href=$article-license" role="error" id="block-permish-license-link">[block-permish-license-link] license link (the xlink:href attribute value on the license element) in permissions for <value-of select="$label"/> is the same as the license link for the article - <value-of select="$article-license"/> - which is incorrect.</report>
      
    </rule></pattern><pattern id="fig-caption-tests-pattern"><rule context="fig/caption/p[not(child::supplementary-material)]" id="fig-caption-tests">
      <let name="label" value="replace(ancestor::fig[1]/label,'\.$','')"/>
      <let name="no-panels" value="replace(.,'\([a-zA-Z]\)|\([a-zA-Z]\-[a-zA-Z]\)','')"/>
      <let name="text-tokens" value="for $x in tokenize($no-panels,'\. ') return         if (string-length($x) lt 3) then ()         else if (matches($x,'^\p{Zs}{1,3}?[a-z]')) then $x         else ()"/>
      <let name="panel-list" value="e:list-panels(.)"/>
      
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-caption-test-1" test="count($text-tokens) = 0" role="warning" id="fig-caption-test-1">[fig-caption-test-1] Caption for <value-of select="$label"/> contains what looks like a lower case letter at the start of a sentence - <value-of select="string-join($text-tokens,'; ')"/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-caption-test-2" test="contains(lower-case(.),'image credit') and not(parent::caption/parent::fig/attrib)" role="warning" id="fig-caption-test-2">[fig-caption-test-2] Caption for <value-of select="$label"/> contains what looks like an image credit. It's quite likely that this should be captured in an &lt;attrib&gt; element instead - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#h7hrp-fig-caption-test-3" test="$panel-list//*:item" role="warning" id="fig-caption-test-3">[fig-caption-test-3] Panel indicators at the start of sentences in captions should be surrounded by parentheses. The caption for <value-of select="$label"/> may have some panels without parentheses. Check <value-of select="string-join(for $x in $panel-list//*:item return concat('&quot;',$x/@token,'&quot;',' in ','&quot;',$x,'&quot;'),';')"/></report>

    </rule></pattern><pattern id="biorender-tests-pattern"><rule context="article" id="biorender-tests">
      
      <let name="article-text" value="string-join(for $x in self::*/*[local-name() = 'body' or local-name() = 'back']//*           return           if ($x/ancestor::ref-list) then ()           else if ($x/ancestor::caption[parent::fig] or $x/ancestor::permissions[parent::fig]) then ()           else $x/text(),'')"/>

       <report test="matches(lower-case($article-text),'biorend[eo]r')" role="warning" id="biorender-check">[biorender-check] Article text contains a reference to BioRender. Any figures created with BioRender should include a sentence in the caption in the format: "Created with BioRender.com/{figure-code}".</report>

    </rule></pattern><pattern id="biorender-fig-tests-pattern"><rule context="fig/caption/p[not(child::supplementary-material)] | fig/attrib" id="biorender-fig-tests">
      <let name="is-cc0" value="contains(lower-case(ancestor::article[1]/front[1]/descendant::permissions[1]/license[1]/@xlink:href),'creativecommons.org/publicdomain/zero/')"/>
      <let name="label" value="replace(ancestor::fig[1]/label,'\.$','')"/>    

      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#hm6gy-pre-fig-caption-test-4" test="$is-cc0 and matches(lower-case(.),'biorend[eo]r') and not(ancestor::fig/permissions[matches(lower-case(.),'biorend[eo]r')])" role="error" id="fig-caption-test-4">[fig-caption-test-4] Caption or attrib for <value-of select="$label"/> contains what looks like a mention of BioRender. Since the overall license for the article is CC0, and BioRender can (only) be licensed CC BY, a permissions statement needs to be added (e.g. © <value-of select="year-from-date(current-date())"/>, {authors}. Parts of this image created with BioRender are made available under a Creative Commons Attribution License, which permits unrestricted use and redistribution provided that the original author and source are credited.).</report>

      

      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty?shr=rqdavyty#hquuu-final-fig-biorender-test-1" test="not(descendant::ext-link[matches(lower-case(@xlink:href),'biorender.com/[a-z\d]')]) and (descendant::ext-link[matches(lower-case(@xlink:href),'biorender.com')] or matches(lower-case(.),'biorender.com'))" role="error" id="final-fig-biorender-test-1">[final-fig-biorender-test-1] Caption or attrib for <value-of select="$label"/> contains a BioRender link, but it does not look like a BioRender 'unique figure citation URL'.</report>

    </rule></pattern><pattern id="fig-panel-tests-pattern"><rule context="fig/caption/p/bold" id="fig-panel-tests">
      <let name="first-character" value="substring(.,1, 1)"/>
      <let name="last-character" value="substring(., string-length(.), 1)"/>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-panel-test-1" test="($first-character= ('(', ')', '.', ',')) or ($last-character = ('(', ')', '.', ','))" role="warning" id="fig-panel-test-1">[fig-panel-test-1] Bold text in the caption for <value-of select="replace(ancestor::fig[1]/label,'\.$','')"/> starts and/or ends with punctuation - <value-of select="."/> - is that correct? Or should the punctuation be unbolded?</report>
      
    </rule></pattern>
  
  <pattern id="ra-body-tests-pattern"><rule context="article[@article-type='research-article']/body" id="ra-body-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="method-count" value="count(sec[@sec-type='materials|methods']) + count(sec[@sec-type='methods']) + count(sec[@sec-type='model'])"/>
      <let name="res-disc-count" value="count(sec[@sec-type='results']) + count(sec[@sec-type='discussion'])"/>
    
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#ra-sec-test-1" test="count(sec) = 0" role="error" id="ra-sec-test-1">[ra-sec-test-1] At least one sec should be present in body for research-article content.</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#ra-sec-test-2" test="if ($type = ('Short Report','Scientific Correspondence','Feature Article')) then ()         else count(sec[@sec-type='intro']) != 1" role="warning" id="ra-sec-test-2">[ra-sec-test-2] <value-of select="$type"/> doesn't have child sec[@sec-type='intro'] in the main body. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#ra-sec-test-3" test="if ($type = ('Short Report','Scientific Correspondence','Feature Article')) then ()         else $method-count != 1" role="warning" id="ra-sec-test-3">[ra-sec-test-3] main body in <value-of select="$type"/> content doesn't have a child sec with @sec-type whose value is either 'materials|methods', 'methods' or 'model'. Is this correct?.</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#ra-sec-test-4" test="if ($type = ('Short Report','Scientific Correspondence','Feature Article')) then ()         else if (sec[@sec-type='results|discussion']) then ()         else $res-disc-count != 2" role="warning" id="ra-sec-test-4">[ra-sec-test-4] main body in <value-of select="$type"/> content doesn't have either a child sec[@sec-type='results|discussion'] or a sec[@sec-type='results'] and a sec[@sec-type='discussion']. Is this correct?</report>
    
    </rule></pattern><pattern id="medicine-section-tests-pattern"><rule context="article[@article-type='research-article' and descendant::article-meta[not(//subj-group[@subj-group-type='display-channel']/subject[lower-case(.)='feature article']) and //subj-group[@subj-group-type='heading']/subject[.=('Medicine','Epidemiology and Global Health')] and history/date[@date-type='received']/@iso-8601-date gt '2021-04-05']]/body/sec" id="medicine-section-tests">
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#medicine-introduction" test="$pos=1 and title[1]!='Introduction'" role="error" id="medicine-introduction">[medicine-introduction] The first top level section in a Medicine article should be 'Introduction'. This one is '<value-of select="title[1]"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#medicine-methods" test="$pos=2 and not(title[1]=('Methods','Materials and methods'))" role="warning" id="medicine-methods">[medicine-methods] The second top level section in a Medicine article should be 'Methods' or 'Materials and methods', but this one is '<value-of select="title[1]"/>'. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#medicine-results" test="$pos=3 and title[1]!='Results'" role="warning" id="medicine-results">[medicine-results] The third top level section in a Medicine article should be 'Results', but this one is '<value-of select="title[1]"/>'. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#medicine-discussion" test="$pos=4 and title[1]!='Discussion'" role="warning" id="medicine-discussion">[medicine-discussion] The fourth top level section in a Medicine article should be 'Discussion', but this one is '<value-of select="title[1]"/>'. Is that correct?</report>
      
    </rule></pattern><pattern id="top-level-sec-tests-pattern"><rule context="body/sec" id="top-level-sec-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
      <let name="allowed-titles" value="('Introduction', 'Results', 'Discussion', 'Materials and methods', 'Results and discussion','Methods', 'Model')"/>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-conformity" test="not($type = ($features-subj,'Review Article',$notice-display-types)) and not(replace(title[1],' ',' ') = $allowed-titles)" role="warning" id="sec-conformity">[sec-conformity] top level sec with title - <value-of select="title"/> - is not a usual title for <value-of select="$type"/> content. Should this be captured as a sub-level of <value-of select="preceding-sibling::sec[1]/title"/>?</report>
      
    </rule></pattern><pattern id="conclusion-sec-tests-pattern"><rule context="article[@article-type='research-article' and not(descendant::article-meta//subj-group[@subj-group-type]/subject=('Feature Article','Review Article','Short Report'))]/body/sec/title" id="conclusion-sec-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="title" value="normalize-space(replace(lower-case(.),' ',' '))"/>
        
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#conclusion-test-1" test="matches($title,'conclusions?')" role="warning" id="conclusion-test-1">[conclusion-test-1] Top level section title has the content '<value-of select="."/>' - should it be made a level 2 section? Potentially as a child of the <value-of select="preceding-sibling::sec[1]/title"/> section?</report>
      
    </rule></pattern><pattern id="conclusion-lower-sec-tests-pattern"><rule context="article[@article-type='research-article' and not(descendant::article-meta//subj-group[@subj-group-type]/subject=('Feature Article','Review Article','Short Report'))]/body//sec/sec//sec/title" id="conclusion-lower-sec-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="title" value="normalize-space(replace(lower-case(.),' ',' '))"/>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#conclusion-test-2" test="matches($title,'conclusions?')" role="warning" id="conclusion-test-2">[conclusion-test-2] Level <value-of select="count(ancestor::sec) + 1"/> section with the title '<value-of select="."/>' should likely be made a level 2 section.</report>
      
    </rule></pattern>
  
  <pattern id="article-title-tests-pattern"><rule context="article-meta//article-title" id="article-title-tests">
      <let name="type" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="specifics" value="('Replication Study','Registered Report',$notice-display-types)"/>
      <let name="count" value="string-length(.)"/>
      
      <report test="($type = $specifics) and not(starts-with(.,e:article-type2title($type)))" role="error" id="article-type-title-test-1">[article-type-title-test-1] title of a '<value-of select="$type"/>' must start with '<value-of select="e:article-type2title($type)"/>'.</report>
      
      <report test="($type = 'Scientific Correspondence') and not(matches(.,'^Comment on|^Response to comment on'))" role="error" id="article-type-title-test-2">[article-type-title-test-2] title of a '<value-of select="$type"/>' must start with 'Comment on' or 'Response to comment on', but this starts with something else - <value-of select="."/>.</report>
      
      <report test="($type = 'Scientific Correspondence') and matches(.,'^Comment on “|^Response to comment on “')" role="error" id="sc-title-test-1">[sc-title-test-1] title of a '<value-of select="$type"/>' contains a left double quotation mark. The original article title must be surrounded by a single roman apostrophe - <value-of select="."/>.</report>
      
      <report test="($type = 'Scientific Correspondence') and matches(.,'”')" role="warning" id="sc-title-test-2">[sc-title-test-2] title of a '<value-of select="$type"/>' contains a right double quotation mark. Is this correct? The original article title must be surrounded by a single roman apostrophe - <value-of select="."/>.</report>
      
      <report test="$count gt 255" role="error" id="absolute-title-length-restriction">[absolute-title-length-restriction] The article title contains <value-of select="$count"/> characters, when the current absolute limit for Continuum is 255.</report>
    </rule></pattern><pattern id="sec-title-tests-pattern"><rule context="sec[@sec-type]/title" id="sec-title-tests">
      <let name="title" value="e:sec-type2title(parent::sec/@sec-type)"/>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-type-title-test" test="if ($title = 'undefined') then ()         else . != $title" role="warning" id="sec-type-title-test">[sec-type-title-test] title of a sec with an @sec-type='<value-of select="parent::sec/@sec-type"/>' should usually be '<value-of select="$title"/>'.</report>
      
    </rule></pattern><pattern id="fig-title-tests-pattern"><rule context="fig/caption/title" id="fig-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label[1]"/>
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\p{Zs}]$',''),'\. '))"/>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-1" test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" role="warning" id="fig-title-test-1">[fig-title-test-1] '<value-of select="$label"/>' appears to have a title which is the beginning of a caption. Is this correct?</report>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-2" test="matches(replace(.,'&quot;',''),'\.$|\?$')" role="error" id="fig-title-test-2">[fig-title-test-2] title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-3" test="matches(.,' vs\.$')" role="warning" id="fig-title-test-3">[fig-title-test-3] title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-4" test="matches(.,'^\p{Zs}')" role="error" id="fig-title-test-4">[fig-title-test-4] title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-5" test="matches(.,'^\p{P}')" role="warning" id="fig-title-test-5">[fig-title-test-5] title for <value-of select="$label"/> begins with punctuation. Is this correct? - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-6" test="matches(.,'^[Pp]anel ')" role="warning" id="fig-title-test-6">[fig-title-test-6] title for <value-of select="$label"/> begins with '<value-of select="substring-before(.,' ')"/>' - <value-of select="."/>. It is very likely that this requires an overall title instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-7" test="string-length(.) gt 250" role="warning" id="fig-title-test-7">[fig-title-test-7] title for <value-of select="$label"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-title-test-8" test="$sentence-count gt 1" role="warning" id="fig-title-test-8">[fig-title-test-8] title for <value-of select="$label"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
      
      <report test="matches(.,'\p{Zs}$')" role="error" id="fig-title-test-9">[fig-title-test-9] The title for <value-of select="$label"/> ends with space(s) which is incorrect - '<value-of select="."/>'.</report>
    </rule></pattern><pattern id="supplementary-material-title-tests-pattern"><rule context="supplementary-material/caption/title" id="supplementary-material-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label[1]"/>
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\p{Zs}]$',''),'\. '))"/>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-title-test-1" test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" role="warning" id="supplementary-material-title-test-1">[supplementary-material-title-test-1] '<value-of select="$label"/>' appears to have a title which is the beginning of a caption. Is this correct?</report>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-title-test-2" test="matches(.,'[\.\?]$')" role="error" id="supplementary-material-title-test-2">[supplementary-material-title-test-2] title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-title-test-3" test="matches(.,' vs\.$')" role="warning" id="supplementary-material-title-test-3">[supplementary-material-title-test-3] title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-title-test-4" test="matches(.,'^\p{Zs}')" role="error" id="supplementary-material-title-test-4">[supplementary-material-title-test-4] title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-title-test-7" test="string-length(.) gt 250" role="warning" id="supplementary-material-title-test-7">[supplementary-material-title-test-7] title for <value-of select="$label"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-title-test-8" test="$sentence-count gt 1" role="warning" id="supplementary-material-title-test-8">[supplementary-material-title-test-8] title for <value-of select="$label"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
      
      <report test="matches(.,'\p{Zs}$')" role="error" id="supplementary-material-title-test-9">[supplementary-material-title-test-9] title for <value-of select="$label"/> ends with space(s), which is not allowed - '<value-of select="."/>'</report>
    </rule></pattern><pattern id="video-title-tests-pattern"><rule context="media/caption/title" id="video-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label[1]"/>
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\p{Zs}]$',''),'\. '))"/>
      
      <report test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" role="warning" id="video-title-test-1">[video-title-test-1] '<value-of select="$label"/>' appears to have a title which is the beginning of a caption. Is this correct?</report>
      
      <assert test="matches(.,'\.$|\?$')" role="error" id="video-title-test-2">[video-title-test-2] title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report test="matches(.,' vs\.$')" role="warning" id="video-title-test-3">[video-title-test-3] title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\p{Zs}')" role="error" id="video-title-test-4">[video-title-test-4] title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
      
      <report test="string-length(.) gt 250" role="warning" id="video-title-test-7">[video-title-test-7] title for <value-of select="$label"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report test="$sentence-count gt 1" role="warning" id="video-title-test-8">[video-title-test-8] title for <value-of select="$label"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
      
      <report test="matches(.,'\p{Zs}$')" role="error" id="video-title-test-9">[video-title-test-9] The title for <value-of select="$label"/> ends with space(s) which is incorrect - '<value-of select="."/>'.</report>
    </rule></pattern><pattern id="ack-title-tests-pattern"><rule context="ack" id="ack-title-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/acknowledgements-49wvb1xt#hddcf-ack-title-test" test="title = 'Acknowledgements'" role="error" id="ack-title-test">[ack-title-test] ack must have a title that contains 'Acknowledgements'. Currently it is '<value-of select="title"/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/acknowledgements-49wvb1xt#hslfn-ack-content-test" test="p[* or not(normalize-space(.)='')]" role="error" id="ack-content-test">[ack-content-test] An Acknowledgements section must contain content. Either add in the missing content or delete the Acknowledgements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/funding-3sv64358#ack-funding" test="p[* or not(normalize-space(.)='')]" role="warning" id="ack-funding">[ack-funding] Please check the acknowledgements section to ensure that all funding information is captured in the funding section.</report>
      
    </rule></pattern><pattern id="ack-content-tests-pattern"><rule context="ack//p" id="ack-content-tests">
      <let name="hit" value="string-join(for $x in tokenize(.,' ') return         if (matches($x,'^[A-Z]{1}\.$')) then $x         else (),', ')"/>
      <let name="hit-count" value="count(for $x in tokenize(.,' ') return         if (matches($x,'^[A-Z]{1}\.$')) then $x         else ())"/>
      
      <report see="https://elifeproduction.slab.com/posts/acknowledgements-49wvb1xt#ht2dv-ack-full-stop-intial-test" test="matches(.,' [A-Z]\. |^[A-Z]\. ')" role="warning" id="ack-full-stop-intial-test">[ack-full-stop-intial-test] p element in Acknowledgements contains what looks like <value-of select="$hit-count"/> initial(s) followed by a full stop. Is it correct? - <value-of select="$hit"/></report>
    </rule></pattern><pattern id="ref-list-title-tests-pattern"><rule context="ref-list" id="ref-list-title-tests">
      <let name="cite-list" value="e:ref-cite-list(.)"/>
      <let name="non-distinct" value="e:non-distinct-citations($cite-list)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#ref-list-title-test" test="title = 'References'" role="warning" id="ref-list-title-test">[ref-list-title-test] reference list usually has a title that is 'References', but currently it is '<value-of select="title"/>' - is that correct?</assert>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#ref-list-distinct-1" test="$non-distinct//*:item" role="error" id="ref-list-distinct-1">[ref-list-distinct-1] In the reference list, each reference must be unique in its citation style (combination of authors and year). If a reference's citation is the same as anothers, a lowercase letter should be suffixed to the year (e.g. Smith et al., 2020a). <value-of select="string-join(for $x in $non-distinct//*:item return concat($x,' with the id ',$x/@id),' and ')"/> does not meet this requirement.</report>
      
    </rule></pattern><pattern id="app-title-tests-pattern"><rule context="app/title" id="app-title-tests">
      
      <assert test="matches(.,'^Appendix$|^Appendix [0-9]$|^Appendix [0-9][0-9]$')" role="error" id="app-title-test">[app-title-test] app title must be in the format 'Appendix 1'. Currently it is '<value-of select="."/>'.</assert>
      
    </rule></pattern><pattern id="fn-group-tests-pattern"><rule context="fn-group" id="fn-group-tests">
      <let name="allowed-content-types" value="('competing-interest','author-contribution','ethics-information')"/>
      
      <assert test="@content-type" role="error" id="fn-content-type-1">[fn-content-type-1] fn-group that is descendant of back must have a content-type attribute.</assert>
      
      <report test="@content-type and not(@content-type=$allowed-content-types)" role="error" id="fn-content-type-2">[fn-content-type-2] fn-group with content-type '<value-of select="@content-type"/>' is not permitted. The only permitted fn-group types are <value-of select="string-join($allowed-content-types,'; ')"/>.</report>
      
      <assert test="parent::back or parent::sec[@sec-type='additional-information' and parent::back]" role="error" id="fn-parent">[fn-parent] fn-group is only allowed as a child of back or as a child of sec[@sec-type='additional-information'] (which in turn is in back). This one is placed as a child of <value-of select="parent::*/name()"/></assert>
      
    </rule></pattern><pattern id="comp-int-title-tests-pattern"><rule context="fn-group[@content-type='competing-interest']" id="comp-int-title-tests">
      
      <assert test="title = 'Competing interests'" role="error" id="comp-int-title-test">[comp-int-title-test] fn-group[@content-type='competing-interests'] must have a title that contains 'Competing interests'. Currently it is '<value-of select="title"/>'.</assert>
    </rule></pattern><pattern id="auth-cont-title-tests-pattern"><rule context="fn-group[@content-type='author-contribution']" id="auth-cont-title-tests">
      
      <assert test="title = 'Author contributions'" role="error" id="auth-cont-title-test">[auth-cont-title-test] fn-group[@content-type='author-contribution'] must have a title that contains 'Author contributions'. Currently it is '<value-of select="title"/>'.</assert>
    </rule></pattern><pattern id="ethics-title-tests-pattern"><rule context="fn-group[@content-type='ethics-information']" id="ethics-title-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-title-test" test="title = 'Ethics'" role="error" id="ethics-title-test">[ethics-title-test] fn-group[@content-type='ethics-information'] must have a title that contains 'Ethics'. Currently it is '<value-of select="title"/>'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-broken-unicode-test" test="matches(.,'&amp;#x\d')" role="warning" id="ethics-broken-unicode-test">[ethics-broken-unicode-test] Ethics statement likely contains a broken unicode - <value-of select="."/>.</report>
    </rule></pattern><pattern id="ed-eval-title-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/title-group" id="ed-eval-title-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-title-test" test="article-title = (&quot;Editor's evaluation&quot;,'eLife assessment','eLife Assessment')" role="error" flag="dl-ar" id="ed-eval-title-test">[ed-eval-title-test] A sub-article[@article-type='editor-report'] must have the title "eLife Assessment" or "Editor's evaluation". Currently it is <value-of select="article-title"/>.</assert>
    </rule></pattern><pattern id="dec-letter-title-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/title-group" id="dec-letter-title-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-title-test" test="article-title = 'Decision letter'" role="error" flag="dl-ar" id="dec-letter-title-test">[dec-letter-title-test] title-group must contain article-title which contains 'Decision letter'. Currently it is <value-of select="article-title"/>.</assert>
    </rule></pattern><pattern id="reply-title-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/front-stub/title-group" id="reply-title-tests">
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-title-test" test="article-title = 'Author response'" role="error" flag="dl-ar" id="reply-title-test">[reply-title-test] title-group must contain article-title which contains 'Author response'. Currently it is <value-of select="article-title"/>.</assert>
      
    </rule></pattern><pattern id="title-child-tests-pattern"><rule context="title/*" id="title-child-tests">
      <let name="allowed-elems" value="('sub','xref','sup','bold','italic','inline-formula','underline','sc','ext-link','monospace','mml:math')"/>
     
      <assert test="name()=$allowed-elems" role="error" id="title-child-conformance">[title-child-conformance] <name/> is not allowed in a title element. The only permitted elements are <value-of select="string-join($allowed-elems,', ')"/>.</assert>
      
    </rule></pattern>
  
  <pattern id="award-group-ids-pattern"><rule context="funding-group/award-group" id="award-group-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/funding-3sv64358#award-group-test-1" test="matches(substring-after(@id,'fund'),'^[0-9]{1,2}$')" role="error" id="award-group-test-1">[award-group-test-1] award-group must have an @id, the value of which conforms to the convention 'fund', followed by a digit. <value-of select="@id"/> does not conform to this.</assert>
    </rule></pattern><pattern id="fig-ids-pattern"><rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]" id="fig-ids">
      
      <!-- Needs updating once scheme/checmical structure ids have been updated -->
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-id-test-1" test="matches(@id,'^fig[0-9]{1,3}$|^C[0-9]{1,3}$|^S[0-9]{1,3}$')" role="error" id="fig-id-test-1">[fig-id-test-1] fig must have an @id in the format fig0 (or C0 for chemical structures, or S0 for Schemes). <value-of select="@id"/> does not conform to this.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-id-test-2" test="matches(label[1],'[Ff]igure') and not(matches(@id,'^fig[0-9]{1,3}$'))" role="error" id="fig-id-test-2">[fig-id-test-2] fig must have an @id in the format fig0. <value-of select="@id"/> does not conform to this.</report>
      
      <!--<report test="matches(label[1],'[Cc]hemical [Ss]tructure') and not(matches(@id,'^chem[0-9]{1,3}$'))" 
        role="warning"
        id="fig-id-test-3">Chemical structures must have an @id in the format chem0.</report>-->
      
      <!--<report test="matches(label[1],'[Ss]cheme') and not(matches(@id,'^scheme[0-9]{1,3}$'))" 
        role="warning"
        id="fig-id-test-4">Schemes must have an @id in the format scheme0. <value-of select="@id"/> does not conform to this.</report>-->
    </rule></pattern><pattern id="fig-sup-ids-pattern"><rule context="article/body//fig[@specific-use='child-fig'][not(ancestor::boxed-text)]" id="fig-sup-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#fig-sup-id-test" test="matches(@id,'^fig[0-9]{1,3}s[0-9]{1,3}$')" role="error" id="fig-sup-id-test">[fig-sup-id-test] figure supplement must have an @id in the format fig0s0. <value-of select="@id"/> does not conform to this.</assert>
    </rule></pattern><pattern id="box-fig-ids-pattern"><rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]" id="box-fig-ids">
      <let name="box-id" value="ancestor::boxed-text/@id"/> 
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#box-fig-id-1" test="matches(@id,'^box[0-9]{1,3}fig[0-9]{1,3}$')" role="error" id="box-fig-id-1">[box-fig-id-1] fig must have @id in the format box0fig0. <value-of select="@id"/> does not conform to this.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#box-fig-id-2" test="contains(@id,$box-id)" role="error" id="box-fig-id-2">[box-fig-id-2] fig id (<value-of select="@id"/>) does not contain its ancestor boxed-text id. Please ensure the first part of the id contains '<value-of select="$box-id"/>'.</assert>
    </rule></pattern><pattern id="app-fig-ids-pattern"><rule context="article/back//app//fig[not(@specific-use='child-fig')]" id="app-fig-ids">
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-id-test-1" test="matches(label[1],'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix [A-Z]—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$') and not(matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}$'))" role="error" id="app-fig-id-test-1">[app-fig-id-test-1] figures in appendices must have an @id in the format app0fig0. <value-of select="@id"/> does not conform to this.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-id-test-2" test="matches(label[1],'[Cc]hemical [Ss]tructure') and not(matches(@id,'^app[0-9]{1,3}chem[0-9]{1,3}$'))" role="warning" id="app-fig-id-test-2">[app-fig-id-test-2] Chemical structures must have an @id in the format app0chem0. <value-of select="@id"/> does not conform to this.</report>
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-id-test-3" test="matches(label[1],'[Ss]cheme') and not(matches(@id,'^app[0-9]{1,3}scheme[0-9]{1,3}$'))" role="warning" id="app-fig-id-test-3">[app-fig-id-test-3] Schemes must have an @id in the format app0scheme0. <value-of select="@id"/> does not conform to this.</report>
    </rule></pattern><pattern id="app-fig-sup-ids-pattern"><rule context="article/back//app//fig[@specific-use='child-fig']" id="app-fig-sup-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#app-fig-sup-id-test" test="matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}s[0-9]{1,3}$')" role="error" id="app-fig-sup-id-test">[app-fig-sup-id-test] figure supplements in appendices must have an @id in the format app0fig0s0. <value-of select="@id"/> does not conform to this.</assert>
    </rule></pattern><pattern id="rep-fig-ids-pattern"><rule context="sub-article//fig[not(@specific-use='child-fig')]" id="rep-fig-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-id-test" test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')" role="error" flag="dl-ar" id="resp-fig-id-test">[resp-fig-id-test] fig in decision letter/author response must have @id in the format respfig0, or sa0fig0. <value-of select="@id"/> does not conform to this.</assert>
    </rule></pattern><pattern id="rep-fig-sup-ids-pattern"><rule context="sub-article//fig[@specific-use='child-fig']" id="rep-fig-sup-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-sup-id-test" test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')" role="error" flag="dl-ar" id="resp-fig-sup-id-test">[resp-fig-sup-id-test] figure supplement in decision letter/author response must have @id in the format respfig0s0 or sa0fig0s0. <value-of select="@id"/> does not conform to this.</assert>
      
    </rule></pattern><pattern id="video-ids-pattern"><rule context="article/body//media[(@mimetype='video') and not(ancestor::boxed-text) and not(parent::fig-group)]" id="video-ids">
      
      <assert test="matches(@id,'^video[0-9]{1,3}$')" role="error" id="video-id-test">[video-id-test] main video must have an @id in the format video0.  <value-of select="@id"/> does not conform to this.</assert>
    </rule></pattern><pattern id="video-sup-ids-pattern"><rule context="article/body//fig-group/media[(@mimetype='video') and not(ancestor::boxed-text)]" id="video-sup-ids">
      <let name="id-prefix" value="parent::fig-group/fig[1]/@id"/>
      
      <assert test="matches(@id,'^fig[0-9]{1,3}video[0-9]{1,3}$')" role="error" id="video-sup-id-test-1">[video-sup-id-test-1] video supplement must have an @id in the format fig0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,$id-prefix)" role="error" id="video-sup-id-test-2">[video-sup-id-test-2] video supplement must have an @id which begins with the id of its parent fig. <value-of select="@id"/> does not start with <value-of select="$id-prefix"/>.</assert>
    </rule></pattern><pattern id="app-video-ids-pattern"><rule context="article/back//app//media[(@mimetype='video') and not(parent::fig-group)]" id="app-video-ids">
      <let name="id-prefix" value="substring-after(ancestor::app[1]/@id,'-')"/>
      
      <assert test="matches(@id,'^app[0-9]{1,3}video[0-9]{1,3}$')" role="error" id="app-video-id-test-1">[app-video-id-test-1] video in appendix must have an @id in the format app0video0. <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,concat('app',$id-prefix))" role="error" id="app-video-id-test-2">[app-video-id-test-2] video supplement must have an @id which begins with the id of its ancestor appendix. <value-of select="@id"/> does not start with <value-of select="concat('app',$id-prefix)"/>.</assert>
    </rule></pattern><pattern id="app-video-sup-ids-pattern"><rule context="article/back//app//media[(@mimetype='video') and (parent::fig-group)]" id="app-video-sup-ids">
      <let name="id-prefix-1" value="substring-after(ancestor::app[1]/@id,'-')"/>
      <let name="id-prefix-2" value="parent::fig-group/fig[1]/@id"/>
      
      <assert test="matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}video[0-9]{1,3}$')" role="error" id="app-video-sup-id-test-1">[app-video-sup-id-test-1] video supplement must have an @id in the format app0fig0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,concat('app',$id-prefix-1))" role="error" id="app-video-sup-id-test-2">[app-video-sup-id-test-2] video supplement must have an @id which begins with the id of its ancestor appendix. <value-of select="@id"/> does not start with <value-of select="concat('app',$id-prefix-1)"/>.</assert>
      
      <assert test="starts-with(@id,$id-prefix-2)" role="error" id="app-video-sup-id-test-3">[app-video-sup-id-test-3] video supplement must have an @id which begins with the id of its ancestor appendix, followed by id of its parent fig. <value-of select="@id"/> does not start with <value-of select="$id-prefix-2"/>.</assert>
    </rule></pattern><pattern id="box-vid-ids-pattern"><rule context="article/body//boxed-text//media[(@mimetype='video')]" id="box-vid-ids">
      <let name="box-id" value="ancestor::boxed-text/@id"/> 
      
      <assert test="matches(@id,'^box[0-9]{1,3}video[0-9]{1,3}$')" role="error" id="box-vid-id-1">[box-vid-id-1] video must have @id in the format box0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,$box-id)" role="error" id="box-vid-id-2">[box-vid-id-2] video id does not start with its ancestor boxed-text id. Please ensure the first part of the id contains '<value-of select="$box-id"/>'.</assert>
    </rule></pattern><pattern id="related-articles-ids-pattern"><rule context="related-article" id="related-articles-ids">
      
      <assert test="matches(@id,'^ra\d$')" role="error" id="related-articles-test-7">[related-articles-test-7] related-article element must contain a @id, the value of which should be in the form ra0.</assert>
    </rule></pattern><pattern id="aff-ids-pattern"><rule context="aff[not(parent::contrib)]" id="aff-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h2lcw-aff-id-test" test="if (label) then @id = concat('aff',label[1])         else starts-with(@id,'aff')" role="error" id="aff-id-test">[aff-id-test] aff @id must be a concatenation of 'aff' and the child label value. In this instance it should be <value-of select="concat('aff',label[1])"/>.</assert>
    </rule></pattern><pattern id="fn-ids-pattern"><rule context="fn" id="fn-ids">
      <let name="type" value="@fn-type"/>
      <let name="parent" value="self::*/parent::*/local-name()"/>
      
      <report test="if ($parent = 'table-wrap-foot') then ()         else if ($type = 'conflict') then not(matches(@id,'^conf[0-9]{1,3}$'))         else if ($type = 'con') then         if ($parent = 'author-notes') then not(matches(@id,'^equal-contrib[0-9]{1,3}$'))         else not(matches(@id,'^con[0-9]{1,3}$'))         else if ($type = 'present-address') then not(matches(@id,'^pa[0-9]{1,3}$'))         else if ($type = 'COI-statement') then not(matches(@id,'^conf[0-9]{1,3}$'))         else if ($type = 'fn') then not(matches(@id,'^fn[0-9]{1,3}$'))         else ()" role="error" id="fn-id-test">[fn-id-test] fn @id is not in the correct format. Refer to eLife kitchen sink for correct format.</report>
    </rule></pattern><pattern id="disp-formula-ids-pattern"><rule context="disp-formula" id="disp-formula-ids">
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#disp-formula-id-test" test="not(ancestor::sub-article) and not(matches(@id,'^equ[0-9]{1,9}$'))" role="error" id="disp-formula-id-test">[disp-formula-id-test] disp-formula @id must be in the format 'equ0'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#sub-disp-formula-id-test" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-disp-formula-id-test">[sub-disp-formula-id-test] disp-formula @id must be in the format 'sa0equ0' when in a sub-article.  <value-of select="@id"/> does not conform to this.</report>
    </rule></pattern><pattern id="mml-math-ids-pattern"><rule context="disp-formula/mml:math" id="mml-math-ids">
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#mml-math-id-test" test="not(ancestor::sub-article) and not(matches(@id,'^m[0-9]{1,9}$'))" role="error" id="mml-math-id-test">[mml-math-id-test] mml:math @id in disp-formula must be in the format 'm0'.  <value-of select="@id"/> does not conform to this.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#sub-mml-math-id-test" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-mml-math-id-test">[sub-mml-math-id-test] mml:math @id in disp-formula must be in the format 'sa0m0'.  <value-of select="@id"/> does not conform to this.</report>
    </rule></pattern><pattern id="app-table-wrap-ids-pattern"><rule context="app//table-wrap[label]" id="app-table-wrap-ids">
      <let name="app-no" value="substring-after(ancestor::app[1]/@id,'-')"/>
    
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#app-table-wrap-id-test-1" test="matches(@id, '^app[0-9]{1,3}table[0-9]{1,3}$|^app[0-9]{1,3}keyresource$|^keyresource$')" role="error" id="app-table-wrap-id-test-1">[app-table-wrap-id-test-1] table-wrap @id in appendix must be in the format 'app0table0' for normal tables, or 'app0keyresource' or 'keyresource' for key resources tables in appendices. <value-of select="@id"/> does not conform to this.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#app-table-wrap-id-test-2" test="not(@id='keyresource') and not(starts-with(@id, concat('app' , $app-no)))" role="error" id="app-table-wrap-id-test-2">[app-table-wrap-id-test-2] table-wrap @id must start with <value-of select="concat('app' , $app-no)"/>.</report>
    </rule></pattern><pattern id="resp-table-wrap-ids-pattern"><rule context="sub-article//table-wrap" id="resp-table-wrap-ids">
 
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#resp-table-wrap-id-test" test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$')         else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')" role="warning" flag="dl-ar" id="resp-table-wrap-id-test">[resp-table-wrap-id-test] table-wrap @id in a sub-article must be in the format 'resptable0' or 'sa0table0' if it has a label, or in the format 'respinlinetable0' or 'sa0inlinetable0' if it does not.</assert>
    </rule></pattern><pattern id="table-wrap-ids-pattern"><rule context="article//table-wrap[not(ancestor::app) and not(ancestor::sub-article)]" id="table-wrap-ids">
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#table-wrap-id-test" test="if (label = 'Key resources table') then @id='keyresource'         else if (label) then matches(@id, '^table[0-9]{1,3}$')         else matches(@id, '^inlinetable[0-9]{1,3}$')" role="error" id="table-wrap-id-test">[table-wrap-id-test] table-wrap @id must be in the format 'table0', unless it doesn't have a label, in which case it must be 'inlinetable0' or it is the key resource table which must be 'keyresource'.</assert>
    </rule></pattern><pattern id="body-top-level-sec-ids-pattern"><rule context="article/body/sec" id="body-top-level-sec-ids">
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
    
      <assert see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#body-top-level-sec-id-test" test="@id = concat('s',$pos)" role="error" id="body-top-level-sec-id-test">[body-top-level-sec-id-test] This sec id must be a concatenation of 's' and this element's position relative to its siblings. It must be <value-of select="concat('s',$pos)"/>.</assert>
      </rule></pattern><pattern id="back-top-level-sec-ids-pattern"><rule context="article/back/sec" id="back-top-level-sec-ids">
      <let name="pos" value="count(ancestor::article/body/sec) + count(parent::back/sec) - count(following-sibling::sec)"/>
      
      <assert test="@id = concat('s',$pos)" role="error" id="back-top-level-sec-id-test">[back-top-level-sec-id-test] This sec id must be a concatenation of 's' and this element's position relative to other top level secs. It must be <value-of select="concat('s',$pos)"/>.</assert>
    </rule></pattern><pattern id="low-level-sec-ids-pattern"><rule context="article/body/sec//sec|article/back/sec//sec" id="low-level-sec-ids">
      <let name="parent-sec" value="parent::sec/@id"/>
      <let name="pos" value="count(parent::sec/sec) - count(following-sibling::sec)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#low-level-sec-id-test" test="@id = concat($parent-sec,'-',$pos)" role="error" id="low-level-sec-id-test">[low-level-sec-id-test] sec id must be a concatenation of its parent sec id and this element's position relative to its sibling secs. It must be <value-of select="concat($parent-sec,'-',$pos)"/>.</assert>
    </rule></pattern><pattern id="app-ids-pattern"><rule context="app" id="app-ids">
      <let name="pos" value="string(count(ancestor::article//app) - count(following::app))"/>
      
      <assert test="matches(@id,'^appendix-[0-9]{1,3}$')" role="error" id="app-id-test-1">[app-id-test-1] app id must be in the format 'appendix-0'. <value-of select="@id"/> is not in this format.</assert>
      
      <assert test="substring-after(@id,'appendix-') = $pos" role="error" id="app-id-test-2">[app-id-test-2] app id is <value-of select="@id"/>, but relative to other appendices it is in position <value-of select="$pos"/>.</assert>
    </rule></pattern><pattern id="mdar-ids-pattern"><rule context="supplementary-material[contains(lower-case(label[1]),'mdar')]" id="mdar-ids">
      
      <assert test="matches(@id,'^mdar$')" role="error" id="mdar-id">[mdar-id] The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. It must be 'mdar'.</assert>
      
    </rule></pattern><pattern id="igrf-ids-pattern"><rule context="supplementary-material[matches(label[1],'^Inclusion in global research form$')]" id="igrf-ids">
      
      <assert test="matches(@id,'^igrf$')" role="error" id="igrf-id">[igrf-id] The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. It must be 'igrf'.</assert>
      
    </rule></pattern><pattern id="transrep-ids-pattern"><rule context="supplementary-material[contains(lower-case(label[1]),'transparent')]" id="transrep-ids">
      
      <assert test="matches(@id,'^transrepform$')" role="error" id="transrep-id">[transrep-id] The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. It must be 'transrepform'.</assert>
      
    </rule></pattern>
  
  <pattern id="fig-children-pattern"><rule context="fig/*" id="fig-children">
      <let name="allowed-children" value="('label', 'caption', 'graphic', 'permissions', 'attrib')"/>
      
      <assert test="local-name() = $allowed-children" role="error" id="fig-child-conformance">[fig-child-conformance] <name/> is not allowed as a child of fig.</assert>
    </rule></pattern><pattern id="table-wrap-children-pattern"><rule context="table-wrap/*" id="table-wrap-children">
      <let name="allowed-children" value="('label', 'caption', 'table', 'permissions', 'table-wrap-foot')"/>
      
      <assert test="local-name() = $allowed-children" role="error" id="table-wrap-child-conformance">[table-wrap-child-conformance] <name/> is not allowed as a child of table-wrap.</assert>
    </rule></pattern><pattern id="media-children-pattern"><rule context="media/*" id="media-children">
      <let name="allowed-children" value="('label', 'caption', 'permissions', 'attrib')"/>
      
      <assert test="local-name() = $allowed-children" role="error" id="media-child-conformance">[media-child-conformance] <name/> is not allowed as a child of media.</assert>
    </rule></pattern><pattern id="supplementary-material-children-pattern"><rule context="supplementary-material/*" id="supplementary-material-children">
      <let name="allowed-children" value="('label', 'caption', 'media', 'permissions')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/additional-files-60jpvalx#supplementary-material-child-conformance" test="local-name() = $allowed-children" role="error" id="supplementary-material-child-conformance">[supplementary-material-child-conformance] <name/> is not allowed as a child of supplementary-material.</assert>
    </rule></pattern><pattern id="author-notes-children-pattern"><rule context="author-notes/*" id="author-notes-children">
      
      <assert test="local-name() = 'fn'" role="error" id="author-notes-child-conformance">[author-notes-child-conformance] <name/> is not allowed as a child of author-notes.</assert>
    </rule></pattern>
  
  <pattern id="sec-tests-pattern"><rule context="sec" id="sec-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-test-1" test="title" role="error" id="sec-test-1">[sec-test-1] sec must have a title</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#final-sec-test-2" test="p or sec or fig or fig-group or media or table-wrap or boxed-text or list or fn-group or supplementary-material or related-object or code" role="error" id="final-sec-test-2">[final-sec-test-2] sec appears to contain no content. This cannot be correct.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-test-5" test="count(ancestor::sec) ge 5" role="error" id="sec-test-5">[sec-test-5] Level <value-of select="count(ancestor::sec) + 1"/> sections are not allowed. Please either make this a level 5 heading, or capture the title as a bolded paragraph in its parent section.</report>
    </rule></pattern><pattern id="res-data-sec-pattern"><rule context="article[@article-type='research-article']//sec[not(@sec-type) and not(matches(.,'[Gg]ithub|[Gg]itlab|[Cc]ode[Pp]lex|[Ss]ource[Ff]orge|[Bb]it[Bb]ucket'))]" id="res-data-sec">
      <let name="title" value="lower-case(title[1])"/>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#sec-test-3" test="contains($title,'data') and (contains($title,'availability') or contains($title,'code') or contains($title,'accessib') or contains($title,'statement'))" role="warning" id="sec-test-3">[sec-test-3] Section has a title '<value-of select="title[1]"/>'. Is it a duplicate of the data availability section (and therefore should be removed)?</report>
      
    </rule></pattern><pattern id="res-ethics-sec-pattern"><rule context="article[@article-type='research-article']//sec[not(descendant::xref[@ref-type='bibr'])]" id="res-ethics-sec">
      
      <report see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#sec-test-4" test="matches(lower-case(title[1]),'^ethics| ethics$| ethics ')" role="warning" id="sec-test-4">[sec-test-4] Section has a title '<value-of select="title[1]"/>'. Is it a duplicate of, or very similar to, the ethics statement (in the article details page)? If so, it should be removed. If not, then which statement is correct? The one in this section or '<value-of select="string-join(         ancestor::article//fn-group[@content-type='ethics-information']/fn         ,' '         )"/>'?</report>
      
    </rule></pattern>
  
  <pattern id="back-tests-pattern"><rule context="back" id="back-tests">
      <let name="article-type" value="parent::article/@article-type"/>
      <let name="subj-type" value="parent::article//subj-group[@subj-group-type='display-channel']/subject"/>
      <let name="pub-date" value="e:get-iso-pub-date(self::*)"/>
      <let name="version" value="e:get-version(.)"/>
      
      <report test="if ($article-type = ($features-article-types,$notice-article-types)) then ()         else count(sec[@sec-type='additional-information']) != 1" role="error" id="back-test-1">[back-test-1] One and only one sec[@sec-type="additional-information"] must be present in back.</report>
      
      <report test="count(sec[@sec-type='supplementary-material']) gt 1" role="error" id="back-test-2">[back-test-2] More than one sec[@sec-type="supplementary-material"] cannot be present in back.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#back-test-3" test="($article-type='research-article') and ($subj-type != 'Scientific Correspondence') and (not($pub-date) or ($pub-date gt '2018-05-31')) and (count(sec[@sec-type='data-availability']) != 1)" role="error" id="back-test-3">[back-test-3] One and only one Data availability section (sec[@sec-type="data-availability"]) must be present (as a child of back) for '<value-of select="$article-type"/>'.</report>
      
      <report test="($article-type='research-article') and ($subj-type != 'Scientific Correspondence') and ($pub-date le '2018-05-31') and (count(sec[@sec-type='data-availability']) != 1)" role="warning" id="back-test-10">[back-test-10] One and only one Data availability section (sec[@sec-type="data-availability"]) should be present (as a child of back) for '<value-of select="$article-type"/>'. Is this a new version which was published first without one? If not, then it certainly needs adding.</report>
      
      <report test="count(ack) gt 1" role="error" id="back-test-4">[back-test-4] One and only one ack may be present in back.</report>
      
      <report test="if ($article-type = ('research-article','article-commentary')) then (count(ref-list) != 1)         else ()" role="error" id="back-test-5">[back-test-5] One and only one ref-list must be present in <value-of select="$article-type"/> content.</report>
      
      <report test="count(app-group) gt 1" role="error" id="back-test-6">[back-test-6] One and only one app-group may be present in back.</report>
      
      <report see="https://elifeproduction.slab.com/posts/acknowledgements-49wvb1xt#hmlys-back-test-8" test="if ($article-type = ($features-article-types,$notice-article-types)) then ()         else if ($subj-type = 'Scientific Correspondence') then ()         else (not(ack))" role="warning" id="back-test-8">[back-test-8] '<value-of select="$article-type"/>' usually have acknowledgement sections, but there isn't one here. Is this correct?</report>
      
      <report test="($article-type = $features-article-types) and (count(fn-group[@content-type='competing-interest']) != 1)" role="error" id="back-test-7">[back-test-7] An fn-group[@content-type='competing-interest'] must be present as a child of back <value-of select="$subj-type"/> content.</report>
      
      <report test="($article-type = 'research-article') and (count(sec[@sec-type='additional-information']/fn-group[@content-type='competing-interest']) != 1)" role="error" id="back-test-9">[back-test-9] One and only one fn-group[@content-type='competing-interest'] must be present in back as a child of sec[@sec-type="additional-information"] in <value-of select="$subj-type"/> content.</report>
      
      <report test="if ($version='1') then ($article-type = 'research-article') and (count(sec[@sec-type='additional-information']/fn-group[@content-type='author-contribution']) != 1)         else ()" role="error" id="back-test-12">[back-test-12] One and only one fn-group[@content-type='author-contribution'] must be present in back as a child of sec[@sec-type="additional-information"] in <value-of select="$subj-type"/> content.</report>
      
      <report test="($article-type = ('article-commentary', 'editorial', 'book-review', 'discussion')) and sec[@sec-type='additional-information']" role="error" id="back-test-11">[back-test-11] <value-of select="$article-type"/> type articles cannot contain additional information sections (sec[@sec-type="additional-information"]).</report>
      
    </rule></pattern><pattern id="data-content-tests-pattern"><rule context="back/sec[@sec-type='data-availability']" id="data-content-tests">
      
      <assert test="count(p) gt 0" role="error" id="data-p-presence">[data-p-presence] At least one p element must be present in sec[@sec-type='data=availability'].</assert>
      
      <report test="count(p[matches(.,'^The following datasets? w(as|ere) generated:\s?$')]) gt 1" role="error" id="data-gen-p-presence">[data-gen-p-presence] Data availabilty section contains more than one p element describing that the datasets were generated. Either the content of one (or more) is incorrect, or the duplicated sentence needs removing.</report>
      
      <report test="count(p[matches(.,'^The following previously published datasets? w(as|ere) used:\s?$')]) gt 1" role="error" id="data-used-p-presence">[data-used-p-presence] Data availabilty section contains more than one p element describing that previously published datasets were used. Either the content of one (or more) is incorrect, or the duplicated sentence needs removing.</report>
    </rule></pattern><pattern id="ack-tests-pattern"><rule context="back/ack" id="ack-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/acknowledgements-49wvb1xt#howwo-ack-test-1" test="count(title) = 1" role="error" id="ack-test-1">[ack-test-1] ack must have only 1 title.</assert>
    </rule></pattern><pattern id="ack-child-tests-pattern"><rule context="back/ack/*" id="ack-child-tests">
    
      <assert see="https://elifeproduction.slab.com/posts/acknowledgements-49wvb1xt#hdl9z-ack-child-test-1" test="local-name() = ('p','sec','title')" role="error" id="ack-child-test-1">[ack-child-test-1] Only p, sec or title can be children of ack. <name/> is not allowed.</assert>
    </rule></pattern><pattern id="app-tests-pattern"><rule context="back//app" id="app-tests">
      
      <assert test="parent::app-group" role="error" id="app-test-1">[app-test-1] app must be captured as a child of an app-group element.</assert>
      
      <assert test="count(title) = 1" role="error" id="app-test-2">[app-test-2] app must have one title.</assert>
    </rule></pattern><pattern id="additional-info-tests-pattern"><rule context="sec[@sec-type='additional-information']" id="additional-info-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="author-count" value="count(ancestor::article//article-meta//contrib[@contrib-type='author'])"/>
      <let name="non-contribs" value="('article-commentary', 'editorial', 'book-review', $notice-article-types)"/>
      
      <assert test="parent::back" role="error" id="additional-info-test-1">[additional-info-test-1] sec[@sec-type='additional-information'] must be a child of back.</assert>
      
      <!-- Exception for article with no authors -->
      <report test="if ($author-count = 0) then ()         else not(fn-group[@content-type='competing-interest'])" role="error" id="additional-info-test-2">[additional-info-test-2] This type of sec must have a child fn-group[@content-type='competing-interest'].</report>
      
      <report test="if (e:get-version(.)='1' and $article-type = ('research-article','review-article')) then (not(fn-group[@content-type='author-contribution']))         else ()" role="error" id="final-additional-info-test-3">[final-additional-info-test-3] Missing author contributions. This type of sec in research content must have a child fn-group[@content-type='author-contribution'].</report>
      
      
      
      <report test="$article-type=$non-contribs and fn-group[@content-type='author-contribution']" role="error" id="additional-info-test-4">[additional-info-test-4] <value-of select="$article-type"/> type articles should not contain author contributions.</report>
      
    </rule></pattern><pattern id="additional-files-tests-pattern"><rule context="sec[@sec-type='supplementary-material']" id="additional-files-tests">
      
      <assert test="title = 'Additional files'" role="error" id="add-files-1">[add-files-1] The additional files section (sec[@sec-type='supplementary-material']) must have a title which is 'Additional files'. This one does not.</assert>
      
      <report test="descendant::supplementary-material[matches(lower-case(label[1]),'transparent reporting form')] and descendant::supplementary-material[matches(lower-case(label[1]),'mdar checklist')]" role="error" id="add-files-4">[add-files-4] This article has both a transparent reporting form and an MDAR checklist - there should only be one. Please check with the eLife team who will decide which should be retained.</report>
      
    </rule></pattern><pattern id="trf-presence-pattern"><rule context="article[@article-type='research-article']" id="trf-presence">
      
      <assert test="descendant::supplementary-material[matches(lower-case(label[1]),'transparent reporting form|mdar checklist')]" role="warning" id="add-files-2">[add-files-2] This article does not have a transparent reporting form or MDAR checklist. Is that correct?</assert>
      
    </rule></pattern><pattern id="additional-files-child-tests-pattern"><rule context="sec[@sec-type='supplementary-material']/*" id="additional-files-child-tests">
      
      <assert test="name()=('title','supplementary-material')" role="error" id="add-files-3">[add-files-3] <value-of select="name()"/> is not allowed as a child element in the additional files section (sec[@sec-type='supplementary-material']).</assert>
      
    </rule></pattern><pattern id="comp-int-fn-group-tests-pattern"><rule context="fn-group[@content-type='competing-interest']" id="comp-int-fn-group-tests">
      
      <assert test="count(fn) gt 0" role="error" id="comp-int-fn-test-1">[comp-int-fn-test-1] At least one child fn element should be present in fn-group[@content-type='competing-interest'].</assert>
      
      <assert test="ancestor::back" role="error" id="comp-int-fn-group-test-1">[comp-int-fn-group-test-1] This fn-group must be a descendant of back.</assert>
    </rule></pattern><pattern id="comp-int-fn-tests-pattern"><rule context="fn-group[@content-type='competing-interest']/fn" id="comp-int-fn-tests">
      <let name="lower-case" value="lower-case(.)"/>
      
      <assert test="@fn-type='COI-statement'" role="error" id="comp-int-fn-test-2">[comp-int-fn-test-2] fn element must have an @fn-type='COI-statement' as it is a child of fn-group[@content-type='competing-interest'].</assert>
      
      <report test="contains(lower-case(.),'the other authors')" role="error" id="comp-int-fn-test-3">[comp-int-fn-test-3] Competing interests footnote contains information about other authors - '<value-of select="."/>'. These footnotes should only contain information about that specific author.</report>
      
      <report test="matches(.,'\.\p{Zs}*$')" role="error" id="comp-int-fn-test-4">[comp-int-fn-test-4] Competing interests footnote ends with full stop - <value-of select="."/> - Please remove the full stop.</report>

      <report test="preceding::fn[lower-case(.)=$lower-case]" role="error" id="comp-int-fn-test-5">[comp-int-fn-test-5] Competing interests footnotes must be distinct. This one (with the id <value-of select="@id"/>) is the same as another one (with the id <value-of select="string-join(preceding::fn[lower-case(.)=$lower-case]/@id,'; ')"/>): <value-of select="."/></report>
      
    </rule></pattern><pattern id="auth-cont-fn-tests-pattern"><rule context="fn-group[@content-type='author-contribution']/fn" id="auth-cont-fn-tests">
      
      <assert test="@fn-type='con'" role="error" id="auth-cont-fn-test-1">[auth-cont-fn-test-1] This fn must have an @fn-type='con'.</assert>

      <report test="matches(.,'\.\s*$')" role="error" id="auth-cont-fn-test-2">[auth-cont-fn-test-2] Author contribution must not end with a full stop. This one does: <value-of select="."/></report>
    </rule></pattern><pattern id="ethics-tests-pattern"><rule context="fn-group[@content-type='ethics-information']" id="ethics-tests">
      
      <!-- Exclusion included for Feature 5 -->
      <report see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-test-1" test="ancestor::article[not(@article-type='discussion')] and not(parent::sec[@sec-type='additional-information'])" role="error" id="ethics-test-1">[ethics-test-1] Ethics fn-group can only be captured as a child of a sec [@sec-type='additional-information']</report>
 
      <report see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-test-2" test="count(fn) gt 3" role="error" id="ethics-test-2">[ethics-test-2] Ethics fn-group may not have more than 3 fn elements. Currently there are <value-of select="count(fn)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-test-3" test="count(fn) = 0" role="error" id="ethics-test-3">[ethics-test-3] Ethics fn-group must have at least one fn element.</report>
    </rule></pattern><pattern id="ethics-fn-tests-pattern"><rule context="fn-group[@content-type='ethics-information']/fn" id="ethics-fn-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-test-4" test="@fn-type='other'" role="error" id="ethics-test-4">[ethics-test-4] This fn must have an @fn-type='other'</assert>
      
    </rule></pattern>
  
  <pattern id="dec-letter-reply-tests-pattern"><rule context="article/sub-article" id="dec-letter-reply-tests">
      <let name="is-prc" value="e:is-prc(.)"/>
      <let name="sub-article-types" value="('editor-report','referee-report','author-comment','decision-letter','reply')"/>
      <let name="sub-article-count" value="count(parent::article/sub-article)"/>
      <let name="id-convention" value="if (@article-type='editor-report') then 'sa0'         else if (@article-type='decision-letter') then 'sa1'         else if (@article-type='reply') then 'sa2'         else if (@article-type='author-comment') then concat('sa',$sub-article-count - 1)         else concat('sa',count(preceding-sibling::sub-article))"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-1" test="@article-type=$sub-article-types" role="error" flag="dl-ar" id="dec-letter-reply-test-1">[dec-letter-reply-test-1] sub-article must must have an article-type which is equal to one of the following values: <value-of select="string-join($sub-article-types,'; ')"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-2" test="@id = $id-convention" role="error" flag="dl-ar" id="dec-letter-reply-test-2">[dec-letter-reply-test-2] sub-article id is <value-of select="@id"/> when based on it's article-type and position it should be <value-of select="$id-convention"/>.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-3" test="count(front-stub) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-3">[dec-letter-reply-test-3] sub-article must contain one and only one front-stub.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-4" test="count(body) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-4">[dec-letter-reply-test-4] sub-article must contain one and only one body.</assert>
      
      <report test="not($is-prc) and @article-type='referee-report'" role="error" flag="dl-ar" id="sub-article-1">[sub-article-1] '<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'decision-letter'.</report>
      
      <report test="not($is-prc) and @article-type='author-comment'" role="error" flag="dl-ar" id="sub-article-2">[sub-article-2] '<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'response'.</report>
      
      <report test="$is-prc and @article-type='decision-letter'" role="error" flag="dl-ar" id="sub-article-3">[sub-article-3] '<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in PRC articles. Provided this is in fact a PRC article, the article-type should be 'referee-report'.</report>
      
      <report test="$is-prc and @article-type='reply'" role="error" flag="dl-ar" id="sub-article-4">[sub-article-4] '<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'author-comment'.</report>
      
    </rule></pattern><pattern id="dec-letter-reply-content-tests-pattern"><rule context="article/sub-article//p" id="dec-letter-reply-content-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-5" test="matches(.,'&lt;[/]?[Aa]uthor response')" role="error" flag="dl-ar" id="dec-letter-reply-test-5">[dec-letter-reply-test-5] <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what looks like pseudo-code - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-6" test="matches(.,'&lt;\p{Zs}?/?\p{Zs}?[a-z]*\p{Zs}?/?\p{Zs}?&gt;')" role="warning" flag="dl-ar" id="dec-letter-reply-test-6">[dec-letter-reply-test-6] <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be pseudo-code or tags which should likely be removed - <value-of select="."/>.</report>
    </rule></pattern><pattern id="dec-letter-reply-content-tests-2-pattern"><rule context="article/sub-article//p[not(ancestor::disp-quote)]" id="dec-letter-reply-content-tests-2">
      <let name="regex" value="'\p{Zs}([Oo]ffensive|[Oo]ffended|[Uu]nproff?essional|[Rr]ude|[Cc]onflict\p{Zs}[Oo]f\p{Zs}[Ii]nterest|([Aa]re|[Aa]m)\p{Zs}[Ss]hocked|[Ss]trongly\p{Zs}[Dd]isagree)[^\p{L}]'"/>
      
      <!-- Need to improve messaging -->
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reply-test-7" test="matches(.,$regex)" role="warning" flag="dl-ar" id="dec-letter-reply-test-7">[dec-letter-reply-test-7] <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be inflammatory or offensive language. eLife: please check it to see if it is language that should be removed. This paragraph was flagged because of the phrase(s) <value-of select="string-join(tokenize(.,'\p{Zs}')[matches(.,concat('^',substring-before(substring-after($regex,'\p{Zs}'),'[^\p{L}]')))],'; ')"/> in <value-of select="."/>.</report>
    </rule></pattern><pattern id="ed-eval-front-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub" id="ed-eval-front-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="ed-eval-front-test-1">[ed-eval-front-test-1] sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-2" test="count(contrib-group) = 1" role="error" flag="dl-ar" id="ed-eval-front-test-2">[ed-eval-front-test-2] editor report front-stub must contain 1 (and only 1) contrib-group element. This one has <value-of select="count(contrib-group)"/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-3" test="count(related-object) gt 1" role="error" flag="dl-ar" id="ed-eval-front-test-3">[ed-eval-front-test-3] editor report front-stub must contain 1 or 0 related-object elements. This one has <value-of select="count(related-object)"/>.</report>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-4" test="e:is-prc(.) and not(kwd-group[@kwd-group-type='evidence-strength'])" role="error" flag="dl-ar" id="ed-eval-front-test-4">[ed-eval-front-test-4] eLife Assessment front-stub does not contain a strength term keyword group, which must be incorrect.</report>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-test-5" test="e:is-prc(.) and not(kwd-group[@kwd-group-type='claim-importance'])" role="warning" flag="dl-ar" id="ed-eval-front-test-5">[ed-eval-front-test-5] eLife Assessment front-stub does not contain a significance term keyword group, which is very unusual. Is that correct?</report>
    </rule></pattern><pattern id="ed-eval-front-child-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/*" id="ed-eval-front-child-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-front-child-test-1" test="name()=('article-id','title-group','contrib-group','kwd-group','related-object')" role="error" flag="dl-ar" id="ed-eval-front-child-test-1">[ed-eval-front-child-test-1] <name/> element is not allowed in the front-stub for an editor report. Only the following elements are permitted: article-id, title-group, contrib-group, kwd-group, related-object.</assert>
    </rule></pattern><pattern id="ed-eval-contrib-group-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/contrib-group" id="ed-eval-contrib-group-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-contrib-group-test-1" test="count(contrib[@contrib-type='author']) = 1" role="error" flag="dl-ar" id="ed-eval-contrib-group-test-1">[ed-eval-contrib-group-test-1] editor report contrib-group must contain 1 contrib[@contrib-type='author'].</assert>
    </rule></pattern><pattern id="ed-eval-author-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/contrib-group/contrib[@contrib-type='author' and name]" id="ed-eval-author-tests">
      <let name="rev-ed-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section'][1]/contrib[@contrib-type='editor'][1]/name[1])"/>
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-author-test-1" test="$name = $rev-ed-name" role="error" flag="dl-ar" id="ed-eval-author-test-1">[ed-eval-author-test-1] The author of the editor report must be the same as the Reviewing editor for the article. The Reviewing editor is <value-of select="$rev-ed-name"/>, but the editor evaluation author is <value-of select="$name"/>.</assert>
    </rule></pattern><pattern id="ed-eval-rel-obj-tests-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/related-object" id="ed-eval-rel-obj-tests">
      <let name="event-preprint-doi" value="for $x in ancestor::article//article-meta/pub-history/event[1]/self-uri[@content-type='preprint'][1]/@xlink:href                                         return substring-after($x,'.org/')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-1" test="matches(@id,'^sa0ro\d$')" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-1">[ed-eval-rel-obj-test-1] related-object in editor's evaluation must have an id in the format sa0ro1. <value-of select="@id"/> does not meet this convention.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-2" test="@object-id-type='id'" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-2">[ed-eval-rel-obj-test-2] related-object in editor's evaluation must have an object-id-type="id" attribute.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-3" test="@link-type='continued-by'" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-3">[ed-eval-rel-obj-test-3] related-object in editor's evaluation must have a link-type="continued-by" attribute.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-4" test="matches(@object-id,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-4">[ed-eval-rel-obj-test-4] related-object in editor's evaluation must have an object-id attribute which is a doi. '<value-of select="@object-id"/>' is not a valid doi.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-5" test="@object-id = $event-preprint-doi" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-5">[ed-eval-rel-obj-test-5] related-object in editor's evaluation must have an object-id attribute whose value is the same as the preprint doi in the article's pub-history. object-id '<value-of select="@object-id"/>' is not the same as the preprint doi in the event history, '<value-of select="$event-preprint-doi"/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-6" test="@xlink:href = (         concat('https://sciety.org/articles/activity/',@object-id),         concat('https://sciety.org/articles/',@object-id)         )" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-6">[ed-eval-rel-obj-test-6] related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the object-id attribute value (which must be a doi). '<value-of select="@xlink:href"/>' is not equal to <value-of select="concat('https://sciety.org/articles/activity/',@object-id)"/>. Which is correct?</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-eval-rel-obj-test-7" test="@xlink:href = (         concat('https://sciety.org/articles/activity/',$event-preprint-doi),         concat('https://sciety.org/articles/',$event-preprint-doi)         )" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-7">[ed-eval-rel-obj-test-7] related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the preprint doi in the article's pub-history. xlink:href '<value-of select="@xlink:href"/>' is not the same as '<value-of select="concat('https://sciety.org/articles/activity/',$event-preprint-doi)"/>'. Which is correct?</assert>
      
    </rule></pattern><pattern id="ed-report-kwd-group-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group" id="ed-report-kwd-group">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-1" test="@kwd-group-type=('claim-importance','evidence-strength')" role="error" flag="dl-ar" id="ed-report-kwd-group-1">[ed-report-kwd-group-1] kwd-group in <value-of select="parent::*/title-group/article-title"/> must have the attribute kwd-group-type with the value 'claim-importance' or 'evidence-strength'. This one does not.</assert>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-3" test="@kwd-group-type='claim-importance' and count(kwd) gt 1" role="error" flag="dl-ar" id="ed-report-kwd-group-3">[ed-report-kwd-group-3] <value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is not permitted, please check which single importance keyword should be used.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-2" test="@kwd-group-type='evidence-strength' and count(kwd) = 2" role="warning" flag="dl-ar" id="ed-report-kwd-group-2">[ed-report-kwd-group-2] <value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. Please check this is correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-group-4" test="@kwd-group-type='evidence-strength' and count(kwd) gt 2" role="error" flag="dl-ar" id="ed-report-kwd-group-4">[ed-report-kwd-group-4] <value-of select="@kwd-group-type"/> type kwd-group has <value-of select="count(kwd)"/> keywords: <value-of select="string-join(kwd,'; ')"/>. This is incorrect.</report>
      
    </rule></pattern><pattern id="ed-report-claim-kwds-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='claim-importance']/kwd" id="ed-report-claim-kwds">
      <let name="allowed-vals" value="('Landmark', 'Fundamental', 'Important', 'Valuable', 'Useful')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-claim-kwd-1" test=".=$allowed-vals" role="error" flag="dl-ar" id="ed-report-claim-kwd-1">[ed-report-claim-kwd-1] Keyword contains <value-of select="."/>, but it is in a 'claim-importance' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/></assert>
      
    </rule></pattern><pattern id="ed-report-evidence-kwds-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='evidence-strength']/kwd" id="ed-report-evidence-kwds">
      <let name="wos-go-vals" value="('Exceptional', 'Compelling', 'Convincing', 'Solid')"/>
      <let name="wos-no-go-vals" value="('Incomplete', 'Inadequate')"/>
      <let name="allowed-vals" value="($wos-go-vals,$wos-no-go-vals)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-evidence-kwd-1" test=".=$allowed-vals" role="error" flag="dl-ar" id="ed-report-evidence-kwd-1">[ed-report-evidence-kwd-1] Keyword contains <value-of select="."/>, but it is in an 'evidence-strength' keyword group, meaning it should have one of the following values: <value-of select="string-join($allowed-vals,', ')"/></assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-evidence-kwd-2" test=".=$wos-no-go-vals and parent::*/kwd[.=$wos-go-vals]" role="warning" flag="dl-ar" id="ed-report-evidence-kwd-2">[ed-report-evidence-kwd-2] There is both an <value-of select="."/> and <value-of select="string-join(parent::*/kwd[.=$wos-go-vals],'; ')"/> kwd in the kwd-group for strength of evidence. Should <value-of select="."/> be unbolded or changed to a different word in the Assessment and removed as a keyword?</report>
    </rule></pattern><pattern id="ed-report-kwds-pattern"><rule context="sub-article[@article-type='editor-report']/front-stub/kwd-group/kwd" id="ed-report-kwds">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-1" test="preceding-sibling::kwd = ." role="error" flag="dl-ar" id="ed-report-kwd-1">[ed-report-kwd-1] Keyword contains <value-of select="."/>, there is another kwd with that value witin the same kwd-group, so this one is either incorrect or superfluous and should be deleted.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-2" test="some $x in ancestor::sub-article[1]/body/p//bold satisfies contains(lower-case($x),lower-case(.))" role="error" flag="dl-ar" id="ed-report-kwd-2">[ed-report-kwd-2] Keyword contains <value-of select="."/>, but this term is not bolded in the text of the <value-of select="ancestor::front-stub/title-group/article-title"/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-kwd-3" test="*" role="error" flag="dl-ar" id="ed-report-kwd-3">[ed-report-kwd-3] Keywords in <value-of select="ancestor::front-stub/title-group/article-title"/> cannot contain elements, only text. This one has: <value-of select="string-join(distinct-values(*/name()),'; ')"/>.</report>
      
    </rule></pattern><pattern id="ed-report-bold-terms-pattern"><rule context="sub-article[@article-type='editor-report' and e:is-prc(.)]/body/p[1]//bold" id="ed-report-bold-terms">
      <let name="str-kwds" value="('exceptional', 'compelling', 'convincing', 'convincingly', 'solid', 'incomplete', 'incompletely', 'inadequate', 'inadequately')"/>
      <let name="sig-kwds" value="('landmark', 'fundamental', 'important', 'valuable', 'useful')"/>
      <let name="allowed-vals" value="($str-kwds,$sig-kwds)"/>
      <let name="normalized-kwd" value="replace(lower-case(.),'ly$','')"/>
      <let name="title-case-kwd" value="concat(upper-case(substring($normalized-kwd,1,1)),lower-case(substring($normalized-kwd,2)))"/>
      <let name="preceding-text" value="string-join(preceding-sibling::node(),'')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-bold-terms-1" test="lower-case(.)=$allowed-vals" role="error" id="ed-report-bold-terms-1">[ed-report-bold-terms-1] Bold phrase in eLife Assessment - <value-of select="."/> - is not one of the permitted terms from the vocabulary. Should the bold formatting be removed? These are currently bolded terms <value-of select="string-join($allowed-vals,', ')"/></assert>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-bold-terms-2" test="lower-case(.)=$allowed-vals and not($title-case-kwd=ancestor::sub-article/front-stub/kwd-group/kwd)" role="error" id="ed-report-bold-terms-2">[ed-report-bold-terms-2] Bold phrase in eLife Assessment - <value-of select="."/> - is one of the permitted vocabulary terms, but there's no corresponding keyword in the metadata (in a kwd-group in the front-stub).</report>

      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-bold-terms-3" test="preceding-sibling::bold[replace(lower-case(.),'ly$','') = $normalized-kwd]" role="warning" id="ed-report-bold-terms-3">[ed-report-bold-terms-3] There is more than one of the same <value-of select="if (replace(lower-case(.),'ly$','')=$str-kwds) then 'strength' else 'significance'"/> keywords in the assessment - <value-of select="$normalized-kwd"/>. This is very likely to be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-bold-terms-4" test="(lower-case(.)=$allowed-vals) and matches($preceding-text,'\smore\s*$')" role="warning" id="ed-report-bold-terms-4">[ed-report-bold-terms-4] Assessment keyword (<value-of select="."/>) is preceded by 'more'. Has the keyword been deployed correctly?</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#ed-report-bold-terms-5" test="(lower-case(.)=$str-kwds) and matches($preceding-text,'\spotentially\s*$')" role="warning" id="ed-report-bold-terms-5">[ed-report-bold-terms-5] Assessment strength keyword (<value-of select="."/>) is preceded by 'potentially'. Has the keyword been deployed correctly?</report>
    </rule></pattern><pattern id="dec-letter-front-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub" id="dec-letter-front-tests">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="dec-letter-front-test-1">[dec-letter-front-test-1] sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-2" test="$count gt 0" role="error" flag="dl-ar" id="dec-letter-front-test-2">[dec-letter-front-test-2] decision letter front-stub must contain at least 1 contrib-group element.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-3" test="$count gt 2" role="error" flag="dl-ar" id="dec-letter-front-test-3">[dec-letter-front-test-3] decision letter front-stub contains more than 2 contrib-group elements.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-front-test-4" test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'(All|The) reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/|doi.org/10.24072/pci.evolbiol')])" role="warning" flag="dl-ar" id="dec-letter-front-test-4">[dec-letter-front-test-4] decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviewing editor) anonymous? The text 'The reviewers have opted to remain anonymous' or 'The reviewer has opted to remain anonymous' is not present and there is no link to Review commons or a Peer Community in Evolutionary Biology doi in the decision letter.</report>
    </rule></pattern><pattern id="dec-letter-editor-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]" id="dec-letter-editor-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-editor-test-1" test="count(contrib[@contrib-type='editor']) = 1" role="warning" flag="dl-ar" id="dec-letter-editor-test-1">[dec-letter-editor-test-1] First contrib-group in decision letter must contain 1 and only 1 editor (contrib[@contrib-type='editor']).</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-editor-test-2" test="contrib[not(@contrib-type) or @contrib-type!='editor']" role="warning" flag="dl-ar" id="dec-letter-editor-test-2">[dec-letter-editor-test-2] First contrib-group in decision letter contains a contrib which is not marked up as an editor (contrib[@contrib-type='editor']).</report>
    </rule></pattern><pattern id="dec-letter-editor-tests-2-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]/contrib[@contrib-type='editor']" id="dec-letter-editor-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role[1]"/>
      <!--<let name="top-role" value="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[e:get-name(name[1])=$name]/role"/>-->
      <!--<let name="top-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[role=$role]/name[1])"/>-->
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-editor-test-3" test="$role=('Reviewing Editor','Senior and Reviewing Editor')" role="error" flag="dl-ar" id="dec-letter-editor-test-3">[dec-letter-editor-test-3] Editor in decision letter front-stub must have the role 'Reviewing Editor' or 'Senior and Reviewing Editor'. <value-of select="$name"/> has '<value-of select="$role"/>'.</assert>
      
      <!--<report test="($top-name!='') and ($top-name!=$name)"
        role="error"
        id="dec-letter-editor-test-5">In decision letter <value-of select="$name"/> is a <value-of select="$role"/>, but in the top-level article details <value-of select="$top-name"/> is the <value-of select="$role"/>.</report>-->
    </rule></pattern><pattern id="dec-letter-reviewer-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]" id="dec-letter-reviewer-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-1" test="count(contrib[@contrib-type='reviewer']) gt 0" role="error" flag="dl-ar" id="dec-letter-reviewer-test-1">[dec-letter-reviewer-test-1] Second contrib-group in decision letter must contain a reviewer (contrib[@contrib-type='reviewer']).</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-2" test="contrib[not(@contrib-type) or @contrib-type!='reviewer']" role="error" flag="dl-ar" id="dec-letter-reviewer-test-2">[dec-letter-reviewer-test-2] Second contrib-group in decision letter contains a contrib which is not marked up as a reviewer (contrib[@contrib-type='reviewer']).</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-6" test="count(contrib[@contrib-type='reviewer']) gt 5" role="warning" flag="dl-ar" id="dec-letter-reviewer-test-6">[dec-letter-reviewer-test-6] Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</report>
    </rule></pattern><pattern id="dec-letter-reviewer-tests-2-pattern"><rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]/contrib[@contrib-type='reviewer']" id="dec-letter-reviewer-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-reviewer-test-3" test="role='Reviewer'" role="error" flag="dl-ar" id="dec-letter-reviewer-test-3">[dec-letter-reviewer-test-3] Reviewer in decision letter front-stub must have the role 'Reviewer'. <value-of select="$name"/> has '<value-of select="role"/>'.</assert>
    </rule></pattern><pattern id="dec-letter-body-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/body" id="dec-letter-body-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-body-test-1" test="child::*[1]/local-name() = 'boxed-text'" role="error" flag="dl-ar" id="dec-letter-body-test-1">[dec-letter-body-test-1] First child element in decision letter is not boxed-text. This is certainly incorrect.</assert>
    </rule></pattern><pattern id="dec-letter-body-p-tests-pattern"><rule context="sub-article[@article-type=('decision-letter','referee-report')]/body//p" id="dec-letter-body-p-tests">  
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-body-test-2" test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])" role="error" flag="dl-ar" id="dec-letter-body-test-2">[dec-letter-body-test-2] The text 'Review Commons' in '<value-of select="."/>' must contain an embedded link pointing to https://www.reviewcommons.org/.</report>
      
      <report see="https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-body-test-3" test="contains(lower-case(.),'reviewed and recommended by peer community in evolutionary biology') and not(child::ext-link[matches(@xlink:href,'doi.org/10.24072/pci.evolbiol')])" role="error" flag="dl-ar" id="dec-letter-body-test-3">[dec-letter-body-test-3] The decision letter indicates that this article was reviewed by PCI evol bio, but there is no doi link with the prefix '10.24072/pci.evolbiol' which must be incorrect.</report>
    </rule></pattern><pattern id="dec-letter-box-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/body/boxed-text[1]" id="dec-letter-box-tests">  
      <let name="permitted-text-1" value="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below.$'"/>
      <let name="permitted-text-2" value="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below. We also include an acceptance summary that explains what the editors found interesting or important about the work.$'"/>
      <let name="permitted-text-3" value="'^In the interests of transparency, eLife publishes the most substantive revision requests and the accompanying author responses.$'"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-box-test-1" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2,'|',$permitted-text-3))" role="warning" flag="dl-ar" id="dec-letter-box-test-1">[dec-letter-box-test-1] The text at the top of the decision letter is not correct - '<value-of select="."/>'. It has to be one of the three paragraphs which are permitted (see the GitBook page for these paragraphs).</assert>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-box-test-2" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[contains(@xlink:href,'sciety.org/') and .='public reviews'])" role="error" flag="dl-ar" id="dec-letter-box-test-2">[dec-letter-box-test-2] At the top of the decision letter, the text 'public reviews' must contain an embedded link to Sciety where the public review for this article's preprint is located.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#dec-letter-box-test-3" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[.='the preprint'])" role="error" flag="dl-ar" id="dec-letter-box-test-3">[dec-letter-box-test-3] At the top of the decision letter, the text 'the preprint' must contain an embedded link to this article's preprint.</report>
    </rule></pattern><pattern id="decision-missing-table-tests-pattern"><rule context="sub-article[@article-type='decision-letter']" id="decision-missing-table-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#decision-missing-table-test" test="contains(.,'letter table') and not(descendant::table-wrap[label])" role="warning" flag="dl-ar" id="decision-missing-table-test">[decision-missing-table-test] A decision letter table is referred to in the text, but there is no table in the decision letter with a label.</report>
    </rule></pattern><pattern id="reply-front-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/front-stub" id="reply-front-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="reply-front-test-1">[reply-front-test-1] sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
    </rule></pattern><pattern id="reply-body-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body" id="reply-body-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-body-test-1" test="count(disp-quote[@content-type='editor-comment']) = 0" role="warning" flag="dl-ar" id="reply-body-test-1">[reply-body-test-1] author response doesn't contain a disp-quote. This is very likely to be incorrect. Please check the original file.</report>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-body-test-2" test="count(p) = 0" role="error" flag="dl-ar" id="reply-body-test-2">[reply-body-test-2] author response doesn't contain a p. This has to be incorrect.</report>
    </rule></pattern><pattern id="reply-disp-quote-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//disp-quote" id="reply-disp-quote-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-disp-quote-test-1" test="@content-type='editor-comment'" role="warning" flag="dl-ar" id="reply-disp-quote-test-1">[reply-disp-quote-test-1] disp-quote in author reply does not have @content-type='editor-comment'. This is almost certainly incorrect.</assert>
    </rule></pattern><pattern id="reply-missing-disp-quote-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//p[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests">
      <let name="free-text" value="replace(         normalize-space(string-join(for $x in self::*/text() return $x,''))         ,' ','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-missing-disp-quote-test-1" test="(count(*)=1) and (child::italic) and ($free-text='')" role="warning" flag="dl-ar" id="reply-missing-disp-quote-test-1">[reply-missing-disp-quote-test-1] para in author response is entirely in italics, but not in a display quote. Is this a quote which has been processed incorrectly?</report>
    </rule></pattern><pattern id="reply-missing-disp-quote-tests-2-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]//italic[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests-2">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-missing-disp-quote-test-2" test="string-length(.) ge 50" role="warning" flag="dl-ar" id="reply-missing-disp-quote-test-2">[reply-missing-disp-quote-test-2] A long piece of text is in italics in an Author response paragraph. Should it be captured as a display quote in a separate paragraph? '<value-of select="."/>' in '<value-of select="ancestor::*[local-name()='p'][1]"/>'</report>
    </rule></pattern><pattern id="reply-missing-table-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]" id="reply-missing-table-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#reply-missing-table-test" test="contains(.,'response table') and not(descendant::table-wrap[label])" role="warning" flag="dl-ar" id="reply-missing-table-test">[reply-missing-table-test] An author response table is referred to in the text, but there is no table in the response with a label.</report>
    </rule></pattern><pattern id="sub-article-ext-link-tests-pattern"><rule context="sub-article//ext-link" id="sub-article-ext-link-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#paper-pile-test" test="contains(@xlink:href,'paperpile.com')" role="error" flag="dl-ar" id="paper-pile-test">[paper-pile-test] In the <value-of select="if (ancestor::sub-article[@article-type='reply']) then 'author response' else 'decision letter'"/> the text '<value-of select="."/>' has an embedded hyperlink to <value-of select="@xlink:href"/>. The hyperlink should be removed (but the text retained).</report>
    </rule></pattern><pattern id="sub-article-ref-p-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body/*[last()][name()='p']" id="sub-article-ref-p-tests">
      
      <report see="https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#sub-article-ref-p-test" test="count(tokenize(lower-case(.),'doi\p{Zs}?:')) gt 2" role="warning" flag="dl-ar" id="sub-article-ref-p-test">[sub-article-ref-p-test] The last paragraph of the author response looks like it contains various references. Should each reference be split out into its own paragraph? <value-of select="."/></report>
    </rule></pattern><pattern id="sub-article-dl-image-tests-pattern"><rule context="sub-article[@article-type='decision-letter']/body//bold" id="sub-article-dl-image-tests">
      
      <report test="matches(.,'[Dd]ecision letter image \d')" role="error" flag="dl-ar" id="sub-article-dl-image-1">[sub-article-dl-image-1] Decision letter contains bold text that mentions an image: <value-of select="."/>. This should be changed to a citation (and if the decision letter image is missing, then it should be added).</report>
      
      <report test="matches(.,'[Dd]ecision letter table \d')" role="error" flag="dl-ar" id="sub-article-dl-image-2">[sub-article-dl-image-2] Decision letter contains bold text that mentions an table: <value-of select="."/>. This should be changed to a citation (and if the decision letter table is missing, then it should be added).</report>
    </rule></pattern><pattern id="sub-article-pr-image-tests-pattern"><rule context="sub-article[@article-type='referee-report']/body//bold" id="sub-article-pr-image-tests">
      
      <report test="matches(.,'[Rr]eview image \d')" role="error" flag="dl-ar" id="sub-article-pr-image-1">[sub-article-pr-image-1] Public review contains bold text that mentions an image: <value-of select="."/>. This should be changed to a citation (and if the review image is missing, then it should be added).</report>
      
      <report test="matches(.,'[Rr]eview table \d')" role="error" flag="dl-ar" id="sub-article-pr-image-2">[sub-article-pr-image-2] Public review contains bold text that mentions an table: <value-of select="."/>. This should be changed to a citation (and if the review table is missing, then it should be added).</report>
    </rule></pattern><pattern id="sub-article-ar-image-tests-pattern"><rule context="sub-article[@article-type=('reply','author-comment')]/body//bold" id="sub-article-ar-image-tests">
      
      <report test="matches(.,'[Aa]uthor response image \d')" role="error" flag="dl-ar" id="sub-article-ar-image-1">[sub-article-ar-image-1] Author response contains bold text that mentions an image: <value-of select="."/>. This should be changed to a citation (and if the author response image is missing, then it should be added).</report>
      
      <report test="matches(.,'[Aa]uthor response table \d')" role="error" flag="dl-ar" id="sub-article-ar-image-2">[sub-article-ar-image-2] Author response contains bold text that mentions an table: <value-of select="."/>. This should be changed to a citation (and if the author response table is missing, then it should be added).</report>
    </rule></pattern><pattern id="sub-article-gen-image-tests-pattern"><rule context="sub-article/body//bold[not(matches(.,'[Dd]ecision letter (image|table) \d|[Rr]eview (image|table) \d|[Aa]uthor response (image|table) \d'))]" id="sub-article-gen-image-tests">
      
      <report test="matches(.,'image \d')" role="error" flag="dl-ar" id="sub-article-gen-image-1">[sub-article-gen-image-1] <value-of select="ancestor::sub-article/front-stub//article-title"/> contains bold text that mentions an image: <value-of select="."/>. Is there a missing image?</report>
      
      <report test="matches(.,'table \d')" role="error" flag="dl-ar" id="sub-article-gen-image-2">[sub-article-gen-image-2] <value-of select="ancestor::sub-article/front-stub//article-title"/> contains bold text that mentions a table: <value-of select="."/>. Is there a missing table?</report>
    </rule></pattern>
  
  <pattern id="ref-report-front-pattern"><rule context="sub-article[@article-type='referee-report']/front-stub" id="ref-report-front">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="ref-report-front-1">[ref-report-front-1] sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert test="$count = 1" role="error" flag="dl-ar" id="ref-report-front-2">[ref-report-front-2] sub-article front-stub must contain one, and only one contrib-group elements.</assert>
    </rule></pattern><pattern id="sub-article-contrib-tests-pattern"><rule context="sub-article[@article-type=('editor-report','referee-report','author-comment')]/front-stub/contrib-group/contrib" id="sub-article-contrib-tests">
      
      <assert test="@contrib-type='author'" role="error" flag="dl-ar" id="sub-article-contrib-test-1">[sub-article-contrib-test-1] contrib inside sub-article with article-type '<value-of select="ancestor::sub-article/@article-type"/>' must have the attribute contrib-type='author'.</assert>
      
      <assert test="name or anonymous or collab" role="error" flag="dl-ar" id="sub-article-contrib-test-2">[sub-article-contrib-test-2] sub-article contrib must have either a child name or a child anonymous element.</assert>
      
      <report test="(name and anonymous) or (collab and anonymous) or (name and collab)" role="error" flag="dl-ar" id="sub-article-contrib-test-3">[sub-article-contrib-test-3] sub-article contrib can only have a child name element or a child anonymous element or a child collab element (with descendant group members as required), it cannot have more than one of these elements. This has <value-of select="string-join(for $x in *[name()=('name','anonymous','collab')] return concat('a ',$x/name()),' and ')"/>.</report>
      
      <assert test="role" role="error" flag="dl-ar" id="sub-article-contrib-test-4">[sub-article-contrib-test-4] contrib inside sub-article with article-type '<value-of select="ancestor::sub-article/@article-type"/>' must have a child role element.</assert>
      
    </rule></pattern><pattern id="sub-article-role-tests-pattern"><rule context="sub-article/front-stub/contrib-group/contrib/role" id="sub-article-role-tests">
      <let name="sub-article-type" value="ancestor::sub-article[1]/@article-type"/>
      <let name="sub-title" value="ancestor::sub-article[1]/front-stub[1]/title-group[1]/article-title[1]"/>
      
      <report test="lower-case($sub-title)='recommendations for authors' and not(parent::contrib/preceding-sibling::contrib) and not(@specific-use='editor')" role="error" flag="dl-ar" id="sub-article-role-test-1">[sub-article-role-test-1] The role element for the first contributor in <value-of select="$sub-title"/> must have the attribute specific-use='editor'.</report>
      
      <report test="$sub-article-type='referee-report' and (lower-case($sub-title)!='recommendations for authors' or parent::contrib/preceding-sibling::contrib) and not(@specific-use='referee')" role="error" flag="dl-ar" id="sub-article-role-test-2">[sub-article-role-test-2] The role element for this contributor must have the attribute specific-use='referee'.</report>
      
      <report test="$sub-article-type='author-comment' and not(@specific-use='author')" role="error" flag="dl-ar" id="sub-article-role-test-3">[sub-article-role-test-3] The role element for contributors in the author response must have the attribute specific-use='author'.</report>
      
      <report test="@specific-use='author' and .!='Author'" role="error" flag="dl-ar" id="sub-article-role-test-4">[sub-article-role-test-4] A role element with the attribute specific-use='author' must contain the text 'Author'. This one has '<value-of select="."/>'.</report>
      
      <report test="@specific-use='editor' and not(.=('Senior and Reviewing Editor','Reviewing Editor'))" role="error" flag="dl-ar" id="sub-article-role-test-5">[sub-article-role-test-5] A role element with the attribute specific-use='editor' must contain the text 'Senior and Reviewing Editor' or 'Reviewing Editor'. This one has '<value-of select="."/>'.</report>
      
      <report test="@specific-use='referee' and .!='Reviewer'" role="error" flag="dl-ar" id="sub-article-role-test-6">[sub-article-role-test-6] A role element with the attribute specific-use='referee' must contain the text 'Reviewer'. This one has '<value-of select="."/>'.</report>
      
    </rule></pattern><pattern id="ref-report-editor-tests-pattern"><rule context="sub-article[@article-type='referee-report']/front-stub[lower-case(title-group[1]/article-title[1])='recommendations for authors']" id="ref-report-editor-tests">
      
      <assert test="count(descendant::contrib[role[@specific-use='editor']]) = 1" role="error" flag="dl-ar" id="ref-report-editor-1">[ref-report-editor-1] The Recommendations for authors must contain 1 and only 1 editor (a contrib with a role[@specific-use='editor']). This one has <value-of select="count(descendant::contrib[role[@specific-use='editor']])"/>.</assert>
      
      <assert test="count(descendant::contrib[role[@specific-use='referee']]) &gt; 0" role="error" flag="dl-ar" id="ref-report-reviewer-1">[ref-report-reviewer-1] The Recommendations for authors must contain 1 or more reviewers (a contrib with a role[@specific-use='referee']). This one has 0.</assert>
    </rule></pattern><pattern id="ref-report-editor-tests-2-pattern"><rule context="sub-article[@article-type='referee-report']/front-stub/contrib-group[1]/contrib[role[@specific-use='editor']]" id="ref-report-editor-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role[1]"/>
      <let name="top-contrib" value="ancestor::article//article-meta/contrib-group[2]/contrib[lower-case(role[1])=lower-case($role)]"/>
      <let name="top-name" value="if ($top-contrib) then e:get-name($top-contrib/name[1]) else ''"/>
      
      <report test="($top-name!='') and ($top-name!=$name)" role="error" id="ref-report-editor-2">[ref-report-editor-2] In <value-of select="ancestor::front-stub[1]//article-title"/> '<value-of select="$name"/>' is a '<value-of select="$role"/>', but in the top-level article details '<value-of select="$top-name"/>' is the '<value-of select="$top-contrib/role[1]"/>'.</report>
    </rule></pattern><pattern id="ref-report-reviewer-tests-pattern"><rule context="sub-article[@article-type='referee-report' and contains(lower-case(front-stub[1]/title-group[1]/article-title[1]),'public review')]/front-stub" id="ref-report-reviewer-tests">
      
      <assert test="count(descendant::contrib[role[@specific-use='referee']])=1" role="error" flag="dl-ar" id="ref-report-reviewer-test-1">[ref-report-reviewer-test-1] A public review must contain a single contributor which is a reviewer (a contrib with a child role[@specific-use='referee']). This one contains <value-of select="count(descendant::contrib[role[@specific-use='referee']])"/>.</assert>
      
      <report test="descendant::contrib[not(role[@specific-use='referee'])]" role="error" flag="dl-ar" id="ref-report-reviewer-test-2">[ref-report-reviewer-test-2] A public review cannot contain a contributor which is not a reviewer (i.e. a contrib without a child role[@specific-use='referee']).</report>
    </rule></pattern><pattern id="anonymous-tests-pattern"><rule context="anonymous" id="anonymous-tests">
      
      <assert test="parent::contrib[role[@specific-use='referee']]" role="error" id="anonymous-test-1">[anonymous-test-1] The anonymous element can only be used for a reviewer who has opted not to reveal their name. It cannot be placed as a child of <value-of select="if (parent::contrib) then 'a non-reviewer contrib' else parent::*/name()"/>.</assert>
      
      <report test="* or normalize-space(.)!=''" role="error" id="anonymous-test-2">[anonymous-test-2] anonymous element cannot contain any elements on text.</report>
      
      <report test="@*" role="error" id="anonymous-test-3">[anonymous-test-3] anonymous element cannot have any attributes.</report>
    </rule></pattern><pattern id="prc-reviewer-tests-pattern"><rule context="sub-article[e:is-prc(.)]//contrib[role[@specific-use='referee']]" id="prc-reviewer-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#prc-reviewer-test-1" test="name or collab" role="error" id="prc-reviewer-test-1">[prc-reviewer-test-1] A reviewer contrib in a PRC article cannot have a child <value-of select="*[name()=('name','collab')]/name()"/> element, since all reviewers are captured as anonymous. They must have an anonymous element instead.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#prc-reviewer-test-2" test="anonymous" role="error" id="prc-reviewer-test-2">[prc-reviewer-test-2] A reviewer contrib in a PRC article must have a child anonymous element. This one does not - <value-of select="."/>.</assert>
    </rule></pattern><pattern id="prc-pub-review-tests-pattern"><rule context="article[e:is-prc(.)]" id="prc-pub-review-tests">
      
      <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#prc-reviewer-test-1" test="sub-article[@article-type='referee-report']/front-stub//article-title[starts-with(lower-case(.),'reviewer #')] and (         sub-article[@article-type='referee-report']/front-stub//article-title[starts-with(lower-case(.),'consensus')]          or         sub-article[@article-type='referee-report']/front-stub//article-title[starts-with(lower-case(.),'joint')]         )" role="warning" id="prc-pub-review-test-1">[prc-pub-review-test-1] This article has individual public reviews, and also either a consensus or a joint public review, which is highly unusual. Is this correct?</report>
    </rule></pattern>
  
  <pattern id="sub-article-doi-checks-pattern"><rule context="sub-article/front-stub/article-id[@pub-id-type='doi']" id="sub-article-doi-checks">
      <let name="is-prc" value="e:is-prc(.)"/>
      <let name="msid" value="ancestor::article//article-meta/article-id[@pub-id-type='publisher-id']"/>
      <let name="umbrella-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi' and not(@specific-use='version')]"/>
      <let name="vor-version-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi' and @specific-use='version']"/>
      <let name="id" value="ancestor::sub-article/@id"/>
      <let name="expected-doi" value="if ($is-prc) then concat($vor-version-doi,'.',$id)         else concat($umbrella-doi,'.',$id)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#sub-article-doi-check-1" test=".=$expected-doi" role="error" id="sub-article-doi-check-1">[sub-article-doi-check-1] Based on whether this article is PRC (or not), the umbrella and/or version DOI and the order of the sub-articles, the DOI for peer review piece '<value-of select="ancestor::sub-article/front-stub//article-title"/>' should be '<value-of select="$expected-doi"/>', but it is currently '<value-of select="."/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#sub-article-doi-check-2" test="contains(.,concat('.',$msid,'.'))" role="error" id="sub-article-doi-check-2">[sub-article-doi-check-2] The DOI for peer review piece '<value-of select="ancestor::sub-article/front-stub//article-title"/>' must contain the overall 5-6 digit manuscript tracking number (<value-of select="$msid"/>), but it does not (<value-of select="."/>).</assert>
      
    </rule></pattern>
  
  <pattern id="research-advance-test-pattern"><rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = 'Research Advance']//article-meta" id="research-advance-test">
      
      <assert test="count(related-article[@related-article-type='article-reference']) gt 0" role="error" id="related-articles-test-1">[related-articles-test-1] Research Advance must contain an article-reference link to the original article it is building upon.</assert>
      
    </rule></pattern><pattern id="insight-test-pattern"><rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = 'Insight']//article-meta" id="insight-test">
      
      <assert test="count(related-article[@related-article-type='commentary-article']) gt 0" role="error" id="related-articles-test-2">[related-articles-test-2] Insight must contain an article-reference link (related-article[@related-article-type='commentary-article']) to the original article it is discussing.</assert>
      
    </rule></pattern><pattern id="correction-test-pattern"><rule context="article[@article-type='correction']//article-meta" id="correction-test">
      
      <assert see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hzu2u-related-articles-test-8" test="count(related-article[@related-article-type='corrected-article']) gt 0" role="error" id="related-articles-test-8">[related-articles-test-8] Corrections must contain at least 1 related-article link with the attribute related-article-type='corrected-article'.</assert>
      
    </rule></pattern><pattern id="retraction-test-pattern"><rule context="article[@article-type='retraction']//article-meta" id="retraction-test">
      
      <assert see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hl977-related-articles-test-9" test="count(related-article[@related-article-type='retracted-article']) gt 0" role="error" id="related-articles-test-9">[related-articles-test-9] Retractions must contain at least 1 related-article link with the attribute related-article-type='retracted-article'.</assert>
      
    </rule></pattern><pattern id="eoc-test-pattern"><rule context="article[@article-type='expression-of-concern']//article-meta" id="eoc-test">
      
      <assert test="count(related-article[@related-article-type='object-of-concern']) gt 0" role="error" id="related-articles-test-13">[related-articles-test-13] Expressions of Concern must contain at least 1 related-article link with the attribute related-article-type='object-of-concern'.</assert>
      
    </rule></pattern><pattern id="research-article-ra-test-pattern"><rule context="article[@article-type='research-article']//related-article" id="research-article-ra-test">
      
      <assert test="@related-article-type=('article-reference', 'commentary', 'corrected-article', 'retracted-article')" role="error" id="related-articles-test-12">[related-articles-test-12] The only types of related-article link allowed in a research article are 'article-reference' (link to another research article), 'commentary' (link to an insight), 'corrected-article' (link to a correction notice) or 'retracted-article' (link to retraction notice). The link to <value-of select="@xlink:href"/> is a <value-of select="@related-article-type"/> type link.</assert>
      
    </rule></pattern><pattern id="related-articles-conformance-pattern"><rule context="related-article" id="related-articles-conformance">
      <let name="allowed-values" value="('article-reference', 'commentary', 'commentary-article', 'corrected-article', 'retracted-article', 'object-of-concern')"/>
      <let name="article-doi" value="parent::article-meta/article-id[@pub-id-type='doi'][1]"/>
      
      <assert test="@related-article-type" role="error" id="related-articles-test-3">[related-articles-test-3] related-article element must contain a @related-article-type.</assert>
      
      <assert test="@related-article-type = $allowed-values" role="error" id="related-articles-test-4">[related-articles-test-4] @related-article-type must be equal to one of the allowed values, ('article-reference', 'commentary', 'commentary-article', 'corrected-article', 'retracted-article', and 'object-of-concern').</assert>
      
      <assert test="@ext-link-type='doi'" role="error" id="related-articles-test-5">[related-articles-test-5] related-article element must contain a @ext-link-type='doi'.</assert>
      
      <assert test="matches(@xlink:href,'^10\.7554/e[lL]ife\.[\d]{5,6}$')" role="error" id="related-articles-test-6">[related-articles-test-6] related-article element must contain a @xlink:href, the value of which should be in the form 10.7554/eLife.00000.</assert>
      
      <report test="@xlink:href = preceding::related-article/@xlink:href" role="error" id="related-articles-test-10">[related-articles-test-10] related-article elements must contain a distinct @xlink:href. There is more than 1 related article link for <value-of select="@xlink:href"/>.</report>
      
      <report test="contains(@xlink:href,$article-doi)" role="error" id="related-articles-test-11">[related-articles-test-11] An article cannot contain a related-article link to itself - please delete the related article link to <value-of select="@xlink:href"/>.</report>
    </rule></pattern>
  
  <pattern id="video-parent-conformance-pattern"><rule context="media[@mimetype='video']" id="video-parent-conformance">
      <let name="parent" value="name(..)"/>
      
      <assert test="$parent = ('sec','fig-group','body','boxed-text','app')" role="error" id="video-parent-test">[video-parent-test] <value-of select="replace(label[1],'\.$','')"/> is a child of a &lt;<value-of select="$parent"/>&gt; element. It can only be a child of sec, fig-group, body, boxed-text, or app.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-general-pattern"><rule context="element-citation" id="elem-citation-general">
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-name-5" test="descendant::etal" role="error" id="err-elem-cit-gen-name-5">[err-elem-cit-gen-name-5] The &lt;etal&gt; element in a reference is not allowed. Reference '<value-of select="ancestor::ref/@id"/>' contains it.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-date-1-9" test="count(year) &gt; 1 " role="error" id="err-elem-cit-gen-date-1-9">[err-elem-cit-gen-date-1-9] There may be at most one &lt;year&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(year)"/> &lt;year&gt; elements.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#fpage-lpage-test-1" test="(fpage) and not(lpage)" role="warning" id="fpage-lpage-test-1">[fpage-lpage-test-1] <value-of select="e:citation-format1(.)"/> has a first page <value-of select="fpage"/>, but no last page. Is this correct? Should it be an elocation-id instead?</report>
      
    </rule></pattern><pattern id="elem-citation-gen-name-3-1-pattern"><rule context="element-citation/person-group" id="elem-citation-gen-name-3-1">
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-name-3-1" test=".[not (name or collab)]" role="error" id="err-elem-cit-gen-name-3-1">[err-elem-cit-gen-name-3-1]
        Each &lt;person-group&gt; element in a reference must contain at least one
        &lt;name&gt; or, if allowed, &lt;collab&gt; element. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not.</report>
      
    </rule></pattern><pattern id="elem-citation-gen-name-3-2-pattern"><rule context="element-citation/person-group/collab" id="elem-citation-gen-name-3-2">
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-name-3-2" test="count(*) = count(italic | sub | sup)" role="error" id="err-elem-cit-gen-name-3-2">[err-elem-cit-gen-name-3-2]
        A &lt;collab&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' contains additional elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-gen-name-4-pattern"><rule context="element-citation/person-group/name/suffix" id="elem-citation-gen-name-4">
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-name-4" test=".=('Jr','Jnr', 'Sr','Snr', 'I', 'II', 'III', 'VI', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')" role="error" id="err-elem-cit-gen-name-4">[err-elem-cit-gen-name-4]
        The &lt;suffix&gt; element in a reference may only contain one of the specified values
        Jnr, Snr, I, II, III, VI, V, VI, VII, VIII, IX, X.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement
        as it contains the value '<value-of select="suffix"/>'.</assert>
      
    </rule></pattern><pattern id="elem-citation-year-pattern"><rule context="ref/element-citation/year" id="elem-citation-year">
      <let name="YYYY" value="substring(normalize-space(.), 1, 4)"/>
      <let name="current-year" value="year-from-date(current-date())"/>
      <let name="citation" value="e:citation-format1(parent::element-citation)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-date-1-2" test="(1700 le number($YYYY)) and (number($YYYY) le ($current-year + 5))" role="warning" id="err-elem-cit-gen-date-1-2">[err-elem-cit-gen-date-1-2] The numeric value of the 4 digits in the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive). Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains the value '<value-of select="."/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-date-1-3" test="./@iso-8601-date" role="error" id="err-elem-cit-gen-date-1-3">[err-elem-cit-gen-date-1-3] All &lt;year&gt; elements must have @iso-8601-date attributes. Reference '<value-of select="ancestor::ref/@id"/>' does not.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-date-1-4" test="not(./@iso-8601-date) or (1700 le number(substring(normalize-space(@iso-8601-date),1,4)) and number(substring(normalize-space(@iso-8601-date),1,4)) le ($current-year + 5))" role="warning" id="err-elem-cit-gen-date-1-4">[err-elem-cit-gen-date-1-4] The numeric value of the 4 digits in the @iso-8601-date attribute on the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive). Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the attribute contains the value '<value-of select="./@iso-8601-date"/>'.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#final-err-elem-cit-gen-date-1-5" test="not(./@iso-8601-date) or substring(normalize-space(./@iso-8601-date),1,4) = $YYYY" role="error" id="final-err-elem-cit-gen-date-1-5">[final-err-elem-cit-gen-date-1-5] The numeric value of the 4 digits in the @iso-8601-date attribute must match the first 4 digits on the &lt;year&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the element contains the value '<value-of select="."/>' and the attribute contains the value '<value-of select="./@iso-8601-date"/>'. If there is no year, and you are unable to determine this, please query with the authors.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-date-1-6" test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and         (some $y in //element-citation/descendant::year         satisfies (normalize-space($y) = concat($YYYY,'b'))         and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname         or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]         )))" role="error" id="err-elem-cit-gen-date-1-6">[err-elem-cit-gen-date-1-6] If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with the same first author surname (or collab) with a letter "b" after the year. Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-gen-date-1-7" test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or         (some $y in //element-citation/descendant::year         satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',         'abcdefghijklmnopqrstuvwxy')))         and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname         or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]         ))" role="error" id="err-elem-cit-gen-date-1-7">[err-elem-cit-gen-date-1-7]
        If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another 
        reference with the same first author surname (or collab) with the preceding letter after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
    </rule></pattern><pattern id="elem-citation-source-pattern"><rule context="ref/element-citation/source" id="elem-citation-source">
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#elem-cit-source" test="string-length(normalize-space(.)) ge 2" role="error" id="elem-cit-source">[elem-cit-source] A  &lt;source&gt; element within a <value-of select="parent::element-citation/@publication-type"/> type &lt;element-citation&gt; must contain at least two characters. - <value-of select="."/>. See Ref '<value-of select="ancestor::ref/@id"/>'.</assert>
      
    </rule></pattern><pattern id="elem-citation-ext-link-pattern"><rule context="ref/element-citation/ext-link" id="elem-citation-ext-link">
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#ext-link-attribute-content-match" test="(normalize-space(@xlink:href)=normalize-space(.)) and (normalize-space(.)!='')" role="error" id="ext-link-attribute-content-match">[ext-link-attribute-content-match] &lt;ext-link&gt; must contain content and have an @xlink:href, the value of which must be the same as the content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#link-href-conformance" test="matches(@xlink:href,'^https?://|^s?ftp://')" role="error" id="link-href-conformance">[link-href-conformance] @xlink:href must start with either "http://", "https://", "sftp://" or "ftp://". The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' is '<value-of select="@xlink:href"/>', which does not.</assert>
      
    </rule></pattern><pattern id="collab-content-pattern"><rule context="ref/element-citation//collab" id="collab-content">
      
      <report test="matches(.,'[\[\]\(\)]')" role="warning" id="collab-brackets">[collab-brackets] collab in reference '<value-of select="ancestor::ref/@id"/>' contains brackets - <value-of select="."/>. Are the brackets necessary?</report>
      
    </rule></pattern>
  
  <pattern id="ref-list-ordering-pattern"><rule context="ref[preceding-sibling::ref]" id="ref-list-ordering">
      <let name="order-value" value="e:ref-list-string(self::*)"/>
      <let name="preceding-ref-order-value" value="e:ref-list-string(preceding-sibling::ref[1])"/>
      <!-- Included for legacy reasons. can be removed  -->
      <let name="kriya1-order-value" value="e:ref-list-string2(self::*)"/>
      <let name="preceding-ref-kriya1-order-value" value="e:ref-list-string2(preceding-sibling::ref[1])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-high-2-2" test="($order-value gt $preceding-ref-order-value) or ($kriya1-order-value gt $preceding-ref-kriya1-order-value)" role="error" id="err-elem-cit-high-2-2">[err-elem-cit-high-2-2] The order of &lt;element-citation&gt;s in the reference list should be name and date, arranged alphabetically by the first author’s surname, or by the value of the first &lt;collab&gt; element. In the case of two authors, the sequence should be arranged by both authors' surnames, then date. For three or more authors, the sequence should be the first author's surname, then date. Reference '<value-of select="@id"/>' appears to be in a different order.</assert>
    </rule></pattern><pattern id="ref-pattern"><rule context="ref" id="ref">
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-high-1" test="count(*) = count(element-citation)" role="error" id="err-elem-cit-high-1">[err-elem-cit-high-1] The only element that is allowed as a child of &lt;ref&gt; is &lt;element-citation&gt;. Reference '<value-of select="@id"/>' has other elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-high-3-1" test="@id" role="error" id="err-elem-cit-high-3-1">[err-elem-cit-high-3-1] Each &lt;ref&gt; element must have an @id attribute.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-high-3-2" test="matches(normalize-space(@id) ,'^bib\d+$')" role="error" id="err-elem-cit-high-3-2">[err-elem-cit-high-3-2] Each &lt;ref&gt; element must have an @id attribute that starts with 'bib' and ends with a number. Reference '<value-of select="@id"/>' has the value '<value-of select="@id"/>', which is incorrect.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-high-3-3" test="count(preceding-sibling::ref)=0 or number(substring(@id,4)) gt number(substring(preceding-sibling::ref[1]/@id,4))" role="error" id="err-elem-cit-high-3-3">[err-elem-cit-high-3-3] The sequence of ids in the &lt;ref&gt; elements must increase monotonically (e.g. 1,2,3,4,5, . . . ,50,51,52,53, . . . etc). Reference '<value-of select="@id"/>' has the value  '<value-of select="@id"/>', which does not fit this pattern.</assert>
      
    </rule></pattern><pattern id="xref-pattern"><rule context="xref[@ref-type='bibr' and matches(normalize-space(.),'[b-z]$')]" id="xref">
      
        <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-xref-high-2-1" test="some $x in preceding::xref satisfies (substring(normalize-space(.),string-length(.)) gt substring(normalize-space($x),string-length(.)))" role="error" id="err-xref-high-2-1">[err-xref-high-2-1] Citations in the text to references with the same author(s) in the same year must be arranged in the same order as the reference list. The xref with the value '<value-of select="."/>' is in the wrong order in the text. Check all the references to citations for the same authors to determine which need to be changed.</assert>
      
    </rule></pattern><pattern id="elem-citation-pattern"><rule context="element-citation" id="elem-citation">
      <let name="article-doi" value="lower-case(ancestor::article/descendant::article-meta[1]/article-id[@pub-id-type='doi'][1])"/>
      <let name="title" value="lower-case(ancestor::article/descendant::article-meta[1]/descendant::article-title[1])"/>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#err-elem-cit-high-6-2" test="@publication-type = ('journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis')" role="error" id="err-elem-cit-high-6-2">[err-elem-cit-high-6-2] element-citation must have a publication-type attribute with one of these values: 'journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', or 'thesis'. Reference '<value-of select="../@id"/>' has '<value-of select="if (@publication-type) then concat('a @publication-type with the value ',@publication-type) else ('no @publication-type')"/>'.</assert>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#final-element-cite-year" test="not(year)" role="error" id="final-element-cite-year">[final-element-cite-year] '<value-of select="@publication-type"/>' type references must have a year. Reference '<value-of select="../@id"/>' does not. If you are unable to determine this, please ensure to query the authors for the year of publication.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#self-cite-1" test="lower-case(pub-id[@pub-id-type='doi'][1]) = $article-doi" role="error" id="self-cite-1">[self-cite-1] '<value-of select="@publication-type"/>' type reference has a doi which is the same as this article - <value-of select="pub-id[@pub-id-type='doi']"/>. Is the reference correct? If it is intentional, please remove the reference, and replace citations in the text with the text 'current work' or similar.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#self-cite-1" test="(lower-case(pub-id[@pub-id-type='doi'][1]) != $article-doi) and                (lower-case(source[1]) = 'elife') and                ((lower-case(article-title[1]) = $title) or (lower-case(chapter-title[1]) = $title)) " role="error" id="self-cite-2">[self-cite-2] '<value-of select="@publication-type"/>' type reference looks to possibly be citing itself. If that's the case (and this isn't an error within the reference), please delete the reference and replace any citations in the text with the text 'current work'.</report>
      
    </rule></pattern><pattern id="element-citation-descendants-pattern"><rule context="element-citation//*" id="element-citation-descendants">
      
      
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#final-empty-elem-cit-des" test="normalize-space(.)=''" role="error" id="final-empty-elem-cit-des">[final-empty-elem-cit-des] <name/> element is empty - this is not allowed. It must contain content.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#tagging-elem-cit-des" test="matches(.,'&lt;/?[a-z]*/?&gt;')" role="error" id="tagging-elem-cit-des">[tagging-elem-cit-des] <name/> element contains tagging, which should be removed - '<value-of select="."/>'.</report>
    
    </rule></pattern>
  
  <pattern id="elem-citation-journal-pattern"><rule context="element-citation[@publication-type='journal']" id="elem-citation-journal">
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#final-err-elem-cit-journal-2-1" test="count(person-group)=1" role="error" id="final-err-elem-cit-journal-2-1">[final-err-elem-cit-journal-2-1] Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;person-group&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#final-err-elem-cit-journal-2-2" test="person-group[@person-group-type='author']" role="error" id="final-err-elem-cit-journal-2-2">[final-err-elem-cit-journal-2-2] Each  &lt;element-citation&gt; of type 'journal' must contain one &lt;person-group&gt;  with the attribute person-group-type 'author'. Reference '<value-of select="ancestor::ref/@id"/>' has a  &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#final-err-elem-cit-journal-3-1" test="count(article-title)=1" role="error" id="final-err-elem-cit-journal-3-1">[final-err-elem-cit-journal-3-1] Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#final-err-elem-cit-journal-4-1" test="count(source)=1" role="error" id="final-err-elem-cit-journal-4-1">[final-err-elem-cit-journal-4-1] Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-4-2-2" test="count(source)=1 and count(source/*)!=0" role="error" id="err-elem-cit-journal-4-2-2">[err-elem-cit-journal-4-2-2] A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' may not contain child elements. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-5-1-3" test="count(volume) le 1" role="error" id="err-elem-cit-journal-5-1-3">[err-elem-cit-journal-5-1-3] There may be no more than one  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal'. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(volume)"/> &lt;volume&gt; elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-6-5-1" test="lpage and not(fpage)" role="error" id="err-elem-cit-journal-6-5-1">[err-elem-cit-journal-6-5-1] &lt;lpage&gt; is only allowed if &lt;fpage&gt; is present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; but no &lt;fpage&gt;.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-6-5-2" test="lpage and (number(fpage[1]) ge number(lpage[1]))" role="error" id="err-elem-cit-journal-6-5-2">[err-elem-cit-journal-6-5-2] &lt;lpage&gt; must be larger than &lt;fpage&gt;, if present. Reference '<value-of select="ancestor::ref/@id"/>' has first page &lt;fpage&gt; = '<value-of select="fpage"/>' but last page &lt;lpage&gt; = '<value-of select="lpage"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-6-7" test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1 or count(comment) gt 1" role="error" id="err-elem-cit-journal-6-7">[err-elem-cit-journal-6-7] The following elements may not occur more than once in an &lt;element-citation&gt;: &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, and &lt;comment&gt;In press&lt;/comment&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/> &lt;fpage&gt;, <value-of select="count(lpage)"/> &lt;lpage&gt;, <value-of select="count(elocation-id)"/> &lt;elocation-id&gt;, and <value-of select="count(comment)"/> &lt;comment&gt; elements.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-12" test="count(*) = count(person-group| year| article-title| source| volume| fpage| lpage| elocation-id| comment| pub-id)" role="error" id="err-elem-cit-journal-12">[err-elem-cit-journal-12] The only elements allowed as children of &lt;element-citation&gt; with the publication-type="journal" are: &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;volume&gt;, &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, &lt;comment&gt;, and &lt;pub-id&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-journal-article-title-pattern"><rule context="element-citation[@publication-type='journal']/article-title" id="elem-citation-journal-article-title">
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-3-2" test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-journal-3-2">[err-elem-cit-journal-3-2] An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule></pattern><pattern id="elem-citation-journal-volume-pattern"><rule context="element-citation[@publication-type='journal']/volume" id="elem-citation-journal-volume">
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-5-1-2" test="count(*)=0 and (string-length(text()) ge 1)" role="error" id="err-elem-cit-journal-5-1-2">[err-elem-cit-journal-5-1-2] A &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal' must contain at least one character and may not contain child elements. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters and/or child elements.</assert>
    </rule></pattern><pattern id="elem-citation-journal-fpage-pattern"><rule context="element-citation[@publication-type='journal']/fpage" id="elem-citation-journal-fpage">
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-6-2" test="count(../elocation-id) eq 0 and count(../comment) eq 0" role="error" id="err-elem-cit-journal-6-2">[err-elem-cit-journal-6-2] If &lt;fpage&gt; is present, neither &lt;elocation-id&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt; and one of those elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#err-elem-cit-journal-6-6" test="matches(normalize-space(.),'^\D\d') and ../lpage and not(starts-with(../lpage[1],substring(.,1,1)))" role="error" id="err-elem-cit-journal-6-6">[err-elem-cit-journal-6-6] If the content of &lt;fpage&gt; begins with a letter and digit, then the content of  &lt;lpage&gt; must begin with the same letter. Reference '<value-of select="ancestor::ref/@id"/>' does not.</report>
      
    </rule></pattern><pattern id="elem-citation-journal-elocation-id-pattern"><rule context="element-citation[@publication-type='journal']/elocation-id" id="elem-citation-journal-elocation-id">
      
      <assert test="count(../fpage) eq 0 and count(../comment) eq 0" role="error" id="err-elem-cit-journal-6-3">[err-elem-cit-journal-6-3] If &lt;elocation-id&gt; is present, neither &lt;fpage&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;elocation-id&gt; and one of those elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-journal-comment-pattern"><rule context="element-citation[@publication-type='journal']/comment" id="elem-citation-journal-comment">
      
      <assert test="count(../fpage) eq 0 and count(../elocation-id) eq 0" role="error" id="err-elem-cit-journal-6-4">[err-elem-cit-journal-6-4] If &lt;comment&gt;In press&lt;/comment&gt; is present, neither &lt;fpage&gt; nor &lt;elocation-id&gt; may be present. Reference '<value-of select="ancestor::ref/@id"/>' has one of those elements.</assert>
      
      <assert test="text() = 'In press'" role="error" id="err-elem-cit-journal-13">[err-elem-cit-journal-13] Comment elements with content other than 'In press' are not allowed. Reference '<value-of select="ancestor::ref/@id"/>' has such a &lt;comment&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-journal-pub-id-pattern"><rule context="element-citation[@publication-type='journal']/pub-id" id="elem-citation-journal-pub-id">
      
      <assert test="@pub-id-type=('doi','pmid')" role="error" id="err-elem-cit-journal-9-1">[err-elem-cit-journal-9-1] Each &lt;pub-id&gt;, if present in a journal reference, must have a @pub-id-type of either "doi" or "pmid". The pub-id-type attribute on &lt;pub-id&gt; in Reference '<value-of select="ancestor::ref/@id"/>' is <value-of select="@pub-id-type"/>.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-book-pattern"><rule context="element-citation[@publication-type='book']" id="elem-citation-book">
      <let name="publisher-locations" value="'publisher-locations.xml'"/>
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hc12m-err-elem-cit-book-2-2" test="(count(person-group[@person-group-type='author']) + count(person-group[@person-group-type='editor'])) = count(person-group)" role="error" id="err-elem-cit-book-2-2">[err-elem-cit-book-2-2] The only values allowed for @person-group-type in book references are "author" and "editor". Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h5n4c-final-err-elem-cit-book-2-3" test="count(person-group)=1 or (count(person-group[@person-group-type='author'])=1 and count(person-group[@person-group-type='editor'])=1)" role="error" id="final-err-elem-cit-book-2-3">[final-err-elem-cit-book-2-3] In a book reference, there should be a single person-group element (either author or editor) or one person-group with @person-group-type="author" and one person-group with @person-group-type=editor. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hifu4-final-err-elem-cit-book-10-1" test="count(source)=1" role="error" id="final-err-elem-cit-book-10-1">[final-err-elem-cit-book-10-1] Each  &lt;element-citation&gt; of type 'book' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hp3kx-err-elem-cit-book-10-2-2" test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" role="error" id="err-elem-cit-book-10-2-2">[err-elem-cit-book-10-2-2] A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'book' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h5k88-final-err-elem-cit-book-13-1" test="count(publisher-name)=1" role="error" id="final-err-elem-cit-book-13-1">[final-err-elem-cit-book-13-1] One and only one &lt;publisher-name&gt; is required in a book reference. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/> &lt;publisher-name&gt; elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h4u4v-warning-elem-cit-book-13-3" test="some $p in document($publisher-locations)/locations/location/text()         satisfies ends-with(publisher-name[1],$p)" role="warning" id="warning-elem-cit-book-13-3">[warning-elem-cit-book-13-3] The content of &lt;publisher-name&gt; should not end with a publisher location. Reference '<value-of select="ancestor::ref/@id"/>' contains the string <value-of select="publisher-name"/>, which ends with a publisher location.</report>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#ht2sp-err-elem-cit-book-16" test="(lpage or fpage) and not(chapter-title)" role="warning" id="err-elem-cit-book-16">[err-elem-cit-book-16] Book reference '<value-of select="ancestor::ref/@id"/>' has first and/or last pages, but no chapter title. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hu702-err-elem-cit-book-36" test="(lpage and fpage) and (number(fpage[1]) &gt;= number(lpage[1]))" role="error" id="err-elem-cit-book-36">[err-elem-cit-book-36] If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hbbs8-err-elem-cit-book-36-2" test="lpage and not (fpage)" role="error" id="err-elem-cit-book-36-2">[err-elem-cit-book-36-2] If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; but not &lt;fpage&gt;.</report>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hgboy-err-elem-cit-book-36-6" test="count(lpage) &gt; 1 or count(fpage) &gt; 1" role="error" id="err-elem-cit-book-36-6">[err-elem-cit-book-36-6] At most one &lt;lpage&gt; and one &lt;fpage&gt; are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(lpage)"/> &lt;lpage&gt; elements and <value-of select="count(fpage)"/> &lt;fpage&gt; elements.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h03ib-err-elem-cit-book-40" test="count(*) = count(person-group| year| source| chapter-title| publisher-loc|publisher-name|volume|         edition| fpage| lpage| pub-id | comment)" role="error" id="err-elem-cit-book-40">[err-elem-cit-book-40] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="book" are: &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;chapter-title&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;volume&gt;, &lt;edition&gt;, &lt;fpage&gt;, &lt;lpage&gt;, &lt;pub-id&gt;, and &lt;comment&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-book-person-group-pattern"><rule context="element-citation[@publication-type='book']/person-group" id="elem-citation-book-person-group">
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hcob2-err-elem-cit-book-2-1" test="@person-group-type" role="error" id="err-elem-cit-book-2-1">[err-elem-cit-book-2-1] Each &lt;person-group&gt; must have a @person-group-type attribute. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; element with no @person-group-type attribute.</assert>
    </rule></pattern><pattern id="elem-citation-book-chapter-title-pattern"><rule context="element-citation[@publication-type='book']/chapter-title" id="elem-citation-book-chapter-title">
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hzce0-final-err-elem-cit-book-22" test="count(../person-group[@person-group-type='author'])=1" role="error" id="final-err-elem-cit-book-22">[final-err-elem-cit-book-22] If there is a &lt;chapter-title&gt; element there must be one and only one &lt;person-group person-group-type="author"&gt;. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hhtxz-err-elem-cit-book-28-1" test="count(../person-group[@person-group-type='editor']) le 1" role="error" id="err-elem-cit-book-28-1">[err-elem-cit-book-28-1] If there is a &lt;chapter-title&gt; element there may be a maximum of one &lt;person-group person-group-type="editor"&gt;. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h2922-err-elem-cit-book-31" test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-book-31">[err-elem-cit-book-31] A &lt;chapter-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule></pattern><pattern id="elem-citation-book-publisher-name-pattern"><rule context="element-citation[@publication-type='book']/publisher-name" id="elem-citation-book-publisher-name">
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hvmqu-err-elem-cit-book-13-2" test="count(*)=0" role="error" id="err-elem-cit-book-13-2">[err-elem-cit-book-13-2] No elements are allowed inside &lt;publisher-name&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the &lt;publisher-name&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-book-edition-pattern"><rule context="element-citation[@publication-type='book']/edition" id="elem-citation-book-edition">
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hi14u-err-elem-cit-book-15" test="count(*)=0" role="error" id="err-elem-cit-book-15">[err-elem-cit-book-15] No elements are allowed inside &lt;edition&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the &lt;edition&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-book-pub-id-pattern"><rule context="element-citation[@publication-type='book']/pub-id" id="elem-citation-book-pub-id">
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h4qcy-err-elem-cit-book-17" test="@pub-id-type=('doi','pmid','isbn')" role="error" id="err-elem-cit-book-17">[err-elem-cit-book-17] Each &lt;pub-id&gt;, if present in a book reference, must have a @pub-id-type of one of these values: doi, pmid, isbn. The pub-id-type attribute on &lt;pub-id&gt; in Reference '<value-of select="ancestor::ref/@id"/>' is <value-of select="@pub-id-type"/>.</assert>
      
    </rule></pattern><pattern id="elem-citation-book-comment-pattern"><rule context="element-citation[@publication-type='book']/comment" id="elem-citation-book-comment">
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hh47s-err-elem-cit-book-6-4" test="count(../fpage) eq 0" role="error" id="err-elem-cit-book-6-4">[err-elem-cit-book-6-4] If &lt;comment&gt;In press&lt;/comment&gt; is present, &lt;fpage&gt; cannot be present. Reference '<value-of select="ancestor::ref/@id"/>' has one of those elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h6tpw-err-elem-cit-book-13" test="text() = 'In press'" role="error" id="err-elem-cit-book-13">[err-elem-cit-book-13] Comment elements with content other than 'In press' are not allowed. Reference '<value-of select="ancestor::ref/@id"/>' has such a &lt;comment&gt; element.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-data-pattern"><rule context="ref/element-citation[@publication-type='data']" id="elem-citation-data">
      
      <report see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#err-elem-cit-data-3-1" test="count(person-group[@person-group-type='author']) gt 1" role="error" id="err-elem-cit-data-3-1">[err-elem-cit-data-3-1] Data references must have one and only one &lt;person-group person-group-type='author'&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='author'])"/>.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#final-err-elem-cit-data-3-2" test="count(person-group) lt 1" role="error" id="final-err-elem-cit-data-3-2">[final-err-elem-cit-data-3-2] Data references must have one and only one &lt;person-group person-group-type='author'&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has 0.</report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#final-err-elem-cit-data-10" test="count(data-title)=1" role="error" id="final-err-elem-cit-data-10">[final-err-elem-cit-data-10] Data reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> data-title elements. It must contain one (and only one).</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#final-err-elem-cit-data-11-2" test="count(source)=1" role="error" id="final-err-elem-cit-data-11-2">[final-err-elem-cit-data-11-2] Data reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> source elements. It must contain one (and only one).</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#err-elem-cit-data-11-3-2" test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" role="error" id="err-elem-cit-data-11-3-2">[err-elem-cit-data-11-3-2] A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'data' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#final-err-elem-cit-data-13-1" test="(count(pub-id) = 1) or count(ext-link) = 1" role="error" id="final-err-elem-cit-data-13-1">[final-err-elem-cit-data-13-1] There must be one (and only one) pub-id or one (and only one) ext-link. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements and <value-of select="count(ext-link)"/> &lt;ext-link&gt; elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#elem-cit-data-pub-id-ext-link" test="pub-id and ext-link" role="error" id="elem-cit-data-pub-id-ext-link">[elem-cit-data-pub-id-ext-link] Dataset reference '<value-of select="ancestor::ref/@id"/>' has both &lt;pub-id&gt; &lt;ext-link&gt; elements. There can only be one or the other, not both.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#err-elem-cit-data-18" test="count(*) = count(person-group| data-title| source| year| pub-id| version| ext-link)" role="error" id="err-elem-cit-data-18">[err-elem-cit-data-18] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="data" are: &lt;person-group&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, &lt;ext-link&gt; and &lt;version&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-data-v2-pattern"><rule context="article[e:get-version(.)!='1']//element-citation[@publication-type='data']" id="elem-citation-data-v2">
      
      <assert test="@specific-use=('generated','analyzed')" role="error" flag="version-2" id="err-elem-cit-data-1-v2">[err-elem-cit-data-1-v2] element-citation[@publication-type='data'] must have a specific-use attribute is either 'generated' or 'analyzed'. Reference '<value-of select="ancestor::ref/@id"/>' does not have this attribute or the value is incorrect.</assert>
      
    </rule></pattern><pattern id="elem-citation-data-person-group-pattern"><rule context="element-citation[@publication-type='data']/person-group" id="elem-citation-data-person-group">
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#data-cite-person-group" test="@person-group-type='author'" role="error" id="data-cite-person-group">[data-cite-person-group] The person-group for a data reference must have the attribute person-group-type="author". This one in reference '<value-of select="ancestor::ref/@id"/>' has either no person-group attribute or the value is incorrect (<value-of select="@person-group-type"/>).</assert>
      
    </rule></pattern><pattern id="elem-citation-data-pub-id-doi-pattern"><rule context="ref/element-citation[@publication-type='data']/pub-id[@pub-id-type='doi']" id="elem-citation-data-pub-id-doi">
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#err-elem-cit-data-14-2" test="not(@xlink:href)" role="error" id="err-elem-cit-data-14-2">[err-elem-cit-data-14-2] If the pub-id is of pub-id-type doi, it may not have an @xlink:href. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with type doi and an @link-href with value '<value-of select="@link-href"/>'.</assert>
      
    </rule></pattern><pattern id="elem-citation-data-pub-id-pattern"><rule context="ref/element-citation[@publication-type='data']/pub-id" id="elem-citation-data-pub-id">
      
      <assert see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#err-elem-cit-data-13-2" test="@pub-id-type=('accession','doi')" role="error" id="err-elem-cit-data-13-2">[err-elem-cit-data-13-2] Each pub-id element must have a pub-id-type which is either accession or doi. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with the type '<value-of select="@pub-id-type"/>'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/data-references-4jxukxzy#err-elem-cit-data-14-1" test="if (@pub-id-type != 'doi') then not(@xlink:href) else ()" role="error" id="err-elem-cit-data-14-1">[err-elem-cit-data-14-1] If the pub-id is of any pub-id-type except doi, it must have an @xlink:href. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with type '<value-of select="@pub-id-type"/>' but no @xlink-href.</report>
      
    </rule></pattern><pattern id="elem-citation-data-gend-pattern"><rule context="element-citation[@publication-type='data' and year and @specific-use=('generated','isSupplementedBy')]" id="elem-citation-data-gend">
      <let name="year" value="replace(year[1],'[^\d]','')"/>
      <let name="current-year" value="year-from-date(current-date())"/>
      <let name="diff" value="number($current-year) - number($year)"/>
      
      <report test="($diff gt 1) or ($diff lt -1)" role="warning" id="final-data-old-and-gend">[final-data-old-and-gend] Dataset reference <value-of select="if (parent::ref) then parent::ref/@id else 'in data availability section'"/> is marked as generated but the year is <value-of select="$year"/>. Is this correct?</report>
      
    </rule></pattern>
  
  <pattern id="elem-citation-patent-pattern"><rule context="element-citation[@publication-type='patent']" id="elem-citation-patent">
      
      
      
      <assert test="count(person-group[@person-group-type='inventor'])=1" role="error" id="final-err-elem-cit-patent-2-1">[final-err-elem-cit-patent-2-1] There must be one person-group with @person-group-type="inventor". Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='inventor'])"/> &lt;person-group&gt; elements of type 'inventor'.</assert>
      
      <assert test="every $type in person-group/@person-group-type         satisfies $type = ('assignee','inventor')" role="error" id="err-elem-cit-patent-2-3">[err-elem-cit-patent-2-3] The only allowed types of person-group elements are "assignee" and "inventor". Reference '<value-of select="ancestor::ref/@id"/>' has &lt;person-group&gt; elements of other types.</assert>
      
      <assert test="count(person-group[@person-group-type='assignee']) le 1" role="error" id="err-elem-cit-patent-2A">[err-elem-cit-patent-2A] There may be zero or one person-group elements with @person-group-type="assignee". Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='assignee'])"/> &lt;person-group&gt; elements of type 'assignee'.</assert>
      
      
      
      <assert test="count(article-title)=1" role="error" id="final-err-elem-cit-patent-8-1">[final-err-elem-cit-patent-8-1] Each  &lt;element-citation&gt; of type 'patent' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      
      
      <assert test="count(source)=1" role="error" id="final-err-elem-cit-patent-9-1">[final-err-elem-cit-patent-9-1] Each &lt;element-citation&gt; of type 'patent' must contain one and only one &lt;source&gt; elements. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      
      
      <assert test="patent" role="error" id="final-err-elem-cit-patent-10-1-1">[final-err-elem-cit-patent-10-1-1] The  &lt;patent&gt; element is required. Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;patent&gt; elements.</assert>
      
      
      
      <assert test="ext-link" role="error" id="final-err-elem-cit-patent-11-1">[final-err-elem-cit-patent-11-1] The &lt;ext-link&gt; element is required in a patent reference. Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;ext-link&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group| article-title| source| year| patent| ext-link)" role="error" id="err-elem-cit-patent-18">[err-elem-cit-patent-18] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="patent" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;patent&gt;, and &lt;ext-link&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-patent-article-title-pattern"><rule context="element-citation[@publication-type='patent']/article-title" id="elem-citation-patent-article-title"> 
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-patent-8-2-1">[err-elem-cit-patent-8-2-1] A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' must contain at least two characters. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-patent-8-2-2">[err-elem-cit-patent-8-2-2] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule></pattern><pattern id="elem-citation-patent-source-pattern"><rule context="element-citation[@publication-type='patent']/source" id="elem-citation-patent-source"> 
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-patent-9-2-2">[err-elem-cit-patent-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-patent-patent-pattern"><rule context="element-citation[@publication-type='patent']/patent" id="elem-citation-patent-patent"> 
      <let name="countries" value="'countries.xml'"/>
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-patent-10-1-2">[err-elem-cit-patent-10-1-2] The &lt;patent&gt; element may not have child elements. Reference '<value-of select="ancestor::ref/@id"/>' has child elements.</assert>
      
      <assert test="some $x in document($countries)/countries/country/@country satisfies ($x=@country)" role="error" id="err-elem-cit-patent-10-2">[err-elem-cit-patent-10-2] The &lt;patent&gt; element must have a country attribute, the value of which must be a 2 letter ISO 3166-1 country code. Reference '<value-of select="ancestor::ref/@id"/>' has a patent/@country attribute with the value '<value-of select="@country"/>', which is not in the list.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-software-pattern"><rule context="element-citation[@publication-type = 'software']" id="elem-citation-software">
      
      <assert see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#err-elem-cit-software-2-1" test="count(person-group[@person-group-type='author']) = 1" role="error" id="err-elem-cit-software-2-1">[err-elem-cit-software-2-1] Each &lt;element-citation&gt; of type 'software' must contain one &lt;person-group&gt; element with attribute person-group-type = author. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='author'])"/> &lt;person-group&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#err-elem-cit-software-2-2" test="person-group[@person-group-type='author']" role="error" id="err-elem-cit-software-2-2">[err-elem-cit-software-2-2] The &lt;person-group&gt; in a software reference must have the attribute person-group-type set to 'author'. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#err-elem-cit-software-10-1" test="count(data-title) &gt; 1" role="error" id="err-elem-cit-software-10-1">[err-elem-cit-software-10-1] Each &lt;element-citation&gt; of type 'software' may contain one and only one &lt;data-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(data-title)"/> &lt;data-title&gt; elements.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#err-elem-cit-software-16" test="count(*) = count(person-group | year | data-title | source | version | publisher-name | publisher-loc | ext-link | pub-id)" role="error" id="err-elem-cit-software-16">[err-elem-cit-software-16] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="software" are: &lt;person-group&gt;, &lt;year&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;version&gt;, &lt;publisher-name&gt;, &lt;publisher-loc&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
      <report test="pub-id and ext-link" role="error" id="elem-cit-software-pub-id-ext-link">[elem-cit-software-pub-id-ext-link] Software reference '<value-of select="ancestor::ref/@id"/>' has both &lt;pub-id&gt; &lt;ext-link&gt; elements. There can only be one or the other, not both.</report>
      
    </rule></pattern><pattern id="elem-citation-software-data-title-pattern"><rule context="element-citation[@publication-type = 'software']/data-title" id="elem-citation-software-data-title">
      
      <assert see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#err-elem-cit-software-10-2" test="count(*) = count(sub | sup | italic)" role="error" id="err-elem-cit-software-10-2">[err-elem-cit-software-10-2] An &lt;data-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-preprint-pattern"><rule context="element-citation[@publication-type='preprint']" id="elem-citation-preprint">
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-2-1" test="count(person-group)=1" role="error" id="err-elem-cit-preprint-2-1">[err-elem-cit-preprint-2-1] There must be one and only one person-group. <value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-8-1" test="count(article-title)=1" role="error" id="err-elem-cit-preprint-8-1">[err-elem-cit-preprint-8-1] Each  &lt;element-citation&gt; of type 'preprint' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-9-1" test="count(source) = 1" role="error" id="err-elem-cit-preprint-9-1">[err-elem-cit-preprint-9-1] Each  &lt;element-citation&gt; of type 'preprint' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-10-1" test="count(pub-id) le 1" role="error" id="err-elem-cit-preprint-10-1">[err-elem-cit-preprint-10-1] One &lt;pub-id&gt; element is allowed. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-10-3" test="count(pub-id)=1 or count(ext-link)=1" role="error" id="final-err-elem-cit-preprint-10-3">[final-err-elem-cit-preprint-10-3] Either one &lt;pub-id&gt; or one &lt;ext-link&gt; element is required in a preprint reference. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements and <value-of select="count(ext-link)"/> &lt;ext-link&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-13" test="count(*) = count(person-group| article-title| source| year| pub-id| ext-link)" role="error" id="err-elem-cit-preprint-13">[err-elem-cit-preprint-13] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="preprint" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, and &lt;ext-link&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-preprint-person-group-pattern"><rule context="element-citation[@publication-type='preprint']/person-group" id="elem-citation-preprint-person-group"> 
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-2-2" test="@person-group-type='author'" role="error" id="err-elem-cit-preprint-2-2">[err-elem-cit-preprint-2-2] The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' contains @person-group-type='<value-of select="@person-group-type"/>'.</assert>
      
    </rule></pattern><pattern id="elem-citation-preprint-pub-id-pattern"><rule context="element-citation[@publication-type='preprint']/pub-id" id="elem-citation-preprint-pub-id"> 
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-10-2" test="@pub-id-type='doi'" role="error" id="err-elem-cit-preprint-10-2">[err-elem-cit-preprint-10-2] If present, the &lt;pub-id&gt; element must contain @pub-id-type='doi'. The &lt;pub-id&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' contains @pub-id-type='<value-of select="@pub-id-type"/>'.</assert>
      
    </rule></pattern><pattern id="elem-citation-preprint-article-title-pattern"><rule context="element-citation[@publication-type='preprint']/article-title" id="elem-citation-preprint-article-title"> 
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-8-2-1" test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-preprint-8-2-1">[err-elem-cit-preprint-8-2-1] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' must contain at least two characters. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-8-2-2" test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-preprint-8-2-2">[err-elem-cit-preprint-8-2-2] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule></pattern><pattern id="elem-citation-preprint-source-pattern"><rule context="element-citation[@publication-type='preprint']/source" id="elem-citation-preprint-source"> 
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#err-elem-cit-preprint-9-2-2" test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-preprint-9-2-2">[err-elem-cit-preprint-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-web-pattern"><rule context="element-citation[@publication-type='web']" id="elem-citation-web">
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-web-2-1">[err-elem-cit-web-2-1] There must be one and only one person-group. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      
      
      <assert test="count(article-title)=1" role="error" id="final-err-elem-cit-web-8-1">[final-err-elem-cit-web-8-1] Each  &lt;element-citation&gt; of type 'web' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <report test="count(source) &gt; 1" role="error" id="err-elem-cit-web-9-1">[err-elem-cit-web-9-1] Each  &lt;element-citation&gt; of type 'web' may contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</report>
      
      <assert test="count(ext-link)=1" role="error" id="err-elem-cit-web-10-1">[err-elem-cit-web-10-1] One and only one &lt;ext-link&gt; element is required. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(ext-link)"/> &lt;ext-link&gt; elements.</assert>
      
      
      
      <report test="count(date-in-citation) lt 1" role="error" id="final-err-elem-cit-web-11-1">[final-err-elem-cit-web-11-1] Web Reference '<value-of select="ancestor::ref/@id"/>' has no accessed date (&lt;date-in-citation&gt; element) which is required.</report>
      
      <report test="count(date-in-citation) gt 1" role="error" id="err-elem-cit-web-11-1-1">[err-elem-cit-web-11-1-1] Web Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(date-in-citation)"/> &lt;date-in-citation&gt; elements. One and only one &lt;date-in-citation&gt; element is required.</report>
      
      <assert test="count(*) = count(person-group|article-title|source|year|ext-link|date-in-citation)" role="error" id="err-elem-cit-web-12">[err-elem-cit-web-12] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="web" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;ext-link&gt; and &lt;date-in-citation&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-web-person-group-pattern"><rule context="element-citation[@publication-type='web']/person-group" id="elem-citation-web-person-group"> 
      
      <assert test="@person-group-type='author'" role="error" id="err-elem-cit-web-2-2">[err-elem-cit-web-2-2] The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' contains @person-group-type='<value-of select="@person-group-type"/>'.</assert>
      
    </rule></pattern><pattern id="elem-citation-web-article-title-pattern"><rule context="element-citation[@publication-type='web']/article-title" id="elem-citation-web-article-title"> 
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-web-8-2-1">[err-elem-cit-web-8-2-1] A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' must contain 
        at least two characters. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-web-8-2-2">[err-elem-cit-web-8-2-2] A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule></pattern><pattern id="elem-citation-web-source-pattern"><rule context="element-citation[@publication-type='web']/source" id="elem-citation-web-source"> 
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-web-9-2-2">[err-elem-cit-web-9-2-2] A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-web-date-in-citation-pattern"><rule context="element-citation[@publication-type='web']/date-in-citation" id="elem-citation-web-date-in-citation"> 
      <let name="date-regex" value="'^[12][0-9][0-9][0-9]\-0[13578]\-[12][0-9]$|         ^[12][0-9][0-9][0-9]\-0[13578]\-0[1-9]$|         ^[12][0-9][0-9][0-9]\-0[13578]\-3[01]$|         ^[12][0-9][0-9][0-9]\-02\-[12][0-9]$|         ^[12][0-9][0-9][0-9]\-02\-0[1-9]$|         ^[12][0-9][0-9][0-9]\-0[469]\-0[1-9]$|         ^[12][0-9][0-9][0-9]\-0[469]\-[12][0-9]$|         ^[12][0-9][0-9][0-9]\-0[469]\-30$|         ^[12][0-9][0-9][0-9]\-[1-2][02]\-[12][0-9]$|         ^[12][0-9][0-9][0-9]\-[1-2][02]\-0[1-9]$|         ^[12][0-9][0-9][0-9]\-[1-2][02]\-3[01]$|         ^[12][0-9][0-9][0-9]\-11\-0[1-9]$|         ^[12][0-9][0-9][0-9]\-11\-[12][0-9]$|         ^[12][0-9][0-9][0-9]\-11\-30$'"/>
      
      <assert test="./@iso-8601-date" role="error" id="err-elem-cit-web-11-2-1">[err-elem-cit-web-11-2-1]
        The &lt;date-in-citation&gt; element must have an @iso-8601-date attribute.
        Reference '<value-of select="ancestor::ref/@id"/>' does not.
      </assert>
      
      <assert test="matches(./@iso-8601-date,'^\d{4}-\d{2}-\d{2}$')" role="error" id="err-elem-cit-web-11-2-2">[err-elem-cit-web-11-2-2]
        The &lt;date-in-citation&gt; element's @iso-8601-date attribute must have the format
        'YYYY-MM-DD'.
        Reference '<value-of select="ancestor::ref/@id"/>' has '<value-of select="@iso-8601-date"/>',
        which does not have that format.
      </assert>
      
      <assert test="matches(normalize-space(.),'^(January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2}, \d{4}')" role="error" id="err-elem-cit-web-11-3">[err-elem-cit-web-11-3]
        The format of the element content must match month, space, day, comma, year.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="."/>.</assert>
      
      <assert test="(matches(@iso-8601-date,replace($date-regex,'\p{Zs}','')))" role="error" id="err-elem-cit-web-11-5">[err-elem-cit-web-11-5] 
        The @iso-8601-date value on accessed date must be a valid date value. <value-of select="@iso-8601-date"/> in reference '<value-of select="ancestor::ref/@id"/>' is not valid.</assert>
      
      <report test="if (matches(@iso-8601-date,replace($date-regex,'\p{Zs}',''))) then format-date(xs:date(@iso-8601-date), '[MNn] [D], [Y]')!=.         else ()" role="error" id="err-elem-cit-web-11-4">[err-elem-cit-web-11-4] 
        The Accessed date value must match the @iso-8601-date value in the format 'January 1, 2020'.
        Reference '<value-of select="ancestor::ref/@id"/>' has element content of 
        <value-of select="."/> but an @iso-8601-date value of 
        <value-of select="@iso-8601-date"/>.</report>
      
    </rule></pattern>
  
  <pattern id="elem-citation-report-pattern"><rule context="element-citation[@publication-type='report']" id="elem-citation-report">
      <let name="publisher-locations" value="'publisher-locations.xml'"/> 
      
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-2-1" test="count(person-group)=1" role="error" id="err-elem-cit-report-2-1">[err-elem-cit-report-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-9-1" test="count(source)=1" role="error" id="err-elem-cit-report-9-1">[err-elem-cit-report-9-1] [err-elem-report-report-9-1]
        Each  &lt;element-citation&gt; of type 'report' must contain one and
        only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-11-1" test="count(publisher-name)=1" role="error" id="err-elem-cit-report-11-1">[err-elem-cit-report-11-1]
        &lt;publisher-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/>
        &lt;publisher-name&gt; elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#warning-elem-cit-report-11-3" test="some $p in document($publisher-locations)/locations/location/text()         satisfies ends-with(publisher-name[1],$p)" role="warning" id="warning-elem-cit-report-11-3">[warning-elem-cit-report-11-3]
        The content of &lt;publisher-name&gt; may not end with a publisher location. 
        Reference '<value-of select="ancestor::ref/@id"/>' contains the string <value-of select="publisher-name"/>,
        which ends with a publisher location.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-15" test="count(*) = count(person-group| year| source| publisher-loc|publisher-name| ext-link| pub-id)" role="error" id="err-elem-cit-report-15">[err-elem-cit-report-15]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="report" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-14" test="ext-link and pub-id[@pub-id-type='doi']" role="error" id="err-elem-cit-report-14">[err-elem-cit-report-14] Report reference cannot have both a doi and a URL. Reference '<value-of select="ancestor::ref/@id"/>' has a doi (<value-of select="pub-id[@pub-id-type='doi']"/>) and a URL (<value-of select="ext-link"/>).</report>
      
    </rule></pattern><pattern id="elem-citation-report-preson-group-pattern"><rule context="element-citation[@publication-type='report']/person-group" id="elem-citation-report-preson-group">
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-2-2" test="@person-group-type='author'" role="error" id="err-elem-cit-report-2-2">[err-elem-cit-report-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
    </rule></pattern><pattern id="elem-citation-report-source-pattern"><rule context="element-citation[@publication-type='report']/source" id="elem-citation-report-source">
      
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-9-2-2" test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-report-9-2-2">[err-elem-cit-report-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'report' may only contain the child 
        elements: &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
    </rule></pattern><pattern id="elem-citation-report-publisher-name-pattern"><rule context="element-citation[@publication-type='report']/publisher-name" id="elem-citation-report-publisher-name">
      
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-11-2" test="count(*)=0" role="error" id="err-elem-cit-report-11-2">[err-elem-cit-report-11-2]
        No elements are allowed inside &lt;publisher-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-name&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-report-pub-id-pattern"><rule context="element-citation[@publication-type='report']/pub-id" id="elem-citation-report-pub-id">
      
      <assert see="https://elifeproduction.slab.com/posts/report-references-fzbgnm2d#err-elem-cit-report-12-2" test="@pub-id-type='doi' or @pub-id-type='isbn'" role="error" id="err-elem-cit-report-12-2">[err-elem-cit-report-12-2]
        The only allowed pub-id types are 'doi' and 'isbn'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-confproc-pattern"><rule context="element-citation[@publication-type='confproc']" id="elem-citation-confproc"> 
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hxnwn-err-elem-cit-confproc-2-1" test="count(person-group)=1" role="error" id="err-elem-cit-confproc-2-1">[err-elem-cit-confproc-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#h2qee-err-elem-cit-confproc-8-1" test="count(article-title)=1" role="error" id="err-elem-cit-confproc-8-1">[err-elem-cit-confproc-8-1]
        Each  &lt;element-citation&gt; of type 'confproc' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hlxi8-err-elem-cit-confproc-10-1" test="count(conf-name)=1" role="error" id="err-elem-cit-confproc-10-1">[err-elem-cit-confproc-10-1]
        &lt;conf-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(conf-name)"/>
        &lt;conf-name&gt; elements.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hgdyn-err-elem-cit-confproc-12-1" test="(fpage and elocation-id) or (lpage and elocation-id)" role="error" id="err-elem-cit-confproc-12-1">[err-elem-cit-confproc-12-1]
        The citation may contain &lt;fpage&gt; and &lt;lpage&gt;, only &lt;fpage&gt;, or only &lt;elocation-id&gt; elements, but not a mixture.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#h5jtw-err-elem-cit-confproc-12-2" test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1" role="error" id="err-elem-cit-confproc-12-2">[err-elem-cit-confproc-12-2]
        The citation may contain no more than one of any of &lt;fpage&gt;, &lt;lpage&gt;, and &lt;elocation-id&gt; elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hjoa6-err-elem-cit-confproc-12-3" test="(lpage and fpage) and (number(replace(fpage[1],'[^\d]','')) ge number(replace(lpage[1],'[^\d]','')))" role="error" id="err-elem-cit-confproc-12-3">[err-elem-cit-confproc-12-3]
        If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is 
        less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hyk2a-err-elem-cit-confproc-12-4" test="count(fpage/*)=0 and count(lpage/*)=0" role="error" id="err-elem-cit-confproc-12-4">[err-elem-cit-confproc-12-4]
        The content of the &lt;fpage&gt; and &lt;lpage&gt; elements can contain any alpha numeric value but no child elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage/*)"/> child elements in
        &lt;fpage&gt; and  <value-of select="count(lpage/*)"/> child elements in &lt;lpage&gt;.</assert>     
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hm9rv-err-elem-cit-confproc-16-1" test="count(pub-id) le 1" role="error" id="err-elem-cit-confproc-16-1">[err-elem-cit-confproc-16-1]
        A maximum of one &lt;pub-id&gt; element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/>
        &lt;pub-id&gt; elements.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#h08e2-err-elem-cit-confproc-17" test="count(*) = count(person-group | article-title | year | conf-loc | conf-name | lpage |         fpage | elocation-id | ext-link | pub-id)" role="error" id="err-elem-cit-confproc-17">[err-elem-cit-confproc-17] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="confproc" are: &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;conf-loc&gt;, &lt;conf-name&gt;, &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-confproc-preson-group-pattern"><rule context="element-citation[@publication-type='confproc']/person-group" id="elem-citation-confproc-preson-group">
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hslvg-err-elem-cit-confproc-2-2" test="@person-group-type='author'" role="error" id="err-elem-cit-confproc-2-2">[err-elem-cit-confproc-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
    </rule></pattern><pattern id="elem-citation-confproc-article-title-pattern"><rule context="element-citation[@publication-type='confproc']/article-title" id="elem-citation-confproc-article-title">
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hubhw-err-elem-cit-confproc-8-2" test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-confproc-8-2">[err-elem-cit-confproc-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule></pattern><pattern id="elem-citation-confproc-conf-name-pattern"><rule context="element-citation[@publication-type='confproc']/conf-name" id="elem-citation-confproc-conf-name">
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hwknk-err-elem-cit-confproc-10-2" test="count(*)=0" role="error" id="err-elem-cit-confproc-10-2">[err-elem-cit-confproc-10-2]
        No elements are allowed inside &lt;conf-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;conf-name&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-confproc-conf-loc-pattern"><rule context="element-citation[@publication-type='confproc']/conf-loc" id="elem-citation-confproc-conf-loc">
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hiuzp-err-elem-cit-confproc-11-2" test="count(*)=0" role="error" id="err-elem-cit-confproc-11-2">[err-elem-cit-confproc-11-2]
        No elements are allowed inside &lt;conf-loc&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;conf-loc&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-confproc-fpage-pattern"><rule context="element-citation[@publication-type='confproc']/fpage" id="elem-citation-confproc-fpage">
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hxcbf-err-elem-cit-confproc-12-5" test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage[1]),1,1) = substring(normalize-space(.),1,1))" role="error" id="err-elem-cit-confproc-12-5">[err-elem-cit-confproc-12-5]
        If the content of &lt;fpage&gt; begins with a letter, then the content of &lt;lpage&gt; must begin with 
        the same letter. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt;='<value-of select="."/>'
        and &lt;lpage&gt;='<value-of select="../lpage"/>'.</assert>
      
    </rule></pattern><pattern id="elem-citation-confproc-pub-id-pattern"><rule context="element-citation[@publication-type='confproc']/pub-id" id="elem-citation-confproc-pub-id">
      
      <assert see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#hzrg2-err-elem-cit-confproc-16-2" test="@pub-id-type='doi' or @pub-id-type='pmid'" role="error" id="err-elem-cit-confproc-16-2">[err-elem-cit-confproc-16-2]
        The only allowed pub-id types are 'doi' or 'pmid'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule></pattern>
  
  <pattern id="elem-citation-thesis-pattern"><rule context="element-citation[@publication-type='thesis']" id="elem-citation-thesis"> 
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-thesis-2-1">[err-elem-cit-thesis-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(descendant::collab)=0" role="error" id="err-elem-cit-thesis-3">[err-elem-cit-thesis-3]
        No &lt;collab&gt; elements are allowed in thesis citations.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(collab)"/> &lt;collab&gt; elements.</assert>
      
      <assert test="count(descendant::etal)=0" role="error" id="err-elem-cit-thesis-6">[err-elem-cit-thesis-6]
        No &lt;etal&gt; elements are allowed in thesis citations.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(etal)"/> &lt;etal&gt; elements.</assert>
      
      <assert test="count(article-title)=1" role="error" id="err-elem-cit-thesis-8-1">[err-elem-cit-thesis-8-1]
        Each  &lt;element-citation&gt; of type 'thesis' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(publisher-name)=1" role="error" id="err-elem-cit-thesis-9-1">[err-elem-cit-thesis-9-1]
        &lt;publisher-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/>
        &lt;publisher-name&gt; elements.</assert>
      
      <assert test="count(pub-id) le 1" role="error" id="err-elem-cit-thesis-11-1">[err-elem-cit-thesis-11-1]
        A maximum of one &lt;pub-id&gt; element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/>
        &lt;pub-id&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group | article-title | year| source | publisher-loc | publisher-name | ext-link | pub-id)" role="error" id="err-elem-cit-thesis-13">[err-elem-cit-thesis-13]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="thesis" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, 
        &lt;ext-link&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule></pattern><pattern id="elem-citation-thesis-preson-group-pattern"><rule context="element-citation[@publication-type='thesis']/person-group" id="elem-citation-thesis-preson-group">
      
      <assert test="@person-group-type='author'" role="error" id="err-elem-cit-thesis-2-2">[err-elem-cit-thesis-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
      
      <assert test="count(name)=1" role="error" id="err-elem-cit-thesis-2-3">[err-elem-cit-thesis-2-3]
        Each thesis citation must have one and only one author.
        Reference '<value-of select="ancestor::ref/@id"/>' has a thesis citation 
        with <value-of select="count(name)"/> authors.</assert>
    </rule></pattern><pattern id="elem-citation-thesis-article-title-pattern"><rule context="element-citation[@publication-type='thesis']/article-title" id="elem-citation-thesis-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-thesis-8-2">[err-elem-cit-thesis-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule></pattern><pattern id="elem-citation-thesis-publisher-name-pattern"><rule context="element-citation[@publication-type='thesis']/publisher-name" id="elem-citation-thesis-publisher-name">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-thesis-9-2">[err-elem-cit-thesis-9-2]
        No elements are allowed inside &lt;publisher-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-name&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-thesis-publisher-loc-pattern"><rule context="element-citation[@publication-type='thesis']/publisher-loc" id="elem-citation-thesis-publisher-loc">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-thesis-10-2">[err-elem-cit-thesis-10-2]
        No elements are allowed inside &lt;publisher-loc&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-loc&gt; element.</assert>
      
    </rule></pattern><pattern id="elem-citation-thesis-pub-id-pattern"><rule context="element-citation[@publication-type='thesis']/pub-id" id="elem-citation-thesis-pub-id">
      
      <assert test="@pub-id-type='doi'" role="error" id="err-elem-cit-thesis-11-2">[err-elem-cit-thesis-11-2]
        The only allowed pub-id type is 'doi'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule></pattern>
  
  <pattern id="gen-das-tests-pattern"><rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']" id="gen-das-tests">
      <let name="pos" value="count(ancestor::sec[@sec-type='data-availability']//element-citation[@publication-type='data']) - count(following::element-citation[@publication-type='data' and ancestor::sec[@sec-type='data-availability']])"/> 
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-person-group-1" test="count(person-group[@person-group-type='author'])=1" role="error" id="final-das-elem-person-group-1">[final-das-elem-person-group-1] The reference in position <value-of select="$pos"/> of the data availability section does not have any authors (no person-group[@person-group-type='author']). Please ensure to add them.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-elem-person-group-2" test="count(person-group) gt 1" role="error" id="das-elem-person-group-2">[das-elem-person-group-2] The reference in position <value-of select="$pos"/> of the data availability has <value-of select="count(person-group)"/> person-group elements, which is incorrect.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-person-1" test="(count(person-group[@person-group-type='author']/name)=0) and (count(person-group[@person-group-type='author']/collab)=0)" role="error" id="final-das-elem-person-1">[final-das-elem-person-1] The reference in position <value-of select="$pos"/> of the data availability section does not have any authors (person-group[@person-group-type='author']). Please ensure to add them in.</report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-data-title-1" test="count(data-title)=1" role="error" id="final-das-elem-data-title-1">[final-das-elem-data-title-1] The reference in position <value-of select="$pos"/> of the data availability section does not have a title (no data-title). Please ensure to add it in.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-source-1" test="count(source)=1" role="error" id="final-das-elem-source-1">[final-das-elem-source-1] The reference in position <value-of select="$pos"/> of the data availability section does not have a database name (no source). Please ensure to add it in.</assert>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-pub-id-1" test="count(pub-id)=1" role="error" id="final-das-elem-pub-id-1">[final-das-elem-pub-id-1] The reference in position <value-of select="$pos"/> of the data availability section does not have an identifier (no pub-id). Please ensure to add it in.</assert>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-pub-id-2" test="normalize-space(pub-id)=''" role="error" id="final-das-elem-pub-id-2">[final-das-elem-pub-id-2] The reference in position <value-of select="$pos"/> of the data availability section does not have an id (pub-id is empty). Please ensure to add it in.</report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-year-1" test="count(year)=1" role="error" id="final-das-elem-year-1">[final-das-elem-year-1] The reference in position <value-of select="$pos"/> of the data availability section does not have a year. Please ensure to add it in.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-elem-cit-1" test="@specific-use" role="error" id="das-elem-cit-1">[das-elem-cit-1] Every reference in the data availability section must have an @specific-use. The reference in position <value-of select="$pos"/> does not.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-elem-cit-2" test="@specific-use and not(@specific-use=('isSupplementedBy','references'))" role="error" id="das-elem-cit-2">[das-elem-cit-2] The reference in position <value-of select="$pos"/> of the data availability section has a @specific-use value of <value-of select="@specific-use"/>, which is not allowed. It must be 'isSupplementedBy' or 'references'.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-cit-3" test="pub-id[1]/@xlink:href = preceding::element-citation[(@publication-type='data') and ancestor::sec[@sec-type='data-availability']]/pub-id[1]/@xlink:href" role="error" id="final-das-elem-cit-3">[final-das-elem-cit-3] The reference in position <value-of select="$pos"/> of the data availability section has a link (<value-of select="pub-id[1]/@xlink:href"/>) which is the same as another dataset reference in that section. Dataset reference links should be distinct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-elem-cit-4" test="pub-id[1] = preceding::element-citation[(@publication-type='data') and ancestor::sec[@sec-type='data-availability']]/pub-id[1]" role="warning" id="das-elem-cit-4">[das-elem-cit-4] The reference in position <value-of select="$pos"/> of the data availability section has a pub-id (<value-of select="pub-id[1]"/>) which is the same as another dataset reference in that section. This is very likely incorrect. Dataset reference pub-id should be distinct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-elem-cit-5" test="pub-id[1] = following::element-citation[ancestor::ref-list]/pub-id[1]" role="warning" id="das-elem-cit-5">[das-elem-cit-5] The reference in position <value-of select="$pos"/> of the data availability section has a pub-id (<value-of select="pub-id[1]"/>) which is the same as in another reference in the reference list. Is the same reference in both the reference list and data availability section?</report>
      
      <report test="pub-id and ext-link" role="error" id="das-elem-cit-6">[das-elem-cit-6] The reference in position <value-of select="$pos"/> of the data availability section has both a pub-id (<value-of select="pub-id[1]"/>) and an ext-link (<value-of select="ext-link[1]"/>), which is not allowed.</report>
      
    </rule></pattern><pattern id="das-elem-citation-data-pub-id-pattern"><rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']/pub-id" id="das-elem-citation-data-pub-id">
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-pub-id-1" test="normalize-space(.)!='' and not(@pub-id-type=('accession', 'doi'))" role="error" id="final-das-pub-id-1">[final-das-pub-id-1] Each pub-id element must have an @pub-id-type which is either accession or doi.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-pub-id-2" test="@pub-id-type!='doi' and normalize-space(.)!='' and (not(@xlink:href) or (normalize-space(@xlink:href)=''))" role="error" id="final-das-pub-id-2">[final-das-pub-id-2] Each pub-id element which is not a doi must have an @xlink-href (which is not empty).</report>
      
      <report test="@pub-id-type='doi' and (@xlink:href)" role="error" id="das-pub-id-3">[das-pub-id-3] A pub-id with the type doi does not need an xlink:href attribute. <value-of select="concat('xlink:href=&quot;',.,'&quot;')"/> should be removed from the pub-id containing <value-of select="."/>.</report>
    </rule></pattern><pattern id="das-elem-citation-children-pattern"><rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']/source/*|sec[@sec-type='data-availability']//element-citation[@publication-type='data']/data-title/*" id="das-elem-citation-children">
      <let name="allowed-elems" value="('sup','sub','italic')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-elem-citation-child-1" test="name()=$allowed-elems" role="error" id="das-elem-citation-child-1">[das-elem-citation-child-1] Reference in the data availability section has a <value-of select="name()"/> element in a <value-of select="parent::*/name()"/> element which is not allowed.</assert>
    </rule></pattern><pattern id="das-elem-citation-year-tests-pattern"><rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']/year" id="das-elem-citation-year-tests">
      <let name="digits" value="replace(.,'[^\d]','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-elem-citation-year-1" test="(.!='') and (@iso-8601-date!=$digits)" role="error" id="das-elem-citation-year-1">[das-elem-citation-year-1] Every year in a reference must have an @iso-8601-date attribute equal to the numbers in the year. Reference with id <value-of select="parent::*/@id"/> has a year '<value-of select="."/>' but an @iso-8601-date '<value-of select="@iso-8601-date"/>'.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-elem-citation-year-2" test="normalize-space(.)=''" role="error" id="final-das-elem-citation-year-2">[final-das-elem-citation-year-2] Reference with id <value-of select="parent::*/@id"/> has an empty year. Please ensure to add it in.</report>
    </rule></pattern>
  
  <pattern id="pub-id-tests-pattern"><rule context="element-citation/pub-id" id="pub-id-tests">
      
      
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#final-pub-id-test-1" test="(@xlink:href) and not(matches(@xlink:href,'^http[s]?://|^s?ftp://'))" role="error" id="final-pub-id-test-1">[final-pub-id-test-1] @xlink:href must start with an http:// or ftp:// protocol. - <value-of select="@xlink:href"/> does not.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#final-pub-id-test-2" test="(@pub-id-type='doi') and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9%&lt;&gt;\[\]]+$'))" role="error" id="final-pub-id-test-2">[final-pub-id-test-2] pub-id is tagged as a doi, but it is not one - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#pub-id-test-3" test="(@pub-id-type='pmid') and not(matches(.,'^\d{3,10}$'))" role="error" id="pub-id-test-3">[pub-id-test-3] pub-id is tagged as a pmid, but it is not a number made up of between 3 and 10 digits - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#pub-id-doi-test-1" test="(@pub-id-type != 'doi') and matches(@xlink:href,'https?://(dx.doi.org|doi.org)/')" role="error" id="pub-id-doi-test-1">[pub-id-doi-test-1] pub-id has a doi link - <value-of select="@xlink:href"/> - but its pub-id-type is <value-of select="@pub-id-type"/> instead of doi.</report>
      
      <!-- This is not needed 
        <report test="matches(@xlink:href,'https?://(dx.doi.org|doi.org)/') and not(contains(.,substring-after(@xlink:href,'doi.org/')))" 
        role="error" 
        id="pub-id-doi-test-2">pub id has a doi link - <value-of select="@xlink:href"/> - but the identifier is not the doi - '<value-of select="."/>', which is incorrect. Either the doi link is correct, and the identifier needs changing, or the identifier is correct and needs adding after 'https://doi.org/' in order to create the real doi link.</report>-->
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#pub-id-test-4" test="contains(.,' ')" role="warning" id="pub-id-test-4">[pub-id-test-4] pub id contains whitespace - <value-of select="."/> - which is very likely to be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#pub-id-test-5" test="ends-with(.,'.')" role="error" id="pub-id-test-5">[pub-id-test-5] <value-of select="@pub-id-type"/> pub-id ends with a full stop - <value-of select="."/> - which is not correct. Please remove the full stop.</report>
      
      <report test="matches(.,'\p{Zs}$')" role="error" id="pub-id-test-6">[pub-id-test-6] <value-of select="@pub-id-type"/> pub-id ends with space(s) which is incorrect - '<value-of select="."/>'.</report>
      
      <report test="preceding-sibling::pub-id/@pub-id-type = @pub-id-type" role="error" id="indistinct-pub-ids">[indistinct-pub-ids] element-citation for <value-of select="e:citation-format1(parent::element-citation)"/> has more than one pub-id with the type <value-of select="@pub-id-type"/>, which cannot be correct - <value-of select="."/>.</report>
      
    </rule></pattern><pattern id="pub-id-xlink-href-tests-pattern"><rule context="pub-id[@xlink:href]" id="pub-id-xlink-href-tests">
      
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;//=]*)$|^ftp://.')" role="warning" id="pub-id-url-conformance-test">[pub-id-url-conformance-test] @xlink:href doesn't look like a URL - '<value-of select="@xlink:href"/>'. Is this correct?</assert>
      
      <report test="matches(@xlink:href,'^(ftp|sftp)://\S+:\S+@')" role="warning" id="ftp-credentials-flag-2">[ftp-credentials-flag-2] @xlink:href contains what looks like a link to an FTP site which contains credentials (username and password) - '<value-of select="@xlink:href"/>'. If the link without credentials works (<value-of select="concat(substring-before(@xlink:href,'://'),'://',substring-after(@xlink:href,'@'))"/>), then please replace it with that and notify the authors that you have done so. If the link without credentials does not work, please query with the authors in order to obtain a link without credentials.</report>
      
      <report test="matches(@xlink:href,'\.$')" role="error" id="pub-id-url-fullstop-report">[pub-id-url-fullstop-report] '<value-of select="@xlink:href"/>' - Link ends in a full stop which is incorrect.</report>
      
      <report test="matches(@xlink:href,'[\p{Zs}]')" role="error" id="pub-id-url-space-report">[pub-id-url-space-report] '<value-of select="@xlink:href"/>' - Link contains a space which is incorrect.</report>
      
    </rule></pattern>
  
 <pattern id="feature-title-tests-pattern"><rule context="article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]//title-group/article-title" id="feature-title-tests">
     <let name="sub-disp-channel" value="ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject[1]"/>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-title-test-1" test="(count(ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject) = 1) and starts-with(.,$sub-disp-channel)" role="error" id="feature-title-test-1">[feature-title-test-1] title starts with the sub-display-channel. This is certainly incorrect.</report>
     
   </rule></pattern><pattern id="feature-abstract-tests-pattern"><rule context="front//abstract[@abstract-type=('executive-summary','plain-language-summary')]" id="feature-abstract-tests">
     
     <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#feature-abstract-test-1" test="count(title) = 1" role="error" id="feature-abstract-test-1">[feature-abstract-test-1] abstract must contain one and only one title.</assert>
     
     <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#feature-abstract-test-2" test="title = 'eLife digest'" role="error" id="feature-abstract-test-2">[feature-abstract-test-2] abstract title must contain 'eLife digest'. Possible superfluous characters - <value-of select="replace(title,'eLife digest','')"/></assert>
     
   </rule></pattern><pattern id="digest-tests-pattern"><rule context="front//abstract[@abstract-type=('executive-summary','plain-language-summary')]/p" id="digest-tests">
     
     <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#digest-test-1" test="matches(.,'^\p{Ll}')" role="warning" id="digest-test-1">[digest-test-1] digest paragraph starts with a lowercase letter. Is that correct? Or has a paragraph been incorrectly split into two?</report>
     
     <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-digest-test-2" test="matches(.,'\[[Oo][Kk]\??\]')" role="error" id="final-digest-test-2">[final-digest-test-2] digest paragraph contains [OK] or [OK?] which should be removed - <value-of select="."/></report>
     
     <report test="matches(.,'\[[Qq][Uu][Ee][Rr][Yy]')" role="error" id="final-digest-query-test">[final-digest-query-test] <value-of select="name()"/> element contains [Query] or [QUERY] which should be removed - <value-of select="."/></report>
     
   </rule></pattern><pattern id="feature-subj-tests-pattern"><rule context="subj-group[@subj-group-type='sub-display-channel']/subject" id="feature-subj-tests">		
     <let name="token1" value="substring-before(.,' ')"/>
     <let name="token2" value="substring-after(.,$token1)"/>
		
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-subj-test-2" test=". != e:titleCase(.)" role="error" id="feature-subj-test-2">[feature-subj-test-2] The content of the sub-display-channel should be in title case - <value-of select="e:titleCase(.)"/></report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-subj-test-3" test="ends-with(.,':')" role="error" id="feature-subj-test-3">[feature-subj-test-3] sub-display-channel ends with a colon. This is incorrect.</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-subj-test-4" test="preceding-sibling::subject" role="error" id="feature-subj-test-4">[feature-subj-test-4] There is more than one sub-display-channel subject. This is incorrect.</report>
		
	</rule></pattern><pattern id="feature-article-category-tests-pattern"><rule context="article-categories[subj-group[@subj-group-type='display-channel']/subject = $features-subj]" id="feature-article-category-tests">
     <let name="count" value="count(subj-group[@subj-group-type='sub-display-channel'])"/>
     
     <assert see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-article-category-test-1" test="$count = 1" role="error" id="feature-article-category-test-1">[feature-article-category-test-1] article categories for <value-of select="subj-group[@subj-group-type='display-channel']/subject"/>s must contain one, and only one, subj-group[@subj-group-type='sub-display-channel']</assert>
     
   </rule></pattern><pattern id="feature-author-tests-pattern"><rule context="article//article-meta[article-categories//subj-group[@subj-group-type='display-channel']/subject=$features-subj]//contrib[@contrib-type='author']" id="feature-author-tests">
     
     <assert see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-author-test-1" test="collab or ancestor::collab or bio" role="error" id="feature-author-test-1">[feature-author-test-1] Author must contain child bio in feature content.</assert>
   </rule></pattern><pattern id="feature-bio-tests-pattern"><rule context="article//article-meta[article-categories//subj-group[@subj-group-type='display-channel']/subject=$features-subj]//contrib[@contrib-type='author']/bio" id="feature-bio-tests">
     <let name="name" value="e:get-name(parent::contrib/name[1])"/>
     <let name="xref-rid" value="parent::contrib/xref[@ref-type='aff']/@rid"/>
     <let name="aff" value="if (parent::contrib/aff) then parent::contrib/aff[1]/institution[not(@content-type)][1]/normalize-space(.)        else ancestor::contrib-group/aff[@id/string() = $xref-rid]/institution[not(@content-type)][1]/normalize-space(.)"/>
     <let name="aff-tokens" value="for $y in $aff return tokenize($y,', ')"/>
     
     <assert see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-bio-test-1" test="p[1]/bold = $name" role="error" id="feature-bio-test-1">[feature-bio-test-1] bio must contain a bold element that contains the name of the author - <value-of select="$name"/>.</assert>
     
     <!-- Needs to account for authors with two or more affs-->
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-bio-test-2" test="if (count($aff) &gt; 1) then ()        else not(contains(.,$aff))" role="warning" id="feature-bio-test-2">[feature-bio-test-2] bio does not contain the institution text as it appears in their affiliation ('<value-of select="$aff"/>'). Is this correct?</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-bio-test-6" test="(count($aff) &gt; 1) and (some $x in $aff-tokens satisfies not(contains(.,$x)))" role="warning" id="feature-bio-test-6">[feature-bio-test-6] Some of the text from <value-of select="$name"/>'s affiliations does not appear in their bio - <value-of select="string-join(for $x in $aff-tokens return if (contains(.,$x)) then () else concat('&quot;',$x,'&quot;'),' and ')"/>. Is this correct?</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-bio-test-3" test="matches(p[1],'\.$')" role="error" id="feature-bio-test-3">[feature-bio-test-3] bio cannot end  with a full stop - '<value-of select="p[1]"/>'.</report>
     
     <assert see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-bio-test-4" test="(count(p) = 1)" role="error" id="feature-bio-test-4">[feature-bio-test-4] One and only 1 &lt;p&gt; is allowed as a child of bio. <value-of select="."/></assert>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-bio-test-5" test="*[local-name()!='p']" role="error" id="feature-bio-test-5">[feature-bio-test-5] <value-of select="*[local-name()!='p'][1]/local-name()"/> is not allowed as a child of &lt;bio&gt;. - <value-of select="."/></report>
   </rule></pattern><pattern id="feature-template-tests-pattern"><rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]" id="feature-template-tests">
     <let name="template" value="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
     <let name="type" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-1" test="($template = ('1','2','3')) and child::sub-article" role="error" flag="dl-ar" id="feature-template-test-1">[feature-template-test-1] <value-of select="$type"/> is a template <value-of select="$template"/> but it has a decision letter or author response, which cannot be correct, as only template 5s are allowed these.</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-2" test="($template = '5') and not(@article-type='research-article')" role="error" flag="dl-ar" id="feature-template-test-2">[feature-template-test-2] <value-of select="$type"/> is a template <value-of select="$template"/> so the article element must have a @article-type="research-article". Instead the @article-type="<value-of select="@article-type"/>".</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-3" test="($template = '5') and not(child::sub-article[@article-type='decision-letter'])" role="warning" id="feature-template-test-3">[feature-template-test-3] <value-of select="$type"/> is a template <value-of select="$template"/> but it does not (currently) have a decision letter. Is that OK?</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-4" test="($template = '5') and not(child::sub-article[@article-type='reply'])" role="warning" id="feature-template-test-4">[feature-template-test-4] <value-of select="$type"/> is a template <value-of select="$template"/> but it does not (currently) have an author response. Is that OK?</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-templates-no-bre" test="front/article-meta/contrib-group[@content-type='section'] and ($template != '5')" role="error" id="feature-templates-no-bre">[feature-templates-no-bre] <value-of select="$type"/> is a template <value-of select="$template"/>, which means that it should not have any BREs. This <value-of select="$type"/> has <value-of select="           string-join(           for $x in front/article-meta/contrib-group[@content-type='section']/contrib           return concat(e:get-name($x/name[1]),' as ',$x/role[1])           ,           ' and '           )           "/>. Please remove any senior/reviewing editors.</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-templates-author-cont" test="back/fn-group[@content-type='author-contribution'] and $template = '1'" role="error" id="feature-templates-author-cont">[feature-templates-author-cont] <value-of select="$type"/> articles should not have any Author contributions. This <value-of select="$type"/> has <value-of select="           string-join(for $x in back/fn-group[@content-type='author-contribution']/fn           return concat('&quot;', $x,'&quot;')           ,           '; '           )           "/>. Please remove the author contributions.</report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-templates-author-cont" test="back/fn-group[@content-type='author-contribution'] and $template = '2'" role="warning" id="feature-templates-author-cont-3">[feature-templates-author-cont-3] <value-of select="$type"/> articles should not usually have any Author contributions. This <value-of select="$type"/> has <value-of select="          string-join(for $x in back/fn-group[@content-type='author-contribution']/fn          return concat('&quot;', $x,'&quot;')          ,          '; '          )          "/>. Are they required?</report>
     
     
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#final-feature-templates-author-cont-2" test="$template = ('3','4') and not(back/fn-group[@content-type='author-contribution'])" role="error" id="final-feature-templates-author-cont-2">[final-feature-templates-author-cont-2] <value-of select="$type"/>s should have Author contributions. This one does not. Exeter please check with the Production team who will check with the Features team.</report>
   </rule></pattern><pattern id="insight-asbtract-tests-pattern"><rule context="article[@article-type='article-commentary']//article-meta/abstract" id="insight-asbtract-tests">
     <let name="impact-statement" value="parent::article-meta//custom-meta[meta-name='Author impact statement']/meta-value[1]"/>
     <let name="impact-statement-element-count" value="count(parent::article-meta//custom-meta[meta-name='Author impact statement']/meta-value[1]/*)"/>
     
     <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#insight-abstract-impact-test-1" test=". = $impact-statement" role="warning" id="insight-abstract-impact-test-1">[insight-abstract-impact-test-1] In insights, abstracts must be the same as impact statements. Here the abstract reads "<value-of select="."/>", whereas the impact statement reads "<value-of select="$impact-statement"/>".</assert>
     
     <assert see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#insight-abstract-impact-test-2" test="count(p/*) = $impact-statement-element-count" role="warning" id="insight-abstract-impact-test-2">[insight-abstract-impact-test-2] In insights, abstracts must be the same as impact statements. Here the abstract has <value-of select="count(*)"/> child element(s), whereas the impact statement has <value-of select="$impact-statement-element-count"/> child element(s). Check for possible missing formatting.</assert>
     
   </rule></pattern><pattern id="insight-related-article-tests-pattern"><rule context="article[@article-type='article-commentary']//article-meta/related-article" id="insight-related-article-tests">
     <let name="doi" value="@xlink:href"/>
     <let name="text" value="replace(ancestor::article/body/boxed-text[1],' ',' ')"/>
     <let name="citation" value="for $x in ancestor::article//ref-list//element-citation[pub-id[@pub-id-type='doi']=$doi][1]        return replace(concat(        string-join(        for $y in $x/person-group[@person-group-type='author']/*        return if ($y/name()='name') then concat($y/surname,' ', $y/given-names)        else $y        ,', '),        '. ',        replace($x/year,'[^\d]',''),        '. ',        $x/article-title,        '. eLife ',        $x/volume,        ':',        $x/elocation-id,        '. doi: ',        $x/pub-id[@pub-id-type='doi']),' ',' ')"/>
     
     <assert see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#insight-box-test-1" test="contains($text,$citation)" role="warning" id="insight-box-test-1">[insight-box-test-1] A citation for related article <value-of select="$doi"/> is not included in the related-article box text in the body of the article. '<value-of select="$citation"/>' is not present (or is different to the relevant passage) in '<value-of select="$text"/>'. The following word(s) are in the boxed text but not in the citation: <value-of select="string-join(e:insight-box($text,$citation)//*:item[@type='cite'],'; ')"/>. The following word(s) are in the citation but not in the boxed text: <value-of select="string-join(e:insight-box($text,$citation)//*:item[@type='box'],'; ')"/>.</assert>
     
     <assert see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#insight-related-article-test-1" test="@related-article-type='commentary-article'" role="error" id="insight-related-article-test-1">[insight-related-article-test-1] Insight related article links must have the related-article-type 'commentary-article'. The link for <value-of select="$doi"/> has '<value-of select="@related-article-type"/>'.</assert>
     
     <report test="@related-article-type='commentary-article' and not(ancestor::article//ref-list/ref//pub-id[@pub-id-type]=$doi)" role="error" id="insight-related-article-test-2">[insight-related-article-test-2] This Insight is related to <value-of select="$doi"/>, but there is no reference in the ref-list with that doi.</report>
   </rule></pattern><pattern id="feature-comment-tests-pattern"><rule context="article[descendant::article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]]//p|      article[descendant::article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]]//td|      article[descendant::article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]]//th" id="feature-comment-tests">
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#final-feat-ok-test" test="matches(.,'\[[Oo][Kk]\??\]')" role="error" id="final-feat-ok-test">[final-feat-ok-test] <value-of select="name()"/> element contains [OK] or [OK?] which should be removed - <value-of select="."/></report>
     
     <report see="https://elifeproduction.slab.com/posts/feature-content-alikl8qp#hb9uk-final-feat-query-test" test="matches(.,'\[[Qq][Uu][Ee][Rr][Yy]')" role="error" id="final-feat-query-test">[final-feat-query-test] <value-of select="name()"/> element contains [Query] or [QUERY] which should be removed - <value-of select="."/></report>
     
   </rule></pattern>
  
  <pattern id="correction-tests-pattern"><rule context="article[@article-type = 'correction']" id="correction-tests">
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hy53l-corr-aff-presence" test="descendant::article-meta//aff" role="error" id="corr-aff-presence">[corr-aff-presence] Correction notices should not contain affiliations.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hohvo-corr-coi-presence" test="descendant::fn-group[@content-type='competing-interest']" role="error" id="corr-COI-presence">[corr-COI-presence] Correction notices should not contain competing interests.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hrxuv-corr-self-uri-presence" test="descendant::self-uri" role="error" id="corr-self-uri-presence">[corr-self-uri-presence] Correction notices should not contain a self-uri element (as the PDF is not published).</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#corr-abstract-presence" test="descendant::abstract" role="error" id="corr-abstract-presence">[corr-abstract-presence] Correction notices should not contain abstracts.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hg8b8-corr-back-sec" test="(back/sec[not(@sec-type='supplementary-material')]) or (count(back/sec) gt 1)" role="error" id="corr-back-sec">[corr-back-sec] Correction notices should not contain any sections in the backmatter which are not for supplementary files.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hnc5o-corr-impact-statement" test="descendant::meta-name[text() = 'Author impact statement']" role="error" id="corr-impact-statement">[corr-impact-statement] Correction notices should not contain an impact statement.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hs0ll-corr-se-bre" test="descendant::contrib-group[@content-type='section']" role="error" id="corr-SE-BRE">[corr-SE-BRE] Correction notices must not contain any Senior or Reviewing Editors.</report>
      
    </rule></pattern><pattern id="retraction-tests-pattern"><rule context="article[@article-type = ('retraction','expression-of-concern')]" id="retraction-tests">
      <let name="display-subject" value="article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#h577w-retr-aff-presence" test="descendant::article-meta//aff" role="error" id="retr-aff-presence">[retr-aff-presence] <value-of select="$display-subject"/> notices should not contain affiliations.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#heu8l-retr-coi-presence" test="descendant::fn-group[@content-type='competing-interest']" role="error" id="retr-COI-presence">[retr-COI-presence] <value-of select="$display-subject"/> notices should not contain competing interests.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hmmm1-retr-self-uri-presence" test="descendant::self-uri" role="error" id="retr-self-uri-presence">[retr-self-uri-presence] <value-of select="$display-subject"/> notices should not contain a self-uri element (as the PDF is not published).</report>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#retr-abstract-presence" test="descendant::abstract" role="error" id="retr-abstract-presence">[retr-abstract-presence] <value-of select="$display-subject"/> notices should not contain abstracts.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hwi7f-retr-back" test="back/*" role="error" id="retr-back">[retr-back] <value-of select="$display-subject"/> notices should not contain any content in the back.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hgn3c-retr-impact-statement" test="descendant::meta-name[text() = 'Author impact statement']" role="error" id="retr-impact-statement">[retr-impact-statement] <value-of select="$display-subject"/> notices should not contain an impact statement.</report>
      
      <report see="https://elifeproduction.slab.com/posts/versioning-li6miptl#hqq70-retr-se-bre" test="descendant::contrib-group[@content-type='section']" role="error" id="retr-SE-BRE">[retr-SE-BRE] <value-of select="$display-subject"/> notices must not contain any Senior or Reviewing Editors.</report>
       
    </rule></pattern><pattern id="notice-body-tests-pattern"><rule context="article[@article-type = ('retraction','expression-of-concern','correction')]/body" id="notice-body-tests">
      <let name="display-subject" value="ancestor::article//article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>    

      <assert test="*[1]/name()='boxed-text'" role="error" id="notice-body-test-1">[notice-body-test-1] The first child element of body in a <value-of select="$display-subject"/> must be boxed-text. This one has <value-of select="*[1]/name()"/>.</assert>

    </rule></pattern><pattern id="notice-box-tests-pattern"><rule context="article[@article-type = ('retraction','expression-of-concern','correction')]/body/boxed-text[1]" id="notice-box-tests">
      <let name="display-subject" value="ancestor::article//article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="notice-title" value="ancestor::article[1]/descendant::article-meta[1]/descendant::article-title[1]"/>
      <let name="obj-title" value="substring-after($notice-title,': ')"/>   

      <assert test="count(p)=2" role="error" id="notice-box-1">[notice-box-1] The boxed-text at the start of a <value-of select="$display-subject"/> notice should contain 2 paragraphs. The first should contain the citation details for the related article. The second should state the fulld ate on which it was published. This boxed-text has <value-of select="count(p)"/> p elements.</assert>
      
      <report test="*/name()!='p'" role="error" id="notice-box-2">[notice-box-2] <name/> in boxed-text at the start of a <value-of select="$display-subject"/> notice is not allowed. Only p is permitted.</report>

      <assert test="contains(p[1],$obj-title)" role="error" id="notice-box-3">[notice-box-3] The first paragraph in boxed text at the start of this <value-of select="$display-subject"/> does not contain the title of the related article as written in the title of the notice. Related article title (from notice title) = '<value-of select="$obj-title"/>'. First boxed-text para = '<value-of select="p[1]"/>'</assert>
      
      <assert test="contains(p[1],'eLife')" role="error" id="notice-box-4">[notice-box-4] The first paragraph in boxed text at the start of a <value-of select="$display-subject"/> should contain the citation details for the related article, but this one does not contain the word 'eLife'.</assert>
      
      <assert test="matches(lower-case(p[1]),'10.7554/elife.\d{5,6}')" role="error" id="notice-box-5">[notice-box-5] The first paragraph in boxed text at the start of a <value-of select="$display-subject"/> should contain the citation details for the related article, but this one does not contain an eLife DOI.</assert>
      
      <assert test="matches(p[2],'^Published ([1-9]|[1-2][0-9]|3[0-1]) (January|February|March|April|May|June|July|August|September|October|November|December) 20([1][2-9]|[2][0-9])')" role="error" id="notice-box-6">[notice-box-6] The second paragraph in boxed text at the start of a <value-of select="$display-subject"/> should contain the full publication for the related article in the format 'Published 13 January 2022', but this one does not.</assert>
    </rule></pattern>
  
  <pattern id="gene-primer-sequence-pattern"><rule context="p[not(child::table-wrap)]" id="gene-primer-sequence">
      <let name="count" value="count(descendant::named-content[@content-type='sequence'])"/>
      <let name="text-tokens" value="for $x in tokenize(.,' ') return if (matches($x,'[ACGTacgt]{15,}')) then $x else ()"/>
      <let name="text-count" value="count($text-tokens)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hlpdc-gene-primer-sequence-test" test="($text-count le $count)" role="warning" id="gene-primer-sequence-test">[gene-primer-sequence-test] p element contains what looks like an untagged primer or gene sequence - <value-of select="string-join($text-tokens,', ')"/>.</assert>
    </rule></pattern>
  
  <pattern id="rrid-org-code-pattern"><rule context="p|td|th" id="rrid-org-code">
      <let name="count" value="count(descendant::ext-link[matches(@xlink:href,'identifiers\.org/RRID(:|/).*')])"/>
      <let name="text-count" value="number(count(         for $x in tokenize(.,'RRID\p{Zs}?#?\p{Zs}?:|RRID AB_[\d]+|RRID CVCL_[\d]+|RRID SCR_[\d]+|RRID ISMR_JAX')         return $x)) -1"/>
      <let name="code-text" value="string-join(for $x in tokenize(.,' ') return if (matches($x,'^--[a-z]+')) then $x else (),'; ')"/>
      <let name="unequal-equal-text" value="string-join(for $x in tokenize(replace(.,'[&gt;&lt;]',''),' | ') return if (matches($x,'=$|^=') and not(matches($x,'^=$'))) then $x else (),'; ')"/>
      <let name="link-strip-text" value="string-join(for $x in (*[not(matches(local-name(),'^ext-link$|^contrib-id$|^license_ref$|^institution-id$|^email$|^xref$|^monospace$'))]|text()) return $x,'')"/>
      <let name="url-text" value="string-join(for $x in tokenize($link-strip-text,' ')         return   if (matches($x,'^https?:..(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%_\+.~#?&amp;//=]*)|^ftp://.|^git://.|^tel:.|^mailto:.|\.org[\p{Zs}]?|\.com[\p{Zs}]?|\.co.uk[\p{Zs}]?|\.us[\p{Zs}]?|\.net[\p{Zs}]?|\.edu[\p{Zs}]?|\.gov[\p{Zs}]?|\.io[\p{Zs}]?')) then $x         else (),'; ')"/>
      <let name="organisms" value="if (matches(lower-case(.),$org-regex)) then (e:org-conform(.)) else ()"/>
      
      <report see="https://elifeproduction.slab.com/posts/rri-ds-5k19v560#rrid-test" test="($text-count gt $count)" role="warning" id="rrid-test">[rrid-test] '<name/>' element contains what looks like <value-of select="$text-count - $count"/> unlinked RRID(s). These should always be linked using 'https://identifiers.org/RRID:'. Element begins with <value-of select="substring(.,1,15)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h6d61-org-test" test="not(descendant::element-citation) and $organisms//*:organism" role="warning" id="org-test">[org-test] <name/> element contains organism name(s) that are not in an italic element with that correct capitalisation or spacing - <value-of select="string-join($organisms//*:organism,'; ')"/>. Is this correct? <name/> element begins with <value-of select="concat(.,substring(.,1,15))"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/code-blocks-947pcamv#code-test" test="not(descendant::monospace) and not(descendant::code) and ($code-text != '')" role="warning" id="code-test">[code-test] <name/> element contains what looks like unformatted code - '<value-of select="$code-text"/>' - does this need tagging with &lt;monospace/&gt; or &lt;code/&gt;?</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h9zhw-cell-spacing-test" test="($unequal-equal-text != '') and not(disp-formula[contains(.,'=')]) and not(inline-formula[contains(.,'=')]) and not(child::code) and not(child::monospace)" role="warning" id="cell-spacing-test">[cell-spacing-test] <name/> element contains an equal sign with content directly next to one side, but a space on the other, is this correct? - <value-of select="$unequal-equal-text"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#equal-spacing-test" test="matches(.,'\+cell[s]?|±cell[s]?') and not(descendant::p[matches(.,'\+cell[s]?|±cell[s]?')]) and not(descendant::td[matches(.,'\+cell[s]?|±cell[s]?')]) and not(descendant::th[matches(.,'\+cell[s]?|±cell[s]?')])" role="warning" id="equal-spacing-test">[equal-spacing-test] <name/> element contains the text '+cells' or '±cells' which is very likely to be incorrect spacing - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hrt08-ring-diacritic-symbol-test" test="matches(.,'˚') and not(descendant::p[matches(.,'˚')]) and not(descendant::td[matches(.,'˚')]) and not(descendant::th[matches(.,'˚')])" role="warning" id="ring-diacritic-symbol-test">[ring-diacritic-symbol-test] '<name/>' element contains the ring above symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hxls5-diabetes-1-test" test="matches(.,'[Tt]ype\p{Zs}?[Oo]ne\p{Zs}?[Dd]iabetes') and not(descendant::p[matches(.,'[Tt]ype\p{Zs}?[Oo]ne\p{Zs}?[Dd]iabetes')]) and not(descendant::td[matches(.,'[Tt]ype\p{Zs}?[Oo]ne\p{Zs}?[Dd]iabetes')]) and not(descendant::th[matches(.,'[Tt]ype\p{Zs}?[Oo]ne\p{Zs}?[Dd]iabetes')])" role="error" id="diabetes-1-test">[diabetes-1-test] '<name/>' element contains the phrase 'Type one diabetes'. The number should not be spelled out, this should be 'Type 1 diabetes'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hxls5-diabetes-2-test" test="matches(.,'[Tt]ype\p{Zs}?[Tt]wo\p{Zs}?[Dd]iabetes') and not(descendant::p[matches(.,'[Tt]ype\p{Zs}?[Tt]wo\p{Zs}?[Dd]iabetes')]) and not(descendant::td[matches(.,'[Tt]ype\p{Zs}?[Tt]wo\p{Zs}?[Dd]iabetes')]) and not(descendant::th[matches(.,'[Tt]ype\p{Zs}?[Tt]wo\p{Zs}?[Dd]iabetes')])" role="error" id="diabetes-2-test">[diabetes-2-test] '<name/>' element contains the phrase 'Type two diabetes'. The number should not be spelled out, this should be 'Type 2 diabetes'</report>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hlvnh-unlinked-url" test="not(descendant::p or descendant::td or descendant::th or descendant::title) and not(ancestor::sub-article or child::element-citation) and not(ancestor::fn-group[@content-type='ethics-information']) and not($url-text = '')" role="warning" id="unlinked-url">[unlinked-url] '<name/>' element contains possible unlinked urls. Check - <value-of select="$url-text"/></report>
      
      <report test="matches(.,'\p{Zs}[1-2][0-9][0-9]0\p{Zs}s[\p{Zs}\.]') and not(descendant::p[matches(.,'\p{Zs}[1-2][0-9][0-9]0\p{Zs}s[\p{Zs}\.]')]) and not(descendant::td) and not(descendant::th)" role="warning" id="year-style-test">[year-style-test] '<name/>' element contains the following string(s) - <value-of select="string-join(for $x in tokenize(.,' ')[matches(.,'^[1-2][0-9][0-9]0$')] return concat($x,' s'),'; ')"/>. If this refers to years, then the space should be removed after the number, i.e. <value-of select="string-join(for $x in tokenize(.,' ')[matches(.,'^[1-2][0-9][0-9]0$')] return concat($x,'s'),'; ')"/>. If the text is referring to a unit then this is fine.</report>
      
      <report see="https://elifeproduction.slab.com/posts/archiving-code-zrfi30c5#final-missing-url-test" test="matches(lower-case(.),'(url|citation) to be added')" role="error" id="final-missing-url-test">[final-missing-url-test] <name/> element contains the text 'URL to be added' or 'citation to be added' - <value-of select="."/>. If this is a software heritage link, then please ensure that it is added. If it is a different URL/citation, then the eLife team should check with the authors to determine what needs to be added.</report>
      
      <report test="contains(.,'git://')" role="error" id="git-protocol">[git-protocol] <name/> contains the git:// protocol - <value-of select="."/>. This is no longer widely supported, and should be replaced with the appropriate https:// protocol (or similar) equivalent.</report>
      
      <report test="matches(.,'user-?name\s*:|password\s*:') or (matches(.,'\suser-?name\s') and matches(.,'\spassword\s'))" role="warning" id="user-name-password">[user-name-password] <name/> contains what may be a username and password - <value-of select="."/>. If these are access ceredentials for a dataset depositsed by the authors, it should be made publicly available (unless approved by editors) and the credentials removed/deleted.</report>
    </rule></pattern>
  
  <pattern id="duplicate-ref-pattern"><rule context="ref-list//ref" id="duplicate-ref">
      <let name="doi" value="element-citation/pub-id[@pub-id-type='doi']"/>
      <let name="a-title" value="element-citation/article-title[1]"/>
      <let name="c-title" value="element-citation/chapter-title[1]"/>
      <let name="source" value="element-citation/source[1]"/>
      <let name="top-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi'][1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#duplicate-ref-test-1" test="(element-citation/@publication-type != 'book') and ($doi = preceding-sibling::ref/element-citation/pub-id[@pub-id-type='doi'])" role="error" id="duplicate-ref-test-1">[duplicate-ref-test-1] ref '<value-of select="@id"/>' has the same doi as another reference, which is incorrect. Is it a duplicate?</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#duplicate-ref-test-2" test="(element-citation/@publication-type = 'book') and  ($doi = preceding-sibling::ref/element-citation/pub-id[@pub-id-type='doi'])" role="warning" id="duplicate-ref-test-2">[duplicate-ref-test-2] ref '<value-of select="@id"/>' has the same doi as another reference, which might be incorrect. If they are not different chapters from the same book, then this is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#duplicate-ref-test-3" test="some $x in preceding-sibling::ref/element-citation satisfies (         (($x/article-title = $a-title) and ($x/source = $source))         or         (($x/chapter-title = $c-title) and ($x/source = $source))         )" role="warning" id="duplicate-ref-test-3">[duplicate-ref-test-3] ref '<value-of select="@id"/>' has the same title and source as another reference, which is almost certainly incorrect - '<value-of select="$a-title"/>', '<value-of select="$source"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#duplicate-ref-test-4" test="some $x in preceding-sibling::ref/element-citation satisfies (         (($x/article-title = $a-title) and not($x/source = $source))         or         (($x/chapter-title = $c-title) and not($x/source = $source))         )" role="warning" id="duplicate-ref-test-4">[duplicate-ref-test-4] ref '<value-of select="@id"/>' has the same title as another reference, but a different source. Is this correct? - '<value-of select="$a-title"/>'</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#duplicate-ref-test-6" test="$top-doi = $doi" role="error" id="duplicate-ref-test-6">[duplicate-ref-test-6] ref '<value-of select="@id"/>' has a doi which is the same as the article itself '<value-of select="$top-doi"/>' which must be incorrect.</report>
    </rule></pattern>
  
  <pattern id="ref-xref-conformance-pattern"><rule context="xref[@ref-type='bibr']" id="ref-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="ref" value="ancestor::article/descendant::ref-list[1]/ref[@id = $rid][1]"/>
      <let name="cite1" value="e:citation-format1($ref/descendant::element-citation[1])"/>
      <let name="cite2" value="e:citation-format2($ref/descendant::element-citation[1])"/>
      <let name="cite3" value="normalize-space(replace($cite1,'\p{P}|\p{N}',''))"/>
      <let name="pre-text" value="replace(replace(replace(replace(preceding-sibling::text()[1],' ',' '),' et al\. ',' et al '),'e\.g\.','eg '),'i\.e\. ','ie ')"/>
      <let name="post-text" value="replace(replace(replace(replace(following-sibling::text()[1],' ',' '),' et al\. ',' et al '),'e\.g\.','eg '),'i\.e\. ','ie ')"/>
      <let name="pre-sentence" value="tokenize($pre-text,'\. ')[position() = last()]"/>
      <let name="post-sentence" value="tokenize($post-text,'\. ')[position() = 1]"/>
      <let name="open" value="string-length(replace($pre-sentence,'[^\(]',''))"/>
      <let name="close" value="string-length(replace($pre-sentence,'[^\)]',''))"/>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#final-ref-xref-test-1" test="replace(.,' ',' ') = ($cite1,$cite2)" role="error" id="final-ref-xref-test-1">[final-ref-xref-test-1] <value-of select="."/> - citation does not conform to house style. It should be '<value-of select="$cite1"/>' or '<value-of select="$cite2"/>'. Preceding text = '<value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>'.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-2" test="matches($pre-text,'[\p{L}\p{N}\p{M}\p{Pe},;]$')" role="warning" id="ref-xref-test-2">[ref-xref-test-2] There is no space between citation and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-3" test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')" role="warning" id="ref-xref-test-3">[ref-xref-test-3] There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#final-ref-xref-test-4" test="matches(normalize-space(.),'\p{N}')" role="error" id="final-ref-xref-test-4">[final-ref-xref-test-4] citation doesn't contain numbers, which must be incorrect - <value-of select="."/>. If there is no year for this reference, and you are unable to determine this yourself, please query the authors.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-5" test="matches(normalize-space(.),'\p{L}')" role="error" id="ref-xref-test-5">[ref-xref-test-5] citation doesn't contain letters, which must be incorrect - <value-of select="."/>.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-7" test="($open - $close) gt 1" role="warning" id="ref-xref-test-7">[ref-xref-test-7] citation is preceded by text containing 2 or more open brackets, '('. eLife style is that parenthetical citations already in brackets should be contained in square brackets, '['. Either there is a superfluous '(' in the preceding text, or the '(' needs changing to a '['  - <value-of select="concat(substring($pre-text,string-length($pre-text)-10),.,substring($post-text,1,10))"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-11" test="matches($pre-sentence,' from\p{Zs}*[\(]+$| in\p{Zs}*[\(]+$| by\p{Zs}*[\(]+$| of\p{Zs}*[\(]+$| on\p{Zs}*[\(]+$| to\p{Zs}*[\(]+$| see\p{Zs}*[\(]+$| see also\p{Zs}*[\(]+$| at\p{Zs}*[\(]+$| per\p{Zs}*[\(]+$| follows\p{Zs}*[\(]+$| following\p{Zs}*[\(]+$')" role="warning" id="ref-xref-test-11">[ref-xref-test-11] '<value-of select="concat(substring($pre-text,string-length($pre-text)-10),.)"/>' - citation is preceded by text ending with a possessive, preposition or verb and bracket which suggests the bracket should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-12" test="matches($post-text,'^[\)]+\p{Zs}*who|^[\)]+\p{Zs}*have|^[\)]+\p{Zs}*found|^[\)]+\p{Zs}*used|^[\)]+\p{Zs}*demonstrate|^[\)]+\p{Zs}*follow[s]?|^[\)]+\p{Zs}*followed')" role="warning" id="ref-xref-test-12">[ref-xref-test-12] '<value-of select="concat(.,substring($post-text,1,10))"/>' - citation is followed by a bracket and a possessive, preposition or verb which suggests the bracket is unnecessary.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-14" test="matches($pre-sentence,$cite3)" role="warning" id="ref-xref-test-14">[ref-xref-test-14] citation is preceded by text containing much of the citation text which is possibly unnecessary - <value-of select="concat($pre-sentence,.)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-15" test="matches($post-sentence,$cite3)" role="warning" id="ref-xref-test-15">[ref-xref-test-15] citation is followed by text containing much of the citation text. Is this correct? - '<value-of select="concat(.,$post-sentence)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-13" test="matches($pre-sentence,'\(\[\p{Zs}?$')" role="warning" id="ref-xref-test-13">[ref-xref-test-13] citation is preceded by '(['. Is the square bracket unnecessary? - <value-of select="concat($pre-sentence,.)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-16" test="matches($post-sentence,'^\p{Zs}?\)\)')" role="error" id="ref-xref-test-16">[ref-xref-test-16] citation is followed by '))'. Either one of the brackets is unnecessary or the reference needs to be placed in square brackets - <value-of select="concat(.,$post-sentence)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-17" test="matches($pre-sentence,'\(\(\p{Zs}?$')" role="error" id="ref-xref-test-17">[ref-xref-test-17] citation is preceded by '(('. Either one of the brackets is unnecessary or the reference needs to be placed in square brackets - <value-of select="concat($pre-sentence,.)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-10" test="matches($pre-sentence,'\(\p{Zs}?$') and ((string-length(replace($pre-sentence,'[^\(]','')) - string-length(replace($pre-sentence,'[^\)]',''))) gt 1)" role="warning" id="ref-xref-test-10">[ref-xref-test-10] citation is preceded by '(', and appears to already be in a brackets. Should the bracket(s) around the citation be removed? Or replaced with square brackets? - <value-of select="concat($pre-sentence,.,$post-sentence)"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-18" test="matches($pre-sentence,'\(\p{Zs}?$') and matches($post-sentence,'^\p{Zs}?\);') and (following-sibling::*[1]/name()='xref')" role="warning" id="ref-xref-test-18">[ref-xref-test-18] citation is preceded by '(', and followed by ');'. Should the brackets be removed? - <value-of select="concat($pre-sentence,.,$post-sentence)"/>.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#final-ref-xref-test-19" test="matches(.,'^et al|^ and|^\(\d|^,')" role="error" id="final-ref-xref-test-19">[final-ref-xref-test-19] <value-of select="."/> - citation doesn't start with an author's name which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-20" test="matches($post-text,'^\);\p{Zs}?$') and (following-sibling::*[1]/local-name() = 'xref')" role="error" id="ref-xref-test-20">[ref-xref-test-20] citation is followed by ');', which in turn is followed by another link. This must be incorrect (the bracket should be removed) - '<value-of select="concat(.,$post-sentence,following-sibling::*[1])"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-21" test="matches($pre-sentence,'[A-Za-z0-9]\($')" role="warning" id="ref-xref-test-21">[ref-xref-test-21] citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-sentence,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-22" test="matches($post-sentence,'^\)[A-Za-z0-9]')" role="warning" id="ref-xref-test-22">[ref-xref-test-22] citation is followed by a ')' which in turn is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-sentence)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-26" test="matches($pre-text,'; \[$')" role="warning" id="ref-xref-test-26">[ref-xref-test-26] citation is preceded by '; [' - '<value-of select="concat(substring($pre-text,string-length($pre-text)-10),.,substring($post-text,1,1))"/>' - Are the square bracket(s) surrounding the citation required? If this citation is already in a bracketed sentence, then it's very likely they can be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-27" test="matches($post-text,'^\)\p{Zs}?\($') and (following-sibling::*[1]/local-name() = 'xref')" role="warning" id="ref-xref-test-27">[ref-xref-test-27] citation is followed by ') (', which in turn is followed by another link - '<value-of select="concat(.,$post-sentence,following-sibling::*[1])"/>'. Should the closing and opening brackets be replaced with a '; '? i.e. '<value-of select="concat(.,'; ',following-sibling::*[1])"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-28" test="matches($pre-text,'^\)\p{Zs}?\($') and (preceding-sibling::*[1]/local-name() = 'xref')" role="warning" id="ref-xref-test-28">[ref-xref-test-28] citation is preceded by ') (', which in turn is preceded by another link - '<value-of select="concat(preceding-sibling::*[1],$pre-sentence,.)"/>'. Should the closing and opening brackets be replaced with a '; '? i.e. '<value-of select="concat(preceding-sibling::*[1],'; ',.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/reference-citations-vv87m87l#ref-xref-test-29" test="matches($post-text,'^\);\p{Zs}?$') and (starts-with(following-sibling::*[1]/following-sibling::text()[1],')') or starts-with(following-sibling::*[1]/following-sibling::text()[1],';)'))" role="warning" id="ref-xref-test-29">[ref-xref-test-29] citation is followed by ');', which in turn is followed by something else followed by ')'. Is this punctuation correct? - '<value-of select="concat(.,$post-text,following-sibling::*[1],tokenize(following-sibling::*[1]/following-sibling::text()[1],'\. ')[position() = 1])"/>'.</report>
    </rule></pattern>
  
  <pattern id="unlinked-ref-cite-pattern"><rule context="ref-list/ref/element-citation[year]" id="unlinked-ref-cite">
      <let name="id" value="parent::ref/@id"/>
      <let name="cite-name" value="e:cite-name-text(person-group[@person-group-type='author'][1])"/>
      <let name="cite1" value="e:citation-format1(.)"/>
      <let name="cite2" value="e:citation-format2(.)"/>
      
      <let name="regex" value="replace(replace(concat(replace(replace($cite-name,'\)','\\)'),'\(','\\('),' (',./year[1],'|','\(',./year[1],'\)',')'),'\.','\\.?'),',',',?')"/>
      <let name="article-text" value="string-join(for $x in ancestor::article/*[local-name() = 'body' or local-name() = 'back']//*         return         if ($x/ancestor::sec[@sec-type='data-availability']) then ()         else if ($x/ancestor::ack or local-name()='ack') then ()         else if ($x/ancestor::sec[@sec-type='additional-information']) then ()         else if ($x/ancestor::ref-list) then ()         else if ($x/local-name() = 'xref') then ()         else $x/text(),'')"/>
      
      <report test="matches($article-text,$regex)" role="warning" id="text-v-cite-test">[text-v-cite-test] ref with id <value-of select="$id"/> has unlinked citations in the text - search <value-of select="$cite1"/> or <value-of select="$cite2"/>.</report>
      
    </rule></pattern>
  
  <pattern id="missing-ref-cited-pattern"><rule context="article[not(@article-type=('correction','retraction'))]//p[(ancestor::app or ancestor::body[parent::article]) and not(child::table-wrap) and not(child::supplementary-material)]|td[ancestor::app or ancestor::body[parent::article]]|th[ancestor::app or ancestor::body[parent::article]]" id="missing-ref-cited">
      <let name="text" value="string-join(for $x in self::*/(*|text())         return if ($x/local-name()='xref') then ()         else string($x),'')"/>
      <let name="missing-ref-regex" value="'[A-Z][A-Za-z]+ et al\.?\p{P}?\s*\p{Ps}?([1][7-9][0-9][0-9]|[2][0-2][0-9][0-9])'"/>
      <let name="missing-file-regex" value="' figures? (supplements?\s?)?\d| source (data|code)s? \d| (audio|supplementary) files? \d| tables? \d'"/>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#missing-ref-in-text-test" test="matches($text,$missing-ref-regex)" role="warning" id="missing-ref-in-text-test">[missing-ref-in-text-test] <name/> element contains possible citation which is unlinked or a missing reference - search - <value-of select="concat(tokenize(substring-before($text,' et al'),' ')[last()],' et al ',tokenize(substring-after($text,' et al'),' ')[2])"/></report>
      
      <report test="matches(lower-case($text),$missing-file-regex)" role="warning" id="missing-file-in-text-test">[missing-file-in-text-test] <name/> element contains possible citation to a file which is unlinked or missing. If you are unsure what object needs to be cited then please add the following author query (replacing XXXX as appropriate): Please confirm which XXXXXX this refers to, or confirm that this citation refers to another article.</report>
      
    </rule></pattern>
  
  <pattern id="unlinked-object-cite-pattern"><rule context="fig[not(ancestor::sub-article) and label]|       table-wrap[not(ancestor::sub-article) and label[not(contains(.,'ey resources table'))]]|       media[not(ancestor::sub-article) and label]|       supplementary-material[not(ancestor::sub-article) and label]" id="unlinked-object-cite">
      <let name="cite1" value="replace(label[1],'[\[\]\(\)\.]','')"/>
      <let name="pre-regex" value="replace($cite1,'—','[—–\\-]')"/>
      
      <let name="regex" value="replace($pre-regex,'\s','[\\s ]')"/>
      <let name="article-text" value="string-join(         for $x in ancestor::article/*[local-name() = 'body' or local-name() = 'back']//*         return if ($x/local-name()='label') then ()         else if ($x/ancestor::sub-article or $x/local-name()='sub-article') then ()         else if ($x/ancestor::sec[@sec-type='data-availability']) then ()         else if ($x/ancestor::sec[@sec-type='additional-information']) then ()         else if ($x/ancestor::ref-list) then ()         else if ($x/local-name() = 'xref') then ()         else $x/text(),'')"/>
      
      <report test="matches(lower-case($article-text),lower-case($regex))" role="warning" id="text-v-object-cite-test">[text-v-object-cite-test] <value-of select="$cite1"/> has possible unlinked citations in the text.</report>
      
    </rule></pattern>
  
  <pattern id="vid-xref-conformance-pattern"><rule context="xref[@ref-type='video']" id="vid-xref-conformance">
      <let name="rids" value="tokenize(@rid,'\s')"/>
      <let name="target-nos" value="for $rid in $rids return substring-after($rid,'video')"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <assert see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-conformity-1" test="matches(.,'\p{N}')" role="error" id="vid-xref-conformity-1">[vid-xref-conformity-1] <value-of select="."/> - video citation does not contain any numbers which must be incorrect.</assert>
      
      <!-- Workaround for animations -->
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-conformity-2" test="not(contains(.,'nimation')) and ((count($rids) gt 1 and not(contains(.,$target-nos[1])) or not(contains(.,$target-nos[last()]))) or (count($rids)=1 and not(contains(.,$target-nos))))" role="error" id="vid-xref-conformity-2">[vid-xref-conformity-2] video citation does not match the video that it links to. Target video label number(s) are <value-of select="$target-nos"/>, but <value-of select="if (count($rids) gt 1) then concat($target-nos[1],' and ',$target-nos[last()],' are') else concat($target-nos,' is')"/> not in the citation text - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-2" test="matches($pre-text,'[\p{L}\p{N}\p{M}\p{Pe},;]$')" role="warning" id="vid-xref-test-2">[vid-xref-test-2] There is no space between citation and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-3" test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')" role="warning" id="vid-xref-test-3">[vid-xref-test-3] There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-4" test="(ancestor::media[@mimetype='video']/@id = $rids)" role="warning" id="vid-xref-test-4">[vid-xref-test-4] <value-of select="."/> - video citation is in the caption of the video that it links to. Is it correct or necessary?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-5" test="(matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')" role="error" id="vid-xref-test-5">[vid-xref-test-5] <value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Video citation is in a reference to a video from a different paper, and therefore must be unlinked.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-6" test="matches($pre-text,'[A-Za-z0-9][\(]$')" role="error" id="vid-xref-test-6">[vid-xref-test-6] citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-7" test="matches($post-text,'^[\)][A-Za-z0-9]')" role="error" id="vid-xref-test-7">[vid-xref-test-7] citation is followed by a ')' which in turn is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-8" test="matches($post-text,'^[\p{Zs}]?[\p{Zs}—\-][\p{Zs}]?[Ss]ource')" role="error" id="vid-xref-test-8">[vid-xref-test-8] Incomplete citation. Video citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-9" test="matches($pre-text,'[Ff]igure [0-9]{1,3}[\p{Zs}]?[\p{Zs}\p{P}][\p{Zs}]?$')" role="error" id="vid-xref-test-9">[vid-xref-test-9] Incomplete citation. Video citation is preceded by text which suggests it should instead be a link to a figure level video - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-10" test="matches($pre-text,'cf[\.]?\p{Zs}?[\(]?$')" role="warning" id="vid-xref-test-10">[vid-xref-test-10] citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#vid-xref-test-11" test="contains(lower-case(.),'figure') and contains(.,'Video')" role="warning" id="vid-xref-test-11">[vid-xref-test-11] Figure video citation contains 'Video', when it should contain 'video' with a lowercase v - <value-of select="."/>.</report>
      
    </rule></pattern>
  
  <pattern id="fig-xref-conformance-pattern"><rule context="xref[@ref-type='fig' and @rid]" id="fig-xref-conformance">
      <let name="rid" value="tokenize(@rid,'\s')[1]"/>
      <let name="type" value="e:fig-id-type($rid)"/>
      <let name="no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="target-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="pre-text" value="replace(preceding-sibling::text()[1],'[—–‒]+','-')"/>
      <let name="post-text" value="replace(following-sibling::text()[1],'[—–‒]+','-')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-conformity-1" test="matches(.,'\p{N}')" role="error" id="fig-xref-conformity-1">[fig-xref-conformity-1] <value-of select="."/> - figure citation does not contain any numbers which must be incorrect.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-conformity-2" test="($type = ('Figure','Chemical structure','Scheme')) and not(contains($no,$target-no))" role="error" id="fig-xref-conformity-2">[fig-xref-conformity-2] <value-of select="."/> - figure citation does not appear to link to the same place as the content of the citation suggests it should.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-conformity-3" test="($type = ('Figure','Chemical structure','Scheme')) and ($no != $target-no)" role="warning" id="fig-xref-conformity-3">[fig-xref-conformity-3] <value-of select="."/> - figure citation does not appear to link to the same place as the content of the citation suggests it should.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-conformity-4" test="($type = 'Figure') and matches(.,'[Ss]upplement')" role="error" id="fig-xref-conformity-4">[fig-xref-conformity-4] <value-of select="."/> - figure citation links to a figure, but it contains the string 'supplement'. It cannot be correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-conformity-5" test="($type = 'Figure supplement') and (not(matches(.,'[Ss]upplement'))) and (not(matches(preceding-sibling::text()[1],'–[\p{Zs}]?$| and $| or $|,[\p{Zs}]?$')))" role="warning" id="fig-xref-conformity-5">[fig-xref-conformity-5] figure citation stands alone, contains the text <value-of select="."/>, and links to a figure supplement, but it does not contain the string 'supplement'. Is it correct? Preceding text - '<value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>'</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-conformity-6" test="($type = 'Figure supplement') and ($target-no != $no) and not(contains($no,substring($target-no, string-length($target-no), 1)))" role="error" id="fig-xref-conformity-6">[fig-xref-conformity-6] figure citation contains the text <value-of select="."/> but links to a figure supplement with the id <value-of select="$rid"/> which cannot be correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-2" test="matches($pre-text,'[\p{L}\p{N}\p{M}\p{Pe},;]$')" role="warning" id="fig-xref-test-2">[fig-xref-test-2] There is no space between citation and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-3" test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')" role="warning" id="fig-xref-test-3">[fig-xref-test-3] There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-4" test="not(ancestor::supplementary-material) and not(ancestor::license-p) and (ancestor::fig/@id = $rid)" role="warning" id="fig-xref-test-4">[fig-xref-test-4] <value-of select="."/> - Figure citation is in the caption of the figure that it links to. Is it correct or necessary?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-5" test="($type = 'Figure') and (matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')" role="error" id="fig-xref-test-5">[fig-xref-test-5] <value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Figure citation refers to a figure from a different paper, and therefore must be unlinked.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-6" test="matches($pre-text,'[A-Za-z0-9][\(]$')" role="error" id="fig-xref-test-6">[fig-xref-test-6] citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-7" test="matches($post-text,'^[\)][A-Za-z0-9]')" role="error" id="fig-xref-test-7">[fig-xref-test-7] citation is followed by a ')' which in turn is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-8" test="matches($pre-text,'their $')" role="warning" id="fig-xref-test-8">[fig-xref-test-8] Figure citation is preceded by 'their'. Does this refer to a figure in other content (and as such should be captured as plain text)? - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-9" test="matches($post-text,'^ of [\p{Lu}][\p{Ll}]+[\-]?[\p{Ll}]? et al[\.]?')" role="warning" id="fig-xref-test-9">[fig-xref-test-9] Is this figure citation a reference to a figure from other content (and as such should be captured instead as plain text)? - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-10" test="matches($post-text,'^[\p{Zs}]?[\p{Zs}\p{P}][\p{Zs}]?[Ff]igure supplement')" role="error" id="fig-xref-test-10">[fig-xref-test-10] Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to a Figure supplement - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-11" test="matches($post-text,'^[\p{Zs}]?[\p{Zs}—\-][\p{Zs}]?[Vv]ideo')" role="warning" id="fig-xref-test-11">[fig-xref-test-11] Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to a video supplement - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-12" test="matches($post-text,'^[\p{Zs}]?[\p{Zs}—\-][\p{Zs}]?[Ss]ource')" role="warning" id="fig-xref-test-12">[fig-xref-test-12] Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-13" test="matches($post-text,'^[\p{Zs}]?[Ss]upplement|^[\p{Zs}]?[Ff]igure [Ss]upplement|^[\p{Zs}]?[Ss]ource|^[\p{Zs}]?[Vv]ideo')" role="warning" id="fig-xref-test-13">[fig-xref-test-13] Figure citation is followed by text which suggests it could be an incomplete citation - <value-of select="concat(.,$post-text)"/>'. Is this OK?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-14" test="matches($pre-text,'cf[\.]?\p{Zs}?[\(]?$')" role="warning" id="fig-xref-test-14">[fig-xref-test-14] citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-15" test="matches(.,' [Ff]ig[\.]? ')" role="error" id="fig-xref-test-15">[fig-xref-test-15] Link - '<value-of select="."/>' - is incomplete. It should have 'figure' or 'Figure' spelt out.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-16" test="matches($pre-text,'[Ss]uppl?[\.]?\p{Zs}?$|[Ss]upp?l[ea]mental\p{Zs}?$|[Ss]upp?l[ea]mentary\p{Zs}?$|[Ss]upp?l[ea]ment\p{Zs}?$')" role="warning" id="fig-xref-test-16">[fig-xref-test-16] Figure citation - '<value-of select="."/>' - is preceded by the text '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>' - should it be a figure supplement citation instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-17" test="matches(.,'[A-Z]$') and matches($post-text,'^\p{Zs}?and [A-Z] |^\p{Zs}?and [A-Z]\.')" role="warning" id="fig-xref-test-17">[fig-xref-test-17] Figure citation - '<value-of select="."/>' - is followed by the text '<value-of select="substring($post-text,1,7)"/>' - should this text be included in the link text too (i.e. '<value-of select="concat(.,substring($post-text,1,6))"/>')?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#fig-xref-test-18" test="matches($post-text,'^\-[A-Za-z0-9]')" role="warning" id="fig-xref-test-18">[fig-xref-test-18] Figure citation - '<value-of select="."/>' - is followed by the text '<value-of select="substring($post-text,1,10)"/>' - should some or all of that text be included in the citation text?</report>
    </rule></pattern>
  
  <pattern id="table-xref-conformance-pattern"><rule context="xref[@ref-type='table']" id="table-xref-conformance">
      <let name="rid" value="tokenize(@rid,'\s')[1]"/>
      <let name="text-no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="rid-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-conformity-1" test="not(matches(.,'Table')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ') and not(contains($rid,'app')) and not(contains($rid,'resp')) and not(contains($rid,'sa'))" role="warning" id="table-xref-conformity-1">[table-xref-conformity-1] <value-of select="."/> - citation points to table, but does not include the string 'Table', which is very unusual.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-conformity-2" test="not(matches(.,'table')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ') and contains($rid,'app')" role="warning" id="table-xref-conformity-2">[table-xref-conformity-2] <value-of select="."/> - citation points to an Appendix table, but does not include the string 'table', which is very unusual.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-conformity-3" test="(not(contains($rid,'app') or contains($rid,'sa'))) and ($text-no != $rid-no) and not(contains(.,'–')) and not(contains(.,' and '))" role="warning" id="table-xref-conformity-3">[table-xref-conformity-3] <value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-conformity-4" test="(contains($rid,'app')) and (not(ends-with($text-no,substring($rid-no,2)))) and not(contains(.,'–'))" role="warning" id="table-xref-conformity-4">[table-xref-conformity-4] <value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-conformity-5" test="(contains($rid,'sa')) and (not(ends-with($text-no,substring($rid-no,2)))) and not(contains(.,'–')) and not(contains(.,' and '))" role="warning" id="table-xref-conformity-5">[table-xref-conformity-5] <value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-test-1" test="(ancestor::table-wrap/@id = $rid) and not(ancestor::supplementary-material)" role="warning" id="table-xref-test-1">[table-xref-test-1] <value-of select="."/> - Citation is in the caption of the Table that it links to. Is it correct or necessary?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-test-2" test="matches($pre-text,'[A-Za-z0-9][\(]$')" role="error" id="table-xref-test-2">[table-xref-test-2] citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-test-3" test="matches($post-text,'^[\)][A-Za-z0-9]')" role="error" id="table-xref-test-3">[table-xref-test-3] citation is followed by a ')' which in turn is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-test-4" test="matches($post-text,'^[\p{Zs}]?[\p{Zs}—\-][\p{Zs}]?[Ss]ource')" role="error" id="table-xref-test-4">[table-xref-test-4] Incomplete citation. Table citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-test-5" test="matches($pre-text,'cf[\.]?\p{Zs}?[\(]?$')" role="warning" id="table-xref-test-5">[table-xref-test-5] citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#table-xref-test-6" test="matches($pre-text,'[Ss]uppl?[\.]?\p{Zs}?$|[Ss]upp?l[ea]mental\p{Zs}?$|[Ss]upp?l[ea]mentary\p{Zs}?$|[Ss]upp?l[ea]ment\p{Zs}?$')" role="warning" id="table-xref-test-6">[table-xref-test-6] Table citation - '<value-of select="."/>' - is preceded by the text '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>' - should it be a Supplementary file citation instead?</report>
    </rule></pattern>
  
  <pattern id="supp-file-xref-conformance-pattern"><rule context="xref[@ref-type='supplementary-material']" id="supp-file-xref-conformance">
      <let name="rid" value="tokenize(@rid,'\s')[1]"/>
      <let name="text-no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="last-text-no" value="substring($text-no,string-length($text-no), 1)"/>
      <let name="rid-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="last-rid-no" value="substring($rid-no,string-length($rid-no))"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-conformity-1" test="contains($rid,'data') and not(matches(.,'[Ss]ource data')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ')" role="warning" id="supp-file-xref-conformity-1">[supp-file-xref-conformity-1] <value-of select="."/> - citation points to source data, but does not include the string 'source data', which is very unusual.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-conformity-2" test="contains($rid,'code') and not(matches(.,'[Ss]ource code')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ')" role="warning" id="supp-file-xref-conformity-2">[supp-file-xref-conformity-2] <value-of select="."/> - citation points to source code, but does not include the string 'source code', which is very unusual.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-conformity-3" test="contains($rid,'supp') and not(matches(.,'[Ss]upplementary file')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ')" role="warning" id="supp-file-xref-conformity-3">[supp-file-xref-conformity-3] <value-of select="."/> - citation points to a supplementary file, but does not include the string 'Supplementary file', which is very unusual.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-conformity-4" test="contains(.,$last-rid-no)" role="warning" id="supp-file-xref-conformity-4">[supp-file-xref-conformity-4] <value-of select="."/> - It looks like the citation content does not match what it directs to. The only case where this can be ignored is if this points to an audio file.</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-conformity-5" test="$last-text-no = $last-rid-no" role="warning" id="supp-file-xref-conformity-5">[supp-file-xref-conformity-5] <value-of select="."/> - It looks like the citation content does not match what it directs to. Check that it is correct.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-test-1" test="ancestor::supplementary-material/@id = $rid" role="warning" id="supp-file-xref-test-1">[supp-file-xref-test-1] <value-of select="."/> - Citation is in the caption of the Supplementary file that it links to. Is it correct or necessary?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-xref-test-2" test="matches($pre-text,'[A-Za-z0-9][\(]$')" role="error" id="supp-xref-test-2">[supp-xref-test-2] citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-xref-test-3" test="matches($post-text,'^[\)][A-Za-z0-9]')" role="error" id="supp-xref-test-3">[supp-xref-test-3] citation is followed by a ')' which in turn is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-xref-test-4" test="matches($pre-text,'[Ff]igure [\d]{1,2}[\p{Zs}]?[\p{Zs}\p{P}][\p{Zs}]?$|[Vv]ideo [\d]{1,2}[\p{Zs}]?[\p{Zs}\p{P}][\p{Zs}]?$|[Tt]able [\d]{1,2}[\p{Zs}]?[\p{Zs}\p{P}][\p{Zs}]?$')" role="error" id="supp-xref-test-4">[supp-xref-test-4] Incomplete citation. <value-of select="."/> citation is preceded by text which suggests it should instead be a link to Figure/Video/Table level source data or code - <value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-xref-test-5" test="matches($pre-text,'cf[\.]?\p{Zs}?[\(]?$')" role="warning" id="supp-xref-test-5">[supp-xref-test-5] citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-xref-test-6" test="contains(.,'—Source')" role="warning" id="supp-xref-test-6">[supp-xref-test-6] citation contains '—Source' (<value-of select="."/>). If it refers to asset level source data or code, then 'Source' should be spelled with a lowercase s, as in the label for that file.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-conformity-6" test="contains($rid,'data') and matches(.,'[Ss]ource datas')" role="error" id="supp-file-xref-conformity-6">[supp-file-xref-conformity-6] <value-of select="."/> - citation points to source data but contains the string 'source datas', which is grammatically incorrect. It should be source data instead.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supp-file-xref-conformity-7" test="contains($rid,'code') and matches(.,'[Ss]ource codes')" role="error" id="supp-file-xref-conformity-7">[supp-file-xref-conformity-7] <value-of select="."/> - citation points to source code but contains the string 'source codes', which is grammatically incorrect. It should be source code instead.</report>
      
    </rule></pattern>
  
  <pattern id="equation-xref-conformance-pattern"><rule context="xref[@ref-type='disp-formula']" id="equation-xref-conformance">
      <let name="rids" value="replace(@rid,'^\s|\s$','')"/>
      <let name="labels" value="for $rid in tokenize($rids,'\s')[position()=(1,last())] return translate(ancestor::article//disp-formula[@id = $rid]/label,'()','')"/>
      <let name="prec-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#equ-xref-conformity-1" test="not(matches(.,'[Ee]quation')) and ($prec-text != ' and ') and ($prec-text != '–')" role="warning" id="equ-xref-conformity-1">[equ-xref-conformity-1] <value-of select="."/> - link points to equation, but does not include the string 'Equation', which is unusual. Is it correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#equ-xref-conformity-2" test="if (count($labels) gt 1) then (some $label in $labels satisfies not(contains(.,$label)))               else not(contains(.,$labels))" role="warning" id="equ-xref-conformity-2">[equ-xref-conformity-2] equation link content does not match what it directs to (content = <value-of select="."/>; label(s) = <value-of select="string-join($labels,'; ')"/>). Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#equ-xref-conformity-3" test="(matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')" role="error" id="equ-xref-conformity-3">[equ-xref-conformity-3] <value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Equation citation appears to be a reference to an equation from a different paper, and therefore must be unlinked.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#equ-xref-conformity-4" test="matches($prec-text,'cf[\.]?\p{Zs}?[\(]?$')" role="warning" id="equ-xref-conformity-4">[equ-xref-conformity-4] citation is preceded by '<value-of select="substring($prec-text,string-length($prec-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
    </rule></pattern>
  
  <pattern id="org-ref-article-book-title-pattern"><rule context="element-citation/article-title|       element-citation/chapter-title|       element-citation/source|       element-citation/data-title" id="org-ref-article-book-title">
      
      <let name="organisms" value="if (matches(lower-case(.),$org-regex)) then (e:org-conform(.)) else ()"/>
      
      <report test="$organisms//*:organism" role="info" id="ref-article-title-organism-check">[ref-article-title-organism-check] ref <value-of select="ancestor::ref/@id"/> has a <name/> element containing an organism - <value-of select="string-join($organisms//*:organism,'; ')"/> - but there is no italic element with that correct capitalisation or spacing.</report>
    
    </rule></pattern><pattern id="org-title-kwd-pattern"><rule context="article//article-meta/title-group/article-title | article/body//sec/title | article//article-meta//kwd" id="org-title-kwd">
      
      <let name="organisms" value="if (matches(lower-case(.),$org-regex)) then (e:org-conform(.)) else ()"/>
      
      <report test="$organisms//*:organism" role="info" id="article-title-organism-check">[article-title-organism-check] <name/> contains an organism - <value-of select="string-join($organisms//*:organism,'; ')"/> - but there is no italic element with that correct capitalisation or spacing.</report>
      
    </rule></pattern><pattern id="italic-genus-pattern"><rule context="italic[matches(lower-case(.),$genus-regex)]" id="italic-genus">
      <let name="regex-prefix" value="concat('(',$genus-regex,')')"/>
      
      <report test="matches(lower-case(.),concat($regex-prefix,'\p{Zs}*oocytes'))" role="error" id="italic-genus-oocytes">[italic-genus-oocytes] <name/> contains a genus name followed by 'oocytes'. 'oocytes' should not be in italics.</report>
      
    </rule></pattern>
  
  <pattern id="unallowed-symbol-tests-pattern"><rule context="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link" id="unallowed-symbol-tests">		
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7s38-copyright-symbol" test="contains(.,'©')" role="error" id="copyright-symbol">[copyright-symbol] <name/> element contains the copyright symbol, '©', which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7s38-trademark-symbol" test="contains(.,'™')" role="error" id="trademark-symbol">[trademark-symbol] <name/> element contains the trademark symbol, '™', which is not allowed.</report>

      <report test="contains(.,'℠')" role="error" id="service-mark-symbol">[service-mark-symbol] <name/> element contains the service mark symbol, '℠', which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7s38-reg-trademark-symbol" test="contains(.,'®')" role="error" id="reg-trademark-symbol">[reg-trademark-symbol] <name/> element contains the registered trademark symbol, '®', which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7s38-Inc-presence" test="matches(.,' [Ii]nc\. |[Ii]nc\.\)|[Ii]nc\.,')" role="warning" id="Inc-presence">[Inc-presence] <name/> element contains 'Inc.' with a full stop. Remove the full stop.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hkbnb-andand-presence" test="matches(.,' [Aa]nd [Aa]nd ')" role="warning" id="andand-presence">[andand-presence] <name/> element contains ' and and ' which is very likely to be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#figurefigure-presence" test="matches(.,'[Ff]igure [Ff]igure')" role="warning" id="figurefigure-presence">[figurefigure-presence] <name/> element contains ' figure figure ' which is very likely to be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hkbnb-plus-minus-presence" test="matches(translate(.,'—– ','-- '),'[\+\-]\p{Zs}+/\p{Zs}?[\+\-]|[\+\-]\p{Zs}?/\p{Zs}+[\+\-]')" role="warning" id="plus-minus-presence">[plus-minus-presence] <name/> element contains two plus or minus signs separated by a space and a forward slash (such as '+ /-'). Should the space be removed? - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supplementalfigure-presence" test="not(ancestor::sub-article) and matches(.,'\p{Zs}?[Ss]upplemental [Ff]igure')" role="warning" id="supplementalfigure-presence">[supplementalfigure-presence] <name/> element contains the phrase ' Supplemental figure ' which almost certainly needs updating. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supplementalfile-presence" test="not(ancestor::sub-article) and matches(.,'\p{Zs}?[Ss]upplemental [Ff]ile')" role="warning" id="supplementalfile-presence">[supplementalfile-presence] <name/> element contains the phrase ' Supplemental file ' which almost certainly needs updating. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supplementaryfigure-presence" test="not(ancestor::sub-article) and matches(.,'\p{Zs}?[Ss]upplementary [Ff]igure')" role="warning" id="supplementaryfigure-presence">[supplementaryfigure-presence] <name/> element contains the phrase ' Supplementary figure ' which almost certainly needs updating. If it's unclear which figure/figure supplement should be cited, please query the authors. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#supplement-table-presence" test="not(ancestor::sub-article) and matches(.,'\p{Zs}?[Ss]upplementa(l|ry) [Tt]able')" role="warning" id="supplement-table-presence">[supplement-table-presence] <name/> element contains the phrase 'Supplementary table' or 'Supplemental table'. Does it need updating? If it's unclear what should be cited, please query the authors. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report test="not(local-name()='code') and not(ancestor::sub-article) and matches(.,' [Rr]ef\. ')" role="error" id="ref-presence">[ref-presence] <name/> element contains 'Ref.' which is either incorrect or unnecessary.</report>
      
      <report test="not(local-name()='code') and not(ancestor::sub-article) and matches(.,' [Rr]efs\. ')" role="error" id="refs-presence">[refs-presence] <name/> element contains 'Refs.' which is either incorrect or unnecessary.</report>
      
      <report test="contains(.,'�')" role="error" id="replacement-character-presence">[replacement-character-presence] <name/> element contains the replacement character '�' which is not allowed.</report>
      
      <report test="contains(.,'')" role="error" id="junk-character-presence">[junk-character-presence] <name/> element contains a junk character '' which should be replaced.</report>
      
      <report test="contains(.,'︎')" role="error" id="junk-character-presence-2">[junk-character-presence-2] <name/> element contains a junk character '︎' which should be replaced or deleted.</report>

      <report test="contains(.,'□')" role="warning" id="junk-character-presence-3">[junk-character-presence-3] <name/> element contains a possible junk character '□'. Unless it's at the end of a mathematical proof, this should be replaced or deleted.</report>
      
      <report test="contains(.,'¿')" role="warning" id="inverterted-question-presence">[inverterted-question-presence] <name/> element contains an inverted question mark '¿' which should very likely be replaced/removed.</report>
      
      <report test="some $x in self::*[not(local-name() = ('monospace','code'))]/text() satisfies matches($x,'\(\)|\[\]')" role="warning" id="empty-parentheses-presence">[empty-parentheses-presence] <name/> element contains empty parentheses ('[]', or '()'). Is there a missing citation within the parentheses? Or perhaps this is a piece of code that needs formatting?</report>
      
      <report test="matches(.,'&amp;#x\d')" role="warning" id="broken-unicode-presence">[broken-unicode-presence] <name/> element contains what looks like a broken unicode - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7s38-extra-full-stop-presence" test="not(ancestor::sub-article) and not(local-name()='code') and contains(.,'..') and not(contains(.,'...'))" role="warning" id="extra-full-stop-presence">[extra-full-stop-presence] <name/> element contains what looks two full stops right next to each other (..) - Is that correct? - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7s38-extra-space-presence" test="not(local-name()='code') and not(inline-formula|element-citation|code|disp-formula|table-wrap|list|inline-graphic|supplementary-material|break) and matches(replace(.,' ',' '),'\s\s+')" role="warning" id="extra-space-presence">[extra-space-presence] <name/> element contains two or more spaces right next to each other - it is very likely that only 1 space is necessary - <value-of select="."/>.</report>
      
      <report test="contains(.,'&#x9D;')" role="error" id="operating-system-command-presence">[operating-system-command-presence] <name/> element contains an operating system command character '&#x9D;' (unicode string: &amp;#x9D;) which should very likely be replaced/removed. - <value-of select="."/></report>

      <report test="matches(lower-case(.),&quot;(^|\s)((i am|i'm) an? ai (language)? model|as an ai (language)? model,? i('m|\s)|(here is|here's) an? (possible|potential)? introduction (to|for) your topic|(here is|here's) an? (abstract|introduction|results|discussion|methods)( section)? for you|certainly(,|!)? (here is|here's)|i'm sorry,?( but)? i (don't|can't)|knowledge (extend|cutoff)|as of my last update|regenerate response)&quot;)" role="warning" id="ai-response-presence-1">[ai-response-presence-1] <name/> element contains what looks like a response from an AI chatbot after it being provided a prompt. Is that correct? Should the content be adjusted?</report>
    </rule></pattern><pattern id="unallowed-symbol-tests-sup-pattern"><rule context="sup" id="unallowed-symbol-tests-sup">		
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-copyright-symbol-sup" test="contains(.,'©')" role="error" id="copyright-symbol-sup">[copyright-symbol-sup] '<name/>' element contains the copyright symbol, '©', which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-trademark-symbol-1-sup" test="contains(.,'™')" role="error" id="trademark-symbol-1-sup">[trademark-symbol-1-sup] '<name/>' element contains the trademark symbol, '™', which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-trademark-symbol-2-sup" test=". = 'TM'" role="warning" id="trademark-symbol-2-sup">[trademark-symbol-2-sup] '<name/>' element contains the text 'TM', which means that it resembles the trademark symbol. The trademark symbol is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-reg-trademark-symbol-sup" test="contains(.,'®')" role="error" id="reg-trademark-symbol-sup">[reg-trademark-symbol-sup] '<name/>' element contains the registered trademark symbol, '®', which is not allowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-degree-symbol-sup" test="contains(.,'°')" role="error" id="degree-symbol-sup">[degree-symbol-sup] '<name/>' element contains the degree symbol, '°', which is unnecessary. It does not need to be superscript.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-white-circle-symbol-sup" test="contains(.,'○')" role="warning" id="white-circle-symbol-sup">[white-circle-symbol-sup] '<name/>' element contains the white circle symbol, '○'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-ring-op-symbol-sup" test="contains(.,'∘')" role="warning" id="ring-op-symbol-sup">[ring-op-symbol-sup] '<name/>' element contains the Ring Operator symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#he2sr-ring-diacritic-symbol-sup" test="contains(.,'˚')" role="warning" id="ring-diacritic-symbol-sup">[ring-diacritic-symbol-sup] '<name/>' element contains the ring above symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>

      <report test="contains(.,'℠')" role="error" id="service-mark-symbol-1-sup">[service-mark-symbol-1-sup] '<name/>' element contains the service mark symbol, '℠', which is not allowed.</report>
      
      <report test=". = 'SM'" role="warning" id="service-mark-symbol-2-sup">[service-mark-symbol-2-sup] '<name/>' element contains the text 'SM', which means that it resembles the service mark symbol. The service mark symbol is not allowed.</report>
    </rule></pattern><pattern id="underline-tests-pattern"><rule context="underline" id="underline-tests">
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hd9o3-underline-test-1" test="matches(.,'^\p{P}*$')" role="warning" id="underline-test-1">[underline-test-1] '<name/>' element only contains punctuation - <value-of select="."/> - Should it have underline formatting?</report>
      
    </rule></pattern><pattern id="latex-tests-pattern"><rule context="p[not(descendant::mml:math)]|td[not(descendant::mml:math)]|th[not(descendant::mml:math)]|monospace|code" id="latex-tests">
      
      <report test="matches(.,'\p{Zs}*\\[a-z]*\p{Ps}')" role="warning" id="latex-test">[latex-test] <name/> element contains what looks like possible LaTeX. Please check that this is correct (i.e. that it is not the case that the authors included LaTeX markup expecting the content to be rendered as it would be in LaTeX. Content - "<value-of select="."/>"</report>
      
    </rule></pattern><pattern id="country-tests-pattern"><rule context="front//aff/country" id="country-tests">
      <let name="text" value="self::*/text()"/>
      <let name="countries" value="'countries.xml'"/>
      <let name="city" value="parent::aff/descendant::named-content[@content-type='city'][1]"/>
      <!--<let name="valid-country" value="document($countries)/countries/country[text() = $text]"/>-->
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h54ah-united-states-test-1" test="$text = 'United States of America'" role="error" id="united-states-test-1">[united-states-test-1] <value-of select="."/> is not allowed. This should be 'United States'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hvgkz-united-states-test-2" test="$text = 'USA'" role="error" id="united-states-test-2">[united-states-test-2] <value-of select="."/> is not allowed. This should be 'United States'</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hko11-united-kingdom-test-2" test="$text = 'UK'" role="error" id="united-kingdom-test-2">[united-kingdom-test-2] <value-of select="."/> is not allowed. This should be 'United Kingdom'</report>
      
      <assert see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hulu7-gen-country-test" test="$text = document($countries)/countries/country" role="error" id="gen-country-test">[gen-country-test] affiliation contains a country which is not in the allowed list - <value-of select="."/>. For a list of allowed countries, refer to https://github.com/elifesciences/eLife-JATS-schematron/blob/master/src/countries.xml.</assert>
      <!-- Commented out until this is implemented
      <report test="($text = document($countries)/countries/country) and not(@country = $valid-country/@country)" 
        role="warning" 
        id="gen-country-iso-3166-test">country does not have a 2 letter ISO 3166-1 @country value. It should be @country='<value-of select="$valid-country/@country"/>'.</report>-->
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hiz90-singapore-test-1" test="(. = 'Singapore') and ($city != 'Singapore')" role="error" id="singapore-test-1">[singapore-test-1] <value-of select="ancestor::aff/@id"/> has 'Singapore' as its country but '<value-of select="$city"/>' as its city, which must be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hyh7x-taiwan-test" test="(. != 'Taiwan') and  (matches(lower-case($city),'ta[i]?pei|tai\p{Zs}?chung|kaohsiung|taoyuan|tainan|hsinchu|keelung|chiayi|changhua|jhongli|tao-yuan|hualien'))" role="warning" id="taiwan-test">[taiwan-test] Affiliation has a Taiwanese city - <value-of select="$city"/> - but its country is '<value-of select="."/>'. Please check the original manuscript. If it has 'Taiwan' as the country in the original manuscript then ensure it is changed to 'Taiwan'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h44n1-s-korea-test" test="(. != 'Republic of Korea') and  (matches(lower-case($city),'chuncheon|gyeongsan|daejeon|seoul|daegu|gwangju|ansan|goyang|suwon|gwanju|ochang|wonju|jeonnam|cheongju|ulsan|inharo|chonnam|miryang|pohang|deagu|gwangjin-gu|gyeonggi-do|incheon|gimhae|gyungnam|muan-gun|chungbuk|chungnam|ansung|cheongju-si'))" role="warning" id="s-korea-test">[s-korea-test] Affiliation has a South Korean city - <value-of select="$city"/> - but its country is '<value-of select="."/>', instead of 'Republic of Korea'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h2i0t-n-korea-test" test="replace(.,'\p{P}','') = 'Democratic Peoples Republic of Korea'" role="warning" id="n-korea-test">[n-korea-test] Affiliation has '<value-of select="."/>' as its country which is very likely to be incorrect.</report>
    </rule></pattern><pattern id="city-tests-pattern"><rule context="front//aff//named-content[@content-type='city']" id="city-tests">
      <let name="lc" value="normalize-space(lower-case(.))"/>
      <let name="states-regex" value="'^alabama$|^al$|^alaska$|^ak$|^arizona$|^az$|^arkansas$|^ar$|^california$|^ca$|^colorado$|^co$|^connecticut$|^ct$|^delaware$|^de$|^florida$|^fl$|^georgia$|^ga$|^hawaii$|^hi$|^idaho$|^id$|^illinois$|^il$|^indiana$|^in$|^iowa$|^ia$|^kansas$|^ks$|^kentucky$|^ky$|^louisiana$|^la$|^maine$|^me$|^maryland$|^md$|^massachusetts$|^ma$|^michigan$|^mi$|^minnesota$|^mn$|^mississippi$|^ms$|^missouri$|^mo$|^montana$|^mt$|^nebraska$|^ne$|^nevada$|^nv$|^new hampshire$|^nh$|^new jersey$|^nj$|^new mexico$|^nm$|^ny$|^north carolina$|^nc$|^north dakota$|^nd$|^ohio$|^oh$|^oklahoma$|^ok$|^oregon$|^or$|^pennsylvania$|^pa$|^rhode island$|^ri$|^south carolina$|^sc$|^south dakota$|^sd$|^tennessee$|^tn$|^texas$|^tx$|^utah$|^ut$|^vermont$|^vt$|^virginia$|^va$|^wa$|^west virginia$|^wv$|^wisconsin$|^wi$|^wyoming$|^wy$'"/>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#ho7od-final-us-states-test" test="matches($lc,$states-regex)" role="error" id="final-US-states-test">[final-US-states-test] city contains a US state (or an abbreviation for it) - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h4yk9-singapore-test-2" test="(. = 'Singapore') and (ancestor::aff/country/text() != 'Singapore')" role="error" id="singapore-test-2">[singapore-test-2] <value-of select="ancestor::aff/@id"/> has 'Singapore' as its city but '<value-of select="ancestor::aff/country/text()"/>' as its country, which must be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h54dm-wash-dc-test-1" test="(lower-case(.) = 'washington') and (ancestor::aff/country/text() = 'United States')" role="error" id="wash-dc-test-1">[wash-dc-test-1] <value-of select="ancestor::aff/@id"/> has 'Washington' as its city. Either it should be changed to 'Washington, DC' or if referring to the US state then changed to the correct city.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hxtjh-city-replacement-character-presence" test="matches(.,'�')" role="error" id="city-replacement-character-presence">[city-replacement-character-presence] <name/> element contains the replacement character '�' which is unallowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hbjgo-city-number-presence" test="matches(.,'\d')" role="warning" id="city-number-presence">[city-number-presence] city contains a number, which is almost certainly incorrect - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hra66-city-street-presence" test="matches(lower-case(.),'^rue | rue |^street | street |^building | building |^straße | straße |^stadt | stadt |^platz | platz |^strada | strada |^cedex | cedex |^blvd | blvd |^boulevard| boulevard ')" role="warning" id="city-street-presence">[city-street-presence] city likely contains a street or building name, which is almost certainly incorrect - <value-of select="."/>.</report>
    </rule></pattern><pattern id="institution-tests-pattern"><rule context="aff/institution[not(@*)]" id="institution-tests">
      <let name="city" value="parent::*/addr-line[1]/named-content[@content-type='city'][1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hfc9g-uc-no-test-1" test="matches(normalize-space(.),'[Uu]niversity of [Cc]alifornia$')" role="error" id="UC-no-test1">[UC-no-test1] <value-of select="."/> is not allowed as insitution name, since this is always followed by city name. This should very likely be <value-of select="concat('University of California, ',$city)"/> (provided there is a city tagged).</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hgke7-uc-no-test-2" test="matches(normalize-space(.),'[Uu]niversity of [Cc]alifornia.') and not(contains(.,'San Diego')) and ($city !='') and not(contains(.,$city))" role="warning" id="UC-no-test-2">[UC-no-test-2] <value-of select="."/> has '<value-of select="substring-after(.,'alifornia')"/>' as its campus name in the institution field, but '<value-of select="$city"/>' is the city. Which is correct? Should it end with '<value-of select="concat('University of California, ',following-sibling::addr-line[1]/named-content[@content-type='city'][1])"/>' instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hw55n-uc-no-test-3" test="matches(normalize-space(.),'[Uu]niversity of [Cc]alifornia.') and not(contains(.,'San Diego')) and ($city='La Jolla')" role="warning" id="UC-no-test-3">[UC-no-test-3] <value-of select="."/> has '<value-of select="substring-after(.,'alifornia')"/>' as its campus name in the institution field, but '<value-of select="$city"/>' is the city. Should the institution end with 'University of California, San Diego' instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hc48u-institution-replacement-character-presence" test="matches(.,'�')" role="error" id="institution-replacement-character-presence">[institution-replacement-character-presence] <name/> element contains the replacement character '�' which is unallowed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#h69nr-institution-street-presence" test="matches(lower-case(.),'^rue | rue |^street | street |^building | building |^straße | straße |^stadt | stadt |^platz | platz |^strada | strada |^cedex | cedex |^blvd | blvd |^boulevard| boulevard ')" role="warning" id="institution-street-presence">[institution-street-presence] institution likely contains a street or building name, which is likely to be incorrect - <value-of select="."/>.</report>
      
      <!-- contains an ampersand and is not a known exception -->
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hs0dc-institution-ampersand-presence" test="matches(replace(lower-case(.),'(texas a\s*&amp;\s*m|hygiene &amp; tropical|r\s*&amp;\s*d)',''),'&amp;')" role="warning" id="institution-ampersand-presence">[institution-ampersand-presence] institution contains an ampersand - <value-of select="."/>. It's eLife style to use 'and' instead of an ampersand except in cases where the ampersand is explicitly part of the institution name (e.g. Texas A&amp;M University). Should it be changed here?</report>
    </rule></pattern><pattern id="department-tests-pattern"><rule context="aff/institution[@content-type='dept']" id="department-tests">
      
      <report see="https://elifeproduction.slab.com/posts/affiliations-js7opgq6#hd64t-dept-replacement-character-presence" test="contains(.,'�')" role="error" id="dept-replacement-character-presence">[dept-replacement-character-presence] <name/> element contains the replacement character '�' which is unallowed.</report>
      
    </rule></pattern><pattern id="journal-title-tests-pattern"><rule context="element-citation[@publication-type='journal']/source" id="journal-title-tests">
      <let name="doi" value="ancestor::element-citation/pub-id[@pub-id-type='doi'][1]"/>
      <let name="uc" value="upper-case(.)"/>
        
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#PLOS-1" test="($uc != 'PLOS ONE') and matches(.,'plos|Plos|PLoS')" role="error" id="PLOS-1">[PLOS-1] ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'PLOS' should be upper-case.</report>
        
       <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#PLOS-2" test="($uc = 'PLOS ONE') and (. != 'PLOS ONE')" role="error" id="PLOS-2">[PLOS-2] ref '<value-of select="ancestor::ref/@id"/>' contains
         <value-of select="."/>. 'PLOS ONE' should be upper-case.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#PNAS" test="if (starts-with($doi,'10.1073')) then . != 'PNAS'         else()" role="error" id="PNAS">[PNAS] ref '<value-of select="ancestor::ref/@id"/>' has the doi for 'PNAS' but the journal name is
        <value-of select="."/>, which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#RNA" test="($uc = 'RNA') and (. != 'RNA')" role="error" id="RNA">[RNA] ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'RNA' should be upper-case.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#bmj" test="(matches($uc,'^BMJ$|BMJ[:]? ')) and matches(.,'Bmj|bmj|BMj|BmJ|bMj|bmJ')" role="error" id="bmj">[bmj] ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'BMJ' should be upper-case.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#G3" test="starts-with($doi,'10.1534/g3') and (. != 'G3: Genes, Genomes, Genetics')" role="error" id="G3">[G3] ref '<value-of select="ancestor::ref/@id"/>' has the doi for 'G3' but the journal name is
        <value-of select="."/> - it should be 'G3: Genes, Genomes, Genetics'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#ampersand-check" test="matches(.,'[Aa]mp;')" role="warning" id="ampersand-check">[ampersand-check] ref '<value-of select="ancestor::ref/@id"/>' appears to contain the text 'amp', is this a broken ampersand?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#Research-gate-check" test="(normalize-space($uc) = 'RESEARCH GATE') or (normalize-space($uc) = 'RESEARCHGATE')" role="error" id="Research-gate-check">[Research-gate-check]  ref '<value-of select="ancestor::ref/@id"/>' has a source title '<value-of select="."/>' which must be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#journal-replacement-character-presence" test="matches(.,'�')" role="error" id="journal-replacement-character-presence">[journal-replacement-character-presence] <name/> element contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#journal-off-presence" test="matches(.,'[Oo]fficial [Jj]ournal')" role="warning" id="journal-off-presence">[journal-off-presence] ref '<value-of select="ancestor::ref/@id"/>' has a source title which contains the text 'official journal' - '<value-of select="."/>'. Is this necessary?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#handbook-presence" test="contains($uc,'HANDBOOK')" role="error" id="handbook-presence">[handbook-presence] Journal ref '<value-of select="ancestor::ref/@id"/>' has a journal name '<value-of select="."/>'. Should it be captured as a book type reference instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#elife-check" test="starts-with($doi,'10.7554/eLife.') and (. != 'eLife')" role="error" id="elife-check">[elife-check] Journal ref '<value-of select="ancestor::ref/@id"/>' has an eLife doi <value-of select="$doi"/>, but the journal name is '<value-of select="."/>', when it should be 'eLife'. Either the journal name needs updating to eLife, or the doi is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#journal-bracket-check" test="matches(.,'\[|\(|\)|\]')" role="warning" id="journal-bracket-check">[journal-bracket-check] Journal ref '<value-of select="ancestor::ref/@id"/>' has a journal name which contains brackets '<value-of select="."/>'. It is very unlikely that the content in the brackets is required.</report>
    </rule></pattern><pattern id="ref-article-title-tests-pattern"><rule context="element-citation[@publication-type='journal']/article-title" id="ref-article-title-tests">
      <let name="rep" value="replace(.,' [Ii]{1,3}\. | IV\. | V. | [Cc]\. [Ee]legans| vs\. | sp\. ','')"/>
      <let name="word-count" value="count(tokenize(.,'\p{Zs}'))"/>
      <let name="title-word-count" value="count(tokenize(.,'\p{Zs}')[.=concat(upper-case(substring(.,1,1)),substring(.,2))])"/>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#article-title-fullstop-check-1" test="(matches($rep,'[A-Za-z][A-Za-z]+\. [A-Za-z]'))" role="info" id="article-title-fullstop-check-1">[article-title-fullstop-check-1] ref '<value-of select="ancestor::ref/@id"/>' has an article-title with a full stop. Is this correct, or has the journal/source title been included? Or perhaps the full stop should be a colon ':'?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#article-title-fullstop-check-2" test="matches(.,'\.$') and not(matches(.,'\.\.$'))" role="error" id="article-title-fullstop-check-2">[article-title-fullstop-check-2] ref '<value-of select="ancestor::ref/@id"/>' has an article-title which ends with a full stop, which cannot be correct - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#article-title-fullstop-check-3" test="matches(.,'\.$') and matches(.,'\.\.$')" role="warning" id="article-title-fullstop-check-3">[article-title-fullstop-check-3] ref '<value-of select="ancestor::ref/@id"/>' has an article-title which ends with some full stops - is this correct? - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#article-title-correction-check" test="matches(.,'^[Cc]orrection|^[Rr]etraction|[Ee]rratum')" role="warning" id="article-title-correction-check">[article-title-correction-check] ref '<value-of select="ancestor::ref/@id"/>' has an article-title which begins with 'Correction', 'Retraction' or contains 'Erratum'. Is this a reference to the notice or the original article?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#article-title-journal-check" test="matches(.,' [Jj]ournal ')" role="warning" id="article-title-journal-check">[article-title-journal-check] ref '<value-of select="ancestor::ref/@id"/>' has an article-title which contains the text ' journal '. Is a journal name (source) erroneously included in the title? - '<value-of select="."/>'</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#article-title-child-1" test="(count(child::*) = 1) and (count(child::text()) = 0)" role="warning" id="article-title-child-1">[article-title-child-1] ref '<value-of select="ancestor::ref/@id"/>' has an article-title with one child <value-of select="*/local-name()"/> element, and no text. This is almost certainly incorrect. - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#a-title-replacement-character-presence" test="matches(.,'�')" role="error" id="a-title-replacement-character-presence">[a-title-replacement-character-presence] <name/> element contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#article-title-case" test="($word-count gt 4) and ($title-word-count gt ($word-count div 2))" role="warning" id="article-title-case">[article-title-case] Journal ref has <name/> in mostly title case. Is that correct? eLife style is to use sentence case. "<value-of select="."/>"</report>
      
    </rule></pattern><pattern id="journal-tests-pattern"><rule context="element-citation[@publication-type='journal']" id="journal-tests">
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#eloc-page-assert" test="not(fpage) and not(elocation-id) and not(comment)" role="warning" id="eloc-page-assert">[eloc-page-assert] ref '<value-of select="ancestor::ref/@id"/>' is a journal, but it doesn't have a page range or e-location. Is this right?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#volume-assert" test="not(comment[.='In press']) and not(volume)" role="warning" id="volume-assert">[volume-assert] ref '<value-of select="ancestor::ref/@id"/>' is a journal, but it doesn't have a volume. Is this right?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#journal-preprint-check" test="matches(normalize-space(lower-case(source[1])),'^biorxiv$|^africarxiv$|^arxiv$|^cell\s+sneak\s+peak$|^chemrxiv$|^chinaxiv$|^eartharxiv$|^medrxiv$|^osf\s+preprints$|^paleorxiv$|^peerj\s+preprints$|^preprints$|^preprints\.org$|^psyarxiv$|^research\s+square$|^scielo\s+preprints$|^ssrn$|^vixra$')" role="error" id="journal-preprint-check">[journal-preprint-check] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="source[1]"/>, but it is captured as a journal not a preprint.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#elife-ref-check" test="(lower-case(source[1]) = 'elife') and not(matches(pub-id[@pub-id-type='doi'][1],'^10.7554/eLife\.\d{5,6}$|^10.7554/eLife\.\d{5,6}\.\d$|^10.7554/eLife\.\d{5,6}\.\d{3}$|^10.7554/eLife\.\d{5,6}\.sa[12]$'))" role="error" id="elife-ref-check">[elife-ref-check] ref '<value-of select="ancestor::ref/@id"/>' is an <value-of select="source[1]"/> article, but it has no doi in the format 10.7554/eLife.00000, which must be incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#journal-conference-ref-check-1" test="matches(lower-case(source[1]),'conference|symposium|symposia|neural information processing|nips|computer vision and pattern recognition|scipy|workshop|meeting|spie|congress|[\d]st|[\d]nd|[\d]rd|[\d]th')" role="warning" id="journal-conference-ref-check-1">[journal-conference-ref-check-1] Journal ref '<value-of select="ancestor::ref/@id"/>' has the journal name <value-of select="source[1]"/>. Should it be a conference type reference instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/journal-references-i098980k#journal-conference-ref-check-2" test="matches(source[1],'^[1][7-9][0-9][0-9] |\([1][7-9][0-9][0-9][\)\p{Zs}]| [1][7-9][0-9][0-9] | [1][7-9][0-9][0-9]$|^[2][0-2][0-9][0-9] |\([2][0-2][0-9][0-9][\)\p{Zs}]| [2][0-2][0-9][0-9] | [2][0-2][0-9][0-9]$')" role="warning" id="journal-conference-ref-check-2">[journal-conference-ref-check-2] Journal ref '<value-of select="ancestor::ref/@id"/>' has a journal name containing a year - <value-of select="source[1]"/>. Should it be a conference type reference instead? Or should the year be removed from the journal name?</report>
      
    </rule></pattern><pattern id="book-chapter-tests-pattern"><rule context="element-citation[(@publication-type='book') and chapter-title]" id="book-chapter-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hm8cf-book-chapter-test-1" test="person-group[@person-group-type='editor']" role="warning" id="book-chapter-test-1">[book-chapter-test-1] ref '<value-of select="ancestor::ref/@id"/>' (<value-of select="e:citation-format1(.)"/>) is tagged as a book reference with a chapter title, but there are no editors. Is this correct, or are these details missing?</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#hwihq-book-chapter-test-2" test="fpage and lpage" role="warning" id="book-chapter-test-2">[book-chapter-test-2] ref '<value-of select="ancestor::ref/@id"/>' (<value-of select="e:citation-format1(.)"/>) is tagged as a book reference with a chapter title, but there is not a first page and last page. Is this correct, or are these details missing?</assert>
      
    </rule></pattern><pattern id="ref-chapter-title-tests-pattern"><rule context="element-citation[@publication-type='book']/chapter-title" id="ref-chapter-title-tests">
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h6n1g-report-chapter-title-test" test="matches(.,' [Rr]eport |^[Rr]eport | [Rr]eport[\p{Zs}\p{P}]?$')" role="warning" id="report-chapter-title-test">[report-chapter-title-test] ref '<value-of select="ancestor::ref/@id"/>' is tagged as a book reference, but the chapter title is <value-of select="."/>. Should it be captured as a report type reference instead?</report>
      
    </rule></pattern><pattern id="ref-book-source-tests-pattern"><rule context="element-citation[@publication-type='book']/source" id="ref-book-source-tests">
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h1zta-report-book-source-test" test="matches(.,' [Rr]eport |^[Rr]eport | [Rr]eport[\p{Zs}\p{P}]?$')" role="warning" id="report-book-source-test">[report-book-source-test] ref '<value-of select="ancestor::ref/@id"/>' is tagged as a book reference, but the book title is <value-of select="."/>. Should it be captured as a report type reference instead?</report>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h4ccl-book-bracket-check" test="matches(.,'\[|\(|\)|\]')" role="warning" id="book-bracket-check">[book-bracket-check] Book ref '<value-of select="ancestor::ref/@id"/>' has a book name which contains brackets '<value-of select="."/>'. Is the content in the brackets is required?</report>
      
    </rule></pattern><pattern id="preprint-title-tests-pattern"><rule context="element-citation[@publication-type='preprint']/source" id="preprint-title-tests">
      <let name="lc" value="lower-case(.)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#not-rxiv-test" test="matches($lc,'biorxiv|arxiv|chemrxiv|medrxiv|osf preprints|peerj preprints|psyarxiv|paleorxiv|preprints|research square|zenodo|ecoevorxiv|africarxiv')" role="warning" id="not-rxiv-test">[not-rxiv-test] ref '<value-of select="ancestor::ref/@id"/>' is tagged as a preprint, but has a source <value-of select="."/>, which doesn't look like a preprint. Is it correct?</assert>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#biorxiv-test" test="matches($lc,'biorxiv') and not(. = 'bioRxiv')" role="error" id="biorxiv-test">[biorxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'bioRxiv'.</report>
      
      <report test="matches($lc,'biorxiv') and not(starts-with(parent::element-citation/pub-id[@pub-id-type='doi'][1],'10.1101/'))" role="warning" id="biorxiv-test-2">[biorxiv-test-2] ref '<value-of select="ancestor::ref/@id"/>' is captured as a <value-of select="."/> preprint, but it does not have a doi starting with the bioRxiv prefix, '10.1101/'. <value-of select="if (parent::element-citation/pub-id[@pub-id-type='doi']) then concat('The doi does not point to bioRxiv - https://doi.org/',parent::element-citation/pub-id[@pub-id-type='doi'][1]) else 'The doi is missing'"/>. Please check with eLife.</report>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#arxiv-test" test="matches($lc,'^arxiv$') and not(. = 'arXiv')" role="error" id="arxiv-test">[arxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'arXiv'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#chemrxiv-test" test="matches($lc,'chemrxiv') and not(. = 'ChemRxiv')" role="error" id="chemrxiv-test">[chemrxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'ChemRxiv'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#medrxiv-test" test="matches($lc,'medrxiv') and not(. = 'medRxiv')" role="error" id="medrxiv-test">[medrxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'medRxiv'.</report>
      
      <report test="matches($lc,'osf preprints') and not(. = 'OSF Preprints')" role="error" id="osfpreprints-test">[osfpreprints-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'OSF Preprints'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#peerjpreprints-test" test="matches($lc,'peerj preprints') and not(. = 'PeerJ Preprints')" role="error" id="peerjpreprints-test">[peerjpreprints-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PeerJ Preprints'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#psyarxiv-test" test="matches($lc,'psyarxiv') and not(. = 'PsyArXiv')" role="error" id="psyarxiv-test">[psyarxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PsyArXiv'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#paleorxiv-test" test="matches($lc,'paleorxiv') and not(. = 'PaleorXiv')" role="error" id="paleorxiv-test">[paleorxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PaleorXiv'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#preprint-replacement-character-presence" test="matches(.,'�')" role="error" id="preprint-replacement-character-presence">[preprint-replacement-character-presence] <name/> element contains the replacement character '�' which is unallowed - <value-of select="."/>.</report>
      
      
      <report see="https://elifeproduction.slab.com/posts/preprint-references-okxjjp9i#preprint-handbook-presence" test="contains(.,'handbook')" role="error" id="preprint-handbook-presence">[preprint-handbook-presence] Preprint ref '<value-of select="ancestor::ref/@id"/>' has a source '<value-of select="."/>'. Should it be captured as a book type reference instead?</report>
      
      <report test="matches($lc,'africarxiv') and not(. = 'AfricArXiv')" role="error" id="africarxiv-test">[africarxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'AfricArXiv'.</report>
      
      <report test="matches($lc,'ecoevorxiv') and not(. = 'EcoEvoRxiv')" role="error" id="ecoevorxiv-test">[ecoevorxiv-test] ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'EcoEvoRxiv'.</report>
    </rule></pattern><pattern id="website-tests-pattern"><rule context="element-citation[@publication-type='web']" id="website-tests">
      <let name="link" value="lower-case(ext-link[1])"/>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#github-web-test" test="contains($link,'github') and not(contains($link,'github.io'))" role="warning" id="github-web-test">[github-web-test] web ref '<value-of select="ancestor::ref/@id"/>' has a link which contains 'github', therefore it should almost certainly be captured as a software ref (unless it's a blog post by GitHub).</report>
      
      <report test="matches(.,'�')" role="error" id="webreplacement-character-presence">[webreplacement-character-presence] web citation contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report test="matches($link,'psyarxiv.org')" role="error" id="psyarxiv-web-test">[psyarxiv-web-test] web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, PsyArXiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'/arxiv.org')" role="error" id="arxiv-web-test">[arxiv-web-test] web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, arXiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'biorxiv.org')" role="warning" id="biorxiv-web-test">[biorxiv-web-test] web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, bioRxiv, therefore it should almost certainly be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'chemrxiv.org')" role="error" id="chemrxiv-web-test">[chemrxiv-web-test] web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, ChemRxiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'peerj.com/preprints/')" role="error" id="peerj-preprints-web-test">[peerj-preprints-web-test] web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, PeerJ Preprints, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'paleorxiv.org')" role="error" id="paleorxiv-web-test">[paleorxiv-web-test] web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, PaleorXiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
    </rule></pattern><pattern id="software-ref-tests-pattern"><rule context="element-citation[@publication-type='software']" id="software-ref-tests">
      <let name="lc" value="lower-case(data-title[1])"/>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#r-test-1" test="matches($lc,'r: a language and environment for statistical computing') and not(matches(person-group[@person-group-type='author']/collab[1],'^R Development Core Team$'))" role="error" id="R-test-1">[R-test-1] software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but it does not have one collab element containing 'R Development Core Team'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#r-test-2" test="matches($lc,'r: a language and environment for statistical computing') and (count(person-group[@person-group-type='author']/collab) != 1)" role="error" id="R-test-2">[R-test-2] software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but it has <value-of select="count(person-group[@person-group-type='author']/collab)"/> collab element(s).</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#r-test-3" test="matches($lc,'r: a language and environment for statistical computing') and (count((publisher-loc[text() = 'Vienna, Austria'])) != 1)" role="error" id="R-test-3">[R-test-3] software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but does not have a &lt;publisher-loc&gt;Vienna, Austria&lt;/publisher-loc&gt; element.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#r-test-4" test="matches($lc,'r: a language and environment for statistical computing') and not(matches(ext-link[1]/@xlink:href,'^http[s]?://www.[Rr]-project.org'))" role="error" id="R-test-4">[R-test-4] software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but does not have a 'http://www.r-project.org' type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#r-test-5" test="matches(lower-case(source[1]),'r: a language and environment for statistical computing')" role="error" id="R-test-5">[R-test-5] software ref '<value-of select="ancestor::ref/@id"/>' has a source '<value-of select="source"/>' but this is the data-title.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#r-test-6" test="matches(lower-case(publisher-name[1]),'r: a language and environment for statistical computing')" role="error" id="R-test-6">[R-test-6] software ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name '<value-of select="publisher-name"/>' but this is the data-title.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#r-test-7" test="matches($lc,'r: a language and environment for statistical computing') and (lower-case(publisher-name[1]) != 'r foundation for statistical computing')" role="error" id="R-test-7">[R-test-7] software ref '<value-of select="ancestor::ref/@id"/>' with the title '<value-of select="data-title"/>' must have a publisher-name element which contains 'R Foundation for Statistical Computing'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#software-replacement-character-presence" test="matches(.,'�')" role="error" id="software-replacement-character-presence">[software-replacement-character-presence] software reference contains the replacement character '�' which is unallowed - <value-of select="."/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#ref-software-test-1" test="source and publisher-name" role="error" id="ref-software-test-1">[ref-software-test-1] software ref '<value-of select="ancestor::ref/@id"/>' has both a source - <value-of select="source[1]"/> - and a publisher-name - <value-of select="publisher-name[1]"/> - which is incorrect. It should have either one or the other.</report>
      
      <assert see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#ref-software-test-2" test="source or publisher-name" role="error" id="ref-software-test-2">[ref-software-test-2] software ref '<value-of select="ancestor::ref/@id"/>' with the title - <value-of select="data-title"/> - must contain either one source element or one publisher-name element.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#ref-software-test-3" test="matches(lower-case(publisher-name[1]),'github|gitlab|bitbucket|sourceforge|figshare|^osf$|open science framework|zenodo|matlab')" role="error" id="ref-software-test-3">[ref-software-test-3] software ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name - <value-of select="publisher-name[1]"/>. Since this is a software source, it should be captured in a source element. Please move into the source field (rather than publisher).</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#ref-software-test-4" test="matches(lower-case(source[1]),'schr[öo]dinger|r foundation|rstudio ,? inc|mathworks| llc| ltd')" role="error" id="ref-software-test-4">[ref-software-test-4] software ref '<value-of select="ancestor::ref/@id"/>' has a source - <value-of select="source[1]"/>. Since this is a software publisher, it should be captured in a publisher-name element. Please move into the Software publisher field.</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#ref-software-test-5" test="(normalize-space(lower-case(source[1]))='github') and not(version)" role="warning" id="ref-software-test-5">[ref-software-test-5] <value-of select="source[1]"/> software ref (with id '<value-of select="ancestor::ref/@id"/>') does not have a version number. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#ref-software-test-6" test="matches(lower-case(source[1]),'github|gitlab|bitbucket|sourceforge|matlab') and not(ext-link)" role="error" id="ref-software-test-6">[ref-software-test-6] <value-of select="source[1]"/> software ref (with id '<value-of select="ancestor::ref/@id"/>') does not have a URL which is incorrect.</report>
      
      <report test="matches(lower-case(source[1]),'^osf$|open science framework|zenodo|figshare') and not(ext-link) and not(pub-id)" role="error" id="ref-software-test-7">[ref-software-test-7] <value-of select="source[1]"/> software ref (with id '<value-of select="ancestor::ref/@id"/>') does not have a URL or a DOI which is incorrect.</report>
    </rule></pattern><pattern id="data-ref-tests-pattern"><rule context="element-citation[@publication-type='data']" id="data-ref-tests">
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-geo-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/geo') and not(source[1]='NCBI Gene Expression Omnibus')" role="warning" id="data-geo-test">[data-geo-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/geo' type link, but the database name is not 'NCBI Gene Expression Omnibus' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-nucleotide-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/nuccore') and not(source[1]='NCBI GenBank') and not(source[1]='NCBI Nucleotide')" role="warning" id="data-nucleotide-test">[data-nucleotide-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/nuccore' type link, but the database name is not 'NCBI Nucleotide' or 'NCBI GenBank' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-bioproject-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/bioproject') and not(source[1]='NCBI BioProject')" role="warning" id="data-bioproject-test">[data-bioproject-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/bioproject' type link, but the database name is not 'NCBI BioProject' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-dbgap-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/gap') and not(source[1]='NCBI dbGaP')" role="warning" id="data-dbgap-test">[data-dbgap-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/gap' type link, but the database name is not 'NCBI dbGaP' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-popset-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/popset') and not(source[1]='NCBI PopSet')" role="warning" id="data-popset-test">[data-popset-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/popset' type link, but the database name is not 'NCBI PopSet' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-sra-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/sra') and not(source[1]='NCBI Sequence Read Archive')" role="warning" id="data-sra-test">[data-sra-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/sra' type link, but the database name is not 'NCBI Sequence Read Archive' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-biosample-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/biosample') and not(source[1]='NCBI BioSample')" role="warning" id="data-biosample-test">[data-biosample-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/biosample' type link, but the database name is not 'NCBI BioSample' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-protein-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/protein') and not(source[1]='NCBI Protein')" role="warning" id="data-protein-test">[data-protein-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/protein' type link, but the database name is not 'NCBI Protein' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-assembly-test" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/assembly') and not(source[1]='NCBI Assembly')" role="warning" id="data-assembly-test">[data-assembly-test] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/assembly' type link, but the database name is not 'NCBI Assembly' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-ncbi-test-1" test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/') and pub-id[@pub-id-type!='accession']" role="warning" id="data-ncbi-test-1">[data-ncbi-test-1] Data reference with an NCBI link '<value-of select="pub-id[1]/@xlink:href"/>' is not marked as an accession number, which is likely incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-ncbi-test-2" test="matches(lower-case(source[1]),'^ncbi gene expression omnibus$|^ncbi nucleotide$|^ncbi genbank$|^ncbi assembly$|^ncbi bioproject$|^ncbi dbgap$|^ncbi sequence read archive$|^ncbi popset$|^ncbi biosample$') and pub-id[@pub-id-type!='accession']" role="warning" id="data-ncbi-test-2">[data-ncbi-test-2] Data reference with the database source '<value-of select="source[1]"/>' is not marked as an accession number, which is very likely incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-dryad-test-1" test="(starts-with(pub-id[1][@pub-id-type='doi'],'10.5061/dryad') or starts-with(pub-id[1][@pub-id-type='doi'],'10.7272')) and (source[1]!='Dryad Digital Repository')" role="warning" id="data-dryad-test-1">[data-dryad-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a Dryad type doi <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the database name is not 'Dryad Digital Repository' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-dryad-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.5061/dryad') or starts-with(pub-id[1][@pub-id-type='doi'],'10.7272')) and (source[1]='Dryad Digital Repository')" role="warning" id="data-dryad-test-2">[data-dryad-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name  <value-of select="source[1]"/>, but no doi starting with '10.5061/dryad' or '10.7272', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-rcsbpbd-test-1" test="contains(pub-id[1]/@xlink:href,'www.rcsb.org') and not(pub-id[@pub-id-type='accession'])" role="warning" id="data-rcsbpbd-test-1">[data-rcsbpbd-test-1] Data reference with the title '<value-of select="data-title[1]"/>' links to RCSB Protein Data Bank (<value-of select="pub-id[1]/@xlink:href"/>). PDB datasets must (only) link to wwPDB using a DOI (e.g. https://doi.org/10.2210/pdb8QHN/pdb), not to RCSB Protein Data Bank or other Protein Data Banks.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-rcsbpbd-test-3" test="contains(pub-id[1]/@xlink:href,'www.rcsb.org') and pub-id[@pub-id-type='accession']" role="warning" id="data-rcsbpbd-test-3">[data-rcsbpbd-test-3] Data reference with the title '<value-of select="data-title[1]"/>' links to RCSB Protein Data Bank (<value-of select="pub-id[1]/@xlink:href"/>) with the accesion number (<value-of select="pub-id[@pub-id-type='accession'][1]"/>). PDB datasets must (only) link to wwPDB using a DOI (not to RCSB Protein Data Bank or other Protein Data Banks). Is the correct DOI to use instead: <value-of select="concat('https://doi.org/10.2210/pdb',replace(normalize-space(pub-id[@pub-id-type='accession'][1]),'^pdb_0000',''),'/pdb')"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-pbde-test-1" test="contains(pub-id[1]/@xlink:href,'ebi.ac.uk/pdbe/entry/pdb/') and not(pub-id[@pub-id-type='accession'])" role="error" id="data-pbde-test-1">[data-pbde-test-1] Data reference with the title '<value-of select="data-title[1]"/>' links to Protein Data Bank in Europe (<value-of select="pub-id[1]/@xlink:href"/>). PDB datasets must (only) link to wwPDB using a DOI (e.g. https://doi.org/10.2210/pdb8QHN/pdb), not to Protein Data Bank in Europe or other Protein Data Banks.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-pbde-test-2" test="contains(pub-id[1]/@xlink:href,'ebi.ac.uk/pdbe/entry/pdb/') and pub-id[@pub-id-type='accession']" role="error" id="data-pbde-test-2">[data-pbde-test-2] Data reference with the title '<value-of select="data-title[1]"/>' links to Protein Data Bank in Europe (<value-of select="pub-id[1]/@xlink:href"/>) with the accesion number (<value-of select="pub-id[@pub-id-type='accession'][1]"/>). PDB datasets must (only) link to wwPDB using a DOI (not to Protein Data Bank in Europe or other Protein Data Banks). Is the correct DOI to use instead: <value-of select="concat('https://doi.org/10.2210/pdb',replace(normalize-space(pub-id[@pub-id-type='accession'][1]),'^pdb_0000',''),'/pdb')"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-pbdj-test-1" test="contains(pub-id[1]/@xlink:href,'pdbj.org') and not(pub-id[@pub-id-type='accession'])" role="error" id="data-pbdj-test-1">[data-pbdj-test-1] Data reference with the title '<value-of select="data-title[1]"/>' links to Protein Data Bank Japan (<value-of select="pub-id[1]/@xlink:href"/>). PDB datasets must (only) link to wwPDB using a DOI (e.g. https://doi.org/10.2210/pdb8QHN/pdb), not to Protein Data Bank Japan or other Protein Data Banks.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-pbdj-test-2" test="contains(pub-id[1]/@xlink:href,'pdbj.org') and pub-id[@pub-id-type='accession']" role="error" id="data-pbdj-test-2">[data-pbdj-test-2] Data reference with the title '<value-of select="data-title[1]"/>' links to Protein Data Bank Japan (<value-of select="pub-id[1]/@xlink:href"/>) with the accesion number (<value-of select="pub-id[@pub-id-type='accession'][1]"/>). PDB datasets must (only) link to wwPDB using a DOI (not to Protein Data Bank Japan or other Protein Data Banks). Is the correct DOI to use instead: <value-of select="concat('https://doi.org/10.2210/pdb',replace(normalize-space(pub-id[@pub-id-type='accession'][1]),'^pdb_0000',''),'/pdb')"/></report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-wwpdb-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.2210') and (source[1]!='Worldwide Protein Data Bank')" role="warning" id="data-wwpdb-test-1">[data-wwpdb-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.2210' but the database name is not 'Worldwide Protein Data Bank' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-wwpdb-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.2210')) and (source[1]='Worldwide Protein Data Bank')" role="warning" id="data-wwpdb-test-2">[data-wwpdb-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.2210', which is incorrect.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-data-pdb-source-test-1" test="not(pub-id) and source[1][matches(normalize-space(lower-case(.)),'protein data bank|^(r[cs][cs]b\s)?pdb[je]?$') and lower-case(.)!='worldwide protein data bank']" role="error" id="final-data-pdb-source-test-1">[final-data-pdb-source-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a source that suggests it is a Protein data bank dataset - <value-of select="."/>. PDB datasets should have a DOI in the format https://doi.org/10.2210/pdb{accession-number}/pdb which links to the entry in the Worldwide Protein Data Bank. If this information isn't present, please query the author.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-emdb-test-1" test="not(contains(pub-id[1]/@xlink:href,'empiar')) and matches(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb|www.ebi.ac.uk/pdbe/entry/emdb') and not(source[1]='Electron Microscopy Data Bank')" role="warning" id="data-emdb-test-1">[data-emdb-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.ebi.ac.uk/pdbe/emdb' type link, but the database name is not 'Electron Microscopy Data Bank' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-emdb-test-3" test="matches(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb|www.ebi.ac.uk/pdbe/entry/emdb') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-emdb-test-3">[data-emdb-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has a EMDB 'http://www.ebi.ac.uk/pdbe/emdb' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-empiar-test-1" test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb/empiar/') and not(source[1]='Electron Microscopy Public Image Archive')" role="warning" id="data-empiar-test-1">[data-empiar-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.ebi.ac.uk/pdbe/emdb/empiar' type link, but the database name is not 'Electron Microscopy Public Image Archive' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-arrayexpress-test-1" test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/arrayexpress') and not(source[1]='ArrayExpress')" role="warning" id="data-arrayexpress-test-1">[data-arrayexpress-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.ebi.ac.uk/arrayexpress' type link, but the database name is not 'ArrayExpress' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-arrayexpress-test-3" test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/arrayexpress') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-arrayexpress-test-3">[data-arrayexpress-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has an ArrayExpress 'www.ebi.ac.uk/arrayexpress' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-pride-test-1" test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pride') and not(source[1]='PRIDE')" role="warning" id="data-pride-test-1">[data-pride-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.ebi.ac.uk/pride' type link, but the database name is not 'PRIDE' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-pride-test-3" test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pride') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-pride-test-3">[data-pride-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has a PRIDE 'www.ebi.ac.uk/pride' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-zenodo-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.5281/zenodo') and (source[1]!='Zenodo')" role="warning" id="data-zenodo-test-1">[data-zenodo-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.5281/zenodo' but the database name is not 'Zenodo' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-zenodo-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.5281/zenodo')) and (source[1]='Zenodo')" role="warning" id="data-zenodo-test-2">[data-zenodo-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name  <value-of select="source[1]"/>, but no doi starting with '10.5281/zenodo', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-osf-test-1" test="matches(pub-id[1]/@xlink:href,'^http[s]?://osf.io') and not(source[1]='Open Science Framework')" role="warning" id="data-osf-test-1">[data-osf-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://osf.io' type link, but the database name is not 'Open Science Framework' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-osf-test-3" test="matches(pub-id[1]/@xlink:href,'^http[s]?://osf.io') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-osf-test-3">[data-osf-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has an OSF 'https://osf.io' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-osf-test-4" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17605/OSF') and (source[1]!='Open Science Framework')" role="warning" id="data-osf-test-4">[data-osf-test-4] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.17605/OSF' but the database name is not 'Open Science Framework' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-figshare-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.6084/m9.figshare') and (source[1]!='figshare')" role="warning" id="data-figshare-test-1">[data-figshare-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.6084/m9.figshare' but the database name is not 'figshare' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-figshare-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.6084/m9.figshare')) and (source[1]='figshare')" role="warning" id="data-figshare-test-2">[data-figshare-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.6084/m9.figshare' - is this correct? Figshare sometimes host for other organisations (example http://doi.org/10.1184/R1/9963566), so this may be fine.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-proteomexchange-test-1" test="contains(pub-id[1]/@xlink:href,'proteomecentral.proteomexchange.org/') and not(source[1]='ProteomeXchange')" role="warning" id="data-proteomexchange-test-1">[data-proteomexchange-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://proteomecentral.proteomexchange.org/' type link, but the database name is not 'ProteomeXchange' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-proteomexchange-test-3" test="contains(pub-id[1]/@xlink:href,'proteomecentral.proteomexchange.org/') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-proteomexchange-test-3">[data-proteomexchange-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has a ProteomeXchange 'http://proteomecentral.proteomexchange.org/' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-openneuro-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.18112/openneuro') and (source[1]!='OpenNeuro')" role="warning" id="data-openneuro-test-1">[data-openneuro-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.18112/openneuro' but the database name is not 'OpenNeuro' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-openneuro-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.18112/openneuro')) and not(contains(pub-id[1]/@xlink:href,'openneuro.org/datasets')) and (source[1]='OpenNeuro')" role="warning" id="data-openneuro-test-2">[data-openneuro-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.18112/openneuro' or 'openneuro.org/datasets' type link, which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-synapse-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7303/syn') and (source[1]!='Synapse')" role="warning" id="data-synapse-test-1">[data-synapse-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.7303/syn' but the database name is not 'Synapse' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-synapse-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.7303/syn')) and (source[1]='Synapse')" role="warning" id="data-synapse-test-2">[data-synapse-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.7303/syn', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-bmrb-test-1" test="contains(pub-id[1]/@xlink:href,'www.bmrb.wisc.edu/data_library/summary') and not(source[1]='Biological Magnetic Resonance Data Bank')" role="warning" id="data-bmrb-test-1">[data-bmrb-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.bmrb.wisc.edu/data_library/summary' type link, but the database name is not 'Biological Magnetic Resonance Data Bank' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-bmrb-test-3" test="contains(pub-id[1]/@xlink:href,'www.bmrb.wisc.edu/data_library/summary') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-bmrb-test-3">[data-bmrb-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has a BMRB 'www.bmrb.wisc.edu/data_library/summary' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-morphdbase-test-1" test="contains(pub-id[1]/@xlink:href,'www.morphdbase.de') and not(source[1]='Morph D Base')" role="warning" id="data-morphdbase-test-1">[data-morphdbase-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.morphdbase.de' type link, but the database name is not 'Morph D Base' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-morphdbase-test-3" test="contains(pub-id[1]/@xlink:href,'www.morphdbase.de') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-morphdbase-test-3">[data-morphdbase-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has a Morph D Base 'www.morphdbase.de' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-mendeley-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17632') and (source[1]!='Mendeley Data')" role="warning" id="data-mendeley-test-1">[data-mendeley-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.17632' but the database name is not 'Mendeley Data' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-mendeley-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.17632')) and (source[1]='Mendeley Data')" role="warning" id="data-mendeley-test-2">[data-mendeley-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.17632', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-edatashare-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7488') and (source[1]!='Edinburgh DataShare')" role="warning" id="data-edatashare-test-1">[data-edatashare-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.7488' but the database name is not 'Edinburgh DataShare' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-edatashare-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.7488')) and (source[1]='Edinburgh DataShare')" role="warning" id="data-edatashare-test-2">[data-edatashare-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.7488', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-eth-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.3929') and (source[1]!='ETH Library research collection')" role="warning" id="data-eth-test-1">[data-eth-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.3929' but the database name is not 'ETH Library research collection' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-eth-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.3929')) and (source[1]='ETH Library research collection')" role="warning" id="data-eth-test-2">[data-eth-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.3929', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-crcns-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.6080') and (source[1]!='Collaborative Research in Computational Neuroscience')" role="warning" id="data-crcns-test-1">[data-crcns-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.6080' but the database name is not 'Collaborative Research in Computational Neuroscience' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-crcns-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.6080')) and (source[1]='Collaborative Research in Computational Neuroscience')" role="warning" id="data-crcns-test-2">[data-crcns-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.6080', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-morphosource-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17602') and (source[1]!='MorphoSource')" role="warning" id="data-morphosource-test-1">[data-morphosource-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.17602' but the database name is not 'MorphoSource' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-morphosource-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.17602')) and (source[1]='MorphoSource')" role="warning" id="data-morphosource-test-2">[data-morphosource-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.17602', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-neurovault-test-1" test="contains(pub-id[1]/@xlink:href,'neurovault.org/collections') and not(source[1]='NeuroVault')" role="warning" id="data-neurovault-test-1">[data-neurovault-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'neurovault.org/collections' type link, but the database name is not 'NeuroVault' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-neurovault-test-3" test="contains(pub-id[1]/@xlink:href,'neurovault.org/collections') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-neurovault-test-3">[data-neurovault-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has a NeuroVault 'neurovault.org/collections' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-sbgdb-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.15785/SBGRID') and (source[1]!='SBGrid Data Bank')" role="warning" id="data-sbgdb-test-1">[data-sbgdb-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.15785/SBGRID' but the database name is not 'SBGrid Data Bank' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-sbgdb-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.15785/SBGRID')) and (source[1]='SBGrid Data Bank')" role="warning" id="data-sbgdb-test-2">[data-sbgdb-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.15785/SBGRID', which is likely incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-harvard-dataverse-test-1" test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7910') and (source[1]!='Harvard Dataverse')" role="warning" id="data-harvard-dataverse-test-1">[data-harvard-dataverse-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.7910' but the database name is not 'Harvard Dataverse' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-harvard-dataverse-test-2" test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.7910')) and (source[1]='Harvard Dataverse')" role="warning" id="data-harvard-dataverse-test-2">[data-harvard-dataverse-test-2] Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.7910', which is likely incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-encode-test-1" test="contains(pub-id[1]/@xlink:href,'www.encodeproject.org') and not(source[1]='ENCODE')" role="warning" id="data-encode-test-1">[data-encode-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.encodeproject.org' type link, but the database name is not 'ENCODE' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-encode-test-3" test="contains(pub-id[1]/@xlink:href,'www.encodeproject.org') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-encode-test-3">[data-encode-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has an ENCODE 'www.encodeproject.org' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-emdr-test-1" test="contains(pub-id[1]/@xlink:href,'www.emdataresource.org') and not(source[1]='EMDataResource')" role="warning" id="data-emdr-test-1">[data-emdr-test-1] Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.emdataresource.org' type link, but the database name is not 'EMDataResource' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-emdr-test-3" test="contains(pub-id[1]/@xlink:href,'www.emdataresource.org') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" role="warning" id="data-emdr-test-3">[data-emdr-test-3] Data reference with the title '<value-of select="data-title[1]"/>' has an EMDataResource 'www.emdataresource.org' type link, but is not marked as an accession type link.</report>
      
    </rule></pattern><pattern id="ncbi-pub-id-checks-pattern"><rule context="element-citation[@publication-type='data']/pub-id[@pub-id-type='accession' and contains(@xlink:href,'.ncbi.nlm.nih.gov')]" id="ncbi-pub-id-checks">
      
      <assert test="contains(lower-case(@xlink:href),lower-case(.))" role="warning" id="ncbi-pub-id-1">[ncbi-pub-id-1] Dataset reference is an NCBI dataset, but the link for the dataset - <value-of select="@xlink:href"/> - does not contain the accession number - <value-of select="."/> - which is particularly unusual, and its likely that one of these is incorrect.</assert>
      
    </rule></pattern><pattern id="publisher-name-tests-pattern"><rule context="element-citation/publisher-name" id="publisher-name-tests">
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#publisher-name-colon" test="matches(.,':')" role="warning" id="publisher-name-colon">[publisher-name-colon] ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing a colon - <value-of select="."/>. Should the text preceding the colon instead be captured as publisher-loc?</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#publisher-name-inc" test="matches(.,'[Ii]nc\.')" role="warning" id="publisher-name-inc">[publisher-name-inc] ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing the text 'Inc.' Should the fullstop be removed? <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#pub-name-replacement-character-presence" test="matches(.,'�')" role="error" id="pub-name-replacement-character-presence">[pub-name-replacement-character-presence] <name/> contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#pub-name-newspaper" test="matches(lower-case(.),'guardian|the independent|times|post|news')" role="warning" id="pub-name-newspaper">[pub-name-newspaper] <name/> contains the text 'guardian', 'independent', 'times' or 'post' - <value-of select="."/> - is it a newspaper reference? If so, it should be captured as a web or a periodical reference.</report>
    </rule></pattern><pattern id="ref-name-tests-pattern"><rule context="element-citation//name" id="ref-name-tests">
      <let name="type" value="ancestor::person-group[1]/@person-group-type"/>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#author-test-1" test="matches(.,'[Aa]uthor')" role="warning" id="author-test-1">[author-test-1] name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Author'. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#author-test-2" test="matches(.,'[Ed]itor')" role="warning" id="author-test-2">[author-test-2] name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Editor'. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#author-test-3" test="matches(.,'[Pp]ress')" role="warning" id="author-test-3">[author-test-3] name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Press'. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#all-caps-surname" test="matches(surname[1],'^[A-Z]*$')" role="warning" id="all-caps-surname">[all-caps-surname] surname in ref '<value-of select="ancestor::ref/@id"/>' is composed of only capitalised letters - <value-of select="surname[1]"/>. Should this be captured as a collab? If not, Should it be - <value-of select="concat(substring(surname[1],1,1),lower-case(substring(surname[1],2)))"/>?</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#surname-number-check" test="matches(.,'[0-9]')" role="warning" id="surname-number-check">[surname-number-check] name in ref '<value-of select="ancestor::ref/@id"/>' contains numbers - <value-of select="."/>. Should this be captured as a collab?</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#surname-ellipsis-check" test="matches(surname[1],'^\p{Zs}*?…|^\p{Zs}*?\.\p{Zs}?\.\p{Zs}?\.')" role="error" id="surname-ellipsis-check">[surname-ellipsis-check] surname in ref '<value-of select="ancestor::ref/@id"/>' begins with an ellipsis which is wrong - <value-of select="surname"/>. Are there preceding authors missing from the list?</report>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#surname-count" test="count(surname) = 1" role="error" id="surname-count">[surname-count] ref '<value-of select="ancestor::ref/@id"/>' has an <value-of select="$type"/> with <value-of select="count(surname)"/> surnames - <value-of select="."/> - which is incorrect.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#given-names-count" test="count(given-names) gt 1" role="error" id="given-names-count">[given-names-count] ref '<value-of select="ancestor::ref/@id"/>' has an <value-of select="$type"/> with <value-of select="count(given-names)"/> given-names - <value-of select="."/> - which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#given-names-count-2" test="count(given-names) lt 1" role="warning" id="given-names-count-2">[given-names-count-2] ref '<value-of select="ancestor::ref/@id"/>' has an <value-of select="$type"/> with <value-of select="count(given-names)"/> given-names - <value-of select="."/> - is this incorrect?</report>
    </rule></pattern><pattern id="page-conformity-pattern"><rule context="element-citation[(@publication-type='journal') and (fpage or lpage)]" id="page-conformity">
      <let name="cite" value="e:citation-format1(.)"/>
      
      <report test="matches(lower-case(source[1]),'plos|^elife$|^mbio$')" role="error" id="online-journal-w-page">[online-journal-w-page] <value-of select="$cite"/> is a <value-of select="source"/> article, but has a page number, which is incorrect.</report>
      
    </rule></pattern><pattern id="isbn-conformity-pattern"><rule context="element-citation/pub-id[@pub-id-type='isbn']" id="isbn-conformity">
      <let name="t" value="translate(.,'-','')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#isbn-conformity-test" test="e:is-valid-isbn(.)" role="error" id="isbn-conformity-test">[isbn-conformity-test] pub-id contains an invalid ISBN - '<value-of select="."/>'. Should it be captured as another type of pub-id?</assert>
    </rule></pattern><pattern id="isbn-conformity-2-pattern"><rule context="isbn" id="isbn-conformity-2">
      <let name="t" value="translate(.,'-','')"/>
      
      <assert test="e:is-valid-isbn(.)" role="error" id="isbn-conformity-test-2">[isbn-conformity-test-2] isbn contains an invalid ISBN - '<value-of select="."/>'. Should it be captured as another type of pub-id?</assert>
    </rule></pattern><pattern id="data-availability-statement-pattern"><rule context="sec[@sec-type='data-availability']/p[1]" id="data-availability-statement">
      
      <assert see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-sentence-conformity" test="matches(.,'\.$|\?$')" role="error" id="das-sentence-conformity">[das-sentence-conformity] The Data Availability Statement must end with a full stop.</assert>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-dryad-conformity" test="matches(.,'[Dd]ryad') and          (not(parent::sec//element-citation[contains(source[1],'Dryad') or pub-id[@pub-id-type='doi' and (contains(.,'10.7272') or contains(.,'10.5061/dryad'))]]))         and not(ancestor::back//ref-list/ref[element-citation[@publication-type='data' and (contains(source[1],'Dryad') or pub-id[@pub-id-type='doi' and (contains(.,'10.7272') or contains(.,'10.5061/dryad'))])]]/@id = xref[@ref-type='bibr']/@rid)" role="error" id="final-das-dryad-conformity">[final-das-dryad-conformity] Data Availability Statement contains the word Dryad, but there is no data citation in the dataset section with a dryad doi and/or database name containing 'Dryad'.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-supplemental-conformity" test="matches(.,'[Ss]upplemental [Ff]igure')" role="warning" id="das-supplemental-conformity">[das-supplemental-conformity] Data Availability Statement contains the phrase 'supplemental figure'. This will almost certainly need updating to account for eLife's figure labelling.</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-request-conformity-1" test="matches(.,'[Rr]equest')" role="warning" id="das-request-conformity-1">[das-request-conformity-1] Data Availability Statement contains the phrase 'request'. Does it state data is available upon request, and if so, has this been approved by editorial?</report>
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#das-doi-conformity-1" test="matches(.,'10\.\d{4,9}/[-._;()/:A-Za-z0-9&lt;&gt;\+#&amp;`~–−]+$') and not(matches(.,'http[s]?://doi.org/'))" role="error" id="das-doi-conformity-1">[das-doi-conformity-1] Data Availability Statement contains a doi, but it does not contain the 'https://doi.org/' proxy. All dois should be updated to include a full 'https://doi.org/...' type link.</report>
      
    </rule></pattern><pattern id="data-availability-version-2-pattern"><rule context="article[e:get-version(.)!='1']//sec[@sec-type='data-availability']" id="data-availability-version-2">
      
      <report test="descendant::element-citation" role="error" id="das-no-refs">[das-no-refs] Version 2 xml cannot have references in the data availability section. Data references must instead be cited from the data availability section.</report>
      
      <assert test="count(p) = 1" role="error" id="das-p-count">[das-p-count] Version 2 xml cannot have more than one p element in the data availability section.</assert>
      
    </rule></pattern><pattern id="data-availability-child-version-2-pattern"><rule context="article[e:get-version(.)!='1']//sec[@sec-type='data-availability']/*" id="data-availability-child-version-2">
      
      <assert test="name()=('p','title')" role="error" id="das-child-conformance">[das-child-conformance] Only p and title elements are permitted within the data availability section. In version 2 XML <value-of select="name()"/> is not permitted.</assert>
      
    </rule></pattern><pattern id="data-availability-p-pattern"><rule context="sec[@sec-type='data-availability']/p[not(*)]" id="data-availability-p">
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#final-das-p-conformity-1" test="normalize-space(replace(.,' ',''))=''" role="error" id="final-das-p-conformity-1">[final-das-p-conformity-1] p element in data availability section contains no content. It must be removed.</report>
      
    </rule></pattern><pattern id="data-availability-generated-p-pattern"><rule context="article[e:get-version(.)='1']//sec[@sec-type='data-availability']/p[position() gt 1 and not(element-citation) and following-sibling::p[element-citation[@specific-use='isSupplementedBy']]]" id="data-availability-generated-p">
      <let name="ref-count" value="count(ancestor::sec[@sec-type='data-availability']//element-citation[@specific-use='isSupplementedBy'])"/>
      
      <report test="$ref-count = 1 and not(matches(.,'^The following dataset was generated:\s?$'))" role="error" id="das-generated-p-1">[das-generated-p-1] p element before generated datasets in data availability sections that contain 1 generated dataset should contain 'The following dataset was generated:', but this one contains '<value-of select="."/>'.</report>
      
      <report test="($ref-count gt 1) and not(matches(.,'^The following datasets were generated:\s?$'))" role="error" id="das-generated-p-2">[das-generated-p-2] p element before generated datasets in data availability sections that contain more than 1 generated dataset should contain 'The following datasets were generated:', but this one contains '<value-of select="."/>'.</report>
      
    </rule></pattern><pattern id="data-availability-used-p-pattern"><rule context="article[e:get-version(.)='1']//sec[@sec-type='data-availability']/p[position() gt 1 and not(element-citation) and not(following-sibling::p[element-citation[@specific-use='isSupplementedBy']]) and following-sibling::p[element-citation[@specific-use='references']]]" id="data-availability-used-p">
      <let name="ref-count" value="count(ancestor::sec[@sec-type='data-availability']//element-citation[@specific-use='references'])"/>
      
      <report test="$ref-count = 1 and not(matches(.,'^The following previously published dataset was used:\s?$'))" role="error" id="das-used-p-1">[das-used-p-1] p element before used datasets in data availability sections that contain 1 used dataset should contain 'The following previously published dataset was used:', but this one contains '<value-of select="."/>'.</report>
      
      <report test="($ref-count gt 1) and not(matches(.,'^The following previously published datasets were used:\s?$'))" role="error" id="das-used-p-2">[das-used-p-2] p element before used datasets in data availability sections that contain more than 1 used dataset should contain 'The following previously published datasets were used:', but this one contains '<value-of select="."/>'.</report>
      
    </rule></pattern><pattern id="data-availability-extra-p-pattern"><rule context="sec[@sec-type='data-availability' and not(descendant::element-citation)]/p" id="data-availability-extra-p">
      
      <report test="preceding-sibling::p" role="warning" id="das-extra-p">[das-extra-p] Is this extra p element in the data availability section required? There are no dataset references within the section.</report>
      
    </rule></pattern><pattern id="ethics-info-pattern"><rule context="fn-group[@content-type='ethics-information']/fn" id="ethics-info">
      
      <assert see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-info-conformity" test="matches(replace(normalize-space(.),'&quot;',''),'\.$|\?$')" role="error" id="ethics-info-conformity">[ethics-info-conformity] The ethics statement must end with a full stop.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/ethics-se0ia1cs#ethics-info-supplemental-conformity" test="matches(.,'[Ss]upplemental [Ffigure]')" role="warning" id="ethics-info-supplemental-conformity">[ethics-info-supplemental-conformity] Ethics statement contains the phrase 'supplemental figure'. This will almost certainly need updating to account for eLife's figure labelling.</report>
      
    </rule></pattern><pattern id="sec-title-conformity-pattern"><rule context="sec/title" id="sec-title-conformity">
      <let name="free-text" value="replace(         normalize-space(string-join(for $x in self::*/text() return $x,''))         ,' ','')"/>
      <let name="no-link-text" value="translate(         normalize-space(string-join(for $x in self::*/(*[not(name()='xref')]|text()) return $x,''))         ,' ?.',' ')"/>
      <let name="new-org-regex" value="string-join(for $x in tokenize($org-regex,'\|') return concat('^',$x,'$'),'|')"/>
      
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-list-check" test="matches(.,'^\p{Zs}?[A-Za-z]{1,3}\)|^\p{Zs}?\([A-Za-z]{1,3}')" role="warning" id="sec-title-list-check">[sec-title-list-check] Section title might start with a list indicator - '<value-of select="."/>'. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-appendix-check" test="matches(.,'^[Aa]ppendix')" role="warning" id="sec-title-appendix-check">[sec-title-appendix-check] Section title contains the word appendix - '<value-of select="."/>'. Should it be captured as an appendix?</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-appendix-check-2" test="ancestor::body and matches(.,'^[Ss]upplementary |^[Ss]upplemental ')" role="warning" id="sec-title-appendix-check-2">[sec-title-appendix-check-2] Should the section titled '<value-of select="."/>' be captured as an appendix?</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hp09b-sec-title-abbr-check" test="matches(.,'^[Aa]bbreviation[s]?')" role="warning" id="sec-title-abbr-check">[sec-title-abbr-check] Section title contains the word abbreviation - '<value-of select="."/>'. Is it an abbreviation section? eLife house style is to define abbreviations in the text when they are first mentioned.</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-content-mandate" test="normalize-space(.)=''" role="error" id="sec-title-content-mandate">[sec-title-content-mandate] Section title must not be empty.</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-full-stop" test="matches(replace(.,' ',' '),'\.[\p{Zs}]*$')" role="warning" id="sec-title-full-stop">[sec-title-full-stop] Section title ends with full stop, which is very likely to be incorrect - <value-of select="."/></report>
      
      <report test="matches(.,'\p{Zs}$')" role="error" id="sec-title-space">[sec-title-space] Section title ends with space(s). Please remove the space '<value-of select="."/>'</report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-bold" test="(count(*) = 1) and child::bold and ($free-text='')" role="error" id="sec-title-bold">[sec-title-bold] All section title content is captured in bold. This is incorrect - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-underline" test="(count(*) = 1) and child::underline and ($free-text='')" role="error" id="sec-title-underline">[sec-title-underline] All section title content is captured in underline. This is incorrect - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-italic" test="(count(*) = 1) and child::italic and ($free-text='') and not(matches(normalize-space(lower-case(.)),$new-org-regex))" role="warning" id="sec-title-italic">[sec-title-italic] All section title content is captured in italics. Is this incorrect? If it is just a species name, then this is likely to be fine - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-dna" test="matches(upper-case($no-link-text),'^DNA | DNA | DNA$') and not(matches($no-link-text,'^DNA | DNA | DNA$'))" role="warning" id="sec-title-dna">[sec-title-dna] Section title contains the phrase DNA, but it is not in all caps - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-rna" test="matches(upper-case($no-link-text),'^RNA | RNA | RNA$') and not(matches($no-link-text,'^RNA | RNA | RNA$'))" role="warning" id="sec-title-rna">[sec-title-rna] Section title contains the phrase RNA, but it is not in all caps - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-dimension" test="matches($no-link-text,'^[1-4]d | [1-4]d | [1-4]d$')" role="warning" id="sec-title-dimension">[sec-title-dimension] Section title contains lowercase abbreviation for dimension, when this should always be uppercase 'D' - <value-of select="."/></report>
      
      <!-- AIDS not included due to other meaning/use -->
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#sec-title-hiv" test="matches(upper-case($no-link-text),'^HIV | HIV | HIV') and not(matches($no-link-text,'^HIV | HIV | HIV'))" role="warning" id="sec-title-hiv">[sec-title-hiv] Section title contains the word HIV, but it is not in all caps - <value-of select="."/></report>
      
      <report see="https://elifeproduction.slab.com/posts/acknowledgements-49wvb1xt#h9cd3-sec-title-ack" test="matches(.,'^[\p{Zs}\p{P}]*[Aa][ck][ck]n?ow[le][le]?[dg][dg]?e?ments?[\p{Zs}\p{P}]*$')" role="error" id="sec-title-ack">[sec-title-ack] Section title indicates that it is an acknowledgements section - <value-of select="."/>. Acknowledgements must be tagged as an &lt;ack&gt; element in the back of the article.</report>
      
    </rule></pattern><pattern id="abstract-house-tests-pattern"><rule context="abstract[not(@*)]" id="abstract-house-tests">
      <let name="subj" value="parent::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#xref-bibr-presence" test="descendant::xref[@ref-type='bibr']" role="warning" id="xref-bibr-presence">[xref-bibr-presence] Abstract contains a citation - '<value-of select="descendant::xref[@ref-type='bibr'][1]"/>' - which isn't usually allowed. Check that this is correct.</report>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#final-res-comm-test" test="($subj = 'Research Communication') and (not(matches(self::*/descendant::p[2],'^Editorial note')))" role="error" id="final-res-comm-test">[final-res-comm-test] '<value-of select="$subj"/>' has only one paragraph in its abstract or the second paragraph does not begin with 'Editorial note', which is incorrect.</report>
     
      <report see="https://elifeproduction.slab.com/posts/abstracts-digests-and-impact-statements-tiau2k6x#res-art-test" test="(count(p) &gt; 1) and ($subj = 'Research Article')" role="warning" id="res-art-test">[res-art-test] '<value-of select="$subj"/>' has more than one paragraph in its abstract, is this correct?</report>
    </rule></pattern><pattern id="KRT-xref-tests-pattern"><rule context="table-wrap[@id='keyresource']//xref[@ref-type='bibr']" id="KRT-xref-tests">
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#xref-column-test" test="(count(ancestor::*:td/preceding-sibling::td) = 0) or (count(ancestor::*:td/preceding-sibling::td) = 1) or (count(ancestor::*:td/preceding-sibling::td) = 3)" role="warning" id="xref-column-test">[xref-column-test] '<value-of select="."/>' citation is in a column in the Key Resources Table which usually does not include references. Is it correct?</report>
      
    </rule></pattern><pattern id="KRT-check-pattern"><rule context="article" id="KRT-check">
      <let name="subj" value="descendant::subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="methods" value="('model', 'methods', 'materials|methods')"/>
      
      <report test="($subj = 'Research Article') and not(descendant::table-wrap[@id = 'keyresource']) and (descendant::sec[@sec-type=$methods]/*[2]/local-name()='table-wrap')" role="warning" id="KRT-presence">[KRT-presence] '<value-of select="$subj"/>' does not have a key resources table, but the <value-of select="descendant::sec[@sec-type=$methods]/title"/> starts with a table. Should this table be a key resources table?</report>
      
      <report test="($subj = ('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance')) and matches(lower-case(.),'key\sresources?\stable') and         not(descendant::table-wrap[contains(@id,'keyresource')]) and         not(descendant::supplementary-material[contains(lower-case(caption[1]/title[1]),'key resource')])" role="warning" id="krt-missing">[krt-missing] This is a '<value-of select="$subj"/>', it mentions a key resources table, but it does not have a key resources table (or a supplementary file containing a KR table). Should it have one?</report>
      
    </rule></pattern><pattern id="KRT-td-checks-pattern"><rule context="table-wrap[@id='keyresource']//td" id="KRT-td-checks">
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#doi-link-test" test="matches(.,'10\.\d{4,9}/') and (count(ext-link[contains(@xlink:href,'doi.org')]) = 0)" role="error" id="doi-link-test">[doi-link-test] td element containing - '<value-of select="."/>' - looks like it contains a doi, but it contains no link with 'doi.org', which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#PMID-link-test" test="matches(.,'[Pp][Mm][Ii][Dd][:]?\p{Zs}?[0-9][0-9][0-9][0-9]+') and (count(ext-link[contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed/') or contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov/')]) = 0)" role="error" id="PMID-link-test">[PMID-link-test] td element containing - '<value-of select="."/>' - looks like it contains a PMID, but it contains no link pointing to PubMed, which is incorrect.</report>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#PMCID-link-test" test="matches(.,'PMCID[:]?\p{Zs}?PMC[0-9][0-9][0-9]+') and (count(ext-link[contains(@xlink:href,'www.ncbi.nlm.nih.gov/pmc')]) = 0)" role="error" id="PMCID-link-test">[PMCID-link-test] td element containing - '<value-of select="."/>' - looks like it contains a PMCID, but it contains no link pointing to PMC, which is incorrect.</report>
      
      <report test="matches(lower-case(.),'addgene\p{Zs}?#?\p{Zs}?\d') and not(ext-link[matches(@xlink:href,'identifiers\.org/RRID:.*')])" role="warning" id="addgene-test">[addgene-test] td element containing - '<value-of select="."/>' - looks like it contains an addgene number. Should this be changed to an RRID with a https://identifiers.org/RRID:addgene_{number} link?</report>
      
    </rule></pattern><pattern id="colour-table-pattern"><rule context="table-wrap" id="colour-table">
      <let name="allowed-values" value="('background-color: #90CAF9;','background-color: #C5E1A5;','background-color: #FFB74D;','background-color: #FFF176;','background-color: #9E86C9;','background-color: #E57373;','background-color: #F48FB1;','background-color: #E6E6E6;')"/>
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#colour-check-table" test="descendant::th[@style=$allowed-values] or descendant::td[@style=$allowed-values]" role="warning" id="colour-check-table">[colour-check-table] <value-of select="if (label) then label else 'table'"/> has colour background. Is this correct and appropriate?</report>
    </rule></pattern><pattern id="colour-table-2-pattern"><rule context="th[@style]|td[@style]" id="colour-table-2">
      <let name="allowed-values" value="('background-color: #90CAF9;','background-color: #C5E1A5;','background-color: #FFB74D;','background-color: #FFF176;','background-color: #9E86C9;','background-color: #E57373;','background-color: #F48FB1;','background-color: #E6E6E6;')"/>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/tables-3nehcouh#final-colour-check-table-2" test="@style=($allowed-values)" role="error" id="final-colour-check-table-2">[final-colour-check-table-2] <name/> element contanining '<value-of select="."/>' has an @style with an unallowed value - '<value-of select="@style"/>'. The only allowed values are <value-of select="string-join($allowed-values,', ')"/> for blue, green orange, yellow, purple, red, pink and grey respectively.</assert>
    </rule></pattern><pattern id="colour-styled-content-pattern"><rule context="article//body//named-content[not(@content-type='sequence')]|article//back//named-content[not(@content-type='sequence')]" id="colour-styled-content">
      <let name="parent" value="parent::*/local-name()"/>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hqmsd-final-colour-styled-content-check" test="." role="error" id="final-colour-styled-content-check">[final-colour-styled-content-check] '<value-of select="."/>' - <value-of select="$parent"/> element contains a named content element. This is not allowed for coloured text. Please ensure that &lt;styled-content&gt; is used with the three permitted colours for text - red, blue and purple.</report>
    </rule></pattern><pattern id="colour-styled-content-v2-pattern"><rule context="article//styled-content" id="colour-styled-content-v2">
      <let name="allowed-values" value="('color: #366BFB;','color: #9C27B0;','color: #D50000;')"/>
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h3819-colour-styled-content-flag" test="@style = $allowed-values" role="warning" id="colour-styled-content-flag">[colour-styled-content-flag] <value-of select="."/> has colour formatting. Is this correct? Preceding text - <value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/></report>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h7uzr-final-styled-content-style-check" test="@style = $allowed-values" role="error" id="final-styled-content-style-check">[final-styled-content-style-check] <value-of select="."/> - text in <value-of select="parent::*/name()"/> element is captured in a &lt;styled-content style="<value-of select="@style"/>"&gt;. The only allowed values for the @style are <value-of select="string-join($allowed-values,', ')"/>.</assert>
    </rule></pattern><pattern id="math-colour-tests-pattern"><rule context="mml:*[@mathcolor]" id="math-colour-tests">
      <let name="allowed-values" value="('red','blue','purple')"/>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#final-mathcolor-test-1" test="@mathcolor = $allowed-values" role="error" id="final-mathcolor-test-1">[final-mathcolor-test-1] math (<value-of select="name()"/> element) containing '<value-of select="."/>' has a color style which is not red, blue or purple - '<value-of select="@mathcolor"/>' - which is not allowed. Only 'red', 'blue' and 'purple' are allowed.</assert>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#mathcolor-test-2" test="@mathcolor = $allowed-values" role="warning" id="mathcolor-test-2">[mathcolor-test-2] math (<value-of select="name()"/> element) containing '<value-of select="."/>' has <value-of select="@mathcolor"/> colour formatting. Is this OK?</report>
      
    </rule></pattern><pattern id="mathbackground-tests-pattern"><rule context="mml:*[@mathbackground]" id="mathbackground-tests">
      
      
      
      
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#final-mathbackground-test-1" test="not(ancestor::table-wrap)" role="error" id="final-mathbackground-test-1">[final-mathbackground-test-1] math (<value-of select="name()"/> element) containing '<value-of select="."/>' has '<value-of select="@mathbackground"/>' colour background formatting. This likely means that there's a mistake in the content which will not render correctly online. If it's not a mistake, and the background colour is deliberate, then this will need to removed.</report>
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#final-mathbackground-test-2" test="ancestor::table-wrap" role="error" id="final-mathbackground-test-2">[final-mathbackground-test-2] math (<value-of select="name()"/> element) containing '<value-of select="."/>' has '<value-of select="@mathbackground"/>' colour background formatting. This likely means that there's a mistake in the content which will not render correctly online. If it's not a mistake, and the background colour is deliberate, then either the background colour will need to added to the table cell (rather than the maths), or it needs to be removed.</report>
      
    </rule></pattern><pattern id="mtext-tests-pattern"><rule context="mml:mtext" id="mtext-tests">
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#mtext-test-1" test="matches(.,'^\p{Zs}*\\')" role="warning" id="mtext-test-1">[mtext-test-1] math (<value-of select="name()"/> element) contains '<value-of select="."/>' which looks suspiciously like LaTeX markup. Is it correct? Or is there missing content or content which has been processed incompletely?</report>
      
    </rule></pattern><pattern id="inline-formula-length-tests-pattern"><rule context="inline-formula[not(descendant::mml:mtable) and following-sibling::text()]" id="inline-formula-length-tests">
      
      <report see="https://elifeproduction.slab.com/posts/maths-0gfptlyl#inline-formula-length-test-1" test="string-length(descendant::mml:math[1]) gt 89" role="warning" id="inline-formula-length-test-1">[inline-formula-length-test-1] Inline formula containing '<value-of select="descendant::mml:math[1]"/>' is particularly long. Consider either splitting this up into multiple equations or capturing this as a display equation, as the display on Continuum will likely be strange.</report>
      
    </rule></pattern><pattern id="p-punctuation-pattern"><rule context="article[not(@article-type=($notice-article-types,'article-commentary'))]/body//p[not(parent::list-item) and not(descendant::*[last()]/ancestor::disp-formula) and not(table-wrap)]|       article[@article-type='article-commentary']/body//p[not(parent::boxed-text)]" id="p-punctuation">
      <let name="para" value="replace(.,' ',' ')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hbmr0-p-punctuation-test" test="matches($para,'\p{P}\p{Zs}*?$')" role="warning" id="p-punctuation-test">[p-punctuation-test] paragraph doesn't end with punctuation - Is this correct?</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hbmr0-p-bracket-test" test="matches($para,'([\?:]|\.[\)”&quot;]?)\p{Zs}*$')" role="warning" id="p-bracket-test">[p-bracket-test] paragraph doesn't end with a full stop, colon, question or exclamation mark - Is this correct?</assert>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hbmr0-p-space-test" test="matches(.,'\p{Zs}$')" role="warning" id="p-space-test">[p-space-test] paragraph ends with space(s). Is this correct? '<value-of select="."/>'</report>
    </rule></pattern><pattern id="italic-house-style-pattern"><rule context="italic[not(ancestor::ref) and not(ancestor::sub-article)]" id="italic-house-style">  
      
      

      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hvcr0-final-et-al-italic-test" test="matches(.,'et al[\.]?')" role="warning" id="final-et-al-italic-test">[final-et-al-italic-test] <name/> element contains 'et al.' - this should not be in italics (eLife house style).</report>  
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
      
      
        
      
       
      
        
      
        
      
        
      
      
      
      
      
    </rule></pattern><pattern id="final-latin-conformance-pattern"><rule context="article" id="final-latin-conformance">
      <let name="latin-terms" value="e:get-latin-terms(.,$latin-regex)"/>
      <let name="roman-count" value="sum(for $x in $latin-terms//*:list[@list-type='roman']//*:match return number($x/@count))"/>
      <let name="italic-count" value="sum(for $x in $latin-terms//*:list[@list-type='italic']//*:match return number($x/@count))"/>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7l5o-latin-italic-info" test="($italic-count != 0) and ($roman-count gt $italic-count)" role="warning" id="latin-italic-info">[latin-italic-info] Latin terms are not consistently either roman or italic. There are <value-of select="$roman-count"/> roman terms which is more common, and <value-of select="$italic-count"/> italic term(s). The following terms should be unitalicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='italic'])"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7l5o-latin-roman-info" test="($roman-count != 0) and ($italic-count gt $roman-count)" role="warning" id="latin-roman-info">[latin-roman-info] Latin terms are not consistently either roman or italic. There are <value-of select="$italic-count"/> italic terms which is more common, and <value-of select="$roman-count"/> roman term(s). The following terms should be italicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='roman'])"/>.</report>
      
      <report see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#h7l5o-latin-conformance-info" test="($roman-count != 0) and ($italic-count = $roman-count)" role="warning" id="latin-conformance-info">[latin-conformance-info] Latin terms are not consistently either roman or italic. There are an equal number of italic (<value-of select="$italic-count"/>) and roman (<value-of select="$roman-count"/>) terms. The following terms are italicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='italic'])"/>. The following terms are unitalicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='roman'])"/>.</report>
    </rule></pattern><pattern id="pubmed-link-pattern"><rule context="p//ext-link[not(ancestor::table-wrap) and not(ancestor::sub-article)]" id="pubmed-link">
      
      <report test="matches(@xlink:href,'^http[s]?://www.ncbi.nlm.nih.gov/pubmed/[\d]*')" role="warning" id="pubmed-presence">[pubmed-presence] <value-of select="parent::*/local-name()"/> element contains what looks like a link to a PubMed article - <value-of select="."/> - should this be added a reference instead?</report>
      
      <report test="matches(@xlink:href,'^http[s]?://www.ncbi.nlm.nih.gov/pmc/articles/PMC[\d]*')" role="warning" id="pmc-presence">[pmc-presence] <value-of select="parent::*/local-name()"/> element contains what looks like a link to a PMC article - <value-of select="."/> - should this be added a reference instead?</report>
      
    </rule></pattern><pattern id="pubmed-link-2-pattern"><rule context="table-wrap//ext-link[(contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed') or contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov')) and not(ancestor::sub-article)]" id="pubmed-link-2">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="lc" value="lower-case($pre-text)"/>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/tables-3nehcouh#final-pmid-spacing-table" test="ends-with($lc,'pmid: ') or ends-with($lc,'pmid ')" role="warning" id="final-pmid-spacing-table">[final-pmid-spacing-table] PMID link should be preceding by 'PMID:' with no space but instead it is preceded by '<value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/>'.</report>
    </rule></pattern><pattern id="rrid-link-pattern"><rule context="ext-link[contains(lower-case(@xlink:href),'identifiers.org/rrid') and not(ancestor::sub-article)]" id="rrid-link">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="lc" value="lower-case($pre-text)"/>
      
      
      
      <report see="https://elifeproduction.slab.com/posts/rri-ds-5k19v560#final-rrid-spacing" test="ends-with($lc,'rrid: ') or ends-with($lc,'rrid ')" role="warning" id="final-rrid-spacing">[final-rrid-spacing] RRID link should be preceded by 'RRID:' with no space but instead it is preceded by '<value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/>'.</report>
      
      <report test="matches(@xlink:href,'identifiers\.org/RRID/RRID:')" role="error" id="rrid-link-format">[rrid-link-format] RRID links should be in the format 'https://identifiers.org/RRID:XXXX', but this one is not - <value-of select="@xlink:href"/>.</report>
    </rule></pattern><pattern id="ref-link-mandate-pattern"><rule context="ref-list/ref" id="ref-link-mandate">
      <let name="id" value="@id"/>
      
      
      
      <assert see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#final-ref-link-presence" test="ancestor::article//xref[@rid = $id]" role="error" id="final-ref-link-presence">[final-ref-link-presence] '<value-of select="$id"/>' has no linked citations. Either the reference should be removed or a citation linking to it needs to be added.</assert>
    </rule></pattern><pattern id="fig-permissions-check-pattern"><rule context="fig[not(descendant::permissions)]|media[@mimetype='video' and not(descendant::permissions)]|table-wrap[not(descendant::permissions)]|supplementary-material[not(descendant::permissions)]" id="fig-permissions-check">
      <let name="label" value="replace(label[1],'\.','')"/>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-1" test="matches(caption[1],'[Rr]eproduced from')" role="warning" id="reproduce-test-1">[reproduce-test-1] The caption for <value-of select="$label"/> contains the text 'reproduced from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-2" test="matches(caption[1],'[Rr]eproduced [Ww]ith [Pp]ermission')" role="warning" id="reproduce-test-2">[reproduce-test-2] The caption for <value-of select="$label"/> contains the text 'reproduced with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-3" test="matches(caption[1],'[Aa]dapted from|[Aa]dapted with')" role="warning" id="reproduce-test-3">[reproduce-test-3] The caption for <value-of select="$label"/> contains the text 'adapted from ...', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-4" test="matches(caption[1],'[Rr]eprinted from')" role="warning" id="reproduce-test-4">[reproduce-test-4] The caption for <value-of select="$label"/> contains the text 'reprinted from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-5" test="matches(caption[1],'[Rr]eprinted [Ww]ith [Pp]ermission')" role="warning" id="reproduce-test-5">[reproduce-test-5] The caption for <value-of select="$label"/> contains the text 'reprinted with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-6" test="matches(caption[1],'[Mm]odified from')" role="warning" id="reproduce-test-6">[reproduce-test-6] The caption for <value-of select="$label"/> contains the text 'modified from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-7" test="matches(caption[1],'[Mm]odified [Ww]ith')" role="warning" id="reproduce-test-7">[reproduce-test-7] The caption for <value-of select="$label"/> contains the text 'modified with', but has no permissions. Is this correct?</report>
      
      <report see="https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-8" test="matches(caption[1],'[Uu]sed [Ww]ith [Pp]ermission')" role="warning" id="reproduce-test-8">[reproduce-test-8] The caption for <value-of select="$label"/> contains the text 'used with permission', but has no permissions. Is this correct?</report>
    </rule></pattern><pattern id="xref-formatting-pattern"><rule context="xref[not(@ref-type='bibr')]" id="xref-formatting">
      <let name="parent" value="parent::*/local-name()"/>
      <let name="child" value="child::*/local-name()"/>
      <let name="formatting-elems" value="('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby')"/>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#xref-parent-test" test="$parent = $formatting-elems" role="error" id="xref-parent-test">[xref-parent-test] xref - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which is not correct.</report>
      
      <report see="https://elifeproduction.slab.com/posts/asset-citations-fa3e2yoo#xref-child-test" test="$child = $formatting-elems" role="warning" id="xref-child-test">[xref-child-test] xref - <value-of select="."/> - has a formatting child element - <value-of select="$child"/> - which is likely not correct.</report>
    </rule></pattern><pattern id="ref-xref-formatting-pattern"><rule context="xref[@ref-type='bibr']" id="ref-xref-formatting">
      <let name="parent" value="parent::*/local-name()"/>
      <let name="child" value="child::*/local-name()"/>
      <let name="formatting-elems" value="('bold','fixed-case','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')"/>
      
      <report test="$parent = ($formatting-elems,'italic')" role="error" id="ref-xref-parent-test">[ref-xref-parent-test] xref - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which is not correct.</report>
      
      <report test="$child = $formatting-elems" role="error" id="ref-xref-child-test">[ref-xref-child-test] xref - <value-of select="."/> - has a formatting child element - <value-of select="$child"/> - which is not correct.</report>
      
      <report test="italic" role="warning" id="ref-xref-italic-child-test">[ref-xref-italic-child-test] xref - <value-of select="."/> - contains italic formatting. Is this correct?</report>
    </rule></pattern><pattern id="code-fork-pattern"><rule context="article" id="code-fork">
      <let name="test" value="e:code-check(lower-case(.))"/>
      
      <report see="https://elifeproduction.slab.com/posts/archiving-code-zrfi30c5#code-fork-info" test="$test//*:match" role="warning" id="code-fork-info">[code-fork-info] Article possibly contains code that needs forking. Search - <value-of select="string-join(for $x in $test//*:match return $x,', ')"/>.</report>
    </rule></pattern><pattern id="auth-kwd-style-pattern"><rule context="kwd-group[@kwd-group-type='author-keywords']/kwd" id="auth-kwd-style">
      <let name="article-text" value="string-join(for $x in ancestor::article/*[local-name() = 'body' or local-name() = 'back']//*         return         if ($x/ancestor::sec[@sec-type='data-availability']) then ()         else if ($x/ancestor::sec[@sec-type='additional-information']) then ()         else if ($x/ancestor::ref-list) then ()         else if ($x/local-name() = 'xref') then ()         else $x/text(),'')"/>
      <let name="lower" value="lower-case(.)"/>
      <!-- removes instances where the keyword begins a sentence and accounts for regex special characters -->
      <let name="kwd-regex" value="concat('\. ',replace(.,'\+','\\+'))"/>
      <let name="t" value="replace($article-text,$kwd-regex,'')"/>
      
      <report test="not(matches(.,'RNA|[Cc]ryoEM|[34]D')) and (. != $lower) and not(contains($t,.))" role="warning" id="auth-kwd-check">[auth-kwd-check] Keyword - '<value-of select="."/>' - does not appear in the article text with this capitalisation. Should it be <value-of select="$lower"/> instead?</report>
      
      <report test="matches(.,'&amp;#x\d')" role="warning" id="auth-kwd-check-2">[auth-kwd-check-2] Keyword contains what looks like a broken unicode - <value-of select="."/>.</report>
      
      <report test="contains(.,'&lt;') or contains(.,'&gt;')" role="error" id="auth-kwd-check-3">[auth-kwd-check-3] Keyword contains markup captured as text - <value-of select="."/>. Please remove it and ensure that it is marked up properly (if necessary).</report>
      
      <report test="matches(.,'[\(\)\[\]]') or contains(.,'{') or contains(.,'}')" role="warning" id="auth-kwd-check-4">[auth-kwd-check-4] Keyword contains brackets - <value-of select="."/>. These should either simply be removed, or added as two keywords (with the brackets still removed).</report>
      
      <report test="contains($lower,' and ')" role="warning" id="auth-kwd-check-5">[auth-kwd-check-5] Keyword contains 'and' - <value-of select="."/>. These should be split out into two keywords.</report>
      
      <report test="not(ancestor::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1] = $features-subj) and count(tokenize(.,'\p{Zs}')) gt 4" role="warning" id="auth-kwd-check-6">[auth-kwd-check-6] Keyword contains more than 4 words - <value-of select="."/>. Should these be split out into separate keywords?</report>
      
      <report test="not(italic) and matches($lower,$org-regex)" role="warning" id="auth-kwd-check-7">[auth-kwd-check-7] Keyword contains an organism name which is not in italics - <value-of select="."/>. Please italicise the organism name in the keyword.</report>
    </rule></pattern><pattern id="general-kwd-pattern"><rule context="kwd" id="general-kwd">
      
      <report test="contains(.,', ')" role="warning" id="auth-kwd-check-8">[auth-kwd-check-8] Keyword contains a comma - '<value-of select="."/>'. Should this be split into multiple keywords?</report>
      
      <report test="matches(.,'[”“‘’&quot;]')" role="warning" id="auth-kwd-check-9">[auth-kwd-check-9] Keyword contains a quotation mark - '<value-of select="."/>'. Should this be removed and/or should the keyword be split into multiple keywords?</report>
    </rule></pattern><pattern id="ref-given-names-pattern"><rule context="ref-list//element-citation/person-group[@person-group-type='author']//given-names" id="ref-given-names">
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#ref-given-names-test-1" test="string-length(.) gt 4" role="warning" id="ref-given-names-test-1">[ref-given-names-test-1] Given names should always be initialised. Ref '<value-of select="ancestor::ref[1]/@id"/>' contains a given names with a string longer than 4 characters - '<value-of select="."/>' in <value-of select="concat(preceding-sibling::surname[1],' ',.)"/>. Is this a surname captured as given names? Or a fully spelt out given names?</report>
    </rule></pattern><pattern id="data-ref-given-names-pattern"><rule context="sec[@sec-type='data-availability']//element-citation/person-group[@person-group-type='author']//given-names" id="data-ref-given-names">      
      
      <report see="https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#data-ref-given-names-test-1" test="string-length(.) gt 4" role="warning" id="data-ref-given-names-test-1">[data-ref-given-names-test-1] Given names should always be initialised. Ref contains a given names with a string longer than 4 characters - '<value-of select="."/>' in <value-of select="concat(preceding-sibling::surname[1],' ',.)"/>. Is this a surname captured as given names? Or a fully spelt out given names?</report>
      
    </rule></pattern><pattern id="ar-fig-title-tests-pattern"><rule context="fig[ancestor::sub-article]/caption/title" id="ar-fig-title-tests">     
      
      <report see="https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#ar-fig-title-test-1" test="lower-case(normalize-space(.))=('title','title.')" role="warning" id="ar-fig-title-test-1">[ar-fig-title-test-1] Please query author for a <value-of select="ancestor::fig/label"/> title, and/or remove placeholder title text - <value-of select="."/>.</report>
      
    </rule></pattern><pattern id="section-title-tests-pattern"><rule context="sec/p/*[1][not(preceding-sibling::text()) or (normalize-space(preceding-sibling::text())='')]" id="section-title-tests">     
      <let name="following-text" value="following-sibling::text()[1]"/>
      
      <report see="https://elifeproduction.slab.com/posts/article-structure-5nhfjxj0#section-title-test-1" test="(name()=('italic','bold','underline')) and (ends-with(.,'.') or matches($following-text,'^\p{Zs}?\.|^[\p{P}]?\p{Zs}?[A-Z]|^[\p{P}]?\p{Zs}?\d')) and not((name()='italic') and matches(lower-case(.),$sec-title-regex))" role="warning" id="section-title-test-1">[section-title-test-1] <name/> text begins a paragraph - <value-of select="."/> - Should it be marked up as a section title (Heading level <value-of select="count(ancestor::sec) + 1"/>)?</report>
      
    </rule></pattern><pattern id="strike-tests-pattern"><rule context="strike" id="strike-tests">     
      
      <report test="." role="warning" id="final-strike-flag">[final-strike-flag] <value-of select="parent::*/local-name()"/> element contains text with strikethrough formatting - <value-of select="."/> - Is this correct? Or have the authors added strikethrough formatting as an indication that the content should be removed?</report>
      
    </rule></pattern><pattern id="title-bold-tests-pattern"><rule context="title[(count(*)=1) and (child::bold or child::italic)]" id="title-bold-tests">  
    <let name="free-text" value="replace(       normalize-space(string-join(for $x in self::*/text() return $x,''))       ,' ','')"/>
    
    <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hcq0l-title-all-bold-test-1" test="$free-text=''" role="warning" id="title-all-bold-test-1">[title-all-bold-test-1] Title is entirely in <value-of select="child::*[1]/local-name()"/> - '<value-of select="."/>'. Is this correct?</report>
    </rule></pattern><pattern id="italic-org-tests-pattern"><rule context="italic[matches(lower-case(.),$org-regex)]" id="italic-org-tests">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      <let name="pre-token" value="substring($pre-text, string-length($pre-text), 1)"/>
      <let name="post-token" value="substring($post-text, 1, 1)"/>
      
      <assert see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hkbnb-italic-org-test-1" test="(substring(.,1,1) = (' ',' ')) or ($pre-token='') or matches($pre-token,'[\p{Zs}\p{P}]')" role="warning" id="italic-org-test-1">[italic-org-test-1] There is no space between the organism name '<value-of select="."/>' and its preceding text - '<value-of select="concat(substring($pre-text,string-length($pre-text)-10),.)"/>'. Is this correct or is there a missing space?</assert>
      
      <assert see="https://elifeproduction.slab.com/posts/house-style-yi0641ob#hkbnb-italic-org-test-2" test="(substring(., string-length(.), 1) = (' ',' ')) or ($post-token='') or matches($post-token,'[\p{Zs}\p{P}]')" role="warning" id="italic-org-test-2">[italic-org-test-2] There is no space between the organism name '<value-of select="."/>' and its following text - '<value-of select="concat(.,substring($post-text,1,10))"/>'. Is this correct or is there a missing space?</assert>
    </rule></pattern><pattern id="sub-sup-tests-pattern"><rule context="sub|sup" id="sub-sup-tests">
      
      <report see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#h6795-double-sup-sub" test="parent::*/name() = name()" role="error" id="double-sup-sub">[double-sup-sub] <name/> is captured as a child of <name/>, which is not permitted.</report>
      
    </rule></pattern><pattern id="break-tests-pattern"><rule context="break" id="break-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hmp1c-break-placement" test="ancestor::td or ancestor::th" role="error" id="break-placement">[break-placement] The break element is only permitted as a child (or descendant) of a table cell. This one is placed elsewhere (<value-of select="concat(string-join(for $x in ancestor::* return $x/name(),'/'),'/',name())"/>).</assert>
      
    </rule></pattern><pattern id="flag-github-pattern"><rule context="ext-link[not(ancestor::sub-article or ancestor::element-citation or ancestor::sec[@sec-type='data-availability']) and contains(lower-case(@xlink:href),'github.com') and not(contains(@xlink:href,'archive.softwareheritage.org'))]" id="flag-github">
      <let name="l" value="lower-case(@xlink:href)"/>
      <let name="substring" value="substring-after($l,'github.com/')"/>
      <let name="owner-repo" value="string-join(for $x in tokenize($substring,'/')[position()=(1,2)] return if (contains($x,'#')) then substring-before($x,'#') else $x,'/')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#github-no-citation" test="preceding::ext-link[contains(lower-case(@xlink:href),$owner-repo)] or ancestor::article//element-citation[@publication-type=('software','data') and (contains(lower-case(ext-link[1]),$owner-repo) or  contains(lower-case(pub-id[1]/@xlink:href),$owner-repo))]" role="warning" id="github-no-citation">[github-no-citation] This GitHub link - <value-of select="@xlink:href"/> - is included in the text, but there is no software reference for it. Please add a software reference or, in the event that all the information is not available, query the authors for the reference details.</assert>
      
    </rule></pattern><pattern id="flag-gitlab-pattern"><rule context="ext-link[not(ancestor::sub-article or ancestor::element-citation or ancestor::sec[@sec-type='data-availability']) and contains(lower-case(@xlink:href),'gitlab.com') and not(contains(@xlink:href,'archive.softwareheritage.org'))]" id="flag-gitlab">
      <let name="l" value="lower-case(@xlink:href)"/>
      <let name="substring" value="substring-after($l,'gitlab.com/')"/>
      <let name="owner-repo" value="string-join(for $x in tokenize($substring,'/')[position()=(1,2)] return if (contains($x,'#')) then substring-before($x,'#') else $x,'/')"/>
      
      <assert see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#gitlab-no-citation" test="preceding::ext-link[contains(lower-case(@xlink:href),$owner-repo)] or ancestor::article//element-citation[@publication-type=('software','data') and (contains(lower-case(ext-link[1]),$owner-repo) or  contains(lower-case(pub-id[1]/@xlink:href),$owner-repo))]" role="warning" id="gitlab-no-citation">[gitlab-no-citation] This GitLab link - <value-of select="@xlink:href"/> - is included in the text, but there is no software reference for it. Please add a software reference or, in the event that all the information is not available, query the authors for the reference details.</assert>
      
    </rule></pattern><pattern id="data-request-checks-pattern"><rule context="p|td|th|title" id="data-request-checks">
      
      <report test="matches(lower-case(.),'(^|\s)(data|datasets)(\s|\?|\.|!)') and matches(lower-case(.),'(^|\s)request(\s|\?|\.|!|$)')" role="warning" id="data-request-check">[data-request-check] <name/> element contains text that has the words data (or dataset(s)) as well as request. Is this a statement that data is available on request? If so, has this been approved by the editors?</report>

      <report test="matches(lower-case(.),'^mmethods[\s\.]|\smmethods[\s\.]')" role="error" id="mmethods-typo-check">[mmethods-typo-check] <name/> element contains a typo ('mmethods') - <value-of select="."/>.</report>
      
    </rule></pattern>
  
  <pattern id="doi-journal-ref-checks-pattern"><rule context="element-citation[(@publication-type='journal') and not(pub-id[@pub-id-type='doi']) and year and source]" id="doi-journal-ref-checks">
      <let name="cite" value="e:citation-format1(.)"/>
      <let name="year" value="number(replace(year[1],'[^\d]',''))"/>
      <let name="journal" value="replace(lower-case(source[1]),'^the ','')"/>
      <let name="journals" value="'journals.xml'"/>
      
      <assert test="some $x in document($journals)/journals/journal satisfies (($x/@title/string()=$journal) and (number($x/@year) ge $year))" role="warning" id="journal-doi-test-1">[journal-doi-test-1] <value-of select="$cite"/> is a journal ref without a doi. Should it have one?</assert>
      
    </rule></pattern><pattern id="doi-book-ref-checks-pattern"><rule context="element-citation[(@publication-type='book') and not(pub-id[@pub-id-type='doi']) and year and publisher-name]" id="doi-book-ref-checks">
      <let name="cite" value="e:citation-format1(.)"/>
      <let name="year" value="number(replace(year[1],'[^\d]',''))"/>
      <let name="publisher" value="lower-case(publisher-name[1])"/>
      <let name="publishers" value="'publishers.xml'"/>
      
      <report see="https://elifeproduction.slab.com/posts/book-references-x4trb0n2#h5h75-book-doi-test-1" test="some $x in document($publishers)/publishers/publisher satisfies ($x/@title/string()=$publisher)" role="warning" id="book-doi-test-1">[book-doi-test-1] <value-of select="$cite"/> is a book ref without a doi, but its publisher (<value-of select="publisher-name[1]"/>) is known to register dois with some books/chapters. Should it have one?</report>
      
    </rule></pattern><pattern id="doi-software-ref-checks-pattern"><rule context="element-citation[(@publication-type='software') and year and source]" id="doi-software-ref-checks">
      <let name="cite" value="e:citation-format1(.)"/>
      <let name="host" value="lower-case(source[1])"/>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#software-doi-test-1" test="$host='zenodo' and not(contains(ext-link[1],'10.5281/zenodo'))" role="warning" id="software-doi-test-1">[software-doi-test-1] <value-of select="$cite"/> is a software ref with a source (<value-of select="source[1]"/>) known to register dois starting with '10.5281/zenodo'. Should it have a link in the format 'https://doi.org/10.5281/zenodo...'?</report>
      
      <report see="https://elifeproduction.slab.com/posts/software-references-aymhzmlh#software-doi-test-2" test="$host='figshare' and not(contains(ext-link[1],'10.6084/m9.figshare'))" role="warning" id="software-doi-test-2">[software-doi-test-2] <value-of select="$cite"/> is a software ref with a source (<value-of select="source[1]"/>) known to register dois starting with '10.6084/m9.figshare'. Should it have a link in the format 'https://doi.org/10.6084/m9.figshare...'?</report>
      
    </rule></pattern><pattern id="doi-conf-ref-checks-pattern"><rule context="element-citation[(@publication-type='confproc') and not(pub-id[@pub-id-type='doi']) and year and conf-name]" id="doi-conf-ref-checks">
      <let name="name" value="lower-case(conf-name[1])"/>
      
      <report see="https://elifeproduction.slab.com/posts/conference-references-d51f08lj?shr=d51f08lj#h5t13-conf-doi-test-1" test="contains($name,'ieee')" role="warning" id="conf-doi-test-1">[conf-doi-test-1] <value-of select="e:citation-format1(.)"/> is a conference ref without a doi, but it's a conference which is known to possibly have dois - (<value-of select="conf-name[1]"/>). Should it have one?</report>
      
    </rule></pattern>
  
  <pattern id="zenodo-tests-pattern"><rule context="element-citation[(lower-case(source[1])='zenodo') or contains(ext-link[1],'10.5281/zenodo') or contains(pub-id[@pub-id-type='doi'][1],'10.5281/zenodo')]" id="zenodo-tests">
      
      <assert see="https://elifeproduction.slab.com/posts/journal-references-i098980k#zenodo-check" test="@publication-type=('data','software','preprint','report')" role="error" id="zenodo-check">[zenodo-check] <value-of select="@publication-type"/> type reference <value-of select="if (parent::ref[@id]) then concat('(with id ',parent::ref[1]/@id,')') else ()"/> is a zenodo one, which means that it must be one of the following reference types: data, software, preprint or report.</assert>
      
    </rule></pattern>
  
  <pattern id="link-ref-tests-pattern"><rule context="element-citation/source | element-citation/article-title | element-citation/chapter-title | element-citation/data-title" id="link-ref-tests">
      <let name="lc" value="lower-case(.)"/>
      <!-- Get tokens in the string which are not common. Distinct values can then be compared to determine if there is duplication -->
      <let name="t" value="tokenize($lc,'\s')[not(.=('of','the'))]"/>
      <let name="t-count" value="if (count($t) lt 1) then 1                                  else count($t)"/>
      <let name="d-count" value="if ($t-count = 1) then 1                                  else count(distinct-values($t))"/>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#doi-in-display-test" test="matches(.,'^10\.\d{4,9}/[-._;()/:A-Za-z0-9&lt;&gt;\+#&amp;`~–−]+|\p{Zs}10\.\d{4,9}/[-._;()/:A-Za-z0-9&lt;&gt;\+#&amp;`~–−]+')" role="error" id="doi-in-display-test">[doi-in-display-test] <value-of select="name()"/> element contains a doi - <value-of select="."/>. The doi must be moved to the appropriate field, and the correct information should be included in this element (or queried if the information is missing).</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#link-in-display-test" test="matches(.,'^(https?:|ftp://|git://|tel:\s*[\d\+]|mailto:)|\s(https?:|ftp://|git://|tel:\s*[\d\+]|mailto:)')" role="error" id="link-in-display-test">[link-in-display-test] <value-of select="name()"/> element contains a url - <value-of select="."/>. The url must be moved to the appropriate field (if it is a doi, then it should be captured as a doi without the 'https://doi.org/' prefix), and the correct information should be included in this element (or queried if the information is missing).</report>
      
      <report see="https://elifeproduction.slab.com/posts/references-ghxfa7uy#hg303-duplicated-content" test="lower-case(.)!='cell stem cell' and ($d-count div $t-count) lt 0.75" role="warning" id="duplicated-content">[duplicated-content] Does <value-of select="name(.)"/> in <value-of select="e:citation-format1(parent::element-citation)"/> have duplicated content? <value-of select="."/></report>
      
    </rule></pattern>
  
  <pattern id="unicode-tests-pattern"><rule context="sub-article//p[matches(.,'[âÂÅÃËÆ]')]|sub-article//td[matches(.,'[âÂÅÃËÆ]')]|sub-article//th[matches(.,'[âÂÅÃËÆ]')]" id="unicode-tests">
      
        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-1" test="contains(.,'â‚¬')" role="warning" id="unicode-test-1">[unicode-test-1] <name/> element contains 'â‚¬' - this should instead be the character '€'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-2" test="contains(.,'Ã€')" role="warning" id="unicode-test-2">[unicode-test-2] <name/> element contains 'Ã€' - this should instead be the character 'À'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-3" test="contains(.,'Ã')" role="warning" id="unicode-test-3">[unicode-test-3] <name/> element contains 'Ã' - this should instead be the character 'Á'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-4" test="contains(.,'â€š')" role="warning" id="unicode-test-4">[unicode-test-4] <name/> element contains 'â€š' - this should instead be the character '‚'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-5" test="contains(.,'Ã‚')" role="warning" id="unicode-test-5">[unicode-test-5] <name/> element contains 'Ã‚' - this should instead be the character 'Â'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-6" test="contains(.,'Æ’')" role="warning" id="unicode-test-6">[unicode-test-6] <name/> element contains 'Æ’' - this should instead be the character 'ƒ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-7" test="contains(.,'Ãƒ')" role="warning" id="unicode-test-7">[unicode-test-7] <name/> element contains 'Ãƒ' - this should instead be the character 'Ã'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-8" test="contains(.,'â€ž')" role="warning" id="unicode-test-8">[unicode-test-8] <name/> element contains 'â€ž' - this should instead be the character '„'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-9" test="contains(.,'Ã„')" role="warning" id="unicode-test-9">[unicode-test-9] <name/> element contains 'Ã„' - this should instead be the character 'Ä'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-10" test="contains(.,'â€¦')" role="warning" id="unicode-test-10">[unicode-test-10] <name/> element contains 'â€¦' - this should instead be the character '…'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-11" test="contains(.,'Ã…')" role="warning" id="unicode-test-11">[unicode-test-11] <name/> element contains 'Ã…' - this should instead be the character 'Å'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-13" test="contains(.,'Ã†')" role="warning" id="unicode-test-13">[unicode-test-13] <name/> element contains 'Ã†' - this should instead be the character 'Æ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-14" test="contains(.,'â€¡')" role="warning" id="unicode-test-14">[unicode-test-14] <name/> element contains 'â€¡' - this should instead be the character '‡'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-15" test="contains(.,'Ã‡')" role="warning" id="unicode-test-15">[unicode-test-15] <name/> element contains 'Ã‡' - this should instead be the character 'Ç'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-16" test="contains(.,'Ë†')" role="warning" id="unicode-test-16">[unicode-test-16] <name/> element contains 'Ë†' - this should instead be the character 'ˆ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-17" test="contains(.,'Ãˆ')" role="warning" id="unicode-test-17">[unicode-test-17] <name/> element contains 'Ãˆ' - this should instead be the character 'È'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-18" test="contains(.,'â€°')" role="warning" id="unicode-test-18">[unicode-test-18] <name/> element contains 'â€°' - this should instead be the character '‰'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-19" test="contains(.,'Ã‰')" role="warning" id="unicode-test-19">[unicode-test-19] <name/> element contains 'Ã‰' - this should instead be the character 'É'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-21" test="contains(.,'ÃŠ')" role="warning" id="unicode-test-21">[unicode-test-21] <name/> element contains 'ÃŠ' - this should instead be the character 'Ê'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-22" test="contains(.,'â€¹')" role="warning" id="unicode-test-22">[unicode-test-22] <name/> element contains 'â€¹' - this should instead be the character '‹'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-23" test="contains(.,'Ã‹')" role="warning" id="unicode-test-23">[unicode-test-23] <name/> element contains 'Ã‹' - this should instead be the character 'Ë'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-24" test="contains(.,'Å’')" role="warning" id="unicode-test-24">[unicode-test-24] <name/> element contains 'Å’' - should this instead be the character 'Œ'? - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-25" test="contains(.,'ÃŒ')" role="warning" id="unicode-test-25">[unicode-test-25] <name/> element contains 'ÃŒ' - this should instead be the character 'Ì'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-26" test="contains(.,'Ã')" role="warning" id="unicode-test-26">[unicode-test-26] <name/> element contains 'Ã' - this should instead be the character 'Í'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-27" test="contains(.,'Å½')" role="warning" id="unicode-test-27">[unicode-test-27] <name/> element contains 'Å½' - this should instead be the character 'Ž'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-28" test="contains(.,'ÃŽ')" role="warning" id="unicode-test-28">[unicode-test-28] <name/> element contains 'ÃŽ' - this should instead be the character 'Î'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-29" test="contains(.,'Ã')" role="warning" id="unicode-test-29">[unicode-test-29] <name/> element contains 'Ã' - this should instead be the character 'Ï'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-30" test="contains(.,'Ã')" role="warning" id="unicode-test-30">[unicode-test-30] <name/> element contains 'Ã' - this should instead be the character 'Ð'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-31" test="contains(.,'â€˜')" role="warning" id="unicode-test-31">[unicode-test-31] <name/> element contains 'â€˜' - this should instead be the character '‘'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-32" test="contains(.,'Ã‘')" role="warning" id="unicode-test-32">[unicode-test-32] <name/> element contains 'Ã‘' - this should instead be the character 'Ñ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-33" test="contains(.,'â€™')" role="warning" id="unicode-test-33">[unicode-test-33] <name/> element contains 'â€™' - this should instead be the character '’'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-34" test="contains(.,'Ã’')" role="warning" id="unicode-test-34">[unicode-test-34] <name/> element contains 'Ã’' - this should instead be the character 'Ò'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-35" test="contains(.,'â€œ')" role="warning" id="unicode-test-35">[unicode-test-35] <name/> element contains 'â€œ' - this should instead be the character '“'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-36" test="contains(.,'Ã“')" role="warning" id="unicode-test-36">[unicode-test-36] <name/> element contains 'Ã“' - this should instead be the character 'Ó'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-37" test="contains(.,'â€')" role="warning" id="unicode-test-37">[unicode-test-37] <name/> element contains 'â€' - this should instead be the character '”'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-38" test="contains(.,'Ã”')" role="warning" id="unicode-test-38">[unicode-test-38] <name/> element contains 'Ã”' - this should instead be the character 'Ô'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-39" test="contains(.,'Ã•')" role="warning" id="unicode-test-39">[unicode-test-39] <name/> element contains 'Ã•' - this should instead be the character 'Õ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-40" test="contains(.,'â€“')" role="warning" id="unicode-test-40">[unicode-test-40] <name/> element contains 'â€“' - this should instead be the character '–'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-41" test="contains(.,'Ã–')" role="warning" id="unicode-test-41">[unicode-test-41] <name/> element contains 'Ã–' - this should instead be the character 'Ö'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-42" test="contains(.,'â€”')" role="warning" id="unicode-test-42">[unicode-test-42] <name/> element contains 'â€”' - this should instead be the character '—'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-43" test="contains(.,'Ã—')" role="warning" id="unicode-test-43">[unicode-test-43] <name/> element contains 'Ã—' - this should instead be the character '×'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-44" test="contains(.,'Ëœ')" role="warning" id="unicode-test-44">[unicode-test-44] <name/> element contains 'Ëœ' - this should instead be the character '˜'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-45" test="contains(.,'Ã˜')" role="warning" id="unicode-test-45">[unicode-test-45] <name/> element contains 'Ã˜' - this should instead be the character 'Ø'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-46" test="contains(.,'Ã™')" role="warning" id="unicode-test-46">[unicode-test-46] <name/> element contains 'Ã™' - this should instead be the character 'Ù'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-47" test="contains(.,'Å¡')" role="warning" id="unicode-test-47">[unicode-test-47] <name/> element contains 'Å¡' - this should instead be the character 'š'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-48" test="contains(.,'Ãš')" role="warning" id="unicode-test-48">[unicode-test-48] <name/> element contains 'Ãš' - this should instead be the character 'Ú'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-49" test="contains(.,'â€º')" role="warning" id="unicode-test-49">[unicode-test-49] <name/> element contains 'â€º' - this should instead be the character '›'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-50" test="contains(.,'Ã›')" role="warning" id="unicode-test-50">[unicode-test-50] <name/> element contains 'Ã›' - this should instead be the character 'Û'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-51" test="contains(.,'Å“')" role="warning" id="unicode-test-51">[unicode-test-51] <name/> element contains 'Å“' - this should instead be the character 'œ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-52" test="contains(.,'Ãœ')" role="warning" id="unicode-test-52">[unicode-test-52] <name/> element contains 'Ãœ' - this should instead be the character 'Ü'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-53" test="contains(.,'Ã')" role="warning" id="unicode-test-53">[unicode-test-53] <name/> element contains 'Ã' - this should instead be the character 'Ý'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-54" test="contains(.,'Å¾')" role="warning" id="unicode-test-54">[unicode-test-54] <name/> element contains 'Å¾' - this should instead be the character 'ž'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-55" test="contains(.,'Ãž')" role="warning" id="unicode-test-55">[unicode-test-55] <name/> element contains 'Ãž' - this should instead be the character 'Þ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-56" test="contains(.,'Å¸')" role="warning" id="unicode-test-56">[unicode-test-56] <name/> element contains 'Å¸' - this should instead be the character 'Ÿ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-57" test="contains(.,'ÃŸ')" role="warning" id="unicode-test-57">[unicode-test-57] <name/> element contains 'ÃŸ' - this should instead be the character 'ß'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-58" test="contains(.,'Â¡')" role="warning" id="unicode-test-58">[unicode-test-58] <name/> element contains 'Â¡' - this should instead be the character '¡'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-59" test="contains(.,'Ã¡')" role="warning" id="unicode-test-59">[unicode-test-59] <name/> element contains 'Ã¡' - this should instead be the character 'á'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-60" test="contains(.,'Â¢')" role="warning" id="unicode-test-60">[unicode-test-60] <name/> element contains 'Â¢' - this should instead be the character '¢'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-61" test="contains(.,'Ã¢')" role="warning" id="unicode-test-61">[unicode-test-61] <name/> element contains 'Ã¢' - this should instead be the character 'â'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-62" test="contains(.,'Â£')" role="warning" id="unicode-test-62">[unicode-test-62] <name/> element contains 'Â£' - this should instead be the character '£'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-63" test="contains(.,'Ã£')" role="warning" id="unicode-test-63">[unicode-test-63] <name/> element contains 'Ã£' - this should instead be the character 'ã'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-64" test="contains(.,'Â¤')" role="warning" id="unicode-test-64">[unicode-test-64] <name/> element contains 'Â¤' - this should instead be the character '¤'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-65" test="contains(.,'Ã¤')" role="warning" id="unicode-test-65">[unicode-test-65] <name/> element contains 'Ã¤' - this should instead be the character 'ä'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-66" test="contains(.,'Ã¥')" role="warning" id="unicode-test-66">[unicode-test-66] <name/> element contains 'Ã¥' - this should instead be the character 'å'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-67" test="contains(.,'Â¨')" role="warning" id="unicode-test-67">[unicode-test-67] <name/> element contains 'Â¨' - this should instead be the character '¨'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-68" test="contains(.,'Ã¨')" role="warning" id="unicode-test-68">[unicode-test-68] <name/> element contains 'Ã¨' - this should instead be the character 'è'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-69" test="contains(.,'Âª')" role="warning" id="unicode-test-69">[unicode-test-69] <name/> element contains 'Âª' - this should instead be the character 'ª'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-70" test="contains(.,'Ãª')" role="warning" id="unicode-test-70">[unicode-test-70] <name/> element contains 'Ãª' - this should instead be the character 'ê'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-71" test="contains(.,'Â­')" role="warning" id="unicode-test-71">[unicode-test-71] <name/> element contains 'Â­' - this should instead be the character '­'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-72" test="contains(.,'Ã­')" role="warning" id="unicode-test-72">[unicode-test-72] <name/> element contains 'Ã­' - this should instead be the character 'í'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-73" test="contains(.,'Â¯')" role="warning" id="unicode-test-73">[unicode-test-73] <name/> element contains 'Â¯' - this should instead be the character '¯'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-74" test="contains(.,'Ã¯')" role="warning" id="unicode-test-74">[unicode-test-74] <name/> element contains 'Ã¯' - this should instead be the character 'ï'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-75" test="contains(.,'Â°')" role="warning" id="unicode-test-75">[unicode-test-75] <name/> element contains 'Â°' - this should instead be the character '°'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-76" test="contains(.,'Ã°')" role="warning" id="unicode-test-76">[unicode-test-76] <name/> element contains 'Ã°' - this should instead be the character 'ð'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-77" test="contains(.,'Â±')" role="warning" id="unicode-test-77">[unicode-test-77] <name/> element contains 'Â±' - this should instead be the character '±'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-78" test="contains(.,'Ã±')" role="warning" id="unicode-test-78">[unicode-test-78] <name/> element contains 'Ã±' - this should instead be the character 'ñ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-79" test="contains(.,'Â´')" role="warning" id="unicode-test-79">[unicode-test-79] <name/> element contains 'Â´' - this should instead be the character '´'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-80" test="contains(.,'Ã´')" role="warning" id="unicode-test-80">[unicode-test-80] <name/> element contains 'Ã´' - this should instead be the character 'ô'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-81" test="contains(.,'Âµ')" role="warning" id="unicode-test-81">[unicode-test-81] <name/> element contains 'Âµ' - this should instead be the character 'µ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-82" test="contains(.,'Ãµ')" role="warning" id="unicode-test-82">[unicode-test-82] <name/> element contains 'Ãµ' - this should instead be the character 'õ'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-83" test="contains(.,'Â¶')" role="warning" id="unicode-test-83">[unicode-test-83] <name/> element contains 'Â¶' - this should instead be the character '¶'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-84" test="contains(.,'Ã¶')" role="warning" id="unicode-test-84">[unicode-test-84] <name/> element contains 'Ã¶' - this should instead be the character 'ö'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-85" test="contains(.,'Â·')" role="warning" id="unicode-test-85">[unicode-test-85] <name/> element contains 'Â·' - this should instead be the character '·'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-86" test="contains(.,'Ã·')" role="warning" id="unicode-test-86">[unicode-test-86] <name/> element contains 'Ã·' - this should instead be the character '÷'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-87" test="contains(.,'Â¸')" role="warning" id="unicode-test-87">[unicode-test-87] <name/> element contains 'Â¸' - this should instead be the character '¸'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-88" test="contains(.,'Ã¸')" role="warning" id="unicode-test-88">[unicode-test-88] <name/> element contains 'Ã¸' - this should instead be the character 'ø'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-89" test="contains(.,'Ã¹')" role="warning" id="unicode-test-89">[unicode-test-89] <name/> element contains 'Ã¹' - this should instead be the character 'ù'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-90" test="contains(.,'Âº')" role="warning" id="unicode-test-90">[unicode-test-90] <name/> element contains 'Âº' - this should instead be the character 'º'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-91" test="contains(.,'Ãº')" role="warning" id="unicode-test-91">[unicode-test-91] <name/> element contains 'Ãº' - this should instead be the character 'ú'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-92" test="contains(.,'Â¿')" role="warning" id="unicode-test-92">[unicode-test-92] <name/> element contains 'Â¿' - this should instead be the character '¿'. - <value-of select="."/>.</report>

        <report see="https://elifeproduction.slab.com/posts/review-materials-r9uiav3j#unicode-test-93" test="contains(.,'Ã¿')" role="warning" id="unicode-test-93">[unicode-test-93] <name/> element contains 'Ã¿' - this should instead be the character 'ÿ'. - <value-of select="."/>.</report>

        </rule></pattern><pattern id="private-char-tests-pattern"><rule context="p[not(descendant::p or descendant::td or descendant::th)]|td[not(descendant::p)]|th[not(descendant::p)]" id="private-char-tests">
      
      <report see="https://elifeproduction.slab.com/posts/general-content-2y3029rs#private-char-test" test="matches(.,'\p{Co}')" role="error" id="private-char-test">[private-char-test] <name/> element contains private use character(s). They either need removing or changing to the correct character. Private characters: '<value-of select="string-join(distinct-values(tokenize(.,'\p{Zs}')[matches(.,'\p{Co}')]),' ')"/>'.</report>
      
    </rule></pattern>
  
  <pattern id="element-allowlist-pattern"><rule context="article//*[not(ancestor::mml:math)]" id="element-allowlist">
      <let name="allowed-elements" value="('abstract',         'ack',         'addr-line',         'aff',         'ali:free_to_read',         'ali:license_ref',         'alternatives',         'anonymous',         'app',         'app-group',         'article',         'article-categories',         'article-id',         'article-meta',         'article-title',         'article-version',         'attrib',         'author-notes',         'award-group',         'award-id',         'back',         'bio',         'body',         'bold',         'boxed-text',         'break',         'caption',         'chapter-title',         'code',         'collab',         'comment',         'conf-date',         'conf-loc',         'conf-name',         'contrib',         'contrib-group',         'contrib-id',         'copyright-holder',         'copyright-statement',         'copyright-year',         'corresp',         'country',         'custom-meta',         'custom-meta-group',         'data-title',         'date',         'date-in-citation',         'day',         'disp-formula',         'disp-quote',         'edition',         'element-citation',         'elocation-id',         'email',         'event',         'event-desc',         'ext-link',         'fig',         'fig-group',         'fn',         'fn-group',         'fpage',         'front',         'front-stub',         'funding-group',         'funding-source',         'funding-statement',         'given-names',         'graphic',         'history',         'inline-formula',         'inline-graphic',         'institution',         'institution-id',         'institution-wrap',         'issn',         'issue',         'italic',         'journal-id',         'journal-meta',         'journal-title',         'journal-title-group',         'kwd',         'kwd-group',         'label',         'license',         'license-p',         'list',         'list-item',         'lpage',         'media',         'meta-name',         'meta-value',         'mml:math',         'monospace',         'month',         'name',         'named-content',         'on-behalf-of',         'p',         'patent',         'permissions',         'person-group',         'principal-award-recipient',         'pub-date',         'pub-history',         'pub-id',         'publisher',         'publisher-loc',         'publisher-name',         'ref',         'ref-list',         'related-article',         'related-object',         'role',         'sc',         'sec',         'self-uri',         'source',         'strike',         'string-date',         'string-name',         'styled-content',         'sub',         'sub-article',         'subj-group',         'subject',         'suffix',         'sup',         'supplementary-material',         'surname',         'table',         'table-wrap',         'table-wrap-foot',         'tbody',         'td',         'tex-math',         'th',         'thead',         'title',         'title-group',         'tr',         'underline',         'version',         'volume',         'xref',         'year')"/>
      
      <assert test="name()=$allowed-elements" role="error" id="element-conformity">[element-conformity] <value-of select="name()"/> element is not allowed.</assert>
      
    </rule></pattern>
  
  <pattern id="empty-attribute-test-pattern"><rule context="*[@*/normalize-space(.)='']" id="empty-attribute-test">
      
      
      
      <report test="." role="error" id="final-empty-attribute-conformance">[final-empty-attribute-conformance] <value-of select="name()"/> element has attribute(s) with an empty value. &lt;<value-of select="name()"/><value-of select="for $att in ./@*[normalize-space(.)=''] return concat(' ',$att/name(),'=&quot;',$att,'&quot;')"/>&gt;</report>
      
    </rule></pattern><pattern id="contrib-id-attribute-test-pattern"><rule context="contrib[@contrib-type]" id="contrib-id-attribute-test">
      <let name="allowed-values" value="('author','senior_editor','editor','reviewer')"/>
      
      <assert test="@contrib-type=$allowed-values" role="error" id="contrib-id-value-conformance">[contrib-id-value-conformance] '<value-of select="@contrib-type"/>' is not a permitted value for a <name/> element. The only permitted values are 'author','senior_editor','editor', and 'reviewer'.</assert>
    </rule></pattern><pattern id="content-type-attribute-test-pattern"><rule context="*[@content-type]" id="content-type-attribute-test">
      <let name="allowed-elements" value="('named-content','contrib-group','self-uri','institution','fn-group','disp-quote')"/>
      
      <assert test="name()=$allowed-elements" role="error" id="content-type-value-conformance">[content-type-value-conformance] <name/> element cannot have a content-type attribute. The only elements that can have that can have a content-type attribtue are named-content, contrib-group, self-uri, institution, fn-group, and disp-quote.</assert>
    </rule></pattern>
  
  
  
</schema>