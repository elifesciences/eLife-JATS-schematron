<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:mml="http://www.w3.org/1998/Math/MathML" queryBinding="xslt2">
  <title>Copyedit Schematron</title>
  <ns uri="http://www.niso.org/schemas/ali/1.0/" prefix="ali"/>
  <ns uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
  <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  <ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
  <ns uri="https://elifesciences.org/namespace" prefix="e"/>
  <pattern>
    <rule context="article" id="copyedit-test">
      <let name="list" value="document('../../../../copy-edit/us-uk-list.xml')"/>
      <let name="corr-authors" value="distinct-values(                 for $x in self::*//article-meta//contrib[@corresp='yes']                 return                 $x/xref[@ref-type='aff']/@rid                 )"/>
      <let name="countries" value="string-join(distinct-values(                 for $x in self::*//article-meta//aff[@id/string() = $corr-authors]                 return                 $x/country/string()                 ),'; ')"/>
      <let name="text" value="string-join(for $x in                      self::*/(front/article-meta//(article-title|abstract//p|custom-meta/meta-value)|                               body//(p|title|th|td)|                               back//(ack//p|app//p|title|th|td)                               )                     return $x/data(),' ')"/>
      <let name="us-tokens" value="for $x in tokenize($text,' ')                  return if (replace(lower-case($x),'[^\p{L}]','') = $list//item/@us/string()) then replace($x,'[^\p{L}]','')                 else if ($x = 'dr.') then $x                 else ()"/>
      <let name="us-count" value="count($us-tokens)"/>
      <let name="us-text" value="string-join(distinct-values($us-tokens),'; ')"/>
      <let name="uk-variants" value="for $x in $us-tokens                 return if ($x = 'dr.') then 'dr'                 else ($list//item[@us/string() = replace($x,'[^\p{L}]','')]/@uk/string())"/>
      <let name="uk-tokens" value="for $x in tokenize($text,' ')                  return if (replace(lower-case($x),'[^\p{L}]','') = $list//item/@uk/string()) then replace($x,'[^\p{L}]','')                 else if ($x = 'dr') then $x                 else ()"/>
      <let name="uk-count" value="count($uk-tokens)"/>
      <let name="uk-text" value="string-join(distinct-values($uk-tokens),'; ')"/>
      <report test="($uk-count &gt; $us-count)" role="info" id="uk-confirm">UK terms are prevalent, and corresponding author affiliaiton countries are --- <value-of select="$countries"/>
      </report>
    </rule>
  </pattern>
  <pattern id="root-pattern">
    <rule context="root" id="root-rule">
      <assert test="descendant::article" role="error" id="copyedit-test-xspec-assert">article must be present.</assert>
    </rule>
  </pattern>
</schema>