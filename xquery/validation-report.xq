(: In order for this query to function you have to installed the schematron module for BaseX:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";

let $path := '/Users/fredatherden/desktop/elife51810-2.xml'
let $schema := doc('../src/pre-JATS-schematron.sch')
let $src := substring-before($schema/base-uri(),'pre-JATS-schematron')
let $xml := doc($path)
let $filename := tokenize($path,'/')[last()]
let $folder := substring-before($path,$filename)
let $report-path := ($folder||substring-before($filename,'.xml')||'-report.xml')

let $schema2 := copy $copy := $schema
                modify(
                  for $x in $copy//*:let[@name=("journals","countries","publisher-locations")]
                  return replace value of node $x/@value with concat("'",$src,replace($x/@value/string(),"'",''),"'")
                )
                return $copy
let $sch := schematron:compile($schema2)
let $svrl := schematron:validate($xml, $sch)

let $report-1 := <report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:file="java.io.File" xmlns:java="http://www.java.com/">{$svrl//(*:failed-assert|*:successful-report)}</report>

let $report-2 := copy $copy := $report-1
modify(  
  for $y in $copy//(*:failed-assert|*:successful-report)
  return delete node $y/@test
)
return $copy

return file:write($report-path,$report-2)



