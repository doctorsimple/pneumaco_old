# use CGI::Carp qw(fatalsToBrowser);
# ==================== MOFcart v2.5.10.21.03 ====================== #
# === SAVE WEB COPY CUSTOM ======================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Example of a custom Web  Copy of Invoice (Stored to Disk)
# It uses the exact same Custom Messages in <mofpay.conf>
# and the exact same branch conditions for Top Message as in <mofpay.cgi>
# However, you can use the branching below and customize whatever you want

sub SaveInvoiceFile {

	# buttons on left (1), default on right (0)
	my $invc_reverse_paypal = 0;
	my $invc_reverse_forms = 0;
	my $invc_reverse_gateway = 0;

	# initialize some vars
	my ($FileNumber) = $$ . $InvoiceNumber;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;
	my ($file_path_name) = $save_invoice_path . $FileNumber . ".html";

	my ($invc_msg);
	my $paypal_return_url = $file_path_name if ($use_web_copy_as_return_url);

	# top messages payment methods branches
	# the branches simply populate the Top Message

	# pay by mail
	if ($frm{'input_payment_options'} eq "MAIL") {
	$invc_msg = qq~	
	<table Class="tblTopMessage">
	<tr Class="rowTopMessage"><td>Thank You. This is a copy of your order invoice </td></tr>
	<tr><td Class="cellTopMessage">
	Print this invoice and complete Payment details below.  Mail To : 
	<blockquote>
	<font color="#0101FF">$mail_merchant_name <br>  $merchant_addr <br> $merchant_csz</font>
	</blockquote>
	Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
	Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
	</td></tr></table>
	~;


	# cod
	} elsif ($frm{'input_payment_options'} eq "COD") {
	$invc_msg = qq~	
	<table Class="tblTopMessage">
	<tr Class="rowTopMessage"><td>
	Thank You. This is a copy of your order invoice 
	</td></tr><tr><td Class="cellTopMessage">
	Payment: {{global_PayType}}. 
	COD charges may apply. Please print for your records. <p>
	Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
	Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
	</td></tr></table>
	~;


	# on account
	} elsif ($frm{'input_payment_options'} eq "ONACCT") {
	$invc_msg = qq~	
	<table Class="tblTopMessage">
	<tr Class="rowTopMessage"><td>
	Thank You. This is a copy of your order invoice 
	</td></tr><tr><td Class="cellTopMessage">
	Payment will be debited {{global_PayType}}. 
	Please print for your records. <p>
	Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
	Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
	</td></tr></table>
	~;


	# call for pay details
	} elsif ($frm{'input_payment_options'} eq "CALLME") {
	$invc_msg = qq~	
	<table Class="tblTopMessage">
	<tr Class="rowTopMessage"><td>
	Thank You. This is a copy of your order invoice 
	</td></tr><tr><td Class="cellTopMessage">
	We will call you for payment details. 
	Please print for your records.  Phone : {{customG_PhoneNumber}}. <p>
	Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
	Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
	</td></tr></table>
	~;


	# invoice is zero amt
	} elsif ($frm{'input_payment_options'} eq "ZEROPAY") {
	$invc_msg = qq~	
	<table Class="tblTopMessage">
	<tr Class="rowTopMessage"><td>
	Thank You. This is a copy of your order invoice 
	</td></tr><tr><td Class="cellTopMessage">
	No charges are associated with this invoice. 
	Please print for your records. <p>
	Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
	Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
	</td></tr></table>
	~;


	# paypal pass off	
	} elsif ($frm{'input_payment_options'} eq "PAYPAL") {
	my $invc_heading_paypal = "Payment via PayPal service was selected for this order.";
	my $invc_msg_paypal = qq~
	If you have not yet completed payment at the PayPal service site, you can do that now.
	Note: your order will not be processed and/or shipped until we receive confirmation
        from the PayPal service that your payment has been completed. 
	For more information about the PayPal Service, 
	<a Class="TextLink" href="http://www.gardenthemes.com/mofcart/pop-paypal.html" onclick="window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false" onmouseover="status='Get more PayPal information';return true\;" onmouseout="status='&nbsp';return true\;">
	click here</a>. <p>
	Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
	Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
	 ~;

	$invc_msg .= "<FORM ACTION=\"$paypal_url\" METHOD=\"POST\">\n";
	# allow _xclick or _ext-enter : 8/01
	if ($paypal_prepop) {
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"cmd\" VALUE=\"_ext-enter\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"redirect_cmd\" VALUE=\"_xclick\">\n";
	} else {
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"cmd\" VALUE=\"_xclick\">\n";
	}
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"business\" VALUE=\"$paypal_login\"> \n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"item_name\" VALUE=\"$paypal_merchant Order $InvoiceNumber On $ShortDate\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"item_number\" VALUE=\"Invoice $InvoiceNumber $ShortDate\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"amount\" VALUE=\"$Send_API_Amount\">\n";
	# new fields 8/01
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"return\" VALUE=\"$paypal_return_url\">\n" if($paypal_return_url);
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"image_url\" VALUE=\"$paypal_image_url\">\n" if($paypal_image_url);
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"cancel_return\" VALUE=\"$paypal_cancel_return\">\n" if($paypal_cancel_return);
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"no_note\" VALUE=\"$paypal_no_note\">\n" if($paypal_no_note);
	# new pre-populate options 8/01
	if ($paypal_prepop==1) {
	# use shipping addr
	$ppPhone = $frm{'Ecom_ShipTo_Telecom_Phone_Number'};
	my ($ppFirst) = $frm{'Ecom_ShipTo_Postal_Name_First'} . " " . $frm{'Ecom_ShipTo_Postal_Name_Middle'};
	my ($ppState) = $frm{'Ecom_ShipTo_Postal_StateProv'} . " " . $frm{'Ecom_ShipTo_Postal_Region'};
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"first_name\" VALUE=\"$ppFirst\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"last_name\" VALUE=\"$frm{'Ecom_ShipTo_Postal_Name_Last'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"address1\" VALUE=\"$frm{'Ecom_ShipTo_Postal_Street_Line1'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"address2\" VALUE=\"$frm{'Ecom_ShipTo_Postal_Street_Line2'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"city\" VALUE=\"$frm{'Ecom_ShipTo_Postal_City'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"state\" VALUE=\"$ppState\"> \n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"zip\" VALUE=\"$frm{'Ecom_ShipTo_Postal_PostalCode'}\">\n";
	} elsif ($paypal_prepop==2) {
	# use billing addr
	$ppPhone = $frm{'Ecom_BillTo_Telecom_Phone_Number'};
	my ($ppFirst) = $frm{'Ecom_BillTo_Postal_Name_First'} . " " . $frm{'Ecom_BillTo_Postal_Name_Middle'};
	my ($ppState) = $frm{'Ecom_BillTo_Postal_StateProv'} . " " . $frm{'Ecom_BillTo_Postal_Region'};
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"first_name\" VALUE=\"$ppFirst\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"last_name\" VALUE=\"$frm{'Ecom_BillTo_Postal_Name_Last'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"address1\" VALUE=\"$frm{'Ecom_BillTo_Postal_Street_Line1'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"address2\" VALUE=\"$frm{'Ecom_BillTo_Postal_Street_Line2'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"city\" VALUE=\"$frm{'Ecom_BillTo_Postal_City'}\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"state\" VALUE=\"$ppState\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"zip\" VALUE=\"$frm{'Ecom_BillTo_Postal_PostalCode'}\">\n";
	}
	# 8/01 phone input is nnn|nnn|nnnn only
	$ppPhone =~ s/[^0-9]//g;
	my ($ppA,$ppB,$ppC) = (substr($ppPhone,0,3),substr($ppPhone,3,3),substr($ppPhone,6,4));
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"night_phone_a\" VALUE=\"$ppA\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"night_phone_b\" VALUE=\"$ppB\">\n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"night_phone_c\" VALUE=\"$ppC\">\n";
	my($ppsubmit) = "<INPUT TYPE=\"image\" border=\"0\" SRC=\"$paypal_button\" NAME=\"submit\" ALT=\"Click here to complete Order Via PayPal\">";

	$invc_msg .= "<table Class=\"tblTopMessage\">";
	$invc_msg .= "<tr Class=\"rowTopMessage\"><td>$invc_heading_paypal</td></tr>" if ($invc_heading_paypal);
	$invc_msg .= "<tr><td Class=\"cellTopMessage\"><table Class=\"tblButton\"><tr Class=\"rowButton\">";
	$invc_msg .= "<td Class=\"cellButtonLeft\">$invc_msg_paypal</td>" unless ($invc_reverse_paypal);
	$invc_msg .= "<td Class=\"cellButtonRight\">$ppsubmit</td>" unless ($invc_reverse_paypal);
	$invc_msg .= "<td Class=\"cellButtonRight\">$ppsubmit</td>" if ($invc_reverse_paypal);
	$invc_msg .= "<td Class=\"cellButtonLeft\">$invc_msg_paypal</td>" if ($invc_reverse_paypal);
	$invc_msg .= "</tr></table></td></tr></table>";
	$invc_msg .= "</FORM>";

	# forms gateway
	} elsif ($frm{'input_payment_options'} eq "GATEWAY") {
	my $invc_heading_forms = "Payment via Forms Gateway was selected for this order.";
	my $invc_msg_forms = qq~
	If you have not yet completed payment at the Gateway site, you can do that now. 
	Note: your order will not be processed and/or shipped until we receive confirmation
        from the Gateway service that your payment has been completed. 
	For more information about this Service, 
	<a Class="TextLink" href="http://www.gardenthemes.com/mofcart/pop-forms-service.html" onclick="window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false" onmouseover="status='Get more PayPal information';return true\;" onmouseout="status='&nbsp';return true\;">
	click here</a>. <p>
	Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
	Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
	 ~;

	# CUSTOM <FORM> GATEWAY BEGIN CODE ---------------->
	# Insert your custom gateway <FORM></FORM> code here
	# See docs file: Final Invoice Variables.html for list of vars available
	# You must start a <FORM> and close </FORM> the form in your custom code
	$invc_msg .= "<FORM ACTION=\"---URL-TO-POST-TO----\" METHOD=\"POST\"> \n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"---RETURN-URL---\" VALUE=\"$gateway_return_url\"> \n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"---INVOICE-NUM---\" VALUE=\"Order $InvoiceNumber On $ShortDate\"> \n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"---FINAL-AMOUNT---\" VALUE=\"$Send_API_Amount\"> \n";

	# preserve this or make your own custom message here:
	my($gtsubmit) = "<input type=submit value=\"Payment $currency $Send_API_Amount\">";
	$invc_msg .= "<table Class=\"tblTopMessage\">";
	$invc_msg .= "<tr Class=\"rowTopMessage\"><td>$invc_heading_forms</td></tr>" if ($invc_heading_forms);
	$invc_msg .= "<tr><td Class=\"cellTopMessage\"><table Class=\"tblButton\"><tr Class=\"rowButton\">";
	$invc_msg .= "<td Class=\"cellButtonLeft\">$invc_msg_forms</td>" unless ($invc_reverse_forms);
	$invc_msg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" unless ($invc_reverse_forms);
	$invc_msg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" if ($invc_reverse_forms);
	$invc_msg .= "<td Class=\"cellButtonLeft\">$invc_msg_forms</td>" if ($invc_reverse_forms);
	$invc_msg .= "</tr></table></td></tr></table>";
	$invc_msg .= "</FORM>\n\n";
	# CUSTOM </FORM> GATEWAY END CODE <-----------------

	} else {
		
		# custom full gateway
		if ($use_gateway_mof) {
		my $invc_heading_gateway = "You selected Payment using {{global_PayType}}.";
		my $invc_msg_gateway = qq~
		If you have not yet completed payment, you can do that now. 
		Note: your order will not be processed and/or shipped until we receive confirmation
       		that your payment has been completed. 
		For more information about this Service, 
		<a Class="TextLink" href="http://www.gardenthemes.com/mofcart/pop-gateway.html" onclick="window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false" onmouseover="status='Get more PayPal information';return true\;" onmouseout="status='&nbsp';return true\;">
		click here</a>. <p>
		Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
		Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
		 ~;

		# CUSTOM FULL GATEWAY BEGIN CODE ---------------->
		# Insert your custom gateway <FORM></FORM> code here
		# See docs file: Final Invoice Variables.html for list of vars available
		# You must start a <FORM> and close </FORM> the form in your custom code
		# Note: This gateway assumes that MOFcart will collect cc/check info via SSL
		$invc_msg .= "<FORM ACTION=\"---URL-TO-POST-TO----\" METHOD=\"POST\"> \n";
		$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"---RETURN-URL---\" VALUE=\"$gateway_return_url\"> \n";
		$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"---INVOICE-NUM---\" VALUE=\"$InvoiceNumber\"> \n";
		$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"---FINAL-AMOUNT---\" VALUE=\"$Send_API_Amount\"> \n";

		# preserve this or make your own custom message here:
		my($gtsubmit) = "<input type=submit value=\"Authorize $currency $Send_API_Amount\">";
		$invc_msg .= "<table Class=\"tblTopMessage\">";
		$invc_msg .= "<tr Class=\"rowTopMessage\"><td>$invc_heading_gateway</td></tr>" if ($invc_heading_gateway);
		$invc_msg .= "<tr><td Class=\"cellTopMessage\"><table Class=\"tblButton\"><tr Class=\"rowButton\">";
		$invc_msg .= "<td Class=\"cellButtonLeft\">$invc_msg_gateway</td>" unless ($invc_reverse_gateway);
		$invc_msg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" unless ($invc_reverse_gateway);
		$invc_msg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" if ($invc_reverse_gateway);
		$invc_msg .= "<td Class=\"cellButtonLeft\">$invc_msg_gateway</td>" if ($invc_reverse_gateway);
		$invc_msg .= "</tr></table></td></tr></table>";

		$invc_msg .= "</FORM>\n\n";
		# CUSTOM FULL GATEWAY END CODE <-----------------

		# online check
		} elsif ($check_check) {
		$invc_msg = qq~	
		<table Class="tblTopMessage">
		<tr Class="rowTopMessage"><td>
		Thank You. This is a copy of your order invoice 
		</td></tr><tr><td Class="cellTopMessage">
		Payment by {{global_PayType}}. 
		Please print for your records. 
		Bank Name : {{Check_Bank_Name}}. <p>
		Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
		Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
		</td></tr></table>
		~;


		# credit card
		} elsif ($card_check) {
		$invc_msg = qq~	
		<table Class="tblTopMessage">
		<tr Class="rowTopMessage"><td>
		Thank You. This is a copy of your order invoice 
		</td></tr><tr><td Class="cellTopMessage">
		Payment by {{global_PayType}}. 
		Please print for your records. 
		Please Note charges from <strong>$mail_merchant_name</strong> on your {{global_PayType}} statement. <p>
		Customer Service : <b>$mail_return_addr</b> or <b>$merchant_phone</b> <br>
		Please refer to Invoice Number <b>{{global_InvoiceNumber}}</b> in all communication.
		</td></tr></table>
		~;



		}
	}


# set up the rest of the custom Web Copy of Invoice

# use only the [ qq~ ~; ] enclosure as in the examples below. You can use *any* valid html,
# added CSS, javascript, images, pop up links, and even robust variable replacements in your  messages
# For a detail list of available Variables for replacement in your messages refer to the Docs
# You can use any of the replacement VARs in both the Header and/or the Text Message
# You will need to Escape some chars .. \@  for Sales\@OurSite.com
# But almost all chars used within the [ qq ] format need *not* be escaped, including quotes, double quotes
# Use the <mofstyle.css> CSS settings for the <TABLE><TR><TD> surrounding the message for added customizing

# you use the existing computations amounts found in the VarReplacer {{variables}}
# You can refer to any of the VarReplacer variables in the RAW as   $frm{'variable'}
# example : You can use the VarReplacer to substitute {{Tax_Amount}} in your message
# example : but call the RAW number for computation with   $frm{'Tax_Amount'}
# example: both contain the same number, but you can't perform operations on a VarReplacer

# Please Note: this example for currencies does *not* include computations
# for Tax, Shipping, Handling, Insurance, Discounts, etc. that the MOFcart front end provide
# Those can certainly be added into this example, however

# make sure your string is always appended for the entire message you can 
# use the VarReplacer fields, and make decisions outside the text definitions add text

# even possible to even manipulate @orders from here, adding to the $invc_msg_string
# see docs on How to Process @orders array (@orders is always globally available)

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

	# set up table 
	$invc_msg .= qq~

	<p>
	Invoice Number : <b>{{global_InvoiceNumber}}</b><br>
	Date of Order : {{global_ShortDate}} : {{global_Time}}<br>
	Shipping Method : {{Shipping_Message}} <br>
	Estimated Shipping Date : $Date ( $ShortDate ) <p>
	<ul><u>Possibilities for dynamic web copy useage</u> : 
	<li>Dynamic Download Location for Electronic Deliverables : <br>
	<li>Dynamic user : pswd for access to DL location <br>
	<li>And/or have script generate a specific PKG by filename for Download
	<li>Best alternative for IPN, downloads, etc. is to just store to dB, then make message from the dB data
		customer is provided a web GUI with logon info mailed to them to access the DL location, etc.
	</ul>
	<p>

	# table headings
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
   				$invc_msg .= qq~<tr Class="aRow">~;
				# column quantity
   				$invc_msg .= qq~<td Class="aQtyCell">$q</td>~;
				# column item
				$invc_msg .= qq~<td Class="aItemCell">$i </td>~;
				# column price per item
				$invc_msg .= qq~<td Class="aPriceCell"> $currency $p </td> ~;
				# column total price
				$invc_msg .= qq~<td Class="aPriceCell"> $currency $pt </td> ~;
				# end row
   				$invc_msg .= "</tr>";
			}

	# end table	
	$invc_msg .= "</table>";

	# compute alternate currencies, before formatting $tt
	# example fixed conversion rates only
	# USD, EUR, CAD, AUD (Austrailia dollars), GBP, MXN (pecos), JPY (yen), RUR (Rubles)
      	($tt) = CommifyMoney(sprintf "%.2f",($tt));
	my ($eur) = CommifyMoney(sprintf "%.2f",($tt * 0.879894));
	my ($cad) = CommifyMoney(sprintf "%.2f",($tt * 1.40038));
	my ($aud) = CommifyMoney(sprintf "%.2f",($tt * 1.53003));
	my ($gbp) = CommifyMoney(sprintf "%.2f",($tt * 0.618189));
	my ($mxn) = CommifyMoney(sprintf "%.2f",($tt * 10.4774));
	my ($jpy) = FormatAltMoney(sprintf "%.2f",($tt * 120.460));

	# display totals
	$invc_msg .= qq~
	<table Class="TotalTable">
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


	# End message set up
	# now run it through the VarReplacer and print out to FILE
	$invc_msg = &VarReplacer($invc_msg);

	unless (open (INVC,">$file_path_name") ) { 
		$ErrMsg = "Unable to Create HTML Invoice File: $frm{'OrderID'}";
		&ErrorMessage($ErrMsg);
		}

		print INVC "@header";
		print INVC "$invc_msg";
		print INVC "@footer";
		
		close(INVC);
		chmod (0777, $file_path_name) if ($set_ssl_chmod);

	}

# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;
