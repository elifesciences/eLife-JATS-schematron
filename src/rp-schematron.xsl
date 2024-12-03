<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:file="java.io.File" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:java="http://www.java.com/" xmlns:meca="http://manuscriptexchange.org" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
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
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron" name="e:is-valid-issn" as="xs:boolean">
      <xsl:param name="s" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="not(matches($s,'^\d{4}\-\d{3}[\dX]$'))">
            <xsl:value-of select="false()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="d1" select="number(substring($s,1,1)) * 8"/>
            <xsl:variable name="d2" select="number(substring($s,2,1)) * 7"/>
            <xsl:variable name="d3" select="number(substring($s,3,1)) * 6"/>
            <xsl:variable name="d4" select="number(substring($s,4,1)) * 5"/>
            <xsl:variable name="d5" select="number(substring($s,6,1)) * 4"/>
            <xsl:variable name="d6" select="number(substring($s,7,1)) * 3"/>
            <xsl:variable name="d7" select="number(substring($s,8,1)) * 2"/>
            <xsl:variable name="remainder" select="number($d1 + $d2 + $d3 + $d4 + $d5 + $d6 + $d7) mod 11"/>
            <xsl:variable name="calc" select="if ($remainder=0) then 0 else (11 - $remainder)"/>
            <xsl:variable name="check" select="if (substring($s,9,1)='X') then 10 else number(substring($s,9,1))"/>
            <xsl:value-of select="$calc = $check"/>
         </xsl:otherwise>
      </xsl:choose>
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
                        <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author']/collab[1]/text()[1],' &amp; ',$contrib-group/contrib[@contrib-type='author']/collab[2]/text()[1])"/>
                     </xsl:when>
                     <xsl:when test="$contrib-group/contrib[@contrib-type='author'][1]/collab">
                        <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/collab[1]/text()[1],' &amp; ',$contrib-group/contrib[@contrib-type='author'][2]/name[1]/surname[1])"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/name[1]/surname[1],' &amp; ',$contrib-group/contrib[@contrib-type='author'][2]/collab[1]/text()[1])"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="concat($contrib-group/contrib[@contrib-type='author'][1]/name[1]/surname[1],' &amp; ',$contrib-group/contrib[@contrib-type='author'][2]/name[1]/surname[1])"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="is-equal-contrib" select="if ($contrib-group/contrib[@contrib-type='author'][1]/@equal-contrib='yes') then true() else false()"/>
            <xsl:value-of select="concat(e:get-surname($contrib-group/contrib[@contrib-type='author'][1]),' et al')"/>
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
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="eLife reviewed preprint schematron" schemaVersion="">
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
         <svrl:ns-prefix-in-attribute-values uri="http://manuscriptexchange.org" prefix="meca"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">article-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-title-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">article-title-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-title-children-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">article-title-children-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">author-contrib-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">author-contrib-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">author-corresp-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">author-corresp-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">name-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">name-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">surname-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">surname-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">given-names-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">given-names-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">name-child-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">name-child-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">orcid-name-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">orcid-name-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">affiliation-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">affiliation-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">aff-institution-wrap-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">aff-institution-wrap-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">aff-institution-id-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">aff-institution-id-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">journal-ref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">journal-ref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">journal-source-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">journal-source-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">preprint-ref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">preprint-ref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">book-ref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">book-ref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M34"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">book-ref-source-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">book-ref-source-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M35"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-list-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-list-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M36"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-numeric-label-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-numeric-label-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M37"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-label-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-label-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M38"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-year-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-year-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M39"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-name-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-name-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-name-space-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-name-space-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M41"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">collab-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">collab-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-etal-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-etal-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-comment-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-comment-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-pub-id-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-pub-id-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">isbn-conformity-pattern</xsl:attribute>
            <xsl:attribute name="name">isbn-conformity-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">issn-conformity-pattern</xsl:attribute>
            <xsl:attribute name="name">issn-conformity-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-person-group-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-person-group-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M48"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">mixed-citation-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">mixed-citation-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M50"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">back-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">back-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">strike-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">strike-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M52"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">underline-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">underline-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fig-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">fig-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M54"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fig-child-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">fig-child-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fig-label-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">fig-label-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">table-wrap-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">table-wrap-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">table-wrap-child-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">table-wrap-child-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">table-wrap-label-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">table-wrap-label-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">supplementary-material-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">supplementary-material-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">supplementary-material-child-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">supplementary-material-child-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-formula-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-formula-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">inline-formula-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">inline-formula-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">inline-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">inline-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">list-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">list-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M66"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">graphic-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">graphic-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M67"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">media-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">media-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M68"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sec-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">sec-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M69"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">title-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">title-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M70"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">title-toc-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">title-toc-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M71"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">p-bold-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">p-bold-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M72"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">general-article-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">general-article-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M73"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">general-article-id-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">general-article-id-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M74"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">publisher-article-id-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">publisher-article-id-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M75"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-dois-pattern</xsl:attribute>
            <xsl:attribute name="name">article-dois-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M76"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">author-notes-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">author-notes-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M77"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">author-notes-fn-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">author-notes-fn-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M78"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-version-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">article-version-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M79"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-version-alternatives-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">article-version-alternatives-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M80"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rp-and-preprint-version-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">rp-and-preprint-version-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M81"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">preprint-pub-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">preprint-pub-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M82"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">contrib-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">contrib-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M83"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">volume-test-pattern</xsl:attribute>
            <xsl:attribute name="name">volume-test-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M84"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">elocation-id-test-pattern</xsl:attribute>
            <xsl:attribute name="name">elocation-id-test-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M85"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">history-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">history-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M86"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">pub-history-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">pub-history-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M87"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">event-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">event-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M88"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">event-child-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">event-child-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M89"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rp-event-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">rp-event-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M90"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">event-desc-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">event-desc-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M91"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">event-date-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">event-date-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M92"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">event-self-uri-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">event-self-uri-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M93"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">abstract-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">abstract-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M94"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">abstract-child-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">abstract-child-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M95"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">abstract-lang-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">abstract-lang-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M96"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">front-permissions-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">front-permissions-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M97"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">cc-by-permissions-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">cc-by-permissions-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M98"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">cc-0-permissions-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">cc-0-permissions-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M99"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">license-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">license-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M100"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">license-p-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">license-p-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M101"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">license-link-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">license-link-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M102"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">license-ali-ref-link-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">license-ali-ref-link-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M103"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fig-permissions-check-pattern</xsl:attribute>
            <xsl:attribute name="name">fig-permissions-check-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M104"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">digest-title-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">digest-title-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M105"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">preformat-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">preformat-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M106"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">code-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">code-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M107"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">uri-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">uri-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M108"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">xref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">xref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M109"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ext-link-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ext-link-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M110"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ext-link-tests-2-pattern</xsl:attribute>
            <xsl:attribute name="name">ext-link-tests-2-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M111"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">footnote-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">footnote-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M112"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">unallowed-symbol-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">unallowed-symbol-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M113"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-report-front-stub-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-report-front-stub-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M114"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-report-kwd-group-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-report-kwd-group-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M115"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-report-kwds-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-report-kwds-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M116"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-report-claim-kwds-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-report-claim-kwds-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M117"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-report-evidence-kwds-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-report-evidence-kwds-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M118"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ed-report-bold-terms-pattern</xsl:attribute>
            <xsl:attribute name="name">ed-report-bold-terms-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M119"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ar-bold-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ar-bold-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M120"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sub-article-title-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">sub-article-title-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M121"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">arxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">arxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M122"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">arxiv-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">arxiv-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M123"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">res-square-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">res-square-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M124"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">res-square-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">res-square-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M125"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">psyarxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">psyarxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M126"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">psyarxiv-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">psyarxiv-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M127"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">osf-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">osf-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M128"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">osf-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">osf-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M129"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ecoevorxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ecoevorxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M130"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ecoevorxiv-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ecoevorxiv-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M131"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">authorea-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">authorea-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M132"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">authorea-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">authorea-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M133"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">eLife reviewed preprint schematron</svrl:text>
   <!--PATTERN article-tests-pattern-->
   <!--RULE article-tests-->
   <xsl:template match="article" priority="1000" mode="M18">
      <xsl:variable name="article-text" select="string-join(for $x in self::*/*[local-name() = 'body' or local-name() = 'back']//*           return           if ($x/ancestor::ref-list) then ()           else if ($x/ancestor::caption[parent::fig] or $x/ancestor::permissions[parent::fig]) then ()           else $x/text(),'')"/>
      <xsl:variable name="is-revised-rp" select="if (descendant::article-meta/pub-history/event/self-uri[@content-type='reviewed-preprint']) then true() else false()"/>
      <xsl:variable name="rp-version" select="replace(descendant::article-meta[1]/article-id[@specific-use='version'][1],'^.*\.','')"/>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case($article-text),'biorend[eo]r')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case($article-text),'biorend[eo]r')">
            <xsl:attribute name="id">biorender-check</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[biorender-check] Article text contains a reference to bioRender. Any figures created with bioRender should include a sentence in the caption in the format: "Created with BioRender.com/{figure-code}".</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="$is-revised-rp and not(sub-article[@article-type='author-comment'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-revised-rp and not(sub-article[@article-type='author-comment'])">
            <xsl:attribute name="id">no-author-response-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[no-author-response-1] Revised Reviewed Preprint (version <xsl:text/>
               <xsl:value-of select="$rp-version"/>
               <xsl:text/>) does not have an author response, which is unusual. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="not($is-revised-rp) and (number($rp-version) gt 1) and not(sub-article[@article-type='author-comment'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-revised-rp) and (number($rp-version) gt 1) and not(sub-article[@article-type='author-comment'])">
            <xsl:attribute name="id">no-author-response-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[no-author-response-2] Revised Reviewed Preprint (version <xsl:text/>
               <xsl:value-of select="$rp-version"/>
               <xsl:text/>) does not have an author response, which is unusual. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <!--PATTERN article-title-checks-pattern-->
   <!--RULE article-title-checks-->
   <xsl:template match="article-meta/title-group/article-title" priority="1000" mode="M19">

		<!--REPORT error-->
      <xsl:if test=". = upper-case(.)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = upper-case(.)">
            <xsl:attribute name="id">article-title-all-caps</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-title-all-caps] Article title is in all caps - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>. Please change to sentence case.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'[*¶†‡§¥⁑╀◊♯࿎ł#]$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[*¶†‡§¥⁑╀◊♯࿎ł#]$')">
            <xsl:attribute name="id">article-title-check-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-title-check-1] Article title ends with a '<xsl:text/>
               <xsl:value-of select="substring(.,string-length(.))"/>
               <xsl:text/>' character: '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Is this a note indicator? If so, since notes are not supported in EPP, this should be removed.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <!--PATTERN article-title-children-checks-pattern-->
   <!--RULE article-title-children-checks-->
   <xsl:template match="article-meta/title-group/article-title/*" priority="1000" mode="M20">
      <xsl:variable name="permitted-children" select="('italic','sup','sub')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name()=$permitted-children"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()=$permitted-children">
               <xsl:attribute name="id">article-title-children-check-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-title-children-check-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> is not supported as a child of article title. Please remove this element (and any child content, as appropriate).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="normalize-space(.)=''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.)=''">
            <xsl:attribute name="id">article-title-children-check-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-title-children-check-2] Child elements of article-title must contain text content. This <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element is empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <!--PATTERN author-contrib-checks-pattern-->
   <!--RULE author-contrib-checks-->
   <xsl:template match="article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)]" priority="1000" mode="M21">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="xref[@ref-type='aff']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="xref[@ref-type='aff']">
               <xsl:attribute name="id">author-contrb-no-aff-xref</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[author-contrb-no-aff-xref] Author <xsl:text/>
                  <xsl:value-of select="e:get-name(name[1])"/>
                  <xsl:text/> has no affiliation.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <!--PATTERN author-corresp-checks-pattern-->
   <!--RULE author-corresp-checks-->
   <xsl:template match="contrib[@contrib-type='author']" priority="1000" mode="M22">

		<!--REPORT error-->
      <xsl:if test="@corresp='yes' and not(email) and not(xref[@ref-type='corresp'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@corresp='yes' and not(email) and not(xref[@ref-type='corresp'])">
            <xsl:attribute name="id">author-corresp-no-email</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-corresp-no-email] Author <xsl:text/>
               <xsl:value-of select="e:get-name(name[1])"/>
               <xsl:text/> has the attribute corresp="yes", but they do not have a child email element or an xref with the attribute ref-type="corresp".</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="not(@corresp='yes') and (email or xref[@ref-type='corresp'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@corresp='yes') and (email or xref[@ref-type='corresp'])">
            <xsl:attribute name="id">author-email-no-corresp</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-email-no-corresp] Author <xsl:text/>
               <xsl:value-of select="e:get-name(name[1])"/>
               <xsl:text/> does not have the attribute corresp="yes", but they have a child email element or an xref with the attribute ref-type="corresp".</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and not(@equal-contrib='yes')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and not(@equal-contrib='yes')">
            <xsl:attribute name="id">author-equal-contrib-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-equal-contrib-1] Author <xsl:text/>
               <xsl:value-of select="e:get-name(name[1])"/>
               <xsl:text/> does not have the attribute equal-contrib="yes", but they have a child xref element that points to a footnote with the fn-type 'equal'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="not(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and @equal-contrib='yes'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(xref/@rid = ancestor::article-meta/author-notes/fn[@fn-type='equal']/@id) and @equal-contrib='yes'">
            <xsl:attribute name="id">author-equal-contrib-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-equal-contrib-2] Author <xsl:text/>
               <xsl:value-of select="e:get-name(name[1])"/>
               <xsl:text/> has the attribute equal-contrib="yes", but they do not have a child xref element that points to a footnote with the fn-type 'equal'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <!--PATTERN name-tests-pattern-->
   <!--RULE name-tests-->
   <xsl:template match="contrib-group//name" priority="1000" mode="M23">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(surname) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(surname) = 1">
               <xsl:attribute name="id">surname-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[surname-test-1] Each name must contain only one surname.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="count(given-names) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(given-names) gt 1">
            <xsl:attribute name="id">given-names-test-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-1] Each name must contain only one given-names element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="given-names"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="given-names">
               <xsl:attribute name="id">given-names-test-2</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[given-names-test-2] This name - <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/> - does not contain a given-name. Please check with eLife staff that this is correct.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <!--PATTERN surname-tests-pattern-->
   <!--RULE surname-tests-->
   <xsl:template match="contrib-group//name/surname" priority="1000" mode="M24">

		<!--REPORT error-->
      <xsl:if test="not(*) and (normalize-space(.)='')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(*) and (normalize-space(.)='')">
            <xsl:attribute name="id">surname-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-2] surname must not be empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc">
            <xsl:attribute name="id">surname-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-3] surname must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,&quot;^[\p{L}\p{M}\s'’\.-]*$&quot;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,&quot;^[\p{L}\p{M}\s'’\.-]*$&quot;)">
               <xsl:attribute name="id">surname-test-4</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[surname-test-4] surname should usually only contain letters, spaces, or hyphens. <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/> contains other characters.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'^\p{Ll}') and not(matches(.,'^de[lrn]? |^van |^von |^el |^te[rn] |^d[ai] '))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\p{Ll}') and not(matches(.,'^de[lrn]? |^van |^von |^el |^te[rn] |^d[ai] '))">
            <xsl:attribute name="id">surname-test-5</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-5] surname doesn't begin with a capital letter - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(.,'^\p{Zs}')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\p{Zs}')">
            <xsl:attribute name="id">surname-test-6</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-6] surname starts with a space, which cannot be correct - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(.,'\p{Zs}$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\p{Zs}$')">
            <xsl:attribute name="id">surname-test-7</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-7] surname ends with a space, which cannot be correct - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'^[A-Z]{1,2}\.?\p{Zs}') and (string-length(.) gt 3)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^[A-Z]{1,2}\.?\p{Zs}') and (string-length(.) gt 3)">
            <xsl:attribute name="id">surname-test-8</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-8] surname looks to start with initial - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Should '<xsl:text/>
               <xsl:value-of select="substring-before(.,' ')"/>
               <xsl:text/>' be placed in the given-names field?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'[\(\)\[\]]')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[\(\)\[\]]')">
            <xsl:attribute name="id">surname-test-9</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-9] surname contains brackets - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Should the bracketed text be placed in the given-names field instead?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'\s') and not(matches(lower-case(.),'^de[lrn]? |^v[ao]n |^el |^te[rn] |^l[ae] |^zur |^d[ia] '))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\s') and not(matches(lower-case(.),'^de[lrn]? |^v[ao]n |^el |^te[rn] |^l[ae] |^zur |^d[ia] '))">
            <xsl:attribute name="id">surname-test-10</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[surname-test-10] surname contains space(s) - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Has it been captured correctly? Should any namee be moved to given-names?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <!--PATTERN given-names-tests-pattern-->
   <!--RULE given-names-tests-->
   <xsl:template match="name/given-names" priority="1000" mode="M25">

		<!--REPORT error-->
      <xsl:if test="not(*) and (normalize-space(.)='')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(*) and (normalize-space(.)='')">
            <xsl:attribute name="id">given-names-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-3] given-names must not be empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="descendant::bold or descendant::sub or descendant::sup or descendant::italic or descendant::sc">
            <xsl:attribute name="id">given-names-test-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-4] given-names must not contain any formatting (bold, or italic emphasis, or smallcaps, superscript or subscript) - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,&quot;^[\p{L}\p{M}\(\)\s'’\.-]*$&quot;)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,&quot;^[\p{L}\p{M}\(\)\s'’\.-]*$&quot;)">
               <xsl:attribute name="id">given-names-test-5</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[given-names-test-5] given-names should usually only contain letters, spaces, or hyphens. <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/> contains other characters.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="matches(.,'^\p{Lu}')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\p{Lu}')">
               <xsl:attribute name="id">given-names-test-6</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[given-names-test-6] given-names doesn't begin with a capital letter - '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'. Is this correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="matches(.,'^\p{Zs}')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\p{Zs}')">
            <xsl:attribute name="id">given-names-test-8</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-8] given-names starts with a space, which cannot be correct - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(.,'\p{Zs}$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\p{Zs}$')">
            <xsl:attribute name="id">given-names-test-9</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-9] given-names ends with a space, which cannot be correct - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'[A-Za-z]\.? [Dd]e[rn]?$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[A-Za-z]\.? [Dd]e[rn]?$')">
            <xsl:attribute name="id">given-names-test-10</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-10] given-names ends with de, der, or den - should this be captured as the beginning of the surname instead? - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'[A-Za-z]\.? [Vv]an$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[A-Za-z]\.? [Vv]an$')">
            <xsl:attribute name="id">given-names-test-11</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-11] given-names ends with ' van' - should this be captured as the beginning of the surname instead? - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'[A-Za-z]\.? [Vv]on$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[A-Za-z]\.? [Vv]on$')">
            <xsl:attribute name="id">given-names-test-12</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-12] given-names ends with ' von' - should this be captured as the beginning of the surname instead? - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'[A-Za-z]\.? [Ee]l$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[A-Za-z]\.? [Ee]l$')">
            <xsl:attribute name="id">given-names-test-13</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-13] given-names ends with ' el' - should this be captured as the beginning of the surname instead? - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'[A-Za-z]\.? [Tt]e[rn]?$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[A-Za-z]\.? [Tt]e[rn]?$')">
            <xsl:attribute name="id">given-names-test-14</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-14] given-names ends with te, ter, or ten - should this be captured as the beginning of the surname instead? - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT info-->
      <xsl:if test="matches(normalize-space(.),'[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]|[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]$|^[A-za-z]\p{Zs}[A-za-z]$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(.),'[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]|[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]$|^[A-za-z]\p{Zs}[A-za-z]$')">
            <xsl:attribute name="id">given-names-test-15</xsl:attribute>
            <xsl:attribute name="role">info</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-15] given-names contains initials with spaces. Ensure that the space(s) is removed between initials - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'^[\p{Lu}\s]+$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^[\p{Lu}\s]+$')">
            <xsl:attribute name="id">given-names-test-16</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[given-names-test-16] given-names for author is made up only of uppercase letters (and spaces) '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Are they initials? Should the authors full given-names be introduced instead?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <!--PATTERN name-child-tests-pattern-->
   <!--RULE name-child-tests-->
   <xsl:template match="contrib-group//name/*" priority="1000" mode="M26">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="local-name() = ('surname','given-names','suffix')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="local-name() = ('surname','given-names','suffix')">
               <xsl:attribute name="id">disallowed-child-assert</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[disallowed-child-assert] <xsl:text/>
                  <xsl:value-of select="local-name()"/>
                  <xsl:text/> is not supported as a child of name.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <!--PATTERN orcid-name-checks-pattern-->
   <!--RULE orcid-name-checks-->
   <xsl:template match="article/front/article-meta/contrib-group[1]" priority="1000" mode="M27">
      <xsl:variable name="names" select="for $name in contrib[@contrib-type='author']/name[1] return e:get-name($name)"/>
      <xsl:variable name="indistinct-names" select="for $name in distinct-values($names) return $name[count($names[. = $name]) gt 1]"/>
      <xsl:variable name="orcids" select="for $x in contrib[@contrib-type='author']/contrib-id[@contrib-id-type='orcid'] return substring-after($x,'orcid.org/')"/>
      <xsl:variable name="indistinct-orcids" select="for $orcid in distinct-values($orcids) return $orcid[count($orcids[. = $orcid]) gt 1]"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="empty($indistinct-names)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="empty($indistinct-names)">
               <xsl:attribute name="id">duplicate-author-test</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[duplicate-author-test] There is more than one author with the following name(s) - <xsl:text/>
                  <xsl:value-of select="if (count($indistinct-names) gt 1) then concat(string-join($indistinct-names[position() != last()],', '),' and ',$indistinct-names[last()]) else $indistinct-names"/>
                  <xsl:text/> - which is very likely be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="empty($indistinct-orcids)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="empty($indistinct-orcids)">
               <xsl:attribute name="id">duplicate-orcid-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[duplicate-orcid-test] There is more than one author with the following ORCiD(s) - <xsl:text/>
                  <xsl:value-of select="if (count($indistinct-orcids) gt 1) then concat(string-join($indistinct-orcids[position() != last()],', '),' and ',$indistinct-orcids[last()]) else $indistinct-orcids"/>
                  <xsl:text/> - which must be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <!--PATTERN affiliation-checks-pattern-->
   <!--RULE affiliation-checks-->
   <xsl:template match="aff" priority="1000" mode="M28">
      <xsl:variable name="country-count" select="count(descendant::country)"/>
      <!--REPORT warning-->
      <xsl:if test="$country-count lt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$country-count lt 1">
            <xsl:attribute name="id">aff-no-country</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-no-country] Affiliation does not contain a country element: <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$country-count gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$country-count gt 1">
            <xsl:attribute name="id">aff-multiple-country</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-multiple-country] Affiliation contains more than one country element: <xsl:text/>
               <xsl:value-of select="string-join(descendant::country,'; ')"/>
               <xsl:text/> in <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="count(descendant::institution) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(descendant::institution) gt 1">
            <xsl:attribute name="id">aff-multiple-institution</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-multiple-institution] Affiliation contains more than one institution element: <xsl:text/>
               <xsl:value-of select="string-join(descendant::institution,'; ')"/>
               <xsl:text/> in <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="count(descendant::institution-id) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(descendant::institution-id) gt 1">
            <xsl:attribute name="id">aff-multiple-ids</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-multiple-ids] Affiliation contains more than one institution-id element: <xsl:text/>
               <xsl:value-of select="string-join(descendant::institution-id,'; ')"/>
               <xsl:text/> in <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="ancestor::article/journal-meta/lower-case(journal-id[1])='elife' and count(institution-wrap) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::article/journal-meta/lower-case(journal-id[1])='elife' and count(institution-wrap) = 0">
            <xsl:attribute name="id">aff-no-wrap</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-no-wrap] Affiliation doesn't have an institution-wrap element (the container for institution name and id). Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="institution-wrap[not(institution-id)] and not(ancestor::contrib-group[@content-type='section']) and not(ancestor::sub-article)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="institution-wrap[not(institution-id)] and not(ancestor::contrib-group[@content-type='section']) and not(ancestor::sub-article)">
            <xsl:attribute name="id">aff-has-wrap-no-id</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-has-wrap-no-id] aff contains institution-wrap, but that institution-wrap does not have a child institution-id. institution-wrap should only be used when there is an institution-id for the institution.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="institution-wrap[not(institution)]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="institution-wrap[not(institution)]">
            <xsl:attribute name="id">aff-has-wrap-no-inst</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-has-wrap-no-inst] aff contains institution-wrap, but that institution-wrap does not have a child institution.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="count(descendant::institution-wrap) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(descendant::institution-wrap) gt 1">
            <xsl:attribute name="id">aff-mutliple-wraps</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-mutliple-wraps] Affiliation contains more than one institution-wrap element: <xsl:text/>
               <xsl:value-of select="string-join(descendant::institution-wrap/*,'; ')"/>
               <xsl:text/> in <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <!--PATTERN aff-institution-wrap-tests-pattern-->
   <!--RULE aff-institution-wrap-tests-->
   <xsl:template match="aff[ancestor::contrib-group[not(@*)]/parent::article-meta]//institution-wrap" priority="1000" mode="M29">
      <xsl:variable name="display" select="string-join(parent::aff//*[not(local-name()=('label','institution-id','institution-wrap','named-content','city'))],', ')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="institution-id and institution[not(@*)]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="institution-id and institution[not(@*)]">
               <xsl:attribute name="id">aff-institution-wrap-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[aff-institution-wrap-test-1] If an affiliation has an institution wrap, then it must have both an institution-id and an institution. If there is no ROR for this institution, then it should be captured as a single institution element without institution-wrap. This institution-wrap does not have both elements - <xsl:text/>
                  <xsl:value-of select="$display"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="parent::aff"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::aff">
               <xsl:attribute name="id">aff-institution-wrap-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[aff-institution-wrap-test-2] institution-wrap must be a child of aff. This one has <xsl:text/>
                  <xsl:value-of select="parent::*/name()"/>
                  <xsl:text/> as its parent.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="count(institution-id)=1 and text()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(institution-id)=1 and text()">
            <xsl:attribute name="id">aff-institution-wrap-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-institution-wrap-test-3] institution-wrap cannot contain text. It can only contain elements.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(institution[not(@*)]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(institution[not(@*)]) = 1">
               <xsl:attribute name="id">aff-institution-wrap-test-5</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[aff-institution-wrap-test-5] institution-wrap must contain 1 and only 1 institution elements. This one has <xsl:text/>
                  <xsl:value-of select="count(institution[not(@*)])"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <!--PATTERN aff-institution-id-tests-pattern-->
   <!--RULE aff-institution-id-tests-->
   <xsl:template match="aff//institution-id" priority="1000" mode="M30">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@institution-id-type='ror'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@institution-id-type='ror'">
               <xsl:attribute name="id">aff-institution-id-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[aff-institution-id-test-1] institution-id in aff must have the attribute institution-id-type="ror".</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'https?://ror\.org/[a-z0-9]{9}')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'https?://ror\.org/[a-z0-9]{9}')">
               <xsl:attribute name="id">aff-institution-id-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[aff-institution-id-test-2] institution-id in aff must a value which is a valid ROR id. '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' is not a valid ROR id.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="*">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
            <xsl:attribute name="id">aff-institution-id-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[aff-institution-id-test-3] institution-id in aff cannot contain elements, only text (which is a valid ROR id). This one contains the following element(s): <xsl:text/>
               <xsl:value-of select="string-join(*/name(),'; ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <!--PATTERN journal-ref-checks-pattern-->
   <!--RULE journal-ref-checks-->
   <xsl:template match="mixed-citation[@publication-type='journal']" priority="1000" mode="M31">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="source"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="source">
               <xsl:attribute name="id">journal-ref-source</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[journal-ref-source] This journal reference (<xsl:text/>
                  <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
                  <xsl:text/>) has no source element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-title">
               <xsl:attribute name="id">journal-ref-article-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[journal-ref-article-title] This journal reference (<xsl:text/>
                  <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
                  <xsl:text/>) has no article-title element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|epub|vol|and|pp?|in|is[sb]n)[:\.]?'))]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|epub|vol|and|pp?|in|is[sb]n)[:\.]?'))]">
            <xsl:attribute name="id">journal-ref-text-content</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[journal-ref-text-content] This journal reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has untagged textual content - <xsl:text/>
               <xsl:value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|epub|vol|and|pp?|in|is[sb]n)[:\.]?'))],'; ')"/>
               <xsl:text/>. Is it tagged correctly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="person-group[@person-group-type='editor']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="person-group[@person-group-type='editor']">
            <xsl:attribute name="id">journal-ref-editor</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[journal-ref-editor] This journal reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has an editor person-group. This info isn;t typically included in journal refs. Is it really a journal ref? Does it really contain editors?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <!--PATTERN journal-source-checks-pattern-->
   <!--RULE journal-source-checks-->
   <xsl:template match="mixed-citation[@publication-type='journal']/source" priority="1000" mode="M32">
      <xsl:variable name="preprint-regex" select="'biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra'"/>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),$preprint-regex)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),$preprint-regex)">
            <xsl:attribute name="id">journal-source-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[journal-source-1] Journal reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has a source which suggests it might be a preprint - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>. Is it tagged correctly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'^i{1,3}\.\s') and parent::*/article-title">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^i{1,3}\.\s') and parent::*/article-title">
            <xsl:attribute name="id">journal-source-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[journal-source-2] Journal reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has a source that starts with a roman numeral. Is part of the article-title captured in source? Source = <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'^(symposium|conference|meeting|workshop)|\s?(symposium|conference|meeting|workshop)\s?|(symposium|conference|meeting|workshop)$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^(symposium|conference|meeting|workshop)|\s?(symposium|conference|meeting|workshop)\s?|(symposium|conference|meeting|workshop)$')">
            <xsl:attribute name="id">journal-source-3</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[journal-source-3] Journal reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has the following source, '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Should it be captured as a conference proceeding instead?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <!--PATTERN preprint-ref-checks-pattern-->
   <!--RULE preprint-ref-checks-->
   <xsl:template match="mixed-citation[@publication-type='preprint']" priority="1000" mode="M33">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="source"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="source">
               <xsl:attribute name="id">preprint-ref-source</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[preprint-ref-source] This preprint reference (<xsl:text/>
                  <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
                  <xsl:text/>) has no source element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-title">
               <xsl:attribute name="id">preprint-ref-article-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[preprint-ref-article-title] This preprint reference (<xsl:text/>
                  <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
                  <xsl:text/>) has no article-title element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))]">
            <xsl:attribute name="id">preprint-ref-text-content</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[preprint-ref-text-content] This journal reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has untagged textual content - <xsl:text/>
               <xsl:value-of select="string-join(text()[matches(.,'\p{L}') and not(matches(lower-case(.),'^[\p{Z}\p{P}]+(doi|pmid|and|pp?)[:\.]?'))],'; ')"/>
               <xsl:text/>. Is it tagged correctly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <!--PATTERN book-ref-checks-pattern-->
   <!--RULE book-ref-checks-->
   <xsl:template match="mixed-citation[@publication-type='book']" priority="1000" mode="M34">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="source"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="source">
               <xsl:attribute name="id">book-ref-source</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[book-ref-source] This book reference (<xsl:text/>
                  <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
                  <xsl:text/>) has no source element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="count(source) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(source) gt 1">
            <xsl:attribute name="id">book-ref-source-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[book-ref-source-2] This book reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has more than 1 source element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="not(chapter-title) and person-group[@person-group-type='editor']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(chapter-title) and person-group[@person-group-type='editor']">
            <xsl:attribute name="id">book-ref-editor</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[book-ref-editor] This book reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has an editor person-group but no chapter-title element. Have all the details been captured correctly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="not(chapter-title) and publisher-name[italic]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(chapter-title) and publisher-name[italic]">
            <xsl:attribute name="id">book-ref-pub-name-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[book-ref-pub-name-1] This book reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has a publisher-name with italics and no chapter-title element. Have all the details been captured correctly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <!--PATTERN book-ref-source-checks-pattern-->
   <!--RULE book-ref-source-checks-->
   <xsl:template match="mixed-citation[@publication-type='book']/source" priority="1000" mode="M35">

		<!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'^chapter\s|\s+chapter\s+')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^chapter\s|\s+chapter\s+')">
            <xsl:attribute name="id">book-source-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[book-source-1] The source in book reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) contains 'chapter' - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>. Are the details captured correctly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'\.\s+in:\s+')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'\.\s+in:\s+')">
            <xsl:attribute name="id">book-source-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[book-source-2] The source in book reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) contains '. In: ' - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>. Are the details captured correctly?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'^(symposium|conference|proc\.?|proceeding|meeting|workshop)|\s?(symposium|conference|proc\.?|proceeding|meeting|workshop)\s?|(symposium|conference|proc\.?|proceeding|meeting|workshop)$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^(symposium|conference|proc\.?|proceeding|meeting|workshop)|\s?(symposium|conference|proc\.?|proceeding|meeting|workshop)\s?|(symposium|conference|proc\.?|proceeding|meeting|workshop)$')">
            <xsl:attribute name="id">book-source-3</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[book-source-3] Book reference (<xsl:text/>
               <xsl:value-of select="if (ancestor::ref/@id) then concat('id ',ancestor::ref/@id) else 'no id'"/>
               <xsl:text/>) has the following source, '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Should it be captured as a conference proceeding instead?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <!--PATTERN ref-list-checks-pattern-->
   <!--RULE ref-list-checks-->
   <xsl:template match="ref-list" priority="1000" mode="M36">
      <xsl:variable name="labels" select="./ref/label"/>
      <xsl:variable name="indistinct-labels" select="for $label in distinct-values($labels) return $label[count($labels[. = $label]) gt 1]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="empty($indistinct-labels)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="empty($indistinct-labels)">
               <xsl:attribute name="id">indistinct-ref-labels</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[indistinct-ref-labels] Duplicate labels in reference list - <xsl:text/>
                  <xsl:value-of select="string-join($indistinct-labels,'; ')"/>
                  <xsl:text/>. Have there been typesetting errors?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')] and ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')] and ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))]">
            <xsl:attribute name="id">ref-label-types</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-label-types] This ref-list has labels in the format '<xsl:text/>
               <xsl:value-of select="ref/label[matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$')][1]"/>
               <xsl:text/>' as well as labels in the format '<xsl:text/>
               <xsl:value-of select="ref/label[not(matches(.,'^\p{P}*\d+[a-zA-Z]?\p{P}*$'))][1]"/>
               <xsl:text/>'. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <!--PATTERN ref-numeric-label-checks-pattern-->
   <!--RULE ref-numeric-label-checks-->
   <xsl:template match="ref-list[ref/label[matches(.,'^\p{P}*\d+\p{P}*$')] and not(ref/label[not(matches(.,'^\p{P}*\d+\p{P}*$'))])]/ref[label]" priority="1000" mode="M37">
      <xsl:variable name="numeric-label" select="number(replace(./label[1],'[^\d]',''))"/>
      <xsl:variable name="pos" select="count(parent::ref-list/ref[label]) - count(following-sibling::ref[label])"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$numeric-label = $pos"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$numeric-label = $pos">
               <xsl:attribute name="id">ref-label-1</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ref-label-1] ref with id <xsl:text/>
                  <xsl:value-of select="@id"/>
                  <xsl:text/> has the label <xsl:text/>
                  <xsl:value-of select="$numeric-label"/>
                  <xsl:text/>, but according to its position it should be labelled as number <xsl:text/>
                  <xsl:value-of select="$pos"/>
                  <xsl:text/>. Has there been a processing error?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <!--PATTERN ref-label-checks-pattern-->
   <!--RULE ref-label-checks-->
   <xsl:template match="ref-list[ref/label]/ref" priority="1000" mode="M38">

		<!--REPORT warning-->
      <xsl:if test="not(label) and (preceding-sibling::ref[label] or following-sibling::ref[label])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(label) and (preceding-sibling::ref[label] or following-sibling::ref[label])">
            <xsl:attribute name="id">ref-label-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-label-2] ref with id <xsl:text/>
               <xsl:value-of select="@id"/>
               <xsl:text/> doesn't have a label, but other refs within the same ref-list do. Has there been a processing error?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <!--PATTERN ref-year-checks-pattern-->
   <!--RULE ref-year-checks-->
   <xsl:template match="ref//year" priority="1000" mode="M39">

		<!--REPORT error-->
      <xsl:if test="matches(.,'\d') and not(matches(.,'^\d{4}[a-z]?$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\d') and not(matches(.,'^\d{4}[a-z]?$'))">
            <xsl:attribute name="id">ref-year-value-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-year-value-1] Ref with id <xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/> has a year element with the value '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>' which contains a digit (or more) but is not a year.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="matches(.,'\d')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\d')">
               <xsl:attribute name="id">ref-year-value-2</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ref-year-value-2] Ref with id <xsl:text/>
                  <xsl:value-of select="ancestor::ref/@id"/>
                  <xsl:text/> has a year element which does not contain a digit. Is it correct? (it's acceptable for this element to contain 'no date' or equivalent non-numerical information relating to year of publication)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'^\d{4}[a-z]?$') and number(replace(.,'[^\d]','')) lt 1800">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\d{4}[a-z]?$') and number(replace(.,'[^\d]','')) lt 1800">
            <xsl:attribute name="id">ref-year-value-3</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-year-value-3] Ref with id <xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/> has a year element which is less than 1800, which is almost certain to be incorrect: <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <!--PATTERN ref-name-checks-pattern-->
   <!--RULE ref-name-checks-->
   <xsl:template match="mixed-citation//name | mixed-citation//string-name" priority="1000" mode="M40">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="surname"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="surname">
               <xsl:attribute name="id">ref-surname</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ref-surname] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in reference (id=<xsl:text/>
                  <xsl:value-of select="ancestor::ref/@id"/>
                  <xsl:text/>) does not have a surname element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="name()='string-name' and text()[not(matches(.,'^[\s\p{P}]*$'))]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()='string-name' and text()[not(matches(.,'^[\s\p{P}]*$'))]">
            <xsl:attribute name="id">ref-string-name-text</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-string-name-text] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in reference (id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) has child text containing content. This content should either be tagged or moved into a different appropriate tag, as appropriate.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--PATTERN ref-name-space-checks-pattern-->
   <!--RULE ref-name-space-checks-->
   <xsl:template match="mixed-citation//given-names | mixed-citation//surname" priority="1000" mode="M41">

		<!--REPORT error-->
      <xsl:if test="matches(.,'^\p{Z}+')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\p{Z}+')">
            <xsl:attribute name="id">ref-name-space-start</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-name-space-start] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element cannot start with space(s). This one (in ref with id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) does: '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(.,'\p{Z}+$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\p{Z}+$')">
            <xsl:attribute name="id">ref-name-space-end</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-name-space-end] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element cannot end with space(s). This one (in ref with id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) does: '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="not(*) and (normalize-space(.)='')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(*) and (normalize-space(.)='')">
            <xsl:attribute name="id">ref-name-empty</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-name-empty] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element must not be empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <!--PATTERN collab-checks-pattern-->
   <!--RULE collab-checks-->
   <xsl:template match="collab" priority="1000" mode="M42">

		<!--REPORT error-->
      <xsl:if test="matches(.,'^\p{Z}+')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\p{Z}+')">
            <xsl:attribute name="id">collab-check-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[collab-check-1] collab element cannot start with space(s). This one does: <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(.,'\p{Z}+$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\p{Z}+$')">
            <xsl:attribute name="id">collab-check-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[collab-check-2] collab element cannot end with space(s). This one does: <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="normalize-space(.)=."/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.)=.">
               <xsl:attribute name="id">collab-check-3</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[collab-check-3] collab element seems to contain odd spacing. Is it correct? '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--PATTERN ref-etal-checks-pattern-->
   <!--RULE ref-etal-checks-->
   <xsl:template match="mixed-citation[person-group]//etal" priority="1000" mode="M43">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="parent::person-group"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::person-group">
               <xsl:attribute name="id">ref-etal-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ref-etal-1] If the etal element is included in a reference, and that reference has a person-group element, then the etal should also be included in the person-group element. But this one is a child of <xsl:text/>
                  <xsl:value-of select="parent::*/name()"/>
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
   <!--PATTERN ref-comment-checks-pattern-->
   <!--RULE ref-comment-checks-->
   <xsl:template match="comment" priority="1000" mode="M44">

		<!--REPORT warning-->
      <xsl:if test="ancestor::mixed-citation">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::mixed-citation">
            <xsl:attribute name="id">ref-comment-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-comment-1] Reference (with id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) contains a comment element. Is this correct? <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <!--PATTERN ref-pub-id-checks-pattern-->
   <!--RULE ref-pub-id-checks-->
   <xsl:template match="ref//pub-id" priority="1000" mode="M45">

		<!--REPORT error-->
      <xsl:if test="@pub-id-type='doi' and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@pub-id-type='doi' and not(matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$'))">
            <xsl:attribute name="id">ref-doi-conformance</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-doi-conformance] &lt;pub-id pub-id="doi"&gt; in reference (id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) does not contain a valid DOI: '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@pub-id-type">
               <xsl:attribute name="id">pub-id-check-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[pub-id-check-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> does not have a pub-id-type attribute.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="ancestor::mixed-citation[@publication-type='journal'] and not(@pub-id-type=('doi','pmid','pmcid','issn'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::mixed-citation[@publication-type='journal'] and not(@pub-id-type=('doi','pmid','pmcid','issn'))">
            <xsl:attribute name="id">pub-id-check-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-id-check-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','issn'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="ancestor::mixed-citation[@publication-type='book'] and not(@pub-id-type=('doi','pmid','pmcid','isbn'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::mixed-citation[@publication-type='book'] and not(@pub-id-type=('doi','pmid','pmcid','isbn'))">
            <xsl:attribute name="id">pub-id-check-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-id-check-3] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','isbn'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="ancestor::mixed-citation[@publication-type='preprint'] and not(@pub-id-type=('doi','pmid','pmcid','arxiv'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::mixed-citation[@publication-type='preprint'] and not(@pub-id-type=('doi','pmid','pmcid','arxiv'))">
            <xsl:attribute name="id">pub-id-check-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-id-check-4] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is within a journal reference, but it does not have one of the following permitted @pub-id-type values: 'doi','pmid','pmcid','arxiv'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="ancestor::mixed-citation[@publication-type='web']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::mixed-citation[@publication-type='web']">
            <xsl:attribute name="id">pub-id-check-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-id-check-5] Web reference (with id <xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) has a <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>
               <xsl:text/>
               <xsl:value-of select="if (@pub-id-type) then concat('with a pub-id-type ',@pub-id-type) else 'with no pub-id-type'"/>
               <xsl:text/> (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>). This must be incorrect. Either the publication-type for the reference needs changing, or the pub-id should be changed to another element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <!--PATTERN isbn-conformity-pattern-->
   <!--RULE isbn-conformity-->
   <xsl:template match="ref//pub-id[@pub-id-type='isbn']|isbn" priority="1000" mode="M46">
      <xsl:variable name="t" select="translate(.,'-','')"/>
      <xsl:variable name="sum" select="e:isbn-sum($t)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$sum = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$sum = 0">
               <xsl:attribute name="id">isbn-conformity-test</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/references-ghxfa7uy#isbn-conformity-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[isbn-conformity-test] pub-id contains an invalid ISBN - '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'. Should it be captured as another type of pub-id?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <!--PATTERN issn-conformity-pattern-->
   <!--RULE issn-conformity-->
   <xsl:template match="ref//pub-id[@pub-id-type='issn']|issn" priority="1000" mode="M47">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="e:is-valid-issn(.)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="e:is-valid-issn(.)">
               <xsl:attribute name="id">issn-conformity-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[issn-conformity-test] pub-id contains an invalid ISSN - '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'. Should it be captured as another type of pub-id?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <!--PATTERN ref-person-group-checks-pattern-->
   <!--RULE ref-person-group-checks-->
   <xsl:template match="ref//person-group" priority="1000" mode="M48">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@person-group-type)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(@person-group-type)!=''">
               <xsl:attribute name="id">ref-person-group-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ref-person-group-type] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must have a person-group-type attribute with a non-empty value.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="./@person-group-type = preceding-sibling::person-group/@person-group-type">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@person-group-type = preceding-sibling::person-group/@person-group-type">
            <xsl:attribute name="id">ref-person-group-type-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-person-group-type-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>s within a reference should be distinct. There are numerous person-groups with the person-group-type <xsl:text/>
               <xsl:value-of select="@person-group-type"/>
               <xsl:text/> within this reference (id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="ancestor::mixed-citation[@publication-type='book'] and not(normalize-space(@person-group-type)=('','author','editor'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::mixed-citation[@publication-type='book'] and not(normalize-space(@person-group-type)=('','author','editor'))">
            <xsl:attribute name="id">ref-person-group-type-book</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-person-group-type-book] This <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> inside a book reference has the person-group-type '<xsl:text/>
               <xsl:value-of select="@person-group-type"/>
               <xsl:text/>'. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="ancestor::mixed-citation[@publication-type=('journal','data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')] and not(normalize-space(@person-group-type)=('','author'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::mixed-citation[@publication-type=('journal','data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')] and not(normalize-space(@person-group-type)=('','author'))">
            <xsl:attribute name="id">ref-person-group-type-other</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ref-person-group-type-other] This <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> inside a <xsl:text/>
               <xsl:value-of select="ancestor::mixed-citation/@publication-type"/>
               <xsl:text/> reference has the person-group-type '<xsl:text/>
               <xsl:value-of select="@person-group-type"/>
               <xsl:text/>'. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--PATTERN ref-checks-pattern-->
   <!--RULE ref-checks-->
   <xsl:template match="ref" priority="1000" mode="M49">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="mixed-citation or element-citation"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="mixed-citation or element-citation">
               <xsl:attribute name="id">ref-empty</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ref-empty] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> does not contain either a mixed-citation or an element-citation element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@id)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(@id)!=''">
               <xsl:attribute name="id">ref-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ref-id] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must have an id attribute with a non-empty value.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <!--PATTERN mixed-citation-checks-pattern-->
   <!--RULE mixed-citation-checks-->
   <xsl:template match="mixed-citation" priority="1000" mode="M50">
      <xsl:variable name="publication-type-values" select="('journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')"/>
      <xsl:variable name="name-elems" select="('name','string-name','collab','on-behalf-of','etal')"/>
      <!--REPORT error-->
      <xsl:if test="normalize-space(.)=('','.')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.)=('','.')">
            <xsl:attribute name="id">mixed-citation-empty-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[mixed-citation-empty-1] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in reference (id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) is empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="not(normalize-space(.)=('','.')) and (string-length(normalize-space(.)) lt 6)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(normalize-space(.)=('','.')) and (string-length(normalize-space(.)) lt 6)">
            <xsl:attribute name="id">mixed-citation-empty-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[mixed-citation-empty-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in reference (id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) only contains <xsl:text/>
               <xsl:value-of select="string-length(normalize-space(.))"/>
               <xsl:text/> characters.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@publication-type)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(@publication-type)!=''">
               <xsl:attribute name="id">mixed-citation-publication-type-presence</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[mixed-citation-publication-type-presence] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must have a publication-type attribute with a non-empty value.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="normalize-space(@publication-type)!='' and not(@publication-type=$publication-type-values)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(@publication-type)!='' and not(@publication-type=$publication-type-values)">
            <xsl:attribute name="id">mixed-citation-publication-type-flag</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[mixed-citation-publication-type-flag] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> has publication-type="<xsl:text/>
               <xsl:value-of select="@publication-type"/>
               <xsl:text/>" which is not one of the known/supported types: <xsl:text/>
               <xsl:value-of select="string-join($publication-type-values,'; ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="@publication-type='other'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@publication-type='other'">
            <xsl:attribute name="id">mixed-citation-other-publication-flag</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[mixed-citation-other-publication-flag] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in reference (id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) has a publication-type='other'. Is that correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="*[name()=$name-elems]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*[name()=$name-elems]">
            <xsl:attribute name="id">mixed-citation-person-group-flag-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[mixed-citation-person-group-flag-1] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in reference (id=<xsl:text/>
               <xsl:value-of select="ancestor::ref/@id"/>
               <xsl:text/>) has child name elements (<xsl:text/>
               <xsl:value-of select="string-join(distinct-values(*[name()=$name-elems]/name()),'; ')"/>
               <xsl:text/>). These all need to be placed in a person-group element with the appropriate person-group-type attribute.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="person-group[@person-group-type='author']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="person-group[@person-group-type='author']">
               <xsl:attribute name="id">mixed-citation-person-group-flag-2</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[mixed-citation-person-group-flag-2] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in reference (id=<xsl:text/>
                  <xsl:value-of select="ancestor::ref/@id"/>
                  <xsl:text/>) does not have an author person-group. Is that correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--PATTERN back-tests-pattern-->
   <!--RULE back-tests-->
   <xsl:template match="back" priority="1000" mode="M51">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="ref-list"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ref-list">
               <xsl:attribute name="id">no-ref-list</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[no-ref-list] This preprint has no reference list (as a child of back), which must be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <!--PATTERN strike-checks-pattern-->
   <!--RULE strike-checks-->
   <xsl:template match="strike" priority="1000" mode="M52">

		<!--REPORT warning-->
      <xsl:if test=".">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".">
            <xsl:attribute name="id">strike-warning</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[strike-warning] strike element is present. Is this tracked change formatting that's been erroneously retained? Should this text be deleted?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <!--PATTERN underline-checks-pattern-->
   <!--RULE underline-checks-->
   <xsl:template match="underline" priority="1000" mode="M53">

		<!--REPORT warning-->
      <xsl:if test="string-length(.) gt 20">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) gt 20">
            <xsl:attribute name="id">underline-warning</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[underline-warning] underline element contains more than 20 characters. Is this tracked change formatting that's been erroneously retained?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'www\.|(f|ht)tp|^link\s|\slink\s')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'www\.|(f|ht)tp|^link\s|\slink\s')">
            <xsl:attribute name="id">underline-link-warning</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[underline-link-warning] Should this underline element be a link (ext-link) instead? <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="replace(.,'[\s\.]','')='&gt;'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="replace(.,'[\s\.]','')='&gt;'">
            <xsl:attribute name="id">underline-gt-warning</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[underline-gt-warning] underline element contains a greater than symbol (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>). Should this a greater than or equal to symbol instead (≥)?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="replace(.,'[\s\.]','')='&lt;'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="replace(.,'[\s\.]','')='&lt;'">
            <xsl:attribute name="id">underline-lt-warning</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[underline-lt-warning] underline element contains a less than symbol (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>). Should this a less than or equal to symbol instead (≤)?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--PATTERN fig-checks-pattern-->
   <!--RULE fig-checks-->
   <xsl:template match="fig" priority="1000" mode="M54">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="graphic"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="graphic">
               <xsl:attribute name="id">fig-graphic-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[fig-graphic-conformance] <xsl:text/>
                  <xsl:value-of select="if (label) then label else name()"/>
                  <xsl:text/> does not have a child graphic element, which must be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <!--PATTERN fig-child-checks-pattern-->
   <!--RULE fig-child-checks-->
   <xsl:template match="fig/*" priority="1000" mode="M55">
      <xsl:variable name="supported-fig-children" select="('label','caption','graphic','alternatives','permissions')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name()=$supported-fig-children"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()=$supported-fig-children">
               <xsl:attribute name="id">fig-child-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[fig-child-conformance] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> is not supported as a child of &lt;fig&gt;.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--PATTERN fig-label-checks-pattern-->
   <!--RULE fig-label-checks-->
   <xsl:template match="fig/label" priority="1000" mode="M56">

		<!--REPORT error-->
      <xsl:if test="normalize-space(.)=''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.)=''">
            <xsl:attribute name="id">fig-wrap-empty</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[fig-wrap-empty] Label for fig is empty. Either remove the elment or add the missing content.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'^\s*(video|movie)')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^\s*(video|movie)')">
            <xsl:attribute name="id">fig-label-video</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[fig-label-video] Label for figure ('<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>') starts with text that suggests its a video. Should this content be captured as a video instead of a figure?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'^\s*table')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^\s*table')">
            <xsl:attribute name="id">fig-label-table</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[fig-label-table] Label for figure ('<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>') starts with table. Should this content be captured as a table instead of a figure?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--PATTERN table-wrap-checks-pattern-->
   <!--RULE table-wrap-checks-->
   <xsl:template match="table-wrap" priority="1000" mode="M57">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="graphic or alternatives[graphic]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="graphic or alternatives[graphic]">
               <xsl:attribute name="id">table-wrap-content-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[table-wrap-content-conformance] <xsl:text/>
                  <xsl:value-of select="if (label) then label else name()"/>
                  <xsl:text/> does not have a child graphic element, which must be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--PATTERN table-wrap-child-checks-pattern-->
   <!--RULE table-wrap-child-checks-->
   <xsl:template match="table-wrap/*" priority="1000" mode="M58">
      <xsl:variable name="supported-table-wrap-children" select="('label','caption','graphic','alternatives','table','permissions','table-wrap-foot')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name()=$supported-table-wrap-children"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()=$supported-table-wrap-children">
               <xsl:attribute name="id">table-wrap-child-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[table-wrap-child-conformance] <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> is not supported as a child of &lt;table-wrap&gt;.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--PATTERN table-wrap-label-checks-pattern-->
   <!--RULE table-wrap-label-checks-->
   <xsl:template match="table-wrap/label" priority="1000" mode="M59">

		<!--REPORT error-->
      <xsl:if test="normalize-space(.)=''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(.)=''">
            <xsl:attribute name="id">table-wrap-empty</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[table-wrap-empty] Label for table is empty. Either remove the elment or add the missing content.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),'^\s*fig')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^\s*fig')">
            <xsl:attribute name="id">table-wrap-label-fig</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[table-wrap-label-fig] Label for table ('<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>') starts with text that suggests its a figure. Should this content be captured as a figure instead of a table?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--PATTERN supplementary-material-checks-pattern-->
   <!--RULE supplementary-material-checks-->
   <xsl:template match="supplementary-material" priority="1000" mode="M60">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="ancestor::sec[@sec-type='supplementary-material']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::sec[@sec-type='supplementary-material']">
               <xsl:attribute name="id">supplementary-material-temp-test</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[supplementary-material-temp-test] supplementary-material element is not placed within a &lt;sec sec-type="supplementary-material"&gt;. There is currently no support for supplementary-material in RPs. Please either move the supplementary-material under an existing &lt;sec sec-type="supplementary-material"&gt; or add a new &lt;sec sec-type="supplementary-material"&gt; around this an any other supplementary-material.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="media"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="media">
               <xsl:attribute name="id">supplementary-material-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[supplementary-material-test-1] supplementary-material does not have a child media. It must either have a file or be deleted.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="count(media) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(media) gt 1">
            <xsl:attribute name="id">supplementary-material-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[supplementary-material-test-2] supplementary-material has <xsl:text/>
               <xsl:value-of select="count(media)"/>
               <xsl:text/> child media elements. Each file must be wrapped in its own supplementary-material.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <!--PATTERN supplementary-material-child-checks-pattern-->
   <!--RULE supplementary-material-child-checks-->
   <xsl:template match="supplementary-material/*" priority="1000" mode="M61">
      <xsl:variable name="permitted-children" select="('label','caption','media')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name()=$permitted-children"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()=$permitted-children">
               <xsl:attribute name="id">supplementary-material-child-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[supplementary-material-child-test-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> is not supported as a child of supplementary-material. The only permitted children are: <xsl:text/>
                  <xsl:value-of select="string-join($permitted-children,'; ')"/>
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
   <!--PATTERN disp-formula-checks-pattern-->
   <!--RULE disp-formula-checks-->
   <xsl:template match="disp-formula" priority="1000" mode="M62">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="graphic or alternatives[graphic]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="graphic or alternatives[graphic]">
               <xsl:attribute name="id">disp-formula-content-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[disp-formula-content-conformance] <xsl:text/>
                  <xsl:value-of select="if (label) then concat('Equation ',label) else name()"/>
                  <xsl:text/> does not have a child graphic element, which must be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <!--PATTERN inline-formula-checks-pattern-->
   <!--RULE inline-formula-checks-->
   <xsl:template match="inline-formula" priority="1000" mode="M63">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="inline-graphic or alternatives[inline-graphic]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="inline-graphic or alternatives[inline-graphic]">
               <xsl:attribute name="id">inline-formula-content-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[inline-formula-content-conformance] <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> does not have a child inline-graphic element, which must be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <!--PATTERN disp-equation-alternatives-checks-pattern-->
   <!--RULE disp-equation-alternatives-checks-->
   <xsl:template match="alternatives[parent::disp-formula]" priority="1000" mode="M64">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="graphic and mml:math"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="graphic and mml:math">
               <xsl:attribute name="id">disp-equation-alternatives-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[disp-equation-alternatives-conformance] alternatives element within <xsl:text/>
                  <xsl:value-of select="parent::*/name()"/>
                  <xsl:text/> must have both a graphic (or numerous graphics) and mathml representation of the equation. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <!--PATTERN inline-equation-alternatives-checks-pattern-->
   <!--RULE inline-equation-alternatives-checks-->
   <xsl:template match="alternatives[parent::inline-formula]" priority="1000" mode="M65">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="inline-graphic and mml:math"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="inline-graphic and mml:math">
               <xsl:attribute name="id">inline-equation-alternatives-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[inline-equation-alternatives-conformance] alternatives element within <xsl:text/>
                  <xsl:value-of select="parent::*/name()"/>
                  <xsl:text/> must have both an inline-graphic (or numerous graphics) and mathml representation of the equation. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <!--PATTERN list-checks-pattern-->
   <!--RULE list-checks-->
   <xsl:template match="list" priority="1000" mode="M66">
      <xsl:variable name="supported-list-types" select="('bullet','simple','order','alpha-lower','alpha-upper','roman-lower','roman-upper')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@list-type=$supported-list-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@list-type=$supported-list-types">
               <xsl:attribute name="id">list-type-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[list-type-conformance] &lt;list&gt; element must have a list-type attribute with one of the supported values: <xsl:text/>
                  <xsl:value-of select="string-join($supported-list-types,'; ')"/>
                  <xsl:text/>.<xsl:text/>
                  <xsl:value-of select="if (./@list-type) then concat(' list-type ',@list-type,' is not supported.') else ()"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <!--PATTERN graphic-checks-pattern-->
   <!--RULE graphic-checks-->
   <xsl:template match="graphic|inline-graphic" priority="1000" mode="M67">
      <xsl:variable name="link" select="lower-case(@xlink:href)"/>
      <xsl:variable name="file" select="tokenize($link,'\.')[last()]"/>
      <xsl:variable name="image-file-types" select="('tif','tiff','gif','jpg','jpeg','png')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(@xlink:href)!=''">
               <xsl:attribute name="id">graphic-check-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[graphic-check-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must have an xlink:href attribute. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$file=$image-file-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$file=$image-file-types">
               <xsl:attribute name="id">graphic-check-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[graphic-check-2] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must have an xlink:href attribute that ends with an image file type extension. <xsl:text/>
                  <xsl:value-of select="if ($file!='') then $file else @xlink:href"/>
                  <xsl:text/> is not one of <xsl:text/>
                  <xsl:value-of select="string-join($image-file-types,', ')"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="contains(@mime-subtype,'tiff') and not($file=('tif','tiff'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(@mime-subtype,'tiff') and not($file=('tif','tiff'))">
            <xsl:attribute name="id">graphic-test-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[graphic-test-1] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> has tiff mime-subtype but filename does not end with '.tif' or '.tiff'. This cannot be correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@mime-subtype)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(@mime-subtype)!=''">
               <xsl:attribute name="id">graphic-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[graphic-test-2] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must have a mime-subtype attribute.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="contains(@mime-subtype,'jpeg') and not($file=('jpg','jpeg'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(@mime-subtype,'jpeg') and not($file=('jpg','jpeg'))">
            <xsl:attribute name="id">graphic-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[graphic-test-3] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> has jpeg mime-subtype but filename does not end with '.jpg' or '.jpeg'. This cannot be correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@mimetype='image'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@mimetype='image'">
               <xsl:attribute name="id">graphic-test-4</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[graphic-test-4] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must have a @mimetype='image'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="@mime-subtype='png' and $file!='png'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@mime-subtype='png' and $file!='png'">
            <xsl:attribute name="id">graphic-test-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[graphic-test-5] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> has png mime-subtype but filename does not end with '.png'. This cannot be correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="preceding::graphic/@xlink:href/lower-case(.) = $link or preceding::inline-graphic/@xlink:href/lower-case(.) = $link">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="preceding::graphic/@xlink:href/lower-case(.) = $link or preceding::inline-graphic/@xlink:href/lower-case(.) = $link">
            <xsl:attribute name="id">graphic-test-6</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[graphic-test-6] Image file for <xsl:text/>
               <xsl:value-of select="if (parent::fig/label) then parent::fig/label else 'graphic'"/>
               <xsl:text/> (<xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>) is the same as the one used for another graphic or inline-graphic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@mime-subtype='gif' and $file!='gif'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@mime-subtype='gif' and $file!='gif'">
            <xsl:attribute name="id">graphic-test-7</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[graphic-test-7] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> has gif mime-subtype but filename does not end with '.gif'. This cannot be correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <!--PATTERN media-checks-pattern-->
   <!--RULE media-checks-->
   <xsl:template match="media" priority="1000" mode="M68">
      <xsl:variable name="link" select="@xlink:href"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,15}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'\.[\p{L}\p{N}]{1,15}$')">
               <xsl:attribute name="id">media-test-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[media-test-3] media must have an @xlink:href which contains a file reference.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="preceding::media/@xlink:href = $link">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="preceding::media/@xlink:href = $link">
            <xsl:attribute name="id">media-test-10</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[media-test-10] Media file for <xsl:text/>
               <xsl:value-of select="if (parent::*/label) then parent::*/label else 'media'"/>
               <xsl:text/> (<xsl:text/>
               <xsl:value-of select="$link"/>
               <xsl:text/>) is the same as the one used for <xsl:text/>
               <xsl:value-of select="if (preceding::media[@xlink:href=$link][1]/parent::*/label) then preceding::media[@xlink:href=$link][1]/parent::*/label         else 'another file'"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="text()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="text()">
            <xsl:attribute name="id">media-test-12</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[media-test-12] Media element cannot contain text. This one has <xsl:text/>
               <xsl:value-of select="string-join(text(),'')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="*">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
            <xsl:attribute name="id">media-test-13</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[media-test-13] Media element cannot contain child elements. This one has the following element(s) <xsl:text/>
               <xsl:value-of select="string-join(*/name(),'; ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M68"/>
   <xsl:template match="@*|node()" priority="-2" mode="M68">
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <!--PATTERN sec-checks-pattern-->
   <!--RULE sec-checks-->
   <xsl:template match="sec" priority="1000" mode="M69">

		<!--REPORT warning-->
      <xsl:if test="@sec-type='supplementary-material' and *[not(name()=('label','title','supplementary-material'))]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@sec-type='supplementary-material' and *[not(name()=('label','title','supplementary-material'))]">
            <xsl:attribute name="id">sec-supplementary-material</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[sec-supplementary-material] &lt;sec sec-type='supplementary-material'&gt; contains elements other than supplementary-material: <xsl:text/>
               <xsl:value-of select="string-join(*[not(name()=('label','title','supplementary-material'))]/name(),'; ')"/>
               <xsl:text/>. These will currently be stripped from the content rendered on EPP. Should they be moved out of the section or is that OK?'</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="*[not(name()=('label','title','sec-meta'))]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*[not(name()=('label','title','sec-meta'))]">
               <xsl:attribute name="id">sec-empty</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[sec-empty] sec element is not populated with any content. Either there's a mistake or the section should be removed.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <!--PATTERN title-checks-pattern-->
   <!--RULE title-checks-->
   <xsl:template match="title" priority="1000" mode="M70">

		<!--REPORT warning-->
      <xsl:if test="upper-case(.)=.">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="upper-case(.)=.">
            <xsl:attribute name="id">title-upper-case</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[title-upper-case] Content of &lt;title&gt; element is entirely in upper case: Is that correct? '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="lower-case(.)=.">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="lower-case(.)=.">
            <xsl:attribute name="id">title-lower-case</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[title-lower-case] Content of &lt;title&gt; element is entirely in lower-case case: Is that correct? '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <!--PATTERN title-toc-checks-pattern-->
   <!--RULE title-toc-checks-->
   <xsl:template match="article/body/sec/title|article/back/sec/title" priority="1000" mode="M71">

		<!--REPORT error-->
      <xsl:if test="xref">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="xref">
            <xsl:attribute name="id">toc-title-contains-citation</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[toc-title-contains-citation] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains a citation and will appear within the table of contents on EPP. This will cause images not to load. Please either remove the citaiton or make it plain text.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M71"/>
   <xsl:template match="@*|node()" priority="-2" mode="M71">
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <!--PATTERN p-bold-checks-pattern-->
   <!--RULE p-bold-checks-->
   <xsl:template match="p[not(ancestor::sub-article) and (count(*)=1) and (child::bold or child::italic)]" priority="1000" mode="M72">
      <xsl:variable name="free-text" select="replace(normalize-space(string-join(for $x in self::*/text() return $x,'')),' ','')"/>
      <!--REPORT warning-->
      <xsl:if test="$free-text=''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$free-text=''">
            <xsl:attribute name="id">p-all-bold</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[p-all-bold] Content of p element is entirely in <xsl:text/>
               <xsl:value-of select="child::*[1]/local-name()"/>
               <xsl:text/> - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M72"/>
   <xsl:template match="@*|node()" priority="-2" mode="M72">
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <!--PATTERN general-article-meta-checks-pattern-->
   <!--RULE general-article-meta-checks-->
   <xsl:template match="article/front/article-meta" priority="1000" mode="M73">
      <xsl:variable name="is-reviewed-preprint" select="parent::front/journal-meta/lower-case(journal-id[1])='elife'"/>
      <xsl:variable name="distinct-emails" select="distinct-values((descendant::contrib[@contrib-type='author']/email, author-notes/corresp/email))"/>
      <xsl:variable name="distinct-email-count" select="count($distinct-emails)"/>
      <xsl:variable name="corresp-authors" select="distinct-values(for $name in descendant::contrib[@contrib-type='author' and @corresp='yes']/name[1] return e:get-name($name))"/>
      <xsl:variable name="corresp-author-count" select="count($corresp-authors)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-id[@pub-id-type='doi']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-id[@pub-id-type='doi']">
               <xsl:attribute name="id">article-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-id] article-meta must contain at least one DOI - a &lt;article-id pub-id-type="doi"&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT info-->
      <xsl:if test="article-version[not(@article-version-type)] or article-version-alternatives/article-version[@article-version-type='preprint-version']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-version[not(@article-version-type)] or article-version-alternatives/article-version[@article-version-type='preprint-version']">
            <xsl:attribute name="id">article-version-flag</xsl:attribute>
            <xsl:attribute name="role">info</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-flag] This is preprint version <xsl:text/>
               <xsl:value-of select="if (article-version-alternatives/article-version[@article-version-type='preprint-version']) then article-version-alternatives/article-version[@article-version-type='preprint-version'] else article-version[not(@article-version-type)]"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="not($is-reviewed-preprint) and not(count(article-version)=1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($is-reviewed-preprint) and not(count(article-version)=1)">
            <xsl:attribute name="id">article-version-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-1] article-meta in preprints must contain one (and only one) &lt;article-version&gt; element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-reviewed-preprint and not(count(article-version-alternatives)=1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-reviewed-preprint and not(count(article-version-alternatives)=1)">
            <xsl:attribute name="id">article-version-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-3] article-meta in reviewed preprints must contain one (and only one) &lt;article-version-alternatives&gt; element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(contrib-group)=(1,2)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib-group)=(1,2)">
               <xsl:attribute name="id">article-contrib-group</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-contrib-group] article-meta must contain either one or two &lt;contrib-group&gt; elements. This one contains <xsl:text/>
                  <xsl:value-of select="count(contrib-group)"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="(descendant::contrib[@contrib-type='author' and email]) or (descendant::contrib[@contrib-type='author']/xref[@ref-type='corresp']/@rid=./author-notes/corresp/@id)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(descendant::contrib[@contrib-type='author' and email]) or (descendant::contrib[@contrib-type='author']/xref[@ref-type='corresp']/@rid=./author-notes/corresp/@id)">
               <xsl:attribute name="id">article-no-emails</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-no-emails] This preprint has no emails for corresponding authors, which must be incorrect.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$corresp-author-count=$distinct-email-count"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$corresp-author-count=$distinct-email-count">
               <xsl:attribute name="id">article-email-corresp-author-count-equivalence</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-email-corresp-author-count-equivalence] The number of corresponding authors (<xsl:text/>
                  <xsl:value-of select="$corresp-author-count"/>
                  <xsl:text/>: <xsl:text/>
                  <xsl:value-of select="string-join($corresp-authors,'; ')"/>
                  <xsl:text/>) is not equal to the number of distinct email addresses (<xsl:text/>
                  <xsl:value-of select="$distinct-email-count"/>
                  <xsl:text/>: <xsl:text/>
                  <xsl:value-of select="string-join($distinct-emails,'; ')"/>
                  <xsl:text/>). Is this correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="$corresp-author-count=$distinct-email-count and author-notes/corresp">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$corresp-author-count=$distinct-email-count and author-notes/corresp">
            <xsl:attribute name="id">article-corresp</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-corresp] The number of corresponding authors and distinct emails is the same, but a match between them has been unable to be made. As its stands the corresp will display on EPP: <xsl:text/>
               <xsl:value-of select="author-notes/corresp"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='publisher-id'])=1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='publisher-id'])=1)">
            <xsl:attribute name="id">article-id-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-id-1] Reviewed preprints must have one (and only one) publisher-id. This one has <xsl:text/>
               <xsl:value-of select="count(article-id[@pub-id-type='publisher-id'])"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='doi'])=2)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-reviewed-preprint and not(count(article-id[@pub-id-type='doi'])=2)">
            <xsl:attribute name="id">article-id-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-id-2] Reviewed preprints must have two DOIs. This one has <xsl:text/>
               <xsl:value-of select="count(article-id[@pub-id-type='doi'])"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-reviewed-preprint and not(count(volume)=1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-reviewed-preprint and not(count(volume)=1)">
            <xsl:attribute name="id">volume-presence</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[volume-presence] Reviewed preprints must have (and only one) volume. This one has <xsl:text/>
               <xsl:value-of select="count(volume)"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-reviewed-preprint and not(count(elocation-id)=1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-reviewed-preprint and not(count(elocation-id)=1)">
            <xsl:attribute name="id">elocation-id-presence</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[elocation-id-presence] Reviewed preprints must have (and only one) elocation-id. This one has <xsl:text/>
               <xsl:value-of select="count(elocation-id)"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-reviewed-preprint and not(count(history)=1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-reviewed-preprint and not(count(history)=1)">
            <xsl:attribute name="id">history-presence</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[history-presence] Reviewed preprints must have (and only one) history. This one has <xsl:text/>
               <xsl:value-of select="count(history)"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-reviewed-preprint and not(count(pub-history)=1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-reviewed-preprint and not(count(pub-history)=1)">
            <xsl:attribute name="id">pub-history-presence</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-history-presence] Reviewed preprints must have (and only one) pub-history. This one has <xsl:text/>
               <xsl:value-of select="count(pub-history)"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M73"/>
   <xsl:template match="@*|node()" priority="-2" mode="M73">
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <!--PATTERN general-article-id-checks-pattern-->
   <!--RULE general-article-id-checks-->
   <xsl:template match="article/front/article-meta/article-id" priority="1000" mode="M74">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type=('publisher-id','doi')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@pub-id-type=('publisher-id','doi')">
               <xsl:attribute name="id">article-id-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-id-3] article-id must have a pub-id-type with a value of 'publisher-id' or 'doi'. This one has <xsl:text/>
                  <xsl:value-of select="if (@publisher-id) then @publisher-id else 'no publisher-id attribute'"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <!--PATTERN publisher-article-id-checks-pattern-->
   <!--RULE publisher-article-id-checks-->
   <xsl:template match="article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='publisher-id']" priority="1000" mode="M75">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^1?\d{5}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^1?\d{5}$')">
               <xsl:attribute name="id">publisher-id-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[publisher-id-1] article-id with the attribute pub-id-type="publisher-id" must contain the 5 or 6 digit manuscript tracking number. This one contains <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <!--PATTERN article-dois-pattern-->
   <!--RULE article-dois-->
   <xsl:template match="article/front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M76">
      <xsl:variable name="article-id" select="parent::article-meta[1]/article-id[@pub-id-type='publisher-id'][1]"/>
      <xsl:variable name="latest-rp-doi" select="parent::article-meta/pub-history/event[position()=last()]/self-uri[@content-type='reviewed-preprint']/@xlink:href"/>
      <xsl:variable name="latest-rp-doi-version" select="if ($latest-rp-doi) then replace($latest-rp-doi,'^.*\.','')                                                else '0'"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(.,'10.7554/eLife.')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="starts-with(.,'10.7554/eLife.')">
               <xsl:attribute name="id">prc-article-dois-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[prc-article-dois-1] Article level DOI must start with '10.7554/eLife.'. Currently it is <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="not(@specific-use) and substring-after(.,'10.7554/eLife.') != $article-id">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@specific-use) and substring-after(.,'10.7554/eLife.') != $article-id">
            <xsl:attribute name="id">prc-article-dois-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[prc-article-dois-2] Article level concept DOI must be a concatenation of '10.7554/eLife.' and the article-id. Currently it is <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@specific-use and not(contains(.,$article-id))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use and not(contains(.,$article-id))">
            <xsl:attribute name="id">prc-article-dois-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[prc-article-dois-3] Article level specific version DOI must contain the article-id (<xsl:text/>
               <xsl:value-of select="$article-id"/>
               <xsl:text/>). Currently it does not <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@specific-use and not(matches(.,'^10.7554/eLife\.\d{5,6}\.\d$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use and not(matches(.,'^10.7554/eLife\.\d{5,6}\.\d$'))">
            <xsl:attribute name="id">prc-article-dois-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[prc-article-dois-4] Article level specific version DOI must be in the format 10.7554/eLife.00000.0. Currently it is <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="not(@specific-use) and (preceding-sibling::article-id[@pub-id-type='doi'] or following-sibling::article-id[@pub-id-type='doi' and not(@specific-use)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@specific-use) and (preceding-sibling::article-id[@pub-id-type='doi'] or following-sibling::article-id[@pub-id-type='doi' and not(@specific-use)])">
            <xsl:attribute name="id">prc-article-dois-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[prc-article-dois-5] Article level concept DOI must be first in article-meta, and there can only be one. This concept DOI has a preceding DOI or following concept DOI.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@specific-use and (following-sibling::article-id[@pub-id-type='doi'] or preceding-sibling::article-id[@pub-id-type='doi' and @specific-use])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use and (following-sibling::article-id[@pub-id-type='doi'] or preceding-sibling::article-id[@pub-id-type='doi' and @specific-use])">
            <xsl:attribute name="id">prc-article-dois-6</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[prc-article-dois-6] Article level version DOI must be second in article-meta. This version DOI has a following sibling DOI or a preceding version specific DOI.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@specific-use and @specific-use!='version'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use and @specific-use!='version'">
            <xsl:attribute name="id">prc-article-dois-7</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[prc-article-dois-7] Article DOI has a specific-use attribute value <xsl:text/>
               <xsl:value-of select="@specific-use"/>
               <xsl:text/>. The only permitted value is 'version'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@specific-use and number(substring-after(.,concat($article-id,'.'))) != (number($latest-rp-doi-version)+1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@specific-use and number(substring-after(.,concat($article-id,'.'))) != (number($latest-rp-doi-version)+1)">
            <xsl:attribute name="id">final-prc-article-dois-8</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[final-prc-article-dois-8] The version DOI for this Reviewed preprint version needs to end with a number that is one more than whatever number the last published reviewed preprint version DOI ends with. This version DOI ends with <xsl:text/>
               <xsl:value-of select="substring-after(.,concat($article-id,'.'))"/>
               <xsl:text/> (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>), whereas <xsl:text/>
               <xsl:value-of select="if ($latest-rp-doi-version='0') then 'there is no previous reviewed preprint version in the pub-history' else concat('the latest reviewed preprint DOI in the publication history ends with ',$latest-rp-doi-version,' (',$latest-rp-doi,')')"/>
               <xsl:text/>. Either there is a missing reviewed preprint publication event in the publication history, or the version DOI is incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <!--PATTERN author-notes-checks-pattern-->
   <!--RULE author-notes-checks-->
   <xsl:template match="article/front/article-meta/author-notes" priority="1000" mode="M77">

		<!--REPORT error-->
      <xsl:if test="count(corresp) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(corresp) gt 1">
            <xsl:attribute name="id">multiple-corresp</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[multiple-corresp] author-notes contains <xsl:text/>
               <xsl:value-of select="count(corresp)"/>
               <xsl:text/> corresp elements. There should only be one. Either these can be collated into one corresp or one of these is a footnote which has been incorrectly captured.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <!--PATTERN author-notes-fn-checks-pattern-->
   <!--RULE author-notes-fn-checks-->
   <xsl:template match="article/front/article-meta/author-notes/fn" priority="1000" mode="M78">
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="known-types" select="('abbr','con','coi-statement','deceased','equal','financial-disclosure','presented-at','present-address','supported-by')"/>
      <!--REPORT error-->
      <xsl:if test="@fn-type='present-address' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@fn-type='present-address' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)">
            <xsl:attribute name="id">author-fn-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-fn-1] Present address type footnote (id=<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>) in author-notes is not linked to from any specific author, which must be a mistake. "<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@fn-type='equal' and (count(ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id]) lt 2)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@fn-type='equal' and (count(ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id]) lt 2)">
            <xsl:attribute name="id">author-fn-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-fn-2] Equal author type footnote (id=<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>) in author-notes is linked to from <xsl:text/>
               <xsl:value-of select="count(ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id])"/>
               <xsl:text/> author(s), which must be a mistake. "<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@fn-type='deceased' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@fn-type='deceased' and not(ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)">
            <xsl:attribute name="id">author-fn-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-fn-3] Deceased type footnote (id=<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>) in author-notes is not linked to from any specific author, which must be a mistake. "<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="@fn-type=('abbr','con','coi-statement','financial-disclosure','presented-at','supported-by') and (ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@fn-type=('abbr','con','coi-statement','financial-disclosure','presented-at','supported-by') and (ancestor::article-meta//contrib[@contrib-type='author']/xref/@rid = $id)">
            <xsl:attribute name="id">author-fn-4</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-fn-4] <xsl:text/>
               <xsl:value-of select="@fn-type"/>
               <xsl:text/> type footnote (id=<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>) in author-notes usually contains content that relates to all authors instead of a subset. This one however is linked to from <xsl:text/>
               <xsl:value-of select="ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id]"/>
               <xsl:text/> author(s) (<xsl:text/>
               <xsl:value-of select="string-join(for $x in ancestor::article-meta//contrib[@contrib-type='author'][xref/@rid = $id] return e:get-name($x/name[1]),'; ')"/>
               <xsl:text/>). "<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="@fn-type and not(@fn-type=$known-types)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@fn-type and not(@fn-type=$known-types)">
            <xsl:attribute name="id">author-fn-5</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[author-fn-5] footnote with id <xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/> has the fn-type '<xsl:text/>
               <xsl:value-of select="@fn-type"/>
               <xsl:text/>' which is not one of the known values (<xsl:text/>
               <xsl:value-of select="string-join($known-types,'; ')"/>
               <xsl:text/>). Should it be changed to be one of the values? "<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <!--PATTERN article-version-checks-pattern-->
   <!--RULE article-version-checks-->
   <xsl:template match="article/front/article-meta//article-version" priority="1000" mode="M79">

		<!--REPORT error-->
      <xsl:if test="parent::article-meta and not(@article-version-type) and not(matches(.,'^1\.\d+$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::article-meta and not(@article-version-type) and not(matches(.,'^1\.\d+$'))">
            <xsl:attribute name="id">article-version-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-2] article-version must be in the format 1.x (e.g. 1.11). This one is '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="parent::article-version-alternatives and not(@article-version-type=('publication-state','preprint-version'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::article-version-alternatives and not(@article-version-type=('publication-state','preprint-version'))">
            <xsl:attribute name="id">article-version-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-4] article-version placed within article-meta-alternatives must have an article-version-type attribute with either the value 'publication-state' or 'preprint-version'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@article-version-type='preprint-version' and not(matches(.,'^1\.\d+$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@article-version-type='preprint-version' and not(matches(.,'^1\.\d+$'))">
            <xsl:attribute name="id">article-version-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-5] article-version with the attribute article-version-type="preprint-version" must contain text in the format 1.x (e.g. 1.11). This one has '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@article-version-type='publication-state' and .!='reviewed preprint'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@article-version-type='publication-state' and .!='reviewed preprint'">
            <xsl:attribute name="id">article-version-6</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-6] article-version with the attribute article-version-type="publication-state" must contain the text 'reviewed preprint'. This one has '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="./@article-version-type = preceding-sibling::article-version/@article-version-type">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@article-version-type = preceding-sibling::article-version/@article-version-type">
            <xsl:attribute name="id">article-version-7</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-7] article-version must be distinct. There is one or more article-version elements with the article-version-type <xsl:text/>
               <xsl:value-of select="@article-version-type"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@*[name()!='article-version-type']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@*[name()!='article-version-type']">
            <xsl:attribute name="id">article-version-11</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[article-version-11] The only attribute permitted on <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> is article-version-type. This one has the following unallowed attribute(s): <xsl:text/>
               <xsl:value-of select="string-join(@*[name()!='article-version-type']/name(),'; ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <!--PATTERN article-version-alternatives-checks-pattern-->
   <!--RULE article-version-alternatives-checks-->
   <xsl:template match="article/front/article-meta/article-version-alternatives" priority="1000" mode="M80">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-version)=2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-version)=2">
               <xsl:attribute name="id">article-version-8</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-version-8] article-version-alternatives must contain 2 and only 2 article-version elements. This one has '<xsl:text/>
                  <xsl:value-of select="count(article-version)"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-version[@article-version-type='preprint-version']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-version[@article-version-type='preprint-version']">
               <xsl:attribute name="id">article-version-9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-version-9] article-version-alternatives must contain a &lt;article-version article-version-type="preprint-version"&gt;.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="article-version[@article-version-type='publication-state']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="article-version[@article-version-type='publication-state']">
               <xsl:attribute name="id">article-version-10</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-version-10] article-version-alternatives must contain a &lt;article-version article-version-type="publication-state"&gt;.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <!--PATTERN rp-and-preprint-version-checks-pattern-->
   <!--RULE rp-and-preprint-version-checks-->
   <xsl:template match="article/front[journal-meta/journal-id='elife']/article-meta[matches(replace(article-id[@specific-use='version'][1],'^.*\.',''),'^\d\d?$') and matches(descendant::article-version[@article-version-type='preprint-version'][1],'^1\.\d+$')]" priority="1000" mode="M81">
      <xsl:variable name="preprint-version" select="number(substring-after(descendant::article-version[@article-version-type='preprint-version'][1],'.'))"/>
      <xsl:variable name="rp-version" select="number(replace(article-id[@specific-use='version'][1],'^.*\.',''))"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$rp-version le $preprint-version"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$rp-version le $preprint-version">
               <xsl:attribute name="id">article-version-12</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-version-12] This is Reviewed Preprint version <xsl:text/>
                  <xsl:value-of select="$rp-version"/>
                  <xsl:text/>, but according to the article-version, it's based on preprint version <xsl:text/>
                  <xsl:value-of select="$preprint-version"/>
                  <xsl:text/>. This cannot be correct.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M81"/>
   <xsl:template match="@*|node()" priority="-2" mode="M81">
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <!--PATTERN preprint-pub-checks-pattern-->
   <!--RULE preprint-pub-checks-->
   <xsl:template match="article/front/article-meta/pub-date[@pub-type='epub']/year" priority="1000" mode="M82">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test=".=('2024','2025')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".=('2024','2025')">
               <xsl:attribute name="id">preprint-pub-date-1</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[preprint-pub-date-1] This preprint version was posted in <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>. Is it the correct version that corresponds to the version submitted to eLife?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M82"/>
   <xsl:template match="@*|node()" priority="-2" mode="M82">
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <!--PATTERN contrib-checks-pattern-->
   <!--RULE contrib-checks-->
   <xsl:template match="article/front/article-meta/contrib-group/contrib" priority="1000" mode="M83">

		<!--REPORT error-->
      <xsl:if test="parent::contrib-group[not(preceding-sibling::contrib-group)] and @contrib-type!='author'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::contrib-group[not(preceding-sibling::contrib-group)] and @contrib-type!='author'">
            <xsl:attribute name="id">contrib-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[contrib-1] Contrib with the type '<xsl:text/>
               <xsl:value-of select="@contrib-type"/>
               <xsl:text/>' is present in author contrib-group (the first contrib-group within article-meta). This is not correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="parent::contrib-group[not(preceding-sibling::contrib-group)] and not(@contrib-type)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::contrib-group[not(preceding-sibling::contrib-group)] and not(@contrib-type)">
            <xsl:attribute name="id">contrib-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[contrib-2] Contrib without the attribute contrib-type="author" is present in author contrib-group (the first contrib-group within article-meta). This is not correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type)">
            <xsl:attribute name="id">contrib-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[contrib-3] The second contrib-group in article-meta should (only) contain Reviewing and Senior Editors. This contrib is placed in that group, but it does not have a contrib-type. Add the correct contrib-type for the Editor.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type=('editor','senior_editor'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::contrib-group[preceding-sibling::contrib-group and not(following-sibling::contrib-group)] and not(@contrib-type=('editor','senior_editor'))">
            <xsl:attribute name="id">contrib-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[contrib-4] The second contrib-group in article-meta should (only) contain Reviewing and Senior Editors. This contrib is placed in that group, but it has the contrib-type <xsl:text/>
               <xsl:value-of select="@contrib-type"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M83"/>
   <xsl:template match="@*|node()" priority="-2" mode="M83">
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <!--PATTERN volume-test-pattern-->
   <!--RULE volume-test-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/volume" priority="1000" mode="M84">
      <xsl:variable name="is-first-version" select="if (ancestor::article-meta/article-id[@specific-use='version' and ends-with(.,'.1')]) then true()                                           else if (not(ancestor::article-meta/pub-history[event[date[@date-type='reviewed-preprint']]])) then true()                                           else false()"/>
      <xsl:variable name="pub-date" select=" if (not($is-first-version)) then parent::article-meta/pub-history[1]/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]          else if (ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic']) then ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic'][1]/year[1]          else string(year-from-date(current-date()))"/>
      <!--REPORT error-->
      <xsl:if test=".='' or (. != (number($pub-date) - 2011))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".='' or (. != (number($pub-date) - 2011))">
            <xsl:attribute name="id">volume-test-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[volume-test-1] volume is incorrect. It should be <xsl:text/>
               <xsl:value-of select="number($pub-date) - 2011"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M84"/>
   <xsl:template match="@*|node()" priority="-2" mode="M84">
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <!--PATTERN elocation-id-test-pattern-->
   <!--RULE elocation-id-test-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/elocation-id" priority="1000" mode="M85">
      <xsl:variable name="msid" select="parent::article-meta/article-id[@pub-id-type='publisher-id']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^RP\d{5,6}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^RP\d{5,6}$')">
               <xsl:attribute name="id">elocation-id-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[elocation-id-test-1] The content of elocation-id must 'RP' followed by a 5 or 6 digit MSID. This is not in that format: <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="$msid and not(.=concat('RP',$msid))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$msid and not(.=concat('RP',$msid))">
            <xsl:attribute name="id">elocation-id-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[elocation-id-test-2] The content of elocation-id must 'RP' followed by the 5 or 6 digit MSID (<xsl:text/>
               <xsl:value-of select="$msid"/>
               <xsl:text/>). This is not in that format (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/> != <xsl:text/>
               <xsl:value-of select="concat('RP',$msid)"/>
               <xsl:text/>).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M85"/>
   <xsl:template match="@*|node()" priority="-2" mode="M85">
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <!--PATTERN history-tests-pattern-->
   <!--RULE history-tests-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']/article-meta/history" priority="1000" mode="M86">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(date[@date-type='sent-for-review']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(date[@date-type='sent-for-review']) = 1">
               <xsl:attribute name="id">prc-history-date-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[prc-history-date-test-1] history must contain one (and only one) date[@date-type='sent-for-review'] in Reviewed preprints.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="date[@date-type!='sent-for-review' or not(@date-type)]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="date[@date-type!='sent-for-review' or not(@date-type)]">
            <xsl:attribute name="id">prc-history-date-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[prc-history-date-test-2] Reviewed preprints can only have sent-for-review dates in their history. This one has a <xsl:text/>
               <xsl:value-of select="if (date[@date-type!='sent-for-review']) then date[@date-type!='sent-for-review']/@date-type else 'undefined'"/>
               <xsl:text/> date.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M86"/>
   <xsl:template match="@*|node()" priority="-2" mode="M86">
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <!--PATTERN pub-history-tests-pattern-->
   <!--RULE pub-history-tests-->
   <xsl:template match="article[front[journal-meta/lower-case(journal-id[1])='elife']]//pub-history" priority="1000" mode="M87">
      <xsl:variable name="version-from-doi" select="replace(ancestor::article-meta[1]/article-id[@pub-id-type='doi' and @specific-use='version'][1],'^.*\.','')"/>
      <xsl:variable name="is-revised-rp" select="if ($version-from-doi=('','1')) then false() else true()"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="parent::article-meta"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::article-meta">
               <xsl:attribute name="id">pub-history-parent</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[pub-history-parent] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> is only allowed to be captured as a child of article-meta. This one is a child of <xsl:text/>
                  <xsl:value-of select="parent::*/name()"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(event) ge 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(event) ge 1">
               <xsl:attribute name="id">pub-history-events-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[pub-history-events-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in Reviewed Preprints must have at least one event element. This one has <xsl:text/>
                  <xsl:value-of select="count(event)"/>
                  <xsl:text/> event elements.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="count(event[self-uri[@content-type='preprint']]) != 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(event[self-uri[@content-type='preprint']]) != 1">
            <xsl:attribute name="id">pub-history-events-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-history-events-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> must contain one, and only one preprint event (an event with a self-uri[@content-type='preprint'] element). This one has <xsl:text/>
               <xsl:value-of select="count(event[self-uri[@content-type='preprint']])"/>
               <xsl:text/> preprint event elements.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$is-revised-rp and (count(event[self-uri[@content-type='reviewed-preprint']]) != (number($version-from-doi) - 1))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$is-revised-rp and (count(event[self-uri[@content-type='reviewed-preprint']]) != (number($version-from-doi) - 1))">
            <xsl:attribute name="id">pub-history-events-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-history-events-3] The <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> for revised reviewed preprints must have one event (with a self-uri[@content-type='reviewed-preprint'] element) element for each of the previous reviewed preprint versions. There are <xsl:text/>
               <xsl:value-of select="count(event[self-uri[@content-type='reviewed-preprint']])"/>
               <xsl:text/> reviewed preprint publication events in pub-history,. but since this is reviewed preprint version <xsl:text/>
               <xsl:value-of select="$version-from-doi"/>
               <xsl:text/> there should be <xsl:text/>
               <xsl:value-of select="number($version-from-doi) - 1"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="count(event[self-uri[@content-type='reviewed-preprint']]) gt 3">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(event[self-uri[@content-type='reviewed-preprint']]) gt 3">
            <xsl:attribute name="id">pub-history-events-4</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[pub-history-events-4] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> has <xsl:text/>
               <xsl:value-of select="count(event[self-uri[@content-type='reviewed-preprint']])"/>
               <xsl:text/> reviewed preprint event elements, which is unusual. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M87"/>
   <xsl:template match="@*|node()" priority="-2" mode="M87">
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <!--PATTERN event-tests-pattern-->
   <!--RULE event-tests-->
   <xsl:template match="event" priority="1000" mode="M88">
      <xsl:variable name="date" select="date[1]/@iso-8601-date"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="event-desc"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="event-desc">
               <xsl:attribute name="id">event-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-test-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must contain an event-desc element. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="date[@date-type=('preprint','reviewed-preprint')]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="date[@date-type=('preprint','reviewed-preprint')]">
               <xsl:attribute name="id">event-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-test-2] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must contain a date element with the attribute date-type="preprint" or date-type="reviewed-preprint". This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="self-uri"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="self-uri">
               <xsl:attribute name="id">event-test-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-test-3] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must contain a self-uri element. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="following-sibling::event[date[@iso-8601-date lt $date]]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="following-sibling::event[date[@iso-8601-date lt $date]]">
            <xsl:attribute name="id">event-test-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-test-4] Events in pub-history must be ordered chronologically in descending order. This event has a date (<xsl:text/>
               <xsl:value-of select="$date"/>
               <xsl:text/>) which is later than the date of a following event (<xsl:text/>
               <xsl:value-of select="preceding-sibling::event[date[@iso-8601-date lt $date]][1]"/>
               <xsl:text/>).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="date and self-uri and date[1]/@date-type != self-uri[1]/@content-type">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="date and self-uri and date[1]/@date-type != self-uri[1]/@content-type">
            <xsl:attribute name="id">event-test-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-test-5] This event in pub-history has a date with the date-type <xsl:text/>
               <xsl:value-of select="date[1]/@date-type"/>
               <xsl:text/>, but a self-uri with the content-type <xsl:text/>
               <xsl:value-of select="self-uri[1]/@content-type"/>
               <xsl:text/>. These values should be the same, so one (or both of them) are incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M88"/>
   <xsl:template match="@*|node()" priority="-2" mode="M88">
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <!--PATTERN event-child-tests-pattern-->
   <!--RULE event-child-tests-->
   <xsl:template match="event/*" priority="1000" mode="M89">
      <xsl:variable name="allowed-elems" select="('event-desc','date','self-uri')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name()=$allowed-elems"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()=$allowed-elems">
               <xsl:attribute name="id">event-child</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-child] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> is not allowed in an event element. The only permitted children of event are <xsl:text/>
                  <xsl:value-of select="string-join($allowed-elems,', ')"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M89"/>
   <xsl:template match="@*|node()" priority="-2" mode="M89">
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <!--PATTERN rp-event-tests-pattern-->
   <!--RULE rp-event-tests-->
   <xsl:template match="event[date[@date-type='reviewed-preprint']/@iso-8601-date != '']" priority="1000" mode="M90">
      <xsl:variable name="rp-link" select="self-uri[@content-type='reviewed-preprint']/@xlink:href"/>
      <xsl:variable name="rp-version" select="replace($rp-link,'^.*\.','')"/>
      <xsl:variable name="rp-pub-date" select="date[@date-type='reviewed-preprint']/@iso-8601-date"/>
      <xsl:variable name="sent-for-review-date" select="ancestor::article-meta/history/date[@date-type='sent-for-review']/@iso-8601-date"/>
      <xsl:variable name="preprint-pub-date" select="parent::pub-history/event/date[@date-type='preprint']/@iso-8601-date"/>
      <xsl:variable name="later-rp-events" select="parent::pub-history/event[date[@date-type='reviewed-preprint'] and replace(self-uri[@content-type='reviewed-preprint'][1]/@xlink:href,'^.*\.','') gt $rp-version]"/>
      <!--REPORT error-->
      <xsl:if test="($preprint-pub-date and $preprint-pub-date != '') and         $preprint-pub-date ge $rp-pub-date">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($preprint-pub-date and $preprint-pub-date != '') and $preprint-pub-date ge $rp-pub-date">
            <xsl:attribute name="id">rp-event-test-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[rp-event-test-1] Reviewed preprint publication date (<xsl:text/>
               <xsl:value-of select="$rp-pub-date"/>
               <xsl:text/>) in the publication history (for RP version <xsl:text/>
               <xsl:value-of select="$rp-version"/>
               <xsl:text/>) is the same or an earlier date than the preprint posted date (<xsl:text/>
               <xsl:value-of select="$preprint-pub-date"/>
               <xsl:text/>), which must be incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="($sent-for-review-date and $sent-for-review-date != '') and         $sent-for-review-date ge $rp-pub-date">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($sent-for-review-date and $sent-for-review-date != '') and $sent-for-review-date ge $rp-pub-date">
            <xsl:attribute name="id">rp-event-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[rp-event-test-2] Reviewed preprint publication date (<xsl:text/>
               <xsl:value-of select="$rp-pub-date"/>
               <xsl:text/>) in the publication history (for RP version <xsl:text/>
               <xsl:value-of select="$rp-version"/>
               <xsl:text/>) is the same or an earlier date than the sent for review date (<xsl:text/>
               <xsl:value-of select="$sent-for-review-date"/>
               <xsl:text/>), which must be incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$later-rp-events/date/@iso-8601-date = $rp-pub-date">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$later-rp-events/date/@iso-8601-date = $rp-pub-date">
            <xsl:attribute name="id">rp-event-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[rp-event-test-3] Reviewed preprint publication date (<xsl:text/>
               <xsl:value-of select="$rp-pub-date"/>
               <xsl:text/>) in the publication history (for RP version <xsl:text/>
               <xsl:value-of select="$rp-version"/>
               <xsl:text/>) is the same or an earlier date than publication date for a later reviewed preprint version date (<xsl:text/>
               <xsl:value-of select="$later-rp-events/date/@iso-8601-date[. = $rp-pub-date]"/>
               <xsl:text/> for version(s) <xsl:text/>
               <xsl:value-of select="$later-rp-events/self-uri[@content-type='reviewed-preprint'][1]/@xlink:href/replace(.,'^.*\.','')"/>
               <xsl:text/>). This must be incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="self-uri[@content-type='editor-report']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="self-uri[@content-type='editor-report']">
               <xsl:attribute name="id">rp-event-test-4</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[rp-event-test-4] The event-desc for Reviewed preprint publication events must have a &lt;self-uri content-type="editor-report"&gt; (which has a DOI link to the eLife Assessment for that version).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="self-uri[@content-type='referee-report']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="self-uri[@content-type='referee-report']">
               <xsl:attribute name="id">rp-event-test-5</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[rp-event-test-5] The event-desc for Reviewed preprint publication events must have at least one &lt;self-uri content-type="referee-report"&gt; (which has a DOI link to a public review for that version).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M90"/>
   <xsl:template match="@*|node()" priority="-2" mode="M90">
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <!--PATTERN event-desc-tests-pattern-->
   <!--RULE event-desc-tests-->
   <xsl:template match="event-desc" priority="1000" mode="M91">

		<!--REPORT error-->
      <xsl:if test="parent::event/self-uri[1][@content-type='preprint'] and .!='Preprint posted'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::event/self-uri[1][@content-type='preprint'] and .!='Preprint posted'">
            <xsl:attribute name="id">event-desc-content</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-desc-content] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> that's a child of a preprint event must contain the text 'Preprint posted'. This one does not (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="parent::event/self-uri[1][@content-type='reviewed-preprint'] and .!=concat('Reviewed preprint v',replace(parent::event[1]/self-uri[1][@content-type='reviewed-preprint']/@xlink:href,'^.*\.',''))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::event/self-uri[1][@content-type='reviewed-preprint'] and .!=concat('Reviewed preprint v',replace(parent::event[1]/self-uri[1][@content-type='reviewed-preprint']/@xlink:href,'^.*\.',''))">
            <xsl:attribute name="id">event-desc-content-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-desc-content-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> that's a child of a Reviewed preprint event must contain the text 'Reviewed preprint v' followwd by the verison number for that Reviewed preprint version. This one does not (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/> != <xsl:text/>
               <xsl:value-of select="concat('Reviewed preprint v',replace(parent::event[1]/self-uri[1][@content-type='reviewed-preprint']/@xlink:href,'^.*\.',''))"/>
               <xsl:text/>).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="*">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
            <xsl:attribute name="id">event-desc-elems</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-desc-elems] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> cannot contain elements. This one has the following: <xsl:text/>
               <xsl:value-of select="string-join(distinct-values(*/name()),', ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M91"/>
   <xsl:template match="@*|node()" priority="-2" mode="M91">
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <!--PATTERN event-date-tests-pattern-->
   <!--RULE event-date-tests-->
   <xsl:template match="event/date" priority="1000" mode="M92">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="day and month and year"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="day and month and year">
               <xsl:attribute name="id">event-date-child</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-date-child] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in event must have a day, month and year element. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@date-type=('preprint','reviewed-preprint')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@date-type=('preprint','reviewed-preprint')">
               <xsl:attribute name="id">event-date-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-date-type] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in event must have a date-type attribute with the value 'preprint' or 'reviewed-preprint'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M92"/>
   <xsl:template match="@*|node()" priority="-2" mode="M92">
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <!--PATTERN event-self-uri-tests-pattern-->
   <!--RULE event-self-uri-tests-->
   <xsl:template match="event/self-uri" priority="1000" mode="M93">
      <xsl:variable name="article-id" select="ancestor::article-meta/article-id[@pub-id-type='publisher-id']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@content-type=('preprint','reviewed-preprint','editor-report','referee-report','author-comment')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type=('preprint','reviewed-preprint','editor-report','referee-report','author-comment')">
               <xsl:attribute name="id">event-self-uri-content-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-self-uri-content-type] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in event must have the attribute content-type="preprint" or content-type="reviewed-preprint". This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="@content-type=('preprint','reviewed-preprint') and (* or normalize-space(.)!='')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type=('preprint','reviewed-preprint') and (* or normalize-space(.)!='')">
            <xsl:attribute name="id">event-self-uri-content-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-content-1] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> with the content-type <xsl:text/>
               <xsl:value-of select="@content-type"/>
               <xsl:text/> must not have any child elements or text. This one does.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@content-type='editor-report' and (* or not(matches(.,'^eLife [Aa]ssessment$')))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type='editor-report' and (* or not(matches(.,'^eLife [Aa]ssessment$')))">
            <xsl:attribute name="id">event-self-uri-content-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-content-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> with the content-type <xsl:text/>
               <xsl:value-of select="@content-type"/>
               <xsl:text/> must not have any child elements, and contain the text 'eLife Assessment'. This one does not.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@content-type='referee-report' and (* or .='')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type='referee-report' and (* or .='')">
            <xsl:attribute name="id">event-self-uri-content-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-content-3] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> with the content-type <xsl:text/>
               <xsl:value-of select="@content-type"/>
               <xsl:text/> must not have any child elements, and contain the title of the public review as text. This self-uri either has child elements or it is empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@content-type='author-comment' and (* or not(matches(.,'^Author [Rr]esponse:?\s?$')))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type='author-comment' and (* or not(matches(.,'^Author [Rr]esponse:?\s?$')))">
            <xsl:attribute name="id">event-self-uri-content-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-content-4] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> with the content-type <xsl:text/>
               <xsl:value-of select="@content-type"/>
               <xsl:text/> must not have any child elements, and contain the title of the text 'Author response'. This one does not.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;&lt;&gt;//=]*)$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{2,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;&lt;&gt;//=]*)$')">
               <xsl:attribute name="id">event-self-uri-href-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-self-uri-href-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in event must have an xlink:href attribute containing a link to the preprint. This one does not have a valid URI - <xsl:text/>
                  <xsl:value-of select="@xlink:href"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="matches(lower-case(@xlink:href),'(bio|med)rxiv')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(@xlink:href),'(bio|med)rxiv')">
            <xsl:attribute name="id">event-self-uri-href-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-href-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. bioRxiv and medRxiv preprint have dois, and this one points to one of those, but it is not a doi - <xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="matches(@xlink:href,'https?://(dx.doi.org|doi.org)/')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'https?://(dx.doi.org|doi.org)/')">
               <xsl:attribute name="id">event-self-uri-href-3</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[event-self-uri-href-3] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> in event must have an xlink:href attribute containing a link to the preprint. Where possible this should be a doi. This one is not a doi - <xsl:text/>
                  <xsl:value-of select="@xlink:href"/>
                  <xsl:text/>. Please check whether there is a doi that can be used instead.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="@content-type='reviewed-preprint' and not(matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type='reviewed-preprint' and not(matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]$'))">
            <xsl:attribute name="id">event-self-uri-href-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-href-4] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in event has the attribute content-type="reviewed-preprint", but the xlink:href attribute does not contain an eLife version specific DOI - <xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="(@content-type!='reviewed-preprint' or not(@content-type)) and matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.\d$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(@content-type!='reviewed-preprint' or not(@content-type)) and matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.\d$')">
            <xsl:attribute name="id">event-self-uri-href-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-href-5] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in event does not have the attribute content-type="reviewed-preprint", but the xlink:href attribute contains an eLife version specific DOI - <xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>. If it's a preprint event, the link should be to a preprint. If it's an event for reviewed preprint publication, then it should have the attribute content-type!='reviewed-preprint'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@content-type='reviewed-preprint' and not(contains(@xlink:href,$article-id))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type='reviewed-preprint' and not(contains(@xlink:href,$article-id))">
            <xsl:attribute name="id">event-self-uri-href-6</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-href-6] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in event the attribute content-type="reviewed-preprint", but the xlink:href attribute value (<xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>) does not contain the article id (<xsl:text/>
               <xsl:value-of select="$article-id"/>
               <xsl:text/>) which must be incorrect, since this should be the version DOI for the reviewed preprint version.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@content-type=('editor-report','referee-report','author-comment') and not(matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]\.sa\d+$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@content-type=('editor-report','referee-report','author-comment') and not(matches(@xlink:href,'^https://doi.org/10.7554/eLife.\d+\.[1-9]\.sa\d+$'))">
            <xsl:attribute name="id">event-self-uri-href-7</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[event-self-uri-href-7] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> in event has the attribute content-type="<xsl:text/>
               <xsl:value-of select="@content-type"/>
               <xsl:text/>", but the xlink:href attribute does not contain an eLife peer review DOI - <xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M93"/>
   <xsl:template match="@*|node()" priority="-2" mode="M93">
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <!--PATTERN abstract-checks-pattern-->
   <!--RULE abstract-checks-->
   <xsl:template match="abstract[parent::article-meta]" priority="1000" mode="M94">
      <xsl:variable name="allowed-types" select="('structured','plain-language-summary','teaser','summary','graphical')"/>
      <!--REPORT error-->
      <xsl:if test="preceding::abstract[not(@abstract-type) and not(@xml:lang)] and not(@abstract-type) and not(@xml:lang)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="preceding::abstract[not(@abstract-type) and not(@xml:lang)] and not(@abstract-type) and not(@xml:lang)">
            <xsl:attribute name="id">abstract-test-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[abstract-test-1] There should only be one abstract without an abstract-type attribute (for the common-garden abstract) or xml:lang attirbute (for common-garden abstract in a language other than english). This asbtract does not have an abstract-type, but there is also a preceding abstract without an abstract-type or xml:lang. One of these needs to be given an abstract-type with the allowed values ('structured' for a syrctured abstract with sections; 'plain-language-summary' for a digest or author provided plain summary; 'teaser' for an impact statement; 'summary' for a general summary that's in addition to the common-garden abstract; 'graphical' for a graphical abstract).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="@abstract-type and not(@abstract-type=$allowed-types)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@abstract-type and not(@abstract-type=$allowed-types)">
            <xsl:attribute name="id">abstract-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[abstract-test-2] abstract has an abstract-type (<xsl:text/>
               <xsl:value-of select="@abstract-type"/>
               <xsl:text/>), but it's not one of the permiited values: <xsl:text/>
               <xsl:value-of select="string-join($allowed-types,'; ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(lower-case(title[1]),'funding')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(title[1]),'funding')">
            <xsl:attribute name="id">abstract-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[abstract-test-3] abstract has a title that indicates it contains funding information (<xsl:text/>
               <xsl:value-of select="title[1]"/>
               <xsl:text/>) If this is funding information, it should be captured as a section in back or as part of an (if existing) structured abstract.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(lower-case(title[1]),'data')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(title[1]),'data')">
            <xsl:attribute name="id">abstract-test-4</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[abstract-test-4] abstract has a title that indicates it contains a data availability statement (<xsl:text/>
               <xsl:value-of select="title[1]"/>
               <xsl:text/>) If this is a data availability statement, it should be captured as a section in back.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="descendant::fig and not(@abstract-type='graphical')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="descendant::fig and not(@abstract-type='graphical')">
            <xsl:attribute name="id">abstract-test-5</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[abstract-test-5] abstract has a descendant fig, but it does not have the attribute abstract-type="graphical". If it is a graphical abstract, it should have that type. If it's not a graphical abstract the content should be moved out of &lt;abstract&gt;</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="@abstract-type=$allowed-types and ./@abstract-type = preceding-sibling::abstract/@abstract-type">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@abstract-type=$allowed-types and ./@abstract-type = preceding-sibling::abstract/@abstract-type">
            <xsl:attribute name="id">abstract-test-6</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[abstract-test-6] abstract has the abstract-type '<xsl:text/>
               <xsl:value-of select="@abstract-type"/>
               <xsl:text/>', which is a permitted value, but it is not the only abstract with that type. It is very unlikely that two abstracts with the same abstract-type are required.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M94"/>
   <xsl:template match="@*|node()" priority="-2" mode="M94">
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <!--PATTERN abstract-child-checks-pattern-->
   <!--RULE abstract-child-checks-->
   <xsl:template match="abstract[parent::article-meta]/*" priority="1000" mode="M95">
      <xsl:variable name="allowed-children" select="('label','title','sec','p','fig','list')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="name()=$allowed-children"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name()=$allowed-children">
               <xsl:attribute name="id">abstract-child-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[abstract-child-test-1] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> is not permitted within abstract.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M95"/>
   <xsl:template match="@*|node()" priority="-2" mode="M95">
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <!--PATTERN abstract-lang-checks-pattern-->
   <!--RULE abstract-lang-checks-->
   <xsl:template match="abstract[@xml:lang]" priority="1000" mode="M96">
      <xsl:variable name="xml-lang-value" select="@xml:lang"/>
      <xsl:variable name="languages" select="'languages.xml'"/>
      <xsl:variable name="subtag-description" select="string-join(document($languages)//*:item[@subtag=$xml-lang-value]/*:description,' / ')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$subtag-description!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$subtag-description!=''">
               <xsl:attribute name="id">abstract-lang-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[abstract-lang-test-1] The xml:lang attribute on <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> must contain one of the IETF RFC 5646 subtags. '<xsl:text/>
                  <xsl:value-of select="@xml:lang"/>
                  <xsl:text/>' is not one of these values.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="$subtag-description!=''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$subtag-description!=''">
            <xsl:attribute name="id">abstract-lang-test-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[abstract-lang-test-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> has an xml:lang attribute with the value '<xsl:text/>
               <xsl:value-of select="$xml-lang-value"/>
               <xsl:text/>', which corresponds to the following language: <xsl:text/>
               <xsl:value-of select="$subtag-description"/>
               <xsl:text/>. Please check this is correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M96"/>
   <xsl:template match="@*|node()" priority="-2" mode="M96">
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <!--PATTERN front-permissions-tests-pattern-->
   <!--RULE front-permissions-tests-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']//permissions" priority="1000" mode="M97">
      <xsl:variable name="author-contrib-group" select="ancestor::article-meta/contrib-group[1]"/>
      <xsl:variable name="copyright-holder" select="e:get-copyright-holder($author-contrib-group)"/>
      <xsl:variable name="license-type" select="license/@xlink:href"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="ali:free_to_read"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ali:free_to_read">
               <xsl:attribute name="id">permissions-test-4</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-4</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-4] permissions must contain an ali:free_to_read element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="license"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="license">
               <xsl:attribute name="id">permissions-test-5</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-5] permissions must contain license.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$license-type = ('http://creativecommons.org/publicdomain/zero/1.0/', 'https://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by/4.0/')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$license-type = ('http://creativecommons.org/publicdomain/zero/1.0/', 'https://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/licenses/by/4.0/', 'https://creativecommons.org/licenses/by/4.0/')">
               <xsl:attribute name="id">permissions-test-9</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-9] license does not have an @xlink:href which is equal to 'https://creativecommons.org/publicdomain/zero/1.0/' or 'https://creativecommons.org/licenses/by/4.0/'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT info-->
      <xsl:if test="license">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="license">
            <xsl:attribute name="id">permissions-info</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-info</xsl:attribute>
            <xsl:attribute name="role">info</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[permissions-info] This article is licensed under a<xsl:text/>
               <xsl:value-of select="      if (contains($license-type,'publicdomain/zero')) then ' CC0 1.0'      else if (contains($license-type,'by/4.0')) then ' CC BY 4.0'      else if (contains($license-type,'by/3.0')) then ' CC BY 3.0'      else 'n unknown'"/>
               <xsl:text/> license. <xsl:text/>
               <xsl:value-of select="$license-type"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M97"/>
   <xsl:template match="@*|node()" priority="-2" mode="M97">
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <!--PATTERN cc-by-permissions-tests-pattern-->
   <!--RULE cc-by-permissions-tests-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/licenses/by/')]" priority="1000" mode="M98">
      <xsl:variable name="author-contrib-group" select="ancestor::article-meta/contrib-group[1]"/>
      <xsl:variable name="copyright-holder" select="e:get-copyright-holder($author-contrib-group)"/>
      <xsl:variable name="license-type" select="license/@xlink:href"/>
      <xsl:variable name="is-first-version" select="if (ancestor::article-meta/article-id[@specific-use='version' and ends-with(.,'.1')]) then true()                                           else if (not(ancestor::article-meta/pub-history[event[date[@date-type='reviewed-preprint']]])) then true()                                           else false()"/>
      <xsl:variable name="authoritative-year" select="if (not($is-first-version)) then ancestor::article-meta/pub-history/event[date[@date-type='reviewed-preprint']][1]/date[@date-type='reviewed-preprint'][1]/year[1]         else if (ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic']) then ancestor::article-meta/pub-date[@date-type='publication' and @publication-format='electronic']/year         else string(year-from-date(current-date()))"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="copyright-statement"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-statement">
               <xsl:attribute name="id">permissions-test-1</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-1] permissions must contain copyright-statement in CC BY licensed articles.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(copyright-year[1],'^[0-9]{4}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(copyright-year[1],'^[0-9]{4}$')">
               <xsl:attribute name="id">permissions-test-2</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-2] permissions must contain copyright-year in the format 0000 in CC BY licensed articles. Currently it is <xsl:text/>
                  <xsl:value-of select="copyright-year"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="copyright-holder"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-holder">
               <xsl:attribute name="id">permissions-test-3</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-3] permissions must contain copyright-holder in CC BY licensed articles.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="copyright-year = $authoritative-year"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-year = $authoritative-year">
               <xsl:attribute name="id">permissions-test-6</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-6</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-6] copyright-year must match the year of first reviewed preprint publication date. Currently copyright-year=<xsl:text/>
                  <xsl:value-of select="copyright-year"/>
                  <xsl:text/> and authoritative pub-date=<xsl:text/>
                  <xsl:value-of select="$authoritative-year"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="copyright-holder = $copyright-holder"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-holder = $copyright-holder">
               <xsl:attribute name="id">permissions-test-7</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-7</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-7] copyright-holder is incorrect. If the article has one author then it should be their surname (or collab name). If it has two authors it should be the surname (or collab name) of the first, then ' &amp; ' and then the surname (or collab name) of the second. If three or more, it should be the surname (or collab name) of the first, and then ' et al'. Currently it's '<xsl:text/>
                  <xsl:value-of select="copyright-holder"/>
                  <xsl:text/>' when based on the author list it should be '<xsl:text/>
                  <xsl:value-of select="$copyright-holder"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="copyright-statement = concat('© ',copyright-year,', ',copyright-holder)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-statement = concat('© ',copyright-year,', ',copyright-holder)">
               <xsl:attribute name="id">permissions-test-8</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#permissions-test-8</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[permissions-test-8] copyright-statement must contain a concatenation of '© ', copyright-year, and copyright-holder. Currently it is <xsl:text/>
                  <xsl:value-of select="copyright-statement"/>
                  <xsl:text/> when according to the other values it should be <xsl:text/>
                  <xsl:value-of select="concat('© ',copyright-year,', ',copyright-holder)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')]">
            <xsl:attribute name="id">permissions-test-16</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#hztjj-permissions-test-16</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[permissions-test-16] This article is CC-BY, but one or more of the authors are affiliated with the NIH (<xsl:text/>
               <xsl:value-of select="string-join(for $x in ancestor::article-meta/contrib-group[1]/aff[country='United States']//institution[matches(lower-case(.),'national institutes of health|office of the director|national cancer institute|^nci$|national eye institute|^nei$|national heart,? lung,? and blood institute|^nhlbi$|national human genome research institute|^nhgri$|national institute on aging|^nia$|national institute on alcohol abuse and alcoholism|^niaaa$|national institute of allergy and infectious diseases|^niaid$|national institute of arthritis and musculoskeletal and skin diseases|^niams$|national institute of biomedical imaging and bioengineering|^nibib$|national institute of child health and human development|^nichd$|national institute on deafness and other communication disorders|^nidcd$|national institute of dental and craniofacial research|^nidcr$|national institute of diabetes and digestive and kidney diseases|^niddk$|national institute on drug abuse|^nida$|national institute of environmental health sciences|^niehs$|national institute of general medical sciences|^nigms$|national institute of mental health|^nimh$|national institute on minority health and health disparities|^nimhd$|national institute of neurological disorders and stroke|^ninds$|national institute of nursing research|^ninr$|national library of medicine|^nlm$|center for information technology|^cit$|center for scientific review|^csr$|fogarty international center|^fic$|national center for advancing translational sciences|^ncats$|national center for complementary and integrative health|^nccih$|nih clinical center|^nih cc$')] return $x,'; ')"/>
               <xsl:text/>). Should it be CC0 instead?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M98"/>
   <xsl:template match="@*|node()" priority="-2" mode="M98">
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <!--PATTERN cc-0-permissions-tests-pattern-->
   <!--RULE cc-0-permissions-tests-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']//permissions[contains(license[1]/@xlink:href,'creativecommons.org/publicdomain/zero')]" priority="1000" mode="M99">
      <xsl:variable name="license-type" select="license/@xlink:href"/>
      <!--REPORT error-->
      <xsl:if test="copyright-statement">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-statement">
            <xsl:attribute name="id">cc-0-test-1</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[cc-0-test-1] This is a CC0 licensed article (<xsl:text/>
               <xsl:value-of select="$license-type"/>
               <xsl:text/>), but there is a copyright-statement (<xsl:text/>
               <xsl:value-of select="copyright-statement"/>
               <xsl:text/>) which is not correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="copyright-year">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-year">
            <xsl:attribute name="id">cc-0-test-2</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[cc-0-test-2] This is a CC0 licensed article (<xsl:text/>
               <xsl:value-of select="$license-type"/>
               <xsl:text/>), but there is a copyright-year (<xsl:text/>
               <xsl:value-of select="copyright-year"/>
               <xsl:text/>) which is not correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="copyright-holder">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="copyright-holder">
            <xsl:attribute name="id">cc-0-test-3</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#cc-0-test-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[cc-0-test-3] This is a CC0 licensed article (<xsl:text/>
               <xsl:value-of select="$license-type"/>
               <xsl:text/>), but there is a copyright-holder (<xsl:text/>
               <xsl:value-of select="copyright-holder"/>
               <xsl:text/>) which is not correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M99"/>
   <xsl:template match="@*|node()" priority="-2" mode="M99">
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <!--PATTERN license-tests-pattern-->
   <!--RULE license-tests-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license" priority="1000" mode="M100">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="ali:license_ref"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ali:license_ref">
               <xsl:attribute name="id">license-test-1</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[license-test-1] license must contain ali:license_ref.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(license-p) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(license-p) = 1">
               <xsl:attribute name="id">license-test-2</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#license-test-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[license-test-2] license must contain one and only one license-p.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M100"/>
   <xsl:template match="@*|node()" priority="-2" mode="M100">
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <!--PATTERN license-p-tests-pattern-->
   <!--RULE license-p-tests-->
   <xsl:template match="front[journal-meta/lower-case(journal-id[1])='elife']//permissions/license/license-p" priority="1000" mode="M101">
      <xsl:variable name="license-link" select="parent::license/@xlink:href"/>
      <xsl:variable name="license-type" select="if (contains($license-link,'//creativecommons.org/publicdomain/zero/1.0/')) then 'cc0' else if (contains($license-link,'//creativecommons.org/licenses/by/4.0/')) then 'ccby' else ('unknown')"/>
      <xsl:variable name="cc0-text" select="'This is an open-access article, free of all copyright, and may be freely reproduced, distributed, transmitted, modified, built upon, or otherwise used by anyone for any lawful purpose. The work is made available under the Creative Commons CC0 public domain dedication.'"/>
      <xsl:variable name="ccby-text" select="'This article is distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use and redistribution provided that the original author and source are credited.'"/>
      <!--REPORT error-->
      <xsl:if test="($license-type='ccby') and .!=$ccby-text">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($license-type='ccby') and .!=$ccby-text">
            <xsl:attribute name="id">license-p-test-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[license-p-test-1] The text in license-p is incorrect (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>). Since this article is CCBY licensed, the text should be <xsl:text/>
               <xsl:value-of select="$ccby-text"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="($license-type='cc0') and .!=$cc0-text">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($license-type='cc0') and .!=$cc0-text">
            <xsl:attribute name="id">license-p-test-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[license-p-test-2] The text in license-p is incorrect (<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>). Since this article is CC0 licensed, the text should be <xsl:text/>
               <xsl:value-of select="$cc0-text"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M101"/>
   <xsl:template match="@*|node()" priority="-2" mode="M101">
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <!--PATTERN license-link-tests-pattern-->
   <!--RULE license-link-tests-->
   <xsl:template match="permissions/license[@xlink:href]/license-p" priority="1000" mode="M102">
      <xsl:variable name="license-link" select="parent::license/@xlink:href"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="some $x in ext-link satisfies $x/@xlink:href = $license-link"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="some $x in ext-link satisfies $x/@xlink:href = $license-link">
               <xsl:attribute name="id">license-p-test-3</xsl:attribute>
               <xsl:attribute name="see">https://elifeproduction.slab.com/posts/house-style-yi0641ob#hx30h-p-test-3</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[license-p-test-3] If a license element has an xlink:href attribute, there must be a link in license-p that matches the link in the license/@xlink:href attribute. License link: <xsl:text/>
                  <xsl:value-of select="$license-link"/>
                  <xsl:text/>. Links in the license-p: <xsl:text/>
                  <xsl:value-of select="string-join(ext-link/@xlink:href,'; ')"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M102"/>
   <xsl:template match="@*|node()" priority="-2" mode="M102">
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <!--PATTERN license-ali-ref-link-tests-pattern-->
   <!--RULE license-ali-ref-link-tests-->
   <xsl:template match="permissions/license[ali:license_ref]/license-p" priority="1000" mode="M103">
      <xsl:variable name="ali-ref" select="parent::license/ali:license_ref"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="some $x in ext-link satisfies $x/@xlink:href = $ali-ref"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="some $x in ext-link satisfies $x/@xlink:href = $ali-ref">
               <xsl:attribute name="id">license-p-test-4</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[license-p-test-4] If a license contains an ali:license_ref element, there must be a link in license-p that matches the link in the ali:license_ref element. ali:license_ref link: <xsl:text/>
                  <xsl:value-of select="$ali-ref"/>
                  <xsl:text/>. Links in the license-p: <xsl:text/>
                  <xsl:value-of select="string-join(ext-link/@xlink:href,'; ')"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M103"/>
   <xsl:template match="@*|node()" priority="-2" mode="M103">
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>
   <!--PATTERN fig-permissions-check-pattern-->
   <!--RULE fig-permissions-check-->
   <xsl:template match="fig[not(descendant::permissions)]|media[@mimetype='video' and not(descendant::permissions)]|table-wrap[not(descendant::permissions)]|supplementary-material[not(descendant::permissions)]" priority="1000" mode="M104">
      <xsl:variable name="label" select="replace(label[1],'\.','')"/>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Rr]eproduced from')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Rr]eproduced from')">
            <xsl:attribute name="id">reproduce-test-1</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-1] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'reproduced from', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Rr]eproduced [Ww]ith [Pp]ermission')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Rr]eproduced [Ww]ith [Pp]ermission')">
            <xsl:attribute name="id">reproduce-test-2</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-2] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'reproduced with permission', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Aa]dapted from|[Aa]dapted with')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Aa]dapted from|[Aa]dapted with')">
            <xsl:attribute name="id">reproduce-test-3</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-3</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-3] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'adapted from ...', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Rr]eprinted from')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Rr]eprinted from')">
            <xsl:attribute name="id">reproduce-test-4</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-4</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-4] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'reprinted from', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Rr]eprinted [Ww]ith [Pp]ermission')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Rr]eprinted [Ww]ith [Pp]ermission')">
            <xsl:attribute name="id">reproduce-test-5</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-5</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-5] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'reprinted with permission', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Mm]odified from')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Mm]odified from')">
            <xsl:attribute name="id">reproduce-test-6</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-6</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-6] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'modified from', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Mm]odified [Ww]ith')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Mm]odified [Ww]ith')">
            <xsl:attribute name="id">reproduce-test-7</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-7</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-7] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'modified with', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(caption[1],'[Uu]sed [Ww]ith [Pp]ermission')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(caption[1],'[Uu]sed [Ww]ith [Pp]ermission')">
            <xsl:attribute name="id">reproduce-test-8</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/licensing-and-copyright-rqdavyty#reproduce-test-8</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[reproduce-test-8] The caption for <xsl:text/>
               <xsl:value-of select="$label"/>
               <xsl:text/> contains the text 'used with permission', but has no permissions. Is this correct?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M104"/>
   <xsl:template match="@*|node()" priority="-2" mode="M104">
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>
   <!--PATTERN digest-title-checks-pattern-->
   <!--RULE digest-title-checks-->
   <xsl:template match="title" priority="1000" mode="M105">

		<!--REPORT error-->
      <xsl:if test="matches(lower-case(.),'^\s*(elife\s)?digest\s*$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),'^\s*(elife\s)?digest\s*$')">
            <xsl:attribute name="id">digest-flag</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[digest-flag] <xsl:text/>
               <xsl:value-of select="parent::*/name()"/>
               <xsl:text/> element has a title containing 'digest' - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>. If this is referring to an plain language summary written by the authors it should be renamed to plain language summary (or similar) in order to not suggest to readers this was written by the features team.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M105"/>
   <xsl:template match="@*|node()" priority="-2" mode="M105">
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <!--PATTERN preformat-checks-pattern-->
   <!--RULE preformat-checks-->
   <xsl:template match="preformat" priority="1000" mode="M106">

		<!--REPORT warning-->
      <xsl:if test=".">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".">
            <xsl:attribute name="id">preformat-flag</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[preformat-flag] Please check whether the content in this preformat element has been captured crrectly (and is rendered approriately).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M106"/>
   <xsl:template match="@*|node()" priority="-2" mode="M106">
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <!--PATTERN code-checks-pattern-->
   <!--RULE code-checks-->
   <xsl:template match="code" priority="1000" mode="M107">

		<!--REPORT warning-->
      <xsl:if test=".">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".">
            <xsl:attribute name="id">code-flag</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[code-flag] Please check whether the content in this code element has been captured crrectly (and is rendered approriately).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M107"/>
   <xsl:template match="@*|node()" priority="-2" mode="M107">
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <!--PATTERN uri-checks-pattern-->
   <!--RULE uri-checks-->
   <xsl:template match="uri" priority="1000" mode="M108">

		<!--REPORT error-->
      <xsl:if test=".">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".">
            <xsl:attribute name="id">uri-flag</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[uri-flag] The uri element is not permitted. Instead use ext-link with the attribute link-type="uri".</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M108"/>
   <xsl:template match="@*|node()" priority="-2" mode="M108">
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <!--PATTERN xref-checks-pattern-->
   <!--RULE xref-checks-->
   <xsl:template match="xref" priority="1000" mode="M109">
      <xsl:variable name="allowed-attributes" select="('ref-type','rid')"/>
      <!--REPORT warning-->
      <xsl:if test="@*[not(name()=$allowed-attributes)]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@*[not(name()=$allowed-attributes)]">
            <xsl:attribute name="id">xref-attributes</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[xref-attributes] This xref element has the following attribute(s) which are not supported: <xsl:text/>
               <xsl:value-of select="string-join(@*[not(name()=$allowed-attributes)]/name(),'; ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="parent::xref">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="parent::xref">
            <xsl:attribute name="id">xref-parent</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[xref-parent] This xref element containing '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>' is a child of another xref. Nested xrefs are not supported - it must be either stripped or moved so that it is a child of another element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M109"/>
   <xsl:template match="@*|node()" priority="-2" mode="M109">
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <!--PATTERN ext-link-tests-pattern-->
   <!--RULE ext-link-tests-->
   <xsl:template match="ext-link[@ext-link-type='uri']" priority="1000" mode="M110">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)\[\]+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)\[\]+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')">
               <xsl:attribute name="id">url-conformance-test</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[url-conformance-test] @xlink:href doesn't look like a URL - '<xsl:text/>
                  <xsl:value-of select="@xlink:href"/>
                  <xsl:text/>'. Is this correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="matches(@xlink:href,'^(ftp|sftp)://\S+:\S+@')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'^(ftp|sftp)://\S+:\S+@')">
            <xsl:attribute name="id">ftp-credentials-flag</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ftp-credentials-flag] @xlink:href contains what looks like a link to an FTP site which contains credentials (username and password) - '<xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>'. If the link without credentials works (<xsl:text/>
               <xsl:value-of select="concat(substring-before(@xlink:href,'://'),'://',substring-after(@xlink:href,'@'))"/>
               <xsl:text/>), then please replace it with that.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(@xlink:href,'\.$')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'\.$')">
            <xsl:attribute name="id">url-fullstop-report</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#htqb8-url-fullstop-report</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[url-fullstop-report] '<xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>' - Link ends in a full stop which is incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(@xlink:href,'[\p{Zs}]')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'[\p{Zs}]')">
            <xsl:attribute name="id">url-space-report</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hjtq3-url-space-report</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[url-space-report] '<xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>' - Link contains a space which is incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="(.!=@xlink:href) and matches(.,'https?:|ftp:')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(.!=@xlink:href) and matches(.,'https?:|ftp:')">
            <xsl:attribute name="id">ext-link-text</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/general-layout-and-formatting-wq0m31at#hyyhg-ext-link-text</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ext-link-text] The text for a URL is '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>' (which looks like a URL), but it is not the same as the actual embedded link, which is '<xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="matches(@xlink:href,'^https?://(dx\.)?doi\.org/[^1][^0]?')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'^https?://(dx\.)?doi\.org/[^1][^0]?')">
            <xsl:attribute name="id">ext-link-doi-check</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ext-link-doi-check] Embedded URL within text starts with the DOI prefix, but it is not a valid doi - <xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="not(ancestor::fig/permissions[contains(.,'phylopic')]) and matches(@xlink:href,'phylopic\.org')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(ancestor::fig/permissions[contains(.,'phylopic')]) and matches(@xlink:href,'phylopic\.org')">
            <xsl:attribute name="id">phylopic-link-check</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[phylopic-link-check] This link is to phylopic.org, which is a site where silhouettes/images are typically reproduced from. Please check whether any figures contain reproduced images from this site, and if so whether permissions have been obtained and/or copyright statements are correctly included.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="contains(@xlink:href,'datadryad.org/review?')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(@xlink:href,'datadryad.org/review?')">
            <xsl:attribute name="id">ext-link-child-test-5</xsl:attribute>
            <xsl:attribute name="see">https://elifeproduction.slab.com/posts/data-availability-qi8vg0qp#ext-link-child-test-5</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ext-link-child-test-5] ext-link looks like it points to a review dryad dataset - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>. Should it be updated?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="contains(@xlink:href,'paperpile.com')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(@xlink:href,'paperpile.com')">
            <xsl:attribute name="id">paper-pile-test</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[paper-pile-test] This paperpile hyperlink should be removed: '<xsl:text/>
               <xsl:value-of select="@xlink:href"/>
               <xsl:text/>' embedded in the text '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M110"/>
   <xsl:template match="@*|node()" priority="-2" mode="M110">
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <!--PATTERN ext-link-tests-2-pattern-->
   <!--RULE ext-link-tests-2-->
   <xsl:template match="ext-link" priority="1000" mode="M111">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@ext-link-type='uri'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ext-link-type='uri'">
               <xsl:attribute name="id">ext-link-type-test-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ext-link-type-test-1] ext-link must have the attribute ext-link-type="uri". This one does not. It contains the text: <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M111"/>
   <xsl:template match="@*|node()" priority="-2" mode="M111">
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>
   <!--PATTERN footnote-checks-pattern-->
   <!--RULE footnote-checks-->
   <xsl:template match="fn-group[fn]" priority="1000" mode="M112">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="ancestor::notes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ancestor::notes">
               <xsl:attribute name="id">body-footnote</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[body-footnote] This preprint has footnotes appended to the content. EPP cannot render these, so they need adding to the text.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M112"/>
   <xsl:template match="@*|node()" priority="-2" mode="M112">
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <!--PATTERN unallowed-symbol-tests-pattern-->
   <!--RULE unallowed-symbol-tests-->
   <xsl:template match="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link" priority="1000" mode="M113">

		<!--REPORT error-->
      <xsl:if test="contains(.,'�')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'�')">
            <xsl:attribute name="id">replacement-character-presence</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[replacement-character-presence] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains the replacement character '�' which is not allowed.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="contains(.,'')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'')">
            <xsl:attribute name="id">junk-character-presence</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[junk-character-presence] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains a junk character '' which should be replaced.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="contains(.,'︎')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'︎')">
            <xsl:attribute name="id">junk-character-presence-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[junk-character-presence-2] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains a junk character '︎' which should be replaced or deleted.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="contains(.,'□')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'□')">
            <xsl:attribute name="id">junk-character-presence-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[junk-character-presence-3] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains a junk character '□' which should be replaced or deleted.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="contains(.,'¿')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'¿')">
            <xsl:attribute name="id">inverterted-question-presence</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[inverterted-question-presence] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains an inverted question mark '¿' which should very likely be replaced/removed.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="some $x in self::*[not(local-name() = ('monospace','code'))]/text() satisfies matches($x,'\(\)|\[\]')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="some $x in self::*[not(local-name() = ('monospace','code'))]/text() satisfies matches($x,'\(\)|\[\]')">
            <xsl:attribute name="id">empty-parentheses-presence</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[empty-parentheses-presence] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains empty parentheses ('[]', or '()'). Is there a missing citation within the parentheses? Or perhaps this is a piece of code that needs formatting?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(.,'&amp;#x\d')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'&amp;#x\d')">
            <xsl:attribute name="id">broken-unicode-presence</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[broken-unicode-presence] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains what looks like a broken unicode - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="contains(.,'&#x9D;')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(.,'&#x9D;')">
            <xsl:attribute name="id">operating-system-command-presence</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[operating-system-command-presence] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains an operating system command character '&#x9D;' (unicode string: &amp;#x9D;) which should very likely be replaced/removed. - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="matches(lower-case(.),&quot;(^|\s)((i am|i'm) an? ai (language)? model|as an ai (language)? model,? i('m|\s)|(here is|here's) an? (possible|potential)? introduction (to|for) your topic|(here is|here's) an? (abstract|introduction|results|discussion|methods)( section)? for you|certainly(,|!)? (here is|here's)|i'm sorry,?( but)? i (don't|can't)|knowledge (extend|cutoff)|as of my last update|regenerate response)&quot;)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(lower-case(.),&quot;(^|\s)((i am|i'm) an? ai (language)? model|as an ai (language)? model,? i('m|\s)|(here is|here's) an? (possible|potential)? introduction (to|for) your topic|(here is|here's) an? (abstract|introduction|results|discussion|methods)( section)? for you|certainly(,|!)? (here is|here's)|i'm sorry,?( but)? i (don't|can't)|knowledge (extend|cutoff)|as of my last update|regenerate response)&quot;)">
            <xsl:attribute name="id">ai-response-presence-1</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ai-response-presence-1] <xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/> element contains what looks like a response from an AI chatbot after it being provided a prompt. Is that correct? Should the content be adjusted?</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M113"/>
   <xsl:template match="@*|node()" priority="-2" mode="M113">
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <!--PATTERN ed-report-front-stub-pattern-->
   <!--RULE ed-report-front-stub-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub" priority="1000" mode="M114">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="kwd-group[@kwd-group-type='evidence-strength']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="kwd-group[@kwd-group-type='evidence-strength']">
               <xsl:attribute name="id">ed-report-str-kwd-presence</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ed-report-str-kwd-presence] eLife Assessment does not have a strength keyword group. Is that correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="kwd-group[@kwd-group-type='claim-importance']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="kwd-group[@kwd-group-type='claim-importance']">
               <xsl:attribute name="id">ed-report-sig-kwd-presence</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ed-report-sig-kwd-presence] eLife Assessment does not have a significance keyword group. Is that correct?</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M114"/>
   <xsl:template match="@*|node()" priority="-2" mode="M114">
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <!--PATTERN ed-report-kwd-group-pattern-->
   <!--RULE ed-report-kwd-group-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/kwd-group" priority="1000" mode="M115">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@kwd-group-type=('claim-importance','evidence-strength')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@kwd-group-type=('claim-importance','evidence-strength')">
               <xsl:attribute name="id">ed-report-kwd-group-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ed-report-kwd-group-1] kwd-group in <xsl:text/>
                  <xsl:value-of select="parent::*/title-group/article-title"/>
                  <xsl:text/> must have the attribute kwd-group-type with the value 'claim-importance' or 'evidence-strength'. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="@kwd-group-type='claim-importance' and count(kwd) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@kwd-group-type='claim-importance' and count(kwd) gt 1">
            <xsl:attribute name="id">ed-report-kwd-group-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ed-report-kwd-group-3] <xsl:text/>
               <xsl:value-of select="@kwd-group-type"/>
               <xsl:text/> type kwd-group has <xsl:text/>
               <xsl:value-of select="count(kwd)"/>
               <xsl:text/> keywords: <xsl:text/>
               <xsl:value-of select="string-join(kwd,'; ')"/>
               <xsl:text/>. This is not permitted, please check which single importance keyword should be used.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="@kwd-group-type='evidence-strength' and count(kwd) gt 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@kwd-group-type='evidence-strength' and count(kwd) gt 1">
            <xsl:attribute name="id">ed-report-kwd-group-2</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ed-report-kwd-group-2] <xsl:text/>
               <xsl:value-of select="@kwd-group-type"/>
               <xsl:text/> type kwd-group has <xsl:text/>
               <xsl:value-of select="count(kwd)"/>
               <xsl:text/> keywords: <xsl:text/>
               <xsl:value-of select="string-join(kwd,'; ')"/>
               <xsl:text/>. This is unusual, please check this is correct.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M115"/>
   <xsl:template match="@*|node()" priority="-2" mode="M115">
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>
   <!--PATTERN ed-report-kwds-pattern-->
   <!--RULE ed-report-kwds-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/kwd-group/kwd" priority="1000" mode="M116">

		<!--REPORT error-->
      <xsl:if test="preceding-sibling::kwd = .">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="preceding-sibling::kwd = .">
            <xsl:attribute name="id">ed-report-kwd-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ed-report-kwd-1] Keyword contains <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>, there is another kwd with that value witin the same kwd-group, so this one is either incorrect or superfluous and should be deleted.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="some $x in ancestor::sub-article[1]/body/p//bold satisfies contains(lower-case($x),lower-case(.))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="some $x in ancestor::sub-article[1]/body/p//bold satisfies contains(lower-case($x),lower-case(.))">
               <xsl:attribute name="id">ed-report-kwd-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ed-report-kwd-2] Keyword contains <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>, but this term is not bolded in the text of the <xsl:text/>
                  <xsl:value-of select="ancestor::front-stub/title-group/article-title"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="*">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="*">
            <xsl:attribute name="id">ed-report-kwd-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ed-report-kwd-3] Keywords in <xsl:text/>
               <xsl:value-of select="ancestor::front-stub/title-group/article-title"/>
               <xsl:text/> cannot contain elements, only text. This one has: <xsl:text/>
               <xsl:value-of select="string-join(distinct-values(*/name()),'; ')"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M116"/>
   <xsl:template match="@*|node()" priority="-2" mode="M116">
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <!--PATTERN ed-report-claim-kwds-pattern-->
   <!--RULE ed-report-claim-kwds-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='claim-importance']/kwd" priority="1000" mode="M117">
      <xsl:variable name="allowed-vals" select="('Landmark', 'Fundamental', 'Important', 'Valuable', 'Useful')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=".=$allowed-vals"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".=$allowed-vals">
               <xsl:attribute name="id">ed-report-claim-kwd-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ed-report-claim-kwd-1] Keyword contains <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>, but it is in a 'claim-importance' keyword group, meaning it should have one of the following values: <xsl:text/>
                  <xsl:value-of select="string-join($allowed-vals,', ')"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M117"/>
   <xsl:template match="@*|node()" priority="-2" mode="M117">
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <!--PATTERN ed-report-evidence-kwds-pattern-->
   <!--RULE ed-report-evidence-kwds-->
   <xsl:template match="sub-article[@article-type='editor-report']/front-stub/kwd-group[@kwd-group-type='evidence-strength']/kwd" priority="1000" mode="M118">
      <xsl:variable name="allowed-vals" select="('Exceptional', 'Compelling', 'Convincing', 'Solid', 'Incomplete', 'Inadequate')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=".=$allowed-vals"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=".=$allowed-vals">
               <xsl:attribute name="id">ed-report-evidence-kwd-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ed-report-evidence-kwd-1] Keyword contains <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>, but it is in a 'claim-importance' keyword group, meaning it should have one of the following values: <xsl:text/>
                  <xsl:value-of select="string-join($allowed-vals,', ')"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M118"/>
   <xsl:template match="@*|node()" priority="-2" mode="M118">
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>
   <!--PATTERN ed-report-bold-terms-pattern-->
   <!--RULE ed-report-bold-terms-->
   <xsl:template match="sub-article[@article-type='editor-report']/body/p[1]//bold" priority="1000" mode="M119">
      <xsl:variable name="str-kwds" select="('exceptional', 'compelling', 'convincing', 'convincingly', 'solid', 'incomplete', 'incompletely', 'inadequate', 'inadequately')"/>
      <xsl:variable name="sig-kwds" select="('landmark', 'fundamental', 'important', 'valuable', 'useful')"/>
      <xsl:variable name="allowed-vals" select="($str-kwds,$sig-kwds)"/>
      <xsl:variable name="normalized-kwd" select="replace(lower-case(.),'ly$','')"/>
      <xsl:variable name="title-case-kwd" select="concat(upper-case(substring($normalized-kwd,1,1)),lower-case(substring($normalized-kwd,2)))"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="lower-case(.)=$allowed-vals"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="lower-case(.)=$allowed-vals">
               <xsl:attribute name="id">ed-report-bold-terms-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ed-report-bold-terms-1] Bold phrase in eLife Assessment - <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/> - is not one of the permitted terms from the vocabulary. Should the bold formatting be removed? These are currently bolded terms <xsl:text/>
                  <xsl:value-of select="string-join($allowed-vals,', ')"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT error-->
      <xsl:if test="lower-case(.)=$allowed-vals and not($title-case-kwd=ancestor::sub-article/front-stub/kwd-group/kwd)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="lower-case(.)=$allowed-vals and not($title-case-kwd=ancestor::sub-article/front-stub/kwd-group/kwd)">
            <xsl:attribute name="id">ed-report-bold-terms-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ed-report-bold-terms-2] Bold phrase in eLife Assessment - <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/> - is one of the permitted vocabulary terms, but there's no corresponding keyword in the metadata (in a kwd-group in the front-stub).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT warning-->
      <xsl:if test="preceding-sibling::bold[replace(lower-case(.),'ly$','') = $normalized-kwd]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="preceding-sibling::bold[replace(lower-case(.),'ly$','') = $normalized-kwd]">
            <xsl:attribute name="id">ed-report-bold-terms-3</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[ed-report-bold-terms-3] There is more than one of the same <xsl:text/>
               <xsl:value-of select="if (replace(lower-case(.),'ly$','')=$str-kwds) then 'strength' else 'significance'"/>
               <xsl:text/> keywords in the assessment - <xsl:text/>
               <xsl:value-of select="$normalized-kwd"/>
               <xsl:text/>. This is very likely to be incorrect.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M119"/>
   <xsl:template match="@*|node()" priority="-2" mode="M119">
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <!--PATTERN ar-bold-checks-pattern-->
   <!--RULE ar-bold-checks-->
   <xsl:template match="sub-article[@article-type='author-comment']/body//bold[not(preceding-sibling::text() or preceding-sibling::*) and (parent::p/following-sibling::*[1]/ext-link/inline-graphic or parent::p/following-sibling::*[2]/ext-link/inline-graphic)]" priority="1000" mode="M120">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'Author response (image|table) \d\d?\.')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'Author response (image|table) \d\d?\.')">
               <xsl:attribute name="id">ar-bold-image</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ar-bold-image] The bold text in a label preceding an image in the author response must be in the format 'Author response image 1.' or 'Author response table 1.' - this one is not - <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M120"/>
   <xsl:template match="@*|node()" priority="-2" mode="M120">
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <!--PATTERN sub-article-title-checks-pattern-->
   <!--RULE sub-article-title-checks-->
   <xsl:template match="sub-article/front-stub/title-group/article-title" priority="1000" mode="M121">
      <xsl:variable name="type" select="ancestor::sub-article/@article-type"/>
      <!--REPORT error-->
      <xsl:if test="$type='editor-report' and not(matches(.,'^eLife [aA]ssessment$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$type='editor-report' and not(matches(.,'^eLife [aA]ssessment$'))">
            <xsl:attribute name="id">sub-article-title-check-1</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[sub-article-title-check-1] The title of an <xsl:text/>
               <xsl:value-of select="$type"/>
               <xsl:text/> type sub-article should be 'eLife Assessment'. This one is: <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$type='referee-report' and not(matches(.,'^Reviewer #\d\d? \([Pp]ublic [Rr]eview\):?$|^Joint [Pp]ublic [Rr]eview:?$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$type='referee-report' and not(matches(.,'^Reviewer #\d\d? \([Pp]ublic [Rr]eview\):?$|^Joint [Pp]ublic [Rr]eview:?$'))">
            <xsl:attribute name="id">sub-article-title-check-2</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[sub-article-title-check-2] The title of a <xsl:text/>
               <xsl:value-of select="$type"/>
               <xsl:text/> type sub-article should be in one of the following formats: 'Reviewer #0 (public review)' or 'Joint public review'. This one is: <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT error-->
      <xsl:if test="$type='author-comment' and not(matches(.,'^Author [Rr]esponse:?$'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$type='author-comment' and not(matches(.,'^Author [Rr]esponse:?$'))">
            <xsl:attribute name="id">sub-article-title-check-3</xsl:attribute>
            <xsl:attribute name="role">error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[sub-article-title-check-3] The title of a <xsl:text/>
               <xsl:value-of select="$type"/>
               <xsl:text/> type sub-article should be 'Author response'. This one is: <xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M121"/>
   <xsl:template match="@*|node()" priority="-2" mode="M121">
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <!--PATTERN arxiv-journal-meta-checks-pattern-->
   <!--RULE arxiv-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id[1])='arxiv']" priority="1000" mode="M122">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-id[@journal-id-type='publisher-id']='arXiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-id[@journal-id-type='publisher-id']='arXiv'">
               <xsl:attribute name="id">arxiv-journal-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[arxiv-journal-id] arXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'arXiv'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/journal-title='arXiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/journal-title='arXiv'">
               <xsl:attribute name="id">arxiv-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[arxiv-journal-title] arXiv preprints must have a &lt;journal-title&gt; element with the value 'arXiv' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='arXiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='arXiv'">
               <xsl:attribute name="id">arxiv-abbrev-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[arxiv-abbrev-journal-title] arXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'arXiv' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="issn[@pub-type='epub']='2331-8422'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="issn[@pub-type='epub']='2331-8422'">
               <xsl:attribute name="id">arxiv-issn</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[arxiv-issn] arXiv preprints must have a &lt;issn pub-type="epub"&gt; element with the value '2331-8422'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="publisher/publisher-name='Cornell University'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="publisher/publisher-name='Cornell University'">
               <xsl:attribute name="id">arxiv-publisher</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[arxiv-publisher] arXiv preprints must have a &lt;publisher-name&gt; element with the value 'Cornell University', inside a &lt;publisher&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M122"/>
   <xsl:template match="@*|node()" priority="-2" mode="M122">
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>
   <!--PATTERN arxiv-doi-checks-pattern-->
   <!--RULE arxiv-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id[1])='arxiv']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M123">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^10\.48550/arXiv\.\d{4,5}\.\d{4,5}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^10\.48550/arXiv\.\d{4,5}\.\d{4,5}$')">
               <xsl:attribute name="id">arxiv-doi-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[arxiv-doi-conformance] arXiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '10\.48550/arXiv\.\d{4,}\.\d{4,5}'. In other words, the current DOI listed is not a valid arXiv DOI: '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M123"/>
   <xsl:template match="@*|node()" priority="-2" mode="M123">
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>
   <!--PATTERN res-square-journal-meta-checks-pattern-->
   <!--RULE res-square-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id[1])='rs']" priority="1000" mode="M124">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-id[@journal-id-type='publisher-id']='RS'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-id[@journal-id-type='publisher-id']='RS'">
               <xsl:attribute name="id">res-square-journal-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[res-square-journal-id] Research Square preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'RS'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/journal-title='Research Square'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/journal-title='Research Square'">
               <xsl:attribute name="id">res-square-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[res-square-journal-title] Research Square preprints must have a &lt;journal-title&gt; element with the value 'Research Square' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='rs'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='rs'">
               <xsl:attribute name="id">res-square-abbrev-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[res-square-abbrev-journal-title] Research Square preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'rs' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="issn[@pub-type='epub']='2693-5015'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="issn[@pub-type='epub']='2693-5015'">
               <xsl:attribute name="id">res-square-issn</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[res-square-issn] Research Square preprints must have a &lt;issn pub-type="epub"&gt; element with the value '2693-5015'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="publisher/publisher-name='Research Square'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="publisher/publisher-name='Research Square'">
               <xsl:attribute name="id">res-square-publisher</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[res-square-publisher] Research Square preprints must have a &lt;publisher-name&gt; element with the value 'Research Square', inside a &lt;publisher&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M124"/>
   <xsl:template match="@*|node()" priority="-2" mode="M124">
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <!--PATTERN res-square-doi-checks-pattern-->
   <!--RULE res-square-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id[1])='rs']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M125">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^10\.21203/rs\.3\.rs-\d+/v\d$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^10\.21203/rs\.3\.rs-\d+/v\d$')">
               <xsl:attribute name="id">res-square-doi-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[res-square-doi-conformance] Research Square preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.21203/rs\.3\.rs-\d+/v\d$'. In other words, the current DOI listed is not a valid Research Square DOI: '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M125"/>
   <xsl:template match="@*|node()" priority="-2" mode="M125">
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <!--PATTERN psyarxiv-journal-meta-checks-pattern-->
   <!--RULE psyarxiv-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id[1])='psyarxiv']" priority="1000" mode="M126">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-id[@journal-id-type='publisher-id']='PsyArXiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-id[@journal-id-type='publisher-id']='PsyArXiv'">
               <xsl:attribute name="id">psyarxiv-journal-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[psyarxiv-journal-id] PsyArXiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'PsyArXiv'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/journal-title='PsyArXiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/journal-title='PsyArXiv'">
               <xsl:attribute name="id">psyarxiv-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[psyarxiv-journal-title] PsyArXiv preprints must have a &lt;journal-title&gt; element with the value 'PsyArXiv' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='PsyArXiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='PsyArXiv'">
               <xsl:attribute name="id">psyarxiv-abbrev-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[psyarxiv-abbrev-journal-title] PsyArXiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'PsyArXiv' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="publisher/publisher-name='Center for Open Science'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="publisher/publisher-name='Center for Open Science'">
               <xsl:attribute name="id">psyarxiv-publisher</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[psyarxiv-publisher] PsyArXiv preprints must have a &lt;publisher-name&gt; element with the value 'Center for Open Science', inside a &lt;publisher&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M126"/>
   <xsl:template match="@*|node()" priority="-2" mode="M126">
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <!--PATTERN psyarxiv-doi-checks-pattern-->
   <!--RULE psyarxiv-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id[1])='psyarxiv']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M127">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^10\.31234/osf\.io/[\da-z]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^10\.31234/osf\.io/[\da-z]+$')">
               <xsl:attribute name="id">psyarxiv-doi-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[psyarxiv-doi-conformance] PsyArXiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.31234/osf\.io/[\da-z]+$'. In other words, the current DOI listed is not a valid PsyArXiv DOI: '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M127"/>
   <xsl:template match="@*|node()" priority="-2" mode="M127">
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <!--PATTERN osf-journal-meta-checks-pattern-->
   <!--RULE osf-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id[1])='osf preprints']" priority="1000" mode="M128">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-id[@journal-id-type='publisher-id']='OSF Preprints'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-id[@journal-id-type='publisher-id']='OSF Preprints'">
               <xsl:attribute name="id">osf-journal-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[osf-journal-id] Preprints on OSF must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'OSF Preprints'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/journal-title='OSF Preprints'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/journal-title='OSF Preprints'">
               <xsl:attribute name="id">osf-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[osf-journal-title] Preprints on OSF must have a &lt;journal-title&gt; element with the value 'OSF Preprints' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='OSF pre.'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='OSF pre.'">
               <xsl:attribute name="id">osf-abbrev-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[osf-abbrev-journal-title] Preprints on OSF must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'OSF pre.' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="publisher/publisher-name='Center for Open Science'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="publisher/publisher-name='Center for Open Science'">
               <xsl:attribute name="id">osf-publisher</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[osf-publisher] Preprints on OSF must have a &lt;publisher-name&gt; element with the value 'Center for Open Science', inside a &lt;publisher&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M128"/>
   <xsl:template match="@*|node()" priority="-2" mode="M128">
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <!--PATTERN osf-doi-checks-pattern-->
   <!--RULE osf-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id[1])='osf preprints']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M129">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^10\.31219/osf\.io/[\da-z]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^10\.31219/osf\.io/[\da-z]+$')">
               <xsl:attribute name="id">osf-doi-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[osf-doi-conformance] Preprints on OSF must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10/.31219/osf\.io/[\da-z]+$'. In other words, the current DOI listed is not a valid OSF Preprints DOI: '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M129"/>
   <xsl:template match="@*|node()" priority="-2" mode="M129">
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <!--PATTERN ecoevorxiv-journal-meta-checks-pattern-->
   <!--RULE ecoevorxiv-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id[1])='ecoevorxiv']" priority="1000" mode="M130">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-id[@journal-id-type='publisher-id']='EcoEvoRxiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-id[@journal-id-type='publisher-id']='EcoEvoRxiv'">
               <xsl:attribute name="id">ecoevorxiv-journal-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ecoevorxiv-journal-id] EcoEvoRxiv preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'EcoEvoRxiv'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/journal-title='EcoEvoRxiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/journal-title='EcoEvoRxiv'">
               <xsl:attribute name="id">ecoevorxiv-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ecoevorxiv-journal-title] EcoEvoRxiv preprints must have a &lt;journal-title&gt; element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='EcoEvoRxiv'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='EcoEvoRxiv'">
               <xsl:attribute name="id">ecoevorxiv-abbrev-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ecoevorxiv-abbrev-journal-title] EcoEvoRxiv preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'EcoEvoRxiv' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="publisher/publisher-name='Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="publisher/publisher-name='Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)'">
               <xsl:attribute name="id">ecoevorxiv-publisher</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ecoevorxiv-publisher] EcoEvoRxiv preprints must have a &lt;publisher-name&gt; element with the value 'Society for Open, Reliable, and Transparent Ecology and Evolutionary Biology (SORTEE)', inside a &lt;publisher&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M130"/>
   <xsl:template match="@*|node()" priority="-2" mode="M130">
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <!--PATTERN ecoevorxiv-doi-checks-pattern-->
   <!--RULE ecoevorxiv-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id[1])='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M131">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^10.32942/[A-Z\d]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^10.32942/[A-Z\d]+$')">
               <xsl:attribute name="id">ecoevorxiv-doi-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ecoevorxiv-doi-conformance] EcoEvoRxiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10.32942/[A-Z\d]+$'. In other words, the current DOI listed is not a valid EcoEvoRxiv DOI: '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M131"/>
   <xsl:template match="@*|node()" priority="-2" mode="M131">
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>
   <!--PATTERN authorea-journal-meta-checks-pattern-->
   <!--RULE authorea-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id[1])='authorea']" priority="1000" mode="M132">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-id[@journal-id-type='publisher-id']='Authorea'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-id[@journal-id-type='publisher-id']='Authorea'">
               <xsl:attribute name="id">authorea-journal-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[authorea-journal-id] Authorea preprints must have a &lt;journal-id journal-id-type="publisher-id"&gt; element with the value 'Authorea'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/journal-title='Authorea'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/journal-title='Authorea'">
               <xsl:attribute name="id">authorea-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[authorea-journal-title] Authorea preprints must have a &lt;journal-title&gt; element with the value 'Authorea' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='Authorea'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="journal-title-group/abbrev-journal-title[@abbrev-type='publisher']='Authorea'">
               <xsl:attribute name="id">authorea-abbrev-journal-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[authorea-abbrev-journal-title] Authorea preprints must have a &lt;abbrev-journal-title abbrev-type="publisher"&gt; element with the value 'Authorea' inside a &lt;journal-title-group&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="publisher/publisher-name='Authorea, Inc'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="publisher/publisher-name='Authorea, Inc'">
               <xsl:attribute name="id">authorea-publisher</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[authorea-publisher] Authorea preprints must have a &lt;publisher-name&gt; element with the value 'Authorea, Inc', inside a &lt;publisher&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M132"/>
   <xsl:template match="@*|node()" priority="-2" mode="M132">
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <!--PATTERN authorea-doi-checks-pattern-->
   <!--RULE authorea-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id[1])='authorea']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M133">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^10\.22541/au\.\d+\.\d+/v\d$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^10\.22541/au\.\d+\.\d+/v\d$')">
               <xsl:attribute name="id">authorea-doi-conformance</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[authorea-doi-conformance] Authorea preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '^10\.22541/au\.\d+\.\d+/v\d$'. In other words, the current DOI listed is not a valid Authorea DOI: '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M133"/>
   <xsl:template match="@*|node()" priority="-2" mode="M133">
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
</xsl:stylesheet>