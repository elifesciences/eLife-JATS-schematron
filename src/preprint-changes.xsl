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

    <xsl:variable name="name-elems" select="('string-name','collab','on-behalf-of','etal')"/>

    <xsl:function name="e:get-copyright-holder">
        <xsl:param name="contrib-group"/>
        <xsl:variable name="author-count" select="count($contrib-group/contrib[@contrib-type = 'author'])"/>
        <xsl:choose>
            <xsl:when test="$author-count lt 1"/>
            <xsl:when test="$author-count = 1">
                <xsl:value-of select="e:get-surname($contrib-group/contrib[@contrib-type = 'author'][1])"/>
            </xsl:when>
            <xsl:when test="$author-count = 2">
                <xsl:value-of select="concat(e:get-surname($contrib-group/contrib[@contrib-type = 'author'][1]), ' and ', e:get-surname($contrib-group/contrib[@contrib-type = 'author'][2]))"/>
            </xsl:when>
            <!-- author count is 3+ -->
            <xsl:otherwise>
                <xsl:value-of select="concat(e:get-surname($contrib-group/contrib[@contrib-type = 'author'][1]), ' et al')"/>
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

    <xsl:function name="e:stripDiacritics" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="replace(replace(replace(translate(normalize-unicode($string,'NFD'),'ƀȼđɇǥħɨıɉꝁłøɍŧɏƶ','bcdeghiijklortyz'),'[\p{M}’]',''),'æ','ae'),'ß','ss')"/>
    </xsl:function>

     <xsl:template match="*|@*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- fix common typos in ack titles -->
    <xsl:template xml:id="ack-title" match="ack/title">
        <xsl:copy>
            <xsl:choose>
                <!-- UK spelling -->
                <xsl:when test="matches(lower-case(.),'^a(c?k|k?c)[nl]?ol?w?e?le?(d?g|g?d)ements?[\.:\s]?$')">
                    <xsl:apply-templates select="@*"/>
                    <xsl:text>Acknowledgements</xsl:text>
                </xsl:when>
                <!-- US spelling -->
                <xsl:when test="matches(lower-case(.),'^a(c?k|k?c)[nl]?ol?w?e?le?(d?g|g?d)ments?[\.:\s]?$')">
                    <xsl:apply-templates select="@*"/>
                    <xsl:text>Acknowledgments</xsl:text>
                </xsl:when>
                <!-- Something else?? -->
                <xsl:otherwise>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
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

    <!-- wrapper for article-meta templates run in sequence -->
    <xsl:template match="article-meta">
         <xsl:variable name="article-meta-round-1">
             <xsl:apply-templates select="." mode="article-meta-round-1"/>
         </xsl:variable>
        <xsl:apply-templates select="$article-meta-round-1" mode="article-meta-round-2"/>
    </xsl:template>
    
    <!-- Changes to article-meta: 
            Introduce flag to distinguish between reviewed-preprint and VOR XML -->
    <xsl:template xml:id="add-article-version" mode="article-meta-round-1" match="article-meta">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[name()='article-id']|*[name()=('article-id','article-version','article-version-alternatives')]/preceding-sibling::text()"/>
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
                        <xsl:for-each select="./article-version-alternatives/article-version">
                            <xsl:copy>
                                <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                            </xsl:copy>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:for-each>
                    </xsl:element>
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
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="article-version">
                        <xsl:attribute name="article-version-type">publication-state</xsl:attribute>
                        <xsl:text>reviewed preprint</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[not(name()=('article-id','article-version','article-version-alternatives','custom-meta-group'))]|*[name()=('article-version','article-version-alternatives')]/following-sibling::text()[not(preceding-sibling::*[1]/name()=('counts','self-uri','custom-meta-group'))]|comment()|processing-instruction()"/>
            <xsl:element name="custom-meta-group">
                <xsl:text>&#xa;</xsl:text>
                <xsl:if test="custom-meta-group">
                    <xsl:for-each select="./custom-meta-group/custom-meta|./custom-meta-group/text()[not(position()=1 and .='&#xa;')]">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:if>
                <xsl:element name="custom-meta">
                    <xsl:attribute name="specific-use">meta-only</xsl:attribute>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:element name="meta-name">
                        <xsl:text>publishing-route</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:element name="meta-value">
                        <xsl:text>prc</xsl:text>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:element>
                <xsl:text>&#xa;</xsl:text>
            </xsl:element>
            <xsl:text>&#xa;</xsl:text>
        </xsl:copy>
    </xsl:template>

    <!-- corresp element handling 
        1. Attempt to match up emails and remove corresp
        2. If no match is found and there is an email, remove all content except emails from corresp -->
    <xsl:template xml:id="handle-corresp" mode="article-meta-round-2" match="article-meta">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="./author-notes">
                    <xsl:apply-templates select="*[name()!='contrib-group' and following-sibling::contrib-group]|text()[following-sibling::contrib-group and not(preceding-sibling::contrib-group)]"/>
                    <xsl:choose>
                        <xsl:when test="./author-notes/corresp/email">
                            <xsl:variable name="corresp-emails" select="./author-notes/corresp/email"/>
                            <xsl:variable name="corresp-authors" select="./contrib-group/contrib[@contrib-type='author' and xref[@ref-type='corresp']]"/>
                            <xsl:choose>
                                <!-- When there are no emails in corresp -->
                                <xsl:when test="count($corresp-emails)=0">
                                    <xsl:apply-templates select="./author-notes|text()[preceding-sibling::contrib-group and following-sibling::author-notes]"/>
                                </xsl:when>
                                <!-- When there's 1 corresponding author/email -->
                                <xsl:when test="count($corresp-emails)=1 and count($corresp-authors)=1">
                                    <xsl:element name="contrib-group">
                                        <xsl:apply-templates select="./contrib-group[not(@content-type='section')]/@*"/>
                                        <xsl:text>&#xa;</xsl:text>
                                        <xsl:for-each select="./contrib-group/contrib[@contrib-type='author']">
                                            <xsl:copy>
                                                <xsl:choose>
                                                    <xsl:when test="xref[@ref-type='corresp']">
                                                        <xsl:apply-templates select="@*"/>
                                                        <xsl:if test="not(./@corresp='yes')">
                                                            <xsl:attribute name="corresp">yes</xsl:attribute>
                                                        </xsl:if>
                                                        <xsl:apply-templates select="*[not(@ref-type='corresp')]|text()[not(following-sibling::*[1]/@ref-type='corresp')]"/>
                                                        <xsl:element name="email">
                                                            <xsl:value-of select="$corresp-emails"/>
                                                        </xsl:element>
                                                        <xsl:text>&#xa;</xsl:text>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:apply-templates select="@*|*|text()"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:copy>
                                            <xsl:text>&#xa;</xsl:text>
                                        </xsl:for-each>
                                        <xsl:copy-of select="./contrib-group[not(@content-type='section')]/*[name()!='contrib']|./contrib-group[not(@content-type='section')]/text()[not(following-sibling::contrib) and not(preceding-sibling::*[1]/name()='contrib')]|./contrib-group[not(@content-type='section')]/comment()"/>
                                    </xsl:element>
                                    <xsl:if test="./contrib-group[@content-type='section']">
                                        <xsl:text>&#xa;</xsl:text>
                                        <xsl:copy-of select="./contrib-group[@content-type='section']"/>
                                    </xsl:if>    
                                    <xsl:choose>
                                        <xsl:when test="./author-notes/*[name()!='corresp']">
                                            <xsl:text>&#xa;</xsl:text>
                                            <xsl:element name="author-notes">
                                                <xsl:copy-of select="./author-notes/*[name()!='corresp']|./author-notes/text()[preceding-sibling::corresp]"/>
                                            </xsl:element>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Attempt to match emails to authors -->
                                    <xsl:choose>
                                        <!-- corresp email and author counts match - we can attempt to match them up -->
                                        <xsl:when test="count($corresp-emails) = count($corresp-authors)">
                                            <xsl:variable name="match-round-1">
                                                <matches>
                                                    <xsl:for-each select="$corresp-authors">
                                                        <xsl:variable name="given-name" select="e:stripDiacritics(lower-case(./name[1]/given-names[1]))"/>
                                                        <xsl:variable name="surname" select="e:stripDiacritics(lower-case(./name[1]/surname[1]))"/>
                                                        <xsl:for-each select="$corresp-emails">
                                                            <xsl:variable name="local-part" select="e:stripDiacritics(lower-case(substring-before(.,'@')))"/>
                                                            <xsl:choose>
                                                                <xsl:when test="contains($local-part,$surname) and contains($local-part,$given-name)">
                                                                    <match name="{concat($given-name,' ',$surname)}" email="{.}" confidence="1"/>
                                                                </xsl:when>
                                                                <xsl:when test="contains($local-part,$surname) and contains($local-part,substring($given-name,1,1))">
                                                                    <match name="{concat($given-name,' ',$surname)}" email="{.}" confidence="0.75"/>
                                                                </xsl:when>
                                                                <xsl:when test="contains($local-part,$surname)">
                                                                    <match name="{concat($given-name,' ',$surname)}" email="{.}" confidence="0.5"/>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                        </xsl:for-each>
                                                    </xsl:for-each>
                                                </matches>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <!-- All distinct matches have been easily found -->
                                                <xsl:when test="(count(distinct-values($match-round-1//*:match/@email)) = count($corresp-emails)) and (count($match-round-1//*:match) = count($corresp-authors))">
                                                    <xsl:element name="contrib-group">
                                                        <xsl:apply-templates select="./contrib-group[not(@content-type='section')]/@*"/>
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:for-each select="./contrib-group/contrib[@contrib-type='author']">
                                                            <xsl:copy>
                                                            <xsl:choose>
                                                                <xsl:when test="xref[@ref-type='corresp']">
                                                                    <xsl:variable name="given-name" select="lower-case(./name[1]/given-names[1])"/>
                                                                    <xsl:variable name="surname" select="lower-case(./name[1]/surname[1])"/>
                                                                    <xsl:variable name="name" select="e:stripDiacritics(concat($given-name,' ',$surname))"/>
                                                                    <xsl:variable name="email" select="$match-round-1//*:match[@name=$name]/@email"/>
                                                                    <xsl:apply-templates select="@*"/>
                                                                    <xsl:if test="not(./@corresp='yes')">
                                                                        <xsl:attribute name="corresp">yes</xsl:attribute>
                                                                    </xsl:if>
                                                                    <xsl:apply-templates select="*[not(@ref-type='corresp')]|text()[not(following-sibling::*[1]/@ref-type='corresp')]"/>
                                                                    <xsl:element name="email">
                                                                        <xsl:value-of select="$email"/>
                                                                    </xsl:element>
                                                                    <xsl:text>&#xa;</xsl:text>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:apply-templates select="@*|*|text()"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            </xsl:copy>
                                                            <xsl:text>&#xa;</xsl:text>
                                                        </xsl:for-each>
                                                        <xsl:copy-of select="./contrib-group[not(@content-type='section')]/*[name()!='contrib']|./contrib-group[not(@content-type='section')]/text()[not(following-sibling::contrib) and not(preceding-sibling::*[1]/name()='contrib')]|./contrib-group[not(@content-type='section')]/comment()"/>
                                                    </xsl:element>
                                                    <xsl:if test="./contrib-group[@content-type='section']">
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:copy-of select="./contrib-group[@content-type='section']"/>
                                                    </xsl:if>
                                                    <xsl:choose>
                                                        <xsl:when test="./author-notes/*[name()!='corresp']">
                                                            <xsl:text>&#xa;</xsl:text>
                                                            <xsl:element name="author-notes">
                                                                <xsl:copy-of select="./author-notes/*[name()!='corresp']|./author-notes/text()[preceding-sibling::corresp]"/>
                                                    </xsl:element>
                                                        </xsl:when>
                                                        <xsl:otherwise/>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <!-- All distinct matches except for one have been found -->
                                                <xsl:when test="((count(distinct-values($match-round-1//*:match/@email)) + 1) = count($corresp-emails)) and ((count($match-round-1//*:match) + 1)  = count($corresp-authors))">
                                                     <xsl:element name="contrib-group">
                                                        <xsl:apply-templates select="./contrib-group[not(@content-type='section')]/@*"/>
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:for-each select="./contrib-group/contrib[@contrib-type='author']">
                                                            <xsl:copy>
                                                            <xsl:choose>
                                                                <xsl:when test="xref[@ref-type='corresp']">
                                                                    <xsl:variable name="given-name" select="lower-case(./name[1]/given-names[1])"/>
                                                                    <xsl:variable name="surname" select="lower-case(./name[1]/surname[1])"/>
                                                                    <xsl:variable name="name" select="e:stripDiacritics(concat($given-name,' ',$surname))"/>
                                                                    <xsl:variable name="email" select="if ($match-round-1//*:match[@name=$name]) then $match-round-1//*:match[@name=$name]/@email
                                                                                                       else $corresp-emails[not(. = $match-round-1//*:match/@email)]"/>
                                                                    <xsl:apply-templates select="@*"/>
                                                                    <xsl:if test="not(./@corresp='yes')">
                                                                        <xsl:attribute name="corresp">yes</xsl:attribute>
                                                                    </xsl:if>
                                                                    <xsl:apply-templates select="*[not(@ref-type='corresp')]|text()[not(following-sibling::*[1]/@ref-type='corresp')]"/>
                                                                    <xsl:element name="email">
                                                                        <xsl:value-of select="$email"/>
                                                                    </xsl:element>
                                                                    <xsl:text>&#xa;</xsl:text>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:apply-templates select="@*|*|text()"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            </xsl:copy>
                                                            <xsl:text>&#xa;</xsl:text>
                                                        </xsl:for-each>
                                                        <xsl:copy-of select="./contrib-group[not(@content-type='section')]/*[name()!='contrib']|./contrib-group[not(@content-type='section')]/text()[not(following-sibling::contrib) and not(preceding-sibling::*[1]/name()='contrib')]|./contrib-group[not(@content-type='section')]/comment()"/>
                                                    </xsl:element>
                                                    <xsl:if test="./contrib-group[@content-type='section']">
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:copy-of select="./contrib-group[@content-type='section']"/>
                                                    </xsl:if>
                                                    <xsl:choose>
                                                        <xsl:when test="./author-notes/*[name()!='corresp']">
                                                            <xsl:text>&#xa;</xsl:text>
                                                            <xsl:element name="author-notes">
                                                                <xsl:copy-of select="./author-notes/*[name()!='corresp']|./author-notes/text()[preceding-sibling::corresp]"/>
                                                            </xsl:element>
                                                        </xsl:when>
                                                        <xsl:otherwise/>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <!-- There have been some duplicate matches -->
                                                <xsl:when test="(count(distinct-values($match-round-1//*:match/@email)) = count($corresp-emails)) and (count(distinct-values($match-round-1//*:match/@email)) = count($corresp-authors)) and (count(distinct-values($match-round-1//*:match/@email)) lt count($match-round-1//*:match))">
                                                     <xsl:element name="contrib-group">
                                                        <xsl:apply-templates select="./contrib-group[not(@content-type='section')]/@*"/>
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:for-each select="./contrib-group/contrib[@contrib-type='author']">
                                                            <xsl:copy>
                                                            <xsl:choose>
                                                                <xsl:when test="xref[@ref-type='corresp']">
                                                                    <xsl:variable name="given-name" select="lower-case(./name[1]/given-names[1])"/>
                                                                    <xsl:variable name="surname" select="lower-case(./name[1]/surname[1])"/>
                                                                    <xsl:variable name="name" select="e:stripDiacritics(concat($given-name,' ',$surname))"/>
                                                                    <xsl:variable name="max-conf-match" select="max($match-round-1//*:match[@name=$name]/@confidence)"/>
                                                                    <xsl:variable name="email" select="if ($match-round-1//*:match[@name=$name]) then $match-round-1//*:match[@name=$name and @confidence=$max-conf-match]/@email
                                                                                                       else $corresp-emails[not(. = $match-round-1//*:match/@email)]"/>
                                                                    <xsl:apply-templates select="@*"/>
                                                                    <xsl:if test="not(./@corresp='yes')">
                                                                        <xsl:attribute name="corresp">yes</xsl:attribute>
                                                                    </xsl:if>
                                                                    <xsl:apply-templates select="*[not(@ref-type='corresp')]|text()[not(following-sibling::*[1]/@ref-type='corresp')]"/>
                                                                    <xsl:element name="email">
                                                                        <xsl:value-of select="$email"/>
                                                                    </xsl:element>
                                                                    <xsl:text>&#xa;</xsl:text>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:apply-templates select="@*|*|text()"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            </xsl:copy>
                                                            <xsl:text>&#xa;</xsl:text>
                                                        </xsl:for-each>
                                                        <xsl:copy-of select="./contrib-group[not(@content-type='section')]/*[name()!='contrib']|./contrib-group[not(@content-type='section')]/text()[not(following-sibling::contrib) and not(preceding-sibling::*[1]/name()='contrib')]|./contrib-group[not(@content-type='section')]/comment()"/>
                                                    </xsl:element>
                                                    <xsl:if test="./contrib-group[@content-type='section']">
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:copy-of select="./contrib-group[@content-type='section']"/>
                                                    </xsl:if>
                                                    <xsl:choose>
                                                        <xsl:when test="./author-notes/*[name()!='corresp']">
                                                            <xsl:text>&#xa;</xsl:text>
                                                            <xsl:element name="author-notes">
                                                                <xsl:copy-of select="./author-notes/*[name()!='corresp']|./author-notes/text()[preceding-sibling::corresp]"/>
                                                            </xsl:element>
                                                        </xsl:when>
                                                        <xsl:otherwise/>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <!-- matches cannot be found easily - this will need doing manually if desired -->
                                                <xsl:otherwise>
                                                    <xsl:apply-templates select="./contrib-group|text()[preceding-sibling::contrib-group and following-sibling::author-notes]"/>
                                                    <xsl:element name="author-notes">
                                                        <xsl:copy-of select="./author-notes/text()[following-sibling::corresp]"/>
                                                        <xsl:comment><xsl:value-of select="./author-notes/corresp"/></xsl:comment>
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:element name="corresp">
                                                            <xsl:copy-of select="./author-notes/corresp/@id|./author-notes/corresp/label"/>
                                                            <xsl:for-each select="./author-notes/corresp/email">
                                                                <xsl:if test="position() gt 1">
                                                                    <xsl:text>; </xsl:text>
                                                                </xsl:if>
                                                                <xsl:copy><xsl:value-of select="."/></xsl:copy>
                                                            </xsl:for-each>
                                                        </xsl:element>
                                                        <xsl:copy-of select="./author-notes/*[name()!='corresp']|./author-notes/text()[preceding-sibling::corresp]"/>
                                                    </xsl:element>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- corresp email and author counts do not match - this will need doing manually if desired -->
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="./contrib-group|text()[preceding-sibling::contrib-group and following-sibling::author-notes]"/>
                                            <xsl:element name="author-notes">
                                                <xsl:choose>
                                                    <!-- If there are two or more corresps for some reason -->
                                                    <xsl:when test="count(./author-notes/corresp) gt 1">
                                                        <xsl:for-each select="./author-notes/corresp">
                                                            <xsl:text>&#xa;</xsl:text>
                                                            <xsl:choose>
                                                                <xsl:when test="./email">
                                                                    <xsl:comment><xsl:value-of select="."/></xsl:comment>
                                                                    <xsl:text>&#xa;</xsl:text>
                                                                    <xsl:element name="corresp">
                                                                        <xsl:copy-of select="./@id|./label"/>
                                                                        <xsl:for-each select="./email">
                                                                            <xsl:if test="position() gt 1">
                                                                                <xsl:text>; </xsl:text>
                                                                            </xsl:if>
                                                                            <xsl:copy><xsl:value-of select="."/></xsl:copy>
                                                                        </xsl:for-each>
                                                                   </xsl:element>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:copy-of select="."/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:for-each>
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:copy-of select="./author-notes/*[name()!='corresp']|./author-notes/text()[preceding-sibling::*[name()!='corresp']]"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:copy-of select="./author-notes/text()[following-sibling::corresp]"/>
                                                        <xsl:comment><xsl:value-of select="./author-notes/corresp"/></xsl:comment>
                                                        <xsl:text>&#xa;</xsl:text>
                                                        <xsl:element name="corresp">
                                                            <xsl:copy-of select="./author-notes/corresp/@id|./author-notes/corresp/label"/>
                                                            <xsl:for-each select="./author-notes/corresp/email">
                                                                <xsl:if test="position() gt 1">
                                                                    <xsl:text>; </xsl:text>
                                                                </xsl:if>
                                                                <xsl:copy><xsl:value-of select="."/></xsl:copy>
                                                            </xsl:for-each>
                                                        </xsl:element>
                                                        <xsl:copy-of select="./author-notes/*[name()!='corresp']|./author-notes/text()[preceding-sibling::corresp]"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:element>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="./contrib-group|./author-notes|text()[preceding-sibling::contrib-group and following-sibling::author-notes]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[preceding-sibling::author-notes]|text()[preceding-sibling::author-notes]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Handle cases where there is a singular affiliation without links from the authors -->
    <xsl:template xml:id="singular-aff-contrib" match="article-meta/contrib-group[contrib[@contrib-type='author'] and count(aff) = 1 and not(contrib[@contrib-type='author' and xref[@ref-type='aff']])]/contrib[@contrib-type='author' and not(xref[@ref-type='aff'])]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*|text()"/>
            <!-- label unknown -->
            <xref ref-type="aff" rid="aff1"/>
        </xsl:copy>
    </xsl:template>

    
    <!-- In cases where there is one affiliation for all authors, add id for affiliation so that it can be linked -->
    <xsl:template xml:id="singular-aff" match="article-meta/contrib-group[contrib[@contrib-type='author'] and count(aff) = 1 and not(contrib[@contrib-type='author' and xref[@ref-type='aff']])]/aff">
        <aff id="aff1">
            <xsl:apply-templates select="@*[name()!='id']"/>
            <xsl:apply-templates select="*|text()"/>
        </aff>
    </xsl:template>

    <!-- Introduce text for present address type footnotes -->
    <xsl:template xml:id="present-address-fn" match="article-meta/author-notes//fn[@fn-type=('present-address','current-aff','Present-address','current-address','current-adrress')]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="matches(lower-case(./p[1]),'^\s*(present|current) address')">
                    <xsl:apply-templates select="@*[name()!='fn-type']"/>
                    <xsl:attribute name="fn-type">present-address</xsl:attribute>
                    <xsl:apply-templates select="*|text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*[name()!='fn-type']"/>
                    <xsl:attribute name="fn-type">present-address</xsl:attribute>
                    <xsl:apply-templates select="label"/>
                    <xsl:element name="p">
                        <xsl:text>Present address: </xsl:text>
                        <xsl:copy-of select="./p/*|./p/text()"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Map wildcard fn-types to known/suggested ones -->
    <xsl:template xml:id="author-fn-types" match="article-meta/author-notes//fn[@fn-type and not(@fn-type=('abbr','con','coi-statement','deceased','equal','financial-disclosure','presented-at','present-address','current-aff','Present-address','current-address','current-adrress','supported-by'))]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="lower-case(@fn-type)=('conflict','interest')">
                    <xsl:apply-templates select="@*[name()!='fn-type']"/>
                    <xsl:attribute name="fn-type">coi-statement</xsl:attribute>
                    <xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
                </xsl:when>
                <xsl:when test="lower-case(@fn-type)=('equ','equl')">
                    <xsl:apply-templates select="@*[name()!='fn-type']"/>
                    <xsl:attribute name="fn-type">equal</xsl:attribute>
                    <xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
                </xsl:when>
                <xsl:when test="lower-case(@fn-type)=('supported-by') and @fn-type!='supported-by'">
                    <xsl:apply-templates select="@*[name()!='fn-type']"/>
                    <xsl:attribute name="fn-type">supported-by</xsl:attribute>
                    <xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- Strip full stops from author names -->
    <xsl:template xml:id="remove-fullstops-from-author-names" match="article-meta//contrib[@contrib-type='author']/name/given-names|article-meta//contrib[@contrib-type='author']/name/surname">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="matches(.,'\.')">
                    <xsl:choose>
                        <!-- If there's an initial followed by a word, e.g. de A. M. M. Armas
                                then just go for de A M M Armas -->
                        <xsl:when test="matches(.,'\p{Lu}\.?\s+\p{Lu}\p{Ll}+')">
                            <xsl:value-of select="replace(.,'\.','')"/>
                        </xsl:when>
                        <!-- otherwise remove all spaces after fullstops as well -->
                        <xsl:otherwise>
                            <xsl:value-of select="replace(replace(replace(.,'(\p{Lu})\.+\s*(\p{Lu})', '$1$2'),'(\p{Lu})\.+\s*(\p{Lu})', '$1$2'),'\.+$','')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- Remove degrees from contrib -->
    <xsl:template xml:id="remove-degrees-from-contrib" match="contrib/degrees"/>
        
    <!-- Remove counts from article-meta -->
    <xsl:template xml:id="strip-counts" match="article-meta/counts"/>

    <!-- Remove self-uri for PDF from article-meta -->
    <xsl:template xml:id="strip-pdf-self-uri" match="article-meta/self-uri[@content-type='pdf']"/>
    
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
                        <xsl:copy-of select="$editor/aff"/>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                </xsl:element>
                <xsl:text>&#xa;</xsl:text>
            </xsl:element>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates select="kwd-group|text()[preceding-sibling::kwd-group]"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Change all caps titles to sentence case for known phrases, e.g. REFERENCES -> References -->
    <xsl:template xml:id="all-caps-to-sentence" match="title[(upper-case(.)=. or lower-case(.)=.) and not(*) and not(parent::caption) and not(parent::ack)]">
        <xsl:variable name="phrases" select="(
            'bibliography( (and|&amp;) references?)?',
            '(graphical )?abstract',
            '(materials? (and|&amp;)|experimental)?\s?methods?( details?|summary|(and|&amp;) materials?)?',
            '(supplement(al|ary)? )?materials( (and|&amp;) correspondence)?',
            '(model|methods?)(( and| &amp;) (results|materials?))?',
            'introu?duction',
            '(results?|conclusions?)( (and|&amp;) discussion)?',
            'discussion( (and|&amp;) (results?|conclusions?))?',
            'fundings?( sources)?',
            'key\s?words?',
            '(supplementa(ry|l)|additional) (informations?|files?|figures?|tables?|materials?|videos?)',
            '(data|resource|code|software|materials?)( and (data|resource|code|software|materials?))? (avail(a|i)bi?li?ty|accessibi?li?ty)( statement)?',
            'summary|highlights?|teaser',
            '(impact|significance|competing interests?|(conflicts?|declarations?) (of interests?|disclosures?))\s?(statements?)?',
            '(article( and| &amp;)?)?(authors?’? )?(contributions?|details?|information)',
            'key resources? table',
            '(supplement(al|ary)? )?(figure|table|material|(source )?(data|code)|references?)( supplement(al|ary)?)?( legends?)?',
            '(figures?|tables?) supplements',
            'ethic(s|al)( declarations?|statements?)?',
            'patient cohort details',
            'abbreviations?|glossary',
            'quantification (and|&amp;) statistical analysis',
            'experimental (design and statistical analysis|model( details)?|(model (and|&amp;)( study)? (subject|participant) details|procedures))'
        )"/>
        <xsl:variable name="regex" select="concat('^(',string-join($phrases,'|'),')$')"/>
        <xsl:choose>
            <xsl:when test="matches(normalize-space(lower-case(.)),$regex)">
            <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:value-of select="concat(upper-case(substring(.,1,1)),lower-case(substring(.,2)))"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Capture additional content within asbtract as additional, sibling abstract(s) with JATS4R compliant abstract-type -->
    <xsl:template xml:id="abstract-types" match="article-meta/abstract[*:sec[preceding-sibling::p]]">
        <xsl:copy>
        <xsl:apply-templates select="@*|title|p[not(preceding-sibling::sec)]|text()[not(preceding-sibling::sec)]"/>
        </xsl:copy>
        <xsl:for-each select="./sec[preceding-sibling::p]">
            <xsl:text>&#xa;</xsl:text>
            <abstract>
                <xsl:apply-templates select="@id"/>
                <xsl:choose>
                    <xsl:when test="count(./sec) gt 1">
                        <xsl:attribute name="abstract-type">structured</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="matches(./lower-case(title[1]),'lay summary|digest')">
                        <xsl:attribute name="abstract-type">plain-language-summary</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="not(./sec) and matches(./lower-case(title[1]),'statement|summary|teaser')">
                        <xsl:attribute name="abstract-type">teaser</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="not(./sec) and (matches(./lower-case(title[1]),'highlight|importance|significance') or ./list)">
                        <xsl:attribute name="abstract-type">summary</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="./fig or matches(./lower-case(title[1]),'graphic')">
                        <xsl:attribute name="abstract-type">graphical</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
                <xsl:apply-templates select="*|text()"/>
            </abstract>
        </xsl:for-each>
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
    
    <!-- wrapper for mixed-citation templates run in sequence -->
    <xsl:template match="mixed-citation">
         <xsl:variable name="mixed-citation-round-1">
             <xsl:apply-templates select="." mode="mixed-citation-round-1"/>
         </xsl:variable>
         <xsl:variable name="mixed-citation-round-2">
            <xsl:apply-templates select="$mixed-citation-round-1" mode="mixed-citation-round-2"/>
         </xsl:variable>
        <xsl:variable name="mixed-citation-round-3">
            <xsl:apply-templates select="$mixed-citation-round-2" mode="mixed-citation-round-3"/>
         </xsl:variable>
        <xsl:apply-templates select="$mixed-citation-round-3" mode="mixed-citation-round-4"/>
    </xsl:template>

    <!-- Introduces author person-groups into refs when they are missing-->
    <xsl:template xml:id="add-person-group" mode="mixed-citation-round-1" match="mixed-citation">
        <xsl:variable name="name-elems" select="('name','string-name','collab','on-behalf-of','etal')"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="not(person-group[@person-group-type='author']) and ./*[name()=$name-elems]">
                    <xsl:apply-templates select="@*"/>
                    <xsl:element name="person-group">
                    <xsl:attribute name="person-group-type">author</xsl:attribute>
                        <xsl:for-each select="./*[name()=$name-elems]|./text()[following-sibling::*[name()=$name-elems]]">
                            <xsl:choose>
                                <xsl:when test="self::text() and matches(.,'^\.?,?\s*(…|\.{3,4})\s*(&amp;\s*|and\s*)?$')">
                                    <xsl:text>, </xsl:text>
                                    <etal>…</etal>
                                    <xsl:text> </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:for-each select="./*[not(name()=$name-elems)]|./*[name()=$name-elems][last()]/following-sibling::text()|./text()[preceding-sibling::*[not(name()=$name-elems)]]">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Fixes known/common issues in mixed-citation -->
    <xsl:template xml:id="fix-common-ref-issues" mode="mixed-citation-round-2" match="mixed-citation">
        <xsl:copy>
            <xsl:choose>
                 <!-- Fixes common tagging error with lpage in journal refs -->
                <xsl:when test="@publication-type='journal' and lpage">
                    <xsl:apply-templates select="@*"/>
                    <xsl:for-each select="*|text()">
                        <xsl:choose>
                            <xsl:when test="self::lpage and matches(following-sibling::text()[1],'^[\s\.]+e\d')">
                                <xsl:copy>
                                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                                    <xsl:value-of select="concat('.',substring-before(replace(following-sibling::text()[1],'^[\s+\.]',''),' '))"/>
                                </xsl:copy>
                            </xsl:when>
                            <xsl:when test="self::text() and preceding-sibling::*[1][name()='lpage'] and matches(.,'^[\s\.]+e\d')">
                                <xsl:value-of select="concat(' ',substring-after(replace(.,'^[\s+\.]',''),' '))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <!-- Change chapter-title to source in books -->
                <xsl:when test="@publication-type='book'">
                    <xsl:choose>
                        <xsl:when test="count(chapter-title)=1 and not(source)">
                            <xsl:apply-templates select="@*|*[following-sibling::chapter-title]|text()[following-sibling::chapter-title]|comment()[following-sibling::chapter-title]|processing-instruction()[following-sibling::chapter-title]"/>
                            <xsl:element name="source">
                                <xsl:copy-of select="./chapter-title/*|./chapter-title/text()"/>
                            </xsl:element>
                            <xsl:apply-templates select="*[preceding-sibling::chapter-title]|text()[preceding-sibling::chapter-title]|comment()[preceding-sibling::chapter-title]|processing-instruction()[preceding-sibling::chapter-title]"/>
                        </xsl:when>
                        <xsl:when test="count(article-title)=1 and not(source)">
                            <xsl:apply-templates select="@*|*[following-sibling::article-title]|text()[following-sibling::article-title]|comment()[following-sibling::article-title]|processing-instruction()[following-sibling::article-title]"/>
                            <xsl:element name="source">
                                <xsl:copy-of select="./article-title/*|./article-title/text()"/>
                            </xsl:element>
                            <xsl:apply-templates select="*[preceding-sibling::article-title]|text()[preceding-sibling::article-title]|comment()[preceding-sibling::article-title]|processing-instruction()[preceding-sibling::article-title]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- Change publication-type="website" to "web" for consistency across all eLife content -->
                <xsl:when test="@publication-type='website'">
                     <xsl:attribute name="publication-type">web</xsl:attribute>
                     <xsl:apply-templates select="@*[name()!='publication-type']"/>
                     <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Introduces missing year in mixed-citation -->
     <xsl:template xml:id="add-year-to-ref" mode="mixed-citation-round-3" match="mixed-citation">
         <xsl:copy>
            <xsl:choose>
                <!-- introduce a year at the end of the reference -->
                <xsl:when test="not(year)">
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                    <xsl:text> </xsl:text>
                    <year>no date</year>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
         </xsl:copy>
     </xsl:template>
    
    <!-- Fixes mistagged preprints -->
     <xsl:template xml:id="find-and-tag-preprint-refs" mode="mixed-citation-round-4" match="mixed-citation">
         <xsl:variable name="preprint-regex" select="'^(biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra)$'"/>
         <xsl:copy>
            <xsl:choose>
                <xsl:when test="@publication-type!='preprint' and matches(lower-case(source[1]),$preprint-regex)">
                    <xsl:attribute name="publication-type">preprint</xsl:attribute>
                    <xsl:apply-templates select="@*[name()!='publication-type']|*|text()|comment()|processing-instruction()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
         </xsl:copy>
     </xsl:template>
    
    
    <!-- Add a CC-BY biorender statement for CC0 RPs -->
    <xsl:template xml:id="biorender-permissions" match="article[front//permissions/license/@xlink:href[contains(lower-case(.),'creativecommons.org/publicdomain/zero/')]]//*[caption[contains(lower-case(.),'biorender')]]">
        <xsl:variable name="current-year" select="year-from-date(current-date())"/>
        <xsl:variable name="author-contrib-group" select="ancestor::article/front/article-meta/contrib-group[1]"/>
        <xsl:variable name="copyright-holder" select="e:get-copyright-holder($author-contrib-group)"/>
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
            <xsl:choose>
                <xsl:when test="permissions[contains(.,$copyright-holder) and contains(.,'biorender')]"/>
                <xsl:otherwise>
                    <permissions>
                        <xsl:text>&#xa;</xsl:text>
                        <copyright-statement><xsl:value-of select="concat('© ',$current-year,', ', $copyright-holder)"/></copyright-statement>
                        <xsl:text>&#xa;</xsl:text>
                        <copyright-year><xsl:value-of select="$current-year"/></copyright-year>
                        <xsl:text>&#xa;</xsl:text>
                        <copyright-holder><xsl:value-of select="$copyright-holder"/></copyright-holder>
                        <xsl:text>&#xa;</xsl:text>
                        <license xlink:href="http://creativecommons.org/licenses/by/4.0/">
                            <ali:license_ref>http://creativecommons.org/licenses/by/4.0/</ali:license_ref>
                            <xsl:text>&#xa;</xsl:text>
                            <license-p><xsl:text>Parts of this image created with </xsl:text><ext-link ext-link-type="uri" xlink:href="https://www.biorender.com/">BioRender</ext-link><xsl:text> are made available under a </xsl:text><ext-link ext-link-type="uri" xlink:href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution License</ext-link><xsl:text>, which permits unrestricted use and redistribution provided that the original author and source are credited.</xsl:text></license-p>
                        </license>
                        <xsl:text>&#xa;</xsl:text>
                    </permissions>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
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

    <!-- Strip unnecessary bolding and italicisation from inside citations -->
    <xsl:template xml:id="strip-bold-italic-around-xref" match="xref/bold[italic[not(xref)]]
                                                                    |xref/bold/italic[not(xref)]
                                                                    |bold[italic[xref]]
                                                                    |xref/italic[bold[not(xref)]]
                                                                    |xref/italic/bold[not(xref)]
                                                                    |italic[bold[xref]]">
         <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
    </xsl:template>

    <!-- Strip unnecessary bolding and italicisation above citations -->
    <xsl:template xml:id="strip-bold-italic-from-above-xref" match="bold[xref]|italic[xref]">
        <xsl:choose> 
            <!-- if there's a text node that contains anything other than punctuation -->
            <xsl:when test="text()[matches(.,'[^\s\p{P}]')] or *[not(name()=('bold','italic','xref'))]">
                <xsl:for-each select="node()">
                    <xsl:choose>
                        <xsl:when test="self::xref">
                            <xsl:apply-templates select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <!-- if the text node is just space -->
                                <xsl:when test="self::text() and matches(.,'^\p{Z}+$')">
                                    <xsl:apply-templates select="."/>
                                </xsl:when>
                                <!-- reintroduce styling for unknown content -->
                                <xsl:when test="parent::bold[parent::italic]">
                                    <italic><bold><xsl:apply-templates select="."/></bold></italic>
                                </xsl:when>
                                <xsl:when test="parent::bold">
                                    <bold><xsl:apply-templates select="."/></bold>
                                </xsl:when>
                                <xsl:when test="parent::italic[parent::bold]">
                                    <bold><italic><xsl:apply-templates select="."/></italic></bold>
                                </xsl:when>
                                <xsl:when test="parent::italic">
                                    <italic><xsl:apply-templates select="."/></italic>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy>
                                        <xsl:apply-templates select="."/>
                                    </xsl:copy>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                 <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Make unnecessary list item labels semantic -->
    <xsl:template xml:id="fix-list-item-labels" match="list[@list-type='simple' and list-item[label] and not(@continued-from) and not(@prefix-word)]">
        <xsl:variable name="distinct-labels" select="distinct-values(./list-item/label)"/>
        <xsl:variable name="bullet-variants" select="('○','-','•','▪','◦','–','●','□')"/>
        <xsl:variable name="clean-labels" select="for $label in $distinct-labels return replace($label,'[^\p{L}\d]','')"/>
        <xsl:variable name="label-type">
            <xsl:choose>
                <xsl:when test="every $label in $clean-labels satisfies matches($label,'^\d+$')">order</xsl:when>
                <xsl:when test="every $label in $clean-labels satisfies matches($label,'^[ivxl]+$')">roman-lower</xsl:when>
                <xsl:when test="every $label in $clean-labels satisfies matches($label,'^[IVXL]+$')">roman-upper</xsl:when>
                <xsl:when test="every $label in $clean-labels satisfies matches($label,'^[a-z]+$')">alpha-lower</xsl:when>
                <xsl:when test="every $label in $clean-labels satisfies matches($label,'^[A-Z]+$')">alpha-upper</xsl:when>
                <xsl:otherwise>unknown</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- If the list is in order and starts from 1, a or A (roman numerals are too complex to validate) -->
        <xsl:variable name="non-arithmetic-labels" as="xs:string*">
            <xsl:choose>
                <xsl:when test="$label-type='order'">
                    <xsl:for-each select="./list-item">
                        <xsl:variable name="clean-label" select="replace(./label[1],'[^\d+]','')"/>
                        <xsl:if test="number($clean-label) != position()">
                           <xsl:value-of select="."/>
                       </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$label-type=('alpha-lower','alpha-upper')">
                    <xsl:for-each select="$clean-labels">
                        <xsl:variable name="p" select="position()"/>
                        <xsl:variable name="prev" select="$clean-labels[$p - 1]"/>
                        <xsl:choose>
                            <xsl:when test=".=''">
                                <xsl:value-of select="'unknown'"/>
                            </xsl:when>
                            <xsl:when test="$p=1 and not(.=('a','A'))">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:when test="(string-length(.) gt 2)">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:when test="(string-length(.) = 2) and string-length($prev)=1">
                                <xsl:if test="lower-case(.)!='aa' or lower-case($prev)!='z'">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="(string-length(.) = 2) and string-length($prev)=2">
                                <xsl:if test="(substring(.,1,1) != substring($prev,1,1)) or ((string-to-codepoints(.)[2] - 1) != string-to-codepoints($prev)[2])">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="(string-to-codepoints(.)[1] - 1) != string-to-codepoints($prev)[1]">
                                <xsl:value-of select="."/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'unknown'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:choose>
                <!-- bullet list with one label -->
                <xsl:when test="count($distinct-labels)=1 and $distinct-labels=$bullet-variants">
                    <xsl:apply-templates select="@*[name()!='list-type']"/>
                    <xsl:attribute name="list-type">bullet</xsl:attribute>
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()" mode="list-item-without-label"/>
                </xsl:when>
                <!-- list is arithmetic (i.e. increases by a contant amount each time: 1,2,3; A,B,C; a,b,c; and so on) -->
                <xsl:when test="empty($non-arithmetic-labels)">
                    <xsl:apply-templates select="@*[name()!='list-type']"/>
                    <xsl:attribute name="list-type" select="$label-type"/>
                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()" mode="list-item-without-label"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="list-item[label]" mode="list-item-without-label">
        <xsl:copy>
            <xsl:apply-templates select="*[name()!='label']|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>