declare variable $sch := doc('../src/schematron.sch');
declare variable $outputDir := substring-before(base-uri($sch),'schematron.sch');

let $fundref := fetch:xml('https://gitlab.com/crossref/open_funder_registry/raw/master/registry.rdf')

let $regex :=  ( "' "||
  string-join(
    for $funder in $fundref//*:Concept//*:literalForm/data()
    let $a := replace($funder,"'","&amp;apos;")
    let $b:= replace($a,"&amp;",'&amp;')
    let $c:= replace($b,'\.','\\.')
    let $d := replace($c,'"','&quot;')
    let $e := replace($d,'\(','\\(')
    let $f := replace($e,'\)','\\)')
    let $g := replace($f,'\[','\\[')
    let $h := replace($g,'\]','\\]')
    return 
    $h
  ,
  ' | ')||
  " '"
)

return file:write(($outputDir||'fundref-regex.xml'),<regex>{$regex}</regex>)