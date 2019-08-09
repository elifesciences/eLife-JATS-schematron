declare namespace x="http://www.jenitennison.com/xslt/xspec";
declare namespace sch="http://purl.oclc.org/dsdl/schematron";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace java="http://www.java.com/";
declare variable $sch :=  for $x in doc('../schematron.sch')
                          return copy $copy := $x
                          modify(
                            for $y in $copy//xsl:function[@name="java:file-exists"]
                            return delete node $y,
                            
                            for $c in $copy//sch:pattern[@id="final-package-pattern"]
                            return delete node $c,
                            
                             for $c in $copy//sch:rule[@id="missing-ref-cited"]
                            return delete node $c
                          )
                          return $copy
;
declare variable $base-uri := substring-before(base-uri($sch),'/schematron.sch');


declare function local:get-id($rule){
  if ($rule/@id) then $rule/@id
  else if ($rule/parent::sch:pattern/@id) then
    let $p := $rule/parent::sch:pattern[@id]
    let $pos := count($p/sch:rule) - count($rule/following-sibling::sch:rule)
    return concat($rule/parent::sch:pattern/@id,$pos)
  else generate-id($rule)
};

let $xspec := 
<x:description xmlns:x="http://www.jenitennison.com/xslt/xspec" schematron="schematron.sch">
  <x:scenario >{
    (:Ignore final package rule :)
    for $x in $sch//sch:rule[@id!='final-package']
    let $id := local:get-id($x)  
    return
    <x:scenario label="{$id}">
      {for $y in $x//(sch:assert|sch:report)
       let $id-2 := $y/@id
       let $folder := concat('../tests/',$id,'/',$id-2,'/') 
       let $e := element {concat('x:expect-',$y/local-name())} {attribute {'id'} {$id-2}, attribute {'role'} {$y/@role}}
       return (
       <x:scenario label="{concat($id-2,'-pass')}">
         <x:context href="{concat($folder,'pass.xml')}"/>
         <x:expect-valid/>
       </x:scenario>,
       <x:scenario label="{concat($id-2,'-fail')}">
         <x:context href="{concat($folder,'fail.xml')}"/>
         {
           $e
         }
       </x:scenario>
         )
      }
    </x:scenario>
  
  }</x:scenario>
</x:description>

return (file:write(concat($base-uri,'/xspec/schematron.xspec'),$xspec),
        file:write(concat($base-uri,'/xspec/schematron.sch'),$sch))