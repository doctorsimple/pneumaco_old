# ==================== MOFcart v2.5.02.20.04 ====================== #
# === CUSTOM MYSQL DATA STORAGE =================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# MOFcart v2.5 mySQL Data Storage plug in
# Note: the plugins must be called from a <mof.cgi> or <mofpay.cgi> process
# Otherwise you will need to pre load the vars from <common.conf>

# RGA : February 20, 2004 2:45:51 PM
# Added (2) new tables for Abuse mgmt : mofabuse, mofabusedeny
# Note that data storage *only* for mofabuse stats
# The mofabusedeny DB is to use as a Block IP, or OrderID List
# The Block lists is used by <mofpay.cgi> & the DB backend manager

# USING DBD::mysqlPP (Pure Perl)
# You can use both DBD::mysqlPP & DBI (pure perl) in native DIR
# DBI pure perl compiles a little slower than C DBI
# most servers have (compiled) DBI as common module
# if you are having trouble with Database Drivers place the DBD::mysqlPP in same DIR as this script

# Note that mySQL stores dates as YYYY-MM-DD
# the Var for that in this sub routine is $sqlDate
# Which is taken from $frm{ShortDate'} MM/DD/YYYY
# So you will *never* use any of MOFcarts dates for mySQL
# but only the formatted $sqlDate

# THIS SAVE UTILITY IS UNDER DEVELOPMENT, notes in script
# This is distributed with MOFcart v2.5, howerver it is only the underpinnings
# for further mySQL operations with MOFcart v3.0. You may customize to suite.
# RGA : August 10, 2003 8:22:10 PM

# WHERE TO GO:
# (soon) Build encryption/decryption for any Payment info (cards, etc.)
# (1) Build user GUI to access order status & download instructions
        # Send initial assigned user : pasw Login via first email notice
# (2) Build in APIs for IPN, BOFA, AuthNet
# (3) Complete Admin GUI for order status updates, reports, import/export
# (4) Integrate ARES v3.0 to mySQL, with enhanced features
# (5) Integrate other features for mail, specials, referrals, updates, customer profiles
# (6) Integrate customer ID tie in with checkout, provide auto-fill payment info
        # and ability for customer profile management

sub SaveSQLdB {

	use DBI;
	local($x)=0;
	local (@qry) = ();
	local (@msg) = ();
	local (@notes) = ();
	local $errFilePath = "$mvar_back_path_mcart/dbquery/mof_savesql_err.txt";
	local ($sth,$sql,$dbh,$sql,$i,$ver,$id);

	# Tip: any variables you want to include in your mail messages resulting from
	#        the database save operation should be initialized as Global
	$myUsr,$myPsw,$cryptPsw;$recid,$usrid,$sqlDate;

	my ($f1,$f2,$f3,$f4,$f5,$f6,$f7,
		$f8,$f9,$f10,$f11,$f12,$f13,$f14,$f15,
		$qty,$itm,$dbk,$price,$ship,$tax,$desc,$ibk);

	# prepare date format for mySQL : 2003-08-08 18:55:55
	# ShortDate : MM/DD/YYYY
	my(@dt) =  split(/\//,$ShortDate);
		$sqlDate = "$dt[2]";
		$sqlDate .= "$dt[0]";
		$sqlDate .= "$dt[1]";
	
	# I wonder if it is better to do the order activity qry as a JOIN
	# where the recID automatically populates to referential recID 
	# probably no need, as only 1 unique recID is produced per script session
	# which is the exact same referential ID stored
	# We are producing a usrID as well, but that is also unique to this sessions only

	# (1) Profiles must go first, to obtain the usrID (Profiles will *never* have reference to order activity)
	        # but all order activity will have usrID reference
	# (2) Invoices must go next, to store the usrID, and obtain the recID for rest of tables

	# make temp usr : psw, crypt(myPsw,myUsr) This is the initial stored usrID 
	# if no eMail for Receipt, Bill or Ship Addr, then InvoiceNumber is used as usrID
	
	$myUsr = $frm{'global_InvoiceNumber'};
	$myUsr = $frm{'global_mail_customer_addr'} if ($frm{'global_mail_customer_addr'});

	# for now we are storing the real myPsw
	# you can store the crypt(ed) Psw to dB, but you'll need a way to get the real Psw to user
	# via email or even store to temp file somewhere
	# also, using the unix crypt scheme, the profile dB cannot mail a forgotten Psw
	# but it can allow someone to change the myPsw && myUsr (both must change)
	# by mailing (to myEmail listed) a special SSL login to utility that resets the myUsr & myPsw
	($myPsw,$cryptPsw) = &genPsw($myUsr);

	&dbConnect();

	##### The card data needs to be encrypted ??
	##### use my Rot13, agenie.cgi, or mySQL encrypt ???????
	##### August 09, 2003 11:05:17 PM

	# profile first, get insertid for usrID val
	# and we need to set up process to prompt or login for existing usrID
	# in the sequence of things you'll need to match up user w/ user profile
	# and use that usr Number instead of assigning a new one ..

	# NOTE: when real profile data is used in order process
	# NOTE: you will need to prompt customer for usrID, etc. or login
	# NOTE: so that we can match order/invoice to the user profile
	# NOTE: perhaps prompt at Billing info page, saying if has a user ID
	# NOTE: then we can prefill payment info, or user can change profile info stored
	# NOTE: then we can proceed with the final confirmation & mySQL store from stored usrID
	# NOTE: The process below is only for NEW user's at this point, all orders create a new profile record

	# (1) <mofprofile> table structure
	$sql = qq~
	INSERT INTO mofprofile (
		myUsr,
		myPsw,
		myDate,
		myTime,
		myEmail,
		myCity,
		myCompany,
		myCountryCode,
		myName_First,
		myName_Last,
		myName_Middle,
		myName_Prefix,
		myName_Suffix,
		myPostalCode,
		myRegion,
		myStateProv,
		myStreet_Line1,
		myStreet_Line2,
		myPhone_Number,
		myCard_ExpDate_Day,
		myCard_ExpDate_Month,
		myCard_ExpDate_Year,
		myCard_FromDate_Month,
		myCard_FromDate_Year,
		myCard_IssueNumber,
		myCard_Name,
		myCard_Number,
		myCard_Type,
		myNotes
	) VALUES (
		\"$myUsr\",
		\"$myPsw\",
		\"$sqlDate\",
		\"$Time\",
		\"$frm{'global_mail_customer_addr'}\",
		\"$frm{'Ecom_BillTo_Postal_City'}\",
		\"$frm{'Ecom_BillTo_Postal_Company'}\",
		\"$frm{'Ecom_BillTo_Postal_CountryCode'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_First'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Last'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Middle'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Prefix'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Suffix'}\",
		\"$frm{'Ecom_BillTo_Postal_PostalCode'}\",
		\"$frm{'Ecom_BillTo_Postal_Region'}\",
		\"$frm{'Ecom_BillTo_Postal_StateProv'}\",
		\"$frm{'Ecom_BillTo_Postal_Street_Line1'}\",
		\"$frm{'Ecom_BillTo_Postal_Street_Line2'}\",
		\"$frm{'Ecom_BillTo_Telecom_Phone_Number'}\",
		\"$frm{'Ecom_Payment_Card_ExpDate_Day'}\",
		\"$frm{'Ecom_Payment_Card_ExpDate_Month'}\",
		\"$frm{'Ecom_Payment_Card_ExpDate_Year'}\",
		\"$frm{'Ecom_Payment_Card_FromDate_Month'}\",
		\"$frm{'Ecom_Payment_Card_FromDate_Year'}\",
		\"$frm{'Ecom_Payment_Card_IssueNumber'}\",
		\"$frm{'Ecom_Payment_Card_Name'}\",
		\"Not Stored\",
		\"$frm{'Ecom_Payment_Card_Type'}\",
		\"ver2.5 Record\")\;
		~;

	# qry => mofprofile
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);
	# get the usrID to store
	$usrid = $dbh->{'mysqlpp_insertid'};

	# order activity next, using usrID, and obtaining recID to store to other orders
	# (2) <mofinvoices> table structure
	$sql = qq~
	INSERT INTO mofinvoices (
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID,
		global_Amount,
		global_CodCharges,
		global_CreditAmount,
		global_currency,
		global_depmin,
		global_mail_customer_addr,
		global_MyDate,
		global_PayType,
		global_RemainingBalance,
		global_RepAmt,
		global_RepCode,
		global_RepRate,
		global_save_url,
		global_Send_API_Amount,
		global_ShortDate,
		global_Time,
		Ecom_BillTo_Online_Email,
		Ecom_BillTo_Postal_City,
		Ecom_BillTo_Postal_Company,
		Ecom_BillTo_Postal_CountryCode,
		Ecom_BillTo_Postal_Name_First,
		Ecom_BillTo_Postal_Name_Last,
		Ecom_BillTo_Postal_Name_Middle,
		Ecom_BillTo_Postal_Name_Prefix,
		Ecom_BillTo_Postal_Name_Suffix,
		Ecom_BillTo_Postal_PostalCode,
		Ecom_BillTo_Postal_Region,
		Ecom_BillTo_Postal_StateProv,
		Ecom_BillTo_Postal_Street_Line1,
		Ecom_BillTo_Postal_Street_Line2,
		Ecom_BillTo_Telecom_Phone_Number,
		Ecom_ShipTo_Online_Email,
		Ecom_ShipTo_Postal_City,
		Ecom_ShipTo_Postal_Company,
		Ecom_ShipTo_Postal_CountryCode,
		Ecom_ShipTo_Postal_Name_First,
		Ecom_ShipTo_Postal_Name_Last,
		Ecom_ShipTo_Postal_Name_Middle,
		Ecom_ShipTo_Postal_Name_Prefix,
		Ecom_ShipTo_Postal_Name_Suffix,
		Ecom_ShipTo_Postal_PostalCode,
		Ecom_ShipTo_Postal_Region,
		Ecom_ShipTo_Postal_StateProv,
		Ecom_ShipTo_Postal_Street_Line1,
		Ecom_ShipTo_Postal_Street_Line2,
		Ecom_ShipTo_Telecom_Phone_Number,
		Ecom_ShipTo_Postal_Type,
		Check_Account_Number,
		Check_Account_Type,
		Check_Bank_Address,
		Check_Bank_Name,
		Check_Customer_Organization_Type,
		Check_Drivers_License_DOB,
		Check_Drivers_License_Num,
		Check_Drivers_License_ST,
		Check_Fraction_Number,
		Check_Holder_Name,
		Check_Number,
		Check_Routing_Number,
		Check_Tax_ID,
		Ecom_Payment_Card_ExpDate_Day,
		Ecom_Payment_Card_ExpDate_Month,
		Ecom_Payment_Card_ExpDate_Year,
		Ecom_Payment_Card_FromDate_Month,
		Ecom_Payment_Card_FromDate_Year,
		Ecom_Payment_Card_IssueNumber,
		Ecom_Payment_Card_Name,
		Ecom_Payment_Card_Number,
		Ecom_Payment_Card_Type
	) VALUES (
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\",
		\"$frm{'global_Amount'}\",
		\"$frm{'global_CodCharges'}\",
		\"$frm{'global_CreditAmount'}\",
		\"$frm{'global_currency'}\",
		\"$frm{'global_depmin'}\",
		\"$frm{'global_mail_customer_addr'}\",
		\"$frm{'global_MyDate'}\",
		\"$frm{'global_PayType'}\",
		\"$frm{'global_RemainingBalance'}\",
		\"$frm{'global_RepAmt'}\",
		\"$frm{'global_RepCode'}\",
		\"$frm{'global_RepRate'}\",
		\"$frm{'global_save_url'}\",
		\"$frm{'global_Send_API_Amount'}\",
		\"$sqlDate\",
		\"$frm{'global_Time'}\",
		\"$frm{'Ecom_BillTo_Online_Email'}\",
		\"$frm{'Ecom_BillTo_Postal_City'}\",
		\"$frm{'Ecom_BillTo_Postal_Company'}\",
		\"$frm{'Ecom_BillTo_Postal_CountryCode'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_First'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Last'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Middle'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Prefix'}\",
		\"$frm{'Ecom_BillTo_Postal_Name_Suffix'}\",
		\"$frm{'Ecom_BillTo_Postal_PostalCode'}\",
		\"$frm{'Ecom_BillTo_Postal_Region'}\",
		\"$frm{'Ecom_BillTo_Postal_StateProv'}\",
		\"$frm{'Ecom_BillTo_Postal_Street_Line1'}\",
		\"$frm{'Ecom_BillTo_Postal_Street_Line2'}\",
		\"$frm{'Ecom_BillTo_Telecom_Phone_Number'}\",
		\"$frm{'Ecom_ShipTo_Online_Email'}\",
		\"$frm{'Ecom_ShipTo_Postal_City'}\",
		\"$frm{'Ecom_ShipTo_Postal_Company'}\",
		\"$frm{'Ecom_ShipTo_Postal_CountryCode'}\",
		\"$frm{'Ecom_ShipTo_Postal_Name_First'}\",
		\"$frm{'Ecom_ShipTo_Postal_Name_Last'}\",
		\"$frm{'Ecom_ShipTo_Postal_Name_Middle'}\",
		\"$frm{'Ecom_ShipTo_Postal_Name_Prefix'}\",
		\"$frm{'Ecom_ShipTo_Postal_Name_Suffix'}\",
		\"$frm{'Ecom_ShipTo_Postal_PostalCode'}\",
		\"$frm{'Ecom_ShipTo_Postal_Region'}\",
		\"$frm{'Ecom_ShipTo_Postal_StateProv'}\",
		\"$frm{'Ecom_ShipTo_Postal_Street_Line1'}\",
		\"$frm{'Ecom_ShipTo_Postal_Street_Line2'}\",
		\"$frm{'Ecom_ShipTo_Telecom_Phone_Number'}\",
		\"$frm{'Ecom_ShipTo_Postal_Type'}\",
		\"$frm{'Check_Account_Number'}\",
		\"$frm{'Check_Account_Type'}\",
		\"$frm{'Check_Bank_Address'}\",
		\"$frm{'Check_Bank_Name'}\",
		\"$frm{'Check_Customer_Organization_Type'}\",
		\"$frm{'Check_Drivers_License_DOB'}\",
		\"$frm{'Check_Drivers_License_Num'}\",
		\"$frm{'Check_Drivers_License_ST'}\",
		\"$frm{'Check_Fraction_Number'}\",
		\"$frm{'Check_Holder_Name'}\",
		\"$frm{'Check_Number'}\",
		\"$frm{'Check_Routing_Number'}\",
		\"$frm{'Check_Tax_ID'}\",
		\"$frm{'Ecom_Payment_Card_ExpDate_Day'}\",
		\"$frm{'Ecom_Payment_Card_ExpDate_Month'}\",
		\"$frm{'Ecom_Payment_Card_ExpDate_Year'}\",
		\"$frm{'Ecom_Payment_Card_FromDate_Month'}\",
		\"$frm{'Ecom_Payment_Card_FromDate_Year'}\",
		\"$frm{'Ecom_Payment_Card_IssueNumber'}\",
		\"$frm{'Ecom_Payment_Card_Name'}\",
		\"Not Stored\",
		\"$frm{'Ecom_Payment_Card_Type'}\")\;
		~;

	# qry => mofinvoices
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);
	# get the recID to store
	$recid = $dbh->{'mysqlpp_insertid'};

	# no more insertid needed :  $recid & usrid are fixed
	# (3) <mofdata> table structure
	$sql = qq~
	INSERT INTO mofdata (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID,
		Adjusted_Tax_Amount,
		Adjusted_Tax_Amount_After,
		Adjusted_Tax_Amount_Before,
		Allow_Shipping,
		Allow_Tax,
		Combined_Discount,
		Combined_SHI,
		Compute_Coupons,
		Compute_Insurance,
		Compute_Shipping_Method,
		Coupon_Affiliate_Rate,
		Coupon_Cust_Rate,
		Coupon_Discount,
		Coupon_Discount_myNumber,
		Coupon_Discount_Status,
		Deposit_Amount,
		Domestic_City,
		Final_Amount,
		Final_ConvertAmount,
		Format_Deposit_Amount,
		Handling,
		Handling_Status,
		Initial_Taxable_Amount,
		input_cyber_permission,
		input_payment_options,
		input_shipping_info,
		Insurance,
		Insurance_Amt_Override,
		Insurance_Line_Override,
		Insurance_Status,
		Is_Domestic,
		previouspage,
		Primary_Discount,
		Primary_Discount_Line_Override_Backend,
		Primary_Discount_Status,
		Primary_Price,
		Primary_Products,
		Remaining_Balance,
		resubmit_info,
		Shipping_Amount,
		Shipping_Amt_Override,
		Shipping_Line_Override,
		Shipping_Message,
		Shipping_Method_Description,
		Shipping_Method_Name,
		Shipping_Status,
		Sub_Coupon_Discount,
		Sub_Final_Discount,
		Sub_Primary_Discount,
		Sub_SHI,
		Tax_Amount,
		Tax_Discount_Ratio,
		Tax_Exempt_Status,
		Tax_Line_Override,
		Tax_Message,
		Tax_Rate,
		Tax_Rule,
		Tax_Rule_Exceptions,
		Total_Weight,
		Use_Domestic,
		Ecom_ReceiptTo_Online_Email,
		Ecom_ReceiptTo_Postal_City,
		Ecom_ReceiptTo_Postal_Company,
		Ecom_ReceiptTo_Postal_CountryCode,
		Ecom_ReceiptTo_Postal_Name_First,
		Ecom_ReceiptTo_Postal_Name_Last,
		Ecom_ReceiptTo_Postal_Name_Middle,
		Ecom_ReceiptTo_Postal_Name_Prefix,
		Ecom_ReceiptTo_Postal_Name_Suffix,
		Ecom_ReceiptTo_Postal_PostalCode,
		Ecom_ReceiptTo_Postal_Region,
		Ecom_ReceiptTo_Postal_StateProv,
		Ecom_ReceiptTo_Postal_Street_Line1,
		Ecom_ReceiptTo_Postal_Street_Line2,
		Ecom_ReceiptTo_Telecom_Phone_Number,
		special_instructions
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\",
		\"$frm{'Adjusted_Tax_Amount'}\",
		\"$frm{'Adjusted_Tax_Amount_After'}\",
		\"$frm{'Adjusted_Tax_Amount_Before'}\",
		\"$frm{'Allow_Shipping'}\",
		\"$frm{'Allow_Tax'}\",
		\"$frm{'Combined_Discount'}\",
		\"$frm{'Combined_SHI'}\",
		\"$frm{'Compute_Coupons'}\",
		\"$frm{'Compute_Insurance'}\",
		\"$frm{'Compute_Shipping_Method'}\",
		\"$frm{'Coupon_Affiliate_Rate'}\",
		\"$frm{'Coupon_Cust_Rate'}\",
		\"$frm{'Coupon_Discount'}\",
		\"$frm{'Coupon_Discount_myNumber'}\",
		\"$frm{'Coupon_Discount_Status'}\",
		\"$frm{'Deposit_Amount'}\",
		\"$frm{'Domestic_City'}\",
		\"$frm{'Final_Amount'}\",
		\"$frm{'Final_ConvertAmount'}\",
		\"$frm{'Format_Deposit_Amount'}\",
		\"$frm{'Handling'}\",
		\"$frm{'Handling_Status'}\",
		\"$frm{'Initial_Taxable_Amount'}\",
		\"$frm{'input_cyber_permission'}\",
		\"$frm{'input_payment_options'}\",
		\"$frm{'input_shipping_info'}\",
		\"$frm{'Insurance'}\",
		\"$frm{'Insurance_Amt_Override'}\",
		\"$frm{'Insurance_Line_Override'}\",
		\"$frm{'Insurance_Status'}\",
		\"$frm{'Is_Domestic'}\",
		\"$frm{'previouspage'}\",
		\"$frm{'Primary_Discount'}\",
		\"$frm{'Primary_Discount_Line_Override_Backend'}\",
		\"$frm{'Primary_Discount_Status'}\",
		\"$frm{'Primary_Price'}\",
		\"$frm{'Primary_Products'}\",
		\"$frm{'Remaining_Balance'}\",
		\"$frm{'resubmit_info'}\",
		\"$frm{'Shipping_Amount'}\",
		\"$frm{'Shipping_Amt_Override'}\",
		\"$frm{'Shipping_Line_Override'}\",
		\"$frm{'Shipping_Message'}\",
		\"$frm{'Shipping_Method_Description'}\",
		\"$frm{'Shipping_Method_Name'}\",
		\"$frm{'Shipping_Status'}\",
		\"$frm{'Sub_Coupon_Discount'}\",
		\"$frm{'Sub_Final_Discount'}\",
		\"$frm{'Sub_Primary_Discount'}\",
		\"$frm{'Sub_SHI'}\",
		\"$frm{'Tax_Amount'}\",
		\"$frm{'Tax_Discount_Ratio'}\",
		\"$frm{'Tax_Exempt_Status'}\",
		\"$frm{'Tax_Line_Override'}\",
		\"$frm{'Tax_Message'}\",
		\"$frm{'Tax_Rate'}\",
		\"$frm{'Tax_Rule'}\",
		\"$frm{'Tax_Rule_Exceptions'}\",
		\"$frm{'Total_Weight'}\",
		\"$frm{'Use_Domestic'}\",
		\"$frm{'Ecom_ReceiptTo_Online_Email'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_City'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Company'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_CountryCode'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Name_First'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Name_Last'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Name_Middle'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Name_Prefix'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Name_Suffix'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_PostalCode'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Region'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_StateProv'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Street_Line1'}\",
		\"$frm{'Ecom_ReceiptTo_Postal_Street_Line2'}\",
		\"$frm{'Ecom_ReceiptTo_Telecom_Phone_Number'}\",
		\"$frm{'special_instructions'}\")\;
		~;

	# qry => mofdata
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
 	&dbQry($sql);

	# (4) <mofcustom> table structure
	$sql = qq~
	INSERT INTO mofcustom (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID,
		customA_CompanyName,
		customB_Address,
		customC_City,
		customD_State,
		customE_Country,
		customF_Zip,
		customG_PhoneNumber,
		customH_PhoneNumber,
		customI_AddToMail,
		customJ_StableEmail,
		customK_ReferredBy,
		customL_Other,
		customM_AnotherList,
		customN_OneMore
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\",
		\"$frm{'customA_CompanyName'}\",
		\"$frm{'customB_Address'}\",
		\"$frm{'customC_City'}\",
		\"$frm{'customD_State'}\",
		\"$frm{'customE_Country'}\",
		\"$frm{'customF_Zip'}\",
		\"$frm{'customG_PhoneNumber'}\",
		\"$frm{'customH_PhoneNumber'}\",
		\"$frm{'customI_AddToMail'}\",
		\"$frm{'customJ_StableEmail'}\",
		\"$frm{'customK_ReferredBy'}\",
		\"$frm{'customL_Other'}\",
		\"$frm{'customM_AnotherList'}\",
		\"$frm{'customN_OneMore'}\")\;
		~;

	# qry => mofcustom
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);

	# (5) <moforders> table structure
	# Item ---------------- Item stripped of any pseudo html
	# ItemBlock -------- Item stored as html
	# Description ------ Description stripped of any pseudo html
	# Option 1.. 15 ---  Possible Optional input seperated into fields 1 - 15
	# DescBlock ------ Description stored as html

	foreach (@orders) {
  	($qty,$ibk,$dbk,$price,$ship,$tax) = split (/$delimit/,$_);

	# strip [pseudo] html
	$itm = $ibk;
	$itm =~ s/\[([^\]]|\n)*\]//g;
	$itm =~ s/\[//g;
	$itm =~ s/\]//g;

	# make html
	$ibk =~ s/\[/</g;
	$ibk =~ s/\]/>/g;
	
	# strip [pseudo] html & split Options
	$desc = $dbk;
	$desc =~ s/\[([^\]]|\n)*\]//g;
	$desc =~ s/\[//g;
	$desc =~ s/\]//g;
	$desc =~ s/::/ : /g;
 	($desc,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$f10,$f11,$f12,$f13,$f14,$f15) = split (/\|/,$desc);

	# make html
	$dbk =~ s/\[/</g;
	$dbk =~ s/\]/>/g;

	$sql = qq~
	INSERT INTO moforders (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID,
		Quantity,
		Item,
		ItemBlock,
		Description,
		DescBlock,
		Price,
		Shipping,
		Tax,
		Option1,
		Option2,
		Option3,
		Option4,
		Option5,
		Option6,
		Option7,
		Option8,
		Option9,
		Option10,
		Option11,
		Option12,
		Option13,
		Option14,
		Option15
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\",
		\"$qty\",
		\"$itm\",
		\"$ibk\",
		\"$desc\",
		\"$dbk\",
		\"$price\",
		\"$ship\",
		\"$tax\",
		\"$f1\",
		\"$f2\",
		\"$f3\",
		\"$f4\",
		\"$f5\",
		\"$f6\",
		\"$f7\",
		\"$f8\",
		\"$f9\",
		\"$f10\",
		\"$f11\",
		\"$f12\",
		\"$f13\",
		\"$f14\",
		\"$f15\")\;
		~;

	# qry => moforders (loop)
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);
	}

	# (6) <mofipn> table structure
	$sql = qq~
	INSERT INTO mofipn (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\")\;
		~;

	# qry => mofipn
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);

	# (7) <mofbofa> table structure
	$sql = qq~
	INSERT INTO mofbofa (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\")\;
		~;

	# qry => mofbofa
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);

	# (8) <mofauthnet> table structure
	$sql = qq~
	INSERT INTO mofauthnet (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\")\;
		~;

	# qry => mofauthnet
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);

	# (9) <mofabuse> table structure
	$sql = qq~
	INSERT INTO mofabuse (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID,
		REMOTE_ADDR,
		REMOTE_HOST,
		REMOTE_PORT,
		HTTP_HOST,
		SERVER_NAME,
		SERVER_ADDR,
		SERVER_PORT
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\",
		\"$ENV{'REMOTE_ADDR'}\",
		\"$ENV{'REMOTE_HOST'}\",
		\"$ENV{'REMOTE_PORT'}\",
		\"$ENV{'HTTP_HOST'}\",
		\"$ENV{'SERVER_NAME'}\",
		\"$ENV{'SERVER_ADDR'}\",
		\"$ENV{'SERVER_PORT'}\")\;
		~;

	# qry => mofabuse
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);

	# (10) <mofupdates> table structure
	$sql = qq~
	INSERT INTO mofupdates (
		recID,
		usrID,
		global_InvoiceNumber,
		OrderID,
		InfoID,
		myLogin,
		myPass,
		myShip,
		myShipStmp,
		myTracking,
		myStatus,
		myDownload,
		myReg,
		myDate,
		myTime,
		myStmp1,
		myStmp2,
		myStmp3,
		myRSA,
		myNotes
	) VALUES (
		\"$recid\",
		\"$usrid\",
		\"$frm{'global_InvoiceNumber'}\",
		\"$frm{'OrderID'}\",
		\"$frm{'InfoID'}\",
		\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",
		\"MOFcart v2.5 mySQL Updates Table\")\;
		~;

	# qry => mofupdates
	$sql =~ s/\n//g;
	$sql =~ s/\r//g;
	$sql =~ s/\t//g;
	&dbQry($sql);

	# close
	&dbClose();
	}


# sub routines
# sub routines

# connect to DB
sub dbConnect {
	unless (
		$dbh = DBI->connect("dbi:mysqlPP:database=$dbName;host=$dbHost",
		"$dbUser","$dbPswd",
		{ RaiseError => 0 }		
		)) {
	        my $errmsg = $DBI::errstr;
		$errmsg =~ s/\n//g;
		$errmsg =~ s/\r//g;
		&dbErr("$errmsg") if ($log_sql_errs);
		$errmsg = qq~
		<li>DataBase Error, mySQL Error Reason :
		<li>$errmsg ~;
		&ErrorMessage($errmsg);
		}
	}

# do query
sub dbQry {
	my ($sql) = @_;
	$sth = $dbh->prepare($sql);
	unless ($sth->execute) {
	        my $errmsg = $DBI::errstr;
		$errmsg =~ s/\n//g;
		$errmsg =~ s/\r//g;
		&dbClose();
		&dbErr("$errmsg") if ($log_sql_errs);
		&ErrorMessage("Unable to execute mySQL update: $errmsg");
		}
	}

# make Pswd
sub genPsw {
	# genPsw idea by Scott Stolpmann 2-19-2000
	# Alpha-Numerical Generator
	my ($salt) = @_;
	my $l,$c;
	# psw length $i<6
	for($i=0; $i<6; $i++){ 
	$l =int(rand 3) +1;
	$c =int(rand 7) +50 if ($l ==1);
	$c =int(rand 25) +65 if ($l ==2);
	$c =int(rand 25) +97 if ($l ==3);
	$c =chr($c);
	$myPsw .= $c;
	}
	# using one way unix crypt to store usr : psw
	# psw is generated as random and (crypt)ed as psw,myUsr
	# Note: if myUsr changes in dB, the myPsw must be re-crypted with new SALT
	# Also, the initial SALT is global_mail_customer_addr
	# If that is not present, then it is global_InvoiceNumber
	$cryptPsw = crypt($myPsw,$salt); 
	return ($myPsw,$cryptPsw);
	}

# err log file
sub dbErr {
	my ($err) = @_;
	unless (open (ERR,">>$errFilePath") ) { 
		&ErrorMessage("LOG FILE ERROR: $errFilePath <br> $err");
		}
	print ERR "$ENV{'REMOTE_ADDR'}\t$sqlDate\t$Time\t$err\n";
	close(ERR);
	}

# close db
sub dbClose {
	$sth->finish;
	$dbh->disconnect;
	}



# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;

