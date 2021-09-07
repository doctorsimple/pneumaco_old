#!/usr/local/bin/perl 
#
#Set up variables
#I can add blank lines to scratchpad to correct for missing stuff
$i=0;
 print "Content-type: text/html\n\n";
 print "<head></head><body>Here Tis<p>\n";
 open (STUFF, "scratchpad.html");
 local ($/)=undef;
 $thetext=<STUFF>;
 @thelist=split(/\n/,$thetext);
 foreach $line (@thelist)
 {
 $line =~ s/nnnn/$i+375/e;
 $i++;
 print "$line<br>";
 }
