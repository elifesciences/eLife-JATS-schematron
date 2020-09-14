let $base := doc('../src/schematron.sch')
let $base-uri := substring-before(base-uri($base),'/schematron.sch')
let $root := substring-before($base-uri,'/src')
let $test-path := ($root||'/test/tests/gen/')

let $files := file:list($test-path)[.!='.DS_Store']
let $dirs := 
<list>{for $dir in $files 
let $cases := ($test-path||$dir)
return 
  for $x in file:list($cases)[.!='.DS_Store']
  return <dir id="{tokenize(replace($x,'/$',''),'/')[last()]}">{$test-path||$dir||$x}</dir>}</list>

for $x in $dirs//*:dir[not(@id=('abstract-test-7','p-test-1','gen-country-iso-3166-test'))]
let $id := $x/@id
return if ($base//*[@id = $id]) then ()
else $x
