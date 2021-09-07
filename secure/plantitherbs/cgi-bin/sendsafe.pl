#!/usr/bin/perl -w
##
## sendsafemail - encrypts and sends a mail to plantit@frognet.net
##                I'm fairly sure this script will not work on other
##                servers.  It is basicallly a glorified macro as it
##                mimics the encryption process
##

require 'fn_lib.pl';
require 'cgi-lib.pl';

&hh();
&ReadParse();
#&errorCheck();

&showPage('/home/plantit/plantitherbs.com/html/success.htm');

my $mailprog = '/usr/sbin/sendmail';
my $pgpe ='/usr/bin/pgpe';
my $pd = '/usr/local/www/com/plantitherbs/.pgp';
#my $pd = '/usr/local/www/net/frognet/planitherbs_pgp';
#my $pd = '/usr/local/www/com/plantitherbs/html/script';
#				"--PubRing=\"$pd/pubring.pkr\" " .
#				"--NoBatchInvalidKeys=0 " .
#				"--SecRing=\"$pd/secring.skr\" " .
#				" 2>&1"

$| = 1; #flush buffers
alarm(45);
open (STDOUT, "|$mailprog -t") || die "$!\n";
print STDOUT "To: plantit\@frognet.net\n";
print STDOUT "From: plantit\@frognet.net\n";
print STDOUT "Subject: Secure Order from PLANTITHERBS.COM\n\n\n";
open (ENCRYPT,	"|$pgpe -r plantit\@frognet.net -atf") || die "$!\n";
print ENCRYPT <<ENDENCRYPT;
BILLING
==================================
Name: $in{billing_name}
Email: $in{billing_email}
Address: $in{billing_address}
City: $in{billing_city}
State: $in{billing_state}
State: $in{billing_zip}
Fax: $in{billing_fax}
Phone: $in{billing_phone}

Shipping
==================================
Name: $in{shipping_name}
Address: $in{shipping_address}
City: $in{shipping_city}
State: $in{shipping_state}
Zip: $in{shipping_zip}

CCN: $in{ccn}
EXP: $in{cce}
Total Amount: $in{ordertotal}

The Order
==================================
ENDENCRYPT

my $count = 0;
foreach  (sort keys %in) {
	$count++ if (/^num\d+/);
	if ($in{"num$count"} ne '') {
		print ENCRYPT "item number: " . $in{"num$count"} . "\n";
		print ENCRYPT "name: " . $in{"name$count"} . "\n";
		print ENCRYPT "quantity: " . $in{"q$count"} . "\n";
		print ENCRYPT "price: " . $in{"p$count"} . "\n";
		print ENCRYPT "total: " . $in{"t$count"} . "\n\n";
	}
}

print ENCRYPT "Substitutions\n";
print ENCRYPT "================================\n";

$count = 0;
foreach  (sort keys %in) {
	if (/^sub\d+/) {
		$count++;
		print ENCRYPT "$count) " . $in{"sub$count"} . "\n";
	}
}

print ENCRYPT <<ENDENCRYPT2;
Duplicate: $in{duplicate}
Refund: $in{refund}

Gift Certificate
=================================
$in{giftcertificate}
Amount: $in{giftcertificateamount}
Sign Card as: $in{cardsigned}


ENDENCRYPT2
close ENCRYPT;
close STDOUT;
print STDIN "Y\n";


exit;

##
## errorCheck - check for errors

sub errorCheck {
	my @error = ();
	push (@error, "You forgot to include the billing name") if ($in{billing_name} eq '');
	push (@error, "You forgot to include the billing address") if ($in{billing_address} eq '');
	push (@error, "You forgot to include the billing city") if ($in{billing_city} eq '');
	push (@error, "You forgot to include the billing state") if ($in{billing_state} eq '');
	push (@error, "You forgot to include the billing zip") if ($in{billing_zip} eq '');

	my $contactinfo = 0;
	$contactinfo++ if ($in{billing_phone} ne '');
	$contactinfo++ if ($in{billing_email} ne '');
	push (@error, "You need to give us your email address and/or your phone " .
				  "number so that we can contact you in the event there is a " .
				  "problem with your order. You cannot leave both of these ".
				  "blank.") if not $contactinfo;
	push (@error, "You forgot to include the credit card number") if ($in{ccn} eq '');
	push (@error, "You forgot to include the expiration date of your card") if ($in{cce} eq '');

	 &exitCGI(\@error, 1, 1) if (scalar @error > 0);
}