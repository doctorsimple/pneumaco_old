#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === SSI GET MOFcart DATA ======================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# SSI Get MOFcart data : RGA : 2-11-02
# Place this script in same DIR as <mof.cgi>,<mof.conf>,<moflib.pl>
# When called as SSI include/execute it will check cart and return totals
# You can also specify what URL gets passed as "continue shopping" from link
# Send : ../mofget.cgi?ret_url=http://www.full-url-to-page.html
# Script will also compute/include any Primary Discount computations as per <mof.conf>
# Note: Script will not compute Coupon and/or ARES discounts

# If SSI include has problems retrieving cookie as MOFcart sets it
# Try adding a path=/ to the Set-Cookie header in the <moflib.pl> 
# And then delete all MOFcart cookies so they reset to path=/

# SET NEW COOKIE <moflib.pl>
# print "Set-Cookie: $name_for_cookie=$ID;expires=$expirestime;path=/\n";

BEGIN {
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart/lib');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart');
push(@INC, '/home/gardenth/public_html/cgi-bin/mcart/lib');
} 

require 'common.conf';
require 'mof.conf';
require 'moflib.pl';
# cookie names must be the same in both program files
$cookiename_OrderID = 'mof_v25_OrderID';
$cookiename_InfoID = 'mof_v25_InfoID';	

# override <mof.conf> formatting
# table totals
# $totalback = '#FFFFDF';
# $totalcolor = '<font face="Arial,Helvetica" size=2 color=#000066>';
# $totaltext = '<font face="Arial,Helvetica" size=2 color=#000066>';

# include Primary Discount computations
$include_discount = 1;

# Show only one line total, adjusted to include Primary Discount
# Note: $include_discount must be enabled to compute discount first
$totals_only = 0;

# link msg to viewcart (requires full URL as $programfile in mof.conf)
$link_msg = 1;


	# Program Flow
	%Computations = ();
	$cookieOrderID = "";
	$cookieInfoID = "";
	my($q,$i,$d,$p,$s,$t);	
	my($totalqnty,$totalprice) = (0,0);

	&GetQryStr;
	&CheckCookie;
	&ReadDataFile($cookieOrderID) if ($cookieOrderID);

	foreach (@orders) {
	($q,$i,$d,$p,$s,$t) = split(/$delimit/);
		$totalqnty += ($q);
		$totalprice += ($q * $p);
 		}
	
	my($str) = "item";
	$str .= "s" if ($totalqnty > 1);

	# Primary Discount
	$Computations{'Primary_Price'} = $totalprice;
	$Computations{'Primary_Products'} = $totalqnty;
	$Computations{'Primary_Discount'} = &ComputeDiscount if (scalar(@use_discount) && $include_discount);
	my ($discountline) = $Computations{'Primary_Discount'};
	$discounttotal = ($totalprice - $Computations{'Primary_Discount'});
	$totalprice = $discounttotal if ($discountline > 0 && $totals_only);
	$discounttotal = sprintf "%.2f", $discounttotal;
	$discounttotal = CommifyMoney ($discounttotal);
	$Computations{'Primary_Discount'} = CommifyNumbers($Computations{'Primary_Discount'});
	$totalprice = sprintf "%.2f", $totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);

	# HTML OUTPUT
	# uncomment the Content-Type if server requires that
   	print "Content-type: text/html\n\n";

	if (scalar(@orders)) {
	print "<table border=0 cellpadding=1 cellspacing=0>\n";
	print "<tr><td align=right>$totaltext \n";

	if ($link_msg) {
	print "<a href=\"$programfile?viewcart";
	print "\&previouspage=$qry{'ret_url'}" if ($qry{'ret_url'});
	print "\">";
	}

	print "$totalqnty $str in cart : ";
	print "</a>" if ($link_msg);
	print "</font></td>\n";
	print "<td bgcolor=$totalback align=right nowrap>";
	print "$totalcolor ";
	print "$currency $totalprice ";
	print "</font></td></tr>\n";

	# default discount
	unless ($totals_only) {
	if ($discountline > 0 || $Computations{'Primary_Discount_Line_Override'}) {
	print "<tr><td align=right>$totaltext \n";
	print "$Computations{'Primary_Discount_Status'} : </font></td> \n";
	print "<td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor ";
		if ($discountline == 0 && $Computations{'Primary_Discount_Amt_Override'}) {
		print "$Computations{'Primary_Discount_Amt_Override'} ";
		} else {
		print "<font color=red>-</font> $currency $Computations{'Primary_Discount'} ";
		}
	print "</font></td></tr>\n";
	}}

	# sub total after default discount
	unless ($totals_only) {
	if ($discountline > 0 || $Computations{'Primary_Discount_Line_Override'}) {
	print "<tr><td align=right>$totaltext <strong> Subtotal \n";
	print "After Discount</strong> : </font></td> \n";
	print "<td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $discounttotal </font></td></tr>\n";
	}}

	print "</table>\n";

	# no items in cart
	} else {
	print "<table border=0 cellpadding=1 cellspacing=0>\n";
	print "<tr><td align=right>$totaltext \n";
	print "0 items in cart : ";	
	print "</font></td>\n";
	print "<td bgcolor=$totalback align=right nowrap>";
	print "$totalcolor ";
	print "$currency 0.00 ";
	print "</font></td></tr>\n";
	print "</table>\n";
	}

# QUERY STRING
sub GetQryStr {
	$buffer = $ENV{'QUERY_STRING'};
  	@pairs = split(/&/, $buffer);
  	foreach $pair (@pairs) {
   	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
   	$qry{$name} = $value;
	}}



exit;

# END MERCHANT ORDERFORM Cart ver 2.4
# Copyright by RGA 2000- 2001
