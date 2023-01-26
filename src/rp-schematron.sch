<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <pattern>
        <rule context="contrib">
            <report test="collab" role="warning" id="test-collab-presence">This article includes a group author - ensure it displays correctly.</report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="app-group|app[not(parent::app-group)]">
            <report test="." role="warning" id="test-appendix-presence">This article includes one or more appendices - ensure these display correctly.</report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="table-wrap">
            <report test="count (graphic) gt 1" role="warning" id="test-multi-table-presence">This table has multiple slides, ensure all of these display correctly.</report>
        </rule>
    </pattern>
</schema>