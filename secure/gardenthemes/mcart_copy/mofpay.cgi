#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.03.08.04 ====================== #
# === CART BACK END PROGRAM FLOW : CHECKOUT ======================= #
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
require 'mofpay.conf';
require 'mofpaylib.pl';
# cookie names must be the same in both program files
$cookiename_OrderID = 'mof_v25_OrderID';
$cookiename_InfoID = 'mof_v25_InfoID';
# PROGRAM FLOW
# PaymentInformation
# PaymentAccepted
&SetDateVariable;
&RunTestMode if ($ERRORMODE==0 && $ENV{'QUERY_STRING'} =~ /^test/i);
&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
&CustomFieldType;
&ProcessPost;

# RGA : February 20, 2004 6:19:32 PM
# Added resubmit error page
my $path = $datadirectory . $frm{'OrderID'} . "\.$data_extension";
 	unless (-e "$path") {
	print "Location: $ErrMsgResubmit\n\n";
	exit;
	}

if (scalar(keys(%MissingInfoFields))) {
	require $mof_billto_pg;
	@header = ();
	@footer = ();
	@state_list = ();
	@country_list = ();
	# droplist BillTo / ReceiptTo
	@country_list_bill = (&GetDropBoxList($use_country_list,'Ecom_BillTo_Postal_CountryCode')) if ($use_country_list);
	@state_list_bill = (&GetDropBoxList($use_state_list,'Ecom_BillTo_Postal_StateProv')) if ($use_state_list);
	@country_list_receipt = (&GetDropBoxList($use_country_list,'Ecom_ReceiptTo_Postal_CountryCode')) if ($use_country_list);
	@state_list_receipt = (&GetDropBoxList($use_state_list,'Ecom_ReceiptTo_Postal_StateProv')) if ($use_state_list);
	# 05-04-03 : Custom Fields Added
	# GetDropBoxList for any custom fields
	if (scalar(keys(%extraList))) {
	my ($fld,$key,$val);
	while (($key,$val) = each (%extraList)) {@$key = (&GetDropBoxList($val,$key))}
	}
	&GetTemplateFile($payment_info_template,"Payment Information File","payment_info_template"); 
	&PaymentInformation;
} else {
	# requires for Final Confirmation processes
	require $mof_final_pg;
	# Disabled any of these PlugIns in <mofpay.conf>
	require $save_invoice_file if ($save_invoice_html);
	require $mail_merchant_file if ($mail_merchant_invoice);
	require $mail_customer_file if ($mail_customer_receipt);
	require $save_ascii_file if ($save_ascii_data);
	require $save_mysql_file if ($save_mysql_data);
	require $save_cc_file if ($save_cc_data);

	# cod flat charge adjustment
	if ($frm{'input_payment_options'} eq "COD") {
	$frm{'Final_Amount'} = ( $frm{'Final_Amount'} + $cod_charges );
	$frm{'Final_Amount'} = sprintf "%.2f",$frm{'Final_Amount'};
      	$cod_charges = sprintf "%.2f",$cod_charges;
	$frm{'global_CodCharges'} = $cod_charges;
	$cod_charges = CommifyMoney ($cod_charges);
	}

	# adjustment for deposit, and find Payment Amount to display/send
	if ($frm{'Deposit_Amount'} > 0 ) {
	$frm{'Format_Deposit_Amount'} = sprintf "%.2f",$frm{'Deposit_Amount'};
	$frm{'Format_Deposit_Amount'} = CommifyMoney($frm{'Format_Deposit_Amount'});
	$frm{'Remaining_Balance'} = ($frm{'Final_Amount'} - $frm{'Deposit_Amount'});
	$frm{'Overpaid_Surplus'}++ if ($frm{'Remaining_Balance'} < 0 );
	$frm{'Remaining_Balance'} = sprintf "%.2f",$frm{'Remaining_Balance'};
	$frm{'global_RemainingBalance'} = $frm{'Remaining_Balance'};
	$frm{'Remaining_Balance'} = CommifyMoney($frm{'Remaining_Balance'});
	$Display_Payment_Amount = $frm{'Format_Deposit_Amount'};
	$Send_API_Amount = sprintf "%.2f",$frm{'Deposit_Amount'};
	} else {
	$Display_Payment_Amount = CommifyMoney($frm{'Final_Amount'});
	$Send_API_Amount = $frm{'Final_Amount'};
	}

	# API here - sending $Send_API_Amount (formatted 000000.00)
	# Note: The $Send_API_Amount is always Final Amount for anything
	# Note: in <PaymentAccepted><mofinvoice.pl><customer.mail><merchant.mail>

	# needs option to obtain from mySQL dB:invoices:recID
	&GetInvoiceNumber;

	# what customer mail to use
	$mail_customer_addr = "";
	if ($frm{'Ecom_ReceiptTo_Online_Email'}) {
	$mail_customer_addr = $frm{'Ecom_ReceiptTo_Online_Email'};
	} elsif ($frm{'Ecom_BillTo_Online_Email'}) {
	$mail_customer_addr = $frm{'Ecom_BillTo_Online_Email'};
	} elsif ($frm{'Ecom_ShipTo_Online_Email'}) {
	$mail_customer_addr = $frm{'Ecom_ShipTo_Online_Email'};
	}

	@header = ();
	@footer = ();

	# add globals to %frm so that all custom PLs can use them
	# numbers are formatted to sprintf 2F, but not Commified
	# Use a safe Naming Convention not to overwrite existing vars
	# use "global_VarName" to designate a global to use in templating, VarReplacer, SQL
	$frm{'global_currency'} = $currency;
	$frm{'global_MyDate'} = $MyDate;
	$frm{'global_ShortDate'} = $ShortDate;
	$frm{'global_Time'} = $Time;
	$frm{'global_InvoiceNumber'} = $InvoiceNumber;
	$frm{'global_PayType'} = $payment_options_list{$frm{'input_payment_options'}};
	$frm{'global_mail_customer_addr'} = $mail_customer_addr;
	$frm{'global_save_url'} = $save_invoice_url . $$ . $InvoiceNumber . ".html";
	$frm{'global_Send_API_Amount'} = $Send_API_Amount;
	$frm{'global_depmin'} = $depmin;
	# Display_Payment_Amount is the "formatted" payment amount
	# The Deposit Amt (if deposit), The Total Amount (If no deposit)
	$frm{'global_Amount'} = $Display_Payment_Amount;
	# stored after sprintf 2f, before CommifyMoney
	# listed here just to keep the "global_Vars" together
	$frm{'global_CodCharges'} = $frm{'global_CodCharges'};
	$frm{'global_RemainingBalance'} = $frm{'global_RemainingBalance'};
	# all from ARES
	$frm{'global_RepRate'} = $RepRate;
	$frm{'global_RepCode'} = $RepCode;
	$frm{'global_CreditAmount'} = $CreditAmount;
	$frm{'global_RepAmt'} = $RepAmt;

	if ($save_invoice_html) {
	&GetTemplateFile($save_invoice_template,"Save Invoice Template File","save_invoice_template"); 
	&SaveInvoiceFile;
	}

	# Append to the affiliate tracking log
	# Set the condition for whatever you want logged	
	# Caution: do not set a condition like Customer Discount > 0
	# If you are using ARES and have Customer Discount set to zero
	# Because it will then not log the credit due to Affiliates / Reps
	# Note: the RepRate is not found until Final Logging
	# So you cannot set a condition involving RepRates		
	# VERY IMPORTANT: If you enable it this way you MUST have a valid 
	# default Coupon Number Assigned in <mof.conf>
	&LogAffiliateActivity($frm{'Compute_Coupons'}) if ($frm{'Compute_Coupons'} && $use_ARES);
	&DateCouponNumber($frm{'Compute_Coupons'},$coupon_file) if ($coupon_file && $frm{'Coupon_Discount'} > 0);

	@header = ();
	@footer = ();
	&GetTemplateFile($final_template,"Payment Final Template File","final_template"); 

#	&SaveASCIIdB if ($save_ascii_data);
	&SaveASCIIcc if ($save_cc_data);
	&SaveSQLdB if ($save_mysql_data);

	# make PaymentAccepted call from an outside subRoutine
	# Where we can simply substitute different plug ins for the format
	&PaymentAccepted;

	# need to grab the mySQL usrID, myPsw & myUsr to mail, even recID, etc. for mail info
	&MailCustomerReceipt if ($mail_customer_receipt && $mail_customer_addr);

	if ($mail_merchant_invoice && scalar(@mail_merchant_addr)) {
	foreach(@mail_merchant_addr){&MailMerchantInvoice($_)}
	}

	if ($delete_cart_final) {&DeleteCartFile($frm{'OrderID'})}
	else {&ExpireCookie($cookiename_OrderID)}	

}
# End Program Flow



# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003
