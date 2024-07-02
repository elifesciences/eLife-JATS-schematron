<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    exclude-result-prefixes="xs xsi"
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
    
    <!-- Handle cases where there is a singular affiliation without links from the authors -->
    <xsl:template xml:id="singular-aff-contrib" match="article-meta/contrib-group[count(aff) = 1 and not(contrib[@contrib-type='author' and xref[@ref-type='aff']])]/contrib[@contrib-type='author' and not(xref[@ref-type='aff'])]">
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

    <!-- Strip full stops from author names -->
    <xsl:template xml:id="remove-fullstops-from-author-names" match="article-meta//contrib[@contrib-type='author']/name/(given-names|surname)">
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
    
    <!-- Change all caps titles to sentence case for known phrases, e.g. REFERENCES -> References -->
    <xsl:template xml:id="all-caps-to-sentence" match="title[(upper-case(.)=. or lower-case(.)=.) and not(*) and not(parent::caption)]">
        <xsl:variable name="phrases" select="(
            'bibliography( (and|&amp;) references?)?',
            '(graphical )?abstract',
            '(materials? (and|&amp;)|experimental)?\s?methods?( details?|summary|(and|&amp;) materials?)?',
            '(supplement(al|ary)? )?materials( (and|&amp;) correspondence)?',
            'model((and|&amp;) results)?',
            'introu?duction',
            '(results?|conclusions?)( (and|&amp;) discussion)?',
            'acknowled?ge?ments?',
            'discussion( (and|&amp;) (results?|conclusions?))?',
            'fundings?( sources)?',
            'key\s?words?',
            '(supplementa(ry|l)|additional) (information|files?|figures?|tables?|materials?)',
            '(data|resource|code|software|materials?)( and (data|resource|code|software|materials?))? (avail(a|i)bi?li?ty|accessibi?li?ty)( statement)?',
            'summary|highlights?|teaser',
            '(impact|significance|competing interests?|(conflicts?|declarations?) (of interests?|disclosures?))\s?(statements?)?',
            '(article( and| &amp;)?)?(authors?’? )?(contributions?|details?|information)',
            'key resources? table',
            '(supplement(al|ary)? )?(figure|table|material|(source )?(data|code)|references?)( supplement(al|ary)?)?( legends?)?',
            '(figures?|tables?) supplements',
            'ethic(s|al)( declarations?|statements?)?',
            'patient cohort details',
            'abbreviations?|glossary'
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
                    <xsl:when test="not(./sec) and matches(./lower-case(title[1]),'statement|summary')">
                        <xsl:attribute name="abstract-type">teaser</xsl:attribute>
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
    
    <!-- Change publication-type="website" to "web" for consistency across all eLife content -->
    <xsl:template xml:id="web-ref-type" match="mixed-citation[@publication-type='website']|element-citation-citation[@publication-type='website']">
        <xsl:copy>
            <xsl:attribute name="publication-type">web</xsl:attribute>
            <xsl:apply-templates select="@*[name()!='publication-type']"/>
            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add blanket biorender statement for any object with a caption that mentions it -->
    <xsl:template xml:id="biorender-permissions" match="*[caption[contains(lower-case(.),'biorender')] and not(permissions[contains(lower-case(.),'biorender')])]">
        <xsl:variable name="current-year" select="year-from-date(current-date())"/>
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
            <permissions>
                <xsl:text>&#xa;</xsl:text>
                <copyright-statement><xsl:value-of select="concat('© ',$current-year,', BioRender Inc')"/></copyright-statement>
                <xsl:text>&#xa;</xsl:text>
                <copyright-year><xsl:value-of select="$current-year"/></copyright-year>
                <xsl:text>&#xa;</xsl:text>
                <copyright-holder>BioRender Inc</copyright-holder>
                <xsl:text>&#xa;</xsl:text>
                <license>
                    <license-p><xsl:text>Any parts of this image created with </xsl:text><ext-link ext-link-type="uri" xlink:href="https://www.biorender.com/">BioRender</ext-link><xsl:text> are not made available under the same license as the Reviewed Preprint, and are © </xsl:text><xsl:value-of select="$current-year"/><xsl:text>, BioRender Inc.</xsl:text></license-p>
                </license>
                <xsl:text>&#xa;</xsl:text>
            </permissions>
        </xsl:copy>
    </xsl:template>
    
    <!-- Introduce id for top-level sections (with titles) that don't have them, so they appear in the TOC on EPP -->
    <xsl:template xml:id="toc-sec-ids" match="(body|back)/sec[title and not(@id)]">
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

</xsl:stylesheet>