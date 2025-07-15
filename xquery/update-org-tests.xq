declare function local:ref-update($path as xs:string, $orgs as node()*, $isPass as xs:boolean){
  let $xml := doc($path)
  let $new-xml := copy $copy := $xml
                  modify (
                    let $node := if ($isPass) then (
                      <article>{
                        for $x in $orgs
                        return (<element-citation><article-title><italic>{$x/text()}</italic></article-title></element-citation>,'&#10;')
                      }</article>
                    ) 
                    else (
                      <article>{
                        for $x in $orgs
                        return (<element-citation><article-title>{$x/text()}</article-title></element-citation>,'&#10;')
                      }</article>
                    )
                    return replace node $copy//*:article with $node
                  )
                  return $copy
  return file:write($path,$new-xml)
};

declare function local:title-update($path as xs:string, $orgs as node()*, $isPass as xs:boolean){
  let $xml := doc($path)
  let $new-xml := copy $copy := $xml
                  modify (
                    let $node := if ($isPass) then (
                      <body>{
                        for $x in $orgs
                        return (<sec><title><italic>{$x/text()}</italic></title></sec>,'&#10;')
                      }</body>
                    ) 
                    else (
                      <body>{
                        for $x in $orgs
                        return (<sec><title>{$x/text()}</title></sec>,'&#10;')

                      }</body>
                    )
                    return if ($copy//*:body) then (replace node $copy//*:body with $node)
                    else insert node $node into $copy//*:article
                  )
                  return $copy
  return file:write($path,$new-xml)
};

let $base := doc('../src/schematron.sch')
let $base-uri := substring-before(base-uri($base),'src')
let $folder := $base-uri||"/test/tests/gen/"
let $research-organisms := doc($base-uri||'src/research-organisms.xml')//*:organism

for $folder in ($base-uri||'test/tests/gen/org-title-kwd/article-title-organism-check/',
                $base-uri||'test/tests/gen/org-ref-article-book-title/ref-article-title-organism-check/')
let $pass-file := $folder||'pass.xml'
let $fail-file := $folder||'fail.xml'
return if (contains($folder,'org-ref-article-book-title')) then (
        local:ref-update($pass-file,$research-organisms,true()),
        local:ref-update($fail-file,$research-organisms,false())
      )
else (
  local:title-update($pass-file,$research-organisms,true()),
  local:title-update($fail-file,$research-organisms,false())
)