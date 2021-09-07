#!/usr/bin/perl
# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === ARES User Management ======================================== #
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

# ARES v2.5 - User Management
# ARES v2.5 - Affiliate Referral Earnings System 4-10-2001
# Copyright @ All Rights Reserved 2001 MerchantOrderForm.com / MerchantPal.com

# This script is the User Management portion of the ARES v2.5
# Provides Affiliates an online way to View Earnings, Change personal data, etc.

# CONFIGURATIONS
# Note: The delimiter for all files is "|"
# Note: If any user input has this it will be replaced with space

# ALLOW COMPLETE REP INFO ?
# Allow all Rep info to print in mail and messages to affiliate
# if (0) off only Name, number, and email will print
$allow_rep_info = 1;

# WHAT DOMAINS TO ALLOW POST FROM ?
#@ALLOWED_DOMAINS = (
#	"http://$ENV{SERVER_NAME}",
#	"https://$ENV{SERVER_NAME}",
#	"http://$ENV{HTTP_HOST}",
#	"https://$ENV{HTTP_HOST}"
#	);

# WHERE ARE THE DATA FILES KEPT ?
# All the data files should be behind Public Web areas
# Define the full absolute path, not an Http url

# Where's the Main Information file ?
$infofile_path = "$mvar_front_path_mcart/data/ares_infofile.dat";

# Where's the Coupon File ?
$couponfile_path = "$mvar_front_path_mcart/data/ares_couponcode.dat";

# Where's the PSWD File ?
$pswdfile_path = "$mvar_front_path_mcart/data/ares_pswdfile.dat";

# Where's the Affiliate Activity log ?
$activityfile_path = "$mvar_front_path_mcart/data/ares_activitylog.dat";

# Where's the Rep Info File ?
$repinfo_path = "$mvar_front_path_mcart/data/ares_repinfo.dat";

# VERY IMPORTANT .. VERY IMPORTANT .. VERY IMPORTANT
# THIS FEATURE MUST BE ENABLED WHEN THE SYSTEM GOES LIVE
$lockfiles = 1 unless ($^O =~ m/mswin32/i);

# WHERE IS THE TEMPLATE FILE KEPT ?
# This is also absolute path, not Http url
# or put it in your cgi-bin
$template = "$mvar_front_path_web/ares/temp_referral.html";

# Insert output at this point in template
$insertion_marker = '<!--INSERT_TEMPLATE_OUTPUT-->';

# MAIL PSWD OPTION
# If you want to turn off Mail Pswd as option for user mgmt
# Then set my $mail_program = '';
# It must be Null to turn off = '';
# It must be a loca var because <common.conf> uses the same setting for sendmail location
# Make sure you use only sendmail progs with -t switch
# Security holes exist with any other configuration or prog
# If this is disabled and user selects this action, they will get not in use message

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

# RESUBMIT CGI SCRIPT (This Script)
# This script either in native cgi-bin or Full url
$resubmit_file = "$mvar_front_http_mcart/user/usrmgt.cgi";

# USING FONTS - COLORS
# Assign light / dark table colors
$table_dark = '#CECE9C';
$table_light = '#EBEBD8';

# Assign font attributed used in html output
$font1 = '<font face="Arial, Verdana,Helvetica,Arial" size="1" color="#000000">';
$font2 = '<font face="Arial, Verdana,Helvetica,Arial" size="2" color="#000000">';
$font3 = '<font face="Arial, Verdana,Helvetica,Arial" size="3" color="#000000">';

# END OF CONFIGURATIONS	

# PROGRAM FLOW
&SetDateVariable;
&IllegalUse if ($ENV{'QUERY_STRING'});
&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
&ProcessForm;

# must submit 2 Field names
# To prevent a *.cgi? triggering script
&IllegalUse if (scalar(keys(%frm)) < 2);
&GetTemplateFile($template, "Template File");
@MissingInformation = ();
if ($frm{'ActionRequest'} eq "RESUBMIT") {&ValidateReSubmit} else {&ValidateForm}

	if (scalar(@MissingInformation)) {
	&ValidationError;
	exit;

	} elsif ($frm{'ActionRequest'} eq "RESUBMIT") {
	@ALLINFO = ();
	@ALLPSWD = ();
	# must validate that email addr is there to change
	# if resubmitting from cached form after effectively changing email
	# then the $frm{'OLD_PSWD'} will NOT be found to validate for login ...
	# Let's create a message sending them back to the log in page
	unless (&ValidateReturnEmailAddr) {
	$cache_err = "You may have changed your UserID <br>";
	$cache_err = $cache_err . "You'll need to Login with the New UserID <p> ";
	$cache_err = $cache_err . "<font color=red>Please go to the Login area and Start Over <p></font>";

	## $cache_err = $cache_err . "<a href=\"$usrmgt_url\"><strong>Click Here</strong></a> to Login";
	$cache_err = $cache_err . "<form  action=\"$usrmgt_url\"><input type=\"submit\" value=\"Login\"></form>";

	push (@MissingInformation, $cache_err);
	&ValidationCacheError;
	exit;	
	}


	# Ready to proceed, email addr exists in PSWD File
	# And as long as these scripts manage data the email must exist in info and pswd files	
	# must ReadWrite open both files before update operations begin
	# commence update operations once both files opened and locked
	# You'll know the following when you clear ValidateResubmit
	# =========================================================
	# 1. If email is changed edit both files (email is relational field)
	# 2. Elsif (email not changed) but Fields and Pswd change, still edit both files
	# 3. Elsif (email not changed) but Fields changed, Pswd not changed, edit only info file
	# 4. Elsif (email not changed), Fields not change, but Pswd changed, edit only pswd file

		$Upd_Function;
		if ($email_changed) {
		$Upd_Function = "EMAIL_UPDATE";
		&ReadWrite_PSWDFile;
		&ReadWrite_InfoFile;
		&Update_InfoFile;
		&Update_PSWDFile;
		close (IFILE);
		close (PFILE);

		} elsif ($fields_changed && $pswd_changed) {
		$Upd_Function = "FIELDS_PSWD_UPDATE";
		&ReadWrite_PSWDFile;
		&ReadWrite_InfoFile;
		&Update_InfoFile;
		&Update_PSWDFile;
		close (IFILE);
		close (PFILE);

		} elsif ($fields_changed && pswd_changed == 0) {
		$Upd_Function = "FIELDS_UPDATE";
		&ReadWrite_InfoFile;
		&Update_InfoFile;
		close (IFILE);

		} elsif ($pswd_changed && $fields_changed == 0) {
		$Upd_Function = "PSWD_UPDATE";
		&ReadWrite_PSWDFile;
		&Update_PSWDFile;
		close (PFILE);

		} else {
		$unkn_err = "<li><font color=red>An Unknown Error Has Occurred. Nothing Updated.</font>";
		push (@MissingInformation, $unkn_err);
		&ValidationError;
		exit;
		}
		# Updates completed


	## mail affiliate changes ?
	## You can provide email note of changes made
	&ResubmitApproved;

	} elsif ($frm{'ActionRequest'} eq "VIEW_ACTIVITY") {
		@ALLINFO = ();
		@ALLACTIVITY = ();
		&Read_InfoFile;
		&Read_ActivityFile;
		&ViewActivity;

	} elsif ($frm{'ActionRequest'} eq "CHANGE_INFO") {
		@ALLINFO = ();
		&Read_InfoFile;
		&EditAccountInfo;

	} elsif ($frm{'ActionRequest'} eq "EMAIL_PSWD") {
		$pass;
		&FindPSWD;
		unless ($pass) {
		$pmsg = "<li><font color=red>$frm{'Ecom_Online_Email'}</font> is not a valid User ID $ip";
		push (@MissingInformation, "$pmsg");
		&ValidationError;
		exit;	
		}
		@ALLINFO = ();
		&Read_InfoFile;
		&MailAccountInformation;
		&ReturnMailMessage;

	} else {
	&IllegalUse;
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
	unless ($frm{'Ecom_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/) {
	push (@MissingInformation, "<li>Email Address does not appear to be valid.");
	}
	unless ($frm{'ActionRequest'} eq "EMAIL_PSWD") {
	unless (length($frm{'Ecom_Password'}) > 7 ) {
	push (@MissingInformation, "<li>Password must have at least 8 characters. ");
	}
	if ($frm{'Ecom_Password'} =~ /\D\W/g) {
	push (@MissingInformation, "<li>Only Numbers - Letters allowed for Password. Reenter Password.");
	}
	}
	unless ($frm{'ActionRequest'}) {
	push (@MissingInformation, "<li>Select what action you want ? ");
	}
	if ($frm{'ActionRequest'} eq "EMAIL_PSWD") {
	unless ($mail_program) {
	push (@MissingInformation, "<li>Sorry, the feature <font color=red>Email Password</font> is not Enabled");
	}
	}
	unless ($frm{'ActionRequest'} eq "EMAIL_PSWD") {
	&ValidatePSWD unless (scalar(@MissingInformation));
	}
	return @MissingInformation;
	}

# VALIDATE RESUBMIT
sub ValidateReSubmit {
	$fields_changed = 0;
	$email_changed = 0;
	$pswd_changed = 0;
	$total_changed = 0;

	# any changes ?
	$fields_changed++ unless ($frm{'Ecom_Postal_Name_First'} eq $frm{'OLD_Name_First'});
	$fields_changed++ unless ($frm{'Ecom_Postal_Name_Last'} eq $frm{'OLD_Name_Last'});
	$fields_changed++ unless ($frm{'Ecom_Postal_Street_Line1'} eq $frm{'OLD_Street_Line1'});
	$fields_changed++ unless ($frm{'Ecom_Postal_Street_Line2'} eq $frm{'OLD_Street_Line2'});
	$fields_changed++ unless ($frm{'Ecom_Postal_City'} eq $frm{'OLD_City'});
	$fields_changed++ unless ($frm{'Ecom_Postal_StateProv'} eq $frm{'OLD_StateProv'});
	$fields_changed++ unless ($frm{'Ecom_Postal_PostalCode'} eq $frm{'OLD_PostalCode'});
	$fields_changed++ unless ($frm{'Ecom_Postal_CountryCode'} eq $frm{'OLD_CountryCode'});
	$fields_changed++ unless ($frm{'Ecom_DOB'} eq $frm{'OLD_DOB'});
	$fields_changed++ unless ($frm{'Ecom_Telecom_Phone_Number'} eq $frm{'OLD_Phone_Number'});
	if ($frm{'Ecom_Online_Email'}) {$email_changed++ unless ($frm{'Ecom_Online_Email'} eq $frm{'OLD_USRID'})}
	if ($frm{'Ecom_Password'}) {$pswd_changed++ unless ($frm{'Ecom_Password'} eq $frm{'OLD_PSWD'})}
	$total_changed = ($fields_changed + $email_changed + $pswd_changed);

	# if nothing changed - Error
	unless ($total_changed) {
	push (@MissingInformation, "<li><font color=red>You have not made any changes to Update</font>");
	&ValidationError;
	exit;
	}

	# validate info fields
	unless (length($frm{'Ecom_Postal_Name_First'}) > 0 ) {
	push (@MissingInformation, "<li>First Name missing or incomplete ")}
	unless (length($frm{'Ecom_Postal_Name_Last'}) > 0 ) {
	push (@MissingInformation, "<li>Last Name missing or incomplete ")}
	unless (length($frm{'Ecom_Postal_Street_Line1'}) > 0 ) {
	push (@MissingInformation, "<li>Street Address missing or incomplete ")}
	unless (length($frm{'Ecom_Postal_City'}) > 0 ) {
	push (@MissingInformation, "<li>City missing or incomplete ")}
	unless (length($frm{'Ecom_Postal_StateProv'}) > 0 ) {
	push (@MissingInformation, "<li>State-Province missing or incomplete ")}
	unless (length($frm{'Ecom_Postal_PostalCode'}) > 0 ) {
	push (@MissingInformation, "<li>Postal Code missing or incomplete ")}
	unless (length($frm{'Ecom_Postal_CountryCode'}) > 0 ) {
	push (@MissingInformation, "<li>Country missing or incomplete ")}
	unless (length($frm{'Ecom_Telecom_Phone_Number'}) > 0 ) {
	push (@MissingInformation, "<li>Phone Number missing or incomplete ")}

	# validate email if new one
	if ($email_changed) {
	unless ($frm{'Ecom_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/) {
	push (@MissingInformation, "<li>UserID (email address) does not appear to be valid.");
	}
	unless ($frm{'Ecom_Online_Email'} eq $frm{'Ecom_Online_Email_Check'} ) {
	push (@MissingInformation, "<li>UserIDs (email address) are not the same. Check closely. ");
	}
	}

	# don't put Reenter if not using
	if ($frm{'Ecom_Online_Email_Check'} && $email_changed == 0) {
	unless ($frm{'Ecom_Online_Email'} eq $frm{'Ecom_Online_Email_Check'} ) {
	push (@MissingInformation, "<li>UserID (email address) Unchanged. Don't Use Reenter UserID. ");
	}
	}

	# validate pswd if new one
	if ($pswd_changed) {
	unless (length($frm{'Ecom_Password'}) > 7 ) {
	push (@MissingInformation, "<li>Password must have at least 8 characters. ");
	}
	if ($frm{'Ecom_Password'} =~ /\D\W/g) {
	push (@MissingInformation, "<li>Only Numbers - Letters allowed for Password. Reenter Password.");
	}
	unless ($frm{'Ecom_Password'} eq $frm{'Ecom_Password_Check'} ) {
	push (@MissingInformation, "<li>Passwords are not the same. Retype Passwords");
	}
	}

	# don't put reenter if not using
	if ($frm{'Ecom_Password_Check'} && $pswd_changed == 0) {
	unless ($frm{'Ecom_Password'} eq $frm{'Ecom_Password_Check'} ) {
	push (@MissingInformation, "<li>Password is Unchanged. Don't Use Reenter Password");
	}
	}

	# if email changed check if in use
	# Doesn't check current email because it ain't changed
	# Check for duplicate email addr 
	# Check only if all else is okay
	if ($email_changed) {
	&ValidateEmailAddr unless (scalar(@MissingInformation));
	}

	return @MissingInformation;
	}


# GET TEMPLATE FILE
sub GetTemplateFile {
	my ($FilePath, $Type) = @_;
	my (@template) = ();
	my ($line, $switch) = ("",0);
	unless (open (FILE, "$FilePath") ) { 
	$ErrMsg = "Unable to Read $Type";
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

# CHECK ALLOWED DOMAINS
sub CheckAllowedDomains {
	my ($domain_approved) = 0;
	my ($domain_referred) = $ENV{'HTTP_REFERER'};
	$domain_referred =~ tr/A-Z/a-z/;
  	foreach (@ALLOWED_DOMAINS) {
     		if ($domain_referred =~ /$_/ || !$ENV{'HTTP_REFERER'}) { 
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
	$ErrMsg=$ErrMsg . "<p>Contact Web Developer about this Error <br>";
	&ErrorMessage($ErrMsg);
	}
	}

# PASS ERROR MESSAGE
sub ErrorMessage {
	my ($Err) = @_;
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Errors Occurred</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";
	print "<h3>Data Processing Error</h3>";
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

# VALIDATE PSWD
sub ValidatePSWD {
	my (@EmailAddr) = ();
	my ($addr, $pswd, $str, $pswdtest, $ip);
	$ip = "<ul>";
	$ip = $ip . "<font size=1 color=navy><li>$ENV{'REMOTE_ADDR'}</font>" if ($ENV{'REMOTE_ADDR'});
	$ip = $ip . "<font size=1 color=navy><li>$ENV{'REMOTE_HOST'}</font>" if ($ENV{'REMOTE_HOST'});
	$ip = $ip . "<font size=1 color=navy><li>$ENV{'REMOTE_USER'}</font>" if ($ENV{'REMOTE_USER'});
	$ip = $ip . "</ul>";
	unless (open (PFILE, "$pswdfile_path") ) { 
	$ErrMsg = "Unable to Complete Request 1";
	&ErrorMessage($ErrMsg);
	}
	flock (PFILE, 2) if ($lockfiles);
	@EmailAddr = <PFILE>;
	close(PFILE);
	chop (@EmailAddr);
	foreach (@EmailAddr) {
	($addr, $pswd) = split (/\|/, $_);
		if ($frm{'Ecom_Online_Email'} eq $addr) {
			$pswdtest = "FOUND";
			unless ($frm{'Ecom_Password'} eq $pswd) {
			$str = "Incorrect Login: <font color=red> $frm{'Ecom_Online_Email'} </font> ";
			push (@MissingInformation, "<li>$str $ip ");
			}
		}
	}
	unless ($pswdtest eq "FOUND") {
	$str = "Incorrect Login: <font color=red> $frm{'Ecom_Online_Email'} </font> ";
	push (@MissingInformation, "<li>$str $ip ");
	}
	@EmailAddr = ();
	}

# FIND PSWD
sub FindPSWD {
	$ip;
	my (@EmailAddr) = ();
	my ($addr, $pswd, $str, $pswdtest);
	$ip = "<ul>";
	$ip = $ip . "<font size=1 color=navy><li>$ENV{'REMOTE_ADDR'}</font>" if ($ENV{'REMOTE_ADDR'});
	$ip = $ip . "<font size=1 color=navy><li>$ENV{'REMOTE_HOST'}</font>" if ($ENV{'REMOTE_HOST'});
	$ip = $ip . "<font size=1 color=navy><li>$ENV{'REMOTE_USER'}</font>" if ($ENV{'REMOTE_USER'});
	$ip = $ip . "</ul>";
	unless (open (PFILE, "$pswdfile_path") ) { 
	$ErrMsg = "Unable to Complete Request 2";
	&ErrorMessage($ErrMsg);
	}
	flock (PFILE, 2) if ($lockfiles);
	@EmailAddr = <PFILE>;
	close(PFILE);
	chop (@EmailAddr);
	foreach (@EmailAddr) {
	($addr, $pswd) = split (/\|/, $_);
		if ($frm{'Ecom_Online_Email'} eq $addr) {
		$pswdtest = "FOUND";
		$pass = $pswd;
		$last;
		}
	}
	@EmailAddr = ();
	return $pass;
	}

# CHECK PSWDFILE FOR EMAIL DUPS
sub ValidateEmailAddr {
	my (@EmailAddr) = ();
	my ($addr, $pswd, $str);
	unless (open (PFILE, "$pswdfile_path") ) { 
	$ErrMsg = "Unable to Complete Request 3";
	&ErrorMessage($ErrMsg);
	}
	flock (PFILE, 2) if ($lockfiles);
	@EmailAddr = <PFILE>;
	foreach (@EmailAddr) {
	($addr, $pswd) = split (/\|/, $_);
	if ($frm{'Ecom_Online_Email'} eq $addr) {
	$str = "<li>UserID (email address) <font color=red> $frm{'Ecom_Online_Email'} </font> already in use <p>";
	$str = $str . "<form  action=\"$usrmgt_url\">$font2 <strong>If you just changed your UserID to ";
	$str = $str . "<font color=red> $frm{'Ecom_Online_Email'} </font> <br>";
	$str = $str . "You'll need to Login again under your New UserID </font><p>";
	$str = $str . "<input type=\"submit\" value=\"Login\"></form>";
	push (@MissingInformation, $str);
	last;
	}
	}
	close (PFILE);
	@EmailAddr = ();
	}

# CHECK THAT EMAIL ADDR HAS NOT BEEN REMOVED
sub ValidateReturnEmailAddr {
	$CacheError = 0;
	my (@EmailAddr) = ();
	my ($addr, $pswd);
	unless (open (PFILE, "$pswdfile_path") ) { 
	$ErrMsg = "Unable to Complete Request 4";
	&ErrorMessage($ErrMsg);
	}
	flock (PFILE, 2) if ($lockfiles);
	@EmailAddr = <PFILE>;
	foreach (@EmailAddr) {
	($addr, $pswd) = split (/\|/, $_);
	if ($frm{'OLD_USRID'} eq $addr) {
	$CacheError++;
	last;
	}
	}
	close (PFILE);
	@EmailAddr = ();
	return $CacheError;
	}

# READ-WRITE INFO FILE
sub ReadWrite_InfoFile {
	unless (open (IFILE, "+< $infofile_path") ) { 
	$ErrMsg = "Unable to Complete Request 5";
	&ErrorMessage($ErrMsg);
	}
	flock (IFILE, 2) if ($lockfiles);
	}

# READ-WRITE PSWD FILE
sub ReadWrite_PSWDFile {
	unless (open (PFILE, "+< $pswdfile_path") ) { 
	$ErrMsg = "Unable to Complete Request 6";
	&ErrorMessage($ErrMsg);
	}
	flock (PFILE, 2) if ($lockfiles);
	}

# UPDATE INFO FILE
sub Update_InfoFile {
	my ($icount) = 0;
	my ($istr);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	@ALLINFO = <IFILE>;
	seek (IFILE, 0, 0);
 	chop (@ALLINFO);

	# update operations
	foreach (@ALLINFO) {
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($i2 eq $frm{'OLD_USRID'}) {

		# construct new line
		$istr = $i1;
		$istr = $istr . "\|";
			if ($email_changed) {
			$istr = $istr . $frm{'Ecom_Online_Email'};
			} else {
			$istr = $istr . $i2;
			}
		$istr = $istr . "\|";
		$istr = $istr . $i3;
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
	}

# UPDATE PSWD FILE
sub Update_PSWDFile {
	my ($pcount) = 0;
	my ($pstr);
	my ($userid, $password);
	@ALLPSWD = <PFILE>;
	seek (PFILE, 0, 0);

	# update operations
	foreach (@ALLPSWD) {
	($userid, $password) = split (/\|/, $_);
		if ($userid eq $frm{'OLD_USRID'}) {
		# construct new line
		if ($email_changed) {
		$pstr = $frm{'Ecom_Online_Email'};		
		} else {
		$pstr = $userid;
		}
		$pstr = $pstr . "\|";
		if ($pswd_changed) {
		$pstr = $pstr . $frm{'Ecom_Password'};
		} else {
		$pstr = $pstr . $frm{'OLD_PSWD'};
		}
		$ALLPSWD[$pcount] = "$pstr\n";
		$debugpswd = $pstr;	
		$debugpcount = ($pcount + 1);
		}
	$pcount++;
	}
	foreach (@ALLPSWD) {print PFILE "$_"}
	truncate(PFILE, tell(PFILE));
	}

# READ INFO FILE
sub Read_InfoFile {
	unless (open (IFILE, "$infofile_path") ) { 
	$ErrMsg = "Unable to Complete Request 7";
	&ErrorMessage($ErrMsg);
	}
	flock (IFILE, 2) if ($lockfiles);
	@ALLINFO = <IFILE>;
	close(IFILE);
	chop (@ALLINFO);
	return @ALLINFO;
	}


# READ ACTIVITY FILE
sub Read_ActivityFile {
	unless (open (AFILE, "$activityfile_path") ) { 
	$ErrMsg = "Unable to Complete Request 8";
	&ErrorMessage($ErrMsg);
	}
	flock (AFILE, 2) if ($lockfiles);
	@ALLACTIVITY = <AFILE>;
	close(AFILE);
	chop (@ALLACTIVITY);
	return @ALLACTIVITY;
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
	Use the login area for Affiliate Account Management <p>
	<center>
	<strong>
	<a href=\"$usrmgt_url\">
	Click Here For Affiliate Management </a> </strong> </center> <p>
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

# VIEW ACTIVITY
sub ViewActivity {
	my (@activity) = ();
	my ($count) = 0;
	my ($found) = 0;
	my ($num) = 0;
	my ($strnum) = 0;
	my ($crate);
	my ($ErrStr);
	my ($Rnum);
	my ($amt_invoices, $amt_earned, $amt_paid, $amt_unpaid);
	my ($num_paid, $num_unpaid, $recno);
	my ($a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $a10);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14);

	## get registration information
	foreach (@ALLINFO) {
	++$count;
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($i2 eq $frm{'Ecom_Online_Email'}) {
		$Rnum = $i14;
		$found++;
		last; 
		}
	}
	@ALLINFO = ();
	unless ($found) {
	$ErrStr = "<li>Cannot Find Information for <font color=red>$frm{'Ecom_Online_Email'}</font>.";
	$ErrStr = $ErrStr . "<li>Contact site owner about this error.";
	push (@MissingInformation, $ErrStr);
	&ValidationError;
	exit;
	}

	# get all activity for this account
	foreach (@ALLACTIVITY) {
	($a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $a10) = split (/\|/, $_);
	push (@activity, $_) if ($i3 eq $a5);
	}
	@ALLACTIVITY = ();
	$num = (scalar(@activity));

	# get rep info for this account
	$REPRECORD = &GetRepRecord($Rnum) if ($Rnum);
	($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $REPRECORD);

	# print up all output
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";
	print "<strong>VIEWING ACCOUNT ACTIVITY </strong><p> ";

	if ($found) {
	print "<table border=0 cellpadding=0 cellspacing=2 width=100\%>";
	print "<tr>";
	print "<td align=center bgcolor=$table_dark>$font2 <strong>Affiliate Information</strong> </font></td> \n"; 

	if ($REPRECORD) {
	print "<td align=center bgcolor=$table_dark>$font2 <strong>Representative Information</strong> </font></td></tr> \n"; 
	} else {
	print "<td><br> </td></tr> \n"; 
	}

	print "<tr> ";
	print "<td bgcolor=#FBFBFF> $font2 \n";
	print "<li>Name: <strong>$i4 $i5 </strong>";
	print "<li>Activated: <strong>$i1 </strong> \n";
	print "<li>Number: <strong>$i3 </strong> \n";
	print "<li>User ID: <strong>$i2 </strong> \n";
	print "<li>Addr: $i6 \n";
	print "<li>Addr: $i7 \n" if ($i7);
	print "<li>Addr: $i8, $i9 $i10 \n";
	print "<li>Country: $i11 \n";
	print "<li>Phone: $i12 \n";
	print "<li>DOB: $i13 \n";
	print "</font></td> \n";
		if ($REPRECORD) {
	print "<td valign=top bgcolor=#FBFBFF> $font2 \n";
	print "<li>Name: <strong>$r4 $r5 </strong>";
	print "<li>Activated: <strong>$r1 </strong> \n" if ($allow_rep_info);
	print "<li>Number: <strong>$r2 </strong> \n";
	print "<li>Addr: $r6 \n" if ($allow_rep_info);
	print "<li>Addr: $r7 \n" if ($r7 && $allow_rep_info);
	print "<li>Addr: $r8, $r9 $r10 \n" if ($allow_rep_info);
	print "<li>Country: $r11 \n" if ($allow_rep_info);
	print "<li>Phone: $r12 \n" if ($allow_rep_info);
	print "<li>eMail: <a href=\"mailto:$r14\">$r14</a> \n";
	print "</font></td> \n";
		} else {
		print "<td><br> </td> ";
		}
	print "</tr></table> \n";
	} else {
	print "Cannot Find Information <font color=red> $frm{'Ecom_Online_Email'}. Contact Site Owner.</font>";
	}
	$strnum = "Records" if ($num > 1);
	$strnum = "Record" if ($num == 1);
	print "<p>";

	if ($num) {
	print "$font2 <strong> $num </strong> $strnum found for Affiliate Number: <strong>$i3 </strong> </font>";
	} else {
	print "$font2 No activity found for Affiliate Number: <strong>$i3 </strong> </font> <br><br><br><br>";
	}

	# begin printing tables
	if ($num) {
	print "<table border=0 bordercolor=#84B5CE cellpadding=0 cellspacing=2 width=100\%> \n";
	print "<tr bgcolor=$table_dark> \n";
	print "<td align=center>$font1 # </font></td>";
	print "<td align=center>$font1 Date </font></td>";
	print "<td align=center>$font1 Invc </font></td>";
	print "<td align=center>$font1 Sale </font></td>";
	print "<td align=center>$font1 Rate </font></td>";
	print "<td align=center>$font1 Earned </font></td>";
	print "<td align=center>$font1 Customer </font></td>";
	print "<td align=center>$font1 Paid </font></td>";
	print "</tr> ";

		my ($bgswitch) = 0;
		foreach (@activity) {
		($a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $a10) = split (/\|/, $_);
		$amt_invoices += $a4;
		$amt_earned += $a7;
		$amt_paid += $a9;
		$amt_unpaid += $a7 unless ($a9 > 0);
		$num_paid++ if ($a9 > 0);
		$num_unpaid++ unless ($a9 > 0);
		$crate = ($a6 * 100);
		++$recno;

		if ($bgswitch) {
		$bgswitch = 0;
		print "<tr bgcolor=#F9F9F9> \n";
		} else {
		$bgswitch = 1;
		print "<tr bgcolor=#F4FFF3> \n";
		}

		print "<td nowrap> $font1 $recno </font></td>";
		print "<td nowrap> $font1 $a1 </font></td>";
		print "<td nowrap> $font2 $a3 </font></td>";
		print "<td align=right> $font2 $a4 </font></td>";
		print "<td align=center nowrap> $font2 $crate\% </font></td>";

		if ($a7) {
		print "<td align=right nowrap> $font2 $a7 </font></td>";
		} else {
		print "<td align=right nowrap> $font2 0.00 </font></td>";
		}

		if ($a8) {
		print "<td nowrap> $font2 <a href=\"mailto:$a8\">$a8 <\/a> </font></td>";
		} else {
		print "<td nowrap><br> </td>";
		}

		if ($a10) {
		print "<td nowrap> $font1 $a10 </font></td>";
		} else {	
		print "<td nowrap><br> </font></td>";
		}
		print "</tr> ";
		}
		print "</table><br> ";

		# summary
 		$amt_invoices = sprintf "%.2f", $amt_invoices;
 		$amt_earned = sprintf "%.2f", $amt_earned;
 		$amt_paid = sprintf "%.2f", $amt_paid;
 		$amt_unpaid = sprintf "%.2f", $amt_unpaid;
		$amt_invoices = CommifyMoney($amt_invoices);
		$amt_earned = CommifyMoney($amt_earned);
		$amt_paid = CommifyMoney($amt_paid);
		$amt_unpaid = CommifyMoney($amt_unpaid);

	print "<table border=0 cellpadding=2 cellspacing=4 width=100\%> \n";
	print "<tr bgcolor=$table_dark><td>$font2 <strong>Account Summary</strong> </font></td></tr> ";
	print "<tr bgcolor=$table_light><td>";
	print "$font2 You had <strong>$num </strong> Customers use your Affiliate Number, Total Sales: \$ $amt_invoices </font></td></tr> \n";
	print "<tr bgcolor=$table_light><td>";
	print "$font2 Making your overall Total Affiliate Earnings To Date: \$ $amt_earned </font></td></tr> \n";
	print "<tr bgcolor=$table_light><td>";
	print "$font2 We have paid you earnings on <strong>$num_paid </strong> Invoices to Date, Total Paid: \$ $amt_paid </font></td></tr> \n";
	print "<tr bgcolor=$table_light><td>";
	print "$font2 You have <strong>$num_unpaid </strong> Invoices Awaiting Payment, Current Earnings: <strong>\$ $amt_unpaid </strong></font></td></tr> \n";
	print "</table><br><br>";
	@activity = ();
	}
	print "@footer \n\n";
	}

# EDIT INFORMATION
sub EditAccountInfo {
	my ($count) = 0;
	my ($found) = 0;
	my ($ErrStr);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);

	## get registration information
	foreach (@ALLINFO) {
	++$count;
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($i2 eq $frm{'Ecom_Online_Email'}) {
		$found++;
		last; 
		}
	}
	@ALLINFO = ();
	unless ($found) {
	$ErrStr = "<li>Cannot Find Information for <font color=red>$frm{'Ecom_Online_Email'}</font>.";
	$ErrStr = $ErrStr . "<li>Contact site owner about this error.";
	push (@MissingInformation, $ErrStr);
	&ValidationError;
	exit;
	}

	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";
	print "<strong>EDITING ACCOUNT INFORMATION </strong><p> ";
	print "You can change your information by editing this form <br> \n";
	print "and clicking the Enter Changes button below. \n";
	print "<FORM action=$resubmit_file method=post> \n";
	print "<input type=hidden name=\"ActionRequest\" value=\"RESUBMIT\"> \n";
	print "<input type=hidden name=\"OLD_PSWD\" value=\"$frm{'Ecom_Password'}\"> \n";
	print "<input type=hidden name=\"OLD_USRID\" value=\"$frm{'Ecom_Online_Email'}\"> \n";
	print "<input type=hidden name=\"OLD_Name_First\" value=\"$i4\"> \n";
	print "<input type=hidden name=\"OLD_Name_Last\" value=\"$i5\"> \n";
	print "<input type=hidden name=\"OLD_Street_Line1\" value=\"$i6\"> \n";
	print "<input type=hidden name=\"OLD_Street_Line2\" value=\"$i7\"> \n";
	print "<input type=hidden name=\"OLD_City\" value=\"$i8\"> \n";
	print "<input type=hidden name=\"OLD_StateProv\" value=\"$i9\"> \n";
	print "<input type=hidden name=\"OLD_PostalCode\" value=\"$i10\"> \n";
	print "<input type=hidden name=\"OLD_CountryCode\" value=\"$i11\"> \n";
	print "<input type=hidden name=\"OLD_DOB\" value=\"$i13\"> \n";
	print "<input type=hidden name=\"OLD_Phone_Number\" value=\"$i12\"> \n";
	print "<input type=hidden name=\"Ecom_Rep_Number\" value=\"$i14\"> \n";
	print "<table border=0 cellpadding=0 cellspacing=2> \n";
	print qq~
	<tr><td align=center bgcolor=$table_dark nowrap colspan="2">
 	<b>
 	<font face="Arial" size="2">
 	Account Holder Information</font></b></td> 
	</tr> 
	~;
	print "<tr><td align=right bgcolor=$table_light nowrap>$font2 First Name:</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Postal_Name_First\" value=\"$i4\" size=30></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap>$font2 Last Name:</font></td> \n"; 
	print "<td bgcolor=$table_dark> $font2 ";
	print "<input name=\"Ecom_Postal_Name_Last\" value=\"$i5\" size=30></font> </td></tr> \n";
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Street Address 1:</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line1\" value=\"$i6\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Street Address 2:</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Postal_Street_Line2\" value=\"$i7\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap>$font2 City</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Postal_City\" value=\"$i8\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 State - Province</font></td> \n"; 
	print "<td bgcolor=$table_dark> $font2 ";
	print "<input name=\"Ecom_Postal_StateProv\" value=\"$i9\" size=30></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Postal Code:</font></td> \n"; 
	print "<td bgcolor=$table_dark> $font2 ";
	print "<input name=\"Ecom_Postal_PostalCode\" value=\"$i10\" size=30></font> </td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Country</font></td> \n"; 
	print "<td bgcolor=$table_dark> $font2 ";
	print "<input name=\"Ecom_Postal_CountryCode\" value=\"$i11\" size=30></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Date of Birth</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_DOB\" value=\"$i13\" size=30></font></td></tr> \n";
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Phone Number</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Telecom_Phone_Number\" value=\"$i12\" size=30></font> </td></tr> \n"; 
	print "</table><p> \n";
	print "$font2 <strong>Leave this blank unless you want to change your email or password</strong>.<br> ";
	print "Your current UserID: <font color=red>$i2</font> <p> \n";
	print "<table border=0 cellpadding=2 cellspacing=0> \n";
	print qq~
	<tr><td align=center bgcolor=$table_dark nowrap colspan="2">
 	<b>
 	<font face="Arial" size="2">
 	To change UserID only</font></b></td> 
	</tr> 
	~;
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 New UserID (email)</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Online_Email\" size=35></font></td></tr> \n"; 
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Reenter UserID (email)</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Online_Email_Check\" size=35></font></td></tr> \n";
	print "<tr><td align=right nowrap><br></td> \n"; 
	print "<td><br></td></tr> \n";
	print qq~
	<tr><td align=center bgcolor=$table_dark nowrap colspan="2">
 	<b>
 	<font face="Arial" size="2">
 	To change Password only</font></b></td> 
	</tr> 
	~;
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 New Password</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Password\" size=35 type=\"password\"></font></td></tr> \n";
	print "<tr><td align=right bgcolor=$table_light nowrap> $font2 Reenter Password</font></td> \n"; 
	print "<td bgcolor=$table_dark>$font2 ";
	print "<input name=\"Ecom_Password_Check\" size=35 type=\"password\"></font></td></tr> \n"; 
	print qq~
	<tr><td align=center nowrap colspan="2">
 	<font face="Arial" size="2">
	<br>
	</font></b></td> 
	</tr> 
	~;
	print qq~
	<tr><td align=center nowrap colspan="2">
 	<font face="Arial" size="2">
	<INPUT type=Submit value="Enter Changes">
	</font></b></td> 
	</tr> 
	~;
	print "</table></FORM> \n";
	print "@footer \n\n";
	}

# VALIDATION ERROR
sub ValidationError {
	my ($nfailed) = scalar(@MissingInformation);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";

	if ($frm{'ActionRequest'} eq "RESUBMIT") {
	print "<strong>CHANGE REQUEST FAILED</STRONG><p>";
	print "Update Errors Found. <br>Use ";
	print "your <strong>browser back</strong> button to return to editing your account information ";
	print "and correct any errors.<p>\n\n";
	} else {
	print "<strong>LOGIN FAILED</STRONG><p>";
	print "Login Errors. Use ";
	print "your <strong>browser back</strong> button to return to the Login ";
	print "area and correct any errors. <br>Information about this login attempt has been recorded. <p>\n\n";
	}
		
	print "Error Detail: <p> ";
	print "<ol> ";		
	foreach (@MissingInformation) {
	print "$_ \n\n";
	}
	print "</ol> ";
	
	$brck = (scalar(@MissingInformation));
	while ($brck < 9) {
	print "<br>";
	$brck++;	
	}
	print "@footer \n\n";
	}

# VALIDATION CACHE ERROR
sub ValidationCacheError {
	my ($nfailed) = scalar(@MissingInformation);
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";
	print "<strong>CHANGE REQUEST FAILED</STRONG><p>";
	print "Error Detail: <p> ";
	print "<ol> ";		

	foreach (@MissingInformation) {
	print "$_ \n\n";
	}
	print "</ol> ";
	$brck = (scalar(@MissingInformation));
	while ($brck < 9) {
	print "<br>";
	$brck++;	
	}
	print "@footer \n\n";
	}

# BROWSER MESSAGE
sub ReturnMailMessage {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";
	print "<strong>USER INFORMATION MAILED</STRONG><p>";
	print "
	Account information has been mailed to <font color=red> 
	$frm{'Ecom_Online_Email'} </font>. <p>\n\n";
	print "<BR><BR><BR><BR><BR><BR><BR><BR><BR>";
	print "@footer \n\n";
	}

# RESUBMIT APPROVED
sub ResubmitApproved {
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$font2 \n\n";
	print "$Date $ShortTime </font><p> $font2";
	print "<strong>CHANGE REQUEST SUCCESSFUL</STRONG><p>";
	# DEBUG
	# print "<ul><li>fields_changed = $fields_changed ";
	# print "<li>email_changed = $email_changed ";
	# print "<li>pswd_changed = $pswd_changed ";
	# print "<li>Upd_Function = $Upd_Function";
	# print "<li>CACHE_ERROR = $CacheError ";
	# print "<li>$debugicount $debuginfo";
	# print "<li>$debugpcount $debugpswd </ul>";

	print "$font2 ";
	print "<u><strong>What You Changed</strong></u>:<p> ";
	print "<ul> ";

	if ($fields_changed) {
	print "<li>You changed Registration Information <br>" ;
	print "$font2 <strong>";
	print "$frm{'Ecom_Postal_Name_First'} $frm{'Ecom_Postal_Name_Last'} <br> ";
	print "$frm{'Ecom_Postal_Street_Line1'} <br>";
	print "$frm{'Ecom_Postal_Street_Line2'} <br>" if ($frm{'Ecom_Postal_Street_Line2'});
	print "$frm{'Ecom_Postal_City'}, $frm{'Ecom_Postal_StateProv'} $frm{'Ecom_Postal_PostalCode'} ";
	print "$frm{'Ecom_Postal_CountryCode'} </strong><br> ";
	print "DOB: $frm{'Ecom_DOB'}<br>" if ($frm{'Ecom_DOB'});
	print "Phone: $frm{'Ecom_Telecom_Phone_Number'}" if ($frm{'Ecom_Telecom_Phone_Number'});
	print "<p></font>";
	}
	print "$font2<li>You changed your Password </font><p>" if ($pswd_changed);
	
	if ($email_changed) {
	print "<li>$font2 \n";
	print "You changed your UserID </font>";
	print "$font2 <form  action=\"$usrmgt_url\">\n";
	print "<strong>You'll need to Login in with your new UserID <br>";
	print "to access your Account Information further</strong><p>";
	print "<input type=\"submit\" value=\"Login\"></form></font>";
	}
	print "</ul>";
	print "<br><br><br>";
	print "<br><br><br><br>" unless ($fields_changed);
	print "@footer \n\n";
	}

# EMAIL ACCOUNT INFORMATION	
sub MailAccountInformation {
	my ($count, $found);
	my ($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14);
	my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14);

	## get registration information
	foreach (@ALLINFO) {
	++$count;
	($i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9, $i10, $i11, $i12, $i13, $i14) = split (/\|/, $_);
		if ($i2 eq $frm{'Ecom_Online_Email'}) {
		$Rnum = $i14;
		$found++;
		last; 
		}
	}
	@ALLINFO = ();
	unless ($found) {
	push (@MissingInformation, "<li>Cannot Find Information for <font color=red>$frm{'Ecom_Online_Email'}</font>");
	&ValidationError;
	exit;
	}

	# get rep info for this account
	$REPRECORD = &GetRepRecord($Rnum) if ($Rnum);

	# SEND MAIL --> REGISTRANT
	open (R_MAIL, "|$mail_program");
	# debug to txt file
	# open (R_MAIL, ">R-MAIL.txt");
   	print R_MAIL "To: $frm{'Ecom_Online_Email'}\n";
	print R_MAIL "From: $mail_return_addr\n";
   	print R_MAIL "Subject: $business_name Information\n\n";
	print R_MAIL "$Date $ShortTime \n";

	print R_MAIL "
A request for account information has been requested for the UserID $frm{'Ecom_Online_Email'}.  This message is being sent only to $frm{'Ecom_Online_Email'}, and can only be retrieved by someone who has permission to download email at this address. 

You should not give others access to your email accounts if you do not want them to view important information such as this.

";

	print R_MAIL "Account Information \n";
	print R_MAIL "========================== \n";
	print R_MAIL "Account Activated: $i1 \n";
	print R_MAIL "Your Affiliate Number: $i3  \n";
	print R_MAIL "Your User ID: $frm{'Ecom_Online_Email'}  \n";
	print R_MAIL "Your Account Password: $pass \n\n";

	print R_MAIL "Registration Information \n";
	print R_MAIL "========================== \n";
	print R_MAIL "$i4 $i5 \n";
	print R_MAIL "$i6 \n";
	print R_MAIL "$i7 \n" if ($i7);
	print R_MAIL "$i8, $i9 $i10 $i11 \n";
	print R_MAIL "Phone: $i12 \n";
	print R_MAIL "DOB: $i13 \n\n";

	if ($REPRECORD) {
	($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10, $r11, $r12, $r13, $r14) = split (/\|/, $REPRECORD);

	print R_MAIL "Representative Information \n";
	print R_MAIL "========================== \n";
	print R_MAIL "$r4 $r5 # $r2 \n";
	print R_MAIL "$r6 \n" if ($allow_rep_info);
	print R_MAIL "$r7 \n" if ($r7 && $allow_rep_info);
	print R_MAIL "$r8, $r9 $r10, $r11 \n" if ($allow_rep_info);
	print R_MAIL "Phone: $r12 \n" if ($allow_rep_info);
	print R_MAIL "eMail: $r14 \n\n";
	}

	print R_MAIL "You will need your User ID (your email address) and your Password to ";
	print R_MAIL "manage your account.  You can change your registration information, or ";
	print R_MAIL "view your current Affiliate activity by logging in here: \n\n";
	print R_MAIL "$usrmgt_url \n\n";
	print R_MAIL "Questions ? Just hit Reply on your email program \n";
	print R_MAIL "-- or email $mail_info_questions \n\n";
	print R_MAIL "-- $business_name \n";
	print R_MAIL "-- $business_url \n\n\n";
	close (R_MAIL);
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
