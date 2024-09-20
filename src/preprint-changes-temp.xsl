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

    <xsl:template match="*[name()=('sec','app')]/title">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="not(*) and .=upper-case(.)">
                    <xsl:apply-templates select="@*"/>
                    <xsl:value-of select="concat(substring(.,1,1),lower-case(substring(.,2)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>