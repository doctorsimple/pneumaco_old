#!/usr/local/bin/perl 
#
#Set up variables
 
 print "Content-type: text/html\n\n";
 #querystring must be two letters
$letters= $ENV{'QUERY_STRING'};
$workdata='';



open (STUFF, "default.db");
local ($/)=undef;
$workdata=<STUFF>;
@linez=split(/\n/,$workdata);
sub linecompare
{
return (substr(@_[0],index(@_[0],'.jpg">',6)) cmp substr(@_[1],index(@_[1],'.jpg">',6)))
}
foreach $row (@linez)
{
@{$row}=split(/\|/,$row);
}
# go thru all entries in flatfile
for ($i=0;$i<$#linez;$i++)
{
#extract strings from the flatfile
$id=$linez[$i][1];
$filename=$linez[$i][2];
$venue=$linez[$i][3];
$date=$linez[$i][4];
$firstkey=$linez[$i][5];

#add matching records to alinez array
if (substr($firstkey,0,1) eq substr($letters,0,1) or substr($firstkey,0,1) eq substr($letters,1,1))
{
$alinez[$i]="<tr>\n<td><A HREF=\"../showpicture.html\?Pictures/$filename\">$firstkey</A></td>\n<td>$venue </td>\n<td>$date</td>\n<td><input type=\"submit\" value=\"Buy this Print\"  onClick=\"passdata(\'$id\');\"><\/td>\n</tr>";
}
}
@finished = sort {linecompare($a,$b)} @alinez;


print qq|
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Catalog of Artists</title>
<link rel=StyleSheet type="text/css" href="http://bandbstudios.com/bandb.css" title="BandBstyle">
<script language="javascript">
	<!--
	function passdata(name) { 
		
		  document.catalog.artist.value=name;
	  }
	  if (!parent.menu)
	  	{
		window.location="http://bandbstudios.com/alphaindex.html?AB"
		}
	function handoff(name)
	{
	parent.menu.foo.holdname.value = name;
	} 

	  //-->
	  </script>
	
</head>
<body bgcolor="black" text="yellow">

<h3>Browse Image Catalog</h3>
<p>Each listing in the catalog shows locations and dates of photo shoots done with that artist. 
NOJHF is the New Orleans Jazz Heritage Festival, MS is Mountain Stage.
<p>Click on the artist's name to see a a thumbnail of the print. You can also do a <a href="http://bandbstudios.com/bindex5.html" target="_top">name search</a>. We also have many images that have not been scanned yet - call to inquire if you are interested in a particular artist.</p>

<p> To buy a print: Click the buy button at the far right to add that print to 
your shopping cart.   Use the navigation bar above to 
see what's in your basket and to pay for your order. You can also order prints that are not thumbnailed 
here yet. Prints that you purchase will not have the copyright watermark.   If you have any questions, or want to see any of the thousands of images we have that are not in this catalog yet, email Brian at <a href="mailto:bblauser\@frognet.net">bblauser\@frognet.net</a> or call 1-877-414-2263 (toll free) during business hours EST.</b>
<p><a href="http://bandbstudios.com/priceinfo.html" target="_top">Want
to see Price information or alternate ways of ordering</a>?
<p>
<table border="1" cellpadding="4" style="font-size:14pt;font-weight:bold" class="namelist">
<tr>
<td><a href="alphacatpages.pl?AB">AB</a></td>
<td><a href="alphacatpages.pl?CD">CD</a></td>
<td><a href="alphacatpages.pl?EF">EF</a></td>
<td><a href="alphacatpages.pl?GH">GH</a></td>
<td><a href="alphacatpages.pl?IJ">IJ</a></td>
<td><a href="alphacatpages.pl?KL">KL</a></td>
<td><a href="alphacatpages.pl?MN">MN</a></td>
<td><a href="alphacatpages.pl?OP">OP</a></td>
<td><a href="alphacatpages.pl?QR">QR</a></td>
<td><a href="alphacatpages.pl?ST">ST</a></td>
<td><a href="alphacatpages.pl?UV">UV</a></td>
<td><a href="alphacatpages.pl?WX">WX</a></td>
<td><a href="alphacatpages.pl?YZ">YZ</a></td>



</tr>
</table>



<form name="catalog" action="http://www.bandbstudios.com/orderoptions.php" method="get" target="_top">

<input type="hidden" name="artist">
<table border cellspacing="1" cellpadding="3" width="100%">

|;
print join ("\n",@finished);
print qq|
</table>
</form>
<p><div class="menu">  <a href="http://bandbstudios.com/index.html" target="_top">Main Page</a> &nbsp;-&nbsp;  &nbsp;-&nbsp; <a href="../bindex5.html" target="_top">Name Search</a> &nbsp;-&nbsp; <a href="../postcards.html" target="_top">Postcards</a> &nbsp;-&nbsp; <a href="../multimagegallery.html" target="_top">MultiPanels</a> &nbsp;-&nbsp; <a href="../fullsizegallery.html" target="_top">Fullsize</a> &nbsp;-&nbsp; <a href="../catalogothers.html">Others  catalog</a></div>
</body>
</html>
|;

