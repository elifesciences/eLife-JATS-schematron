let $root := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/'
let $rp-sch := doc($root||'src/rp-schematron-base.sch')

for $t in $rp-sch//*:rule[@id="fig-xref-conformance"]//*[name()=('report','assert')]
let $gen-f := $root||'/test/tests/gen/'||$t/parent::*:rule/@id||'/'||$t/@id||'/'
let $folder := $root||'/test/tests/rp/'||$t/parent::*:rule/@id||'/'||$t/@id||'/'
let $f := doc($folder||'fail.xml')
let $p := doc($folder||'pass.xml')
let $o-f := copy $copy := $f 
              modify(
                replace node $copy//*:root with doc($gen-f||'fail.xml')//*:root
              ) 
              return $copy
let $new-f := copy $copy := $o-f
              modify(
                if ($copy//*:root//*:front) then 
                  if ($copy//*:root//*:front/*:journal-meta) then insert node <journal-id>eLife</journal-id> as first into $copy//*:root//*:front/*:journal-meta
                  else insert node <journal-meta><journal-id>eLife</journal-id></journal-meta> as first into $copy//*:root//*:front
                else if ($copy//*:root/*:article) then insert node <front><journal-meta><journal-id>eLife</journal-id></journal-meta></front> as first into $copy//*:root/*:article
                else insert node <article><front><journal-meta><journal-id>eLife</journal-id></journal-meta></front></article> as first into $copy//*:root
              )
              return $copy
let $o-p := copy $copy := $p 
              modify(
                replace node $copy//*:root with doc($gen-f||'pass.xml')//*:root
              ) 
              return $copy
let $new-p := copy $copy := $o-p
              modify(
                if ($copy//*:root//*:front) then 
                  if ($copy//*:root//*:front/*:journal-meta) then insert node <journal-id>eLife</journal-id> as first into $copy//*:root//*:front/*:journal-meta
                  else insert node <journal-meta><journal-id>eLife</journal-id></journal-meta> as first into $copy//*:root//*:front
                else if ($copy//*:root/*:article) then insert node <front><journal-meta><journal-id>eLife</journal-id></journal-meta></front> as first into $copy//*:root/*:article
                else insert node <article><front><journal-meta><journal-id>eLife</journal-id></journal-meta></front></article> as first into $copy//*:root
              )
              return $copy            
return (
 file:write($folder||'fail.xml',$new-f),
 file:write($folder||'pass.xml',$new-p) 
)