declare variable $sch := doc('../src/schematron.sch');

let $src := substring-before($sch/base-uri(),'schematron.sch')

(: Get latest zip from https://github.com/ror-community/ror-data :)
let $json := json:parse(file:read-text('/Users/fredatherden/Desktop/ror.json'))

let $list := 
<rors>{
  for $x in $json/*:json/*:_
  let $id := $x/*:id
  let $name := $x/*:name 
  let $cities := for $y in $x/*:addresses/*:_/*:city
                 return $y
  let $country := <country country="{$x/country/*:country__code}">{$x/country/*:country__name/text()}</country>
  return <ror>{($id,$name,$cities,$country)}</ror> 
}</rors>

return file:write(($src||'rors.xml'),$list)