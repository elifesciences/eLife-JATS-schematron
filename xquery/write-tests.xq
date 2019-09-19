(: Initial creation of test files. This can be continuously ran as tests are added since the schemalet files are always overwritten, but the test files are not in intsnaces where they already exist. :)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";
import module namespace elife = 'elife' at 'elife.xqm';

declare option db:chop 'false';

let $base := doc('../src/schematron.sch')
let $base-uri := substring-before(base-uri($base),'/schematron.sch')
let $root := substring-before($base-uri,'/src')

let $copy-edit-base := doc(concat($base-uri,'/copy-edit.sch'))

return
(
  for $test in $base//(*:assert|*:report)
  let $rule-id := $test/parent::*:rule/@id
  let $path := concat($root,'/test/tests/gen/',$rule-id,'/',$test/@id,'/')
  let $pass := concat($path,'pass.xml')
  let $fail := concat($path,'fail.xml')
  let $schema-let := elife:schema-let($test)

  let $pi-content := ('SCHSchema="'||$test/@id||'.sch'||'"') 
  let $comment := comment{concat('Context: ',$test/parent::*:rule/@context/string(),'
Test: ',$test/local-name(),'    ',normalize-space($test/@test/string()),'
Message: ',replace($test/data(),'-',''))}

  let $node := 
  (processing-instruction {'oxygen'}{$pi-content},
  $comment,
  <root xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xlink="http://www.w3.org/1999/xlink"><article/></root>)

  return 
  (
    if(file:exists($path)) 
    then () 
    else file:create-dir($path)
    ,
    if(file:exists($pass)) then 
      let $new-pass := elife:new-test-case($pass,$comment)
      return file:write($pass,$new-pass,map{'indent':'no'})
    else file:write($pass,$node)
    ,
    if(file:exists($fail)) then 
     let $new-fail := elife:new-test-case($fail,$comment)
      return file:write($fail,$new-fail,map{'indent':'no'})
    else file:write($fail,$node)
    ,
    file:write(concat($path,$test/@id,'.sch'),$schema-let)
  )
,

for $test2 in $copy-edit-base//(*:assert|*:report)
  let $rule-id := $test2/parent::*:rule/@id
  let $path := concat($root,'/test/tests/copy-edit/',$rule-id,'/',$test2/@id,'/')
  let $pass := concat($path,'pass.xml')
  let $fail := concat($path,'fail.xml')
  let $schema-let := elife:copy-edit-schema-let($test2)
  
  let $pi-content := ('SCHSchema="'||$test2/@id||'.sch'||'"') 
  let $comment := comment{concat('Context: ',$test2/parent::*:rule/@context/string(),'
Test: ',$test2/local-name(),'    ',normalize-space($test2/@test/string()),'
Message: ',replace($test2/data(),'-',''))}

  let $node := 
  (processing-instruction {'oxygen'}{$pi-content},
  $comment,
  <root xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xlink="http://www.w3.org/1999/xlink"><article/></root>)
  
 return 
  (
    if(file:exists($path)) 
    then () 
    else file:create-dir($path)
    ,
    if(file:exists($pass)) then 
      let $new-pass := elife:new-test-case($pass,$comment)
      return file:write($pass,$new-pass,map{'indent':'no'})
    else file:write($pass,$node)
    ,
    if(file:exists($fail)) then 
     let $new-fail := elife:new-test-case($fail,$comment)
      return file:write($fail,$new-fail,map{'indent':'no'})
    else file:write($fail,$node)
    ,
    file:write(concat($path,$test2/@id,'.sch'),$schema-let)
  )
)