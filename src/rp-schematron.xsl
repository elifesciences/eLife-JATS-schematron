<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:file="java.io.File" xmlns:java="http://www.java.com/" xmlns:meca="http://manuscriptexchange.org" version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
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
            <xsl:attribute name="id">article-title-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">article-title-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">author-contrib-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">author-contrib-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">author-corresp-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">author-corresp-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">name-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">name-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">surname-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">surname-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">given-names-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">given-names-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">name-child-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">name-child-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">orcid-name-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">orcid-name-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">journal-ref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">journal-ref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-list-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-list-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-year-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-year-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-name-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-name-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-etal-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-etal-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-pub-id-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-pub-id-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">mixed-citation-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">mixed-citation-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">strike-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">strike-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">underline-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">underline-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fig-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">fig-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fig-child-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">fig-child-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fig-label-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">fig-label-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M34"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">table-wrap-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">table-wrap-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M35"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">table-wrap-child-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">table-wrap-child-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M36"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">table-wrap-label-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">table-wrap-label-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M37"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-formula-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-formula-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M38"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">inline-formula-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">inline-formula-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M39"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">disp-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">disp-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">inline-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">inline-equation-alternatives-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M41"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">list-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">list-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">graphic-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">graphic-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">title-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">title-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">title-toc-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">title-toc-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">general-article-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">general-article-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-version-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">article-version-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">digest-title-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">digest-title-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M48"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">preformat-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">preformat-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">code-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">code-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M50"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">uri-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">uri-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ext-link-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">ext-link-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M52"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">unallowed-symbol-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">unallowed-symbol-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">arxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">arxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M54"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">arxiv-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">arxiv-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">res-square-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">res-square-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">res-square-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">res-square-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">psyarxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">psyarxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">psyarxiv-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">psyarxiv-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">osf-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">osf-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">osf-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">osf-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ecoevorxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ecoevorxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ecoevorxiv-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ecoevorxiv-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">authorea-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">authorea-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">authorea-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">authorea-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">eLife reviewed preprint schematron</svrl:text>

   <!--PATTERN article-title-checks-pattern-->


	  <!--RULE article-title-checks-->
   <xsl:template match="article-meta/title-group/article-title" priority="1000" mode="M14">

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
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN author-contrib-checks-pattern-->


	  <!--RULE author-contrib-checks-->
   <xsl:template match="article-meta/contrib-group/contrib[@contrib-type='author' and not(collab)]" priority="1000" mode="M15">

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
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN author-corresp-checks-pattern-->


	  <!--RULE author-corresp-checks-->
   <xsl:template match="contrib[@contrib-type='author']" priority="1000" mode="M16">

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
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN name-tests-pattern-->


	  <!--RULE name-tests-->
   <xsl:template match="contrib-group//name" priority="1000" mode="M17">

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
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN surname-tests-pattern-->


	  <!--RULE surname-tests-->
   <xsl:template match="contrib-group//name/surname" priority="1000" mode="M18">

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
      <xsl:if test="matches(.,'^\p{Ll}') and not(matches(.,'^de[rn]? |^van |^von |^el |^te[rn] '))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^\p{Ll}') and not(matches(.,'^de[rn]? |^van |^von |^el |^te[rn] '))">
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
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN given-names-tests-pattern-->


	  <!--RULE given-names-tests-->
   <xsl:template match="name/given-names" priority="1000" mode="M19">

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
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN name-child-tests-pattern-->


	  <!--RULE name-child-tests-->
   <xsl:template match="contrib-group//name/*" priority="1000" mode="M20">

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
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN orcid-name-checks-pattern-->


	  <!--RULE orcid-name-checks-->
   <xsl:template match="article/front/article-meta/contrib-group[1]" priority="1000" mode="M21">
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
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN journal-ref-checks-pattern-->


	  <!--RULE journal-ref-checks-->
   <xsl:template match="mixed-citation[@publication-type='journal']" priority="1000" mode="M22">

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
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN ref-list-checks-pattern-->


	  <!--RULE ref-list-checks-->
   <xsl:template match="ref-list" priority="1000" mode="M23">
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
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN ref-year-checks-pattern-->


	  <!--RULE ref-year-checks-->
   <xsl:template match="ref//year" priority="1000" mode="M24">

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
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN ref-name-checks-pattern-->


	  <!--RULE ref-name-checks-->
   <xsl:template match="mixed-citation//name | mixed-citation//string-name" priority="1000" mode="M25">

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
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN ref-etal-checks-pattern-->


	  <!--RULE ref-etal-checks-->
   <xsl:template match="mixed-citation[person-group]//etal" priority="1000" mode="M26">

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
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN ref-pub-id-checks-pattern-->


	  <!--RULE ref-pub-id-checks-->
   <xsl:template match="ref//pub-id[@pub-id-type='doi']" priority="1000" mode="M27">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')">
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
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

   <!--PATTERN ref-checks-pattern-->


	  <!--RULE ref-checks-->
   <xsl:template match="ref" priority="1000" mode="M28">

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
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

   <!--PATTERN mixed-citation-checks-pattern-->


	  <!--RULE mixed-citation-checks-->
   <xsl:template match="mixed-citation" priority="1000" mode="M29">
      <xsl:variable name="publication-type-values" select="('journal', 'book', 'data', 'patent', 'software', 'preprint', 'web', 'report', 'confproc', 'thesis', 'other')"/>

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
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

   <!--PATTERN strike-checks-pattern-->


	  <!--RULE strike-checks-->
   <xsl:template match="strike" priority="1000" mode="M30">

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
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>

   <!--PATTERN underline-checks-pattern-->


	  <!--RULE underline-checks-->
   <xsl:template match="underline" priority="1000" mode="M31">

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
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>

   <!--PATTERN fig-checks-pattern-->


	  <!--RULE fig-checks-->
   <xsl:template match="fig" priority="1000" mode="M32">

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
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>

   <!--PATTERN fig-child-checks-pattern-->


	  <!--RULE fig-child-checks-->
   <xsl:template match="fig/*" priority="1000" mode="M33">
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
                  <xsl:value-of select="name()"/>
                  <xsl:text/> is not supported as a child of &lt;fig&gt;.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>

   <!--PATTERN fig-label-checks-pattern-->


	  <!--RULE fig-label-checks-->
   <xsl:template match="fig/label" priority="1000" mode="M34">

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
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>

   <!--PATTERN table-wrap-checks-pattern-->


	  <!--RULE table-wrap-checks-->
   <xsl:template match="table-wrap" priority="1000" mode="M35">

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
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>

   <!--PATTERN table-wrap-child-checks-pattern-->


	  <!--RULE table-wrap-child-checks-->
   <xsl:template match="table-wrap/*" priority="1000" mode="M36">
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
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>

   <!--PATTERN table-wrap-label-checks-pattern-->


	  <!--RULE table-wrap-label-checks-->
   <xsl:template match="table-wrap/label" priority="1000" mode="M37">

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
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>

   <!--PATTERN disp-formula-checks-pattern-->


	  <!--RULE disp-formula-checks-->
   <xsl:template match="disp-formula" priority="1000" mode="M38">

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
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>

   <!--PATTERN inline-formula-checks-pattern-->


	  <!--RULE inline-formula-checks-->
   <xsl:template match="inline-formula" priority="1000" mode="M39">

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
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>

   <!--PATTERN disp-equation-alternatives-checks-pattern-->


	  <!--RULE disp-equation-alternatives-checks-->
   <xsl:template match="alternatives[parent::disp-formula]" priority="1000" mode="M40">

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
               <svrl:text>[disp-equation-alternatives-conformance] alternaives element within <xsl:text/>
                  <xsl:value-of select="parent::*/name()"/>
                  <xsl:text/> must have both a graphic (or numerous graphics) and mathml representation of the equation. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>

   <!--PATTERN inline-equation-alternatives-checks-pattern-->


	  <!--RULE inline-equation-alternatives-checks-->
   <xsl:template match="alternatives[parent::inline-formula]" priority="1000" mode="M41">

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
               <svrl:text>[inline-equation-alternatives-conformance] alternaives element within <xsl:text/>
                  <xsl:value-of select="parent::*/name()"/>
                  <xsl:text/> must have both an inline-graphic (or numerous graphics) and mathml representation of the equation. This one does not.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>

   <!--PATTERN list-checks-pattern-->


	  <!--RULE list-checks-->
   <xsl:template match="list" priority="1000" mode="M42">
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
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>

   <!--PATTERN graphic-checks-pattern-->


	  <!--RULE graphic-checks-->
   <xsl:template match="graphic|inline-graphic" priority="1000" mode="M43">
      <xsl:variable name="file" select="tokenize(lower-case(@xlink:href),'\.')[last()]"/>
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
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>

   <!--PATTERN title-checks-pattern-->


	  <!--RULE title-checks-->
   <xsl:template match="title" priority="1000" mode="M44">

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
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>

   <!--PATTERN title-toc-checks-pattern-->


	  <!--RULE title-toc-checks-->
   <xsl:template match="article/body/sec/title|article/back/sec/title" priority="1000" mode="M45">

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
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>

   <!--PATTERN general-article-meta-checks-pattern-->


	  <!--RULE general-article-meta-checks-->
   <xsl:template match="article/front/article-meta" priority="1000" mode="M46">
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

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-version)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(article-version)=1">
               <xsl:attribute name="id">article-version-1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-version-1] article-meta must contain one (and only one) &lt;article-version&gt; element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(contrib-group)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contrib-group)=1">
               <xsl:attribute name="id">article-contrib-group</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-contrib-group] article-meta must contain one (and only one) &lt;contrib-group&gt; element.</svrl:text>
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
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>

   <!--PATTERN article-version-checks-pattern-->


	  <!--RULE article-version-checks-->
   <xsl:template match="article/front/article-meta/article-version" priority="1000" mode="M47">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(.,'^1\.\d+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^1\.\d+$')">
               <xsl:attribute name="id">article-version-2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[article-version-2] article-must be in the format 1.x (e.g. 1.11). This one is '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>

   <!--PATTERN digest-title-checks-pattern-->


	  <!--RULE digest-title-checks-->
   <xsl:template match="title" priority="1000" mode="M48">

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
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>

   <!--PATTERN preformat-checks-pattern-->


	  <!--RULE preformat-checks-->
   <xsl:template match="preformat" priority="1000" mode="M49">

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
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>

   <!--PATTERN code-checks-pattern-->


	  <!--RULE code-checks-->
   <xsl:template match="code" priority="1000" mode="M50">

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
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>

   <!--PATTERN uri-checks-pattern-->


	  <!--RULE uri-checks-->
   <xsl:template match="uri" priority="1000" mode="M51">

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
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>

   <!--PATTERN ext-link-tests-pattern-->


	  <!--RULE ext-link-tests-->
   <xsl:template match="ext-link[@ext-link-type='uri']" priority="1000" mode="M52">

		<!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(@xlink:href,'^https?:..(www\.)?[-a-zA-Z0-9@:%.,_\+~#=!]{1,256}\.[a-z]{2,6}([-a-zA-Z0-9@:;%,_\\(\)+.~#?!&amp;&lt;&gt;//=]*)$|^ftp://.|^tel:.|^mailto:.')">
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
      <xsl:if test="(.!=@xlink:href) and matches(.,'https?:|ftp:|www\.')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(.!=@xlink:href) and matches(.,'https?:|ftp:|www\.')">
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
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>

   <!--PATTERN unallowed-symbol-tests-pattern-->


	  <!--RULE unallowed-symbol-tests-->
   <xsl:template match="p|td|th|title|xref|bold|italic|sub|sc|named-content|monospace|code|underline|fn|institution|ext-link" priority="1000" mode="M53">

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
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>

   <!--PATTERN arxiv-journal-meta-checks-pattern-->


	  <!--RULE arxiv-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id)='arxiv']" priority="1000" mode="M54">

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
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>

   <!--PATTERN arxiv-doi-checks-pattern-->


	  <!--RULE arxiv-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id)='arxiv']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M55">

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
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>

   <!--PATTERN res-square-journal-meta-checks-pattern-->


	  <!--RULE res-square-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id)='rs']" priority="1000" mode="M56">

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
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>

   <!--PATTERN res-square-doi-checks-pattern-->


	  <!--RULE res-square-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id)='rs']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M57">

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
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>

   <!--PATTERN psyarxiv-journal-meta-checks-pattern-->


	  <!--RULE psyarxiv-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id)='psyarxiv']" priority="1000" mode="M58">

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
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>

   <!--PATTERN psyarxiv-doi-checks-pattern-->


	  <!--RULE psyarxiv-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id)='psyarxiv']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M59">

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
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>

   <!--PATTERN osf-journal-meta-checks-pattern-->


	  <!--RULE osf-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id)='osf preprints']" priority="1000" mode="M60">

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
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>

   <!--PATTERN osf-doi-checks-pattern-->


	  <!--RULE osf-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id)='osf preprints']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M61">

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
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>

   <!--PATTERN ecoevorxiv-journal-meta-checks-pattern-->


	  <!--RULE ecoevorxiv-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id)='ecoevorxiv']" priority="1000" mode="M62">

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
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>

   <!--PATTERN ecoevorxiv-doi-checks-pattern-->


	  <!--RULE ecoevorxiv-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id)='ecoevorxiv']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M63">

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
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>

   <!--PATTERN authorea-journal-meta-checks-pattern-->


	  <!--RULE authorea-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id)='authorea']" priority="1000" mode="M64">

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
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>

   <!--PATTERN authorea-doi-checks-pattern-->


	  <!--RULE authorea-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id)='authorea']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M65">

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
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
</xsl:stylesheet>