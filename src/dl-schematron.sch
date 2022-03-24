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
  <let name="research-subj" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Correction', 'Retraction', 'Scientific Correspondence', 'Review Article')"/>
  
  <!-- Notice type articles -->
  <let name="notice-article-types" value="('correction','retraction','expression-of-concern')"/>
  <let name="notice-display-types" value="('Correction','Retraction','Expression of Concern')"/>
  
  <!-- All article types -->
  <let name="allowed-article-types" value="('research-article','review-article',$features-article-types, $notice-article-types)"/>
  <let name="allowed-disp-subj" value="($research-subj, $features-subj)"/> 
  
  <let name="MSAs" value="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
  
  <!--=== Custom functions ===-->
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
        <xsl:value-of select="'Expression of Concern:'"/>
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
      <!-- Requires Vendor development work
        <xsl:when test="$s = 'model'">
        <xsl:value-of select="'Model'"/>
      </xsl:when>-->
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
    <xsl:value-of select="replace(replace(replace(translate(normalize-unicode($string,'NFD'),'ƀȼđɇǥħɨıɉꝁłøɍŧɏƶ','bcdeghiijklortyz'),'\p{M}',''),'æ','ae'),'ß','ss')"/>
  </xsl:function>
  
  <!-- generates a string from a reference which is used to determine the position the reference should have in the ref list -->
  <xsl:function name="e:ref-list-string" as="xs:string">
    <xsl:param name="ref"/>
    <xsl:choose>
      <xsl:when test="$ref/element-citation[1]/person-group[1]/* and $ref/element-citation[1]/year">
        <xsl:value-of select="concat(           e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[1]),           ' ',           $ref/element-citation[1]/year[1],           ' ',           string-join(for $x in $ref/element-citation[1]/person-group[1]/*[position()=(2,3)]           return e:get-collab-or-surname($x),' ')           )"/>
      </xsl:when>
      <xsl:when test="$ref/element-citation/person-group[1]/*">
        <xsl:value-of select="concat(           e:get-collab-or-surname($ref/element-citation[1]/person-group[1]/*[1]),           ' 9999 ',           string-join(for $x in $ref/element-citation[1]/person-group[1]/*[position()=(2,3)]           return e:get-collab-or-surname($x),' ')           )"/>
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
        <xsl:value-of select="e:stripDiacritics(lower-case($collab-or-name))"/>
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
  <let name="org-regex" value="'b\.\p{Zs}?subtilis|bacillus\p{Zs}?subtilis|d\.\p{Zs}?melanogaster|drosophila\p{Zs}?melanogaster|e\.\p{Zs}?coli|escherichia\p{Zs}?coli|s\.\p{Zs}?pombe|schizosaccharomyces\p{Zs}?pombe|s\.\p{Zs}?cerevisiae|saccharomyces\p{Zs}?cerevisiae|c\.\p{Zs}?elegans|caenorhabditis\p{Zs}?elegans|a\.\p{Zs}?thaliana|arabidopsis\p{Zs}?thaliana|m\.\p{Zs}?thermophila|myceliophthora\p{Zs}?thermophila|dictyostelium|p\.\p{Zs}?falciparum|plasmodium\p{Zs}?falciparum|s\.\p{Zs}?enterica|salmonella\p{Zs}?enterica|s\.\p{Zs}?pyogenes|streptococcus\p{Zs}?pyogenes|p\.\p{Zs}?dumerilii|platynereis\p{Zs}?dumerilii|p\.\p{Zs}?cynocephalus|papio\p{Zs}?cynocephalus|o\.\p{Zs}?fasciatus|oncopeltus\p{Zs}?fasciatus|n\.\p{Zs}?crassa|neurospora\p{Zs}?crassa|c\.\p{Zs}?intestinalis|ciona\p{Zs}?intestinalis|e\.\p{Zs}?cuniculi|encephalitozoon\p{Zs}?cuniculi|h\.\p{Zs}?salinarum|halobacterium\p{Zs}?salinarum|s\.\p{Zs}?solfataricus|sulfolobus\p{Zs}?solfataricus|s\.\p{Zs}?mediterranea|schmidtea\p{Zs}?mediterranea|s\.\p{Zs}?rosetta|salpingoeca\p{Zs}?rosetta|n\.\p{Zs}?vectensis|nematostella\p{Zs}?vectensis|s\.\p{Zs}?aureus|staphylococcus\p{Zs}?aureus|v\.\p{Zs}?cholerae|vibrio\p{Zs}?cholerae|t\.\p{Zs}?thermophila|tetrahymena\p{Zs}?thermophila|c\.\p{Zs}?reinhardtii|chlamydomonas\p{Zs}?reinhardtii|n\.\p{Zs}?attenuata|nicotiana\p{Zs}?attenuata|e\.\p{Zs}?carotovora|erwinia\p{Zs}?carotovora|e\.\p{Zs}?faecalis|h\.\p{Zs}?sapiens|homo\p{Zs}?sapiens|c\.\p{Zs}?trachomatis|chlamydia\p{Zs}?trachomatis|enterococcus\p{Zs}?faecalis|x\.\p{Zs}?laevis|xenopus\p{Zs}?laevis|x\.\p{Zs}?tropicalis|xenopus\p{Zs}?tropicalis|m\.\p{Zs}?musculus|mus\p{Zs}?musculus|d\.\p{Zs}?immigrans|drosophila\p{Zs}?immigrans|d\.\p{Zs}?subobscura|drosophila\p{Zs}?subobscura|d\.\p{Zs}?affinis|drosophila\p{Zs}?affinis|d\.\p{Zs}?obscura|drosophila\p{Zs}?obscura|f\.\p{Zs}?tularensis|francisella\p{Zs}?tularensis|p\.\p{Zs}?plantaginis|podosphaera\p{Zs}?plantaginis|p\.\p{Zs}?lanceolata|plantago\p{Zs}?lanceolata|m\.\p{Zs}?trossulus|mytilus\p{Zs}?trossulus|m\.\p{Zs}?edulis|mytilus\p{Zs}?edulis|m\.\p{Zs}?chilensis|mytilus\p{Zs}?chilensis|u\.\p{Zs}?maydis|ustilago\p{Zs}?maydis|p\.\p{Zs}?knowlesi|plasmodium\p{Zs}?knowlesi|p\.\p{Zs}?aeruginosa|pseudomonas\p{Zs}?aeruginosa|t\.\p{Zs}?brucei|trypanosoma\p{Zs}?brucei|caulobacter\p{Zs}?crescentus|c\.\p{Zs}?crescentus|agrobacterium\p{Zs}?tumefaciens|a\.\p{Zs}?tumefaciens|t\.\p{Zs}?gondii|toxoplasma\p{Zs}?gondii|d\.\p{Zs}?rerio|danio\p{Zs}?rerio|drosophila|xenopus'"/>
  
  <let name="sec-title-regex" value="string-join(     for $x in tokenize($org-regex,'\|')     return concat('^',$x,'$')     ,'|')"/>
  
  <xsl:function name="e:org-conform" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="matches($s,'b\.\p{Zs}?subtilis')">
        <xsl:value-of select="'B. subtilis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'bacillus\p{Zs}?subtilis')">
        <xsl:value-of select="'Bacillus subtilis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\p{Zs}?melanogaster')">
        <xsl:value-of select="'D. melanogaster'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\p{Zs}?melanogaster')">
        <xsl:value-of select="'Drosophila melanogaster'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\p{Zs}?coli')">
        <xsl:value-of select="'E. coli'"/>
      </xsl:when>
      <xsl:when test="matches($s,'escherichia\p{Zs}?coli')">
        <xsl:value-of select="'Escherichia coli'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?pombe')">
        <xsl:value-of select="'S. pombe'"/>
      </xsl:when>
      <xsl:when test="matches($s,'schizosaccharomyces\p{Zs}?pombe')">
        <xsl:value-of select="'Schizosaccharomyces pombe'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?cerevisiae')">
        <xsl:value-of select="'S. cerevisiae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'saccharomyces\p{Zs}?cerevisiae')">
        <xsl:value-of select="'Saccharomyces cerevisiae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\p{Zs}?elegans')">
        <xsl:value-of select="'C. elegans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'caenorhabditis\p{Zs}?elegans')">
        <xsl:value-of select="'Caenorhabditis elegans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'a\.\p{Zs}?thaliana')">
        <xsl:value-of select="'A. thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'arabidopsis\p{Zs}?thaliana')">
        <xsl:value-of select="'Arabidopsis thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\p{Zs}?thermophila')">
        <xsl:value-of select="'M. thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'myceliophthora\p{Zs}?thermophila')">
        <xsl:value-of select="'Myceliophthora thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'dictyostelium')">
        <xsl:value-of select="'Dictyostelium'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?falciparum')">
        <xsl:value-of select="'P. falciparum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'plasmodium\p{Zs}?falciparum')">
        <xsl:value-of select="'Plasmodium falciparum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?enterica')">
        <xsl:value-of select="'S. enterica'"/>
      </xsl:when>
      <xsl:when test="matches($s,'salmonella\p{Zs}?enterica')">
        <xsl:value-of select="'Salmonella enterica'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?pyogenes')">
        <xsl:value-of select="'S. pyogenes'"/>
      </xsl:when>
      <xsl:when test="matches($s,'streptococcus\p{Zs}?pyogenes')">
        <xsl:value-of select="'Streptococcus pyogenes'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?dumerilii')">
        <xsl:value-of select="'P. dumerilii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'platynereis\p{Zs}?dumerilii')">
        <xsl:value-of select="'Platynereis dumerilii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?cynocephalus')">
        <xsl:value-of select="'P. cynocephalus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'papio\p{Zs}?cynocephalus')">
        <xsl:value-of select="'Papio cynocephalus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'o\.\p{Zs}?fasciatus')">
        <xsl:value-of select="'O. fasciatus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'oncopeltus\p{Zs}?fasciatus')">
        <xsl:value-of select="'Oncopeltus fasciatus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'n\.\p{Zs}?crassa')">
        <xsl:value-of select="'N. crassa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'neurospora\p{Zs}?crassa')">
        <xsl:value-of select="'Neurospora crassa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\p{Zs}?intestinalis')">
        <xsl:value-of select="'C. intestinalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'ciona\p{Zs}?intestinalis')">
        <xsl:value-of select="'Ciona intestinalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\p{Zs}?cuniculi')">
        <xsl:value-of select="'E. cuniculi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'encephalitozoon\p{Zs}?cuniculi')">
        <xsl:value-of select="'Encephalitozoon cuniculi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'h\.\p{Zs}?salinarum')">
        <xsl:value-of select="'H. salinarum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'halobacterium\p{Zs}?salinarum')">
        <xsl:value-of select="'Halobacterium salinarum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?solfataricus')">
        <xsl:value-of select="'S. solfataricus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'sulfolobus\p{Zs}?solfataricus')">
        <xsl:value-of select="'Sulfolobus solfataricus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?mediterranea')">
        <xsl:value-of select="'S. mediterranea'"/>
      </xsl:when>
      <xsl:when test="matches($s,'schmidtea\p{Zs}?mediterranea')">
        <xsl:value-of select="'Schmidtea mediterranea'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?rosetta')">
        <xsl:value-of select="'S. rosetta'"/>
      </xsl:when>
      <xsl:when test="matches($s,'salpingoeca\p{Zs}?rosetta')">
        <xsl:value-of select="'Salpingoeca rosetta'"/>
      </xsl:when>
      <xsl:when test="matches($s,'n\.\p{Zs}?vectensis')">
        <xsl:value-of select="'N. vectensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'nematostella\p{Zs}?vectensis')">
        <xsl:value-of select="'Nematostella vectensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?aureus')">
        <xsl:value-of select="'S. aureus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'staphylococcus\p{Zs}?aureus')">
        <xsl:value-of select="'Staphylococcus aureus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'a\.\p{Zs}?thaliana')">
        <xsl:value-of select="'A. thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'arabidopsis\p{Zs}?thaliana')">
        <xsl:value-of select="'Arabidopsis thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'v\.\p{Zs}?cholerae')">
        <xsl:value-of select="'V. cholerae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'vibrio\p{Zs}?cholerae')">
        <xsl:value-of select="'Vibrio cholerae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'t\.\p{Zs}?thermophila')">
        <xsl:value-of select="'T. thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'tetrahymena\p{Zs}?thermophila')">
        <xsl:value-of select="'Tetrahymena thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\p{Zs}?reinhardtii')">
        <xsl:value-of select="'C. reinhardtii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'chlamydomonas\p{Zs}?reinhardtii')">
        <xsl:value-of select="'Chlamydomonas reinhardtii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'n\.\p{Zs}?attenuata')">
        <xsl:value-of select="'N. attenuata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'nicotiana\p{Zs}?attenuata')">
        <xsl:value-of select="'Nicotiana attenuata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\p{Zs}?carotovora')">
        <xsl:value-of select="'E. carotovora'"/>
      </xsl:when>
      <xsl:when test="matches($s,'erwinia\p{Zs}?carotovora')">
        <xsl:value-of select="'Erwinia carotovora'"/>
      </xsl:when>
      <xsl:when test="matches($s,'h\.\p{Zs}?sapiens')">
        <xsl:value-of select="'H. sapiens'"/>
      </xsl:when>
      <xsl:when test="matches($s,'homo\p{Zs}?sapiens')">
        <xsl:value-of select="'Homo sapiens'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\p{Zs}?faecalis')">
        <xsl:value-of select="'E. faecalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'enterococcus\p{Zs}?faecalis')">
        <xsl:value-of select="'Enterococcus faecalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\p{Zs}?trachomatis')">
        <xsl:value-of select="'C. trachomatis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'chlamydia\p{Zs}?trachomatis')">
        <xsl:value-of select="'Chlamydia trachomatis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'x\.\p{Zs}?laevis')">
        <xsl:value-of select="'X. laevis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'xenopus\p{Zs}?laevis')">
        <xsl:value-of select="'Xenopus laevis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'x\.\p{Zs}?tropicalis')">
        <xsl:value-of select="'X. tropicalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'xenopus\p{Zs}?tropicalis')">
        <xsl:value-of select="'Xenopus tropicalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\p{Zs}?musculus')">
        <xsl:value-of select="'M. musculus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mus\p{Zs}?musculus')">
        <xsl:value-of select="'Mus musculus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\p{Zs}?immigrans')">
        <xsl:value-of select="'D. immigrans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\p{Zs}?immigrans')">
        <xsl:value-of select="'Drosophila immigrans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\p{Zs}?subobscura')">
        <xsl:value-of select="'D. subobscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\p{Zs}?subobscura')">
        <xsl:value-of select="'Drosophila subobscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\p{Zs}?affinis')">
        <xsl:value-of select="'D. affinis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\p{Zs}?affinis')">
        <xsl:value-of select="'Drosophila affinis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\p{Zs}?obscura')">
        <xsl:value-of select="'D. obscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\p{Zs}?obscura')">
        <xsl:value-of select="'Drosophila obscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'f\.\p{Zs}?tularensis')">
        <xsl:value-of select="'F. tularensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'francisella\p{Zs}?tularensis')">
        <xsl:value-of select="'Francisella tularensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?plantaginis')">
        <xsl:value-of select="'P. plantaginis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'podosphaera\p{Zs}?plantaginis')">
        <xsl:value-of select="'Podosphaera plantaginis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?lanceolata')">
        <xsl:value-of select="'P. lanceolata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'plantago\p{Zs}?lanceolata')">
        <xsl:value-of select="'Plantago lanceolata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\p{Zs}?edulis')">
        <xsl:value-of select="'M. edulis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mytilus\p{Zs}?edulis')">
        <xsl:value-of select="'Mytilus edulis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\p{Zs}?chilensis')">
        <xsl:value-of select="'M. chilensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mytilus\p{Zs}?chilensis')">
        <xsl:value-of select="'Mytilus chilensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\p{Zs}?trossulus')">
        <xsl:value-of select="'M. trossulus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mytilus\p{Zs}?trossulus')">
        <xsl:value-of select="'Mytilus trossulus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'u\.\p{Zs}?maydis')">
        <xsl:value-of select="'U. maydis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'ustilago\p{Zs}?maydis')">
        <xsl:value-of select="'Ustilago maydis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?knowlesi')">
        <xsl:value-of select="'P. knowlesi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'plasmodium\p{Zs}?knowlesi')">
        <xsl:value-of select="'Plasmodium knowlesi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?aeruginosa')">
        <xsl:value-of select="'P. aeruginosa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'pseudomonas\p{Zs}?aeruginosa')">
        <xsl:value-of select="'Pseudomonas aeruginosa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'t\.\p{Zs}?brucei')">
        <xsl:value-of select="'T. brucei'"/>
      </xsl:when>
      <xsl:when test="matches($s,'trypanosoma\p{Zs}?brucei')">
        <xsl:value-of select="'Trypanosoma brucei'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\p{Zs}?crescentus')">
        <xsl:value-of select="'C. crescentus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'caulobacter\p{Zs}?crescentus')">
        <xsl:value-of select="'Caulobacter crescentus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'a\.\p{Zs}?tumefaciens')">
        <xsl:value-of select="'A. tumefaciens'"/>
      </xsl:when>
      <xsl:when test="matches($s,'agrobacterium\.\p{Zs}?tumefaciens')">
        <xsl:value-of select="'Agrobacterium tumefaciens'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\p{Zs}?rerio')">
        <xsl:value-of select="'D. rerio'"/>
      </xsl:when>
      <xsl:when test="matches($s,'danio\p{Zs}?rerio')">
        <xsl:value-of select="'Danio rerio'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila')">
        <xsl:value-of select="'Drosophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'xenopus')">
        <xsl:value-of select="'Xenopus'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undefined'"/>
      </xsl:otherwise>
    </xsl:choose>
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
        <xsl:choose>
          <xsl:when test="$contrib-group/contrib[@contrib-type='author'][1]/collab">
            <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author']/collab[1]/text()[1],' et al')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/name[1]/surname[1],' et al')"/>
          </xsl:otherwise>
        </xsl:choose>
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
  
  
  
  
 <pattern id="research-article-pattern">
    <rule context="article[@article-type='research-article']" id="research-article">
	  <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
	  <let name="version" value="e:get-version(.)"/>
	  
	  <report test="if ($version='1') then ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])      else ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='referee-report'])" role="warning" flag="dl-ar" id="test-r-article-d-letter">A decision letter should almost always be present for research articles. This one doesn't have one. Check that this is correct.</report>
	  
	  <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/feature-content#final-test-r-article-d-letter-feat" test="if ($version='1') then ($disp-channel = 'Feature Article') and not(sub-article[@article-type='decision-letter'])      else ($disp-channel = 'Feature Article') and not(sub-article[@article-type='referee-report'])" role="warning" flag="dl-ar" id="final-test-r-article-d-letter-feat">A decision letter should be present for research articles. Feature template 5s almost always have a decision letter, but this one does not. Is that correct?</report>
		
	  <report test="if ($version='1') then ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='reply'])      else ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='author-comment'])" role="warning" flag="dl-ar" id="test-r-article-a-reply">Author response should usually be present for research articles, but this one does not have one. Is that correct?</report>
	
	</rule>
  </pattern>
  <pattern id="research-article-sub-article-pattern">
    <rule context="article[@article-type='research-article' and sub-article]" id="research-article-sub-article">
     <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
     <let name="version" value="e:get-version(.)"/>
     
     <report test="if ($version='1') then ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type!='reply'])        else ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type!='author-comment'])" flag="dl-ar" role="error" id="r-article-sub-articles">
        <value-of select="$disp-channel"/> type articles cannot have only an Author response. The following combinations of peer review-material are permitted: Editor's evaluation, Decision letter, and Author response; Decision letter, and Author response; Editor's evaluation and Decision letter; Editor's evaluation and Author response; or Decision letter.</report>
     
   </rule>
  </pattern>

  

  

  
  
  

   	
  
  <pattern id="ar-fig-tests-pattern">
    <rule context="fig[ancestor::sub-article[@article-type='reply']]" id="ar-fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(ancestor::body//fig)"/>
      <let name="pos" value="$count - count(following::fig)"/>
      <let name="no" value="substring-after(@id,'fig')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#ar-fig-test-2" test="if ($article-type = ($features-article-types,$notice-article-types)) then ()         else not(label)" role="error" flag="dl-ar" id="ar-fig-test-2">Author Response fig must have a label.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-ar-fig-test-3" test="graphic" role="warning" flag="dl-ar" id="pre-ar-fig-test-3">Author Response fig does not have graphic. Ensure author query is added asking for file.</assert>
      
      
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-ar-fig-position-test" test="$no = string($pos)" role="warning" flag="dl-ar" id="pre-ar-fig-position-test">
        <value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR images it is placed in position <value-of select="$pos"/>.</assert>
      
      
    </rule>
  </pattern>
  <pattern id="disp-quote-tests-pattern">
    <rule context="disp-quote" id="disp-quote-tests">
      <let name="subj" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="ancestor::sub-article[@article-type='decision-letter']" role="warning" flag="dl-ar" id="disp-quote-test-1">Content is tagged as a display quote, which is almost definitely incorrect, since it's in a decision letter - <value-of select="."/>
      </report>
      
      
    </rule>
  </pattern>
  
  <pattern id="dl-video-specific-pattern">
    <rule context="sub-article[@article-type=('decision-letter','referee-report')]/body//media[@mimetype='video']" id="dl-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video' and ancestor::sub-article/@article-type=('decision-letter','referee-report')])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      <assert test="$no = string($pos)" role="warning" flag="dl-ar" id="pre-dl-video-position-test">
        <value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other DL videos it is placed in position <value-of select="$pos"/>.</assert>
      
      
    </rule>
  </pattern>
  <pattern id="ar-video-specific-pattern">
    <rule context="sub-article[@article-type=('reply','author-comment')]/body//media[@mimetype='video']" id="ar-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      <assert test="$no = string($pos)" role="warning" flag="dl-ar" id="pre-ar-video-position-test">
        <value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
      
      
    </rule>
  </pattern>
  
  
  
  <pattern id="rep-fig-tests-pattern">
    <rule context="sub-article[@article-type='reply']//fig" id="rep-fig-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-test-2" test="label" role="error" flag="dl-ar" id="resp-fig-test-2">fig must have a label.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#reply-fig-test-2" test="matches(label[1],'^Author response image [0-9]{1,3}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" role="error" flag="dl-ar" id="reply-fig-test-2">fig label in author response must be in the format 'Author response image 1.', or 'Chemical Structure 1.', or 'Scheme 1.'.</assert>
      
    </rule>
  </pattern>
  <pattern id="dec-fig-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']//fig" id="dec-fig-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#dec-fig-test-1" test="label" role="error" flag="dl-ar" id="dec-fig-test-1">fig must have a label.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#dec-fig-test-2" test="matches(label[1],'^Decision letter image [0-9]{1,3}\.$')" role="error" flag="dl-ar" id="dec-fig-test-2">fig label in author response must be in the format 'Decision letter image 1.'.</assert>
      
    </rule>
  </pattern>
  
  
  
  <pattern id="ed-eval-title-tests-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/title-group" id="ed-eval-title-tests">
      
      <assert test="article-title = &quot;Editor's evaluation&quot;" role="error" flag="dl-ar" id="ed-eval-title-test">title-group must contain article-title which contains "Editor's evaluation". Currently it is <value-of select="article-title"/>.</assert>
    </rule>
  </pattern>
  <pattern id="dec-letter-title-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']/front-stub/title-group" id="dec-letter-title-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-title-test" test="article-title = 'Decision letter'" role="error" flag="dl-ar" id="dec-letter-title-test">title-group must contain article-title which contains 'Decision letter'. Currently it is <value-of select="article-title"/>.</assert>
    </rule>
  </pattern>
  <pattern id="reply-title-tests-pattern">
    <rule context="sub-article[@article-type='reply']/front-stub/title-group" id="reply-title-tests">
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-title-test" test="article-title = 'Author response'" role="error" flag="dl-ar" id="reply-title-test">title-group must contain article-title which contains 'Author response'. Currently it is <value-of select="article-title"/>.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="rep-fig-ids-pattern">
    <rule context="sub-article//fig[not(@specific-use='child-fig')]" id="rep-fig-ids">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-id-test" test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')" role="error" flag="dl-ar" id="resp-fig-id-test">fig in decision letter/author response must have @id in the format respfig0, or sa0fig0. <value-of select="@id"/> does not conform to this.</assert>
    </rule>
  </pattern>
  <pattern id="rep-fig-sup-ids-pattern">
    <rule context="sub-article//fig[@specific-use='child-fig']" id="rep-fig-sup-ids">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-sup-id-test" test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')" role="error" flag="dl-ar" id="resp-fig-sup-id-test">figure supplement in decision letter/author response must have @id in the format respfig0s0 or sa0fig0s0. <value-of select="@id"/> does not conform to this.</assert>
      
    </rule>
  </pattern>
  <pattern id="disp-formula-ids-pattern">
    <rule context="disp-formula" id="disp-formula-ids">
      
      
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/maths#sub-disp-formula-id-test" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-disp-formula-id-test">disp-formula @id must be in the format 'sa0equ0' when in a sub-article.  <value-of select="@id"/> does not conform to this.</report>
    </rule>
  </pattern>
  <pattern id="mml-math-ids-pattern">
    <rule context="disp-formula/mml:math" id="mml-math-ids">
      
      
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/maths#sub-mml-math-id-test" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-mml-math-id-test">mml:math @id in disp-formula must be in the format 'sa0m0'.  <value-of select="@id"/> does not conform to this.</report>
    </rule>
  </pattern>
  <pattern id="resp-table-wrap-ids-pattern">
    <rule context="sub-article//table-wrap" id="resp-table-wrap-ids">
 
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#resp-table-wrap-id-test" test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$')         else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')" role="warning" flag="dl-ar" id="resp-table-wrap-id-test">table-wrap @id in a sub-article must be in the format 'resptable0' or 'sa0table0' if it has a label, or in the format 'respinlinetable0' or 'sa0inlinetable0' if it does not.</assert>
    </rule>
  </pattern>
  
  
  
  
  
  
  
  <pattern id="dec-letter-reply-tests-pattern">
    <rule context="article/sub-article" id="dec-letter-reply-tests">
      <let name="version" value="e:get-version(.)"/>
      <let name="id-convention" value="if (@article-type='editor-report') then 'sa0'         else if (@article-type=('decision-letter','referee-report')) then 'sa1'         else if (@article-type=('reply','author-comment')) then 'sa2'         else 'unknown'"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-1" test="@article-type=('editor-report','referee-report','author-comment','decision-letter','reply')" role="error" flag="dl-ar" id="dec-letter-reply-test-1">sub-article must must have an article-type which is equal to one of the following values: 'editor-report','decision-letter', or 'reply'.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-2" test="@id = $id-convention" role="error" flag="dl-ar" id="dec-letter-reply-test-2">sub-article id is <value-of select="@id"/> when based on it's article-type it should be <value-of select="$id-convention"/>.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-3" test="count(front-stub) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-3">sub-article must contain one and only one front-stub.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-4" test="count(body) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-4">sub-article must contain one and only one body.</assert>
      
      <report test="$version='1' and @article-type='referee-report'" role="warning" flag="dl-ar" id="sub-article-1">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in version 1 xml. Either, this needs to be made version 2 xml, or 'decision-letter' should be used in place of <value-of select="@article-type"/>.</report>
      
      <report test="$version='1' and @article-type='author-comment'" role="warning" flag="dl-ar" id="sub-article-2">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in version 1 xml. Either, this needs to be made version 2 xml, or 'reply' should be used in place of '<value-of select="@article-type"/>'.</report>
      
      <report test="$version!='1' and @article-type='decision-letter'" role="warning" flag="dl-ar" id="sub-article-3">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in version 2 xml. Either, this needs to be made version 1 xml, or 'referee-report' should be used in place of <value-of select="@article-type"/>.</report>
      
      <report test="$version!='1' and @article-type='reply'" role="warning" flag="dl-ar" id="sub-article-4">'<value-of select="@article-type"/>' is not permitted as the article-type for a sub-article in version 2 xml. Either, this needs to be made version 1 xml, or 'author-comment' should be used in place of <value-of select="@article-type"/>.</report>
      
    </rule>
  </pattern>
  <pattern id="dec-letter-reply-content-tests-pattern">
    <rule context="article/sub-article//p" id="dec-letter-reply-content-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-5" test="matches(.,'&lt;[/]?[Aa]uthor response')" role="error" flag="dl-ar" id="dec-letter-reply-test-5">
        <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what looks like pseudo-code - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-6" test="matches(.,'&lt;\p{Zs}?/?\p{Zs}?[a-z]*\p{Zs}?/?\p{Zs}?&gt;')" role="warning" flag="dl-ar" id="dec-letter-reply-test-6">
        <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be pseudo-code or tags which should likely be removed - <value-of select="."/>.</report>
    </rule>
  </pattern>
  <pattern id="dec-letter-reply-content-tests-2-pattern">
    <rule context="article/sub-article//p[not(ancestor::disp-quote)]" id="dec-letter-reply-content-tests-2">
      <let name="regex" value="'\p{Zs}([Oo]ffensive|[Oo]ffended|[Uu]nproff?essional|[Rr]ude|[Cc]onflict\p{Zs}[Oo]f\p{Zs}[Ii]nterest|([Aa]re|[Aa]m)\p{Zs}[Ss]hocked|[Ss]trongly\p{Zs}[Dd]isagree)[^\p{L}]'"/>
      
      <!-- Need to improve messaging -->
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-7" test="matches(.,$regex)" role="warning" flag="dl-ar" id="dec-letter-reply-test-7">
        <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be inflammatory or offensive language. eLife: please check it to see if it is language that should be removed. This paragraph was flagged because of the phrase(s) <value-of select="string-join(tokenize(.,'\p{Zs}')[matches(.,concat('^',substring-before(substring-after($regex,'\p{Zs}'),'[^\p{L}]')))],'; ')"/> in <value-of select="."/>.</report>
    </rule>
  </pattern>
  <pattern id="ed-eval-front-tests-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub" id="ed-eval-front-tests">
      
      <assert test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="ed-eval-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert test="count(contrib-group) = 1" role="error" flag="dl-ar" id="ed-eval-front-test-2">editor evaluation front-stub must contain 1 (and only 1) contrib-group element. This one has <value-of select="count(contrib-group)"/>.</assert>
      
      <report test="count(related-object) gt 1" role="error" flag="dl-ar" id="ed-eval-front-test-3">editor evaluation front-stub must contain 1 or 0 related-object elements. This one has <value-of select="count(related-object)"/>.</report>
    </rule>
  </pattern>
  <pattern id="ed-eval-front-child-tests-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/*" id="ed-eval-front-child-tests">
      
      <assert test="name()=('article-id','title-group','contrib-group','related-object')" role="error" flag="dl-ar" id="ed-eval-front-child-test-1">
        <name/> element is not allowed in the front-stub for an Editor's evaluation. Only the following elements are permitted: article-id, title-group, contrib-group, related-object.</assert>
    </rule>
  </pattern>
  <pattern id="ed-eval-contrib-group-tests-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/contrib-group" id="ed-eval-contrib-group-tests">
      
      <assert test="count(contrib[@contrib-type='author']) = 1" role="error" flag="dl-ar" id="ed-eval-contrib-group-test-1">editor evaluation contrib-group must contain 1 contrib[@contrib-type='author'].</assert>
    </rule>
  </pattern>
  <pattern id="ed-eval-author-tests-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/contrib-group/contrib[@contrib-type='author' and name]" id="ed-eval-author-tests">
      <let name="rev-ed-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section'][1]/contrib[@contrib-type='editor'][1]/name[1])"/>
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert test="$name = $rev-ed-name" role="error" flag="dl-ar" id="ed-eval-author-test-1">The author of the editor evaluation must be the same as the Reviewing editor for the article. The Reviewing editor is <value-of select="$rev-ed-name"/>, but the editor evaluation author is <value-of select="$name"/>.</assert>
    </rule>
  </pattern>
  <pattern id="ed-eval-rel-obj-tests-pattern">
    <rule context="sub-article[@article-type='editor-report']/front-stub/related-object" id="ed-eval-rel-obj-tests">
      <let name="event-preprint-doi" value="for $x in ancestor::article//article-meta/pub-history/event[1]/self-uri[@content-type='preprint'][1]/@xlink:href                                         return substring-after($x,'.org/')"/>
      
      <assert test="matches(@id,'^sa0ro\d$')" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-1">related-object in editor's evaluation must have an id in the format sa0ro1. <value-of select="@id"/> does not meet this convention.</assert>
      
      <assert test="@object-id-type='id'" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-2">related-object in editor's evaluation must have an object-id-type="id" attribute.</assert>
      
      <assert test="@link-type='continued-by'" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-3">related-object in editor's evaluation must have a link-type="continued-by" attribute.</assert>
      
      <assert test="matches(@object-id,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-4">related-object in editor's evaluation must have an object-id attribute which is a doi. '<value-of select="@object-id"/>' is not a valid doi.</assert>
      
      <assert test="@object-id = $event-preprint-doi" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-5">related-object in editor's evaluation must have an object-id attribute whose value is the same as the preprint doi in the article's pub-history. object-id '<value-of select="@object-id"/>' is not the same as the preprint doi in the event history, '<value-of select="$event-preprint-doi"/>'.</assert>
      
      <assert test="@xlink:href = concat('https://sciety.org/articles/activity/',@object-id)" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-6">related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the object-id attribute value (which must be a doi). '<value-of select="@xlink:href"/>' is not equal to <value-of select="concat('https://sciety.org/articles/activity/',@object-id)"/>. Which is correct?</assert>
      
      <assert test="@xlink:href = concat('https://sciety.org/articles/activity/',$event-preprint-doi)" role="error" flag="dl-ar" id="ed-eval-rel-obj-test-7">related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the preprint doi in the article's pub-history. xlink:href '<value-of select="@xlink:href"/>' is not the same as '<value-of select="concat('https://sciety.org/articles/activity/',$event-preprint-doi)"/>'. Which is correct?</assert>
      
    </rule>
  </pattern>
  <pattern id="dec-letter-front-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']/front-stub" id="dec-letter-front-tests">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="dec-letter-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-2" test="$count gt 0" role="error" flag="dl-ar" id="dec-letter-front-test-2">decision letter front-stub must contain at least 1 contrib-group element.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-3" test="$count gt 2" role="error" flag="dl-ar" id="dec-letter-front-test-3">decision letter front-stub contains more than 2 contrib-group elements.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-4" test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'(All|The) reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/|doi.org/10.24072/pci.evolbiol')])" role="warning" flag="dl-ar" id="dec-letter-front-test-4">decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviewing editor) anonymous? The text 'The reviewers have opted to remain anonymous' or 'The reviewer has opted to remain anonymous' is not present and there is no link to Review commons or a Peer Community in Evolutionary Biology doi in the decision letter.</report>
    </rule>
  </pattern>
  <pattern id="dec-letter-editor-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]" id="dec-letter-editor-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-1" test="count(contrib[@contrib-type='editor']) = 1" role="warning" flag="dl-ar" id="dec-letter-editor-test-1">First contrib-group in decision letter must contain 1 and only 1 editor (contrib[@contrib-type='editor']).</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-2" test="contrib[not(@contrib-type) or @contrib-type!='editor']" role="warning" flag="dl-ar" id="dec-letter-editor-test-2">First contrib-group in decision letter contains a contrib which is not marked up as an editor (contrib[@contrib-type='editor']).</report>
    </rule>
  </pattern>
  <pattern id="dec-letter-editor-tests-2-pattern">
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]/contrib[@contrib-type='editor']" id="dec-letter-editor-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role[1]"/>
      <!--<let name="top-role" value="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[e:get-name(name[1])=$name]/role"/>-->
      <!--<let name="top-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[role=$role]/name[1])"/>-->
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-3" test="$role=('Reviewing Editor','Senior and Reviewing Editor')" role="error" flag="dl-ar" id="dec-letter-editor-test-3">Editor in decision letter front-stub must have the role 'Reviewing Editor' or 'Senior and Reviewing Editor'. <value-of select="$name"/> has '<value-of select="$role"/>'.</assert>
      
      <!--<report test="($top-name!='') and ($top-name!=$name)"
        role="error"
        id="dec-letter-editor-test-5">In decision letter <value-of select="$name"/> is a <value-of select="$role"/>, but in the top-level article details <value-of select="$top-name"/> is the <value-of select="$role"/>.</report>-->
    </rule>
  </pattern>
  <pattern id="dec-letter-reviewer-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]" id="dec-letter-reviewer-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-1" test="count(contrib[@contrib-type='reviewer']) gt 0" role="error" flag="dl-ar" id="dec-letter-reviewer-test-1">Second contrib-group in decision letter must contain a reviewer (contrib[@contrib-type='reviewer']).</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-2" test="contrib[not(@contrib-type) or @contrib-type!='reviewer']" role="error" flag="dl-ar" id="dec-letter-reviewer-test-2">Second contrib-group in decision letter contains a contrib which is not marked up as a reviewer (contrib[@contrib-type='reviewer']).</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-6" test="count(contrib[@contrib-type='reviewer']) gt 5" role="warning" flag="dl-ar" id="dec-letter-reviewer-test-6">Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</report>
    </rule>
  </pattern>
  <pattern id="dec-letter-reviewer-tests-2-pattern">
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]/contrib[@contrib-type='reviewer']" id="dec-letter-reviewer-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-3" test="role='Reviewer'" role="error" flag="dl-ar" id="dec-letter-reviewer-test-3">Reviewer in decision letter front-stub must have the role 'Reviewer'. <value-of select="$name"/> has '<value-of select="role"/>'.</assert>
    </rule>
  </pattern>
  <pattern id="dec-letter-body-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']/body" id="dec-letter-body-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-1" test="child::*[1]/local-name() = 'boxed-text'" role="error" flag="dl-ar" id="dec-letter-body-test-1">First child element in decision letter is not boxed-text. This is certainly incorrect.</assert>
    </rule>
  </pattern>
  <pattern id="dec-letter-body-p-tests-pattern">
    <rule context="sub-article[@article-type=('decision-letter','referee-report')]/body//p" id="dec-letter-body-p-tests">  
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-2" test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])" role="error" flag="dl-ar" id="dec-letter-body-test-2">The text 'Review Commons' in '<value-of select="."/>' must contain an embedded link pointing to https://www.reviewcommons.org/.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-3" test="contains(lower-case(.),'reviewed and recommended by peer community in evolutionary biology') and not(child::ext-link[matches(@xlink:href,'doi.org/10.24072/pci.evolbiol')])" role="error" flag="dl-ar" id="dec-letter-body-test-3">The decision letter indicates that this article was reviewed by PCI evol bio, but there is no doi link with the prefix '10.24072/pci.evolbiol' which must be incorrect.</report>
    </rule>
  </pattern>
  <pattern id="dec-letter-box-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']/body/boxed-text[1]" id="dec-letter-box-tests">  
      <let name="permitted-text-1" value="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below.$'"/>
      <let name="permitted-text-2" value="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below. We also include an acceptance summary that explains what the editors found interesting or important about the work.$'"/>
      <let name="permitted-text-3" value="'^In the interests of transparency, eLife publishes the most substantive revision requests and the accompanying author responses.$'"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-box-test-1" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2,'|',$permitted-text-3))" role="warning" flag="dl-ar" id="dec-letter-box-test-1">The text at the top of the decision letter is not correct - '<value-of select="."/>'. It has to be one of the three paragraphs which are permitted (see the GitBook page for these paragraphs).</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-box-test-2" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[contains(@xlink:href,'sciety.org/') and .='public reviews'])" role="error" flag="dl-ar" id="dec-letter-box-test-2">At the top of the decision letter, the text 'public reviews' must contain an embedded link to Sciety where the public review for this article's preprint is located.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-box-test-3" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[.='the preprint'])" role="error" flag="dl-ar" id="dec-letter-box-test-3">At the top of the decision letter, the text 'the preprint' must contain an embedded link to this article's preprint.</report>
    </rule>
  </pattern>
  <pattern id="decision-missing-table-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']" id="decision-missing-table-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#decision-missing-table-test" test="contains(.,'letter table') and not(descendant::table-wrap[label])" role="warning" flag="dl-ar" id="decision-missing-table-test">A decision letter table is referred to in the text, but there is no table in the decision letter with a label.</report>
    </rule>
  </pattern>
  <pattern id="reply-front-tests-pattern">
    <rule context="sub-article[@article-type='reply']/front-stub" id="reply-front-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="reply-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
    </rule>
  </pattern>
  <pattern id="reply-body-tests-pattern">
    <rule context="sub-article[@article-type='reply']/body" id="reply-body-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-body-test-1" test="count(disp-quote[@content-type='editor-comment']) = 0" role="warning" flag="dl-ar" id="reply-body-test-1">author response doesn't contain a disp-quote. This is very likely to be incorrect. Please check the original file.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-body-test-2" test="count(p) = 0" role="error" flag="dl-ar" id="reply-body-test-2">author response doesn't contain a p. This has to be incorrect.</report>
    </rule>
  </pattern>
  <pattern id="reply-disp-quote-tests-pattern">
    <rule context="sub-article[@article-type='reply']/body//disp-quote" id="reply-disp-quote-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-disp-quote-test-1" test="@content-type='editor-comment'" role="warning" flag="dl-ar" id="reply-disp-quote-test-1">disp-quote in author reply does not have @content-type='editor-comment'. This is almost certainly incorrect.</assert>
    </rule>
  </pattern>
  <pattern id="reply-missing-disp-quote-tests-pattern">
    <rule context="sub-article[@article-type='reply']/body//p[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests">
      <let name="free-text" value="replace(         normalize-space(string-join(for $x in self::*/text() return $x,''))         ,' ','')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-disp-quote-test-1" test="(count(*)=1) and (child::italic) and ($free-text='')" role="warning" flag="dl-ar" id="reply-missing-disp-quote-test-1">para in author response is entirely in italics, but not in a display quote. Is this a quote which has been processed incorrectly?</report>
    </rule>
  </pattern>
  <pattern id="reply-missing-disp-quote-tests-2-pattern">
    <rule context="sub-article[@article-type='reply']//italic[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests-2">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-disp-quote-test-2" test="string-length(.) ge 50" role="warning" flag="dl-ar" id="reply-missing-disp-quote-test-2">A long piece of text is in italics in an Author response paragraph. Should it be captured as a display quote in a separate paragraph? '<value-of select="."/>' in '<value-of select="ancestor::*[local-name()='p'][1]"/>'</report>
    </rule>
  </pattern>
  <pattern id="reply-missing-table-tests-pattern">
    <rule context="sub-article[@article-type='reply']" id="reply-missing-table-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-table-test" test="contains(.,'response table') and not(descendant::table-wrap[label])" role="warning" flag="dl-ar" id="reply-missing-table-test">An author response table is referred to in the text, but there is no table in the response with a label.</report>
    </rule>
  </pattern>
  <pattern id="sub-article-ext-link-tests-pattern">
    <rule context="sub-article//ext-link" id="sub-article-ext-link-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#paper-pile-test" test="contains(@xlink:href,'paperpile.com')" role="error" flag="dl-ar" id="paper-pile-test">In the <value-of select="if (ancestor::sub-article[@article-type='reply']) then 'author response' else 'decision letter'"/> the text '<value-of select="."/>' has an embedded hyperlink to <value-of select="@xlink:href"/>. The hyperlink should be removed (but the text retained).</report>
    </rule>
  </pattern>
  <pattern id="sub-article-ref-p-tests-pattern">
    <rule context="sub-article[@article-type='reply']/body/*[last()][name()='p']" id="sub-article-ref-p-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#sub-article-ref-p-test" test="count(tokenize(lower-case(.),'doi\p{Zs}?:')) gt 2" role="warning" flag="dl-ar" id="sub-article-ref-p-test">The last paragraph of the author response looks like it contains various references. Should each reference be split out into its own paragraph? <value-of select="."/>
      </report>
    </rule>
  </pattern>
  
  <pattern id="ref-report-front-pattern">
    <rule context="sub-article[@article-type='referee-report']/front-stub" id="ref-report-front">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="ref-report-front-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert test="$count = 2" role="error" flag="dl-ar" id="ref-report-front-2">sub-article front-stub must contain 2 contrib-group elements.</assert>
    </rule>
  </pattern>
  <pattern id="sub-article-contrib-tests-pattern">
    <rule context="sub-article[@article-type=('editor-report','referee-report','author-comment')]/front-stub/contrib-group/contrib" id="sub-article-contrib-tests">
      
      <assert test="@contrib-type='author'" role="error" flag="dl-ar" id="sub-article-contrib-test-1">contrib inside sub-article with article-type '<value-of select="ancestor::sub-article/@article-type"/>' must have the attribute contrib-type='author'.</assert>
      
      <assert test="name or anonymous or collab" role="error" flag="dl-ar" id="sub-article-contrib-test-2">sub-article contrib must have either a child name or a child anonymous element.</assert>
      
      <report test="(name and anonymous) or (collab and anonymous) or (name and collab)" role="error" flag="dl-ar" id="sub-article-contrib-test-3">sub-article contrib can only have a child name element or a child anonymous element or a child collab element (with descendant group members as required), it cannot have more than one of these elements. This has <value-of select="string-join(for $x in *[name()=('name','anonymous','collab')] return concat('a ',$x/name()),' and ')"/>.</report>
      
      <assert test="role" role="error" flag="dl-ar" id="sub-article-contrib-test-4">contrib inside sub-article with article-type '<value-of select="ancestor::sub-article/@article-type"/>' must have a child role element.</assert>
      
    </rule>
  </pattern>
  <pattern id="sub-article-role-tests-pattern">
    <rule context="sub-article/front-stub/contrib-group/contrib/role" id="sub-article-role-tests">
      <let name="sub-article-type" value="ancestor::sub-article[1]/@article-type"/>
      
      <report test="$sub-article-type='referee-report' and parent::contrib/parent::contrib-group[not(preceding-sibling::contrib-group)] and not(@specific-use='editor')" role="error" flag="dl-ar" id="sub-article-role-test-1">The role element for contributors in the first contrib-group in the decision letter must have the attribute specific-use='editor'.</report>
      
      <report test="$sub-article-type='referee-report' and parent::contrib/parent::contrib-group[not(following-sibling::contrib-group)] and not(@specific-use='referee')" role="error" flag="dl-ar" id="sub-article-role-test-2">The role element for contributors in the second contrib-group in the decision letter must have the attribute specific-use='referee'.</report>
      
      <report test="$sub-article-type='author-comment' and not(@specific-use='author')" role="error" flag="dl-ar" id="sub-article-role-test-3">The role element for contributors in the author response must have the attribute specific-use='author'.</report>
      
      <report test="@specific-use='author' and .!='Author'" role="error" flag="dl-ar" id="sub-article-role-test-4">A role element with the attribute specific-use='author' must contain the text 'Author'. This one has '<value-of select="."/>'.</report>
      
      <report test="@specific-use='editor' and not(.=('Senior and Reviewing Editor','Reviewing Editor'))" role="error" flag="dl-ar" id="sub-article-role-test-5">A role element with the attribute specific-use='editor' must contain the text 'Senior and Reviewing Editor' or 'Reviewing Editor'. This one has '<value-of select="."/>'.</report>
      
      <report test="@specific-use='referee' and .!='Reviewer'" role="error" flag="dl-ar" id="sub-article-role-test-6">A role element with the attribute specific-use='referee' must contain the text 'Reviewer'. This one has '<value-of select="."/>'.</report>
      
    </rule>
  </pattern>
  <pattern id="ref-report-editor-tests-pattern">
    <rule context="sub-article[@article-type='referee-report']/front-stub/contrib-group[1]" id="ref-report-editor-tests">
      
      <assert test="count(contrib[role[@specific-use='editor']]) = 1" role="error" flag="dl-ar" id="ref-report-editor-1">First contrib-group in decision letter must contain 1 and only 1 editor (a contrib with a role[@specific-use='editor']).</assert>
    </rule>
  </pattern>
  <pattern id="ref-report-reviewer-tests-pattern">
    <rule context="sub-article[@article-type='referee-report']/front-stub/contrib-group[2]" id="ref-report-reviewer-tests">
      
      <assert test="count(contrib[role[@specific-use='referee']]) gt 0" role="error" flag="dl-ar" id="ref-report-reviewer-test-1">Second contrib-group in decision letter must contain a reviewer (a contrib with a child role[@specific-use='referee']).</assert>
      
      <report test="count(contrib[role[@specific-use='referee']]) gt 5" role="warning" flag="dl-ar" id="ref-report-reviewer-test-6">Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</report>
    </rule>
  </pattern>
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 <pattern id="feature-template-tests-pattern">
    <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]" id="feature-template-tests">
     <let name="template" value="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
     <let name="type" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
     
     <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/feature-content#feature-template-test-1" test="($template = ('1','2','3')) and child::sub-article" role="error" flag="dl-ar" id="feature-template-test-1">
        <value-of select="$type"/> is a template <value-of select="$template"/> but it has a decision letter or author response, which cannot be correct, as only template 5s are allowed these.</report>
     
     <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/feature-content#feature-template-test-2" test="($template = '5') and not(@article-type='research-article')" role="error" flag="dl-ar" id="feature-template-test-2">
        <value-of select="$type"/> is a template <value-of select="$template"/> so the article element must have a @article-type="research-article". Instead the @article-type="<value-of select="@article-type"/>".</report>
     
     
     
     
     
     
     
     
     
     
     
     
     
     
   </rule>
  </pattern>
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
</schema>