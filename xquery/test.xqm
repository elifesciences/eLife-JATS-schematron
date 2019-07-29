module namespace test = 'test';
import module namespace schematron = "http://github.com/Schematron/schematron-basex";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";

declare variable $test:base := doc('../schematron.sch');

declare function test:schema-let($assert-or-report){
  let $id := $assert-or-report/@id
  return
    copy $copy1 := $test:base
    modify(
      for $x in $copy1//*:rule
      return 
        if ($x//(*:assert|*:report)/@id = $id) then ()
        else delete node $x,
        
        for $x in $copy1//xsl:function[@name="java:file-exists"]
return delete node $x,

for $x in $copy1//comment()
return delete node $x
       )

  return

  copy $copy2 := $copy1
  modify(
    for $x in $copy2//*:pattern[not(*:rule)]
    return delete node $x,
    
    for $x in $copy2//*:pattern[*:rule]/*:rule/*
    return 
     if ($x/@id = $id) then ()
     else if ($x/local-name() = 'let') then ()
     else delete node $x 
    )

return $copy2
  
};

declare function test:validate($pass-or-fail-path,$sch){
  if (file:exists($pass-or-fail-path)) then 
                  schematron:validate(doc($pass-or-fail-path), $sch)
                  else ('File not found')
};


(:~ 
 : Return the ids of any messages from a SVRL validation result.
 :)
declare function test:message-ids($svrl){
  ($svrl/svrl:schematron-output/svrl:failed-assert/@id union $svrl/svrl:schematron-output/svrl:successful-report/@id)
};


(:~ 
 : Return context from rule as string and parse so that it can be compared against local-name
 :)
declare function test:get-context($test){
  for $x in replace($test/parent::*:rule/@context/string(),'\[.*\]| ','')
                return
                if (contains($x,'/*')) then 
                tokenize(substring-before($x,'/*'),'/')[last()]
                else if (contains($x,'mml:')) then 
                tokenize(substring-after($x,'mml:'),'/')[last()]
                else if (contains($x,'|')) then for $y in tokenize($x,'\|')
                              return if (contains($y,'/')) then tokenize($y,'/')[last()]
                              else $y
                else tokenize($x,'/')[last()]
};