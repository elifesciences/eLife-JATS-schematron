declare variable $rors := doc('../../src/rors.xml');
declare variable $src := substring-before($rors/base-uri(),'rors.xml');
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

let $new-rors := 
  copy $copy := $rors
  modify (
    for $ror in $copy//*:ror[@grant-dois="yes"]
    let $dois := for $fundref in $ror/*:fundref return substring-after($fundref,'doi.org/')
    let $funder-grants := $grants//*:grant[@funder=$dois]
    return replace node $ror with <ror grant-dois="{$ror/@grant-dois}">
            {($ror/*,$funder-grants)}
           </ror>
  )
  return $copy
 
return (
  file:write($src||'rors.xml',$new-rors,map{"indent":"yes"}),
  file:delete($grant-folder,true())
)
