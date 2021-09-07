#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === CGI SERVER INSTALL UTILITY ================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  й 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #
# Encryption and Decryption : http://www.smartCGIs.com
# (c) copyright 2000 SmartCGIs.com : Jimmy (wordx@hotmail.com)
# genPsw idea by Scott Stolpmann 2-19-2000 : Alpha-Numerical Generator
# DHTML-Javascript popup : Spriteworks Developments, http://www.spriteworks.com

# Note: I originally set the "mkdir" syntax as [mkdir FILE] 
# and found some older versions of perl & OS (freebsd) require that permission params be
# set for the mkdir function. The <setup.cgi> was updated in the distribution 
# on : January 26, 2004 7:04:24 AM, to specify Mask in mkdir, and I am hoping that
# syntax has wider reliability than the former
# Current syntax : mkdir ("FILE",MASK);

# WARNING -- WARNING -- any positive value for this setting will OVERWRITE FILES
# NEVER enable this setting unless you are very clear of the consequences
# ALWAYS -- ALWAYS -- Keep a good backup of everything before overwriting anything
# $overwrite_files = 0;

# selects template pkg to install
# only 2 for now (1) boxed (2) ver25
# Note: must add new template pkgs to unpack & settings below
# this just assigns which pkg gets actually copied to site

$usepkg = 'ver25';
$usepkg = 'boxed';

# frmFUNCTIONs
# (1) AGREEMENT
# (2) SETTINGS
# (3) TESTING
# (4) MAKEDIRS
# (5) REPLACE
# (6) FINISH

# <setup.cgi> is the Short Version of install
# STILL TO DO : September 07, 2003 10:29:26 PM
# What is that NS anomoly on submit AGREEMENT ??
# still need error trap for mkdir in sub MAKEDIR, 
# do the unpack after MAKEDIRS
# check that the HTTPS = on works on both linux/win32 ---- DOES NOT
#### Gonna have to come up with something for unable to write to apache apache u/g
#### need the setup.cgi script running under UID credentials

# If you are on Win32 / IIS you *must* let this script create all Dirs/Files
# So script based access privilages are established
# IIS admin must enable script privilages for the initial ../cgi-bin/mcart DIR

# It's very important that you *only* use the 'mcart' directory name to install from
# as described in the instructions below

# (1) On the server, make a Dir called "mcart" inside your ../cgi-bin/ or ../script/ Dir
# (2) Upload the Tar.Gz to the new "mcart" Dir on the server
# (3) Upload this script <setup.cgi> to the new "mcart" Dir on the server
      # Important: upload this <setup.cgi> script in ASCII mode *only*
# (4) Set permissions on this file <setup.cgi> to 755 (if linux/unix)
# (5) Close your FTP client, and open your web browser
      # and enter the URL (web address) leading to the ../mcart/setup.cgi on your site
      # example --> http://www.yoursite.com/cgi-bin/mcart/setup.cgi
	  # We recommend installing both the cart FRONT & BACK ENDs via SSL (secure - HTTPS)
	  # If you do that, then place the installer pkg and <setup.cgi> script in the (secure) ./mcart
	  # and call up the <setup.cgi> script iva HTTPS://the.secure.url/cgi-bin/mcart/setup.cgi
# (6) Follow prompts, directions, suggestions, etc.

# This works on XP & Linux, but will not work if HTTP/HTTPS split install
$prg = 'setup.cgi';
$os = 'This is NOT a Win32 OS';
$os = 'This is a Win32 OS' if ($^O =~ m/mswin32/i);
$cfg = 'setup.conf';

# globals
$mvar;
$info;
$result;
$failed;
%save = ();
%missing = ();
%fileCheck = ();

# (1) HOW TO ADD NEW SEARCH/REPLACE VARS TO INSTALL ROUTINE
# (1) If you need to add new MVAR-Vars to the install pkg, then list them throughout the script
# (1) Add new "MVAR-Vars" to the @mvarsort list (end of script) and to all the functions
# (1) VarNames for .htpasswd / .htadmin user:pass ** must ** have naming convention:
# (1) MVAR-name-USR : MVAR-name-PSWD

# (2) WHAT TYPES OF FILES TO SEARCH/REPLACE FOR INSTALL VARS
# (2) file types to search/replace
# (2) file extensions listed here will be Searched for Replacement VARS
# (2) which means if you add files to the install pkg that have MVAR-Vars to replace
# (2) then you must add the file extension here or it will not be searched

@types = ('.html','.htm','.css','.txt','.pl','.conf',
		'.dat','.cgi','.mail','.htaccess','.htpasswd','.htadmin');

# (3) HOW TO ADD TEMPLATE PACKAGES TO THE INSTALL ROUTINE
# (3) Add 3 new Dirs to UNPACK pkg
# ./unpack/mofcart/newpkg         (examples,css,moftemplates,etc.)
# ./unpack/mofcart/newpkg/docs    (mofinstallation.html & support files)
# ./unpack/mofcart/newpkg/images  (images for examples,css,moftemplates,etc.)
# Then add the root pkg Directory name to @template_pkgs
# Script will automatically create ./copy/DIRs

@template_pkgs = ('boxed','ver25');

# Prg ->
use Cwd;
$root_cgi = cwd;
$cfg = $root_cgi . "/$cfg";
$root_http = 'http://' . $ENV{HTTP_HOST};

&doInput();
&doDate();
&doHtml();

$base = "$ShortDate $Time";
$base .= " : $ENV{'COMPUTERNAME'}" if($ENV{'COMPUTERNAME'});
$base .= " : $ENV{'OS'}" if($ENV{'OS'});
$base .= " : $ENV{'HTTP_HOST'}" if($ENV{'HTTP_HOST'});
$base .= " : $ENV{'REMOTE_ADDR'}" if($ENV{'REMOTE_ADDR'});

# FIND possible settings to prefill
# find Front End URLs : assumes that scrip is running under SSL
# if Front End wanting SSL install, otherwise default is set to HTTP
$root_front = 'http';
$root_front .= 's' if ($ENV{'HTTPS'} =~ /on/i);
$root_front .= '://' . $ENV{HTTP_HOST};
$mf = $ENV{'SCRIPT_NAME'};
$mf =~ (s/\/$prg//i);
$mf = $root_front . $mf;

# find Back End URLs : assumes that scrip is running under SSL
# if Back End wanting SSL install, otherwise default is set to HTTP
$root_back = 'http';
$root_back .= 's' if ($ENV{'HTTPS'} =~ /on/i);
$root_back .= '://' . $ENV{HTTP_HOST};
$mb = $ENV{'SCRIPT_NAME'};
$mb =~ (s/\/$prg//i);
$mb = $root_back . $mb;
$mp = $ENV{'SCRIPT_NAME'};
$mp =~ (s/\/$prg//i);
$mp = $root_http . $mp;

# start
&getConfigs($cfg) if (-e "$cfg");

	if (exists($save{'USER-AGREEMENT'})) {
	# start with SETTINGS (AGREEMENT has it's own routine)

	# if a form is coming back
	if ($frm{'frmFUNCTION'}) {


# (1)   SETTINGS - Make All Settings
		if ($frm{'frmFUNCTION'} eq 'SETTINGS') {

		&doValidate(
			'MVAR-BUSINESS-NAME'=>'/^[A-Za-z0-9 -,.]{3}/',
			'MVAR-BUSINESS-ADDRESS'=>'/^[A-Za-z0-9 -,.]{3}/',
			'MVAR-BUSINESS-CITY-STATE-ZIP'=>'/^[A-Za-z0-9 -,.]{3}/',
			'MVAR-BUSINESS-PHONE'=>'',
			'MVAR-BUSINESS-FAX'=>'',
			'MVAR-PHONE-HELP'=>'',
			'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'=>'/^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/',
			'MVAR-ORDER-HELP-AT-YOURSITE.COM'=>'/^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/',
			'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'=>'/^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/',
			'MVAR-YOUR-CC-KEY'=>'/^[A-Za-z0-9]{6}/',
			'MVAR-YOUR-CC-PSW'=>'/^[A-Za-z0-9]{6}/',
			'MVAR-ADMIN-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-ADMIN-PSWD'=>'/^[A-Za-z0-9]{5}/',
			'MVAR-INVOICES-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-INVOICES-PSWD'=>'/^[A-Za-z0-9]{4}/',
			'MVAR-DOCS-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-DOCS-PSWD'=>'/^[A-Za-z0-9]{4}/',
			'MVAR-USER-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-USER-PSWD'=>'/^[A-Za-z0-9]{4}/',
			'MVAR-DOMAIN-NAME.COM'=>'/[A-Za-z0-9 _\-.]{5}/',
			'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-FRONT-PATH-WEB-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/',
			'MVAR-FRONT-PATH-CGI-MCART-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/',
			'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-BACK-PATH-WEB-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/',
			'MVAR-BACK-PATH-CGI-MCART-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/'
			);

		# if no validate, do same form over again
		if (scalar(keys(%missing))) {
		my $failed = scalar(keys(%missing));

			# SAVE PREVIOUS frmFUNCTION (in case this is quit & return)
			$save{'frmFUNCTION'} = "AGREEMENT";
			$mvar = "MVAR-$save{'frmFUNCTION'}";
			$save{$mvar} = "$ShortDate : $Time";
			# append frm{MVAR-Vars} to %save for save
			$save{'MVAR-BUSINESS-NAME'} = $frm{'MVAR-BUSINESS-NAME'};
			$save{'MVAR-BUSINESS-ADDRESS'} = $frm{'MVAR-BUSINESS-ADDRESS'};
			$save{'MVAR-BUSINESS-CITY-STATE-ZIP'} = $frm{'MVAR-BUSINESS-CITY-STATE-ZIP'};
			$save{'MVAR-BUSINESS-PHONE'} = $frm{'MVAR-BUSINESS-PHONE'};
			$save{'MVAR-BUSINESS-FAX'} = $frm{'MVAR-BUSINESS-FAX'};
			$save{'MVAR-PHONE-HELP'} = $frm{'MVAR-PHONE-HELP'};
			$save{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'} = $frm{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'};
			$save{'MVAR-ORDER-HELP-AT-YOURSITE.COM'} = $frm{'MVAR-ORDER-HELP-AT-YOURSITE.COM'};
			$save{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'} = $frm{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'};
			$save{'MVAR-YOUR-CC-KEY'} = $frm{'MVAR-YOUR-CC-KEY'};
			$save{'MVAR-YOUR-CC-PSW'} = $frm{'MVAR-YOUR-CC-PSW'};
			$save{'MVAR-ADMIN-USR'} = $frm{'MVAR-ADMIN-USR'};
			$save{'MVAR-ADMIN-PSWD'} = $frm{'MVAR-ADMIN-PSWD'};
			$save{'MVAR-INVOICES-USR'} = $frm{'MVAR-INVOICES-USR'};
			$save{'MVAR-INVOICES-PSWD'} = $frm{'MVAR-INVOICES-PSWD'};
			$save{'MVAR-DOCS-USR'} = $frm{'MVAR-DOCS-USR'};
			$save{'MVAR-DOCS-PSWD'} = $frm{'MVAR-DOCS-PSWD'};
			$save{'MVAR-USER-USR'} = $frm{'MVAR-USER-USR'};
			$save{'MVAR-USER-PSWD'} = $frm{'MVAR-USER-PSWD'};	
			$save{'MVAR-DOMAIN-NAME.COM'} = $frm{'MVAR-DOMAIN-NAME.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'} = $frm{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-PATH-WEB-ROOT'} = $frm{'MVAR-FRONT-PATH-WEB-ROOT'};
			$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-FRONT-PATH-CGI-MCART-ROOT'};	
			$save{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-BACK-PATH-WEB-ROOT'} = $frm{'MVAR-BACK-PATH-WEB-ROOT'};
			$save{'MVAR-BACK-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-BACK-PATH-CGI-MCART-ROOT'};

			# saves %save to $cfg (path)
			&saveConfigs($cfg);

		# resubmit - validation errors message
		$info = qq~
			<b>Some settings are missing or incorrect</b>: 
			Note : <font color=black>PATHS <u>do not</u> have a trailing slash</font><br>
			Go to the <span Class="thisL">INPUT AREA</span> below and fix the item(s) highlighted in 
			<font color="red">Red</font><br>
			MouseOver the setting Name to display information about a setting <br>
			Click the <b>Save & Continue</b> button to proceed with the installation.
			~;

		$info .= &listMissing();

		# Redo doForm, THIS FUNCTION frm{frmFUNCTION}, THIS INFO MESSAGE
		# Parse All MVAR-Var %frm fields (so redo doForm has updated values) 
		&doForm(
			'frmINFO'=>$info,
			'frmFUNCTION'=>$frm{'frmFUNCTION'},
			'MVAR-BUSINESS-NAME'=>$frm{'MVAR-BUSINESS-NAME'},
			'MVAR-BUSINESS-ADDRESS'=>$frm{'MVAR-BUSINESS-ADDRESS'},
			'MVAR-BUSINESS-CITY-STATE-ZIP'=>$frm{'MVAR-BUSINESS-CITY-STATE-ZIP'},
			'MVAR-BUSINESS-PHONE'=>$frm{'MVAR-BUSINESS-PHONE'},
			'MVAR-BUSINESS-FAX'=>$frm{'MVAR-BUSINESS-FAX'},
			'MVAR-PHONE-HELP'=>$frm{'MVAR-PHONE-HELP'},
			'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'=>$frm{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'},
			'MVAR-ORDER-HELP-AT-YOURSITE.COM'=>$frm{'MVAR-ORDER-HELP-AT-YOURSITE.COM'},
			'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'=>$frm{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'},
			'MVAR-YOUR-CC-KEY'=>$frm{'MVAR-YOUR-CC-KEY'},
			'MVAR-YOUR-CC-PSW'=>$frm{'MVAR-YOUR-CC-PSW'},
			'MVAR-ADMIN-USR'=>$frm{'MVAR-ADMIN-USR'},
			'MVAR-ADMIN-PSWD'=>$frm{'MVAR-ADMIN-PSWD'},
			'MVAR-INVOICES-USR'=>$frm{'MVAR-INVOICES-USR'},
			'MVAR-INVOICES-PSWD'=>$frm{'MVAR-INVOICES-PSWD'},
			'MVAR-DOCS-USR'=>$frm{'MVAR-DOCS-USR'},
			'MVAR-DOCS-PSWD'=>$frm{'MVAR-DOCS-PSWD'},
			'MVAR-USER-USR'=>$frm{'MVAR-USER-USR'},
			'MVAR-USER-PSWD'=>$frm{'MVAR-USER-PSWD'},
			'MVAR-DOMAIN-NAME.COM'=>$frm{'MVAR-DOMAIN-NAME.COM'},
			'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'=>$frm{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'},
			'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'=>$frm{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'=>$frm{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'=>$frm{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-PATH-WEB-ROOT'=>$frm{'MVAR-FRONT-PATH-WEB-ROOT'},
			'MVAR-FRONT-PATH-CGI-MCART-ROOT'=>$frm{'MVAR-FRONT-PATH-CGI-MCART-ROOT'},
			'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'=>$frm{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'=>$frm{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-BACK-PATH-WEB-ROOT'=>$frm{'MVAR-BACK-PATH-WEB-ROOT'},
			'MVAR-BACK-PATH-CGI-MCART-ROOT'=>$frm{'MVAR-BACK-PATH-CGI-MCART-ROOT'}
			);

		# function validated, save & next 
		} else {
			# save current function
			$save{'frmFUNCTION'} = $frm{'frmFUNCTION'};
			$mvar = "MVAR-$save{'frmFUNCTION'}";
			$save{$mvar} = "$ShortDate : $Time";
			# append frm{MVAR-Vars} to %save for save
			$save{'MVAR-BUSINESS-NAME'} = $frm{'MVAR-BUSINESS-NAME'};
			$save{'MVAR-BUSINESS-ADDRESS'} = $frm{'MVAR-BUSINESS-ADDRESS'};
			$save{'MVAR-BUSINESS-CITY-STATE-ZIP'} = $frm{'MVAR-BUSINESS-CITY-STATE-ZIP'};
			$save{'MVAR-BUSINESS-PHONE'} = $frm{'MVAR-BUSINESS-PHONE'};
			$save{'MVAR-BUSINESS-FAX'} = $frm{'MVAR-BUSINESS-FAX'};
			$save{'MVAR-PHONE-HELP'} = $frm{'MVAR-PHONE-HELP'};
			$save{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'} = $frm{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'};
			$save{'MVAR-ORDER-HELP-AT-YOURSITE.COM'} = $frm{'MVAR-ORDER-HELP-AT-YOURSITE.COM'};
			$save{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'} = $frm{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'};
			$save{'MVAR-YOUR-CC-KEY'} = $frm{'MVAR-YOUR-CC-KEY'};
			$save{'MVAR-YOUR-CC-PSW'} = $frm{'MVAR-YOUR-CC-PSW'};
			$save{'MVAR-ADMIN-USR'} = $frm{'MVAR-ADMIN-USR'};
			$save{'MVAR-ADMIN-PSWD'} = $frm{'MVAR-ADMIN-PSWD'};
			$save{'MVAR-INVOICES-USR'} = $frm{'MVAR-INVOICES-USR'};
			$save{'MVAR-INVOICES-PSWD'} = $frm{'MVAR-INVOICES-PSWD'};
			$save{'MVAR-DOCS-USR'} = $frm{'MVAR-DOCS-USR'};
			$save{'MVAR-DOCS-PSWD'} = $frm{'MVAR-DOCS-PSWD'};
			$save{'MVAR-USER-USR'} = $frm{'MVAR-USER-USR'};
			$save{'MVAR-USER-PSWD'} = $frm{'MVAR-USER-PSWD'};	
			$save{'MVAR-DOMAIN-NAME.COM'} = $frm{'MVAR-DOMAIN-NAME.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'} = $frm{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-PATH-WEB-ROOT'} = $frm{'MVAR-FRONT-PATH-WEB-ROOT'};
			$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-FRONT-PATH-CGI-MCART-ROOT'};	
			$save{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-BACK-PATH-WEB-ROOT'} = $frm{'MVAR-BACK-PATH-WEB-ROOT'};
			$save{'MVAR-BACK-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-BACK-PATH-CGI-MCART-ROOT'};

			# saves %save to $cfg (path)
			&saveConfigs($cfg);

		# directions next step
		$info = qq~
		<table cellpadding="0">
		<tr><td Class="compL">1. </td><td Class="compL">Agreement Logged</td><td Class="compR">COMPLETED</td>
    	<td Class="default" rowspan="6">
		<P>
		<b>STEP 3 of 5 : Testing Paths</b><br>

		Note: <u>Testing routines not yet written</u>, proceed as is .. <br>
		Setup can help you test paths. Setup guessed the paths below (unless you changed path
		settings in the last step).  Click the test button to the right of each path setting
		to direct setup to test that path. No files on your site are changed during the test.
		Click "Save & Continue" to proceed to the next step
		</P>
		</td>
		</tr>
		<tr><td Class="compL">2. </td><td Class="compL">Adjust All Settings</td><td Class="compR">COMPLETED</td></tr>
		<tr><td Class="thisL">3. </td><td Class="thisL">Testing Settings</td><td Class="thisR"> = = = = = > </td></tr>
		<tr><td Class="nextL">4. </td><td Class="nextL">Make Directories</td><td Class="nextR">NEXT STEP</td></tr>
		<tr><td Class="nextL">5. </td><td Class="nextL">Replace & Copy</td><td Class="nextR">NEXT STEP</td></tr>
		</table>
		~;

		&doForm(
			'frmINFO'=>$info,
			'frmFUNCTION'=>'TESTING',
			'MVAR-BUSINESS-NAME'=>$save{'MVAR-BUSINESS-NAME'},
			'MVAR-BUSINESS-ADDRESS'=>$save{'MVAR-BUSINESS-ADDRESS'},
			'MVAR-BUSINESS-CITY-STATE-ZIP'=>$save{'MVAR-BUSINESS-CITY-STATE-ZIP'},
			'MVAR-BUSINESS-PHONE'=>$save{'MVAR-BUSINESS-PHONE'},
			'MVAR-BUSINESS-FAX'=>$save{'MVAR-BUSINESS-FAX'},
			'MVAR-PHONE-HELP'=>$save{'MVAR-PHONE-HELP'},
			'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'=>$save{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'},
			'MVAR-ORDER-HELP-AT-YOURSITE.COM'=>$save{'MVAR-ORDER-HELP-AT-YOURSITE.COM'},
			'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'=>$save{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'},
			'MVAR-YOUR-CC-KEY'=>$save{'MVAR-YOUR-CC-KEY'},
			'MVAR-YOUR-CC-PSW'=>$save{'MVAR-YOUR-CC-PSW'},
			'MVAR-ADMIN-USR'=>$save{'MVAR-ADMIN-USR'},
			'MVAR-ADMIN-PSWD'=>$save{'MVAR-ADMIN-PSWD'},
			'MVAR-INVOICES-USR'=>$save{'MVAR-INVOICES-USR'},
			'MVAR-INVOICES-PSWD'=>$save{'MVAR-INVOICES-PSWD'},
			'MVAR-DOCS-USR'=>$save{'MVAR-DOCS-USR'},
			'MVAR-DOCS-PSWD'=>$save{'MVAR-DOCS-PSWD'},
			'MVAR-USER-USR'=>$save{'MVAR-USER-USR'},
			'MVAR-USER-PSWD'=>$save{'MVAR-USER-PSWD'},
			'MVAR-DOMAIN-NAME.COM'=>$save{'MVAR-DOMAIN-NAME.COM'},
			'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'=>$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'},
			'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'=>$save{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'=>$save{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'=>$save{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-PATH-WEB-ROOT'=>$save{'MVAR-FRONT-PATH-WEB-ROOT'},
			'MVAR-FRONT-PATH-CGI-MCART-ROOT'=>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'},
			'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'=>$save{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'=>$save{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-BACK-PATH-WEB-ROOT'=>$save{'MVAR-BACK-PATH-WEB-ROOT'},
			'MVAR-BACK-PATH-CGI-MCART-ROOT'=>$save{'MVAR-BACK-PATH-CGI-MCART-ROOT'}
			);
		}


# (2) - TESTING (Test Paths --> Make Directories to Proceed)
		} elsif ($frm{'frmFUNCTION'} eq "TESTING") {

		&doValidate(
			'MVAR-BUSINESS-NAME'=>'/^[A-Za-z0-9 -,.]{3}/',
			'MVAR-BUSINESS-ADDRESS'=>'/^[A-Za-z0-9 -,.]{3}/',
			'MVAR-BUSINESS-CITY-STATE-ZIP'=>'/^[A-Za-z0-9 -,.]{3}/',
			'MVAR-BUSINESS-PHONE'=>'',
			'MVAR-BUSINESS-FAX'=>'',
			'MVAR-PHONE-HELP'=>'',
			'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'=>'/^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/',
			'MVAR-ORDER-HELP-AT-YOURSITE.COM'=>'/^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/',
			'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'=>'/^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/',
			'MVAR-YOUR-CC-KEY'=>'/^[A-Za-z0-9]{6}/',
			'MVAR-YOUR-CC-PSW'=>'/^[A-Za-z0-9]{6}/',
			'MVAR-ADMIN-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-ADMIN-PSWD'=>'/^[A-Za-z0-9]{5}/',
			'MVAR-INVOICES-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-INVOICES-PSWD'=>'/^[A-Za-z0-9]{4}/',
			'MVAR-DOCS-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-DOCS-PSWD'=>'/^[A-Za-z0-9]{4}/',
			'MVAR-USER-USR'=>'/^[A-Za-z0-9]{3}/',
			'MVAR-USER-PSWD'=>'/^[A-Za-z0-9]{4}/',
			'MVAR-DOMAIN-NAME.COM'=>'/[A-Za-z0-9 _\-.]{5}/',
			'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-FRONT-PATH-WEB-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/',
			'MVAR-FRONT-PATH-CGI-MCART-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/',
			'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'=>'/[A-Za-z0-9/ _\-.]{6}/',
			'MVAR-BACK-PATH-WEB-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/',
			'MVAR-BACK-PATH-CGI-MCART-ROOT'=>'/[A-Za-z0-9/\\: _\-.]{3}/'
			);

		if (scalar(keys(%missing))) {
		my $failed = scalar(keys(%missing));

			# SAVE PREVIOUS frmFUNCTION (in case this is quit & return)
			$save{'frmFUNCTION'} = "SETTINGS";
			$mvar = "MVAR-$save{'frmFUNCTION'}";
			$save{$mvar} = "$ShortDate : $Time";
			$save{'MVAR-BUSINESS-NAME'} = $frm{'MVAR-BUSINESS-NAME'};
			$save{'MVAR-BUSINESS-ADDRESS'} = $frm{'MVAR-BUSINESS-ADDRESS'};
			$save{'MVAR-BUSINESS-CITY-STATE-ZIP'} = $frm{'MVAR-BUSINESS-CITY-STATE-ZIP'};
			$save{'MVAR-BUSINESS-PHONE'} = $frm{'MVAR-BUSINESS-PHONE'};
			$save{'MVAR-BUSINESS-FAX'} = $frm{'MVAR-BUSINESS-FAX'};
			$save{'MVAR-PHONE-HELP'} = $frm{'MVAR-PHONE-HELP'};
			$save{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'} = $frm{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'};
			$save{'MVAR-ORDER-HELP-AT-YOURSITE.COM'} = $frm{'MVAR-ORDER-HELP-AT-YOURSITE.COM'};
			$save{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'} = $frm{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'};
			$save{'MVAR-YOUR-CC-KEY'} = $frm{'MVAR-YOUR-CC-KEY'};
			$save{'MVAR-YOUR-CC-PSW'} = $frm{'MVAR-YOUR-CC-PSW'};
			$save{'MVAR-ADMIN-USR'} = $frm{'MVAR-ADMIN-USR'};
			$save{'MVAR-ADMIN-PSWD'} = $frm{'MVAR-ADMIN-PSWD'};
			$save{'MVAR-INVOICES-USR'} = $frm{'MVAR-INVOICES-USR'};
			$save{'MVAR-INVOICES-PSWD'} = $frm{'MVAR-INVOICES-PSWD'};
			$save{'MVAR-DOCS-USR'} = $frm{'MVAR-DOCS-USR'};
			$save{'MVAR-DOCS-PSWD'} = $frm{'MVAR-DOCS-PSWD'};
			$save{'MVAR-USER-USR'} = $frm{'MVAR-USER-USR'};
			$save{'MVAR-USER-PSWD'} = $frm{'MVAR-USER-PSWD'};	
			$save{'MVAR-DOMAIN-NAME.COM'} = $frm{'MVAR-DOMAIN-NAME.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'} = $frm{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-PATH-WEB-ROOT'} = $frm{'MVAR-FRONT-PATH-WEB-ROOT'};
			$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-FRONT-PATH-CGI-MCART-ROOT'};	
			$save{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-BACK-PATH-WEB-ROOT'} = $frm{'MVAR-BACK-PATH-WEB-ROOT'};
			$save{'MVAR-BACK-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-BACK-PATH-CGI-MCART-ROOT'};
			&saveConfigs($cfg);

		# resubmit - validation errors message
		$info = qq~
			<b>Some settings are missing or incorrect</b>: 
			Note : <font color=black>PATHS <u>do not</u> have a trailing slash</font><br>
			Go to the <span Class="thisL">INPUT AREA</span> below and fix the item(s) highlighted in 
			<font color="red">Red</font><br>
			MouseOver the setting Name to display information about a setting <br>
			Click the <b>Save & Continue</b> button to proceed with the installation.
			~;

		$info .= &listMissing();

		# Redo doForm, THIS FUNCTION frm{frmFUNCTION}, THIS INFO MESSAGE
		# Parse All MVAR-Var %frm fields (so redo doForm has updated values) 
		&doForm(
			'frmINFO'=>$info,
			'frmFUNCTION'=>$frm{'frmFUNCTION'},
			'MVAR-BUSINESS-NAME'=>$frm{'MVAR-BUSINESS-NAME'},
			'MVAR-BUSINESS-ADDRESS'=>$frm{'MVAR-BUSINESS-ADDRESS'},
			'MVAR-BUSINESS-CITY-STATE-ZIP'=>$frm{'MVAR-BUSINESS-CITY-STATE-ZIP'},
			'MVAR-BUSINESS-PHONE'=>$frm{'MVAR-BUSINESS-PHONE'},
			'MVAR-BUSINESS-FAX'=>$frm{'MVAR-BUSINESS-FAX'},
			'MVAR-PHONE-HELP'=>$frm{'MVAR-PHONE-HELP'},
			'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'=>$frm{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'},
			'MVAR-ORDER-HELP-AT-YOURSITE.COM'=>$frm{'MVAR-ORDER-HELP-AT-YOURSITE.COM'},
			'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'=>$frm{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'},
			'MVAR-YOUR-CC-KEY'=>$frm{'MVAR-YOUR-CC-KEY'},
			'MVAR-YOUR-CC-PSW'=>$frm{'MVAR-YOUR-CC-PSW'},
			'MVAR-ADMIN-USR'=>$frm{'MVAR-ADMIN-USR'},
			'MVAR-ADMIN-PSWD'=>$frm{'MVAR-ADMIN-PSWD'},
			'MVAR-INVOICES-USR'=>$frm{'MVAR-INVOICES-USR'},
			'MVAR-INVOICES-PSWD'=>$frm{'MVAR-INVOICES-PSWD'},
			'MVAR-DOCS-USR'=>$frm{'MVAR-DOCS-USR'},
			'MVAR-DOCS-PSWD'=>$frm{'MVAR-DOCS-PSWD'},
			'MVAR-USER-USR'=>$frm{'MVAR-USER-USR'},
			'MVAR-USER-PSWD'=>$frm{'MVAR-USER-PSWD'},
			'MVAR-DOMAIN-NAME.COM'=>$frm{'MVAR-DOMAIN-NAME.COM'},
			'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'=>$frm{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'},
			'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'=>$frm{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'=>$frm{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'=>$frm{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-PATH-WEB-ROOT'=>$frm{'MVAR-FRONT-PATH-WEB-ROOT'},
			'MVAR-FRONT-PATH-CGI-MCART-ROOT'=>$frm{'MVAR-FRONT-PATH-CGI-MCART-ROOT'},
			'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'=>$frm{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'=>$frm{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-BACK-PATH-WEB-ROOT'=>$frm{'MVAR-BACK-PATH-WEB-ROOT'},
			'MVAR-BACK-PATH-CGI-MCART-ROOT'=>$frm{'MVAR-BACK-PATH-CGI-MCART-ROOT'}
			);

		# function validated, save & next 
		} else {

			# save current function
			$save{'frmFUNCTION'} = $frm{'frmFUNCTION'};
			$mvar = "MVAR-$save{'frmFUNCTION'}";
			$save{$mvar} = "$ShortDate : $Time";
			$save{'MVAR-BUSINESS-NAME'} = $frm{'MVAR-BUSINESS-NAME'};
			$save{'MVAR-BUSINESS-ADDRESS'} = $frm{'MVAR-BUSINESS-ADDRESS'};
			$save{'MVAR-BUSINESS-CITY-STATE-ZIP'} = $frm{'MVAR-BUSINESS-CITY-STATE-ZIP'};
			$save{'MVAR-BUSINESS-PHONE'} = $frm{'MVAR-BUSINESS-PHONE'};
			$save{'MVAR-BUSINESS-FAX'} = $frm{'MVAR-BUSINESS-FAX'};
			$save{'MVAR-PHONE-HELP'} = $frm{'MVAR-PHONE-HELP'};
			$save{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'} = $frm{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'};
			$save{'MVAR-ORDER-HELP-AT-YOURSITE.COM'} = $frm{'MVAR-ORDER-HELP-AT-YOURSITE.COM'};
			$save{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'} = $frm{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'};
			$save{'MVAR-YOUR-CC-KEY'} = $frm{'MVAR-YOUR-CC-KEY'};
			$save{'MVAR-YOUR-CC-PSW'} = $frm{'MVAR-YOUR-CC-PSW'};
			$save{'MVAR-ADMIN-USR'} = $frm{'MVAR-ADMIN-USR'};
			$save{'MVAR-ADMIN-PSWD'} = $frm{'MVAR-ADMIN-PSWD'};
			$save{'MVAR-INVOICES-USR'} = $frm{'MVAR-INVOICES-USR'};
			$save{'MVAR-INVOICES-PSWD'} = $frm{'MVAR-INVOICES-PSWD'};
			$save{'MVAR-DOCS-USR'} = $frm{'MVAR-DOCS-USR'};
			$save{'MVAR-DOCS-PSWD'} = $frm{'MVAR-DOCS-PSWD'};
			$save{'MVAR-USER-USR'} = $frm{'MVAR-USER-USR'};
			$save{'MVAR-USER-PSWD'} = $frm{'MVAR-USER-PSWD'};	
			$save{'MVAR-DOMAIN-NAME.COM'} = $frm{'MVAR-DOMAIN-NAME.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'} = $frm{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'};
			$save{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-FRONT-PATH-WEB-ROOT'} = $frm{'MVAR-FRONT-PATH-WEB-ROOT'};
			$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-FRONT-PATH-CGI-MCART-ROOT'};	
			$save{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'} = $frm{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'};
			$save{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'} = $frm{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'};
			$save{'MVAR-BACK-PATH-WEB-ROOT'} = $frm{'MVAR-BACK-PATH-WEB-ROOT'};
			$save{'MVAR-BACK-PATH-CGI-MCART-ROOT'} = $frm{'MVAR-BACK-PATH-CGI-MCART-ROOT'};
			&saveConfigs($cfg);


			# directions next step
			$info = qq~
			<table cellpadding="0">
			<tr><td Class="compL">1. </td><td Class="compL">Agreement Logged</td><td Class="compR">COMPLETED</td>
   		 	<td Class="default" rowspan="6">
			<P>
			<b>STEP 4 of 5 : Make Directory Structure</b><br>
			Setup will now create the directory structure for all of the files. 
			Click "Create Directories" to create the directories and proceed to the next step
			</P>
			</td>
			</tr>
			<tr><td Class="compL">2. </td><td Class="compL">Adjust All Settings</td><td Class="compR">COMPLETED</td></tr>
			<tr><td Class="compL">3. </td><td Class="compL">Testing Settings</td><td Class="compR">COMPLETED</td></tr>
			<tr><td Class="thisL">4. </td><td Class="thisL">Make Directories</td><td Class="thisR"> = = = = = > </td></tr>
			<tr><td Class="nextL">5. </td><td Class="nextL">Replace & Copy</td><td Class="nextR">NEXT STEP</td></tr>
			</table>
			~;

		&doForm(
			'frmINFO'=>$info,
			'frmFUNCTION'=>'MAKEDIRS',
			);
		}


# (3) - REPLACE (Search & Replace)
		} elsif ($frm{'frmFUNCTION'} eq "MAKEDIRS") {
		&doMakeDirs();
		# &doUnPack();

		# save current function if successful
		$save{'frmFUNCTION'} = $frm{'frmFUNCTION'};
		$mvar = "MVAR-$save{'frmFUNCTION'}";
		$save{$mvar} = "$ShortDate : $Time";
		&saveConfigs($cfg);


# (4) - REPLACE (Search & Replace)
		} elsif ($frm{'frmFUNCTION'} eq "REPLACE") {

		use File::Copy;
		&doReplacement();
		# when replacements done, copy all from ../copy ---> MOFcart dirs
		# set permissions

		# save current function if successful
		$save{'frmFUNCTION'} = $frm{'frmFUNCTION'};
		$mvar = "MVAR-$save{'frmFUNCTION'}";
		$save{$mvar} = "$ShortDate : $Time";
		&saveConfigs($cfg);


# (5) - FINISH (Final msg & link to Welcome, Start)
		} elsif ($frm{'frmFUNCTION'} eq "FINISH") {	
		&doErr("STEP TO DO : $frm{'frmFUNCTION'}");	
		# Delete temp settings & redirect to info page

		# save current function if successful
		$save{'frmFUNCTION'} = $frm{'frmFUNCTION'};
		$mvar = "MVAR-$save{'frmFUNCTION'}";
		$save{$mvar} = "$ShortDate : $Time";
		&saveConfigs($cfg);

	
# (Err) ERROR (Agreement submitted again, after agreement already logged)
		} else{

		# Netsacpe is hitting this branch on the very FIRST Yes, AGREEMENT POST
		# Netscape v7.0 also has problems with premature delete_cart_final in <mofpay.cgi>
		# Find its way into the -e file exists && field for save agreement exists, strange.
		&doErr("ERROR SUBMITTED frmFUNCTION = $save{'frmFUNCTION'} : Agreement Logged Already <br> path: $cfg");	
		}

	# no form found, use saved last function to go to next step
	} else {

	$tempmsg = qq~
	<br>
	<font color="black">
	The install utility <b>Save & Resume</b> functions have not yet been written. 
	To Start Completely over with the install utility, find the <b><u>setup.conf</u></b> file
    in the same directory as this script, and delete <b><u>setup.conf</u></b>. You will then
    be able to run <b><u>setup.cgi</u></b> from the beginning again.</font><p>
	~;


		# happens if script restarted with no form input
		# THIS PART STILL NEEDS TO BE THOUGHT THROUGH

		if ($save{'frmFUNCTION'} eq "AGREEMENT") {	
		&doErr("$tempmsg NO FORM INPUT, LAST SAVED FUNCTION : <b>$save{'frmFUNCTION'}</b>");

		} elsif ($save{'frmFUNCTION'} eq "SETTINGS") {
		&doErr("$tempmsg NO FORM INPUT, LAST SAVED FUNCTION : <b>$save{'frmFUNCTION'}</b>");

		} elsif ($save{'frmFUNCTION'} eq "TESTING") {
		&doErr("$tempmsg NO FORM INPUT, LAST SAVED FUNCTION : <b>$save{'frmFUNCTION'}</b>");

		} elsif ($save{'frmFUNCTION'} eq "MAKEDIRS") {
		&doErr("$tempmsg NO FORM INPUT, LAST SAVED FUNCTION : <b>$save{'frmFUNCTION'}</b>");

		} elsif ($save{'frmFUNCTION'} eq "REPLACE") {
		&doErr("$tempmsg NO FORM INPUT, LAST SAVED FUNCTION : <b>$save{'frmFUNCTION'}</b>");

		} elsif ($save{'frmFUNCTION'} eq "FINISH") {
		&doErr("$tempmsg NO FORM INPUT, LAST SAVED FUNCTION : <b>$save{'frmFUNCTION'}</b>");

		} else {
		# something is missing, redo AGREEMENT
		&doErr("$tempmsg NO FORM INPUT, AND NOTHING IS SAVED");

		}
	}

	# AGREEMENT MISSING doTerms
	} else {
	# First Time or Missing Agreement : start/update agreement & first saved Vars
	# Didn't find user agreement in saved file, or didn't find a saved conf file

		if ($frm{'frmFUNCTION'} eq 'AGREEMENT') {
		&doTerms("CANCEL-EXIT") unless ($frm{'frmAGREEMENT'} eq 'CONTINUE');

		# SAVE beginning default settings all "MVAR-"s
		# DomainName.com
		$save{'MVAR-DOMAIN-NAME.COM'} = $ENV{'HTTP_HOST'};
		# Strict HTTP://DomainName.com (for nonSSL stuff)
		$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'} = $root_http;
		$save{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'} = $mp;

		# HTTP/HTTPS Front End paths
		$save{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'} = $root_front;
		$save{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'} = $mf;
		# Doc_Root not available on XP, will print blank
		$save{'MVAR-FRONT-PATH-WEB-ROOT'} = $ENV{'DOCUMENT_ROOT'};
		$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'} = $root_cgi;

		# HTTP/HTTPS Back End paths
		$save{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'} = $root_back;
		$save{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'} = $mb;
		# Doc_Root not available on XP, will print blank
		$save{'MVAR-BACK-PATH-WEB-ROOT'} = $ENV{'DOCUMENT_ROOT'};
		$save{'MVAR-BACK-PATH-CGI-MCART-ROOT'} = $root_cgi;

		# Business info
		$save{'MVAR-BUSINESS-NAME'} = 'MVAR-BUSINESS-NAME';
		$save{'MVAR-BUSINESS-ADDRESS'} = 'MVAR-BUSINESS-ADDRESS';
		$save{'MVAR-BUSINESS-CITY-STATE-ZIP'} = 'MVAR-BUSINESS-CITY-STATE-ZIP';
		$save{'MVAR-BUSINESS-PHONE'} = 'MVAR-BUSINESS-PHONE';
		$save{'MVAR-BUSINESS-FAX'} = 'MVAR-BUSINESS-FAX';
		$save{'MVAR-PHONE-HELP'} = 'MVAR-PHONE-HELP';

		# mail info : strip "www." from domain name to mail
		my $nowww = $save{'MVAR-DOMAIN-NAME.COM'};
		   $nowww =~ s/www\.//;
		$save{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'} = "orders\@$nowww";
		$save{'MVAR-ORDER-HELP-AT-YOURSITE.COM'} = "orders\@$nowww";
		$save{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'} = "affiliates\@$nowww";

		# default users
		$save{'MVAR-ADMIN-USR'} = 'admin';
		$save{'MVAR-INVOICES-USR'} = 'invoice';
		$save{'MVAR-DOCS-USR'} = 'docs';
		$save{'MVAR-USER-USR'} = 'user';

		# various pswd generators, get pswds first time only
		# (1) $cryptPsw = crypt($myPsw,$salt);
 		# (2) syntax: $v&genPsw(length);
		# (3) syntax: $v&random_password(length); or default to 6## syntax: 
		# (4) syntax: $v= &doEncrypt(psw,KEY,PublicKey)
		# (4) syntax: $v = &doDecrypt(psw,KEY,PublicKey)

		my $ap = &genPsw(6);
		$save{'MVAR-YOUR-CC-KEY'} = &random_password(22);
		$save{'MVAR-YOUR-CC-PSW'} = $ap;
		$save{'MVAR-ADMIN-PSWD'} = $ap;
		$save{'MVAR-INVOICES-PSWD'} = &random_password(6);
		$save{'MVAR-DOCS-PSWD'} = &random_password(6);
		$save{'MVAR-USER-PSWD'} = &random_password(6);

		# SAVE some ENV Vars
		# stored but not used for MVAR Replacement
		$save{'USER-AGREEMENT'} = $base;
		$save{'OS_PERL'} = ($^O);
		$save{'OS'} = $ENV{'OS'};
		$save{'PWD'} = $ENV{'PWD'};
		$save{'HTTPS'} = $ENV{'HTTPS'};
		$save{'PATH_INFO'} = $ENV{'PATH_INFO'};
		$save{'LOCAL_ADDR'} = $ENV{'LOCAL_ADDR'};
		$save{'SCRIPT_NAME'} = $ENV{'SCRIPT_NAME'};
		$save{'REMOTE_ADDR'} = $ENV{'REMOTE_ADDR'};
		$save{'REMOTE_HOST'} = $ENV{'REMOTE_HOST'};
		$save{'SERVER_NAME'} = $ENV{'SERVER_NAME'};
		$save{'COMPUTERNAME'} = $ENV{'COMPUTERNAME'};
		$save{'DOCUMENT_ROOT'} = $ENV{'DOCUMENT_ROOT'};
		$save{'HTTP_USER_AGENT'} = $ENV{'HTTP_USER_AGENT'};
		$save{'SERVER_SOFTWARE'} = $ENV{'SERVER_SOFTWARE'};
		$save{'PATH_TRANSLATED'} = $ENV{'PATH_TRANSLATED'};
		$save{'GATEWAY_INTERFACE'} = $ENV{'GATEWAY_INTERFACE'};

		# save current function
		$save{'frmFUNCTION'} = $frm{'frmFUNCTION'};
		$mvar = "MVAR-$save{'frmFUNCTION'}";
		$save{$mvar} = "$ShortDate : $Time";

		# saves %save to $cfg (path)
		&saveConfigs($cfg);

		$info = qq~
		<table cellpadding="0">
		<tr><td Class="compL">1. </td><td Class="compL">Agreement Logged</td><td Class="compR">COMPLETED</td>
    	<td Class="default" rowspan="6">
		<P>
		<b>STEP 2 of 5 : Adjust All Settings</b><br>
		<b>Path settings do not have a trailing slash "/"</b><br>
		We tried to guess at some of your settings for installing on this server.
		The path settings are guesses only. You must check and/or edit all the 
		settings below for a successful installation to match your server specifications.
		When you have made all the settings below correctly, then click "Save & Continue"
		to proceed to Step Three. Setup will *not* make any changes to your filespace
		until Step 4: Making Directories. MouseOver the setting names for more info.</P>
		</td>
		</tr>
		<tr><td Class="thisL">2. </td><td Class="thisL">Adjust All Settings</td><td Class="thisR"> = = = = = > </td></tr>
		<tr><td Class="nextL">3. </td><td Class="nextL">Testing Settings</td><td Class="nextR">NEXT STEP</td></tr>
		<tr><td Class="nextL">4. </td><td Class="nextL">Make Directories</td><td Class="nextR">NEXT STEP</td></tr>
		<tr><td Class="nextL">5. </td><td Class="nextL">Replace & Copy</td><td Class="nextR">NEXT STEP</td></tr>
		</table>
		~;

		# set up for next Function, next vars
		&doForm(
			'frmINFO'=>$info,
			'frmMESSAGE'=>$message,
			'frmFUNCTION'=>'SETTINGS',
			'MVAR-BUSINESS-NAME'=>$save{'MVAR-BUSINESS-NAME'},
			'MVAR-BUSINESS-ADDRESS'=>$save{'MVAR-BUSINESS-ADDRESS'},
			'MVAR-BUSINESS-CITY-STATE-ZIP'=>$save{'MVAR-BUSINESS-CITY-STATE-ZIP'},
			'MVAR-BUSINESS-PHONE'=>$save{'MVAR-BUSINESS-PHONE'},
			'MVAR-BUSINESS-FAX'=>$save{'MVAR-BUSINESS-FAX'},
			'MVAR-PHONE-HELP'=>$save{'MVAR-PHONE-HELP'},
			'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'=>$save{'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'},
			'MVAR-ORDER-HELP-AT-YOURSITE.COM'=>$save{'MVAR-ORDER-HELP-AT-YOURSITE.COM'},
			'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'=>$save{'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'},
			'MVAR-YOUR-CC-KEY'=>$save{'MVAR-YOUR-CC-KEY'},
			'MVAR-YOUR-CC-PSW'=>$save{'MVAR-YOUR-CC-PSW'},
			'MVAR-ADMIN-USR'=>$save{'MVAR-ADMIN-USR'},
			'MVAR-ADMIN-PSWD'=>$save{'MVAR-ADMIN-PSWD'},
			'MVAR-INVOICES-USR'=>$save{'MVAR-INVOICES-USR'},
			'MVAR-INVOICES-PSWD'=>$save{'MVAR-INVOICES-PSWD'},
			'MVAR-DOCS-USR'=>$save{'MVAR-DOCS-USR'},
			'MVAR-DOCS-PSWD'=>$save{'MVAR-DOCS-PSWD'},
			'MVAR-USER-USR'=>$save{'MVAR-USER-USR'},
			'MVAR-USER-PSWD'=>$save{'MVAR-USER-PSWD'},
			'MVAR-DOMAIN-NAME.COM'=>$save{'MVAR-DOMAIN-NAME.COM'},
			'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'=>$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'},
			'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'=>$save{'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'=>$save{'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'=>$save{'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-FRONT-PATH-WEB-ROOT'=>$save{'MVAR-FRONT-PATH-WEB-ROOT'},
			'MVAR-FRONT-PATH-CGI-MCART-ROOT'=>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'},
			'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'=>$save{'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'},
			'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'=>$save{'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'},
			'MVAR-BACK-PATH-WEB-ROOT'=>$save{'MVAR-BACK-PATH-WEB-ROOT'},
			'MVAR-BACK-PATH-CGI-MCART-ROOT'=>$save{'MVAR-BACK-PATH-CGI-MCART-ROOT'}
			);

		} else {
		&doTerms("FIRST-EXIT") unless ($frm{'frmAGREEMENT'} eq 'CONTINUE');
		}

	}	

	exit;


# subs 
# subs 

sub doReplacement {

	# how to clear the screen ??
	# print "Content-Type: text/html\n\n";
	# print "	<html><head></head><body>";
	# print "WORKING .. PLEASE WAIT";
	# print "</body></html>";


	# the following (3) arrays are active, but not printed anywhere
	%status = ();		# (global) contains all activity, files, dirs (dir-file_path)=>status_msg
	%cpstatus = ();		# (global) contains copy to site activity, files, dirs (dir-file_path)=>status_msg
	my @srTypes = ();	# list of all (full_path_&files) that have MVAR-s to replace
	my @cpTypes = ();	# list of all (full_path_&files) WITHOUT MVAR-s (copy only files)

	# take from ../unpack ---> (replace) ----> put in ../copy
	my (@old) = ();
	my (@new) = ();
	my (@files) = ();
	my $istype = 0;
	my ($add,$pth,$d,$f,$nn,$n,$t,$v,$p,$r,$w,$e,$usr);
	my ($all_vars,$t_srch,$t_copy) = (0,0,0);
	my ($tnn,$tcp,$tsr,$tr_ok,$tw_ok,$tr_err,$tw_err) = (0,0,0,0,0,0,0);
	my $newpath = "$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mofcart";

	# directions next step
	$info = qq~
	<table cellpadding="0">
	<tr><td Class="compL">1. </td><td Class="compL">Agreement Logged</td><td Class="compR">COMPLETED</td>
 	<td Class="default" rowspan="6">
	<P>
	<b>Installation Process Finished</b><br>
	Setup has completed the installation on your site. A "Getting Started" information page has been
	created specifically for your site & installation. You will need the User : Pswd Login below to 
	access the "Getting Started" page.
	<li><a href="$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'}/mofcart/docs/mofinstallation.html">
	<b>Getting Started</b>: $save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'}/mofcart/docs/mofinstallation.html</a>
	<li>user : $save{'MVAR-DOCS-USR'}
	<li>pass : $save{'MVAR-DOCS-PSWD'}
	</P>
	</td>
	</tr>
	<tr><td Class="compL">2. </td><td Class="compL">Adjust All Settings</td><td Class="compR">COMPLETED</td></tr>
	<tr><td Class="compL">3. </td><td Class="compL">Testing Settings</td><td Class="compR">COMPLETED</td></tr>
	<tr><td Class="compL">4. </td><td Class="compL">Make Directories</td><td Class="compR">COMPLETED</td></tr>
	<tr><td Class="compL">5. </td><td Class="compL">Replace & Copy</td><td Class="compR">COMPLETED</td></tr>
	</table>
	~;




	$out .= qq~
	$header
	<font size="2"><li>$Date $ShortTime</font>
	<font size="2"><li>$save{'USER-AGREEMENT'} : </font><font size="1">SETTINGS</font>
	<font size="2"><li>$base : </font><font size="1">CURRENT</font>
	<p>
	<form name="myFORM" method="post" action="$prg">
	<input type="hidden" name="frmFUNCTION" value="FINISH">
	<table Class="form">
	<tr Class="info"><td colspan="10" Class="info">$info</td></tr>
	~;

	# static dir structure : load from ./unpack
	my @dirsUnpack = (
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/ares",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/ares/docs",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/invoices",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/admin",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/data",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/dbquery",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/info",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/lib",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/lib/DBD",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/logs",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/temp",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/unpack/mcart/user"
	);

	# add template pkgs DIRs structure to unpack paths for search/replace
	# root Dir ./unpack/mofcart/pkg -----------> ./copy/mofcart/pkg
	# docs Dir ./unpack/mofcart/pkg/docs ------> ./copy/mofcart/pkg/docs
	# images Dir ./unpack/mofcart/pkg/images --> ./copy/mofcart/pkg/images

		foreach $add (@template_pkgs) {
			push (@dirsUnpack,"$newpath/$add");
			push (@dirsUnpack,"$newpath/$add/docs");
			push (@dirsUnpack,"$newpath/$add/images");
			}	

	print "Content-Type: text/html\n\n";
	print "$out";
	$out = '';

	print qq~
	<tr Class="form">
	<td Class="line">?</td>
	<td Class="line">#</td>
	<td Class="line">path</td>
	<td Class="line">copy</td>
	<td Class="line">updt</td>
	<td Class="line">read</td>
	<td Class="line">write</td>
	<td Class="line">Rd err</td>
	<td Class="line">Wr err</td>
	<td Class="line">Rplcd</td>
	</tr>~;

	# Search, Replace, Copy --> ../mcart/copy (holding area)
	foreach $d (@dirsUnpack) {

		# reset
		($sr,$cp,$nn,$r_err,$w_err,$r_ok,$w_ok,$t_vars)=(0,0,0,0,0,0,0,0);

		$status{$d} = "OK";
		$status{$d} = "Error" unless (chdir($d));
		$status{$d} = "Error" unless (opendir(DIR,$d));
		@files = readdir(DIR);
		closedir(DIR);

		foreach $f (@files) {
		if ( -f $f) {

			$nn++;
			$tnn++;

			foreach $t (@types) {
			# reset
			$istype = 0;
			if ($f =~ /$t$/) {
				$istype++;
				last;
			}}

			# updatable file types
			if ($istype) {
				$sr++;
				$tsr++;
				push(@srTypes,"$d/$f");

				# srch/replace operations
				if (open (RDE,"$d/$f")) {
				$r_ok++;
				$tr_ok++;
				$status{"$d/$f"} = "Read OK";

					@old = <RDE>;
					close(RDE);
					@new = ();
					chomp(@old);
		
					foreach (@old) {

						# Filter for *only* MVAR-Vars because the MVAR occurs on the same line
						# as another OS var, etc., so we must be able to swap global
						# instances of all MVARs per line, without swaping any other
						# mentioned VAR in the save array

						if ($_ =~ /MVAR-/) {

							while (($n,$v) = each (%save)) { 
							if ($n =~ /^MVAR-/) {

							# count is only doing first match in line
							$t_vars++ if ($_ =~ /$n/);
							$all_vars++ if ($_ =~ /$n/);

								# crypt the .htpasswd / .htadmin user:pswds
								# Naming Convention - MVAR-name-USR : MVAR-name-PSWD
								# But *only* crypt to .htpasswd .htadmin
								# Must preserve the unCrypted PSWD to send to user

								if ($f eq '.htpasswd' or $f eq '.htadmin') {
								if($n =~ /PSWD/) {
									$usr = $n;
									$usr =~ s/PSWD/USR/;
									$v = crypt($save{$n},$save{$usr});
 									}}
			
							# exact substitution
							$_ =~ (s/$n/$v/g);	
							}}
						}
					push (@new,$_);
					}

					# id destination dir
					$pth = "$d/$f";
					$pth =~ s/unpack/copy/ig;

					if (open (WRT,">$pth")) {

						foreach (@new) {
						print WRT "$_\n";
						}

						close(WRT);
						$w_ok++;
						$tw_ok++;
						$t_srch++;
						$status{$pth} = "Write OK";

					} else {
					$w_err++;
					$tw_err++;
					$status{$pth} = "Write Error";
					}

				# file open err
				} else {
				$r_err++;
				$tr_err++;
				$status{"$d/$f"} = "Read Error";
				}

			# just copy
			} else {
				$cp++;
				$tcp++;
				$t_copy++;
				push(@cpTypes,"$d/$f");

				# id destination dir
				$pth = "$d/$f";
				$pth =~ s/unpack/copy/ig;
				copy("$d/$f","$pth");

			}
		}}

	print qq~
	<tr Class="form">
	<td Class="pathleft">$status{$d}</td>
	<td Class="pathcenter">$nn</td>
	<td Class="pathleft">$d</td>
	<td Class="pathcenter">$cp</td>
	<td Class="pathcenter">$sr</td>
	<td Class="pathcenter">$r_ok</td>
	<td Class="pathcenter">$w_ok</td>
	<td Class="pathcenter">$r_err</td>
	<td Class="pathcenter">$w_err</td>
	<td Class="pathcenter">$t_vars</td>
	</tr>~;

	} # end unPack Dirs

	# static dir structure : from ../mcart/copy --> site
	my %dirsCopy = (
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/ares"=>"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/ares",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/ares/docs"=>"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/ares/docs",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/invoices"=>"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/invoices",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/admin"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/admin",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/data"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/data",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/dbquery"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/dbquery",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/info"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/info",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/lib"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/lib",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/lib/DBD"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/lib/DBD",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/logs"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/logs",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/temp"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/temp",
	"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/user"=>"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/user",
	);

	# add selected pkg to %dirsCopy settings
	# From: MVAR-FRONT-PATH-CGI-MCART-ROOT/copy/mofcart/$usepkg/[docs/images]
	#   To: MVAR-FRONT-PATH-WEB-ROOT/mofcart/[docs/images]

	my $pkgpath = "$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mofcart/$usepkg";
	$dirsCopy{"$pkgpath"} = "$save{'MVAR-FRONT-PATH-WEB-ROOT'}/mofcart";
	$dirsCopy{"$pkgpath/docs"} = "$save{'MVAR-FRONT-PATH-WEB-ROOT'}/mofcart/docs";
	$dirsCopy{"$pkgpath/images"} = "$save{'MVAR-FRONT-PATH-WEB-ROOT'}/mofcart/images";

	# copy to site
	my $err = qq~
	<p><li>Set Up will not Overwrite existing files in your Main Web Filespace
	<li>You must rename, move, or delete directories and contents that Set Up needs
	<p><li>Here is a list of clean directories needed by the install
	<li>$save{'MVAR-FRONT-PATH-WEB-ROOT'}/ares
	<li>$save{'MVAR-FRONT-PATH-WEB-ROOT'}/mofcart
	<li>$save{'MVAR-FRONT-PATH-WEB-ROOT'}/invoices
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/admin
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/dbquery
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/info
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/lib
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/logs
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/temp
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/user
	<li>$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/admin
	~;

	while (($n,$v) = each (%dirsCopy)) { 

		$cpstatus{$n} = "OK";
		$cpstatus{$n} = "Error" unless (chdir($n));
		$cpstatus{$n} = "Error" unless (opendir(DIR,$n));
		@files = readdir(DIR);
		closedir(DIR);

			foreach $f (@files) {
			if ( -f $f) {

# Gonna have to come up with something for unable to write to apache apache u/g
# need the setup.cgi script running under UID credentials

				if ( -e "$v/$f" && !$overwrite_files) {
				&doErr($err);		
						
				# you can either err out here and be safe
				# or you can log the -e as (not copied)
				# and advise installer to double check, remove destination contents

				} else {

					# overwriting, or copying 
					copy("$n/$f","$v/$f");

					# set *.cgi 0755 unless MSwin
					unless ($save{'OS_PERL'} =~ /MSwin/i){
					chmod (0755, "$v\/$f") if ($f =~ /\.cgi$/i);
					}
	
				}

			}}


	}


	# find sendmail, send message

	# Summary #
	print qq~
	<tr Class="form">
	<td Class="line"><br></td>
	<td Class="line">$tnn</td>
	<td Class="line"><br></td>
	<td Class="line">$tcp</td>
	<td Class="line">$tsr</td>
	<td Class="line">$tr_ok</td>
	<td Class="line">$tw_ok</td>
	<td Class="line">$tr_err</td>
	<td Class="line">$tw_err</td>
	<td Class="line">$all_vars</td>
	</tr>~;

	print qq~
	<tr Class="form"><td colspan="10" Class="label">Files updated : $t_srch</td></tr>
	<tr Class="form"><td colspan="10" Class="label">Files copied : $t_copy</td></tr>
	<tr Class="form"><td colspan="10" Class="label">Strings Replaced : $all_vars</td></tr>
	<tr Class="form"><td colspan="10" Class="label">
	The <b>Getting Started</b> information is here : 
	<a href="$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'}/mofcart/docs/mofinstallation.html">
	$save{'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'}/mofcart/docs/mofinstallation.html</a>
	<br> If password protection is enabled for this area, the User:pswd pair is:
	<li>user : $save{'MVAR-DOCS-USR'}
	<li>pass : $save{'MVAR-DOCS-PSWD'}
	<li>A copy of the settings for this installation was saved to log:

	<script type="text/javascript" language="JavaScript">
	<!-- Begin
	function closeWin() {
	text =  "<html><head><title>Working ..</title></head><body><center>"\;
	text += "<strong>Install Script Completed ..</strong><br><br>"\;
	text += "</center></body></html>"\;
	newWindow = window.open('','MESSAGE')\;
	newWindow.document.write(text)\;
	setTimeout('closeNow(text)',2000); 
	newWindow.focus()\;
	}
	function closeNow(text) {
	newWindow.focus()\;
	newWindow.close()\;
	}
	closeWin()\;
	//  End -->
	</script>

	</td></tr>
	~;

	# MAKE LOG #
	my (@srt) = ();
	my (@log) = ();
	
		# save log of file operations
		$pth = "$ShortDate"."$Time"."\.txt";
		$pth =~ s/\///g;
		$pth =~ s/\://g;
		$pth = "$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/logs/$pth";

		@srt = sort { lc($a) cmp lc($b) } (keys %status);
		foreach (@srt) {
		push(@log,"$_\t$status{$_}\n");
		}

		@srt = sort { lc($a) cmp lc($b) } (keys %save);
		foreach (@srt) {
		push(@log,"$_\t$save{$_}\n");
		}

		chomp(@log);
		open (WRT,">$pth");
		print WRT "LOG CREATED: $base\n";
		foreach (@log) {
		print WRT "$_\n";
		}
		close(WRT);

	print qq~</table></form>$footer~;
	}




# MAKE DIRECTORIES
sub doMakeDirs {

	my ($d,$n,$p,$r,$w,$e,$pth);
	# each template pkg has sub Dir under ./copy/mofcart/pkg/[docs/images]
	my $newpath = "$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mofcart";

	# September 08, 2003 12:59:07 AM
	# absolute paths for FRONT End web root & cgi-bin root
	# $save{'MVAR-FRONT-PATH-WEB-ROOT'}
	# $save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}

	# absolute paths for BACK End web root & cgi-bin root
	# The MakeDirs routine (for now) uses Front End only
	# Which is *not* compatible with split HTTP/HTTPS installs
	# where HTTP/HTTPS is mapped to different filespace on server
	# $save{'MVAR-BACK-PATH-WEB-ROOT'}
	# $save{'MVAR-BACK-PATH-CGI-MCART-ROOT'}

	# Try script UID defaults for write permissions first
	# then go to 755, then 777 (for write dirs)
	# you can also specifically set each Dir value with XXX

	# first level Dirs
	my %dirs1 = (
		# http root
		"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/ares",'',
		"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/mofcart",'',
		"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/invoices",'777',
		# cgi-bin
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/admin",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/data",'777',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/dbquery",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/info",'777',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/lib",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/logs",'777',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/temp",'777',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/user",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy",''
		);

	# level (2)
	my %dirs2 = (
		# http root
		"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/ares/docs",'',
		"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/mofcart/docs",'',
		"$save{'MVAR-FRONT-PATH-WEB-ROOT'}/mofcart/images",'',
		# cgi-bin
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/lib/DBD",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/ares",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/invoices",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mofcart",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart",''
		);

	# level (3)
	my %dirs3 = (
		# cgi-bin (copy only)
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/ares/docs",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/admin",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/data",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/dbquery",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/info",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/lib",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/logs",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/temp",'',
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/user",''
		);

		# add level (3) template pkg root DIR
		# copy root dir for template pkgs ./copy/mofcart/root
		foreach $pth (@template_pkgs) {
			$dirs3{"$newpath/$pth"}="";
			}

	# level (4)
	my %dirs4 = (
		"$save{'MVAR-FRONT-PATH-CGI-MCART-ROOT'}/copy/mcart/lib/DBD",''
		);

		# add level (4) template pkg root DIRs
		# copy dirs for template pkgs ./copy/mofcart/root/docs & ./copy/mofcart/root/images
		foreach $pth (@template_pkgs) {
			$dirs4{"$newpath/$pth/docs"}="";
			$dirs4{"$newpath/$pth/images"}="";
			}

	if ($overwrite_files) {
	$info = qq~
	<font size="2"color="red"><strong>VERY SERIOUS WARNING : File OverWrite Is Enabled</strong></font><br>
	<font size="2"color="black">You are about to Overwrite Files on your Server. This 
	cannot be undone. If you are not 100% certain about what you are doing, BACKUP your entire
	Web Site Now! This setting can overwrite and destroy a previous copy of MerchantOrderForm cart, 
	including <b>ALL</b> custom settings, shipping, code, templates, and any files in Directories 
	used in the installation. If you do not want to OverWrite files then you must Disable the 
	setting <b>\$overwrite_files</b> in <b>setup.cgi</b>, and then go back through the installation.
	</font><p>
	~;
	}

	# directions next step
	$info .= qq~
	<table cellpadding="0">
	<tr><td Class="compL">1. </td><td Class="compL">Agreement Logged</td><td Class="compR">COMPLETED</td>
 	<td Class="default" rowspan="6">
	<P>
	<b>STEP 5 of 5 : Replace Settings</b><br>
	Setup will now begin importing your settings into the
	script configurations. Click "Begin Replacement >" to begin copying your settings
	to the script configurations, templates, and example pages.
	</P>
	</td>
	</tr>
	<tr><td Class="compL">2. </td><td Class="compL">Adjust All Settings</td><td Class="compR">COMPLETED</td></tr>
	<tr><td Class="compL">3. </td><td Class="compL">Testing Settings</td><td Class="compR">COMPLETED</td></tr>
	<tr><td Class="compL">4. </td><td Class="compL">Make Directories</td><td Class="compR">COMPLETED</td></tr>
	<tr><td Class="thisL">5. </td><td Class="thisL">Replace & Copy</td><td Class="thisR"> = = = = = > </td></tr>
	</table>
	~;


	$out .= qq~
	$header
	<font size="2"><li>$Date $ShortTime</font>
	<font size="2"><li>$save{'USER-AGREEMENT'} : </font><font size="1">SETTINGS</font>
	<font size="2"><li>$base : </font><font size="1">CURRENT</font>
	<p>
	<form name="myFORM" method="post" action="$prg">
	<input type="hidden" name="frmFUNCTION" value="REPLACE">
	<table Class="form">
	<tr Class="info"><td colspan="4" Class="info">$info</td></tr>
	<tr><td colspan="4" Class="titleValidate">DIRECTORIES CREATED</td></tr>
	<tr><td Class="line">Status</td>
	<td Class="line">Readable</td>
	<td Class="line">Writable</td>
	<td Class="line">Directory Path</td></tr>
	~;

	# first level DIRs
	while (($n,$p) = each (%dirs1)) {
		$d = 'Created';
		$d = "Already Exists" if ( -d "$n");

		# mkdir after -d check
		# mkdir under script running permissions first
		# default permissions best, then 0755, to 0777 until we get read/write
		# also need to trap error here if unable to create

		unless ($d eq "Already Exists") {
		# windoze
		if ($^O =~ m/mswin32/i) {
			# best to mkdir under
			mkdir "$n", 0755;
		# unix/linux
		} else {
			# still needs testing on linux		
			mkdir "$n", 0755;
			# upgrade perms only for Dirs flagged as write '777' in list
			if ($p) {
			chmod(0755,$n) unless ( -w "$n");
			chmod(0777,$n) unless ( -w "$n");
			}
		}}

		$r = 'No';
		$r = 'Yes' if ( -r "$n");
		$w = 'No';
		$w = 'Yes' if ( -w "$n");
		$out .= "<tr Class=\"form\">";
		$out .= "<td Class=\"label\">$d</td>";
		$out .= "<td Class=\"label\">$r</td>";
		$out .= "<td Class=\"label\">$w</td>";
		$out .= "<td Class=\"input\">$n</td></tr>";
		}



	# second level Dirs
	while (($n,$p) = each (%dirs2)) {
		$d = 'Created';
		$d = "Already Exists" if ( -d "$n");
		unless ($d eq "Already Exists") {
		if ($^O =~ m/mswin32/i) {
			mkdir "$n", 0755;
		} else {
			mkdir "$n", 0755;
			if ($p) {
			chmod(0755,$n) unless ( -w "$n");
			chmod(0777,$n) unless ( -w "$n");
			}
		}}
		$r = 'No';
		$r = 'Yes' if ( -r "$n");
		$w = 'No';
		$w = 'Yes' if ( -w "$n");
		$out .= "<tr Class=\"form\">";
		$out .= "<td Class=\"label\">$d</td>";
		$out .= "<td Class=\"label\">$r</td>";
		$out .= "<td Class=\"label\">$w</td>";
		$out .= "<td Class=\"input\">$n</td></tr>";
		}


	# third level Dirs
	while (($n,$p) = each (%dirs3)) {
		$d = 'Created';
		$d = "Already Exists" if ( -d "$n");
		unless ($d eq "Already Exists") {
		if ($^O =~ m/mswin32/i) {
			mkdir "$n", 0755;
		} else {
			mkdir "$n", 0755;
			if ($p) {
			chmod(0755,$n) unless ( -w "$n");
			chmod(0777,$n) unless ( -w "$n");
			}
		}}
		$r = 'No';
		$r = 'Yes' if ( -r "$n");
		$w = 'No';
		$w = 'Yes' if ( -w "$n");
		$out .= "<tr Class=\"form\">";
		$out .= "<td Class=\"label\">$d</td>";
		$out .= "<td Class=\"label\">$r</td>";
		$out .= "<td Class=\"label\">$w</td>";
		$out .= "<td Class=\"input\">$n</td></tr>";
		}


	# fourth level Dirs
	while (($n,$p) = each (%dirs4)) {
		$d = 'Created';
		$d = "Already Exists" if ( -d "$n");
		unless ($d eq "Already Exists") {
		if ($^O =~ m/mswin32/i) {
			mkdir "$n", 0755;
		} else {
			mkdir "$n", 0755;
			if ($p) {
			chmod(0755,$n) unless ( -w "$n");
			chmod(0777,$n) unless ( -w "$n");
			}
		}}
		$r = 'No';
		$r = 'Yes' if ( -r "$n");
		$w = 'No';
		$w = 'Yes' if ( -w "$n");
		$out .= "<tr Class=\"form\">";
		$out .= "<td Class=\"label\">$d</td>";
		$out .= "<td Class=\"label\">$r</td>";
		$out .= "<td Class=\"label\">$w</td>";
		$out .= "<td Class=\"input\">$n</td></tr>";
		}

# close msg
$out .= qq~
<script type="text/javascript" language="JavaScript">
<!-- Begin
function popupWin() {
text =  "<html><head><title>Working ..</title>"\;
text += "</head><body><center><strong>Please Wait .. </strong><br><br>"\;
text += "</center></body></html>"\;
newWindow = window.open('','MESSAGE','directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=no,width=300,height=100,resizable=no,left=300,top=300')\;
newWindow.document.write(text)\;
}
//  End -->
</script>
<tr Class="form"><td align="right"><br></td><td colspan="3" align="right">
<a href="javascript:document.myFORM.submit()\; javascript:popupWin()\;" 
 onmouseover="status='Continue ..'\;return true\;" 
 onmouseout="status='&nbsp'\;return true\;">
<input Class="btn" type="button" value="Begin Replacement >>" 
onclick="javascript:document.myFORM.submit()\; javascript:popupWin()\;"></a> 
</td></tr>
~;

$out .= qq~<tr><td><br></td><td colspan="3" Class="line">SAVED SETTINGS</td></tr>~;
	foreach (@mvarsort) {
		if(exists($save{$_})) {
		$out .= qq~<tr Class="form"><td Class="label">$_</td><td colspan="3" Class="input">~;
		$out .= "$save{$_}" if ($save{$_});
		$out .= "(null)" unless ($save{$_});
		$out .= "</td></tr>";
		}
	}

$out .= qq~<tr><td><br></td><td colspan="3" Class="line">ENVIRONMENT SETTINGS</td></tr>~;
	my @srt = sort { lc($a) cmp lc($b) } (keys %save);
	foreach (@srt) {
		unless ($_ =~ /^MVAR-/i) {
		$out .= qq~<tr Class="form"><td Class="label">$_</td><td colspan="3" Class="input">~;
		$out .= "$save{$_}" if ($save{$_});
		$out .= "(null)" unless ($save{$_});
		$out .= "</td></tr>";
		}
	}

$out .= qq~</table></form>$footer~;
print "Content-Type: text/html\n\n";
print "$out";
}

# print 
sub doForm {
my (%in) = @_;
my ($n,$v,$l,$out);
# input frmNAME, frmFUNCTION 
# (do not hyphenate names, values for frmNAME, frmFUNCTION)
# input: MVAR- (text box input name, value)

if ($overwrite_files) {
	$in{'frmMESSAGE'} .= qq~
	<font size="2"color="red"><strong>WARNING : File OverWrite Is Enabled : WARNING</strong></font><br>
	<font size="2"color="black">Disable setting <b>\$overwrite_files</b> in <b>setup.cgi</b> 
	unless you are very clear about this feature. This setting can overwrite and destroy a 
	previous copy of MerchantOrderForm cart, including <b>ALL</b> custom settings, shipping, code,
	templates, and any files in Directories used in the installation.</font><p>
	~;
	}

my $step;
$step = 'INPUT AREA : ';
$step .= 'Adjust Settings (2/5)' if($save{'frmFUNCTION'} eq "AGREEMENT");
$step .= 'Testing Paths (3/5)' if($save{'frmFUNCTION'} eq "SETTINGS");
$step .= 'Create Directories (4/5)' if($save{'frmFUNCTION'} eq "TESTING");
$step .= 'Install Files (5/5)' if($save{'frmFUNCTION'} eq "MAKEDIRS");
$step .= 'Installation Completed' if($save{'frmFUNCTION'} eq "REPLACE");

$out .= qq~
$header
<font size="2"><li>$Date $ShortTime</font>
<font size="2"><li>$save{'USER-AGREEMENT'} : </font><font size="1">SETTINGS</font>
<font size="2"><li>$base : </font><font size="1">CURRENT</font>
<p>
$in{'frmMESSAGE'}
<form name="myFORM" method="post" action="$prg">
<input type="hidden" name="frmFUNCTION" value="$in{'frmFUNCTION'}">
<table Class="form">
<tr Class="info"><td colspan="2" Class="info">$in{'frmINFO'}</td></tr>
<tr><td Class="thisL"><b>$step</b></td>
<td Class="line">SETTINGS FOR THIS STEP</td></tr>
~;

	# this will set up textBox input for MVAR_(s) sent
	# prefill $v if exists in %save **********************
	# yet accept any changes by user ********************

	# this is listing all newly sent vars for this frmFUNCTION
	# it is *not* listing %save
	# %save is set as First Save, then saved,
	# %save is fetched on subsequent frmFUNCTIONS, is global, has previous saves

	foreach (@mvarsort) {
	if (exists($in{$_})) {
	$out .= "<tr Class=\"form\">";
		# if validation error
		if (exists($missing{$_})) {

		$out .= "<td Class=\"vlabel\"><a class=\"NArial\" href=\"javascript:void(0)\" "; 
		$out .= "onMouseover=\"EnterContent('ToolTip','";
		$out .= "$helpSys{$_}";
		$out .="')\; Activate()\; \""; 
		$out .= "onMouseout=\"deActivate()\"> <b>$_</b> </a></td>\n";

		$out .= "<td Class=\"vinput\"><input Class=\"vtextBox\"name=\"$_\" value=\"";

		} else {

		$out .= "<td Class=\"label\"><a class=\"NArial\" href=\"javascript:void(0)\" "; 
		$out .= "onMouseover=\"EnterContent('ToolTip','";
		$out .= "$helpSys{$_}";
		$out .="')\; Activate()\; \""; 
		$out .= "onMouseout=\"deActivate()\"> <b>$_</b> </a></td>\n";

		$out .= "<td Class=\"input\"><input Class=\"textBox\"name=\"$_\" value=\"";
		}

	$out .= "$in{$_}" unless ($save{$_}); 
	$out .= "$save{$_}" if ($save{$_}); 
	$out .= "\">";
	$out .= "</td></tr>";

	}}


# what button ?
my $bttn = 'Save & Continue >';
$bttn = 'Create Directories >' if ($frm{'frmFUNCTION'} eq "TESTING");

# button
$out .= qq~
<tr Class="form"><td align="right"><br></td><td align="right">
<a href="javascript:document.myFORM.submit()\;" 
 onmouseover="status='Continue ..'\;return true\;" 
 onmouseout="status='&nbsp'\;return true\;">
<input Class="btn" type="button" value="$bttn" 
 onclick="javascript:document.myFORM.submit()\;"></a></td></tr>
~;

$out .= qq~<tr><td><br></td><td Class="line">SAVED SETTINGS</td></tr>~;
	foreach (@mvarsort) {
		if(exists($save{$_})) {
		$out .= qq~<tr Class="form"><td Class="label">$_</td><td Class="input">~;
		$out .= "$save{$_}" if ($save{$_});
		$out .= "(null)" unless ($save{$_});
		$out .= "</td></tr>";
		}
	}

$out .= qq~<tr><td><br></td><td Class="line">ENVIRONMENT SETTINGS</td></tr>~;
	my @srt = sort { lc($a) cmp lc($b) } (keys %save);
	foreach (@srt) {
		unless ($_ =~ /^MVAR-/i) {
		$out .= qq~<tr Class="form"><td Class="label">$_</td><td Class="input">~;
		$out .= "$save{$_}" if ($save{$_});
		$out .= "(null)" unless ($save{$_});
		$out .= "</td></tr>";
		}
	}

$out .= qq~</table></form>$footer~;
print "Content-Type: text/html\n\n";
print "$out";
}


# agreement/terms
sub doTerms {
my ($term) = @_;
my ($out);

$out .= $header;

$out .= qq~ 
<form name="frmAgreementYes" method="post" action="$prg">
<input type="hidden" name="frmFUNCTION" value="AGREEMENT">
<input type="hidden" name="frmAGREEMENT" value="CONTINUE">
</form>
<form name="frmAgreementNo" method="post" action="$prg">
<input type="hidden" name="frmFUNCTION" value="AGREEMENT">
</form>

<table Class="form"><tr Class="info"><td Class="info">$agreement</td></tr></table>

<a href="javascript:document.frmAgreementYes.submit()\;" onmouseover="status='Click To Submit Agreement'\;return true\;" onmouseout="status='&nbsp'\;return true\;">
<input Class="btn" type="button" value="Yes, I Agree" onclick="javascript:document.frmAgreementYes.submit()\;"></a>
<a href="javascript:document.frmAgreementNo.submit()\;" onmouseover="status='Click To Abort Agreement'\;return true\;" onmouseout="status='&nbsp'\;return true\;">
<input Class="btn" type="button" value="No, Cancel Install" onclick="javascript:document.frmAgreementNo.submit()\;"></a>
~;

if ($term =~ /cancel/i) {
$out .= qq~
<p Class="default"><font color="red"><b>Installation Cancelled by User</b></font><br>$base</p>
<p Class="default">Close your browser and delete any MOFcart v2.5 files that you uploaded to your server.</p>~;
}

if ($term =~ /first/i) {
$out .= qq~
<p Class="default"><font color="navy"><b>Please Read the Agreement & Terms</b></font><br>$base</p>
<p Class="default">If you agree to abide by these License Terms, click "agree" to proceed with installation.</p>~;
}

if ($term =~ /error/i) {
$out .= qq~
<p Class="default"><font color="red"><b>An Unknown Error Occurred</b></font><br>$base</p>
<p Class="default">Please Read the Agreement & Terms, and click "agree" to proceed with installation.</p>~;
}

$out .= $footer;
print "Content-Type: text/html\n\n";
print "$out";
exit if ($term =~ /exit/i);
}


sub listMissing {
	my $list;
	$list .= "<table width=\"100%\"><tr><td colspan=\"3\" Class=\"titleValidate\">";
	$list .= "$failed FIELD(S) NEED CORRECTING</td></tr>";

	$list .= "<tr><td Class=\"line\">Setting</td>";
	$list .= "<td Class=\"line\">Input</td><td Class=\"line\">Problem</td></tr>";

	foreach (@mvarsort) {
	if (exists($missing{$_})) {
		$list .= "<tr><td Class=\"nameValidate\">$_ : </td>"; 
		$list .= "<td Class=\"valueValidate\">$frm{$_}</td>";
		$list .= "<td Class=\"noteValidate\"> $missing{$_}</td></tr>";
		}}
	$list .= "</table>";	
	return $list;
	}

# make Pswd
sub genPsw {
	# genPsw idea by Scott Stolpmann 2-19-2000
	# Alpha-Numerical Generator
	# submit (size (in length))
	my ($size) = @_;
	$size=6 unless $size;
   	my ($myPsw) = "";
	my $l,$c;
	# psw length $i<6
	for($i=0; $i< $size; $i++){ 
	$l =int(rand 3) +1;
	$c =int(rand 7) +50 if ($l ==1);
	$c =int(rand 25) +65 if ($l ==2);
	$c =int(rand 25) +97 if ($l ==3);
	$c =chr($c);
	$myPsw .= $c;
	}
	return ($myPsw);
	}

sub random_password {
# &random_password(length); or default to 6
   	my ($maxlen) = $_[0] || 6;
   	my ($myPsw) = "";
   	my (@vowel) = (
	qw (a a a e e e e i i i o o o u u y ai au ay ea ee eu ia ie io oa oi oo oy));
   	my (@consonant) = (
	qw (b c d f g h j k l m n p qu r s t v w x z th st sh ph ng nd));
   	srand;                 
   	my ($vowelnext) = int(rand(2));
		do {
      	if ($vowelnext) {
      	$myPsw .= $vowel[rand(@vowel)];
      	} else {
      	$myPsw .= $consonant[rand(@consonant)];
      	}
      	$vowelnext = !$vowelnext;
   		} until length($myPsw) >= $maxlen;
   	return $myPsw;
	}


## Encryption and Decryption : http://www.smartCGIs.com
## Jimmy (wordx@hotmail.com) : (c) copyright 2000 SmartCGIs.com
## syntax: $v = &doEncrypt(psw,KEY,PublicKey)

sub doEncrypt {
        my ($source,$key,$pub_key) = @_;
        my ($cr,$index,$char,$key_char,$enc_string,$encode,$first,
        $second,$let1,$let2,$encrypted,$escapes) = '';
        $source = &rot13($source);
        $cr = '╖иа';
        $source =~ s/[\n\f]//g;
        $source =~ s/[\r]/$cr/g;
        while ( length($key) < length($source) ) { $key .= $key }
        $key=substr($key,0,length($source));
        while ($index < length($source)) {
        $char = substr($source,$index,1);
        $key_char = substr($key,$index,1);
        $enc_string .= chr(ord($char) ^ ord($key_char));
        $index++;
        }
    for (0..255) { $escapes{chr($_)} = sprintf("%2x", $_); }
    $index=0;
    while ($index < length($enc_string)) {
        $char = substr($enc_string,$index,1);
        $encode = $escapes{$char};
        $first = substr($encode,0,1);
        $second = substr($encode,1,1);
        $let1=substr($pub_key, hex($first),1);
        $let2=substr($pub_key, hex($second),1);
        $encrypted .= "$let1$let2";
        $index++;
    }
    return $encrypted;
}

sub doDecrypt {
   	my ($encrypted, $key, $pub_key) = @_;
    $encrypted =~ s/[\n\r\t\f]//eg;
    my ($cr,$index,$decode,$decode2,$char,$key_char,$dec_string,$decrypted) = '';
    while ( length($key) < length($encrypted) ) { $key .= $key }
    $key=substr($key,0,length($encrypted));
    while ($index < length($encrypted)) {
        $decode = sprintf("%1x", index($pub_key, substr($encrypted,$index,1)));
        $index++;
        $decode2 = sprintf("%1x", index($pub_key, substr($encrypted,$index,1)));
        $index++;
        $dec_string .= chr(hex("$decode$decode2"));
    }
    $index=0;
    while( $index < length($dec_string) ) {
        $char = substr($dec_string,$index,1);
        $key_char = substr($key,$index,1);
        $decrypted .= chr(ord($char) ^ ord($key_char));
        $index++;
    }
    $cr = '╖иа';
    $decrypted =~ s/$cr/\r/g;
    return &rot13( $decrypted );
}

sub rot13 {
   	my $source = shift (@_);
	$source =~ tr /[a-m][n-z]/[n-z][a-m]/;
    $source =~ tr /[A-M][N-Z]/[N-Z][A-M]/;
    $source = reverse($source);
    return $source;
	}


# functions
sub doDate {
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

sub doInput {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);
	foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/\n//d;
	$value =~ tr/\r//d;
	$value =~ tr/+/ /;
	$frm{$name} = $value;
	}}

sub doCheck {
	my ($p) = @_;
	$fileCheck{'FileExists'} = "Exists: $p" if ( -e "$p" );
	$fileCheck{'IsDirectory'} = "Is Dir: $p" if ( -d "$p");
	$fileCheck{'eOwned'} = "effective User Owned: $p" if ( -o "$p");
	$fileCheck{'eRead'} = "effective User Read: $p" if ( -r "$p");
	$fileCheck{'eWrite'} = "effective User Write: $p" if ( -w "$p");
	$fileCheck{'eExe'} = "effective User Execute: $p" if ( -x "$p");
	$fileCheck{'rOwned'} = "real User Owned: $p" if ( -O "$p");
	$fileCheck{'rRead'} = "real User Read: $p" if ( -R "$p");
	$fileCheck{'rWrite'} = "real User Write: $p" if ( -W "$p");
	$fileCheck{'rExe'} = "real User Execute: $p" if ( -X "$p");
	return %fileCheck;
	}


sub doValidate {
# note: validates a passed field with /REGEX/
# You may omit the field, or put null /REGEX/ if not required
my (%in) = @_;
my ($field,$regx);

	while (($field,$regx) = each (%in)) {
	$regx =~ (s/\///g);

	if ($regx) {
	unless ($frm{$field} =~ /$regx/) {
		if ($frm{$field}) {
		$missing{$field} = "Incorrect";
		} else {
   		$missing{$field} = "Missing";
		}	
	}}}

	return (%missing);
	}


# get configs
sub getConfigs {
	my ($p) = @_;
	my ($n,$v);
	my (@cfgs) = ();
	&doErr("Cannot Read $p") unless (open (CFG,"$p")); 
	@cfgs = <CFG>;
	close(CFG);
	chomp(@cfgs);

		foreach (@cfgs) {
		($n,$v) = split(/\t/,$_);
		$save{$n} = $v if ($n);
		}
	undef @cfgs;
#	return %save;
	}

# save
sub saveConfigs {
	my ($p) = @_;
	my ($n,$v);
	my $l;
	$result = 0;
	&doErr("Cannot Write $p") unless (open (CFG,">$p")); 

	while (($n,$v) = each (%save)) { 
	$result++;
	$l .= "$n\t$v\n";
	}

	print CFG $l;
	close(CFG);
	return $result;
	}

# error
sub doErr {
my ($e) = @_;
my ($trace,$evars);

# stack trace
my $i = 0;
while (my ($f,$l,$s) = (caller($i++))[1,2,3]) {
$trace .= qq~($s) called from ($f) line ($l)<BR>\n~;
}

# vars
my(@srt) = sort { lc($a) cmp lc($b) } (keys %ENV);
$evars .= "<hr><u><strong>\%ENV</strong></u><ol>";
	foreach (@srt) {
	$evars .= "<li>$_, <strong>$ENV{$_}</strong>";
	}
	$evars .= "</ol>";
@srt = sort { lc($a) cmp lc($b) } (keys %INC);
	$evars .= "<hr><u><strong>\%INC</strong></u><ol>";
	foreach (@srt) {
	$evars .= "<li>$_, <strong>$INC{$_}</strong>";
	}
	$evars .= "</ol>";
	$evars .= "<hr><u><strong>\@INC</strong></u><ol>";
	foreach (@INC) {
	$evars .= "<li>$_";
	}
	$evars .= "</ol>";

print "Content-Type: text/html\n\n";
print "<html><head><title>Error Message</title></head><body>";
print "Error: $e<p>";
print "$trace<p>";
print "$evars<b>";
print "</body></html>";
exit;	
}



sub doHtml {
$header = qq~
<html><head><title>MOFcart v2.5 Setup ..</title>
<script language = "javascript">
<!--
var ie = document.all ? 1 : 0
var ns = document.layers ? 1 : 0
if(ns){doc = "document."; sty = ""}
if(ie){doc = "document.all."; sty = ".style"}
var initialize = 0
var Ex, Ey, ContentInfo
if(ie){
Ex = "event.x"
Ey = "event.y"
}
if(ns){
Ex = "e.pageX"
Ey = "e.pageY"
window.captureEvents(Event.MOUSEMOVE)
window.onmousemove=overhere
}
function MoveToolTip(layerName, FromTop, FromLeft, e){
if(ie){eval(doc + layerName + sty + ".top = "  + (eval(FromTop) + 12 + document.body.scrollTop))}
if(ns){eval(doc + layerName + sty + ".top = "  +  eval(FromTop))}
eval(doc + layerName + sty + ".left = " + (eval(FromLeft) + 10))
}
function ReplaceContent(layerName){
if(ie){document.all[layerName].innerHTML = ContentInfo}
if(ns){
with(document.layers[layerName].document) { 
   open(); 
   write(ContentInfo); 
   close(); 
}}}
function Activate(){initialize=1}
function deActivate(){initialize=0}
function overhere(e){
if(initialize){
MoveToolTip("ToolTip", Ey, Ex, e)
eval(doc + "ToolTip" + sty + ".visibility = 'visible'")
}
else{
MoveToolTip("ToolTip", 0, 0)
eval(doc + "ToolTip" + sty + ".visibility = 'hidden'")
}}
function EnterContent(layerName, TContent){
ContentInfo = '<table Class="moreinfo"><tr><td Class="moreinfo">'+TContent+'</td></tr></table>';
ReplaceContent(layerName)
}
//-->
</script>
<style type="text/css">
<!--

FORM { margin-bottom:0; margin-top:0 }
A {text-decoration : none;}
A:ACTIVE {font-weight: normal;color : #808080;font-family: Arial,Serif; background : none;}
A:LINK {font-weight: normal;color : #336699;font-family: Arial,Serif; background : none;}
A:VISITED {font-weight: normal;color : #336699;font-family: Arial,Serif; background : none;}
A.TextLink:HOVER {color : #FF0000; background : #D6D6D6;}
#ToolTip{position:absolute; width: 400px; top: 0px; left: 0px; z-index:4; visibility:hidden;}

BODY {
	font-size : 10px;	
	font-weight : normal;
	font-family : 
	Arial,Serif;
	}

P.default {
	color: Black;
	font-size : 12px;
	text-align : left;
	font-style : normal;
	font-weight : normal;
	font-family : Arial,Serif;
	}

TABLE.form {
	background-color: transparent; 
	color : #000000; 
	font-size: 12px; 
	font-family: Arial,Serif;
	}

TR.form {
	padding: 0px; 
	background: transparent; 
	}

TD.label {  
	padding: 0 4px 0 0;	  
	white-space: nowrap; 
	border : 0;
	color: Black;
	font-size : 11px;
	font-style : normal;
	font-weight : normal;
	text-align : right;
	vertical-align: middle;
	background-color : #F9FBFD;
	font-family : Arial,Serif;
	}

TD.input {  		 
	width: 380px;
	height: 22px;
	padding: 0 0 0 4px;	  
 	white-space: nowrap; 
	border-bottom: 0px; 
	border-left-color: #E2DEAE;
	border-left-width: 3px;
	border-left-style: double;
	border-top: 0px;
	border-right-color: #E2DEAE;
	border-right-width: 3px;
	border-right-style: double;
	color: Black;
	font-size : 12px;
	font-style : normal;
	font-weight : normal;
	text-align : left;
	background-color : #F9F8EE;
	font-family : Arial,Serif;
	}

.thisL {
	color: Navy;
	font-size : 12px;
	text-align : left;
	font-style : normal;
	font-weight : bold;
	white-space: nowrap; 
	font-family : Arial,Serif;
	background-color : #FFFFCD;
	}

TD.default {
	padding: 6px 6px 6px 6px; 
	color: Navy;
	font-size : 12px;
	text-align : left;
	font-style : normal;
	font-weight : normal;
	vertical-align: top;
	font-family : Arial,Serif;
	background-color : #FFFFCD;
	}

TD.compL {
	color: Black;
	white-space: nowrap; 
	font-size : 12px;
	text-align : left;
	font-style : normal;
	font-weight : bold;
	font-family : Arial,Serif;
	background-color : transparent;
	}

TD.compR {
	color: Black;
	font-size : 11px;
	font-style : normal;
	font-weight : normal;
	white-space: nowrap; 
	font-variant: small-caps;
	}

TD.thisL {
	color: Navy;
	font-size : 12px;
	text-align : left;
	font-style : normal;
	font-weight : bold;
	white-space: nowrap; 
	font-family : Arial,Serif;
	background-color : #FFFFCD;
	}

TD.thisR {
	color: Navy;
	font-size : 11px;
	font-style : normal;
	font-weight : bold;
	white-space: nowrap; 
	font-variant: small-caps;
	background-color : #FFFFCD;
	}

TD.nextL {
	color: #B8B8B8;
	font-size : 12px;
	text-align : left;
	font-style : normal;
	font-weight : bold;
	white-space: nowrap; 
	font-family : Arial,Serif;
	background-color : transparent;
	}

TD.nextR {
	color: #B8B8B8;
	font-size : 11px;
	font-style : normal;
	font-weight : normal;
	white-space: nowrap; 
	font-variant: small-caps;
	}

TABLE.moreinfo {	 
	width: 400px;
	border-color: #BDE5C1;
	border-width: 3px;
	border-style: groove;
	background : #F2FAF3 ;	
	font-size : 12px;
	font-style : normal;
	font-weight : normal;
	font-family : Arial,Serif;
	}

TD.moreinfo {	 
	color : #000000;
	font-size : 12px;
	font-style : normal;
	font-weight : normal;
	font-family : Arial,Serif;
	}

.textBox {	  	 
	padding: 0 0 0 5px;
	width: 360px;
	height: 20px;
	border-style: hidden;
	border-width: 0px;
	background-color : #FFFFCD;
	color: #3F5623;
	font-size : 12px;
	font-style : normal;
	font-weight : bold;
	text-align : left;
	font-family : Arial,Serif;
	border-color: #FBFBF4 #FBFBF4 #FBFBF4 #FBFBF4;	
	}

.titleValidate {
	text-align : center;
	color: #FFFFFF;
	font-size : 12px;
	font-style : normal;
	font-weight : bold;
	background-color : #B0B0B0;
	}

.nameValidate {
	text-align : right;
	color: #000000;
	font-size : 11px;
	font-style : normal;
	font-weight : bold;
	}

.valueValidate {
	color: #FF0000;
	font-size : 12px;
	font-style : normal;
	font-weight : bold;
	}

.noteValidate {
	color: #1A53BC;
	font-size : 11px;
	font-style : normal;
	font-weight : normal;
	font-variant: small-caps;
	}

TD.vlabel {  
	padding: 0 4px 0 0;	  
	white-space: nowrap; 
	border : 0;
	color: #FF0000;
	font-size : 11px;
	font-style : normal;
	font-weight : normal;
	text-align : right;
	vertical-align: middle;
	background-color : #FFE3E3;
	font-family : Arial,Serif;
	}

TD.vinput {  		 
	width: 380px;
	height: 22px;
	padding: 0 0 0 4px;	  
 	white-space: nowrap; 
	border-bottom: 0px; 
	border-left-color: #E9EBE9;
	border-left-width: 3px;
	border-left-style: double;
	border-top: 0px;
	border-right-color: #E2DEAE;
	border-right-width: 3px;
	border-right-style: double;
	color: #FF0000;
	font-size : 12px;
	font-style : normal;
	font-weight : normal;
	text-align : left;
	background-color : #FF0000;
	font-family : Arial,Serif;
	}

.vtextBox {	  	 
	padding: 0 0 0 5px;
	width: 360px;
	height: 20px;
	border-style: hidden;
	border-width: 0px;
	background-color : #FFE3E3;
	color: #FF0000;
	font-size : 12px;
	font-style : normal;
	font-weight : bold;
	text-align : left;
	font-family : Arial,Serif;
	border-color: #FBFBF4 #FBFBF4 #FBFBF4 #FBFBF4;	
	}

TR.info {
	}

TD.info {  
	padding: 6px 6px 6px 6px;	
	border-bottom-color: #E2DEAE;
	border-bottom-width: 3px;
	border-bottom-style: double;
	border-left-color: #E2DEAE;
	border-left-width: 3px;
	border-left-style: double;
	border-top-color: #E2DEAE;
	border-top-width: 3px;
	border-top-style: double;
	border-right-color: #E2DEAE;
	border-right-width: 3px;
	border-right-style: double;
	background-color: #FCFCF8;
  	color: Black;
	font-size : 12px;
	font-style : normal;
	font-weight : normal;
	text-align : left;
	vertical-align: top;
	background-color : #FCFCF8;
	font-family : Arial,Serif;
	}

TD.line {  
	padding: 0 4px 0 0;	  
	border-right: 0px; 
	border-left: 0px;
	border-top: 0px;
	border-bottom-color: #E2DEAE;
	border-bottom-width: 3px;
	border-bottom-style: double;
	background-color : #E2DEAE;
	color: #848466;
	font-size : 11px;
	font-style : normal;
	font-weight : bold;
	text-align : center;
	vertical-align: middle;
	font-family : Arial,Serif;
	}

TD.pathleft {	 
	padding: 0 0 0 0;	  
	border-right: 0px; 
	border-left: 0px;
	border-top: 0px;
	border-bottom-color: #E2DEAE;
	border-bottom-width: 1px;
	border-bottom-style: double;
	background-color : #FFFFDF;

	text-align : left;
	color : #000000;
	font-size : 11px;
	font-style : normal;
	font-weight : normal;
	font-family : Arial,Serif;
	}

TD.pathcenter {	 
	padding: 0 0 0 0;	  
	border-right: 0px; 
	border-left: 0px;
	border-top: 0px;
	border-bottom-color: #E2DEAE;
	border-bottom-width: 1px;
	border-bottom-style: double;
	background-color : #FFFFDF;

	text-align : center;
	color : #000000;
	font-size : 11px;
	font-style : normal;
	font-weight : normal;
	font-family : Arial,Serif;
	}

-->
</style>

</head><body onmousemove="overhere()"><div id="ToolTip"></div>
<center>
<table border=0 width="740" cellpadding="4" cellspacing="0">
<tr><td valign="top" align=top> <b><font size="4" color="#006600">
Merchant OrderForm</font><font size="3" color="#006600"> cart</font></b> 
<font size="2" color="#000000" face="Verdana, Arial,Serif">
<b> v2.5 Setup Utility</b></font><br>
~;

$footer = qq~
<p><font face="Verdana" size="1">
These programs are copyright @ <a href="http://www.merchantorderform.com">MerchantOrderForm.com</a>,
<a href="http://www.merchantpal.com">MerchantPal.com</a> 2001-2004</font>
</td></tr></table></center></body></html>
~;

$message = qq~
<font size="1">
<b>Note</b>: The install utility is a tool to configure the entire MOFcart package
to run under your site, using all the packaged examples. For best results, 
make all the settings <u>complete</u> (the way you want the
final cart to operate). The installation utility adjusts all necessary settings 
for the distribution package of MOFcart, which includes scripts, example templates, 
and example product input pages. Once the installation has completed, 
<b>you cannot run the installation utility on the <i>installed</i> files</b>. 
After installation, you can only adjust configuration settings manually and/or 
reinstall the example package.<p>
</font>
~;

$agreement = qq~
<strong><u>MerchantOrderForm Shopping Cart v2.5</u> Perl Code is clean, well organized, open source code. 
I have made no attempt to condense or scramble the code, as that would render the Package 
less suitable for customizing. It was a mamouth effort to produce and package. Please respect the 
licensing restrictions, distribution limitations, and modification Terms & Conditions outlined below. 
</strong>
<p>

MerchantOrderForm Shopping Cart v2.5 & ARES (Affiliate Referral Earnings System) v 2.4 are 
copyright (c) 2000 -2004 Russell Alexander, Austin Contract Computing, and MerchantPal.com (tm).
"Merchant OrderForm" & "MerchantPal.com" are trademarks of Russell Alexander.
<p>

This license statement and limited warranty constitutes a legal agreement ("License Agreement") 
between you ("Licensee", either as an individual or a single entity) and 
Russell Alexander (Austin Contract Computing, Merchant OrderForm) ("Vendor"), 
owner of the "Merchant OrderForm" shopping cart, and "Merchant OrderForm" related programs,
the ("Software Package") of which Russell Alexander is the copyright holder.
<p>

BY INSTALLING, COPYING, OR OTHERWISE USING THIS SOFTWARE PACKAGE, YOU AGREE TO BE BOUND 
BY ALL OF THE TERMS AND CONDITIONS OF THE LICENSE AGREEMENT.
<p>

Upon your acceptance of the terms and conditions of the License Agreement, 
MerchantPal Services, Russell Alexander, & Austin Contract Computing grants 
you the right to use the Software Package in the manner provided below.
<p>

If you do not accept the terms and conditions of the License Agreement, you are to 
promptly delete all copies of the Software Package from your computer(s) and/or server(s).
<p>

The Vendor reserves the right to license the same Software Package to other individuals or 
entities under a different license agreement.
<p>

This Software Package is licensed for <b><u>Installation Only</u></b>. The Software Package, 
and all files included in the Software Package, either individually or together, cannot 
be sold outright & cannot be distributed or downloaded, to any person or entiry, outside 
the number of Installation Licenses Purchased. The Software Package cannot be modified 
and then sold as a package or component, either individually or together.
<p>

You may install, modify, test, enhance, customize, and use the Software Package, 
as an "in service" web application, either individually or together, on the number of 
web sites you are licensed for. Licenses are available in (1) Single User Licenses,
(2) Web Developer Licenses, (3) Special Negotiated Licenses. <b><u>All copyright (c) 
notes commented in the scripts must be unaltered</u></b>. Only a (3) Special License may alter the 
copyright (c) notes commented in the actual scripts, and only as outlined by the Special 
License.
<p>

<b><u>Single User Licenses</u></b> grant you rights to install, modify, test, enhance, customize, 
and use the Software Package in any way you need, for one (1) web site. The Software
Package resides as a web application on one (1) existing server, and for one (1) 
primary web site project. It is permissible to run a Single User License at one 
location, but have several web sites posting input to the cart. The Software Package 
is primarily "in service" on one (1) web site, and one server.
<p>

<b><u>Multi-Site Licenses</u></b> (Web Developer Licenses) permit the Licensee, rights to 
install, modify, test, enhance, customize, and use the Software Package in any way needed, for 
the number of Installation Licenses Purchased. The Software Package resides as a web application 
on only the licensed number of Installation Sites, and primary web site projects. 
This license is intended for Web Developers who want to include a Shopping Cart as part 
of a larger project, or for Web Developers who want to install only the Shopping Cart as a 
service. In either case, the Software Package cannot be made available for download, nor 
can it be set up as a Package in an automated installation service. 
The Developer is expected to charge whatever professional fees are associated with 
either a larger project bid, or the installation service. The End User Client cannot sell, 
or otherwise make available to a person or entity, the Software Package the Developer has installed. 
The End User has rights to modify, test, enhance, customize, or use in anyway needed, but may 
not sell or distribute as a package or component, either individually or together.
<p>

<b><u>Special Licenses</u></b> are required to do anything outside the concept 
outlined in this agreement. Use of the Software Package, either individually or together, 
as a <b><u>Remote Shopping Cart Service</u></b>, or use of the Software Package, either 
individually or together, as a component of a <b><u>Hosting Service</u></b>, or  
inclusion of the Software Package, either individually or together, as a component of a 
<b><u>Shareware or Freeware compilation</u></b>, download service, or script 
<b><u>collection service</u></b>, require a Special License. Please contact me if you 
have any of these type needs. Hosting Licenses are quite affordable, compared to some of 
the other Cart Packages available. In any of the cases above, the person or entiry involved, 
needs to have a Special License Registration on file with me--MerchantPal.com (tm), 
Russell Alexander, or Austin Contract Computing. 

<p>

<b><u>Backup</u></b> copies are not considered "in service" installations. 
<b><u>Transferring</u></b> the Installation 
to a different server than originally installed is permitted, as long as one (1) Installation
License appears "in service" at any one time. Modifications are permitted by eithr the Single 
User or by the Developer and/or Developer End User. The basic concept is that any particular 
installation that appears to be "in service" requires an Installation License, whether the 
License was purchased by the End User (and installed by another), a Single License (installed 
by a do-it-yourselfer), or one of the Installation Licenses used as part of a Developer's 
Multi Site License.  In any of the cases, the Installed or modified Software Package 
may not be sold or distributed, either individually or together. 
<p>

The Software is provided "as is". In no event shall MerchantPal Services, Russell Alexander, or 
Austin Contract Computing be liable for any consequential, special, incidental or indirect 
damages of any kind arising out of the delivery, performance or use of this Software, 
to the maximum extent permitted by applicable law. While the Software has been developed 
with great care, it is not possible to warrant that the Software is error free. The Software 
is not designed or intended to be used in any activity that may cause personal injury, 
death or any other severe damage or loss.
<p>

~;

# help
%helpSys = (
'MVAR-YOUR-CC-KEY'=>
'<b>MVAR-YOUR-CC-KEY:</b> (<font color=red>CaSE sEnSItiVe</font>)<p>An Encryption/Decryption key used to save & retrieve credit card numbers from the secure online retrieval utility. Set up generates a random key when first started. You can change the key during this installation. The key is used by (2) scripts. If you change the key after installation, then you must change BOTH keys, in both scripts that use it. Consult the docs for manually changing the key.<ul><li><u>Notes</u><li>Use alpha-numeric only<li>no spaces or special characters<li>make at least 12 characters</ul>',
'MVAR-YOUR-CC-PSW'=>
'<b>MVAR-YOUR-CC-PSW</b> (<font color=red>CaSE sEnSItiVe</font>)<p>The password to be used to login to the Secure CC Retrieval script. The CC Retrieval script allows for secure storage of cc numbers on the server, and retrieval via your browsers SSL. You must have SSL available for your site to use this correctly.',
'MVAR-ADMIN-USR'=>
'<b>MVAR-ADMIN-USR</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Name Part of the User-PSWD authentication needed to access the admin area. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.</ul>',
'MVAR-ADMIN-PSWD'=>
'<b>MVAR-ADMIN-PSWD</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Password Part of the User-PSWD authentication needed to access the admin area. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.<li>Actual password is crypted in the .htaccess</ul>',
'MVAR-INVOICES-USR'=>
'<b>MVAR-INVOICES-USR</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Name Part of the User-PSWD authentication needed for customers to access the web copy of their invoice. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.</ul>',
'MVAR-INVOICES-PSWD'=>
'<b>MVAR-INVOICES-PSWD</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Password Part of the User-PSWD authentication needed for customers to access the web copy of their invoice. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.<li>Actual password is crypted in the .htaccess</ul>',
'MVAR-DOCS-USR'=>
'<b>MVAR-DOCS-USR</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Name Part of the User-PSWD authentication to keep the documentation area private. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.</ul>',
'MVAR-DOCS-PSWD'=>
'<b>MVAR-DOCS-PSWD</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Password Part of the User-PSWD authentication to keep the documentation area private. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.<li>Actual password is crypted in the .htaccess</ul>',
'MVAR-USER-USR'=>
'<b>MVAR-USER-USR</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Name Part of the User-PSWD authentication needed for ARES Affiliates to access their stats. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.</ul>',
'MVAR-USER-PSWD'=>
'<b>MVAR-USER-PSWD</b> (<font color=red>CaSE sEnSItiVe</font>)<p>Password Part of the User-PSWD authentication needed for ARES Affiliates to access their stats. <ul><li><u>Notes</u><li>Used only for Apache .htaccess on unix/linux<li>ActivePerl & win32 do not use this.<li>Actual password is crypted in the .htaccess</ul>',
'MVAR-BUSINESS-NAME'=>
'<b>MVAR-BUSINESS-NAME</b><p>Business, Web site, Company, etc. Appears on the example templates, and used in auto-mail messages to customer.<blockquote>Business Name<br>Business Mailing Address<br>City, ST postal-code</blockquote>',
'MVAR-BUSINESS-ADDRESS'=>
'<b>MVAR-BUSINESS-ADDRESS</b><p>Mailing Address of business. Appears on the example templates, and used in auto-mail messages to customer.<blockquote>Business Name<br>Business Mailing Address<br>City, ST postal-code</blockquote>',
'MVAR-BUSINESS-CITY-STATE-ZIP'=>
'<b>MVAR-BUSINESS-CITY-STATE-ZIP</b><p>Mailing Address of business: (My City, ST  postalCode). Appears on the example templates, and used in auto-mail messages to customer.<blockquote>Business Name<br>Business Mailing Address<br>City, ST postal-code</blockquote>',
'MVAR-BUSINESS-PHONE'=>
'<b>MVAR-BUSINESS-PHONE</b><p>Phone for business. Appears on the example templates, and used in auto-mail messages to customer.',
'MVAR-BUSINESS-FAX'=>
'<b>MVAR-BUSINESS-FAX</b> (<font color=red>MAKE BLANK IF NO FAX</font>)<p>Fax used. Appears on the example templates, and used in auto-mail messages to customer.',
'MVAR-PHONE-HELP'=>
'<b>MVAR-PHONE-HELP</b><p>Help Line phone, may be different than business phone. Appears on the example templates as number to contact for help. Also used in auto-mail messages to customer.',
'MVAR-DOMAIN-NAME.COM'=>
"<b>MVAR-DOMAIN-NAME.COM</b><p>The server reports this script is running within the Domain Name <b>$ENV{'HTTP_HOST'}</b>. If this is not the Domain Name you intend to run the cart within, then place the setup script in the Domain you want to use the cart for. The installation utility works best when run from same location you will run the cart from. If you need to set a different domain name, make sure you understand all the settings pretty well. <ul><li><u>Notes</u><li>Do <b>not</b> include the <b>HTTP</b> prefix to the Domain Name. <li>Do <b>not</b> use a trailing slash after the Domain Name. <li>Do <b>not</b> leave any spaces in the Domain Name.</ul>",
'MVAR-STRICT-HTTP-WWW.YOURSITE.COM'=>
"<b>MVAR-STRICT-HTTP-WWW.YOURSITE.COM</b><br><li><font color=red>PATHS have no trailing slash</font><p>This is the <b>NON-SSL (HTTP)</b> url (web address) leading to the Web root area. Usually, this is the directory area where your (index.htm) or starting home page is. Even if you will run the cart under SSL, this is a NON-SSL address. <ul><li><u>Setup Reports</u><li><b>$root_http</b></ul>",
'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR'=>
"<b>MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR</b><br><li><font color=red>PATHS have no trailing slash</font><p>This is the <b>NON-SSL (HTTP)</b> url (web address) leading to the <br> <b> ../cgi-bin/mcart </b> directory. Even if you are running the setup.cgi script from an SSL (HTTPS) url, this address must be NON-SSL (HTTP). If you have placed <b>setup.cgi</b> in the <b>../mcart</b> directory, then it is the Strict HTTP url to that directory.<ul><li><u>Setup Reports</u><li><b>$mp</b></ul>",
'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM'=>
"<b>MVAR-FRONT-HTTPs-WWW.YOURSITE.COM</b><br><li><font color=red>PATHS have no trailing slash</font><p>This is the <b>HTTP</b> or <b>HTTPS</b> url (web address) leading to the Web root area. Usually, this is the directory area where your (index.htm) or starting home page is. <p> If you are going to run the cart <b>Front End</b> under SSL (recommended) then it is an <b>HTTPS</b> url. <ul><li><u>Setup Reports</u><li><b>$root_front</b></ul>",
'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR'=>
"<b>MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR</b><br><li><font color=red>PATHS have no trailing slash</font><p>This is the <b>HTTP</b> or <b>HTTPS</b> url (web address) leading to the <br> <b> ../cgi-bin/mcart </b> directory. It is the root url where the <b>mof.cgi</b> - Front End script lives. <p> If you are going to run the cart <b>Front End</b> under SSL (recommended) then it is an <b>HTTPS</b> url. <ul><li><u>Setup Reports</u><li><b>$mf</b></ul>",
'MVAR-FRONT-PATH-WEB-ROOT'=>
"<b>MVAR-FRONT-PATH-WEB-ROOT</b><br><li><font color=red>PATHS have no trailing slash</font><li>It is <b>not</b> an <b>HTTP</b> url<p>This is the sever <b>Absolute Path</b> (actual hard drive file path) leading to the <b>WEB</b> root filespace where the cart <b>FRONT END TEMPLATES</b> live. Consult your server help section for running CGI scripts & absolute paths. <ul><li><u>Setup Reports</u><li><b>$ENV{'DOCUMENT_ROOT'}</b><li>Do not include <b> /mofcart </b> in this path.</ul>",
'MVAR-FRONT-PATH-CGI-MCART-ROOT'=>
"<b>MVAR-FRONT-PATH-CGI-MCART-ROOT</b><br><li><font color=red>PATHS have no trailing slash</font><li>It is <b>not</b> an <b>HTTP</b> url<p>This is the sever <b>Absolute Path</b> (actual hard drive file path) leading to the <b>mcart</b> script directory & <b>FRONT END SCRIPT</b> <b>mof.cgi</b>. Script directories are usually assigned by the server, usually set up as <b>cgi-bin</b>. Consult your server help section for running CGI scripts & absolute paths. <ul><li><u>Setup Reports</u><li><b>$root_cgi</b><li>This path must include <b>/mcart</b> </ul>",
'MVAR-BACK-HTTPs-WWW.YOURSITE.COM'=>
"<b>MVAR-BACK-HTTPs-WWW.YOURSITE.COM</b><br><li><font color=red>PATHS have no trailing slash</font><p>This is the <b>HTTPS</b> url (web address) leading to the <b>(SECURE)</b> Web root area. If you have your own SSL certificate for the site it is simply <b>HTTPS</b>.. www.YourSite.com. This <b>must</b> Match the Domain Name the SSL cert was issued to. Example- if the cert does not use the <b>www</b> this url should match. If you are using <b>Shared SSL</b> on the server then make this the base url the server folks say to use for (secure) to your site.  <ul><li><u>Setup Reports</u><li><b>$root_back</b></ul>",
'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR'=>
"<b>MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR</b><br><li><font color=red>PATHS have no trailing slash</font><p>This is the <b>HTTPS</b> url (web address) leading to the <br> <b>(SECURE)</b> <b> ../cgi-bin/mcart </b> directory. It is the root url where the <b>mofpay.cgi</b> - Back End script lives. <p> The best scenario is where the server uses the same (secure) root url for both <b>scripts</b> and <b>regular html pages</b>. Servers can do this (1) if you have your own site SSL certificate (2) Using <b>shared SSL</b> where both <b>scripts</b> and <b>regular html pages</b> are mapped to the same root filespace. It gets messy where a server maps shared SSL to different filespace for CGI & Regular Pages.<ul><li><u>Setup Reports</u><li><b>$mf</b></ul>",
'MVAR-BACK-PATH-WEB-ROOT'=>
"<b>MVAR-BACK-PATH-WEB-ROOT</b><br><li><font color=red>PATHS have no trailing slash</font><li>It is <b>not</b> an <b>HTTP</b> url<p>This is the <b>(SECURE)</b> sever <b>Absolute Path</b> (actual hard drive file path) leading to the <b>WEB</b> root filespace where the cart <b>BACK END TEMPLATES</b> live. Consult your server help section for running CGI scripts & absolute paths. <ul><li><u>Setup Reports</u><li><b>$ENV{'DOCUMENT_ROOT'}</b><li>Do not include <b> /mofcart </b> in this path.</ul>",
'MVAR-BACK-PATH-CGI-MCART-ROOT'=>
"<b>MVAR-BACK-PATH-CGI-MCART-ROOT</b><br><li><font color=red>PATHS have no trailing slash</font><li>It is <b>not</b> an <b>HTTP</b> url<p>This is the <b>(SECURE)</b> sever <b>Absolute Path</b> (actual hard drive file path) leading to the <b>mcart</b> script directory & <b>BACK END SCRIPT</b> <b>mofpay.cgi</b>. Script directories are usually assigned by the server, usually set up as <b>cgi-bin</b>. Consult your server help section for running CGI scripts & absolute paths. <ul><li><u>Setup Reports</u><li><b>$root_cgi</b><li>This path must include <b>/mcart</b> </ul>",
'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM'=>
'<b>MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM</b><p>The email address that receives notice an order has been placed. This is the <b>Merchant</b> Notice.',
'MVAR-ORDER-HELP-AT-YOURSITE.COM'=>
'<b>MVAR-ORDER-HELP-AT-YOURSITE.COM</b><p>The email address for help : listed on templates, and customer messages',
'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'=>
'<b>MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM</b><p>The email address of the ARES Affiliate System Admin.'
);

# sort order
# These are all the Vars needed in the pkg install for MOFcart v2.5
@mvarsort = (
	# these vars mark the save & next points, but don't appear as input
	'MVAR-SETTINGS',
	'MVAR-TESTING',
 	'MVAR-MAKEDIRS',
 	'MVAR-REPLACE',
 	'MVAR-FINISH',
	# end save & next points
	'MVAR-YOUR-CC-KEY',
	'MVAR-YOUR-CC-PSW',
	'MVAR-ADMIN-USR',
	'MVAR-ADMIN-PSWD',
	'MVAR-INVOICES-USR',
	'MVAR-INVOICES-PSWD',
	'MVAR-DOCS-USR',
	'MVAR-DOCS-PSWD',
	'MVAR-USER-USR',
	'MVAR-USER-PSWD',
	'MVAR-BUSINESS-NAME',
	'MVAR-BUSINESS-ADDRESS',
	'MVAR-BUSINESS-CITY-STATE-ZIP',
	'MVAR-BUSINESS-PHONE',
	'MVAR-BUSINESS-FAX',
	'MVAR-PHONE-HELP',
	'MVAR-DOMAIN-NAME.COM',
	'MVAR-STRICT-HTTP-WWW.YOURSITE.COM',
	'MVAR-STRICT-HTTP-WWW.YOUR-MCART-DIR',
	'MVAR-FRONT-HTTPs-WWW.YOURSITE.COM',
	'MVAR-FRONT-HTTPs-WWW.YOUR-MCART-DIR',
	'MVAR-FRONT-PATH-WEB-ROOT',
	'MVAR-FRONT-PATH-CGI-MCART-ROOT',
	'MVAR-BACK-HTTPs-WWW.YOURSITE.COM',
	'MVAR-BACK-HTTPs-WWW.YOUR-MCART-DIR',
	'MVAR-BACK-PATH-WEB-ROOT',
	'MVAR-BACK-PATH-CGI-MCART-ROOT',
	'MVAR-SEND-ORDERS-TO-AT-YOURSITE.COM',
	'MVAR-ORDER-HELP-AT-YOURSITE.COM',
	'MVAR-AFFILIATES-MAIL-AT-YOURSITE.COM'
	);

return ($header,$footer,$message,@mvarsort,%helpSys);
}




# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA http://www.merchantpal.com 2000-2003
