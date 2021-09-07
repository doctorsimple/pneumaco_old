
<?php
function grabpage ($goto) {
$gp = curl_init("http://en.wikipedia.org");
curl_setopt($gp,CURLOPT_URL,$goto);
curl_setopt($gp, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($gp,CURLOPT_RETURNTRANSFER,1);
curl_setopt($gp,CURLOPT_VERBOSE,TRUE);
$apage=curl_exec($gp);
curl_close($gp);
return $apage;
}

function untag($text,$tag){ 
    $tmp=array(); 
    $preg="|<".$tag.">(.*?)</".$tag.">|si"; 
    preg_match_all($preg,$text,$tags); 
    foreach ($tags[1] as $tmpcont){ 
		
        {$tmp[]=$tmpcont;} 
 
        } 
    return $tmp; 
}

function getrandompage($phrase) {
$gp = curl_init("http://en.wikipedia.org");
$go = "http://en.wikipedia.org/wiki/Special:Search?search=" . urlencode($phrase) ."&go=Go";
curl_setopt($gp,CURLOPT_URL,$go);
curl_setopt($gp, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($gp,CURLOPT_RETURNTRANSFER,1);
curl_setopt($gp,CURLOPT_VERBOSE,TRUE);
curl_setopt($gp,CURLOPT_HTTPHEADER,array('Content-Type:text/plain','User-Agent: WikiWalk(+http://www.pneumaco.com)'));
$apage=curl_exec($gp);
curl_close($gp);
//return $apage;
if (strpos($apage,'Search results')>0 || strpos($apage,'disambiguation')>0){ 
	$m=preg_match('|<li><a href="(.*)"(.*)</a>|U',$apage,$result);
	return grabpage("http://en.wikipedia.org{$result[1]}");
	}	
else {return $apage;}
}

function getparas($text) {
$r=explode('<div id="bodyContent">',$text);
$ps=array();
$ps=untag ($r[1],"p");
$hold=count($ps);
for ($i=0;$i<=$hold;$i++) {
  $chk=strip_tags($ps[$i]);
	
  if ($chk=="" || $chk==$ps[$i] || strpos($ps[$i],'<a href="/wiki')===FALSE) {unset($ps[$i]);}
}
return $ps;
}

function getrandomline($text) {
$inp=getparas($text);
$x=array_rand($inp);
return $inp[$x];
}

function getrandomlink($line) {
$find = '|<a href="/wiki/(.*)</a>|U';
preg_match_all($find,$line,$atags);
return $atags[0];
}

$life = grabpage('http://en.wikipedia.org/wiki/Special:Random');

$x=getrandomline($life);
$y=getrandomlink($x);
$z=getrandompage("blue pants");
echo $z;


?>