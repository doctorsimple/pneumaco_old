#
#       ----------------------
#               DBMan
#       ----------------------
#       Database Administrator            
#
#         File: README.txt
#  Description: Instructions for how to install, setup and use dbman.
#       Author: Alex Krohn
#        Email: alex@gossamer-threads.com
#          Web: http://www.gossamer-threads.com/
#      Version: 2.05
# CVS Revision: $Id: README.txt,v 1.2 2000/07/08 18:06:26 alex Exp $
#
# COPYRIGHT NOTICE:
#
# Copyright 1997 Gossamer Threads Inc.  All Rights Reserved.
#
# This program is being distributed as shareware.  It may be used and
# modified free of charge for personal, academic or non-profit
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

Revision History:
    July 9, 2000: Version 2.05 Released
		- Security fix! One major and one minor security hole patched.

    October   15, 1998: Version 2.04 Released
		- Fixed Server Authentication bug.				
		- Query() optimized on non sorting searches.
		- Added $db_track_key option which will ignore counter file 
		  if using your own key.
		- Added signup_permissions which can be different then default.
		- Added support for usernames with numbers.
		- Admin's can now modify userid's.
		- Removed restriction that empty fields must have NULL in it.
		- Removed restriction that key must be in first position.
				
    September 11, 1998: Version 2.03 Released
                - Minor bug fix with shared flocks not working on some 
                  systems. Simply removed the &cgierr so it will not choke
                  if your system doesn't support it.

    August 16, 1998: Version 2.02 Released
                - Users can now sign up their own accounts.
                - Fixed logging bug.
                - Fixed flock bug.

    July 15, 1998: Version 2.01 Released
                - After many promises, version 2 is out with a lot 
                  of new features.
                - Removed PATH_INFO dependancy, will now work on crippled
                  IIS/PerlIS.dll machines.
                - Integrated user admin, can mangage the password 
                  file and add, remove, modify users. 
                - Record ownership features. Users can own records, and 
                  db can be set up so users can only modify or view their 
                  own records. Admin of course can do anything. 
                - Search engine rewritten with optimized regular expressions,
                  approximately 30% faster then before. 
                - Can now do range searches. 
                - Can now sort properly on numeric, date or alphabetical fields. 
                - AltaVista style next hit links. 
                - Multiple database support. 
                - New (cleaner?) default look               

    October 29, 1997: Version 1.2 Released
                - Sorting now searches entire database then sorts.
                - Added new search option: Sort order. Set "so" to "ascend" to sort
                  in ascending order, or "descend" to sort in descending order.
                - Reworked file locking to minimize time database is opened.
                - Added code snippet in html.pl so that if only one record is returned
                  on a modify search, that records is automatically brought up for editing.

    September 26, 1997: Version 1.1 Released
                - Added Sorting Support
                - Authentication Scheme completely redone, now 
                  supports Apache style authentication using
                  password and group files, no authentication,
                  or script authentication.
                - Added a "default user" capability.
                - Expanded Readme a little bit.
                - Few bug fixes.

    September 12, 1997: Version 1.0 Released

TABLE OF CONTENTS

    1. Welcome
        1.1 About the Script
        1.2 Registration
    2. Installation
    3. Creating your own Database
        3.1 One or more databases?
        3.2 Defining your database.
        3.3 Setting up authorization.
        3.4 Customizing the look.
    4. Problems

1. Welcome
----------------------------------------------------
DBMan is a shareware database manager that can manage a flat
file database for you. It has a wide range of possible applications,
anything from a Links manager to a telphone directory, to a 
shopping catalog. It provides a web interface to your database
to do such tasks as add, remove, modify and of course search. It
also provides a powerful security system to set up permissions
however you like.

I've stolen from Selena Sol a little flowchart of how the script
works as like he says, a picture is worth a thousand words. Here's
how a user can expect to go through the dbman:


                      Login ------- Login Failure
                        |                 |
                        |-----------------|
                        |
    -------------------Home Page-------------------------------------
    |             |                 |              |                |
  Add           Modify           Delete          View             Admin
  Record        Search           Search          Search           User 
    |             |                 |              |              Management
  Add           Pick Record      Pick Record     View Success/
  Success/      to Modify        to Delete       Failure
  Failure         |                 |               
               Modify Record     Delete Record  
                  |              Success/Failure
               Modify Record
               Success/Failure

Pretty straightforward? =)

This database is quite fast considering the information is stored
in a flat file text database. There is no upper limits on either
the number of fields you can have, or the number of records. Search
speed will slowly degrade as your database grows. You can expect reasonable
performance for database approaching 1 MB though.

However, if you find your database outgrows DBMan, an all SQL
version is available. Please contact alex@gossamer-threads.com for
more information.

This program has been tested on the following platforms: Win95 (without 
file locking and benchmarking support), HP-UX 9.05 and Linux 2.0 and
should work on any system with a working Perl 5.003. flock is about as exotic
as it gets.

1.1 Registration

DBMan is being distributed as shareware. It is free for non-profit,
academic or personal use. If you are a for-profit business then there
is a one time $100 US registration fee. Please make checks payable to 
Gossamer Threads Inc., and mail them to:

        Gossamer Threads Inc.
        653 Andover Pl.
        West Vancouver, B.C.
        V7S 1Y6

You can also pay by credit card on the web at:
	http://www.gossamer-threads.com/scripts/register/
        
I also ask that if you use DBMan, you let me know where it is
setup (a link to my site would also be nice, though not 
required).

2. Installation
----------------------------------------------------

You should find the following files in the archive and they
should have the following permissions

db.cgi              (755)       -rwxr--r--  
html.pl             (644)       -rw-r--r--
auth.pl             (644)       -rw-r--r--
default.cfg         (644)       -rw-r--r--
default.pass        (666)       -rw-rw-rw-
default.count       (666)       -rw-rw-rw-
default.log         (666)       -rw-rw-rw-
default.db          (666)       -rw-rw-rw
auth                (777)       drwxrwxrwx
README.txt          (644)       -rw-r--r--

The only file that should be accessible from the net is db.cgi. 
All requests to the script will go through db.cgi, and letting people
view the password file or auth directory is a major security risk 
(risk to DBMan's built in security, not to the security of the system). 
You can get by, by making sure Directory Indexing is off (and rename 
the files, security through obfuscation) or by placing all the files 
in a cgi-bin directory (preferred). 

Make sure you edit db.cgi and check that the path to perl points to
Perl 5.003 or better.

Edit default.cfg and set $db_dir_url to the directory that db.cgi
resides in. If you now go to the net you should be able to run the
demo database.

3. Creating your own Database
----------------------------------------------------

3.i. One or More databases?
-------------------------
Each database is made up of several files:

database.cfg    - this is your config file that defines the database.
database.db     - this stores the actual information. 
database.pass   - this stores the user passwords and permissions.
database.count  - this stores the counter for the next ID number to use.
database.log    - this stores a log of all activity to the database.
html.pl         - this is the html for the database and can be different
                  for different databases.

If you are only going to run one database, then you can just edit the
config and html files and ignore the following.

If you are planning to run multiple databases then you will need at a minimum
seperate database.db and database.cfg files. You might want seperate password,
counter and log files as well. You might also want seperate html files. For each
database, just set up a new config file with the appropriate file names defined.

To tell the script which database to use, you pass in the name of the config
file to load. For instance, if I have a 'orders.cfg' file for a list of orders,
I would call that by going to:

http://server.com/cgi-bin/db.cgi?db=orders

Note: You don't put on the .cfg. Just the part before the .cfg. If you don't
specify a config file to use, the script will look for "default.cfg".

3.2 Defining your database.
----------------------------
Most of the config is self explanatory, however I will cover a few of the options
here (and see authentication options later on).

* The database definition: %db_def
  By far the most important variable to set up. This holds a lot of information
  about how your database is defined. Pay careful attention to syntax, as it is
  easy to get tripped up. The format is:
  
  field_name => ['position', 'field_type', 'form-length', 'maxlength', 'not_null', 'default', 'valid_expr']
  
  Where:
  
        field_name = the name of the column.
        position   = field's position in the delimited text file.
        field_type = one of 'numer', 'alpha', 'date' depending on whether
                     the information is numerical, alphabetical or a date.
        form-length= the length the form field should be. Set to 0 for select, checkbox
                     or radio buttons, and set to '40x3' to make a 40 col by 3 row
                     textarea box. Set to -1 for hidden fields. Set -2 for admin only fields.
					 This is useful for the Userid field which will let an admin edit/view it,
					 but other users can't see it. All these fields only apply if you are
					 using auto_form_generation. You can alternatively, design your own form.
        maxlength  = maximum length of the field. The script will kick out an error if a user
                     tries to enter a data larger then the max.
        not_null   = set to 1 if this field can't be blank. set to 0 if it can.
        default    = you can enter a value to use as a default. Call &get_date to insert
                     today's date.
        valid_expr = enter a regular expression to validate input.
        
  Again, be careful about syntax. Study the example, and watch your commas and apostrophes.
  
* Auto generate forms with: $db_auto_generate
  Set this to 1 and the script will use your information supplied above and try and 
  produce some nice forms for you. You can use this to get a jump start and not
  worry about modifying the HTML. 
  
* Select, radio and checkboxes.
  You can use the three hashes to set up select, radio and checkboxes. Simply put
  the field name and a comma seperated list of values. See the default for an idea.
  
* Debugging with: $db_debug
  If you get stuck, make sure this is set to 1 and a nice error message will be
  displayed after every call to db.cgi. Be sure to turn it on if you ask for support.
  
* Benchmarking with: $db_benchmark
  If you have a particularly large database (> 5000 records), I'd love to take a 
  look at the performance. Send me a message.

3.3. Setting up the Authentication
----------------------------------
There are many different ways to configure the authentication system in DBMan.
You can have your system wide open where anyone can add, remove, modify or delete. Just
as easily, you could have it set up so that anyone can view the database, but only
you can add, remove or modify listings. With Version 2.01, it is now possible to
let users add records and then only modify or view their own records.

I'll go through the setups for some common scenerios:

* Anyone can view/modify/delete/add records: Just set $auth_no_authentication to 1.
* Users must log on with username/passwords to add/view/modify/delete:
     set $auth_no_authenticaion = 0;
         $auth_allow_default = 0;
         $auth_modify_own = 0;
         $auth_view_own = 0;
* Users must log on and can only modify their own, but can view anyones record:
     set $auth_no_authenticaion = 0;
         $auth_allow_default = 0;
         $auth_modify_own = 1;
         $auth_view_own = 0;
* Users must log on to add, remove, modify but anyone can view without logging on:
     set $auth_no_authenticaion = 0;
         $auth_allow_default = 1;
         @auth_default_permissions = (1,0,0,0,0);
         $auth_modify_own = 0;
         $auth_view_own = 0;
         
Notes on authentication:
    1. There is now an admin permission. Users with admin permission can add, remove
       and modify any records. They are not bound to the modify_own and view_own 
       restrictions. They can also add, remove, delete users into the password file.
       If you are logged in as an admin, you should see a link to the admin menu.
    2. Default Users. If you go to:
            http://server.com/cgi-bin/db.cgi?uid=default
       You will log into the database with @auth_default_permissions. You can use
       this method to bypass the log on, and go directly to an add form, or to
       a prebuilt search. For different databases, just use:
            http://server.com/cgi-bin/db.cgi?db=mydb&uid=default
       To do a search for 'cgi' in a field called 'title' you could do:
            http://server.com/cgi-bin/db.cgi?db=mydb&uid=default&view_records=1&title=cgi
       You can pass in as much as you like to the script this way.
    3. Modify/View Own. If you use modify/view own, you must define a "Userid" 
       field in your database and set $auth_user_field to it's position. See
       the default config file as an example.
    4. Creating Accounts. Anyone with admin access can add/remove/modify users. You
       can also turn on $auth_signup and let users create their own accounts. Simply
       link to the database:
            http://server.com/cgi-bin/db.cgi?signup_form=1      

3.4. Customizing the look
------------------------
All the HTML for the database is stored in an html.pl file. This contains
about 14 screens that you will probably want to modify to suit your needs.
90% of it is just HTML, so if you are comfortable with HTML tags, it should
be a breeze. If you have problems customizing the forms, consider using
$db_auto_generate which will make them for you.

There are a couple of things you should understand before you create your
HTML pages. You should feel comfortable with how print qq works. You should
also feel comfortable with some Perl syntax. I've tried to make it as easy 
as possible, while at the same time as powerful as possible.

If you've never seen print qq, well here's how it works. Perl will take
the first character after qq as a delimiter and print everything up to
the end delimiter. It will also interpolate variables. This allows you
to do something like

    print qq! Perl will print this line out, and everything else
    until it sees another exclamation mark. I can put $variables in here
    as well. I must however, backslash \@ symbols, but not quotes "'".

    Here's the end delimiter!;   # need ; to end statement

And that will print out everything between the !'s and put the value of 
$variables instead of actually printing "$variables". Make sense? Look
through the sample code and you'll see what I mean.

A tricky part comes when you want to insert some dynamic text for which
you need to run a subroutine to generate. You will have to end the 
print qq, run the subroutine and then start printing again. You'll see
that I've done this in several spots in the script already.

Creating Links:
You'll want to create links to the database functions, so here's how
you create them in html.pl.

Add Record              <A HREF="$db_script_link_url?add_form=1"> ... </A>
Modify Record           <A HREF="$db_script_link_url?modify_search=1"> ... </A>
Delete Record           <A HREF="$db_script_link_url?delete_search=1"> ... </A>
View Records            <A HREF="$db_script_link_url?view_search=1"> ... </A>
Home Page               <A HREF="$db_script_link_url"> ... </A>
Log Off                 <A HREF="$db_script_link_url?logoff=1"> ... </A>
List All                <A HREF="$db_script_link_url?view_records=1&$db_key=*"> ... </A>
Admin                   <A HREF="$db_script_link_url?admin_display=1"> ... </A>

In fact you can do any search with 

    <A HREF="$db_script_link_url?view_records=1"> ... </A>
    
and just put what you are searching for after that. The "List All" works because
a * will return everything. We use $db_key because every record must have
a key value. If you wanted to create a link that returned a list of all
records with "soft" in the title you could do:

    <A HREF="$db_script_link_url?view_records=1&Title=soft">
    
The options you can specify are:

Match Case              cs=1
Match Whole Word        ww=1
Regular Expression      re=1
Match Any               ma=1
Keywords                keyword=?
Sort By Field Number    sb=?       where ? is the field number indexed from 0.
Sort Ascending Order    so=ascend
Sort Descending Order   so=descend

With Version 2.01, you can now do range searches. To do a range search
just create a form with -gt or -lt after the name. For example, if you
have a price field: "CurrentPrice", then to make a range just enter:

between <input type=text name="CurrentPrice-gt"> and 
        <input type=text name="CurrentPrice-lt">
        
If the script sees a -gt, it will look for all values greater then the
inputed value, and if it sees a -lt, it will look for all values less
then the inputed value.

You can also do range searches by starting your query with a > or <. For
instance, to find all ID's greater then 10, you could put into the ID 
field '>10'. This will save you from creating an extra form field.
        
4. Problems
----------------------------------------------------

If you have any problems during the setup, please visit the support
forum of our website at:

    http://www.gossamer-threads.com/scripts/forum/
    
Good Luck!

Alex