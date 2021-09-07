# Merchant OrderForm v1.53 Plug In for Save To Disk Invoice File, UPDATED 9/15/2000
# Copyright August 2000
# Owner: http://www.io.com/~rga/
# Mailto: rga@io.com
# Written for Austin Contract Computing, Inc. All Rights Reserved 2000

# PLEASE NOTE_________________________________________________
# These programs are distributed as Trial Ware or Share Ware.
# You are Welcome to install and test all portions of the programs.
# The package is not limited in any way and code source is left readable.
# Please make arrangements for the fee if you continue operating it on a Web Site
# Feel free to contact me if you need special arrangements for use of MOF v1.53

# For personal web site use: $ 15.00
# For web development (3-10 sites): $ 45.00, includes limited support
# For web development (above 10 sites): $ 150.00, includes limited support
# Note: For Resale or hosting license please contact rga@io.com
# For payment arrangements: http://www.merchantorderform.com/payment.html

# IMPORTANT ____________________________________________
# Distribution of this file without owner consent is prohibited.
# Please contact the authors of this product for any use outside 
# The original registration and user license

# COPYRIGHT NOTICE____________________________________________
# The contents of this file is protected under the United States
# copyright laws as an unpublished work, and is confidential and
# proprietary to Austin Contract Computing, Inc. Its use or disclosure 
# in whole or in part without the expressed written permission of Austin
# Contract Computing, Inc. is prohibited.

# THIS IS THE SAVE HTML INVOICE COPY PLUG IN
# THIS IS THE SAVE HTML INVOICE COPY PLUG IN

# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES
# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES

# This Plug In contains One sub routine to save the invoice file to html on server
# Sensitive data is removed, menu navigation removed, no hidden data is processed
# It is an exact copy of the Final Invoice Processing Page with navigation and sensitive data removed
# You MUST have correct settings in the mofpayment.conf configuration file for this function
# This file does not need a lock on it, because it can only print the one most recent OrderID invoice


sub SaveInvoiceFile {

	my (@tmpfile) = ();

	my ($FileNumber) = $frm{'OrderID'};
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;

	my ($file_path_name) = $save_invoice_path . $FileNumber . ".html";
	
	# FINAL HTML COPY
	# FINAL HTML COPY

	my (@list) = ();
	
	my ($key, $val);
	my ($nav_top, $nav_bottom) = (0,0);
	my ($li, $lk, $lv, $msg_status);
	my ($totalprice, $totalqnty, $temprice);
	my ($line, $qty, $item, $desc, $price, $ship, $taxit);

	my ($DiscountOne);
	my ($DiscountTwo);
	my ($CombinedDiscount);
	my ($SubDiscount);
	my ($TaxRate);
	my ($AdjustedTax);
	my ($Tax);
	my ($HandlingCharge);
	my ($InsuranceCharge);
	my ($ShippingCharge);
	my ($FinalProducts) = CommifyNumbers ($frm{'Primary_Products'});
	my ($FinalAmount) = CommifyMoney ($frm{'Final_Amount'});

	my ($msg_tab);
	my ($msg_tab_ck);
	my ($check_additional);
	my ($mail_msg, $save_msg, $save_url, $ship_msg, $bill_msg, $receipt_msg);

	$msg_status = "$FinalProducts Products " if ($frm{'Primary_Products'} > 1);
	$msg_status = "$FinalProducts Product " if ($frm{'Primary_Products'} == 1);
	$msg_status = $msg_status . " $currency $FinalAmount";

	foreach $_ (@header) {push (@tmpfile, $_)}



		# top message
		# top message

	$_ = $frm{'input_payment_options'};	

	if ($_ eq "MAIL") {
	push (@tmpfile, "This is a copy of your original invoice.<br> ");
	push (@tmpfile, "Payment: ");
	push (@tmpfile, "$payment_options_list{$_} ");
	push (@tmpfile, "for Amount ");
	push (@tmpfile, "$currency $FinalAmount. ");


	} elsif ($_ eq "PAYPAL") {

	$paypal_login =~ s/\@/%40/g;
	$paypal_merchant =~ s/ /+/g;
	$paypal_return_url =~ s/:/%3A/g;

	$paypal_str = "<A HREF=\"$paypal_url";
	$paypal_str = $paypal_str . "business=$paypal_login";
	$paypal_str = $paypal_str . "&item_name=$paypal_merchant";
	$paypal_str = $paypal_str . "+Order+$InvoiceNumber+On+$ShortDate";
	$paypal_str = $paypal_str . "&item_number=Invoice+$InvoiceNumber+$ShortDate";
	$paypal_str = $paypal_str . "&amount=$frm{'Final_Amount'}";
	$paypal_str = $paypal_str . "&return=$paypal_return_url";
	$paypal_str = $paypal_str . "\">";

	push (@tmpfile, "Thanks for using PayPal for your Payment of ");
	push (@tmpfile, "$currency $FinalAmount.<br> ");
	push (@tmpfile, "If you did not already submit your payment, then ");
	push (@tmpfile, "$paypal_str\n");
	push (@tmpfile, "Click Here </a>\n");

	} else {

		if ($check_check) {
		push (@tmpfile, "This is a copy of your original invoice.<br> ");
		push (@tmpfile, "Payment: ");
		push (@tmpfile, "$payment_options_list{$_} ");
		push (@tmpfile, ", $frm{'Check_Bank_Name'}, ") if ($frm{'Check_Bank_Name'}) ;
		push (@tmpfile, "for $currency $FinalAmount.  ");

		} elsif ($card_check) {
		push (@tmpfile, "This is a copy of your original invoice.<br> ");
		push (@tmpfile, "Payment: ");
		push (@tmpfile, "$payment_options_list{$_} ");
		push (@tmpfile, "for $currency $FinalAmount.  ");
		}

	}

	push (@tmpfile, "<p> ");




		# Order ID - Date - Invoice Num
		# Order ID - Date - Invoice Num

	push (@tmpfile, "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n");

	push (@tmpfile, "<tr><td valign=bottom nowrap>$font_invoice_num_s \n");
	push (@tmpfile, "Invoice: $InvoiceNumber $font_invoice_num_e </td><td align=right>");

	push (@tmpfile, "<table border=0 cellpadding=0 cellspacing=0> \n");
	push (@tmpfile, "<tr><td align=right nowrap>$datetime_s Order ID: $frm{'OrderID'} $datetime_e </td></tr> \n");
	push (@tmpfile, "<tr><td align=right nowrap>$datetime_s $Date $ShortTime $datetime_e </td></tr></table> \n");
	
	push (@tmpfile, "</td></tr></table> \n");


		# Top information
		# Top information

	push (@tmpfile, "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td width=50% $ship_to_bg_final> \n");

		# Display shipping info, etc.
		# Display shipping info, etc.

	push (@tmpfile, "<table border=0 cellpadding=6 cellspacing=0 width=100% height=100%> ");
	push (@tmpfile, "<tr><td valign=top> \n");


	if ($frm{'Allow_Shipping'}) {
	$msg_tab = "<font size=1 color=black>SHIP TO: </font><br>" ;	

	} elsif ($frm{'Allow_Tax'}) {
	$msg_tab = "<font size=1 color=black>TAX AREA: </font><br>"
	
	} else {
	$msg_tab = "<font size=1 color=black>ORDER INFORMATION: </font><br>" ;	
	$msg_tab = $msg_tab . "$action_message_s $msg_status $action_message_e\n"
	}

	push (@tmpfile, "$msg_tab \n");
	push (@tmpfile, "$action_message_s \n");
	$msg_tab_ck = 0;

	if ($frm{'Ecom_ShipTo_Postal_Name_Prefix'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Name_Prefix'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_First'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Name_First'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_Middle'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Name_Middle'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_Last'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Name_Last'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_Name_Suffix'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Name_Suffix'} \n");
	$msg_tab_ck++;}

	push (@tmpfile, "<br>") if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($frm{'Ecom_ShipTo_Postal_Company'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Company'} <br>\n");
	}

	if ($frm{'Ecom_ShipTo_Postal_Street_Line1'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Street_Line1'} <br>\n");
	}

	if ($frm{'Ecom_ShipTo_Postal_Street_Line2'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_Street_Line2'} <br>\n");
	}


	if ($frm{'Ecom_ShipTo_Postal_City'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_City'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_ShipTo_Postal_StateProv'}) {
	unless ($frm{'Ecom_ShipTo_Postal_StateProv'} eq "NOTINLIST") {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_StateProv'} \n");
	$msg_tab_ck++;}
	}

	if ($frm{'Ecom_ShipTo_Postal_PostalCode'}) {
	push (@tmpfile, "$frm{'Ecom_ShipTo_Postal_PostalCode'} \n");
	$msg_tab_ck++;}
	
	push (@tmpfile, "<br>") if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($frm{'Ecom_ShipTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_ShipTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	push (@tmpfile, "$tc \n");
	}

	push (@tmpfile, "$action_message_e </td></tr></table> \n");
	push (@tmpfile, "</td><td width=50% $bill_to_bg_final> \n");


		# Display Bill To info, etc.
		# Display Bill To info, etc.

	push (@tmpfile, "<table border=0 cellpadding=6 cellspacing=0 width=100% height=100%> ");
	push (@tmpfile, "<tr><td valign=top> \n");

	push (@tmpfile, "<font size=1 color=black>BILL TO: </font><br>");

	$msg_tab_ck = 0;
	push (@tmpfile, "$action_message_s \n");

	if ($frm{'Ecom_BillTo_Postal_Name_Prefix'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Name_Prefix'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_First'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Name_First'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_Middle'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Name_Middle'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_Last'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Name_Last'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_Name_Suffix'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Name_Suffix'} \n");
	$msg_tab_ck++;}

	push (@tmpfile, "<br>") if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($frm{'Ecom_BillTo_Postal_Company'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Company'} <br>\n");
	}

	if ($frm{'Ecom_BillTo_Postal_Street_Line1'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Street_Line1'} <br>\n");
	}

	if ($frm{'Ecom_BillTo_Postal_Street_Line2'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_Street_Line2'} <br>\n");
	}

	if ($frm{'Ecom_BillTo_Postal_City'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_City'} \n");
	$msg_tab_ck++;}

	if ($frm{'Ecom_BillTo_Postal_StateProv'}) {
 	unless ($frm{'Ecom_BillTo_Postal_StateProv'} eq "NOTINLIST") {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_StateProv'} \n");
	$msg_tab_ck++;}
	}

	if ($frm{'Ecom_BillTo_Postal_PostalCode'}) {
	push (@tmpfile, "$frm{'Ecom_BillTo_Postal_PostalCode'} \n");
	$msg_tab_ck++;}
	
	push (@tmpfile, "<br>") if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($frm{'Ecom_BillTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_BillTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	push (@tmpfile, "$tc \n");
	}
	
	push (@tmpfile, "$action_message_e </td></tr></table> \n");
	push (@tmpfile, "</td></tr></table> \n");


		# printing orders in cart
		# printing orders in cart

	push (@tmpfile, "<table $tableborder_color cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr bgcolor=$tableheading> \n");
	push (@tmpfile, "<td align=center>$fontheading <strong>Qty</strong></font></td> \n");
	push (@tmpfile, "<td align=center nowrap>$fontheading <strong>Item Name</strong></font></td> \n");
	push (@tmpfile, "<td align=center>$fontheading <strong>Description</strong></font></td> \n");
	push (@tmpfile, "<td align=center>$fontheading <strong>Price</strong></font></td></tr> \n");

		# populate orders in table / store hidden input
		# populate orders in table / store hidden input

	foreach $line (@orders) {
  	($qty, $item, $desc, $price, $ship, $taxit) = split (/$delimit/, $line);

   	push (@tmpfile, "<tr bgcolor=$tableitem> \n");
	push (@tmpfile, "<td><center> $fontqnty $qty </center></td> \n");

	if ($frm{'Tax_Amount'} > 0 && $identify_tax_items && $taxit) {
	push (@tmpfile, "<td>$fontitem $item $identify_tax_items </td> \n");
	} else {
	push (@tmpfile, "<td>$fontitem $item </td> \n");
	}


		# Format User Input in Description
		# Format User Input in Description

	@list = split (/\|/, $desc);

	$desc = shift (@list);
 	$desc =~ s/\[/</g;
	$desc =~ s/\]/>/g;
	$desc = $fontdesc_s . $desc . $fontdesc_e;

		foreach $li (@list) {
		($lk, $lv) = split (/::/, $li);

			if ($makelist) {
			$desc = $desc . "$font_key_s<li>$lk: $font_key_e$font_val_s$lv$font_val_e";
			} else {
			$desc = $desc . " - $font_key_s$lk: $font_key_e$font_val_s$lv$font_val_e";
			}

		}
		
	push (@tmpfile, "<td>$desc </td> \n");

			# Print row for single item or multiple to sub totals
			# Print row for single item or multiple to sub totals

	if ($qty > 1) {
	push (@tmpfile, "<td align=right>$fontprice \&nbsp\; </td></tr>\n");

		$sub_price = ($qty * $price);
		$totalprice += $sub_price;
		$totalqnty += $qty;
      	$sub_price = sprintf "%.2f", $sub_price;
      	$sub_price = CommifyMoney ($sub_price);
		$price = CommifyMoney ($price);
		$qty = CommifyNumbers ($qty);

   		push (@tmpfile, "<tr bgcolor=$tablesub><td> \&nbsp\; </td>\n");
		push (@tmpfile, "<td colspan=2>$fontsubtext\n"); 
		push (@tmpfile, "Sub Total $qty of $item at ");
		push (@tmpfile, "$currency $price each </font></td>\n");
		push (@tmpfile, "<td align=right nowrap>$fontsub $currency $sub_price </font></td></tr>\n\n");

	} else {

		$totalprice += $price;
		$totalqnty += $qty;
		$price = CommifyMoney ($price);		
		push (@tmpfile, "<td valign=bottom align=right nowrap>$fontprice$currency $price </font></td></tr>\n\n");

	}

	}

   	push (@tmpfile, "</table> \n");
	push (@tmpfile, "$returntofont \n");


		# Display Summary Totals
		# Display Summary Totals

	if ($totalqnty > 1) {$pd = "Products"} else {$pd = "Product"}

	$totalprice = sprintf "%.2f", $totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext Subtotal <strong> \n");
	push (@tmpfile, "$totalqnty </strong> $pd ----> </font></td> \n");
	push (@tmpfile, "<td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency $totalprice </font></td></tr></table> \n");


		# Totals from %frm Formerly %Computations -------------->
		# Totals from %frm Formerly %Computations -------------->
		# CommifyMoney here, keep computations free of formatting


		# Display First Discount
		# Display First Discount

	if ($frm{'Primary_Discount'} > 0) {
	$DiscountOne = CommifyMoney ($frm{'Primary_Discount'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "Discount $frm{'Primary_Discount_Status'} ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> - ");
	push (@tmpfile, "$totalcolor $currency $DiscountOne </font></td></tr></table> \n");
	}


		# Display Coupon Discount
		# Display Coupon Discount
		
	if ($frm{'Coupon_Discount'} > 0) {
	$DiscountTwo = CommifyMoney ($frm{'Coupon_Discount'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "Discount $frm{'Coupon_Discount_Status'} ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> - ");
	push (@tmpfile, "$totalcolor $currency $DiscountTwo </font></td></tr></table> \n");
	}


		# Display Subtotal if discounts
		# Display Subtotal if discounts

	if ($frm{'Combined_Discount'} > 0 ) {
	$SubDiscount = CommifyMoney ($frm{'Sub_Final_Discount'});
	$CombinedDiscount = CommifyMoney ($frm{'Combined_Discount'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "Sub Total After $currency $CombinedDiscount Total Discount ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency <strong>$SubDiscount </strong></font></td></tr></table> \n");
	}


		# Tax Before
		# Tax Before

	if ($frm{'Tax_Amount'} > 0 && $frm{'Tax_Rule'} eq "BEFORE") {
	$TaxRate = ($frm{'Tax_Rate'} * 100);
	$AdjustedTax = CommifyMoney ($frm{'Adjusted_Tax_Amount_Before'});
	$Tax = CommifyMoney ($frm{'Tax_Amount'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "Sales tax $TaxRate\% \(on $currency $AdjustedTax taxable\) ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency $Tax </font></td></tr></table> \n");
	}


		# Handling Charges
		# Handling Charges

	if ($frm{'Handling'} > 0) {
	$HandlingCharges = CommifyMoney ($frm{'Handling'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "Handling $frm{'Handling_Status'} ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency $HandlingCharges </font></td></tr></table> \n");
	}


		# Insurance Charges
		# Insurance Charges

	if ($frm{'Insurance'} > 0) {
	$InsuranceCharges = CommifyMoney ($frm{'Insurance'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "Insurance $frm{'Insurance_Status'} ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency $InsuranceCharges </font></td></tr></table> \n");
	}


		# Shipping Charges
		# Shipping Charges


	if ($frm{'Shipping_Amount'} > 0 ) {
	$ShippingCharges = CommifyMoney ($frm{'Shipping_Amount'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "$frm{'Shipping_Message'} ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency $ShippingCharges </font></td></tr></table> \n");
	}


		# Tax After
		# Tax After

	if ($frm{'Tax_Amount'} > 0 && $frm{'Tax_Rule'} eq "AFTER") {
	$TaxRate = ($frm{'Tax_Rate'} * 100);
	$AdjustedTax = CommifyMoney ($frm{'Adjusted_Tax_Amount_After'});
	$Tax = CommifyMoney ($frm{'Tax_Amount'});

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "Sales tax $TaxRate\% \(on $currency $AdjustedTax taxable\) ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency $Tax </font></td></tr></table> \n");
	}


		# Final Total
		# Final Total

	push (@tmpfile, "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td align=right width=80%>$totaltext \n");
	push (@tmpfile, "<strong>Total Order Amount</strong> ----> </font>\n");
	push (@tmpfile, "</td><td bgcolor=$totalback align=right nowrap> ");
	push (@tmpfile, "$totalcolor $currency <strong> $FinalAmount </strong></font></td></tr></table> \n");



		# Set up additional information
		# Set up additional information

	if ($mail_customer_receipt) {

		# Order: ReceiptTo, BillTo, ShipTo
		if ($frm{'Ecom_ReceiptTo_Online_Email'}) {
		$mail_msg = "An email notice has been mailed to ";		
		$mail_msg = $mail_msg . $frm{'Ecom_ReceiptTo_Online_Email'};

		} elsif ($frm{'Ecom_BillTo_Online_Email'}) {
		$mail_msg = "An email notice has been mailed to ";		
		$mail_msg = $mail_msg . $frm{'Ecom_BillTo_Online_Email'};

		} elsif ($frm{'Ecom_ShipTo_Online_Email'}) {
		$mail_msg = "An email notice has been mailed to ";		
		$mail_msg = $mail_msg . $frm{'Ecom_ShipTo_Online_Email'};

		} else {
		$mail_msg = "An email receipt was not mailed because no customer email address was entered.";
		}

	}
		

	$ship_msg = "Email $frm{'Ecom_ShipTo_Online_Email'} " if ($frm{'Ecom_ShipTo_Online_Email'});

	$bill_msg = "Email $frm{'Ecom_BillTo_Online_Email'} " if ($frm{'Ecom_BillTo_Online_Email'});

	$receipt_msg = "$frm{'Ecom_ReceiptTo_Postal_Name_Prefix'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Prefix'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_First'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_First'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_Middle'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Middle'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_Last'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Last'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Name_Suffix'} " if ($frm{'Ecom_ReceiptTo_Postal_Name_Suffix'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Company'} " if ($frm{'Ecom_ReceiptTo_Postal_Company'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Street_Line1'} " if ($frm{'Ecom_ReceiptTo_Postal_Street_Line1'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_Street_Line2'} " if ($frm{'Ecom_ReceiptTo_Postal_Street_Line2'});
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_City'} " if ($frm{'Ecom_ReceiptTo_Postal_City'});

	if ($frm{'Ecom_ReceiptTo_Postal_StateProv'}) {
	unless ($frm{'Ecom_ReceiptTo_Postal_StateProv'} eq "NOTINLIST") {
	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_StateProv'} ";
	}
	}

	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Postal_PostalCode'} " if ($frm{'Ecom_ReceiptTo_Postal_PostalCode'});

	if ($frm{'Ecom_ReceiptTo_Postal_CountryCode'}) {
	my ($tc) = $frm{'Ecom_ReceiptTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	$receipt_msg = $receipt_msg . "$tc ";
	}

	$receipt_msg = $receipt_msg . "$frm{'Ecom_ReceiptTo_Online_Email'} " if ($frm{'Ecom_ReceiptTo_Online_Email'});

	$check_additional++ if ($mail_msg);
	$check_additional++ if ($ship_msg);
	$check_additional++ if ($bill_msg);
	$check_additional++ if ($receipt_msg);

	if ($check_additional) {

	push (@tmpfile, "<p><table border=0 cellpadding=2 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td>$font_comments \n");
	push (@tmpfile, "<strong>Additional Information:</strong> \n");
	push (@tmpfile, "</font></td></tr> \n");
	push (@tmpfile, "<tr><td>$font_comments \n");
	push (@tmpfile, "$mail_msg <br>") if ($mail_msg);
	push (@tmpfile, "Ship To: $ship_msg <br>") if ($ship_msg);
	push (@tmpfile, "Bill To: $bill_msg <br>") if ($bill_msg);
	push (@tmpfile, "Receipt To: $receipt_msg <br>") if ($receipt_msg);
	push (@tmpfile, "</font></td></tr></table> \n");
	}


		# Set up Mailing or Faxing payment info
		# Set up Mailing or Faxing payment info


	if ($frm{'input_payment_options'} eq "MAIL") {
	$line_str = "__________________________________";

	if ($allow_lines_credit || $allow_lines_check) {

	push (@tmpfile, "<p><table border=0 cellpadding=2 cellspacing=0 width=90%> \n");

	push (@tmpfile, "<tr><td colspan=2>$font_mailfax_form \n");
	push (@tmpfile, "<strong>Complete Any Payment Information For Mailing or Faxing:</strong> \n");
	push (@tmpfile, "</font></td></tr> \n");


		# CC info
		# CC info

	if ($allow_lines_credit) {

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Credit Card Holder's Name </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Credit Card Number </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Credit Card Expiration Date </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");
	}

		# Check info
		# Check info

	if ($allow_lines_check) {

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Name on Checking Account </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Check Number </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Checking Account Number </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Bank Routing Number </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Fraction Number </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Bank Name </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");

	push (@tmpfile, "<tr><td width=10% align=right nowrap>$font_mailfax_form Bank Address </font></td> \n");
	push (@tmpfile, "<td>$line_str </td></tr> \n");
	}

	push (@tmpfile, "</table> \n");
	}
	}




		# Special Instructions comments
		# Special Instructions comments

	if ($frm{'special_instructions'}) {
	push (@tmpfile, "<p><table border=0 cellpadding=2 cellspacing=0 width=90%> \n");
	push (@tmpfile, "<tr><td>$font_comments \n");
	push (@tmpfile, "<strong>Special Instructions or Comments:</strong> \n");
	push (@tmpfile, "</font></td></tr> \n");
	push (@tmpfile, "<tr><td>$font_comments \n");
	push (@tmpfile, "$frm{'special_instructions'} \n");
	push (@tmpfile, "</font></td></tr></table> \n");
	}

	push (@tmpfile, "<p>$returntofont \n");

	foreach $_ (@footer) {push (@tmpfile, $_)}

	# END FINAL HTML COPY 
	# END FINAL HTML COPY 


		# PRINT TO FILE	
		# PRINT TO FILE



	unless (open (FILE, ">$file_path_name") ) { 

		$ErrMsg = "Unable to Create HTML Invoice File: $frm{'OrderID'}";
		&ErrorMessage($ErrMsg);
		}

		print FILE @tmpfile;
		close(FILE);
		chmod (0777, $file_path_name) if ($set_ssl_chmod);


	}


1;


