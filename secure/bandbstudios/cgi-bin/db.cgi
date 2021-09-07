#!/usr/local/bin/perl 
# =====================================================================
#       ----------------------
#               DBMan
# 		----------------------
#		Database Administrator
#
#         File: db.cgi
#  Description: This is the main program file and contains all the functionality
#               of the database manager.
#       Author: Alex Krohn
#          Web: http://www.gossamer-threads.com/
#      Version: 2.05
# CVS Revision: $Id: db.cgi,v 1.6 2000/07/08 18:14:40 alex Exp $
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

# If you run into problems, set $db_script_path to the full path
# to your directory.
$db_script_path = "/home/bandbstu/public_html/cgi-bin";

# Load the form information and set the config file and userid.
local(%in) = &parse_form;
$in{'db'}  ? ($db_setup = $in{'db'}) : ($db_setup = 'default');
$in{'uid'} ? ($db_uid   = $in{'uid'}): ($db_uid   = '');

# Required Librariers
# --------------------------------------------------------
# Make sure we are using perl 5.003, load the config file, and load the auth file.
eval {
	unshift (@INC, $db_script_path);
	require 5.003;				# We need at least Perl 5.003
	unless ($db_setup =~ /^[A-Za-z0-9]+$/) { die "Invalid config file name: $db_setup"; }
	require "$db_setup.cfg";	# Database Definition File
	require "auth.pl";			# Authorization Routines
};
if ($@) { &cgierr ("Error loading required libraries.\nCheck that they exist, permissions are set correctly and that they compile.\nReason: $@"); }

# If we are using benchmarking, then we start a timer and stop it around &main. Then we print the difference.
if ($db_benchmark) { eval { require Benchmark; }; if ($@) { &cgierr ("Fatal Error Benchmark Module not installed: $@"); } $t0 = new Benchmark; }

eval { &main; };							# Trap any fatal errors so the program hopefully 
if ($@) { &cgierr("fatal error: $@"); }		# never produces that nasty 500 server error page.

# Stop the timer and print.
if ($db_benchmark) { $t1 = new Benchmark; print "<h6>Processing Time: " . timestr(timediff($t1, $t0)) . "</h6>"; }

# Display debugging information if requested.
&cgierr("Debug Information") if ($db_debug);

exit; 	# There are only two exit calls in the script, here and in in &cgierr. 

sub main {
# --------------------------------------------------------
	my ($status, $uid);
	local($per_add, $per_view, $per_mod, $per_del, $per_admin);	

	$|++;		# Flush Output Right Away

	&auth_cleanup unless ($auth_no_authentication);	 # Remove old session files.

	($status, $uid, $per_view, $per_add, $per_del, $per_mod, $per_admin) 
			= &auth_check_password;	     # Authenticate User, get permissions and userid.

	if ($status eq "ok") {
# Set the script link URL with db and user info for links. Use $db_script_url for forms.
		$db_script_link_url = "$db_script_url?db=$db_setup&uid=$db_uid";
		if ($uid eq "default") { $db_userid = $uid; }
		else { ($db_userid) = $db_uid =~ /([A-Za-z0-9]+)\.\d+/; }		
					
# Main Menu. Check to see what the user requested, then, if he has permission for that
# request, do it. Otherwise send the user off to an unauthorized request page.
		if    ($in{'add_form'})				{ if ($per_add) { &html_add_form; } 		  else { &html_unauth; } }
		elsif ($in{'add_record'})			{ if ($per_add) { &add_record; } 			  else { &html_unauth; } }
		elsif ($in{'view_search'})			{ if ($per_view) { &html_view_search; } 	  else { &html_unauth; } }
		elsif ($in{'view_records'})			{ if ($per_view) { &view_records; } 		  else { &html_unauth; } } 
		elsif ($in{'delete_search'})		{ if ($per_del) { &html_delete_search; } 	  else { &html_unauth; } }  
		elsif ($in{'delete_form'})			{ if ($per_del) { &html_delete_form; }		  else { &html_unauth; } }  
		elsif ($in{'delete_records'})		{ if ($per_del) { &delete_records; } 		  else { &html_unauth; } }  
		elsif ($in{'modify_search'})		{ if ($per_mod) { &html_modify_search; } 	  else { &html_unauth; } }  
		elsif ($in{'modify_form'})			{ if ($per_mod) { &html_modify_form; }		  else { &html_unauth; } }  
		elsif ($in{'modify_form_record'})	{ if ($per_mod) { &html_modify_form_record; } else { &html_unauth; } }  
		elsif ($in{'modify_record'})		{ if ($per_mod) { &modify_record;  } 		  else { &html_unauth; } }
		elsif ($in{'admin_display'})		{ if ($per_admin) { &admin_display; }		  else { &html_unauth; } }
		elsif ($in{'logoff'})				{ &auth_logging('logged off') if ($auth_logging);
                                              (-e "$auth_dir/$db_uid") and ($db_uid =~ /^[\A-Za-z0-9]+\.\d+$/) and unlink ("$auth_dir/$db_uid");
                                              $auth_logoff ? (print "Location: $auth_logoff\n\n") : (print "Location: $db_script_url\n\n");
                                            }
		elsif ((keys(%in) <= 2) || 
				($in{'login'}))				{ &html_home; }
		else 								{ &html_unkown_action; }		
	}
# If we allow users to signup, and they want to, go to the signup form.	
	elsif ($auth_signup and $in{'signup_form'}) {
		&html_signup_form; 
	}
	elsif ($auth_signup and $in{'signup'}) {
		&signup; 
	}
# Auth Check Password has determined that the user has not logged in, so let's send
# him to the login screen.
	elsif ($status eq "no login") {
		&html_login_form;
	}
# Auth Check Password had an error trying to authenticate the user. Probably there was
# an invalid user/password or the user file has expired. Let's go to an error page and
# ask the user to re log on.
	else {
		&html_login_failure($status);
	}
}

sub add_record {
# --------------------------------------------------------
# Adds a record to the database. First, validate_record is called
# to make sure the record is ok to add. If it is, then the record is
# encoded and added to the database and the user is sent to 
# html_add_success, otherwise the user is sent to html_add_failure with
# an error message explaining why. The counter file is also updated to the
# next number.

	my ($output, $status, $counter);
# Set the userid to the logged in user.
	($auth_user_field >= 0) and ($in{$db_cols[$auth_user_field]} = $db_userid);
	
# First we validate the record to make sure the addition is ok.	
	$status = &validate_record;

# We keep checking for the next available key, or until we've tried 50 times
# after which we give up.
	while ($status eq "duplicate key error" and $db_key_track) {
		return "duplicate key error" if ($counter++ > 50);
		$in{$db_key}++;
		$status = &validate_record;
	}

	if ($status eq "ok") {
		open (DB, ">>$db_file_name") or &cgierr("error in add_record. unable to open database: $db_file_name.\nReason: $!");
			if ($db_use_flock) {
				flock(DB, 2)  or &cgierr("unable to get exclusive lock on $db_file_name.\nReason: $!");
			}
			print DB &join_encode(%in);	
		close DB;		# automatically removes file lock
		if ($db_key_track) {
			open (ID, ">$db_id_file_name") or &cgierr("error in get_defaults. unable to open id file: $db_id_file_name.\nReason: $!");
				if ($db_use_flock) {
					flock(ID, 2)  or &cgierr("unable to get exclusive lock on $db_id_file_name.\nReason: $!");
				}
				print ID $in{$db_key};		# update counter.
			close ID;		# automatically removes file lock
		}
		&auth_logging("added record: $in{$db_key}") if ($auth_logging);
		&html_add_success;
	}
	else {
		&html_add_failure($status);
	}
}

sub delete_records {
# --------------------------------------------------------
# Deletes a single or multiple records. First the routine goes thrrough
# the form input and makes sure there are some records to delete. It then goes
# through the database deleting each entry and marking it deleted. If there
# are any keys not deleted, an error message will be returned saying which keys
# were not found and not deleted, otherwise the user will go to the success page.

	my ($key, %delete_list, $rec_to_delete, @lines, $line, @data, $errstr, $succstr, $output, $restricted);
	$rec_to_delete = 0;
	foreach $key (keys %in) {				# Build a hash of keys to delete.
		if ($in{$key} eq "delete") {
			$delete_list{$key} = 1;
			$rec_to_delete = 1;
		}
	}
	if (!$rec_to_delete) {
		&html_delete_failure("no records specified.");
		return;
	}

	open (DB, "<$db_file_name") or &cgierr("error in delete_records. unable to open db file: $db_file_name.\nReason: $!");
		if ($db_use_flock) { flock(DB, 1); }
		@lines = <DB>;
	close DB;

	($restricted = 1) if ($auth_modify_own and !$per_admin);
	
	LINE: foreach $line (@lines) {
		if ($line =~ /^$/) { next LINE; }
		if ($line =~ /^#/) { $output .= $line; next LINE; }
		chomp ($line);			
		@data     = &split_decode($line);
		($output .= "$line\n" and next LINE) if ($restricted and ($db_userid ne $data[$auth_user_field]));
		
		$delete_list{$data[$db_key_pos]} ? 			    # if this id is one we want to delete
			($delete_list{$data[$db_key_pos]} = 0) : 	# then mark it deleted and don't print it to the new database.
			($output .= $line . "\n");					# otherwise print it.
	}
	
	foreach $key (keys %delete_list) {
		$delete_list{$key} ?				# Check to see if any items weren't deleted
			($errstr .= "$key,") :			# that should have been.
			($succstr .= "$key,"); 			# For logging, we'll remember the one's we deleted.
	}
	chop($succstr);		# Remove trailing delimeter
	chop($errstr);		# Remove trailing delimeter

	open (DB, ">$db_file_name") or &cgierr("error in delete_records. unable to open db file: $db_file_name.\nReason: $!");
		if ($db_use_flock) {
			flock(DB, 2) or &cgierr("unable to get exclusive lock on $db_file_name.\nReason: $!");
		}
		print DB $output;
	close DB;		# automatically removes file lock			

	&auth_logging("deleted records: $succstr") if ($auth_logging);
	$errstr ?								# Do we have an error?
		&html_delete_failure($errstr) :		# If so, then let's report go to the failure page,
		&html_delete_success($succstr);		# else, everything went fine.
}	

sub modify_record {
# --------------------------------------------------------
# This routine does the actual modification of a record. It expects
# to find in %in a record that is already in the database, and will
# rewrite the database with the new entry. First it checks to make
# sure that the modified record is ok with validate record.
# It then goes through the database looking for the right record to
# modify, if found, it prints out the modified record, and returns
# the user to a success page. Otherwise the user is returned to an error
# page with a reason why.

	my ($status, $line, @lines, @data, $output, $found, $restricted);
	
	$status = &validate_record;		# Check to make sure the modifications are ok!

	if ($status eq "ok") {
		open (DB, "<$db_file_name") or &cgierr("error in modify_records. unable to open db file: $db_file_name.\nReason: $!");
			if ($db_use_flock) { flock(DB, 1); }
			@lines = <DB>;	# Slurp the database into @lines..
		close DB;

		($restricted = 1) if ($auth_modify_own and !$per_admin);

		$found = 0;		# Make sure the record is in here!
		LINE: foreach $line (@lines) {
			if ($line =~ /^$/) { next LINE; }					# Skip and Remove blank lines
			if ($line =~ /^#/) { $output .= $line; next LINE; }	# Comment Line
			chomp ($line);			
			@data     = &split_decode($line);
			($output .= "$line\n" and next LINE) if ($restricted and ($db_userid ne $data[$auth_user_field]));
			
			if ($data[$db_key_pos] eq $in{$db_key}) {
# If we have userid's and this is not an admin, then we force the record to keep it's own
# userid.
				if ($auth_user_field >= 0 and (!$per_admin or !$in{$db_cols[$auth_user_field]})) {
					$in{$db_cols[$auth_user_field]} = $data[$auth_user_field];  
				}
				$output .= &join_encode(%in);			
				$found = 1;								
			}
			else {
				$output .= $line . "\n";				# else print regular line.
			}
		}
		if ($found) {
			open (DB, ">$db_file_name") or &cgierr("error in modify_records. unable to open db file: $db_file_name.\nReason: $!");
				if ($db_use_flock) {
					flock(DB, 2)  or &cgierr("unable to get exclusive lock on $db_file_name.\nReason: $!");
				}
				print DB $output;				
			close DB;			# automatically removes file lock

			&auth_logging("modified record: $in{$db_key}") if ($auth_logging);
			&html_modify_success;
		}
		else {
			&html_modify_failure("$in{$db_key} (can't find requested record)");
		}
	}
	else {
		&html_modify_failure($status);		# Validation Error
	}
}

sub view_records {
# --------------------------------------------------------
# This is called when a user is searching the database for 
# viewing. All the work is done in query() and the routines just
# checks to see if the search was successful or not and returns
# the user to the appropriate page.

	my ($status, @hits) = &query("view");
	if ($status eq "ok") {
		&html_view_success(@hits);
	}
	else {
		&html_view_failure($status);
	}
}

sub query {
# --------------------------------------------------------
# First let's get a list of database fields we want to search on and 
# store it in @search_fields

	my ($i, $column, @search_fields, @search_gt_fields, @search_lt_fields, $maxhits, $numhits, $nh,
	    $field, @regexp, $line, @values, $key_match, @hits, @sortedhits, $next_url, $next_hit, $prev_hit,
		$first, $last, $upper, $lower, $left, $right, $restricted);	
	local (%sortby);
	
# First thing we do is find out what we are searching for. We build a list of fields
# we want to search on in @search_fields.
	if ($in{'keyword'}) {		# If this is a keyword search, we are searching the same
		$i = 0; 				# thing in all fields. Make sure "match any" option is 
		$in{'ma'} = "on";		# on, otherwise this will almost always fail.
		foreach $column (@db_cols) {		
			if (($db_sort{$column} eq 'date') or &date_to_unix($in{'keyword'})) { $i++; next; }
			if ($i == $auth_user_field) { $i++; next; }
			push (@search_fields, $i);		# Search every column			
			$in{$column} = $in{'keyword'};	# Fill %in with keyword we are looking for.
			$i++;
		}
	}
	else {						# Otherwise this is a regular search, and we only want records
		$i = 0;					# that match everything the user specified for.		
		foreach $column (@db_cols) {
			if ($in{$column}   =~ /^\>(.+)$/) { ($db_sort{$column} eq 'date') and (&date_to_unix($1) or return "Invalid date format: '$1'");
												push (@search_gt_fields, $i); $in{"$column-gt"} = $1; $i++; next; }
			if ($in{$column}   =~ /^\<(.+)$/) { ($db_sort{$column} eq 'date') and (&date_to_unix($1) or return "Invalid date format: '$1'");
												push (@search_lt_fields, $i); $in{"$column-lt"} = $1; $i++; next; }
			if ($in{$column}      !~ /^\s*$/) { ($db_sort{$column} eq 'date') and (&date_to_unix($in{$column}) or return "Invalid date format: '$in{$column}'");
												push(@search_fields, $i); $i++; next; }
			if ($in{"$column-gt"} !~ /^\s*$/) { ($db_sort{$column} eq 'date') and (&date_to_unix($in{"$column-gt"}) or return "Invalid date format: '$in{$column}'");
												push(@search_gt_fields, $i); }
			if ($in{"$column-lt"} !~ /^\s*$/) { ($db_sort{$column} eq 'date') and (&date_to_unix($in{"$column-lt"}) or return "Invalid date format: '$in{$column}'");
												push(@search_lt_fields, $i); }
			$i++;
		}
	}
# If we don't have anything to search on, let's complain.
	if (!@search_fields and !@search_gt_fields and !@search_lt_fields) {
		return "no search terms specified";
	}
	
# Define the maximum number of hits we will allow, and the next hit counter.	
	$in{'mh'} ?	($maxhits = $in{'mh'}) : ($maxhits = $db_max_hits);
	$in{'nh'} ? ($nh      = $in{'nh'}) : ($nh      = 1);
	$numhits = 0;

# Let's set restricted to 1 if the user can only view/mod their own and
# this isn't an admin.
	($restricted = 1) if ($_[0] eq "view" and $auth_view_own and !$per_admin);
	($restricted = 1) if ($_[0] eq "mod"  and $auth_modify_own and !$per_admin);

# Now let's build up all the regexpressions we will use. This saves the program
# from having to recompile the same regular expression every time.
    foreach $field (@search_fields) {
		my $tmpreg = "$in{$db_cols[$field]}";
		(!$in{'re'}) and ($tmpreg = "\Q$tmpreg\E");
		($in{'ww'})  and ($tmpreg = "\\b$tmpreg\\b");
		(!$in{'cs'}) and ($tmpreg = "(?i)$tmpreg");
		($in{$db_cols[$field]} eq "*") and ($tmpreg = ".*");	# A "*" matches anything.
		$regexp_func[$field] = eval 'sub { m/$tmpreg/o; }';
		$regexp_bold[$field] = $tmpreg;
	}

# Now we go through the database and do the actual searching.	
# First figure out which records we want:
	$first = ($maxhits * ($nh - 1));
	$last  =  $first + $maxhits - 1;
	
	open (DB, "<$db_file_name") or &cgierr("error in search. unable to open database: $db_file_name.\nReason: $!");
	if ($db_use_flock) { flock(DB, 1); }	
	LINE: while (<DB>) {
		(/^#/)      and next LINE;		# Skip comment Lines.
		(/^\s*$/)   and next LINE;		# Skip blank lines.
		$line = $_;	chomp ($line);		# Remove trailing new line.
		@values = &split_decode($line);

# If we are only allowed to view/mod our own record, then let's check here.
		next LINE if ($restricted and ($db_userid ne $values[$auth_user_field]));
		
# Normal searches.		
		$key_match = 0;
		foreach $field (@search_fields) {
			$_ = $values[$field];	# Reg function works on $_.
			$in{'ma'} ?
				($key_match = ($key_match or &{$regexp_func[$field]})) :
			    (&{$regexp_func[$field]} or next LINE);
		}
# Greater then searches.
		foreach $field (@search_gt_fields) {		
			$term = $in{"$db_cols[$field]-gt"};						
			if ($db_sort{$db_cols[$field]} eq "date") {
				$in{'ma'} ?
					($key_match = ($key_match or (&date_to_unix($values[$field])) > &date_to_unix($term))) :
					(&date_to_unix($values[$field]) > (&date_to_unix($term)) or next LINE);
			}
			elsif ($db_sort{$db_cols[$field]} eq 'alpha') {
				$in{'ma'} ?
					($key_match = ($key_match or ($values[$field] > $term))) :
					((lc($values[$field]) gt lc($term)) or next LINE);			
			}
			else {			
				$in{'ma'} ?
					($key_match = ($key_match or ($values[$field] > $term))) :
					(($values[$field] > $term) or next LINE);
			}
		}
# Less then searches.
		foreach $field (@search_lt_fields) {
			$term = $in{"$db_cols[$field]-lt"};
			if ($db_sort{$db_cols[$field]} eq "date") {
				$in{'ma'} ?
					($key_match = ($key_match or (&date_to_unix($values[$field]) < &date_to_unix($term)))) :
					(&date_to_unix($values[$field]) < (&date_to_unix($term)) or next LINE);
			}
			elsif ($db_sort{$db_cols[$field]} eq 'alpha') {
				$in{'ma'} ?
					($key_match = ($key_match or ($values[$field] < $term))) :
					((lc($values[$field]) lt lc($term)) or next LINE);			
			}
			else {
				$in{'ma'} ?
					($key_match = ($key_match or ($values[$field] < $term))) :
					(($values[$field] < $term) or next LINE);
			}
		}
# Did we find a match? We only add the hit to the @hits array if we need it. We can
# skip it if we are not sorting and it's not in our first < > last range.
		if ($key_match || (!($in{'keyword'}) && !($in{'ma'}))) {			
			if (exists $in{'sb'}) {
				$sortby{(($#hits+1) / ($#db_cols+1))} = $values[$in{'sb'}];				
				push (@hits, @values); 
			}
			else {
				(($numhits >= $first) and ($numhits <= $last)) and push (@hits, @values);
			}
			$numhits++;		# But we always count it!
		}
	}
	close DB;
	
# Now we've stored all our hits in @hits, and we've got a sorting values stored
# in %sortby indexed by their position in @hits.
	$numhits ? ($db_total_hits = $numhits) : ($db_total_hits = 0);
	($db_total_hits == 0) and return ("no matching records.");

# Sort the array @hits in order if we are meant to sort.
	if (exists $in{'sb'}) {	# Sort hits on $in{'sb'} field.
		my ($sort_order, $sort_func);
		$in{'so'} ? ($sort_order = $in{'so'}) : ($sort_order = "ascend");
		$sort_func = "$db_sort{$db_cols[$in{'sb'}]}_$sort_order";		
		
		foreach $hit (sort $sort_func (keys %sortby)) {
			$first = ($hit * $#db_cols) + $hit; $last = ($hit * $#db_cols) + $#db_cols + $hit;			
			push (@sortedhits, @hits[$first .. $last]);
		}
		@hits = @sortedhits;
	}	

# If we have to many hits, let's build the next toolbar, and return only the hits we want.
	if ($numhits > $maxhits) {	
# Remove the nh= from the query string.		
		$next_url = $ENV{'QUERY_STRING'};
		$next_url =~ s/\&nh=\d+//;
		$next_hit = $nh + 1; $prev_hit = $nh - 1;

# Build the next hits toolbar. It seems really complicated as we have to do
# some number crunching to keep track of where we are on the toolbar, and so
# that the toolbar stays centred.		

# First, set how many pages we have on the left and the right.
		$left  = $nh; $right = int($numhits/$maxhits) - $nh;		
# Then work out what page number we can go above and below.		
		($left > 7)  ? ($lower = $left - 7) : ($lower = 1);
		($right > 7) ? ($upper = $nh + 7)   : ($upper = int($numhits/$maxhits) + 1);
# Finally, adjust those page numbers if we are near an endpoint.		
		(7 - $nh >= 0) and ($upper = $upper + (8 - $nh));
		($nh > ($numhits/$maxhits - 7)) and ($lower = $lower - ($nh - int($numhits/$maxhits - 7) - 1));
		$db_next_hits = "";

# Then let's go through the pages and build the HTML.		
		($nh > 1) and ($db_next_hits .= qq~<a href="$db_script_url?$next_url&nh=$prev_hit">[<<]</a> ~);
		for ($i = 1; $i <= int($numhits/$maxhits) + 1; $i++) {
			if ($i < $lower) { $db_next_hits .= " ... "; $i = ($lower-1); next; }			
			if ($i > $upper) { $db_next_hits .= " ... "; last; }
			($i == $nh) ?
				($db_next_hits .= qq~$i ~) :
				($db_next_hits .= qq~<a href="$db_script_url?$next_url&nh=$i">$i</a> ~);
			if (($i * $maxhits) >= $numhits) { last; }  # Special case if we hit exact.
		}
		$db_next_hits .= qq~<a href="$db_script_url?$next_url&nh=$next_hit">[>>]</a> ~ unless ($nh == $i);
		
# Slice the @hits to only return the ones we want, only have to do this if the results are sorted.
		if (exists $in{'sb'}) {			
			$first = ($maxhits * ($nh - 1)) * ($#db_cols+1);
			$last  =  $first + (($#db_cols+1) * $maxhits) - 1;		
			$last = $#hits if ($last > $#hits);
			@hits = @hits[$first .. $last];
		}
	}
	
# Bold the results 
	if ($db_bold and $in{'view_records'}) {
		for $i (0 .. (($#hits+1) / ($#db_cols+1)) - 1) {
			$offset = $i * ($#db_cols+1);
			foreach $field (@search_fields) {				
				$hits[$field + $offset] =~ s,(<[^>]+>)|($regexp_bold[$field]),defined($1) ? $1 : "<B>$2</B>",ge;
			}
		}
	}
	return ("ok", @hits);
}

sub admin_display {
# --------------------------------------------------------
# Let's an admin add/update/remove users from the authorization file.
#	
	my ($message, @lines, $line);
	
# Do we have anything to do?
	CASE: {
# If we've been passed in new_username, then we are adding a new user. Do
# some basic error checking and then add him into the password file.
		$in{'new_username'}		and do {
				unless ((length($in{'new_username'}) >= 3) and (length($in{'new_username'}) <= 12) and ($in{'new_username'} =~ /^[a-zA-Z0-9]+$/)) {
					$message = "Invalid username: $in{'new_username'}. Must only contain letters and numbers and be less then 12 and greater then 3 characters.";
					last CASE;
				}
				unless ((length($in{'password'}) >= 3) and (length($in{'password'}) <= 12)) {
					$message = "Invalid password: '$in{'password'}'. Must be less then 12 and greater then 3 characters.";
					last CASE;
				}
				open (PASS, ">>$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
					if ($db_use_flock) {
						flock(PASS, 2)  or &cgierr("unable to get exclusive lock on $auth_pw_file.\nReason: $!");
					}
				    my @salt_chars = ('A' .. 'Z', 0 .. 9, 'a' .. 'z', '.', '/');
					my $salt = join '', @salt_chars[rand 64, rand 64];
					my $encrypted = crypt($in{'password'}, $salt);			
					print PASS "$in{'new_username'}:$encrypted:$in{'per_view'}:$in{'per_add'}:$in{'per_del'}:$in{'per_mod'}:$in{'per_admin'}\n";
				close PASS;
				$message = "User: $in{'new_username'} created.";
				last CASE;
			};
# If we've been passed in delete, then we are removing a user. Check
# to make sure a user was selected then try and remove him.
		$in{'delete'}		and do {
				unless ($in{'username'}) {
					$message = "No username selected to delete.";
					last CASE;
				}
				open (PASS, "<$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
				if ($db_use_flock) { flock(PASS, 1)	}				
				@lines = <PASS>;
				close PASS;
				
				open (PASS, ">$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
				if ($db_use_flock) {
					flock(PASS, 2)  or &cgierr("unable to get exclusive lock on $auth_pw_file.\nReason: $!");
				}
				my $found = 0;
				foreach $line (@lines) {
					($line =~ /^$in{'username'}:/) ?
						($found = 1) :
						print PASS $line;
				}
				close PASS;
				$found ?
					($message = "User: $in{'username'} deleted.") :
					($message = "Unable to find userid: $in{'username'} in password file.");
				last CASE;
			};
# If we have a username, and the admin didn't press inquire, then
# we are updating a user. 
		($in{'username'} && !$in{'inquire'}) and do {
				open (PASS, "<$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
				if ($db_use_flock) { flock(PASS, 1); }				
				@lines = <PASS>;
				close PASS;
				
				open (PASS, ">$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
				if ($db_use_flock) {
					flock(PASS, 2)  or &cgierr("unable to get exclusive lock on $auth_pw_file.\nReason: $!");
				}
				my $found = 0;
				foreach $line (@lines) {
					if ($line =~ /^$in{'username'}:/) {
						my $password = (split (/:/, $line))[1];
						unless ($password eq $in{'password'}) {
						    my @salt_chars = ('A' .. 'Z', 0 .. 9, 'a' .. 'z', '.', '/');
							my $salt = join '', @salt_chars[rand 64, rand 64];
							$password = crypt($in{'password'}, $salt);
						}
						print PASS "$in{'username'}:$password:$in{'per_view'}:$in{'per_add'}:$in{'per_del'}:$in{'per_mod'}:$in{'per_admin'}\n";
						$found = 1;
					}
					else {
						print PASS $line;
					}
				}
				$in{'inquire'} = $in{'username'};
				$found ?
					($message = "User: $in{'username'} updated.") :
					($message = "Unable to find user: '$in{'username'}' in the password file.");
				last CASE;
			};
	};

# Now let's load the list of users.	
	open (PASS, "<$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
	if ($db_use_flock) { flock(PASS, 1); }	
	@lines = <PASS>;
	close PASS;

# If we are inquiring, let's look for the specified user.
	my (@data, $user_list, $perm, $password);

	$user_list = qq~<select name="username"><option> </option>~;
	LINE: foreach $line (@lines) {
		$line =~ /^#/    and next LINE;
		$line =~ /^\s*$/ and next LINE;
		chomp $line;
		@data = split (/:/, $line);
		
		if ($in{'inquire'} and ($in{'username'} eq $data[0])) {
			$user_list .= qq~<option value="$data[0]" SELECTED>$data[0]</option>\n~;
			$perm = qq|
			  View <input type=checkbox name="per_view" value="1"     |; ($data[2] and $perm .= "CHECKED"); $perm .= qq|> 
		      Add <input type=checkbox name="per_add" value="1"       |; ($data[3] and $perm .= "CHECKED"); $perm .= qq|> 
			  Delete <input type=checkbox name="per_del" value="1"    |; ($data[4] and $perm .= "CHECKED"); $perm .= qq|> 
			  Modify <input type=checkbox name="per_mod" value="1" 	  |; ($data[5] and $perm .= "CHECKED"); $perm .= qq|>
			  Admin <input type=checkbox name="per_admin" value="1"   |; ($data[6] and $perm .= "CHECKED"); $perm .= qq|>|;
			$password = $data[1];
		}
		else {
			$user_list .= qq~<option value="$data[0]">$data[0]</option>\n~;	
		}
	}
	$user_list .= "</select>";
# Build the permissions list if we haven't inquired in someone.
	if (!$perm) {
		$perm = qq|
		  View <input type=checkbox name="per_view" value="1"     |; ($auth_default_perm[0] and $perm .= "CHECKED"); $perm .= qq|> 
	      Add <input type=checkbox name="per_add" value="1"       |; ($auth_default_perm[1] and $perm .= "CHECKED"); $perm .= qq|> 
		  Delete <input type=checkbox name="per_del" value="1"    |; ($auth_default_perm[2] and $perm .= "CHECKED"); $perm .= qq|> 
		  Modify <input type=checkbox name="per_mod" value="1" 	  |; ($auth_default_perm[3] and $perm .= "CHECKED"); $perm .= qq|>
		  Admin <input type=checkbox name="per_admin" value="1"   |; ($auth_default_perm[4] and $perm .= "CHECKED"); $perm .= qq|>|;
	}			  
	&html_admin_display ($message, $user_list, $password, $perm);
}

sub signup {
# --------------------------------------------------------
# Allows a user to sign up without admin approval. Must have $auth_signup = 1
# set. The user gets @default_permissions.
#
	my $message;

# Check to make sure userid is ok, pw ok, and userid is unique.	
	unless ((length($in{'userid'}) >= 3) and (length($in{'userid'}) <= 12) and ($in{'userid'} =~ /^[a-zA-Z0-9]+$/)) {
		$message = "Invalid userid: $in{'userid'}. Must only contain only letters and be less then 12 and greater then 3 characters.";
	}
	unless ((length($in{'pw'}) >= 3) and (length($in{'pw'}) <= 12)) {
		$message = "Invalid pw: '$in{'pw'}'. Must be less then 12 and greater then 3 characters.";
	}
	open (PASS, "<$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
	if ($db_use_flock) { flock(PASS, 1); }
	while (<PASS>) {
		/^\Q$in{'userid'}\E:/ and ($message = "userid already exists. Please try another.");
	}
	close PASS;	
	if ($message) {
		&html_signup_form ($message);
		return;
	}

# Add the userid into the file with default permissions.	
	open (PASS, ">>$auth_pw_file") or &cgierr ("unable to open: $auth_pw_file.\nReason: $!");
	if ($db_use_flock) {
		flock(PASS, 2)  or &cgierr("unable to get exclusive lock on $auth_pw_file.\nReason: $!");
	}
	srand( time() ^ ($$ + ($$ << 15)) );	# Seed Random Number
    my @salt_chars  = ('A' .. 'Z', 0 .. 9, 'a' .. 'z', '.', '/');
	my $salt        = join '', @salt_chars[rand 64, rand 64];
	my $encrypted   = crypt($in{'pw'}, $salt);			
	my $permissions = join (":", @auth_signup_permissions);
	
	print PASS "$in{'userid'}:$encrypted:$permissions\n";
	close PASS;
	
	&html_signup_success;
}

sub get_record {
# --------------------------------------------------------
# Given an ID as input, get_record returns a hash of the 
# requested record or undefined if not found.

	my ($key, $found, $line, @data, $field, $restricted);
	$key = $_[0];	
	$found = 0;
	($restricted = 1) if ($auth_modify_own and !$per_admin);

	open (DB, "<$db_file_name") or &cgierr("error in get_records. unable to open db file: $db_file_name.\nReason: $!");
	if ($db_use_flock) { flock(DB, 1); }	
	LINE: while (<DB>) {
		(/^#/)      and next LINE;
		(/^\s*$/)   and next LINE;
		$line = $_;	chomp ($line);		
		@data = &split_decode($line);
		next LINE if ($restricted and ($db_userid ne $data[$auth_user_field]));
		if ($data[$db_key_pos] eq $key) {
			$found = 1;
			for ($i = 0; $i <= $#db_cols; $i++) {  # Map the array columns to a hash.
				$rec{$db_cols[$i]} = $data[$i];
			}
			last LINE;
		}
	}
	close DB;	
	$found ?
		(return %rec) :
		(return undef);
}

sub get_defaults {
# --------------------------------------------------------
# Returns a hash of the defaults used for a new record.

	my (%default);

	foreach $field (keys %db_defaults) {
		$default{$field} =  $db_defaults{$field};
	}
	
	if ($db_key_track) {
		open (ID, "<$db_id_file_name") or &cgierr("error in get_defaults. unable to open id file: $db_id_file_name.\nReason: $!");
		if ($db_use_flock) { flock(ID, 1);	}	
		$default{$db_key} = <ID> + 1;	# Get next ID number
		close ID;
	}
	return %default;
}


sub validate_record {
# --------------------------------------------------------
# Verifies that the information passed through the form and stored
# in %in matches a valid record. It checks first to see that if 
# we are adding, that a duplicate ID key does not exist. It then
# checks to see that fields specified as not null are indeed not null,
# finally it checks against the reg expression given in the database
# definition.

	my ($col, @input_err, $errstr, $err, $line, @lines, @data);	

	if ($in{'add_record'}) 	{		# don't need to worry about duplicate key if modifying	
		open (DB, "<$db_file_name") or &cgierr("error in validate_records. unable to open db file: $db_file_name.\nReason: $!");		
		if ($db_use_flock) { flock(DB, 1); }		
		LINE: while (<DB>) {
			(/^#/)      and next LINE;
			(/^\s*$/)   and next LINE;
			$line = $_;	chomp ($line);
			@data = &split_decode($line);	
			if ($data[$db_key_pos] eq $in{$db_key}) {
				return "duplicate key error";
			}
		}
		close DB;
	}	
	foreach $col (@db_cols) {
		if ($in{$col} =~ /^\s*$/) {				# entry is null or only whitespace
			($db_not_null{$col}) and			# entry is not allowed to be null.
				push(@input_err, "$col (Can not be left blank)");  # so let's add it as an error
		}
		else {									# else entry is not null.
			($db_valid_types{$col} && !($in{$col} =~ /$db_valid_types{$col}/)) and
				push(@input_err, "$col (Invalid format)");	# but has failed validation.
            (length($in{$col}) > $db_lengths{$col}) and
                push (@input_err, "$col (Too long. Max length: $db_lengths{$col})");
            if ($db_sort{$col} eq "date") {		
                push (@input_err, "$col (Invalid date format)") unless &date_to_unix($in{$col});
            }
		}
	}	
	if ($#input_err+1 > 0) {					# since there are errors, let's build
		foreach $err (@input_err) {				# a string listing the errors
			$errstr .= "<li>$err";				# and return it.
		}
		return "<ul>$errstr</ul>";
	}
	else {
		return "ok";							# no errors, return ok.
	}
}

sub join_encode {
# --------------------------------------------------------
# Takes a hash (ususally from the form input) and builds one 
# line to output into the database. It changes all occurrences
# of the database delimeter to '~~' and all newline chars to '``'.

	my (%hash) = @_;
	my ($tmp, $col, $output);	

	foreach $col (@db_cols) {				
		$tmp = $hash{$col};
		$tmp =~ s/^\s+//g;				# Trim leading blanks...
		$tmp =~ s/\s+$//g;				# Trim trailing blanks...
		$tmp =~ s/\Q$db_delim\E/~~/og;	# Change delimeter to ~~ symbol.
		$tmp =~ s/\n/``/g;				# Change newline to `` symbol.
		$tmp =~ s/\r//g;				# Remove Windows linefeed character.
		$output .= $tmp . $db_delim;	# Build Output.
	}
	chop $output;		# remove extra delimeter.
	$output .= "\n";	# add linefeed char.
	return $output;
}

sub split_decode {
# --------------------------------------------------------
# Takes one line of the database as input and returns an
# array of all the values. It replaces special mark up that 
# join_encode makes such as replacing the '``' symbol with a 
# newline and the '~~' symbol with a database delimeter.

	my ($input) = shift;
	$input =~ s/\Q$db_delim\E$/$db_delim /o; # Add a space if we have delimiter new line.
	my (@array) = split (/\Q$db_delim\E/o, $input);
	for ($i = 0; $i <= $#array; $i++) {
		$array[$i] =~ s/~~/$db_delim/og;	# Retrieve Delimiter..
		$array[$i] =~ s/``/\n/g;			# Change '' back to newlines..
	}	
	return @array;
}

sub build_select_field {
# --------------------------------------------------------
# Builds a SELECT field based on information found
# in the database definition. Parameters are the column to build
# and a default value (optional).

	my ($column, $value) = @_;	
	my (@fields, $ouptut);

	@fields = split (/\,/, $db_select_fields{$column});
	if ($#fields == -1) {
		$output = "error building select field: no select fields specified in config for field '$column'!";
	}
	else {
		$output = qq|<SELECT NAME="$column"><OPTION>---|;
		foreach $field (@fields) {
			$field eq $value ?
				($output .= "<OPTION SELECTED>$field\n") :
				($output .= "<OPTION>$field");
		}
		$output .= "</SELECT>";
	}
	return $output;
}

sub build_select_field_from_db {
# --------------------------------------------------------
# Builds a SELECT field from the database. 

	my ($column, $value, $name) = @_;
	my (@fields, $field, @selectfields, @lines, $line, $ouptut);
	my ($fieldnum, $found, $i) = 0;
	
	$name || ($name = $column);
	
	for ($i = 0; $i <= $#db_cols; $i++) {
		if ($column eq $db_cols[$i]) {
			$fieldnum = $i; $found = 1;
			last;
		}
	}
	if (!$found) {
		return "error building select field: no fields specified!";
	}

	open (DB, "<$db_file_name") or &cgierr("unable to open $db_file_name. Reason: $!");
	if ($db_use_flock) { flock(DB, 1); }
	LINE: while (<DB>) {		
		next if /^#/;
		next if /^\s*$/;
		$line = $_;
		chomp ($line);		
		@fields = &split_decode ($line);
		if (!(grep $_ eq $fields[$fieldnum], @selectfields)) {
			push (@selectfields, $fields[$fieldnum]);
		}
	}
	close DB;
	
	$output = qq|<SELECT NAME="$name"><OPTION>---|;
	foreach $field (sort @selectfields) {
		($field eq $value) ?
			($output .= "<OPTION SELECTED>$field") :
			($output .= "<OPTION>$field");
	}
	$output .= "</SELECT>";

	return $output;
}

sub build_checkbox_field {
# --------------------------------------------------------
# Builds a CHECKBOX field based on information found
# in the database definition. Parameters are the column to build
# whether it should be checked or not and a default value (optional).

	my ($column, $values) = @_;

	if (!$db_checkbox_fields{$column}) {
		return "error building checkboxes: no checkboxes specified in config for field '$column'";
	}	
	
	my @names  = split (/,/, $db_checkbox_fields{$column});
	my @values = split (/\Q$db_delim\E/, $values);
	my ($name, $output);	

	foreach $name (@names) {
		(grep $_ eq $name, @values) ?
			($output .= qq!<INPUT TYPE="CHECKBOX" NAME="$column" VALUE="$name" CHECKED> $name\n!) :
			($output .= qq!<INPUT TYPE="CHECKBOX" NAME="$column" VALUE="$name"> $name\n!);
	}
	return $output;
}

sub build_radio_field {
# --------------------------------------------------------
# Builds a RADIO Button field based on information found
# in the database definition. Parameters are the column to build
# and a default value (optional).

	my ($column, $value) = @_;
	my (@buttons, $button, $output);

	@buttons = split (/,/, $db_radio_fields{$column});
	
	if ($#buttons == -1) {
		$output = "error building radio buttons: no radio fields specified in config for field '$column'!";
	}
	else {
		foreach $button (@buttons) {
			$value =~ /^\Q$button\E$/ ?
				($output .= qq|<INPUT TYPE="RADIO" NAME="$column" VALUE="$button" CHECKED> $button \n|) :
				($output .= qq|<INPUT TYPE="RADIO" NAME="$column" VALUE="$button"> $button \n|);
		}
	}	
	return $output;
}

sub array_to_hash {
# --------------------------------------------------------
# Converts an array to a hash using db_cols as the field names.

	my($hit, @array) = @_;
	my(%hash);
	 
	for ($j = 0; $j <= $#db_cols; $j++) {
		$hash{$db_cols[$j]} = $array[$hit * ($#db_cols+1) + $j];
	}	
	return %hash;
}

sub build_html_record {
# --------------------------------------------------------
# Builds a record based on the config information.
#
	my (%rec) = @_;
	my ($output, $field);
	
	$output = "<p><table border=0 width=450>";
	foreach $field (@db_cols) {
		next if ($db_form_len{$field} == -1);
		$output .= qq~<tr><td align=right valign=top width=20%><$font>$field:</font></td>
		                <td width=80%><$font>$rec{$field}</font></td></tr>
					~;
	}
	$output .= "</table></p>\n";
	return $output;
}

sub build_html_record_form {
# --------------------------------------------------------
# Builds a record form based on the config information.
#
	my (%rec) = @_;
	my ($output, $field);
	
	$output = "<p><table border=0>";
	foreach $field (@db_cols) {
		if ($db_select_fields{$field}) {      $output .= "<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%>" . &build_select_field($field, $rec{$field}) . "</td></tr>"; }
		elsif ($db_radio_fields{$field}) {    $output .= "<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%>" . &build_radio_field($field, $rec{$field}) . "</td></tr>"; }
		elsif ($db_checkbox_fields{$field}) { $output .= "<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%>" . &build_checkbox_field ($field, $rec{$field}) . "</td></tr>"; }
		elsif ($db_form_len{$field} =~ /(\d+)x(\d+)/) { 
											  $output .= qq~<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%><textarea name="$field" cols="$1" rows="$2">$rec{$field}</textarea></td></tr>~; }
		elsif ($db_form_len{$field} == -1) {  $output  = qq~<input type=hidden name="$field" value="$rec{$field}">$output~; }
		elsif ($db_form_len{$field} == -2) {  $per_admin ? ($output .= qq~<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%><input type=text name="$field" value="$rec{$field}" maxlength="$db_lengths{$field}"></td></tr>~) :
														   ($output  = qq~<input type=hidden name="$field" value="$rec{$field}">$output~); }
		else  { 							  $output .= qq~<tr><td align=right valign=top width=20%><$font>$field:</font></td><td width=80%><input type=text name="$field" value="$rec{$field}" size="$db_form_len{$field}" maxlength="$db_lengths{$field}"></td></tr>~; }
	}
	$output .= "</table></p>\n";
	return $output;
}		
		
sub get_time {
# --------------------------------------------------------
# Returns the time in the format "hh-mm-ss".
#
	my ($sec, $min, $hour, $day, $mon, $year, $dweek, $dyear, $daylight) = localtime(time());
	($sec < 10)  and ($sec = "0$sec");
	($min < 10)  and ($min = "0$min");
	($hour < 10) and ($hour = "0$hour");
	
	return "$hour:$min:$sec";
}

sub get_date {
# --------------------------------------------------------
# Returns the date in the format "dd-mmm-yy".
# Warning: If you change the default format, you must also modify the &date_to_unix
# subroutine below which converts your date format into a unix time in seconds for sorting
# purposes.

    my ($sec, $min, $hour, $day, $mon, $year, $dweek, $dyear, $daylight) = localtime(time());
    my (@months) = qw!Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec!;
	($day < 10) and ($day = "0$day");
	$year = $year + 1900;
    
    return "$day-$months[$mon]-$year";
}

sub date_to_unix {
# --------------------------------------------------------
# This routine must take your date format and return the time a la UNIX time().
# Some things to be careful about.. 
#     int your values just in case to remove spaces, etc.
#     catch the fatal error timelocal will generate if you have a bad date..
#     don't forget that the month is indexed from 0!
#
    my ($date)   = $_[0]; 
    my (%months) = ("Jan" => 0, "Feb" => 1, "Mar" => 2, "Apr" => 3, "May" => 4, "Jun" => 5, 
                    "Jul" => 6, "Aug" => 7, "Sep" => 8, "Oct" => 9, "Nov" => 10,"Dec" => 11);
	my ($time);
    my ($day, $mon, $year) = split(/-/, $_[0]);
    unless ($day and $mon and $year)  { return undef; }
    unless (defined($months{$mon}))   { return undef; }    

	use Time::Local;
    eval {		
		$day = int($day); $year = int($year) - 1900; 
        $time = timelocal(0,0,0,$day, $months{$mon}, $year);
    };
    if ($@) { return undef; } # Could return 0 if you want.
    return ($time); 
}

# These are the sorting functions used in &query.
# --------------------------------------------------------
sub alpha_ascend  { lc($sortby{$a}) cmp lc ($sortby{$b}) }
sub alpha_descend { lc($sortby{$b}) cmp lc ($sortby{$a}) }
sub numer_ascend  { $sortby{$a} <=> $sortby{$b} }
sub numer_descend { $sortby{$b} <=> $sortby{$a} }
sub date_ascend   { &date_to_unix($sortby{$a}) <=> &date_to_unix($sortby{$b}) }
sub date_descend  { &date_to_unix($sortby{$b}) <=> &date_to_unix($sortby{$a}) }

sub parse_form {
# --------------------------------------------------------
# Parses the form input and returns a hash with all the name
# value pairs. Removes SSI and any field with "---" as a value 
# (as this denotes an empty SELECT field.

	my (@pairs, %in);
	my ($buffer, $pair, $name, $value);	

	if ($ENV{'REQUEST_METHOD'} eq 'GET') {
		@pairs = split(/&/, $ENV{'QUERY_STRING'});
	}
	elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
 		@pairs = split(/&/, $buffer);
	}
	else {
		&cgierr ("This script must be called from the Web\nusing either GET or POST requests\n\n");
	}
	PAIR: foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		 
		$name =~ tr/+/ /;
		$name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		$value =~ s/<!--(.|\n)*-->//g;			  # Remove SSI.
		if ($value eq "---") { next PAIR; }		  # This is used as a default choice for select lists and is ignored.
		(exists $in{$name}) ?
			($in{$name} .= "~~$value") :	      # If we have multiple select, then we tack on
			($in{$name}  = $value);				  # using the ~~ as a seperator.
	}
	return %in;
}

sub cgierr {
# --------------------------------------------------------
# Displays any errors and prints out FORM and ENVIRONMENT 
# information. Useful for debugging.

    if (!$html_headers_printed) {
        print "Content-type: text/html\n\n";
        $html_headers_printed = 1;
    }
    print "DBMan encountered an internal error. ";
    if ($db_debug) {
        print "<PRE>\n\nCGI ERROR\n==========================================\n";
        $_[0]      and print "Error Message       : $_[0]\n";   
        $0         and print "Script Location     : $0\n";
        $]         and print "Perl Version        : $]\n";  
        $db_setup  and print "Setup File          : $db_setup.cfg\n";
        $db_userid and print "User ID             : $db_userid\n";
        $db_uid    and print "Session ID          : $db_uid\n";
        
        print "\nForm Variables\n-------------------------------------------\n";
        foreach $key (sort keys %in) {
            my $space = " " x (20 - length($key));
            print "$key$space: $in{$key}\n";
        }
        print "\nEnvironment Variables\n-------------------------------------------\n";
        foreach $env (sort keys %ENV) {
            my $space = " " x (20 - length($env));
            print "$env$space: $ENV{$env}\n";
        }
        print "\n</PRE>";
    }
    else {
        print "Please enable debugging to view.";
    }
    exit -1;
}
