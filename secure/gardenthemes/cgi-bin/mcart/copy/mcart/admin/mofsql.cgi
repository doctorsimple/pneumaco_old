#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
# THIS COMPONENT IS CURRENTLY UNDER DEVELOPMENT
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === MYSQL COMPONENTS ADMIN ====================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Utility to create mySQL dB Tables for MOFcart orders storage
# MOFcart and all MOF PlugIns are copyright, rga@merchantpal.com 
# INSTRUCTIONS: 
# Upload this file to your server and run as cgi script 
# Set permissions to 755 (unix,linux servers)
# Note: Perl DBI module may not be installed in Win32 platforms
# Note: DBD::mysqlPP (Pure Perl) is the DBD module being used
# Note: You may have to install this on your server
# ============================================== #

# THIS mySQL Component is under Development : August 10, 2003 11:36:57 PM
# It is released with MOFcart v2.5 as a custom utility only
# and will be Developed further for MOFcart v3.0
# As it is now, it will only run the Create Table queries <mofsql_structure25.sql>

# WHERE TO GO
# (1) Build the admin login : pswd shell
# (2) Build a set up function for configuring MOFcart conf file stored to mySQL
        # and printed out as appropriate *.conf file in cgi-bin DIR
        # capable of saving several modifications, to restore if needed
        # set up can also mkdir, unTar.Gz files for Search/Replace configs, and copy pkg files to correct DIR
# (3) Use function : Create Tables <run query>
# (4) Use function : Create Reports
# (5) Use function : Update Records
# (6) Use function : Secure Credit Card Retrieval
       # This is going to be interesting since Visa agreements prohibit CVV from hard saves
       # and sometime in 2004 Visa will "require" CVV for internet transactions, Hmmm
       # This means a dead end for MOTO transactions, unless one plans to save CVV data
       # and creates necessity for gateway processing 	

# (CUSTOMER) Build seperate <mofusrsql.pl> for customer GUI to Orders, downloads, and Update Info
        # Issue user : pswd at order confirmation for login to mySQL data
        # recall all orders, locate downloads, etc.




# Note: alternate calls to HOST = dbName.dbHost
# may need to disable host=InConnect string

# set up a unix pswd, if  .pswd file not found in native dir
# if .pswd file found use the pswd to access admin functions

BEGIN {
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart/lib');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart/lib');
} 

require 'common.conf';
require 'mofpay.conf';


$ThisFile = 'mofsql.cgi';
$dbHost = $dbHost;
$dbName = $dbName;
$dbUser = $dbUser;
$dbPswd = $dbPswd;

# just load from the <mofpay.conf>
# $dbHost = 'localhost';
# $dbName = 'mofdb';
# $dbUser = 'rga';
# $dbPswd = 'rga';

# path works with XP & Linux
$filePath = "$mvar_front_path_mcart/dbquery/";


# this is set to post pend to $filePath as &ReadFile(param)
# File Names are scanned for security : s/[^A-Za-z0-9._-]//g;
$fileName = 'mofsql_structure25.sql';
# $fileName = 'mofsql_test.sql';

# USING DBD::mysqlPP (Pure Perl)
# You can use both DBD::mysqlPP & DBI (pure perl) in native DIR
# DBI pure perl compiles a little slower than C DBI
# most servers have (compiled) DBI as common module

	use DBI;
	my($x)=0;
	my (@qry) = ();
	my (@msg) = ();
	my (@notes) = ();
	my($sth,$sql,$dbh,$sql,$i,$ver);
	

	# connect to DB
	unless (
		$dbh = DBI->connect("dbi:mysqlPP:database=$dbName;host=$dbHost",
		"$dbUser","$dbPswd",
		{ RaiseError => 0 }		
		)) {
	        my $errmsg = $DBI::errstr;
		$errmsg = qq~
		<li>DataBase Error, mySQL Error Reason :
		<li>$errmsg ~;
		&Err($errmsg);
		}


	# Make a list of queries available in the ./sqlqueries/ DIR
	# load a query to run as $SQL string

	##### WHAT I WANT TO DO	
		# use the mofaccess.pl as login manager
		# be able to read the ./dbqueries/ DIR for plugin sql operations
		# display a list of operations, by filename
			# be nice to keep comments for each operation (file name)

		# also would like to perform diagnostics on <mofdb> various tasks
			# backup, restore, referential integrity

		# also sould like to house report queries in the ./dbqueries/ DIR for various reports
		# and queries for various downloads, exports

		# we need return information from mySQL on operation outcomes
		# and even be able to store them to log file
		# one important part is to be able to check SQL syntax
		# and prevent malicious queries from executing

		# also be able to save reports, export report data, export reports
		# export functions for QuickBook Pro, Quicken, Access
		# export upload file for AuthorizeNet (if processing is that way)

		# then I want real APIs from <mofpay.cgi> where temp data is stored
		# and AuthNet outcome parsed before final operations in MOFcart v2.5

		# we also need a dB backend operation for users to login and see any
		# activity on orders, shipping, etc., and the admin GUI must be able
		# to update records with shipping dates, UPS tracking numbers, etc.
		# you should be able to get pretty close to real time w/ UPS, even
		# their bulk email queries, can be imported into dB for orders updates	

		# Then after that, we need a front end store, catalogue, using a SKU# for
		# products, that ties into inventory

		# you can also place a textarea to cut/paste queries

		# Note: must run all queries one at a time, split by semi colon
		# Should I check for malicious syntax possibilities ?



	&ReadFile($fileName);

	&RunQuery();

	&OutCome(@msg);






# read in the batch file
sub ReadFile {
	my ($file) = @_;

	$file =~ s/[^A-Za-z0-9._-]//g;
	$filePath .= $file;

	unless (open (QRY,"$filePath") ) { 
	&Err("<li><font color=red>Unable to open file. Check paths, check filename, etc.</font>");
	}

	@qry = <QRY>;

	# first line is batch file info
	$ver = shift(@qry);

	close(QRY);
	chop (@qry);

		foreach (@qry) {
	
			# save # note content
			# might need to look closer at this, not to interfere with any valid SQL stmt
			# unless line is commented, and if line is not Null

			if ($_ =~ /#/) {
			push(@notes,$_) if ($_ =~ /note/i);	

			} else {
			# don't store any blank lines
			$sql .= $_ if ($_) ;

			}
		}	

	# are there multiple queries ?
	@qry = split(/\;/,$sql);
	return @qry;
	}

# execute query
sub RunQuery {

	my $errmsg;

	# @qry is global and has SQL stmts
	my $i = scalar(@qry);
	push (@msg, "<p>Found $i queries in file <p>");

		$i = 1;
		foreach (@qry) {

		$sth = $dbh->prepare($_);

			if ($sth->execute) {

			# return : how to get what mySQL just did ??
			# and return that as statement for operation
			# $errmsg = $DBI::errstr;

			push (@msg,"<li>Query Num : $i successful");

			} else {
	        	$errmsg = $DBI::errstr;
			push (@msg,"<li><font color=red>Query Num : <b> $i </b> did not execute. Reason: <br>$errmsg </font>");

			}
			$i++;
		}

	$sth->finish;
	$dbh->disconnect;

	}

# browser
sub OutCome {
	my (@msg) = @_;

	my $note;
	$ver =~ s/#//g;

	if (scalar(@notes)) {
		foreach (@notes) {
		$note .= $_ ."<br>";
		}
	$note =~ s/#//g;
	$note =~ s/notes//gi;
	$note =~ s/note//gi;	
	}

	print "Content-Type: text/html\n\n";
	print "<html><body>";
	print "<h3>MOFcart v2.5 mySQL Utility</h3>";
	print "<b>$ver</b><p>";
	print "<b>NOTES:</b><br>$note<p>" if ($note);
	
	print "<b>Batch Outcome:</b>";	
	print "<ol>";
		foreach (@msg) {
			print "$_ <br>";
			}
	print "</ol>";
	print "</html></body>";
	exit;

	}

# browser
sub Err {
	my ($msg) = @_;
	print "Content-Type: text/html\n\n";
	print "<html><body>";	
	print "<h3>MOFcart v2.5 mySQL Utility : ERROR</h3>";
	print "$msg";
	print "</html></body>";
	exit;
	}



# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

