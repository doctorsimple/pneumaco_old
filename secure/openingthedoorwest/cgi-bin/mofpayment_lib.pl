# Merchant OrderForm v1.53 Payment Processing Library, UPDATED 9/15/2000, UPDATED 10/01/2000
# Copyright August 2000
# Owner: http://www.io.com/~rga/
# Mailto: rga@io.com
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

# CREDIT CARD VALIDATION WRITTEN BY_________________________
# Credit Card Validation Solution, version 3.6 -- 25 May 2000
# Copyright 2000 - http://www.AnalysisAndSolutions.com/code/
# The Analysis and Solutions Company - info@AnalysisAndSolutions.com
# The CC verification uses 4 digit ranges current as of October 1999
# If any other Ranges become available then this routine is out of date

# THIS IS THE PAYMENT PROCESSING LIBRARY FILE
# THIS IS THE PAYMENT PROCESSING LIBRARY FILE

# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES
# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES



	# CHECK ALLOWED DOMAINS
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
		$ErrMsg=$ErrMsg . "<a href=\"$_\">$_</a><br>";
		}

		$ErrMsg=$ErrMsg . "<p>Contact Web Site Developer about this Error <br>";

		&ErrorMessage($ErrMsg);
		}

	}




	# GET INPUT
	# GET INPUT

sub ProcessPost {

	@orders = ();
	$card_check = 0;
	$check_check = 0;

	my ($name, $value, $line);
	my ($key, $val);
	my ($strBill, $strShip);

	@UsingInfoFields = ();
	%MissingInfoFields = ();

	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);

	foreach $pair (@pairs) {

		($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ tr/"/ /;

		push (@orders, $value) if ($name eq "order");
		$frm{$name} = $value;
    		}

		unless (scalar(@orders) && $frm{'Primary_Price'} && $frm{'Primary_Products'}) {
		&IllegalPost;
		}


		# ADJUST %FRM ARRAY
		# ADJUST %FRM ARRAY	

		# prevent duplication
		# since %frm is used to populate resubmit POST

	delete ($frm{'order'});
	delete ($frm{'x'});
	delete ($frm{'y'});

		# strip line endings from comments

	$frm{'special_instructions'} =~ tr/\n//d;

		# Use ShipTo for BillTo info
		# Uses info only if configured to use for BillTo


	if ($frm{'input_shipping_info'} eq "YES") {

	 	while (($key, $val) = each (%billing_info_fields)) {
		
			$strBill = 	substr ($key,11);
			$strShip = "Ecom_ShipTo" . $strBill;

			unless ($frm{$key}) {
			$frm{$key} = $frm{$strShip} if (exists($frm{$strShip}));	
			}
	
		 }

	}


	&BuildPaymentOptions;

		# Set flag if Method selected is CC 
		# Must be after arrays populated in BuildPaymentOptions
		
	foreach $_ (@credit_card_list) { 
	$card_check++ if ($frm{'input_payment_options'} eq $_);
	}

		# if using CC capture Card Type

	$frm{'Ecom_Payment_Card_Type'} = "" unless ($card_check);
	$frm{'Ecom_Payment_Card_Type'} = $frm{'input_payment_options'} if ($card_check);


		# Set flag if method selected is CHECK (Online Checking)

	$check_check++ if ($frm{'input_payment_options'} eq "CHECK");


		# Run cc verify if enabled and CC Type selected
		# And if CC Number field enabled in configs

	if (exists ($credit_card_fields{'Ecom_Payment_Card_Number'})) {

		if ($card_check && $enable_cc_verify) {

		$CCNumber = ($frm{'Ecom_Payment_Card_Number'});
		$cc_approved = &CCValidationSolution;

			unless ($cc_approved) {
			$MissingInfoFields{'Ecom_Payment_Card_Number'} = "Incomplete";
			}

		}

	}


	&CheckFieldsNeeded;
	&CheckUsingInfoFields;

	# If cc verify has type error change to Incomplete
	if ($cc_type_error) {$MissingInfoFields{'input_payment_options'} = "Incomplete"}

	}
	




	# SET DATE
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
	# CHECK FOR COOKIE

sub CheckCookie {

	# IDENTIFY MOF CART COOKIES
	# Positive Value is if $cookieOrderID has Value
	# Positive Value is if $cookieInfoID has Value

	$cookies = $ENV{'HTTP_COOKIE'};
	@cookie = split (/;/, $cookies);

    	foreach $line (@cookie) {
   	($name, $value) = split(/=/, $line);

	$cookieOrderID=$value if ($name =~ /\b$cookiename_OrderID\b/);
	$cookieInfoID=$value if ($name =~ /\b$cookiename_InfoID\b/);

	}

  return ($cookieOrderID, $cookieInfoID);
  }




	# SET NEW COOKIE
	# SET NEW COOKIE

sub ExpireCookie {

	# Always print the cookie before the Content-Type header

	my ($name_for_cookie) = @_;
	print "Set-Cookie: $name_for_cookie=$ID;expires=Sat, 1-Jan-2000 12:12:12 GMT \n";	

  }





	# DELETE CART FILE
	# DELETE CART FILE

sub DeleteCartFile {

	my ($FileNumber) = @_;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;

	my ($line);

	$path = $datadirectory . $FileNumber . "\.$data_extension";

	unless (open (FILE, ">$path") ) { 

		$ErrMsg = "Unable to Delete Orders Data File: $FileNumber";
		&ErrorMessage($ErrMsg);
		}
	
	close(FILE);
	}


	



	# LOG AFFILIATE ACTIVITY
	# LOG AFFILIATE ACTIVITY
	
sub LogAffiliateActivity {

	my ($coupon_number) = @_;
	my ($CreditAmount);
	my ($RepCode, $RepRate, $RepAmt);
	my ($i1,$i2,$i3,$i4,$i5,$i6,$i7,$i8,$i9,$i10,$i11,$i12,$i13,$i14);


		# obtain Rep Number for this coupon
		# obtain Rep Number for this coupon

	unless (open (IFILE, "$infofile_path") ) { 
		$ErrMsg = "Unable to Access Affiliate Information File";
		&ErrorMessage($ErrMsg);
		}
	
		flock (IFILE,2) if ($lockfiles);
  		@ALLINFO = <IFILE>;
  		close (IFILE);
		chop (@ALLINFO);

		foreach (@ALLINFO) {

  		($i1,$i2,$i3,$i4,$i5,$i6,$i7,$i8,$i9,$i10,$i11,$i12,$i13,$i14) = split (/\|/, $_);
		
			if ($i3 == $coupon_number) {
			
				$RepCode = $i14;
				last;
			}

		}


		# obtain Rep rates
		# obtain Rep rates

	unless (open (IFILE, "$repinfo_path") ) { 
		$ErrMsg = "Unable to Access Representative Information File";
		&ErrorMessage($ErrMsg);
		}

		flock (IFILE,2) if ($lockfiles);
	  	@ALLINFO = <IFILE>;
  		close (IFILE);

		foreach (@ALLINFO) {

  		($i1,$i2,$i3,$i4,$i5,$i6,$i7,$i8,$i9,$i10,$i11,$i12,$i13,$i14) = split (/\|/, $_);
	
			if ($RepCode == $i2) {

				$RepRate = $i3;
				last;
			}	

		}


	
		# Computations for both Affiliate and Representative earnings 
		# are on Net Amount of the Customer's purchase
		# If you want to use the Gross then change the computation vars below
		# The log stores the Rates in raw format, the usrmgt.cgi will convert to percent

		if ($RepRate) {

			$RepAmt = ($frm{'Final_Amount'} * $RepRate);

			} else {

			$RepRate = 0;
			$RepAmt = 0;
	
			}


		if ($frm{'Coupon_Affiliate_Rate'} > 0) {
			$CreditAmount = ($frm{'Final_Amount'} * $frm{'Coupon_Affiliate_Rate'});
	
			} else {
			$CreditAmount = 0;
			}

			
			$RepAmt = sprintf "%.2f", $RepAmt;
  			$CreditAmount = sprintf "%.2f", $CreditAmount;


		# transaction logging
		# transaction logging

	unless (open (AFILE, ">>$activityfile_path") ) { 
		$ErrMsg = "Unable to Access Affiliate Tracking Log";
		&ErrorMessage($ErrMsg);
		}

		flock (AFILE, 2) if ($lockfiles);

		$_ = $ShortDate;

		$_ = $_ . "\|";
		$_ = $_ . $Time;

		$_ = $_ . "\|";
		$_ = $_ . $InvoiceNumber;

		$_ = $_ . "\|";
		$_ = $_ . $frm{'Final_Amount'};

		$_ = $_ . "\|";
		$_ = $_ . $coupon_number;

		$_ = $_ . "\|";
		$_ = $_ . $frm{'Coupon_Affiliate_Rate'};

		$_ = $_ . "\|";
		$_ = $_ . $CreditAmount;

		$_ = $_ . "\|";
		$_ = $_ . $mail_customer_addr;

		$_ = $_ . "\|\|\|";

		$_ = $_ . $RepCode;
		$_ = $_ . "\|";

		$_ = $_ . $RepRate;
		$_ = $_ . "\|";

		$_ = $_ . $RepAmt;

		$_ = $_ . "\|\|";

	print AFILE "$_\n";

	close(AFILE);

	}




	# GET INVOIVE NUMBER
	# GET INVOICE NUMBER

sub GetInvoiceNumber {

 	$InvoiceNumber;

	unless (open (NUMBER, "$numberfile") ) { 
		
		$ErrMsg = "Unable to Read Invoice Number File";
		&ErrorMessage($ErrMsg);
		}

	flock (NUMBER,2) if ($lockfiles);

	$InvoiceNumber = <NUMBER>;
	$InvoiceNumber++;

	unless (open (NUMBER, ">$numberfile") ) { 

		$ErrMsg = "Unable to Write To Invoice Number File";
		&ErrorMessage($ErrMsg);
		}

	print NUMBER "$InvoiceNumber";
	close (NUMBER);
	flock (NUMBER,8) if ($lockfiles);

	return $InvoiceNumber;

	}




	# GET TEMPLATE FILE
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





	# BUILD PAYMENT OPTIONS
	# BUILD PAYMENT OPTIONS

sub BuildPaymentOptions {

	# If you plan on customizing any of the Payment Method behavior area
	# Then you must make sure all updated configurations are formatted here

	# If you need to add a special business cc type then you'll need to customize
	# this BuildPaymentOptions ability to recognize a cc type other than the Master List

	# Example: To add-subtract a CC Type
	# Example: Declare/Undeclare the Type in %payment_options_list
	# Example: Declare/Undeclare the Type in @credit_card_list <configs>
	# Example: Declare/Undeclare the Type in @payment_options_order
	# Important: All three lists in this example must match
	# Important: else your Payment Methods drop box will behave incorrectly

	# Note: If you want to add another Payment Method like COD
	# Note: Then you have to follow out all the single option configuration possibilities
	# Note: You'll also need to follow suite w/ CC, Online Checking and how those fields
		  # A. Are declared, ordered, built 
		  # B. Are Flagged in the ProcessPost 
		  # C. Are declared in @UsingInfoFields
		  # D. Are Flagged in %MissingInfoFields
		  # E. Have Fields set up to display on Payment Info Page
		  # F. Updated how Cyber Permission works
		

	my ($key, $val);
	my ($msg_check, $msg_mail);


	@payment_options_order = ();
	%payment_options_list = ();
	%payment_options_desc = ();

	


	# Build the %payment_options_list for each CC type
	# CC payment options are dependent on @credit_card_list <configs>
	# Build them into the options_list only if being used as per <configs>

	if (scalar(keys(%credit_card_fields))) {
		
		foreach (@credit_card_list) {

		$payment_options_list{'VISA'} = "Visa Credit Card" if ($_ eq 'VISA');
		$payment_options_list{'MAST'} = "Mastercard Credit Card" if ($_ eq 'MAST');
		$payment_options_list{'AMER'} = "American Express Credit Card" if ($_ eq 'AMER');
		$payment_options_list{'DISC'} = "Discover Credit Card" if ($_ eq 'DISC');
		$payment_options_list{'DINE'} = "Diners Club Credit Card" if ($_ eq 'DINE');
		$payment_options_list{'JCB'} = "JCB Card" if ($_ eq 'JCB');
		$payment_options_list{'CART'} = "Carte Blache" if ($_ eq 'CART');
		$payment_options_list{'AUST'} = "Australian BankCard" if ($_ eq 'AUST');
		
		}	

		}


	if (scalar(keys(%checking_account_fields))) {
		
		$payment_options_list{'CHECK'} = "Online Checking Draft";
		}


	if ($mail_or_fax_field) {

		$payment_options_list{'MAIL'} = "Mailing or Faxing Payment";
		}


	if ($enable_paypal) {

		$payment_options_list{'PAYPAL'} = "Using PayPal Service";		
		}



		# What order to display in drop box ?
		# Uses the order of @credit_card_list for cc types
		# then adds Check and Mail methods to end of order


			foreach (@credit_card_list) {
			push (@payment_options_order, $_);
			}

			push(@payment_options_order, 'CHECK');

			push(@payment_options_order, 'MAIL');

			push(@payment_options_order, 'PAYPAL');



		# What message to display if only ONE Payment Method is defaulted
		# This means that only one method is allowed
		# This list must include all possible methods that can default 
		# as a single method restricted to only one payment method
		# Note: Credit Cards should not do this, unless you really want
		# Note: to restrict method to only "Mastercard" for example
		# Note: In which case you would need to put it's message here
		# Note: This is what displays when the Drop Box doesn't


		$msg_check = "Payment by Online Checking is the only Method Available. ";
		$msg_check = $msg_check . "Please complete the required Checking Account ";
		$msg_check = $msg_check . "Information below.";

		$msg_mail = "We are not accepting any Online Payment Methods at this time. ";
		$msg_mail = $msg_mail . "You will be able to Print or Save to Disk your Final ";
		$msg_mail = $msg_mail . "Invoice.  Then you should Mail the Invoice with your payment ";
		$msg_mail = $msg_mail . "or Fax it in with your Payment Information.";

		$msg_paypal = "Payment via the PayPal Web Accept system is the only Method Available. ";
		$msg_paypal = $msg_paypal . "Please continue with Checkout and you will be provided ";
		$msg_paypal = $msg_paypal . "with a final button to continue on to the PayPal system. ";
		$msg_paypal = $msg_paypal . "Please note that PayPal is for US residents only.";


		# Note: If payment method eq "MAIL" a form will print on the final invoice
		# Note: So that CC, or other info can be filled out and sent in.


	%payment_options_desc = (
		
		'CHECK', $msg_check,
		'MAIL', $msg_mail,
		'PAYPAL', $msg_paypal);


	return (%payment_options_list, 
		  %payment_options_desc, 
		  @payment_options_order);


	}






	# MAKE LIST OF FIELDS NEEDED
	# MAKE LIST OF FIELDS NEEDED

sub CheckFieldsNeeded {

	my ($use_perm) = 0;

	# Anything requiring user input must be declared in this list 
	# Even if it will not be validated
	# MOF creates this list to know what should be expected from the config settings

	# Any of the 14 BillTo fields being used ?
	while (($key, $val) = each (%billing_info_fields)) {
		push (@UsingInfoFields, $key) if ($val);	
		}

	# Any of the 14 ReceiptTo fields being used ?
	while (($key, $val) = each (%receipt_info_fields)) {
		push (@UsingInfoFields, $key) if ($val);	
		}

	# Any of the 6 Credit Card fields being used ?
	while (($key, $val) = each (%credit_card_fields)) {
		push (@UsingInfoFields, $key) if ($val);	
		}

	# Any of the 7 Checking Account fields being used ?
	while (($key, $val) = each (%checking_account_fields)) {
		push (@UsingInfoFields, $key) if ($val);	
		}

	
	# Set up Payment Methods Field
	# There is no switch in configs for this
	# It's always a missing field when entering Payment Info the first time

		push (@UsingInfoFields, 'input_payment_options');

	
	# Over ride cyber permission if Mailing or Faxing payment
	# Don't need online authorization for this

	if ($enable_cyber_permission) {

		$use_perm++ if ($frm{'input_payment_options'} eq "MAIL");
		$use_perm++ if ($frm{'input_payment_options'} eq "PAYPAL");

		unless ($use_perm) {
		push (@UsingInfoFields,'input_cyber_permission');
		}

	}


	return @UsingInfoFields;
	}




	# CHECK WHAT FIELDS ARE COMPLETE
	# CHECK WHAT FIELDS ARE COMPLETE	

sub CheckUsingInfoFields {

	my ($use_perm) = 0;

	# This checks what info we actually have against what info is expected/needed
	# The list of what is expected is already created 

	# Checking required input
	# Checking required input	

	foreach $_ (@UsingInfoFields) {


		# What BillTo fields required ?
		# What BillTo fields required ?

		if ($billing_info_fields{$_}) {
	
			unless (length($frm{$_}) >= ($billing_info_fields{$_})) {

			$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
			$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);

			}

		}



		# What ReceiptTo fields required ?
		# What ReceiptTo fields required ?

		if ($receipt_info_fields{$_}) {
	
			unless (length($frm{$_}) >= ($receipt_info_fields{$_})) {

			$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
			$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);

			}

		}



		# What Credit Card fields required ?
		# But only if a CC Method is selected

		if ($card_check) {

			if ($credit_card_fields{$_}) {
	
				unless (length($frm{$_}) >= ($credit_card_fields{$_})) {

				$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
				$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);

				}

			}

		}


		# What Checking Account fields required ?
		# But only if Online Checking Method is selected

		if ($frm{'input_payment_options'} eq "CHECK") {

			if ($checking_account_fields{$_}) {
	
				unless (length($frm{$_}) >= ($checking_account_fields{$_})) {

				$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
				$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);

				}

			}
		
		}



	} 

	# End foreach in @UsingInfoFields list
	# End foreach in @UsingInfoFields list


		# Payment Method Input is Required by script
		# This field has No switch in the configurations
		# Always Null when first entering Payment script
		# If configs for single option default will be hidden value
		# Else we will check for user selection from Drop Box
		# This insures that at least the first stop for Payment Info is always true

		unless ($frm{'input_payment_options'}) {
		$MissingInfoFields{'input_payment_options'} = "Missing";
		}


		
		# Cyber permission is required if enabled
		# Unless Mailing or Faxing in payment

	if ($enable_cyber_permission) {

		$use_perm++ if ($frm{'input_payment_options'} eq "MAIL");
		$use_perm++ if ($frm{'input_payment_options'} eq "PAYPAL");

		unless ($use_perm) {

			unless ($frm{'input_cyber_permission'} eq "APPROVED") {
			$MissingInfoFields{'input_cyber_permission'} = "Missing";
			}

		}

	}


	# validate any Email addr whether required or not
	# to prevent sendmail from crashing script w/ bogus addr

	if ($frm{'Ecom_BillTo_Online_Email'}) {
	unless ($frm{'Ecom_BillTo_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/) {
      $MissingInfoFields{'Ecom_BillTo_Online_Email'} = "Incomplete";}	
	}

	if ($frm{'Ecom_ReceiptTo_Online_Email'}) {
	unless ($frm{'Ecom_ReceiptTo_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/) {
      $MissingInfoFields{'Ecom_ReceiptTo_Online_Email'} = "Incomplete";}	
	}

	return %MissingInfoFields;
	}





	# VALIDATE BILLTO INFO FIELDS
	# VALIDATE BILLTO INFO FIELDS

sub ValidateBillingInfo {

	my ($v) = @_;
	my ($mv);

	if ($MissingInfoFields{$v} eq "Missing") {

		if ($frm{'resubmit_info'}) {
		$mv = $info_missing;
		} else {
		$mv = $info_required;
		}

	} elsif ($MissingInfoFields{$v} eq "Incomplete") {
	$mv = $info_incomplete;

	} else {

		if ($billing_info_fields{$v}) {
		$mv = $info_okay;
		} else {
		$mv = "<br>";
		}

	}

	return $mv;
	}





	# VALIDATE RECEIPT TO INFO FIELDS
	# VALIDATE RECEIPT TO INFO FIELDS

sub ValidateReceiptInfo {

	my ($v) = @_;
	my ($mv);

	if ($MissingInfoFields{$v} eq "Missing") {

		if ($frm{'resubmit_info'}) {
		$mv = $info_missing;
		} else {
		$mv = $info_required;
		}

	} elsif ($MissingInfoFields{$v} eq "Incomplete") {
	$mv = $info_incomplete;

	} else {

		if ($receipt_info_fields{$v}) {
		$mv = $info_okay;
		} else {
		$mv = "<br>";
		}

	}

	return $mv;
	}





	# VALIDATE CREDIT CARD FIELDS
	# VALIDATE CREDIT CARD FIELDS

sub ValidateCreditCardInfo {

	my ($v) = @_;
	my ($mv);

	# Only validate if a CC Method is selected	
	# Only validate if a CC Method is selected	

	if ($card_check) {

		if ($MissingInfoFields{$v} eq "Missing") {

			if ($frm{'resubmit_info'}) {
			$mv = $info_missing;
			} else {
			$mv = $info_required;
			}

		} elsif ($MissingInfoFields{$v} eq "Incomplete") {
		$mv = $info_incomplete;

		} else {

			if ($credit_card_fields{$v}) {
			$mv = $info_okay;
			} else {
			$mv = "<br>";
			}

		}

	} else {
	$mv = "<br>";
	}


	return $mv;
	}




	# VALIDATE CHECKING ACCOUNT FIELDS
	# VALIDATE CHECKING ACCOUNT FIELDS

sub ValidateCheckingInfo {

	my ($v) = @_;
	my ($mv);


	# Only validate if Online Checking Method is selected	
	# Only validate if Online Checking Method is selected	

	if ($frm{'input_payment_options'} eq "CHECK") {

		if ($MissingInfoFields{$v} eq "Missing") {

			if ($frm{'resubmit_info'}) {
			$mv = $info_missing;
			} else {
			$mv = $info_required;
			}

		} elsif ($MissingInfoFields{$v} eq "Incomplete") {
		$mv = $info_incomplete;

		} else {

			if ($checking_account_fields{$v}) {
			$mv = $info_okay;
			} else {
			$mv = "<br>";
			}

		}

	} else {
	$mv = "<br>";
	}


	return $mv;
	}





	# VALIDATE INPUT PAYMENT BOX
	# VALIDATE INPUT PAYMENT BOX

sub ValidateInputOptions {

	my ($v) = @_;
	my ($mv);

	if ($MissingInfoFields{$v} eq "Missing") {

		if ($frm{'resubmit_info'}) {
		$mv = $info_missing;
		} else {
		$mv = $info_required;
		}

	} elsif ($MissingInfoFields{$v} eq "Incomplete") {
	$mv = $info_incomplete;

	} else {

		if ($info_okay) {
		$mv = $info_okay;
		} else {
		$mv = "<br>";
		}

	}
	return $mv;

	}








	# POPULATE DROP BOX LIST
	# POPULATE DROP BOX LIST

sub GetDropBoxList {

	# Processes a list file and returns <option> list to array asking for the list
	# Only makes the <option> items between <select></select>
	# Preserves any default "selected" in file list
	# But re-assigns "selected" %frm FieldName if stored data found in the list file
	# Capable of returning to default "selected" if data present but no match found in list file
	# The list ends up in the array asking for it Passes: (filename, fieldname_with_possible_data)
	# IMPORTANT: Function requires list to have "value=some-name>" format as pattern
 	# IMPORTANT: Any "selected" must preceed this pattern.  The pattern must end with >

	my ($FilePath, $FieldName) = @_;
	my (@TempList) = ();
	my ($selected, $line, $match);
	my ($itm, $match_lock) = (0,0);

	unless (open (FILE, "$FilePath") ) { 

		$ErrMsg = "Unable to Read Drop Box List File: $FilePath";
		&ErrorMessage($ErrMsg);
		}

		@TempList = <FILE>;
		close(FILE);
		chop (@TempList);

		if ($frm{$FieldName}) {

		$match = "value=" . $frm{$FieldName} . ">";

  			foreach $_ (@TempList) {

				# if list has "selected" flag as default
				# if list has "selected" flag as default

				if ( $_ =~ /\bselected\b/i ) {
				
				($selected, $line) = ($_, $itm);

				$TempList[$itm] =~ ( s/\bselected\b//i );
				$TempList[$itm] =~ ( s/  / / );
				}
	
				if ($_ =~ /$match/i) {

				$match_lock++;

				$TempList[$itm] =~ ( s/$match/selected $match/i );

				}

			$itm++;

			} 

			# return to default if no match
			# return to default if there's a default

			if ($selected) {

				unless ($match_lock) {
				$TempList[$line] = $selected;
				}

			}

		} 

	return @TempList;
	}






	# ERROR MESSAGE
	# ERROR MESSAGE

sub ErrorMessage {

	my ($Err) = @_;
	my ($gmt) = &MakeUnixTime(0);	

	print "Content-Type: text/html\n\n";
	print "<html><head><title>MOF v1.53 Error</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";

	print "<h3>Merchant OrderForm v1.53 Data Processing Error</h3>";
      print "<h4>$Err</h4>\n";

	print "Please Contact: <a href=\"mailto:$merchantmail?subject=$Err\">$merchantmail</a><p>" if ($merchantmail);
	print "Please include as much information as possible, especially what page you were on and what action you took just before this error happened.";
	print "<u>Data Processing Information Available</u><br>";
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
	print "<p><font face=\"Arial,Helvetica\" size=1 color=gray>";
	print "<strong>Merchant OrderForm v1.53 \© Copyright ";
	print "<a href=\"http://www.io.com/~rga/scripts/\">RGA</a></strong>\n";
	print "</body></html>";
	exit;	
	}





	# ILLEGAL POST
	# ILLEGAL POST

sub IllegalPost {

	my ($gmt) = &MakeUnixTime(0);	
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Merchant OrderForm ver 1.53</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";
	print "<center><table bgcolor=#FFCE00 border=0 cellpadding=2 cellspacing=0 width=400> ";
	print "<tr><td align=center> ";
	print "<br><h2>Merchant OrderForm ver 1.53 </h2> ";
	print "<table bgcolor=#FFFFE6 border=0 cellpadding=6 cellspacing=0 width=100%><tr><td> ";
	print "<font size=3 color=navy><br> ";
	print "<center><strong>COPYRIGHT NOTICE</strong></center><br> ";
	print "The contents of this file is protected under the United States ";
	print "copyright laws as an unpublished work, and is confidential and ";
	print "proprietary to ";
	print "<a href=\"http://www.io.com/~rga\">Austin Contract Computing, Inc.</a>\n";
	print "Its use or disclosure ";
	print "in whole or in part without the expressed written permission of ";
	print "<a href=\"http://www.io.com/~rga\">Austin Contract Computing, Inc.</a>\n";	
	print " is prohibited.";
	print "</td></tr></table> \n\n";
	print "</td></tr></table></center><p> \n\n";
	print "<font size=3 color=black> ";
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
	print "</body></html>";
	exit;	
	}








	# CC VERIFY ROUTINES
	# CC VERIFY ROUTINES

sub CCValidationSolution {

	$cc_type_error = "";
	
    	$CCNumber =~ tr/0-9//cd;
   	$CCNumber = substr($CCNumber, 0, 19);

    	my $ShouldLength = "";
    	my $NumberLeft = substr($CCNumber, 0, 4);
    	my $NumberLength = length($CCNumber);


    RANGE: {
        if ($NumberLeft >= 3000 and $NumberLeft <= 3059) {
            $CCVS::CardName = "Diners Club";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "DINE");
            $ShouldLength = 14;
            last RANGE;
        }
        if ($NumberLeft >= 3600 and $NumberLeft <= 3699) {
            $CCVS::CardName = "Diners Club";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "DINE");
            $ShouldLength = 14;
            last RANGE;
        }
        if ($NumberLeft >= 3800 and $NumberLeft <= 3889) {
            $CCVS::CardName = "Diners Club";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "DINE");
            $ShouldLength = 14;
            last RANGE;
        }

        if ($NumberLeft >= 3400 and $NumberLeft <= 3499) {
            $CCVS::CardName = "American Express";
		$cc_type_error = $CCVS::CardName  unless ($frm{'Ecom_Payment_Card_Type'} eq "AMER");
            $ShouldLength = 15;
            last RANGE;
        }
        if ($NumberLeft >= 3700 and $NumberLeft <= 3799) {
            $CCVS::CardName = "American Express";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "AMER");
            $ShouldLength = 15;
            last RANGE;
        }

        if ($NumberLeft >= 3528 and $NumberLeft <= 3589) {
            $CCVS::CardName = "JCB";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "JCB");
            $ShouldLength = 16;
            last RANGE;
        }

        if ($NumberLeft >= 3890 and $NumberLeft <= 3899) {
            $CCVS::CardName = "Carte Blache";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "CART");
            $ShouldLength = 14;
            last RANGE;
        }

        if ($NumberLeft >= 4000 and $NumberLeft <= 4999) {
            $CCVS::CardName = "Visa";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "VISA");
            VISALENGTH: {

                if ($NumberLength > 14) {
                    $ShouldLength = 16;
                    last VISALENGTH;
                }

                if ($NumberLength < 14) {
                    $ShouldLength = 13;
                    last VISALENGTH;
                }

                $msg_cc = "Number $CCNumber is 14 digits long. ";
		    $msg_cc = $msg_cc . "Visa cards usually have 16 digits, though some have 13. ";
		    $msg_cc = $msg_cc . "Please check the number and try again.";
                return 0;
            }

            last RANGE;
        }

        if ($NumberLeft >= 5100 and $NumberLeft <= 5599) {
            $CCVS::CardName = "MasterCard";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "MAST");
            $ShouldLength = 16;
            last RANGE;
        }

        if ($NumberLeft == 5610) {
            $CCVS::CardName = "Australian BankCard";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "AUST");
            $ShouldLength = 16;
            last RANGE;
        }

        if ($NumberLeft == 6011) {
            $CCVS::CardName = "Discover/Novus";
		$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "DISC");
            $ShouldLength = 16;
            last RANGE;
        }

		$dgt = "digits $NumberLeft do";
	  	$dgt = "digit  $NumberLeft does" if (length($NumberLeft) == 1);
	
        $msg_cc = "The beginning $dgt not match any credit card types we accept. ";
	  $msg_cc = $msg_cc . "Please check the credit card Number for accuracy. ";
        return 0;

    }


    if ($NumberLength != $ShouldLength) {

        my $Missing = ($NumberLength - $ShouldLength);

        if ($Missing < 0) {

			$dgt = "digits";
			$dgt = "digit" if (abs($Missing) ==  1);

            $msg_cc = "The card number $CCNumber appears to be a $CCVS::CardName number, but is missing ";
		$msg_cc = $msg_cc . abs($Missing) . " $dgt. Please check the credit card number for accuracy. ";

        } else {

			$dgt = "digits";
			$dgt = "digit" if ($Missing == 1);

            $msg_cc = "The card number $CCNumber appears to be a $CCVS::CardName number, but has $Missing ";
		$msg_cc = $msg_cc . "extra $dgt. Please check the credit card number for accuracy. ";
        }
        return 0;

    }


    if (Mod10Solution($CCNumber) == 1) {
        return 1;

    } else {

        $msg_cc =  "The card number $CCNumber appears to be a $CCVS::CardName number, but the ";
	  $msg_cc = $msg_cc . "number is not valid. Please check the credit card number for accuracy. ";
        return 0;
    }

}



sub Mod10Solution {

    my $NumberLength = length($CCNumber);
    my $Location = 0;
    my $Checksum = 0;
    my $Digit = "";

    for ($Location = 1 - ($NumberLength % 2); $Location < $NumberLength; $Location += 2) {

      $Checksum += substr($CCNumber, $Location, 1);
	}

    for ($Location = ($NumberLength % 2); $Location < $NumberLength; $Location += 2) {

        $Digit = substr($CCNumber, $Location, 1) * 2;

        if ($Digit < 10) {
            $Checksum += $Digit;
        } else {
            $Checksum += $Digit - 9;
        }

    }


return ($Checksum % 10 == 0);
}



	# END CC VERIFY ROUTINES
	# END CC VERIFY ROUTINES




	# FORMAT NUMBERS
	# FORMAT NUMBERS

sub CommifyNumbers {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
    	return $_;
  	}



	# FORMAT MONEY
	# FORMAT MONEY
	# Change this to alter how money is formatted
	# The sprintf function throughout mof.cgi creates the 2 decimils


sub CommifyMoney {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
    	return $_;
  	}






1;


