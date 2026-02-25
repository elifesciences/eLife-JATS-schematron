declare variable $rors := doc('../../src/rors.xml');
declare variable $src := substring-before($rors/base-uri(),'rors.xml');
declare variable $grant-folder := substring-before($src,'src/')||'grant-dois/';

let $crossref-grant-data := for $file in file:list($grant-folder)[contains(.,'crossref') and ends-with(.,'.json')]
               let $json := json:parse(file:read-text($grant-folder||$file))
               return $json//*:items/*

let $datacite-grant-data := for $file in file:list($grant-folder)[contains(.,'datacite') and ends-with(.,'.json')]
               let $json := json:parse(file:read-text($grant-folder||$file))
               return $json//*:data/*

let $datacite-funder-rors := distinct-values($datacite-grant-data//*:attributes/*:creators/*[1]/*:nameIdentifiers/*[*:nameIdentifierScheme='ROR']/*:nameIdentifier)

let $grants := <grants>{(
               for $item in $crossref-grant-data
               let $doi := $item/DOI
               let $award := $item/award
               let $funder-doi := $item/project[1]/*[1]/funding[1]/*[1]/funder[1]/id[1]/*[1]/id[1]
               order by $funder-doi
               return <grant doi="{$doi}" award="{$award}" funder="{$funder-doi}"/>,
               
               for $item in $datacite-grant-data
               let $doi := $item/*:id
               let $award := $item/*:attributes/*:identifiers/*[*:identifierType='award-number']/*:identifier
               let $funder-ror := $item/*:attributes/*:creators/*[1]/*:nameIdentifiers/*[*:nameIdentifierScheme='ROR']/*:nameIdentifier
               order by $funder-ror
               return <grant doi="{$doi}" award="{$award}" funder="{$funder-ror}"/>
           )}</grants>

let $grants-by-funder := map:merge(
  for $funder-key in distinct-values($grants//*:grant/@funder)
  return map:entry($funder-key, $grants//*:grant[@funder = $funder-key]),
   map { "duplicates": "combine" }
)

let $new-rors := 
  copy $copy := $rors
  modify (
    for $ror in $copy//*:ror
    let $ror-id := $ror/*:id[@type="ror"]
    return if ($ror/@grant-dois="yes" or $ror-id=$datacite-funder-rors) then (
      let $dois := for $fundref in $ror/*:id[@type="fundref"] return substring-after($fundref,'doi.org/')
      let $funder-grants := for $key in ($dois, $ror-id)
                            return $grants-by-funder($key)
      return replace node $ror with <ror status="{$ror/@status}" grant-dois="yes">
            {($ror/*,$funder-grants)}
           </ror>
    )
    else replace node $ror with $ror
  )
  return $copy
  
return (
  file:write($src||'rors.xml',$new-rors,map{"indent":"yes"})
)