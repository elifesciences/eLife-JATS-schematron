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
            <xsl:attribute name="id">name-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">name-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">surname-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">surname-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">given-names-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">given-names-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">name-child-tests-pattern</xsl:attribute>
            <xsl:attribute name="name">name-child-tests-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">journal-ref-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">journal-ref-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ref-list-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">ref-list-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">strike-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">strike-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">underline-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">underline-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">general-article-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">general-article-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">article-version-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">article-version-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">arxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">arxiv-journal-meta-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">arxiv-doi-checks-pattern</xsl:attribute>
            <xsl:attribute name="name">arxiv-doi-checks-pattern</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
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
   <xsl:template match="article-meta/contrib-group[count(aff) gt 1]/contrib[@contrib-type='author' and not(collab)]" priority="1000" mode="M15">

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

   <!--PATTERN name-tests-pattern-->


	  <!--RULE name-tests-->
   <xsl:template match="contrib-group//name" priority="1000" mode="M16">

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
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN surname-tests-pattern-->


	  <!--RULE surname-tests-->
   <xsl:template match="contrib-group//name/surname" priority="1000" mode="M17">

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
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN given-names-tests-pattern-->


	  <!--RULE given-names-tests-->
   <xsl:template match="name/given-names" priority="1000" mode="M18">

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
      <xsl:if test="matches(.,'[\(\)\[\]]')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'[\(\)\[\]]')">
            <xsl:attribute name="id">final-given-names-test-16</xsl:attribute>
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>[final-given-names-test-16] given-names contains brackets - '<xsl:text/>
               <xsl:value-of select="."/>
               <xsl:text/>'. This will be flagged by Crossref (although will not actually cause any significant problems).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN name-child-tests-pattern-->


	  <!--RULE name-child-tests-->
   <xsl:template match="contrib-group//name/*" priority="1000" mode="M19">

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
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN journal-ref-checks-pattern-->


	  <!--RULE journal-ref-checks-->
   <xsl:template match="mixed-citation[@publication-type='journal']" priority="1000" mode="M20">

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
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN ref-list-checks-pattern-->


	  <!--RULE ref-list-checks-->
   <xsl:template match="ref-list" priority="1000" mode="M21">
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
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN strike-checks-pattern-->


	  <!--RULE strike-checks-->
   <xsl:template match="strike" priority="1000" mode="M22">

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
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN underline-checks-pattern-->


	  <!--RULE underline-checks-->
   <xsl:template match="underline" priority="1000" mode="M23">

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
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN general-article-meta-checks-pattern-->


	  <!--RULE general-article-meta-checks-->
   <xsl:template match="article/front/article-meta" priority="1000" mode="M24">

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
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN article-version-checks-pattern-->


	  <!--RULE article-version-checks-->
   <xsl:template match="article/front/article-meta/article-version" priority="1000" mode="M25">

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
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN arxiv-journal-meta-checks-pattern-->


	  <!--RULE arxiv-journal-meta-checks-->
   <xsl:template match="article/front/journal-meta[lower-case(journal-id)='arxiv']" priority="1000" mode="M26">

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
               <svrl:text>[arxiv-issn] arXiv preprints must have a &lt;issn pub-type="epub"&gt; element with the value 'arXiv'.</svrl:text>
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
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN arxiv-doi-checks-pattern-->


	  <!--RULE arxiv-doi-checks-->
   <xsl:template match="article/front[journal-meta[lower-case(journal-id)='arxiv']]/article-meta/article-id[@pub-id-type='doi']" priority="1000" mode="M27">

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
               <svrl:text>[arxiv-doi-conformance] arXiv preprints must have a &lt;article-id pub-id-type="doi"&gt; element with a value that matches the regex '10\.48550/arXiv\.\d{4,}\.\d{4,}'. In other words, the current DOI listed is not a valid arXiv DOI: '<xsl:text/>
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
</xsl:stylesheet>