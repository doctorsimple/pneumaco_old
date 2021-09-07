# ==================== MOFcart v2.5.10.21.03 ====================== #
# === EXAMPLE FINAL SCREEN THAT PRINTS ALL VARS =================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# A Custom Final Confirmation Screen <mof_finalvars.pl>
# Called by <mofpay.cgi> as set <mofpay.conf> $mof_final_pg = 'mof_finalvars.pl';
# That simply shows you how to call Final variables in different ways
# Major Sections of this sub Routine:
	# (1) Branching for Payment Method Top Messages
	# (2) A Comphrensive Listing of Variables available for use in &PaymentAccepted


# PAYMENT ACCEPTED 
sub PaymentAccepted {

	my $invc_msg;
	my ($nav_top,$nav_bottom) = (0,0);

	# (1) Branching for Payment Method Top Messages
	# (1) Branching for Payment Method Top Messages

	# (1.1) pay by mail
	if ($frm{'input_payment_options'} eq "MAIL") {
	$invc_msg .= qq~	<b>Payment by MAIL Selected</b> ~;

	# (1.2) cod
	} elsif ($frm{'input_payment_options'} eq "COD") {
	$invc_msg .= qq~	<b>Payment by COD Selected</b> ~;

	# (1.3) on account
	} elsif ($frm{'input_payment_options'} eq "ONACCT") {
	$invc_msg .= qq~	<b>Payment by ONNACCT Selected</b> ~;

	# (1.4) call for pay details
	} elsif ($frm{'input_payment_options'} eq "CALLME") {
	$invc_msg .= qq~	<b>Payment by CALLME Selected</b> ~;

	# (1.5) invoice is zero amt
	} elsif ($frm{'input_payment_options'} eq "ZEROPAY") {
	$invc_msg .= qq~	<b>Payment by ZEROPAY : No Payable Amount on Order</b> ~;

	# (1.6) paypal pass off	
	} elsif ($frm{'input_payment_options'} eq "PAYPAL") {
	$invc_msg .= qq~	<b>Payment by PAYPAL Selected</b> ~;

	# (1.7) forms gateway
	} elsif ($frm{'input_payment_options'} eq "GATEWAY") {
	$invc_msg .= qq~	<b>Payment by FORM GATEWAY Selected</b> ~;

	} else {
		
		# (1.8) custom full gateway
		if ($use_gateway_mof) {
		$invc_msg .= qq~	<b>Payment by FULL GATEWAY or CARD Selected</b> ~;

		# (1.9) online check
		} elsif ($check_check) {
		$invc_msg .= qq~	<b>Payment by FULL GATEWAY or CHECK Selected</b> ~;

		}
	}


	# (2) List of 164 Variable names available
	# (2) With example of how to loop through the list of vars
	# (2) Note: the customA .. N vars are used in the package example
	#       Any custom var names you use are the ones you need listed here


my @vars = (
'Adjusted_Tax_Amount',
'Adjusted_Tax_Amount_After',
'Adjusted_Tax_Amount_Before',
'Allow_Shipping',
'Allow_Tax',
'Check_Account_Number',
'Check_Account_Type',
'Check_Bank_Address',
'Check_Bank_Name',
'Check_Customer_Organization_Type',
'Check_Drivers_License_DOB',
'Check_Drivers_License_Num',
'Check_Drivers_License_ST',
'Check_Fraction_Number',
'Check_Holder_Name',
'Check_Number',
'Check_Routing_Number',
'Check_Tax_ID',
'Combined_Discount',
'Combined_SHI',
'Compute_Coupons',
'Compute_Insurance',
'Compute_Shipping_Method',
'Coupon_Affiliate_Rate',
'Coupon_Cust_Rate',
'Coupon_Discount',
'Coupon_Discount_myNumber',
'Coupon_Discount_Status',
'customA_CompanyName',
'customB_Address',
'customC_City',
'customD_State',
'customE_Country',
'customF_Zip',
'customG_PhoneNumber',
'customH_PhoneNumber',
'customI_AddToMail',
'customJ_StableEmail',
'customK_ReferredBy',
'customL_Other',
'customM_AnotherList',
'customN_OneMore',
'Deposit_Amount',
'Domestic_City',
'Ecom_BillTo_Online_Email',
'Ecom_BillTo_Postal_City',
'Ecom_BillTo_Postal_Company',
'Ecom_BillTo_Postal_CountryCode',
'Ecom_BillTo_Postal_Name_First',
'Ecom_BillTo_Postal_Name_Last',
'Ecom_BillTo_Postal_Name_Middle',
'Ecom_BillTo_Postal_Name_Prefix',
'Ecom_BillTo_Postal_Name_Suffix',
'Ecom_BillTo_Postal_PostalCode',
'Ecom_BillTo_Postal_Region',
'Ecom_BillTo_Postal_StateProv',
'Ecom_BillTo_Postal_Street_Line1',
'Ecom_BillTo_Postal_Street_Line2',
'Ecom_BillTo_Telecom_Phone_Number',
'Ecom_Payment_Card_ExpDate_Day',
'Ecom_Payment_Card_ExpDate_Month',
'Ecom_Payment_Card_ExpDate_Year',
'Ecom_Payment_Card_FromDate_Month',
'Ecom_Payment_Card_FromDate_Year',
'Ecom_Payment_Card_IssueNumber',
'Ecom_Payment_Card_Name',
'Ecom_Payment_Card_Number',
'Ecom_Payment_Card_Type',
'Ecom_Payment_Card_Verification',
'Ecom_ReceiptTo_Online_Email',
'Ecom_ReceiptTo_Postal_City',
'Ecom_ReceiptTo_Postal_Company',
'Ecom_ReceiptTo_Postal_CountryCode',
'Ecom_ReceiptTo_Postal_Name_First',
'Ecom_ReceiptTo_Postal_Name_Last',
'Ecom_ReceiptTo_Postal_Name_Middle',
'Ecom_ReceiptTo_Postal_Name_Prefix',
'Ecom_ReceiptTo_Postal_Name_Suffix',
'Ecom_ReceiptTo_Postal_PostalCode',
'Ecom_ReceiptTo_Postal_Region',
'Ecom_ReceiptTo_Postal_StateProv',
'Ecom_ReceiptTo_Postal_Street_Line1',
'Ecom_ReceiptTo_Postal_Street_Line2',
'Ecom_ReceiptTo_Telecom_Phone_Number',
'Ecom_ShipTo_Online_Email',
'Ecom_ShipTo_Postal_City',
'Ecom_ShipTo_Postal_Company',
'Ecom_ShipTo_Postal_CountryCode',
'Ecom_ShipTo_Postal_Name_First',
'Ecom_ShipTo_Postal_Name_Last',
'Ecom_ShipTo_Postal_Name_Middle',
'Ecom_ShipTo_Postal_Name_Prefix',
'Ecom_ShipTo_Postal_Name_Suffix',
'Ecom_ShipTo_Postal_PostalCode',
'Ecom_ShipTo_Postal_Region',
'Ecom_ShipTo_Postal_StateProv',
'Ecom_ShipTo_Postal_Street_Line1',
'Ecom_ShipTo_Postal_Street_Line2',
'Ecom_ShipTo_Telecom_Phone_Number',
'Ecom_ShipTo_Postal_Type',
'Final_Amount',
'Final_ConvertAmount',
'Format_Deposit_Amount',
'global_Amount',
'global_CodCharges',
'global_CreditAmount',
'global_currency',
'global_depmin',
'global_InvoiceNumber',
'global_mail_customer_addr',
'global_MyDate',
'global_PayType',
'global_RemainingBalance',
'global_RepAmt',
'global_RepCode',
'global_RepRate',
'global_save_url',
'global_Send_API_Amount',
'global_ShortDate',
'global_Time',
'Handling',
'Handling_Status',
'InfoID',
'Initial_Taxable_Amount',
'input_cyber_permission',
'input_payment_options',
'input_shipping_info',
'Insurance',
'Insurance_Amt_Override',
'Insurance_Line_Override',
'Insurance_Status',
'Is_Domestic',
'OrderID',
'previouspage',
'Primary_Discount',
'Primary_Discount_Line_Override_Backend',
'Primary_Discount_Status',
'Primary_Price',
'Primary_Products',
'Remaining_Balance',
'resubmit_info',
'Shipping_Amount',
'Shipping_Amt_Override',
'Shipping_Line_Override',
'Shipping_Message',
'Shipping_Method_Description',
'Shipping_Method_Name',
'Shipping_Status',
'special_instructions',
'Sub_Coupon_Discount',
'Sub_Final_Discount',
'Sub_Primary_Discount',
'Sub_SHI',
'Tax_Amount',
'Tax_Discount_Ratio',
'Tax_Exempt_Status',
'Tax_Line_Override',
'Tax_Message',
'Tax_Rate',
'Tax_Rule',
'Tax_Rule_Exceptions',
'Total_Weight',
'Use_Domestic');


	# (3) loop through the list and do something

	$invc_msg .= qq~<p>
	A Comphrensive Listing of Variables available for use in &PaymentAccepted <br>
	Using a loop to do something with the list of vars<p> 
	<table Class="TotalTable"> ~;

		my $i = 1;
		my $st;
		foreach (@vars) {
		$st = "{{$_}}" if ($frm{$_});
		$st = "<font color=red>no data</font>" unless ($frm{$_});
		$invc_msg .= qq~<tr Class="sRow8"><td nowrap Class="pText8">$i <b>$_</b> : </td><td> $st </td></tr>~;
		$i++;
		}

	$invc_msg .= qq~</table>~;

	# (4) List all the $frm global variables at this point in the script

	my $i = 1;
	my $st;
	@Sort = sort {uc($a) cmp uc($b)} (keys %frm);

	$invc_msg .= qq~<p>
	A Comphrensive Listing of Variables available for use in &PaymentAccepted <br>
	Listing the vars by looping through the $frm hash for var names : values<br>
	Providing an ascending alphabetised sort<br>
	Note: some vars may not be present, example COD, Deposit vars if those options not used<p>
	<table Class="TotalTable"> ~;

	foreach (@Sort) {
	$st = "{{$_}}" if ($frm{$_});
	$st = "<font color=red>no data</font>" unless ($frm{$_});
	$invc_msg .= qq~<tr Class="sRow8"><td nowrap Class="pText8">$i <b>$_</b> : </td><td>$st</td></tr>~;
	$i++;
	}

	$invc_msg .= qq~</table>~;


	# (5) A static list of all the vars and how to set them up for the VarReplacer
	# so that you can place real values in your custom final screen routines

	$invc_msg .= qq~
	<p>
	A Comphrensive Listing of Variables available for use in &PaymentAccepted <br>
	Using a static list with examples on how to use the VarReplacer for real values in your custoizing.<br>
	Remember, you can't perform operations on VarReplacer variables, but you can perform operations
        on the real name : value pair available by the same name in the $frm hash<p>

	In other words, both examples below contain the exact same value, however, the VarReplacer value
	is a simple substitution, whereas, the example referring to the $frm hash is how you would reference
	a variable if you were going to perform some operation on the value.<p>

	<li><b>NAME</b> : {{VALUE}} .. provides a simple substitution via VarReplacer
	<li><b>NAME</b> : \$frm{'NAME'}  ..  produces a real time value you can perform operation with<p>

	<table Class="TotalTable"><tr Class="sRow8"><td Class="pText8"><ol>
	<li><b>Adjusted_Tax_Amount</b> : {{Adjusted_Tax_Amount}}
	<li><b>Adjusted_Tax_Amount_After</b> : {{Adjusted_Tax_Amount_After}}
	<li><b>Adjusted_Tax_Amount_Before</b> : {{Adjusted_Tax_Amount_Before}}
	<li><b>Allow_Shipping</b> : {{Allow_Shipping}}
	<li><b>Allow_Tax</b> : {{Allow_Tax}}
	<li><b>Check_Account_Number</b> : {{Check_Account_Number}}
	<li><b>Check_Account_Type</b> : {{Check_Account_Type}}
	<li><b>Check_Bank_Address</b> : {{Check_Bank_Address}}
	<li><b>Check_Bank_Name</b> : {{Check_Bank_Name}}
	<li><b>Check_Customer_Organization_Type</b> : {{Check_Customer_Organization_Type}}
	<li><b>Check_Drivers_License_DOB</b> : {{Check_Drivers_License_DOB}}
	<li><b>Check_Drivers_License_Num</b> : {{Check_Drivers_License_Num}}
	<li><b>Check_Drivers_License_ST</b> : {{Check_Drivers_License_ST}}
	<li><b>Check_Fraction_Number</b> : {{Check_Fraction_Number}}
	<li><b>Check_Holder_Name</b> : {{Check_Holder_Name}}
	<li><b>Check_Number</b> : {{Check_Number}}
	<li><b>Check_Routing_Number</b> : {{Check_Routing_Number}}
	<li><b>Check_Tax_ID</b> : {{Check_Tax_ID}}
	<li><b>Combined_Discount</b> : {{Combined_Discount}}
	<li><b>Combined_SHI</b> : {{Combined_SHI}}
	<li><b>Compute_Coupons</b> : {{Compute_Coupons}}
	<li><b>Compute_Insurance</b> : {{Compute_Insurance}}
	<li><b>Compute_Shipping_Method</b> : {{Compute_Shipping_Method}}
	<li><b>Coupon_Affiliate_Rate</b> : {{Coupon_Affiliate_Rate}}
	<li><b>Coupon_Cust_Rate</b> : {{Coupon_Cust_Rate}}
	<li><b>Coupon_Discount</b> : {{Coupon_Discount}}
	<li><b>Coupon_Discount_myNumber</b> : {{Coupon_Discount_myNumber}}
	<li><b>Coupon_Discount_Status</b> : {{Coupon_Discount_Status}}
	<li><b>customA_CompanyName</b> : {{customA_CompanyName}}
	<li><b>customB_Address</b> : {{customB_Address}}
	<li><b>customC_City</b> : {{customC_City}}
	<li><b>customD_State</b> : {{customD_State}}
	<li><b>customE_Country</b> : {{customE_Country}}
	<li><b>customF_Zip</b> : {{customF_Zip}}
	<li><b>customG_PhoneNumber</b> : {{customG_PhoneNumber}}
	<li><b>customH_PhoneNumber</b> : {{customH_PhoneNumber}}
	<li><b>customI_AddToMail</b> : {{customI_AddToMail}}
	<li><b>customJ_StableEmail</b> : {{customJ_StableEmail}}
	<li><b>customK_ReferredBy</b> : {{customK_ReferredBy}}
	<li><b>customL_Other</b> : {{customL_Other}}
	<li><b>customM_AnotherList</b> : {{customM_AnotherList}}
	<li><b>customN_OneMore</b> : {{customN_OneMore}}
	<li><b>Deposit_Amount</b> : {{Deposit_Amount}}
	<li><b>Domestic_City</b> : {{Domestic_City}}
	<li><b>Ecom_BillTo_Online_Email</b> : {{Ecom_BillTo_Online_Email}}
	<li><b>Ecom_BillTo_Postal_City</b> : {{Ecom_BillTo_Postal_City}}
	<li><b>Ecom_BillTo_Postal_Company</b> : {{Ecom_BillTo_Postal_Company}}
	<li><b>Ecom_BillTo_Postal_CountryCode</b> : {{Ecom_BillTo_Postal_CountryCode}}
	<li><b>Ecom_BillTo_Postal_Name_First</b> : {{Ecom_BillTo_Postal_Name_First}}
	<li><b>Ecom_BillTo_Postal_Name_Last</b> : {{Ecom_BillTo_Postal_Name_Last}}
	<li><b>Ecom_BillTo_Postal_Name_Middle</b> : {{Ecom_BillTo_Postal_Name_Middle}}
	<li><b>Ecom_BillTo_Postal_Name_Prefix</b> : {{Ecom_BillTo_Postal_Name_Prefix}}
	<li><b>Ecom_BillTo_Postal_Name_Suffix</b> : {{Ecom_BillTo_Postal_Name_Suffix}}
	<li><b>Ecom_BillTo_Postal_PostalCode</b> : {{Ecom_BillTo_Postal_PostalCode}}
	<li><b>Ecom_BillTo_Postal_Region</b> : {{Ecom_BillTo_Postal_Region}}
	<li><b>Ecom_BillTo_Postal_StateProv</b> : {{Ecom_BillTo_Postal_StateProv}}
	<li><b>Ecom_BillTo_Postal_Street_Line1</b> : {{Ecom_BillTo_Postal_Street_Line1}}
	<li><b>Ecom_BillTo_Postal_Street_Line2</b> : {{Ecom_BillTo_Postal_Street_Line2}}
	<li><b>Ecom_BillTo_Telecom_Phone_Number</b> : {{Ecom_BillTo_Telecom_Phone_Number}}
	<li><b>Ecom_Payment_Card_ExpDate_Day</b> : {{Ecom_Payment_Card_ExpDate_Day}}
	<li><b>Ecom_Payment_Card_ExpDate_Month</b> : {{Ecom_Payment_Card_ExpDate_Month}}
	<li><b>Ecom_Payment_Card_ExpDate_Year</b> : {{Ecom_Payment_Card_ExpDate_Year}}
	<li><b>Ecom_Payment_Card_FromDate_Month</b> : {{Ecom_Payment_Card_FromDate_Month}}
	<li><b>Ecom_Payment_Card_FromDate_Year</b> : {{Ecom_Payment_Card_FromDate_Year}}
	<li><b>Ecom_Payment_Card_IssueNumber</b> : {{Ecom_Payment_Card_IssueNumber}}
	<li><b>Ecom_Payment_Card_Name</b> : {{Ecom_Payment_Card_Name}}
	<li><b>Ecom_Payment_Card_Number</b> : {{Ecom_Payment_Card_Number}}
	<li><b>Ecom_Payment_Card_Type</b> : {{Ecom_Payment_Card_Type}}
	<li><b>Ecom_Payment_Card_Verification</b> : {{Ecom_Payment_Card_Verification}}
	<li><b>Ecom_ReceiptTo_Online_Email</b> : {{Ecom_ReceiptTo_Online_Email}}
	<li><b>Ecom_ReceiptTo_Postal_City</b> : {{Ecom_ReceiptTo_Postal_City}}
	<li><b>Ecom_ReceiptTo_Postal_Company</b> : {{Ecom_ReceiptTo_Postal_Company}}
	<li><b>Ecom_ReceiptTo_Postal_CountryCode</b> : {{Ecom_ReceiptTo_Postal_CountryCode}}
	<li><b>Ecom_ReceiptTo_Postal_Name_First</b> : {{Ecom_ReceiptTo_Postal_Name_First}}
	<li><b>Ecom_ReceiptTo_Postal_Name_Last</b> : {{Ecom_ReceiptTo_Postal_Name_Last}}
	<li><b>Ecom_ReceiptTo_Postal_Name_Middle</b> : {{Ecom_ReceiptTo_Postal_Name_Middle}}
	<li><b>Ecom_ReceiptTo_Postal_Name_Prefix</b> : {{Ecom_ReceiptTo_Postal_Name_Prefix}}
	<li><b>Ecom_ReceiptTo_Postal_Name_Suffix</b> : {{Ecom_ReceiptTo_Postal_Name_Suffix}}
	<li><b>Ecom_ReceiptTo_Postal_PostalCode</b> : {{Ecom_ReceiptTo_Postal_PostalCode}}
	<li><b>Ecom_ReceiptTo_Postal_Region</b> : {{Ecom_ReceiptTo_Postal_Region}}
	<li><b>Ecom_ReceiptTo_Postal_StateProv</b> : {{Ecom_ReceiptTo_Postal_StateProv}}
	<li><b>Ecom_ReceiptTo_Postal_Street_Line1</b> : {{Ecom_ReceiptTo_Postal_Street_Line1}}
	<li><b>Ecom_ReceiptTo_Postal_Street_Line2</b> : {{Ecom_ReceiptTo_Postal_Street_Line2}}
	<li><b>Ecom_ReceiptTo_Telecom_Phone_Number</b> : {{Ecom_ReceiptTo_Telecom_Phone_Number}}
	<li><b>Ecom_ShipTo_Online_Email</b> : {{Ecom_ShipTo_Online_Email}}
	<li><b>Ecom_ShipTo_Postal_City</b> : {{Ecom_ShipTo_Postal_City}}
	<li><b>Ecom_ShipTo_Postal_Company</b> : {{Ecom_ShipTo_Postal_Company}}
	<li><b>Ecom_ShipTo_Postal_CountryCode</b> : {{Ecom_ShipTo_Postal_CountryCode}}
	<li><b>Ecom_ShipTo_Postal_Name_First</b> : {{Ecom_ShipTo_Postal_Name_First}}
	<li><b>Ecom_ShipTo_Postal_Name_Last</b> : {{Ecom_ShipTo_Postal_Name_Last}}
	<li><b>Ecom_ShipTo_Postal_Name_Middle</b> : {{Ecom_ShipTo_Postal_Name_Middle}}
	<li><b>Ecom_ShipTo_Postal_Name_Prefix</b> : {{Ecom_ShipTo_Postal_Name_Prefix}}
	<li><b>Ecom_ShipTo_Postal_Name_Suffix</b> : {{Ecom_ShipTo_Postal_Name_Suffix}}
	<li><b>Ecom_ShipTo_Postal_PostalCode</b> : {{Ecom_ShipTo_Postal_PostalCode}}
	<li><b>Ecom_ShipTo_Postal_Region</b> : {{Ecom_ShipTo_Postal_Region}}
	<li><b>Ecom_ShipTo_Postal_StateProv</b> : {{Ecom_ShipTo_Postal_StateProv}}
	<li><b>Ecom_ShipTo_Postal_Street_Line1</b> : {{Ecom_ShipTo_Postal_Street_Line1}}
	<li><b>Ecom_ShipTo_Postal_Street_Line2</b> : {{Ecom_ShipTo_Postal_Street_Line2}}
	<li><b>Ecom_ShipTo_Telecom_Phone_Number</b> : {{Ecom_ShipTo_Telecom_Phone_Number}}
	<li><b>Ecom_ShipTo_Postal_Type</b> : {{Ecom_ShipTo_Postal_Type}}
	<li><b>Final_Amount</b> : {{Final_Amount}}
	<li><b>Final_ConvertAmount</b> : {{Final_ConvertAmount}}
	<li><b>Format_Deposit_Amount</b> : {{Format_Deposit_Amount}}
	<li><b>global_Amount</b> : {{global_Amount}}
	<li><b>global_CodCharges</b> : {{global_CodCharges}}
	<li><b>global_CreditAmount</b> : {{global_CreditAmount}}
	<li><b>global_currency</b> : {{global_currency}}
	<li><b>global_depmin</b> : {{global_depmin}}
	<li><b>global_InvoiceNumber</b> : {{global_InvoiceNumber}}
	<li><b>global_mail_customer_addr</b> : {{global_mail_customer_addr}}
	<li><b>global_MyDate</b> : {{global_MyDate}}
	<li><b>global_PayType</b> : {{global_PayType}}
	<li><b>global_RemainingBalance</b> : {{global_RemainingBalance}}
	<li><b>global_RepAmt</b> : {{global_RepAmt}}
	<li><b>global_RepCode</b> : {{global_RepCode}}
	<li><b>global_RepRate</b> : {{global_RepRate}}
	<li><b>global_save_url</b> : {{global_save_url}}
	<li><b>global_Send_API_Amount</b> : {{global_Send_API_Amount}}
	<li><b>global_ShortDate</b> : {{global_ShortDate}}
	<li><b>global_Time</b> : {{global_Time}}
	<li><b>Handling</b> : {{Handling}}
	<li><b>Handling_Status</b> : {{Handling_Status}}
	<li><b>InfoID</b> : {{InfoID}}
	<li><b>Initial_Taxable_Amount</b> : {{Initial_Taxable_Amount}}
	<li><b>input_cyber_permission</b> : {{input_cyber_permission}}
	<li><b>input_cyber_permission</b> : {{input_cyber_permission}}x
	<li><b>input_shipping_info</b> : {{input_shipping_info}}
	<li><b>Insurance</b> : {{Insurance}}
	<li><b>Insurance_Amt_Override</b> : {{Insurance_Amt_Override}}
	<li><b>Insurance_Line_Override</b> : {{Insurance_Line_Override}}
	<li><b>Insurance_Status</b> : {{Insurance_Status}}
	<li><b>Is_Domestic</b> : {{Is_Domestic}}
	<li><b>OrderID</b> : {{OrderID}}
	<li><b>previouspage</b> : {{previouspage}}
	<li><b>Primary_Discount</b> : {{Primary_Discount}}
	<li><b>Primary_Discount_Line_Override_Backend</b> : {{Primary_Discount_Line_Override_Backend}}
	<li><b>Primary_Discount_Status</b> : {{Primary_Discount_Status}}
	<li><b>Primary_Price</b> : {{Primary_Price}}
	<li><b>Primary_Products</b> : {{Primary_Products}}
	<li><b>Remaining_Balance</b> : {{Remaining_Balance}}
	<li><b>Shipping_Amount</b> : {{Shipping_Amount}}
	<li><b>Shipping_Amt_Override</b> : {{Shipping_Amt_Override}}
	<li><b>Shipping_Line_Override</b> : {{Shipping_Line_Override}}
	<li><b>Shipping_Message</b> : {{Shipping_Message}}
	<li><b>Shipping_Method_Description</b> : {{Shipping_Method_Description}}
	<li><b>Shipping_Method_Name</b> : {{Shipping_Method_Name}}
	<li><b>Shipping_Status</b> : {{Shipping_Status}}
	<li><b>special_instructions</b> : {{special_instructions}}
	<li><b>Sub_Coupon_Discount</b> : {{Sub_Coupon_Discount}}
	<li><b>Sub_Final_Discount</b> : {{Sub_Final_Discount}}
	<li><b>Sub_Primary_Discount</b> : {{Sub_Primary_Discount}}
	<li><b>Sub_SHI</b> : {{Sub_SHI}}
	<li><b>Tax_Amount</b> : {{Tax_Amount}}
	<li><b>Tax_Discount_Ratio</b> : {{Tax_Discount_Ratio}}
	<li><b>Tax_Exempt_Status</b> : {{Tax_Exempt_Status}}
	<li><b>Tax_Line_Override</b> : {{Tax_Line_Override}}
	<li><b>Tax_Message</b> : {{Tax_Message}}
	<li><b>Tax_Rate</b> : {{Tax_Rate}}
	<li><b>Tax_Rule</b> : {{Tax_Rule}}
	<li><b>Tax_Rule_Exceptions</b> : {{Tax_Rule_Exceptions}}
	<li><b>Total_Weight</b> : {{Total_Weight}}
	<li><b>Use_Domestic</b> : {{Use_Domestic}}
	</ol></td></tr></table>
	~;

	$invc_msg = &VarReplacer($invc_msg);

	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$invc_msg <p>";
	print "@footer \n\n";
	}


	sub Space {
		my($len,$txt) = @_;	
		$str = length($txt);
		$len = ($len - $str);
		$len = " . " x $len;
		$str = $len . $txt;
	return $str;
	}


# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;

