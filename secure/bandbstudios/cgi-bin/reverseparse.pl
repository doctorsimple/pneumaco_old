#!/usr/local/bin/perl 
#
#Set up variables
 print "Content-type: text/html\n\n";

$workdata='';



open (STUFF, "newthings.db");
local ($/)=undef;
$workdata=<STUFF>;
@linez=split(/\n/,$workdata);
foreach $row (@linez)
{
@{$row}=split(/\|/,$row);
}
# C in this line is the number of lines in the text to be processed
for ($c=0;$c<175;$c++)
{

$id=$linez[$c][0];
$filename=$linez[$c][1];
$venue=$linez[$c][2];
$date=$linez[$c][3];
$firstkey=$linez[$c][4];
$alinez[$c]="<tr>\n<td><A HREF=\"showpicture.html\?Pictures/$filename\">$firstkey</A></td>\n<td>$venue </td>\n<td>$date</td>\n<td><input type=\"submit\" value=\"Buy this Print\" onClick=\"passdata(\'$id\')\"><\/td>\n</tr>";

}
@finished = sort @alinez;



print join ("\n",@finished);


