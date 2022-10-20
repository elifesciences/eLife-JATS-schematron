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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:is-prc" as="xs:boolean">
      <xsl:param name="elem" as="node()"/>
      <xsl:choose>
         <xsl:when test="$elem/name()='article'">
            <xsl:value-of select="e:is-prc-helper($elem)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="e:is-prc-helper($elem/ancestor::article[1])"/>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:is-prc-helper" as="xs:boolean">
      <xsl:param name="article" as="node()"/>
      <xsl:choose>
         <xsl:when test="$article//article-meta/custom-meta-group/custom-meta[meta-name='publishing-route']/meta-value='prc'">
            <xsl:value-of select="true()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="false()"/>
         </xsl:otherwise>
      </xsl:choose>
  </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-version" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-version-helper" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:titleCaseToken" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:titleCase" as="xs:string">
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
         <xsl:when test="$s = 'Expression of Concern'">
            <xsl:value-of select="'Expression of Concern:'"/>
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:stripDiacritics" as="xs:string">
      <xsl:param name="string" as="xs:string"/>
      <xsl:value-of select="replace(replace(replace(translate(normalize-unicode($string,'NFD'),'ƀȼđɇǥħɨıɉꝁłøɍŧɏƶ','bcdeghiijklortyz'),'[\p{M}’]',''),'æ','ae'),'ß','ss')"/>
  </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:ref-list-string" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:ref-list-string2" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-collab-or-surname" as="xs:string?">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:cite-name-text" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:citation-format1" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:citation-format2" as="xs:string">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:ref-cite-list">
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
         <xsl:when test="matches($s,'e\.\p{Zs}?faecalis')">
            <xsl:value-of select="'E. faecalis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'h\.\p{Zs}?sapiens')">
            <xsl:value-of select="'H. sapiens'"/>
         </xsl:when>
         <xsl:when test="matches($s,'homo\p{Zs}?sapiens')">
            <xsl:value-of select="'Homo sapiens'"/>
         </xsl:when>
         <xsl:when test="matches($s,'c\.\p{Zs}?trachomatis')">
            <xsl:value-of select="'C. trachomatis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'chlamydia\p{Zs}?trachomatis')">
            <xsl:value-of select="'Chlamydia trachomatis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'enterococcus\p{Zs}?faecalis')">
            <xsl:value-of select="'Enterococcus faecalis'"/>
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
         <xsl:when test="matches($s,'m\.\p{Zs}?trossulus')">
            <xsl:value-of select="'M. trossulus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'mytilus\p{Zs}?trossulus')">
            <xsl:value-of select="'Mytilus trossulus'"/>
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
         <xsl:when test="matches($s,'caulobacter\p{Zs}?crescentus')">
            <xsl:value-of select="'Caulobacter crescentus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'c\.\p{Zs}?crescentus')">
            <xsl:value-of select="'C. crescentus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'agrobacterium\p{Zs}?tumefaciens')">
            <xsl:value-of select="'Agrobacterium tumefaciens'"/>
         </xsl:when>
         <xsl:when test="matches($s,'a\.\p{Zs}?tumefaciens')">
            <xsl:value-of select="'A. tumefaciens'"/>
         </xsl:when>
         <xsl:when test="matches($s,'t\.\p{Zs}?gondii')">
            <xsl:value-of select="'T. gondii'"/>
         </xsl:when>
         <xsl:when test="matches($s,'toxoplasma\p{Zs}?gondii')">
            <xsl:value-of select="'Toxoplasma gondii'"/>
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
         <xsl:when test="matches($s,'yimenosaurus')">
            <xsl:value-of select="'Yimenosaurus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'lesothosaurus\p{Zs}?diagnosticus')">
            <xsl:value-of select="'Lesothosaurus diagnosticus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'l.\p{Zs}?diagnosticus')">
            <xsl:value-of select="'L. diagnosticus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'scelidosaurus\p{Zs}?harrisonii')">
            <xsl:value-of select="'Scelidosaurus harrisonii'"/>
         </xsl:when>
         <xsl:when test="matches($s,'s.\p{Zs}?harrisonii')">
            <xsl:value-of select="'S. harrisonii'"/>
         </xsl:when>
         <xsl:when test="matches($s,'haya\p{Zs}?griva')">
            <xsl:value-of select="'Haya griva'"/>
         </xsl:when>
         <xsl:when test="matches($s,'h.\p{Zs}?griva')">
            <xsl:value-of select="'H. griva'"/>
         </xsl:when>
         <xsl:when test="matches($s,'polacanthus\p{Zs}?foxii')">
            <xsl:value-of select="'Polacanthus foxii'"/>
         </xsl:when>
         <xsl:when test="matches($s,'p.\p{Zs}?foxii')">
            <xsl:value-of select="'P. foxii'"/>
         </xsl:when>
         <xsl:when test="matches($s,'scutellosaurus\p{Zs}?lawleri')">
            <xsl:value-of select="'Scutellosaurus lawleri'"/>
         </xsl:when>
         <xsl:when test="matches($s,'s.\p{Zs}?lawleri')">
            <xsl:value-of select="'S. lawleri'"/>
         </xsl:when>
         <xsl:when test="matches($s,'saichania\p{Zs}?chulsanensis')">
            <xsl:value-of select="'Saichania chulsanensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'s.\p{Zs}?chulsanensis')">
            <xsl:value-of select="'S. chulsanensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'gargoyleosaurus\p{Zs}?parkpinorum')">
            <xsl:value-of select="'Gargoyleosaurus parkpinorum'"/>
         </xsl:when>
         <xsl:when test="matches($s,'g.\p{Zs}?parkpinorum')">
            <xsl:value-of select="'G. parkpinorum'"/>
         </xsl:when>
         <xsl:when test="matches($s,'europelta\p{Zs}?carbonensis')">
            <xsl:value-of select="'Europelta carbonensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'e.\p{Zs}?carbonensis')">
            <xsl:value-of select="'E. carbonensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'stegosaurus\p{Zs}?stenops')">
            <xsl:value-of select="'Stegosaurus stenops'"/>
         </xsl:when>
         <xsl:when test="matches($s,'s.\p{Zs}?stenops')">
            <xsl:value-of select="'S. stenops'"/>
         </xsl:when>
         <xsl:when test="matches($s,'pinacosaurus\p{Zs}?grangeri')">
            <xsl:value-of select="'Pinacosaurus grangeri'"/>
         </xsl:when>
         <xsl:when test="matches($s,'p.\p{Zs}?grangeri')">
            <xsl:value-of select="'P. grangeri'"/>
         </xsl:when>
         <xsl:when test="matches($s,'tatisaurus\p{Zs}?oehleri')">
            <xsl:value-of select="'Tatisaurus oehleri'"/>
         </xsl:when>
         <xsl:when test="matches($s,'t.\p{Zs}?oehleri')">
            <xsl:value-of select="'T. oehleri'"/>
         </xsl:when>
         <xsl:when test="matches($s,'hungarosaurus\p{Zs}?tormai')">
            <xsl:value-of select="'Hungarosaurus tormai'"/>
         </xsl:when>
         <xsl:when test="matches($s,'h.\p{Zs}?tormai')">
            <xsl:value-of select="'H. tormai'"/>
         </xsl:when>
         <xsl:when test="matches($s,'lesothosaurus\p{Zs}?diagnosticus')">
            <xsl:value-of select="'Lesothosaurus diagnosticus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'l.\p{Zs}?diagnosticus')">
            <xsl:value-of select="'L. diagnosticus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'bienosaurus\p{Zs}?lufengensis')">
            <xsl:value-of select="'Bienosaurus lufengensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'b.\p{Zs}?lufengensis')">
            <xsl:value-of select="'B. lufengensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'fabrosaurus\p{Zs}?australis')">
            <xsl:value-of select="'Fabrosaurus australis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'f.\p{Zs}?australis')">
            <xsl:value-of select="'F. australis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'chinshakiangosaurus\p{Zs}?chunghoensis')">
            <xsl:value-of select="'Chinshakiangosaurus chunghoensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'c.\p{Zs}?chunghoensis')">
            <xsl:value-of select="'C. chunghoensis'"/>
         </xsl:when>
         <xsl:when test="matches($s,'euoplocephalus\p{Zs}?tutus')">
            <xsl:value-of select="'Euoplocephalus tutus'"/>
         </xsl:when>
         <xsl:when test="matches($s,'e.\p{Zs}?tutus')">
            <xsl:value-of select="'E. tutus'"/>
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-xrefs">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-copyright-holder">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-surname" as="text()">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:insight-box" as="element()">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:list-panels">
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:get-weekday" as="xs:integer?">
      <xsl:param name="date" as="xs:anyAtomicType?"/>
      <xsl:sequence select="       if (empty($date)) then ()       else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7       "/>
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
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">research-article-sub-article-pattern</xsl:attribute>
            <xsl:attribute name="name">research-article-sub-article-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ar-fig-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ar-fig-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-quote-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-quote-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dl-video-specific-pattern</xsl:attribute>
            <xsl:attribute name="name">dl-video-specific-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ar-video-specific-pattern</xsl:attribute>
            <xsl:attribute name="name">ar-video-specific-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rep-fig-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">rep-fig-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-fig-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-fig-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-eval-title-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-eval-title-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-title-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-title-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-title-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-title-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M66"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rep-fig-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">rep-fig-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M67"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rep-fig-sup-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">rep-fig-sup-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M68"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-formula-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-formula-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M69"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">mml-math-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">mml-math-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M70"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">resp-table-wrap-ids-pattern</xsl:attribute>
            <xsl:attribute name="name">resp-table-wrap-ids-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M71"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reply-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reply-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M72"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reply-content-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reply-content-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M73"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reply-content-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reply-content-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M74"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-eval-front-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-eval-front-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M75"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-eval-front-child-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-eval-front-child-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M76"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-eval-contrib-group-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-eval-contrib-group-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M77"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-eval-author-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-eval-author-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M78"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-eval-rel-obj-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-eval-rel-obj-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M79"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-front-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-front-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M80"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-editor-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-editor-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M81"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-editor-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-editor-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M82"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reviewer-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reviewer-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M83"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-reviewer-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-reviewer-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M84"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-body-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-body-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M85"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-body-p-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-body-p-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M86"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dec-letter-box-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">dec-letter-box-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M87"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">decision-missing-table-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">decision-missing-table-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M88"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-front-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-front-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M89"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-body-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-body-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M90"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-disp-quote-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-disp-quote-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M91"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-missing-disp-quote-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-missing-disp-quote-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M92"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-missing-disp-quote-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-missing-disp-quote-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M93"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">reply-missing-table-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">reply-missing-table-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M94"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sub-article-ext-link-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">sub-article-ext-link-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M95"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sub-article-ref-p-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">sub-article-ref-p-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M96"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-report-front-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-report-front-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M97"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sub-article-contrib-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">sub-article-contrib-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M98"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sub-article-role-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">sub-article-role-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M99"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-report-editor-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-report-editor-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M100"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-report-reviewer-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-report-reviewer-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M101"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">feature-template-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">feature-template-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M102"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">eLife Schematron</svrl:text>
   <xsl:param name="features-subj" select="('Feature Article', 'Insight', 'Editorial')"/>
   <xsl:param name="features-article-types" select="('article-commentary','editorial','discussion')"/>
   <xsl:param name="research-subj" select="('Research Article', 'Short Report', 'Tools and Resources', 'Research Advance', 'Registered Report', 'Replication Study', 'Research Communication', 'Correction', 'Retraction', 'Scientific Correspondence', 'Review Article')"/>
   <xsl:param name="notice-article-types" select="('correction','retraction','expression-of-concern')"/>
   <xsl:param name="notice-display-types" select="('Correction','Retraction','Expression of Concern')"/>
   <xsl:param name="allowed-article-types" select="('research-article','review-article',$features-article-types, $notice-article-types)"/>
   <xsl:param name="allowed-disp-subj" select="($research-subj, $features-subj)"/>
   <xsl:param name="MSAs" select="('Biochemistry and Chemical Biology', 'Cancer Biology', 'Cell Biology', 'Chromosomes and Gene Expression', 'Computational and Systems Biology', 'Developmental Biology', 'Ecology', 'Epidemiology and Global Health', 'Evolutionary Biology', 'Genetics and Genomics', 'Medicine', 'Immunology and Inflammation', 'Microbiology and Infectious Disease', 'Neuroscience', 'Physics of Living Systems', 'Plant Biology', 'Stem Cells and Regenerative Medicine', 'Structural Biology and Molecular Biophysics')"/>
   <xsl:param name="org-regex" select="'b\.\p{Zs}?subtilis|bacillus\p{Zs}?subtilis|d\.\p{Zs}?melanogaster|drosophila\p{Zs}?melanogaster|e\.\p{Zs}?coli|escherichia\p{Zs}?coli|s\.\p{Zs}?pombe|schizosaccharomyces\p{Zs}?pombe|s\.\p{Zs}?cerevisiae|saccharomyces\p{Zs}?cerevisiae|c\.\p{Zs}?elegans|caenorhabditis\p{Zs}?elegans|a\.\p{Zs}?thaliana|arabidopsis\p{Zs}?thaliana|m\.\p{Zs}?thermophila|myceliophthora\p{Zs}?thermophila|dictyostelium|p\.\p{Zs}?falciparum|plasmodium\p{Zs}?falciparum|s\.\p{Zs}?enterica|salmonella\p{Zs}?enterica|s\.\p{Zs}?pyogenes|streptococcus\p{Zs}?pyogenes|p\.\p{Zs}?dumerilii|platynereis\p{Zs}?dumerilii|p\.\p{Zs}?cynocephalus|papio\p{Zs}?cynocephalus|o\.\p{Zs}?fasciatus|oncopeltus\p{Zs}?fasciatus|n\.\p{Zs}?crassa|neurospora\p{Zs}?crassa|c\.\p{Zs}?intestinalis|ciona\p{Zs}?intestinalis|e\.\p{Zs}?cuniculi|encephalitozoon\p{Zs}?cuniculi|h\.\p{Zs}?salinarum|halobacterium\p{Zs}?salinarum|s\.\p{Zs}?solfataricus|sulfolobus\p{Zs}?solfataricus|s\.\p{Zs}?mediterranea|schmidtea\p{Zs}?mediterranea|s\.\p{Zs}?rosetta|salpingoeca\p{Zs}?rosetta|n\.\p{Zs}?vectensis|nematostella\p{Zs}?vectensis|s\.\p{Zs}?aureus|staphylococcus\p{Zs}?aureus|v\.\p{Zs}?cholerae|vibrio\p{Zs}?cholerae|t\.\p{Zs}?thermophila|tetrahymena\p{Zs}?thermophila|c\.\p{Zs}?reinhardtii|chlamydomonas\p{Zs}?reinhardtii|n\.\p{Zs}?attenuata|nicotiana\p{Zs}?attenuata|e\.\p{Zs}?carotovora|erwinia\p{Zs}?carotovora|e\.\p{Zs}?faecalis|h\.\p{Zs}?sapiens|homo\p{Zs}?sapiens|c\.\p{Zs}?trachomatis|chlamydia\p{Zs}?trachomatis|enterococcus\p{Zs}?faecalis|x\.\p{Zs}?laevis|xenopus\p{Zs}?laevis|x\.\p{Zs}?tropicalis|xenopus\p{Zs}?tropicalis|m\.\p{Zs}?musculus|mus\p{Zs}?musculus|d\.\p{Zs}?immigrans|drosophila\p{Zs}?immigrans|d\.\p{Zs}?subobscura|drosophila\p{Zs}?subobscura|d\.\p{Zs}?affinis|drosophila\p{Zs}?affinis|d\.\p{Zs}?obscura|drosophila\p{Zs}?obscura|f\.\p{Zs}?tularensis|francisella\p{Zs}?tularensis|p\.\p{Zs}?plantaginis|podosphaera\p{Zs}?plantaginis|p\.\p{Zs}?lanceolata|plantago\p{Zs}?lanceolata|m\.\p{Zs}?trossulus|mytilus\p{Zs}?trossulus|m\.\p{Zs}?edulis|mytilus\p{Zs}?edulis|m\.\p{Zs}?chilensis|mytilus\p{Zs}?chilensis|u\.\p{Zs}?maydis|ustilago\p{Zs}?maydis|p\.\p{Zs}?knowlesi|plasmodium\p{Zs}?knowlesi|p\.\p{Zs}?aeruginosa|pseudomonas\p{Zs}?aeruginosa|t\.\p{Zs}?brucei|trypanosoma\p{Zs}?brucei|caulobacter\p{Zs}?crescentus|c\.\p{Zs}?crescentus|agrobacterium\p{Zs}?tumefaciens|a\.\p{Zs}?tumefaciens|t\.\p{Zs}?gondii|toxoplasma\p{Zs}?gondii|d\.\p{Zs}?rerio|danio\p{Zs}?rerio|drosophila|yimenosaurus|lesothosaurus\p{Zs}?diagnosticus|l.\p{Zs}?diagnosticus|scelidosaurus\p{Zs}?harrisonii|s.\p{Zs}?harrisonii|haya\p{Zs}?griva|h.\p{Zs}?griva|polacanthus\p{Zs}?foxii|p.\p{Zs}?foxii|scutellosaurus\p{Zs}?lawleri|s.\p{Zs}?lawleri|saichania\p{Zs}?chulsanensis|s.\p{Zs}?chulsanensis|gargoyleosaurus\p{Zs}?parkpinorum|g.\p{Zs}?parkpinorum|europelta\p{Zs}?carbonensis|e.\p{Zs}?carbonensis|stegosaurus\p{Zs}?stenops|s.\p{Zs}?stenops|pinacosaurus\p{Zs}?grangeri|p.\p{Zs}?grangeri|tatisaurus\p{Zs}?oehleri|t.\p{Zs}?oehleri|hungarosaurus\p{Zs}?tormai|h.\p{Zs}?tormai|lesothosaurus\p{Zs}?diagnosticus|l.\p{Zs}?diagnosticus|bienosaurus\p{Zs}?lufengensis|b.\p{Zs}?lufengensis|fabrosaurus\p{Zs}?australis|f.\p{Zs}?australis|chinshakiangosaurus\p{Zs}?chunghoensis|c.\p{Zs}?chunghoensis|euoplocephalus\p{Zs}?tutus|e.\p{Zs}?tutus|xenopus'"/>
   <xsl:param name="sec-title-regex" select="string-join(     for $x in tokenize($org-regex,'\|')     return concat('^',$x,'$')     ,'|')"/>
   <xsl:param name="latin-regex" select="'in\p{Zs}+vitro|ex\p{Zs}+vitro|in\p{Zs}+vivo|ex\p{Zs}+vivo|a\p{Zs}+priori|a\p{Zs}+posteriori|de\p{Zs}+novo|in\p{Zs}+utero|in\p{Zs}+natura|in\p{Zs}+situ|in\p{Zs}+planta|in\p{Zs}+cellulo|rete\p{Zs}+mirabile|nomen\p{Zs}+novum| sensu |ad\p{Zs}+libitum|in\p{Zs}+ovo'"/>

   <!--PATTERN research-article-pattern-->


	  <!--RULE research-article-->
   <xsl:template match="article[@article-type='research-article']" priority="1000" mode="M56">
      <xsl:variable name="disp-channel" select="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>
      <xsl:variable name="is-prc" select="e:is-prc(.)"/>

		    <!--REPORT warning-->
      <xsl:if test="if ($is-prc) then ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='referee-report'])      else ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="if ($is-prc) then ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='referee-report']) else ($disp-channel != 'Scientific Correspondence') and not(sub-article[@article-type='decision-letter'])">
            <xsl:attribute name="id">test-r-article-d-letter</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="if ($is-prc) then 'Public reviews and recomendations for the authors' else 'A decision letter'"/>
               <xsl:text/>should almost always be present for research articles. This one doesn't have one. Check that this is correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="$disp-channel = 'Feature Article' and not(sub-article[@article-type='decision-letter'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$disp-channel = 'Feature Article' and not(sub-article[@article-type='decision-letter'])">
            <xsl:attribute name="id">final-test-r-article-d-letter-feat</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/feature-content-alikl8qp#final-test-r-article-d-letter-feat</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A decision letter should be present for research articles. Feature template 5s almost always have a decision letter, but this one does not. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="$disp-channel != 'Scientific Correspondence' and not(sub-article[@article-type=('reply','author-comment')])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$disp-channel != 'Scientific Correspondence' and not(sub-article[@article-type=('reply','author-comment')])">
            <xsl:attribute name="id">test-r-article-a-reply</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author response should usually be present for research articles, but this one does not have one. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>

   <!--PATTERN research-article-sub-article-pattern-->


	  <!--RULE research-article-sub-article-->
   <xsl:template match="article[@article-type='research-article' and sub-article]" priority="1000" mode="M57">
      <xsl:variable name="disp-channel" select="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>

		    <!--REPORT error-->
      <xsl:if test="$disp-channel != 'Scientific Correspondence' and not(sub-article[not(@article-type=('reply','author-comment'))])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$disp-channel != 'Scientific Correspondence' and not(sub-article[not(@article-type=('reply','author-comment'))])">
            <xsl:attribute name="id">r-article-sub-articles</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="$disp-channel"/>
               <xsl:text/> type articles cannot have only an Author response. The following combinations of peer review-material are permitted: Editor's evaluation, Decision letter, and Author response; Decision letter, and Author response; Editor's evaluation and Decision letter; Editor's evaluation and Author response; or Decision letter.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>

   <!--PATTERN ar-fig-tests-pattern-->


	  <!--RULE ar-fig-tests-->
   <xsl:template match="fig[ancestor::sub-article[@article-type='reply']]" priority="1000" mode="M58">
      <xsl:variable name="article-type" select="ancestor::article/@article-type"/>
      <xsl:variable name="count" select="count(ancestor::body//fig)"/>
      <xsl:variable name="pos" select="$count - count(following::fig)"/>
      <xsl:variable name="no" select="substring-after(@id,'fig')"/>

		    <!--REPORT error-->
      <xsl:if test="if ($article-type = ($features-article-types,$notice-article-types)) then ()         else not(label)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="if ($article-type = ($features-article-types,$notice-article-types)) then () else not(label)">
            <xsl:attribute name="id">ar-fig-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#ar-fig-test-2</xsl:attribute>
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
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#pre-ar-fig-test-3</xsl:attribute>
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
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#pre-ar-fig-position-test</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>

   <!--PATTERN disp-quote-tests-pattern-->


	  <!--RULE disp-quote-tests-->
   <xsl:template match="disp-quote" priority="1000" mode="M59">
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
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>

   <!--PATTERN dl-video-specific-pattern-->


	  <!--RULE dl-video-specific-->
   <xsl:template match="sub-article[@article-type=('decision-letter','referee-report')]/body//media[@mimetype='video']" priority="1000" mode="M60">
      <xsl:variable name="count" select="count(ancestor::body//media[@mimetype='video'])"/>
      <xsl:variable name="pos" select="$count - count(following::media[@mimetype='video' and ancestor::sub-article/@article-type=('decision-letter','referee-report')])"/>
      <xsl:variable name="no" select="substring-after(@id,'video')"/>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$no = string($pos)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$no = string($pos)">
               <xsl:attribute name="id">pre-dl-video-position-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="label"/>
                  <xsl:text/> does not appear in sequence which is likely incorrect. Relative to the other DL videos it is placed in position <xsl:text/>
                  <xsl:value-of select="$pos"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>

   <!--PATTERN ar-video-specific-pattern-->


	  <!--RULE ar-video-specific-->
   <xsl:template match="sub-article[@article-type=('reply','author-comment')]/body//media[@mimetype='video']" priority="1000" mode="M61">
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
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>

   <!--PATTERN rep-fig-tests-pattern-->


	  <!--RULE rep-fig-tests-->
   <xsl:template match="sub-article[@article-type='reply']//fig" priority="1000" mode="M62">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="label"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="label">
               <xsl:attribute name="id">resp-fig-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-test-2</xsl:attribute>
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
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#reply-fig-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>fig label in author response must be in the format 'Author response image 1.', or 'Chemical Structure 1.', or 'Scheme 1.'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>

   <!--PATTERN dec-fig-tests-pattern-->


	  <!--RULE dec-fig-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']//fig" priority="1000" mode="M63">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="label"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="label">
               <xsl:attribute name="id">dec-fig-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#dec-fig-test-1</xsl:attribute>
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
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#dec-fig-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>fig label in author response must be in the format 'Decision letter image 1.'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>

   <!--PATTERN ed-eval-title-tests-pattern-->


	  <!--RULE ed-eval-title-tests-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/title-group" priority="1000" mode="M64">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-title = (&quot;Editor's evaluation&quot;,'eLife assessment')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-title = (&quot;Editor's evaluation&quot;,'eLife assessment')">
               <xsl:attribute name="id">ed-eval-title-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A sub-article[@article-type='editor-report'] must have the title "eLife assessment" or "Editor's evaluation". Currently it is <xsl:text/>
                  <xsl:value-of select="article-title"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>

   <!--PATTERN dec-letter-title-tests-pattern-->


	  <!--RULE dec-letter-title-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/title-group" priority="1000" mode="M65">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-title = 'Decision letter'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-title = 'Decision letter'">
               <xsl:attribute name="id">dec-letter-title-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-title-test</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>

   <!--PATTERN reply-title-tests-pattern-->


	  <!--RULE reply-title-tests-->
   <xsl:template match="sub-article[@article-type='reply']/front-stub/title-group" priority="1000" mode="M66">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-title = 'Author response'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-title = 'Author response'">
               <xsl:attribute name="id">reply-title-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-title-test</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>

   <!--PATTERN rep-fig-ids-pattern-->


	  <!--RULE rep-fig-ids-->
   <xsl:template match="sub-article//fig[not(@specific-use='child-fig')]" priority="1000" mode="M67">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@id,'^respfig[0-9]{1,3}$|^sa[0-9]fig[0-9]{1,3}$')">
               <xsl:attribute name="id">resp-fig-id-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-id-test</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>

   <!--PATTERN rep-fig-sup-ids-pattern-->


	  <!--RULE rep-fig-sup-ids-->
   <xsl:template match="sub-article//fig[@specific-use='child-fig']" priority="1000" mode="M68">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@id,'^respfig[0-9]{1,3}s[0-9]{1,3}$|^sa[0-9]{1}fig[0-9]{1,3}s[0-9]{1,3}$')">
               <xsl:attribute name="id">resp-fig-sup-id-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/figures-and-figure-supplements-8gb4whlr#resp-fig-sup-id-test</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M68"/>
   <xsl:template match="@*|node()" priority="-2" mode="M68">
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>

   <!--PATTERN disp-formula-ids-pattern-->


	  <!--RULE disp-formula-ids-->
   <xsl:template match="disp-formula" priority="1000" mode="M69">

		<!--REPORT error-->
      <xsl:if test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]equ[0-9]{1,9}$|^equ[0-9]{1,9}$'))">
            <xsl:attribute name="id">sub-disp-formula-id-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/maths-0gfptlyl#sub-disp-formula-id-test</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>disp-formula @id must be in the format 'sa0equ0' when in a sub-article.  <xsl:text/>
               <xsl:value-of select="@id"/>
               <xsl:text/> does not conform to this.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>

   <!--PATTERN mml-math-ids-pattern-->


	  <!--RULE mml-math-ids-->
   <xsl:template match="disp-formula/mml:math" priority="1000" mode="M70">

		<!--REPORT error-->
      <xsl:if test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(ancestor::sub-article) and not(matches(@id,'^sa[0-9]m[0-9]{1,9}$|^m[0-9]{1,9}$'))">
            <xsl:attribute name="id">sub-mml-math-id-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/maths-0gfptlyl#sub-mml-math-id-test</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>mml:math @id in disp-formula must be in the format 'sa0m0'.  <xsl:text/>
               <xsl:value-of select="@id"/>
               <xsl:text/> does not conform to this.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>

   <!--PATTERN resp-table-wrap-ids-pattern-->


	  <!--RULE resp-table-wrap-ids-->
   <xsl:template match="sub-article//table-wrap" priority="1000" mode="M71">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$')         else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="if (label) then matches(@id, '^resptable[0-9]{1,3}$|^sa[0-9]table[0-9]{1,3}$') else matches(@id, '^respinlinetable[0-9]{1,3}$||^sa[0-9]inlinetable[0-9]{1,3}$')">
               <xsl:attribute name="id">resp-table-wrap-id-test</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/tables-3nehcouh#resp-table-wrap-id-test</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>table-wrap @id in a sub-article must be in the format 'resptable0' or 'sa0table0' if it has a label, or in the format 'respinlinetable0' or 'sa0inlinetable0' if it does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M71"/>
   <xsl:template match="@*|node()" priority="-2" mode="M71">
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>

   <!--PATTERN dec-letter-reply-tests-pattern-->


	  <!--RULE dec-letter-reply-tests-->
   <xsl:template match="article/sub-article" priority="1000" mode="M72">
      <xsl:variable name="is-prc" select="e:is-prc(.)"/>
      <xsl:variable name="sub-article-count" select="count(parent::article/sub-article)"/>
      <xsl:variable name="id-convention" select="if (@article-type='editor-report') then 'sa0'         else if (@article-type=('reply','author-comment')) then ('sa'||$sub-article-count - 1)         else ('sa'||count(preceding-sibling::sub-article))"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@article-type=('editor-report','referee-report','author-comment','decision-letter','reply')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@article-type=('editor-report','referee-report','author-comment','decision-letter','reply')">
               <xsl:attribute name="id">dec-letter-reply-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reply-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article must must have an article-type which is equal to one of the following values: 'editor-report','decision-letter', or 'reply'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@id = $id-convention"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@id = $id-convention">
               <xsl:attribute name="id">dec-letter-reply-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reply-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article id is <xsl:text/>
                  <xsl:value-of select="@id"/>
                  <xsl:text/> when based on it's article-type and position it should be <xsl:text/>
                  <xsl:value-of select="$id-convention"/>
                  <xsl:text/>.</svrl:text>
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
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reply-test-3</xsl:attribute>
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
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reply-test-4</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article must contain one and only one body.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="not($is-prc) and @article-type='referee-report'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-prc) and @article-type='referee-report'">
            <xsl:attribute name="id">sub-article-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>'<xsl:text/>
               <xsl:value-of select="@article-type"/>
               <xsl:text/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'decision-letter'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="not($is-prc) and @article-type='author-comment'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-prc) and @article-type='author-comment'">
            <xsl:attribute name="id">sub-article-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>'<xsl:text/>
               <xsl:value-of select="@article-type"/>
               <xsl:text/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'response'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="$is-prc and @article-type='decision-letter'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-prc and @article-type='decision-letter'">
            <xsl:attribute name="id">sub-article-3</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>'<xsl:text/>
               <xsl:value-of select="@article-type"/>
               <xsl:text/>' is not permitted as the article-type for a sub-article in PRC articles. Provided this is in fact a PRC article, the article-type should be 'referee-report'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="$is-prc and @article-type='reply'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-prc and @article-type='reply'">
            <xsl:attribute name="id">sub-article-4</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>'<xsl:text/>
               <xsl:value-of select="@article-type"/>
               <xsl:text/>' is not permitted as the article-type for a sub-article in a non-PRC article. Provided this is in fact a non-PRC article, the article-type should be 'author-comment'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M72"/>
   <xsl:template match="@*|node()" priority="-2" mode="M72">
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>

   <!--PATTERN dec-letter-reply-content-tests-pattern-->


	  <!--RULE dec-letter-reply-content-tests-->
   <xsl:template match="article/sub-article//p" priority="1000" mode="M73">

		<!--REPORT error-->
      <xsl:if test="matches(.,'&lt;[/]?[Aa]uthor response')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'&lt;[/]?[Aa]uthor response')">
            <xsl:attribute name="id">dec-letter-reply-test-5</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reply-test-5</xsl:attribute>
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
      <xsl:if test="matches(.,'&lt;\p{Zs}?/?\p{Zs}?[a-z]*\p{Zs}?/?\p{Zs}?&gt;')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'&lt;\p{Zs}?/?\p{Zs}?[a-z]*\p{Zs}?/?\p{Zs}?&gt;')">
            <xsl:attribute name="id">dec-letter-reply-test-6</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reply-test-6</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M73"/>
   <xsl:template match="@*|node()" priority="-2" mode="M73">
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>

   <!--PATTERN dec-letter-reply-content-tests-2-pattern-->


	  <!--RULE dec-letter-reply-content-tests-2-->
   <xsl:template match="article/sub-article//p[not(ancestor::disp-quote)]" priority="1000" mode="M74">
      <xsl:variable name="regex" select="'\p{Zs}([Oo]ffensive|[Oo]ffended|[Uu]nproff?essional|[Rr]ude|[Cc]onflict\p{Zs}[Oo]f\p{Zs}[Ii]nterest|([Aa]re|[Aa]m)\p{Zs}[Ss]hocked|[Ss]trongly\p{Zs}[Dd]isagree)[^\p{L}]'"/>

		    <!--REPORT warning-->
      <xsl:if test="matches(.,$regex)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,$regex)">
            <xsl:attribute name="id">dec-letter-reply-test-7</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reply-test-7</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="ancestor::sub-article/@article-type"/>
               <xsl:text/> paragraph contains what might be inflammatory or offensive language. eLife: please check it to see if it is language that should be removed. This paragraph was flagged because of the phrase(s) <xsl:text/>
               <xsl:value-of select="string-join(tokenize(.,'\p{Zs}')[matches(.,concat('^',substring-before(substring-after($regex,'\p{Zs}'),'[^\p{L}]')))],'; ')"/>
               <xsl:text/> in <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>

   <!--PATTERN ed-eval-front-tests-pattern-->


	  <!--RULE ed-eval-front-tests-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub" priority="1000" mode="M75">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-id[@pub-id-type='doi']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-id[@pub-id-type='doi']) = 1">
               <xsl:attribute name="id">ed-eval-front-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
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
         <xsl:when test="count(contrib-group) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib-group) = 1">
               <xsl:attribute name="id">ed-eval-front-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>editor evaluation front-stub must contain 1 (and only 1) contrib-group element. This one has <xsl:text/>
                  <xsl:value-of select="count(contrib-group)"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="count(related-object) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(related-object) gt 1">
            <xsl:attribute name="id">ed-eval-front-test-3</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>editor evaluation front-stub must contain 1 or 0 related-object elements. This one has <xsl:text/>
               <xsl:value-of select="count(related-object)"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>

   <!--PATTERN ed-eval-front-child-tests-pattern-->


	  <!--RULE ed-eval-front-child-tests-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/*" priority="1000" mode="M76">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name()=('article-id','title-group','contrib-group','related-object')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()=('article-id','title-group','contrib-group','related-object')">
               <xsl:attribute name="id">ed-eval-front-child-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element is not allowed in the front-stub for an Editor's evaluation. Only the following elements are permitted: article-id, title-group, contrib-group, related-object.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>

   <!--PATTERN ed-eval-contrib-group-tests-pattern-->


	  <!--RULE ed-eval-contrib-group-tests-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/contrib-group" priority="1000" mode="M77">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(contrib[@contrib-type='author']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[@contrib-type='author']) = 1">
               <xsl:attribute name="id">ed-eval-contrib-group-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>editor evaluation contrib-group must contain 1 contrib[@contrib-type='author'].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>

   <!--PATTERN ed-eval-author-tests-pattern-->


	  <!--RULE ed-eval-author-tests-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/contrib-group/contrib[@contrib-type='author' and name]" priority="1000" mode="M78">
      <xsl:variable name="rev-ed-name" select="e:get-name(ancestor::article//article-meta/contrib-group[@content-type='section'][1]/contrib[@contrib-type='editor'][1]/name[1])"/>
      <xsl:variable name="name" select="e:get-name(name[1])"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$name = $rev-ed-name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$name = $rev-ed-name">
               <xsl:attribute name="id">ed-eval-author-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The author of the editor evaluation must be the same as the Reviewing editor for the article. The Reviewing editor is <xsl:text/>
                  <xsl:value-of select="$rev-ed-name"/>
                  <xsl:text/>, but the editor evaluation author is <xsl:text/>
                  <xsl:value-of select="$name"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>

   <!--PATTERN ed-eval-rel-obj-tests-pattern-->


	  <!--RULE ed-eval-rel-obj-tests-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/related-object" priority="1000" mode="M79">
      <xsl:variable name="event-preprint-doi" select="for $x in ancestor::article//article-meta/pub-history/event[1]/self-uri[@content-type='preprint'][1]/@xlink:href                                         return substring-after($x,'.org/')"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@id,'^sa0ro\d$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@id,'^sa0ro\d$')">
               <xsl:attribute name="id">ed-eval-rel-obj-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-object in editor's evaluation must have an id in the format sa0ro1. <xsl:text/>
                  <xsl:value-of select="@id"/>
                  <xsl:text/> does not meet this convention.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@object-id-type='id'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@object-id-type='id'">
               <xsl:attribute name="id">ed-eval-rel-obj-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-object in editor's evaluation must have an object-id-type="id" attribute.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@link-type='continued-by'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@link-type='continued-by'">
               <xsl:attribute name="id">ed-eval-rel-obj-test-3</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-object in editor's evaluation must have a link-type="continued-by" attribute.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@object-id,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@object-id,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')">
               <xsl:attribute name="id">ed-eval-rel-obj-test-4</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-object in editor's evaluation must have an object-id attribute which is a doi. '<xsl:text/>
                  <xsl:value-of select="@object-id"/>
                  <xsl:text/>' is not a valid doi.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@object-id = $event-preprint-doi"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@object-id = $event-preprint-doi">
               <xsl:attribute name="id">ed-eval-rel-obj-test-5</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-object in editor's evaluation must have an object-id attribute whose value is the same as the preprint doi in the article's pub-history. object-id '<xsl:text/>
                  <xsl:value-of select="@object-id"/>
                  <xsl:text/>' is not the same as the preprint doi in the event history, '<xsl:text/>
                  <xsl:value-of select="$event-preprint-doi"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href = concat('https://sciety.org/articles/activity/',@object-id)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@xlink:href = concat('https://sciety.org/articles/activity/',@object-id)">
               <xsl:attribute name="id">ed-eval-rel-obj-test-6</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the object-id attribute value (which must be a doi). '<xsl:text/>
                  <xsl:value-of select="@xlink:href"/>
                  <xsl:text/>' is not equal to <xsl:text/>
                  <xsl:value-of select="concat('https://sciety.org/articles/activity/',@object-id)"/>
                  <xsl:text/>. Which is correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href = concat('https://sciety.org/articles/activity/',$event-preprint-doi)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@xlink:href = concat('https://sciety.org/articles/activity/',$event-preprint-doi)">
               <xsl:attribute name="id">ed-eval-rel-obj-test-7</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-object in editor's evaluation must have an xlink:href attribute whose value is 'https://sciety.org/articles/activity/' followed by the preprint doi in the article's pub-history. xlink:href '<xsl:text/>
                  <xsl:value-of select="@xlink:href"/>
                  <xsl:text/>' is not the same as '<xsl:text/>
                  <xsl:value-of select="concat('https://sciety.org/articles/activity/',$event-preprint-doi)"/>
                  <xsl:text/>'. Which is correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>

   <!--PATTERN dec-letter-front-tests-pattern-->


	  <!--RULE dec-letter-front-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub" priority="1000" mode="M80">
      <xsl:variable name="count" select="count(contrib-group)"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-id[@pub-id-type='doi']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-id[@pub-id-type='doi']) = 1">
               <xsl:attribute name="id">dec-letter-front-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-front-test-1</xsl:attribute>
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
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-front-test-2</xsl:attribute>
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
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-front-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>decision letter front-stub contains more than 2 contrib-group elements.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT warning-->
      <xsl:if test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'(All|The) reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/|doi.org/10.24072/pci.evolbiol')])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($count = 1) and not(matches(parent::sub-article[1]/body[1],'(All|The) reviewers have opted to remain anonymous|The reviewer has opted to remain anonymous')) and not(parent::sub-article[1]/body[1]//ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/|doi.org/10.24072/pci.evolbiol')])">
            <xsl:attribute name="id">dec-letter-front-test-4</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-front-test-4</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>decision letter front-stub has only 1 contrib-group element. Is this correct? i.e. were all of the reviewers (aside from the reviewing editor) anonymous? The text 'The reviewers have opted to remain anonymous' or 'The reviewer has opted to remain anonymous' is not present and there is no link to Review commons or a Peer Community in Evolutionary Biology doi in the decision letter.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>

   <!--PATTERN dec-letter-editor-tests-pattern-->


	  <!--RULE dec-letter-editor-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]" priority="1000" mode="M81">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="count(contrib[@contrib-type='editor']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[@contrib-type='editor']) = 1">
               <xsl:attribute name="id">dec-letter-editor-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-editor-test-1</xsl:attribute>
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
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-editor-test-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>First contrib-group in decision letter contains a contrib which is not marked up as an editor (contrib[@contrib-type='editor']).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M81"/>
   <xsl:template match="@*|node()" priority="-2" mode="M81">
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>

   <!--PATTERN dec-letter-editor-tests-2-pattern-->


	  <!--RULE dec-letter-editor-tests-2-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[1]/contrib[@contrib-type='editor']" priority="1000" mode="M82">
      <xsl:variable name="name" select="e:get-name(name[1])"/>
      <xsl:variable name="role" select="role[1]"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$role=('Reviewing Editor','Senior and Reviewing Editor')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$role=('Reviewing Editor','Senior and Reviewing Editor')">
               <xsl:attribute name="id">dec-letter-editor-test-3</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-editor-test-3</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M82"/>
   <xsl:template match="@*|node()" priority="-2" mode="M82">
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>

   <!--PATTERN dec-letter-reviewer-tests-pattern-->


	  <!--RULE dec-letter-reviewer-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]" priority="1000" mode="M83">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(contrib[@contrib-type='reviewer']) gt 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[@contrib-type='reviewer']) gt 0">
               <xsl:attribute name="id">dec-letter-reviewer-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reviewer-test-1</xsl:attribute>
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
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reviewer-test-2</xsl:attribute>
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
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reviewer-test-6</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M83"/>
   <xsl:template match="@*|node()" priority="-2" mode="M83">
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>

   <!--PATTERN dec-letter-reviewer-tests-2-pattern-->


	  <!--RULE dec-letter-reviewer-tests-2-->
   <xsl:template match="sub-article[@article-type='decision-letter']/front-stub/contrib-group[2]/contrib[@contrib-type='reviewer']" priority="1000" mode="M84">
      <xsl:variable name="name" select="e:get-name(name[1])"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="role='Reviewer'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="role='Reviewer'">
               <xsl:attribute name="id">dec-letter-reviewer-test-3</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-reviewer-test-3</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M84"/>
   <xsl:template match="@*|node()" priority="-2" mode="M84">
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>

   <!--PATTERN dec-letter-body-tests-pattern-->


	  <!--RULE dec-letter-body-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/body" priority="1000" mode="M85">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="child::*[1]/local-name() = 'boxed-text'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="child::*[1]/local-name() = 'boxed-text'">
               <xsl:attribute name="id">dec-letter-body-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-body-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>First child element in decision letter is not boxed-text. This is certainly incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M85"/>
   <xsl:template match="@*|node()" priority="-2" mode="M85">
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>

   <!--PATTERN dec-letter-body-p-tests-pattern-->


	  <!--RULE dec-letter-body-p-tests-->
   <xsl:template match="sub-article[@article-type=('decision-letter','referee-report')]/body//p" priority="1000" mode="M86">

		<!--REPORT error-->
      <xsl:if test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(lower-case(.),'this paper was reviewed by review commons') and not(child::ext-link[matches(@xlink:href,'http[s]?://www.reviewcommons.org/') and (lower-case(.)='review commons')])">
            <xsl:attribute name="id">dec-letter-body-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-body-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The text 'Review Commons' in '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>' must contain an embedded link pointing to https://www.reviewcommons.org/.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="contains(lower-case(.),'reviewed and recommended by peer community in evolutionary biology') and not(child::ext-link[matches(@xlink:href,'doi.org/10.24072/pci.evolbiol')])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(lower-case(.),'reviewed and recommended by peer community in evolutionary biology') and not(child::ext-link[matches(@xlink:href,'doi.org/10.24072/pci.evolbiol')])">
            <xsl:attribute name="id">dec-letter-body-test-3</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-body-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The decision letter indicates that this article was reviewed by PCI evol bio, but there is no doi link with the prefix '10.24072/pci.evolbiol' which must be incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M86"/>
   <xsl:template match="@*|node()" priority="-2" mode="M86">
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>

   <!--PATTERN dec-letter-box-tests-pattern-->


	  <!--RULE dec-letter-box-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']/body/boxed-text[1]" priority="1000" mode="M87">
      <xsl:variable name="permitted-text-1" select="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below.$'"/>
      <xsl:variable name="permitted-text-2" select="'^Our editorial process produces two outputs: \(?i\) public reviews designed to be posted alongside the preprint for the benefit of readers; \(?ii\) feedback on the manuscript for the authors, including requests for revisions, shown below. We also include an acceptance summary that explains what the editors found interesting or important about the work.$'"/>
      <xsl:variable name="permitted-text-3" select="'^In the interests of transparency, eLife publishes the most substantive revision requests and the accompanying author responses.$'"/>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="matches(.,concat($permitted-text-1,'|',$permitted-text-2,'|',$permitted-text-3))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2,'|',$permitted-text-3))">
               <xsl:attribute name="id">dec-letter-box-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-box-test-1</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The text at the top of the decision letter is not correct - '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'. It has to be one of the three paragraphs which are permitted (see the GitBook page for these paragraphs).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[contains(@xlink:href,'sciety.org/') and .='public reviews'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[contains(@xlink:href,'sciety.org/') and .='public reviews'])">
            <xsl:attribute name="id">dec-letter-box-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-box-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>At the top of the decision letter, the text 'public reviews' must contain an embedded link to Sciety where the public review for this article's preprint is located.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[.='the preprint'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,concat($permitted-text-1,'|',$permitted-text-2)) and not(descendant::ext-link[.='the preprint'])">
            <xsl:attribute name="id">dec-letter-box-test-3</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-box-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>At the top of the decision letter, the text 'the preprint' must contain an embedded link to this article's preprint.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M87"/>
   <xsl:template match="@*|node()" priority="-2" mode="M87">
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>

   <!--PATTERN decision-missing-table-tests-pattern-->


	  <!--RULE decision-missing-table-tests-->
   <xsl:template match="sub-article[@article-type='decision-letter']" priority="1000" mode="M88">

		<!--REPORT warning-->
      <xsl:if test="contains(.,'letter table') and not(descendant::table-wrap[label])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'letter table') and not(descendant::table-wrap[label])">
            <xsl:attribute name="id">decision-missing-table-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#decision-missing-table-test</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A decision letter table is referred to in the text, but there is no table in the decision letter with a label.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M88"/>
   <xsl:template match="@*|node()" priority="-2" mode="M88">
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>

   <!--PATTERN reply-front-tests-pattern-->


	  <!--RULE reply-front-tests-->
   <xsl:template match="sub-article[@article-type='reply']/front-stub" priority="1000" mode="M89">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-id[@pub-id-type='doi']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-id[@pub-id-type='doi']) = 1">
               <xsl:attribute name="id">reply-front-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-front-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article front-stub must contain article-id[@pub-id-type='doi'].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M89"/>
   <xsl:template match="@*|node()" priority="-2" mode="M89">
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>

   <!--PATTERN reply-body-tests-pattern-->


	  <!--RULE reply-body-tests-->
   <xsl:template match="sub-article[@article-type='reply']/body" priority="1000" mode="M90">

		<!--REPORT warning-->
      <xsl:if test="count(disp-quote[@content-type='editor-comment']) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(disp-quote[@content-type='editor-comment']) = 0">
            <xsl:attribute name="id">reply-body-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-body-test-1</xsl:attribute>
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
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-body-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>author response doesn't contain a p. This has to be incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M90"/>
   <xsl:template match="@*|node()" priority="-2" mode="M90">
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>

   <!--PATTERN reply-disp-quote-tests-pattern-->


	  <!--RULE reply-disp-quote-tests-->
   <xsl:template match="sub-article[@article-type='reply']/body//disp-quote" priority="1000" mode="M91">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@content-type='editor-comment'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type='editor-comment'">
               <xsl:attribute name="id">reply-disp-quote-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-disp-quote-test-1</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>disp-quote in author reply does not have @content-type='editor-comment'. This is almost certainly incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M91"/>
   <xsl:template match="@*|node()" priority="-2" mode="M91">
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>

   <!--PATTERN reply-missing-disp-quote-tests-pattern-->


	  <!--RULE reply-missing-disp-quote-tests-->
   <xsl:template match="sub-article[@article-type='reply']/body//p[not(ancestor::disp-quote)]" priority="1000" mode="M92">
      <xsl:variable name="free-text" select="replace(         normalize-space(string-join(for $x in self::*/text() return $x,''))         ,' ','')"/>

		    <!--REPORT warning-->
      <xsl:if test="(count(*)=1) and (child::italic) and ($free-text='')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(count(*)=1) and (child::italic) and ($free-text='')">
            <xsl:attribute name="id">reply-missing-disp-quote-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-missing-disp-quote-test-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>para in author response is entirely in italics, but not in a display quote. Is this a quote which has been processed incorrectly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M92"/>
   <xsl:template match="@*|node()" priority="-2" mode="M92">
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>

   <!--PATTERN reply-missing-disp-quote-tests-2-pattern-->


	  <!--RULE reply-missing-disp-quote-tests-2-->
   <xsl:template match="sub-article[@article-type='reply']//italic[not(ancestor::disp-quote)]" priority="1000" mode="M93">

		<!--REPORT warning-->
      <xsl:if test="string-length(.) ge 50">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) ge 50">
            <xsl:attribute name="id">reply-missing-disp-quote-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-missing-disp-quote-test-2</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M93"/>
   <xsl:template match="@*|node()" priority="-2" mode="M93">
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>

   <!--PATTERN reply-missing-table-tests-pattern-->


	  <!--RULE reply-missing-table-tests-->
   <xsl:template match="sub-article[@article-type='reply']" priority="1000" mode="M94">

		<!--REPORT warning-->
      <xsl:if test="contains(.,'response table') and not(descendant::table-wrap[label])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'response table') and not(descendant::table-wrap[label])">
            <xsl:attribute name="id">reply-missing-table-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#reply-missing-table-test</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>An author response table is referred to in the text, but there is no table in the response with a label.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M94"/>
   <xsl:template match="@*|node()" priority="-2" mode="M94">
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>

   <!--PATTERN sub-article-ext-link-tests-pattern-->


	  <!--RULE sub-article-ext-link-tests-->
   <xsl:template match="sub-article//ext-link" priority="1000" mode="M95">

		<!--REPORT error-->
      <xsl:if test="contains(@xlink:href,'paperpile.com')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(@xlink:href,'paperpile.com')">
            <xsl:attribute name="id">paper-pile-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#paper-pile-test</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M95"/>
   <xsl:template match="@*|node()" priority="-2" mode="M95">
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>

   <!--PATTERN sub-article-ref-p-tests-pattern-->


	  <!--RULE sub-article-ref-p-tests-->
   <xsl:template match="sub-article[@article-type='reply']/body/*[last()][name()='p']" priority="1000" mode="M96">

		<!--REPORT warning-->
      <xsl:if test="count(tokenize(lower-case(.),'doi\p{Zs}?:')) gt 2">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(tokenize(lower-case(.),'doi\p{Zs}?:')) gt 2">
            <xsl:attribute name="id">sub-article-ref-p-test</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#sub-article-ref-p-test</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The last paragraph of the author response looks like it contains various references. Should each reference be split out into its own paragraph? <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M96"/>
   <xsl:template match="@*|node()" priority="-2" mode="M96">
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>

   <!--PATTERN ref-report-front-pattern-->


	  <!--RULE ref-report-front-->
   <xsl:template match="sub-article[@article-type='referee-report']/front-stub" priority="1000" mode="M97">
      <xsl:variable name="count" select="count(contrib-group)"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-id[@pub-id-type='doi']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-id[@pub-id-type='doi']) = 1">
               <xsl:attribute name="id">ref-report-front-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/decision-letters-and-author-responses-rr1pcseo#dec-letter-front-test-1</xsl:attribute>
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
         <xsl:when test="$count = 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$count = 2">
               <xsl:attribute name="id">ref-report-front-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article front-stub must contain 2 contrib-group elements.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M97"/>
   <xsl:template match="@*|node()" priority="-2" mode="M97">
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>

   <!--PATTERN sub-article-contrib-tests-pattern-->


	  <!--RULE sub-article-contrib-tests-->
   <xsl:template match="sub-article[@article-type=('editor-report','referee-report','author-comment')]/front-stub/contrib-group/contrib" priority="1000" mode="M98">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@contrib-type='author'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@contrib-type='author'">
               <xsl:attribute name="id">sub-article-contrib-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>contrib inside sub-article with article-type '<xsl:text/>
                  <xsl:value-of select="ancestor::sub-article/@article-type"/>
                  <xsl:text/>' must have the attribute contrib-type='author'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name or anonymous or collab"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name or anonymous or collab">
               <xsl:attribute name="id">sub-article-contrib-test-2</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>sub-article contrib must have either a child name or a child anonymous element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="(name and anonymous) or (collab and anonymous) or (name and collab)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(name and anonymous) or (collab and anonymous) or (name and collab)">
            <xsl:attribute name="id">sub-article-contrib-test-3</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>sub-article contrib can only have a child name element or a child anonymous element or a child collab element (with descendant group members as required), it cannot have more than one of these elements. This has <xsl:text/>
               <xsl:value-of select="string-join(for $x in *[name()=('name','anonymous','collab')] return concat('a ',$x/name()),' and ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="role"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="role">
               <xsl:attribute name="id">sub-article-contrib-test-4</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>contrib inside sub-article with article-type '<xsl:text/>
                  <xsl:value-of select="ancestor::sub-article/@article-type"/>
                  <xsl:text/>' must have a child role element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M98"/>
   <xsl:template match="@*|node()" priority="-2" mode="M98">
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>

   <!--PATTERN sub-article-role-tests-pattern-->


	  <!--RULE sub-article-role-tests-->
   <xsl:template match="sub-article/front-stub/contrib-group/contrib/role" priority="1000" mode="M99">
      <xsl:variable name="sub-article-type" select="ancestor::sub-article[1]/@article-type"/>

		    <!--REPORT error-->
      <xsl:if test="$sub-article-type='referee-report' and parent::contrib/parent::contrib-group[not(preceding-sibling::contrib-group)] and not(@specific-use='editor')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$sub-article-type='referee-report' and parent::contrib/parent::contrib-group[not(preceding-sibling::contrib-group)] and not(@specific-use='editor')">
            <xsl:attribute name="id">sub-article-role-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The role element for contributors in the first contrib-group in the decision letter must have the attribute specific-use='editor'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="$sub-article-type='referee-report' and parent::contrib/parent::contrib-group[not(following-sibling::contrib-group)] and not(@specific-use='referee')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$sub-article-type='referee-report' and parent::contrib/parent::contrib-group[not(following-sibling::contrib-group)] and not(@specific-use='referee')">
            <xsl:attribute name="id">sub-article-role-test-2</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The role element for contributors in the second contrib-group in the decision letter must have the attribute specific-use='referee'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="$sub-article-type='author-comment' and not(@specific-use='author')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$sub-article-type='author-comment' and not(@specific-use='author')">
            <xsl:attribute name="id">sub-article-role-test-3</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The role element for contributors in the author response must have the attribute specific-use='author'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="@specific-use='author' and .!='Author'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use='author' and .!='Author'">
            <xsl:attribute name="id">sub-article-role-test-4</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A role element with the attribute specific-use='author' must contain the text 'Author'. This one has '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="@specific-use='editor' and not(.=('Senior and Reviewing Editor','Reviewing Editor'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use='editor' and not(.=('Senior and Reviewing Editor','Reviewing Editor'))">
            <xsl:attribute name="id">sub-article-role-test-5</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A role element with the attribute specific-use='editor' must contain the text 'Senior and Reviewing Editor' or 'Reviewing Editor'. This one has '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="@specific-use='referee' and .!='Reviewer'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use='referee' and .!='Reviewer'">
            <xsl:attribute name="id">sub-article-role-test-6</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A role element with the attribute specific-use='referee' must contain the text 'Reviewer'. This one has '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M99"/>
   <xsl:template match="@*|node()" priority="-2" mode="M99">
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>

   <!--PATTERN ref-report-editor-tests-pattern-->


	  <!--RULE ref-report-editor-tests-->
   <xsl:template match="sub-article[@article-type='referee-report']/front-stub/contrib-group[1]" priority="1000" mode="M100">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(contrib[role[@specific-use='editor']]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[role[@specific-use='editor']]) = 1">
               <xsl:attribute name="id">ref-report-editor-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>First contrib-group in decision letter must contain 1 and only 1 editor (a contrib with a role[@specific-use='editor']).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M100"/>
   <xsl:template match="@*|node()" priority="-2" mode="M100">
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>

   <!--PATTERN ref-report-reviewer-tests-pattern-->


	  <!--RULE ref-report-reviewer-tests-->
   <xsl:template match="sub-article[@article-type='referee-report']/front-stub/contrib-group[2]" priority="1000" mode="M101">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(contrib[role[@specific-use='referee']]) gt 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[role[@specific-use='referee']]) gt 0">
               <xsl:attribute name="id">ref-report-reviewer-test-1</xsl:attribute>
               <xsl:attribute name="flag">dl-ar</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Second contrib-group in decision letter must contain a reviewer (a contrib with a child role[@specific-use='referee']).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT warning-->
      <xsl:if test="count(contrib[role[@specific-use='referee']]) gt 5">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib[role[@specific-use='referee']]) gt 5">
            <xsl:attribute name="id">ref-report-reviewer-test-6</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Second contrib-group in decision letter contains more than five reviewers. Is this correct? Exeter: Please check with eLife. eLife: check eJP to ensure this is correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M101"/>
   <xsl:template match="@*|node()" priority="-2" mode="M101">
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>

   <!--PATTERN feature-template-tests-pattern-->


	  <!--RULE feature-template-tests-->
   <xsl:template match="article[descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject = $features-subj]" priority="1000" mode="M102">
      <xsl:variable name="template" select="descendant::article-meta/custom-meta-group/custom-meta[meta-name='Template']/meta-value[1]"/>
      <xsl:variable name="type" select="descendant::article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]"/>

		    <!--REPORT error-->
      <xsl:if test="($template = ('1','2','3')) and child::sub-article">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($template = ('1','2','3')) and child::sub-article">
            <xsl:attribute name="id">feature-template-test-1</xsl:attribute>
            <xsl:attribute name="flag">dl-ar</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-1</xsl:attribute>
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
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/feature-content-alikl8qp#feature-template-test-2</xsl:attribute>
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
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M102"/>
   <xsl:template match="@*|node()" priority="-2" mode="M102">
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
</xsl:stylesheet>