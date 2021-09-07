# ==================== MOFcart v2.5.12.08.04 ====================== #
# === BILLING INFO SCREEN ========================================= #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Default Billing Information Screen <mof_billto.pl>
# Called by <mofpay.cgi> as set <mofpay.conf> $mof_billto_pg = 'mof_billto.pl';
# ============================================== #
#  HOW TO ADD NEW FIELDS TO THE BILLING INFO PAGE  
# ============================================== #
# 1. ADD FIELD(S) (mofpay.cgi)
#    * Add the field to the printed HTML this section (PaymentInformation)
# 2. ADD FIELD(S) TO MASTER FIELDS LIST (mofpaylib.pl)
#    * Add Field(s) to [CheckFieldsNeeded] sub routine
#    * push to UsingInfoFields array, a list of all possible field(s)
#    * Possible fields are those requiring Validation only
# 3. ADD ANY VALIDATION NEEDED  (mofpaylib.pl) 
#    * If required, validate new Field(s) in [CheckUsingInfoFields]
#    * which validates and flags in MissingInfoFields array if
#    * there is anything "Missing" or "Incomplete"
# 4. ADD DISPLAY FLAGS (if desired)  (mofpaylib.pl)
#    * Use a similar sub routine as [ValidateBillingInfo] to set up proper
#    * display flag (Missing/Incomplete) on BillingInformation page
# NOTE: If BillingInformation page reloads, because validation failed
#    * we can only prefill a text box.  We cannot Find the already
#    * selected value of a drop box, list box, radio button, checkbox
#    * unless you write a routine for matching the returning input
# 5. ADJUST POST ARRAY FOR RELOAD (mofpay.cgi)
#    * See the notes/area appx: LINE 1065
#    * Validation will not prefill unless you delete from reload array
# 6. SET NEW FIELD(S) TO PRINT WHERE NEEDED
#    * To print at [PaymentAccepted] use $frm{'NewField'}
#    * Use $frm{'NewField'} to print in <mofpay.cgi> 
#    * <invoice.pl><merchant.mail><customer.mail>
# ========================================= #
# PAYMENT INFO
sub PaymentInformation {
	$out = "";
	$msg_v;
	$itm_n = 0;
	$itm_m = 0;
	$allow_methods = 0;
	my ($new_value,$key,$val,$single_option,
		$billErr,$iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum);
	($depmin,$deppct,$display_deposit) = (0,0,0);
	$itm_m = scalar(keys(%MissingInfoFields));
	if ($itm_m == 1) {$fld = "Field"} else {$fld = "Fields"}
	$submit_total = CommifyMoney($frm{'Final_Amount'});
	$allow_methods++ if ($enable_paypal);
	$allow_methods++ if ($mail_or_fax_field);
	$allow_methods++ if ($enable_cod);
	$allow_methods++ if ($enable_onaccount);
	$allow_methods++ if ($call_for_cc_info);
	$allow_methods++ if ($use_gateway_forms);
	$allow_methods++ if (scalar(keys(%checking_account_fields)));
	$allow_methods++ if (scalar(keys(%credit_card_fields)));
	$depmin = $deposit_minimum if ($deposit_minimum > 0);
	$deppct = ($deposit_percent * $frm{'Final_Amount'}) if ($deposit_percent > 0);
 	$depmin = $deppct if ($deppct > $depmin);
	$depmin = sprintf "%.2f",$depmin if ($depmin > 0);
	$display_deposit++ if ($enable_deposit && $frm{'Final_Amount'} >= $depmin);
	$tmpmin = CommifyMoney($depmin);
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	$nav_top++ if ($menu_home_top);
	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_viewcart_top);
	$nav_top++ if ($menu_payment_top);
	$nav_top++ if ($menu_help_top);
	# changed menus : v2.5 Top Navigation : Billing Info Pg
	if ($nav_top && $includeBillingInfo) {
	my ($tblCSS,$tdCSS) = ('tblTopPreviousNav','tdTopPreviousNav') if ($twoTopTables);
	my ($tblCSS,$tdCSS) = ('tblTopNav','tdTopNav') unless ($twoTopTables);
	$out .= "<table Class=\"$tblCSS\"><tr>\n";
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
	$out .= "<td Class=\"tdTopNav\">$menu_payment_top</td>\n" if ($menu_payment_top);
	$out .= "</tr></table><br>\n\n"
	}
	# CSS replacement : Billing Info Screen  top message 
	$out .= "Enter billing information below, then click the <span Class=\"next\">place order</span> button ";
	$out .= "to process payment." if ($display_deposit);
	$out .= "to pay <strong>$currency $submit_total</strong>." unless ($display_deposit);
	$out .= "<p>";
	if ($frm{'resubmit_info'}) {
	if ($itm_m > 1) {
	$out .= "<SPAN Class=\"ValidationMessageText\">You have $itm_m $fld Missing or Incomplete. ";
	$out .= "Check the prompts on this page for missing or incomplete information.";
	# missing fields msg
	if ($MissingInfoFields{'Ecom_BillTo_Online_Email'} eq "Incomplete" || $MissingInfoFields{'Ecom_ReceiptTo_Online_Email'} eq "Incomplete") {
	$out .= "<span color=\"#FF0D00\">Check eMail for accuracy</span>.";
	}
	$out .= "<p></SPAN>\n";
	} elsif ($itm_m == 1) {
	$out .= "<SPAN Class=\"ValidationMessageText\">";
		if (exists($MissingInfoFields{'input_cyber_permission'})) {
		$out .= "Your Final Approval is needed to continue processing this order. ";
		$out .= "Check <strong>Yes</strong> at the bottom of this form to continue, or abort by ";
		$out .= "leaving this form without checking Yes. \n";
		} else {
		$out .= "You have $itm_m $fld Missing or Incomplete. Check the prompts on this page for ";
		$out .= "missing or incomplete information. \n";
		if ($MissingInfoFields{'Ecom_BillTo_Online_Email'} eq "Incomplete" || $MissingInfoFields{'Ecom_ReceiptTo_Online_Email'} eq "Incomplete") {
		$out .= "<span color=\"#FF0D00\">Check eMail for accuracy</span>.";
		}}
	$out .= "<p></SPAN>\n";
	}}
	# Re POST Hidden to payment file : All hidden INPUT occurs after populating form
	$out .= "\n\n";
	$out .= "<FORM name=\"formCheckout\" method=POST action=\"$paymentfile\">\n";
	# deposit : this condition takes care of zero based invoices as well as invoices under the minimum deposit 
	if ($display_deposit) {
	$itm_n++;
	my($depAmt) = $frm{'Deposit_Amount'};
	$depAmt = $depmin if ($deposit_prefill && $depAmt > 0 && $depAmt < $depmin);
	$depAmt = $submit_total if ($deposit_prefill && !$depAmt > 0);
	$depAmt =~ s/,//g ;
	$depAmt = sprintf "%.2f",$depAmt if ($depAmt > 0);
	# section table (2) columns
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">Deposit Options : Invoice Total <strong>$currency $submit_total</strong>. ";
	if ($link_deposit) {
	$out .= "<a Class=\"TextLink\" href=\"$link_deposit_url\" ";
	$out .= "onmouseover=\"status='Get more information about deposits';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_deposit</a> ";
	}
	$out .= "</td></tr>\n";
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td><td Class=\"textBText\">$more_deposit_notes</td></tr>" if ($more_deposit_notes);
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table>\n";
	# use input (4) cols format, but CSS of (2) cols above for msg on top of input box 
	$out .= "<table Class=\"billInput\">";
	$msg_v = "<br>";
	$msg_v = $info_okay if ($frm{'resubmit_info'} && $info_okay);
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$strNum) = ('inputBRow','inputBNum','inputBLabel','inputBInput','inputBValidate','<br>');
		if ($MissingInfoFields{'Deposit_Amount'} || $depmin > 0) {
		$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
		$out .= "<td Class=\"textBNum\"><br></td>";
		$out .= "<td colspan=\"2\" Class=\"textBText\">";
		 if ($depmin > 0) {
		$out .= "<SPAN Class=\"ValidationMessageText\">Minimum : <strong>$currency $tmpmin</strong>.</SPAN> ";
		}
		if ($MissingInfoFields{'Deposit_Amount'} eq "MinimumNeeded") {
		$msg_v = $info_incomplete if ($info_incomplete);
		$strNum = $info_incomplete_Num if ($info_incomplete_Num);
		($iRow,$iNum,$iLabel,$iInput,$iValidate) = ('errBRow','errBNum','errBLabel','errBInput','errBValidate');
		$out .= "<SPAN Class=\"ValidationMessageText\"><u>Minimum Required</u>.</SPAN>";
		} elsif ($MissingInfoFields{'Deposit_Amount'}) {
		$msg_v = $info_missing if ($info_missing);
		$strNum = $info_missing_Num if ($info_missing_Num);
		($iRow,$iNum,$iLabel,$iInput,$iValidate) = ('errBRow','errBNum','errBLabel','errBInput','errBValidate');
		$out .= "<SPAN Class=\"ValidationMessageText\">Enter numbers <u>only</u>. ";
		$out .= "Error : <strong>$MissingInfoFields{'Deposit_Amount'}</strong></SPAN>.";
		}
		$out .= "</td></tr>";
		}
	# input box row (4) columns
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td>";
	$out .= "<td Class=\"$iLabel\">Deposit :</td>";
	$out .= "<td Class=\"$iInput\">";
	$out .= "<input Class=\"BillingBoxFormat\" name=\"Deposit_Amount\" value=\"$depAmt\" size=12>";
	$out .= "</td>";
	$out .= "<td Class=\"$iValidate\">$msg_v </td></tr>\n";
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	}
	# zero based invoive bypass
	if ($zb_no_method && $frm{'Final_Amount'} == 0) {
	$itm_n++;
	# (2) column section
	$out .= "<input type=hidden name=\"input_payment_options\" value=\"ZEROPAY\"> \n\n";
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">$ZeroHeading ";
	if ($link_zero) {
	$out .= "<a Class=\"TextLink\" href=\"$link_zero_url\" ";
	$out .= "onmouseover=\"status='Get more information for Receipt To section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_zero</a> ";
	}
	$out .= "</td></tr>\n";
	if ($more_zero_notes) {
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
	$out .= "<td Class=\"textBText\">$more_zero_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	# multiple methods
	} elsif ($allow_methods) {
	$itm_n++;
	# (2) column section
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">$PaymentHeading ";
	if ($link_payment) {
	$out .= "<a Class=\"TextLink\" href=\"$link_payment_url\" ";
	$out .= "onmouseover=\"status='Get more information for Payment section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_payment</a> ";
	}
	$out .= "</td></tr>\n";
	unless (scalar(keys(%payment_options_list)) == 1 ) {
		if ($more_payment_notes) {
		$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
		$out .= "<td Class=\"textBText\">$more_payment_notes</td></tr>\n";
		}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr>\n";
	}
	# cc verify err
	if ($frm{'Ecom_Payment_Card_Number'}) {	
	$billErr .= $msg_cc if ($msg_cc);
	$billErr .= "Check the Card Type selected for accuracy. The card number is a $cc_type_error number." if ($cc_type_error);
	}
	# cc date err
	$billErr .= $ccDateErr if ($frm{'Ecom_Payment_Card_ExpDate_Month'} && $frm{'Ecom_Payment_Card_ExpDate_Year'} && $ccDateErr);
	if ($billErr) {
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
	$out .= "<td Class=\"textBText\"><SPAN Class=\"ValidationMessageText\">$billErr</SPAN></td></tr>\n";
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr>\n";
	}
	$out .= "</table>\n";
	# payment options (only 1 method)
	if (scalar(keys(%payment_options_list)) == 1 ) {
		while (($key,$val) = each (%payment_options_list)) {$single_option = $key}
		$out .= "<table Class=\"billSection\">";
		$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
		$out .= "<td Class=\"textBText\">$payment_options_desc{$single_option}\n";
		$out .= "<input type=hidden name=\"input_payment_options\" value=\"$single_option\"></td></tr>\n";
		$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	# payment options (more than 1 method)
	} elsif (scalar(keys(%payment_options_list)) > 1 ) {
		$msg_v = (&ValidateInputOptions('input_payment_options'));	
		($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('input_payment_options');
		$out .= "<table Class=\"billInput\">";
		$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td>";
		$out .= "<td Class=\"$iLabel\">Payment Method: </td>";
		$out .= "<td Class=\"$iInput\">";
	# dropbox
	$out .= "<select Class=\"BillingBoxFormat\" name=\"input_payment_options\"> \n";
	if ($frm{'input_payment_options'}) {
		$out .= "<option value=\"\">Please Select Here \n";
		$out .= "<option value=\"\"> ------------------------------ \n";
		foreach (@payment_options_order) {
		if ($_ eq $frm{'input_payment_options'}) {
		$out .= "<option selected value=\"$_\">$payment_options_list{$_} \n";
		} else {
		$out .= "<option value=\"$_\">$payment_options_list{$_} \n" if ($payment_options_list{$_});
		}}
	} else {
		$out .= "<option selected value=\"\">Please Select Here \n";
		$out .= "<option value=\"\"> ------------------------------ \n";
		foreach $_ (@payment_options_order) {
		$out .= "<option value=\"$_\">$payment_options_list{$_} \n" if ($payment_options_list{$_});
		}
	}
	$out .= "</select></td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	} 
	# end payment options
	# cc fields
	if (scalar(keys(%credit_card_fields))) {
	# (2) column section
	$out .= "<table Class=\"optSection\">";
	if ($CardHeading or  $link_card) {
	$out .= "<tr Class=\"optRow\">";
	$out .= "<td Class=\"optNum\">$options_card </td>"; 
	$out .= "<td Class=\"optTitle\">$CardHeading ";
	if ($link_card) {
	$out .= "<a Class=\"TextLink\" href=\"$link_card_url\" ";
	$out .= "onmouseover=\"status='Get more information for Credit Card section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_card</a> ";
	}
	$out .= "</td></tr>\n";
	}
	if ($more_card_notes) {
	$out .= "<tr Class=\"optRow\"><td Class=\"optNum\"><br></td>";
	$out .= "<td Class=\"optText\">$more_card_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	$out .= "<table Class=\"billInput\">";
	if (exists ($credit_card_fields{'Ecom_Payment_Card_Name'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_Name'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_Name');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Name on Card: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_Name'}}
	$out .= "<input Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_Name\" value=\"$new_value\" size=30>";
	$out .= "</td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	if (exists ($credit_card_fields{'Ecom_Payment_Card_Number'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_Number'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_Number');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Card Number: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_Number'}}
	$out .= "<input Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_Number\" value=\"$new_value\" size=30>";
	$out .= "</td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	if (exists ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Month'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_ExpDate_Month'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_ExpDate_Month');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Expiration Month: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_ExpDate_Month'}}
	$out .= "<select Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_ExpDate_Month\"> \n";
		if ($new_value == 0) {$out .= "<option selected value=\"\">Select Month \n";
		} else {$out .= "<option value=\"\">Select Month \n";}
		$out .= "<option value=\"\"> ------------------- \n";
		if ($new_value == 1) {$out .= "<option selected value =\"1\">January \n";
		} else {$out .= "<option value =\"1\">January \n";}
		if ($new_value == 2) {$out .= "<option selected value =\"2\">February \n";
		} else {$out .= "<option value =\"2\">February \n";}
		if ($new_value == 3) {$out .= "<option selected value =\"3\">March \n";
		} else {$out .= "<option value =\"3\">March \n";}
		if ($new_value == 4) {$out .= "<option selected value =\"4\">April \n";
		} else {$out .= "<option value =\"4\">April \n";}
		if ($new_value == 5) {$out .= "<option selected value =\"5\">May \n";
		} else {$out .= "<option value =\"5\">May \n";}
		if ($new_value == 6) {$out .= "<option selected value =\"6\">June \n";
		} else {$out .= "<option value =\"6\">June \n";}
		if ($new_value == 7) {$out .= "<option selected value =\"7\">July \n";
		} else {$out .= "<option value =\"7\">July \n";}
		if ($new_value == 8) {$out .= "<option selected value =\"8\">August \n";
		} else {$out .= "<option value =\"8\">August \n";}
		if ($new_value == 9) {$out .= "<option selected value =\"9\">September \n";
		} else {$out .= "<option value =\"9\">September \n";}
		if ($new_value == 10) {$out .= "<option selected value =\"10\">October \n";
		} else {$out .= "<option value =\"10\">October \n";}
		if ($new_value == 11) {$out .= "<option selected value =\"11\">November \n";
		} else {$out .= "<option value =\"11\">November \n";}
		if ($new_value == 12) {$out .= "<option selected value =\"12\">December \n";
		} else {$out .= "<option value =\"12\">December \n";}
	$out .= "</select></td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	if (exists ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Day'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_ExpDate_Day'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_ExpDate_Day');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Expiration Day: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_ExpDate_Day'}}
	$out .= "<select Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_ExpDate_Day\"> \n";
		$count_day = 1;
		if ($new_value == 0) {
		$out .= "<option selected value=\"\">Select Day \n";
		} else {
		$out .= "<option value=\"\">Select Day \n";
		}
		$out .= "<option value=\"\"> ------------------- \n";
		while ($count_day < 32) {
			if ($new_value == $count_day) {
			$out .= "<option selected value=\"$count_day\">$count_day \n";
			} else {
			$out .= "<option value=\"$count_day\">$count_day \n";
			}
			$count_day++;
		}
	$out .= "</select></td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	if (exists ($credit_card_fields{'Ecom_Payment_Card_ExpDate_Year'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_ExpDate_Year'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_ExpDate_Year');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Expiration Year: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_ExpDate_Year'}}
	$count_year = $pass_year;
	$stop_year = ($count_year + 21);
	$out .= "<select Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_ExpDate_Year\"> \n";
		if ($new_value == 0) {
		$out .= "<option selected value=\"\">Select Year \n";
		} else {
		$out .= "<option value=\"\">Select Year \n";
		}
		$out .= "<option value=\"\"> ------------------- \n";
		while ($count_year < $stop_year) {
			if ($new_value == $count_year) {
			$out .= "<option selected value=\"$count_year\">$count_year \n";
			} else {
			$out .= "<option value=\"$count_year\">$count_year \n";
			}
			$count_year++;
		}
	$out .= "</select></td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	if (exists ($credit_card_fields{'Ecom_Payment_Card_Verification'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_Verification'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_Verification');
	if ($link_cvvcid) {
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\"><br></td><td Class=\"$iLabel\"><br></td><td Class=\"$iInput\">";
	$out .= "<a Class=\"TextLink\" href=\"$link_cvvcid_url\" onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_cvvcid</a></td><td Class=\"$iValidate\"><br></td></tr>\n";
	}
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Card Verification: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_Verification'}}
	$out .= "<input Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_Verification\" value=\"$new_value\" size=12>";
	$out .= "</td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	# new field : July 25, 2003 9:01:12 AM
	# this is not a one way psw, but an API that retrieves a personal phrase to match psw
	# withhold for v2.5 and check into the API further
	if (exists ($credit_card_fields{'Ecom_Payment_Card_VisaPSW'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_VisaPSW'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_VisaPSW');
	if ($link_visapsw) {
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\"><br></td><td Class=\"$iLabel\"><br></td><td Class=\"$iInput\">";
	$out .= "<a Class=\"TextLink\" href=\"$link_visapsw_url\" onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_visapsw</a></td><td Class=\"$iValidate\"><br></td></tr>\n";
	}
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Visa Password: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_VisaPSW'}}
	$out .= "<input Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_VisaPSW\" value=\"$new_value\" size=12>";
	$out .= "</td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";

	# (2) column section
	if ($enable_switch) {
	$out .= "<table Class=\"optSection\">";
	if ($SwitchHeading or  $link_switch) {
	$out .= "<tr Class=\"optRow\"><td Class=\"optNum\">$options_switch </td>";
	$out .= "<td Class=\"optTitle\">$SwitchHeading ";
	if ($link_switch) {
	$out .= "<a Class=\"TextLink\" href=\"$link_switch_url\" ";
	$out .= "onmouseover=\"status='Get more information for Credit Card section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_switch</a> ";
	}
	$out .= "</td></tr>\n";
	}
	if ($more_switch_notes) {
	$out .= "<tr Class=\"optRow\"><td Class=\"optNum\"><br></td>";
	$out .= "<td Class=\"optText\">$more_switch_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	$out .= "<table Class=\"billInput\">";
	# switch fields 011702
	if (exists ($switch_card_fields{'Ecom_Payment_Card_IssueNumber'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_IssueNumber'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_IssueNumber');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">Issue Number: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_IssueNumber'}}
	$out .= "<input Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_IssueNumber\" value=\"$new_value\" size=12>";
	$out .= "</td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	if (exists ($switch_card_fields{'Ecom_Payment_Card_FromDate_Month'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_FromDate_Month'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_FromDate_Month');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">From Month: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_FromDate_Month'}}
	$out .= "<select Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_FromDate_Month\"> \n";
		if ($new_value == 0) {$out .= "<option selected value=\"\">Select Month \n";
		} else {$out .= "<option value=\"\">Select Month \n";}
		$out .= "<option value=\"\"> ------------------- \n";
		if ($new_value == 1) {$out .= "<option selected value =\"1\">January \n";
		} else {$out .= "<option value =\"1\">January \n";}
		if ($new_value == 2) {$out .= "<option selected value =\"2\">February \n";
		} else {$out .= "<option value =\"2\">February \n";}
		if ($new_value == 3) {$out .= "<option selected value =\"3\">March \n";
		} else {$out .= "<option value =\"3\">March \n";}
		if ($new_value == 4) {$out .= "<option selected value =\"4\">April \n";
		} else {$out .= "<option value =\"4\">April \n";}
		if ($new_value == 5) {$out .= "<option selected value =\"5\">May \n";
		} else {$out .= "<option value =\"5\">May \n";}
		if ($new_value == 6) {$out .= "<option selected value =\"6\">June \n";
		} else {$out .= "<option value =\"6\">June \n";}
		if ($new_value == 7) {$out .= "<option selected value =\"7\">July \n";
		} else {$out .= "<option value =\"7\">July \n";}
		if ($new_value == 8) {$out .= "<option selected value =\"8\">August \n";
		} else {$out .= "<option value =\"8\">August \n";}
		if ($new_value == 9) {$out .= "<option selected value =\"9\">September \n";
		} else {$out .= "<option value =\"9\">September \n";}
		if ($new_value == 10) {$out .= "<option selected value =\"10\">October \n";
		} else {$out .= "<option value =\"10\">October \n";}
		if ($new_value == 11) {$out .= "<option selected value =\"11\">November \n";
		} else {$out .= "<option value =\"11\">November \n";}
		if ($new_value == 12) {$out .= "<option selected value =\"12\">December \n";
		} else {$out .= "<option value =\"12\">December \n";}
	$out .= "</select></td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	if (exists ($switch_card_fields{'Ecom_Payment_Card_FromDate_Year'})) {
	$msg_v = (&ValidateCreditCardInfo('Ecom_Payment_Card_FromDate_Month'));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags('Ecom_Payment_Card_FromDate_Year');
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td><td Class=\"$iLabel\">From Year: </td><td Class=\"$iInput\">";
	if ($check_check) {$new_value = ""} else {$new_value = $frm{'Ecom_Payment_Card_FromDate_Year'}}
	$count_year = $pass_year;
	$stop_year = ($count_year - 21);
	$out .= "<select Class=\"BillingBoxFormat\" name=\"Ecom_Payment_Card_FromDate_Year\"> \n";
		if ($new_value == 0) {
		$out .= "<option selected value=\"\">Select Year \n";
		} else {
		$out .= "<option value=\"\">Select Year \n";
		}
		$out .= "<option value=\"\"> ------------------- \n";
		while ($count_year > $stop_year) {
			if ($new_value == $count_year) {
			$out .= "<option selected value=\"$count_year\">$count_year \n";
			} else {
			$out .= "<option value=\"$count_year\">$count_year \n";
			}
			$count_year--;
		}
	$out .= "</select></td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	}
	# end switch mods rga 011702
	} 
	# end card section
	# checking
	if (scalar(keys(%checking_account_fields))) {
	my($fC,$tC,$sC);
	# field order : Key,Title,Size : (be nice to put RegEx for javascript validation)
	@checkFIELDS = (
	"Check_Bank_Name,Bank Name:,30",
	"Check_Bank_Address,Bank Address:,30",
	"Check_Account_Type,Account Type:,30",
	"Check_Number,Check Number:,30",
	"Check_Account_Number,Account Number:,30",
	"Check_Routing_Number,Routing Number:,30",
	"Check_Fraction_Number,Fraction Number:,30",
	"Check_Holder_Name,Name on Account:,30",
	"Check_Customer_Organization_Type,Organization Type:,30",
	"Check_Tax_ID,Tax ID / SSN:,30",
	"Check_Drivers_License_Num,Drivers License Number:,30",
	"Check_Drivers_License_ST,Drivers License State:,30",
	"Check_Drivers_License_DOB,Date of Birth:,30"
	);
	# (2) column section
	$out .= "<table Class=\"optSection\">";
	if ($CheckHeading or  $link_check) {
	$out .= "<tr Class=\"optRow\"><td Class=\"optNum\">$options_check </td>";
	$out .= "<td Class=\"optTitle\">$CheckHeading ";
	if ($link_check) {
	$out .= "<a Class=\"TextLink\" href=\"$link_check_url\" ";
	$out .= "onmouseover=\"status='Get more information for Check section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_check</a> ";
	}
	$out .= "</td></tr>\n";
	}
	if ($more_check_notes) {
	$out .= "<tr Class=\"optRow\"><td Class=\"optNum\"><br></td>";
	$out .= "<td Class=\"optText\">$more_check_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	$out .= "<table Class=\"billInput\">";
	foreach (@checkFIELDS) {
  	($fC,$tC,$sC) = split (/,/,$_);
		if (exists ($checking_account_fields{$fC})) {
		$msg_v = (&ValidateCheckingInfo($fC));
		($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags($fC);
		$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td>";
		$out .= "<td Class=\"$iLabel\">$tC </td>";
		$out .= "<td Class=\"$iInput\">";
		if ($card_check) {$new_value = ""} else {$new_value = $frm{$fC}}
		$out .= "<input Class=\"$iBox\" name=\"$fC\" value=\"$new_value\" size=\"$sC\">";
		$out .= "</td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
		}}
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	}
	# end checking
	}
	# end pay methods
	# CSS Replacement w/ loop for display : Ecom_BillTo_FIELDS
	unless ($zb_no_billing && $frm{'Final_Amount'} == 0) {
	if (scalar(keys(%billing_info_fields))) {
	$itm_n++;
	my($fB,$tB,$sB);
	# field order : Key,Title,Size : (be nice to put RegEx for javascript validation)
	@billingFIELDS = (
	"Ecom_BillTo_Postal_Name_Prefix,Title:,4",
	"Ecom_BillTo_Postal_Name_First,First Name:,36",
	"Ecom_BillTo_Postal_Name_Middle,Middle Name:,36",
	"Ecom_BillTo_Postal_Name_Last,Last Name:,36",
	"Ecom_BillTo_Postal_Name_Suffix,Last Name Suffix:,4",
	"Ecom_BillTo_Postal_Company,Company Name:,36",
	"Ecom_BillTo_Postal_Street_Line1,Address:,36",
	"Ecom_BillTo_Postal_Street_Line2,Address:,36",
	"Ecom_BillTo_Postal_City,City:,36",
	"Ecom_BillTo_Postal_StateProv,State - Province:,30",
	"Ecom_BillTo_Postal_Region,* Region:,30",
	"Ecom_BillTo_Postal_PostalCode,Postal Code:,30",
	"Ecom_BillTo_Postal_CountryCode,Country:,30",
	"Ecom_BillTo_Telecom_Phone_Number,Phone Number:,30",
	"Ecom_BillTo_Online_Email,E-mail Address:,36"
	);
	# (2) column section
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">$BillToHeading ";
	if ($link_billto) {
	$out .= "<a Class=\"TextLink\" href=\"$link_billto_url\" ";
	$out .= "onmouseover=\"status='Get more information for Bill To section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_billto</a> ";
	}
	$out .= "</td></tr>\n";
	if ($more_billto_notes) {
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
	$out .= "<td Class=\"textBText\">$more_billto_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr>\n";
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
	$out .= "<td Class=\"textBText\">\n";
		if ($frm{'Allow_Shipping'}) {
		# JavaScript pre Fill billing : 05-05-03
		if ($useJavaShortCut) {
		my ($strBill,$strShip);
		$out .= "<SCRIPT LANGUAGE=\"JavaScript\">\n";
		$out .= "<!-- Begin\n";
		$out .= "function ShipToBillTo(form) {\n";
		$out .= "if (form.input_shipping_info.checked) {\n";
		# set up values (checked)
		while (($key,$val) = each (%billing_info_fields)) {
		$strBill = substr ($key,11);
		$strShip = "Ecom_ShipTo" . $strBill;
		# state, country drop lists are not supported Jscript
		$out .= "form.$key.value = \"$frm{$strShip}\";\n" if ($frm{$strShip});
		}
		$out .= "} else { \n";
		# set up nulls (actively unchecked)
		while (($key,$val) = each (%billing_info_fields)) {
		# state, country drop lists are not supported Jscript
		$out .= "form.$key.value = \"\"\;\n";
		}
		$out .= "}}//  End --></script>\n\n";
		# end insert JavaScript
		}
	if ($frm{'input_shipping_info'} eq "YES") {
		# Jscript option  : 05-05-03
		if ($useJavaShortCut) {
		$out .= "<input id=\"scut\" Class=\"BillingCheckBoxFormat\" type=\"checkbox\" name=\"input_shipping_info\" checked=\"on\" OnClick=\"javascript:ShipToBillTo(this.form)\;\" value=\"YES\">\n";
		} else {
		$out .= "<input id=\"scut\" Class=\"BillingCheckBoxFormat\" type=\"checkbox\" name=\"input_shipping_info\" checked=\"on\" value=\"YES\"> ";
		}
	} else {
		if ($useJavaShortCut) {
		$out .= "<input id=\"scut\" Class=\"BillingCheckBoxFormat\" type=\"checkbox\" name=\"input_shipping_info\" OnClick=\"javascript:ShipToBillTo(this.form)\;\" value=\"YES\">\n";
		} else {
		$out .= "<input id=\"scut\" Class=\"BillingCheckBoxFormat\" type=\"checkbox\" name=\"input_shipping_info\" value=\"YES\"> ";
		}
	}
	$out .= "<label for=\"scut\"><strong>shortcut</strong>: Check here if exactly same as shipping address.</label>";
	$out .= "</td></tr>\n";
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr>\n";
	}
	$out .= "</table> \n";
	$out .= "<table Class=\"billInput\">";
	foreach (@billingFIELDS) {
  	($fB,$tB,$sB) = split (/,/,$_);
		if (exists ($billing_info_fields{$fB})) {
		$msg_v = (&ValidateBillingInfo($fB));
		($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags($fB);
		$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td>";
		$out .= "<td Class=\"$iLabel\">$tB </td>";
		$out .= "<td Class=\"$iInput\">";
		if ($fB eq "Ecom_BillTo_Postal_StateProv" && $use_state_list) {
			# use drop box
			$out .= "<select Class=\"$iBox\" name=\"$fB\"> \n";
			foreach $itm (@state_list_bill) {
			$out .= "$itm \n";
			}
			$out .= "</select> \n";
		} elsif ($fB eq "Ecom_BillTo_Postal_CountryCode" && $use_country_list) {
			# use drop box
			$out .= "<select Class=\"$iBox\" name=\"$fB\"> \n";
			foreach $itm (@country_list_bill) {
			$out .= "$itm \n";
			}
			$out .= "</select> \n";
		} else {
		$out .= "<input Class=\"$iBox\" name=\"$fB\" value=\"$frm{$fB}\" size=\"$sB\">";
		}
		$out .= "</td>";
		$out .= "<td Class=\"$iValidate\">$msg_v </td></tr>\n";
		}}
	if ($force_state_message) {
	if (exists($billing_info_fields{'Ecom_BillTo_Postal_Region'})) {
	$out .= "<tr Class=\"regionBRow\"><td Class=\"regionBNum\"><br></td>";
	$out .= "<td colspan=\"3\" Class=\"regionBText\">$force_state_message</td></tr>\n";
	}}
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	}}
	# end bill to fields
	# CSS Replacement w/ loop for display : Ecom_ReceiptTo_FIELDS
	unless ($zb_no_receipt && $frm{'Final_Amount'} == 0) {
	if (scalar(keys(%receipt_info_fields))) {
	$itm_n++;
	my($fR,$tR,$sR);
	# field order : Key,Title,Size : (be nice to put RegEx for javascript validation)
	@receiptFIELDS = (
	"Ecom_ReceiptTo_Postal_Name_Prefix,Title:,4",
	"Ecom_ReceiptTo_Postal_Name_First,First Name:,36",
	"Ecom_ReceiptTo_Postal_Name_Middle,Middle Name:,36",
	"Ecom_ReceiptTo_Postal_Name_Last,Last Name:,36",
	"Ecom_ReceiptTo_Postal_Name_Suffix,Last Name Suffix:,4",
	"Ecom_ReceiptTo_Postal_Company,Company Name:,36",
	"Ecom_ReceiptTo_Postal_Street_Line1,Address:,36",
	"Ecom_ReceiptTo_Postal_Street_Line2,Address:,36",
	"Ecom_ReceiptTo_Postal_City,City:,36",
	"Ecom_ReceiptTo_Postal_StateProv,State - Province:,30",
	"Ecom_ReceiptTo_Postal_Region,* Region:,30",
	"Ecom_ReceiptTo_Postal_PostalCode,Postal Code:,30",
	"Ecom_ReceiptTo_Postal_CountryCode,Country:,30",
	"Ecom_ReceiptTo_Telecom_Phone_Number,Phone Number:,30",
	"Ecom_ReceiptTo_Online_Email,E-mail Address:,36"
	);
	# (2) column section
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">$ReceiptToHeading ";
	if ($link_receipt) {
	$out .= "<a Class=\"TextLink\" href=\"$link_receipt_url\" ";
	$out .= "onmouseover=\"status='Get more information for Receipt To section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_receipt</a> ";
	}
	$out .= "</td></tr>\n";
	if ($more_receipt_notes) {
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
	$out .= "<td Class=\"textBText\">$more_receipt_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	$out .= "<table Class=\"billInput\">";
	foreach (@receiptFIELDS) {
  	($fR,$tR,$sR) = split (/,/,$_);
		if (exists ($receipt_info_fields{$fR})) {
		$msg_v = (&ValidateReceiptInfo($fR));
		($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags($fR);
		$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td>";
		$out .= "<td Class=\"$iLabel\">$tR </td>";
		$out .= "<td Class=\"$iInput\">";
		if ($fR eq "Ecom_ReceiptTo_Postal_StateProv" && $use_state_list) {
			# use drop box
			$out .= "<select Class=\"$iBox\" name=\"$fR\"> \n";
			foreach $itm (@state_list_receipt) {
			$out .= "$itm \n";
			}
			$out .= "</select> \n";
		} elsif ($fR eq "Ecom_ReceiptTo_Postal_CountryCode" && $use_country_list) {
			# use drop box
			$out .= "<select Class=\"$iBox\" name=\"$fR\"> \n";
			foreach $itm (@country_list_receipt) {
			$out .= "$itm \n";
			}
			$out .= "</select> \n";
		} else {
		$out .= "<input Class=\"$iBox\" name=\"$fR\" value=\"$frm{$fR}\" size=\"$sR\">";
		}
		$out .= "</td>";
		$out .= "<td Class=\"$iValidate\">$msg_v </td></tr>\n";
		}}
	if ($force_state_message) {
	if (exists($receipt_info_fields{'Ecom_ReceiptTo_Postal_Region'})) {
	$out .= "<tr Class=\"regionBRow\"><td Class=\"regionBNum\"><br></td>";
	$out .= "<td colspan=\"3\" Class=\"regionBText\">$force_state_message</td></tr>\n";
	}}
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	}}
	# end receipt fields
	# 05-04-03 : Custom Fields Added
	if (scalar(@extraFields)) {
	$itm_n++;
	my ($fp,$x,$lst,$fld);
	# (2) cols
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">$CustomHeading ";
	if ($link_custom) {
	$out .= "<a Class=\"TextLink\" href=\"$link_custom_url\" ";
	$out .= "onmouseover=\"status='Get more information for this section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_custom</a> ";
	}
	$out .= "</td></tr>\n";
	if ($more_custom_notes) {
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
	$out .= "<td Class=\"textBText\">$more_custom_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	# (4) cols - input
	$out .= "<table Class=\"billInput\">";
	foreach $fld (@extraFields) {
	$msg_v = (&ValidateCustomFields($fld));
	($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) =&GetFlags($fld);
	# July 25, 2003 9:20:04 AM
	# debug : msg_v and strNum not in agreement with drop box 
	# $strNum = "<font size=1>($msg_v)($MissingInfoFields{$fld})</font>";
	# something to do with validating them both seperately ??
	# something to do with the NULL in a required drop box ??
	$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td>";
	$out .= "<td Class=\"$iLabel\">$extraTitle{$fld}: </td>";
	$out .= "<td Class=\"$iInput\">";
		# drop box
		if ($extraType{$fld} eq "DROP") {
		$out .= "<select Class=\"$iBox\" name=\"$fld\">\n";
			foreach $x (@$fld) {
			$out .= "$x\n";
			}
		$out .= "</select>\n";
		# text box
		} else {
		# prefill
		$fp = "";
		$fp = $extraPreFill{$fld} if ($extraPreFill{$fld});
		$fp = $frm{$fld} if ($frm{$fld});
		$out .= "<input Class=\"$iBox\" name=\"$fld\" value=\"$fp\" size=30>";
		}
	$out .= "</td><td Class=\"$iValidate\">$msg_v </td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=4><br></td></tr></table>\n\n";
	}
	# end custom fields
	# comments
	if ($enable_comments_box) {
	$itm_n++;
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">$CommentsHeading ";
	if ($link_comments) {
	$out .= "<a Class=\"TextLink\" href=\"$link_comments_url\" ";
	$out .= "onmouseover=\"status='Get more information about this section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_comments</a> ";
	}
	$out .= "</td></tr>\n";
	if ($more_comments_notes) {
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>";
	$out .= "<td Class=\"textBText\">$more_comments_notes</td></tr>\n";
	}
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr>\n";
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td><td Class=\"textBText\">";
	$out .= "<textarea Class=\"BillingTextAreaFormat\" name=\"special_instructions\" rows=\"4\" cols=\"45\" wrap=\"soft\">";
	$out .= "$frm{'special_instructions'}</textarea></td></tr>\n\n";
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	}
	# Cyber Permission
	if ($enable_cyber_permission) {
	$itm_n++;
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleBTitle\">$PermsHeading ";
	if ($link_perms) {
	$out .= "<a Class=\"TextLink\" href=\"$link_perms_url\" ";
	$out .= "onmouseover=\"status='Get more information about this section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_perms</a> ";
	}
	$out .= "</td></tr>\n";
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td>" if ($more_perms_notes);
	$out .= "<td Class=\"textBText\">$more_perms_notes</td></tr>\n" if ($more_perms_notes);
	$out .= "<tr Class=\"blankBRow\"><td colspan=2><br></td></tr>\n";
	$out .= "<tr Class=\"billText\"><td Class=\"textBNum\"><br></td><td Class=\"textBText\">";
	$out .= "<table Class=\"permsSection\"><tr Class=\"yesRow\"><td Class=\"yesText\">";
   	$out .= "<input Class=\"yesRadio\" type=\"radio\" name=\"input_cyber_permission\" value=\"APPROVED\" id=\"yes\" ";
	$out .= "checked=\"on\"" if ($frm{'input_cyber_permission'} && $remember_yes);
	$out .= "><label for=\"yes\">$yesResponse";
   	$out .= " <strong>$currency $submit_total</strong>" if ($appendAmt && !$display_deposit);
	$out .= "</label></td></tr><tr Class=\"noRow\"><td Class=\"noText\">";
   	$out .= "<input Class=\"noRadio\" type=\"radio\" name=\"input_cyber_permission\" value=\"\" id=\"no\" ";
	$out .= "checked=\"on\"" unless ($frm{'input_cyber_permission'} && $remember_yes);
	$out .= "><label for=\"no\">$noResponse</label></td></tr></table>\n\n";
	$out .= "</td></tr><tr Class=\"blankBRow\"><td colspan=2><br></td></tr></table> \n";
	}
 	# changed menus : v2.5 Bottom Navigation : Billing Info Pg
	$out .= "<table Class=\"billSection\">";
	$out .= "<tr Class=\"billTitle\"><td Class=\"titleBNum\"><br></td>";
	$out .= "<td Class=\"titleBTitle\">";
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
	# functions
	$out .= "<td Class=\"tdBottomNav\">$menu_payment_bottom</td>\n" if ($menu_payment_bottom);
	$out .= "</tr></table>\n";
	$out .= "</td></tr></table>\n";
	# submit / resubmit all data
	$out .= "<input type=hidden name=\"resubmit_info\" value=\"RESUBMIT\"> \n\n";
	# Adjust %frm to prevent resubmit conflict in hidden POST
	# All Input Fields used in this form must be prevented from hidden POST
	# The only field on this form allowed as hidden post is the 'resubmit_info' 
	# which is hidden to begin with
 	while (($key,$val) = each (%billing_info_fields)) {delete ($frm{$key})}
 	while (($key,$val) = each (%receipt_info_fields)) {delete ($frm{$key})}
 	while (($key,$val) = each (%credit_card_fields)) {delete ($frm{$key})}
 	while (($key,$val) = each (%switch_card_fields)) {delete ($frm{$key})}
 	while (($key,$val) = each (%checking_account_fields)) {delete ($frm{$key})}
	unless ($zb_no_method && $frm{'Final_Amount'} == 0) {delete ($frm{'input_payment_options'})}
	delete ($frm{'Ecom_Payment_Card_Type'});
	delete ($frm{'input_shipping_info'});
	delete ($frm{'special_instructions'});
	delete ($frm{'input_cyber_permission'});
	delete ($frm{'Deposit_Amount'});
	# 05-04-03 : Custom Fields Added
 	while (($key,$val) = each (%custom_fields)) {delete ($frm{$key})}
	# Print adjusted frm Data and new POST data
	while (($key,$val) = each (%frm)) {$out .= "<input type=hidden name=\"$key\" value=\"$val\">\n"}
	# orders printing must come after above frm print
	foreach $line (@orders) {$out .= "<input type=hidden name=\"order\" value=\"$line\">\n"}
	$out .= "\n\n</FORM>\n";
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$out \n\n";
	print "@footer \n\n";
	}


# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;
