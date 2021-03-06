declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

declare variable $outputDir := '/Users/fredatherden/Documents/GitHub/texture/data/kitchen-sink/manuscript.xml';

for $x in collection('articles')//*:article[(descendant::*:article-id[@pub-id-type="publisher-id"]= '42955') and descendant::*:body]
let $y := 
copy $copy := $x
modify(
  for $a in $copy//*:sub-article
  return delete node $a,
  
  for $y in $copy//*:back/*:ack
  return (delete node $y,
          insert node <sec sec-type="acknowledgments">{$y/*}</sec> as last into $y/preceding::*:body),
  
  for $z in $copy//*:article-meta/*:author-notes
  return  delete node $z,
  
  for $s in $copy//*:sec[@sec-type="additional-information"]/*:fn-group
  return delete node $s,
  
  for $x in $copy//*:front//*:xref[@ref-type="fn"]
  return delete node $x,
    
  for $e in $copy//*:object-id[ancestor::*:abstract or ancestor::*:supplementary-material]
  return delete node $e,
  
  for $d in $copy//*:funding-group/*:funding-statement
  return delete node $d,
    
  for $t in $copy//*:kwd-group/*:title
  return delete node $t,
    
  for $f in $copy//*:collab[not(descendant::*)]
  return delete node $f,
  
  for $x in $copy//*:contrib-group[@content-type="section"]//*:aff
let $id := if ($x/ancestor::contrib[@contrib-type="editor"]) then 'aff100'
           else 'aff200'
return (replace node $x with <xref ref-type="aff" rid="{$id}"/>, insert node <aff id="{$id}">{$x/*}</aff> after $x/ancestor::*:contrib-group),

for $x in $copy//*:contrib-group/*:aff
return (insert node $x after $x/parent::*:contrib-group, delete node $x),

for $x in $copy//*:supplementary-material
let $m := $x/*:media
let $ms := $m/@mime-subtype
let $mt := $m/@mimetype
let $xl := $m/@xlink:href
return (insert node attribute mime-subtype {$ms} into $x,
        insert node attribute mimetype {$mt} into $x,
        insert node attribute xlink:href {$xl} into $x,
        delete node $m), 
 
  for $f in $copy//*:related-article
  return delete node $f,
  
  for $x in  $copy//*:p//*:disp-formula
  return (insert node $x after $x/ancestor::*:p,
          delete node $x),
  
  for $o in $copy//*:abstract[@abstract-type="executive-summary"]
  return delete node $o,
  
   for $x in $copy//*:fig/*:attrib
  return delete node $x,
  
  for $x in $copy//*:body
  return 
  if ($x/following-sibling::*:back) then ()
  else insert node <back/> after $x,
  
  for $i in  $copy//*:table-wrap[count(descendant::*:table)>1]
  return (delete node $i,
  for $t in $i//*:table
          let $count := count($i/descendant::*:table)
          let $pos := $count - count($t/following-sibling::*:table)
        return
          if ($pos = 1) then insert node <table-wrap id="{$i/@id}">{$i/*:label}{$t}</table-wrap> after $i
          else insert node <table-wrap id="{($i/@id || '.'|| $pos)}">{$t}</table-wrap>  after $i),
          
  for $x in $copy//*:fig/*:graphic
  let $count := count($x/ancestor::*:article//*:fig)
  let $pos := $count - count($x/following::*:fig)
  return
  if (($pos mod 4) = 0) then replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig4.jpg"/>
  else if (($pos mod 3) = 0) then replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig3.jpg"/>
  else if (($pos mod 2) = 0) then replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig2.jpg"/>
  else replace node $x with <graphic mime-subtype="jpeg" mimetype="image" xlink:href="fig1.jpg"/>
  
)
return
copy $copy2 := $copy
modify(
for $x in $copy2//*:addr-line/*:named-content
return replace node $x with $x/(*|text()),

for $x in $copy2//*:back/*:sec
  return if ($x/@sec-type="additional-information") then (insert node $x as last into $x/preceding::*:body, delete node $x)
  else if ($x/@sec-type="supplementary-material") then (insert node $x as last into $x/preceding::*:body, delete node $x)
  else delete node $x,
  
  for $m in $copy2//mml:math
  return delete node $m,
  
   for $x in  $copy2//*:inline-formula
  return insert node <tex-math>e=mc^2</tex-math> as last into $x,
  
  for $x in  $copy2//*:disp-formula
  return insert node <tex-math>e=mc^2</tex-math> as last into $x,
  
  for $x in  $copy2//*:underline/*:named-content[@content-type="sequence"]
  return replace node $x with $x/(text()|*),
  
  for $x in  $copy2//*:fn-group[@content-type="author-contribution"]
  return delete node $x
)
return 
copy $copy3 := $copy2
modify(

for $v in $copy3//*:contrib-group[@content-type="section"]
  return (delete node $v,insert node $v after $v/preceding-sibling::*:contrib-group),
  
  for $x in $copy3//*:self-uri
  return delete node $x,
  
  for $x in $copy3//*:custom-meta-group
  return delete node $x,
  
  for $x in $copy3//*:aff/*:institution
  return if ($x/@content-type) then replace value of node $x/@content-type with 'orgdiv1'
         else insert node attribute content-type {'orgname'} into $x,
         
  for $x in $copy3//*:ref//*:ext-link
  return replace node $x with <uri>{$x/text()}</uri>,
  
  for $x in $copy3//*:table-wrap-foot/*:fn
  return replace node $x with <fn-group>{$x}</fn-group>,
  
  for $x in $copy3//*:break
  return delete node $x,
  
  for $x in  $copy3//*:media[@mimetype="video"]
  return delete node $x,
  
  for $x in  $copy3//*:xref[@ref-type="video"]
  return delete node $x,
  
  for $x in  $copy3//*:sec[@sec-type="data-availability"]
  return delete node $x,
  
  for $x in $copy3//*:app
  return (delete node $x, insert node <sec>{$x/*[not(local-name() = 'object-id')]}</sec> as last into $x/preceding::*:body)

)
return 
copy $copy4 := $copy3
modify(
  for $x in  $copy4//*:p/*:fig
  return (delete node $x, insert node $x after $x/parent::*:p),
  
  for $x in  $copy4//*:p/*:fig-group
  return (delete node $x, insert node $x after $x/parent::*:p),
  
  for $x in  $copy4//*:p/*:table-wrap
  return (delete node $x, insert node $x after $x/parent::*:p),
  
  for $x in  $copy4//*:p/*:related-object
  return delete node $x,
  
  for $x in  $copy4//*:app-group
  return delete node $x,
  
  for $x in  $copy4//*:table-wrap-foot[count(fn-group)>1]
  return (for $c in $x/descendant::*:fn-group
           let $count :=  count($c/ancestor::*:table-wrap-foot//*:fn-group)
          let $pos := $count - count($c/following-sibling::*:fn-group)
        return if ($pos > 1) then (for $y in $c/*:fn return insert node $y as last into $y/ancestor::table-wrap-foot/descendant::*:fn-group[1], delete node $c)
      else ()),
      
  for $x in  $copy4//*:boxed-text
  return replace node $x with $x/*,
  
  for $x in  $copy4//*:element-citation[@publication-type="web"]
  return replace value of node $x/@publication-type with 'webpage'
)
return $copy4
return file:write($outputDir,$y)