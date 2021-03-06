module namespace e = 'http://elifesciences.org/modules/validate';
import module namespace session = "http://basex.org/modules/session";
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace schematron = "http://github.com/Schematron/schematron-basex";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";


declare
  %rest:path("/schematron/pre")
  %rest:POST("{$xml}")
  %input:text("xml","encoding=UTF-8")
  %output:method("json")
function e:validate-pre($xml)
{
  let $xsl := doc('./schematron/pre-JATS-schematron.xsl')
  let $svrl :=  xslt:transform($xml, $xsl)
  
  return e:svrl2json($svrl)
  
};

declare
  %rest:path("/schematron/dl")
  %rest:POST("{$xml}")
  %input:text("xml","encoding=UTF-8")
  %output:method("json")
function e:validate-dl($xml)
{
  let $xsl := doc('./schematron/dl-schematron.xsl')
  let $svrl :=  xslt:transform($xml, $xsl)
  
 return e:svrl2json($svrl)
  
};

declare
  %rest:path("/schematron/final")
  %rest:POST("{$xml}")
  %input:text("xml","encoding=UTF-8")
  %output:method("json")
function e:validate-final($xml)
{
  let $xsl := doc('./schematron/final-JATS-schematron.xsl')
  let $svrl :=  xslt:transform($xml, $xsl)
  
  return 
  (: Extra check for Glencoe Metadata :)
  if ($xml//*:media[@mimetype="video"]) then (e:svrl2json-final($xml,$svrl))
  else e:svrl2json($svrl)
  
};

declare
  %rest:path("/schematron")
  %rest:GET
  %output:method("html")
function e:upload()
{
  let $div := 
   <div class="container">
    <div class="col-sm-2">
        <a href="/schematron">
            <img src="static/elife.jpg" class="img-thumbnail"/>
        </a>
    </div>
    <div class="col-md-10">
        <h3>Schematron validator</h3>
        <form id="form1" action="/schematron/pre" method="POST" enctype="multipart/form-data">
            <div class="row justify-content-start">
                <div class="form-group">
                    <label for="InputFiles" class="col-md-3 control-label">Select files</label>
                    <div class="col-md-3">
                         <input type="file" name="xml" accept="application/xml"/>
                    </div>
                </div>
            </div>
            <div class="row justify-content-start">
                <div class="form-group">
                    <label class="col-md-3">Choose Schematron</label>
                    <div class="col-md-4">
                        <input type="submit" value="Pre"/>
                        <input type="submit" formaction="/schematron/final" value="Final"/>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
    
    return e:template($div)
    
};


declare function e:svrl2json($svrl){
  
  let $errors :=
      concat(
         '"errors": [',
         string-join(
         for $error in $svrl//*[@role="error"]
         return concat(
                '{',
                ('"path": "'||$error/@location/string()||'",'),
                ('"type": "'||$error/@role/string()||'",'),
                ('"message": "'||e:get-message($error)||'"'),
                '}'
              )
          ,','),
        ']'
      )
let $warnings := 
     concat(
         '"warnings": [',
         string-join(
         for $warn in $svrl//*[@role=('info','warning','warn')]
         return concat(
                '{',
                ('"path": "'||$warn/@location/string()||'",'),
                ('"type": "'||$warn/@role/string()||'",'),
                ('"message": "'||e:get-message($warn)||'"'),
                '}'
              )
          ,','),
        ']'
      )
      
let $json :=  
    concat(
      '{
        "results": {',
      $errors,
      ',',
      $warnings,
      '} }'
    )
return json:parse($json)
};

(: Contains check for Glencoe metadata :)
declare function e:svrl2json-final($xml,$svrl){
  let $doi := $xml//*:article-meta//*:article-id[@pub-id-type="doi"]/string()
  let $glencoe := e:get-glencoe($doi)
  let $glencoe-errors := 
  string-join(
           if ($glencoe//*:error) then ('{"path": "unknown", "type": "error", "message": "There is no Glencoe metadata for this article but it contains videos. Please esnure that the Glencoe data is correct."}')
         else (
           for $vid in $xml//*:media[@mimetype="video"]
           let $id := $vid/@id
           return if ($glencoe/*[local-name()=$id and *:video__id[.=$id] and ends-with(*:solo__href,$id)]) then ()
           else concat(
                '{',
                ('"path": "unkown",'),
                ('"type": "error",'),
                ('"message": "There is no metadata in Glencoe for the video with id '||concat("'",$id,"'")||'."'),
                '}'
              )
         ),',')
  let $sch-errors := string-join(
         for $error in $svrl//*[@role="error"]
         return concat(
                '{',
                ('"path": "'||$error/@location/string()||'",'),
                ('"type": "'||$error/@role/string()||'",'),
                ('"message": "'||e:get-message($error)||'"'),
                '}'
              )
          ,',')
  
  let $errors :=
      concat(
         '"errors": [', 
          string-join(
            (if ($glencoe-errors='') then () else $glencoe-errors,
             if ($sch-errors='') then () else $sch-errors)
            ,','),
        ']'
      )
let $warnings := 
     concat(
         '"warnings": [',
         string-join(
         for $warn in $svrl//*[@role=('info','warning','warn')]
         return concat(
                '{',
                ('"path": "'||$warn/@location/string()||'",'),
                ('"type": "'||$warn/@role/string()||'",'),
                ('"message": "'||e:get-message($warn)||'"'),
                '}'
              )
          ,','),
        ']'
      )
      
let $json :=  
    concat(
      '{
        "results": {',
      $errors,
      ',',
      $warnings,
      '} }'
    )
return json:parse($json)
};

declare function e:json-escape($string){
  normalize-space(replace(replace($string,'\\','\\\\'),'"','\\"'))
};

declare function e:get-message($node){
  if ($node[@see]) then e:json-escape((data($node)||' '||$node/@see))
  else e:json-escape(data($node))
};

declare function e:get-glencoe($doi){
  try {
    http:send-request(
  <http:request method='get' href="{('https://movie-usa.glencoesoftware.com/metadata/'||$doi)}" timeout='2'>
    <http:header name="From" value="production@elifesciences.org"/>
    <http:header name="Referer" value="https://basex-validator--staging.elifesciences.org/schematron/final"/>
    <http:header name="User-Agent" value="basex-validator"/>
  </http:request>)//*:json}
  
  (: Return error for timeout :)
  catch * { json:parse('{"error": "Not found"}') }
   
};

declare function e:validate($xml,$schema){
  
  try {schematron:validate($xml, $schema)}
  (: Return psuedo-svrl to output error message for fatal xslt errors :)
  catch * { <schematron-output><successful-report id="validator-broken" location="unknown" role="error"><text>{'Error [' || $err:code || ']: ' || $err:description}</text></successful-report></schematron-output>}
};

declare
function e:template($div as element(div))
as element(html) 
{
  <html lang="en">
  <head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>

  <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css' integrity='sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u' crossorigin='anonymous'/>
  <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css' integrity='sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp' crossorigin='anonymous'/>

  <title>Schematron Validator</title>
  </head>
  <body>
  {$div}
   <script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
   <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
   <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
  </body>
</html>
};