declare variable $rors := doc('../../src/rors.xml');
declare variable $src := substring-before($rors/base-uri(),'rors.xml');
declare variable $grant-folder := substring-before($src,'src/')||'grant-dois/';

declare variable $horizon-dois := ('10.13039/100018693','10.13039/100018694','10.13039/100018695','10.13039/100018696','10.13039/100018697','10.13039/100018698','10.13039/100018699','10.13039/100018700','10.13039/100018701','10.13039/100018702','10.13039/100018703','10.13039/100018704','10.13039/100018705','10.13039/100018706','10.13039/100018707','10.13039/100019180','10.13039/100019185','10.13039/100019186','10.13039/100019187','10.13039/100019188');

let $crossref-grant-data := for $file in file:list($grant-folder)[contains(.,'crossref') and ends-with(.,'.json')]
               let $json := json:parse(file:read-text($grant-folder||$file))
               return $json//*:items/*
               
let $grants := <grants>{(
               for $item in $crossref-grant-data
               let $doi := $item/DOI
               let $award := $item/award
               let $funder-doi := $item/project[1]/*[1]/funding[1]/*[1]/funder[1]/id[1]/*[1]/id[1]
               where $funder-doi=$horizon-dois
               order by $funder-doi
               return <grant doi="{$doi}" award="{$award}" funder="{$funder-doi}"/>
           )}</grants>
               
let $new-rors := 
  copy $copy := $rors
  modify (
    for $ror in $copy//*:ror[*:id[@type="ror"]='https://ror.org/00k4n6c32']
      return replace node $ror with <ror status="{$ror/@status}" grant-dois="yes">
            {(
              $ror/*:id,
              for $id in $horizon-dois return <id type="fundref" preferred="no">{'http://dx.doi.org/'||$id}</id>,
              $ror/*:grant,
              $grants/*)}
           </ror>
    )
  return $copy
 
return (
  file:write($src||'rors.xml',$new-rors,map{"indent":"yes"}),
  file:delete($grant-folder,true())
)