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
    
    <xsl:function name="e:toTitleCase" as="xs:string">
        <xsl:param name="input" as="xs:string"/>
        <xsl:variable name="upper-exceptions" as="xs:string*" select="('PLOS','OSF','JOSS','JAMA','EMBO','RNA','BMJ','PRIDE','CRAN','EMDB','SSRN','EMPIAR','NEJM','FEMS','JMLR','APMIS','ISME','FASEB','PNAS','JBO','JBJS','AAPS','NIPS','BJOG','ISMRM')"/>
        <xsl:variable name="case-exceptions" as="xs:string*" select="('eLife','iScience','eNeuro','arXiv','bioRxiv','medRxiv','ChemRxiv','PeerJ','PsyArXiv','PaleorXiv','AfricArXiv','EcoEvoRxiv')"/>
        <xsl:variable name="lower-exceptions" as="xs:string*" select="('and', 'or', 'of', 'the', 'in', 'on', 'with', 'a', 'an')"/>
        <xsl:variable name="processed-words" as="xs:string*">
            <xsl:for-each select="tokenize($input,'\s+')">
                <xsl:variable name="val" select="."/>
                <xsl:choose>
                    <xsl:when test="some $example in $case-exceptions satisfies (lower-case($example)=lower-case($val))">
                        <xsl:value-of select="$case-exceptions[lower-case(.)=lower-case($val)]"/>
                    </xsl:when>
                    <xsl:when test="position()=1 and not(upper-case(.)=$upper-exceptions)">
                        <xsl:value-of select="concat(upper-case(substring(.,1,1)),lower-case(substring(.,2)))"/>
                    </xsl:when>
                    <xsl:when test="upper-case(.)=$upper-exceptions">
                        <xsl:value-of select="upper-case(.)"/>
                    </xsl:when>
                    <xsl:when test="lower-case(.)=($lower-exceptions)">
                        <xsl:value-of select="lower-case(.)"/>
                    </xsl:when>
                    <xsl:when test="string-length(.)=1">
                        <xsl:value-of select="upper-case(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(upper-case(substring(.,1,1)),lower-case(substring(.,2)))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($processed-words,' ')"/>
    </xsl:function>
    
    <xsl:variable name="panel-regex" select="'^,?\s?(left|right|top|bottom|inset|lower|upper|middle)(\s(and\s)?(left|right|top|bottom|inset|lower|upper|middle))?(\s?panels?)?[;\),]?[\s\.]?$|^(\s?([,&amp;–\-]|and))*\s?[\p{L}](,?\s?[\p{L}]|\-\s?[\p{L}])?[;\),]?[\s\.]?$'"/>

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
            - Introduce flag to distinguish between reviewed-preprint and VOR XML
            - If there are front//notes that should be in author-notes, and no extant author-notes, then add author-notes in
            - Add clinical trial number(s) from notes as related-object 
    -->
    <xsl:template xml:id="article-meta-changes" mode="article-meta-round-1" match="article-meta">
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
                        <xsl:for-each select="./article-version-alternatives/article-version">
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
            <xsl:choose>
                <xsl:when test="not(./author-notes)">
                    <xsl:choose>
                        <xsl:when test="ancestor::article/front//notes[not(fn-group) and not(contains(@notes-type,'clinical'))]">
                            <xsl:if test="ancestor::article/front//notes[@notes-type]">
                                <xsl:element name="author-notes">
                                    <!-- Ignore clinical trial type notes for now - these are handled separately -->
                                    <xsl:for-each select="ancestor::article/front//notes[not(fn-group) and not(contains(@notes-type,'clinical'))]">
                                        <xsl:text>&#xa;</xsl:text>
                                        <xsl:element name="fn">
                                            <xsl:attribute name="fn-type">coi-statement</xsl:attribute>
                                            <xsl:element name="p">
                                                <xsl:choose>
                                                    <xsl:when test="./title">
                                                        <xsl:value-of select="./title"/>
                                                        <xsl:text>: </xsl:text>
                                                        <xsl:apply-templates select="./p/(*|text())"/></xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:text>Competing interests: </xsl:text>
                                                        <xsl:apply-templates select="./p/(*|text())"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:for-each>
                                    <xsl:text>&#xa;</xsl:text>
                                </xsl:element>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="./author-notes">
                        <xsl:apply-templates select="author-notes"/>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
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
            <xsl:apply-templates select="self-uri[not(@content-type='pdf')]|self-uri[not(@content-type='pdf')]/following-sibling::text()[1]"/>
            <xsl:apply-templates select="*[name()=('related-article','related-object')] | *[name()=('related-article','related-object')]/following-sibling::text()[1]"/>
            <xsl:if test="ancestor::article/front//notes[not(fn-group) and p and contains(@notes-type,'clinical')]">
                <xsl:for-each select="tokenize(string-join(ancestor::article/front//notes[not(fn-group) and contains(@notes-type,'clinical')]/p,';'),';')">
                    <xsl:element name="related-object">
                        <xsl:attribute name="content-type"/>
                        <xsl:attribute name="source-id"/>
                        <xsl:attribute name="source-id-type">registry-name</xsl:attribute>
                        <xsl:attribute name="source-type">clinical-trials-registry</xsl:attribute>
                        <xsl:attribute name="document-id"/>
                        <xsl:attribute name="document-id-type">clinical-trial-number</xsl:attribute>
                        <xsl:attribute name="xlink:href"/>
                        <xsl:value-of select="replace(.,'^\s+|\s+$','')"/>
                    </xsl:element>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates select="abstract|abstract/following-sibling::text()[1]"/>
            <xsl:apply-templates select="trans-abstract|trans-abstract/following-sibling::text()[1]"/>
            <xsl:apply-templates select="kwd-group|kwd-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="funding-group|funding-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="support-group|support-group/following-sibling::text()[1]"/>
            <xsl:apply-templates select="conference|conference/following-sibling::text()[1]"/>
            <xsl:apply-templates select="counts"/>
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
                                        <xsl:if test="./aff">
                                            <xsl:copy-of select="./aff|./aff/preceding-sibling::text()[1]"/>
                                            <xsl:text>&#xa;</xsl:text>
                                        </xsl:if>
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
                                                        <xsl:if test="./aff">
                                                            <xsl:copy-of select="./aff|./aff/preceding-sibling::text()[1]"/>
                                                            <xsl:text>&#xa;</xsl:text>
                                                        </xsl:if>
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
                                                         <xsl:if test="./aff">
                                                            <xsl:copy-of select="./aff|./aff/preceding-sibling::text()[1]"/>
                                                            <xsl:text>&#xa;</xsl:text>
                                                        </xsl:if>
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
                                                         <xsl:if test="./aff">
                                                            <xsl:copy-of select="./aff|./aff/preceding-sibling::text()[1]"/>
                                                            <xsl:text>&#xa;</xsl:text>
                                                        </xsl:if>
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
                                                    <xsl:apply-templates select="./contrib-group|./aff|text()[preceding-sibling::contrib-group and following-sibling::author-notes]"/>
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
                                            <xsl:apply-templates select="./contrib-group|./aff|text()[preceding-sibling::contrib-group and following-sibling::author-notes]"/>
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
                            <xsl:apply-templates select="./contrib-group|./aff|./author-notes|text()[preceding-sibling::contrib-group and following-sibling::author-notes]"/>
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
    
    <!-- Introduce notes captures in front//notes into author-notes -->
    <xsl:template xml:id="author-notes-notes-handling" match="article/front[descendant::notes[@notes-type]]/article-meta/author-notes">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
            <!-- Ignore clinical trial type notes - these are handled separately -->
            <xsl:for-each select="ancestor::article/front//notes[not(notes) and not(fn-group) and not(contains(@notes-type,'clinical')) and not(@notes-type='disclosures')]">
                <xsl:element name="fn">
                    <xsl:choose>
                        <xsl:when test="./@notes-type='competing-interest-statement'">
                            <xsl:attribute name="fn-type">coi-statement</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="./@notes-type">
                            <xsl:attribute name="fn-type">
                                <xsl:value-of select="./@notes-type"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="fn-type">coi-statement</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:element name="p">
                        <xsl:choose>
                            <xsl:when test="./@notes-type='competing-interest-statement'">
                                <xsl:text>Competing interests: </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="count(p) = 1 and ./p[1]='The authors have declared no competing interest.'">
                                        <xsl:text>No competing interests declared</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="./p/(*|text())"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="./title">
                                <xsl:value-of select="./title"/>
                                <xsl:text>: </xsl:text>
                                <xsl:apply-templates select="./p/(*|text())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="./p/(*|text())"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:element>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- Determine what to do with remaining notes after templates have run -->
    <xsl:template xml:id="notes-handling" match="article/front/notes">
        <xsl:choose>
            <xsl:when test="not(@notes-type) and not(notes)">
                <xsl:copy>
                    <xsl:apply-templates select="@*|*|comment()|processing-instruction()"/>
                </xsl:copy>
            </xsl:when>
            <!-- retain only the notes types and fn-groups we want here -->
            <xsl:when test="fn-group or notes[not(@notes-type) or @notes-type='disclosures']">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:apply-templates select="./notes[not(@notes-type) or @notes-type='disclosures']|./notes[not(@notes-type) or @notes-type='disclosures']/following-sibling::text()[1]|fn-group|fn-group/following-sibling::text()[1]"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- Strip full stops from author names -->
    <xsl:template xml:id="remove-fullstops-from-author-names" match="contrib[@contrib-type='author']/name/given-names|article-meta//contrib[@contrib-type='author']/name/surname">
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
            'fundings?( (sources|information))?',
            'key\s?words?',
            '(supplementa(ry|l)|additional|supporting) (informations?|files?|figures?|tables?|materials?|videos?)(( and | &amp; )?(informations?|files?|figures?|tables?|materials?|videos?))?',
            '(data|resource|code|software|methods|materials?)(( and |\s?/\s?|\s+)(data|resource|code|software|materials?))? (avail(a|i)bi?li?ty|accessibi?li?ty)( statement)?',
            'summary|highlights?|teaser',
            '(authors? )?(impact|significance|competing interests?|(conflicts?|declarations?) (of interests?|disclosures?))\s?(disclosures?|statements?)?',
            '(article( and| &amp;)? )?(authors?’? )?(contributions?|details?|information)',
            '(key )?resources? table',
            '(supplement(al|ary)? )?(figure|table|material|(source )?(data|code)|references?)( supplement(al|ary)?)?( legends?)?',
            '(figures?|tables?) supplements',
            'ethic(s|al)( declarations?|statements?|approvals?)?',
            'patient cohort details',
            'abbreviations?|glossary|footnotes?',
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
            <xsl:when test="matches(.,'^\s*STAR ([*★+] )?METHODS?\s*$')">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:text>STAR methods</xsl:text>
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
    
    <!-- Convert addr-line (with named-content) to city -->
    <xsl:template xml:id="addr-line-to-city" match="addr-line[named-content[@content-type='city']]">
        <xsl:element name="city">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <!-- Standardise certain country names -->
    <xsl:template xml:id="country-standardisation" match="aff//country">
        <xsl:variable name="lc" select="e:stripDiacritics(replace(lower-case(.),'[\(\)]',''))"/>
        <xsl:variable name="countries" select="'countries.xml'"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="matches($lc,'^(the )?(u\.?s\.?a?\.?|unite[ds] states( of america)?)\.?$')">
                    <xsl:attribute name="country">US</xsl:attribute>
                    <xsl:text>United States</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?(u\.?k\.?|unite[ds] kingdom|england|wales|scotland)\.?$')">
                    <xsl:attribute name="country">GB</xsl:attribute>
                    <xsl:text>United Kingdom</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?([rp]\.?\s?[pr]\.?|(people’?s )?republic( of)?)?\s?china\.?$')">
                    <xsl:attribute name="country">CN</xsl:attribute>
                    <xsl:text>China</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?(holland|netherlands)\.?$')">
                    <xsl:attribute name="country">NL</xsl:attribute>
                    <xsl:text>Netherlands</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?(republic of|south)?\s?korea\.?$')">
                    <xsl:attribute name="country">KR</xsl:attribute>
                    <xsl:text>Republic of Korea</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?(turkiye|turkey)\.?$')">
                    <xsl:attribute name="country">TR</xsl:attribute>
                    <xsl:text>Turkiye</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?russia\.?$')">
                    <xsl:attribute name="country">RU</xsl:attribute>
                    <xsl:text>Russian Federation</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?tanzania\.?$')">
                    <xsl:attribute name="country">TZ</xsl:attribute>
                    <xsl:text>United Republic of Tanzania</xsl:text>
                </xsl:when>
                <xsl:when test="matches($lc,'^(the )?\s?vietnam\.?$')">
                    <xsl:attribute name="country">VN</xsl:attribute>
                    <xsl:text>Viet Nam</xsl:text>
                </xsl:when>
                <xsl:when test="document($countries)//*:country[lower-case(.)=$lc]">
                    <xsl:attribute name="country">
                        <xsl:value-of select="document($countries)//*:country[lower-case(.)=$lc]/@country"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="document($countries)//*:country[lower-case(.)=$lc]/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|text()"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="comment()|processing-instruction()"/>
        </xsl:copy>
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
                <!-- Handling edited collection refs -->
                <xsl:when test="@publication-type='book' and not(person-group[@person-group-type='author']) and ./*[name()=$name-elems and following-sibling::chapter-title] and ./*[name()=$name-elems and preceding-sibling::chapter-title]">
                    <xsl:apply-templates select="@*"/>
                    <xsl:element name="person-group">
                    <xsl:attribute name="person-group-type">author</xsl:attribute>
                        <xsl:for-each select="./*[name()=$name-elems and following-sibling::chapter-title]|./text()[following-sibling::*[name()=$name-elems and following-sibling::chapter-title]]">
                            <xsl:choose>
                                <xsl:when test="self::text() and matches(.,'^\.?,?\s*(…|\.{3,4}|. . .)\s*(&amp;\s*|and\s*)?$')">
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
                    <xsl:apply-templates select="year|year/following-sibling::text()[1]|year/preceding-sibling::text()[1]"/>
                    <xsl:apply-templates select="chapter-title|chapter-title/following-sibling::text()[1]"/>
                    <xsl:element name="person-group">
                    <xsl:attribute name="person-group-type">editor</xsl:attribute>
                        <xsl:for-each select="./*[name()=$name-elems and preceding-sibling::chapter-title]|./text()[following-sibling::*[name()=$name-elems and preceding-sibling::chapter-title] and preceding-sibling::*[name()=$name-elems and preceding-sibling::chapter-title]]">
                            <xsl:choose>
                                <xsl:when test="self::text() and matches(.,'^\.?,?\s*(…|\.{3,4}|. . .)\s*(&amp;\s*|and\s*)?$')">
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
                    <xsl:apply-templates select="./*[not(name()=($name-elems,'year','chapter-title'))]|./*[name()=$name-elems][last()]/following-sibling::text()|./text()[preceding-sibling::*[not(name()=($name-elems,'year','chapter-title'))]]"/>
                </xsl:when>
                <!-- Any ref without an author person-group -->
                <xsl:when test="not(person-group[@person-group-type='author']) and ./*[name()=$name-elems]">
                    <xsl:apply-templates select="@*"/>
                    <xsl:element name="person-group">
                    <xsl:attribute name="person-group-type">author</xsl:attribute>
                        <xsl:for-each select="./*[name()=$name-elems]|./text()[following-sibling::*[name()=$name-elems]]">
                            <xsl:choose>
                                <xsl:when test="self::text() and matches(.,'^\.?,?\s*(…|\.{3,4}|. . .)\s*(&amp;\s*|and\s*)?$')">
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
                <!-- change fpage tagging to elocation-id in eLife refs -->
                <xsl:when test="@publication-type='journal' and lower-case(source[1])='elife' and fpage">
                    <xsl:apply-templates select="@*"/>
                    <xsl:for-each select="*|text()">
                        <xsl:choose>
                            <xsl:when test="self::fpage">
                                <xsl:element name="elocation-id">
                                    <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
                                </xsl:element>
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
         <xsl:variable name="preprint-regex" select="'^(biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra|ecoevorxiv)$'"/>
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
    
    <!-- Fixes mistagged and all caps source elements -->
     <xsl:template xml:id="ref-source-fixes" match="mixed-citation//source">
         <xsl:choose>
             <!-- Fix casing for eLife -->
             <xsl:when test="matches(lower-case(.),'^\s*elife\s*$') and not(matches(.,'^\s*eLife\s*$'))">
                    <xsl:copy>
                        <xsl:apply-templates select="@*"/>
                        <xsl:text>eLife</xsl:text>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="matches(lower-case(.),'^in\s')">
                    <xsl:choose>
                        <xsl:when test="(ancestor::mixed-citation/@publication-type=('preprint','journal','other')) and upper-case(.)=.">
                            <xsl:text>In </xsl:text>
                            <xsl:copy>
                                <xsl:value-of select="e:toTitleCase(substring-after(.,' '))"/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>In </xsl:text>
                            <xsl:copy>
                                <xsl:value-of select="substring-after(.,' ')"/>
                            </xsl:copy>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="(ancestor::mixed-citation/@publication-type=('preprint','journal','other')) and upper-case(.)=.">
                    <xsl:copy>
                        <xsl:apply-templates select="@*"/>
                        <xsl:value-of select="e:toTitleCase(.)"/>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
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
    
     <!-- Add sec-type="ethics-statement" -->
    <xsl:template xml:id="sec-ethics" match="sec[(not(@sec-type)) and matches(lower-case(title[1]),'ethics') and not(matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing')) and not(ancestor::sec[matches(lower-case(title[1]),'ethics')])]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="sec-type">ethics-statement</xsl:attribute>
            <xsl:if test="not(@id)">
                <xsl:attribute name="id">
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
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
    
    <!-- Include certain bolded text within xref when it immediately follows that xref 
        e.g. <xref>Fig 1</xref><bold>, right)</bold> to <xref>Fig 1, right</xref>) 
        bold handling in template 'bold-follow-xref-cleanup' -->
    <xsl:template xml:id="fix-truncated-xrefs" match="xref[following-sibling::node()[1][name()='bold']]">
        <xsl:variable name="bold-text" select="following-sibling::node()[1]"/>
         <xsl:copy>
             <xsl:choose>
                 <xsl:when test="matches(lower-case($bold-text),$panel-regex) and not(matches(lower-case($bold-text),'^ to $'))">
                     <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                     <xsl:value-of select="replace($bold-text,'[;\),][\s\.]?$','')"/>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                 </xsl:otherwise>
             </xsl:choose>
         </xsl:copy>
    </xsl:template>
    
    <!-- Cleanup unnecessary bold elements that appear directly after xrefs -->
    <xsl:template xml:id="bold-follow-xref-cleanup" match="bold[preceding-sibling::node()[1][name()='xref']]">
        <xsl:choose>
            <xsl:when test="matches(lower-case(.),'^\s?(and|to|&amp;|[,;\)])\s?\.?$')">
                <xsl:apply-templates select="text()|comment()|processing-instruction()"/>
            </xsl:when>
            <xsl:when test="matches(lower-case(.),$panel-regex)">
                <xsl:choose>
                    <xsl:when test="matches(.,'[;\),][\s\.]$')">
                        <xsl:value-of select="substring(.,string-length(.)-1)"/>
                    </xsl:when>
                    <xsl:when test="matches(.,'[\s\.;\),]$')">
                        <xsl:value-of select="substring(.,string-length(.))"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
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

    <!-- Strip unnecessary bolding and italicisation above citations -->
    <xsl:template xml:id="strip-bold-italic-from-above-xref" match="bold[xref]|italic[xref]">
        <xsl:choose> 
            <!-- if there's a text node that contains anything other than punctuation -->
            <xsl:when test="text()[matches(.,'[^\s\p{P}]')] or *[not(name()=('bold','italic','xref'))]">
                <xsl:choose>
                    <xsl:when test="count(text()) = 1 and count(xref) = 1 and xref/following-sibling::text() and matches(lower-case(text()[1]),$panel-regex)">
                        <xsl:element name="xref">
                            <xsl:apply-templates select="xref/@*|xref/*|xref/text()"/>
                            <xsl:value-of select="replace(text()[1],'[;\),][\s\.]?$','')"/>
                        </xsl:element>
                        <xsl:if test="matches(.,'[;\),][\s\.]$')">
                            <xsl:value-of select="substring(.,string-length(.)-1)"/>
                        </xsl:if>
                        <xsl:if test="matches(.,'[\s\.;\),]$')">
                            <xsl:value-of select="substring(.,string-length(.))"/>
                        </xsl:if>                
                    </xsl:when>
                    <xsl:otherwise>
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
                    </xsl:otherwise>
                </xsl:choose>
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
    
    <!-- remove sec[@sec-type='supplementary-material'] from body - it is copied into back in the template below -->
    <xsl:template match="body">
        <xsl:copy>
            <xsl:apply-templates select="*[not(name()='sec' and @sec-type='supplementary-material')]|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Re-arrange back content -->
    <xsl:template xml:id="rearrange-back" match="back">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- This is a section containing presumably complex content, so let's keep it as a child of back and place it first -->
            <xsl:if test="sec[not(matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing')) and not(@sec-type='supplementary-material') and (sec or descendant::fig or descendant::table-wrap or descendant::supplementary-material or descendant::disp-formula or descendant::inline-formula or descendant::statement or descendant::code or descendant::preformat or descendant::ref-list)]">
                <xsl:for-each select="sec[not(matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing'))  and not(@sec-type='supplementary-material') and (sec or descendant::fig or descendant::table-wrap or descendant::supplementary-material or descendant::disp-formula or descendant::inline-formula or descendant::statement or descendant::code or descendant::preformat or descendant::ref-list)]">
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:if>
            <!-- Ensure data availability is a top level section -->
            <xsl:if test="sec[@sec-type='data-availability' or (matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing'))]">
                <xsl:for-each select="sec[@sec-type='data-availability' or (matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing'))]">
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:if>
            <!-- Copy the acknowledgements -->
            <xsl:if test="ack">
                <xsl:for-each select="ack">
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:if>
            <!-- Move (presumed) simple sections into an additional information section -->
            <xsl:if test="sec[not(matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing')) and (not(@sec-type='supplementary-material' or sec or descendant::fig or descendant::table-wrap or descendant::supplementary-material or descendant::disp-formula or descendant::inline-formula or descendant::statement or descendant::code or descendant::preformat or descendant::ref-list))]">
                <xsl:text>&#xa;</xsl:text>
                <xsl:element name="sec">
                    <xsl:choose>
                        <xsl:when test="@id">
                            <xsl:apply-templates select="@id"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id">
                                <xsl:value-of select="generate-id(.)"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="sec-type">additional-information</xsl:attribute>
                    <xsl:text>&#xa;</xsl:text>
                    <title>Additional information</title>
                    <xsl:for-each select="sec[not(matches(lower-case(title[1]),'data') and matches(lower-case(title[1]),'ava[il][il]ability|access|sharing')) and (not(@sec-type='supplementary-material' or sec or descendant::fig or descendant::table-wrap or descendant::supplementary-material or descendant::disp-formula or descendant::inline-formula or descendant::statement or descendant::code or descendant::preformat or descendant::ref-list))]">
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <!-- glossary must come after sec according to the DTD -->
                    <xsl:for-each select="glossary">
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:element>
            </xsl:if>
            <!-- Rename 'Supplementary Information' to 'Additional files' -->
            <xsl:if test="ancestor::article//sec[@sec-type='supplementary-material' and (parent::body or parent::back)]">
                <xsl:text>&#xa;</xsl:text>
                <xsl:element name="sec">
                    <xsl:choose>
                        <xsl:when test="preceding-sibling::body/sec[@sec-type='supplementary-material' and @id]">
                            <xsl:apply-templates select="preceding-sibling::body/sec[@sec-type='supplementary-material'][1]/@id"/>
                        </xsl:when>
                        <xsl:when test="sec[@sec-type='supplementary-material' and @id]">
                            <xsl:apply-templates select="sec[@sec-type='supplementary-material'][1]/@id"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id">
                                <xsl:value-of select="concat('supp',generate-id(.))"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="sec-type">supplementary-material</xsl:attribute>
                    <xsl:text>&#xa;</xsl:text>
                    <title>Additional files</title>
                    <xsl:for-each select="preceding-sibling::body/sec[@sec-type='supplementary-material']/*[name()!='title']|./sec[@sec-type='supplementary-material']/*[name()!='title']">
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:element>
            </xsl:if>
            <xsl:if test="ref-list">
                <xsl:text>&#xa;</xsl:text>
                <xsl:apply-templates select="ref-list"/>
            </xsl:if>
            <xsl:if test="app-group">
                <xsl:text>&#xa;</xsl:text>
                <xsl:apply-templates select="app-group"/>
            </xsl:if>
            <xsl:if test="fn-group|bio|notes">
                <xsl:text>&#xa;</xsl:text>
                <xsl:apply-templates select="fn-group|bio|notes"/>
            </xsl:if>
            <xsl:text>&#xa;</xsl:text>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>