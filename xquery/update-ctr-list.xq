declare variable $sch := doc('../src/schematron.sch');

let $src := substring-before($sch/base-uri(),'schematron.sch')

let $c := fetch:xml('http://api.crossref.org/works/10.18810/registries/transform/application/vnd.crossref.unixsd+xml')

let $list := 
<registries>{
 for $x in $c//*:component
 return 
 <registry>
 <subtitle>{$x/*:titles/*:subtitle/data()}</subtitle>
 <doi>{$x/*:doi_data/*:doi/data()}</doi>
 </registry> 
}</registries>

return file:write(($src||'clinical-trial-registries.xml'),$list)