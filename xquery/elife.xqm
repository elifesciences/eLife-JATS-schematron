module namespace elife = 'elife';
import module namespace schematron = "http://github.com/Schematron/schematron-basex";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";
declare namespace x="http://www.jenitennison.com/xslt/xspec";

declare variable $elife:base := doc('../src/schematron.sch');
declare variable $elife:copy-edit-base := doc('../src/copy-edit.sch');

(:~ Generate schemalet files for unit testing purposes
 :)
declare function elife:schema-let($assert-or-report){
  let $id := $assert-or-report/@id
  return
    copy $copy1 := $elife:base
    modify(
      for $x in $copy1//*:rule
      return 
        if ($x//(*:assert|*:report)/@id = $id) then ()
        else delete node $x,
        
        for $x in $copy1//xsl:function[@name="java:file-exists"]
return delete node $x,

        for $x in $copy1//*:let[@name=("countries","publisher-locations","journals","publishers","funders","registries")]
        let $new-v := concat("'../../../../../src/",substring-after($x/@value,"'"))
        return 
        replace value of node $x/@value with $new-v,

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
     else delete node $x,
     
    for $x in $copy2//*:schema
    let $rule := $x//*[@id = $id]/parent::*:rule
    let $test := $rule/@context/string()
    let $q := 
            if ($rule/@id="covid-prologue") then <assert test="{concat('descendant::',$test)}" role="error" id="{concat($rule/@id,'-xspec-assert')}">{$test} must be present.</assert>
            else if (matches($test,'\|')) then <assert test="{string-join(
                              for $x in tokenize($test,'\|')
                              return concat('descendant::',$x)
                              ,
                              ' or ')}" role="error" id="{concat($rule/@id,'-xspec-assert')}">{$test} must be present.</assert>
            else <assert test="{concat('descendant::',$test)}" role="error" id="{concat($rule/@id,'-xspec-assert')}">{$test} must be present.</assert> 
    
    return 
    if ($id=('pre-colour-styled-content-check','final-colour-styled-content-check','final-strike-flag','permissions-notification','empty-attribute-conformance')) then ()
    else insert node 
        <pattern id="root-pattern">
        <rule context="root" id="root-rule">
        {$q}
        </rule>
        </pattern>
    as last into $x 
    )

return copy $copy3 := $copy2
  modify(
    
    for $x in $copy3//*:schema/text()
    return delete node $x,
    
    for $x in $copy3//*:pattern/text()
    return delete node $x,
    
    for $x in $copy3//*:rule/text()
    return delete node $x
  )
  
  return $copy3
  
};

declare function elife:validate($pass-or-fail-path,$sch){
  if (file:exists($pass-or-fail-path)) then 
                  schematron:validate(doc($pass-or-fail-path), $sch)
                  else ('File not found')
};



(:~ 
 : Generate 'pre' version of schematron
 :)
declare function elife:sch2pre($sch){
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
      return 
      if (starts-with($x/@id,'final-')) then delete node $x
      else (replace node $x with <pattern id="{$id}">{$x}</pattern>)
    )
    return
    copy $copy3 := $copy2
    modify(
      for $x in $copy3//(*:report|*:assert)
      let $id := ("["||$x/@id||"] ")
      return 
      if (starts-with($x/@id,'final-')) then delete node $x
      else if (starts-with($x/data(),('['||$x/@id))) then ()
      else insert node $id as first into $x,

      for $x in $copy3//xsl:function[@name=("java:file-exists","e:get-latin-terms","e:print-latin-terms")]
      return delete node $x,

      for $x in $copy3//*:let[@name="article-text"]/preceding-sibling::comment()[1]
      return delete node $x
    )
  return $copy3
};

(:~ 
 : Generate decision letter version of schematron
 :)
declare function elife:sch2dl($sch){
   copy $copy1 := $sch
    modify(
      for $x in $copy1//*:pattern
      return replace node $x with $x/*,
      
      for $x in $copy1//xsl:function[@name=("java:file-exists","e:get-latin-terms","e:print-latin-terms")]
      return delete node $x
    )
    return
    copy $copy2 := $copy1
    modify(
      for $x in $copy2//*:rule
      let $id := ($x/@id || '-pattern')
      return 
      if ($x/*[@flag="dl-ar"]) then replace node $x with <pattern id="{$id}">{$x}</pattern>
      else delete node $x
    )
    return 
    copy $copy3 := $copy2
    modify(
      for $x in $copy3//(*:report[not(@flag="dl-ar")]|*:assert[not(@flag="dl-ar")])
      return delete node $x
    )
    return $copy3
};

(:~ 
 : Generate 'final' version of schematron
 :)
declare function elife:sch2final($sch){
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
      return 
      if (starts-with($x/@id,'pre-')) then delete node $x
      else (replace node $x with <pattern id="{$id}">{$x}</pattern>)
    )
    return
    copy $copy3 := $copy2
    modify(
      for $x in $copy3//(*:report|*:assert)
      let $id := ("["||$x/@id||"] ")
      return 
      if (starts-with($x/@id,'pre-')) then delete node $x
      else if ($x/@id = 'graphic-media-presence') then delete node $x/ancestor::*:pattern
      else if (starts-with($x/data(),('['||$x/@id))) then ()
      else insert node $id as first into $x,

      for $x in $copy3//xsl:function[@name="java:file-exists"]
      return delete node $x,

      for $x in $copy3//*:let[@name="article-text"]/preceding-sibling::comment()[1]
      return delete node $x
    )
  return $copy3
};


(:~ 
 : Generate 'final-package' version of schematron
 :)
declare function elife:sch2final-package($sch){
    copy $copy1 := $sch
    modify(
      for $x in $copy1//*:pattern
      return replace node $x with $x/*,
      
      for $y in $copy1//*[@flag]
      return delete node $y/@flag
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
      else if ($x/@flag) then delete node $x/@flag
      else ()
    )
  return $copy3
};


(:~ 
 : Get id for the purposes of Xspec generation
 :)
declare function elife:get-id($rule){
  if ($rule/@id) then $rule/@id
  else if ($rule/parent::sch:pattern/@id) then
    let $p := $rule/parent::sch:pattern[@id]
    let $pos := count($p/sch:rule) - count($rule/following-sibling::sch:rule)
    return concat($rule/parent::sch:pattern/@id,$pos)
  else generate-id($rule)
};

(:~ 
 : Generate modified schematron file for use with Xspec file
 :)
declare function elife:sch2xspec-sch($sch){
  copy $copy1 := $sch
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
        for $t in $copy2
         let $r := 
             <pattern id="root-pattern">
                <rule context="root" id="root-rule">{
                for $z in $t//sch:rule[not(@id=("missing-ref-cited","strike-tests","colour-styled-content","empty-attribute-test"))]
                let $test := $z/@context/string()
                return
                if ($z/@id="covid-prologue") then <assert test="{concat('descendant::',$test)}" role="error" id="{concat($z/@id,'-xspec-assert')}">{$test} must be present.</assert>
                else if (matches($test,'\|')) then (
                  let $q := string-join(
                     for $x in tokenize($test,'\|')
                     return concat('descendant::',$x)
                     ,
                     ' or ')   
                     return <assert test="{$q}" role="error" id="{concat($z/@id,'-xspec-assert')}">{$test} must be present.</assert>)
                else <assert test="{concat('descendant::',$test)}" role="error" id="{concat($z/@id,'-xspec-assert')}">{$test} must be present.</assert> 
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
};


(:~ 
 : Generate Xspec file from modified schematron file in elife:sch2xspec-sch
 :)
declare function elife:sch2xspec($xspec-sch){
  <x:description xmlns:x="http://www.jenitennison.com/xslt/xspec" schematron="schematron.sch">
  <x:scenario>
  {
    (:Ignore final package rule :)
    for $x in $xspec-sch//sch:rule[(@id!='final-package') and (@id!='root-rule')]
    let $id := elife:get-id($x)  
    return
    <x:scenario label="{$id}">
      {for $y in $x//(sch:assert|sch:report)
       let $id-2 := $y/@id
       let $folder := concat('../tests/gen/',$id,'/',$id-2,'/') 
       let $e-pass := element {concat('x:expect-not-',$y/local-name())} {attribute {'id'} {$id-2}, attribute {'role'} {$y/@role}}
       let $e-fail := element {concat('x:expect-',$y/local-name())} {attribute {'id'} {$id-2}, attribute {'role'} {$y/@role}}
       let $e-present := if ($y[@id="permissions-notification"]) then () 
                         else element {'x:expect-not-assert'} {attribute {'id'} {concat($x/@id,'-xspec-assert')}, attribute {'role'} {'error'}}
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
  
};

(:~ 
 : Update comment at top of test files with latest test info
 :)
declare function elife:new-test-case($file-path,$new-comment){
  for $x in doc($file-path)
  return
  copy $copy := $x
  modify(
    for $comment in $copy//comment()
    return replace node $comment with ('&#xa;',$new-comment,'&#xa;')
  )
  return $copy
  
};


(:~ 
 : Generate Xspec file from copyedit schematron file
 :)
declare function elife:copy-edit2xspec($xspec-sch){
  <x:description xmlns:x="http://www.jenitennison.com/xslt/xspec" schematron="copy-edit.sch">
  <x:scenario >{
    for $x in $xspec-sch//sch:rule
    let $id := elife:get-id($x)  
    return
    <x:scenario label="{$id}">
      {for $y in $x//(sch:assert|sch:report)
       let $id-2 := $y/@id
       let $folder := concat('../tests/copy-edit/',$id,'/',$id-2,'/') 
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
</x:description>};


(:~ Generate schemalet files for unit testing purposes from the copy-edit-schematron
 :)
declare function elife:copy-edit-schema-let($assert-or-report){
  let $id := $assert-or-report/@id
  return
    copy $copy1 := $elife:copy-edit-base
    modify(
      for $x in $copy1//*:rule
      return 
        if ($x//(*:assert|*:report)/@id = $id) then ()
        else delete node $x,
        
        for $x in $copy1//xsl:function[@name="java:file-exists"]
return delete node $x,

        for $x in $copy1//*:let[@name="list"]
        let $new-v := "document('../../../../../src/us-uk-list.xml')"
        return 
        replace value of node $x/@value with $new-v,

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
     else delete node $x,
     
    for $x in $copy2//*:schema
    let $rule := $x//*[@id = $id]/parent::*:rule
    let $test := $rule/@context/string()
    let $q := 
            if (matches($test,'\|')) then <assert test="{string-join(
                              for $x in tokenize($test,'\|')
                              return concat('descendant::',$x)
                              ,
                              ' or ')}" role="error" id="{concat($rule/@id,'-xspec-assert')}">{$test} must be present.</assert>
            else <assert test="{concat('descendant::',$test)}" role="error" id="{concat($rule/@id,'-xspec-assert')}">{$test} must be present.</assert> 
    
    return 
    insert node 
        <pattern id="root-pattern">
        <rule context="root" id="root-rule">
        {$q}
        </rule>
        </pattern>
    as last into $x 
    )

return copy $copy3 := $copy2
  modify(
    
    for $x in $copy3//*:schema/text()
    return delete node $x,
    
    for $x in $copy3//*:pattern/text()
    return delete node $x,
    
    for $x in $copy3//*:rule/text()
    return delete node $x
  )
  
  return $copy3
  
};

(: Return error for unallowed roles in input :)
declare function elife:unallowed-roles($sch as node(),$allowed-roles as item()*){
let $unallowed-roles := distinct-values(
  $sch//*[not(@role=$allowed-roles)]/@role
)
return if (empty($unallowed-roles)) then ()
else 
let $problem-tests := string-join(
                        $sch//(*:report[@role=$unallowed-roles]/@id|*:assert[@role=$unallowed-roles]/@id)
                        ,', ')
return error(
        xs:QName("elife:error"),
        (string-join($unallowed-roles,', ')||' is not allowed as value of @role in src/schematron.sch. See test(s) with id(s) '||$problem-tests))
};