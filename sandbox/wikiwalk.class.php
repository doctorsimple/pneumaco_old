<?php
class Wikiwalk {

var $link;
	
function grabpage ($goto) {
$gp = curl_init("http://en.wikipedia.org");
curl_setopt($gp,CURLOPT_URL,"http://en.wikipedia.org".$goto);
curl_setopt($gp, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($gp,CURLOPT_RETURNTRANSFER,1);
curl_setopt($gp,CURLOPT_VERBOSE,TRUE);
curl_setopt($gp,CURLOPT_HTTPHEADER,array('Content-Type:text/plain','User-Agent: WikiWalker(http://www.pneumaco.com)'));
$apage=curl_exec($gp);
curl_close($gp);
if (preg_match('|<h1 class="firstHeading">(.*)\(disambiguation\)</h1>|', $apage) > 1  ){ 
	$m=preg_match('|<li><a href="(.*)"(.*)</a>|U',$apage,$result);
	return $this->grabpage("{$result[1]}");
	}	
else if (preg_match_all('|<span class="redirectText"><a(.*)href="(.*)">(.*)</a></span>|Ui', $apage, $result) > 1  ){ 

	return $this->grabpage("{$result[2]}");
}
else {return $apage; }
}

function spltag($text,$tag){ 
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
//$go = "http://en.wikipedia.org/wiki/Special:Search?search=" . urlencode($phrase) ."&go=Go";
$go = "http://en.wikipedia.org/w/index.php?title=Special%3ASearch&search=" . urlencode($phrase);
curl_setopt($gp,CURLOPT_URL,$go);
curl_setopt($gp, CURLOPT_FOLLOWLOCATION, 3);
curl_setopt($gp,CURLOPT_RETURNTRANSFER,1);
curl_setopt($gp,CURLOPT_VERBOSE,TRUE);
curl_setopt($gp,CURLOPT_HTTPHEADER,array('Content-Type:text/plain','User-Agent: WikiWalk(http://www.pneumaco.com)'));
$apage=curl_exec($gp);
curl_close($gp);
if (strpos($apage,'No article title matches')>0 || strpos($apage,'Disambiguation')>0){ 
	$m=preg_match('|<li><a href="(.*)"(.*)</a>|U',$apage,$result);
	return $this->grabpage("{$result[1]}");
	}	
else {return $apage;}
}

function getpagetitle ($text) {
	$s=strpos($text,"<title>")+7;
	$f=strpos($text,"Wikipedia, the free encyclopedia</title>");
	
	if ($f>0) {	$mytitle=substr($text,$s,($f-$s));}
	else {$mytitle = "I'm lost";}	
	return $mytitle;
	}

function getparas($text) {
$r=explode('<div id="bodyContent">',$text);
$ps=$this->spltag ($r[0],"p");
//remove footnotes
$ps=preg_replace('|<sup(.*)</sup>|i','',$ps); 
$hold=count($ps);
for ($i=0;$i<=$hold;$i++) {
  $chk=strip_tags($ps[$i]);

  if (strlen($chk)<30 || $chk==$ps[$i] || strpos($ps[$i],'<a href="/wiki')===FALSE) {unset($ps[$i]);
	}
}

return $ps;
}

function getrandomline($text) {
$inp=$this->getparas($text);
if (count($inp)>1) {
	srand();
	$x=array_rand($inp); 
	//Remove footnotes
	$inp[$x]=preg_replace("|\[(.*)]|"," ",$inp[$x]);
	return $inp[$x];
	}
else {return $inp[0];}	
	
}

function getrandomlink($line) {
$find = '|<a href="/wiki/(.*)"(.*)</a>|Um';
preg_match_all($find,$line,$results);
$x=array_rand($results[1]);
return $results[1][$x];
}

}
?>