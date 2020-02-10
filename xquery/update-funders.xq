declare variable $sch := doc('../src/schematron.sch');

let $src := substring-before($sch/base-uri(),'schematron.sch')

let $fundref := fetch:xml('https://gitlab.com/crossref/open_funder_registry/raw/master/registry.rdf')

let $list := <funders>{
  for $x in $fundref//*:Concept//*:prefLabel
  let $link := $x/ancestor::*:Concept/@*:about/string()
  let $r := replace($x//*:literalForm/data(),'\.','')
  let $text := if (matches($r,'[A-Z] [A-Z] [A-Z] ')) then 
                  replace(string-join(
                    for $x in analyze-string($r,'[A-Z] [A-Z] [A-Z] ')/* 
                    return if ($x/local-name()='match') then replace($x,' ','') 
                    else $x,' '),'\s{2,}',' ')
               else if (matches($r,'[A-Z] [A-Z] ')) then 
                  replace(string-join(
                    for $x in analyze-string($r,'[A-Z] [A-Z] ')/* 
                    return if ($x/local-name()='match') then replace($x,' ','') 
                    else $x,' '),'\s{2,}',' ')
               else replace($r,'\s{2,}',' ')
               
  return <funder fundref="{$link}">{$text}</funder> 
}</funders>

return file:write(($src||'funders.xml'),$list)