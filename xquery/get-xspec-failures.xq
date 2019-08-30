declare namespace x="http://www.jenitennison.com/xslt/xspec";

let $result := doc('../xspec/xspec/schematron-result.xml')

return distinct-values(
  for $x in $result//x:test[@successful="false"]/parent::x:scenario/x:context/substring-after(@href,'/tests/')
  order by lower-case($x)
  return $x 
)