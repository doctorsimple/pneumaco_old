# ==================== MOFcart v2.5.12.08.04 ====================== #
# === CART PREVIEW SCREEN ========================================= #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Default Cart Preview Screen <mof_preview.pl>
# Called by <mof.cgi> as set <mof.conf> $mof_preview_pg = 'mof_preview.pl';
# ============================================== #
# PREVIEW INVOICE ORDER 
sub PreviewOrder {
	@header = ();
	@footer = ();
	$out = "";
	my (@list) = ();
	my ($msg_tab_ck) = 0;
	my ($nav_top,$nav_bottom) = (0,0);
	my ($key,$val,$li,$lk,$lv,$msg_status,$totalprice,$totalqnty,$temprice,
		$line,$qty,$item,$desc,$price,$ship,$taxit,$DiscountOne,
		$DiscountTwo,$CombinedDiscount,$SubDiscount,$HandlingCharge,
		$InsuranceCharge,$ShippingCharge,$TaxCharge,$msg_tab);
	my ($FinalAmount) = CommifyMoney ($Computations{'Final_Amount'});
	my ($FinalProducts) = CommifyNumbers ($Computations{'Primary_Products'});
	$msg_status = "$FinalProducts Items " if ($Computations{'Primary_Products'} > 1);
	$msg_status = "$FinalProducts Item " if ($Computations{'Primary_Products'} == 1);
	$msg_status = $msg_status . " $currency $FinalAmount ";
	# using shipping and/or tax flags
	$allow_shipping++ if (scalar(@use_shipping));
	$allow_shipping++ if (scalar(keys(%use_method)));
	$allow_tax++ if (scalar(keys(%use_city_tax)));
	$allow_tax++ if (scalar(keys(%use_zipcode_tax)));
	$allow_tax++ if (scalar(keys(%use_state_tax)));
	$allow_tax++ if (scalar(keys(%use_country_tax)));
	&GetTemplateFile($preview_template,"Order Summary,Order Preview Template","preview_template"); 
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	# nav
	$nav_top++ if ($menu_home_top);
	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_viewcart_top);
	$nav_top++ if ($menu_shipinfo_top);
	$nav_top++ if ($menu_payment_top);
	$nav_top++ if ($menu_help_top);
	# changed menus : v2.5 Top Navigation : Summary Pg
	if ($nav_top && $includeOrderSummary) {
	my ($tblCSS,$tdCSS) = ('tblTopPreviousNav','tdTopPreviousNav') if ($twoTopTables);
	my ($tblCSS,$tdCSS) = ('tblTopNav','tdTopNav') unless ($twoTopTables);
	$out .= "<table Class=\"$tblCSS\"><tr>\n";
	# help / home <a href .. >in Conf</a>
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
	# edit cart
	if ($menu_viewcart_top) {
	$out .= "<td Class=\"$tdCSS\">";
	$out .= "<a Class=\"TopPreviousLink\" " if ($twoTopTables);
	$out .= "<a Class=\"TopNavLink\" " unless ($twoTopTables);
	$out .= "href=\"$programfile?viewcart&previouspage=$frm{'previouspage'}\" ";
	$out .= "onmouseover=\"status='$menu_viewcart_top_status';return true\;\" ";
	$out .= "onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$menu_viewcart_top" unless($menu_viewcart_top_btn);
	$out .= "<input class=\"$menu_viewcart_top_btn\" type=\"button\" value=\"myCart \" onClick=\"location.href='$programfile?viewcart&previouspage=$frm{'previouspage'}';\">" if ($menu_viewcart_top_btn);
	$out .= "</a></td>\n" ;
	}
	$out .= "</tr></table><table Class=\"tblTopNav\"><tr>" if ($twoTopTables);
	}
	# functions
	if ($menu_shipinfo_top) {
	$out .= "<td Class=\"tdTopNav\">$menu_shipinfo_top</td>\n" if ($allow_shipping || $allow_tax);
	}
	$out .= "<td Class=\"tdTopNav\">$menu_payment_top</td>\n" if ($menu_payment_top);
	$out .= "</tr></table><br>\n";
	}
	$out .= "<table Class=\"TopTable\"><tr Class=\"topRow\"><td Class=\"topLeft\">";
	$out .= "<table Class=\"tblSum\"><tr Class=\"trSum\"><td Class=\"tdSum\">";
	# CSS replacement : ViewCart Screen Item(s)	
	# shipping info
	if ($allow_shipping) {
	$msg_tab = "SHIP TO:";
	} elsif ($allow_tax) {
	$msg_tab = "$taxstring AREA:";
	} else {
	$msg_tab = "ORDER PREVIEW:<br>";
	$msg_tab .= "$msg_status"
	}
	$out .= "<span Class=\"tabMsg\">$msg_tab</span><br>";
	$out .= "<a Class=\"ShipToAddressLink\" href=\"javascript:document.formShipInfo.submit()\;\" onmouseover=\"status='Click To Change Shipping Information';return true\;\" onmouseout=\"status='&nbsp';return true\;\">" if ($linkAddressON);
	$edit_check_top = 0;
	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Prefix'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Name_Prefix'} ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_Name_First'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Name_First'} ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Middle'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Name_Middle'} ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Last'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Name_Last'} ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Suffix'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Name_Suffix'} ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	$out .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($NewInfo{'Ecom_ShipTo_Postal_Company'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Company'} <br>";
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_Street_Line1'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Street_Line1'} <br>";
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_Street_Line2'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Street_Line2'} <br>";
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_City'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_City'} ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_StateProv'}) {
	unless ($NewInfo{'Ecom_ShipTo_Postal_StateProv'} eq "NOTINLIST") {
	my ($sc) = $NewInfo{'Ecom_ShipTo_Postal_StateProv'};
	$sc =~ s/-/ /g;
	$out .= "$sc ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_Region'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_Region'} ";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_PostalCode'}) {
	$out .= "$NewInfo{'Ecom_ShipTo_Postal_PostalCode'} ";
	$edit_check_top++;
	}
	$out .= "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;
	if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'}) {
	my ($tc) = $NewInfo{'Ecom_ShipTo_Postal_CountryCode'};
	$msg_tab_ck++;
	$tc =~ s/-/ /g;
	$out .= "$tc ";
	$edit_check_top++;
	}
	$out .= "</a>" if ($linkAddressON);
	$out .= "</td></tr></table>\n\n";
	# Top Edit Button - Can't edit unless ship or tax
	if ($allow_shipping || $allow_tax) {
	$out .= "</td><td Class=\"topMid\">$linkShippingTop" if ($linkShippingTop);
	}
	# date
	my($y) = "$MyDate";
	my($x) = "Order ID: $OrderID";
	$y = "<br>" unless ($y);
	$x = "<br>" unless ($show_order_id);
	$out .= "</td><td Class=\"topRight\">$x <br>$y </td></tr></table>\n\n";
	# cart
	$out .= "<table Class=\"ItemTable\"><tr Class=\"hRow\"><td Class=\"hCell\">Qty</td>";
	$out .= "<td Class=\"hCell\">Item</td><td Class=\"hCell\">Description</td><td Class=\"hCell\">Price</td></tr>";
	# orders - store hidden input
	foreach $line (@orders) {
  	($qty,$item,$desc,$price,$ship,$taxit) = split (/$delimit/,$line);
   	$out .= "<tr Class=\"aRow\"><td Class=\"aQtyCell\">$qty</td>";
	$item =~ s/\[/</g;
	$item =~ s/\]/>/g;
	$out .= "<td Class=\"aItemCell\">$item ";
	$out .= " $identify_tax_items" if ($Computations{'Tax_Amount'} > 0 && $identify_tax_items && $taxit);
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
		$out .= "<td Class=\"aDescriptionCell\">$desc </td>";
	# row for single item or multiple to sub totals
	if ($qty > 1 || $allow_fractions) {
		$out .= "<td Class=\"aPriceCell\"><br></td></tr>";
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
	# sub total
	if ($totalqnty > 1) {$pd = "Items"} else {$pd = "Item"}
	$totalprice = sprintf "%.2f",$totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);
	$out .= "<table Class=\"TotalTable\">";
	$out .= "<tr Class=\"sRow1\"><td Class=\"sImage\">";
	if ($linkHaveCoupons && !$use_ARES && scalar(@use_coupons) && $Computations{'Coupon_Discount'}==0) {
	$out .= "$linkHaveCoupons";
	} else {
	$out .= "<br>";
	}
	$out .= "</td><td Class=\"sText1\">Subtotal $totalqnty $pd : </td>";
	$out .= "<td Class=\"sPrice1\">$currency $totalprice </td></tr>";
	# Totals from %Computations ------------------>
	# CommifyMoney here, keep computations free of formatting
	# first discount
	if ($Computations{'Primary_Discount'} > 0 || $Computations{'Primary_Discount_Line_Override'}) {
	$DiscountOne = CommifyMoney ($Computations{'Primary_Discount'});
	$out .= "<tr Class=\"sRow2\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText2\">$Computations{'Primary_Discount_Status'} : </td><td Class=\"sPrice2\">";
	$out .= "$Computations{'Primary_Discount_Amt_Override'} " if ($Computations{'Primary_Discount'} == 0 && $Computations{'Primary_Discount_Amt_Override'});
	$out .= "<span color=\"#FF0D00\">-</span> $currency $DiscountOne " unless ($Computations{'Primary_Discount'} == 0 && $Computations{'Primary_Discount_Amt_Override'});
	$out .= "</td></tr>";
	}
	# coupon discount
	if ($Computations{'Coupon_Discount'} > 0 || $Computations{'Coupon_Discount_Override'}) {
	$DiscountTwo = CommifyMoney ($Computations{'Coupon_Discount'});
	$out .= "<tr Class=\"sRow3\"><td Class=\"sImage\"><br></td><td Class=\"sText3\">";
	$out .= "$linkCouponItem" if ($linkCouponItem && !$use_ARES);
	$out .= "<a Class=\"SummaryTextLink\" href=\"javascript:document.formShipInfo.submit()\;\" onmouseover=\"status='Click To Change Coupon Information';return true\;\" onmouseout=\"status='&nbsp';return true\;\">" if ($linkCouponON && !$use_ARES);
	$out .= "$Computations{'Coupon_Discount_Status'}";
	$out .= "</a>" if ($linkCouponON && !$use_ARES);
	$out .= " : </td><td Class=\"sPrice3\"><span color=\"#FF0D00\">-</span> $currency $DiscountTwo </td></tr>";
	}
	# subtotal if discounts
	if ($Computations{'Combined_Discount'} > 0 ) {
	$SubDiscount = CommifyMoney ($Computations{'Sub_Final_Discount'});
	$CombinedDiscount = CommifyMoney ($Computations{'Combined_Discount'});
	$out .= "<tr Class=\"sRow4\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText4\">Sub Total After $currency $CombinedDiscount Total Discount : </td>";
	$out .= "<td Class=\"sPrice4\">$currency $SubDiscount </td></tr>";
	}
	# tax before
	if ($Computations{'Tax_Rule'} eq "BEFORE") {
	if ($Computations{'Tax_Amount'} > 0 || $Computations{'Tax_Line_Override'}) {
	$TaxCharge = CommifyMoney ($Computations{'Tax_Amount'});
	$out .= "<tr Class=\"sRow5\"><td Class=\"sImage\"><br></td><td Class=\"sText5\">";
	$out .= "$linkTaxItem" if ($linkTaxItem);
	$out .= "<a Class=\"SummaryTextLink\" href=\"javascript:document.formShipInfo.submit()\;\" onmouseover=\"status='Click To Change $taxstring Information';return true\;\" onmouseout=\"status='&nbsp';return true\;\">" if ($linkTaxON);
	$out .= "$Computations{'Tax_Message'}";
	$out .= "</a>" if ($linkTaxON);
	$out .= " : </td><td Class=\"sPrice5\"> ";
	$out .= "$Computations{'Tax_Amt_Override'} " if ($Computations{'Tax_Amount'} == 0 && $Computations{'Tax_Amt_Override'});
	$out .= "$currency $TaxCharge " unless ($Computations{'Tax_Amount'} == 0 && $Computations{'Tax_Amt_Override'});
	$out .= "</td></tr>";
	}}
	# handling
	if ($Computations{'Handling'} > 0 || $Computations{'Handling_Line_Override'}) {
	$HandlingCharge = CommifyMoney ($Computations{'Handling'});
	$out .= "<tr Class=\"sRow6\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText6\">$Computations{'Handling_Status'} : </td><td Class=\"sPrice6\">";
	$out .= "$Computations{'Handling_Amt_Override'} " if ($Computations{'Handling'} == 0 && $Computations{'Handling_Amt_Override'});
	$out .= "$currency $HandlingCharge " unless ($Computations{'Handling'} == 0 && $Computations{'Handling_Amt_Override'});;
	$out .= "</td></tr>";
	}
	# insurance
	if ($Computations{'Insurance'} > 0 || $Computations{'Insurance_Line_Override'}) {
	$InsuranceCharge = CommifyMoney ($Computations{'Insurance'});
	$out .= "<tr Class=\"sRow7\"><td Class=\"sImage\"><br></td><td Class=\"sText7\">";
	$out .= "$linkInsuranceItem" if ($linkInsuranceItem);
	$out .= "<a Class=\"SummaryTextLink\" href=\"javascript:document.formShipInfo.submit()\;\" onmouseover=\"status='Click To Change Insurance Information';return true\;\" onmouseout=\"status='&nbsp';return true\;\">" if ($linkInsuranceON);
	$out .= "$Computations{'Insurance_Status'}";
	$out .= "</a>" if ($linkInsuranceON);
	$out .= " : </td><td Class=\"sPrice7\">";
	$out .= "$Computations{'Insurance_Amt_Override'} " if ($Computations{'Insurance'} == 0 && $Computations{'Insurance_Amt_Override'});
	$out .= "$currency $InsuranceCharge " unless ($Computations{'Insurance'} == 0 && $Computations{'Insurance_Amt_Override'});
	$out .= "</td></tr>";
	}
	# shipping
	if ($Computations{'Shipping_Amount'} > 0 || $Computations{'Shipping_Line_Override'}) {
	$ShippingCharge = CommifyMoney ($Computations{'Shipping_Amount'});
	$out .= "<tr Class=\"sRow8\"><td Class=\"sImage\"><br></td><td Class=\"sText8\">";
	$out .= "$linkShippingItem" if ($linkShippingItem);
	$out .= "<a Class=\"SummaryTextLink\" href=\"javascript:document.formShipInfo.submit()\;\" onmouseover=\"status='Click To Change Shipping Information';return true\;\" onmouseout=\"status='&nbsp';return true\;\">" if ($linkShippingON);
	$out .= "$Computations{'Shipping_Message'}";
	$out .= "</a>" if ($linkShippingON);
	$out .= " : </td><td Class=\"sPrice8\">";
	$out .= "$Computations{'Shipping_Amt_Override'} " if ($Computations{'Shipping_Amount'} == 0 && $Computations{'Shipping_Amt_Override'});
	$out .= "$currency $ShippingCharge " unless ($Computations{'Shipping_Amount'} == 0 && $Computations{'Shipping_Amt_Override'});
	$out .= "</td></tr>";
	}
	# tax after
	if ($Computations{'Tax_Rule'} eq "AFTER") {
	if ($Computations{'Tax_Amount'} > 0 || $Computations{'Tax_Line_Override'}) {
	$TaxCharge = CommifyMoney ($Computations{'Tax_Amount'});
	$out .= "<tr Class=\"sRow5\"><td Class=\"sImage\"><br></td><td Class=\"sText5\">";
	$out .= "$linkTaxItem" if ($linkTaxItem);
	$out .= "<a Class=\"SummaryTextLink\" href=\"javascript:document.formShipInfo.submit()\;\" onmouseover=\"status='Click To Change $taxstring Information';return true\;\" onmouseout=\"status='&nbsp';return true\;\">" if ($linkTaxON);
	$out .= "$Computations{'Tax_Message'}";
	$out .= "</a>" if ($linkTaxON);
	$out .= " : </td><td Class=\"sPrice5\">";
	$out .= "$Computations{'Tax_Amt_Override'} " if ($Computations{'Tax_Amount'} == 0 && $Computations{'Tax_Amt_Override'});
	$out .= "$currency $TaxCharge " unless ($Computations{'Tax_Amount'} == 0 && $Computations{'Tax_Amt_Override'});
	$out .= "</td></tr>";
	}}
	# total
	$out .= "<tr Class=\"sRow9\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText9\">Total Order Amount : </td>";
	$out .= "<td Class=\"sPrice9\">$currency $FinalAmount </td></tr>";
	# conversion : May 12, 2003 6:44:04 PM
	if ($currencyConvertRate > 0.00) {
	my($altCurrency) = CommifyMoney ($Computations{'Final_ConvertAmount'});
	$out .= "<tr Class=\"sRow10\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText10\">$currencyConvertTitle : </td>";
	$out .= "<td Class=\"sPrice10\"> $currencyConvertSymbol  $altCurrency </td></tr>";
	}
	$out .= "</table><p>\n\n";
	# changed menus : v2.5 Bottom Navigation : Shipping Pg
	my ($tblCSS,$tdCSS) = ('tblBottomPreviousNav','tdBottomPreviousNav') if ($twoBottomTables);
	my ($tblCSS,$tdCSS) = ('tblBottomNav','tdBottomNav') unless ($twoBottomTables);
	$out .= "<table Class=\"$tblCSS\"><tr>\n";
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
	}
	# edit cart
	if ($menu_viewcart_bottom) {
	$out .= "<td Class=\"$tdCSS\">";
	$out .= "<a Class=\"BottomPreviousLink\" " if ($twoBottomTables);
	$out .= "<a Class=\"BottomNavLink\" " unless ($twoBottomTables);
	$out .= "href=\"$programfile?viewcart&previouspage=$frm{'previouspage'}\" ";
	$out .= "onmouseover=\"status='$menu_viewcart_bottom_status';return true\;\" ";
	$out .= "onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$menu_viewcart_bottom" unless($menu_viewcart_bottom_btn);
	$out .= "<input class=\"$menu_viewcart_bottom_btn\" type=\"button\" value=\"myCart \" onClick=\"location.href='$programfile?viewcart&previouspage=$frm{'previouspage'}';\">" if ($menu_viewcart_bottom_btn);
	$out .= "</a></td>\n" ;
	}
	$out .= "</tr></table><table Class=\"tblBottomNav\"><tr>" if ($twoBottomTables);
	}
	# edit Shipping Info
	if (scalar(@UsingInfoFields)) {
	if ($menu_shipinfo_bottom) {
	$out .= "<td Class=\"tdBottomNav\">";
	$out .= "<FORM name=\"formShipInfo\" method=POST action=\"$programfile\">\n";
	$out .= "<input type=hidden name=\"postmode\" value=\"PREVIEW\">\n";
	$out .= "<input type=hidden name=\"submit_preview_info\" value=\"EDITING\">\n";
	$out .= "<input type=hidden name=\"OrderID\" value=\"$frm{'OrderID'}\">\n";
	$out .= "<input type=hidden name=\"InfoID\" value=\"$InfoID\">\n";
	$out .= "<input type=hidden name=\"previouspage\" value=\"$frm{'previouspage'}\">\n\n";
		foreach $line (@orders) {
		$out .= "<input type=hidden name=\"order\" value=\"$line\">\n";
		}
	$out .= "</FORM>$menu_shipinfo_bottom</td>\n";
	}}
	# Checkout
	$out .= "<td Class=\"tdBottomNav\">";
	$out .= "<FORM name=\"formCheckout\" method=\"post\" action=\"$paymentfile\">\n";
	# pass collected data ---------------->
	# This is where you would put your hidden field to bypass 
	# The Billing Info page: example
	# $out .= "<input type=\"hidden\" name=\"input_payment_options\" value=\"MAIL\">\n";
	if ($zb_passthrough) {
	unless ($Computations{'Final_Amount'}>0) {
	$out .= "<input type=\"hidden\" name=\"input_payment_options\" value=\"ZEROPAY\">\n";
	}}
   	while (($key,$val) = each (%Computations)) { 
	$out .= "<input type=\"hidden\" name=\"$key\" value=\"$val\">\n"}
	foreach (@orders) {
	$out .= "<input type=\"hidden\" name=\"order\" value=\"$_\">\n"}
   	while (($key,$val) = each (%NewInfo)) { 
	$out .= "<input type=\"hidden\" name=\"$key\" value=\"$val\">\n"}
	$out .= "<input type=\"hidden\" name=\"Allow_Tax\" value=\"$allow_tax\">\n";
	$out .= "<input type=\"hidden\" name=\"Allow_Shipping\" value=\"$allow_shipping\">\n";
	$out .= "<input type=\"hidden\" name=\"OrderID\" value=\"$frm{'OrderID'}\">\n";
	$out .= "<input type=\"hidden\" name=\"InfoID\" value=\"$InfoID\">\n";
	$out .= "<input type=\"hidden\" name=\"previouspage\" value=\"$frm{'previouspage'}\">\n";
	$out .= "</FORM>$menu_payment_bottom</td></tr></table>\n";
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$out \n\n";
	print "@footer \n\n";
  }


# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;



