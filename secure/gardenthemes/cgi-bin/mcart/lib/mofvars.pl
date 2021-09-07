#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === SIMPLE SCRIPT TO TEST GET/POST ============================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# MAKE THESE CONFIG SETTINGS
# AND ADJUST THE MESSAGE FOOTERS IN THE SCRIPT BODY

# Where is the Return Message template ?
$return_info_template = 'formtest.html';

# Insertion marker
$insertion_marker = '<!--MOF-INPUT-AREA-->';

# $currency = '£';
# $currency = '€';
$currency = '$';

$font1 = '<font face="Arial, Verdana,Helvetica,Arial" size="1" color="#000000">';
$font2 = '<font face="Arial, Verdana,Helvetica,Arial" size="2" color="#000000">';
$font3 = '<font face="Arial, Verdana,Helvetica,Arial" size="3" color="#000000">';
@TempSort = ();
$primary_n;


# PROGRAM FLOW
	&ProcessInput;
	@header = ('<html><body>');
	@footer = ('</body></html>');
	# &GetTemplateFile($return_info_template,"Return Template File"); 
	&PrintResults;
	
# PROCESS INPUT
sub ProcessInput {
	$buffer = $ENV{'QUERY_STRING'};
  	@pairs = split(/&/, $buffer);
  	foreach $pair (@pairs) {
   		($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$qry{$name} = $value;
	    	}

	# populate all POST info
	@orders = ();
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);
	foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/"/ /;
	push (@orders, $value) if ($name eq "order");
	$frm{$name} = $value;
    	}}



# RESULTS	
sub PrintResults {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";


	# GET
	@TempSort = sort {uc($a) cmp uc($b)} (keys %qry);
	$primary_n = scalar(@TempSort);

	print "<h4>GET input ..</h4>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100\%> \n";
	print "<tr bgcolor=#84B5CE><td>$font2 <strong>All Field Name(s) returned";
	print "</strong></font></td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100\%> \n";
	print "<tr bgcolor=#CCCCCC> ";
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>Exact Field Name</strong></font></td> ";
	print "<td align=center>$font2 <strong>Value Submitted</strong></font></td> ";
	print "</tr>\n\n";
		$switch = 1;
		$count =1;
	foreach (@TempSort) {
	print "<tr bgcolor=#C9DCEE>" if ($switch);
	print "<tr bgcolor=#EEEEEE>" unless ($switch);
	print "<td align=center nowrap>$font2 $count</font></td> ";
	print "<td nowrap>$font2 <font color=#626262>name=\"</font><strong>$_</strong><font color=#626262>\" ";
	print "</font></font></td> ";
		if ($qry{$_}) {
		print "<td>$font2 $qry{$_}</font></td> ";
		} else {
		print "<td>$font2 <font color=red><b>No Data Present</b></strong></font></td> ";
		}
	print "</tr> \n";
		if ($switch) {
		$switch = 0;
		} else {
		$switch = 1;
		}
	$count++;
	}
	print "</table><p>";



	# POST
	@TempSort = sort {uc($a) cmp uc($b)} (keys %frm);
	$primary_n = scalar(@TempSort);

	print "<h4>POST input ..</h4>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100\%> \n";
	print "<tr bgcolor=#84B5CE><td>$font2 <strong>All Field Name(s) returned";
	print "</strong></font></td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100\%> \n";
	print "<tr bgcolor=#CCCCCC> ";
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>Exact Field Name</strong></font></td> ";
	print "<td align=center>$font2 <strong>Value Submitted</strong></font></td> ";
	print "</tr>\n\n";
		$switch = 1;
		$count =1;
	foreach (@TempSort) {
	print "<tr bgcolor=#C9DCEE>" if ($switch);
	print "<tr bgcolor=#EEEEEE>" unless ($switch);
	print "<td align=center nowrap>$font2 $count</font></td> ";
	print "<td nowrap>$font2 <font color=#626262>name=\"</font><strong>$_</strong><font color=#626262>\" ";
	print "</font></font></td> ";
		if ($frm{$_}) {
		print "<td>$font2 $frm{$_}</font></td> ";
		} else {
		print "<td>$font2 <font color=red><b>No Data Present</b></strong></font></td> ";
		}
	print "</tr> \n";
		if ($switch) {
		$switch = 0;
		} else {
		$switch = 1;
		}
	$count++;
	}
	print "</table><p>";



	# HOW TO PROCESS @ORDERS
	# HOW TO PROCESS @ORDERS

	# How many products are in the @orders array ?
	my($tot) = scalar(@orders);

	# display some stuff
	print "<h4>\@orders input ..</h4>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100\%> \n";
	print "<tr bgcolor=#84B5CE><td>$font2 <strong>How To Process \@orders array : Current \@orders array contains $tot Elements";
	print "</strong></font></td></tr></table>\n";

	# set up table titles
	print "<table border=0 cellpadding=2 cellspacing=2 width=100\%> \n";
	print "<tr bgcolor=#CCCCCC>";
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>ITEM</strong></font></td> ";
	print "<td align=center>$font2 <strong>DESC</strong></font></td> ";
	print "<td align=center>$font2 <strong>PRICE</strong></font></td> ";
	print "<td align=center>$font2 <strong>SHIP</strong></font></td> ";
	print "<td align=center>$font2 <strong>TAX</strong></font></td> ";
	print "</tr>";

	# HOW TO SORT THROUGH THE @ORDERS ARRAY	
	
	# loop foreach element (line) in @orders
	# Each element (line) contains the data for *one* product in the cart
	# Format : value="QTY----ITEM----DESC----PRICE----SHIP----TAX"

	foreach(@orders) {

	# split the individual fields in each element (line) from format
	# QTY---ITEM----DESC----PRICE----SHIP----TAX
  	($q,$i,$d,$p,$s,$t) = split (/----/,$_);

		# pseudo html replacement (if any exists) for ITEM only (for now)
 		$i =~ s/\[/</g;
		$i =~ s/\]/>/g;

	# ROW ONE ---- ROW ONE ---- ROW ONE ----------------------->
	# do something with each field from each element (line) : start row
	print "<tr bgcolor=#EEEEEE>";

	# field one : quantity of that product ordered
	print "<td align=center>$font2 $q</font></td> ";

	# field two : Item Name
	print "<td align=center>$font2 $i</font></td> ";

	# field three : DESC (description)
	# data in this field uses a seperate set of delimiters to sort out Options :: Values
	# (if any are associated with the product)
	# If no Options :: Values are associated with the product then DESC contains only the DESC

	# Here is the RAW data in DESC field
	# See the next Table Row (below) for how to break down the Options :: Values
	print "<td align=center>$font2 $d</font></td> ";

	# field four : Price : 00.00
	print "<td align=center>$font2 $p</font></td> ";

	# field five : Shipping Flag or ShipCode
	print "<td align=center>$font2 $s</font></td> ";

	# field six : Tax Flag or Taxcode
	print "<td align=center>$font2 $t</font></td> ";

	# end row
	print "</tr>";

	# ROW TWO ---- ROW TWO ---- ROW TWO -----------------------> start row
	# How to to breakdown the RAW DESCription data into seperate Options :: Values
	print "<tr bgcolor=#C9DCEE>";

	# split up the RAW DESC data into respective Options :: Values (using temp @list)
	# delimited by pipe char |
	@list = split (/\|/,$d);

	# extract *only* the first element (line) containing the BASE Product DESCription
	$d = shift (@list);

		print "<td bgcolor=#EEEEEE align=left>$font2 <br></font></td> ";

		# show the RAW data output for BASE Product DESCription
		print "<td align=left>$font2 <b><u>BASE Product Description RAW data</u></b><br>$d <br>";

		# pseudo html replacement (if any exists) for DESCription
 		$d =~ s/\[/</g;
		$d =~ s/\]/>/g;

		# now show the pseudo formatted output for BASE product Description
		print "<b><u>BASE Product Description HTML format (if any)</u></b><br>$d </font></td> ";

		
		# show the Options :: Values that exist (if any) for the Product
		print "<td colspan=4 align=left>$font2 <b><u>Options :: Values Split Up</u></b><br>";

		# just counter vars
		my($count) = 1;

		# @list now contains only the Optional input	
		# we extracted the BASE Product DESc w/ shift above	
		# So, loop through Options :: Values (one pair per line)
		foreach $line (@list) {

			# pseudo html replacement (if any exists)
 			# $l =~ s/\[/</g;
			# $l =~ s/\]/>/g;

			# Split up the Options :: Values delimited by double colon ::
			($opt,$val) = split (/::/,$line);

			# do something with each Option :: Value Pair
			print "<b>Option => Value  $count</b> : $opt  => $val <br>";
			
				# increment for counter
				$opt++;
				$val++;

		}
		# end row 2
		print "</font></td> ";

	# end row 1
	print "</tr>";

	}

	# end
	print "</table><p>";

	print "@footer \n\n";
	}


# GET TEMPLATE FILE
sub GetTemplateFile {
	my ($FilePath, $Type) = @_;
	my (@template) = ();
	my ($line, $switch) = ("",0);
	unless (open (FILE, "$FilePath") ) { 
		$ErrMsg = "Unable to Read Template File: $Type";
		&ErrorMessage($ErrMsg);
		}
		@template = <FILE>;
		foreach $line (@template) {
		$switch=1 if ($line =~ /$insertion_marker/i);
			if ($switch) {
			push (@footer, $line);
			} else {
			push (@header, $line);
			}
		}
	}


# PASS ERROR MESSAGE
sub ErrorMessage {
	my ($Err) = @_;
	print "Content-Type: text/html\n\n";
	print "<html><head><title>MOF v1.53 Error</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";
	print "<h3>Merchant OrderForm v1.53 Data Processing Error</h3>";
        print "<h4>$Err</h4>\n";
	print "<u>Data Processing Information Available</u><br>";
	print "<li>Referring URL: $ENV{'HTTP_REFERER'}" if ($ENV{'HTTP_REFERER'});
	print "<li>Server Name: $ENV{'SERVER_NAME'}" if ($ENV{'SERVER_NAME'});
	print "<li>Server Protocol: $ENV{'SERVER_PROTOCOL'}" if ($ENV{'SERVER_PROTOCOL'});
	print "<li>Server Software: $ENV{'SERVER_SOFTWARE'}" if ($ENV{'SERVER_SOFTWARE'});
	print "<li>Gateway: $ENV{'GATEWAY_INTERFACE'}" if ($ENV{'GATEWAY_INTERFACE'});
	print "<li>Remote Host: $ENV{'REMOTE_HOST'}" if ($ENV{'REMOTE_HOST'});
	print "<li>Remote Addr: $ENV{'REMOTE_ADDR'}" if ($ENV{'REMOTE_ADDR'});
	print "<li>Remote User: $ENV{'REMOTE_USER'}" if ($ENV{'REMOTE_USER'});
	print "<p><font face=\"Arial,Helvetica\" size=1 color=gray>";
	print "<strong>Merchant OrderForm v2.4 \© Copyright ";
	print "<a href=\"http://www.merchantpal.com/\">RGA</a></strong>\n";
	print "</body></html>";
	exit;	
	}



	# END OF FILE
	# END OF FILE







