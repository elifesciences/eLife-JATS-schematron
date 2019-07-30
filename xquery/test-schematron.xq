(: 
Splits out schematron.xq into schemalets consisting only of one test. This schemalet is then validated against a pass and fail file.
item/@status in the output report indicates which test cases pass and fail. 
An output with no item[@status="fail"] would indicate that all tests have passed.  
:)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";
import module namespace test = 'test' at 'test.xqm';

<result>{
let $base := doc('../schematron.sch')
let $base-uri := substring-before(base-uri($base),'/schematron.sch')

(: Select every test except for graphic-media-presence, which uses a Java method BaseX is unable to handle :)
for $test in $base//(*:assert|*:report)[not(@id='graphic-media-presence')]
let $rule-id := $test/parent::*:rule/@id
let $path := concat($base-uri,'/tests/',$rule-id,'/',$test/@id,'/')
let $pass := concat($path,'pass.xml')
let $fail := concat($path,'fail.xml')
let $element := test:get-context($test)

return 
  
if (file:exists($pass) and file:exists($fail)) then

   let $schema-let := test:schema-let($test)
   let $sch := schematron:compile($schema-let)
   let $sch-pass := test:validate($pass,$sch)
   let $sch-fail := test:validate($fail, $sch)
   order by lower-case($rule-id)
   return
   
  (
   if (test:message-ids($sch-pass) = $test/@id) then <item id="{$test/@id}" type="pass" status="failed"/>
   else if (not(doc($pass)//*/local-name() = $element)) then <item id="{$test/@id}" type="pass" status="failed"/>
   else <item id="{$test/@id}" type="pass" status="passed"/>
  ,
  if (test:message-ids($sch-fail) = $test/@id) then <item id="{$test/@id}" type="fail" status="passed"/>
   else <item id="{$test/@id}" type="fail" status="failed"/>
  )
  
  
else ()

}</result>