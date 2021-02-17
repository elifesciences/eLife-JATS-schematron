(: deletes unused unit tests - use with caution! :)
let $base := doc('../src/schematron.sch')
let $base-uri := substring-before(base-uri($base),'/schematron.sch')
let $root := substring-before($base-uri,'/src')

let $dir := ($root||'/test/tests/gen/')
(: all folders in unit testing root directory :)
let $folders := file:list($dir)[.!='.DS_Store']

for $folder in $folders
let $path := ($dir||$folder)
let $sub-folders := file:list($path)[.!='.DS_Store']
  for $sub-folder in $sub-folders
  (: if there's a test in the base schematron with an id that matches the folder name then ignore :)
  return if ($base//*[@id = replace($sub-folder,'/$','')]) then ()
  (: otherwise purge :fire: :)
  else file:delete(($path||$sub-folder),true())