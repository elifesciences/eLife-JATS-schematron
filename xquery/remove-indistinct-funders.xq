declare function local:non-distinct-values($seq as xs:anyAtomicType*)
  as xs:anyAtomicType*{
   for $val in distinct-values($seq)
   return $val[count($seq[. = $val]) > 1]
 };

declare variable $sch := doc('../src/schematron.sch');
declare variable $src := substring-before($sch/base-uri(),'schematron.sch');
 
let $funders := doc('../src/funders.xml') 
let $non-distinct :=  local:non-distinct-values($funders//*:funder)
let $dates := <list>{
  for $value in $non-distinct
  let $dois := $funders//*:funder[text()=$value]/@fundref/string() 
  let $urls := for $doi in $dois return ('http://data.crossref.org/fundingdata/funder/'||substring-after($doi,'doi.org/'))
  let $json := for $url in $urls return json:parse(fetch:text($url))
  let $latest-time := max(for $data in $json//*:json[descendant::*:prefLabel//*:content/data()=$value]
                          return if ($data//*:modified) then xs:dateTime($data//*:modified)
                               else xs:dateTime($data//*:created))
  let $latest-doi := for $data in $json//*:json[descendant::*:prefLabel//*:content/data()=$value]
                     let $t := if ($data//*:modified) then xs:dateTime($data//*:modified)
                               else xs:dateTime($data//*:created)
                     return if ($data//*:isReplacedBy) then ()
                     else if ($data//*:replaces) then $data/*:id
                     else if ($t=$latest-time) then $data/*:id
                     else ()
  return <item fundref="{$latest-doi}">{$value}</item>
}</list>

let $new-funders := copy $copy := $funders
  modify(
    for $funder in $copy//*:funder[.=$non-distinct]
    let $doi := $funder/@fundref
    let $latest-doi := $dates//*:item[text()=$funder/text()]/@fundref
    let $dx-doi := ('http://dx.doi.org/'||substring-after($latest-doi,'doi.org/'))
    return if ($doi=$dx-doi) then ()
    else delete node $funder
    )
return $copy
  
return file:write(($src||'funders.xml'),$new-funders)