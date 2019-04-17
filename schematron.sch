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
  <ns uri="https://elifesciences.org/" prefix="e"/>
	<!-- Added in case we want to validate the presence of ancillary files -->
    <ns uri="java.io.File" prefix="file"/>
    <ns uri="http://www.java.com/" prefix="java"/>

<let name="allowed-article-types" value="('article-commentary', 'correction', 'discussion', 'editorial', 'research-article', 'retraction')"/>
  <let name="allowed-disp-subj" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Feature article', 'Insight', 'Editorial', 'Correction', 'Retraction', 'Scientific Correspondence')"/>
  <let name="disp-channel" value="//article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject"/> 
  
  <!-- Features specific values included here for convenience -->
  <let name="features-subj" value="('Feature article', 'Insight', 'Editorial')"/>
  <let name="features-article-types" value="('article-commentary','editorial','discussion')"/>
	 
<let name="MSAs" value="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Human Biology and Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
  
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
      <xsl:when test="lower-case($s)=('and','or','the','an','of')">
        <xsl:value-of select="lower-case($s)"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('rna','dna')">
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
        <xsl:value-of select="concat(
          concat(upper-case(substring($token1, 1, 1)), lower-case(substring($token1, 2))),
          ' ',
          string-join(for $x in tokenize(substring-after($token2,' '),'\s') return e:titleCase($x),' ')
          )"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('and','or','the','an','of')">
        <xsl:value-of select="lower-case($s)"/>
      </xsl:when>
      <xsl:when test="lower-case($s)=('rna','dna')">
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
      <xsl:when test="$s = 'Scientific Correspondence'">
        <xsl:value-of select="'Comment on'"/>
      </xsl:when>
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
    <xsl:value-of select="replace(translate($string,'àáâãäåçčèéêěëħìíîïłñňòóôõöøřšśşùúûüýÿž','aaaaaacceeeeehiiiilnnoooooorsssuuuuyyz'),'æ','ae')"/>
  </xsl:function>

  <xsl:function name="e:citation-format1">
    <xsl:param name="year"/>
    <xsl:choose>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/name">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname,', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/collab">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,' and ',$year/ancestor::element-citation/person-group[1]/name/surname,', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname,' and ',$year/ancestor::element-citation/person-group[1]/collab,', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname,' and ',$year/ancestor::element-citation/person-group[1]/name[2]/surname,', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/collab) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1],' and ',$year/ancestor::element-citation/person-group[1]/collab[2],', ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1], ' et al., ',$year)"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname, ' et al., ',$year)"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="'undetermined'"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="e:citation-format2">
    <xsl:param name="year"/>
    <xsl:choose>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/name">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname,' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/collab">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab,' and ',$year/ancestor::element-citation/person-group[1]/name/surname,' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name/surname,' and ',$year/ancestor::element-citation/person-group[1]/collab,' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname,' and ',$year/ancestor::element-citation/person-group[1]/name[2]/surname,' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/collab) = 2)">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1],' and ',e:stripDiacritics($year/ancestor::element-citation/person-group[1]/collab[2]),' (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/collab[1], ' et al. (',$year,')')"/>
      </xsl:when>
      <xsl:when test="(count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name'">
        <xsl:value-of select="concat($year/ancestor::element-citation/person-group[1]/name[1]/surname, ' et al. (',$year,')')"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="'undetermined'"/></xsl:otherwise>
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
  
  <let name="org-regex" value="'b\.\s?subtilis|bacillus\s?subtilis|d\.\s?melanogaster|drosophila\s?melanogaster|e\.\s?coli|escherichia\s?coli|s\.\s?pombe|schizosaccharomyces\s?pombe|s\.\s?cerevisiae|saccharomyces\s?cerevisiae|c\.\s?elegans|caenorhabditis\s?elegans|a\.\s?thaliana|arabidopsis\s?thaliana|xenopus|m\.\s?thermophila|myceliophthora\s?thermophila|dictyostelium|p\.\s?falciparum|plasmodium\s?falciparum|s\.\s?enterica|salmonella\s?enterica|s\.\s?pyogenes|streptococcus\s?pyogenes|p\.\s?dumerilii|platynereis\s?dumerilii|p\.\s?cynocephalus|papio\s?cynocephalus|o\.\s?fasciatus|oncopeltus\s?fasciatus|n\.\s?crassa|neurospora\s?crassa|c\.\s?intestinalis|ciona\s?intestinalis|e\.\s?cuniculi|encephalitozoon\s?cuniculi|h\.\s?salinarum|halobacterium\s?salinarum|s\.\s?solfataricus|sulfolobus\s?solfataricus|s\.\s?mediterranea|schmidtea\s?mediterranea|s\.\s?rosetta|salpingoeca\s?rosetta|n\.\s?vectensis|nematostella\s?vectensis|s.\s?aureus|staphylococcus\s?aureus|a\.\s?thaliana|arabidopsis\s?thaliana|v\.\s?cholerae|vibrio\s?cholerae|t\.\s?thermophila|tetrahymena\s?thermophila|c\.\s?reinhardtii|chlamydomonas\s?reinhardtii|n\.\s?attenuata|nicotiana\s?attenuata|e\.\s?carotovora|erwinia\s?carotovora|e\.\s?faecalis|enterococcus\s?faecalis|drosophila'"/>
  
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
  
  <xsl:function name="e:rrid-text-count" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:variable name="uc" select="upper-case($s)"/>
    <xsl:choose>
      <xsl:when test="matches($uc,'RRID:')">
        <xsl:choose>
          <xsl:when test="matches(substring-after($uc,'RRID:'),'RRID:')">
            <xsl:choose>
              <xsl:when test="matches(substring-after(substring-after($uc,'RRID:'),'RRID:'),'RRID:')">
                <xsl:choose>
                  <xsl:when test="matches(substring-after(substring-after(substring-after($uc,'RRID:'),'RRID:'),'RRID:'),'RRID:')">
                    <xsl:choose>
                      <xsl:when test="matches(substring-after(substring-after(substring-after(substring-after($uc,'RRID:'),'RRID:'),'RRID:'),'RRID:'),'RRID:')">
                        <xsl:value-of select="number('5')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="number('4')"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="number('3')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="number('2')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="number('1')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number('0')"/>
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
		
      <report test="(@article-type = ('article-commentary','discussion','editorial','research-article')) and count(back) != 1"
        role="error" 
        id="test-article-back">Article must have one child back. Currently there are <value-of select="count(back)"/></report>
		
 	</rule>
	
	<rule context="article[@article-type='research-article']" id="research-article">
	
	  <assert test="sub-article[@article-type='decision-letter']"
        role="warning" 
        id="pre-test-r-article-d-letter">A decision letter should be present for research articles.</assert>
	  
	  <assert test="sub-article[@article-type='decision-letter']"
	    role="error" 
	    id="final-test-r-article-d-letter">A decision letter must be present for research articles.</assert>
		
	  <assert test="sub-article[@article-type='reply']"
        role="warning" 
        id="test-r-article-a-reply">sub-article[@article-type="reply"] should be present for article[@article-type="research-article"]</assert>
	
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
      id="test-contrib-group-presence-1">contrib-group must be present (as a child of article-meta) for research articles.</assert>
     
     <assert test="contrib-group[@content-type='section']"
       role="error" 
       id="test-contrib-group-presence-2">contrib-group must be present (as a child of article-meta) for research articles.</assert>
   
   </rule>
	 
   <rule context="article-meta/article-categories" id="test-article-categories">
	 <let name="article-type" value="ancestor::article/@article-type"/>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']) = 1"
       role="error" 
       id="disp-subj-test">There must be one subj-group[@subj-group-type='display-channel'] which is a child of article-categories. Currently there are <value-of select="count(article-categories/subj-group[@subj-group-type='display-channel'])"/>.</assert>
	   
     <assert test="count(subj-group[@subj-group-type='display-channel']/subject) = 1"
       role="error" 
       id="disp-subj-test2">subj-group[@subj-group-type='display-channel'] must contain only one subject. Currently there are <value-of select="count(subj-group[@subj-group-type='display-channel']/subject)"/>.</assert>
		
     <report test="count(subj-group[@subj-group-type='heading']) gt 2"
       role="error" 
       id="head-subj-test1">article-categories must contain one and or two subj-group[@subj-group-type='heading'] elements. Currently there are <value-of select="count(subj-group[@subj-group-type='heading']/subject)"/>.</report>
	   
     <report test="($article-type != 'editorial') and ($article-type != 'discussion') and count(subj-group[@subj-group-type='heading']) lt 1"
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
        id="disp-subj-value-test-1">Content of the display channel should be one of the following: Research Article, Short Report, Tools and Resources, Research Advance, Registered Report, Replication Study, Research Communication, Feature, Insight, Editorial, Correction, Retraction . Currently it is <value-of select="subj-group[@subj-group-type='display-channel']/subject"/>.</assert>
      
      <assert test="if ($article-type = 'research-article') then . = $research-disp-channels
        else if ($article-type = 'article-commentary') then . = 'Insight'
        else if ($article-type = 'editorial') then . = 'Editorial'
        else if ($article-type = 'correction') then . = 'Correction'
        else if ($article-type = 'discussion') then . = 'Feature article'
        else . = 'Retraction'"
        role="error" 
        id="disp-subj-value-test-2">Content of the display channel must correspond with the correct NLM article type defined in article[@artilce-type].</assert>
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
	  <let name="lc" value="normalize-space(lower-case(article-title))"/>
	
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
      role="error" 
      id="article-title-test-5">Article title must not contain math.</report>
	  
    <report test="article-title//bold"
      role="error" 
      id="article-title-test-6">Article title must not contain bold.</report>
	  
	  <report test="matches(article-title,'-Based ')"
	    role="error" 
	    id="article-title-test-7">Article title contains the string '-Based '. this should be lower-case, '-based '.</report>
	
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
	
	<rule context="article-meta/contrib-group//name" 
		id="name-tests">
		
    	<assert test="count(surname) = 1"
      	role="error" 
      	id="surname-test-1">Each name must contain only one surname.</assert>
		
	  <report test="not(surname/*) and normalize-space(surname)=''"
      	role="error" 
      	id="surname-test-2">surname must not be empty.</report>
		
    	<report test="surname[descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc]"
      	role="error" 
      	id="surname-test-3">surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	  <assert test="matches(surname,'^[\p{L}\p{M}\s-]*$')"
      	role="warning" 
      	id="surname-test-4">surname should usually only contain letters, spaces, or hyphens. <value-of select="surname"/> contains other characters.</assert>
		
	  <assert test="matches(surname,'^\p{Lu}')"
      	role="warning" 
      	id="surname-test-5">surname doesn't begin with a capital letter. Is this correct?</assert>
		
    	<report test="count(given-names) gt 1"
      	role="error" 
      	id="given-names-test-1">Each name must contain only one given-names element.</report>
		
    	<assert test="given-names"
      	role="warning" 
      	id="given-names-test-2">This name does not contain a given-name. Please check with eLife staff that this is correct.</assert>
		
	  <report test="not(given-names/*) and normalize-space(given-names)=''"
      	role="error" 
      	id="given-names-test-3">given-names must not be empty.</report>
		
    	<report test="given-names[descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc]"
      	role="error" 
      	id="given-names-test-4">given-names must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</report>
		
	  <assert test="matches(given-names,'^[\p{L}\p{M}\s-]*$')"
      	role="warning" 
      	id="given-names-test-5">given-names should usually only contain letters, spaces, or hyphens. <value-of select="given-names"/> contains other characters.</assert>
		
	  <assert test="matches(given-names,'^\p{Lu}')"
      	role="warning" 
      	id="given-names-test-6">given-names doesn't begin with a capital letter. Is this correct?</assert>
	  
	  <report test="matches(given-names,'^[\p{L}]{1}\.$|^[\p{L}]{1}\.\s?[\p{L}]{1}\.\s?$')"
	    role="error" 
	    id="given-names-test-7">given-names contains initialised full stop(s) which is incorrect - <value-of select="given-names"/></report>
		
	</rule>
	
	<rule context="article-meta//contrib" 
		id="contrib-tests">
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
	  <let name="comp-regex" value="' [Ii]nc[.]?| LLC| Ltd| [Ll]imited| [Cc]ompanies| [Cc]ompany| [Cc]o\.| Pharmaceutical[s]| [Pp][Ll][Cc]| AstraZeneca| Pfizer| R&amp;D'"/>
		
		<!-- Subject to change depending of the affiliation markup of group authors and editors. Currently fires for individual group contributors and editors who do not have either a child aff or a child xref pointing to an aff.  -->
    	<report test="if ($subj-type = ('Retraction','Correction')) then ()
    	  else if (collab) then ()
    	  else if (ancestor::collab) then (count(xref[@ref-type='aff']) + count(aff) = 0)
    	  else if (parent::contrib-group[@content-type='section']) then (count(xref[@ref-type='aff']) + count(aff) = 0)
    	  else count(xref[@ref-type='aff']) = 0"
      	role="error" 
      	id="contrib-test-1">author contrib should contain at least 1 xref[@ref-type='aff'].</report>
	  
	     <report test="name and collab"
	       role="error" 
	       id="contrib-test-2">author contains both a child name and a child collab. This is not correct.</report>
	  
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
	       id="COI-test"><value-of select="concat(descendant::surname,' ',descendant::given-names)"/> is affiliated with what looks like a company, but contains no COI statement. Is this correct?</report>
		
		</rule>
		
		<rule context="article-meta//contrib[@contrib-type='author']/*" 
			id="author-children-tests">
		  <let name="article-type" value="ancestor::article/@article-type"/> 
			<let name="allowed-contrib-blocks" value="('name', 'collab', 'contrib-id', 'email', 'xref')"/>
		  <let name="allowed-contrib-blocks-features" value="($allowed-contrib-blocks, 'bio', 'role')"/>
		
		  <!-- Exception included for group authors - subject to change. The capture here may use xrefs instead of affs - if it does then the else if param can simply be removed. -->
		  <assert test="if ($article-type = $features-article-types) then self::*[local-name() = $allowed-contrib-blocks-features]
		                else if (ancestor::collab) then self::*[local-name() = ($allowed-contrib-blocks,'aff')]
		                else self::*[local-name() = $allowed-contrib-blocks]"
      	role="error"
      	id="author-children-test"><value-of select="self::*/local-name()"/> is not allowed as a child of author.</assert>
		
		</rule>

	<rule context="contrib-id[@contrib-id-type='orcid']" 
		id="orcid-tests">
		
    	<assert test="@authenticated='true'"
      	role="error" 
      	id="orcid-test-1">contrib-id[@contrib-id-type="orcid"] must have an @authenticated="true"</assert>
		
	  <assert test="matches(.,'http[s]?://orcid.org/[\d]{4}-[\d]{4}-[\d]{4}-[\d]{3}[0-9X]')"
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
	
	<rule context="front//abstract" 
		id="abstract-tests">
	  <let name="article-type" value="ancestor::article/@article-type"/>
		
	<!-- Exception for Features article-types -->	
	<report test="if ($article-type = $features-article-types) then () else count(object-id[@pub-id-type='doi']) != 1"
  	role="error" 
  	id="abstract-test-1">object-id[@pub-id-type='doi'] must be present in abstract in <value-of select="$article-type"/> content.</report>
	
	<report test="count(p) lt 1"
  	role="error" 
  	id="abstract-test-2">At least 1 p element must be present in abstract.</report>
	
	<report test="p/disp-formula"
  	role="error" 
  	id="abstract-test-4">abstracts cannot contain display formulas.</report>
		
    </rule>
	
    <rule context="article-meta/contrib-group/aff" 
      id="aff-tests">
      
    <assert test="parent::contrib-group//contrib//xref/@rid = @id"
      role="error"
      id="aff-test-1">aff elements that are direct children of contrib-group must have an xref in that contrib-group pointing to them.</assert>
    </rule>
    
    <rule context="article-meta//aff/institution|addr-line/named-content[@content-type='city']|country" 
      id="institution-tests">
      
      <report test="matches(.,'[\p{P}]$')"
        role="warning"
        id="institution-test-1">Institution ends in punctuation - '<value-of select="substring(.,string-length(.),1)"/>' - is this correct?</report>
      
      <report test="matches(.,'^US$|^USA$|^UK$')"
        role="error"
        id="institution-test-2">This element cannot contain an abbreviated country name.</report>
    </rule>
    
	<rule context="article-meta/funding-group" 
		id="funding-group-tests">
	  <let name="author-count" value="count(parent::article-meta//contrib[@contrib-type='author'])"/>
		
		<assert test="count(funding-statement) = 1"
	  	role="error" 
	  	id="funding-group-test-1">One funding-statement should be present in funding-group.</assert>
		
		<report test="count(award-group) = 0"
	  	role="warning" 
	  	id="funding-group-test-2">funding-group contains no award-groups. Is this correct? Please check with eLife staff.</report>
		
	  <report test="if (count(award-group) = 0) then
	                   if ($author-count = 1) then funding-statement != 'The author declares that there was no funding for this work.'
	                   else if ($author-count gt 1) then funding-statement != 'The authors declare that there was no funding for this work.'
		                 else ()
		               else ()"
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
      
      <assert test="count(custom-meta[@specific-use='meta-only']) = 1"
        role="error"
        id="custom-meta-presence">custom-meta[@specific-use='meta-only'] must be present in custom-meta-group.</assert>
      
    </rule>
    
    <rule context="article-meta/custom-meta-group/custom-meta" 
      id="custom-meta-tests">
      
      <assert test="count(meta-name) = 1"
        role="error"
        id="custom-meta-test-1">One meta-name must be present in custom-meta.</assert>
      
      <assert test="meta-name = 'Author impact statement'"
        role="error"
        id="custom-meta-test-2">The value of meta-name can only be 'Author impact statement'. Currently it is <value-of select="meta-name"/>.</assert>
      
      <assert test="count(meta-value) = 1"
        role="error"
        id="custom-meta-test-3">One meta-value must be present in custom-meta.</assert>
      
    </rule>
      
    <rule context="article-meta/custom-meta-group/custom-meta/meta-value" 
      id="meta-value-tests">
      <report test="not(child::*) and normalize-space(.)=''"
        role="error"
        id="custom-meta-test-4">The value of meta-value cannot be empty</report>
      
      <report test="count(for $x in tokenize(normalize-space(replace(.,'\p{P}','')),' ') return $x) gt 30"
        role="warning"
        id="pre-custom-meta-test-5">Impact statement contains more than 30 words. This is not allowed - please alert eLife staff.</report>
      
      <report test="count(for $x in tokenize(normalize-space(replace(.,'\p{P}','')),' ') return $x) gt 30"
        role="error"
        id="final-custom-meta-test-5">Impact statement contains more than 30 words. This is not allowed.</report>
      
      <assert test="matches(.,'[\.|\?]$')"
        role="warning"
        id="pre-custom-meta-test-6">Impact statement should end with a full stop or question mark - please alert eLife staff.</assert>
      
      <assert test="matches(.,'[\.|\?]$')"
        role="error"
        id="final-custom-meta-test-6">Impact statement must end with a full stop or question mark.</assert>
      
      <report test="matches(.,'[\p{L}]{2,}\. .*$|[\p{L}\p{N}]{2,}\? .*$|[\p{L}\p{N}]{2,}! .*$')"
        role="warning"
        id="custom-meta-test-7">Impact statement appears to be made up of more than one sentence. Please check, as more than one sentence is not allowed.</report>
      
      <report test="matches(.,'[:;]')"
        role="warning"
        id="custom-meta-test-8">Impact statement contains a colon or semi-colon, which is likely incorrect. It needs to be a proper sentence.</report>
      
      <report test="matches(.,'[Ww]e show|[Tt]his study|[Tt]his paper')"
        role="warning"
        id="pre-custom-meta-test-9">Impact statement contains non-descriptive phrase. This is not allowed</report>
      
      <report test="matches(.,'[Ww]e show|[Tt]his study|[Tt]his paper')"
        role="error"
        id="final-custom-meta-test-9">Impact statement contains non-descriptive phrase. This is not allowed</report>
      
      <report test="matches(.,'^[\d]+$')"
        role="error"
        id="custom-meta-test-10">Impact statement is comprised entirely of letters, which must be incorrect.</report>
    </rule>
    
    <rule context="article-meta/elocation-id" 
      id="elocation-id-tests">
      <let name="article-id" value="parent::article-meta/article-id[@pub-id-type='publisher-id']"/>
      
      <assert test=". = concat('e' , $article-id)"
        role="error" 
        id="test-elocation-conformance">elocation-id is incorrect. It's value should be a concatenation of 'e' and the article id, in this case <value-of select="concat('e',$article-id)"/>.</assert>
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
    id="object-id">
	
	<rule context="object-id[@pub-id-type='doi']" 
		id="object-id-tests">
	<let name="article-id" value="ancestor::article/front//article-id[@pub-id-type='publisher-id']"/>
	
	  <assert test="starts-with(.,concat('10.7554/eLife.' , $article-id))"
  	role="error" 
  	id="object-id-test-1">object-id must start with the elife doi prefix, '10.7554/eLife.' and the article id <value-of select="$article-id"/>.</assert>
	
	  <assert test="matches(.,'^10.7554/eLife\.[\d]{5}\.[0-9]{3}$')"
  	role="error" 
  	id="object-id-test-2">object-id must follow this convention - '10.7554/eLife.00000.000'.</assert>
	  
	  <report test="(. = preceding::object-id[@pub-id-type='doi']) or (. = following::object-id[@pub-id-type='doi'])"
	    role="error" 
	    id="object-id-test-3">object-ids must always be distinct. <value-of select="."/> is not distinct.</report>

    </rule>
 </pattern>	
  
  <pattern
    id="content-containers">
    
    <rule context="p" 
      id="p-tests">
    
      <!--<report test="not(matches(.,'^[\p{Lu}\p{N}\p{Ps}\p{S}\p{Pi}\p{Z}]')) and not(parent::list-item) and not(parent::td)"
        role="error" 
        id="p-test-1">p element begins with '<value-of select="substring(.,1,1)"/>'. Is this OK? Usually it should begin with an upper-case letter, or digit, or mathematic symbol, or open parenthesis, or open quote. Or perhaps it should not be the beginning of a new paragraph?</report>-->
      
      <report test="@*"
        role="error" 
        id="p-test-2">p element must not have any attributes.</report>
    </rule>
    
    <rule context="p/*" 
      id="p-child-tests">
      <let name="allowed-p-blocks" value="('bold', 'sup', 'sub', 'sc', 'italic', 'underline', 'xref','inline-formula', 'disp-formula','supplementary-material', 'code', 'ext-link', 'named-content', 'inline-graphic', 'monospace', 'related-object', 'table-wrap')"/>
      
      <assert test="if (ancestor::sec[@sec-type='data-availability']) then self::*/local-name() = ($allowed-p-blocks,'element-citation')
                    else self::*/local-name() = $allowed-p-blocks"
        role="error" 
        id="p-test-3">p element cannot contain <value-of select="self::*/local-name()"/>. only contain the following elements are allowed - bold, sup, sub, sc, italic, xref, inline-formula, disp-formula, supplementary-material, code, ext-link, named-content, inline-graphic, monospace, related-object.</assert>
    </rule>
    
    <rule context="xref" 
      id="xref-target-tests">
      <let name="rid" value="@rid"/>
      <let name="target" value="self::*/ancestor::article//*[@id = $rid]"/>
      
      <report test="if (@ref-type='aff') then $target/local-name() != 'aff'
                    else if (@ref-type='fn') then $target/local-name() != 'fn'
                    else ()"
        role="error" 
        id="xref-target-test">xref with @ref-type='<value-of select="@ref-type"/>' points to <value-of select="$target/local-name()"/>. This is not correct.</report>
    </rule>
    
    <rule context="ext-link[@ext-link-type='uri']" 
      id="ext-link-tests">
      
      <!-- Not entirely sure if this works -->
      <assert test="@xlink:href castable as xs:anyURI" 
        role="error"
        id="broken-uri-test">Broken URI in @xlink:href</assert>
      
      <!-- Needs further testing. Presume that we want to ensure a url follows the HTTP/HTTPs/FTP protocol. -->
      <assert test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:%_\+.~#?&amp;//=]*)$|^ftp://.')" 
        role="warning"
        id="url-conformance-test">@xlink:href doesn't look like a URL. Is this correct?</assert>
      
      <report test="matches(@xlink:href,'\.$')" 
        role="error"
        id="url-fullstop-report">'<value-of select="@xlink:href"/>' - Link ends in a fullstop which is incorrect.</report>
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
    
    <rule context="graphic" 
      id="graphic-tests">
      <let name="file" value="@xlink:href"/>
      
      <report test="contains(@mime-subtype,'tiff') and not(ends-with($file,'.tif'))"
        role="error"
        id="graphic-test-1">graphic has tif mime-subtype but filename does not end with '.tif'. This cannot be correct.</report>
      
      <report test="contains(@mime-subtype,'postscript') and not(ends-with($file,'.eps'))"
        role="error"
        id="graphic-test-2">graphic has postscript mime-subtype but filename does not end with '.eps'. This cannot be correct.</report>
      
      <report test="contains(@mime-subtype,'jpeg') and not(ends-with($file,'.jpg'))"
        role="error"
        id="graphic-test-3">graphic has jpeg mime-subtype but filename does not end with '.jpg'. This cannot be correct.</report>
    </rule>
    
    <rule context="media" 
      id="media-tests">
      <let name="file" value="@mime-subtype"/>
      
      <assert test="@mimetype" 
        role="error"
        id="media-test-1">media must have @mimetype.</assert>
      
      <assert test="@mime-subtype" 
        role="error"
        id="media-test-2">media must have @mime-subtype.</assert>
      
      <assert test="@xlink:href" 
        role="error"
        id="media-test-3">media must have @xlink:href.</assert>
      
      <report test="if ($file='octet-stream') then ()
                    else if ($file = 'msword') then not(matches(@xlink:href,'\.doc[x]?$'))
                    else if ($file = 'excel') then not(matches(@xlink:href,'\.xl[s|t|m][x|m|b]?$'))
                    else if ($file='x-m') then not(matches(@xlink:href,'\.m$'))
                    else if ($file='tab-separated-values') then not(matches(@xlink:href,'\.tsv$'))
                    else if (@mimetype='text') then not(matches(@xlink:href,'\.txt$|\.py$|\.xml$'))
                    else if ($file='jpeg') then not(matches(@xlink:href,'\.[Jj][Pp][Gg]$'))
                    else not(ends-with(@xlink:href,concat('.',$file)))" 
        role="error"
        id="media-test-4">media must have a file reference in @xlink:href which is equivalent to its @mime-subtype.</report>      
      
      <report test="matches(label,'^Animation [0-9]{1,3}') and not(@mime-subtype='gif')" 
        role="error"
        id="media-test-5">media whose label is in the format 'Animation 0' must have a @mime-subtype='gif'.</report>    
      
      <report test="matches(@xlink:href,'\.doc[x]?$|\.pdf$|\.xlsx$|\.xml$|\.xlsx$|\.mp4$|\.gif$')  and (@mime-subtype='octet-stream')" 
        role="warning"
        id="media-test-6">media has @mime-subtype='octet-stream', but the file reference ends with a recognised mime-type. Is this correct?</report>      
      
      <report test="if (child::label) then not(matches(label,'^Video \d{1,4}\.$|^Figure \d{1,4}—video \d{1,4}\.$|^Table \d{1,4}—video \d{1,4}\.$|^Appendix \d{1,4}—video \d{1,4}\.$|^Animation \d{1,4}\.$|^Author response video \d{1,4}\.$'))
        else ()"
        role="error"
        id="media-test-7">video label does not conform to eLife's usual label format.</report>
      
      <report test="if (@mimetype='video') then (not(label))
        else ()"
        role="error"
        id="media-test-8">video does not contain a label, which is incorrect.</report>
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
      
      <assert test="matches(label,'^Transparent reporting form$|^Figure \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source data \d{1,4}\.$|^Table \d{1,4}—source data \d{1,4}\.$|^Video \d{1,4}—source data \d{1,4}\.$|^Figure \d{1,4}—source code \d{1,4}\.$|^Figure \d{1,4}—figure supplement \d{1,4}—source code \d{1,4}\.$|^Table \d{1,4}—source code \d{1,4}\.$|^Video \d{1,4}—source code \d{1,4}\.$|^Supplementary file \d{1,4}\.$|^Source data \d{1,4}\.$|^Source code \d{1,4}\.$|^Reporting standard \d{1,4}\.$')"
        role="error"
        id="supplementary-material-test-6">supplementary-material label does not conform to eLife's usual label format.</assert>
    </rule>
    
    <rule context="supplementary-material[(ancestor::fig) or (ancestor::media) or (ancestor::table-wrap)]" 
      id="source-data-specific-tests">
      
      <report test="matches(label,'^Figure \d{1,4}—source data \d{1,4}') and (descendant::xref[contains(.,'upplement')])"
        role="warning"
        id="fig-data-test-1"><value-of select="label"/> is figure level source data, but contains a link to a figure supplement - should it be figure supplement source data?</report>
      
    </rule>
    
    <rule context="disp-formula" 
      id="disp-formula-tests">
      
      <assert test="mml:math"
        role="error"
        id="disp-formula-test-2">disp-formula must contain an mml:math element.</assert>
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
    </rule>
    
    <rule context="mml:math" 
      id="math-tests">
      
      <report test="normalize-space(.)=''"
        role="error"
        id="math-test-1">mml:math must not be empty.</report>
      
      <report test="descendant::mml:merror"
        role="error"
        id="math-test-2">math contains an mml:merror with '<value-of select="descendant::mml:merror[1]/*"/>'. This will almost certainly not render correctly.</report>
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
        else not(ancestor::article//xref[@rid = $id])" 
        role="error"
        id="final-table-wrap-cite-1">There is no citation to <value-of select="$lab"/> Esnure this is added.</report>
      
      <report test="if (contains($id,'inline')) then () 
        else if ($article-type = $features-article-types) then (not(ancestor::article//xref[@rid = $id]))
        else ()" 
        role="warning"
        id="feat-table-wrap-cite-1">There is no citation to <value-of select="if (label) then label else 'table.'"/> Is this correct?</report>
      
    </rule>
    
    <rule context="body//table-wrap/label" 
      id="body-table-label-tests">
      
      <assert test="matches(.,'^Table \d{1,4}\.$|^Key resources table$')"
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
        id="table-test-1">table must have at least one tbody.</report>
      
      <assert test="thead"
        role="warning"
        id="table-test-2">table doesn't have a thead. Is this correct?</assert>
    </rule>
    
    <rule context="table/tbody" 
      id="tbody-tests">
      
      <report test="count(tr) = 0"
        role="error"
        id="tbody-test-1">tbody must have at least one tr.</report>
    </rule>
    
    <rule context="table/thead" 
      id="thead-tests">
      
      <report test="count(tr) = 0"
        role="error"
        id="thead-test-1">thead must have at least one tr.</report>
    </rule>
    
    <rule context="tr" 
      id="tr-tests">
      <let name="count" value="count(th) + count(td)"/> 
      
      <report test="$count = 0"
        role="error"
        id="tr-test-1">tr must contain at least one th or td.</report>
      
      <report test="th and (tr/parent::tbody)"
        role="warning"
        id="tr-test-2">table row in body contains a th element (a header), which is unusual. Please check that this is correct.</report>
      
      <report test="td and (tr/parent::thead)"
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
      
      <report test="($type='alpha-lower') and matches(.,'^\s?[a-z][\.|\)]? ')"
        role="warning"
        id="alpha-lower-test-1">list-item is part of an alpha-lower list, but it begins with a single lower-case letter. Is this correct? <value-of select="."/></report>
      
      <report test="($type='alpha-upper') and matches(.,'^\s?[A-Z][\.|\)]? ')"
        role="warning"
        id="alpha-upper-test-1">list-item is part of an alpha-upper list, but it begins with a single upper-case letter. Is this correct? <value-of select="."/></report>
      
      <report test="($type='roman-lower') and matches(.,'^\s?(i|ii|iii|iv|v|vi|vii|viii|ix|x)[\.|\)]? ')"
        role="warning"
        id="roman-lower-test-1">list-item is part of an roman-lower list, but it begins with a single roman-lower letter. Is this correct? <value-of select="."/></report>
      
      <report test="($type='roman-upper') and matches(.,'^\s?(I|II|III|IV|V|VI|VII|VIII|IX|X)[\.|\)]? ')"
        role="warning"
        id="roman-upper-test-1">list-item is part of an roman-upper list, but it begins with a single roman-upper letter. Is this correct? <value-of select="."/></report>
    </rule>
    
    <rule context="media[@mimetype='video'][matches(@id,'^video[0-9]{1,3}$')]"
      id="general-video">
      <let name="id" value="@id"/>
      <let name="xref1" value="ancestor::article/descendant::xref[(@rid = $id) and not(ancestor::fig)][1]"/>
      <let name="fig-xref1" value="ancestor::article/descendant::xref[(@rid = $id) and (ancestor::fig)][1]"/>
      <let name="xref-sib" value="$xref1/parent::*/following-sibling::*[1]/local-name()"/>
      
      <assert test="ancestor::article//xref[@rid = $id]" 
        role="warning"
        id="pre-video-cite">There is no citation to <value-of select="label"/> Ensure to query the author asking for a citation.</assert>
      
      <assert test="ancestor::article//xref[@rid = $id]" 
        role="error"
        id="final-video-cite">There is no citation to <value-of select="label"/> Esnure this is added.</assert>
      
      <report test="if ((count($fig-xref1) = 1) and (count($xref1) = 0)) then (ancestor::sec[1]/@id != ($fig-xref1/ancestor::sec[1]/@id))
        else (ancestor::sec[1]/@id != ($xref1/ancestor::sec[1]/@id))" 
        role="error"
        id="video-placement-1"><value-of select="replace(label,'\.$','')"/> does not appear in the same section as where it is first cited, which is incorrect.</report>
      
      <report test="($xref-sib = 'p') and ($xref1//following::media/@id = $id)" 
        role="warning"
        id="video-placement-2"><value-of select="replace(label,'\.$','')"/> appears after it's first citation but not directly after it's first citation. Is this correct?</report>
      
      <report test="if ((count($fig-xref1) = 1) and (count($xref1) = 0)) then ($fig-xref1//preceding::media/@id = $id)
        else ($xref1//preceding::media/@id = $id)" 
        role="error"
        id="video-placement-3"><value-of select="replace(label,'\.$','')"/> appears before its citation, which must be incorrect.</report>
      
    </rule>
  </pattern>
  
  <pattern id="video-tests">
    
    <rule context="article/body//media[@mimetype='video']" 
      id="body-video-specific">
      <let name="count" value="count(ancestor::body//media[@mimetype='video'][matches(label,'^Video [\d]+\.$')])"/>
      <let name="pos" value="$count - count(following::media[@mimetype='video'][matches(label,'^Video [\d]+\.$')][ancestor::body])"/>
      <let name="no" value="substring-after(@id,'video')"/>
      <let name="fig-label" value="replace(ancestor::fig-group/fig[1]/label,'\.','')"/>
      
      <report test="not(ancestor::fig-group) and (matches(label,'[Vv]ideo')) and ($no != string($pos))" 
        role="error"
        id="body-video-position-test-1"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other videos it is placed in position <value-of select="$pos"/>.</report>
      
      <assert test="starts-with(label,$fig-label)" 
        role="error"
        id="fig-video-label-test"><value-of select="label"/> does not begin with its parent figure label - <value-of select="$fig-label"/> - which is incorrect.</assert>
      
    </rule>
    
  </pattern>
  
  <pattern
    id="further-fig-tests">
  
    <rule context="article/body//fig[not(@specific-use='child-fig')][not(ancestor::boxed-text)]" 
      id="fig-specific-tests">
      <let name="article-type" value="ancestor::article/@article-type"/>
      <let name="id" value="@id"/>
      <let name="count" value="count(ancestor::article//fig[matches(label,'Figure \d{1,4}\.')])"/>
      <let name="pos" value="$count - count(following::fig[matches(label,'Figure \d{1,4}\.')])"/>
      <let name="no" value="substring-after($id,'fig')"/>
      <let name="pre-sib" value="preceding-sibling::*[1]"/>
      <let name="fol-sib" value="following-sibling::*[1]"/>
      <let name="lab" value="replace(label,'\.','')"/>
      
      <report test="label[contains(lower-case(.),'supplement')]" 
        role="error"
        id="fig-specific-test-1">fig label contains 'supplement', but it does not have a @specific-use='child-fig'. If it is a figure supplement it needs the attribute, if it isn't then it cannot contain 'supplement' in the label.</report>
      
      <report test="if ($count = 0) then ()
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
        id="final-fig-specific-test-4">There is no citation to <value-of select="$lab"/> Esnure this is added.</report>
      
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
      <let name="count" value="count(parent::fig-group/fig[@specific-use='child-fig'])"/>
      <let name="pos" value="$count - count(following-sibling::fig[@specific-use='child-fig'])"/>
      <let name="no" value="substring-after(@id,'s')"/>
      <let name="parent-fig-no" value="substring-after(parent::fig-group/fig[not(@specific-use='child-fig')]/@id,'fig')"/>
      
      <assert test="parent::fig-group" 
        role="error"
        id="fig-sup-test-1">fig supplement is not a child of fig-group. This cannot be correct.</assert>
      
      <assert test="label[contains(lower-case(.),'supplement')]" 
        role="error"
        id="fig-sup-test-2">fig which has a @specific-use='child-fig' must have a label which contains 'supplement'.</assert>
      
      <assert test="starts-with(label,concat('Figure ',$parent-fig-no))" 
        role="error"
        id="fig-sup-test-3"><value-of select="label"/> does not start with the main figure number it is associated with - <value-of select="concat('Figure ',$parent-fig-no)"/>.</assert>
      
      <assert test="$no = string($pos)" 
        role="error"
        id="fig-sup-test-4"><value-of select="label"/> does not appear in sequence which is incorrect. Relative to the other figures it is placed in position <value-of select="$pos"/>.</assert>
      
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
    
    <rule context="article/body//boxed-text//fig[not(@specific-use='child-fig')]/label" 
      id="box-fig-tests"> 
      
      <assert test="matches(.,'^Box \d{1,4}—figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error"
        id="box-fig-test-1">label for fig inside boxed-text must be in the format 'Box 1—figure 1.', or 'Chemical structure 1.', or 'Scheme 1'.</assert>
    </rule>
    
    <rule context="article//app//fig[not(@specific-use='child-fig')]/label" 
      id="app-fig-tests"> 
      
      <assert test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')" 
        role="error"
        id="app-fig-test-1">label for fig inside appendix must be in the format 'Appendix 1—figure 1.', or 'Chemical structure 1.', or 'Scheme 1'.</assert>
      
      <report test="matches(.,'^Appendix \d{1,4}—figure \d{1,4}\.$|^Appendix—figure \d{1,4}\.$') and not(starts-with(.,ancestor::app/title))" 
        role="error"
        id="app-fig-test-2">label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure i placed in the incorrect appendix or the label is incorrect.</report>
    </rule>
    
    <rule context="article//app//fig[@specific-use='child-fig']/label" 
      id="app-fig-sup-tests"> 
      
      <assert test="matches(.,'^Appendix \d{1,4}—Figure \d{1,4}—figure Supplement \d{1,4}\.$|^Appendix—figure \d{1,4}—figure Supplement \d{1,4}\.$')" 
        role="error"
        id="app-fig-sup-test-1">label for fig inside appendix must be in the format 'Appendix 1—Figure 1—Figure Supplement 1.'.</assert>
      
      <assert test="starts-with(.,ancestor::app/title)" 
        role="error"
        id="app-fig-sup-test-2">label for <value-of select="."/> does not start with the correct appendix prefix. Either the figure i placed in the incorrect appendix or the label is incorrect.</assert>
    </rule>
  </pattern>
  
  <pattern
    id="body">
    
    <rule context="article/body[ancestor::article/@article-type='research-article']" 
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
        id="ra-sec-test-3">main body in <value-of select="$type"/> content doesn't have a child sec with @sec-type whose value is either 'material|methods', 'methods' or 'model'. Is this correct?.</report>
      
      <report test="if ($type = ('Short Report','Scientific Correspondence')) then ()
        else if (sec[@sec-type='results|discussion']) then ()
        else $res-disc-count != 2" 
        role="warning"
        id="ra-sec-test-4">main body in <value-of select="$type"/> content doesn't have either a child sec[@sec-type='results|discussion'] or a sec[@sec-type='results'] and a sec[@sec-type='discussion']. Is this correct?</report>
    
    </rule>
    
    <rule context="body/sec" 
      id="top-level-sec-tests">
      <let name="pos" value="count(parent::body/sec) - count(following-sibling::sec)"/>
      
      <assert test="@id = concat('s', $pos)" 
        role="error"
        id="top-sec-id">top-level must have @id in the format 's0', where 0 relates to the position of the sec. It should be <value-of select="concat('s', $pos)"/>.</assert>
      
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
      <let name="string" value="e:article-type2title($type)" />
      <let name="specifics" value="('Scientific Correspondence','Replication Study','Registered Report','Correction','Retraction')"/>
      
      <report test="if ($type = $specifics) then not(starts-with(.,$string))
                    else ()" 
        role="warning"
        id="article-type-title-test">title of a '<value-of select="$type"/>' should usually start with '<value-of select="$string"/>'. Is it correct?</report>
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
      
      <assert test="matches(.,'\.$')" 
        role="error"
        id="fig-title-test-2">title for <value-of select="$label"/> must end with a fullstop.</assert>
      
      <report test="matches(.,' vs\.$')" 
        role="warning"
        id="fig-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\s')" 
        role="error"
        id="fig-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
    </rule>
    
    <rule context="supplementary-material/caption/title" 
      id="supplementary-material-title-tests"> 
      <let name="label" value="parent::caption/preceding-sibling::label"/>
      
      <report test="matches(.,'^\([A-Za-z]|^[A-Za-z]\)')" 
        role="warning"
        id="supplementary-material-title-test-1">'<value-of select="$label"/>' appears to have a title which is the begining of a caption. Is this correct?</report>
      
      <assert test="matches(.,'\.$')" 
        role="error"
        id="supplementary-material-title-test-2">title for <value-of select="$label"/> must end with a fullstop.</assert>
      
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
      
      <assert test="matches(.,'\.$')" 
        role="error"
        id="video-title-test-2">title for <value-of select="$label"/> must end with a fullstop.</assert>
      
      <report test="matches(.,' vs\.$')" 
        role="warning"
        id="video-title-test-3">title for <value-of select="$label"/> ends with 'vs.', which indicates that the title sentence may be split across title and caption.</report>
      
      <report test="matches(.,'^\s')" 
        role="error"
        id="video-title-test-4">title for <value-of select="$label"/> begins with a space, which is not allowed.</report>
    </rule>
    
    <rule context="ack" 
      id="ack-title-tests">
      
      <assert test="title = ('Acknowledgements','Acknowledgments')"
        role="error"
        id="ack-title-test">ack must have a title that contains 'Acknowledgements', or 'Acknowledgments'. Currently it is '<value-of select="title"/>'.</assert>
      
    </rule>
    
    <rule context="ack//p" 
      id="ack-content-tests">
      <let name="hit" value="string-join(for $x in tokenize(.,' ') return 
        if (matches($x,'^[A-Z]{1}\.$')) then $x
        else (),', ')"/>
      <let name="hit-count" value="count(for $x in tokenize(.,' ') return 
        if (matches($x,'^[A-Z]{1}\.$')) then $x
        else ())"/>
      
      <report test="matches(.,' [A-Z]\. ')"
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
      
      <assert test="matches(.,'Appendix [0-9]{1,2}?')"
        role="warning"
        id="app-title-test">app title should usually be in the format 'Appendix 1'. Currently it is '<value-of select="."/>'.</assert>
      
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
      
      <assert test="matches(@id,'^fig[0-9]{1,3}$')" 
        role="error"
        id="fig-id-test">fig must have an @id in the format fig0, fig00, or fig000.</assert>
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
        id="mml-math-id-test">disp-formula @id must be in the format 'm0'.</assert>
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
        role="error"
        id="resp-table-wrap-id-test">table-wrap @id in author reply must be in the format 'resptable0' if it has a label or in the format 'respinlinetable0' if it does not.</assert>
    </rule>
    
    <rule context="article//table-wrap[not(ancestor::app)]" 
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
  </pattern>
  
  <pattern
    id="sec-specific">
    
    <rule context="sec" 
      id="sec-tests">
      <let name="child-count" value="count(p) + count(sec) + count(fig) + count(fig-group) + count(media) + count(table-wrap) + count(boxed-text) + count(list) + count(fn-group) + count(supplementary-material)"/>
      
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
        id="back-test-2">One and only one sec[@sec-type="supplementary-material"] may be present in back.</report>
      
      <report test="if (($article-type != 'research-article') or ($subj-type = 'Scientific Correspondence') ) then ()
        else count(sec[@sec-type='data-availability']) != 1"
        role="error"
        id="back-test-3">One and only one sec[@sec-type="data-availability"] must be present as a child of back for '<value-of select="$article-type"/>'.</report>
      
      <report test="count(ack) gt 1"
        role="error"
        id="back-test-4">One and only one ack may be present in back.</report>
      
      <report test="if ($article-type != ('research-article','article-commentary')) then ()
                    else count(ref-list) != 1"
        role="error"
        id="back-test-5">One and only one ref-list must be present in <value-of select="$article-type"/> content.</report>
      
      <report test="count(app-group) gt 1"
        role="error"
        id="back-test-6">One and only one app-group may be present in back.</report>
      
      <report test="if ($article-type != 'article-commentary') then ()
              else (count(fn-group[@content-type='competing-interest']) != 1)"
        role="error"
        id="back-test-7">One and only one fn-group[@content-type='competing-interest'] must be present in back in <value-of select="$article-type"/> content.</report>
      
      <report test="if ($article-type = ($features-article-types,'retraction','correction')) then ()
        else (not(ack))"
        role="warning"
        id="back-test-8">'<value-of select="$article-type"/>' usually have acknowledgement section, but there isn't one here. Is this correct?</report>
      
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
        id="additional-info-test-1">This type of sec must be a child of back.</assert>
      
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
      
      <assert test="parent::sec[@sec-type='additional-information']"
        role="error"
        id="ethics-test-1">Ethics fn-group can only be captured as a child of a sec [@sec-type='additional-information']</assert>
 
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
      
      <assert test="@id = concat('SA',$pos)"
        role="error"
        id="dec-letter-reply-test-2">sub-article id must be in the format 'SA0', where '0' is it's position (1 or 2).</assert>
      
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
      
      <assert test="count(article-id[@pub-id-type='doi']) = 1"
        role="error"
        id="dec-letter-front-test-1">sub-article front-stub must contain article-id[@pub-id-type='doi'].</assert>
      
      <assert test="count(contrib-group) gt 0"
        role="error"
        id="dec-letter-front-test-2">sub-article front-stub must contain at least 1 contrib-group element.</assert>
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
  </pattern>
  
  <pattern
    id="related-articles">
    
    <rule context="article[$disp-channel = 'Research Advance']//article-meta" 
      id="research-advance-test">
      
      <assert test="count(related-article[@related-article-type='article-reference']) gt 0"
        role="error"
        id="related-articles-test-1">Research Advance must contain an article-reference link to the original article it is building upon.</assert>
      
    </rule>
    
    <rule context="article[$disp-channel = 'Insight']//article-meta" 
      id="insight-test">
      
      <assert test="count(related-article) gt 0"
        role="error"
        id="related-articles-test-2">Insight must contain an article-reference link to the original article it is discussing.</assert>
      
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
      
      <report test="person-group/name[not(surname)]" role="error" id="err-elem-cit-gen-name-2">[err-elem-cit-gen-name-2]
        Each &lt;name&gt; element in a reference must contain a &lt;surname&gt; element. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not.</report>
      
      <report test="descendant::etal" role="error" id="err-elem-cit-gen-name-5">[err-elem-cit-gen-name-5]
        The &lt;etal&gt; element in a reference is not allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' contains it.</report>
      
      <report test="count(year)&gt;1 " role="error" id="err-elem-cit-gen-date-1-9">[err-elem-cit-gen-date-1-9]
        There may be at most one &lt;year&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(year)"/>
        &lt;year&gt; elements.
      </report>
      
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
      
      <assert test="(1700 le number($YYYY)) and (number($YYYY) le ($current-year + 5))" role="error" id="err-elem-cit-gen-date-1-2">[err-elem-cit-gen-date-1-2]
        The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive).
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="./@iso-8601-date" role="error" id="err-elem-cit-gen-date-1-3">[err-elem-cit-gen-date-1-3]
        All &lt;year&gt; elements must have @iso-8601-date attributes.
        Reference '<value-of select="ancestor::ref/@id"/>' does not.
      </assert>
      
      <assert test="not(./@iso-8601-date) or (1700 le number(substring(normalize-space(@iso-8601-date),1,4)) and number(substring(normalize-space(@iso-8601-date),1,4)) le ($current-year + 5))" role="error" id="err-elem-cit-gen-date-1-4">[err-elem-cit-gen-date-1-4]
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
    
  </pattern>
  
  <pattern id="element-citation-high-tests">
    
    <rule context="ref" id="ref">
      <let name="pre-name" value="lower-case(if (local-name(element-citation/person-group[1]/*[1])='name')       then (element-citation/person-group[1]/name[1]/surname)       else (element-citation/person-group[1]/*[1]))"/>
      <let name="name" value="e:stripDiacritics($pre-name)"/>
      
      <let name="pre-name2" value="lower-case(if (local-name(element-citation/person-group[1]/*[2])='name')       then (element-citation/person-group[1]/*[2]/surname)       else (element-citation/person-group[1]/*[2]))"/>
      <let name="name2" value="e:stripDiacritics($pre-name2)"/>
      
      <let name="pre-preceding-name" value="lower-case(if (preceding-sibling::ref[1] and       local-name(preceding-sibling::ref[1]/element-citation/person-group[1]/*[1])='name')       then (preceding-sibling::ref[1]/element-citation/person-group[1]/name[1]/surname)       else (preceding-sibling::ref[1]/element-citation/person-group[1]/*[1]))"/>
      <let name="preceding-name" value="e:stripDiacritics($pre-preceding-name)"/>
      
      <let name="pre-preceding-name2" value="lower-case(if (preceding-sibling::ref[1] and       local-name(preceding-sibling::ref[1]/element-citation/person-group[1]/*[2])='name')       then (preceding-sibling::ref[1]/element-citation/person-group[1]/*[2]/surname)       else (preceding-sibling::ref[1]/element-citation/person-group[1]/*[2]))"/>
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
      
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-journal-4-2-1">[err-elem-cit-journal-4-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
      <assert test="count(source)=1 and count(source/*)=0" role="error" id="err-elem-cit-journal-4-2-2">[err-elem-cit-journal-4-2-2]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' may not contain child 
        elements.
        Reference '<value-of select="ancestor::ref/@id"/>' has disallowed child elements.</assert>
      
      <assert test="count(volume) le 1" role="error" id="err-elem-cit-journal-5-1-3">[err-elem-cit-journal-5-1-3]
        There may be no more than one  &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal'.
        Reference '<value-of select="ancestor::ref/@id"/>' has <value-of select="count(volume)"/>
        &lt;volume&gt; elements.</assert>
      
      <assert test="(count(fpage) eq 1) or (count(elocation-id) eq 1) or (count(comment/text()='In press') eq 1)" role="warning" id="warning-elem-cit-journal-6-1">[warning-elem-cit-journal-6-1]
        One of &lt;fpage&gt;, &lt;elocation-id&gt;, or &lt;comment&gt;In press&lt;/comment&gt; should be present. 
        Reference '<value-of select="ancestor::ref/@id"/>' has missing page or elocation information.</assert>
      
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
      
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-book-10-2-1">[err-elem-cit-book-10-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'book' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-data-11-3-1">[err-elem-cit-data-11-3-1]
        A &lt;source&gt; element within a &lt;element-citation&gt; of type 'data' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      
    </rule>
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
      
    </rule>
    
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
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-patent-9-2-1">[err-elem-cit-patent-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'patent' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      
      <assert test="count(person-group) = 1 or (count(person-group/@person-group-type = 'author') +         count(person-group/@person-group-type = 'editor') = 2)" role="error" id="err-elem-cit-software-2-1">[err-elem-cit-software-2-1] Each
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
      
    </rule>
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
      
    </rule>
    
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
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-preprint-9-2-1">[err-elem-cit-preprint-9-2-1]
        A &lt;source&gt; element within a &lt;element-citation&gt; of type 'preprint' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      
    </rule>
    
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
      <assert test="./string-length() + sum(*/string-length()) ge 2" role="error" id="err-elem-cit-web-9-2-1">[err-elem-cit-web-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'web' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      <assert test="(./string-length() + sum(*/string-length()) ge 2)" role="error" id="err-elem-cit-report-9-2-1">[err-elem-cit-report-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'report' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      
    </rule>
    
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
      
      <report test="(lpage and fpage) and (fpage ge lpage)" role="error" id="err-elem-cit-confproc-12-3">[err-elem-cit-confproc-12-3]
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
      <assert test="(./string-length() + sum(*/string-length()) ge 2)" role="error" id="err-elem-cit-confproc-9-2-1">[err-elem-cit-confproc-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'confproc' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      
      <assert test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage),1,1) = substring(normalize-space(.),1,1))" role="error" id="err-elem-cit-confproc-12-5">[err-elem-cit-confproc-12-5]
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
      
    </rule>
    
  </pattern>
  
  <pattern id="element-citation-thesis-tests">
    
    <rule context="element-citation[@publication-type='thesis']" id="elem-citation-thesis"> 
      
      <assert test="count(person-group)=1" role="error" id="err-elem-cit-thesis-2-1">[err-elem-cit-thesis-2-1]
        One and only one person-group element is allowed.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(person-group)"/> &lt;person-group&gt; elements.</assert>
      
      <assert test="count(collab)=0" role="error" id="err-elem-cit-thesis-3">[err-elem-cit-thesis-3]
        No &lt;collab&gt; elements are allowed in thesis citations.
        Reference '<value-of select="ancestor::ref/@id"/>' has 
        <value-of select="count(collab)"/> &lt;collab&gt; elements.</assert>
      
      <assert test="count(etal)=0" role="error" id="err-elem-cit-thesis-6">[err-elem-cit-thesis-6]
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
      
    </rule>
    
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
      
      <assert test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)" role="error" id="err-elem-cit-periodical-9-2-1">[err-elem-cit-periodical-9-2-1]
        A  &lt;source&gt; element within a &lt;element-citation&gt; of type 'periodical' must contain 
        at least two characters.
        Reference '<value-of select="ancestor::ref/@id"/>' has too few characters.</assert>
      
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
      
      <report test="(lpage and fpage) and (fpage ge lpage)" role="error" id="err-elem-cit-periodical-11-3">[err-elem-cit-periodical-11-3]
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
      
      <assert test="matches(normalize-space(@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')" role="error" id="err-elem-cit-periodical-7-3">[err-elem-cit-periodical-7-3]
        The @iso-8601-date value must include 4 digit year, 2 digit month, and (optionally) a 2 digit day.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="@iso-8601-date"/>'.
      </assert>
      
      <assert test="matches(normalize-space(.),'(^\d{4}[a-z]?)')" role="error" id="err-elem-cit-periodical-7-4-1">[err-elem-cit-periodical-7-4-1]
        The &lt;year&gt; element in a reference must contain 4 digits, possibly followed by one (but not more) lower-case letter.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="(1700 le number($YYYY)) and (number($YYYY) le $current-year)" role="error" id="err-elem-cit-periodical-7-4-2">[err-elem-cit-periodical-7-4-2]
        The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year (inclusive).
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value '<value-of select="."/>'.
      </assert>
      
      <assert test="not(./@iso-8601-date) or substring(normalize-space(./@iso-8601-date),1,4) = $YYYY" role="error" id="err-elem-cit-periodical-7-5">[err-elem-cit-periodical-7-5]
        The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the 
        &lt;year&gt; element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as the element contains
        the value '<value-of select="."/>' and the attribute contains the value 
        '<value-of select="./@iso-8601-date"/>'.
      </assert>
      
      <assert test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and        (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,'b'))        and ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname)       )" role="error" id="err-elem-cit-periodical-7-6">[err-elem-cit-periodical-7-6]
        If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with 
        the same first author surname with a letter "b" after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <assert test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or       (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',       'abcdefghijklmnopqrstuvwxy')))        and ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname)       " role="error" id="err-elem-cit-periodical-7-7">[err-elem-cit-periodical-7-7]
        If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another 
        reference with the same first author surname with the preceding letter after the year. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement.</assert>
      
      <report test=". = preceding::year and        ancestor::element-citation/person-group[1]/name[1]/surname = preceding::year/ancestor::element-citation/person-group[1]/name[1]/surname" role="error" id="err-elem-cit-periodical-7-8">[err-elem-cit-periodical-7-8]
        Letter suffixes must be unique for the combination of year and first author surname. 
        Reference '<value-of select="ancestor::ref/@id"/>' does not fulfill this requirement as it 
        contains the &lt;year&gt; '<value-of select="."/>' more than once for the same first author surname
        '<value-of select="ancestor::element-citation/person-group[1]/name[1]/surname"/>'.</report>
      
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
      
      <assert test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage),1,1) = substring(normalize-space(.),1,1))" role="error" id="err-elem-cit-periodical-11-5">[err-elem-cit-periodical-11-4]
        If the content of &lt;fpage&gt; begins with a letter, then the content of  &lt;lpage&gt; must begin with 
        the same letter. 
        Reference '<value-of select="ancestor::ref/@id"/>' has &lt;fpage&gt;='<value-of select="."/>'
        and &lt;lpage&gt;='<value-of select="../lpage"/>'.</assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date" id="elem-citation-periodical-string-date">
      
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
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/month" id="elem-citation-periodical-month">
      
      <assert test=".=('January','February','March','April','May','June','July','August','September','October','November','December')" role="error" id="err-elem-cit-periodical-14-4">[err-elem-cit-periodical-14-4]
        The content of &lt;month&gt; must be the month, written out, with correct capitalization.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value  &lt;month&gt;='<value-of select="."/>'.
      </assert>
      
      <assert test=".=format-date(xs:date(../year/@iso-8601-date), '[MNn]')" role="error" id="err-elem-cit-periodical-14-5">[err-elem-cit-periodical-14-5]
        The content of &lt;month&gt; must match the content of the month section of @iso-8601-date on the 
        sibling year element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value &lt;month&gt;='<value-of select="."/>' but &lt;year&gt;/@iso-8601-date='<value-of select="../year/@iso-8601-date"/>'.
      </assert>
      
    </rule>
    
    <rule context="element-citation[@publication-type='periodical']/string-date/day" id="elem-citation-periodical-day">
      
      <assert test="matches(normalize-space(.),'([1-9])|([1-2][0-9])|(3[0-1])')" role="error" id="err-elem-cit-periodical-14-6">[err-elem-cit-periodical-14-6]
        The content of &lt;day&gt;, if present, must be the day, in digits, with no zeroes.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value  &lt;day&gt;='<value-of select="."/>'.
      </assert>
      
      <assert test=".=format-date(xs:date(../year/@iso-8601-date), '[D]')" role="error" id="err-elem-cit-periodical-14-7">[err-elem-cit-periodical-14-7]
        The content of &lt;day&gt;, if present, must match the content of the day section of @iso-8601-date on the 
        sibling year element.
        Reference '<value-of select="ancestor::ref/@id"/>' does not meet this requirement as it contains
        the value &lt;day&gt;='<value-of select="."/>' but &lt;year&gt;/@iso-8601-date='<value-of select="../year/@iso-8601-date"/>'.
      </assert>
      
    </rule>
  </pattern>
  
 <pattern
 	id="features">
   
   <rule context="article-meta[descendant::subj-group[@subj-group-type='display-channel']/subject = $features-subj]//title-group/article-title" 
     id="feature-title-tests">
     <let name="sub-disp-channel" value="ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject"/>
     
     <report test="starts-with(.,$sub-disp-channel)"
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
		
	</rule>
   
   <rule context="article[@article-type = $features-article-types]//article-meta//contrib[@contrib-type='author']"
     id="feature-author-tests">
     
     <assert test="bio"
       role="error"
       id="feature-author-test-1">Author must contain child bio in feature content.</assert>
   </rule>
   
   <rule context="article[@article-type = $features-article-types]//article-meta//contrib[@contrib-type='author']/bio"
     id="feature-bio-tests">
     <let name="name" value="concat(parent::contrib/name/given-names,' ',parent::contrib/name/surname)"/>
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
      id="rrid-org-presence">		
      <let name="count" value="count(descendant::ext-link[matches(@xlink:href,'scicrunch\.org.*resolver')])"/>
      <let name="lc" value="lower-case(.)"/>
      <let name="text-count" value="number(e:rrid-text-count(.))"/>
      <let name="t" value="replace($lc,'drosophila genetic resource center|bloomington drosophila stock center','')"/>
      
      <report test="($text-count gt $count)"
        role="warning"
        id="rrid-test">'<name/>' element contains what looks like <value-of select="$text-count - $count"/> unlinked RRID(s). These should always be linked using 'https://scicrunch.org/resolver/'. Element begins with <value-of select="substring(.,1,15)"/>.</report>
      
      <report test="matches($t,$org-regex) and not(descendant::italic[contains(.,e:org-conform($t))])"
        role="warning" 
        id="org-test"><name/> element contains an organism - <value-of select="e:org-conform($t)"/> - but there is no italic element with that correct capitalisation or spacing. Is this correct? <name/> element begins with <value-of select="concat(.,substring(.,1,15))"/>.</report>
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
      
      <report test="(ref/element-citation/@publication-type != 'book') and ($doi = preceding-sibling::ref/element-citation/pub-id[@pub-id-type='doi'])"
        role="error" 
        id="duplicate-ref-test-1">ref '<value-of select="@id"/>' has the same doi as another reference, which is incorrect. Is it a duplicate?</report>
      
      <report test="(ref/element-citation/@publication-type = 'book') and  ($doi = preceding-sibling::ref/element-citation/pub-id[@pub-id-type='doi'])"
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
        id="duplicate-ref-test-6">ref '<value-of select="ancestor::ref/@id"/>' has a doi which is the same as the article itself '<value-of select="$top-doi"/>' which must be incorrect.</report>
    </rule>
    
  </pattern>
  
  <pattern id="ref-xref-pattern">
    
    <rule context="xref[@ref-type='bibr']" id="ref-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="ref" value="ancestor::article//descendant::ref-list//ref[@id = $rid]"/>
      <let name="cite1" value="e:citation-format1($ref//year)"/>
      <let name="cite2" value="e:citation-format2($ref//year)"/>
      <let name="cite3" value="normalize-space(replace($cite1,'\p{P}|\p{N}',''))"/>
      <let name="pre-text" value="preceding-sibling::text()[1]"/>
      <let name="post-text" value="following-sibling::text()[1]"/>
      <let name="pre-sentence" value="tokenize(replace($pre-text,' et al\. ',' et al '),'\. ')[position() = last()]"/>
      <let name="post-sentence" value="tokenize(replace($post-text,' et al\. ',' et al '),'\. ')[position() = 1]"/>
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
      
      <report test="((matches($pre-text,' from [\(]{1}$| in [\(]{1}$| by [\(]{1}$| of [\(]{1}$| on [\(]{1}$| to [\(]{1}$| see [\(]?$| see also [\(]?$| at [\(]?$') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' from [\(]{1}$| in [\(]{1}$| by [\(]{1}$| of [\(]{1}| on [\(]{1}$| to [\(]{1}$| see [\(]{1}$| see also [\(]{1}$| at [\(]{1}$') and matches($pre-text,'[\(].*[\(]') and matches($pre-text,'[\)]+'))
        or (matches($pre-text,' from $| in $| by $| of $| on $| to $') and not(matches($pre-text,'[\(]+')))
        or (matches($pre-text,' from $') and matches($pre-text,'[\(].*[\)].* from $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' in $') and matches($pre-text,'[\(].*[\)].* in $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' by $') and matches($pre-text,'[\(].*[\)].* by $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' of $') and matches($pre-text,'[\(].*[\)].* of $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' on $') and matches($pre-text,'[\(].*[\)].* on $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' to $') and matches($pre-text,'[\(].*[\)].* to $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' see $') and matches($pre-text,'[\(].*[\)].* see $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' see also $') and matches($pre-text,'[\(].*[\)].* see also $') and not(matches($pre-text,'[\(].*[\(]')))
        or (matches($pre-text,' at $') and matches($pre-text,'[\(].*[\)].* at $') and not(matches($pre-text,'[\(].*[\(]')))
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
      
      <report test="matches($pre-sentence,$cite3)"
        role="warning"
        id="ref-xref-test-14">citation is preceded by text containing much of the citation text which is possibly unnecessary - <value-of select="concat($pre-sentence,.)"/></report>
      
      <report test="matches($post-sentence,$cite3)"
        role="warning"
        id="ref-xref-test-15">citation is followed by text containing much of the citation text. Is this correct? - <value-of select="concat(.,$post-sentence)"/></report>
      
      <report test="matches($post-sentence,'^[\)]{2,}')"
        role="error"
        id="ref-xref-test-16">citation is followed by text starting with 2 or more closing brackets, which must be incorrect - <value-of select="concat(.,$post-sentence)"/></report>
      
      <report test="(not(matches($pre-sentence,'[\(]$|\[$|^[\)]'))) and (not(matches($pre-text,'; $| and $| see $|cf\. $'))) and (($open - $close) = 0) and (. = $cite1) and not(ancestor::td) and not(matches($post-sentence,'^[\)]'))"
        role="warning"
        id="ref-xref-test-17">citation is in parenthetic format - <value-of select="."/> - but the preceding text does not contain open parentheses. Should it be in the format - <value-of select="$cite2"/>?</report>
      
      <report test="($pre-sentence = ', ') and (($open - $close) = 0) and (. = $cite1) and not(ancestor::td)"
        role="warning"
        id="ref-xref-test-18">citation is in parenthetic format, but the preceding text is ', ' . Should the predecing text be '; ' instead? <value-of select="concat($pre-sentence,.)"/></report>
      
      <report test="matches(.,'^et al|^ and|^[\(]\d|^,')"
        role="error"
        id="ref-xref-test-19"><value-of select="."/> - citation doesn't start with an author's name which is incorrect.</report>
      
    </rule>
    
  </pattern>
  
  <pattern id="unlinked-ref-cite-pattern">
    
    <rule context="ref-list/ref/element-citation" id="unlinked-ref-cite">
      <let name="text" value="concat(ancestor::article/body,ancestor::article/back)"/>
      <let name="id" value="parent::ref/@id"/>
      <let name="cite1" value="e:citation-format1(year)"/>
      <let name="cite2" value="e:citation-format2(year)"/>
      <let name="cite-count" value="count(ancestor::article//xref[@rid = $id])"/>
      <let name="regex" value="concat($cite1,'|',$cite2)"/>
      <let name="text-count" value="count(for $x in tokenize($text,'\. ') return if (matches($x,$regex)) then $x else ())"/>
      
      <report test="($text-count &gt; $cite-count)" 
        role="error" 
        id="text-v-cite-test">ref with id <value-of select="$id"/> has unlinked citations in the text - search <value-of select="$cite1"/> or <value-of select="$cite2"/>.</report>
      
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
      
      <report test="($type = 'Figure supplement') and ($target-no != $no) and not(contains($no,substring($target-no,2)))"
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
    </rule>
  </pattern>
  
  <pattern id="table-xref-pattern">
    <rule context="xref[@ref-type='table']" id="table-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="text-no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="rid-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="prec-text" value="preceding-sibling::text()[1]"/>
      
      <report test="not(matches(.,'Table')) and ($prec-text != ' and ') and ($prec-text != '–') and ($prec-text != ', ') and not(contains($rid,'app'))"
        role="warning" 
        id="table-xref-conformity-1"><value-of select="."/> - citation points to table, but does not include the string 'Table', which is very unusual.</report>
      
      <report test="not(matches(.,'table')) and ($prec-text != ' and ') and ($prec-text != '–') and ($prec-text != ', ') and contains($rid,'app')"
        role="warning" 
        id="table-xref-conformity-2"><value-of select="."/> - citation points to and Appendix table, but does not include the string 'table', which is very unusual.</report>
      
      <report test="($text-no != $rid-no) and not(contains(.,'–'))"
        role="error" 
        id="table-xref-conformity-3"><value-of select="."/> - Citation content does not match what it directs to.</report>
      
      <report test="ancestor::table-wrap/@id = $rid"
        role="warning"
        id="table-xref-test-1"><value-of select="."/> - Citation is in the caption of the Table that it links to. Is it correct or necessary?</report>
    </rule>
    
  </pattern>
  
  <pattern id="supp-xref-pattern">
    
    <rule context="xref[@ref-type='supplementary-material']" id="supp-file-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="text-no" value="normalize-space(replace(.,'[^0-9]+',''))"/>
      <let name="last-text-no" value="substring($text-no,string-length($text-no), 1)"/>
      <let name="rid-no" value="replace($rid,'[^0-9]+','')"/>
      <let name="last-rid-no" value="substring($rid-no,string-length($rid-no))"/>
      <let name="prec-text" value="preceding-sibling::text()[1]"/>
      
      <report test="contains($rid,'data') and not(matches(.,'[Ss]ource data')) and ($prec-text != ' and ') and ($prec-text != '–') and ($prec-text != ', ')" 
        role="warning" 
        id="supp-file-xref-conformity-1"><value-of select="."/> - citation points to source data, but does not include the string 'source data', which is very unusual.</report>
      
      <report test="contains($rid,'code') and not(matches(.,'[Ss]ource code')) and ($prec-text != ' and ') and ($prec-text != '–') and ($prec-text != ', ')" 
        role="warning" 
        id="supp-file-xref-conformity-2"><value-of select="."/> - citation points to source code, but does not include the string 'source code', which is very unusual.</report>
      
      <report test="contains($rid,'supp') and not(matches(.,'[Ss]upplementary file')) and ($prec-text != ' and ') and ($prec-text != '–') and ($prec-text != ', ')" 
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
    </rule>
  </pattern>
  
  <pattern id="equation-xref-pattern">
    
    <rule context="xref[@ref-type='disp-formula']" id="equation-xref-conformance">
      <let name="rid" value="@rid"/>
      <let name="label" value="translate(ancestor::article//disp-formula[@id = $rid]/label,'()','')"/>
      <let name="prec-text" value="preceding-sibling::text()[1]"/>
      
      <report test="not(matches(.,'[Ee]quation')) and ($prec-text != ' and ') and ($prec-text != '–')" 
        role="warning" 
        id="equ-xref-conformity-1"><value-of select="."/> - link points to equation, but does not include the string 'Equation', which is unusual. Is it correct?</report>
      
      <assert test="contains(.,$label)" 
        role="error" 
        id="equ-xref-conformity-2"><value-of select="$label"/> - equation link content does not match what it directs to. Check that it is correct.</assert>
    </rule>
    
  </pattern>
  
  <pattern
    id="org-pattern">
    
    <rule context="element-citation[@publication-type='journal']/article-title"
      id="org-ref-article-book-title">	
      <let name="lc" value="lower-case(.)"/>
      
      <report test="matches($lc,'b\.\s?subtilis') and not(italic[contains(text() ,'B. subtilis')])"
        role="error" 
        id="bssubtilis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'B. subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'bacillus\s?subtilis') and not(italic[contains(text() ,'Bacillus subtilis')])"
        role="error" 
        id="bacillusssubtilis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Bacillus subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?melanogaster') and not(italic[contains(text() ,'D. melanogaster')])"
        role="error" 
        id="dsmelanogaster-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'D. melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?melanogaster') and not(italic[contains(text() ,'Drosophila melanogaster')])"
        role="error" 
        id="drosophilasmelanogaster-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Drosophila melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?coli') and not(italic[contains(text() ,'E. coli')])"
        role="error" 
        id="escoli-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'escherichia\s?coli') and not(italic[contains(text() ,'Escherichia coli')])"
        role="error" 
        id="escherichiascoli-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Escherichia coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pombe') and not(italic[contains(text() ,'S. pombe')])"
        role="error" 
        id="sspombe-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schizosaccharomyces\s?pombe') and not(italic[contains(text() ,'Schizosaccharomyces pombe')])"
        role="error" 
        id="schizosaccharomycesspombe-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Schizosaccharomyces pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?cerevisiae') and not(italic[contains(text() ,'S. cerevisiae')])"
        role="error" 
        id="sscerevisiae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'saccharomyces\s?cerevisiae') and not(italic[contains(text() ,'Saccharomyces cerevisiae')])"
        role="error" 
        id="saccharomycesscerevisiae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Saccharomyces cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?elegans') and not(italic[contains(text() ,'C. elegans')])"
        role="error" 
        id="cselegans-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'caenorhabditis\s?elegans') and not(italic[contains(text() ,'Caenorhabditis elegans')])"
        role="error" 
        id="caenorhabditisselegans-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Caenorhabditis elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'a\.\s?thaliana') and not(italic[contains(text() ,'A. thaliana')])"
        role="error" 
        id="asthaliana-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'A. thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'arabidopsis\s?thaliana') and not(italic[contains(text() ,'Arabidopsis thaliana')])"
        role="error" 
        id="arabidopsissthaliana-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Arabidopsis thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?thermophila') and not(italic[contains(text() ,'M. thermophila')])"
        role="error" 
        id="msthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'M. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'myceliophthora\s?thermophila') and not(italic[contains(text() ,'Myceliophthora thermophila')])"
        role="error" 
        id="myceliophthorasthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Myceliophthora thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'dictyostelium') and not(italic[contains(text() ,'Dictyostelium')])"
        role="error" 
        id="dictyostelium-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Dictyostelium' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?falciparum') and not(italic[contains(text() ,'P. falciparum')])"
        role="error" 
        id="psfalciparum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'P. falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plasmodium\s?falciparum') and not(italic[contains(text() ,'Plasmodium falciparum')])"
        role="error" 
        id="plasmodiumsfalciparum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Plasmodium falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?enterica') and not(italic[contains(text() ,'S. enterica')])"
        role="error" 
        id="ssenterica-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salmonella\s?enterica') and not(italic[contains(text() ,'Salmonella enterica')])"
        role="error" 
        id="salmonellasenterica-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Salmonella enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pyogenes') and not(italic[contains(text() ,'S. pyogenes')])"
        role="error" 
        id="sspyogenes-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'streptococcus\s?pyogenes') and not(italic[contains(text() ,'Streptococcus pyogenes')])"
        role="error" 
        id="streptococcusspyogenes-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Streptococcus pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?dumerilii') and not(italic[contains(text() ,'P. dumerilii')])"
        role="error" 
        id="psdumerilii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'P. dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'platynereis\s?dumerilii') and not(italic[contains(text() ,'Platynereis dumerilii')])"
        role="error" 
        id="platynereissdumerilii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Platynereis dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?cynocephalus') and not(italic[contains(text() ,'P. cynocephalus')])"
        role="error" 
        id="pscynocephalus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'P. cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'papio\s?cynocephalus') and not(italic[contains(text() ,'Papio cynocephalus')])"
        role="error" 
        id="papioscynocephalus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Papio cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'o\.\s?fasciatus') and not(italic[contains(text() ,'O. fasciatus')])"
        role="error" 
        id="osfasciatus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'O. fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'oncopeltus\s?fasciatus') and not(italic[contains(text() ,'Oncopeltus fasciatus')])"
        role="error" 
        id="oncopeltussfasciatus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Oncopeltus fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?crassa') and not(italic[contains(text() ,'N. crassa')])"
        role="error" 
        id="nscrassa-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'N. crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'neurospora\s?crassa') and not(italic[contains(text() ,'Neurospora crassa')])"
        role="error" 
        id="neurosporascrassa-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Neurospora crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?intestinalis') and not(italic[contains(text() ,'C. intestinalis')])"
        role="error" 
        id="csintestinalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'ciona\s?intestinalis') and not(italic[contains(text() ,'Ciona intestinalis')])"
        role="error" 
        id="cionasintestinalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Ciona intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?cuniculi') and not(italic[contains(text() ,'E. cuniculi')])"
        role="error" 
        id="escuniculi-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'encephalitozoon\s?cuniculi') and not(italic[contains(text() ,'Encephalitozoon cuniculi')])"
        role="error" 
        id="encephalitozoonscuniculi-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Encephalitozoon cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?salinarum') and not(italic[contains(text() ,'H. salinarum')])"
        role="error" 
        id="hssalinarum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'H. salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'halobacterium\s?salinarum') and not(italic[contains(text() ,'Halobacterium salinarum')])"
        role="error" 
        id="halobacteriumssalinarum-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Halobacterium salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?solfataricus') and not(italic[contains(text() ,'S. solfataricus')])"
        role="error" 
        id="sssolfataricus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'sulfolobus\s?solfataricus') and not(italic[contains(text() ,'Sulfolobus solfataricus')])"
        role="error" 
        id="sulfolobusssolfataricus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Sulfolobus solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?mediterranea') and not(italic[contains(text() ,'S. mediterranea')])"
        role="error" 
        id="ssmediterranea-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schmidtea\s?mediterranea') and not(italic[contains(text() ,'Schmidtea mediterranea')])"
        role="error" 
        id="schmidteasmediterranea-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Schmidtea mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?rosetta') and not(italic[contains(text() ,'S. rosetta')])"
        role="error" 
        id="ssrosetta-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salpingoeca\s?rosetta') and not(italic[contains(text() ,'Salpingoeca rosetta')])"
        role="error" 
        id="salpingoecasrosetta-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Salpingoeca rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?vectensis') and not(italic[contains(text() ,'N. vectensis')])"
        role="error" 
        id="nsvectensis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'N. vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nematostella\s?vectensis') and not(italic[contains(text() ,'Nematostella vectensis')])"
        role="error" 
        id="nematostellasvectensis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Nematostella vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?aureus') and not(italic[contains(text() ,'S. aureus')])"
        role="error" 
        id="ssaureus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'S. aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'staphylococcus\s?aureus') and not(italic[contains(text() ,'Staphylococcus aureus')])"
        role="error" 
        id="staphylococcussaureus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Staphylococcus aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'v\.\s?cholerae') and not(italic[contains(text() ,'V. cholerae')])"
        role="error" 
        id="vscholerae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'V. cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'vibrio\s?cholerae') and not(italic[contains(text() ,'Vibrio cholerae')])"
        role="error" 
        id="vibrioscholerae-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Vibrio cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'t\.\s?thermophila') and not(italic[contains(text() ,'T. thermophila')])"
        role="error" 
        id="tsthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'T. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'tetrahymena\s?thermophila') and not(italic[contains(text() ,'Tetrahymena thermophila')])"
        role="error" 
        id="tetrahymenasthermophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Tetrahymena thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?reinhardtii') and not(italic[contains(text() ,'C. reinhardtii')])"
        role="error" 
        id="csreinhardtii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydomonas\s?reinhardtii') and not(italic[contains(text() ,'Chlamydomonas reinhardtii')])"
        role="error" 
        id="chlamydomonassreinhardtii-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Chlamydomonas reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?attenuata') and not(italic[contains(text() ,'N. attenuata')])"
        role="error" 
        id="nsattenuata-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'N. attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nicotiana\s?attenuata') and not(italic[contains(text() ,'Nicotiana attenuata')])"
        role="error" 
        id="nicotianasattenuata-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Nicotiana attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?carotovora') and not(italic[contains(text() ,'E. carotovora')])"
        role="error" 
        id="escarotovora-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'erwinia\s?carotovora') and not(italic[contains(text() ,'Erwinia carotovora')])"
        role="error" 
        id="erwiniascarotovora-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Erwinia carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?faecalis') and not(italic[contains(text() ,'E. faecalis')])"
        role="error" 
        id="esfaecalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'E. faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?sapiens') and not(italic[contains(text() ,'H. sapiens')])"
        role="error" 
        id="hsapiens-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'H. sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'homo\s?sapiens') and not(italic[contains(text() ,'Homo sapiens')])"
        role="error" 
        id="homosapiens-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Homo sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?trachomatis') and not(italic[contains(text() ,'C. trachomatis')])"
        role="error" 
        id="ctrachomatis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'C. trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydia\s?trachomatis') and not(italic[contains(text() ,'Chlamydia trachomatis')])"
        role="error" 
        id="chlamydiatrachomatis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Chlamydia trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'enterococcus\s?faecalis') and not(italic[contains(text() ,'Enterococcus faecalis')])"
        role="error" 
        id="enterococcussfaecalis-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Enterococcus faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila') and not(italic[contains(text(),'Drosophila')])"
        role="error" 
        id="drosophila-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Drosophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus') and not(italic[contains(text() ,'Xenopus')])"
        role="error" 
        id="xenopus-ref-article-title-check">ref <value-of select="ancestor::ref/@id"/> references an organism - 'Xenopus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
    </rule>
    
    <rule context="article//article-meta/title-group/article-title"
      id="org-article-title">		
      <let name="lc" value="lower-case(.)"/>
      
      <report test="matches($lc,'b\.\s?subtilis') and not(italic[contains(text() ,'B. subtilis')])"
        role="error" 
        id="bssubtilis-article-title-check">article title contains an organism - 'B. subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'bacillus\s?subtilis') and not(italic[contains(text() ,'Bacillus subtilis')])"
        role="error" 
        id="bacillusssubtilis-article-title-check">article title contains an organism - 'Bacillus subtilis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'d\.\s?melanogaster') and not(italic[contains(text() ,'D. melanogaster')])"
        role="error" 
        id="dsmelanogaster-article-title-check">article title contains an organism - 'D. melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila\s?melanogaster') and not(italic[contains(text() ,'Drosophila melanogaster')])"
        role="error" 
        id="drosophilasmelanogaster-article-title-check">article title contains an organism - 'Drosophila melanogaster' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?coli') and not(italic[contains(text() ,'E. coli')])"
        role="error" 
        id="escoli-article-title-check">article title contains an organism - 'E. coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'escherichia\s?coli') and not(italic[contains(text() ,'Escherichia coli')])"
        role="error" 
        id="escherichiascoli-article-title-check">article title contains an organism - 'Escherichia coli' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pombe') and not(italic[contains(text() ,'S. pombe')])"
        role="error" 
        id="sspombe-article-title-check">article title contains an organism - 'S. pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schizosaccharomyces\s?pombe') and not(italic[contains(text() ,'Schizosaccharomyces pombe')])"
        role="error" 
        id="schizosaccharomycesspombe-article-title-check">article title contains an organism - 'Schizosaccharomyces pombe' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?cerevisiae') and not(italic[contains(text() ,'S. cerevisiae')])"
        role="error" 
        id="sscerevisiae-article-title-check">article title contains an organism - 'S. cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'saccharomyces\s?cerevisiae') and not(italic[contains(text() ,'Saccharomyces cerevisiae')])"
        role="error" 
        id="saccharomycesscerevisiae-article-title-check">article title contains an organism - 'Saccharomyces cerevisiae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?elegans') and not(italic[contains(text() ,'C. elegans')])"
        role="error" 
        id="cselegans-article-title-check">article title contains an organism - 'C. elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'caenorhabditis\s?elegans') and not(italic[contains(text() ,'Caenorhabditis elegans')])"
        role="error" 
        id="caenorhabditisselegans-article-title-check">article title contains an organism - 'Caenorhabditis elegans' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'a\.\s?thaliana') and not(italic[contains(text() ,'A. thaliana')])"
        role="error" 
        id="asthaliana-article-title-check">article title contains an organism - 'A. thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'arabidopsis\s?thaliana') and not(italic[contains(text() ,'Arabidopsis thaliana')])"
        role="error" 
        id="arabidopsissthaliana-article-title-check">article title contains an organism - 'Arabidopsis thaliana' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'m\.\s?thermophila') and not(italic[contains(text() ,'M. thermophila')])"
        role="error" 
        id="msthermophila-article-title-check">article title contains an organism - 'M. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'myceliophthora\s?thermophila') and not(italic[contains(text() ,'Myceliophthora thermophila')])"
        role="error" 
        id="myceliophthorasthermophila-article-title-check">article title contains an organism - 'Myceliophthora thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'dictyostelium') and not(italic[contains(text() ,'Dictyostelium')])"
        role="error" 
        id="dictyostelium-article-title-check">article title contains an organism - 'Dictyostelium' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?falciparum') and not(italic[contains(text() ,'P. falciparum')])"
        role="error" 
        id="psfalciparum-article-title-check">article title contains an organism - 'P. falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'plasmodium\s?falciparum') and not(italic[contains(text() ,'Plasmodium falciparum')])"
        role="error" 
        id="plasmodiumsfalciparum-article-title-check">article title contains an organism - 'Plasmodium falciparum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?enterica') and not(italic[contains(text() ,'S. enterica')])"
        role="error" 
        id="ssenterica-article-title-check">article title contains an organism - 'S. enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salmonella\s?enterica') and not(italic[contains(text() ,'Salmonella enterica')])"
        role="error" 
        id="salmonellasenterica-article-title-check">article title contains an organism - 'Salmonella enterica' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?pyogenes') and not(italic[contains(text() ,'S. pyogenes')])"
        role="error" 
        id="sspyogenes-article-title-check">article title contains an organism - 'S. pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'streptococcus\s?pyogenes') and not(italic[contains(text() ,'Streptococcus pyogenes')])"
        role="error" 
        id="streptococcusspyogenes-article-title-check">article title contains an organism - 'Streptococcus pyogenes' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?dumerilii') and not(italic[contains(text() ,'P. dumerilii')])"
        role="error" 
        id="psdumerilii-article-title-check">article title contains an organism - 'P. dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'platynereis\s?dumerilii') and not(italic[contains(text() ,'Platynereis dumerilii')])"
        role="error" 
        id="platynereissdumerilii-article-title-check">article title contains an organism - 'Platynereis dumerilii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'p\.\s?cynocephalus') and not(italic[contains(text() ,'P. cynocephalus')])"
        role="error" 
        id="pscynocephalus-article-title-check">article title contains an organism - 'P. cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'papio\s?cynocephalus') and not(italic[contains(text() ,'Papio cynocephalus')])"
        role="error" 
        id="papioscynocephalus-article-title-check">article title contains an organism - 'Papio cynocephalus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'o\.\s?fasciatus') and not(italic[contains(text() ,'O. fasciatus')])"
        role="error" 
        id="osfasciatus-article-title-check">article title contains an organism - 'O. fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'oncopeltus\s?fasciatus') and not(italic[contains(text() ,'Oncopeltus fasciatus')])"
        role="error" 
        id="oncopeltussfasciatus-article-title-check">article title contains an organism - 'Oncopeltus fasciatus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?crassa') and not(italic[contains(text() ,'N. crassa')])"
        role="error" 
        id="nscrassa-article-title-check">article title contains an organism - 'N. crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'neurospora\s?crassa') and not(italic[contains(text() ,'Neurospora crassa')])"
        role="error" 
        id="neurosporascrassa-article-title-check">article title contains an organism - 'Neurospora crassa' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?intestinalis') and not(italic[contains(text() ,'C. intestinalis')])"
        role="error" 
        id="csintestinalis-article-title-check">article title contains an organism - 'C. intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'ciona\s?intestinalis') and not(italic[contains(text() ,'Ciona intestinalis')])"
        role="error" 
        id="cionasintestinalis-article-title-check">article title contains an organism - 'Ciona intestinalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?cuniculi') and not(italic[contains(text() ,'E. cuniculi')])"
        role="error" 
        id="escuniculi-article-title-check">article title contains an organism - 'E. cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'encephalitozoon\s?cuniculi') and not(italic[contains(text() ,'Encephalitozoon cuniculi')])"
        role="error" 
        id="encephalitozoonscuniculi-article-title-check">article title contains an organism - 'Encephalitozoon cuniculi' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?salinarum') and not(italic[contains(text() ,'H. salinarum')])"
        role="error" 
        id="hssalinarum-article-title-check">article title contains an organism - 'H. salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'halobacterium\s?salinarum') and not(italic[contains(text() ,'Halobacterium salinarum')])"
        role="error" 
        id="halobacteriumssalinarum-article-title-check">article title contains an organism - 'Halobacterium salinarum' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?solfataricus') and not(italic[contains(text() ,'S. solfataricus')])"
        role="error" 
        id="sssolfataricus-article-title-check">article title contains an organism - 'S. solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'sulfolobus\s?solfataricus') and not(italic[contains(text() ,'Sulfolobus solfataricus')])"
        role="error" 
        id="sulfolobusssolfataricus-article-title-check">article title contains an organism - 'Sulfolobus solfataricus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?mediterranea') and not(italic[contains(text() ,'S. mediterranea')])"
        role="error" 
        id="ssmediterranea-article-title-check">article title contains an organism - 'S. mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'schmidtea\s?mediterranea') and not(italic[contains(text() ,'Schmidtea mediterranea')])"
        role="error" 
        id="schmidteasmediterranea-article-title-check">article title contains an organism - 'Schmidtea mediterranea' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?rosetta') and not(italic[contains(text() ,'S. rosetta')])"
        role="error" 
        id="ssrosetta-article-title-check">article title contains an organism - 'S. rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'salpingoeca\s?rosetta') and not(italic[contains(text() ,'Salpingoeca rosetta')])"
        role="error" 
        id="salpingoecasrosetta-article-title-check">article title contains an organism - 'Salpingoeca rosetta' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?vectensis') and not(italic[contains(text() ,'N. vectensis')])"
        role="error" 
        id="nsvectensis-article-title-check">article title contains an organism - 'N. vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nematostella\s?vectensis') and not(italic[contains(text() ,'Nematostella vectensis')])"
        role="error" 
        id="nematostellasvectensis-article-title-check">article title contains an organism - 'Nematostella vectensis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'s\.\s?aureus') and not(italic[contains(text() ,'S. aureus')])"
        role="error" 
        id="ssaureus-article-title-check">article title contains an organism - 'S. aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'staphylococcus\s?aureus') and not(italic[contains(text() ,'Staphylococcus aureus')])"
        role="error" 
        id="staphylococcussaureus-article-title-check">article title contains an organism - 'Staphylococcus aureus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'v\.\s?cholerae') and not(italic[contains(text() ,'V. cholerae')])"
        role="error" 
        id="vscholerae-article-title-check">article title contains an organism - 'V. cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'vibrio\s?cholerae') and not(italic[contains(text() ,'Vibrio cholerae')])"
        role="error" 
        id="vibrioscholerae-article-title-check">article title contains an organism - 'Vibrio cholerae' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'t\.\s?thermophila') and not(italic[contains(text() ,'T. thermophila')])"
        role="error" 
        id="tsthermophila-article-title-check">article title contains an organism - 'T. thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'tetrahymena\s?thermophila') and not(italic[contains(text() ,'Tetrahymena thermophila')])"
        role="error" 
        id="tetrahymenasthermophila-article-title-check">article title contains an organism - 'Tetrahymena thermophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?reinhardtii') and not(italic[contains(text() ,'C. reinhardtii')])"
        role="error" 
        id="csreinhardtii-article-title-check">article title contains an organism - 'C. reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydomonas\s?reinhardtii') and not(italic[contains(text() ,'Chlamydomonas reinhardtii')])"
        role="error" 
        id="chlamydomonassreinhardtii-article-title-check">article title contains an organism - 'Chlamydomonas reinhardtii' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'n\.\s?attenuata') and not(italic[contains(text() ,'N. attenuata')])"
        role="error" 
        id="nsattenuata-article-title-check">article title contains an organism - 'N. attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'nicotiana\s?attenuata') and not(italic[contains(text() ,'Nicotiana attenuata')])"
        role="error" 
        id="nicotianasattenuata-article-title-check">article title contains an organism - 'Nicotiana attenuata' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?carotovora') and not(italic[contains(text() ,'E. carotovora')])"
        role="error" 
        id="escarotovora-article-title-check">article title contains an organism - 'E. carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'erwinia\s?carotovora') and not(italic[contains(text() ,'Erwinia carotovora')])"
        role="error" 
        id="erwiniascarotovora-article-title-check">article title contains an organism - 'Erwinia carotovora' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'h\.\s?sapiens') and not(italic[contains(text() ,'H. sapiens')])"
        role="error" 
        id="hsapiens-article-title-check">article title contains an organism - 'H. sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'homo\s?sapiens') and not(italic[contains(text() ,'Homo sapiens')])"
        role="error" 
        id="homosapiens-article-title-check">article title contains an organism - 'Homo sapiens' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'c\.\s?trachomatis') and not(italic[contains(text() ,'C. trachomatis')])"
        role="error" 
        id="ctrachomatis-article-title-check">article title contains an organism - 'C. trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'chlamydia\s?trachomatis') and not(italic[contains(text() ,'Chlamydia trachomatis')])"
        role="error" 
        id="chlamydiatrachomatis-article-title-check">article title contains an organism - 'Chlamydia trachomatis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'e\.\s?faecalis') and not(italic[contains(text() ,'E. faecalis')])"
        role="error" 
        id="esfaecalis-article-title-check">article title contains an organism - 'E. faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'enterococcus\s?faecalis') and not(italic[contains(text() ,'Enterococcus faecalis')])"
        role="error" 
        id="enterococcussfaecalis-article-title-check">article title contains an organism - 'Enterococcus faecalis' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'drosophila') and not(italic[contains(text(),'Drosophila')])"
        role="error" 
        id="drosophila-article-title-check">article title contains an organism - 'Drosophila' - but there is no italic element with that correct capitalisation or spacing.</report>
      
      <report test="matches($lc,'xenopus') and not(italic[contains(text() ,'Xenopus')])"
        role="error" 
        id="xenopus-article-title-check">article title contains an organism - 'Xenopus' - but there is no italic element with that correct capitalisation or spacing.</report>
      
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
      
      <report test="matches(.,' [Rr]ef\. ')"
        role="error"
        id="ref-presence"><name/> element contains 'Ref.' which is either incorrect or unnecessary.</report>
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
    </rule>
    
    <rule context="front//aff/country"
      id="country-tests">
      <let name="countries" value="'countries.xml'"/>
      
      <report test=". = 'United States of America'"
        role="error"
        id="united-states-test-1"><value-of select="."/> is not allowed it. This should be 'United States'.</report>
      
      <report test=". = 'USA'"
        role="error"
        id="united-states-test-2"><value-of select="."/> is not allowed it. This should be 'United States'</report>
      
      <report test=". = 'UK'"
        role="error"
        id="united-kingdom-test-2"><value-of select="."/> is not allowed it. This should be 'United Kingdom'</report>
      
      <assert test=". = document($countries)/countries/country" 
        role="error" 
        id="gen-country-test">affiliation contains a country which is not in the allowed list - <value-of select="."/>.</assert>
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
    </rule>
    
    <rule context="element-citation[@publication-type='journal']/article-title" id="ref-article-title-tests">
      <let name="rep" value="replace(.,' [Ii]{1,3}\. | IV\. | V. | [Cc]\. [Ee]legans| vs\. | sp\. ','')"/>
      
      <report test="(matches($rep,'[A-Za-z]{2,}\. [A-Za-z]'))"
        role="warning" 
        id="article-title-fullstop-check-1">ref '<value-of select="ancestor::ref/@id"/>' has an article-title with a full stop. Is this correct, or has the journal/source title been included? Or perhaps the full stop should be a colon ':'?</report>
      
      <report test="matches(.,'\.$')"
        role="error" 
        id="article-title-fullstop-check-2">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which ends with a full stop, which cannot be correct.</report>
      
      <report test="matches(.,'^[Cc]orrection|^[Rr]etraction')"
        role="warning" 
        id="article-title-correction-check">ref '<value-of select="ancestor::ref/@id"/>' has an article-title which begins with 'Correction' or 'Retraction'. Is this a reference to the notice or the original article?</report>
      
    </rule>
    
    <rule context="element-citation[@publication-type='journal']" 
      id="journal-tests">
      
      <report test="not(fpage) and not(elocation-id)"
        role="warning" 
        id="eloc-page-assert">ref '<value-of select="ancestor::ref/@id"/>' is a journal, but it doesn't have a page range or e-location. Is this right?</report>
      
      <report test="matches(source,'[Bb]io[Rr]xiv|[Aa]r[Xx]iv')"
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
      
    </rule>
    
    <rule context="element-citation[@publication-type='website']" 
      id="website-tests">
      
      <report test="contains(ext-link,'github')"
        role="error" 
        id="github-web-test">web ref '<value-of select="ancestor::ref/@id"/>' has a link which contains 'github', therefore it should be captured as a software ref.</report>
    </rule>
    
    <rule context="element-citation[@publication-type='software']" 
      id="software-ref-tests">
      <let name="lc" value="lower-case(data-title)"/>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and not(matches(person-group[@person-group-type='author']/collab[1],'^R Development Core Team$'))"
        role="error" 
        id="R-test-1">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but it does not have one collab element containing 'R Development Core Team'.</report>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and (count(person-group[@person-group-type='author']/collab) != 1)"
        role="error" 
        id="R-test-2">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but it has <value-of select="count(person-group[@person-group-type='author']/collab)"/> collab element(s).</report>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and (count((publisher-loc[text() = 'Vienna, Austria'])) != 1)"
        role="error"
        id="R-test-3">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but does not have a &lt;publisher-loc&gt;Vienna, Austria&lt;/publisher-loc&gt; element.</report>
      
      <report test="matches($lc,'r: a language and environment for statistical computing') and (count(matches(ext-link/@xlink:href,'http[s]?://www.r-project.org/')) != 1)"
        role="error"
        id="R-test-4">software ref '<value-of select="ancestor::ref/@id"/>' has a data-title - <value-of select="data-title"/> - but does not have a 'http://www.r-project.org/' link.</report>
      
      <report test="matches(lower-case(source),'r: a language and environment for statistical computing')"
        role="error" 
        id="R-test-5">software ref '<value-of select="ancestor::ref/@id"/>' has a source - <value-of select="source"/> - but this is the data-title.</report>
      
    </rule>
    
    <rule context="element-citation/publisher-name" id="publisher-name-tests">
      
      <report test="matches(.,':')"
        role="warning" 
        id="publisher-name-colon">ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing a colon. Should the text preceding the colon instead be captured as publisher-loc?</report>
      
      <report test="matches(.,'[Ii]nc\.')"
        role="warning" 
        id="publisher-name-inc">ref '<value-of select="ancestor::ref/@id"/>' has a publisher-name containing the text 'Inc.' Should the fullstop be removed?</report>
    </rule>
    
    <rule context="element-citation/person-group[@person-group-type='author']//name" 
      id="ref-name-tests">
      
      <report test="matches(.,'[Aa]uthor')"
        role="warning" 
        id="author-test-1">name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Author'. Is this correct?</report>
      
      <report test="matches(.,'[Ed]itor')"
        role="warning" 
        id="author-test-2">name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Editor'. Is this correct?</report>
      
      <report test="matches(.,'[Pp]ress')"
        role="warning" 
        id="author-test-3">name in ref '<value-of select="ancestor::ref/@id"/>' contans the text 'Press'. Is this correct?</report>
    </rule>
    
    <rule context="element-citation/pub-id[@pub-id-type='isbn']" 
      id="isbn-conformity">
      <let name="t" value="translate(.,'-','')"/>
      <let name="sum" value="e:isbn-sum($t)"/>
      
      <assert test="number($sum) = 0"
        role="error" 
        id="isbn-conformity-test">pub-id contains an invalid ISBN. Should it be captured as another type of pub-id?</assert>
    </rule>
    
    <rule context="sec[@sec-type='data-availability']/p[1]" 
      id="data-availability-statement">
      
      <assert test="matches(.,'.$|\?$')"
        role="error" 
        id="DAS-sentence-conformity">The Data Availability Statement must end with a full stop.</assert>
      
      <report test="matches(.,'[Dd]ryad') and not(parent::sec//element-citation/pub-id[@assigning-authority='Dryad'])"
        role="error" 
        id="DAS-dryad-conformity">Data Availability Statement contains the word Dryad, but there is no data citationin the dataset section with a dryad assigning authority.</report>
      
    </rule>
    
    <rule context="sec/title" 
      id="sec-title-conformity">
      
      <report test="matches(.,'^[A-Za-z]{1,3}\)|^\([A-Za-z]{1,3}')"
        role="warning" 
        id="sec-title-list-check">Section title might start with a list indicator - '<value-of select="."/>'. Is this correct?</report>
      
    </rule>
    
    <rule context="abstract[not(@*)]" 
      id="abstract-house-tests">
      <let name="subj" value="parent::article-meta/article-categories/subj-group[@subj-group-type='display-channel']"/>
      
      <report test="descendant::xref[@ref-type='bibr']"
        role="warning" 
        id="xref-bibr-presence">Abstract contains a citation - '<value-of select="descendant::xref[@ref-type='bibr'][1]"/>' - which isn't usually allowed. Check that this is correct.</report>
      
      <report test="($subj = 'Research Communication') and (not(matches(self::*/descendant::p[2],'^Editorial note')))"
        role="error" 
        id="res-comm-test">'<value-of select="$subj"/>' has only one paragraph in its abstract or the second paragraph does not begin with 'Editorial note', which is incorrect.</report>
     
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
      
      <report test="($subj = 'Research Article') and not(descendant::table-wrap[@id = 'keyresource'])"
        role="warning" 
        id="KRT-presence">'<value-of select="$subj"/>' type articles often have a key resources table, but this does not. Is this correct?</report>
      
    </rule>
    
    <rule context="table-wrap[@id='keyresource']//td" 
      id="KRT-td-checks">
      
      <report test="matches(.,'10\.\d{4,9}/') and (count(ext-link[contains(@xlink:href,'doi.org')]) = 0)"
        role="error" 
        id="doi-link-test">td element containing - '<value-of select="."/>' - looks like it contains a doi, but it contains no link with 'doi.org', which is incorrect.</report>
      
      <report test="matches(.,'[Pp][Mm][Ii][Dd][:]?\s?\d{5,}') and (count(ext-link[contains(@xlink:href,'www.ncbi.nlm.nih.gov/pubmed/')]) = 0)"
        role="error" 
        id="PMID-link-test">td element containing - '<value-of select="."/>' - looks like it contains a PMID, but it contains no link pointing to PubMed, which is incorrect.</report>
      
      <report test="matches(.,'PMCID[:]?\s?PMC\d{3,}') and (count(ext-link[contains(@xlink:href,'www.ncbi.nlm.nih.gov/pmc')]) = 0)"
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
    
    <rule context="article/body//p[not(parent::list-item)]" 
      id="p-punctuation">
      <let name="para" value="replace(.,'&#x00A0;',' ')"/>
      
      <report test="if ((ancestor::article[@article-type='article-commentary']) and (count(preceding::p[ancestor::body]) = 0)) then () else if (descendant::*[last()]/ancestor::disp-formula) then () else not(matches($para,'\p{P}\s*?$'))"
        role="warning" 
        id="p-punctuation-test">paragraph doesn't end with punctuation - Is this correct?</report>
      
      <report test="if ((ancestor::article[@article-type='article-commentary']) and (count(preceding::p[ancestor::body]) = 0)) then () else if (descendant::*[last()]/ancestor::disp-formula) then () else not(matches($para,'\.\s*?$|:\s*?$|\?\s*?$|!\s*?$'))"
        role="warning" 
        id="p-bracket-test">paragraph doesn't end with a full stop, colon, question or excalamation mark - Is this correct?</report>
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
    
    <rule context="article" 
      id="code-fork">
      <let name="test" value="e:code-check(.)"/>
      
      <report test="$test//*:match"
        role="warning" 
        id="code-fork-info">Article possibly contains code that needs forking. Search - <value-of select="string-join(for $x in $test//*:match return $x,', ')"/></report>
    </rule>
  </pattern>
  
</schema>