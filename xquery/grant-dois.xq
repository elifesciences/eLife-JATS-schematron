(: Overall list of funders that register grants is available here https://api.crossref.org/works?filter=type-name:Grant&facet=funder-doi:* :)
declare variable $funders := doc('../src/funders.xml');
declare variable $src := substring-before($funders/base-uri(),'funders.xml');
declare variable $temp-folder := $src||'/grant-data/';

declare function local:get-grant-data(
                       $grants as node()*,
                       $funder-doi as xs:string,
                       $folder as xs:string,
                       $count as xs:integer,
                       $cursor as xs:string
                     ) 
                       as node()* {
  if ($cursor='null') then ()
  else (
   let $api-call := 'https://api.crossref.org/works?filter=award.funder:'||web:encode-url($funder-doi)||',type:grant&amp;rows=1000&amp;cursor='||web:encode-url($cursor)
   let $response := http:send-request(<http:request method='get' href="{$api-call}" timeout='20'/>)
   let $json := $response//*:json
   let $next-cursor := if ($json//*:items/*) then $json//*:next-cursor
                       else 'null'
   let $grants := <funder doi="{$funder-doi}">{
                   for $x in $json//*:items/*
                   return <grant doi="{$x/DOI}" award="{$x/award}"/>
                  }</funder>      
   return (
     file:write($folder||string($count)||'.xml',$grants),
     let $new-count := $count + 1 
     return local:get-grant-data($grants,$funder-doi,$folder,$new-count,$next-cursor)
   )
  )
};

(
  if (not(file:exists($temp-folder))) then file:create-dir($temp-folder),
  
  for $funder in $funders//*:funder[@grant-dois="yes"]
  let $doi := substring-after($funder/@fundref,'.org/')
  let $folder := $temp-folder||replace($doi,'/','-')||'/'
  return (
    file:create-dir($folder),
    local:get-grant-data(<grant/>,$doi,$folder,1,'*')
  ),
  

  let $new-xml := copy $copy := $funders
                  modify(
                   for $funder in $copy//*:funder[@grant-dois="yes"]
                   let $doi := substring-after($funder/@fundref,'.org/')
                   let $folder := $temp-folder||replace($doi,'/','-')||'/'
                   let $all-grants := for $file in file:list($folder)[.!='.DS_Store']
                                      let $xml := doc($folder||$file)
                                      return $xml//*:grant

                   for $grant in $all-grants
                   where $grant[@doi and @award]
                   return insert node $grant as last into $funder
                  )
                  return $copy

  return file:write(($src||'funders.xml'),$new-xml),

  file:delete($temp-folder,true())

)
