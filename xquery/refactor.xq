(:
 ~ This query generates the pre, final, and final-package Schematron files from the base schematron.sch.
 ~ It also generates the xspec and manipulated version of schematron.sch, as well as updating any schemalet files and writing new test files at the same time, for the purposes of testing. 
 
 :)
import module namespace schematron = "http://github.com/Schematron/schematron-basex";
import module namespace elife = 'elife' at 'elife.xqm';
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";

(: base schematron file :)
declare variable $sch := doc('../src/schematron.sch');

(: sch output directory :)
declare variable $outputDir := substring-before(base-uri($sch),'/schematron.sch');

(: repo root :)
declare variable $root := substring-before($outputDir,'/src');

(: copy edit schematron file :)
declare variable $copy-edit-sch := doc(concat($outputDir,'/copy-edit.sch'));

(
  for $sch in $sch/sch:schema
  (: Permitted role values :)
  let $roles := ('error','warning','info')
  (: schematron for pre-author :)
  let $pre-sch := elife:sch2pre($sch)
  (: schematron for post-author :)
  let $final-sch := elife:sch2final($sch)
  (: schematron for final-package - niche use :)
  let $final-package-sch :=  elife:sch2final-package($sch)
  (: Generate xspec specific sch :)
  let $xspec-sch := elife:sch2xspec-sch($sch)
  (: Generate xspec file from xspec specific sch :)
  let $xspec := elife:sch2xspec($xspec-sch)


  return (
    (: error if file contains unallowed role values :)
    elife:unallowed-roles($sch,$roles),
    file:write(($outputDir||'/pre-JATS-schematron.sch'),$pre-sch),
    file:write(($outputDir||'/final-JATS-schematron.sch'),$final-sch),
    
    file:write(($outputDir||'/final-package-JATS-schematron.sch'),$final-package-sch),
    file:write(($root||'/test/xspec/schematron.sch'),$xspec-sch),
    file:write(($root||'/test/xspec/schematron.xspec'),$xspec)
  )
,

  for $sch2 in $copy-edit-sch/sch:schema
  let $copy-edit-xspec := elife:copy-edit2xspec($sch2)
  return (
    file:write(($root||'/test/xspec/copy-edit.sch'),$sch2),
    file:write(($root||'/test/xspec/copy-edit.xspec'),$copy-edit-xspec)
  )
,
  
  for $file in file:list($outputDir)[matches(.,'\.xml')]
  let $xml := doc(($outputDir||'/'||$file))
  return (
    file:write(($root||'/test/xspec/'||$file),$xml)
  )
)