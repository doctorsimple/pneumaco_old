#!/usr/bin/perl
#
# AdminPro version 1.0.4 by Craig Richards
# October 11, 2000
# 
# You may try AdminPro free for up to 10 days. If you like and 
# want to continue using it, please send US$20.00 (single-user 
# license) to: 
#                        Craig Richards
#                        1014 Zook Drive 
#                    Glendale, CA 91202-2623 
#  
# You may also pay your shareware fee online through the secure 
# RegNow website at:
# https://www.regnow.com/softsell/nph-softsell.cgi?item=4287-1 
#  
# Your encouragement and support enable me to continue to add new 
# features and develop new products. 
# Go to http://www.CraigRichards.com/software/ for upgrade info 
# as it becomes available.
# 
# # # # # # # # # # # # # # # #
# 
# Created to be a powerful, completely browser-based, 
# platform-independent tool, AdminPro will... 
# 
#       * allow you to navigate your domain directory structure 
#         with point and click simplicity
# 
#       * test the syntax of your CGI scripts and report any 
#         errors right in your browser
# 
#       * create a new directory
# 
#       * upload an image or text file
# 
#       * modify a file or directory's permissions
# 
#       * delete an empty directory
# 
#       * delete a file
# 
# 
# INSTALLATION INSTRUCTIONS - PLEASE READ
# 
# You may need to change the path to Perl (above)
# A good alternate line is  #!/usr/local/perl
# Use whatever is at the top of any existing (working) scripts 
# on your server.
# 
# DO NOT change the name of this script as its performance will 
# be adversely affected. However, you may change the extension 
# to ".pl" if ".cgi" is not supported by your server.
# 
# To include "warnings" in your reports, simply add  -w  
# after the path to perl at the top of the scripts you're 
# testing, i.e.    #!/usr/local/bin/perl -w
# 
# 
# INSTALLATION INSTRUCTIONS
# 
#--> Step 1: upload this file
# 
# Simply upload this file (as ASCII text) to any path 
# in your domain or at its root. If your server administrator 
# restricts executables to a cgi or cgi-bin directory, 
# that's where you'd want to put the adminpro.cgi file.
# 
#--> Step 2: set AdminPro's permissions (Unix/Linux)
# 
# On Unix/Linux and perhaps other servers, set the 
# file permissions for the adminpro.cgi document to 
# 755 (world executable or rwxr-xr-x).
# 
#--> Step 3: upload images (optional) 
# f16x13.gif  f11x13.gif  i11x13.gif  t9x13.gif  td9x13.gif
# 
# You may optionally upload the five small icon images. 
# Do NOT change the names of the image files and be sure to
# upload them to the same path to which you uploaded this
# script. That directory needs to be world readable (755 or 777).
# If you cannot change the permissions of that directory, place
# the script and icons in a different directory or do not
# upload the icons. AdminPro will automatically determine
# their presence then read them from your server. If they
# don't exist in the same path as this script, they will be
# read from CraigRichards.com.
# 
# That's it! Now open your browser and type:
# http://www.mydomainhere.com/path/adminpro.cgi
#            ^                ^   your domain and path go here)
# and follow the simple online prompts.
# 
# # # # # # # # # # # # # # # #
# 
# WHEN YOU USE AdminPro
# YOU AGREE WITH THESE TERMS AND CONDITIONS
# 
# We encourage your questions, feedback and suggestions. 
# AdminPro is distributed as "shareware" so limited user 
# support is provided for licensed users. User agrees to run 
# this application at his/her own risk, assumes all liability, 
# and no warranty as to the suitability or performance of 
# AdminPro for your specific purpose is stated nor implied. 
# If dissatisfied with AdminPro, discontinue use.
# 
# AdminPro may be distributed via the Internet or included 
# on CD-ROM as long as the original source code, comments, 
# instructions and credits remain intact. AdminPro is 
# shareware and may not be individually sold by third parties 
# though it may be bundled with other software whether that 
# distribution contains other software that is free, 
# shareware, demo or sold. In essence, no other parties 
# should materially profit from distribution of this script.
# 
# You are urged not to link to this script from any public 
# pages on your site as AdminPro displays all the paths and 
# documents on your site - even hidden ones. Public access to 
# AdminPro may compromise the security of your site 
# and/or server.
# 
# Application and interface is (c)Copyright 2000. 
# All rights reserved worldwide.
# 
# Feel free to email me at "CGI@CraigRichards.com" with your 
# comments and/or suggestions or use the Registration/Contact 
# form on my software pages.
# 
# # # # # # # # # # # # # # # #
#### 
#### USER PREFERENCES DEFAULTS
   # 
#--> access-restriction security (optional)
   # complete steps 1 and 2 below
   # (only if you use a static IP address)
   #
#--> Step 1: input your static IP address here:
   #
   $ipaddress .= "000.000.000.000\n"; # your IP goes here
   $ipaddress .= "000.000.000.000\n"; # add another (and so on)...
   #
   # (for multiple administrators, just duplicate 
   # the line below to add more static IP addresses.)
   #
#--> Step 2: turn on access-restriction security
   #
   $secure=0;
   #       ^ set to 1 to enable IP address security.
   #
   # note: failed access attempts are directed to a special 
   # error page located at CraigRichards.com
   #
#--> Step 1: set date format display default (optional)
   # 
   $uk=0; # 0 is for US - 1 is for UK
   #   ^ set this value to 1 to display UK date format
   #     as "day-month-year"
   #     set to 0 to display US date format
   #     as "month-day-year"
   #
#--> Step 1: local/server time adjustment default (optional)
   # 
   $tz= 0;
   #    ^ adjust this value to 
   #      subtract or add to the server's system clock
   #      to add 2 hours, for example, the value is 2
   #      subtract 3 hours by using the value -3 
   #
#--> Step 1: manual path editing default (optional)
   # 
   $dispath=0;
   #        ^ set this value to 1 to add a field to the form
   #          that will permit you to input the path in the
   #          server tree to which you'd like to navigate
   #          (most people just point and click so the default
   #          is set at 0 - disabled)
   #
#--> Step 1: set display color values (optional)
   #
   $c1="#006600";  # heads & borders - default: dark green
   $c2="#000000";  # text - default: black
   $c3="#E0E0E0";  # DIR table bg - default: gray
   $c3a="#CCCCCC"; # DIR alt table bg - default:  darker gray
   $c4="#E0E0E0";  # instruct/results bg - default: gray
   $c5="#000000";  # overall interface bg - default: black
   $c6="#7F007F";  # mouseover highlight (CCS) - default: violet
   $c7="#FFFFFF";  # mouseover text (CCS) - default: white
   $face="arial,helvetica,sans-serif"; # font set
   #
####
# # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # #
#                                           # #
# DO NOT CHANGE ANYTHING BELOW THIS POINT!  # #
#                                           # #
# # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # #
# 
# 
##########
# VARIABLES DEFINED

use English; # variables are identified in error report
if ($ENV{CONTENT_TYPE} =~ /multipart/i) {&transParse;}
else {&inParse;}
$sn="$ENV{SERVER_NAME}";
$root="$ENV{DOCUMENT_ROOT}";
$hst="$ENV{HTTP_HOST}";
$fnt="<FONT SIZE=2 FACE=$face>";
$fnt1="<FONT SIZE=1 FACE=$face>";
$fnt1w="<FONT SIZE=1 COLOR=$c7 FACE=$face>";
$v="1.0.4";
$version="v $v";
$secflag="not restricted";
$dcnt=0; $fcnt=0;

##########
# RESTRICTED-ACCESS SUBROUTINE

if ($secure eq 1) {&access;}
 sub access {
 if ($ipaddress !~ /$ENV{REMOTE_ADDR}/) {
 print "Location: http://www.CraigRichards.com/restricted.html?v=$v&sn=$sn&hst=$hst\n\n";
 exit;
 } else {$secflag="<FONT SIZE=2 COLOR=$c1><B>restricted</B></FONT>";}
}

##########
# CONDITIONAL VARIABLES DEFINED

$title="File Administration & Debugging";
$t{'uk'}=$uk unless ($t{'uk'});
if ($t{'uk'} == 0) {$usck=" CHECKED";}
if ($t{'uk'} == 1) {$ukck=" CHECKED";}
$uk=$t{'uk'};
if (($t{'tz'} =~ /\d+/) && ($t{'tz'} != $tz)) {$tz=$t{'tz'};}
 else {$t{'tz'}=$tz;}
$t{'dispath'}=$dispath unless ($t{'dispath'});
if ($t{'dispath'} == 1) {$dispathck=" CHECKED";}
$dispath=$t{'dispath'};

if (!$t{'run'}) {
 $path="$ENV{SCRIPT_FILENAME}";
 $path =~ s/adminpro.*?\..+?$//g;
 $cgirootpath=$path;
	$cgipath=$ENV{SCRIPT_NAME};
	$t{'adminpro'}=$cgipath;
 $cgipath =~ s/adminpro.*?\..+?$//g;
 &instblock;
 }
else {
 $path="$t{'path'}";
 if ($t{'newfile'} || $t{'newdir'}=~ /\w+/) {&runtest;}
 elsif (!$t{'test'}) {
 &instblock;
 }
 else {
  if (!(-e "$path$t{'test'}")) {
  push(@error,"<TR><TD COLSPAN=2>$fnt <FONT COLOR=FF0000>Sorry, could not find <B>$t{'test'}</B>.</FONT><BR>Check the file name and try again.</TD></TR>\n\n");
  $title="Error - File Not Found";
  }
  else {
  &runtest;
  }
 }
}
 &result;


##########
# CHMOD, DELETE OR TEST THE SYNTAX

sub runtest {

 if ($t{'newdir'}=~ /\w+/) {
  if (-e "$path$t{'newdir'}") {
 push(@error,"<TR><TD COLSPAN=2>$fnt A directory named \"<B>$t{'newdir'}</B>\" already exists.</TD></TR>\n\n");
 $title="$t{'newdir'} Already Exists";
 } else {
  mkdir("$path$t{'newdir'}",0777);
  if (-e "$path$t{'newdir'}") {
  push(@error,"<TR><TD COLSPAN=2>$fnt The directory \"<B>$t{'newdir'}</B>\" has been created.</TD></TR>\n\n");
 $title="$t{'newdir'} Created";
   }
  }
 } elsif ($t{'newfile'}) {&write_file;}
 &chmod;
 if (($t{'syntax'}) && ($t{'test'})) {
 @all = `($path$t{'test'} | 's/^/stdout:/') 2>&1`;
 for (@all) {push @{s/stdout://?\@outlines: \@errlines},$_}
  if (@errlines) {
   if (($ENV{SERVER_SOFTWARE} =~ /(unix|linux)/i) && (!(-x "$path$t{'test'}"))) {
   push(@error,"<TR><TD COLSPAN=2>$fnt <FONT COLOR=FF0000>Sorry, <B>$t{'test'}</B> does not appear to be executable.</FONT><BR>\nSet file permissions to 755 or 775 and test again.</TD></TR>\n\n");
   }
   foreach $errline(@errlines) {$qty++;
 $errline =~ s/ (at|of) //g;
 $errline =~ s/$path$t{'test'}//g;
 $errline =~ s/line /line&nbsp;/g;
 $errline =~ s/</&#60;/g;
 $errline =~ s/>/&#62;/g;
 $errline =~ s/\//&#47;/g;
 $errline =~ s/sh: : No such file or directory/Executable error due to invalid characters in the file &#150; Suggest re-upload $t{'test'} to server via FTP and test again./g;
 $errline =~ s/sh: : //g;
 $error="<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 $qty</TD><TD>$fnt$errline</TD></TR>\n"; push(@error,$error);
  }
 }
else {
 push(@error,"<TR><TD COLSPAN=2>$fnt No errors were found when testing <B>$t{'test'}</B></TD></TR>\n\n");
 $title="Congratulations!";
  }
 }
 elsif ($t{'delete'}) {
 unlink("$path$t{'test'}");
  if (-e "$path$t{'test'}") {
  push(@error,"<TR><TD COLSPAN=2>$fnt The file \"<B>$t{'test'}</B>\" could not be deleted from the server.</TD></TR>\n\n");
  $title="$t{'test'} Not Deleted"; undef($t{'test'});
  }
 else {
  push(@error,"<TR><TD COLSPAN=2>$fnt The file \"<B>$t{'test'}</B>\" was permanently deleted from the server.</TD></TR>\n\n");
  $title="$t{'test'} Deleted"; undef($t{'test'});
  }
 }
 elsif ($t{'remove'}) {
 rmdir("$path$t{'test'}");
  if (-e "$path$t{'test'}") {
  push(@error,"<TR><TD COLSPAN=2>$fnt The directory \"<B>$t{'test'}</B>\" could not be removed from the server.</TD></TR>\n\n");
  $title="$t{'test'} Not Removed"; undef($t{'test'});
  }
  else {
  push(@error,"<TR><TD COLSPAN=2>$fnt The directory \"<B>$t{'test'}</B>\" was permanently deleted from the server.</TD></TR>\n\n");
  $title="$t{'test'} Deleted"; undef($t{'test'});
  }
 }
elsif (!$t{'chmod'} && !$t{'newdir'} && !$t{'newfile'}) {
 push(@error,"<TR><TD COLSPAN=2>$fnt No action was taken because the selected file \"<B>$t{'test'}</B>\" had no process requested for it. You may change permissions and/or test its syntax or delete the file.</TD></TR>\n\n");
 $title="No Process Requested";
 }
}


##########
# PRINT HTML RESULT

sub result {

&viewDir; 
&form;

print "Content-type: text/html\n\n";

$jschmod=<<"JSchmod";

function calcperm() {var aa=0;var ab=0;var ac=0;var ba=0;var bb=0;var bc=0;var ca=0;var cb=0;var cc=0;
if (document.adminpro.aa.checked) {aa=400;}
if (document.adminpro.ab.checked) {ab=200;}
if (document.adminpro.ac.checked) {ac=100;}
if (document.adminpro.ba.checked) {ba=40;}
if (document.adminpro.bb.checked) {bb=20;}
if (document.adminpro.bc.checked) {bc=10;}
if (document.adminpro.ca.checked) {ca=4;}
if (document.adminpro.cb.checked) {cb=2;}
if (document.adminpro.cc.checked) {cc=1;}
document.adminpro.chmod.value=aa+ab+ac+ba+bb+bc+ca+cb+cc; return true;}
function setperms() {var val=document.adminpro.chmod.value;
document.adminpro.aa.checked=0; document.adminpro.ab.checked=0; document.adminpro.ac.checked=0; document.adminpro.ba.checked=0; document.adminpro.bb.checked=0; document.adminpro.bc.checked=0; document.adminpro.ca.checked=0; document.adminpro.cb.checked=0; document.adminpro.cc.checked=0;
if (val==100) {document.adminpro.ac.checked=1;}
if (val==110) {document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;}
if (val==111) {document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==200) {document.adminpro.ab.checked=1;}
if (val==220) {document.adminpro.ab.checked=1;document.adminpro.bb.checked=1;}
if (val==222) {document.adminpro.ab.checked=1;document.adminpro.bb.checked=1;document.adminpro.cb.checked=1;}
if (val==300) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;}
if (val==310) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;}
if (val==311) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==320) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;}
if (val==322) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.cb.checked=1;}
if (val==330) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;}
if (val==331) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==332) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cb.checked=1;}
if (val==333) {document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cb.checked=1;document.adminpro.cc.checked=1;}
if (val==400) {document.adminpro.aa.checked=1;}
if (val==440) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;}
if (val==444) {document.adminpro.aa.checked=1;document.adminpro.ba.checked=1;document.adminpro.ca.checked=1;}
if (val==500) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;}
if (val==510) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;}
if (val==510) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;}
if (val==511) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==550) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;}
if (val==551) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==544) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.ca.checked=1;}
if (val==554) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;}
if (val==555) {document.adminpro.aa.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;document.adminpro.cc.checked=1;}
if (val==600) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;}
if (val==620) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.bb.checked=1;}
if (val==622) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.bb.checked=1;document.adminpro.cb.checked=1;}
if (val==640) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ba.checked=1;}
if (val==644) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ba.checked=1;document.adminpro.ca.checked=1;}
if (val==660) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;}
if (val==662) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.cb.checked=1;}
if (val==664) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.ca.checked=1;}
if (val==666) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.ca.checked=1;document.adminpro.cb.checked=1;}
if (val==700) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;}
if (val==710) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;}
if (val==711) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==720) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;}
if (val==722) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.cb.checked=1;}
if (val==730) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;}
if (val==731) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==732) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cb.checked=1;}
if (val==733) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cb.checked=1;document.adminpro.cc.checked=1;}
if (val==740) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;}
if (val==744) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.ca.checked=1;}
if (val==750) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;}
if (val==751) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==754) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;}
if (val==755) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;document.adminpro.cc.checked=1;}
if (val==760) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;}
if (val==762) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.cb.checked=1;}
if (val==764) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.ca.checked=1;}
if (val==766) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;}
if (val==770) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;}
if (val==771) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cc.checked=1;}
if (val==772) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cb.checked=1;}
if (val==773) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.cb.checked=1;document.adminpro.cc.checked=1;}
if (val==774) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;}
if (val==775) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;document.adminpro.cc.checked=1;}
if (val==776) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;document.adminpro.cb.checked=1;}
if (val==777) {document.adminpro.aa.checked=1;document.adminpro.ab.checked=1;document.adminpro.ac.checked=1;document.adminpro.ba.checked=1;document.adminpro.bb.checked=1;document.adminpro.bc.checked=1;document.adminpro.ca.checked=1;document.adminpro.cb.checked=1;document.adminpro.cc.checked=1;}
}
JSchmod

undef($jschmod) if ($disablechmod);

print <<"Print_Result";

<HTML><HEAD><TITLE>AdminPro | $title</TITLE>

<SCRIPT LANGUAGE="JavaScript">
<!---// Begin script
function verify(file) {
 if (confirm('Permanently delete\\n     ' + file + '\\nAre you sure?')) {return true;}
 else {alert('The deletion of\\n     ' + file + '\\nwas cancelled.'); document.adminpro.test.value=""; return false;}
}
$jschmod
// end script -->
</SCRIPT>

<STYLE TYPE="text/css">
	A:link {text-decoration:underline;color:$c2}
	A:visited {text-decoration:underline;color:$c1;}
	A:active {text-decoration:none;color:$c7;background-color:$c6;}
	A:hover {text-decoration:none;color:$c7;background-color:$c6;}
</STYLE>

</HEAD>
<BODY BGCOLOR=$c4 MARGINWIDTH=0 MARGINHEIGHT=0 LEFTMARGIN=0 RIGHTMARGIN=0 TOPMARGIN=0 BOTTOMMARGIN=0 TEXT=000000 LINK=$c2 ALINK=FF0000 VLINK=$c1 onLoad="document.adminpro.test.focus();$disablechmod"><BASEFONT SIZE=2><A NAME="top"></A>$fnt1
$head
<CENTER><TABLE BGCOLOR=$c5 CELLPADDING=6 CELLSPACING=0 BORDER=0><TR ALIGN=CENTER VALIGN=TOP><TD><TABLE BGCOLOR=$c1 CELLPADDING=1 CELLSPACING=0 BORDER=0><TR VALIGN=TOP><TD ALIGN=LEFT NOWRAP><NOBR>$fnt1w$item</FONT></NOBR></TD><TD WIDTH=100% ALIGN=CENTER NOWRAP><NOBR>$fnt1w directory of $fnt<B>$curdir</B></FONT></NOBR><TD NOWRAP><NOBR>$fnt1<FONT COLOR=$c1>$item</NOBR></TD><TR>
<TR><TD COLSPAN=3><TABLE BGCOLOR=$c3 CELLPADDING=3 CELLSPACING=0 BORDER=0><TR><TD>
<TABLE BGCOLOR=$c3 CELLPADDING=0 CELLSPACING=0 BORDER=0>
$return
<TR VALIGN=TOP><TD NOWRAP>$fnt1<FONT COLOR=$c1>$dhd&nbsp;</FONT></TD><TD ALIGN=CENTER NOWRAP>
$fnt1<FONT COLOR=$c1>&nbsp;del&nbsp;</FONT></TD><TD ALIGN=RIGHT NOWRAP>
$fnt1&nbsp;</FONT></TD><TD COLSPAN=2 ALIGN=CENTER NOWRAP>
$fnt1<FONT COLOR=$c1>&nbsp;date modified&nbsp;</FONT></TD><TD NOWRAP>$fnt1<FONT COLOR=$c1>&nbsp;permissions</FONT></TD></TR>
$directorydata
<TR VALIGN=TOP><TD NOWRAP>$fnt1<FONT COLOR=$c1>$fhd&nbsp;</FONT></TD><TD ALIGN=CENTER NOWRAP>
$fnt1<FONT COLOR=$c1>&nbsp;del&nbsp;</FONT></TD><TD ALIGN=RIGHT NOWRAP>
$fnt1<FONT COLOR=$c1>&nbsp;size&nbsp;&nbsp;</FONT></TD><TD COLSPAN=2 ALIGN=CENTER NOWRAP>
$fnt1<FONT COLOR=$c1>&nbsp;date modified&nbsp;</FONT></TD><TD NOWRAP>$fnt1<FONT COLOR=$c1>&nbsp;permissions</FONT></TD></TR>
$filedata
</TABLE></TD></TR><TR ALIGN=RIGHT><TD>$preferences</TD></TR>
</TABLE></TD></TR></TABLE></TD><TD WIDTH=100% BGCOLOR=$c5>$fnt
<FONT COLOR=$c7>
$form

<TABLE BGCOLOR=$c1 CELLPADDING=1 CELLSPACING=0 BORDER=0><TR ALIGN=CENTER VALIGN=MIDDLE><TD COLSPAN=2><FONT SIZE=3 COLOR=$c7 FACE="$face"><B>$title</B><BR>
<TABLE BGCOLOR=$c4 CELLPADDING=2 CELLSPACING=0 BORDER=0>
@error
</TABLE></TD></TR><TR VALIGN=TOP><TD BGCOLOR=$c5 NOWRAP>$fnt1w<A HREF="$ENV{SCRIPT_NAME}?uk=$t{'uk'}&tz=$t{'tz'}&dispath=$t{'dispath'}" onMouseOver="window.status='click here to go to the instruction page'; return true;" onMouseOut="window.status=''; return true;" TITLE="click here to go to the instruction page now" STYLE="color:$c7">instructions</A></FONT></TD>
<TD BGCOLOR=$c5 ALIGN=RIGHT NOWRAP>$fnt1<FONT COLOR=$c7>by <A HREF="http://www.CraigRichards.com/" onMouseOver="window.status='click here to go to Craig Richards Design'; return true;" onMouseOut="window.status=''; return true;" TITLE="click here to go to Craig&nbsp;Richards Design now" STYLE="color:$c7">Craig&nbsp;Richards&nbsp;Design</A></FONT></TD></TR></TABLE></TD></TR></TABLE></CENTER><BR>
$foot

Print_Result
}

##########
# CONVERT INPUT

sub transParse {
$upload++;
use CGI;
my $req=new CGI;
$t{'path'}=$req->param("path");
$t{'path'} =~ s/\/+/\//g;
$t{'adminpro'}=$req->param("adminpro");
$t{'uk'}=$req->param("uk");
$t{'tz'}=$req->param("tz");
$t{'dispath'}=$req->param("dispath");
$t{'run'}=$req->param("run");
$t{'newfile'}=$req->param("newfile");
$t{'newdir'}=$req->param("newdir");
}


##########
# WRITE UPLOADED FILE

sub write_file {
 my $req=new CGI;
 $newfile=$req->param("newfile");
 if ($newfile) {
  $filename=$newfile; 
  $filename =~ s!^.*(\\|\/)!!;
  open (FILE,">$path$filename");
  binmode FILE;
  while (my $byteorder=read($newfile,my $buff,1024)) { 
  $size += $byteorder;
  $buff =~ s/[\r\n]/\n/g unless ($req->param("image"));
   print FILE $buff;
  }
 close (FILE);
 }
 if (!$newfile) {push(@error,"<TR><TD COLSPAN=2>$fnt You did not select a file to upload.</TD></TR>\n\n");
 $title="Upload Failed";
 }
 elsif (-e "$path$filename") {push(@error,"<TR><TD COLSPAN=2>$fnt The file \"<B>$newfile</B>\" <NOBR>($size bytes)</NOBR> was successfully uploaded.</TD></TR>\n\n");
 $title="$newfile Successfully Uploaded";
 }
 else {push(@error,"<TR><TD COLSPAN=2>$fnt The file \"<B>$newfile</B>\" could not be uploaded.</TD></TR>\n\n");
 $title="$newfile Upload Failed";
 }
}

##########
# CHMOD

sub chmod {

 if ($t{'chmod'}) {
 @filestat=stat("$path$t{'test'}");
  if (!$filestat[2]) {@filestat=lstat("$path$t{'test'}");}
   $permset=sprintf("%.0o",$filestat[2]);
   $permset =~ s/.*(.{3})$/$1/;
  if ($t{'chmod'} != $permset || $t{'chmod'}==0) {
  print `chmod $t{'chmod'} $path$t{'test'}`;
  push(@error,"<TR><TD COLSPAN=2>$fnt Permissions for <B>$t{'test'}</B> were successfully changed to $t{'chmod'}.</TD></TR>\n\n"); $title="Permissions Successfully Changed";
  }
 else {undef($t{'chmod'});}
 }
}

##########
# COMPOSE THE FORM

sub form {

$ckstyl=" STYLE=\"color:$c7;background-color:$c2;\"";
$set=<<"PermTable";
<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0>
<TR ALIGN=CENTER><TD ROWSPAN=2 ALIGN=RIGHT VALIGN=BOTTOM>$fnt1w Owner</TD><TD TITLE="Readable" STYLE="cursor:hand;">$fnt1w R</TD><TD TITLE="Writable" STYLE="cursor:hand;">$fnt1w W</TD><TD TITLE="Executable" STYLE="cursor:hand;">$fnt1w X</TD><TD>$fnt1 &nbsp;</TD></TR>
<TR ALIGN=CENTER><TD><INPUT TYPE=CHECKBOX NAME="aa" onClick="calcperm();"$ckstyl></TD><TD><INPUT TYPE=CHECKBOX NAME="ab" onClick="calcperm();"$ckstyl></TD><TD><INPUT TYPE=CHECKBOX NAME="ac" onClick="calcperm();"$ckstyl></TD><TD>$fnt1w Permissions</TD></TR>
<TR ALIGN=CENTER><TD ALIGN=RIGHT>$fnt1w Group</TD><TD><INPUT TYPE=CHECKBOX NAME="ba" onClick="calcperm();"$ckstyl></TD><TD><INPUT TYPE=CHECKBOX NAME="bb" onClick="calcperm();"$ckstyl></TD><TD><INPUT TYPE=CHECKBOX NAME="bc" onClick="calcperm();"$ckstyl></TD><TD ROWSPAN=2 VALIGN=TOP><INPUT TYPE=TEXT NAME="chmod" SIZE=4 MAXLENGTH=3 onFocus="window.status='edit this permissions value by checking the boxes to the left'; return true;" onBlur="setperms(); window.status=''; return true;" STYLE="font-size:10pt;" TITLE="edit this permissions value by checking the boxes to the left"></TD></TR>
<TR ALIGN=CENTER><TD ALIGN=RIGHT>$fnt1w Everyone</TD><TD><INPUT TYPE=CHECKBOX NAME="ca" onClick="calcperm();"$ckstyl></TD><TD><INPUT TYPE=CHECKBOX NAME="cb" onClick="calcperm();"$ckstyl></TD><TD><INPUT TYPE=CHECKBOX NAME="cc" onClick="calcperm();"$ckstyl></TD></TR></TABLE>

PermTable

if ($dispath>0) {$setpath=" <NOBR>path&nbsp;<INPUT TYPE=TEXT NAME=\"path\" SIZE=47 MAXLENGTH=200 VALUE=\"$path\" onFocus=\"window.status='type the to the directory to which you want to navigate'; return true;\" onBlur=\"window.status=''; return true;\" TITLE=\"type the path to which you want to navigate\">&nbsp;</NOBR><BR>\n";}

undef($set) if ($disablechmod);
$form=<<"Form";

$fnt1w
$set$setpath\n<NOBR>item&nbsp;<INPUT TYPE=TEXT NAME="test" SIZE=25 MAXLENGTH=200 VALUE="$t{'test'}" onFocus="window.status='type the name of the item you want to test or modify permissions'; return true;" onBlur="window.status=''; return true;" TITLE="type the name of the file you want to test or modify permissions">&nbsp;</NOBR> 

<NOBR><INPUT TYPE=CHECKBOX NAME="syntax" onMouseOver=\"window.status='check here to test the syntax of the file'; return true;\" onMouseOut=\"window.status=''; return true;\" TITLE="check here to test the syntax of the file"$ckstyl CHECKED>test&nbsp;

<INPUT TYPE=SUBMIT NAME="run" VALUE="execute" onMouseOver=\"window.status='click this button to execute the action'; return true;\" TITLE="click here to execute the action" STYLE="color:$c7;background-color:$c1;border:1;cursor:hand;"></NOBR><BR></FORM></FONT>

Form

$preferences=<<"Preferences";

<FORM NAME="adminpro" ACTION="$t{'adminpro'}" METHOD=GET>
$hidden<TABLE BGCOLOR=$c3a WIDTH=100% CELLPADDING=0 CELLSPACING=0 BORDER=0><TR ALIGN=CENTER><TD BGCOLOR=$c1 COLSPAN=8 NOWRAP TITLE="changes made here are for this session only and do not modify the preference defaults set in the script" STYLE="cursor:hand;"><NOBR>$fnt1w session preferences</TD></TR>

<TR ALIGN=CENTER VALIGN=BOTTOM><TD WIDTH=40% NOWRAP><NOBR>$fnt1 edit path</NOBR></TD> 
<TD WIDTH=40% NOWRAP><NOBR>$fnt1 adjust time display</NOBR></TD> 
<TD COLSPAN=4 NOWRAP><NOBR>$fnt1 date format</NOBR></TD><TD WIDTH=20% ROWSPAN=2>&nbsp;</TD></TR>

<TR ALIGN=CENTER VALIGN=MIDDLE><TD>$fnt1 <INPUT TYPE=CHECKBOX NAME="dispath" VALUE="1"$dispathck onMouseOver=\"window.status='check here show or hide the \\'manual path edit\\' field at the top of the form then click execute'; return true;\" onMouseOut=\"window.status=''; return true;\" TITLE="click here to show or hide the 'manual path edit' field at the top of the form then click 'execute'"></TD> 

<TD>$fnt1 <INPUT TYPE=TEXT NAME="tz" SIZE=3 MAXLENGTH=3 VALUE="$t{'tz'}" onMouseOver=\"window.status='adjust for difference between local and server timezones, then click execute'; return true;\" onMouseOut=\"window.status=''; return true;\" TITLE="adjust for the difference (in hours) between local and server timezones (does not change actual server timestamps), then click execute" STYLE="font-size:10pt;color:$c7;background-color:$c2;">hours</TD> 

<TD>$fnt1<INPUT TYPE=RADIO NAME="uk" VALUE="0"$usck TITLE="check here to display in the 'mo/da/year' date format then click execute"></TD><TD>$fnt1 us&nbsp;</TD>
<TD>$fnt1<INPUT TYPE=RADIO NAME="uk" VALUE="1"$ukck TITLE="check here to display in the 'da/mo/year' date format then click execute"></TD><TD>$fnt1 uk
</TD></TR></TABLE>

Preferences

$head=<<"Head";

<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><TR VALIGN=BOTTOM><TD NOWRAP><NOBR>$fnt1 &nbsp;access is $secflag<BR>
 &nbsp;user IP: $ENV{REMOTE_ADDR}
</NOBR></TD><TD WIDTH=100% ALIGN=CENTER NOWRAP><NOBR>$fnt1<A HREF="http://www.CraigRichards.com/software/?v=$v" onMouseOver="window.status='click here to check for an update'; return true;" onMouseOut="window.status=''; return true;" TITLE="click here to check for an update"><IMG SRC="http://www.CraigRichards.com/images/adminpro-0103.gif" WIDTH=96 HEIGHT=31 ALIGN=MIDDLE BORDER=0 ALT="AdminPro"></A> $version</NOBR></TD><TD ALIGN=RIGHT>$fnt1<FONT COLOR=808080><NOBR>&copy; Copyright 2000 Craig Richards Design.&nbsp;</NOBR> <NOBR>All rights reserved worldwide.&nbsp;
</NOBR></FONT></TD></TR></TABLE>

$fnt

Head

$foot="</FONT></BODY></HTML>\n";

}

##########
# SUB REPORT FILES IN DIRECTORY

sub viewDir {

if (-e "$cgirootpath"."f16x13.gif") {$fol="<IMG SRC=\"$cgipath"."f16x13.gif\" WIDTH=16 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"folder\" BORDER=0>";}
else {$fol="<IMG SRC=\"http://www.craigrichards.com/images/f16x13.gif\" WIDTH=16 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"folder\" BORDER=0>";}

if (-e "$cgirootpath"."f11x13.gif") {$doc="<IMG SRC=\"$cgipath"."f11x13.gif\" WIDTH=11 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"file\" BORDER=0>";}
else {$doc="<IMG SRC=\"http://www.craigrichards.com/images/f11x13.gif\" WIDTH=11 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"file\" BORDER=0>";}

if (-e "$cgirootpath"."i11x13.gif") {$img="<IMG SRC=\"$cgipath"."i11x13.gif\" WIDTH=11 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"image\" BORDER=0>";}
else {$img="<IMG SRC=\"http://www.craigrichards.com/images/i11x13.gif\" WIDTH=11 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"image\" BORDER=0>";}

if (-e "$cgirootpath"."t9x13.gif") {$tra="<IMG SRC=\"$cgipath"."t9x13.gif\" WIDTH=9 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"delete\" BORDER=0>";}
else {$tra="<IMG SRC=\"http://www.craigrichards.com/images/t9x13.gif\" WIDTH=9 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"delete\" BORDER=0>";}

$trdexp="cannot delete this item";
if (-e "$cgirootpath"."td9x13.gif") {$trd="<IMG SRC=\"$cgipath"."td9x13.gif\" WIDTH=9 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"delete\" BORDER=0 TITLE=\"$trdexp\">";}
else {$trd="<IMG SRC=\"http://www.craigrichards.com/images/td9x13.gif\" WIDTH=9 HEIGHT=13 ALIGN=ABSMIDDLE ALT=\"delete\" BORDER=0 TITLE=\"$trdexp\">";}

$return="<TR VALIGN=TOP><TD COLSPAN=6 NOWRAP>$fnt &#60;<A HREF=\"$t{'adminpro'}?adminpro =$t{'adminpro'}&path=/&run=yes\" onMouseOver=\"window.status='navigate to the root directory'; return true;\" onMouseOut=\"window.status=''; return true;\" TITLE=\"click here to navigate to the root directory\">..</A>";

 if (length($path)>1) {
  $path.="/";
  $path =~ s/\/+/\//g;
  @dirs=split(/\//,$path);
  $curdir=pop(@dirs);
   foreach $dir(@dirs) {
   $w.="/$dir"; $w =~ s/\/+/\//g;
    if (length($w)>1) {$return .= "/<A HREF=\"$t{'adminpro'}?uk=$t{'uk'}&tz=$t{'tz'}&dispath=$t{'dispath'}&adminpro=$t{'adminpro'}&path=$w&run=yes\" onMouseOver=\"window.status='navigate to the \\'$dir\\' directory'; return true;\" onMouseOut=\"window.status=''; return true;\" TITLE=\"click here to navigate to the '$dir' directory\">$dir</A>";
   }
  }
 }
 if ($curdir) {$return .= "/$curdir"; $return .= "/$fnt1<BR>&nbsp;
</FONT></FONT></TD></TR>\n\n";}
 else {$curdir="root"; undef($return);}

 opendir (DIR,"$path");
 @allfiles = grep(!/^\.\.?$/, readdir(DIR));
 push(@allfiles,(readlink(DIR))) unless (!(readlink(DIR)));
 foreach $file(@allfiles) {
  $alf="<!- ".lc($file)." ->";
 $a="A";
 @filestats=stat("$path$file");
  if (!$filestats[2]) {@filestats=lstat("$path$file");
    $i="<I>"; $l=" <FONT COLOR=909090>(link)</FONT>";}
 $size=sprintf("%.1f",($filestats[7])/1024);
  if ($size<1) {$size="$filestats[7] b";}
   else {$size.=" k";}
 $datemod=$filestats[9]; &date;
 $fileperm=sprintf("%.0o",$filestats[2]);
 $fileperm =~ s/.*(.{3})$/$1/;
  if (!$filestats[2]) {$fileperm="<FONT COLOR=808080>n/a</FONT>"; $a="! A"; $dis++;}

if (!$disablechmod) {
$set0=" document.adminpro.chmod.value=0; setperms();";
$set1=" document.adminpro.chmod.value=$fileperm; setperms();";
}
 # if it's a directory
 if ((-d "$file") || ($filestats[2] =~ /^(16|17|41)/)) {
   opendir (SUB,"$path$file");
    @subfiles=grep(!/^\.\.?$/, readdir(SUB));
    push(@subfiles,(readlink(SUB))) unless (!(readlink(SUB)));
   closedir (SUB);
 $deldir="$trd";
 $deldir="<A HREF=\"$t{'adminpro'}"."?uk=$t{'uk'}&tz=$t{'tz'}&dispath=$t{'dispath'}&adminpro=$t{'adminpro'}&path=$path&test=$file&remove=yes&run=yes\" onMouseOver=\"window.status='click here to permantently delete \\'$file\\''; return true;\" onMouseOut=\"window.status=''; return true;\" onClick=\"return verify('$file');\" TITLE=\"click here to permanently delete '$file'\">$tra</A>" if (!@subfiles);

push (@dlist,"$alf<TR VALIGN=TOP><TD NOWRAP>$fnt1$i<A HREF=\"$t{'adminpro'}"."?uk=$t{'uk'}&tz=$t{'tz'}&dispath=$t{'dispath'}&adminpro=$t{'adminpro'}&path=$path$file/&run=yes\" onMouseOver=\"window.status='click here to open the \\'$file\\' directory'; return true;\" onMouseOut=\"window.status=''; return true;\" TITLE=\"click here to open the '$file' directory\">$fol$file</A>$l&nbsp;</TD><TD ALIGN=CENTER NOWRAP>$deldir</TD><TD>$fnt1&nbsp;</TD>$filelastmod<TD ALIGN=CENTER NOWRAP>$fnt1$i<$a HREF=\"#\" onMouseOver=\"window.status='click here to change the permissions for \\'$file\\''; return true;\" onMouseOut=\"window.status=''; return true;\" onClick=\"document.adminpro.test.value='$file'; document.adminpro.syntax.checked=0;$set1 return false;\" TITLE=\"click here to change the permissions for '$file'\">$fileperm</A></TD></TR>\n");}

 # if it's not a directory
 else {$a="A"; $tr=$tra;
 if ($ENV{SCRIPT_NAME} =~ /$file/) {$a="! A"; $tr=$trd;}
 if ($file =~ /\.(gif|jp*g|png|ico)$/i) {$ficon=$img;}
 else {$ficon=$doc;}
push (@flist,"$alf<TR VALIGN=TOP><TD NOWRAP>$fnt1$i<$a HREF=\"$t{'adminpro'}"."?uk=$t{'uk'}&tz=$t{'tz'}&dispath=$t{'dispath'}&adminpro=$t{'adminpro'}&path=$path&test=$file&run=yes\" onMouseOver=\"window.status='click here to test \\'$file\\''; return true;\" onMouseOut=\"window.status=''; return true;\" onClick=\"document.adminpro.test.value='$file'; document.adminpro.syntax.checked=1;$set1 return false;\" TITLE=\"click here to test '$file' then click execute\">$ficon$file</A>$l&nbsp;</TD><TD ALIGN=CENTER NOWRAP><$a HREF=\"$t{'adminpro'}"."?uk=$t{'uk'}&tz=$t{'tz'}&dispath=$t{'dispath'}&adminpro=$t{'adminpro'}&path=$path&test=$file&delete=yes&run=yes\" onMouseOver=\"window.status='click here to permantently delete \\'$file\\''; return true;\" onMouseOut=\"window.status=''; return true;\" onClick=\"return verify('$file');\" TITLE=\"click here to permanently delete '$file'\">$tr</A></TD><TD ALIGN=RIGHT NOWRAP>$i$fnt1$size</TD>\n$filelastmod\n<TD ALIGN=CENTER NOWRAP>$fnt1$i<$a HREF=\"#\" onMouseOver=\"window.status='click here to change the permissions for \\'$file\\''; return true;\" onMouseOut=\"window.status=''; return true;\" onClick=\"document.adminpro.test.value='$file'; document.adminpro.syntax.checked=0;$set1 return false;\" TITLE=\"click here to change the permissions for '$file'\">$fileperm</A></TD></TR>\n");}

undef($i); undef($l);
 }
closedir (DIR);

$hidden="<INPUT TYPE=HIDDEN NAME=\"adminpro\" VALUE=\"$t{'adminpro'}\"><INPUT TYPE=HIDDEN NAME=\"path\" VALUE=\"$path\">\n<INPUT TYPE=HIDDEN NAME=\"run\" VALUE=\"execute\">\n<INPUT TYPE=HIDDEN NAME=\"newdir\">\n<INPUT TYPE=HIDDEN NAME=\"tz\" VALUE=\"$t{'tz'}\">\n<INPUT TYPE=HIDDEN NAME=\"uk\" VALUE=\"$t{'uk'}\">\n<INPUT TYPE=HIDDEN NAME=\"dispath\" VALUE=\"$t{'dispath'}\">\n";

$newdir="<TR><TD COLSPAN=5 NOWRAP><NOBR><FORM NAME=\"dirform\" ACTION=\"$t{'adminpro'}\" METHOD=GET>$hidden$fnt1$fol<INPUT TYPE=TEXT NAME=\"newdir\" SIZE=18 STYLE=\"font-size:9pt;\" onFocus=\"window.status='type the name of the new directory to create'; document.adminpro.test.value=this.value; document.adminpro.syntax.checked=0;$set0 return false;\" onKeyUp=\"document.adminpro.test.value=this.value; document.adminpro.newdir.value=this.value; return false;\" TITLE=\"type the name of the new directory to create\"></NOBR></TD><TD>$fnt1</FORM></TD></TR>\n\n";

$newfil="<TR><TD COLSPAN=5 NOWRAP><NOBR><FORM NAME=\"filform\" ACTION=\"$t{'adminpro'}\" METHOD=POST ENCTYPE=\"multipart/form-data\">$hidden$fnt1$doc<INPUT TYPE=FILE NAME=\"newfile\" SIZE=12 MAXLENGTH=80 STYLE=\"font-size:9pt;cursor:hand;\" onMouseOver=\"window.status='click this button to get the file then click \\'upload\\''; return true;\" onMouseOut=\"window.status=''; return true;\" onClick=\"document.adminpro.syntax.checked=0;$set0 document.adminpro.test.value=''; return true;\" TITLE=\"click here to get the file then click 'upload'\"><INPUT TYPE=CHECKBOX NAME=\"image\" VALUE=\"yes\" onMouseOver=\"window.status='check here if the file you are uploading is not a text file'; return true;\" onMouseOut=\"window.status=''; return true;\" TITLE=\"check here if the file you are uploading is not a text file\">image&nbsp; <INPUT TYPE=SUBMIT NAME=\"run\" VALUE=\"upload\" onMouseOver=\"window.status='click this button to upload the file'; return true;\" TITLE=\"click here to upload the file\" STYLE=\"font-size:9pt;color:$c7;background-color:$c1;border:1;cursor:hand;\"></NOBR></TD><TD ALIGN=RIGHT NOWRAP><NOBR>
$fnt1<A HREF=\"#top\" onMouseOver=\"window.status='click here to return to the top of this page'; return true;\" onMouseOut=\"window.status=''; return true;\" onClick=\"document.adminpro.run.focus(); return true;\" TITLE=\"click here to return to the top of this page now\">top</A></FORM></NOBR></TD></TR>\n\n";

 $dcnt=@dlist; $fcnt=@flist;
 @dlist=sort(@dlist); # alpha sort directories
 @flist=sort(@flist); # alpha sort files
 if ($dcnt<1) {
$directorydata="$newdir<TR><TD COLSPAN=6>$fnt1 &nbsp;</TD></TR>\n\n";
 } else {
 $d1=1; push(@dlist,$newdir);
   foreach $dlist(@dlist) {
    if ($d1==1) {$alt1=" BGCOLOR=$c3a"; $d1--;}
    else {undef($alt1); $d1++;}
   $dlist =~ s/<TR/<TR$alt1/g;
   $directorydata .= $dlist;
   }
$directorydata .= "<TR><TD COLSPAN=6>$fnt1 &nbsp;</TD></TR>\n\n";
   }
 if ($fcnt<1) {$filedata="$newfil";
 } else {$f1=1; push(@flist,$newfil);
   foreach $flist(@flist) {
    if ($f1==1) {$alt2=" BGCOLOR=$c3a"; $f1--;}
    else {undef($alt2); $f1++;}
   $flist =~ s/<TR/<TR$alt2/g;
   $filedata .= $flist;}
   }
 if ($dcnt==1) {$dhd="$dcnt directory";}
  else {$dhd="$dcnt directories";}
 if ($fcnt==1) {$fhd="$fcnt file";}
  else {$fhd="$fcnt files";}

 $tot=($dcnt+$fcnt);
 if ($dis == $tot) {
$disablechmod=" ";
# $disablechmod=" document.adminpro.chmod.disabled=1;";
}
 $item="$tot items";
 $item="$tot item" if ($tot==1);
}


##########
# COMPUTE THE DATE

sub date {
 $datemod=$datemod+($tz*3600);
 ($se,$mn,$ho,$da,$mo,$yr)=localtime($datemod);
 $mo=($mo+1); $yr=($yr+1900);
  if ($ho>=12) {$ampm="pm";} else {$ampm="am";}
  if ($ho<1) {$ho=12;}
  if ($ho>=13) {$ho=($ho-12);}
 $mo=sprintf("%02.0f",$mo);
 $ho=sprintf("%02.0f",$ho);
 $mn=sprintf("%02.0f",$mn);
 $se=sprintf("%02.0f",$se);
 $hourmin="$ho:"."$mn:$se"."&nbsp;$ampm";
 $da=sprintf("%02.0f",$da);

 $moda="$mo-$da";
  if ($uk>0) {$moda="$da-$mo";}

 $filelastmod="<TD NOWRAP>$fnt1$i &nbsp; $moda-$yr</TD><TD NOWRAP>$fnt1$i &nbsp; $hourmin</TD>";

}

##########
# SUB PARSE

sub inParse {
	binmode(STDIN);
	binmode(STDOUT);
	binmode(STDERR);

 $method=$ENV{REQUEST_METHOD};
 if ($method =~ /get/i) {
 $buffer=$ENV{QUERY_STRING};
 } elsif ($method =~ /post/i) {
  read (STDIN, $buffer, $ENV{CONTENT_LENGTH});
 } 

##########
# SPLIT THE NAME/VALUE PAIRS

 @pairs=split(/&/, $buffer);
 foreach $pair(@pairs) {
  ($name, $value)=split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $value =~ s/(\n+|\r+|\s+)/ /g;
  $value =~ s/’|Õ|Ô|\`/'/g;
  $value =~ s/(\*|\!|\+|\$|\^|\#|\%)//g;
  $value =~ s/\?/%3F/g;
  $t{$name} = $value;
 }
}

##########
# SUB INSTRUCTION COPY BLOCK

sub instblock {

 $title="How To Use AdminPro";
 $instructions=<<"Inst";

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 &nbsp;</TD><TD>$fnt1 <FONT SIZE=2 COLOR=$c1><B>Navigation</B></FONT><BR>
Click down into the paths in the directory table (left) or backward up the path tree from the links at the top of the directory table.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 &nbsp;</TD><TD>$fnt1 <FONT SIZE=2 COLOR=$c1><B>Test a Script's Syntax</B></FONT><BR>
Click on the file name in the directory table (left), check the "test" checkbox (above) and click execute.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 or</TD><TD>$fnt1 Type the script name in the "item" field (above), check the "test" checkbox and click execute.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 &nbsp;</TD><TD>$fnt1 <FONT SIZE=2 COLOR=$c1><B>Create a Directory</B></FONT><BR>
Click on the empty "folder" field in the directory table (left), type the new directory name, check the desired permissions from the permissions grid (above &#150; if&nbsp;desired) and click execute.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 &nbsp;</TD><TD>$fnt1 <FONT SIZE=2 COLOR=$c1><B>Upload a File</B></FONT><BR>
Click the "Browse..." button in the table (left), select a file from your local system, check the "image" checkbox (if it's not a text file) and click upload.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 &nbsp;</TD><TD>$fnt1 <FONT SIZE=2 COLOR=$c1><B>Delete an Item</B></FONT><BR>
Click an item's trash icon in the directory table (left). A&nbsp;popup window may prompt you to confirm the deletion. Click Cancel to change your mind or <NOBR>click OK</NOBR> to permanently remove the item from the server.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 &nbsp;</TD><TD>$fnt1 <FONT SIZE=2 COLOR=$c1><B>Change an Item's Permissions</B></FONT><BR> Click on the link in the item's current permissions column in the directory table (left), check the desired boxes in the permissions grid (above) and click execute.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 or</TD><TD>$fnt1 Type the item's name in the "item" field (above), check the desired boxes in the permissions grid and click execute.</TD></TR>

<TR VALIGN=TOP><TD ALIGN=RIGHT>$fnt1 &nbsp;</TD><TD>$fnt1 Note: Simultaneously modify a CGI script's permissions and test its syntax by following the instructions for modifying permissions except check the "test" checkbox.</TD></TR>

Inst
push(@error,"$instructions");
}

1;
exit;
