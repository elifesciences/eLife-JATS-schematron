declare variable $sch := doc('../src/schematron.sch');

let $src := substring-before($sch/base-uri(),'schematron.sch')

let $file := fetch:text('https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry')
let $languages := <languages type="IETF-RFC-5646">{
  for $x in tokenize($file,'%\n')[.!='']
  let $type := replace(substring-after($x,'Type: '),'\n.*','')
  where $type=('language','extlang')
  let $subtag := replace(substring-after($x,'Subtag: '),'\n.*','')
  return <item type="{$type}" subtag="{$subtag}">{
    for $y in tokenize($x,'Description:')[matches(.,'^\s')]
    return <description>{replace($y,'^\s|\n.*','')}</description>
  }</item>
}</languages>

return file:write(($src||'languages.xml'),$languages, map{"indent":"yes"})