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
  <let name="research-subj" value="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Correction', 'Retraction', 'Scientific Correspondence', 'Review Article')"/>
  <let name="notice-article-types" value="('correction','retraction','expression-of-concern')"/>
  <let name="notice-display-types" value="('Correction','Retraction','Expression of Concern')"/>
  <let name="allowed-article-types" value="('research-article','review-article',$features-article-types, $notice-article-types)"/>
  <let name="allowed-disp-subj" value="($research-subj, $features-subj)"/>
  <let name="MSAs" value="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
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
  <let name="org-regex" value="'b\.\p{Zs}?subtilis|bacillus\p{Zs}?subtilis|d\.\p{Zs}?melanogaster|drosophila\p{Zs}?melanogaster|e\.\p{Zs}?coli|escherichia\p{Zs}?coli|s\.\p{Zs}?pombe|schizosaccharomyces\p{Zs}?pombe|s\.\p{Zs}?cerevisiae|saccharomyces\p{Zs}?cerevisiae|c\.\p{Zs}?elegans|caenorhabditis\p{Zs}?elegans|a\.\p{Zs}?thaliana|arabidopsis\p{Zs}?thaliana|m\.\p{Zs}?thermophila|myceliophthora\p{Zs}?thermophila|dictyostelium|p\.\p{Zs}?falciparum|plasmodium\p{Zs}?falciparum|s\.\p{Zs}?enterica|salmonella\p{Zs}?enterica|s\.\p{Zs}?pyogenes|streptococcus\p{Zs}?pyogenes|p\.\p{Zs}?dumerilii|platynereis\p{Zs}?dumerilii|p\.\p{Zs}?cynocephalus|papio\p{Zs}?cynocephalus|o\.\p{Zs}?fasciatus|oncopeltus\p{Zs}?fasciatus|n\.\p{Zs}?crassa|neurospora\p{Zs}?crassa|c\.\p{Zs}?intestinalis|ciona\p{Zs}?intestinalis|e\.\p{Zs}?cuniculi|encephalitozoon\p{Zs}?cuniculi|h\.\p{Zs}?salinarum|halobacterium\p{Zs}?salinarum|s\.\p{Zs}?solfataricus|sulfolobus\p{Zs}?solfataricus|s\.\p{Zs}?mediterranea|schmidtea\p{Zs}?mediterranea|s\.\p{Zs}?rosetta|salpingoeca\p{Zs}?rosetta|n\.\p{Zs}?vectensis|nematostella\p{Zs}?vectensis|s\.\p{Zs}?aureus|staphylococcus\p{Zs}?aureus|v\.\p{Zs}?cholerae|vibrio\p{Zs}?cholerae|t\.\p{Zs}?thermophila|tetrahymena\p{Zs}?thermophila|c\.\p{Zs}?reinhardtii|chlamydomonas\p{Zs}?reinhardtii|n\.\p{Zs}?attenuata|nicotiana\p{Zs}?attenuata|e\.\p{Zs}?carotovora|erwinia\p{Zs}?carotovora|e\.\p{Zs}?faecalis|h\.\p{Zs}?sapiens|homo\p{Zs}?sapiens|c\.\p{Zs}?trachomatis|chlamydia\p{Zs}?trachomatis|enterococcus\p{Zs}?faecalis|x\.\p{Zs}?laevis|xenopus\p{Zs}?laevis|x\.\p{Zs}?tropicalis|xenopus\p{Zs}?tropicalis|m\.\p{Zs}?musculus|mus\p{Zs}?musculus|d\.\p{Zs}?immigrans|drosophila\p{Zs}?immigrans|d\.\p{Zs}?subobscura|drosophila\p{Zs}?subobscura|d\.\p{Zs}?affinis|drosophila\p{Zs}?affinis|d\.\p{Zs}?obscura|drosophila\p{Zs}?obscura|f\.\p{Zs}?tularensis|francisella\p{Zs}?tularensis|p\.\p{Zs}?plantaginis|podosphaera\p{Zs}?plantaginis|p\.\p{Zs}?lanceolata|plantago\p{Zs}?lanceolata|m\.\p{Zs}?trossulus|mytilus\p{Zs}?trossulus|m\.\p{Zs}?edulis|mytilus\p{Zs}?edulis|m\.\p{Zs}?chilensis|mytilus\p{Zs}?chilensis|u\.\p{Zs}?maydis|ustilago\p{Zs}?maydis|p\.\p{Zs}?knowlesi|plasmodium\p{Zs}?knowlesi|p\.\p{Zs}?aeruginosa|pseudomonas\p{Zs}?aeruginosa|t\.\p{Zs}?brucei|trypanosoma\p{Zs}?brucei|caulobacter\p{Zs}?crescentus|c\.\p{Zs}?crescentus|agrobacterium\p{Zs}?tumefaciens|a\.\p{Zs}?tumefaciens|t\.\p{Zs}?gondii|toxoplasma\p{Zs}?gondii|d\.\p{Zs}?rerio|danio\p{Zs}?rerio|drosophila|yimenosaurus|lesothosaurus\p{Zs}?diagnosticus|l.\p{Zs}?diagnosticus|scelidosaurus\p{Zs}?harrisonii|s.\p{Zs}?harrisonii|haya\p{Zs}?griva|h.\p{Zs}?griva|polacanthus\p{Zs}?foxii|p.\p{Zs}?foxii|scutellosaurus\p{Zs}?lawleri|s.\p{Zs}?lawleri|saichania\p{Zs}?chulsanensis|s.\p{Zs}?chulsanensis|gargoyleosaurus\p{Zs}?parkpinorum|g.\p{Zs}?parkpinorum|europelta\p{Zs}?carbonensis|e.\p{Zs}?carbonensis|stegosaurus\p{Zs}?stenops|s.\p{Zs}?stenops|pinacosaurus\p{Zs}?grangeri|p.\p{Zs}?grangeri|tatisaurus\p{Zs}?oehleri|t.\p{Zs}?oehleri|hungarosaurus\p{Zs}?tormai|h.\p{Zs}?tormai|lesothosaurus\p{Zs}?diagnosticus|l.\p{Zs}?diagnosticus|bienosaurus\p{Zs}?lufengensis|b.\p{Zs}?lufengensis|fabrosaurus\p{Zs}?australis|f.\p{Zs}?australis|chinshakiangosaurus\p{Zs}?chunghoensis|c.\p{Zs}?chunghoensis|euoplocephalus\p{Zs}?tutus|e.\p{Zs}?tutus|xenopus'"/>
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
      <xsl:when test="matches($s,'yimenosaurus')">
        <xsl:value-of select="'Yimenosaurus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'lesothosaurus\p{Zs}?diagnosticus')">
        <xsl:value-of select="'Lesothosaurus diagnosticus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'l\.\p{Zs}?diagnosticus')">
        <xsl:value-of select="'L. diagnosticus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'scelidosaurus\p{Zs}?harrisonii')">
        <xsl:value-of select="'Scelidosaurus harrisonii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?harrisonii')">
        <xsl:value-of select="'S. harrisonii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'haya\p{Zs}?griva')">
        <xsl:value-of select="'Haya griva'"/>
      </xsl:when>
      <xsl:when test="matches($s,'h\.\p{Zs}?griva')">
        <xsl:value-of select="'H. griva'"/>
      </xsl:when>
      <xsl:when test="matches($s,'polacanthus\p{Zs}?foxii')">
        <xsl:value-of select="'Polacanthus foxii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?foxii')">
        <xsl:value-of select="'P. foxii'"/>
      </xsl:when>
      <xsl:when test="matches($s,'scutellosaurus\p{Zs}?lawleri')">
        <xsl:value-of select="'Scutellosaurus lawleri'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?lawleri')">
        <xsl:value-of select="'S. lawleri'"/>
      </xsl:when>
      <xsl:when test="matches($s,'saichania\p{Zs}?chulsanensis')">
        <xsl:value-of select="'Saichania chulsanensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?chulsanensis')">
        <xsl:value-of select="'S. chulsanensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'gargoyleosaurus\p{Zs}?parkpinorum')">
        <xsl:value-of select="'Gargoyleosaurus parkpinorum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'g\.\p{Zs}?parkpinorum')">
        <xsl:value-of select="'G. parkpinorum'"/>
      </xsl:when>
      <xsl:when test="matches($s,'europelta\p{Zs}?carbonensis')">
        <xsl:value-of select="'Europelta carbonensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\p{Zs}?carbonensis')">
        <xsl:value-of select="'E. carbonensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'stegosaurus\p{Zs}?stenops')">
        <xsl:value-of select="'Stegosaurus stenops'"/>
      </xsl:when>
      <xsl:when test="matches($s,'s\.\p{Zs}?stenops')">
        <xsl:value-of select="'S. stenops'"/>
      </xsl:when>
      <xsl:when test="matches($s,'pinacosaurus\p{Zs}?grangeri')">
        <xsl:value-of select="'Pinacosaurus grangeri'"/>
      </xsl:when>
      <xsl:when test="matches($s,'p\.\p{Zs}?grangeri')">
        <xsl:value-of select="'P. grangeri'"/>
      </xsl:when>
      <xsl:when test="matches($s,'tatisaurus\p{Zs}?oehleri')">
        <xsl:value-of select="'Tatisaurus oehleri'"/>
      </xsl:when>
      <xsl:when test="matches($s,'t\.\p{Zs}?oehleri')">
        <xsl:value-of select="'T. oehleri'"/>
      </xsl:when>
      <xsl:when test="matches($s,'hungarosaurus\p{Zs}?tormai')">
        <xsl:value-of select="'Hungarosaurus tormai'"/>
      </xsl:when>
      <xsl:when test="matches($s,'h\.\p{Zs}?tormai')">
        <xsl:value-of select="'H. tormai'"/>
      </xsl:when>
      <xsl:when test="matches($s,'lesothosaurus\p{Zs}?diagnosticus')">
        <xsl:value-of select="'Lesothosaurus diagnosticus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'l\.\p{Zs}?diagnosticus')">
        <xsl:value-of select="'L. diagnosticus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'bienosaurus\p{Zs}?lufengensis')">
        <xsl:value-of select="'Bienosaurus lufengensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'b\.\p{Zs}?lufengensis')">
        <xsl:value-of select="'B. lufengensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'fabrosaurus\p{Zs}?australis')">
        <xsl:value-of select="'Fabrosaurus australis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'f\.\p{Zs}?australis')">
        <xsl:value-of select="'F. australis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'chinshakiangosaurus\p{Zs}?chunghoensis')">
        <xsl:value-of select="'Chinshakiangosaurus chunghoensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'c\.\p{Zs}?chunghoensis')">
        <xsl:value-of select="'C. chunghoensis'"/>
      </xsl:when>
      <xsl:when test="matches($s,'euoplocephalus\p{Zs}?tutus')">
        <xsl:value-of select="'Euoplocephalus tutus'"/>
      </xsl:when>
      <xsl:when test="matches($s,'e\.\p{Zs}?tutus')">
        <xsl:value-of select="'E. tutus'"/>
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
      
      <xsl:otherwise>
        <xsl:variable name="is-equal-contrib" select="if ($contrib-group/contrib[@contrib-type='author'][1]/@equal-contrib='yes') then true() else false()"/>
        <xsl:choose>
          <xsl:when test="$is-equal-contrib">
            
            <xsl:variable name="equal-contrib-rid" select="$contrib-group/contrib[@contrib-type='author'][1]/xref[starts-with(@rid,'equal-contrib')]/@rid"/>
            <xsl:variable name="first-authors" select="$contrib-group/contrib[@contrib-type='author' and @equal-contrib='yes' and xref[@rid=$equal-contrib-rid] and (not(preceding-sibling::contrib) or preceding-sibling::contrib[1][@equal-contrib='yes' and xref[@rid=$equal-contrib-rid]])]"/>
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
  <xsl:function name="e:get-weekday" as="xs:integer?">
    <xsl:param name="date" as="xs:anyAtomicType?"/>
    <xsl:sequence select="       if (empty($date)) then ()       else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7       "/>
  </xsl:function>
  <xsl:function name="e:line-count" as="xs:integer">
    <xsl:param name="arg" as="xs:string?"/>
    
    <xsl:sequence select="count(tokenize($arg,'(\r\n?|\n\r?)'))"/>
    
  </xsl:function>
  <pattern id="element-citation-web-tests">
    <rule context="element-citation[@publication-type='web']" id="elem-citation-web">
      <assert test="count(*) = count(person-group|article-title|source|year|ext-link|date-in-citation)" role="error" id="err-elem-cit-web-12">The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="web" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;ext-link&gt; and &lt;date-in-citation&gt;. Reference '<value-of select="ancestor::ref/@id"/>' has other elements.</assert>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::element-citation[@publication-type='web']" role="error" id="elem-citation-web-xspec-assert">element-citation[@publication-type='web'] must be present.</assert>
    </rule>
  </pattern>
</schema>