#!/usr/local/bin/perl 
#
#Set up variables
require 'cookie.lib';
 print "Content-type: text/html\n\n";

 read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
 
        # Split the name-value pairs
        @pairs = split(/&/, $buffer);
		







