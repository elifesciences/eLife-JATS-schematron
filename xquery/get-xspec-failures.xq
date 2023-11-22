declare namespace x="http://www.jenitennison.com/xslt/xspec";
import module namespace schematron = "http://github.com/Schematron/schematron-basex";
declare variable $sch := doc('../src/schematron.sch');
declare variable $base := substring-before(base-uri($sch),'src');

let $xspec-result := doc('../test/xspec/xspec/schematron-result.xml')

let $failures := distinct-values(for $x in $xspec-result//x:test[@successful="false"]/parent::x:scenario//x:context/substring-after(@href,'/tests/')
                 order by lower-case($x)
                 return $x)

for $failure in $failures
let $filename := tokenize($failure,'/')[last()]
let $folder := $base||'/test/tests/'||substring-before($failure,$filename)
let $id := tokenize(replace($folder,'/$',''),'/')[last()]
let $xml := doc($folder||$filename)
let $sch := schematron:compile(doc($folder||$id||'.sch'))
let $svrl := schematron:validate($xml, $sch)
let $messages := schematron:messages($svrl)
return ($failure,
        schematron:is-valid($svrl),
        for $message in $messages
        return concat(schematron:message-level($message), ': ', schematron:message-description($message))
      )