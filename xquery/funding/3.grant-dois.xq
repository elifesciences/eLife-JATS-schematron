declare variable $rors := doc('../../src/rors.xml');
declare variable $src := substring-before($rors/base-uri(),'rors.xml');
declare variable $grant-folder := substring-before($src,'src/')||'grant-dois/';

let $crossref-grants-by-funder := map:merge(
  for $file in file:list($grant-folder)[contains(.,'crossref') and ends-with(.,'.json')]
  let $json := json:parse(file:read-text($grant-folder||$file))
  for $item in $json//*:items/*
  let $funder-doi := $item/project[1]/*[1]/funding[1]/*[1]/funder[1]/id[1]/*[1]/id[1]
  where exists($funder-doi)
  let $grant := <grant doi="{$item/DOI}" award="{$item/award}" funder="{$funder-doi}"/>
  group by $funder-doi
  return map:entry($funder-doi, $grant),
  map { "duplicates": "combine" }
)

let $datacite-grants-by-funder := map:merge(
  for $file in file:list($grant-folder)[contains(.,'datacite') and ends-with(.,'.json')]
  let $json := json:parse(file:read-text($grant-folder||$file))
  for $item in $json//*:data/*
  let $funder-ror := $item/*:attributes/*:creators/*[1]/*:nameIdentifiers/*[*:nameIdentifierScheme='ROR']/*:nameIdentifier
  where exists($funder-ror)
  let $grant := <grant doi="{$item/*:id}" award="{$item/*:attributes/*:identifiers/*[*:identifierType='award-number']/*:identifier}" funder="{$funder-ror}"/>
  group by $funder-ror
  return map:entry($funder-ror, $grant),
  map { "duplicates": "combine" }
)

let $datacite-funder-rors := map:keys($datacite-grants-by-funder)

let $grants-by-funder := map:merge(
  ($crossref-grants-by-funder, $datacite-grants-by-funder),
  map { "duplicates": "combine" }
)

let $ror-fundref-map := map:merge(
  for $ror in $rors//*:ror
  let $ror-id := string($ror/*:id[@type="ror"])
  return map:entry(
    $ror-id,
    for $f in $ror/*:id[@type="fundref"] return substring-after($f,'doi.org/')
  )
)

let $new-rors :=
  copy $copy := $rors
  modify (
    for $ror in $copy//*:ror
    let $ror-id := string($ror/*:id[@type="ror"])
    where $ror/@grant-dois="yes" or $ror-id=$datacite-funder-rors
    let $dois := $ror-fundref-map($ror-id)
    let $funder-grants := for $key in ($dois, $ror-id)
                          return $grants-by-funder($key)
    return replace node $ror with
      <ror status="{$ror/@status}" grant-dois="yes">
        {($ror/*, $funder-grants)}
      </ror>
  )
  return $copy

return file:write($src||'rors.xml', $new-rors, map{"indent":"yes"})