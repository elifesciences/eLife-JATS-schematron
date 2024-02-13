declare variable $sch := doc('../../src/schematron.sch');

let $src := substring-before($sch/base-uri(),'schematron.sch')
let $fundref := parse-xml(fetch:text('https://gitlab.com/crossref/open_funder_registry/raw/master/registry.rdf'))
let $api-query := 'https://api.crossref.org/works?filter=type-name:Grant&amp;facet=funder-doi:*'
let $response := json:parse(fetch:text($api-query))
let $grant-doi-registering-funder-dois := for $obj in $response//*:facets/*:funder-doi/*:values/* 
                                          return 'http://dx.doi.org/10.'||replace(substring-after($obj/name(),'10.'),'_002f','/')

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
  let $registers-grant-dois := if ($link=$grant-doi-registering-funder-dois) then 'yes' else 'no'
  return <funder grant-dois="{$registers-grant-dois}" fundref="{$link}">
            <name>{$text}</name>
         </funder> 
}</funders>

return file:write(($src||'funders.xml'),$list,map {"indent":"yes"})