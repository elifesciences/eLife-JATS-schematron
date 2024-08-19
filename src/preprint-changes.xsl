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

    <xsl:variable name="name-elems" select="('string-name','collab','on-behalf-of','etal')"/>

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
            Introduce flag to distinguish between reviewed-preprint and VOR XML 
    <xsl:template xml:id="article-meta" match="article-meta"> 
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[name()='article-id']|*[name()=('article-id','article-version','article-version-alternatives')]/preceding-sibling::text()"/>
            <!- - multiple article versions need to be wrapped in <article-version-alternatives> - ->
            <xsl:choose>
                <xsl:when test="./article-version-alternatives">
                    <article-version-alternatives>
                        <xsl:text>&#xa;</xsl:text>
                        <article-version article-version-type="publication-state">reviewed preprint</article-version>
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:for-each select="./article-version-alternatives/article-version">
                            <xsl:copy>
                                <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                            </xsl:copy>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:for-each>
                    </article-version-alternatives>
                </xsl:when>
                <xsl:when test="./article-version">
                    <article-version-alternatives>
                        <xsl:text>&#xa;</xsl:text>
                        <article-version article-version-type="publication-state">reviewed preprint</article-version>
                        <xsl:text>&#xa;</xsl:text>
                        <article-version article-version-type="preprint-version"><xsl:value-of select="./article-version"/></article-version>
                        <xsl:text>&#xa;</xsl:text>
                    </article-version-alternatives>
                </xsl:when>
                <xsl:otherwise>
                    <article-version article-version-type="publication-state">reviewed preprint</article-version>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[not(name()=('article-id','article-version','article-version-alternatives'))]|*[name()=('article-version','article-version-alternatives')]/following-sibling::text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>-->
    
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
    
    <!-- Change all caps titles to sentence case for known phrases, e.g. REFERENCES -> References -->
    <xsl:template xml:id="all-caps-to-sentence" match="title[(upper-case(.)=. or lower-case(.)=.) and not(*) and not(parent::caption)]">
        <xsl:variable name="phrases" select="(
            'bibliography( (and|&amp;) references?)?',
            '(graphical )?abstract',
            '(materials? (and|&amp;)|experimental)?\s?methods?( details?|summary|(and|&amp;) materials?)?',
            '(supplement(al|ary)? )?materials( (and|&amp;) correspondence)?',
            '(model|methods?)(( and| &amp;) (results|materials?))?',
            'introu?duction',
            '(results?|conclusions?)( (and|&amp;) discussion)?',
            'ac?knowled?ge?ments?',
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

    <!-- Fixes common tagging error with lpage in journal refs -->
    <xsl:template xml:id="journal-ref-lpage" match="mixed-citation[@publication-type='journal' and lpage]">
        <xsl:copy>
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
                        <xsl:copy>
                            <xsl:apply-templates select="@*|*|text()|comment()|processing-instruction()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- Change publication-type="website" to "web" for consistency across all eLife content -->
    <xsl:template xml:id="web-ref-type" match="mixed-citation[@publication-type='website']|element-citation[@publication-type='website']">
        <xsl:copy>
            <xsl:attribute name="publication-type">web</xsl:attribute>
            <xsl:apply-templates select="@*[name()!='publication-type']"/>
            <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Attempt to determine correct type/content for publication-type="other"
            Just trying preprints to begin with -->
    <xsl:template xml:id="other-ref-type" match="mixed-citation[@publication-type='other']">
        <xsl:variable name="preprint-regex" select="'^(biorxiv|africarxiv|arxiv|cell\s+sneak\s+peak|chemrxiv|chinaxiv|eartharxiv|medrxiv|osf\s+preprints|paleorxiv|peerj\s+preprints|preprints|preprints\.org|psyarxiv|research\s+square|scielo\s+preprints|ssrn|vixra)$'"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="matches(lower-case(source[1]),$preprint-regex)">
                    <xsl:attribute name="publication-type">preprint</xsl:attribute>
                    <xsl:apply-templates select="@*[name()!='publication-type']|*|text()|comment()|processing-instruction()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|*|text()|comment()|processing-instruction()"/>    
                </xsl:otherwise>
        </xsl:choose>
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