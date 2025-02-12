<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    xmlns:e="https://elifesciences.org/namespace"
    exclude-result-prefixes="xs xsi e"
    version="3.0">

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

     <xsl:template match="*|@*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Update dtd-version attribute to 1.3
         remove specific-use attribute
         change article-type to conform with VORs
         add namespace definitions to root element if missing -->
    <xsl:template xml:id="article-changes" match="article">
        <xsl:copy>
            <xsl:choose>
                <!-- to account for review articles under the new model -->
                <xsl:when test="@article-type='review-article'">
                    <xsl:apply-templates select="@article-type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="article-type">research-article</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="dtd-version">1.3</xsl:attribute>
            <xsl:apply-templates select="@*[not(name()=('dtd-version','specific-use','article-type'))]"/>
            <!-- If ali, mml and xlink namespaces are missing on root -->
            <xsl:if test="empty(namespace::mml)">
                <xsl:namespace name="mml">http://www.w3.org/1998/Math/MathML</xsl:namespace>
            </xsl:if>
            <xsl:if test="empty(namespace::ali)">
                <xsl:namespace name="ali">http://www.niso.org/schemas/ali/1.0/</xsl:namespace>
            </xsl:if>
            <xsl:if test="empty(namespace::xlink)">
                <xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
            </xsl:if>
            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Replace preprint server information with eLife -->
    <xsl:template xml:id="journal-meta" match="journal-meta">
        <journal-meta>
        <xsl:text>&#xa;</xsl:text>
            <journal-id journal-id-type="nlm-ta">elife</journal-id>
            <xsl:text>&#xa;</xsl:text>
            <journal-id journal-id-type="publisher-id">eLife</journal-id>
            <xsl:text>&#xa;</xsl:text>
            <journal-title-group>
            <xsl:text>&#xa;</xsl:text>
                <journal-title>eLife</journal-title>
            <xsl:text>&#xa;</xsl:text>
            </journal-title-group>
            <xsl:text>&#xa;</xsl:text>
            <issn publication-format="electronic" pub-type="epub">2050-084X</issn>
            <xsl:text>&#xa;</xsl:text>
            <publisher>
            <xsl:text>&#xa;</xsl:text>
                <publisher-name>eLife Sciences Publications, Ltd</publisher-name>
            <xsl:text>&#xa;</xsl:text>
            </publisher>
            <xsl:text>&#xa;</xsl:text>
        </journal-meta>
    </xsl:template>
    
    <!-- Change capitalisation of eLife [aA]ssessment -->
    <xsl:template xml:id="assessment-capitalisation" match="sub-article/front-stub//article-title">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="replace(.,'[\s:\n\.]','')='eLifeassessment'">
                    <xsl:text>eLife Assessment</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- Add editor as author of eLife Assessment -->
    <xsl:template xml:id="assessment-author" match="article[//article-meta/contrib-group[@content-type='section']/contrib[@contrib-type='editor']]/sub-article[@article-type='editor-report']/front-stub">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[name()!='kwd-group' and following-sibling::kwd-group]|text()[following-sibling::kwd-group and not(preceding-sibling::kwd-group)]"/>
            <xsl:variable name="editor" select="ancestor::article//article-meta/contrib-group[@content-type='section']/contrib[@contrib-type='editor']"/>
            <xsl:element name="contrib-group">
                <xsl:text>&#xa;</xsl:text>
                <xsl:element name="contrib">
                    <xsl:attribute name="contrib-type">author</xsl:attribute>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:copy-of select="$editor/*:name"/>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:element name="role">
                        <xsl:attribute name="specific-use">editor</xsl:attribute>
                        <xsl:text>Reviewing Editor</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:if test="$editor/contrib-id">
                        <xsl:copy-of select="$editor/contrib-id"/>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$editor/aff">
                        <xsl:element name="aff">
                            <xsl:text>&#xa;</xsl:text>
                            <xsl:if test="$editor/aff/*[name()=('institution','institution-wrap')]">
                                <xsl:copy-of select="$editor/aff/*[name()=('institution','institution-wrap')]"/>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:if>
                            <xsl:if test="$editor/aff/addr-line">
                                <xsl:element name="city">
                                    <xsl:value-of select="$editor/aff/addr-line"/>
                                </xsl:element>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:if>
                            <xsl:if test="$editor/aff/country">
                                <xsl:copy-of select="$editor/aff/country"/>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:if>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                </xsl:element>
                <xsl:text>&#xa;</xsl:text>
            </xsl:element>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="kwd-group|text()[preceding-sibling::kwd-group]"/>
        </xsl:copy>
    </xsl:template>

    <!-- Convert ext-link elements that contain dois in refs to correct semantic capture: pub-id -->
    <xsl:template xml:id="ref-doi-fix" match="ref//ext-link[@ext-link-type='uri'][matches(lower-case(@xlink:href),'^https?://(dx\.)?doi\.org/')]">
        <xsl:element name="pub-id">
            <xsl:attribute name="pub-id-type">doi</xsl:attribute>
            <xsl:value-of select="substring(@xlink:href, (string-length(@xlink:href) - string-length(substring-after(lower-case(@xlink:href),'doi.org/')) + 1))"/>
        </xsl:element>
    </xsl:template>

    <!-- Convert uri elements to ext-link -->
    <xsl:template xml:id="uri-to-ext-link" match="uri">
        <xsl:choose>
            <xsl:when test="ancestor::mixed-citation and matches(lower-case(.),'^https?://(dx\.)?doi\.org/')">
                <xsl:element name="pub-id">
                    <xsl:attribute name="pub-id-type">doi</xsl:attribute>
                    <xsl:value-of select="substring(., (string-length(.) - string-length(substring-after(lower-case(.),'doi.org/')) + 1))"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="./@xlink:href">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type">uri</xsl:attribute>
                    <xsl:attribute name="xlink:href"><xsl:value-of select="./@xlink:href"/></xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type">uri</xsl:attribute>
                    <xsl:attribute name="xlink:href"><xsl:value-of select="."/></xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Convert addr-line (with named-content) to city -->
    <xsl:template xml:id="addr-line-to-city" match="addr-line[named-content[@content-type='city']]">
        <xsl:element name="city">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <!-- introduce mimetype and mime-subtype when missing -->
    <xsl:template xml:id="graphics" match="graphic|inline-graphic">
        <xsl:choose>
            <xsl:when test="./@mime-subtype">
                <xsl:copy>
                    <xsl:apply-templates select="@*[name()!='mimetype']"/>
                    <xsl:attribute name="mimetype">image</xsl:attribute>
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                </xsl:copy>
            </xsl:when>
            <!-- No link to file, cannot determine mime-subtype -->
            <xsl:when test="not(@xlink:href)">
                <xsl:copy>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="file" select="tokenize(lower-case(@xlink:href),'\.')[last()]"/>
                <xsl:variable name="mime-subtype">
                    <xsl:choose>
                        <xsl:when test="$file=('tif','tiff')">tiff</xsl:when>
                        <xsl:when test="$file=('jpeg','jpg')">jpeg</xsl:when>
                        <xsl:when test="$file='gif'">gif</xsl:when>
                        <xsl:when test="$file='png'">png</xsl:when>
                        <xsl:otherwise>unknown</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <!-- no @mime-subtype -->
                    <xsl:when test="$mime-subtype!='unknown'">
                        <xsl:copy>
                            <xsl:apply-templates select="@*[name()!='mimetype']"/>
                            <xsl:attribute name="mimetype">image</xsl:attribute>
                            <xsl:attribute name="mime-subtype"><xsl:value-of select="$mime-subtype"/></xsl:attribute>
                            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                        </xsl:copy>
                    </xsl:when>
                    <!-- It is not a known/supported image type -->
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*[name()!='mimetype']"/>
                            <xsl:attribute name="mimetype">image</xsl:attribute>
                            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Introduce id for top-level sections (with titles) that don't have them, so they appear in the TOC on EPP -->
    <xsl:template match="(body|back)/sec[title and not(@id) and not(matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing'))]">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Introduce id for supplementary-material -->
    <xsl:template match="supplementary-material[not(@id)]">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Add sec-type="data-availability" -->
    <xsl:template xml:id="sec-data-availability" match="sec[(not(@sec-type) or @sec-type='data-availability') and matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="sec-type">data-availability</xsl:attribute>
            <xsl:if test="not(@id)">
                <xsl:attribute name="id">
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Strip or convert HTML <i> tags -->
    <xsl:template xml:id="strip-i-tags" match="i">
        <xsl:choose>
            <xsl:when test="ancestor::italic">
                <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="italic">
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Strip or convert HTML <blockquote> tags -->
    <xsl:template xml:id="strip-blockquote-tags" match="blockquote">
        <xsl:choose>
            <xsl:when test="ancestor::disp-quote">
                <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="disp-quote">
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>