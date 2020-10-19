<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:file="java.io.File" xmlns:java="http://www.java.com/" version="2.0">
  <!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


   <!--KEYS AND FUNCTIONS-->
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:titleCaseToken" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:titleCase" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:article-type2title" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:sec-type2title" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:fig-id-type" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:stripDiacritics" as="xs:string">
      <xsl:param name="string" as="xs:string"/>
      <xsl:value-of select="replace(replace(replace(translate(normalize-unicode($string,'NFD'),'ƀȼđɇǥħɨɉꝁłøɍŧɏƶ','bcdeghijklortyz'),'\p{M}',''),'æ','ae'),'ß','ss')"/>
  </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:citation-format1" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:citation-format2" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:ref-cite-list">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:non-distinct-citations">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-name" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-collab">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:isbn-sum" as="xs:integer">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:escape-for-regex" as="xs:string">
      <xsl:param name="arg" as="xs:string?"/>
      <xsl:sequence select="replace($arg,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
  </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-ordinal" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:org-conform" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:code-check">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-xrefs">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-iso-pub-date">
      <xsl:param name="element"/>
      <xsl:choose>
         <xsl:when test="$element/ancestor-or-self::article//article-meta/pub-date[(@date-type='publication') or (@date-type='pub')]/month">
            <xsl:variable name="pub-date" select="$element/ancestor-or-self::article//article-meta/pub-date[(@date-type='publication') or (@date-type='pub')]"/>
            <xsl:value-of select="concat($pub-date/year,'-',$pub-date/month,'-',$pub-date/day)"/>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
  </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:line-count" as="xs:integer">
      <xsl:param name="arg" as="xs:string?"/>
    
      <xsl:sequence select="count(tokenize($arg,'(\r\n?|\n\r?)'))"/>
    
  </xsl:function>

   <!--DEFAULT RULES-->


   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="eLife Schematron" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.niso.org/schemas/ali/1.0/" prefix="ali"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XInclude" prefix="xi"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://saxon.sf.net/" prefix="saxon"/>
         <svrl:ns-prefix-in-attribute-values uri="http://purl.org/dc/terms/" prefix="dc"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
         <svrl:ns-prefix-in-attribute-values uri="https://elifesciences.org/namespace" prefix="e"/>
         <svrl:ns-prefix-in-attribute-values uri="java.io.File" prefix="file"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.java.com/" prefix="java"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">research-article-pattern</xsl:attribute>
            <xsl:attribute name="name">research-article-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ar-fig-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ar-fig-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M41"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-quote-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-quote-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ar-video-specific-pattern</xsl:attribute>
            <xsl:attribute name="name">ar-video-specific-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rep-fig-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">rep-fig-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-fig-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-fig-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-title-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-title-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-title-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-title-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rep-fig-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">rep-fig-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M48"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rep-fig-sup-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">rep-fig-sup-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-formula-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-formula-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M50"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">mml-math-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">mml-math-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">resp-table-wrap-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">resp-table-wrap-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M52"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reply-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reply-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reply-content-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reply-content-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M54"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-front-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-front-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-editor-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-editor-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-editor-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-editor-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reviewer-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reviewer-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reviewer-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reviewer-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-body-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-body-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-body-p-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-body-p-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">decision-missing-table-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">decision-missing-table-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-front-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-front-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-body-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-body-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-disp-quote-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-disp-quote-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-missing-disp-quote-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-missing-disp-quote-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M66"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-missing-disp-quote-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-missing-disp-quote-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M67"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-missing-table-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-missing-table-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M68"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sub-article-ext-link-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">sub-article-ext-link-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M69"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">feature-template-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">feature-template-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M70"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">eLife Schematron</svrl:text>
   <xsl:param name="allowed-article-types" select="('article-commentary', 'correction', 'discussion', 'editorial', 'research-article', 'retraction','review-article')"/>
   <xsl:param name="allowed-disp-subj" select="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Feature Article', 'Insight', 'Editorial', 'Correction', 'Retraction', 'Scientific Correspondence', 'Review Article')"/>
   <xsl:param name="features-subj" select="('Feature Article', 'Insight', 'Editorial')"/>
   <xsl:param name="features-article-types" select="('article-commentary','editorial','discussion')"/>
   <xsl:param name="research-subj" select="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Correction', 'Retraction', 'Scientific Correspondence', 'Review Article')"/>
   <xsl:param name="MSAs" select="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
   <xsl:param name="org-regex" select="'b\.\s?subtilis|bacillus\s?subtilis|d\.\s?melanogaster|drosophila\s?melanogaster|e\.\s?coli|escherichia\s?coli|s\.\s?pombe|schizosaccharomyces\s?pombe|s\.\s?cerevisiae|saccharomyces\s?cerevisiae|c\.\s?elegans|caenorhabditis\s?elegans|a\.\s?thaliana|arabidopsis\s?thaliana|m\.\s?thermophila|myceliophthora\s?thermophila|dictyostelium|p\.\s?falciparum|plasmodium\s?falciparum|s\.\s?enterica|salmonella\s?enterica|s\.\s?pyogenes|streptococcus\s?pyogenes|p\.\s?dumerilii|platynereis\s?dumerilii|p\.\s?cynocephalus|papio\s?cynocephalus|o\.\s?fasciatus|oncopeltus\s?fasciatus|n\.\s?crassa|neurospora\s?crassa|c\.\s?intestinalis|ciona\s?intestinalis|e\.\s?cuniculi|encephalitozoon\s?cuniculi|h\.\s?salinarum|halobacterium\s?salinarum|s\.\s?solfataricus|sulfolobus\s?solfataricus|s\.\s?mediterranea|schmidtea\s?mediterranea|s\.\s?rosetta|salpingoeca\s?rosetta|n\.\s?vectensis|nematostella\s?vectensis|s\.\s?aureus|staphylococcus\s?aureus|v\.\s?cholerae|vibrio\s?cholerae|t\.\s?thermophila|tetrahymena\s?thermophila|c\.\s?reinhardtii|chlamydomonas\s?reinhardtii|n\.\s?attenuata|nicotiana\s?attenuata|e\.\s?carotovora|erwinia\s?carotovora|e\.\s?faecalis|h\.\s?sapiens|homo\s?sapiens|c\.\s?trachomatis|chlamydia\s?trachomatis|enterococcus\s?faecalis|x\.\s?laevis|xenopus\s?laevis|x\.\s?tropicalis|xenopus\s?tropicalis|m\.\s?musculus|mus\s?musculus|d\.\s?immigrans|drosophila\s?immigrans|d\.\s?subobscura|drosophila\s?subobscura|d\.\s?affinis|drosophila\s?affinis|d\.\s?obscura|drosophila\s?obscura|f\.\s?tularensis|francisella\s?tularensis|p\.\s?plantaginis|podosphaera\s?plantaginis|p\.\s?lanceolata|plantago\s?lanceolata|m\.\s?trossulus|mytilus\s?trossulus|m\.\s?edulis|mytilus\s?edulis|m\.\s?chilensis|mytilus\s?chilensis|u\.\s?maydis|ustilago\s?maydis|p\.\s?knowlesi|plasmodium\s?knowlesi|p\.\s?aeruginosa|pseudomonas\s?aeruginosa|t\.\s?brucei|trypanosoma\s?brucei|caulobacter\s?crescentus|c\.\s?crescentus|d\.\s?rerio|danio\s?rerio|drosophila|xenopus'"/>
   <xsl:param name="sec-title-regex" select="string-join(     for $x in tokenize($org-regex,'\|')     return concat('^',$x,'$')     ,'|')"/>

   <!--PATTERN research-article-pattern-->


	  <!--RULE research-article-->
   <xsl:template match="article[@article-type='research-article']" priority="1000" mode="M40">
      <xsl:variable name="disp-channel" select="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>

		    <!--REPORT warning-->
      <xsl:if test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])">
            <xsl:attribute name="id">pre-test-r-article-d-letter</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A decision letter should be present for research articles.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="not($disp-channel = ('Scientific Correspondence','Feature Article')) and not(sub-article[@article-type='decision-letter'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($disp-channel = ('Scientific Correspondence','Feature Article')) and not(sub-article[@article-type='decision-letter'])">
            <xsl:attribute name="id">final-test-r-article-d-letter</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A decision letter must be present for research articles.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="($disp-channel = 'Feature Article') and not(sub-article[@article-type='decision-letter'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($disp-channel = 'Feature Article') and not(sub-article[@article-type='decision-letter'])">
            <xsl:attribute name="id">final-test-r-article-d-letter-feat</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A decision letter should be present for research articles. Feature template 5s almost always have a decision letter, but this one does not. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='reply'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='reply'])">
            <xsl:attribute name="id">test-r-article-a-reply</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author response should usually be present for research articles, but this one does not have one. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>

   <!--PATTERN ar-fig-tests-pattern-->


	  <!--RULE ar-fig-tests-->
   <xsl:template match="fig[ancestor::sub-article[@article-type='reply']]" priority="1000" mode="M41">
      <xsl:variable name="article-type" select="ancestor::article/@article-type"/>
      <xsl:variable name="count" select="count(ancestor::body//fig)"/>
      <xsl:variable name="pos" select="$count - count(following::fig)"/>
      <xsl:variable name="no" select="substring-after(@id,'fig')"/>

		    <!--REPORT error-->
      <xsl:if test="if ($article-type = ($features-article-types,'correction','retraction')) then ()         else not(label)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="if ($article-type = ($features-article-types,'correction','retraction')) then () else not(label)">
            <xsl:attribute name="id">ar-fig-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#ar-fig-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author Response fig must have a label.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="graphic"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="graphic">
               <xsl:attribute name="id">pre-ar-fig-test-3</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-ar-fig-test-3</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author Response fig does not have graphic. Ensure author query is added asking for file.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$no = string($pos)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$no = string($pos)">
               <xsl:attribute name="id">pre-ar-fig-position-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#pre-ar-fig-position-test</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="label"/>
                  <xsl:text/> does not appear in sequence which is likely incorrect. Relative to the other AR images it is placed in position <xsl:text/>
                  <xsl:value-of select="$pos"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>

   <!--PATTERN disp-quote-tests-pattern-->


	  <!--RULE disp-quote-tests-->
   <xsl:template match="disp-quote" priority="1000" mode="M42">
      <xsl:variable name="subj" select="ancestor::article//subj-group[@subj-group-type='display-channel']/subject[1]"/>

		    <!--REPORT warning-->
      <xsl:if test="ancestor::sub-article[@article-type='decision-letter']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::sub-article[@article-type='decision-letter']">
            <xsl:attribute name="id">disp-quote-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content is tagged as a display quote, which is almost definitely incorrect, since it's in a decision letter - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>

   <!--PATTERN ar-video-specific-pattern-->


	  <!--RULE ar-video-specific-->
   <xsl:template match="sub-article/body//media[@mimetype='video']" priority="1000" mode="M43">
      <xsl:variable name="count" select="count(ancestor::body//media[@mimetype='video'])"/>
      <xsl:variable name="pos" select="$count - count(following::media[@mimetype='video'])"/>
      <xsl:variable name="no" select="substring-after(@id,'video')"/>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$no = string($pos)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$no = string($pos)">
               <xsl:attribute name="id">pre-ar-video-position-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="label"/>
                  <xsl:text/> does not appear in sequence which is likely incorrect. Relative to the other AR videos it is placed in position <xsl:text/>
                  <xsl:value-of select="$pos"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>

   <!--PATTERN rep-fig-tests-pattern-->


	  <!--RULE rep-fig-tests-->
   <xsl:template match="sub-article[@article-type='reply']//fig" priority="1000" mode="M44">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="label"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="label">
               <xsl:attribute name="id">resp-fig-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>fig must have a label.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(label[1],'^Author response image [0-9]{1,3}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(label[1],'^Author response image [0-9]{1,3}\.$|^Chemical structure \d{1,4}\.$|^Scheme \d{1,4}\.$')">
               <xsl:attribute name="id">reply-fig-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#reply-fig-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>fig label in author response must be in the format 'Author response image 1.', or 'Chemical Structure 1.', or 'Scheme 1.'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>

   <!--PATTERN dec-fig-tests-pattern-->


	  <!--RULE dec-fig-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']//fig" priority="1000" mode="M45">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="label"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="label">
               <xsl:attribute name="id">dec-fig-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#dec-fig-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>fig must have a label.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(label[1],'^Decision letter image [0-9]{1,3}\.$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(label[1],'^Decision letter image [0-9]{1,3}\.$')">
               <xsl:attribute name="id">dec-fig-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#dec-fig-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>fig label in author response must be in the format 'Decision letter image 1.'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>

   <!--PATTERN dec-letter-title-tests-pattern-->


	  <!--RULE dec-letter-title-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/title-group" priority="1000" mode="M46">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-title = 'Decision letter'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-title = 'Decision letter'">
               <xsl:attribute name="id">dec-letter-title-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-title-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>title-group must contain article-title which contains 'Decision letter'. Currently it is <xsl:text/>
                  <xsl:value-of select="article-title"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>

   <!--PATTERN reply-title-tests-pattern-->


	  <!--RULE reply-title-tests-->
   <xsl:template match="sub-article[@article-type='reply']/front-stub/title-group" priority="1000" mode="M47">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-title = 'Author response'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-title = 'Author response'">
               <xsl:attribute name="id">reply-title-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-title-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>title-group must contain article-title which contains 'Author response'. Currently it is <xsl:text/>
                  <xsl:value-of select="article-title"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>

   <!--PATTERN rep-fig-ids-pattern-->


	  <!--RULE rep-fig-ids-->
   <xsl:template match="sub-article//fig[not(@specific-use='child-fig')]" priority="1000" mode="M48">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')">
               <xsl:attribute name="id">resp-fig-id-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-id-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>fig in decision letter/author response must have @id in the format respfig0, or sa0fig0. <xsl:text/>
                  <xsl:value-of select="@id"/>
                  <xsl:text/> does not conform to this.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>

   <!--PATTERN rep-fig-sup-ids-pattern-->


	  <!--RULE rep-fig-sup-ids-->
   <xsl:template match="sub-article//fig[@specific-use='child-fig']" priority="1000" mode="M49">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')">
               <xsl:attribute name="id">resp-fig-sup-id-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/figures#resp-fig-sup-id-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>figure supplement in decision letter/author response must have @id in the format respfig0s0 or sa0fig0s0. <xsl:text/>
                  <xsl:value-of select="@id"/>
                  <xsl:text/> does not conform to this.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>

   <!--PATTERN disp-formula-ids-pattern-->


	  <!--RULE disp-formula-ids-->
   <xsl:template match="disp-formula" priority="1000" mode="M50">

		<!--REPORT error-->
      <xsl:if test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))">
            <xsl:attribute name="id">sub-disp-formula-id-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>disp-formula @id must be in the format 'sa0equ0' when in a sub-article.  <xsl:text/>
               <xsl:value-of select="@id"/>
               <xsl:text/> does not conform to this.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>

   <!--PATTERN mml-math-ids-pattern-->


	  <!--RULE mml-math-ids-->
   <xsl:template match="disp-formula/mml:math" priority="1000" mode="M51">

		<!--REPORT error-->
      <xsl:if test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))">
            <xsl:attribute name="id">sub-mml-math-id-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>mml:math @id in disp-formula must be in the format 'sa0m0'.  <xsl:text/>
               <xsl:value-of select="@id"/>
               <xsl:text/> does not conform to this.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>

   <!--PATTERN resp-table-wrap-ids-pattern-->


	  <!--RULE resp-table-wrap-ids-->
   <xsl:template match="sub-article//table-wrap" priority="1000" mode="M52">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$')         else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$') else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')">
               <xsl:attribute name="id">resp-table-wrap-id-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/allowed-assets/tables#resp-table-wrap-id-test</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>table-wrap @id in author reply must be in the format 'resptable0' or 'sa0table0' if it has a label, or in the format 'respinlinetable0' or 'sa0inlinetable0' if it does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>

   <!--PATTERN dec-letter-reply-tests-pattern-->


	  <!--RULE dec-letter-reply-tests-->
   <xsl:template match="article/sub-article" priority="1000" mode="M53">
      <xsl:variable name="pos" select="count(parent::article/sub-article) - count(following-sibling::sub-article)"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="if ($pos = 1) then @article-type='decision-letter'         else @article-type='reply'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="if ($pos = 1) then @article-type='decision-letter' else @article-type='reply'">
               <xsl:attribute name="id">dec-letter-reply-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>1st sub-article must be the decision letter. 2nd sub-article must be the author response.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@id = concat('sa',$pos)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@id = concat('sa',$pos)">
               <xsl:attribute name="id">dec-letter-reply-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article id must be in the format 'sa0', where '0' is its position (1 or 2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(front-stub) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(front-stub) = 1">
               <xsl:attribute name="id">dec-letter-reply-test-3</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article must contain one and only one front-stub.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(body) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(body) = 1">
               <xsl:attribute name="id">dec-letter-reply-test-4</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-4</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article must contain one and only one body.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>

   <!--PATTERN dec-letter-reply-content-tests-pattern-->


	  <!--RULE dec-letter-reply-content-tests-->
   <xsl:template match="article/sub-article//p" priority="1000" mode="M54">

		<!--REPORT error-->
      <xsl:if test="matches(.,'&lt;[/]?[Aa]uthor response')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'&lt;[/]?[Aa]uthor response')">
            <xsl:attribute name="id">dec-letter-reply-test-5</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="ancestor::sub-article/@article-type"/>
               <xsl:text/> paragraph contains what looks like pseudo-code - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="matches(.,'&lt;\s?/?\s?[a-z]*\s?/?\s?&gt;')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'&lt;\s?/?\s?[a-z]*\s?/?\s?&gt;')">
            <xsl:attribute name="id">dec-letter-reply-test-6</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reply-test-6</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="ancestor::sub-article/@article-type"/>
               <xsl:text/> paragraph contains what might be pseudo-code or tags which should likely be removed - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>

   <!--PATTERN dec-letter-front-tests-pattern-->


	  <!--RULE dec-letter-front-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub" priority="1000" mode="M55">
      <xsl:variable name="count" select="count(contrib-group)"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-id[@pub-id-type='doi']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-id[@pub-id-type='doi']) = 1">
               <xsl:attribute name="id">dec-letter-front-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article front-stub must contain article-id[@pub-id-type='doi'].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$count gt 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$count gt 0">
               <xsl:attribute name="id">dec-letter-front-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>decision letter front-stub must contain at least 1 contrib-group element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="$count gt 2">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$count gt 2">
            <xsl:attribute name="id">dec-letter-front-test-3</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>decision letter front-stub contains more than 2 contrib-group elements.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'The reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/')])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'The reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/')])">
            <xsl:attribute name="id">dec-letter-front-test-4</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-front-test-4</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviewing editor) anonymous? The text 'The reviewers have opted to remain anonymous' or 'The reviewer has opted to remain anonymous' is not present and there is no link to Review commons in the decision letter.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>

   <!--PATTERN dec-letter-editor-tests-pattern-->


	  <!--RULE dec-letter-editor-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]" priority="1000" mode="M56">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="count(contrib[@contrib-type='editor']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[@contrib-type='editor']) = 1">
               <xsl:attribute name="id">dec-letter-editor-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-1</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>First contrib-group in decision letter must contain 1 and only 1 editor (contrib[@contrib-type='editor']).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT warning-->
      <xsl:if test="contrib[not(@contrib-type) or @contrib-type!='editor']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contrib[not(@contrib-type) or @contrib-type!='editor']">
            <xsl:attribute name="id">dec-letter-editor-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>First contrib-group in decision letter contains a contrib which is not marked up as an editor (contrib[@contrib-type='editor']).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>

   <!--PATTERN dec-letter-editor-tests-2-pattern-->


	  <!--RULE dec-letter-editor-tests-2-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]/contrib[@contrib-type='editor']" priority="1000" mode="M57">
      <xsl:variable name="name" select="e:get-name(name[1])"/>
      <xsl:variable name="role" select="role[1]"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$role=('Reviewing Editor','Senior and Reviewing Editor')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$role=('Reviewing Editor','Senior and Reviewing Editor')">
               <xsl:attribute name="id">dec-letter-editor-test-3</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-editor-test-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Editor in decision letter front-stub must have the role 'Reviewing Editor' or 'Senior and Reviewing Editor'. <xsl:text/>
                  <xsl:value-of select="$name"/>
                  <xsl:text/> has '<xsl:text/>
                  <xsl:value-of select="$role"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>

   <!--PATTERN dec-letter-reviewer-tests-pattern-->


	  <!--RULE dec-letter-reviewer-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]" priority="1000" mode="M58">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(contrib[@contrib-type='reviewer']) gt 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[@contrib-type='reviewer']) gt 0">
               <xsl:attribute name="id">dec-letter-reviewer-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Second contrib-group in decision letter must contain a reviewer (contrib[@contrib-type='reviewer']).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="contrib[not(@contrib-type) or @contrib-type!='reviewer']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contrib[not(@contrib-type) or @contrib-type!='reviewer']">
            <xsl:attribute name="id">dec-letter-reviewer-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Second contrib-group in decision letter contains a contrib which is not marked up as a reviewer (contrib[@contrib-type='reviewer']).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="count(contrib[@contrib-type='reviewer']) gt 5">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[@contrib-type='reviewer']) gt 5">
            <xsl:attribute name="id">dec-letter-reviewer-test-6</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-6</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>

   <!--PATTERN dec-letter-reviewer-tests-2-pattern-->


	  <!--RULE dec-letter-reviewer-tests-2-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]/contrib[@contrib-type='reviewer']" priority="1000" mode="M59">
      <xsl:variable name="name" select="e:get-name(name[1])"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="role='Reviewer'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="role='Reviewer'">
               <xsl:attribute name="id">dec-letter-reviewer-test-3</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-reviewer-test-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Reviewer in decision letter front-stub must have the role 'Reviewer'. <xsl:text/>
                  <xsl:value-of select="$name"/>
                  <xsl:text/> has '<xsl:text/>
                  <xsl:value-of select="role"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>

   <!--PATTERN dec-letter-body-tests-pattern-->


	  <!--RULE dec-letter-body-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/body" priority="1000" mode="M60">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="child::*[1]/local-name() = 'boxed-text'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="child::*[1]/local-name() = 'boxed-text'">
               <xsl:attribute name="id">dec-letter-body-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>First child element in decision letter is not boxed-text. This is certainly incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>

   <!--PATTERN dec-letter-body-p-tests-pattern-->


	  <!--RULE dec-letter-body-p-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/body//p" priority="1000" mode="M61">

		<!--REPORT error-->
      <xsl:if test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])">
            <xsl:attribute name="id">dec-letter-body-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#dec-letter-body-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The text 'Review Commons' in '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>' must contain an embedded link pointing to https://www.reviewcommons.org/.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>

   <!--PATTERN decision-missing-table-tests-pattern-->


	  <!--RULE decision-missing-table-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']" priority="1000" mode="M62">

		<!--REPORT warning-->
      <xsl:if test="contains(.,'letter table') and not(descendant::table-wrap[label])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'letter table') and not(descendant::table-wrap[label])">
            <xsl:attribute name="id">decision-missing-table-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#decision-missing-table-test</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A decision letter table is referred to in the text, but there is no table in the decision letter with a label.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>

   <!--PATTERN reply-front-tests-pattern-->


	  <!--RULE reply-front-tests-->
   <xsl:template match="sub-article[@article-type='reply']/front-stub" priority="1000" mode="M63">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-id[@pub-id-type='doi']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-id[@pub-id-type='doi']) = 1">
               <xsl:attribute name="id">reply-front-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-front-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article front-stub must contain article-id[@pub-id-type='doi'].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>

   <!--PATTERN reply-body-tests-pattern-->


	  <!--RULE reply-body-tests-->
   <xsl:template match="sub-article[@article-type='reply']/body" priority="1000" mode="M64">

		<!--REPORT warning-->
      <xsl:if test="count(disp-quote[@content-type='editor-comment']) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(disp-quote[@content-type='editor-comment']) = 0">
            <xsl:attribute name="id">reply-body-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-body-test-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>author response doesn't contain a disp-quote. This is very likely to be incorrect. Please check the original file.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="count(p) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(p) = 0">
            <xsl:attribute name="id">reply-body-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-body-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>author response doesn't contain a p. This has to be incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>

   <!--PATTERN reply-disp-quote-tests-pattern-->


	  <!--RULE reply-disp-quote-tests-->
   <xsl:template match="sub-article[@article-type='reply']/body//disp-quote" priority="1000" mode="M65">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@content-type='editor-comment'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type='editor-comment'">
               <xsl:attribute name="id">reply-disp-quote-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-disp-quote-test-1</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>disp-quote in author reply does not have @content-type='editor-comment'. This is almost certainly incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>

   <!--PATTERN reply-missing-disp-quote-tests-pattern-->


	  <!--RULE reply-missing-disp-quote-tests-->
   <xsl:template match="sub-article[@article-type='reply']/body//p[not(ancestor::disp-quote)]" priority="1000" mode="M66">
      <xsl:variable name="free-text" select="replace(         normalize-space(string-join(for $x in self::*/text() return $x,''))         ,' ','')"/>

		    <!--REPORT warning-->
      <xsl:if test="(count(*)=1) and (child::italic) and ($free-text='')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(count(*)=1) and (child::italic) and ($free-text='')">
            <xsl:attribute name="id">reply-missing-disp-quote-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-disp-quote-test-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>para in author response is entirely in italics, but not in a display quote. Is this a quote which has been processed incorrectly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>

   <!--PATTERN reply-missing-disp-quote-tests-2-pattern-->


	  <!--RULE reply-missing-disp-quote-tests-2-->
   <xsl:template match="sub-article[@article-type='reply']//italic[not(ancestor::disp-quote)]" priority="1000" mode="M67">

		<!--REPORT warning-->
      <xsl:if test="string-length(.) ge 50">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) ge 50">
            <xsl:attribute name="id">reply-missing-disp-quote-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-disp-quote-test-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A long piece of text is in italics in an Author response paragraph. Should it be captured as a display quote in a separate paragraph? '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>' in '<xsl:text/>
               <xsl:value-of select="ancestor::*[local-name()='p'][1]"/>
               <xsl:text/>'</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>

   <!--PATTERN reply-missing-table-tests-pattern-->


	  <!--RULE reply-missing-table-tests-->
   <xsl:template match="sub-article[@article-type='reply']" priority="1000" mode="M68">

		<!--REPORT warning-->
      <xsl:if test="contains(.,'response table') and not(descendant::table-wrap[label])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'response table') and not(descendant::table-wrap[label])">
            <xsl:attribute name="id">reply-missing-table-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#reply-missing-table-test</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>An author response table is referred to in the text, but there is no table in the response with a label.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M68"/>
   <xsl:template match="@*|node()" priority="-2" mode="M68">
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>

   <!--PATTERN sub-article-ext-link-tests-pattern-->


	  <!--RULE sub-article-ext-link-tests-->
   <xsl:template match="sub-article//ext-link" priority="1000" mode="M69">

		<!--REPORT error-->
      <xsl:if test="contains(@xlink:href,'paperpile.com')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(@xlink:href,'paperpile.com')">
            <xsl:attribute name="id">paper-pile-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/decision-letters-and-author-responses#paper-pile-test</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>In the <xsl:text/>
               <xsl:value-of select="if (ancestor::sub-article[@article-type='reply']) then 'author response' else 'decision letter'"/>
               <xsl:text/> the text '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>' has an embedded hyperlink to <xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>. The hyperlink should be removed (but the text retained).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>

   <!--PATTERN feature-template-tests-pattern-->


	  <!--RULE feature-template-tests-->
   <xsl:template match="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]" priority="1000" mode="M70">
      <xsl:variable name="template" select="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
      <xsl:variable name="type" select="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>

		    <!--REPORT error-->
      <xsl:if test="($template = ('1','2','3')) and child::sub-article">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($template = ('1','2','3')) and child::sub-article">
            <xsl:attribute name="id">feature-template-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="$type"/>
               <xsl:text/> is a template <xsl:text/>
               <xsl:value-of select="$template"/>
               <xsl:text/> but it has a decision letter or author response, which cannot be correct, as only template 5s are allowed these.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="($template = '5') and not(@article-type='research-article')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($template = '5') and not(@article-type='research-article')">
            <xsl:attribute name="id">feature-template-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="$type"/>
               <xsl:text/> is a template <xsl:text/>
               <xsl:value-of select="$template"/>
               <xsl:text/> so the article element must have a @article-type="research-article". Instead the @article-type="<xsl:text/>
               <xsl:value-of select="@article-type"/>
               <xsl:text/>".</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
</xsl:stylesheet>