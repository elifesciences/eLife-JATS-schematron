<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">

<pattern>
    
    <rule context="article">
        
        <assert test="body">There must be a body in article</assert>
        
    </rule>
    
</pattern>

</sch:schema>