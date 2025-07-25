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

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" use-character-maps="char-map"/>
    
    <!-- Force hexadecimal entities for HTML named entities (required by Python XML parser) -->
    <xsl:character-map name="char-map">
        <xsl:output-character character="&#160;" string="&amp;#xA0;"/>
        <xsl:output-character character="&lt;" string="&amp;#x3c;"/>
        <xsl:output-character character="&gt;" string="&amp;#x3e;"/>
        <xsl:output-character character="≥" string="&amp;#x2265;"/>
        <xsl:output-character character="≤" string="&amp;#x2264;"/>
        <xsl:output-character character="α" string="&amp;#x3b1;"/>
        <xsl:output-character character="β" string="&amp;#x3b2;"/>
        <xsl:output-character character="γ" string="&amp;#x3b3;"/>
        <xsl:output-character character="δ" string="&amp;#x3b4;"/>
        <xsl:output-character character="ε" string="&amp;#x3b5;"/>
        <xsl:output-character character="ζ" string="&amp;#x3b6;"/>
        <xsl:output-character character="η" string="&amp;#x3b7;"/>
        <xsl:output-character character="θ" string="&amp;#x3b8;"/>
        <xsl:output-character character="ι" string="&amp;#x3b9;"/>
        <xsl:output-character character="κ" string="&amp;#x3ba;"/>
        <xsl:output-character character="λ" string="&amp;#x3bb;"/>
        <xsl:output-character character="μ" string="&amp;#x3bc;"/>
        <xsl:output-character character="ν" string="&amp;#x3bd;"/>
        <xsl:output-character character="ξ" string="&amp;#x3bE;"/>
        <xsl:output-character character="ο" string="&amp;#x3bf;"/>
        <xsl:output-character character="π" string="&amp;#x3c0;"/>
        <xsl:output-character character="ρ" string="&amp;#x3c1;"/>
        <xsl:output-character character="ς" string="&amp;#x3c2;"/>
        <xsl:output-character character="σ" string="&amp;#x3c3;"/>
        <xsl:output-character character="τ" string="&amp;#x3c4;"/>
        <xsl:output-character character="υ" string="&amp;#x3c5;"/>
        <xsl:output-character character="φ" string="&amp;#x3c6;"/>
        <xsl:output-character character="χ" string="&amp;#x3c7;"/>
        <xsl:output-character character="ψ" string="&amp;#x3c8;"/>
        <xsl:output-character character="ω" string="&amp;#x3c9;"/>
        <xsl:output-character character="Α" string="&amp;#x391;"/>
        <xsl:output-character character="Β" string="&amp;#x392;"/>
        <xsl:output-character character="Γ" string="&amp;#x393;"/>
        <xsl:output-character character="Δ" string="&amp;#x394;"/>
        <xsl:output-character character="Ε" string="&amp;#x395;"/>
        <xsl:output-character character="Ζ" string="&amp;#x396;"/>
        <xsl:output-character character="Η" string="&amp;#x397;"/>
        <xsl:output-character character="Θ" string="&amp;#x398;"/>
        <xsl:output-character character="Ι" string="&amp;#x399;"/>
        <xsl:output-character character="Κ" string="&amp;#x39a;"/>
        <xsl:output-character character="Λ" string="&amp;#x39b;"/>
        <xsl:output-character character="Μ" string="&amp;#x39c;"/>
        <xsl:output-character character="Ν" string="&amp;#x39d;"/>
        <xsl:output-character character="Ξ" string="&amp;#x39E;"/>
        <xsl:output-character character="Ο" string="&amp;#x39f;"/>
        <xsl:output-character character="Π" string="&amp;#x3a0;"/>
        <xsl:output-character character="Ρ" string="&amp;#x3a1;"/>
        <xsl:output-character character="Σ" string="&amp;#x3a3;"/>
        <xsl:output-character character="Τ" string="&amp;#x3a4;"/>
        <xsl:output-character character="Υ" string="&amp;#x3a5;"/>
        <xsl:output-character character="Φ" string="&amp;#x3a6;"/>
        <xsl:output-character character="Χ" string="&amp;#x3a7;"/>
        <xsl:output-character character="Ψ" string="&amp;#x3a8;"/>
        <xsl:output-character character="Ω" string="&amp;#x3a9;"/>  
    </xsl:character-map>

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
    
    <!-- Changes to article-meta: 
            - Introduce flag to distinguish between reviewed-preprint and VOR XML
            - Ensure correct ordering of elements -->
    <xsl:template xml:id="article-meta-changes" match="article-meta">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="article-id|article-id/following-sibling::text()[1]"/>
            <!-- multiple article versions need to be wrapped in <article-version-alternatives> -->
            <xsl:choose>
                <xsl:when test="./article-version-alternatives">
                    <xsl:element name="article-version-alternatives">
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:element name="article-version">
                            <xsl:attribute name="article-version-type">publication-state</xsl:attribute>
                            <xsl:text>reviewed preprint</xsl:text>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:for-each select="./article-version-alternatives/article-version[not(@article-version-type='publication-state')]">
                            <xsl:copy>
                                <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                            </xsl:copy>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:when>
                <xsl:when test="./article-version">
                    <xsl:element name="article-version-alternatives">
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:element name="article-version">
                            <xsl:attribute name="article-version-type">publication-state</xsl:attribute>
                            <xsl:text>reviewed preprint</xsl:text>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:element name="article-version">
                            <xsl:attribute name="article-version-type">preprint-version</xsl:attribute>
                            <xsl:value-of select="./article-version"/>
                        </xsl:element>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="article-version">
                        <xsl:attribute name="article-version-type">publication-state</xsl:attribute>
                        <xsl:text>reviewed preprint</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="article-categories|article-categories/following-sibling::text()[1]"/>
            <xsl:apply-templates select="title-group|title-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('contrib-group','aff','aff-alternatives','x')]|*[name()=('contrib-group','aff','aff-alternatives','x')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="author-notes|author-notes/following-sibling::text()[1]"/>
            <xsl:apply-templates select="pub-date|pub-date/following-sibling::text()[1]"/>
            <xsl:apply-templates select="pub-date-not-available|pub-date-not-available/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume|volume/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume-id|volume-id/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume-series|volume-series/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue|issue/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-id|issue-id/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-title|issue-title/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-title-group|issue-title-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="issue-sponsor|issue-sponsor/following-sibling::text()[1]"/>
            <xsl:apply-templates select="volume-issue-group|volume-issue-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="isbn|isbn/following-sibling::text()[1]"/>
            <xsl:apply-templates select="supplement|supplement/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('fpage','lpage','page-range','elocation-id')] | *[name()=('fpage','lpage','page-range','elocation-id')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('email','ext-link','uri','product','supplementary-material')] | *[name()=('email','ext-link','uri','product','supplementary-material')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="history|history/following-sibling::text()[1]"/>
            <xsl:apply-templates select="pub-history|pub-history/following-sibling::text()[1]"/>
            <xsl:apply-templates select="permissions|permissions/following-sibling::text()[1]"/>
            <xsl:apply-templates select="self-uri|self-uri/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('related-article','related-object')] | *[name()=('related-article','related-object')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="abstract|abstract/following-sibling::text()[1]"/>
            <xsl:apply-templates select="trans-abstract|trans-abstract/following-sibling::text()[1]"/>
            <xsl:apply-templates select="kwd-group|kwd-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="funding-group|funding-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="support-group|support-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="conference|conference/following-sibling::text()[1]"/>
            <xsl:apply-templates select="custom-meta-group|custom-meta-group/following-sibling::text()[1]"/>
        </xsl:copy>
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
    <xsl:template match="(body|back)/sec[title and not(@id)]">
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