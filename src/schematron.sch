<schema
   xmlns="http://purl.oclc.org/dsdl/schematron"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:java="http://www.java.com/"
   xmlns:file="java.io.File"
   xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
   xmlns:mml="http://www.w3.org/1998/Math/MathML"
   queryBinding="xslt2">

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
        <xsl:value-of select="concat(
          upper-case(substring(substring-before($s,'-'), 1, 1)),
          lower-case(substring(substring-before($s,'-'),2)),
          '-',
          upper-case(substring(substring-after($s,'-'), 1, 1)),
          lower-case(substring(substring-after($s,'-'),2)))"/>
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
            <xsl:value-of select="concat(upper-case($token1),
              ' ',
              string-join(for $x in tokenize(substring-after($token2,' '),'\s') return e:titleCaseToken($x),' ')
              )"/>
          </xsl:when>
          <xsl:when test="matches(lower-case($token1),'[1-4]d')">
            <xsl:value-of select="concat(upper-case($token1),
              ' ',
              string-join(for $x in tokenize(substring-after($token2,' '),'\s') return e:titleCaseToken($x),' ')
              )"/>
          </xsl:when>
          <xsl:when test="contains($token1,'-')">
            <xsl:value-of select="string-join(for $x in tokenize($s,'\s') return e:titleCaseToken($x),' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(
              concat(upper-case(substring($token1, 1, 1)), lower-case(substring($token1, 2))),
              ' ',
              string-join(for $x in tokenize(substring-after($token2,' '),'\s') return e:titleCaseToken($x),' ')
              )"/>
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
  
  <!-- Global variable included here for convenience -->
  <let name="org-regex" value="'b\.\s?subtilis|bacillus\s?subtilis|d\.\s?melanogaster|drosophila\s?melanogaster|e\.\s?coli|escherichia\s?coli|s\.\s?pombe|schizosaccharomyces\s?pombe|s\.\s?cerevisiae|saccharomyces\s?cerevisiae|c\.\s?elegans|caenorhabditis\s?elegans|a\.\s?thaliana|arabidopsis\s?thaliana|m\.\s?thermophila|myceliophthora\s?thermophila|dictyostelium|p\.\s?falciparum|plasmodium\s?falciparum|s\.\s?enterica|salmonella\s?enterica|s\.\s?pyogenes|streptococcus\s?pyogenes|p\.\s?dumerilii|platynereis\s?dumerilii|p\.\s?cynocephalus|papio\s?cynocephalus|o\.\s?fasciatus|oncopeltus\s?fasciatus|n\.\s?crassa|neurospora\s?crassa|c\.\s?intestinalis|ciona\s?intestinalis|e\.\s?cuniculi|encephalitozoon\s?cuniculi|h\.\s?salinarum|halobacterium\s?salinarum|s\.\s?solfataricus|sulfolobus\s?solfataricus|s\.\s?mediterranea|schmidtea\s?mediterranea|s\.\s?rosetta|salpingoeca\s?rosetta|n\.\s?vectensis|nematostella\s?vectensis|s\.\s?aureus|staphylococcus\s?aureus|v\.\s?cholerae|vibrio\s?cholerae|t\.\s?thermophila|tetrahymena\s?thermophila|c\.\s?reinhardtii|chlamydomonas\s?reinhardtii|n\.\s?attenuata|nicotiana\s?attenuata|e\.\s?carotovora|erwinia\s?carotovora|e\.\s?faecalis|h\.\s?sapiens|homo\s?sapiens|c\.\s?trachomatis|chlamydia\s?trachomatis|enterococcus\s?faecalis|x\.\s?laevis|xenopus\s?laevis|x\.\s?tropicalis|xenopus\s?tropicalis|m\.\s?musculus|mus\s?musculus|d\.\s?immigrans|drosophila\s?immigrans|d\.\s?subobscura|drosophila\s?subobscura|d\.\s?affinis|drosophila\s?affinis|d\.\s?obscura|drosophila\s?obscura|f\.\s?tularensis|francisella\s?tularensis|p\.\s?plantaginis|podosphaera\s?plantaginis|p\.\s?lanceolata|plantago\s?lanceolata|m\.\s?trossulus|mytilus\s?trossulus|m\.\s?edulis|mytilus\s?edulis|m\.\s?chilensis|mytilus\s?chilensis|u\.\s?maydis|ustilago\s?maydis|p\.\s?knowlesi|plasmodium\s?knowlesi|p\.\s?aeruginosa|pseudomonas\s?aeruginosa|t\.\s?brucei|trypanosoma\s?brucei|caulobacter\s?crescentus|c\.\s?crescentus|d\.\s?rerio|danio\s?rerio|drosophila|xenopus'"/>
  
  <let name="sec-title-regex" value="string-join(
    for $x in tokenize($org-regex,'\|')
    return concat('^',$x,'$')
    ,'|')"/>
  
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
          <xsl:when test="($rid-no lt $object-no) and (./following-sibling::text()[1] = '&#x2013;') and (./following-sibling::*[1]/name()='xref') and (number(replace(replace(./following-sibling::xref[1]/@rid,'\-','.'),'[a-z]','')) gt number($object-no))">
            <xsl:element name="match">
              <xsl:attribute name="sec-id">
                <xsl:value-of select="./ancestor::sec[1]/@id"/>
              </xsl:attribute>
              <xsl:value-of select="self::*"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="($rid-no lt $object-no) and contains(.,$object-no) and (contains(.,'Videos') or contains(.,'videos') and contains(.,'&#x2013;'))">
            <xsl:element name="match">
              <xsl:attribute name="sec-id">
                <xsl:value-of select="./ancestor::sec[1]/@id"/>
              </xsl:attribute>
              <xsl:value-of select="self::*"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="($rid-no lt $object-no) and (contains(.,'Videos') or contains(.,'videos') and contains(.,'&#x2014;')) and ($text-no gt $object-no)">
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
  
  <xsl:function name="e:get-latin-terms" as="element()">
    <xsl:param name="article" as="element()"/>
    <xsl:param name="regex" as="xs:string"/>
    
    <xsl:variable name="roman-text" select="lower-case(
      string-join(for $x in $article/*[local-name() = 'body' or local-name() = 'back']//*
      return
      if ($x/ancestor-or-self::sec[@sec-type='additional-information']) then ()
      else if ($x/ancestor-or-self::ref-list) then ()
      else if ($x/local-name() = 'italic') then ()
      else $x/text(),' '))"/>
    <xsl:variable name="italic-text" select="lower-case(string-join($article//*:italic[not(ancestor::ref-list) and not(ancestor::sec[@sec-type='additional-information'])],' '))"/>
    
    
    <xsl:element name="result">
      <xsl:choose>
        <xsl:when test="matches($roman-text,$regex)">
          <xsl:element name="list">
            <xsl:attribute name="list-type">roman</xsl:attribute>
            <xsl:for-each select="tokenize($regex,'\|')">
              <xsl:variable name="display" select="replace(replace(.,'\\s\+',' '),'^ | $','')"/>
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
              <xsl:variable name="display" select="replace(.,'\\s\+',' ')"/>
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
    <xsl:value-of select="string-join(
      for $term in $list//*:match[@count != '0'] 
      return if (number($term/@count) gt 1) then concat($term/@count,' instances of ',$term)
      else concat($term/@count,' instance of ',$term)
      ,', ')"/>
  </xsl:function>
  
  <!-- Modification of http://www.xsltfunctions.com/xsl/functx_line-count.html -->
  <xsl:function name="e:line-count" as="xs:integer">
    <xsl:param name="arg" as="xs:string?"/>
    
    <xsl:sequence select="count(tokenize($arg,'(\r\n?|\n\r?)'))"/>
    
  </xsl:function>
 
  <!-- Taken from here https://stackoverflow.com/questions/2917655/how-do-i-check-for-the-existence-of-an-external-file-with-xsl -->
  <xsl:function name="java:file-exists" xmlns:file="java.io.File" as="xs:boolean">
    <xsl:param name="file" as="xs:string"/>
    <xsl:param name="base-uri" as="xs:string"/>
    
    <xsl:variable name="absolute-uri" select="resolve-uri($file, $base-uri)" as="xs:anyURI"/>
    <xsl:sequence select="file:exists(file:new($absolute-uri))"/>
  </xsl:function>
  
  <pattern id="covid-prologue-pattern">
    <rule context="article[front/article-meta//article-title[matches(lower-case(.),'sars-cov-2|covid-19|coronavirus')]]" 
      id="covid-prologue">
      
      <assert test="preceding::processing-instruction('covid-19-tdm')" 
        role="warning" 
        id="covid-processing-instruction">The article title (<value-of select="front/article-meta//article-title"/>) suggests that this article should probably have the covid processing instruction - '&lt;?covid-19-tdm?>' - but it does not. Should it?</assert>
      
    </rule>
  </pattern>
  
 <pattern id="article">
 
    <rule context="article" id="article-tests">
      <let name="line-count" value="e:line-count(.)"/>
      
	  <report test="@dtd-version" 
        role="info" 
        id="dtd-info">DTD version is <value-of select="@dtd-version"/></report>
	  
	  <assert test="@article-type = $allowed-article-types" 
        role="error" 
        id="test-article-type">article-type must be equal to 'article-commentary', 'correction', 'discussion', 'editorial', or 'research-article'. Currently it is <value-of select="@article-type"/></assert>
		
	  <assert test="count(front) = 1" 
        role="error" 
        id="test-article-front">Article must have one child front. Currently there are <value-of select="count(front)"/></assert>
		
	  <assert test="count(body) = 1" 
        role="error" 
        id="test-article-body">Article must have one child body. Currently there are <value-of select="count(body)"/></assert>
		
    <report test="(@article-type = ('article-commentary','discussion','editorial','research-article','review-article')) and count(back) != 1" 
        role="error" 
        id="test-article-back">Article must have one child back. Currently there are <value-of select="count(back)"/></report>
		
      <report test="not(descendant::code) and ($line-count gt 1)" 
        role="error" 
        id="line-count">Articles without code blocks must only have one line in the xml. The xml for this article has <value-of select="$line-count"/>.</report>
      
      <report test="@article-type='retraction'" 
        role="info" 
        id="retraction-info">Ensure that the PDF for the article which is being retracted (<value-of select="string-join(descendant::article-meta/related-article[@related-article-type='retracted-article']/@xlink:href,'; ')"/>) is also updated with a header saying it's been retracted.</report>
 	</rule>
	
	<rule context="article[@article-type='research-article']" id="research-article">
	  <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/> 
	
	  <report test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])" 
        role="warning"
        flag="dl-ar"
        id="pre-test-r-article-d-letter">A decision letter should be present for research articles.</report>
	  
	  <report test="not($disp-channel = ('Scientific Correspondence','Feature Article')) and not(sub-article[@article-type='decision-letter'])" 
        role="error" 
        flag="dl-ar"
        id="final-test-r-article-d-letter">A decision letter must be present for research articles.</report>
	  
	  <report test="($disp-channel = 'Feature Article') and not(sub-article[@article-type='decision-letter'])" 
        role="warning" 
        flag="dl-ar"
        id="final-test-r-article-d-letter-feat">A decision letter should be present for research articles. Feature template 5s almost always have a decision letter, but this one does not. Is that correct?</report>
		
	  <report test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='reply'])" 
        role="warning"
        flag="dl-ar"
        id="test-r-article-a-reply">Author response should usually be present for research articles, but this one does not have one. Is that correct?</report>
	
	</rule>
 </pattern>

  <pattern id="front"> 
	 
	 <rule context="article/front" id="test-front">
	 
  	  <assert test="count(journal-meta) = 1" 
        role="error" 
        id="test-front-jmeta">There must be one journal-meta that is a child of front. Currently there are <value-of select="count(journal-meta)"/></assert>
		  
  	  <assert test="count(article-meta) = 1" 
        role="error" 
        id="test-front-ameta">There must be one article-meta that is a child of front. Currently there are <value-of select="count(article-meta)"/></assert>
	 
	 </rule>
  </pattern>

  <pattern id="journal-meta">
	 
	 <rule context="article/front/journal-meta" id="test-journal-meta">
	 
		<assert test="journal-id[@journal-id-type='nlm-ta'] = 'elife'" 
        role="error" 
        id="test-journal-nlm">journal-id[@journal-id-type='nlm-ta'] must only contain 'eLife'. Currently it is <value-of select="journal-id[@journal-id-type='nlm-ta']"/></assert>
		  
		<assert test="journal-id[@journal-id-type='publisher-id'] = 'eLife'" 
        role="error" 
        id="test-journal-pubid-1">journal-id[@journal-id-type='publisher-id'] must only contain 'eLife'. Currently it is <value-of select="journal-id[@journal-id-type='publisher-id']"/></assert>
	 
		<assert test="journal-title-group/journal-title = 'eLife'" 
        role="error" 
        id="test-journal-pubid-2">journal-meta must contain a journal-title-group with a child journal-title which must be equal to 'eLife'. Currently it is <value-of select="journal-id[@journal-id-type='publisher-id']"/></assert>
		  
		<assert test="issn = '2050-084X'" 
        role="error" 
        id="test-journal-pubid-3">ISSN must be 2050-084X. Currently it is <value-of select="issn"/></assert>
		  
		<assert test="issn[@publication-format='electronic'][@pub-type='epub']" 
        role="error" 
        id="test-journal-pubid-4">The journal issn element must have a @publication-format='electronic' and a @pub-type='epub'.</assert>
	    
	 </rule>
  </pattern>

  <pattern id="article-metadata">
			 
  <rule context="article/front/article-meta" id="test-article-metadata">
    <let name="article-id" value="article-id[@pub-id-type='publisher-id'][1]"/>
    <let name="article-type" value="ancestor::article/@article-type"/>
    <let name="subj-type" value="descendant::subj-group[@subj-group-type='display-channel']/subject[1]"/>
    <let name="exceptions" value="('Insight','Retraction','Correction')"/>
    <let name="no-digest" value="('Scientific Correspondence','Replication Study','Research Advance','Registered Report','Correction','Retraction',$features-subj)"/>
    
	<assert test="matches($article-id,'^\d{5}$')" 
        role="error" 
        id="test-article-id">article-id must consist only of 5 digits. Currently it is <value-of select="article-id[@pub-id-type='publisher-id']"/></assert> 
	 
	 <assert test="starts-with(article-id[@pub-id-type='doi'][1],'10.7554/eLife.')" 
        role="error" 
        id="test-article-doi-1">Article level DOI must start with '10.7554/eLife.'. Currently it is <value-of select="article-id[@pub-id-type='doi']"/></assert>
	   
  	 <assert test="substring-after(article-id[@pub-id-type='doi'][1],'10.7554/eLife.') = $article-id" 
        role="error" 
        id="test-article-doi-2">Article level DOI must be a concatenation of '10.7554/eLife.' and the article-id. Currently it is <value-of select="article-id[@pub-id-type='doi']"/></assert>
	   
     <assert test="count(article-categories) = 1" 
        role="error" 
        id="test-article-presence">There must be one article-categories element in the article-meta. Currently there are <value-of select="count(article-categories)"/></assert>
	   
    <assert test="title-group[article-title]" 
        role="error" 
        id="test-title-group-presence">title-group containing article-title must be present.</assert>
	   
    <assert test="pub-date[@publication-format='electronic'][@date-type='publication']" 
        role="error" 
        id="test-epub-date">There must be a child pub-date[@publication-format='electronic'][@date-type='publication'] in article-meta.</assert>
	   
    <assert test="pub-date[@pub-type='collection']" 
        role="error" 
        id="test-pub-collection-presence">There must be a child pub-date[@pub-type='collection'] in article-meta.</assert> 
	  
    <assert test="volume" 
        role="error" 
        id="test-volume-presence">There must be a child volume in article-meta.</assert> 
		
    <assert test="matches(volume[1],'^[0-9]*$')" 
        role="error" 
        id="test-volume-contents">volume must only contain a number.</assert> 
	   
    <assert test="elocation-id" 
        role="error" 
        id="test-elocation-presence">There must be a child elocation-id in article-meta.</assert>
		
    <report test="(($article-type != 'retraction') and $article-type != 'correction') and not(self-uri)" 
        role="error" 
        id="test-self-uri-presence">There must be a child self-uri in article-meta.</report>
		
    <report test="(($article-type != 'retraction') and $article-type != 'correction') and not(self-uri[@content-type='pdf'])" 
        role="error" 
        id="test-self-uri-att">self-uri must have an @content-type="pdf"</report>
		
    <report test="(($article-type != 'retraction') and $article-type != 'correction') and not(self-uri[starts-with(@xlink:href,concat('elife-', $article-id))])" 
        role="error" 
        id="test-self-uri-pdf-1">self-uri must have attribute xlink:href="elife-xxxxx.pdf" where xxxxx = the article-id. Currently it is <value-of select="self-uri/@xlink:href"/>. It should start with elife-<value-of select="$article-id"/>.</report>
    
    <report test="(($article-type != 'retraction') and $article-type != 'correction') and not(self-uri[matches(@xlink:href, '^elife-[\d]{5}\.pdf$|^elife-[\d]{5}-v[0-9]{1,2}\.pdf$')])" 
        role="error" 
        id="test-self-uri-pdf-2">self-uri does not conform.</report>
		
    <report test="(($article-type != 'retraction') and $article-type != 'correction') and count(history) != 1" 
        role="error" 
        id="test-history-presence">There must be one and only one history element in the article-meta. Currently there are <value-of select="count(history)"/></report>
		  
    <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#test-permissions-presence" 
        test="count(permissions) = 1" 
        role="error" 
        id="test-permissions-presence">There must be one and only one permissions element in the article-meta. Currently there are <value-of select="count(permissions)"/></assert>
		  
    <report test="(($article-type != 'retraction') and $article-type != 'correction') and (count(abstract[not(@abstract-type='executive-summary')]) != 1 or (count(abstract[not(@abstract-type='executive-summary')]) != 1 and count(abstract[@abstract-type='executive-summary']) != 1))" 
        role="error" 
        id="test-abstracts">There must either be only one abstract or one abstract and one abstract[@abstract-type="executive-summary]. No other variations are allowed.</report>
    
    <report test="($subj-type= $no-digest) and abstract[@abstract-type='executive-summary']" 
        role="error" 
        id="test-no-digest">'<value-of select="$subj-type"/>' cannot have a digest.</report>
	 
    <report test="if ($article-type = $features-article-types) then ()
      else if ($subj-type = ('Scientific Correspondence','Correction','Retraction')) then ()
      else count(funding-group) != 1" 
        role="error" 
        id="test-funding-group-presence">There must be one and only one funding-group element in the article-meta. Currently there are <value-of select="count(funding-group)"/>.</report>
    
    <report test="if ($subj-type = $exceptions) then ()
      else count(custom-meta-group) != 1" 
        role="error" 
        id="test-custom-meta-group-presence">One custom-meta-group should be present in article-meta for all article types except Insights, Retractions and Corrections.</report>
	   
    <report test="if ($subj-type = ('Correction','Retraction')) then ()
      else count(kwd-group[@kwd-group-type='author-keywords']) != 1" 
        role="error" 
        id="test-auth-kwd-group-presence-1">One author keyword group must be present in article-meta.</report>
    
    <report test="if ($subj-type = ('Correction','Retraction')) then (count(kwd-group[@kwd-group-type='author-keywords']) != 0)
      else ()" 
        role="error" 
        id="test-auth-kwd-group-presence-2"><value-of select="$subj-type"/> articles must not have any author keywords</report>
    
    <report test="count(kwd-group[@kwd-group-type='research-organism']) gt 1" 
        role="error" 
        id="test-ro-kwd-group-presence-1">More than 1 Research organism keyword group is present in article-meta. This is incorrect.</report>
    
    <report test="if ($subj-type = ('Research Article', 'Research Advance', 'Replication Study', 'Research Communication'))
      then (count(kwd-group[@kwd-group-type='research-organism']) = 0)
      else ()" 
        role="warning" 
        id="test-ro-kwd-group-presence-2"><value-of select="$subj-type"/> does not contain a Research Organism keyword group. Is this correct?</report>
   </rule>
   
   <rule context="article[@article-type='research-article']/front/article-meta" id="test-research-article-metadata">
   
    <assert test="contrib-group" 
        role="error" 
        id="test-contrib-group-presence-1">contrib-group (with no attributes containing authors) must be present (as a child of article-meta) for research articles.</assert>
     
     <assert test="contrib-group[@content-type='section']" 
        role="error" 
        id="test-contrib-group-presence-2">contrib-group[@content-type='section'] must be present (as a child of article-meta) for research articles (this is the contrib-group which contains reviewers and editors).</assert>
   
   </rule>
    
    <rule context="article[@article-type='editorial']/front/article-meta" id="editorial-metadata">
      
      <report test="contrib-group[@content-type='section']" 
        role="error" 
        id="editorial-editors-presence">Editorials cannot contain Editors and/or Reviewers. This one has a contrib-group[@content-type='section'] containing <value-of select="string-join(for $x in contrib-group[@content-type='section']/contrib return concat('&quot;',e:get-name($x/*[1][name()=('name','collab')]),'&quot;',' as ','&quot;',$x/role[1],'&quot;'),' and ')"/>.</report>
      
    </rule>
	 
   <rule context="article-meta/article-categories" id="test-article-categories">
	 <let name="article-type" value="ancestor::article/@article-type"/>
   <let name="template" value="parent::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']) = 1" 
        role="error" 
        id="disp-subj-test">There must be one subj-group[@subj-group-type='display-channel'] which is a child of article-categories. Currently there are <value-of select="count(article-categories/subj-group[@subj-group-type='display-channel'])"/>.</assert>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']/subject) = 1" 
        role="error" 
        id="disp-subj-test2">subj-group[@subj-group-type='display-channel'] must contain only one subject. Currently there are <value-of select="count(subj-group[@subj-group-type='display-channel']/subject)"/>.</assert>
    
     <report test="count(subj-group[@subj-group-type='heading']) gt 2" 
        role="error" 
        id="head-subj-test1">article-categories must contain 0-2 subj-group[@subj-group-type='heading'] elements. Currently there are <value-of select="count(subj-group[@subj-group-type='heading']/subject)"/>.</report>
	   
     <report test="($article-type = ('correction','research-article','retraction','review-article')) and not($template ='5') and count(subj-group[@subj-group-type='heading']) lt 1" 
        role="error" 
        id="head-subj-test2">article-categories must contain one and or two subj-group[@subj-group-type='heading'] elements. Currently there are <value-of select="count(subj-group[@subj-group-type='heading']/subject)"/>.</report>
     
     <report test="($article-type = ('editorial','discussion')) and count(subj-group[@subj-group-type='heading']) lt 1" 
        role="warning" 
        id="head-subj-test3">article-categories does not contain a subj-group[@subj-group-type='heading']. Is this correct?</report>
	   
     <assert test="count(subj-group[@subj-group-type='heading']/subject) = count(distinct-values(subj-group[@subj-group-type='heading']/subject))" 
        role="error" 
        id="head-subj-distinct-test">Where there are two headings, the content of one must not match the content of the other (each heading should be unique)</assert>
	</rule>
    
    <rule context="article-categories/subj-group[@subj-group-type='display-channel']/subject" id="disp-channel-checks">
    <let name="article-type" value="ancestor::article/@article-type"/> 
      <let name="research-disp-channels" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Scientific Correspondence')"/>
      
      <assert test=". = $allowed-disp-subj" 
        role="error" 
        id="disp-subj-value-test-1">Content of the display channel should be one of the following: Research Article, Short Report, Tools and Resources, Research Advance, Registered Report, Replication Study, Research Communication, Feature Article, Insight, Editorial, Correction, Retraction . Currently it is <value-of select="."/>.</assert>
      
      <report test="($article-type = 'research-article') and not(.=($research-disp-channels,'Feature Article'))" 
        role="error" 
        id="disp-subj-value-test-2">Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be one of 'Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', or 'Scientific Correspondence' according to the article-type.</report>
      
      <report test="($article-type = 'article-commentary') and not(.='Insight')" 
        role="error" 
        id="disp-subj-value-test-3">Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Insight' according to the article-type.</report>
      
      <report test="($article-type = 'editorial') and not(.='Editorial')" 
        role="error" 
        id="disp-subj-value-test-4">Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Editorial' according to the article-type.</report>
      
      <report test="($article-type = 'correction') and not(.='Correction')" 
        role="error" 
        id="disp-subj-value-test-5">Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Correction' according to the article-type.</report>
      
      <report test="($article-type = 'discussion') and not(.='Feature Article')" 
        role="error" 
        id="disp-subj-value-test-6">Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Feature Article' according to the article-type.</report>
      
      <report test="($article-type = 'review-article') and not(.='Review Article')" 
        role="error" 
        id="disp-subj-value-test-7">Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Review Article' according to the article-type.</report>
      
      <report test="($article-type = 'retraction') and not(.='Retraction')" 
        role="error" 
        id="disp-subj-value-test-8">Article is an @article-type="<value-of select="$article-type"/>" but the display channel is <value-of select="."/>. It should be 'Retraction' according to the article-type.</report>
  </rule>
    
    <rule context="article-categories/subj-group[@subj-group-type='heading']/subject" id="MSA-checks">
      
      <assert test=". = $MSAs" 
        role="error" 
        id="head-subj-MSA-test">Content of the heading must match one of the MSAs.</assert>
    </rule>
    
    <rule context="article-categories/subj-group[@subj-group-type='heading']" id="head-subj-checks">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert test="count(subject) = 1" 
        role="error" 
        id="head-subj-test-1">Each subj-group[@subj-group-type='heading'] must contain one and only one subject. This one contains <value-of select="count(subject)"/>.</assert>
    </rule>
	
	<rule context="article/front/article-meta/title-group" id="test-title-group">
	  <let name="subj-type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
	  <let name="lc" value="normalize-space(lower-case(article-title[1]))"/>
	  <let name="title" value="replace(article-title[1],'\p{P}','')"/>
	  <let name="body" value="ancestor::front/following-sibling::body[1]"/>
	  <let name="tokens" value="string-join(for $x in tokenize($title,' ')[position() &gt; 1] return
	    if (matches($x,'^[A-Z]') and (string-length($x) gt 1) and matches($body,concat(' ',lower-case($x),' '))) then $x      else (),', ')"/>
	
    <report test="ends-with(replace(article-title[1],'\p{Z}',''),'.')" 
        role="error" 
        id="article-title-test-1">Article title must not end with a full stop  - '<value-of select="article-title"/>'.</report>  
   
    <report test="article-title[text() != ''] = lower-case(article-title[1])" 
        role="warning" 
        id="article-title-test-2">Article title is entirely in lower case, is this correct? - <value-of select="article-title"/>.</report>
   
    <report test="article-title[text() != ''] = upper-case(article-title[1])" 
        role="error" 
        id="article-title-test-3">Article title must not be entirely in upper case  - <value-of select="article-title"/>.</report>
	  
	  <report test="not(article-title/*) and normalize-space(article-title[1])=''" 
        role="error" 
        id="article-title-test-4">Article title must not be empty.</report>
	  
    <report test="article-title//mml:math" 
        role="warning" 
        id="article-title-test-5">Article title contains maths. Is this correct?</report>
	  
    <report test="article-title//bold" 
        role="error" 
        id="article-title-test-6">Article title must not contain bold.</report>
	  
	  <report test="article-title//underline" 
        role="error" 
        id="article-title-test-7">Article title must not contain underline.</report>
	  
	  <report test="article-title//break" 
        role="error" 
        id="article-title-test-8">Article title must not contain a line break (the element 'break').</report>
	  
	  <report test="matches(article-title[1],'-Based ')" 
        role="error" 
        id="article-title-test-9">Article title contains the string '-Based '. this should be lower-case, '-based '.  - <value-of select="article-title"/></report>
	  
	  <report test="($subj-type = ('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Research Communication', 'Feature article', 'Insight', 'Editorial', 'Scientific Correspondence')) and contains(article-title[1],':')" 
        role="warning" 
        id="article-title-test-10">Article title contains a colon. This almost never allowed. - <value-of select="article-title"/></report>
	  
	  <report test="($subj-type!='Correction') and ($subj-type!='Retraction') and ($subj-type!='Scientific Correspondence') and ($subj-type!='Replication Study') and matches($tokens,'[A-Za-z]')" 
        role="warning" 
        id="article-title-test-11">Article title contains a capitalised word(s) which is not capitalised in the body of the article - <value-of select="$tokens"/> - is this correct? - <value-of select="article-title"/></report>
	  
	  <report test="matches(article-title[1],' [Bb]ased ') and not(matches(article-title[1],' [Bb]ased on '))" 
        role="warning" 
        id="article-title-test-12">Article title contains the string ' based'. Should the preceding space be replaced by a hyphen - '-based'.  - <value-of select="article-title"/></report>
	
	</rule>
    
    <rule context="article[@article-type='review-article']/front/article-meta/title-group/article-title[contains(.,': ')]" 
      id="review-article-title-tests">
      <let name="pre-colon" value="substring-before(.,':')"/>
      <let name="post-colon" value="substring-after(.,': ')"/>
      
      <assert test="substring($pre-colon,1,1) = upper-case(substring($pre-colon,1,1))" 
        role="error" 
        id="review-article-title-1">The first character in the title for a review article should be upper case. '<value-of select="substring($pre-colon,1,1)"/>' in '<value-of select="."/>'</assert>
      
      <assert test="substring($post-colon,1,1) = upper-case(substring($post-colon,1,1))" 
        role="error" 
        id="review-article-title-2">The first character after the colon in the title for a review article should be upper case. '<value-of select="substring($post-colon,1,1)"/>' in '<value-of select="."/>'</assert>
    </rule>
	
	<rule context="article/front/article-meta/contrib-group" id="test-contrib-group">
		
    <assert test="contrib" 
        role="error" 
        id="contrib-presence-test">contrib-group must contain at least one contrib.</assert>
		  
    <report test="count(contrib[@equal-contrib='yes']) = 1" 
        role="error" 
        id="equal-count-test">There is one contrib with the attribute equal-contrib='yes'. This cannot be correct. Either 2 or more contribs within the same contrib-group should have this attribute, or none. Check <value-of select="contrib[@equal-contrib='yes']/name"/></report>
	
	</rule>
    
    <rule context="article/front/article-meta/contrib-group[1]" id="auth-contrib-group">
      <let name="names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="indistinct-names" value="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      <let name="orcids" value="for $x in contrib[@contrib-type='author']/contrib-id[@contrib-id-type='orcid'] return substring-after($x,'orcid.org/')"/>
      <let name="indistinct-orcids" value="for $orcid in distinct-values($orcids) return $orcid[count($orcids[. = $orcid]) gt 1]"/>
      
      <assert test="contrib[@contrib-type='author' and @corresp='yes']" 
        role="error" 
        id="corresp-presence-test">There must be at least one corresponding author (a contrib[@contrib-type='author' and @corresp='yes'] in the first contrib-group).</assert>
      
      <assert test="empty($indistinct-names)" 
        role="warning" 
        id="duplicate-author-test">There is more than one author with the following name(s) - <value-of select="if (count($indistinct-names) gt 1) then concat(string-join($indistinct-names[position() != last()],', '),' and ',$indistinct-names[last()]) else $indistinct-names"/> - which is very likely be incorrect.</assert>
      
      <assert test="empty($indistinct-orcids)" 
        role="error" 
        id="duplicate-orcid-test">There is more than one author with the following ORCiD(s) - <value-of select="if (count($indistinct-orcids) gt 1) then concat(string-join($indistinct-orcids[position() != last()],', '),' and ',$indistinct-orcids[last()]) else $indistinct-orcids"/> - which must be incorrect.</assert>
      
    </rule>
    
    <rule context="article/front/article-meta/contrib-group[@content-type='section']" id="test-editor-contrib-group">
      
      <assert test="count(contrib[@contrib-type='senior_editor']) = 1" 
        role="error" 
        id="editor-conformance-1">contrib-group[@content-type='section'] must contain one (and only 1) Senior Editor (contrib[@contrib-type='senior_editor']).</assert>
      
      <assert test="count(contrib[@contrib-type='editor']) = 1" 
        role="error" 
        id="editor-conformance-2">contrib-group[@content-type='section'] must contain one (and only 1) Reviewing Editor (contrib[@contrib-type='editor']).</assert>
      
    </rule>
    
    <rule context="article/front/article-meta/contrib-group[@content-type='section']/contrib" id="test-editors-contrib">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role[1]"/>
      
      <report test="(@contrib-type='senior_editor') and ($role!='Senior Editor')" 
        role="error" 
        id="editor-conformance-3"><value-of select="$name"/> has a @contrib-type='senior_editor' but their role is not 'Senior Editor' (<value-of select="$role"/>), which is incorrect.</report>
      
      <report test="(@contrib-type='editor') and ($role!='Reviewing Editor')" 
        role="error" 
        id="editor-conformance-4"><value-of select="$name"/> has a @contrib-type='editor' but their role is not 'Reviewing Editor' (<value-of select="$role"/>), which is incorrect.</report>
      
    </rule>
    
    <rule context="article[@article-type='research-article']//article-meta//contrib[(@contrib-type='author') and not(child::collab) and not(ancestor::collab)]" id="auth-cont-tests">
      
      <assert test="child::xref[@ref-type='fn' and matches(@rid,'^con[0-9]{1,3}$')]" 
        role="warning" 
        id="auth-cont-test-1"><value-of select="e:get-name(name[1])"/> has no contributions. Please ensure to query this with the authors.</assert>
    </rule>
    
    <rule context="article[@article-type='research-article']//article-meta//contrib[(@contrib-type='author') and child::collab]" id="collab-cont-tests">
      
      <assert test="child::xref[@ref-type='fn' and matches(@rid,'^con[0-9]{1,3}$')]" 
        role="warning" 
        id="collab-cont-test-1"><value-of select="e:get-collab(child::collab[1])"/> has no contributions. Please ensure to query this with the authors.</assert>
    </rule>
    
    <rule context="article//article-meta/contrib-group[1]/contrib[@contrib-type='author']/collab/contrib-group" 
      id="collab-tests">
      <let name="names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="indistinct-names" value="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      <let name="orcids" value="for $x in contrib[@contrib-type='author']/contrib-id[@contrib-id-type='orcid'] return substring-after($x,'orcid.org/')"/>
      <let name="indistinct-orcids" value="for $orcid in distinct-values($orcids) return $orcid[count($orcids[. = $orcid]) gt 1]"/>
      
      <assert test="empty($indistinct-names)" 
        role="warning" 
        id="duplicate-member-test">There is more than one member of the group author <value-of select="e:get-collab(parent::collab)"/> with the following name(s) - <value-of select="if (count($indistinct-names) gt 1) then concat(string-join($indistinct-names[position() != last()],', '),' and ',$indistinct-names[last()]) else $indistinct-names"/> - which is very likely incorrect.</assert>
      
      <assert test="empty($indistinct-orcids)" 
        role="error" 
        id="duplicate-member-orcid-test">There is more than one member of the group author <value-of select="e:get-collab(parent::collab)"/> with the following ORCiD(s) - <value-of select="if (count($indistinct-orcids) gt 1) then concat(string-join($indistinct-orcids[position() != last()],', '),' and ',$indistinct-orcids[last()]) else $indistinct-orcids"/> - which must be incorrect.</assert>
    </rule>
    
    <rule context="article//article-meta/contrib-group[1][contrib[@contrib-type='author']/collab/contrib-group]" 
      id="collab-tests-2">
      <let name="top-names" value="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <let name="members" value="for $member in contrib[@contrib-type='author']/collab/contrib-group/contrib[@contrib-type='author']/name[1]
        return e:get-name($member)"/>
      <let name="auth-and-member" value="$top-names[.=$members]"/>
      
      <assert test="empty($auth-and-member)" 
        role="warning" 
        id="auth-and-member-test">Top level author(s) <value-of select="if (count($auth-and-member) gt 1) then concat(string-join($auth-and-member[position() != last()],', '),' and ',$auth-and-member[last()]) else $auth-and-member"/> are also a member of a group author. Is this correct?</assert>
    </rule>
    
    <!-- Probably needs extending for general order -->
    <rule context="article-meta//contrib[@contrib-type='author']/xref" id="author-xref-tests">
      
      <report test="(@ref-type='aff') and preceding-sibling::xref[not(@ref-type='aff')]" 
        role="error" 
        id="author-xref-test-1">Affiliation footnote links (xrefs) from authors must be the first type of link. For <value-of select="e:get-name(preceding-sibling::name[1])"/>, their affiliation link - <value-of select="."/> - appears after another non-affiliation link, when it should appear before it.</report>
      
      <report test="(@ref-type='fn') and contains(@rid,'equal') and preceding-sibling::xref[not(@ref-type='aff')]" 
        role="error" 
        id="author-xref-test-2">Equal contribution links from authors must appear after affiliation footnote links. For <value-of select="e:get-name(preceding-sibling::name[1])"/>, their equal contribution link (to <value-of select="idref(@rid)"/>) appears after another non-affiliation link, when it should appear before it.</report>
      
      <report test="(@ref-type='fn') and contains(@rid,'pa') and following-sibling::xref[@ref-type='aff' or contains(@rid,'equal')]" 
        role="error" 
        id="author-xref-test-3">Present address type footnote links from authors must appear after affiliation and equal contribution links (if there is one). For <value-of select="e:get-name(preceding-sibling::name[1])"/>, their present address link (to <value-of select="idref(@rid)"/>) appears before an affiliation link or equal contribution link.</report>
      
      <report test="contains(@rid,'dataset')" 
        role="error" 
        id="author-xref-test-4">Author footnote links to datasets are not needed. Please remove this - &lt;xref <value-of select="string-join(for $x in self::*/@* return concat($x/name(),'=&quot;',$x,'&quot;'),' ')"/>/&gt;</report>
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
		
	  <report test="not(*) and (normalize-space(.)='')" 
        role="error" 
        id="surname-test-2">surname must not be empty.</report>
		
    <report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" 
        role="error" 
        id="surname-test-3">surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	  <assert test="matches(.,&quot;^[\p{L}\p{M}\s'-]*$&quot;)" 
        role="error" 
        id="surname-test-4">surname should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <report test="matches(.,'^\p{Ll}') and not(matches(.,'^de[rn]? |^van |^von |^el |^te[rn] '))" 
        role="warning" 
        id="surname-test-5">surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</report>
	  
	  <report test="matches(.,'^\s')" 
        role="error" 
        id="surname-test-6">surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\s$')" 
        role="error" 
        id="surname-test-7">surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	    
	    <report test="matches(.,'^[A-Z]{1,2}\s') and (string-length(.) gt 3)" 
        role="warning" 
        id="surname-test-8">surname looks to start with initial - '<value-of select="."/>'. Should '<value-of select="substring-before(.,' ')"/>' be placed in the given-names field?</report>
	    
	    <report test="matches(.,'[\(\)\[\]]')" 
	      role="warning" 
	      id="surname-test-9">surname contains brackets - '<value-of select="."/>'. Should the brakceted text be placed in the given-names field instead?</report>
		
	  </rule>
    
    <rule context="contrib-group//name/given-names" id="given-names-tests">
		
	  <report test="not(*) and (normalize-space(.)='')" 
        role="error" 
        id="given-names-test-3">given-names must not be empty.</report>
		
    	<report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc" 
        role="error" 
        id="given-names-test-4">given-names must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript) - '<value-of select="."/>'.</report>
		
      <assert test="matches(.,&quot;^[\p{L}\p{M}\(\)\s'-]*$&quot;)" 
        role="error" 
        id="given-names-test-5">given-names should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <assert test="matches(.,'^\p{Lu}')" 
        role="warning" 
        id="given-names-test-6">given-names doesn't begin with a capital letter - '<value-of select="."/>'. Is this correct?</assert>
	  
	  <report test="matches(.,'^[\p{L}]{1}\.$|^[\p{L}]{1}\.\s?[\p{L}]{1}\.\s?$')" 
        role="error" 
        id="given-names-test-7">given-names contains initialised full stop(s) which is incorrect - <value-of select="."/></report>
	  
	  <report test="matches(.,'^\s')" 
        role="error" 
        id="given-names-test-8">given-names starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\s$')" 
        role="error" 
        id="given-names-test-9">given-names ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'[A-Za-z] [Dd]e[rn]?$')" 
        role="warning" 
        id="given-names-test-10">given-names ends with de, der, or den - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
		
	  <report test="matches(.,'[A-Za-z] [Vv]an$')" 
        role="warning" 
        id="given-names-test-11">given-names ends with ' van' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z] [Vv]on$')" 
        role="warning" 
        id="given-names-test-12">given-names ends with ' von' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
	  
      <report test="matches(.,'[A-Za-z] [Ee]l$')" 
        role="warning" 
        id="given-names-test-13">given-names ends with ' el' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(.,'[A-Za-z] [Tt]e[rn]?$')" 
        role="warning" 
        id="given-names-test-14">given-names ends with te, ter, or ten - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
      
      <report test="matches(normalize-space(.),'[A-Za-z]\s[A-za-z]\s[A-za-z]\s[A-za-z]|[A-Za-z]\s[A-za-z]\s[A-za-z]$|^[A-za-z]\s[A-za-z]$')" 
        role="info" 
        id="given-names-test-15">given-names contains initials with spaces. Esnure that the space(s) is removed between initials - '<value-of select="."/>'.</report>
      
      <report test="matches(.,'[\(\)\[\]]')" 
        role="warning" 
        id="pre-given-names-test-16">given-names contains brackets - '<value-of select="."/>'. This will be flagged by Crossref (although will not actually cause any significant problems). Please add the following author query: Please confirm whether you are happy to remove the brackets around (one of) your given names - '<value-of select="."/>'. This will cause minor issues at Crossref, although they can be retained if desired.</report>
      
      <report test="matches(.,'[\(\)\[\]]')" 
        role="warning" 
        id="final-given-names-test-16">given-names contains brackets - '<value-of select="."/>'. This will be flagged by Crossref (although will not actually cause any significant problems).</report>
		
	</rule>
    
    <rule context="contrib-group//name/suffix" id="suffix-tests">
      
      <assert test=".=('Jr', 'Jnr', 'Sr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')" 
        role="error" 
        id="suffix-assert">suffix can only have one of these values - 'Jr', 'Jnr', 'Sr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'.</assert>
      
      <report test="*" 
        role="error" 
        id="suffix-child-test">suffix cannot have any child elements - <value-of select="*/local-name()"/></report>
      
    </rule>
    
    <rule context="contrib-group//name/*" id="name-child-tests">
      
      <assert test="local-name() = ('surname','given-names','suffix')" 
        role="error" 
        id="disallowed-child-assert"><value-of select="local-name()"/> is not allowed as a child of name.</assert>
      
    </rule>
	
	<rule context="article-meta//contrib" id="contrib-tests">
	  <let name="type" value="@contrib-type"/>
	  <let name="subj-type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
	  <let name="aff-rid1" value="xref[@ref-type='aff'][1]/@rid"/>
	  <let name="inst1" value="ancestor::contrib-group//aff[@id = $aff-rid1]/institution[not(@content-type)][1]"/>
	  <let name="aff-rid2" value="xref[@ref-type='aff'][2]/@rid"/>
	  <let name="inst2" value="ancestor::contrib-group//aff[@id = $aff-rid2]/institution[not(@content-type)][1]"/>
	  <let name="aff-rid3" value="xref[@ref-type='aff'][3]/@rid"/>
	  <let name="inst3" value="ancestor::contrib-group//aff[@id = $aff-rid3]/institution[not(@content-type)][1]"/>
	  <let name="aff-rid4" value="xref[@ref-type='aff'][4]/@rid"/>
	  <let name="inst4" value="ancestor::contrib-group//aff[@id = $aff-rid4]/institution[not(@content-type)][1]"/>
	  <let name="aff-rid5" value="xref[@ref-type='aff'][5]/@rid"/>
	  <let name="inst5" value="ancestor::contrib-group//aff[@id = $aff-rid5]/institution[not(@content-type)][1]"/>
	  <let name="inst" value="concat($inst1,'*',$inst2,'*',$inst3,'*',$inst4,'*',$inst5)"/>
	  <let name="coi-rid" value="xref[starts-with(@rid,'conf')]/@rid"/>
	  <let name="coi" value="ancestor::article//fn[@id = $coi-rid]/p[1]"/>
	  <let name="comp-regex" value="' [Ii]nc[.]?| LLC| Ltd| [Ll]imited| [Cc]ompanies| [Cc]ompany| [Cc]o\.| Pharmaceutical[s]| [Pp][Ll][Cc]|AstraZeneca|Pfizer| R&amp;D'"/>
	  <let name="fn-rid" value="xref[starts-with(@rid,'fn')]/@rid"/>
	  <let name="fn" value="string-join(ancestor::article-meta//author-notes/fn[@id = $fn-rid]/p,'')"/>
	  <let name="name" value="if (child::collab[1]) then collab else if (child::name[1]) then e:get-name(child::name[1]) else ()"/>
		
		<!-- Subject to change depending of the affiliation markup of group authors and editors. Currently fires for individual group contributors and editors who do not have either a child aff or a child xref pointing to an aff.  -->
    	<report test="if ($subj-type = ('Retraction','Correction')) then ()
    	  else if (collab) then ()
    	  else if (ancestor::collab) then ()
    	  else if ($type != 'author') then ()
    	  else count(xref[@ref-type='aff']) = 0" 
        role="error" 
        id="contrib-test-1">Authors should have at least 1 link to an affiliation. <value-of select="$name"/> does not.</report>
	  
	  <report test="if ($subj-type = ('Retraction','Correction')) then ()      else if ($type != 'author') then ()      else if (collab) then ()      else if (ancestor::collab) then (count(xref[@ref-type='aff']) + count(aff) = 0)      else ()" 
        role="warning" 
        id="contrib-test-5">Group author members should very likely have an affiliation. <value-of select="$name"/> does not. Is this OK?</report>
	  
	  <report test="($type = 'senior_editor') and (count(xref[@ref-type='aff']) + count(aff) = 0)" 
        role="warning" 
        id="contrib-test-2">The <value-of select="role[1]"/> doesn't have an affiliation - <value-of select="$name"/> - is this correct?</report>
	  
	  <report test="($type = 'editor') and (count(xref[@ref-type='aff']) + count(aff) = 0)" 
        role="error" 
        id="contrib-test-4">The  <value-of select="role[1]"/> (<value-of select="$name"/>) must have an affiliation. Exeter: If it is not present in the eJP ouput, please check with eLife production. Production: Please check eJP or ask Editorial for the correct affiliation. - is this correct?</report>
	  
	     <report test="name and collab" 
        role="error" 
        id="contrib-test-3">author contains both a child name and a child collab. This is not correct.</report>
	  
	     <report test="if (collab) then ()
	       else count(name) != 1" 
        role="error" 
        id="name-test">Contrib contains no collab but has <value-of select="count(name)"/> name(s). This is not correct.</report>
	  
	     <report test="self::*[@corresp='yes'][not(child::*:email)]" 
        role="error" 
        id="contrib-email-1">Corresponding authors must have an email.</report>
	  
	  <report test="not(@corresp='yes') and (not(ancestor::collab/parent::contrib[@corresp='yes'])) and (child::email)" 
        role="error" 
        id="contrib-email-2">Non-corresponding authors must not have an email.</report>
	  
	  <report test="(@contrib-type='author') and ($coi = 'No competing interests declared') and (matches($inst,$comp-regex))" 
        role="warning" 
        id="COI-test"><value-of select="$name"/> is affiliated with what looks like a company, but contains no COI statement. Is this correct?</report>
	  
	  <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/people/deceased-status#deceased-test-1" 
	      test="matches($fn,'[Dd]eceased') and not(@deceased='yes')" 
        role="error" 
        id="deceased-test-1"><value-of select="$name"/> has a linked footnote '<value-of select="$fn"/>', but not @deceased="yes" which is incorrect.</report>
	  
	  <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/people/deceased-status#deceased-test-2" 
	      test="(@deceased='yes') and not(matches($fn,'[Dd]eceased'))" 
        role="error" 
        id="deceased-test-2"><value-of select="$name"/> has the attribute deceased="yes", but no footnote which contains the text 'Deceased', which is incorrect.</report>
		
		</rule>
    
    <rule context="article[@article-type=('research-article','review-article','discussion')]//article-meta[not(descendant::custom-meta[meta-name='Template']/meta-value='3')]/contrib-group[1][count(contrib[@contrib-type='author' and @corresp='yes']) gt 1]/contrib[@contrib-type='author' and @corresp='yes' and name]" 
      id="corresp-author-initial-tests">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="normalized-name" value="e:stripDiacritics($name)"/>
      
      <report test="$normalized-name != $name" 
        role="warning" 
        id="corresp-author-initial-test"><value-of select="$name"/> has a name with letters that have diacritics or marks. Please ensure that their initials display correctly in the PDF in the 'For correspondence' section on the first page.</report>
      
    </rule>
		
		<rule context="article-meta//contrib[@contrib-type='author']/*" id="author-children-tests">
		  <let name="article-type" value="ancestor::article/@article-type"/> 
		  <let name="template" value="ancestor::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
			<let name="allowed-contrib-blocks" value="('name', 'collab', 'contrib-id', 'email', 'xref')"/>
		  <let name="allowed-contrib-blocks-features" value="($allowed-contrib-blocks, 'bio', 'role')"/>
		
		  <!-- Exception included for group authors - subject to change. The capture here may use xrefs instead of affs - if it does then the else if param can simply be removed. -->
		  <assert test="if ($article-type = $features-article-types) then self::*[local-name() = $allowed-contrib-blocks-features]
		    else if (ancestor::collab) then self::*[local-name() = ($allowed-contrib-blocks,'aff')]
		    else if ($template = '5') then self::*[local-name() = $allowed-contrib-blocks-features]
		    else self::*[local-name() = $allowed-contrib-blocks]" 
        role="error" 
        id="author-children-test"><value-of select="self::*/local-name()"/> is not allowed as a child of author.</assert>
		
		</rule>

	<rule context="contrib-id[@contrib-id-type='orcid']" id="orcid-tests">
	  <let name="text" value="."/>
		
    	<assert test="@authenticated='true'" 
        role="error" 
        id="orcid-test-1">contrib-id[@contrib-id-type="orcid"] must have an @authenticated="true"</assert>
		
		<!-- Needs updating to only allow https when this is implemented -->
	  <assert test="matches(.,'^http[s]?://orcid.org/[\d]{4}-[\d]{4}-[\d]{4}-[\d]{3}[0-9X]$')" 
        role="error" 
        id="orcid-test-2">contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL in the format 'https://orcid.org/0000-0000-0000-0000'</assert>
	  
	  <report test="(preceding::contrib-id[@contrib-id-type='orcid']/text() = $text) or (following::contrib-id[@contrib-id-type='orcid']/text() = $text)" 
        role="warning" 
        id="pre-orcid-test-3"><value-of select="e:get-name(parent::*/name[1])"/>'s ORCiD is the same as another author's - <value-of select="."/>. Duplicated ORCiDs are not allowed. If it is clear who the ORCiD belongs to, remove the duplicate. If it is not clear please add an author query - 'This ORCiD - <value-of select="."/> - is associated with <value-of select="count(preceding::contrib-id[@contrib-id-type='orcid' and text()=$text]) + count(following::contrib-id[@contrib-id-type='orcid' and text()=$text]) + 1"/> authors. Please confirm which author this ORCiD belongs to.'.</report>
	  
	  <report test="(preceding::contrib-id[@contrib-id-type='orcid']/text() = $text) or (following::contrib-id[@contrib-id-type='orcid']/text() = $text)" 
        role="error" 
        id="final-orcid-test-3"><value-of select="e:get-name(parent::*/name[1])"/>'s ORCiD is the same as another author's - <value-of select="."/>. Duplicated ORCiDs are not allowed. If it is clear who the ORCiD belongs to, remove the duplicate. If it is not clear please raise a query with production so that they can raise it with the authors.</report>
		
		</rule>
	
	<rule context="article-meta//email" id="email-tests">
		
    	<assert test="matches(upper-case(.),'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$')" 
        role="error" 
        id="email-test">email element must contain a valid email address. Currently it is <value-of select="self::*"/>.</assert>
		
	</rule>
	
	<rule context="article-meta/history" id="history-tests">
		
    	<assert test="date[@date-type='received']" 
        role="error" 
        id="history-date-test-1">history must contain date[@date-type='received']</assert>
		
    	<assert test="date[@date-type='accepted']" 
        role="error" 
        id="history-date-test-2">history must contain date[@date-type='accepted']</assert>
	
	
	</rule>
	
	<rule context="date" id="date-tests">
	  
	  <assert test="matches(day[1],'^[0-9]{2}$')" 
        role="error" 
        id="date-test-1">date must contain day in the format 00. Currently it is '<value-of select="day"/>'.</assert>
	  
	  <assert test="matches(month[1],'^[0-9]{2}$')" 
        role="error" 
        id="date-test-2">date must contain month in the format 00. Currently it is '<value-of select="month"/>'.</assert>
	  
	  <assert test="matches(year[1],'^[0-9]{4}$')" 
        role="error" 
        id="date-test-3">date must contain year in the format 0000. Currently it is Currently it is '<value-of select="year"/>'.</assert>
		
    	<assert test="@iso-8601-date = concat(year[1],'-',month[1],'-',day[1])" 
        role="error" 
        id="date-test-4">date must have an @iso-8601-date the value of which must be the values of the year-month-day elements. Currently it is <value-of select="@iso-8601-date"/>, when it should be <value-of select="concat(year,'-',month,'-',day)"/>.</assert>
	
	</rule>
    
    <rule context="day[not(parent::string-date)]" id="day-tests">
      
      <assert test="matches(.,'^[0][1-9]$|^[1-2][0-9]$|^[3][0-1]$')" 
        role="error" 
        id="day-conformity">day must contain 2 digits which are between '01' and '31' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule>
    
    <rule context="month[not(parent::string-date)]" id="month-tests">
      
      <assert test="matches(.,'^[0][1-9]$|^[1][0-2]$')" 
        role="error" 
        id="month-conformity">month must contain 2 digits which are between '01' and '12' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule>
    
    <rule context="year[ancestor::article-meta]" id="year-article-meta-tests">
      
      <assert test="matches(.,'^[2]0[0-2][0-9]$')" 
        role="error" 
        id="year-article-meta-conformity">year in article-meta must contain 4 digits which match the regular expression '^[2]0[0-2][0-9]$' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule>
    
    <rule context="year[ancestor::element-citation]" id="year-element-citation-tests">
      
      <assert test="matches(.,'^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$')" 
        role="warning" 
        id="pre-year-element-citation-conformity">year in reference must contain content which matches the regular expression '^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$' - '<value-of select="."/>' doesn't meet this requirement. If there is no year, and this cannot be determined yourself, please query this with the authors.</assert>
      
      <assert test="matches(.,'^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$')" 
        role="error" 
        id="final-year-element-citation-conformity">year in reference must contain content which matches the regular expression '^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$' - '<value-of select="."/>' doesn't meet this requirement. If there is no year, and this cannot be determined yourself, please query this with the authors.</assert>
      
    </rule>
    
    <rule context="pub-date[not(@pub-type='collection')]" id="pub-date-tests-1">
      
      <assert test="matches(day[1],'^[0-9]{2}$')" 
        role="warning" 
        id="pre-pub-date-test-1">day is not present in pub-date.</assert>
      
      <assert test="matches(day[1],'^[0-9]{2}$')" 
        role="error" 
        id="final-pub-date-test-1">pub-date must contain day in the format 00. Currently it is '<value-of select="day"/>'.</assert>
      
      <assert test="matches(month[1],'^[0-9]{2}$')" 
        role="warning" 
        id="pre-pub-date-test-2">month is not present in pub-date.</assert>
      
      <assert test="matches(month[1],'^[0-9]{2}$')" 
        role="error" 
        id="final-pub-date-test-2">pub-date must contain month in the format 00. Currently it is '<value-of select="month"/>'.</assert>
      
      <assert test="matches(year[1],'^[0-9]{4}$')" 
        role="error" 
        id="pub-date-test-3">pub-date must contain year in the format 0000. Currently it is '<value-of select="year"/>'.</assert>
      
    </rule>
    
    <rule context="pub-date[@pub-type='collection']" id="pub-date-tests-2">
      
      <assert test="matches(year[1],'^[0-9]{4}$')" 
        role="error" 
        id="pub-date-test-4">date must contain year in the format 0000. Currently it is '<value-of select="year"/>'.</assert>
      
      <report test="*/local-name() != 'year'" 
        role="error" 
        id="pub-date-test-5">pub-date[@pub-type='collection'] can only contain a year element.</report>
      
      <assert test="year[1] = parent::*/pub-date[@publication-format='electronic'][@date-type='publication']/year[1]" 
        role="error" 
        id="pub-date-test-6">pub-date[@pub-type='collection'] year must be the same as pub-date[@publication-format='electronic'][@date-type='publication'] year.</assert>
      
    </rule>
	
	<rule context="front//permissions" id="front-permissions-tests">
	<let name="author-count" value="count(ancestor::article-meta//contrib[@contrib-type='author'])"/>
	  <let name="license-type" value="license/@xlink:href"/>
	
	  <report see ="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-1" 
	      test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then ()
	    else not(copyright-statement)" 
        role="error" 
        id="permissions-test-1">permissions must contain copyright-statement.</report>
	
	  <report see ="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-2" 
	      test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then ()
	          else not(matches(copyright-year[1],'^[0-9]{4}$'))" 
        role="error" 
        id="permissions-test-2">permissions must contain copyright-year in the format 0000. Currently it is <value-of select="copyright-year"/></report>
	
	  <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-3" 
	      test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then ()
	            else not(copyright-holder)" 
        role="error" 
        id="permissions-test-3">permissions must contain copyright-holder.</report>
	
	  <assert see ="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-4" 
	      test="ali:free_to_read" 
        role="error" 
        id="permissions-test-4">permissions must contain an ali:free_to_read element.</assert>
	
	<assert test="license" 
        role="error" 
        id="permissions-test-5">permissions must contain license.</assert>
	
	  <report see ="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-6" 
	      test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then ()
	          else not(copyright-year = ancestor::article-meta/pub-date[@publication-format='electronic'][@date-type='publication']/year)" 
        role="error" 
        id="permissions-test-6">copyright-year must match the contents of the year in the pub-date[@publication-format='electronic'][@date-type='publication']. Currently, copyright-year=<value-of select="copyright-year"/> and pub-date=<value-of select="ancestor::article-meta/pub-date[@publication-format='electronic'][@date-type='publication']/year"/>.</report>
	
	  <report see ="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-7" 
	    test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then ()
	    else if ($author-count = 1) then copyright-holder != ancestor::article-meta//contrib[@contrib-type='author']//surname      else if ($author-count = 2) then copyright-holder != concat(ancestor::article-meta/descendant::contrib[@contrib-type='author'][1]//surname,' and ',ancestor::article-meta/descendant::contrib[@contrib-type='author'][2]//surname)  else copyright-holder != concat(ancestor::article-meta/descendant::contrib[@contrib-type='author'][1]//surname,' et al')" 
        role="error" 
        id="permissions-test-7">copyright-holder is incorrect. If the article has one author then it should be their surname. If it has two authors it should be the surname of the first, then ' and ' and then the surname of the second. If three or more, it should be the surname of the first, and then ' et al'. Currently it's <value-of select="copyright-holder"/></report>
	
	  <report see ="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-8" 
	    test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then ()
	    else not(copyright-statement = concat('© ',copyright-year,', ',copyright-holder))" 
        role="error" 
        id="permissions-test-8">copyright-statement must contain a concatenation of '© ', copyright-year, and copyright-holder. Currently it is <value-of select="copyright-statement"/> when according to the other values it should be <value-of select="concat('© ',copyright-year,', ',copyright-holder)"/></report>
	  
	  <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-test-9" 
	    test="($license-type = 'http://creativecommons.org/publicdomain/zero/1.0/') or ($license-type = 'http://creativecommons.org/licenses/by/4.0/')" 
        role="error" 
        id="permissions-test-9">license does not have an @xlink:href which is equal to 'http://creativecommons.org/publicdomain/zero/1.0/' or 'http://creativecommons.org/licenses/by/4.0/'.</assert>
	  
	  <report see ="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-info" 
	      test="license" 
        role="info" 
        id="permissions-info">This article is licensed under a<value-of select="
	    if (contains($license-type,'publicdomain/zero')) then ' CC0 1.0'
	    else if (contains($license-type,'by/4.0')) then ' CC BY 4.0'
	    else if (contains($license-type,'by/3.0')) then ' CC BY 3.0'
	    else 'n unknown'"/> license. <value-of select="$license-type"/></report>
	
	</rule>
	
	<rule context="front//permissions/license" id="license-tests">
	
	  <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#license-test-1" 
	      test="ali:license_ref" 
        role="error" 
        id="license-test-1">license must contain ali:license_ref.</assert>
	
	  <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#license-test-2" 
	      test="count(license-p) = 1" 
        role="error" 
        id="license-test-2">license must contain one and only one license-p.</assert>
	
	</rule>
	
	<rule context="front//abstract" id="abstract-tests">
	  <let name="article-type" value="ancestor::article/@article-type"/>
	
	<report test="(count(p) + count(sec[descendant::p])) lt 1" 
        role="error" 
        id="abstract-test-2">At least 1 p element or sec element (with descendant p) must be present in abstract.</report>
	
	<report test="descendant::disp-formula" 
        role="error" 
        id="abstract-test-4">abstracts cannot contain display formulas.</report>
	  
	  <report test="child::sec and count(sec) != 6" 
        role="error" 
        id="abstract-test-5">If an abstract has sections, then it must have the 6 sections required for clinical trial abstracts.</report>
	  
	  <report test="matches(lower-case(.),'^\s*abstract')" 
        role="warning" 
        id="abstract-test-6">Abstract starts with the word 'Abstract', which is almost certainly incorrect - <value-of select="."/></report>
	  
	    <report test="some $x in child::p satisfies (starts-with($x,'Background:') or starts-with($x,'Methods:') or starts-with($x,'Results:') or starts-with($x,'Conclusion:') or starts-with($x,'Trial registration:') or starts-with($x,'Clinical trial number:'))" 
        role="warning" 
        id="abstract-test-7">Abstract looks like it should instead be captured as a structured abstract (using sections) - <value-of select="."/></report>
		
    </rule>
    
    <rule context="front//abstract/*" id="abstract-children-tests">
      <let name="allowed-elems" value="('p','sec','title')"/>
      
      <assert test="local-name() = $allowed-elems" 
        role="error" 
        id="abstract-child-test-1"><name/> is not allowed as a child of abstract.</assert>
    </rule>
    
    <rule context="abstract[not(@abstract-type)]/sec" id="abstract-sec-titles">
      <let name="pos" value="count(ancestor::abstract/sec) - count(following-sibling::sec)"/>
      
      <report test="($pos = 1) and (title != 'Background:')" 
        role="error" 
        id="clintrial-conformance-1">First section title is '<value-of select="title"/>' - but the only allowed value is 'Background:'.</report>
      
      <report test="($pos = 2) and (title != 'Methods:')" 
        role="error" 
        id="clintrial-conformance-2">Second section title is '<value-of select="title"/>' - but the only allowed value is 'Methods:'.</report>
      
      <report test="($pos = 3) and (title != 'Results:')" 
        role="error" 
        id="clintrial-conformance-3">Third section title is '<value-of select="title"/>' - but the only allowed value is 'Results:'.</report>
      
      <report test="($pos = 4) and (title != 'Conclusions:')" 
        role="error" 
        id="clintrial-conformance-4">Fourth section title is '<value-of select="title"/>' - but the only allowed value is 'Conclusions:'.</report>
      
      <report test="($pos = 6) and (title != 'Clinical trial number:')" 
        role="error" 
        id="clintrial-conformance-5">Sixth section title is '<value-of select="title"/>' - but the only allowed value is 'Clinical trial number:'.</report>
      
      <report test="($pos = 5) and (title != 'Funding:')" 
        role="error" 
        id="clintrial-conformance-6">Fifth section title is '<value-of select="title"/>' - but the only allowed value is 'Funding:'.</report>
      
      <report test="child::sec" 
        role="error" 
        id="clintrial-conformance-7">Nested secs are not allowed in abstracts. Sec with the id <value-of select="@id"/> and title '<value-of select="title"/>' has child sections.</report>
      
      <assert test="matches(@id,'^abs[1-9]$')" 
        role="error" 
        id="clintrial-conformance-8"><name/> must have an @id in the format 'abs1'. <value-of select="@id"/> does not conform to this convention.</assert>
    </rule>
    
    <rule context="abstract[not(@abstract-type) and sec]//related-object" id="clintrial-related-object">
      <let name="registries" value="'clinical-trial-registries.xml'"/>
      
      <assert test="ancestor::sec[title = 'Clinical trial number:']" 
        role="error" 
        id="clintrial-related-object-1"><name/> in abstract must be placed in a section whose title is 'Clinical trial number:'</assert>
      
      <assert test="@source-type='clinical-trials-registry'" 
        role="error" 
        id="clintrial-related-object-2"><name/> must have an @source-type='clinical-trials-registry'.</assert>
      
      <assert test="@source-id" 
        role="error" 
        id="clintrial-related-object-3"><name/> must have an @source-id.</assert>
      
      <assert test="@source-id-type='registry-name'" 
        role="error" 
        id="clintrial-related-object-4"><name/> must have an @source-id-type='registry-name'.</assert>
      
      <assert test="@document-id-type='clinical-trial-number'" 
        role="error" 
        id="clintrial-related-object-5"><name/> must have an @document-id-type='clinical-trial-number'.</assert>
      
      <assert test="@document-id" 
        role="error" 
        id="clintrial-related-object-6"><name/> must have an @document-id.</assert>
      
      <assert test="@xlink:href" 
        role="error" 
        id="clintrial-related-object-7"><name/> must have an @xlink:href.</assert>
      
      <assert test="contains(.,@document-id/string())" 
        role="warning" 
        id="clintrial-related-object-8"><name/> has an @document-id '<value-of select="@document-id"/>'. But this is not in the text, which is likely incorrect - <value-of select="."/>.</assert>
      
      <assert test="matches(@id,'^RO[1-9]')" 
        role="error" 
        id="clintrial-related-object-9"><name/> must have an @id in the format 'RO1'. '<value-of select="@id"/>' does not conform to this convention.</assert>
      
      <assert test="parent::p" 
        role="error" 
        id="clintrial-related-object-10"><name/> in abstract must be a child of a &lt;p&gt; element.</assert>
      
      <assert test="some $x in document($registries)/registries/registry satisfies ($x/subtitle/string()=@source-id)" 
        role="error" 
        id="clintrial-related-object-11"><name/> @source-id value must be one of the subtitles of the Crossref clinical trial registries. "<value-of select="@source-id"/>" is not one of the following <value-of select="string-join(for $x in document($registries)/registries/registry return concat('&quot;',$x/subtitle/string(),'&quot; (',$x/doi/string(),')'),', ')"/></assert>
      
    </rule>
	
    <!-- Exclusion for structured abstracts (clinical trials) -->
    <rule context="front//abstract[not(@abstract-type) and not(sec)]" id="abstract-word-count">
      <let name="p-words" value="string-join(child::p[not(starts-with(.,'DOI:') or starts-with(.,'Editorial note:'))],' ')"/>
	    <let name="count" value="count(tokenize(normalize-space(replace($p-words,'\p{P}','')),' '))"/>
	     
      <report test="($count gt 180)" 
        role="warning" 
        id="pre-abstract-word-count-restriction">The abstract contains <value-of select="$count"/> words, when the usual upper limit is 180. Exeter: Please check with the eLife production team who will need to contact the eLife Editorial team.</report>
	     
      <report test="($count gt 180)" 
        role="warning" 
        id="final-abstract-word-count-restriction">The abstract contains <value-of select="$count"/> words, when the usual upper limit is 180. Abstracts with more than 180 words should be checked with the eLife Editorial team.</report>
	   </rule>
	
    <rule context="article-meta/contrib-group/aff" id="aff-tests">
      
    <assert test="parent::contrib-group//contrib//xref/@rid = @id" 
        role="error" 
        id="aff-test-1">aff elements that are direct children of contrib-group must have an xref in that contrib-group pointing to them.</assert>
    </rule>
    
    <rule context="article-meta/contrib-group[not(@*)]/aff" id="author-aff-tests">
      <let name="display" value="string-join(child::*[not(local-name()='label')],', ')"/>
      
      <assert test="country" 
        role="warning" 
        id="pre-auth-aff-test-1">Author affiliations must have a country. This one does not - <value-of select="$display"/>. Please query with the authors.</assert>
      
      <assert test="country" 
        role="error" 
        id="final-auth-aff-test-1">Author affiliations must have a country. This one does not - <value-of select="$display"/>.</assert>
      
      <assert test="addr-line[named-content[@content-type='city']]" 
        role="warning" 
        id="pre-auth-aff-test-2">Author affiliations must have a city. This one does not - <value-of select="$display"/>. Please query the authors.</assert>
      
      <assert test="addr-line[named-content[@content-type='city']]" 
        role="error" 
        id="final-auth-aff-test-2">Author affiliations must have a city. This one does not - <value-of select="$display"/></assert>
      
      <assert test="institution[not(@*)]" 
        role="warning" 
        id="pre-auth-aff-test-3">Author affiliations must have a top level institution. This one (with the id <value-of select="@id"/>) does not - <value-of select="$display"/>. Please query the authors.</assert>
      
      <assert test="institution[not(@*)]" 
        role="error" 
        id="final-auth-aff-test-3">Author affiliations must have a top level institution. This one (with the id <value-of select="@id"/>) does not - <value-of select="$display"/></assert>
    </rule>
    
    <rule context="aff" id="gen-aff-tests">
      <let name="display" value="string-join(child::*[not(local-name()='label')],', ')"/>
      
     <report test="count(institution[not(@*)]) gt 1" 
        role="error" 
        id="gen-aff-test-1">Affiliations cannot have more than 1 top level institutions. <value-of select="$display"/> has <value-of select="count(institution[not(@*)])"/>.</report>
    
     <report test="count(institution[@content-type='dept']) ge 1" 
        role="warning" 
        id="gen-aff-test-2">Affiliation has <value-of select="count(institution[@content-type='dept'])"/> department field(s) - <value-of select="$display"/>. Is this correct?</report>
      
      <report test="count(label) gt 1" 
        role="error" 
        id="gen-aff-test-3">Affiliations cannot have more than 1 label. <value-of select="$display"/> has <value-of select="count(label)"/>.</report>
      
      <report test="count(addr-line) gt 1" 
        role="error" 
        id="gen-aff-test-4">Affiliations cannot have more than 1 addr-line elements. <value-of select="$display"/> has <value-of select="count(addr-line)"/>.</report>
      
      <report test="count(country) gt 1" 
        role="error" 
        id="gen-aff-test-5">Affiliations cannot have more than 1 country elements. <value-of select="$display"/> has <value-of select="count(country)"/>.</report>
      
      <report test="text()" 
        role="error" 
        id="gen-aff-test-6">aff elements cannot contain text. They can only contain elements (label, institution, addr-line, country). This one (<value-of select="@id"/>) contains the text '<value-of select="string-join(text(),'')"/>'</report>
    </rule>
    
    <rule context="aff/*" id="aff-child-tests">
      <let name="allowed-elems" value="('label','institution','addr-line','country')"/>
      
      <assert test="name()=$allowed-elems" 
        role="error" 
        id="aff-child-conformity"><value-of select="name()"/> is not allowed as a child of &lt;aff&gt;.</assert>
      
    </rule>
    
    <rule context="addr-line" id="addr-line-parent-test">
      
      <assert test="parent::aff" 
        role="error" 
        id="addr-line-parent"><value-of select="name()"/> is not allowed as a child of &lt;<value-of select="parent::*[1]/local-name()"/>&gt;.</assert>
    </rule>
    
    <rule context="addr-line/*" id="addr-line-child-tests">
      
      <assert test="name()='named-content'" 
        role="error" 
        id="addr-line-child-1"><value-of select="name()"/> is not allowed as a child of &lt;addr-line&gt;.</assert>
      
      <report test="(name()='named-content') and not(@content-type='city')" 
        role="error" 
        id="addr-line-child-2"><value-of select="name()"/> in &lt;addr-line&gt; must have the attribute content-type="city". <value-of select="."/> does not.</report>
    </rule>
    
	<rule context="article-meta/funding-group" id="funding-group-tests">
		
		<assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#funding-group-test-1" 
        test="count(funding-statement) = 1" 
        role="error" 
        id="funding-group-test-1">One funding-statement should be present in funding-group.</assert>
		
		<report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#funding-group-test-2" 
        test="count(award-group) = 0" 
        role="warning" 
        id="funding-group-test-2">There is no funding for this article. Is this correct?</report>
		
	  <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#funding-group-test-3" 
        test="(count(award-group) = 0) and (funding-statement!='No external funding was received for this work.')" 
        role="warning" 
        id="funding-group-test-3">Is this funding-statement correct? - '<value-of select="funding-statement"/>' Usually it should be 'No external funding was received for this work.'</report>
	  
	  <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#funding-group-test-4" 
	    test="(count(award-group) != 0) and not(matches(funding-statement[1],'^The funders? had no role in study design, data collection and interpretation, or the decision to submit the work for publication\.$'))" 
	    role="warning" 
	    id="funding-group-test-4">Is the funding-statement correct? There are funders, but the statement is '<value-of select="funding-statement[1]"/>'. If there are funders it should usually be 'The funders had no role in study design, data collection and interpretation, or the decision to submit the work for publication.'</report>
    </rule>
	
	<rule context="funding-group/award-group" id="award-group-tests">
	  <let name="id" value="@id"/>
	  <let name="institution" value="funding-source[1]/institution-wrap[1]/institution[1]"/>
		
		<assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-group-test-2" 
        test="funding-source" 
        role="error" 
        id="award-group-test-2">award-group must contain a funding-source.</assert>
		
		<assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#pre-award-group-test-3" 
        test="principal-award-recipient" 
        role="warning" 
        id="pre-award-group-test-3">award-group must contain a principal-award-recipient. If it is not clear which author(s) are associated with this funding, please add an author query.</assert>
	  
	  <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#final-award-group-test-3" 
        test="principal-award-recipient" 
        role="error" 
        id="final-award-group-test-3">award-group must contain a principal-award-recipient.</assert>
		
		<report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-group-test-4" 
        test="count(award-id) gt 1" 
        role="error" 
        id="award-group-test-4">award-group may contain one and only one award-id.</report>
		
		<assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-group-test-5" 
        test="funding-source/institution-wrap" 
        role="error" 
        id="award-group-test-5">funding-source must contain an institution-wrap.</assert>
		
		<report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-group-test-6" 
        test="count(funding-source/institution-wrap/institution) = 0" 
        role="error" 
        id="award-group-test-6">Every piece of funding must have an institution. &lt;award-group id="<value-of select="@id"/>"&gt; does not have one.</report>
	  
	  <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#pre-award-group-test-7" 
        test="ancestor::article//article-meta//contrib//xref/@rid = $id" 
        role="warning" 
        id="pre-award-group-test-7">There is no author associated with the funding for <value-of select="$institution"/>, which is incorrect. (There is no xref from a contrib pointing to this &lt;award-group id="<value-of select="$id"/>"&gt;). If you are unable to determine which author(s) are associated with this funding, please add an author query.</assert>
	  
	  <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#final-award-group-test-7" 
        test="ancestor::article//article-meta//contrib//xref/@rid = $id" 
        role="error" 
        id="final-award-group-test-7">There is no author associated with the funding for <value-of select="$institution"/>, which is incorrect. (There is no xref from a contrib pointing to this &lt;award-group id="<value-of select="$id"/>"&gt;).</assert>
	  
	  <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-group-test-8" 
        test="count(funding-source/institution-wrap/institution) gt 1" 
        role="error" 
        id="award-group-test-8">Every piece of funding must only have 1 institution. &lt;award-group id="<value-of select="@id"/>"&gt; has <value-of select="count(funding-source/institution-wrap/institution)"/> - <value-of select="string-join(funding-source/institution-wrap/institution,', ')"/>.</report>
	</rule>
    
    <rule context="funding-group/award-group/award-id" id="award-id-tests">
      <let name="id" value="parent::award-group/@id"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-id-test-1" 
        test="matches(.,',|;')" 
        role="warning" 
        id="award-id-test-1">Funding entry with id <value-of select="$id"/> has a comma or semi-colon in the award id. Should this be separated out into several funding entries? - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-id-test-2" 
        test="matches(.,'^\s?[Nn][/]?[\.]?[Aa][.]?\s?$')" 
        role="error" 
        id="award-id-test-2">Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-id-test-3" 
        test="matches(.,'^\s?[Nn]one[\.]?\s?$')" 
        role="error" 
        id="award-id-test-3">Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#award-id-test-4" 
        test="matches(.,'&amp;#x\d')" 
        role="warning" 
        id="award-id-test-4">Award id contains what looks like a broken unicode - <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="article-meta//award-group//institution-wrap" id="institution-wrap-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#institution-id-test" 
        test="institution-id[@institution-id-type='FundRef']" 
        role="warning" 
        id="institution-id-test">Whenever possible, a funder should have a doi - please check whether there is an appropriate doi in the open funder registry. (institution-id[@institution-id-type="FundRef"] is not present in institution-wrap).</assert>
      
    </rule>
    
    <rule context="institution-wrap/institution-id" id="institution-id-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#institution-id-test-2" 
        test="@institution-id-type='FundRef'" 
        role="error" 
        id="institution-id-test-2"><name/> element must have the attribute institution-id-type="FundRef".</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#institution-id-test-3" 
        test="normalize-space(.) != ''" 
        role="error" 
        id="institution-id-test-3">The funding entry for <value-of select="parent::institution-wrap/institution"/> has an empty <name/> element, which is not allowed.</assert>
      
        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#institution-id-test-4" 
        test="*" 
        role="error" 
        id="institution-id-test-4">The <name/> element in funding entry for <value-of select="parent::institution-wrap/institution"/> contains child element(s) (<value-of select="string-join(distinct-values(*/name()),', ')"/>) which is not allowed.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#institution-id-test-5" 
        test="(normalize-space(.) != '') and not(matches(.,'^http[s]?://d?x?\.?doi.org/10.13039/\d*$'))" 
        role="error" 
        id="institution-id-test-5"><name/> element in funding entry for <value-of select="parent::institution-wrap/institution"/> contains the following text - <value-of select="."/> - which is not a fundref doi.</report>
      
    </rule>
    
    <rule context="funding-group//principal-award-recipient/name" id="par-name-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#par-name-test-1" 
        test="contains(.,'.')" 
        role="error" 
        id="par-name-test-1">Author name in funding entry contains a full stop - <value-of select="e:get-name(.)"/>. Please remove the full stop.</report>
      
    </rule>
    
    <rule context="article-meta/kwd-group[not(@kwd-group-type='research-organism')]" id="kwd-group-tests">
      
      <assert test="@kwd-group-type='author-keywords'" 
        role="error" 
        id="kwd-group-type">kwd-group must have a @kwd-group-type 'research-organism', or 'author-keywords'.</assert>
      
      <assert test="kwd" 
        role="warning" 
        id="non-ro-kwd-presence-test">kwd-group must contain at least one kwd</assert>
    </rule>
    
    <rule context="article-meta/kwd-group[@kwd-group-type='research-organism']" id="ro-kwd-group-tests">
	  
      <assert test="title = 'Research organism'" 
        role="error" 
        id="kwd-group-title">kwd-group title is <value-of select="title"/>, which is wrong. It should be 'Research organism'.</assert>
      
      <assert test="kwd" 
        role="warning" 
        id="ro-kwd-presence-test">kwd-group must contain at least one kwd</assert>
	
	</rule>
    
    <rule context="article-meta/kwd-group[@kwd-group-type='research-organism']/kwd" id="ro-kwd-tests">
      
      <assert test="substring(.,1,1) = upper-case(substring(.,1,1))" 
        role="error" 
        id="kwd-upper-case">research-organism kwd elements should start with an upper-case letter.</assert>
      
      <report test="*[local-name() != 'italic']" 
        role="error" 
        id="kwd-child-test">research-organism keywords cannot have child elements such as <value-of select="*/local-name()"/>.</report>
      
    </rule>
    
    <rule context="article-meta/custom-meta-group" id="custom-meta-group-tests">
      <let name="type" value="parent::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="($type = $research-subj) and count(custom-meta[@specific-use='meta-only']) != 1" 
        role="error" 
        id="custom-meta-presence">1 and only 1 custom-meta[@specific-use='meta-only'] must be present in custom-meta-group for <value-of select="$type"/>.</report>
      
      <report test="($type = $features-subj) and count(custom-meta[@specific-use='meta-only']) != 2" 
        role="error" 
        id="features-custom-meta-presence">2 custom-meta[@specific-use='meta-only'] must be present in custom-meta-group for <value-of select="$type"/>.</report>
      
    </rule>
    
    <rule context="article-meta/custom-meta-group/custom-meta" id="custom-meta-tests">
      <let name="type" value="ancestor::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="pos" value="count(parent::custom-meta-group/custom-meta) - count(following-sibling::custom-meta)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-1" 
        test="count(meta-name) = 1" 
        role="error" 
        id="custom-meta-test-1">One meta-name must be present in custom-meta.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-2" 
        test="($type = $research-subj) and (meta-name != 'Author impact statement')" 
        role="error" 
        id="custom-meta-test-2">The value of meta-name can only be 'Author impact statement'. Currently it is <value-of select="meta-name"/>.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-3" 
        test="count(meta-value) = 1" 
        role="error" 
        id="custom-meta-test-3">One meta-value must be present in custom-meta.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-14" 
        test="($type = $features-subj) and ($pos=1) and  (meta-name != 'Author impact statement')" 
        role="error" 
        id="custom-meta-test-14">The value of the 1st meta-name can only be 'Author impact statement'. Currently it is <value-of select="meta-name"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-15" 
        test="($type = $features-subj) and ($pos=2) and  (meta-name != 'Template')" 
        role="error" 
        id="custom-meta-test-15">The value of the 2nd meta-name can only be 'Template'. Currently it is <value-of select="meta-name"/>.</report>
      
    </rule>
      
    <rule context="article-meta/custom-meta-group/custom-meta[meta-name='Author impact statement']/meta-value" id="meta-value-tests">
      <let name="subj" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="count" value="count(for $x in tokenize(normalize-space(replace(.,'\p{P}','')),' ') return $x)"/>
      <let name="we-token" value="substring-before(substring-after(lower-case(.),' we '),' ')"/>
      <let name="verbs" value="('name', 'named', 'can', 'progress', 'progressed', 'explain', 'explained', 'found', 'founded', 'present', 'presented', 'have', 'describe', 'described', 'showed', 'report', 'reported', 'miss', 'missed', 'identify', 'identified', 'better', 'bettered', 'validate', 'validated', 'use', 'used', 'listen', 'listened', 'demonstrate', 'demonstrated', 'argue', 'argued', 'will', 'assess', 'assessed', 'are', 'may', 'observe', 'observed', 'find', 'found', 'previously', 'should', 'rely', 'relied', 'reflect', 'reflected', 'recognise', 'recognised', 'attend', 'attended', 'first', 'define', 'defined', 'here', 'need', 'needed')"/>
      
      <report test="not(child::*) and normalize-space(.)=''" 
        role="error" 
        id="custom-meta-test-4">The value of meta-value cannot be empty</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-5" 
        test="($count gt 30)" 
        role="warning" 
        id="custom-meta-test-5">Impact statement contains more than 30 words (<value-of select="$count"/>). This is not allowed.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#pre-custom-meta-test-6" 
        test="matches(.,'[\.|\?]$')" 
        role="warning" 
        id="pre-custom-meta-test-6">Impact statement must end with a full stop or question mark.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#final-custom-meta-test-6" 
        test="matches(.,'[\.|\?]$')" 
        role="error" 
        id="final-custom-meta-test-6">Impact statement must end with a full stop or question mark.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-7" 
        test="matches(replace(.,' et al\. ',' et al '),'[\p{L}][\p{L}]+\. .*$|[\p{L}\p{N}][\p{L}\p{N}]+\? .*$|[\p{L}\p{N}][\p{L}\p{N}]+! .*$')" 
        role="warning" 
        id="custom-meta-test-7">Impact statement appears to be made up of more than one sentence. Please check, as more than one sentence is not allowed.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-8" 
        test="not($subj = 'Replication Study') and matches(.,'[:;]')" 
        role="warning" 
        id="custom-meta-test-8">Impact statement contains a colon or semi-colon, which is likely incorrect. It needs to be a proper sentence.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#pre-custom-meta-test-9" 
        test="matches(.,'[Ww]e show|[Ww]e present|[Tt]his study|[Tt]his paper')" 
        role="warning" 
        id="pre-custom-meta-test-9">Impact statement contains a possessive phrase. This is not allowed.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#final-custom-meta-test-9" 
        test="matches(.,'[Ww]e show|[Ww]e present|[Tt]his study|[Tt]his paper')" 
        role="error" 
        id="final-custom-meta-test-9">Impact statement contains a possessive phrase. This is not allowed.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-10" 
        test="matches(.,'^[\d]+$')" 
        role="error" 
        id="custom-meta-test-10">Impact statement is comprised entirely of numbers, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-11" 
        test="matches(.,' [Oo]ur |^[Oo]ur ')" 
        role="warning" 
        id="custom-meta-test-11">Impact statement contains 'our'. Is this possessive langauge relating to the article or research itself (which should be removed)?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-13" 
        test="matches(.,' study ') and not(matches(.,'[Tt]his study'))" 
        role="warning" 
        id="custom-meta-test-13">Impact statement contains 'study'. Is this a third person description of this article? If so, it should be changed to not include this.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#pre-rep-study-custom-meta-test" 
        test="($subj = 'Replication Study') and not(matches(.,'^Editors[\p{Po}] Summary: '))" 
        role="warning" 
        id="pre-rep-study-custom-meta-test">Impact statement in Replication studies must begin with 'Editors' summary: '. This does not - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#final-rep-study-custom-meta-test" 
        test="($subj = 'Replication Study') and not(matches(.,'^Editors[\p{Po}] Summary: '))" 
        role="error" 
        id="final-rep-study-custom-meta-test">Impact statement in Replication studies must begin with 'Editors' summary: '. This does not - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-test-16" 
        test="$we-token = $verbs" 
        role="warning" 
        id="custom-meta-test-16">Impact statement contains 'we' followed by a verb - '<value-of select="concat('we ',$we-token)"/>' in '<value-of select="."/>'. Is this possessive language relating to the article or research itself (which should be removed)?</report>
    </rule>
    
    <rule context="article-meta/custom-meta-group/custom-meta/meta-value/*" id="meta-value-child-tests">
      <let name="allowed-elements" value="('italic','sup','sub')"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#custom-meta-child-test-1" 
        test="local-name() = $allowed-elements" 
        role="error" 
        id="custom-meta-child-test-1"><name/> is not allowed in impact statement.</assert>
      
    </rule>
    
    <rule context="article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value" id="featmeta-value-tests">
      <let name="type" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="child::*" 
        role="error" 
        id="feat-custom-meta-test-1"><value-of select="child::*[1]/name()"/> is not allowed in a Template type meta-value.</report>
      
      <assert test=". = ('1','2','3','4','5')" 
        role="error" 
        id="feat-custom-meta-test-2">Template type meta-value must one of '1','2','3','4', or '5'.</assert>
      
      <report test=". = ('1','2','3','4','5')" 
        role="info" 
        id="feat-custom-meta-test-info">Template <value-of select="."/>.</report>
      
      <report test="($type='Insight') and (. != '1')" 
        role="error" 
        id="feat-custom-meta-test-3"><value-of select="$type"/> must be a template 1. Currently it is a template <value-of select="."/>.</report>
      
      <report test="($type='Editorial') and (. != '2')" 
        role="error" 
        id="feat-custom-meta-test-4"><value-of select="$type"/> must be a template 2. Currently it is a template <value-of select="."/>.</report>
      
      <report test="($type='Feature Article') and not(.=('3','4','5'))" 
        role="error" 
        id="feat-custom-meta-test-5"><value-of select="$type"/> must be a template 3, 4, or 5. Currently it is a template <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="article-meta/elocation-id" id="elocation-id-tests">
      <let name="article-id" value="parent::article-meta/article-id[@pub-id-type='publisher-id'][1]"/>
      
      <assert test=". = concat('e' , $article-id)" 
        role="error" 
        id="test-elocation-conformance">elocation-id is incorrect. Its value should be a concatenation of 'e' and the article id, in this case <value-of select="concat('e',$article-id)"/>.</assert>
    </rule>
    
    <rule context="related-object" id="related-object-tests">
      
      <assert test="ancestor::abstract[not(@abstract-type)]" 
        role="error" 
        id="related-object-ancetsor"><name/> is not allowed outside of the main abstract (abstract[not(@abstract-type)]).</assert>
    </rule>
 </pattern>
  
  <pattern id="journal-volume">
    
    <rule context="article-meta/volume" id="volume-test">
      <!-- @date-type='pub' included for legacy content -->
      <let name="pub-date" value="parent::article-meta/pub-date[@publication-format='electronic'][@date-type=('publication','pub')]/year[1]"/>
      
      <assert test=". = number($pub-date) - 2011" 
        role="error" 
        id="volume-test-1">Journal volume is incorrect. It should be <value-of select="number($pub-date) - 2011"/>.</assert>
    </rule>
  </pattern>

  <pattern id="equal-author-checks">

  <rule context="article-meta//contrib[@contrib-type='author']" id="equal-author-tests">
    	
    <report test="@equal-contrib='yes' and not(xref[matches(@rid,'^equal-contrib[0-9]$')])" 
        role="error" 
        id="equal-author-test-1">Equal authors must contain an xref[@ref-type='fn'] with an @rid that starts with 'equal-contrib' and ends in a digit.</report>
    
    <report test="xref[matches(@rid,'^equal-contrib[0-9]$')] and not(@equal-contrib='yes')" 
        role="error" 
        id="equal-author-test-2">author contains an xref[@ref-type='fn'] with a 'equal-contrib0' type @rid, but the contrib has no @equal-contrib='yes'.</report>
		
		</rule>
  
</pattern> 	
  
  <pattern id="content-containers">
    
    <rule context="p" id="p-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="text-tokens" value="for $x in tokenize(.,' ') return if (matches($x,'±[Ss][Dd]|±standard|±SEM|±S\.E\.M|±s\.e\.m|\+[Ss][Dd]|\+standard|\+SEM|\+S\.E\.M|\+s\.e\.m')) then $x else ()"/>
      
      <!--<report test="not(matches(.,'^[\p{Lu}\p{N}\p{Ps}\p{S}\p{Pi}\p{Z}]')) and not(parent::list-item) and not(parent::td)"
        role="error" 
        id="p-test-1">p element begins with '<value-of select="substring(.,1,1)"/>'. Is this OK? Usually it should begin with an upper-case letter, or digit, or mathematic symbol, or open parenthesis, or open quote. Or perhaps it should not be the beginning of a new paragraph?</report>-->
      
      <report test="@*" 
        role="error" 
        id="p-test-2">p element must not have any attributes.</report>
      
      <assert test="count($text-tokens) = 0" 
        role="error" 
        id="p-test-3">p element contains <value-of select="string-join($text-tokens,', ')"/> - The spacing is incorrect.</assert>
      
      <report test="((ancestor::article/@article-type = ('article-commentary', 'discussion', 'editorial', 'research-article', 'review-article')) and ancestor::body[parent::article]) and (descendant::*[1]/local-name() = 'bold') and not(ancestor::caption) and not(descendant::*[1]/preceding-sibling::text()) and matches(descendant::bold[1],'\p{L}') and (descendant::bold[1] != 'Related research article')" 
        role="warning" 
        id="p-test-5">p element starts with bolded text - <value-of select="descendant::*[1]"/> - Should it be a header?</report>
      
      <report test="(ancestor::body[parent::article]) and (string-length(.) le 100) and not(parent::*[local-name() = ('list-item','fn','td','th')]) and (preceding-sibling::*[1]/local-name() = 'p') and (string-length(preceding-sibling::p[1]) le 100) and ($article-type != 'correction') and ($article-type != 'retraction') and not((count(*) = 1) and child::supplementary-material)" 
        role="warning" 
        id="p-test-6">Should this be captured as a list-item in a list? p element is less than 100 characters long, and is preceded by another p element less than 100 characters long.</report>
      
      <report test="matches(.,'^\s?•') and not(ancestor::sub-article)" 
        role="warning" 
        id="p-test-7">p element starts with a bullet point. It is very likely that this should instead be captured as a list-item in a list[@list-type='bullet']. - <value-of select="."/></report>
    </rule>
    
    <rule context="p/*" id="p-child-tests">
      <let name="allowed-p-blocks" value="('bold', 'sup', 'sub', 'sc', 'italic', 'underline', 'xref','inline-formula', 'disp-formula','supplementary-material', 'code', 'ext-link', 'named-content', 'inline-graphic', 'monospace', 'related-object', 'table-wrap')"/>
      
      <assert test="if (ancestor::sec[@sec-type='data-availability']) then self::*/local-name() = ($allowed-p-blocks,'element-citation')

else self::*/local-name() = $allowed-p-blocks" 
        role="error" 
        id="allowed-p-test">p element cannot contain <value-of select="self::*/local-name()"/>. only contain the following elements are allowed - bold, sup, sub, sc, italic, xref, inline-formula, disp-formula, supplementary-material, code, ext-link, named-content, inline-graphic, monospace, related-object.</assert>
    </rule>
    
    <rule context="xref" id="xref-target-tests">
      <let name="rid" value="tokenize(@rid,' ')[1]"/>
      <let name="target" value="self::*/ancestor::article//*[@id = $rid]"/>
      
      <report test="(@ref-type='aff') and ($target/local-name() != 'aff')" 
        role="error" 
        id="aff-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='fn') and ($target/local-name() != 'fn')" 
        role="error" 
        id="fn-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='fig') and ($target/local-name() != 'fig')" 
        role="error" 
        id="fig-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='video') and (($target/local-name() != 'media') or not($target/@mimetype='video'))" 
        role="error" 
        id="vid-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' must point to a media[@mimetype="video"] element. Either this links to the incorrect location or the xref/@ref-type is incorrect.</report>
      
      <report test="(@ref-type='bibr') and ($target/local-name() != 'ref')" 
        role="error" 
        id="bibr-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='supplementary-material') and ($target/local-name() != 'supplementary-material')" 
        role="error" 
        id="supplementary-material-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='other') and ($target/local-name() != 'award-group') and ($target/local-name() != 'element-citation')" 
        role="error" 
        id="other-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='table') and ($target/local-name() != 'table-wrap') and ($target/local-name() != 'table')" 
        role="error" 
        id="table-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='table-fn') and ($target/local-name() != 'fn')" 
        role="error" 
        id="table-fn-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='box') and ($target/local-name() != 'boxed-text')" 
        role="error" 
        id="box-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='sec') and ($target/local-name() != 'sec')" 
        role="error" 
        id="sec-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='app') and ($target/local-name() != 'app')" 
        role="error" 
        id="app-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='decision-letter') and ($target/local-name() != 'sub-article')" 
        role="error" 
        id="decision-letter-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <report test="(@ref-type='disp-formula') and ($target/local-name() != 'disp-formula')" 
        role="error" 
        id="disp-formula-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
      
      <assert test="@ref-type = ('aff', 'fn', 'fig', 'video', 'bibr', 'supplementary-material', 'other', 'table', 'table-fn', 'box', 'sec', 'app', 'decision-letter', 'disp-formula')" 
        role="error" 
        id="xref-ref-type-conformance">@ref-type='<value-of select="@ref-type"/>' is not allowed . The only allowed values are 'aff', 'fn', 'fig', 'video', 'bibr', 'supplementary-material', 'other', 'table', 'table-fn', 'box', 'sec', 'app', 'decision-letter', 'disp-formula'.</assert>
      
      <report test="boolean($target) = false()" 
        role="error" 
        id="xref-target-conformance">xref with @ref-type='<value-of select="@ref-type"/>' points to an element with an @id='<value-of select="$rid"/>', but no such element exists.</report>
    </rule>
    
    <rule context="body//xref" id="body-xref-tests">
      
      <report test="not(child::*) and normalize-space(.)=''" 
        role="error" 
        id="empty-xref-test">Empty xref in the body is not allowed. Its position here in the text - "<value-of select="concat(preceding-sibling::text()[1],'*Empty xref*',following-sibling::text()[1])"/>".</report>
      
      <report test="ends-with(.,';') or ends-with(.,'; ')" 
        role="warning" 
        id="semi-colon-xref-test">xref ends with semi-colon - '<value-of select="."/>' - which is almost definitely incorrect. The semi-colon should very likely be placed after the link as 'normal' text.</report>
      
    </rule>
    
    <rule context="ext-link[@ext-link-type='uri']" id="ext-link-tests">
      <let name="formatting-elems" value="('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')"/>
      <let name="parent" value="parent::*[1]/local-name()"/>
      <let name="form-children" value="string-join(
        for $x in child::* return if ($x/local-name()=$formatting-elems) then $x/local-name()
        else ()
        ,', ')"/>
      <let name="non-form-children" value="string-join(
        for $x in child::* return if ($x/local-name()=$formatting-elems) then ()
        else ($x/local-name())
        ,', ')"/>
      
      <!-- Not entirely sure if this works 
           Removed for now as it seems not to work
      <assert test="@xlink:href castable as xs:anyURI" 
        role="error"
        id="broken-uri-test">Broken URI in @xlink:href</assert>-->
      
      <!-- Needs further testing. Presume that we want to ensure a url follows certain URI schemes. -->
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.')" 
        role="warning" 
        id="url-conformance-test">@xlink:href doesn't look like a URL - '<value-of select="@xlink:href"/>'. Is this correct?</assert>
      
      <report test="matches(@xlink:href,'^(ftp|sftp)://\S+:\S+@')" 
        role="warning" 
        id="ftp-credentials-flag">@xlink:href contains what looks like a link to an FTP site which contains credentials (username and password) - '<value-of select="@xlink:href"/>'. If the link without credentials works (<value-of select="concat(substring-before(@xlink:href,'://'),'://',substring-after(@xlink:href,'@'))"/>), then please replace it with that and notify the authors that you have done so. If the link without credentials does not work, please query with the authors in order to obtain a link without credentials.</report>
      
      <report test="matches(@xlink:href,'\.$')" 
        role="error" 
        id="url-fullstop-report">'<value-of select="@xlink:href"/>' - Link ends in a full stop which is incorrect.</report>
      
      <report test="(matches(.,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%,_\+.~#?&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.') and $parent = $formatting-elems)" 
        role="warning" 
        id="ext-link-parent-test">ext-link - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which almost certainly unnecessary.</report>
      
      <report test="(matches(.,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%,_\+.~#?&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.') and ($form-children!=''))" 
        role="error" 
        id="ext-link-child-test">ext-link - <value-of select="."/> - has a formatting child element - <value-of select="$form-children"/> - which is not correct.</report>
      
      <assert test="$non-form-children=''" 
        role="error" 
        id="ext-link-child-test-2">ext-link - <value-of select="."/> - has a non-formatting child element - <value-of select="$non-form-children"/> - which is not correct.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/toolkit/archiving-code#ext-link-child-test-3" 
        test="contains(.,'copy archived')" 
        role="error" 
        id="ext-link-child-test-3">ext-link - <value-of select="."/> - contains the phrase 'copy archived', which is incorrect.</report>
      
      <report test="matches(.,'^[Dd][Oo][Ii]:|^[Dd][Oo][Ii]\s')" 
        role="warning" 
        id="ext-link-child-test-4">ext-link text - <value-of select="."/> - appears to start with the string 'Doi:' or 'Doi ' (or similar), which is unnecessary.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#ext-link-child-test-5" 
        test="contains(@xlink:href,'datadryad.org/review?')" 
        role="warning" 
        id="ext-link-child-test-5">ext-link looks like it points to a review dryad dataset - <value-of select="."/>. Should it be updated?</report>
      
      <report test="(.!=@xlink:href) and matches(.,'https?:|ftp:|www\.')" 
        role="warning" 
        id="ext-link-text">The text for a URL is '<value-of select="."/>' (which looks like a URL), but it is not the same as the actual embedded link, which is '<value-of select="@xlink:href"/>'.</report>
    </rule>
    
    <rule context="ext-link[contains(@xlink:href,'softwareheritage')]" 
      id="software-heritage-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/toolkit/archiving-code#software-heritage-test-1" 
        test="ancestor::sec[@sec-type='data-availability'] and not(matches(@xlink:href,'^https://archive.softwareheritage.org/swh:.:rev:[\da-z]*/?$'))" 
        role="error" 
        id="software-heritage-test-1">Software heritage links in the data availability statement must be the revision link without contextual information. '<value-of select="."/>' is not a revision link without contextual information.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/toolkit/archiving-code#software-heritage-test-2" 
        test="ancestor::body and not(matches(@xlink:href,'.*swh:.:dir.*origin=.*visit=.*anchor=.*'))" 
        role="error" 
        id="software-heritage-test-2">Software heritage links in the main text must be the directory link with contextual information. '<value-of select="@xlink:href"/>' is not a directory link with contextual information.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/toolkit/archiving-code#software-heritage-test-3" 
        test="ancestor::body and matches(@xlink:href,'.*swh:.:dir.*origin=.*visit=.*anchor=.*') and (. != replace(substring-after(@xlink:href,'anchor='),'/$',''))" 
        role="error" 
        id="software-heritage-test-3">The text for Software heritage links in the main text must be the revision SWHID without contextual information. '<value-of select="."/>' is not. Based on the link itself, the text that is embedded should be '<value-of select="replace(substring-after(@xlink:href,'anchor='),'/$','')"/>'.</report>
      
    </rule>
    
    <rule context="ext-link[@ext-link-type='uri' and not(ancestor::sec[@sec-type='data-availability']) and not(parent::element-citation) and not(ancestor::table-wrap) and string-length(.) gt 59]" 
      id="ext-link-tests-2">
      
      <report test=". = @xlink:href" 
        role="info" 
        id="ext-link-length">Consider embedding long URLs in text instead of displaying in full, where appropriate. This is a very long URL - <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="fig-group" id="fig-group-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-group-test-1" 
        test="count(child::fig[not(@specific-use='child-fig')]) = 1" 
        role="error" 
        id="fig-group-test-1">fig-group must have one and only one main figure.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-group-test-2" 
        test="not(child::fig[@specific-use='child-fig']) and not(descendant::media[@mimetype='video'])" 
        role="error" 
        id="fig-group-test-2">fig-group does not contain a figure supplement or a figure-level video, which must be incorrect.</report>
      
    </rule>
    
    <rule context="fig-group/*" id="fig-group-child-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-group-child-test-1" 
        test="local-name() = ('fig','media')" 
        role="error" 
        id="fig-group-child-test-1"><name/> is not allowed as a child of fig-group.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-group-child-test-2" 
        test="(local-name() = 'media') and not(@mimetype='video')" 
        role="error" 
        id="fig-group-child-test-2"><name/> which is a child of fig-group, must have an @mimetype='video' - i.e. only video type media is allowed as a child of fig-group.</report>
      
    </rule>
    
    <rule context="fig[not(ancestor::sub-article)]" id="fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-test-2" 
        test="@position" 
        role="error" 
        id="fig-test-2">fig must have a @position.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-test-3" 
        test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(label)" 
        role="error" 
        id="fig-test-3">fig must have a label.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#feat-fig-test-3" 
        test="($article-type = $features-article-types) and not(label)" 
        role="warning" 
        id="feat-fig-test-3">fig doesn't have a label. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-fig-test-4" 
        test="if ($article-type = ('correction','retraction')) then ()
        else not(caption)" 
        role="warning" 
        id="pre-fig-test-4"><value-of select="label"/> has no title or caption (caption element). Ensure this is queried with the author.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#final-fig-test-4" 
        test="if ($article-type = ('correction','retraction')) then ()
        else not(caption)" 
        role="error" 
        id="final-fig-test-4"><value-of select="label"/> has no title or caption (caption element).</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-fig-test-5" 
        test="if ($article-type = ('correction','retraction')) then ()
        else not(caption/title)" 
        role="warning" 
        id="pre-fig-test-5"><value-of select="label"/> does not have a title.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#final-fig-test-5" 
        test="if ($article-type = ('correction','retraction')) then ()
        else not(caption/title)" 
        role="error" 
        id="final-fig-test-5">fig caption must have a title.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-test-6" 
        test="if ($article-type = ('correction','retraction')) then ()
        else (matches(@id,'^fig[0-9]{1,3}$') and not(caption/p))" 
        role="warning" 
        id="fig-test-6">Figure does not have a legend, which is very unorthodox. Is this correct?</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-fig-test-7" 
        test="graphic" 
        role="warning" 
        id="pre-fig-test-7">fig does not have graphic. Ensure author query is added asking for file.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#final-fig-test-7" 
        test="graphic" 
        role="error" 
        id="final-fig-test-7">fig must have a graphic.</assert>
    </rule>
    
    <rule context="fig[ancestor::sub-article[@article-type='reply']]" id="ar-fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(ancestor::body//fig)"/>
      <let name="pos" value="$count - count(following::fig)"/>
      <let name="no" value="substring-after(@id,'fig')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#ar-fig-test-2" 
        test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(label)" 
        role="error" 
        flag="dl-ar"
        id="ar-fig-test-2">Author Response fig must have a label.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-ar-fig-test-3" 
        test="graphic" 
        role="warning" 
        flag="dl-ar"
        id="pre-ar-fig-test-3">Author Response fig does not have graphic. Ensure author query is added asking for file.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#final-ar-fig-test-3" 
        test="graphic" 
        role="error" 
        id="final-ar-fig-test-3">Author Response fig must have a graphic.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-ar-fig-position-test" 
        test="$no = string($pos)" 
        role="warning" 
        flag="dl-ar"
        id="pre-ar-fig-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR images it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#final-ar-fig-position-test" 
        test="$no = string($pos)" 
        role="error" 
        id="final-ar-fig-position-test"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR images it is placed in position <value-of select="$pos"/>.</assert>
    </rule>
    
    <rule context="graphic|inline-graphic" id="graphic-tests">
      <let name="link" value="@xlink:href"/>
      <let name="file" value="lower-case($link)"/>
      
      <report test="contains(@mime-subtype,'tiff') and not(matches($file,'\.tif$|\.tiff$'))" 
        role="error" 
        id="graphic-test-1"><name/> has tif mime-subtype but filename does not end with '.tif' or '.tiff'. This cannot be correct.</report>
      
      <report test="contains(@mime-subtype,'postscript') and not(ends-with($file,'.eps'))" 
        role="error" 
        id="graphic-test-2"><name/> has postscript mime-subtype but filename does not end with '.eps'. This cannot be correct.</report>
      
      <report test="contains(@mime-subtype,'jpeg') and not(matches($file,'\.jpg$|\.jpeg$'))" 
        role="error" 
        id="graphic-test-3"><name/> has jpeg mime-subtype but filename does not end with '.jpg' or '.jpeg'. This cannot be correct.</report>
      
      <!-- Should this just be image? application included because during proofing stages non-web image files are referenced, e.g postscript -->
      <assert test="@mimetype=('image','application')" 
        role="error" 
        id="graphic-test-4"><name/> must have a @mimetype='image'.</assert>
      
      <assert test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,6}$')" 
        role="error" 
        id="graphic-test-5"><name/> must have an @xlink:href which contains a file reference.</assert>
      
      <report test="preceding::graphic/@xlink:href = $link" 
        role="error" 
        id="graphic-test-6">Image file for <value-of select="if (name()='inline-graphic') then 'inline-graphic' else replace(parent::fig/label,'\.','')"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="replace(preceding::graphic[@xlink:href=$link][1]/parent::fig/label,'\.','')"/>.</report>
      
      <report test="contains($link,'&amp;')" 
        role="error" 
        id="graphic-test-8">Image file-name for <value-of select="if (name()='inline-graphic') then 'inline-graphic' else replace(parent::fig/label,'\.','')"/> contains an ampersand - <value-of select="tokenize($link,'/')[last()]"/>. Please rename the file so that this ampersand is removed.</report>
    </rule>
    
    <rule context="media" id="media-tests">
      <let name="file" value="@mime-subtype"/>
      <let name="link" value="@xlink:href"/>
      
      <assert test="@mimetype=('video','application','text','image', 'audio','chemical')" 
        role="error" 
        id="media-test-1">media must have @mimetype, the value of which has to be one of 'video','application','text','image', or 'audio', 'chemical'.</assert>
      
      <assert test="@mime-subtype" 
        role="error" 
        id="media-test-2">media must have @mime-subtype.</assert>
      
      <assert test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,15}$')" 
        role="error" 
        id="media-test-3">media must have an @xlink:href which contains a file reference.</assert>
      
      <report test="if ($file='octet-stream') then ()
        else if ($file = 'msword') then not(matches(@xlink:href,'\.doc[x]?$'))
        else if ($file = 'excel') then not(matches(@xlink:href,'\.xl[s|t|m][x|m|b]?$'))
        else if ($file='x-m') then not(ends-with(@xlink:href,'.m'))
        else if ($file='tab-separated-values') then not(ends-with(@xlink:href,'.tsv'))
        else if ($file='jpeg') then not(matches(@xlink:href,'\.[Jj][Pp][Gg]$'))
        else if ($file='postscript') then not(matches(@xlink:href,'\.[Aa][Ii]$|\.[Pp][Ss]$'))
        else if ($file='x-tex') then not(ends-with(@xlink:href,'.tex'))
        else if ($file='x-gzip') then not(ends-with(@xlink:href,'.gz'))
        else if ($file='html') then not(ends-with(@xlink:href,'.html'))
        else if ($file='x-wav') then not(ends-with(@xlink:href,'.wav'))
        else if ($file='x-aiff') then not(ends-with(@xlink:href,'.aiff'))
        else if ($file='x-macbinary') then not(ends-with(@xlink:href,'.bin'))
        else if ($file='x-pdb') then not(ends-with(@xlink:href,'.pdb'))
        else if ($file='fasta') then not(ends-with(@xlink:href,'.fasta'))
        else if (@mimetype='text') then not(matches(@xlink:href,'\.txt$|\.py$|\.xml$|\.sh$|\.rtf$|\.c$|\.for$|\.pl$'))
        else not(ends-with(@xlink:href,concat('.',$file)))" 
        role="warning" 
        id="media-test-4">media must have a file reference in @xlink:href which is equivalent to its @mime-subtype.</report>      
      
      <report test="matches(label[1],'[Aa]nimation') and not(@mime-subtype='gif')" 
        role="error" 
        id="media-test-5"><value-of select="label"/> media with animation type label must have a @mime-subtype='gif'.</report>    
      
      <report test="matches(@xlink:href,'\.doc[x]?$|\.pdf$|\.xlsx$|\.xml$|\.xlsx$|\.mp4$|\.gif$')  and (@mime-subtype='octet-stream')" 
        role="warning" 
        id="media-test-6">media has @mime-subtype='octet-stream', but the file reference ends with a recognised mime-type. Is this correct?</report>      
      
      <report test="if (child::label) then not(matches(label[1],'^Video \d{1,4}\.$|^Figure \d{1,4}—video \d{1,4}\.$|^Figure \d{1,4}—animation \d{1,4}\.$|^Table \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—figure \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—figure \d{1,4}—animation \d{1,4}\.$|^Animation \d{1,4}\.$|^Author response video \d{1,4}\.$'))
        else ()" 
        role="error" 
        id="media-test-7">media label does not conform to eLife's usual label format - <value-of select="label[1]"/>.</report>
      
      <report test="if (ancestor::sec[@sec-type='supplementary-material']) then ()
        else if (@mimetype='video') then (not(label))
        else ()" 
        role="error" 
        id="media-test-8">video does not contain a label, which is incorrect.</report>
      
      <report test="matches(lower-case(@xlink:href),'\.xml$|\.html$|\.json$')" 
        role="error" 
        id="media-test-9">media points to an xml, html or json file. This cannot be handled by Kriya currently. Please download the file, place it in a zip and replace the file with this zip (otherwise the file will be erroneously overwritten before publication).</report>
      
      <report test="preceding::media/@xlink:href = $link" 
        role="error" 
        id="media-test-10">Media file for <value-of select="if (@mimetype='video') then replace(label,'\.','') else replace(parent::*/label,'\.','')"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="if (preceding::media[@xlink:href=$link][1]/@mimetype='video') then replace(preceding::media[@xlink:href=$link][1]/label,'\.','')
        else replace(preceding::media[@xlink:href=$link][1]/parent::*/label,'\.','')"/>.</report>
      
      <report test="contains($link,'&amp;')" 
        role="error" 
        id="media-test-11">Media filename for <value-of select="if (@mimetype='video') then replace(label,'\.','') else replace(parent::*/label,'\.','')"/> contains an ampersand - <value-of select="tokenize($link,'/')[last()]"/>. Please rename the file so that this ampersand is removed.</report>
    </rule>
    
    <rule context="media[child::label]" id="video-test">
      
      <assert test="caption/title" 
        role="warning" 
        id="pre-video-title"><value-of select="replace(label,'\.$,','')"/> does not have a title. Please query the authors for one.</assert>
      
      <assert test="caption/title" 
        role="error" 
        id="final-video-title"><value-of select="replace(label,'\.$,','')"/> does not have a title, which is incorrect.</assert>
      
    </rule>
    
    <rule context="supplementary-material" id="supplementary-material-tests">
      <let name="link" value="media[1]/@xlink:href"/>
      <let name="file" value="if (contains($link,'.')) then lower-case(tokenize($link,'\.')[last()]) else ()"/>
      <let name="code-files" value="('m','py','lib','jl','c','sh','for','cpproj','ipynb','mph','cc','rmd','nlogo','stan','wrl','pl','r','fas','ijm','llb','ipf','mdl','h')"/>
      
      <assert test="label" 
        role="error" 
        id="supplementary-material-test-1">supplementary-material must have a label.</assert>
      
      <report test="if (contains(label,'Transparent reporting form')) then ()
        else not(caption)" 
        role="warning" 
        id="supplementary-material-test-2"><value-of select="label"/> is missing a title/caption - is this correct?  (supplementary-material should have a child caption.)</report>
      
      <report test="if (caption) then not(caption/title)
        else ()" 
        role="warning" 
        id="pre-supplementary-material-test-3"><value-of select="label"/> does not have a title.</report>
      
      <report test="if (caption) then not(caption/title)
        else ()" 
        role="warning" 
        id="final-supplementary-material-test-3"><value-of select="label"/> doesn't have a title. Is this correct?</report>
      
      <assert test="media" 
        role="warning" 
        id="pre-supplementary-material-test-5"><value-of select="label"/> is missing a file (supplementary-material missing a media element) - please ensure that this is queried with the author.</assert>		
      
      <assert test="media" 
        role="error" 
        id="final-supplementary-material-test-5"><value-of select="label"/> is missing a file (supplementary-material must have a media).</assert>
      
      <assert test="matches(label[1],'^Transparent reporting form$|^Figure \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source data \d{1,4}\.$|^Table \d{1,4}—source data \d{1,4}\.$|^Video \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—source code \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source code \d{1,4}\.$|^Table \d{1,4}—source code \d{1,4}\.$|^Video \d{1,4}—source code \d{1,4}\.$|^Supplementary file \d{1,4}\.$|^Source data \d{1,4}\.$|^Source code \d{1,4}\.$|^Reporting standard \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—figure supplement \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—table \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—video \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—figure supplement \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—table \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—video \d{1,4}—source code \d{1,4}\.$|^Audio file \d{1,4}\.$')" 
        role="error" 
        id="supplementary-material-test-6">supplementary-material label (<value-of select="label"/>) does not conform to eLife's usual label format.</assert>
      
      <report test="(ancestor::sec[@sec-type='supplementary-material']) and (media[@mimetype='video'])" 
        role="error" 
        id="supplementary-material-test-7">supplementary-material in additional files sections cannot have the a media element with the attribute mimetype='video'. This should be mimetype='application'</report>
      
      <report test="matches(label[1],'^Transparent reporting form$|^Supplementary file \d{1,4}\.$|^Source data \d{1,4}\.$|^Source code \d{1,4}\.$|^Reporting standard \d{1,4}\.$') and not(ancestor::sec[@sec-type='supplementary-material'])" 
        role="error" 
        id="supplementary-material-test-8"><value-of select="label"/> has an article level label but it is not captured in the additional files section - This must be incorrect.</report>
      
      <report test="count(media) gt 1" 
        role="error" 
        id="supplementary-material-test-9"><value-of select="label"/> has <value-of select="count(media)"/> media elements which is incorrect.</report>
      
      <report test="matches(label[1],'^Reporting standard \d{1,4}\.$')" 
        role="warning" 
        id="supplementary-material-test-10">Article contains <value-of select="label"/> Please check with eLife - is this actually a reporting standard?</report>
      
      <report test="($file = $code-files) and not(matches(label[1],'[Ss]ource code \d{1,4}\.$'))" 
        role="warning" 
        id="source-code-test-1"><value-of select="label"/> has a file which looks like code - <value-of select="$link"/>, but it's not labelled as code.</report>
      
      <report test="contains(lower-case(caption[1]/title[1]),'key resource')" 
        role="warning" 
        id="supplementary-material-test-11"><value-of select="if (self::*/label) then replace(label,'\.$','') else self::*/local-name()"/> has a title '<value-of select="caption[1]/title[1]"/>'. Is it a Key resources table? If so, it should be captured as a table in an appendix for the article.</report>
      
      <report test="contains(label[1],'ource code') and not(($file=('tar','gz','zip','tgz','rar')))" 
        role="warning" 
        id="source-code-test-2">Source code files should always be zipped. The file type for <value-of select="if (self::*/label) then replace(label,'\.$','') else self::*/local-name()"/> is '<value-of select="$file"/>'. Please zip this file, and replace it with the zipped version.</report>
    </rule>
    
    <rule context="sec[@sec-type='supplementary-material']/supplementary-material[contains(label[1],'upplementary file')]" 
      id="back-supplementary-file-tests">
      <let name="pos" value="count(parent::*/supplementary-material[contains(label[1],'upplementary file')]) - count(following::supplementary-material[contains(label[1],'upplementary file')])"/>
      <let name="no" value="substring-after(@id,'supp')"/>
      
      <assert test="string($pos) = $no" 
        role="error" 
        id="back-supplementary-file-position"><value-of select="replace(label,'\.$','')"/> id ends with <value-of select="$no"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is mislabelled, the id is incorrect, or it should be moved to a different position.</assert>
      
      <assert test="matches(@id,'^supp\d{1,2}$')" 
        role="error" 
        id="back-supplementary-file-id">The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. Supplementary files need to have ids in the format 'supp0'.</assert>
      
    </rule>
    
    <rule context="sec[@sec-type='supplementary-material']/supplementary-material[contains(label[1],'ource data')]" 
      id="back-source-data-tests">
      <let name="pos" value="count(parent::*/supplementary-material[contains(label[1],'ource data')]) - count(following::supplementary-material[contains(label[1],'ource data')])"/>
      <let name="no" value="substring-after(@id,'sdata')"/>
      
      <assert test="string($pos) = $no" 
        role="error" 
        id="back-source-data-position"><value-of select="replace(label,'\.$','')"/> id ends with <value-of select="$no"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is mislabelled, the id is incorrect, or it should be moved to a different position.</assert>
      
      <assert test="matches(@id,'^sdata\d{1,2}$')" 
        role="error" 
        id="back-source-data-id">The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. Source data need to have ids in the format 'sdata0'.</assert>
      
    </rule>
    
    <rule context="sec[@sec-type='supplementary-material']/supplementary-material[contains(label[1],'ource code')]" 
      id="back-source-code-tests">
      <let name="pos" value="count(parent::*/supplementary-material[contains(label[1],'ource code')]) - count(following::supplementary-material[contains(label[1],'ource code')])"/>
      <let name="no" value="substring-after(@id,'scode')"/>
      
      <assert test="string($pos) = $no" 
        role="error" 
        id="back-source-code-position"><value-of select="replace(label,'\.$','')"/> id ends with <value-of select="$no"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is mislabelled, the id is incorrect, or it should be moved to a different position.</assert>
      
      <assert test="matches(@id,'^scode\d{1,2}$')" 
        role="error" 
        id="back-source-code-id">The id (<value-of select="@id"/>) for <value-of select="replace(label,'\.$','')"/> is not in the correct format. Source code needs to have ids in the format 'scode0'.</assert>
      
    </rule>
    
    <rule context="supplementary-material[(ancestor::fig) or (ancestor::media) or (ancestor::table-wrap)]" id="source-data-specific-tests">
      
      <report test="matches(label[1],'^Figure \d{1,4}—source data \d{1,4}|^Appendix \d{1,4}—figure \d{1,4}—source data \d{1,4}') and (count(descendant::xref[@ref-type='fig'])=1) and (descendant::xref[(@ref-type='fig') and contains(.,'upplement')])" 
        role="warning" 
        id="fig-data-test-1"><value-of select="label"/> is figure level source data, but contains 1 figure citation which is a link to a figure supplement - should it be figure supplement level source data?</report>
      
      <report test="matches(label[1],'^Figure \d{1,4}—source code \d{1,4}|^Appendix \d{1,4}—figure \d{1,4}—source code \d{1,4}') and (count(descendant::xref[@ref-type='fig'])=1) and (descendant::xref[(@ref-type='fig') and contains(.,'upplement')])" 
        role="warning" 
        id="fig-code-test-1"><value-of select="label"/> is figure level source code, but contains 1 figure citation which is a link to a figure supplement - should it be figure supplement level source code?</report>
      
    </rule>
    
    <rule context="fig//supplementary-material[not(ancestor::media) and contains(label[1],' data ')]" id="fig-source-data-tests">
      <let name="label" value="label[1]"/>
      <let name="fig-id" value="ancestor::fig[1]/@id"/>
      <let name="number" value="number(replace(substring-after($label,' data '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::fig[1]//supplementary-material[contains(label[1],' data ')])"/>
      <let name="pos" value="$sibling-count - count(following::supplementary-material[(ancestor::fig[1]/@id=$fig-id) and contains(label[1],' data ')])"/>
      
      <assert test="$number = $pos" 
        role="error" 
        id="fig-data-test-2">'<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert test="@id=concat($fig-id,'sdata',$pos)" 
        role="error" 
        id="fig-data-id">The id for figure level source data must be the id of its ancestor fig, followed by 'sdata', followed by its position relative to other source data for the same figure. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($fig-id,'sdata',$pos)"/>' instead.</assert>
      
    </rule>
    
    <rule context="fig//supplementary-material[not(ancestor::media) and contains(label[1],' code ')]" id="fig-source-code-tests">
      <let name="label" value="label[1]"/>
      <let name="fig-id" value="ancestor::fig[1]/@id"/>
      <let name="number" value="number(replace(substring-after($label,' code '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::fig[1]//supplementary-material[contains(label[1],' code ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::fig[1]/@id=$fig-id) and contains(label[1],' code ')])"/>
      
      <assert test="$number = $pos" 
        role="error" 
        id="fig-code-test-2">'<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert test="@id=concat($fig-id,'scode',$pos)" 
        role="error" 
        id="fig-code-id">The id for figure level source code must be the id of its ancestor fig, followed by 'scode', followed by its position relative to other source data for the same figure. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($fig-id,'scode',$pos)"/>' instead.</assert>
      
    </rule>
    
    <rule context="media//supplementary-material[not(ancestor::fig) and contains(label[1],' data ')]" id="vid-source-data-tests">
      <let name="label" value="label[1]"/>
      <let name="vid-id" value="ancestor::media[1]/@id"/>
      <let name="number" value="number(replace(substring-after($label,' data '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::media[1]//supplementary-material[contains(label[1],' data ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::media[1]/@id=$vid-id) and contains(label[1],' data ')])"/>
      
      <assert test="$number = $pos" 
        role="error" 
        id="vid-data-test-2">'<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert test="@id=concat($vid-id,'sdata',$pos)" 
        role="error" 
        id="vid-data-id">The id for video level source data must be the id of its ancestor video, followed by 'sdata', followed by its position relative to other source data for the same video. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($vid-id,'sdata',$pos)"/>' instead.</assert>
      
    </rule>
    
    <rule context="media//supplementary-material[not(ancestor::fig) and contains(label[1],' code ')]" id="vid-source-code-tests">
      <let name="label" value="label[1]"/>
      <let name="vid-id" value="ancestor::media[1]/@id"/>
      <let name="number" value="number(replace(substring-after($label,' code '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::media[1]//supplementary-material[contains(label[1],' code ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::media[1]/@id=$vid-id) and contains(label[1],' code ')])"/>
      
      <assert test="$number = $pos" 
        role="error" 
        id="vid-code-test-2">'<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert test="@id=concat($vid-id,'scode',$pos)" 
        role="error" 
        id="vid-code-id">The id for video level source code must be the id of its ancestor video, followed by 'scode', followed by its position relative to other source data for the same video. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($vid-id,'scode',$pos)"/>' instead.</assert>
      
    </rule>
    
    <rule context="table-wrap//supplementary-material[contains(label[1],' data ')]" id="table-source-data-tests">
      <let name="label" value="label[1]"/>
      <let name="table-id" value="ancestor::table-wrap[1]/@id"/>
      <let name="number" value="number(replace(substring-after($label,' data '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::table-wrap[1]//supplementary-material[contains(label[1],' data ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::table-wrap[1]/@id=$table-id) and contains(label[1],' data ')])"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-data-test-2" 
        test="$number = $pos" 
        role="error" 
        id="table-data-test-2">'<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert test="@id=concat($table-id,'sdata',$pos)" 
        role="error" 
        id="table-data-id">The id for table level source data must be the id of its ancestor table-wrap, followed by 'sdata', followed by its position relative to other source data for the same table. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($table-id,'sdata',$pos)"/>' instead.</assert>
      
    </rule>
    
    <rule context="table-wrap//supplementary-material[contains(label[1],' code ')]" id="table-source-code-tests">
      <let name="label" value="label[1]"/>
      <let name="table-id" value="ancestor::table-wrap[1]/@id"/>
      <let name="number" value="number(replace(substring-after($label,' code '),'[^\d]',''))"/>
      <let name="sibling-count" value="count(ancestor::table-wrap[1]//supplementary-material[contains(label[1],' code ')])"/>
      <let name="pos" value="$sibling-count - count( following::supplementary-material[(ancestor::table-wrap[1]/@id=$table-id) and contains(label[1],' code ')])"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-code-test-2" 
        test="$number = $pos" 
        role="error" 
        id="table-code-test-2">'<value-of select="$label"/>' ends with <value-of select="$number"/>, but it is placed <value-of select="e:get-ordinal($pos)"/>. Either it is misnumbered or it should be moved to a different position.</assert>
      
      <assert test="@id=concat($table-id,'scode',$pos)" 
        role="error" 
        id="table-code-id">The id for table level source code must be the id of its ancestor table, followed by 'scode', followed by its position relative to other source data for the same table. The id for <value-of select="$label"/>, '<value-of select="@id"/>' is not in this format. It should be '<value-of select="concat($table-id,'scode',$pos)"/>' instead.</assert>
      
    </rule>
    
    <rule context="disp-formula" id="disp-formula-tests">
      
      <assert test="mml:math" 
        role="error" 
        id="disp-formula-test-2">disp-formula must contain an mml:math element.</assert>
      
      <assert test="parent::p" 
        role="warning" 
        id="disp-formula-test-3">In the vast majority of cases disp-formula should be a child of p. <value-of select="label"/> is a child of <value-of select="parent::*/local-name()"/>. Is that correct?</assert>
      
      <report test="parent::p and not(preceding-sibling::*) and (not(preceding-sibling::text()) or normalize-space(preceding-sibling::text()[1])='')"
        role="error" 
        id="disp-formula-test-4">disp-formula cannot be placed as the first child of a p element with no content before it (ie. &lt;p>&lt;disp-formula ...). Either capture it at the end of the previous paragraph or capture it as a child of <value-of select="parent::p/parent::*/local-name()"/></report>
    </rule>
    
    <rule context="inline-formula" id="inline-formula-tests">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <assert test="mml:math" 
        role="error" 
        id="inline-formula-test-1">inline-formula must contain an mml:math element.</assert>
      
      <report test="matches($pre-text,'[\p{L}\p{N}\p{M}]$')" 
        role="warning" 
        id="inline-formula-test-2">There is no space between inline-formula and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report test="matches($post-text,'^[\p{L}\p{N}\p{M}]')" 
        role="warning" 
        id="inline-formula-test-3">There is no space between inline-formula and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <assert test="parent::p or parent::td or parent::th or parent::title" 
        role="error" 
        id="inline-formula-test-4"><name/> must be a child of p, td,  th or title. The formula containing <value-of select="."/> is a child of <value-of select="parent::*/local-name()"/></assert>
    </rule>
    
    <rule context="mml:math" id="math-tests">
      <let name="data" value="replace(normalize-space(.),'\s','')"/>
      <let name="children" value="string-join(for $x in .//*[(local-name()!='mo') and (local-name()!='mn') and (normalize-space(.)!='')] return $x/local-name(),'')"/>
      
      <report test="$data = ''" 
        role="error" 
        id="math-test-1">mml:math must not be empty.</report>
      
      <report test="descendant::mml:merror" 
        role="error" 
        id="math-test-2">math contains an mml:merror with '<value-of select="descendant::mml:merror[1]/*"/>'. This will almost certainly not render correctly.</report>
      
      <report test="not(matches($data,'^±$|^±[\d]+$|^±[\d]+\.[\d]+$|^×$|^~$|^~[\d]+$|^~[\d]+\.[\d]+$|^%[\d]+$|^%[\d]+\.[\d]+$|^%$|^±\d+%$|^+\d+%$|^-\d+%$|^\d+%$|^±\d+$|^+\d+$|^-\d+$')) and ($children='')" 
        role="warning" 
        id="math-test-14">mml:math only contains numbers and/or operators - '<value-of select="$data"/>'. Is it necessary for this to be set as a formula, or can it be captured with as normal text instead?</report>
      
      <report test="$data = '±'" 
        role="error" 
        id="math-test-3">mml:math only contains '±', which is unnecessary. Capture this as a normal text '±' instead.</report>
      
      <report test="matches($data,'^±[\d]+$|^±[\d]+\.[\d]+$')" 
        role="error" 
        id="math-test-4">mml:math only contains '±' followed by digits, which is unnecessary. Capture this as a normal text instead.</report>
      
      <report test="$data = '×'" 
        role="error" 
        id="math-test-5">mml:math only contains '×', which is unnecessary. Capture this as a normal text '×' instead.</report>
      
      <report test="$data = '~'" 
        role="error" 
        id="math-test-6">mml:math only contains '~', which is unnecessary. Capture this as a normal text '~' instead.</report>
      
      <report test="matches($data,'^~[\d]+$|^~[\d]+\.[\d]+$')" 
        role="error" 
        id="math-test-7">mml:math only contains '~' and digits, which is unnecessary. Capture this as a normal text instead.</report>
      
      <report test="$data = 'μ'" 
        role="warning" 
        id="math-test-8">mml:math only contains 'μ', which is likely unnecessary. Should this be captured as a normal text 'μ' instead?</report>
      
      <report test="matches($data,'^[\d]+%$|^[\d]+\.[\d]+%$|^%$')" 
        role="error" 
        id="math-test-9">mml:math only contains '%' and digits, which is unnecessary. Capture this as a normal text instead.</report>
      
      <report test="matches($data,'^%$')" 
        role="error" 
        id="math-test-12">mml:math only contains '%', which is unnecessary. Capture this as a normal text instead.</report>
      
      <report test="$data = '°'" 
        role="error" 
        id="math-test-10">mml:math only contains '°', which is likely unnecessary. This should be captured as a normal text '°' instead.</report>
      
      <report test="contains($data,'○')" 
        role="warning" 
        id="math-test-11">mml:math contains '○' (the white circle symbol). Should this be the degree symbol instead - '°', or '∘' (the ring operator symbol)?</report>
      
      <report test="not(descendant::mml:msqrt) and not(descendant::mml:mroot) and not(descendant::mml:mfrac) and matches($data,'^±\d+%$|^+\d+%$|^-\d+%$|^\d+%$|^±\d+$|^+\d+$|^-\d+$')" 
        role="warning" 
        id="math-test-13">mml:math only contains '<value-of select="."/>', which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report test="matches($data,'^Na[2]?\+$|^Ca2\+$|^K\+$|^Cu[2]?\+$|^Ag\+$|^Hg[2]?\+$|^H\+$|^Mg2\+$|^Ba2\+$|^Pb2\+$|^Fe2\+$|^Co2\+$|^Ni2\+$|^Mn2\+$|^Zn2\+$|^Al3\+$|^Fe3\+$|^Cr3\+$')" 
        role="warning" 
        id="math-test-15">mml:math seems to only contain the formula for a cation - '<value-of select="."/>' - which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report test="matches($data,'^H\-$|^Cl\-$|^Br\-$|^I\-$|^OH\-$|^NO3\-$|^NO2\-$|^HCO3\-$|^HSO4\-$|^CN\-$|^MnO4\-$|^ClO[3]?\-$|^O2\-$|^S2\-$|^SO42\-$|^SO32\-$|^S2O32\-$|^SiO32\-$|^CO32\-$|^CrO42\-$|^Cr2O72\-$|^N3\-$|^P3\-$|^PO43\-$')" 
        role="warning" 
        id="math-test-16">mml:math seems to only contain the formula for an anion - '<value-of select="."/>' - which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report test="child::mml:msqrt and matches($data,'^±\d+%$|^+\d+%$|^-\d+%$|^\d+%$|^±\d+$|^+\d+$|^-\d+$')" 
        role="warning" 
        id="math-test-17">mml:math only contains number(s) and square root symbol(s) '<value-of select="."/>', which is likely unnecessary. Should this be captured as normal text instead? Such as <value-of select="concat('√',.)"/>?</report>
      
      <report test="ancestor::abstract" 
        role="warning" 
        id="math-test-18">abstract contains MathML (<value-of select="."/>). Is this necessary? MathML in abstracts may not render downstream, so if it can be represented using normal text/unicode, then please do so instead.</report>
      
      <report test="descendant::mml:mi[(.='') and preceding-sibling::*[1][(local-name() = 'mi') and matches(.,'[A-Za-z]')] and following-sibling::*[1][(local-name() = 'mi') and matches(.,'[A-Za-z]')]]" 
        role="warning" 
        id="math-test-19">Maths containing '<value-of select="."/>' has what looks like words or terms which need separating with a space. With it's current markup the space will not be preserved on the eLife website. Please add in the space(s) using the latext '\;' in the appropriate place(s), so that the space is preserved in the HTML.</report>
    </rule>
    
    <rule context="disp-formula/*" id="disp-formula-child-tests">
      
      <report test="not(local-name()=('label','math'))" 
        role="error" 
        id="disp-formula-child-test-1"><name/> element is not allowed as a child of disp-formula.</report>
    </rule>
    
    <rule context="inline-formula/*" id="inline-formula-child-tests">
      
      <report test="local-name()!='math'" 
        role="error" 
        id="inline-formula-child-test-1"><name/> element is not allowed as a child of inline-formula.</report>
    </rule>
    
    <rule context="table-wrap" id="table-wrap-tests">
      <let name="id" value="@id"/>
      <let name="lab" value="label[1]"/>
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-wrap-test-1" 
        test="table" 
        role="error" 
        id="table-wrap-test-1">table-wrap must have one table.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-wrap-test-2" 
        test="count(table) &gt; 1" 
        role="warning" 
        id="table-wrap-test-2">table-wrap has more than one table - Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-wrap-test-3" 
        test="(contains($id,'inline')) and (normalize-space($lab) != '')" 
        role="error" 
        id="table-wrap-test-3">table-wrap has an inline id <value-of select="$id"/> but it has a label - <value-of select="$lab"/>, which is not correct.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-wrap-test-4" 
        test="(matches($id,'^table[0-9]{1,3}$')) and (normalize-space($lab) = '')" 
        role="error" 
        id="table-wrap-test-4">table-wrap with id <value-of select="$id"/> has no label which is not correct.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-wrap-test-1" 
        test="($id = 'keyresource') and not(matches($lab,'^Key resources table$|^Appendix [0-9]{1,4}—key resources table$'))" 
        role="error" 
        id="kr-table-wrap-test-1">table-wrap has an id 'keyresource' but its label is not in the format 'Key resources table' or 'Appendix 0—key resources table', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#pre-table-wrap-cite-1" 
        test="if (contains($id,'keyresource')) then ()
        else if (contains($id,'inline')) then ()
        else if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="warning" 
        id="pre-table-wrap-cite-1">There is no citation to <value-of select="$lab"/> Ensure to query the author asking for a citation.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#final-table-wrap-cite-1" 
        test="if (contains($id,'keyresource')) then ()
        else if (contains($id,'inline')) then ()
        else if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else if (ancestor::app or ancestor::sub-article) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="warning" 
        id="final-table-wrap-cite-1">There is no citation to <value-of select="$lab"/> Ensure this is added.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#feat-table-wrap-cite-1" 
        test="if (contains($id,'inline')) then ()
        else if ($article-type = $features-article-types) then (not(ancestor::article//xref[@rid = $id]))
        else ()" 
        role="warning" 
        id="feat-table-wrap-cite-1">There is no citation to <value-of select="if (label) then label else 'table.'"/> Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-not-tagged" 
        test="not(matches($id,'keyresource|app[\d]{1,4}keyresource')) and matches(normalize-space(descendant::thead[1]),'[Rr]eagent\s?type\s?\(species\)\s?or resource\s?[Dd]esignation\s?[Ss]ource\s?or\s?reference\s?[Ii]dentifiers\s?[Aa]dditional\s?information')" 
        role="warning" 
        id="kr-table-not-tagged"><value-of select="$lab"/> has headings that are for a Key resources table, but it does not have an @id the format 'keyresource' or 'app0keyresource'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-not-tagged-2" 
        test="matches(caption/title[1],'[Kk]ey [Rr]esource')" 
        role="warning" 
        id="kr-table-not-tagged-2"><value-of select="$lab"/> has the title <value-of select="caption/title[1]"/> but it is not tagged as a key resources table. Is this correct?</report>
      
    </rule>
    
    <rule context="table-wrap[not(ancestor::sub-article) and not(contains(@id,'keyresource')) and label]" id="table-title-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#pre-table-title-test-1" 
        test="caption/title" 
        role="warning" 
        id="pre-table-title-test-1"><value-of select="replace(label[1],'\.$','')"/> does not have a title. Please ensure to query the authors for one.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#final-table-title-test-1" 
        test="caption/title" 
        role="error" 
        id="final-table-title-test-1"><value-of select="replace(label[1],'\.$','')"/> does not have a title. Please ensure to query the authors for one.</assert>
    </rule>
    
    <rule context="table-wrap/caption/title" id="table-title-tests-2">
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\s ]$',''),'\. '))"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-title-test-2" 
        test="not(*) and normalize-space(.)=''" 
        role="error" 
        id="table-title-test-2">The title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> is empty which is not allowed.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-title-test-3" 
        test="ends-with(.,'.') or ends-with(.,'?')" 
        role="error" 
        id="table-title-test-3">The title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> does not end with a full stop which is incorrect - '<value-of select="."/>'.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-title-test-4" 
        test="ends-with(.,' vs.')" 
        role="warning" 
        id="table-title-test-4">title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-title-test-5" 
        test="string-length(.) gt 250" 
        role="warning" 
        id="table-title-test-5">title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-title-test-6" 
        test="$sentence-count gt 1" 
        role="warning" 
        id="table-title-test-6">title for <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
    </rule>
    
    <rule context="table-wrap[contains(@id,'keyresource')]/table/thead[1]" id="kr-table-heading-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-1" 
        test="count(tr[1]/th) != 5" 
        role="warning" 
        id="kr-table-header-1">Key resources tables should have 5 column headings (th elements) but this one has <value-of select="count(tr[1]/th)"/>. Either it is incorrectly typeset or the author will need to be queried in order to provide the table in the correct format.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-2" 
        test="count(tr) gt 1" 
        role="warning" 
        id="kr-table-header-2">Key resources table has more than 1 row in its header, which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-3" 
        test="count(tr) lt 1" 
        role="warning" 
        id="kr-table-header-3">Key resources table has no rows in its header, which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-4" 
        test="tr[1]/th[1] and (normalize-space(tr[1]/th[1]) != 'Reagent type (species) or resource')" 
        role="warning" 
        id="kr-table-header-4">The first column header in a Key resources table is usually 'Reagent type (species) or resource' but this one has '<value-of select="tr[1]/th[1]"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-5" 
        test="tr[1]/th[2] and (normalize-space(tr[1]/th[2]) != 'Designation')" 
        role="warning" 
        id="kr-table-header-5">The second column header in a Key resources table is usually 'Designation' but this one has '<value-of select="tr[1]/th[2]"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-6" 
        test="tr[1]/th[3] and (normalize-space(tr[1]/th[3]) != 'Source or reference')" 
        role="warning" 
        id="kr-table-header-6">The third column header in a Key resources table is usually 'Source or reference' but this one has '<value-of select="tr[1]/th[3]"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-7" 
        test="tr[1]/th[4] and (normalize-space(tr[1]/th[4]) != 'Identifiers')" 
        role="warning" 
        id="kr-table-header-7">The fourth column header in a Key resources table is usually 'Identifiers' but this one has '<value-of select="tr[1]/th[4]"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-header-8" 
        test="tr[1]/th[5] and (normalize-space(tr[1]/th[5]) != 'Additional information')" 
        role="warning" 
        id="kr-table-header-8">The fifth column header in a Key resources table is usually 'Additional information' but this one has '<value-of select="tr[1]/th[5]"/>'.</report>
      
    </rule>
    
    <rule context="table-wrap[contains(@id,'keyresource')]/table/tbody/tr/*" id="kr-table-body-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#kr-table-body-1" 
        test="local-name()='td'" 
        role="error" 
        id="kr-table-body-1">Table cell in KR table containing '<value-of select="."/>' is captured as a table header cell (<value-of select="local-name()"/>), which is not allowed. Ensure that this is changed to a normal table cell (td).</assert>
      
    </rule>
    
    <rule context="table-wrap/table/tbody/tr/*[xref[@ref-type='bibr'] and matches(.,'[\(\)\[\]]')]|table-wrap/table/thead/tr/*[xref[@ref-type='bibr'] and matches(.,'[\(\)\[\]]')]" id="table-cell-tests">
      <let name="stripped-text" value="string-join(for $x in self::*/(text()|*)
        return if (($x/local-name()='xref') and $x/@ref-type='bibr') then ()
        else $x,'')"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/funding-information#table-cell-1" 
        test="matches($stripped-text,'[\p{N}\p{L}]')" 
        role="warning" 
        id="table-cell-1">Table cell in <value-of select="replace(ancestor::table-wrap[1]/label[1],'\.$','')"/> contains '<value-of select="."/>'. Are the brackets around the citation(s) unnecessary?</assert>
      
    </rule>
    
    <rule context="body//table-wrap/label" id="body-table-label-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#body-table-label-test-1" 
        test="matches(.,'^Table \d{1,4}\.$|^Key resources table$|^Author response table \d{1,4}\.$|^Decision letter table \d{1,4}\.$')" 
        role="error" 
        id="body-table-label-test-1"><value-of select="."/> - Table label does not conform to the usual format.</assert>
      
    </rule>
    
    <rule context="app//table-wrap/label" id="app-table-label-tests">
      <let name="app" value="ancestor::app/title[1]"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#app-table-label-test-1" 
        test="matches(.,'^Appendix \d{1,4}—table \d{1,4}\.$|^Appendix \d{1,4}—key resources table$')" 
        role="error" 
        id="app-table-label-test-1"><value-of select="."/> - Table label does not conform to the usual format.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#app-table-label-test-2" 
        test="starts-with(.,$app)" 
        role="error" 
        id="app-table-label-test-2"><value-of select="."/> - Table label does not begin with the title of the appendix it sits in. Either the table is in the incorrect appendix or the table has been labelled incorrectly.</assert>
      
    </rule>
    
    <rule context="table" id="table-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-test-1" 
        test="count(tbody) = 0" 
        role="error" 
        id="table-test-1">table must have at least one body (tbody).</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-test-2" 
        test="thead" 
        role="warning" 
        id="table-test-2">table doesn't have a header (thead). Is this correct?</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-test-3" 
        test="thead and tbody/tr/th[not(following-sibling::td)] and count(descendant::tr) gt 45" 
        role="warning" 
        id="table-test-3"><value-of select="if (ancestor::table-wrap[1]/label[1]) then replace(ancestor::table-wrap[1]/label[1],'\.$','') else 'Table'"/> has a main header (thead), but it also has a header or headers in the body and contains 45 or more rows. The main (first) header will as a result appear at the start of any new pages in the PDF. Is this correct? Or should the main header be moved down into the body (but still captured with &lt;th&gt; instead of &lt;td&gt;) so that this header does not appear on the subsequent pages?</report>
    </rule>
    
    <rule context="table/tbody" id="tbody-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#tbody-test-1" 
        test="count(tr) = 0" 
        role="error" 
        id="tbody-test-1">tbody must have at least one row (tr).</report>
    </rule>
    
    <rule context="table/thead" id="thead-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#thead-test-1" 
        test="count(tr) = 0" 
        role="error" 
        id="thead-test-1">thead must have at least one row (tr).</report>
    </rule>
    
    <rule context="tr" id="tr-tests">
      <let name="count" value="count(th) + count(td)"/> 
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#tr-test-1" 
        test="$count = 0" 
        role="error" 
        id="tr-test-1">row (tr) must contain at least one heading cell (th) or data cell (td).</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#tr-test-2" 
        test="th and (parent::tbody)" 
        role="warning" 
        id="tr-test-2">table row in body contains a th element (a header). Please check that this is correct.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#tr-test-3" 
        test="td and (parent::thead)" 
        role="error" 
        id="tr-test-3">table row in header contains a td element (table data), which is not allowed. Only th elements (table heading cells) are allowed in a row in the table header.</report>
    </rule>
    
    <rule context="td/*" id="td-child-tests">
      <let name="allowed-blocks" value="('bold','italic','sup','sub','sc','ext-link','xref', 'break', 'named-content', 'monospace', 'code','inline-graphic','underline','inline-formula')"/> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#td-child-test" 
        test="self::*/local-name() = $allowed-blocks" 
        role="error" 
        id="td-child-test">td cannot contain <value-of select="self::*/local-name()"/>. Only the following elements are allowed - 'bold', 'italic', 'sup', 'sub', 'sc', 'ext-link', 'xref', 'break', 'named-content', 'monospace', 'code','inline-graphic','underline', and 'inline-formula'.</assert>
    </rule>
    
    <rule context="th/*" id="th-child-tests">
      <let name="allowed-blocks" value="('bold','italic','sup','sub','sc','ext-link','xref', 'break', 'named-content', 'monospace','inline-formula','inline-graphic')"/> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#th-child-test-1" 
        test="self::*/local-name() = ($allowed-blocks)" 
        role="error" 
        id="th-child-test-1">th cannot contain <value-of select="self::*/local-name()"/>. Only the following elements are allowed - 'bold', 'italic', 'sup', 'sub', 'sc', 'ext-link', 'xref', 'break', 'named-content', 'monospace',  'code', 'inline-graphic', and 'inline-formula'.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#th-child-test-2" 
        test="self::*/local-name() = 'bold'" 
        role="warning" 
        id="th-child-test-2">th contains bold. Is this correct?</report>
    </rule>
    
    <rule context="th" id="th-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#th-row-test" 
        test="following-sibling::td or preceding-sibling::td" 
        role="warning" 
        id="th-row-test">Table header cell containing '<value-of select="."/>' has table data (not header) cells next to it on the same row. Is this correct? Should the whole row be header cells, or should this cell extend across the whole row?</report>
      
    </rule>
    
    <rule context="table-wrap-foot//fn/p" id="table-fn-label-tests"> 
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-fn-label-test-1" 
        test="not(matches(.,'^\s?[*†‡§¶]')) and matches(.,'^\s?[\p{Ps}]?[\da-z][\p{Pe}]?\s+[\p{Lu}\d]')" 
        role="warning" 
        id="table-fn-label-test-1">Footnote starts with what might be a label which is not in line with house style - <value-of select="."/>. If it is a label, then it should changed to one of the allowed symbols, so that the order of labels in the footnotes follows this sequence *, †, ‡, §, ¶, **, ††, ‡‡, §§, ¶¶, etc.</report>
    </rule>
    
    <rule context="fn[@id][not(@fn-type='other')]" id="fn-tests">
      
      <assert test="ancestor::article//xref/@rid = @id" 
        role="error" 
        id="fn-xref-presence-test">fn element with an id must have at least one xref element pointing to it.</assert>
    </rule>
    
    <rule context="list" id="list-tests">
      
      <report test="@continued-from" 
        role="error" 
        id="continued-from-test-1">The continued-from attribute is not allowed for lists, since this is not supported by Continuum. Please use an alternative method to capture lists which are interrupted.</report>
      
    </rule>
    
    <rule context="list-item" id="list-item-tests">
      <let name="type" value="ancestor::list[1]/@list-type"/>
      
      <report test="($type='bullet') and matches(.,'^\s?•')" 
        role="error" 
        id="bullet-test-1">list-item is part of bullet list, but it also begins with a '•', which means that two will output. Remove the unnecessary '•' from the beginning of the list-item.</report>
      
      <report test="($type='simple') and matches(.,'^\s?•')" 
        role="error" 
        id="bullet-test-2">list-item is part of simple list, but it begins with a '•'. Remove the unnecessary '•' and capture the list as a bullet type list.</report>
      
      <report test="($type='order') and matches(.,'^\s?\d+')" 
        role="warning" 
        id="order-test-1">list-item is part of an ordered list, but it begins with a number. Is this correct? <value-of select="."/></report>
      
      <report test="($type='alpha-lower') and matches(.,'^\s?[a-h|j-w|y-z][\.|\)]? ')" 
        role="warning" 
        id="alpha-lower-test-1">list-item is part of an alpha-lower list, but it begins with a single lower-case letter. Is this correct? <value-of select="."/></report>
      
      <report test="($type='alpha-upper') and matches(.,'^\s?[A-H|J-W|Y-Z][\.|\)]? ')" 
        role="warning" 
        id="alpha-upper-test-1">list-item is part of an alpha-upper list, but it begins with a single upper-case letter. Is this correct? <value-of select="."/></report>
      
      <report test="($type='roman-lower') and matches(.,'^\s?(i|ii|iii|iv|v|vi|vii|viii|ix|x)[\.|\)]? ')" 
        role="warning" 
        id="roman-lower-test-1">list-item is part of an roman-lower list, but it begins with a single roman-lower letter. Is this correct? <value-of select="."/></report>
      
      <report test="($type='roman-upper') and matches(.,'^\s?(I|II|III|IV|V|VI|VII|VIII|IX|X)[\.|\)]? ')" 
        role="warning" 
        id="roman-upper-test-1">list-item is part of an roman-upper list, but it begins with a single roman-upper letter. Is this correct? <value-of select="."/></report>
      
      <report test="($type='simple') and matches(.,'^\s?[1-9][\.|\)]? ')" 
        role="warning" 
        id="simple-test-1">list-item is part of a simple list, but it begins with a number. Should the list-type be updated to ordered and this number removed? <value-of select="."/></report>
      
      <report test="($type='simple') and matches(.,'^\s?[a-h|j-w|y-z][\.|\)] ')" 
        role="warning" 
        id="simple-test-2">list-item is part of a simple list, but it begins with a single lower-case letter. Should the list-type be updated to 'alpha-lower' and this first letter removed? <value-of select="."/></report>
      
      <report test="($type='simple') and matches(.,'^\s?[A-H|J-W|Y-Z][\.|\)] ')" 
        role="warning" 
        id="simple-test-3">list-item is part of a simple list, but it begins with a single upper-case letter. Should the list-type be updated to 'alpha-upper' and this first letter removed? <value-of select="."/></report>
      
      <report test="($type='simple') and matches(.,'^\s?(i|ii|iii|iv|v|vi|vii|viii|ix|x)[\.|\)]? ')" 
        role="warning" 
        id="simple-test-4">list-item is part of a simple list, but it begins with a single roman-lower letter. Should the list-type be updated to 'roman-lower' and this first letter removed? <value-of select="."/></report>
      
      <report test="($type='simple') and matches(.,'^\s?(I|II|III|IV|V|VI|VII|VIII|IX|X)[\.|\)]? ')" 
        role="warning" 
        id="simple-test-5">list-item is part of a simple list, but it begins with a single roman-upper letter. Should the list-type be updated to 'roman-upper' and this first letter removed? <value-of select="."/></report>
      
      <report test="matches(.,'^\s?\p{Ll}[\s\)\.]')" 
        role="warning" 
        id="list-item-test-1">list-item begins with a single lowercase letter, is this correct? - <value-of select="."/></report>
    </rule>
    
    <rule context="media[@mimetype='video'][matches(@id,'^video[0-9]{1,3}$')]" id="general-video">
      <let name="label" value="replace(label,'\.$','')"/>
      <let name="id" value="@id"/>
      <let name="xrefs" value="e:get-xrefs(ancestor::article,$id,'video')"/>
      <let name="sec1" value="ancestor::article/descendant::sec[@id = $xrefs//*/@sec-id][1]"/>
      <let name="sec-id" value="ancestor::sec[1]/@id"/>
      <let name="xref1" value="ancestor::article/descendant::xref[(@rid = $id) and not(ancestor::caption)][1]"/>
      <let name="xref-sib" value="$xref1/parent::*/following-sibling::*[1]/local-name()"/>
      
      <assert test="$xrefs//*:match" 
        role="warning" 
        id="pre-video-cite">There is no citation to <value-of select="$label"/>. Ensure to query the author asking for a citation.</assert>
      
      <assert test="$xrefs//*:match" 
        role="warning" 
        id="final-video-cite">There is no citation to <value-of select="$label"/>. Ensure this is added.</assert>
      
      <report test="($xrefs//*:match) and ($sec-id != $sec1/@id)" 
        role="error" 
        id="video-placement-1"><value-of select="$label"/> does not appear in the same section as where it is first cited (sec with title '<value-of select="$sec1/title"/>'), which is incorrect.</report>
      
      <report test="($xref-sib = 'p') and ($xref1//following::media/@id = $id)" 
        role="warning" 
        id="video-placement-2"><value-of select="$label"/> appears after its first citation but not directly after its first citation. Is this correct?</report>
      
    </rule>
    
    <rule context="code" id="code-tests">
      
      <report test="child::*" 
        role="error" 
        id="code-child-test">code contains a child element, which will display in HTML with its tagging, i.e. '&lt;<value-of select="child::*[1]/name()"/><value-of select="if (child::*[1]/@*) then for $x in child::*[1]/@* return concat(' ',$x/name(),'=&quot;',$x/string(),'&quot;') else ()"/>&gt;<value-of select="child::*[1]"/>&lt;/<value-of select="child::*[1]/name()"/>&gt;'. Strip any child elements.</report>
      
      <assert test="parent::p" 
        role="error" 
        id="code-parent-test">code element (containing the content <value-of select="."/>) is directly preceded by another code element (containing the content <value-of select="preceding::*[1]"/>). If the content is part of the same code block, then it should be captured using only 1 code element and line breaks added in the xml. If these are separate code blocks (uncommon, but possible), then this markup is fine.</assert>
      
    </rule>
    
    <rule context="p[count(code) gt 1]/code[2]" id="code-tests-2">
      
      <report test="normalize-space(preceding-sibling::text()[preceding-sibling::*[1]/local-name()='code'][1])=''" 
        role="warning" 
        id="code-sibling-test">code element (containing the content <value-of select="."/>) is directly preceded by another code element (containing the content <value-of select="preceding::*[1]"/>). If the content is part of the same code block, then it should be captured using only 1 code element and line breaks added in the xml. If these are separate code blocks (uncommon, but possible), then this markup is fine.</report>
      
    </rule>
    
    <rule context="p[count(code) = 1]/code" id="code-tests-3">
      <let name="previous-parent" value="parent::p/preceding-sibling::*[1]"/>
      
      <report test="$previous-parent/*[last()][(local-name()='code') and not(following-sibling::text())] and not(preceding-sibling::*) and not(preceding-sibling::text())" 
        role="warning" 
        id="code-sibling-test-2">code element (containing the content <value-of select="."/>) is directly preceded by another code element (containing the content <value-of select="preceding::*[1]"/>). If the content is part of the same code block, then it should be captured using only 1 code element and line breaks added in the xml. If these are separate code blocks (uncommon, but possible), then this markup is fine.</report>
      
    </rule>
    
    <rule context="fig/label|supplementary-material/label|media/label|table-wrap/label|boxed-text/label" id="generic-label-tests">
      <let name="label" value="replace(.,'\.$','')"/>
      <let name="label-2" value="replace(.,'\p{P}','')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#label-fig-group-conformance-1" 
        test="not(ancestor::fig-group) and parent::fig[@specific-use='child-fig']" 
        role="error" 
        id="label-fig-group-conformance-1"><value-of select="$label"/> is not placed in a &lt;fig-group&gt; element, which is incorrect. Either the label needs updating, or it needs moving into the &lt;fig-group&gt;.</report>
      
      <report test="not(ancestor::fig-group) and parent::media and matches(.,'[Ff]igure')" 
        role="error" 
        id="label-fig-group-conformance-2"><value-of select="$label"/> contains the string 'Figure' but it's not placed in a &lt;fig-group&gt; element, which is incorrect. Either the label needs updating, or it needs moving into the &lt;fig-group&gt;.</report>
      
      <report test="some $x in preceding::label satisfies (replace($x,'\p{P}','') = $label-2)" 
        role="error" 
        id="distinct-label-conformance">Duplicated labels - <value-of select="$label"/> is present more than once in the text.</report>
      
    </rule>
    
    <rule context="disp-formula/label" id="equation-label-tests">
      <let name="label-2" value="replace(.,'\p{P}','')"/>
      <let name="app-id" value="ancestor::app/@id"/>
      
      <report test="(ancestor::app) and (some $x in preceding::disp-formula/label[ancestor::app[@id=$app-id]] satisfies (replace($x,'\p{P}','') = $label-2))" 
        role="error" 
        id="equation-label-conformance-1">Duplicated display formula labels - <value-of select="."/> is present more than once in the same appendix.</report>
      
      <report test="(ancestor::body[parent::article]) and (some $x in preceding::disp-formula/label[ancestor::body[parent::article] and not(ancestor::fig)] satisfies (replace($x,'\p{P}','') = $label-2))" 
        role="error" 
        id="equation-label-conformance-2">Duplicated display formula labels - <value-of select="."/> is present more than once in the main body of the text.</report>
      
    </rule>
    
    <rule context="aff/label" id="aff-label-tests">
      <let name="label-2" value="replace(.,'\p{P}','')"/>
      
      <report test="some $x in preceding::aff/label satisfies (replace($x,'\p{P}','') = $label-2)" 
        role="error" 
        id="aff-label-conformance-1">Duplicated affiliation labels - <value-of select="."/> is present more than once.</report>
    </rule>
    
    <rule context="disp-quote" id="disp-quote-tests">
      <let name="subj" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="ancestor::sub-article[@article-type='decision-letter']" 
        role="warning" 
        flag="dl-ar"
        id="disp-quote-test-1">Content is tagged as a display quote, which is almost definitely incorrect, since it's in a decision letter - <value-of select="."/></report>
      
      <report test="not(ancestor::sub-article) and ($subj=$research-subj)" 
        role="error"
        id="disp-quote-test-2">Display quote in a <value-of select="$subj"/> is not allowed. Please capture as paragraph instead - '<value-of select="."/>'</report>
    </rule>
    
    <rule context="p[matches(.,'[\(\)\[\]]')]|th[matches(.,'[\(\)\[\]]')]|td[matches(.,'[\(\)\[\]]')]|title[matches(.,'[\(\)\[\]]')]" id="bracket-tests">
      <let name="open-curly" value="string-length(replace(.,'[^\(]',''))"/>
      <let name="close-curly" value="string-length(replace(.,'[^\)]',''))"/>
      <let name="open-square" value="string-length(replace(.,'[^\[]',''))"/>
      <let name="close-square" value="string-length(replace(.,'[^\]]',''))"/>
      
      <report test="$open-curly gt $close-curly" 
        role="warning" 
        id="bracket-test-1"><name/> element contains more left '(' than right ')' parentheses (<value-of select="$open-curly"/> and <value-of select="$close-curly"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\(]','')) gt string-length(replace($sentence,'[^\)]',''))) then $sentence else (),' ---- ')"/></report>
      
      <report test="not(matches(.,'^\s?(\d+|[A-Za-z]|[Ii]?[Xx]|[Ii]?[Vv]|[Vv]?[Ii]{1,3})\)')) and ($open-curly lt $close-curly)" 
        role="warning" 
        id="bracket-test-2"><name/> element contains more right ')' than left '(' parentheses (<value-of select="$close-curly"/> and <value-of select="$open-curly"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\(]','')) lt string-length(replace($sentence,'[^\)]',''))) then $sentence else (),' ---- ')"/></report>
      
      <report test="$open-square gt $close-square" 
        role="warning" 
        id="bracket-test-3"><name/> element contains more left '[' than right ']' square brackets (<value-of select="$open-square"/> and <value-of select="$close-square"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\[]','')) gt string-length(replace($sentence,'[^\]]',''))) then $sentence else (),' ---- ')"/></report>
      
      <report test="not(matches(.,'^\s?(\d+|[A-Za-z]|[Ii]?[Xx]|[Ii]?[Vv]|[Vv]?[Ii]{1,3})\]')) and ($open-square lt $close-square)" 
        role="warning" 
        id="bracket-test-4"><name/> element contains more right ']' than left '[' square brackets (<value-of select="$close-square"/> and <value-of select="$open-square"/> respectively). Is that correct? Possibly troublesome section(s) are <value-of select="string-join(for $sentence in tokenize(.,'\. ') return if (string-length(replace($sentence,'[^\[]','')) lt string-length(replace($sentence,'[^\]]',''))) then $sentence else (),' ---- ')"/></report>
    </rule>
    
  </pattern>
  
  <pattern id="video-tests">
    
    <rule context="article[(@article-type!='correction') and (@article-type!='retraction')]/body//media[@mimetype='video']" id="body-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'][matches(label[1],'^Video [\d]+\.$')])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'][matches(label[1],'^Video [\d]+\.$')][ancestor::body])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      <let name="fig-label" value="replace(ancestor::fig-group/fig[1]/label,'\.$','—')"/>
      <let name="fig-pos" value="count(ancestor::fig-group//media[@mimetype='video'][starts-with(label[1],$fig-label)]) - count(following::media[@mimetype='video'][starts-with(label[1],$fig-label)])"/>
      
      <report test="not(ancestor::fig-group) and (matches(label[1],'[Vv]ideo')) and ($no != string($pos))" 
        role="warning" 
        id="pre-body-video-position-test-1"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other videos it is placed in position <value-of select="$pos"/>. Please ensure this is queried with the authors if they have cited them out of position.</report>
      
      <report test="not(ancestor::fig-group) and (matches(label[1],'[Vv]ideo')) and ($no != string($pos))" 
        role="error" 
        id="final-body-video-position-test-1"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other videos it is placed in position <value-of select="$pos"/>.</report>
      
      <assert test="starts-with(label[1],$fig-label)" 
        role="error" 
        id="fig-video-label-test"><value-of select="label"/> does not begin with its parent figure label - <value-of select="$fig-label"/> - which is incorrect.</assert>
      
      <report test="(ancestor::fig-group) and ($no != string($fig-pos))" 
        role="error" 
        id="fig-video-position-test"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other fig-level videos it is placed in position <value-of select="$fig-pos"/>.</report>
      
      <report test="(not(ancestor::fig-group)) and (descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))])" 
        role="warning" 
        id="fig-video-check-1"><value-of select="label"/> contains a link to <value-of select="descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))][1]"/>, but it is not a captured as a child of that fig. Should it be captured as <value-of select="concat(descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))][1],'—video x')"/> instead?</report>
      
    </rule>
    
    <rule context="app//media[@mimetype='video']" id="app-video-specific">
      <let name="app-id" value="ancestor::app/@id"/>
      <let name="count" value="count(ancestor::app//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[(@mimetype='video') and (ancestor::app/@id = $app-id)])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      <assert test="$no = string($pos)" 
        role="warning" 
        id="pre-app-video-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert test="$no = string($pos)" 
        role="error" 
        id="final-app-video-position-test"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
    </rule>
    
    <rule context="fig-group/media[@mimetype='video']" id="fig-video-specific">
      
      <report test="following-sibling::fig" 
        role="error" 
        id="fig-video-position-test-2"><value-of select="replace(label,'\.$','')"/> is placed before <value-of select="following-sibling::fig[1]/label[1]"/> Figure level videos should always be placed after figures and figure supplements in their figure group.</report>
      
    </rule>
    
    <rule context="sub-article/body//media[@mimetype='video']" id="ar-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      <assert test="$no = string($pos)" 
        role="warning" 
        flag="dl-ar"
        id="pre-ar-video-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert test="$no = string($pos)" 
        role="error" 
        id="final-ar-video-position-test"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
    </rule>
    
  </pattern>
  
  <pattern id="table-pos-tests">
    
    <rule context="article[(@article-type!='correction') and (@article-type!='retraction')]/body//table-wrap[matches(@id,'^table[\d]+$')]" id="body-table-pos-conformance">
      <let name="count" value="count(ancestor::body//table-wrap[matches(@id,'^table[\d]+$')])"/>
      <let name="pos" value="$count - count(following::table-wrap[(matches(@id,'^table[\d]+$')) and (ancestor::body) and not(ancestor::sub-article)])"/>
      <let name="no" value="substring-after(@id,'table')"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#pre-body-table-report" 
        test="($no = string($pos))" 
        role="warning" 
        id="pre-body-table-report"><value-of select="label"/> does not appear in sequence. Relative to the other numbered tables it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#final-body-table-report" 
        test="($no = string($pos))" 
        role="error" 
        id="final-body-table-report"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other numbered tables it is placed in position <value-of select="$pos"/>.</assert>
      
    </rule>
    
    <rule context="article//app//table-wrap[matches(@id,'^app[\d]+table[\d]+$')]" id="app-table-pos-conformance">
      <let name="app-id" value="ancestor::app/@id"/>
      <let name="app-no" value="substring-after($app-id,'appendix-')"/>
      <let name="id-regex" value="concat('^app',$app-no,'table[\d]+$')"/>
      <let name="count" value="count(ancestor::app//table-wrap[matches(@id,$id-regex)])"/>
      <let name="pos" value="$count - count(following::table-wrap[matches(@id,$id-regex)])"/>
      <let name="no" value="substring-after(@id,concat($app-no,'table'))"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#pre-app-table-report" 
        test="($no = string($pos))" 
        role="warning" 
        id="pre-app-table-report"><value-of select="label"/> does not appear in sequence. Relative to the other numbered tables in the same appendix it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#final-app-table-report" 
        test="($no = string($pos))" 
        role="error" 
        id="final-app-table-report"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other numbered tables in the same appendix it is placed in position <value-of select="$pos"/>.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="further-fig-tests">
  
    <rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]" id="fig-specific-tests">
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
      <let name="in-between-elements" value="distinct-values(
        $first-cite-parent/following-sibling::*[@id=$id or (child::*[@id=$id] and local-name()='fig-group') or following::*[@id=$id] or following::*/*[@id=$id]]/local-name()
        )"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-specific-test-1" 
        test="label[contains(lower-case(.),'supplement')]" 
        role="error" 
        id="fig-specific-test-1">fig label contains 'supplement', but it does not have a @specific-use='child-fig'. If it is a figure supplement it needs the attribute, if it isn't then it cannot contain 'supplement' in the label.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-fig-specific-test-2" 
        test="if ($article-type = ('correction','retraction')) then ()
        else if ($count = 0) then ()
        else if (not(matches($id,'^fig[0-9]{1,3}$'))) then ()
        else $no != string($pos)" 
        role="warning" 
        id="pre-fig-specific-test-2"><value-of select="$lab"/> does not appear in sequence. Relative to the other figures it is placed in position <value-of select="$pos"/>. Please query this with the author.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#final-fig-specific-test-2" 
        test="if ($article-type = ('correction','retraction')) then ()
        else if ($count = 0) then ()
        else if (not(matches($id,'^fig[0-9]{1,3}$'))) then ()
        else $no != string($pos)" 
        role="error" 
        id="final-fig-specific-test-2"><value-of select="$lab"/> does not appear in sequence which is incorrect. Relative to the other figures it is placed in position <value-of select="$pos"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-specific-test-3" 
        test="not($article-type = ('correction','retraction')) and ancestor::article//xref[@rid = $id] and  (empty($in-between-elements) or (some $x in $in-between-elements satisfies not($x=('fig-group','fig','media','table-wrap'))))" 
        role="warning" 
        id="fig-specific-test-3"><value-of select="$lab"/> is cited, but does not appear directly after the paragraph citing it. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-fig-specific-test-4" 
        test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else if (contains($lab,'Chemical') or contains($lab,'Scheme')) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="warning" 
        id="pre-fig-specific-test-4">There is no citation to <value-of select="$lab"/> Ensure to query the author asking for a citation.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#final-fig-specific-test-4" 
        test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else if (contains($lab,'Chemical') or contains($lab,'Scheme')) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="warning" 
        id="final-fig-specific-test-4">There is no citation to <value-of select="$lab"/> Ensure this is added.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#feat-fig-specific-test-4" 
        test="if ($article-type = $features-article-types) then (not(ancestor::article//xref[@rid = $id]))
        else ()" 
        role="warning" 
        id="feat-fig-specific-test-4">There is no citation to <value-of select="if (label) then label else 'figure.'"/> Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-specific-test-6" 
        test="($fol-sib/local-name() = 'p') and ($fol-sib/*/local-name() = 'disp-formula') and (count($fol-sib/*[1]/preceding-sibling::text()) = 0) and (not(matches($pre-sib,'\.\s*?$|\?\s*?$|!\s*?$')))" 
        role="warning" 
        id="fig-specific-test-6"><value-of select="$lab"/> is immediately followed by a display formula, and preceded by a paragraph which does not end with punctuation. Should it should be moved after the display formula or after the para following the display formula?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-specific-test-5" 
        test="($fol-sib/local-name() = 'disp-formula') and (not(matches($pre-sib,'\.\s*?$|\?\s*?$|!\s*?$')))" 
        role="warning" 
        id="fig-specific-test-5"><value-of select="$lab"/> is immediately followed by a display formula, and preceded by a paragraph which does not end with punctuation. Should it should be moved after the display formula or after the para following the display formula?</report>
      
      <report test="not($article-type = ('correction','retraction')) and ancestor::article//xref[(ancestor::caption or ancestor::table-wrap) and @rid = $id] and not(ancestor::article//xref[(@rid = $id) and not(ancestor::caption) and not(ancestor::table-wrap)])" 
        role="warning"
        id="fig-specific-test-7"><value-of select="$lab"/> is only cited in a table or the caption of an object. Please ask the authors for citation in the main text.</report>
  
    </rule>
    
    <rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]/label" id="fig-label-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-label-test-1" 
        test="matches(.,'^Figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error" 
        id="fig-label-test-1">fig label must be in the format 'Figure 0.', 'Chemical structure 0.', or 'Scheme 0'.</assert>
    </rule>
    
    <rule context="article/body//fig[@specific-use='child-fig']" id="fig-sup-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(parent::fig-group/fig[@specific-use='child-fig'])"/>
      <let name="pos" value="$count - count(following-sibling::fig[@specific-use='child-fig'])"/>
      <let name="label-conform" value="matches(label[1],'^Figure [\d]+—figure supplement [\d]+')"/>
      <let name="no" value="substring-after(@id,'s')"/>
      <let name="parent-fig-no" value="substring-after(parent::fig-group/fig[not(@specific-use='child-fig')][1]/@id,'fig')"/>
      <let name="label-no" value="replace(substring-after(label[1],'supplement'),'[^\d]','')"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-sup-test-1" 
        test="parent::fig-group" 
        role="error" 
        id="fig-sup-test-1">fig supplement is not a child of fig-group. This cannot be correct.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-sup-test-2" 
        test="$label-conform = true()" 
        role="error" 
        id="fig-sup-test-2">fig in the body of the article which has a @specific-use='child-fig' must have a label in the format 'Figure 0—figure supplement 0.' (where 0 is one or more digits).</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-sup-test-3" 
        test="starts-with(label[1],concat('Figure ',$parent-fig-no))" 
        role="error" 
        id="fig-sup-test-3"><value-of select="label"/> does not start with the main figure number it is associated with - <value-of select="concat('Figure ',$parent-fig-no)"/>.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-sup-test-4" 
        test="if ($article-type = ('correction','retraction')) then ()
        else $no != string($pos)" 
        role="error" 
        id="fig-sup-test-4"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other figures it is placed in position <value-of select="$pos"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-sup-test-5" 
        test="if ($article-type = ('correction', 'retraction')) then ()
        else (($label-conform = true()) and ($label-no != string($pos)))" 
        role="error" 
        id="fig-sup-test-5"><value-of select="label"/> is in position <value-of select="$pos"/>, which means either the label or the placement incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-sup-test-6" 
        test="($label-conform = true()) and ($no != $label-no)" 
        role="error" 
        id="fig-sup-test-6"><value-of select="label"/> label ends with <value-of select="$label-no"/>, but the id (<value-of select="@id"/>) ends with <value-of select="$no"/>, so one must be incorrect.</report>
      
    </rule>
    
    <rule context="sub-article[@article-type='reply']//fig" id="rep-fig-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-test-2" 
        test="label" 
        role="error" 
        flag="dl-ar"
        id="resp-fig-test-2">fig must have a label.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#reply-fig-test-2" 
        test="matches(label[1],'^Author response image [0-9]{1,3}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error" 
        flag="dl-ar"
        id="reply-fig-test-2">fig label in author response must be in the format 'Author response image 1.', or 'Chemical Structure 1.', or 'Scheme 1.'.</assert>
      
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']//fig" id="dec-fig-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#dec-fig-test-1" 
        test="label" 
        role="error" 
        flag="dl-ar"
        id="dec-fig-test-1">fig must have a label.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#dec-fig-test-2" 
        test="matches(label[1],'^Decision letter image [0-9]{1,3}\.$')" 
        role="error" 
        flag="dl-ar"
        id="dec-fig-test-2">fig label in author response must be in the format 'Decision letter image 1.'.</assert>
      
    </rule>
    
    <rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]/label" id="box-fig-tests"> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#box-fig-test-1" 
        test="matches(.,'^Box \d{1,4}—figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error" 
        id="box-fig-test-1">label for fig inside boxed-text must be in the format 'Box 1—figure 1.', or 'Chemical structure 1.', or 'Scheme 1'.</assert>
    </rule>
    
    <rule context="article//app//fig[not(@specific-use='child-fig')]/label" id="app-fig-tests"> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-test-1" 
        test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix [A-Z]—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$|^Appendix \d{1,4}—chemical structure \d{1,4}\.$|^Appendix \d{1,4}—scheme \d{1,4}\.$|^Appendix [A-Z]—chemical structure \d{1,4}\.$|^Appendix [A-Z]—scheme \d{1,4}\.$|^Appendix—chemical structure \d{1,4}\.$|^Appendix—scheme \d{1,4}\.$')" 
        role="error" 
        id="app-fig-test-1">label for fig inside appendix must be in the format 'Appendix 1—figure 1.', 'Appendix A—figure 1.', or 'Appendix 1—chemical structure 1.', or 'Appendix A—scheme 1'.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-test-2" 
        test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$') and not(starts-with(.,ancestor::app/title))" 
        role="error" 
        id="app-fig-test-2">label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure is placed in the incorrect appendix or the label is incorrect.</report>
    </rule>
    
    <rule context="article//app//fig[@specific-use='child-fig']/label" id="app-fig-sup-tests"> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-sup-test-1" 
        test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}—figure supplement \d{1,4}\.$|^Appendix—figure \d{1,4}—figure supplement \d{1,4}\.$')" 
        role="error" 
        id="app-fig-sup-test-1">label for fig inside appendix must be in the format 'Appendix 1—figure 1—figure supplement 1.'.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-sup-test-2" 
        test="starts-with(.,ancestor::app/title)" 
        role="error" 
        id="app-fig-sup-test-2">label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure is placed in the incorrect appendix or the label is incorrect.</assert>
    </rule>
    
    <rule context="permissions[not(parent::article-meta)]" id="fig-permissions">
      <let name="label" value="if (parent::*/label[1]) then replace(parent::*/label[1],'\.$','') else parent::*/local-name()"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-1" 
        test="copyright-statement and (not(copyright-year) or not(copyright-holder))" 
        role="error" 
        id="fig-permissions-test-1">permissions for <value-of select="$label"/> has a copyright-statement, but not a copyright-year or copyright-holder which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-2" 
        test="copyright-year and (not(copyright-statement) or not(copyright-holder))" 
        role="error" 
        id="fig-permissions-test-2">permissions for <value-of select="$label"/> has a copyright-year, but not a copyright-statement or copyright-holder which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-3" 
        test="copyright-holder and (not(copyright-statement) or not(copyright-year))" 
        role="error" 
        id="fig-permissions-test-3">permissions for <value-of select="$label"/> has a copyright-holder, but not a copyright-statement or copyright-year which is incorrect.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-4" 
        test="license/license-p" 
        role="error" 
        id="fig-permissions-test-4">permissions for <value-of select="$label"/> must contain a license-p element.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-5" 
        test="count(copyright-statement) gt 1" 
        role="error" 
        id="fig-permissions-test-5">permissions for <value-of select="$label"/> has <value-of select="count(copyright-statement)"/> &lt;copyright-statement&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-6" 
        test="count(copyright-holder) gt 1" 
        role="error" 
        id="fig-permissions-test-6">permissions for <value-of select="$label"/> has <value-of select="count(copyright-holder)"/> &lt;copyright-holder&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-7" 
        test="count(copyright-year) gt 1" 
        role="error" 
        id="fig-permissions-test-7">permissions for <value-of select="$label"/> has <value-of select="count(copyright-year)"/> &lt;copyright-year&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-8" 
        test="count(license) gt 1" 
        role="error" 
        id="fig-permissions-test-8">permissions for <value-of select="$label"/> has <value-of select="count(license)"/> &lt;license&gt; elements, when there can only be 0 or 1.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-9" 
        test="(count(license) = 1) and not(license/license-p)" 
        role="error" 
        id="fig-permissions-test-9">permissions for <value-of select="$label"/> has a &lt;license&gt; element, but not &lt;license-p&gt; element, which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-10" 
        test="count(license/license-p) gt 1" 
        role="error" 
        id="fig-permissions-test-10">permissions for <value-of select="$label"/> has <value-of select="count(license-p)"/> &lt;license-p&gt; elements, when there can only be 0 or 1.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-11" 
        test="copyright-statement or license" 
        role="error" 
        id="fig-permissions-test-11">Asset level permissions must either have a &lt;copyright-statement&gt; and/or a &lt;license&gt; element, but those for <value-of select="$label"/> have neither.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-notification" 
        test="." 
        role="info" 
        id="permissions-notification"><value-of select="$label"/> has permissions - '<value-of select="if (license/license-p) then license/license-p else if (copyright-statement) then copyright-statement else ()"/>'.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#permissions-parent" 
        test="parent::*/local-name() = ('fig', 'media', 'table-wrap', 'boxed-text', 'supplementary-material')" 
        role="error" 
        id="permissions-parent">permissions  is not allowed as a child of <value-of select="parent::*/local-name()"/></assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-14" 
        test="copyright-statement" 
        role="warning" 
        id="fig-permissions-test-14">permissions for <value-of select="$label"/> does not contain a &lt;copyright-statement&gt; element. Is this correct? This would usually only be the case in CC0 licenses.</assert>
      
    </rule>
    
    <rule context="permissions[not(parent::article-meta) and copyright-year and copyright-holder]/copyright-statement" id="fig-permissions-2">
      <let name="label" value="if (parent::*/label[1]) then replace(parent::*/label[1],'\.$','') else parent::*/local-name()"/>
      <let name="text" value="concat('© ',parent::*/copyright-year[1],', ',parent::*/copyright-holder[1])"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-15" 
        test="contains(.,$text)" 
        role="error" 
        id="fig-permissions-test-15">The &lt;copyright-statement&gt; element in the permissions for <value-of select="$label"/> does not contain the text '<value-of select="$text"/>' (a concatenation of '© ', copyright-year, a comma and space, and copyright-holder).</assert>
    </rule>
    
    <rule context="permissions[not(parent::article-meta) and copyright-statement and not(license[1]/ali:license_ref[1][contains(.,'creativecommons.org')]) and not(contains(license[1]/@xlink:href,'creativecommons.org'))]" id="permissions-2">
      <let name="label" value="if (parent::*/label[1]) then replace(parent::*/label[1],'\.$','') else parent::*/local-name()"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-12" 
        test="matches(license[1]/license-p[1],'[Ff]urther reproduction of (this|these) (panels?|illustrations?) would need permission from the copyright holder\.$|[Ff]urther reproduction of this figure would need permission from the copyright holder\.$')" 
        role="warning" 
        id="fig-permissions-test-12"><value-of select="$label"/> permissions - the &lt;license-p&gt; for all rights reserved type permissions should usually end with 'further reproduction of this panel/illustration/figure would need permission from the copyright holder.', but <value-of select="$label"/>'s doesn't. Is this correct? (There is no 'https://creativecommons.org/' type link on the license element or in an ali:license_ref so presumed ARR.)</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#fig-permissions-test-13" 
        test="license//ext-link[contains(@xlink:href,'creativecommons.org')]" 
        role="warning" 
        id="fig-permissions-test-13"><value-of select="$label"/> permissions - the &lt;license-p&gt; contains a CC link, but the license does not have an ali:license_ref element, which is very likely incorrect.</report>
      
    </rule>
    
    <rule context="fig/caption/p" id="fig-caption-tests">
      <let name="label" value="replace(ancestor::fig[1]/label,'\.$','')"/>
      <let name="no-panels" value="replace(.,'\([a-zA-Z]\)|\([a-zA-Z]\-[a-zA-Z]\)','')"/>
      <let name="text-tokens" value="for $x in tokenize($no-panels,'\. ') return
        if (string-length($x) lt 3) then ()
        else if (matches($x,'^\s{1,3}?[a-z]')) then $x
        else ()"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-caption-test-1" 
        test="count($text-tokens) = 0" 
        role="warning" 
        id="fig-caption-test-1">Caption for <value-of select="$label"/> contains what looks like a lower case letter at the start of a sentence - <value-of select="string-join($text-tokens,'; ')"/>.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-caption-test-2" 
        test="contains(lower-case(.),'image credit') and not(parent::caption/parent::fig/attrib)" 
        role="warning" 
        id="fig-caption-test-2">Caption for <value-of select="$label"/> contains what looks like an image credit. It's quite likely that this should be captured in an &lt;attrib&gt; element instead - <value-of select="."/>.</report>
    </rule>
    
    <rule context="fig/caption/p/bold" id="fig-panel-tests">
      <let name="first-character" value="substring(.,1, 1)"/>
      <let name="last-character" value="substring(., string-length(.), 1)"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-panel-test-1"  
        test="($first-character= ('(', ')', '.', ',')) or ($last-character = ('(', ')', '.', ','))" 
        role="warning" 
        id="fig-panel-test-1">Bold text in the caption for <value-of select="replace(ancestor::fig[1]/label,'\.$','')"/> starts and/or ends with punctuation - <value-of select="."/> - is that correct? Or should the punctuation be unbolded?</report>
      
    </rule>
  </pattern>
  
  <pattern id="body">
    
    <rule context="article[@article-type='research-article']/body" id="ra-body-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="method-count" value="count(sec[@sec-type='materials|methods']) + count(sec[@sec-type='methods']) + count(sec[@sec-type='model'])"/>
      <let name="res-disc-count" value="count(sec[@sec-type='results']) + count(sec[@sec-type='discussion'])"/>
    
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#ra-sec-test-1"
        test="count(sec) = 0" 
        role="error" 
        id="ra-sec-test-1">At least one sec should be present in body for research-article content.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#ra-sec-test-2"
        test="if ($type = ('Short Report','Scientific Correspondence')) then ()
        else count(sec[@sec-type='intro']) != 1" 
        role="warning" 
        id="ra-sec-test-2"><value-of select="$type"/> doesn't have child sec[@sec-type='intro'] in the main body. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#ra-sec-test-3"
        test="if ($type = ('Short Report','Scientific Correspondence')) then ()
        else $method-count != 1" 
        role="warning" 
        id="ra-sec-test-3">main body in <value-of select="$type"/> content doesn't have a child sec with @sec-type whose value is either 'materials|methods', 'methods' or 'model'. Is this correct?.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#ra-sec-test-4"
        test="if ($type = ('Short Report','Scientific Correspondence')) then ()
        else if (sec[@sec-type='results|discussion']) then ()
        else $res-disc-count != 2" 
        role="warning" 
        id="ra-sec-test-4">main body in <value-of select="$type"/> content doesn't have either a child sec[@sec-type='results|discussion'] or a sec[@sec-type='results'] and a sec[@sec-type='discussion']. Is this correct?</report>
    
    </rule>
    
    <rule context="body/sec" id="top-level-sec-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
      <let name="allowed-titles" value="('Introduction', 'Results', 'Discussion', 'Materials and methods', 'Results and discussion','Methods', 'Model')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-conformity"
        test="not($type = ($features-subj,'Review Article','Correction','Retraction')) and not(replace(title,' ',' ') = $allowed-titles)" 
        role="warning" 
        id="sec-conformity">top level sec with title - <value-of select="title"/> - is not a usual title for <value-of select="$type"/> content. Should this be captured as a sub-level of <value-of select="preceding-sibling::sec[1]/title"/>?</report>
      
    </rule>
  </pattern>
  
  <pattern id="title-conformance">
    
    <rule context="article-meta//article-title" id="article-title-tests">
      <let name="type" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="specifics" value="('Replication Study','Registered Report','Correction','Retraction')"/>
      
      <report test="if ($type = $specifics) then not(starts-with(.,e:article-type2title($type)))
        else ()" 
        role="error" 
        id="article-type-title-test-1">title of a '<value-of select="$type"/>' must start with '<value-of select="e:article-type2title($type)"/>'.</report>
      
      <report test="($type = 'Scientific Correspondence') and not(matches(.,'^Comment on|^Response to comment on'))" 
        role="error" 
        id="article-type-title-test-2">title of a '<value-of select="$type"/>' must start with 'Comment on' or 'Response to comment on', but this starts with something else - <value-of select="."/>.</report>
      
      <report test="($type = 'Scientific Correspondence') and matches(.,'^Comment on “|^Response to comment on “')" 
        role="error" 
        id="sc-title-test-1">title of a '<value-of select="$type"/>' contains a left double quotation mark. The original article title must be surrounded by a single roman apostrophe - <value-of select="."/>.</report>
      
      <report test="($type = 'Scientific Correspondence') and matches(.,'”')" 
        role="warning" 
        id="sc-title-test-2">title of a '<value-of select="$type"/>' contains a right double quotation mark. Is this correct? The original article title must be surrounded by a single roman apostrophe - <value-of select="."/>.</report>
    </rule>
    
    <rule context="sec[@sec-type]/title" id="sec-title-tests">
      <let name="title" value="e:sec-type2title(parent::sec/@sec-type)"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-type-title-test"
        test="if ($title = 'undefined') then ()
        else . != $title" 
        role="warning" 
        id="sec-type-title-test">title of a sec with an @sec-type='<value-of select="parent::sec/@sec-type"/>' should usually be '<value-of select="$title"/>'.</report>
      
    </rule>
    
    <rule context="fig/caption/title" id="fig-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label[1]"/>
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\s ]$',''),'\. '))"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-1" 
        test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" 
        role="warning" 
        id="fig-title-test-1">'<value-of select="$label"/>' appears to have a title which is the beginning of a caption. Is this correct?</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-2" 
        test="matches(replace(.,'&quot;',''),'\.$|\?$')" 
        role="error" 
        id="fig-title-test-2">title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-3" 
        test="matches(.,' vs\.$')" 
        role="warning" 
        id="fig-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-4" 
        test="matches(.,'^\s')" 
        role="error" 
        id="fig-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-5" 
        test="matches(.,'^\p{P}')" 
        role="warning" 
        id="fig-title-test-5">title for <value-of select="$label"/> begins with punctuation. Is this correct? - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-6" 
        test="matches(.,'^[Pp]anel ')" 
        role="warning" 
        id="fig-title-test-6">title for <value-of select="$label"/> begins with '<value-of select="substring-before(.,' ')"/>' - <value-of select="."/>. It is very likely that this requires an overall title instead.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-7" 
        test="string-length(.) gt 250" 
        role="warning" 
        id="fig-title-test-7">title for <value-of select="$label"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-title-test-8" 
        test="$sentence-count gt 1" 
        role="warning" 
        id="fig-title-test-8">title for <value-of select="$label"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
    </rule>
    
    <rule context="supplementary-material/caption/title" id="supplementary-material-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label[1]"/>
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\s ]$',''),'\. '))"/>
      
      <report test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" 
        role="warning" 
        id="supplementary-material-title-test-1">'<value-of select="$label"/>' appears to have a title which is the beginning of a caption. Is this correct?</report>
      
      <assert test="matches(.,'\.$')" 
        role="error" 
        id="supplementary-material-title-test-2">title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report test="matches(.,' vs\.$')" 
        role="warning" 
        id="supplementary-material-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\s')" 
        role="error" 
        id="supplementary-material-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
      
      <report test="contains(lower-case(.),'key resource table')" 
        role="warning" 
        id="supplementary-material-title-test-5">title for <value-of select="$label"/> is '<value-of select="."/>' - should 'resource' be plural, i.e. 'resources'?.</report>
      
      <report test="(normalize-space(lower-case(.))='key resources table.') and not(contains($label,'upplementary'))" 
        role="warning" 
        id="supplementary-material-title-test-6">title for <value-of select="$label"/> is '<value-of select="."/>', which suggest the label should be in the format Supplementary file X instead.</report>
      
      <report test="string-length(.) gt 250" 
        role="warning" 
        id="supplementary-material-title-test-7">title for <value-of select="$label"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report test="$sentence-count gt 1" 
        role="warning" 
        id="supplementary-material-title-test-8">title for <value-of select="$label"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
    </rule>
    
    <rule context="media/caption/title" id="video-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label[1]"/>
      <let name="sentence-count" value="count(tokenize(replace(replace(lower-case(.),$org-regex,''),'[\s ]$',''),'\. '))"/>
      
      <report test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" 
        role="warning" 
        id="video-title-test-1">'<value-of select="$label"/>' appears to have a title which is the beginning of a caption. Is this correct?</report>
      
      <assert test="matches(.,'\.$|\?$')" 
        role="error" 
        id="video-title-test-2">title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report test="matches(.,' vs\.$')" 
        role="warning" 
        id="video-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\s')" 
        role="error" 
        id="video-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
      
      <report test="string-length(.) gt 250" 
        role="warning" 
        id="video-title-test-7">title for <value-of select="$label"/> is longer than 250 characters. Is it a caption instead?</report>
      
      <report test="$sentence-count gt 1" 
        role="warning" 
        id="video-title-test-8">title for <value-of select="$label"/> contains <value-of select="$sentence-count"/> sentences. Should the sentence(s) after the first be moved into the caption? Or is the title itself a caption (in which case, please ask the authors for a title)?</report>
    </rule>
    
    <rule context="ack" id="ack-title-tests">
      
      <assert test="title = 'Acknowledgements'" 
        role="error" 
        id="ack-title-test">ack must have a title that contains 'Acknowledgements'. Currently it is '<value-of select="title"/>'.</assert>
      
      <assert test="p[* or not(normalize-space(.)='')]" 
        role="error" 
        id="ack-content-test">An Acknowledgements section must contain content. Either add in the missing content or delete the Acknowledgements.</assert>
      
    </rule>
    
    <rule context="ack//p" id="ack-content-tests">
      <let name="hit" value="string-join(for $x in tokenize(.,' ') return
        if (matches($x,'^[A-Z]{1}\.$')) then $x
        else (),', ')"/>
      <let name="hit-count" value="count(for $x in tokenize(.,' ') return
        if (matches($x,'^[A-Z]{1}\.$')) then $x
        else ())"/>
      
      <report test="matches(.,' [A-Z]\. |^[A-Z]\. ')" 
        role="warning" 
        id="ack-full-stop-intial-test">p element in Acknowledgements contains what looks like <value-of select="$hit-count"/> initial(s) followed by a full stop. Is it correct? - <value-of select="$hit"/></report>
      
    </rule>
    
    <rule context="ref-list" id="ref-list-title-tests">
      <let name="cite-list" value="e:ref-cite-list(.)"/>
      <let name="non-distinct" value="e:non-distinct-citations($cite-list)"/>
      
      <assert test="title = 'References'" 
        role="warning" 
        id="ref-list-title-test">reference list usually has a title that is 'References', but currently it is '<value-of select="title"/>' - is that correct?</assert>
      
      <report test="$non-distinct//*:item" 
        role="error" 
        id="ref-list-distinct-1">In the reference list, each reference must be unique in its citation style (combination of authors and year). If a reference's citation is the same as anothers, a lowercase letter should be suffixed to the year (e.g. Smith et al., 2020a). <value-of select="string-join(for $x in $non-distinct//*:item return concat($x,' with the id ',$x/@id),' and ')"/> does not meet this requirement.</report>
      
    </rule>
    
    <rule context="app/title" id="app-title-tests">
      
      <assert test="matches(.,'^Appendix$|^Appendix [0-9]$|^Appendix [0-9][0-9]$')" 
        role="error" 
        id="app-title-test">app title must be in the format 'Appendix 1'. Currently it is '<value-of select="."/>'.</assert>
      
    </rule>
    
    <rule context="fn-group[@content-type='competing-interest']" id="comp-int-title-tests">
      
      <assert test="title = 'Competing interests'" 
        role="error" 
        id="comp-int-title-test">fn-group[@content-type='competing-interests'] must have a title that contains 'Competing interests'. Currently it is '<value-of select="title"/>'.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='author-contribution']" id="auth-cont-title-tests">
      
      <assert test="title = 'Author contributions'" 
        role="error" 
        id="auth-cont-title-test">fn-group[@content-type='author-contribution'] must have a title that contains 'Author contributions'. Currently it is '<value-of select="title"/>'.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='ethics-information']" id="ethics-title-tests">
      
      <assert test="title = 'Ethics'" 
        role="error" 
        id="ethics-title-test">fn-group[@content-type='ethics-information'] must have a title that contains 'Ethics'. Currently it is '<value-of select="title"/>'.</assert>
      
      <report test="matches(.,'&amp;#x\d')" 
        role="warning" 
        id="ethics-broken-unicode-test">Ethics statement likely contains a broken unicode - <value-of select="."/>.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/title-group" id="dec-letter-title-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-title-test" 
        test="article-title = 'Decision letter'" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-title-test">title-group must contain article-title which contains 'Decision letter'. Currently it is <value-of select="article-title"/>.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/front-stub/title-group" id="reply-title-tests">
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-title-test" 
        test="article-title = 'Author response'" 
        role="error" 
        flag="dl-ar"
        id="reply-title-test">title-group must contain article-title which contains 'Author response'. Currently it is <value-of select="article-title"/>.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="id-conformance">
    
    <rule context="article-meta//contrib[@contrib-type='author']" id="author-contrib-ids">
      
      <report test="if (collab) then ()
        else if (ancestor::collab) then ()
        else not(matches(@id,'^[a-z]+-[0-9]+$'))" 
        role="error" 
        id="author-id-1">contrib[@contrib-type="author"] must have an @id which is an alpha-numeric string. <value-of select="@id"/> does not conform to this.</report>
    </rule>
    
    <rule context="funding-group/award-group" id="award-group-ids">
      
      <assert test="matches(substring-after(@id,'fund'),'^[0-9]{1,2}$')" 
        role="error" 
        id="award-group-test-1">award-group must have an @id, the value of which conforms to the convention 'fund', followed by a digit. <value-of select="@id"/> does not conform to this.</assert>
    </rule>
    
    <rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]" id="fig-ids">
      
      <!-- Needs updating once scheme/checmical structure ids have been updated -->
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-id-test-1" 
        test="matches(@id,'^fig[0-9]{1,3}$|^C[0-9]{1,3}$|^S[0-9]{1,3}$')" 
        role="error" 
        id="fig-id-test-1">fig must have an @id in the format fig0 (or C0 for chemical structures, or S0 for Schemes). <value-of select="@id"/> does not conform to this.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-id-test-2" 
        test="matches(label[1],'[Ff]igure') and not(matches(@id,'^fig[0-9]{1,3}$'))" 
        role="error" 
        id="fig-id-test-2">fig must have an @id in the format fig0. <value-of select="@id"/> does not conform to this.</report>
      
      <!--<report test="matches(label[1],'[Cc]hemical [Ss]tructure') and not(matches(@id,'^chem[0-9]{1,3}$'))" 
        role="warning"
        id="fig-id-test-3">Chemical structures must have an @id in the format chem0.</report>-->
      
      <!--<report test="matches(label[1],'[Ss]cheme') and not(matches(@id,'^scheme[0-9]{1,3}$'))" 
        role="warning"
        id="fig-id-test-4">Schemes must have an @id in the format scheme0. <value-of select="@id"/> does not conform to this.</report>-->
    </rule>
    
    <rule context="article/body//fig[@specific-use='child-fig'][not(ancestor::boxed-text)]" id="fig-sup-ids">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#fig-sup-id-test" 
        test="matches(@id,'^fig[0-9]{1,3}s[0-9]{1,3}$')" 
        role="error" 
        id="fig-sup-id-test">figure supplement must have an @id in the format fig0s0. <value-of select="@id"/> does not conform to this.</assert>
    </rule>
    
    <rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]" id="box-fig-ids">
      <let name="box-id" value="ancestor::boxed-text/@id"/> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#box-fig-id-1" 
        test="matches(@id,'^box[0-9]{1,3}fig[0-9]{1,3}$')" 
        role="error" 
        id="box-fig-id-1">fig must have @id in the format box0fig0. <value-of select="@id"/> does not conform to this.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#box-fig-id-2" 
        test="contains(@id,$box-id)" 
        role="error" 
        id="box-fig-id-2">fig id (<value-of select="@id"/>) does not contain its ancestor boxed-text id. Please ensure the first part of the id contains '<value-of select="$box-id"/>'.</assert>
    </rule>
    
    <rule context="article/back//app//fig[not(@specific-use='child-fig')]" id="app-fig-ids">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-id-test-1" 
        test="matches(label[1],'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix [A-Z]—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$') and not(matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}$'))" 
        role="error" 
        id="app-fig-id-test-1">figures in appendices must have an @id in the format app0fig0. <value-of select="@id"/> does not conform to this.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-id-test-2" 
        test="matches(label[1],'[Cc]hemical [Ss]tructure') and not(matches(@id,'^app[0-9]{1,3}chem[0-9]{1,3}$'))" 
        role="warning" 
        id="app-fig-id-test-2">Chemical structures must have an @id in the format app0chem0. <value-of select="@id"/> does not conform to this.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-id-test-3"
        test="matches(label[1],'[Ss]cheme') and not(matches(@id,'^app[0-9]{1,3}scheme[0-9]{1,3}$'))" 
        role="warning" 
        id="app-fig-id-test-3">Schemes must have an @id in the format app0scheme0. <value-of select="@id"/> does not conform to this.</report>
    </rule>
    
    <rule context="article/back//app//fig[@specific-use='child-fig']" id="app-fig-sup-ids">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#app-fig-sup-id-test" 
        test="matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}s[0-9]{1,3}$')" 
        role="error" 
        id="app-fig-sup-id-test">figure supplements in appendices must have an @id in the format app0fig0s0. <value-of select="@id"/> does not conform to this.</assert>
    </rule>
    
    <rule context="sub-article//fig[not(@specific-use='child-fig')]" id="rep-fig-ids">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-id-test" 
        test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')" 
        role="error" 
        flag="dl-ar"
        id="resp-fig-id-test">fig in decision letter/author response must have @id in the format respfig0, or sa0fig0. <value-of select="@id"/> does not conform to this.</assert>
    </rule>
    
    <rule context="sub-article//fig[@specific-use='child-fig']" id="rep-fig-sup-ids">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-sup-id-test" 
        test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')" 
        role="error" 
        flag="dl-ar"
        id="resp-fig-sup-id-test">figure supplement in decision letter/author response must have @id in the format respfig0s0 or sa0fig0s0. <value-of select="@id"/> does not conform to this.</assert>
      
    </rule>
    
    <rule context="article/body//media[(@mimetype='video') and not(ancestor::boxed-text) and not(parent::fig-group)]" id="video-ids">
      
      <assert test="matches(@id,'^video[0-9]{1,3}$')" 
        role="error" 
        id="video-id-test">main video must have an @id in the format video0.  <value-of select="@id"/> does not conform to this.</assert>
    </rule>
    
    <rule context="article/body//fig-group/media[(@mimetype='video') and not(ancestor::boxed-text)]" id="video-sup-ids">
      <let name="id-prefix" value="parent::fig-group/fig[1]/@id"/>
      
      <assert test="matches(@id,'^fig[0-9]{1,3}video[0-9]{1,3}$')" 
        role="error" 
        id="video-sup-id-test-1">video supplement must have an @id in the format fig0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,$id-prefix)" 
        role="error" 
        id="video-sup-id-test-2">video supplement must have an @id which begins with the id of its parent fig. <value-of select="@id"/> does not start with <value-of select="$id-prefix"/>.</assert>
    </rule>
    
    <rule context="article/back//app//media[(@mimetype='video') and not(parent::fig-group)]" id="app-video-ids">
      <let name="id-prefix" value="substring-after(ancestor::app[1]/@id,'-')"/>
      
      <assert test="matches(@id,'^app[0-9]{1,3}video[0-9]{1,3}$')" 
        role="error" 
        id="app-video-id-test-1">video in appendix must have an @id in the format app0video0. <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,concat('app',$id-prefix))" 
        role="error" 
        id="app-video-id-test-2">video supplement must have an @id which begins with the id of its ancestor appendix. <value-of select="@id"/> does not start with <value-of select="concat('app',$id-prefix)"/>.</assert>
    </rule>
    
    <rule context="article/back//app//media[(@mimetype='video') and (parent::fig-group)]" id="app-video-sup-ids">
      <let name="id-prefix-1" value="substring-after(ancestor::app[1]/@id,'-')"/>
      <let name="id-prefix-2" value="parent::fig-group/fig[1]/@id"/>
      
      <assert test="matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}video[0-9]{1,3}$')" 
        role="error" 
        id="app-video-sup-id-test-1">video supplement must have an @id in the format app0fig0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,concat('app',$id-prefix-1))" 
        role="error" 
        id="app-video-sup-id-test-2">video supplement must have an @id which begins with the id of its ancestor appendix. <value-of select="@id"/> does not start with <value-of select="concat('app',$id-prefix-1)"/>.</assert>
      
      <assert test="starts-with(@id,$id-prefix-2)" 
        role="error" 
        id="app-video-sup-id-test-3">video supplement must have an @id which begins with the id of its ancestor appendix, followed by id of its parent fig. <value-of select="@id"/> does not start with <value-of select="$id-prefix-2"/>.</assert>
    </rule>
    
    <rule context="article/body//boxed-text//media[(@mimetype='video')]" id="box-vid-ids">
      <let name="box-id" value="ancestor::boxed-text/@id"/> 
      
      <assert test="matches(@id,'^box[0-9]{1,3}video[0-9]{1,3}$')" 
        role="error" 
        id="box-vid-id-1">video must have @id in the format box0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,$box-id)" 
        role="error" 
        id="box-vid-id-2">video id does not start with its ancestor boxed-text id. Please ensure the first part of the id contains '<value-of select="$box-id"/>'.</assert>
    </rule>
    
    <rule context="related-article" id="related-articles-ids">
      
      <assert test="matches(@id,'^ra\d$')" 
        role="error" 
        id="related-articles-test-7">related-article element must contain a @id, the value of which should be in the form ra0.</assert>
    </rule>
    
    <rule context="aff[not(parent::contrib)]" id="aff-ids">
      
      <assert test="if (label) then @id = concat('aff',label[1])
        else starts-with(@id,'aff')" 
        role="error" 
        id="aff-id-test">aff @id must be a concatenation of 'aff' and the child label value. In this instance it should be <value-of select="concat('aff',label[1])"/>.</assert>
    </rule>
    
    <!-- @id for fn[parent::table-wrap-foot] not accounted for -->
    <rule context="fn" id="fn-ids">
      <let name="type" value="@fn-type"/>
      <let name="parent" value="self::*/parent::*/local-name()"/>
      
      <report test="if ($parent = 'table-wrap-foot') then ()
        else if ($type = 'conflict') then not(matches(@id,'^conf[0-9]{1,3}$'))
        else if ($type = 'con') then
        if ($parent = 'author-notes') then not(matches(@id,'^equal-contrib[0-9]{1,3}$'))
        else not(matches(@id,'^con[0-9]{1,3}$'))
        else if ($type = 'present-address') then not(matches(@id,'^pa[0-9]{1,3}$'))
        else if ($type = 'COI-statement') then not(matches(@id,'^conf[0-9]{1,3}$'))
        else if ($type = 'fn') then not(matches(@id,'^fn[0-9]{1,3}$'))
        else ()" 
        role="error" 
        id="fn-id-test">fn @id is not in the correct format. Refer to eLife kitchen sink for correct format.</report>
    </rule>
    
    <rule context="disp-formula" id="disp-formula-ids">
      
      <report test="not(ancestor::sub-article) and not(matches(@id,'^equ[0-9]{1,9}$'))" 
        role="error" 
        id="disp-formula-id-test">disp-formula @id must be in the format 'equ0'.</report>
      
      <report test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))" 
        role="error" 
        flag="dl-ar"
        id="sub-disp-formula-id-test">disp-formula @id must be in the format 'sa0equ0' when in a sub-article.  <value-of select="@id"/> does not conform to this.</report>
    </rule>
    
    <rule context="disp-formula/mml:math" id="mml-math-ids">
      
      <report test="not(ancestor::sub-article) and not(matches(@id,'^m[0-9]{1,9}$'))" 
        role="error" 
        id="mml-math-id-test">mml:math @id in disp-formula must be in the format 'm0'.  <value-of select="@id"/> does not conform to this.</report>
      
      <report test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))" 
        role="error" 
        flag="dl-ar"
        id="sub-mml-math-id-test">mml:math @id in disp-formula must be in the format 'sa0m0'.  <value-of select="@id"/> does not conform to this.</report>
    </rule>
    
    <rule context="app//table-wrap[label]" id="app-table-wrap-ids">
      <let name="app-no" value="substring-after(ancestor::app[1]/@id,'-')"/>
    
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#app-table-wrap-id-test-1" 
        test="matches(@id, '^app[0-9]{1,3}table[0-9]{1,3}$|^keyresource$')" 
        role="error" 
        id="app-table-wrap-id-test-1">table-wrap @id in appendix must be in the format 'app0table0' for normal tables, or 'keyresource' for key resources tables in appendices. <value-of select="@id"/> does not conform to this.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#app-table-wrap-id-test-2" 
        test="not(@id='keyresource') and not(starts-with(@id, concat('app' , $app-no)))" 
        role="error" 
        id="app-table-wrap-id-test-2">table-wrap @id must start with <value-of select="concat('app' , $app-no)"/>.</report>
    </rule>
    
    <rule context="sub-article//table-wrap" id="resp-table-wrap-ids">
 
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#resp-table-wrap-id-test" 
        test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$')
        else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')" 
        role="warning" 
        flag="dl-ar"
        id="resp-table-wrap-id-test">table-wrap @id in author reply must be in the format 'resptable0' or 'sa0table0' if it has a label, or in the format 'respinlinetable0' or 'sa0inlinetable0' if it does not.</assert>
    </rule>
    
    <rule context="article//table-wrap[not(ancestor::app) and not(ancestor::sub-article[@article-type='reply'])]" id="table-wrap-ids">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#table-wrap-id-test" 
        test="if (label = 'Key resources table') then @id='keyresource'
        else if (label) then matches(@id, '^table[0-9]{1,3}$')
        else matches(@id, '^inlinetable[0-9]{1,3}$')" 
        role="error" 
        id="table-wrap-id-test">table-wrap @id must be in the format 'table0', unless it doesn't have a label, in which case it must be 'inlinetable0' or it is the key resource table which must be 'keyresource'.</assert>
    </rule>
    
    <rule context="article/body/sec" id="body-top-level-sec-ids">
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
    
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#body-top-level-sec-id-test"
        test="@id = concat('s',$pos)" 
        role="error" 
        id="body-top-level-sec-id-test">This sec id must be a concatenation of 's' and this element's position relative to its siblings. It must be <value-of select="concat('s',$pos)"/>.</assert>
      </rule>
    
    <rule context="article/back/sec" id="back-top-level-sec-ids">
      <let name="pos" value="count(ancestor::article/body/sec) + count(parent::back/sec) - count(following-sibling::sec)"/>
      
      <assert test="@id = concat('s',$pos)" 
        role="error" 
        id="back-top-level-sec-id-test">This sec id must be a concatenation of 's' and this element's position relative to other top level secs. It must be <value-of select="concat('s',$pos)"/>.</assert>
    </rule>
    
    <rule context="article/body/sec//sec|article/back/sec//sec" id="low-level-sec-ids">
      <let name="parent-sec" value="parent::sec/@id"/>
      <let name="pos" value="count(parent::sec/sec) - count(following-sibling::sec)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#low-level-sec-id-test"
        test="@id = concat($parent-sec,'-',$pos)" 
        role="error" 
        id="low-level-sec-id-test">sec id must be a concatenation of its parent sec id and this element's position relative to its sibling secs. It must be <value-of select="concat($parent-sec,'-',$pos)"/>.</assert>
    </rule>
    
    <rule context="app" id="app-ids">
      <let name="pos" value="string(count(ancestor::article//app) - count(following::app))"/>
      
      <assert test="matches(@id,'^appendix-[0-9]{1,3}$')" 
        role="error" 
        id="app-id-test-1">app id must be in the format 'appendix-0'. <value-of select="@id"/> is not in this format.</assert>
      
      <assert test="substring-after(@id,'appendix-') = $pos" 
        role="error" 
        id="app-id-test-2">app id is <value-of select="@id"/>, but relative to other appendices it is in position <value-of select="$pos"/>.</assert>
    </rule>
  </pattern>
  
  <pattern id="child-conformance">
    
    <rule context="fig/*" id="fig-children">
      <let name="allowed-children" value="('label', 'caption', 'graphic', 'permissions', 'attrib')"/>
      
      <assert test="local-name() = $allowed-children" 
        role="error" 
        id="fig-child-conformance"><name/> is not allowed as a child of fig.</assert>
    </rule>
    
    <rule context="table-wrap/*" id="table-wrap-children">
      <let name="allowed-children" value="('label', 'caption', 'table', 'permissions', 'table-wrap-foot')"/>
      
      <assert test="local-name() = $allowed-children" 
        role="error" 
        id="table-wrap-child-conformance"><name/> is not allowed as a child of table-wrap.</assert>
    </rule>
    
    <rule context="media/*" id="media-children">
      <let name="allowed-children" value="('label', 'caption', 'permissions', 'attrib')"/>
      
      <assert test="local-name() = $allowed-children" 
        role="error" 
        id="media-child-conformance"><name/> is not allowed as a child of media.</assert>
    </rule>
    
    <rule context="supplementary-material/*" id="supplementary-material-children">
      <let name="allowed-children" value="('label', 'caption', 'media', 'permissions')"/>
      
      <assert test="local-name() = $allowed-children" 
        role="error" 
        id="supplementary-material-child-conformance"><name/> is not allowed as a child of supplementary-material.</assert>
    </rule>
    
    <rule context="author-notes/*" id="author-notes-children">
      
      <assert test="local-name() = 'fn'" 
        role="error" 
        id="author-notes-child-conformance"><name/> is not allowed as a child of author-notes.</assert>
    </rule>
    
  </pattern>
  
  <pattern id="sec-specific">
    
    <rule context="sec" id="sec-tests">
      <let name="child-count" value="count(p) + count(sec) + count(fig) + count(fig-group) + count(media) + count(table-wrap) + count(boxed-text) + count(list) + count(fn-group) + count(supplementary-material) + count(related-object)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-test-1"
        test="title" 
        role="error" 
        id="sec-test-1">sec must have a title</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-test-2"
        test="$child-count gt 0" 
        role="error" 
        id="sec-test-2">sec appears to contain no content. This cannot be correct.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-test-5" 
        test="count(ancestor::sec) ge 5" 
        role="error" 
        id="sec-test-5">Level <value-of select="count(ancestor::sec) + 1"/> sections are not allowed. Please either make this a level 5 heading, or capture the title as a bolded paragraph in its parent section.</report>
    </rule>
    
    <rule context="article[@article-type='research-article']//sec[not(@sec-type) and not(matches(.,'[Gg]ithub|[Gg]itlab|[Cc]ode[Pp]lex|[Ss]ource[Ff]orge|[Bb]it[Bb]ucket'))]" id="res-data-sec">
      <let name="title" value="lower-case(title[1])"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#sec-test-3" 
        test="contains($title,'data') and (contains($title,'availability') or contains($title,'code') or contains($title,'accessib') or contains($title,'statement'))" 
        role="warning" 
        id="sec-test-3">Section has a title '<value-of select="title[1]"/>'. Is it a duplicate of the data availability section (and therefore should be removed)?</report>
      
    </rule>
    
    <rule context="article[@article-type='research-article']//sec[not(descendant::xref[@ref-type='bibr'])]" id="res-ethics-sec">
      
      <report test="matches(lower-case(title[1]),'^ethics| ethics$| ethics ')" 
        role="warning" 
        id="sec-test-4">Section has a title '<value-of select="title[1]"/>'. Is it a duplicate of, or very similar to, the ethics statement (in the article details page)? If so, it should be removed. If not, then which statement is correct? The one in this section or '<value-of select="string-join(
        ancestor::article//fn-group[@content-type='ethics-information']/fn
        ,' '
        )"/>'?</report>
      
    </rule>
  </pattern>
  
  <pattern id="back">
    
    <rule context="back" id="back-tests">
      <let name="article-type" value="parent::article/@article-type"/>
      <let name="subj-type" value="parent::article//subj-group[@subj-group-type='display-channel']/subject"/>
      <let name="pub-date" value="e:get-iso-pub-date(self::*)"/>
      
      <report test="if ($article-type = ($features-article-types,'retraction','correction')) then ()
        else count(sec[@sec-type='additional-information']) != 1" 
        role="error" 
        id="back-test-1">One and only one sec[@sec-type="additional-information"] must be present in back.</report>
      
      <report test="count(sec[@sec-type='supplementary-material']) gt 1" 
        role="error" 
        id="back-test-2">More than one sec[@sec-type="supplementary-material"] cannot be present in back.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#back-test-3" 
        test="($article-type='research-article') and ($subj-type != 'Scientific Correspondence') and ( not($pub-date) or ($pub-date gt '2018-05-31')) and (count(sec[@sec-type='data-availability']) != 1)" 
        role="error" 
        id="back-test-3">One and only one Data availability section (sec[@sec-type="data-availability"]) must be present (as a child of back) for '<value-of select="$article-type"/>'.</report>
      
      <report test="($article-type='research-article') and ($subj-type != 'Scientific Correspondence') and ($pub-date le '2018-05-31') and (count(sec[@sec-type='data-availability']) != 1)" 
        role="warning" 
        id="back-test-10">One and only one Data availability section (sec[@sec-type="data-availability"]) should be present (as a child of back) for '<value-of select="$article-type"/>'. Is this a new version which was published first without one? If not, then it certainly needs adding.</report>
      
      <report test="count(ack) gt 1" 
        role="error" 
        id="back-test-4">One and only one ack may be present in back.</report>
      
      <report test="if ($article-type = ('research-article','article-commentary')) then (count(ref-list) != 1)
        else ()" 
        role="error" 
        id="back-test-5">One and only one ref-list must be present in <value-of select="$article-type"/> content.</report>
      
      <report test="count(app-group) gt 1" 
        role="error" 
        id="back-test-6">One and only one app-group may be present in back.</report>
      
      <report test="if ($article-type = ($features-article-types,'retraction','correction')) then ()
        else if ($subj-type = 'Scientific Correspondence') then ()
        else (not(ack))" 
        role="warning" 
        id="back-test-8">'<value-of select="$article-type"/>' usually have acknowledgement sections, but there isn't one here. Is this correct?</report>
      
      <report test="($article-type = $features-article-types) and (count(fn-group[@content-type='competing-interest']) != 1)" 
        role="error" 
        id="back-test-7">An fn-group[@content-type='competing-interest'] must be present as a child of back <value-of select="$subj-type"/> content.</report>
      
      <report test="($article-type = 'research-article') and (count(sec[@sec-type='additional-information']/fn-group[@content-type='competing-interest']) != 1)" 
        role="error" 
        id="back-test-9">One and only one fn-group[@content-type='competing-interest'] must be present in back as a child of sec[@sec-type="additional-information"] in <value-of select="$subj-type"/> content.</report>
      
      <report test="($article-type = 'research-article') and (count(sec[@sec-type='additional-information']/fn-group[@content-type='author-contribution']) != 1)" 
        role="error" 
        id="back-test-12">One and only one fn-group[@content-type='author-contribution'] must be present in back as a child of sec[@sec-type="additional-information"] in <value-of select="$subj-type"/> content.</report>
      
      <report test="($article-type = ('article-commentary', 'editorial', 'book-review', 'discussion')) and sec[@sec-type='additional-information']" 
        role="error" 
        id="back-test-11"><value-of select="$article-type"/> type articles cannot contain additional information sections (sec[@sec-type="additional-information"]).</report>
      
    </rule>
    
    <!-- Included as a separate rule so that it won't be flagged in features content -->
    <rule context="back/sec[@sec-type='data-availability']" id="data-content-tests">
      
      <assert test="count(p) gt 0" 
        role="error" 
        id="data-p-presence">At least one p element must be present in sec[@sec-type='data=availability'].</assert>
    </rule>
    
    <rule context="back/ack" id="ack-tests">
      
      <assert test="count(title) = 1" 
        role="error" 
        id="ack-test-1">ack must have only 1 title.</assert>
    </rule>
    
    <rule context="back/ack/*" id="ack-child-tests">
    
      <assert test="local-name() = ('p','sec','title')" 
        role="error" 
        id="ack-child-test-1">Only p, sec or title can be children of ack. <name/> is not allowed.</assert>
    </rule>
    
    <rule context="back//app" id="app-tests">
      
      <assert test="parent::app-group" 
        role="error" 
        id="app-test-1">app must be captured as a child of an app-group element.</assert>
      
      <assert test="count(title) = 1" 
        role="error" 
        id="app-test-2">app must have one title.</assert>
    </rule>
    
    <rule context="sec[@sec-type='additional-information']" id="additional-info-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="author-count" value="count(ancestor::article//article-meta//contrib[@contrib-type='author'])"/>
      <let name="non-contribs" value="('article-commentary', 'editorial', 'book-review', 'correction', 'retraction', 'review-article')"/>
      
      <assert test="parent::back" 
        role="error" 
        id="additional-info-test-1">sec[@sec-type='additional-information'] must be a child of back.</assert>
      
      <!-- Exception for article with no authors -->
      <report test="if ($author-count = 0) then ()
        else not(fn-group[@content-type='competing-interest'])" 
        role="error" 
        id="additional-info-test-2">This type of sec must have a child fn-group[@content-type='competing-interest'].</report>
      
      <report test="if ($article-type = 'research-article') then (not(fn-group[@content-type='author-contribution']))
        else ()" 
        role="error" 
        id="final-additional-info-test-3">Missing author contributions. This type of sec in research content must have a child fn-group[@content-type='author-contribution'].</report>
      
      <report test="if ($article-type = 'research-article') then (not(fn-group[@content-type='author-contribution']))
        else ()" 
        role="warning" 
        id="pre-additional-info-test-3">Missing author contributions. Please ensure that this is raised with eLife staff/the authors. (This type of sec in research content must have a child fn-group[@content-type='author-contribution']).</report>
      
      <report test="$article-type=$non-contribs and fn-group[@content-type='author-contribution']" 
        role="error" 
        id="additional-info-test-4"><value-of select="$article-type"/> type articles should not contain author contributions.</report>
      
    </rule>
    
    <rule context="fn-group[@content-type='competing-interest']" id="comp-int-fn-group-tests">
      
      <assert test="count(fn) gt 0" 
        role="error" 
        id="comp-int-fn-test-1">At least one child fn element should be present in fn-group[@content-type='competing-interest'].</assert>
      
      <assert test="ancestor::back" 
        role="error" 
        id="comp-int-fn-group-test-1">This fn-group must be a descendant of back.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='competing-interest']/fn" id="comp-int-fn-tests">
      
      <assert test="@fn-type='COI-statement'" 
        role="error" 
        id="comp-int-fn-test-2">fn element must have an @fn-type='COI-statement' as it is a child of fn-group[@content-type='competing-interest'].</assert>
      
    </rule>
    
    <rule context="fn-group[@content-type='author-contribution']/fn" id="auth-cont-fn-tests">
      
      <assert test="@fn-type='con'" 
        role="error" 
        id="auth-cont-fn-test-1">This fn must have an @fn-type='con'.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='ethics-information']" id="ethics-tests">
      
      <!-- Exclusion included for Feature 5 -->
      <report test="ancestor::article[not(@article-type='discussion')] and not(parent::sec[@sec-type='additional-information'])" 
        role="error" 
        id="ethics-test-1">Ethics fn-group can only be captured as a child of a sec [@sec-type='additional-information']</report>
 
      <report test="count(fn) gt 3" 
        role="error" 
        id="ethics-test-2">Ethics fn-group may not have more than 3 fn elements. Currently there are <value-of select="count(fn)"/>.</report>
      
      <report test="count(fn) = 0" 
        role="error" 
        id="ethics-test-3">Ethics fn-group must have at least one fn element.</report>
    </rule>
    
    <rule context="fn-group[@content-type='ethics-information']/fn" id="ethics-fn-tests">
      
      <assert test="@fn-type='other'" 
        role="error" 
        id="ethics-test-4">This fn must have an @fn-type='other'</assert>
      
    </rule>
  </pattern>
  
  <pattern id="dec-letter-auth-response">
    
    <rule context="article/sub-article" id="dec-letter-reply-tests">
      <let name="pos" value="count(parent::article/sub-article) - count(following-sibling::sub-article)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-1" 
        test="if ($pos = 1) then @article-type='decision-letter'
        else @article-type='reply'" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reply-test-1">1st sub-article must be the decision letter. 2nd sub-article must be the author response.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-2" 
        test="@id = concat('sa',$pos)" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reply-test-2">sub-article id must be in the format 'sa0', where '0' is its position (1 or 2).</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-3" 
        test="count(front-stub) = 1" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reply-test-3">sub-article must contain one and only one front-stub.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-4" 
        test="count(body) = 1" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reply-test-4">sub-article must contain one and only one body.</assert>
      
    </rule>
    
    
    <rule context="article/sub-article//p" id="dec-letter-reply-content-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-5" 
        test="matches(.,'&lt;[/]?[Aa]uthor response')" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reply-test-5"><value-of select="ancestor::sub-article/@article-type"/> paragraph contains what looks like pseudo-code - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-6" 
        test="matches(.,'&lt;\s?/?\s?[a-z]*\s?/?\s?&gt;')" 
        role="warning" 
        flag="dl-ar"
        id="dec-letter-reply-test-6"><value-of select="ancestor::sub-article/@article-type"/> paragraph contains what might be pseudo-code or tags which should likely be removed - <value-of select="."/>.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub" id="dec-letter-front-tests">
      <let name="count" value="count(contrib-group)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-1" 
        test="count(article-id[@pub-id-type='doi']) = 1" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-2" 
        test="$count gt 0" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-front-test-2">decision letter front-stub must contain at least 1 contrib-group element.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-3" 
        test="$count gt 2" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-front-test-3">decision letter front-stub contains more than 2 contrib-group elements.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-4" 
        test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'The reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/|doi.org/10.24072/pci.evolbiol')])" 
        role="warning" 
        flag="dl-ar"
        id="dec-letter-front-test-4">decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviewing editor) anonymous? The text 'The reviewers have opted to remain anonymous' or 'The reviewer has opted to remain anonymous' is not present and there is no link to Review commons or a Peer Community in Evolutionary Biology doi in the decision letter.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]" id="dec-letter-editor-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-1" 
        test="count(contrib[@contrib-type='editor']) = 1" 
        role="warning" 
        flag="dl-ar"
        id="dec-letter-editor-test-1">First contrib-group in decision letter must contain 1 and only 1 editor (contrib[@contrib-type='editor']).</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-2" 
        test="contrib[not(@contrib-type) or @contrib-type!='editor']" 
        role="warning" 
        flag="dl-ar"
        id="dec-letter-editor-test-2">First contrib-group in decision letter contains a contrib which is not marked up as an editor (contrib[@contrib-type='editor']).</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]/contrib[@contrib-type='editor']" id="dec-letter-editor-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role[1]"/>
      <!--<let name="top-role" value="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[e:get-name(name[1])=$name]/role"/>-->
      <!--<let name="top-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[role=$role]/name[1])"/>-->
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-3" 
        test="$role=('Reviewing Editor','Senior and Reviewing Editor')" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-editor-test-3">Editor in decision letter front-stub must have the role 'Reviewing Editor' or 'Senior and Reviewing Editor'. <value-of select="$name"/> has '<value-of select="$role"/>'.</assert>
      
      <!--<report test="($top-name!='') and ($top-name!=$name)"
        role="error"
        id="dec-letter-editor-test-5">In decision letter <value-of select="$name"/> is a <value-of select="$role"/>, but in the top-level article details <value-of select="$top-name"/> is the <value-of select="$role"/>.</report>-->
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]" id="dec-letter-reviewer-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-1" 
        test="count(contrib[@contrib-type='reviewer']) gt 0" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reviewer-test-1">Second contrib-group in decision letter must contain a reviewer (contrib[@contrib-type='reviewer']).</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-2" 
        test="contrib[not(@contrib-type) or @contrib-type!='reviewer']" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reviewer-test-2">Second contrib-group in decision letter contains a contrib which is not marked up as a reviewer (contrib[@contrib-type='reviewer']).</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-6" 
        test="count(contrib[@contrib-type='reviewer']) gt 5" 
        role="warning" 
        flag="dl-ar"
        id="dec-letter-reviewer-test-6">Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]/contrib[@contrib-type='reviewer']" id="dec-letter-reviewer-tests-2">
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-3" 
        test="role='Reviewer'" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-reviewer-test-3">Reviewer in decision letter front-stub must have the role 'Reviewer'. <value-of select="$name"/> has '<value-of select="role"/>'.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/body" id="dec-letter-body-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-1" 
        test="child::*[1]/local-name() = 'boxed-text'" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-body-test-1">First child element in decision letter is not boxed-text. This is certainly incorrect.</assert>
    </rule>
      
    <rule context="sub-article[@article-type='decision-letter']/body//p" id="dec-letter-body-p-tests">  
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-2" 
        test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-body-test-2">The text 'Review Commons' in '<value-of select="."/>' must contain an embedded link pointing to https://www.reviewcommons.org/.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-3" 
        test="contains(lower-case(.),'reviewed and recommended by peer community in evolutionary biology') and not(child::ext-link[matches(@xlink:href,'doi.org/10.24072/pci.evolbiol')])" 
        role="error" 
        flag="dl-ar"
        id="dec-letter-body-test-3">The decision letter indicates that this article was reviewed by PCI evol bio, but there is no doi link with the prefix '10.24072/pci.evolbiol' which must be incorrect.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']" 
      id="decision-missing-table-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#decision-missing-table-test" 
        test="contains(.,'letter table') and not(descendant::table-wrap[label])"
        role="warning" 
        flag="dl-ar"
        id="decision-missing-table-test">A decision letter table is referred to in the text, but there is no table in the decision letter with a label.</report>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/front-stub" id="reply-front-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-front-test-1" 
        test="count(article-id[@pub-id-type='doi']) = 1" 
        role="error" 
        flag="dl-ar"
        id="reply-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/body" id="reply-body-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-body-test-1" 
        test="count(disp-quote[@content-type='editor-comment']) = 0" 
        role="warning" 
        flag="dl-ar"
        id="reply-body-test-1">author response doesn't contain a disp-quote. This is very likely to be incorrect. Please check the original file.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-body-test-2" 
        test="count(p) = 0" 
        role="error" 
        flag="dl-ar"
        id="reply-body-test-2">author response doesn't contain a p. This has to be incorrect.</report>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/body//disp-quote" id="reply-disp-quote-tests">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-disp-quote-test-1" 
        test="@content-type='editor-comment'" 
        role="warning" 
        flag="dl-ar"
        id="reply-disp-quote-test-1">disp-quote in author reply does not have @content-type='editor-comment'. This is almost certainly incorrect.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/body//p[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests">
      <let name="free-text" value="replace(
        normalize-space(string-join(for $x in self::*/text() return $x,''))
        ,' ','')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-disp-quote-test-1" 
        test="(count(*)=1) and (child::italic) and ($free-text='')" 
        role="warning" 
        flag="dl-ar"
        id="reply-missing-disp-quote-test-1">para in author response is entirely in italics, but not in a display quote. Is this a quote which has been processed incorrectly?</report>
    </rule>
    
    <rule context="sub-article[@article-type='reply']//italic[not(ancestor::disp-quote)]" id="reply-missing-disp-quote-tests-2">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-disp-quote-test-2" 
        test="string-length(.) ge 50" 
        role="warning" 
        flag="dl-ar"
        id="reply-missing-disp-quote-test-2">A long piece of text is in italics in an Author response paragraph. Should it be captured as a display quote in a separate paragraph? '<value-of select="."/>' in '<value-of select="ancestor::*[local-name()='p'][1]"/>'</report>
    </rule>
    
    <rule context="sub-article[@article-type='reply']" 
      id="reply-missing-table-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-table-test" 
        test="contains(.,'response table') and not(descendant::table-wrap[label])"
        role="warning" 
        flag="dl-ar"
        id="reply-missing-table-test">An author response table is referred to in the text, but there is no table in the response with a label.</report>
    </rule>
    
    <rule context="sub-article//ext-link" 
      id="sub-article-ext-link-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#paper-pile-test" 
        test="contains(@xlink:href,'paperpile.com')"
        role="error" 
        flag="dl-ar"
        id="paper-pile-test">In the <value-of select="if (ancestor::sub-article[@article-type='reply']) then 'author response' else 'decision letter'"/> the text '<value-of select="."/>' has an embedded hyperlink to <value-of select="@xlink:href"/>. The hyperlink should be removed (but the text retained).</report>
    </rule>
  </pattern>
  
  <pattern id="related-articles">
    
    <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = 'Research Advance']//article-meta" id="research-advance-test">
      
      <assert test="count(related-article[@related-article-type='article-reference']) gt 0" 
        role="error" 
        id="related-articles-test-1">Research Advance must contain an article-reference link to the original article it is building upon.</assert>
      
    </rule>
    
    <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = 'Insight']//article-meta" id="insight-test">
      
      <assert test="count(related-article[@related-article-type='commentary-article']) gt 0" 
        role="error" 
        id="related-articles-test-2">Insight must contain an article-reference link (related-article[@related-article-type='commentary-article']) to the original article it is discussing.</assert>
      
    </rule>
    
    <rule context="article[@article-type='correction']//article-meta" id="correction-test">
      
      <assert test="count(related-article[@related-article-type='corrected-article']) gt 0" 
        role="error" 
        id="related-articles-test-8">Corrections must contain at least 1 related-article link with the attribute related-article-type='corrected-article'.</assert>
      
    </rule>
    
    <rule context="article[@article-type='retraction']//article-meta" id="retraction-test">
      
      <assert test="count(related-article[@related-article-type='retracted-article']) gt 0" 
        role="error" 
        id="related-articles-test-9">Retractions must contain at least 1 related-article link with the attribute related-article-type='retracted-article'.</assert>
      
    </rule>
    
    <rule context="article[@article-type='research-article']//related-article" id="research-article-ra-test">
      
      <assert test="@related-article-type=('article-reference', 'commentary', 'corrected-article', 'retracted-article')" 
        role="error" 
        id="related-articles-test-12">The only types of related-article link allowed in a research article are 'article-reference' (link to another research article), 'commentary' (link to an insight), 'corrected-article' (link to a correction notice) or 'retracted-article' (link to retraction notice). The link to <value-of select="@xlink:href"/> is a <value-of select="@related-article-type"/> type link.</assert>
      
    </rule>
    
    <rule context="related-article" id="related-articles-conformance">
      <let name="allowed-values" value="('article-reference', 'commentary', 'commentary-article', 'corrected-article', 'retracted-article')"/>
      <let name="article-doi" value="parent::article-meta/article-id[@pub-id-type='doi']"/>
      
      <assert test="@related-article-type" 
        role="error" 
        id="related-articles-test-3">related-article element must contain a @related-article-type.</assert>
      
      <assert test="@related-article-type = $allowed-values" 
        role="error" 
        id="related-articles-test-4">@related-article-type must be equal to one of the allowed values, ('article-reference', 'commentary', 'commentary-article', 'corrected-article', and 'retracted-article').</assert>
      
      <assert test="@ext-link-type='doi'" 
        role="error" 
        id="related-articles-test-5">related-article element must contain a @ext-link-type='doi'.</assert>
      
      <assert test="matches(@xlink:href,'^10\.7554/eLife\.[\d]{5}$')" 
        role="error" 
        id="related-articles-test-6">related-article element must contain a @xlink:href, the value of which should be in the form 10.7554/eLife.00000.</assert>
      
      <report test="@xlink:href = preceding::related-article/@xlink:href" 
        role="error" 
        id="related-articles-test-10">related-article elements must contain a distinct @xlink:href. There is more than 1 related article link for <value-of select="@xlink:href"/>.</report>
      
      <report test="contains(@xlink:href,$article-doi)" 
        role="error" 
        id="related-articles-test-11">An article cannot contain a related-article link to itself - please delete the related article link to <value-of select="@xlink:href"/>.</report>
    </rule>
    
  </pattern>
  
  <pattern id="parent-tests">
    
    <rule context="media[@mimetype='video']" id="video-parent-conformance">
      <let name="parent" value="name(..)"/>
      
      <assert test="$parent = ('sec','fig-group','body','boxed-text','app')" 
        role="error" 
        id="video-parent-test"><value-of select="replace(label[1],'\.$','')"/> is a child of a &lt;<value-of select="$parent"/>&gt; element. It can only be a child of sec, fig-group, body, boxed-text, or app.</assert>
      
    </rule>
  
  </pattern>
  
  <pattern id="element-citation-general-tests">
    
    <rule context="element-citation" id="elem-citation-general">
      
      <report test="descendant::etal" 
        role="error" 
        id="err-elem-cit-gen-name-5">The &lt;etal&gt; element in a reference is not allowed. Reference '<value-of select="ancestor::ref/@id"/>' contains it.</report>
      
      <report test="count(year) > 1 " 
        role="error" 
        id="err-elem-cit-gen-date-1-9">There may be at most one &lt;year&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(year)"/> &lt;year&gt; elements.</report>
      
      <report test="(fpage) and not(lpage)" 
        role="warning" 
        id="fpage-lpage-test-1"><value-of select="e:citation-format1(.)"/> has a first page <value-of select="fpage"/>, but no last page. Is this correct? Should it be an elocation-id instead?</report>
      
    </rule> 
    
    <rule context="element-citation/person-group" id="elem-citation-gen-name-3-1">
      
      <report test=".[not (name or collab)]" 
        role="error" 
        id="err-elem-cit-gen-name-3-1">[err-elem-cit-gen-name-3-1]
        Each &lt;person-group&gt; element in a reference must contain at least one
        &lt;name&gt; or, if allowed, &lt;collab&gt; element. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not.</report>
      
    </rule>
    
    <rule context="element-citation/person-group/collab" id="elem-citation-gen-name-3-2">
      
      <assert test="count(*) = count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-gen-name-3-2">[err-elem-cit-gen-name-3-2]
        A &lt;collab&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' contains additional elements.</assert>
      
    </rule>
    
    <rule context="element-citation/person-group/name/suffix" id="elem-citation-gen-name-4">
      
      <assert test=".=('Jr','Jnr', 'Sr','Snr', 'I', 'II', 'III', 'VI', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')" 
        role="error" 
        id="err-elem-cit-gen-name-4">[err-elem-cit-gen-name-4]
        The &lt;suffix&gt; element in a reference may only contain one of the specified values
        Jnr, Snr, I, II, III, VI, V, VI, VII, VIII, IX, X.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement
        as it contains the value '<value-of select="suffix"/>'.</assert>
      
    </rule>
    
    <rule context="ref/element-citation/year" id="elem-citation-year">
      <let name="YYYY" value="substring(normalize-space(.), 1, 4)"/>
      <let name="current-year" value="year-from-date(current-date())"/>
      <let name="citation" value="e:citation-format1(parent::element-citation)"/>
      
      <assert test="(1700 le number($YYYY)) and (number($YYYY) le ($current-year + 5))" 
        role="warning" 
        id="err-elem-cit-gen-date-1-2">The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive). Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains the value '<value-of select="."/>'.</assert>
      
      <assert test="./@iso-8601-date" 
        role="error" 
        id="err-elem-cit-gen-date-1-3">All &lt;year&gt; elements must have @iso-8601-date attributes. Reference '<value-of select="ancestor::ref/@id"/>' does not.</assert>
      
      <assert test="not(./@iso-8601-date) or (1700 le number(substring(normalize-space(@iso-8601-date),1,4)) and number(substring(normalize-space(@iso-8601-date),1,4)) le ($current-year + 5))" 
        role="warning" 
        id="err-elem-cit-gen-date-1-4">The numeric value of the first 4 digits of the @iso-8601-date attribute on the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive). Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the attribute contains the value '<value-of select="./@iso-8601-date"/>'.</assert>
      
      <assert test="not(./@iso-8601-date) or substring(normalize-space(./@iso-8601-date),1,4) = $YYYY" 
        role="warning" 
        id="pre-err-elem-cit-gen-date-1-5">The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the  &lt;year&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the element contains the value '<value-of select="."/>' and the attribute contains the value '<value-of select="./@iso-8601-date"/>'. If there is no year, and you are unable to determine this, please query with the authors.</assert>
      
      <assert test="not(./@iso-8601-date) or substring(normalize-space(./@iso-8601-date),1,4) = $YYYY" 
        role="error" 
        id="final-err-elem-cit-gen-date-1-5">The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the &lt;year&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the element contains the value '<value-of select="."/>' and the attribute contains the value '<value-of select="./@iso-8601-date"/>'. If there is no year, and you are unable to determine this, please query with the authors.</assert>
      
      <assert test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and
        (some $y in //element-citation/descendant::year
        satisfies (normalize-space($y) = concat($YYYY,'b'))
        and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname
        or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]
        )))" 
        role="error" 
        id="err-elem-cit-gen-date-1-6">If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with the same first author surname (or collab) with a letter "b" after the year. Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <assert test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or
        (some $y in //element-citation/descendant::year
        satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',
        'abcdefghijklmnopqrstuvwxy')))
        and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname
        or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]
        ))" 
        role="error" 
        id="err-elem-cit-gen-date-1-7">[err-elem-cit-gen-date-1-7]
        If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another 
        reference with the same first author surname (or collab) with the preceding letter after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
    </rule>
    
    <rule context="ref/element-citation/source" id="elem-citation-source">
      
      <assert test="string-length(normalize-space(.)) ge 2" 
        role="error" 
        id="elem-cit-source">A  &lt;source&gt; element within a <value-of select="parent::element-citation/@publication-type"/> type &lt;element-citation&gt; must contain at least two characters. - <value-of select="."/>. See Ref '<value-of select="ancestor::ref/@id"/>'.</assert>
      
    </rule>
    
    <rule context="ref/element-citation/ext-link" id="elem-citation-ext-link">
      
      <assert test="(normalize-space(@xlink:href)=normalize-space(.)) and (normalize-space(.)!='')" 
        role="error" 
        id="ext-link-attribute-content-match">&lt;ext-link&gt; must contain content and have an @xlink:href, the value of which must be the same as the content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
      <assert test="matches(@xlink:href,'^https?://|^ftp://')" 
        role="error" 
        id="link-href-conformance">@xlink:href must start with either "http://", "https://",  or "ftp://". The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' is '<value-of select="@xlink:href"/>', which does not.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-high-tests">
    
    <rule context="ref" id="ref">
      <let name="pre-name" value="lower-case(if (local-name(element-citation/person-group[1]/*[1])='name')
        then (element-citation/person-group[1]/name[1]/surname[1])
        else (element-citation/person-group[1]/*[1]))"/>
      <let name="name" value="e:stripDiacritics($pre-name)"/>
      
      <let name="pre-name2" value="lower-case(if (local-name(element-citation/person-group[1]/*[2])='name')
        then (element-citation/person-group[1]/*[2]/surname[1])
        else (element-citation/person-group[1]/*[2]))"/>
      <let name="name2" value="e:stripDiacritics($pre-name2)"/>
      
      <let name="pre-preceding-name" value="lower-case(if (preceding-sibling::ref[1] and
        local-name(preceding-sibling::ref[1]/element-citation/person-group[1]/*[1])='name')
        then (preceding-sibling::ref[1]/element-citation/person-group[1]/name[1]/surname[1])
        else (preceding-sibling::ref[1]/element-citation/person-group[1]/*[1]))"/>
      <let name="preceding-name" value="e:stripDiacritics($pre-preceding-name)"/>
      
      <let name="pre-preceding-name2" value="lower-case(if (preceding-sibling::ref[1] and
        local-name(preceding-sibling::ref[1]/element-citation/person-group[1]/*[2])='name')
        then (preceding-sibling::ref[1]/element-citation/person-group[1]/*[2]/surname[1])
        else (preceding-sibling::ref[1]/element-citation/person-group[1]/*[2]))"/>
      <let name="preceding-name2" value="e:stripDiacritics($pre-preceding-name2)"/>
      
      <assert test="count(*) = count(element-citation)" 
        role="error" 
        id="err-elem-cit-high-1">The only element that is allowed as a child of &lt;ref&gt; is &lt;element-citation&gt;. Reference '<value-of select="@id"/>' has other elements.</assert>
      
      <assert test="if (count(element-citation/person-group[1]/*) != 2)
        then (count(preceding-sibling::ref) = 0 or ($name &gt; $preceding-name) or ($name = $preceding-name and element-citation/year &gt;= preceding-sibling::ref[1]/element-citation/year))
        else (count(preceding-sibling::ref) = 0 or ($name &gt; $preceding-name) or ($name = $preceding-name and $name2 &gt; $preceding-name2)
        or ($name = $preceding-name and $name2 = $preceding-name2 and element-citation/year &gt;= preceding-sibling::ref[1]/element-citation/year)
        or ($name = $preceding-name and count(preceding-sibling::ref[1]/element-citation/person-group[1]/*) !=2))" 
        role="error" 
        id="err-elem-cit-high-2-2">The order of &lt;element-citation&gt;s in the reference list should be name and date, arranged alphabetically by the first author’s surname, or by the value of the first &lt;collab&gt; element. In the case of two authors, the sequence should be arranged by both authors' surnames, then date. For three or more authors, the sequence should be the first author's surname, then date. Reference '<value-of select="@id"/>' appears to be in a different order.</assert>
      
      <assert test="@id" 
        role="error" 
        id="err-elem-cit-high-3-1">Each &lt;ref&gt; element must have an @id attribute.</assert>
      
      <assert test="matches(normalize-space(@id) ,'^bib\d+$')" 
        role="error" 
        id="err-elem-cit-high-3-2">Each &lt;ref&gt; element must have an @id attribute that starts with 'bib' and ends with a number. Reference '<value-of select="@id"/>' has the value '<value-of select="@id"/>', which is incorrect.</assert>
      
      <assert test="count(preceding-sibling::ref)=0 or number(substring(@id,4)) gt number(substring(preceding-sibling::ref[1]/@id,4))" 
        role="error" 
        id="err-elem-cit-high-3-3">The sequence of ids in the &lt;ref&gt; elements must increase monotonically (e.g. 1,2,3,4,5, . . . ,50,51,52,53, . . . etc). Reference '<value-of select="@id"/>' has the value  '<value-of select="@id"/>', which does not fit this pattern.</assert>
      
    </rule>
    
      <rule context="xref[@ref-type='bibr' and matches(normalize-space(.),'[b-z]$')]" id="xref">
      
      <assert test="some $x in preceding::xref satisfies (substring(normalize-space(.),string-length(.)) gt substring(normalize-space($x),string-length(.)))" 
        role="error" 
        id="err-xref-high-2-1">Citations in the text to references with the same author(s) in the same year must be arranged in the same  order as the reference list. The xref with the value '<value-of select="."/>' is in the wrong order in the text. Check all the references to citations for the same authors to determine which need to be changed.</assert>
      
    </rule>
    
    <rule context="element-citation" id="elem-citation">
      
      <assert test="@publication-type = ('journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'periodical', 'report', 'confproc', 'thesis')" 
        role="error" 
        id="err-elem-cit-high-6-2">element-citation must have a publication-type attribute with one of these values: 'journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'periodical', 'report', 'confproc', or 'thesis'. Reference '<value-of select="../@id"/>' has '<value-of select="if (@publication-type) then concat('a @publication-type with the value ',@publication-type) else ('no @publication-type')"/>'.</assert>
      
      <report test="(@publication-type!='periodical') and not(year)" 
        role="warning" 
        id="pre-element-cite-year">'<value-of select="@publication-type"/>' type references must have a year. Reference '<value-of select="../@id"/>' does not. If you are unable to determine this, please ensure to add an author query asking for the year of publication.</report>
      
      <report test="(@publication-type!='periodical') and not(year)" 
        role="error" 
        id="final-element-cite-year">'<value-of select="@publication-type"/>' type references must have a year. Reference '<value-of select="../@id"/>' does not. If you are unable to determine this, please ensure to query the authors for the year of publication.</report>
      
      <report test="(@publication-type='periodical') and not(string-date)" 
        role="warning" 
        id="pre-element-cite-string-date">'<value-of select="@publication-type"/>' type references must have a year. Reference '<value-of select="../@id"/>' does not. If you are unable to determine this, please ensure to add an author query asking for the year of publication.</report>
      
      <report test="(@publication-type='periodical') and not(string-date)" 
        role="error" 
        id="final-element-cite-string-date">'<value-of select="@publication-type"/>' type references must have a year. Reference '<value-of select="../@id"/>' does not. If you are unable to determine this, please ensure to query the authors for the year of publication.</report>
      
    </rule>
    
    <rule context="element-citation//*" id="element-citation-descendants">
      
      <report test="not(*) and (normalize-space(.)='')" 
        role="warning" 
        id="pre-empty-elem-cit-des"><name/> element is empty - this is not allowed. It must contain content. If the details are missing and cannot be determined, please query the authors.</report>
      
      <report test="not(*) and (normalize-space(.)='')" 
        role="error" 
        id="final-empty-elem-cit-des"><name/> element is empty - this is not allowed. It must contain content.</report>
      
      <report test="matches(.,'&lt;/?[a-z]*/?>')" 
        role="error" 
        id="tagging-elem-cit-des"><name/> element contains tagging, which should be removed - '<value-of select="."/>'.</report>
    
    </rule>
  </pattern>
  
  <pattern id="element-citation-journal-tests">
    <rule context="element-citation[@publication-type='journal']" id="elem-citation-journal">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#pre-err-elem-cit-journal-2-1" 
        test="count(person-group)=1" 
        role="warning" 
        id="pre-err-elem-cit-journal-2-1">Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;person-group&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements. If this information is missing, please query the authors for it.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#final-err-elem-cit-journal-2-1" 
        test="count(person-group)=1" 
        role="error" 
        id="final-err-elem-cit-journal-2-1">Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;person-group&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#pre-err-elem-cit-journal-2-2" 
        test="person-group[@person-group-type='author']" 
        role="warning" 
        id="pre-err-elem-cit-journal-2-2">Each  &lt;element-citation&gt; of type 'journal' must contain one &lt;person-group&gt;  with the attribute person-group-type 'author'. Reference '<value-of select="ancestor::ref/@id"/>' has a  &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'. If this information is missing, please query the authors for it.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#final-err-elem-cit-journal-2-2" 
        test="person-group[@person-group-type='author']" 
        role="error" 
        id="final-err-elem-cit-journal-2-2">Each  &lt;element-citation&gt; of type 'journal' must contain one &lt;person-group&gt;  with the attribute person-group-type 'author'. Reference '<value-of select="ancestor::ref/@id"/>' has a  &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-referencesn#pre-err-elem-cit-journal-3-1" 
        test="count(article-title)=1" 
        role="warning" 
        id="pre-err-elem-cit-journal-3-1">Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements. If you are unable to determine this then please query the authors for this information.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-referencesn#final-err-elem-cit-journal-3-1" 
        test="count(article-title)=1" 
        role="error" 
        id="final-err-elem-cit-journal-3-1">Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#pre-err-elem-cit-journal-4-1" 
        test="count(source)=1" 
        role="warning" 
        id="pre-err-elem-cit-journal-4-1">Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements. If you are unable to determine this then please query the authors for this information.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#final-err-elem-cit-journal-4-1" 
        test="count(source)=1" 
        role="error" 
        id="final-err-elem-cit-journal-4-1">Each  &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-4-2-2" 
        test="count(source)=1 and count(source/*)!=0" 
        role="error" 
        id="err-elem-cit-journal-4-2-2">A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' may not contain child elements. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-5-1-3" 
        test="count(volume) le 1" 
        role="error" 
        id="err-elem-cit-journal-5-1-3">There may be no more than one  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal'. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(volume)"/> &lt;volume&gt; elements.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-6-5-1" 
        test="lpage and not(fpage)" 
        role="error" 
        id="err-elem-cit-journal-6-5-1">&lt;lpage&gt; is only allowed if &lt;fpage&gt; is present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; but no &lt;fpage&gt;.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-6-5-2" 
        test="lpage and (number(fpage[1]) ge number(lpage[1]))" 
        role="error" 
        id="err-elem-cit-journal-6-5-2">&lt;lpage&gt; must be larger than &lt;fpage&gt;, if present. Reference '<value-of select="ancestor::ref/@id"/>' has first page &lt;fpage&gt; = '<value-of select="fpage"/>' but last page &lt;lpage&gt; = '<value-of select="lpage"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-6-7" 
        test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1 or count(comment) gt 1" 
        role="error" 
        id="err-elem-cit-journal-6-7">The following elements may not occur more than once in an &lt;element-citation&gt;: &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, and &lt;comment&gt;In press&lt;/comment&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/> &lt;fpage&gt;, <value-of select="count(lpage)"/> &lt;lpage&gt;, <value-of select="count(elocation-id)"/> &lt;elocation-id&gt;, and <value-of select="count(comment)"/> &lt;comment&gt; elements.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-12" 
        test="count(*) = count(person-group| year| article-title| source| volume| fpage| lpage| elocation-id| comment| pub-id)" 
        role="error" 
        id="err-elem-cit-journal-12">The only elements allowed as children of &lt;element-citation&gt; with the publication-type="journal" are: &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;volume&gt;, &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, &lt;comment&gt;, and &lt;pub-id&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/article-title" id="elem-citation-journal-article-title">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-3-2" 
        test="count(*) = count(sub|sup|italic)" 
        role="error" 
        id="err-elem-cit-journal-3-2">An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/volume" id="elem-citation-journal-volume">
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-5-1-2" 
        test="count(*)=0 and (string-length(text()) ge 1)" 
        role="error" 
        id="err-elem-cit-journal-5-1-2">A &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal' must contain at least one character and may not contain child elements. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters and/or child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/fpage" id="elem-citation-journal-fpage">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-6-2" 
        test="count(../elocation-id) eq 0 and count(../comment) eq 0" 
        role="error" 
        id="err-elem-cit-journal-6-2">If &lt;fpage&gt; is present, neither &lt;elocation-id&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt; and one of those elements.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#err-elem-cit-journal-6-6" 
        test="matches(normalize-space(.),'^\D\d') and ../lpage and not(starts-with(../lpage[1],substring(.,1,1)))" 
        role="error" 
        id="err-elem-cit-journal-6-6">If the content of &lt;fpage&gt; begins with a letter and digit, then the content of  &lt;lpage&gt; must begin with the same letter. Reference '<value-of select="ancestor::ref/@id"/>' does not.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/elocation-id" id="elem-citation-journal-elocation-id">
      
      <assert test="count(../fpage) eq 0 and count(../comment) eq 0" 
        role="error" 
        id="err-elem-cit-journal-6-3">If &lt;elocation-id&gt; is present, neither &lt;fpage&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;elocation-id&gt; and one of those elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/comment" id="elem-citation-journal-comment">
      
      <assert test="count(../fpage) eq 0 and count(../elocation-id) eq 0" 
        role="error" 
        id="err-elem-cit-journal-6-4">If &lt;comment&gt;In press&lt;/comment&gt; is present, neither &lt;fpage&gt; nor &lt;elocation-id&gt; may be present. Reference '<value-of select="ancestor::ref/@id"/>' has one of those elements.</assert>
      
      <assert test="text() = 'In press'" 
        role="error" 
        id="err-elem-cit-journal-13">Comment elements with content other than 'In press' are not allowed. Reference '<value-of select="ancestor::ref/@id"/>' has such a &lt;comment&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/pub-id[@pub-id-type='pmid']" id="elem-citation-journal-pub-id-pmid">
      
      <report test="matches(.,'\D')" 
        role="error" 
        id="err-elem-cit-journal-10">If &lt;pub-id pub-id-type="pmid"&gt; is present, the content must be all numeric. The content of &lt;pub-id pub-id-type="pmid"&gt; in Reference '<value-of select="ancestor::ref/@id"/>' is <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/pub-id" id="elem-citation-journal-pub-id">
      
      <assert test="@pub-id-type=('doi','pmid')" 
        role="error" 
        id="err-elem-cit-journal-9-1">Each &lt;pub-id&gt;, if present in a journal reference, must have a @pub-id-type of either "doi" or "pmid". The pub-id-type attribute on &lt;pub-id&gt; in Reference '<value-of select="ancestor::ref/@id"/>' is <value-of select="@pub-id-type"/>.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-book-tests">
    <rule context="element-citation[@publication-type='book']" id="elem-citation-book">
      <let name="publisher-locations" value="'publisher-locations.xml'"/>
      
      <assert test="(count(person-group[@person-group-type='author']) + count(person-group[@person-group-type='editor'])) = count(person-group)" 
        role="error" 
        id="err-elem-cit-book-2-2">The only values allowed for @person-group-type in book references are "author" and "editor". Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      <assert test="count(person-group)=1 or (count(person-group[@person-group-type='author'])=1 and count(person-group[@person-group-type='editor'])=1)" 
        role="warning" 
        id="pre-err-elem-cit-book-2-3">In a book reference, there should be a single person-group element (either author or editor) or one person-group with @person-group-type="author" and one person-group with @person-group-type=editor. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements. If this finromation is missing, please query it with the authors.</assert>
      
      <assert test="count(person-group)=1 or (count(person-group[@person-group-type='author'])=1 and count(person-group[@person-group-type='editor'])=1)" 
        role="error" 
        id="final-err-elem-cit-book-2-3">In a book reference, there should be a single person-group element (either author or editor) or one person-group with @person-group-type="author" and one person-group with @person-group-type=editor. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(source)=1" 
        role="warning" 
        id="pre-err-elem-cit-book-10-1">Each  &lt;element-citation&gt; of type 'book' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements. If this information is missing, please query it with the authors.</assert>
      
      <assert test="count(source)=1" 
        role="error" 
        id="final-err-elem-cit-book-10-1">Each  &lt;element-citation&gt; of type 'book' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" 
        role="error" 
        id="err-elem-cit-book-10-2-2">A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'book' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
      <assert test="count(publisher-name)=1" 
        role="warning" 
        id="pre-err-elem-cit-book-13-1">One and only one &lt;publisher-name&gt; is required in a book reference. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/> &lt;publisher-name&gt; elements. If this information is missing, please query it with the authors.</assert>
      
      <assert test="count(publisher-name)=1" 
        role="error" 
        id="final-err-elem-cit-book-13-1">One and only one &lt;publisher-name&gt; is required in a book reference. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/> &lt;publisher-name&gt; elements.</assert>
      
      <report test="some $p in document($publisher-locations)/locations/location/text()
        satisfies ends-with(publisher-name[1],$p)" 
        role="warning" 
        id="warning-elem-cit-book-13-3">The content of &lt;publisher-name&gt; should not end with a publisher location. Reference '<value-of select="ancestor::ref/@id"/>' contains the string <value-of select="publisher-name"/>, which ends with a publisher location.</report>
      
      <report test="(lpage or fpage) and not(chapter-title)" 
        role="warning" 
        id="err-elem-cit-book-16">Book reference '<value-of select="ancestor::ref/@id"/>' has first and/or last pages, but no chapter title. Is this correct?</report>
      
      <report test="(lpage and fpage) and (number(fpage[1]) &gt;= number(lpage[1]))" 
        role="error" 
        id="err-elem-cit-book-36">If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <report test="lpage and not (fpage)" 
        role="error" 
        id="err-elem-cit-book-36-2">If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present. Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; but not &lt;fpage&gt;.</report>
      
      <report test="count(lpage) &gt; 1 or count(fpage) &gt; 1" 
        role="error" 
        id="err-elem-cit-book-36-6">At most one &lt;lpage&gt; and one &lt;fpage&gt; are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(lpage)"/> &lt;lpage&gt; elements and <value-of select="count(fpage)"/> &lt;fpage&gt; elements.</report>
      
      <assert test="count(*) = count(person-group| year| source| chapter-title| publisher-loc|publisher-name|volume|
        edition| fpage| lpage| pub-id | comment)" 
        role="error" 
        id="err-elem-cit-book-40">The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="book" are: &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;chapter-title&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;volume&gt;, &lt;edition&gt;, &lt;fpage&gt;, &lt;lpage&gt;, &lt;pub-id&gt;, and &lt;comment&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/person-group" id="elem-citation-book-person-group">
      <assert test="@person-group-type" 
        role="error" 
        id="err-elem-cit-book-2-1">Each &lt;person-group&gt; must have a @person-group-type attribute. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; element with no @person-group-type attribute.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='book']/chapter-title" id="elem-citation-book-chapter-title">
      
      <assert test="count(../person-group[@person-group-type='author'])=1" 
        role="warning" 
        id="pre-err-elem-cit-book-22">If there is a &lt;chapter-title&gt; element there must be one and only one &lt;person-group person-group-type="author"&gt;. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement. If this information is missing, please query the authors for it.</assert>
      
      <assert test="count(../person-group[@person-group-type='author'])=1" 
        role="error" 
        id="final-err-elem-cit-book-22">If there is a &lt;chapter-title&gt; element there must be one and only one &lt;person-group person-group-type="author"&gt;. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
      <assert test="count(../person-group[@person-group-type='editor']) le 1" 
        role="error" 
        id="err-elem-cit-book-28-1">If there is a &lt;chapter-title&gt; element there may be a maximum of one &lt;person-group person-group-type="editor"&gt;. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
      <assert test="count(*) = count(sub|sup|italic)" 
        role="error" 
        id="err-elem-cit-book-31">A &lt;chapter-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/publisher-name" id="elem-citation-book-publisher-name">
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-book-13-2">No elements are allowed inside &lt;publisher-name&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the &lt;publisher-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/edition" id="elem-citation-book-edition">
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-book-15">No elements are allowed inside &lt;edition&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the &lt;edition&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/pub-id[@pub-id-type='pmid']" id="elem-citation-book-pub-id-pmid">
      
      <report test="matches(.,'\D')" 
        role="error" 
        id="err-elem-cit-book-18">If &lt;pub-id pub-id-type="pmid"&gt; is present, the content must be all numeric. The content of &lt;pub-id pub-id-type="pmid"&gt; in Reference '<value-of select="ancestor::ref/@id"/>' is <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/pub-id" id="elem-citation-book-pub-id">
      
      <assert test="@pub-id-type=('doi','pmid','isbn')" 
        role="error" 
        id="err-elem-cit-book-17">Each &lt;pub-id&gt;, if present in a book reference, must have a @pub-id-type of one of these values: doi, pmid, isbn. The pub-id-type attribute on &lt;pub-id&gt; in Reference '<value-of select="ancestor::ref/@id"/>' is <value-of select="@pub-id-type"/>.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/comment" id="elem-citation-book-comment">
      
      <assert test="count(../fpage) eq 0 and count(../elocation-id) eq 0" 
        role="error" 
        id="err-elem-cit-book-6-4">If &lt;comment&gt;In press&lt;/comment&gt; is present, neither &lt;fpage&gt; nor &lt;elocation-id&gt; may be present. Reference '<value-of select="ancestor::ref/@id"/>' has one of those elements.</assert>
      
      <assert test="text() = 'In press'" 
        role="error" 
        id="err-elem-cit-book-13">Comment elements with content other than 'In press' are not allowed. Reference '<value-of select="ancestor::ref/@id"/>' has such a &lt;comment&gt; element.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-data-tests">
    <rule context="ref/element-citation[@publication-type='data']" id="elem-citation-data">
      
      <report test="count(person-group[@person-group-type='author']) gt 1" 
        role="error" 
        id="err-elem-cit-data-3-1">Data references must have one and only one &lt;person-group person-group-type='author'&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='author'])"/>.</report>
      
      <report test="count(person-group) lt 1" 
        role="warning" 
        id="pre-err-elem-cit-data-3-2">Data references must have one and only one &lt;person-group person-group-type='author'&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has 0. If this information is missing, please query the authors asking for it.</report>
      
      <report test="count(person-group) lt 1" 
        role="error" 
        id="final-err-elem-cit-data-3-2">Data references must have one and only one &lt;person-group person-group-type='author'&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has 0.</report>
      
      <assert test="count(data-title)=1" 
        role="warning" 
        id="pre-err-elem-cit-data-10">Data reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(data-title)"/> data-title elements, when it should contain one. If this information is missing, please query it with the authors.</assert>
      
      <assert test="count(data-title)=1" 
        role="error" 
        id="final-err-elem-cit-data-10">Data reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> data-title elements. It must contain one (and only one).</assert>
      
      <assert test="count(source)=1" 
        role="warning" 
        id="pre-err-elem-cit-data-11-2">Data reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> source elements, when it should contain one. If this information is missing, please query it with the authors.</assert>
      
      <assert test="count(source)=1" 
        role="error" 
        id="final-err-elem-cit-data-11-2">Data reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> source elements. It must contain one (and only one).</assert>
      
      <assert test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" 
        role="error" 
        id="err-elem-cit-data-11-3-2">A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'data' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
      <assert test="pub-id" 
        role="warning" 
        id="pre-err-elem-cit-data-13-1">There must be at least one pub-id. There may be more than one pub-id. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id elements. If this information is missing, please query it with the authors.</assert>
      
      <assert test="pub-id" 
        role="error" 
        id="final-err-elem-cit-data-13-1">There must be at least one pub-id. There may be more than one pub-id. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id elements.</assert>
      
      <assert test="count(*) = count(person-group| data-title| source| year| pub-id| version)" 
        role="error" 
        id="err-elem-cit-data-18">The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="data" are: &lt;person-group&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, and &lt;version&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='data']/person-group" 
      id="elem-citation-data-person-group">
      
      <assert test="@person-group-type='author'" 
        role="error" 
        id="data-cite-person-group">The person-group for a data reference must have the attribute person-group-type="author". This one in reference '<value-of select="ancestor::ref/@id"/>' has either no person-group attribute or the value is incorrect (<value-of select="@person-group-type"/>).</assert>
      
    </rule>
    
    <rule context="ref/element-citation[@publication-type='data']/pub-id[@pub-id-type='doi']" id="elem-citation-data-pub-id-doi">
      
      <assert test="not(@xlink:href)" 
        role="error" 
        id="err-elem-cit-data-14-2">If the pub-id is of pub-id-type doi, it may not have an @xlink:href. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with type doi and an @link-href with value '<value-of select="@link-href"/>'.</assert>
      
    </rule>
    
    <rule context="ref/element-citation[@publication-type='data']/pub-id" id="elem-citation-data-pub-id">
      
      <assert test="@pub-id-type=('accession','doi')" 
        role="error" 
        id="err-elem-cit-data-13-2">Each pub-id element must have a pub-id-type which is either accession or doi. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with the type '<value-of select="@pub-id-type"/>'.</assert>
      
      <report test="if (@pub-id-type != 'doi') then not(@xlink:href) else ()" 
        role="error" 
        id="err-elem-cit-data-14-1">If the pub-id is of any pub-id-type except doi, it must have an @xlink:href. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with type '<value-of select="@pub-id-type"/>' but no @xlink-href.</report>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-patent-tests">
    <rule context="element-citation[@publication-type='patent']" id="elem-citation-patent">
      
      <assert test="count(person-group[@person-group-type='inventor'])=1" 
        role="warning" 
        id="pre-err-elem-cit-patent-2-1">There must be one person-group with @person-group-type="inventor". Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='inventor'])"/> &lt;person-group&gt; elements of type 'inventor'. If this information is missing, please query the authors for it.</assert>
      
      <assert test="count(person-group[@person-group-type='inventor'])=1" 
        role="error" 
        id="final-err-elem-cit-patent-2-1">There must be one person-group with @person-group-type="inventor". Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='inventor'])"/> &lt;person-group&gt; elements of type 'inventor'.</assert>
      
      <assert test="every $type in person-group/@person-group-type
        satisfies $type = ('assignee','inventor')" 
        role="error" 
        id="err-elem-cit-patent-2-3">The only allowed types of person-group elements are "assignee" and "inventor". Reference '<value-of select="ancestor::ref/@id"/>' has &lt;person-group&gt; elements of other types.</assert>
      
      <assert test="count(person-group[@person-group-type='assignee']) le 1" 
        role="error" 
        id="err-elem-cit-patent-2A">There may be zero or one person-group elements with @person-group-type="assignee". Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group[@person-group-type='assignee'])"/> &lt;person-group&gt; elements of type 'assignee'.</assert>
      
      <assert test="count(article-title)=1" 
        role="warning" 
        id="pre-err-elem-cit-patent-8-1">Each  &lt;element-citation&gt; of type 'patent' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(article-title)=1" 
        role="error" 
        id="final-err-elem-cit-patent-8-1">Each  &lt;element-citation&gt; of type 'patent' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source)=1" 
        role="warning" 
        id="pre-err-elem-cit-patent-9-1">Each &lt;element-citation&gt; of type 'patent' must contain one and only one &lt;source&gt; elements. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements. If this information is missing, please query the authors for it.</assert>
      
      <assert test="count(source)=1" 
        role="error" 
        id="final-err-elem-cit-patent-9-1">Each &lt;element-citation&gt; of type 'patent' must contain one and only one &lt;source&gt; elements. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="patent" 
        role="warning" 
        id="pre-err-elem-cit-patent-10-1-1">The  &lt;patent&gt; element is required. Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;patent&gt; elements. If you are unable to determine this yourself, please add an author query asking for this.</assert>
      
      <assert test="patent" 
        role="error" 
        id="final-err-elem-cit-patent-10-1-1">The  &lt;patent&gt; element is required. Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;patent&gt; elements.</assert>
      
      <assert test="ext-link" 
        role="warning" 
        id="pre-err-elem-cit-patent-11-1">The &lt;ext-link&gt; element is required in a patent reference. Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;ext-link&gt; elements. If you are unable to determine this yourself, please add an author query asking for this.</assert>
      
      <assert test="ext-link" 
        role="error" 
        id="final-err-elem-cit-patent-11-1">The &lt;ext-link&gt; element is required in a patent reference. Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;ext-link&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group| article-title| source| year| patent| ext-link)" 
        role="error" 
        id="err-elem-cit-patent-18">The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="patent" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;patent&gt;, and &lt;ext-link&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='patent']/article-title" id="elem-citation-patent-article-title"> 
      <assert test="./string-length() + sum(*/string-length()) ge 2" 
        role="error" 
        id="err-elem-cit-patent-8-2-1">A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' must contain at least two characters. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-patent-8-2-2">A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='patent']/source" id="elem-citation-patent-source"> 
      
      <assert test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-patent-9-2-2">A &lt;source&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='patent']/patent" id="elem-citation-patent-patent"> 
      <let name="countries" value="'countries.xml'"/>
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-patent-10-1-2">The &lt;patent&gt; element may not have child elements. Reference '<value-of select="ancestor::ref/@id"/>' has child elements.</assert>
      
      <assert test="some $x in document($countries)/countries/country satisfies ($x=@country)" 
        role="error" 
        id="err-elem-cit-patent-10-2">The &lt;patent&gt; element must have a country attribute, the value of which must be an allowed value. Reference '<value-of select="ancestor::ref/@id"/>' has a patent/@country attribute with the value '<value-of select="@country"/>', which is not in the list.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-software-tests">
    <rule context="element-citation[@publication-type = 'software']" id="elem-citation-software">
      <let name="person-count" value="count(person-group[@person-group-type='author']) + count(person-group[@person-group-type='curator'])"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#err-elem-cit-software-2-1" 
        test="$person-count = (1,2)" 
        role="error" 
        id="err-elem-cit-software-2-1">Each &lt;element-citation&gt; of type 'software' must contain one &lt;person-group&gt; element (either author or curator) or one &lt;person-group&gt; with attribute person-group-type = author and one &lt;person-group&gt; with attribute person-group-type = curator. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#err-elem-cit-software-2-2" 
        test="person-group[@person-group-type = ('author', 'curator')]" 
        role="error" 
        id="err-elem-cit-software-2-2">Each &lt;element-citation&gt; of type 'software' must contain one &lt;person-group&gt; with the attribute person-group-type set to 'author' or 'curator'. Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#err-elem-cit-software-10-1" 
        test="count(data-title) &gt; 1" 
        role="error" 
        id="err-elem-cit-software-10-1">Each &lt;element-citation&gt; of type 'software' may contain one and only one &lt;data-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(data-title)"/> &lt;data-title&gt; elements.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#err-elem-cit-software-16" 
        test="count(*) = count(person-group | year | data-title | source | version | publisher-name | publisher-loc | ext-link)" 
        role="error" 
        id="err-elem-cit-software-16">The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="software" are: &lt;person-group&gt;, &lt;year&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;version&gt;, &lt;publisher-name&gt;, &lt;publisher-loc&gt;, and &lt;ext-link&gt; Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type = 'software']/data-title" id="elem-citation-software-data-title">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#err-elem-cit-software-10-2" 
        test="count(*) = count(sub | sup | italic)" 
        role="error" 
        id="err-elem-cit-software-10-2">An &lt;data-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-preprint-tests">
    <rule context="element-citation[@publication-type='preprint']" id="elem-citation-preprint">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-2-1" 
        test="count(person-group)=1" 
        role="error" 
        id="err-elem-cit-preprint-2-1">There must be one and only one person-group. <value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-8-1" 
        test="count(article-title)=1" 
        role="error" 
        id="err-elem-cit-preprint-8-1">Each  &lt;element-citation&gt; of type 'preprint' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-9-1" 
        test="count(source) = 1" 
        role="error" 
        id="err-elem-cit-preprint-9-1">Each  &lt;element-citation&gt; of type 'preprint' must contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-10-1" 
        test="count(pub-id) le 1" 
        role="error" 
        id="err-elem-cit-preprint-10-1">One &lt;pub-id&gt; element is allowed. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-10-3" 
        test="count(pub-id)=1 or count(ext-link)=1" 
        role="error" 
        id="err-elem-cit-preprint-10-3">Either one &lt;pub-id&gt; or one &lt;ext-link&gt; element is required in a preprint reference. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements and <value-of select="count(ext-link)"/> &lt;ext-link&gt; elements.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-13" 
        test="count(*) = count(person-group| article-title| source| year| pub-id| ext-link)" 
        role="error" 
        id="err-elem-cit-preprint-13">The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="preprint" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, and &lt;ext-link&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/person-group" id="elem-citation-preprint-person-group"> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-2-2" 
        test="@person-group-type='author'" 
        role="error" 
        id="err-elem-cit-preprint-2-2">The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' contains @person-group-type='<value-of select="@person-group-type"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/pub-id" id="elem-citation-preprint-pub-id"> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-10-2" 
        test="@pub-id-type='doi'" 
        role="error" 
        id="err-elem-cit-preprint-10-2">If present, the &lt;pub-id&gt; element must contain @pub-id-type='doi'. The &lt;pub-id&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' contains @pub-id-type='<value-of select="@pub-id-type"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/article-title" id="elem-citation-preprint-article-title"> 
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-8-2-1" 
        test="./string-length() + sum(*/string-length()) ge 2" 
        role="error" 
        id="err-elem-cit-preprint-8-2-1">A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' must contain at least two characters. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-8-2-2" 
        test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-preprint-8-2-2">A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/source" id="elem-citation-preprint-source"> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#err-elem-cit-preprint-9-2-2" 
        test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-preprint-9-2-2">A &lt;source&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-web-tests">
    <rule context="element-citation[@publication-type='web']" id="elem-citation-web">
      
      <assert test="count(person-group)=1" 
        role="error" 
        id="err-elem-cit-web-2-1">There must be one and only one person-group. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(article-title)=1" 
        role="warning" 
        id="pre-err-elem-cit-web-8-1">Each  &lt;element-citation&gt; of type 'web' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements. If you are unable to determine this yourself, please query the authors for this information.</assert>
      
      <assert test="count(article-title)=1" 
        role="error" 
        id="final-err-elem-cit-web-8-1">Each  &lt;element-citation&gt; of type 'web' must contain one and only one &lt;article-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <report test="count(source) &gt; 1" 
        role="error" 
        id="err-elem-cit-web-9-1">Each  &lt;element-citation&gt; of type 'web' may contain one and only one &lt;source&gt; element. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(source)"/> &lt;source&gt; elements.</report>
      
      <assert test="count(ext-link)=1" 
        role="error" 
        id="err-elem-cit-web-10-1">One and only one &lt;ext-link&gt; element is required. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(ext-link)"/> &lt;ext-link&gt; elements.</assert>
      
      <report test="count(date-in-citation) lt 1" 
        role="warning" 
        id="pre-err-elem-cit-web-11-1">Web Reference '<value-of select="ancestor::ref/@id"/>' has no accessed date (&lt;date-in-citation&gt; element), which is required. Please ensure this is queried with the author.</report>
      
      <report test="count(date-in-citation) lt 1" 
        role="error" 
        id="final-err-elem-cit-web-11-1">Web Reference '<value-of select="ancestor::ref/@id"/>' has no accessed date (&lt;date-in-citation&gt; element) which is required.</report>
      
      <report test="count(date-in-citation) gt 1" 
        role="error" 
        id="err-elem-cit-web-11-1-1">Web Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(date-in-citation)"/> &lt;date-in-citation&gt; elements. One and only one &lt;date-in-citation&gt; element is required.</report>
      
      <assert test="count(*) = count(person-group|article-title|source|year|ext-link|date-in-citation)" 
        role="error" 
        id="err-elem-cit-web-12">The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="web" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;ext-link&gt; and &lt;date-in-citation&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='web']/person-group" id="elem-citation-web-person-group"> 
      
      <assert test="@person-group-type='author'" 
        role="error" 
        id="err-elem-cit-web-2-2">The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' contains @person-group-type='<value-of select="@person-group-type"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='web']/article-title" id="elem-citation-web-article-title"> 
      <assert test="./string-length() + sum(*/string-length()) ge 2" 
        role="error" 
        id="err-elem-cit-web-8-2-1">A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' must contain 
        at least two characters. Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-web-8-2-2">A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='web']/source" id="elem-citation-web-source"> 
      
      <assert test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-web-9-2-2">A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='web']/date-in-citation" id="elem-citation-web-date-in-citation"> 
      <let name="date-regex" value="'^[12][0-9][0-9][0-9]\-0[13578]\-[12][0-9]$|
        ^[12][0-9][0-9][0-9]\-0[13578]\-0[1-9]$|
        ^[12][0-9][0-9][0-9]\-0[13578]\-3[01]$|
        ^[12][0-9][0-9][0-9]\-02\-[12][0-9]$|
        ^[12][0-9][0-9][0-9]\-02\-0[1-9]$|
        ^[12][0-9][0-9][0-9]\-0[469]\-0[1-9]$|
        ^[12][0-9][0-9][0-9]\-0[469]\-[12][0-9]$|
        ^[12][0-9][0-9][0-9]\-0[469]\-30$|
        ^[12][0-9][0-9][0-9]\-[1-2][02]\-[12][0-9]$|
        ^[12][0-9][0-9][0-9]\-[1-2][02]\-0[1-9]$|
        ^[12][0-9][0-9][0-9]\-[1-2][02]\-3[01]$|
        ^[12][0-9][0-9][0-9]\-11\-0[1-9]$|
        ^[12][0-9][0-9][0-9]\-11\-[12][0-9]$|
        ^[12][0-9][0-9][0-9]\-11\-30$'"/>
      
      <assert test="./@iso-8601-date" 
        role="error" 
        id="err-elem-cit-web-11-2-1">[err-elem-cit-web-11-2-1]
        The &lt;date-in-citation&gt; element must have an @iso-8601-date attribute.
        Reference '<value-of select="ancestor::ref/@id"/>' does not.
      </assert>
      
      <assert test="matches(./@iso-8601-date,'^\d{4}-\d{2}-\d{2}$')" 
        role="error" 
        id="err-elem-cit-web-11-2-2">[err-elem-cit-web-11-2-2]
        The &lt;date-in-citation&gt; element's @iso-8601-date attribute must have the format
        'YYYY-MM-DD'.
        Reference '<value-of select="ancestor::ref/@id"/>' has '<value-of select="@iso-8601-date"/>',
        which does not have that format.
      </assert>
      
      <assert test="matches(normalize-space(.),'^(January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2}, \d{4}')" 
        role="error" 
        id="err-elem-cit-web-11-3">[err-elem-cit-web-11-3]
        The format of the element content must match month, space, day, comma, year.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="."/>.</assert>
      
      <assert test="(matches(@iso-8601-date,replace($date-regex,'\s','')))" 
        role="error" 
        id="err-elem-cit-web-11-5">
        The @iso-8601-date value on accessed date must be a valid date value. <value-of select="@iso-8601-date"/> in reference '<value-of select="ancestor::ref/@id"/>' is not valid.</assert>
      
      <report test="if (matches(@iso-8601-date,replace($date-regex,'\s',''))) then format-date(xs:date(@iso-8601-date), '[MNn] [D], [Y]')!=.
        else ()" 
        role="error" 
        id="err-elem-cit-web-11-4">
        The Accessed date value must match the @iso-8601-date value in the format 'January 1, 2020'.
        Reference '<value-of select="ancestor::ref/@id"/>' has element content of 
        <value-of select="."/> but an @iso-8601-date value of 
        <value-of select="@iso-8601-date"/>.</report>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-report-tests">
    <rule context="element-citation[@publication-type='report']" id="elem-citation-report">
      <let name="publisher-locations" value="'publisher-locations.xml'"/> 
      
      <assert test="count(person-group)=1" 
        role="error" 
        id="err-elem-cit-report-2-1">[err-elem-cit-report-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(source)=1" 
        role="error" 
        id="err-elem-cit-report-9-1">[err-elem-report-report-9-1]
        Each  &lt;element-citation&gt; of type 'report' must contain one and
        only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="count(publisher-name)=1" 
        role="error" 
        id="err-elem-cit-report-11-1">[err-elem-cit-report-11-1]
        &lt;publisher-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/>
        &lt;publisher-name&gt; elements.</assert>
      
      <report test="some $p in document($publisher-locations)/locations/location/text()
        satisfies ends-with(publisher-name[1],$p)" 
        role="warning" 
        id="warning-elem-cit-report-11-3">[warning-elem-cit-report-11-3]
        The content of &lt;publisher-name&gt; may not end with a publisher location. 
        Reference '<value-of select="ancestor::ref/@id"/>' contains the string <value-of select="publisher-name"/>,
        which ends with a publisher location.</report>
      
      <assert test="count(*) = count(person-group| year| source| publisher-loc|publisher-name| ext-link| pub-id)" 
        role="error" 
        id="err-elem-cit-report-15">[err-elem-cit-report-15]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="report" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='report']/person-group" id="elem-citation-report-preson-group">
      <assert test="@person-group-type='author'" 
        role="error" 
        id="err-elem-cit-report-2-2">[err-elem-cit-report-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='report']/source" id="elem-citation-report-source">
      
      <assert test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-report-9-2-2">[err-elem-cit-report-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'report' may only contain the child 
        elements: &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='report']/publisher-name" id="elem-citation-report-publisher-name">
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-report-11-2">[err-elem-cit-report-11-2]
        No elements are allowed inside &lt;publisher-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='report']/pub-id" id="elem-citation-report-pub-id">
      
      <assert test="@pub-id-type='doi' or @pub-id-type='isbn'" 
        role="error" 
        id="err-elem-cit-report-12-2">[err-elem-cit-report-12-2]
        The only allowed pub-id types are 'doi' and 'isbn'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type='report']/ext-link" id="elem-citation-report-ext-link"> 
      
      <assert test="@xlink:href" role="error" id="err-elem-cit-report-14-1">[err-elem-cit-report-14-1]
        Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        does not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-report-14-2">[err-elem-cit-report-14-2]
        The value of @xlink:href must start with either "http://" or "https://". 
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        is '<value-of select="@xlink:href"/>', which does not.</assert>  
        
      <assert test="normalize-space(@xlink:href)=normalize-space(.)" role="error" id="err-elem-cit-report-14-3">[err-elem-cit-report-14-3]
        The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
    
  </pattern>
  
  <pattern id="element-citation-confproc-tests">
    <rule context="element-citation[@publication-type='confproc']" id="elem-citation-confproc"> 
      
      <assert test="count(person-group)=1" 
        role="error" 
        id="err-elem-cit-confproc-2-1">[err-elem-cit-confproc-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(article-title)=1" 
        role="error" 
        id="err-elem-cit-confproc-8-1">[err-elem-cit-confproc-8-1]
        Each  &lt;element-citation&gt; of type 'confproc' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source) le 1" 
        role="error" 
        id="err-elem-cit-confproc-9-1">[err-elem-confproc-confproc-9-1]
        Each  &lt;element-citation&gt; of type 'confproc' must not contain more than one &lt;source&gt; element(s).
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="count(conf-name)=1" 
        role="error" 
        id="err-elem-cit-confproc-10-1">[err-elem-cit-confproc-10-1]
        &lt;conf-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(conf-name)"/>
        &lt;conf-name&gt; elements.</assert>
      
      <report test="(fpage and elocation-id) or (lpage and elocation-id)" 
        role="error" 
        id="err-elem-cit-confproc-12-1">[err-elem-cit-confproc-12-1]
        The citation may contain &lt;fpage&gt; and &lt;lpage&gt;, only &lt;fpage&gt;, or only &lt;elocation-id&gt; elements, but not a mixture.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1" 
        role="error" 
        id="err-elem-cit-confproc-12-2">[err-elem-cit-confproc-12-2]
        The citation may contain no more than one of any of &lt;fpage&gt;, &lt;lpage&gt;, and &lt;elocation-id&gt; elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report test="(lpage and fpage) and (fpage[1] ge lpage[1])" 
        role="error" 
        id="err-elem-cit-confproc-12-3">[err-elem-cit-confproc-12-3]
        If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is 
        less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <assert test="count(fpage/*)=0 and count(lpage/*)=0" 
        role="error" 
        id="err-elem-cit-confproc-12-4">[err-elem-cit-confproc-12-4]
        The content of the &lt;fpage&gt; and &lt;lpage&gt; elements can contain any alpha numeric value but no child elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage/*)"/> child elements in
        &lt;fpage&gt; and  <value-of select="count(lpage/*)"/> child elements in &lt;lpage&gt;.</assert>     
      
      <assert test="count(pub-id) le 1" 
        role="error" 
        id="err-elem-cit-confproc-16-1">[err-elem-cit-confproc-16-1]
        A maximum of one &lt;pub-id&gt; element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/>
        &lt;pub-id&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group | article-title | year| source | conf-loc | conf-name | lpage |
        fpage | elocation-id | ext-link | pub-id)" 
        role="error" 
        id="err-elem-cit-confproc-17">[err-elem-cit-confproc-17]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="confproc" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;conf-loc&gt;, &lt;conf-name&gt;, 
        &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/person-group" id="elem-citation-confproc-preson-group">
      <assert test="@person-group-type='author'" 
        role="error" 
        id="err-elem-cit-confproc-2-2">[err-elem-cit-confproc-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/source" id="elem-citation-confproc-source">
      
      <assert test="count(*)=count(italic | sub | sup)" 
        role="error" 
        id="err-elem-cit-confproc-9-2-2">[err-elem-cit-confproc-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'confproc' may only contain the child 
        elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/article-title" id="elem-citation-confproc-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" 
        role="error" 
        id="err-elem-cit-confproc-8-2">[err-elem-cit-confproc-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/conf-name" id="elem-citation-confproc-conf-name">
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-confproc-10-2">[err-elem-cit-confproc-10-2]
        No elements are allowed inside &lt;conf-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;conf-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/conf-loc" id="elem-citation-confproc-conf-loc">
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-confproc-11-2">[err-elem-cit-confproc-11-2]
        No elements are allowed inside &lt;conf-loc&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;conf-loc&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/fpage" id="elem-citation-confproc-fpage">
      
      <assert test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage[1]),1,1) = substring(normalize-space(.),1,1))" 
        role="error" 
        id="err-elem-cit-confproc-12-5">[err-elem-cit-confproc-12-5]
        If the content of &lt;fpage&gt; begins with a letter, then the content of &lt;lpage&gt; must begin with 
        the same letter. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt;='<value-of select="."/>'
        and &lt;lpage&gt;='<value-of select="../lpage"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/pub-id" id="elem-citation-confproc-pub-id">
      
      <assert test="@pub-id-type='doi' or @pub-id-type='pmid'" 
        role="error" 
        id="err-elem-cit-confproc-16-2">[err-elem-cit-confproc-16-2]
        The only allowed pub-id types are 'doi' or 'pmid'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-thesis-tests">
    
    <rule context="element-citation[@publication-type='thesis']" id="elem-citation-thesis"> 
      
      <assert test="count(person-group)=1" 
        role="error" 
        id="err-elem-cit-thesis-2-1">[err-elem-cit-thesis-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(descendant::collab)=0" 
        role="error" 
        id="err-elem-cit-thesis-3">[err-elem-cit-thesis-3]
        No &lt;collab&gt; elements are allowed in thesis citations.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(collab)"/> &lt;collab&gt; elements.</assert>
      
      <assert test="count(descendant::etal)=0" 
        role="error" 
        id="err-elem-cit-thesis-6">[err-elem-cit-thesis-6]
        No &lt;etal&gt; elements are allowed in thesis citations.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(etal)"/> &lt;etal&gt; elements.</assert>
      
      <assert test="count(article-title)=1" 
        role="error" 
        id="err-elem-cit-thesis-8-1">[err-elem-cit-thesis-8-1]
        Each  &lt;element-citation&gt; of type 'thesis' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(publisher-name)=1" 
        role="error" 
        id="err-elem-cit-thesis-9-1">[err-elem-cit-thesis-9-1]
        &lt;publisher-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/>
        &lt;publisher-name&gt; elements.</assert>
      
      <assert test="count(pub-id) le 1" 
        role="error" 
        id="err-elem-cit-thesis-11-1">[err-elem-cit-thesis-11-1]
        A maximum of one &lt;pub-id&gt; element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/>
        &lt;pub-id&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group | article-title | year| source | publisher-loc | publisher-name | ext-link | pub-id)" 
        role="error" 
        id="err-elem-cit-thesis-13">[err-elem-cit-thesis-13]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="thesis" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, 
        &lt;ext-link&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/person-group" id="elem-citation-thesis-preson-group">
      
      <assert test="@person-group-type='author'" 
        role="error" 
        id="err-elem-cit-thesis-2-2">[err-elem-cit-thesis-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
      
      <assert test="count(name)=1" 
        role="error" 
        id="err-elem-cit-thesis-2-3">[err-elem-cit-thesis-2-3]
        Each thesis citation must have one and only one author.
        Reference '<value-of select="ancestor::ref/@id"/>' has a thesis citation 
        with <value-of select="count(name)"/> authors.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/article-title" id="elem-citation-thesis-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" 
        role="error" 
        id="err-elem-cit-thesis-8-2">[err-elem-cit-thesis-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/publisher-name" id="elem-citation-thesis-publisher-name">
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-thesis-9-2">[err-elem-cit-thesis-9-2]
        No elements are allowed inside &lt;publisher-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/publisher-loc" id="elem-citation-thesis-publisher-loc">
      
      <assert test="count(*)=0" 
        role="error" 
        id="err-elem-cit-thesis-10-2">[err-elem-cit-thesis-10-2]
        No elements are allowed inside &lt;publisher-loc&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-loc&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/pub-id" id="elem-citation-thesis-pub-id">
      
      <assert test="@pub-id-type='doi'" 
        role="error" 
        id="err-elem-cit-thesis-11-2">[err-elem-cit-thesis-11-2]
        The only allowed pub-id type is 'doi'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-periodical-tests">
    
    <rule context="element-citation[@publication-type='periodical']" id="elem-citation-periodical">
      
      <assert test="count(person-group)=1" 
        role="error" 
        id="err-elem-cit-periodical-2-1">[err-elem-cit-periodical-2-1]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one and
        only one &lt;person-group&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="person-group[@person-group-type='author']" 
        role="error" 
        id="err-elem-cit-periodical-2-2">[err-elem-cit-periodical-2-2]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one &lt;person-group&gt; 
        with the attribute person-group-type set to 'author'. Reference 
        '<value-of select="ancestor::ref/@id"/>' has a  &lt;person-group&gt; type of 
        '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      <assert test="count(string-date/year)=1" 
        role="error" 
        id="err-elem-cit-periodical-7-1">[err-elem-cit-periodical-7-1]
        There must be one and only one &lt;year&gt; element in a &lt;string-date&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(year)"/>
        &lt;year&gt; elements in the &lt;string-date&gt; element.</assert>
      
      <assert test="count(article-title)=1" 
        role="error" 
        id="err-elem-cit-periodical-8-1">[err-elem-cit-periodical-8-1]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source)=1" 
        role="error" 
        id="err-elem-cit-periodical-9-1">[err-elem-cit-periodical-9-1]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one and
        only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" 
        role="error" 
        id="err-elem-cit-periodical-9-2-2">[err-elem-cit-periodical-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'periodical' may only contain the child 
        elements &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
      <assert test="count(volume) le 1" 
        role="error" 
        id="err-elem-cit-periodical-10-1-3">[err-elem-cit-periodical-10-1-3]
        There may be at most one  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'periodical'.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(volume)"/>
        &lt;volume&gt; elements.</assert>
      
      <report test="lpage and not(fpage)" 
        role="error" 
        id="err-elem-cit-periodical-11-1">[err-elem-cit-periodical-11-1]
        If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report test="count(fpage) gt 1 or count(lpage) gt 1" 
        role="error" 
        id="err-elem-cit-periodical-11-2">[err-elem-cit-periodical-11-2]
        The citation may contain no more than one &lt;fpage&gt; or &lt;lpage&gt; elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements and <value-of select="count(lpage)"/> &lt;lpage&gt; elements.</report>
      
      <report test="(lpage and fpage) and (fpage[1] ge lpage[1])" 
        role="error" 
        id="err-elem-cit-periodical-11-3">[err-elem-cit-periodical-11-3]
        If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is 
        less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <assert test="count(fpage/*)=0 and count(lpage/*)=0" 
        role="error" 
        id="err-elem-cit-periodical-11-4">[err-elem-cit-periodical-11-4]
        The content of the &lt;fpage&gt; and &lt;lpage&gt; elements can contain any alpha numeric value but no child elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage/*)"/> child elements in
        &lt;fpage&gt; and  <value-of select="count(lpage/*)"/> child elements in &lt;lpage&gt;.</assert>     
      
      <assert test="count(*) = count(person-group | year | string-date | article-title | source | volume | fpage | lpage)" 
        role="error" 
        id="err-elem-cit-periodical-13">[err-elem-cit-periodical-13]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="periodical" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;string-date&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;volume&gt;, &lt;fpage&gt;, and &lt;lpage&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
      <assert test="count(string-date)=1" 
        role="error" 
        id="err-elem-cit-periodical-14-1">[err-elem-cit-periodical-14-1]
        There must be one and only one &lt;string-date&gt; element within a &lt;element-citation&gt; of type 'periodical'.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(string-date)"/>
        &lt;string-date&gt; elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/year" id="elem-citation-periodical-year">
      
      <let name="YYYY" value="substring(normalize-space(.), 1, 4)"/>
      <let name="current-year" value="year-from-date(current-date())"/>
      
      <assert test="./@iso-8601-date" 
        role="error" 
        id="err-elem-cit-periodical-7-2">[err-elem-cit-periodical-7-2]
        The &lt;year&gt; element must have an @iso-8601-date attribute.
        Reference '<value-of select="ancestor::ref/@id"/>' does not.
      </assert>
      
      <assert test="matches(normalize-space(.),'(^\d{4}[a-z]?)')" 
        role="error" 
        id="err-elem-cit-periodical-7-4-1">[err-elem-cit-periodical-7-4-1]
        The &lt;year&gt; element in a reference must contain 4 digits, possibly followed by one (but not more) lower-case letter.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="(1700 le number($YYYY)) and (number($YYYY) le $current-year)" 
        role="warning" 
        id="err-elem-cit-periodical-7-4-2">[err-elem-cit-periodical-7-4-2]
        The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year (inclusive).
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and
        (some $y in //element-citation/descendant::year
        satisfies (normalize-space($y) = concat($YYYY,'b'))
        and ancestor::element-citation/person-group[1]/name[1]/surname[1] = $y/ancestor::element-citation/person-group[1]/name[1]/surname[1])
        )" 
        role="error" 
        id="err-elem-cit-periodical-7-6">[err-elem-cit-periodical-7-6]
        If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with 
        the same first author surname with a letter "b" after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <assert test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or
        (some $y in //element-citation/descendant::year
        satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',
        'abcdefghijklmnopqrstuvwxy')))
        and ancestor::element-citation/person-group[1]/name[1]/surname[1] = $y/ancestor::element-citation/person-group[1]/name[1]/surname[1])" 
        role="error" 
        id="err-elem-cit-periodical-7-7">[err-elem-cit-periodical-7-7]
        If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another 
        reference with the same first author surname with the preceding letter after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <report test=". = preceding::year and
        ancestor::element-citation/person-group[1]/name[1]/surname[1] = preceding::year/ancestor::element-citation/person-group[1]/name[1]/surname[1]" 
        role="error" 
        id="err-elem-cit-periodical-7-8">[err-elem-cit-periodical-7-8]
        Letter suffixes must be unique for the combination of year and first author surname. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement as it 
        contains the &lt;year&gt; '<value-of select="."/>' more than once for the same first author surname
        '<value-of select="ancestor::element-citation/person-group[1]/name[1]/surname[1]"/>'.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/article-title" id="elem-citation-periodical-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" 
        role="error" 
        id="err-elem-cit-periodical-8-2">[err-elem-cit-periodical-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/volume" id="elem-citation-periodical-volume">
      <assert test="count(*)=0 and (string-length(text()) ge 1)" 
        role="error" 
        id="err-elem-cit-periodical-10-1-2">[err-elem-cit-periodical-10-1-2]
        A  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'periodical' must contain 
        at least one character and may not contain child elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters and/or
        child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/fpage" id="elem-citation-periodical-fpage">
      
      <assert test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage[1]),1,1) = substring(normalize-space(.),1,1))" 
        role="error" 
        id="err-elem-cit-periodical-11-5">[err-elem-cit-periodical-11-4]
        If the content of &lt;fpage&gt; begins with a letter, then the content of  &lt;lpage&gt; must begin with 
        the same letter. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt;='<value-of select="."/>'
        and &lt;lpage&gt;='<value-of select="../lpage"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date" id="elem-citation-periodical-string-date">
      <let name="YYYY" value="substring(normalize-space(year[1]), 1, 4)"/>
      
      <assert test="count(month)=1 and count(year)=1" 
        role="error" 
        id="err-elem-cit-periodical-14-2">[err-elem-cit-periodical-14-2]
        The &lt;string-date&gt; element must include one of each of &lt;month&gt; and &lt;year&gt; 
        elements.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        <value-of select="count(month)"/> &lt;month&gt; elements and <value-of select="count(year)"/> &lt;year&gt; elements.
      </assert>
      
      <assert test="count(day) le 1" 
        role="error" 
        id="err-elem-cit-periodical-14-3">[err-elem-cit-periodical-14-3]
        The &lt;string-date&gt; element may include one &lt;day&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        <value-of select="count(day)"/> &lt;day&gt; elements.
      </assert> 
      
      <assert test="(name(child::node()[1])='month' and replace(child::node()[2],'\s+',' ')=' ' and
        name(child::node()[3])='day' and replace(child::node()[4],'\s+',' ')=', ' and name(*[position()=last()])='year') or
        (name(child::node()[1])='month' and replace(child::node()[2],'\s+',' ')=', ' and name(*[position()=last()])='year')" 
        role="error" 
        id="err-elem-cit-periodical-14-8">[err-elem-cit-periodical-14-8]
        The format of the element content must match &lt;month&gt;, space, &lt;day&gt;, comma, &lt;year&gt;, or &lt;month&gt;, comma, &lt;year&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="."/>.</assert>    
      
      <assert test="matches(normalize-space(@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')" 
        role="error" 
        id="err-elem-cit-periodical-7-3">[err-elem-cit-periodical-7-3]
        The @iso-8601-date value must include 4 digit year, 2 digit month, and (optionally) a 2 digit day.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="@iso-8601-date"/>'.
      </assert>
      
      <report test="not(@iso-8601-date) or (substring(normalize-space(@iso-8601-date),1,4) != $YYYY)" 
        role="error" 
        id="err-elem-cit-periodical-7-5">[err-elem-cit-periodical-7-5]
        The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the 
        &lt;year&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the element contains
        the value '<value-of select="."/>' and the attribute contains the value 
        '<value-of select="./@iso-8601-date"/>'.
      </report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/month" id="elem-citation-periodical-month">
      
      <assert test=".=('January','February','March','April','May','June','July','August','September','October','November','December')" 
        role="error" 
        id="err-elem-cit-periodical-14-4">[err-elem-cit-periodical-14-4]
        The content of &lt;month&gt; must be the month, written out, with correct capitalization.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value  &lt;month&gt;='<value-of select="."/>'.
      </assert>
      
      <report test="if  (matches(normalize-space(../@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')) then .!=format-date(xs:date(../@iso-8601-date), '[MNn]')
        else ." 
        role="error" 
        id="err-elem-cit-periodical-14-5">[err-elem-cit-periodical-14-5]
        The content of &lt;month&gt; must match the content of the month section of @iso-8601-date on the 
        parent string-date element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value &lt;month&gt;='<value-of select="."/>' but &lt;string-date&gt;/@iso-8601-date='<value-of select="../@iso-8601-date"/>'.
      </report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/day" id="elem-citation-periodical-day">
      
      <assert test="matches(normalize-space(.),'([1-9])|([1-2][0-9])|(3[0-1])')" 
        role="error" 
        id="err-elem-cit-periodical-14-6">[err-elem-cit-periodical-14-6]
        The content of &lt;day&gt;, if present, must be the day, in digits, with no zeroes.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value  &lt;day&gt;='<value-of select="."/>'.
      </assert>
      
      <report test="if  (matches(normalize-space(../@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')) then .!=format-date(xs:date(../@iso-8601-date), '[D]')
        else ." 
        role="error" 
        id="err-elem-cit-periodical-14-7">[err-elem-cit-periodical-14-7]
        The content of &lt;day&gt;, if present, must match the content of the day section of @iso-8601-date on the 
        parent string-date element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value &lt;day&gt;='<value-of select="."/>' but &lt;string-date&gt;/@iso-8601-date='<value-of select="../@iso-8601-date"/>'.
      </report>
      
    </rule>
  </pattern>
  
  <pattern id="das-element-citation-tests">
    <rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']" id="gen-das-tests">
      <let name="pos" value="count(ancestor::sec[@sec-type='data-availability']//element-citation[@publication-type='data']) - count(following::element-citation[@publication-type='data' and ancestor::sec[@sec-type='data-availability']])"/> 
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-person-group-1" 
        test="count(person-group[@person-group-type='author'])=1" 
        role="warning" 
        id="pre-das-elem-person-group-1">The reference in position <value-of select="$pos"/> of the data availability section does not have any authors (no person-group[@person-group-type='author']). Please ensure to add them in or query the authors asking for the author list.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-person-group-1" 
        test="count(person-group[@person-group-type='author'])=1" 
        role="error" 
        id="final-das-elem-person-group-1">The reference in position <value-of select="$pos"/> of the data availability section does not have any authors (no person-group[@person-group-type='author']). Please ensure to add them.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-elem-person-group-2" 
        test="count(person-group) gt 1" 
        role="error" 
        id="das-elem-person-group-2">The reference in position <value-of select="$pos"/> of the data availability has <value-of select="count(person-group)"/> person-group elements, which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-person-1" 
        test="(count(person-group[@person-group-type='author']/name)=0) and (count(person-group[@person-group-type='author']/collab)=0)" 
        role="warning" 
        id="pre-das-elem-person-1">The reference in position <value-of select="$pos"/> of the data availability section does not have any authors. Please ensure to add them in or query the authors asking for the author list.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-person-1" 
        test="(count(person-group[@person-group-type='author']/name)=0) and (count(person-group[@person-group-type='author']/collab)=0)" 
        role="error" 
        id="final-das-elem-person-1">The reference in position <value-of select="$pos"/> of the data availability section does not have any authors (person-group[@person-group-type='author']). Please ensure to add them in.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-data-title-1" 
        test="count(data-title)=1" 
        role="warning" 
        id="pre-das-elem-data-title-1">The reference in position <value-of select="$pos"/> of the data availability section does not have a title (no data-title). Please ensure to add it in or query the authors asking for it.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-data-title-1" 
        test="count(data-title)=1" 
        role="error" 
        id="final-das-elem-data-title-1">The reference in position <value-of select="$pos"/> of the data availability section does not have a title (no data-title). Please ensure to add it in.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-source-1" 
        test="count(source)=1" 
        role="warning" 
        id="pre-das-elem-source-1">The reference in position <value-of select="$pos"/> of the data availability section does not have a database name (no source). Please ensure to add it in or query the authors asking for it.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-source-1" 
        test="count(source)=1" 
        role="error" 
        id="final-das-elem-source-1">The reference in position <value-of select="$pos"/> of the data availability section does not have a database name (no source). Please ensure to add it in.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-pub-id-1" 
        test="count(pub-id)=1" 
        role="warning" 
        id="pre-das-elem-pub-id-1">The reference in position <value-of select="$pos"/> of the data availability section does not have an identifier (no pub-id). Please ensure to add it in or query the authors asking for it.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-pub-id-1" 
        test="count(pub-id)=1" 
        role="error" 
        id="final-das-elem-pub-id-1">The reference in position <value-of select="$pos"/> of the data availability section does not have an identifier (no pub-id). Please ensure to add it in.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-pub-id-2" 
        test="normalize-space(pub-id)=''" 
        role="warning" 
        id="pre-das-elem-pub-id-2">The reference in position <value-of select="$pos"/> of the data availability section does not have an id (pub-id is empty). Please ensure to add it in or query the authors asking for it.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-pub-id-2" 
        test="normalize-space(pub-id)=''" 
        role="error" 
        id="final-das-elem-pub-id-2">The reference in position <value-of select="$pos"/> of the data availability section does not have an id (pub-id is empty). Please ensure to add it in.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-year-1" 
        test="count(year)=1" 
        role="warning" 
        id="pre-das-elem-year-1">The reference in position <value-of select="$pos"/> of the data availability section does not have a year. Please ensure to add it in or query the authors asking for it.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-year-1" 
        test="count(year)=1" 
        role="error" 
        id="final-das-elem-year-1">The reference in position <value-of select="$pos"/> of the data availability section does not have a year. Please ensure to add it in.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-elem-cit-1" 
        test="@specific-use" 
        role="error" 
        id="das-elem-cit-1">Every reference in the data availability section must have an @specific-use. The reference in position <value-of select="$pos"/> does not.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-elem-cit-2" 
        test="@specific-use and not(@specific-use=('isSupplementedBy','references'))" 
        role="error" 
        id="das-elem-cit-2">The reference in position <value-of select="$pos"/> of the data availability section has a @specific-use value of <value-of select="@specific-use"/>, which is not allowed. It must be 'isSupplementedBy' or 'references'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-cit-3" 
        test="pub-id[1]/@xlink:href = preceding::element-citation[(@publication-type='data') and ancestor::sec[@sec-type='data-availability']]/pub-id[1]/@xlink:href" 
        role="warning" 
        id="pre-das-elem-cit-3">The reference in position <value-of select="$pos"/> of the data availability section has a link (<value-of select="pub-id[1]/@xlink:href"/>) which is the same as another dataset reference in that section. Dataset reference links should be distinct.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-cit-3" 
        test="pub-id[1]/@xlink:href = preceding::element-citation[(@publication-type='data') and ancestor::sec[@sec-type='data-availability']]/pub-id[1]/@xlink:href" 
        role="error" 
        id="final-das-elem-cit-3">The reference in position <value-of select="$pos"/> of the data availability section has a link (<value-of select="pub-id[1]/@xlink:href"/>) which is the same as another dataset reference in that section. Dataset reference links should be distinct.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-elem-cit-4" 
        test="pub-id[1] = preceding::element-citation[(@publication-type='data') and ancestor::sec[@sec-type='data-availability']]/pub-id[1]" 
        role="warning" 
        id="das-elem-cit-4">The reference in position <value-of select="$pos"/> of the data availability section has a pub-id (<value-of select="pub-id[1]"/>) which is the same as another dataset reference in that section. This is very likely incorrect. Dataset reference pub-id should be distinct.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-elem-cit-5" 
        test="pub-id[1] = following::element-citation[ancestor::ref-list]/pub-id[1]" 
        role="warning" 
        id="das-elem-cit-5">The reference in position <value-of select="$pos"/> of the data availability section has a pub-id (<value-of select="pub-id[1]"/>) which is the same as in another reference in the reference list. Is the same reference in both the reference list and data availability section?</report>
      
    </rule>
    
    <rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']/pub-id" id="das-elem-citation-data-pub-id">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-pub-id-1" 
        test="normalize-space(.)!='' and not(@pub-id-type=('accession', 'doi'))" 
        role="error" 
        id="das-pub-id-1">Each pub-id element must have an @pub-id-type which is either accession or doi.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-pub-id-2" 
        test="@pub-id-type!='doi' and normalize-space(.)!='' and (not(@xlink:href) or (normalize-space(@xlink:href)=''))" 
        role="warning" 
        id="pre-das-pub-id-2">Each pub-id element which is not a doi must have an @xlink-href (which is not empty). If the link is not available please query the authors asking for it.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-pub-id-2" 
        test="@pub-id-type!='doi' and normalize-space(.)!='' and (not(@xlink:href) or (normalize-space(@xlink:href)=''))" 
        role="error" 
        id="final-das-pub-id-2">Each pub-id element which is not a doi must have an @xlink-href (which is not empty).</report>
      
    </rule>
    
    <rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']/source/*|sec[@sec-type='data-availability']//element-citation[@publication-type='data']/data-title/*" id="das-elem-citation-children">
      <let name="allowed-elems" value="('sup','sub','italic')"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-elem-citation-child-1" 
        test="name()=$allowed-elems" 
        role="error" 
        id="das-elem-citation-child-1">Reference in the data availability section has a <value-of select="name()"/> element in a <value-of select="parent::*/name()"/> element which is not allowed.</assert>
    </rule>
    
    <rule context="sec[@sec-type='data-availability']//element-citation[@publication-type='data']/year" id="das-elem-citation-year-tests">
      <let name="digits" value="replace(.,'[^\d]','')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-elem-citation-year-1" 
        test="(.!='') and (@iso-8601-date!=$digits)" 
        role="error" 
        id="das-elem-citation-year-1">Every year in a reference must have an @iso-8601-date attribute equal to the numbers in the year. Reference with id <value-of select="parent::*/@id"/> has a year '<value-of select="."/>' but an @iso-8601-date '<value-of select="@iso-8601-date"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-elem-citation-year-2" 
        test="normalize-space(.)=''" 
        role="warning" 
        id="pre-das-elem-citation-year-2">Reference with id <value-of select="parent::*/@id"/> has an empty year. Please ensure to add it in or query the authors asking for it.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-elem-citation-year-2" 
        test="normalize-space(.)=''" 
        role="error" 
        id="final-das-elem-citation-year-2">Reference with id <value-of select="parent::*/@id"/> has an empty year. Please ensure to add it in.</report>
    </rule>
  </pattern>
  
  <pattern id="pub-id-pattern">
    
    <rule context="element-citation/pub-id" id="pub-id-tests">
      
      <report test="(@xlink:href) and not(matches(@xlink:href,'^http[s]?://|^ftp://'))" 
        role="warning" 
        id="pre-pub-id-test-1">@xlink:href must start with an http:// or ftp:// protocol. - <value-of select="@xlink:href"/> does not. If this information is missing, please ensure to query it with the authors.</report>
      
      <report test="(@xlink:href) and not(matches(@xlink:href,'^http[s]?://|^ftp://'))" 
        role="error" 
        id="final-pub-id-test-1">@xlink:href must start with an http:// or ftp:// protocol. - <value-of select="@xlink:href"/> does not.</report>
      
      <report test="(@pub-id-type='doi') and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))" 
        role="warning" 
        id="pre-pub-id-test-2">pub-id is tagged as a doi, but it is not one - <value-of select="."/>. If this information is missing, please ensure to query it with the authors.</report>
      
      <report test="(@pub-id-type='doi') and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))" 
        role="error" 
        id="final-pub-id-test-2">pub-id is tagged as a doi, but it is not one - <value-of select="."/></report>
      
      <report test="(@pub-id-type='pmid') and matches(.,'\D')" 
        role="error" 
        id="pub-id-test-3">pub-id is tagged as a pmid, but it contains a character(s) which is not a digit - <value-of select="."/></report>
      
      <report test="(@pub-id-type != 'doi') and matches(@xlink:href,'https?://(dx.doi.org|doi.org)/')" 
        role="error" 
        id="pub-id-doi-test-1">pub-id has a doi link - <value-of select="@xlink:href"/> - but its pub-id-type is <value-of select="@pub-id-type"/> instead of doi.</report>
      
      <report test="matches(@xlink:href,'https?://(dx.doi.org|doi.org)/') and not(contains(.,substring-after(@xlink:href,'doi.org/')))" 
        role="error" 
        id="pub-id-doi-test-2">pub id has a doi link - <value-of select="@xlink:href"/> - but the identifier is not the doi - '<value-of select="."/>', which is incorrect. Either the doi link is correct, and the identifier needs changing, or the identifier is correct and needs adding after 'https://doi.org/' in order to create the real doi link.</report>
      
      <report test="contains(.,' ')" 
        role="warning" 
        id="pub-id-test-4">pub id contains whitespace - <value-of select="."/> - which is very likely to be incorrect.</report>
      
      <report test="ends-with(.,'.')" 
        role="error" 
        id="pub-id-test-5"><value-of select="@pub-id-type"/> pub-id ends with a full stop - <value-of select="."/> - which is not correct. Please remove the full stop.</report>
      
    </rule>
    
  </pattern>
  
 <pattern id="features">
   
   <rule context="article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]//title-group/article-title" id="feature-title-tests">
     <let name="sub-disp-channel" value="ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject[1]"/>
     
     <report test="(count(ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject) = 1) and starts-with(.,$sub-disp-channel)" 
        role="error" 
        id="feature-title-test-1">title starts with the sub-display-channel. This is certainly incorrect.</report>
     
   </rule>
   
   <rule context="front//abstract[@abstract-type='executive-summary']" id="feature-abstract-tests">
     
     <assert test="count(title) = 1" 
        role="error" 
        id="feature-abstract-test-1">abstract must contain one and only one title.</assert>
     
     <assert test="title = 'eLife digest'" 
        role="error" 
        id="feature-abstract-test-2">abstract title must contain 'eLife digest'. Possible superfluous characters - <value-of select="replace(title,'eLife digest','')"/></assert>
     
   </rule>
   
   <rule context="front//abstract[@abstract-type='executive-summary']/p" id="digest-tests">
     
     <report test="matches(.,'^\p{Ll}')" 
       role="warning" 
       id="digest-test-1">digest paragraph starts with a lowercase letter. Is that correct? Or has a paragraph been incorrect split into two?</report>
     
     <report test="matches(.,'\[[Oo][Kk]\??\]')" 
       role="error" 
       id="final-digest-test-2">digest paragraph contains [OK] or [OK?] which should be removed - <value-of select="."/></report>
     
   </rule>
   
   <rule context="subj-group[@subj-group-type='sub-display-channel']/subject" id="feature-subj-tests">		
     <let name="token1" value="substring-before(.,' ')"/>
     <let name="token2" value="substring-after(.,$token1)"/>
		
     <report test=". != e:titleCase(.)" 
        role="error" 
        id="feature-subj-test-2">The content of the sub-display-channel should be in title case - <value-of select="e:titleCase(.)"/></report>
     
     <report test="ends-with(.,':')" 
        role="error" 
        id="feature-subj-test-3">sub-display-channel ends with a colon. This is incorrect.</report>
     
     <report test="preceding-sibling::subject" 
        role="error" 
        id="feature-subj-test-4">There is more than one sub-display-channel subject. This is incorrect.</report>
		
	</rule>
   
   <rule context="article-categories[subj-group[@subj-group-type='display-channel']/subject = $features-subj]" id="feature-article-category-tests">
     <let name="count" value="count(subj-group[@subj-group-type='sub-display-channel'])"/>
     
     <assert test="$count = 1" 
        role="error" 
        id="feature-article-category-test-1">article categories for <value-of select="subj-group[@subj-group-type='display-channel']/subject"/>s must contain one, and only one, subj-group[@subj-group-type='sub-display-channel']</assert>
     
   </rule>
   
   <rule context="article//article-meta[article-categories//subj-group[@subj-group-type='display-channel']/subject=$features-subj]//contrib[@contrib-type='author']" id="feature-author-tests">
     
     <assert test="bio" 
        role="error" 
        id="feature-author-test-1">Author must contain child bio in feature content.</assert>
   </rule>
   
   <rule context="article//article-meta[article-categories//subj-group[@subj-group-type='display-channel']/subject=$features-subj]//contrib[@contrib-type='author']/bio" id="feature-bio-tests">
     <let name="name" value="e:get-name(parent::contrib/name[1])"/>
     <let name="xref-rid" value="parent::contrib/xref[@ref-type='aff']/@rid"/>
     <let name="aff" value="if (parent::contrib/aff) then parent::contrib/aff[1]/institution[not(@content-type)][1]/normalize-space(.)
       else ancestor::contrib-group/aff[@id/string() = $xref-rid]/institution[not(@content-type)][1]/normalize-space(.)"/>
     <let name="aff-tokens" value="for $y in $aff return tokenize($y,', ')"/>
     
     <assert test="p[1]/bold = $name" 
        role="error" 
        id="feature-bio-test-1">bio must contain a bold element that contains the name of the author - <value-of select="$name"/>.</assert>
     
     <!-- Needs to account for authors with two or more affs-->
     <report test="if (count($aff) &gt; 1) then ()
       else not(contains(.,$aff))" 
        role="warning" 
        id="feature-bio-test-2">bio does not contain the institution text as it appears in their affiliation ('<value-of select="$aff"/>'). Is this correct?</report>
     
     <report test="(count($aff) &gt; 1) and (some $x in $aff-tokens satisfies not(contains(.,$x)))" 
        role="warning" 
        id="feature-bio-test-6">Some of the text from <value-of select="$name"/>'s affiliations does not appear in their bio - <value-of select="string-join(for $x in $aff-tokens return if (contains(.,$x)) then () else concat('&quot;',$x,'&quot;'),' and ')"/>. Is this correct?</report>
     
     <report test="matches(p[1],'\.$')" 
        role="error" 
        id="feature-bio-test-3">bio cannot end  with a full stop - '<value-of select="p[1]"/>'.</report>
     
     <assert test="(count(p) = 1)" 
        role="error" 
        id="feature-bio-test-4">One and only 1 &lt;p&gt; is allowed as a child of bio. <value-of select="."/></assert>
     
     <report test="*[local-name()!='p']" 
        role="error" 
        id="feature-bio-test-5"><value-of select="*[local-name()!='p'][1]/local-name()"/> is not allowed as a child of &lt;bio&gt;. - <value-of select="."/></report>
   </rule>
   
   <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]" id="feature-template-tests">
     <let name="template" value="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
     <let name="type" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
     
     <report test="($template = ('1','2','3')) and child::sub-article" 
        role="error" 
        flag="dl-ar"
        id="feature-template-test-1"><value-of select="$type"/> is a template <value-of select="$template"/> but it has a decision letter or author response, which cannot be correct, as only template 5s are allowed these.</report>
     
     <report test="($template = '5') and not(@article-type='research-article')" 
        role="error" 
        flag="dl-ar"
        id="feature-template-test-2"><value-of select="$type"/> is a template <value-of select="$template"/> so the article element must have a @article-type="research-article". Instead the @article-type="<value-of select="@article-type"/>".</report>
     
     <report test="($template = '5') and not(child::sub-article[@article-type='decision-letter'])" 
        role="warning" 
        id="feature-template-test-3"><value-of select="$type"/> is a template <value-of select="$template"/> but it does not (currently) have a decision letter. Is that OK?</report>
     
     <report test="($template = '5') and not(child::sub-article[@article-type='reply'])" 
        role="warning" 
        id="feature-template-test-4"><value-of select="$type"/> is a template <value-of select="$template"/> but it does not (currently) have an author response. Is that OK?</report>
     
     <report test="front/article-meta/contrib-group[@content-type='section'] and ($template != '5')" 
        role="error" 
        id="feature-templates-no-bre"><value-of select="$type"/> is a template <value-of select="$template"/>, which means that it should not have any BREs. This <value-of select="$type"/> has <value-of select="
          string-join(
          for $x in front/article-meta/contrib-group[@content-type='section']/contrib
          return concat(e:get-name($x/name[1]),' as ',$x/role[1])
          ,
          ' and '
          )
          "/>. Please remove any senior/reviewing editors.</report>
     
     <report test="back/fn-group[@content-type='author-contribution'] and ($template != '5')" 
        role="warning" 
        id="feature-templates-author-cont"><value-of select="$type"/> is a template <value-of select="$template"/>, which means that it should very likely not have any Author contributions. This <value-of select="$type"/> has <value-of select="
          string-join(for $x in back/fn-group[@content-type='author-contribution']/fn
          return concat('&quot;', $x,'&quot;')
          ,
          '; '
          )
          "/>. Please check with eLife production whether author contributions should be present.</report>
   </rule>
   
   <rule context="article[@article-type='article-commentary']//article-meta/abstract" id="insight-asbtract-tests">
     <let name="impact-statement" value="parent::article-meta//custom-meta[meta-name='Author impact statement']/meta-value[1]"/>
     <let name="impact-statement-element-count" value="count(parent::article-meta//custom-meta[meta-name='Author impact statement']/meta-value[1]/*)"/>
     
     <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#insight-abstract-impact-test-1" 
        test=". = $impact-statement" 
        role="warning" 
        id="insight-abstract-impact-test-1">In insights, abstracts must be the same as impact statements. Here the abstract reads "<value-of select="."/>", whereas the impact statement reads "<value-of select="$impact-statement"/>".</assert>
     
     <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/impact-statement#insight-abstract-impact-test-2" 
        test="count(p/*) = $impact-statement-element-count" 
        role="warning" 
        id="insight-abstract-impact-test-2">In insights, abstracts must be the same as impact statements. Here the abstract has <value-of select="count(*)"/> child element(s), whereas the impact statement has <value-of select="$impact-statement-element-count"/> child element(s). Check for possible missing formatting.</assert>
     
   </rule>
   
   <rule context="article[@article-type='article-commentary']//article-meta/related-article" id="insight-related-article-tests">
     <let name="doi" value="@xlink:href"/>
     <let name="text" value="replace(ancestor::article/body/boxed-text[1],' ',' ')"/>
     <let name="citation" value="for $x in ancestor::article//ref-list//element-citation[pub-id[@pub-id-type='doi']=$doi][1]
       return replace(concat(
       string-join(
       for $y in $x/person-group[@person-group-type='author']/*
       return if ($y/name()='name') then concat($y/surname,' ', $y/given-names)
       else $y
       ,', '),
       '. ',
       replace($x/year,'[^\d]',''),
       '. ',
       $x/article-title,
       '. eLife ',
       $x/volume,
       ':',
       $x/elocation-id,
       '. doi: ',
       $x/pub-id[@pub-id-type='doi']),' ',' ')"/>
     
     <assert test="contains($text,$citation)" 
        role="warning" 
        id="insight-box-test-1">A citation for related article <value-of select="$doi"/> is not included in the related-article box text in the body of the article. '<value-of select="$citation"/>' is not present (or is different to the relevant passage) in '<value-of select="$text"/>'. The following word(s) are in the boxed text but not in the citation: <value-of select="string-join(e:insight-box($text,$citation)//*:item[@type='cite'],'; ')"/>. The following word(s) are in the citation but not in the boxed text: <value-of select="string-join(e:insight-box($text,$citation)//*:item[@type='box'],'; ')"/>.</assert>
     
     <assert test="@related-article-type='commentary-article'" 
        role="error" 
        id="insight-related-article-test-1">Insight related article links must have the related-article-type 'commentary-article'. The link for <value-of select="$doi"/> has '<value-of select="@related-article-type"/>'.</assert>
   </rule>
   
   <rule context="article[descendant::article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]]//p|
     article[descendant::article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]]//td|
     article[descendant::article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]]//th" 
     id="feature-comment-tests">
     
     <report test="matches(.,'\[[Oo][Kk]\??\]')" 
       role="error" 
       id="final-feat-ok-test"><value-of select="name()"/> element contains [OK] or [OK?] which should be removed - <value-of select="."/></report>
     
   </rule>
  </pattern>
  
  <pattern id="correction-retraction">
    
    <rule context="article[@article-type = 'correction']" id="correction-tests">
      
      <report test="descendant::article-meta//aff" 
        role="error" 
        id="corr-aff-presence">Correction notices should not contain affiliations.</report>
      
      <report test="descendant::fn-group[@content-type='competing-interest']" 
        role="error" 
        id="corr-COI-presence">Correction notices should not contain competing interests.</report>
      
      <report test="descendant::self-uri" 
        role="error" 
        id="corr-self-uri-presence">Correction notices should not contain a self-uri element (as the PDF is not published).</report>
      
      <report test="descendant::abstract" 
        role="error" 
        id="corr-abstract-presence">Correction notices should not contain abstracts.</report>
      
      <report test="(back/sec[not(@sec-type='supplementary-material')]) or (count(back/sec) gt 1)" 
        role="error" 
        id="corr-back-sec">Correction notices should not contain any sections in the backmatter which are not for supplementary files.</report>
      
      <report test="descendant::meta-name[text() = 'Author impact statement']" 
        role="error" 
        id="corr-impact-statement">Correction notices should not contain an impact statement.</report>
      
      <report test="descendant::contrib-group[@content-type='section']" 
        role="error" 
        id="corr-SE-BRE">Correction notices must not contain any Senior or Reviewing Editors.</report>
      
    </rule>
    
    <rule context="article[@article-type = 'retraction']" id="retraction-tests">
      
      <report test="descendant::article-meta//aff" 
        role="error" 
        id="retr-aff-presence">Retractions should not contain affiliations.</report>
      
      <report test="descendant::fn-group[@content-type='competing-interest']" 
        role="error" 
        id="retr-COI-presence">Retractions should not contain competing interests.</report>
      
      <report test="descendant::self-uri" 
        role="error" 
        id="retr-self-uri-presence">Retractions should not contain a self-uri element (as the PDF is not published).</report>
      
      <report test="descendant::abstract" 
        role="error" 
        id="retr-abstract-presence">Retractions should not contain abstracts.</report>
      
      <report test="back/*" 
        role="error" 
        id="retr-back">Retractions should not contain any content in the back.</report>
      
      <report test="descendant::meta-name[text() = 'Author impact statement']" 
        role="error" 
        id="retr-impact-statement">Retractions should not contain an impact statement.</report>
      
      <report test="descendant::contrib-group[@content-type='section']" 
        role="error" 
        id="retr-SE-BRE">Retractions must not contain any Senior or Reviewing Editors.</report>
       
    </rule>
    
  </pattern>
  
  <pattern id="gene-primer-sequence-pattern">
    
    <rule context="p[not(child::table-wrap)]" id="gene-primer-sequence">
      <let name="count" value="count(descendant::named-content[@content-type='sequence'])"/>
      <let name="text-tokens" value="for $x in tokenize(.,' ') return if (matches($x,'[ACGTacgt]{15,}')) then $x else ()"/>
      <let name="text-count" value="count($text-tokens)"/>
      
      <assert test="($text-count le $count)" 
        role="warning" 
        id="gene-primer-sequence-test">p element contains what looks like an untagged primer or gene sequence - <value-of select="string-join($text-tokens,', ')"/>.</assert>
    </rule>
    
  </pattern>
  
  <pattern id="rrid-org-pattern">
    
    <rule context="p|td|th" id="rrid-org-code">
      <let name="count" value="count(descendant::ext-link[matches(@xlink:href,'scicrunch\.org.*')])"/>
      <let name="lc" value="lower-case(.)"/>
      <let name="text-count" value="number(count(
        for $x in tokenize(.,'RRID:|RRID AB_[\d]+|RRID CVCL_[\d]+|RRID SCR_[\d]+|RRID ISMR_JAX')
        return $x)) -1"/>
      <let name="t" value="replace($lc,'drosophila genetic resource center|bloomington drosophila stock center|drosophila genomics resource center','')"/>
      <let name="code-text" value="string-join(for $x in tokenize(.,' ') return if (matches($x,'^--[a-z]+')) then $x else (),'; ')"/>
      <let name="unequal-equal-text" value="string-join(for $x in tokenize(replace(.,'[&gt;&lt;]',''),' | ') return if (matches($x,'=$|^=') and not(matches($x,'^=$'))) then $x else (),'; ')"/>
      <let name="link-strip-text" value="string-join(for $x in (*[not(matches(local-name(),'^ext-link$|^contrib-id$|^license_ref$|^institution-id$|^email$|^xref$|^monospace$'))]|text()) return $x,'')"/>
      <let name="url-text" value="string-join(for $x in tokenize($link-strip-text,' ')
        return   if (matches($x,'^https?:..(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%_\+.~#?&amp;//=]*)|^ftp://.|^git://.|^tel:.|^mailto:.|\.org[\s]?|\.com[\s]?|\.co.uk[\s]?|\.us[\s]?|\.net[\s]?|\.edu[\s]?|\.gov[\s]?|\.io[\s]?')) then $x
        else (),'; ')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/rrids#rrid-test" 
        test="($text-count gt $count)" 
        role="warning" 
        id="rrid-test">'<name/>' element contains what looks like <value-of select="$text-count - $count"/> unlinked RRID(s). These should always be linked using 'https://scicrunch.org/resolver/'. Element begins with <value-of select="substring(.,1,15)"/>.</report>
      
      <report test="matches($t,$org-regex) and not(descendant::italic[contains(.,e:org-conform($t))]) and not(descendant::element-citation)" 
        role="warning" 
        id="org-test"><name/> element contains an organism - <value-of select="e:org-conform($t)"/> - but there is no italic element with that correct capitalisation or spacing. Is this correct? <name/> element begins with <value-of select="concat(.,substring(.,1,15))"/>.</report>
      
      <report test="not(descendant::monospace) and not(descendant::code) and ($code-text != '')" 
        role="warning" 
        id="code-test"><name/> element contains what looks like unformatted code - '<value-of select="$code-text"/>' - does this need tagging with &lt;monospace/&gt; or &lt;code/&gt;?</report>
      
      <report test="($unequal-equal-text != '') and not(disp-formula[contains(.,'=')]) and not(inline-formula[contains(.,'=')]) and not(child::code) and not(child::monospace)" 
        role="warning" 
        id="cell-spacing-test"><name/> element contains an equal sign with content directly next to one side, but a space on the other, is this correct? - <value-of select="$unequal-equal-text"/></report>
      
      <report test="matches(.,'\+cell[s]?|±cell[s]?') and not(descendant::p[matches(.,'\+cell[s]?|±cell[s]?')]) and not(descendant::td[matches(.,'\+cell[s]?|±cell[s]?')]) and not(descendant::th[matches(.,'\+cell[s]?|±cell[s]?')])" 
        role="warning" 
        id="equal-spacing-test"><name/> element contains the text '+cells' or '±cells' which is very likely to be incorrect spacing - <value-of select="."/></report>
      
      <report test="matches(.,'˚') and not(descendant::p[matches(.,'˚')]) and not(descendant::td[matches(.,'˚')]) and not(descendant::th[matches(.,'˚')])" 
        role="warning" 
        id="ring-diacritic-symbol-test">'<name/>' element contains the ring above symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report test="matches(.,'[Tt]ype\s?[Oo]ne\s?[Dd]iabetes') and not(descendant::p[matches(.,'[Tt]ype\s?[Oo]ne\s?[Dd]iabetes')]) and not(descendant::td[matches(.,'[Tt]ype\s?[Oo]ne\s?[Dd]iabetes')]) and not(descendant::th[matches(.,'[Tt]ype\s?[Oo]ne\s?[Dd]iabetes')])" 
        role="error" 
        id="diabetes-1-test">'<name/>' element contains the phrase 'Type one diabetes'. The number should not be spelled out, this should be 'Type 1 diabetes'.</report>
      
      <report test="matches(.,'[Tt]ype\s?[Tt]wo\s?[Dd]iabetes') and not(descendant::p[matches(.,'[Tt]ype\s?[Tt]wo\s?[Dd]iabetes')]) and not(descendant::td[matches(.,'[Tt]ype\s?[Tt]wo\s?[Dd]iabetes')]) and not(descendant::th[matches(.,'[Tt]ype\s?[Tt]wo\s?[Dd]iabetes')])" 
        role="error" 
        id="diabetes-2-test">'<name/>' element contains the phrase 'Type two diabetes'. The number should not be spelled out, this should be 'Type 2 diabetes'</report>
      
      <report test="not(descendant::p or descendant::td or descendant::th) and not(ancestor::sub-article or child::element-citation) and not(ancestor::fn-group[@content-type='ethics-information']) and not($url-text = '')" 
        role="warning" 
        id="unlinked-url">'<name/>' element contains possible unlinked urls. Check - <value-of select="$url-text"/></report>
      
      <report test="matches(.,'\s[1-2][0-9][0-9]0\ss[\s\.]') and not(descendant::p[matches(.,'\s[1-2][0-9][0-9]0\ss[\s\.]')]) and not(descendant::td) and not(descendant::th)" 
        role="warning" 
        id="year-style-test">'<name/>' element contains the following string(s) - <value-of select="string-join(for $x in tokenize(.,' ')[matches(.,'^[1-2][0-9][0-9]0$')] return concat($x,' s'),'; ')"/>. If this refers to years, then the space should be removed after the number, i.e. <value-of select="string-join(for $x in tokenize(.,' ')[matches(.,'^[1-2][0-9][0-9]0$')] return concat($x,'s'),'; ')"/>. If the text is referring to a unit then this is fine.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/toolkit/archiving-code#final-missing-url-test"
        test="contains(lower-case(.),'url to be added')" 
        role="warning" 
        id="final-missing-url-test"><name/> element contains the text 'URL to be added' - <value-of select="."/>. If this is a software heritage link, then please ensure that it is added. If it is a different URL, then it may be worth querying with the authors to determine what needs to be added.</report>
    </rule>
    
  </pattern>
  
  <pattern id="reference">
    
    <rule context="ref-list//ref" id="duplicate-ref">
      <let name="doi" value="element-citation/pub-id[@pub-id-type='doi']"/>
      <let name="a-title" value="element-citation/article-title[1]"/>
      <let name="c-title" value="element-citation/chapter-title[1]"/>
      <let name="source" value="element-citation/source[1]"/>
      <let name="top-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi'][1]"/>
      
      <report test="(element-citation/@publication-type != 'book') and ($doi = preceding-sibling::ref/element-citation/pub-id[@pub-id-type='doi'])" 
        role="error" 
        id="duplicate-ref-test-1">ref '<value-of select="@id"/>' has the same doi as another reference, which is incorrect. Is it a duplicate?</report>
      
      <report test="(element-citation/@publication-type = 'book') and  ($doi = preceding-sibling::ref/element-citation/pub-id[@pub-id-type='doi'])" 
        role="warning" 
        id="duplicate-ref-test-2">ref '<value-of select="@id"/>' has the same doi as another reference, which might be incorrect. If they are not different chapters from the same book, then this is incorrect.</report>
      
      <report test="some $x in preceding-sibling::ref/element-citation satisfies (
        (($x/article-title = $a-title) and ($x/source = $source))
        or
        (($x/chapter-title = $c-title) and ($x/source = $source))
        )" 
        role="warning" 
        id="duplicate-ref-test-3">ref '<value-of select="@id"/>' has the same title and source as another reference, which is almost certainly incorrect - '<value-of select="$a-title"/>', '<value-of select="$source"/>'.</report>
      
      <report test="some $x in preceding-sibling::ref/element-citation satisfies (
        (($x/article-title = $a-title) and not($x/source = $source))
        or
        (($x/chapter-title = $c-title) and not($x/source = $source))
        )" 
        role="warning" 
        id="duplicate-ref-test-4">ref '<value-of select="@id"/>' has the same title as another reference, but a different source. Is this correct? - '<value-of select="$a-title"/>'</report>
      
      <report test="$top-doi = $doi" 
        role="error" 
        id="duplicate-ref-test-6">ref '<value-of select="@id"/>' has a doi which is the same as the article itself '<value-of select="$top-doi"/>' which must be incorrect.</report>
    </rule>
    
  </pattern>
  
  <pattern id="ref-xref-pattern">
    
    <rule context="xref[@ref-type='bibr']" id="ref-xref-conformance">
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
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#pre-ref-xref-test-1" 
        test="$ref/*/year and (replace(.,' ',' ') != $cite1)" 
        role="error" 
        id="pre-ref-xref-test-1"><value-of select="."/> - citation does not conform to house style. It should be '<value-of select="$cite1"/>'. Preceding text = '<value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>'.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#final-ref-xref-test-1" 
        test="replace(.,' ',' ') = ($cite1,$cite2)" 
        role="error" 
        id="final-ref-xref-test-1"><value-of select="."/> - citation does not conform to house style. It should be '<value-of select="$cite1"/>' or '<value-of select="$cite2"/>'. Preceding text = '<value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>'.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-2" 
        test="matches($pre-text,'[\p{L}\p{N}\p{M}\p{Pe},;]$')" 
        role="warning" 
        id="ref-xref-test-2">There is no space between citation and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-3" 
        test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')" 
        role="warning" 
        id="ref-xref-test-3">There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#pre-ref-xref-test-4" 
        test="matches(normalize-space(.),'\p{N}')" 
        role="warning" 
        id="pre-ref-xref-test-4">citation doesn't contain numbers, which must be incorrect - <value-of select="."/>. If there is no year for this reference, and you are unable to determine this yourself, please query the authors.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#final-ref-xref-test-4" 
        test="matches(normalize-space(.),'\p{N}')" 
        role="error" 
        id="final-ref-xref-test-4">citation doesn't contain numbers, which must be incorrect - <value-of select="."/>. If there is no year for this reference, and you are unable to determine this yourself, please query the authors.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-5" 
        test="matches(normalize-space(.),'\p{L}')" 
        role="error" 
        id="ref-xref-test-5">citation doesn't contain letters, which must be incorrect - <value-of select="."/>.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-7"
        test="($open - $close) gt 1" 
        role="warning" 
        id="ref-xref-test-7">citation is preceded by text containing 2 or more open brackets, '('. eLife style is that parenthetical citations already in brackets should be contained in square brackets, '['. Either there is a superfluous '(' in the preceding text, or the '(' needs changing to a '['  - <value-of select="concat(substring($pre-text,string-length($pre-text)-10),.,substring($post-text,1,10))"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-11" 
        test="matches($pre-sentence,' from\s*[\(]+$| in\s*[\(]+$| by\s*[\(]+$| of\s*[\(]+$| on\s*[\(]+$| to\s*[\(]+$| see\s*[\(]+$| see also\s*[\(]+$| at\s*[\(]+$| per\s*[\(]+$| follows\s*[\(]+$| following\s*[\(]+$')" 
        role="warning" 
        id="ref-xref-test-11">'<value-of select="concat(substring($pre-text,string-length($pre-text)-10),.)"/>' - citation is preceded by text ending with a possessive, preposition or verb and bracket which suggests the bracket should be removed.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-12" 
        test="matches($post-text,'^[\)]+\s*who|^[\)]+\s*have|^[\)]+\s*found|^[\)]+\s*used|^[\)]+\s*demonstrate|^[\)]+\s*follow[s]?|^[\)]+\s*followed')" 
        role="warning" 
        id="ref-xref-test-12">'<value-of select="concat(.,substring($post-text,1,10))"/>' - citation is followed by a bracket and a possessive, preposition or verb which suggests the bracket is unnecessary.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-14" 
        test="matches($pre-sentence,$cite3)" 
        role="warning" 
        id="ref-xref-test-14">citation is preceded by text containing much of the citation text which is possibly unnecessary - <value-of select="concat($pre-sentence,.)"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-15" 
        test="matches($post-sentence,$cite3)" 
        role="warning" 
        id="ref-xref-test-15">citation is followed by text containing much of the citation text. Is this correct? - '<value-of select="concat(.,$post-sentence)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-13" 
        test="matches($pre-sentence,'\(\[\s?$')" 
        role="warning" 
        id="ref-xref-test-13">citation is preceded by '(['. Is the square bracket unnecessary? - <value-of select="concat($pre-sentence,.)"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-16" 
        test="matches($post-sentence,'^\s?\)\)')" 
        role="error" 
        id="ref-xref-test-16">citation is followed by '))'. Either one of the brackets is unnecessary or the reference needs to be placed in square brackets - <value-of select="concat(.,$post-sentence)"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-17" 
        test="matches($pre-sentence,'\(\(\s?$')" 
        role="error" 
        id="ref-xref-test-17">citation is preceded by '(('. Either one of the brackets is unnecessary or the reference needs to be placed in square brackets - <value-of select="concat($pre-sentence,.)"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-10" 
        test="matches($pre-sentence,'\(\s?$') and ((string-length(replace($pre-sentence,'[^\(]','')) - string-length(replace($pre-sentence,'[^\)]',''))) gt 1)" 
        role="warning" 
        id="ref-xref-test-10">citation is preceded by '(', and appears to already be in a brackets. Should the bracket(s) around the citation be removed? Or replaced with square brackets? - <value-of select="concat($pre-sentence,.,$post-sentence)"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-18" 
        test="matches($pre-sentence,'\(\s?$') and matches($post-sentence,'^\s?\);') and (following-sibling::*[1]/name()='xref')" 
        role="warning" 
        id="ref-xref-test-18">citation is preceded by '(', and followed by ');'. Should the brackets be removed? - <value-of select="concat($pre-sentence,.,$post-sentence)"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#pre-ref-xref-test-19" 
        test="matches(.,'^et al|^ and|^\(\d|^,')" 
        role="warning" 
        id="pre-ref-xref-test-19"><value-of select="."/> - citation doesn't start with an author's name. If this information is missing, please ensure to query the authors asking for the details for this reference.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#final-ref-xref-test-19" 
        test="matches(.,'^et al|^ and|^\(\d|^,')" 
        role="error" 
        id="final-ref-xref-test-19"><value-of select="."/> - citation doesn't start with an author's name which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-20" 
        test="matches($post-text,'^\);\s?$') and (following-sibling::*[1]/local-name() = 'xref')" 
        role="error" 
        id="ref-xref-test-20">citation is followed by ');', which in turn is followed by another link. This must be incorrect (the bracket should be removed) - '<value-of select="concat(.,$post-sentence,following-sibling::*[1])"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-21" 
        test="matches($pre-sentence,'[A-Za-z0-9]\($')" 
        role="warning" 
        id="ref-xref-test-21">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-sentence,.)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-22" 
        test="matches($post-sentence,'^\)[A-Za-z0-9]')" 
        role="warning" 
        id="ref-xref-test-22">citation is followed by a ')' which in turns is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-sentence)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-26" 
        test="matches($pre-text,'; \[$')" 
        role="warning" 
        id="ref-xref-test-26">citation is preceded by '; [' - '<value-of select="concat(substring($pre-text,string-length($pre-text)-10),.,substring($post-text,1,1))"/>' - Are the square bracket(s) surrounding the citation required? If this citation is already in a bracketed sentence, then it's very likely they can be removed.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-27" 
        test="matches($post-text,'^\)\s?\($') and (following-sibling::*[1]/local-name() = 'xref')" 
        role="warning" 
        id="ref-xref-test-27">citation is followed by ') (', which in turn is followed by another link - '<value-of select="concat(.,$post-sentence,following-sibling::*[1])"/>'. Should the closing and opening brackets be replaced with a '; '? i.e. '<value-of select="concat(.,'; ',following-sibling::*[1])"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-28" 
        test="matches($pre-text,'^\)\s?\($') and (preceding-sibling::*[1]/local-name() = 'xref')" 
        role="warning" 
        id="ref-xref-test-28">citation is preceded by ') (', which in turn is preceded by another link - '<value-of select="concat(preceding-sibling::*[1],$pre-sentence,.)"/>'. Should the closing and opening brackets be replaced with a '; '? i.e. '<value-of select="concat(preceding-sibling::*[1],'; ',.)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/reference-citations#ref-xref-test-29" 
        test="matches($post-text,'^\);\s?$') and (starts-with(following-sibling::*[1]/following-sibling::text()[1],')') or starts-with(following-sibling::*[1]/following-sibling::text()[1],';)'))" 
        role="warning" 
        id="ref-xref-test-29">citation is followed by ');', which in turn is followed by something else followed by ')'. Is this punctuation correct? - '<value-of select="concat(.,$post-text,following-sibling::*[1],tokenize(following-sibling::*[1]/following-sibling::text()[1],'\. ')[position() = 1])"/>'.</report>
    </rule>
    
  </pattern>
  
  <pattern id="unlinked-ref-cite-pattern">
    <rule context="ref-list/ref/element-citation[year]" id="unlinked-ref-cite">
      <let name="id" value="parent::ref/@id"/>
      <let name="cite1" value="e:citation-format1(.)"/>
      <let name="cite1.5" value="e:citation-format2(.)"/>
      <let name="cite2" value="concat(substring-before($cite1.5,'('),'\(',descendant::year[1],'\)')"/>
      <let name="regex" value="concat(replace(replace($cite1,'\.','\\.?'),',',',?'),'|',replace(replace($cite2,'\.','\\.?'),',',',?'))"/>
      <let name="article-text" value="string-join(for $x in ancestor::article/*[local-name() = 'body' or local-name() = 'back']//*
        return
        if ($x/ancestor::sec[@sec-type='data-availability']) then ()
        else if ($x/ancestor::sec[@sec-type='additional-information']) then ()
        else if ($x/ancestor::ref-list) then ()
        else if ($x/local-name() = 'xref') then ()
        else $x/text(),'')"/>
      
      <report test="matches($article-text,$regex)" 
        role="error" 
        id="text-v-cite-test">ref with id <value-of select="$id"/> has unlinked citations in the text - search <value-of select="$cite1"/> or <value-of select="$cite1.5"/>.</report>
      
    </rule>
  </pattern>
  
  <pattern id="missing-ref-cited-pattern">
    
    <rule context="p[(ancestor::app or ancestor::body[parent::article]) and not(child::table-wrap) and not(child::supplementary-material)]|td[ancestor::app or ancestor::body[parent::article]]|th[ancestor::app or ancestor::body[parent::article]]" id="missing-ref-cited">
      <let name="text" value="string-join(for $x in self::*/(*|text())
        return if ($x/local-name()='xref') then ()
        else string($x),'')"/>
      <let name="missing-ref-regex" value="'[A-Z][A-Za-z]+ et al\.?, [1][7-9][0-9][0-9]|[A-Z][A-Za-z]+ et al\.?, [2][0-2][0-9][0-9]|[A-Z][A-Za-z]+ et al\.? [\(]?[1][7-9][0-9][0-9][\)]?|[A-Z][A-Za-z]+ et al\.? [\(]?[1][7-9][0-9][0-9][\)]?'"/>
      
      <report test="matches($text,$missing-ref-regex)" 
        role="warning" 
        id="missing-ref-in-text-test"><name/> element contains possible citation which is unlinked or a missing reference - search - <value-of select="concat(

tokenize(substring-before($text,' et al'),' ')[last()],
' et al ',
tokenize(substring-after($text,' et al'),' ')[2]
)"/></report>
      
    </rule>
    
  </pattern>
  
  <pattern id="unlinked-object-cite-pattern">
    <rule context="fig[not(ancestor::sub-article) and label]|
      table-wrap[not(ancestor::sub-article) and label[not(contains(.,'ey resources table'))]]|
      media[not(ancestor::sub-article) and label]|
      supplementary-material[not(ancestor::sub-article) and label]" id="unlinked-object-cite">
      <let name="cite1" value="replace(label[1],'\.','')"/>
      <let name="regex" value="replace($cite1,'—','[—–\\-]')"/>
      <let name="article-text" value="string-join(
        for $x in ancestor::article/*[local-name() = 'body' or local-name() = 'back']//*
        return if ($x/local-name()='label') then ()
        else if ($x/ancestor::sub-article or $x/local-name()='sub-article') then ()
        else if ($x/ancestor::sec[@sec-type='data-availability']) then ()
        else if ($x/ancestor::sec[@sec-type='additional-information']) then ()
        else if ($x/ancestor::ref-list) then ()
        else if ($x/local-name() = 'xref') then ()
        else $x/text(),'')"/>
      
      <report test="matches($article-text,$regex)" 
        role="warning" 
        id="text-v-object-cite-test"><value-of select="$cite1"/> has possible unlinked citations in the text.</report>
      
    </rule>
  </pattern>
  
  <pattern id="video-xref-pattern">
    
    <rule context="xref[@ref-type='video']" id="vid-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="target-no" value="substring-after($rid,'video')"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <assert test="matches(.,'\p{N}')" 
        role="error" 
        id="vid-xref-conformity-1"><value-of select="."/> - video citation does not contain any numbers which must be incorrect.</assert>
      
      <!-- Workaround for animations -->
      <report test="not(contains(.,'nimation')) and not(contains(.,$target-no))" 
        role="error" 
        id="vid-xref-conformity-2">video citation does not matches the video that it links to. Target video label number is <value-of select="$target-no"/>, but that number is not in the citation text - <value-of select="."/>.</report>
      
      <report test="matches($pre-text,'[\p{L}\p{N}\p{M}\p{Pe},;]$')" 
        role="warning" 
        id="vid-xref-test-2">There is no space between citation and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')" 
        role="warning" 
        id="vid-xref-test-3">There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <report test="(ancestor::media[@mimetype='video']/@id = $rid)" 
        role="warning" 
        id="vid-xref-test-4"><value-of select="."/> - video citation is in the caption of the video that it links to. Is it correct or necessary?</report>
      
      <report test="(matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')" 
        role="error" 
        id="vid-xref-test-5"><value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Video citation is in a reference to a video from a different paper, and therefore must be unlinked.</report>
      
      <report test="matches($pre-text,'[A-Za-z0-9][\(]$')" 
        role="warning" 
        id="vid-xref-test-6">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($post-text,'^[\)][A-Za-z0-9]')" 
        role="warning" 
        id="vid-xref-test-7">citation is followed by a ')' which in turns is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($post-text,'^[\s]?[\s—\-][\s]?[Ss]ource')" 
        role="error" 
        id="vid-xref-test-8">Incomplete citation. Video citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($pre-text,'[Ff]igure [0-9]{1,3}[\s]?[\s—\-][\s]?$')" 
        role="error" 
        id="vid-xref-test-9">Incomplete citation. Video citation is preceded by text which suggests it should instead be a link to figure level source data or code - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($pre-text,'cf[\.]?\s?[\(]?$')" 
        role="warning" 
        id="vid-xref-test-10">citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
      
      <report test="contains(lower-case(.),'figure') and contains(.,'Video')" 
        role="warning" 
        id="vid-xref-test-11">Figure video citation contains 'Video', when it should contain 'video' with a lowercase v - <value-of select="."/>.</report>
      
    </rule>
  </pattern>
  
  <pattern id="figure-xref-pattern">
    
    <rule context="xref[@ref-type='fig' and @rid]" id="fig-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="type" value="e:fig-id-type($rid)"/>
      <let name="no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="target-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="pre-text" value="replace(preceding-sibling::text()[1],'[—–‒]','-')"/>
      <let name="post-text" value="replace(following-sibling::text()[1],'[—–‒]','-')"/>
      
      <assert test="matches(.,'\p{N}')" 
        role="error" 
        id="fig-xref-conformity-1"><value-of select="."/> - figure citation does not contain any numbers which must be incorrect.</assert>
      
      <report test="($type = 'Figure') and not(contains($no,$target-no))" 
        role="error" 
        id="fig-xref-conformity-2"><value-of select="."/> - figure citation does not appear to link to the same place as the content of the citation suggests it should.</report>
      
      <report test="($type = 'Figure') and ($no != $target-no)" 
        role="warning" 
        id="fig-xref-conformity-3"><value-of select="."/> - figure citation does not appear to link to the same place as the content of the citation suggests it should.</report>
      
      <report test="($type = 'Figure') and matches(.,'[Ss]upplement')" 
        role="error" 
        id="fig-xref-conformity-4"><value-of select="."/> - figure citation links to a figure, but it contains the string 'supplement'. It cannot be correct.</report>
      
      <report test="($type = 'Figure supplement') and (not(matches(.,'[Ss]upplement'))) and (not(matches(preceding-sibling::text()[1],'–[\s]?$| and $| or $|,[\s]?$')))" 
        role="warning" 
        id="fig-xref-conformity-5">figure citation stands alone, contains the text <value-of select="."/>, and links to a figure supplement, but it does not contain the string 'supplement'. Is it correct? Preceding text - '<value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>'</report>
      
      <report test="($type = 'Figure supplement') and ($target-no != $no) and not(contains($no,substring($target-no, string-length($target-no), 1)))" 
        role="error" 
        id="fig-xref-conformity-6">figure citation contains the text <value-of select="."/> but links to a figure supplement with the id <value-of select="$rid"/> which cannot be correct.</report>
      
      <report test="matches($pre-text,'[\p{L}\p{N}\p{M}\p{Pe},;]$')" 
        role="warning" 
        id="fig-xref-test-2">There is no space between citation and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')" 
        role="warning" 
        id="fig-xref-test-3">There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <report test="not(ancestor::supplementary-material) and not(ancestor::license-p) and (ancestor::fig/@id = $rid)" 
        role="warning" 
        id="fig-xref-test-4"><value-of select="."/> - Figure citation is in the caption of the figure that it links to. Is it correct or necessary?</report>
      
      <report test="($type = 'Figure') and (matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')" 
        role="error" 
        id="fig-xref-test-5"><value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Figure citation is in a reference to a figure from a different paper, and therefore must be unlinked.</report>
      
      <report test="matches($pre-text,'[A-Za-z0-9][\(]$')" 
        role="error" 
        id="fig-xref-test-6">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($post-text,'^[\)][A-Za-z0-9]')" 
        role="error" 
        id="fig-xref-test-7">citation is followed by a ')' which in turns is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($pre-text,'their $')" 
        role="warning" 
        id="fig-xref-test-8">Figure citation is preceded by 'their'. Does this refer to a figure in other content (and as such should be captured as plain text)? - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($post-text,'^ of [\p{Lu}][\p{Ll}]+[\-]?[\p{Ll}]? et al[\.]?')" 
        role="warning" 
        id="fig-xref-test-9">Is this figure citation a reference to a figure from other content (and as such should be captured instead as plain text)? - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($post-text,'^[\s]?[\s—\-][\s]?[Ff]igure supplement')" 
        role="error" 
        id="fig-xref-test-10">Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to a Figure supplement - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($post-text,'^[\s]?[\s—\-][\s]?[Vv]ideo')" 
        role="error" 
        id="fig-xref-test-11">Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to a video supplement - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($post-text,'^[\s]?[\s—\-][\s]?[Ss]ource')" 
        role="warning" 
        id="fig-xref-test-12">Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($post-text,'^[\s]?[Ss]upplement|^[\s]?[Ff]igure [Ss]upplement|^[\s]?[Ss]ource|^[\s]?[Vv]ideo')" 
        role="warning" 
        id="fig-xref-test-13">Figure citation is followed by text which suggests it could be an incomplete citation - <value-of select="concat(.,$post-text)"/>'. Is this OK?</report>
      
      <report test="matches($pre-text,'cf[\.]?\s?[\(]?$')" 
        role="warning" 
        id="fig-xref-test-14">citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
      
      <report test="matches(.,' [Ff]ig[\.]? ')" 
        role="error" 
        id="fig-xref-test-15">Link - '<value-of select="."/>' - is incomplete. It should have 'figure' or 'Figure' spelt out.</report>
      
      <report test="matches($pre-text,'[Ss]uppl?[\.]?\s?$|[Ss]upp?l[ea]mental\s?$|[Ss]upp?l[ea]mentary\s?$|[Ss]upp?l[ea]ment\s?$')" 
        role="warning" 
        id="fig-xref-test-16">Figure citation - '<value-of select="."/>' - is preceded by the text '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>' - should it be a figure supplement citation instead?</report>
      
      <report test="matches(.,'[A-Z]$') and matches($post-text,'^\s?and [A-Z] |^\s?and [A-Z]\.')" 
        role="warning" 
        id="fig-xref-test-17">Figure citation - '<value-of select="."/>' - is followed by the text '<value-of select="substring($post-text,1,7)"/>' - should this text be included in the link text too (i.e. '<value-of select="concat(.,substring($post-text,1,6))"/>')?</report>
      
      <report test="matches($post-text,'^\-[A-Za-z0-9]')" 
        role="warning" 
        id="fig-xref-test-18">Figure citation - '<value-of select="."/>' - is followed by the text '<value-of select="substring($post-text,1,10)"/>' - should some or all of that text be included in the citation text?</report>
    </rule>
  </pattern>
  
  <pattern id="table-xref-pattern">
    <rule context="xref[@ref-type='table']" id="table-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="text-no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="rid-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-conformity-1" 
        test="not(matches(.,'Table')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ') and not(contains($rid,'app')) and not(contains($rid,'resp'))" 
        role="warning" 
        id="table-xref-conformity-1"><value-of select="."/> - citation points to table, but does not include the string 'Table', which is very unusual.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-conformity-2" 
        test="not(matches(.,'table')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ') and contains($rid,'app')" 
        role="warning" 
        id="table-xref-conformity-2"><value-of select="."/> - citation points to an Appendix table, but does not include the string 'table', which is very unusual.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-conformity-3" 
        test="(not(contains($rid,'app'))) and ($text-no != $rid-no) and not(contains(.,'–'))" 
        role="warning" 
        id="table-xref-conformity-3"><value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-conformity-4" 
        test="(contains($rid,'app')) and (not(ends-with($text-no,substring($rid-no,2)))) and not(contains(.,'–'))" 
        role="warning" 
        id="table-xref-conformity-4"><value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-test-1" 
        test="(ancestor::table-wrap/@id = $rid) and not(ancestor::supplementary-material)" 
        role="warning" 
        id="table-xref-test-1"><value-of select="."/> - Citation is in the caption of the Table that it links to. Is it correct or necessary?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-test-2" 
        test="matches($pre-text,'[A-Za-z0-9][\(]$')" 
        role="warning" 
        id="table-xref-test-2">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-test-3" 
        test="matches($post-text,'^[\)][A-Za-z0-9]')" 
        role="warning" 
        id="table-xref-test-3">citation is followed by a ')' which in turns is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-test-4" 
        test="matches($post-text,'^[\s]?[\s—\-][\s]?[Ss]ource')" 
        role="error" 
        id="table-xref-test-4">Incomplete citation. Table citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-test-5" 
        test="matches($pre-text,'cf[\.]?\s?[\(]?$')" 
        role="warning" 
        id="table-xref-test-5">citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/asset-citations#table-xref-test-6" 
        test="matches($pre-text,'[Ss]uppl?[\.]?\s?$|[Ss]upp?l[ea]mental\s?$|[Ss]upp?l[ea]mentary\s?$|[Ss]upp?l[ea]ment\s?$')" 
        role="warning" 
        id="table-xref-test-6">Table citation - '<value-of select="."/>' - is preceded by the text '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>' - should it be a Supplementary file citation instead?</report>
    </rule>
    
  </pattern>
  
  <pattern id="supp-xref-pattern">
    
    <rule context="xref[@ref-type='supplementary-material']" id="supp-file-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="text-no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="last-text-no" value="substring($text-no,string-length($text-no), 1)"/>
      <let name="rid-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="last-rid-no" value="substring($rid-no,string-length($rid-no))"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <report test="contains($rid,'data') and not(matches(.,'[Ss]ource data')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ')" 
        role="warning" 
        id="supp-file-xref-conformity-1"><value-of select="."/> - citation points to source data, but does not include the string 'source data', which is very unusual.</report>
      
      <report test="contains($rid,'code') and not(matches(.,'[Ss]ource code')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ')" 
        role="warning" 
        id="supp-file-xref-conformity-2"><value-of select="."/> - citation points to source code, but does not include the string 'source code', which is very unusual.</report>
      
      <report test="contains($rid,'supp') and not(matches(.,'[Ss]upplementary file')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ')" 
        role="warning" 
        id="supp-file-xref-conformity-3"><value-of select="."/> - citation points to a supplementary file, but does not include the string 'Supplementary file', which is very unusual.</report>
      
      <assert test="contains(.,$last-rid-no)" 
        role="error" 
        id="supp-file-xref-conformity-4"><value-of select="."/> - It looks like the citation content does not match what it directs to.</assert>
      
      <assert test="$last-text-no = $last-rid-no" 
        role="warning" 
        id="supp-file-xref-conformity-5"><value-of select="."/> - It looks like the citation content does not match what it directs to. Check that it is correct.</assert>
      
      <report test="ancestor::supplementary-material/@id = $rid" 
        role="warning" 
        id="supp-file-xref-test-1"><value-of select="."/> - Citation is in the caption of the Supplementary file that it links to. Is it correct or necessary?</report>
      
      <report test="matches($pre-text,'[A-Za-z0-9][\(]$')" 
        role="warning" 
        id="supp-xref-test-2">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($post-text,'^[\)][A-Za-z0-9]')" 
        role="warning" 
        id="supp-xref-test-3">citation is followed by a ')' which in turns is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($pre-text,'[Ff]igure [\d]{1,2}[\s]?[\s—\-][\s]?$|[Vv]ideo [\d]{1,2}[\s]?[\s—\-][\s]?$|[Tt]able [\d]{1,2}[\s]?[\s—\-][\s]?$')" 
        role="error" 
        id="supp-xref-test-4">Incomplete citation. <value-of select="."/> citation is preceded by text which suggests it should instead be a link to Figure/Video/Table level source data or code - <value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($pre-text,'cf[\.]?\s?[\(]?$')" 
        role="warning" 
        id="supp-xref-test-5">citation is preceded by '<value-of select="substring($pre-text,string-length($pre-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
      
      <report test="contains(.,'—Source')" 
        role="warning" 
        id="supp-xref-test-6">citation contains '—Source' (<value-of select="."/>). If it refers to asset level source data or code, then 'Source' should be spelled with a lowercase s, as in the label for that file.</report>
      
    </rule>
  </pattern>
  
  <pattern id="equation-xref-pattern">
    
    <rule context="xref[@ref-type='disp-formula']" id="equation-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="label" value="translate(ancestor::article//disp-formula[@id = $rid]/label,'()','')"/>
      <let name="prec-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <report test="not(matches(.,'[Ee]quation')) and ($prec-text != ' and ') and ($prec-text != '–')" 
        role="warning" 
        id="equ-xref-conformity-1"><value-of select="."/> - link points to equation, but does not include the string 'Equation', which is unusual. Is it correct?</report>
      
      <assert test="contains(.,$label)" 
        role="warning" 
        id="equ-xref-conformity-2">equation link content does not match what it directs to (content = <value-of select="."/>; label = <value-of select="$label"/>). Is this correct?</assert>
      
      <report test="(matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')" 
        role="error" 
        id="equ-xref-conformity-3"><value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Equation citation appears to be a reference to an equation from a different paper, and therefore must be unlinked.</report>
      
      <report test="matches($prec-text,'cf[\.]?\s?[\(]?$')" 
        role="warning" 
        id="equ-xref-conformity-4">citation is preceded by '<value-of select="substring($prec-text,string-length($prec-text)-10)"/>'. The 'cf.' is unnecessary and should be removed.</report>
    </rule>
    
  </pattern>
  
  <pattern id="org-pattern">
    
    <rule context="element-citation/article-title|element-citation/chapter-title|element-citation/source|element-citation/data-title" id="org-ref-article-book-title">	
      <let name="lc" value="lower-case(.)"/>
      
      <report test="matches($lc,'b\.\s?subtilis') and not(italic[contains(text() ,'B. subtilis')])" 
        role="info" 
        id="bssubtilis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'B. subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'bacillus\s?subtilis') and not(italic[contains(text() ,'Bacillus subtilis')])" 
        role="info" 
        id="bacillusssubtilis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Bacillus subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?melanogaster') and not(italic[contains(text() ,'D. melanogaster')])" 
        role="info" 
        id="dsmelanogaster-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'D. melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?melanogaster') and not(italic[contains(text() ,'Drosophila melanogaster')])" 
        role="info" 
        id="drosophilasmelanogaster-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Drosophila melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?coli') and not(italic[contains(text() ,'E. coli')])" 
        role="info" 
        id="escoli-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'escherichia\s?coli') and not(italic[contains(text() ,'Escherichia coli')])" 
        role="info" 
        id="escherichiascoli-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Escherichia coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pombe') and not(italic[contains(text() ,'S. pombe')])" 
        role="info" 
        id="sspombe-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schizosaccharomyces\s?pombe') and not(italic[contains(text() ,'Schizosaccharomyces pombe')])" 
        role="info" 
        id="schizosaccharomycesspombe-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Schizosaccharomyces pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?cerevisiae') and not(italic[contains(text() ,'S. cerevisiae')])" 
        role="info" 
        id="sscerevisiae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'saccharomyces\s?cerevisiae') and not(italic[contains(text() ,'Saccharomyces cerevisiae')])" 
        role="info" 
        id="saccharomycesscerevisiae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Saccharomyces cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?elegans') and not(italic[contains(text() ,'C. elegans')])" 
        role="info" 
        id="cselegans-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'caenorhabditis\s?elegans') and not(italic[contains(text() ,'Caenorhabditis elegans')])" 
        role="info" 
        id="caenorhabditisselegans-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Caenorhabditis elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'a\.\s?thaliana') and not(italic[contains(text() ,'A. thaliana')])" 
        role="info" 
        id="asthaliana-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'A. thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'arabidopsis\s?thaliana') and not(italic[contains(text() ,'Arabidopsis thaliana')])" 
        role="info" 
        id="arabidopsissthaliana-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Arabidopsis thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?thermophila') and not(italic[contains(text() ,'M. thermophila')])" 
        role="info" 
        id="msthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'M. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'myceliophthora\s?thermophila') and not(italic[contains(text() ,'Myceliophthora thermophila')])" 
        role="info" 
        id="myceliophthorasthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Myceliophthora thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'dictyostelium') and not(italic[contains(text() ,'Dictyostelium')])" 
        role="info" 
        id="dictyostelium-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Dictyostelium' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?falciparum') and not(italic[contains(text() ,'P. falciparum')])" 
        role="info" 
        id="psfalciparum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'P. falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plasmodium\s?falciparum') and not(italic[contains(text() ,'Plasmodium falciparum')])" 
        role="info" 
        id="plasmodiumsfalciparum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Plasmodium falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?enterica') and not(italic[contains(text() ,'S. enterica')])" 
        role="info" 
        id="ssenterica-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salmonella\s?enterica') and not(italic[contains(text() ,'Salmonella enterica')])" 
        role="info" 
        id="salmonellasenterica-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Salmonella enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pyogenes') and not(italic[contains(text() ,'S. pyogenes')])" 
        role="info" 
        id="sspyogenes-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'streptococcus\s?pyogenes') and not(italic[contains(text() ,'Streptococcus pyogenes')])" 
        role="info" 
        id="streptococcusspyogenes-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Streptococcus pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?dumerilii') and not(italic[contains(text() ,'P. dumerilii')])" 
        role="info" 
        id="psdumerilii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'P. dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'platynereis\s?dumerilii') and not(italic[contains(text() ,'Platynereis dumerilii')])" 
        role="info" 
        id="platynereissdumerilii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Platynereis dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?cynocephalus') and not(italic[contains(text() ,'P. cynocephalus')])" 
        role="info" 
        id="pscynocephalus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'P. cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'papio\s?cynocephalus') and not(italic[contains(text() ,'Papio cynocephalus')])" 
        role="info" 
        id="papioscynocephalus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Papio cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'o\.\s?fasciatus') and not(italic[contains(text() ,'O. fasciatus')])" 
        role="info" 
        id="osfasciatus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'O. fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'oncopeltus\s?fasciatus') and not(italic[contains(text() ,'Oncopeltus fasciatus')])" 
        role="info" 
        id="oncopeltussfasciatus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Oncopeltus fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?crassa') and not(italic[contains(text() ,'N. crassa')])" 
        role="info" 
        id="nscrassa-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'N. crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'neurospora\s?crassa') and not(italic[contains(text() ,'Neurospora crassa')])" 
        role="info" 
        id="neurosporascrassa-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Neurospora crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?intestinalis') and not(italic[contains(text() ,'C. intestinalis')])" 
        role="info" 
        id="csintestinalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'ciona\s?intestinalis') and not(italic[contains(text() ,'Ciona intestinalis')])" 
        role="info" 
        id="cionasintestinalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Ciona intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?cuniculi') and not(italic[contains(text() ,'E. cuniculi')])" 
        role="info" 
        id="escuniculi-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'encephalitozoon\s?cuniculi') and not(italic[contains(text() ,'Encephalitozoon cuniculi')])" 
        role="info" 
        id="encephalitozoonscuniculi-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Encephalitozoon cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?salinarum') and not(italic[contains(text() ,'H. salinarum')])" 
        role="info" 
        id="hssalinarum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'H. salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'halobacterium\s?salinarum') and not(italic[contains(text() ,'Halobacterium salinarum')])" 
        role="info" 
        id="halobacteriumssalinarum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Halobacterium salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?solfataricus') and not(italic[contains(text() ,'S. solfataricus')])" 
        role="info" 
        id="sssolfataricus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'sulfolobus\s?solfataricus') and not(italic[contains(text() ,'Sulfolobus solfataricus')])" 
        role="info" 
        id="sulfolobusssolfataricus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Sulfolobus solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?mediterranea') and not(italic[contains(text() ,'S. mediterranea')])" 
        role="info" 
        id="ssmediterranea-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schmidtea\s?mediterranea') and not(italic[contains(text() ,'Schmidtea mediterranea')])" 
        role="info" 
        id="schmidteasmediterranea-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Schmidtea mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?rosetta') and not(italic[contains(text() ,'S. rosetta')])" 
        role="info" 
        id="ssrosetta-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salpingoeca\s?rosetta') and not(italic[contains(text() ,'Salpingoeca rosetta')])" 
        role="info" 
        id="salpingoecasrosetta-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Salpingoeca rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?vectensis') and not(italic[contains(text() ,'N. vectensis')])" 
        role="info" 
        id="nsvectensis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'N. vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nematostella\s?vectensis') and not(italic[contains(text() ,'Nematostella vectensis')])" 
        role="info" 
        id="nematostellasvectensis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Nematostella vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?aureus') and not(italic[contains(text() ,'S. aureus')])" 
        role="info" 
        id="ssaureus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'staphylococcus\s?aureus') and not(italic[contains(text() ,'Staphylococcus aureus')])" 
        role="info" 
        id="staphylococcussaureus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Staphylococcus aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'v\.\s?cholerae') and not(italic[contains(text() ,'V. cholerae')])" 
        role="info" 
        id="vscholerae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'V. cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'vibrio\s?cholerae') and not(italic[contains(text() ,'Vibrio cholerae')])" 
        role="info" 
        id="vibrioscholerae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Vibrio cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'t\.\s?thermophila') and not(italic[contains(text() ,'T. thermophila')])" 
        role="info" 
        id="tsthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'T. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'tetrahymena\s?thermophila') and not(italic[contains(text() ,'Tetrahymena thermophila')])" 
        role="info" 
        id="tetrahymenasthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Tetrahymena thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?reinhardtii') and not(italic[contains(text() ,'C. reinhardtii')])" 
        role="info" 
        id="csreinhardtii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydomonas\s?reinhardtii') and not(italic[contains(text() ,'Chlamydomonas reinhardtii')])" 
        role="info" 
        id="chlamydomonassreinhardtii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Chlamydomonas reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?attenuata') and not(italic[contains(text() ,'N. attenuata')])" 
        role="info" 
        id="nsattenuata-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'N. attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nicotiana\s?attenuata') and not(italic[contains(text() ,'Nicotiana attenuata')])" 
        role="info" 
        id="nicotianasattenuata-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Nicotiana attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?carotovora') and not(italic[contains(text() ,'E. carotovora')])" 
        role="info" 
        id="escarotovora-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'erwinia\s?carotovora') and not(italic[contains(text() ,'Erwinia carotovora')])" 
        role="info" 
        id="erwiniascarotovora-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Erwinia carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?faecalis') and not(italic[contains(text() ,'E. faecalis')])" 
        role="info" 
        id="esfaecalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?sapiens') and not(italic[contains(text() ,'H. sapiens')])" 
        role="info" 
        id="hsapiens-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'H. sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'homo\s?sapiens') and not(italic[contains(text() ,'Homo sapiens')])" 
        role="info" 
        id="homosapiens-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Homo sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?trachomatis') and not(italic[contains(text() ,'C. trachomatis')])" 
        role="info" 
        id="ctrachomatis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydia\s?trachomatis') and not(italic[contains(text() ,'Chlamydia trachomatis')])" 
        role="info" 
        id="chlamydiatrachomatis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Chlamydia trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'enterococcus\s?faecalis') and not(italic[contains(text() ,'Enterococcus faecalis')])" 
        role="info" 
        id="enterococcussfaecalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Enterococcus faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'x\.\s?laevis') and not(italic[contains(text() ,'X. laevis')])" 
        role="info" 
        id="xlaevis-ref-article-title-check"><name/> contains an organism - 'X. laevis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus\s?laevis') and not(italic[contains(text() ,'Xenopus laevis')])" 
        role="info" 
        id="xenopuslaevis-ref-article-title-check"><name/> contains an organism - 'Xenopus laevis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'x\.\s?tropicalis') and not(italic[contains(text() ,'X. tropicalis')])" 
        role="info" 
        id="xtropicalis-ref-article-title-check"><name/> contains an organism - 'X. tropicalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus\s?tropicalis') and not(italic[contains(text() ,'Xenopus tropicalis')])" 
        role="info" 
        id="xenopustropicalis-ref-article-title-check"><name/> contains an organism - 'Xenopus tropicalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?musculus') and not(italic[contains(text() ,'M. musculus')])" 
        role="info" 
        id="mmusculus-ref-article-title-check"><name/> contains an organism - 'M. musculus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mus\s?musculus') and not(italic[contains(text() ,'Mus musculus')])" 
        role="info" 
        id="musmusculus-ref-article-title-check"><name/> contains an organism - 'Mus musculus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?immigrans') and not(italic[contains(text() ,'D. immigrans')])" 
        role="info" 
        id="dimmigrans-ref-article-title-check"><name/> contains an organism - 'D. immigrans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?immigrans') and not(italic[contains(text() ,'Drosophila immigrans')])" 
        role="info" 
        id="drosophilaimmigrans-ref-article-title-check"><name/> contains an organism - 'Drosophila immigrans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?subobscura') and not(italic[contains(text() ,'D. subobscura')])" 
        role="info" 
        id="dsubobscura-ref-article-title-check"><name/> contains an organism - 'D. subobscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?subobscura') and not(italic[contains(text() ,'Drosophila subobscura')])" 
        role="info" 
        id="drosophilasubobscura-ref-article-title-check"><name/> contains an organism - 'Drosophila subobscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?affinis') and not(italic[contains(text() ,'D. affinis')])" 
        role="info" 
        id="daffinis-ref-article-title-check"><name/> contains an organism - 'D. affinis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?affinis') and not(italic[contains(text() ,'Drosophila affinis')])" 
        role="info" 
        id="drosophilaaffinis-ref-article-title-check"><name/> contains an organism - 'Drosophila affinis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?obscura') and not(italic[contains(text() ,'D. obscura')])" 
        role="info" 
        id="dobscura-ref-article-title-check"><name/> contains an organism - 'D. obscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?obscura') and not(italic[contains(text() ,'Drosophila obscura')])" 
        role="info" 
        id="drosophilaobscura-ref-article-title-check"><name/> contains an organism - 'Drosophila obscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'f\.\s?tularensis') and not(italic[contains(text() ,'F. tularensis')])" 
        role="info" 
        id="ftularensis-ref-article-title-check"><name/> contains an organism - 'F. tularensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'francisella\s?tularensis') and not(italic[contains(text() ,'Francisella tularensis')])" 
        role="info" 
        id="francisellatularensis-ref-article-title-check"><name/> contains an organism - 'Francisella tularensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?plantaginis') and not(italic[contains(text() ,'P. plantaginis')])" 
        role="info" 
        id="pplantaginis-ref-article-title-check"><name/> contains an organism - 'P. plantaginis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'podosphaera\s?plantaginis') and not(italic[contains(text() ,'Podosphaera plantaginis')])" 
        role="info" 
        id="podosphaeraplantaginis-ref-article-title-check"><name/> contains an organism - 'Podosphaera plantaginis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?lanceolata') and not(italic[contains(text() ,'P. lanceolata')])" 
        role="info" 
        id="planceolata-ref-article-title-check"><name/> contains an organism - 'P. lanceolata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plantago\s?lanceolata') and not(italic[contains(text() ,'Plantago lanceolata')])" 
        role="info" 
        id="plantagolanceolata-ref-article-title-check"><name/> contains an organism - 'Plantago lanceolata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?trossulus') and not(italic[contains(text() ,'M. trossulus')])" 
        role="info" 
        id="mtrossulus-ref-article-title-check"><name/> contains an organism - 'M. trossulus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mytilus\s?trossulus') and not(italic[contains(text() ,'Mytilus trossulus')])" 
        role="info" 
        id="mytilustrossulus-ref-article-title-check"><name/> contains an organism - 'Mytilus trossulus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?edulis') and not(italic[contains(text() ,'M. edulis')])" 
        role="info" 
        id="medulis-ref-article-title-check"><name/> contains an organism - 'M. edulis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mytilus\s?edulis') and not(italic[contains(text() ,'Mytilus edulis')])" 
        role="info" 
        id="mytilusedulis-ref-article-title-check"><name/> contains an organism - 'Mytilus edulis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?chilensis') and not(italic[contains(text() ,'M. chilensis')])" 
        role="info" 
        id="mchilensis-ref-article-title-check"><name/> contains an organism - 'M. chilensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mytilus\s?chilensis') and not(italic[contains(text() ,'Mytilus chilensis')])" 
        role="info" 
        id="mytiluschilensis-ref-article-title-check"><name/> contains an organism - 'Mytilus chilensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'u\.\s?maydis') and not(italic[contains(text() ,'U. maydis')])" 
        role="info" 
        id="umaydis-ref-article-title-check"><name/> contains an organism - 'U. maydis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'ustilago\s?maydis') and not(italic[contains(text() ,'Ustilago maydis')])" 
        role="info" 
        id="ustilagomaydis-ref-article-title-check"><name/> contains an organism - 'Ustilago maydis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?knowlesi') and not(italic[contains(text() ,'P. knowlesi')])" 
        role="info" 
        id="pknowlesi-ref-article-title-check"><name/> contains an organism - 'P. knowlesi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plasmodium\s?knowlesi') and not(italic[contains(text() ,'Plasmodium knowlesi')])" 
        role="info" 
        id="plasmodiumknowlesi-ref-article-title-check"><name/> contains an organism - 'Plasmodium knowlesi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?aeruginosa') and not(italic[contains(text() ,'P. aeruginosa')])" 
        role="info" 
        id="paeruginosa-ref-article-title-check"><name/> contains an organism - 'P. aeruginosa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'pseudomonas\s?aeruginosa') and not(italic[contains(text() ,'Pseudomonas aeruginosa')])" 
        role="info" 
        id="pseudomonasaeruginosa-ref-article-title-check"><name/> contains an organism - 'Pseudomonas aeruginosa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'t\.\s?brucei') and not(italic[contains(text() ,'T. brucei')])" 
        role="info" 
        id="tbrucei-ref-article-title-check"><name/> contains an organism - 'T. brucei' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'trypanosoma\s?brucei') and not(italic[contains(text() ,'Trypanosoma brucei')])" 
        role="info" 
        id="trypanosomabrucei-ref-article-title-check"><name/> contains an organism - 'Trypanosoma brucei' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?rerio') and not(italic[contains(text() ,'D. rerio')])" 
        role="info" 
        id="drerio-ref-article-title-check"><name/> contains an organism - 'D. rerio' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'danio\s?rerio') and not(italic[contains(text() ,'Danio rerio')])" 
        role="info" 
        id="daniorerio-ref-article-title-check"><name/> contains an organism - 'Danio rerio' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila') and not(italic[contains(text(),'Drosophila')])" 
        role="info" 
        id="drosophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Drosophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus') and not(italic[contains(text() ,'Xenopus')])" 
        role="info" 
        id="xenopus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Xenopus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
    </rule>
    
    <rule context="article//article-meta/title-group/article-title | article/body//sec/title | article//article-meta//kwd" id="org-title-kwd">		
      <let name="lc" value="lower-case(.)"/>
      
      <report test="matches($lc,'b\.\s?subtilis') and not(italic[contains(text() ,'B. subtilis')])" 
        role="warning" 
        id="bssubtilis-article-title-check"><name/> contains an organism - 'B. subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'bacillus\s?subtilis') and not(italic[contains(text() ,'Bacillus subtilis')])" 
        role="warning" 
        id="bacillusssubtilis-article-title-check"><name/> contains an organism - 'Bacillus subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?melanogaster') and not(italic[contains(text() ,'D. melanogaster')])" 
        role="warning" 
        id="dsmelanogaster-article-title-check"><name/> contains an organism - 'D. melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?melanogaster') and not(italic[contains(text() ,'Drosophila melanogaster')])" 
        role="warning" 
        id="drosophilasmelanogaster-article-title-check"><name/> contains an organism - 'Drosophila melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?coli') and not(italic[contains(text() ,'E. coli')])" 
        role="warning" 
        id="escoli-article-title-check"><name/> contains an organism - 'E. coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'escherichia\s?coli') and not(italic[contains(text() ,'Escherichia coli')])" 
        role="warning" 
        id="escherichiascoli-article-title-check"><name/> contains an organism - 'Escherichia coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pombe') and not(italic[contains(text() ,'S. pombe')])" 
        role="warning" 
        id="sspombe-article-title-check"><name/> contains an organism - 'S. pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schizosaccharomyces\s?pombe') and not(italic[contains(text() ,'Schizosaccharomyces pombe')])" 
        role="warning" 
        id="schizosaccharomycesspombe-article-title-check"><name/> contains an organism - 'Schizosaccharomyces pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?cerevisiae') and not(italic[contains(text() ,'S. cerevisiae')])" 
        role="warning" 
        id="sscerevisiae-article-title-check"><name/> contains an organism - 'S. cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'saccharomyces\s?cerevisiae') and not(italic[contains(text() ,'Saccharomyces cerevisiae')])" 
        role="warning" 
        id="saccharomycesscerevisiae-article-title-check"><name/> contains an organism - 'Saccharomyces cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?elegans') and not(italic[contains(text() ,'C. elegans')])" 
        role="warning" 
        id="cselegans-article-title-check"><name/> contains an organism - 'C. elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'caenorhabditis\s?elegans') and not(italic[contains(text() ,'Caenorhabditis elegans')])" 
        role="warning" 
        id="caenorhabditisselegans-article-title-check"><name/> contains an organism - 'Caenorhabditis elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'a\.\s?thaliana') and not(italic[contains(text() ,'A. thaliana')])" 
        role="warning" 
        id="asthaliana-article-title-check"><name/> contains an organism - 'A. thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'arabidopsis\s?thaliana') and not(italic[contains(text() ,'Arabidopsis thaliana')])" 
        role="warning" 
        id="arabidopsissthaliana-article-title-check"><name/> contains an organism - 'Arabidopsis thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?thermophila') and not(italic[contains(text() ,'M. thermophila')])" 
        role="warning" 
        id="msthermophila-article-title-check"><name/> contains an organism - 'M. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'myceliophthora\s?thermophila') and not(italic[contains(text() ,'Myceliophthora thermophila')])" 
        role="warning" 
        id="myceliophthorasthermophila-article-title-check"><name/> contains an organism - 'Myceliophthora thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'dictyostelium') and not(italic[contains(text() ,'Dictyostelium')])" 
        role="warning" 
        id="dictyostelium-article-title-check"><name/> contains an organism - 'Dictyostelium' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?falciparum') and not(italic[contains(text() ,'P. falciparum')])" 
        role="warning" 
        id="psfalciparum-article-title-check"><name/> contains an organism - 'P. falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plasmodium\s?falciparum') and not(italic[contains(text() ,'Plasmodium falciparum')])" 
        role="warning" 
        id="plasmodiumsfalciparum-article-title-check"><name/> contains an organism - 'Plasmodium falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?enterica') and not(italic[contains(text() ,'S. enterica')])" 
        role="warning" 
        id="ssenterica-article-title-check"><name/> contains an organism - 'S. enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salmonella\s?enterica') and not(italic[contains(text() ,'Salmonella enterica')])" 
        role="warning" 
        id="salmonellasenterica-article-title-check"><name/> contains an organism - 'Salmonella enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pyogenes') and not(italic[contains(text() ,'S. pyogenes')])" 
        role="warning" 
        id="sspyogenes-article-title-check"><name/> contains an organism - 'S. pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'streptococcus\s?pyogenes') and not(italic[contains(text() ,'Streptococcus pyogenes')])" 
        role="warning" 
        id="streptococcusspyogenes-article-title-check"><name/> contains an organism - 'Streptococcus pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?dumerilii') and not(italic[contains(text() ,'P. dumerilii')])" 
        role="warning" 
        id="psdumerilii-article-title-check"><name/> contains an organism - 'P. dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'platynereis\s?dumerilii') and not(italic[contains(text() ,'Platynereis dumerilii')])" 
        role="warning" 
        id="platynereissdumerilii-article-title-check"><name/> contains an organism - 'Platynereis dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?cynocephalus') and not(italic[contains(text() ,'P. cynocephalus')])" 
        role="warning" 
        id="pscynocephalus-article-title-check"><name/> contains an organism - 'P. cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'papio\s?cynocephalus') and not(italic[contains(text() ,'Papio cynocephalus')])" 
        role="warning" 
        id="papioscynocephalus-article-title-check"><name/> contains an organism - 'Papio cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'o\.\s?fasciatus') and not(italic[contains(text() ,'O. fasciatus')])" 
        role="warning" 
        id="osfasciatus-article-title-check"><name/> contains an organism - 'O. fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'oncopeltus\s?fasciatus') and not(italic[contains(text() ,'Oncopeltus fasciatus')])" 
        role="warning" 
        id="oncopeltussfasciatus-article-title-check"><name/> contains an organism - 'Oncopeltus fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?crassa') and not(italic[contains(text() ,'N. crassa')])" 
        role="warning" 
        id="nscrassa-article-title-check"><name/> contains an organism - 'N. crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'neurospora\s?crassa') and not(italic[contains(text() ,'Neurospora crassa')])" 
        role="warning" 
        id="neurosporascrassa-article-title-check"><name/> contains an organism - 'Neurospora crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?intestinalis') and not(italic[contains(text() ,'C. intestinalis')])" 
        role="warning" 
        id="csintestinalis-article-title-check"><name/> contains an organism - 'C. intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'ciona\s?intestinalis') and not(italic[contains(text() ,'Ciona intestinalis')])" 
        role="warning" 
        id="cionasintestinalis-article-title-check"><name/> contains an organism - 'Ciona intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?cuniculi') and not(italic[contains(text() ,'E. cuniculi')])" 
        role="warning" 
        id="escuniculi-article-title-check"><name/> contains an organism - 'E. cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'encephalitozoon\s?cuniculi') and not(italic[contains(text() ,'Encephalitozoon cuniculi')])" 
        role="warning" 
        id="encephalitozoonscuniculi-article-title-check"><name/> contains an organism - 'Encephalitozoon cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?salinarum') and not(italic[contains(text() ,'H. salinarum')])" 
        role="warning" 
        id="hssalinarum-article-title-check"><name/> contains an organism - 'H. salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'halobacterium\s?salinarum') and not(italic[contains(text() ,'Halobacterium salinarum')])" 
        role="warning" 
        id="halobacteriumssalinarum-article-title-check"><name/> contains an organism - 'Halobacterium salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?solfataricus') and not(italic[contains(text() ,'S. solfataricus')])" 
        role="warning" 
        id="sssolfataricus-article-title-check"><name/> contains an organism - 'S. solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'sulfolobus\s?solfataricus') and not(italic[contains(text() ,'Sulfolobus solfataricus')])" 
        role="warning" 
        id="sulfolobusssolfataricus-article-title-check"><name/> contains an organism - 'Sulfolobus solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?mediterranea') and not(italic[contains(text() ,'S. mediterranea')])" 
        role="warning" 
        id="ssmediterranea-article-title-check"><name/> contains an organism - 'S. mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schmidtea\s?mediterranea') and not(italic[contains(text() ,'Schmidtea mediterranea')])" 
        role="warning" 
        id="schmidteasmediterranea-article-title-check"><name/> contains an organism - 'Schmidtea mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?rosetta') and not(italic[contains(text() ,'S. rosetta')])" 
        role="warning" 
        id="ssrosetta-article-title-check"><name/> contains an organism - 'S. rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salpingoeca\s?rosetta') and not(italic[contains(text() ,'Salpingoeca rosetta')])" 
        role="warning" 
        id="salpingoecasrosetta-article-title-check"><name/> contains an organism - 'Salpingoeca rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?vectensis') and not(italic[contains(text() ,'N. vectensis')])" 
        role="warning" 
        id="nsvectensis-article-title-check"><name/> contains an organism - 'N. vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nematostella\s?vectensis') and not(italic[contains(text() ,'Nematostella vectensis')])" 
        role="warning" 
        id="nematostellasvectensis-article-title-check"><name/> contains an organism - 'Nematostella vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?aureus') and not(italic[contains(text() ,'S. aureus')])" 
        role="warning" 
        id="ssaureus-article-title-check"><name/> contains an organism - 'S. aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'staphylococcus\s?aureus') and not(italic[contains(text() ,'Staphylococcus aureus')])" 
        role="warning" 
        id="staphylococcussaureus-article-title-check"><name/> contains an organism - 'Staphylococcus aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'v\.\s?cholerae') and not(italic[contains(text() ,'V. cholerae')])" 
        role="warning" 
        id="vscholerae-article-title-check"><name/> contains an organism - 'V. cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'vibrio\s?cholerae') and not(italic[contains(text() ,'Vibrio cholerae')])" 
        role="warning" 
        id="vibrioscholerae-article-title-check"><name/> contains an organism - 'Vibrio cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'t\.\s?thermophila') and not(italic[contains(text() ,'T. thermophila')])" 
        role="warning" 
        id="tsthermophila-article-title-check"><name/> contains an organism - 'T. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'tetrahymena\s?thermophila') and not(italic[contains(text() ,'Tetrahymena thermophila')])" 
        role="warning" 
        id="tetrahymenasthermophila-article-title-check"><name/> contains an organism - 'Tetrahymena thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?reinhardtii') and not(italic[contains(text() ,'C. reinhardtii')])" 
        role="warning" 
        id="csreinhardtii-article-title-check"><name/> contains an organism - 'C. reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydomonas\s?reinhardtii') and not(italic[contains(text() ,'Chlamydomonas reinhardtii')])" 
        role="warning" 
        id="chlamydomonassreinhardtii-article-title-check"><name/> contains an organism - 'Chlamydomonas reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?attenuata') and not(italic[contains(text() ,'N. attenuata')])" 
        role="warning" 
        id="nsattenuata-article-title-check"><name/> contains an organism - 'N. attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nicotiana\s?attenuata') and not(italic[contains(text() ,'Nicotiana attenuata')])" 
        role="warning" 
        id="nicotianasattenuata-article-title-check"><name/> contains an organism - 'Nicotiana attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?carotovora') and not(italic[contains(text() ,'E. carotovora')])" 
        role="warning" 
        id="escarotovora-article-title-check"><name/> contains an organism - 'E. carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'erwinia\s?carotovora') and not(italic[contains(text() ,'Erwinia carotovora')])" 
        role="warning" 
        id="erwiniascarotovora-article-title-check"><name/> contains an organism - 'Erwinia carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?sapiens') and not(italic[contains(text() ,'H. sapiens')])" 
        role="warning" 
        id="hsapiens-article-title-check"><name/> contains an organism - 'H. sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'homo\s?sapiens') and not(italic[contains(text() ,'Homo sapiens')])" 
        role="warning" 
        id="homosapiens-article-title-check"><name/> contains an organism - 'Homo sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?trachomatis') and not(italic[contains(text() ,'C. trachomatis')])" 
        role="warning" 
        id="ctrachomatis-article-title-check"><name/> contains an organism - 'C. trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydia\s?trachomatis') and not(italic[contains(text() ,'Chlamydia trachomatis')])" 
        role="warning" 
        id="chlamydiatrachomatis-article-title-check"><name/> contains an organism - 'Chlamydia trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?faecalis') and not(italic[contains(text() ,'E. faecalis')])" 
        role="warning" 
        id="esfaecalis-article-title-check"><name/> contains an organism - 'E. faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'enterococcus\s?faecalis') and not(italic[contains(text() ,'Enterococcus faecalis')])" 
        role="warning" 
        id="enterococcussfaecalis-article-title-check"><name/> contains an organism - 'Enterococcus faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'x\.\s?laevis') and not(italic[contains(text() ,'X. laevis')])" 
        role="warning" 
        id="xlaevis-article-title-check"><name/> contains an organism - 'X. laevis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus\s?laevis') and not(italic[contains(text() ,'Xenopus laevis')])" 
        role="warning" 
        id="xenopuslaevis-article-title-check"><name/> contains an organism - 'Xenopus laevis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'x\.\s?tropicalis') and not(italic[contains(text() ,'X. tropicalis')])" 
        role="warning" 
        id="xtropicalis-article-title-check"><name/> contains an organism - 'X. tropicalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus\s?tropicalis') and not(italic[contains(text() ,'Xenopus tropicalis')])" 
        role="warning" 
        id="xenopustropicalis-article-title-check"><name/> contains an organism - 'Xenopus tropicalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?musculus') and not(italic[contains(text() ,'M. musculus')])" 
        role="warning" 
        id="mmusculus-article-title-check"><name/> contains an organism - 'M. musculus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mus\s?musculus') and not(italic[contains(text() ,'Mus musculus')])" 
        role="warning" 
        id="musmusculus-article-title-check"><name/> contains an organism - 'Mus musculus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?immigrans') and not(italic[contains(text() ,'D. immigrans')])" 
        role="warning" 
        id="dimmigrans-article-title-check"><name/> contains an organism - 'D. immigrans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?immigrans') and not(italic[contains(text() ,'Drosophila immigrans')])" 
        role="warning" 
        id="drosophilaimmigrans-article-title-check"><name/> contains an organism - 'Drosophila immigrans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?subobscura') and not(italic[contains(text() ,'D. subobscura')])" 
        role="warning" 
        id="dsubobscura-article-title-check"><name/> contains an organism - 'D. subobscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?subobscura') and not(italic[contains(text() ,'Drosophila subobscura')])" 
        role="warning" 
        id="drosophilasubobscura-article-title-check"><name/> contains an organism - 'Drosophila subobscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?affinis') and not(italic[contains(text() ,'D. affinis')])" 
        role="warning" 
        id="daffinis-article-title-check"><name/> contains an organism - 'D. affinis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?affinis') and not(italic[contains(text() ,'Drosophila affinis')])" 
        role="warning" 
        id="drosophilaaffinis-article-title-check"><name/> contains an organism - 'Drosophila affinis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?obscura') and not(italic[contains(text() ,'D. obscura')])" 
        role="warning" 
        id="dobscura-article-title-check"><name/> contains an organism - 'D. obscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?obscura') and not(italic[contains(text() ,'Drosophila obscura')])" 
        role="warning" 
        id="drosophilaobscura-article-title-check"><name/> contains an organism - 'Drosophila obscura' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'f\.\s?tularensis') and not(italic[contains(text() ,'F. tularensis')])" 
        role="warning" 
        id="ftularensis-article-title-check"><name/> contains an organism - 'F. tularensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'francisella\s?tularensis') and not(italic[contains(text() ,'Francisella tularensis')])" 
        role="warning" 
        id="francisellatularensis-article-title-check"><name/> contains an organism - 'Francisella tularensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?plantaginis') and not(italic[contains(text() ,'P. plantaginis')])" 
        role="warning" 
        id="pplantaginis-article-title-check"><name/> contains an organism - 'P. plantaginis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'podosphaera\s?plantaginis') and not(italic[contains(text() ,'Podosphaera plantaginis')])" 
        role="warning" 
        id="podosphaeraplantaginis-article-title-check"><name/> contains an organism - 'Podosphaera plantaginis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?lanceolata') and not(italic[contains(text() ,'P. lanceolata')])" 
        role="warning" 
        id="planceolata-article-title-check"><name/> contains an organism - 'P. lanceolata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plantago\s?lanceolata') and not(italic[contains(text() ,'Plantago lanceolata')])" 
        role="warning" 
        id="plantagolanceolata-article-title-check"><name/> contains an organism - 'Plantago lanceolata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?trossulus') and not(italic[contains(text() ,'M. trossulus')])" 
        role="info" 
        id="mtrossulus-article-title-check"><name/> contains an organism - 'M. trossulus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mytilus\s?trossulus') and not(italic[contains(text() ,'Mytilus trossulus')])" 
        role="info" 
        id="mytilustrossulus-article-title-check"><name/> contains an organism - 'Mytilus trossulus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?edulis') and not(italic[contains(text() ,'M. edulis')])" 
        role="info" 
        id="medulis-article-title-check"><name/> contains an organism - 'M. edulis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mytilus\s?edulis') and not(italic[contains(text() ,'Mytilus edulis')])" 
        role="info" 
        id="mytilusedulis-article-title-check"><name/> contains an organism - 'Mytilus edulis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?chilensis') and not(italic[contains(text() ,'M. chilensis')])" 
        role="info" 
        id="mchilensis-article-title-check"><name/> contains an organism - 'M. chilensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'mytilus\s?chilensis') and not(italic[contains(text() ,'Mytilus chilensis')])" 
        role="info" 
        id="mytiluschilensis-article-title-check"><name/> contains an organism - 'Mytilus chilensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'u\.\s?maydis') and not(italic[contains(text() ,'U. maydis')])" 
        role="info" 
        id="umaydis-article-title-check"><name/> contains an organism - 'U. maydis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'ustilago\s?maydis') and not(italic[contains(text() ,'Ustilago maydis')])" 
        role="info" 
        id="ustilagomaydis-article-title-check"><name/> contains an organism - 'Ustilago maydis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?knowlesi') and not(italic[contains(text() ,'P. knowlesi')])" 
        role="info" 
        id="pknowlesi-article-title-check"><name/> contains an organism - 'P. knowlesi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plasmodium\s?knowlesi') and not(italic[contains(text() ,'Plasmodium knowlesi')])" 
        role="info" 
        id="plasmodiumknowlesi-article-title-check"><name/> contains an organism - 'Plasmodium knowlesi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?aeruginosa') and not(italic[contains(text() ,'P. aeruginosa')])" 
        role="info" 
        id="paeruginosa-article-title-check"><name/> contains an organism - 'P. aeruginosa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'pseudomonas\s?aeruginosa') and not(italic[contains(text() ,'Pseudomonas aeruginosa')])" 
        role="info" 
        id="pseudomonasaeruginosa-article-title-check"><name/> contains an organism - 'Pseudomonas aeruginosa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'t\.\s?brucei') and not(italic[contains(text() ,'T. brucei')])" 
        role="warning" 
        id="tbrucei-article-title-check"><name/> contains an organism - 'T. brucei' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'trypanosoma\s?brucei') and not(italic[contains(text() ,'Trypanosoma brucei')])" 
        role="warning" 
        id="trypanosomabrucei-article-title-check"><name/> contains an organism - 'Trypanosoma brucei' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?rerio') and not(italic[contains(text() ,'D. rerio')])" 
        role="warning" 
        id="drerio-article-title-check"><name/> contains an organism - 'D. rerio' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'danio\s?rerio') and not(italic[contains(text() ,'Danio rerio')])" 
        role="warning" 
        id="daniorerio-article-title-check"><name/> contains an organism - 'Danio rerio' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila') and not(italic[contains(text(),'Drosophila')])" 
        role="warning" 
        id="drosophila-article-title-check"><name/> contains an organism - 'Drosophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus') and not(italic[contains(text() ,'Xenopus')])" 
        role="warning" 
        id="xenopus-article-title-check"><name/> contains an organism - 'Xenopus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
    </rule>
    
  </pattern>
  
  <pattern id="house-style">
    
    <rule context="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link" id="unallowed-symbol-tests">		
      
      <report test="contains(.,'©')" 
        role="error" 
        id="copyright-symbol"><name/> element contains the copyright symbol, '©', which is not allowed.</report>
      
      <report test="contains(.,'™')" 
        role="error" 
        id="trademark-symbol"><name/> element contains the trademark symbol, '™', which is not allowed.</report>
      
      <report test="contains(.,'®')" 
        role="error" 
        id="reg-trademark-symbol"><name/> element contains the registered trademark symbol, '®', which is not allowed.</report>
      
      <report test="matches(.,' [Ii]nc\. |[Ii]nc\.\)|[Ii]nc\.,')" 
        role="warning" 
        id="Inc-presence"><name/> element contains 'Inc.' with a full stop. Remove the full stop.</report>
      
      <report test="matches(.,' [Aa]nd [Aa]nd ')" 
        role="warning" 
        id="andand-presence"><name/> element contains ' and and ' which is very likely to be incorrect.</report>
      
      <report test="matches(.,'[Ff]igure [Ff]igure')" 
        role="warning" 
        id="figurefigure-presence"><name/> element contains ' figure figure ' which is very likely to be incorrect.</report>
      
      <report test="matches(translate(.,'—– ','-- '),'[\+\-]\s+/[\+\-]|[\+\-]/\s+[\+\-]')" 
        role="warning" 
        id="plus-minus-presence"><name/> element contains two plus or minus signs separated by a space and a forward slash (such as '+ /-'). Should the space be removed? - <value-of select="."/></report>
      
      <report test="not(ancestor::sub-article) and matches(.,'\s?[Ss]upplemental [Ff]igure')" 
        role="warning" 
        id="supplementalfigure-presence"><name/> element contains the phrase ' Supplemental figure ' which almost certainly needs updating. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report test="not(ancestor::sub-article) and matches(.,'\s?[Ss]upplemental [Ff]ile')" 
        role="warning" 
        id="supplementalfile-presence"><name/> element contains the phrase ' Supplemental file ' which almost certainly needs updating. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report test="not(ancestor::sub-article) and matches(.,'\s?[Ss]upplementary [Ff]igure')" 
        role="warning" 
        id="supplementaryfigure-presence"><name/> element contains the phrase ' Supplementary figure ' which almost certainly needs updating. If it's unclear which figure/figure supplement should be cited, please query the authors. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report test="not(ancestor::sub-article) and matches(.,'\s?[Ss]upplementa(l|ry) [Tt]able')" 
        role="warning" 
        id="supplement-table-presence"><name/> element contains the phrase 'Supplementary table' or 'Supplemental table'. Does it need updating? If it's unclear what should be cited, please query the authors. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report test="not(local-name()='code') and not(ancestor::sub-article) and matches(.,' [Rr]ef\. ')" 
        role="error" 
        id="ref-presence"><name/> element contains 'Ref.' which is either incorrect or unnecessary.</report>
      
      <report test="not(local-name()='code') and not(ancestor::sub-article) and matches(.,' [Rr]efs\. ')" 
        role="error" 
        id="refs-presence"><name/> element contains 'Refs.' which is either incorrect or unnecessary.</report>
      
      <report test="contains(.,'�')" 
        role="error" 
        id="replacement-character-presence"><name/> element contains the replacement character '�' which is not allowed.</report>
      
      <report test="contains(.,'')" 
        role="error" 
        id="junk-character-presence"><name/> element contains a junk character '' which should be replaced.</report>
      
      <report test="contains(.,'¿')" 
        role="warning" 
        id="inverterted-question-presence"><name/> element contains an inverted question mark '¿' which should very likely be replaced/removed.</report>
      
      <report test="some $x in self::*[not(local-name() = ('monospace','code'))]/text() satisfies matches($x,'\(\)|\[\]')" 
        role="warning" 
        id="empty-parentheses-presence"><name/> element contains empty parentheses ('[]', or '()'). Is there a missing citation within the parentheses? Or perhaps this is a piece of code that needs formatting?</report>
      
      <report test="matches(.,'&amp;#x\d')" 
        role="warning" 
        id="broken-unicode-presence"><name/> element contains what looks like a broken unicode - <value-of select="."/>.</report>
      
      <report test="not(local-name()='code') and contains(.,'..') and not(contains(.,'...'))" 
        role="warning" 
        id="extra-full-stop-presence"><name/> element contains what looks two full stops right next to each other (..) - Is that correct? - <value-of select="."/>.</report>
      
      <report test="not(local-name()='code') and not(inline-formula|element-citation|code|disp-formula|table-wrap|list|inline-graphic|supplementary-material|break) and matches(replace(.,' ',' '),'\s\s+')" 
        role="warning" 
        id="extra-space-presence"><name/> element contains two or more spaces right next to each other - it is very likely that only 1 space is necessary - <value-of select="."/>.</report>
      
      <report test="contains(.,'&#x9D;')" 
        role="error" 
        id="operating-system-command-presence"><name/> element contains a operating system command character '&#x9D;' which should very likely be replaced/removed. - <value-of select="."/></report>
    </rule>
    
    <rule context="sup" id="unallowed-symbol-tests-sup">		
      
      <report test="contains(.,'©')" 
        role="error" 
        id="copyright-symbol-sup">'<name/>' element contains the copyright symbol, '©', which is not allowed.</report>
      
      <report test="contains(.,'™')" 
        role="error" 
        id="trademark-symbol-1-sup">'<name/>' element contains the trademark symbol, '™', which is not allowed.</report>
      
      <report test=". = 'TM'" 
        role="warning" 
        id="trademark-symbol-2-sup">'<name/>' element contains the text 'TM', which means that it resembles the trademark symbol. The trademark symbol is not allowed.</report>
      
      <report test="contains(.,'®')" 
        role="error" 
        id="reg-trademark-symbol-sup">'<name/>' element contains the registered trademark symbol, '®', which is not allowed.</report>
      
      <report test="contains(.,'°')" 
        role="error" 
        id="degree-symbol-sup">'<name/>' element contains the degree symbol, '°', which is not unnecessary. It does not need to be superscript.</report>
      
      <report test="contains(.,'○')" 
        role="warning" 
        id="white-circle-symbol-sup">'<name/>' element contains the white circle symbol, '○'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report test="contains(.,'∘')" 
        role="warning" 
        id="ring-op-symbol-sup">'<name/>' element contains the Ring Operator symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report test="contains(.,'˚')" 
        role="warning" 
        id="ring-diacritic-symbol-sup">'<name/>' element contains the ring above symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
    </rule>
    
    <rule context="underline" id="underline-tests">
      
      <report test="matches(.,'^\p{P}*$')" 
        role="warning" 
        id="underline-test-1">'<name/>' element only contains punctuation - <value-of select="."/> - Should it have underline formatting?</report>
      
    </rule>
    
    <rule context="p[not(descendant::mml:math)]|td[not(descendant::mml:math)]|th[not(descendant::mml:math)]|monospace|code" id="latex-tests">
      
      <report test="matches(.,'\s*\\[a-z]*\p{Ps}')" 
        role="warning" 
        id="latex-test"><name/> element contains what looks like possible LaTeX. Please check that this is correct (i.e. that it is not the case that the authors included LaTeX markup expecting the content to be rendered as it would be in LaTeX. Content - "<value-of select="."/>"</report>
      
    </rule>
    
    <rule context="front//aff/country" id="country-tests">
      <let name="text" value="self::*/text()"/>
      <let name="countries" value="'countries.xml'"/>
      <let name="city" value="parent::aff//named-content[@content-type='city'][1]"/>
      <!--<let name="valid-country" value="document($countries)/countries/country[text() = $text]"/>-->
      
      <report test="$text = 'United States of America'" 
        role="error" 
        id="united-states-test-1"><value-of select="."/> is not allowed it. This should be 'United States'.</report>
      
      <report test="$text = 'USA'" 
        role="error" 
        id="united-states-test-2"><value-of select="."/> is not allowed it. This should be 'United States'</report>
      
      <report test="$text = 'UK'" 
        role="error" 
        id="united-kingdom-test-2"><value-of select="."/> is not allowed it. This should be 'United Kingdom'</report>
      
      <assert test="$text = document($countries)/countries/country" 
        role="error" 
        id="gen-country-test">affiliation contains a country which is not in the allowed list - <value-of select="."/>. For a list of allowed countries, refer to https://github.com/elifesciences/eLife-JATS-schematron/blob/master/src/countries.xml.</assert>
      <!-- Commented out until this is implemented
      <report test="($text = document($countries)/countries/country) and not(@country = $valid-country/@country)" 
        role="warning" 
        id="gen-country-iso-3166-test">country does not have a 2 letter ISO 3166-1 @country value. It should be @country='<value-of select="$valid-country/@country"/>'.</report>-->
      
      <report test="(. = 'Singapore') and ($city != 'Singapore')" 
        role="error" 
        id="singapore-test-1"><value-of select="ancestor::aff/@id"/> has 'Singapore' as its country but '<value-of select="$city"/>' as its city, which must be incorrect.</report>
      
      <report test="(. != 'Taiwan') and  (matches(lower-case($city),'ta[i]?pei|tai\s?chung|kaohsiung|taoyuan|tainan|hsinchu|keelung|chiayi|changhua|jhongli|tao-yuan|hualien'))" 
        role="warning" 
        id="taiwan-test">Affiliation has a Taiwanese city - <value-of select="$city"/> - but its country is '<value-of select="."/>'. Please check the original manuscript. If it has 'Taiwan' as the country in the original manuscript then ensure it is changed to 'Taiwan'.</report>
      
      <report test="(. != 'Republic of Korea') and  (matches(lower-case($city),'chuncheon|gyeongsan|daejeon|seoul|daegu|gwangju|ansan|goyang|suwon|gwanju|ochang|wonju|jeonnam|cheongju|ulsan|inharo|chonnam|miryang|pohang|deagu|gwangjin-gu|gyeonggi-do|incheon|gimhae|gyungnam|muan-gun|chungbuk|chungnam|ansung|cheongju-si'))" 
        role="warning" 
        id="s-korea-test">Affiliation has a South Korean city - <value-of select="$city"/> - but its country is '<value-of select="."/>', instead of 'Republic of Korea'.</report>
      
      <report test="replace(.,'\p{P}','') = 'Democratic Peoples Republic of Korea'" 
        role="warning" 
        id="n-korea-test">Affiliation has '<value-of select="."/>' as its country which is very likely to be incorrect.</report>
    </rule>
    
    <rule context="front//aff//named-content[@content-type='city']" id="city-tests">
      <let name="lc" value="normalize-space(lower-case(.))"/>
      <let name="states-regex" value="'^alabama$|^al$|^alaska$|^ak$|^arizona$|^az$|^arkansas$|^ar$|^california$|^ca$|^colorado$|^co$|^connecticut$|^ct$|^delaware$|^de$|^florida$|^fl$|^georgia$|^ga$|^hawaii$|^hi$|^idaho$|^id$|^illinois$|^il$|^indiana$|^in$|^iowa$|^ia$|^kansas$|^ks$|^kentucky$|^ky$|^louisiana$|^la$|^maine$|^me$|^maryland$|^md$|^massachusetts$|^ma$|^michigan$|^mi$|^minnesota$|^mn$|^mississippi$|^ms$|^missouri$|^mo$|^montana$|^mt$|^nebraska$|^ne$|^nevada$|^nv$|^new hampshire$|^nh$|^new jersey$|^nj$|^new mexico$|^nm$|^ny$|^north carolina$|^nc$|^north dakota$|^nd$|^ohio$|^oh$|^oklahoma$|^ok$|^oregon$|^or$|^pennsylvania$|^pa$|^rhode island$|^ri$|^south carolina$|^sc$|^south dakota$|^sd$|^tennessee$|^tn$|^texas$|^tx$|^utah$|^ut$|^vermont$|^vt$|^virginia$|^va$|^wa$|^west virginia$|^wv$|^wisconsin$|^wi$|^wyoming$|^wy$'"/>
      
      <report test="matches($lc,$states-regex)" 
        role="warning" 
        id="pre-US-states-test">city contains a US state (or an abbreviation for it) - <value-of select="."/>. Please raise with eLife production staff.</report>
      
      <report test="matches($lc,$states-regex)" 
        role="error" 
        id="final-US-states-test">city contains a US state (or an abbreviation for it) - <value-of select="."/>.</report>
      
      <report test="(. = 'Singapore') and (ancestor::aff/country/text() != 'Singapore')" 
        role="error" 
        id="singapore-test-2"><value-of select="ancestor::aff/@id"/> has 'Singapore' as its city but '<value-of select="ancestor::aff/country/text()"/>' as its country, which must be incorrect.</report>
      
      <report test="matches(.,'�')" 
        role="error" 
        id="city-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed.</report>
      
      <report test="matches(.,'\d')" 
        role="warning" 
        id="city-number-presence">city contains a number, which is almost certainly incorrect - <value-of select="."/>.</report>
      
      <report test="matches(lower-case(.),'^rue | rue |^street | street |^building | building |^straße | straße |^stadt | stadt |^platz | platz |^strada | strada |^cedex | cedex ')" 
        role="warning" 
        id="city-street-presence">city likely contains a street or building name, which is almost certainly incorrect - <value-of select="."/>.</report>
    </rule>
    
    <rule context="aff/institution[not(@*)]" id="institution-tests">
      <let name="city" value="parent::*/addr-line/named-content[@content-type='city'][1]"/>
      
      <report test="matches(normalize-space(.),'[Uu]niversity of [Cc]alifornia$')" 
        role="error" 
        id="UC-no-test1"><value-of select="."/> is not allowed as insitution name, since this is always followed by city name. This should very likely be <value-of select="concat('University of California, ',$city)"/> (provided there is a city tagged).</report>
      
      <report test="matches(normalize-space(.),'[Uu]niversity of [Cc]alifornia.') and not(contains(.,'San Diego')) and ($city !='') and not(contains(.,$city))" 
        role="warning" 
        id="UC-no-test-2"><value-of select="."/> has '<value-of select="substring-after(.,'alifornia')"/>' as its campus name in the institution field, but '<value-of select="$city"/>' is the city. Which is correct? Should it end with '<value-of select="concat('University of California, ',following-sibling::addr-line/named-content[@content-type='city'][1])"/>' instead?</report>
      
      <report test="matches(normalize-space(.),'[Uu]niversity of [Cc]alifornia.') and not(contains(.,'San Diego')) and ($city='La Jolla')" 
        role="warning" 
        id="UC-no-test-3"><value-of select="."/> has '<value-of select="substring-after(.,'alifornia')"/>' as its campus name in the institution field, but '<value-of select="$city"/>' is the city. Should the institution end with 'University of California, San Diego' instead?</report>
      
      <report test="matches(.,'�')" 
        role="error" 
        id="institution-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed.</report>
      
      <report test="matches(lower-case(.),'^rue | rue |^street | street |^building | building |^straße | straße |^stadt | stadt |^platz | platz |^strada | strada |^cedex | cedex ')" 
        role="warning" 
        id="institution-street-presence">institution likely contains a street or building name, which is likely to be incorrect - <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="aff/institution[@content-type='dept']" id="department-tests">
      
      <report test="contains(.,'�')" 
        role="error" 
        id="dept-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/source" id="journal-title-tests">
      <let name="doi" value="ancestor::element-citation/pub-id[@pub-id-type='doi'][1]"/>
      <let name="uc" value="upper-case(.)"/>
        
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#PLOS-1" 
        test="($uc != 'PLOS ONE') and matches(.,'plos|Plos|PLoS')" 
        role="error" 
        id="PLOS-1">ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'PLOS' should be upper-case.</report>
        
       <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#PLOS-2" 
        test="($uc = 'PLOS ONE') and (. != 'PLOS ONE')" 
        role="error" 
        id="PLOS-2">ref '<value-of select="ancestor::ref/@id"/>' contains
         <value-of select="."/>. 'PLOS ONE' should be upper-case.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#PNAS" 
        test="if (starts-with($doi,'10.1073')) then . != 'PNAS'
        else()" 
        role="error" 
        id="PNAS">ref '<value-of select="ancestor::ref/@id"/>' has the doi for 'PNAS' but the journal name is
        <value-of select="."/>, which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#RNA" 
        test="($uc = 'RNA') and (. != 'RNA')" 
        role="error" 
        id="RNA">ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'RNA' should be upper-case.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#bmj" 
        test="(matches($uc,'^BMJ$|BMJ[:]? ')) and matches(.,'Bmj|bmj|BMj|BmJ|bMj|bmJ')" 
        role="error" 
        id="bmj">ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'BMJ' should be upper-case.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#G3" 
        test="starts-with($doi,'10.1534/g3') and (. != 'G3: Genes, Genomes, Genetics')" 
        role="error" 
        id="G3">ref '<value-of select="ancestor::ref/@id"/>' has the doi for 'G3' but the journal name is
        <value-of select="."/> - it should be 'G3: Genes, Genomes, Genetics'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#ampersand-check" 
        test="matches(.,'\s?[Aa]mp[;]?\s?') and (. != 'Hippocampus')" 
        role="warning" 
        id="ampersand-check">ref '<value-of select="ancestor::ref/@id"/>' appears to contain the text 'amp', is this a broken ampersand?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#Research-gate-check" 
        test="(normalize-space($uc) = 'RESEARCH GATE') or (normalize-space($uc) = 'RESEARCHGATE')" 
        role="error" 
        id="Research-gate-check"> ref '<value-of select="ancestor::ref/@id"/>' has a source title '<value-of select="."/>' which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#zenodo-check" 
        test="$uc = 'ZENODO'" 
        role="error" 
        id="zenodo-check">Journal ref '<value-of select="ancestor::ref/@id"/>' has a source title '<value-of select="."/>' which must be incorrect. It should be a data or software type reference.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#journal-replacement-character-presence" 
        test="matches(.,'�')" 
        role="error" 
        id="journal-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#journal-off-presence" 
        test="matches(.,'[Oo]fficial [Jj]ournal')" 
        role="warning" 
        id="journal-off-presence">ref '<value-of select="ancestor::ref/@id"/>' has a source title which contains the text 'official journal' - '<value-of select="."/>'. Is this necessary?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#handbook-presence" 
        test="contains($uc,'HANDBOOK')" 
        role="error" 
        id="handbook-presence">Journal ref '<value-of select="ancestor::ref/@id"/>' has a journal name '<value-of select="."/>'. Should it be captured as a book type reference instead?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#elife-check" 
        test="starts-with($doi,'10.7554/eLife.') and (. != 'eLife')" 
        role="error" 
        id="elife-check">Journal ref '<value-of select="ancestor::ref/@id"/>' has an eLife doi <value-of select="$doi"/>, but the journal name is '<value-of select="."/>', when it should be 'eLife'. Either the journal name needs updating to eLife, or the doi is incorrect.</report>
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/article-title" id="ref-article-title-tests">
      <let name="rep" value="replace(.,' [Ii]{1,3}\. | IV\. | V. | [Cc]\. [Ee]legans| vs\. | sp\. ','')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#article-title-fullstop-check-1" 
        test="(matches($rep,'[A-Za-z][A-Za-z]+\. [A-Za-z]'))" 
        role="info" 
        id="article-title-fullstop-check-1">ref '<value-of select="ancestor::ref/@id"/>' has an article-title with a full stop. Is this correct, or has the journal/source title been included? Or perhaps the full stop should be a colon ':'?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#article-title-fullstop-check-2" 
        test="matches(.,'\.$') and not(matches(.,'\.\.$'))" 
        role="error" 
        id="article-title-fullstop-check-2">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which ends with a full stop, which cannot be correct - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#article-title-fullstop-check-3" 
        test="matches(.,'\.$') and matches(.,'\.\.$')" 
        role="warning" 
        id="article-title-fullstop-check-3">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which ends with some full stops - is this correct? - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#article-title-correction-check" 
        test="matches(.,'^[Cc]orrection|^[Rr]etraction|[Ee]rratum')" 
        role="warning" 
        id="article-title-correction-check">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which begins with 'Correction', 'Retraction' or contains 'Erratum'. Is this a reference to the notice or the original article?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#article-title-journal-check" 
        test="matches(.,' [Jj]ournal ')" 
        role="warning" 
        id="article-title-journal-check">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which contains the text ' journal '. Is a journal name (source) erroneously included in the title? - '<value-of select="."/>'</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#article-title-child-1" 
        test="(count(child::*) = 1) and (count(child::text()) = 0)" 
        role="warning" 
        id="article-title-child-1">ref '<value-of select="ancestor::ref/@id"/>' has an article-title with one child <value-of select="*/local-name()"/> element, and no text. This is almost certainly incorrect. - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#a-title-replacement-character-presence" 
        test="matches(.,'�')" 
        role="error" 
        id="a-title-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']" id="journal-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#eloc-page-assert" 
        test="not(fpage) and not(elocation-id) and not(comment)" 
        role="warning" 
        id="eloc-page-assert">ref '<value-of select="ancestor::ref/@id"/>' is a journal, but it doesn't have a page range or e-location. Is this right?</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#volume-assert" 
        test="volume" 
        role="warning" 
        id="volume-assert">ref '<value-of select="ancestor::ref/@id"/>' is a journal, but it doesn't have a volume. Is this right?</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#journal-preprint-check" 
        test="matches(normalize-space(lower-case(source[1])),'^biorxiv$|^arxiv$|^chemrxiv$|^peerj preprints$|^psyarxiv$|^paleorxiv$|^preprints$')" 
        role="error" 
        id="journal-preprint-check">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="source[1]"/>, but it is captured as a journal not a preprint.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#elife-ref-check" 
        test="(lower-case(source[1]) = 'elife') and not(matches(pub-id[@pub-id-type='doi'][1],'^10.7554/eLife\.\d{5}$|^10.7554/eLife\.\d{5}\.\d{3}$|^10.7554/eLife\.\d{5}\.sa[12]$'))" 
        role="error" 
        id="elife-ref-check">ref '<value-of select="ancestor::ref/@id"/>' is an <value-of select="source[1]"/> article, but it has no doi in the format 10.7554/eLife.00000, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#journal-conference-ref-check-1" 
        test="matches(lower-case(source[1]),'conference|symposium|symposia|neural information processing|nips|computer vision and pattern recognition|scipy|workshop|meeting|spie|congress|[\d]st|[\d]nd|[\d]rd|[\d]th')" 
        role="warning" 
        id="journal-conference-ref-check-1">Journal ref '<value-of select="ancestor::ref/@id"/>' has the journal name <value-of select="source[1]"/>. Should it be a conference type reference instead?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/journal-references#journal-conference-ref-check-2" 
        test="matches(source[1],'^[1][7-9][0-9][0-9] |\([1][7-9][0-9][0-9][\)\s]| [1][7-9][0-9][0-9] | [1][7-9][0-9][0-9]$|^[2][0-2][0-9][0-9] |\([2][0-2][0-9][0-9][\)\s]| [2][0-2][0-9][0-9] | [2][0-2][0-9][0-9]$')" 
        role="warning" 
        id="journal-conference-ref-check-2">Journal ref '<value-of select="ancestor::ref/@id"/>' has a journal name containing a year - <value-of select="source[1]"/>. Should it be a conference type reference instead? Or should the year be removed from the journal name?</report>
      
    </rule>
    
    <rule context="element-citation[(@publication-type='book') and chapter-title]" id="book-chapter-tests">
      
      <assert test="person-group[@person-group-type='editor']" 
        role="warning" 
        id="book-chapter-test-1">ref '<value-of select="ancestor::ref/@id"/>' (<value-of select="e:citation-format1(.)"/>) is tagged as a book reference with a chapter title, but there are no editors. Is this correct, or are these details missing?</assert>
      
      <assert test="fpage and lpage" 
        role="warning" 
        id="book-chapter-test-2">ref '<value-of select="ancestor::ref/@id"/>' (<value-of select="e:citation-format1(.)"/>) is tagged as a book reference with a chapter title, but there is not a first page and last page. Is this correct, or are these details missing?</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/chapter-title" id="ref-chapter-title-tests">
      
      <report test="matches(.,' [Rr]eport |^[Rr]eport | [Rr]eport[\s\p{P}]?$')" 
        role="warning" 
        id="report-chapter-title-test">ref '<value-of select="ancestor::ref/@id"/>' is tagged as a book reference, but the chapter title is <value-of select="."/>. Should it be captured as a report type reference instead?</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/source" id="ref-book-source-tests">
      
      <report test="matches(.,' [Rr]eport |^[Rr]eport | [Rr]eport[\s\p{P}]?$')" 
        role="warning" 
        id="report-book-source-test">ref '<value-of select="ancestor::ref/@id"/>' is tagged as a book reference, but the book title is <value-of select="."/>. Should it be captured as a report type reference instead?</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/source" id="preprint-title-tests">
      <let name="lc" value="lower-case(.)"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#not-rxiv-test" 
        test="matches($lc,'biorxiv|arxiv|chemrxiv|medrxiv|peerj preprints|psyarxiv|paleorxiv|preprints')" 
        role="warning" 
        id="not-rxiv-test">ref '<value-of select="ancestor::ref/@id"/>' is tagged as a preprint, but has a source <value-of select="."/>, which doesn't look like a preprint. Is it correct?</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#biorxiv-test" 
        test="matches($lc,'biorxiv') and not(. = 'bioRxiv')" 
        role="error" 
        id="biorxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'bioRxiv'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#biorxiv-test-2" 
        test="matches($lc,'biorxiv') and not(starts-with(parent::element-citation/pub-id[@pub-id-type='doi'][1],'10.1101/'))" 
        role="error" 
        id="biorxiv-test-2">ref '<value-of select="ancestor::ref/@id"/>' is captured as a <value-of select="."/> preprint, but it does not have a doi starting with the bioRxiv prefix, '10.1101/'. <value-of select="if (parent::element-citation/pub-id[@pub-id-type='doi']) then concat('The doi does not point to bioRxiv - https://doi.org/',parent::element-citation/pub-id[@pub-id-type='doi'][1]) else 'The doi is missing'"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#arxiv-test" 
        test="matches($lc,'^arxiv$') and not(. = 'arXiv')" 
        role="error" 
        id="arxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'arXiv'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#chemrxiv-test" 
        test="matches($lc,'chemrxiv') and not(. = 'ChemRxiv')" 
        role="error" 
        id="chemrxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'ChemRxiv'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#medrxiv-test" 
        test="matches($lc,'medrxiv') and not(. = 'medRxiv')" 
        role="error" 
        id="medrxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'medRxiv'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#peerjpreprints-test" 
        test="matches($lc,'peerj preprints') and not(. = 'PeerJ Preprints')" 
        role="error" 
        id="peerjpreprints-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PeerJ Preprints'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#psyarxiv-test" 
        test="matches($lc,'psyarxiv') and not(. = 'PsyArXiv')" 
        role="error" 
        id="psyarxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PsyArXiv'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#paleorxiv-test" 
        test="matches($lc,'paleorxiv') and not(. = 'PaleorXiv')" 
        role="error" 
        id="paleorxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PaleorXiv'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#preprint-replacement-character-presence" 
        test="matches(.,'�')" 
        role="error" 
        id="preprint-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed - <value-of select="."/>.</report>
      
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/preprint-references#preprint-handbook-presence" 
        test="contains(.,'handbook')" 
        role="error" 
        id="preprint-handbook-presence">Preprint ref '<value-of select="ancestor::ref/@id"/>' has a source '<value-of select="."/>'. Should it be captured as a book type reference instead?</report>
    </rule>
    
    <rule context="element-citation[@publication-type='web']" id="website-tests">
      <let name="link" value="lower-case(ext-link[1])"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#github-web-test" 
        test="contains($link,'github') and not(contains($link,'github.io'))" 
        role="warning" 
        id="github-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which contains 'github', therefore it should almost certainly be captured as a software ref (unless it's a blog post by GitHub).</report>
      
      <report test="matches(.,'�')" 
        role="error" 
        id="webreplacement-character-presence">web citation contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report test="matches($link,'psyarxiv.org')" 
        role="error" 
        id="psyarxiv-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, PsyArXiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'/arxiv.org')" 
        role="error" 
        id="arxiv-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, arXiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'biorxiv.org')" 
        role="warning" 
        id="biorxiv-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, bioRxiv, therefore it should almost certainly be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'chemrxiv.org')" 
        role="error" 
        id="chemrxiv-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, ChemRxiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'peerj.com/preprints/')" 
        role="error" 
        id="peerj-preprints-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, PeerJ Preprints, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
      
      <report test="matches($link,'paleorxiv.org')" 
        role="error" 
        id="paleorxiv-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which points to a preprint server, bioRxiv, therefore it should be captured as a preprint type ref - <value-of select="ext-link"/></report>
    </rule>
    
    <rule context="element-citation[@publication-type='software']" id="software-ref-tests">
      <let name="lc" value="lower-case(data-title[1])"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#r-test-1" 
        test="matches($lc,'r: a language and environment for statistical computing') and not(matches(person-group[@person-group-type='author']/collab[1],'^R Development Core Team$'))" 
        role="error" 
        id="R-test-1">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but it does not have one collab element containing 'R Development Core Team'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#r-test-2" 
        test="matches($lc,'r: a language and environment for statistical computing') and (count(person-group[@person-group-type='author']/collab) != 1)" 
        role="error" 
        id="R-test-2">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but it has <value-of select="count(person-group[@person-group-type='author']/collab)"/> collab element(s).</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#r-test-3" 
        test="matches($lc,'r: a language and environment for statistical computing') and (count((publisher-loc[text() = 'Vienna, Austria'])) != 1)" 
        role="error" 
        id="R-test-3">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but does not have a &lt;publisher-loc&gt;Vienna, Austria&lt;/publisher-loc&gt; element.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#r-test-4" 
        test="matches($lc,'r: a language and environment for statistical computing') and not(matches(ext-link[1]/@xlink:href,'^http[s]?://www.[Rr]-project.org'))" 
        role="error" 
        id="R-test-4">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title '<value-of select="data-title[1]"/>' but does not have a 'http://www.r-project.org' type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#r-test-5" 
        test="matches(lower-case(source[1]),'r: a language and environment for statistical computing')" 
        role="error" 
        id="R-test-5">software ref '<value-of select="ancestor::ref/@id"/>' has a source '<value-of select="source"/>' but this is the data-title.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#r-test-6" 
        test="matches(lower-case(publisher-name[1]),'r: a language and environment for statistical computing')" 
        role="error" 
        id="R-test-6">software ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name '<value-of select="publisher-name"/>' but this is the data-title.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#r-test-7" 
        test="matches($lc,'r: a language and environment for statistical computing') and (lower-case(publisher-name[1]) != 'r foundation for statistical computing')" 
        role="error" 
        id="R-test-7">software ref '<value-of select="ancestor::ref/@id"/>' with the title '<value-of select="data-title"/>' must have a publisher-name element (Software host) which contains 'R Foundation for Statistical Computing'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#software-replacement-character-presence" 
        test="matches(.,'�')" 
        role="error" 
        id="software-replacement-character-presence">software reference contains the replacement character '�' which is unallowed - <value-of select="."/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#ref-software-test-1" 
        test="source and publisher-name" 
        role="error" 
        id="ref-software-test-1">software ref '<value-of select="ancestor::ref/@id"/>' has both a source (Software name) - <value-of select="source[1]"/> - and a publisher-name (Software host) - <value-of select="publisher-name[1]"/> - which is incorrect. It should have either one or the other.</report>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#ref-software-test-2" 
        test="source or publisher-name" 
        role="error" 
        id="ref-software-test-2">software ref '<value-of select="ancestor::ref/@id"/>' with the title - <value-of select="data-title"/> - must contain either one source element (Software name) or one publisher-name element (Software host).</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#ref-software-test-3" 
        test="matches(lower-case(publisher-name[1]),'github|gitlab|bitbucket|sourceforge|figshare|^osf$|open science framework|zenodo|matlab')" 
        role="error" 
        id="ref-software-test-3">software ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name (Software host) - <value-of select="publisher-name[1]"/>. Since this is a software source, it should be captured in a source element. Please move into the Software name field (rather than Software host).</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#ref-software-test-4" 
        test="matches(lower-case(source[1]),'schr[öo]dinger|r foundation|rstudio ,? inc|mathworks| llc| ltd')" 
        role="error" 
        id="ref-software-test-4">software ref '<value-of select="ancestor::ref/@id"/>' has a source (Software name) - <value-of select="source[1]"/>. Since this is a software publisher, it should be captured in a publisher-name element. Please move into the Software host field.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#ref-software-test-5" 
        test="(normalize-space(lower-case(source[1]))='github') and not(version)" 
        role="warning" 
        id="ref-software-test-5"><value-of select="source[1]"/> software ref (with id '<value-of select="ancestor::ref/@id"/>') does not have a version number. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#ref-software-test-6" 
        test="matches(lower-case(source[1]),'github|gitlab|bitbucket|sourceforge|figshare|^osf$|open science framework|zenodo|matlab') and not(ext-link)" 
        role="error" 
        id="ref-software-test-6"><value-of select="source[1]"/> software ref (with id '<value-of select="ancestor::ref/@id"/>') does not have a URL which is incorrect.</report>
    </rule>
    
    <rule context="element-citation[@publication-type='data']" id="data-ref-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-geo-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/geo') and not(source[1]='NCBI Gene Expression Omnibus')" 
        role="warning" 
        id="data-geo-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/geo' type link, but the database name is not 'NCBI Gene Expression Omnibus' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-nucleotide-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/nuccore') and not(source[1]='NCBI GenBank') and not(source[1]='NCBI Nucleotide')" 
        role="warning" 
        id="data-nucleotide-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/nuccore' type link, but the database name is not 'NCBI Nucleotide' or 'NCBI GenBank' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-bioproject-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/bioproject') and not(source[1]='NCBI BioProject')" 
        role="warning" 
        id="data-bioproject-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/bioproject' type link, but the database name is not 'NCBI BioProject' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-dbgap-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/gap') and not(source[1]='NCBI dbGaP')" 
        role="warning" 
        id="data-dbgap-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/gap' type link, but the database name is not 'NCBI dbGaP' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-popset-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/popset') and not(source[1]='NCBI PopSet')" 
        role="warning" 
        id="data-popset-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/popset' type link, but the database name is not 'NCBI PopSet' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-sra-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/sra') and not(source[1]='NCBI Sequence Read Archive')" 
        role="warning" 
        id="data-sra-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/sra' type link, but the database name is not 'NCBI Sequence Read Archive' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-biosample-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/biosample') and not(source[1]='NCBI BioSample')" 
        role="warning" 
        id="data-biosample-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/biosample' type link, but the database name is not 'NCBI BioSample' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-protein-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/protein') and not(source[1]='NCBI Protein')" 
        role="warning" 
        id="data-protein-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/protein' type link, but the database name is not 'NCBI Protein' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-assembly-test" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/assembly') and not(source[1]='NCBI Assembly')" 
        role="warning" 
        id="data-assembly-test">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://www.ncbi.nlm.nih.gov/assembly' type link, but the database name is not 'NCBI Assembly' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-ncbi-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/') and pub-id[@pub-id-type!='accession']" 
        role="warning" 
        id="data-ncbi-test-1">Data reference with an NCBI link '<value-of select="pub-id[1]/@xlink:href"/>' is not marked as an accession number, which is likely incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-ncbi-test-2" 
        test="matches(lower-case(source[1]),'^ncbi gene expression omnibus$|^ncbi nucleotide$|^ncbi genbank$|^ncbi assembly$|^ncbi bioproject$|^ncbi dbgap$|^ncbi sequence read archive$|^ncbi popset$|^ncbi biosample$') and pub-id[@pub-id-type!='accession']" 
        role="warning" 
        id="data-ncbi-test-2">Data reference with the database source '<value-of select="source[1]"/>' is not marked as an accession number, which is very likely incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-ncbi-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.ncbi.nlm.nih.gov/') and pub-id[1][@assigning-authority!='NCBI' or not(@assigning-authority)]" 
        role="warning" 
        id="data-ncbi-test-3">Data reference with an NCBI link '<value-of select="pub-id[1]/@xlink:href"/>' is not marked with NCBI as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-ncbi-test-4" 
        test="matches(lower-case(source[1]),'^ncbi gene expression omnibus$|^ncbi nucleotide$|^ncbi genbank$|^ncbi assembly$|^ncbi bioproject$|^ncbi dbgap$|^ncbi sequence read archive$|^ncbi popset$|^ncbi biosample$') and pub-id[1][@assigning-authority!='NCBI' or not(@assigning-authority)]" 
        role="warning" 
        id="data-ncbi-test-4">Data reference with the database source '<value-of select="source[1]"/>' is not marked with NCBI as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-dryad-test-1" 
        test="(starts-with(pub-id[1][@pub-id-type='doi'],'10.5061/dryad') or starts-with(pub-id[1][@pub-id-type='doi'],'10.7272')) and (source[1]!='Dryad Digital Repository')" 
        role="warning" 
        id="data-dryad-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a Dryad type doi <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the database name is not 'Dryad Digital Repository' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-dryad-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.5061/dryad') or starts-with(pub-id[1][@pub-id-type='doi'],'10.7272')) and (source[1]='Dryad Digital Repository')" 
        role="warning" 
        id="data-dryad-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name  <value-of select="source[1]"/>, but no doi starting with '10.5061/dryad' or '10.7272', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-dryad-test-3" 
        test="(starts-with(pub-id[1][@pub-id-type='doi'],'10.5061/dryad') or starts-with(pub-id[1][@pub-id-type='doi'],'10.7272')) and (pub-id[1][@assigning-authority!='Dryad' or not(@assigning-authority)])" 
        role="warning" 
        id="data-dryad-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a Dryad type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not Dryad, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-rcsbpbd-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.rcsb.org') and not(source[1]='RCSB Protein Data Bank')" 
        role="warning" 
        id="data-rcsbpbd-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.rcsb.org' type link, but the database name is not 'RCSB Protein Data Bank' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-rcsbpbd-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.rcsb.org') and  pub-id[1][@assigning-authority!='PDB' or not(@assigning-authority)]" 
        role="warning" 
        id="data-rcsbpbd-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.rcsb.org' type link, but is not marked with PDB as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-rcsbpbd-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.rcsb.org') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-rcsbpbd-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a PDB 'http://www.rcsb.org' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-emdb-test-1" 
        test="not(contains(pub-id[1]/@xlink:href,'empiar')) and matches(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb|www.ebi.ac.uk/pdbe/entry/emdb') and not(source[1]='Electron Microscopy Data Bank')" 
        role="warning" 
        id="data-emdb-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.ebi.ac.uk/pdbe/emdb' type link, but the database name is not 'Electron Microscopy Data Bank' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-emdb-test-2" 
        test="not(contains(pub-id[1]/@xlink:href,'empiar')) and matches(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb|www.ebi.ac.uk/pdbe/entry/emdb') and  pub-id[1][@assigning-authority!='EMDB' or not(@assigning-authority)]" 
        role="warning" 
        id="data-emdb-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.ebi.ac.uk/pdbe/emdb' type link, but is not marked with EMDB as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-emdb-test-3" 
        test="matches(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb|www.ebi.ac.uk/pdbe/entry/emdb') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-emdb-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a EMDB 'http://www.ebi.ac.uk/pdbe/emdb' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-empiar-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb/empiar/') and not(source[1]='Electron Microscopy Public Image Archive')" 
        role="warning" 
        id="data-empiar-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.ebi.ac.uk/pdbe/emdb/empiar' type link, but the database name is not 'Electron Microscopy Public Image Archive' - <value-of select="source[1]"/>. Is that correct? https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-empiar-test-1</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-empiar-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pdbe/emdb/empiar/') and  pub-id[1][@assigning-authority!='EBI' or not(@assigning-authority)]" 
        role="warning" 
        id="data-empiar-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://www.ebi.ac.uk/pdbe/emdb/empiar' type link, but is not marked with EBI as its assigning authority, which must be incorrect. https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-empiar-test-2</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-arrayexpress-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/arrayexpress') and not(source[1]='ArrayExpress')" 
        role="warning" 
        id="data-arrayexpress-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.ebi.ac.uk/arrayexpress' type link, but the database name is not 'ArrayExpress' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-arrayexpress-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/arrayexpress') and  pub-id[1][@assigning-authority!='EBI' or not(@assigning-authority)]" 
        role="warning" 
        id="data-arrayexpress-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.ebi.ac.uk/arrayexpress' type link, but is not marked with EBI as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-arrayexpress-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/arrayexpress') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-arrayexpress-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has an ArrayExpress 'www.ebi.ac.uk/arrayexpress' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-pride-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pride') and not(source[1]='PRIDE')" 
        role="warning" 
        id="data-pride-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.ebi.ac.uk/pride' type link, but the database name is not 'PRIDE' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-pride-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pride') and  pub-id[1][@assigning-authority!='EBI' or not(@assigning-authority)]" 
        role="warning" 
        id="data-pride-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.ebi.ac.uk/pride' type link, but is not marked with EBI as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-pride-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.ebi.ac.uk/pride') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-pride-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a PRIDE 'www.ebi.ac.uk/pride' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-zenodo-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.5281/zenodo') and (source[1]!='Zenodo')" 
        role="warning" 
        id="data-zenodo-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.5281/zenodo' but the database name is not 'Zenodo' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-zenodo-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.5281/zenodo')) and (source[1]='Zenodo')" 
        role="warning" 
        id="data-zenodo-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name  <value-of select="source[1]"/>, but no doi starting with '10.5281/zenodo', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-zenodo-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.5281/zenodo') and (pub-id[1][@assigning-authority!='Zenodo'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-zenodo-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a Zenodo type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not Zenodo, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-osf-test-1" 
        test="matches(pub-id[1]/@xlink:href,'^http[s]?://osf.io') and not(source[1]='Open Science Framework')" 
        role="warning" 
        id="data-osf-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://osf.io' type link, but the database name is not 'Open Science Framework' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-osf-test-2" 
        test="matches(pub-id[1]/@xlink:href,'^http[s]?://osf.io') and pub-id[1][@assigning-authority!='Open Science Framework' or not(@assigning-authority)]" 
        role="warning" 
        id="data-osf-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'https://osf.io' type link, but is not marked with Open Science Framework as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-osf-test-3" 
        test="matches(pub-id[1]/@xlink:href,'^http[s]?://osf.io') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-osf-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has an OSF 'https://osf.io' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-osf-test-4" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17605/OSF') and (source[1]!='Open Science Framework')" 
        role="warning" 
        id="data-osf-test-4">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.17605/OSF' but the database name is not 'Open Science Framework' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-osf-test-5" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17605/OSF') and (pub-id[1][@assigning-authority!='Open Science Framework'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-osf-test-5">Data reference with the title '<value-of select="data-title[1]"/>' has a OSF type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not Open Science Framework, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-figshare-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.6084/m9.figshare') and (source[1]!='figshare')" 
        role="warning" 
        id="data-figshare-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.6084/m9.figshare' but the database name is not 'figshare' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-figshare-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.6084/m9.figshare')) and (source[1]='figshare')" 
        role="warning" 
        id="data-figshare-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.6084/m9.figshare' - is this correct? Figshare sometimes host for other organisations (example http://doi.org/10.1184/R1/9963566), so this may be fine.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-figshare-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.6084/m9.figshare') and (pub-id[1][@assigning-authority!='figshare'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-figshare-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a figshare type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not figshare, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-proteomexchange-test-1" 
        test="contains(pub-id[1]/@xlink:href,'proteomecentral.proteomexchange.org/') and not(source[1]='ProteomeXchange')" 
        role="warning" 
        id="data-proteomexchange-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://proteomecentral.proteomexchange.org/' type link, but the database name is not 'ProteomeXchange' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-proteomexchange-test-2" 
        test="contains(pub-id[1]/@xlink:href,'proteomecentral.proteomexchange.org/') and pub-id[1][@assigning-authority!='other' or not(@assigning-authority)]" 
        role="warning" 
        id="data-proteomexchange-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'http://proteomecentral.proteomexchange.org/' type link, but is not marked with 'other' as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-proteomexchange-test-3" 
        test="contains(pub-id[1]/@xlink:href,'proteomecentral.proteomexchange.org/') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-proteomexchange-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a ProteomeXchange 'http://proteomecentral.proteomexchange.org/' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-openneuro-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.18112/openneuro') and (source[1]!='OpenNeuro')" 
        role="warning" 
        id="data-openneuro-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.18112/openneuro' but the database name is not 'OpenNeuro' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-openneuro-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.18112/openneuro')) and not(contains(pub-id[1]/@xlink:href,'openneuro.org/datasets')) and (source[1]='OpenNeuro')" 
        role="warning" 
        id="data-openneuro-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.18112/openneuro' or 'openneuro.org/datasets' type link, which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-openneuro-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.18112/openneuro') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-openneuro-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a OpenNeuro type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-synapse-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7303/syn') and (source[1]!='Synapse')" 
        role="warning" 
        id="data-synapse-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.7303/syn' but the database name is not 'Synapse' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-synapse-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.7303/syn')) and (source[1]='Synapse')" 
        role="warning" 
        id="data-synapse-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.7303/syn', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-synapse-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7303/syn') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-synapse-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a Synapse type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-bmrb-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.bmrb.wisc.edu/data_library/summary') and not(source[1]='Biological Magnetic Resonance Data Bank')" 
        role="warning" 
        id="data-bmrb-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.bmrb.wisc.edu/data_library/summary' type link, but the database name is not 'Biological Magnetic Resonance Data Bank' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-bmrb-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.bmrb.wisc.edu/data_library/summary') and  pub-id[1][@assigning-authority!='other' or not(@assigning-authority)]" 
        role="warning" 
        id="data-bmrb-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.bmrb.wisc.edu/data_library/summary' type link, but is not marked with 'other' as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-bmrb-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.bmrb.wisc.edu/data_library/summary') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-bmrb-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a BMRB 'www.bmrb.wisc.edu/data_library/summary' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-morphdbase-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.morphdbase.de') and not(source[1]='Morph D Base')" 
        role="warning" 
        id="data-morphdbase-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.morphdbase.de' type link, but the database name is not 'Morph D Base' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-morphdbase-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.morphdbase.de') and  pub-id[1][@assigning-authority!='other' or not(@assigning-authority)]" 
        role="warning" 
        id="data-morphdbase-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.morphdbase.de' type link, but is not marked with 'other' as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-morphdbase-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.morphdbase.de') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-morphdbase-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a Morph D Base 'www.morphdbase.de' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-mendeley-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17632') and (source[1]!='Mendeley Data')" 
        role="warning" 
        id="data-mendeley-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.17632' but the database name is not 'Mendeley Data' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-mendeley-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.17632')) and (source[1]='Mendeley Data')" 
        role="warning" 
        id="data-mendeley-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.17632', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-mendeley-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17632') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-mendeley-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a Mendeley Data type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-edatashare-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7488') and (source[1]!='Edinburgh DataShare')" 
        role="warning" 
        id="data-edatashare-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.7488' but the database name is not 'Edinburgh DataShare' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-edatashare-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.7488')) and (source[1]='Edinburgh DataShare')" 
        role="warning" 
        id="data-edatashare-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.7488', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-edatashare-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7488') and (pub-id[1][@assigning-authority!='Edinburgh University'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-edatashare-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has an Edinburgh DataShare type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'Edinburgh University', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-eth-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.3929') and (source[1]!='ETH Library research collection')" 
        role="warning" 
        id="data-eth-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.3929' but the database name is not 'ETH Library research collection' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-eth-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.3929')) and (source[1]='ETH Library research collection')" 
        role="warning" 
        id="data-eth-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.3929', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-eth-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.3929') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-eth-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a ETH Library research collection type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-crcns-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.6080') and (source[1]!='Collaborative Research in Computational Neuroscience')" 
        role="warning" 
        id="data-crcns-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.6080' but the database name is not 'Collaborative Research in Computational Neuroscience' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-crcns-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.6080')) and (source[1]='Collaborative Research in Computational Neuroscience')" 
        role="warning" 
        id="data-crcns-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.6080', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-crcns-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.6080') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-crcns-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a CRCNS type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-morphosource-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17602') and (source[1]!='MorphoSource')" 
        role="warning" 
        id="data-morphosource-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.17602' but the database name is not 'MorphoSource' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-morphosource-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.17602')) and (source[1]='MorphoSource')" 
        role="warning" 
        id="data-morphosource-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.17602', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-morphosource-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.17602') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-morphosource-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a MorphoSource type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-neurovault-test-1" 
        test="contains(pub-id[1]/@xlink:href,'neurovault.org/collections') and not(source[1]='NeuroVault')" 
        role="warning" 
        id="data-neurovault-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'neurovault.org/collections' type link, but the database name is not 'NeuroVault' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-neurovault-test-2" 
        test="contains(pub-id[1]/@xlink:href,'neurovault.org/collections') and  pub-id[1][@assigning-authority!='other' or not(@assigning-authority)]" 
        role="warning" 
        id="data-neurovault-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'neurovault.org/collections' type link, but is not marked with 'other' as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-neurovault-test-3" 
        test="contains(pub-id[1]/@xlink:href,'neurovault.org/collections') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-neurovault-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a NeuroVault 'neurovault.org/collections' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-wwpdb-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.2210') and (source[1]!='Worldwide Protein Data Bank')" 
        role="warning" 
        id="data-wwpdb-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.2210' but the database name is not 'Worldwide Protein Data Bank' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-wwpdb-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.2210')) and (source[1]='Worldwide Protein Data Bank')" 
        role="warning" 
        id="data-wwpdb-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.2210', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-wwpdb-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.2210') and (pub-id[1][@assigning-authority!='PDB'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-wwpdb-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a Worldwide Protein Data Bank type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'PDB', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-sbgdb-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.15785/SBGRID') and (source[1]!='SBGrid Data Bank')" 
        role="warning" 
        id="data-sbgdb-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.15785/SBGRID' but the database name is not 'SBGrid Data Bank' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-sbgdb-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.15785/SBGRID')) and (source[1]='SBGrid Data Bank')" 
        role="warning" 
        id="data-sbgdb-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.15785/SBGRID', which is likely incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-sbgdb-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.15785/SBGRID') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-sbgdb-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a SBGrid Data Bank type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-harvard-dataverse-test-1" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7910') and (source[1]!='Harvard Dataverse')" 
        role="warning" 
        id="data-harvard-dataverse-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a doi starting with '10.7910' but the database name is not 'Harvard Dataverse' - <value-of select="source[1]"/>.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-harvard-dataverse-test-2" 
        test="(pub-id or ext-link) and not(starts-with(pub-id[1][@pub-id-type='doi'],'10.7910')) and (source[1]='Harvard Dataverse')" 
        role="warning" 
        id="data-harvard-dataverse-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has the database name <value-of select="source[1]"/>, but no doi starting with '10.7910', which is likely incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-harvard-dataverse-test-3" 
        test="starts-with(pub-id[1][@pub-id-type='doi'],'10.7910') and (pub-id[1][@assigning-authority!='other'  or not(@assigning-authority)])" 
        role="warning" 
        id="data-harvard-dataverse-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has a Harvard Dataverse type doi - <value-of select="pub-id[1][@pub-id-type='doi']"/>, but the assigning authority is not 'other', which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-encode-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.encodeproject.org') and not(source[1]='ENCODE')" 
        role="warning" 
        id="data-encode-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.encodeproject.org' type link, but the database name is not 'ENCODE' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-encode-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.encodeproject.org') and  pub-id[1][@assigning-authority!='other' or not(@assigning-authority)]" 
        role="warning" 
        id="data-encode-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.encodeproject.org' type link, but is not marked with 'other' as its assigning authority, which must be incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-encode-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.encodeproject.org') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-encode-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has an ENCODE 'www.encodeproject.org' type link, but is not marked as an accession type link.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-emdr-test-1" 
        test="contains(pub-id[1]/@xlink:href,'www.emdataresource.org') and not(source[1]='EMDataResource')" 
        role="warning" 
        id="data-emdr-test-1">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.emdataresource.org' type link, but the database name is not 'EMDataResource' - <value-of select="source[1]"/>. Is that correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-emdr-test-2" 
        test="contains(pub-id[1]/@xlink:href,'www.emdataresource.org') and  pub-id[1][@assigning-authority!='other' or not(@assigning-authority)]" 
        role="warning" 
        id="data-emdr-test-2">Data reference with the title '<value-of select="data-title[1]"/>' has a 'www.emdataresource.org' type link, but is not marked with 'other' as its assigning authority, which must be incorrect. https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-emdr-test-2</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-emdr-test-3" 
        test="contains(pub-id[1]/@xlink:href,'www.emdataresource.org') and pub-id[1][@pub-id-type!='accession' or not(@pub-id-type)]" 
        role="warning" 
        id="data-emdr-test-3">Data reference with the title '<value-of select="data-title[1]"/>' has an EMDataResource 'www.emdataresource.org' type link, but is not marked as an accession type link.</report>
      
    </rule>
    
    <rule context="element-citation/publisher-name" id="publisher-name-tests">
      
      <report test="matches(.,':')" 
        role="warning" 
        id="publisher-name-colon">ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing a colon - <value-of select="."/>. Should the text preceding the colon instead be captured as publisher-loc?</report>
      
      <report test="matches(.,'[Ii]nc\.')" 
        role="warning" 
        id="publisher-name-inc">ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing the text 'Inc.' Should the fullstop be removed? <value-of select="."/></report>
      
      <report test="matches(.,'�')" 
        role="error" 
        id="pub-name-replacement-character-presence"><name/> contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report test="matches(lower-case(.),'guardian|the independent|times|post|news')" 
        role="warning" 
        id="pub-name-newspaper"><name/> contains the text 'guardian', 'independent', 'times' or 'post' - <value-of select="."/> - is it a newspaper reference? If so, it should be captured as a web or a periodical reference.</report>
    </rule>
    
    <rule context="element-citation//name" id="ref-name-tests">
      <let name="type" value="ancestor::person-group[1]/@person-group-type"/>
      
      <report test="matches(.,'[Aa]uthor')" 
        role="warning" 
        id="author-test-1">name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Author'. Is this correct?</report>
      
      <report test="matches(.,'[Ed]itor')" 
        role="warning" 
        id="author-test-2">name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Editor'. Is this correct?</report>
      
      <report test="matches(.,'[Pp]ress')" 
        role="warning" 
        id="author-test-3">name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Press'. Is this correct?</report>
      
      <report test="matches(surname[1],'^[A-Z]*$')" 
        role="warning" 
        id="all-caps-surname">surname in ref '<value-of select="ancestor::ref/@id"/>' is composed of only capitalised letters - <value-of select="surname[1]"/>. Should this be captured as a collab? If not, Should it be - <value-of select="concat(substring(surname[1],1,1),lower-case(substring(surname[1],2)))"/>?</report>
      
      <report test="matches(.,'[0-9]')" 
        role="warning" 
        id="surname-number-check">name in ref '<value-of select="ancestor::ref/@id"/>' contains numbers - <value-of select="."/>. Should this be captured as a collab?</report>
      
      <report test="matches(surname[1],'^\s*?…|^\s*?\.\s?\.\s?\.')" 
        role="error" 
        id="surname-ellipsis-check">surname in ref '<value-of select="ancestor::ref/@id"/>' begins with an ellipsis which is wrong - <value-of select="surname"/>. Are there preceding author missing from the list?</report>
      
      <assert test="count(surname) = 1" 
        role="error" 
        id="surname-count">ref '<value-of select="ancestor::ref/@id"/>' has an <value-of select="$type"/> with <value-of select="count(surname)"/> surnames - <value-of select="."/> - which is incorrect.</assert>
      
      <report test="count(given-names) gt 1" 
        role="error" 
        id="given-names-count">ref '<value-of select="ancestor::ref/@id"/>' has an <value-of select="$type"/> with <value-of select="count(given-names)"/> given-names - <value-of select="."/> - which is incorrect.</report>
      
      <report test="count(given-names) lt 1" 
        role="warning" 
        id="given-names-count-2">ref '<value-of select="ancestor::ref/@id"/>' has an <value-of select="$type"/> with <value-of select="count(given-names)"/> given-names - <value-of select="."/> - is this incorrect?</report>
    </rule>
    
    <rule context="element-citation[(@publication-type='journal') and (fpage or lpage)]" id="page-conformity">
      <let name="cite" value="e:citation-format1(.)"/>
      
      <report test="matches(lower-case(source[1]),'plos|^elife$|^mbio$')" 
        role="error" 
        id="online-journal-w-page"><value-of select="$cite"/> is a <value-of select="source"/> article, but has a page number, which is incorrect.</report>
      
    </rule>
    
    <rule context="element-citation/pub-id[@pub-id-type='isbn']" id="isbn-conformity">
      <let name="t" value="translate(.,'-','')"/>
      <let name="sum" value="e:isbn-sum($t)"/>
      
      <assert test="$sum = 0" 
        role="error" 
        id="isbn-conformity-test">pub-id contains an invalid ISBN - '<value-of select="."/>'. Should it be captured as another type of pub-id?</assert>
    </rule>
    
    <rule context="isbn" id="isbn-conformity-2">
      <let name="t" value="translate(.,'-','')"/>
      <let name="sum" value="e:isbn-sum($t)"/>
      
      <assert test="$sum = 0" 
        role="error" 
        id="isbn-conformity-test-2">isbn contains an invalid ISBN - '<value-of select="."/>'. Should it be captured as another type of pub-id?</assert>
    </rule>
    
    <rule context="sec[@sec-type='data-availability']/p[1]" id="data-availability-statement">
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-sentence-conformity" 
        test="matches(.,'\.$|\?$')" 
        role="error" 
        id="das-sentence-conformity">The Data Availability Statement must end with a full stop.</assert>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#pre-das-dryad-conformity" 
        test="matches(.,'[Dd]ryad') and not(parent::sec//element-citation/pub-id[@assigning-authority='Dryad'])" 
        role="warning" 
        id="pre-das-dryad-conformity">Data Availability Statement contains the word Dryad, but there is no data citation in the dataset section with a dryad assigning authority. If there is a dryad dataset present, ensure the assigning authority is dryad, otherwise please query the authors for the reference details.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-dryad-conformity" 
        test="matches(.,'[Dd]ryad') and not(parent::sec//element-citation/pub-id[@assigning-authority='Dryad'])" 
        role="error" 
        id="final-das-dryad-conformity">Data Availability Statement contains the word Dryad, but there is no data citation in the dataset section with a dryad assigning authority.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-supplemental-conformity" 
        test="matches(.,'[Ss]upplemental [Ff]igure')" 
        role="warning" 
        id="das-supplemental-conformity">Data Availability Statement contains the phrase 'supplemental figure'. This will almost certainly need updating to account for eLife's figure labelling.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-request-conformity-1" 
        test="matches(.,'[Rr]equest')" 
        role="warning" 
        id="das-request-conformity-1">Data Availability Statement contains the phrase 'request'. Does it state data is available upon request, and if so, has this been approved by editorial?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#das-doi-conformity-1" 
        test="matches(.,'10\.\d{4,9}/[-._;()/:A-Za-z0-9]+$') and not(matches(.,'http[s]?://doi.org/'))" 
        role="error" 
        id="das-doi-conformity-1">Data Availability Statement contains a doi, but it does not contain the 'https://doi.org/' proxy. All dois should be updated to include a full 'https://doi.org/...' type link.</report>
      
    </rule>
    
    <rule context="sec[@sec-type='data-availability']/p[not(*)]" id="data-availability-p">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#final-das-p-conformity-1" 
        test="normalize-space(replace(.,' ',''))=''" 
        role="error" 
        id="final-das-p-conformity-1">p element in data availability section contains no content. It must be removed.</report>
      
    </rule>
    
    <rule context="fn-group[@content-type='ethics-information']/fn" id="ethics-info">
      
      <assert test="matches(replace(normalize-space(.),'&quot;',''),'\.$|\?$')" 
        role="error" 
        id="ethics-info-conformity">The ethics statement must end with a full stop.</assert>
      
      <report test="matches(.,'[Ss]upplemental [Ffigure]')" 
        role="warning" 
        id="ethics-info-supplemental-conformity">Ethics statement contains the phrase 'supplemental figure'. This will almost certainly need updating to account for eLife's figure labelling.</report>
      
    </rule>
    
    <rule context="sec/title" id="sec-title-conformity">
      <let name="free-text" value="replace(
        normalize-space(string-join(for $x in self::*/text() return $x,''))
        ,' ','')"/>
      <let name="no-link-text" value="translate(
        normalize-space(string-join(for $x in self::*/(*[not(name()='xref')]|text()) return $x,''))
        ,' ?.',' ')"/>
      <let name="new-org-regex" value="string-join(for $x in tokenize($org-regex,'\|') return concat('^',$x,'$'),'|')"/>
      
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-list-check"
        test="matches(.,'^\s?[A-Za-z]{1,3}\)|^\s?\([A-Za-z]{1,3}')" 
        role="warning" 
        id="sec-title-list-check">Section title might start with a list indicator - '<value-of select="."/>'. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-appendix-check"
        test="matches(.,'^[Aa]ppendix')" 
        role="warning" 
        id="sec-title-appendix-check">Section title contains the word appendix - '<value-of select="."/>'. Should it be captured as an appendix?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-appendix-check-2"
        test="ancestor::body and matches(.,'^[Ss]upplementary |^[Ss]upplemental ')" 
        role="warning" 
        id="sec-title-appendix-check-2">Should the section titled '<value-of select="."/>' be captured as an appendix?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-abbr-check"
        test="matches(.,'^[Aa]bbreviation[s]?')" 
        role="warning" 
        id="sec-title-abbr-check">Section title contains the word abbreviation - '<value-of select="."/>'. Is it an abbreviation section? eLife house style is to define abbreviations in the text when they are first mentioned.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-content-mandate"
        test="not(*) and (normalize-space(.)='')" 
        role="error" 
        id="sec-title-content-mandate">Section title must not be empty.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-full-stop"
        test="matches(replace(.,' ',' '),'\.[\s]*$')" 
        role="warning" 
        id="sec-title-full-stop">Section title ends with full stop, which is very likely to be incorrect - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-bold" 
        test="(count(*) = 1) and child::bold and ($free-text='')" 
        role="error" 
        id="sec-title-bold">All section title content is captured in bold. This is incorrect - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-underline"
        test="(count(*) = 1) and child::underline and ($free-text='')" 
        role="error" 
        id="sec-title-underline">All section title content is captured in underline. This is incorrect - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-italic"
        test="(count(*) = 1) and child::italic and ($free-text='') and not(matches(normalize-space(lower-case(.)),$new-org-regex))" 
        role="warning" 
        id="sec-title-italic">All section title content is captured in italics. Is this incorrect? If it is just a species name, then this is likely to be fine - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-dna"
        test="matches(upper-case($no-link-text),'^DNA | DNA | DNA$') and not(matches($no-link-text,'^DNA | DNA | DNA$'))" 
        role="warning" 
        id="sec-title-dna">Section title contains the phrase DNA, but it is not in all caps - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-rna"
        test="matches(upper-case($no-link-text),'^RNA | RNA | RNA$') and not(matches($no-link-text,'^RNA | RNA | RNA$'))" 
        role="warning" 
        id="sec-title-rna">Section title contains the phrase RNA, but it is not in all caps - <value-of select="."/></report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-dimension"
        test="matches($no-link-text,'^[1-4]d | [1-4]d | [1-4]d$')" 
        role="warning" 
        id="sec-title-dimension">Section title contains lowercase abbreviation for dimension, when this should always be uppercase 'D' - <value-of select="."/></report>
      
      <!-- AIDS not included due to other meaning/use -->
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#sec-title-hiv"
        test="matches(upper-case($no-link-text),'^HIV | HIV | HIV') and not(matches($no-link-text,'^HIV | HIV | HIV'))" 
        role="warning" 
        id="sec-title-hiv">Section title contains the word HIV, but it is not in all caps - <value-of select="."/></report>
      
    </rule>
    
    <rule context="abstract[not(@*)]" id="abstract-house-tests">
      <let name="subj" value="parent::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
      
      <report test="descendant::xref[@ref-type='bibr']" 
        role="warning" 
        id="xref-bibr-presence">Abstract contains a citation - '<value-of select="descendant::xref[@ref-type='bibr'][1]"/>' - which isn't usually allowed. Check that this is correct.</report>
      
      <report test="($subj = 'Research Communication') and (not(matches(self::*/descendant::p[2],'^Editorial note')))" 
        role="warning" 
        id="pre-res-comm-test">'<value-of select="$subj"/>' has only one paragraph in its abstract or the second paragraph does not begin with 'Editorial note', which is incorrect. Please ensure to check with eLife staff for the required wording.</report>
      
      <report test="($subj = 'Research Communication') and (not(matches(self::*/descendant::p[2],'^Editorial note')))" 
        role="error" 
        id="final-res-comm-test">'<value-of select="$subj"/>' has only one paragraph in its abstract or the second paragraph does not begin with 'Editorial note', which is incorrect.</report>
     
      <report test="(count(p) &gt; 1) and ($subj = 'Research Article')" 
        role="warning" 
        id="res-art-test">'<value-of select="$subj"/>' has more than one paragraph in its abstract, is this correct?</report>
    </rule>
    
    <rule context="table-wrap[@id='keyresource']//xref[@ref-type='bibr']" id="KRT-xref-tests">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#xref-column-test" 
        test="(count(ancestor::*:td/preceding-sibling::td) = 0) or (count(ancestor::*:td/preceding-sibling::td) = 1) or (count(ancestor::*:td/preceding-sibling::td) = 3)" 
        role="warning" 
        id="xref-column-test">'<value-of select="."/>' citation is in a column in the Key Resources Table which usually does not include references. Is it correct?</report>
      
    </rule>
    
    <rule context="article" id="KRT-check">
      <let name="subj" value="descendant::subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <let name="methods" value="('model', 'methods', 'materials|methods')"/>
      
      <report test="($subj = 'Research Article') and not(descendant::table-wrap[@id = 'keyresource']) and (descendant::sec[@sec-type=$methods]/*[2]/local-name()='table-wrap')" 
        role="warning" 
        id="KRT-presence">'<value-of select="$subj"/>' does not have a key resources table, but the <value-of select="descendant::sec[@sec-type=$methods]/title"/> starts with a table. Should this table be a key resources table?</report>
      
    </rule>
    
    <rule context="table-wrap[@id='keyresource']//td" id="KRT-td-checks">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#doi-link-test" 
        test="matches(.,'10\.\d{4,9}/') and (count(ext-link[contains(@xlink:href,'doi.org')]) = 0)" 
        role="error" 
        id="doi-link-test">td element containing - '<value-of select="."/>' - looks like it contains a doi, but it contains no link with 'doi.org', which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#PMID-link-test" 
        test="matches(.,'[Pp][Mm][Ii][Dd][:]?\s?[0-9][0-9][0-9][0-9]+') and (count(ext-link[contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed/') or contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov/')]) = 0)" 
        role="error" 
        id="PMID-link-test">td element containing - '<value-of select="."/>' - looks like it contains a PMID, but it contains no link pointing to PubMed, which is incorrect.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#PMCID-link-test" 
        test="matches(.,'PMCID[:]?\s?PMC[0-9][0-9][0-9]+') and (count(ext-link[contains(@xlink:href,'www.ncbi.nlm.nih.gov/pmc')]) = 0)" 
        role="error" 
        id="PMCID-link-test">td element containing - '<value-of select="."/>' - looks like it contains a PMCID, but it contains no link pointing to PMC, which is incorrect.</report>
      
      <report
        test="matches(lower-case(.),'addgene\s?#?\s?\d') and not(ext-link[contains(@xlink:href,'scicrunch.org/resolver')])" 
        role="warning" 
        id="addgene-test">td element containing - '<value-of select="."/>' - looks like it contains an addgene number. Should this be changed to an RRID with a https://scicrunch.org/resolver/RRID:addgene_{number} link?</report>
      
    </rule>
    
    <rule context="th|td" id="colour-table">
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#colour-check-table" 
        test="starts-with(@style,'author-callout')" 
        role="warning" 
        id="colour-check-table"><name/> element has colour background. Is this correct? It contains <value-of select="."/>.</report>
    </rule>
    
    <rule context="th[@style]|td[@style]" id="colour-table-2">
      <let name="allowed-values" value="('author-callout-style-b1', 'author-callout-style-b2', 'author-callout-style-b3', 'author-callout-style-b4', 'author-callout-style-b5', 'author-callout-style-b6', 'author-callout-style-b7', 'author-callout-style-b8')"/>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#pre-colour-check-table-2" 
        test="@style=$allowed-values" 
        role="warning" 
        id="pre-colour-check-table-2"><name/> element containing '<value-of select="."/>' has an @style with an unallowed value - '<value-of select="@style"/>'. The only allowed values are 'author-callout-style-b1', 'author-callout-style-b2', 'author-callout-style-b3', 'author-callout-style-b4', 'author-callout-style-b5', 'author-callout-style-b6', 'author-callout-style-b7', 'author-callout-style-b8' for blue, green orange, yellow, purple, red, pink and grey respectively. Please ensure one of these is used. If it is clear that colours are supposed to be used, but you are not sure which ones, then please query the authors - 'eLife only supports the following colours for table cells - blue, green orange, yellow, purple, red, pink and grey. Please confirm how you would like the colour(s) here captured given this information.'.</assert>
      
      <assert see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#final-colour-check-table-2" 
        test="@style=$allowed-values" 
        role="error" 
        id="final-colour-check-table-2"><name/> element contanining '<value-of select="."/>' has an @style with an unallowed value - '<value-of select="@style"/>'. The only allowed values are 'author-callout-style-b1', 'author-callout-style-b2', 'author-callout-style-b3', 'author-callout-style-b4', 'author-callout-style-b5', 'author-callout-style-b6', 'author-callout-style-b7', 'author-callout-style-b8' for blue, green orange, yellow, purple, red, pink and grey respectively.</assert>
    </rule>
    
    <rule context="named-content" id="colour-named-content">
      <let name="allowed-values" value="('city', 'department', 'state', 'sequence', 'author-callout-style-a1','author-callout-style-a2','author-callout-style-a3')"/>
      
      <report test="starts-with(@content-type,'author-callout')" 
        role="warning" 
        id="colour-named-content-check"><value-of select="."/> has colour formatting. Is this correct? Preceding text - <value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/></report>
      
      <assert test="@content-type = $allowed-values" 
        role="warning" 
        id="pre-named-content-type-check"><value-of select="."/> - text in <value-of select="parent::*/name()"/> element is captured in a &lt;named-content content-type="<value-of select="@content-type"/>"&gt;. The only allowed values for the @content-type are <value-of select="string-join($allowed-values,', ')"/>. Only blue, purple, and red text is permitted (author-callout-style-a1, author-callout-style-a2, and author-callout-style-a3 respectively). If this is coloured text and it is not one of the allowed colours, please query the authors - 'eLife only supports the following colours for text - red, blue and purple. Please confirm how you would like the colour(s) here captured given this information.'</assert>
      
      <assert test="@content-type = $allowed-values" 
        role="error" 
        id="final-named-content-type-check"><value-of select="."/> - text in <value-of select="parent::*/name()"/> element is captured in a &lt;named-content content-type="<value-of select="@content-type"/>"&gt;. The only allowed values for the @content-type are <value-of select="string-join($allowed-values,', ')"/>.</assert>
      
    </rule>
    
    <rule context="styled-content" id="colour-styled-content">
      <let name="parent" value="parent::*/local-name()"/>
      
      <report test="." 
        role="warning" 
        id="pre-colour-styled-content-check">'<value-of select="."/>' - <value-of select="$parent"/> element contains a styled content element. If it is red, blue or purple then it should be tagged using &lt;named-content&gt;. If it is not, then the author will need to be queried - 'eLife only supports the following colours for text - red, blue and purple. Please confirm how you would like the colour(s) here captured given this information.'</report>
      
      <report test="." 
        role="error" 
        id="final-colour-styled-content-check">'<value-of select="."/>' - <value-of select="$parent"/> element contains a styled content element. This is not allowed. Please ensure that &lt;named-content&gt; is used with the three permitted colours for text - red, blue and purple.</report>
    </rule>
    
    <rule context="mml:*[@mathcolor]" id="math-colour-tests">
      <let name="allowed-values" value="('red','blue','purple')"/>
      
      <assert test="@mathcolor = $allowed-values" 
        role="warning" 
        id="pre-mathcolor-test-1">math (<value-of select="name()"/> element) containing '<value-of select="."/>' has a color style which is not red, blue or purple - '<value-of select="@mathcolor"/>' - which is not allowed. If it is clear that colours are supposed to be used, but you are not sure which ones, then please query the authors - 'eLife only supports the following colours for text and maths - 'red', 'blue' and 'purple'. Please confirm how you would like the colour(s) here captured given this information.'.</assert>
      
      <assert test="@mathcolor = $allowed-values" 
        role="error" 
        id="final-mathcolor-test-1">math (<value-of select="name()"/> element) containing '<value-of select="."/>' has a color style which is not red, blue or purple - '<value-of select="@mathcolor"/>' - which is not allowed. Only 'red', 'blue' and 'purple' are allowed.</assert>
      
      <report test="@mathcolor = $allowed-values" 
        role="warning" 
        id="mathcolor-test-2">math (<value-of select="name()"/> element) containing '<value-of select="."/>' has <value-of select="@mathcolor"/> colour formatting. Is this OK?</report>
      
    </rule>
    
    <rule context="mml:*[@mathbackground]" id="mathbackground-tests">
      
      <report test="not(ancestor::table-wrap)" 
        role="warning" 
        id="pre-mathbackground-test-1">math (<value-of select="name()"/> element) containing '<value-of select="."/>' has '<value-of select="@mathbackground"/>' colour background formatting. This likely means that there's a mistake in the content which will not render correctly online. Please check this carefully against the original manuscript. If it's not a mistake, and the background colour is deliberate, then please add the following author query -&gt; 'Where possible, we prefer that colours are not used in text in the interests of accessibility and because they will not display in downstream HTML (for example in PMC). eLife does not support background colours for text, however we do support the following colours for text itself - 'red', 'blue' and 'purple'. Please confirm how you would like the colour(s) captured here given this information, and note that our preference would be to use more common forms of emphasis (such as bold, italic or underline) if possible to still convey the same meaning.'.</report>
      
      <report test="ancestor::table-wrap" 
        role="warning" 
        id="pre-mathbackground-test-2">math (<value-of select="name()"/> element) containing '<value-of select="."/>' has '<value-of select="@mathbackground"/>' colour background formatting. This likely means that there's a mistake in the content which will not render correctly online. Please check this carefully against the original manuscript. If it's not a mistake, and the background colour is deliberate, then please ensure that the background colour is captured for the table cell (rather than the maths).</report>
      
      <report test="not(ancestor::table-wrap)" 
        role="error" 
        id="final-mathbackground-test-1">math (<value-of select="name()"/> element) containing '<value-of select="."/>' has '<value-of select="@mathbackground"/>' colour background formatting. This likely means that there's a mistake in the content which will not render correctly online. If it's not a mistake, and the background colour is deliberate, then this will need to removed.</report>
      
      <report test="ancestor::table-wrap" 
        role="error" 
        id="final-mathbackground-test-2">math (<value-of select="name()"/> element) containing '<value-of select="."/>' has '<value-of select="@mathbackground"/>' colour background formatting. This likely means that there's a mistake in the content which will not render correctly online. If it's not a mistake, and the background colour is deliberate, then either the background colour will need to added to the table cell (rather than the maths), or it needs to be removed.</report>
      
    </rule>
    
    <rule context="mml:mtext" id="mtext-tests">
      
      <report test="matches(.,'^\s*\\')" 
        role="warning" 
        id="mtext-test-1">math (<value-of select="name()"/> element) contains '<value-of select="."/>' which looks suspiciously like LaTeX markup. Is it correct? Or is there missing content or content which has been processed incompletely?</report>
      
    </rule>
    
    <rule context="article[not(@article-type=('correction','retraction','article-commentary'))]/body//p[not(parent::list-item) and not(descendant::*[last()]/ancestor::disp-formula) and not(table-wrap)]|
      article[@article-type='article-commentary']/body//p[not(parent::boxed-text)]" id="p-punctuation">
      <let name="para" value="replace(.,' ',' ')"/>
      
      <assert test="matches($para,'\p{P}\s*?$')" 
        role="warning" 
        id="p-punctuation-test">paragraph doesn't end with punctuation - Is this correct?</assert>
      
      <assert test="matches($para,'\.\)?\s*?$|:\s*?$|\?\s*?$|!\s*?$|\.”\s*?|\.&quot;\s*?')" 
        role="warning" 
        id="p-bracket-test">paragraph doesn't end with a full stop, colon, question or exclamation mark - Is this correct?</assert>
    </rule>
    
    <rule context="italic[not(ancestor::ref) and not(ancestor::sub-article)]" id="italic-house-style">  
      
      <report test="matches(.,'et al[\.]?')" 
        role="error" 
        id="pre-et-al-italic-test"><name/> element contains 'et al.' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'et al[\.]?')" 
        role="warning" 
        id="final-et-al-italic-test"><name/> element contains 'et al.' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Vv]itro')" 
        role="error" 
        id="pre-in-vitro-italic-test"><name/> element contains 'in vitro' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Vv]ivo')" 
        role="error" 
        id="pre-in-vivo-italic-test"><name/> element contains 'in vivo' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ee]x [Vv]ivo')" 
        role="error" 
        id="pre-ex-vivo-italic-test"><name/> element contains 'ex vivo' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Aa] [Pp]riori')" 
        role="error" 
        id="pre-a-priori-italic-test"><name/> element contains 'a priori' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Aa] [Pp]osteriori')" 
        role="error" 
        id="pre-a-posteriori-italic-test"><name/> element contains 'a posteriori' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Dd]e [Nn]ovo')" 
        role="error" 
        id="pre-de-novo-italic-test"><name/> element contains 'de novo' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Uu]tero')" 
        role="error" 
        id="pre-in-utero-italic-test"><name/> element contains 'in utero' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Nn]atura')" 
        role="error" 
        id="pre-in-natura-italic-test"><name/> element contains 'in natura' - this should not be in italics (eLife house style).</report>
      
      <report test="matches(.,'[Ii]n [Ss]itu')" 
        role="error" 
        id="pre-in-situ-italic-test"><name/> element contains 'in situ' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Pp]lanta')" 
        role="error" 
        id="pre-in-planta-italic-test"><name/> element contains 'in planta' - this should not be in italics (eLife house style).</report> 
      
      <report test="matches(.,'[Rr]ete [Mm]irabile')" 
        role="error" 
        id="pre-rete-mirabile-italic-test"><name/> element contains 'rete mirabile' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Nn]omen [Nn]ovum')" 
        role="error" 
        id="pre-nomen-novum-italic-test"><name/> element contains 'nomen novum' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'^[Ss]ensu$| [Ss]ensu$|^[Ss]ensu | [Ss]ensu ')" 
        role="error" 
        id="pre-sensu-italic-test"><name/> element contains 'sensu' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Aa]d [Ll]ibitum')" 
        role="error" 
        id="pre-ad-libitum-italic-test"><name/> element contains 'ad libitum' - this should not be in italics (eLife house style).</report>
      
      <report test="matches(.,'[Ii]n [Oo]vo')" 
        role="error" 
        id="pre-in-ovo-italic-test"><name/> element contains 'In Ovo' - this should not be in italics (eLife house style).</report>
      
    </rule>
    
    <rule context="article" id="final-latin-conformance">
      <let name="latin-terms" value="e:get-latin-terms(.,$latin-regex)"/>
      <let name="roman-count" value="sum(for $x in $latin-terms//*:list[@list-type='roman']//*:match return number($x/@count))"/>
      <let name="italic-count" value="sum(for $x in $latin-terms//*:list[@list-type='italic']//*:match return number($x/@count))"/>
      
      <report test="($italic-count != 0) and ($roman-count gt $italic-count)" 
        role="warning" 
        id="latin-italic-info">Latin terms are not consistenly either roman or italic. There are <value-of select="$roman-count"/> roman terms which is more common, and <value-of select="$italic-count"/> italic term(s). The following terms should be unitalicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='italic'])"/>.</report>
      
      <report test="($roman-count != 0) and ($italic-count gt $roman-count)" 
        role="warning" 
        id="latin-roman-info">Latin terms are not consistenly either roman or italic. There are <value-of select="$italic-count"/> italic terms which is more common, and <value-of select="$roman-count"/> roman term(s). The following terms should be italicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='roman'])"/>.</report>
      
      <report test="($roman-count != 0) and ($italic-count = $roman-count)" 
        role="warning" 
        id="latin-conformance-info">Latin terms are not consistenly either roman or italic. There are an equal number of italic (<value-of select="$italic-count"/>) and roman (<value-of select="$roman-count"/>) terms. The following terms are italicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='italic'])"/>. The following terms are unitalicised: <value-of select="e:print-latin-terms($latin-terms//*:list[@list-type='roman'])"/>.</report>
    </rule>
    
    <rule context="p//ext-link[not(ancestor::table-wrap) and not(ancestor::sub-article)]" id="pubmed-link">
      
      <report test="matches(@xlink:href,'^http[s]?://www.ncbi.nlm.nih.gov/pubmed/[\d]*')" 
        role="warning" 
        id="pubmed-presence"><value-of select="parent::*/local-name()"/> element contains what looks like a link to a PubMed article - <value-of select="."/> - should this be added a reference instead?</report>
      
      <report test="matches(@xlink:href,'^http[s]?://www.ncbi.nlm.nih.gov/pmc/articles/PMC[\d]*')" 
        role="warning" 
        id="pmc-presence"><value-of select="parent::*/local-name()"/> element contains what looks like a link to a PMC article - <value-of select="."/> - should this be added a reference instead?</report>
      
    </rule>
    
    <rule context="table-wrap//ext-link[(contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed') or contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov')) and not(ancestor::sub-article)]" id="pubmed-link-2">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="lc" value="lower-case($pre-text)"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#pre-pmid-spacing-table" 
        test="ends-with($lc,'pmid: ') or ends-with($lc,'pmid ')" 
        role="error" 
        id="pre-pmid-spacing-table">PMID link should be preceding by 'PMID:' with no space but instead it is preceded by '<value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#final-pmid-spacing-table" 
        test="ends-with($lc,'pmid: ') or ends-with($lc,'pmid ')" 
        role="warning" 
        id="final-pmid-spacing-table">PMID link should be preceding by 'PMID:' with no space but instead it is preceded by '<value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/>'.</report>
    </rule>
    
    <rule context="ext-link[contains(@xlink:href,'scicrunch.org/resolver') and not(ancestor::sub-article)]" id="rrid-link">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="lc" value="lower-case($pre-text)"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/rrids#pre-rrid-spacing" 
        test="ends-with($lc,'rrid: ') or ends-with($lc,'rrid ')" 
        role="error" 
        id="pre-rrid-spacing">RRID (scicrunch) link should be preceded by 'RRID:' with no space but instead it is preceded by '<value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/>'.</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/rrids#final-rrid-spacing" 
        test="ends-with($lc,'rrid: ') or ends-with($lc,'rrid ')" 
        role="warning" 
        id="final-rrid-spacing">RRID (scicrunch) link should be preceded by 'RRID:' with no space but instead it is preceded by '<value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/>'.</report>
    </rule>
    
    <rule context="ref-list/ref" id="ref-link-mandate">
      <let name="id" value="@id"/>
      
      <assert test="ancestor::article//xref[@rid = $id]" 
        role="warning" 
        id="pre-ref-link-presence">'<value-of select="$id"/>' has no linked citations. Either the reference should be removed or a citation linking to it needs to be added.</assert>
      
      <assert test="ancestor::article//xref[@rid = $id]" 
        role="error" 
        id="final-ref-link-presence">'<value-of select="$id"/>' has no linked citations. Either the reference should be removed or a citation linking to it needs to be added.</assert>
    </rule>
    
    <rule context="fig[not(descendant::permissions)]|media[@mimetype='video' and not(descendant::permissions)]|table-wrap[not(descendant::permissions)]|supplementary-material[not(descendant::permissions)]" id="fig-permissions-check">
      <let name="label" value="replace(label[1],'\.','')"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-1" 
        test="matches(caption[1],'[Rr]eproduced from')" 
        role="warning" 
        id="reproduce-test-1">The caption for <value-of select="$label"/> contains the text 'reproduced from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-2" 
        test="matches(caption[1],'[Rr]eproduced [Ww]ith [Pp]ermission')" 
        role="warning" 
        id="reproduce-test-2">The caption for <value-of select="$label"/> contains the text 'reproduced with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-3" 
        test="matches(caption[1],'[Aa]dapted from|[Aa]dapted with')" 
        role="warning" 
        id="reproduce-test-3">The caption for <value-of select="$label"/> contains the text 'adapted from ...', but has no permissions. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-4" 
        test="matches(caption[1],'[Rr]eprinted from')" 
        role="warning" 
        id="reproduce-test-4">The caption for <value-of select="$label"/> contains the text 'reprinted from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-5" 
        test="matches(caption[1],'[Rr]eprinted [Ww]ith [Pp]ermission')" 
        role="warning" 
        id="reproduce-test-5">The caption for <value-of select="$label"/> contains the text 'reprinted with permission', but has no permissions. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-6" 
        test="matches(caption[1],'[Mm]odified from')" 
        role="warning" 
        id="reproduce-test-6">The caption for <value-of select="$label"/> contains the text 'modified from', but has no permissions. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-7"
        test="matches(caption[1],'[Mm]odified [Ww]ith')" 
        role="warning" 
        id="reproduce-test-7">The caption for <value-of select="$label"/> contains the text 'modified with', but has no permissions. Is this correct?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/licensing-and-copyright#reproduce-test-8" 
        test="matches(caption[1],'[Uu]sed [Ww]ith [Pp]ermission')" 
        role="warning" 
        id="reproduce-test-8">The caption for <value-of select="$label"/> contains the text 'used with permission', but has no permissions. Is this correct?</report>
    </rule>
    
    <rule context="xref[not(@ref-type='bibr')]" id="xref-formatting">
      <let name="parent" value="parent::*/local-name()"/>
      <let name="child" value="child::*/local-name()"/>
      <let name="formatting-elems" value="('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby')"/>
      
      <report test="$parent = $formatting-elems" 
        role="error" 
        id="xref-parent-test">xref - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which is not correct.</report>
      
      <report test="$child = $formatting-elems" 
        role="warning" 
        id="xref-child-test">xref - <value-of select="."/> - has a formatting child element - <value-of select="$child"/> - which is likely not correct.</report>
    </rule>
    
    <rule context="xref[@ref-type='bibr']" id="ref-xref-formatting">
      <let name="parent" value="parent::*/local-name()"/>
      <let name="child" value="child::*/local-name()"/>
      <let name="formatting-elems" value="('bold','fixed-case','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')"/>
      
      <report test="$parent = ($formatting-elems,'italic')" 
        role="error" 
        id="ref-xref-parent-test">xref - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which is not correct.</report>
      
      <report test="$child = $formatting-elems" 
        role="error" 
        id="ref-xref-child-test">xref - <value-of select="."/> - has a formatting child element - <value-of select="$child"/> - which is not correct.</report>
      
      <report test="italic" 
        role="warning" 
        id="ref-xref-italic-child-test">xref - <value-of select="."/> - contains italic formatting. Is this correct?</report>
    </rule>
    
    <rule context="article" id="code-fork">
      <let name="test" value="e:code-check(lower-case(.))"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/toolkit/archiving-code#code-fork-info" 
        test="$test//*:match" 
        role="warning" 
        id="code-fork-info">Article possibly contains code that needs forking. Search - <value-of select="string-join(for $x in $test//*:match return $x,', ')"/>.</report>
    </rule>
    
    <rule context="kwd-group[@kwd-group-type='author-keywords']/kwd" id="auth-kwd-style">
      <let name="article-text" value="string-join(for $x in ancestor::article/*[local-name() = 'body' or local-name() = 'back']//*
        return
        if ($x/ancestor::sec[@sec-type='data-availability']) then ()
        else if ($x/ancestor::sec[@sec-type='additional-information']) then ()
        else if ($x/ancestor::ref-list) then ()
        else if ($x/local-name() = 'xref') then ()
        else $x/text(),'')"/>
      <let name="lower" value="lower-case(.)"/>
      <let name="t" value="replace($article-text,concat('\. ',.),'')"/>
      
      <report test="not(matches(.,'RNA|[Cc]ryoEM|[34]D')) and (. != $lower) and not(contains($t,.))" 
        role="warning" 
        id="auth-kwd-check">Keyword - '<value-of select="."/>' - does not appear in the article text with this capitalisation. Should it be <value-of select="$lower"/> instead?</report>
      
      <report test="matches(.,'&amp;#x\d')" 
        role="warning" 
        id="auth-kwd-check-2">Keyword contains what looks like a broken unicode - <value-of select="."/>.</report>
      
      <report test="contains(.,'&lt;') or contains(.,'&gt;')" 
        role="error" 
        id="auth-kwd-check-3">Keyword contains markup captured as text - <value-of select="."/>. Please remove it and ensure that it is marked up properly (if necessary).</report>
      
      <report test="matches(.,'[\(\)\[\]]') or contains(.,'{') or contains(.,'}')" 
        role="warning" 
        id="auth-kwd-check-4">Keyword contains brackets - <value-of select="."/>. These should either simply be removed, or added as two keywords (with the brackets still removed).</report>
      
      <report test="contains($lower,' and ')" 
        role="warning" 
        id="auth-kwd-check-5">Keyword contains 'and' - <value-of select="."/>. These should be split out into two keywords.</report>
      
      <report test="not(ancestor::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1] = $features-subj) and count(tokenize(.,'\s')) gt 4" 
        role="warning" 
        id="auth-kwd-check-6">Keyword contains more than 4 words - <value-of select="."/>. Should these be split out into separate keywords?</report>
      
      <report test="not(italic) and matches($lower,$org-regex)" 
        role="warning" 
        id="auth-kwd-check-7">Keyword contains an organism name which is not in italics - <value-of select="."/>. Please italicise the organism name in the keyword.</report>
    </rule>
    
    <rule context="ref-list//element-citation/person-group[@person-group-type='author']//given-names" id="ref-given-names">
      
      <report test="string-length(.) gt 4" 
        role="warning" 
        id="ref-given-names-test-1">Given names should always be initialised. Ref '<value-of select="ancestor::ref[1]/@id"/>' contains a given names with a string longer than 4 characters - '<value-of select="."/>' in <value-of select="concat(preceding-sibling::surname[1],' ',.)"/>. Is this a surname captured as given names? Or a fully spelt out given names?</report>
    </rule>
    
    <rule context="sec[@sec-type='data-availability']//element-citation/person-group[@person-group-type='author']//given-names" id="data-ref-given-names">      
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/data-availability#data-ref-given-names-test-1" 
        test="string-length(.) gt 4" 
        role="warning" 
        id="data-ref-given-names-test-1">Given names should always be initialised. Ref contains a given names with a string longer than 4 characters - '<value-of select="."/>' in <value-of select="concat(preceding-sibling::surname[1],' ',.)"/>. Is this a surname captured as given names? Or a fully spelt out given names?</report>
      
    </rule>
    
    <rule context="fig[ancestor::sub-article]/caption/title" id="ar-fig-title-tests">     
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#ar-fig-title-test-1" 
        test="lower-case(normalize-space(.))=('title','title.')" 
        role="warning" 
        id="ar-fig-title-test-1">Please query author for a <value-of select="ancestor::fig/label"/> title, and/or remove placeholder title text - <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="sec/p/*[1][not(preceding-sibling::text()) or (normalize-space(preceding-sibling::text())='')]" id="section-title-tests">     
      <let name="following-text" value="following-sibling::text()[1]"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure#section-title-test-1"
        test="(name()=('italic','bold','underline')) and (ends-with(.,'.') or matches($following-text,'^\s?\.|^[\p{P}]?\s?[A-Z]|^[\p{P}]?\s?\d')) and not((name()='italic') and matches(lower-case(.),$sec-title-regex))" 
        role="warning" 
        id="section-title-test-1"><name/> text begins a paragraph - <value-of select="."/> - Should it be marked up as a section title (Heading level <value-of select="count(ancestor::sec) + 1"/>)?</report>
      
    </rule>
    
    <rule context="strike" id="strike-tests">     
      
      <report test="." 
        role="warning" 
        id="final-strike-flag"><value-of select="parent::*/local-name()"/> element contains text with strikethrough formatting - <value-of select="."/> - Is this correct? Or have the authors added strikethrough formatting as an indication that the content should be removed?</report>
      
    </rule>
    
    <rule context="title[(count(*)=1) and (child::bold or child::italic)]" id="title-bold-tests">  
    <let name="free-text" value="replace(       normalize-space(string-join(for $x in self::*/text() return $x,''))       ,' ','')"/>
    
    <report test="$free-text=''" 
        role="warning" 
        id="title-all-bold-test-1">Title is entirely in <value-of select="child::*[1]/local-name()"/> - '<value-of select="."/>'. Is this correct?</report>
    </rule>
    
    <rule context="italic[matches(lower-case(.),$org-regex)]" id="italic-org-tests">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      <let name="pre-token" value="substring($pre-text, string-length($pre-text), 1)"/>
      <let name="post-token" value="substring($post-text, 1, 1)"/>
      
      <assert test="(substring(.,1,1) = (' ',' ')) or ($pre-token='') or matches($pre-token,'[\s\p{P}]')" 
        role="warning" 
        id="italic-org-test-1">There is no space between the organism name '<value-of select="."/>' and its preceeding text - '<value-of select="concat(substring($pre-text,string-length($pre-text)-10),.)"/>'. Is this correct or is there a missing space?</assert>
      
      <assert test="(substring(., string-length(.), 1) = (' ',' ')) or ($post-token='') or matches($post-token,'[\s\p{P}]')" 
        role="warning" 
        id="italic-org-test-2">There is no space between the organism name '<value-of select="."/>' and its following text - '<value-of select="concat(.,substring($post-text,1,10))"/>'. Is this correct or is there a missing space?</assert>
    </rule>
  </pattern>
  
  <pattern id="doi-ref-checks">
    
    <rule context="element-citation[(@publication-type='journal') and not(pub-id[@pub-id-type='doi']) and year and source]" id="doi-journal-ref-checks">
      <let name="cite" value="e:citation-format1(.)"/>
      <let name="year" value="number(replace(year[1],'[^\d]',''))"/>
      <let name="journal" value="replace(lower-case(source[1]),'^the ','')"/>
      <let name="journals" value="'journals.xml'"/>
      
      <assert test="some $x in document($journals)/journals/journal satisfies (($x/@title/string()=$journal) and (number($x/@year) ge $year))" 
        role="warning" 
        id="journal-doi-test-1"><value-of select="$cite"/> is a journal ref without a doi. Should it have one?</assert>
      
    </rule>

    <rule context="element-citation[(@publication-type='book') and not(pub-id[@pub-id-type='doi']) and year and publisher-name]" id="doi-book-ref-checks">
      <let name="cite" value="e:citation-format1(.)"/>
      <let name="year" value="number(replace(year[1],'[^\d]',''))"/>
      <let name="publisher" value="lower-case(publisher-name[1])"/>
      <let name="publishers" value="'publishers.xml'"/>
      
      <report test="some $x in document($publishers)/publishers/publisher satisfies ($x/@title/string()=$publisher)" 
        role="warning" 
        id="book-doi-test-1"><value-of select="$cite"/> is a book ref without a doi, but its publisher (<value-of select="publisher-name[1]"/>) is known to register dois with some books/chapters. Should it have one?</report>
      
    </rule>
    
    <rule context="element-citation[(@publication-type='software') and year and source]" id="doi-software-ref-checks">
      <let name="cite" value="e:citation-format1(.)"/>
      <let name="host" value="lower-case(source[1])"/>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#software-doi-test-1" 
        test="$host='zenodo' and not(contains(ext-link,'10.5281/zenodo'))" 
        role="warning" 
        id="software-doi-test-1"><value-of select="$cite"/> is a software ref with a host (<value-of select="source[1]"/>) known to register dois starting with '10.5281/zenodo'. Should it have a link in the format 'https://doi.org/10.5281/zenodo...'?</report>
      
      <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/references/software-references#software-doi-test-2" 
        test="$host='figshare' and not(contains(ext-link,'10.6084/m9.figshare'))" 
        role="warning" 
        id="software-doi-test-2"><value-of select="$cite"/> is a software ref with a host (<value-of select="source[1]"/>) known to register dois starting with '10.6084/m9.figshare'. Should it have a link in the format 'https://doi.org/10.6084/m9.figshare...'?</report>
      
    </rule>
    
    <rule context="element-citation[(@publication-type='confproc') and not(pub-id[@pub-id-type='doi']) and year and conf-name]" id="doi-conf-ref-checks">
      <let name="name" value="lower-case(conf-name[1])"/>
      
      <report test="contains($name,'ieee')" 
        role="warning" 
        id="conf-doi-test-1"><value-of select="e:citation-format1(.)"/> is a conference ref without a doi, but it's a conference which is known to possibly have dois - (<value-of select="conf-name[1]"/>). Should it have one?</report>
      
    </rule>
  </pattern>
  
  <pattern id="links-in-ref-tests">
    
    <rule context="element-citation/source | element-citation/article-title | element-citation/chapter-title | element-citation/data-title"
      id="link-ref-tests">
      
      <report test="matches(.,'^10\.\d{4,9}/[-._;()/:A-Za-z0-9]+|\s10\.\d{4,9}/[-._;()/:A-Za-z0-9]+')" 
        role="error" 
        id="doi-in-display-test"><value-of select="name()"/> element contains a doi - <value-of select="."/>. The doi must be moved to the appropriate field, and the correct information should be included in this element (or queried if the information is missing).</report>
      
      <report test="matches(.,'https?:|ftp://|git://|tel:|mailto:')" 
        role="error" 
        id="link-in-display-test"><value-of select="name()"/> element contains a url - <value-of select="."/>. The url must be moved to the appropriate field (if it is a doi, then it should be captured as a doi without the 'https://doi.org/' prefix), and the correct information should be included in this element (or queried if the information is missing).</report>
      
    </rule>
      
  </pattern>
  
  <pattern id="fundref-pattern">
    
    <rule context="article//ack" id="fundref-rule">
      <let name="ack" value="."/>   
      <let name="funding-group" value="distinct-values(ancestor::article//funding-group//institution-id)"/>
      <let name="funders" value="'funders.xml'"/>
      
      <report test="some $funder in document($funders)//funder satisfies ((contains($ack,concat(' ',$funder,' ')) or contains($ack,concat(' ',$funder,'.'))) and not($funder/@fundref = $funding-group))" 
        role="warning" 
        id="fundref-test-1">Acknowledgements contains funder(s) in the open funder registry, but their doi is not listed in the funding section. Please check - <value-of select="string-join(for $x in document($funders)//funder[((contains($ack,concat(' ',.,' ')) or contains($ack,concat(' ',.,'.'))) and not(@fundref = $funding-group))] return concat($x,' - ',$x/@fundref),'; ')"/>.</report>
    </rule>
    
  </pattern>
  
  <pattern id="unicode-checks">
    
    <rule context="sub-article//p[contains(.,'â') or contains(.,'Â') or contains(.,'Å') or contains(.,'Ã')  or contains(.,'Ë')  or contains(.,'Æ')]|       sub-article//td[contains(.,'â') or contains(.,'Â') or contains(.,'Å') or contains(.,'Ã')  or contains(.,'Ë')  or contains(.,'Æ')]|       sub-article//th[contains(.,'â') or contains(.,'Â') or contains(.,'Å') or contains(.,'Ã')  or contains(.,'Ë')  or contains(.,'Æ')]" id="unicode-tests">
      
        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-1" 
        test="contains(.,'â‚¬')" 
        role="warning" 
        id="unicode-test-1"><name/> element contains 'â‚¬' - this should instead be the character '€'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-2" 
        test="contains(.,'Ã€')" 
        role="warning" 
        id="unicode-test-2"><name/> element contains 'Ã€' - this should instead be the character 'À'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-3" 
        test="contains(.,'Ã')" 
        role="warning" 
        id="unicode-test-3"><name/> element contains 'Ã' - this should instead be the character 'Á'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-4" 
        test="contains(.,'â€š')" 
        role="warning" 
        id="unicode-test-4"><name/> element contains 'â€š' - this should instead be the character '‚'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-5" 
        test="contains(.,'Ã‚')" 
        role="warning" 
        id="unicode-test-5"><name/> element contains 'Ã‚' - this should instead be the character 'Â'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-6" 
        test="contains(.,'Æ’')" 
        role="warning" 
        id="unicode-test-6"><name/> element contains 'Æ’' - this should instead be the character 'ƒ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-7" 
        test="contains(.,'Ãƒ')" 
        role="warning" 
        id="unicode-test-7"><name/> element contains 'Ãƒ' - this should instead be the character 'Ã'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-8" 
        test="contains(.,'â€ž')" 
        role="warning" 
        id="unicode-test-8"><name/> element contains 'â€ž' - this should instead be the character '„'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-9" 
        test="contains(.,'Ã„')" 
        role="warning" 
        id="unicode-test-9"><name/> element contains 'Ã„' - this should instead be the character 'Ä'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-10" 
        test="contains(.,'â€¦')" 
        role="warning" 
        id="unicode-test-10"><name/> element contains 'â€¦' - this should instead be the character '…'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-11" 
        test="contains(.,'Ã…')" 
        role="warning" 
        id="unicode-test-11"><name/> element contains 'Ã…' - this should instead be the character 'Å'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-13" 
        test="contains(.,'Ã†')" 
        role="warning" 
        id="unicode-test-13"><name/> element contains 'Ã†' - this should instead be the character 'Æ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-14" 
        test="contains(.,'â€¡')" 
        role="warning" 
        id="unicode-test-14"><name/> element contains 'â€¡' - this should instead be the character '‡'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-15" 
        test="contains(.,'Ã‡')" 
        role="warning" 
        id="unicode-test-15"><name/> element contains 'Ã‡' - this should instead be the character 'Ç'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-16" 
        test="contains(.,'Ë†')" 
        role="warning" 
        id="unicode-test-16"><name/> element contains 'Ë†' - this should instead be the character 'ˆ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-17" 
        test="contains(.,'Ãˆ')" 
        role="warning" 
        id="unicode-test-17"><name/> element contains 'Ãˆ' - this should instead be the character 'È'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-18" 
        test="contains(.,'â€°')" 
        role="warning" 
        id="unicode-test-18"><name/> element contains 'â€°' - this should instead be the character '‰'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-19" 
        test="contains(.,'Ã‰')" 
        role="warning" 
        id="unicode-test-19"><name/> element contains 'Ã‰' - this should instead be the character 'É'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-21" 
        test="contains(.,'ÃŠ')" 
        role="warning" 
        id="unicode-test-21"><name/> element contains 'ÃŠ' - this should instead be the character 'Ê'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-22" 
        test="contains(.,'â€¹')" 
        role="warning" 
        id="unicode-test-22"><name/> element contains 'â€¹' - this should instead be the character '‹'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-23" 
        test="contains(.,'Ã‹')" 
        role="warning" 
        id="unicode-test-23"><name/> element contains 'Ã‹' - this should instead be the character 'Ë'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-24" 
        test="contains(.,'Å’')" 
        role="warning" 
        id="unicode-test-24"><name/> element contains 'Å’' - should this instead be the character 'Œ'? - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-25" 
        test="contains(.,'ÃŒ')" 
        role="warning" 
        id="unicode-test-25"><name/> element contains 'ÃŒ' - this should instead be the character 'Ì'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-26" 
        test="contains(.,'Ã')" 
        role="warning" 
        id="unicode-test-26"><name/> element contains 'Ã' - this should instead be the character 'Í'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-27" 
        test="contains(.,'Å½')" 
        role="warning" 
        id="unicode-test-27"><name/> element contains 'Å½' - this should instead be the character 'Ž'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-28" 
        test="contains(.,'ÃŽ')" 
        role="warning" 
        id="unicode-test-28"><name/> element contains 'ÃŽ' - this should instead be the character 'Î'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-29" 
        test="contains(.,'Ã')" 
        role="warning" 
        id="unicode-test-29"><name/> element contains 'Ã' - this should instead be the character 'Ï'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-30" 
        test="contains(.,'Ã')" 
        role="warning" 
        id="unicode-test-30"><name/> element contains 'Ã' - this should instead be the character 'Ð'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-31" 
        test="contains(.,'â€˜')" 
        role="warning" 
        id="unicode-test-31"><name/> element contains 'â€˜' - this should instead be the character '‘'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-32" 
        test="contains(.,'Ã‘')" 
        role="warning" 
        id="unicode-test-32"><name/> element contains 'Ã‘' - this should instead be the character 'Ñ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-33" 
        test="contains(.,'â€™')" 
        role="warning" 
        id="unicode-test-33"><name/> element contains 'â€™' - this should instead be the character '’'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-34" 
        test="contains(.,'Ã’')" 
        role="warning" 
        id="unicode-test-34"><name/> element contains 'Ã’' - this should instead be the character 'Ò'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-35" 
        test="contains(.,'â€œ')" 
        role="warning" 
        id="unicode-test-35"><name/> element contains 'â€œ' - this should instead be the character '“'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-36" 
        test="contains(.,'Ã“')" 
        role="warning" 
        id="unicode-test-36"><name/> element contains 'Ã“' - this should instead be the character 'Ó'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-37" 
        test="contains(.,'â€')" 
        role="warning" 
        id="unicode-test-37"><name/> element contains 'â€' - this should instead be the character '”'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-38" 
        test="contains(.,'Ã”')" 
        role="warning" 
        id="unicode-test-38"><name/> element contains 'Ã”' - this should instead be the character 'Ô'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-39" 
        test="contains(.,'Ã•')" 
        role="warning" 
        id="unicode-test-39"><name/> element contains 'Ã•' - this should instead be the character 'Õ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-40" 
        test="contains(.,'â€“')" 
        role="warning" 
        id="unicode-test-40"><name/> element contains 'â€“' - this should instead be the character '–'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-41" 
        test="contains(.,'Ã–')" 
        role="warning" 
        id="unicode-test-41"><name/> element contains 'Ã–' - this should instead be the character 'Ö'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-42" 
        test="contains(.,'â€”')" 
        role="warning" 
        id="unicode-test-42"><name/> element contains 'â€”' - this should instead be the character '—'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-43" 
        test="contains(.,'Ã—')" 
        role="warning" 
        id="unicode-test-43"><name/> element contains 'Ã—' - this should instead be the character '×'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-44" 
        test="contains(.,'Ëœ')" 
        role="warning" 
        id="unicode-test-44"><name/> element contains 'Ëœ' - this should instead be the character '˜'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-45" 
        test="contains(.,'Ã˜')" 
        role="warning" 
        id="unicode-test-45"><name/> element contains 'Ã˜' - this should instead be the character 'Ø'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-46" 
        test="contains(.,'Ã™')" 
        role="warning" 
        id="unicode-test-46"><name/> element contains 'Ã™' - this should instead be the character 'Ù'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-47" 
        test="contains(.,'Å¡')" 
        role="warning" 
        id="unicode-test-47"><name/> element contains 'Å¡' - this should instead be the character 'š'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-48" 
        test="contains(.,'Ãš')" 
        role="warning" 
        id="unicode-test-48"><name/> element contains 'Ãš' - this should instead be the character 'Ú'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-49" 
        test="contains(.,'â€º')" 
        role="warning" 
        id="unicode-test-49"><name/> element contains 'â€º' - this should instead be the character '›'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-50" 
        test="contains(.,'Ã›')" 
        role="warning" 
        id="unicode-test-50"><name/> element contains 'Ã›' - this should instead be the character 'Û'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-51" 
        test="contains(.,'Å“')" 
        role="warning" 
        id="unicode-test-51"><name/> element contains 'Å“' - this should instead be the character 'œ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-52" 
        test="contains(.,'Ãœ')" 
        role="warning" 
        id="unicode-test-52"><name/> element contains 'Ãœ' - this should instead be the character 'Ü'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-53" 
        test="contains(.,'Ã')" 
        role="warning" 
        id="unicode-test-53"><name/> element contains 'Ã' - this should instead be the character 'Ý'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-54" 
        test="contains(.,'Å¾')" 
        role="warning" 
        id="unicode-test-54"><name/> element contains 'Å¾' - this should instead be the character 'ž'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-55" 
        test="contains(.,'Ãž')" 
        role="warning" 
        id="unicode-test-55"><name/> element contains 'Ãž' - this should instead be the character 'Þ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-56" 
        test="contains(.,'Å¸')" 
        role="warning" 
        id="unicode-test-56"><name/> element contains 'Å¸' - this should instead be the character 'Ÿ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-57" 
        test="contains(.,'ÃŸ')" 
        role="warning" 
        id="unicode-test-57"><name/> element contains 'ÃŸ' - this should instead be the character 'ß'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-58" 
        test="contains(.,'Â¡')" 
        role="warning" 
        id="unicode-test-58"><name/> element contains 'Â¡' - this should instead be the character '¡'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-59" 
        test="contains(.,'Ã¡')" 
        role="warning" 
        id="unicode-test-59"><name/> element contains 'Ã¡' - this should instead be the character 'á'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-60" 
        test="contains(.,'Â¢')" 
        role="warning" 
        id="unicode-test-60"><name/> element contains 'Â¢' - this should instead be the character '¢'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-61" 
        test="contains(.,'Ã¢')" 
        role="warning" 
        id="unicode-test-61"><name/> element contains 'Ã¢' - this should instead be the character 'â'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-62" 
        test="contains(.,'Â£')" 
        role="warning" 
        id="unicode-test-62"><name/> element contains 'Â£' - this should instead be the character '£'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-63" 
        test="contains(.,'Ã£')" 
        role="warning" 
        id="unicode-test-63"><name/> element contains 'Ã£' - this should instead be the character 'ã'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-64" 
        test="contains(.,'Â¤')" 
        role="warning" 
        id="unicode-test-64"><name/> element contains 'Â¤' - this should instead be the character '¤'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-65" 
        test="contains(.,'Ã¤')" 
        role="warning" 
        id="unicode-test-65"><name/> element contains 'Ã¤' - this should instead be the character 'ä'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-66" 
        test="contains(.,'Ã¥')" 
        role="warning" 
        id="unicode-test-66"><name/> element contains 'Ã¥' - this should instead be the character 'å'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-67" 
        test="contains(.,'Â¨')" 
        role="warning" 
        id="unicode-test-67"><name/> element contains 'Â¨' - this should instead be the character '¨'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-68" 
        test="contains(.,'Ã¨')" 
        role="warning" 
        id="unicode-test-68"><name/> element contains 'Ã¨' - this should instead be the character 'è'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-69" 
        test="contains(.,'Âª')" 
        role="warning" 
        id="unicode-test-69"><name/> element contains 'Âª' - this should instead be the character 'ª'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-70" 
        test="contains(.,'Ãª')" 
        role="warning" 
        id="unicode-test-70"><name/> element contains 'Ãª' - this should instead be the character 'ê'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-71" 
        test="contains(.,'Â­')" 
        role="warning" 
        id="unicode-test-71"><name/> element contains 'Â­' - this should instead be the character '­'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-72" 
        test="contains(.,'Ã­')" 
        role="warning" 
        id="unicode-test-72"><name/> element contains 'Ã­' - this should instead be the character 'í'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-73" 
        test="contains(.,'Â¯')" 
        role="warning" 
        id="unicode-test-73"><name/> element contains 'Â¯' - this should instead be the character '¯'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-74" 
        test="contains(.,'Ã¯')" 
        role="warning" 
        id="unicode-test-74"><name/> element contains 'Ã¯' - this should instead be the character 'ï'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-75" 
        test="contains(.,'Â°')" 
        role="warning" 
        id="unicode-test-75"><name/> element contains 'Â°' - this should instead be the character '°'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-76" 
        test="contains(.,'Ã°')" 
        role="warning" 
        id="unicode-test-76"><name/> element contains 'Ã°' - this should instead be the character 'ð'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-77" 
        test="contains(.,'Â±')" 
        role="warning" 
        id="unicode-test-77"><name/> element contains 'Â±' - this should instead be the character '±'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-78" 
        test="contains(.,'Ã±')" 
        role="warning" 
        id="unicode-test-78"><name/> element contains 'Ã±' - this should instead be the character 'ñ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-79" 
        test="contains(.,'Â´')" 
        role="warning" 
        id="unicode-test-79"><name/> element contains 'Â´' - this should instead be the character '´'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-80" 
        test="contains(.,'Ã´')" 
        role="warning" 
        id="unicode-test-80"><name/> element contains 'Ã´' - this should instead be the character 'ô'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-81" 
        test="contains(.,'Âµ')" 
        role="warning" 
        id="unicode-test-81"><name/> element contains 'Âµ' - this should instead be the character 'µ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-82" 
        test="contains(.,'Ãµ')" 
        role="warning" 
        id="unicode-test-82"><name/> element contains 'Ãµ' - this should instead be the character 'õ'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-83" 
        test="contains(.,'Â¶')" 
        role="warning" 
        id="unicode-test-83"><name/> element contains 'Â¶' - this should instead be the character '¶'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-84" 
        test="contains(.,'Ã¶')" 
        role="warning" 
        id="unicode-test-84"><name/> element contains 'Ã¶' - this should instead be the character 'ö'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-85" 
        test="contains(.,'Â·')" 
        role="warning" 
        id="unicode-test-85"><name/> element contains 'Â·' - this should instead be the character '·'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-86" 
        test="contains(.,'Ã·')" 
        role="warning" 
        id="unicode-test-86"><name/> element contains 'Ã·' - this should instead be the character '÷'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-87" 
        test="contains(.,'Â¸')" 
        role="warning" 
        id="unicode-test-87"><name/> element contains 'Â¸' - this should instead be the character '¸'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-88" 
        test="contains(.,'Ã¸')" 
        role="warning" 
        id="unicode-test-88"><name/> element contains 'Ã¸' - this should instead be the character 'ø'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-89" 
        test="contains(.,'Ã¹')" 
        role="warning" 
        id="unicode-test-89"><name/> element contains 'Ã¹' - this should instead be the character 'ù'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-90" 
        test="contains(.,'Âº')" 
        role="warning" 
        id="unicode-test-90"><name/> element contains 'Âº' - this should instead be the character 'º'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-91" 
        test="contains(.,'Ãº')" 
        role="warning" 
        id="unicode-test-91"><name/> element contains 'Ãº' - this should instead be the character 'ú'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-92" 
        test="contains(.,'Â¿')" 
        role="warning" 
        id="unicode-test-92"><name/> element contains 'Â¿' - this should instead be the character '¿'. - <value-of select="."/>.</report>

        <report see="https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#unicode-test-93" 
        test="contains(.,'Ã¿')" 
        role="warning" 
        id="unicode-test-93"><name/> element contains 'Ã¿' - this should instead be the character 'ÿ'. - <value-of select="."/>.</report>

        </rule>
    
  </pattern>
  
  <pattern id="element-allowlist-pattern">
    
    <rule context="article//*[not(ancestor::mml:math)]" id="element-allowlist">
      <let name="allowed-elements" value="('abstract', 'ack', 'addr-line', 'aff', 'ali:free_to_read', 'ali:license_ref', 'app', 'app-group', 'article', 'article-categories', 'article-id', 'article-meta', 'article-title', 'attrib', 'author-notes', 'award-group', 'award-id', 'back', 'bio', 'body', 'bold', 'boxed-text', 'break', 'caption', 'chapter-title', 'code', 'collab', 'comment', 'conf-date', 'conf-loc', 'conf-name', 'contrib', 'contrib-group', 'contrib-id', 'copyright-holder', 'copyright-statement', 'copyright-year', 'corresp', 'country', 'custom-meta', 'custom-meta-group', 'data-title', 'date', 'date-in-citation', 'day', 'disp-formula', 'disp-quote', 'edition', 'element-citation', 'elocation-id', 'email', 'ext-link', 'fig', 'fig-group', 'fn', 'fn-group', 'fpage', 'front', 'front-stub', 'funding-group', 'funding-source', 'funding-statement', 'given-names', 'graphic', 'history', 'inline-formula', 'inline-graphic', 'institution', 'institution-id', 'institution-wrap', 'issn', 'issue', 'italic', 'journal-id', 'journal-meta', 'journal-title', 'journal-title-group', 'kwd', 'kwd-group', 'label', 'license', 'license-p', 'list', 'list-item', 'lpage', 'media', 'meta-name', 'meta-value', 'mml:math', 'monospace', 'month', 'name', 'named-content', 'on-behalf-of', 'p', 'patent', 'permissions', 'person-group', 'principal-award-recipient', 'pub-date', 'pub-id', 'publisher', 'publisher-loc', 'publisher-name', 'ref', 'ref-list', 'related-article', 'related-object', 'role', 'sc', 'sec', 'self-uri', 'source', 'strike', 'string-date', 'string-name', 'styled-content', 'sub', 'sub-article', 'subj-group', 'subject', 'suffix', 'sup', 'supplementary-material', 'surname', 'table', 'table-wrap', 'table-wrap-foot', 'tbody', 'td', 'th', 'thead', 'title', 'title-group', 'tr', 'underline', 'version', 'volume', 'xref', 'year')"/>
      
      <assert test="name()=$allowed-elements" 
        role="error" 
        id="element-conformity"><value-of select="name()"/> element is not allowed.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="empty-attribute-pattern">
    
    <rule context="*[@*/normalize-space(.)='']" id="empty-attribute-test">
      
      <report test="." 
        role="warning" 
        id="pre-empty-attribute-conformance"><value-of select="name()"/> element has attribute(s) with an empty value. &lt;<value-of select="name()"/><value-of select="for $att in ./@*[normalize-space(.)=''] return concat(' ',$att/name(),'=&quot;',$att,'&quot;')"/>>. If this cannot be filled out yet (due to missing or incomplete information), please ensure that the authors are queried, as appropriate.</report>
      
      <report test="." 
        role="error" 
        id="final-empty-attribute-conformance"><value-of select="name()"/> element has attribute(s) with an empty value. &lt;<value-of select="name()"/><value-of select="for $att in ./@*[normalize-space(.)=''] return concat(' ',$att/name(),'=&quot;',$att,'&quot;')"/>></report>
      
    </rule>
  </pattern>
  
  <pattern id="final-package-pattern">
    
    <rule context="graphic[@xlink:href]|media[@xlink:href]|self-uri[@xlink:href]" id="final-package">
      <let name="article-id" value="ancestor::article/front//article-id[@pub-id-type='publisher-id']"/>
      <let name="base" value="base-uri(.)"/>
      <let name="base-path" value="substring-before(
        substring-after($base,'file:'),
        concat('elife-',$article-id,'.xml')
        )"/>
      
      <assert test="java:file-exists(@xlink:href, $base)" 
        role="error" 
        id="graphic-media-presence"><name/> element points to file <value-of select="@xlink:href"/> - but there is no file with that name in the same folder as the XML file. It should be placed here - <value-of select="$base-path"/></assert>
      
    </rule>
    
  </pattern>
  
</schema>