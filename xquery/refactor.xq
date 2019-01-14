(: This query places each rule in it's own pattern, and writes a new file. In this new file, every test will certainly be run :)

declare variable $outputDir := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron';

let $sch-file := doc($outputDir||'/schematron.sch')

for $sch in $sch-file/*:schema
let $new-sch := 
copy $copy1 := $sch
modify(
for $x in $copy1//*:pattern
return replace node $x with $x/*
)
return
copy $copy2 := $copy1
modify(
for $x in $copy2//*:rule
let $id := ($x/@id || '-pattern')
return replace node $x with <pattern id="{$id}">{$x}</pattern>
)
return $copy2

return file:write(($outputDir||'/JATS-schematron.sch'),$new-sch)