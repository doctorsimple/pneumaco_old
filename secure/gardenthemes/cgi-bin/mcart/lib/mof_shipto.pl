# ==================== MOFcart v2.5.12.08.04 ====================== #
# === SHIPPING INFO SCREEN ======================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# Default Shipping Information Screen <mof_shipto.pl>
# Called by <mof.cgi> as set <mof.conf> $mof_shipto_pg = 'mof_shipto.pl';
# ============================================== #
#  HOW TO ADD NEW FIELDS TO THE SHIPPING INFO PAGE              
# ============================================== #
# 1. ADD FIELD(S)                                                       
#    * Add the field to the printed HTML this section                   
# 2. ADD FIELD(S) TO MASTER INFO LIST                                   
#    * List the new field name(s) in [GetMasterInfoList] array          
#    * This will create new Field(s) in InfoFile storage                
#    * You must list new Field(s) to store whether required or not      
# 3. ADD FIELD(S) to USING INFO FIELDS (if required)                    
#    * If Field(s) required Add to [CheckFieldsNeeded]                  
#    * push to UsingInfoFields array, a list of all required Field(s)   
# 4. ADD ANY VALIDATION NEEDED                                          
#    * If required, validate new Field(s) in [CheckUsingInfoFields]     
#    * which validates and flags in MissingInfoFields array if          
#    * there is anything "Missing" or "Incomplete"                      
# 5. ADD DISPLAY FLAGS (if desired)                                     
#    * Use the sub routine [ValidatePreviewFields] to set up proper     
#    * display flag (Missing/Incomplete) on PreviewInformation page     
# NOTE: If PreviewInformation page reloads, because validation failed   
#    * we can only prefill a text box.  We cannot Find the already      
#    * selected value of a drop box, list box, radio button, checkbox   
#    * unless you write a routine for matching the returning input      
# 6. SET NEW FIELD(S) TO PRINT WHERE NEEDED                             
#    * To print at [PreviewOrder] use $NewInfo{'NewField'}              
#    * %NewInfo fields will automatically parse as hidden to mofpay     
#    * Use $frm{'NewField'} to print in <mofpay.cgi><invoice.pl>        
#    * <merchant.mail><customer.mail>                                  
# ============================================== #
# PREVIEW INFORMATION  
sub PreviewInformation {
	$out = "";
	my ($itm_n)=0;
	my ($key,$val);
	my (@InsuranceList) = ();
	my (@MethodList) = ();
	$msg_v;
	@country_list = ();
	@state_list = ();
	($allow_shipping,$allow_tax) = (0,0);
	# failed validation(s)
	$itm_m = scalar(keys(%MissingInfoFields));
	# using shipping and/or tax flags
	$allow_shipping++ if (scalar(@use_shipping));
	$allow_shipping++ if (scalar(keys(%use_method)));
	$allow_tax++ if (scalar(keys(%use_city_tax)));
	$allow_tax++ if (scalar(keys(%use_zipcode_tax)));
	$allow_tax++ if (scalar(keys(%use_state_tax)));
	$allow_tax++ if (scalar(keys(%use_country_tax)));
	@country_list = (&GetDropBoxList($use_country_list,'Ecom_ShipTo_Postal_CountryCode')) if ($use_country_list);
	@state_list = (&GetDropBoxList($use_state_list,'Ecom_ShipTo_Postal_StateProv')) if ($use_state_list);
	&GetTemplateFile($preview_info_template,"Shipping Information Template","preview_info_template"); 
	# you must call any sub routine that can ErrorMessage(ErrMsg)
	# BEFORE you set up the print Content-Type header
	# strip print to $out .= : August 11, 2003 1:07:02 AM;
	# nav
	$nav_top++ if ($menu_home_top);
	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_viewcart_top);
	$nav_top++ if ($menu_preview_top);
	$nav_top++ if ($menu_help_top);
	# changed menus : v2.5 Top Navigation : Shipping Info Pg
	if ($nav_top && $includeShipInfo) {
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
	$out .= "<td Class=\"tdTopNav\">$menu_preview_top</td>\n" if ($menu_preview_top);
	$out .= "</tr></table><br>\n\n";
	}
	if ($itm_m == 1) {$fld = "Field is"} else {$fld = "Fields are"}
	if ($msg_function eq "FOUNDATA") {
	$out .= "Enter all information below. $itm_m $fld incomplete. ";
	$out .= "When the information is complete, continue by clicking the ";
	$out .= "<span Class=\"next\">next</span> button.";
	} elsif ($msg_function eq "EDITING") {
	$out .= "When finished changing your information, ";
	$out .= "click the <span Class=\"next\">next</span> button to see your Order Summary.";
	} elsif ($msg_function eq "NEWSUBMIT") {
	$out .= "<SPAN Class=\"ValidationMessageText\">";
	$out .= "Some information for $itm_m $fld missing or incomplete. ";
	$out .= "Complete all required information and continue by clicking the ";
	$out .= "<span Class=\"next\">next</span> button.";
		if ($MissingInfoFields{'Ecom_ShipTo_Online_Email'} eq "Incomplete") {
		$out .= "  <span color=\"#FF0D00\">Email appears incomplete</span>.";
		}
	$out .= "</SPAN>";
	} elsif ($msg_function eq "NEWLIST") {
	$out .= "Enter all information below. $itm_m $fld required. ";
	$out .= "When the information is complete, continue by clicking the ";
	$out .= "<span Class=\"next\">next</span> button.";
	}
	# CSS replacement : Shipping Info Screen
	$out .= "<P>";
	$out .= "<FORM name=\"formPreviewSubmit\" method=POST action=\"$programfile\">\n";
	$out .= "<input type=hidden name=\"postmode\" value=\"PREVIEW\">\n";
	$out .= "<input type=hidden name=\"submit_preview_info\" value=\"NEWSUBMIT\">\n";
	$out .= "<input type=hidden name=\"OrderID\" value=\"$frm{'OrderID'}\">\n";
	$out .= "<input type=hidden name=\"InfoID\" value=\"$InfoID\">\n";
	$out .= "<input type=hidden name=\"previouspage\" value=\"$frm{'previouspage'}\">\n";
		foreach $line (@orders) {
		$out .= "<input type=hidden name=\"order\" value=\"$line\">\n";
		}
	# ship or tax ?
	if ($allow_shipping || $allow_tax) {
	$itm_n++;
	my($fS,$tS,$sS,$iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum);
	# field order : Key,Title,Size : (be nice to put RegEx for javascript validation)
	@shipFIELDS = (
	"Ecom_ShipTo_Postal_Name_Prefix,Title:,4",
	"Ecom_ShipTo_Postal_Name_First,First Name:,36",
	"Ecom_ShipTo_Postal_Name_Middle,Middle Name:,36",
	"Ecom_ShipTo_Postal_Name_Last,Last Name:,36",
	"Ecom_ShipTo_Postal_Name_Suffix,Last Name Suffix:,4",
	"Ecom_ShipTo_Postal_Company,Company Name:,36",
	"Ecom_ShipTo_Postal_Street_Line1,Address:,36",
	"Ecom_ShipTo_Postal_Street_Line2,Address:,36",
	"Ecom_ShipTo_Postal_City,City:,36",
	"Ecom_ShipTo_Postal_StateProv,State - Province:,30",
	"Ecom_ShipTo_Postal_Region,* Region:,30",
	"Ecom_ShipTo_Postal_PostalCode,Postal Code:,30",
	"Ecom_ShipTo_Postal_CountryCode,Country:,30",
	"Ecom_ShipTo_Telecom_Phone_Number,Phone Number:,30",
	"Ecom_ShipTo_Online_Email,E-mail Address:,36",
	"Ecom_ShipTo_Postal_Type,Destination Is A:,30"
	);
	$out .= "<table Class=\"shipSection\">";
	$out .= "<tr Class=\"shipTitle\"><td Class=\"titleNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleTitle\">$ShipToHeading ";
	if ($link_shipto) {
	$out .= "<a Class=\"TextLink\" href=\"$link_shipto_url\" ";
	$out .= "onmouseover=\"status='Get more information for Ship To section';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_shipto</a> ";
	}
	$out .= "<span Class=\"editing\"> EDITING </span>" if ($msg_function eq "EDITING");
	$out .= "</td></tr>";
	if ($more_shipto_notes) {
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">$more_shipto_notes</td></tr>";
	}
	$out .= "<tr Class=\"blankRow\"><td colspan=2><br></td></tr></table> \n";
	# input
	$out .= "<table Class=\"shipInput\">";
	foreach (@shipFIELDS) {
  	($fS,$tS,$sS) = split (/,/,$_);
		if (exists ($shipping_destination_fields{$fS})) {
		$msg_v = (&ValidatePreviewFields($fS));
		($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) = ('inputRow','inputNum','inputLabel','inputInput','inputValidate','ShippingBoxFormat','<br>');
		if ($frm{'submit_preview_info'}) {
		if ($MissingInfoFields{$fS} eq "Missing") {
		($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) = ('errRow','errNum','errLabel','errInput','errValidate','ShippingErrBoxFormat');
		$strNum = $preview_missing_Num if ($preview_missing_Num);
		}
		if ($MissingInfoFields{$fS} eq "Incomplete") {
		($iRow,$iNum,$iLabel,$iInput,$iValidate,$iBox,$strNum) = ('errRow','errNum','errLabel','errInput','errValidate','ShippingErrBoxFormat');
		$strNum = $preview_incomplete_Num if ($preview_incomplete_Num);
		}}
		$out .= "<tr Class=\"$iRow\"><td Class=\"$iNum\">$strNum</td>";
		$out .= "<td Class=\"$iLabel\">$tS </td>";
		$out .= "<td Class=\"$iInput\">";
		if ($fS eq "Ecom_ShipTo_Postal_StateProv" && $use_state_list) {
			# use drop box
			$out .= "<select Class=\"$iBox\" name=\"$fS\"> \n";
			foreach $itm (@state_list) {
			$out .= "$itm \n";
			}
			$out .= "</select> \n";
		} elsif ($fS eq "Ecom_ShipTo_Postal_CountryCode" && $use_country_list) {
			# use drop box
			$out .= "<select Class=\"$iBox\" name=\"$fS\"> \n";
			foreach $itm (@country_list) {
			$out .= "$itm \n";
			}
			$out .= "</select> \n";
		# added : August 04, 2003 7:29:40 PM
		} elsif ($fS eq "Ecom_ShipTo_Postal_Type") {
			# use drop box
			$out .= "<select Class=\"$iBox\" name=\"$fS\"> \n";
			if ($NewInfo{$fS}) {
				if ($NewInfo{$fS} eq "Business") {
				$out .= "<option value=\"Residence\">Residence\n";
				$out .= "<option selected value=\"Business\">Business\n";
				} else {
				$out .= "<option selected value=\"Residence\">Residence\n";
				$out .= "<option value=\"Business\">Business\n";
				}
			} else {
				if ($shipping_destination_fields{$fS} == 2) {
				$out .= "<option value=\"Residence\">Residence\n";
				$out .= "<option selected value=\"Business\">Business\n";
				} else {
				$out .= "<option selected value=\"Residence\">Residence\n";
				$out .= "<option value=\"Business\">Business\n";
				}
			}
			$out .= "</select> \n";
		} else {
		$out .= "<input Class=\"$iBox\" name=\"$fS\" value=\"$NewInfo{$fS}\" size=\"$sS\">";
		}
		$out .= "</td>";
		$out .= "<td Class=\"$iValidate\">$msg_v </td></tr>";
		}}
	if ($force_state_message) {
	if (exists($shipping_destination_fields{'Ecom_ShipTo_Postal_Region'})) {
	$out .= "<tr Class=\"regionRow\"><td Class=\"regionNum\"><br></td>";
	$out .= "<td colspan=\"3\" Class=\"regionText\">$force_state_message</td></tr>";
	}}
	$out .= "<tr Class=\"blankRow\"><td colspan=4><br></td></tr></table>\n\n";
	# End Ship To Input
	# tax exempt status
	if ($allow_tax || $use_global_tax || $use_custom_tax) {
	if ($tax_exempt_status) {
	$itm_n++;
	$msg_v = (&ValidatePreviewFields('Tax_Exempt_Status'));
	$out .= "<table Class=\"shipSection\">";
	$out .= "<tr Class=\"shipTitle\"><td Class=\"titleNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleTitle\">Do You Have $taxstring Exempt Status ? ";
	if ($link_tax) {
	$out .= "<a Class=\"TextLink\" href=\"$link_tax_url\" ";
	$out .= "onmouseover=\"status='Get more information for $taxstring';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_tax</a> ";
	}
	$out .= "<span Class=\"editing\"> EDITING </span>" if ($msg_function eq "EDITING");
	$out .= "</td></tr>";
	if ($more_tax_notes) {
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">$more_tax_notes</td></tr>";
	}
	$out .= "<tr Class=\"blankRow\"><td colspan=\"2\"><br></td></tr>";
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">";
	# print extra message if ID/VAT fails validation 
	if ($MissingInfoFields{'Tax_Exempt_Status'} eq "Incomplete") {
	$out .= "<SPAN Class=\"ValidationMessageText\">The $taxstring number appears incorrect.</span><br>";
	}
	if ( $NewInfo{'Tax_Exempt_Status'} ) {
	$out .= "<input Class=\"ShippingBoxFormat\" name=\"Tax_Exempt_Status\" value=\"$NewInfo{'Tax_Exempt_Status'}\" size=30>\n";
	} else {
	$out .= "<input Class=\"ShippingBoxFormat\" name=\"Tax_Exempt_Status\" value=\"\" size=30>\n";
	}
	$out .= " $msg_v	</td></tr><tr Class=\"blankRow\"><td colspan=2><br></td></tr></table>\n\n";
	}}
	# shipping method
	if (scalar(keys(%use_method))) {
	$itm_n++;
	$out .= "<table Class=\"shipSection\">";
	$out .= "<tr Class=\"shipTitle\"><td Class=\"titleNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleTitle\">Select Shipping Method. ";
	if ($link_shipping) {
	$out .= "<a Class=\"TextLink\" href=\"$link_shipping_url\" ";
	$out .= "onmouseover=\"status='Get more information for Shipping';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_shipping</a> ";
	}
	$out .= "<span Class=\"editing\"> EDITING </span>" if ($msg_function eq "EDITING");
	$out .= "</td></tr>";
	if ($more_shipping_notes) {
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">$more_shipping_notes</td></tr>";
	}
	$out .= "<tr Class=\"blankRow\"><td colspan=2><br></td></tr>";
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">\n\n";
	# make options
	@MethodList = (sort keys(%use_method));
	if ($type_method_options =~ /\bdropbox\b/i) {
	$out .= "<select Class=\"ShippingBoxFormat\" name=\"Compute_Shipping_Method\">\n";
	foreach $_ (@MethodList) {
	if ($NewInfo{'Compute_Shipping_Method'}) {
		if ($NewInfo{'Compute_Shipping_Method'} eq $_) {
		$out .= "<option selected value=\"$_\"> $use_method{$_} \n";
		} else {
		$out .= "<option value=\"$_\"> $use_method{$_} \n";
		}
	} else {
		if ($default_method eq $_) {
		$out .= "<option selected value=\"$_\"> $use_method{$_} \n";
		} else {
		$out .= "<option value=\"$_\"> $use_method{$_} \n";
		}
	}}
	$out .= "</select>\n";
	} elsif ($type_method_options =~ /\bradio\b/i) {
	foreach $_ (@MethodList) {
	if ($NewInfo{'Compute_Shipping_Method'}) {
		if ($NewInfo{'Compute_Shipping_Method'} eq $_) {
		$out .= "<input Class=\"ShippingRadioFormat\" type=radio name=\"Compute_Shipping_Method\" value=\"$_\" checked=\"on\" id=\"$_\"><label for=\"$_\"> $use_method{$_} </label><br>\n";
		} else {
		$out .= "<input Class=\"ShippingRadioFormat\" type=radio name=\"Compute_Shipping_Method\" value=\"$_\" id=\"$_\"><label for=\"$_\"> $use_method{$_} </label><br>\n";
		}
	} else {
		if ($default_method eq $_) {
		$out .= "<input Class=\"ShippingRadioFormat\" type=radio name=\"Compute_Shipping_Method\" value=\"$_\" checked=\"on\" id=\"$_\"><label for=\"$_\"> $use_method{$_} </label><br>\n";
		} else {
		$out .= "<input Class=\"ShippingRadioFormat\" type=radio name=\"Compute_Shipping_Method\" value=\"$_\" id=\"$_\"><label for=\"$_\"> $use_method{$_} </label><br>\n";	
		}
	}}}
	$out .= "</td></tr><tr Class=\"blankRow\"><td colspan=2><br></td></tr></table>\n\n";
	}
	# insurance options
	if (scalar(keys(%use_insurance)) && $allow_shipping) {
	$itm_n++;
	$out .= "<table Class=\"shipSection\">";
	$out .= "<tr Class=\"shipTitle\"><td Class=\"titleNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleTitle\">Select Insurance Options. ";
	if ($link_insurance) {
	$out .= "<a Class=\"TextLink\" href=\"$link_insurance_url\" ";
	$out .= "onmouseover=\"status='Get more information for Insurance';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_insurance</a> ";
	}
	$out .= "<span Class=\"editing\"> EDITING </span>" if ($msg_function eq "EDITING");
	$out .= "</td></tr>";
	if ($more_insurance_notes) {
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">$more_insurance_notes</td></tr>";
	}
	$out .= "<tr Class=\"blankRow\"><td colspan=2><br></td></tr>";
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">\n\n";
	# make options
    	@InsuranceList = sort { $a <=> $b } (values %use_insurance);
	if ($type_insurance_options =~ /\bdropbox\b/i) {
	$out .= "<select Class=\"ShippingBoxFormat\" name=\"Compute_Insurance\">\n";
	foreach $_ (@InsuranceList) {
		while (($key,$val) = each (%use_insurance)) {		
			if ($_ == $val) {
				if ($NewInfo{'Compute_Insurance'} == $val) {
				$out .= "<option selected value=\"$val\">$key \n";
				} else {
				$out .= "<option value=\"$val\">$key \n";
				}
			}
		}
	}
	$out .= "</select>\n";
	} elsif ($type_insurance_options =~ /\bradio\b/i) {
	foreach $_ (@InsuranceList) {
		while (($key,$val) = each (%use_insurance)) {		
			if ($_ == $val) {
				if ($NewInfo{'Compute_Insurance'} == $val) {
				$out .= "<input Class=\"ShippingRadioFormat\" type=radio name=\"Compute_Insurance\" value=\"$val\" checked=\"on\" id=\"$_\"><label for=\"$_\"> $key </label><br>\n";
				} else {
				$out .= "<input Class=\"ShippingRadioFormat\" type=radio name=\"Compute_Insurance\" value=\"$val\" id=\"$_\"><label for=\"$_\"> $key </label><br>\n";
				}
			}
		}
	}}
	$out .= "</td></tr><tr Class=\"blankRow\"><td colspan=2><br></td></tr></table>\n\n";
	}}
	# discount coupons
	unless ($use_ARES) {
	if (scalar(@use_coupons)) {
	$itm_n++;
	$msg_v = (&ValidatePreviewFields('Compute_Coupons'));
	$out .= "<table Class=\"shipSection\">";
	$out .= "<tr Class=\"shipTitle\"><td Class=\"titleNum\">$itm_n.</td>";
	$out .= "<td Class=\"titleTitle\">Do You Have Any Discount Coupons ? ";
	if ($link_coupons) {
	$out .= "<a Class=\"TextLink\" href=\"$link_coupons_url\" ";
	$out .= "onmouseover=\"status='Get more information for Coupons';return true;\" onmouseout=\"status='&nbsp';return true;\" ";
	$out .= "onclick=\"window.open(this.href,14,'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=yes,width=450,height=400,resizable=no');return false\">";
	$out .= "$link_coupons</a> ";
	}
	$out .= "<span Class=\"editing\"> EDITING </span>" if ($msg_function eq "EDITING");
	$out .= "</td></tr>";
	if ($more_coupon_notes) {
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">$more_coupon_notes </td></tr>";
	}
	$out .= "<tr Class=\"blankRow\"><td colspan=2><br></td></tr>";
	$out .= "<tr Class=\"shipText\"><td Class=\"textNum\"><br></td>";
	$out .= "<td Class=\"textText\">\n\n";
	if ( $NewInfo{'Compute_Coupons'} ) {
	$out .= "<input Class=\"ShippingBoxFormat\" name=\"Compute_Coupons\" value=\"$NewInfo{'Compute_Coupons'}\" size=30>\n";
	} else {
	$out .= "<input Class=\"ShippingBoxFormat\" name=\"Compute_Coupons\" value=\"$default_coupon\" size=30>\n";
	}
	$out .= " $msg_v	</td></tr><tr Class=\"blankRow\"><td colspan=2><br></td></tr></table>\n\n";
	}}
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
	# preview
	$out .= "<td Class=\"tdBottomNav\">$menu_preview_bottom</td>\n" if ($menu_preview_bottom);
	$out .= "</tr></table></FORM>\n";
	# strip print to $out .= : August 11, 2003 1:07:02 AM
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "$out \n\n";
	print "@footer \n\n";
  }


# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003

1;
