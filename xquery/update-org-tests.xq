declare function local:ref-update($path as xs:string, $org as xs:string, $isPass as xs:boolean){
  let $xml := doc($path)
  let $new-xml := copy $copy := $xml
                  modify (
                    if ($isPass) then insert node <element-citation><article-title><italic>{upper-case(substring($org,1,1))||substring($org,2)}</italic></article-title></element-citation> into $copy//*:article
                    else insert node <element-citation><article-title>{upper-case(substring($org,1,1))||substring($org,2)}</article-title></element-citation> into $copy//*:article)
                  return $copy
  return file:write($path,$new-xml)
};

declare function local:tit-update($path as xs:string, $org as xs:string, $isPass as xs:boolean){
  let $xml := doc($path)
  let $new-xml := copy $copy := $xml
                  modify (
                    if ($isPass) then insert node <body><sec><title><italic>{upper-case(substring($org,1,1))||substring($org,2)}</italic></title></sec></body> into $copy//*:article
                    else insert node <body><sec><title>{upper-case(substring($org,1,1))||substring($org,2)}</title></sec></body> into $copy//*:article)
                  return $copy
  return file:write($path,$new-xml)
};

let $base := doc('../src/schematron.sch')
let $base-uri := substring-before(base-uri($base),'src')
let $folder := $base-uri||"/test/tests/gen/"

for $x in tokenize('Albugo candida
Beta macrocarpa
Beta patula
Beta vulgaris
Cercospora beticola
Hemileia vastatrix
Melampsora lini
Neurospora discreta
Phakopsora pachyrhizi
Phytophthora infestans
Puccinia striiformis
Uromyces fabae','\n')
return 
  if (contains($x,' ')) then 
  let $z := replace($x,' ','')
  let $y := substring($x,1,1)||substring-after($x,' ')
  let $y-display := substring($x,1,1)||'. '||substring-after($x,' ')
  let $y-ref-pass := $folder||"org-ref-article-book-title/"||$y||"-ref-article-title-check/pass.xml"
  let $y-ref-fail := $folder||"org-ref-article-book-title/"||$y||"-ref-article-title-check/fail.xml"
  let $z-ref-pass := $folder||"org-ref-article-book-title/"||$z||"-ref-article-title-check/pass.xml"
  let $z-ref-fail := $folder||"org-ref-article-book-title/"||$z||"-ref-article-title-check/fail.xml"
  let $y-tit-pass := $folder||"org-title-kwd/"||$y||"-article-title-check/pass.xml"
  let $y-tit-fail := $folder||"org-title-kwd/"||$y||"-article-title-check/fail.xml"
  let $z-tit-pass := $folder||"org-title-kwd/"||$z||"-article-title-check/pass.xml"
  let $z-tit-fail := $folder||"org-title-kwd/"||$z||"-article-title-check/fail.xml"
  return (
    local:ref-update($y-ref-pass,$y-display,true()),
    local:ref-update($y-ref-fail,$y-display,false()),
    local:ref-update($z-ref-pass,$x,true()),
    local:ref-update($z-ref-fail,$x,false()),
    local:tit-update($y-tit-pass,$y-display,true()),
    local:tit-update($y-tit-fail,$y-display,false()),
    local:tit-update($z-tit-pass,$x,true()),
    local:tit-update($z-tit-fail,$x,false())
  )
  else (
    let $x-ref-pass := $folder||"org-ref-article-book-title/"||$x||"-ref-article-title-check/pass.xml"
    let $x-ref-fail := $folder||"org-ref-article-book-title/"||$x||"-ref-article-title-check/fail.xml"
    let $x-tit-pass := $folder||"org-title-kwd/"||$x||"-article-title-check/pass.xml"
    let $x-tit-fail := $folder||"org-title-kwd/"||$x||"-article-title-check/fail.xml"
    return (
      local:ref-update($x-ref-pass,$x,true()),
      local:ref-update($x-ref-fail,$x,false()),
      local:tit-update($x-tit-pass,$x,true()),
      local:tit-update($x-tit-fail,$x,false())
    )  
  )