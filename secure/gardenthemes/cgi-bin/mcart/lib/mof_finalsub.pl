# ==================== MOFcart v2.5.10.21.03 ====================== #
# === EXAMPLE OF SEPERATE SUB ROUTINE IN FINAL SCREEN ============= #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# This example show you how to use a seperate sub Routine to present a custom
# Final Order Confirmation screen which is *specific* to only one payment method
# Using the default <mof_final.pl> Final Order Confirmation Screen
# We can insert a call to this sub Routine for (as example) the Mailing Payment method
# See embedded notes in <mof_final.pl> for that Payment Method : # (1.1) pay by mail

# This area allows you to customize in almost an unlimited way, the final confirmation screen
# top message, specific to each Payment Method you make available in the configs
# use only the [ qq~ ~; ] enclosure as in the examples below. You can use *any* valid html,
# added CSS, javascript, images, pop up links, and even robust variable replacements in your  messages
# For a detail list of available Variables for replacement in your messages refer to the Docs
# You can use any of the replacement VARs in both the Header and/or the Text Message
# You will need to Escape some chars .. \@  for Sales\@OurSite.com
# But almost all chars used within the [ qq ] format need *not* be escaped, including quotes, double quotes
# As a sub Routine within <mof_final.pl> (the default final confirmation screen) you can refer to any
# existing variables active at this point in the script ..
# You can refer to any of the vars directly as part of the %frm hash : $frm{'NAME'}
# --or you can use the VarReplacer shceme for replacement VARs {{VARNAME}}
# You can refer to any VARiable that appears in the Conf file by direct name: $currency
# Use the <mofstyle.css> CSS settings for the <TABLE><TR><TD> surrounding the message for added customizing
# *Do Not* include a Top Message in the Final template <mofconfirmation.html> 
# but let the dynamic message definitions below create final order confirmation messages

# You can use a different sub Routine for each Payment Method Available
# This example sets up Two : (1) Mailing Payment & (2) COD .. as examples only
# See those sections in <mof_final.pl> # (1.1) pay by mail & # (1.2) cod
# and call the sub routine from the <mof_final.pl> PaymentAccepted section as 
#       $final_msg_var = &YOURSUBROUTINE();
#	$final_msg_var = &VarReplacer($final_msg_var);

# example using -----> $final_msg_mail
# in <mof_final.pl> call the new sub routine directly above the &VarReplacer() function
#  (new line) ------------>   $final_msg_mail = &FINALMSGMAIL();
#  (existing line) ------->   $final_msg_mail = &VarReplacer($final_msg_mail);

# example of the sub ROUTINE (note: make the sub NAME something that mirrors the var
# to prevent any overwriting of existing sub Routines in the pkg
# and if you initialize any new Vars, make sure and do them locally ---> my $var

# There is a special switch in <mof_final.pl> The default Final Confirmation Screen
# called "$UseCustomOnlyMsg" that will allow you to override the default cart content
# that <mof_final.pl> prints .. so you can use ** only ** the custom $final_msg_var here
# or you can include the default content in <mof_final.pl> and just enhance the Top Message
# with your custom sub Routine here .

# the custom sub ROUTINE provides a set aside area where you can tie in your own perl
# to the cart PKG .. virtually unlimited .. you can create your own Receipt page as a final
# screen, you could even create some javascript for a redirect, or a simple perl redirect with exit
# at this point, custom-custom gateway or API, program lines for different currencies, or even
# set up custom mail messages, or set up custom files to print to server, etc.
# re-work the computations, use your own arithmitic, etc. I recommend that for any totals
# you use the existing computations amounts found in the VarReplacer {{variables}}
# You can refer to any of the VarReplacer variables in the RAW as   $frm{'variable'}
# example : You can use the VarReplacer to substitute {{Tax_Amount}} in your message
# example : but call the RAW number for computation with   $frm{'Tax_Amount'}
# example: both contain the same number, but you can't perform operations on a VarReplacer
# if you do any kind of script termination (exit) or redirect from this point, just make sure you
# understand what is happening in the program flow of <mofpay.cgi> ** and ** <mof_final.pl>.
# Basically at this point the only two functions that are not yet performed are the Mail messages to Customer and Merchant
# You can also re position the &PaymentAccepted call in the program flow <mofpay.cgi>
# as the last item before the "# End Program Flow" and your sub ROUTINE will be the very last function
# If your sub ROUTINE gets too big for the CONF file, then just put it in its own file and require it when <mofpay.cgi> loads
# Put a unique CSS for the <mofconfirmation.html> and set up your completely unique final page design

# Yet another way to customize the Final confirmation message is to simply construct a custom
# Web Copy invoice file, then just insert a RE-DIRECT to the Saved URL instead of printing
# the &PaymentAccepted routine

# this is an example only, it will not execute unless called
# Please Note: this example for currencies does *not* include computations
# for Tax, Shipping, Handling, Insurance, Discounts, etc. that the MOFcart front end provide
# Those can certainly be added into this example, however

# The following sub Routine is set up as an example to use in <mof_final.pl> section 1.1
# Allowing you to insert a custom final screen for the Pay By Mailing or Faxing method

sub FINALMSGMAIL {

	# you'll need to block out the existing msg in <mof_final.pl> branching
	# of if you want to include that message then disable the following var replacement
	$final_msg_mail = "";

	# use only your msg (1), or use the default Final cart content (0)
	# note this flag can be set individually for each Payment Method
	# so Mail can have complete custom final screen, but another method
	# still able to display the complete default cart content
	# The default cart content always displays your $final_msg_var at top
	$UseCustomOnlyMsg = 1;

	# omit top navigation bar
	$OmitTopNav = 1;
	# omit bottom navigation bar
	$OmitBottomNav = 1;

	# make sure your string is always appended for the entire message
	# you can use the VarReplacer fields, and make decisions outside the text definitions add text
	$final_msg_mail .= qq~
	Payment: <b>{{global_PayType}}</b>. <br>
	~;

	# conditional
	if ($mail_customer_addr) {
	$final_msg_mail .= qq~We have emailed further instructions to : $mail_customer_addr <br>~;
	}

	# another conditional
	if ($save_invoice_html) {
	my($uri) = $save_invoice_url . $$ . $InvoiceNumber . ".html";
	$final_msg_mail .= qq~We have saved a copy of your Invoice here : <a href="$uri">$uri</a><br>~;
	}

	# add more text
	$final_msg_mail .= qq~
	<b>Print this invoice and complete Payment details below</b>.  Mail To : <br>
		<blockquote><font color="#0101FF">
		$mail_merchant_name<br>
		$merchant_addr<br>
		$merchant_csz</font>
		</blockquote>
	~;

	# even possible to even manipulate @orders from here, adding to the $final_msg_string
	# see docs on How to Process @orders array (@orders is always globally available)

	# set up table 
	$final_msg_mail .= qq~
	<p>
	<table Class="ItemTable"><tr><td align="right">
	<b>Order # {{global_InvoiceNumber}} {{global_MyDate}}</b></td></tr></table>

	<table Class="ItemTable"><tr Class="hRow">
	<td Class="hCell"><font size=1>Number Ordered</font></td>
	<td Class="hCell"><font size=1><br>Item</font></td>
	<td Class="hCell"><font size=1>Price per Item</font></td>
	<td Class="hCell"><font size=1>Item Total</font></td>
	</tr>~;
	
		# initialize vars as local
		my($pt,$tt,$p2,$p3,$p4);
		my($q,$i,$d,$p,$s,$t);

		# loop through each product
		foreach(@orders) {
	  
			# seperate out the fields
			($q,$i,$d,$p,$s,$t) = split (/$delimit/,$_);
	
				# make your own computations
				$pt = ($q * $p);

				# running total, before formatting, commify
				$tt += $pt;
	
				# format to 00.00
      				$p = sprintf "%.2f",$p;
      				$pt = sprintf "%.2f",$pt;

				# use functions from library <mofpaylib.pl>
				$p = CommifyMoney ($p);	
				$pt= CommifyMoney ($pt);	

				# apply pseudo html (if any) from item
				# $i =~ s/\[/</g;
				# $i =~ s/\]/>/g;

				# strip pseudo html (if any) from item, no pictures, etc.
 				$i =~ s/\[/</g;
				$i =~ s/\]/>/g;
  			 	$i =~ s/<([^>]|\n)*>//g;

				# start row
   				$final_msg_mail .= qq~<tr Class="aRow">~;
				# column quantity
   				$final_msg_mail .= qq~<td Class="aQtyCell">$q</td>~;
				# column item
				$final_msg_mail .= qq~<td Class="aItemCell">$i </td>~;
				# column price per item
				$final_msg_mail .= qq~<td Class="aPriceCell"> $currency $p </td> ~;
				# column total price
				$final_msg_mail .= qq~<td Class="aPriceCell"> $currency $pt </td> ~;
				# end row
   				$final_msg_mail .= "</tr>";
			}

	# end table	
	$final_msg_mail .= "</table>";

	my $trb = ($frm{'Final_Amount'} - $frm{'Deposit_Amount'});

	# now, lets format the money, numbers in the $frm{'vars'}
	$frm{'Primary_Price'} = CommifyMoney($frm{'Primary_Price'});
	$frm{'Primary_Products'} = CommifyNumbers($frm{'Primary_Products'});
	$frm{'Primary_Discount'} = CommifyMoney($frm{'Primary_Discount'});
	$frm{'Sub_Primary_Discount'} = CommifyMoney($frm{'Sub_Primary_Discount'});
	$frm{'Coupon_Discount'} = CommifyMoney($frm{'Coupon_Discount'});
	$frm{'Sub_Coupon_Discount'} = CommifyMoney($frm{'Sub_Coupon_Discount'});
	$frm{'Combined_Discount'} = CommifyMoney($frm{'Combined_Discount'});
	$frm{'Sub_Final_Discount'} = CommifyMoney($frm{'Sub_Final_Discount'});
	$frm{'Handling'} = CommifyMoney($frm{'Handling'});
	$frm{'Insurance'} = CommifyMoney($frm{'Insurance'});
	$frm{'Shipping_Amount'} = CommifyMoney($frm{'Shipping_Amount'});
	$frm{'Combined_SHI'} = CommifyMoney($frm{'Combined_SHI'});
	$frm{'Sub_SHI'} = CommifyMoney($frm{'Sub_SHI'});
	$frm{'Tax_Amount'} = CommifyMoney($frm{'Tax_Amount'});
	$frm{'Initial_Taxable_Amount'} = CommifyMoney($frm{'Initial_Taxable_Amount'});
	$frm{'Final_Amount'} = CommifyMoney($frm{'Final_Amount'});
	$frm{'Deposit_Amount'} = CommifyMoney($frm{'Deposit_Amount'});
	$frm{'Remaining_Balance'} = CommifyMoney($frm{'Remaining_Balance'});

	# display totals using a combination of VarReplacer {{vars}} & real time %frm hash vars $frm{'vars'}
	# Note: When you do tax remember that Tax can be either "BEFORE" or "AFTER" SHI, depending on your tax configs

	$final_msg_mail .= qq~
	<table Class="TotalTable">

	<tr Class="sRow1"><td Class="sText1"><br></td>
	<td Class="sText1">Number of Products Ordered $frm{'Primary_Products'} : </td><td Class="sPrice1">{{global_currency}} $frm{'Primary_Price'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">$frm{'Primary_Discount_Status'} : </td><td Class="sPrice2"><font size=4>-</font> {{global_currency}} $frm{'Primary_Discount'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">Sub Total After First Discount {{global_currency}} $frm{'Sub_Primary_Discount'} : </td><td Class="sText2"><br></td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">Discount For Coupon <b>{{Compute_Coupons}}</b> : </td><td Class="sPrice2"><font size=4>-</font> {{global_currency}} $frm{'Coupon_Discount'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">Sub Total After Coupon Discount {{global_currency}} $frm{'Sub_Final_Discount'} : </td><td Class="sText2"><br></td></tr>

	<tr Class="sRow3"><td Class="sText3"><br></td>
	<td Class="sText3">Total Discount Applied : </td><td Class="sPrice3"><font size=4>-</font> {{global_currency}} $frm{'Combined_Discount'}</td></tr>

	<tr Class="sRow1"><td Class="sText1"><br></td>
	<td Class="sText1">Sub Total After Discounts : </td><td Class="sPrice1">{{global_currency}} $frm{'Sub_Final_Discount'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">$frm{'Tax_Message'} : </td><td Class="sPrice8">{{global_currency}} $frm{'Tax_Amount'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">$frm{'Handling_Status'} : </td><td Class="sPrice8">{{global_currency}} $frm{'Handling'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">$frm{'Insurance_Status'} : </td><td Class="sPrice8">{{global_currency}} $frm{'Insurance'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">$frm{'Shipping_Message'} : </td><td Class="sPrice8">{{global_currency}} $frm{'Shipping_Amount'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">Combined Shipping, Handling & InsuranceI {{global_currency}} $frm{'Combined_SHI'} : </td><td Class="sPrice1"><br></td></tr>

	<tr Class="sRow1"><td Class="sText1"><br></td>
	<td Class="sText1">Sub Total After SH&I : </td><td Class="sPrice1">{{global_currency}} $frm{'Sub_SHI'} </td></tr>

	<tr Class="sRow9"><td Class="sText9"><br></td>
	<td Class="sText9">Final Amount Before Deposit : </td><td Class="sPrice9">{{global_currency}} $frm{'Final_Amount'} </td></tr>

	<tr Class="sRow2"><td Class="sText2"><br></td>
	<td Class="sText2">Deposit Applied : </td><td Class="sPrice2"><font size=4>-</font> {{global_currency}} $frm{'Deposit_Amount'} </td></tr>

	<tr Class="sRow9"><td Class="sText9"><br></td>
	<td Class="sText9">Remaining Balance After Deposit : </td><td Class="sPrice9">{{global_currency}} $frm{'Remaining_Balance'} </td></tr>

	</table>
	~;


	# compute alternate currencies, before formatting $tt
	# example fixed conversion rates only
	# USD, EUR, CAD, AUD (Austrailia dollars), GBP, MXN (pecos), JPY (yen), RUR (Rubles)

	my ($eur) = CommifyMoney(sprintf "%.2f",($trb * 0.879894));
	my ($cad) = CommifyMoney(sprintf "%.2f",($trb * 1.40038));
	my ($aud) = CommifyMoney(sprintf "%.2f",($trb * 1.53003));
	my ($gbp) = CommifyMoney(sprintf "%.2f",($trb * 0.618189));
	my ($mxn) = CommifyMoney(sprintf "%.2f",($trb * 10.4774));
	my ($jpy) = FormatAltMoney(sprintf "%.2f",($trb * 120.460));

	# commify the USD last so not to mess up the math above
      	($tt) = CommifyMoney(sprintf "%.2f",($trb));

	# display alternate currencies
	$final_msg_mail .= qq~
	<table Class="TotalTable">

	<tr Class="sRow8"><td colspan="2" Class="sText8"><br></td></tr>
	<tr Class="sRow8"><td colspan="3" align="right"> <b><u>Want That In Other Currencies</u></b></td></tr>

	<tr Class="sRow8"><td Class="sText8"> USD : United States Dollar </td>
	<td Class="sText8"><img src="http://www.gardenthemes.com/mofcart/usd.gif" width="22" height="16"></td>
	<td Class="sPrice8">\$ $tt</td></tr>
	<tr Class="sRow8"><td Class="sText8"> EUR : Euros Currency </td>
	<td Class="sText8"><img src="http://www.gardenthemes.com/mofcart/eur.gif" width="22" height="16"></td>
	<td Class="sPrice8">\€ $eur</td></tr>
	<tr Class="sRow8"><td Class="sText8"> CAD : Canadian Dollars </td>
	<td Class="sText8"><img src="http://www.gardenthemes.com/mofcart/cad.gif" width="22" height="16"></td>
	<td Class="sPrice8">\$ $cad</td></tr>
	<tr Class="sRow8"><td Class="sText8"> AUD : Austrailian Dollars </td>
	<td Class="sText8"><img src="http://www.gardenthemes.com/mofcart/aud.gif" width="22" height="16"></td>
	<td Class="sPrice8">\$ $aud</td></tr>
	<tr Class="sRow8"><td Class="sText8"> GBP : United Kingdom Pound </td>
	<td Class="sText8"><img src="http://www.gardenthemes.com/mofcart/gbp.gif" width="22" height="16"></td>
	<td Class="sPrice8">\£ $gbp</td></tr>
	<tr Class="sRow8"><td Class="sText8"> MXN : Mexican Peso </td>
	<td Class="sText8"><img src="http://www.gardenthemes.com/mofcart/mxn.gif" width="22" height="16"></td>
	<td Class="sPrice8">Ps $mxn</td></tr>
	<tr Class="sRow8"><td Class="sText8"> JPY : Japanese Yen </td>
	<td Class="sText8"><img src="http://www.gardenthemes.com/mofcart/jpy.gif" width="22" height="16"></td>
	<td Class="sPrice8">\¥ $jpy</td></tr>
	</table>
	~;


	# play with some of the VarReplacer {{vars}} to create a custom message
	$final_msg_mail .= qq~
	<p>Thank You, {{Ecom_BillTo_Postal_Name_First}} {{Ecom_BillTo_Postal_Name_Last}}, for you business. 
	~;

	# use a condition for piece of the message
	if ($frm{'Ecom_BillTo_Postal_Company'}) {
	$final_msg_mail .= qq~ <br>We are pleased to be serving the business needs of <b>{{Ecom_BillTo_Postal_Company}}</b>. 
	~;
	}

	# add more text
	$final_msg_mail .= qq~ <p>
	For customer service please contact us at 
	<ul> 
	<li> Phone : 1-888-888-8888
	<li> eMail : CustomerSupport\@OurSite.com
	<li> Address : Great Sales Co. of Canada, 1-500 Monarch Way, BC CA z45557
	</ul>
	<p>

	And reference the following order details
	<ol>
	<li>Invoice : <b>{{global_InvoiceNumber}}</b> 
	<li>Date of order : {{global_ShortDate}} {{global_Time}}
	<li><font size=1>Promotional Code : {{Coupon_Discount_myNumber}}</font>	
	<li><font size=1>Order ID : {{OrderID}}</font>		
	<li><font size=1>Info ID : {{InfoID}}</font>		
	</ol>

	<p>
	 Remember: you're writing in a real time sub Routine here, which can use all the power or 
	 perl and/or HTML, CSS, Javascript, etc., So almost anything goes from here. For example
	 you could easily add another FORM POST to this output for a Mail Signup List, or
	 for customer referrals (and direct to a script that logs email addresses for possible referrals)
	 then reward the customer with another Coupon Number, etc.
	
	~;

	# return the final string
	return $final_msg_mail;
	}


# Example (2) using the COD Payment Method
sub FINALMSGCOD {
	
	# In this Payment Method example we do *not* override the default Final Confirmation screen content
	# in <mof_final.pl> we are simply providing an extended customizing sub Routine for the COD Pay Method
	# so that we can perform additional computations  --  The Expected Shippment Date

	# Make expected shipping date

	my $est = 120000;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday);

	# set up estimate 
	local (@months) = ('January','February','March','April','May','June','July',
			'August','September','October','November','December');
	local (@days) = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

	if ($gmtPlusMinus) {
		($sec,$min,$hour,$mday,$mon,$year,$wday) = (gmtime(time + $gmtPlusMinus + $est));
		} else {
		($sec,$min,$hour,$mday,$mon,$year,$wday) = (localtime(time + $est))[0,1,2,3,4,5,6];
		}
		$year += 1900;	
 
	my $Date = "$days[$wday], $months[$mon] $mday, $year";
 	my $ShortDate = sprintf("%02d%1s%02d%1s%04d",$mon+1,'/',$mday,'/',$year);

	# We also do *not* block out the existing msg in <mof_final.pl> branching
	# instead simply appending to the msg already set up in <mof_final.pl>

	# make sure your string is always appended for the entire message
	# you can use the VarReplacer fields, and make decisions outside the text definitions add text
	$final_msg_cod .= qq~
	<b>EXPECTED SHIPPING DATE</b> : $Date ( $ShortDate ) ~;


	# return the final string
	return $final_msg_cod;
	}	



# Example (3) using the ON ACCOUNT Payment Method
# Write a custom Web Copy then Re-direct to it as Final Confirmation Screen
sub FINALMSGONACCT {

	# template header & footer are already loaded ** IF ** Save Web Copy is enabled in <mofpay.conf>
	# if not you'll need to load the template header / footer here using the same method that <mofpay.cgi> uses
	# or you can simply make your own custom header / footer

	# where is the HTTP addr of this custom hard copy ?
	my($uri) = $save_invoice_url . $$ . $InvoiceNumber . ".html";

	# you could also use a custom Hard Copy save sub Routine for each payment method
	# and then redirect to that saved copy .. imaginary example below will overwrite the just saved Hard Copy
		
	# Example only : Files do not exist in PKG
	# require 'mof_YourCustomHardCopy.pl';
	# &YourCustomHardCopySubRoutine;

	# re-direct to the custom hard copy just printed
	print "Location: $uri\n\n";
	
	# done (because On Account pay method was selected)
	# if another method had been selected instead, another scenario occurred
	exit;

	}


# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;
