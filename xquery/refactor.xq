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

(: schematron files for preprints :)
declare variable $rp-sch := doc(concat($outputDir,'/rp-schematron-base.sch'));
declare variable $manifest-sch := doc(concat($outputDir,'/meca-manifest-schematron.sch'));

(: Permitted role values :)
declare variable $roles := ('error','warning','info');

(: XSL for preprints :)
declare variable $preprint-changes-xsl := doc(concat($outputDir,'/preprint-changes.xsl'));

(
  for $sch in $sch/sch:schema
  (: schematron for pre-author :)
  let $pre-sch := elife:sch2pre($sch)
   (: schematron for dl only :)
  let $dl-sch := elife:sch2dl($sch)
  (: schematron for post-author :)
  let $final-sch := elife:sch2final($sch)
  (:xsl files for validator:)
  let $pre-xsl := schematron:compile($pre-sch)
  let $dl-xsl := schematron:compile($dl-sch)
  let $final-xsl := schematron:compile($final-sch)
  (: schematron for final-package - niche use :)
  let $final-package-sch := elife:sch2final-package($sch)
  (: Generate xspec specific sch :)
  let $xspec-sch := elife:sch2xspec-sch($sch)
  (: Generate xspec file from xspec specific sch :)
  let $xspec := elife:sch2xspec($xspec-sch,'gen')


  return (
    (: error if file contains unallowed role values :)
    elife:unallowed-roles($sch,$roles),
    file:write(($outputDir||'/pre-JATS-schematron.sch'),$pre-sch),
    file:write(($outputDir||'/dl-schematron.sch'),$dl-sch),
    file:write(($outputDir||'/final-JATS-schematron.sch'),$final-sch),
    file:write(($outputDir||'/pre-JATS-schematron.xsl'),$pre-xsl),
    file:write(($outputDir||'/dl-schematron.xsl'),$dl-xsl),
    file:write(($outputDir||'/final-JATS-schematron.xsl'),$final-xsl),
    file:write(($outputDir||'/final-package-JATS-schematron.sch'),$final-package-sch),
    file:write(($root||'/test/xspec/schematron.sch'),$xspec-sch,map{'indent':'yes'}),
    file:write(($root||'/test/xspec/schematron.xspec'),$xspec,map{'indent':'yes'})
  )
,

  for $rp-sch in $rp-sch/sch:schema
  (: schematron for reviewed preprints - every rule has it's own pattern :)
  let $rp-sch-mod := elife:sch2final($rp-sch)
  let $rp-xsl := schematron:compile($rp-sch-mod)
  (: schematron for manifest files in meca packages :)
  let $manifest-xsl := schematron:compile($manifest-sch)
  (: Generate xspec specific sch :)
  let $rp-xspec-sch := elife:sch2xspec-sch($rp-sch)
  (: Generate xspec file from xspec specific sch :)
  let $rp-xspec := elife:sch2xspec($rp-xspec-sch,'rp')

  
  return (
    (: error if file contains unallowed role values :)
    elife:unallowed-roles($rp-sch,$roles),
    elife:unallowed-roles($manifest-sch,$roles),
    file:write(($outputDir||'/rp-schematron.sch'),$rp-sch-mod),
    file:write(($outputDir||'/rp-schematron.xsl'),$rp-xsl),
    file:write(($outputDir||'/meca-manifest-schematron.xsl'),$manifest-xsl),
    file:write(($root||'/test/xspec/rp-schematron.sch'),$rp-xspec-sch,map{'indent':'yes'}),
    file:write(($root||'/test/xspec/rp-schematron.xspec'),$rp-xspec,map{'indent':'yes'})
  )
  
,
  for $file in file:list($outputDir)[matches(.,'\.xml')]
  let $xml := doc(($outputDir||'/'||$file))
  return (
    file:write(($root||'/test/xspec/'||$file),$xml)
  )
  
,
  (: Generate xspec file for preprint-changes xsl :)
  let $preprint-changes-xspec := elife:xsl2xspec($preprint-changes-xsl,'preprint-changes')
  return (
    file:write(($root||'/test/xspec/preprint-changes.xspec'),$preprint-changes-xspec,map{'indent':'yes'})
  )
)