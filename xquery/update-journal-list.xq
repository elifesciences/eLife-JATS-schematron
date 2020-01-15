(: Presumes that a database called 'articles' is setup in BaseX from https://github.com/elifesciences/elife-article-xml :)
let $db := 'articles'

let $sch := doc('../src/schematron.sch')

let $src := substring-before(base-uri($sch),'schematron.sch')

let $crossref := fetch:xml('https://www.crossref.org/xref/xml/mddb.xml')

let $archive := 
distinct-values(
  for $x in collection($db)//*:element-citation[(@publication-type="journal") and (*:pub-id[@pub-id-type='doi'])]
  return replace($x/source[1],' ','')
)

let $list := 
<journals>
{for $x in $crossref//*:journal
return if ($x/@title/string() = $archive) then <journal title="{lower-case($x/@title)}" year="{replace($x/@years,'\-.*$','')}" prefix="{$x/@prefix}"/>
else ()}
</journals>

let $list2 := 
  copy $copy := $list
  modify (
    for $x in $copy//*:journal[preceding::*:journal/@title = self::*/@title and not(following::*:journal/@title = self::*/@title)]
    let $low := min(for $z in $copy//*:journal[@title = $x/@title]/@year/string() return number($z))
    let $prefix := string-join(distinct-values($copy//*:journal[@title = $x/@title]/@prefix),'|')
    return (
     replace node $x with <journal title="{$x/@title}" year="{$low}" prefix="{$prefix}"/>,
     delete node $x/preceding::*:journal[@title = $x/@title]
    )
  )
  return $copy
  
let $journal-list := 
  <journals>{
  for $x in $list//*:journal
  order by $x/@title
  return $x
  }</journals>
  

return file:write(($src||'journals.xml'),$journal-list,map{'omit-xml-declaration':'no'})