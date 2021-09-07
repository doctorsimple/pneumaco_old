#!/usr/bin/perl

# Merchant OrderForm v1.53 - August 2000, UPDATED 9/15/2000, UPDATED 10/01/2000
# Stand Alone Payment Processing
# Copyright © August 2000, All Rights Reserved
# Austin Contract Computing, Austin, Texas
# Russell Alexander - rga@io.com
# http://www.io.com/~rga/
# Written for Austin Contract Computing, Inc. All Rights Reserved 2000

# PLEASE NOTE_________________________________________________
# These programs are distributed as Trial Ware or Share Ware.
# You are Welcome to install and test all portions of the programs.
# The package is not limited in any way and code source is left readable.
# Please make arrangements for the fee if you continue operating it on a Web Site
# Feel free to contact me if you need special arrangements for use of MOF v1.53

# For personal web site use: $ 15.00
# For web development (3-10 sites): $ 45.00, includes limited support
# For web development (above 10 sites): $ 150.00, includes limited support
# Note: For Resale or hosting license please contact rga@io.com
# For payment arrangements: http://www.merchantorderform.com/payment.html

# IMPORTANT ____________________________________________
# Distribution of this file without owner consent is prohibited.
# Please contact the authors of this product for any use outside 
# The original registration and user license

# COPYRIGHT NOTICE____________________________________________
# The contents of this file is protected under the United States
# copyright laws as an unpublished work, and is confidential and
# proprietary to Austin Contract Computing, Inc. Its use or disclosure 
# in whole or in part without the expressed written permission of Austin
# Contract Computing, Inc. is prohibited.

# THIS IS THE PAYMENT PROCESSING PROGRAM
# THIS IS THE PAYMENT PROCESSING PROGRAM

# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES
# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES


 # DO NOT CHANGE ANY OF THESE SETTINGS
 # ===================================
 require 5.001;
 require 'mofpayment.conf';
 require 'mofpayment_lib.pl';

 # These Plug-Ins must be disabled in the mofpayment.conf file
 # You should change their name or operations by declaring a new Plug-In file
 # Declare the Plug-In files in the configuration file and enable/disable the function there

 require $save_invoice_file if ($save_invoice_html);
 require $mail_merchant_file if ($mail_merchant_invoice);
 require $mail_customer_file if ($mail_customer_receipt);

 # cookie names must be the same in both program files
 # cookie names must be the same in both program files
	
 $cookiename_OrderID = 'mof_v15_OrderID';
 $cookiename_InfoID = 'mof_v15_InfoID';


 	# START PROGRAM FLOW
 	# START PROGRAM FLOW

	&SetDateVariable;
	&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
	&ProcessPost;


	if (scalar(keys(%MissingInfoFields))) {

		@header = ();
		@footer = ();
		@state_list = ();
		@county_list = ();
		@country_list = ();
		@country_list_bill = (&GetDropBoxList($use_country_list,'Ecom_BillTo_Postal_CountryCode')) if ($use_country_list);
		@country_list_receipt = (&GetDropBoxList($use_country_list,'Ecom_ReceiptTo_Postal_CountryCode')) if ($use_country_list);
		@county_list_bill = (&GetDropBoxList($use_county_list,'Ecom_BillTo_Postal_County')) if ($use_county_list);
		@county_list_receipt = (&GetDropBoxList($use_county_list,'Ecom_ReceiptTo_Postal_County')) if ($use_county_list);
		@state_list_bill = (&GetDropBoxList($use_state_list,'Ecom_BillTo_Postal_StateProv')) if ($use_state_list);
		@state_list_receipt = (&GetDropBoxList($use_state_list,'Ecom_ReceiptTo_Postal_StateProv')) if ($use_state_list);
		&GetTemplateFile($payment_info_template,"Payment Information File"); 
		&PaymentInformation;

	} else {


		# ===========================================>
		# API HERE -- API HERE -- API HERE - API HERE  
		# API results Branch: accepted - not accepted
		# ===========================================>


		# PAYMENT ACCEPTED
		# PAYMENT ACCEPTED

		&GetInvoiceNumber;

		@header = ();
		@footer = ();
		
		if ($save_invoice_html) {
		&GetTemplateFile($save_invoice_template,"Save Invoice Template File"); 
		&SaveInvoiceFile;
		}
		

			$mail_customer_addr = "";

				# Order: ReceiptTo, BillTo, ShipTo
				# Order: ReceiptTo, BillTo, ShipTo

			if ($frm{'Ecom_ReceiptTo_Online_Email'}) {
			$mail_customer_addr = $frm{'Ecom_ReceiptTo_Online_Email'};

			} elsif ($frm{'Ecom_BillTo_Online_Email'}) {
			$mail_customer_addr = $mail_msg . $frm{'Ecom_BillTo_Online_Email'};

			} elsif ($frm{'Ecom_ShipTo_Online_Email'}) {
			$mail_customer_addr = $mail_msg . $frm{'Ecom_ShipTo_Online_Email'};

			}

		if ($delete_cart_final) {&DeleteCartFile($frm{'OrderID'})} 
		else {&ExpireCookie($cookiename_OrderID)}	

		# Append to the affiliate tracking log
		# Enable this only if you are using the Referral system
		# or if you know what you are doing to set up custom logging
		# Set the condition for whatever you want logged	
		# &LogAffiliateActivity($frm{'Compute_Coupons'}) if ($frm{'Coupon_Affiliate_Rate'} > 0);	
		

		@header = ();
		@footer = ();
		&GetTemplateFile($final_template,"Payment Final Template File"); 
		&PaymentAccepted;

		&MailMerchantInvoice if ($mail_merchant_invoice);

		&MailCustomerReceipt if ($mail_customer_receipt && $mail_customer_addr);


	}





	# PAYMENT INFO
	# PAYMENT INFO


sub PaymentInformation {

	$msg_v;
	$itm_n = 0;
	$itm_m = 0;
	$allow_methods = 0;

	my ($new_value);
	my ($key, $val);
	my ($single_option);

	$itm_m = scalar(keys(%MissingInfoFields));

	if ($itm_m == 1) {$fld = "Field"} 
	else {$fld = "Fields"}

	$submit_total = CommifyMoney($frm{'Final_Amount'});

	$allow_methods++ if ($enable_paypal);
	$allow_methods++ if ($mail_or_fax_field);
	$allow_methods++ if (scalar(keys(%checking_account_fields)));
	$allow_methods++ if (scalar(keys(%credit_card_fields)));


		# start HTML output
		# start HTML output

	print "Content-Type: text/html\n\n";
	print "@header \n\n";


		# Insert MOF navigation at TOP
		# Insert MOF navigation at TOP

	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_viewcart_top);
	$nav_top++ if ($menu_help_top);

	if ($nav_top) {
	print "<table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_previous_top) {
	print "<td nowrap><a href=\"$frm{'previouspage'}\">$menu_previous_top</a></td> \n";}

	if ($menu_viewcart_top) {
	print "<td nowrap>";
	print "<a href=\"$programfile?viewcart&previouspage=$frm{'previouspage'}\"> ";
	print "$menu_viewcart_top</a></td> \n";
	}

	if ($menu_help_top) {
	print "<td nowrap> \n";
	print "<a href=\"$menu_help_top_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_top_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_top</a></td> \n";}

	print "</tr></table><br> \n\n";
	}



		# top message 
		# top message

	print "Please complete all billing information, then click the ";
	print "<strong>place order</strong> function below to process ";
	print "payment of <strong> $currency $submit_total</strong>.<p>";


	if ($frm{'resubmit_info'}) {
	if ($itm_m > 1) {

	print "You have $itm_m $fld Missing or Incomplete. Please check the cues on this page ";
	print "for fields that have missing or incomplete information. ";

	if ($MissingInfoFields{'Ecom_BillTo_Online_Email'} eq "Incomplete" || $MissingInfoFields{'Ecom_ReceiptTo_Online_Email'} eq "Incomplete") {
	print "<font color=red>Check eMail for accuracy.";
	}

	print "<p> \n";


	} elsif ($itm_m == 1) {
		
		if (exists($MissingInfoFields{'input_cyber_permission'})) {
		print "Your Final Approval is needed to continue processing this order. \n";
		print "Check <strong>Yes</strong> at the bottom of this form to continue, or abort by ";
		print "leaving this form without checking Yes. \n";

		} else {
		print "You have $itm_m $fld Missing or Incomplete. Please check the prompts on this page for ";
		print "where you have missing or incomplete information. \n";

		if ($MissingInfoFields{'Ecom_BillTo_Online_Email'} eq "Incomplete" || $MissingInfoFields{'Ecom_ReceiptTo_Online_Email'} eq "Incomplete") {
		print "<font color=red>Check eMail for accuracy.";
		}

		print "<p> \n";

		}

	}
	}
	



		# Re POST Hidden to payment file
		# All hidden INPUT occurs after populating form
		
	print "<FORM method=POST action=\"$paymentfile\" name='editform'> \n";



		# Method of Payment
		# Method of Payment

	if ($allow_methods) {

	$itm_n++;
	$box_heading = "What is the Method of Payment ?";
	$box_message = "Please select method of payment and complete any corresponding information.";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$final_heading \n";
	print "<strong>$box_heading</strong>";
	print "</font></td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$final_text \n";
	print "$box_message </font></td></tr>\n";

		# Any CC verify message
		# Any CC verify message
	
	if ($frm{'Ecom_Payment_Card_Number'}) {			

		if ($msg_cc || $cc_type_error) {

		print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";
		print "<tr><td width=5%><br></td> \n";
		print "<td width=95%>$final_text \n";

			print "$msg_cc " if ($msg_cc);

			if ($cc_type_error) {
			print "Check the Card Type selected for accuracy. ";
			print "The card number is a $cc_type_error number. ";
			}

		print "</font></td></tr> \n";
		}

	}

	print "<tr><td colspan=2><font size=1><br></font></td></tr></table> \n";



		# Set up Payment Methods 
		# Set up Payment Methods 

	if (scalar(keys(%payment_options_list)) == 1 ) {

		# No drop box - single option forced
		# No drop box - single option forced

		while (($key, $val) = each (%payment_options_list)) {
			$single_option = $key;	
			}


	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td><td> \n";

	print "$payment_options_desc{$single_option} ";
	print "<input type=hidden name=\"input_payment_options\" value=\"$single_option\"> \n\n";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";


	} elsif (scalar(keys(%payment_options_list)) > 1 ) {

		# build the drop box
		# build the drop box

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

	print "<table border=0 cellpadding=2 cellspacing=0 bgcolor=$font_outside_line><tr><td> \n";
	print "<table border=0 cellpadding=2 cellspacing=0> \n";

	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Payment Method:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n\n";


		# Populate a Drop Box
		# Populate a Drop Box

	print "<select name=\"input_payment_options\"> \n";

	if ($frm{'input_payment_options'}) {

		print "<option value=\"\">Please Select Here \n";
		print "<option value=\"\"> ------------------------------ \n";

			foreach $_ (@payment_options_order) {

				if ($_ eq $frm{'input_payment_options'}) {
				print "<option selected value=\"$_\">$payment_options_list{$_} \n";

				} else {
				print "<option value=\"$_\">$payment_options_list{$_} \n" if ($payment_options_list{$_});
				}

			}

	} else {

		print "<option selected value=\"\">Please Select Here \n";
		print "<option value=\"\"> ------------------------------ \n";

		foreach $_ (@payment_options_order) {

		print "<option value=\"$_\">$payment_options_list{$_} \n" if ($payment_options_list{$_});

		}


	}

	print "</select></td> \n\n";

	$msg_v = (&ValidateInputOptions('input_payment_options'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";

	print "</table>";
	print "</td></tr></table> \n";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";

	} 

	# End Payment Options Branch
	# End Payment Options Branch



		# Enable Credit Card Payment
		# Enable Credit Card Payment

	if (scalar(keys(%credit_card_fields))) {

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

	print "<table border=0 cellpadding=2 cellspacing=0 bgcolor=$font_outside_line><tr><td> \n";
	print "<table border=0 cellpadding=2 cellspacing=0> \n";

	if (exists ($credit_card_fields{'Ecom_Payment_Card_Name'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Name on Card:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($check_check) {$new_value = ""}	else {$new_value = $frm{'Ecom_Payment_Card_Name'}}
	print "<input name=\"Ecom_Payment_Card_Name\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_Name'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($credit_card_fields{'Ecom_Payment_Card_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Card Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	if ($check_check) {$new_value = ""}	else {$new_value = $frm{'Ecom_Payment_Card_Number'}}
	print "<input name=\"Ecom_Payment_Card_Number\" value=\"$new_value\" size=19></td>";

	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}
	
	if (exists ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Month'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Expiration Month:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

	if ($check_check) {$new_value = ""}	else {$new_value = $frm{'Ecom_Payment_Card_ExpDate_Month'}}
	print "<select name=\"Ecom_Payment_Card_ExpDate_Month\"> \n";

		if ($new_value == 0) {print "<option selected value=\"\">Select A Month \n";
		} else {print "<option value=\"\">Select A Month \n";}

		print "<option value=\"\"> ------------------- \n";
			
		if ($new_value == 1) {print "<option selected value =\"1\">January \n";
		} else {print "<option value =\"1\">January \n";}

		if ($new_value == 2) {print "<option selected value =\"2\">February \n";
		} else {print "<option value =\"2\">February \n";}

		if ($new_value == 3) {print "<option selected value =\"3\">March \n";
		} else {print "<option value =\"3\">March \n";}

		if ($new_value == 4) {print "<option selected value =\"4\">April \n";
		} else {print "<option value =\"4\">April \n";}

		if ($new_value == 5) {print "<option selected value =\"5\">May \n";
		} else {print "<option value =\"5\">May \n";}

		if ($new_value == 6) {print "<option selected value =\"6\">June \n";
		} else {print "<option value =\"6\">June \n";}

		if ($new_value == 7) {print "<option selected value =\"7\">July \n";
		} else {print "<option value =\"7\">July \n";}

		if ($new_value == 8) {print "<option selected value =\"8\">August \n";
		} else {print "<option value =\"8\">August \n";}

		if ($new_value == 9) {print "<option selected value =\"9\">September \n";
		} else {print "<option value =\"9\">September \n";}

		if ($new_value == 10) {print "<option selected value =\"10\">October \n";
		} else {print "<option value =\"10\">October \n";}

		if ($new_value == 11) {print "<option selected value =\"11\">November \n";
		} else {print "<option value =\"11\">November \n";}

		if ($new_value == 12) {print "<option selected value =\"12\">December \n";
		} else {print "<option value =\"12\">December \n";}

	print "</select></td> \n\n";
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_ExpDate_Month'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Day'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Expiration Day:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

	if ($check_check) {$new_value = ""}	else {$new_value = $frm{'Ecom_Payment_Card_ExpDate_Day'}}
	print "<select name=\"Ecom_Payment_Card_ExpDate_Day\"> \n";

		$count_day = 1;

		if ($new_value == 0) {
		print "<option selected value=\"\">Select A Day \n";
		} else {
		print "<option value=\"\">Select A Day \n";
		}

		print "<option value=\"\"> ------------------- \n";

			while ($count_day < 32) {

				if ($new_value == $count_day) {
				print "<option selected value=\"$count_day\">$count_day \n";
	
				} else {
				print "<option value=\"$count_day\">$count_day \n";
				}

				$count_day++;

			}

	print "</select></td> \n\n";
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_ExpDate_Day'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Year'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Expiration Year:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

	if ($check_check) {$new_value = ""}	else {$new_value = $frm{'Ecom_Payment_Card_ExpDate_Year'}}

		$count_year = $pass_year;
		$stop_year = ($count_year + 21);

	print "<select name=\"Ecom_Payment_Card_ExpDate_Year\"> \n";

		if ($new_value == 0) {
		print "<option selected value=\"\">Select A Year \n";
		} else {
		print "<option value=\"\">Select A Year \n";
		}

		print "<option value=\"\"> ------------------- \n";

			while ($count_year < $stop_year) {

				if ($new_value == $count_year) {
				print "<option selected value=\"$count_year\">$count_year \n";
	
				} else {
				print "<option value=\"$count_year\">$count_year \n";
				}

				$count_year++;

			}

	print "</select></td> \n\n";
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_ExpDate_Year'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($credit_card_fields{'Ecom_Payment_Card_Verification'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Card Verification:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($check_check) {$new_value = ""}	else {$new_value = $frm{'Ecom_Payment_Card_Verification'}}
	print "<input name=\"Ecom_Payment_Card_Verification\" value=\"$new_value\" size=19></td>";

	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_Verification'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	print "</table>";
	print "</td></tr></table> \n";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";

	} 
	
	# End Enable Credit Card
	# End Enable Credit Card



		# Enable Checking Account Payment
		# Enable Checking Account Payment

	if (scalar(keys(%checking_account_fields))) {


	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

	print "<table border=0 cellpadding=2 cellspacing=0 bgcolor=$font_outside_line><tr><td> \n";
	print "<table border=0 cellpadding=2 cellspacing=0> \n";

	if (exists ($checking_account_fields{'Check_Holder_Name'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Name on Account:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($card_check) {$new_value = ""}	else {$new_value = $frm{'Check_Holder_Name'}}
	print "<input name=\"Check_Holder_Name\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCheckingInfo('Check_Holder_Name'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($checking_account_fields{'Check_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Check Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($card_check) {$new_value = ""}	else {$new_value = $frm{'Check_Number'}}
	print "<input name=\"Check_Number\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCheckingInfo('Check_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($checking_account_fields{'Check_Account_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Account Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($card_check) {$new_value = ""}	else {$new_value = $frm{'Check_Account_Number'}}
	print "<input name=\"Check_Account_Number\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCheckingInfo('Check_Account_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($checking_account_fields{'Check_Routing_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Bank Routing Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($card_check) {$new_value = ""}	else {$new_value = $frm{'Check_Routing_Number'}}
	print "<input name=\"Check_Routing_Number\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCheckingInfo('Check_Routing_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($checking_account_fields{'Check_Fraction_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Fraction Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($card_check) {$new_value = ""}	else {$new_value = $frm{'Check_Fraction_Number'}}
	print "<input name=\"Check_Fraction_Number\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCheckingInfo('Check_Fraction_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($checking_account_fields{'Check_Bank_Name'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Bank Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($card_check) {$new_value = ""}	else {$new_value = $frm{'Check_Bank_Name'}}
	print "<input name=\"Check_Bank_Name\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCheckingInfo('Check_Bank_Name'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($checking_account_fields{'Check_Bank_Address'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Bank Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

	if ($card_check) {$new_value = ""}	else {$new_value = $frm{'Check_Bank_Address'}}
	print "<input name=\"Check_Bank_Address\" value=\"$new_value\" size=30></td>";

	$msg_v = (&ValidateCheckingInfo('Check_Bank_Address'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	print "</table>";
	print "</td></tr></table> \n";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";

	} 
	
	# End Enable Checking Account
	# End Enable Checking Account


	}
 
	# End Method of Payment
	# End Method of Payment




		# Bill to Information
		# Bill to Information

	if (scalar(keys(%billing_info_fields))) {

	$itm_n++;
	$box_heading = "Who Will This Be Billed To ?";
	$box_message = "Please complete this Information ";
	$box_message = $box_message . "as it is on your Credit Card or Checking Account ";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$final_heading \n";
	print "<strong>$box_heading</strong></font>";
	print "</td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$final_text \n";
	print "$box_message </font></td></tr>\n";

	print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";

	if ($frm{'Allow_Shipping'}) {

		print "<tr><td width=5%><br></td> \n";
		print "<td width=95%>$font_final_titles \n";

		if ($frm{'input_shipping_info'} eq "YES") {
		print "<input type=\"checkbox\" name=\"input_shipping_info\" checked=\"on\" value=\"YES\"> ";
		} else {
		print "<input type=\"checkbox\" name=\"input_shipping_info\" value=\"YES\"> ";
		}

		print "<strong>shortcut</strong>: Check here if exactly same as Shipping Address </font></td></tr>\n";
		print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";
	}

	print "</table> \n";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

	print "<table border=0 cellpadding=2 cellspacing=0 bgcolor=$font_outside_line><tr><td> \n";
	print "<table border=0 cellpadding=2 cellspacing=0> \n";

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Name_Prefix'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Title:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Name_Prefix\" value=\"$frm{'Ecom_BillTo_Postal_Name_Prefix'}\" size=4></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Name_Prefix'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Name_First'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles First Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Name_First\" value=\"$frm{'Ecom_BillTo_Postal_Name_First'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Name_First'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Name_Middle'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Middle Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Name_Middle\" value=\"$frm{'Ecom_BillTo_Postal_Name_Middle'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Name_Middle'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Name_Last'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Last Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Name_Last\" value=\"$frm{'Ecom_BillTo_Postal_Name_Last'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Name_Last'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Name_Suffix'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Last Name Suffix:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Name_Suffix\" value=\"$frm{'Ecom_BillTo_Postal_Name_Suffix'}\" size=4></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Name_Suffix'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Company'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Company Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Company\" value=\"$frm{'Ecom_BillTo_Postal_Company'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Company'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Street_Line1'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Street_Line1\" value=\"$frm{'Ecom_BillTo_Postal_Street_Line1'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Street_Line1'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_Street_Line2'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_Street_Line2\" value=\"$frm{'Ecom_BillTo_Postal_Street_Line2'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_Street_Line2'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_City'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles City:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_City\" value=\"$frm{'Ecom_BillTo_Postal_City'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_City'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}


	
	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_StateProv'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_final_titles State - Province:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

		# Does state field use Drop Box
		# Does state field use Drop Box

	if ($use_state_list) {
	print "<select name=\"Ecom_BillTo_Postal_StateProv\" onchange=\"inOhio(this.value)\"> \n";
	foreach $itm_db (@state_list_bill) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print "<input name=\"Ecom_BillTo_Postal_StateProv\" value=\"$frm{'Ecom_BillTo_Postal_StateProv'}\" size=30>";
	}

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_StateProv'));
	print "</td><td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

			if (exists ($billing_info_fields{'Ecom_BillTo_Postal_County'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_final_titles County (Ohio only):</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

		# Does county field use Drop Box
		# Does state field use Drop Box
	if ($use_county_list) {
	print "<select name=\"Ecom_BillTo_Postal_County\" style='visibility:hidden'> \n";
	foreach $itm_db (@county_list_bill) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print "<input name=\"Ecom_BillTo_Postal_County\" value=\"$frm{'Ecom_BillTo_Postal_County'}\" size=30>";
	}

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_County'));
	print "</td><td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	
	
	
	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_PostalCode'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Zip  Code:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Postal_PostalCode\" value=\"$frm{'Ecom_BillTo_Postal_PostalCode'}\" size=30></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_PostalCode'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Postal_CountryCode'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_final_titles Country:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

		# Does country field use Drop Box
		# Does country field use Drop Box

	if ($use_country_list) {
	print "<select name=\"Ecom_BillTo_Postal_CountryCode\"> \n";
	foreach $itm_db (@country_list_bill) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print "<input name=\"Ecom_BillTo_Postal_CountryCode\" value=\"$frm{'Ecom_BillTo_Postal_CountryCode'}\" size=30>";
	}

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Postal_CountryCode'));
	print "</td><td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($billing_info_fields{'Ecom_BillTo_Telecom_Phone_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Phone Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Telecom_Phone_Number\" value=\"$frm{'Ecom_BillTo_Telecom_Phone_Number'}\" size=30></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Telecom_Phone_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}
	
	if (exists ($billing_info_fields{'Ecom_BillTo_Telecom_Fax_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Fax  Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Telecom_Fax_Number\" value=\"$frm{'Ecom_BillTo_Telecom_Fax_Number'}\" size=30></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Telecom_Fax_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}


	if (exists ($billing_info_fields{'Ecom_BillTo_Online_Email'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles E-mail Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_BillTo_Online_Email\" value=\"$frm{'Ecom_BillTo_Online_Email'}\" size=36></td>";

	$msg_v = (&ValidateBillingInfo('Ecom_BillTo_Online_Email'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	print "</table>";
	print "</td></tr></table> \n";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";

	}
 
	# End Bill To Input Tables
	# End Bill To Input Tables




		# Receipt to Information
		# Receipt to Information

	if (scalar(keys(%receipt_info_fields))) {

	$itm_n++;
	$box_heading = "Who To Send Receipt To ?";
	$box_message = "Send receipt here if different than Billing Location.  ";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$final_heading \n";
	print "<strong>$box_heading</strong>";
	print "</font></td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$final_text \n";
	print "$box_message </font></td></tr>\n";
	print "<tr><td colspan=2><font size=1><br></font></td></tr></table> \n";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

	print "<table border=0 cellpadding=2 cellspacing=0 bgcolor=$font_outside_line><tr><td> \n";
	print "<table border=0 cellpadding=2 cellspacing=0> \n";

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Name_Prefix'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Title:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Name_Prefix\" value=\"$frm{'Ecom_ReceiptTo_Postal_Name_Prefix'}\" size=4></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Name_Prefix'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Name_First'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles First Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Name_First\" value=\"$frm{'Ecom_ReceiptTo_Postal_Name_First'}\" size=36></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Name_First'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Name_Middle'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Middle Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Name_Middle\" value=\"$frm{'Ecom_ReceiptTo_Postal_Name_Middle'}\" size=36></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Name_Middle'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Name_Last'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Last Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Name_Last\" value=\"$frm{'Ecom_ReceiptTo_Postal_Name_Last'}\" size=36></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Name_Last'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Name_Suffix'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Last Name Suffix:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Name_Suffix\" value=\"$frm{'Ecom_ReceiptTo_Postal_Name_Suffix'}\" size=4></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Name_Suffix'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Company'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Company Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Company\" value=\"$frm{'Ecom_ReceiptTo_Postal_Company'}\" size=36></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Company'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Street_Line1'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Street_Line1\" value=\"$frm{'Ecom_ReceiptTo_Postal_Street_Line1'}\" size=36></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Street_Line1'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_Street_Line2'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_Street_Line2\" value=\"$frm{'Ecom_ReceiptTo_Postal_Street_Line2'}\" size=36></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_Street_Line2'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_City'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles City:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_City\" value=\"$frm{'Ecom_ReceiptTo_Postal_City'}\" size=30></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_City'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_StateProv'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_final_titles State - Province:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

		# Does state field use Drop Box
		# Does state field use Drop Box

	if ($use_state_list) {
	print "<select name=\"Ecom_ReceiptTo_Postal_StateProv\" onchange='inOhio(this.value)'> \n";
	foreach $itm_db (@state_list_receipt) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print "<input name=\"Ecom_ReceiptTo_Postal_StateProv\" value=\"$frm{'Ecom_ReceiptTo_Postal_StateProv'}\" size=30>";
	}

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_StateProv'));
	print "</td><td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

		if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_County'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_final_titles County(Ohio only):</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

		# Does county field use Drop Box
		# Does field use Drop Box

	if ($use_state_list) {
	print "<select name=\"Ecom_ReceiptTo_Postal_County\" style='visibility:hidden'> \n";
	foreach $itm_db (@county_list_receipt) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print "<input name=\"Ecom_ReceiptTo_Postal_County\" value=\"$frm{'Ecom_ReceiptTo_Postal_County'}\" size=30>";
	}

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_County'));
	print "</td><td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	
	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_PostalCode'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Zip  Code:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Postal_PostalCode\" value=\"$frm{'Ecom_ReceiptTo_Postal_PostalCode'}\" size=30></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_PostalCode'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Postal_CountryCode'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_final_titles Country:</font></td> \n";
	print "<td bgcolor=$font_right_column>$font_final_titles \n";

		# Does country field use Drop Box
		# Does country field use Drop Box

	if ($use_country_list) {
	print "<select name=\"Ecom_ReceiptTo_Postal_CountryCode\"> \n";
	foreach $itm_db (@country_list_receipt) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print "<input name=\"Ecom_ReceiptTo_Postal_CountryCode\" value=\"$frm{'Ecom_ReceiptTo_Postal_CountryCode'}\" size=30>";
	}

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Postal_CountryCode'));
	print "</td><td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Telecom_Phone_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Phone Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Telecom_Phone_Number\" value=\"$frm{'Ecom_ReceiptTo_Telecom_Phone_Number'}\" size=30></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Telecom_Phone_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}
	
	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Telecom_Fax_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles Fax Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Telecom_Fax_Number\" value=\"$frm{'Ecom_ReceiptTo_Fax_Phone_Number'}\" size=30></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Fax_Phone_Number'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}
	
	if (exists ($receipt_info_fields{'Ecom_ReceiptTo_Online_Email'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_final_titles E-mail Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ReceiptTo_Online_Email\" value=\"$frm{'Ecom_ReceiptTo_Online_Email'}\" size=36></td>";

	$msg_v = (&ValidateReceiptInfo('Ecom_ReceiptTo_Online_Email'));
	print "<td bgcolor=$info_message_bg nowrap>$msg_v </td></tr> \n";
	}

	print "</table>";
	print "</td></tr></table> \n";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></td></tr>";
	print "</table> \n";

	}
 
	# End Receipt To Input Tables
	# End Receipt To Input Tables

  # How did you hear about OTDW section
  # How did you hear about OTDW section
	
	$itm_n++;
	$box_heading = "How did you hear about Shelburne Films?";
	$box_message = "";
	
		print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

		print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$final_heading \n";
	print "<strong>$box_heading</strong>";
	print "</font></td></tr> \n";

		print "<tr><td colspan=2><font size=1><br></font></td></tr></table> \n";

		print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
		print "<tr><td width=5%><br></td>  \n";
		print "<td> \n\n";
		print "<input type='checkbox' name='Publication' />Publication (specify): <input type='text' width='35' name='PubValue'><br />";
		 print "<input type='checkbox' name='TVstation' />TV Station &nbsp;(specify): <input type='text' width='35' name='TVvalue'><br />";
		print "<input type='checkbox' name='Friend' />Friend <br />";
		print "<input type='checkbox' name='WebSearch' />Web Search <br />";
		 print "<input type='checkbox' name='Other' />Other (specify): <input type='text' width='35' name='othervalue'>";
		print "</td></tr>";

		print "<tr><td colspan=2><font size=1><br></font></td></tr>";
		print "</table> \n";
	
	
	###End Drop down box
	
	
	
		# Comments Special Instructions
		# Comments Special Instructions

	if ($enable_comments_box) {

	$itm_n++;
	$box_heading = "Any Special Instructions or Comments ?";
	$box_message = "Please enter any Comments or Special Instructions here ";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$final_heading \n";
	print "<strong>$box_heading</strong>";
	print "</font></td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$final_text \n";
	print "$box_message </font></td></tr>\n";

	print "<tr><td colspan=2><font size=1><br></font></td></tr></table> \n";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

	print "<textarea name=\"special_instructions\" rows=\"4\" cols=\"60\" wrap=\"soft\">";
	print "$frm{'special_instructions'}</textarea> \n\n";

	print "</td></tr>";

	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";

	}
 
	# End Comments Input Tables
	# End Comments Input Tables


		# Cyber Permission
		# Cyber Permission

	if ($enable_cyber_permission) {

	$itm_n++;
	$box_heading = "Your Final Authorization is Required ?";
	$box_message = "You must give your final approval by checking Yes for Final Processing ";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$final_heading \n";
	print "<strong>$box_heading</strong>";
	print "</font></td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$final_text \n";
	print "$box_message </font></td></tr>\n";

	print "<tr><td colspan=2><font size=1><br></font></td></tr></table> \n";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

   	print "<table border=0 width=100%><tr>";
   	print "<td bgcolor=green align=center width=5%>";
   	print "<input type=radio name=\"input_cyber_permission\" value=\"APPROVED\"></td>";
   	print "<td bgcolor=#D5FED1>$final_text ";
	print "<strong> YES</strong>, I authorize my account to be billed ";
   	print "<strong>$currency $submit_total</strong>.";
	print "</font></td></tr></table>";

   	print "<table border=0 width=100%><tr>";
   	print "<td bgcolor=red align=center width=5%>";
   	print "<input type=radio name=\"input_cyber_permission\" value=\"\" checked=\"on\"></td>";
   	print "<td bgcolor=#FFCCCC>$final_text ";
   	print "<strong> NO</strong>, I do not authorize my account to be billed. \n";
	print "</font></td></tr></table>";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";

	}
 
	# End Cyber Permission Input Tables
	# End Cyber Permission Input Tables


		# Submit Payment Information Menu
		# Submit Payment Information Menu

	print "<table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_home_bottom) {
	print "<td valign=top nowrap><a href=\"$menu_home_bottom_url\">$menu_home_bottom</a></td> \n"}

	if ($menu_previous_bottom) {
	print "<td valign=top nowrap><a href=\"$frm{'previouspage'}\">$menu_previous_bottom</a></td> \n"}

	if ($menu_editcart_bottom) {
	print "<td valign=top nowrap>";
	print "<a href=\"$programfile?viewcart&previouspage=$frm{'previouspage'}\"> ";
	print "$menu_editcart_bottom</a></td> \n";
	}


		# Submit-Resubmit all Preview Data as hidden
		# Submit-Resubmit all Preview Data as hidden

	print "<input type=hidden name=\"resubmit_info\" value=\"RESUBMIT\"> \n\n";

		# Adjust %frm to prevent resubmit conflict in hidden POST
		# Adjust %frm to prevent resubmit conflict in hidden POST
		# All Input Fields used in this form must be prevented from hidden POST
		# The only field on this form allowed as hidden post is the 'resubmit_info' 
		# which is hidden to begin with

	 	while (($key, $val) = each (%billing_info_fields)) { 
		delete ($frm{$key});
		}

	 	while (($key, $val) = each (%receipt_info_fields)) { 
		delete ($frm{$key});
		}

	 	while (($key, $val) = each (%credit_card_fields)) { 
		delete ($frm{$key});
		}

	 	while (($key, $val) = each (%checking_account_fields)) { 
		delete ($frm{$key});
		}

		delete ($frm{'input_payment_options'});
		delete ($frm{'Ecom_Payment_Card_Type'});
		delete ($frm{'input_shipping_info'});
		delete ($frm{'special_instructions'});
		delete ($frm{'input_cyber_permission'});


		# Print adjusted frm Data and new POST data
		# Print adjusted frm Data and new POST data
		
	 while (($key, $val) = each (%frm)) { 
	 print "<input type=hidden name=\"$key\" value=\"$val\"> \n";
	 }

		# orders printing must come after above frm print

	foreach $line (@orders) {
	print "<input type=hidden name=\"order\" value=\"$line\"> \n";
	}

	print "\n\n";

	# Submit Payment FORM ends here
	print "<td valign=top>$menu_payment_bottom </FORM></td> \n";

	if ($menu_help_bottom) {
	print "<td valign=top> \n";
	print "<a href=\"$menu_help_bottom_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_bottom_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_bottom</a></td> \n";}

	print "</tr></table>";


	# DEBUG PAYMENT INFO PAGE
	# DEBUG PAYMENT INFO PAGE
	# print "<br><hr><u><strong>All Global Vars</strong></u>";
	# print "<li>resubmit_info = $frm{'resubmit_info'}";
	# print "<li>FRM-OrderID = $frm{'OrderID'}";
	# print "<li>FRM-InfoID = $frm{'InfoID'}";
	# print "<li>previouspage = $frm{'previouspage'}";
	# print "<hr><u><strong>\%MissingInfoFields</strong></u>";
	# print "<ol>";
	# while (($key, $val) = each (%MissingInfoFields)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "</ol>";
	# print "<hr><strong><u>\@UsingInfoFields</u></strong>";
	# print "<ol>";
	# foreach $_ (@UsingInfoFields) {print "<li>$_"}
	# print "</ol>";
	# print "<hr><strong><u>All POST Input From Preview Data or Resubmit</u></strong><br>";
	# print "<font size=2>This must hold at 59 fields from Preview, and 60 if Payment resubmit<br>";
	# print "These are hidden POST, and must not include any fields on this form </font>";
	# print "<ol>";
	# while (($key, $val) = each (%frm)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "</ol>";
	# print "<hr><strong><u>orders Array</u></strong> \n";
	# foreach $_ (@orders) {print "<li>$_ \n";}




	print "$returntofont\n";
	print "@footer \n\n";

   }








	# PAYMENT ACCEPTED 
	# PAYMENT ACCEPTED 

sub PaymentAccepted {

	my (@list) = ();
	
	my ($key, $val);
	my ($nav_top, $nav_bottom) = (0,0);
	my ($li, $lk, $lv, $msg_status, $paypal_str);
	my ($totalprice, $totalqnty, $temprice);
	my ($line, $qty, $item, $desc, $price, $ship, $taxit);

	my ($DiscountOne);
	my ($DiscountTwo);
	my ($CombinedDiscount);
	my ($SubDiscount);
	my ($TaxRate);
	my ($AdjustedTax);
	my ($Tax);
	my ($HandlingCharge);
	my ($InsuranceCharge);
	my ($ShippingCharge);
	my ($FinalProducts) = CommifyNumbers ($frm{'Primary_Products'});
	my ($FinalAmount) = CommifyMoney ($frm{'Final_Amount'});

	my ($msg_tab);
	my ($msg_tab_ck);
	my ($check_additional);
	my ($mail_msg, $save_msg, $save_url, $ship_msg, $bill_msg, $receipt_msg);

	$msg_status = "$FinalProducts Products " if ($frm{'Primary_Products'} > 1);
	$msg_status = "$FinalProducts Product " if ($frm{'Primary_Products'} == 1);
	$msg_status = $msg_status . " $currency $FinalAmount";

	print "Content-Type: text/html\n\n";
	print "@header \n\n";


		# top message
		# top message

	$_ = $frm{'input_payment_options'};	

	if ($_ eq "MAIL") {
	print "Payment: ";
	print "$payment_options_list{$_} ";
	print "for Amount ";
	print "$currency $FinalAmount.<br> ";
	print "Please print this invoice, complete any Payment Information ";
	print "below, and Mail or Fax. \n";


	} elsif ($_ eq "PAYPAL") {

	$paypal_login =~ s/\@/%40/g;
	$paypal_merchant =~ s/ /+/g;

	if ($use_web_copy_as_return_url) {

		$paypal_return_url = $save_invoice_url . $frm{'OrderID'} . ".html";
		$paypal_return_url =~ s/:/%3A/g;

		} else {
		$paypal_return_url =~ s/:/%3A/g;

		}

	$paypal_str = "<A HREF=\"$paypal_url";
	$paypal_str = $paypal_str . "business=$paypal_login";
	$paypal_str = $paypal_str . "&item_name=$paypal_merchant";
	$paypal_str = $paypal_str . "+Order+$InvoiceNumber+On+$ShortDate";
	$paypal_str = $paypal_str . "&item_number=Invoice+$InvoiceNumber+$ShortDate";
	$paypal_str = $paypal_str . "&amount=$frm{'Final_Amount'}";
	$paypal_str = $paypal_str . "&return=$paypal_return_url";
	$paypal_str = $paypal_str . "\">";

	print "<table border=0 cellpadding=1 cellspacing=0 width 90%><tr> ";
	print "<td valign=top>$paypal_str$paypal_button</a><td>";
	print "<td valign=top> ";
	print "$payment_options_list{$_} ";
	print "submitting ";
	print "$currency $FinalAmount.<br> ";
	print "Print this invoice, and click ";
	print "$paypal_str\n";
	print "PayPal </a>";
	print "to complete.\n";
	print "</td></tr></table> ";


	} else {

		if ($check_check) {
		print "Payment: ";
		print "$payment_options_list{$_} ";
		print ", $frm{'Check_Bank_Name'}, " if ($frm{'Check_Bank_Name'}) ;
		print "for $currency $FinalAmount. <br> ";
		print "Please print this Final Invoice for your records. \n";

		} elsif ($card_check) {
		print "Payment: ";
		print "$payment_options_list{$_} ";
		print "for $currency $FinalAmount. <br> ";
		print "Please print this Final Invoice for your records. \n";
		}

	}

	print "<p> ";



		# Insert MOF navigation at TOP
		# Insert MOF navigation at TOP

	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_help_top);

	if ($nav_top) {
	print "<table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_previous_top) {
	print "<td nowrap><a href=\"$frm{'previouspage'}\">$menu_previous_top</a></td> \n";}

	if ($menu_help_top) {
	print "<td nowrap> \n";
	print "<a href=\"$menu_help_top_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_top_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_top</a></td> \n";}

	print "</tr></table>\n\n";
	}


		# Order ID - Date - Invoice Num
		# Order ID - Date - Invoice Num

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td valign=bottom nowrap>$font_invoice_num_s \n";
	print "Invoice: $InvoiceNumber $font_invoice_num_e </td><td align=right>";

	print "<table border=0 cellpadding=0 cellspacing=0> \n";
	print "<tr><td align=right nowrap>$datetime_s Order ID: $frm{'OrderID'} $datetime_e </td></tr> \n";
	print "<tr><td align=right nowrap>$datetime_s $Date $ShortTime $datetime_e </td></tr></table> \n";
	
	print "</td></tr></table> \n";


		# Top information
		# Top information

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=50% $ship_to_bg_final> \n";

		# Display shipping info, etc.
		# Display shipping info, etc.

	print "<table border=0 cellpadding=6 cellspacing=0 width=100% height=100%> ";
	print "<tr><td valign=top> \n";


	if ($frm{'Allow_Shipping'}) {
	$msg_tab = "<font size=1 color=black>SHIP TO: </font><br>" ;	

	} elsif ($frm{'Allow_Tax'}) {
	$msg_tab = "<font size=1 color=black>TAX AREA: </font><br>"
	
	} else {
	$msg_tab = "<font size=1 color=black>ORDER INFORMATION: </font><br>" ;	
	$msg_tab = $msg_tab . "$action_message_s $msg_status $action_message_e\n"
	}

	print "$msg_tab \n";
	print "$action_message_s \n";
	$msg_tab_ck = 0;

	if ($frm{'Ecom_ShipTo_Postal_Name_Prefix'}) {
	print "$frm{'Ecom_ShipTo_Postal_Name_Prefix'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_First'}) {
	print "$frm{'Ecom_ShipTo_Postal_Name_First'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_Middle'}) {
	print "$frm{'Ecom_ShipTo_Postal_Name_Middle'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_Last'}) {
	print "$frm{'Ecom_ShipTo_Postal_Name_Last'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_Suffix'}) {
	print "$frm{'Ecom_ShipTo_Postal_Name_Suffix'} \n";
	$msg_tab_ck++;}

	print "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($frm{'Ecom_ShipTo_Postal_Company'}) {
	print "$frm{'Ecom_ShipTo_Postal_Company'} <br>\n";
	}

	if ($frm{'Ecom_ShipTo_Postal_Street_Line1'}) {
	print "$frm{'Ecom_ShipTo_Postal_Street_Line1'} <br>\n";
	}

	if ($frm{'Ecom_ShipTo_Postal_Street_Line2'}) {
	print "$frm{'Ecom_ShipTo_Postal_Street_Line2'} <br>\n";
	}

	if ($frm{'Ecom_ShipTo_Postal_City'}) {
	print "$frm{'Ecom_ShipTo_Postal_City'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_StateProv'}) {
	unless ($frm{'Ecom_ShipTo_Postal_StateProv'} eq "NOTINLIST") {
	print "$frm{'Ecom_ShipTo_Postal_StateProv'} \n";
	$msg_tab_ck++;}
	}
	
	if ($frm{'Ecom_ShipTo_Postal_County'}) {
	unless ($frm{'Ecom_ShipTo_Postal_County'} eq "NOTINLIST") {
	print "$frm{'Ecom_ShipTo_Postal_County'} \n";
	$msg_tab_ck++;}
	}
	
	if ($frm{'Ecom_ShipTo_Postal_PostalCode'}) {
	print "$frm{'Ecom_ShipTo_Postal_PostalCode'} \n";
	$msg_tab_ck++;}
	
	print "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($frm{'Ecom_ShipTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_ShipTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	print "$tc \n";
	}

	print "$action_message_e </td></tr></table> \n";
	print "</td><td width=50% $bill_to_bg_final> \n";


		# Display Bill To info, etc.
		# Display Bill To info, etc.

	print "<table border=0 cellpadding=6 cellspacing=0 width=100% height=100%> ";
	print "<tr><td valign=top> \n";

	print "<font size=1 color=black>BILL TO: </font><br>" ;

	$msg_tab_ck = 0;
	print "$action_message_s \n";

	if ($frm{'Ecom_BillTo_Postal_Name_Prefix'}) {
	print "$frm{'Ecom_BillTo_Postal_Name_Prefix'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_First'}) {
	print "$frm{'Ecom_BillTo_Postal_Name_First'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_Middle'}) {
	print "$frm{'Ecom_BillTo_Postal_Name_Middle'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_Last'}) {
	print "$frm{'Ecom_BillTo_Postal_Name_Last'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_Suffix'}) {
	print "$frm{'Ecom_BillTo_Postal_Name_Suffix'} \n";
	$msg_tab_ck++;}

	print "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_BillTo_Postal_Company'}) {
	print "$frm{'Ecom_BillTo_Postal_Company'} <br>\n";
	}

	if ($frm{'Ecom_BillTo_Postal_Street_Line1'}) {
	print "$frm{'Ecom_BillTo_Postal_Street_Line1'} <br>\n";
	}

	if ($frm{'Ecom_BillTo_Postal_Street_Line2'}) {
	print "$frm{'Ecom_BillTo_Postal_Street_Line2'} <br>\n";
	}

	if ($frm{'Ecom_BillTo_Postal_City'}) {
	print "$frm{'Ecom_BillTo_Postal_City'} \n";
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_StateProv'}) {
 	unless ($frm{'Ecom_BillTo_Postal_StateProv'} eq "NOTINLIST") {
	print "$frm{'Ecom_BillTo_Postal_StateProv'} \n";
	$msg_tab_ck++;}
	}
	if ($frm{'Ecom_BillTo_Postal_County'}) {
 	unless ($frm{'Ecom_BillTo_Postal_County'} eq "NOTINLIST") {
	print "$frm{'Ecom_BillTo_Postal_County'} \n";
	$msg_tab_ck++;}
	}

	if ($frm{'Ecom_BillTo_Postal_PostalCode'}) {
	print "$frm{'Ecom_BillTo_Postal_PostalCode'} \n";
	$msg_tab_ck++;}
	
	print "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($frm{'Ecom_BillTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_BillTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	print "$tc \n";
	}
	
	print "$action_message_e </td></tr></table> \n";
	print "</td></tr></table> \n";


		# printing orders in cart
		# printing orders in cart

	print "<table $tableborder_color cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr bgcolor=$tableheading> \n";
	print "<td align=center>$fontheading <strong>Qty</strong></font></td> \n";
	print "<td align=center nowrap>$fontheading <strong>Item Name</strong></font></td> \n";
	print "<td align=center>$fontheading <strong>Description</strong></font></td> \n";
	print "<td align=center>$fontheading <strong>Price</strong></font></td></tr> \n";

		# populate orders in table / store hidden input
		# populate orders in table / store hidden input

	foreach $line (@orders) {
  	($qty, $item, $desc, $price, $ship, $taxit) = split (/$delimit/, $line);

   	print "<tr bgcolor=$tableitem> \n";
	print "<td><center> $fontqnty $qty </center></font></td> \n";

	if ($frm{'Tax_Amount'} > 0 && $identify_tax_items && $taxit) {
	print "<td>$fontitem $item </font> $identify_tax_items </td> \n";
	} else {
	print "<td>$fontitem $item </font></td> \n";
	}



		# Format User Input in Description
		# Format User Input in Description

	@list = split (/\|/, $desc);

	$desc = shift (@list);
 	$desc =~ s/\[/</g;
	$desc =~ s/\]/>/g;
	$desc = $fontdesc_s . $desc . $fontdesc_e;

		foreach $li (@list) {
		($lk, $lv) = split (/::/, $li);

			if ($makelist) {
			$desc = $desc . "$font_key_s<li>$lk: $font_key_e$font_val_s$lv$font_val_e";
			} else {
			$desc = $desc . " - $font_key_s$lk: $font_key_e$font_val_s$lv$font_val_e";
			}

		}
		
	print "<td>$desc </td> \n";


			# Print row for single item or multiple to sub totals
			# Print row for single item or multiple to sub totals

	if ($qty > 1) {
	print "<td align=right>$fontprice \&nbsp\; </td></tr>\n";

		$sub_price = ($qty * $price);
		$totalprice += $sub_price;
		$totalqnty += $qty;
      	$sub_price = sprintf "%.2f", $sub_price;
      	$sub_price = CommifyMoney ($sub_price);
		$price = CommifyMoney ($price);
		$qty = CommifyNumbers ($qty);

   		print "<tr bgcolor=$tablesub><td> \&nbsp\; </td>\n";
		print "<td colspan=2>$fontsubtext\n"; 
		print "Sub Total $qty of $item at ";
		print "$currency $price each </font></td>\n";
		print "<td align=right nowrap>$fontsub $currency $sub_price </font></td></tr>\n\n";

	} else {

		$totalprice += $price;
		$totalqnty += $qty;
		$price = CommifyMoney ($price);		
		print "<td valign=bottom align=right nowrap>$fontprice$currency $price </font></td></tr>\n\n";

	}

	}

   	print "</table> \n";
	print "$returntofont \n";


		# Display Summary Totals
		# Display Summary Totals

	if ($totalqnty > 1) {$pd = "Products"} else {$pd = "Product"}

	$totalprice = sprintf "%.2f", $totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext Subtotal <strong> \n";
	print "$totalqnty </strong> $pd ----> </font></td> \n";
	print "<td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $totalprice </font></td></tr></table> \n";


		# Totals from %frm Formerly %Computations -------------->
		# Totals from %frm Formerly %Computations -------------->
		# CommifyMoney here, keep computations free of formatting


		# Display First Discount
		# Display First Discount

	if ($frm{'Primary_Discount'} > 0) {
	$DiscountOne = CommifyMoney ($frm{'Primary_Discount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "Discount $frm{'Primary_Discount_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> - ";
	print "$totalcolor $currency $DiscountOne </font></td></tr></table> \n";
	}


		# Display Coupon Discount
		# Display Coupon Discount
		
	if ($frm{'Coupon_Discount'} > 0) {
	$DiscountTwo = CommifyMoney ($frm{'Coupon_Discount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "Discount $frm{'Coupon_Discount_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> - ";
	print "$totalcolor $currency $DiscountTwo </font></td></tr></table> \n";
	}


		# Display Subtotal if discounts
		# Display Subtotal if discounts

	if ($frm{'Combined_Discount'} > 0 ) {
	$SubDiscount = CommifyMoney ($frm{'Sub_Final_Discount'});
	$CombinedDiscount = CommifyMoney ($frm{'Combined_Discount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "Sub Total After $currency $CombinedDiscount Total Discount ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency <strong>$SubDiscount </strong></font></td></tr></table> \n";
	}


		# Tax Before
		# Tax Before

	if ($frm{'Tax_Amount'} > 0 && $frm{'Tax_Rule'} eq "BEFORE") {
	$TaxRate = ($frm{'Tax_Rate'} * 100);
	$AdjustedTax = CommifyMoney ($frm{'Adjusted_Tax_Amount_Before'});
	$Tax = CommifyMoney ($frm{'Tax_Amount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "Sales tax $TaxRate\% \(on $currency $AdjustedTax taxable\) ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $Tax </font></td></tr></table> \n";
	}


		# Handling Charges
		# Handling Charges

	if ($frm{'Handling'} > 0) {
	$HandlingCharges = CommifyMoney ($frm{'Handling'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "Handling $frm{'Handling_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $HandlingCharges </font></td></tr></table> \n";
	}


		# Insurance Charges
		# Insurance Charges

	if ($frm{'Insurance'} > 0) {
	$InsuranceCharges = CommifyMoney ($frm{'Insurance'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "Insurance $frm{'Insurance_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $InsuranceCharges </font></td></tr></table> \n";
	}


		# Shipping Charges
		# Shipping Charges


	if ($frm{'Shipping_Amount'} > 0 ) {
	$ShippingCharges = CommifyMoney ($frm{'Shipping_Amount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "$frm{'Shipping_Message'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $ShippingCharges </font></td></tr></table> \n";
	}


		# Tax After
		# Tax After

	if ($frm{'Tax_Amount'} > 0 && $frm{'Tax_Rule'} eq "AFTER") {
	$TaxRate = ($frm{'Tax_Rate'} * 100);
	$AdjustedTax = CommifyMoney ($frm{'Adjusted_Tax_Amount_After'});
	$Tax = CommifyMoney ($frm{'Tax_Amount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "Sales tax $TaxRate\% \(on $currency $AdjustedTax taxable\) ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $Tax </font></td></tr></table> \n";
	}


		# Final Total
		# Final Total

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext \n";
	print "<strong>Total Order Amount</strong> ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency <strong> $FinalAmount </strong></font></td></tr></table> \n";



		# Set up additional information
		# Set up additional information

	if ($mail_customer_receipt) {

		# Order: ReceiptTo, BillTo, ShipTo
		if ($frm{'Ecom_ReceiptTo_Online_Email'}) {
		$mail_msg = "An email notice has been mailed to ";		
		$mail_msg = $mail_msg . $frm{'Ecom_ReceiptTo_Online_Email'};

		} elsif ($frm{'Ecom_BillTo_Online_Email'}) {
		$mail_msg = "An email notice has been mailed to ";		
		$mail_msg = $mail_msg . $frm{'Ecom_BillTo_Online_Email'};

		} elsif ($frm{'Ecom_ShipTo_Online_Email'}) {
		$mail_msg = "An email notice has been mailed to ";		
		$mail_msg = $mail_msg . $frm{'Ecom_ShipTo_Online_Email'};

		} else {
		$mail_msg = "An email receipt was not mailed because no customer email address was entered.";
		}

	}
		

	if ($save_invoice_html) {
	$save_url = $save_invoice_url . $frm{'OrderID'} . ".html";
	$save_msg = "Invoice ";
	$save_msg = $save_msg . "<a href=\"$save_url\">$save_url</a>";	
	}


	$ship_msg = "Phone $frm{'Ecom_ShipTo_Telecom_Phone_Number'} " if ($frm{'Ecom_ShipTo_Telecom_Phone_Number'});

	$ship_msg = $ship_msg . "Fax $frm{'Ecom_ShipTo_Telecom_Fax_Number'} " if ($frm{'Ecom_ShipTo_Telecom_Fax_Number'});

	$ship_msg = $ship_msg . "Email $frm{'Ecom_ShipTo_Online_Email'} " if ($frm{'Ecom_ShipTo_Online_Email'});

	$bill_msg = "Phone $frm{'Ecom_BillTo_Telecom_Phone_Number'} " if  ($frm{'Ecom_BillTo_Telecom_Phone_Number'});
	$bill_msg = $bill_msg . "Fax $frm{'Ecom_BillTo_Telecom_Fax_Number'} " if  ($frm{'Ecom_BillTo_Telecom_Fax_Number'});
	$bill_msg = $bill_msg . "Email $frm{'Ecom_BillTo_Online_Email'} " if  ($frm{'Ecom_BillTo_Online_Email'});


	$receipt_msg = "$frm{'Ecom_ReceiptTo_Postal_Name_Prefix'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Prefix'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_First'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_First'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_Middle'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Middle'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_Last'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Last'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_Suffix'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Suffix'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Company'} " if ($frm{'Ecom_ReceiptTo_Postal_Company'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Street_Line1'} " if ($frm{'Ecom_ReceiptTo_Postal_Street_Line1'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Street_Line2'} " if ($frm{'Ecom_ReceiptTo_Postal_Street_Line2'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_City'} " if ($frm{'Ecom_ReceiptTo_Postal_City'});

	if ($frm{'Ecom_ReceiptTo_Postal_StateProv'}) {
	unless ($frm{'Ecom_ReceiptTo_Postal_StateProv'} eq "NOTINLIST") {
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_StateProv'} ";
	}
	}

	if ($frm{'Ecom_ReceiptTo_Postal_County'}) {
	unless ($frm{'Ecom_ReceiptTo_Postal_County'} eq "NOTINLIST") {
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_County'} ";
	}
	}
	
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_PostalCode'} " if ($frm{'Ecom_ReceiptTo_Postal_PostalCode'});

	if ($frm{'Ecom_ReceiptTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_ReceiptTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	$receipt_msg = $receipt_msg . "$tc ";
	}

	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Telecom_Phone_Number'} " if ($frm{'Ecom_ReceiptTo_Telecom_Phone_Number'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Online_Email'} " if ($frm{'Ecom_ReceiptTo_Online_Email'});

	$check_additional++ if ($mail_msg);
	$check_additional++ if ($save_msg);
	$check_additional++ if ($ship_msg);
	$check_additional++ if ($bill_msg);
	$check_additional++ if ($receipt_msg);

	if ($check_additional) {

	print "<p><table border=0 cellpadding=2 cellspacing=0 width=90%> \n";
	print "<tr><td>$font_comments \n";
	print "<strong>Additional Information:</strong> \n";
	print "</font></td></tr> \n";
	print "<tr><td>$font_comments \n";
	print "$mail_msg <br>" if ($mail_msg);
	print "$save_msg <br>" if ($save_msg);
	print "Ship To: $ship_msg <br>" if ($ship_msg);
	print "Bill To: $bill_msg <br>" if ($bill_msg);
	print "Receipt To: $receipt_msg <br>" if ($receipt_msg);
	print "</font></td></tr></table> \n";
	}


		# Set up Mailing or Faxing payment info
		# Set up Mailing or Faxing payment info


	if ($frm{'input_payment_options'} eq "MAIL") {
	$line_str = "__________________________________";

	if ($allow_lines_credit || $allow_lines_check) {

	print "<p><table border=0 cellpadding=2 cellspacing=0 width=90%> \n";

	print "<tr><td colspan=2>$font_mailfax_form \n";
	print "<strong>Complete any Payment Information for Mailing or Faxing:</strong> \n";
	print "</font></td></tr> \n";


		# CC info
		# CC info

	if ($allow_lines_credit) {

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Credit Card Holder's Name </font></td> \n";
	if ($frm{'Ecom_Payment_Card_Name'}) {
		print "<td>___$frm{'Ecom_Payment_Card_Name'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Credit Card Number </font></td> \n";
	if ($frm{'Ecom_Payment_Card_Number'}) {
		print "<td>___$frm{'Ecom_Payment_Card_Number'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";


	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Credit Card Expiration Date </font></td> \n";


		$exp_date = $frm{'Ecom_Payment_Card_ExpDate_Month'};

		if ($frm{'Ecom_Payment_Card_ExpDate_Month'}) {
			$exp_date = $exp_date . "-" if ($frm{'Ecom_Payment_Card_ExpDate_Day'});
			}

		$exp_date = $exp_date . $frm{'Ecom_Payment_Card_ExpDate_Day'};

		if ($frm{'Ecom_Payment_Card_ExpDate_Month'} || $frm{'Ecom_Payment_Card_ExpDate_Day'}) {
			$exp_date = $exp_date . "-" if ($frm{'Ecom_Payment_Card_ExpDate_Year'});
			}

		$exp_date = $exp_date . $frm{'Ecom_Payment_Card_ExpDate_Year'};


	if ($exp_date) {
		print "<td>___$exp_date </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	}



		# Check info
		# Check info

	if ($allow_lines_check) {

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Name on Checking Account </font></td> \n";
	if ($frm{'Check_Holder_Name'}) {
		print "<td>___$frm{'Check_Holder_Name'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Check Number </font></td> \n";
	if ($frm{'Check_Number'}) {
		print "<td>___$frm{'Check_Number'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Checking Account Number </font></td> \n";
	if ($frm{'Check_Account_Number'}) {
		print "<td>___$frm{'Check_Account_Number'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Bank Routing Number </font></td> \n";
	if ($frm{'Check_Routing_Number'}) {
		print "<td>___$frm{'Check_Routing_Number'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Fraction Number </font></td> \n";
	if ($frm{'Check_Fraction_Number'}) {
		print "<td>___$frm{'Check_Fraction_Number'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Bank Name </font></td> \n";
	if ($frm{'Check_Bank_Name'}) {
		print "<td>___$frm{'Check_Bank_Name'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	print "<tr><td width=10% align=right nowrap>$font_mailfax_form Bank Address </font></td> \n";
	if ($frm{'Check_Bank_Address'}) {
		print "<td>___$frm{'Check_Bank_Address'} </td> \n";
		} else {
		print "<td>$line_str </td> \n";
		}
		print "</tr> \n";

	}

	print "</table> \n";
	}
	}




		# Special Instructions comments
		# Special Instructions comments

	if ($frm{'special_instructions'}) {
	print "<p><table border=0 cellpadding=2 cellspacing=0 width=90%> \n";
	print "<tr><td>$font_comments \n";
	print "<strong>Special Instructions or Comments:</strong> \n";
	print "</font></td></tr> \n";
	print "<tr><td>$font_comments \n";
	print "$frm{'special_instructions'} \n";
	print "</font></td></tr></table> \n";
	}




		# Bottom Navigation Menu
		# Bottom Navigation Menu

	print "<p><table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_home_bottom) {
	print "<td valign=top nowrap><a href=\"$menu_home_bottom_url\">$menu_home_bottom</a></td> \n";}

	if ($menu_previous_bottom) {
	print "<td valign=top nowrap><a href=\"$frm{'previouspage'}\">$menu_previous_bottom</a></td> \n";}

	if ($menu_help_bottom) {
	print "<td valign=top> \n";
	print "<a href=\"$menu_help_bottom_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_bottom_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_bottom</a></td> \n";}

	print "</tr></table><p>";

	# DEBUG FINAL ORDER
	# DEBUG FINAL ORDER
	# print "<strong><u>Library Variables</u></strong> \n";
	# print "<ol>";
 	# print "<li>Date: $Date \n"; 
 	# print "<li>ShortDate: $ShortDate \n";
	# print "<li>Time: $Time \n";
	# print "<li>ShortTime: $ShortTime \n";
	# print "<li>InvoiceNumber: $InvoiceNumber \n";
	# print "</ol>";
	# print "<strong><u>All frm POST Input From Payment Info Form</u></strong><p>";
	# print "<ol>";
	# while (($key, $val) = each (%frm)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "</ol>";
	# print "<strong><u>orders Array</u></strong> \n";
	# print "<ul> ";
	# foreach $_ (@orders) {print "<li>$_ \n";}
	# print "</ul> ";
		
	print "$returntofont\n";
	print "@footer \n\n";

  }


















