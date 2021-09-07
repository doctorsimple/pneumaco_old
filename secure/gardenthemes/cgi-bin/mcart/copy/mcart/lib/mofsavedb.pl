# ==================== MOFcart v2.5.10.21.03 ====================== #
# === Save ASCII DB info ========================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

sub SaveASCIIdB {
	my ($itemordered);
	my (@STRIP_ORDERS) = (@orders);
 	my (@STORE_ORDERS) = ();
	my ($q, $i, $d, $p, $s, $t);

		# strip out all pseudo html [<-->]
		foreach (@STRIP_ORDERS) {
   		$_ =~ s/\[([^\]]|\n)*\]//g;
   		$_ =~ s/\[//g;
   		$_ =~ s/\]//g;
		push (@STORE_ORDERS,$_);
		}

	my ($comments) = $frm{'special_instructions'};
	$comments =~ tr/\r\n/ /s;
 	my ($save_url_db) = "Not Saved";
	$save_url_db = $save_invoice_url . $$ . $InvoiceNumber . ".html" if ($save_invoice_html);

	# STORE MAIN INVOICE SHIPPING INFO
	unless (open (DAT, ">>$MOFINVOICES") ) { 
		$ErrMsg = "Unable to Access Data Files: 1";
		&ErrorMessage($ErrMsg);
		}
		flock (DAT,2) if ($lockfiles);
		$_ = $InvoiceNumber;  # Referential Key
		$_ .=  "\|";
		$_ .=  $frm{'OrderID'};
		$_ .=  "\|";
		$_ .=  $ShortDate;
		$_ .=  "\|";
		$_ .=  $Time;
		$_ .=  "\|";
		$_ .=  $frm{'Primary_Products'};
		$_ .=  "\|";
		$_ .=  $frm{'Primary_Price'};
		$_ .=  "\|";
		$_ .=  $frm{'Primary_Discount'};
		$_ .=  "\|";
		$_ .=  $frm{'Compute_Coupons'};	# Coupon Number
		$_ .=  "\|";
		$_ .=  $frm{'Coupon_Discount'};
		$_ .=  "\|";
		$_ .=  $frm{'Coupon_Affiliate_Rate'};
		$_ .=  "\|";
		$_ .=  $frm{'Coupon_Cust_Rate'};
		$_ .=  "\|";
		$_ .=  $frm{'Handling'};
		$_ .=  "\|";
		$_ .=  $frm{'Insurance'};
		$_ .=  "\|";
		$_ .=  $frm{'Shipping_Amount'};
		$_ .=  "\|";
		$_ .=  $frm{'Shipping_Message'};
		$_ .=  "\|";
		$_ .=  $frm{'Total_Weight'};
		$_ .=  "\|";
		$_ .=  $frm{'Tax_Rate'};
		$_ .=  "\|";
		$_ .=  $frm{'Tax_Amount'};
		my($scod) = 0;
		$scod = $cod_charges if ($frm{'input_payment_options'} eq "COD");
      		$scod = sprintf "%.2f", $scod;
		$_ .=  "\|";
		$_ .=  $scod;
		$_ .=  "\|";
		$_ .=  $frm{'Final_Amount'};
		my($dpamt) = sprintf "%.2f", $frm{'Deposit_Amount'};
		$_ .=  "\|";
		$_ .=  $dpamt;
		my($sbal) = 0;
		$sbal = ($frm{'Final_Amount'} - $frm{'Deposit_Amount'}) if ($frm{'Deposit_Amount'}>0);
		$sbal = sprintf "%.2f", $sbal;
		$_ .=  "\|";
		$_ .=  $sbal;
		$_ .=  "\|";
		$_ .=  $Send_API_Amount;
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Name_Prefix'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Name_First'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Name_Middle'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Name_Last'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Name_Suffix'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Company'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Street_Line1'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Street_Line2'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_City'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_StateProv'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_Region'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_CountryCode'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Postal_PostalCode'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Telecom_Phone_Number'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ShipTo_Online_Email'};
		$_ .=  "\|";
		$_ .=  $save_url_db;
		# line ending
		print DAT "$_\n";
		close(DAT);

	# STORE BILLING INFO
	unless (open (DAT, ">>$MOFBILLING") ) { 
		$ErrMsg = "Unable to Access Data Files: 2";
		&ErrorMessage($ErrMsg);
		}
		flock (DAT,2) if ($lockfiles);
		$_ = $InvoiceNumber;  # Referential Key
		$_ .=  "\|";
		$_ .=  $frm{'OrderID'};
		$_ .=  "\|";
		$_ .=  $frm{'input_payment_options'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_Payment_Card_Name'};
		# Credit card number ------->
		$_ .=  "\|";
		# $_ .=  $frm{'Ecom_Payment_Card_Number'};
		$_ .=  'Not Stored';
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_Payment_Card_ExpDate_Month'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_Payment_Card_ExpDate_Day'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_Payment_Card_ExpDate_Year'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_Payment_Card_Verification'};
		$_ .=  "\|";
		$_ .=  $frm{'Check_Holder_Name'};
		$_ .=  "\|";
		$_ .=  $frm{'Check_Number'};
		# Check info ------->
		$_ .=  "\|";
		# $_ .=  $frm{'Check_Account_Number'};
		$_ .=  'Not Stored';
		$_ .=  "\|";
		# $_ .=  $frm{'Check_Routing_Number'};
		$_ .=  'Not Stored';
		$_ .=  "\|";
		$_ .=  $frm{'Check_Fraction_Number'};
		$_ .=  "\|";
		$_ .=  $frm{'Check_Bank_Name'};
		$_ .=  "\|";
		$_ .=  $frm{'Check_Bank_Address'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Name_Prefix'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Name_First'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Name_Middle'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Name_Last'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Name_Suffix'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Company'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Street_Line1'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Street_Line2'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_City'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_StateProv'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_Region'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_CountryCode'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Postal_PostalCode'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Telecom_Phone_Number'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_BillTo_Online_Email'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Name_Prefix'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Name_First'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Name_Middle'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Name_Last'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Name_Suffix'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Company'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Street_Line1'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Street_Line2'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_City'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_StateProv'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_Region'};	
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_CountryCode'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Postal_PostalCode'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Telecom_Phone_Number'};
		$_ .=  "\|";
		$_ .=  $frm{'Ecom_ReceiptTo_Online_Email'};
		# line ending
		print DAT "$_\n";
		close(DAT);

	# STORE ORDERS INFO
	unless (open (DAT, ">>$MOFORDERS") ) { 
		$ErrMsg = "Unable to Access Data Files: 3";
		&ErrorMessage($ErrMsg);
		}
		flock (DAT,2) if ($lockfiles);
		foreach $itemsordered (@STORE_ORDERS) {
  		($q, $i, $d, $p, $s, $t) = split (/$delimit/, $itemsordered);
		$_ = $InvoiceNumber;  # Referential Key
		$_ .=  "\|";
		$_ .=  $frm{'OrderID'};
		$_ .=  "\|";
		$_ .=  $q;
		$_ .=  "\|";
		$_ .=  $i;
		$_ .=  "\|";
		$d =~ s/::/ : /g;
 		my ($d,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$f10,$f11,$f12,$f13,$f14,$f15) = split (/\|/,$d);
		$_ .=  $d;
		$_ .=  "\|";
		$_ .= $f1;
		$_ .=  "\|";
		$_ .= $f2;
		$_ .=  "\|";
		$_ .= $f3;
		$_ .=  "\|";
		$_ .= $f4;
		$_ .=  "\|";
		$_ .= $f5;
		$_ .=  "\|";
		$_ .= $f6;
		$_ .=  "\|";
		$_ .= $f7;
		$_ .=  "\|";
		$_ .= $f8;
		$_ .=  "\|";
		$_ .= $f9;
		$_ .=  "\|";
		$_ .= $f10;
		$_ .=  "\|";
		$_ .= $f11;
		$_ .=  "\|";
		$_ .= $f12;
		$_ .=  "\|";
		$_ .= $f13;
		$_ .=  "\|";
		$_ .= $f14;
		$_ .=  "\|";
		$_ .= $f15;
		$_ .=  "\|";
		$_ .=  $p;
		$_ .=  "\|";
		$_ .=  $s;
		$_ .=  "\|";
		$_ .=  $t;
		# line ending
		print DAT "$_\n";
		}
	close(DAT);

	# STORE COMMENTS INFO
	if ($frm{'special_instructions'}) {
	unless (open (DAT, ">>$MOFTEXT") ) { 
		$ErrMsg = "Unable to Access Data Files: 4";
		&ErrorMessage($ErrMsg);
		}
		flock (DAT,2) if ($lockfiles);
		$_ = $InvoiceNumber;  # Referential Key
		$_ .=  "\|";
		$_ .=  $frm{'OrderID'};
		$_ .=  "\|";
		$_ .=  $comments;
	# line ending
	print DAT "$_\n";
	close(DAT);
	}

	#### END OF PLUG IN SUB ROUTINE
	#### END OF PLUG IN SUB ROUTINE
	
	}

1;
# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

