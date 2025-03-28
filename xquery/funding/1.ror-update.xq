declare variable $sch := doc('../../src/schematron.sch');
(: Get latest zip from https://doi.org/10.5281/zenodo.7926988 :)
let $json := json:parse(file:read-text('/Users/fredatherden/Desktop/ror.json'))
let $src := substring-before($sch/base-uri(),'schematron.sch')
let $api-query := 'https://api.crossref.org/works?filter=type-name:Grant&amp;facet=funder-doi:*'
let $response := json:parse(fetch:text($api-query))
let $grant-doi-registering-funder-dois := for $obj in $response//*:facets/*:funder-doi/*:values/* 
                                          return 'http://dx.doi.org/10.'||replace(substring-after($obj/name(),'10.'),'_002f','/')
let $list := 
<rors>{
  for $x in $json/*:json/*:_
  let $id := $x/*:id
  let $pref-fundref := $x/*:external__ids/*[*:type='fundref']/*:preferred
  let $fundrefs := for $y in $x/*:external__ids/*[*:type='fundref']/*:all/*/text()
                   return if ($pref-fundref[@type="null"]) then <fundref>{'http://dx.doi.org/10.13039/'||$y}</fundref>
                   else if ($y=$pref-fundref) then <fundref preferred="yes">{'http://dx.doi.org/10.13039/'||$y}</fundref>
                   else <fundref preferred="no">{'http://dx.doi.org/10.13039/'||$y}</fundref>
  let $registers-grant-dois := if (some $link in $fundrefs satisfies $link=$grant-doi-registering-funder-dois) then 'yes' else 'no'
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
  return <ror grant-dois="{$registers-grant-dois}">{($id,$fundrefs,$name,$cities,$country)}</ror>
}</rors>

return file:write(($src||'rors.xml'),$list, map{"indent":"yes"})