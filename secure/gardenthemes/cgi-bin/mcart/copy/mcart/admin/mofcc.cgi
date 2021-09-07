#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.12.08.04 ====================== #
# === SAVE CC INFO ================================================ #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

BEGIN {
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart/lib');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart/lib');
} 

require 'common.conf';

# key must match key in <mofsavecc.pl>
my($key) = 'ejekendijendaidendiand';
$setuid = 'lwftmb';
$cookiename_UserID = 'UserID';

# (1) recent invoices on top
$sort_descending = 1;

# Currency symbol
# $currency = '£';
# $currency = '€';
$currency = '$';

# Full http URL
$programfile = "$mvar_back_http_mcart/admin/mofcc.cgi";
$error_email = $merchantmail;
@ALLOWED_SERVER = ('');

# WHERE IS THE DATA FILE ?
$infofile_path = "$mvar_front_path_mcart/data/mofcc";

# Lockfiles MUST BE TURNED ON (Unix,Linx)
$lockfiles = 1 unless ($^O =~ m/mswin32/i);

# WHERE IS THE TEMPLATE FILE ?
# This is also absolute path, not Http url, or put it in your cgi-bin
$template = "$mvar_back_path_mcart/admin/temp_cc.html";

# Insert output at this point in template
$insertion_marker = '<!--INSERT_TEMPLATE_OUTPUT-->';

# Assign font attributed used in html output
$font1 = '<font face="Arial,Verdana,Helvetica" size="1" color="#000000">';
$font2 = '<font face="Arial,Verdana,Helvetica" size="2" color="#000000">';
$font3 = '<font face="Arial,Verdana,Helvetica" size="3" color="#000000">';
$font4 = '<font face="Arial,Verdana,Helvetica" size="4" color="#000000">';
# END CONFIGURATIONS


	# PROGRAM FLOW
	&SetDateVariable;
	if ($ENV{'QUERY_STRING'}) {
		$ErrMsg = "You cannot use this program this way.";
		&ErrorMessage($ErrMsg);
		}
		# check cookie
		# can't POST without a cookie
		# if no cookie present login
		# if cookie and matches PSWD check function
		# if function not found err
		@header = ();
		@footer = ();
		&GetTemplateFile($template, "Template File");
		@SELECTED_INVOICES = ();
		&ProcessForm;
		&CheckCookie;

	# START FUNCTIONS
	if ($UserID eq $setuid) {

		if ($frm{'FUNCTION'} eq "LOG_OUT") {
			&ExpireCookie($cookiename_UserID);
			&LOG_IN;

		} elsif ($frm{'FUNCTION'} eq "MAIN_MENU") {
			&MAIN_MENU;

		} elsif ($frm{'FUNCTION'} eq "LIST_ORDERS") {
			$pending = 0;
			@ALLINFO = ();
			@CC_INFO = ();
			@CHECK_INFO = ();
			@OTHER_INFO = ();
			&Get_Records;
			&Sort_Records;
			if ($pending) {
			&LIST_ORDERS;
			} else {				
			$MenuMsg = "There are no pending records .. <br>";
			%frm = ();
			&MAIN_MENU;
			}
			@CC_INFO = ();
			@CHECK_INFO = ();
			@OTHER_INFO = ();

		} elsif ($frm{'FUNCTION'} eq "DELETE_RECS") {
			@ALLINFO = ();
			($remove, $remain) = (0,0);
			&Delete_Invoice_Number();
			$MenuMsg = "Removed $remove Record(s), $remain Record(s) Remaining .. <br>";
			%frm = ();
			&MAIN_MENU;

     		# END FUNCTIONS #
		} else {
		# you may want to log back in here instead of err
		$ErrMsg = "Improper function requested.";
		$ErrMsg = $ErrMsg . "<p>If you are the administrator trying to log in ";
		$ErrMsg = $ErrMsg . "<br>Then close and restart your browser.";
		&ErrorMessage($ErrMsg);
		}
		
	} elsif ($frm{'Ecom_Password'} eq $setuid) {
		&MakeCookie($cookiename_UserID, $setuid);
		&MAIN_MENU;

	} else {
	&LOG_IN;
	}
	exit;

# STARTING LOGIN
sub LOG_IN {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print '<BLOCKQUOTE>';
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "$font2";
	print "<strong>Log In Required</strong></font>";
	print "<strong> - <font color=red>Log In Not Valid</font></strong></font>" if ($frm{'Ecom_Password'});
	print "<FORM method=POST action=\"$programfile\">";
	print '<table border=0 cellpadding=2 cellspacing=1><tr><td align=right bgcolor=#EEEEEE>';
	print "$font2";
	print 'Password</font></td><td bgcolor=#EEEEEE height="25">';
	print "$font2";
	print '<input name="Ecom_Password" size=12 type=password></font> </td>
	<td align=right bgcolor=#EEEEEE nowrap height="18"><p align="center">';
	print "<INPUT Class=\"ButtonFormat\" type=submit value=\"Log In\"></td>";
	print '</tr></table></FORM>';
	print "<p><b>Note</b>: Always log out before closing your browser.
	<p>If you close your browser before logging out, then you may have to 
	<br>change your password before you can get back in to the system.";
	print '</BLOCKQUOTE>';
	print "@footer \n\n";
	}

# MAIN MENU
sub MAIN_MENU {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "$font2";
	print "<strong>LOGGED IN: ADMIN MENU </strong></font> ";
	print "<INPUT Class=\"ButtonFormat\" type=submit value=\"Log Out\">";
	print "</FORM><p>";
		if ($Caution1) {
		print "<table border=0 cellpadding=2 cellspacing=0 width=95\%>";
		print "<tr><td bgcolor=#FFCE00>$font2 <strong>$Caution1 </strong></font></td></tr> \n";
		print "<tr bgcolor=#FFFFFF><td>$font2 $Caution2 </strong></td></tr>" if ($Caution2);
		print "</table>";
		}
		if ($MenuMsg) {
		print "<table border=0 cellpadding=2 cellspacing=0><tr><td bgcolor=#EFEFEF>";
		print "$font2 $MenuMsg </font></td></tr></table>"
		}
	print "<table border=0 cellpadding=2 cellspacing=3 bgcolor=\"white\" width=95%\%>";
	print "<tr><td colspan=3 align=right>$font1 $Date $ShortTime</font></td</tr> ";

	# MAIN MENU
	print "<tr><td align=center colspan=3 bgcolor=#99CCCC>$font2 <strong>";
	print "Orders Management</strong></td></tr> \n";

	# Listing Orders
	print "<tr>";
	print "<FORM name=\"form_list\" method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LIST_ORDERS\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2";
	print "List Stored Orders </font>";
	print "</td>";
	print "<td bgcolor=#99CCCC valign=center align=center>";
	print "$font2 ";
	print "<input Class=\"MenuButton\" type=\"submit\" name=\"button_list\" value='List Orders' onClick='form_list.button_list.value=\"Please Wait ... \";return true'>";
	print "</font>";
	print "</td>";
	print "<td bgcolor=#EAF4F4>$font2 Show a list of all Orders to settle <br> ";
	print "Retrieve credit card numbers for Orders </font></td> ";
	print "</FORM></tr>";

	# other menu items 
	print "</table>";
	print "@footer \n\n";
	}

# LIST ORDERS
sub LIST_ORDERS {
	my ($total);
	my (@REC)=();
	print "Content-Type: text/html\n\n";
	print "@header \n\n";

	print qq~
	<SCRIPT LANGUAGE="JavaScript">
	<!-- Begin
	function checkAll(field) {
	for (i = 0; i < field.length; i++)
	field[i].checked = true ;
	}
	function uncheckAll(field) {
	for (i = 0; i < field.length; i++)
	field[i].checked = false ;
	}
	//  End -->
	</script>
	~;
 
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>LISTING ORDERS &nbsp;&nbsp </strong></td> ";
	print "<td valign=top>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT Class=\"ButtonFormat\" type=submit value=\"Log Out\">";
	print "</FORM></td><td>&nbsp;</td>";
	print "<td valign=top>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT Class=\"ButtonFormat\" type=submit value=\"Menu\">";
	print "</FORM></td><td>&nbsp;</td>";
	print "<td bgcolor=#F5F5F5>$font2 ";
	print "Listing <b>pending credit card numbers</b>. Delete after copying. 
	Do <b>not</b> leave credit card numbers on the server after retrieval.</font></td>";
	print "<td>&nbsp;</td><td valign=top>";
	print "<INPUT Class=\"ButtonFormat\" type=\"button\" value=\"Delete\" onClick=\"javascript:document.formDeleteRecords.submit()\;\">";
	print "</td><td>&nbsp;</td></tr></table>";

	# Start Form
	print "<FORM name=\"formDeleteRecords\" method=\"POST\" action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"DELETE_RECS\">";

	# CC Numbers
	$total = scalar(@CC_INFO);
	if ($total) {
	print "<table border=0 cellpadding=2 bgcolor=#FFFFFF cellspacing=2 width=100\%>";
	print "<tr>";
	print "<td nowrap align=center bgcolor=#396DA5>";
	if ($total > 1) {
	print "<input Class=\"checkButtonFormat\" type=\"button\" name=\"CheckAll\" value=\"[x]\" onClick=\"checkAll(document.formDeleteRecords.InvcNumberCC)\">";
	print "<input Class=\"checkButtonFormat\" type=\"button\" name=\"UnCheckAll\" value=\"[  ]\" onClick=\"uncheckAll(document.formDeleteRecords.InvcNumberCC)\">";
	} else {print "<BR>"}
	print "</td>";
	print "<td colspan=2 nowrap bgcolor=#396DA5>$font2<font color=#FFFFFF><b>CREDIT CARD ORDERS : $total</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Amt</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Type</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Number</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Exp</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Start</b></font></font></td>";###CHANGE###
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Issue</b></font></font></td>";###CHANGE###
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>CVV</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Name/Phone</b></font></font></td>";
	print "</tr>\n";

	foreach (@CC_INFO) {
		@REC = split(/\|/,$_);
		print "<tr>";
		print "<td bgcolor=#F5F5F5 align=center>";
		if ($REC[34]) {
		print "$font2<a Class=\"TextLink\" href=\"$REC[34]\" target=\"_blank\"><b>$REC[0]</b></a></font></td>";
		} else {
		print "$font2 <b>$REC[0]</b></font></td>";
		}
		print "<td bgcolor=#EBF5FF>$font2 $REC[2]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[3]</font></td>";
      		$REC[5] = sprintf "%.2f", $REC[5];
      		$REC[5] = CommifyMoney($REC[5]);
		print "<td bgcolor=#EBF5FF>$font2 $currency $REC[5]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[6]</font></td>";
		print "<td bgcolor=#F5F5F5 align=center>$font2 <b>$REC[8]</b></font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[9]/$REC[10]</font></td>";
		if ($REC[35]) {
		print "<td bgcolor=#EBF5FF>$font2 $REC[35]/$REC[36]</font></td>";				###CHANGE###
		} else {																		###CHANGE###
		print "<td bgcolor=#EBF5FF>$font2 </font></td>";								###CHANGE###
		}																				###CHANGE###
		print "<td bgcolor=#EBF5FF align=center>$font2 $REC[37]</font></td>";			###CHANGE###
		print "<td bgcolor=#EBF5FF>$font2 $REC[11]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[7]</font></td>";
		print "</tr><tr>";
		print "<td bgcolor=#F5F5F5 align=center>$font2";
		print "<input type=\"checkbox\" name=\"InvcNumberCC\" value=\"$REC[0]\" checked=\"true\">";
		print "</font></td>";
		print "<td  bgcolor=#F5F5F5 colspan=9>$font2"; ###CHANGE###
		if ($REC[33]) {
		print "<a Class=\"TextLink\" href=\"mailto:$REC[33]\">$REC[19] $REC[20] $REC[21] $REC[22] $REC[23]</a> ";
		} else {
		print "$REC[19] $REC[20] $REC[21] $REC[22] $REC[23]";
		}
		print "	$REC[24] $REC[25] $REC[26] $REC[27] $REC[28] $REC[29] $REC[30] $REC[31]</font></td>";
		print "<td bgcolor=#F5F5F5>$font2 $REC[32]</font></td>";
		print "</tr><tr><td colspan=9><br></td></tr>";
		}
		print "</table> ";
		}
		# END cc Records

	# Checking Numbers
	$total = scalar(@CHECK_INFO);
	if ($total) {
	print "<table border=0 cellpadding=2 bgcolor=#FFFFFF cellspacing=2 width=100\%>";
	print "<tr>";
	print "<td nowrap align=center bgcolor=#396DA5>";
	if ($total > 1) {
	print "<input Class=\"checkButtonFormat\" type=\"button\" name=\"CheckAll\" value=\"[x]\" onClick=\"checkAll(document.formDeleteRecords.InvcNumberCK)\">";
	print "<input Class=\"checkButtonFormat\" type=\"button\" name=\"UnCheckAll\" value=\"[  ]\" onClick=\"uncheckAll(document.formDeleteRecords.InvcNumberCK)\">";
	} else {print "<BR>"}
	print "</td>";
	print "<td colspan=3 nowrap bgcolor=#396DA5>$font2<font color=#FFFFFF><b>CHECKING ACCOUNT ORDERS : $total</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Ck #</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Account #</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Routing #</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>F #</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Name/Phone</b></font></font></td>";
	print "</tr>\n";

	foreach (@CHECK_INFO) {
		@REC = split(/\|/,$_);
		print "<tr>";
		print "<td bgcolor=#F5F5F5 align=center>";
		if ($REC[34]) {
		print "$font2<a Class=\"TextLink\" href=\"$REC[34]\" target=\"_blank\"><b>$REC[0]</b></a></font></td>";
		} else {
		print "$font2 <b>$REC[0]</b></font></td>";
		}
		print "<td bgcolor=#EBF5FF>$font2 $REC[2]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[3]</font></td>";
      		$REC[5] = sprintf "%.2f", $REC[5];
      		$REC[5] = CommifyMoney($REC[5]);
		print "<td bgcolor=#EBF5FF>$font2 $currency $REC[5]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[13]</font></td>";
		print "<td bgcolor=#F5F5F5 align=center>$font2 <b>$REC[14]</b></font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[15]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[16]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[12]</font></td>";
		print "</tr><tr>";
		print "<td bgcolor=#F5F5F5 align=center>$font2";
		print "<input type=\"checkbox\" name=\"InvcNumberCK\" value=\"$REC[0]\" checked=\"true\">";
		print "</font></td>";
		print "<td  bgcolor=#F5F5F5 colspan=7>$font2";
		if ($REC[33]) {
		print "<a Class=\"TextLink\" href=\"mailto:$REC[33]\">$REC[19] $REC[20] $REC[21] $REC[22] $REC[23]</a> ";
		} else {
		print "$REC[19] $REC[20] $REC[21] $REC[22] $REC[23]";
		}
		print "	$REC[24] $REC[25] $REC[26] $REC[27] $REC[28] $REC[29] $REC[30] $REC[31]</font></td>";
		print "<td bgcolor=#F5F5F5>$font2 $REC[32]</font></td>";
		print "</tr><tr>";
		print "<td bgcolor=#F5F5F5><br></font></td>";
		print "<td colspan=8 bgcolor=#F5F5F5>$font2 Bank: $REC[17] $REC[18]</font></td>";
		print "</tr><tr><td colspan=9><br></td></tr>";
		}
		print "</table> ";
		}
		# END Checking Records

	# Other Orders
	$total = scalar(@OTHER_INFO);
	if ($total) {
	print "<table border=0 cellpadding=2 bgcolor=#FFFFFF cellspacing=2 width=100\%>";
	print "<tr>";
	print "<td nowrap align=center bgcolor=#396DA5>";
	if ($total > 1) {
	print "<input Class=\"checkButtonFormat\" type=\"button\" name=\"CheckAll\" value=\"[x]\" onClick=\"checkAll(document.formDeleteRecords.InvcNumberOT)\">";
	print "<input Class=\"checkButtonFormat\" type=\"button\" name=\"UnCheckAll\" value=\"[  ]\" onClick=\"uncheckAll(document.formDeleteRecords.InvcNumberOT)\">";
	} else {print "<BR>"}
	print "</td>";
	print "<td colspan=2 nowrap bgcolor=#396DA5>$font2<font color=#FFFFFF><b>OTHER ORDERS : $total</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Amount</b></font></font></td>";
	print "<td nowrap align=center bgcolor=#396DA5>$font1<font color=#FFFFFF><b>Type/Phone</b></font></font></td>";
	print "</tr>\n";

	foreach (@OTHER_INFO) {
		@REC = split(/\|/,$_);
		print "<tr>";
		print "<td bgcolor=#F5F5F5 align=center>";
		if ($REC[34]) {
		print "$font2<a Class=\"TextLink\" href=\"$REC[34]\" target=\"_blank\"><b>$REC[0]</b></a></font></td>";
		} else {
		print "$font2 <b>$REC[0]</b></font></td>";
		}
		print "<td bgcolor=#EBF5FF>$font2 $REC[2]</font></td>";
		print "<td bgcolor=#EBF5FF>$font2 $REC[3]</font></td>";
      		$REC[5] = sprintf "%.2f", $REC[5];
      		$REC[5] = CommifyMoney($REC[5]);
		print "<td bgcolor=#EBF5FF>$font2 $currency $REC[5]</font></td>";
		print "<td align=left bgcolor=#EBF5FF>$font2 $REC[6]</font></td>";
		print "</tr><tr>";
		print "<td bgcolor=#F5F5F5 align=center>$font2";
		print "<input type=\"checkbox\" name=\"InvcNumberOT\" value=\"$REC[0]\" checked=\"true\">";
		print "</font></td>";
		print "<td  bgcolor=#F5F5F5 colspan=3>$font2";
		if ($REC[33]) {
		print "<a Class=\"TextLink\" href=\"mailto:$REC[33]\">$REC[19] $REC[20] $REC[21] $REC[22] $REC[23]</a> ";
		} else {
		print "$REC[19] $REC[20] $REC[21] $REC[22] $REC[23]";
		}
		print "	$REC[24] $REC[25] $REC[26] $REC[27] $REC[28] $REC[29] $REC[30] $REC[31]</font></td>";
		print "<td bgcolor=#F5F5F5>$font2 $REC[32]</font></td>";
		print "</tr><tr><td colspan=5><br></td></tr>";
		}
		print "</table>";
		}
		# END Other Records

	print "<INPUT Class=\"BottomButton\" type=\"submit\" value=\"Delete Marked Records\">";
	print "</FORM>";
	print "@footer \n\n";
	}
# END LIST ORDERS

# DELETE INVOICE NUMBER
sub Delete_Invoice_Number {
	my (@REC) = ();
	my (@NEWINFO) = ();
	my ($row, $inv, $dcrypt);
	my ($delete) = 0;
	unless (open (FILE, "+< $infofile_path") ) { 
		$ErrMsg = "Unable to Access Data File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		chop (@ALLINFO);
		seek (FILE, 0, 0);
	foreach $row (@ALLINFO) {
	$dcrypt = &Decrypt($row, $key);
	@REC = split(/\|/,$dcrypt);
		foreach $inv (@SELECTED_INVOICES) {
		$delete++ if ($inv == $REC[0]);
		}
		if ($delete) {
		$remove++;
		} else {
		push (@NEWINFO, $row);
		$remain++;
		}
	$delete = 0;
	}
	foreach (@NEWINFO) {
	print FILE "$_\n"
	}
	truncate(FILE, tell(FILE));
	close(FILE);
	@ALLINFO = ();
	@NEWINFO = ();
	return ($remove, $remain);
	}

# SORT-DECRYPT
sub Sort_Records {
	my (@REC)=();
	my ($cpOID) = "";
	my ($cpCC) = "";
	my ($cpCK) = "";
	my ($str) = "";
	foreach (@ALLINFO) {
	$str = &Decrypt($_, $key);
	@REC = split(/\|/, $str);
		if ($REC[8]) {
		push (@CC_INFO, $str);
		} elsif ($REC[14]) {
		push (@CHECK_INFO, $str);
		} else {
		push (@OTHER_INFO, $str);
		}
	}
	# sort
	if ($sort_descending) {
	@CC_INFO = sort {$b <=> $a} (@CC_INFO);
	@CHECK_INFO = sort {$b <=> $a} (@CHECK_INFO);
	@OTHER_INFO = sort {$b <=> $a} (@OTHER_INFO);
	} else {
	@CC_INFO = sort {$a <=> $b} (@CC_INFO);
	@CHECK_INFO = sort {$a <=> $b} (@CHECK_INFO);
	@OTHER_INFO = sort {$a <=> $b} (@OTHER_INFO);
	}
	$pending = scalar(@ALLINFO);
	@ALLINFO = ();
	return (@CC_INFO, @CHECK_INFO, @OTHER_INFO, $pending);
  	}

# GET RECORDS
sub Get_Records {
unless (open (FILE, "$infofile_path") ) { 
	$ErrMsg = "Unable to Read Information File";
	&ErrorMessage($ErrMsg);
	}	
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	return @ALLINFO;
	}

# DECRYPT
sub Decrypt {
    my ($encrypted, $key) = @_;
    $encrypted = decode_base64($encrypted);
    my ($cr,$index,$char,$key_char,$decrypted);
    while ( length($key) < length($encrypted) ) { $key .= $key }
    $key=substr($key,0,length($encrypted));
    $index=0;
    while( $index < length($encrypted) ) {
        $char = substr($encrypted,$index,1);
        $key_char = substr($key,$index,1);
        $decrypted .= chr(ord($char) ^ ord($key_char));
        $index++;
    }
    $cr = '``'; 
    $decrypted =~ s/$cr/\r/g;
    return &rot13( $decrypted );
}

sub rot13{
    my $source = shift (@_);
    $source =~ tr /[a-m][n-z]/[n-z][a-m]/;
    $source =~ tr /[A-M][N-Z]/[N-Z][A-M]/;
    $source = reverse($source);
    $source;
}

sub decode_base64{
    local($^W) = 0;
    my $str = shift;
    my $res = "";
    $str =~ tr|A-Za-z0-9+=/||cd;
    if (length($str) % 4) {
    die "Base64 decoder requires string length to be a multiple of 4"
    }
    $str =~ s/=+$//;
    $str =~ tr|A-Za-z0-9+/| -_|;
    while ($str =~ /(.{1,60})/gs) {
    my $len = chr(32 + length($1)*3/4);
    $res .= unpack("u", $len . $1 );
    }
    $res;
}

# PROCESS FORM	
sub ProcessForm {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);
	foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/\n\r//d;
	$frm{$name} = $value;
	push (@SELECTED_INVOICES, $value) if ($name =~ /InvcNumber/);
	}
	}

# CHECK ALLOWED DOMAINS
sub CheckAllowedDomains {
	my ($domain_approved) = 0;
	my ($domain_referred) = $ENV{'HTTP_REFERER'};
	$domain_referred =~ tr/A-Z/a-z/;
  	foreach (@ALLOWED_DOMAINS) {
     		if ($domain_referred =~ /$_/) { 
		$domain_approved++;	
		}
	   	}
	unless ($domain_approved) {
		$ErrMsg="This is not an authorized input area <br>";
		$ErrMsg=$ErrMsg . "$ENV{'HTTP_REFERER'} <p>";
		$ErrMsg=$ErrMsg . "These are the only authorized input areas:<br>";
		foreach (@ALLOWED_DOMAINS) {
		$ErrMsg=$ErrMsg . "<a href=\"$_\">$_</a><p>";
		}
		&ErrorMessage($ErrMsg);
		}
	}

# SET DATE
sub SetDateVariable {
	local (@months) = ('January','February','March','April','May','June','July',
			'August','September','October','November','December');
	local (@days) = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
 	local ($sec,$min,$hour,$mday,$mon,$year,$wday) = (localtime(time))[0,1,2,3,4,5,6];
	$year += 1900;	
 	$Date = "$days[$wday], $months[$mon] $mday, $year";
 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mon+1,'/',$mday,'/',$year);
 	$Time = sprintf("%02d%1s%02d%1s%02d",$hour,':',$min,':',$sec);
	$pass_year = $year;
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour<12);
	$ShortTime="12:".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour==0);
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour==12);
	$ShortTime=($hour-12).":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour>12);
	 }

# MAKE GMT UNIX TIME
sub MakeUnixTime {
	local ($now) = time;
 	local ($expires) = @_;
 	$expires += $now;
 	local (@days) = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
 	local (@months) = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
 	local ($sec,$min,$hour,$mday,$mon,$year,$wday) = gmtime($expires); 
 	$sec = "0" . $sec if $sec < 10; 
 	$min = "0" . $min if $min < 10; 
 	$hour = "0" . $hour if $hour < 10; 
 	$year += 1900; 
  	$expires = "$days[$wday], $mday-$months[$mon]-$year $hour:$min:$sec GMT"; 
  	return $expires;
  	}

# CHECK FOR COOKIE
sub CheckCookie {
	$cookies = $ENV{'HTTP_COOKIE'};
	@cookie = split (/;/, $cookies);
    	foreach (@cookie) {
   	($name, $value) = split(/=/, $_);
	$UserID=$value if ($name =~ /\b$cookiename_UserID\b/);
	}
  return ($UserID);
  }

# EXPIRE COOKIE
sub ExpireCookie {
	my ($name_for_cookie) = @_;
	print "Set-Cookie: $name_for_cookie=$ID;expires=Sat, 1-Jan-2000 12:12:12 GMT \n";	
  }

# SET NEW COOKIE
sub MakeCookie {
	my ($name_for_cookie, $ID) = @_;
	print "Set-Cookie: $name_for_cookie=$ID\n";
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

# ERROR MESSAGE
sub ErrorMessage {
	my ($Err) = @_;
	my ($gmt) = &MakeUnixTime(0);	
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Error Message</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";
	print "<table bgcolor=#FFCE00 border=0 cellpadding=4 cellspacing=0 width=100\%>";
	print "<tr><td>$font2 <strong>Error Message .. </strong> </td></tr></table><p>";
      	print "<h4>$Err</h4>\n";
	print "Contact: <a href=\"mailto:$error_email\">$error_email</a><p>" if ($error_email);
	print "<ul>";
	print "<li>Local Time: $Date $Time<br>";
	print "<li>GMT Time: $gmt";
	print "<li>Referring URL: $ENV{'HTTP_REFERER'}" if ($ENV{'HTTP_REFERER'});
	print "<li>Server Name: $ENV{'SERVER_NAME'}" if ($ENV{'SERVER_NAME'});
	print "<li>Server Protocol: $ENV{'SERVER_PROTOCOL'}" if ($ENV{'SERVER_PROTOCOL'});
	print "<li>Server Software: $ENV{'SERVER_SOFTWARE'}" if ($ENV{'SERVER_SOFTWARE'});
	print "<li>Gateway: $ENV{'GATEWAY_INTERFACE'}" if ($ENV{'GATEWAY_INTERFACE'});
	print "<li>Remote Host: $ENV{'REMOTE_HOST'}" if ($ENV{'REMOTE_HOST'});
	print "<li>Remote Addr: $ENV{'REMOTE_ADDR'}" if ($ENV{'REMOTE_ADDR'});
	print "<li>Remote User: $ENV{'REMOTE_USER'}" if ($ENV{'REMOTE_USER'});
	print "</ul><br><br></body></html>";
	exit;	
	}

# FORMAT NUMBERS
sub CommifyNumbers {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
    	return $_;
  	}

# FORMAT MONEY
# Change this to alter how money is formatted
# The sprintf function throughout mof.cgi creates the 2 decimils
sub CommifyMoney {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
    	return $_;
  	}

# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

