# ==================== MOFcart v2.5.10.21.03 ====================== #
# === VIEW CART SCREEN ============================================ #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Default View Cart Screen <mof_view.pl>
# Called by <mof.cgi> as set <mof.conf> $mof_view_pg = 'mof_view.pl';

# ACCEPT ORDER 
sub AcceptOrder {
	@header = ();
	@footer = ();
	$out = "";
	my ($i)=0;
	my (@list) = ();
	my ($nav_top, $nav_bottom) = (0,0);
	my ($statusmsg,$li,$lk,$lv,$msg_status,$msg_n,$totalprice,$totalqnty,
		$temprice,$line,$qty,$item,$desc,$price,$ship,$taxit);
	# continue shopping URL
	if ($ContinueShopURL) {
		$previouspage = $ContinueShopURL;
	} elsif ($frm{'previouspage'}) {
		$previouspage = $frm{'previouspage'};
	} else {
   	    	if ($ERRORMODE==2 && $ENV{'HTTP_REFERER'} =~ /$ErrMsgRedirect/i) {
			$previouspage = $ErrMsgViewCart;
		} else {
			if ($frm{'RET_URL'}) {
				$previouspage = $frm{'RET_URL'};
			} else {			
				$previouspage = $ENV{'HTTP_REFERER'};
	}}}
	$msg_n = scalar(@orders);
	$msg_status = "Viewing $msg_n Items" if ($msg_n > 1);
	$msg_status = "Viewing $msg_n Item" if ($msg_n == 1);
	if ($msg_n == 0) {$msg_status = "Viewing No Items"}
	&GetTemplateFile($accept_order_template,"View Cart Main Template","accept_order_template"); 
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	$OrderID = $cookieOrderID if ($cookieOrderID);
	$OrderID = $OrderID if ($OrderID);
	# nav
	$nav_top++ if ($menu_home_top);
	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_help_top);
	$nav_top++ if ($menu_update_top);
	$nav_top++ if ($menu_delete_top);
	$nav_top++ if ($menu_preview_top);
	unless ($msg_n) {
	$out .= "<SPAN Class=\"ValidationMessageText\">";
	$out .= "Your Cart Is Empty<p></SPAN>"}
	# changed menus : v2.5 Top Navigation : ViewCart Pg
	if ($nav_top && $includeViewCart) {
	my ($tblCSS,$tdCSS) = ('tblTopPreviousNav','tdTopPreviousNav') if ($twoTopTables);
	my ($tblCSS,$tdCSS) = ('tblTopNav','tdTopNav') unless ($twoTopTables);
	$out .= "<table Class=\"$tblCSS\"><tr>\n";
	# help / home
	if ($menu_previous_top or $menu_help_top or $menu_home_top) {
	$out .= "<td Class=\"$tdCSS\">$menu_help_top</td>\n" if ($menu_help_top); 
	$out .= "<td Class=\"$tdCSS\">$menu_home_top</td>\n" if ($menu_home_top);
	# previous pg
	if ($menu_previous_top) {
	$out .= "<td Class=\"$tdCSS\">";
	$out .= "<a Class=\"TopPreviousLink\" " if ($twoTopTables);
	$out .= "<a Class=\"TopNavLink\" " unless ($twoTopTables);
	$out .= "href=\"$previouspage\" ";
	$out .= "onmouseover=\"status='$menu_previous_top_status';return true\;\" ";
	$out .= "onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$menu_previous_top" unless($menu_previous_top_btn);
	$out .= "<input Class=\"$menu_previous_top_btn\" type=\"button\" value=\"Shopping\" onclick=\"window.open('$previouspage','MAIN')\"\;>" if ($menu_previous_top_btn);
	$out .= "</a></td>\n" ;
	}
	$out .= "</tr></table><table Class=\"tblTopNav\"><tr>" if ($twoTopTables);
	}
	# functions
	$out .= "<td Class=\"tdTopNav\">$menu_update_top</td>\n" if ($menu_update_top && $msg_n);
	$out .= "<td Class=\"tdTopNav\">$menu_delete_top</td>\n" if ($menu_delete_top && $msg_n);
	$out .= "<td Class=\"tdTopNav\">$menu_preview_top</td>\n" if ($menu_preview_top && $msg_n);
	$out .= "</tr></table><br>\n\n";
	}
	# CSS replacement : ViewCart Screen Item(s)	
	my($y) = "$MyDate";
	my($x) = "Order ID: $OrderID";
	$y = "<br>" unless ($y);
	$x = "<br>" unless ($show_order_id);
	$out .= "<table Class=\"TopTable\"><tr Class=\"topRow\">";
	$out .= "<td Class=\"topLeft\">$msg_status<br>$msg_function</td>";
	$out .= "<td Class=\"topRight\">$x <br>$y </td></tr></table>\n\n";
	# Update form
	$out .= "<FORM name=\"formUpdateCart\" method=POST action=\"$programfile\">\n";
	$out .= "<input type=hidden name=\"postmode\" value=\"UPDATE\">\n";
	$out .= "<input type=hidden name=\"OrderID\" value=\"$OrderID\">\n";
	$out .= "<input type=hidden name=\"previouspage\" value=\"$previouspage\">\n";
	$out .= "<table Class=\"ItemTable\"><tr Class=\"hRow\"><td Class=\"hCell\">Qty</td>";
	$out .= "<td Class=\"hCell\">Item</td><td Class=\"hCell\">Description</td><td Class=\"hCell\">Price</td></tr>";
	# hidden input
	foreach $line (@orders) {
	++$i;
  	($qty,$item,$desc,$price,$ship,$taxit) = split (/$delimit/,$line);
   	$out .= "<tr Class=\"aRow\"><td Class=\"aQtyCell\">\n";
	# auto ReCalculate
	if ($autoReCalculate) {
	$out .= "<input Class=\"QuantityBoxFormat\" type=\"text\" name=\"quantity_$i\" value=\"$qty\" size=\"4\" maxlength=\"4\" ";
	$out .= "onchange=\"javascript:document.formUpdateCart.submit()\;\">\n";
	} else {
	$out .= "<input Class=\"QuantityBoxFormat\" type=\"text\" name=\"quantity_$i\" value=\"$qty\" size=\"4\" maxlength=\"4\">\n";
	}
	# trash
	if ($trash_can_mode) {
	# remove pseudo html
	$statusmsg = $item;
	$statusmsg =~ s/\[/</g;
	$statusmsg =~ s/\]/>/g;
   	$statusmsg =~ s/<([^>]|\n)*>//g;
	my($del) = $trash_can_icon;
	$del =~ (s/>/ alt=\"Remove \($qty\) of $statusmsg from Cart\">/);
	$out .= "<a Class=\"TrashCanLink\" href=\"javascript:document.formTrash_$i.submit()\;\" ";
	$out .= "onmouseover=\"status='Remove $qty of $statusmsg from this Cart';return true\;\" onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$del</a>\n";
	}
	$out .= "</td><td Class=\"aItemCell\">";
	$out .= "<input type=hidden name=\"product_$i\" value=\"$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit\">";
	$item =~ s/\[/</g;
	$item =~ s/\]/>/g;
	$out .= "$item</td>";
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
	# end update form
   	$out .= "</tr></table></FORM>\n\n";
	# summary
	if ($totalqnty > 1) {$pd = "Items"} else {$pd = "Item"}
	$Computations{'Primary_Price'} = $totalprice;
	$Computations{'Primary_Products'} = $totalqnty;
	$Computations{'Primary_Discount'} = &ComputeDiscount if scalar(@use_discount);
	my ($discountline) = $Computations{'Primary_Discount'};
	$discounttotal = ($totalprice - $Computations{'Primary_Discount'});
	$discounttotal = sprintf "%.2f",$discounttotal;
	$discounttotal = CommifyMoney ($discounttotal);
	# currency conversion : May 12, 2003 6:10:12 PM
	# needs ability to use different money formats same invoice
	if ($currencyConvertRate > 0.00) {
	$totalConverted = ($totalprice * $currencyConvertRate) ;
	$totalConverted = sprintf "%.2f",$totalConverted;
	$totalConverted = CommifyMoney ($totalConverted);
	}
	$totalprice = sprintf "%.2f",$totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);
	$Computations{'Primary_Discount'} = CommifyNumbers($Computations{'Primary_Discount'});
	# sub total
	$out .= "<table Class=\"TotalTable\"><tr Class=\"sRow1\"><td Class=\"sImage\">";
	$out .= "$linkReCalculate\n" if ($linkReCalculate && $msg_n);
	$out .= "<br>" unless ($linkReCalculate && $msg_n);
	$out .= "</td><td Class=\"sText1\">Subtotal $totalqnty $pd : </td>";
	$out .= "<td Class=\"sPrice1\">$currency $totalprice </td></tr>";
	# default discount
	if ($discountline > 0 || $Computations{'Primary_Discount_Line_Override'}) {
	$out .= "<tr Class=\"sRow2\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText2\">$Computations{'Primary_Discount_Status'} : </td>";
	$out .= "<td Class=\"sPrice2\">";
	$out .= "$Computations{'Primary_Discount_Amt_Override'} " if ($discountline == 0 && $Computations{'Primary_Discount_Amt_Override'});
	$out .= "<span color=\"#FF0D00\">-</span> $currency $Computations{'Primary_Discount'} " unless ($discountline == 0 && $Computations{'Primary_Discount_Amt_Override'});
	$out .= "</td></tr>";
	# sub total after default discount
	$out .= "<tr Class=\"sRow4\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText4\">Subtotal After Discount : </td>";
	$out .= "<td Class=\"sPrice4\">$currency $discounttotal </td></tr>";
	}
	# Simple currency conversion : May 12, 2003 5:32:25 PM
	if ($currencyConvertRate  > 0.00) {
	$out .= "<tr Class=\"sRow10\"><td Class=\"sImage\"><br></td>";
	$out .= "<td Class=\"sText10\">$currencyConvertTitle : </td>";
	$out .= "<td Class=\"sPrice10\">$currencyConvertSymbol $totalConverted </td></tr>";
	}
	$out .= "</table><p> ";
	# changed menus : v2.5 Bottom Navigation : ViewCart Pg
	my ($tblCSS,$tdCSS) = ('tblBottomPreviousNav','tdBottomPreviousNav') if ($twoBottomTables);
	my ($tblCSS,$tdCSS) = ('tblBottomNav','tdBottomNav') unless ($twoBottomTables);
	$out .= "<table Class=\"$tblCSS\"><tr>\n";
	# help / home <a href .. >in Conf</a>
	if ($menu_previous_bottom or $menu_help_bottom or $menu_home_bottom) {
	$out .= "<td Class=\"$tdCSS\">$menu_help_bottom</td>\n" if ($menu_help_bottom); 
	$out .= "<td Class=\"$tdCSS\">$menu_home_bottom</td>\n" if ($menu_home_bottom);
	# previous pg <a href .. >Fixed</a>
	if ($menu_previous_bottom) {
	$out .= "<td Class=\"$tdCSS\">";
	$out .= "<a Class=\"BottomPreviousLink\" " if ($twoBottomTables);
	$out .= "<a Class=\"BottomNavLink\" " unless ($twoBottomTables);
	$out .= "href=\"$previouspage\"  ";
	$out .= "onmouseover=\"status='$menu_previous_bottom_status';return true\;\" ";
	$out .= "onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$menu_previous_bottom" unless($menu_previous_bottom_btn);
	$out .= "<input Class=\"$menu_previous_bottom_btn\" type=\"button\" value=\"Shopping\" onclick=\"window.open('$previouspage','MAIN')\"\;>" if ($menu_previous_bottom_btn);
	$out .= "</a></td>\n" ;
	}
	$out .= "</tr></table><table Class=\"tblBottomNav\"><tr>" if ($twoBottomTables);
	}
	# update
	$out .= "<td Class=\"tdBottomNav\">$menu_update_bottom</td>" if ($menu_update_bottom && $msg_n);
	# delete
	if ($menu_delete_bottom && $msg_n) {
	$out .= "<td Class=\"tdBottomNav\">";
	$out .= "<FORM name=\"formDeleteCart\" method=POST action=\"$programfile\">\n";
	$out .= "<input type=hidden name=\"postmode\" value=\"DELETE\">\n";
	$out .= "<input type=hidden name=\"deleted_items\" value=\"$msg_n\">\n";
	$out .= "<input type=hidden name=\"OrderID\" value=\"$OrderID\">\n";
	$out .= "<input type=hidden name=\"previouspage\" value=\"$previouspage\">\n";
	$out .= "</FORM>\n";
	$out .= "$menu_delete_bottom</td>\n";
	}
	# next
	if ($menu_preview_bottom && $msg_n) {
	$out .= "<td Class=\"tdBottomNav\">";
	$out .= "<FORM name=\"formPreviewSubmit\" method=POST action=\"$programfile\">\n";
	$out .= "<input type=hidden name=\"postmode\" value=\"PREVIEW\">\n";
	$out .= "<input type=hidden name=\"OrderID\" value=\"$OrderID\">\n";
	$out .= "<input type=hidden name=\"previouspage\" value=\"$previouspage\">\n";
		foreach $line (@orders) {
		$out .= "<input type=hidden name=\"order\" value=\"$line\">\n"
		}
	$out .= "</FORM>\n";
	$out .= "$menu_preview_bottom</td>\n";
	}
	$out .= "</tr></table>";
	if ($msg_n) {
	$out .= "<p>$reCalcMsg";
	} else {
	if ($showPlacesToGo) {
	$out .= "<SPAN Class=\"ValidationMessageText\"><p>There are no items in your cart<br></SPAN>";
	if ($menu_previous_bottom || $menu_home_bottom) {
	$out .= "<SPAN Class=\"DefaultText\">Places to go: ";
	if ($menu_previous_bottom) {
	$out .= "<a Class=\"BottomNavLink\" ";
	$out .= "href=\"$previouspage\"  ";
	$out .= "onmouseover=\"status='$menu_previous_bottom_status';return true\;\" ";
	$out .= "onmouseout=\"status='&nbsp';return true\;\">";
	$out .= "$menu_previous_bottom" unless($menu_previous_bottom_btn);
	$out .= "<input Class=\"$menu_previous_bottom_btn\" type=\"button\" value=\"Shopping\" onclick=\"window.open('$previouspage','MAIN')\"\;>" if ($menu_previous_bottom_btn);
	$out .= "</a>\n" ;
	}
	$out .= " $menu_home_bottom" if ($menu_home_bottom);
	$out .= "</SPAN>";
	}}}
	# trash
	if ($trash_can_mode) {
	my ($i,$ii) = (0,0);
	$out .= "\n\n";
	foreach $line (@orders) {
	++$i;
	$out .= "<FORM name=\"formTrash_$i\" method=POST action=\"$programfile\">\n";
	$out .= "<input type=hidden name=\"postmode\" value=\"UPDATE\">\n";
	$out .= "<input type=hidden name=\"OrderID\" value=\"$OrderID\">\n";
	$out .= "<input type=hidden name=\"previouspage\" value=\"$previouspage\">\n";
		$ii=0;
		foreach (@orders) {
  		unless ($line eq $_) {
		++$ii;
  		($qty,$item,$desc,$price,$ship,$taxit) = split (/$delimit/,$_);
		$out .= "<input type=hidden name=\"quantity_$ii\" value=\"$qty\">\n";
		$out .= "<input type=hidden name=\"product_$ii\" ";
		$out .= "value=\"$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit\">\n";
		}}
	$out .= "</FORM>\n";
	}}
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$out \n\n";
	print "@footer \n\n";
 }

# ACCEPT ORDER POP
sub AcceptOrderPop {
	@header = ();
	@footer = ();
	$out = "";
	my (@list);
	my ($set) = $frm{'POP_VIEWCART'};
	my ($q,$i,$d,$p,$s,$t,$k,$v);
	my($newqnty,$newprice) = (0,0);
	my($totalqnty,$totalprice) = (0,0);
	# cart total
	foreach (@orders) {
	($q,$i,$d,$p,$s,$t) = split(/$delimit/);
		$totalqnty += ($q);
		$totalprice += ($q * $p);
 		}
	my($str) = "item";
	$str .= "s" if ($totalqnty > 1);
	$Computations{'Primary_Price'} = $totalprice;
	$Computations{'Primary_Products'} = $totalqnty;
	# discount
	if (scalar(@use_discount)) {
	if ($set =~ /8/ or $set =~ /9/) {
	$Computations{'Primary_Discount'} = &ComputeDiscount;
	$discountline = $Computations{'Primary_Discount'};
	$discounttotal = ($totalprice - $Computations{'Primary_Discount'});
	$totalprice = $discounttotal if ($discountline > 0 && $set =~ /9/);
	$discounttotal = sprintf "%.2f",$discounttotal;
	$discounttotal = CommifyMoney ($discounttotal);
	$Computations{'Primary_Discount'} = CommifyNumbers($Computations{'Primary_Discount'});
	}}
	# adjusted total
	$totalprice = sprintf "%.2f",$totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);
	&GetTemplateFile($accept_order_template_pop,"View Cart Pop Template","accept_order_template_pop"); 
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	# alternate header
	$out .= "<P Class=\"SectionHeadings\">$frm{'POP_MSG'}</P><p>" if ($frm{'POP_MSG'});
	# option(s) 1,2,3,4 : new item(s) in cart
	if ($set =~ /1/ or $set =~ /2/ or $set =~ /3/ or $set =~ /4/) {
	$out .= "<table Class=\"ItemTable\">";
	foreach (@NewOrder) {
	$_ =~ s/\[/</g;
	$_ =~ s/\]/>/g;
	$_ =~ s/<([^>]|\n)*>//g if ($strip_html_pop);
	($q,$i,$d,$p,$s,$t) = split(/$delimit/);
	$newqnty += ($q);
	$newprice += ($q * $p);
	$p = ($q * $p);
	$p = sprintf "%.2f",$p;
		@list = split (/\|/,$d);
		$d = shift (@list);
		foreach (@list) {
		($k,$v) = split (/::/,$_);
			if ($makelist) {
			$d .= "<li Class=\"MakeList\">$k $v</li>";
			} else {
			$d .= "$k $v";
			}
		}
	$out .= "<tr Class=\"aRow\">" if ($set =~ /1/ or $set =~ /2/ or $set =~ /3/);
	$out .= "<td Class=\"aQtyCell\">$q</td>" if ($set =~ /1/);
	$out .= "<td Class=\"aItemCell\">$i</td>" if ($set =~ /2/);
	$out .= "<td Class=\"aPriceCell\">$currency $p </td>" if ($set =~ /3/);
	$out .= "</tr>" if ($set =~ /1/ or $set =~ /2/ or $set =~ /3/);
		# adapt to top row - need at least item
		if ($set =~ /4/) {
		$out .= "<tr Class=\"bRow\">";
		$out .= "<td Class=\"bQtyCell\"><br></td>" if ($set =~ /1/);
		$out .= "<td ";
		$out .= "colspan=2 " if ($set =~ /2/ and $set =~ /3/);
		$out .= "Class=\"bDescriptionCell\">$d</td>";
		$out .= "</tr>";
		}
	}
	$out .= "</table>\n";
	}
	# option(s) 5,6,7,8,9 : total(s)
	$out .= "<table Class=\"TotalTable\">";
	# 5 new total
	if ($set =~ /5/) {
	my($newstr) = "Item";
	$newstr .= "s" if ($newqnty > 1);
	$newprice = sprintf "%.2f",$newprice;
	$newprice = CommifyMoney ($newprice);
	$newqnty = CommifyNumbers ($newqnty);
	$out .= "<tr Class=\"cRow\"><td Class=\"cText\"> $newqnty New $newstr : </td><td Class=\"cPrice\">$currency $newprice </td></tr>";
	}
	# 6 current summary
	if ($set =~ /6/) {
	$out .= "<tr Class=\"mRow\"><td Class=\"mText\">Your current cart summary : </td><td Class=\"mPrice\"><br></td></tr>";
	}
	# 7 total
	if ($set =~ /7/ or $set =~ /8/ or $set =~ /9/) {
	$out .= "<tr Class=\"tRow\"><td Class=\"tText\">$totalqnty $str in cart : </td>";
	$out .= "<td  Class=\"tPrice\">$currency $totalprice </td></tr>";
	}
	# 8 discount
	unless ($set =~ /9/) {
	if ($set =~ /8/) {
	if ($discountline > 0 || $Computations{'Primary_Discount_Line_Override'}) {
	$out .= "<tr Class=\"dRow\"><td Class=\"dText\">$Computations{'Primary_Discount_Status'} : </td>";
	$out .= "<td  Class=\"dPrice\">";
		if ($discountline == 0 && $Computations{'Primary_Discount_Amt_Override'}) {
		$out .= "$Computations{'Primary_Discount_Amt_Override'} ";
		} else {
		$out .= "- $currency $Computations{'Primary_Discount'} ";
		}
	$out .= "</td></tr>";
	}}}
	# 8 sub total
	unless ($set =~ /9/) {
	if ($set =~ /8/) {
	if ($discountline > 0 || $Computations{'Primary_Discount_Line_Override'}) {
	$out .= "<tr Class=\"tRow\"><td Class=\"tText\">Subtotal After Discount : </td>";
	$out .= "<td  Class=\"tPrice\">$currency $discounttotal </td></tr>";
	}}}
	# Alt Currency for Popup goes here : May 12, 2003 9:44:22 PM
	$out .= "</table>\n";
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$out \n\n";
	print "@footer \n\n";
 }


# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;

