# ==================== MOFcart v2.5.02.08.05 ====================== #
# === CHECKOUT LIBRARY ROUTINES =================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# sub Routines for <mofpay.cgi> Checkout
# ============================================== #
# Added Switch Debit card as cc option with full Switch validation Jan 2002
# Tarren A Barnes, Inservitus.com UK, validation routine and UK assistance
# ============================================== #
# Credit Card Validation Solution, version 3.6 -- 25 May 2000              
# Copyright 2000 - http://www.AnalysisAndSolutions.com/code/               
# The Analysis and Solutions Company - info@AnalysisAndSolutions.com      
# The CC verification uses 4 digit ranges current as of October 1999      
# If any other Ranges become available then this routine is out of date    
# Distributed with permission for Merchant OrderForm                     
# ============================================== #
# CHECK ALLOWED DOMAINS
sub CheckAllowedDomains {
	my ($domain_approved) = 0;
	my ($domain_referred) = $ENV{'HTTP_REFERER'};
	$domain_referred =~ tr/A-Z/a-z/;
  	foreach (@ALLOWED_DOMAINS) {if ($domain_referred =~ /$_/i) {$domain_approved++}}
	unless ($domain_approved) {
	$ErrMsg="<h4>POST is not from an Allowed Domain</h4>";
	$ErrMsg .= "You have enabled the ALLOWED_DOMAINS setting in MOF's Back End 
	Configuration file [mofpay.conf], however, the page that is attempting to POST
	to the cart is <b>not</b> listed in the Allowed Domains list.<p> Solution: Adjust the ALLOWED_DOMAINS
	setting to include all domains you will allow to POST to the cart.<p>";
	$ErrMsg .= "Documentation
	<a href=\"http://www.merchantorderform.com/Documentation/Configurations2.html\#AllowDomains\" target=\"_blank\">
	Configurations2.html</a>, How to allow only your domain to use the scripts.<p>";
	if ($ENV{'HTTP_REFERER'}) {
	$ErrMsg .= "Attempting POST from:<br><a href=\"$ENV{'HTTP_REFERER'}\"><b>$ENV{'HTTP_REFERER'}</b></a><p>";
	$ErrMsg .= "Your present ALLOWED_DOMAINS settings are:<br>";
	foreach (@ALLOWED_DOMAINS) {$ErrMsg .= "<a href=\"$_\"><li>$_</a>"}
	$ErrMsg .= "<p>";
	}
	$ErrMsg .= "<font color=red><b>CAUTION</b></font>: 
	We recommend that you <B>do not</b> disable the ALLOWED_DOMAINS feature. 
	You should be aware of the possible tampering with prices, etc. that can occur if you
	disable these safeguards. See the MOFcart 
	<a href=\"http://www.merchantorderform.com/support_pricefix.html\">support</a> notes 
	for more information on this security issue.<p>";
	unless ($ENV{'HTTP_REFERER'}) {
	$ErrMsg .= "<b>Note</b>: The only way you can make a direct call to this script is if you
	specify <b>?test</b> mode. Any other use of this script must have been submitted by
	an appropriate product page or dynamic page produced by this script, and not entered as a 
	direct url from your browser.  If you are getting this errror, and sure all settings are correct, 
	then you may have one of these problems:<p>
	<li>Your site's cgi environment has HTTP_REFERER disabled
	<li>Your site is behind a firewall (cgi environment HTTP_REFERER not available)
	<li>You are attempting to submit something other than <b>?test</b> from the Query String";}
	&ErrorMessage($ErrMsg);
	}}

# FORM PROCESS
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
	# 05-04-03 : Custom Fields Added
	if (scalar(keys(%custom_fields))) {
	# prevent POSTing of these chars for custom fields
	$value =~ s/[\!\#\$\%\&]//g if (exists($custom_fields{$name}));
	}
	push (@orders, $value) if ($name eq "order");
	$frm{$name} = $value;
	}
	unless (scalar(@orders) && $frm{'Primary_Products'}) {
	$ErrMsg="<h4>Essential MOFcart data is missing</h4>";
	$ErrMsg .= "<b>Note</b>: The only way you can make a direct call to this script is if you
	specify <b>?test</b> mode. Any other use of this script must have been submitted from a
	legitimate MOFcart Front End Order Summary page, and not entered as a direct url from your browser.
	If you are getting this errror, and sure all settings are correct, then you may have one of these problems:<p>
	<li>Your site's cgi environment has HTTP_REFERER disabled
	<li>Your site is behind a firewall (cgi environment HTTP_REFERER not available)
	<li>You are attempting to use the <b>GET</b> Query String which is <b>only</b> allowed for <b>?test</b>";
	&ErrorMessage($ErrMsg);
	}

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
		$strBill = substr ($key,11);
		$strShip = "Ecom_ShipTo" . $strBill;
		unless ($frm{$key}) {
		$frm{$key} = $frm{$strShip} if (exists($frm{$strShip}));	
		}}
	}

	&BuildPaymentOptions;
	# Set flag if Method selected is CC 
	# Must be after arrays populated in BuildPaymentOptions
	foreach $_ (@credit_card_list) {$card_check++ if ($frm{'input_payment_options'} eq $_)}
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
	}}}

	# check dates if using cc, if MM/YYYY both required
	if ($card_check) {
	if ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Year'}) {
	if ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Month'}) {
	my ($y,$m) = ($frm{'Ecom_Payment_Card_ExpDate_Year'},$frm{'Ecom_Payment_Card_ExpDate_Month'});
		if ($y == $ckyear) {
		if ($m < $ckmon) {
		$MissingInfoFields{'Ecom_Payment_Card_ExpDate_Month'} = "Incomplete";
		$MissingInfoFields{'Ecom_Payment_Card_ExpDate_Year'} = "Incomplete";
		$ccDateErr = "Check card expiration date for accuracy";
		}}
	}}}

	# check switch dates if using, if MM/YYYY both required
	# AND the VFRequired for beginning numbers
	if ($frm{'Ecom_Payment_Card_Type'} eq "SWIT") {
	if ($card_check) {
	if ($switch_card_fields{'Ecom_Payment_Card_FromDate_Year'}) {
	if ($switch_card_fields{'Ecom_Payment_Card_FromDate_Month'}) {
	my ($y,$m) = ($frm{'Ecom_Payment_Card_FromDate_Year'},$frm{'Ecom_Payment_Card_FromDate_Month'});
		if ($y == $ckyear) {
		if ($m > $ckmon) {
		$MissingInfoFields{'Ecom_Payment_Card_FromDate_Month'} = "Incomplete";
		$MissingInfoFields{'Ecom_Payment_Card_FromDate_Year'} = "Incomplete";
		$ccDateErr = "Check Switch card From date for accuracy";
		}}
	}}}}

	$UseBillStateProv = 0;
	$UseReceiptStateProv = 0;
	&CheckFieldsNeeded;
	&CheckUsingInfoFields;

	# If cc verify has type error change to Incomplete
	if ($cc_type_error) {$MissingInfoFields{'input_payment_options'} = "Incomplete"}
	}
	

# SET DATE
sub SetDateVariable {
	my($sec,$min,$hour,$mday,$mon,$year,$wday);
	local (@months) = ('January','February','March','April','May','June','July',
			'August','September','October','November','December');
	local (@days) = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
	if ($gmtPlusMinus) {($sec,$min,$hour,$mday,$mon,$year,$wday) = (gmtime(time + $gmtPlusMinus))} 
	else {($sec,$min,$hour,$mday,$mon,$year,$wday) = (localtime(time))[0,1,2,3,4,5,6]}
	$year += 1900;	
	($ckmon,$ckyear) = (($mon+1),$year);
 	$Date = "$days[$wday], $months[$mon] $mday, $year";
 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mon+1,'/',$mday,'/',$year);
 	$Time = sprintf("%02d%1s%02d%1s%02d",$hour,':',$min,':',$sec);
	$pass_year = $year;
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour<12);
	$ShortTime="12:".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour==0);
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour==12);
	$ShortTime=($hour-12).":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour>12);
	# formatted date
	$MyDate = "";
	$MyDate = $Date if ($format_date==1);
	$MyDate = "$months[$mon] $mday, $year" if ($format_date==2);
	$MyDate = $ShortDate if ($format_date==3);
 	$MyDate = sprintf("%02d%1s%02d%1s%04d",$mday,'/',$mon+1,'/',$year) if ($format_date==4);
 	$MyDate = sprintf("%04d%1s%02d%1s%02d",$year,'/',$mon+1,'/',$mday) if ($format_date==5);
	# added eur format : August 04, 2003 8:18:50 PM
	if ($format_date==10) {
	 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mday,'.',$mon+1,'.',$year);	 
		$MyDate = $ShortDate;
		} elsif ($format_date==11) {
		# German
		@months = ('Januar','Februar','März','April','Mai','Juni','Juli','August',
			'September','November','Oktober','Dezember');
		@days = ('Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag');
	 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mday,'.',$mon+1,'.',$year);	 
		$Date = "$days[$wday], ";
 		$Date .= sprintf("%02d",$mday);
 		$Date .= ". $months[$mon] $year";
		$MyDate = $Date;
		} elsif ($format_date==12) {
		# German
		@months = ('Januar','Februar','März','April','Mai','Juni','Juli','August',
			'September','November','Oktober','Dezember');
		@days = ('Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag');
	 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mday,'.',$mon+1,'.',$year);	 
		$Date = "$days[$wday], den $mday. $months[$mon] $year";
		$MyDate = $Date;
		}
	# add time
	$MyDate .= " " . $ShortTime  if ($format_time==1);
	$MyDate .= " " . $Time  if ($format_time==2);
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
sub ExpireCookie {
	# Always print the cookie before the Content-Type header
	my ($name_for_cookie) = @_;
	print "Set-Cookie: $name_for_cookie=$ID;expires=Sat, 1-Jan-2000 12:12:12 GMT \n";	
	}

# DELETE CART FILE
sub DeleteCartFile {
	my ($FileNumber) = @_;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;
	my ($line);
	$path = $datadirectory . $FileNumber . "\.$data_extension";
	unless (unlink("$path")) { 
	$ErrMsg="<h4>Unable to find or write to datafile: $FileNumber\.$data_extension</h4>";
	$ErrMsg .= "The <b>\$delete_cart_final</b> setting is enabled in [mofpay.conf], however, 
	something is preventing access to temporary files in the <b>orderdata</b> directory.<p>
	Make sure the <b>\$datadirectory</b> and <b>\$data_extension</b> settings in [mofpay.conf] 
	are <b><u>exactly identical</u></b> to the same settings in [mof.conf]. <p>
	If you have the MOFcart Back End running under SSL and getting this error, <b>and</b>
	the absolute paths are correct, then consult this documentation:<p>
	<li><a href=\"http://www.merchantorderform.com/Documentation/Configurations2.html\#ExpiringCart\" target=\"_blank\">
	Configurations2.html</a>, How to expire MOF's cart when order if finalized. 
	<li><a href=\"http://www.merchantorderform.com/Documentation/Troubleshooting.html\#ExpiringCart\" target=\"_blank\">
	Troubleshooting.html</a>, Expiring MOFcart under SSL. <p>
	If your SSL is on a remote server you will <b>not</b> be able to use the <b>\$delete_cart_final</b> 
	feature in MOFcart.";
	&ErrorMessage($ErrMsg);
	}}

# DATE COUPON NUMBER USED
sub DateCouponNumber {
	# format: number, rate, affiliate rate, revoke, used, dateused, invoice
	my ($num, $file) = @_;
	my ($str);
	my (@row);
	my (@ALLINFO) = ();
	my (@NEWINFO) = ();
	unless (open (FILE, "+< $file") ) { 
		$ErrMsg = "Unable to Access Coupon File";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE, 2) if ($lockfiles);
		@ALLINFO = <FILE>;
		chop (@ALLINFO);
		seek (FILE, 0, 0);
		foreach (@ALLINFO) {
		(@row) = split (/\|/, $_);
		if ($row[0] eq $num) {
			# revoke
			if ($row[3]) {
				if ($row[4] < $row[3]) {
				$row[4] ++;
				$row[5] .= "," if ($row[5]);
				$row[5] .= $ShortDate;
				$row[6] .= "," if ($row[6]);
				$row[6] .= $InvoiceNumber;
				}
			}
		}
		$str = join ("\|", (@row));
		push (@NEWINFO, $str);
		}
	foreach (@NEWINFO) {print FILE "$_\n"}
	truncate(FILE, tell(FILE));
	close(FILE);
	@ALLINFO = ();
	@NEWINFO = ();
	}

# LOG AFFILIATE ACTIVITY
sub LogAffiliateActivity {
	my ($coupon_number) = @_;
	$CreditAmount,$RepCode, $RepRate, $RepAmt;
	my ($i1,$i2,$i3,$i4,$i5,$i6,$i7,$i8,$i9,$i10,$i11,$i12,$i13,$i14);

	# obtain Rep Number for this coupon
	unless (open (IFILE, "$infofile_path") ) { 
		$ErrMsg="<h4>Unable to Access ARES Affiliate Information File</h4>";
		$ErrMsg .= "You have the ARES feature enabled, but an essential file 
		cannot be found as you have it defined in the [mofpay.conf] settings.<p>";
		$ErrMsg .= "<li>Check this setting: <b>\$infofile_path</b>.
		<li>You have it defined as: <b>$infofile_path</b>.
		<li>MOFcart <b>cannot</b> find or read the file there.<p>
		<b>Note</b>: This setting should be <b><u>exactly identical</b></u> to the same setting 
		defined in the ARES scripts for <b>\$infofile_path</b><p>
		<li>You should have the full absolute path to the file, not a URL (http).
		<li>Check, double check, and triple check that your path is correct.
		<li>Check that the needed file is in the location you have defined above.
		<li>Check that the file is named as you have it listed in config settings.<p>
		Consult the ARES Documentation for more on ARES datafiles.";
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
		}}

	# obtain Rep rates
	unless (open (IFILE, "$repinfo_path") ) { 
		$ErrMsg="<h4>Unable to Access ARES Representative Information File</h4>";
		$ErrMsg .= "You have the ARES feature enabled, but an essential file 
		cannot be found as you have it defined in the [mofpay.conf] settings.<p>";
		$ErrMsg .= "<li>Check this setting: <b>\$repinfo_path</b>.
		<li>You have it defined as: <b>$repinfo_path</b>.
		<li>MOFcart <b>cannot</b> find or read the file there.<p>
		<b>Note</b>: This setting should be <b><u>exactly identical</b></u> to the same setting 
		defined in the ARES scripts for <b>\$repinfo_path</b><p>
		<li>You should have the full absolute path to the file, not a URL (http).
		<li>Check, double check, and triple check that your path is correct.
		<li>Check that the needed file is in the location you have defined above.
		<li>Check that the file is named as you have it listed in config settings.<p>
		Consult the ARES Documentation for more on ARES datafiles.";
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
		}}

	# compute rep earnings			
	if ($RepRate) {
		if ($frm{'Deposit_Amount'} > 0 ) {
		$RepAmt = ($Send_API_Amount * $RepRate);
		} elsif ($use_NETAMT) {
		$RepAmt = ($frm{'Final_Amount'} * $RepRate);
		} else {
		$RepAmt = ($frm{'Sub_Final_Discount'} * $RepRate);
		}
	} else {
	$RepRate = 0;
	$RepAmt = 0;
	}

	# compute affiliate earnings	
	if ($frm{'Coupon_Affiliate_Rate'} > 0) {
		if ($frm{'Deposit_Amount'} > 0 ) {
		$CreditAmount = ($Send_API_Amount * $frm{'Coupon_Affiliate_Rate'});
		} elsif ($use_NETAMT) {
		$CreditAmount = ($frm{'Final_Amount'} * $frm{'Coupon_Affiliate_Rate'});
		} else {
		$CreditAmount = ($frm{'Sub_Final_Discount'} * $frm{'Coupon_Affiliate_Rate'});
		}
	} else {
	$CreditAmount = 0;
	}
	$RepAmt = sprintf "%.2f", $RepAmt;
	$CreditAmount = sprintf "%.2f", $CreditAmount;

	# transaction logging
	unless (open (AFILE, ">>$activityfile_path") ) { 
	$ErrMsg="<h4>Unable to Access ARES Affiliate Tracking Log File</h4>";
	$ErrMsg .= "You have the ARES feature enabled, but MOFcart <b>cannot</b> 
	find or write to the log file as defined in the [mofpay.conf] settings.<p>";
	$ErrMsg .= "<li>Check this setting: <b>\$activityfile_path</b>.
	<li>You have it defined as: <b>$activityfile_path</b>.
	<li>MOFcart <b>cannot</b> find or write to the file there.
	<li>Make sure the file has <b>full write permissions</b><p>
	If the file has been defined correctly, then you probably need to 
	give the file full write permissions, chmod 777 for unix, linux.<p>
	<b>Note</b>: This setting should be <b><u>exactly identical</b></u> to the same setting 
	defined in the ARES scripts for <b>\$activityfile_path</b><p>
	<li>You should have the full absolute path to the file, not a URL (http).
	<li>Check, double check, and triple check that your path is correct.
	<li>Check that the needed file is in the location you have defined above.
	<li>Check that the file is named as you have it listed in config settings.<p>
	Consult the ARES Documentation for more on ARES datafiles.";
	&ErrorMessage($ErrMsg);
	}
	flock (AFILE, 2) if ($lockfiles);
	$_ = $ShortDate;
	$_ = $_ . "\|";
	$_ = $_ . $Time;
	$_ = $_ . "\|";
	$_ = $_ . $InvoiceNumber;
	$_ = $_ . "\|";
		if ($frm{'Deposit_Amount'} > 0 ) {
		$_ = $_ . $Send_API_Amount;
		} elsif ($use_NETAMT) {
		$_ = $_ . $frm{'Final_Amount'};
		} else {
		$_ = $_ . $frm{'Sub_Final_Discount'};
		}
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

# GET INVOICE NUMBER
sub GetInvoiceNumber {
 	$InvoiceNumber;
	unless (open (NUMBER, "+< $numberfile") ) { 
	$ErrMsg="<h4>Unable to Access Invoice Number File</h4>";
	$ErrMsg .= "MOFcart is trying to read a support file that supplies the increment for
	Invoice Numbering, but the file cannot be found as you have it defined in the [mofpay.conf]
	settings.<p>";
	$ErrMsg .= "MOFcart is looking for this file: <b>$numberfile</b>.<p>
	Make sure the needed file is in the same directory as the [mofpay.cgi] script, 
	and make sure the setting for <b>\$numberfile</b> defines <b>only</b> the file name. 
	You do not need the full path. It is not a url. If you are listing the full absolute path to the file, 
	then make sure your absolute path is correct.<p>
	<b>Note</b>: If installing on NT you may need to use the full path to this file.<p>";
	$ErrMsg .= "Applicable documentation:<br>
	<a href=\"http://www.merchantorderform.com/Documentation/Configurations2.html\#NumberFile\" target=\"_blank\">
	Configurations2.html</a>, Were is the Invoice Number file ?<br>";
	&ErrorMessage($ErrMsg);
	}
	flock (NUMBER,2) if ($lockfiles);
	$InvoiceNumber = <NUMBER>;
	$InvoiceNumber++;
	seek (NUMBER, 0, 0);
	print NUMBER "$InvoiceNumber";
	close (NUMBER);
	return $InvoiceNumber;
	}

# GET TEMPLATE FILE
sub GetTemplateFile {
	my ($FilePath, $Type, $Setting) = @_;
	my (@template) = ();
	my ($line, $switch) = ("",0);
	unless (open (FILE, "$FilePath") ) { 
	$ErrMsg="<h4>Unable to read template file: $Type</h4>";
	$ErrMsg .= "MOFcart is trying to read a template file, but the file 
	cannot be found as you have it defined in the [mofpay.conf] settings.<p>";
	$ErrMsg .= "MOFcart is looking for this file: <b>$FilePath</b>.<p>
	<li>Check the setting <b>\$$Setting</b> in [mofpay.conf]
	<li>You should have the full absolute path to the file, not a URL (http).
	<li>Check, double check, and triple check that your path is correct.
	<li>Check that the needed file is in the location you have defined above.
	<li>Check that the file is named as you have it listed in config settings.<p>";
	$ErrMsg .= "Applicable documentation:<br>
	<a href=\"http://www.merchantorderform.com/Documentation/Configurations2.html\#WhereAreTemplates\" target=\"_blank\">
	Configurations2.html</a>, Where are the template file settings ?<br>";
	&ErrorMessage($ErrMsg);
	}
	@template = <FILE>;
	foreach $line (@template) {
	$switch=1 if ($line =~ /$insertion_marker/i);
		# link VarReplacer : August 11, 2003 12:07:56 AM
		$line = &VarReplacer($line);
		if ($switch) {
		push (@footer, $line);
		} else {
		push (@header, $line);
		}
	}}

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
	# Note: add new methods to $allow_methods++ in mofpay.cgi(PaymentInformation)
	# Note: Else the item will not show up as a the single only payment method enabled

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
		$payment_options_list{'VISA'} = "Visa Card" if ($_ eq 'VISA');
		$payment_options_list{'MAST'} = "MasterCard" if ($_ eq 'MAST');
		$payment_options_list{'AMER'} = "American Express" if ($_ eq 'AMER');
		$payment_options_list{'DISC'} = "Discover Card" if ($_ eq 'DISC');
		$payment_options_list{'DINE'} = "Diners Club Card" if ($_ eq 'DINE');
		$payment_options_list{'JCB'} = "JCB Card" if ($_ eq 'JCB');
		$payment_options_list{'CART'} = "Carte Blanche" if ($_ eq 'CART');
		$payment_options_list{'AUST'} = "Australian BankCard" if ($_ eq 'AUST');
		$payment_options_list{'SWIT'} = "Switch Debit Card" if ($_ eq 'SWIT');
		# rga : 12/10/04 18:36:22 : added Delta, Solo, Euro MasterCard
		$payment_options_list{'DELT'} = "Visa Delta Card" if ($_ eq 'DELT');
		$payment_options_list{'SOLO'} = "Solo Debit Card" if ($_ eq 'SOLO');
		$payment_options_list{'EURO'} = "Mastercard Eurocard" if ($_ eq 'EURO');
		}}

	if (scalar(keys(%checking_account_fields))) {$payment_options_list{'CHECK'} = "Online Checking Draft"}
	if ($mail_or_fax_field) {
		if ($merchant_fax) {
		$payment_options_list{'MAIL'} = "Mailing or Faxing Payment";
		} else {
		$payment_options_list{'MAIL'} = "Mailing Payment";
		}}
	if ($enable_paypal) {$payment_options_list{'PAYPAL'} = "Using PayPal Service"}
	if ($enable_cod) {$payment_options_list{'COD'} = "COD Delivery"}
	if ($enable_onaccount) {$payment_options_list{'ONACCT'} = "On Account"}
	if ($call_for_cc_info) {$payment_options_list{'CALLME'} = "Call Me For Card Info"}
	if ($use_gateway_forms) {$payment_options_list{'GATEWAY'} = $gateway_item_name}

	# What order to display in drop box ?
	# Uses the order of @credit_card_list for cc types
	# then adds Check and Mail methods to end of order
	foreach (@credit_card_list) {
	push (@payment_options_order, $_);
	}

	push(@payment_options_order, 'CHECK');
	push(@payment_options_order, 'MAIL');
	push(@payment_options_order, 'COD');
	push(@payment_options_order, 'PAYPAL');
	push(@payment_options_order, 'ONACCT');
	push(@payment_options_order, 'CALLME');
	push(@payment_options_order, 'GATEWAY');

	# Note: If payment method eq "MAIL" a form will print on the final invoice
	# Note: So that CC, or other info can be filled out and sent in.

	%payment_options_desc = (
		'CHECK', $msg_check,
		'MAIL', $msg_mail,
		'PAYPAL', $msg_paypal,
		'COD', $msg_cod,
		'CALLME', $msg_call,
		'ONACCT', $msg_acct,
		'GATEWAY', $msg_gateway);

	return (%payment_options_list, 
		%payment_options_desc, 
		@payment_options_order);
	}

# MASTER LIST OF FIELDS
sub CheckFieldsNeeded {
	# Anything requiring user input must be declared in this list even if it will not be validated
	# MOF creates this list to know what should be expected from the config settings
	my ($use_perm) = 0;

	# Any of the 15 BillTo fields being used ?
	unless ($zb_no_billing && $frm{'Final_Amount'} == 0) {
	while (($key, $val) = each (%billing_info_fields)) {
	push (@UsingInfoFields, $key) if ($val);	
	}}

	# Any of the 15 ReceiptTo fields being used ?
	unless ($zb_no_receipt && $frm{'Final_Amount'} == 0) {
	while (($key, $val) = each (%receipt_info_fields)) {
	push (@UsingInfoFields, $key) if ($val);	
	}}

	# 05-04-03 : Custom Fields Added
	while (($key, $val) = each (%custom_fields)) {
	unless ($extraType{$key} eq "NONE" or $extraType{$key} eq "PRE") {
	push (@UsingInfoFields,$key);	
	}}

	# Any of the 6 Credit Card fields being used ?
	while (($key, $val) = each (%credit_card_fields)) {
	push (@UsingInfoFields, $key) if ($val);	
	}

	# Any of the 3 extra Switch card fields being used ?
	push (@UsingInfoFields, "Ecom_Payment_Card_FromDate_Month") if ($VFRequired == 1);	
	push (@UsingInfoFields, "Ecom_Payment_Card_FromDate_Year") if ($VFRequired == 1);
	push (@UsingInfoFields, "Ecom_Payment_Card_IssueNumber") if ($IssueLength);

	# Any of the 7 Checking Account fields being used ?
	while (($key, $val) = each (%checking_account_fields)) {
	push (@UsingInfoFields, $key) if ($val);	
	}
	
	# Set up Payment Methods Field
	# There is no switch in configs for this
	# It's always a missing field when entering Payment Info the first time
	push (@UsingInfoFields, 'input_payment_options');

	# FOR NEW FIELD(S) ---------------------------->
	# Push required new Field(s) to @UsingInfoFields
	
	# Over ride cyber permission if Mailing or Faxing payment
	# Don't need online authorization for this
	if ($enable_cyber_permission) {
	$use_perm++ if ($frm{'input_payment_options'} eq "MAIL");
	$use_perm++ if ($frm{'input_payment_options'} eq "PAYPAL");
	$use_perm++ if ($frm{'input_payment_options'} eq "ZEROPAY");
	$use_perm++ if ($frm{'input_payment_options'} eq "GATEWAY");
	unless ($use_perm) {
	push (@UsingInfoFields,'input_cyber_permission');
	}}
	return @UsingInfoFields;
	}

# VALIDATION: WHAT FIELDS NOT COMPLETE	
sub CheckUsingInfoFields {
	my ($use_perm) = 0;
	# This checks what info we actually have against what info is expected/needed
	# The list of what is expected is already created 

	foreach $_ (@UsingInfoFields) {

	# What BillTo fields required ?
	if ($billing_info_fields{$_}) {
	unless (length($frm{$_}) >= ($billing_info_fields{$_})) {
	$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
	$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);
	}}

	# extra phone validation
	if ($_ eq "Ecom_BillTo_Telecom_Phone_Number") {
		if ($frm{$_}) {
		my ($chrs) = $frm{$_};
		$chrs =~ s/[ ()0-9.-]//g;
		$MissingInfoFields{$_} = "Incomplete" if ($chrs);
		}
	}

	# What ReceiptTo fields required ?
	if ($receipt_info_fields{$_}) {
	unless (length($frm{$_}) >= ($receipt_info_fields{$_})) {
	$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
	$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);
	}}

	# extra phone validation
	if ($_ eq "Ecom_ReceiptTo_Telecom_Phone_Number") {
		if ($frm{$_}) {
		my ($chrs) = $frm{$_};
		$chrs =~ s/[ ()0-9.-]//g;
		$MissingInfoFields{$_} = "Incomplete" if ($chrs);
		}
	}

	# What Credit Card fields required ?
	# But only if a CC Method is selected
	if ($card_check) {
	if ($credit_card_fields{$_}) {
	unless (length($frm{$_}) >= ($credit_card_fields{$_})) {
	$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
	$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);
	}}}

	# What Switch Card fields required ?
	# But only if a CC Method is selected
	if ($card_check) {
	if ($switch_card_fields{$_}) {
	unless (length($frm{$_}) >= ($switch_card_fields{$_})) {
	$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
	$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);
	}}}

	# pad to IssueLength
	if ($_ eq "Ecom_Payment_Card_IssueNumber") {	
	if ($frm{$_}) {
	my ($chrs) = $frm{$_};
	$chrs =~ s/[0-9]//g;
	$MissingInfoFields{$_} = "Incomplete" if ($chrs);
	$MissingInfoFields{$_} = "Incomplete" if ((length($frm{$_})) > $IssueLength);
	my ($pad) = ($IssueLength - (length($frm{$_})));
	$frm{$_} = 0 x ($pad) . $frm{$_} if ($pad);
	}}

	# What Checking Account fields required ?
	# But only if Online Checking Method is selected
	if ($frm{'input_payment_options'} eq "CHECK") {
	if ($checking_account_fields{$_}) {
	unless (length($frm{$_}) >= ($checking_account_fields{$_})) {
	$MissingInfoFields{$_} = "Missing" if (length($frm{$_})==0);
	$MissingInfoFields{$_} = "Incomplete" if (length($frm{$_})>0);
	}}}
	} 
	# End foreach in @UsingInfoFields list

	# Adjust BillTo validation if Region being used
	if ($frm{'Ecom_BillTo_Postal_CountryCode'}) {
	if (exists($billing_info_fields{'Ecom_BillTo_Postal_Region'})) {
	foreach (@force_state_select) {
	$UseBillStateProv++ if ($frm{'Ecom_BillTo_Postal_CountryCode'} eq $_)}
		if ($UseBillStateProv) {
		delete($MissingInfoFields{'Ecom_BillTo_Postal_Region'});
		} else {
		delete($MissingInfoFields{'Ecom_BillTo_Postal_StateProv'});
		$frm{'Ecom_BillTo_Postal_StateProv'} = "";	
		}
	}}

	# Adjust ReceiptTo validation if Region being used
	if ($frm{'Ecom_ReceiptTo_Postal_CountryCode'}) {
	if (exists($receipt_info_fields{'Ecom_ReceiptTo_Postal_Region'})) {
	foreach (@force_state_select) {
	$UseReceiptStateProv++ if ($frm{'Ecom_ReceiptTo_Postal_CountryCode'} eq $_)}
		if ($UseReceiptStateProv) {
		delete($MissingInfoFields{'Ecom_ReceiptTo_Postal_Region'});
		} else {
		delete($MissingInfoFields{'Ecom_ReceiptTo_Postal_StateProv'});
		$frm{'Ecom_ReceiptTo_Postal_StateProv'} = "";	
		}
	}}

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
	# Unless you trigger use_perm for a given payment method
	if ($enable_cyber_permission) {
	$use_perm++ if ($frm{'input_payment_options'} eq "MAIL");
	$use_perm++ if ($frm{'input_payment_options'} eq "PAYPAL");
	$use_perm++ if ($frm{'input_payment_options'} eq "ZEROPAY");
	$use_perm++ if ($frm{'input_payment_options'} eq "GATEWAY");
	unless ($use_perm) {
	unless ($frm{'input_cyber_permission'} eq "APPROVED") {
	$MissingInfoFields{'input_cyber_permission'} = "Missing";
	}}}

	# validate any Email addr whether required or not
	# to prevent sendmail from crashing script w/ bogus addr
	if ($frm{'Ecom_BillTo_Online_Email'}) {
	unless ($frm{'Ecom_BillTo_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/) {
        $MissingInfoFields{'Ecom_BillTo_Online_Email'} = "Incomplete";
	}}

	if ($frm{'Ecom_ReceiptTo_Online_Email'}) {
	unless ($frm{'Ecom_ReceiptTo_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/) {
        $MissingInfoFields{'Ecom_ReceiptTo_Online_Email'} = "Incomplete";
	}}

	# validate any needed deposit minimums if enabled
	# Deposit_Amount only displays if deposit enabled
	# and validation only triggers if amount is entered
	$depmin = $deposit_minimum if ($deposit_minimum > 0);
	$deppct = ($deposit_percent * $frm{'Final_Amount'}) if ($deposit_percent > 0);
 	$depmin = $deppct if ($deppct > $depmin);
	$depmin = sprintf "%.2f", $depmin if ($depmin > 0);
	if ($frm{'Deposit_Amount'}) {
	$frm{'Deposit_Amount'} =~ s/ //g ;
	my ($mtch) = $frm{'Deposit_Amount'};
	$mtch =~ s/[0-9.]//g;
	if ($mtch) {$MissingInfoFields{'Deposit_Amount'} = "$mtch"} 
	elsif ($frm{'Deposit_Amount'} > 0 && $frm{'Deposit_Amount'} < $depmin ) {
	$MissingInfoFields{'Deposit_Amount'} = "MinimumNeeded"}
	}

	# 05-04-03 : Custom Fields Added Validation
	# Will validate any %extraType with "REGX" as Type
	while (($key,$val) = each (%custom_fields)) {
		#  text box Regx
		if ($extraType{$key} =~ /REGX/) {
			unless ($frm{$key} =~ /$extraRegx{$key}/) {
				if ($frm{$key}) {
				$MissingInfoFields{$key} = "Incomplete";
				} else {
	      			$MissingInfoFields{$key} = "Missing";
				}	
			}
		# drop box
		} elsif ($extraType{$key} eq "DROP") {
			unless ($frm{$key}) {
      			$MissingInfoFields{$key} = "Missing";
			}	
		}
	}

	# FOR NEW FIELD(S) -------------------------->
	# Push validation errors to @MissingInfoFields
	return %MissingInfoFields;
	}

# FLAG MISSING BILLTO FIELDS
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

# FLAG MISSING RECEIPT TO FIELDS
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

# 05-04-03 : Custom Fields Added
# Validation has already occurred, this simply returns the appropriate prompt
# FLAG MISSING CUSTOM FIELDS
sub ValidateCustomFields {
	my ($f);
	my ($v) = @_;
	my ($mv);
	if ($MissingInfoFields{$v} eq "Missing") {
		if ($frm{'resubmit_info'}) {
		$mv = $info_missing;
		# drop lists get special treatment
		$mv = $info_incomplete if (exists($extraList{$v}));
		} else {
		$mv = $info_required;
		}
	} elsif ($MissingInfoFields{$v} eq "Incomplete") {
	$mv = $info_incomplete;
	} else {
		# find different
		$mv = "<br>";
		foreach $f (@UsingInfoFields) {
		$mv = $info_okay if ($v eq $f);
		}
	}
	return $mv;
	}

# VALIDATE CREDIT CARD FIELDS
sub ValidateCreditCardInfo {
	my ($v) = @_;
	my ($mv);

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
			if (
			($credit_card_fields{$v}) or
			($v eq "Ecom_Payment_Card_FromDate_Month" && $VFRequired == 1) or
			($v eq "Ecom_Payment_Card_FromDate_Year" && $VFRequired == 1) or
			($v eq "Ecom_Payment_Card_IssueNumber" && $IssueLength)		
			) {
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
sub ValidateCheckingInfo {
	my ($v) = @_;
	my ($mv);

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

# 07-25-03 : optimize flagging
sub GetFlags {
my ($v) = @_;
($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) = (
	'inputBRow',
	'inputBNum',
	'inputBLabel',
	'inputBInput',
	'inputBValidate',
	'BillingBoxFormat',
	'<br>');
	if ($frm{'resubmit_info'}) {
	if ($MissingInfoFields{$v} eq "Missing") {
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox) = (
	'errBRow','errBNum','errBLabel','errBInput','errBValidate','BillingErrBoxFormat');
	$strNum = $info_missing_Num if ($info_missing_Num);
	}
	if ($MissingInfoFields{$v} eq "Incomplete") {
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox) = (
	'errBRow','errBNum','errBLabel','errBInput','errBValidate','BillingErrBoxFormat');
	$strNum = $info_incomplete_Num if ($info_incomplete_Num);
	}}
	return ($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum);
	}

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
	my ($FilePath,$FieldName) = @_;
	my (@TempList) = ();
	my ($selected,$line,$match);
	my ($itm,$match_lock) = (0,0);
	unless (open (FILE,"$FilePath") ) { 
	$ErrMsg="<h4>Unable to read dropbox list: $FilePath</h4>";
	$ErrMsg .= "MOFcart is trying to read a support file that supplies the list for a
	dropbox on the Billing Information page, but the file cannot be found as you have
	it defined in the [mofpay.conf] settings.<p>";
	$ErrMsg .= "MOFcart is looking for this file: <b>$FilePath</b>.<p>
	Make sure the needed file is in the same directory as the Back End scripts, 
	and make sure the [mofpay.conf] setting for <b>";
	if ($FieldName eq "Ecom_BillTo_Postal_CountryCode") {$ErrMsg .= "\$use_country_list"}
	elsif ($FieldName eq "Ecom_BillTo_Postal_StateProv") {$ErrMsg .= "\$use_state_list"}
	elsif ($FieldName eq "Ecom_ReceiptTo_Postal_CountryCode") {$ErrMsg .= "\$use_country_list"}
	elsif ($FieldName eq "Ecom_ReceiptTo_Postal_StateProv") {$ErrMsg .= "\$use_state_list"}
	$ErrMsg .= "</b> defines <b>only</b> the file name. You do not need the full path. 
	It is not a url. If you are listing the full absolute path to the file, then make
	sure your absolute path is correct.<p>";
	$ErrMsg .= "Applicable documentation:<br>
	<a href=\"http://www.merchantorderform.com/Documentation/Configurations2.html\#ChangeDropBox\" target=\"_blank\">
	Configurations2.html</a>, How to change the Drop Boxes<br>";
	&ErrorMessage($ErrMsg);
	}
	# custom fields DROP boxes use this as well as fixed country,state lists
		@TempList = <FILE>;
		close(FILE);
		chop (@TempList);
		if ($frm{$FieldName}) {
		$match = "value=" . $frm{$FieldName} . ">";
			# rga : 02/07/05 12:04:33
			# need to match the (parentheses) in usps_country.txt List
			$match =~ s/\(/\\\(/g;
			$match =~ s/\)/\\\)/g;
  			foreach (@TempList) {
				# if list has "selected" flag as default
				if ( $_ =~ /\bselected\b/i ) {
				($selected, $line) = ($_, $itm);
				$TempList[$itm] =~ ( s/\bselected\b//i );
				$TempList[$itm] =~ ( s/  / / );
				}
				if ($_ =~ /$match/i) {
				$match_lock++;
				$match_replace = $match;
				$match_replace =~ s/\\//g;
				$TempList[$itm] =~ ( s/$match/selected $match_replace/i );
				}
			$itm++;
			} 
			# return to default if there's a default
			if ($selected) {
				unless ($match_lock) {
				$TempList[$line] = $selected;
				}
			}
		} 
	return @TempList;
	}

# 05-04-03 : Custom Fields Added
# IDENTIFY CUSTOM FIELD TYPE [ PRE, REGX, PREREGX, DROP, NONE }
sub CustomFieldType {
	my ($fld);
	my ($title,$text);
	%extraType = ();
	%extraTitle = ();
	%extraPreFill = ();
	%extraRegx = ();
	%extraList = ();
	@extraFields = sort { lc($a) cmp lc($b) } (keys %custom_fields);
		foreach $fld (@extraFields) {
  		($title,$text) = split (/----/,$custom_fields{$fld});
		$extraTitle{$fld} = $title;	
		if ($text) {
			# drop box
			if ( -e "$text" ) {
				$extraType{$fld} = "DROP";
				$extraList{$fld} = $text;
			# text box
			} else {
			my($p,$r,$t) = split (/\//,$text);
				# type?
				$extraType{$fld} = "PRE" if ($p);
				$extraType{$fld} .= "REGX" if ($r);
				# params
				$extraPreFill{$fld} = $p if ($p);
				$extraRegx{$fld} = $r if ($r);
			}
		} else {
		$extraType{$fld} = "NONE";
		}
	}
}

# 07-28-03 : Message Var replacer
sub VarReplacer {
	my ($str) = @_;
	# find any {{STR}} and isolate name only, look for that in $frm{} if exists
	# you can also do variations of the @orders
	my $p;
   	my $rx = qr/\Q{{\E(.+?)\Q}}\E/;
	my @tmp = ( $str =~ /$rx/g );
	foreach $p (@tmp) {
		if (exists($frm{$p})) {
		$str =~ (s/{{$p}}/$frm{$p}/g);
		} else {
		$str =~ (s/{{$p}}//g);
		}
	}
	return $str;
	}
	
# PASS ERROR MESSAGE
sub ErrorMessage {
	my ($Err) = @_;
	my ($gmt) = &MakeUnixTime(0);	
	if ($ERRORMODE == 2) {
	print "Location: $ErrMsgRedirect\n\n";
	} elsif ($ERRORMODE == 1) {
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Error</title></head><body bgcolor=#FFFFE6 text=#000000>";
	print "<center><table bgcolor=#FFCE00 border=0 cellpadding=2 cellspacing=0 width=400> ";
	print "<tr><td align=center> ";
	print "$font <b> Shopping Cart Message </b></font> ";
	print "<table bgcolor=#FFFFE6 border=0 cellpadding=6 cellspacing=0 width=100%><tr><td> ";
	print "<font size=2 color=navy><br> ";
	print "<center><strong>We're sorry .. </strong></center><p> ";
	print "$font2 ";
	print "
	Our shopping cart has detected a problem with this request. <p>
	You may be attempting to load an <font color=red><b>expired cart page</b></font> 
	by using browser functions such as: PAGE BACK, PAGE FORWARD, BOOKMARKS, or the ADDRESS BAR.<p>
	Use the link below to return to the site, and then try navigating through
	the Shopping cart using <u>only</u> the buttons provided on the cart pages. <p>
	";
	if ($merchantmail) {
	print "If you are using all the cart buttons, and still getting this error, ";
	print "then please report the problem to ";
	print "<a href=\"mailto:$merchantmail\">$merchantmail</a>.<p>" ;
	}
	print "
	<center>
	<strong>
	<a href=\"$ErrMsgLink\">
	Click Here to return to the site</a></strong></center> <p>
	";
	print " </font> \n\n";
	print "</td></tr></table> \n\n";
	print "</td></tr></table></center><p> \n\n";
	print "</body></html>";
	} else {
	print "Content-Type: text/html\n\n";
	print "<html><head><title>MOF v2.4 Error</title></head><body bgcolor=#FFFFE6 text=#000000>";
	print "<center><h4>Merchant OrderForm v2.4 Error - TroubleShooting Mode</h4></center>";
	print "<center><table border=0 cellpadding=8 bgcolor=white cellspacing=0 width=600><tr><td>";
	print "<p>$Err ";
	print "</td></tr></table></center>";
	print "<p><center><table border=0 cellpadding=8 bgcolor=#FFFFE6 cellspacing=0 width=600><tr><td>";
	print "<li><u>Information Available</u><br>";
	print "<li>Local Time: $Date $Time<br>";
	print "<li>GMT Time: $gmt";
		if ($ENV{'HTTP_REFERER'}) {
		print "<li>Referring URL: $ENV{'HTTP_REFERER'}";
		} else {
		print "<li>Referring URL: <font color=red><b>Possible direct call to script</b></font>";
		}
	print "<li>Server Name: $ENV{'SERVER_NAME'}" if ($ENV{'SERVER_NAME'});
	print "<li>Server Protocol: $ENV{'SERVER_PROTOCOL'}" if ($ENV{'SERVER_PROTOCOL'});
	print "<li>Server Software: $ENV{'SERVER_SOFTWARE'}" if ($ENV{'SERVER_SOFTWARE'});
	print "<li>Gateway: $ENV{'GATEWAY_INTERFACE'}" if ($ENV{'GATEWAY_INTERFACE'});
	print "<li>Remote Host: $ENV{'REMOTE_HOST'}" if ($ENV{'REMOTE_HOST'});
	print "<li>Remote Addr: $ENV{'REMOTE_ADDR'}" if ($ENV{'REMOTE_ADDR'});
	print "<li>Remote User: $ENV{'REMOTE_USER'}" if ($ENV{'REMOTE_USER'});
	print "<p><font face=\"Arial,Helvetica\" size=1 color=gray>";
	print "<strong>Merchant OrderForm v2.4 \© Copyright ";
	print "<a href=\"http://www.merchantorderform.com\">RGA</a></strong>\n";
	print "</td></tr></table></center>";
	print "</body></html>";
	}
	exit;	
	}

# CC VERIFY ROUTINES
sub CCValidationSolution {
	$cc_type_error = "";
    	$CCNumber =~ tr/0-9//cd;
   	$CCNumber = substr($CCNumber, 0, 19);
    	my $ShouldLength = "";
	# next 2 vars must be global for switch FromDate validation
    	$VFRequired = 0;
    	$IssueLength = 0;
    	my $NumberLeft = substr($CCNumber, 0, 4);
    	my $Number6Left = substr($CCNumber, 0, 6);
    	my $NumberLength = length($CCNumber);

    RANGE: {

	# For Switch validation vars (1-3) must be set here for various
	# validation of FromDate conditions throughout script
	# Start Range  : Number6Left
	# End Range    : Number6Left
	# (1) ShouldLength : No Of Digits
	# (2) (global) VFRequired   : VALID FROM required? (1=yes, 0=no, 2=optional)
	# (3) (global) IssueLength  : ISSUE NUMBER digits padded? (0=no, number=digits)

	# 490302 is a possible VISA number and will trigger SWIT card type error
	# before Visa is ever checked against 4903 NumberLeft ..
	# So, enable only if CardType SWIT else pass by for standard NumberLeft check
	if ($frm{'Ecom_Payment_Card_Type'} eq "SWIT" && $enable_switch_verify) {

	# added Switch Cards by INSERVITUS 1/2002
        if (
	($Number6Left >= 490302 and $Number6Left <= 490309) or
	($Number6Left >= 490335 and $Number6Left <= 490339) or
	($Number6Left >= 675938 and $Number6Left <= 675940)
	) {
	$CCVS::CardName = "Switch (HSBC)";
	$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "SWIT");
        $ShouldLength = 18;
        $VFRequired = 1;
        $IssueLength = 0;
        last RANGE;
        }

        if (
	($Number6Left >= 491101 and $Number6Left <= 491102)
	) {
        $CCVS::CardName = "Switch (Bank of Scotland)";
	$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "SWIT");
        $ShouldLength = 16;
        $VFRequired = 1;
        $IssueLength = 0;
        last RANGE;
        }

        if (
	($Number6Left >= 491174 and $Number6Left <= 491182)
	) {
        $CCVS::CardName = "Switch (Clydesdale)";
	$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "SWIT");
        $ShouldLength = 18;
        $VFRequired = 1;
        $IssueLength = 0;
        last RANGE;
        }

        if (
	($Number6Left >= 493600 and $Number6Left <= 493699) or
	($Number6Left >= 675901 and $Number6Left <= 675901) or
	($Number6Left >= 675918 and $Number6Left <= 675918) or
	($Number6Left >= 675950 and $Number6Left <= 675962) or
	($Number6Left >= 675998 and $Number6Left <= 675998)
	) {
        $CCVS::CardName = "Switch (Natwest)";
	$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "SWIT");
        $ShouldLength = 19;
        $VFRequired = 1;
        $IssueLength = 0;
        last RANGE;
        }

        if (
	($Number6Left >= 564182 and $Number6Left <= 564182)
	) {
        $CCVS::CardName = "Switch (Halifax)";
	$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "SWIT");
        $ShouldLength = 16;
        $VFRequired = 2;
        $IssueLength = 0;
        last RANGE;
        }
 
       if (
	($Number6Left >= 633300 and $Number6Left <= 633300) or
	($Number6Left >= 633302 and $Number6Left <= 633349) or
	($Number6Left >= 675900 and $Number6Left <= 675900) or
	($Number6Left >= 675902 and $Number6Left <= 675904) or
	($Number6Left >= 675906 and $Number6Left <= 675917) or
	($Number6Left >= 675919 and $Number6Left <= 675937) or
	($Number6Left >= 675941 and $Number6Left <= 675949) or
	($Number6Left >= 675963 and $Number6Left <= 675997) or
	($Number6Left >= 675999 and $Number6Left <= 675999)
	) {
        $CCVS::CardName = "Switch";
	$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "SWIT");
        $ShouldLength = 16;
        $VFRequired = 0;
        $IssueLength = 2;
        last RANGE;
        }

        if (
	($Number6Left >= 633301 and $Number6Left <= 633301) or
	($Number6Left >= 675905 and $Number6Left <= 675905)
	) {
        $CCVS::CardName = "Switch (Yorkshire Bank)";
	$cc_type_error = $CCVS::CardName unless ($frm{'Ecom_Payment_Card_Type'} eq "SWIT");
        $ShouldLength = 19;
        $VFRequired = 1;
        $IssueLength = 0;
        last RANGE;
        }

	# end switch
	}

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
            $CCVS::CardName = "Carte Blanche";
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
	$msg_cc = $msg_cc . "Please check the card Number for accuracy. ";
        return 0;
    }

    if ($NumberLength != $ShouldLength) {
        my $Missing = ($NumberLength - $ShouldLength);
        if ($Missing < 0) {
	$dgt = "digits";
	$dgt = "digit" if (abs($Missing) ==  1);
        $msg_cc = "The card number $CCNumber appears to be a $CCVS::CardName number, but is missing ";
	$msg_cc = $msg_cc . abs($Missing) . " $dgt. Please check the card number for accuracy. ";
        } else {
	$dgt = "digits";
	$dgt = "digit" if ($Missing == 1);
        $msg_cc = "The card number $CCNumber appears to be a $CCVS::CardName number, but has $Missing ";
	$msg_cc = $msg_cc . "extra $dgt. Please check the card number for accuracy. ";
        }
        return 0;
    }

    if (Mod10Solution($CCNumber) == 1) {
        return 1;
    # override mod10 for Switch
    # } elsif ($frm{'Ecom_Payment_Card_Type'} eq "SWIT") {
    #	return 1;
    } else {
        $msg_cc =  "The card number $CCNumber appears to be a $CCVS::CardName number, but the ";
	$msg_cc = $msg_cc . "number is not valid. Please check the card number for accuracy. ";
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
# End cc verify

# TEST MODE
sub RunTestMode {
	my(@MAIL_TEST) = (
 	'/usr/sbin/sendmail -t',
  	'/usr/lib/sendmail -t',
  	'/var/qmail/bin/qmail-inject');
	my($ts);
	my(@MailExists) = ();
	foreach (@MAIL_TEST) {
	@ts = split(/ /, $_);
	if ( -e $ts[0] ) {push (@MailExists, $_)}}
	$ErrMsg="<h4>Merchant OrderForm v2.4 is Running [Back End - Payment Processing]</h4>";
	$ErrMsg .= "The core components for the MOFcart Back End are loaded, and the core 
	script package appears to be running on the server. For further installation instructions 
	consult the <b>Installation.html</b> in your Documentation, or the online
	<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\" target=\"_blank\">
	Installation.html</a> document.<p>";
	$ErrMsg .= "<li><u>Absolute Path</u>: <strong>$ENV{DOCUMENT_ROOT}</strong>";
	if (scalar(@MailExists)) {
	foreach (@MailExists) {$ErrMsg .= "<li><u>Mail</u>: Found Mail Path: <b>$_</b>, <font color=green>okay</font>";}
	} else {
	$ErrMsg .= "<li><u>Mail</u>: Cannot find common Unix, Linux (Qmail or Sendmail) Paths, <font color=red>problem</font>";}
	$ErrMsg .= "<li><u>Empty Cart</u>: <b>\$delete_cart_final</b> is <b>NOT</b> enabled in [mofpay.conf], <font color=red>problem</font>" unless ($delete_cart_final);
	if ( -w "$datadirectory" ) {
	$ErrMsg .= "<li><u>Empty Cart</u>: $datadirectory is Writeable, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Empty Cart</u>: $datadirectory <b>NOT</b> Writeable or not Found, <font color=red>problem</font>";}
	if ( -w "$save_invoice_path" ) {
	$ErrMsg .= "<li><u>Save Invoices</u>: $save_invoice_path is Writeable, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Save Invoices</u>: $save_invoice_path <b>NOT</b> Writeable or not Found, <font color=red>problem</font>";}
	if ( -w "$numberfile" ) {
	$ErrMsg .= "<li><u>Number File</u>: $numberfile is Writeable, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Number File</u>: $numberfile <b>NOT</b> Writeable or not Found, <font color=red>problem</font>";}
	if ( -r "$payment_info_template" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $payment_info_template, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $payment_info_template, <font color=red>problem</font>";}
	if ( -r "$final_template" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $final_template, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $final_template, <font color=red>problem</font>";}
	if ( -r "$save_invoice_template" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $save_invoice_template, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $save_invoice_template, <font color=red>problem</font>";}
	$ErrMsg .= "<li><font color=red>Security Warning</font>: Allowed Domains is disabled in [mofpay.conf]" unless scalar(@ALLOWED_DOMAINS);	
	&ErrorMessage($ErrMsg);
 	}

# FORMAT NUMBERS
sub CommifyNumbers {
	local $_  = shift;
	if ($alt_numbers) {	
    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
	} else {
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
	}
    	return $_;
  	}

# FORMAT MONEY
sub CommifyMoney {
	local $_  = shift;
	if ($alt_currency) {	
	    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
		local ($str);
		$str = (length ($_) - 3);
		substr ($_,$str,1) = ',';
	} else {
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
	}
    	return $_;
  	}

# FORMAT ALTERNATE per request
sub FormatAltMoney {
	local $_  = shift;
	    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
		local ($str);
		$str = (length ($_) - 3);
		substr ($_,$str,1) = ',';
    	return $_;
  	}

# FORMAT ALTERNATE per request
sub FormatAltNumbers {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
    	return $_;
  	}

# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;
