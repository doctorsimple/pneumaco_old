#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.12.08.04 ====================== #
# === CART FRONT END PROGRAM FLOW : ORDER PREVIEW ================= #
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
require 'mof.conf';
require 'moflib.pl';
# cookie names must be the same in both program files
$cookiename_OrderID = 'mof_v25_OrderID';
$cookiename_InfoID = 'mof_v25_InfoID';
# PROGRAM FLOW
# AcceptOrder / AcceptOrderPop (v2.5)
# PreviewInformation
# PreviewOrder
&SetDateVariable;
&RunTestMode if ($ERRORMODE==0 && $ENV{'QUERY_STRING'} =~ /^test/i);
 # qry
 if ($ENV{'QUERY_STRING'}) {
	&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
	&ProcessQueryString;
	&CheckCookie;
	if ($view) {
		if ($cookieOrderID) {
		$frm{'previouspage'} = substr ($ENV{'QUERY_STRING'},22);
		&ReadDataFile($cookieOrderID);
		$msg_function = "What's In Your Cart ?";
		# split : August 04, 2003 7:59:21 PM
		require $mof_view_pg;
		&AcceptOrder;
		} else {
		print "Location: $cookieredirect\n\n";
		exit;
		}
	} else {
		if ($cookieOrderID) {
		&ReadDataFile($cookieOrderID);
		&ProcessDataFile;
		# added Volume Price adjustments : 12-17-04
		&ProcessVolumePricing() if($mofPriceList);
		&WriteDataFile($cookieOrderID);
		$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
		$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);
			if ($msg_d) {
			$msg_function .= ", $msg_d Duplicate Item" if ($msg_d == 1);
			$msg_function .= ", $msg_d Duplicate Items" if ($msg_d != 1);
			}
			# split : August 04, 2003 7:59:21 PM
			require $mof_view_pg;
			&AcceptOrder;
		} else {
		&GenerateOrderID;
		&MakeCookie($cookiename_OrderID, $OrderID);
		@orders = @NewOrder;
		# added Volume Price adjustments : 12-17-04
		&ProcessVolumePricing() if($mofPriceList);
		&WriteDataFile($OrderID);
		$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
		$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);
		# split : August 04, 2003 7:59:21 PM
		require $mof_view_pg;
		&AcceptOrder;
		}
	}
 # post
 } else {
	&ProcessForm;
	&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
	# POSTMODE = SINGLEPOST-CHECKBOXES-QUANTITYBOXES
	if (
	($frm{'postmode'} eq "SINGLEPOST") or
	( $frm{'postmode'} eq "CHECKBOXES") or 
	($frm{'postmode'} eq "QUANTITYBOXES")
	) {
		&CheckCookie;
		if ($cookieOrderID) {
		&ReadDataFile($cookieOrderID);
		&ProcessDataFile;
		# added Volume Price adjustments : 12-17-04
		&ProcessVolumePricing() if($mofPriceList);
		&WriteDataFile($cookieOrderID);
		$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
		$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);
			if ($msg_d) {
			$msg_function .= ", $msg_d Duplicate Item" if ($msg_d == 1);
			$msg_function .= ", $msg_d Duplicate Items" if ($msg_d != 1);
			}
			# Adding POPUP 3-02-02 triggers (cookie)
				if ($frm{'POP_TARGET'}) {
					# <mof.cgi> will handle REDIRECT_URL to "POPUP" window
					# the lib JavaScript will not open Alt win just focus() the POPUP				
					if ($frm{'REDIRECT_URL'} && $frm{'POP_TARGET'} eq "POPUP") {
					print "Location: $frm{'REDIRECT_URL'}\n\n";
					} else {
					# split : August 04, 2003 7:59:21 PM
					require $mof_view_pg;
					&AcceptOrderPop;
					}
				} else {
				if ($frm{'REDIRECT_URL'}) {
				print "Location: $frm{'REDIRECT_URL'}\n\n";
				} else {
				# split : August 04, 2003 7:59:21 PM
				require $mof_view_pg;
				&AcceptOrder;
				}
				}
		} else {
		&GenerateOrderID;
		&MakeCookie($cookiename_OrderID, $OrderID);
		@orders = @NewOrder;
		# added Volume Price adjustments : 12-17-04
		&ProcessVolumePricing() if($mofPriceList);
		&WriteDataFile($OrderID);
		$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
		$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);
		# Adding POPUP 3-02-02 triggers (no cookie)
			if ($frm{'POP_TARGET'}) {
				if ($frm{'REDIRECT_URL'} && $frm{'POP_TARGET'} eq "POPUP") {
				print "Location: $frm{'REDIRECT_URL'}\n\n";
				} else {
				# split : August 04, 2003 7:59:21 PM
				require $mof_view_pg;
				&AcceptOrderPop;
				}
			} else {
			if ($frm{'REDIRECT_URL'}) {
			print "Location: $frm{'REDIRECT_URL'}\n\n";
			} else {
			# split : August 04, 2003 7:59:21 PM
			require $mof_view_pg;
			&AcceptOrder;
			}
			}
		}
	# update
	} elsif ($frm{'postmode'} eq "UPDATE") {
		&CheckCookie;
		if ($cookieOrderID) {
		$OrderID = $frm{'OrderID'};
		@orders = @NewOrder;
		# added Volume Price adjustments : 12-17-04
		&ProcessVolumePricing() if($mofPriceList);
		&WriteDataFile($OrderID);
		$msg_function = "Updated $msg_i Cart Item" if ($msg_i == 1);
		$msg_function = "Updated $msg_i Cart Items" if ($msg_i != 1);
		# split : August 04, 2003 7:59:21 PM
		require $mof_view_pg;
		&AcceptOrder;
		} else {
		print "Location: $cookieredirect\n\n";
		exit;
		}
	# delete
	} elsif ($frm{'postmode'} eq "DELETE") {
		$msg_i = $frm{'deleted_items'};
		&CheckCookie;
		if ($cookieOrderID) {
		$OrderID = $frm{'OrderID'};
		&WriteDataFile($OrderID);
		$msg_function = "Deleted $msg_i Cart Item" if ($msg_i == 1);
		$msg_function = "Deleted $msg_i Cart Items" if ($msg_i != 1);
		# split : August 04, 2003 7:59:21 PM
		require $mof_view_pg;
		&AcceptOrder;
		} else {
		print "Location: $cookieredirect\n\n";
		exit;
		}
	# preview
	} elsif ($frm{'postmode'} eq "PREVIEW") {
		# globals
		@UsingInfoFields = ();
		@MasterInfoList = ();
		%MissingInfoFields = ();
		$UseStateProv = 0;
		%Computations = ();
		&CheckCookie;
		$OrderID = $frm{'OrderID'};
		$InfoID = $cookieInfoID if ($cookieInfoID);
		$InfoID = $frm{'InfoID'} if $frm{'InfoID'};
		@orders = @NewOrder;
		# preview decision
		if (&CheckFieldsNeeded) { 
			if ($cookieOrderID) {
				if ($frm{'submit_preview_info'} eq "NEWSUBMIT") {
				&ReadNewInfo;
				&WriteInfoFile($InfoID);
				$msg_function = "NEWSUBMIT";
				} elsif ($frm{'submit_preview_info'} eq "EDITING") {
				&ReadInfoFile($InfoID);
				$msg_function = "EDITING";
				} else {
					if ($cookieInfoID) {
					$InfoID = $cookieInfoID;
					&ReadInfoFile($InfoID);
					$msg_function = "FOUNDATA";
					} else {
					&GenerateInfoID;
					&MakeNullList;
					$msg_function = "NEWLIST";
					}
				}
			} else {
			print "Location: $cookieredirect\n\n";
			exit;
			} 
		} else {
			if ($cookieOrderID) {
			$msg_function = "Nothing Needed";
			&MakeComputations;
			# split : August 04, 2003 7:59:21 PM
			require $mof_preview_pg;
			&PreviewOrder;
			exit;
			} else {
			print "Location: $cookieredirect\n\n";
			exit;
			}
		} 
		# end decision
		&MakeCookie($cookiename_InfoID, $InfoID);
		if (&CheckUsingInfoFields) {
		# split : August 04, 2003 7:59:21 PM
		require $mof_shipto_pg;
		&PreviewInformation;
		} else {
			if ($frm{'submit_preview_info'} eq "EDITING") {
			# split : August 04, 2003 7:59:21 PM
			require $mof_shipto_pg;
			&PreviewInformation;
			} else {
			&MakeComputations;
			# split : August 04, 2003 7:59:21 PM
			require $mof_preview_pg;
			&PreviewOrder;
			} 
		}
	# custom
	} elsif ($frm{'postmode'} eq "CUSTOM") {
	# Reserved for custom input mode
	} else {
	# mode not found
 	$ErrMsg="<h4>Unable To Determine Input Mode</h4>";
	&ErrorMessage($ErrMsg);
	}
 }

# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003
