declare variable $funders := doc('../../src/funders.xml');
declare variable $src := substring-before($funders/base-uri(),'funders.xml');
declare variable $grant-folder := substring-before($src,'src/')||'grant-dois/';

let $grant-data := for $file in file:list($grant-folder)[ends-with(.,'.json')]
               let $json := json:parse(file:read-text($grant-folder||$file))
               return $json//*:items/*

let $grants := <grants>{for $item in $grant-data
               let $doi := $item/DOI
               let $award := $item/award
               let $funder-doi := $item/project[1]/*[1]/funding[1]/*[1]/funder[1]/id[1]/*[1]/id[1]
               order by $funder-doi
               return <grant doi="{$doi}" award="{$award}" funder="{$funder-doi}"/>}</grants>

let $new-funders := 
  copy $copy := $funders
  modify (
    for $funder in $copy//*:funder[@grant-dois="yes"]
    let $doi := substring-after($funder/@fundref,'doi.org/')
    let $funder-grants := $grants//*:grant[@funder=$doi]
    return replace node $funder with <funder grant-dois="{$funder/@grant-dois}" fundref="{$funder/@fundref}">
            {($funder/*:name,$funder-grants)}
           </funder>
  )
  return $copy
 
return (
  file:write($src||'funders.xml',$new-funders,map{"indent":"yes"}),
  file:delete($grant-folder,true())
)
