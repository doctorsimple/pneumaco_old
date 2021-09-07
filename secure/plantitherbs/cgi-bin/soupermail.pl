#!/bin/perl

my $relVersion = "1.0.7b9";

############################################################################
# Soupermail
#
# Internal build version:
# $Id: soupermail.pl,v 1.69 2000/01/23 22:28:22 root Exp root $
#
# Soupermail. A whacky and powerful WWW to Email form handler.
# Copyright (C) 1998, 1999, 2000 
#               Vittal Aithal <vittal.aithal@bigfoot.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See 
# the GNU General Public License for more details. You should have received 
# a copy of the GNU General Public License along with this program; if not,
# write to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, 
# MA 02139, USA.
#
############################################################################

############################################################################
# Set up the modules soupermail uses - these should all be perl5 standard
############################################################################
use CGI;
use FileHandle;
use File::Copy;
use IPC::Open3;
use Time::Local;
use strict;
use 5.003;

# Not all systems will have Net::SMTP, so eval to handle this.. is this the
# best way?
eval('use Net::SMTP;');

BEGIN {
	if ($^O =~ /MSWin/i) {
		require Win32::File;
		import Win32::File;
	}
}


############################################################################
my ($soupermailAdmin, $serverRoot, $mailprog, $mailhost, $pgpencrypt,
    $tempDir, $debug, $extraMailOpts, $gs, $lout, $gsDirs, $loutOpts,
	$gsOpts, $forkable, $fhBug) = "";
############################################################################

############################################################################
# ---CHANGE ME FOR YOUR SITE---
# This is who to mail when soupermail goes wrong
############################################################################
$soupermailAdmin = 'design@frognet.net';

############################################################################
# ---CHANGE ME FOR YOUR SITE---
# This is where the webserver's document tree starts
# Do NOT include a trailing '/' character
############################################################################
#$serverRoot = 'c:/inetpub/wwwroot';
#$serverRoot = $ENV{'DOCUMENT_ROOT'};          # May work on some webservers
#$serverRoot = '/opt/apache/share/devcontent';
$serverRoot = '/usr/local/www/net/frognet/html/plantitherbs';

############################################################################
# Program locations. These will vary from site to site, so check that
# they're there and setup as appropriate
############################################################################

############################################################################
# ---CHANGE ME FOR YOUR SITE---
# To send outgoing mail, soupermail needs an SMTP mailserver to talk to.
# If you don't know the address of a suitable mailserver, ask your ISP
# or a system administrator. If you don't have a mailserver handy, but
# you do have sendmail (UNIX boxes only I think), you MUST leave mailhost
# blank (but not commented out) and set mailprog to the location of your
# sendmail program.
# I'll repeat that - either sendmail or mailhost - NOT BOTH.
############################################################################
$mailhost = '';
$mailprog = '/usr/sbin/sendmail';

#$mailhost = 'localhost';
#$mailprog = '';

############################################################################
# ---CHANGE ME FOR YOUR SITE---
# The program to do pgp encryption. This was tested with PGP 5.0i 
# and GNU Privacy Guard 1.0.0 on my home Linux box, your milage 
# may vary with others.
# Experimental support for GPG under Windows NT is provided
# Values could be /usr/local/bin/pgpe (PGP *nix)
# or /usr/local/bin/gpg (GNUPG *nix)
# or c:/gpg/gpg.exe (GNUPG Windows)
############################################################################
#$pgpencrypt = '';                                      # No PGP/GPG
#$pgpencrypt = 'c:/gpg/gpg.exe';                        # GPG NT
#$pgpencrypt = 'c:/pgp5/pgpe.exe';                      # PGP NT
$pgpencrypt = '/usr/bin/pgpe';							# PGP *nix
#$pgpencrypt = '/usr/local/bin/gpg';                    # GPG *nix

############################################################################
# ---CHANGE ME FOR YOUR SITE---
# These are the programs needed to generate PDFs
# $gs is the location of ghostscript
# $gsDirs is a comma separated set of paths containing ghostscript fonts
# and suchlike.
# $lout is the location of lout
# Comment them out if they're not used
############################################################################
$gs = '/usr/bin/gs';
$gsDirs = '/usr/share/ghostscript/5.10/fonts,/usr/share/ghostscript/5.10';
#$lout = '/usr/local/bin/lout';

############################################################################
# ---CHANGE ME FOR YOUR SITE---
# Where to write out temporary files. If you're using PGP, or making
# PDFs, several files will be generated in a sudirectory off here. 
# Include a trailing '/' character.
############################################################################
#$tempDir = 'c:/temp/';
$tempDir = '/usr/local/www/net/frognet/html/plantitherbs/temp/';

############################################################################
# Uncomment this to see what soupermail's doing.
# On a production server make sure its commented out.
############################################################################
$debug = "${tempDir}soupermaillog";


############################################################################
# This is a fairly advanced setting you should only touch if:
#   *) You're using sendmail, or a sendmail-like stub program
#   *) Mail doesn't seem to be getting sent
#   *) You've read the FAQ
# It appears that versions of sendmail prior to 8.8.0 do not have the 
# -U command line flag (certainly I've had a report of it not being happy
# on an IRIX box). So here, you can set the extra mail options to blank
# by uncommenting the first line and commenting out the other line.
# Sendmail replacements like exim may need this changed too.
############################################################################
#$extraMailOpts = "";
$extraMailOpts = " -i -U";

############################################################################
# If your machine doesn't have fork() support, try setting this to 0
############################################################################
$forkable = 1;

############################################################################
# If you have trouble uploading files, try setting this to 1
# FreeBSD users may well need to do this
############################################################################
$fhBug = 0;

############################################################################
# This stuff is for PDF generation and is liable to change
############################################################################
$loutOpts = " -S";
$gsOpts = " -q -dNOPAUSE -dBATCH " . 
          ($gsDirs ? "-I" : "") .
          join(" -I", split(/,\s*/, $gsDirs)) .
          " -sDEVICE=pdfwrite -sOutputFile=";

############################################################################
# Right, that in theory is the end of anything you have to configure...
# the rest's generic... well, maybe :)
############################################################################



############################################################################
# Set up some global constants
############################################################################

############################################################################
# $maxbytes is the maximum number of bytes allowed to be uploaded.
# Its not very cleverly handled at the moment, but what can you do.
############################################################################
my ($maxbytes) = 102400;

############################################################################
# $maxdownload is the maximum number of bytes allowed to be downloaded.
############################################################################
my ($maxdownload) = 10240000;

############################################################################
# Useful month shortcuts
############################################################################
my (%MONTHS) = 
	('Jan','01','Feb','02','Mar','03','Apr','04','May','05','Jun','06',
	 'Jul','07','Aug','08','Sep','09','Oct','10','Nov','11','Dec','12');


############################################################################
# We may be generating cookies, and they'll live in @cookieList
# $cookieStr determines how many cookies we're allowing (3 by default)
############################################################################
my (@cookieList) = ();
my ($cookieStr) = 'cookie([123])';


############################################################################
# Other globals
############################################################################
my ($pageRoot, $config, %CONFIG, @required, @conditions, @condTypes, 
    @typeChecks);
my ($query, $child);
my $parent = $$;
my @ignored = ('SoupermailConf');
my $CRLF = "\015\012";


############################################################################
# Some default configuration values
############################################################################
my $today                = time;
$CONFIG{'expirydate'}    = $today;
$CONFIG{'subject'}       = 'Form Submission';
$CONFIG{'ref'}           = translateFormat('REF:%rrrrrr%');
$CONFIG{'successcookie'} = 1;
$CONFIG{'failurecookie'} = 0;
$CONFIG{'blankcookie'}   = 0;
$CONFIG{'expirescookie'} = 0;
$CONFIG{'cgiwrappers'}   = 0;
$CONFIG{'counter'}       = {};
$CONFIG{'charset'}       = 'iso-8859-1';
$CONFIG{'encoding'}      = 'quoted-printable';
$CONFIG{'pgpmime'}       = 1;

my %needToReplace = ();
### These are the config options that can use variable replacement
my $replaceable = "^(mailto|(sender)?replyto|${cookieStr}value|" .
                  '(sender)?subject|ref|fileto)';
my $scratchPad = "";
my $OS;
my $attachCount = 1;

if ($^O =~ /MSWin/i) {
	$OS = "windows";
} else {
	$OS = "unix";
}

### Just in case people didn't read the instructions :)                  ###
$serverRoot =~ s/[\/\\]$//;
### Concatenate dir breaks into single ones.                             ###
$serverRoot =~ s/[\/\\]+/\//g;

### Speed things up by interpreting only what we need                    ###

my $fileFunctions =<<'END_OF_FILE_FUNCTIONS';
############################################################################
# Subroutine: hideFile ( filename )
# Make an OS specific call to hide a file from the webserver
# makes the file hidden under windows, chmoded under unix
############################################################################
sub hideFile {
	($debug) && (print STDERR "hideFile (@_) \@ " . time . "\n");
	my $filename = shift;
	no strict 'subs';
	if ($OS eq "windows") {
		Win32::File::SetAttributes($filename, Win32::File::HIDDEN)
	} else {
		if ($CONFIG{"cgiwrappers"}) {
			chmod 0600, $filename;
		} else {
			chmod 0266, $filename;
		}
	}
}

############################################################################
# Subroutine: saveResults ()
# Save the results to a file called $fileto
############################################################################
sub saveResults {
	($debug) && (print STDERR "saveResults (@_) \@ " . time . "\n");
	my $outstring = "";
	my $outbuffer = "";
	my ($value, $tmpfile);
	if ($CONFIG{'filetemplate'}) {
		grabFile($CONFIG{'filetemplate'}, \$outbuffer);
		if ($CONFIG{'nofilecr'}) {
			substOutput(\$outbuffer, '2');
		} else {
			substOutput(\$outbuffer, '0');
		}
		$outbuffer =~ s/\cM?\n$//;
	} else {
		my (@keylist) = sort($query->param());
		my ($key);
		foreach $key (@keylist) {
			### Because we may be dealing with multiple values, need to  ###
			### join with a comma.                                       ###
			$value = join(',', $query->param($key));
			$value =~ s/\cM?\n/ /g if ($CONFIG{'nofilecr'});
			$outbuffer .= "$key = $value\n";
		}
	}
	my ($header, $footer, $fileto) = "";
	if ($CONFIG{'headings'}) {
		grabFile($CONFIG{'headings'}, \$header);
	}
	if ($CONFIG{'footings'}) {
		grabFile($CONFIG{'footings'}, \$footer);
	}
	showFile($CONFIG{'fileto'});

	if (-f $CONFIG{'fileto'}) {
		my @fileStats = stat($CONFIG{'fileto'});
		### Is the file going to be bigger than the maximum?             ###
		if ($CONFIG{'filemaxbytes'} && 
			($fileStats[7] + length($outbuffer)) > $CONFIG{'filemaxbytes'}) {
			### Yes, it is too big, but first see if it needs copying.   ###
			if ($CONFIG{'filebackupformat'}) {
				copy($CONFIG{'fileto'}, $CONFIG{'filebackupformat'});
				hideFile($CONFIG{'filebackupformat'}) 
					unless ($CONFIG{'filereadable'});
			}
			### Now delete it.                                           ###
			unlink $CONFIG{'fileto'};
		} else {
			grabFile($CONFIG{'fileto'}, \$fileto);
		}
	}

	$fileto = $header . $footer unless ($fileto);
	if ($CONFIG{'filepgpuserid'}) {
	    pgpMessage(\$outbuffer, $CONFIG{'filepgpuserid'});
	}

	open (FILETO, "> $CONFIG{fileto}") ||
		fatal("Failed to write data file <B>$CONFIG{fileto} </B>");
	if ($CONFIG{'fileattop'}) {
		### want to add new entries to top of file.                      ###
		print FILETO $header;
		print FILETO $outbuffer;
		print FILETO substr($fileto, length($header));
	} else {
		if ($footer) {
			print FILETO substr($fileto, 0, (-1 * length($footer)));
		} else {
			print FILETO $fileto;
		}
		print FILETO $outbuffer;
		print FILETO $footer;
	}
	close (FILETO);

	hideFile($CONFIG{'fileto'}) unless ($CONFIG{'filereadable'});
	return 1;
}

sub genFileto {
    $CONFIG{'fileto'} = makePath(translateFormat($CONFIG{'fileto'}));
	$CONFIG{'fileto'} =~ m!^(.*)/[^/]*$!;
	my $tmpFileName = $1;

	### We have to check to see if its writable, or at least the     ###
	### directory where it'll be created is writable. Also check     ###
	### the file's a read file and not a symlink.                    ###
	fatal ("Can not write to fileto of $CONFIG{fileto}") 
	    if ((-e $CONFIG{'fileto'} && ! -w $CONFIG{'fileto'}) ||
			(-e $CONFIG{'fileto'} && -l $CONFIG{'fileto'}) ||
			(! -e $CONFIG{'fileto'} && ! -w $tmpFileName));
}
END_OF_FILE_FUNCTIONS


my $templateFunctions =<<'END_OF_TEMPLATE_FUNCTIONS';
############################################################################
# Subroutine: getOutVals ( name, {attributes}, iscounter )
# Given a variable name and an assoc array of attributes, return a list
# of values with appropriate formatting. The value of iscounter is set by
# reference.
############################################################################
sub getOutVals {
    my @nameoutput = ();
	$_ = shift;
	my $at = shift;
	my $isCounter = shift;
	my %ATTRIBS = %$at;
	$debug && print STDERR "In getOutVals with $_\n";

	$ATTRIBS{'format'} = '%ddd% %mmmm% %dd% %yyyy%' if (/^http_date/ && 
						 !$ATTRIBS{'format'});
	$ATTRIBS{'format'} = '%hhhh%:%mm%:%ss%' if (/^http_time/ && 
						 !$ATTRIBS{'format'});
	$$isCounter = 0;

    if (/^http_[a-zA-Z_]+$/) {
        if (!/^http_(time|date|config_path)$/) {
            push(@nameoutput, getHttpValue($_)) if (getHttpValue($_));
        } else {
            if ($1 eq "config_path") {
                push(@nameoutput, "$pageRoot/");
            } else {
                push(@nameoutput, translateFormat($ATTRIBS{'format'}));
            }
        }
    } elsif (/^cookie_([\w\-]+)/) {
        push(@nameoutput, $query->cookie($1)) if ($query->cookie($1));
    } elsif (/^counter_(\d+)/i) {
        push(@nameoutput, $CONFIG{"counter"}->{"${1}value"})
            if ($CONFIG{"counter"}->{"${1}value"});
        $$isCounter = (!$CONFIG{"counter"}->{"${1}value"});
    } else {
        push(@nameoutput, $query->param($_));
    }
	if ($ATTRIBS{'format'} =~ /^\%(c+)\%$/) {
	    my $span = length($1);
		@nameoutput = map { s/\D//g; s/(\d{0,$span})/$1 /g; s/\s+$//s; $_; } 
		                  @nameoutput;
	}
	return @nameoutput;
}



############################################################################
# doMaths ( element_list, element_name, attributes )
# For every element in the list, perform the maths function specified in 
# the math attribute. Assume this is for the element named element_name
############################################################################
sub doMaths {
    my $list = shift;
	my $name = shift;
	my $at = shift;
	my $isCounter = 0;

	my $expr = $at->{'math'};
	$expr =~ s/\s//g;
	my $toEval = "";
	my $mathSyms = '\)\(\+\-\*\/';

	$debug && print STDERR "In doMath with $expr\n";

	while ($expr =~ /[sS][uU][mM]\(([^\)]+)\)/) {
	    my $var = $1;
	    my @vals = getOutVals($var, $at, \$isCounter);
		my $sum = 0;
		for (@vals) {
		    if (/^(\-?\d+|\-?\d+\.\d+)$/) {
			    $sum += $_;
			}
		}
		$expr =~ s/[sS][uU][mM]\($var\)/$sum/g;
	}

	while ($expr =~ /[cC][oO][uU][nN][tT]\(([^\)]+)\)/) {
	    my $var = $1;
	    my @vals = getOutVals($var, $at, \$isCounter);
		my $cnt = scalar(@vals);
		$expr =~ s/[cC][oO][uU][nN][tT]\($var\)/$cnt/g;
	}

	my @breakdown = split(/([^$mathSyms]+)/, $expr);
	$debug && print STDERR ("Breakdown = " . join(" | ", @breakdown) . "\n");
	for (@breakdown) {
	    if (/^([$mathSyms]+|\d+|\d+\.\d+)$/) {
		    $toEval .= $_;
		} elsif ($_ ne $name && $_) {
		    my @vals = getOutVals($_, $at, \$isCounter);
			if ($vals[0] && $vals[0] =~ /^(\-?\d+|\-?\d+\.\d+)$/) {
		        $toEval .= $vals[0];
			} elsif ($_) {
		        $toEval .= "0";
			}
		} elsif ($_) {
		    $toEval .= $name;
		}
	}

	$debug && print STDERR "to eval is $toEval\n";
    my $i = 0;
	while ($i < scalar(@$list)) {
	    my $thisEval = $toEval;
		my $rep = ($list->[$i] ? 
		    ($list->[$i] =~ /^(\-?\d+|\-?\d+\.\d+)$/ ? 
			    $list->[$i] : "1") : "0");
		$thisEval =~ s/$name/$list->[$i]/g;
		$thisEval =~ s/[^${mathSyms}\.\d]//g;
		$debug && print STDERR "Evaling $thisEval\n";
		my $r = eval($thisEval);
		if ($at->{'precision'} =~/^\d+$/) {
		    $r = sprintf("%." . $at->{'precision'} . "f", $r);
		}
		$list->[$i] = ($r ? $r : ($@ ? "NaN" : "0"));
		$i++;
	}
}

############################################################################
# Subroutine: dehtml ( [unescape], string )
# Change common HTML characters to special charaters optionally url
# unescaping if neccessary. 
############################################################################
sub dehtml { 
	my $arg1 = shift;
	my $arg2 = shift;
	$_ = ($arg1) ? URLunescape($arg2) : $arg2;
	s/\&/\&#38;/g; s/>/\&#62;/g; s/</\&#60;/g;
	s/\"/\&#34;/g; s/\'/\&#39;/g;
	return $_;
}


############################################################################
# Subroutine: URLescape ( string )
# Escape out characters in a string, and return the string. Pinched
# straight out of CGI.pm, but since its not exported explicitly I figure
# its best to copy it here.
############################################################################
sub URLescape {
	($debug) && (print STDERR "URLescape (@_) \@ " . time . "\n");
	my $toencode = shift;
	return undef unless defined($toencode);
	$toencode=~s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;
	return $toencode;
}


############################################################################
# Subroutine: URLunescape ( string )
# Takes a URL escaped string and unencodes it. Again pinched from CGI.pm
############################################################################
sub URLunescape {
	($debug) && (print STDERR "URLunescape (@_) \@ " . time . "\n");
	my $todecode = shift;
	return undef unless defined($todecode);
	$todecode =~ tr/+/ /;       # pluses become spaces
	$todecode =~ s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
	return $todecode;
}

############################################################################
# Subroutine: substOutput ( buffer_containing_output_tags,
#                            flag_to_specify_format )
# Substitute all instances of the output tag in a string
# returning the substituted string
# $format is '0' for no changes
#            '1' for output newlines as HTML <br> elements
#            '2' for remove all newlines, and replace with space characters.
############################################################################
sub substOutput {
	($debug) && (print STDERR "substOutput (@_) \@ " . time . "\n");
	my ($buffer, $format, $includes) = @_;
	my ($tempstring, $endstring, $outstring, $doLines) = "";
	$outstring = "";
	while ($$buffer =~ /(<output(\s+[^>\s]+?\s*=\s*('[^']*'|
							"[^\"]*"|[^\s>]+))+\s*>)/iox) {
		$$buffer = $';
		$endstring = $`;
		($tempstring, $doLines) = translateOutput($1);
		$tempstring =~ s/\n/<BR>/g if ($format == 1 && !$doLines);
		$tempstring =~ s/\cM?\n/ /g if ($format == 2);
		$tempstring = clean4Lout($tempstring) if ($format == 4);
		$outstring .= "$endstring$tempstring";
	}
	$$buffer = "$outstring$$buffer";
	$outstring = "";
	if ($format == 1 || $includes) {
		### CRAZZEEEE!!! do SSI type includes if its a HTML format type   ###
		### substitution.                                                 ###
		while ($$buffer =~ /<\!\-\-\#include\s+virtual\s*=\s*
							("([^"]+)"|'([^']+)'|(\S+))\s*-->/xi) {
			$$buffer = $';
			$endstring = $`;
			$tempstring = "";
			my $incFile = $2;
			$incFile = $3 if ($3);
			$incFile = $4 if ($4);
			($debug) && (print STDERR "including $incFile\n");
			$incFile = makePath($incFile);
			if (-f $incFile && -r $incFile &&
				-T $incFile) {
				grabFile($incFile, \$tempstring);
			}
			$outstring .= "$endstring$tempstring";
		}
	}
	$$buffer = $outstring . $$buffer;
}

############################################################################
# Subroutine: translateOutput ( output_tag_string )
# Take a tag in the form <output ...> and return the value based on
# %rqpairs. If no pair exists, return "".
############################################################################
sub translateOutput {
	($debug) && (print STDERR "translateOutput (@_) \@ " . time . "\n");
	my ($line) = shift;
	my ($name, $attrib, $tag, $nameoutput) = "";
	my (@nameoutput) = ();
	my (%ATTRIBS) = ();
	my (%SETATTRIBS) = ();
	my $isCounter = 0;
    my $newlineTrans = 0;
	my $matchVal = 1;
	my $matchData = 1;
	$ATTRIBS{'list'} = $ATTRIBS{'post'} = $ATTRIBS{'pre'} = $ATTRIBS{'case'} =
		$ATTRIBS{'name'} = $ATTRIBS{'sub'} = $ATTRIBS{'alt'} = 
		$ATTRIBS{'math'} = $ATTRIBS{'format'} = $ATTRIBS{'delim'} = 
		$ATTRIBS{'type'} = $ATTRIBS{'indent'} = $ATTRIBS{'newline'} = 
		$ATTRIBS{'altvar'} = $ATTRIBS{'subvar'} = $ATTRIBS{'charmap'} =
		$ATTRIBS{'value'} = $ATTRIBS{'valuevar'} = $ATTRIBS{'data'} = "";

	while ($line =~ /(\w+)\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)/) {
		print STDERR "Translating $line\n" if ($debug);
		$line = $';
		$attrib  = lc($1);
		$tag = $2;
		$tag =~ s/^'([^']*)'/$1/ unless ($tag =~ s/^"([^"]*)"/$1/);
		$ATTRIBS{$attrib} = $tag;
		$SETATTRIBS{$attrib} = 1;
	}
	$ATTRIBS{'name'} =~ s/^\s*([\S])/$1/;
	$ATTRIBS{'name'} =~ s/(.*[\S])\s*$/$1/;
	$_ = $ATTRIBS{'name'};
	securityName($_);

    @nameoutput = getOutVals($_, \%ATTRIBS, \$isCounter);

	### Firstly, it should be unescaped if needed.                       ###
    if ($ATTRIBS{'type'} =~ /^unescaped(html)?$/i) {
		@nameoutput = map { URLunescape($_); } @nameoutput;
    }

	if (scalar(@nameoutput) && $ATTRIBS{'subvar'} &&
	    (!$SETATTRIBS{'valuevar'} || $nameoutput[0] eq $ATTRIBS{'valuevar'})) {
	    securityName($ATTRIBS{'subvar'});
		$debug && print STDERR "subvar replace $_ with $ATTRIBS{'subvar'}\n";
	    $_ = $ATTRIBS{'subvar'};
		@nameoutput = getOutVals($_, \%ATTRIBS, \$isCounter); 
	} elsif ((!scalar(@nameoutput) || ($SETATTRIBS{'valuevar'} &&
	         $nameoutput[0] ne $ATTRIBS{'valuevar'})) && $ATTRIBS{'altvar'}) {
	    securityName($ATTRIBS{'altvar'});
		$debug && print STDERR "altvar replace $_ with $ATTRIBS{'altvar'}\n";
	    $_ = $ATTRIBS{'altvar'};
		@nameoutput = getOutVals($_, \%ATTRIBS, \$isCounter); 
	}
    if ($SETATTRIBS{'value'}) {
	    $matchVal = ($nameoutput[0] eq $ATTRIBS{'value'}) ? 1 : 0;
	}
    if ($SETATTRIBS{'data'} && scalar(@nameoutput)) {
	    $ATTRIBS{'data'} =~ s/^\s*(.*?)\s*$/\L$1\E/;
		$debug && print STDERR "data $nameoutput[0] as a $ATTRIBS{'data'}\n";
	    $matchData = !checkType($ATTRIBS{'data'},$nameoutput[0]);
		$debug && print STDERR "check results in $matchData\n";
	}

    ### We can now apply various transformations on the data.            ###
    ### Upper of lowercase                                               ###
	if ($ATTRIBS{'case'} =~ /^upper$/i) {
        @nameoutput = map { uc($_); } @nameoutput;
	} elsif ($ATTRIBS{'case'} =~ /^lower$/i) { 
        @nameoutput = map { lc($_); } @nameoutput;
	}
	
	### Map special character                                            ###
	if ($ATTRIBS{'charmap'} && $ATTRIBS{'charmap'} =~ m!(.)\,(.*)!) {
	    my $fromChar = $1;
		my $toStr = $2;
		$debug && print STDERR "Char mapping $fromChar to $toStr\n";
		@nameoutput = map { s/$fromChar/$toStr/gs;$_; } @nameoutput;
	}

    ### Perform maths functions                                          ###
	if ($ATTRIBS{'math'}) {
	    doMaths(\@nameoutput, $_, \%ATTRIBS);
	}

    if ($ATTRIBS{'type'} =~ /^escaped$/i) {
		@nameoutput = map { URLescape($_); } @nameoutput;
    } elsif ($ATTRIBS{'type'} =~ /^(unescaped)?html$/i) {
		@nameoutput = map { dehtml($1,$_); } @nameoutput;
    }

    if ($ATTRIBS{'newline'} =~ /^html$/i) {
        @nameoutput = map { s/(\r?\n)/<br>\n/gs;$_; } @nameoutput;
        $newlineTrans = 1;
    } elsif ($ATTRIBS{'newline'} =~ /^none$/i) {
        @nameoutput = map { s/(\r?\n)/ /gs;$_; } @nameoutput;
        $newlineTrans = 1;
    } elsif ($ATTRIBS{'newline'} =~ /^paragraphs$/i) {
        @nameoutput = map { s/(\r?\n){3,}/\n\n/gs;$_; } @nameoutput;
        @nameoutput = map { s/(\r?\n){1,1}/\n/gs;$_; } @nameoutput;
        $newlineTrans = 1;
    } elsif ($ATTRIBS{'newline'} =~ /^unchanged$/i) {
        $newlineTrans = 1;
    }
	
    if (@nameoutput || $nameoutput || $isCounter) {
        ### Now we have to be smart and handle multiple lists. Default   ###
        ### behavior is to display multiples as HTML UL lists, but can   ###
        ### be overridden by the list tag of OL, DIR or MENU.            ###
		if (!$SETATTRIBS{'sub'} && ($ATTRIBS{'list'} || scalar(@nameoutput) > 1 )) {
			if ($SETATTRIBS{'delim'}) {
				$nameoutput= join("$ATTRIBS{post}$ATTRIBS{delim}$ATTRIBS{pre}",
								  @nameoutput);
				return("$ATTRIBS{pre}$nameoutput$ATTRIBS{post}", $newlineTrans);
			} elsif ($ATTRIBS{'list'} =~ /TEXT/i) {
				### Plain text list.                                     ###
				$nameoutput = join("$ATTRIBS{post}\n    * $ATTRIBS{pre}",
									@nameoutput);
				return("\n    * $ATTRIBS{pre}$nameoutput$ATTRIBS{post}\n", 
                       $newlineTrans);
			} else {
				$ATTRIBS{'list'} = 'UL' unless ($ATTRIBS{'list'} ne "");
				$nameoutput = join ("$ATTRIBS{post}<LI>$ATTRIBS{pre}",
									@nameoutput);
               
				return("<$ATTRIBS{list}><LI>$ATTRIBS{pre}" .
						"$nameoutput$ATTRIBS{post}</$ATTRIBS{list}>", 
                        $newlineTrans);
			}
		} else {
			$nameoutput = $nameoutput[0] unless ($nameoutput);
			if ($SETATTRIBS{'sub'} && $matchVal && $matchData) {
				return($ATTRIBS{'sub'},0);
			} elsif ($matchVal && $matchData) {
				if ($SETATTRIBS{'indent'}) {
					$nameoutput =~ s/(\cM?\n)/$1$ATTRIBS{'indent'}/g ;
					$nameoutput = $ATTRIBS{'indent'} . 
									($isCounter ? '0' : $nameoutput);
					$isCounter = 0;
				}
				return("$ATTRIBS{pre}" .
						($isCounter ? '0' : $nameoutput) . "$ATTRIBS{post}",
                        $newlineTrans);
			} else {
		        return($ATTRIBS{'alt'},0);
            }
		}
	} else {
		return($ATTRIBS{'alt'},0);
	}
}

END_OF_TEMPLATE_FUNCTIONS


my $pdfFunctions =<<'END_OF_PDF_FUNCTIONS';
sub makePdf {
    my $template = shift;
	my $fname = "$scratchPad/" . shift;
	if ($gs && $lout && -d $scratchPad) {
	    open (LIN, ">${scratchPad}/lout.in");
        print LIN $$template;
        close (LIN);
		my $cmd1 = "$lout $loutOpts lout.in >lout.ps";
		my $cmd2 = "$gs ${gsOpts}${fname} lout.ps";
	    ($debug) && print STDERR "Running $cmd1 and $cmd2\n";
		chdir ($scratchPad);
		system("$cmd1");
		system("$cmd2");
	    if ($fname) {
		    return $fname;
		}
	}
	return "";
}


sub clean4Lout {
    my $val = shift;
    $val =~ s/[\t ]+/ /gs;
    $val =~ s/([\"\\])/\"\\$1\"/gs;
    $val =~ s/([\#\&\/\@\^\{\|\}\~])/\"$1\"/gs;
    $val =~ s/(\r?\n){2,}/\n\@LP\n/gs;
			 
    # Win latin stuff... can we check for this in form
    # enctype?
    $val =~ s/\x82/ \@Char quotesinglbase /gs;
    $val =~ s/\x83/ \@Florin /gs;
    $val =~ s/\x84/ \@Char quotedblbase /gs;
    $val =~ s/\x85/ \@Char ellipsis /gs;
    $val =~ s/\x86/ \@Dagger /gs;
    $val =~ s/\x87/ \@DaggerDbl /gs;
    $val =~ s/\x88/ \@Char circumflex /gs;
    $val =~ s/\x8a/ \@Char S /gs;
    $val =~ s/\x8c/ \@Char OE /gs;
    $val =~ s/\x91/ \@Char quoteleft /gs;
    $val =~ s/\x92/ \@Char quoteright /gs;
    $val =~ s/\x93/ \@Char quotedbl /gs;
    $val =~ s/\x94/ \@Char quotedbl /gs;
    $val =~ s/\x95/ \@Sym bullet /gs;
    $val =~ s/\x96/ \@Char endash /gs;
    $val =~ s/\x97/ \@Char emdash /gs;
    $val =~ s/\x99/ \@Sym trademarkserif /gs;
    $val =~ s/\x9c/ \@Char oe /gs;
    $val =~ s/\x9e/ \@Char z /gs;
    $val =~ s/\x9f/ \@Char Y /gs;
    return $val;
}
END_OF_PDF_FUNCTIONS


my $mailFunctions =<<'END_OF_MAIL_FUNCTIONS';
############################################################################
# Subroutine: makeHtmlMail ( message )
#
# Takes a message, and wraps it up in a HTML mime format.
############################################################################
sub makeHtmlMail {
    my $buffer = shift;
	$$buffer = "Content-Type: text/html; charset=$CONFIG{charset}\n" .
               "Content-Transfer-Encoding: $CONFIG{encoding}\n" .
			   "Content-Base: " . makeUrl() . "\n\n" .
			   "$$buffer\n\n";
}

############################################################################
# Subroutine: makeAltMail ( text_message, html_message )
#
# Takes a text and html message and generate a multipart/alternative
# message 
############################################################################
sub makeAltMail {
    my $txtBuffer = shift;
    my $htmlBuffer = shift;
	my $altBoundary = time() . "98237498345781235ijs728y5jhsdf";
	return("Content-Type: multipart/alternative; " .
		   "boundary=\"${altBoundary}\"\n" .
		   "\n--${altBoundary}\n" .
		   "Content-Type: text/plain; charset=$CONFIG{charset}\n" .
		   "Content-Transfer-Encoding: $CONFIG{encoding}\n\n" .
		   "$$txtBuffer\n\n" .
		   "--${altBoundary}\n" .
           "$$htmlBuffer\n\n".
		   "--${altBoundary}--\n");
}


############################################################################
# Subroutine: makeTextMail ( text_message )
#
# Takes a text message and generate a text plain message 
############################################################################
sub makeTextMail {
    my $msg = shift;
    return("Content-type: text/plain; charset=$CONFIG{charset}\n" .
           "Content-Transfer-Encoding: $CONFIG{encoding}\n\n$$msg");
}

############################################################################
# Subroutine: encode_qp
#
# Quoted printable encode a text maessage for 7bit mail transfer.
# Blatantly ripped from MIME::Lite by Eryq eryq@zeegee.com
# Which in turn is ripped from MIME::QuotedPrint by Gisle Aas
############################################################################
sub encode_qp {
    my $res = shift;
    $res =~ s/([^ \t\n!-<>-~])/sprintf("=%02X", ord($1))/eg;  # rule #2,#3
    $res =~ s/([ \t]+)$/
            join('', map { sprintf("=%02X", ord($_)) }
                     split('', $1)
            )/egm;                        # rule #3 (encode whitespace at eol)

    # rule #5 (lines shorter than 76 chars, but can't break =XX escapes:
    my $brokenlines = "";
    $brokenlines .= "$1=\n" while $res =~ s/^(.{70}([^=]{2})?)//; # 70 was 74
    $brokenlines =~ s/=\n$// unless length $res;
    "$brokenlines$res";
} 




############################################################################
# Subroutine: sendmail ( from_address, replyto_addresses, to_addresses,
#                        smtp_server, subject_line, message);
#
############################################################################
sub sendmail {
	($debug) && (print STDERR "sendmail (@_) \@ " . time . "\n");
	my ($from, $reply, $to, $smtp, $subject, $message) = @_;

	### Remove the case where multiple from addresses are used.          ###
	$from =~ s/^\s*([^\,]+).*/$1/;
	$debug && print STDERR "[ $from ] [ $reply ] [ $to ] [ $smtp ] [ $subject ]\n";
	my $printer =
		(my $mail = $smtp ?  Net::SMTP->new($smtp) : undef) ?
		"\$mail->datasend" : "print MAIL ";
	if (defined $mail) {
        $debug && print STDERR "using SMTP\n";
		my $fromReturn = $mail->mail($from);
    	$debug && print STDERR "Mail from $from returned with $fromReturn\n";
        for (split(/\s*\,\s*/, $to)) {
            my $toReturn = $mail->to($_);
            $debug && print STDERR "Mail to $_ returned $toReturn\n";
        }
		$mail->data() && $debug && print STDERR "Ready to send mail data\n";
	} elsif ($mailprog) {
		$debug && $smtp && print STDERR "Unable to connect to $smtp\n";
		$debug && print STDERR "Sending mail with $mailprog\n";
		open(MAIL, "| $mailprog -t $extraMailOpts ");
	}
	if ($mail || $mailprog) {
        my $gTime = gmtime;
        $gTime =~ s/\w+ (\w+) (\d+) ([\d:]+) (\d\d)?(\d\d)/$2 $1 $5 $3 GMT/;
		eval("$printer(\"To: \$to\\n\")");
		eval("$printer(\"From: \$from\\n\")");
		eval("$printer(\"Reply-to: \$reply\\n\")");
		eval("$printer(\"Subject: \$subject\\n\")");
		eval("$printer(\"Date: \$gTime\\n\")");
		eval("$printer(\"X-Mailer: Soupermail $relVersion\\n\")");
		eval("$printer(\"\$\$message\")");
		if (defined $mail) {
			$mail->dataend() && $debug && print STDERR "Message end sent OK\n";
			$mail->quit() && $debug && 
				print STDERR "SMTP connection closed OK\n";
		} else {
			close MAIL;
		}
		$debug && print STDERR "Mail sent OK\n";
		return 1;
	} else {
		$debug && print STDERR "Unable to send mail - check mail server\n";
		return 0;
	}
}


############################################################################
# Subroutine: encode_base64 ( string_to_encode,
#                             character_string_to_end_lines_with )
# base64 encode a string.
############################################################################
sub encode_base64 {
	($debug) && (print STDERR "encode_base64 () \@ " . time . "\n");
	my ($res) = "";
	my ($eol) = $_[1];
	$eol = "\n" unless defined $eol;
	while ($_[0] =~ /(.{1,45})/gs) {
		$res .= substr(pack('u', $1), 1);
		chop($res);
	}
	$res =~ tr|` -_|AA-Za-z0-9+/|; 
	### fix padding at the end.                                          ###
	my $padding = (3 - length($_[0]) % 3) % 3;
	$res =~ s/.{$padding}$/'=' x $padding/e if $padding;

	### break encoded string into lines of no more than 76 characters    ###
	### each.                                                            ###
	if (length $eol) {
		$res =~ s/(.{1,76})/$1$eol/g;
	}
	$res;
}


############################################################################
# Subroutine: mailResults ()
# Mail the results to the people in $mailto and also send back a mail to the
# form's sender using the sendertemplate config field.
############################################################################
sub mailResults {
	($debug) && (print STDERR "mailResults (@_) \@ " . time() . "\n");
	my ($outstring, $messageBuffer, $value, $tmpfile, $mailbuffer) = "";
	my ($mailto, $email, $tmp, $theirMail);
    my $t = time();


	checkEmail($email) if ($email = $query->param('Email'));

	$mailto = $CONFIG{'mailto'};
	$mailto = $email if (!$mailto && $CONFIG{'returntosender'} && $email);

	### Handle a sendertemplate setting.                                 ###
	if ($email && ($CONFIG{'sendertemplate'} || $CONFIG{'htmlsendertemplate'} ||
	               $CONFIG{'pdfsendertemplate'})
        && ($mailto || $CONFIG{'replyto'} || $CONFIG{'senderreplyto'} ||
		    $CONFIG{'senderfrom'} || $email)) {
		print STDERR "Should be sending a mail to the sender\n" if ($debug);

		my $theirTemplate = "";
		my $theirHtmlTemplate = "";
		my $theirPdfTemplate = "";
        my $messageBody = "";
		my $senderFrom = $CONFIG{'senderfrom'} ? $CONFIG{'senderfrom'} :
	                    ($CONFIG{'senderreplyto'} ? $CONFIG{'senderreplyto'} :
						($mailto ? $mailto : 
							($CONFIG{'replyto'} ? $CONFIG{'replyto'} : 
								$email)));
        if ($CONFIG{'sendertemplate'}) {
    		grabFile($CONFIG{'sendertemplate'}, \$theirTemplate);
	    	substOutput(\$theirTemplate, '0', 1);
        }
        if ($CONFIG{'htmlsendertemplate'}) {
            grabFile($CONFIG{'htmlsendertemplate'}, \$theirHtmlTemplate);
		    substOutput(\$theirHtmlTemplate, '0', 1);
            $theirHtmlTemplate = encode_qp($theirHtmlTemplate)
                if ($CONFIG{'encoding'} eq 'quoted-printable');
            makeHtmlMail(\$theirHtmlTemplate);
        }
        if ($CONFIG{'pdfsendertemplate'}) {
            grabFile($CONFIG{'pdfsendertemplate'}, \$theirPdfTemplate);
		    substOutput(\$theirPdfTemplate, '4', 1);
			my $pdfName = $CONFIG{'pdfsendertemplate'};
			$pdfName =~ s!/.*?([^/]+)(\.[^/]*)$!$1\.pdf!;
			my $pdfFile = makePdf(\$theirPdfTemplate, $pdfName);
			if ($pdfFile) {
			    $CONFIG{"attachments"}->{"${attachCount}file"} =
			        $pdfFile;
			    $CONFIG{"attachments"}->{"${attachCount}mime"} =
			        "application/pdf";
			}
		}
		if ($CONFIG{'wrap'} && $theirTemplate) {
            wrapText($CONFIG{'wrap'}, \$theirTemplate);
        }
		if ($CONFIG{'sendertemplate'}) {                                        
            $theirTemplate = encode_qp($theirTemplate)
                if ($CONFIG{'encoding'} eq 'quoted-printable');
		}
        $messageBody = "MIME-Version: 1.0\n";
        if ($theirTemplate && $theirHtmlTemplate) {
            $messageBody .= makeAltMail(\$theirTemplate, \$theirHtmlTemplate);
        } elsif ($theirHtmlTemplate) {
            $messageBody .= "$theirHtmlTemplate";
		} elsif ($theirTemplate) {
			$messageBody .= makeTextMail(\$theirTemplate);
		}
		if ($CONFIG{'attachments'}) {
		    my ($key, $file, @attachList);
		    while (($key, $file) = each %{$CONFIG{'attachments'}}) {
			    next unless ($key =~ /(\d+)file/);
				my $attachNum = $1;
				my $fh = new FileHandle "< $file";
				if (defined $fh) {
				    binmode($fh);
				    $file =~ m!/([^/]+)$!;
					my $filename = $1;
				    my $mime_type = 
					    $CONFIG{'attachments'}->{"${attachNum}mime"};
                    unless ($mime_type) {
                        $mime_type = (!$fhBug && -T $fh) ? 'text/plain' :
                                                'application/octet-stream';
					}
					($debug) && print STDERR "Attaching $filename $mime_type\n";
				    push (@attachList, [$fh, $mime_type, $filename]);
				}
			}
		    attachFiles(\$messageBody, $t, \@attachList, 1, $maxdownload);
		}
		sendmail($senderFrom,
		    ($CONFIG{'senderreplyto'} ? $CONFIG{'senderreplyto'} :
			($CONFIG{'replyto'} ? $CONFIG{'replyto'} : $mailto)),
			$email, $mailhost,
			($CONFIG{'sendersubject'} ? $CONFIG{'sendersubject'} :
			$CONFIG{'subject'}), \$messageBody);
		undef $messageBody;
	}

	return 1 unless ($mailto);

    ### Since we're going through PGP ascii armoring, there's no need   ###
	### to use 7bit safe quoted-printable messages since the data will  ###
	### be mail transport safe.                                         ###
	if ($CONFIG{'pgpuserid'}) {
		$CONFIG{'encoding'} = "8bit";
	}

	my $footerText .= "-------------------------------\n" .
				      "Remote Host: $ENV{'REMOTE_HOST'}\n" .
				      "Remote IP: $ENV{'REMOTE_ADDR'}\n" .
				      "User Agent: $ENV{'HTTP_USER_AGENT'}\n" .
				      "Referer: $ENV{'HTTP_REFERER'}\n";
    my $mailMessage = "";
    my $htmlMailMessage = "";
	if ($CONFIG{'mailtemplate'} || $CONFIG{'htmlmailtemplate'}) {
        if ($CONFIG{'mailtemplate'}) {
		    grabFile($CONFIG{'mailtemplate'}, \$mailMessage);
		    substOutput(\$mailMessage, '0', 1);

            $mailMessage .= "\n$footerText" unless ($CONFIG{'nomailfooter'});
	        ### If there's to be word wrapping...                        ###
	        ($CONFIG{'wrap'}) && (wrapText($CONFIG{'wrap'}, \$mailMessage));
            $mailMessage = encode_qp($mailMessage) 
                if ($CONFIG{'encoding'} eq 'quoted-printable');
        }
        if ($CONFIG{'htmlmailtemplate'}) {
		    grabFile($CONFIG{'htmlmailtemplate'}, \$htmlMailMessage);
		    substOutput(\$htmlMailMessage, '0', 1);
            $htmlMailMessage = encode_qp($htmlMailMessage)
                if ($CONFIG{'encoding'} eq 'quoted-printable');
            makeHtmlMail(\$htmlMailMessage);
        }
        if ($mailMessage && $htmlMailMessage) {
            $messageBuffer = makeAltMail(\$mailMessage, \$htmlMailMessage);
        } elsif ($htmlMailMessage) {
            $messageBuffer = $htmlMailMessage;
		} else {
			$messageBuffer = makeTextMail(\$mailMessage);
		}
	} else {
		my (@keylist) = sort($query->param());
		my ($key);
		foreach $key (@keylist) {
			### Because we may be dealing with multiple values, need to  ###
			### join with commas.                                        ###
			$value = join(',', $query->param($key));
			$messageBuffer .= "$key = $value\n";
		}

        $messageBuffer .= "\n$footerText" unless ($CONFIG{'nomailfooter'});
	    ### If there's to be word wrapping...                            ###
	    ($CONFIG{'wrap'}) && (wrapText($CONFIG{'wrap'}, \$messageBuffer));
		### Don't encode the message if its going to a non PGP/MIME      ###
		### destination.                                                 ###
        $messageBuffer = encode_qp($messageBuffer)  
            if ($CONFIG{'encoding'} eq 'quoted-printable');
        $messageBuffer = makeTextMail(\$messageBuffer);
	}

    ### At this point, message buffer contains the right message         ###
	
	### Its here that file upload should go - should restrict size       ###
	### Pseudo code is:                                                  ###
	### foreach input item, look at its values                           ###
	### see if the value has a filehandle                                ###
	### if there's a filehandle, read it in to the specified size        ###
	### MIME it up                                                       ###
	### print it with an appropriate mime type                           ###
	### simple :)                                                        ###
    
    my @attachList = ();
	if ($CONFIG{'mimeon'}) {
	    no strict 'refs';
		foreach ($query->param()) {
		    my $val;
		    foreach $val ($query->param($_)) {
  			    next unless (fileno($val));
		        my $isText = (!$fhBug && -T $val);
				my $mime_type = $query->uploadInfo($val)->{'Content-Type'};
				unless ($mime_type) {
                    $mime_type = ($isText) ? 'text/plain' :
                                             'application/octet-stream';
                }
				my $fname = $val;
				if ($query->user_agent() =~ /(PPC|Mac)\b/) {
				    $fname =~ s/.*:([^:]*)/$1/;
				} else {
				    $fname =~ s/\\/\//g;
				    $fname =~ s/.*\/([^\/]*)/$1/;
				}
				push (@attachList, [$val, $mime_type, $fname]);
			}
		}
	}
    if ($CONFIG{'pdfmailtemplate'}) {
		my $pdfTemplate = "";
        grabFile($CONFIG{'pdfmailtemplate'}, \$pdfTemplate);
	    substOutput(\$pdfTemplate, '4', 1);
		my $pdfName = $CONFIG{'pdfmailtemplate'};
		$pdfName =~ s!/.*?([^/]+)(\.[^/]*)$!$1\.pdf!;
		my $pdfFile = makePdf(\$pdfTemplate, $pdfName);
		if ($pdfFile) {
			($debug) && print STDERR "Putting $pdfName as an attachment\n";
			my $pdfFh = new FileHandle "< ${scratchPad}/$pdfName";
			push(@attachList, [$pdfFh, "application/pdf", $pdfName]);
		}
	}
	if (@attachList) {
	    attachFiles(\$messageBuffer, $t, \@attachList, 0, $maxbytes);
	}

	if ($CONFIG{'pgpuserid'}) {
	    my ($pgpBoundary)    = "###_SfuRdE####_${$}${t}####_foA0R####";
        my $pgpBuffer = $CONFIG{'pgpmime'} ?
                        "Content-Type: multipart/encrypted; " .
                        "protocol=\"application/pgp-encrypted\"; " .
                        "boundary=$pgpBoundary\n\n--$pgpBoundary\n" .
                        "Content-Type: application/pgp-encrypted\n\n" .
                        "Version: 1\n\n--$pgpBoundary\n" .
                        "Content-Type: application/octet-stream\n\n" :
                        "";
		pgpMessage(\$messageBuffer, $CONFIG{'pgpuserid'});
	    $messageBuffer = "${pgpBuffer}${messageBuffer}\n" . 
                      ($CONFIG{'pgpmime'} ? "--${pgpBoundary}--" : "");
	}

    $messageBuffer = "MIME-Version: 1.0\n$messageBuffer";
	$debug && print STDERR "Sending mail to $mailto or $email\n";
	my $mailRes = sendmail(($email) ? $email : $mailto,
							$CONFIG{'replyto'} ? $CONFIG{'replyto'} : $mailto,
							($CONFIG{'returntosender'} && $email 
                                                       && $email ne $mailto) ? 
							"$mailto, $email" : $mailto,
							$mailhost, $CONFIG{'subject'}, \$messageBuffer);
	$debug && print STDERR "Mail returned result of $mailRes\n";
	undef $messageBuffer;
	return 1;
}

############################################################################
# Subroutine: attachFiles ( message, timestamp, filelist, 
#                           do_encoding, maximum )
# Add MIME attachments to a message buffer. Messagebuffer will be
# enclosed in the appropriate MIME headers. Filelist is assumed to be
# a list of filehandle, mime and filename tuples.
############################################################################
sub attachFiles {
    my $messageBuffer = shift;
    my $t = shift;
	my $fileList = shift;
	my $doEnc = shift;
	my $max = shift;
	my ($mixBoundary)    = "###_AIIEHATSS###_${$}${t}##_SUEMIL###";
	my ($val, @vals, $mime_type, $bytesin, $inbuff, $tmpbuffer);
	no strict 'refs';
	my ($currentBytes) = 0;
    my $attachBuffer = "Content-Type: multipart/mixed; " .
                       "boundary=\"$mixBoundary\"\n" .
                       "\n--$mixBoundary\n" .
                       $$messageBuffer .
		               "\n--$mixBoundary";
	foreach $val (@$fileList) {
		### Doesn't do anything in UNIX, but NT ready :)             ###
		my $fh = $val->[0];
		$mime_type = $val->[1];
		my $filename = $val->[2];
		binmode($fh);
		$tmpbuffer = '';
		my $tmpBytes = $currentBytes;
		if ($currentBytes < $max) {
			while (<$fh>) {
				$tmpbuffer .= $_;
				$tmpBytes += length($_);
				if ($tmpBytes >= $max) {
					close($fh);
					next;
				}
			}
			close($fh);
			$currentBytes = $tmpBytes;
		} else {
			last;
		}

		if ($tmpbuffer) {
			$attachBuffer .= "\nContent-Type: $mime_type; " .
                             "name=\"$filename\"\n" .
					         "Content-Disposition: attachment; " .
					         "filename=\"$filename\"\n";
			if ($mime_type =~ m!^text/!) {
                $tmpbuffer = encode_qp($tmpbuffer)  
                    if ($CONFIG{'encoding'} eq 'quoted-printable' && $doEnc);
				$attachBuffer .= "Content-Transfer-Encoding: " .
                                 "$CONFIG{encoding}\n\n" .
						         "$tmpbuffer\n";
			} else {
				$attachBuffer .= "Content-Transfer-Encoding: " .
                                 "base64\n\n" .
						         encode_base64("$tmpbuffer", "\cM\n") .
                                 "\n";
			}
			$attachBuffer .= "--$mixBoundary";
		}
	}
	$$messageBuffer = $attachBuffer . "--\cM\n";
}

END_OF_MAIL_FUNCTIONS

my $wrapFunctions =<<'END_OF_WRAP_FUNCTIONS';
############################################################################
# Subroutine: wrapText ( number_of_characters_to_wrap_to,
#                        buffer_to_wrap )
# Takes a buffer, and wraps it to the number of characters specified.
# Returns the wrapped buffer.
############################################################################
sub wrapText {
	($debug) && (print STDERR "wrapText (@_) \@ " . time . "\n");
	my ($wrap, $buffer) = @_;
	my ($start, $rest, $tmp, $something);
	### Need to isolate words longer than the wrap size ...              ###
	$$buffer =~ s/([^\s]{$wrap,})\s/\n$1\n/g;
	### ... and then do real wrapping.                                   ###
	while ($$buffer =~ /([^\n]{$wrap})/) {
		$start = $`;
		$rest = $';
		$something = $1;
		$something =~ s/((.|\n)*)\s((.|\n)*)/$1\n$3/;
		$something =~ /((.|\n)*)(\n.*)/;
		$tmp .= $start . $1;
		$$buffer = $3 . $rest;
	}
	$$buffer = $tmp . $$buffer;
}
END_OF_WRAP_FUNCTIONS


my $pgpFunctions =<<'END_OF_PGP_FUNCTIONS';

############################################################################
# Subroutine: pgpFail ( failure_message )
# Need a special pgp failure routine to clean up after pgp's done a mess.
############################################################################
sub pgpFail {
	($debug) && (print STDERR "pgpFail (@_) \@ " . time . "\n");
	my ($msg) = shift;
	fatal("PGP Failure: <B>$msg </B>");
}

############################################################################
# Subroutine: pgpInit ()
# Using PGP, so check all's well
# This is designed with pgp 5.0i in mind, so i have to take care
# that pgp doesn't generate any unwanted output... ie. give it a
# random number file
# Stop soupermails from clashing by using pid numbers
# If it all goes pear shape, make sure the files are deleted
# by giving total write access. I suppose this is a hole, but a small one
#
# How to encrypt to sender... hmm, they'd have to supply their own
# pgp key... i guess it could be done, but not at the moment.
# Guess i could introduce a text area called PGP for users to put
# their key in, or have the pgp check the Email field
# Perhaps even use netscape's upload button - only if v.adventurous though
# Actually, now this is using PGP 5.0i rather than 2.6, I guess the 
# keys should be pulled from a central key server!
############################################################################
sub pgpInit {
	my $keyring = 'pubring.' . ($CONFIG{'gnupg'} ? 'gpg' : 'pkr');

	($debug) && (print STDERR "pgpInit (@_) \@ " . time . "\n");
	fatal("Cannot use PGP encryption with Return to Sender option") 
		if ($CONFIG{'returntosender'});

	### Now we need to two one thing for GPG (import the given keyring) ###
	### or create a config and random file for PGP.                     ###
	if ($CONFIG{'gnupg'}) {
	    copy("$serverRoot${pageRoot}/$keyring", "$scratchPad/$keyring") || 
			pgpFail("Can't copy $keyring");
		showFile("${scratchPad}/$keyring");
	} else {
		if (-f "${serverRoot}${pageRoot}/$keyring") {
			copy("$serverRoot${pageRoot}/$keyring", "$scratchPad/$keyring") || 
				pgpFail("Can't copy $keyring");
			showFile("${scratchPad}/$keyring");
		}

		### I don't know how random this is going to be, but there's     ###
		### no HTTP keypress emulator :)                                 ###
		open(RAND, "> ${scratchPad}/randseed.bin") || 
			pgpFail("can't open randseed.bin for creating");
		my ($i);
		for ($i = 0; $i < 512; $i++) {
			print RAND pack("c", rand(255));
		}
		close(RAND);
		showFile("${scratchPad}/randseed.bin");

		### Make a config file... PGP 5 complains if it doesn't get one. ###
		open (PGPCONF, "> ${scratchPad}/pgp.cfg") ||
			pgpFail("can't open pgp.cfg for creating");
        if ($OS eq "windows") { 
            $scratchPad =~ s/\/+/\\/g;
			print PGPCONF "PubRing=${scratchPad}\\$keyring\n" 
                if (-f "${scratchPad}/$keyring");
        } else {
			print PGPCONF "PubRing=${scratchPad}/$keyring\n" 
                if (-f "${scratchPad}/$keyring");
        }
		print PGPCONF "NoBatchInvalidKeys=0\n";
		print PGPCONF "VERBOSE=0\n";
		print PGPCONF "HTTPKeyServerHost=$CONFIG{pgpserver}\n"
			if ($CONFIG{'pgpserver'});
		print PGPCONF "HTTPKeyServerPort=$CONFIG{pgpserverport}\n"
			if ($CONFIG{'pgpserverport'});
		close(PGPCONF);
	}
}


############################################################################
# Subroutine: pgpMessage (messageRef, timeString)
# Wrap a message up as a PGP encrypted message
############################################################################
sub pgpMessage {
    my $messageBuffer = shift;
    my $uid = shift;
	my $pgpBuffer = "";
	### want to PGP encode the buffer.                               ###
	pgpInit();
	$| = 1;
	my $cmd = ($CONFIG{'gnupg'}) ?
		"$pgpencrypt --homedir $scratchPad --batch " .
		"--always-trust --quiet " .
		"-eatr '${uid}'"
		:
		"PGPPATH=$scratchPad $pgpencrypt -at -r '${uid}' " .
		"-f +batchmode=1";

    if ($OS eq 'windows') {
        my $outfile = "$scratchPad/eout.txt";
        if ($CONFIG{'gnupg'}) {
            $outfile =~ s/\/+/\\/g;
            $cmd .= " -o \"$outfile\"";
            $cmd =~ s/'/"/g;
            $debug || close(STDERR);
            open (WINGPGIN, "| $cmd");
            print WINGPGIN $$messageBuffer;
            close WINGPGIN;
        } else {
            $outfile =~ s/\/+/\\/g;
            $cmd = "\"$pgpencrypt\" -at -f -r $uid " .
			       "+batchmode -o $outfile";
            $ENV{'PGPPATH'} = $scratchPad;
            chdir($scratchPad);
            open (WINPGPIN, "| $cmd");
            print WINPGPIN $$messageBuffer;
            close WINPGPIN;
        }
        open (WINOUT, "< $outfile");
        while (<WINOUT>) {
            $pgpBuffer .= $_;
        }
        close (WINOUT);
    } else {
	    my $read = new FileHandle;
	    my $write = new FileHandle;
	    my $error = new FileHandle;
	    my $pid = open3($write, $read, $error, $cmd);
	    $read->autoflush();
	    for (split (/\n/, $$messageBuffer)) { 
		    $write->print("$_\n"); 
	    }
	    $write->close;
	    undef $write;
	    for ($read->getlines()) {
		    $pgpBuffer .= $_;
	    }
	    $read->close;
	    for ($error->getlines()) {
		    print STDERR $_;
	    }
	    $error->close;
    }
    $debug && print STDERR ($CONFIG{'gnupg'} ? "GPG" : "PGP") . ": $cmd\n";
	$$messageBuffer = $pgpBuffer;
}

END_OF_PGP_FUNCTIONS

############################################################################
# There are a couple of deadlock points in soupermail, mainly due to PGP and
# fileuploads. So, we'll actually fork of a child to do that dangerous stuff
# and kill it if a certain timeout's reached.
############################################################################
if ($forkable && $OS eq "unix" && ($child = fork)) {
	$SIG{CHLD} = sub { cleanScratch(); exit; };
	$SIG{TERM} = sub { kill 9, $child;
						cleanScratch(); exit; };
	$SIG{PIPE} = sub { kill 9, $child;
						cleanScratch(); exit; };
	$| = 1;
	sleep 60;
	kill 9, $child;
	fatal ("Soupermail has timed out");
	exit;
} else {
	### Stop STDERR being output to the screen                           ###
	### This is UNIX specific... should check the OS I guess...          ###
	if ($debug) {
		open(STDERR, ">> $debug"); 
	} else {
		open(STDERR, "> /dev/null");
	}

	$| = 1;
	### This is the dangerous child that could hang on the new CGI       ###
	$query = new CGI;

	### Remove leading and trailing spaces.                              ###
	nukeValues();

	$debug && print STDERR "\n\nrunning on perl $] for $^O\n\n";

	### Try and find out where the configuration file is.                ###
	my $transPath = "";
	$transPath = $query->path_translated() if ($query->path_translated());
	if ($transPath =~ m!${serverRoot}(.*)/([^/]*)!) {
		### $pageRoot is where the actual script is being called from    ###
		$pageRoot = $1;
		securityFilename($pageRoot);
		### The configuration file                                       ###
		$config = $transPath;
	} else {
		### See if the config file's been specified in the form itself   ###
		if ($query->param('SoupermailConf')) {
			unless ($query->param('SoupermailConf') =~ m!^/!) {
				if ($query->referer() =~ m!^https?://[\w\.\-]+(:\d+)?(/.*)!i) {
					my $urlPath = $2;
					### Remove any anchor or query stuff... won't work   ###
					### for path info though :(                          ###
					$urlPath =~ s/(^.*?)[\#\?]/$1/;
					$urlPath =~ m!(.*)/[^/]*!;
					$pageRoot = $1;
					$config = "$serverRoot$pageRoot/" . 
								$query->param('SoupermailConf');
					### Have to possibly compress ../ type directories.  ###
					while ($config =~ s![^/]+/\.\./!!) {}
					fatal ("Config file out of server root") unless
						($config =~ /^$serverRoot/);
				} else {
					fatal("Cannot determine conf location from referer");
				}
			} else {
				### The config file is an absolute path starting with /. ###
				$query->param('SoupermailConf') =~ m!(.*)/[^/]*!;
				$pageRoot = $1;
				$config = $serverRoot . $query->param('SoupermailConf');
			}
			securityFilename($config);
			fatal("Unable to find or read the config file") unless 
				(-e $config && -f $config && -r $config);
			### Need to reset pageRoot here because ../s in the relative ###
			### path may have altered things.                            ###
			$config =~ m!^$serverRoot(.*)/[^/]+!;
			$pageRoot = $1;
		} else {
			fatal("Unable to determine where the config file is.");
		}
	}

	my $configFile = "";
	grabFile($config, \$configFile);

	$debug && print STDERR "Reading config $config\n";
	for (split(/\n/, $configFile)) {
		my ($setValue);
		my ($toValue);
		next if (/^\s*\#/);
		next unless (/\S/);
		if (/^\s*([^:\s]*\S+)\s*:\s*(.*[\S])\s*$/) {
			$setValue = $1;
			$toValue = $2;
            unless ($setValue =~ /^(if|unless)/i) {
			    fatal ("Too many quote marks in a configuration line <B>$_</B>")
			        if (($toValue =~ tr/"/"/) > 2);
            }
	    
			### now do some work to do replacement of mailto, replyto,   ###
			### subject, ref and cookie values                           ###
			if ($toValue =~ /^"[^"]*"\s*$/ && 
				$setValue =~ /$replaceable/ix) {
				$toValue = replacer($toValue, $setValue);
			}
			setConfig($setValue, $toValue);
		} else {
			fatal("Unrecognised config line '$_'\n");
		}
	}
	$debug && print STDERR "Finished reading config $config\n";

	### Set up config based on conditions - and do it before anything    ###
	### else, because it can affect pgp, requireds, etc.                 ###
	if (@conditions) {
		$debug && print STDERR "Have conditions to parse\n";
		parseConditions();
	}

    makeScratch();
	$CONFIG{'wrap'} && eval($wrapFunctions);
	if ($CONFIG{'templated'}) { 
	    eval($templateFunctions);
	    $debug && print STDERR "Evaluated template functions\n";
	}
    if ($CONFIG{'pgpuserid'} || $CONFIG{'filepgpuserid'}) {
	    eval($pgpFunctions);
	    $debug && print STDERR "Evaluated PGP functions\n";
	}
	if ($CONFIG{'fileto'}) {
	    eval($fileFunctions);
	    $debug && print STDERR "Evaluated file functions\n";
	}
	if ($CONFIG{'pdftemplate'} || $CONFIG{'pdfmailtemplate'} ||
	    $CONFIG{'pdfsendertemplate'}) {
	    eval($pdfFunctions);
	    $debug && print STDERR "Evaluated pdf functions\n";
	}
	if ($CONFIG{'mailto'} || $CONFIG{'returntosender'} || 
		$CONFIG{'sendertemplate'} || $CONFIG{'htmlsendertemplate'} ||
		$CONFIG{'pdfsendertemplate'} || $CONFIG{'pdfmailtemplate'}) {
		eval($mailFunctions);
	    $debug && print STDERR "Evaluated mail functions\n";
	}

	### Do a test to see if the GPG key is OK                            ###
	if ($CONFIG{'pgpuserid'}) {
		if ($CONFIG{'gnupg'}) {
			fatal("GPG doesn't appear to be available at $pgpencrypt") unless
				(-f $pgpencrypt && -x $pgpencrypt);
			fatal("Cannot find GPG keyring") unless 
				(-f "${serverRoot}${pageRoot}/pubring.gpg");
			fatal("Cannot read GPG keyring") unless 
				(-r "${serverRoot}${pageRoot}/pubring.gpg");
		} else {
			fatal("PGP doesn't appear to be available at $pgpencrypt") unless
				(-f $pgpencrypt && -x $pgpencrypt);
			fatal("Can't find pubring.pkr in ${pageRoot}") unless 
				(-f "${serverRoot}${pageRoot}/pubring.pkr" || 
				 $CONFIG{'pgpserver'});
			fatal("Can't read pubring.pkr in ${pageRoot}") unless 
				(-r "${serverRoot}${pageRoot}/pubring.pkr" || 
				 $CONFIG{'pgpserver'});
		}
	}
	### Check for expiry date                                            ###
	if ($today > $CONFIG{'expirydate'}) {
		doCounters('expires');
		$CONFIG{"ref"} = translateFormat($CONFIG{"ref"});
		subReplace();
		returnExpired();
		cleanScratch();
		exit;
	}

	### Check for missing required fields                                ###
	if (formMissingRequired()) {
		doCounters('failure');
		$CONFIG{"ref"} = translateFormat($CONFIG{"ref"});
		subReplace();
		returnFailure();
		cleanScratch();
		exit;
	}

	if (badTypes(\@typeChecks)) {
		$debug && print STDERR "Have bad types\n";
		$CONFIG{"ref"} = translateFormat($CONFIG{"ref"});
		subReplace();
		returnFailure();
		cleanScratch();
		exit;
	}


	### Check for a blank form                                           ###
	if (formIsBlank()) {
		doCounters('blank');
		$CONFIG{"ref"} = translateFormat($CONFIG{"ref"});
		subReplace();
		returnBlank();
		cleanScratch();
		exit;
	}

	### Looks ok, so return the final page                               ###
	doCounters('success');
	$CONFIG{"ref"} = translateFormat($CONFIG{"ref"});
	subReplace();
	if ($CONFIG{'fileto'}) { genFileto(); }
	returnSuccess();
	cleanScratch();
	exit;
}



############################################################################
# Subroutine: subReplace () 
# Replace http_ref and counter values for config options. This needs
# to happen after counters have been processed
############################################################################
sub subReplace () {
	($debug) && (print STDERR "subReplace () \@ " . time . "\n");
    my $setValue;
    foreach $setValue (keys %needToReplace) {
	    my $val = $CONFIG{$setValue};
		$val =~ s/\$counter_(\d+)/$CONFIG{'counter'}->{"${1}value"}/gs;
	    ($debug) && (print STDERR "processing $setValue to $val\n");
	    $CONFIG{$setValue} = $val;
	}
}

############################################################################
# Subroutine: makeUrl ( url )
# For convenience sake, this will try and figure out if a given URL is 
# absolute or relative. If its relative, it'll try and fill in the
# blanks to make it an absolute URL for the current server. 
# Returns the absolute URL.
############################################################################
sub makeUrl {
	($debug) && (print STDERR "makeUrl (@_) \@ " . time . "\n");
	$_ = shift;
	my ($server, $url);
	$server = $query->server_name() unless ($server = $ENV{'HTTP_HOST'});
	if ($query->server_port() != 80 && ! $server =~ /:\d+$/) {
		$server .= ":" . $query->server_port();
	}
    my $proto = "http" . ($ENV{'HTTPS'} =~ /on/i ? "s" : "");
	SWITCH: {
		if (/^\//) { $url = "${proto}://${server}$_"; last SWITCH; }
		if (m!^https?://!i) { $url = $_; last SWITCH; }
		$url = "${pageRoot}/$_";
		while ($url =~ s![^/]+/\.\./!!) {}
		$url = "${proto}://${server}$url";
	}
	return($url);
}


############################################################################
# Subroutine: makePath ( path )
# Makes a path from the server root from the specified path. If the path is
# absolute (ie. starts with a /, its assumed to be from the server root,
# otherwise its assumed to be relative to the configuration file.)
############################################################################
sub makePath {
	($debug) && (print STDERR "makePath (@_) \@ " . time . "\n");
	my $path = shift;
	my $oPath = $path;
	$path = $serverRoot . ($path =~ m!^/! ? "" : "$pageRoot/") . $path; 
	while ($path =~ s![^/]+/\.\./!!) {}
	$path =~ s!/+!/!g;
	securityFilename($path);
	($path =~ /^$serverRoot\//) && (return $path);
	fatal("The path $oPath requested is outside the server root");
}


############################################################################
# Subroutine: setConfig ( configuration_line )
# This routine takes a configuration variable name and a value and attempts
# to set the variable to the value. It does a fair bit of error and
# security checking depending on the type of variable to set.
############################################################################
sub setConfig {
	($debug) && (print STDERR "setConfig (@_) \@ " . time . "\n");
	$_ = shift; 
	my ($value) = shift;
	$_ = lc($_);
	CONFSWITCH : {

	### Required form fields that must be filled in before success.      ###
	### Ignored fields can be used to hide hidden fields from the blank  ###
	### form checking routine.                                           ###
	if (/^(required|ignore)/) {
		securityName($value, 1);
		my ($list) = ($1 eq "required" ? \@required : \@ignored);
		push(@$list, $value);
		last CONFSWITCH;
	}

	### Type checking fields                                             ###
	if (/^is(not)?(number|integer|email|creditcard)$/) {
	    push(@typeChecks, [$_, $value]);
	}
    
	### This is a subject line for generated email... truncated at 199   ###
	### characters to stop DoS attacks against crappy mail clients.      ###
	if (/^(sender)?subject/) {
        if (length($value) > 199) {
            $value = pack("a199", $value);
        }
		$CONFIG{$&} = $value;
		last CONFSWITCH;
	} 

	### A format for the autogenerated reference field.                  ###
	### See translateFormat() for more on how it works.                  ###
	if (/^ref/) {
		$CONFIG{'ref'} = $value;
		last CONFSWITCH;
	}

	### A filename to save the form results into. It should be specified ###
	### relative to where the configuration file was placed.             ###
	if (/^fileto/) {
		$CONFIG{'fileto'} = $value;
		last CONFSWITCH;
	}

	### This is a filename for a counter. The numbers in the middle are  ###
	### used to specify which counter we're talking about.               ###
	if (/^counter(\d+)file/) {
		my $countNum = $1;
		my $counterFile = makePath($value);
		$counterFile =~ m!^(.*)/[^/]*$!;
		fatal ("Can not write to counter file of $value") 
			if ((-e $counterFile && ! -w $counterFile) ||
				(-e $counterFile && -l $counterFile) ||
				(! -e $counterFile && ! -w $1));
		my $counterValue = "0";
		grabFile($counterFile, \$counterValue) if (-f $counterFile);
		$counterValue =~ /^(\d+)/;
		$CONFIG{"counter"}->{"${countNum}value"} = $1;
		$CONFIG{"counter"}->{"${countNum}file"} = $counterFile;
		if (!$CONFIG{"counter"}->{"${countNum}step"}) {
			$CONFIG{"counter"}->{"${countNum}step"} = 1;
		}
		last CONFSWITCH;
	}

	### Set the counter to an absolute value.                            ###
	if (/^setcounter(\d+)/) {
		my $countNum = $1;
		fatal("Counter values must be numeric for $_") if 
			($value =~ /[^\d]/);
		$CONFIG{"counter"}->{"${countNum}set"} = $value;
		last CONFSWITCH;
	}

	### Set the counter step value.                                      ###
	if (/^counter(\d+)step/) {
		my $countNum = $1;
		fatal("Counter step values must be numeric for $_") if 
			($value =~ /[^\d]/);
		$CONFIG{"counter"}->{"${countNum}step"} = $value;
		last CONFSWITCH;
	}

	### Counters can change depending on the four different outcomes of ###
	### a form's submission.                                            ###
	if (/^counter(\d+)on(failure|success|expires|blank)/) {
		my $countNum = $1;
		my $mode = $2;
		last CONFSWITCH unless ($value =~ /^(yes|no|1|0)$/i);
		$CONFIG{'counter'}->{"${countNum}on$mode"} = 
			($value =~ /^(yes|1)$/i) ? 1 : 0;
		last CONFSWITCH;
	}

	### Attachments are sent with sendertemplate data and there can be  ###
	### any number of them.                                             ###
	if (/^attachment(\d+)$/) {
	    my $attachNum = $1;
		if ($value ne '""') {
		    my $attachFile = makePath($value);
		    unless (-f $attachFile && -r $attachFile) {
		        fatal("Cannot read file attachment $attachNum");
		    }
		    $CONFIG{"attachments"}->{"${attachNum}file"} = $attachFile;
			$attachCount++;
		} else {
		    delete $CONFIG{"attachments"}->{"${attachNum}file"};
		    delete $CONFIG{"attachments"}->{"${attachNum}mime"};
			$attachCount--;
		}
	}

	### Attachments need to have a mime type associated with them       ###
	if (/^attachment(\d+)mime/) {
	    my $attachNum = $1;
		fatal("Unrecognised attachment MIME format $value") unless
		    ($value =~ m!^[\w\-]+/[\w\-]+$!);
		$CONFIG{"attachments"}->{"${attachNum}mime"} = $value;
	}

	### This specifies the maximum number of bytes a soupermail generated###
	### file can grow to. If a new addition will take the file over this ###
	### size, the file is initially deleted. The backup name (if any)    ###
	### for the deleted file is specified with filebackupformat.         ###
	if (/^filemaxbytes/) {
		fatal("filemaxbytes must be a number")	if ($value =~ /[^\d]/);
		$CONFIG{'filemaxbytes'} = $value;
		last CONFSWITCH;
	}

	### This is the format for any backup of a soupermail generated file ###
	### which is deleted due to the filemaxbytes setting. It takes the   ###
	### same formatting values as a reference number format.             ###
	if (/^filebackupformat/) {
		$value = translateFormat($value);
		my $tmpFile = makePath($value);
		if (-e $tmpFile && !-w $tmpFile) {
			fatal("No permissions for writing to filebackupformat");
		}
		if (-e $tmpFile && -l $tmpFile) {
			fatal("The filebackupformat file is a symlink");
		}
		### Check to see if we've got write access to the backup         ###
		### directory.                                                   ###
		unless (-e $tmpFile) {
			$tmpFile =~ m!(.*/)[^/]*!;
			fatal ("Cannot write into the backup directory") unless (-w $1);
		}
		$CONFIG{'filebackupformat'} = $tmpFile;
		last CONFSWITCH;
    }

	### email address(es) to send the form's mail to.                    ###
	### checkEmail() does a little security check to make sure emails    ###
	### look right.                                                      ###
	if (/^(sender)?replyto|mailto|senderfrom/) {
		checkEmail($value);
		$CONFIG{$&} = $value;
		last CONFSWITCH;
	} 

	### Set up some template files. All these are assumed to be relative ###
	### to the location of the configuration file.                       ###
	if (/^(headings|footings|success|failure|blank|
	       (expires|file|pdf)template|
		   (html|pdf)?mailtemplate|(html|pdf)?sendertemplate)/x) {
		my $cf = $&;
		if (!$CONFIG{'templated'}) {
		    $CONFIG{'templated'} = (/success|failure|blank|template/);
		}
		$CONFIG{$cf} = makePath($value);
		fatal("Cannot find the $cf template file") unless 
			(-f $CONFIG{$cf} && -r $CONFIG{$cf});
		last CONFSWITCH;
	}

	### If the sender of the email wants to get a confirmation copy of   ###
	### soupermail generated email, setting this to 'yes' or 1 will do   ###
	### so by putting the sender in the CC email header.                 ###
	if (/^returntosender/) {
		last CONFSWITCH unless ($value =~ /^(yes|no|1|0)$/i);
		$CONFIG{'returntosender'} = ($value =~ /^(yes|1)$/i) ? 1 : 0;
		last CONFSWITCH;
	}

	### This field takes a date, and will cause the form to stop         ###
	### accepting submissions ON or AFTER that date.                     ###
	if (/^expires/) {
		fatal ("Invalid expiry format $value") unless 
			($value =~ /^(\d\d?)-(\d\d?)-(\d\d(\d\d)?)$/);
		if ($1 > 31 ||  $2 > 12 || $1 < 1 || $2 < 1) {
			fatal ("Invalid Expiry date <B>$1 - $2 - $3 </B>");
		} elsif ($3 > 2037) {
			### Hey, this even looks for the dreaded 32bit running out   ###
			### of bits bug!                                             ###
			fatal("Expiry date must be before the year 2038");
		}
		$CONFIG{'expirydate'} = timelocal(0,0,0,$1,($2 - 1), $3);
		last CONFSWITCH;
	}

	### This species how many characters to wrap emails to.              ###
	if (/^wrap/) {
		$value =~ s/\D//g;
		$CONFIG{'wrap'} = $value;
		last CONFSWITCH;
	}

	### This is the username or KeyID of a user in the pubring.pkr       ###
	### PGP public keyring placed in the directory where the config file ###
	### is. Using KeyIDs is better, as they are unique (I think).        ###
	if (/^(file)?pgpuserid/) {
		fatal("Illegal characters in the PGP userid $value") if
			($value =~ /[^\w \<\>\@\.\-]/);
		$CONFIG{$_} = $value;
		last CONFSWITCH;
	}

	### PGP 5 can look for stuff off an internet PGP key server, this    ###
	### way, you should be able to use pgp userids that are on a remote  ###
	### server, rather than in your public keyring.                      ###
	if (/^pgpserver/) {
		unless ($value =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|
							(([\w\-]+\.)*[\w\-]+)$/x) {
			fatal("The PGP keyserver name must be a hostname or an" .
				  " IP address");
		}
		$CONFIG{'pgpserver'} = $value;
		last CONFSWITCH;
	}

	### This defines the post the PGP key server's running on.           ###
	if (/^pgpport/) {
		unless ($value =~ /^\d+$/) {
			fatal("The PGP keyserver port must be an integer");
		}
		$CONFIG{'pgpserverport'} = $value;
		last CONFSWITCH;
	}

	### These are the flags to say whether or not to use GNU Privacy     ###
    ### Guard rather than PGP 5 an whether to use PGP/MIME packaging of  ###
    ### the email.                                                       ###
	if (/gnupg|pgpmime/) {
		my $confVal = $&;
		last CONFSWITCH unless ($value =~ /^(yes|no|1|0)$/i);
		$CONFIG{$confVal} = ($value =~ /^(yes|1)$/i) ? 1 : 0;
		last CONFSWITCH;
	}

    ### The defines the character set to set as the email character set  ###
    if (/mailcharset/) {
		if ($value =~ /[^\w\-]/) {
			fatal("The mail character set must only contain letters, numbers " .
                  "and hyphens");
		}
		$CONFIG{'charset'} = $value;
		last CONFSWITCH;
    }

	### This sets up an if conditional value.                            ###
	if (/^if|(unless)/) {
		my $conditionType = $1 ? 1 : 0;
		fatal("Conditional <B>$value </B>with wrong format") unless 
			($value =~ /.*\s+then\s+[^:\s]+\s*:\s*.*[\S]\s*/i);
		push(@conditions, $value);
		push(@condTypes, $conditionType);
		last CONFSWITCH;
	}

	### Rather than using a templates, these goto... values goto a       ###
	### specific URL.                                                    ###
	if (/^(goto(success|failure|expires|blank))/) {
		$CONFIG{$1} = makeUrl($value);
		last CONFSWITCH;
	}

	### Set some boolean flags up.                                       ###
	### By default, soupermail pops a 4 line summary about the form that ###
	### started it at the end of the email it sends out. nomailfooter    ###
	### stops that behaviour.                                            ###
	### By default, any files written by soupermail are made unreadable  ###
	### to the webserver. If you want, setting filereadable stops this   ###
	### behaviour.                                                       ###
	### Setting nofilecr will remove newline characters from anything    ###
	### written into a soupermail generated file.                        ###
	### Setting fileattop will place new entries into a soupermail       ###
	### generated file right at the top, or, if a headings has been      ###
	### specified, straight after the headings.                          ###
	### Setting mimeon allows MIME form uploads. The generated emails    ###
	### will have MIME based attachments for anything uploaded.          ###
	### Setting cgiwrappers alters the chmod behaviour when hiding files ###
	if (/^nomailfooter|filereadable|nofilecr|fileattop|mimeon|
	      cgiwrappers/x) {
		my $confVal = $&;
		last CONFSWITCH unless ($value =~ /^(yes|no|1|0)$/i);
		$CONFIG{$confVal} = ($value =~ /^(yes|1)$/i) ? 1 : 0;
		last CONFSWITCH;
	}

	### This will set or generate a cookie.                              ###
	### Defaults for a new cookie are:                                   ###
	###     name    - cookie1, cookie2 or cookie3                        ###
	###     value   - ""                                                 ###
	###     path    - path to the soupermail CGI                         ###
	###     domain  - the current server's name                          ###
	###     expires - in 24 hours                                        ###
	###     secure  - sent over SSL and non-SSL connections              ###
	if (/^${cookieStr}(name|value|path|domain|secure|expires)/) {
		my $item  = $1 - 1;
		my $cset  = $2;
		my $cname = "cookie$1";
		my $cval  = "";
		my $csec  = 0;
		my $cexpires = '+1d';
		my $cdomain = ($query->virtual_host() ? $query->virtual_host() :
												$query->server_name());
		my $cpath = $query->script_name();
		if ($cset eq "name") {
			$cname = $value;
			if ($cname =~ /[^\w\-]/) {
				fatal("Cookie names can only contain letters and numbers");
			}
			if (length($cname) > 50) { 
				fatal("Cookie names must be less than 50 characters long.");
			}
		} elsif ($cset eq "value") {
			if (length($value) > 516) {
				$value = substr($value, 516);
			}
			$cval = $value;
		} elsif ($cset eq "path") {
			fatal("Invalid cookie path $value") if ($value =~ /[^\w\.\/\%\-]/);
			$cpath = $value;
		} elsif ($cset eq "domain") {
			fatal("Invalid cookie domain $value") 
				unless ($value =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|
									(([\w\-]+\.)*[\w\-]+)(:\d+)?$/x);
			$cdomain = $value;
		} elsif ($cset eq "secure") {
			$csec = $value = ($value =~ /yes|1/i) ? 1 : 0;
		} elsif ($cset eq "expires") {
			unless ($value =~ /^(\+\d+[smhdMy]|
								\-\d+[smhdMy]|
								[nN][oO][wW]|
								\d\d?-\d\d?-\d\d(\d\d)?|
								\d\d?-\d\d?-\d\d(\d\d)?\s+\d\d?:\d\d?(:\d\d?)?|
								\d\d?:\d\d?(:\d\d?)?)$/x) {
				fatal("Incorrect cookie expires format $value");
			}
			my (@hasDate) = ();
			my (@hasTime) = ();

			### Now check the date format.                               ###
			if ($value =~ /\b(\d\d?)-(\d\d?)-(\d\d(\d\d)?)\b/) {
				if ($1 > 31 ||  $2 > 12 || $1 < 1 || $2 < 1) {
					fatal ("Invalid Expiry date <B>$1 - $2 - $3 </B>");
				} elsif ($3 > 2037) {
					fatal("Cookie expiry date must be before the year 2038");
				}
				$hasDate[0] = $1;
				$hasDate[1] = $2;
				$hasDate[2] = $3;
			}

			### And check the time format.                               ###
			if ($value =~ /\b(\d\d?):(\d\d?)(:(\d\d?))?\b/) {
				if ($1 > 23 || $2 > 59 || ($4 && $4 > 59)) {
					fatal("Invalid cookie expiry time ${1}:$2$3");
				}
				$hasTime[0] = $1;
				$hasTime[1] = $2;
				$hasTime[2] = $4;
			}

			### Now set up the time/date stuff.                          ###
			if (@hasDate || @hasTime) {
				if (@hasDate && @hasTime) {
					$value = localtime(timelocal($hasTime[2],
										$hasTime[1],
										$hasTime[0],
										$hasDate[0],
										$hasDate[1] - 1,
										$hasDate[2]));
				} elsif (@hasDate) {
					$value = localtime(timelocal(0, 0, 0,
										$hasDate[0],
										$hasDate[1] - 1,
										$hasDate[2]));
				} else {
					my @now = localtime(time);
					$value = localtime(timelocal($hasTime[2],
										$hasTime[1],
										$hasTime[0],
										$now[3],
										$now[4],
										$now[5]));
				}
			}
			$cexpires = $value;
		}
		if ($cookieList[$item]) {
			### That cookie already exists, so we'll have to change      ###
			### stuff.                                                   ###
			$cookieList[$item]->{$cset} = $value;
		} else {
			### Its a new cookie, hhhmmmmmm, coookies :)                 ###
			$cookieList[$item] = {'name'=>$cname, 'value'=>$cval,
								  'domain'=>$cdomain, 'path'=>$cpath,
								  'secure'=>$csec, 'expires'=>$cexpires};
		}
		last CONFSWITCH;
	}

	### This controls when cookies will be sent out.                     ###
	if (/^cookieon(failure|success|blank|expires)/) {
		my $cfgval = $1 . "cookie";
		last CONFSWITCH unless ($value =~ /^(yes|no|1|0)$/i);
		$CONFIG{$cfgval} = ($value =~ /^(yes|1)$/i) ? 1 : 0;
		last CONFSWITCH;
	}

	} ### End of CONFSWITCH ###
}


############################################################################
# Subroutine: parseConditions ()
# This will go through the list of conditional configuration statements
# in the order that they appeared in the config file. It'll see if the
# condition is true, and if so set the specified config values.
############################################################################
sub parseConditions {
	($debug) && (print STDERR "parseConditions (@_) \@ " . time . "\n");
	my ($result, $part, @parts, $opens, $closes, $set, $cond, $toValue);
	my ($tmp, $op, $field, $val) = "";
	my $condCnt = 0;

	### Run through the list of conditions.                              ###
	while ($condCnt < scalar(@conditions)) {
		$_ = $conditions[$condCnt];
		### Initially break up the conditions.                           ###
		/^([^\:]*[^\s:])\s+then\s+([^:]*[^\s:])\s*:\s*(.*[\S])\s*/i;
		$cond = $1;
		$set = $2;
		$toValue = $3;

		$debug && print STDERR "[$cond] [$set] [$toValue]\n";
		### Perform some validation checks on the statement.             ###
		fatal ("Don't use nested conditionals in <B>$_ </B>") 
			if ($set =~ /(if|unless)/i);
		$opens = tr/(/(/;
		$closes = tr/)/)/;
		fatal("Mismatched parentheses <B>in $cond </B>") 
			if ($opens != $closes);
		$tmp = $cond;
		$tmp =~ s/\&\&|\|\|//g;
		failSecurity("<B>$cond </B>contains unamtched &#124;s and &amp;s") 
			if ($tmp =~ /&|\|/);
		fatal ("Too many quote marks in a configuration line <B> $_ </B>")
			if (($toValue =~ tr/"/"/) > 2);

		### Some values can contain other config and form values, but    ###
		### NOT ALL. Why? Paranoid security and I really can't see a use ###
		### for changing the others.                                     ###
		if ($toValue =~ /^"[^"]*"\s*$/ &&
			$set =~ /$replaceable/ix) {
			$toValue = replacer($toValue, $set);
		}

		### Now break into smaller parts and security check.             ###
		my @conBits = split (/\(\s*|\)\s*|\&\&\s*|\|\|\s*/, $cond);

		### Each part should be of the form:                             ###
		### field op token      OR      field                            ###
		### where field is a field name from the form, op is a boolean   ###
		### operator and token is some alphanumeric.                     ###
		while (scalar(@conBits)) {
			### Have to put the scalar in to cope with null list values. ###
			$part = shift(@conBits);
			next unless ($part =~ /\S/);
			$field = $op = $val = '';
			$_ = $part;
			$debug && print STDERR "Looking at condition $_ \n";
			
			if (/^("[^"]+"|'[^']+'|[\S]+)\s+([\S]+)\s+
				("[^"]+"|'[^']+'|[\S]+)\s*$/x) {
    
				### Dealing with a boolean expression.                   ###
				$result = '0';
				$field = $1;
				$op = lc($2);
				$val = $3;
				$field =~ s/^"([^"]+)"/$1/ unless ($field =~ s/^'([^']+)'/$1/);
				$val =~ s/^"([^"]+)"/$1/ unless ($val =~ s/^'([^']+)'/$1/);
				securityName($field) unless 
					($field =~ /^\$((http|cookie)_[\w\-]+|counter_(\d+))/i);;

				### Check the operator is OK. Note the new operators...  ###
				### has and hasnt. this sees if a multiple selection     ###
				### has or hasn't a value.                               ###
				failSecurity("Can't use <B>${op}</B> in a condition")
					unless ($op =~ /^(has(nt)?|[=!]=|eq|ne|[<>]|
									[gl]t|[<>]=|[gl]e|contains)$/x);

				### Now see if field is something out of the form.       ###
				if ($op =~ /^has/) {
					$val =~ s/[^\w\.\-\s]//g;
					if ($field =~ /^\$cookie_([\w\-]+)/) {
						$result = '1' if ($query->cookie($1) eq $val);
					} elsif ($field =~ /^\$(http_[\w\-]+)/i) {
						$result = '1' if (getHttpValue($1) eq $val);
					} elsif ($field =~ /^\$counter_(\d+)/i) {
						$result = '1' if 
							($CONFIG{'counter'}->{"${1}value"} eq $val);
					} else {
						foreach ($query->param($field)) {
							$result = '1',last if ($_ eq $val);
						}
					}
					$result = !$result if ($op =~ /nt/);
				} elsif ($op =~ /^contains/) {
					### Escape out potential regexp characters           ###
					$val =~ s/([\\\/\[\]\?\.\*\!\^\$\(\)])/\\$1/g;
					if ($field =~ /^\$cookie_([\w\-]+)/i) {
						$field = $query->cookie($1);
						$result = ($field =~ /$val/i);
					} elsif ($field =~ /^\$(http_[\w\-]+)/i) {
						$field = getHttpValue($1);
						$result = ($field =~ /$val/i);
					} elsif ($field =~ /^\$counter_(\d+)/i) {
						$result = 
							($CONFIG{'counter'}->{"${1}value"} =~ /$val/i);
					} else {
						foreach ($query->param($field)) {
							$result = '1',last if (/$val/i);
						}
					}
				} else {
					if ($field =~ /^\$cookie_([\w\-]+)/i) {
						$field = $query->cookie($1);
					} elsif ($field =~ /^\$(http_[\w\-]+)/i) {
						$field = getHttpValue($1);
					} elsif ($field =~ /^\$counter_(\d+)/i) {
						$field = $CONFIG{'counter'}->{"${1}value"};
					} else {
						$field = $query->param($field);
					}
					$field =~ s/[^\w\.\-\s]//g;
					### Single quote strings to stop them being 'eval'ed ###
					$field = "'${field}'" unless ($field =~ /^\d+$/);
					$val = "'$val'" unless ($val =~ /^\d+$/);
					$result = eval "$field $op $val";
				}
			} elsif (/^\s*("[^"]+"|'[^']+'|\S+)\s*$/) {
				### Does the field exist?                                ###
				$field = $1;
				$field =~ s/^"([^"]+)"/$1/ unless 
					($field =~ s/^'([^']+)'/$1/);
				if ($field =~ /^\$cookie_([\w\-]+)/i) {
					$result = defined $query->cookie($1) ? 1 : 0;
				} elsif ($field =~ /^\$(http_[\w\-]+)/) {
					$result = (getHttpValue($1) != "") ? 1 : 0;
				} elsif ($field =~ /^\$counter_(\d+)/i) {
					$result = ($CONFIG{'counter'}->{"${1}value"}) ? 1 : 0;
				} else {
					securityName($field);
					$result = (defined $query->param($field)) ? 1 : 0;
				}
			} else {
				fatal("Bad conditional <B>$_</B>");
			}

			$result = '0' if ($result != 1);
			$part =~ s/([^\w\.\-\s])/\\$1/g;
			$cond =~ s/$part/$result /;
			$result = '0';
		}

		eval {$cond = eval "$cond"};
		if ($condTypes[$condCnt]) {
			setConfig($set, $toValue) unless ($cond);
		} else {
			setConfig($set, $toValue) if ($cond);
		}
		$condCnt = $condCnt + 1;
	}
}


############################################################################
# Subroutine: replacer ( string_containing_things_to_replace )
# The aim here is to do robust replacement of values from the user's form
# (anything that starts with '$form_') most of the http_ variables that
# can be used in output tags (things starting '$http_'), cookie values
# (anything starting with '$cookie_') and some
# special ones like $subject, $sendersubject, $replyto, $mailto...
# All the replacement values must appear in a double quoted string.
############################################################################
sub replacer {
	($debug) && (print STDERR "replacer (@_) \@ " . time . "\n");
	my $toValue  = shift;
	my $setValue  = shift;
	$toValue     =~ s/^"(.*)"\s*$/$1/;
	my $tmpString = "";
	my @chunks = split(/((?:(?:\$form|\$http|\$cookie)_[\w-]+)|
						\$mailto|\$(?:sender)?subject|\$(?:sender)?replyto|
						\$counter_\d+)/ix, $toValue);

	### Now look through what we've got.                                 ###
	for (@chunks) {
		if (/^\$(((form|http|cookie)_[\w-]+)|
					mailto|(sender)?subject|(sender)?replyto|
					counter_\d+)/ix) {
			my $replaceStr = "";
			if (/^\$form_([\w-]+)/i) {
				### This is a value from the submitted form.             ###
				$replaceStr = $query->param($1);
			} elsif (/^\$counter_\d+/i) {
				### This is one of the http variables.                   ###
				$needToReplace{lc($setValue)} = 1;
				$replaceStr = $_;
			} elsif (/^\$(http_[\w\-]+)/i) {
				### This is one of the http variables.                   ###
				$replaceStr = getHttpValue($1);
			} elsif (/^\$cookie_([\w-]+)/i) {
				### This is a cookie value.                              ###
				$replaceStr = $query->cookie($1);
			} else {
				/^\$(.*)/;
				$replaceStr = $CONFIG{lc($1)};
			}
			$replaceStr =~ s/\s/ /g;
			$tmpString .= $replaceStr;
		} else {
			$tmpString .= $_;
		}
	}
	return $tmpString;
}


############################################################################
# Subroutine: getHttpValue ( string_to_match )
# Given a string starting with 'http_', this will return an appropriate
# value from the CGI environment, or an emprty string if it doesn't 
# recognise what was passed in.
############################################################################
sub getHttpValue {
	($debug) && (print STDERR "getHttpValue (@_) \@ " . time . "\n");
	$_ = shift;
	if (/^http_(remote_user|remote_addr|remote_ident|remote_host|
	            server_name|server_port)$/xi) {
		return($ENV{"\U$1\E"});
	}
	if (/^(http_(user_agent|referer|from|host))$/i) {
		return($ENV{"\U$1\E"});
	}
	if (/^http_time/) {
		return(translateFormat("%hhhh%:%mm%:%ss%"));
	}
	if (/^http_date/) {
		return(translateFormat("%ddd% %mmmm% %dd% %yyyy%"));
	}
	if (/^http_ref/) { return($CONFIG{'ref'}); }
	return "";
}


############################################################################
# Subroutine: checkEmail ( email_address )
# Found a flaw in the email handling, so check that email addresses are
# correct... or at least contain reasonable characters
# The flaw would fail because the email had mismatched < brackets
############################################################################
sub checkEmail {
	($debug) && (print STDERR "checkEmail (@_) \@ " . time . "\n");
	$_ = shift;
	my ($opens, $closes);
	$opens = tr/</</; 
	$closes = tr/>/>/;
	fatal("Malformed Email in <B>$_ </B>") if 
		($opens != $closes || $opens > 1 || $opens == 1 && !/^<.*>$/);
	s/</&lt;/, fatal("Can't handle email type <B>$_ </B>") if 
		(/[^,\'\w\-\.\@\/\!\%\:\<\>\s\xc0-\xd6\xd8-\xf6\xf8-\xff ]/);
}


############################################################################
# Subroutine: fatal (msg)
# Takes a string message and makes a HTML failure page.
############################################################################
sub fatal {
	($debug) && (print STDERR "fatal (@_) \@ " . time . "\n");
	my ($msg) = @_;
	print "Content-type: text/html$CRLF$CRLF";
	print <<"	EOT";
	<HTML><HEAD><TITLE>Fatal Error</TITLE></HEAD>
	<BODY>
	<H1>Error:</H1>
	The soupermail CGI died due to the following error:<P>
	<BLOCKQUOTE>
	$msg
	</BLOCKQUOTE>
	<HR>
	Check your soupermail configuration or contact: 
	<A HREF="mailto:$soupermailAdmin">$soupermailAdmin</A> 
	informing them of the error, and how and where it occured.<P>
	<HR>
	<P>
	Soupermail Release Version $relVersion
	</P>
	</BODY></HTML>
	EOT
	cleanScratch();
	exit;
}


############################################################################
# Subroutine: securityFilename ( path_to_check )
# Exit the script if a filename contains ..'s or other potentially nasty
# characters.
############################################################################
sub securityFilename { 
	($debug) && (print STDERR "securityFilename (@_) \@ " . time . "\n");
	my ($filename) = shift;
	if ($filename =~ /\.\.|\~|[^\w\.\-\/:]/) {
		failSecurity("Filename $filename contains a .. " .
						" or other illegal characters");
		cleanScratch();
		exit;
	}
}


############################################################################
# Subroutine: securityName ( form_name_to_check )
# Exit the script if a given string contains shell meta characters
############################################################################
sub securityName {
	($debug) && (print STDERR "securityName (@_) \@ " . time . "\n");
	$_ = shift;
	my ($isrequired) = shift;
	my ($opens, $closes);
	my ($name) = $_;
	if ($isrequired) {
		### Required names can have brackets, &&s and ||s in, so strip   ###
		### them from the name before checking and ensure they all match ###
		### up.                                                          ###
		$opens = tr/(//d;
		$closes = tr/)//d;
		fatal("Mismatched parentheses in <B>$name </B>") if 
			($opens != $closes);
		### Make sure people are only putting proper numbers of          ###
		### ampersands in!                                               ###
		s/&&|\|\|//g;
	}
	if (s!([^"'\w\s\.\-])!<font color="#ff0000"><b>$1</b></font>!g) {
		failSecurity ("$_ contains an insecure string such as a " .
						"shell meta character. Please use another string " .
						"containing only alphanumerics\n");
		cleanScratch();
		exit;
	}
}


############################################################################
# Subroutine: failSecurity ( failure_message )
# Something has failed a security check, so bomb out with a failure message
############################################################################
sub failSecurity {
	($debug) && (print STDERR "failSecurity (@_) \@ " . time . "\n");
	my ($msg) = shift;
	print $query->header();
	print "<HTML> <HEAD> <TITLE>Form Response</TITLE> </HEAD>\n";
	print "<BODY> <H1>Sorry</H1>\n";
	print "The form failed a security check.\n";
	if ($msg) {
		print "<P><H2>Failure Message:</H2><BR>\n$msg\n";
	}
	print "</BODY> </HTML>\n";
	cleanScratch();
	exit;
}


############################################################################
# Subroutine: nukeValues ()
# This goes through all the form values, removing blank values and stripping
# leading and trailing space characters. Care is taken not to munge up 
# files that have been submitted using file upload.
############################################################################
sub nukeValues {
	($debug) && (print STDERR "nukeValues (@_) \@ " . time . "\n");
	no strict 'refs';
	my (@vals, @newvals, $val);
	foreach $val ($query->param()) {
		undef @newvals;
		@vals = $query->param($val);
		foreach (@vals) { 
			### Skip stripping for file upload fields.                   ###
			if (fileno($_)) { push(@newvals, $_); next; }
			s/^\s*([\S][\s\S]*)/$1/;
			s/([\s\S]*[\S])\s*$/$1/;
			push (@newvals, $_) if /\S/;
		}
		$query->delete($val) unless (@newvals);
		$query->param($val, @newvals);
	}
}


############################################################################
# Subroutine: formIsBlank ()
# Return TRUE if the form is blank (i.e. has no non-ignored fields filled 
# in)
############################################################################
sub formIsBlank {
	($debug) && (print STDERR "formIsBlank (@_) \@ " . time . "\n");
	my (%names, $name, @vals);
	foreach ($query->param()) {
		@vals = $query->param($_);
		$names{$_} = ($#vals < 0) ? 0 : 1;
	}
	foreach $name (@ignored) {
		delete $names{$name};
	}
	return(!keys(%names));
}


############################################################################
# Subroutine: formMissingRequired ()
# Check that all the required bits have been filled in in the form.
# This bit is liable to change to add more complex behaviour
# Returns TRUE if the form has any missing bits
############################################################################
sub formMissingRequired {
	($debug) && (print STDERR "formMissingRequired (@_) \@ " . time . "\n");
	my ($name, $requiredline, @requirednames, $replacement, $missing,
		$oldname);
	my (@vals);
	foreach $requiredline (@required) {
		@requirednames = split (/\(\s*|\)\s*|\&\&\s*|\|\|\s*/,$requiredline);
		foreach $name (@requirednames) {
			### Strip off leading and trailing whitespace.               ###
			$oldname = $name;
			$name =~ s/\s*([\"\'\w\.\-\s]*[\"\'\w\.\-]+)\s*$/$1/;
			$name =~ s/^"([^"]+)"/$1/ unless ($name =~ s/^'([^']+)'/$1/);
			$requiredline =~ s/$oldname/$name/;
			if ($name ne "") {
				@vals = $query->param($name);
				$replacement = ($#vals < 0) ? 0 : 1;
				$requiredline =~ s/$name/$replacement/;
			}
		}
		eval "if ($requiredline) {\$missing = \"0\"} else {\$missing = \"1\"}";
		last if ($missing);
	}
	return($missing);
}


############################################################################
# Subroutine: badTypes ( type_list )
# Check that the given datatypes for various fields are correct. Expects
# an array of type, value pairs to be passed in. Returns true if there
# are incorrect types.
############################################################################
sub badTypes {
    my $toCheck = shift;
    foreach (@$toCheck) {
	    my ($type, $name) = @$_;
		my $v;
		foreach $v ($query->param($name)) {
		    if (checkType($type, $v)) { return 1; }
		}
	}
	return 0;
}


sub checkType {
    my $type = shift;
	my $v = shift;
	my $r = 1;
	$type =~ s/^is//;
	if ($type =~ s/^not//) { $r = 0; }
	return 0 unless $v;
	if ($type eq 'number') {
	    if ($v !~ /^-?\d*(\.\d*)?$/) { return $r; }
	} elsif ($type eq 'integer') {
	    if ($v !~ /^-?\d*(\.0*)?$/) { return $r; }
	} elsif ($type eq 'email') {
	    if ($v !~ /^[\w\-\.\+\/\\\xc0-\xd6\xd8-\xf6\xf8-\xff ]+
		          \@[A-Za-z\d][\-\w]*[A-Za-z\d]
	        (\.[0-9A-Za-z][\-\w]*[A-Za-z\d])*$/x) { return $r; }
	} elsif ($type eq 'creditcard') {
		$v =~ s/\D//g;
		if (length($v) < 13) { return $r; }
		my ($sum, $i) = 0;
		foreach (reverse split(//, $v)) {
		    my $s = $_ * (1 + $i++ % 2);
			$sum += $s - ($s > 9 ? 9 : 0);
		}
		if ($sum % 10) { return $r; }
	} 
	return !$r;
}

############################################################################
# Subroutine: returnHtml ( redirection_URL,
#                           template_pathname,
#                           return_message,
#                           boolean_replace_output_tags_flag,
#                           boolean_send_out_cookies_flag,
#                           boolean_is_pdf)
# General routine to output HTML back to the browser.
############################################################################
sub returnHtml {
	($debug) && (print STDERR "returnHtml (@_) \@ " . time . "\n");
	my ($redirect, $template, $msg, $do_substitute, $do_cookie, $isPdf) = @_;
	my ($outstring);
	my @cookiesToGo = ();
	my $newCookie;

	### This goes throught the cookie settings generating CGI.pm cookie  ###
	### objects.                                                         ###
	if ($do_cookie && @cookieList) {
		my $i = 0;
		while ($i < 3) {
			if ($cookieList[$i]) { 
				my %cookieVals = %{$cookieList[$i]};
				$i++,next unless ($cookieVals{"value"});
				$newCookie = $query->cookie(-name=>$cookieVals{"name"},
											-expires=>$cookieVals{"expires"},
											-value=>$cookieVals{"value"},
											-domain=>$cookieVals{"domain"},
											-path=>$cookieVals{"path"},
											-secure=>$cookieVals{"secure"});
				push(@cookiesToGo, $newCookie);
			}
			$i++;
		}
	}

	### Handle redirects or send the output from a template or default   ###
	### message.                                                         ###
	if ($redirect) {
		if (@cookiesToGo) {
			print $query->redirect(-URL=>$redirect, -cookie=>\@cookiesToGo);
		} else {
			print $query->redirect($redirect);
		}
	} else {
		if ($template) {
			my $ct = "text/html";
			my $pdfName = "";
			grabFile($template, \$outstring);
		    if ($isPdf) {
			    $ct = "application/pdf";
			    ($do_substitute) && (substOutput(\$outstring, '4'));
				$pdfName = $CONFIG{'pdftemplate'};
				$pdfName =~ s!/.*?([^/]+)(\.[^/]*)$!$1\.pdf!;
			} else {
			    ($do_substitute) && (substOutput(\$outstring, '1'));
			}
			if (@cookiesToGo) {
				print $query->header(
							 -cookie=>\@cookiesToGo, 
							 -type=>"$ct;name=$pdfName",
							 -Content-Disposition=>"file;filename=$pdfName"); 
			} else {
				print $query->header(-content_type=>$ct);
			}
			if ($isPdf) {
				my $pdfFile = makePdf(\$outstring, $pdfName, 1);
				open (PDF, "<$pdfFile");
				while (<PDF>) {
					print;
				}
				close(PDF);
			} else {
			   print $outstring;
			}
		} else {
			if (@cookiesToGo) {
				print $query->header(-type=>'text/html',
									-cookie=>\@cookiesToGo); 
			} else {
				print $query->header();
			}
			print "<HTML> <HEAD> <TITLE>Form Response</TITLE> </HEAD>\n";
			print "<BODY> $msg\n";
			print "</BODY> </HTML>\n";
		}
	}
}

############################################################################
# Subroutine: grabFile (filename, stringRef)
# Reads a file (usually a template) and places its contents in the thing
# specified by stringRef
############################################################################
sub grabFile {
	my ($file, $buffer) = @_;
	my @stats = stat($file);
	open (FILE, "<$file") || 
		fatal("Failed to open <B>$file</B>");
	read(FILE, $$buffer, $stats[7]);
	close(FILE);
}

############################################################################
# Subroutine: returnBlank ()
# If the form was blank, produce a www page saying so
############################################################################
sub returnBlank {
	($debug) && (print STDERR "returnBlank (@_) \@ " . time . "\n");
	my ($msg) = "<H1>Sorry</H1>\n";
	$msg .= "You did not enter any form fields so the form was not submitted";
	returnHtml($CONFIG{'gotoblank'}, $CONFIG{'blank'}, $msg, 1, 
				$CONFIG{'blankcookie'});
}


############################################################################
# Subroutine: returnExpired
# The form is out of date, so return a page saying so.
############################################################################
sub returnExpired {
	($debug) && (print STDERR "returnExpired (@_) \@ " . time . "\n");
	my $msg = "<h1>Sorry</h1>The Form is now out of date. Your " .
				"information was not submitted.\n";
	my $goto = $CONFIG{'gotoexpires'} ? $CONFIG{'gotoexpires'} : '0';
	my $template = $CONFIG{'expirestemplate'} ? 
		$CONFIG{'expirestemplate'} : '0';
	returnHtml($goto, $template, $msg, 1, $CONFIG{'expirescookie'});
}


############################################################################
# Subroutine: returnFailure ()
# Return a failure page indicating that some required fields are missing
############################################################################
sub returnFailure {
	($debug) && (print STDERR "returnFailure (@_) \@ " . time . "\n");
	my $msg = "<H1>Sorry</H1>\n" .
			  "You did not complete all the required sections of the\n" .
			  "form.<BR>Use your browser's BACK button to return to the\n".
			  "form and complete the missing fields.\n";
	my $goto = $CONFIG{'gotofailure'} ? $CONFIG{'gotofailure'} : '0';
	my $template = $CONFIG{'failure'} ? $CONFIG{'failure'} : '0';
	returnHtml($goto, $template, $msg, 1, $CONFIG{'failurecookie'});
}


############################################################################
# Subroutine: returnSuccess ()
# The form has been successfully completed, so return a www page saying so
############################################################################
sub returnSuccess {
	($debug) && (print STDERR "returnSuccess (@_) \@ " . time . "\n");
	my $msg = "<H1>Thank You</H1>Your information has been submitted\n";
	my $goto = $CONFIG{'gotosuccess'} ? $CONFIG{'gotosuccess'} : '0';
	my $template = $CONFIG{'success'} ? $CONFIG{'success'} : '0';

	if (!$template && $CONFIG{'pdftemplate'}) {
	    returnHtml($goto, $CONFIG{'pdftemplate'}, $msg, 1, 
		           $CONFIG{'successcookie'}, 1);
	} else {
	    returnHtml($goto, $template, $msg, 1, $CONFIG{'successcookie'});
	}

	### Hmm, for user percieved speed, does closing STDOUT now help?     ###
	close(STDOUT);
	if ($CONFIG{'mailto'} || $CONFIG{'returntosender'} || 
		$CONFIG{'sendertemplate'} || $CONFIG{'htmlsendertemplate'} ||
	    $CONFIG{'pdfsendertemplate'} || $CONFIG{'pdfmailtemplate'}) {
		$debug && print STDERR "About to mailResults\n";
		mailResults();
	}

	if ($CONFIG{'fileto'}) {
		saveResults();
	}
}



############################################################################
# Subroutine: translateFormat ()
# Take a format string and return the expanded output.
############################################################################
sub translateFormat {
	($debug) && (print STDERR "translateFormat (@_) \@ " . time . "\n");
	my ($format) = shift;
	my ($mm, $mmm, $mmmm, $yy, $yyyy, $hh, $hhhh, $ss, $dd, $ddd);
	my ($maxfactor) = 12; ### :-)
	my ($randomno);
	my ($currtime) = scalar (localtime(time));

	$currtime =~ /^(\w+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)/;
	$ddd = $1;
	$mmmm = $2;
	$mmm = $MONTHS{$mmmm};
	$dd = $3;
	$hhhh = $4;
	$mm = $5;
	$ss = $6;
	$hh = ($hhhh > 12) ? ($hhhh - 12) : $hhhh;
	$yyyy = $7;
	$yyyy =~ /(\d\d)$/;
	$yy = $1;
	$hh = "0$hh" if (length($hh) == 1);
	$mm = "0$mm" if (length($mm) == 1);
	$ss = "0$ss" if (length($ss) == 1);
	$dd = "0$dd" if (length($dd) == 1);
	$yy = "0$yy" if (length($yy) == 1);
	$format =~ s/%yyyy%/$yyyy/gi;
	$format =~ s/%hhhh%/$hhhh/gi;
	$format =~ s/%ddd%/$ddd/gi;
	$format =~ s/%mmmm%/$mmmm/gi;
	$format =~ s/%mmm%/$mmm/gi;
	$format =~ s/%mm%/$mm/gi;
	$format =~ s/%dd%/$dd/gi;
	$format =~ s/%yy%/$yy/gi;
	$format =~ s/%ss%/$ss/gi;
	$format =~ s/%hh%/$hh/gi;
	$format =~ s/%counter_(\d+)%/$CONFIG{"counter"}->{"${1}value"}/gi;
	while ($format =~ /%(r{1,$maxfactor})%/) {
		my ($tmp) = $1;
		$randomno = rand (10 ** length($tmp));
		$randomno = int (10 ** $maxfactor + $randomno);
		$randomno = substr ($randomno, length($randomno) - length($tmp) );
		$format =~ s/%${tmp}%/${randomno}/;
	}

	return $format;
}


############################################################################
# Subroutine: showFile ( filename )
# Make a OS specific call to show a given file for the webserver...
# unhides under NT, chmods it under UNIX
############################################################################
sub showFile {
	($debug) && (print STDERR "showFile (@_) \@ " . time . "\n");
	my $filename = shift;
	no strict 'subs';
	if ($OS eq "windows") {
		Win32::File::SetAttributes($filename, Win32::File::NORMAL)
	} else {
		if ($CONFIG{"cgiwrappers"}) {
			chmod 0644, $filename;
		} else {
			chmod 0666, $filename;
		}
	}
}



sub makeScratch() {
	($debug) && (print STDERR "makeScratch (@_) \@ " . time . "\n");
    if ($CONFIG{'pgpuserid'} || $CONFIG{'filepgpuserid'} ||
	    $CONFIG{'pdfsendertemplate'} || $CONFIG{'pdfmailtemplate'} ||
		$CONFIG{'pdftemplate'}) {
        if ($OS eq "windows") {
            my $rand = "$$" . int(rand(99999999));
            $rand =~ s/(.{8}).*/$1/;
            $scratchPad = "${tempDir}$rand";
        } else {
            $scratchPad = "${tempDir}soupermail$$" . int(rand(99999999));
		}
	    fatal("Unable to create unique tmp directory <B>$scratchPad </B>") 
 		    if (-e $scratchPad || -d $scratchPad || -l $scratchPad);

	    umask(011);
	    mkdir($scratchPad, 0766) || fatal("can't create tmp area $scratchPad");
	}
}

sub cleanScratch {
	($debug) && (print STDERR "cleanScratch (@_) \@ " . time . "\n");
	### Clean up the temp scratch pad directory.                         ###
    if ($CONFIG{'pgpuserid'} || $CONFIG{'filepgpuserid'} ||
	    $CONFIG{'pdfsendertemplate'} || $CONFIG{'pdfmailtemplate'} ||
		$CONFIG{'pdftemplate'} && -d $scratchPad) {
	    ($debug) && (print STDERR "Cleaning $scratchPad\n");
	    opendir (DIR, $scratchPad);
	    my $item;
	    my @items = readdir(DIR);
	    closedir(DIR);
	    while ($item = shift (@items)) {
		    if ($item =~ /^[^\.]/ && -f "${scratchPad}/$item") {
			    unlink("$scratchPad/$item");
		    }
	    }
		if (-d $scratchPad) {
			chdir ($tempDir);
	    	rmdir ($scratchPad) ||
			    (($debug) && print STDERR "Unable to remove $scratchPad $!\n");
		}
	}
}



############################################################################
# Subroutine: doCounters ( mode_type )
#
# Look through the available counters, setting those that need to be set
# based on the given mode.
############################################################################

sub doCounters {
	my $counters = $CONFIG{"counter"};
	my $mode = shift;
    my ($n, $v);
	while (($n, $v) = each %$counters) {
		if ($n =~ /(\d+)on$mode/ && $v) {
			setCounter($1);
		}
	}
}

############################################################################
# Subroutine: setCounter ( counter_number )
#
# Take a counter from the counter hash and increase its value by whatever
# step is defined (or one if undefined)
############################################################################

sub setCounter {
	my $counterNum = shift;
	my $counterValue = $CONFIG{"counter"}->{"${counterNum}value"} +
					   $CONFIG{"counter"}->{"${counterNum}step"};

	if ($CONFIG{"counter"}->{"${counterNum}set"} ||
		$CONFIG{"counter"}->{"${counterNum}set"} eq "0") {
		$counterValue = $CONFIG{"counter"}->{"${counterNum}set"}
	}
	$CONFIG{"counter"}->{"${counterNum}value"} = $counterValue;

	if ($CONFIG{"counter"}->{"${counterNum}file"}) {
		open(COUNTER, ">" . $CONFIG{"counter"}->{"${counterNum}file"});
		print COUNTER $counterValue;
		close (COUNTER);
	}
}



__END__

=head1 NAME

Soupermail - a generic CGI WWW form handler written in Perl


=head1 SYNOPSIS

E<lt>form method="post" action="/cgi-bin/soupermail.pl"E<gt>

=head1 DESCRIPTION

Soupermail is a generic HTML form handling script designed to provide a
high degree of control over a form's behaviour and output. It provides the 
following features:

=over 4

=item * Email the contents of a form to one or more email addresses

=item * Expire a form based on the date

=item * Handle blank forms intelligently

=item * Limited conditional control based on the form's contents

=item * HTML and text templates

=item * Copy the form email to the form's sender

=item * PGP encrypt resulting emails (requires PGP 5 or GNUPG installed)

=item * Write the contents of a form to a file

=item * Write the encrypted contents of a form to a file

=item * Generate a unique reference number for each submission

=item * Set certain form fields as required

=item * Word wrap resulting emails

=item * Handle file uploads, and send them on as MIME attachments

=item * Access CGI variables through templates

=item * Set cookies and display cookies by using templates

=item * Send the form's submitter a formatted reply

=item * Set any number of counter files up on the server

=item * Send mail as HTML and/or plain text 

=item * Act as a frontend for PDF generation with Lout and GhostScript

=item * Attach files to outgoing emails

=item * Validate form fields

=back

Soupermail can be used to handle single standalone forms, or generate and
control complex multipart forms.

=head1 RESTRICTED FORM FIELDS

Soupermail assumes some form fields have special meanings. These field names
ARE CASE SENSITIVE. The following is a list of such fields:

=over 4

=item B<Email>

Assumed to be the email address of the form's sender. Needed if the email is to
be copied to the sender, or you are using a B<sendertemplate>.

=item B<SoupermailConf>

This is a path to the configuration file that controls soupermail. The path
can either be relative to the location of the form, or an absolute path
from the webserver's root. If you are using soupermail to generate multipart
forms, it is recommended that you use absolute paths.


=back


=head1 CONFIGURATION FILES

Soupermail is controlled on a per form basis by using B<configuration files>.
Each form handled by soupermail must have an associated configuration file. 

The location of the file is passed to soupermail through the PATH_INFO CGI
variable, or by using 'SoupermailConf' as a form parameter. 
The PATH_INFO is set by providing a path after the call to soupermail
in the <form> element of the HTML page.

eg. If a form has a configuration file in F</forms/config.txt>, the form
should call soupermail with

E<lt>C<form method="post" action="/cgi-bin/soupermail.pl/forms/config.txt">E<gt>

or as a form variable with:

E<lt>C<input type="hidden" name="SoupermailConf" value="/forms/config.txt">E<gt>

The path to the configuration file must be relative to the web server's 
root directory. Do not use URLs or absolute paths to the configuration file.

The format for a configuration file is a series of configuration
statements of the form:

=over 4

=item

C<I<name> : I<value>>

or

C<if I<condition> then name : I<value>>

or

C<unless I<condition> then I<name> : I<value>>

=back

If a badly phrased or incorrect configuration file is passed to soupermail,
it will complain, so always check your soupermail configurations carefully.

Valid I<names> for the configuration file are:

=over 4

=item B<attachmentI<X>>

Files can be attached to email sent with B<sendertemplate> and 
B<htmlsendertemplate>. B<I<X>> is a number identifying the attachment.

=over 4

=item eg. 

C<attachment1 : /forms/download/myfile.pdf>
C<attachment3 : file2.doc>

=back

=item B<attachmentI<X>mime>

Since Soupermail doesn't know about MIME types, you may want to set a
specific MIME type for an attachment so receiving mail clients know how
to deal with them. By default, Soupermail sends text attachments as
text/plain and binary attachments as application/octet-stream.

=over 4

=item eg. 

C<attachment2 : /wordfile.doc>
C<attachment2mime : application/x-msword>
C<attachment5 : /forms/download/myfile.pdf>
C<attachment5mime : application/pdf>

=back


=item B<blank>

A template file to return to the user if they submitted a blank form

=over 4

=item eg. 

C<blank : /forms/config/blank.tpl>

=back

=item B<cgiwrappers>

If you are running Soupermail in a CGI wrappers type environment, where 
Soupermail's running with its owner's permissions rather than the webserver's
permissions, setting cgiwrappers to C<yes> will make the
C<filereadable> config command actually work.

=item B<cookie[123]domain>

This specifies the domain name that the cookie will be sent to. By default,
no domain is specified for a cookie. See the section on L<COOKIES> for
more information.

=over 4

=item eg.

C<cookie1domain : myhost.domainname.com>

Will only send cookie1 to pages on the myhost.domainname.com webserver. See
the section on L<COOKIES> for more information.

=back

=item B<cookie[123]expires>

A date or time format indicating when one of the three available cookies
expires. Allowable formats can be relative. eg. +1h means one hour from
now, -2d means 2 days ago. The time periods allowable are s = second, 
m = minute, h = hour, d = day, M = month, y = year.

Absolute dates and times can also be specified.

See the section on L<COOKIES> for more information. 

=over 4

=item eg.

cookie1expires : 1-4-1999 12:00:00

will expire the first cookie at midday on 1 April 1999.

cookie2expires : +1M

will expire the second cookie one month from when the form was submitted

=back

By default, cookies expire 24 hours from when they were set.

=item B<cookie[123]name>

This sets the name of one of the three available cookies to a value. See the
section on L<COOKIES> for more information.

=over 4

=item eg.

cookie1name: zippy

sets the first cookie's name to 'zippy'

=back

=item B<cookie[123]path>

This specifies which pathnames a cookie will be sent to. By default, this
will be to the location where soupermail is stored. See the section on
L<COOKIES> for more information.

=over 4

=item eg.

C<cookie3path : /products>

Would only send cookie 3 to pages below the /products directory of a website.

=back

=item B<cookie[123]secure>

This is a yes or no value that specifies whether a cookie will be sent over
all connections, or just secure SSL connections. See the section on 
L<COOKIES> for more information.

=item B<cookie[123]value>

This sets the value of one of the three available cookies. See the section
on L<COOKIES> for more information.

=item B<cookieonblank>

If set to yes, this will send cookies when a blank form is detected.

=item B<cookieonexpires>

When set to yes, this will send cookies when a submission past an
expires date is sent.

=item B<cookieonfailure>

When this is set to yes, cookies will be sent out even if the form
has been considered a failure.

=item B<cookieonsuccess>

When set to yes, cookies are sent out when the form is considered a
success. This is the default behaviour.

=item B<counterI<X>file>

Each counter is stored on the webserver in a single file. The file simply
contains a number and should be specified in a directory that's writable by
the webserver. When a counterfile line is read into the config file, the
counter's value is made available for later use in the config file. See
L<COUNTERS> for more information.

=item B<counterI<X>onblank>

If set to C<yes>, this specifies that counter I<X> will be incremented
if a blank form is submitted.

=item B<counterI<X>onexpires>

If set to C<yes> this specifies that counter I<X> will be incremented
if the form is submitted after its expiry date.

=item B<counterI<X>onfailure>

If set to C<yes> this specifies that counter I<X> will be incremented
if the form is missing required fields.

=item B<counterI<X>onsuccess>

If set to C<yes> this specifies that counter I<X> will be incremented
if the form is submitted successfully. The default to increase the conter
by is 1.

=item B<counterI<X>step>

This is a positive integer value that specifies how much counter I<X>
should be increased by.

=item B<expires>

A date of the format dd-mm-yyyy after which the form cannot be submitted

=over 4

=item eg.

C<expires : 24-12-1998>

=back

This means the form would not be submittable after the 24st of December 1998

=item B<expirestemplate>

A template file to use if the form has been submitted after its B<expires>
date. See the section on L<TEMPLATES> for more information.

=item B<failure>

A template to return to the user if they have not completed all the required
fields of a form. See the section on L<TEMPLATES> for more information.

=over 4

=item eg.

C<failure : /forms/config/bad.tpl>

=back

=item B<fileattop>

When writing the contents of a form to a file, new data is usually placed
at the end of the file. By setting B<fileattop>, new data can be written
at the start of the file (although after any specified header).

=over 4

=item eg.

C<fileattop : yes>

=back

=item B<filebackupformat>

This specifies a filename for backup files to be written into if a soupermail
generated file will grow over a B<filemaxbytes> limit.

The value for this can include formatting codes as listed in the
L<FORMATS> section of this document. This lets you generate a number of backups
with a very fine level of detail.

The value specified in B<filereadable> will affect any backup files generated.

=over 4

=item eg.

C<filebackupformat: /files/backup.txt>

would always backup the file to /files/backup.txt

C<filebackupformat: /files/%yyyy%%mmm%%dd%backup.txt>

would backup to /files/19980801backup.txt on 1 August 1998.

=back

=item B<filemaxbytes>

This specifies the maximum size a soupermail generated file can grow to in
bytes. If a new addition would cause the generated file to grow over
B<filemaxbytes>, then the file will be cleared of all other entries.

If you would like to save backup copies of the file, rather than simply
deleting it, specify a B<filebackupformat> as described above.

To force a deletion after each entry, set the filemaxbytes to 1. Note that
setting it to 0 (zero), effectively resets filemaxbytes, and so has no
effect.

=over 4

=item eg. 

C<filemaxbytes: 10000>

=back

=item B<filepgpuserid>

If you want to store the data from a form encrypted, you can use
B<filepgpuserid> to securely store data.

=item eg. 

C<filepgpuserid: vittal.aithal@bigfoot.com>

Will store data encrypted for vittal.aithal@bigfoot.com

=back

=item B<filereadable>

When writing form data to a file, the file is usually kept unreadable by the 
webserver. By setting B<filereadable>, the file can be made readable by the
webserver.

Note that this only affects people reading the file from a web browser, it
does not secure the file from other types of access (eg. from FTP or through
the filesystem). So, don't go storing credit card numbers in a file unless
you're damn sure that your machine's secure.

=over 4

=item eg.

C<filereadable : yes>

=back

=item B<filetemplate>

A template file which determines how a set of form data should be written to 
the file specified by B<fileto>. See the section on L<TEMPLATES> for more 
information.

=item B<fileto>

The filename that the contents of a form should be written to. The path is
either relative to the location of the configuration file or an absolute
path from the web server's root.

=over 4

=item eg.

C<fileto : output/out.txt>

=back

If no B<filetemplate> is given, the output form a form is written as a series
of lines matching:

C<name = value[,value ...]>

Where a form field has multiple values, these are listed separated by commas.

=item B<footings>

This is a plain text file that can be placed at the end of files specified by
B<fileto>.

=item B<gotoblank>

A URL for a page to redirect the user to if their form entry was blank. Unlike
the B<blank> field, the file is not a template, and so should not contain
E<lt>outputE<gt> elements.

=over 4

=item eg.

C<gotoblank : http://myserver/errors/blank.htm>

=back

=item B<gotoexpires>

A URL for a page to redirect to if the form has past its B<expires> date.

=item B<gotofailure>

A URL for a page to redirect the user to if their form entry did not contain
all the required fields. Unlike the B<failure> entry, this is not a template
and should not contain E<lt>outputE<gt> elements.

=over 4

=item eg.

C<gotofailure : http://myserver/errors/failed.htm>

=back

=item B<gotosuccess>

A URL for a page to redirect the user to if their form entry was successfully
completed. Unlike the B<success> field, this is not a template and should
not contain E<lt>outputE<gt> elements.

=over 4

=item eg.

C<gotosuccess : http://myserver/forms/success.htm>

=back

=item B<gnupg>

It is possible to use the GNU Privacy Guard program rather than PGP. If you
do use it, then set C<gnupg> to yes in your configuration. If you do not,
then Soupermail will assume encryption is using PGP.


=item B<headings>

This is a plain text file that can be placed at the start of files specified
by B<fileto>.

=item B<htmlmailtemplate>

This option allows you to send mail formatted in HTML. Only the HTML
is sent, images are not encoded or sent. All relative links from the HTML
will be from the location of the config file on the server.
Probably the best thing to do with HTML templates is use absolute URLs
for images and suchlike.

If you specify both C<htmlmailtemplate> and C<mailtemplate> a mixed
text and HTML message is generated. This will allow people who don't have
HTML capable mail clients to read your mail.

=item B<htmlsendertemplate>

In the same way as C<htmlmailtemplate> is sent to the C<mailto> address, this
template is used when sending mail to the submitter of the form. It behaves
in the same way as C<htmlmailtemplate> when it comes to link handling.

=item B<ignore>

If your HTML forms contain hidden fields, you can I<ignore> them so that
you can check for situations where the user doesn't complete any fields. Only
one form field can be specified on an ignore line. Use multiple ignore lines
if you wish to ignore more than one field. The soupermail special form
variable B<SoupermailConf> is ignored automatically.

=over 4

=item eg.

=for text
C<ignore : hidden1
ignore : hidden2>

=for man
C<ignore : hidden1
ignore : hidden2>

=for html
<pre>ignore : hidden1
ignore : hidden2</pre>

This would ignore the values of fields 'hidden1' and 'hidden2' 
when determining if a form was left blank.

=back

=item B<if>

A conditional statement used to set configuration values based on the user's
form input. See the section on L<CONDITIONAL STATEMENTS> for more information.

=over 4

=item eg.

C<if : (division eq 'Accounts') then mailto : accounts@mycompany.com>

This would set B<mailto> to accounts@mycompany.com if the form contained
a field called 'division' and its value was 'Accounts'.

=back

=item B<iscreditcard>

This is used to validate a form field to see if its a credit card number.
The check performed is a basic Luhn checksum, and doesn't check card
ranges.

=over 4

=item eg.

If you have a field called 'creditc' in your form, and want to validate it,
use:

C<iscreditcard: creditc>

=back

If the validation fails, the B<failure> template is activated. Validation will
not fail if the field is left blank.

=item B<isinteger>

This is used to validate a form field is an integer. If the validation fails, 
the failure template is activated.

=item B<isnumber>

Behaves in the same way as the isinteger option, and validates a form field 
as a number.

=item B<isnotcreditcard>

Used to check is a form field is NOT a credit card number.

=item B<isnotinteger>

Used to check is a form field is NOT an integer.

=item B<isnotnumber>

Used to check is a form field is NOT a number.

=item B<mailcharset>

This defines the character set to send email as. It defaults to iso-8859-1.

=item B<mailtemplate>

A template file to use when formatting the outgoing email. See the section 
on L<TEMPLATES> for more information.

=over 4

=item eg.

C<mailtemplate : /forms/config/mail.tpl>

=back

=item B<mailto>

A comma separated list of email addresses to send the results of the email to.

=over 4

=item eg.

C<mailto : rod@mycompany.com, jane@othercompany.com, freddy@mycompany.com>

=back

=item B<mimeon>

When set, Soupermail will allow file uploads from web browsers using RFC1867
and will attach the uploaded files as MIME attachments on resulting emails.

=over 4

=item eg.

C<mimeon : yes>

This would allow MIME attachments to be sent.

=back

=item B<nofilecr>

When saving results to a file, it is sometimes useful to remove newline
characters from the results. Setting B<nofilecr> will do this.

=over 4

=item eg. 

C<nofilecr : yes>

This would remove newline characters from fields written to a file.

=back

=item B<nomailfooter>

Do not display the hostname and IP address details at the foot of each 
outgoing email.

=over 4

=item eg.

C<nomailfooter : yes>

=back

=item B<pdftemplate>

=item B<pdfmailtemplate>

=item B<pdfsendertemplate>

=item B<pgpmime>

By default, Soupermail will send PGP messages as a multipart/encrypted MIME
message (as per RFC 2015). However, not all PGP mail plugins recognise 
this format (eg, the Pegasus mail PGP plugin). Setting pgpmime to B<no> 
will not encapsulate the PGP message in MIME headers.


=item B<pgpport>

This is the port number of a HTTP PGP 5 keyserver. The default port is
11371. The hostname for the server is specified with B<pgpserver> below.
See the section on L<USING PGP> for more information.

=item B<pgpserver>

This is the hostname of a HTTP PGP 5 keyserver to get PGP keys from.
See the section on L<USING PGP> for more information.

=over 4

=item eg.

C<pgpserver : pgpkeys.mit.edu>

=back

=item B<pgpuserid>

A user in the public keyring which outgoing email should be encrypted for.
See the section on L<USING PGP> for more information.

=over 4

=item eg.

C<pgpuserid : bungle@mycompany.com>

=back

=item B<ref>

A format for a reference number to be generated and used as the
I<http_ref> CGI variable. See the sections on L<CGI VARIABLES> and 
L<FORMATS> for more information.

=over 4

=item eg.

C<ref : REF%yy%%mmm%%dd%%rrrr%>

This may generate a reference like: REF9704016364 on April 1 1997

=back

=item B<replyto>

An email address that will be used in the Reply-To: mail header.

=over 4

=item eg.

C<replyto : zippy@mycompany.com>

=back

=item B<required>

A boolean expression which determines which form fields must be completed. 
The entry is composed of field names separated by && (AND) and || (OR) 
operators. See the section on L<Boolean Expressions> for more details.

=over 4

=item eg.

C<required : ((name && address) || telephone)>

The above expression requires either the fields name and address to be 
completed, or the field telephone to be completed.

=back

=item B<returntosender>

This will CC the sender of the form a copy of the email message sent as a 
result of the form. This requires the form to have a field called Email (case
sensitive), which is assumed to be the sender's email address.

=over 4

=item eg.

C<returntosender : yes>

=back

=item B<senderfrom>

When using a sendertemplate, the email address used in the email back to
the form's sender is set to this. The preferred order email addresses are 
chosen for the sender's From field is:

=over 4

=item * senderfrom

=item * senderreplyto

=item * mailto

=item * replyto

=item * sender's email address

=back

This field is useful if you need an auto-reply function from your form, but
don't want to obviously expose the mailto address directly to the sender of
a form.

=item B<senderreplyto>

An email address that will be used in the Reply-To: mail header for mails
sent with the B<sendertemplate> config option.

=item B<sendersubject>

Used in conjunction with sendertemplate, this is a subject line only to
be used in email messages send directly back to the form's submitter. If its
not set, the subject line set with the subject: config line is used.

=item B<sendertemplate>

This is a template file for an email to be sent back to whoever submitted
the form. It takes the email address to send this to from the B<Email>
form variable. The From field of the email is set to either the B<mailto>
or B<replyto> configuration values. See the section on L<TEMPLATES> for
more information.

=item B<setcounterI<X>>

This sets the value of a counter prior to any templates being filled based
on the counter's onsuccess, onfailure, onblank and onexpires config
values.

=item B<subject>

A subject line to use on resulting emails.

=over 4

=item eg.

C<subject : This is a feedback email>

=back

=item B<success>

A template file to return through the web browser if the form was correctly
submitted. See the section on L<TEMPLATES> for more information.a

=over 4

=item eg.

C<success : /forms/config/success.tpl>

=back

=item B<unless>

This has an identical format to the B<if> command, but performs the opposite
of what the B<if> tests do. Using this, you can check for when values are not
set. See the section on L<CONDITIONAL STATEMENTS> for more information.

=item B<wrap>

The number of characters to wrap the soupermail emails to.

=over 4

=item eg.

C<wrap : 60>

=back

=back

Sometimes it is useful to concatenate some of the configuration values, for
instance where you need to specify more that one B<mailto> recipient based
on the user's input. In order to do this, you can use the following variables
in you configuration files:

=over 4

=item B<$mailto>

This is the current value of B<mailto> in the configuration. This will be
expanded to the value when the configuration is parsed.

=over 4

=item eg.

=for text
C<mailto : rod@mycompany.com
mailto : "$mailto, jane@mycompany.com">

=for man
C<mailto : rod@mycompany.com
mailto : "$mailto, jane@mycompany.com">

=for html
<pre>mailto : rod@mycompany.com
mailto : "$mailto, jane@mycompany.com"></pre>

This example initially sets B<mailto> to rod@mycompany.com. Then it sets
B<mailto> to rod@mycompany.com, jane@mycompany.com. Notice that the expansion
occurs only if the value is enclosed in double quotes (").

=back

=item B<$subject>

This is used to get the current value of B<subject>

=over 4

=item eg.

=for html
<pre>subject : Feedback of type - 
if (feedtype eq 'comment') then subject : "$subject Comment"
if (feedtype eq 'problem') then subject : "$subject Problem"</pre>

=for text
C<subject : Feedback of type ->
C<if (feedtype eq 'comment') then subject : "$subject Comment">
C<if (feedtype eq 'problem') then subject : "$subject Problem">

=for man
C<subject : Feedback of type ->
C<if (feedtype eq 'comment') then subject : "$subject Comment">
C<if (feedtype eq 'problem') then subject : "$subject Problem">

This example changes the B<subject> based on a field in the original form 
called 'feedtype'.

=back

=item B<$replyto>

This is used to get the current value of the B<replyto> field.

=over 4

=item eg.

=for man
C<replyto : management@mycompany.com
if : (interested has 'rod') then replyto : "$replyto, rod@mycompany.com"
if : (interested has 'jane') then replyto : "$replyto, jane@mycompany.com"
if : (interested has 'freddy') then replyto : "$replyto, freddy@mycompany.com">

=for text
C<replyto : management@mycompany.com
if : (interested has 'rod') then replyto : "$replyto, rod@mycompany.com"
if : (interested has 'jane') then replyto : "$replyto, jane@mycompany.com"
if : (interested has 'freddy') then replyto : "$replyto, freddy@mycompany.com">

=for html
<pre>replyto : management@mycompany.com
if : (interested has 'rod') then replyto : "$replyto, rod@mycompany.com"
if : (interested has 'jane') then replyto : "$replyto, jane@mycompany.com"
if : (interested has 'freddy') then replyto : "$replyto, freddy@mycompany.com"
</pre>

If the form contained a set of checkboxes all called 'interested' with the
values of 'rod', 'jane' and 'freddy', this configuration will add the email
addresses of rod, jane and freddy depending upon which checkboxes were set
by the user.

=back

=item B<CGI variables>

It is possible to all of the L<CGI VARIABLES> listed below (except
counter variables) by placing a '$' character before their name.

=over 4

=item eg.

C<$http_user_agent>

will return the web browser name.

=back

=item B<Form Variables>

It is possible to use any value from a form by placing '$form_' before the
form variable's name.

=over 4

=item eg.

If a form has a field called 'TheirName', then the following could be used in
the configuration file:

C<Subject: "Form response from $form_TheirName">

=back

=item B<Cookie Variables>

In the same way as its possible to use form variables, cookie variables can
be inserted by putting '$cookie_' before the cookie's name.
See the section on L<COOKIES> for more information.

=over 4

=item eg.

C<Subject: "The cookie named Bungle has value $cookie_Bungle">

=back

=back

Replacements can only be used when setting the subject, mailto, replyto,
reference number and cookie value fields. 

Replacement value will only be used when they are enclosed in double-quotes.
So, the following will NOT work:

=over 4

=item eg.

Subject: This is a non-working mail to $mailto

=back

However, this will work:

=over 4 

=item eg.

Subject: "This is a working mail to $mailto"

=back

=head1 CONDITIONAL STATEMENTS

Conditional statements in configuration files allow you to control the
configuration of a form based on the user's form input, values from a
users cookies or any of the http_ variables. A conditional
statement is made up of a boolean expression followed by a configuration
statement.

=over 4

=item ie.

C<if : I<boolean_expression> then I<configuration_statement>>

or

C<unless : I<boolean_expression> then I<configuration_statement>>

=back

The only configuration statement disallowed in a conditional statement is
another if or unless.

Conditional statements are executed in the same order that they appear in
the configuration file. 

=head2 Boolean Expressions

A boolean expression is something that can either be true or false. If it's
true, then the configuration statement is set, otherwise it isn't.

The simplest boolean expression is just the name of a form field. If the form
field was completed by the user, then the boolean is true.

=over 4

=item eg.

If you have a form that contains and input field called 'name' and you want to
set the B<subject> line based on this name being set, you could use the
following configuration statements:

=for text
C<subject : They haven't set their name
if : name then subject : They have set their name!>

=for man
C<subject : They haven't set their name
if : name then subject : They have set their name!>

=for html
<pre>subject : They haven't set their name
if : name then subject : They have set their name!</pre>

Initially, subject is set to 'They haven't set their name'. However, if the
'name' field is completed on the form, the conditional statement is
activated and the subject is reset to 'They have set their name!'.

=back

If you want to check on cookies, prefix the cookie's name with $cookie_. So,
if you wanted to test if the user had sent a cookie called "MyName", use
a condition like this:

=over 4

=item eg.

C<if: $cookie_MyName then Subject: "Cookie MyName was set to $cookie_MyName">

=back

Boolean expressions in soupermail use two basic operators, AND (&&) 
and OR (||). An expression with an AND in will be true if BOTH of the things
around the AND are true. An expression with an OR in will be true if one or
more of the things around the OR is true.

=over 4

=item eg.

I<x> && I<y> will be true if I<x> is true and I<y> is true

I<x> || I<y> will be true if I<x> is true or I<y> is true

I<x> && I<y> || I<z> will be true if I<x> and I<y> are both true, or 
I<x> is true.

=back

Boolean expressions can contain any number of smaller boolean expressions.
To make life easy, you can group these with brackets "(" and ")".

=over 4

=item eg.

You have a form containing the fields 'name', 'address', 'telephone', 'fax' and
'Email'. You want to know that name has been filled in and that they have
supplied an address or telephone or email. The following boolean expression
could be used:

C< name && (address || telephone || Email)>

Notice the use of brackets, to enclose the ORs. If the brackets were missed 
out, the expression would have meant the user must complete their 
name and address, or their telephone, or their email; or as a boolean 
expression:

C<(name && address) || telephone || Email>

This is because AND is considered to be more important than OR.

=back

If you have form fields that contain spaces, you can still use them in boolean
expressions, but you must enclose them in double quotes (").

=over 4

=item eg.

You have a form containing:

E<lt>input type="text" name="title"E<gt> 
E<lt>input type="text" name="First Name"E<gt>

Any boolean expression using this field name must use it quoted:

C<"First Name">

=back

Other operators available in boolean expressions are:

=over 4

=item B<==>

Numerical equality

=over 4

=item eg.  

C<if : age == 45 then subject : You are 45>

=back

=item B<!=>

Numerical inequality

=over 4

=item eg.  

C<if : age != 50 then subject : You are NOT 50>

=back

=item <B<=>

Numerically less than or equal to

=over 4

=item eg.  

C<if : age E<lt>= 50 then subject : You younger than 51>

=back

=item >=

Numerically greater than or equal to

=over 4

=item eg.  

C<if : age E<gt>= 50 then subject : You older than 49>

=back

=item <

Numerically less than

=over 4

=item eg.  

C<if : age E<lt> 50 then subject : You younger than 50>

=back

=item >

Numerically greater than

=over 4

=item eg.  

C<if : age E<gt> 50 then subject : You older than 50>

=back

=item B<eq>

String equality

=over 4

=item eg.  

C<if : name eq 'Humphry' then subject : You are called Humphry>

=back

=item B<ne>

String equality

=over 4

=item eg.

C<if : name ne 'Humphry' then subject : You are NOT called Humphry>

=back

=item B<le>

String less than or equal to

=item B<ge>

String greater than or equal to

=item B<lt>

String less than

=item B<gt>

String greater than

=item B<has>

A string value is equal to something in a multivalue field

=item B<hasnt>

A string value is not equal to something in a multivalue field

=item B<contains>

A string value exists inside, or is equal to another value. It is 
case-insensitive.

=over 4

=item eg.

C<if : name contains 'on' then subject: Your name contains the letters on>

The above example would match names such as "Ron" or "Donna".

=back

=back

=head1 TEMPLATES

Soupermail uses a series of templates specified by the configuration file to
control the output, either to the screen, a file or to email. All the
template locations should be specified relative to the location of the
configuration file or as absolute paths (things starting with a '/' character)
from the web server's root. The basis for a template is a HTML-like element 
called E<lt>outputE<gt>.

The E<lt>outputE<gt> element can be considered as analogous to the HTML 
E<lt>inputE<gt> element.

Where an <output> element appears in a template, Soupermail replaces it with
some appropriate text. The value of the replacement text depends upon the
attributes specified in the <output> element.

=head2 Attributes

The following is a list of attributes that can be placed in template
E<lt>outputE<gt> elements.

=over 4

=item B<alt>

This field is alternative text to replace the E<lt>outputE<gt> element 
with, if the field name wasn't filled in on the original form.

=item B<altvar>

Usually, the value of the B<name> attribute is replaced in the
E<lt>outputE<gt> element. However, using B<altvar>, another variable
can be used if B<name> hasn't a value.

=over 4

=item eg.

Supposing you have a field called 'month' that you want to default to the
current month if it's not filled in in the form. The following could be
used:

E<lt>output name="month" altvar="http_date" format="%mmm%"E<gt>

=back

=item B<case>

This can take the values of B<upper> or B<lower> and will upcase or 
downcase the thing returned by the output element.

=item B<charmap>

Sometimes, you need to change one character in a string to another; for 
instance, escaping quote marks when saving a CSV file. The B<charmap> 
attribute allows a character to be changed to a string (or removed). The
format for the B<charmap> attribute should be the character to change,
followed by a comma, followed by the string to change it to.

=over 4

=item eg.

To double up quote marks for a CSV file, use something like:

E<lt>output name="fieldname" charmap='",""'E<gt>

To remove all occurences of the letter 'a':

E<lt>output name="fieldname" charmap="a,"E<gt>

To turn underscores into hyphens:

E<lt>output name="fieldname" charmap="_,-"E<gt>

=back

=item B<data>

This is used to check the type of data in the form field. The B<data> attribute
can have the following values: B<number>, B<notnumber>, B<integer>,
B<notinteger>, B<email>, B<notemail>, B<creditcard>, B<notcreditcard>

If the check fails, then the output element will return its B<alt> value.

=over 4

=item eg.

Here are some examples for a form field, 'foo', with a value of 6.5:

E<lt>output name="foo" data="number" alt="fail" sub="pass"E<gt> = pass

E<lt>output name="foo" data="integer" alt="fail" sub="pass"E<gt> = fail

E<lt>output name="foo" data="notnumber" alt="fail" sub="pass"E<gt> = fail

E<lt>output name="foo" data="notinteger" alt="fail" sub="pass"E<gt> = pass

E<lt>output name="foo" data="email" alt="fail" sub="pass"E<gt> = fail

=back

The credit card check is a simple LUHN checksum that makes sure the number
given looks like a credit card number. It does not mean the number is a real
card number, or that there's any money in the account.

=item B<delim>

A text string to display between items in a text list. 

=item B<format>

A format to specify how certain variables are formatted when displayed. Only 
applies to http_time, http_date and http_ref.

=item B<indent>

This is a string to indent the substituted text with. Its mainly useful
for email templates, where you may want to indent the contents of an HTML
textarea element.

=item B<list>

When an E<lt>outputE<gt> element is replaced by a multivalued form field, 
Soupermail's default behavior is to output a HTML E<lt>ulE<gt> list, or 
text list. By setting the B<list> attribute to ul|ol|menu|dir|text, a 
specific type of HTML list can be achieved. The text value will return a 
non-HTML text list. The format of this text list can be controlled by the 
B<delim> attribute.

=item B<math>

You can use simple maths expressions using this attribute. You can use
form, cookie and http values in the B<math> expression, and they will be
replaced before the expression is evaluated. Values that are undefined or
non-numeric are replaced by zero. If the B<name> attribute is multi-valued,
the B<math> expression is evalued for each value.

The following are the maths operators available:

=over 4

=item +

addition

=item -

subtraction

=item *

multiplication

=item /

division

=item sum()

summation of a multiple valued field

=item count()

count of a multiple valued field

=back

=item B<name>

This should correspond to a field name from the HTML form, a CGI 
Variable available from soupermail or a cookie name prefixed with 'cookie_'.
This field is case-sensitive.

=item B<newline>

This allows newlines to be represented as either HTML or removed from the
value. If B<newline> has the value B<html>, then newline characters
are converted to E<lt>brE<gt> tags. If it has the value of B<none>, then
newline characters are replaced by spaces. If it has a value of
B<unchanged> then newlines are left as is. The value of B<paragraphs>
replaces breaks of more than 2 newlines with only 2 newlines - useful
for formatting plain text entries.

=item B<post>

This is text to be post-pended to the value of the field name if the
field was set in the original form. It isn't used with the B<alt> or B<sub>
attributes. For multivalue entries, the B<post> section is placed after each
list item.

=item B<pre>

This is text to be pre-pended to the value of the field name if the field 
name was set in the original form. It isn't used with the B<alt> or 
B<sub> attributes. For multivalue entries, the B<pre> section is placed 
before each list item.

=item B<precision>

Used in conjunction with the B<math> attribute, this value is the number of
decimal places to display numbers to.

=item B<sub>

This is text to replace the output field with if the field is set in the 
original form.

=item B<subvar>

This is similar to the B<altvar> attribute, but comes into play when the
variable set be the B<name> attribute has a value. 

=item B<type>

If type is set, it can be one of B<escaped>, B<unescaped>, B<html> or
B<unescapedhtml>. Escaping output tags is useful if you want to pass 
form values between forms in hidden form fields. Escaped output tags 
are URL encoded, so characters such as E<lt> and " don't appear. 
When you want to get the user's original values, use the B<unescaped> 
or B<unescapedhtml> types in an output tag. The B<html> type is useful
for displaying values in HTML templates where a user may have typed in
HTML characters such as E<lt> or E<gt>.

=over 4

=item eg.

If you have a field like this:

E<lt>input type="text" name="val"E<gt>

and this in a template:

E<lt>input type=hidden name=val value="E<lt>output name="val"E<gt>"E<gt>

and the user's typed something like this into the field:

This will "break stuff"

If you don't escape the output tag, you get broken HTML like this:

E<lt>input type=hidden name=val value="This will "break stuff""E<gt>

However, if you used E<lt>output name="val" type="escaped"E<gt>, you'd get:

E<lt>input type=hidden name=val value="This%20will%20%22break%20stuff%22"E<gt>

which is HTML safe, and can be B<unescaped> in your final template.

=back

=item B<value>

Usually, if the thing set by B<name> has a value, it is returned by the
E<lt>outputE<gt> element. However, if B<value> is set, it is only returned
if its value equals that of B<value>. The B<alt> attribute will become active
if the values do not match and the B<sub> attribute will become active if
they do match. This may sound pretty daft, but its
useful for regenerating drop down lists in multipart forms. See the
Multipart form example that comes with Soupermail.

=item B<valuevar>

Similar to the B<value> attribute, but affects the use of B<altvar> and
B<subvar> replacement.

=back

=head2 SSI Like Includes

Server Side Includes (SSI) are a means of dropping one file into another
before sending a page onto the user's browser. Soupermail can provide a basic
inclusion mechanism using the same syntax as normal SSI directives. Soupermail
will only handle E<lt>!--#include virtual="..."--E<gt> type includes, #exec
is too much of a processing burden. The path can either be an absolute path
from the server's root, or a path relative to the location of the config
file.



=head1 CGI VARIABLES

CGI variables are set by the web server, and in some specific cases, Soupermail.
These names should not be used as field names in your HTML forms.

=over 4

=item B<counter_I<X>>

The value of the counter named I<X>

=item B<http_time>

The time at the web server.

=item B<http_date>

The date at the web server.

=item B<http_referer>

The URL of the calling form.

=item B<http_remote_host>

The hostname of the person sending the form.

=item B<http_remote_addr>

The IP address of the person sending the form.

=item B<http_server_name>

The name of the webserver.

=item B<http_server_port>

The port number the webserver is listening on.

=item B<http_user_agent>

The type of browser used to send the form.

=item B<http_ref>

A soupermail generated reference number.

=item B<http_remote_user>

The username if the form was password protected.

=item B<http_remote_ident>

Not sure, but some browsers set it.

=item B<http_host>

The server name the browser thinks its at.

=item B<http_from>

A browser specific variable

=item B<http_config_path>

The path from the web server's root to the configuration file
that was used to generate the page. This can be very useful
when generating multipart forms, where you want to keep your
directory structure portable by using relative links.

=back

=head1 FORMATS

Formats allow the http_time, http_date and http_ref variables to be controlled.
A format is a one line string containing the following substrings. When the 
E<lt>outputE<gt> element is expanded, the substrings are expanded into the 
following:

=over 4

=item B<%yyyy%>

A 4 digit year (eg. 1997)

=item B<%yy%>

A two digit year (eg. 97)

=item B<%mmmm%>

A three letter month code (eg. Jan)

=item B<%mmm%>

A two digit month code

=item B<%ddd%>

A three letter day code (eg. Mon)

=item B<%dd%>

A two digit day code (eg. 28)

=item B<%hhhh%>

A 2 digit 24 hour (eg. 13)

=item B<%hh%>

A 2 digit hour (eg. 03)

=item B<%mm%>

A 2 digit minute (eg. 23)

=item B<%ss%>

A 2 digit second (eg. 06)

=item B<%r...%>

A random number. The length of the random number is determined by the 
number of r's in the format. The maximum number of r's is 12. eg. %rrr% returns
a value between 0 and 999.

=item B<%c...%>

This is a formatting command used to break a number into a series of
space delimited blocks. The number of B<c> characters given determines
how many characters to use before a space.

=over 4

=item eg., to format a credit card number

use C<format="%cccc%"> which would give you something like:

C<1234 5678 9876 5432>

C<format="%ccc%"> would give you:

C<123 456 789 876 543 2>

=back

Non-numeric characters are removed from the value.


=item B<%counter_I<X>%>

This is the value of a config file specified counter. The value used is
calculated B<after> any increments or sets are performed on the counter, so
it will be the same value that appears in templates. The value of I<X> is
the counter number needed. eg. %counter_3%

=back

=head1 COUNTERS

Counters are a way of storing and reading the number of times Soupermail has
done something. They are specified in the configuration file, and you can have
any number of them in use. In their simplest guise, you can use them to count
how many people have submitted a form. More complex uses include setting
the maximum number of times a form's submitted, online voting systems
and renaming the filenames form information is saved to.

The behaviour of counters can be slightly odd for the unwary. Firstly, they
are always defined in the config file, but simply declaring a counter file
does not mean it gets updated, its value just becomes available for the config
file and for templates. To update a counter, an onsuccess, onfailure, onblank
or onexpires setting for the counter must be set.

Secondly, the value returned by a counter in the config file is the value
stored in the counter file BEFORE any increments have been performed on the
counter, however, the value returned in templates and the http_ref value
are set AFTER increments have been applied to the counter.

=over 4

=item eg.

=begin man

C<mailto: cookiemonster@example.org
counter1file: counters/count1.txt
counter1onsuccess: yes
if : ("$counter_1" == 10) then setcounter1 : 1
if : ("$counter_1" == 10) then mailto : thecount@example.net>

=end man

=begin text

C<mailto: cookiemonster@example.org
counter1file: counters/count1.txt
counter1onsuccess: yes
if : ("$counter_1" == 10) then setcounter1 : 1
if : ("$counter_1" == 10) then mailto : thecount@example.net>

=end text

=begin html

<pre>mailto: cookiemonster@example.org
counter1file: counters/count1.txt
counter1onsuccess: yes
if : ("$counter_1" == 10) then setcounter1 : 1
if : ("$counter_1" == 10) then mailto : thecount@example.net
</pre>

=end html

The above example would result in counter1 being set to 1 and the mailto
address set to thecount@example.net whenever the counter reached 10.
Note that even though the 
C<setcounter1> is set in the config file, it does not have an immediate
effect, and does not prevent the second C<if> statement being used.

=back

=head1 COOKIES

Cookies were introduced in Netscape Navigator 2.0. They are a means of 
storing information on the user's browser even after they've turned off their
computer. Soupermail allows up to three cookies to be set, each cookie holding
at most 516 characters worth of data, and with a cookie name less than 50
characters long. The restriction on the cookie size and number of cookies
is mainly out of politeness, because its not considered nice to flood users
with cookies.

More information on cookies can be found at 
http://home.netscape.com/eng/mozilla/3.0/handbook/javascript/index.html

=head1 USING PGP

PGP is a means of encrypting text through a public key and decrypting through
a private key. Using PGP, Soupermail can send secure encrypted email over
an insecure Internet.

To use PGP, you will need to place a public keyring (pubring.pkr or
pubring.gpg) in the 
directory where your form's configuration file is located. In your
configuration file, set B<pgpuserid> to be a user in the pubring keyring.
When soupermail generates an email, it will encrypt the message using the
public key of the given user. By default, this version of Soupermail 
assumes that PGP version 5.0i is being used.

As of Soupermail 1.0.3, GNU Privacy Guard (GPG) is supported as an alternative
to using PGP. Using GPG rather than PGP 5 differs only in that the public
keyring file is called pubring.gpg and the C<gnupg> config option must be
set. See the GPG documentation for more information.

You can also specify a PGP keyserver in the configuration file. If specified,
the PGP encryption will look on the key server for encryption keys.
B<THE PGP KEYSERVER CODE IS EXPERIMENTAL AND HASN'T BEEN TESTED! USE AT YOUR
OWN RISK!>

For more information on PGP, please look at http://www.pgpi.com/

For more information on GPG, please look at http://www.gnupg.org/

=head1 REQUIREMENTS

Soupermail requires perl 5.003 or better. See http://www.perl.com/ for where
to get perl from, or http://www.activestate.com/ if you need the Windows NT
version of Perl.

To handle the CGI input, Soupermail needs Lincoln D. Stein's excellent
CGI module, available from 
http://www.genome.wi.mit.edu/ftp/pub/software/WWW/cgi_docs.html

To send email, Soupermail either needs a working Net::SMTP perl module 
installed on the server, or, if you are on a UNIX server, a working 
sendmail. Net::SMTP is distributed as part of the 
Libnet set of packages available from CPAN. For users on Windows NT,
libnet is available with Activestate's Perl Package Manager.

On UNIX boxes, PGP requires PGP 5.0, available internationally from
http://www.pgpi.com/

Under NT, you can use the DOS version of PGP 5, again, available from
http://www.pgpi.com/. Unfortunately, I haven't got version 6.2 to work
yet, so its the 16bit only.

GNU Privacy Guard is available from http://www.gnupg.org/


=head1 EXAMPLES

Some examples are distributed with soupermail. If anyone has any good sites
with examples, please let me know.

=head1 AUTHOR

Vittal Aithal E<lt>vittal.aithal@bigfoot.comE<gt>

=head1 CREDITS

I'd would be wrong to say I wrote this all on my own, other people made my life
difficult on the way, so I'd better credit them (only joking guys :) 
A round of applause for everyone at
http://www.angelfire.com/va/lattiv/credits.txt

=head1 HISTORY

Soupermail started life in late 1995 as a fairly lightweight CGI to handle 
emails. However, as the years went by, it began to suffer heavily 
from creeping featuritis, and has now grown into a monster. It started life
at Unipalm PIPEX, and various copies/versions are used by a number of 
companies. UUNET UK ( http://www.uk.uu.net/ ) maintain a copy for their
WorldWeb service users, this copy escaped and worked at 
Ionica. However, things went a bit pear-shaped, so now it teleworks
from my house or from Revolution ( http://www.revolutionltd.com/ ).

=head1 BUGS

PGP seems unstable. It doesn't check for the UserIDs you pass into it. Also,
its highly variable upon platform as to whether it works :(

Soupermail suffers from major bloat, but I just haven't worked up the will
to cull it down.

Empty config files return a Thank you message, although nothing has happened.
Its debatable if this is correct.

Speaking of featuritis, it would be nice to see DBI/DBD support, and how 
about generic form variable setting :)


= cut
 
# vim:ts=4
