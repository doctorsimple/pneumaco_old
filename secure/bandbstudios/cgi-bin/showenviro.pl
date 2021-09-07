#!/usr/bin/perl
print "Content-type: text/html\n\n";
print "Balls out";
read (STDIN,$stuff,$ENV{"CONTENT_LENGTH"});
print "$stuff <br>";
while (($key,$value) = each(%ENV))
{print "$key equals $value<br>"}
