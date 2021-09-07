#!/usr/local/bin/perl 
#
#Set up variables
 print "Content-type: text/html\n\n";
$i=0;
$p=0;
$workdata='';

my ($id,$filename,$venue,$date,$firstkey);



open (STUFF, "fullcataloghtml.html");
local ($/)=undef;
$workdata=<STUFF>;
@stuph=split(/\n/,$workdata);
THANGS: for ($i=0;$i<1000;$i++)
{
while ($stuph[$p] eq "")
	{$p++}
$filename=$stuph[$p];
$p++;
$firstkey=$stuph[$p];
$p++;
$venue=$stuph[$p];
$p++;
$date=$stuph[$p];
$p++;
$id=$stuph[$p];
$p++;
print "$id|$filename|$venue|$date|$firstkey|||||||||||<br>\n";
if ($p > $#stuph)
{last THANGS}
}




print "Done\n";
#Read in big text file
