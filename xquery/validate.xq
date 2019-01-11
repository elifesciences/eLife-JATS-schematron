(: In order for this query to functino you have to installed the schematron module:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";

let $xml := doc('/Users/fredatherden/desktop/elife-39723.xml')

let $sch := schematron:compile(doc('/Users/fredatherden/desktop/schematron.sch'))

let $svrl := schematron:validate($xml, $sch)
let $messages := schematron:messages($svrl)
return
(
  schematron:is-valid($svrl),
  for $message in schematron:messages($svrl)
  return concat(schematron:message-level($message), ': ', schematron:message-description($message))
)


