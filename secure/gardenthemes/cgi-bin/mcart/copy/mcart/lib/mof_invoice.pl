# ==================== MOFcart v2.5.10.21.03 ====================== #
# === SAVE WEB COPY =============================================== #
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
# Exact copy of the Default cart content in Final Confirmation screen
# For an example of a custom Web Copy see <mof_custinvc.pl>
# Note: $Send_API_Amount is always Final Amount for raw number
# Note: $Display_Payment_Amount is the formatted Final Amount
# This <mof_invoice.pl> assembles the string, then prints to file

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
		$ship_msg,$bill_msg,$receipt_msg);
	$msg_status = "$FinalProducts Items " if ($frm{'Primary_Products'} > 1);
	$msg_status = "$FinalProducts Item " if ($frm{'Primary_Products'} == 1);
	$msg_status .= " $currency $Display_Payment_Amount";

	# top messages payment methods

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
	# rga : 03/02/05 15:08:05
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"currency_code\" VALUE=\"$paypal_currency_code\"> \n";
	$invc_msg .= "<INPUT TYPE=\"hidden\" NAME=\"lc\" VALUE=\"$paypal_lang_code\"> \n";
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

	# space & close
	$invc_msg .= "<p>";

	# top nav
	$nav_top++ if ($menu_home_top);
	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_help_top);
	# changed menus : v2.5 Top Navigation : Order Confirmation Pg
	if ($nav_top && $includeOrderConfirmation) {
	my ($tblCSS,$tdCSS) = ('tblTopPreviousNav','tdTopPreviousNav') if ($twoTopTables);
	my ($tblCSS,$tdCSS) = ('tblTopNav','tdTopNav') unless ($twoTopTables);
	$invc_msg .= "<table Class=\"$tblCSS\"><tr>";

	# help / home
	if ($menu_previous_top or $menu_viewcart_top or $menu_help_top or $menu_home_top) {
	$invc_msg .= "<td Class=\"$tdCSS\">$menu_help_top</td>\n" if ($menu_help_top); 
	$invc_msg .= "<td Class=\"$tdCSS\">$menu_home_top</td>\n" if ($menu_home_top);
	# previous pg
	if ($menu_previous_top) {
	$invc_msg .= "<td Class=\"$tdCSS\">";
	$invc_msg .= "<a Class=\"TopPreviousLink\" " if ($twoTopTables);
	$invc_msg .= "<a Class=\"TopNavLink\" " unless ($twoTopTables);
	$invc_msg .= "href=\"$frm{'previouspage'}\" ";
	$invc_msg .= "onmouseover=\"status='$menu_previous_top_status';return true\;\" ";
	$invc_msg .= "onmouseout=\"status='&nbsp';return true\;\">";
	$invc_msg .= "$menu_previous_top" unless($menu_previous_top_btn);
	$invc_msg .= "<input Class=\"$menu_previous_top_btn\" type=\"button\" value=\"Shopping\" onclick=\"window.open('$frm{'previouspage'}','MAIN')\"\;>" if ($menu_previous_top_btn);
	$invc_msg .= "</a></td>\n" ;
	}
	}
	# no more functions
	$invc_msg .= "</tr></table>\n";
	}

	# CSS replacement : confirmation screen
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
	$invc_msg .= "<table Class=\"tblInvc\"><tr Class=\"trInvcTop\"><td Class=\"tdInvcLeftTop\">";
	$invc_msg .= "Invoice: $InvoiceNumber</td><td Class=\"tdInvcRightTop\">$y $x </td></tr>";
	$invc_msg .= "<tr Class=\"trInvcAddr\"><td Class=\"tdInvcLeftAddr\"><span Class=\"tabMsg\">$msg_tab</span><br>";
	$msg_tab_ck = 0;
	if ($frm{'Ecom_ShipTo_Postal_Name_Prefix'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Name_Prefix'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_First'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Name_First'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_Middle'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Name_Middle'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_Last'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Name_Last'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_Name_Suffix'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Name_Suffix'} ";
	$msg_tab_ck++;}
	$invc_msg .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_ShipTo_Postal_Company'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Company'} <br>"}
	if ($frm{'Ecom_ShipTo_Postal_Street_Line1'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Street_Line1'} <br>"}
	if ($frm{'Ecom_ShipTo_Postal_Street_Line2'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Street_Line2'} <br>"}
	if ($frm{'Ecom_ShipTo_Postal_City'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_City'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_ShipTo_Postal_StateProv'}) {
	unless ($frm{'Ecom_ShipTo_Postal_StateProv'} eq "NOTINLIST") {
	my ($sc) = $frm{'Ecom_ShipTo_Postal_StateProv'};
	$sc =~ s/-/ /g;
	$invc_msg .= "$sc ";
	$msg_tab_ck++;
	}}
	if ($frm{'Ecom_ShipTo_Postal_Region'}) {
	$invc_msg .= "$frm{'Ecom_ShipTo_Postal_Region'} ";
	$msg_tab_ck++}
	if ($frm{'Ecom_ShipTo_Postal_PostalCode'}) {
	$invc_msg .= " $frm{'Ecom_ShipTo_Postal_PostalCode'} ";
	$msg_tab_ck++;}
	$invc_msg .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_ShipTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_ShipTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	$invc_msg .= "$tc ";
	}
	$invc_msg .= "</td><td Class=\"tdInvcRightAddr\">";
	my ($k,$v,$t);
	while (($k,$v)=each(%frm)) {if ($k =~ /^Ecom_BillTo_/) {++$t if ($v)}}
	$invc_msg .= "<span Class=\"tabMsg\">BILL TO:</span><br>" if ($t);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_BillTo_Postal_Name_Prefix'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Name_Prefix'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_First'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Name_First'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_Middle'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Name_Middle'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_Last'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Name_Last'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_Name_Suffix'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Name_Suffix'} ";
	$msg_tab_ck++;}
	$invc_msg .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_BillTo_Postal_Company'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Company'} <br>"}
	if ($frm{'Ecom_BillTo_Postal_Street_Line1'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Street_Line1'} <br>"}
	if ($frm{'Ecom_BillTo_Postal_Street_Line2'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Street_Line2'} <br>"}
	if ($frm{'Ecom_BillTo_Postal_City'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_City'} ";
	$msg_tab_ck++;}
	if ($frm{'Ecom_BillTo_Postal_StateProv'}) {
 	unless ($frm{'Ecom_BillTo_Postal_StateProv'} eq "NOTINLIST") {
	my ($sc) = $frm{'Ecom_BillTo_Postal_StateProv'};
	$sc =~ s/-/ /g;
	$invc_msg .= "$sc ";
	$msg_tab_ck++;}
	}
	if ($frm{'Ecom_BillTo_Postal_Region'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_Region'} ";
	$msg_tab_ck++}
	if ($frm{'Ecom_BillTo_Postal_PostalCode'}) {
	$invc_msg .= "$frm{'Ecom_BillTo_Postal_PostalCode'} ";
	$msg_tab_ck++;}
	$invc_msg .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($frm{'Ecom_BillTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_BillTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	$invc_msg .= "$tc";
	}
	$invc_msg .= "</td></tr></table>\n\n";
	# cart	
	$invc_msg .= "<table Class=\"ItemTable\"><tr Class=\"hRow\"><td Class=\"hCell\">Qty</td>";
	$invc_msg .= "<td Class=\"hCell\">Item</td><td Class=\"hCell\">Description</td><td Class=\"hCell\">Price</td></tr>";
	foreach $line (@orders) {
  	($qty,$item,$desc,$price,$ship,$taxit) = split (/$delimit/,$line);
   	$invc_msg .= "<tr Class=\"aRow\"><td Class=\"aQtyCell\">$qty</td>";
	$item =~ s/\[/</g;
	$item =~ s/\]/>/g;
	$invc_msg .= "<td Class=\"aItemCell\">$item ";
	$invc_msg .= " $identify_tax_items" if ($frm{'Tax_Amount'} > 0 && $identify_tax_items && $taxit);
	$invc_msg .= "</td>";
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
	$invc_msg .= "<td Class=\"aDescriptionCell\">$desc </td>\n";
	# row for single item or multiple to sub totals
	if ($qty > 1 || $allow_fractions) {
	$invc_msg .= "<td Class=\"aPriceCell\"><br></td></tr>\n";
		$sub_price = ($qty * $price);
		$totalprice += $sub_price;
		$totalqnty += $qty;
      		$sub_price = sprintf "%.2f",$sub_price;
      		$sub_price = CommifyMoney ($sub_price);
		$price = CommifyMoney ($price);
		$qty = CommifyNumbers ($qty);
   		$invc_msg .= "<tr Class=\"bRow\"><td Class=\"bQtyCell\"><br></td><td colspan=2 Class=\"bDescriptionCell\">"; 
		$invc_msg .= "Sub Total $qty of $item at $currency $price each " if ($item_in_subline);
		$invc_msg .= "Sub Total $qty ( $currency $price per unit ) " unless ($item_in_subline);
		$invc_msg .= "</td><td Class=\"bPriceCell\"> $currency $sub_price </td>";
	} else {
		$totalprice += $price;
		$totalqnty += $qty;
		$price = CommifyMoney ($price);		
		$invc_msg .= "<td Class=\"aPriceCell\"> $currency $price </td>";
	}}
   	$invc_msg .= "</tr></table>\n\n";
	# sub total
	if ($totalqnty > 1) {$pd = "Items"} else {$pd = "Item"}
	$totalprice = sprintf "%.2f",$totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);
	$invc_msg .= "<table Class=\"TotalTable\"><tr Class=\"sRow1\">";
	$invc_msg .= "<td Class=\"sText1\">Subtotal $totalqnty $pd : </td>";
	$invc_msg .= "<td Class=\"sPrice1\">$currency $totalprice </td></tr>";
	# Totals from %frm Formerly %Computations -------------->
	# CommifyMoney here, keep computations free of formatting
	# first discount
	if ($frm{'Primary_Discount'} > 0 || $frm{'Primary_Discount_Line_Override_Backend'}) {
	$DiscountOne = CommifyMoney ($frm{'Primary_Discount'});
	$invc_msg .= "<tr Class=\"sRow2\">";
	$invc_msg .= "<td Class=\"sText2\">$frm{'Primary_Discount_Status'} : </td><td Class=\"sPrice2\">";
	$invc_msg .= "$frm{'Primary_Discount_Amt_Override'} " if ($frm{'Primary_Discount'} == 0 && $frm{'Primary_Discount_Amt_Override'});
	$invc_msg .= "<span color=\"#FF0D00\">-</span> $currency $DiscountOne " unless ($frm{'Primary_Discount'} == 0 && $frm{'Primary_Discount_Amt_Override'});
	$invc_msg .= "</td></tr>";
	}
	# coupon discount	
	if ($frm{'Coupon_Discount'} > 0 || $frm{'Coupon_Discount_Override'}) {
	$DiscountTwo = CommifyMoney ($frm{'Coupon_Discount'});
	$invc_msg .= "<tr Class=\"sRow3\"><td Class=\"sText3\">$frm{'Coupon_Discount_Status'} : </td>";
	$invc_msg .= "<td Class=\"sPrice3\"><span color=\"#FF0D00\">-</span> $currency $DiscountTwo </td></tr>";
	}
	# subtotal if discounts
	if ($frm{'Combined_Discount'} > 0 ) {
	$SubDiscount = CommifyMoney ($frm{'Sub_Final_Discount'});
	$CombinedDiscount = CommifyMoney ($frm{'Combined_Discount'});
	$invc_msg .= "<tr Class=\"sRow4\"><td Class=\"sText4\">Sub Total After $currency $CombinedDiscount Total Discount : </td>";
	$invc_msg .= "<td Class=\"sPrice4\">$currency $SubDiscount </td></tr>";
	}
	# tax before
	if ($frm{'Tax_Rule'} eq "BEFORE") {
	if ($frm{'Tax_Amount'} > 0 || $frm{'Tax_Line_Override'}) {
	$TaxCharge = CommifyMoney ($frm{'Tax_Amount'});
	$invc_msg .= "<tr Class=\"sRow5\"><td Class=\"sText5\">$frm{'Tax_Message'} : </td><td Class=\"sPrice5\">";
	$invc_msg .= "$frm{'Tax_Amt_Override'} " if ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});
	$invc_msg .= "$currency $TaxCharge " unless ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});
	$invc_msg .= "</td></tr>";
	}}
	# handling
	if ($frm{'Handling'} > 0 || $frm{'Handling_Line_Override'}) {
	$HandlingCharge = CommifyMoney ($frm{'Handling'});
	$invc_msg .= "<tr Class=\"sRow6\"><td Class=\"sText6\">$frm{'Handling_Status'} : </td><td Class=\"sPrice6\">";
	$invc_msg .= "$frm{'Handling_Amt_Override'} " if ($frm{'Handling'} == 0 && $frm{'Handling_Amt_Override'});
	$invc_msg .= "$currency $HandlingCharge " unless ($frm{'Handling'} == 0 && $frm{'Handling_Amt_Override'});
	$invc_msg .= "</td></tr>";
	}
	# insurance
	if ($frm{'Insurance'} > 0 || $frm{'Insurance_Line_Override'}) {
	$InsuranceCharge = CommifyMoney ($frm{'Insurance'});
	$invc_msg .= "<tr Class=\"sRow7\"><td Class=\"sText7\">$frm{'Insurance_Status'} : </td><td Class=\"sPrice7\">";
	$invc_msg .= "$frm{'Insurance_Amt_Override'} " if ($frm{'Insurance'} == 0 && $frm{'Insurance_Amt_Override'});
	$invc_msg .= "$currency $InsuranceCharge " unless ($frm{'Insurance'} == 0 && $frm{'Insurance_Amt_Override'});
	$invc_msg .= "</td></tr>";
	}
	# shipping
	if ($frm{'Shipping_Amount'} > 0 || $frm{'Shipping_Line_Override'}) {
	$ShippingCharge = CommifyMoney ($frm{'Shipping_Amount'});
	$invc_msg .= "<tr Class=\"sRow8\"><td Class=\"sText8\">$frm{'Shipping_Message'} : </td><td Class=\"sPrice8\">";
	$invc_msg .= "$frm{'Shipping_Amt_Override'} " if ($frm{'Shipping_Amount'} == 0 && $frm{'Shipping_Amt_Override'});
	$invc_msg .= "$currency $ShippingCharge " unless ($frm{'Shipping_Amount'} == 0 && $frm{'Shipping_Amt_Override'});
	$invc_msg .= "</td></tr>";
	}
	# tax after
	if ($frm{'Tax_Rule'} eq "AFTER") {
	if ($frm{'Tax_Amount'} > 0 || $frm{'Tax_Line_Override'}) {
	$TaxCharge = CommifyMoney ($frm{'Tax_Amount'});
	$invc_msg .= "<tr Class=\"sRow5\"><td Class=\"sText5\">$frm{'Tax_Message'} : </td><td Class=\"sPrice5\">";
	$invc_msg .= "$frm{'Tax_Amt_Override'} " if ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});
	$invc_msg .= "$currency $TaxCharge " unless ($frm{'Tax_Amount'} == 0 && $frm{'Tax_Amt_Override'});;
	$invc_msg .= "</td></tr>";
	}}
	# cod
	if ($frm{'input_payment_options'} eq "COD") {
	if ($cod_charges > 0 ) {
	$invc_msg .= "<tr Class=\"sRow11\"><td Class=\"sText11\">$cod_msg : </td>";
	$invc_msg .= "<td Class=\"sPrice11\">$currency $cod_charges </td></tr>";
	}}
	# total
	$invc_msg .= "<tr Class=\"sRow9\"><td Class=\"sText9\">Total Order Amount : </td>";
	$invc_msg .= "<td Class=\"sPrice9\">$currency $FinalAmount </td></tr>";
	# conversion : May 12, 2003 6:44:04 PM
	if ($frm{'Final_ConvertAmount'} > 0.00) {
	my($altCurrency) = CommifyMoney ($frm{'Final_ConvertAmount'});
	$invc_msg .= "<tr Class=\"sRow10\"><td Class=\"sText10\">$currencyConvertTitle : </td>";
	$invc_msg .= "<td Class=\"sPrice10\"> $currencyConvertSymbol  $altCurrency </td></tr>";
	}
	# deposits
	if ($frm{'Deposit_Amount'} > 0) {
	$invc_msg .= "<tr Class=\"sRow12\"><td Class=\"sText12\">Amount of Deposit : </td>";
	$invc_msg .= "<td Class=\"sPrice12\">$currency $Display_Payment_Amount </td></tr>";
	}
	# balance
	if ($frm{'Deposit_Amount'} > 0) {
	$invc_msg .= "<tr Class=\"sRow13\"><td Class=\"sText13\">";
	$invc_msg .= "Overpaid Surplus" if ($frm{'Overpaid_Surplus'});
	$invc_msg .= "Remaining Balance" unless ($frm{'Overpaid_Surplus'});
	$invc_msg .= " : </td><td Class=\"sPrice13\">$currency $frm{'Remaining_Balance'} </td></tr>";	
	}
	$invc_msg .= "</table>";

	# 05-04-03 : Custom Fields Added
	# custom fields display for billing confirmation page
	if (scalar(@customFinal)) {
	$invc_msg .= "<p><table Class=\"tblCustom\">\n";
	$invc_msg .= "<tr Class=\"rowCustomTitle\"><td colspan=\"2\">$CustomHeading</td></tr>\n";
	$invc_msg .= "<tr Class=\"rowCustomText\"><td colspan=\"2\">$CustomDisplay</td></tr>\n";
	my $cf;
	foreach $cf (@customFinal) {
	$invc_msg .= "<tr><td Class=\"titleCustom\">$extraTitle{$cf} : </td><td Class=\"valueCustom\">$frm{$cf}</td></tr>" if (!$onlyValues || $frm{$cf});
	}
	$invc_msg .= "</table>\n\n";
	}

	# email to
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
	# web copy
	$save_url = $save_invoice_url . $$ . $InvoiceNumber . ".html";
	$save_msg = "<a Class=\"TextLink\" href=\"$save_url\">$save_url</a>";	
	# extra ship info
	$ship_msg = "Phone $frm{'Ecom_ShipTo_Telecom_Phone_Number'} " if ($frm{'Ecom_ShipTo_Telecom_Phone_Number'});
	$ship_msg .= "Email $frm{'Ecom_ShipTo_Online_Email'} " if ($frm{'Ecom_ShipTo_Online_Email'});
	# extra bill into
	$bill_msg = "Phone $frm{'Ecom_BillTo_Telecom_Phone_Number'} " if ($frm{'Ecom_BillTo_Telecom_Phone_Number'});
	$bill_msg .= "Email $frm{'Ecom_BillTo_Online_Email'} " if ($frm{'Ecom_BillTo_Online_Email'});

	# receipt info
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

	# display extra info
	if ($check_additional) {
	$invc_msg .= "<p><table Class=\"tblAdditional\">";
	$invc_msg .= "<tr Class=\"rowAdditionalTitle\"><td colspan=\"2\">$AdditionalHeading</td></tr>" if ($AdditionalHeading);
	$invc_msg .= "<tr Class=\"rowAdditionalText\"><td colspan=\"2\">$AdditionalDisplay</td></tr>" if ($AdditionalDisplay);
	$invc_msg .= "<tr><td Class=\"titleAdditional\">eMail : </td><td Class=\"valueAdditional\">$mail_msg</td></tr>" if ($mail_msg && $list_customer_mail);
	$invc_msg .= "<tr><td Class=\"titleAdditional\">Invoice Copy : </td><td Class=\"valueAdditional\">$save_msg</td></tr>" if ($save_msg && $list_invoice_url );
	$invc_msg .= "<tr><td Class=\"titleAdditional\">Shipping Phone : </td><td Class=\"valueAdditional\">$ship_msg</td></tr>" if ($ship_msg && $list_ship_extra );
	$invc_msg .= "<tr><td Class=\"titleAdditional\">Billing Phone : </td><td Class=\"valueAdditional\">$bill_msg</td></tr>" if ($bill_msg && $list_bill_extra);
	$invc_msg .= "<tr><td Class=\"titleAdditional\">Receipt To : </td><td Class=\"valueAdditional\">$receipt_msg</td></tr>" if ($receipt_msg && $list_receipt_info);
	$invc_msg .= "</table>\n\n";
	}

	# comments
	if ($list_comments && $frm{'special_instructions'}) {
	$invc_msg .= "<p><table Class=\"tblComments\">";
	$invc_msg .= "<tr Class=\"rowComments\"><td>$CommentsHeading</td></tr>" if ($CommentsHeading);
	$invc_msg .= "<tr><td Class=\"cellComments\">$frm{'special_instructions'}</td></tr></table>";
	}

	# print lines
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
	$invc_msg .= "<p><table Class=\"tblLines\">";
	$invc_msg .= "<tr Class=\"rowLines\"><td colspan=\"2\">$LinesHeading</td></tr>" if ($LinesHeading);
	# card
	if ($allow_lines_credit) {
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Card Holder's Name : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Ecom_Payment_Card_Name'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Card Number : </td><td Class=\"cellLinesValue\">&nbsp;</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Card Expiration Date : </td><td Class=\"cellLinesValue\">&nbsp; $exp_date</td></tr>";
	if ($enable_switch) {
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Switch Issue Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Ecom_Payment_Card_IssueNumber'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Switch From Date : </td><td Class=\"cellLinesValue\">&nbsp; $swt_date</td></tr>";
	}
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Signature : </td><td Class=\"cellLinesValue\">&nbsp;</td></tr>";
	}
	# check
	if ($allow_lines_check) {
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Name on Checking Account : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Holder_Name'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Check Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Number'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Checking Account Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Account_Number'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Routing Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Routing_Number'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Fraction Number : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Fraction_Number'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Bank Name : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Bank_Name'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Bank Address : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Bank_Address'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Account Type : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Account_Type'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Organization Type : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Customer_Organization_Type'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Tax ID or SSN : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Tax_ID'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Drivers License # : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Drivers_License_Num'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Drivers LIcense State : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Drivers_License_ST'}</td></tr>";
	$invc_msg .= "<tr><td Class=\"cellLinesTitle\">Drivers License DOB : </td><td Class=\"cellLinesValue\">&nbsp; $frm{'Check_Drivers_License_DOB'}</td></tr>";
	}
	$invc_msg .= "</table>";
	}}

	# changed menus : v2.5 Bottom Navigation : Confirmation Pg
	if ($includeOrderConfirmationBottom) {
	my ($tblCSS,$tdCSS) = ('tblBottomPreviousNav','tdBottomPreviousNav') if ($twoBottomTables);
	my ($tblCSS,$tdCSS) = ('tblBottomNav','tdBottomNav') unless ($twoBottomTables);
	$invc_msg .= "<p><table Class=\"$tblCSS\"><tr>\n";
	# help / home
	if ($menu_previous_bottom or $menu_viewcart_bottom or $menu_help_bottom or $menu_home_bottom) {
	$invc_msg .= "<td Class=\"$tdCSS\">$menu_help_bottom</td>\n" if ($menu_help_bottom); 
	$invc_msg .= "<td Class=\"$tdCSS\">$menu_home_bottom</td>\n" if ($menu_home_bottom);
	# previous pg
	if ($menu_previous_bottom) {
	$invc_msg .= "<td Class=\"$tdCSS\">";
	$invc_msg .= "<a Class=\"BottomPreviousLink\" " if ($twoBottomTables);
	$invc_msg .= "<a Class=\"BottomNavLink\" " unless ($twoBottomTables);
	$invc_msg .= "href=\"$frm{'previouspage'}\" ";
	$invc_msg .= "onmouseover=\"status='$menu_previous_bottom_status';return true\;\" ";
	$invc_msg .= "onmouseout=\"status='&nbsp';return true\;\">";
	$invc_msg .= "$menu_previous_bottom" unless($menu_previous_bottom_btn);
	$invc_msg .= "<input Class=\"$menu_previous_bottom_btn\" type=\"button\" value=\"Shopping\" onclick=\"window.open('$frm{'previouspage'}','MAIN')\"\;>" if ($menu_previous_bottom_btn);
	$invc_msg .= "</a></td>\n" ;
	}}
	# no more functions
	$invc_msg .= "</tr></table>\n";
	}


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
