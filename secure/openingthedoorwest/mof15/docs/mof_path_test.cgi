#!/usr/bin/perl

	

@MAIL_TEST = (
  '/usr/sbin/sendmail -t',
  '/usr/lib/sendmail -t',
  '/var/qmail/bin/qmail-inject'
  );



	@MailExists = ();
	@MailNotExists = ();

	foreach (@MAIL_TEST) {

	@ts = split(/ /, $_);
	
	
		if ( -e $ts[0] ) {
	
		push (@MailExists, $_);


   		} else {

		push (@MailNotExists, $_);


		}

	}




	# TESTING INSTALLATION INFO
	# TESTING INSTALLATION INFO


	$LocalTime = (localtime(time));
	$GMTime = (gmtime(time));


		# Print Variables Available
		# Print Variables Available

	print "Content-Type: text/html\n\n";
	print "<html><head><title>Merchant OrderForm v1.53 Installation Test</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";

	print "<h3>Merchant OrderForm v1.53 Installation Test</h3>";

	print "<ul> ";

	print "<li>DOCUMENT_ROOT: <strong>$ENV{DOCUMENT_ROOT} </strong> <p>";

		
	print "<li>Referring URL: <strong>$ENV{'HTTP_REFERER'}</strong>";
	print "<li>Server Name: <strong>$ENV{'SERVER_NAME'}</strong>";
	print "<li>Server Protocol: <strong>$ENV{'SERVER_PROTOCOL'}</strong>";
	print "<li>Server Software: <strong>$ENV{'SERVER_SOFTWARE'}</strong>";
	print "<li>Gateway: <strong>$ENV{'GATEWAY_INTERFACE'}</strong>";
	print "<li>Remote Host: <strong>$ENV{'REMOTE_HOST'}</strong>";
	print "<li>Remote Addr: <strong>$ENV{'REMOTE_ADDR'}</strong>";
	print "<li>Remote User: <strong>$ENV{'REMOTE_USER'}</strong><p>";
	
	print "<li>Local Time: $LocalTime";
	print "<li>GM Time: $GMTime <p>";

	print "</ul> ";



	print "<P>Mail Locations That Work:<br>";

		foreach (@MailExists) {
		print "<li>$_";
		}



	print "<P>Mail Locations Not Working:<br>";

		foreach (@MailNotExists) {
		print "<li>$_";
		}




	print "<p>Happy Ordering<br> ";
	print "Merchant OrderForm v1.53 \© Copyright <a href=\"http://www.io.com/~rga/scripts/\">RGA</a> \n";
	
	print "</body></html> \n\n";



