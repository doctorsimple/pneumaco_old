#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === ARES AFFILIATE SIGNUP SCRIPT ================================ #
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

# ARES v2.5 - Signup and Registrations
# ARES v2.5 - Affiliate Referral Earnings System 4-10-2001
# Copyright @ All Rights Reserved 2001-2003 MerchantOrderForm.com / MerchantPal.com

# Validation to match user input for Email, Password
# Validation to prevent duplicate email addresses
# Validation to prevent duplicate coupon codes after random generation
# Note: The first two digits of the Random Coupon Code
# Note: are taken from the current year .. 20 = 2000, 21 = 2001, etc.
# Note: The coupon file MUST be Integers only No other characters
# Note: Check for dups uses numeric operators only

# CONFIGURATIONS
# Note: The delimiter for all files is "|"
# Note: If any user input has this it will be replaced with space

# THIS FILE
# Use the Full URL
$programfile = "$mvar_front_http_mcart/signup.cgi";

# WHAT ARE THE DEFAULT RATES ?	
# What default discount to give a customer using a coupon code
$discount = 0.1;

# What percent earning rate to give the affiliate when their coupon is used
$affiliate_rate = 0.1;

# REQUIRE A REP TO BE SELECTED ?	
$require_rep = 1;

# Allow all Rep info to print in mail and messages to affiliate
# if (0) off only Name, number, and email will print
$allow_rep_info = 1;

# WHERE ARE THE DATA FILES KEPT ?
# All the data files should be behind Public Web areas
# Define the full absolute path, not an Http url	
# Or put data files inside public web area and .htaccess protect
# if these file in public web areas they MUST be pswd protected

# Where's the Main Information file ?
$infofile_path = "$mvar_front_path_mcart/data/ares_infofile.dat";

# Where's the Coupon File ?
$couponfile_path = "$mvar_front_path_mcart/data/ares_couponcode.dat";

# Where's the PSWD File ?
$pswdfile_path = "$mvar_front_path_mcart/data/ares_pswdfile.dat";

# Where's the Rep Info File ?
$repinfo_path = "$mvar_front_path_mcart/data/ares_repinfo.dat";

# VERY IMPORTANT .. VERY IMPORTANT .. VERY IMPORTANT
# THIS FEATURE MUST BE ENABLED WHEN THE SYSTEM GOES LIVE
$lockfiles = 1 unless ($^O =~ m/mswin32/i);

# WHAT DOMAINS TO ALLOW POST FROM ?
#@ALLOWED_DOMAINS = (
#	"http://$ENV{SERVER_NAME}",
#	"https://$ENV{SERVER_NAME}",
#	"http://$ENV{HTTP_HOST}",
#	"https://$ENV{HTTP_HOST}"
#	);

# WHERE IS THE TEMPLATE FILE KEPT ?
# This is also absolute path, not Http url or put it in your cgi-bin
$template = "$mvar_front_path_web/ares/temp_referral.html";

# Insert output at this point in template
$insertion_marker = '<!--INSERT_TEMPLATE_OUTPUT-->';

# Who to Reply To, return addr for Registrant mail
# This can be the same as $email_address below
$mail_return_addr = 'affiliates@gardenthemes.com';

# information email address in email confirmation
# who to email for more information
$mail_info_questions = 'affiliates@gardenthemes.com';

# email address for owner of site
# used to report file opening errors
$email_address = 'affiliates@gardenthemes.com';

# Buiness name, appears in email message
$business_name = $mail_merchant_name;

# Home url for this business name
$business_url = $mail_site_url;

# Full URL for the usrmgt.html form
# This appears in email instructions
$usrmgt_url = "$mvar_front_http_web/ares/usrmgt.html";

# Full URL for the signup.html form
# This appears for any cache errors
$signup_url = "$mvar_front_http_web/ares/signup.html";

# Full URL to the ares.cgi script
# Used to create cut and paste link examples
$ares_url = "$mvar_front_http_mcart/ares.cgi";

# Full URL to the "more information" page
$moreinfo_url = "$mvar_strict_http_web/ares/linkhelp.html";
	
# Full URL to your small logo image
# used for cut and paste code as image link example
$logo_url = "$mvar_strict_http_web/ares/small_logo.gif";

# USING FONTS - COLORS	
# Assign light / dark table colors
$table_dark = '#CECE9C';
$table_light = '#EBEBD8';

# Assign font attributed used in html output
$font2 = '<font face="Arial, Verdana,Helvetica,Arial" size="2" color="#000000">';
$font3 = '<font face="Arial, Verdana,Helvetica,Arial" size="3" color="#000000">';

# END OF CONFIGURATIONS	

# EDIT THE "HOW IT WORKS" HTML MESSAGE HERE
# You must leave the $HowItWorksMessage = " <starting line>
# and you must leave the <ending line> ";
# proceed a dollar sign character with the \$

$HowItWorksMessage = "


<ul>

<li>Set up your
affiliate links to $mail_merchant_name on your personal and business web pages, newsletters, 
email correspondence, and
any other legitimate promotional avenues. (Instructions follow below.)


<li>Whenever anyone
clicks on one of your links to our site, we will automatically
associate that clickthrough with your affiliate number. 
If the visitor makes any purchases from our online store during 
the 30 days following the clickthrough,
we'll credit your affiliate account with your commission, and
give the customer a discount. Starting rates are listed above.

<li>This
entire affiliate referral process is fully automated, which means that
you can check your account anytime to view your earnings.
Referral revenue is paid to you monthly by the 10th of the following month. 
Accounts with balance less than \$ 25.00 will be carried over to the following pay period.

<li>Note:
Affiliate earnings apply only to products purchased via our online store

<li><b>$mail_merchant_name enforces a strict no-spam policy</b>. 
We specifically prohibit any use of links to
our website or mention of our products in mass
unsolicited email programs. To enforce this policy, we monitor
referrals into the program. If we discover that an affiliate partner
has violated the no-spam policy, we will immediately void that partner's 
account and file notice with its originating server and host.

</ul>

"; # do not remove this line
# END "HOW IT WORKS" HTML MESSAGE


# EDIT THE "HOW IT WORKS" MAIL MESSAGE HERE
# You must leave the $HowItWorksMessage = " <starting line>
# and you must leave the <ending line> ";
# proceed a dollar sign character with the \$
# Also in this message your carriage returns will show up
# in the mail, unlike the HTML message where not carriage returns show up

$HowItWorksMailMessage = "
a.. Set up your affiliate links to us on your personal and business web pages, newsletters, email correspondence, and any other legitimate promotional avenues. (Instructions follow below.)

b.. Whenever anyone clicks on one of your links to our site, we will automatically associate that clickthrough with your affiliate number. 
 
c.. If the visitor makes any purchases from our online store during the 30 days following the clickthrough, we'll credit your affiliate account with your commission, and give the customer a discount. Starting rates are listed above.
   
d.. This entire affiliate referral process is fully automated, which means that you can check your account anytime to view your earnings. 

e.. Referral revenue is paid to you monthly by the 10th of the following month. Accounts with balance less than \$ 25.00 will be carried over to the following pay period.
 
f.. Note: Affiliate earnings apply only to products purchased via our online store
 
g.. We enforce a strict no-spam policy. We specifically prohibit any use of links to our website or mention of our products and services in mass unsolicited email programs. To enforce this policy, we monitor referrals into the program. If we discover that an affiliate partner has violated the no-spam policy, we will immediately void that partner's account and file notice with its originating server and host. 
"; # do not remove this line
# END "HOW IT WORKS" MAIL MESSAGE

# PROGRAM FLOW
&SetDateVariable;
&IllegalUse if ($ENV{'QUERY_STRING'});
&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
&ProcessForm;
# must submit 14 Field names from signup.html
&IllegalUse if (scalar(keys(%frm)) < 14);
&GetTemplateFile($template, "Main Template");
@MissingInformation = ();
&ValidateForm;

	if (scalar(@MissingInformation)) {
		close(PFILE);
		&RegistrationFailed;
		exit;
	} else {
		if ($require_rep) {
			unless ($frm{'Ecom_Rep_Number'}) {	
			@REPLIST = ();
			&GetRepList;		
			&RequireRepresentative;
			exit;
			}
		}
		$REPRECORD;
		&GetRepRecord($frm{'Ecom_Rep_Number'}) if ($frm{'Ecom_Rep_Number'});

		# Get random coupon number
		# check for non duplicate
		# only call srand once
		srand();
		$RandomCode = 0;
		@CouponCodes = ();

		# open coupon file keep open while 
		# testing for dups
		unless (open (CFILE, "$couponfile_path") ) { 
		$ErrMsg = "Unable to Locate the Coupon Data File";
		&ErrorMessage($ErrMsg);
		}
		flock (CFILE, 2) if ($lockfiles);
		@CouponCodes = <CFILE>;
		while ($RandomCode == 0) {
		&RandomCouponCode;
		&ValidateCouponNumber;
		}

		# close both open files 
		# before you can write
		close(PFILE);
		close(CFILE);
		&Append_To_PSWDFile;
		&Append_To_CouponFile;
		&Append_To_InfoFile;
		close(PFILE);
		close(CFILE);
		close(IFILE);
		&MailAccountInformation if ($mail_program);
		&RegistrationSuccessful;
		}
		exit;


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
	}
	}


# VALIDATE FORM
sub ValidateForm {
	unless (length($frm{'Ecom_Postal_Name_First'}) > 0 ) {
	push (@MissingInformation, "<li>First Name missing or incomplete ");
	}
	unless (length($frm{'Ecom_Postal_Name_Last'}) > 0 ) {
	push (@MissingInformation, "<li>Last Name missing or incomplete ");
	}
	unless (length($frm{'Ecom_Postal_Street_Line1'}) > 0 ) {
	push (@MissingInformation, "<li>Street Address missing or incomplete ");
	}
	unless (length($frm{'Ecom_Postal_City'}) > 0 ) {
	push (@MissingInformation, "<li>City missing or incomplete ");
	}
	unless (length($frm{'Ecom_Postal_StateProv'}) > 0 ) {
	push (@MissingInformation, "<li>State-Province missing or incomplete ");
	}
	unless (length($frm{'Ecom_Postal_PostalCode'}) > 0 ) {
	push (@MissingInformation, "<li>Postal Code missing or incomplete ");
	}
	unless (length($frm{'Ecom_Postal_CountryCode'}) > 0 ) {
	push (@MissingInformation, "<li>Country missing or incomplete ");
	}
	unless (length($frm{'Ecom_Telecom_Phone_Number'}) > 0 ) {
	push (@MissingInformation, "<li>Phone Number missing or incomplete ");
	}
	unless (length($frm{'Ecom_DOB'}) > 3 ) {
	push (@MissingInformation, "<li>Date of Birth missing or incomplete ");
	}
	# Email validation	
	unless ($frm{'Ecom_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/) {
	push (@MissingInformation, "<li>Email Address does not appear to be valid.");
	}
	unless ($frm{'Ecom_Online_Email'} eq $frm{'Ecom_Online_Email_Check'} ) {
	push (@MissingInformation, "<li>Email Addresses are not the same. Check closely. ");
	}

	# PSWD validation
	unless (length($frm{'Ecom_Password'}) > 7 ) {
	push (@MissingInformation, "<li>Password must have at least 8 characters - numbers and/or letters. ");
	}
	if ($frm{'Ecom_Password'} =~ /\D\W/g) {
	push (@MissingInformation, "<li>Only Numbers and/or Letters allowed for Password. Reenter Password.");
	}
	unless ($frm{'Ecom_Password'} eq $frm{'Ecom_Password_Check'} ) {
	push (@MissingInformation, "<li>Passwords are not the same. Retype Passwords.");
	}

	# Check only if all else is okay
	&ValidateEmailAddr unless (scalar(@MissingInformation));

	# Validate Rep Number
	unless (scalar(@MissingInformation)) {
	&ValidateRepNumber if ($frm{'Ecom_Rep_Number'});
	}

	return @MissingInformation;
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

# PASS ERROR MESSAGE
sub ErrorMessage {
	my ($Err) = @_;
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Errors Occurred</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";
	print "<h3>Error Message</h3>";
      	print "<h4>$Err</h4>\n";
	print "Please Contact: <a href=\"mailto:$email_address\">$email_address</a><p>" if ($email_address);
	print "<li><u>Data Processing Information Available</u><br>";
	print "<li>Referring URL: $ENV{'HTTP_REFERER'}" if ($ENV{'HTTP_REFERER'});
	print "<li>Server Name: $ENV{'SERVER_NAME'}" if ($ENV{'SERVER_NAME'});
	print "<li>Remote Host: $ENV{'REMOTE_HOST'}" if ($ENV{'REMOTE_HOST'});
	print "<li>Remote Addr: $ENV{'REMOTE_ADDR'}" if ($ENV{'REMOTE_ADDR'});
	print "<li>Remote User: $ENV{'REMOTE_USER'}" if ($ENV{'REMOTE_USER'});
	print "</body></html>";
	exit;	
	}

# FIND RANDOM COUPON
sub RandomCouponCode {
	my ($test) = 0;
	my ($firstdigits);
		while ($test < 6) {
		$RandomCode = $RandomCode . int(rand 999);
		$test = length($RandomCode);
		}
	$firstdigits = substr ($globalyear,0,1);
	$firstdigits = $firstdigits . substr ($globalyear,3,1);
	$RandomCode = $firstdigits . $RandomCode;
	return $RandomCode;
	}

# CHECK COUPON FILE FOR DUPS	
sub ValidateCouponNumber {
	my ($code, $rate) = (0,0);
		foreach (@CouponCodes) {
		($code, $rate) = split (/\|/, $_);
			if ($code == $RandomCode) {
			$RandomCode = 0;
			last;
			}
		}
	}

# CHECK PSWDFILE FOR EMAIL DUPS
sub ValidateEmailAddr {
	my (@EmailAddr) = ();
	my ($addr, $pswd);
	unless (open (PFILE, "$pswdfile_path") ) { 
	$ErrMsg = "Unable to Locate the Email Data File";
	&ErrorMessage($ErrMsg);
	}
	flock (PFILE, 2) if ($lockfiles);
	@EmailAddr = <PFILE>;
	foreach (@EmailAddr) {
	($addr, $pswd) = split (/\|/, $_);
	if ($frm{'Ecom_Online_Email'} eq $addr) {
	push (@MissingInformation, "<li>Email <font color=red> $frm{'Ecom_Online_Email'} </font> already in use.");
	last;
	}}
	@EmailAddr = ();
	}

# VALIDATE REP NUMBER
sub ValidateRepNumber {
	my (@RepCodes) = ();
	my ($RepCheck) = 0;
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (RFILE, "$repinfo_path") ) { 
	$ErrMsg = "Unable to Locate the Rep Info File";
	&ErrorMessage($ErrMsg);
	}
	flock (RFILE, 2) if ($lockfiles);
	@RepCodes = <RFILE>;
	foreach (@RepCodes) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ( $i2 == $frm{'Ecom_Rep_Number'} ) {
		$RepCheck ++;
		last;
		}
	}
	unless ($RepCheck) {
	$repmsg = "<li>Representative Number <strong>$frm{'Ecom_Rep_Number'}</strong> not valid<br>";
	$repmsg = $repmsg . "re-enter a correct Rep Number or leave blank.";
	push (@MissingInformation, "$repmsg");
	}
	close(RFILE);
	@RepCodes = ();
	}

# GET REP LIST
sub GetRepList {
	my (@RepRecords) = ();
	my (@SortTemp) = ();
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (RFILE, "$repinfo_path") ) { 
	$ErrMsg = "Unable to Locate the Rep Info File";
	&ErrorMessage($ErrMsg);
	}
	flock (RFILE, 2) if ($lockfiles);
	@RepRecords = <RFILE>;
	close(RFILE);

	# Sort by Last Name
	foreach (@RepRecords) {
	($i3, $i4, $i5, $i2, $i1, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
	$_ = join ('|', ($i1, $i2, $i4, $i8, $i9, $i11));
	push (@SortTemp, $_);
	}
	@REPLIST = sort (@SortTemp);
	@RepRecords = ();
	@SortTemp = ();
	return (@REPLIST);
	}

# GET REP RECORD
sub GetRepRecord {
	my ($Rnum) = @_;
	my (@RepCodes) = ();
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	unless (open (RFILE, "$repinfo_path") ) { 
	$ErrMsg = "Unable to Locate the Rep Info File";
	&ErrorMessage($ErrMsg);
	}
	flock (RFILE, 2) if ($lockfiles);
	@RepCodes = <RFILE>;
	close(RFILE);
	foreach (@RepCodes) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ( $i2 == $Rnum ) {
		$REPRECORD = $_;
		last;
		}
	}
	@RepCodes = ();
	return ($REPRECORD);
	}

# APPEND PSWD FILE
sub Append_To_PSWDFile {
	unless (open (PFILE, ">>$pswdfile_path") ) { 
	$ErrMsg = "Unable to Write To PSWD File";
	&ErrorMessage($ErrMsg);
	}
	flock (PFILE, 2) if ($lockfiles);
	$_ = $frm{'Ecom_Online_Email'};
	$_ = $_ . "\|";
	$_ = $_ . $frm{'Ecom_Password'};
	print PFILE "$_\n";
	}

# APPEND COUPON FILE
sub Append_To_CouponFile {
	unless (open (CFILE, ">>$couponfile_path") ) { 
	$ErrMsg = "Unable to Write To Coupon File";
	&ErrorMessage($ErrMsg);
	}
	flock (CFILE, 2) if ($lockfiles);
	$_ = $RandomCode;
	$_ = $_ . "\|";
	$_ = $_ . $discount;
	$_ = $_ . "\|";
	$_ = $_ . $affiliate_rate;
	print CFILE "$_\n";
	}

# APPEND MAIN INFO FILE
sub Append_To_InfoFile {
	unless (open (IFILE, ">>$infofile_path") ) { 
	$ErrMsg = "Unable to Write To Main Information File";
	&ErrorMessage($ErrMsg);
	}
	flock (IFILE, 2) if ($lockfiles);
	$_ = $ShortDate;
	$_ = $_ . "\|";
	$_ = $_ . $frm{'Ecom_Online_Email'};
	$_ = $_ . "\|";
	$_ = $_ . $RandomCode;
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
	$_ = $_ . $frm{'Ecom_Rep_Number'};
	print IFILE "$_\n";
	}

# ILLEGAL USE
sub IllegalUse {
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Data Processing</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";
	print "<center><table bgcolor=#FFCE00 border=0 cellpadding=2 cellspacing=0 width=400> ";
	print "<tr><td align=center> ";
	print "$font <b> Data Processing Message </b></font> ";
	print "<table bgcolor=#FFFFE6 border=0 cellpadding=6 cellspacing=0 width=100%><tr><td> ";
	print "<font size=2 color=navy><br> ";
	print "<center><strong>NOTICE - NOTICE - NOTICE</strong></center><p> ";
	print "$font2 ";
	print "
	Your browser is not permitted to access this script this way. <p>
	You may be attempting to page back or page forward with your browser where
	a page has expired on the server or in your browser's cache <p>
	Use the sign-up area for Affiliate Accounts <p>
	<center>
	<strong>
	<a href=\"$signup_url\">
	Click Here For Affiliate Sign-up </a> </strong> </center> <p>
	";
	print " </font> \n\n";
	print "</td></tr></table> \n\n";
	print "</td></tr></table></center><p> \n\n";
	print "<font size=3 color=black> ";
	print "<li>Local Time: $Date $Time<br>";
	print "<li>Referring URL: $ENV{'HTTP_REFERER'}" if ($ENV{'HTTP_REFERER'});
	print "<li>Server Name: $ENV{'SERVER_NAME'}" if ($ENV{'SERVER_NAME'});
	print "<li>Remote Host: $ENV{'REMOTE_HOST'}" if ($ENV{'REMOTE_HOST'});
	print "<li>Remote Addr: $ENV{'REMOTE_ADDR'}" if ($ENV{'REMOTE_ADDR'});
	print "<li>Remote User: $ENV{'REMOTE_USER'}" if ($ENV{'REMOTE_USER'});
	print "</body></html>";
	exit;	
	}

# SET DATE
sub SetDateVariable {
	local (@months) = ('January','February','March','April','May','June','July',
			'August','September','October','November','December');
	local (@days) = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
 	local ($sec,$min,$hour,$mday,$mon,$year,$wday) = (localtime(time))[0,1,2,3,4,5,6];
	$year += 1900;	
	$globalyear = $year;
 	$Date = "$days[$wday], $months[$mon] $mday, $year";
 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mon+1,'/',$mday,'/',$year);
 	$Time = sprintf("%02d%1s%02d%1s%02d",$hour,':',$min,':',$sec);
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour<12);
	$ShortTime="12:".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour==0);
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour==12);
	$ShortTime=($hour-12).":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour>12);
	}

# CHECK ALLOWED DOMAINS
sub CheckAllowedDomains {
	my ($domain_approved) = 0;
	my ($domain_referred) = $ENV{'HTTP_REFERER'};
	$domain_referred =~ tr/A-Z/a-z/;
  	foreach (@ALLOWED_DOMAINS) {
	if ($domain_referred =~ /$_/ || !$ENV{'HTTP_REFERER'}) { 
	$domain_approved++;	
	}}
	unless ($domain_approved) {
	$ErrMsg="This is not an authorized input area <br>";
	$ErrMsg=$ErrMsg . "$ENV{'HTTP_REFERER'} <p>";
	$ErrMsg=$ErrMsg . "These are the only authorized input areas:<br>";
	foreach (@ALLOWED_DOMAINS) {
	$ErrMsg=$ErrMsg . "<a href=\"$_\">$_</a><br>";
	}
	$ErrMsg=$ErrMsg . "<p>Contact Web Developer about this Error <br>";
	&ErrorMessage($ErrMsg);
	}
	}

# REGISTRATION SUCCESSFUL	
sub RegistrationSuccessful {
	my ($prate) = ($discount * 100);
	my ($arate) = ($affiliate_rate * 100);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";

	print "<strong><font color=#800000>REGISTRATION WAS SUCCESSFUL!</font> </strong><p> ";
	print "$font2 
	Welcome to our Affiliate Referral Earnings Program.<br>
	You have successfully registered as an Affiliate Partner.<br>
	Your private online account has been established, and your account information appears below.
	<p>
	You may want to print this page for your permanent records.<br>
	This information has also been emailed to you at: 
	<font color=#800000>$frm{'Ecom_Online_Email'}</font>
	<p></font> \n\n
	";

	print "<table border=0 cellpadding=1 cellspacing=0 bgcolor=$table_dark width=100\%><tr><td> ";
	print "$font2 <strong>Account Information</strong> </font></td></tr></table> \n"; 
	print "$font2 ";
	print "<ul> \n";
	print "<li>Account Activated: <strong>$ShortDate </strong> \n";
	print "<li>Your Unique Affiliate Number: <strong>$RandomCode </strong> \n";
	print "<li>Your User ID: <strong>$frm{'Ecom_Online_Email'} </strong> \n";
	print "<li>Beginning Customer Discount Rate: <strong>$prate\% </strong> \n";
	print "<li>Beginning Affiliate Earnings Rate: <strong>$arate\% </strong> \n";
	print "<li>Your Account Password has been emailed to you </ul></font>\n";
	print "<table border=0 cellpadding=1 cellspacing=0 bgcolor=$table_dark width=100\%><tr><td> ";
	print "$font2 <strong>Registration Information </strong> </font></td></tr></table> \n"; 
	print "$font2 ";
	print "<ul> \n";
	print "<li>$frm{'Ecom_Postal_Name_First'} $frm{'Ecom_Postal_Name_Last'} \n";
	print "<li>$frm{'Ecom_Postal_Street_Line1'} \n";
	print "<li>$frm{'Ecom_Postal_Street_Line2'} \n" if ($frm{'Ecom_Postal_Street_Line2'});
	print "<li>$frm{'Ecom_Postal_City'}, $frm{'Ecom_Postal_StateProv'} $frm{'Ecom_Postal_PostalCode'} \n";
	print "<li>$frm{'Ecom_Postal_CountryCode'} \n";
	print "<li>Phone: $frm{'Ecom_Telecom_Phone_Number'} \n";
	print "<li>DOB: $frm{'Ecom_DOB'} \n";
	print "</ul></font><p>";

	if ($REPRECORD) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $REPRECORD);
	print "<table border=0 cellpadding=1 cellspacing=0 bgcolor=$table_dark width=100\%><tr><td> ";
	print "$font2 <strong>Representative Information</strong> </font></td></tr></table> \n"; 
	print "$font2 ";
	print "<ul> \n";
	print "<li> $i4 $i5 <strong># $i2</strong> \n";
	print "<li>$i6 \n" if ($allow_rep_info);
	print "<li>$i7 \n" if ($i7 && $allow_rep_info);
	print "<li>$i8, $i9 $i10, $i11 \n" if ($allow_rep_info);
	print "<li>Phone: $i12 \n" if ($allow_rep_info);
	print "<li>eMail: <a href=\"mailto:$i14\">$i14</a> \n";
	print "</ul><font><p> ";
	} else {
		if ($frm{'Ecom_Rep_Number'}) {
		print "$font2";
		print "Representative Information not available </font><p> \n";	
		}
	}

	print "<table border=0 cellpadding=1 cellspacing=0 bgcolor=$table_dark width=100\%><tr><td> ";
	print "$font2 <strong>How The Program Works</strong> </font></td></tr></table> \n"; 
	print "$font2 ";
	print "$HowItWorksMessage";
	print "</font><p> ";

	# how to set up links
	print "<table border=0 cellpadding=1 cellspacing=0 bgcolor=$table_dark width=100\%><tr><td> ";
	print "$font2 <strong>How To Set Up Affiliate Links</strong> </font></td></tr></table><p> \n"; 
	print "$font2 ";
	print "Cut and paste HTML code for a simple text link: <p> \n";
	print qq~
	<table cellpadding="4" cellspacing="0" border="1" width="100%" bgcolor="#EEEEEE">
	<tr><td bgcolor="$table_light">
	<font face="Arial" size="2">
	~;
	print "&lt;a href=&quot;$ares_url?ID=";
	print "$RandomCode";
	print '&quot;&gt;';
	print "
	<br>
	Click Here&lt;/a&gt; for $business_name
	</font>
	</td></tr></table>
	<p>
	";
	print "Cut and paste link for email communication, discussion post, or newsletter ad: <p> \n";
	print qq~
	<table cellpadding="4" cellspacing="0" border="1" width="100%" bgcolor="$table_light">
	<tr><td bgcolor="$table_light">
	<font face="Arial" size="2">
	~;
	print "$ares_url?ID=";
	print "$RandomCode";
	print qq~
	</font>
	</td></tr></table>
	<p>
	~;
	print "Cut and paste HTML code for an image button link: <p> \n";
	print qq~
	<table cellpadding="4" cellspacing="0" border="1" width="100%" bgcolor="$table_light">
	<tr><td bgcolor="$table_light">
	<font face="Arial" size="2">
	~;
	print "&lt;a href=&quot;$ares_url?ID=";
	print "$RandomCode";
	print '&quot;&gt;';
	print "
	<br>
	&lt;img border=&quot;0&quot; src=&quot;$logo_url&quot;&gt;&lt;/a&gt;
	</font>
	</td></tr></table>
	<p>
	";
	print "$font2 
	Important Note: The above HTML code is pre-formatted 
	with your unique Affiliate Number. You may use any text or image to 
	facilitate the link, but the link destination must be exactly as 
	shown in the examples. 
	<p>
	</font>
	";
	print " 
	You will find more detailed information on setting up
    	affiliate links here: <br> ";
	print "<a href=\"$moreinfo_url\"> \n";
	print "$moreinfo_url</a> \n";
	print "</font><p> ";

	## how to access your account
	print "<table border=0 cellpadding=1 cellspacing=0 bgcolor=$table_dark width=100\%><tr><td> ";
	print "$font2 <strong>How To Access Your Account</strong> </font></td></tr></table><p> \n"; 
	print "$font2 ";
	print "
	This is the URL address of your online account: <br>
	";
	print "<a href=\"$usrmgt_url\"> ";
	print "$usrmgt_url</a> ";
	print "
	<p>
	When you reach
    	that page, login with your UserID and Password to view your account
   	activity, balance, payments, etc., and to edit your account information.
	<p>
	";
	print "</font> ";
	print "@footer \n\n";
	}

# VALIDATION FAILED
sub RegistrationFailed {
	my ($nfailed) = scalar(@MissingInformation);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";
	print "<strong>Please Try Again</STRONG><p>";
	$qty = "one field" if ($nfailed == 1);
	$qty = "$nfailed fields" if ($nfailed > 1);
	print "You have $qty missing or incomplete. <br>Use ";
	print "your <strong>browser back</strong> button ";
	print "and correct your information. <p>\n\n";
		print "<ol> ";		
		foreach (@MissingInformation) {print "$_ \n\n"}
		print "</ol> ";
		$brck = (scalar(@MissingInformation));
		while ($brck < 13) {
		print "<br>";
		$brck++;	
		}
	print "@footer \n\n";
	}

# REQUIRE REPRESENTATIVE
sub RequireRepresentative {
	my ($key, $val);
	my ($i1, $i2, $i3, $i4, $i5, $i6);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";
	print "<strong>Please Select Representative</STRONG><p>";
	print "Please select a representative from the list below. ";
	print "If you do not know your representative, then please contact us ";
	print "at <a href=\"mailto:$mail_info_questions\">$mail_info_questions</a>. <p>\n\n";
	print "<FORM action=\"$programfile\" method=\"post\"> \n";
	print "<select name=\"Ecom_Rep_Number\"> \n";
		print "<option value=\"\">Select Your Representative .. \n";
		print "<option value=\"\">------------------------------------------- \n";
		foreach (@REPLIST) {
		($i1, $i2, $i3, $i4, $i5, $i6) = split (/\|/, $_);
		print "<option value=\"$i3\">$i2 $i1 --> $i4, $i5, $i6 \n";
		}
	print "</select> \n";
	delete ($frm{'Ecom_Rep_Number'});
	while (($key, $val) = each (%frm)) { 
	print "<input type=\"hidden\" name=\"$key\" value=\"$val\">  \n";
	}
	print "<p><INPUT type=\"submit\" value=\"Continue\"> \n";
	print "</form> \n";
	print "<br><br><br><br><br><br><br><br>";
	print "@footer \n\n";
	}

# EMAIL ACCOUNT INFORMATION	
sub MailAccountInformation {
	my ($drate) = ($discount * 100);
	my ($mrate) = ($affiliate_rate * 100);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);

	# SEND MAIL --> REGISTRANT
	open (R_MAIL, "|$mail_program");
	## open (R_MAIL, ">R-MAIL.txt");

   	print R_MAIL "To: $frm{'Ecom_Online_Email'}\n";
	print R_MAIL "From: $mail_return_addr\n";
   	print R_MAIL "Subject: $business_name Affiliate Information\n\n";
	print R_MAIL "\n\n";
	print R_MAIL "$Date $ShortTime \n\n";
	print R_MAIL "Welcome, ";
	print R_MAIL "$frm{'Ecom_Postal_Name_First'} $frm{'Ecom_Postal_Name_Last'}";
	print R_MAIL ", to the $business_name Affiliate Referral Earnings Program. ";
	print R_MAIL "We're happy to have you as an Affiliate Partner. Your unique Affiliate Number is ";
	print R_MAIL "$RandomCode.  Your Affiliate Account is now open and ready to accept your referrals. \n\n";
	print R_MAIL "Please print and save this account information. \n\n";
	print R_MAIL "Your Account Information \n";
	print R_MAIL "   Account Activated: $ShortDate  \n";
	print R_MAIL "   Your Unique Affiliate Number: $RandomCode  \n";
	print R_MAIL "   Your User ID: $frm{'Ecom_Online_Email'}  \n";
	print R_MAIL "   Your Account Password: $frm{'Ecom_Password'} \n";
	print R_MAIL "   Beginning Customer Discount Rate: $drate\%  \n";
	print R_MAIL "   Beginning Affiliate Earnings Rate: $mrate\%  \n\n";
	print R_MAIL "Your Registration Information \n";
	print R_MAIL "   $frm{'Ecom_Postal_Name_First'} $frm{'Ecom_Postal_Name_Last'} \n";
	print R_MAIL "   $frm{'Ecom_Postal_Street_Line1'} \n";
	print R_MAIL "   $frm{'Ecom_Postal_Street_Line2'} \n" if ($frm{'Ecom_Postal_Street_Line2'});
	print R_MAIL "   $frm{'Ecom_Postal_City'}, $frm{'Ecom_Postal_StateProv'} $frm{'Ecom_Postal_PostalCode'} \n";
	print R_MAIL "   $frm{'Ecom_Postal_CountryCode'} \n";
	print R_MAIL "   Phone: $frm{'Ecom_Telecom_Phone_Number'} \n";
	print R_MAIL "   DOB: $frm{'Ecom_DOB'} \n\n";

	if ($REPRECORD) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $REPRECORD);
	print R_MAIL "Contacting Your Representative \n";
	print R_MAIL "   $i4 $i5 # $i2 \n";
	print R_MAIL "   $i6 \n" if ($allow_rep_info);
	print R_MAIL "   $i7 \n" if ($i7 && $allow_rep_info);
	print R_MAIL "   $i8, $i9 $i10, $i11 \n" if ($allow_rep_info);
	print R_MAIL "   Phone: $i12 \n" if ($allow_rep_info);
	print R_MAIL "   eMail: $i14 \n\n";
	} else {
		if ($frm{'Ecom_Rep_Number'}) {
		print R_MAIL "Representative Information not available \n\n";	
		}
	}

	print R_MAIL "How the Program Works: \n";
	print R_MAIL "$HowItWorksMailMessage";
	print R_MAIL "\n\n";
	print R_MAIL "How To Access Your Account \n\n";
	print R_MAIL "View your account status and edit your registration information ";
	print R_MAIL "at any time at this location: \n";
	print R_MAIL "$usrmgt_url \n";
	print R_MAIL "Login using your User ID (your email address) and Account Password. \n\n\n";
	print R_MAIL "How To Set Up Affiliate Links \n";

	print R_MAIL "
Cut and paste HTML code for a simple text link:

<a href=\"$ares_url?ID=$RandomCode\">
Click Here</a> for $business_name

Cut and paste link for email communication, discussion post, or newsletter ad:

$ares_url?ID=$RandomCode

Cut and Paste HTML code for an image button link:

<a href=\"$ares_url?ID=$RandomCode\">
<img border=\"0\" src=\"$logo_url\"></a>

Important Note: The above HTML code is pre-formatted with your unique Affiliate Number. You may use any text or image to facilitate the link, but the link destination must be exactly as shown in the examples.

You will find more detailed information on setting up affiliate links here:
$moreinfo_url


";	

	print R_MAIL "Once again, welcome to the $business_nam team. \n\n";
	print R_MAIL "Do you have questions? Just hit Reply, or email us at ";
	print R_MAIL "$mail_info_questions \n\n";
	print R_MAIL "-- $business_name \n";
	print R_MAIL "-- $business_url \n\n\n";
   	close (R_MAIL);
	}


# END MERCHANT ORDERFORM Cart ver 1.54
# Copyright by RGA http://www.merchantpal.com 2000-2001
