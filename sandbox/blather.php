<script>
	var nextlink="";
	var countp=0;
	var waiting=0;
function addPara(ask)
{
try
  {
  // Firefox, Opera 8.0+, Safari
  xmlHttp=new XMLHttpRequest();
  }
catch (e)
  {
  // Internet Explorer
  try
    {
    xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
    }
  catch (e)
    {
    try
      {
      xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
      }
    catch (e)
      {
      alert("Your browser does not support AJAX! This page won't work.");
      return false;
      }
    }
  }
xmlHttp.onreadystatechange=function() {
//Do stuff here
if (xmlHttp.readyState==2) {
var newp = document.createElement('p');
newp.innerHTML="Loading...";
current="para"+countp;
newp.id=current;
newp.title="Fore reals";
document.getElementById('blathering').appendChild(newp);

}

if (xmlHttp.readyState==4) {
alert(xmlHttp.responseText);
mark=xmlHttp.responseText.indexOf('++|++');
newline=xmlHttp.responseText.substring(0,mark);
newlink=xmlHttp.responseText.substr(mark+5);

document.getElementById('para'+countp).innerHTML = newline;

nextlink=newlink;alert(nextlink);
countp++;
waiting=0;
}
}

url="blather.ajax.php?" + ask;
xmlHttp.open("GET",url,"true");
xmlHttp.send(null);
}
	
function initialize (howmany) {
p=document.getElementById('startphrase');
waiting=1;
r=addPara("phrase="+p.value);
roll=setInterval('keeprolling()',3000);
document.getElementById('stopbutn').style.display="inline";
}

function keeprolling() {
if (waiting==0) {
waiting=1;
addPara('link=/wiki/'+nextlink);
}
}

function stopRolling() {
clearInterval(roll);
}
</script>
<div style="text-align:center">Enter some words and press go.<br />

<input name="startphrase" id="startphrase" size="20"><input type="button" value="Go!" onclick="initialize(5);">

<input type="button" id="stopbutn" value="Stop!" style="display:none" onclick="stopRolling();">
<input type="button" value="Start Again" style="display:none" onclick="initialize(5);">
<div id="blathering">  </div>

