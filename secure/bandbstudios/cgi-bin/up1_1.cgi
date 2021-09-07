#!/usr/bin/perl
#### THIS IS THE BASIC UPLOAD SCRIPT!
#### The top line must point to the location of perl on your server.
#### up.cgi is designed to be placed in the directory you up load images to
#### if it is you needn't configure any thing else except. CHMOD 755 (RWX R_X R_X)
#### To upload to a different directory change $dir & $http below.
#### The upload directory must have write permissions. CHMOD 666. (try 777 if error 500.)

use CGI qw/:standard/; 
# DO NOT REMOVE. You must have CGI.PM module on your server. (MOST SERVERS DO.)

use CGI::Carp qw/fatalsToBrowser/;
## Carp helps with debugging REMOVE IF Carp is not on your server, It should be.
$| = 1;
# Flushes the open filehandles. Not required, however, suppose to be more effective.
#################################################################################
# up.cgi ver 1.1 Last modified 24-November-2000
#################################################################################
# This script is free, However If you wish to distribute, support development. (Remember
# free script keep the price of "pay for script" down), or just remove the P.o.W link
# I require a small donation to:
# O.S.C.A.R.
# Offering Support to Children And Relatives.
# For children with brain or spinal tumours and their families.
# Make your cheque payable to
#			OSCAR
#	Radcliffe Infirmary Charitable fund.
# And send them to
#	C/O Lesley Manning,
#	Leopold Ward,
#	Radcliffe Infirmary,
#	Woodstock road,
#	Oxford,
#	OX2 6HE,
#	ENGLAND.
#
#	Registered Charity No 105728899
#
# 
#  NO-ONE FORM THE OSCAR CHARITY HAS ANY CONECTION WITH THIS SITE OR THESE SCRIPTS>
#  OSCAR IS PURELY MY (Ian Doyle) CHOSEN CHARITY. 
#
#  minimum donation  £5 or $10 for non-commercial sites and £10 or $20 for commercial sites.
#  There is no Maximium OSCAR needs your help...
#  Please mark the back of the cheque with "REF: perls of Wisdom" 
#  and drop me a line to say you have made a donation.> OSCARD@perls-of-wisdom.virtualave.net
#
#  If any one wants to drop me a donation (as if!) send me a mail and I will let you know how.
#  scriptdonations@perls-of-wisdom.virtualave.net  
#  

             #    #   # ##### ##### #####    #
             #    ##  # #   #   #   #        #
           # # #  # # # #   #   #   ###    # # #
            # #   #  ## #   #   #   #       # #
             #    #   # #####   #   #####    #  
  
# Use of this script is always at you our risk. By using this code you agree to 
# indemnify Ian Doyle and Perls of Wisdom from any liability that might arise from its 
# use. 
# Feel free to modify, (DO NOT DISTRUBUTE WITHOUT PERMISSION!)  and send us any improvements.
# You ARE NOT allowed to remove any comments. Thanks, Ian. 
# This script will not work on TRIPOD, i think the UPLOAD feature of Lincoln Stiens
# CGI.PM module has been disabled, By all means prove me wrong.
# see http://stein.cshl.org/~lstein/ for CGI.pm info
# If you have donated to this script or OSCAR you may remove any links 
# or reference to Perls-of-Wisdom below these comments. RATE THIS SCRIPT AT
#
# http://cgi.resourceindex.com/Programs_and_Scripts/Perl/File_Management/File_Uploading/
#
# or
#
# http://www.hotscripts.com/Perl/Scripts_and_Programs/File_Manipulation/Upload_Systems/
# 
#################################################################################

# VERSION 1.1
# BUG REPORT.
# First release will only handle standard dos format file names.
#
#
#
# MODIFICATIONS
# version 1.1
# Changed regular expression to allow spaces in directory
# added the \i option to allow caps in extentions
#
#
#

$title='UPLOAD PAGE!';
# CHANGE THE TITLE IF REQUIRED.

$dir='/home/bblauser/bandbstudios.com/html/seniors/';
#This is the relative/absolute path to the directory you wish to upload to. 
# ./ is the same directory as this script is placed. NEVER USE \ even for windows

$http='http://bandbstudios.com/seniors/';
#uncomment the above line and put in your URL to the upload directory if you have changed $dir='./';

$limit= 60;
# max xKb posts. What ever number you place here is the max file size in KB to upload.

@ext= qw(jpg gif bmp);
# only upload files with the ext's in the brackets. ie @ext= qw(txt html htm asp this that);


#DO NOT CHANGE ANYTHING BELOW HERE UNLESS YOU KNOW CGI.PM 

$encoding='multipart/form-data';
$match=0; 
$CGI::POST_MAX=1024 * $limit; 
$q = new CGI; 
print $q->header();

print $q->start_html(-title=>"$title\n", 
		-meta=>{'description'=>'Perl script to upload any file',
			  'keywords'=>'CGI.pm upload perl script cgi',
			  'copyright'=>'copyright 2000 Perls Of wisdom',},
		-dtd=>1, 
		-BGCOLOR=>'white',
		-TEXT=>'navy',
		-link=>'green',
		-vlink=>'red',
		-alink=>'blue');
		
print "\n"; 
print <<PICTURES;
<table border="1">
<tr>
<td>
<img src="../seniors/1thm.jpg"><br>1</td>
<td>
<img src="../seniors/2thm.jpg"><br>2</td>
<td>
<img src="../seniors/3thm.jpg"><br>3</td>
<td>
<img src="../seniors/4thm.jpg"><br>4</td>
</tr>
<tr>
<td>
<img src="../seniors/5thm.jpg"><br>5</td>
<td>
<img src="../seniors/6thm.jpg"><br>6</td>
<td>
<img src="../seniors/7thm.jpg"><br>7</td>
<td>
<img src="../seniors/8thm.jpg"><br>8</td>
</tr>
<tr>
<td>
<img src="../seniors/9thm.jpg"><br>9</td>
<td>
<img src="../seniors/10thm.jpg"><br>10</td>
<td>
<img src="../seniors/11thm.jpg"><br>11</td>
<td>
<img src="../seniors/12thm.jpg"><br>12</td>
</tr>
<tr>
<td>
<img src="../seniors/13thm.jpg"><br>13</td>
<td>
<img src="../seniors/14thm.jpg"><br>14</td>
<td>
<img src="../seniors/15thm.jpg"><br>15</td>
<td>
<img src="../seniors/16thm.jpg"><br>16</td>
</tr>
<tr>
<td>
<img src="../seniors/17thm.jpg"><br>17</td>
<td>
<img src="../seniors/18thm.jpg"><br>18</td>
<td>
<img src="../seniors/19thm.jpg"><br>19</td>
<td>
<img src="../seniors/20thm.jpg"><br>20</td>
</tr>

</table>
PICTURES

print $q->h1("$title"), "Enter your picture to upload (@ext ${limit}Kb Max.)\n";
print $q->startform($method,$action,$encoding);
print "Which picture-";
print $q->textfield('number');
print $q->filefield(-name=>'uploaded_file', -default=>'starting value', -size=>50, -maxlength=>180); 
print $q->submit(-name=>'button_name', -value=>'UPLOAD'); 


print $q->endform;
$filename = $q->param('uploaded_file');
$thingbutt = $q->param('number');
$pictochange = $thingbutt.'thm.jpg';
$filename2 = $filename;
$filename2 =~ /\w:[\\[\w- ]*\\]*([\w- ]*.\w{1,3})$/g;$file=$1;

if ($filename){
	foreach $ext (@ext){
		if (grep /$ext$/i,$filename){$match=1;print "$pictochange  UPLOADED!<BR>\n";
		}
	}
		if ($match){
			&upload;
		}
			else {
				&error("File Format not supported, $file Can not be uploaded!");
			}	
}	

sub upload{

open(OUTFILE, ">$dir$pictochange")||&error("Can't open $dir$pictochange. $!");
#binmode OUTFILE;
# binmode is for windows only. Ignored by unix
while ($bytesread=read($filename,$buffer,1024)) 
{print OUTFILE $buffer;99 } 
close (OUTFILE); 

}
if ($match){
print "<img src='$http$file'>";
}

sub error{
print "content-type:text/html\n\n";
@error=@_;
print "<H2>@error</H2>";
exit;
}

print "<br><br>\n";
print $q->
	hr({-width=>'90%',-size=>3,-style=>'raised'}),
	p({-align=>CENTER},'Upload script By ',
	a({-href=>'http://perls-of-wisdom.virtualave.net/'},'Perls of wisdom')
	);
print "</body></html>\n";







