let $orgs := 'Albugo candida
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
Uromyces fabae'

for $org in tokenize($orgs,'\n')
let $x := substring($org,1,1)||'. '||substring-after($org,' ')
let $x-test := "matches($lc,'"||lower-case(substring($org,1,1))||"\.\p{Zs}?"||substring-after(lower-case($org),' ')||"') and not(italic[contains(.,'"||$x||"')])"
let $y-test := "matches($lc,'"||substring-before(lower-case($org),' ')||"\p{Zs}?"||substring-after(lower-case($org),' ')||"') and not(italic[contains(.,'"||$org||"')])"
return
(
<report test="{$x-test}" 
        role="info" 
        id="{replace(lower-case($x),'\.\s','')||'-article-title-check'}"><name/> contains an organism - '{$x}' - but there is no italic element with that correct capitalisation or spacing.</report>,
'',
<report test="{$y-test}" 
        role="info" 
        id="{replace(lower-case($org),'\s')||'-article-title-check'}"><name/> contains an organism - '{$org}' - but there is no italic element with that correct capitalisation or spacing.</report>
      ,'')