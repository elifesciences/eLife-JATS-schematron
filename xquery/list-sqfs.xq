(:
https://docs.google.com/spreadsheets/d/1M2agfNez77uKvlFGG-JogiAVjnPdW9M32mdjwjDtp5Y/edit?gid=0#gid=0
:)

let $rp-sch := doc('../src/rp-schematron-base.sch')
let $fixes := $rp-sch//*:fix

for $x in $rp-sch//*[name()=('report','assert') and @*:fix]
let $id := if ($x/@see) then '=HYPERLINK("'||$x/@see||'","'||$x/@id||'")'
           else $x/@id
let $fix-titles := for $fix-id in tokenize($x/@*:fix,'\s+')
                   let $fix := $fixes[@*:id = $fix-id]
                   return $fix//*:title/data()
return string-join((
  $id,
  string-join($fix-titles,' | ')
),'	')