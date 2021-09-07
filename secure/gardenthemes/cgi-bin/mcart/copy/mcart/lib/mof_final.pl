# ==================== MOFcart v2.5.02.20.04 ====================== #
# === FINAL ORDER CONFIRMATION SCREEN ============================= #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Default Final Confirmation Screen <mof_final.pl>
# Called by <mofpay.cgi> as set <mofpay.conf> $mof_final_pg = 'mof_final.pl';
# You can use a custom file by another file name if you want
# Note: if you construct a custom final file, be aware there is a lot
# of subtle programming that must go into this file to make sure it is sound
# You can use any of the listed VarReplacer variables in this file
# And/or you can use any of the existing raw variables in the script at this point
# It is also pretty simple to insert a seperate sub Routine file for each of the Payment Methods
# for that see the examples in the <mof_finalsub.pl> & embedded notes in sec 1.1 & 1.2 this file
# Major Sections of this sub Routine:
	# (1) Branching for Payment Method Top Messages
	# (2) Top Navigation options
	# (3) Top Tabs Shipping & Billing Addr
	# (4) Cart Content
	# (5) Cart Line Item Totals
	# (6) Display Extra Information
	# (7) Bottom Navigation options

# PAYMENT ACCEPTED 
sub PaymentAccepted {
	$out = "";
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

	# enable the next 2 lines to explorer the <mof_finalsub.pl> examples
	# (1) you'll need to require the <mof_finalsub.pl> which has the referenced sub Routines
	# (2) then you can call your custom sub Routine for the Mailing Payment Option
	# require 'mof_finalsub.pl';
	# $final_msg_mail = &FINALMSGMAIL();
	# if you use a custom sub Routine (example above 2 lines) then leave this line in place
	# so that your custom sub Routine can continue to use the VarReplacer
	$final_msg_mail = &VarReplacer($final_msg_mail);
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_mail</td></tr>" if ($final_heading_mail);
	$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_mail</td></tr></table>";

	# (1.2) cod
	} elsif ($frm{'input_payment_options'} eq "COD") {
	$final_heading_cod = &VarReplacer($final_heading_cod);

	# enable the next 2 lines to explorer the <mof_finalsub.pl> examples
	# (1) you'll need to require the <mof_finalsub.pl> which has the referenced sub Routines
	# (2) then you can call your custom sub Routine for the COD Payment Option
	# require 'mof_finalsub.pl';
	# $final_msg_cod = &FINALMSGCOD();
	# if you use a custom sub Routine (example above 2 lines) then leave this line in place
	# so that your custom sub Routine can continue to use the VarReplacer
	$final_msg_cod = &VarReplacer($final_msg_cod);
	$topMsg .= "<table Class=\"tblTopMessage\">";
	$topMsg .= "<tr Class=\"rowTopMessage\"><td>$final_heading_cod</td></tr>" if ($final_heading_cod);
	$topMsg .= "<tr><td Class=\"cellTopMessage\">$final_msg_cod</td></tr></table>";

	# (1.3) on account
	} elsif ($frm{'input_payment_options'} eq "ONACCT") {

	# enable the next 2 lines to explorer the <mof_finalsub.pl> examples
	# (1) you'll need to require the <mof_finalsub.pl> which has the referenced sub Routines
	# (2) then you can call your custom sub Routine for the On Account Payment Option
	# In this custom example for (mof_finalsub.pl> we use a custom sub Routine
	# to print a custom Web Copy then a Redirect to it as Final Confirmation Screen
	# The sub routine does a redirect & exit so nothing after the sub Routine call executes
	# require 'mof_finalsub.pl';
	# $final_msg_onacct = &FINALMSGONACCT();
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
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"currency_code\" VALUE=\"$paypal_currency_code\"> \n";
	$topMsg .= "<INPUT TYPE=\"hidden\" NAME=\"lc\" VALUE=\"$paypal_lang_code\"> \n";
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
	unless ($OmitTopNav) {
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
	}}

	# (3) Top Tabs Shipping & Billing Addr
	# (3) Top Tabs Shipping & Billing Addr

	# CSS replacement : confirmation screen
	# The $UseCustomOnlyMsg switch is an option to bypass everything in this
	# Default Final Order Confirmation Screen between the Top Nav and Bottom Nav
	# If you have both Navs disabled for Final Screen, then only Header & Footer print
	# The switch is used for custom sub Routines to switch off the default cart content
	# So that the custom sub Routine can display only its content
	unless ($UseCustomOnlyMsg) {
	my($y) = "$MyDate";
	my($x) = "<br>Order ID: $frm{'OrderID'}" if ($show_order_id);;
	if ($frm{'Allow_Shipping'}) {
	$msg_tab = "SHIP TO:" ;	
	} elsif ($frm{'Allow_Tax'}) {
	$msg_tab = "$taxstring AREA:"
	} else {
	$msg_tab = "ORDER INFORMATION:" ;	
	$msg_tab .= "$msg_status"
	}
	$out .= "<table Class=\"tblInvc\"><tr Class=\"trInvcTop\"><td Class=\"tdInvcLeftTop\">";
	$out .= "Invoice: $InvoiceNumber</td><td Class=\"tdInvcRightTop\">$y $x </td></tr>";
	$out .= "<tr Class=\"trInvcAddr\"><td Class=\"tdInvcLeftAddr\"><span Class=\"tabMsg\">$msg_tab</span><br>";
	$msg_tab_ck = 0;
	if ($frm{'Ecom_ShipTo_Postal_Name_Prefix'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Name_Prefix'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_First'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Name_First'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_Middle'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Name_Middle'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_Last'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Name_Last'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_Suffix'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Name_Suffix'} ";
	$msg_tab_ck++;}
	$out .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_ShipTo_Postal_Company'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Company'} <br>"}
	if ($frm{'Ecom_ShipTo_Postal_Street_Line1'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Street_Line1'} <br>"}
	if ($frm{'Ecom_ShipTo_Postal_Street_Line2'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_Street_Line2'} <br>"}
	if ($frm{'Ecom_ShipTo_Postal_City'}) {
	$out .= "$frm{'Ecom_ShipTo_Postal_City'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_StateProv'}) {
	unless ($frm{'Ecom_ShipTo_Postal_StateProv'} eq "NOTINLIST") {
	my ($sc) = $frm{'Ecom_ShipTo_Postal_StateProv'};
	$sc =~ s/-/ /g;
	$out .= "$sc  ";
	$msg_tab_ck++;
	}}
	if ($frm{'Ecom_ShipTo_Postal_Region'}) {
	$out .= "  $frm{'Ecom_ShipTo_Postal_Region'} ";
	$msg_tab_ck++}
	if ($frm{'Ecom_ShipTo_Postal_PostalCode'}) {
	$out .= "  $frm{'Ecom_ShipTo_Postal_PostalCode'} ";
	$msg_tab_ck++;}
	$out .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_ShipTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_ShipTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	$out .= "$tc ";
	}
	$out .= "</td><td Class=\"tdInvcRightAddr\">";
	my ($k,$v,$t);
	while (($k,$v)=each(%frm)) {if ($k =~ /^Ecom_BillTo_/) {++$t if ($v)}}
	$out .= "<span Class=\"tabMsg\">BILL TO:</span><br>" if ($t);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_BillTo_Postal_Name_Prefix'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Name_Prefix'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_First'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Name_First'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_Middle'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Name_Middle'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_Last'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Name_Last'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_Suffix'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Name_Suffix'} ";
	$msg_tab_ck++;}
	$out .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_BillTo_Postal_Company'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Company'} <br>"}
	if ($frm{'Ecom_BillTo_Postal_Street_Line1'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Street_Line1'} <br>"}
	if ($frm{'Ecom_BillTo_Postal_Street_Line2'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_Street_Line2'} <br>"}
	if ($frm{'Ecom_BillTo_Postal_City'}) {
	$out .= "$frm{'Ecom_BillTo_Postal_City'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_StateProv'}) {
 	unless ($frm{'Ecom_BillTo_Postal_StateProv'} eq "NOTINLIST") {
	my ($sc) = $frm{'Ecom_BillTo_Postal_StateProv'};
	$sc =~ s/-/ /g;
	$out .= "$sc ";
	$msg_tab_ck++;}
	}
	if ($frm{'Ecom_BillTo_Postal_Region'}) {
	$out .= "  $frm{'Ecom_BillTo_Postal_Region'} ";
	$msg_tab_ck++}
	if ($frm{'Ecom_BillTo_Postal_PostalCode'}) {
	$out .= "  $frm{'Ecom_BillTo_Postal_PostalCode'} ";
	$msg_tab_ck++;}
	$out .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_BillTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_BillTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	$out .= "$tc";
	}
	$out .= "</td></tr></table>\n\n";

	# (4) Cart Content
	# (4) Cart Content

	$out .= "<table Class=\"ItemTable\"><tr Class=\"hRow\"><td Class=\"hCell\">Qty</td>";
	$out .= "<td Class=\"hCell\">Item</td><td Class=\"hCell\">Description</td><td Class=\"hCell\">Price</td></tr>";
	foreach $line (@orders) {
  	($qty,$item,$desc,$price,$ship,$taxit) = split (/$delimit/,$line);
   	$out .= "<tr Class=\"aRow\"><td Class=\"aQtyCell\">$qty</td>";
	$item =~ s/\[/</g;
	$item =~ s/\]/>/g;
	$out .= "<td Class=\"aItemCell\">$item ";
	$out .= " $identify_tax_items" if ($frm{'Tax_Amount'} > 0 && $identify_tax_items && $taxit);
	$out .= "</td>";
	# desc
	@list = split (/\|/,$desc);
	$desc = shift (@list);
		foreach $li (@list) {
		($lk,$lv) = split (/::/,$li);
		$desc .= "<li Class=\"descList\">" if ($makelist);			
		$desc .= "<span Class=\"descKey\">$lk </span><span Class=\"descValue\"> $lv</span>";
		}
 	$desc =~ s/\[/</g;
	$desc =~ s/\]/>/g;
	$out .= "<td Class=\"aDescriptionCell\">$desc </td>\n";
	# row for single item or multiple to sub totals
	if ($qty > 1 || $allow_fractions) {
	$out .= "<td Class=\"aPriceCell\"><br></td></tr>\n";
		$sub_price = ($qty * $price);
		$totalprice += $sub_price;
		$totalqnty += $qty;
      		$sub_price = sprintf "%.2f",$sub_price;
      		$sub_price = CommifyMoney ($sub_price);
		$price = CommifyMoney ($price);
		$qty = CommifyNumbers ($qty);
   		$out .= "<tr Class=\"bRow\"><td Class=\"bQtyCell\"><br></td><td colspan=2 Class=\"bDescriptionCell\">"; 
		$out .= "Sub Total $qty of $item at $currency $price each " if ($item_in_subline);
		$out .= "Sub Total $qty ( $currency $price per unit ) " unless ($item_in_subline);
		$out .= "</td><td Class=\"bPriceCell\"> $currency $sub_price </td>";
	} else {
		$totalprice += $price;
		$totalqnty += $qty;
		$price = CommifyMoney ($price);		
		$out .= "<td Class=\"aPriceCell\"> $currency $price </td>";
	}}
   	$out .= "</tr></table>\n\n";

	# (5) Cart Line Item Totals
	# (5) Cart Line Item Totals

	if ($totalqnty > 1) {$pd = "Items"} else {$pd = "Item"}
	$totalprice = sprintf "%.2f",$totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);
	$out .= "<table Class=\"TotalTable\"><tr Class=\"sRow1\">";
	$out .= "<td Class=\"sText1\">Subtotal $totalqnty $pd : </td>";
	$out .= "<td Class=\"sPrice1\">$currency $totalprice </td></tr>";
	# Totals from %frm Formerly %Computations -------------->
	# CommifyMoney here, keep computations free of formatting

	# (5.1) first discount
	if ($frm{'Primary_Discount'} > 0 || $frm{'Primary_Discount_Line_Override_Backend'}) {
	$DiscountOne = CommifyMoney ($frm{'Primary_Discount'});
	$out .= "<tr Class=\"sRow2\">";
	$out .= "<td Class=\"sText2\">$frm{'Primary_Discount_Status'} : </td><td Class=\"sPrice2\">";
	$out .= "$frm{'Primary_Discount_Amt_Override'} " if ($frm{'Primary_Discount'} == 0 && $frm{'Primary_Discount_Amt_Override'});
	$out .= "<span color=\"#FF0D00\">-</span> $currency $DiscountOne " unless ($frm{'Primary_Discount'} == 0 && $frm{'Primary_Discount_Amt_Override'});
	$out .= "</td></tr>";
	}

	# (5.2) coupon discount	
	if ($frm{'Coupon_Discount'} > 0 || $frm{'Coupon_Discount_Override'}) {
	$DiscountTwo = CommifyMoney ($frm{'Coupon_Discount'});
	$out .= "<tr Class=\"sRow3\"><td Class=\"sText3\">$frm{'Coupon_Discount_Status'} : </td>";
	$out .= "<td Class=\"sPrice3\"><span color=\"#FF0D00\">-</span> $currency $DiscountTwo </td></tr>";
	}

	# (5.3) subtotal if discounts
	if ($frm{'Combined_Discount'} > 0 ) {
	$SubDiscount = CommifyMoney ($frm{'Sub_Final_Discount'});
	$CombinedDiscount = CommifyMoney ($frm{'Combined_Discount'});
	$out .= "<tr Class=\"sRow4\"><td Class=\"sText4\">Sub Total After $currency $CombinedDiscount Total Discount : </td>";
	$out .= "<td Class=\"sPrice4\">$currency $SubDiscount </td></tr>";
	}

	# (5.4) tax before
	if ($frm{'Tax_Rule'} eq "BEFORE") {
	if ($frm{'Tax_Amount'} > 0 || $frm{'Tax_Line_Override'}) {
	$TaxCharge = CommifyMoney ($frm{'Tax_Amount'});
	$out .= "<tr Class=\"sRow5\"><td Class=\"sText5\">$frm{'Tax_Message'} : </td><td Class=\"sPrice5\">";
	$out .= "$frm{'Tax_Amt_Override'} " if ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});
	$out .= "$currency $TaxCharge " unless ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});
	$out .= "</td></tr>";
	}}

	# (5.5) handling
	if ($frm{'Handling'} > 0 || $frm{'Handling_Line_Override'}) {
	$HandlingCharge = CommifyMoney ($frm{'Handling'});
	$out .= "<tr Class=\"sRow6\"><td Class=\"sText6\">$frm{'Handling_Status'} : </td><td Class=\"sPrice6\">";
	$out .= "$frm{'Handling_Amt_Override'} " if ($frm{'Handling'} == 0 && $frm{'Handling_Amt_Override'});
	$out .= "$currency $HandlingCharge " unless ($frm{'Handling'} == 0 && $frm{'Handling_Amt_Override'});
	$out .= "</td></tr>";
	}

	# (5.6) insurance
	if ($frm{'Insurance'} > 0 || $frm{'Insurance_Line_Override'}) {
	$InsuranceCharge = CommifyMoney ($frm{'Insurance'});
	$out .= "<tr Class=\"sRow7\"><td Class=\"sText7\">$frm{'Insurance_Status'} : </td><td Class=\"sPrice7\">";
	$out .= "$frm{'Insurance_Amt_Override'} " if ($frm{'Insurance'} == 0 && $frm{'Insurance_Amt_Override'});
	$out .= "$currency $InsuranceCharge " unless ($frm{'Insurance'} == 0 && $frm{'Insurance_Amt_Override'});
	$out .= "</td></tr>";
	}

	# (5.7) shipping
	if ($frm{'Shipping_Amount'} > 0 || $frm{'Shipping_Line_Override'}) {
	$ShippingCharge = CommifyMoney ($frm{'Shipping_Amount'});
	$out .= "<tr Class=\"sRow8\"><td Class=\"sText8\">$frm{'Shipping_Message'} : </td><td Class=\"sPrice8\">";
	$out .= "$frm{'Shipping_Amt_Override'} " if ($frm{'Shipping_Amount'} == 0 && $frm{'Shipping_Amt_Override'});
	$out .= "$currency $ShippingCharge " unless ($frm{'Shipping_Amount'} == 0 && $frm{'Shipping_Amt_Override'});
	$out .= "</td></tr>";
	}

	# (5.8) tax after
	if ($frm{'Tax_Rule'} eq "AFTER") {
	if ($frm{'Tax_Amount'} > 0 || $frm{'Tax_Line_Override'}) {
	$TaxCharge = CommifyMoney ($frm{'Tax_Amount'});
	$out .= "<tr Class=\"sRow5\"><td Class=\"sText5\">$frm{'Tax_Message'} : </td><td Class=\"sPrice5\">";
	$out .= "$frm{'Tax_Amt_Override'} " if ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});
	$out .= "$currency $TaxCharge " unless ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});;
	$out .= "</td></tr>";
	}}

	# (5.9) cod
	if ($frm{'input_payment_options'} eq "COD") {
	if ($cod_charges > 0 ) {
	$out .= "<tr Class=\"sRow11\"><td Class=\"sText11\">$cod_msg : </td>";
	$out .= "<td Class=\"sPrice11\">$currency $cod_charges </td></tr>";
	}}

	# (5.10) total
	$out .= "<tr Class=\"sRow9\"><td Class=\"sText9\">Total Order Amount : </td>";
	$out .= "<td Class=\"sPrice9\">$currency $FinalAmount </td></tr>";

	# (5.11) conversion : May 12, 2003 6:44:04 PM
	if ($frm{'Final_ConvertAmount'} > 0.00) {
	my($altCurrency) = CommifyMoney ($frm{'Final_ConvertAmount'});
	$out .= "<tr Class=\"sRow10\"><td Class=\"sText10\">$currencyConvertTitle : </td>";
	$out .= "<td Class=\"sPrice10\"> $currencyConvertSymbol  $altCurrency </td></tr>";
	}

	# (5.12) deposits
	if ($frm{'Deposit_Amount'} > 0) {
	$out .= "<tr Class=\"sRow12\"><td Class=\"sText12\">Amount of Deposit : </td>";
	$out .= "<td Class=\"sPrice12\">$currency $Display_Payment_Amount </td></tr>";
	}

	# (5.13) balance
	if ($frm{'Deposit_Amount'} > 0) {
	$out .= "<tr Class=\"sRow13\"><td Class=\"sText13\">";
	$out .= "Overpaid Surplus" if ($frm{'Overpaid_Surplus'});
	$out .= "Remaining Balance" unless ($frm{'Overpaid_Surplus'});
	$out .= " : </td><td Class=\"sPrice13\">$currency $frm{'Remaining_Balance'} </td></tr>";	
	}
	$out .= "</table>";

	# (6) Display Extra Information
	# (6) Display Extra Information

	# (6.1) custom fields display for billing confirmation page
	if (scalar(@customFinal)) {
	$out .= "<p><table Class=\"tblCustom\">\n";
	$out .= "<tr Class=\"rowCustomTitle\"><td colspan=\"2\">$CustomHeading</td></tr>\n";
	$out .= "<tr Class=\"rowCustomText\"><td colspan=\"2\">$CustomDisplay</td></tr>\n";
	my $cf;
	foreach $cf (@customFinal) {
	$out .= "<tr><td Class=\"titleCustom\">$extraTitle{$cf} : </td><td Class=\"valueCustom\">$frm{$cf}</td></tr>" if (!$onlyValues || $frm{$cf});
	}
	$out .= "</table>\n\n";
	}

	# (6.2) email to
	$mail_msg = "An email notice has been mailed to ";	
	if ($frm{'Ecom_ReceiptTo_Online_Email'}) {
	$mail_msg .= $frm{'Ecom_ReceiptTo_Online_Email'};
	} elsif ($frm{'Ecom_BillTo_Online_Email'}) {
	$mail_msg .= $frm{'Ecom_BillTo_Online_Email'};
	} elsif ($frm{'Ecom_ShipTo_Online_Email'}) {
	$mail_msg .= $frm{'Ecom_ShipTo_Online_Email'};
	} else {
	$mail_msg = "An email receipt was not mailed because no customer email address was entered.";
	}

	# (6.3) web copy
	$save_url = $save_invoice_url . $$ . $InvoiceNumber . ".html";
	$save_msg = "<a Class=\"TextLink\" href=\"$save_url\">$save_url</a>";	

	# (6.4) extra ship info
	$ship_msg = "Phone $frm{'Ecom_ShipTo_Telecom_Phone_Number'} " if ($frm{'Ecom_ShipTo_Telecom_Phone_Number'});
	$ship_msg .= "Email $frm{'Ecom_ShipTo_Online_Email'} " if ($frm{'Ecom_ShipTo_Online_Email'});

	# (6.5) extra bill into
	$bill_msg = "Phone $frm{'Ecom_BillTo_Telecom_Phone_Number'} " if ($frm{'Ecom_BillTo_Telecom_Phone_Number'});
	$bill_msg .= "Email $frm{'Ecom_BillTo_Online_Email'} " if ($frm{'Ecom_BillTo_Online_Email'});

	# (6.6) receipt info
	$receipt_msg = "$frm{'Ecom_ReceiptTo_Postal_Name_Prefix'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Prefix'});
	$receipt_msg .=  "$frm{'Ecom_ReceiptTo_Postal_Name_First'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_First'});
	$receipt_msg .=  "$frm{'Ecom_ReceiptTo_Postal_Name_Middle'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Middle'});
	$receipt_msg .=  "$frm{'Ecom_ReceiptTo_Postal_Name_Last'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Last'});
	$receipt_msg .=  "$frm{'Ecom_ReceiptTo_Postal_Name_Suffix'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Suffix'});
	$receipt_msg .=  "<br>$frm{'Ecom_ReceiptTo_Postal_Company'} " if ($frm{'Ecom_ReceiptTo_Postal_Company'});
	$receipt_msg .=  "<br>$frm{'Ecom_ReceiptTo_Postal_Street_Line1'} " if ($frm{'Ecom_ReceiptTo_Postal_Street_Line1'});
	$receipt_msg .=  "<br>$frm{'Ecom_ReceiptTo_Postal_Street_Line2'} " if ($frm{'Ecom_ReceiptTo_Postal_Street_Line2'});
	$receipt_msg .=  "<br>$frm{'Ecom_ReceiptTo_Postal_City'} " if ($frm{'Ecom_ReceiptTo_Postal_City'});
		if ($frm{'Ecom_ReceiptTo_Postal_StateProv'}) {
		unless ($frm{'Ecom_ReceiptTo_Postal_StateProv'} eq "NOTINLIST") {
		my ($sc) = $frm{'Ecom_ReceiptTo_Postal_StateProv'};
		$sc =~ s/-/ /g;
		$receipt_msg .=  "$sc ";
		}}
	$receipt_msg .=  "$frm{'Ecom_ReceiptTo_Postal_Region'} " if ($frm{'Ecom_ReceiptTo_Postal_Region'});
	$receipt_msg .=  "$frm{'Ecom_ReceiptTo_Postal_PostalCode'} " if ($frm{'Ecom_ReceiptTo_Postal_PostalCode'});
		if ($frm{'Ecom_ReceiptTo_Postal_CountryCode'}) {
		my ($tc) = $frm{'Ecom_ReceiptTo_Postal_CountryCode'};
		$tc =~ s/-/ /g;
		$receipt_msg .=  "$tc ";
		}
	$receipt_msg .=  "<br>Phone : $frm{'Ecom_ReceiptTo_Telecom_Phone_Number'} " if ($frm{'Ecom_ReceiptTo_Telecom_Phone_Number'});
	$receipt_msg .=  "<br>eMail : $frm{'Ecom_ReceiptTo_Online_Email'} " if ($frm{'Ecom_ReceiptTo_Online_Email'});
	$check_additional++ if ($mail_msg && $list_customer_mail);
	$check_additional++ if ($save_msg && $list_invoice_url );
	$check_additional++ if ($ship_msg && $list_ship_extra );
	$check_additional++ if ($bill_msg && $list_bill_extra);
	$check_additional++ if ($receipt_msg && $list_receipt_info);

	# (6.2 - 6.6) display collected info
	if ($check_additional) {
	$out .= "<p><table Class=\"tblAdditional\">";
	$out .= "<tr Class=\"rowAdditionalTitle\"><td colspan=\"2\">$AdditionalHeading</td></tr>" if ($AdditionalHeading);
	$out .= "<tr Class=\"rowAdditionalText\"><td colspan=\"2\">$AdditionalDisplay</td></tr>" if ($AdditionalDisplay);
	$out .= "<tr><td Class=\"titleAdditional\">eMail : </td><td Class=\"valueAdditional\">$mail_msg</td></tr>" if ($mail_msg && $list_customer_mail);
	$out .= "<tr><td Class=\"titleAdditional\">Invoice Copy : </td><td Class=\"valueAdditional\">$save_msg</td></tr>" if ($save_msg && $list_invoice_url );
	$out .= "<tr><td Class=\"titleAdditional\">Shipping Phone : </td><td Class=\"valueAdditional\">$ship_msg</td></tr>" if ($ship_msg && $list_ship_extra );
	$out .= "<tr><td Class=\"titleAdditional\">Billing Phone : </td><td Class=\"valueAdditional\">$bill_msg</td></tr>" if ($bill_msg && $list_bill_extra);
	$out .= "<tr><td Class=\"titleAdditional\">Receipt To : </td><td Class=\"valueAdditional\">$receipt_msg</td></tr>" if ($receipt_msg && $list_receipt_info);
	$out .= "</table>\n\n";
	}

	# (6.7) comments
	if ($list_comments && $frm{'special_instructions'}) {
	$out .= "<p><table Class=\"tblComments\">";
	$out .= "<tr Class=\"rowComments\"><td>$CommentsHeading</td></tr>" if ($CommentsHeading);
	$out .= "<tr><td Class=\"cellComments\">$frm{'special_instructions'}</td></tr></table>";
	}

	# (6.8) print lines
	if ($frm{'input_payment_options'} eq "MAIL") {
		$exp_date = $frm{'Ecom_Payment_Card_ExpDate_Month'};
		if ($frm{'Ecom_Payment_Card_ExpDate_Month'}) {
		$exp_date .=  "-" if ($frm{'Ecom_Payment_Card_ExpDate_Day'})
		}
		$exp_date .=  $frm{'Ecom_Payment_Card_ExpDate_Day'};
		if ($frm{'Ecom_Payment_Card_ExpDate_Month'} || $frm{'Ecom_Payment_Card_ExpDate_Day'}) {
		$exp_date .=  "-" if ($frm{'Ecom_Payment_Card_ExpDate_Year'})
		}
		$exp_date .=  $frm{'Ecom_Payment_Card_ExpDate_Year'};
		$swt_date = $frm{'Ecom_Payment_Card_FromDate_Month'};
		$swt_date .= "-" if ($frm{'Ecom_Payment_Card_FromDate_Year'});
		$swt_date .= $frm{'Ecom_Payment_Card_FromDate_Year'};
	if ($allow_lines_credit || $allow_lines_check) {
	$out .= "<p><table Class=\"tblLines\">";
	$out .= "<tr Class=\"rowLines\"><td colspan=\"2\">$LinesHeading</td></tr>" if ($LinesHeading);
	# card
	if ($allow_lines_credit) {
	$out .= "<tr><td Class=\"cellLinesTitle\">Card Holder's Name : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Ecom_Payment_Card_Name'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Card Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Ecom_Payment_Card_Number'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Card Expiration Date : </td><td Class=\"cellLinesValue\">&nbsp; $exp_date</td></tr>";
	if ($enable_switch) {
	$out .= "<tr><td Class=\"cellLinesTitle\">Switch Issue Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Ecom_Payment_Card_IssueNumber'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Switch From Date : </td><td Class=\"cellLinesValue\">&nbsp; $swt_date</td></tr>";
	}
	$out .= "<tr><td Class=\"cellLinesTitle\">Signature : </td><td Class=\"cellLinesValue\">&nbsp;</td></tr>";
	}
	# check
	if ($allow_lines_check) {
	$out .= "<tr><td Class=\"cellLinesTitle\">Name on Checking Account : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Holder_Name'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Check Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Number'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Checking Account Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Account_Number'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Routing Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Routing_Number'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Fraction Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Fraction_Number'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Bank Name : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Bank_Name'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Bank Address : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Bank_Address'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Account Type : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Account_Type'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Organization Type : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Customer_Organization_Type'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Tax ID or SSN : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Tax_ID'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Drivers License # : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Drivers_License_Num'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Drivers LIcense State : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Drivers_License_ST'}</td></tr>";
	$out .= "<tr><td Class=\"cellLinesTitle\">Drivers License DOB : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Drivers_License_DOB'}</td></tr>";
	}
	$out .= "</table>";
	}}
	# End UseCustomOnlyMsg
	}

	# (7) Bottom Navigation options
	# (7) Bottom Navigation options

	# changed menus : v2.5 Bottom Navigation : Confirmation Pg
	unless ($OmitBottomNav) {
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
	}}
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
