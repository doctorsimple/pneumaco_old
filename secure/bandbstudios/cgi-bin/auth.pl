#
#       ----------------------
#               DBMan
# 		----------------------
#		Database Administrator
#
#         File: auth.pl
#  Description: This file contains all the authorization routines.
#       Author: Alex Krohn
#          Web: http://www.gossamer-threads.com/
#      Version: 2.05
# CVS Revision: $Id: auth.pl,v 1.3 2000/07/08 18:14:40 alex Exp $
#
# COPYRIGHT NOTICE:
#
# Copyright 1997 Gossamer Threads Inc.  All Rights Reserved.
#
# This program is being distributed as shareware.  It may be used and
# modified free of charge for personal, academic, government or non-profit
# use, so long as this copyright notice and the header above remain intact.
# Any commercial use should be registered.  Please also send me an email,
# and let me know where you are using this script. By using this program 
# you agree to indemnify Gossamer Threads Inc. from any liability.
#
# Selling the code for this program without prior written consent is
# expressly forbidden.  Obtain permission before redistributing this
# program over the Internet or in any other medium.  In all cases
# copyright and header must remain intact.
#
# Please check the README file for full details on registration.
# =====================================================================

### Auth.pl

sub auth_check_password {
# --------------------------------------------------------
# This routine checks to see if the password and userid found
# in %in (must be 'pw' and 'userid') match a valid password and 
# userid in the password file.
# It returns a status message and a userid which is built by a
# 		"user name" + "random number"
# which get's stored in the query string.

	my ($pass, @passwd, $userid, $pw, @permissions, $file, $uid);
	my ($server_auth) = $ENV{'REMOTE_USER'} || $ENV{'AUTH_USER'};
	 
	if ($auth_no_authentication || (($db_uid eq 'default') && $auth_allow_default)) {		
		return ('ok', 'default', @auth_default_permissions);
	}
	elsif ($server_auth) {   # The user has logged in via server authentication.
		return ('ok', $server_auth, &auth_check_permissions($server_auth));
	}
	elsif ($in{'login'}) {		# The user is trying to login.
		open (PASSWD, "<$auth_pw_file") || &cgierr("unable to open password file. Reason: $!\n");
		my @passwds = <PASSWD>;			# Let's get the user id and passwords..
		close PASSWD;
		my ($view, $add, $mod, $del, $admin);
		PASS: foreach $pass (@passwds) {	# Go through each pass and see if we match..
			next PASS if ($pass =~ /^$/);	# Skip blank lines.
			next PASS if ($pass =~ /^#/);	# Skip Comment lines.
			chomp ($pass);
			($userid, $pw, $view, $add, $del, $mod, $admin) = split (/:/, $pass);
			#if (($in{'userid'} eq $userid) && (crypt($in{'pw'}, $pw) eq $pw)) {  ----this is the old version of the following line	
			if (($in{'userid'} eq $userid) && ($in{'pw'} eq $pw)) {		
				srand( time() ^ ($$ + ($$ << 15)) );				# Seed Random Number
				$db_uid = "$userid." . time() . (int(rand(100000)) + 1);# Build User Id
				open(AUTH, ">$auth_dir/$db_uid") or &cgierr("unable to open auth file: $auth_dir/$uid. Reason: $!\n");
					print AUTH "$uid: $ENV{'REMOTE_HOST'}\n";
				close AUTH;
				foreach (0 .. 3) { $permissions[$_] = int($permissions[$_]); }
				&auth_logging('logged on', $userid) if ($auth_logging);
				return ('ok', $db_uid, $view, $add, $del, $mod, $admin);
			}
		}
		return ("invalid username/password");
	}
	elsif ($db_uid) { # The user already has a user id given by the program.
		(-e "$auth_dir/$db_uid") ?
			return ('ok', $db_uid, &auth_check_permissions($db_uid)) :
			return ('invalid/expired user session');	
	}
	else {	# User has not logged on yet.
		return 'no login';
	}
}

sub auth_check_permissions {
# --------------------------------------------------------	
# This routine checks the permissions file and returns the users
# permissions. It takes as input a valid user id and returns
# a set of permissions.

	my ($userid) = shift;
	my ($username, @permissions, $permission, $name, $pw, $view, $add, $del, $mod, $admin);

# Use default permissions if there is no authentication, or if this is a 
# default user and we allow default users.
	if ($auth_no_authentication || (($userid eq 'default') && $auth_allow_default)) {
		return (@auth_default_permissions);
	}

# Otherwise, check to see if we have been passed in a user id to 
# get permissions for or we have one from server authentication.
	if ($ENV{'REMOTE_USER'} || $ENV{'AUTH_USER'}) {
		$username = $ENV{'REMOTE_USER'} || $ENV{'AUTH_USER'};
	}
	else {
		($userid =~ /^([A-Za-z0-9]+)\.\d+$/) ? ($username = $1) : return (0,0,0,0,0);
	}

# Get the permissions.
	open (PER, "<$auth_pw_file") or &cgierr("unable to open password file. Reason: $!");
		@permissions = <PER>;
	close PER;

	PER: foreach $permission (@permissions) {
		($permission =~ /^$/) and next PER;	# Skip blank lines.
		($permission =~ /^#/) and next PER;	# Skip Comment lines.	
		($name, $pw, $view, $add, $del, $mod, $admin) = split (/:/, $permission);			
		if ($username eq $name) {
			$view = int($view); $add = int($add); 	# We int everything just in case
			$del = int($del); $mod = int($mod); 	# someone has put spaces after the permssions.
			$admin = int($admin);
			return ($view, $add, $del, $mod, $admin);
		}
	}
	return (0,0,0,0,0);	# Can't find this user?
}

sub auth_logging {
# --------------------------------------------------------
# Logs an action to the database. Takes as input an action, and 
# optionally a user id. If no user id is passed in, it get's one from
# the global $db_userid.

	my ($action, $uid) = @_;
	my ($time) = &get_time;		# Change time/date format globally
	my ($date) = &get_date;		# in get_time and get_date.
	if (!$uid) {
		$db_userid ?
			($uid = $db_userid) :
			($uid = "UNKNOWN");	# Hopefully we shouldn't see this..
	}	
	open (LOG, ">>$auth_log_file") || &cgierr("unable to open log file: $auth_log_file. Reason: $!\n");
		flock (LOG, 2) unless (!$db_use_flock);
		print LOG "$uid $action at $time on $date from $ENV{'REMOTE_HOST'}\n";		
	close AUTH;		# releases file lock.
}


sub auth_cleanup {
# --------------------------------------------------------
# This routine cleans up the auth directory. It removes
# old user files that are older then a specified time.

	my (@files);
	
	opendir (AUTHDIR, "$auth_dir") || &cgierr("unable to open directory in auth_cleanup: $auth_dir. Reason: $!");
		@files = readdir(AUTHDIR);			# Read in list of files in directory..
	closedir (AUTHDIR);
	FILE: foreach $file (@files) {
		next if ($file =~ /^\./);			# Skip "." and ".." entries..
		next if ($file =~ /^index/);		# Skip index.htm type files..
		if ((stat("$auth_dir/$file"))[9] + $auth_time < time) {
			unlink ("$auth_dir/$file");		# Delete the file if it is too old.
		}
	}
}

1;	