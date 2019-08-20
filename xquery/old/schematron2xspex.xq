declare namespace x="http://www.jenitennison.com/xslt/xspec";
declare namespace sch="http://purl.oclc.org/dsdl/schematron";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace java="http://www.java.com/";
declare variable $sch :=  for $x in doc('../schematron.sch')
                          return copy $copy1 := $x
                          modify(
                            for $y in $copy1//xsl:function[@name="java:file-exists"]
                            return delete node $y,
                            
                            for $c in $copy1//sch:pattern[@id="final-package-pattern"]
                            return delete node $c,
                                                        
                            for $c in $copy1//*:pattern[@id!="final-package-pattern"]
                            return replace node $c with $c/*
                          )
                          
                          return copy $copy2 := $copy1
                          modify(
                            for $t in $copy2//sch:schema
                            let $r := 
                            <pattern id="root-pattern">
                            <rule context="root" id="root-rule">{
                              for $z in $t//sch:rule[not(@id="missing-ref-cited")]
                              let $test := $z/@context/string()
                              return
                              if (matches($test,'\|')) then (
                                let $q := string-join(
                                  for $x in tokenize($test,'\|')
                                  return concat('descendant::',$x)
                                  ,
                                  ' or ')   
                                return <assert test="{$q}" role="error" id="{concat($z/@id,'-xspec-assert')}">{$test} must be present.</assert>)
                              else 
                              <assert test="{concat('descendant::',$test)}" role="error" id="{concat($z/@id,'-xspec-assert')}">{$test} must be present.</assert> 
                            }</rule>
                            </pattern> 
                            return insert node $r as last into $t,
                            
                            for $c in $copy2//sch:rule[@id="missing-ref-cited"]
                            return delete node $c,
                            
                            for $c in $copy2//sch:rule[not(@id="missing-ref-cited")]
                            let $id := ($c/@id || '-pattern')
                            return replace node $c with <pattern id="{$id}">{$c}</pattern>
                          )
                          return $copy2
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
    for $x in $sch//sch:rule[(@id!='final-package') and (@id!='root-rule')]
    let $id := local:get-id($x)  
    return
    <x:scenario label="{$id}">
      {for $y in $x//(sch:assert|sch:report)
       let $id-2 := $y/@id
       let $folder := concat('../tests/',$id,'/',$id-2,'/') 
       let $e-pass := element {concat('x:expect-not-',$y/local-name())} {attribute {'id'} {$id-2}, attribute {'role'} {$y/@role}}
       let $e-fail := element {concat('x:expect-',$y/local-name())} {attribute {'id'} {$id-2}, attribute {'role'} {$y/@role}}
       let $e-present := element {'x:expect-not-assert'} {attribute {'id'} {concat($x/@id,'-xspec-assert')}, attribute {'role'} {'error'}}
       return (
       <x:scenario label="{concat($id-2,'-pass')}">
         <x:context href="{concat($folder,'pass.xml')}"/>
         {
           $e-pass,
           $e-present
         }
       </x:scenario>,
       <x:scenario label="{concat($id-2,'-fail')}">
         <x:context href="{concat($folder,'fail.xml')}"/>
         {
           $e-fail,
           $e-present
         }
       </x:scenario>
         )
      }
    </x:scenario>
  
  }</x:scenario>
</x:description>

return (file:write(concat($base-uri,'/xspec/schematron.xspec'),$xspec),
        file:write(concat($base-uri,'/xspec/schematron.sch'),$sch))