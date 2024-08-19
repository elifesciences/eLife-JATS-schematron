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
    
    <xsl:template match="mixed-citation[not(person-group[@person-group-type='author'])]">
        <xsl:variable name="name-elems" select="('name','string-name','collab','on-behalf-of','etal')"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="./*[name()=$name-elems]">
                    <xsl:apply-templates select="@*"/>
                    <xsl:element name="person-group">
                    <xsl:attribute name="person-group-type">author</xsl:attribute>
                        <xsl:for-each select="./*[name()=$name-elems]|./text()[following-sibling::*[name()=$name-elems]]">
                            <xsl:copy>
                              <xsl:apply-templates select="@*|*|text()|comment()|processing-instruction()"/>
                            </xsl:copy>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:for-each select="./*[not(name()=$name-elems)]|./*[name()=$name-elems][last()]/following-sibling::text()|./text()[preceding-sibling::*[not(name()=$name-elems)]]">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|*|text()|comment()|processing-instruction()"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>