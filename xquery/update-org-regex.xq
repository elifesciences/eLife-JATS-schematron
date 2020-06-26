let $src := '../src/'
let $schema := doc($src||'schematron.sch')

let $big-regex := string-join(
for $x in $schema//*:rule[@id="org-ref-article-book-title"]/*:report
let $regex := substring-after(substring-before($x/@test,"')"),"matches($lc,'")
return $regex,'|')

return $big-regex