(: This query derives two separate schematron files from one: one for pre-author and one for final XML. It places each rule in its own pattern, thereby esnuring every test is run. If a report/@id or assert/@id begins with the string 'pre-' it is only placed in the pre-author file. If it begins with 'final-' then it only goes in the final file. If it begins with neither, then the test is applicable to both. It is assumed that having two separate files is preferable to two <phase> elements in one file. :)

declare variable $outputDir := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron';

let $sch-file := doc($outputDir||'/schematron.sch')

for $sch in $sch-file/*:schema

let $pre-sch := 
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
return
copy $copy3 := $copy2
modify(
for $x in $copy3//(*:report|*:assert)
return 
if (starts-with($x/@id,'final-')) then delete node $x
else if ($x/@id = 'graphic-media-presence') then delete node $x/ancestor::*:pattern
else ()
)
return $copy3

let $final-sch :=
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
return
copy $copy3 := $copy2
modify(
for $x in $copy3//(*:report|*:assert)
return 
if (starts-with($x/@id,'pre-')) then delete node $x
else if ($x/@id = 'graphic-media-presence') then delete node $x/ancestor::*:pattern
else ()
)
return $copy3

let $final-package-sch :=
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
return
copy $copy3 := $copy2
modify(
for $x in $copy3//(*:report|*:assert)
return 
if (starts-with($x/@id,'pre-')) then delete node $x
else ()
)
return $copy3


return (
  file:write(($outputDir||'/pre-JATS-schematron.sch'),$pre-sch),
  file:write(($outputDir||'/final-JATS-schematron.sch'),$final-sch),
  file:write(($outputDir||'/final-package-JATS-schematron.sch'),$final-package-sch)
)
