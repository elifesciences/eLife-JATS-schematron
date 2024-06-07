(: deletes unused unit tests - use with caution! :)
let $base := doc('../src/schematron.sch')
let $base-uri := substring-before(base-uri($base),'/schematron.sch')
let $root := substring-before($base-uri,'/src')
let $values := distinct-values(for $test in $base//(*:report|*:assert)
                  return ($test/parent::*:rule/@id||'/'||$test/@id))
let $dir := ($root||'/test/tests/gen/')
(: all folders in unit testing root directory :)
let $folders := file:list($dir)[.!='.DS_Store']

let $rp-base := doc('../src/rp-schematron-base.sch')
let $rp-values := distinct-values(for $test in $rp-base//(*:report|*:assert)
                    return ($test/parent::*:rule/@id||'/'||$test/@id))
let $rp-dir := ($root||'/test/tests/rp/')
(: all folders in unit testing root directory :)
let $rp-folders := file:list($dir)[.!='.DS_Store']

return (
  for $folder in $folders
  let $path := ($dir||$folder)
  let $sub-folders := file:list($path)[.!='.DS_Store']
    for $sub-folder in $sub-folders
    let $sub-path := ($folder||replace($sub-folder,'/$',''))
    (: if there's a test in the base schematron with an id that matches the folder name then ignore :)
    return if ($sub-path=$values) then ()
    (: otherwise purge :fire: :)
    else file:delete(($path||$sub-folder),true())
  ,
  for $rp-folder in $rp-folders
  let $rp-path := ($dir||$rp-folder)
  let $rp-sub-folders := file:list($rp-path)[.!='.DS_Store']
    for $rp-sub-folder in $rp-sub-folders
    let $rp-sub-path := ($rp-folder||replace($rp-sub-folder,'/$',''))
    return if ($rp-sub-path=$values) then ()
    else file:delete(($rp-path||$rp-sub-folder),true())
)