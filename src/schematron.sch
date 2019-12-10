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

	<ns uri="http://www.niso.org/schemas/ali/1.0/" prefix='ali' />
	<ns uri='http://www.w3.org/XML/1998/namespace' prefix='xml'/>
	<ns uri='http://www.w3.org/1999/xlink' prefix='xlink'/>
  <ns uri="http://www.w3.org/2001/XInclude" prefix="xi"/>
  <ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml" />
  <ns uri="http://saxon.sf.net/" prefix="saxon" />
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
  
  <let name="MSAs" value="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Human Biology and Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
  
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
          <xsl:when test="lower-case($token1)=('rna','dna')">
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
      <xsl:when test="matches($s,'^respfig[0-9]{1,3}$')">
        <xsl:value-of select="'Author response figure'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'undefined'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="e:stripDiacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="replace(replace(translate($string,'àáâãäåçčèéêěëęħìíîïłñňòóôõöőøřšśşùúûüýÿž','aaaaaacceeeeeehiiiilnnooooooorsssuuuuyyz'),'æ','ae'),'ß','ss')"/>
  </xsl:function>

  <xsl:function name="e:citation-format1">
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
      <xsl:otherwise><xsl:value-of select="'undetermined'"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="e:citation-format2">
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
      <xsl:otherwise><xsl:value-of select="'undetermined'"/></xsl:otherwise>
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
        <!-- Shouldn't occur in eLife content -->
        <xsl:value-of select="'No elements present'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="e:isbn-sum" as="xs:string">
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
  
  <!-- Global variable included here for convenience -->
  <let name="org-regex" value="'b\.\s?subtilis|bacillus\s?subtilis|d\.\s?melanogaster|drosophila\s?melanogaster|e\.\s?coli|escherichia\s?coli|s\.\s?pombe|schizosaccharomyces\s?pombe|s\.\s?cerevisiae|saccharomyces\s?cerevisiae|c\.\s?elegans|caenorhabditis\s?elegans|a\.\s?thaliana|arabidopsis\s?thaliana|m\.\s?thermophila|myceliophthora\s?thermophila|dictyostelium|p\.\s?falciparum|plasmodium\s?falciparum|s\.\s?enterica|salmonella\s?enterica|s\.\s?pyogenes|streptococcus\s?pyogenes|p\.\s?dumerilii|platynereis\s?dumerilii|p\.\s?cynocephalus|papio\s?cynocephalus|o\.\s?fasciatus|oncopeltus\s?fasciatus|n\.\s?crassa|neurospora\s?crassa|c\.\s?intestinalis|ciona\s?intestinalis|e\.\s?cuniculi|encephalitozoon\s?cuniculi|h\.\s?salinarum|halobacterium\s?salinarum|s\.\s?solfataricus|sulfolobus\s?solfataricus|s\.\s?mediterranea|schmidtea\s?mediterranea|s\.\s?rosetta|salpingoeca\s?rosetta|n\.\s?vectensis|nematostella\s?vectensis|s\.\s?aureus|staphylococcus\s?aureus|a\.\s?thaliana|arabidopsis\s?thaliana|v\.\s?cholerae|vibrio\s?cholerae|t\.\s?thermophila|tetrahymena\s?thermophila|c\.\s?reinhardtii|chlamydomonas\s?reinhardtii|n\.\s?attenuata|nicotiana\s?attenuata|e\.\s?carotovora|erwinia\s?carotovora|h\.\s?sapiens|homo\s?sapiens|e\.\s?faecalis|enterococcus\s?faecalis|c\.\s?trachomatis|chlamydia\s?trachomatis|x\.\s?laevis|xenopus\s?laevis|x\.\s?tropicalis|xenopus\s?tropicalis|m\.\s?musculus|mus\s?musculus|d\.\s?immigrans|drosophila\s?immigrans|d\.\s?subobscura|drosophila\s?subobscura|d\.\s?affinis|drosophila\s?affinis|d\.\s?obscura|drosophila\s?obscura|f\.\s?tularensis|francisella\s?tularensis|p\.\s?plantaginis|podosphaera\s?plantaginis|p\.\s?plantaginis|plantago\s?lanceolata|d\.\s?rerio|danio\s?rerio|drosophila|xenopus'"/>
  
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
      <xsl:if test="matches($s,'[Gg]ithub')">
        <xsl:element name="match">
        <xsl:value-of select="'github '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="matches($s,'[Gg]itlab')">
        <xsl:element name="match">
        <xsl:value-of select="'gitlab '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="matches($s,'[Cc]ode[Pp]lex')">
        <xsl:element name="match">
        <xsl:value-of select="'codeplex '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="matches($s,'[Ss]ource[Ff]orge')">
        <xsl:element name="match">
        <xsl:value-of select="'sourceforge '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="matches($s,'[Bb]it[Bb]ucket')">
        <xsl:element name="match">
        <xsl:value-of select="'bitbucket '"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="matches($s,'[Aa]ssembla ')">
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
          <xsl:when test="($rid-no lt $object-no) and (./following-sibling::text()[1] = '&#x2014;') and (./following-sibling::*[1]/name()='xref') and (replace(replace(./following-sibling::xref[1]/@rid,'\-','.'),'[a-z]','') gt $object-no)">
            <xsl:element name="match">
              <xsl:attribute name="sec-id">
                <xsl:value-of select="./ancestor::sec[1]/@id"/>
              </xsl:attribute>
              <xsl:value-of select="self::*"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="($rid-no lt $object-no) and contains(.,$object-no) and (contains(.,'Videos') or contains(.,'videos') and contains(.,'&#x2014;'))">
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
 
  <!-- Taken from here https://stackoverflow.com/questions/2917655/how-do-i-check-for-the-existence-of-an-external-file-with-xsl -->
  <xsl:function name="java:file-exists" xmlns:file="java.io.File" as="xs:boolean">
    <xsl:param name="file" as="xs:string"/>
    <xsl:param name="base-uri" as="xs:string"/>
    
    <xsl:variable name="absolute-uri" select="resolve-uri($file, $base-uri)" as="xs:anyURI"/>
    <xsl:sequence select="file:exists(file:new($absolute-uri))"/>
  </xsl:function>
  
 <pattern
 	id="article">
 
    <rule context="article" id="article-tests">
      
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
		
 	</rule>
	
	<rule context="article[@article-type='research-article']" id="research-article">
	  <let name="disp-channel" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject"/> 
	
	  <report test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])"
        role="warning" 
        id="pre-test-r-article-d-letter">A decision letter should be present for research articles.</report>
	  
	  <report test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])"
	    role="error" 
	    id="final-test-r-article-d-letter">A decision letter must be present for research articles.</report>
		
	  <report test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='reply'])"
        role="warning" 
        id="test-r-article-a-reply">Author response should usually be present for research articles, but this one does not have one. Is that correct?</report>
	
	</rule>
 </pattern>

  <pattern
     id="front"> 
	 
	 <rule context="article/front" id="test-front">
	 
  	  <assert test="count(journal-meta) = 1"
          role="error" 
          id="test-front-jmeta">There must be one journal-meta that is a child of front. Currently there are <value-of select="count(journal-meta)"/></assert>
		  
  	  <assert test="count(article-meta) = 1"
          role="error" 
          id="test-front-ameta">There must be one article-meta that is a child of front. Currently there are <value-of select="count(article-meta)"/></assert>
	 
	 </rule>
  </pattern>

  <pattern
     id="journal-meta">
	 
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

  <pattern
     id="article-metadata">         
			 
  <rule context="article/front/article-meta" id="test-article-metadata">
    <let name="article-id" value="article-id[@pub-id-type='publisher-id']"/>
    <let name="article-type" value="ancestor::article/@article-type"/>
    <let name="subj-type" value="descendant::subj-group[@subj-group-type='display-channel']/subject"/>
    <let name="exceptions" value="('Insight','Retraction','Correction')"/>
    <let name="no-digest" value="('Scientific Correspondence','Replication Study','Research Advance','Registered Report','Correction','Retraction',$features-subj)"/>
    
	<assert test="matches($article-id,'^\d{5}$')"
      role="error" 
      id="test-article-id">article-id must consist only of 5 digits. Currently it is <value-of select="article-id[@pub-id-type='publisher-id']"/></assert> 
	 
	 <assert test="starts-with(article-id[@pub-id-type='doi'],'10.7554/eLife.')"
	   role="error" 
	   id="test-article-doi-1">Article level DOI must start with '10.7554/eLife.'. Currently it is <value-of select="article-id[@pub-id-type='doi']"/></assert>
	   
  	 <assert test="substring-after(article-id[@pub-id-type='doi'],'10.7554/eLife.') = $article-id"
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
		
    <assert test="matches(volume,'^[0-9]*$')"
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
		  
    <assert test="count(permissions) = 1"
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
	 
   <rule context="article-meta/article-categories" id="test-article-categories">
	 <let name="article-type" value="ancestor::article/@article-type"/>
   <let name="template" value="parent::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value"/>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']) = 1"
       role="error" 
       id="disp-subj-test">There must be one subj-group[@subj-group-type='display-channel'] which is a child of article-categories. Currently there are <value-of select="count(article-categories/subj-group[@subj-group-type='display-channel'])"/>.</assert>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']/subject) = 1"
       role="error" 
       id="disp-subj-test2">subj-group[@subj-group-type='display-channel'] must contain only one subject. Currently there are <value-of select="count(subj-group[@subj-group-type='display-channel']/subject)"/>.</assert>
    
     <report test="count(subj-group[@subj-group-type='heading']) gt 2"
       role="error" 
       id="head-subj-test1">article-categories must contain one and or two subj-group[@subj-group-type='heading'] elements. Currently there are <value-of select="count(subj-group[@subj-group-type='heading']/subject)"/>.</report>
	   
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
    
    <rule context="article-categories/subj-group[@subj-group-type='display-channel']/subject" 
      id="disp-channel-checks">
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
    
    <rule context="article-categories/subj-group[@subj-group-type='heading']/subject" 
      id="MSA-checks">
      
      <assert test=". = $MSAs"
        role="error" 
        id="head-subj-MSA-test">Content of the heading must match one of the MSAs.</assert>
    </rule>
    
    <rule context="article-categories/subj-group[@subj-group-type='heading']" 
      id="head-subj-checks">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert test="count(subject) le 3"
        role="error" 
        id="head-subj-test-1">There cannot be more than two MSAs.</assert>
      
      <report test="if ($article-type = 'editorial') then ()
        else count(subject) = 0"
        role="error" 
        id="head-subj-test-2">There must be at least one MSA.</report>
    </rule>
	
	<rule context="article/front/article-meta/title-group" 
		id="test-title-group">
	  <let name="subj-type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject"/>
	  <let name="lc" value="normalize-space(lower-case(article-title))"/>
	  <let name="title" value="replace(article-title,'\p{P}','')"/>
	  <let name="body" value="ancestor::front/following-sibling::body"/>
	  <let name="tokens" value="string-join(for $x in tokenize($title,' ')[position() > 1] return 
	    if (matches($x,'^[A-Z]') and matches($body,concat(' ',lower-case($x),' '))) then $x
	    else (),', ')"/>
	
    <report test="ends-with(replace(article-title,'\p{Z}',''),'.')"
      role="error" 
      id="article-title-test-1">Article title must not end with a full stop.</report>  
   
    <report test="article-title[text() != ''] = lower-case(article-title)"
      role="error" 
      id="article-title-test-2">Article title must not be entirely in lower case.</report>
   
    <report test="article-title[text() != ''] = upper-case(article-title)"
      role="error" 
      id="article-title-test-3">Article title must not be entirely in upper case.</report>
	  
	  <report test="not(article-title/*) and normalize-space(article-title)=''"
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
	  
	  <report test="matches(article-title,'-Based ')"
	    role="error" 
	    id="article-title-test-9">Article title contains the string '-Based '. this should be lower-case, '-based '.  - <value-of select="article-title"/></report>
	  
	  <report test="($subj-type = ('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Research Communication', 'Feature article', 'Insight', 'Editorial', 'Scientific Correspondence')) and matches(article-title,':')"
	    role="warning" 
	    id="article-title-test-10">Article title contains a colon. This almost never allowed. - <value-of select="article-title"/></report>
	  
	  <report test="($subj-type!='Correction') and ($subj-type!='Retraction') and ($subj-type!='Scientific Correspondence') and matches($tokens,'[A-Za-z]')"
	    role="warning" 
	    id="article-title-test-11">Article title contains a capitalised word(s) which is not capitalised in the body of the article - <value-of select="$tokens"/> - is this correct? - <value-of select="article-title"/></report>
	  
	  <report test="matches(article-title,' [Bb]ased ') and not(matches(article-title,' [Bb]ased on '))"
	    role="warning" 
	    id="article-title-test-12">Article title contains the string ' based'. Should the preceding space be replaced by a hyphen - '-based'.  - <value-of select="article-title"/></report>
	
	</rule>
	
	<rule context="article/front/article-meta/contrib-group" 
		id="test-contrib-group">
		
    <assert test="contrib"
          role="error" 
          id="contrib-presence-test">contrib-group must contain at least one contrib.</assert>
		  
    <report test="count(contrib[@equal-contrib='yes']) = 1"
        	role="error" 
        	id="equal-count-test">There is one contrib with the attribute equal-contrib='yes'.This cannot be correct. Either 2 or more contribs within the same contrib-group should have this attribute, or none. Check <value-of select="contrib[@equal-contrib='yes']/name"/></report>
	
	</rule>
    
    <rule context="article/front/article-meta/contrib-group[@content-type='section']" 
      id="test-editor-contrib-group">
      
      <assert test="count(contrib[@contrib-type='senior_editor']) = 1"
        role="error" 
        id="editor-conformance-1">contrib-group[@content-type='section'] must contain one (and only 1) Senior Editor (contrib[@contrib-type='senior_editor']).</assert>
      
      <assert test="count(contrib[@contrib-type='editor']) = 1"
        role="error" 
        id="editor-conformance-2">contrib-group[@content-type='section'] must contain one (and only 1) Reviewing Editor (contrib[@contrib-type='editor']).</assert>
      
    </rule>
    
    <rule context="article/front/article-meta/contrib-group[@content-type='section']/contrib" 
      id="test-editors-contrib">
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role"/>
      
      <report test="(@contrib-type='senior_editor') and ($role!='Senior Editor')"
        role="error" 
        id="editor-conformance-3"><value-of select="$name"/> has a @contrib-type='senior_editor' but their role is not 'Senior Editor' (<value-of select="$role"/>), which is incorrect.</report>
      
      <report test="(@contrib-type='editor') and ($role!='Reviewing Editor')"
        role="error" 
        id="editor-conformance-4"><value-of select="$name"/> has a @contrib-type='editor_editor' but their role is not 'Reviewing Editor' (<value-of select="$role"/>), which is incorrect.</report>
      
    </rule>
	
	<rule context="article-meta/contrib-group//name" 
		id="name-tests">
		
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
	  
	  <rule context="article-meta/contrib-group//name/surname" 
	    id="surname-tests">
		
	  <report test="not(*) and (normalize-space(.)='')"
      	role="error" 
      	id="surname-test-2">surname must not be empty.</report>
		
    <report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc"
      	role="error" 
      	id="surname-test-3">surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	   <assert test="matches(.,&quot;^[\p{L}\p{M}\s'-]*$&quot;)"
      	role="warning" 
      	id="surname-test-4">surname should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
		
	  <assert test="matches(.,'^\p{Lu}')"
      	role="warning" 
      	id="surname-test-5">surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</assert>
	  
	  <report test="matches(.,'^\s')"
	    role="error" 
	    id="surname-test-6">surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
	  
	  <report test="matches(.,'\s$')"
	    role="error" 
	    id="surname-test-7">surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
		
	  </rule>
    
    <rule context="article-meta/contrib-group//name/given-names" 
      id="given-names-tests">
		
	  <report test="not(*) and (normalize-space(.)='')"
      	role="error" 
      	id="given-names-test-3">given-names must not be empty.</report>
		
    	<report test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc"
      	role="error" 
      	id="given-names-test-4">given-names must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript) - '<value-of select="."/>'.</report>
		
      <assert test="matches(.,&quot;^[\p{L}\p{M}\s'-]*$&quot;)"
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
		
	</rule>
    
    <rule context="article-meta/contrib-group//name/suffix" 
      id="suffix-tests">
      
      <assert test=".=('Jnr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')"
        role="error" 
        id="suffix-assert">suffix can only have one of these values - 'Jnr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'.</assert>
      
      <report test="*"
        role="error" 
        id="suffix-child-test">suffix cannot have any child elements - <value-of select="*/local-name()"/></report>
      
    </rule>
    
    <rule context="article-meta/contrib-group//name/*" 
      id="name-child-tests">
      
      <assert test="local-name() = ('surname','given-names','suffix')"
        role="error" 
        id="disallowed-child-assert"><value-of select="local-name()"/> is not allowed as a child of name.</assert>
      
    </rule>
	
	<rule context="article-meta//contrib" 
		id="contrib-tests">
	  <let name="type" value="@contrib-type"/>
	  <let name="subj-type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject"/>
	  <let name="aff-rid1" value="xref[@ref-type='aff'][1]/@rid"/>
	  <let name="inst1" value="ancestor::contrib-group//aff[@id = $aff-rid1]/institution[not(@content-type)]"/>
	  <let name="aff-rid2" value="xref[@ref-type='aff'][2]/@rid"/>
	  <let name="inst2" value="ancestor::contrib-group//aff[@id = $aff-rid2]/institution[not(@content-type)]"/>
	  <let name="aff-rid3" value="xref[@ref-type='aff'][3]/@rid"/>
	  <let name="inst3" value="ancestor::contrib-group//aff[@id = $aff-rid3]/institution[not(@content-type)]"/>
	  <let name="aff-rid4" value="xref[@ref-type='aff'][4]/@rid"/>
	  <let name="inst4" value="ancestor::contrib-group//aff[@id = $aff-rid4]/institution[not(@content-type)]"/>
	  <let name="aff-rid5" value="xref[@ref-type='aff'][5]/@rid"/>
	  <let name="inst5" value="ancestor::contrib-group//aff[@id = $aff-rid5]/institution[not(@content-type)]"/>
	  <let name="inst" value="concat($inst1,'*',$inst2,'*',$inst3,'*',$inst4,'*',$inst5)"/>
	  <let name="coi-rid" value="xref[starts-with(@rid,'conf')]/@rid"/>
	  <let name="coi" value="ancestor::article//fn[@id = $coi-rid]/p"/>
	  <let name="comp-regex" value="' [Ii]nc[.]?| LLC| Ltd| [Ll]imited| [Cc]ompanies| [Cc]ompany| [Cc]o\.| Pharmaceutical[s]| [Pp][Ll][Cc]|AstraZeneca|Pfizer| R&amp;D'"/>
	  <let name="fn-rid" value="xref[starts-with(@rid,'fn')]/@rid"/>
	  <let name="fn" value="string-join(ancestor::article-meta//author-notes/fn[@id = $fn-rid]/p,'')"/>
	  <let name="name" value="if (child::collab[1]) then collab else if (child::name[1]) then e:get-name(child::name[1]) else ()"/>
		
		<!-- Subject to change depending of the affiliation markup of group authors and editors. Currently fires for individual group contributors and editors who do not have either a child aff or a child xref pointing to an aff.  -->
    	<report test="if ($subj-type = ('Retraction','Correction')) then ()
    	  else if (collab) then ()
    	  else if (ancestor::collab) then (count(xref[@ref-type='aff']) + count(aff) = 0)
    	  else if ($type != 'author') then ()
    	  else count(xref[@ref-type='aff']) = 0"
      	role="error" 
      	id="contrib-test-1">author contrib should contain at least 1 xref[@ref-type='aff'].</report>
	  
	  <report test="(($type != 'author') or not(@contrib-type)) and (count(xref[@ref-type='aff']) + count(aff) = 0)"
	     role="warning" 
	     id="contrib-test-2">non-author contrib doesn't have an affiliation - <value-of select="$name"/> - is this correct?</report>
	  
	     <report test="name and collab"
	       role="error" 
	       id="contrib-test-3">author contains both a child name and a child collab. This is not correct.</report>
	  
	     <report test="if (collab) then ()
	       else count(name) != 1"
	       role="error" 
	       id="name-test">Contrib contains no collab but has more than one name. This is not correct.</report>
	  
	     <report test="self::*[@corresp='yes'][not(child::*:email)]"
	       role="error" 
	       id="contrib-email-1">Corresponding authors must have an email.</report>
	  
	  <report test="not(@corresp='yes') and (not(ancestor::collab/parent::contrib[@corresp='yes'])) and (child::email)"
	       role="error" 
	       id="contrib-email-2">Non-corresponding authors must not have an email.</report>
	  
	  <report test="(@contrib-type='author') and ($coi = 'No competing interests declared') and (matches($inst,$comp-regex))"
	       role="warning" 
	       id="COI-test"><value-of select="$name"/> is affiliated with what looks like a company, but contains no COI statement. Is this correct?</report>
	  
	  <report test="matches($fn,'[Dd]eceased') and not(@deceased='yes')"
	    role="error" 
	    id="deceased-test-1"><value-of select="$name"/> has a linked footnote '<value-of select="$fn"/>', but not @deceased="yes" which is incorrect.</report>
	  
	  <report test="(@deceased='yes') and not(matches($fn,'[Dd]eceased'))"
	    role="error" 
	    id="deceased-test-2"><value-of select="$name"/> has the attribute deceased="yes", but no footnote which contains the text 'Deceased', which is incorrect.</report>
		
		</rule>
		
		<rule context="article-meta//contrib[@contrib-type='author']/*" 
			id="author-children-tests">
		  <let name="article-type" value="ancestor::article/@article-type"/> 
		  <let name="template" value="ancestor::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value"/>
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

	<rule context="contrib-id[@contrib-id-type='orcid']" 
		id="orcid-tests">
		
    	<assert test="@authenticated='true'"
      	role="error" 
      	id="orcid-test-1">contrib-id[@contrib-id-type="orcid"] must have an @authenticated="true"</assert>
		
		<!-- Needs updating to only allow https when this is implemented -->
	  <assert test="matches(.,'^http[s]?://orcid.org/[\d]{4}-[\d]{4}-[\d]{4}-[\d]{3}[0-9X]$')"
      	role="error" 
      	id="orcid-test-2">contrib-id[@contrib-id-type="orcid"] must contain a valid ORCID URL in the format 'https://orcid.org/0000-0000-0000-0000'</assert>
		
		</rule>
	
	<rule context="article-meta//email" 
		id="email-tests">
		
    	<assert test="matches(upper-case(.),'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$')"
      	role="error" 
      	id="email-test">email element must contain a valid email address. Currently it is <value-of select="self::*"/>.</assert>
		
	</rule>
	
	<rule context="article-meta/history" 
		id="history-tests">
		
    	<assert test="date[@date-type='received']"
      	role="error" 
      	id="history-date-test-1">history must contain date[@date-type='received']</assert>
		
    	<assert test="date[@date-type='accepted']"
      	role="error" 
      	id="history-date-test-2">history must contain date[@date-type='accepted']</assert>
	
	
	</rule>
	
	<rule context="date" 
		id="date-tests">
	  
	  <assert test="matches(day,'^[0-9]{2}$')"
	    role="error" 
	    id="date-test-1">date must contain day in the format 00. Currently it is '<value-of select="day"/>'.</assert>
	  
	  <assert test="matches(month,'^[0-9]{2}$')"
	    role="error" 
	    id="date-test-2">date must contain month in the format 00. Currently it is '<value-of select="month"/>'.</assert>
	  
	  <assert test="matches(year,'^[0-9]{4}$')"
	    role="error" 
	    id="date-test-3">date must contain year in the format 0000. Currently it is Currently it is '<value-of select="year"/>'.</assert>
		
    	<assert test="@iso-8601-date = concat(year,'-',month,'-',day)"
      	role="error" 
      	id="date-test-4">date must have an @iso-8601-date the value of which must be the values of the year-month-day elements. Currently it is <value-of select="@iso-8601-date"/>, when it should be <value-of select="concat(year,'-',month,'-',day)"/>.</assert>
	
	</rule>
    
    <rule context="day[not(parent::string-date)]" 
      id="day-tests">
      
      <assert test="matches(.,'^[0][1-9]$|^[1-2][0-9]$|^[3][0-1]$')"
        role="error" 
        id="day-conformity">day must contain 2 digits which are between '01' and '31' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule>
    
    <rule context="month[not(parent::string-date)]" 
      id="month-tests">
      
      <assert test="matches(.,'^[0][1-9]$|^[1][0-2]$')"
        role="error" 
        id="month-conformity">month must contain 2 digits which are between '01' and '12' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule>
    
    <rule context="year[ancestor::article-meta]" 
      id="year-article-meta-tests">
      
      <assert test="matches(.,'^[2]0[0-2][0-9]$')"
        role="error" 
        id="year-article-meta-conformity">year in article-meta must contain 4 digits which match the regular expression '^[2]0[0-2][0-9]$' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule>
    
    <rule context="year[ancestor::element-citation]" 
      id="year-element-citation-tests">
      
      <assert test="matches(.,'^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$')"
        role="error" 
        id="year-element-citation-conformity">year in reference must contain content which matches the regular expression '^[1][6-9][0-9][0-9][a-z]?$|^[2]0[0-2][0-9][a-z]?$' - '<value-of select="."/>' doesn't meet this requirement.</assert>
      
    </rule>
    
    <rule context="pub-date[not(@pub-type='collection')]" 
      id="pub-date-tests-1">
      
      <assert test="matches(day,'^[0-9]{2}$')"
        role="warning" 
        id="pre-pub-date-test-1">day is not present in pub-date.</assert>
      
      <assert test="matches(day,'^[0-9]{2}$')"
        role="error" 
        id="final-pub-date-test-1">pub-date must contain day in the format 00. Currently it is '<value-of select="day"/>'.</assert>
      
      <assert test="matches(month,'^[0-9]{2}$')"
        role="warning" 
        id="pre-pub-date-test-2">month is not present in pub-date.</assert>
      
      <assert test="matches(month,'^[0-9]{2}$')"
        role="error" 
        id="final-pub-date-test-2">pub-date must contain month in the format 00. Currently it is '<value-of select="month"/>'.</assert>
      
      <assert test="matches(year,'^[0-9]{4}$')"
        role="error" 
        id="pub-date-test-3">pub-date must contain year in the format 0000. Currently it is '<value-of select="year"/>'.</assert>
      
    </rule>
    
    <rule context="pub-date[@pub-type='collection']" 
      id="pub-date-tests-2">
      
      <assert test="matches(year,'^[0-9]{4}$')"
        role="error" 
        id="pub-date-test-4">date must contain year in the format 0000. Currently it is '<value-of select="year"/>'.</assert>
      
      <report test="*/local-name() != 'year'"
        role="error" 
        id="pub-date-test-5">pub-date[@pub-type='collection'] can only contain a year element.</report>
      
      <assert test="year = parent::*/pub-date[@publication-format='electronic'][@date-type='publication']/year"
        role="error" 
        id="pub-date-test-6">pub-date[@pub-type='collection'] year must be the same as pub-date[@publication-format='electronic'][@date-type='publication'] year.</assert>
      
    </rule>
	
	<rule context="front//permissions" 
		id="front-permissions-tests">
	<let name="author-count" value="count(ancestor::article-meta//contrib[@contrib-type='author'])"/>
	  <let name="license-type" value="license/@xlink:href"/>
	
	  <report test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then () 
	    else not(copyright-statement)"
  	role="error" 
  	id="permissions-test-1">permissions must contain copyright-statement.</report>
	
	  <report test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then () 
	    else not(matches(copyright-year,'^[0-9]{4}$'))"
  	role="error" 
  	id="permissions-test-2">permissions must contain copyright-year in the format 0000. Currently it is <value-of select="copyright-year"/></report>
	
	  <report test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then () 
	    else not(copyright-holder)"
  	role="error" 
  	id="permissions-test-3">permissions must contain copyright-holder.</report>
	
	<assert test="ali:free_to_read"
  	role="error" 
  	id="permissions-test-4">permissions must contain an ali:free_to_read element.</assert>
	
	<assert test="license"
  	role="error" 
  	id="permissions-test-5">permissions must contain license.</assert>
	
	  <report test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then () 
	    else not(copyright-year = ancestor::article-meta/pub-date[@publication-format='electronic'][@date-type='publication']/year)"
  	role="error" 
  	id="permissions-test-6">copyright-year must match the contents of the year in the pub-date[@publication-format='electronic'][@date-type='publication']. Currently, copyright-year=<value-of select="copyright-year"/> and pub-date=<value-of select="ancestor::article-meta/pub-date[@publication-format='electronic'][@date-type='publication']/year"/>.</report>
	
	  <report test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then () 
	    else if ($author-count = 1) then copyright-holder != ancestor::article-meta//contrib[@contrib-type='author']//surname
	    else if ($author-count = 2) then copyright-holder != concat(ancestor::article-meta/descendant::contrib[@contrib-type='author'][1]//surname,' and ',ancestor::article-meta/descendant::contrib[@contrib-type='author'][2]//surname)
	else copyright-holder != concat(ancestor::article-meta/descendant::contrib[@contrib-type='author'][1]//surname,' et al')"
  	role="error" 
  	id="permissions-test-7">copyright-holder is incorrect. If the article has one author then it should be their surname. If it has two authors it should be the surname of the first, then ' and ' and then the surname of the second. If three or more, it should be the surname of the first, and then ' et al'. Currently it's <value-of select="copyright-holder"/></report>
	
	  <report test="if (contains($license-type,'creativecommons.org/publicdomain/zero')) then () 
	    else not(copyright-statement = concat('&#x00A9; ',copyright-year,', ',copyright-holder))"
  	role="error" 
  	id="permissions-test-8">copyright-statement must contain a concatenation of '&#x00A9; ', copyright-year, and copyright-holder. Currently it is <value-of select="copyright-statement"/> when according to the other values it should be <value-of select="concat('&#x00A9; ',copyright-year,', ',copyright-holder)"/></report>
	  
	  <assert test="($license-type = 'http://creativecommons.org/publicdomain/zero/1.0/') or ($license-type = 'http://creativecommons.org/licenses/by/4.0/')"
	    role="error" 
	    id="permissions-test-9">license does not have an @xlink:href which is equal to 'http://creativecommons.org/publicdomain/zero/1.0/' or 'http://creativecommons.org/licenses/by/4.0/'.</assert>
	
	</rule>
	
	<rule context="front//permissions/license" 
		id="license-tests">
	
	<assert test="ali:license_ref"
  	role="error" 
  	id="license-test-1">license must contain ali:license_ref.</assert>
	
	<assert test="count(license-p) = 1"
  	role="error" 
  	id="license-test-2">license must contain one and only one license-p.</assert>
	
	</rule>
	
	<!-- Test needs to be added for clinical trials, which mandates the correct number of secs. This number needs confirming -->
	<rule context="front//abstract" 
		id="abstract-tests">
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
		
    </rule>
    
    <rule context="front//abstract/*" 
      id="abstract-children-tests">
      <let name="allowed-elems" value="('p','sec','title')"/>
      
      <assert test="local-name() = $allowed-elems"
        role="error" 
        id="abstract-child-test-1"><name/> is not allowed as a child of abstract.</assert>
    </rule>
    
    <rule context="abstract[not(@abstract-type)]/sec" 
      id="abstract-sec-titles">
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
    
    <rule context="abstract[not(@abstract-type)]/sec/related-object" 
      id="clintrial-related-object">
      
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
      
    </rule>
	
    <rule context="article-meta/contrib-group/aff" 
      id="aff-tests">
      
    <assert test="parent::contrib-group//contrib//xref/@rid = @id"
      role="error"
      id="aff-test-1">aff elements that are direct children of contrib-group must have an xref in that contrib-group pointing to them.</assert>
    </rule>
    
	<rule context="article-meta/funding-group" 
		id="funding-group-tests">
		
		<assert test="count(funding-statement) = 1"
	  	role="error" 
	  	id="funding-group-test-1">One funding-statement should be present in funding-group.</assert>
		
		<report test="count(award-group) = 0"
	  	role="warning" 
	  	id="funding-group-test-2">funding-group contains no award-groups. Is this correct? Please check with eLife staff.</report>
		
	  <report test="(count(award-group) = 0) and (funding-statement!='No external funding was received for this work.')"
	  	role="warning" 
	  	id="funding-group-test-3">Is funding-statement this correct? Please check with eLife staff. Usually it should be 'The author[s] declare[s] that there was no funding for this work.'</report>
		
		
    </rule>
	
	<rule context="funding-group/award-group" 
		id="award-group-tests">
	  <let name="id" value="@id"/>
		
		<assert test="funding-source"
  		role="error" 
  		id="award-group-test-2">award-group must contain a funding-source.</assert>
		
		<assert test="principal-award-recipient"
  		role="error" 
  		id="award-group-test-3">award-group must contain a principal-award-recipient.</assert>
		
		<report test="count(award-id) gt 1"
  		role="error" 
  		id="award-group-test-4">award-group may contain one and only one award-id.</report>
		
		<assert test="funding-source/institution-wrap"
  		role="error"
  		id="award-group-test-5">funding-source must contain an institution-wrap.</assert>
		
		<assert test="count(funding-source/institution-wrap/institution) = 1"
  		role="error"
  		id="award-group-test-6">One and only one institution must be present.</assert>
	  
	  <assert test="ancestor::article//article-meta//contrib//xref/@rid = $id"
	    role="error"
	    id="award-group-test-7">There is no xref from a contrib pointing to this award-group. This is incorrect.</assert>
	</rule>
    
    <rule context="funding-group/award-group/award-id" 
      id="award-id-tests">
      <let name="id" value="parent::award-group/@id"/>
      
      <report test="matches(.,',|;')"
        role="warning"
        id="award-id-test-1">Funding entry with id <value-of select="$id"/> has a comma or semi-colon in the award id. Should this be separated out into several funding entries? - <value-of select="."/></report>
      
      <report test="matches(.,'^\s?[Nn][/]?[\.]?[Aa][.]?\s?$')"
        role="error"
        id="award-id-test-2">Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
      <report test="matches(.,'^\s?[Nn]one[\.]?\s?$')"
        role="error"
        id="award-id-test-3">Award id contains - <value-of select="."/> - This entry should be empty.</report>
      
    </rule>
    
    <rule context="article-meta//award-group//institution-wrap" 
      id="institution-wrap-tests">
      
      <assert test="institution-id[@institution-id-type='FundRef']"
        role="warning"
        id="institution-id-test">Whenever possible, institution-id[@institution-id-type="FundRef"] should be present in institution-wrap; warn staff if not</assert>
      
    </rule>
    
    <rule context="article-meta/kwd-group[not(@kwd-group-type='research-organism')]" 
      id="kwd-group-tests">
      
      <assert test="@kwd-group-type='author-keywords'"
        role="error"
        id="kwd-group-type">kwd-group must have a @kwd-group-type 'research-organism', or 'author-keywords'.</assert>
      
      <assert test="kwd"
        role="warning"
        id="non-ro-kwd-presence-test">kwd-group must contain at least one kwd</assert>
    </rule>
    
    <rule context="article-meta/kwd-group[@kwd-group-type='research-organism']" 
	    id="ro-kwd-group-tests">
      <let name="subj" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject"/>
	  
      <assert test="title = 'Research organism'"
	    role="error"
	    id="kwd-group-title">kwd-group title is <value-of select="title"/>, which is wrong. It should be 'Research organism'.</assert>
      
      <assert test="kwd"
        role="warning"
        id="ro-kwd-presence-test">kwd-group must contain at least one kwd</assert>
	
	</rule>
    
    <rule context="article-meta/kwd-group[@kwd-group-type='research-organism']/kwd" 
      id="ro-kwd-tests">
      
      <assert test="substring(.,1,1) = upper-case(substring(.,1,1))"
        role="error"
        id="kwd-upper-case">research-organism kwd elements should start with an upper-case letter.</assert>
      
      <report test="*[local-name() != 'italic']"
        role="error"
        id="kwd-child-test">research-organism keywords cannot have child elements such as <value-of select="*/local-name()"/>.</report>
      
    </rule>
    
    <rule context="article-meta/custom-meta-group" 
      id="custom-meta-group-tests">
      <let name="type" value="parent::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject"/>
      
      <report test="($type = $research-subj) and count(custom-meta[@specific-use='meta-only']) != 1"
        role="error"
        id="custom-meta-presence">1 and only 1 custom-meta[@specific-use='meta-only'] must be present in custom-meta-group for <value-of select="$type"/>.</report>
      
      <report test="($type = $features-subj) and count(custom-meta[@specific-use='meta-only']) != 2"
        role="error"
        id="features-custom-meta-presence">2 custom-meta[@specific-use='meta-only'] must be present in custom-meta-group for <value-of select="$type"/>.</report>
      
    </rule>
    
    <rule context="article-meta/custom-meta-group/custom-meta" 
      id="custom-meta-tests">
      <let name="type" value="ancestor::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject"/>
      <let name="pos" value="count(parent::custom-meta-group/custom-meta) - count(following-sibling::custom-meta)"/>
      
      <assert test="count(meta-name) = 1"
        role="error"
        id="custom-meta-test-1">One meta-name must be present in custom-meta.</assert>
      
      <report test="($type = $research-subj) and (meta-name != 'Author impact statement')"
        role="error"
        id="custom-meta-test-2">The value of meta-name can only be 'Author impact statement'. Currently it is <value-of select="meta-name"/>.</report>
      
      <assert test="count(meta-value) = 1"
        role="error"
        id="custom-meta-test-3">One meta-value must be present in custom-meta.</assert>
      
      <report test="($type = $features-subj) and ($pos=1) and  (meta-name != 'Author impact statement')"
        role="error"
        id="custom-meta-test-14">The value of the 1st meta-name can only be 'Author impact statement'. Currently it is <value-of select="meta-name"/>.</report>
      
      <report test="($type = $features-subj) and ($pos=2) and  (meta-name != 'Template')"
        role="error"
        id="custom-meta-test-15">The value of the 2nd meta-name can only be 'Template'. Currently it is <value-of select="meta-name"/>.</report>
      
    </rule>
      
    <rule context="article-meta/custom-meta-group/custom-meta[meta-name='Author impact statement']/meta-value" 
      id="meta-value-tests">
      <let name="subj" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject"/>
      <let name="count" value="count(for $x in tokenize(normalize-space(replace(.,'\p{P}','')),' ') return $x)"/>
      <report test="not(child::*) and normalize-space(.)=''"
        role="error"
        id="custom-meta-test-4">The value of meta-value cannot be empty</report>
      
      <report test="($count gt 30)"
        role="warning"
        id="pre-custom-meta-test-5">Impact statement contains more than 30 words. This is not allowed - please alert eLife staff.</report>
      
      <report test="($count gt 30) and ($subj = $features-subj)"
        role="warning"
        id="final-feature-custom-meta-test-5">Impact statement contains more than 30 words. Is this OK?</report>
      
      <report test="($count gt 30) and ($subj = $research-subj)"
        role="error"
        id="final-custom-meta-test-5">Impact statement contains more than 30 words. This is not allowed.</report>
      
      <assert test="matches(.,'[\.|\?]$')"
        role="warning"
        id="pre-custom-meta-test-6">Impact statement should end with a full stop or question mark - please alert eLife staff.</assert>
      
      <assert test="matches(.,'[\.|\?]$')"
        role="error"
        id="final-custom-meta-test-6">Impact statement must end with a full stop or question mark.</assert>
      
      <report test="matches(replace(.,' et al\. ',' et al '),'[\p{L}][\p{L}]+\. .*$|[\p{L}\p{N}][\p{L}\p{N}]+\? .*$|[\p{L}\p{N}][\p{L}\p{N}]+! .*$')"
        role="warning"
        id="custom-meta-test-7">Impact statement appears to be made up of more than one sentence. Please check, as more than one sentence is not allowed.</report>
      
      <report test="not($subj = 'Replication Study') and matches(.,'[:;]')"
        role="warning"
        id="custom-meta-test-8">Impact statement contains a colon or semi-colon, which is likely incorrect. It needs to be a proper sentence.</report>
      
      <report test="matches(.,'[Ww]e show|[Tt]his study|[Tt]his paper')"
        role="warning"
        id="pre-custom-meta-test-9">Impact statement contains a possesive phrase. This is not allowed</report>
      
      <report test="matches(.,'[Ww]e show|[Tt]his study|[Tt]his paper')"
        role="error"
        id="final-custom-meta-test-9">Impact statement contains a possesive phrase. This is not allowed</report>
      
      <report test="matches(.,'^[\d]+$')"
        role="error"
        id="custom-meta-test-10">Impact statement is comprised entirely of letters, which must be incorrect.</report>
      
      <report test="matches(.,' [Oo]ur |^[Oo]ur ')"
        role="warning"
        id="custom-meta-test-11">Impact statement contains 'our'. Is this possesive langauge relating to the article or research itself (which should be removed)?</report>
      
      <report test="matches(.,' study ') and not(matches(.,'[Tt]his study'))"
        role="warning"
        id="custom-meta-test-13">Impact statement contains 'study'. Is this a third person description of this article? If so, it should be changed to not include this.</report>
      
      <report test="($subj = 'Replication Study') and not(matches(.,'^Editors[\p{Po}] Summary: '))"
        role="error"
        id="rep-study-custom-meta-test">Impact statement in Replication studies must begin with 'Editors' summary: '. This does not - <value-of select="."/></report>
    </rule>
    
    <rule context="article-meta/custom-meta-group/custom-meta/meta-value/*" 
      id="meta-value-child-tests">
      <let name="allowed-elements" value="('italic','sup','sub')"/>
      
      <assert test="local-name() = $allowed-elements"
        role="error"
        id="custom-meta-child-test-1"><name/> is not allowed in impact statement.</assert>
      
    </rule>
    
    <rule context="article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value" 
      id="featmeta-value-tests">
      <let name="type" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject"/>
      
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
    
    <rule context="article-meta/elocation-id" 
      id="elocation-id-tests">
      <let name="article-id" value="parent::article-meta/article-id[@pub-id-type='publisher-id']"/>
      
      <assert test=". = concat('e' , $article-id)"
        role="error" 
        id="test-elocation-conformance">elocation-id is incorrect. It's value should be a concatenation of 'e' and the article id, in this case <value-of select="concat('e',$article-id)"/>.</assert>
    </rule>
    
    <rule context="related-object" 
      id="related-object-tests">
      
      <assert test="ancestor::abstract[not(@abstract-type)]"
        role="error" 
        id="related-object-ancetsor"><name/> is not allowed outside of the main abstract (abstract[not(@abstract-type)]).</assert>
    </rule>
 </pattern>
  
  <pattern
    id="journal-volume">
    
    <rule context="article-meta/volume" 
      id="volume-test">
      <let name="pub-date" value="parent::article-meta/pub-date[@publication-format='electronic'][@date-type='publication']/year"/>
      
      <assert test=". = number($pub-date) - 2011"
        role="error"
        id="volume-test-1">Journal volume is incorrect. It should be <value-of select="number($pub-date) - 2011"/>.</assert>
    </rule>
  </pattern>

  <pattern
    id="equal-author-checks">

  <rule context="article-meta//contrib[@contrib-type='author']" 
		id="equal-author-tests">
    	
    <report test="@equal-contrib='yes' and not(xref[matches(@rid,'^equal-contrib[0-9]$')])"
	    role="error"
	    id="equal-author-test-1">Equal authors must contain an xref[@ref-type='fn'] with an @rid that starts with 'equal-contrib' and ends in a digit.</report>
    
    <report test="xref[matches(@rid,'^equal-contrib[0-9]$')] and not(@equal-contrib='yes')"
      role="error"
      id="equal-author-test-2">author contains an xref[@ref-type='fn'] with a 'equal-contrib0' type @rid, but the contrib has no @equal-contrib='yes'.</report>
		
		</rule>
  
</pattern> 	
  
  <pattern
    id="content-containers">
    
    <rule context="p" 
      id="p-tests">
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
      
      <report test="(ancestor::body[parent::article]) and (descendant::*[1]/local-name() = 'bold') and not(ancestor::caption) and not(descendant::*[1]/preceding-sibling::text()) and matches(descendant::bold[1],'\p{L}') and (descendant::bold[1] != 'Related research article')"
        role="warning" 
        id="p-test-5">p element starts with bolded text - <value-of select="descendant::*[1]"/> - Should it be a header?</report>
      
      <report test="(ancestor::body) and (string-length(.) le 100) and not(parent::*[local-name() = ('fn','td','th')]) and (preceding-sibling::*[1]/local-name() = 'p') and (string-length(preceding-sibling::p[1]) le 100) and ($article-type != 'correction') and ($article-type != 'retraction') and not(ancestor::sub-article) and not((count(*) = 1) and child::supplementary-material)" role="warning" id="p-test-6">Should this be captured as a list-item in a list? p element is less than 100 characters long, and is preceded by another p element less than 100 characters long.</report>
      
      <report test="matches(.,'^\s?•') and not(ancestor::sub-article)"
        role="warning"
        id="p-test-7">p element starts with a bullet point. It is very likely that this should instead be captured as a list-item in a list[@list-type='bullet']. - <value-of select="."/></report>
    </rule>
    
    <rule context="p/*" 
      id="p-child-tests">
      <let name="allowed-p-blocks" value="('bold', 'sup', 'sub', 'sc', 'italic', 'underline', 'xref','inline-formula', 'disp-formula','supplementary-material', 'code', 'ext-link', 'named-content', 'inline-graphic', 'monospace', 'related-object', 'table-wrap')"/>
      
      <assert test="if (ancestor::sec[@sec-type='data-availability']) then self::*/local-name() = ($allowed-p-blocks,'element-citation')
                    else self::*/local-name() = $allowed-p-blocks"
        role="error" 
        id="allowed-p-test">p element cannot contain <value-of select="self::*/local-name()"/>. only contain the following elements are allowed - bold, sup, sub, sc, italic, xref, inline-formula, disp-formula, supplementary-material, code, ext-link, named-content, inline-graphic, monospace, related-object.</assert>
    </rule>
    
    <rule context="xref" 
      id="xref-target-tests">
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
        id="vid-xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' must point to a media[@mimetype="video"] element. Either this links to the incorrect locaiton or the xref/@ref-type is incorrect.</report>
      
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
    
    <rule context="ext-link[@ext-link-type='uri']" 
      id="ext-link-tests">
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
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%,_\+.~#?&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.')" 
        role="warning"
        id="url-conformance-test">@xlink:href doesn't look like a URL. Is this correct?</assert>
      
      <report test="matches(@xlink:href,'\.$')" 
        role="error"
        id="url-fullstop-report">'<value-of select="@xlink:href"/>' - Link ends in a fullstop which is incorrect.</report>
      
      <report test="(matches(.,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%,_\+.~#?&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.') and $parent = $formatting-elems)"
        role="warning" 
        id="ext-link-parent-test">ext-link - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which almost certainly unnecessary.</report>
      
      <report test="(matches(.,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%,_\+.~#?&amp;//=]*)$|^ftp://.|^git://.|^tel:.|^mailto:.') and ($form-children!=''))"
        role="error" 
        id="ext-link-child-test">ext-link - <value-of select="."/> - has a formatting child element - <value-of select="$form-children"/> - which is not correct.</report>
      
      <assert test="$non-form-children=''"
        role="error" 
        id="ext-link-child-test-2">ext-link - <value-of select="."/> - has a non-formatting child element - <value-of select="$non-form-children"/> - which is not correct.</assert>
      
      <report test="contains(.,'copy archived')"
        role="error" 
        id="ext-link-child-test-3">ext-link - <value-of select="."/> - contains the phrase 'copy archived', which is incorrect.</report>
    </rule>
    
    <rule context="fig-group" 
      id="fig-group-tests">
      
      <assert test="count(child::fig[not(@specific-use='child-fig')]) = 1" 
        role="error"
        id="fig-group-test-1">fig-group must have one and only one main figure.</assert>
      
      <report test="not(child::fig[@specific-use='child-fig']) and not(descendant::supplementary-material) and not(descendant::media[@mimetype='video'])" 
        role="error"
        id="fig-group-test-2">fig-group does not contain a figure supplement, figure-level course data or code file, or a figure-level video, which must be incorrect.</report>
      
    </rule>
    
    <rule context="fig-group/*" 
      id="fig-group-child-tests">
      
      <assert test="local-name() = ('fig','media')" 
        role="error"
        id="fig-group-child-test-1"><name/> is not allowed as a child of fig-group.</assert>
      
      <report test="(local-name() = 'media') and not(@mimetype='video')" 
        role="error"
        id="fig-group-child-test-2"><name/> which is a child of fig-group, must have an @mimetype='video' - i.e. only video type media is allowed as a child of fig-group.</report>
      
    </rule>
    
    <rule context="fig[not(ancestor::sub-article[@article-type='reply'])]" 
      id="fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert test="@position" 
        role="error"
        id="fig-test-2">fig must have a @position.</assert>
      
      <report test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(label)" 
        role="error"
        id="fig-test-3">fig must have a label.</report>
      
      <report test="($article-type = $features-article-types) and not(label)" 
        role="warning"
        id="feat-fig-test-3">fig doesn't have a label. Is this correct?</report>
      
      <report test="if ($article-type = ('correction','retraction')) then () 
        else not(caption)" 
        role="error"
        id="fig-test-4">fig must have a caption.</report>
      
      <report test="if ($article-type = ('correction','retraction')) then () 
        else not(caption/title)" 
        role="warning"
        id="pre-fig-test-5"><value-of select="label"/> does not have a title. Please alert eLife staff.</report>
      
      <report test="if ($article-type = ('correction','retraction')) then () 
        else not(caption/title)" 
        role="error"
        id="final-fig-test-5">fig caption must have a title.</report>
      
      <report test="if ($article-type = ('correction','retraction')) then () 
        else (matches(@id,'^fig[0-9]{1,3}$') and not(caption/p))" 
        role="warning"
        id="fig-test-6">Figure does not have a legend, which is very unorthadox. Is this correct?</report>
      
      <assert test="graphic"
        role="warning"
        id="pre-fig-test-7">fig does not have graphic. Esnure author query is added asking for file.</assert>
      
      <assert test="graphic"
        role="error"
        id="final-fig-test-7">fig must have a graphic.</assert>
    </rule>
    
    <rule context="fig[ancestor::sub-article[@article-type='reply']]" 
      id="ar-fig-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(ancestor::body//fig)"/>
      <let name="pos" value="$count - count(following::fig)"/>
      <let name="no" value="substring-after(@id,'fig')"/>
      
      <report test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(label)" 
        role="error"
        id="ar-fig-test-2">Author Response fig must have a label.</report>
      
      <assert test="graphic"
        role="warning"
        id="pre-ar-fig-test-3">Author Response fig does not have graphic. Esnure author query is added asking for file.</assert>
      
      <assert test="graphic"
        role="error"
        id="final-ar-fig-test-3">Author Response fig must have a graphic.</assert>
      
      <assert test="$no = string($pos)" 
        role="warning"
        id="pre-ar-fig-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR images it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert test="$no = string($pos)" 
        role="error"
        id="final-ar-fig-position-test"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR images it is placed in position <value-of select="$pos"/>.</assert>
    </rule>
    
    <rule context="graphic|inline-graphic" 
      id="graphic-tests">
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
    </rule>
    
    <rule context="media" 
      id="media-tests">
      <let name="file" value="@mime-subtype"/>
      <let name="link" value="@xlink:href"/>
      
      <assert test="@mimetype=('video','application','text','image', 'audio')" 
        role="error"
        id="media-test-1">media must have @mimetype, the value of which has to be one of 'video','application','text','image', or 'audio'.</assert>
      
      <assert test="@mime-subtype" 
        role="error"
        id="media-test-2">media must have @mime-subtype.</assert>
      
      <assert test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,6}$')" 
        role="error"
        id="media-test-3">media must have an @xlink:href which contains a file reference.</assert>
      
      <report test="if ($file='octet-stream') then ()
                    else if ($file = 'msword') then not(matches(@xlink:href,'\.doc[x]?$'))
                    else if ($file = 'excel') then not(matches(@xlink:href,'\.xl[s|t|m][x|m|b]?$'))
                    else if ($file='x-m') then not(matches(@xlink:href,'\.m$'))
                    else if ($file='tab-separated-values') then not(matches(@xlink:href,'\.tsv$'))
                    else if ($file='jpeg') then not(matches(@xlink:href,'\.[Jj][Pp][Gg]$'))
                    else if ($file='postscript') then not(matches(@xlink:href,'\.[Aa][Ii]$|\.[Pp][Ss]$'))
                    else if ($file='x-tex') then not(matches(@xlink:href,'\.tex$'))
                    else if ($file='x-gzip') then not(matches(@xlink:href,'\.gz$'))
                    else if ($file='html') then not(matches(@xlink:href,'\.html$'))
                    else if (@mimetype='text') then not(matches(@xlink:href,'\.txt$|\.py$|\.xml$|\.sh$|\.rtf$|\.c$|\.for$'))
                    else not(ends-with(@xlink:href,concat('.',$file)))" 
        role="error"
        id="media-test-4">media must have a file reference in @xlink:href which is equivalent to its @mime-subtype.</report>      
      
      <report test="matches(label,'^Animation [0-9]{1,3}|^Appendix \d{1,4}—animation [0-9]{1,3}') and not(@mime-subtype='gif')" 
        role="error"
        id="media-test-5">media whose label is in the format 'Animation 0' must have a @mime-subtype='gif'.</report>    
      
      <report test="matches(@xlink:href,'\.doc[x]?$|\.pdf$|\.xlsx$|\.xml$|\.xlsx$|\.mp4$|\.gif$')  and (@mime-subtype='octet-stream')" 
        role="warning"
        id="media-test-6">media has @mime-subtype='octet-stream', but the file reference ends with a recognised mime-type. Is this correct?</report>      
      
      <report test="if (child::label) then not(matches(label,'^Video \d{1,4}\.$|^Figure \d{1,4}—video \d{1,4}\.$|^Table \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—figure \d{1,4}—video \d{1,4}\.$|^Animation \d{1,4}\.$|^Author response video \d{1,4}\.$'))
        else ()"
        role="error"
        id="media-test-7">video label does not conform to eLife's usual label format.</report>
      
      <report test="if (ancestor::sec[@sec-type='supplementary-material']) then ()
        else if (@mimetype='video') then (not(label))
        else ()"
        role="error"
        id="media-test-8">video does not contain a label, which is incorrect.</report>
      
      <report test="matches(lower-case(@xlink:href),'\.xml$|\.html$|\.json$')"
        role="error"
        id="media-test-9">media points to an xml, html or json file. This cannot be handled by Kriya currently. Please download the file, place it in a zip and replace the file with this zip (otherwise the file will be erroenously overwritten before publication).</report>
      
      <report test="preceding::media/@xlink:href = $link" 
        role="error"
        id="media-test-10">Media file for <value-of select="if (@mimetype='video') then replace(label,'\.','') else replace(parent::*/label,'\.','')"/> (<value-of select="$link"/>) is the same as the one used for <value-of select="if (preceding::media[@xlink:href=$link][1]/@mimetype='video') then replace(preceding::media[@xlink:href=$link][1]/label,'\.','')
          else replace(preceding::media[@xlink:href=$link][1]/parent::*/label,'\.','')"/>.</report>
    </rule>
    
    <rule context="media[child::label]" 
      id="video-test">
      
      <assert test="caption/title"
        role="warning"
        id="pre-video-title"><value-of select="label"/> does not have a title. Please alert eLife staff.</assert>
      
      <assert test="caption/title"
        role="error"
        id="final-video-title"><value-of select="label"/> does not have a title, which is incorrect.</assert>
      
    </rule>
    
    <rule context="supplementary-material" 
      id="supplementary-material-tests">
      <let name="link" value="media/@xlink:href"/>
      <let name="file" value="if (contains($link,'.')) then lower-case(tokenize($link,'\.')[last()]) else ()"/>
      <let name="code-files" value="('m','py','lib','jl','c','sh','for','cpproj','ipynb','mph','cc','rmd','nlogo','stan','wrl','pl','r','fas','ijm','llb','ipf','mdl','h')"/>
      
      <assert test="label" 
        role="error"
        id="supplementary-material-test-1">supplementary-material must have a label.</assert>
      
      <report test="if (contains(label,'Transparent reporting form')) then () 
                    else not(caption)" 
        role="error"
        id="supplementary-material-test-2">supplementary-material have a child caption.</report>
      
      <report test="if (caption) then not(caption/title)
                    else ()" 
        role="warning"
        id="pre-supplementary-material-test-3"><value-of select="label"/> does not have a title. Please alert eLife staff.</report>
      
      <report test="if (caption) then not(caption/title)
        else ()" 
        role="warning"
        id="final-supplementary-material-test-3"><value-of select="label"/> doesn't have a title. Is this correct?</report>
      
      <!-- Not included because in most instances this is the case
        <report test="if (label = 'Transparent reporting form') then () 
                    else not(caption/p)" 
        role="warning"
        id="supplementary-material-test-4">supplementary-material caption does not have a p. Is this correct?</report>-->
      
      <assert test="media"
        role="error"
        id="supplementary-material-test-5">supplementary-material must have a media.</assert>		
      
      <assert test="matches(label,'^Transparent reporting form$|^Figure \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source data \d{1,4}\.$|^Table \d{1,4}—source data \d{1,4}\.$|^Video \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—source code \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source code \d{1,4}\.$|^Table \d{1,4}—source code \d{1,4}\.$|^Video \d{1,4}—source code \d{1,4}\.$|^Supplementary file \d{1,4}\.$|^Source data \d{1,4}\.$|^Source code \d{1,4}\.$|^Reporting standard \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—figure supplement \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—table \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—video \d{1,4}—source data \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—figure \d{1,4}—figure supplement \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—table \d{1,4}—source code \d{1,4}\.$|^Appendix \d{1,3}—video \d{1,4}—source code \d{1,4}\.$')"
        role="error"
        id="supplementary-material-test-6">supplementary-material label does not conform to eLife's usual label format.</assert>
      
      <report test="(ancestor::sec[@sec-type='supplementary-material']) and (media[@mimetype='video'])" 
        role="error"
        id="supplementary-material-test-7">supplementary-material in additional files sections cannot have the a media element with the attribute mimetype='video'. This should be mimetype='application'</report>
      
      <report test="matches(label,'^Transparent reporting form$|^Supplementary file \d{1,4}\.$|^Source data \d{1,4}\.$|^Source code \d{1,4}\.$|^Reporting standard \d{1,4}\.$') and not(ancestor::sec[@sec-type='supplementary-material'])"
        role="error"
        id="supplementary-material-test-8"><value-of select="label"/> has an article level label but it is not captured in the additional files section - This must be incorrect.</report>
      
      <report test="($file = $code-files) and not(matches(label,'[Ss]ource code \d{1,4}\.$'))"
        role="warning"
        id="source-code-test-1"><value-of select="label"/> has a file which looks like code - <value-of select="$link"/>, but it's not labelled as code.</report>
    </rule>
    
    <rule context="supplementary-material[(ancestor::fig) or (ancestor::media) or (ancestor::table-wrap)]" 
      id="source-data-specific-tests">
      
      <report test="matches(label,'^Figure \d{1,4}—source data \d{1,4}|^Appendix \d{1,4}—figure \d{1,4}—source data \d{1,4}') and (descendant::xref[contains(.,'upplement')])"
        role="warning"
        id="fig-data-test-1"><value-of select="label"/> is figure level source data, but contains a link to a figure supplement - should it be figure supplement source data?</report>
      
    </rule>
    
    <rule context="disp-formula" 
      id="disp-formula-tests">
      
      <assert test="mml:math"
        role="error"
        id="disp-formula-test-2">disp-formula must contain an mml:math element.</assert>
      
      <assert test="parent::p"
        role="error"
        id="disp-formula-test-3">disp-formula must be a child of p. <value-of select="label"/> is a child of <value-of select="parent::*/local-name()"/></assert>
    </rule>
    
    <rule context="inline-formula" 
      id="inline-formula-tests">
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <assert test="mml:math"
        role="error"
        id="inline-formula-test-1">inline-formula must contain an mml:math element.</assert>
      
      <report test="matches($pre-text,'[\p{L}\p{N}\p{M}]$') and not(matches(.,'^\s+'))"
        role="warning"
        id="inline-formula-test-2">There is no space between inline-formula and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report test="matches($post-text,'^[\p{L}\p{N}\p{M}]') and not(matches(.,'\s+$'))"
        role="warning"
        id="inline-formula-test-3">There is no space between inline-formula and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <assert test="parent::p or parent::td or parent::th or parent::title"
        role="error"
        id="inline-formula-test-4"><name/> must be a child of p, td,  th or title. The formula containing <value-of select="."/> is a child of <value-of select="parent::*/local-name()"/></assert>
    </rule>
    
    <rule context="mml:math" 
      id="math-tests">
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
        id="math-test-3">mml:math only contains '±', which is unnecessary. Cature this as a normal text '±' instead.</report>
      
      <report test="matches($data,'^±[\d]+$|^±[\d]+\.[\d]+$')"
        role="error"
        id="math-test-4">mml:math only contains '±' followed by digits, which is unnecessary. Cature this as a normal text instead.</report>
      
      <report test="$data = '×'"
        role="error"
        id="math-test-5">mml:math only contains '×', which is unnecessary. Cature this as a normal text '×' instead.</report>
      
      <report test="$data = '~'"
        role="error"
        id="math-test-6">mml:math only contains '~', which is unnecessary. Cature this as a normal text '~' instead.</report>
      
      <report test="matches($data,'^~[\d]+$|^~[\d]+\.[\d]+$')"
        role="error"
        id="math-test-7">mml:math only contains '~' and digits, which is unnecessary. Cature this as a normal text instead.</report>
      
      <report test="$data = 'μ'"
        role="warning"
        id="math-test-8">mml:math only contains 'μ', which is likely unnecessary. Should this be captured as a normal text 'μ' instead?</report>
      
      <report test="matches($data,'^[\d]+%$|^[\d]+\.[\d]+%$|^%$')"
        role="error"
        id="math-test-9">mml:math only contains '%' and digits, which is unnecessary. Cature this as a normal text instead.</report>
      
      <report test="matches($data,'^%$')"
        role="error"
        id="math-test-12">mml:math only contains '%', which is unnecessary. Cature this as a normal text instead.</report>
      
      <report test="$data = '°'"
        role="error"
        id="math-test-10">mml:math only contains '°', which is likely unnecessary. This should be captured as a normal text '°' instead.</report>
      
      <report test="matches($data,'○')"
        role="warning"
        id="math-test-11">mml:math contains '○' (the white circle symbol). Should this be the degree symbol instead - '°', or '∘' (the ring operator symbol)?</report>
      
      <report test="matches($data,'^±\d+%$|^+\d+%$|^-\d+%$|^\d+%$|^±\d+$|^+\d+$|^-\d+$')"
        role="warning"
        id="math-test-13">mml:math only contains '<value-of select="."/>', which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report test="matches($data,'^Na[2]?\+$|^Ca2\+$|^K\+$|^Cu[2]?\+$|^Ag\+$|^Hg[2]?\+$|^H\+$|^Mg2\+$|^Ba2\+$|^Pb2\+$|^Fe2\+$|^Co2\+$|^Ni2\+$|^Mn2\+$|^Zn2\+$|^Al3\+$|^Fe3\+$|^Cr3\+$')"
        role="warning"
        id="math-test-15">mml:math seems to only contain the formula for a cation - '<value-of select="."/>' - which is likely unnecessary. Should this be captured as normal text instead?</report>
      
      <report test="matches($data,'^H\-$|^Cl\-$|^Br\-$|^I\-$|^OH\-$|^NO3\-$|^NO2\-$|^HCO3\-$|^HSO4\-$|^CN\-$|^MnO4\-$|^ClO[3]?\-$|^O2\-$|^S2\-$|^SO42\-$|^SO32\-$|^S2O32\-$|^SiO32\-$|^CO32\-$|^CrO42\-$|^Cr2O72\-$|^N3\-$|^P3\-$|^PO43\-$')"
        role="warning"
        id="math-test-16">mml:math seems to only contain the formula for an anion - '<value-of select="."/>' - which is likely unnecessary. Should this be captured as normal text instead?</report>
    </rule>
    
    <rule context="disp-formula/*|inline-formula/*" 
      id="formula-child-tests">
      
      <report test="(parent::disp-formula) and not(local-name()=('label','math'))"
        role="error"
        id="disp-formula-child-test-1"><name/> element is not allowed as a child of disp-formula.</report>
      
      <report test="(parent::inline-formula) and (local-name()!='math')"
        role="error"
        id="inline-formula-child-test-1"><name/> element is not allowed as a child of inline-formula.</report>
    </rule>
    
    <rule context="table-wrap" 
      id="table-wrap-tests">
      <let name="id" value="@id"/>
      <let name="lab" value="label"/>
      <let name="article-type" value="ancestor::article/@article-type"/>
      
      <assert test="table"
        role="error"
        id="table-wrap-test-1">table-wrap must have one table.</assert>
      
      <report test="count(table) > 1"
        role="warning"
        id="table-wrap-test-2">table-wrap has more than one table - Is this correct?</report>
      
      <report test="(contains($id,'inline')) and (normalize-space($lab) != '')"
        role="error"
        id="table-wrap-test-3">table-wrap has an inline id <value-of select="$id"/> but it has a label - <value-of select="$lab"/>, which is not correct.</report>
      
      <report test="(matches($id,'^table[0-9]{1,3}$')) and (normalize-space($lab) = '')"
        role="error"
        id="table-wrap-test-4">table-wrap with id <value-of select="$id"/> has no label which is not correct.</report>
      
      <report test="($id = 'keyresource') and ($lab != 'Key resources table')"
        role="error"
        id="kr-table-wrap-test-1">table-wrap has an id <value-of select="$id"/> but it's label is not 'Key resources table', which is incorrect.</report>
      
      <report test="if ($id = 'keyresource') then ()
        else if (contains($id,'inline')) then ()
        else if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="warning"
        id="pre-table-wrap-cite-1">There is no citation to <value-of select="$lab"/> Ensure to query the author asking for a citation.</report>
      
      <report test="if ($id = 'keyresource') then ()
        else if (contains($id,'inline')) then ()
        else if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else if (ancestor::app) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="error"
        id="final-table-wrap-cite-1">There is no citation to <value-of select="$lab"/> Ensure this is added.</report>
      
      <report test="if (contains($id,'inline')) then () 
        else if ($article-type = $features-article-types) then (not(ancestor::article//xref[@rid = $id]))
        else if (ancestor::app) then (not(ancestor::article//xref[@rid = $id]))
        else ()" 
        role="warning"
        id="feat-table-wrap-cite-1">There is no citation to <value-of select="if (label) then label else 'table.'"/> Is this correct?</report>
      
      <report test="($id != 'keyresource') and matches(normalize-space(descendant::thead[1]),'[Rr]eagent\s?type\s?\(species\)\s?or resource\s?[Dd]esignation\s?[Ss]ource\s?or\s?reference\s?[Ii]dentifiers\s?[Aa]dditional\s?information')" 
        role="error"
        id="kr-table-not-tagged"><value-of select="$lab"/> has headings that are for the Key reources table, but it does not have an @id='keyresource'.</report>
      
    </rule>
    
    <rule context="body//table-wrap/label" 
      id="body-table-label-tests">
      
      <assert test="matches(.,'^Table \d{1,4}\.$|^Key resources table$|^Author response table \d{1,4}\.$')"
        role="error"
        id="body-table-label-test-1"><value-of select="."/> - Table label does not conform to the usual format.</assert>
      
    </rule>
    
    <rule context="app//table-wrap/label" 
      id="app-table-label-tests">
      <let name="app" value="ancestor::app/title"/>
      
      <assert test="matches(.,'^Appendix \d{1,4}—table \d{1,4}\.$')"
        role="error"
        id="app-table-label-test-1"><value-of select="."/> - Table label does not conform to the usual format.</assert>
      
      <assert test="starts-with(.,$app)"
        role="error"
        id="app-table-label-test-2"><value-of select="."/> - Table label does not begin with the title of the appendix it sits in. Either the table is in the incorrect appendix or the table has been labelled incorrectly.</assert>
      
    </rule>
    
    <rule context="table" 
      id="table-tests">
      
      <report test="count(tbody) = 0"
        role="error"
        id="table-test-1">table must have at least one body (tbody).</report>
      
      <assert test="thead"
        role="warning"
        id="table-test-2">table doesn't have a header (thead). Is this correct?</assert>
    </rule>
    
    <rule context="table/tbody" 
      id="tbody-tests">
      
      <report test="count(tr) = 0"
        role="error"
        id="tbody-test-1">tbody must have at least one row (tr).</report>
    </rule>
    
    <rule context="table/thead" 
      id="thead-tests">
      
      <report test="count(tr) = 0"
        role="error"
        id="thead-test-1">thead must have at least one row (tr).</report>
    </rule>
    
    <rule context="tr" 
      id="tr-tests">
      <let name="count" value="count(th) + count(td)"/> 
      
      <report test="$count = 0"
        role="error"
        id="tr-test-1">row (tr) must contain at least one heading cell (th) or data cell (td).</report>
      
      <report test="th and (parent::tbody)"
        role="warning"
        id="tr-test-2">table row in body contains a th element (a header), which is unusual. Please check that this is correct.</report>
      
      <report test="td and (parent::thead)"
        role="warning"
        id="tr-test-3">table row in body contains a td element (table data), which is unusual. Please check that this is correct.</report>
    </rule>
    
    <rule context="td/*" 
      id="td-child-tests">
      <let name="allowed-blocks" value="('bold','italic','sup','sub','sc','ext-link','xref', 'break', 'named-content', 'monospace', 'code','inline-graphic','underline','inline-formula')"/> 
      
      <assert test="self::*/local-name() = $allowed-blocks"
        role="error"
        id="td-child-test">td cannot contain <value-of select="self::*/local-name()"/>. Only the following elements are allowed - 'bold','italic','sup','sub','sc','ext-link', 'break', 'named-content', 'monospace', and 'xref'.</assert>
    </rule>
    
    <rule context="th/*" 
      id="th-child-tests">
      <let name="allowed-blocks" value="('italic','sup','sub','sc','ext-link','xref', 'break', 'named-content', 'monospace','inline-formula')"/> 
      
      <assert test="self::*/local-name() = ($allowed-blocks,'bold')"
        role="error"
        id="th-child-test-1">th cannot contain <value-of select="self::*/local-name()"/>. Only the following elements are allowed - 'italic','sup','sub','sc','ext-link', 'break', 'named-content', 'monospace' and 'xref'.</assert>
      
      <report test="self::*/local-name() = 'bold'"
        role="warning"
        id="th-child-test-2">th contains bold. Is this correct?</report>
    </rule>
    
    <rule context="fn[@id][not(@fn-type='other')]" 
      id="fn-tests">
      
      <assert test="ancestor::article//xref/@rid = @id"
        role="error"
        id="fn-xref-presence-test">fn element with an id must have at least one xref element pointing to it.</assert>
    </rule>
    
    <rule context="list-item" 
      id="list-item-tests">
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
    
    <rule context="media[@mimetype='video'][matches(@id,'^video[0-9]{1,3}$')]"
      id="general-video">
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
        role="error"
        id="final-video-cite">There is no citation to <value-of select="$label"/>. Ensure this is added.</assert>
      
      <report test="($xrefs//*:match) and ($sec-id != $sec1/@id)" 
        role="error"
        id="video-placement-1"><value-of select="$label"/> does not appear in the same section as where it is first cited (sec with title '<value-of select="$sec1/title"/>'), which is incorrect.</report>
      
      <report test="($xref-sib = 'p') and ($xref1//following::media/@id = $id)" 
        role="warning"
        id="video-placement-2"><value-of select="$label"/> appears after it's first citation but not directly after it's first citation. Is this correct?</report>
      
    </rule>
    
    <rule context="code"
      id="code-tests">
      
      <report test="child::*"
        role="error"
        id="code-child-test">code contains a child element, which will display in HTML with its tagging, i.e. '&lt;<value-of select="child::*[1]/name()"/><value-of select="if (child::*[1]/@*) then for $x in child::*[1]/@* return concat(' ',$x/name(),'=&quot;',$x/string(),'&quot;') else ()"/>><value-of select="child::*[1]"/>&lt;/<value-of select="child::*[1]/name()"/>>'. Strip any child elements.</report>
      
    </rule>
    
    <rule context="label"
      id="generic-label-tests">
      <let name="label" value="replace(.,'\.$','')"/>
      
      <report test="not(ancestor::fig-group) and parent::fig[@specific-use='child-fig']"
        role="error"
        id="label-fig-group-conformance-1"><value-of select="$label"/> is not placed in a &lt;fig-group&gt; element, which is incorrect. Either the label needs updating, or it needs moving into the &lt;fig-group&gt;.</report>
      
      <report test="not(ancestor::fig-group) and parent::media and matches(.,'[Ff]igure')"
        role="error"
        id="label-fig-group-conformance-2"><value-of select="$label"/> contains the string 'Figure' but it's not placed in a &lt;fig-group&gt; element, which is incorrect. Either the label needs updating, or it needs moving into the &lt;fig-group&gt;.</report>
      
    </rule>
  </pattern>
  
  <pattern id="video-tests">
    
    <rule context="article[(@article-type!='correction') and (@article-type!='retraction')]/body//media[@mimetype='video']" 
      id="body-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'][matches(label,'^Video [\d]+\.$')])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'][matches(label,'^Video [\d]+\.$')][ancestor::body])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      <let name="fig-label" value="replace(ancestor::fig-group/fig[1]/label,'\.$','—')"/>
      <let name="fig-pos" value="count(ancestor::fig-group//media[@mimetype='video'][starts-with(label,$fig-label)]) - count(following::media[@mimetype='video'][starts-with(label,$fig-label)])"/>
      
      <report test="not(ancestor::fig-group) and (matches(label,'[Vv]ideo')) and ($no != string($pos))" 
        role="error"
        id="body-video-position-test-1"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other videos it is placed in position <value-of select="$pos"/>.</report>
      
      <assert test="starts-with(label,$fig-label)" 
        role="error"
        id="fig-video-label-test"><value-of select="label"/> does not begin with its parent figure label - <value-of select="$fig-label"/> - which is incorrect.</assert>
      
      <report test="(ancestor::fig-group) and ($no != string($fig-pos))" 
        role="error"
        id="fig-video-position-test"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other fig-level videos it is placed in position <value-of select="$fig-pos"/>.</report>
      
      <report test="(not(ancestor::fig-group)) and (descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))])" 
        role="warning"
        id="fig-video-check-1"><value-of select="label"/> contains a link to <value-of select="descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))][1]"/>, but it is not a captured as a child of that fig. Should it be captured as <value-of select="concat(descendant::xref[@ref-type='fig'][contains(.,'igure') and not(contains(.,'supplement'))][1],'&#x2014;video x')"/> instead?</report>
      
    </rule>
    
    <rule context="app//media[@mimetype='video']" 
      id="app-video-specific">
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
    
    <rule context="sub-article/body//media[@mimetype='video']" 
      id="ar-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      
      <assert test="$no = string($pos)" 
        role="warning"
        id="pre-ar-video-position-test"><value-of select="label"/> does not appear in sequence which is likely incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert test="$no = string($pos)" 
        role="error"
        id="final-ar-video-position-test"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other AR videos it is placed in position <value-of select="$pos"/>.</assert>
    </rule>
    
  </pattern>
  
  <pattern id="table-pos-tests">
    
    <rule context="article[(@article-type!='correction') and (@article-type!='retraction')]/body//table-wrap[matches(@id,'^table[\d]+$')]" 
      id="body-table-pos-conformance">
      <let name="count" value="count(ancestor::body//table-wrap[matches(@id,'^table[\d]+$')])"/>
      <let name="pos" value="$count - count(following::table-wrap[(matches(@id,'^table[\d]+$')) and (ancestor::body) and not(ancestor::sub-article)])"/>
      <let name="no" value="substring-after(@id,'table')"/>
      
      <assert test="($no = string($pos))" 
        role="warning"
        id="pre-body-table-report"><value-of select="label"/> does not appear in sequence. Relative to the other numbered tables it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert test="($no = string($pos))" 
        role="error"
        id="final-body-table-report"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other numbered tables it is placed in position <value-of select="$pos"/>.</assert>
      
    </rule>
    
    <rule context="article//app//table-wrap[matches(@id,'^app[\d]+table[\d]+$')]" 
      id="app-table-pos-conformance">
      <let name="app-id" value="ancestor::app/@id"/>
      <let name="app-no" value="substring-after($app-id,'appendix-')"/>
      <let name="id-regex" value="concat('^app',$app-no,'table[\d]+$')"/>
      <let name="count" value="count(ancestor::app//table-wrap[matches(@id,$id-regex)])"/>
      <let name="pos" value="$count - count(following::table-wrap[matches(@id,$id-regex)])"/>
      <let name="no" value="substring-after(@id,concat($app-no,'table'))"/>
      
      <assert test="($no = string($pos))" 
        role="warning"
        id="pre-app-table-report"><value-of select="label"/> does not appear in sequence. Relative to the other numbered tables in the same appendix it is placed in position <value-of select="$pos"/>.</assert>
      
      <assert test="($no = string($pos))" 
        role="error"
        id="final-app-table-report"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other numbered tables in the same appendix it is placed in position <value-of select="$pos"/>.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern
    id="further-fig-tests">
  
    <rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]" 
      id="fig-specific-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="id" value="@id"/>
      <let name="count" value="count(ancestor::article//fig[matches(label,'^Figure \d{1,4}\.$')])"/>
      <let name="pos" value="$count - count(following::fig[matches(label,'^Figure \d{1,4}\.$')])"/>
      <let name="no" value="substring-after($id,'fig')"/>
      <let name="pre-sib" value="preceding-sibling::*[1]"/>
      <let name="fol-sib" value="following-sibling::*[1]"/>
      <let name="lab" value="replace(label,'\.','')"/>
      
      <report test="label[contains(lower-case(.),'supplement')]" 
        role="error"
        id="fig-specific-test-1">fig label contains 'supplement', but it does not have a @specific-use='child-fig'. If it is a figure supplement it needs the attribute, if it isn't then it cannot contain 'supplement' in the label.</report>
      
      <report test="if ($article-type = ('correction','retraction')) then () 
                    else if ($count = 0) then ()
                    else if (not(matches($id,'^fig[0-9]{1,3}$'))) then ()
                    else $no != string($pos)" 
        role="error"
        id="fig-specific-test-2"><value-of select="$lab"/> does not appear in sequence which is incorrect. Relative to the other figures it is placed in position <value-of select="$pos"/>.</report>
      
      <report test="if ($article-type = ('correction','retraction')) then () 
        else not((preceding::p[1]//xref[@rid = $id]) or (preceding::p[parent::sec][1]//xref[@rid = $id]))" 
        role="warning"
        id="fig-specific-test-3"><value-of select="$lab"/> does not appear directly after a paragraph citing it. Is that correct?</report>
      
      <report test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="warning"
        id="pre-fig-specific-test-4">There is no citation to <value-of select="$lab"/> Ensure to query the author asking for a citation.</report>
      
      <report test="if ($article-type = ($features-article-types,'correction','retraction')) then ()
        else not(ancestor::article//xref[@rid = $id])" 
        role="error"
        id="final-fig-specific-test-4">There is no citation to <value-of select="$lab"/> Ensure this is added.</report>
      
      <report test="if ($article-type = $features-article-types) then (not(ancestor::article//xref[@rid = $id]))
        else ()" 
        role="warning"
        id="feat-fig-specific-test-4">There is no citation to <value-of select="if (label) then label else 'figure.'"/> Is this correct?</report>
      
      <report test="($fol-sib/local-name() = 'p') and ($fol-sib/*/local-name() = 'disp-formula') and (count($fol-sib/*[1]/preceding-sibling::text()) = 0) and (not(matches($pre-sib,'\.\s*?$|\?\s*?$|!\s*?$')))" 
        role="warning"
        id="fig-specific-test-4"><value-of select="$lab"/> is immediately followed by a display formula, and preceded by a paragraph which does not end with punctuation. Should it should be moved after the display formula or after the para following the display formula?</report>
      
      <report test="($fol-sib/local-name() = 'disp-formula') and (not(matches($pre-sib,'\.\s*?$|\?\s*?$|!\s*?$')))" 
        role="warning"
        id="fig-specific-test-5"><value-of select="$lab"/> is immediately followed by a display formula, and preceded by a paragraph which does not end with punctuation. Should it should be moved after the display formula or after the para following the display formula?</report>
  
    </rule>
    
    <rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]/label" 
      id="fig-label-tests">
      
      <assert test="matches(.,'^Figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error"
        id="fig-label-test-1">fig label must be in the format 'Figure 0.', 'Chemical structure 0.', or 'Scheme 0'.</assert>
    </rule>
    
    <rule context="article/body//fig[@specific-use='child-fig']" 
      id="fig-sup-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="count" value="count(parent::fig-group/fig[@specific-use='child-fig'])"/>
      <let name="pos" value="$count - count(following-sibling::fig[@specific-use='child-fig'])"/>
      <let name="label-conform" value="matches(label,'^Figure [\d]+—figure supplement [\d]+')"/>
      <let name="no" value="substring-after(@id,'s')"/>
      <let name="parent-fig-no" value="substring-after(parent::fig-group/fig[not(@specific-use='child-fig')]/@id,'fig')"/>
      <let name="label-no" value="replace(substring-after(label,'supplement'),'[^\d]','')"/>
      
      <assert test="parent::fig-group" 
        role="error"
        id="fig-sup-test-1">fig supplement is not a child of fig-group. This cannot be correct.</assert>
      
      <assert test="$label-conform = true()" 
        role="error"
        id="fig-sup-test-2">fig in the body of the article which has a @specific-use='child-fig' must have a label in the format 'Figure X—figure supplement X.' (where X is one or more digits).</assert>
      
      <assert test="starts-with(label,concat('Figure ',$parent-fig-no))" 
        role="error"
        id="fig-sup-test-3"><value-of select="label"/> does not start with the main figure number it is associated with - <value-of select="concat('Figure ',$parent-fig-no)"/>.</assert>
      
      <report test="if ($article-type = ('correction','retraction')) then () 
                    else $no != string($pos)"
        role="error"
        id="fig-sup-test-4"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other figures it is placed in position <value-of select="$pos"/>.</report>
      
      <report test="if ($article-type = ('correction', 'retraction')) then () 
        else (($label-conform = true()) and ($label-no != string($pos)))"
        role="error"
        id="fig-sup-test-5"><value-of select="label"/> is in position <value-of select="$pos"/>, which means either the label or the placement incorrect.</report>
      
      <report test="($label-conform = true()) and ($no != $label-no)"
        role="error"
        id="fig-sup-test-6"><value-of select="label"/> label ends with <value-of select="$label-no"/>, but the id (<value-of select="@id"/>) ends with <value-of select="$no"/>, so one must be incorrect.</report>
      
    </rule>
    
    <rule context="sub-article[@article-type='reply']//fig" 
      id="rep-fig-tests">
      
      <assert test="label" 
        role="error"
        id="resp-fig-test-2">fig must have a label.</assert>
      
      <assert test="matches(label,'^Author response image [0-9]{1,3}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')"
        role="error"
        id="reply-fig-test-2">fig label in author response must be in the format 'Author response image 1.', or 'Chemical Structure 1.', or 'Scheme 1.'.</assert>
      
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']//fig" 
      id="dec-fig-tests">
      
      <assert test="label" 
        role="error"
        id="dec-fig-test-1">fig must have a label.</assert>
      
      <assert test="matches(label,'^Decision letter image [0-9]{1,3}\.$')"
        role="error"
        id="dec-fig-test-2">fig label in author response must be in the format 'Decision letter image 1.'.</assert>
      
    </rule>
    
    <rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]/label" 
      id="box-fig-tests"> 
      
      <assert test="matches(.,'^Box \d{1,4}—figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error"
        id="box-fig-test-1">label for fig inside boxed-text must be in the format 'Box 1—figure 1.', or 'Chemical structure 1.', or 'Scheme 1'.</assert>
    </rule>
    
    <rule context="article//app//fig[not(@specific-use='child-fig')]/label" 
      id="app-fig-tests"> 
      
      <assert test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix [A-Z]—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error"
        id="app-fig-test-1">label for fig inside appendix must be in the format 'Appendix 1—figure 1.', 'Appendix A—figure 1.', or 'Chemical structure 1.', or 'Scheme 1'.</assert>
      
      <report test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$') and not(starts-with(.,ancestor::app/title))" 
        role="error"
        id="app-fig-test-2">label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure is placed in the incorrect appendix or the label is incorrect.</report>
    </rule>
    
    <rule context="article//app//fig[@specific-use='child-fig']/label" 
      id="app-fig-sup-tests"> 
      
      <assert test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}—figure supplement \d{1,4}\.$|^Appendix—figure \d{1,4}—figure supplement \d{1,4}\.$')" 
        role="error"
        id="app-fig-sup-test-1">label for fig inside appendix must be in the format 'Appendix 1—figure 1—figure supplement 1.'.</assert>
      
      <assert test="starts-with(.,ancestor::app/title)" 
        role="error"
        id="app-fig-sup-test-2">label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure is placed in the incorrect appendix or the label is incorrect.</assert>
    </rule>
  </pattern>
  
  <pattern
    id="body">
    
    <rule context="article[@article-type='research-article']/body" 
      id="ra-body-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject"/>
      <let name="method-count" value="count(sec[@sec-type='materials|methods']) + count(sec[@sec-type='methods']) + count(sec[@sec-type='model'])"/>
      <let name="res-disc-count" value="count(sec[@sec-type='results']) + count(sec[@sec-type='discussion'])"/>
    
      <report test="count(sec) = 0" 
        role="error"
        id="ra-sec-test-1">At least one sec should be present in body for research-article content.</report>
      
      <report test="if ($type = ('Short Report','Scientific Correspondence')) then ()
                    else count(sec[@sec-type='intro']) != 1" 
        role="warning"
        id="ra-sec-test-2"><value-of select="$type"/> doesn't have child sec[@sec-type='intro'] in the main body. Is this correct?</report>
      
      <report test="if ($type = ('Short Report','Scientific Correspondence')) then ()
                    else $method-count != 1" 
        role="warning"
        id="ra-sec-test-3">main body in <value-of select="$type"/> content doesn't have a child sec with @sec-type whose value is either 'materials|methods', 'methods' or 'model'. Is this correct?.</report>
      
      <report test="if ($type = ('Short Report','Scientific Correspondence')) then ()
        else if (sec[@sec-type='results|discussion']) then ()
        else $res-disc-count != 2" 
        role="warning"
        id="ra-sec-test-4">main body in <value-of select="$type"/> content doesn't have either a child sec[@sec-type='results|discussion'] or a sec[@sec-type='results'] and a sec[@sec-type='discussion']. Is this correct?</report>
    
    </rule>
    
    <rule context="body/sec" 
      id="top-level-sec-tests">
      <let name="type" value="ancestor::article//subj-group[@subj-group-type='display-channel']/subject"/>
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
      <let name="allowed-titles" value="('Introduction', 'Results', 'Discussion', 'Materials and methods', 'Results and discussion', 'Conclusion', 'Introduction and results', 'Results and conclusions', 'Discussion and conclusions', 'Model and methods')"/>
      
      <assert test="@id = concat('s', $pos)" 
        role="error"
        id="top-sec-id">top-level must have @id in the format 's0', where 0 relates to the position of the sec. It should be <value-of select="concat('s', $pos)"/>.</assert>
      
      <report test="not($type = ($features-subj,'Review Article')) and not(replace(title,'&#x00A0;',' ') = $allowed-titles)" 
        role="warning"
        id="sec-conformity">top level sec with title - <value-of select="title"/> - is not a usual title for <value-of select="$type"/> content. Should this be captured as a sub-level of <value-of select="preceding-sibling::sec[1]/title"/>?</report>
      
    </rule>
    
    <rule context="body/sec//sec" 
      id="lower-level-sec-tests">
      <let name="parent-id" value="parent::sec/@id"/>
      <let name="pos" value="count(parent::sec/sec) - count(following-sibling::sec)"/>
      
      <assert test="@id = concat($parent-id,'-',$pos)" 
        role="error"
        id="lower-sec-test-1">This sec @id must be a concatenation of the parent sec @id, '-', and the position of this sec relative to other sibling secs - <value-of select="concat($parent-id,'-',$pos)"/>.</assert>
      
    </rule>
  </pattern>
  
  <pattern
    id="title-conformance">
    
    <rule context="article-meta//article-title" 
      id="article-title-tests">
      <let name="type" value="ancestor::article-meta//subj-group[@subj-group-type='display-channel']/subject" />
      <let name="specifics" value="('Replication Study','Registered Report','Correction','Retraction')"/>
      
      <report test="if ($type = $specifics) then not(starts-with(.,e:article-type2title($type)))
                    else ()" 
        role="error"
        id="article-type-title-test-1">title of a '<value-of select="$type"/>' must start with '<value-of select="e:article-type2title($type)"/>'.</report>
      
      <report test="($type = 'Scientific Correspondence') and not(matches(.,'^Comment on|^Response to comment on'))" 
        role="error"
        id="article-type-title-test-2">title of a '<value-of select="$type"/>' must start with 'Comment on' or 'Response to comment on', but this starts with something else - <value-of select="."/>.</report>
      
      <report test="($type = 'Scientific Correspondence') and matches(.,'^Comment on &#x201c;|^Response to comment on &#x201c;')" 
        role="error"
        id="sc-title-test-1">title of a '<value-of select="$type"/>' contains a left double quotation mark. The original article title must be surrounded by a single roman apostrophe - <value-of select="."/>.</report>
      
      <report test="($type = 'Scientific Correspondence') and matches(.,'&#x201d;')" 
        role="warning"
        id="sc-title-test-2">title of a '<value-of select="$type"/>' contains a right double quotation mark. Is this correct? The original article title must be surrounded by a single roman apostrophe - <value-of select="."/>.</report>
    </rule>
    
    <rule context="sec[@sec-type]/title" 
      id="sec-title-tests">
      <let name="title" value="e:sec-type2title(parent::sec/@sec-type)" />
      
      <report test="if ($title = 'undefined') then () 
        else . != $title" 
        role="warning"
        id="sec-type-title-test">title of a sec with an @sec-type='<value-of select="parent::sec/@sec-type"/>' should usually be '<value-of select="$title"/>'.</report>
      
    </rule>
    
    <rule context="fig/caption/title" 
      id="fig-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label"/>
      
      <report test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" 
        role="warning"
        id="fig-title-test-1">'<value-of select="$label"/>' appears to have a title which is the begining of a caption. Is this correct?</report>
      
      <assert test="matches(.,'\.$|\?$')" 
        role="error"
        id="fig-title-test-2">title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report test="matches(.,' vs\.$')" 
        role="warning"
        id="fig-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\s')" 
        role="error"
        id="fig-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
      
      <report test="matches(.,'^\p{P}')" 
        role="warning"
        id="fig-title-test-5">title for <value-of select="$label"/> begins with punctuation. Is this correct? - <value-of select="."/></report>
    </rule>
    
    <rule context="supplementary-material/caption/title" 
      id="supplementary-material-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label"/>
      
      <report test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" 
        role="warning"
        id="supplementary-material-title-test-1">'<value-of select="$label"/>' appears to have a title which is the begining of a caption. Is this correct?</report>
      
      <assert test="matches(.,'\.$')" 
        role="error"
        id="supplementary-material-title-test-2">title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report test="matches(.,' vs\.$')" 
        role="warning"
        id="supplementary-material-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\s')" 
        role="error"
        id="supplementary-material-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
    </rule>
    
    <rule context="media/caption/title" 
      id="video-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label"/>
      
      <report test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" 
        role="warning"
        id="video-title-test-1">'<value-of select="$label"/>' appears to have a title which is the begining of a caption. Is this correct?</report>
      
      <assert test="matches(.,'\.$|\?$')" 
        role="error"
        id="video-title-test-2">title for <value-of select="$label"/> must end with a full stop.</assert>
      
      <report test="matches(.,' vs\.$')" 
        role="warning"
        id="video-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\s')" 
        role="error"
        id="video-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
    </rule>
    
    <rule context="ack" 
      id="ack-title-tests">
      
      <assert test="title = 'Acknowledgements'"
        role="error"
        id="ack-title-test">ack must have a title that contains 'Acknowledgements'. Currently it is '<value-of select="title"/>'.</assert>
      
    </rule>
    
    <rule context="ack//p" 
      id="ack-content-tests">
      <let name="hit" value="string-join(for $x in tokenize(.,' ') return 
        if (matches($x,'^[A-Z]{1}\.$')) then $x
        else (),', ')"/>
      <let name="hit-count" value="count(for $x in tokenize(.,' ') return 
        if (matches($x,'^[A-Z]{1}\.$')) then $x
        else ())"/>
      
      <report test="matches(.,' [A-Z]\. |^[A-Z]\. ')"
        role="warning"
        id="ack-full-stop-intial-test">p element in Acknowledgements contains what looks like <value-of select="$hit-count"/> intial(s) followed by a full stop. Is it correct? - <value-of select="$hit"/></report>
      
    </rule>
    
    <rule context="ref-list" 
      id="ref-list-title-tests">
      
      <assert test="title = 'References'"
        role="warning"
        id="ref-list-title-test">reference list usually has a title that is 'References', but currently it is '<value-of select="title"/>' - is that correct?</assert>
      
    </rule>
    
    <rule context="app/title" 
      id="app-title-tests">
      
      <assert test="matches(.,'^Appendix$|^Appendix [0-9]$|^Appendix [0-9][0-9]$')"
        role="error"
        id="app-title-test">app title must be in the format 'Appendix 1'. Currently it is '<value-of select="."/>'.</assert>
      
    </rule>
    
    <rule context="fn-group[@content-type='competing-interest']" 
      id="comp-int-title-tests">
      
      <assert test="title = 'Competing interests'"
        role="error"
        id="comp-int-title-test">fn-group[@content-type='competing-interests'] must have a title that contains 'Competing interests'. Currently it is '<value-of select="title"/>'.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='author-contribution']" 
      id="auth-cont-title-tests">
      
      <assert test="title = 'Author contributions'"
        role="error"
        id="auth-cont-title-test">fn-group[@content-type='author-contribution'] must have a title that contains 'Author contributions'. Currently it is '<value-of select="title"/>'.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='ethics-information']" 
      id="ethics-title-tests">
      
      <assert test="title = 'Ethics'"
        role="error"
        id="ethics-title-test">fn-group[@content-type='ethics-information'] must have a title that contains 'Author contributions'. Currently it is '<value-of select="title"/>'.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/title-group" 
      id="dec-letter-title-tests">
      
      <assert test="article-title = 'Decision letter'"
        role="error"
        id="dec-letter-title-test">title-group must contain article-title which contains 'Decision letter'. Currently it is <value-of select="article-title"/>.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/front-stub/title-group" 
      id="reply-title-tests">
      <assert test="article-title = 'Author response'"
        role="error"
        id="reply-title-test">title-group must contain article-title which contains 'Author response'. Currently it is <value-of select="article-title"/>.</assert>
      
    </rule>
  </pattern>
  
  <pattern
    id="id-conformance">
    
    <rule context="article-meta//contrib[@contrib-type='author']" 
      id="author-contrib-ids">
      
      <report test="if (collab) then ()
        else if (ancestor::collab) then ()
        else not(matches(@id,'^[a-z]+-[0-9]+$'))"
        role="error" 
        id="author-id-1">contrib[@contrib-type="author"] must have an @id which is an alpha-numeric string.</report>
    </rule>
    
    <rule context="funding-group/award-group" 
      id="award-group-ids">
      
      <assert test="matches(substring-after(@id,'fund'),'^[0-9]{1,2}$')"
        role="error" 
        id="award-group-test-1">award-group must have an @id, the value of which conforms to the convention 'fund', followed by a digit.</assert>
    </rule>
    
    <rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]" 
      id="fig-ids">
      
      <assert test="matches(@id,'^fig[0-9]{1,3}$|^C[0-9]{1,3}$|^S[0-9]{1,3}$')" 
        role="error"
        id="fig-id-test-1">fig must have an @id in the format fig0 (or C0 for chemical structures, or S0 for Schemes).</assert>
      
      <report test="matches(label,'[Ff]igure') and not(matches(@id,'^fig[0-9]{1,3}$'))" 
        role="error"
        id="fig-id-test-2">fig must have an @id in the format fig0.</report>
      
      <report test="matches(label,'[Cc]hemical [Ss]tructure') and not(matches(@id,'^chem[0-9]{1,3}$'))" 
        role="warning"
        id="fig-id-test-3">Chemical structures must have an @id in the format chem0.</report>
      
      <report test="matches(label,'[Ss]cheme') and not(matches(@id,'^scheme[0-9]{1,3}$'))" 
        role="warning"
        id="fig-id-test-4">Schemes must have an @id in the format scheme0.</report>
    </rule>
    
    <rule context="article/body//fig[@specific-use='child-fig'][not(ancestor::boxed-text)]" 
      id="fig-sup-ids">
      
      <assert test="matches(@id,'^fig[0-9]{1,3}s[0-9]{1,3}$')" 
        role="error"
        id="fig-sup-id-test">figure supplement must have an @id in the format fig0s0.</assert>
    </rule>
    
    <rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]" 
      id="box-fig-ids">
      <let name="box-id" value="ancestor::boxed-text/@id"/> 
      
      <assert test="matches(@id,'^box[0-9]{1,3}fig[0-9]{1,3}$')" 
        role="error"
        id="box-fig-id-1">fig must have @id in the format box0fig0.</assert>
      
      <assert test="contains(@id,$box-id)" 
        role="error"
        id="box-fig-id-2">fig id does not contain its ancestor boxed-text id. Please ensure the first part of the id contains '<value-of select="$box-id"/>'.</assert>
    </rule>
    
    <rule context="article/back//app//fig[not(@specific-use='child-fig')]" 
      id="app-fig-ids">
      
      <assert test="matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}$')" 
        role="error"
        id="app-fig-id-test">figures in appendices must have an @id in the format app0fig0.</assert>
    </rule>
    
    <rule context="article/back//app//fig[@specific-use='child-fig']" 
      id="app-fig-sup-ids">
      
      <assert test="matches(@id,'^app[0-9]{1,3}fig[0-9]{1,3}s[0-9]{1,3}$')" 
        role="error"
        id="app-fig-sup-id-test">figure supplements in appendices must have an @id in the format app0fig0s0.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']//fig[not(@specific-use='child-fig')]" 
      id="rep-fig-ids">
      
      <assert test="matches(@id,'^respfig[0-9]{1,3}$')" 
        role="error"
        id="resp-fig-id-test">author response fig must have @id in the format respfig0.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']//fig[@specific-use='child-fig']" 
      id="rep-fig-sup-ids">
      
      <assert test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$')" 
        role="error"
        id="resp-fig-sup-id-test">author response figure supplement must have @id in the format respfig0s0.</assert>
      
    </rule>
    
    <rule context="article/body//media[(@mimetype='video') and not(ancestor::boxed-text) and not(parent::fig-group)]" 
      id="video-ids">
      
      <assert test="matches(@id,'^video[0-9]{1,3}$')" 
        role="error"
        id="video-id-test">main video must have an @id in the format video0.  <value-of select="@id"/> does not conform to this.</assert>
    </rule>
    
    <rule context="article/body//fig-group/media[(@mimetype='video') and not(ancestor::boxed-text)]" 
      id="video-sup-ids">
      <let name="id-prefix" value="parent::fig-group/fig[1]/@id"/>
      
      <assert test="matches(@id,'^fig[0-9]{1,3}video[0-9]{1,3}$')" 
        role="error"
        id="video-sup-id-test-1">video supplement must have an @id in the format fig0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,$id-prefix)" 
        role="error"
        id="video-sup-id-test-2">video supplement must have an @id which begins with the id of its parent fig. <value-of select="@id"/> does not start with <value-of select="$id-prefix"/>.</assert>
    </rule>
    
    <rule context="article/back//app//media[(@mimetype='video') and not(parent::fig-group)]" 
      id="app-video-ids">
      <let name="id-prefix" value="substring-after(ancestor::app/@id,'-')"/>
      
      <assert test="matches(@id,'^app[0-9]{1,3}video[0-9]{1,3}$')" 
        role="error"
        id="app-video-id-test-1">video in appendix must have an @id in the format app0video0. <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,concat('app',$id-prefix))" 
        role="error"
        id="app-video-id-test-2">video supplement must have an @id which begins with the id of its ancestor appendix. <value-of select="@id"/> does not start with <value-of select="concat('app',$id-prefix)"/>.</assert>
    </rule>
    
    <rule context="article/back//app//media[(@mimetype='video') and (parent::fig-group)]" 
      id="app-video-sup-ids">
      <let name="id-prefix-1" value="substring-after(ancestor::app/@id,'-')"/>
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
    
    <rule context="article/body//boxed-text//media[(@mimetype='video')]" 
      id="box-vid-ids">
      <let name="box-id" value="ancestor::boxed-text/@id"/> 
      
      <assert test="matches(@id,'^box[0-9]{1,3}video[0-9]{1,3}$')" 
        role="error"
        id="box-vid-id-1">video must have @id in the format box0video0.  <value-of select="@id"/> does not conform to this.</assert>
      
      <assert test="starts-with(@id,$box-id)" 
        role="error"
        id="box-vid-id-2">video id does not start with its ancestor boxed-text id. Please ensure the first part of the id contains '<value-of select="$box-id"/>'.</assert>
    </rule>
    
    <rule context="related-article" 
      id="related-articles-ids">
      
      <assert test="matches(@id,'^ra\d$')"
        role="error"
        id="related-articles-test-7">related-article element must contain a @id, the value of which should be in the form ra0.</assert>
    </rule>
    
    <rule context="aff[not(parent::contrib)]" 
      id="aff-ids">
      
      <assert test="if (label) then @id = concat('aff',label)
                    else starts-with(@id,'aff')"
        role="error"
        id="aff-id-test">aff @id must be a concatenation of 'aff' and the child label value. In this instance it should be <value-of select="concat('aff',label)"/>.</assert>
    </rule>
    
    <!-- @id for fn[parent::table-wrap-foot] not accounted for -->
    <rule context="fn" 
      id="fn-ids">
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
    
    <rule context="disp-formula" 
      id="disp-formula-ids">
      
      <assert test="matches(@id,'^equ[0-9]{1,9}$')"
        role="error"
        id="disp-formula-id-test">disp-formula @id must be in the format 'equ0'.</assert>
    </rule>
    
    <rule context="disp-formula/mml:math" 
      id="mml-math-ids">
      
      <assert test="matches(@id,'^m[0-9]{1,9}$')"
        role="error"
        id="mml-math-id-test">mml:math @id in disp-formula must be in the format 'm0'.</assert>
    </rule>
    
    <rule context="app/table-wrap" 
    id="app-table-wrap-ids">
      <let name="app-no" value="substring-after(ancestor::app/@id,'-')"/>
    
      <assert test="matches(@id, '^app[0-9]{1,3}table[0-9]{1,3}$')"
      role="error"
      id="app-table-wrap-id-test-1">table-wrap @id in appendix must be in the format 'app0table0'.</assert>
      
      <assert test="starts-with(@id, concat('app' , $app-no))"
        role="error"
        id="app-table-wrap-id-test-2">table-wrap @id must start with <value-of select="concat('app' , $app-no)"/>.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']//table-wrap" 
      id="resp-table-wrap-ids">
 
      <assert test="if (label) then matches(@id, '^resptable[0-9]{1,3}$')
        else matches(@id, '^respinlinetable[0-9]{1,3}$')"
        role="warning"
        id="resp-table-wrap-id-test">table-wrap @id in author reply must be in the format 'resptable0' if it has a label or in the format 'respinlinetable0' if it does not.</assert>
    </rule>
    
    <rule context="article//table-wrap[not(ancestor::app) and not(ancestor::sub-article[@article-type='reply'])]" 
      id="table-wrap-ids">
      
      <assert test="if (label = 'Key resources table') then @id='keyresource'
                    else if (label) then matches(@id, '^table[0-9]{1,3}$')
                    else matches(@id, '^inlinetable[0-9]{1,3}$')"
        role="error"
        id="table-wrap-id-test">table-wrap @id must be in the format 'table0', unless it doesn't have a label, in which case it must be 'inlinetable0' or it is the key resource table which must be 'keyresource'.</assert>
    </rule>
    
    <rule context="article/body/sec" 
    id="body-top-level-sec-ids">
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
    
      <assert test="@id = concat('s',$pos)"
        role="error"
        id="body-top-level-sec-id-test">This sec id must be a concatenation of 's' and this element's position relative to it's siblings. It must be <value-of select="concat('s',$pos)"/>.</assert>
      </rule>
    
    <rule context="article/back/sec" 
      id="back-top-level-sec-ids">
      <let name="pos" value="count(ancestor::article/body/sec) + count(parent::back/sec) - count(following-sibling::sec)"/>
      
      <assert test="@id = concat('s',$pos)"
        role="error"
        id="back-top-level-sec-id-test">This sec id must be a concatenation of 's' and this element's position relative to other top level secs. It must be <value-of select="concat('s',$pos)"/>.</assert>
    </rule>
    
    <rule context="article/body/sec//sec|article/back/sec//sec" 
      id="low-level-sec-ids">
      <let name="parent-sec" value="parent::sec/@id"/>
      <let name="pos" value="count(parent::sec/sec) - count(following-sibling::sec)"/>
      
      <assert test="@id = concat($parent-sec,'-',$pos)"
        role="error"
        id="low-level-sec-id-test">sec id must be a concatenation of it's parent sec id and this element's position relative to it's sibling secs. It must be <value-of select="concat($parent-sec,'-',$pos)"/>.</assert>
    </rule>
    
    <rule context="app" 
      id="app-ids">
      <let name="pos" value="string(count(ancestor::article//app) - count(following::app))"/>
      
      <assert test="matches(@id,'^appendix-[0-9]{1,3}$')"
        role="error"
        id="app-id-test-1">app id must be in the format 'appendix-0'. <value-of select="@id"/> is not in this format.</assert>
      
      <assert test="substring-after(@id,'appendix-') = $pos"
        role="error"
        id="app-id-test-2">app id is <value-of select="@id"/>, but relative to other appendices it is in position <value-of select="$pos"/>.</assert>
    </rule>
  </pattern>
  
  <pattern
    id="sec-specific">
    
    <rule context="sec" 
      id="sec-tests">
      <let name="child-count" value="count(p) + count(sec) + count(fig) + count(fig-group) + count(media) + count(table-wrap) + count(boxed-text) + count(list) + count(fn-group) + count(supplementary-material) + count(related-object)"/>
      
    <assert test="title"
      role="error"
      id="sec-test-1">sec must have a title</assert>
      
      <assert test="$child-count gt 0"
        role="error"
        id="sec-test-2">sec appears to contain no content. This cannot be correct.</assert>
      
    </rule>
  </pattern>
  
  <pattern
    id="back">
    
    <rule context="back"
      id="back-tests">
      <let name="article-type" value="parent::article/@article-type"/>
      <let name="subj-type" value="parent::article//subj-group[@subj-group-type='display-channel']/subject"/>
      
      <report test="if ($article-type = ($features-article-types,'retraction','correction')) then ()
                    else count(sec[@sec-type='additional-information']) != 1"
        role="error"
        id="back-test-1">One and only one sec[@sec-type="additional-information"] must be present in back.</report>
      
      <report test="count(sec[@sec-type='supplementary-material']) gt 1"
        role="error"
        id="back-test-2">More than one sec[@sec-type="supplementary-material"] cannot be present in back.</report>
      
      <report test="if (($article-type != 'research-article') or ($subj-type = 'Scientific Correspondence') ) then ()
        else count(sec[@sec-type='data-availability']) != 1"
        role="error"
        id="back-test-3">One and only one sec[@sec-type="data-availability"] must be present as a child of back for '<value-of select="$article-type"/>'.</report>
      
      <report test="count(ack) gt 1"
        role="error"
        id="back-test-4">One and only one ack may be present in back.</report>
      
      <report test="if ($article-type = ('research-article','article-commentary')) then (count(ref-list) != 1)                                           else ()"
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
      
    </rule>
    
    <!-- Included as a separate rule so that it won't be flagged in features content -->
    <rule context="back/sec[@sec-type='data-availability']"
      id="data-content-tests">
      
      <assert test="count(p) gt 0"
        role="error"
        id="data-p-presence">At least one p element must be present in sec[@sec-type='data=availability'].</assert>
    </rule>
    
    <rule context="back/ack"
      id="ack-tests">
      
      <assert test="count(title) = 1"
        role="error"
        id="ack-test-1">ack must have only 1 title.</assert>
    </rule>
    
    <rule context="back/ack/*"
    id="ack-child-tests">
    
      <assert test="local-name() = ('p','sec','title')"
        role="error"
        id="ack-child-test-1">Only p, sec or title can be children of ack. <name/> is not allowed.</assert>
    </rule>
    
    <rule context="back//app"
      id="app-tests">
      
      <assert test="parent::app-group"
        role="error"
        id="app-test-1">app must be captured as a child of an app-group element.</assert>
      
      <assert test="count(title) = 1"
        role="error"
        id="app-test-2">app must have one title.</assert>
    </rule>
    
    <rule context="sec[@sec-type='additional-information']"
      id='additional-info-tests'>
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="author-count" value="count(ancestor::article//article-meta//contrib[@contrib-type='author'])"/>
      
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
        id="additional-info-test-3">This type of sec in research content must have a child fn-group[@content-type='author-contribution'].</report>
      
    </rule>
    
    <rule context="fn-group[@content-type='competing-interest']"
      id='comp-int-fn-group-tests'>
      
      <assert test="count(fn) gt 0"
        role="error"
        id="comp-int-fn-test-1">At least one child fn element should be present in fn-group[@content-type='competing-interest'].</assert>
      
      <assert test="ancestor::back"
        role="error"
        id="comp-int-fn-group-test-1">This fn-group must be a descendant of back.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='competing-interest']/fn"
      id='comp-int-fn-tests'>
      
      <assert test="@fn-type='COI-statement'"
        role="error"
        id="comp-int-fn-test-2">fn element must have an @fn-type='COI-statement' as it is a child of fn-group[@content-type='competing-interest'].</assert>
      
    </rule>
    
    <rule context="fn-group[@content-type='author-contribution']"
      id='auth-cont-tests'>
      <let name="author-count" value="count(ancestor::article//article-meta/contrib-group[1]/contrib[@contrib-type='author'])"/>
      
      <assert test="$author-count = count(fn)"
        role="warning"
        id="auth-cont-test-1">fn-group does not contain one fn for each author. Currently there are <value-of select="$author-count"/> authors but <value-of select="count(fn)"/> footnotes. Is this correct?</assert>
    </rule>
    
    <rule context="fn-group[@content-type='author-contribution']/fn"
      id='auth-cont-fn-tests'>
      
      <assert test="@fn-type='con'"
        role="error"
        id="auth-cont-fn-test-1">This fn must have an @fn-type='con'.</assert>
    </rule>
    
    <rule context="fn-group[@content-type='ethics-information']"
      id='ethics-tests'>
      
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
    
    <rule context="fn-group[@content-type='ethics-information']/fn"
      id='ethics-fn-tests'>
      
      <assert test="@fn-type='other'"
        role="error"
        id="ethics-test-4">This fn must have an @fn-type='other'</assert>
      
    </rule>
  </pattern>
  
  <pattern
    id="dec-letter-auth-response">
    
    <rule context="article/sub-article"
      id='dec-letter-reply-tests'>
      <let name='pos' value='count(parent::article/sub-article) - count(following-sibling::sub-article)'/>
      
      <assert test="if ($pos = 1) then @article-type='decision-letter'
                    else @article-type='reply'"
        role="error"
        id="dec-letter-reply-test-1">1st sub-article must be the decision letter. 2nd sub-article must be the author response.</assert>
      
      <assert test="@id = concat('sa',$pos)"
        role="error"
        id="dec-letter-reply-test-2">sub-article id must be in the format 'sa0', where '0' is it's position (1 or 2).</assert>
      
      <assert test="count(front-stub) = 1"
        role="error"
        id="dec-letter-reply-test-3">sub-article contain one and only one front-stub.</assert>
      
      <assert test="count(body) = 1"
        role="error"
        id="dec-letter-reply-test-4">sub-article contain one and only one body.</assert>
      
      <report test="matches(.,'&#x003C;[/]?[Aa]uthor response')"
        role="error"
        id="dec-letter-reply-test-5"><value-of select="@article-type"/> contains what looks like pseudo-code, search - '&#x003C;/Author response' or '&#x003C;Author response'.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub"
      id='dec-letter-front-tests'>
      <let name="count" value="count(contrib-group)"/>
      
      <assert test="count(article-id[@pub-id-type='doi']) = 1"
        role="error"
        id="dec-letter-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert test="$count gt 0"
        role="error"
        id="dec-letter-front-test-2">decision letter front-stub must contain at least 1 contrib-group element.</assert>
      
      <report test="$count gt 2"
        role="error"
        id="dec-letter-front-test-3">decision letter front-stub contains more than 2 contrib-group elements.</report>
      
      <report test="$count = 1"
        role="warning"
        id="dec-letter-front-test-4">decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviwing editor) anonymous?</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]"
      id='dec-letter-editor-tests'>
      
      <assert test="count(contrib[@contrib-type='editor']) = 1"
        role="warning"
        id="dec-letter-editor-test-1">First contrib-group in decision letter must contain 1 and only 1 editor (contrib[@contrib-type='editor']).</assert>
      
      <report test="contrib[not(@contrib-type) or @contrib-type!='editor']"
        role="warning"
        id="dec-letter-editor-test-2">First contrib-group in decision letter contains a contrib which is not marked up as an editor (contrib[@contrib-type='editor']).</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]/contrib[@contrib-type='editor']"
      id='dec-letter-editor-tests-2'>
      <let name="name" value="e:get-name(name[1])"/>
      <let name="role" value="role"/>
      <let name="top-role" value="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[e:get-name(name[1])=$name]/role"/>
      <let name="top-name" value="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[role=$role]/name[1])"/>
      
      <assert test="$role='Reviewing Editor'"
        role="error"
        id="dec-letter-editor-test-3">Editor in decision letter front-stub must have the role 'Reviewing Editor'. <value-of select="$name"/> has '<value-of select="$role"/>'.</assert>
      
      <report test="($top-name!='') and ($top-name!=$name)"
        role="error"
        id="dec-letter-editor-test-5">In decision letter <value-of select="$name"/> is a <value-of select="$role"/>, but in the top-level article details <value-of select="$top-name"/> is the <value-of select="$role"/>.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]"
      id='dec-letter-reviewer-tests'>
      
      <assert test="count(contrib[@contrib-type='reviewer']) gt 0"
        role="error"
        id="dec-letter-reviewer-test-1">Second contrib-group in decision letter must contain a reviewer (contrib[@contrib-type='reviewer']).</assert>
      
      <report test="contrib[not(@contrib-type) or @contrib-type!='reviewer']"
        role="error"
        id="dec-letter-reviewer-test-2">Second contrib-group in decision letter contains a contrib which is not marked up as a reviewer (contrib[@contrib-type='reviewer']).</report>
      
      <report test="count(contrib[@contrib-type='reviewer']) gt 3"
        role="error"
        id="dec-letter-reviewer-test-6">Second contrib-group in decision letter contains more than three reviewers.</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]/contrib[@contrib-type='reviewer']"
      id='dec-letter-reviewer-tests-2'>
      <let name="name" value="e:get-name(name[1])"/>
      
      <assert test="role='Reviewer'"
        role="error"
        id="dec-letter-reviewer-test-3">Reviewer in decision letter front-stub must have the role 'Reviewer'. <value-of select="$name"/> has '<value-of select="role"/>'.</assert>
      
      <report test="parent::contrib-group/preceding-sibling::contrib-group/contrib[e:get-name(name[1]) = $name]"
        role="error"
        id="dec-letter-reviewer-test-4"><value-of select="$name"/> is listed as both a Reviewer and a <value-of select="parent::contrib-group/preceding-sibling::contrib-group/contrib[e:get-name(name[1]) = $name][1]/role"/></report>
      
      <report test="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[e:get-name(name[1]) = $name]"
        role="error"
        id="dec-letter-reviewer-test-5"><value-of select="$name"/> is a Reviewer in the decision letter but is also present in the in the top-level article details (as a <value-of select="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[e:get-name(name[1]) = $name]/role"/>).</report>
    </rule>
    
    <rule context="sub-article[@article-type='decision-letter']/body"
      id='dec-letter-body-tests'>
      
      <assert test="child::*[1]/local-name() = 'boxed-text'"
        role="error"
        id="dec-letter-body-test-1">First child element in decision letter is not boxed-text. This is certainly incorrect.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/front-stub"
      id='reply-front-tests'>
      
      <assert test="count(article-id[@pub-id-type='doi']) = 1"
        role="error"
        id="reply-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/body"
      id='reply-body-tests'>
      
      <report test="count(disp-quote[@content-type='editor-comment']) = 0"
        role="error"
        id="reply-body-test-1">author response doesn't contain a disp-quote. This has to be incorrect.</report>
      
      <report test="count(p) = 0"
        role="error"
        id="reply-body-test-2">author response doesn't contain a p. This has to be incorrect.</report>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/body//disp-quote"
      id='reply-disp-quote-tests'>
      
      <assert test="@content-type='editor-comment'"
        role="warning"
        id="reply-disp-quote-test-1">disp-quote in author reply does not have @content-type='editor-comment'. This is almost certainly incorrect.</assert>
    </rule>
    
    <rule context="sub-article[@article-type='reply']/body//p[not(ancestor::disp-quote)]"
      id='reply-missing-disp-quote-tests'>
      <let name="free-text" value="replace(
        normalize-space(string-join(for $x in self::*/text() return $x,''))
        ,'&#x00A0;','')"/>
      
      <report test="(count(*)=1) and (child::italic) and ($free-text='')"
        role="warning"
        id="reply-missing-disp-quote-test-1">para in author response is entirely in italics, but not in a display quote. Is this a quote which has been processed incorrectly?</report>
    </rule>
  </pattern>
  
  <pattern
    id="related-articles">
    
    <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = 'Research Advance']//article-meta" 
      id="research-advance-test">
      
      <assert test="count(related-article[@related-article-type='article-reference']) gt 0"
        role="error"
        id="related-articles-test-1">Research Advance must contain an article-reference link to the original article it is building upon.</assert>
      
    </rule>
    
    <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = 'Insight']//article-meta" 
      id="insight-test">
      
      <assert test="count(related-article) gt 0"
        role="error"
        id="related-articles-test-2">Insight must contain an article-reference link to the original article it is discussing.</assert>
      
    </rule>
    
    <rule context="article[@article-type='correction']//article-meta" 
      id="correction-test">
      
      <assert test="count(related-article[@related-article-type='corrected-article']) gt 0"
        role="error"
        id="related-articles-test-8">Corrections must contain at least 1 related-article link with the attribute related-article-type='corrected-article'.</assert>
      
    </rule>
    
    <rule context="article[@article-type='retraction']//article-meta" 
      id="retraction-test">
      
      <assert test="count(related-article[@related-article-type='retracted-article']) gt 0"
        role="error"
        id="related-articles-test-9">Retractions must contain at least 1 related-article link with the attribute related-article-type='retracted-article'.</assert>
      
    </rule>
    
    <rule context="related-article" 
      id="related-articles-conformance">
      <let name="allowed-values" value="('article-reference', 'commentary', 'commentary-article', 'corrected-article', 'retracted-article')"/>
      
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
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-general-tests">
    
    <rule context="element-citation" id="elem-citation-general">
      
      <report test="descendant::etal" role="error" id="err-elem-cit-gen-name-5">[err-elem-cit-gen-name-5]
        The &lt;etal&gt; element in a reference is not allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' contains it.</report>
      
      <report test="count(year)&gt;1 " role="error" id="err-elem-cit-gen-date-1-9">[err-elem-cit-gen-date-1-9]
        There may be at most one &lt;year&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(year)"/>
        &lt;year&gt; elements.
      </report>
      
      <report test="(fpage) and not(lpage)"
        role="warning"
        id="fpage-lpage-test-1"><value-of select="e:citation-format1(year[1])"/> has a first page <value-of select="fpage"/>, but no last page. Is this correct? Should it be an elocation-id instead?</report>
      
    </rule> 
    
    <rule context="element-citation/person-group" id="elem-citation-gen-name-3-1">
      
      <report test=".[not (name or collab)]" role="error" id="err-elem-cit-gen-name-3-1">[err-elem-cit-gen-name-3-1]
        Each &lt;person-group&gt; element in a reference must contain at least one
        &lt;name&gt; or, if allowed, &lt;collab&gt; element. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not.</report>
      
    </rule>
    
    <rule context="element-citation/person-group/collab" id="elem-citation-gen-name-3-2">
      
      <assert test="count(*) = count(italic | sub | sup)" role="error" id="err-elem-cit-gen-name-3-2">[err-elem-cit-gen-name-3-2]
        A &lt;collab&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' contains addiitonal elements.</assert>
      
    </rule>
    
    <rule context="element-citation/person-group/name" id="elem-citation-gen-name-4">
      
      <assert test="not(suffix) or .[suffix=('Jnr', 'Snr', 'I', 'II', 'III', 'VI', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')] " role="error" id="err-elem-cit-gen-name-4">[err-elem-cit-gen-name-4]
        The &lt;suffix&gt; element in a reference may only contain one of the specified values
        Jnr, Snr, I, II, III, VI, V, VI, VII, VIII, IX, X.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement
        as it contains the value '<value-of select="suffix"/>'.</assert>
      
    </rule>
    
    <rule context="ref/element-citation/year" id="elem-citation-year">
      <let name="YYYY" value="substring(normalize-space(.), 1, 4)"/>
      <let name="current-year" value="year-from-date(current-date())"/>
      <let name="citation" value="e:citation-format1(self::*)"/>
      
      <assert test="matches(normalize-space(.),'(^\d{4}[a-z]?)')" role="error" id="err-elem-cit-gen-date-1-1">[err-elem-cit-gen-date-1-1]
        The &lt;year&gt; element in a reference must contain 4 digits, possibly followed by one (and only one) lower-case letter.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="(1700 le number($YYYY)) and (number($YYYY) le ($current-year + 5))" role="warning" id="err-elem-cit-gen-date-1-2">[err-elem-cit-gen-date-1-2]
        The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive).
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="./@iso-8601-date" role="error" id="err-elem-cit-gen-date-1-3">[err-elem-cit-gen-date-1-3]
        All &lt;year&gt; elements must have @iso-8601-date attributes.
        Reference '<value-of select="ancestor::ref/@id"/>' does not.
      </assert>
      
      <assert test="not(./@iso-8601-date) or (1700 le number(substring(normalize-space(@iso-8601-date),1,4)) and number(substring(normalize-space(@iso-8601-date),1,4)) le ($current-year + 5))" role="warning" id="err-elem-cit-gen-date-1-4">[err-elem-cit-gen-date-1-4]
        The numeric value of the first 4 digits of the @iso-8601-date attribute on the &lt;year&gt; element must be between 
        1700 and the current year + 5 years (inclusive).
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the attribute contains the value 
        '<value-of select="./@iso-8601-date"/>'.
      </assert>
      
      <assert test="not(./@iso-8601-date) or substring(normalize-space(./@iso-8601-date),1,4) = $YYYY" role="error" id="err-elem-cit-gen-date-1-5">[err-elem-cit-gen-date-1-5]
        The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the 
        &lt;year&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the element contains
        the value '<value-of select="."/>' and the attribute contains the value 
        '<value-of select="./@iso-8601-date"/>'.
      </assert>
      
      <assert test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and        (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,'b'))        and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname       or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]       )))" role="error" id="err-elem-cit-gen-date-1-6">[err-elem-cit-gen-date-1-6]
        If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with 
        the same first author surname (or collab) with a letter "b" after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <assert test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or       (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',       'abcdefghijklmnopqrstuvwxy')))        and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname       or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]       ))" role="error" id="err-elem-cit-gen-date-1-7">[err-elem-cit-gen-date-1-7]
        If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another 
        reference with the same first author surname (or collab) with the preceding letter after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <report test="some $x in (preceding::year[ancestor::ref-list])       satisfies  e:citation-format1($x) = $citation" role="error" id="err-elem-cit-gen-date-1-8">[err-elem-cit-gen-date-1-8]
        Letter suffixes must be unique for the combination of year and author information. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement as it 
        contains the &lt;year&gt; '<value-of select="."/>' for the author information
        '<value-of select="e:stripDiacritics(ancestor::element-citation/person-group[1]/name[1]/surname)"/>', which occurs in at least one other reference.</report>
      
    </rule>
    
    <rule context="ref/element-citation/source" 
      id="elem-citation-source">
      
      <assert test="string-length(normalize-space(.)) ge 2" 
        role="error" 
        id="elem-cit-source">A  &lt;source&gt; element within a <value-of select="parent::element-citation/@publication-type"/> type &lt;element-citation&gt; must contain at least two characters. - <value-of select="."/>. See Ref '<value-of select="ancestor::ref/@id"/>'.</assert>
      
    </rule>
    
    <rule context="ref/element-citation/ext-link" 
      id="elem-citation-ext-link">
      
      <assert test="(normalize-space(@xlink:href)=normalize-space(.)) and (normalize-space(.)!='')" 
        role="error" 
        id="ext-link-attribute-content-match">&lt;ext-link&gt; must contain content and have an @xlink:href, the value of which must be the same as the content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
      <assert test="matches(@xlink:href,'^https?://|^ftp://')" 
        role="error" id="link-href-conformance">@xlink:href must start with either "http://", "https://",  or "ftp://". The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' is '<value-of select="@xlink:href"/>', which does not.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-high-tests">
    
    <rule context="ref" id="ref">
      <let name="pre-name" value="lower-case(if (local-name(element-citation/person-group[1]/*[1])='name')       then (element-citation/person-group[1]/name[1]/surname[1])       else (element-citation/person-group[1]/*[1]))"/>
      <let name="name" value="e:stripDiacritics($pre-name)"/>
      
      <let name="pre-name2" value="lower-case(if (local-name(element-citation/person-group[1]/*[2])='name')       then (element-citation/person-group[1]/*[2]/surname[1])       else (element-citation/person-group[1]/*[2]))"/>
      <let name="name2" value="e:stripDiacritics($pre-name2)"/>
      
      <let name="pre-preceding-name" value="lower-case(if (preceding-sibling::ref[1] and       local-name(preceding-sibling::ref[1]/element-citation/person-group[1]/*[1])='name')       then (preceding-sibling::ref[1]/element-citation/person-group[1]/name[1]/surname[1])       else (preceding-sibling::ref[1]/element-citation/person-group[1]/*[1]))"/>
      <let name="preceding-name" value="e:stripDiacritics($pre-preceding-name)"/>
      
      <let name="pre-preceding-name2" value="lower-case(if (preceding-sibling::ref[1] and       local-name(preceding-sibling::ref[1]/element-citation/person-group[1]/*[2])='name')       then (preceding-sibling::ref[1]/element-citation/person-group[1]/*[2]/surname[1])       else (preceding-sibling::ref[1]/element-citation/person-group[1]/*[2]))"/>
      <let name="preceding-name2" value="e:stripDiacritics($pre-preceding-name2)"/>
      
      <assert test="count(*) = count(element-citation)" role="error" id="err-elem-cit-high-1">[err-elem-cit-high-1]
        The only element that is allowed as a child of &lt;ref&gt; is
        &lt;element-citation&gt;. 
        Reference '<value-of select="@id"/>' has other elements.
      </assert>
      
      <!-- else:
       -->
      
      <assert test="if (count(element-citation/person-group[1]/*) != 2)       then (count(preceding-sibling::ref) = 0 or        ($name &gt; $preceding-name) or       ($name = $preceding-name and       element-citation/year &gt;= preceding-sibling::ref[1]/element-citation/year))       else (count(preceding-sibling::ref) = 0        or ($name &gt; $preceding-name) or       ($name = $preceding-name and $name2 &gt; $preceding-name2)        or        ($name = $preceding-name and $name2 = $preceding-name2 and       element-citation/year &gt;= preceding-sibling::ref[1]/element-citation/year)       or       ($name = $preceding-name and       count(preceding-sibling::ref[1]/element-citation/person-group[1]/*) !=2)       )" role="error" id="err-elem-cit-high-2-2">[err-elem-cit-high-2-2]
        The order of &lt;element-citation&gt;s in the reference list should be name and date, arranged alphabetically 
        by the first author’s surname, or by the value of the first &lt;collab&gt; element. In the case of
        two authors, the sequence should be arranged by both authors' surnames, then date. For
        three or more authors, the sequence should be the first author's surname, then date.
        Reference '<value-of select="@id"/>' appears to be in a different order.
      </assert>
      
      <assert test="@id" role="error" id="err-elem-cit-high-3-1">[err-elem-cit-high-3-1]
        Each &lt;ref&gt; element must have an @id attribute. 
      </assert>
      
      <assert test="matches(normalize-space(@id) ,'^bib\d+$')" role="error" id="err-elem-cit-high-3-2">[err-elem-cit-high-3-2]
        Each &lt;ref&gt; element must have an @id attribute that starts with 'bib' and ends with 
        a number. 
        Reference '<value-of select="@id"/>' has the value 
        '<value-of select="@id"/>', which is incorrect.
      </assert>
      
      <assert test="count(preceding-sibling::ref)=0 or number(substring(@id,4)) gt number(substring(preceding-sibling::ref[1]/@id,4))" role="error" id="err-elem-cit-high-3-3">[err-elem-cit-high-3-3]
        The sequence of ids in the &lt;ref&gt; elements must increase monotonically
        (e.g. 1,2,3,4,5, . . . ,50,51,52,53, . . . etc).
        Reference '<value-of select="@id"/>' has the value 
        '<value-of select="@id"/>', which does not fit this pattern.
      </assert>
      
      <let name="year-comma" value="', \d{4}\w?$'"/>
      <let name="year-paren" value="' \(\d{4}\w?\)$'"/>
      
      <!-- The following is dealt with in test ref-xref-conformity
        <assert test="every $x in //xref[@rid=current()/@id]       satisfies (       if (count(current()/element-citation/person-group[1]/(name | collab))=1)        then (       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/name/surname, $year-comma))       or       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/name/surname, $year-paren))       or       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/collab, $year-comma))       or       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/collab, $year-paren))       )       else        if (count(current()/element-citation/person-group[1]/(name|collab))=2)        then (       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/name[2]/surname, $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/name[2]/surname, $year-paren))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/collab[1], $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/collab[1], $year-paren))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/name[1]/surname, $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/name[1]/surname, $year-paren))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/collab[2], $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/collab[2], $year-paren))       )       else        if (count(current()/element-citation/person-group[1]/(name|collab))&gt;2)        then (if (local-name(current()/element-citation/person-group[1]/*[1])='name')             then (matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,             ' et al.', $year-comma))             or             matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,             ' et al.', $year-paren)))             else (matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],             ' et al.', $year-comma))             or             matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],             ' et al.', $year-paren)))       )          else ()       )" role="error" id="err-elem-cit-high-4">
        <value-of select="$name"/> and  <value-of select="$name2"/> 
        [err-elem-cit-high-4]
             <let name="name" value="lower-case(if (local-name(element-citation/person-group[1]/*[1])='name')
      then (element-citation/person-group[1]/name[1]/surname)
      else (element-citation/person-group[1]/*[1]))"/>
    <let name="name2" value="lower-case(if (local-name(element-citation/person-group[1]/*[2])='name')
      then (element-citation/person-group[1]/*[2]/surname)
      else (element-citation/person-group[1]/*[2]))"/> 
        If an element-citation/person-group contains one &lt;name&gt;, 
        the content of the &lt;surname&gt; inside that name must appear in the 
        content of all &lt;xref&gt;s that point to the &lt;element-citation&gt;. 
        If an element-citation/person-group contains 2 &lt;name&gt;s, the content 
        of the first &lt;surname&gt; of the first &lt;name&gt;, followed by the string “ and “, 
        followed by the content of the &lt;surname&gt; of the second &lt;name&gt; must appear 
        in the content of all &lt;xref&gt;s that point to the &lt;element-citation&gt;. 
        If there are more than 2 &lt;name&gt;s in the &lt;person-group&gt;, all &lt;xref&gt;s that 
        point to that reference must contain the content of only the first 
        of the &lt;surname&gt;s, followed by the text "et al."
        All of these are followed by ', ' and the year, or by the year in parentheses.
        There are <value-of select="count(//xref[@rid=current()/@id]/@rid)"/> &lt;xref&gt; references 
        with @rid = <value-of select="@id"/> to be checked. The first name should be 
        '<value-of select="element-citation/person-group[1]/(name[1]/surname | collab[1])[1]"/>'.
      </assert>-->
      
      <!-- The following is dealt with in test ref-xref-conformity
        
        If there is more than one year (caught by a different test), use the first year to compare. 
      <assert test="every $x in //xref[@rid=current()/@id]       satisfies (matches(replace($x,'\p{Zs}',' '), concat(', ',current()/element-citation/year[1]),'s') or       matches(replace($x,'\p{Zs}',' '), concat('\(',current()/element-citation/year[1],'\)')))" role="error" id="err-elem-cit-high-5">[err-elem-cit-high-5]
        All xrefs to &lt;ref&gt;s, which contain &lt;element-citation&gt;s, should contain, as the last part 
        of their content, the string ", " followed by the content of the year element in the 
        &lt;element-citation&gt;, or the year in parentheses. 
        There is an incorrect &lt;xref&gt; with @rid <value-of select="@id"/>. It should contain the string 
        ', <value-of select="element-citation/year"/>' or the string 
        '(<value-of select="element-citation/year"/>)' but does not.
        There are <value-of select="count(//xref[@rid=current()/@id]/@rid)"/> references to be checked.
      </assert> -->
      
    </rule>
    
    <rule context="xref[@ref-type='bibr']" id="xref">
      
      <assert test="not(matches(substring(normalize-space(.),string-length(.)),'[b-z]')) or        (some $x in preceding::xref       satisfies (substring(normalize-space(.),string-length(.)) gt substring(normalize-space($x),string-length(.))))" role="error" id="err-xref-high-2-1">[err-xref-high-2-1]
        Citations in the text to references with the same author(s) in the same year must be arranged in the same 
        order as the reference list. The xref with the value '<value-of select="."/>' is in the wrong order in the 
        text. Check all the references to citations for the same authors to determine which need to be changed.
      </assert>
      
    </rule>
    
    <rule context="element-citation" id="elem-citation">
      
      <assert test="@publication-type" role="error" id="err-elem-cit-high-6-1">[err-elem-cit-high-6-1]
        The element-citation element must have a publication-type attribute.
        Reference '<value-of select="../@id"/>' does not.
      </assert>
      
      <assert test="@publication-type = 'journal' or                     @publication-type = 'book'    or                     @publication-type = 'data'    or                     @publication-type = 'patent'    or                     @publication-type = 'software'    or                     @publication-type = 'preprint' or                     @publication-type = 'web'    or                     @publication-type = 'periodical' or                     @publication-type = 'report'    or                     @publication-type = 'confproc'    or                     @publication-type = 'thesis'" role="error" id="err-elem-cit-high-6-2">[err-elem-cit-high-6-2]
        The publication-type attribute may only take the values 'journal', 'book', 'data', 
        'patent', 'software', 'preprint', 'web', 
        'periodical', 'report', 'confproc', or 'thesis'. 
        Reference '<value-of select="../@id"/>' has the publication-type 
        '<value-of select="@publication-type"/>'.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-journal-tests">
    <rule context="element-citation[@publication-type='journal']" id="elem-citation-journal">
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-journal-2-1">[err-elem-cit-journal-2-1]
        Each  &lt;element-citation&gt; of type 'journal' must contain one and
        only one &lt;person-group&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="person-group[@person-group-type='author']" role="error" id="err-elem-cit-journal-2-2">[err-elem-cit-journal-2-2]
        Each  &lt;element-citation&gt; of type 'journal' must contain one &lt;person-group&gt; 
        with the attribute person-group-type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a  &lt;person-group&gt; type of 
        '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      <assert test="count(article-title)=1" role="error" id="err-elem-cit-journal-3-1">[err-elem-cit-journal-3-1]
        Each  &lt;element-citation&gt; of type 'journal' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source)=1" role="error" id="err-elem-cit-journal-4-1">[err-elem-cit-journal-4-1]
        Each  &lt;element-citation&gt; of type 'journal' must contain one and
        only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-journal-4-2-1">[err-elem-cit-journal-4-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(source)=1 and count(source/*)=0" role="error" id="err-elem-cit-journal-4-2-2">[err-elem-cit-journal-4-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' may not contain child 
        elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
      <assert test="count(volume) le 1" role="error" id="err-elem-cit-journal-5-1-3">[err-elem-cit-journal-5-1-3]
        There may be no more than one  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal'.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(volume)"/>
        &lt;volume&gt; elements.</assert>
      
      <!-- This doesn't work and the check is covered by eloc-page-assert (with a more human readable error message)
        
        <assert test="(count(fpage) eq 1) or (count(elocation-id) eq 1) or (count(comment/text()='In press') eq 1)" role="warning" id="warning-elem-cit-journal-6-1">[warning-elem-cit-journal-6-1]
        One of &lt;fpage&gt;, &lt;elocation-id&gt;, or &lt;comment&gt;In press&lt;/comment&gt; should be present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has missing page or elocation information.</assert>-->
      
      <report test="lpage and not(fpage)" role="error" id="err-elem-cit-journal-6-5-1">[err-elem-cit-journal-6-5-1]
        &lt;lpage&gt; is only allowed if &lt;fpage&gt; is present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; but no &lt;fpage&gt;.</report>
      
      <report test="lpage and (number(fpage[1]) &gt;= number(lpage[1]))" role="error" id="err-elem-cit-journal-6-5-2">[err-elem-cit-journal-6-5-2]
        &lt;lpage&gt; must be larger than &lt;fpage&gt;, if present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has first page &lt;fpage&gt; = '<value-of select="fpage"/>' 
        but last page &lt;lpage&gt; = '<value-of select="lpage"/>'.</report>
      
      <report test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1 or count(comment) gt 1" role="error" id="err-elem-cit-journal-6-7">[err-elem-cit-journal-6-7]
        The following elements may not occur more than once in an &lt;element-citation&gt;: &lt;fpage&gt;, &lt;lpage&gt;, 
        &lt;elocation-id&gt;, and &lt;comment&gt;In press&lt;/comment&gt;. 
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(fpage)"/> &lt;fpage&gt;, <value-of select="count(lpage)"/> &lt;lpage&gt;,
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt;, and 
        <value-of select="count(comment)"/> &lt;comment&gt; elements.</report>
      
      <assert test="count(*) = count(person-group| year| article-title| source| volume| fpage| lpage| elocation-id| comment| pub-id)" role="error" id="err-elem-cit-journal-12">[err-elem-cit-journal-12]
        The only elements allowed as children of &lt;element-citation&gt; with the publication-type="journal" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;volume&gt;, &lt;fpage&gt;, &lt;lpage&gt;, 
        &lt;elocation-id&gt;, &lt;comment&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/article-title" id="elem-citation-journal-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-journal-3-2">[err-elem-cit-journal-3-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/volume" id="elem-citation-journal-volume">
      <assert test="count(*)=0 and (string-length(text()) ge 1)" role="error" id="err-elem-cit-journal-5-1-2">[err-elem-cit-journal-5-1-2]
        A  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal' must contain 
        at least one character and may not contain child elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters and/or
        child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/fpage" id="elem-citation-journal-fpage">
      
      <assert test="count(../elocation-id) eq 0 and count(../comment) eq 0" role="error" id="err-elem-cit-journal-6-2">[err-elem-cit-journal-6-2]
        If &lt;fpage&gt; is present, neither &lt;elocation-id&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt; and one of those elements.</assert>
      
      <assert test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage[1]),1,1) = substring(normalize-space(.),1,1)) or count(../lpage) eq 0" role="error" id="err-elem-cit-journal-6-6">[err-elem-cit-journal-6-6]
        If the content of &lt;fpage&gt; begins with a letter, then the content of  &lt;lpage&gt; must begin with 
        the same letter. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/elocation-id" id="elem-citation-journal-elocation-id">
      
      <assert test="count(../fpage) eq 0 and count(../comment) eq 0" role="error" id="err-elem-cit-journal-6-3">[err-elem-cit-journal-6-3]
        If &lt;elocation-id&gt; is present, neither &lt;fpage&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;elocation-id&gt; and one of those elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/comment" id="elem-citation-journal-comment">
      
      <assert test="count(../fpage) eq 0 and count(../elocation-id) eq 0" role="error" id="err-elem-cit-journal-6-4">[err-elem-cit-journal-6-4]
        If &lt;comment&gt;In press&lt;/comment&gt; is present, neither &lt;fpage&gt; nor &lt;elocation-id&gt; may be present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has one of those elements.</assert>
      
      <assert test="text() = 'In press'" role="error" id="err-elem-cit-journal-13">[err-elem-cit-journal-13] 
        Comment elements with content other than 'In press' are not allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has such a &lt;comment&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/pub-id[@pub-id-type='pmid']" id="elem-citation-journal-pub-id-pmid">
      
      <report test="matches(.,'\D')" role="error" id="err-elem-cit-journal-10">[err-elem-cit-journal-10]
        If &lt;pub-id pub-id-type="pmid"&gt; is present, the content must be all numeric.
        The content of &lt;pub-id pub-id-type="pmid"&gt; in Reference '<value-of select="ancestor::ref/@id"/>' 
        is <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/pub-id" id="elem-citation-journal-pub-id">
      
      <assert test="@pub-id-type='doi' or @pub-id-type='pmid'" role="error" id="err-elem-cit-journal-9-1">[err-elem-cit-journal-9-1]
        Each &lt;pub-id&gt;, if present in a journal reference, must have a @pub-id-type of either "doi" or "pmid".
        The pub-id-type attribute on &lt;pub-id&gt; in Reference '<value-of select="ancestor::ref/@id"/>' 
        is <value-of select="@pub-id-type"/>.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-book-tests">
    <rule context="element-citation[@publication-type='book']" id="elem-citation-book">
      <let name="publisher-locations" value="'publisher-locations.xml'"/>
      
      <assert test="(count(person-group[@person-group-type='author']) + count(person-group[@person-group-type='editor'])) = count(person-group)" role="error" id="err-elem-cit-book-2-2">[err-elem-cit-book-2-2]
        The only values allowed for @person-group-type in book references are "author" and "editor".
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; type of 
        '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      <assert test="count(person-group)=1 or (count(person-group[@person-group-type='author'])=1 and count(person-group[@person-group-type='editor'])=1)" role="error" id="err-elem-cit-book-2-3">[err-elem-cit-book-2-3]
        In a book reference, there should be a single person-group element (either author or editor) or
        one person-group with @person-group-type="author" and one person-group with @person-group-type=editor.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(source)=1" role="error" id="err-elem-cit-book-10-1">[err-elem-book-book-10-1]
        Each  &lt;element-citation&gt; of type 'book' must contain one and
        only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-book-10-2-1">[err-elem-cit-book-10-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'book' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" role="error" id="err-elem-cit-book-10-2-2">[err-elem-cit-book-10-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'book' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
      <assert test="count(publisher-name)=1" role="error" id="err-elem-cit-book-13-1">[err-elem-cit-book-13-1]
        One and only one &lt;publisher-name&gt; is required in a book reference.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/>
        &lt;publisher-name&gt; elements.</assert>
      
      <report test="some $p in document($publisher-locations)/locations/location/text()       satisfies ends-with(publisher-name[1],$p)" role="warning" id="warning-elem-cit-book-13-3">[warning-elem-cit-book-13-3]
        The content of &lt;publisher-name&gt; may not end with a publisher location. 
        Reference '<value-of select="ancestor::ref/@id"/>' contains the string <value-of select="publisher-name"/>,
        which ends with a publisher location.</report>
      
      <report test="(lpage or fpage) and not(chapter-title)" role="error" id="err-elem-cit-book-16">[err-elem-cit-book-16]
        In a book reference, &lt;lpage&gt; and &lt;fpage&gt; are allowed only if &lt;chapter-title&gt; is present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; or &lt;fpage&gt; but no &lt;chapter-title&gt;.</report>
      
      <report test="(lpage and fpage) and (number(fpage[1]) &gt;= number(lpage[1]))" role="error" id="err-elem-cit-book-36">[err-elem-cit-book-36-1]
        If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is 
        less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <report test="lpage and not (fpage)" role="error" id="err-elem-cit-book-36-2">[err-elem-cit-book-36-2]
        If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; but not &lt;fpage&gt;.</report>
      
      <report test="count(lpage) &gt; 1 or count(fpage) &gt; 1" role="error" id="err-elem-cit-book-36-6">[err-elem-cit-book-36-6]
        At most one &lt;lpage&gt; and one &lt;fpage&gt; are allowed. 
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(lpage)"/> &lt;lpage&gt; 
        elements and <value-of select="count(fpage)"/> &lt;fpage&gt; elements.</report>
      
      <assert test="count(*) = count(person-group| year| source| chapter-title| publisher-loc|publisher-name|volume|        edition| fpage| lpage| pub-id)" role="error" id="err-elem-cit-book-40">[err-elem-cit-book-40]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="book" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;chapter-title&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, 
        &lt;volume&gt;, &lt;edition&gt;, &lt;fpage&gt;, &lt;lpage&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/person-group" id="elem-citation-book-person-group">
      <assert test="@person-group-type" role="error" id="err-elem-cit-book-2-1">[err-elem-cit-book-2-1]
        Each &lt;person-group&gt; must have a @person-group-type attribute.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with no @person-group-type attribute.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='book']/chapter-title" id="elem-citation-book-chapter-title">
      
      <assert test="count(../person-group[@person-group-type='author'])=1" role="error" id="err-elem-cit-book-22">[err-elem-cit-book-22]
        If there is a &lt;chapter-title&gt; element there must be one and only one &lt;person-group person-group-type="author"&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
      <assert test="count(../person-group[@person-group-type='editor']) le 1" role="error" id="err-elem-cit-book-28-1">[err-elem-cit-book-28-1]
        If there is a &lt;chapter-title&gt; element there may be a maximum of one &lt;person-group person-group-type="editor"&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
      <assert test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-book-31">[err-elem-cit-book-31]
        A &lt;chapter-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/publisher-name" id="elem-citation-book-publisher-name">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-book-13-2">[err-elem-cit-book-13-2]
        No elements are allowed inside &lt;publisher-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/edition" id="elem-citation-book-edition">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-book-15">[err-elem-cit-book-15]
        No elements are allowed inside &lt;edition&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;edition&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/pub-id[@pub-id-type='pmid']" id="elem-citation-book-pub-id-pmid">
      
      <report test="matches(.,'\D')" role="error" id="err-elem-cit-book-18">[err-elem-cit-book-18]
        If &lt;pub-id pub-id-type="pmid"&gt; is present, the content must be all numeric. The content of 
        &lt;pub-id pub-id-type="pmid"&gt; in Reference '<value-of select="ancestor::ref/@id"/>' 
        is <value-of select="."/>.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='book']/pub-id" id="elem-citation-book-pub-id">
      
      <assert test="@pub-id-type='doi' or @pub-id-type='pmid' or @pub-id-type='isbn'" role="error" id="err-elem-cit-book-17">[err-elem-cit-book-17]
        Each &lt;pub-id&gt;, if present in a book reference, must have a @pub-id-type of one of these values: doi, pmid, isbn. 
        The pub-id-type attribute on &lt;pub-id&gt; in Reference '<value-of select="ancestor::ref/@id"/>' 
        is <value-of select="@pub-id-type"/>.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-data-tests">
    <rule context="element-citation[@publication-type='data']" id="elem-citation-data">
      
      <assert test="count(person-group[@person-group-type='author']) le 1 and       count(person-group[@person-group-type='compiler']) le 1 and       count(person-group[@person-group-type='curator']) le 1" role="error" id="err-elem-cit-data-3-1">[err-elem-cit-data-3-1]
        Only one person-group of each type (author, compiler, curator) is allowed. 
        Reference 
        '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group[@person-group-type='author'])"/>  &lt;person-group&gt; elements of type of 
        'author', <value-of select="count(person-group[@person-group-type='author'])"/>  &lt;person-group&gt; elements of type of 
        'compiler', <value-of select="count(person-group[@person-group-type='author'])"/>  &lt;person-group&gt; elements of type of 
        'curator', and <value-of select="count(person-group[@person-group-type!='author' and @person-group-type!='compiler' and @person-group-type!='curator'])"/>
        &lt;person-group&gt; elements of some other type.</assert>
      
      <assert test="count(person-group) ge 1" role="error" id="err-elem-cit-data-3-2">[err-elem-cit-data-3-2]
        Each  &lt;element-citation&gt; of type 'data' must contain at least one &lt;person-group&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(data-title)=1" role="error" id="err-elem-cit-data-10">[err-elem-cit-data-10]
        Each  &lt;element-citation&gt; of type 'data' must contain one and only one &lt;data-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(data-title)"/> &lt;data-title&gt; elements.</assert>
      
      <assert test="count(source)=1" role="error" id="err-elem-cit-data-11-2">[err-elem-cit-data-11-2]
        Each  &lt;element-citation&gt; of type 'data' must contain one and only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-data-11-3-1">[err-elem-cit-data-11-3-1]
        A &lt;source&gt; element within a &lt;element-citation&gt; of type 'data' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" role="error" id="err-elem-cit-data-11-3-2">[err-elem-cit-data-11-3-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'data' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
      <assert test="pub-id or ext-link" role="error" id="err-elem-cit-data-13-1">[err-elem-cit-data-13-1]
        There must be at least one pub-id OR an &lt;ext-link&gt;. There may be more than one pub-id.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id elements
        and <value-of select="count(ext-link)"/>  &lt;ext-link&gt; elements.</assert>
      
      <assert test="count(pub-id) ge 1 or count(ext-link) ge 1" role="error" id="err-elem-cit-data-17-1">[err-elem-cit-data-17-1]
        The &lt;ext-link&gt; element is required if there is no &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements
        and <value-of select="count(ext-link)"/>  &lt;ext-link&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group| data-title| source| year| pub-id| version| ext-link)" role="error" id="err-elem-cit-data-18">[err-elem-cit-data-18]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="data" are:
        &lt;person-group&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, &lt;version&gt;, and &lt;ext-link&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='data']/pub-id[@pub-id-type='doi']" id="elem-citation-data-pub-id-doi">
      
      <assert test="not(@xlink:href)" role="error" id="err-elem-cit-data-14-2">[err-elem-cit-data-14-2]
        If the pub-id is of pub-id-type doi, it may not have an @xlink:href.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with type doi and an
        @link-href with value '<value-of select="@link-href"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='data']/pub-id" id="elem-citation-data-pub-id">
      
      <assert test="@pub-id-type=('accession', 'archive', 'ark', 'doi')" role="error" id="err-elem-cit-data-13-2">[err-elem-cit-data-13-2]
        Each pub-id element must have one of these types: accession, archive, ark, assigning-authority or doi. 
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with types 
        '<value-of select="@pub-id-type"/>'.</assert>
      
      <report test="if (@pub-id-type != 'doi') then not(@xlink:href) else ()" role="error" id="err-elem-cit-data-14-1">[err-elem-cit-data-14-1]
        If the pub-id is of any pub-id-type except doi, it must have an @xlink:href. 
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;pub-id element with type 
        '<value-of select="@pub-id-type"/>' but no @xlink-href.</report>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type='data']/ext-link" id="elem-citation-data-ext-link"> 
    
      <assert test="@xlink:href" role="error" id="err-elem-cit-data-17-2">[err-elem-cit-data-17-2]
        Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        does not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-data-17-3">[err-elem-cit-data-17-3]
        The value of @xlink:href must start with either "http://" or "https://". 
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        is '<value-of select="@xlink:href"/>', which does not.</assert>  
        
      <assert test="normalize-space(@xlink:href)=normalize-space(.)" role="error" id="err-elem-cit-data-17-4">[err-elem-cit-data-17-4]
        The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
  </pattern>
  
  <pattern id="element-citation-patent-tests">
    <rule context="element-citation[@publication-type='patent']" id="elem-citation-patent">
      
      <assert test="count(person-group[@person-group-type='inventor'])=1" role="error" id="err-elem-cit-patent-2-1">[err-elem-cit-patent-2-1]
        There must be one person-group with @person-group-type="inventor". 
        Reference '<value-of select="ancestor::ref/@id"/>' has
        <value-of select="count(person-group[@person-group-type='inventor'])"/> &lt;person-group&gt; 
        elements of type 'inventor'.</assert>
      
      <assert test="every $type in person-group/@person-group-type       satisfies $type = ('assignee','inventor')" role="error" id="err-elem-cit-patent-2-3">[err-elem-cit-patent-2-3]
        The only allowed types of person-group elements are "assignee" and "inventor".
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;person-group&gt; elements of other types.</assert>
      
      <assert test="count(person-group[@person-group-type='assignee']) le 1" role="error" id="err-elem-cit-patent-2A">[err-elem-cit-patent-2A]
        There may be zero or one person-group elements with @person-group-type="assignee" 
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group[@person-group-type='assignee'])"/> &lt;person-group&gt; elements of type
        'assignee'.</assert>
      
      <assert test="count(article-title)=1" role="error" id="err-elem-cit-patent-8-1">[err-elem-cit-patent-8-1]
        Each  &lt;element-citation&gt; of type 'patent' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source) le 1" role="error" id="err-elem-cit-patent-9-1">[err-elem-cit-patent-9-1]
        Each  &lt;element-citation&gt; of type 'patent' may contain zero or one &lt;source&gt; elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="patent" role="error" id="err-elem-cit-patent-10-1-1">[err-elem-cit-patent-10-1-1]
        The  &lt;patent&gt; element is required. 
        Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;patent&gt; elements.</assert>
      
      <assert test="ext-link" role="error" id="err-elem-cit-patent-11-1">[err-elem-cit-patent-11-1]
        The &lt;ext-link&gt; element is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has no &lt;ext-link&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group| article-title| source| year| patent| ext-link)" role="error" id="err-elem-cit-patent-18">[err-elem-cit-patent-18]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="patent" are:
        &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;patent&gt;, and &lt;ext-link&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type='patent']/ext-link" id="elem-citation-patent-ext-link"> 
    
      <assert test="@xlink:href" role="error" id="err-elem-cit-patent-11-2">[err-elem-cit-patent-11-2]
        Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        does not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-patent-11-3">[err-elem-cit-patent-11-3]
        The value of @xlink:href must start with either "http://" or "https://". 
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        is '<value-of select="@xlink:href"/>', which does not.</assert>  
        
      <assert test="normalize-space(@xlink:href)=normalize-space(.)" role="error" id="err-elem-cit-patent-11-4">[err-elem-cit-patent-11-4]
        The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
    
    <rule context="element-citation[@publication-type='patent']/article-title" id="elem-citation-patent-article-title"> 
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-patent-8-2-1">[err-elem-cit-patent-8-2-1]
        A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-patent-8-2-2">[err-elem-cit-patent-8-2-2]
        A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='patent']/source" id="elem-citation-patent-source"> 
      
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-patent-9-2-1">[err-elem-cit-patent-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'patent' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-patent-9-2-2">[err-elem-cit-patent-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='patent']/patent" id="elem-citation-patent-patent"> 
      <let name="countries" value="'countries.xml'"/>
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-patent-10-1-2">[err-elem-cit-patent-10-1-2]
        The  &lt;patent&gt; element may not have child elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements.</assert>
      
      <assert test="some $x in document($countries)/countries/country satisfies ($x=@country)" role="error" id="err-elem-cit-patent-10-2">[err-elem-cit-patent-10-2]
        The &lt;patent> element must have a country attribute, the value of which must be an allowed value.
        Reference '<value-of select="ancestor::ref/@id"/>' has a patent/@country attribute with the value 
        '<value-of select="@country"/>', which is not in the list.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-software-tests">
    <rule context="element-citation[@publication-type = 'software']" id="elem-citation-software">
      <let name="person-count" value="count(person-group[@person-group-type='author']) + count(person-group[@person-group-type='curator'])"/>
      
      <assert test="$person-count = (1,2)" role="error" id="err-elem-cit-software-2-1">[err-elem-cit-software-2-1] Each
        &lt;element-citation&gt; of type 'software' must contain one &lt;person-group&gt; element (either
        author or curator) or one &lt;person-group&gt; with attribute person-group-type = author and one
        &lt;person-group&gt; with attribute person-group-type = curator. Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(person-group)"/>
        &lt;person-group&gt; elements.</assert>
      
      <assert test="person-group[@person-group-type = ('author', 'curator')]" role="error" id="err-elem-cit-software-2-2">[err-elem-cit-software-2-2] Each &lt;element-citation&gt; of type
        'software' must contain one &lt;person-group&gt; with the attribute person-group-type set to
        'author'or 'curator'. Reference '<value-of select="ancestor::ref/@id"/>' has a
        &lt;person-group&gt; type of '<value-of select="person-group/@person-group-type"/>'.</assert>
      
      <report test="count(data-title) &gt; 1" role="error" id="err-elem-cit-software-10-1">[err-elem-cit-software-10-1] Each &lt;element-citation&gt; of type 'software' may contain one
        and only one &lt;data-title&gt; element. Reference '<value-of select="ancestor::ref/@id"/>'
        has <value-of select="count(data-title)"/> &lt;data-title&gt; elements.</report>
      
      <assert test="count(*) = count(person-group | year | data-title | source | version | publisher-name | publisher-loc | ext-link)" role="error" id="err-elem-cit-software-16">[err-elem-cit-software-16] The only tags that are
        allowed as children of &lt;element-citation&gt; with the publication-type="software" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;version&gt;, &lt;publisher-name&gt;,
        &lt;publisher-loc&gt;, and &lt;ext-link&gt; Reference '<value-of select="ancestor::ref/@id"/>'
        has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type = 'software']/data-title" id="elem-citation-software-data-title">
      
      <assert test="count(*) = count(sub | sup | italic)" role="error" id="err-elem-cit-software-10-2">[err-elem-cit-software-10-2] An &lt;data-title&gt; element in a reference may contain characters
        and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference
        '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type = 'software']/ext-link" id="elem-citation-software-ext-link">
    
      <assert test="@xlink:href" role="error" id="err-elem-cit-software-15-1">[err-elem-cit-software-15-1] Each &lt;ext-link&gt; element must contain @xlink:href. The
        &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' does
        not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-software-15-2">[err-elem-cit-software-15-2] The value of
        @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in
        Reference '<value-of select="ancestor::ref/@id"/>' is '<value-of select="@xlink:href"/>', which does not.</assert>
        
      <assert test="normalize-space(@xlink:href) = normalize-space(.)" role="error" id="err-elem-cit-software-15-3">[err-elem-cit-software-15-3] The value of @xlink:href must be
        the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference
        '<value-of select="ancestor::ref/@id"/>' has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
  </pattern>
  
  <pattern id="element-citation-preprint-tests">
    <rule context="element-citation[@publication-type='preprint']" id="elem-citation-preprint">
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-preprint-2-1">[err-elem-cit-preprint-2-1]
        There must be one and only one person-group. 
        Reference '<value-of select="ancestor::ref/@id"/>' has
        <value-of select="count(person-group)"/> &lt;person-group&gt; 
        elements.</assert>
      
      <assert test="count(article-title)=1" role="error" id="err-elem-cit-preprint-8-1">[err-elem-cit-preprint-8-1]
        Each  &lt;element-citation&gt; of type 'preprint' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source) = 1" role="error" id="err-elem-cit-preprint-9-1">[err-elem-cit-preprint-9-1]
        Each  &lt;element-citation&gt; of type 'preprint' must contain one and only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="count(pub-id) le 1" role="error" id="err-elem-cit-preprint-10-1">[err-elem-cit-preprint-10-1]
        One &lt;pub-id&gt; element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements.</assert>
      
      <assert test="count(pub-id)=1 or count(ext-link)=1" role="error" id="err-elem-cit-preprint-10-3">[err-elem-cit-preprint-10-3]
        Either one &lt;pub-id&gt; or one &lt;ext-link&gt; element is required in a preprint reference.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/> &lt;pub-id&gt; elements
        and <value-of select="count(ext-link)"/> &lt;ext-link&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group| article-title| source| year| pub-id| ext-link)" role="error" id="err-elem-cit-preprint-13">[err-elem-cit-preprint-13]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="preprint" are:
        &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, and &lt;ext-link&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/person-group" id="elem-citation-preprint-person-group"> 
      
      <assert test="@person-group-type='author'" role="error" id="err-elem-cit-preprint-2-2">[err-elem-cit-preprint-2-2]
        The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in 
        Reference '<value-of select="ancestor::ref/@id"/>' contains @person-group-type='<value-of select="@person-group-type"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/pub-id" id="elem-citation-preprint-pub-id"> 
      
      <assert test="@pub-id-type='doi'" role="error" id="err-elem-cit-preprint-10-2">[err-elem-cit-preprint-10-2]
        If present, the &lt;pub-id&gt; element must contain @pub-id-type='doi'.
        The &lt;pub-id&gt; element in Reference '<value-of select="ancestor::ref/@id"/>'
        contains @pub-id-type='<value-of select="@pub-id-type"/>'.</assert>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type='preprint']/ext-link" id="elem-citation-preprint-ext-link"> 
      
      <assert test="@xlink:href" role="error" id="err-elem-cit-preprint-11-1">[err-elem-cit-preprint-11-1]
        Each &lt;ext-link&gt; element must contain @xlink:href.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' does not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-preprint-11-2">[err-elem-cit-preprint-11-2]
        The value of @xlink:href must start with either "http://" or "https://". 
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        is '<value-of select="@xlink:href"/>', which does not.</assert>  
      
      <assert test="normalize-space(@xlink:href)=normalize-space(.)" role="error" id="err-elem-cit-preprint-11-3">[err-elem-cit-preprint-11-3]
        The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
    
    <rule context="element-citation[@publication-type='preprint']/article-title" id="elem-citation-preprint-article-title"> 
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-preprint-8-2-1">[err-elem-cit-preprint-8-2-1]
        A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-preprint-8-2-2">[err-elem-cit-preprint-8-2-2]
        A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/source" id="elem-citation-preprint-source"> 
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-preprint-9-2-1">[err-elem-cit-preprint-9-2-1]
        A &lt;source&gt; element within a &lt;element-citation&gt; of type 'preprint' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-preprint-9-2-2">[err-elem-cit-preprint-9-2-2]
        A &lt;source&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-web-tests">
    <rule context="element-citation[@publication-type='web']" id="elem-citation-web">
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-web-2-1">[err-elem-cit-web-2-1]
        There must be one and only one person-group. 
        Reference '<value-of select="ancestor::ref/@id"/>' has
        <value-of select="count(person-group)"/> &lt;person-group&gt; 
        elements.</assert>
      
      <assert test="count(article-title)=1" role="error" id="err-elem-cit-web-8-1">[err-elem-cit-web-8-1]
        Each  &lt;element-citation&gt; of type 'web' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <report test="count(source) &gt; 1" role="error" id="err-elem-cit-web-9-1">[err-elem-cit-web-9-1]
        Each  &lt;element-citation&gt; of type 'web' may contain one and only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</report>
      
      <assert test="count(ext-link)=1" role="error" id="err-elem-cit-web-10-1">[err-elem-cit-web-10-1]
        One and only one &lt;ext-link&gt; element is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(ext-link)"/> 
        &lt;ext-link&gt; elements.</assert>
      
      <assert test="count(date-in-citation)=1" role="error" id="err-elem-cit-web-11-1">[err-elem-cit-web-11-1]
        One and only one &lt;date-in-citation&gt; element is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(date-in-citation)"/> 
        &lt;date-in-citation&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group|article-title|source|year|ext-link|date-in-citation)" role="error" id="err-elem-cit-web-12">[err-elem-cit-web-12]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="web" are:
        &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;ext-link&gt; and &lt;date-in-citation&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='web']/person-group" id="elem-citation-web-person-group"> 
      
      <assert test="@person-group-type='author'" role="error" id="err-elem-cit-web-2-2">[err-elem-cit-web-2-2]
        The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in 
        Reference '<value-of select="ancestor::ref/@id"/>' contains @person-group-type='<value-of select="@person-group-type"/>'.</assert>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type='web']/ext-link" id="elem-citation-web-ext-link"> 

      <assert test="@xlink:href" role="error" id="err-elem-cit-web-10-2">[err-elem-cit-web-10-2]
        Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        does not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-web-10-3">[err-elem-cit-web-10-3]
        The value of @xlink:href must start with either "http://" or "https://". 
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        is '<value-of select="@xlink:href"/>', which does not.</assert>  

      <assert test="normalize-space(@xlink:href)=normalize-space(.)" role="error" id="err-elem-cit-web-10-4">[err-elem-cit-web-10-4]
        The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
    
    <rule context="element-citation[@publication-type='web']/article-title" id="elem-citation-web-article-title"> 
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-web-8-2-1">[err-elem-cit-web-8-2-1]
        A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-web-8-2-2">[err-elem-cit-web-8-2-2]
        A  &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='web']/source" id="elem-citation-web-source"> 
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-web-9-2-1">[err-elem-cit-web-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'web' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-web-9-2-2">[err-elem-cit-web-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='web']/date-in-citation" id="elem-citation-web-date-in-citation"> 
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
      
      <!-- issue 5 on the eLife lists -->
      <report test="if (string-length(@iso-8601-date) = 10) then format-date(xs:date(@iso-8601-date), '[MNn] [D], [Y]')!=.
        else (string-length(@iso-8601-date) &lt; 10)" role="error" id="err-elem-cit-web-11-4">[err-elem-cit-web-11-4]
        The element content date must match the @iso-8601-date value.
        Reference '<value-of select="ancestor::ref/@id"/>' has element content of 
        <value-of select="."/> but an @iso-8601-date value of 
        <value-of select="@iso-8601-date"/>.</report>
      
    </rule>
  </pattern>
  
  <pattern id="element-citation-report-tests">
    <rule context="element-citation[@publication-type='report']" id="elem-citation-report">
      <let name="publisher-locations" value="'publisher-locations.xml'"/> 
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-report-2-1">[err-elem-cit-report-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(source)=1" role="error" id="err-elem-cit-report-9-1">[err-elem-report-report-9-1]
        Each  &lt;element-citation&gt; of type 'report' must contain one and
        only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="count(publisher-name)=1" role="error" id="err-elem-cit-report-11-1">[err-elem-cit-report-11-1]
        &lt;publisher-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(publisher-name)"/>
        &lt;publisher-name&gt; elements.</assert>
      
      <report test="some $p in document($publisher-locations)/locations/location/text()       satisfies ends-with(publisher-name,$p)" role="warning" id="warning-elem-cit-report-11-3">[warning-elem-cit-report-11-3]
        The content of &lt;publisher-name&gt; may not end with a publisher location. 
        Reference '<value-of select="ancestor::ref/@id"/>' contains the string <value-of select="publisher-name"/>,
        which ends with a publisher location.</report>
      
      <assert test="count(*) = count(person-group| year| source| publisher-loc|publisher-name| ext-link| pub-id)" role="error" id="err-elem-cit-report-15">[err-elem-cit-report-15]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="report" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='report']/person-group" id="elem-citation-report-preson-group">
      <assert test="@person-group-type='author'" role="error" id="err-elem-cit-report-2-2">[err-elem-cit-report-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='report']/source" id="elem-citation-report-source">
      
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="(./string-length() + sum(*/string-length()) ge 2)" role="error" id="err-elem-cit-report-9-2-1">[err-elem-cit-report-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'report' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-report-9-2-2">[err-elem-cit-report-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'report' may only contain the child 
        elements: &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='report']/publisher-name" id="elem-citation-report-publisher-name">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-report-11-2">[err-elem-cit-report-11-2]
        No elements are allowed inside &lt;publisher-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='report']/pub-id" id="elem-citation-report-pub-id">
      
      <assert test="@pub-id-type='doi' or @pub-id-type='isbn'" role="error" id="err-elem-cit-report-12-2">[err-elem-cit-report-12-2]
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
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-confproc-2-1">[err-elem-cit-confproc-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(article-title)=1" role="error" id="err-elem-cit-confproc-8-1">[err-elem-cit-confproc-8-1]
        Each  &lt;element-citation&gt; of type 'confproc' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source) le 1" role="error" id="err-elem-cit-confproc-9-1">[err-elem-confproc-confproc-9-1]
        Each  &lt;element-citation&gt; of type 'confproc' may contain one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <assert test="count(conf-name)=1" role="error" id="err-elem-cit-confproc-10-1">[err-elem-cit-confproc-10-1]
        &lt;conf-name&gt; is required.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(conf-name)"/>
        &lt;conf-name&gt; elements.</assert>
      
      <report test="(fpage and elocation-id) or (lpage and elocation-id)" role="error" id="err-elem-cit-confproc-12-1">[err-elem-cit-confproc-12-1]
        The citation may contain &lt;fpage&gt; and &lt;lpage&gt;, only &lt;fpage&gt;, or only &lt;elocation-id&gt; elements, but not a mixture.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1" role="error" id="err-elem-cit-confproc-12-2">[err-elem-cit-confproc-12-2]
        The citation may contain no more than one of any of &lt;fpage&gt;, &lt;lpage&gt;, and &lt;elocation-id&gt; elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report test="(lpage and fpage) and (fpage[1] ge lpage[1])" role="error" id="err-elem-cit-confproc-12-3">[err-elem-cit-confproc-12-3]
        If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is 
        less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <assert test="count(fpage/*)=0 and count(lpage/*)=0" role="error" id="err-elem-cit-confproc-12-4">[err-elem-cit-confproc-12-4]
        The content of the &lt;fpage&gt; and &lt;lpage&gt; elements can contain any alpha numeric value but no child elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage/*)"/> child elements in
        &lt;fpage&gt; and  <value-of select="count(lpage/*)"/> child elements in &lt;lpage&gt;.</assert>     
      
      <assert test="count(pub-id) le 1" role="error" id="err-elem-cit-confproc-16-1">[err-elem-cit-confproc-16-1]
        A maximum of one &lt;pub-id&gt; element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(pub-id)"/>
        &lt;pub-id&gt; elements.</assert>
      
      <assert test="count(*) = count(person-group | article-title | year| source | conf-loc | conf-name | lpage |        fpage | elocation-id | ext-link | pub-id)" role="error" id="err-elem-cit-confproc-17">[err-elem-cit-confproc-17]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="confproc" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;conf-loc&gt;, &lt;conf-name&gt;, 
        &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/person-group" id="elem-citation-confproc-preson-group">
      <assert test="@person-group-type='author'" role="error" id="err-elem-cit-confproc-2-2">[err-elem-cit-confproc-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/source" id="elem-citation-confproc-source">
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="(./string-length() + sum(*/string-length()) ge 2)" role="error" id="err-elem-cit-confproc-9-2-1">[err-elem-cit-confproc-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'confproc' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(*)=count(italic | sub | sup)" role="error" id="err-elem-cit-confproc-9-2-2">[err-elem-cit-confproc-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'confproc' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements that are not allowed.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/article-title" id="elem-citation-confproc-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-confproc-8-2">[err-elem-cit-confproc-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/conf-name" id="elem-citation-confproc-conf-name">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-confproc-10-2">[err-elem-cit-confproc-10-2]
        No elements are allowed inside &lt;conf-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;conf-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/conf-loc" id="elem-citation-confproc-conf-loc">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-confproc-11-2">[err-elem-cit-confproc-11-2]
        No elements are allowed inside &lt;conf-loc&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;conf-loc&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/fpage" id="elem-citation-confproc-fpage">
      
      <assert test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage[1]),1,1) = substring(normalize-space(.),1,1))" role="error" id="err-elem-cit-confproc-12-5">[err-elem-cit-confproc-12-5]
        If the content of &lt;fpage&gt; begins with a letter, then the content of &lt;lpage&gt; must begin with 
        the same letter. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt;='<value-of select="."/>'
        and &lt;lpage&gt;='<value-of select="../lpage"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='confproc']/pub-id" id="elem-citation-confproc-pub-id">
      
      <assert test="@pub-id-type='doi' or @pub-id-type='pmid'" role="error" id="err-elem-cit-confproc-16-2">[err-elem-cit-confproc-16-2]
        The only allowed pub-id types are 'doi' or 'pmid'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type='confproc']/ext-link" id="elem-citation-confproc-ext-link"> 
      
      <assert test="@xlink:href" role="error" id="err-elem-cit-confproc-14-1">[err-elem-cit-confproc-14-1]
        Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        does not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-confproc-14-2">[err-elem-cit-confproc-14-2]
        The value of @xlink:href must start with either "http://" or "https://". 
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        is '<value-of select="@xlink:href"/>', which does not.</assert>  
      
      <assert test="normalize-space(@xlink:href)=normalize-space(.)" role="error" id="err-elem-cit-confproc-14-3">[err-elem-cit-confproc-14-3]
        The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
    
  </pattern>
  
  <pattern id="element-citation-thesis-tests">
    
    <rule context="element-citation[@publication-type='thesis']" id="elem-citation-thesis"> 
      
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
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/person-group" id="elem-citation-thesis-preson-group">
      
      <assert test="@person-group-type='author'" role="error" id="err-elem-cit-thesis-2-2">[err-elem-cit-thesis-2-2]
        Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a &lt;person-group&gt; 
        element with @person-group-type attribute '<value-of select="@person-group-type"/>'.</assert>
      
      <assert test="count(name)=1" role="error" id="err-elem-cit-thesis-2-3">[err-elem-cit-thesis-2-3]
        Each thesis citation must have one and only one author.
        Reference '<value-of select="ancestor::ref/@id"/>' has a thesis citation 
        with <value-of select="count(name)"/> authors.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/article-title" id="elem-citation-thesis-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-thesis-8-2">[err-elem-cit-thesis-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/publisher-name" id="elem-citation-thesis-publisher-name">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-thesis-9-2">[err-elem-cit-thesis-9-2]
        No elements are allowed inside &lt;publisher-name&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-name&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/publisher-loc" id="elem-citation-thesis-publisher-loc">
      
      <assert test="count(*)=0" role="error" id="err-elem-cit-thesis-10-2">[err-elem-cit-thesis-10-2]
        No elements are allowed inside &lt;publisher-loc&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has child elements within the
        &lt;publisher-loc&gt; element.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='thesis']/pub-id" id="elem-citation-thesis-pub-id">
      
      <assert test="@pub-id-type='doi'" role="error" id="err-elem-cit-thesis-11-2">[err-elem-cit-thesis-11-2]
        The only allowed pub-id type is 'doi'.
        Reference '<value-of select="ancestor::ref/@id"/>' has a pub-id type of 
        '<value-of select="@pub-id-type"/>'.</assert>
      
    </rule>
    
    <!-- Genercised in  elem-citation-ext-link
    <rule context="element-citation[@publication-type='thesis']/ext-link" id="elem-citation-thesis-ext-link"> 
      
      <assert test="@xlink:href" role="error" id="err-elem-cit-thesis-12-1">[err-elem-cit-thesis-12-1]
        Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        does not.</assert>
      
      <assert test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')" role="error" id="err-elem-cit-thesis-12-2">[err-elem-cit-thesis-12-2]
        The value of @xlink:href must start with either "http://" or "https://". 
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        is '<value-of select="@xlink:href"/>', which does not.</assert>  
      
      <assert test="normalize-space(@xlink:href)=normalize-space(.)" role="error" id="err-elem-cit-thesis-12-3">[err-elem-cit-thesis-12-3]
        The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;.
        The &lt;ext-link&gt; element in Reference '<value-of select="ancestor::ref/@id"/>' 
        has @xlink:href='<value-of select="@xlink:href"/>' and content '<value-of select="."/>'.</assert>
      
    </rule>-->
    
  </pattern>
  
  <pattern id="element-citation-periodical-tests">
    
    <rule context="element-citation[@publication-type='periodical']" id="elem-citation-periodical">
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-periodical-2-1">[err-elem-cit-periodical-2-1]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one and
        only one &lt;person-group&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="person-group[@person-group-type='author']" role="error" id="err-elem-cit-periodical-2-2">[err-elem-cit-periodical-2-2]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one &lt;person-group&gt; 
        with the attribute person-group-type set to 'author'. Reference 
        '<value-of select="ancestor::ref/@id"/>' has a  &lt;person-group&gt; type of 
        '<value-of select="person-group/@person-group-type"/>'.</assert> 
      
      <assert test="count(string-date/year)=1" role="error" id="err-elem-cit-periodical-7-1">[err-elem-cit-periodical-7-1]
        There must be one and only one &lt;year&gt; element in a &lt;string-date&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(year)"/>
        &lt;year&gt; elements in the &lt;string-date&gt; element.</assert>
      
      <assert test="count(article-title)=1" role="error" id="err-elem-cit-periodical-8-1">[err-elem-cit-periodical-8-1]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one and
        only one &lt;article-title&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(article-title)"/> &lt;article-title&gt; elements.</assert>
      
      <assert test="count(source)=1" role="error" id="err-elem-cit-periodical-9-1">[err-elem-cit-periodical-9-1]
        Each  &lt;element-citation&gt; of type 'periodical' must contain one and
        only one &lt;source&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(source)"/> &lt;source&gt; elements.</assert>
      
      <!-- Genericised across all publication types in elem-cit-source
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-periodical-9-2-1">[err-elem-cit-periodical-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'periodical' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>-->
      
      <assert test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))" role="error" id="err-elem-cit-periodical-9-2-2">[err-elem-cit-periodical-9-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'periodical' may only contain the child 
        elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
      <assert test="count(volume) le 1" role="error" id="err-elem-cit-periodical-10-1-3">[err-elem-cit-periodical-10-1-3]
        There may be at most one  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'periodical'.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(volume)"/>
        &lt;volume&gt; elements.</assert>
      
      <report test="lpage and not(fpage)" role="error" id="err-elem-cit-periodical-11-1">[err-elem-cit-periodical-11-1]
        If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements,  <value-of select="count(lpage)"/> &lt;lpage&gt; elements, and 
        <value-of select="count(elocation-id)"/> &lt;elocation-id&gt; elements.</report>
      
      <report test="count(fpage) gt 1 or count(lpage) gt 1" role="error" id="err-elem-cit-periodical-11-2">[err-elem-cit-periodical-11-2]
        The citation may contain no more than one &lt;fpage&gt; or &lt;lpage&gt; elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage)"/>
        &lt;fpage&gt; elements and <value-of select="count(lpage)"/> &lt;lpage&gt; elements.</report>
      
      <report test="(lpage and fpage) and (fpage[1] ge lpage[1])" role="error" id="err-elem-cit-periodical-11-3">[err-elem-cit-periodical-11-3]
        If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;lpage&gt; <value-of select="lpage"/>, which is 
        less than or equal to &lt;fpage&gt; <value-of select="fpage"/>.</report>
      
      <assert test="count(fpage/*)=0 and count(lpage/*)=0" role="error" id="err-elem-cit-periodical-11-4">[err-elem-cit-periodical-11-4]
        The content of the &lt;fpage&gt; and &lt;lpage&gt; elements can contain any alpha numeric value but no child elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(fpage/*)"/> child elements in
        &lt;fpage&gt; and  <value-of select="count(lpage/*)"/> child elements in &lt;lpage&gt;.</assert>     
      
      <assert test="count(*) = count(person-group | year | string-date | article-title | source | volume | fpage | lpage)" role="error" id="err-elem-cit-periodical-13">[err-elem-cit-periodical-13]
        The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="periodical" are:
        &lt;person-group&gt;, &lt;year&gt;, &lt;string-date&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;volume&gt;, &lt;fpage&gt;, and &lt;lpage&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
      
      <assert test="count(string-date)=1" role="error" id="err-elem-cit-periodical-14-1">[err-elem-cit-periodical-14-1]
        There must be one and only one &lt;string-date&gt; element within a &lt;element-citation&gt; of type 'periodical'.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(string-date)"/>
        &lt;string-date&gt; elements.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/year" id="elem-citation-periodical-year">
      
      <let name="YYYY" value="substring(normalize-space(.), 1, 4)"/>
      <let name="current-year" value="year-from-date(current-date())"/>
      
      <assert test="./@iso-8601-date" role="error" id="err-elem-cit-periodical-7-2">[err-elem-cit-periodical-7-2]
        The &lt;year&gt; element must have an @iso-8601-date attribute.
        Reference '<value-of select="ancestor::ref/@id"/>' does not.
      </assert>
      
      <assert test="matches(normalize-space(.),'(^\d{4}[a-z]?)')" role="error" id="err-elem-cit-periodical-7-4-1">[err-elem-cit-periodical-7-4-1]
        The &lt;year&gt; element in a reference must contain 4 digits, possibly followed by one (but not more) lower-case letter.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="(1700 le number($YYYY)) and (number($YYYY) le $current-year)" role="warning" id="err-elem-cit-periodical-7-4-2">[err-elem-cit-periodical-7-4-2]
        The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year (inclusive).
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and        (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,'b'))        and ancestor::element-citation/person-group[1]/name[1]/surname[1] = $y/ancestor::element-citation/person-group[1]/name[1]/surname[1])       )" role="error" id="err-elem-cit-periodical-7-6">[err-elem-cit-periodical-7-6]
        If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with 
        the same first author surname with a letter "b" after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <assert test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or       (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',       'abcdefghijklmnopqrstuvwxy')))        and ancestor::element-citation/person-group[1]/name[1]/surname[1] = $y/ancestor::element-citation/person-group[1]/name[1]/surname[1])       " role="error" id="err-elem-cit-periodical-7-7">[err-elem-cit-periodical-7-7]
        If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another 
        reference with the same first author surname with the preceding letter after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <report test=". = preceding::year and        ancestor::element-citation/person-group[1]/name[1]/surname[1] = preceding::year/ancestor::element-citation/person-group[1]/name[1]/surname[1]" role="error" id="err-elem-cit-periodical-7-8">[err-elem-cit-periodical-7-8]
        Letter suffixes must be unique for the combination of year and first author surname. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement as it 
        contains the &lt;year&gt; '<value-of select="."/>' more than once for the same first author surname
        '<value-of select="ancestor::element-citation/person-group[1]/name[1]/surname[1]"/>'.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/article-title" id="elem-citation-periodical-article-title">
      
      <assert test="count(*) = count(sub|sup|italic)" role="error" id="err-elem-cit-periodical-8-2">[err-elem-cit-periodical-8-2]
        An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. 
        No other elements are allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/volume" id="elem-citation-periodical-volume">
      <assert test="count(*)=0 and (string-length(text()) ge 1)" role="error" id="err-elem-cit-periodical-10-1-2">[err-elem-cit-periodical-10-1-2]
        A  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'periodical' must contain 
        at least one character and may not contain child elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters and/or
        child elements.</assert>
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/fpage" id="elem-citation-periodical-fpage">
      
      <assert test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage[1]),1,1) = substring(normalize-space(.),1,1))" role="error" id="err-elem-cit-periodical-11-5">[err-elem-cit-periodical-11-4]
        If the content of &lt;fpage&gt; begins with a letter, then the content of  &lt;lpage&gt; must begin with 
        the same letter. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt;='<value-of select="."/>'
        and &lt;lpage&gt;='<value-of select="../lpage"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date" id="elem-citation-periodical-string-date">
      <let name="YYYY" value="substring(normalize-space(year[1]), 1, 4)"/>
      
      <assert test="count(month)=1 and count(year)=1" role="error" id="err-elem-cit-periodical-14-2">[err-elem-cit-periodical-14-2]
        The &lt;string-date&gt; element must include one of each of &lt;month&gt; and &lt;year&gt; 
        elements.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        <value-of select="count(month)"/> &lt;month&gt; elements and <value-of select="count(year)"/> &lt;year&gt; elements.
      </assert>
      
      <assert test="count(day) le 1" role="error" id="err-elem-cit-periodical-14-3">[err-elem-cit-periodical-14-3]
        The &lt;string-date&gt; element may include one &lt;day&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        <value-of select="count(day)"/> &lt;day&gt; elements.
      </assert> 
      
      <assert test="(name(child::node()[1])='month' and replace(child::node()[2],'\s+',' ')=' ' and        name(child::node()[3])='day' and replace(child::node()[4],'\s+',' ')=', ' and name(*[position()=last()])='year') or       (name(child::node()[1])='month' and replace(child::node()[2],'\s+',' ')=', ' and name(*[position()=last()])='year')" role="error" id="err-elem-cit-periodical-14-8">[err-elem-cit-periodical-14-8]
        The format of the element content must match &lt;month&gt;, space, &lt;day&gt;, comma, &lt;year&gt;, or &lt;month&gt;, comma, &lt;year&gt;.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="."/>.</assert>    
      
      <assert test="matches(normalize-space(@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')" role="error" id="err-elem-cit-periodical-7-3">[err-elem-cit-periodical-7-3]
        The @iso-8601-date value must include 4 digit year, 2 digit month, and (optionally) a 2 digit day.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="@iso-8601-date"/>'.
      </assert>
      
      <report test="not(@iso-8601-date) or (substring(normalize-space(@iso-8601-date),1,4) != $YYYY)" role="error" id="err-elem-cit-periodical-7-5">[err-elem-cit-periodical-7-5]
        The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the 
        &lt;year&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the element contains
        the value '<value-of select="."/>' and the attribute contains the value 
        '<value-of select="./@iso-8601-date"/>'.
      </report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/month" id="elem-citation-periodical-month">
      
      <assert test=".=('January','February','March','April','May','June','July','August','September','October','November','December')" role="error" id="err-elem-cit-periodical-14-4">[err-elem-cit-periodical-14-4]
        The content of &lt;month&gt; must be the month, written out, with correct capitalization.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value  &lt;month&gt;='<value-of select="."/>'.
      </assert>
      
      <report test="if  (matches(normalize-space(../@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')) then .!=format-date(xs:date(../@iso-8601-date), '[MNn]')
        else ." role="error" id="err-elem-cit-periodical-14-5">[err-elem-cit-periodical-14-5]
        The content of &lt;month&gt; must match the content of the month section of @iso-8601-date on the 
        parent string-date element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value &lt;month&gt;='<value-of select="."/>' but &lt;string-date&gt;/@iso-8601-date='<value-of select="../@iso-8601-date"/>'.
      </report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/day" id="elem-citation-periodical-day">
      
      <assert test="matches(normalize-space(.),'([1-9])|([1-2][0-9])|(3[0-1])')" role="error" id="err-elem-cit-periodical-14-6">[err-elem-cit-periodical-14-6]
        The content of &lt;day&gt;, if present, must be the day, in digits, with no zeroes.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value  &lt;day&gt;='<value-of select="."/>'.
      </assert>
      
      <report test="if  (matches(normalize-space(../@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')) then .!=format-date(xs:date(../@iso-8601-date), '[D]')
                    else ." role="error" id="err-elem-cit-periodical-14-7">[err-elem-cit-periodical-14-7]
        The content of &lt;day&gt;, if present, must match the content of the day section of @iso-8601-date on the 
        parent string-date element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value &lt;day&gt;='<value-of select="."/>' but &lt;string-date&gt;/@iso-8601-date='<value-of select="../@iso-8601-date"/>'.
      </report>
      
    </rule>
  </pattern>
  
  <pattern
    id="pub-id-pattern">
    
    <rule context="element-citation/pub-id" 
      id="pub-id-tests">
      
      <report test="(@xlink:href) and not(matches(@xlink:href,'^http[s]?://|^ftp://'))"
        role="error"
        id="pub-id-test-1">@xlink:href must start with an http:// or ftp:// protocol.</report>
      
      <report test="(@pub-id-type='doi') and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))"
        role="error"
        id="pub-id-test-2">pub-id is tagged as a doi, but it is not one - <value-of select="."/></report>
      
      <report test="(@pub-id-type='pmid') and matches(.,'\D')"
        role="error"
        id="pub-id-test-3">pub-id is tagged as a pmid, but it contains a character(s) which is not a digit - <value-of select="."/></report>
      
    </rule>
    
  </pattern>
  
 <pattern
 	id="features">
   
   <rule context="article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]//title-group/article-title" 
     id="feature-title-tests">
     <let name="sub-disp-channel" value="ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject"/>
     
     <report test="(count(ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject) = 1) and starts-with(.,$sub-disp-channel)"
       role="error"
       id="feature-title-test-1">title starts with the sub-display-channel. This is certainly incorrect.</report>
     
   </rule>
   
   <rule context="front//abstract[@abstract-type='executive-summary']" 
     id="feature-abstract-tests">
     
     <assert test="count(title) = 1"
       role="error"
       id="feature-abstract-test-1">abstract must contain one and only one title.</assert>
     
     <assert test="title = 'eLife digest'"
       role="error"
       id="feature-abstract-test-2">abstract title must contain 'eLife digest'. Possible superfluous characters - <value-of select="replace(title,'eLife digest','')"/></assert>
     
   </rule>
	
   <rule context="article-categories[subj-group[@subj-group-type='display-channel'][subject = $features-subj]]"
		id="feature-subj-tests-1">		
		
     <assert test="subj-group[@subj-group-type='sub-display-channel']"
	  	role="error"
	  	id="feature-subj-test-1">Feature content must contain subj-group[@subj-group-type='sub-display-channel'].</assert>
     
   </rule>
   
   <rule context="subj-group[@subj-group-type='sub-display-channel']/subject"
     id="feature-subj-tests-2">		
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
       id="feature-subj-test-4">There is more than one sub-display-channel subjects. This is incorrect.</report>
		
	</rule>
   
   <rule context="article-categories[subj-group[@subj-group-type='display-channel']/subject = $features-subj]"
     id="feature-article-category-tests">
     <let name="count" value="count(subj-group[@subj-group-type='sub-display-channel'])"/>
     
     <assert test="($count = 1) or ($count = 0)"
       role="error"
       id="feature-article-category-test-1">article categories contains more than one subj-group[@subj-group-type='sub-display-channel'], which must be incorrect.</assert>
     
     <report test="$count = 0"
       role="warning"
       id="feature-article-category-test-2">article categories doesn't contain a subj-group[@subj-group-type='sub-display-channel']. This is almost certainly not right.</report>
     
   </rule>
   
   <rule context="article[@article-type = $features-article-types]//article-meta//contrib[@contrib-type='author']"
     id="feature-author-tests">
     
     <assert test="bio"
       role="error"
       id="feature-author-test-1">Author must contain child bio in feature content.</assert>
   </rule>
   
   <rule context="article[@article-type = $features-article-types]//article-meta//contrib[@contrib-type='author']/bio"
     id="feature-bio-tests">
     <let name="name" value="e:get-name(parent::contrib/name)"/>
     <let name="xref-rid" value="parent::contrib/xref[@ref-type='aff']/@rid"/>
     <let name="aff" value="if (parent::contrib/aff) then parent::contrib/aff[1]/institution[not(@content-type)]/normalize-space(.)
       else ancestor::contrib-group/aff[@id/string() = $xref-rid]/institution[not(@content-type)]/normalize-space(.)"/>
     
     <assert test="p/bold = $name"
       role="error"
       id="feature-bio-test-1">bio must contain a bold element which contains the name of the author - <value-of select="$name"/>.</assert>
     
     <!-- Needs to account for authors with two or more affs-->
     <report test="if (count($aff) > 1) then ()
                   else not(contains(.,$aff))"
       role="warning"
       id="feature-bio-test-2">bio does not contain top level insutution text as it appears in their affiliation ('<value-of select="$aff"/>'). Is this correct?</report>
     
     <report test="matches(p,'[\p{P}]$')"
       role="error"
       id="feature-bio-test-3">bio cannot end in punctuation - '<value-of select="substring(p,string-length(p),1)"/>'.</report>
   </rule>
   
   <rule context="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]"
     id="feature-template-tests">
     <let name="template" value="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value"/>
     <let name="type" value="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject"/>
     
     <report test="($template = ('1','2')) and child::sub-article"
       role="error"
       id="feature-template-test-1"><value-of select="$type"/> is a template <value-of select="$template"/> but it has a decision letter or author response, which cannot be correct, as only template 5s are allowed these.</report>
     
     <report test="($template = '5') and not(@article-type='research-article')"
       role="error"
       id="feature-template-test-2"><value-of select="$type"/> is a template <value-of select="$template"/> so the article element must have a @article-type="research-article". Instead the @article-type="<value-of select="@article-type"/>".</report>
     
     <report test="($template = '5') and not(child::sub-article[@article-type='decision-letter'])"
       role="warning"
       id="feature-template-test-3"><value-of select="$type"/> is a template <value-of select="$template"/> but it does not (currently) have a decision letter. Is that OK?</report>
     
     <report test="($template = '5') and not(child::sub-article[@article-type='reply'])"
       role="warning"
       id="feature-template-test-4"><value-of select="$type"/> is a template <value-of select="$template"/> but it does not (currently) have an author response. Is that OK?</report>
     
   </rule>
  </pattern>
  
  <pattern
    id="correction-retraction">
    
    <rule context="article[@article-type = 'correction']"
      id="correction-tests">
      
      <report test="descendant::article-meta//aff"
        role="error"
        id="corr-aff-presence">Correction notices should not contain affiliations.</report>
      
      <report test="descendant::article-meta//kwd-group[@kwd-group-type='author-keywords']"
        role="error"
        id="corr-auth-kw-presence">Correction notices should not contain any author keywords.</report>
      
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
    
    <rule context="article[@article-type = 'retraction']"
      id="retraction-tests">
      
      <report test="descendant::article-meta//aff"
        role="error"
        id="retr-aff-presence">Retractions should not contain affiliations.</report>
      
      <report test="descendant::article-meta//kwd-group[@kwd-group-type='author-keywords']"
        role="error"
        id="retr-auth-kw-presence">Retractions should not contain any author keywords.</report>
      
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
  
  <pattern
    id="gene-primer-sequence-pattern">
    
    <rule context="p"
      id="final-gene-primer-sequence">
      <let name="count" value="count(descendant::named-content[@content-type='sequence'])"/>
      <let name="text-tokens" value="for $x in tokenize(.,' ') return if (matches($x,'[ACGTacgt]{15,}')) then $x else ()"/>
      <let name="text-count" value="count($text-tokens)"/>
      
      <assert test="(($text-count le $count) or ($text-count = $count))"
        role="warning"
        id="gene-primer-sequence-test">p element contains what looks like an untagged primer or gene sequence - <value-of select="string-join($text-tokens,', ')"/>.</assert>
    </rule>
    
  </pattern>
  
  <pattern
    id="rrid-org-pattern">
    
    <rule context="p|td|th"
      id="rrid-org-code">
      <let name="count" value="count(descendant::ext-link[matches(@xlink:href,'scicrunch\.org.*resolver')])"/>
      <let name="lc" value="lower-case(.)"/>
      <let name="text-count" value="number(count(
        for $x in tokenize(.,'RRID:|RRID AB_[\d]+|RRID CVCL_[\d]+|RRID SCR_[\d]+|RRID ISMR_JAX') 
        return $x)) -1"/>
      <let name="t" value="replace($lc,'drosophila genetic resource center|bloomington drosophila stock center|drosophila genomics resource center','')"/>
      <let name="code-text" value="string-join(for $x in tokenize(.,' ') return if (matches($x,'^--[a-z]+')) then $x else (),'; ')"/>
      <let name="unequal-equal-text" value="string-join(for $x in tokenize(.,' |&#x00A0;') return if (matches($x,'=$|^=') and not(matches($x,'^=$'))) then $x else (),'; ')"/>
      <let name="link-strip-text" value="string-join(for $x in (*[not(matches(local-name(),'^ext-link$|^contrib-id$|^license_ref$|^institution-id$|^email$|^xref$|^monospace$'))]|text()) return $x,'')"/>
      <let name="url-text" value="string-join(for $x in tokenize($link-strip-text,' ') 
        return   if (matches($x,'^https?:..(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%_\+.~#?&amp;//=]*)|^ftp://.|^git://.|^tel:.|^mailto:.|\.org[\s]?|\.com[\s]?|\.co.uk[\s]?|\.us[\s]?|\.net[\s]?|\.edu[\s]?|\.gov[\s]?|\.io[\s]?')) then $x
        else (),'; ')"/>
      
      <report test="($text-count gt $count)"
        role="warning"
        id="rrid-test">'<name/>' element contains what looks like <value-of select="$text-count - $count"/> unlinked RRID(s). These should always be linked using 'https://scicrunch.org/resolver/'. Element begins with <value-of select="substring(.,1,15)"/>.</report>
      
      <report test="matches($t,$org-regex) and not(descendant::italic[contains(.,e:org-conform($t))])"
        role="warning" 
        id="org-test"><name/> element contains an organism - <value-of select="e:org-conform($t)"/> - but there is no italic element with that correct capitalisation or spacing. Is this correct? <name/> element begins with <value-of select="concat(.,substring(.,1,15))"/>.</report>
      
      <report test="not(descendant::monospace) and ($code-text != '')"
        role="warning" 
        id="code-test"><name/> element contains what looks like unformatted code - '<value-of select="$code-text"/>' - does this need tagging with &lt;monospace/&gt; or &lt;preformat/&gt;?</report>
      
      <report test="($unequal-equal-text != '') and not(disp-formula[contains(.,'=')]) and not(inline-formula[contains(.,'=')])"
        role="warning" 
        id="cell-spacing-test"><name/> element contains an equal sign with content directly next to one side, but a space on the other, is this correct? - <value-of select="$unequal-equal-text"/></report>
      
      <report test="matches(.,'\+cell[s]?|±cell[s]?') and not(descendant::p[matches(.,'\+cell[s]?|±cell[s]?')]) and not(descendant::td[matches(.,'\+cell[s]?|±cell[s]?')]) and not(descendant::th[matches(.,'\+cell[s]?|±cell[s]?')])"
        role="warning" 
        id="equal-spacing-test"><name/> element contains the text '+cells' or '±cells' which is very likely to be incorrect spacing - <value-of select="."/></report>
      
      <report test="matches(.,'˚') and not(descendant::p[matches(.,'˚')]) and not(descendant::td[matches(.,'˚')]) and not(descendant::th[matches(.,'˚')])"
        role="warning"
        id="ring-diacritic-symbol-test">'<name/>' element contains the ring above symbol, '∘'. Should this be a (non-superscript) degree symbol - ° - instead?</report>
      
      <report test="matches(.,'[Ttype]\s?[Oo]ne\s?[Dd]iabetes') and not(descendant::p[matches(.,'[Ttype]\s?[Oo]ne\s?[Dd]iabetes')]) and not(descendant::td[matches(.,'[Ttype]\s?[Oo]ne\s?[Dd]iabetes')]) and not(descendant::th[matches(.,'[Ttype]\s?[Oo]ne\s?[Dd]iabetes')])"
        role="error"
        id="diabetes-1-test">'<name/>' element contains the phrase 'Type one diabetes'. The number should not be spelled out, this should be 'Type 1 diabetes'.</report>
      
      <report test="matches(.,'[Ttype]\s?[Tt]wo\s?[Dd]iabetes') and not(descendant::p[matches(.,'[Ttype]\s?[Tt]wo\s?[Dd]iabetes')]) and not(descendant::td[matches(.,'[Ttype]\s?[Tt]wo\s?[Dd]iabetes')]) and not(descendant::th[matches(.,'[Ttype]\s?[Tt]wo\s?[Dd]iabetes')])"
        role="error"
        id="diabetes-2-test">'<name/>' element contains the phrase 'Type two diabetes'. The number should not be spelled out, this should be 'Type 2 diabetes'</report>
      
      <assert test="$url-text = ''"
        role="warning"
        id="unlinked-url">'<name/>' element contains possible unlinked urls. Check - <value-of select="$url-text"/></assert>
    </rule>
    
  </pattern>
  
  <pattern
    id="reference">
    
    <rule context="ref-list//ref" 
      id="duplicate-ref">
      <let name="doi" value="element-citation/pub-id[@pub-id-type='doi']"/>
      <let name="a-title" value="element-citation/article-title"/>
      <let name="c-title" value="element-citation/chapter-title"/>
      <let name="source" value="element-citation/source"/>
      <let name="top-doi" value="ancestor::article//article-meta/article-id[@pub-id-type='doi']"/>
      
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
        role="error" 
        id="duplicate-ref-test-3">ref '<value-of select="@id"/>' has the same title and source as another reference, which must be incorrect - '<value-of select="$a-title"/>', '<value-of select="$source"/>'.</report>
      
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
      <let name="ref" value="ancestor::article//descendant::ref-list//ref[@id = $rid]"/>
      <let name="cite1" value="e:citation-format1($ref/descendant::year[1])"/>
      <let name="cite2" value="e:citation-format2($ref/descendant::year[1])"/>
      <let name="cite3" value="normalize-space(replace($cite1,'\p{P}|\p{N}',''))"/>
      <let name="pre-text" value="replace(replace(replace(replace(preceding-sibling::text()[1],'&#x00A0;',' '),' et al\. ',' et al '),'e\.g\.','eg '),'i\.e\. ','ie ')"/>
      <let name="post-text" value="replace(replace(replace(replace(following-sibling::text()[1],'&#x00A0;',' '),' et al\. ',' et al '),'e\.g\.','eg '),'i\.e\. ','ie ')"/>
      <let name="pre-sentence" value="tokenize($pre-text,'\. ')[position() = last()]"/>
      <let name="post-sentence" value="tokenize($post-text,'\. ')[position() = 1]"/>
      <let name="open" value="string-length(replace($pre-sentence,'[^\(]',''))"/>
      <let name="close" value="string-length(replace($pre-sentence,'[^\)]',''))"/>
      
      
      <assert test="replace(.,'&#x00A0;',' ') = ($cite1,$cite2)" 
        role="error" 
        id="ref-xref-test-1"><value-of select="."/> - citation does not conform to house style. It should be '<value-of select="$cite1"/>' or '<value-of select="$cite2"/>'. Preceding text = '<value-of select="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>'.</assert>
      
      <report test="matches($pre-text,'[\p{L}\p{N}\p{M}\p{Pe},;]$')"
        role="warning"
        id="ref-xref-test-2">There is no space between citation and the preceding text - <value-of select="concat(substring($pre-text,string-length($pre-text)-15),.)"/> - Is this correct?</report>
      
      <report test="matches($post-text,'^[\p{L}\p{N}\p{M}\p{Ps}]')"
        role="warning"
        id="ref-xref-test-3">There is no space between citation and the following text - <value-of select="concat(.,substring($post-text,1,15))"/> - Is this correct?</report>
      
      <assert test="matches(normalize-space(.),'\p{N}')"
        role="error"
        id="ref-xref-test-4">citation doesn't contain numbers, which must be incorrect - <value-of select="."/> </assert>
      
      <assert test="matches(normalize-space(.),'\p{L}')"
        role="error"
        id="ref-xref-test-5">citation doesn't contain letters, which must be incorrect - <value-of select="."/> </assert>
      
      <report test="matches($pre-text,'\($|\[$') and (. = $cite2)"
        role="error"
        id="ref-xref-test-6"><value-of select="concat(substring($pre-text, string-length($pre-text), 1),.)"/> - citation is in non-parenthetic style, but the preceding text ends with open parentheses, so this isn't correct.</report>
      
      <report test="matches($post-text,'^\)|^\]') and (. = $cite2)"
        role="error"
        id="ref-xref-test-7"><value-of select="concat(.,substring($post-text,1,1))"/> - citation is in non-parenthetic style, but the following text ends with closing parentheses, so this isn't correct.</report>
      
      <report test="($open gt $close) and (. = $cite2)"
        role="warning"
        id="ref-xref-test-8"><value-of select="concat(substring($pre-text,string-length($pre-text)-10),.)"/> - citation is in non-parenthetic style, but the preceding text has open parentheses. Should it be in the style of <value-of select="$cite1"/>?</report>
      
      <report test="(($open - $close) gt 1) and (. = $cite1)"
        role="warning"
        id="ref-xref-test-9">sentence before citation has more open brackets than closed - <value-of select="concat($pre-sentence,.)"/> - Either one of the brackets is unnecessary or the citation should be in square brackets - <value-of select="concat('[',.,']')"/>.</report>
      
      <report test="(
        (matches($pre-sentence,' from [\(]{1}$| in [\(]{1}$| by [\(]{1}$| of [\(]{1}$| on [\(]{1}$| to [\(]{1}$| see [\(]{1}$| see also [\(]{1}$| at [\(]{1}$| per [\(]{1}$| follows [\(]{1}$| following [\(]{1}$') and (($open - $close) = 1))
          or
          (matches($pre-sentence,' from [\(]{1}$| in [\(]{1}$| by [\(]{1}$| of [\(]{1}$| on [\(]{1}$| to [\(]{1}$| see [\(]{1}$| see also [\(]{1}$| at [\(]{1}$| per [\(]{1}$| follows [\(]{1}$| following [\(]{1}$') and (($open - $close) = 0) and matches($pre-sentence,'^[\)]'))
          or 
          (matches($pre-sentence,' from $| in $| by $| of $| on $| to $| see $| see also $| at $| per $| follows $| following $') and (($open - $close) = 0) and not(matches($pre-sentence,'^[\)]')))
          or
          (matches($pre-sentence,' from $| in $| by $| of $| on $| to $| see $| see also $| at $| per $| follows $| following $') and (($open - $close) lt 0))
         )
        and (. = $cite1)"
        role="warning"
        id="ref-xref-test-11"><value-of select="concat(substring($pre-text,string-length($pre-text)-10),.)"/> - citation is in parenthetic style, but the preceding text ends with '<value-of select="substring($pre-text,string-length($pre-text)-6)"/>' which suggests it should be in the style - <value-of select="$cite2"/></report>
      
      <report test="((matches($post-text,'^[,]? who') and not(matches($pre-text,'[\(]+')))
        or (matches($post-text,'^[\),]? who') and matches($pre-sentence,'^\($')))
        and (. = $cite1)"
        role="warning"
        id="ref-xref-test-12"><value-of select="concat(.,substring($post-text,1,10))"/> - citation is in parenthetic style, but the following text begins with 'who', which suggests it should be in the style - <value-of select="$cite2"/></report>
      
      <report test="((matches($post-text,'^[,]? have') and not(matches($pre-text,'[\(]+')))
        or (matches($post-text,'^[\),]? have') and matches($pre-sentence,'^\($')))
        and (. = $cite1)"
        role="warning"
        id="ref-xref-test-13"><value-of select="concat(.,substring($post-text,1,10))"/> - citation is in parenthetic style, but the following text begins with 'have', which suggests it should be in the style - <value-of select="$cite2"/></report>
      
      <report test="((matches($post-text,'^[,]? found') and not(matches($pre-text,'[\(]+')))
        or (matches($post-text,'^[\),]? found') and matches($pre-sentence,'^\($')))
        and (. = $cite1)"
        role="warning"
        id="ref-xref-test-23"><value-of select="concat(.,substring($post-text,1,10))"/> - citation is in parenthetic style, but the following text begins with 'found', which suggests it should be in the style - <value-of select="$cite2"/></report>
      
      <report test="((matches($post-text,'^[,]? used') and not(matches($pre-text,'[\(]+')))
        or (matches($post-text,'^[\),]? used') and matches($pre-sentence,'^\($')))
        and (. = $cite1)"
        role="warning"
        id="ref-xref-test-25"><value-of select="concat(.,substring($post-text,1,10))"/> - citation is in parenthetic style, but the following text begins with 'used', which suggests it should be in the style - <value-of select="$cite2"/></report>
      
      <report test="((matches($post-text,'^[,]? demonstrate') and not(matches($pre-text,'[\(]+')))
        or (matches($post-text,'^[\),]? demonstrate') and matches($pre-sentence,'^\($')))
        and (. = $cite1)"
        role="warning"
        id="ref-xref-test-26"><value-of select="concat(.,substring($post-text,1,10))"/> - citation is in parenthetic style, but the following text begins with 'demonstrate', which suggests it should be in the style - <value-of select="$cite2"/></report>
      
      <report test="matches($pre-sentence,$cite3)"
        role="warning"
        id="ref-xref-test-14">citation is preceded by text containing much of the citation text which is possibly unnecessary - <value-of select="concat($pre-sentence,.)"/></report>
      
      <report test="matches($post-sentence,$cite3)"
        role="warning"
        id="ref-xref-test-15">citation is followed by text containing much of the citation text. Is this correct? - <value-of select="concat(.,$post-sentence)"/></report>
      
      <report test="matches($post-sentence,'^[\)][\)]+')"
        role="error"
        id="ref-xref-test-16">citation is followed by text starting with 2 or more closing brackets, which must be incorrect - <value-of select="concat(.,$post-sentence)"/></report>
      
      <report test="(not(matches($pre-sentence,'[\(]$|\[$|^[\)]'))) and (not(matches($pre-text,'; $| and $| see $|cf\. $'))) and (($open - $close) = 0) and (. = $cite1) and not(ancestor::td) and not(ancestor::th) and not(matches($post-sentence,'^[\)]'))"
        role="warning"
        id="ref-xref-test-17">citation is in parenthetic format - <value-of select="."/> - but the preceding text does not contain open parentheses. Should it be in the format - <value-of select="$cite2"/>?</report>
      
      <report test="($pre-sentence = ', ') and (($open - $close) = 0) and (. = $cite1) and not(ancestor::td)"
        role="warning"
        id="ref-xref-test-18">citation is in parenthetic format, but the preceding text is ', ' . Should the preceding text be '; ' instead? <value-of select="concat($pre-sentence,.)"/></report>
      
      <report test="matches(.,'^et al|^ and|^[\(]\d|^,')"
        role="error"
        id="ref-xref-test-19"><value-of select="."/> - citation doesn't start with an author's name which is incorrect.</report>
      
      <report test="matches($post-text,'^[\)];\s?$') and (following-sibling::*[1]/local-name() = 'xref')"
        role="error"
        id="ref-xref-test-20">citation is followed by ');', which in turn is followed by another link. This must be incorrect (the bracket should be removed) - '<value-of select="concat(.,$post-sentence,following-sibling::*[1])"/>'.</report>
      
      <report test="matches($pre-sentence,'[A-Za-z0-9][\(]$')"
        role="warning"
        id="ref-xref-test-21">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-sentence,.)"/>'.</report>
      
      <report test="matches($post-sentence,'^[\)][A-Za-z0-9]')"
        role="warning"
        id="ref-xref-test-22">citation is followed by a ')' which in turns is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-sentence)"/>'.</report>
      
      <report test="(.=$cite1) and ((preceding-sibling::*[1]/local-name()!='xref') or not(preceding-sibling::*[1])) and matches($post-sentence,'^\]') and matches($pre-sentence,'\[$') and not(matches($pre-sentence,'\(')) and not(matches($post-sentence,'^\]\)'))"
        role="warning"
        id="ref-xref-test-24">citation is surrounded by square brackets, do the square brackets need removing? - '<value-of select="concat($pre-sentence,.,$post-sentence)"/>' - it doesn't seem to be already inside round brackets (a parenthetic reference inside parentheses) which is against house style.</report>
      
    </rule>
    
  </pattern>
  
  <pattern id="unlinked-ref-cite-pattern">
    
    <rule context="ref-list/ref/element-citation" id="unlinked-ref-cite">
      <let name="id" value="parent::ref/@id"/>
      <let name="cite1" value="e:citation-format1(descendant::year[1])"/>
      <let name="cite1.5" value="e:citation-format2(descendant::year[1])"/>
      <let name="cite2" value="concat(substring-before($cite1.5,'('),'\(',descendant::year[1],'\)')"/>
      <let name="regex" value="concat($cite1,'|',$cite2)"/>
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
    
    <rule context="article[back/ref-list]"
      id="missing-ref-cited">
      <let name="article-text" value="string-join(for $x in self::*/*[local-name() = 'body' or local-name() = 'back']//*
        return 
        if ($x/ancestor::sec[@sec-type='data-availability']) then ()
        else if ($x/ancestor::sec[@sec-type='additional-information']) then ()
        else if ($x/ancestor::ref-list) then ()
        else if ($x/local-name() = 'xref') then ()
        else $x/text(),'')"/>
      <let name="ref-list-regex" value="string-join(for $x in self::*//ref-list/ref/element-citation/year
        return concat(e:citation-format1($x),'|',e:citation-format2($x))
        ,'|')"/>
      <let name="missing-ref-text" value="replace($article-text,$ref-list-regex,'')"/>
      <let name="missing-ref-regex" value="'[A-Z][A-Za-z]+ et al\.?, [1][7-9][0-9][0-9]|[A-Z][A-Za-z]+ et al\.?, [2][0-2][0-9][0-9]|[A-Z][A-Za-z]+ et al\.? [\(]?[1][7-9][0-9][0-9][\)]?|[A-Z][A-Za-z]+ et al\.? [\(]?[1][7-9][0-9][0-9][\)]?'"/>
      
      <report test="($ref-list-regex !='') and matches($missing-ref-text,$missing-ref-regex)"
        role="warning" 
        id="missing-ref-in-text-test">There may be citations to missing references in the text - search - <value-of select="string-join(for $x in tokenize($missing-ref-text,'\. ')
          return 
          if (matches($x,$missing-ref-regex)) then $x else (),' -- -- ')"/></report>
      
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
      
      <assert test="contains(.,$target-no)"
        role="error" 
        id="vid-xref-conformity-2">video citation does not matches the video that it links to (target video label number is <value-of select="$target-no"/>, but that number is not in the citation).</assert>
      
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
      
    </rule>
  </pattern>
  <pattern id="figure-xref-pattern">
    
    <rule context="xref[@ref-type='fig']" id="fig-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="type" value="e:fig-id-type($rid)"/>
      <let name="no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="target-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
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
      
      <report test="not(ancestor::supplementary-material) and (ancestor::fig/@id = $rid)"
        role="warning"
        id="fig-xref-test-4"><value-of select="."/> - Figure citation is in the caption of the figure that it links to. Is it correct or necessary?</report>
      
      <report test="($type = 'Figure') and (matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')"
        role="error"
        id="fig-xref-test-5"><value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Figure citation is in a reference to a figure from a different paper, and therefore must be unlinked.</report>
      
      <report test="matches($pre-text,'[A-Za-z0-9][\(]$')"
        role="warning"
        id="fig-xref-test-6">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($post-text,'^[\)][A-Za-z0-9]')"
        role="warning"
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
        role="error" 
        id="fig-xref-test-12">Incomplete citation. Figure citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($post-text,'^[\s]?[Ss]upplement|^[\s]?[Ff]igure [Ss]upplement|^[\s]?[Ss]ource|^[\s]?[Vv]ideo')" 
        role="warning" 
        id="fig-xref-test-13">Figure citation is followed by text which suggests it could be an incomplete citation - <value-of select="concat(.,$post-text)"/>'. Is this OK?</report>
    </rule>
  </pattern>
  
  <pattern id="table-xref-pattern">
    <rule context="xref[@ref-type='table']" id="table-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="text-no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="rid-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      
      <report test="not(matches(.,'Table')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ') and not(contains($rid,'app')) and not(contains($rid,'resp'))"
        role="warning" 
        id="table-xref-conformity-1"><value-of select="."/> - citation points to table, but does not include the string 'Table', which is very unusual.</report>
      
      <report test="not(matches(.,'table')) and ($pre-text != ' and ') and ($pre-text != '–') and ($pre-text != ', ') and contains($rid,'app')"
        role="warning" 
        id="table-xref-conformity-2"><value-of select="."/> - citation points to an Appendix table, but does not include the string 'table', which is very unusual.</report>
      
      <report test="(not(contains($rid,'app'))) and ($text-no != $rid-no) and not(contains(.,'–'))"
        role="error" 
        id="table-xref-conformity-3"><value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report test="(contains($rid,'app')) and (not(ends-with($text-no,substring($rid-no,2,1)))) and not(contains(.,'–'))"
        role="error" 
        id="table-xref-conformity-4"><value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report test="(ancestor::table-wrap/@id = $rid) and not(ancestor::supplementary-material)"
        role="warning"
        id="table-xref-test-1"><value-of select="."/> - Citation is in the caption of the Table that it links to. Is it correct or necessary?</report>
      
      <report test="matches($pre-text,'[A-Za-z0-9][\(]$')"
        role="warning"
        id="table-xref-test-2">citation is preceded by a letter or number immediately followed by '('. Is there a space missing before the '('?  - '<value-of select="concat($pre-text,.)"/>'.</report>
      
      <report test="matches($post-text,'^[\)][A-Za-z0-9]')"
        role="warning"
        id="table-xref-test-3">citation is followed by a ')' which in turns is immediately followed by a letter or number. Is there a space missing after the ')'?  - '<value-of select="concat(.,$post-text)"/>'.</report>
      
      <report test="matches($post-text,'^[\s]?[\s—\-][\s]?[Ss]ource')" 
        role="error" 
        id="table-xref-test-4">Incomplete citation. Table citation is followed by text which suggests it should instead be a link to source data or code - <value-of select="concat(.,$post-text)"/>'.</report>
      
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
        role="error" 
        id="equ-xref-conformity-2"><value-of select="$label"/> - equation link content does not match what it directs to. Check that it is correct.</assert>
      
      <report test="(matches($post-text,'^ in $|^ from $|^ of $')) and (following-sibling::*[1]/@ref-type='bibr')"
        role="error"
        id="equ-xref-conformity-3"><value-of select="concat(.,$post-text,following-sibling::*[1])"/> - Equation citation appears to be a reference to an equation from a different paper, and therefore must be unlinked.</report>
    </rule>
    
  </pattern>
  
  <pattern
    id="org-pattern">
    
    <rule context="element-citation[@publication-type='journal']/article-title"
      id="org-ref-article-book-title">	
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
    
    <rule context="article//article-meta/title-group/article-title | article/body//sec/title | article//article-meta//kwd"
      id="org-title-kwd">		
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
  
  <pattern
    id="house-style">
    
    <rule context="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link"
      id="unallowed-symbol-tests">		
      
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
      
      <report test="not(ancestor::sub-article) and matches(.,'\s?[Ss]upplemental [Ff]igure')"
        role="warning"
        id="supplementalfigure-presence"><name/> element contains the phrase ' Supplemental figure ' which almost certainly needs updating. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report test="not(ancestor::sub-article) and matches(.,'\s?[Ss]upplemental [Ff]ile')"
        role="warning"
        id="supplementalfile-presence"><name/> element contains the phrase ' Supplemental file ' which almost certainly needs updating. <name/> starts with - <value-of select="substring(.,1,25)"/></report>
      
      <report test="not(ancestor::sub-article) and matches(.,' [Rr]ef\. ')"
        role="error"
        id="ref-presence"><name/> element contains 'Ref.' which is either incorrect or unnecessary.</report>
      
      <report test="not(ancestor::sub-article) and matches(.,' [Rr]efs\. ')"
        role="error"
        id="refs-presence"><name/> element contains 'Refs.' which is either incorrect or unnecessary.</report>
      
      <report test="matches(.,'�')"
        role="error"
        id="replacement-character-presence"><name/> element contains the replacement character '�' which is not allowed.</report>
      
      <report test="matches(.,'')"
        role="error"
        id="junk-character-presence"><name/> element contains a junk character '' which should be replaced.</report>
      
      <report test="matches(.,'¿')"
        role="warning"
        id="inverterted-question-presence"><name/> element contains an inverted question mark '¿' which should very likely be replaced/removed.</report>
      
      <report test="some $x in self::*[not(local-name() = ('monospace','code'))]/text() satisfies matches($x,'\(\)|\[\]')"
        role="warning"
        id="empty-parentheses-presence"><name/> element contains empty parentheses ('[]', or '()'). Is there a missing citation within the parentheses? Or perhaps this is a piece of code that needs formatting?</report>
    </rule>
    
    <rule context="sup"
      id="unallowed-symbol-tests-sup">		
      
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
    
    <rule context="front//aff/country"
      id="country-tests">
      <let name="text" value="self::*/text()"/>
      <let name="countries" value="'countries.xml'"/>
      <let name="city" value="parent::aff//named-content[@content-type='city']"/>
      <let name="valid-country" value="document($countries)/countries/country[text() = $text]"/>
      
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
    </rule>
    
    <rule context="front//aff//named-content[@content-type='city']"
      id="city-tests">
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
    </rule>
    
    <rule context="aff/institution[not(@*)]" 
      id="institution-tests">
      
      <report test="matches(normalize-space(.),'^[Uu]niversity of [Cc]alifornia$')"
        role="error" 
        id="UC-no-test1"><value-of select="."/> is not allowed as insitution name, since this is always followed by city name. This should very likely be <value-of select="concat('University of California, ',following-sibling::addr-line/named-content[@content-type='city'])"/> (provided there is a city tagged).</report>
      
      <report test="matches(.,'�')"
        role="error"
        id="institution-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed.</report>
      
    </rule>
    
    <rule context="aff/institution[@content-type='dept']" 
      id="department-tests">
      
      <report test="matches(.,'[Dd]epartments')"
        role="error" 
        id="plural-test-1"><value-of select="ancestor::aff/@id"/> contains a department with the plural for department - <value-of select="."/>. Should this be split out inot two separate affiliations?</report>
      
      <report test="matches(.,'^[Ii]nstitutes')"
        role="error" 
        id="plural-test-2"><value-of select="ancestor::aff/@id"/> contains a department with the plural for institute - <value-of select="."/>. Should this be split out inot two separate affiliations?</report>
      
      <report test="matches(.,'^[Dd]epartment .* [Dd]epartment')"
        role="error" 
        id="plural-test-3"><value-of select="ancestor::aff/@id"/> contains a department which has two instances of the word 'department' - <value-of select="."/>. Should this be split out into two separate affiliations?</report>
      
      <report test="matches(.,'^[Ii]nstitute .* [Ii]nstitute')"
        role="error" 
        id="plural-test-4"><value-of select="ancestor::aff/@id"/> contains a department which has two instances of the word 'institution' - <value-of select="."/>. Should this be split out into two separate affiliations?</report>
      
      <report test="matches(.,'�')"
        role="error"
        id="dept-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed.</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/source" id="journal-title-tests">
      <let name="doi" value="ancestor::element-citation/pub-id[@pub-id-type='doi']"/>
      <let name="uc" value="upper-case(.)"/>
        
      <report test="($uc != 'PLOS ONE') and matches(.,'plos|Plos|PLoS')"
        role="error" 
        id="PLOS-1">ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'PLOS' should be upper-case.</report>
        
       <report test="($uc = 'PLOS ONE') and (. != 'PLOS ONE')"
          role="error" 
          id="PLOS-2">ref '<value-of select="ancestor::ref/@id"/>' contains
          <value-of select="."/>. 'PLOS ONE' should be upper-case.</report>
      
      <report test="if (starts-with($doi,'10.1073')) then . != 'PNAS'
        else()"
        role="error" 
        id="PNAS">ref '<value-of select="ancestor::ref/@id"/>' has the doi for 'PNAS' but the title is
        <value-of select="."/>, which is incorrect.</report>
      
      <report test="($uc = 'RNA') and (. != 'RNA')"
        role="error" 
        id="RNA">ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'RNA' should be upper-case.</report>
      
      <report test="(matches($uc,'^BMJ$|BMJ[:]? ')) and matches(.,'Bmj|bmj|BMj|BmJ|bMj|bmJ')"
        role="error" 
        id="bmj">ref '<value-of select="ancestor::ref/@id"/>' contains
        <value-of select="."/>. 'BMJ' should be upper-case.</report>
      
      <report test="starts-with($doi,'10.1534/g3') and (. != 'G3: Genes|Genomes|Genetics') and (. != 'G3: Genes, Genomes, Genetics')"
        role="error" 
        id="G3">ref '<value-of select="ancestor::ref/@id"/>' has the doi for 'G3' but the title is
        <value-of select="."/> - it should be either 'G3: Genes|Genomes|Genetics' or 'G3: Genes, Genomes, Genetics'.</report>
      
      <report test="matches(.,'\s?[Aa]mp[;]?\s?') and (. != 'Hippocampus')"
        role="warning" 
        id="ampersand-check">ref '<value-of select="ancestor::ref/@id"/>' appears to contain the text 'amp', is this a broken ampersand?</report>
      
      <report test="$uc = 'RESEARCH GATE'"
        role="warning" 
        id="Research-gate-check"> ref '<value-of select="ancestor::ref/@id"/>' has a source title '<value-of select="."/>' which must be incorrect.</report>
      
      <report test="matches(.,'�')"
        role="error"
        id="journal-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
      <report test="matches(.,'[Oo]fficial [Jj]ournal')"
        role="warning"
        id="journal-off-presence">ref '<value-of select="ancestor::ref/@id"/>' has a source title which contains the text 'official journal' - '<value-of select="."/>'. Is this necessary?</report>
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/article-title" id="ref-article-title-tests">
      <let name="rep" value="replace(.,' [Ii]{1,3}\. | IV\. | V. | [Cc]\. [Ee]legans| vs\. | sp\. ','')"/>
      
      <report test="(matches($rep,'[A-Za-z][A-Za-z]+\. [A-Za-z]'))"
        role="info" 
        id="article-title-fullstop-check-1">ref '<value-of select="ancestor::ref/@id"/>' has an article-title with a full stop. Is this correct, or has the journal/source title been included? Or perhaps the full stop should be a colon ':'?</report>
      
      <report test="matches(.,'\.$') and not(matches(.,'\.\.$'))"
        role="error" 
        id="article-title-fullstop-check-2">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which ends with a full stop, which cannot be correct - <value-of select="."/></report>
      
      <report test="matches(.,'\.$') and matches(.,'\.\.$')"
        role="warning" 
        id="article-title-fullstop-check-3">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which ends with some full stops - is this correct? - <value-of select="."/></report>
      
      <report test="matches(.,'^[Cc]orrection|^[Rr]etraction|[Ee]rratum')"
        role="warning" 
        id="article-title-correction-check">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which begins with 'Correction', 'Retraction' or 'Erratum'. Is this a reference to the notice or the original article?</report>
      
      <report test="matches(.,' [Jj]ournal ')"
        role="warning" 
        id="article-title-journal-check">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which contains the text ' journal '. Is a journal title (source) erroneously included in the title? - '<value-of select="."/>'</report>
      
      <report test="(count(child::*) = 1) and (count(child::text()) = 0)"
        role="warning" 
        id="article-title-child-1">ref '<value-of select="ancestor::ref/@id"/>' has an article-title with one child <value-of select="*/local-name()"/> element, and no text. This is almost certainly incorrect. - <value-of select="."/></report>
      
      <report test="matches(.,'�')"
        role="error"
        id="a-title-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']" 
      id="journal-tests">
      
      <report test="not(fpage) and not(elocation-id) and not(comment)"
        role="warning" 
        id="eloc-page-assert">ref '<value-of select="ancestor::ref/@id"/>' is a journal, but it doesn't have a page range or e-location. Is this right?</report>
      
      <report test="matches(normalize-space(lower-case(source)),'^biorxiv$|^arxiv$|^chemrxiv$|^peerj preprints$|^psyarxiv$|^paleorxiv$|^preprints$')"
        role="error" 
        id="journal-preprint-check">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="source"/>, but it is captured as a journal not a preprint.</report>
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/source" 
      id="preprint-title-tests">
      <let name="lc" value="lower-case(.)"/>
      
      <report test="not(matches($lc,'biorxiv|arxiv|chemrxiv|peerj preprints|psyarxiv|paleorxiv|preprints'))"
        role="warning" 
        id="not-rxiv-test">ref '<value-of select="ancestor::ref/@id"/>' is tagged as a preprint, but has a source <value-of select="."/>, which doesn't look like a preprint. Is it correct?</report>
      
      <report test="matches($lc,'biorxiv') and not(. = 'bioRxiv')"
        role="error" 
        id="biorxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'bioRxiv'.</report>
      
      <report test="matches($lc,'^arxiv$') and not(. = 'arXiv')"
        role="error" 
        id="arxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'arXiv'.</report>
      
      <report test="matches($lc,'chemrxiv') and not(. = 'ChemRxiv')"
        role="error" 
        id="chemrxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'ChemRxiv'.</report>
      
      <report test="matches($lc,'peerj preprints') and not(. = 'PeerJ Preprints')"
        role="error" 
        id="peerjpreprints-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PeerJ Preprints'.</report>
      
      <report test="matches($lc,'psyarxiv') and not(. = 'PsyArXiv')"
        role="error" 
        id="psyarxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PsyArXiv'.</report>
      
      <report test="matches($lc,'paleorxiv') and not(. = 'PaleorXiv')"
        role="error" 
        id="paleorxiv-test">ref '<value-of select="ancestor::ref/@id"/>' has a source <value-of select="."/>, which is not the correct proprietary capitalisation - 'PaleorXiv'.</report>
      
      <report test="matches(.,'�')"
        role="error"
        id="preprint-replacement-character-presence"><name/> element contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='web']" 
      id="website-tests">
      <let name="link" value="lower-case(ext-link)"/>
      
      <report test="contains($link,'github')"
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
    
    <rule context="element-citation[@publication-type='software']" 
      id="software-ref-tests">
      <let name="lc" value="lower-case(data-title[1])"/>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and not(matches(person-group[@person-group-type='author']/collab[1],'^R Development Core Team$'))"
        role="error" 
        id="R-test-1">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but it does not have one collab element containing 'R Development Core Team'.</report>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and (count(person-group[@person-group-type='author']/collab) != 1)"
        role="error" 
        id="R-test-2">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but it has <value-of select="count(person-group[@person-group-type='author']/collab)"/> collab element(s).</report>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and (count((publisher-loc[text() = 'Vienna, Austria'])) != 1)"
        role="error"
        id="R-test-3">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but does not have a &lt;publisher-loc&gt;Vienna, Austria&lt;/publisher-loc&gt; element.</report>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and not(matches(ext-link[1]/@xlink:href,'^http[s]?://www.[Rr]-project.org'))" 
        role="error" 
        id="R-test-4">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but does not have a 'http://www.[Rr]-project.org' link.</report>
      
      <report test="matches(lower-case(source),'r: a language and environment for statistical computing')"
        role="error" 
        id="R-test-5">software ref '<value-of select="ancestor::ref/@id"/>' has a source - <value-of select="source"/> - but this is the data-title.</report>
      
      <report test="matches(.,'�')"
        role="error"
        id="software-replacement-character-presence">software citation contains the replacement character '�' which is unallowed - <value-of select="."/></report>
      
    </rule>
    
    <rule context="element-citation/publisher-name" id="publisher-name-tests">
      
      <report test="matches(.,':')"
        role="warning" 
        id="publisher-name-colon">ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing a colon. Should the text preceding the colon instead be captured as publisher-loc?</report>
      
      <report test="matches(.,'[Ii]nc\.')"
        role="warning" 
        id="publisher-name-inc">ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing the text 'Inc.' Should the fullstop be removed?</report>
      
      <report test="matches(.,'�')"
        role="error"
        id="pub-name-replacement-character-presence"><name/> contains the replacement character '�' which is unallowed - <value-of select="."/></report>
    </rule>
    
    <rule context="element-citation//name" 
      id="ref-name-tests">
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
    
    <rule context="element-citation[(@publication-type='journal') and (fpage or lpage)]" 
      id="page-conformity">
      <let name="cite" value="e:citation-format1(year)"/>
      
      <report test="matches(lower-case(source),'plos|^elife$|^mbio$')"
        role="error" 
        id="online-journal-w-page"><value-of select="$cite"/> is a <value-of select="source"/> article, but has a page number, which is incorrect.</report>
      
    </rule>
    
    <rule context="element-citation/pub-id[@pub-id-type='isbn']" 
      id="isbn-conformity">
      <let name="t" value="translate(.,'-','')"/>
      <let name="sum" value="e:isbn-sum($t)"/>
      
      <assert test="number($sum) = 0"
        role="error" 
        id="isbn-conformity-test">pub-id contains an invalid ISBN. Should it be captured as another type of pub-id?</assert>
    </rule>
    
    <rule context="isbn" 
      id="isbn-conformity-2">
      <let name="t" value="translate(.,'-','')"/>
      <let name="sum" value="e:isbn-sum($t)"/>
      
      <assert test="number($sum) = 0"
        role="error" 
        id="isbn-conformity-test-2">isbn contains an invalid ISBN. Should it be captured as another type of pub-id?</assert>
    </rule>
    
    <rule context="sec[@sec-type='data-availability']/p[1]" 
      id="data-availability-statement">
      
      <assert test="matches(.,'\.$|\?$')"
        role="error" 
        id="das-sentence-conformity">The Data Availability Statement must end with a full stop.</assert>
      
      <report test="matches(.,'[Dd]ryad') and not(parent::sec//element-citation/pub-id[@assigning-authority='Dryad'])"
        role="error" 
        id="das-dryad-conformity">Data Availability Statement contains the word Dryad, but there is no data citation in the dataset section with a dryad assigning authority.</report>
      
      <report test="matches(.,'[Ss]upplemental [Ffigure]')"
        role="warning" 
        id="das-supplemental-conformity">Data Availability Statement contains the phrase 'supplemental figure'. This will almost certainly need updating to account for eLife's figure labelling.</report>
      
      <report test="matches(.,'[Rr]equest')"
        role="warning" 
        id="das-request-conformity-1">Data Availability Statement contains the phrase 'request'. Does it state data is avaialble upon request, and if so, has this been approved by editorial?</report>
      
      <report test="matches(.,'10\.\d{4,9}/[-._;()/:A-Za-z0-9]+$') and not(matches(.,'http[s]?://doi.org/'))"
        role="error" 
        id="das-doi-conformity-1">Data Availability Statement contains a doi, but it does not contain 'https://doi.org/'. All dois should be updated to include a full 'https://doi.org/...' type link.</report>
      
    </rule>
    
    <rule context="fn-group[@content-type='ethics-information']/fn" 
      id="ethics-info">
      
      <assert test="matches(replace(normalize-space(.),'&quot;',''),'\.$|\?$')"
        role="error" 
        id="ethics-info-conformity">The ethics statement must end with a full stop.</assert>
      
      <report test="matches(.,'[Ss]upplemental [Ffigure]')"
        role="warning" 
        id="ethics-info-supplemental-conformity">Ethics statement contains the phrase 'supplemental figure'. This will almost certainly need updating to account for eLife's figure labelling.</report>
      
    </rule>
    
    <rule context="sec/title" 
      id="sec-title-conformity">
      <let name="free-text" value="replace(
        normalize-space(string-join(for $x in self::*/text() return $x,''))
        ,'&#x00A0;','')"/>
      
      <report test="matches(.,'^[A-Za-z]{1,3}\)|^\([A-Za-z]{1,3}')"
        role="warning" 
        id="sec-title-list-check">Section title might start with a list indicator - '<value-of select="."/>'. Is this correct?</report>
      
      <report test="matches(.,'^[Aa]ppendix')"
        role="warning" 
        id="sec-title-appendix-check">Section title contains the word appendix - '<value-of select="."/>'. Should it be captured as an appendix?</report>
      
      <report test="matches(.,'^[Aa]bbreviation[s]?')"
        role="warning" 
        id="sec-title-abbr-check">Section title contains the word abbreviation - '<value-of select="."/>'. Is it an abbreviation section? eLife house style is to define abbreviations in the text when they are first mentioned.</report>
      
      <report test="not(*) and (normalize-space(.)='')"
        role="error" 
        id="sec-title-content-mandate">Section title must not be empty.</report>
      
      <report test="matches(replace(.,'&#x00A0;',' '),'\.[\s]*$')"
        role="warning" 
        id="sec-title-full-stop">Section title ends with full stop, which is very likely to be incorrect - <value-of select="."/></report>
      
      <report test="(count(*) = 1) and child::bold and ($free-text='')"
        role="error" 
        id="sec-title-bold">All section title content is captured in bold. This is incorrect - <value-of select="."/></report>
      
      <report test="(count(*) = 1) and child::underline and ($free-text='')"
        role="error" 
        id="sec-title-underline">All section title content is captured in underline. This is incorrect - <value-of select="."/></report>
      
      <report test="(count(*) = 1) and child::italic and ($free-text='')"
        role="warning" 
        id="sec-title-italic">All section title content is captured in italics. This is very likely to be incorrect - <value-of select="."/></report>
      
    </rule>
    
    <rule context="abstract[not(@*)]" 
      id="abstract-house-tests">
      <let name="subj" value="parent::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject"/>
      
      <report test="descendant::xref[@ref-type='bibr']"
        role="warning" 
        id="xref-bibr-presence">Abstract contains a citation - '<value-of select="descendant::xref[@ref-type='bibr'][1]"/>' - which isn't usually allowed. Check that this is correct.</report>
      
      <report test="($subj = 'Research Communication') and (not(matches(self::*/descendant::p[2],'^Editorial note')))"
        role="warning" 
        id="pre-res-comm-test">'<value-of select="$subj"/>' has only one paragraph in its abstract or the second paragraph does not begin with 'Editorial note', which is incorrect. Please ensure to check with eLife staff for the required wording.</report>
      
      <report test="($subj = 'Research Communication') and (not(matches(self::*/descendant::p[2],'^Editorial note')))"
        role="error" 
        id="final-res-comm-test">'<value-of select="$subj"/>' has only one paragraph in its abstract or the second paragraph does not begin with 'Editorial note', which is incorrect.</report>
     
      <report test="(count(p) > 1) and ($subj = 'Research Article')"
        role="warning" 
        id="res-art-test">'<value-of select="$subj"/>' has more than one paragraph in its abstract, is this correct?</report>
    </rule>
    
    <rule context="table-wrap[@id='keyresource']//xref[@ref-type='bibr']" 
      id="KRT-xref-tests">
      
      <report test="(count(ancestor::*:td/preceding-sibling::td) = 0) or (count(ancestor::*:td/preceding-sibling::td) = 1) or (count(ancestor::*:td/preceding-sibling::td) = 3)"
        role="warning" 
        id="xref-colum-test">'<value-of select="."/>' citation is in a column in the Key Resources Table which usually does not include references. Is it correct?</report>
      
    </rule>
    
    <rule context="article" 
      id="KRT-check">
      <let name="subj" value="descendant::subj-group[@subj-group-type='display-channel']/subject"/>
      <let name="methods" value="('model', 'methods', 'materials|methods')"/>
      
      <report test="($subj = 'Research Article') and not(descendant::table-wrap[@id = 'keyresource']) and (descendant::sec[@sec-type=$methods]/*[2]/local-name()='table-wrap')"
        role="warning" 
        id="KRT-presence">'<value-of select="$subj"/>' does not have a key resources table, but the <value-of select="descendant::sec[@sec-type=$methods]/title"/> starts with a table. Should this table be a key resources table?</report>
      
    </rule>
    
    <rule context="table-wrap[@id='keyresource']//td" 
      id="KRT-td-checks">
      
      <report test="matches(.,'10\.\d{4,9}/') and (count(ext-link[contains(@xlink:href,'doi.org')]) = 0)"
        role="error" 
        id="doi-link-test">td element containing - '<value-of select="."/>' - looks like it contains a doi, but it contains no link with 'doi.org', which is incorrect.</report>
      
      <report test="matches(.,'[Pp][Mm][Ii][Dd][:]?\s?[0-9][0-9][0-9][0-9]+') and (count(ext-link[contains(@xlink:href,'www.ncbi.nlm.nih.gov/pubmed/')]) = 0)"
        role="error" 
        id="PMID-link-test">td element containing - '<value-of select="."/>' - looks like it contains a PMID, but it contains no link pointing to PubMed, which is incorrect.</report>
      
      <report test="matches(.,'PMCID[:]?\s?PMC[0-9][0-9][0-9]+') and (count(ext-link[contains(@xlink:href,'www.ncbi.nlm.nih.gov/pmc')]) = 0)"
        role="error" 
        id="PMCID-link-test">td element containing - '<value-of select="."/>' - looks like it contains a PMCID, but it contains no link pointing to PMC, which is incorrect.</report>
      
    </rule>
    
    <rule context="th|td" 
      id="colour-table">
      
      <report test="starts-with(@style,'author-callout')"
        role="warning" 
        id="colour-check-table"><name/> element has colour background. Is this correct? It contains <value-of select="."/></report>
    </rule>
    
    <rule context="named-content" 
      id="colour-named-content">
      <let name="prec-text" value="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>
      
      <report test="starts-with(@content-type,'author-callout')"
        role="warning" 
        id="colour-named-content-check"><value-of select="."/> has colour formatting. Is this correct? Preceding text - <value-of select="$prec-text"/></report>
    </rule>
    
    <rule context="styled-content" 
      id="colour-styled-content">
      <let name="parent" value="parent::*/local-name()"/>
      <let name="prec-text" value="substring(preceding-sibling::text()[1],string-length(preceding-sibling::text()[1])-25)"/>
      
      <report test="."
        role="warning" 
        id="colour-styled-content-check">'<value-of select="."/>' - <value-of select="$parent"/> element contains a styled content element. Is this correct?  Preceding text - <value-of select="concat($prec-text,.)"/></report>
    </rule>
    
    <rule context="article/body//p[not(parent::list-item)]" 
      id="p-punctuation">
      <let name="para" value="replace(.,'&#x00A0;',' ')"/>
      
      <report test="if (ancestor::article[@article-type=('correction','retraction')]) then () else if ((ancestor::article[@article-type='article-commentary']) and (count(preceding::p[ancestor::body]) = 0)) then () else if (descendant::*[last()]/ancestor::disp-formula) then () else not(matches($para,'\p{P}\s*?$'))"
        role="warning" 
        id="p-punctuation-test">paragraph doesn't end with punctuation - Is this correct?</report>
      
      <report test="if (ancestor::article[@article-type=('correction','retraction')]) then () else if ((ancestor::article[@article-type='article-commentary']) and (count(preceding::p[ancestor::body]) = 0)) then () else if (descendant::*[last()]/ancestor::disp-formula) then () else not(matches($para,'\.\s*?$|:\s*?$|\?\s*?$|!\s*?$|\.”\s*?|\.&quot;\s*?'))"
        role="warning" 
        id="p-bracket-test">paragraph doesn't end with a full stop, colon, question or excalamation mark - Is this correct?</report>
    </rule>
    
    <rule context="italic[not(ancestor::ref)]"
        id="italic-house-style">  
      
      <report test="matches(.,'et al[\.]?')"
        role="error"
        id="pre-et-al-italic-test"><name/> element contains 'et al.' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'et al[\.]?')"
        role="warning"
        id="final-et-al-italic-test"><name/> element contains 'et al.' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Vv]itro')"
        role="error"
        id="pre-in-vitro-italic-test"><name/> element contains 'in vitro' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ii]n [Vv]itro')"
        role="warning"
        id="final-in-vitro-italic-test"><name/> element contains 'in vitro' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Vv]ivo')"
        role="error"
        id="pre-in-vivo-italic-test"><name/> element contains 'in vivo' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ii]n [Vv]ivo')"
        role="warning"
        id="final-in-vivo-italic-test"><name/> element contains 'in vivo' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ee]x [Vv]ivo')"
        role="error"
        id="pre-ex-vivo-italic-test"><name/> element contains 'ex vivo' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ee]x [Vv]ivo')"
        role="warning"
        id="final-ex-vivo-italic-test"><name/> element contains 'ex vivo' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Aa] [Pp]riori')"
        role="error"
        id="pre-a-priori-italic-test"><name/> element contains 'a priori' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Aa] [Pp]riori')"
        role="warning"
        id="final-a-priori-italic-test"><name/> element contains 'a priori' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Aa] [Pp]osteriori')"
        role="error"
        id="pre-a-posteriori-italic-test"><name/> element contains 'a posteriori' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Aa] [Pp]osteriori')"
        role="warning"
        id="final-a-posteriori-italic-test"><name/> element contains 'a posteriori' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Dd]e [Nn]ovo')"
        role="error"
        id="pre-de-novo-italic-test"><name/> element contains 'de novo' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Dd]e [Nn]ovo')"
        role="warning"
        id="final-de-novo-italic-test"><name/> element contains 'de novo' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Uu]tero')"
        role="error"
        id="pre-in-utero-italic-test"><name/> element contains 'in utero' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ii]n [Uu]tero')"
        role="warning"
        id="final-in-utero-italic-test"><name/> element contains 'in utero' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Nn]atura')"
        role="error"
        id="pre-in-natura-italic-test"><name/> element contains 'in natura' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ii]n [Nn]atura')"
        role="warning"
        id="final-in-natura-italic-test"><name/> element contains 'in natura' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Ss]itu')"
        role="error"
        id="pre-in-situ-italic-test"><name/> element contains 'in situ' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ii]n [Ss]itu')"
        role="warning"
        id="final-in-situ-italic-test"><name/> element contains 'in situ' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ii]n [Pp]lanta')"
        role="error"
        id="pre-in-planta-italic-test"><name/> element contains 'in planta' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ii]n [Pp]lanta')"
        role="warning"
        id="final-in-planta-italic-test"><name/> element contains 'in planta' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Rr]ete [Mm]irabile')"
        role="error"
        id="pre-rete-mirabile-italic-test"><name/> element contains 'rete mirabile' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Rr]ete [Mm]irabile')"
        role="warning"
        id="final-rete-mirabile-italic-test"><name/> element contains 'rete mirabile' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Nn]omen [Nn]ovum')"
        role="error"
        id="pre-nomen-novum-italic-test"><name/> element contains 'nomen novum' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Nn]omen [Nn]ovum')"
        role="warning"
        id="final-nomen-novum-italic-test"><name/> element contains 'nomen novum' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ss]ativum')"
        role="error"
        id="pre-sativum-italic-test"><name/> element contains 'sativum' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ss]ativum')"
        role="warning"
        id="final-sativum-italic-test"><name/> element contains 'sativum' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Ss]ensu')"
        role="error"
        id="pre-sensu-italic-test"><name/> element contains 'sensu' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Ss]ensu')"
        role="warning"
        id="final-sensu-italic-test"><name/> element contains 'sensu' - this should not be in italics (eLife house style).</report>  
      
      <report test="matches(.,'[Aa]d [Ll]ibitum')"
        role="error"
        id="pre-ad-libitum-italic-test"><name/> element contains 'ad libitum' - this should not be in italics (eLife house style).</report>

      <report test="matches(.,'[Aa]d [Ll]ibitum')"
        role="warning"
        id="final-ad-libitum-italic-test"><name/> element contains 'ad libitum' - this should not be in italics (eLife house style).</report>
      
      <report test="matches(.,'[Ii]n [Oo]vo')"
        role="error"
        id="pre-in-ovo-italic-test"><name/> element contains 'In Ovo' - this should not be in italics (eLife house style).</report>
      
      <report test="matches(.,'[Ii]n [Oo]vo')"
        role="warning"
        id="final-in-ovo-italic-test"><name/> element contains 'In Ovo' - this should not be in italics (eLife house style).</report>
      
    </rule>
    
    <rule context="list[@list-type]" 
      id="list-house-style">
      <let name="usual-types" value="('bullet','simple','order')"/>
      
      <assert test="@list-type = $usual-types"
        role="warning" 
        id="list-type-house-style-test"><name/> element is a list-type='<value-of select="@list-type"/>'. According to house style, bullets, numbers or no indicators should be used. Usual values - ('bullet','simple','order').</assert>
    </rule>
    
    <rule context="p//ext-link[not(ancestor::table-wrap) and not(ancestor::sub-article)]" 
      id="pubmed-link">
      
      <report test="matches(@xlink:href,'^http[s]?://www.ncbi.nlm.nih.gov/pubmed/[\d]*')"
        role="warning" 
        id="pubmed-presence"><value-of select="parent::*/local-name()"/> element contains what looks like a link to a PubMed article - <value-of select="."/> - should this be added a reference instead?</report>
      
      <report test="matches(@xlink:href,'^http[s]?://www.ncbi.nlm.nih.gov/pmc/articles/PMC[\d]*')"
        role="warning" 
        id="pmc-presence"><value-of select="parent::*/local-name()"/> element contains what looks like a link to a PMC article - <value-of select="."/> - should this be added a reference instead?</report>
      
    </rule>
    
    <rule context="ref-list/ref" 
      id="ref-link-mandate">
      <let name="id" value="@id"/>
      
      <assert test="ancestor::article//xref[@rid = $id]"
        role="warning" 
        id="pre-ref-link-presence">'<value-of select="$id"/>' has no linked citations. Either the reference should be removed or a citation linking to it needs to be added.</assert>
      
      <assert test="ancestor::article//xref[@rid = $id]"
        role="error" 
        id="final-ref-link-presence">'<value-of select="$id"/>' has no linked citations. Either the reference should be removed or a citation linking to it needs to be added.</assert>
    </rule>
    
    <rule context="fig|media[@mimetype='video']" 
      id="fig-permissions-check">
      <let name="label" value="replace(label,'\.','')"/>
      
      <report test="not(descendant::permissions) and matches(caption,'[Rr]eproduced from')"
        role="warning" 
        id="reproduce-test-1">The caption for <value-of select="$label"/> contains the text 'reproduced from', but has no permissions. Is this correct?</report>
      
      <report test="not(descendant::permissions) and matches(caption,'[Rr]eproduced [Ww]ith [Pp]ermission')"
        role="warning" 
        id="reproduce-test-2">The caption for <value-of select="$label"/> contains the text 'reproduced with permission', but has no permissions. Is this correct?</report>
      
      <report test="not(descendant::permissions) and matches(caption,'[Aa]dapted from|[Aa]dapted with')"
        role="warning" 
        id="reproduce-test-3">The caption for <value-of select="$label"/> contains the text 'adapted from ...', but has no permissions. Is this correct?</report>
      
      <report test="not(descendant::permissions) and matches(caption,'[Rr]eprinted from')"
        role="warning" 
        id="reproduce-test-4">The caption for <value-of select="$label"/> contains the text 'reprinted from', but has no permissions. Is this correct?</report>
      
      <report test="not(descendant::permissions) and matches(caption,'[Rr]eprinted [Ww]ith [Pp]ermission')"
        role="warning" 
        id="reproduce-test-5">The caption for <value-of select="$label"/> contains the text 'reprinted with permission', but has no permissions. Is this correct?</report>
    </rule>
    
    <rule context="xref[not(@ref-type='bibr')]" 
      id="xref-formatting">
      <let name="parent" value="parent::*/local-name()"/>
      <let name="child" value="child::*/local-name()"/>
      <let name="formatting-elems" value="('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')"/>
      
      <report test="$parent = $formatting-elems"
        role="error" 
        id="xref-parent-test">xref - <value-of select="."/> - has a formatting parent element - <value-of select="$parent"/> - which is not correct.</report>
      
      <report test="$child = $formatting-elems"
        role="warning" 
        id="xref-child-test">xref - <value-of select="."/> - has a formatting child element - <value-of select="$child"/> - which is likely not correct.</report>
    </rule>
    
    <rule context="xref[@ref-type='bibr']" 
      id="ref-xref-formatting">
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
    
    <rule context="article" 
      id="code-fork">
      <let name="test" value="e:code-check(.)"/>
      
      <report test="$test//*:match"
        role="warning" 
        id="code-fork-info">Article possibly contains code that needs forking. Search - <value-of select="string-join(for $x in $test//*:match return $x,', ')"/></report>
    </rule>
    
    <rule context="kwd-group[@kwd-group-type='author-keywords']/kwd" 
      id="auth-kwd-style">
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
    </rule>
  </pattern>
  
  <pattern
    id="element-whitelist-pattern">
    
    <rule context="article//*[not(ancestor::mml:math)]"
      id="element-whitelist">
      <let name="allowed-elements" value="('abstract', 'ack', 'addr-line', 'aff', 'ali:free_to_read', 'ali:license_ref', 'app', 'app-group', 'article', 'article-categories', 'article-id', 'article-meta', 'article-title', 'attrib', 'author-notes', 'award-group', 'award-id', 'back', 'bio', 'body', 'bold', 'boxed-text', 'break', 'caption', 'chapter-title', 'code', 'collab', 'comment', 'conf-date', 'conf-loc', 'conf-name', 'contrib', 'contrib-group', 'contrib-id', 'copyright-holder', 'copyright-statement', 'copyright-year', 'corresp', 'country', 'custom-meta', 'custom-meta-group', 'data-title', 'date', 'date-in-citation', 'day', 'disp-formula', 'disp-quote', 'edition', 'element-citation', 'elocation-id', 'email', 'ext-link', 'fig', 'fig-group', 'fn', 'fn-group', 'fpage', 'front', 'front-stub', 'funding-group', 'funding-source', 'funding-statement', 'given-names', 'graphic', 'history', 'inline-formula', 'inline-graphic', 'institution', 'institution-id', 'institution-wrap', 'issn', 'issue', 'italic', 'journal-id', 'journal-meta', 'journal-title', 'journal-title-group', 'kwd', 'kwd-group', 'label', 'license', 'license-p', 'list', 'list-item', 'lpage', 'media', 'meta-name', 'meta-value', 'mixed-citation', 'mml:math', 'monospace', 'month', 'name', 'named-content', 'on-behalf-of', 'p', 'patent', 'permissions', 'person-group', 'principal-award-recipient', 'pub-date', 'pub-id', 'publisher', 'publisher-loc', 'publisher-name', 'ref', 'ref-list', 'related-article', 'related-object', 'role', 'sc', 'sec', 'self-uri', 'source', 'strike', 'string-date', 'string-name', 'styled-content', 'sub', 'sub-article', 'subj-group', 'subject', 'suffix', 'sup', 'supplementary-material', 'surname', 'table', 'table-wrap', 'table-wrap-foot', 'tbody', 'td', 'th', 'thead', 'title', 'title-group', 'tr', 'underline', 'uri', 'version', 'volume', 'xref', 'year')"/>
      
      <assert test="name()=$allowed-elements"
        role="error" 
        id="element-conformity"><value-of select="name()"/> element is not allowed.</assert>
      
      
    </rule>
  </pattern>
  
  <pattern
    id="final-package-pattern">
    
    <rule context="graphic[@xlink:href]|media[@xlink:href]|self-uri[@xlink:href]" 
      id="final-package">
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