<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
   xmlns:meca="http://manuscriptexchange.org"
   queryBinding="xslt2">

    <ns uri="http://manuscriptexchange.org" prefix="meca"/>
    
    <title>eLife MECA manifest schematron</title>

    <pattern id="indistinct-files">
     <rule context="meca:instance" id="distinct-file-checks">
        <report test="@href = preceding::meca:instance/@href"
        role="error" 
        id="indictinct-file">Instance for <value-of select="parent::meca:item/meca:title"/> has the same file as another item within the manifest - <value-of select="@href"/>.</report>
     </rule>
    </pattern>

    <pattern id="item">
     <rule context="meca:item" id="item-checks">
        <let name="allowed-types" value="('article','figure','equation','inlineequation','inlinefigure','table','supplement','video','transfer-details','x-hw-directives')"/>
        <assert test="@type"
        role="error" 
        id="item-type-presence">Item element must have a type attribute with one of the following permitted values: <value-of select="string-join($allowed-types,'; ')"/>. This one does not have a type value.</assert>
        
        <report test="@type and not(@type = $allowed-types)"
        role="error" 
        id="item-type-">Item element has a type attribute with the value '<value-of select="@type"/>' which is not one of the permitted values: <value-of select="string-join($allowed-types,'; ')"/>.</report>
     </rule>
    </pattern>
    
</schema>