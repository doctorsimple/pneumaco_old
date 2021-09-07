# ==================== MOFcart v2.5.10.21.03 ====================== #
# === CUSTOM EXAMPLE : FINAL ORDER CONFIRMATION SCREEN ============ #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Custom Final Confirmation Screen <mof_finalcust.pl>
# Called by <mofpay.cgi> as set <mofpay.conf> $mof_final_pg = 'mof_finalcust.pl';
# You can use any of the listed VarReplacer variables in this file
# And/or you can use any of the existing raw variables in the script at this point
# Major Sections of this sub Routine:
	# (1) Branching for Payment Method Top Messages
	# (2) Top Navigation options
	# (3) Custom Content for Final Confirmation screen
	# (4) Bottom Navigation options

# PAYMENT ACCEPTED 
sub PaymentAccepted {
	my (@list) = ();
	my ($nav_top,$nav_bottom) = (0,0);
	my ($FinalProducts) = CommifyNumbers ($frm{'Primary_Products'});
	my ($FinalAmount) = CommifyMoney ($frm{'Final_Amount'});
	my($gateway_return_url) = $save_invoice_url . $$ . $InvoiceNumber . ".html" if ($save_invoice_html);
	my ($key,$val,$li,$lk,$lv,$msg_status,$line,$qty,$item,$desc,$price,
		$ship,$taxit,$totalprice,$totalqnty,$temprice,$DiscountOne,
		$DiscountTwo,$CombinedDiscount,$SubDiscount,$HandlingCharge,
		$InsuranceCharge,$ShippingCharge,$TaxCharge,$msg_tab,
		$msg_tab_ck,$check_additional,$mail_msg,$save_msg,$save_url,
		$ship_msg,$bill_msg,$receipt_msg,$topMsg);
	$msg_status = "$FinalProducts Items " if ($frm{'Primary_Products'} > 1);
	$msg_status = "$FinalProducts Item " if ($frm{'Primary_Products'} == 1);
	$msg_status .= " $currency $Display_Payment_Amount";

	# (1) Branching for Payment Method Top Messages
	# (1) Branching for Payment Method Top Messages

	# (1.1) pay by mail
	if ($frm{'input_payment_options'} eq "MAIL") {
	$final_heading_mail = &VarReplacer($final_heading_mail);
	$final_msg_mail = &VarReplacer($final_msg_mail);
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_mail</td></tr>" if ($final_heading_mail);
	$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_mail</td></tr></table>";

	# (1.2) cod
	} elsif ($frm{'input_payment_options'} eq "COD") {
	$final_heading_cod = &VarReplacer($final_heading_cod);
	$final_msg_cod = &VarReplacer($final_msg_cod);
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_cod</td></tr>" if ($final_heading_cod);
	$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_cod</td></tr></table>";

	# (1.3) on account
	} elsif ($frm{'input_payment_options'} eq "ONACCT") {
	$final_heading_onacct = &VarReplacer($final_heading_onacct);
	$final_msg_onacct = &VarReplacer($final_msg_onacct);
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_onacct</td></tr>" if ($final_heading_onacct);
	$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_onacct";
	$topMsg .= "</td></tr></table>";

	# (1.4) call for pay details
	} elsif ($frm{'input_payment_options'} eq "CALLME") {
	$final_heading_call = &VarReplacer($final_heading_call);
	$final_msg_call = &VarReplacer($final_msg_call);
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_call</td></tr>" if ($final_heading_call);
	$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_call</td></tr></table>";

	# (1.5) invoice is zero amt
	} elsif ($frm{'input_payment_options'} eq "ZEROPAY") {
	$final_heading_zero = &VarReplacer($final_heading_zero);
	$final_msg_zero = &VarReplacer($final_msg_zero);
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_zero</td></tr>" if ($final_heading_zero);
	$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_zero</td></tr></table>";

	# (1.6) paypal pass off	
	} elsif ($frm{'input_payment_options'} eq "PAYPAL") {
	$final_heading_paypal = &VarReplacer($final_heading_paypal);
	$final_msg_paypal = &VarReplacer($final_msg_paypal);
	$paypal_return_url = $save_invoice_url . $$ . $InvoiceNumber . ".html" if ($use_web_copy_as_return_url);
	$topMsg .= "<FORM ACTION=\"$paypal_url\" METHOD=\"POST\">\n";
	# allow _xclick or _ext-enter : 8/01
	if ($paypal_prepop) {
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"cmd\" VALUE=\"_ext-enter\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"redirect_cmd\" VALUE=\"_xclick\">\n";
	} else {
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"cmd\" VALUE=\"_xclick\">\n";
	}
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"business\" VALUE=\"$paypal_login\"> \n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"item_name\" VALUE=\"$paypal_merchant Order $InvoiceNumber On $ShortDate\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"item_number\" VALUE=\"Invoice $InvoiceNumber $ShortDate\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"amount\" VALUE=\"$Send_API_Amount\">\n";
	# new fields 8/01
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"return\" VALUE=\"$paypal_return_url\">\n" if($paypal_return_url);
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"image_url\" VALUE=\"$paypal_image_url\">\n" if($paypal_image_url);
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"cancel_return\" VALUE=\"$paypal_cancel_return\">\n" if($paypal_cancel_return);
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"no_note\" VALUE=\"$paypal_no_note\">\n" if($paypal_no_note);
	# new pre-populate options 8/01
	if ($paypal_prepop==1) {
	# use shipping addr
	$ppPhone = $frm{'Ecom_ShipTo_Telecom_Phone_Number'};
	my ($ppFirst) = $frm{'Ecom_ShipTo_Postal_Name_First'} . " " . $frm{'Ecom_ShipTo_Postal_Name_Middle'};
	my ($ppState) = $frm{'Ecom_ShipTo_Postal_StateProv'} . " " . $frm{'Ecom_ShipTo_Postal_Region'};
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"first_name\" VALUE=\"$ppFirst\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"last_name\" VALUE=\"$frm{'Ecom_ShipTo_Postal_Name_Last'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"address1\" VALUE=\"$frm{'Ecom_ShipTo_Postal_Street_Line1'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"address2\" VALUE=\"$frm{'Ecom_ShipTo_Postal_Street_Line2'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"city\" VALUE=\"$frm{'Ecom_ShipTo_Postal_City'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"state\" VALUE=\"$ppState\"> \n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"zip\" VALUE=\"$frm{'Ecom_ShipTo_Postal_PostalCode'}\">\n";
	} elsif ($paypal_prepop==2) {
	# use billing addr
	$ppPhone = $frm{'Ecom_BillTo_Telecom_Phone_Number'};
	my ($ppFirst) = $frm{'Ecom_BillTo_Postal_Name_First'} . " " . $frm{'Ecom_BillTo_Postal_Name_Middle'};
	my ($ppState) = $frm{'Ecom_BillTo_Postal_StateProv'} . " " . $frm{'Ecom_BillTo_Postal_Region'};
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"first_name\" VALUE=\"$ppFirst\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"last_name\" VALUE=\"$frm{'Ecom_BillTo_Postal_Name_Last'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"address1\" VALUE=\"$frm{'Ecom_BillTo_Postal_Street_Line1'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"address2\" VALUE=\"$frm{'Ecom_BillTo_Postal_Street_Line2'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"city\" VALUE=\"$frm{'Ecom_BillTo_Postal_City'}\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"state\" VALUE=\"$ppState\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"zip\" VALUE=\"$frm{'Ecom_BillTo_Postal_PostalCode'}\">\n";
	}
	# 8/01 phone input is nnn|nnn|nnnn only
	$ppPhone =~ s/[^0-9]//g;
	my ($ppA,$ppB,$ppC) = (substr($ppPhone,0,3),substr($ppPhone,3,3),substr($ppPhone,6,4));
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"night_phone_a\" VALUE=\"$ppA\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"night_phone_b\" VALUE=\"$ppB\">\n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"night_phone_c\" VALUE=\"$ppC\">\n";
	my($ppsubmit) = "<INPUT TYPE=\"image\" border=\"0\" SRC=\"$paypal_button\" NAME=\"submit\" ALT=\"Click here to complete Order Via PayPal\">";
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_paypal</td></tr>" if ($final_heading_paypal);
	$topMsg .= "<tr><td Class=\"cellTopMessage\"><table Class=\"tblButton\"><tr Class=\"rowButton\">";
	$topMsg .= "<td Class=\"cellButtonLeft\">$final_msg_paypal</td>" unless ($final_reverse_paypal);
	$topMsg .= "<td Class=\"cellButtonRight\">$ppsubmit</td>" unless ($final_reverse_paypal);
	$topMsg .= "<td Class=\"cellButtonRight\">$ppsubmit</td>" if ($final_reverse_paypal);
	$topMsg .= "<td Class=\"cellButtonLeft\">$final_msg_paypal</td>" if ($final_reverse_paypal);
	$topMsg .= "</tr></table></td></tr></table>";
	$topMsg .= "</FORM>";

	# (1.7) forms gateway
	} elsif ($frm{'input_payment_options'} eq "GATEWAY") {
	$final_heading_forms = &VarReplacer($final_heading_forms);
	$final_msg_forms = &VarReplacer($final_msg_forms);

	# CUSTOM <FORM> GATEWAY BEGIN CODE ---------------->
	# Insert your custom gateway <FORM></FORM> code here
	# See docs file: Final Invoice Variables.html for list of vars available
	# You must start a <FORM> and close </FORM> the form in your custom code
	$topMsg .= "<FORM ACTION=\"---URL-TO-POST-TO----\" METHOD=\"POST\"> \n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"---RETURN-URL---\" VALUE=\"$gateway_return_url\"> \n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"---INVOICE-NUM---\" VALUE=\"Order $InvoiceNumber On $ShortDate\"> \n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"---FINAL-AMOUNT---\" VALUE=\"$Send_API_Amount\"> \n";

	# preserve this or make your own custom message here:
	my($gtsubmit) = "<input type=submit value=\"Payment $currency $Send_API_Amount\">";
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_forms</td></tr>" if ($final_heading_forms);
	$topMsg .= "<tr><td Class=\"cellTopMessage\"><table Class=\"tblButton\"><tr Class=\"rowButton\">";
	$topMsg .= "<td Class=\"cellButtonLeft\">$final_msg_forms</td>" unless ($final_reverse_forms);
	$topMsg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" unless ($final_reverse_forms);
	$topMsg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" if ($final_reverse_forms);
	$topMsg .= "<td Class=\"cellButtonLeft\">$final_msg_forms</td>" if ($final_reverse_forms);
	$topMsg .= "</tr></table></td></tr></table>";
	$topMsg .= "</FORM>\n\n";
	# CUSTOM </FORM> GATEWAY END CODE <-----------------

	} else {
		
		# (1.8) custom full gateway
		if ($use_gateway_mof) {
		$final_heading_gateway = &VarReplacer($final_heading_gateway);
		$final_msg_gateway = &VarReplacer($final_msg_gateway);

		# CUSTOM FULL GATEWAY BEGIN CODE ---------------->
		# Insert your custom gateway <FORM></FORM> code here
		# See docs file: Final Invoice Variables.html for list of vars available
		# You must start a <FORM> and close </FORM> the form in your custom code
		# Note: This gateway assumes that MOFcart will collect cc/check info via SSL
		$topMsg .= "<FORM ACTION=\"---URL-TO-POST-TO----\" METHOD=\"POST\"> \n";
		$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"---RETURN-URL---\" VALUE=\"$gateway_return_url\"> \n";
		$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"---INVOICE-NUM---\" VALUE=\"$InvoiceNumber\"> \n";
		$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"---FINAL-AMOUNT---\" VALUE=\"$Send_API_Amount\"> \n";

		# preserve this or make your own custom message here:
		my($gtsubmit) = "<input type=submit value=\"Authorize $currency $Send_API_Amount\">";
		$topMsg .= "<table Class=\"tblTopMessage\">";
		$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_gateway</td></tr>" if ($final_heading_gateway);
		$topMsg .= "<tr><td Class=\"cellTopMessage\"><table Class=\"tblButton\"><tr Class=\"rowButton\">";
		$topMsg .= "<td Class=\"cellButtonLeft\">$final_msg_gateway</td>" unless ($final_reverse_gateway);
		$topMsg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" unless ($final_reverse_gateway);
		$topMsg .= "<td Class=\"cellButtonRight\">$gtsubmit</td>" if ($final_reverse_gateway);
		$topMsg .= "<td Class=\"cellButtonLeft\">$final_msg_gateway</td>" if ($final_reverse_gateway);
		$topMsg .= "</tr></table></td></tr></table>";

		$topMsg .= "</FORM>\n\n";
		# CUSTOM FULL GATEWAY END CODE <-----------------

		# (1.9) online check
		} elsif ($check_check) {
		# Note: $Send_API_Amount is always Final Amount for raw number
		# Note: $Display_Payment_Amount is the formatted Final Amount
		$final_heading_check = &VarReplacer($final_heading_check);
		$final_msg_check = &VarReplacer($final_msg_check);
		$topMsg .= "<table Class=\"tblTopMessage\">";
		$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_check</td></tr>" if ($final_heading_check);
		$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_check</td></tr></table>";

		# (1.10) credit card
		} elsif ($card_check) {
		# Note: $Send_API_Amount is always Final Amount for raw number
		# Note: $Display_Payment_Amount is the formatted Final Amount
		$final_heading_card = &VarReplacer($final_heading_card);
		$final_msg_card = &VarReplacer($final_msg_card);
		$topMsg .= "<table Class=\"tblTopMessage\">";
		$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_card</td></tr>" if ($final_heading_card);
		$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_card</td></tr></table>";

		}
	}

	# strip print to $out .= : August 11, 2003 1:07:02 AM
	# (2) Top Navigation options
	# (2) Top Navigation options

	$nav_top++ if ($menu_home_top);
	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_help_top);
	# changed menus : v2.5 Top Navigation : Order Confirmation Pg
	if ($nav_top && $includeOrderConfirmation) {
	my ($tblCSS,$tdCSS) = ('tblTopPreviousNav','tdTopPreviousNav') if ($twoTopTables);
	my ($tblCSS,$tdCSS) = ('tblTopNav','tdTopNav') unless ($twoTopTables);
	$out .= "<table Class=\"$tblCSS\"><tr>";

	# help / home
	if ($menu_previous_top or $menu_viewcart_top or $menu_help_top or $menu_home_top) {
	$out .= "<td Class=\"$tdCSS\">$menu_help_top</td>\n" if ($menu_help_top); 
	$out .= "<td Class=\"$tdCSS\">$menu_home_top</td>\n" if ($menu_home_top);
	# previous pg
	if ($menu_previous_top) {
	$out .= "<td Class=\"$tdCSS\">";
	$out .= "<a Class=\"TopPreviousLink\" " if ($twoTopTables);
	$out .= "<a Class=\"TopNavLink\" " unless ($twoTopTables);
	$out .= "href=\"$frm{'previouspage'}\" ";
	$out .= "onmouseover=\"status='$menu_previous_top_status';return true\;\" ";
	$out .= "onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$menu_previous_top" unless($menu_previous_top_btn);
	$out .= "<input Class=\"$menu_previous_top_btn\" type=\"button\" value=\"Shopping\" onclick=\"window.open('$frm{'previouspage'}','MAIN')\"\;>" if ($menu_previous_top_btn);
	$out .= "</a></td>\n" ;
	}
	}
	# no more functions
	$out .= "</tr></table>\n";
	}

	# (3) Custom Content for Final Confirmation screen
	# (3) Custom Content for Final Confirmation screen

	# This area allows you to customize in almost an unlimited way, the final confirmation screen
	# use only the [ qq~ ~; ] enclosure as in the examples below. You can use *any* valid html,
	# added CSS, javascript, images, pop up links, and even robust variable replacements in your  messages
	# For a detail list of available Variables for replacement in your messages refer to the Docs
	# You can use any of the replacement VARs in both the Header and/or the Text Message
	# You will need to Escape some chars .. \@  for Sales\@OurSite.com
	# But almost all chars used within the [ qq ] format need *not* be escaped, including quotes, double quotes
	# You can refer to any existing variables active at this point in the script ..
	# You can refer to any of the vars directly as part of the %frm hash : $frm{'NAME'}
	# --or you can use the VarReplacer shceme for replacement VARs {{VARNAME}}
	# You can refer to any VARiable that appears in the Conf file by direct name: $currency
	# Use the <mofstyle.css> CSS settings for the <TABLE><TR><TD> surrounding the message for added customizing
	# *Do Not* include a Top Message in the Final template <mofconfirmation.html> 
	# but let the dynamic message definitions below create final order confirmation messages

	# the custom example provides a set aside area where you can tie in your own perl
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
	# understand what is happening in the program flow of <mofpay.cgi>.
	# Basically at this point the only two functions that are not yet performed are the Mail messages to Customer and Merchant
	# You can also re position the &PaymentAccepted call in the program flow <mofpay.cgi>
	# as the last item before the "# End Program Flow" and your sub ROUTINE will be the very last function
	# If your sub ROUTINE gets too big for the CONF file, then just put it in its own file and require it when <mofpay.cgi> loads
	# Put a unique CSS for the <mofconfirmation.html> and set up your completely unique final page design

	# Yet another way to customize the Final confirmation message is to simply construct a custom
	# Web Copy invoice file, then just insert a RE-DIRECT to the Saved URL instead of printing
	# the &PaymentAccepted routine

	# Please Note: this example for currencies does *not* include computations
	# for Tax, Shipping, Handling, Insurance, Discounts, etc. that the MOFcart front end provide
	# Those can certainly be added into this example, however

	# custom content

	$out .= qq~
	This is an example sub Routine of a custom Final Order Confirmation Screen <br>
	This is an example sub Routine of a custom Final Order Confirmation Screen <br>
	This is an example sub Routine of a custom Final Order Confirmation Screen <br>
	This is an example sub Routine of a custom Final Order Confirmation Screen <br>
	This is an example sub Routine of a custom Final Order Confirmation Screen <br>
	This is an example sub Routine of a custom Final Order Confirmation Screen <br>
	~;


	# (4) Bottom Navigation options
	# (4) Bottom Navigation options

	# changed menus : v2.5 Bottom Navigation : Confirmation Pg
	if ($includeOrderConfirmationBottom) {
	my ($tblCSS,$tdCSS) = ('tblBottomPreviousNav','tdBottomPreviousNav') if ($twoBottomTables);
	my ($tblCSS,$tdCSS) = ('tblBottomNav','tdBottomNav') unless ($twoBottomTables);
	$out .= "<p><table Class=\"$tblCSS\"><tr>\n";
	# help / home
	if ($menu_previous_bottom or $menu_viewcart_bottom or $menu_help_bottom or $menu_home_bottom) {
	$out .= "<td Class=\"$tdCSS\">$menu_help_bottom</td>\n" if ($menu_help_bottom); 
	$out .= "<td Class=\"$tdCSS\">$menu_home_bottom</td>\n" if ($menu_home_bottom);
	# previous pg
	if ($menu_previous_bottom) {
	$out .= "<td Class=\"$tdCSS\">";
	$out .= "<a Class=\"BottomPreviousLink\" " if ($twoBottomTables);
	$out .= "<a Class=\"BottomNavLink\" " unless ($twoBottomTables);
	$out .= "href=\"$frm{'previouspage'}\" ";
	$out .= "onmouseover=\"status='$menu_previous_bottom_status';return true\;\" ";
	$out .= "onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$menu_previous_bottom" unless($menu_previous_bottom_btn);
	$out .= "<input Class=\"$menu_previous_bottom_btn\" type=\"button\" value=\"Shopping\" onclick=\"window.open('$frm{'previouspage'}','MAIN')\"\;>" if ($menu_previous_bottom_btn);
	$out .= "</a></td>\n" ;
	}}
	# no more functions
	$out .= "</tr></table>\n";
	}
	# YOU CAN PUT A SIMPLE <IMG SRC..> AFFILIATE [GET] LINK HERE -- Example
	# The variable [$Send_API_Amount] is the Final amount after all computations (deposit if used)
	# $out .= "<IMG SRC=\"http://www.YOUR-AFFILIATE/PROGRAM/SCRIPT/sale.cgi?cashflow=$Send_API_Amount\" border=0> ";
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$topMsg <p>";
	print "$out \n\n";
	print "@footer \n\n";
	}

# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;
