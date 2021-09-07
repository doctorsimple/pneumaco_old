#!/bin/bash

APPNAME="Gogo Internet Services - Useful cPanel Tools"
TITLE=
PERLSCRIPT=$(cat $0 | perl -e "
   my \$doOut = 0; 
   foreach my \$line (<STDIN>) 
   { 
     if(\$line =~ /^#\!.*perl/)
     {
       \$doOut = 1;
     }
     
     if(\$doOut)
     {
       print \$line;
     }
   }
  ")

function drawLine()
{
  if test ! -z "$1"
  then
   CHAR=$1
  else
   CHAR="-"
  fi
  
  if test ! -z "$2"
  then
    REMAIN=$2
  elif test ! -z "$COLUMNS"
  then
   REMAIN=$COLUMNS
  else
   REMAIN=80
  fi
  
  while test $REMAIN -gt 1
  do
    echo -n "$CHAR"
    REMAIN=$(expr $REMAIN - 1)
  done
  echo "$CHAR"
}

function reset()
{
  clear
  echo "$APPNAME"
  if test -n "$TITLE"
  then
    echo "$TITLE"
  fi
  drawLine "="
  echo  
}

# askQuestion INTRO PROMPT response in $REPLY
function askQuestion()
{
  if test ! -z "$1"
  then
    echo "$1"
    echo
  fi
  
  echo "$2"
  echo -n ": "
  read -e  
  return $?
}

function askPassword()
{
  askQuestion "$@"
  return $?
}

function askYN()
{
  local INTRO=$1
  local PROMPT=$2
  
  if test -z "$PROMPT"
  then
   PROMPT="Please enter YES or NO and hit enter."
  fi

  askQuestion "$INTRO" "$PROMPT"
  
  case $REPLY in
    "Y" | "y" | "yes" | "YES" | "Yes" )
      return 0
    ;;
    
    "N" | "n" | "no" | "NO" |"No" )
      return 1
    ;;
  esac
  
  askYN "" ""
  return $?
}

# TITLE KEY1 DESCRIP1 KEY2 DESCRIP2 ... KEYn DESCRIPn
# Saves response in REPLY
function askMenu()
{      
  local MENUTITLE=$1    
  shift 1
  reset
    
  echo "  $MENUTITLE  "
  drawLine - `echo -n "  $MENUTITLE  " | wc -m`
    
  ADDNL=-n
  OPTCOUNT=1
  
  for Opt
  do
   if test -n "$ADDNL"
   then 
     echo -n "$OPTCOUNT: "
     OPTCOUNT=$(expr $OPTCOUNT + 1)
   fi
   
   echo $ADDNL "$Opt"
   if test -z "$ADDNL"
   then
     ADDNL=-n
   else
     echo -ne "   \t- "
     ADDNL=
   fi
  done
  
  echo
  askQuestion "" "Please type option desired (eg $1) and hit enter."
  return 0
}












function menu()
{
  TITLE=
  
  askMenu     "Select Tool"    \
    Reclaim   "\"nobody\" Files under public_html" \
    Install   "CGI Mode PHP"                       \
    Howto     "Configure CGI php.ini"              \
    Edit      "php.ini File"                       \
    Uninstall "CGI Mode PHP"                       \
    Quit      "this tool."
  
  case $REPLY in
    "Reclaim" | 1 )
      nobodyFixer
      menu
    ;;
    
    "Install" | 2 )    
      installCGI
      menu
    ;;
    
    "Howto"   | 3 ) 
      showHowto
      menu
    ;;
    
    "Edit"    | 4 )
      editIni
      menu
    ;;
    
    "Uninstall" | 5 )
      uninstallCGI
      menu
    ;;
    
  esac
}

function editIni()
{
    if test -d /home/$USERNAME/php-inis
    then
      echo
    else
      mkdir /home/$USERNAME/php-inis
      echo \
"; CGI Mode PHP site.ini File
; ---------------------------------------------------------------------
;                                                                      
; This file contains settings that you wish to override or remove from 
; the server's standard php.ini file, use the below example as a guide 
; for the syntax to use here                                           
;                                                                      
; Examples:                                                            
; 1. Remove an entire section                                          
;  -[Verisign Payflow Pro]                                             
;                                                                      
; 2. Remove a specific ini setting no matter what it's value           
;  -mssql.compatability_mode                                           
;                                                                      
; 3. Set a specific ini setting, even if it was set before (overrides) 
;  mssql.min_error_severity=10                                         
;                                                                      
; 4. Remove lines matching the regular expression \"ingres\..*\"       
; -preg:ingres\..*                                                     
;                                                                      
; 5. Remove an extension                                               
; -extension=pspell.so                                                 
;                                                                      
; 6. Add an extention/ensure it is loaded                              
; extension=mysql.so                                                   
;                                                                      
; 7. And add some settings to a section                                
; [MySQL]                                                              
; mysql.allow_persistent=On                                            
;                                                                      
; ---------------------------------------------------------------------
" > /home/$USERNAME/php-inis/site.ini
    fi    
    
    nano -w /home/$USERNAME/php-inis/site.ini
}

function showAgreement () {
  reset
  LICENCE="Copyright (c) 2006, James Sleeman
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
    
  if askYN "$LICENCE" "Do you agree to this licence agreement (YES/NO) ?"
  then
   reset
  else
   exit
  fi
    
}



function nobodyFixer () {
  TITLE="Reclaim Nobody Files"  
  HOSTNAME=`hostname`
     
  showAgreement
     
  if askYN "It is a very very good idea to take a home directory backup from cpanel before we do the fixing.  If anything goes wrong you can restore (or have your host restore) the backup using cpanel. 
  
Would you like us to download a home directory backup for you from your cpanel now? 

It would be saved as /home/$USERNAME/backup-home.tar.gz"
  then    
   askPassword "" "Please enter your cPanel password."
   PASSWORD=$REPLY
      
   rm -f /home/$USERNAME/backup-home.tar.gz     
   cd /tmp
   wget -v --user=$USERNAME --password=$PASSWORD "http://$HOSTNAME:2082/getbackup/backup-home-$USERNAME.tar.gz"
   mv backup-home-$USERNAME.tar.gz /home/$USERNAME/backup-home.tar.gz
   cd /home/$USERNAME
  else
   echo
  fi
  
  # One final chance
  if askYN "This is your last chance to bail out before we make modifications to the files and directories." "Would you like to EXIT without making any changes now (YES/NO)?"
  then
    reset
    echo "Exiting without making any changes."
    sleep 2s
    return
  fi
  
  # Begin the real work
  reset
  rm -rf /home/$USERNAME/public_html/gogopermfixer
  echo
  echo "Creating temporary PHP script.";    
  mkdir /home/$USERNAME/public_html/gogopermfixer
  echo  "RemoveHandler .php" >/home/$USERNAME/public_html/gogopermfixer/.htaccess
  echo  "<?php 
    header('Content-Type: text/plain');
    \$files = explode(\"\\n\", \`find /home/$USERNAME/public_html -user nobody\`);
    foreach(\$files as \$file)
    {
      echo \$file . \"\\n\";
      system(\"chmod -f ugo+rwX \$file 2>&1\");
      flush();      
    }
  ?>" >/home/$USERNAME/public_html/gogopermfixer/fix.php  
  
  echo
  echo  "Fixing permissions on nobody files..."
  wget -nv -O - "http://$HOSTNAME/~$USERNAME/gogopermfixer/fix.php" 
    
  echo
  echo  "Cleaning up temporary files."
  rm -rf /home/$USERNAME/public_html/gogopermfixer
    
  echo
  echo  "Copying public_html to public_html.new"
  cp -r /home/$USERNAME/public_html /home/$USERNAME/public_html.new 2>fixerrors
  
  if test -s fixerrors
  then
    ERRORS=`cat fixerrors`
    echo    
    if askYN "It appears that there may have been some errors occur when we tried to copy the files, this probably means that there are some files or directories that are owned by a user other than \"nobody\" or \"$USERNAME\".  Here are the errors...      

$(drawLine)      
$ERRORS    
$(drawLine)
      
Do you wish to continue (warning, any files that couldn't be copied may be lost if continue here)?"
    then
      # OK to continue      
      echo
    else
      #Bail
      rm -rf /home/$USERNAME/public_html.new
      reset
      echo "Errors have been left in file called \"fixerrors\" you should examine this file and correct the ownership of the files that have produced the errors, they are likely owned by a user other than $USERNAME or nobody. Probably you will have to get your web host to correct the ownership of these files."
      exit
    fi
  fi
  rm fixerrors
  
  echo "Moving old public_html to public_html.old."  
  mv /home/$USERNAME/public_html /home/$USERNAME/public_html.old
  
  echo "Moving new public_html to it's rightful space."
  mv /home/$USERNAME/public_html.new /home/$USERNAME/public_html
 
  echo "Setting permissions on new public_html."
  chmod 02755 /home/$USERNAME/public_html
    
  if askYN "Would you like to keep the old public_html files (as /home/$USERNAME/public_html.old).  If you think any errors occurred, probably a good idea to keep them, otherwise you don't need them."
  then
   echo 
  else
   rm -rf /home/$USERNAME/public_html.old
  fi
  
}


function showHowto() {
  echo \
"$APPNAME
Howto edit your CGI Mode PHP ini file.
(Press q to (q)uit), up and down arrows to scroll.
$(drawLine =)

Once you install CGI Mode PHP you can no longer specify PHP ini values in your .htaccess file(s), instead you must specify them in a special ini file.
  
In the simplest case, simply edit the file /home/$USERNAME/php-inis/site.ini and add any special ini settings you need in exactly the same was as for a normal php.ini file.
  
Sometimes you may need to remove settings from the main ini file (for instance, to stop a PHP extention that is specified in the system file from loading).  The easiest way to show how to accomplish this is to give an example...
  
$(drawLine -)
; Example /home/$USERNAME/php-inis/site.ini

; Remove the [Verisign Payflow Pro] section and settings in it
-[Verisign Payflow Pro]

; Remove the mssql.compatability_mode setting
-mssql.compatability_mode

; Set the mssql min_error_severity to 10, no matter what it was before
mssql.min_error_severity=10

; Remove all ingres settings, but leave the section header
;  the format here is -preg:<regular expression matching lines to remove>
-preg:ingres\..*

; Remove the pspell extention
-extension=pspell.so

; Add the mysql extention if it hasn't already been added
extension=mysql.so

; And add some mysql settings 
[MySQL]
mysql.allow_persistent=On

$(drawLine -)

One word of caution, when removing entire sections ( with -[Section Name] ), if it's the last section in the file, it will remove all settings from that section header to the end of the file, which may not be what you want.  It is best to do all the removals first, and then the additions/modifications.

Note that our ini merging method is specific to the Gogo CGI Mode PHP setup, it will not work with other typical CGI PHP setups (like suPHP etc), these generally need you to take a full copy of the main server ini file and edit it.  The problem with that is that once you have copied it you no longer get updates to your ini settings if the system administrator has to change a PHP setting for security, or an upgrade etc.  The Gogo method is superior in this regard and will provide for a much easier to maintain (and more reliable) CGI Mode PHP setup.

$(drawLine =)" | less  
}

function installCGI() {
  TITLE="Install CGI Mode PHP"    
  showAgreement
  
  if test -d /home/$USERNAME/public_html/cgi-bin/
  then
   echo
  else
   echo "Creating cgi-bin"
   mkdir /home/$USERNAME/public_html/cgi-bin/
  fi
  
  askQuestion "" "What is the full path to the PHP CGI binary [default is /usr/bin/php]" 
  if test -n "$REPLY"
  then
    PHP_CGI_SCRIPT=$REPLY
  else
    PHP_CGI_SCRIPT="/usr/bin/php"
  fi
  
  rm -f /home/$USERNAME/public_html/cgi-bin/php-cgiwrap.cgi
  
  echo "Creating /home/$USERNAME/public_html/cgi-bin/php-cgiwrap.cgi" 
  echo "$PERLSCRIPT" | replace "::PHP_CGI_EXEC::" "$PHP_CGI_SCRIPT" >/home/$USERNAME/public_html/cgi-bin/php-cgiwrap.cgi
  
  echo "Setting execute permissions."
  chmod =rx /home/$USERNAME/public_html/cgi-bin/php-cgiwrap.cgi
  
  echo "Creating /home/$USERNAME/.htaccess"
  
  echo "# == PHP-CGIWRAP ==
  # Author: James Sleeman, Gogo Internet Services Limited (NZ)
  #         http://www.gogo.co.nz/
  #
  # The following .htaccess rules instruct Apache to send all requests
  # through 
  #    /home/$USERNAME/public_html/cgi-bin/php-cgiwrap.cgi
  # this is in order to have PHP files run under the user account $USERNAME
  # instead of "nobody" (or www-data on some systems) as they do when run
  # as an Apache Module.
  #
  # This system also has the advantage of being able to modify the PHP 
  # ini settings without actually modifying the system base php.ini
  #
  " >>~/.htaccess
  echo "AddHandler php-cgiwrap .php" >>~/.htaccess
  echo "Action     php-cgiwrap /~$USERNAME/cgi-bin/php-cgiwrap.cgi" >>~/.htaccess
  
  if askYN "CGI Mode PHP Activated."  "Would you like to read how you can edit the CGI Mode PHP ini settings?"
  then
    showHowto
  fi
  
  if askYN "" "Would you like to edit the ini settings file now?"
  then
    editIni
  fi  
}


function uninstallCGI()
{
  TITLE="Uninstall CGI Mode PHP"
  showAgreement
  rm /home/$USERNAME/.htaccess
  rm /home/$USERNAME/public_html/cgi-bin/php-cgiwrap.cgi
  echo "Uninstall complete."
  sleep 2  
}

USERNAME=`whoami`
cd /home/$USERNAME
menu
exit


























# BELOW THIS LINE IS PERL CODE FOR php-cgiwrap.cgi
#!/usr/bin/perl
# :mode=perl:
# Debug

my $username       = substr(`whoami`,0,-1);
my $php_cgi_exec   = "::PHP_CGI_EXEC::"; 
my $ini_path       = "/home/$username/php-inis/"; 


# A small wrapper script to call PHP in cgi mode for suexec enabled servers
# drop this script into cgi-bin, and put the following in your root level .htaccess 
# 
# AddHandler .php php-cgiwrap
# Action php-cgiwrap /cgi-bin/php-cgiwrap.cgi
#
# This script has the following main advantage..
#  you may create a file /cgi-bin/php{version}-inis/site.ini
#  and include in that directives which will be merged with the system standard 
#  php.ini for the CGI binary.  This allows you to override certain settings...
#
# ------------ Example site.ini -- cut here --------------------
# ; Remove all Payflow Pro settings entirely (by removing the section)
# -[Verisign Payflow Pro]
#
# ; Remove the mssql.compatability_mode setting entirely
# -mssql.compatability_mode
#
# ; Set the mssql min_error_severity to 10, no matter what it was before
# mssql.min_error_severity=10
#
# ; Remove all ingres settings, but leave the section header
# -preg:ingres\..*
#
# ; Remove the pspell extention
# -extension=pspell.so
#
# ; Add the mysql extention if it hasn't already been added
# extension=mysql.so
# 
# ; And add some mysql settings 
# [MySQL]
# mysql.allow_persistent=On
# ----------------------------------------------------------------------


# Try and be smart if the PHP binary doesn't exist where we are told 
if(!-f $php_cgi_exec)
{
  $php_cgi_exec = '/usr/bin/php'; 
}

my $bin_path   = $ENV{SCRIPT_FILENAME};
   $bin_path   =~ s/\/[^\/]*$/\//;
  
my $master_ini   = $ini_path . 'master.ini';
my $our_ini      = $ini_path . 'php.ini';
my $override_ini = $ini_path . 'site.ini';

if(0)
{
  print "Content-Type: text/plain\n\n";
  print $ini_path;
  
  my $username = substr(`whoami`,0,-1);
  #chomp($username);
  print "You are: $username\n";
  print `sh -c set`;
  exit;
}

if(!-f $ini_path)
{
  mkdir($ini_path);
}

if(!-f $master_ini)
{
  # Find the master ini file for the PHP binary
  my $ini = qx/exec -c $php_cgi_exec -i/;
  if($ini =~ />(\/.*\.ini)/)
  {
    $ini = $1;
    symlink $ini, $master_ini;
  }
}

if(   (! -f $our_ini) 
   || (-M $our_ini > -M $master_ini)
   || (-f $override_ini && (-M $our_ini > -M $override_ini))
  )
{  
  my $s = "(?:(?: |\t)*)";
  my $ini_contents = `cat $master_ini`;
  $ini_contents =~ s/^;.*$//mg;     # Remove all comments 
  $ini_contents =~ s/^(?: |\t)*(.*?)(?: |\t)*$/\1/mg;      # Trim all leading/trailing space  
  $ini_contents =~ s/\r?\n/\n/g;    # Make sure no CR, just LF
  $ini_contents =~ s/(?: |\t)*=(?: |\t)*/=/g;   # Trim whitespace around equals
  
  if(-f $override_ini)
  {
    open OVRD, "<$override_ini";
    foreach $line (<OVRD>)
    {
      $line =~ s/^(?:(?: |\t)*)(.*?)(?:(?: |\t)*)$/\1/;      # Trim all leading/trailing space
      if($line =~ /^-((\[|preg:)?(.*?))$/)
      {                
        if($2 eq '[') # Remove a section
        {
          $ini_contents =~ s/\Q$1\E(?:[^\n]|\n[^\[])*//g; # Remove [Section] to next ^[ or end of file
        }
        elsif($2 eq 'preg:')
        {          
          $ini_contents =~ s/^$3(?: |\t)*(;.*)?$//mg; # Treat as a preg 
        }        
        else
        {
          my $m = $1;
          $m =~ s/(?:(?: |\t)*)=(?:(?: |\t)*)/=/; # Trim whitespace around the equals
          $ini_contents =~ s/^\Q$m\E((?:(?: |\t)*)\=.*)?(;.*)?$//mg; # Treat as a line to match
        }
      }
      else
      {
        # be careful that we don't put the same command with the same value in twice
        # this will stop us loading extentions twice
        my $m = $line;
        $m =~ s/(?:(?: |\t)*)=(?:(?: |\t)*)/=/; # Trim whitespace around the equals
        $ini_contents =~ s/^\Q$m\E((?:(?: |\t)*)\=.*)?(;.*)?$//mg; # Treat as a line to match          
        $ini_contents .= "\n" . $line; # insert the new one
      }
    }
    close OVRD;
  }
  
  $ini_contents =~ s/\n{2,}/\n/g;      # Remove multiple newlines (blank lines)
  
  $new_ini = '
  
;         ____  _____    _    ____     _____ ___ ____  ____ _____
; __/\__ |  _ \| ____|  / \  |  _ \   |  ___|_ _|  _ \/ ___|_   _| __/\__
; \    / | |_) |  _|   / _ \ | | | |  | |_   | || |_) \___ \ | |   \    /
; /_  _\ |  _ <| |___ / ___ \| |_| |  |  _|  | ||  _ < ___) || |   /_  _\
;   \/   |_| \_\_____/_/   \_\____/   |_|   |___|_| \_\____/ |_|     \/

; DO NOT EDIT THIS FILE
; ========================================================================
;
; If you need to make modifications, please place such ini settings in 
; the file called site.ini (in this same directory) and they will be
; MERGED into this file automatically.  The format of the site.ini
; file is the same as for a normal php.ini, with a few additions which allow
; you to remove settings.  Here is an example to show you how to do it...
;
; ------------ Example site.ini -- cut here --------------------
; ; Remove all Payflow Pro settings entirely (by removing the section)
; -[Verisign Payflow Pro]
;
; ; Remove the mssql.compatability_mode setting entirely
; -mssql.compatability_mode
;
; ; Set the mssql min_error_severity to 10, no matter what it was before
; mssql.min_error_severity=10
;
; ; Remove all ingres settings, but leave the section header
; -preg:ingres\..*
;
; ; Remove the pspell extention
; -extension=pspell.so
;
; ; Add the mysql extention if it hasn\'t already been added
; extension=mysql.so
; 
; ; And add some mysql settings 
; [MySQL]
; mysql.allow_persistent=On
; ----------------------------------------------------------------------
;
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
; *********** DO NOT MODIFY THIS FILE - DO NOT MODIFY THIS FILE **********
' . $ini_contents . '
cgi.fix_pathinfo = 1
';

  open OUTFILE, ">" . $our_ini;
  print OUTFILE $new_ini;
  close OUTFILE;  
}




# WARNING - We are specifying fix_pathinfo=1 this will correct the 
# paths for us (PHP_SELF, PATH_INFO, PATH_TRANSLATED, SCRIPT_NAME, SCRIPT_FILENAME
# HOWEVER: PHP_SELF will NOT have the PATH_INFO on the end of it
#  and it is the rewritten SELF (if you used mod_rewrite, the requested "file" is 
#  NOT PHP_SELF, but the end result of the rewrite is).
chdir $ini_path; # PHP4 doesn't really grock -c <inifile> so we chdir there so it finds it
exec $php_cgi_exec, "-c", $out_ini;


