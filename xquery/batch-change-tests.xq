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
  let $xmls := file:list($path||$sub-folder)[ends-with(.,'.xml')]
    for $xml in $xmls
    let $root := doc($path||$sub-folder||$xml)//*:root
    return if ($root//*:article//*:custom-meta[meta-name='Template']) then   
    let $new-root := copy $copy := $root
                    modify(
                      for $x in $copy//*:custom-meta[meta-name='Template']
                      return 
                      replace node $x with <custom-meta><meta-name>pdf-template</meta-name>{$x/*:meta-value}</custom-meta>
                    )
                    return $copy
    let $new-xml := ($root/preceding::processing-instruction(),
                     $root/preceding::comment(),
                     $new-root)
    let $uri := ($path||$sub-folder||$xml)
    return (
    if (file:exists($uri)) then (
      file:write($uri,$new-xml)
    ) 
    else $uri
    )
    
    