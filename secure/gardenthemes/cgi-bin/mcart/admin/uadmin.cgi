#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === ARES ADMIN ================================================== #
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

# ARES v2.5 - Administration Utility
# ARES v2.5 - Affiliate Referral Earnings System 4-10-2001
# Copyright @ All Rights Reserved 2001 MerchantOrderForm.com / MerchantPal.com

# If you're starting with a blank Rep File then manually adjust the starting
# Rep Number after you create the first Rep.  The script will automatically
# assign additional Rep Number incrementing to the setting RepCodeIncrement
# This way you can keep 3 digit Rep numbers
# The Delete uncollected invoices feature has an auto backup of deleted records

# Note: The Rep numbers MUST be Integers only No other characters
# Note: All Admin operations are dependent on Affiliate Numbers and Rep Numbers as numeric values

# CONFIGURATIONS
$setuid = 'lwftmb';

# New Rep Codes are assigned incremented by this
$RepCodeIncrement = 100;

# Starting New Reps at this rate
$RepStartRate = 0;

# Narrow coupon search after n Records
$NarrowCouponSearch = 50;

# When entering "view" for Rep info what is default view
$view_rep_pending = 1;
$view_rep_history = 0;
$view_affiliate_stats = 1;
$view_affiliate_pending = 1;
$view_affiliate_history = 0;

# Currency symbol
# $currency = '£';
# $currency = '€';
$currency = '$';

# Full http URL
$programfile = "$mvar_front_http_mcart/admin/uadmin.cgi";

$cookiename_UserID = 'UserID';

$error_email = $merchantmail;

@ALLOWED_SERVER = ('');

# WHERE IS THE USER MANAGEMENT FORM ?
# Use the full URL
$user_mangement_url = "$mvar_front_http_web/ares/usrmgt.html";

# WHERE ARE THE DATA FILES KEPT ?
# All the data files should be behind Public Web areas
# Define the full absolute path, not an Http url

# Where's the Main Information file ?
$infofile_path = "$mvar_front_path_mcart/data/ares_infofile.dat";

# Where's the Coupon File ?
$couponfile_path = "$mvar_front_path_mcart/data/ares_couponcode.dat";

# Where's the Affiliate Activity log ?
$activityfile_path = "$mvar_front_path_mcart/data/ares_activitylog.dat";

# Where's the Rep Info File ?
$repinfo_path = "$mvar_front_path_mcart/data/ares_repinfo.dat";

# Where's the Mail File Path for Download ?
# needs trailing forward slash
$mail_file_path = "$mvar_front_path_mcart/temp/";

# Where's the URL Redirect File ?
# This feature is operational in ares.cgi
# Which checks for specific redirect request at cookie loggins as per Affiliate Number
# The admin feature to Add/Update an Affiliates redirect URL need building
$redirect_path = "$mvar_front_path_mcart/data/ares_redirecturl.dat";

# Lockfiles is a MUST BE TURNED ON
$lockfiles = 1 unless ($^O =~ m/mswin32/i);

# WHERE IS THE TEMPLATE FILE KEPT ?
# This is also absolute path, not Http url
# or put it in your cgi-bin
$template = "$mvar_front_path_mcart/admin/temp_ares.html";

# Insert output at this point in template
$insertion_marker = '<!--INSERT_TEMPLATE_OUTPUT-->';

# Path to images, leave off the trailing /
$image_path = "$mvar_front_http_web/ares";

# Assign font attributed used in html output
$font1 = '<font face="Arial, Verdana,Helvetica,Arial" size="1" color="#000000">';
$font2 = '<font face="Arial, Verdana,Helvetica,Arial" size="2" color="#000000">';
$font3 = '<font face="Arial, Verdana,Helvetica,Arial" size="3" color="#000000">';
$font4 = '<font face="Arial, Verdana,Helvetica,Arial" size="4" color="#000000">';

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

		# REPRESENTATIVE MANAGEMENT #

		} elsif ($frm{'FUNCTION'} eq "ADD_NEW_REP") {
			&ADD_NEW_REP;

		} elsif ($frm{'FUNCTION'} eq "APPEND_REP") {
			@MissingInformation = ();
			&ValidateNewRep;
				if (scalar(@MissingInformation)) {
				&ADD_NEW_REP;
				} else {
				@ALLINFO = ();
				&Find_New_Rep_Code;
				&Append_To_RepFile;
				$MenuMsg = "Added New Representative Successfully - Rep # <strong>$RepCode</strong><br> ";
				$MenuMsg = $MenuMsg . "<strong>$frm{'Ecom_Postal_Name_First'} ";
				$MenuMsg = $MenuMsg . "$frm{'Ecom_Postal_Name_Last'} ";
				$MenuMsg = $MenuMsg . "<a href=\"mailto:$frm{'Ecom_Online_Email'}\">$frm{'Ecom_Online_Email'}</a></strong>";
				%frm = ();
				&MAIN_MENU;
				}

		} elsif ($frm{'FUNCTION'} eq "EDIT_REP_SEARCH") {
			if ($frm{'Ecom_Search_String'}) {
				@ALLINFO = ();
				@SEARCH_RESULTS = ();
				&Search_Rep_Info_File($frm{'Ecom_Search_String'});
				if (scalar(@SEARCH_RESULTS)) {
				&EDIT_REP_SEARCH;
				} else {
				$Caution1 = "$font2 <strong>Search string not found: <font color=red> ";
				$Caution1 = $Caution1 . "$frm{'Ecom_Search_String'}</font></font></strong>";
				$Caution2 = "$font2 Search pattern: all records, all fields, ignore case</font>";
				&MAIN_MENU;
				}

			} else {
			$Caution1 = "$font2 <strong>Please enter a string to search for ..</strong></font>";
			$Caution2 = "$font2 The entire records will be searched</font>";
			&MAIN_MENU;
			}

		} elsif ($frm{'FUNCTION'} eq "EDIT_REP") {
			&Get_Rep_Record($frm{'Ecom_Rep_Number'});
			&EDIT_REP;

		} elsif ($frm{'FUNCTION'} eq "EDIT_REP_UPDATE") {
			@MissingInformation = ();
			&ValidateNewRep;
				if (scalar(@MissingInformation)) {
				&EDIT_REP;
				} else {
				@ALLINFO = ();
				&Update_Rep_Info_File;
				$MenuMsg = "Updated Representative Successfully - Rep # <strong>$frm{'Ecom_Rep_Number'}</strong><br> ";
				$MenuMsg = $MenuMsg . "<strong>$frm{'Ecom_Postal_Name_First'} ";
				$MenuMsg = $MenuMsg . "$frm{'Ecom_Postal_Name_Last'} ";
				$MenuMsg = $MenuMsg . "<a href=\"mailto:$frm{'Ecom_Online_Email'}\">$frm{'Ecom_Online_Email'}</a></strong>";
				%frm = ();
				&MAIN_MENU;	
				}

		} elsif ($frm{'FUNCTION'} eq "VIEW_REP") {
			%currentAFFILIATES = ();
			%loggedAFFILIATES = ();
			%AEARNINGS = ();
			%APAYMENTS = ();
			%REARNINGS = ();
			%RPAYMENTS = ();
			%AINVOICES = ();
			@ALLINFO = ();
			@TRSUNPAID = ();
			@TRSPAID = ();
			@sortINVC = ();
			($previous_count, $previous_amt, $current_count, $current_amt) = (0,0,0,0);
			$RepRecord = &Get_Rep_Record($frm{'Ecom_Rep_Number'});
			&ListRepActivity($frm{'Ecom_Rep_Number'});
			&VIEW_REP;

		} elsif ($frm{'FUNCTION'} eq "PAY_REP") {
			%currentAFFILIATES = ();
			%loggedAFFILIATES = ();
			%AEARNINGS = ();
			%APAYMENTS = ();
			@ALLINFO = ();
			($pending_count, $pending_amt) = (0,0);
			($previous_count, $previous_amt, $current_count, $current_amt) = (0,0,0,0);
			$RepRecord = &Get_Rep_Record($frm{'Ecom_Rep_Number'});
			&PaySelectRepEarnings($frm{'Ecom_Rep_Number'});
			&PAY_REP;

		} elsif ($frm{'FUNCTION'} eq "LIST_REP_EARNINGS") {
			@TRSINFO = ();
			@REPINFO = ();
			@RepFinalSort = ();
			%RepRecordInfo = ();
			%RepPaidAmt = ();
			%RepPaidCount = ();
			%RepNotAmt = ();
			%RepNotCount = ();
			&CompileRepEarnings;
			&LIST_REP_EARNINGS;

		# AFFILIATE MANAGEMENT #

		} elsif ($frm{'FUNCTION'} eq "EDIT_COUPON_SEARCH") {
			if ($frm{'Ecom_Search_String'}) {
				@ALLINFO = ();
				@SEARCH_RESULTS = ();
				&Search_Info_File($frm{'Ecom_Search_String'});
				$num = scalar(@SEARCH_RESULTS);
				if ($num > 0 && $num <= $NarrowCouponSearch) {
				&EDIT_COUPON_SEARCH;
				} elsif ($num > $NarrowCouponSearch) {
				$Caution1 = "$font2 <strong>Found $num records matching <font color=red> ";
				$Caution1 = $Caution1 . "$frm{'Ecom_Search_String'}</font> .. narrow search ..</font></strong>";
				$Caution2 = "$font2 Search pattern: all records, all fields, ignore case</font>";
				&MAIN_MENU;
				} else {
				$Caution1 = "$font2 <strong>Search string not found: <font color=red> ";
				$Caution1 = $Caution1 . "$frm{'Ecom_Search_String'}</font></font></strong>";
				$Caution2 = "$font2 Search pattern: all records, all fields, ignore case</font>";
				&MAIN_MENU;
				}
			} else {
			$Caution1 = "$font2 <strong>Please enter a string to search for ..</strong></font>";
			$Caution2 = "$font2 The entire records will be searched</font>";
			&MAIN_MENU;
			}

		} elsif ($frm{'FUNCTION'} eq "EDIT_COUPON") {
			&Get_Coupon_Records($frm{'Ecom_Coupon_Number'});
			&EDIT_COUPON;

		} elsif ($frm{'FUNCTION'} eq "EDIT_COUPON_UPDATE") {
			@MissingInformation = ();
			&ValidateCouponInfo;
				if (scalar(@MissingInformation)) {
				&EDIT_COUPON;
				} else {
				&Update_Coupon_Info($frm{'Ecom_Coupon_Number'});
				&Update_Coupon_File($frm{'Ecom_Coupon_Number'});
				$MenuMsg = "Updated Affiliate Successfully - Affiliate # <strong>$frm{'Ecom_Coupon_Number'}</strong><br> ";
				$MenuMsg = $MenuMsg . "<strong>$frm{'Ecom_Postal_Name_First'} ";
				$MenuMsg = $MenuMsg . "$frm{'Ecom_Postal_Name_Last'} ";
				$MenuMsg = $MenuMsg . "<a href=\"mailto:$frm{'Ecom_Online_Email'}\">$frm{'Ecom_Online_Email'}</a></strong>";
				%frm = ();
				&MAIN_MENU;	
				}

		} elsif ($frm{'FUNCTION'} eq "VIEW_COUPON") {
			@ALLINFO = ();
			@TRSUNPAID = ();
			@TRSPAID = ();
			@sortINVC = ();
			($RepRec, $CoupRec, $InfoRec);
			($previous_count, $previous_amt, $current_count, $current_amt) = (0,0,0,0);
			&ListAffiliateActivity($frm{'Ecom_Coupon_Number'});
			&VIEW_COUPON;

		} elsif ($frm{'FUNCTION'} eq "PAY_SELECT") {
			@ALLINFO = ();
			@TRSUMMARY = ();
			($RepRec, $CoupRec, $InfoRec);
			($pending_count, $pending_amt) = (0,0);
			($previous_count, $previous_amt, $current_count, $current_amt) = (0,0,0,0);
			&PaySelectAffiliateEarnings($frm{'Ecom_Coupon_Number'});
			&PAY_SELECT;

		} elsif ($frm{'FUNCTION'} eq "LIST_AFFILIATE_EARNINGS") {
			@TRSINFO = ();
			@AFFINFO = ();
			@CouponsFinalSort = ();
			%CouponsInfo = ();
			%CouponsPaidAmt = ();
			%CouponsPaidCount = ();
			%CouponsNotAmt = ();
			%CouponsNotCount = ();
			&CompileAffiliateEarnings;
			&LIST_AFFILIATE_EARNINGS;

		} elsif ($frm{'FUNCTION'} eq "PAY_AFFILIATE") {
			@ALLINFO = ();
			@TRSUMMARY = ();
			($RepRec, $CoupRec, $InfoRec);
			($previous_count, $previous_amt, $current_count, $current_amt) = (0,0,0,0);
			&PayAffiliateEarnings($frm{'Ecom_Coupon_Number'});
			&PAY_AFFILIATE;

		# TRANSACTION MANAGEMENT #

		} elsif ($frm{'FUNCTION'} eq "VOID_INVOICE_SEARCH") {
			if ($frm{'Ecom_Search_String'}) {
				$UseDelete = 0;
				$TotalTransactions = 0;
				@ALLINFO = ();
				@SEARCH_RESULTS = ();
				&Search_Invoice_Number($frm{'Ecom_Search_String'});
				if (scalar(@SEARCH_RESULTS)) {
					$UseDelete++;
					&MAIN_MENU;
				} else {
				$Caution1 = "$font2 <strong>Invoice Number not found: <font color=red> ";
				$Caution1 = $Caution1 . "$frm{'Ecom_Search_String'}</font></font></strong>";
				$Caution2 = "$font2 Search pattern: All Transactions, Invoice Numbers</font>";
				&MAIN_MENU;
				}
			} else {
			$Caution1 = "$font2 <strong>Please enter an Invoice Number to search for.</strong></font>";
			$Caution2 = "$font2 Only Invoice Numbers will be searched</font>";
			&MAIN_MENU;
			}

		} elsif ($frm{'FUNCTION'} eq "VOID_INVOICE_DELETE") {
			@ALLINFO = ();
			&Delete_Invoice_Number($frm{'InvoiceNumber'});
			$MenuMsg = "Successfully Deleted Invoice # <strong>$frm{'InvoiceNumber'}</strong><br> ";
			%frm = ();
			&MAIN_MENU;	

		# MANAGE REDIRECT URL #

		} elsif ($frm{'FUNCTION'} eq "URL_COUPON") {
			&Get_Coupon_Records($frm{'Ecom_Coupon_Number'});
			&URL_COUPON;

		} elsif ($frm{'FUNCTION'} eq "EDIT_URL_UPDATE") {
			$URLfound = 0;
			if ($frm{'Ecom_Redirect_URL'} =~ /^http\:\/\//i) {
			&Update_Redirect_File($frm{'Ecom_Coupon_Number'});
			$MenuMsg = "Updated " if ($URLfound);
			$MenuMsg = "Added " unless ($URLfound);
			$MenuMsg = $MenuMsg . "Redirect URL Successfully for # <strong>$frm{'Ecom_Coupon_Number'}</strong><br> ";
			$MenuMsg = $MenuMsg . "<strong>$frm{'Ecom_Postal_Name_First'} ";
			$MenuMsg = $MenuMsg . "$frm{'Ecom_Postal_Name_Last'} ";
			$MenuMsg = $MenuMsg . "<a href=\"mailto:$frm{'Ecom_Online_Email'}\">$frm{'Ecom_Online_Email'}</a></strong><br>";
			$MenuMsg = $MenuMsg . "<a href=\"$frm{'Ecom_Redirect_URL'}\">$frm{'Ecom_Redirect_URL'}</a>";
			} elsif ($frm{'Ecom_Redirect_URL'} eq "") {
			&Update_Redirect_File($frm{'Ecom_Coupon_Number'});
				if ($URLfound) {
			$MenuMsg = "Deleted Redirect URL Successfully for # <strong>$frm{'Ecom_Coupon_Number'}</strong><br> ";
			$MenuMsg = $MenuMsg . "<strong>$frm{'Ecom_Postal_Name_First'} ";
			$MenuMsg = $MenuMsg . "$frm{'Ecom_Postal_Name_Last'} ";
			$MenuMsg = $MenuMsg . "<a href=\"mailto:$frm{'Ecom_Online_Email'}\">$frm{'Ecom_Online_Email'}</a></strong><br>";
			$MenuMsg = $MenuMsg . "<a href=\"$frm{'Ecom_Redirect_URL'}\">$frm{'Ecom_Redirect_URL'}</a>";
			$MenuMsg = $MenuMsg . "Affiliate does not have a current Redirect URL, defaults apply";
				} else {
			$MenuMsg = "You did not Add a Redirect URL for # <strong>$frm{'Ecom_Coupon_Number'}</strong><br> ";
			$MenuMsg = $MenuMsg . "<strong>$frm{'Ecom_Postal_Name_First'} ";
			$MenuMsg = $MenuMsg . "$frm{'Ecom_Postal_Name_Last'} ";
			$MenuMsg = $MenuMsg . "<a href=\"mailto:$frm{'Ecom_Online_Email'}\">$frm{'Ecom_Online_Email'}</a></strong><br>";
			$MenuMsg = $MenuMsg . "Affiliate does not have a current Redirect URL, defaults apply ";
				}
			} else {
			$MenuMsg = "No Redirect changes were completed for # <strong>$frm{'Ecom_Coupon_Number'}</strong><br> ";
			$MenuMsg = $MenuMsg . "<strong>$frm{'Ecom_Postal_Name_First'} ";
			$MenuMsg = $MenuMsg . "$frm{'Ecom_Postal_Name_Last'} ";
			$MenuMsg = $MenuMsg . "<a href=\"mailto:$frm{'Ecom_Online_Email'}\">$frm{'Ecom_Online_Email'}</a></strong><br>";
			$MenuMsg = $MenuMsg . "<b>URL Not Valid:</b> $frm{'Ecom_Redirect_URL'}";
			}
			%frm = ();
			&MAIN_MENU;

		# MAIL LIST #

		} elsif ($frm{'FUNCTION'} eq "MAIL_LIST") {
			@ALLINFO = ();
			$FileName = $frm{'Mail_File_Name'};
			$FileName =~ s/[^A-Za-z0-9._-]//g;
			$path = $mail_file_path . $FileName;
			my ($mailtest) = 0;
			$mailtest++ if ($frm{'Mail_Customers'});
			$mailtest++ if ($frm{'Mail_Reps'});
			$mailtest++ if ($frm{'Mail_Affiliates'});
			if (!$frm{'Mail_File_Name'}) {
			$Caution1 = "$font2 <strong>Enter a valid Filename: </strong></font>";
			$Caution2 = "$font2 To Make a Mail List you must enter a file name to store your results in.</font>";
			&MAIN_MENU;
			} elsif ( -e $path ) {
			$Caution1 = "$font2 <strong>Please Enter a different filename: ";
			$Caution1 = $Caution1 . "<font color=red>$frm{'Mail_File_Name'}</font> already exists</strong></font>";
			$Caution2 = "$font2 Enter a different file name or clean up the directory with your mail files.</font>";
			&MAIN_MENU;
			} elsif ($mailtest == 0) {
			$Caution1 = "$font2 <strong>No base for your email addresses has been selcted</font>";
			$Caution2 = "$font2 Select at least one group: Customers, Representatives, or Affiliates.</font>";
			&MAIN_MENU;
			} else {
			&GetMailList();
				if (scalar(@ALLINFO)) {
				&SaveMailFile($path);
				&MAIL_LIST;
				} else {
				$Caution1 = "$font2 <strong>Could not find any records for your search criteria</font>";
				$Caution2 = "$font2 Double check your criteria and try again.</font>";
				&MAIN_MENU;
				}
			}

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

# FUNCTIONS

# STARTING LOGIN
sub LOG_IN {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "$font2";
	print "<strong>LOG IN REQUIRED </strong> </font>";
	print "<strong> - <font color=red>LOG IN NOT VALID </font></strong></font><p>" if ($frm{'Ecom_Password'});
	print '<BLOCKQUOTE>';
	print "<FORM method=POST action=\"$programfile\">";
	print '<table border=0 cellpadding=2 cellspacing=1><tr><td align=right bgcolor=#CEE1EC>';
	print "$font2";
	print 'Password</font></td><td bgcolor=#84B5CE height="25">';
	print "$font2";
	print '<input name="Ecom_Password" size=12 type=password></font> </td>
	<td align=right bgcolor=#84B5CE nowrap height="18"><p align="center">
	';
	print "<INPUT type=submit value=\"Log In\"></td>";
	print '</tr></table></FORM></BLOCKQUOTE>';
	print "@footer \n\n";
	}

# MAIN MENU
sub MAIN_MENU {
	my ($i1, $i2, $i3);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "$font2";
	print "<strong>LOGGED IN: ADMIN MENU </strong></font> ";
	print "<INPUT type=submit value=\"Log Out\">";
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

	# REP MENU
	print "<tr><td align=center colspan=3 bgcolor=#84B5CE>$font2 <strong>";
	print "Representative Management</strong></font></td></tr> \n";

	# Add New Representative
	print "<tr>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"ADD_NEW_REP\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2";
	print "Add Representative </font>";
	print "</td>";
	print "<td bgcolor=#84B5CE valign=center align=center>";
	print "$font2";
	#print "<INPUT type=submit value=\"Add Rep\">";
	print "<INPUT type=image src=\"$image_path/ares_add.gif\" border=0 width=\"51\" height=\"18\" alt=\"Add New Representative\">";
	print "</font></td>";
	print "<td bgcolor=#EEF5F9>$font2 Add a new Rep to the database </font></td> ";
	print "</FORM></tr>";

	# Editing Representative - Search 
	print "<tr>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP_SEARCH\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2 <strong>Str </strong><input name=\"Ecom_Search_String\" size=10> </font>";
	print "</td>";
	print "<td bgcolor=#84B5CE valign=center align=center>";
	print "$font2";
	# print "<INPUT type=submit value=\"Edit Rep\">";
	print "<INPUT type=image src=\"$image_path/ares_find.gif\" border=0 width=\"51\" height=\"18\" alt=\"Find Any Representative Record\">";
	print "</font></td>";
	print "</td>";
	print "<td bgcolor=#EEF5F9>$font2 Find Representatives to edit: Earning rate, <br>";
	print "Personal Information, View-Pay Account Hx. </font></td> ";
	print "</FORM></tr>";

	# Listing Representative Earnings
	print "<tr>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LIST_REP_EARNINGS\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2";
	print "List Rep Earnings </font>";
	print "</td>";
	print "<td bgcolor=#84B5CE valign=center align=center>";
	print "$font2";
	# print "<INPUT type=submit value=\"List Pymt\">";
	print "<INPUT type=image src=\"$image_path/ares_list.gif\" border=0 width=\"51\" height=\"18\" alt=\"Show List of Representative Earnings\">";
	print "</font>";
	print "</td>";
	print "<td bgcolor=#EEF5F9>$font2 Show unpaid Representative earnings that are <br>currently in the database </font></td> ";
	print "</FORM></tr>";

	# AFFILIATE MENU
	print "<tr><td align=center colspan=3 bgcolor=#99CCCC>$font2 <strong>";
	print "Affiliate Management</strong></td></tr> \n";

	# Editing Coupon - Search 
	print "<tr>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_COUPON_SEARCH\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2";
	print "<strong>Str </strong><input name=\"Ecom_Search_String\" size=10> </font>";
	print "</td>";
	print "<td bgcolor=#99CCCC valign=center align=center>";
	print "$font2";
	# print "<INPUT type=submit value=\"Coupons\">";
	print "<INPUT type=image src=\"$image_path/ares_find.gif\" border=0 width=\"51\" height=\"18\" alt=\"Find Any Affiliate Record\">";
	print "</font></td>";
	print "</td>";
	print "<td bgcolor=#EAF4F4>$font2 Find Affiliates to Edit: ";
	print "Earning Rate, Customer <br>Discount, Rep Assignment, Personal Information";
	print "</font></td> ";
	print "</FORM></tr>";

	# Listing Affiliate Earnings
	print "<tr>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LIST_AFFILIATE_EARNINGS\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2";
	print "List Affiliate Earnings </font>";
	print "</td>";
	print "<td bgcolor=#99CCCC valign=center align=center>";
	print "$font2 ";
	# print "<INPUT type=submit value=\"List Pymt\">";
	print "<INPUT type=image src=\"$image_path/ares_list.gif\" border=0 width=\"51\" height=\"18\" alt=\"Show List of Affiliate Earnings\">";
	print "</font>";
	print "</td>";
	print "<td bgcolor=#EAF4F4>$font2 Show unpaid Affiliate earnings in database <br> ";
	print "This updates the live database at payment </font></td> ";
	print "</FORM></tr>";

	# TRANSACTION MANAGEMENT	
	print "<tr><td align=center colspan=3 bgcolor=#84B5CE>$font2 <strong>";
	print "Transaction Management</strong></td></tr> \n";

	# Void Invoice Transaction - Search 
	print "<tr>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VOID_INVOICE_SEARCH\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2 <strong># </strong><input name=\"Ecom_Search_String\" size=10> </font>";
	print "</td>";
	print "<td bgcolor=#84B5CE valign=center align=center>";
	print "$font2 ";
	# print "<INPUT type=submit value=\"Invoice #\"> ";
	print "<INPUT type=image src=\"$image_path/ares_find.gif\" border=0 width=\"51\" height=\"18\" alt=\"Search For Exact Invoice Number\">";
	print "</font></td>";
	print "</td>";
	print "<td bgcolor=#EEF5F9>$font2 Void Affiliate earnings on uncollected invoices  <br>";
	print "Note: do this <strong>before</strong> you list payments </font></td> ";
	print "</FORM></tr>";

	# Return DELETE function - Invoice
	if ($UseDelete) {
	print "<tr> \n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VOID_INVOICE_DELETE\">";
	print "<INPUT type=\"hidden\" name=\"InvoiceNumber\" value=\"$frm{'Ecom_Search_String'}\">";
	print "<td bgcolor=#FFCE00 valign=center align=center colspan=2>";
	print "$font2<INPUT type=submit value=\"Delete Invoice $frm{'Ecom_Search_String'}\"></font>";
	print "</td>";
		$_ = scalar(@SEARCH_RESULTS);
	print "<td bgcolor=#EAF4F4>$font2 This deletes Invoice <strong>$frm{'Ecom_Search_String'}</strong> \n";
	print "$font1 ( $_ of $TotalTransactions ) </font><br> $font2 ";
	foreach (@SEARCH_RESULTS) {
		($i1, $i2, $i3) = split (/\|/, $_);
		$i2 = sprintf "%.2f", $i2;
		$i2 = CommifyMoney ($i2);
		print "on $i1 for $i2 affiliate $i3<br>";
		}
	print "</font></td></FORM></tr>";
	}

	# MAKE MAIL LIST
	print "<tr><td align=center colspan=3 bgcolor=#99CCCC>$font2 <strong>";
	print "Make Mailing List</strong></td></tr> \n";
	print "<tr>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIL_LIST\">";
	print "<td bgcolor=#EFEFEF align=right>";
	print "$font2 <input name=\"Mail_File_Name\" size=18> </font>";
	print "</td>";
	print "<td bgcolor=#99CCCC valign=center align=center>";
	print "$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_list.gif\" border=0 width=\"51\" height=\"18\" alt=\"Create Mailing List\">";
	print "</font>";
	print "</td>";
	print "<td bgcolor=#EAF4F4>$font2 ";
	print "<INPUT type=\"CHECKBOX\" NAME=\"Mail_Customers\" VALUE=\"Customers Included\"> Include Customers <br>\n";
	print "<INPUT type=\"CHECKBOX\" NAME=\"Mail_Reps\" VALUE=\"Representatives Included\"> Include Representatives <br>\n";
	print "<INPUT type=\"CHECKBOX\" NAME=\"Mail_Affiliates\" VALUE=\"Affiliates Included\"> Include Affiliates <br>\n";
	print "<INPUT type=\"CHECKBOX\" NAME=\"Mail_Invalid\" VALUE=\"Removed Invalid Addresses\"> Don't Include Invalid Addresses <br>\n";
	print "<INPUT type=\"CHECKBOX\" NAME=\"Mail_Dups\" VALUE=\"Removed Duplicate Addresses\"> Don't Include Duplicate Addresses \n";
	print "</font></td> ";
	print "</FORM></tr>";

	# other menu items 
	print "</table>";
	print "@footer \n\n";
	}

# MAKE MAIL LIST
sub MAIL_LIST {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>MAKE MAIL LIST &nbsp;&nbsp </strong></td> \n";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>\n";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table>\n";
	print "$font2 The eMail File list was successfully created </font><p> ";
	print "<ul> $font2 ";
	print "<li>Mail File: <b>$frm{'Mail_File_Name'}</b>\n";
	print "<li>Location: <b>$mail_file_path" . "$frm{'Mail_File_Name'}</b>";
	print "<li>Total email addresses: " . scalar(@ALLINFO);
	print "<li>Included Customers " if ($frm{'Mail_Customers'});
	print "<li>Included Representatives " if ($frm{'Mail_Reps'});
	print "<li>Included Affiliates " if ($frm{'Mail_Affiliates'});
	print "<li>Deleted any Invalid Addresses" if ($frm{'Mail_Invalid'});
	print "<li>Deleted any Duplicate Addresses" if ($frm{'Mail_Dups'});
	print "</ul><p></font>";
	print "You may now download your file from the location listed above.";
	}

# ADD NEW REP
sub ADD_NEW_REP {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>ADDING NEW REPRESENTATIVE &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table><p>";
	print "$font2";
	print "<blockquote>";
		if (scalar(@MissingInformation)) {
		print "<ul>";
		foreach (@MissingInformation) {print "$_ \n"}
		print "</ul><p>";
		}
	print "<table border=0 cellpadding=2 cellspacing=0> \n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"APPEND_REP\">";
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 Starting Rate:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	if ($frm{'Ecom_Rep_Rate'}) {
	print "<input name=\"Ecom_Rep_Rate\" value=\"$frm{'Ecom_Rep_Rate'}\" size=10></font> ";
	} else {
	print "<input name=\"Ecom_Rep_Rate\" value=\"$RepStartRate\" size=10></font> ";
	}
	print "$font2 0.05 format for 5\% </font></td></tr> \n"; 
	print "<tr><td align=left bgcolor=#E5E5E5 colspan=2>$font2 <br></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 First Name:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Name_First\" value=\"$frm{'Ecom_Postal_Name_First'}\" size=30></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 Last Name:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_Name_Last\" value=\"$frm{'Ecom_Postal_Name_Last'}\" size=30></font> </td></tr> \n";
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Street Address 1:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line1\" value=\"$frm{'Ecom_Postal_Street_Line1'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Street Address 2:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line2\" value=\"$frm{'Ecom_Postal_Street_Line2'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 City</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_City\" value=\"$frm{'Ecom_Postal_City'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 State - Province</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_StateProv\" value=\"$frm{'Ecom_Postal_StateProv'}\"></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Postal Code:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_PostalCode\" value=\"$frm{'Ecom_Postal_PostalCode'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Country</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_CountryCode\" value=\"$frm{'Ecom_Postal_CountryCode'}\"></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Date of Birth</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_DOB\" value=\"$frm{'Ecom_DOB'}\"></font></td></tr> \n";
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Phone Number</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Telecom_Phone_Number\" value=\"$frm{'Ecom_Telecom_Phone_Number'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Email Address</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Online_Email\" value=\"$frm{'Ecom_Online_Email'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right colspan=2> \n"; 
	print "<INPUT type=Submit value=\"Add New Rep\">";
	print "</td></tr> \n"; 
	print "</table></FORM><p></blockquote>";
	print "@footer \n\n";
	}

# EDIT REP SEARCH
sub EDIT_REP_SEARCH {
	my (@tmp) = ();
	my (@SortTemp) = ();
	my (@SortResults) = ();
	my ($str) = $frm{'Ecom_Search_String'};
	my ($count) = scalar(@SEARCH_RESULTS);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	my ($fixmail, $fixrecno);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>REPRESENTATIVE SEARCH RESULTS &nbsp;&nbsp </strong></td> \n";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>\n";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=0 width=100\%><tr> ";
	print "<td bgcolor=#CEE1EC>$font2 <strong>Matched $count for $str </strong></font></td> ";
	print "<td align=right bgcolor=#CEE1EC>$font2 Total Reps: $TotalReps </font></td> ";
	print "</tr></table> \n ";
		# Sort by Last Name
		foreach (@SEARCH_RESULTS) {
		($i3, $i4, $i5, $i2, $i1, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		$_ = join ('|', ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14));
		push (@SortTemp, $_);
		}
		@SearchResults = sort (@SortTemp);
	print "<table border=0 cellpadding=1 bgcolor=#FFFFFF cellspacing=2 width=100\%>";
	print "<tr><td align=right colspan=4>$font1 Rep Records sorted by Last Name</font></td><td>$font1 <br></font></td></tr> ";
	print "<tr bgcolor=#EBEBEB> ";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Name</strong></font></font></td>";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Rep Num</strong></font></font></td>";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Started</strong></font></font></td>";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Rate</strong></font></font></td>";
	print "<td align=center nowrap bgcolor=#FFFFFF>$font2 <br></font></td>";
	print "</tr>\n";
	foreach (@SearchResults) {
		@tmp = split (/\|/, $_); 
		foreach (@tmp) {s/($str)/<strong>$1<\/strong>/gi}
		$fixrecno = $tmp[3];
		$fixrecno =~ s/(<strong>)//gi;
		$fixrecno =~ s/(<\/strong>)//gi;
		$fixmail = $tmp[13];
		$fixmail =~ s/(<strong>)//gi;
		$fixmail =~ s/(<\/strong>)//gi;
	print "<tr><td colspan=5><hr></td></tr> ";
	# Print first row
	print "<tr bgcolor=#E8F1F7> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$fixrecno\">";
	print "<td nowrap>$font2 $tmp[1] $tmp[0]</font></td>";
	print "<td nowrap>$font2 $tmp[3]</font></td>";
	print "<td nowrap>$font2 $tmp[2]</font></td>";
	print "<td nowrap>$font2 $tmp[4]</font></td>\n\n";
	print "<td align=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_edit.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Rep $fixrecno\">";
	print "</font></td>";
	print "</FORM></tr>\n\n";
	print "<tr bgcolor=#EBEBEB> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$fixrecno\">";
	print "<INPUT type=\"hidden\" name=\"View_Rep_Pending\" value=\"$view_rep_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Rep_History\" value=\"$view_rep_history\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Stats\" value=\"$view_affiliate_stats\">";
	print "<td nowrap colspan=4>$font2 $tmp[5] $tmp[6] $tmp[7] $tmp[8] $tmp[9] $tmp[10] </font></td>";
	print "<td align=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_view.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History $fixrecno\">";
	print "</font></td>";
	print "</FORM></tr>\n";
	print "<tr bgcolor=#F8F8F8> ";
	print "<td nowrap colspan=4>$font1 (Phone) </font>$font2 $tmp[11] </font> $font1 (DOB) </font>$font2 $tmp[12] ";
	print "<a href=\"mailto:$fixmail\">$tmp[13]</a>" if ($tmp[13]);
	print "</font></td>";
	print "<td bgcolor=#FFFFFF>$font2 <br></font></td></tr>\n";
	}	
	print "</table> <p> ";
	print "@footer \n\n";
	}

# EDIT REP
sub EDIT_REP {
	unless ($frm{'FUNCTION'} eq "EDIT_REP_UPDATE") {
		($frm{'Ecom_Rep_Date'},
		$frm{'Ecom_Rep_Number'},
		$frm{'Ecom_Rep_Rate'},
		$frm{'Ecom_Postal_Name_First'},
		$frm{'Ecom_Postal_Name_Last'},
		$frm{'Ecom_Postal_Street_Line1'},
		$frm{'Ecom_Postal_Street_Line2'},
		$frm{'Ecom_Postal_City'},
		$frm{'Ecom_Postal_StateProv'},
		$frm{'Ecom_Postal_PostalCode'},
		$frm{'Ecom_Postal_CountryCode'},
		$frm{'Ecom_Telecom_Phone_Number'},
		$frm{'Ecom_DOB'},
		$frm{'Ecom_Online_Email'}) = split (/\|/, $RepRecord);
		}
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>EDITING REPRESENTATIVE &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table><p>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$frm{'Ecom_Rep_Number'}\">";
	print "<INPUT type=\"hidden\" name=\"View_Rep_Pending\" value=\"$view_rep_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Rep_History\" value=\"$view_rep_history\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Stats\" value=\"$view_affiliate_stats\">";
	print "$font2 Rep Number: </font> $font2 <strong>$frm{'Ecom_Rep_Number'} </strong></font>";
	print "&nbsp; <INPUT type=image src=\"$image_path/ares_view_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History $frm{'Ecom_Rep_Number'}\">";	
	print "<br>$font2 Member Since: </font> $font2 $frm{'Ecom_Rep_Date'} <br>";
	print "Note: Changes to Rep Rates are not retroactive <br>";
	print "Note: Changes to Rep Rates begin at next sale </font>";
	print "<blockquote></FORM>";
		if (scalar(@MissingInformation)) {
		print "<ul>";
		foreach (@MissingInformation) {print "$_ \n"}
		print "</ul><p>";
		}
	print "<table border=0 cellpadding=2 cellspacing=0> \n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP_UPDATE\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$frm{'Ecom_Rep_Number'}\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Date\" value=\"$frm{'Ecom_Rep_Date'}\">";
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 Current Rate:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Rep_Rate\" value=\"$frm{'Ecom_Rep_Rate'}\" size=10></font> ";
	print "$font2 0.05 format for 5\% </font></td></tr> \n"; 
	print "<tr><td align=left bgcolor=#E5E5E5 colspan=2>$font2 <br></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 First Name:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Name_First\" value=\"$frm{'Ecom_Postal_Name_First'}\" size=30></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 Last Name:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_Name_Last\" value=\"$frm{'Ecom_Postal_Name_Last'}\" size=30></font> </td></tr> \n";
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Street Address 1:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line1\" value=\"$frm{'Ecom_Postal_Street_Line1'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Street Address 2:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line2\" value=\"$frm{'Ecom_Postal_Street_Line2'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap>$font2 City</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_City\" value=\"$frm{'Ecom_Postal_City'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 State - Province</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_StateProv\" value=\"$frm{'Ecom_Postal_StateProv'}\"></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Postal Code:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_PostalCode\" value=\"$frm{'Ecom_Postal_PostalCode'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Country</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_CountryCode\" value=\"$frm{'Ecom_Postal_CountryCode'}\"></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Date of Birth</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_DOB\" value=\"$frm{'Ecom_DOB'}\"></font></td></tr> \n";
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Phone Number</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Telecom_Phone_Number\" value=\"$frm{'Ecom_Telecom_Phone_Number'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CEE1EC nowrap> $font2 Email Address</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Online_Email\" value=\"$frm{'Ecom_Online_Email'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right colspan=2> \n"; 
	print "<br><INPUT type=Submit value=\"Update Rep\">";
	print "</td></tr> \n"; 
	print "</table></FORM><p></blockquote>";
	print "@footer \n\n";
	}

# VIEW REP INFO
sub VIEW_REP {
	my (@tempSORT) = ();
	my (@sortEARNINGS) = ();
	my ($pndg, $erngs, $pymts);
	my ($Rpndg, $Rerngs, $Rpymts);
	my ($Tpndg, $Terngs, $Tpymts, $Tinvc);
	my ($TRpndg, $TRerngs, $TRpymts);
	my ($key, $val);
	my ($aname, $aemail);
	my ($switch, $inv);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $RepRecord);
	my ($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15);
	$total_paid = ($previous_count + $current_count);
	$total_paid_amt = ($previous_amt + $current_amt);
	$previous_count = CommifyNumbers ($previous_count);
	$previous_amt = sprintf "%.2f", $previous_amt;
	$previous_amt = CommifyMoney ($previous_amt);
	$current_count = CommifyNumbers ($current_count);
	$current_amt = sprintf "%.2f", $current_amt;
	$current_amt = CommifyMoney ($current_amt);
	$total_paid = CommifyNumbers ($total_paid);
	$total_paid_amt = sprintf "%.2f", $total_paid_amt;
	$total_paid_amt = CommifyMoney ($total_paid_amt);
	my ($astat_current) = CommifyNumbers(scalar(keys(%currentAFFILIATES)));
	my ($astat_logged) = CommifyNumbers(scalar(keys(%loggedAFFILIATES)));
	my ($astat_earnings) = 0;
	while (($key, $val) = each (%AEARNINGS)) {$astat_earnings += $val}
	my ($astat_payments) = 0;
	while (($key, $val) = each (%APAYMENTS)) {$astat_payments += $val}
	my ($astat_pending) = ($astat_earnings - $astat_payments);
	$astat_earnings = sprintf "%.2f", $astat_earnings;
	$astat_earnings = CommifyMoney ($astat_earnings);
	$astat_payments = sprintf "%.2f", $astat_payments;
	$astat_payments = CommifyMoney ($astat_payments);
	$astat_pending = sprintf "%.2f", $astat_pending;
	$astat_pending = CommifyMoney ($astat_pending);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "<table border=0 cellpadding=2 cellspacing=0>";
	print "<tr>";
	print "<td valign=top>$font2 $Date $ShortTime  </font></td> ";
	print "<td valign=top>$font2 ";
	print "<INPUT type=\"checkbox\" name=\"View_Rep_Pending\" value=\"10\"";
	if ($frm{'View_Rep_Pending'}) {print "checked=\"on\">"} else {print ">"}
	print "$font1 <b>pending</b></font> \n";
	print "<INPUT type=\"checkbox\" name=\"View_Rep_History\" value=\"10\"";
	if ($frm{'View_Rep_History'}) {print "checked=\"on\">"} else {print ">"}
	print "$font1 <b>history</b></font> \n";
	print "<INPUT type=\"checkbox\" name=\"View_Affiliate_Stats\" value=\"10\"";
	if ($frm{'View_Affiliate_Stats'}) {print "checked=\"on\">"} else {print ">"}
	print "$font1 <b>affiliate stats</b></font> \n";
	print "</font></td>\n";
	print "<td valign=center>$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_view_rep.gif\" border=0 width=\"21\" height=\"21\" alt=\"Apply Filter\">";
	print "</font></td></table></FORM>\n\n";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>REPRESENTATIVE ACCOUNT HISTORY &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM><p></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM><p></td>";
	print "</tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%><tr>";
	print "<td valign=top> \n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "$font2 Representative: <font color=navy><b>$r2 </b>&nbsp;&nbsp;</font>";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Rep $r2\">";
	print "<br><strong> $r4 $r5 </strong></font><br>\n";
	print "$font2 $r6 <br></font>" if ($r6);
	print "$font2 $r7 <br></font>" if ($r7);
	print "$font2 $r8, $r9 &nbsp; $r10 &nbsp;&nbsp $r11 <br></font>";
	print "$font2 Phone: $r12 <br></font>" if ($r12);
	print "$font2 DOB: $r13 <br></font>" if ($r13);
	print "$font2 <a href=\"mailto:$r14\">$r14</a><br></font>" if ($r14);
	print "$font2 Member Since: $r1 <br></font>" if ($r1);
	print "$font2 Current Rate: $r3 <br></font></FORM></td>";
	print "<td valign=top nowrap>";
	print "$font2 <b><u>Affiliate Stats</u></b><p> \n";
	print "$font2 Assigned Affiliates = $astat_current <br></font>\n";
	print "$font2 Earning Affiliates = $astat_logged </font><p>\n";
	print "<table border=0 cellpadding=0 cellspacing=0> \n";
	print "<tr><td>$font2 Earnings &nbsp;&nbsp;</font></td><td align=right>$font2 $currency $astat_earnings</font></td></tr>\n";
	print "<tr><td>$font2 Payments &nbsp;&nbsp;</font></td><td align=right>$font2 $currency $astat_payments</font></td></tr>\n";
	print "<tr><td>$font2 Pending &nbsp;&nbsp;</font></td><td align=right>$font2 $currency $astat_pending</font></td></tr>\n";
	print "</table>\n\n";
	print "</td></tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Account Summary: REPRESENTATIVE $r2</strong> </font></td></tr> ";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 All previous payments/earnings for <strong>$previous_count </strong> invoices = ";
	print "$currency $previous_amt </font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Pending payments/earnings for <strong>$current_count </strong> invoices = ";
	print "<strong>$currency $current_amt </strong></font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Making your overall total earnings to date: $currency $total_paid_amt </font></td></tr> \n";
	print "</table><P>";
	# PENDING
	if ($frm{'View_Rep_Pending'}) {
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"PAY_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Payment Pending Detail - ";
	print "Has Not Yet Been Paid</strong></font>";
	print "</td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font1 <strong>#</strong></font></td> ";
	print "<td align=center>$font1 <strong>date</strong></font></td> ";
	print "<td align=center>$font1 <strong>invoice</strong></font></td> ";
	print "<td align=center>$font1 <strong>amount</strong></font></td> ";
	print "<td align=center>$font1 <strong>affiliate</strong></font></td> ";
	print "<td align=center>$font1 <strong>rate</strong></font></td> ";
	print "<td align=center>$font1 <strong>pending</strong></font></td> ";
	print "<td align=center>$font1 <strong>pay ?</strong></font></td> ";
	print "</tr>\n\n";
	($switch,$count) = (1,1);
	foreach $inv (@sortINVC) {
	foreach (@TRSUNPAID) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_);
		if ($t3 == $inv) {
		$t4 = sprintf "%.2f", $t4;
		$t4 = CommifyMoney ($t4);
		$t13 = sprintf "%.2f", $t13;
		$t13 = CommifyMoney ($t13);
		print "<tr bgcolor=#E7F0F8>" if ($switch);
		print "<tr bgcolor=#EEEEEE>" unless ($switch);
		print "<td nowrap>$font1 $count</font></td> ";
		print "<td nowrap>$font1 $t1</font></td> ";
		print "<td nowrap>$font1 $t3</font></td> ";
		print "<td align=right nowrap>$font2 $t4</font></td> ";
		if ($loggedAFFILIATES{$t5}) {
		($aname, $aemail) = split (/\|/, $loggedAFFILIATES{$t5});
		print "<td nowrap>$font1 <a href=\"mailto:$aemail\">$aname</a></font></td> ";
		} else {
		print "<td nowrap>$font1 not in list </font></td> ";
		}
		print "<td align=center nowrap>$font2 $t12</font></td> ";
		print "<td align=right nowrap>$font2 $t13</font></td> ";
		print "<td align=center>$font1 ";
		print "<INPUT type=\"CHECKBOX\" NAME=\"InvcNumber\" VALUE=\"$t3\" CHECKED=\"ON\"> pay </font></td>\n";
		print "</tr> \n";
		if ($switch) {$switch = 0} else {$switch = 1}
		$count++;
		}
	}
	}
	print "<tr><td colspan=8 align=right>\n\n";
	if ($current_count) {
	print "<INPUT type=image src=\"$image_path/ares_pay.gif\" border=0 width=\"47\" height=\"16\" alt=\"Pay Selected Invoices\">";
	} else {
	print "$font2 No pending earnings ";
	}
	print "</td></tr></table></FORM><P>";
	} # end View_Rep_Pending
	# PAID HISTORY
	if ($frm{'View_Rep_History'}) {
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Previously Paid Detail - ";
	print "Has Already Been Paid</strong></font></td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font1 <strong>#</strong></font></td> ";
	print "<td align=center>$font1 <strong>date</strong></font></td> ";
	print "<td align=center>$font1 <strong>invoice</strong></font></td> ";
	print "<td align=center>$font1 <strong>amount</strong></font></td> ";
	print "<td align=center>$font1 <strong>affiliate</strong></font></td> ";
	print "<td align=center>$font1 <strong>rate</strong></font></td> ";
	print "<td align=center>$font1 <strong>amt paid</strong></font></td> ";
	print "<td align=center>$font1 <strong>date paid</strong></font></td> ";
	print "</tr>\n\n";
	($switch,$count) = (1,1);
	foreach $inv (@sortINVC) {
	foreach (@TRSPAID) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_) ;
		if ($t3 == $inv) {
		$t4 = sprintf "%.2f", $t4;
		$t4 = CommifyMoney ($t4);
		$t13 = sprintf "%.2f", $t13;
		$t13 = CommifyMoney ($t13);
		print "<tr bgcolor=#E7F0F8>" if ($switch);
		print "<tr bgcolor=#EEEEEE>" unless ($switch);
		print "<td nowrap>$font1 $count</font></td> ";
		print "<td nowrap>$font1 $t1</font></td> ";
		print "<td nowrap>$font1 $t3</font></td> ";
		print "<td align=right nowrap>$font2 $t4</font></td> ";
		if ($loggedAFFILIATES{$t5}) {
		($aname, $aemail) = split (/\|/, $loggedAFFILIATES{$t5});
		print "<td nowrap>$font1 <a href=\"mailto:$aemail\">$aname</a></font></td> ";
		} else {
		print "<td nowrap>$font1 not in list </font></td> ";
		}
		print "<td align=center nowrap>$font2 $t12</font></td> ";
		print "<td align=right nowrap>$font2 $t14</font></td> ";
		print "<td align=right nowrap>$font1 $t15</font></td> ";
		print "</tr> \n";
		if ($switch) {$switch = 0} else {$switch = 1}
		$count++;
		}
	}
	}
	print "</table><P>";
	} # end View_Rep_History
	# AFFILIATE STATS
	if ($frm{'View_Affiliate_Stats'}) {
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Affiliate Stats </strong></font>";
	print "$font1 sorted by higest earnings </font>";
	print "</td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr> ";
	print "<td align=center colspan=3>$font2 <br></font></td> ";
	print "<td align=center colspan=3 bgcolor=#CEE1EC>$font2 <strong>Affiliates</strong></font></td> ";
	print "<td align=center colspan=3 bgcolor=#CEE1EC>$font2 <strong>Rep $r2</strong></font></td> ";
	print "</tr>\n\n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font1 <strong>#</strong></font></td> ";
	print "<td align=center>$font1 <strong>affiliate</strong></font></td> ";
	print "<td align=center>$font1 <strong>invoices</strong></font></td> ";
	print "<td align=center>$font1 <strong>earnings</strong></font></td> ";
	print "<td align=center>$font1 <strong>payments</strong></font></td> ";
	print "<td align=center>$font1 <strong>pending</strong></font></td> ";
	print "<td align=center>$font1 <strong>earnings</strong></font></td> ";
	print "<td align=center>$font1 <strong>payments</strong></font></td> ";
	print "<td align=center>$font1 <strong>pending</strong></font></td> ";
	print "</tr>\n\n";
    	@sortEARNINGS = sort ({ $AEARNINGS{$b} <=> $AEARNINGS{$a} } keys (%AEARNINGS));
	($switch,$count) = (1,1);
	foreach $aff (@sortEARNINGS) {
		$pndg = ($AEARNINGS{$aff} - $APAYMENTS{$aff});
		$Rpndg = ($REARNINGS{$aff} - $RPAYMENTS{$aff});
		$Tpndg += $pndg;
		$TRpndg += $Rpndg;
		$Tinvc += $AINVOICES{$aff};
		$Terngs += $AEARNINGS{$aff};
		$Tpymts += $APAYMENTS{$aff};
		$TRerngs += $REARNINGS{$aff};
		$TRpymts += $RPAYMENTS{$aff};
		$pndg = sprintf "%.2f", $pndg;
		$pndg = CommifyNumbers($pndg);
		$erngs = sprintf "%.2f", $AEARNINGS{$aff};
		$erngs = CommifyNumbers($erngs);
		$pymts = sprintf "%.2f", $APAYMENTS{$aff};
		$pymts = CommifyNumbers($pymts);
		$Rpndg = sprintf "%.2f", $Rpndg;
		$Rpndg = CommifyNumbers($Rpndg);
		$Rerngs = sprintf "%.2f", $REARNINGS{$aff};
		$Rerngs = CommifyNumbers($Rerngs);
		$Rpymts = sprintf "%.2f", $RPAYMENTS{$aff};
		$Rpymts = CommifyNumbers($Rpymts);
		print "<tr bgcolor=#E7F0F8>" if ($switch);
		print "<tr bgcolor=#EEEEEE>" unless ($switch);
		print "<td nowrap>$font1 $count</font></td> ";
		if ($loggedAFFILIATES{$aff}) {
		($aname, $aemail) = split (/\|/, $loggedAFFILIATES{$aff});
		print "<td nowrap>$font2 <a href=\"mailto:$aemail\">$aname</a></font></td> ";
		} else {
		print "<td nowrap>$font1 not in list </font></td> ";
		}
		print "<td align=center nowrap>$font1 $AINVOICES{$aff} </font></td> ";
		print "<td align=right nowrap>$font1 $erngs </font></td> ";
		print "<td align=right nowrap>$font1 $pymts </font></td> ";
		print "<td align=right nowrap>$font1 $pndg </font></td> ";
		print "<td align=right nowrap>$font1 $Rerngs </font></td> ";
		print "<td align=right nowrap>$font1 $Rpymts </font></td> ";
		print "<td align=right nowrap>$font1 $Rpndg </font></td> ";
		print  "</tr>\n";
		if ($switch) {$switch = 0} else {$switch = 1}
		$count++;
	}
	$Tinvc = CommifyNumbers($Tinvc);
	$Tpndg = sprintf "%.2f", $Tpndg;
	$Tpndg = CommifyNumbers($Tpndg);
	$TRpndg = sprintf "%.2f", $TRpndg;
	$TRpndg = CommifyNumbers($TRpndg);
	$Terngs = sprintf "%.2f", $Terngs;
	$Terngs = CommifyNumbers($Terngs);
	$Tpymts = sprintf "%.2f", $Tpymts;
	$Tpymts = CommifyNumbers($Tpymts);
	$TRerngs = sprintf "%.2f", $TRerngs;
	$TRerngs = CommifyNumbers($TRerngs);
	$TRpymts = sprintf "%.2f", $TRpymts;
	$TRpymts = CommifyNumbers($TRpymts);
	print "<tr bgcolor=#E7F0F8>" if ($switch);
	print "<tr bgcolor=#EEEEEE>" unless ($switch);
	print "<td align=right nowrap colspan=2>$font1 Totals: </font></td> ";
	print "<td align=center nowrap>$font1 $Tinvc </font></td> ";
	print "<td align=right nowrap>$font1 $Terngs </font></td> ";
	print "<td align=right nowrap>$font1 $Tpymts </font></td> ";
	print "<td align=right nowrap>$font1 $Tpndg </font></td> ";
	print "<td align=right nowrap>$font1 $TRerngs </font></td> ";
	print "<td align=right nowrap>$font1 $TRpymts </font></td> ";
	print "<td align=right nowrap>$font1 $TRpndg </font></td> ";
	print "</tr></table><P>";
	} # end View_Affiliate_Stats
	print "@footer \n\n";
	}

# PAY REP EARNINGS
sub PAY_REP {
	my ($switch);
	my ($key, $val);
	my ($aname, $aemail);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $RepRecord);
	my ($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15);
	$pending_count = ($pending_count - $current_count);
	$pending_amt = ($pending_amt - $current_amt);
	$pending_count = CommifyNumbers ($pending_count);
	$pending_amt = sprintf "%.2f", $pending_amt;
	$pending_amt = CommifyMoney ($pending_amt);
	$total_paid = ($previous_count + $current_count);
	$total_paid_amt = ($previous_amt + $current_amt);
	$previous_count = CommifyNumbers ($previous_count);
	$previous_amt = sprintf "%.2f", $previous_amt;
	$previous_amt = CommifyMoney ($previous_amt);
	$current_count = CommifyNumbers ($current_count);
	$current_amt = sprintf "%.2f", $current_amt;
	$current_amt = CommifyMoney ($current_amt);
	$total_paid = CommifyNumbers ($total_paid);
	$total_paid_amt = sprintf "%.2f", $total_paid_amt;
	$total_paid_amt = CommifyMoney ($total_paid_amt);
	my ($astat_current) = CommifyNumbers(scalar(keys(%currentAFFILIATES)));
	my ($astat_logged) = CommifyNumbers(scalar(keys(%loggedAFFILIATES)));
	my ($astat_earnings) = 0;
	while (($key, $val) = each (%AEARNINGS)) {$astat_earnings += $val}
	my ($astat_payments) = 0;
	while (($key, $val) = each (%APAYMENTS)) {$astat_payments += $val}
	my ($astat_pending) = ($astat_earnings - $astat_payments);
	$astat_earnings = sprintf "%.2f", $astat_earnings;
	$astat_earnings = CommifyMoney ($astat_earnings);
	$astat_payments = sprintf "%.2f", $astat_payments;
	$astat_payments = CommifyMoney ($astat_payments);
	$astat_pending = sprintf "%.2f", $astat_pending;
	$astat_pending = CommifyMoney ($astat_pending);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font4<strong>S T A T E M E N T &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%><tr>";
	print "<td valign=top> \n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "$font2 Representative: <font color=navy><b>$r2 </b>&nbsp;&nbsp;</font>";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Rep $r2\">";
	print "<br><strong> $r4 $r5 </strong></font><br>\n";
	print "$font2 $r6 <br></font>" if ($r6);
	print "$font2 $r7 <br></font>" if ($r7);
	print "$font2 $r8, $r9 &nbsp; $r10 &nbsp;&nbsp $r11 <br></font>";
	print "$font2 Phone: $r12 <br></font>" if ($r12);
	print "$font2 DOB: $r13 <br></font>" if ($r13);
	print "$font2 <a href=\"mailto:$r14\">$r14</a><br></font>" if ($r14);
	print "$font2 Member Since: $r1 <br></font>" if ($r1);
	print "$font2 Current Rate: $r3 <br></font></FORM></td>";
	print "<td valign=top nowrap>";
	print "$font2 <b><u>Affiliate Stats</u></b><p> \n";
	print "$font2 Assigned Affiliates = $astat_current <br></font>\n";
	print "$font2 Earning Affiliates = $astat_logged </font><p>\n";
	print "<table border=0 cellpadding=0 cellspacing=0> \n";
	print "<tr><td>$font2 Earnings &nbsp;&nbsp;</font></td><td align=right>$font2 $currency $astat_earnings</font></td></tr>\n";
	print "<tr><td>$font2 Payments &nbsp;&nbsp;</font></td><td align=right>$font2 $currency $astat_payments</font></td></tr>\n";
	print "<tr><td>$font2 Pending &nbsp;&nbsp;</font></td><td align=right>$font2 $currency $astat_pending</font></td></tr>\n";
	print "</table>\n\n";
	print "</td></tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=2>";
	print "<tr><td> ";
	print "$font2 Posted <strong>$currency $current_amt</strong> for ";
	print "<strong>$r4 $r5 </strong> on $ShortDate</font>";
	print "</td></tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC> ";
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "<INPUT type=\"hidden\" name=\"View_Rep_Pending\" value=\"$view_rep_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Rep_History\" value=\"$view_rep_history\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Stats\" value=\"$view_affiliate_stats\">";
	print "<td>$font2 <strong> Account Summary: REPRESENTATIVE $r2 </strong>&nbsp;&nbsp;</font> \n\n";
	print "<INPUT type=image src=\"$image_path/ares_view_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History for Rep $r2\">";
	print "</td></FORM></tr> ";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 All previous payments/earnings for <strong>$previous_count </strong> invoices = ";
	print "$currency $previous_amt </font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 <b>This Statement:</b> Payments/earnings for <strong>$current_count </strong> invoices = ";
	print "<strong>$currency $current_amt </strong></font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Making your overall total payments to date: $currency $total_paid_amt </font></td></tr> \n";
	if ($pending_count) {
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 You Have Payments/earnings for <b>$pending_count</b> Invoices <b>$currency $pending_amt</b> Still Pending</font></td></tr> \n";
	}
	print "</table><p>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Earnings Detail - ";
	print "Representative Number: $r2 </strong>Paid/Posted $ShortDate</font></td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font1 <strong>#</strong></font></td> ";
	print "<td align=center>$font1 <strong>date</strong></font></td> ";
	print "<td align=center>$font1 <strong>invoice</strong></font></td> ";
	print "<td align=center>$font1 <strong>amount</strong></font></td> ";
	print "<td align=center>$font1 <strong>affiliate</strong></font></td> ";
	print "<td align=center>$font1 <strong>rate</strong></font></td> ";
	print "<td align=center>$font1 <strong>amt paid</strong></font></td> ";
	print "<td align=center>$font1 <strong>date paid</strong></font></td> ";
	print "</tr>\n\n";
	($switch,$count) = (1,1);
	foreach (@TRSUMMARY) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_) ;
		$t4 = sprintf "%.2f", $t4;
		$t4 = CommifyMoney ($t4);
		$t14 = sprintf "%.2f", $t14;
		$t14 = CommifyMoney ($t14);
	print "<tr bgcolor=#C9DCEE>" if ($switch);
	print "<tr bgcolor=#EEEEEE>" unless ($switch);
	print "<td nowrap>$font1 $count</font></td> ";
	print "<td nowrap>$font1 $t1</font></td> ";
	print "<td nowrap>$font1 $t3</font></td> ";
	print "<td align=right nowrap>$font2 $t4</font></td> ";
	if ($loggedAFFILIATES{$t5}) {
	($aname, $aemail) = split (/\|/, $loggedAFFILIATES{$t5});
	print "<td nowrap>$font1 <a href=\"mailto:$aemail\">$aname</a></font></td> ";
	} else {
	print "<td nowrap>$font1 not in list </font></td> ";
	}
	print "<td align=center nowrap>$font2 $t12</font></td> ";
	print "<td align=right nowrap>$font2 $t14</font></td> ";
	print "<td align=right nowrap>$font1 $t15</font></td> ";
	print "</tr> \n";
	if ($switch) {$switch = 0} else {$switch = 1}
	$count++;
	}
	print "</table>";
	print "@footer \n\n";
	}

# LIST REP EARNINGS
sub LIST_REP_EARNINGS {
	my ($i1, $i2, $i3, $i4, $i5, $i6);
	my ($pd_amt, $pd_count, $notpd_amt, $notpd_count);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>LISTING REPRESENTATIVE EARNINGS &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table><p>";
	$total_paid = CommifyNumbers ($total_paid);
	$total_paid_amt = sprintf "%.2f", $total_paid_amt;
	$total_paid_amt = CommifyMoney ($total_paid_amt);
	$total_notpaid = CommifyNumbers ($total_notpaid);
	$total_notpaid_amt = sprintf "%.2f", $total_notpaid_amt;
	$total_notpaid_amt = CommifyMoney ($total_notpaid_amt);
	print "<table border=0 cellpadding=2 cellspacing=0 width=100\%><tr> ";
	print "<td bgcolor=#E5E5E5>$font2 <strong>Pending Rep Earnings: $total_notpaid \n";
	print "( $currency $total_notpaid_amt ) </strong></font></td> ";
	print "<td align=right bgcolor=#E5E5E5>$font2 Payments To Date $total_paid: \n";
	print "( $currency $total_paid_amt ) </font></td> ";
	print "</tr></table> \n ";
	print "<table border=0 cellpadding=2 bgcolor=#FFFFFF cellspacing=2 width=100\%>";
	print "<tr><td align=right colspan=6>$font1 Rep Records sorted by Higest Earnings \n";
	print "</font></td><td><br></td></tr> ";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Rep</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>name</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>email</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>started</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>phone</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>rate</strong></font></font></td> \n";
	print "<td align=center nowrap bgcolor=#FFFFFF>$font2 <br></font></td>";
	print "</tr>\n";
	# LAYOUT RECORDS
	foreach (@RepFinalSort) {
	($i1, $i2, $i3, $i4, $i5, $i6) = split (/\|/, $RepRecordInfo{$_});
	print "<tr bgcolor=#E7F0F8> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$_\">";
	print "<INPUT type=\"hidden\" name=\"View_Rep_Pending\" value=\"$view_rep_pending\">";
	print "<td nowrap>$font2 <strong>$_ </strong></font></td>";
	print "<td nowrap>$font2 $i3 $i4</font></td>";
	print "<td nowrap>$font2 <a href=\"mailto:$i2\">$i2</a></font></td>";
	print "<td nowrap>$font2 $i1</font></td>";
	print "<td nowrap>$font1 $i5</font></td>";
	print "<td nowrap>$font2 $i6</font></td>\n\n";
	print "<td align=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_view_rep.gif\" border=0 width=\"21\" height=\"21\" alt=\"View-Pay Rep Earnings $_\">";
	print "</td></FORM></tr>\n\n";
	$pd_count = CommifyNumbers ($RepPaidCount{$_});
	$pd_amt = sprintf "%.2f", $RepPaidAmt{$_};
	$pd_amt = CommifyMoney ($pd_amt);
	$notpd_count = CommifyNumbers ($RepNotCount{$_});
	$notpd_amt = sprintf "%.2f", $RepNotAmt{$_};
	$notpd_amt = CommifyMoney ($notpd_amt);
	print "<tr> ";
	print "<td>$font2 <br></td>";
	print "<td  bgcolor=#F8F8F8 colspan=5 align=right>$font2 ";
	print "<strong>$notpd_count unpaid transcations, ";
	print "earnings = $currency $notpd_amt </strong></font></td>";
	print "<td align=center bgcolor=#FFFFFF>$font2 ";
	print "</font></td></tr>\n\n";
	print "<tr><td>$font2 <br></td>";
	print "<td  bgcolor=#F4FFF3 colspan=5 align=right>$font2 ";
	print "$pd_count paid transcations, ";
	print "earnings = $currency $pd_amt </font></td>";
	print "<td>$font1 <br></font></td></tr>\n\n";
	}
	print "</table> ";
	print "@footer \n\n";
	}

# EDIT COUPON SEARCH
sub EDIT_COUPON_SEARCH {
	my (@tmp) = ();
	my (@SortTemp) = ();
	my (@SortResults) = ();
	my ($str) = $frm{'Ecom_Search_String'};
	my ($count) = scalar(@SEARCH_RESULTS);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	my ($fixmail, $fixrecno);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>AFFILIATE SEARCH RESULTS &nbsp;&nbsp </strong></td> \n";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>\n";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=0 width=100\%><tr> ";
	print "<td bgcolor=#CFE7E7>$font2 <strong>Matched $count for $str </strong></font></td> ";
	print "<td align=right bgcolor=#CFE7E7>$font2 Total Affiliates: $TotalAffiliates </font></td> ";
	print "</tr></table> \n ";
		# Sort by Last Name
		foreach (@SEARCH_RESULTS) {
		($i3, $i4, $i5, $i2, $i1, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		$_ = join ('|', ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14));
		push (@SortTemp, $_);
		}
		@SearchResults = sort (@SortTemp);
	print "<table border=0 cellpadding=1 bgcolor=#FFFFFF cellspacing=2 width=100\%>";
	print "<tr><td align=right colspan=4>$font1 Affiliate Records sorted by Last Name</font></td><td><br></td></tr> ";
	print "<tr bgcolor=#E4E4E4> ";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Name</strong></font></font></td>";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Coupon Num</strong></font></font></td>";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Started</strong></font></font></td>";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Rep Code</strong></font></font></td>";
	print "<td align=center nowrap bgcolor=#FFFFFF>$font2 <br></font></td>";
	print "</tr>\n";
	foreach (@SearchResults) {
		@tmp = split (/\|/, $_); 
		foreach (@tmp) {s/($str)/<strong>$1<\/strong>/gi}
		$fixrecno = $tmp[4];
		$fixrecno =~ s/(<strong>)//gi;
		$fixrecno =~ s/(<\/strong>)//gi;
		$fixmail = $tmp[3];
		$fixmail =~ s/(<strong>)//gi;
		$fixmail =~ s/(<\/strong>)//gi;
	print "<tr bgcolor=#FFFFFF><td colspan=5>$font1 <hr></font></td></tr>";
	# Print first row - EDIT_COUPON
	print "<tr bgcolor=#F4FFF3> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<td nowrap>$font2 $tmp[1] $tmp[0]</font></td>";
	print "<td nowrap>$font2 $tmp[4]</font></td>";
	print "<td nowrap>$font2 $tmp[2]</font></td>";
	print "<td nowrap>$font2 $tmp[13]</font></td>\n\n";
	print "<td align=center valign=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$fixrecno\">";
	print "$font2 ";
	# print "<INPUT type=submit value=\"edit\">";
	print "<INPUT type=image src=\"$image_path/ares_edit.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Affiliate $fixrecno\">";
	print "</font>";
	print "</td></FORM></tr>\n\n";
	# Print second row - VIEW_COUPON
	print "<tr bgcolor=#EBEBEB> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<td nowrap colspan=4>$font2 $tmp[5] $tmp[6] $tmp[7] $tmp[8] $tmp[9] $tmp[10] </font></td>";
	print "<td align=center valign=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$fixrecno\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Pending\" value=\"$view_affiliate_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_History\" value=\"$view_affiliate_history\">";
	print "$font2 ";
	# print "<INPUT type=submit value=\"edit\"> ";
	print "<INPUT type=image src=\"$image_path/ares_view.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History $fixrecno\">";	
	print "</font>";
	print "</td></FORM></tr>\n\n";
	# Print Third row - URL_COUPON
	print "<tr bgcolor=#F8F8F8> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<td nowrap colspan=4>$font1 (Phone) </font>$font2 $tmp[11] </font> $font1 (DOB) </font>$font2 $tmp[12] </font>";
	print "$font1 (UserID) </font>$font2 <a href=\"mailto:$fixmail\">$tmp[3]</a>" if ($tmp[3]);
	print "</font></td>\n";
	print "<td align=center valign=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"URL_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$fixrecno\">";
	print "$font2 ";
	# print "<INPUT type=submit value=\"edit\"> ";
	print "<INPUT type=image src=\"$image_path/ares_url.gif\" border=0 width=\"47\" height=\"16\" alt=\"Redirect URL For $fixrecno\">";
	print "</font>";
	print "</td></FORM></tr>\n\n";
	}	
	print "</table> <p> ";
	print "@footer \n\n";
	}

# EDIT COUPON INFO
sub EDIT_COUPON {
	unless ($frm{'FUNCTION'} eq "EDIT_COUPON_UPDATE") {
		($frm{'Ecom_Active_Date'},
		$frm{'Ecom_Online_Email'},
		$frm{'Ecom_Coupon_Number'},
		$frm{'Ecom_Postal_Name_First'},
		$frm{'Ecom_Postal_Name_Last'},
		$frm{'Ecom_Postal_Street_Line1'},
		$frm{'Ecom_Postal_Street_Line2'},
		$frm{'Ecom_Postal_City'},
		$frm{'Ecom_Postal_StateProv'},
		$frm{'Ecom_Postal_PostalCode'},
		$frm{'Ecom_Postal_CountryCode'},
		$frm{'Ecom_Telecom_Phone_Number'},
		$frm{'Ecom_DOB'},
		$frm{'Ecom_Rep_Number'}) = split (/\|/, $InfoRecord);
		}
	unless ($frm{'FUNCTION'} eq "EDIT_COUPON_UPDATE") {
		($CouponNumber,
		$frm{'Ecom_Customer_Discount_Rate'},
		$frm{'Ecom_Affiliate_Rate'}) = split (/\|/, $CouponRecord);
		}
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>EDITING AFFILIATE &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table><p> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$frm{'Ecom_Coupon_Number'}\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Pending\" value=\"$view_affiliate_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_History\" value=\"$view_affiliate_history\">";
	print "$font2 Affiliate Number: </font> $font2 <strong>$frm{'Ecom_Coupon_Number'} </strong></font>";
	print "&nbsp; <INPUT type=image src=\"$image_path/ares_view_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History $frm{'Ecom_Coupon_Number'}\">";	
	print "<br>$font2 Member Since: </font> $font2 $frm{'Ecom_Active_Date'}</font><br>";
	print "$font2 UserID: </font> $font2 <strong><a href=\"mailto:$frm{'Ecom_Online_Email'}\">";
	print "$frm{'Ecom_Online_Email'}</a></strong></font><br>";
	print "$font2 Note: You can only change the UserID via ";
	print "<a href=\"$user_mangement_url\">User Management</a> (pswd associated)<br>";
	print "Note: You must Log Out of Admin functions if you change UserID.<br>";
	print "Note: Changes to Reps and Rates are not retroactive <br>";
	print "Note: Changes to Reps and Rates begin at next sale </font></FORM><p>";
	print "<blockquote>";
		if (scalar(@MissingInformation)) {
		print "<ul>";
		foreach (@MissingInformation) {print "$_ \n"}
		print "</ul><p>";
		}
	print "<table border=0 cellpadding=2 cellspacing=0> \n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_COUPON_UPDATE\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$frm{'Ecom_Coupon_Number'}\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Active_Date\" value=\"$frm{'Ecom_Active_Date'}\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Online_Email\" value=\"$frm{'Ecom_Online_Email'}\">";
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap>$font2 Customer Discount Rate:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Customer_Discount_Rate\" value=\"$frm{'Ecom_Customer_Discount_Rate'}\" size=10></font> ";
	print "$font2 0.05 format for 5\% </font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap>$font2 Affiliate Earnings Rate:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Affiliate_Rate\" value=\"$frm{'Ecom_Affiliate_Rate'}\" size=10></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap>$font2 Representative Number:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Rep_Number\" value=\"$frm{'Ecom_Rep_Number'}\" size=10></font></td></tr> \n"; 
	print "<tr><td align=left bgcolor=#E5E5E5 colspan=2>$font2 <br></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap>$font2 First Name:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Name_First\" value=\"$frm{'Ecom_Postal_Name_First'}\" size=30></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap>$font2 Last Name:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_Name_Last\" value=\"$frm{'Ecom_Postal_Name_Last'}\" size=30></font> </td></tr> \n";
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap> $font2 Street Address 1:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line1\" value=\"$frm{'Ecom_Postal_Street_Line1'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap> $font2 Street Address 2:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line2\" value=\"$frm{'Ecom_Postal_Street_Line2'}\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap>$font2 City</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Postal_City\" value=\"$frm{'Ecom_Postal_City'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap> $font2 State - Province</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_StateProv\" value=\"$frm{'Ecom_Postal_StateProv'}\"></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap> $font2 Postal Code:</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_PostalCode\" value=\"$frm{'Ecom_Postal_PostalCode'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap> $font2 Country</font></td> \n"; 
	print "<td bgcolor=#E5E5E5> $font2 ";
	print "<input name=\"Ecom_Postal_CountryCode\" value=\"$frm{'Ecom_Postal_CountryCode'}\"></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap> $font2 Date of Birth</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_DOB\" value=\"$frm{'Ecom_DOB'}\"></font></td></tr> \n";
	print "<tr><td align=right bgcolor=#CFE7E7 nowrap> $font2 Phone Number</font></td> \n"; 
	print "<td bgcolor=#E5E5E5>$font2 ";
	print "<input name=\"Ecom_Telecom_Phone_Number\" value=\"$frm{'Ecom_Telecom_Phone_Number'}\"></font> </td></tr> \n"; 
	print "<tr><td align=right colspan=2> \n"; 
	print "<br><INPUT type=Submit value=\"Update Affiliate\">";
	print "</td></tr> \n"; 
	print "</table></FORM><p></blockquote>";
	print "@footer \n\n";
	}

# VIEW COUPON INFO
sub VIEW_COUPON {
	my ($switch, $inv);
	my ($c1, $c2, $c3) = split (/\|/, $CoupRec);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $InfoRec);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $RepRec);
	my ($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15);
	$total_paid = ($previous_count + $current_count);
	$total_paid_amt = ($previous_amt + $current_amt);
	$previous_count = CommifyNumbers ($previous_count);
	$previous_amt = sprintf "%.2f", $previous_amt;
	$previous_amt = CommifyMoney ($previous_amt);
	$current_count = CommifyNumbers ($current_count);
	$current_amt = sprintf "%.2f", $current_amt;
	$current_amt = CommifyMoney ($current_amt);
	$total_paid = CommifyNumbers ($total_paid);
	$total_paid_amt = sprintf "%.2f", $total_paid_amt;
	$total_paid_amt = CommifyMoney ($total_paid_amt);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$CouponCode\">";
	print "<table border=0 cellpadding=2 cellspacing=0>";
	print "<tr>";
	print "<td valign=top>$font2 $Date $ShortTime  </font></td> ";
	print "<td valign=top>$font2 ";
	print "<INPUT type=\"checkbox\" name=\"View_Affiliate_Pending\" value=\"10\"";
	if ($frm{'View_Affiliate_Pending'}) {print "checked=\"on\">"} else {print ">"}
	print "$font1 <b>pending</b></font> \n";
	print "<INPUT type=\"checkbox\" name=\"View_Affiliate_History\" value=\"10\"";
	if ($frm{'View_Affiliate_History'}) {print "checked=\"on\">"} else {print ">"}
	print "$font1 <b>history</b></font> \n";
	print "</font></td>\n";
	print "<td valign=center>$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_view_rep.gif\" border=0 width=\"21\" height=\"21\" alt=\"Apply Filter\">";
	print "</font></td></table></FORM>\n\n";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>AFFILIATE ACCOUNT HISTORY &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM><p></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM><p></td>";
	print "</tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%><tr>";
	print "<td valign=top> \n";
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$CouponCode\">";
	print "$font3 <strong> $i4 $i5 &nbsp;</strong></font> ";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Affiliate $CouponCode\">";
	print "<br>$font2 Affiliate ID:</font>$font3 <font color=navy><strong>$CouponCode </strong></font></font></font><br>\n";
	print "$font2 $i6 <br></font>" if ($i6);
	print "$font2 $i7 <br></font>" if ($i7);
	print "$font2 $i8, $i9 &nbsp; $i10 &nbsp;&nbsp $i11 <br></font>";
	print "$font2 Phone: $i12 <br></font>" if ($i12);
	print "$font2 DOB: $i13 <br></font>" if ($i13);
	print "$font2 <a href=\"mailto:$i2\">$i2</a><br></font>" if ($i2);
	print "$font2 Member Since: $i1 <br></font>" if ($i1);
	print "$font2 Customer Discount: $c2 <br></font>";
	print "$font2 Affiliate Rate: $c3 <br></font>";
	print "</FORM></td><td valign=top>";
	if ($RepRec) {
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "$font2 Representative: <font color=navy><b>$r2 </b>&nbsp;</font></font>";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Rep $r2\">";
	print "<P>";
	print "$font2 <strong> $r4 $r5 </strong></font><br>\n";
	print "$font2 $r6 <br></font>" if ($r6);
	print "$font2 $r7 <br></font>" if ($r7);
	print "$font2 $r8, $r9 &nbsp; $r10 &nbsp;&nbsp $r11 <br></font>";
	print "$font2 Phone: $r12 <br></font>" if ($r12);
	print "$font2 DOB: $r13 <br></font>" if ($r13);
	print "$font2 <a href=\"mailto:$r14\">$r14</a><br></font>" if ($r14);
	print "$font2 Member Since: $r1 <br></font>" if ($r1);
	print "$font2 Current Rate: $r3 <br></font></FORM>";
		} else {
		print "<BR><BR>";
		}
	print "</td></tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Account Summary: AFFILIATE $CouponCode</strong></font></td></tr> ";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 All previous payments/earnings for <strong>$previous_count </strong> invoices = ";
	print "$currency $previous_amt </font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Pending payments/earnings for <strong>$current_count </strong> invoices = ";
	print "<strong>$currency $current_amt </strong></font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Making your overall total affiliate earnings to date: $currency $total_paid_amt </font></td></tr> \n";
	print "</table><P>";

	# PENDING
	if ($frm{'View_Affiliate_Pending'}) {
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"PAY_SELECT\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$CouponCode\">";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Payment Pending Detail - ";
	print "$CouponCode - Has Not Yet Been Paid</strong></font>";
	print "</td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>date</strong></font></td> ";
	print "<td align=center>$font2 <strong>invoice</strong></font></td> ";
	print "<td align=center>$font2 <strong>amount</strong></font></td> ";
	print "<td align=center>$font2 <strong>customer</strong></font></td> ";
	print "<td align=center>$font2 <strong>rate</strong></font></td> ";
	print "<td align=center>$font2 <strong>pending</strong></font></td> ";
	print "<td align=center>$font2 <strong>pay ?</strong></font></td> ";
	print "</tr>\n\n";
	($switch,$count) = (1,1);
	foreach $inv (@sortINVC) {
	foreach (@TRSUNPAID) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_) ;
		if ($t3 == $inv) {
		$t4 = sprintf "%.2f", $t4;
		$t4 = CommifyMoney ($t4);
		$t7 = sprintf "%.2f", $t7;
		$t7 = CommifyMoney ($t7);
		print "<tr bgcolor=#E7F0F8>" if ($switch);
		print "<tr bgcolor=#EEEEEE>" unless ($switch);
		print "<td nowrap>$font1 $count</font></td> ";
		print "<td nowrap>$font1 $t1</font></td> ";
		print "<td nowrap>$font1 $t3</font></td> ";
		print "<td align=right nowrap>$font2 $t4</font></td> ";
		print "<td nowrap>$font1 <a href=\"mailto:$t8\">$t8</a></font></td> ";
		print "<td align=center nowrap>$font2 $t6</font></td> ";
		print "<td align=right nowrap>$font2 $t7</font></td> ";
		print "<td align=center>$font1 ";
		print "<INPUT type=\"CHECKBOX\" NAME=\"InvcNumber\" VALUE=\"$t3\" CHECKED=\"ON\"> pay </font></td>\n";
		print "</tr> \n";
		if ($switch) {$switch = 0} else {$switch = 1}
		$count++;
		}
	}
	}
	print "<tr><td colspan=8 align=right>\n\n";
	if ($current_count) {
	print "<INPUT type=image src=\"$image_path/ares_pay.gif\" border=0 width=\"47\" height=\"16\" alt=\"Pay Selected Invoices\">";
	} else {
	print "$font2 No pending earnings ";
	}
	print "</td></tr></table></FORM><P>";
	} # end View_Affiliate_Pending
	# PAID HISTORY
	if ($frm{'View_Affiliate_History'}) {
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Previously Paid Detail - ";
	print "$CouponCode - Has Already Been Paid</strong></font></td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>date</strong></font></td> ";
	print "<td align=center>$font2 <strong>invoice</strong></font></td> ";
	print "<td align=center>$font2 <strong>amount</strong></font></td> ";
	print "<td align=center>$font2 <strong>customer</strong></font></td> ";
	print "<td align=center>$font2 <strong>rate</strong></font></td> ";
	print "<td align=center>$font2 <strong>amt paid</strong></font></td> ";
	print "<td align=center>$font2 <strong>date paid</strong></font></td> ";
	print "</tr>\n\n";
	($switch,$count) = (1,1);
	foreach $inv (@sortINVC) {
	foreach (@TRSPAID) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_) ;
		if ($t3 == $inv) {
		$t4 = sprintf "%.2f", $t4;
		$t4 = CommifyMoney ($t4);
		$t9 = sprintf "%.2f", $t9;
		$t9 = CommifyMoney ($t9);
		print "<tr bgcolor=#E7F0F8>" if ($switch);
		print "<tr bgcolor=#EEEEEE>" unless ($switch);
		print "<td nowrap>$font1 $count</font></td> ";
		print "<td nowrap>$font1 $t1</font></td> ";
		print "<td nowrap>$font1 $t3</font></td> ";
		print "<td align=right nowrap>$font2 $t4</font></td> ";
		print "<td nowrap>$font1 <a href=\"mailto:$t8\">$t8</a></font></td> ";
		print "<td align=center nowrap>$font2 $t6</font></td> ";
		print "<td align=right nowrap>$font2 $t9</font></td> ";
		print "<td align=right nowrap>$font1 $t10</font></td> ";
		print "</tr> \n";
		if ($switch) {$switch = 0} else {$switch = 1}
		$count++;
		}

	}
	}
	print "</table><P>";
	} # end View_Affiliate_History
	print "@footer \n\n";
	}

# AFFILIATES PAY SELECT
sub PAY_SELECT {
	my ($switch);
	my ($c1, $c2, $c3) = split (/\|/, $CoupRec);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $InfoRec);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $RepRec);
	my ($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15);
	$pending_count = ($pending_count - $current_count);
	$pending_amt = ($pending_amt - $current_amt);
	$pending_count = CommifyNumbers ($pending_count);
	$pending_amt = sprintf "%.2f", $pending_amt;
	$pending_amt = CommifyMoney ($pending_amt);
	$total_paid = ($previous_count + $current_count);
	$total_paid_amt = ($previous_amt + $current_amt);
	$previous_count = CommifyNumbers ($previous_count);
	$previous_amt = sprintf "%.2f", $previous_amt;
	$previous_amt = CommifyMoney ($previous_amt);
	$current_count = CommifyNumbers ($current_count);
	$current_amt = sprintf "%.2f", $current_amt;
	$current_amt = CommifyMoney ($current_amt);
	$total_paid = CommifyNumbers ($total_paid);
	$total_paid_amt = sprintf "%.2f", $total_paid_amt;
	$total_paid_amt = CommifyMoney ($total_paid_amt);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font4<strong>S T A T E M E N T &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%><tr>";
	print "<td valign=top> \n";
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$CouponCode\">";
	print "$font3 <strong> $i4 $i5 &nbsp;</strong></font> ";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Affiliate $CouponCode\">";
	print "<br>$font2 Affiliate ID:</font>$font3 <font color=navy><strong>$CouponCode </strong></font></font></font><br>\n";
	print "$font2 $i6 <br></font>" if ($i6);
	print "$font2 $i7 <br></font>" if ($i7);
	print "$font2 $i8, $i9 &nbsp; $i10 &nbsp;&nbsp $i11 <br></font>";
	print "$font2 Phone: $i12 <br></font>" if ($i12);
	print "$font2 DOB: $i13 <br></font>" if ($i13);
	print "$font2 <a href=\"mailto:$i2\">$i2</a><br></font>" if ($i2);
	print "$font2 Member Since: $i1 <br></font>" if ($i1);
	print "$font2 Customer Discount: $c2 <br></font>";
	print "$font2 Affiliate Rate: $c3 <br></font>";
	print "</FORM></td><td valign=top>";
	if ($RepRec) {
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "$font2 Representative: <font color=navy><b>$r2 </b>&nbsp;</font></font>";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Rep $r2\">";
	print "<P>";
	print "$font2 <strong> $r4 $r5 </strong></font><br>\n";
	print "$font2 $r6 <br></font>" if ($r6);
	print "$font2 $r7 <br></font>" if ($r7);
	print "$font2 $r8, $r9 &nbsp; $r10 &nbsp;&nbsp $r11 <br></font>";
	print "$font2 Phone: $r12 <br></font>" if ($r12);
	print "$font2 DOB: $r13 <br></font>" if ($r13);
	print "$font2 <a href=\"mailto:$r14\">$r14</a><br></font>" if ($r14);
	print "$font2 Member Since: $r1 <br></font>" if ($r1);
	print "$font2 Current Rate: $r3 <br></font></FORM>";
		} else {
		print "<BR><BR>";
		}
	print "</td></tr>";
	print "<tr><td colspan=2> ";
	print "$font2 Posted <strong>$currency $current_amt</strong> for ";
	print "<strong>$i4 $i5 </strong> on $ShortDate</font>";
	print "</td></tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC> ";
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$CouponCode\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Pending\" value=\"$view_affiliate_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_History\" value=\"$view_affiliate_history\">";
	print "<td>$font2 <strong> Account Summary: AFFILIATE $CouponCode </strong>&nbsp;&nbsp;</font> \n\n";
	print "<INPUT type=image src=\"$image_path/ares_view_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History for $CouponCode\">";
	print "</td></FORM></tr> ";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 All previous payments/earnings for <strong>$previous_count </strong> invoices = ";
	print "$currency $previous_amt </font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 <b>This Statement:</b> Payments/earnings for <strong>$current_count </strong> invoices = ";
	print "<strong>$currency $current_amt </strong></font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Making your overall total affiliate payments to date: $currency $total_paid_amt </font></td></tr> \n";
	if ($pending_count) {
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 You Have Payments/earnings for <b>$pending_count</b> Invoices <b>$currency $pending_amt</b> Still Pending</font></td></tr> \n";
	}
	print "</table><p>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Earnings Detail - ";
	print "Affiliate Number: $CouponCode </strong>Paid/Posted $ShortDate</font></td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>date</strong></font></td> ";
	print "<td align=center>$font2 <strong>invoice</strong></font></td> ";
	print "<td align=center>$font2 <strong>amount</strong></font></td> ";
	print "<td align=center>$font2 <strong>customer</strong></font></td> ";
	print "<td align=center>$font2 <strong>your rate</strong></font></td> ";
	print "<td align=center>$font2 <strong>amt paid</strong></font></td> ";
	print "<td align=center>$font2 <strong>date paid</strong></font></td> ";
	print "</tr>\n\n";
		$switch = 1;
		$count =1;
	foreach (@TRSUMMARY) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_) ;
		$t4 = sprintf "%.2f", $t4;
		$t4 = CommifyMoney ($t4);
		$t9 = sprintf "%.2f", $t9;
		$t9 = CommifyMoney ($t9);
	print "<tr bgcolor=#C9DCEE>" if ($switch);
	print "<tr bgcolor=#EEEEEE>" unless ($switch);
	print "<td nowrap>$font1 $count</font></td> ";
	print "<td nowrap>$font1 $t1</font></td> ";
	print "<td nowrap>$font1 $t3</font></td> ";
	print "<td align=right nowrap>$font2 $t4</font></td> ";
	print "<td nowrap>$font1 <a href=\"mailto:$t8\">$t8</a></font></td> ";
	print "<td align=center nowrap>$font2 $t6</font></td> ";
	print "<td align=right nowrap>$font2 $t9</font></td> ";
	print "<td align=right nowrap>$font1 $t10</font></td> ";
	print "</tr> \n";
	if ($switch) {$switch = 0} else {$switch = 1}
	$count++;
	}
	print "</table>";
	print "@footer \n\n";
	}

# URL COUPON INFO
sub URL_COUPON {
	my ($u1, $u2) =  split (/\|/, $URLRecord);
	my ($c1, $c2, $c3) =  split (/\|/, $CouponRecord);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) =  split (/\|/, $InfoRecord);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>AFFILIATE REDIRECT URL &nbsp;&nbsp; <br>  -- SETTINGS -- </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM><p></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM><p></td>";
	print "</tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4><tr>";
	print "<td valign=top> \n";
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$frm{'Ecom_Coupon_Number'}\">";
	print "$font3 <strong> $i4 $i5 &nbsp;</strong></font> ";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Affiliate $frm{'Ecom_Coupon_Number'}\">";
	print "<br>$font2 Affiliate ID:</font>$font3 <font color=navy><strong>$frm{'Ecom_Coupon_Number'} </strong></font></font></font><br>\n";
	print "$font2 $i6 <br></font>" if ($i6);
	print "$font2 $i7 <br></font>" if ($i7);
	print "$font2 $i8, $i9 &nbsp; $i10 &nbsp;&nbsp $i11 </font>";
	print "</FORM>$font2 Affiliate Rate: $c3 <br>Customer Discount: $c2 </font></td> ";
	print "<td valign=top>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$frm{'Ecom_Coupon_Number'}\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Pending\" value=\"$view_affiliate_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_History\" value=\"$view_affiliate_history\">";
	print "<INPUT type=image src=\"$image_path/ares_view_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History $frm{'Ecom_Coupon_Number'}\">";	
	print "<p>";
	print "$font2 Phone: $i12 <br></font>" if ($i12);
	print "$font2 DOB: $i13 <br></font>" if ($i13);
	print "$font2 <a href=\"mailto:$i2\">$i2</a><br></font>" if ($i2);
	print "$font2 Member Since: $i1 </font>" if ($i1);
	print "</FORM></font></td></tr>";
	print "</table>";
	print "<table border=0 cellpadding=2 cellspacing=4>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_URL_UPDATE\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$frm{'Ecom_Coupon_Number'}\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Online_Email\" value=\"$i2\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Postal_Name_First\" value=\"$i4\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Postal_Name_Last\" value=\"$i5\">";
	print "<tr><td>\n";
	if ($u1) {
	print "$font2 <b>$i4 $i5</b> # $i3 has the following Redirect URL setting <br> \n";
	print "When a visitor clicks through the Affiliate Link they will redirect to: <br>\n";
	print "<a href=\"$u2\">$u2</a> <p>\n";
	print "Enter a new URL and click the Change Button to update </font>";
	} else {
	print "$font2 There is no Redirect URL set for <b>$i4 $i5</b> # $i3 <br> \n";
	print "Click throughs on this Affiliate's Link will wind up at your default redirect URL <br>\n";
	print "Your default Redirect URL is defined in the script file <b>ares.cgi</b> settings <p> ";
	print "Enter a Redirect URL and click the Add Button to update </font> ";
	}
	print "</td></tr><tr bgcolor=#CEE1EC><td></font>";
	print "<input name=\"Ecom_Redirect_URL\" value=\"$u2\" size=55>\n"; 
	print "</td></tr><tr><td align=center></font>";
		if ($u1) {
		print "<INPUT type=Submit value=\"Change\"> \n"; 
		} else {
		print "<INPUT type=Submit value=\"Add\"> \n"; 
		}
	print "</td></FORM></tr></table><P>";
	print "@footer \n\n";
	}

# LIST AFFILIATE EARNINGS
sub LIST_AFFILIATE_EARNINGS {
	my ($i1, $i2, $i3, $i4, $i5, $i6);
	my ($pd_amt, $pd_count, $notpd_amt, $notpd_count);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font2<strong>LISTING AFFILIATE EARNINGS &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table><p>";
	$total_paid = CommifyNumbers ($total_paid);
	$total_paid_amt = sprintf "%.2f", $total_paid_amt;
	$total_paid_amt = CommifyMoney ($total_paid_amt);
	$total_notpaid = CommifyNumbers ($total_notpaid);
	$total_notpaid_amt = sprintf "%.2f", $total_notpaid_amt;
	$total_notpaid_amt = CommifyMoney ($total_notpaid_amt);
	print "<table border=0 cellpadding=2 cellspacing=0 width=100\%><tr> ";
	print "<td bgcolor=#E5E5E5>$font2 <strong>Pending Affiliate Earnings: $total_notpaid \n";
	print "( $currency $total_notpaid_amt ) </strong></font></td> ";
	print "<td align=right bgcolor=#E5E5E5>$font2 Payments To Date $total_paid: \n";
	print "( $currency $total_paid_amt ) </font></td> ";
	print "</tr></table> \n ";
	print "<table border=0 cellpadding=2 bgcolor=#FFFFFF cellspacing=2 width=100\%>";
	print "<tr><td align=right colspan=6>$font1 Affiliate Records sorted by Higest Earnings \n";
	print "</font></td><td><br></td></tr> ";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Coupon</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Name</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>User ID</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Started</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Phone</strong></font></font></td> \n";
	print "<td align=center nowrap>$font2 <font color=#000000><strong>Rep</strong></font></font></td> \n";
	print "<td align=center nowrap bgcolor=#FFFFFF>$font2 <br></font></td>";
	print "</tr>\n";
	# LAYOUT RECORDS
	foreach (@CouponsFinalSort) {
	($i1, $i2, $i3, $i4, $i5, $i6) = split (/\|/, $CouponsInfo{$_});
	print "<tr bgcolor=#E7F0F8> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$_\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Pending\" value=\"10\">";
	print "<td nowrap>$font2 <strong>$_ </strong></font></td>";
	print "<td nowrap>$font2 $i3 $i4</font></td>";
	print "<td nowrap>$font2 <a href=\"mailto:$i2\">$i2</a></font></td>";
	print "<td nowrap>$font2 $i1</font></td>";
	print "<td nowrap>$font2 $i5</font></td>";
	print "<td nowrap>$font2 $i6</font></td>\n\n";
	print "<td align=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_select.gif\" border=0 width=\"47\" height=\"16\" alt=\"Pay Selected Invoices $_\">";
	print "</td></FORM></tr>\n\n";
	$pd_count = CommifyNumbers ($CouponsPaidCount{$_});
	$pd_amt = sprintf "%.2f", $CouponsPaidAmt{$_};
	$pd_amt = CommifyMoney ($pd_amt);
	$notpd_count = CommifyNumbers ($CouponsNotCount{$_});
	$notpd_amt = sprintf "%.2f", $CouponsNotAmt{$_};
	$notpd_amt = CommifyMoney ($notpd_amt);
	print "<tr> ";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"PAY_AFFILIATE\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$_\">";
	print "<td>$font2 <br></td>";
	print "<td  bgcolor=#F8F8F8 colspan=5 align=right>$font2 ";
	print "<strong>$notpd_count unpaid transcations, ";
	print "earnings = $currency $notpd_amt </strong></font></td>";
	print "<td align=center bgcolor=#FFFFFF>$font2 ";
	print "<INPUT type=image src=\"$image_path/ares_pay_all.gif\" border=0 width=\"47\" height=\"16\" alt=\"Pay All $notpd_amt Now\">";
	print "</font></td></FORM></tr>\n\n";
	print "<tr><td>$font2 <br></td>";
	print "<td  bgcolor=#F4FFF3 colspan=5 align=right>$font2 ";
	print "$pd_count paid transcations, ";
	print "earnings = $currency $pd_amt </font></td>";
	print "<td>$font1 <br></font></td></tr>\n\n";
	}
	print "</table> ";
	print "@footer \n\n";
	}

# PAY AFFILIATE
sub PAY_AFFILIATE {
	my ($switch);
	my ($c1, $c2, $c3) = split (/\|/, $CoupRec);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $InfoRec);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $RepRec);
	my ($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15);
	$total_paid = ($previous_count + $current_count);
	$total_paid_amt = ($previous_amt + $current_amt);
	$previous_count = CommifyNumbers ($previous_count);
	$previous_amt = sprintf "%.2f", $previous_amt;
	$previous_amt = CommifyMoney ($previous_amt);
	$current_count = CommifyNumbers ($current_count);
	$current_amt = sprintf "%.2f", $current_amt;
	$current_amt = CommifyMoney ($current_amt);
	$total_paid = CommifyNumbers ($total_paid);
	$total_paid_amt = sprintf "%.2f", $total_paid_amt;
	$total_paid_amt = CommifyMoney ($total_paid_amt);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime <p>";
	print "<table border=0 cellpadding=0 cellspacing=0><tr>";
	print "<td nowrap valign=top>$font4<strong>S T A T E M E N T &nbsp;&nbsp </strong></td> ";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"LOG_OUT\">";
	print "<INPUT type=submit value=\"Log Out\">";
	print "</FORM></td>";
	print "<td>";
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"MAIN_MENU\">";
	print "<INPUT type=submit value=\"Menu\">";
	print "</FORM></td>";
	print "</tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%><tr>";
	print "<td valign=top> \n";
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$CouponCode\">";
	print "$font3 <strong> $i4 $i5 &nbsp;</strong></font> ";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Affiliate $CouponCode\">";
	print "<br>$font2 Affiliate ID:</font>$font3 <font color=navy><strong>$CouponCode </strong></font></font></font><br>\n";
	print "$font2 $i6 <br></font>" if ($i6);
	print "$font2 $i7 <br></font>" if ($i7);
	print "$font2 $i8, $i9 &nbsp; $i10 &nbsp;&nbsp $i11 <br></font>";
	print "$font2 Phone: $i12 <br></font>" if ($i12);
	print "$font2 DOB: $i13 <br></font>" if ($i13);
	print "$font2 <a href=\"mailto:$i2\">$i2</a><br></font>" if ($i2);
	print "$font2 Member Since: $i1 <br></font>" if ($i1);
	print "$font2 Customer Discount: $c2 <br></font>";
	print "$font2 Affiliate Rate: $c3 <br></font>";
	print "</FORM></td><td valign=top>";
	if ($RepRec) {
	print "<FORM method=POST action=\"$programfile\">";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"EDIT_REP\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Rep_Number\" value=\"$r2\">";
	print "$font2 Representative: <font color=navy><b>$r2 </b>&nbsp;</font></font>";
	print "<INPUT type=image src=\"$image_path/ares_edit_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"Edit Rep $r2\">";
	print "<P>";
	print "$font2 <strong> $r4 $r5 </strong></font><br>\n";
	print "$font2 $r6 <br></font>" if ($r6);
	print "$font2 $r7 <br></font>" if ($r7);
	print "$font2 $r8, $r9 &nbsp; $r10 &nbsp;&nbsp $r11 <br></font>";
	print "$font2 Phone: $r12 <br></font>" if ($r12);
	print "$font2 DOB: $r13 <br></font>" if ($r13);
	print "$font2 <a href=\"mailto:$r14\">$r14</a><br></font>" if ($r14);
	print "$font2 Member Since: $r1 <br></font>" if ($r1);
	print "$font2 Current Rate: $r3 <br></font></FORM>";
		} else {
		print "<BR><BR>";
		}
	print "</td></tr>";
	print "<tr><td colspan=2> ";
	print "$font2 Posted <strong>$currency $current_amt</strong> for ";
	print "<strong>$i4 $i5 </strong> on $ShortDate</font>";
	print "</td></tr></table>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC> ";
	print "<FORM method=POST action=\"$programfile\">\n";
	print "<INPUT type=\"hidden\" name=\"FUNCTION\" value=\"VIEW_COUPON\">";
	print "<INPUT type=\"hidden\" name=\"Ecom_Coupon_Number\" value=\"$CouponCode\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_Pending\" value=\"$view_affiliate_pending\">";
	print "<INPUT type=\"hidden\" name=\"View_Affiliate_History\" value=\"$view_affiliate_history\">";
	print "<td>$font2 <strong> Account Summary: AFFILIATE $CouponCode </strong>&nbsp;&nbsp;</font> \n\n";
	print "<INPUT type=image src=\"$image_path/ares_view_left.gif\" border=0 width=\"47\" height=\"16\" alt=\"View Account History for $CouponCode\">";
	print "</td></FORM></tr> ";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 All previous payments/earnings for <strong>$previous_count </strong> invoices = ";
	print "$currency $previous_amt </font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Affiliate payments/earnings for <strong>$current_count </strong> invoices = ";
	print "<strong>$currency $current_amt </strong></font></td></tr> \n";
	print "<tr bgcolor=#F3F3F3><td>";
	print "$font2 Making your overall total affiliate earnings to date: $currency $total_paid_amt </font></td></tr> \n";
	print "</table><p>";
	print "<table border=0 cellpadding=2 cellspacing=4 width=100%> \n";
	print "<tr bgcolor=#CEE1EC><td>$font2 <strong>Earnings Detail - ";
	print "Affiliate Number: $CouponCode </strong>Paid/Posted $ShortDate</font></td></tr></table>\n";
	print "<table border=0 cellpadding=2 cellspacing=2 width=100%> \n";
	print "<tr bgcolor=#E5E5E5> ";
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>date</strong></font></td> ";
	print "<td align=center>$font2 <strong>invoice</strong></font></td> ";
	print "<td align=center>$font2 <strong>amount</strong></font></td> ";
	print "<td align=center>$font2 <strong>customer</strong></font></td> ";
	print "<td align=center>$font2 <strong>your rate</strong></font></td> ";
	print "<td align=center>$font2 <strong>amt paid</strong></font></td> ";
	print "<td align=center>$font2 <strong>date paid</strong></font></td> ";
	print "</tr>\n\n";
		$switch = 1;
		$count =1;
	foreach (@TRSUMMARY) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_) ;
		$t4 = sprintf "%.2f", $t4;
		$t4 = CommifyMoney ($t4);
		$t9 = sprintf "%.2f", $t9;
		$t9 = CommifyMoney ($t9);
	print "<tr bgcolor=#C9DCEE>" if ($switch);
	print "<tr bgcolor=#EEEEEE>" unless ($switch);
	print "<td nowrap>$font1 $count</font></td> ";
	print "<td nowrap>$font1 $t1</font></td> ";
	print "<td nowrap>$font1 $t3</font></td> ";
	print "<td align=right nowrap>$font2 $t4</font></td> ";
	print "<td nowrap>$font1 <a href=\"mailto:$t8\">$t8</a></font></td> ";
	print "<td align=center nowrap>$font2 $t6</font></td> ";
	print "<td align=right nowrap>$font2 $t9</font></td> ";
	print "<td align=right nowrap>$font1 $t10</font></td> ";
	print "</tr> \n";
	if ($switch) {$switch = 0} else {$switch = 1}
	$count++;
	}
	print "</table>";
	print "@footer \n\n";
	}

# LIBRARIES

# VALIDATE NEW REP
sub ValidateNewRep {
	# Allow zero Rep Rates
	# unless ($frm{'Ecom_Rep_Rate'} > 0 ) {
	# push (@MissingInformation, "<li>The Earnings Rate is missing")}
	unless (length($frm{'Ecom_Postal_Name_First'}) > 0 ) {
	push (@MissingInformation, "<li>First Name missing or incomplete")}
	unless (length($frm{'Ecom_Postal_Name_Last'}) > 0 ) {
	push (@MissingInformation, "<li>Last Name missing or incomplete")}
	unless (length($frm{'Ecom_Postal_Street_Line1'}) > 0 ) {
	push (@MissingInformation, "<li>Street Address missing or incomplete")}
	unless (length($frm{'Ecom_Postal_City'}) > 0 ) {
	push (@MissingInformation, "<li>City missing or incomplete")}
	unless (length($frm{'Ecom_Postal_StateProv'}) > 0 ) {
	push (@MissingInformation, "<li>State-Province missing or incomplete")}
	unless (length($frm{'Ecom_Postal_PostalCode'}) > 0 ) {
	push (@MissingInformation, "<li>Postal Code missing or incomplete")}
	unless (length($frm{'Ecom_Postal_CountryCode'}) > 0 ) {
	push (@MissingInformation, "<li>Country missing or incomplete")}
	unless (length($frm{'Ecom_Telecom_Phone_Number'}) > 0 ) {
	push (@MissingInformation, "<li>Phone Number missing or incomplete")}
	unless (length($frm{'Ecom_DOB'}) > 3 ) {
	push (@MissingInformation, "<li>Date of Birth missing or incomplete")}
	unless ($frm{'Ecom_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/) {
	push (@MissingInformation, "<li>Email Address does not appear to be valid")}
	return @MissingInformation;
	}

# FIND NEW REP CODE
sub Find_New_Rep_Code {
	$RepCode = 0;
	my (@tNum) = ();
	my (@sNum) = ();
	my (@tCode) = ();
	unless (open (RFILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Representative Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (RFILE, 2) if ($lockfiles);
		@ALLINFO = <RFILE>;
		close(RFILE);
	foreach (@ALLINFO) {
		@tCode = split(/\|/, $_);
		push (@tNum, $tCode[1]);
		}
		@ALLINFO = ();
	@sNum = sort(@tNum);
	foreach (@sNum) {$RepCode = $_}
	$RepCode += $RepCodeIncrement;
	return $RepCode;
	}

# APPEND REP INFO FILE
sub Append_To_RepFile {
	unless (open (RFILE, ">>$repinfo_path") ) { 
		$ErrMsg = "Unable to Write to Representative Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (RFILE, 2) if ($lockfiles);
		$_ = $ShortDate;
		$_ = $_ . "\|";
		$_ = $_ . $RepCode;
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Rep_Rate'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_Name_First'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_Name_Last'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_Street_Line1'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_Street_Line2'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_City'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_StateProv'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_PostalCode'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Postal_CountryCode'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Telecom_Phone_Number'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_DOB'};
		$_ = $_ . "\|";
		$_ = $_ . $frm{'Ecom_Online_Email'};
	print RFILE "$_\n";
	close (RFILE);
	}

# READ REP INFO FILE	
sub Search_Rep_Info_File {
	my ($string) = @_;
	my (@tmp) = ();
	my ($saved, $catch);
	unless (open (RFILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Representative Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (RFILE, 2) if ($lockfiles);
		@ALLINFO = <RFILE>;
		close(RFILE);
		foreach $saved (@ALLINFO) {
		$catch = 0;
		@tmp = split (/\|/, $saved); 
		foreach (@tmp) {$catch++ if ($_ =~ /$string/i)}
		push (@SEARCH_RESULTS, $saved) if ($catch);
		}
	$TotalReps = scalar(@ALLINFO);
	@ALLINFO = ();
	return (@SEARCH_RESULTS, $TotalReps);
	}

# GET REP RECORD	
sub Get_Rep_Record {
	my ($Recno) = @_;
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (RFILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Representative Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (RFILE, 2) if ($lockfiles);
		@ALLINFO = <RFILE>;
		close(RFILE);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($Recno == $i2) {
		$RepRecord = $_;
		last;
		}
	}
	@ALLINFO = ();
	chop ($RepRecord);
	return ($RepRecord);
	}

# UPDATE REP INFO FILE
sub Update_Rep_Info_File {
	my ($icount) = 0;
	my ($istr);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (RFILE, "+< $repinfo_path") ) { 
		$ErrMsg = "Unable to Update Representative Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (RFILE, 2) if ($lockfiles);
		@ALLINFO = <RFILE>;
		chop (@ALLINFO);
		seek (RFILE, 0, 0);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($i2 == $frm{'Ecom_Rep_Number'}) {
			# construct new line
			$istr = $frm{'Ecom_Rep_Date'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Rep_Number'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Rep_Rate'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Name_First'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Name_Last'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Street_Line1'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Street_Line2'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_City'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_StateProv'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_PostalCode'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_CountryCode'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Telecom_Phone_Number'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_DOB'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Online_Email'};
			$ALLINFO[$icount] = "$istr";
			
		}
	$icount++;
	}
	foreach (@ALLINFO) {print RFILE "$_\n"}
	truncate(RFILE, tell(RFILE));
	close(RFILE);
	}

# READ INFO FILE
sub Search_Info_File {
	my ($string) = @_;
	my (@tmp) = ();
	my ($saved, $catch);
	unless (open (IFILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
	flock (IFILE, 2) if ($lockfiles);
	@ALLINFO = <IFILE>;
	close(IFILE);
		foreach $saved (@ALLINFO) {
		$catch = 0;
		@tmp = split (/\|/, $saved); 
		foreach (@tmp) {$catch++ if ($_ =~ /$string/i)}
		push (@SEARCH_RESULTS, $saved) if ($catch);
		}
	$TotalAffiliates = scalar(@ALLINFO);
	@ALLINFO = ();
	return (@SEARCH_RESULTS, $TotalAffiliates);
	}

# GET ALL COUPON RECORDS
sub Get_Coupon_Records {
	my ($CouponNumber) = @_;
	my (@CouponCodeRecords) = ();
	my (@CouponInfoRecords) = ();
	my (@URLRecords) = ();
	my ($u1, $u2);
	my ($c1, $c2, $c3);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (FILE, "$couponfile_path") ) { 
		$ErrMsg = "Unable to Read Main Coupon File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@CouponCodeRecords = <FILE>;
		close(FILE);
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@CouponInfoRecords = <FILE>;
		close(FILE);
	unless (open (FILE, "$redirect_path") ) { 
		$ErrMsg = "Unable to Read Redirect File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@URLRecords = <FILE>;
		close(FILE);
	foreach (@URLRecords) {
		($u1, $u2) = split (/\|/, $_);
		if ($CouponNumber == $u1) {
		$URLRecord = $_;
		last;
		}
		}
	foreach (@CouponCodeRecords) {
		($c1, $c2, $c3) = split (/\|/, $_);
		if ($CouponNumber == $c1) {
		$CouponRecord = $_;
		last;
		}
		}
	foreach (@CouponInfoRecords) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($CouponNumber == $i3) {
		$InfoRecord = $_;
		last;
		}
		}
	@URLRecords = ();
	@CouponCodeRecords = ();
	@CouponInfoRecords = ();
	chop($CouponRecord);
	chop($InfoRecord);
	chop($URLRecord);
	return ($CouponRecord, $InfoRecord, $URLRecord);
	}

# LIST REPRESENTATIVE ACTIVITY
sub ListRepActivity {
	my ($RepNumber) = @_;
	my (@tempSORT) = ();
	my (%tempALOG) = ();
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		close(FILE);
		chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		$tempALOG{$i3} = ($i4." ".$i5."\|".$i2);
		$currentAFFILIATES{$i3} = ($i4." ".$i5."\|".$i2) if ($RepNumber == $i14);
		}
		@ALLINFO = ();
	# get transcations
	unless (open (FILE, "$activityfile_path") ) { 
		$ErrMsg = "Unable to Update Transaction log File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		close(FILE);
		chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
		if ($i11 == $RepNumber) {
		push (@tempSORT,$i3);
		$loggedAFFILIATES{$i5} = $tempALOG{$i5};
		$AEARNINGS{$i5} += $i7;
		$APAYMENTS{$i5} += $i9;
		$AINVOICES{$i5}++;
		$REARNINGS{$i5} += $i13;
		$RPAYMENTS{$i5} += $i14;
			if ( length ($i15) > 4 ) {
			$previous_count++;
			$previous_amt += $i14;
			push (@TRSPAID, $_);
			} else {
			$current_count++;
			$current_amt += $i13;
			push (@TRSUNPAID, $_);
			}
		}
		}
	@ALLINFO = ();
	%tempALOG = ();
	@sortINVC = sort {$b <=> $a} (@tempSORT);
	return (%currentAFFILIATES,
		%loggedAFFILIATES,
		%AEARNINGS,
		%APAYMENTS,
		%AINVOICES,
		@TRSUNPAID,
		@TRSPAID,
		@sortINVC,
		$previous_count,
		$previous_amt,
		$current_count,
		$current_amt
		);
	}

# PAY SELECT REP EARNINGS
sub PaySelectRepEarnings {
	my ($RepNumber) = @_;
	my (%tempALOG) = ();
	my ($InvNum);
	my ($icount) = 0;
	my ($istr);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		close(FILE);
		chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		$tempALOG{$i3} = ($i4." ".$i5."\|".$i2);
		$currentAFFILIATES{$i3} = ($i4." ".$i5."\|".$i2) if ($RepNumber == $i14);
		}
		@ALLINFO = ();
		# Update transcations
	unless (open (FILE, "+< $activityfile_path") ) { 
		$ErrMsg = "Unable to Update Transaction log File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		chop (@ALLINFO);
		seek (FILE, 0, 0);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
		if ($i11 == $RepNumber) {
			$loggedAFFILIATES{$i5} = $tempALOG{$i5};
			$AEARNINGS{$i5} += $i7;
			$APAYMENTS{$i5} += $i9;
			if ( length ($i15) > 4 ) {
			$previous_count++;
			$previous_amt += $i14;
			} else {
			$pending_count++;
			$pending_amt += $i13;
			}
			foreach $InvNum (@SELECTED_INVOICES) {
				if ($InvNum == $i3) {
				$current_count++;
				$current_amt += $i13;
				# construct new line
				$istr = $i1;
				$istr = $istr . "\|";
				$istr = $istr . $i2;
				$istr = $istr . "\|";
				$istr = $istr . $i3;
				$istr = $istr . "\|";
				$istr = $istr . $i4;
				$istr = $istr . "\|";
				$istr = $istr . $i5;
				$istr = $istr . "\|";
				$istr = $istr . $i6;
				$istr = $istr . "\|";
				$istr = $istr . $i7;
				$istr = $istr . "\|";
				$istr = $istr . $i8;
				$istr = $istr . "\|";
				$istr = $istr . $i9;
				$istr = $istr . "\|";
				$istr = $istr . $i10;
				$istr = $istr . "\|";
				$istr = $istr . $i11;
				$istr = $istr . "\|";
				$istr = $istr . $i12;
				$istr = $istr . "\|";
				$istr = $istr . $i13;
				$istr = $istr . "\|";
				$istr = $istr . $i13;
				$istr = $istr . "\|";
				$istr = $istr . $ShortDate;
				push (@TRSUMMARY, $istr);
				$ALLINFO[$icount] = "$istr";
				}
			}
		}
	$icount++;
	}
	foreach (@ALLINFO) {print FILE "$_\n"}
	truncate(FILE, tell(FILE));
	close(FILE);
	@ALLINFO = ();
	%tempALOG = ();
	return (@TRSUMMARY,
		%currentAFFILIATES,
		%loggedAFFILIATES,
		%AEARNINGS,
		%APAYMENTS,
		$pending_count,
		$pending_amt,
		$previous_count,
		$previous_amt,
		$current_count,
		$current_amt
		);
	}

# COMPILE REP EARNINGS
sub CompileRepEarnings {
	($total_paid, $total_paid_amt, $total_notpaid, $total_notpaid_amt) = (0,0,0,0);
	my ($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14);
	unless (open (TFILE, "$activityfile_path") ) { 
		$ErrMsg = "Unable to Read Transaction Log";
		&ErrorMessage($ErrMsg);
		}
		flock (TFILE, 2) if ($lockfiles);
		@TRSINFO = <TFILE>;
		close(TFILE);
		chop (@TRSINFO);
	unless (open (FILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Rep Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@REPINFO = <FILE>;
		close(FILE);
		chop (@REPINFO);
	foreach (@REPINFO) {
	($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $_);
	$RepRecordInfo{$r2} = $r1 . "\|" . $r14 . "\|" . $r4 . "\|" . $r5 . "\|" . $r12 . "\|" . $r3;	
	}
	foreach (@TRSINFO) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10, $t11, $t12, $t13, $t14, $t15) = split (/\|/, $_);
		if (length($t15) > 4) {
			if (exists($RepPaidAmt{$t11})) {
				$RepPaidAmt{$t11} += $t14;
				$RepPaidCount{$t11}++;
				$total_paid++;
				$total_paid_amt += $t14;
				} else {
				$RepPaidAmt{$t11} = $t14;
				$RepPaidCount{$t11} = 1;
				$total_paid++;
				$total_paid_amt += $t14;
			}
		} else {
			if (exists($RepNotAmt{$t11})) {
				$RepNotAmt{$t11} += $t13;
				$RepNotCount{$t11}++;
				$total_notpaid++;
				$total_notpaid_amt += $t13;
				} else {
				$RepNotAmt{$t11} = $t13;
				$RepNotCount{$t11} = 1;
				$total_notpaid++;
				$total_notpaid_amt += $t13;
			}
		}
	}
	@TRSINFO = ();
	@REPINFO = ();
    	@RepFinalSort = sort { $RepNotAmt{$b} <=> $RepNotAmt{$a} } (keys %RepNotAmt);
	return (%RepPaidAmt, 
		%RepPaidCount, 
		%RepNotAmt, 
		%RepNotCount, 
		%RepInfo, 
		@RepFinalSort,
		$total_paid,
		$total_notpaid,
		$total_notpaid_amt,
		$total_paid_amt);
	}

# VALIDATE COUPON INFO
sub ValidateCouponInfo {
	my ($repcheck) = 0;
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	if ($frm{'Ecom_Rep_Number'}) {
		unless (open (RFILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Representative Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (RFILE, 2) if ($lockfiles);
		@ALLINFO = <RFILE>;
		close(RFILE);
		foreach (@ALLINFO) {
		($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($frm{'Ecom_Rep_Number'} == $i2) {
		$repcheck++;
		last;
		}
		}
	unless ($repcheck) {
	push (@MissingInformation, "<li>Rep Number <strong>$frm{'Ecom_Rep_Number'}</strong> not valid - Add Rep first or leave blank");
	}
	}
	unless (length($frm{'Ecom_Postal_Name_First'}) > 0 ) {
	push (@MissingInformation, "<li>First Name missing or incomplete")}
	unless (length($frm{'Ecom_Postal_Name_Last'}) > 0 ) {
	push (@MissingInformation, "<li>Last Name missing or incomplete")}
	unless (length($frm{'Ecom_Postal_Street_Line1'}) > 0 ) {
	push (@MissingInformation, "<li>Street Address missing or incomplete")}
	unless (length($frm{'Ecom_Postal_City'}) > 0 ) {
	push (@MissingInformation, "<li>City missing or incomplete")}
	unless (length($frm{'Ecom_Postal_StateProv'}) > 0 ) {
	push (@MissingInformation, "<li>State-Province missing or incomplete")}
	unless (length($frm{'Ecom_Postal_PostalCode'}) > 0 ) {
	push (@MissingInformation, "<li>Postal Code missing or incomplete")}
	unless (length($frm{'Ecom_Postal_CountryCode'}) > 0 ) {
	push (@MissingInformation, "<li>Country missing or incomplete")}
	unless (length($frm{'Ecom_Telecom_Phone_Number'}) > 0 ) {
	push (@MissingInformation, "<li>Phone Number missing or incomplete")}
	unless (length($frm{'Ecom_DOB'}) > 3 ) {
	push (@MissingInformation, "<li>Date of Birth missing or incomplete")}
	return @MissingInformation;
	}

# UPDATE URL REDIRECT FILE
sub Update_Redirect_File {
	my ($CouponNumber) = @_;
	@ALLINFO = ();
	my (%NEWINFO) = ();
	my ($k,$v);
	my ($istr);
	my ($u1, $u2);
	unless (open (UFILE, "+< $redirect_path") ) { 
		$ErrMsg = "Unable to Update Redirect URL File";
		&ErrorMessage($ErrMsg);
		}
		flock (UFILE, 2) if ($lockfiles);
		@ALLINFO = <UFILE>;
		chop (@ALLINFO);
		foreach (@ALLINFO) {
		($u1, $u2) = split (/\|/, $_);
		$NEWINFO{$u1} = $u2;
		}
		@ALLINFO = ();
		while (($k, $v) = each (%NEWINFO)) { 
		if ($k == $CouponNumber) {
			$URLfound++;
			# construct new line
			$istr = $k;
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Redirect_URL'};
		push(@ALLINFO, $istr) if ($frm{'Ecom_Redirect_URL'});
		} else {
		# construct new line
		$istr = $k;
		$istr = $istr . "\|";
		$istr = $istr . $v;
		push(@ALLINFO, $istr);
		}
	}
	if ($frm{'Ecom_Redirect_URL'}) {
	push(@ALLINFO, "$CouponNumber\|$frm{'Ecom_Redirect_URL'}") unless ($URLfound);
	}
	seek (UFILE, 0, 0);
	foreach (@ALLINFO) {print UFILE "$_\n"}
	truncate(UFILE, tell(UFILE));
	close(UFILE);
	@ALLINFO = ();
	}

# UPDATE COUPON FILE
sub Update_Coupon_File {
	my ($CouponNumber) = @_;
	@ALLINFO = ();
	my ($icount) = 0;
	my ($istr);
	my ($c1, $c2, $c3);
	unless (open (CFILE, "+< $couponfile_path") ) { 
		$ErrMsg = "Unable to Update Main Coupon File";
		&ErrorMessage($ErrMsg);
		}
		flock (CFILE, 2) if ($lockfiles);
		@ALLINFO = <CFILE>;
		chop (@ALLINFO);
		seek (CFILE, 0, 0);
	foreach (@ALLINFO) {
	($c1, $c2, $c3) = split (/\|/, $_);
		if ($c1 == $CouponNumber) {
			# construct new line
			$istr = $istr . $CouponNumber;
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Customer_Discount_Rate'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Affiliate_Rate'};
			$ALLINFO[$icount] = "$istr";
			
		}
	$icount++;
	}
	foreach (@ALLINFO) {print CFILE "$_\n"}
	truncate(CFILE, tell(CFILE));
	close(CFILE);
	}

# UPDATE AFFILIATE INFO FILE
sub Update_Coupon_Info {
	my ($CouponNumber) = @_;
	@ALLINFO = ();
	my ($icount) = 0;
	my ($istr);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (IFILE, "+< $infofile_path") ) { 
		$ErrMsg = "Unable to Update Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (IFILE, 2) if ($lockfiles);
		@ALLINFO = <IFILE>;
		chop (@ALLINFO);
		seek (IFILE, 0, 0);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($i3 == $CouponNumber) {
			# construct new line
			$istr = $frm{'Ecom_Active_Date'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Online_Email'};
			$istr = $istr . "\|";
			$istr = $istr . $CouponNumber;
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Name_First'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Name_Last'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Street_Line1'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_Street_Line2'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_City'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_StateProv'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_PostalCode'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Postal_CountryCode'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Telecom_Phone_Number'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_DOB'};
			$istr = $istr . "\|";
			$istr = $istr . $frm{'Ecom_Rep_Number'};
			$ALLINFO[$icount] = "$istr";

		}
	$icount++;
	}
	foreach (@ALLINFO) {print IFILE "$_\n"}
	truncate(IFILE, tell(IFILE));
	close(IFILE);
	}

# COMPILE AFFILIATE EARNINGS
sub CompileAffiliateEarnings {
	($total_paid, $total_paid_amt, $total_notpaid, $total_notpaid_amt) = (0,0,0,0);
	my ($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (TFILE, "$activityfile_path") ) { 
		$ErrMsg = "Unable to Read Transaction Log";
		&ErrorMessage($ErrMsg);
		}
	flock (TFILE, 2) if ($lockfiles);
	@TRSINFO = <TFILE>;
	close(TFILE);
	chop (@TRSINFO);
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@AFFINFO = <FILE>;
		close(FILE);
		chop (@AFFINFO);
	foreach (@AFFINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
	$CouponsInfo{$i3} = $i1 . "\|" . $i2 . "\|" . $i4 . "\|" . $i5 . "\|" . $i12 . "\|" . $i14;	
	}
	foreach (@TRSINFO) {
	($t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10) = split (/\|/, $_);
		if (length($t10) > 4) {
			if (exists($CouponsPaidAmt{$t5})) {
				$CouponsPaidAmt{$t5} += $t9;
				$CouponsPaidCount{$t5}++;
				$total_paid++;
				$total_paid_amt += $t9;
				} else {
				$CouponsPaidAmt{$t5} = $t9;
				$CouponsPaidCount{$t5} = 1;
				$total_paid++;
				$total_paid_amt += $t9;
			}
		} else {
			if (exists($CouponsNotAmt{$t5})) {
				$CouponsNotAmt{$t5} += $t7;
				$CouponsNotCount{$t5}++;
				$total_notpaid++;
				$total_notpaid_amt += $t7;
				} else {
				$CouponsNotAmt{$t5} = $t7;
				$CouponsNotCount{$t5} = 1;
				$total_notpaid++;
				$total_notpaid_amt += $t7;
			}
		}
	}
	@TRSINFO = ();
	@AFFINFO = ();
    	@CouponsFinalSort = sort { $CouponsNotAmt{$b} <=> $CouponsNotAmt{$a} } (keys %CouponsNotAmt);
	return (	%CouponsPaidAmt, 
			%CouponsPaidCount, 
			%CouponsNotAmt, 
			%CouponsNotCount, 
			%CouponsInfo, 
			@CouponsFinalSort,
			$total_paid,
			$total_notpaid,
			$total_notpaid_amt,
			$total_paid_amt);

	}

# LIST AFFILIATE ACTIVITY
sub ListAffiliateActivity {
	my ($CouponNumber) = @_;
	my ($RepNumber);
	my (@tempSORT) = ();
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($CouponNumber == $i3) {
		$InfoRec = $_;
		$RepNumber = $i14;
		last;
		}
		}
		@ALLINFO = ();
	unless (open (FILE, "$couponfile_path") ) { 
		$ErrMsg = "Unable to Read Coupon File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3) = split (/\|/, $_);
		if ($CouponNumber == $i1) {
		$CoupRec = $_;
		last;
		}
		}
		@ALLINFO = ();
	unless (open (FILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Representative Information File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($RepNumber == $i2) {
		$RepRec = $_;
		last;
		}
		}
		@ALLINFO = ();
	# get transcations
	unless (open (FILE, "$activityfile_path") ) { 
		$ErrMsg = "Unable to Update Transaction log File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		close(FILE);
		chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
		if ($i5 == $CouponNumber) {
		push (@tempSORT,$i3);
			if ( length ($i10) > 4 ) {
			$previous_count++;
			$previous_amt += $i9;
			push (@TRSPAID, $_);
			} else {
			$current_count++;
			$current_amt += $i7;
			push (@TRSUNPAID, $_);
			}
		}
		}
	@ALLINFO = ();
	$CouponCode = $CouponNumber;
	@sortINVC = sort {$b <=> $a} (@tempSORT);
	return (	@TRSUNPAID,
			@TRSPAID,
			@sortINVC,
			$RepRec, 
			$CoupRec, 
			$InfoRec,
			$previous_count,
			$previous_amt,
			$current_count,
			$current_amt,
			$CouponCode
			);
	}

# PAY SELECT AFFILIATE EARNINGS
sub PaySelectAffiliateEarnings {
	my ($CouponNumber) = @_;
	my ($RepNumber, $InvNum);
	my ($icount) = 0;
	my ($istr);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($CouponNumber == $i3) {
		$InfoRec = $_;
		$RepNumber = $i14;
		last;
		}
		}
		@ALLINFO = ();
	unless (open (FILE, "$couponfile_path") ) { 
		$ErrMsg = "Unable to Read Coupon File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3) = split (/\|/, $_);
		if ($CouponNumber == $i1) {
		$CoupRec = $_;
		last;
		}
		}
		@ALLINFO = ();
	unless (open (FILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Representative Information File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($RepNumber == $i2) {
		$RepRec = $_;
		last;
		}
		}
		@ALLINFO = ();
		# Update transcations
	unless (open (FILE, "+< $activityfile_path") ) { 
		$ErrMsg = "Unable to Update Transaction log File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		chop (@ALLINFO);
		seek (FILE, 0, 0);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
		if ($i5 == $CouponNumber) {
			if ( length ($i10) > 4 ) {
			$previous_count++;
			$previous_amt += $i9;
			} else {
			$pending_count++;
			$pending_amt += $i7;
			}
			foreach $InvNum (@SELECTED_INVOICES) {
				if ($InvNum == $i3) {
				$current_count++;
				$current_amt += $i7;
				# construct new line
				$istr = $i1;
				$istr = $istr . "\|";
				$istr = $istr . $i2;
				$istr = $istr . "\|";
				$istr = $istr . $i3;
				$istr = $istr . "\|";
				$istr = $istr . $i4;
				$istr = $istr . "\|";
				$istr = $istr . $i5;
				$istr = $istr . "\|";
				$istr = $istr . $i6;
				$istr = $istr . "\|";
				$istr = $istr . $i7;
				$istr = $istr . "\|";
				$istr = $istr . $i8;
				$istr = $istr . "\|";
				$istr = $istr . $i7;
				$istr = $istr . "\|";
				$istr = $istr . $ShortDate;
				$istr = $istr . "\|";
				$istr = $istr . $i11;
				$istr = $istr . "\|";
				$istr = $istr . $i12;
				$istr = $istr . "\|";
				$istr = $istr . $i13;
				$istr = $istr . "\|";
				$istr = $istr . $i14;
				$istr = $istr . "\|";
				$istr = $istr . $i15;
				push (@TRSUMMARY, $istr);
				$ALLINFO[$icount] = "$istr";
				}
			}
		}
	$icount++;
	}
	foreach (@ALLINFO) {print FILE "$_\n"}
	truncate(FILE, tell(FILE));
	close(FILE);
	@ALLINFO = ();
	$CouponCode = $CouponNumber;
	return (	@TRSUMMARY, 
			$RepRec, 
			$CoupRec, 
			$InfoRec,
			$previous_count,
			$previous_amt,
			$current_count,
			$current_amt,
			$pending_count,
			$pending_amt,
			$CouponCode
			);
	}

# PAY AFFILIATE EARNINGS
sub PayAffiliateEarnings {
	my ($CouponNumber) = @_;
	my ($RepNumber);
	my ($icount) = 0;
	my ($istr);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($CouponNumber == $i3) {
		$InfoRec = $_;
		$RepNumber = $i14;
		last;
		}
		}
		@ALLINFO = ();
	unless (open (FILE, "$couponfile_path") ) { 
		$ErrMsg = "Unable to Read Coupon File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3) = split (/\|/, $_);
		if ($CouponNumber == $i1) {
		$CoupRec = $_;
		last;
		}
		}
		@ALLINFO = ();
	unless (open (FILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Representative Information File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	chop (@ALLINFO);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($RepNumber == $i2) {
		$RepRec = $_;
		last;
		}
		}
		@ALLINFO = ();
		# Update transcations
	unless (open (FILE, "+< $activityfile_path") ) { 
		$ErrMsg = "Unable to Update Transaction log File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		chop (@ALLINFO);
		seek (FILE, 0, 0);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
		if ($i5 == $CouponNumber) {
			# construct new line
			$istr = $i1;
			$istr = $istr . "\|";
			$istr = $istr . $i2;
			$istr = $istr . "\|";
			$istr = $istr . $i3;
			$istr = $istr . "\|";
			$istr = $istr . $i4;
			$istr = $istr . "\|";
			$istr = $istr . $i5;
			$istr = $istr . "\|";
			$istr = $istr . $i6;
			$istr = $istr . "\|";
			$istr = $istr . $i7;
			$istr = $istr . "\|";
			$istr = $istr . $i8;
			$istr = $istr . "\|";
				if ( length ($i10) > 4 ) {
				$istr = $istr . $i9;
				$istr = $istr . "\|";
				$istr = $istr . $i10;
				$istr = $istr . "\|";
				$previous_count++;
				$previous_amt += $i9;
				} else {
				$istr = $istr . $i7;
				$istr = $istr . "\|";
				$istr = $istr . $ShortDate;
				$istr = $istr . "\|";
				$current_count++;
				$current_amt += $i7;
				}
			$istr = $istr . $i11;
			$istr = $istr . "\|";
			$istr = $istr . $i12;
			$istr = $istr . "\|";
			$istr = $istr . $i13;
			$istr = $istr . "\|";
			$istr = $istr . $i14;
			$istr = $istr . "\|";
			$istr = $istr . $i15;
			push (@TRSUMMARY, $istr) unless ( length ($i10) > 4 );
			$ALLINFO[$icount] = "$istr";
		}
	$icount++;
	}
	foreach (@ALLINFO) {print FILE "$_\n"}
	truncate(FILE, tell(FILE));
	close(FILE);
	@ALLINFO = ();
	$CouponCode = $CouponNumber;
	return (	@TRSUMMARY, 
			$RepRec, 
			$CoupRec, 
			$InfoRec,
			$previous_count,
			$previous_amt,
			$current_count,
			$current_amt,
			$CouponCode
			);
	}

# SEARCH FOR INVOICE NUMBER	
sub Search_Invoice_Number {
	my ($string) = @_;
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	unless (open (FILE, "$activityfile_path") ) { 
		$ErrMsg = "Unable to Read Transaction Logging File";
		&ErrorMessage($ErrMsg);
		}
	flock (FILE, 2) if ($lockfiles);
	@ALLINFO = <FILE>;
	close(FILE);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
	push (@SEARCH_RESULTS, $i1 . "\|" . $i4 . "\|" . $i5) if ($i3 == $string);
	}
	$TotalTransactions = scalar(@ALLINFO);
	@ALLINFO = ();
	return (@SEARCH_RESULTS, $TotalTransactions);
	}

# DELETE INVOICE NUMBER
sub Delete_Invoice_Number {
	my ($string) = @_;
	my ($backupfile) = $activityfile_path . ".backup";
	my (@NEWINFO) = ();
	my (@BAKINFO) = ();
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	unless (open (FILE, "+< $activityfile_path") ) { 
		$ErrMsg = "Unable to Access Transaction log File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		chop (@ALLINFO);
		seek (FILE, 0, 0);
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
	push (@NEWINFO, $_) unless ($i3 == $string);
	push (@BAKINFO, $_) if ($i3 == $string);
	}
	foreach (@NEWINFO) {print FILE "$_\n"}
	truncate(FILE, tell(FILE));
	close(FILE);
	# Backup Deleted Transaction
	unless (open (BFILE, ">>$backupfile") ) { 
		$ErrMsg = "Unable to Access Transaction backup log";
		&ErrorMessage($ErrMsg);
		}
		foreach (@BAKINFO) {print BFILE "$_\n"}
		close (BFILE);
	@ALLINFO = ();
	@NEWINFO = ();
	@BAKINFO = ();
	}

# MAKE MAIL RECORDS
sub GetMailList {
	my (@list) = ();
	my (%dupelist) = ();
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15);
	if ($frm{'Mail_Customers'}) {
	unless (open (FILE, "$activityfile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@list = <FILE>;
		close(FILE);
		chop(@list);
		foreach (@list) {
 		($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14, $i15) = split (/\|/, $_);
		push (@ALLINFO,$i8) if ($i8);
		}
		}
	if ($frm{'Mail_Reps'}) {
	unless (open (FILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@list = <FILE>;
		close(FILE);
		chop(@list);
		foreach (@list) {
 		($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		push (@ALLINFO,$i14) if ($i14);
		}
		}
	if ($frm{'Mail_Affiliates'}) {
	unless (open (FILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Read Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@list = <FILE>;
		close(FILE);
		chop(@list);
		foreach (@list) {
 		($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		push (@ALLINFO,$i2) if ($i2);
		}
		}

		if ($frm{'Mail_Invalid'}) {
		@list = ();
		@list = @ALLINFO;
		@ALLINFO = ();
		foreach (@list) {
		push(@ALLINFO,$_) if ($_  =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/);
		}
		}
		if ($frm{'Mail_Dups'}) {
			foreach (@ALLINFO) {
			$dupelist{$_}++;
			}
		@ALLINFO = ();
		@ALLINFO = (keys(%dupelist));
		}
	return (@ALLINFO);
	}

# SAVE MAIL FILE
sub SaveMailFile {
	my ($path) = @_;
	unless (open (FILE, ">$path") ) { 
		$ErrMsg = "Unable to Make Mail File";
		&ErrorMessage($ErrMsg);
		}
		foreach (@ALLINFO) {
		print FILE "$_\n";
		}
	close(FILE);
	}

# PROCESS FORM	
sub ProcessForm {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);
	foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/"/ /;
	$value =~ tr/\|/ /;
	$value =~ tr/\n\r//d;
	$frm{$name} = $value;
	push (@SELECTED_INVOICES, $value) if ($name eq "InvcNumber");
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
	# Always print the cookie before the Content-Type header
	# Parse in the name 'UserID'
	my ($name_for_cookie) = @_;
	print "Set-Cookie: $name_for_cookie=$ID;expires=Sat, 1-Jan-2000 12:12:12 GMT \n";	
  }

# SET NEW COOKIE
sub MakeCookie {
	my ($name_for_cookie, $ID) = @_;
	# Always print the cookie before the Content-Type header
	# expire cookie when browser closed
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

# END MERCHANT ORDERFORM Cart ver 1.54
# Copyright by RGA http://www.merchantpal.com 2000-2001
