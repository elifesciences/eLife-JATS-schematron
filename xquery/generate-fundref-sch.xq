declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare variable $sch := doc('../src/schematron.sch');
declare variable $outputDir := substring-before(base-uri($sch),'schematron.sch');

let $fundref := fetch:xml('https://gitlab.com/crossref/open_funder_registry/raw/master/registry.rdf')

let $fundref-pattern := 
<schema
  xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:java="http://www.java.com/"
  xmlns:file="java.io.File"
  xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  queryBinding="xslt2">
<pattern id="fundref">
<rule context="back/ack">
<let name="funders" value="string-join(for $x in ancestor::article//funding-group/award-group/institution return $x,'; ')"/>
  {
  for $funder in $fundref//*:Concept//*:literalForm
  let $y := replace(replace(replace($funder,"&amp;",'&amp;'),"'","&amp;apos;"),'"','&quot;')
  let $name := replace(("' "||$y||" '"),'\.','\\.')
  let $name2 := ("'"||$y||"'")
  let $id := generate-id($funder)
  return
  <report test="{('matches(.,'||$name||') and not(matches($funders,'||$name||'))')}"
        role="warning"
        id="{'fund-ref-'||$id}"></report>
}</rule>
</pattern>
</schema>

return file:write(($outputDir||'test-fundref.sch'),$fundref-pattern)