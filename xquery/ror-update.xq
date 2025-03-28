declare variable $sch := doc('../src/schematron.sch');

let $src := substring-before($sch/base-uri(),'schematron.sch')

(: Get latest zip from https://doi.org/10.5281/zenodo.7926988 :)
let $json := json:parse(file:read-text('/Users/fredatherden/Desktop/ror.json'))

let $list := 
<rors>{
  for $x in $json/*:json/*:_
  let $id := $x/*:id
  let $name := <name>{$x/*:names/*[*:types[*='ror_display']]/*:value/data()}</name>
  let $cities := for $y in $x/*:locations/*/*:geonames__details/*:name
                 return <city>{data($y)}</city>
  (: standardise coutry names according to our style in countries.xml :)
  let $country-name := $x/*:locations/*[1]/*:geonames__details/*:country__name/text()
  let $country-code := $x/*:locations/*[1]/*:geonames__details/*:country__code/text()
  let $country-val := switch($country-name)
                        case 'South Korea' return 'Republic of Korea'
                        case 'North Korea' return "Democratic People's Republic of Korea"
                        case 'Iran' return 'Islamic Republic of Iran'
                        case 'Russia' return 'Russian Federation'
                        case 'Czechia' return 'Czech Republic'
                        case 'Ivory Coast' return "Côte d'Ivoire"
                        case 'Syria' return 'Syrian Arab Republic'
                        case 'Vietnam' return 'Viet Nam'
                        case 'Tanzania' return 'United Republic of Tanzania'
                        case 'Laos' return "Lao People's Democratic Republic"
                        case 'Palestine' return 'State of Palestine'
                        case 'Palestinian Territory' return 'State of Palestine'
                        default return $country-name
  let $country := <country country="{$country-code }">{$country-val}</country>
  return <ror>{($id,$name,$cities,$country)}</ror>
}</rors>

return file:write(($src||'rors.xml'),$list, map{"indent":"yes"})