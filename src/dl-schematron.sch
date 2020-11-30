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
  <let name="allowed-article-types" value="('article-commentary', 'correction', 'discussion', 'editorial', 'research-article', 'retraction','review-article')"/>
  <let name="allowed-disp-subj" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Feature Article', 'Insight', 'Editorial', 'Correction', 'Retraction', 'Scientific Correspondence', 'Review Article')"/> 

  <!-- Features specific values included here for convenience -->
  <let name="features-subj" value="('Feature Article', 'Insight', 'Editorial')"/>
  <let name="features-article-types" value="('article-commentary','editorial','discussion')"/>
  <let name="research-subj" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Correction', 'Retraction', 'Scientific Correspondence', 'Review Article')"/>
  
  <let name="MSAs" value="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
  
  <!--=== Custom functions ===-->
  
  <xsl:function name="e:titleCaseToken" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="contains($s,'-')">
        <xsl:value-of select="concat(           upper-case(substring(substring-before($s,'-'), 1, 1)),           lower-case(substring(substring-before($s,'-'),2)),           '-',           upper-case(substring(substring-after($s,'-'), 1, 1)),           lower-case(substring(substring-after($s,'-'),2)))"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('and','or','the','an','of','in','as','at','by','for','a','to','up','but','yet')">
        <xsl:value-of select="lower-case($s)"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('rna','dna','mri','hiv','tor')">
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
          <xsl:when test="lower-case($token1)=('rna','dna','hiv','aids','covid-19','covid')">
            <xsl:value-of select="concat(upper-case($token1),               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\s') return e:titleCaseToken($x),' ')               )"/>
          </xsl:when>
          <xsl:when test="matches(lower-case($token1),'[1-4]d')">
            <xsl:value-of select="concat(upper-case($token1),               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\s') return e:titleCaseToken($x),' ')               )"/>
          </xsl:when>
          <xsl:when test="contains($token1,'-')">
            <xsl:value-of select="string-join(for $x in tokenize($s,'\s') return e:titleCaseToken($x),' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(               concat(upper-case(substring($token1, 1, 1)), lower-case(substring($token1, 2))),               ' ',               string-join(for $x in tokenize(substring-after($token2,' '),'\s') return e:titleCaseToken($x),' ')               )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="lower-case($s)=('and','or','the','an','of')">
        <xsl:value-of select="lower-case($s)"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('rna','dna')">
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
      <xsl:otherwise>
        <xsl:value-of select="'undefined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="e:stripDiacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="replace(replace(replace(translate(normalize-unicode($string,'NFD'),'ƀȼđɇǥħɨɉꝁłøɍŧɏƶ','bcdeghijklortyz'),'\p{M}',''),'æ','ae'),'ß','ss')"/>
  </xsl:function>

  <xsl:function name="e:citation-format1" as="xs:string">
    <xsl:param name="year"/>
    <xsl:choose>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/name">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname[1],', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/collab">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,' and ',$year/ancestor::element-citation/person-group[1]/name/surname[1],', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname[1],' and ',$year/ancestor::element-citation/person-group[1]/collab,', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname[1],' and ',$year/ancestor::element-citation/person-group[1]/name[2]/surname[1],', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/collab) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1],' and ',$year/ancestor::element-citation/person-group[1]/collab[2],', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1], ' et al., ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname[1], ' et al., ',$year)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undetermined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="e:citation-format2" as="xs:string">
    <xsl:param name="year"/>
    <xsl:choose>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/name">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname[1],' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/collab">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,' and ',$year/ancestor::element-citation/person-group[1]/name/surname[1],' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname[1],' and ',$year/ancestor::element-citation/person-group[1]/collab,' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname[1],' and ',$year/ancestor::element-citation/person-group[1]/name[2]/surname[1],' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/collab) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1],' and ',e:stripDiacritics($year/ancestor::element-citation/person-group[1]/collab[2]),' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1], ' et al. (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname[1], ' et al. (',$year,')')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undetermined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="e:ref-cite-list">
    <xsl:param name="ref-list" as="node()"/>
    <xsl:element name="list">
      <xsl:for-each select="$ref-list/ref[element-citation[year]]">
        <xsl:variable name="cite" select="e:citation-format1(./element-citation[1]/year[1])"/>
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
  <let name="org-regex" value="'b\.\s?subtilis|bacillus\s?subtilis|d\.\s?melanogaster|drosophila\s?melanogaster|e\.\s?coli|escherichia\s?coli|s\.\s?pombe|schizosaccharomyces\s?pombe|s\.\s?cerevisiae|saccharomyces\s?cerevisiae|c\.\s?elegans|caenorhabditis\s?elegans|a\.\s?thaliana|arabidopsis\s?thaliana|m\.\s?thermophila|myceliophthora\s?thermophila|dictyostelium|p\.\s?falciparum|plasmodium\s?falciparum|s\.\s?enterica|salmonella\s?enterica|s\.\s?pyogenes|streptococcus\s?pyogenes|p\.\s?dumerilii|platynereis\s?dumerilii|p\.\s?cynocephalus|papio\s?cynocephalus|o\.\s?fasciatus|oncopeltus\s?fasciatus|n\.\s?crassa|neurospora\s?crassa|c\.\s?intestinalis|ciona\s?intestinalis|e\.\s?cuniculi|encephalitozoon\s?cuniculi|h\.\s?salinarum|halobacterium\s?salinarum|s\.\s?solfataricus|sulfolobus\s?solfataricus|s\.\s?mediterranea|schmidtea\s?mediterranea|s\.\s?rosetta|salpingoeca\s?rosetta|n\.\s?vectensis|nematostella\s?vectensis|s\.\s?aureus|staphylococcus\s?aureus|v\.\s?cholerae|vibrio\s?cholerae|t\.\s?thermophila|tetrahymena\s?thermophila|c\.\s?reinhardtii|chlamydomonas\s?reinhardtii|n\.\s?attenuata|nicotiana\s?attenuata|e\.\s?carotovora|erwinia\s?carotovora|e\.\s?faecalis|h\.\s?sapiens|homo\s?sapiens|c\.\s?trachomatis|chlamydia\s?trachomatis|enterococcus\s?faecalis|x\.\s?laevis|xenopus\s?laevis|x\.\s?tropicalis|xenopus\s?tropicalis|m\.\s?musculus|mus\s?musculus|d\.\s?immigrans|drosophila\s?immigrans|d\.\s?subobscura|drosophila\s?subobscura|d\.\s?affinis|drosophila\s?affinis|d\.\s?obscura|drosophila\s?obscura|f\.\s?tularensis|francisella\s?tularensis|p\.\s?plantaginis|podosphaera\s?plantaginis|p\.\s?lanceolata|plantago\s?lanceolata|m\.\s?trossulus|mytilus\s?trossulus|m\.\s?edulis|mytilus\s?edulis|m\.\s?chilensis|mytilus\s?chilensis|u\.\s?maydis|ustilago\s?maydis|p\.\s?knowlesi|plasmodium\s?knowlesi|p\.\s?aeruginosa|pseudomonas\s?aeruginosa|t\.\s?brucei|trypanosoma\s?brucei|caulobacter\s?crescentus|c\.\s?crescentus|d\.\s?rerio|danio\s?rerio|drosophila|xenopus'"/>
  
  <let name="sec-title-regex" value="string-join(     for $x in tokenize($org-regex,'\|')     return concat('^',$x,'$')     ,'|')"/>
  
  <xsl:function name="e:org-conform" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="matches($s,'b\.\s?subtilis')">
        <xsl:value-of select="'B. subtilis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'bacillus\s?subtilis')">
        <xsl:value-of select="'Bacillus subtilis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\s?melanogaster')">
        <xsl:value-of select="'D. melanogaster'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\s?melanogaster')">
        <xsl:value-of select="'Drosophila melanogaster'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\s?coli')">
        <xsl:value-of select="'E. coli'"/>
      </xsl:when>
      <xsl:when test="matches($s,'escherichia\s?coli')">
        <xsl:value-of select="'Escherichia coli'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?pombe')">
        <xsl:value-of select="'S. pombe'"/>
      </xsl:when>
      <xsl:when test="matches($s,'schizosaccharomyces\s?pombe')">
        <xsl:value-of select="'Schizosaccharomyces pombe'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?cerevisiae')">
        <xsl:value-of select="'S. cerevisiae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'saccharomyces\s?cerevisiae')">
        <xsl:value-of select="'Saccharomyces cerevisiae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\s?elegans')">
        <xsl:value-of select="'C. elegans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'caenorhabditis\s?elegans')">
        <xsl:value-of select="'Caenorhabditis elegans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'a\.\s?thaliana')">
        <xsl:value-of select="'A. thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'arabidopsis\s?thaliana')">
        <xsl:value-of select="'Arabidopsis thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\s?thermophila')">
        <xsl:value-of select="'M. thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'myceliophthora\s?thermophila')">
        <xsl:value-of select="'Myceliophthora thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'dictyostelium')">
        <xsl:value-of select="'Dictyostelium'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\s?falciparum')">
        <xsl:value-of select="'P. falciparum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'plasmodium\s?falciparum')">
        <xsl:value-of select="'Plasmodium falciparum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?enterica')">
        <xsl:value-of select="'S. enterica'"/>
      </xsl:when>
      <xsl:when test="matches($s,'salmonella\s?enterica')">
        <xsl:value-of select="'Salmonella enterica'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?pyogenes')">
        <xsl:value-of select="'S. pyogenes'"/>
      </xsl:when>
      <xsl:when test="matches($s,'streptococcus\s?pyogenes')">
        <xsl:value-of select="'Streptococcus pyogenes'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\s?dumerilii')">
        <xsl:value-of select="'P. dumerilii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'platynereis\s?dumerilii')">
        <xsl:value-of select="'Platynereis dumerilii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\s?cynocephalus')">
        <xsl:value-of select="'P. cynocephalus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'papio\s?cynocephalus')">
        <xsl:value-of select="'Papio cynocephalus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'o\.\s?fasciatus')">
        <xsl:value-of select="'O. fasciatus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'oncopeltus\s?fasciatus')">
        <xsl:value-of select="'Oncopeltus fasciatus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'n\.\s?crassa')">
        <xsl:value-of select="'N. crassa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'neurospora\s?crassa')">
        <xsl:value-of select="'Neurospora crassa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\s?intestinalis')">
        <xsl:value-of select="'C. intestinalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'ciona\s?intestinalis')">
        <xsl:value-of select="'Ciona intestinalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\s?cuniculi')">
        <xsl:value-of select="'E. cuniculi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'encephalitozoon\s?cuniculi')">
        <xsl:value-of select="'Encephalitozoon cuniculi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'h\.\s?salinarum')">
        <xsl:value-of select="'H. salinarum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'halobacterium\s?salinarum')">
        <xsl:value-of select="'Halobacterium salinarum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?solfataricus')">
        <xsl:value-of select="'S. solfataricus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'sulfolobus\s?solfataricus')">
        <xsl:value-of select="'Sulfolobus solfataricus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?mediterranea')">
        <xsl:value-of select="'S. mediterranea'"/>
      </xsl:when>
      <xsl:when test="matches($s,'schmidtea\s?mediterranea')">
        <xsl:value-of select="'Schmidtea mediterranea'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?rosetta')">
        <xsl:value-of select="'S. rosetta'"/>
      </xsl:when>
      <xsl:when test="matches($s,'salpingoeca\s?rosetta')">
        <xsl:value-of select="'Salpingoeca rosetta'"/>
      </xsl:when>
      <xsl:when test="matches($s,'n\.\s?vectensis')">
        <xsl:value-of select="'N. vectensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'nematostella\s?vectensis')">
        <xsl:value-of select="'Nematostella vectensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\s?aureus')">
        <xsl:value-of select="'S. aureus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'staphylococcus\s?aureus')">
        <xsl:value-of select="'Staphylococcus aureus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'a\.\s?thaliana')">
        <xsl:value-of select="'A. thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'arabidopsis\s?thaliana')">
        <xsl:value-of select="'Arabidopsis thaliana'"/>
      </xsl:when>
      <xsl:when test="matches($s,'v\.\s?cholerae')">
        <xsl:value-of select="'V. cholerae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'vibrio\s?cholerae')">
        <xsl:value-of select="'Vibrio cholerae'"/>
      </xsl:when>
      <xsl:when test="matches($s,'t\.\s?thermophila')">
        <xsl:value-of select="'T. thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'tetrahymena\s?thermophila')">
        <xsl:value-of select="'Tetrahymena thermophila'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\s?reinhardtii')">
        <xsl:value-of select="'C. reinhardtii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'chlamydomonas\s?reinhardtii')">
        <xsl:value-of select="'Chlamydomonas reinhardtii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'n\.\s?attenuata')">
        <xsl:value-of select="'N. attenuata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'nicotiana\s?attenuata')">
        <xsl:value-of select="'Nicotiana attenuata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\s?carotovora')">
        <xsl:value-of select="'E. carotovora'"/>
      </xsl:when>
      <xsl:when test="matches($s,'erwinia\s?carotovora')">
        <xsl:value-of select="'Erwinia carotovora'"/>
      </xsl:when>
      <xsl:when test="matches($s,'h\.\s?sapiens')">
        <xsl:value-of select="'H. sapiens'"/>
      </xsl:when>
      <xsl:when test="matches($s,'homo\s?sapiens')">
        <xsl:value-of select="'Homo sapiens'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\s?faecalis')">
        <xsl:value-of select="'E. faecalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'enterococcus\s?faecalis')">
        <xsl:value-of select="'Enterococcus faecalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\s?trachomatis')">
        <xsl:value-of select="'C. trachomatis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'chlamydia\s?trachomatis')">
        <xsl:value-of select="'Chlamydia trachomatis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'x\.\s?laevis')">
        <xsl:value-of select="'X. laevis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'xenopus\s?laevis')">
        <xsl:value-of select="'Xenopus laevis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'x\.\s?tropicalis')">
        <xsl:value-of select="'X. tropicalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'xenopus\s?tropicalis')">
        <xsl:value-of select="'Xenopus tropicalis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\s?musculus')">
        <xsl:value-of select="'M. musculus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mus\s?musculus')">
        <xsl:value-of select="'Mus musculus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\s?immigrans')">
        <xsl:value-of select="'D. immigrans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\s?immigrans')">
        <xsl:value-of select="'Drosophila immigrans'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\s?subobscura')">
        <xsl:value-of select="'D. subobscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\s?subobscura')">
        <xsl:value-of select="'Drosophila subobscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\s?affinis')">
        <xsl:value-of select="'D. affinis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\s?affinis')">
        <xsl:value-of select="'Drosophila affinis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\s?obscura')">
        <xsl:value-of select="'D. obscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'drosophila\s?obscura')">
        <xsl:value-of select="'Drosophila obscura'"/>
      </xsl:when>
      <xsl:when test="matches($s,'f\.\s?tularensis')">
        <xsl:value-of select="'F. tularensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'francisella\s?tularensis')">
        <xsl:value-of select="'Francisella tularensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\s?plantaginis')">
        <xsl:value-of select="'P. plantaginis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'podosphaera\s?plantaginis')">
        <xsl:value-of select="'Podosphaera plantaginis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\s?lanceolata')">
        <xsl:value-of select="'P. lanceolata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'plantago\s?lanceolata')">
        <xsl:value-of select="'Plantago lanceolata'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\s?edulis')">
        <xsl:value-of select="'M. edulis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mytilus\s?edulis')">
        <xsl:value-of select="'Mytilus edulis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\s?chilensis')">
        <xsl:value-of select="'M. chilensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mytilus\s?chilensis')">
        <xsl:value-of select="'Mytilus chilensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'m\.\s?trossulus')">
        <xsl:value-of select="'M. trossulus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'mytilus\s?trossulus')">
        <xsl:value-of select="'Mytilus trossulus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'u\.\s?maydis')">
        <xsl:value-of select="'U. maydis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'ustilago\s?maydis')">
        <xsl:value-of select="'Ustilago maydis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\s?knowlesi')">
        <xsl:value-of select="'P. knowlesi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'plasmodium\s?knowlesi')">
        <xsl:value-of select="'Plasmodium knowlesi'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\s?aeruginosa')">
        <xsl:value-of select="'P. aeruginosa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'pseudomonas\s?aeruginosa')">
        <xsl:value-of select="'Pseudomonas aeruginosa'"/>
      </xsl:when>
      <xsl:when test="matches($s,'t\.\s?brucei')">
        <xsl:value-of select="'T. brucei'"/>
      </xsl:when>
      <xsl:when test="matches($s,'trypanosoma\s?brucei')">
        <xsl:value-of select="'Trypanosoma brucei'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\s?crescentus')">
        <xsl:value-of select="'C. crescentus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'caulobacter\s?crescentus')">
        <xsl:value-of select="'Caulobacter crescentus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'d\.\s?rerio')">
        <xsl:value-of select="'D. rerio'"/>
      </xsl:when>
      <xsl:when test="matches($s,'danio\s?rerio')">
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
        <xsl:variable name="text-no" select="tokenize(normalize-space(replace(.,'[^0-9]',' ')),'\s')[last()]"/>
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
  
  <xsl:function name="e:insight-box" as="element()">
    <xsl:param name="box" as="xs:string"/>
    <xsl:param name="cite-text" as="xs:string"/>
    <xsl:variable name="box-text" select="substring-after(substring-after($box,'article'),' ')"/> 
    
    <xsl:element name="list">
      <xsl:for-each select="tokenize($cite-text,'\s')">
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
      <xsl:for-each select="tokenize($box-text,'\s')">
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
  
  <let name="latin-regex" value="'in\s+vitro|ex\s+vitro|in\s+vivo|ex\s+vivo|a\s+priori|a\s+posteriori|de\s+novo|in\s+utero|in\s+natura|in\s+situ|in\s+planta|rete\s+mirabile|nomen\s+novum| sensu |ad\s+libitum|in\s+ovo'"/>
  
  
  
  
  
  <!-- Modification of http://www.xsltfunctions.com/xsl/functx_line-count.html -->
  <xsl:function name="e:line-count" as="xs:integer">
    <xsl:param name="arg" as="xs:string?"/>
    
    <xsl:sequence select="count(tokenize($arg,'(\r\n?|\n\r?)'))"/>
    
  </xsl:function>
 
  <!-- Taken from here https://stackoverflow.com/questions/2917655/how-do-i-check-for-the-existence-of-an-external-file-with-xsl -->
  
  
  
  
 <pattern id="research-article-pattern">
    <rule context="article[@article-type='research-article']" id="research-article">
	  <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
	
	  <report test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])" role="warning" flag="dl-ar" id="pre-test-r-article-d-letter">A decision letter should be present for research articles.</report>
	  
	  <report test="not($disp-channel = ('Scientific Correspondence','Feature Article')) and not(sub-article[@article-type='decision-letter'])" role="error" flag="dl-ar" id="final-test-r-article-d-letter">A decision letter must be present for research articles.</report>
	  
	  <report test="($disp-channel = 'Feature Article') and not(sub-article[@article-type='decision-letter'])" role="warning" flag="dl-ar" id="final-test-r-article-d-letter-feat">A decision letter should be present for research articles. Feature template 5s almost always have a decision letter, but this one does not. Is that correct?</report>
		
	  <report test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='reply'])" role="warning" flag="dl-ar" id="test-r-article-a-reply">Author response should usually be present for research articles, but this one does not have one. Is that correct?</report>
	
	</rule>
  </pattern>

  

  

  
  
  

   	
  
  <pattern id="ar-fig-tests-pattern">
    <rule context="fig[ancestor::sub-article[@article-type='reply']]" id="ar-fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(ancestor::body//fig)"/>
      <let name="pos" value="$count - count(following::fig)"/>
      <let name="no" value="substring-after(@id,'fig')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#ar-fig-test-2" test="if ($article-type = ($features-article-types,'correction','retraction')) then ()         else not(label)" role="error" flag="dl-ar" id="ar-fig-test-2">Author Response fig must have a label.</report>
      
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
  
  <pattern id="ar-video-specific-pattern">
    <rule context="sub-article/body//media[@mimetype='video']" id="ar-video-specific">
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
      
      
      
      <report test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-disp-formula-id-test">disp-formula @id must be in the format 'sa0equ0' when in a sub-article.  <value-of select="@id"/> does not conform to this.</report>
    </rule>
  </pattern>
  <pattern id="mml-math-ids-pattern">
    <rule context="disp-formula/mml:math" id="mml-math-ids">
      
      
      
      <report test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))" role="error" flag="dl-ar" id="sub-mml-math-id-test">mml:math @id in disp-formula must be in the format 'sa0m0'.  <value-of select="@id"/> does not conform to this.</report>
    </rule>
  </pattern>
  <pattern id="resp-table-wrap-ids-pattern">
    <rule context="sub-article//table-wrap" id="resp-table-wrap-ids">
 
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#resp-table-wrap-id-test" test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$')         else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')" role="warning" flag="dl-ar" id="resp-table-wrap-id-test">table-wrap @id in author reply must be in the format 'resptable0' or 'sa0table0' if it has a label, or in the format 'respinlinetable0' or 'sa0inlinetable0' if it does not.</assert>
    </rule>
  </pattern>
  
  
  
  
  
  
  
  <pattern id="dec-letter-reply-tests-pattern">
    <rule context="article/sub-article" id="dec-letter-reply-tests">
      <let name="pos" value="count(parent::article/sub-article) - count(following-sibling::sub-article)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-1" test="if ($pos = 1) then @article-type='decision-letter'         else @article-type='reply'" role="error" flag="dl-ar" id="dec-letter-reply-test-1">1st sub-article must be the decision letter. 2nd sub-article must be the author response.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-2" test="@id = concat('sa',$pos)" role="error" flag="dl-ar" id="dec-letter-reply-test-2">sub-article id must be in the format 'sa0', where '0' is its position (1 or 2).</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-3" test="count(front-stub) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-3">sub-article must contain one and only one front-stub.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-4" test="count(body) = 1" role="error" flag="dl-ar" id="dec-letter-reply-test-4">sub-article must contain one and only one body.</assert>
      
    </rule>
  </pattern>
  <pattern id="dec-letter-reply-content-tests-pattern">
    <rule context="article/sub-article//p" id="dec-letter-reply-content-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-5" test="matches(.,'&lt;[/]?[Aa]uthor response')" role="error" flag="dl-ar" id="dec-letter-reply-test-5">
        <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what looks like pseudo-code - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-6" test="matches(.,'&lt;\s?/?\s?[a-z]*\s?/?\s?&gt;')" role="warning" flag="dl-ar" id="dec-letter-reply-test-6">
        <value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be pseudo-code or tags which should likely be removed - <value-of select="."/>.</report>
    </rule>
  </pattern>
  <pattern id="dec-letter-front-tests-pattern">
    <rule context="sub-article[@article-type='decision-letter']/front-stub" id="dec-letter-front-tests">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-1" test="count(article-id[@pub-id-type='doi']) = 1" role="error" flag="dl-ar" id="dec-letter-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-2" test="$count gt 0" role="error" flag="dl-ar" id="dec-letter-front-test-2">decision letter front-stub must contain at least 1 contrib-group element.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-3" test="$count gt 2" role="error" flag="dl-ar" id="dec-letter-front-test-3">decision letter front-stub contains more than 2 contrib-group elements.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-4" test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'The reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/|doi.org/10.24072/pci.evolbiol')])" role="warning" flag="dl-ar" id="dec-letter-front-test-4">decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviewing editor) anonymous? The text 'The reviewers have opted to remain anonymous' or 'The reviewer has opted to remain anonymous' is not present and there is no link to Review commons or a Peer Community in Evolutionary Biology doi in the decision letter.</report>
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
    <rule context="sub-article[@article-type='decision-letter']/body//p" id="dec-letter-body-p-tests">  
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-2" test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])" role="error" flag="dl-ar" id="dec-letter-body-test-2">The text 'Review Commons' in '<value-of select="."/>' must contain an embedded link pointing to https://www.reviewcommons.org/.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-3" test="contains(lower-case(.),'reviewed and recommended by peer community in evolutionary biology') and not(child::ext-link[matches(@xlink:href,'doi.org/10.24072/pci.evolbiol')])" role="error" flag="dl-ar" id="dec-letter-body-test-3">The decision letter indicates that this article was reviewed by PCI evol bio, but there is no doi link with the prefix '10.24072/pci.evolbiol' which must be incorrect.</report>
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
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 <pattern id="feature-template-tests-pattern">
    <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]" id="feature-template-tests">
     <let name="template" value="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
     <let name="type" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
     
     <report test="($template = ('1','2','3')) and child::sub-article" role="error" flag="dl-ar" id="feature-template-test-1">
        <value-of select="$type"/> is a template <value-of select="$template"/> but it has a decision letter or author response, which cannot be correct, as only template 5s are allowed these.</report>
     
     <report test="($template = '5') and not(@article-type='research-article')" role="error" flag="dl-ar" id="feature-template-test-2">
        <value-of select="$type"/> is a template <value-of select="$template"/> so the article element must have a @article-type="research-article". Instead the @article-type="<value-of select="@article-type"/>".</report>
     
     
     
     
     
     
     
     
   </rule>
  </pattern>
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
</schema>