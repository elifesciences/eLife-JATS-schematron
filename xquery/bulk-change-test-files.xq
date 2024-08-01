let $test-folder := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/test/tests/gen/'

let $xml-file-paths := for $folder in file:list($test-folder)[.!='.DS_Store']
                        for $sub-folder in file:list($test-folder||$folder)[.!='.DS_Store']
                        let $files := file:list($test-folder||$folder||$sub-folder)
                        return for $file in $files[ends-with(.,'xml')] return $test-folder||$folder||$sub-folder||$file

for $path in $xml-file-paths
let $xml := doc($path)
where $xml//*:contrib[@contrib-type="author" and @id]
let $new-content := copy $copy := $xml//*:root
                    modify(
                      for $x in $copy//contrib[@contrib-type="author"]/@id
                      return delete node $x
                    )
                    return $copy
let $new-file := ($xml//*:root/preceding-sibling::processing-instruction(),
                  $xml//*:root/preceding-sibling::comment(),
                  $new-content)
return file:write($path,$new-file,map{'indent':'yes'})