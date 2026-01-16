<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:java="http://www.java.com/"
   xmlns:file="java.io.File"
   xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
   xmlns:mml="http://www.w3.org/1998/Math/MathML"
   xmlns:meca="http://manuscriptexchange.org"
   xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
   xmlns:api="java:org.elifesciences.validator.ApiCache"
   queryBinding="xslt2">
    
    <ns uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
    <ns uri="http://www.w3.org/2001/XInclude" prefix="xi"/>
    <ns uri="http://saxon.sf.net/" prefix="saxon"/>
    <ns uri="http://purl.org/dc/terms/" prefix="dc"/>
    <ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <ns uri="https://elifesciences.org/namespace" prefix="e"/>
    <ns uri="java.io.File" prefix="file"/>
    <ns uri="java:org.elifesciences.validator.ApiCache" prefix="api"/>
    <ns uri="http://www.java.com/" prefix="java"/>
    <ns uri="http://manuscriptexchange.org" prefix="meca"/>
    
    <pattern>
        <rule context="sub-article[@article-type='editor-report']/front-stub" flag="local-only" id="assessment-api-check">
        <let name="article-id" value="ancestor::article//article-meta/article-id[@pub-id-type='publisher-id']"/>
        <let name="prev-version" value="'1'"/>
        <let name="epp-response" value="if ($article-id and $prev-version) then parse-json(api:getRPData($article-id,$prev-version))
                                        else ('')"/>
        <let name="epp-assessment-data" value="$epp-response?elifeAssessment"/>
        <let name="prev-strength-terms" value="$epp-assessment-data?strength?*"/>
        <let name="prev-significance-terms" value="$epp-assessment-data?significance?*"/>
        
        <assert test="false()" 
        role="error" 
        id="kwd-api-check">Str: <value-of select="$prev-strength-terms"/>. Sig: <value-of select="$prev-significance-terms"/></assert>
        
      </rule>
    </pattern>
    
</schema>