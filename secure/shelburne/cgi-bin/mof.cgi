#!/usr/bin/perl

# Merchant OrderForm v1.53 - August 2000, UPDATED 9/15/2000, UPDATED 10/17/2000
# Cart Front End Collection and Preview
# Copyright © August 2000, All Rights Reserved
# Austin Contract Computing, Austin, Texas
# Russell Alexander - rga@io.com
# http://www.io.com/~rga/
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

# THIS IS THE FRONT END PROGRAM
# THIS IS THE FRONT END PROGRAM

# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES
# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES


 # DO NOT CHANGE ANY OF THESE SETTINGS
 # ===================================
 require 5.001;
 require 'mof15.conf';
 require 'mof15_lib.pl';


 # cookie names must be the same in both program files
 # cookie names must be the same in both program files

 $cookiename_OrderID = 'mof_v15_OrderID';
 $cookiename_InfoID = 'mof_v15_InfoID';


 	# START PROGRAM FLOW
 	# START PROGRAM FLOW


	&SetDateVariable;	

	# QUERY STRING INPUT
	# QUERY STRING INPUT
	
 if ($ENV{'QUERY_STRING'}) {

	&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
	&ProcessQueryString;
	&CheckCookie;

	if ($view) {

		if ($cookieOrderID) {

			$frm{'previouspage'} = $qry{'previouspage'};
			&ReadDataFile($cookieOrderID);
			$msg_function = "What's In Your Cart ?";
			&AcceptOrder;

		} else {

			print "Location: $cookieredirect\n\n";
			exit;

		}

	} else {

		if ($cookieOrderID) {

			&ReadDataFile($cookieOrderID);
			&ProcessDataFile;
			&WriteDataFile($cookieOrderID);

			$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
			$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);

			if ($msg_d) {
			$msg_function = $msg_function . ", $msg_d Duplicate Item" if ($msg_d == 1);
			$msg_function = $msg_function . ", $msg_d Duplicate Items" if ($msg_d != 1);
			}

			&AcceptOrder;

		} else {
			
 			&GenerateOrderID;
			&MakeCookie($cookiename_OrderID, $OrderID);
			@orders = @NewOrder;
			&WriteDataFile($OrderID);
			$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
			$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);
			&AcceptOrder;

		}


	}




	# FORM POST INPUT
	# FORM POST INPUT
	
 } else {

	&CheckAllowedDomains if (scalar(@ALLOWED_DOMAINS));
	&ProcessForm;

	# POSTMODE = SINGLEPOST-CHECKBOXES-QUANTITYBOXES
	# POSTMODE = SINGLEPOST-CHECKBOXES-QUANTITYBOXES

	if ($frm{'postmode'} eq "SINGLEPOST" || $frm{'postmode'} eq "CHECKBOXES" || $frm{'postmode'} eq "QUANTITYBOXES") {
		
		&CheckCookie;

		if ($cookieOrderID) {

			&ReadDataFile($cookieOrderID);
			&ProcessDataFile;
			&WriteDataFile($cookieOrderID);

			$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
			$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);

			if ($msg_d) {
			$msg_function = $msg_function . ", $msg_d Duplicate Item" if ($msg_d == 1);
			$msg_function = $msg_function . ", $msg_d Duplicate Items" if ($msg_d != 1);
			}

			&AcceptOrder;

		} else {

			&GenerateOrderID;
			&MakeCookie($cookiename_OrderID, $OrderID);
			@orders = @NewOrder;
			&WriteDataFile($OrderID);
			$msg_function = "Adding $msg_i New Item" if ($msg_i == 1);
			$msg_function = "Adding $msg_i New Items" if ($msg_i != 1);
			&AcceptOrder;

		}



	# UPDATE CART
	# UPDATE CART

	} elsif ($frm{'postmode'} eq "UPDATE") {

		&CheckCookie;

		if ($cookieOrderID) {

			$OrderID = $frm{'OrderID'};
			@orders = @NewOrder;
			&WriteDataFile($OrderID);
			$msg_function = "Updated $msg_i Cart Item" if ($msg_i == 1);
			$msg_function = "Updated $msg_i Cart Items" if ($msg_i != 1);
			&AcceptOrder;
	
		} else {

			print "Location: $cookieredirect\n\n";
			exit;

		}

	



	# DELETE CART
	# DELETE CART

	} elsif ($frm{'postmode'} eq "DELETE") {

		$msg_i = $frm{'deleted_items'};

		&CheckCookie;

		if ($cookieOrderID) {

			$OrderID = $frm{'OrderID'};
			&WriteDataFile($OrderID);
			$msg_function = "Deleted $msg_i Cart Item" if ($msg_i == 1);
			$msg_function = "Deleted $msg_i Cart Items" if ($msg_i != 1);
			&AcceptOrder;

		} else {

			print "Location: $cookieredirect\n\n";
			exit;

		}
	



	# PREVIEW INVOICE
	# PREVIEW INVOICE

	} elsif ($frm{'postmode'} eq "PREVIEW") {

			# setting up needed globals
			# setting up needed globals

		@UsingInfoFields = ();
		@MasterInfoList = ();
		%MissingInfoFields = ();
		%Computations = ();

		&CheckCookie;
		$OrderID = $frm{'OrderID'};
		$InfoID = $cookieInfoID if ($cookieInfoID);
		$InfoID = $frm{'InfoID'} if $frm{'InfoID'};
		@orders = @NewOrder;

			# Begin Preview Decision Flow
			# Begin Preview Decision Flow

		if (&CheckFieldsNeeded) { 

			if ($cookieOrderID) {

				if ($frm{'submit_preview_info'} eq "NEWSUBMIT") {

					&ReadNewInfo;
					&WriteInfoFile($InfoID);
					$msg_function = "NEWSUBMIT";
	
				} elsif ($frm{'submit_preview_info'} eq "EDITING") {

					&ReadInfoFile($InfoID);
					$msg_function = "EDITING";
			
				} else {

					if ($cookieInfoID) {

						$InfoID = $cookieInfoID;
						&ReadInfoFile($InfoID);
						$msg_function = "FOUNDATA";

					} else {
							
						&GenerateInfoID;
						&MakeNullList;
						$msg_function = "NEWLIST";


					}

				}

			} else {

				print "Location: $cookieredirect\n\n";
				exit;

			} 


		} else {

			if ($cookieOrderID) {

				$msg_function = "Nothing Needed";
				&MakeComputations;
				&PreviewOrder;
				exit;

			} else {

				print "Location: $cookieredirect\n\n";
				exit;

			}


		} 


			# End Preview Decision Flow
			# End Preview Decision Flow


		&MakeCookie($cookiename_InfoID, $InfoID);

		if (&CheckUsingInfoFields) {

			&PreviewInformation;

		} else {

			if ($frm{'submit_preview_info'} eq "EDITING") {

				&PreviewInformation;

			} else {

				&MakeComputations;
				&PreviewOrder;

			} 

		}




	# CUSTOM MODE
	# CUSTOM MODE

	} elsif ($frm{'postmode'} eq "CUSTOM") {

		$ErrMsg="Designer has set a Custom Input Mode<br>";
		$ErrMsg=$ErrMsg . "Designer has set a Custom Input Mode<br>";
		$ErrMsg=$ErrMsg . "Designer has set a Custom Input Mode<br>";
		$ErrMsg=$ErrMsg . "Designer has set a Custom Input Mode";
		&ErrorMessage($ErrMsg);	



	# MODE NOT FOUND
	# MODE NOT FOUND

	} else {
 
		$ErrMsg="Unable to determine Input Mode<br>";
		$ErrMsg=$ErrMsg . "postmode: $frm{'postmode'}<br>";
		$ErrMsg=$ErrMsg . "Contact the Web Developer<br>";
		$ErrMsg=$ErrMsg . "Referring URL:<br> $ENV{'HTTP_REFERER'}";
		&ErrorMessage($ErrMsg);

	}

 }




	# ACCEPT ORDER 
	# ACCEPT ORDER 

sub AcceptOrder {

	@header = ();
	@footer = ();

	my ($i)=0;
	my (@list) = ();
	my ($nav_top, $nav_bottom) = (0,0);
	my ($li, $lk, $lv, $msg_status, $msg_n);
	my ($totalprice, $totalqnty, $temprice);
	my ($line, $qty, $item, $desc, $price, $ship, $taxit);

	if ($frm{'previouspage'}) {
		$previouspage = $frm{'previouspage'};
		} else {
		$previouspage = $ENV{'HTTP_REFERER'};
		}


	$msg_n = scalar(@orders);
	$msg_status = "Viewing $msg_n Items" if ($msg_n > 1);
	$msg_status = "Viewing $msg_n Item" if ($msg_n == 1);

	if ($msg_n == 0) {$msg_status = "Viewing No Items"}


	&GetTemplateFile($accept_order_template,"Main Template File"); 

	print "Content-Type: text/html\n\n";
	print "@header \n\n";

	$OrderID = $cookieOrderID if ($cookieOrderID);
	$OrderID = $OrderID if ($OrderID);


	# START PRINTING FROM HEADER 
	# START PRINTING FROM HEADER 


		# Insert MOF navigation at TOP
		# Insert MOF navigation at TOP

	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_help_top);


	if ($nav_top) {
	print "<table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_previous_top) {
	print "<td nowrap><a href=\"$previouspage\">$menu_previous_top</a></td> \n";}

	if ($menu_help_top) {
	print "<td nowrap> \n";
	print "<a href=\"$menu_help_top_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_top_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_top</a></td> \n";}

	print "</tr></table><br> \n\n";
	}


		# Update hidden POST AcceptOrder Quantities Form
		# Update hidden POST AcceptOrder Quantities Form

	print "<FORM method=POST action=\"$programfile\"> \n";

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%><tr><td> \n";


	print "<input type=hidden name=\"postmode\" value=\"UPDATE\"> \n";
	print "<input type=hidden name=\"OrderID\" value=\"$OrderID\"> \n";
	print "<input type=hidden name=\"previouspage\" value=\"$previouspage\"> \n\n";

	print "<table $action_message_bg border=0 cellpadding=0 cellspacing=0 width=300> \n";
	print "<tr><td><center> \n";
	print "$action_message_s $msg_status <br> ";
	print "$msg_function $action_message_e </center> </td> \n";
	print "</tr></table> \n";

	print "</td><td align=right> \n";

	print "<table border=0 cellpadding=0 cellspacing=0> \n";
	print "<tr><td align=right nowrap>$datetime_s Order ID: $OrderID $datetime_e </td></tr>\n";
	print "<tr><td align=right nowrap>$datetime_s $Date $ShortTime $datetime_e </td></tr> \n";
	print "</table> \n";

	print "</td></tr></table> \n";
	
		# printing orders in cart
		# printing orders in cart

	print "<table $tableborder_color cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr bgcolor=$tableheading> \n";
	print "<td align=center>$fontheading <strong>Qty</strong></font></td> \n";
	print "<td align=center nowrap>$fontheading <strong>Item Name</strong></font></td> \n";
	print "<td align=center>$fontheading <strong>Description</strong></font></td> \n";
	print "<td align=center>$fontheading <strong>Price</strong></td></font></tr> \n";

		# populate orders in table / store hidden input
		# populate orders in table / store hidden input

	foreach $line (@orders) {
  	($qty, $item, $desc, $price, $ship, $taxit) = split (/$delimit/, $line);

		++$i;
	         
   	print "<tr bgcolor=$tableitem> \n";
	print "<td>$fontqnty </font>\n\n";

	print "<input type=text name=\"quantity_$i\" value=\"$qty\" size=4 maxlength=4> \n";

	print "</td><td> \n";
	print "<input type=hidden name=\"product_$i\" \n";
	print "value=\"$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit\"> \n\n";

	print "$fontitem $item </font></td> \n";


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

		
	print "<td>$desc </td> \n";


			# Print row for single item or multiple to sub totals
			# Print row for single item or multiple to sub totals

	if ($qty > 1) {
	print "<td align=right>$fontprice \&nbsp\; </font></td></tr>\n";

		$sub_price = ($qty * $price);
		$totalprice += $sub_price;
		$totalqnty += $qty;
      	$sub_price = sprintf "%.2f", $sub_price;
      	$sub_price = CommifyMoney ($sub_price);
		$price = CommifyMoney ($price);
		$qty = CommifyNumbers ($qty);

   		print "<tr bgcolor=$tablesub><td> \&nbsp\; </td>\n";
		print "<td colspan=2>$fontsubtext\n"; 
		print "Sub Total $qty of $item at ";
		print "$currency $price each </font></td>\n";
		print "<td align=right nowrap>$fontsub $currency $sub_price </font></td></tr>\n\n";

	} else {

		$totalprice += $price;
		$totalqnty += $qty;
		$price = CommifyMoney ($price);		
		print "<td valign=bottom align=right nowrap>$fontprice$currency $price </font></td></tr>\n\n";

	}

	}

   	print "</table> \n";
	print "$returntofont \n";



		# Print Summary Totals
		# Print Summary Totals

	if ($totalqnty > 1) {$pd = "Products"} else {$pd = "Product"}

	$totalprice = sprintf "%.2f", $totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);

	print "<table border=0 cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr><td align=right width=80%>$totaltext Subtotal <strong> \n";
	print "$totalqnty </strong> $pd ----> </font></td> \n";
	print "<td bgcolor=$totalback align=right nowrap> ";
	print "$totalcolor $currency $totalprice </font></td></tr></table><p> \n";

		# Bottom Navigation Menu
		# Bottom Navigation Menu

	print "<table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_home_bottom) {
	print "<td valign=top nowrap><a href=\"$menu_home_bottom_url\">$menu_home_bottom</a></td> \n";}

	if ($menu_previous_bottom) {
	print "<td valign=top nowrap><a href=\"$previouspage\">$menu_previous_bottom</a></td> \n";}

	# Update FORM ends here, Can only start another FORM POST now
	print "<td valign=top>$menu_update_bottom</FORM></td> \n";

	if ($menu_delete_bottom && $msg_n) {
	print "<td valign=top>";
	print "<FORM method=POST action=\"$programfile\" name='orderform'> \n";
	print "<input type=hidden name=\"postmode\" value=\"DELETE\"> \n";
	print "<input type=hidden name=\"deleted_items\" value=\"$msg_n\"> \n";
	print "<input type=hidden name=\"OrderID\" value=\"$OrderID\"> \n";
	print "<input type=hidden name=\"previouspage\" value=\"$previouspage\"> \n";
	print "$menu_delete_bottom</FORM></td> \n";
	}

	if ($menu_preview_bottom && $msg_n) {
	print "<td valign=top>";
	print "<FORM method=POST action=\"$programfile\"> \n";
	print "<input type=hidden name=\"postmode\" value=\"PREVIEW\"> \n";
	print "<input type=hidden name=\"OrderID\" value=\"$OrderID\"> \n";
	print "<input type=hidden name=\"previouspage\" value=\"$previouspage\"> \n\n";
	foreach $line (@orders) {print "<input type=hidden name=\"order\" value=\"$line\"> \n"}
	print "$menu_preview_bottom</FORM></td> \n";
	}

	if ($menu_help_bottom) {
	print "<td valign=top> \n";
	print "<a href=\"$menu_help_bottom_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_bottom_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_bottom</a></td> \n";}

	print "</tr></table>";

	if ($msg_n) {
	print "<font size=2>If you changed any quantities, please click <font color=#9B0022>";
	print "<strong>update quantity </strong></font><font color=#000000> before proceeding to </font>";
	print "<font color=#9B0022><strong>next</strong></font><font color=#000000>. </font>";

	} else {
	print "<font size=2>You don't have any items in your cart<br>";
	print "You can return to your ";
	print "<a href=\"$previouspage\">Previous Shopping Page</a><br>";
	print "Or you can return to our ";
	print "<a href=\"$menu_home_bottom_url\">Site's Main Page</a></font>";
	}

	print "$returntofont\n";
	print "@footer \n\n";

 }




	# PREVIEW INFORMATION  
	# PREVIEW INFORMATION  

sub PreviewInformation {

	my ($itm_n)=0;
	my ($key, $val);
	my (@InsuranceList) = ();
	my (@MethodList) = ();
	$msg_v;
	@country_list = ();
	@county_list = ();
	@state_list = ();
	($allow_shipping, $allow_tax) = (0,0);

	# count how many items failed validation
	$itm_m = scalar(keys(%MissingInfoFields));

	# using shipping and/or tax flags
	$allow_shipping++ if (scalar(@use_shipping));
	$allow_shipping++ if (scalar(keys(%use_method)));
	$allow_tax++ if (scalar(keys(%use_city_tax)));
	$allow_tax++ if (scalar(keys(%use_county_tax)));
	$allow_tax++ if (scalar(keys(%use_zipcode_tax)));
	$allow_tax++ if (scalar(keys(%use_state_tax)));
	$allow_tax++ if (scalar(keys(%use_country_tax)));
	
	@country_list = (&GetDropBoxList($use_country_list,'Ecom_ShipTo_Postal_CountryCode')) if ($use_country_list);

	@state_list = (&GetDropBoxList($use_state_list,'Ecom_ShipTo_Postal_StateProv')) if ($use_state_list);

	@county_list = (&GetDropBoxList($use_county_list,'Ecom_ShipTo_Postal_County')) if ($use_county_list);
	
	&GetTemplateFile($preview_info_template,"Preview Information File"); 

	# you must call any sub routine that can ErrorMessage(ErrMsg)
	# BEFORE you set up the print Content-Type header

		# start HTML output
		# start HTML output

	print "Content-Type: text/html\n\n";
	print "@header \n\n";

	if ($itm_m == 1) {$fld = "Field is"} 
	else {$fld = "Fields are"}

	if ($msg_function eq "FOUNDATA") {

	print "Please provide the information requested below. $itm_m $fld incomplete. ";
	print "When done, continue by clicking the ";
	print "<strong>next</strong> function below.";

	} elsif ($msg_function eq "EDITING") {
	print "You can Edit any of this information.  When finished Editing, then ";
	print "click the <strong>next</strong> function below to see your order summary. ";

	} elsif ($msg_function eq "NEWSUBMIT") {
	print "Some information for $itm_m $fld missing or incomplete. ";
	print "Please complete all required information and continue by clicking the ";
	print "<strong>next</strong> function below.";

		if ($MissingInfoFields{'Ecom_ShipTo_Online_Email'} eq "Incomplete") {
		print "  <font color=red>Email appears incomplete</font>.";
		}

	} elsif ($msg_function eq "NEWLIST") {
	print "Please provide the information requested below. $itm_m $fld required. ";
	print "When done, continue by clicking the ";
	print "<strong>next</strong> function below.";
	
	}

		
	print "<FORM method=POST action=\"$programfile\" name='editform'> \n";
	print "<input type=hidden name=\"postmode\" value=\"PREVIEW\"> \n";
	print "<input type=hidden name=\"submit_preview_info\" value=\"NEWSUBMIT\"> \n";
	print "<input type=hidden name=\"OrderID\" value=\"$frm{'OrderID'}\"> \n";
	print "<input type=hidden name=\"InfoID\" value=\"$InfoID\"> \n";
	print "<input type=hidden name=\"previouspage\" value=\"$frm{'previouspage'}\"> \n\n";
	foreach $line (@orders) {print "<input type=hidden name=\"order\" value=\"$line\"> \n"}
	print " \n\n";

		# shipping info available
		# shipping info available

	if ($allow_shipping || $allow_tax) {

	$itm_n++;

		# Shipping or just tax Message ?
		# if not shipping then must be tax because of above branch

	if ($allow_shipping) {
	$box_heading = "What Is The Shipping Destination ?";
	$box_message = "We need to know about the shipping destination in order to compute all ";
	$box_message = $box_message . "additional charges for shipping, handling, tax.";

	} else {
	$box_heading = "What Is The Tax Location ?";
	$box_message = "We need to know what your taxing location is so that we can ";
	$box_message = $box_message . "assess any appropriate taxes.";
	}

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$preview_heading \n";
	print "<strong>$box_heading </font></strong>";
	print "<font color=red size=1> EDITING </font>" if ($msg_function eq "EDITING");
	print "</font></td></tr> \n";
	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$preview_text \n";
	print "$box_message </font></td></tr>\n";
	print "<tr><td colspan=2><font size=1><br></font></td></tr></table> \n";

		# shipping-tax box input
		# shipping-tax box input

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";
	print "<tr><td width=5%><br></td>  \n";
	print "<td> \n\n";

	print "<table border=0 cellpadding=2 cellspacing=0 bgcolor=$font_outside_line><tr><td> \n";

	print "<table border=0 cellpadding=2 cellspacing=0> \n";

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Name_Prefix'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Title:</font></td> \n";
	print "<td bgcolor=$font_right_column></font> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Name_Prefix\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Name_Prefix'}\" size=4></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Name_Prefix'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Name_First'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles First Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Name_First\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Name_First'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Name_First'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Name_Middle'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Middle Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Name_Middle\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Name_Middle'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Name_Middle'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Name_Last'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Last Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Name_Last\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Name_Last'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Name_Last'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Name_Suffix'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Last Name Suffix:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Name_Suffix\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Name_Suffix'}\" size=4></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Name_Suffix'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Company'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Company Name:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Company\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Company'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Company'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Street_Line1'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Street_Line1\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Street_Line1'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Street_Line1'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_Street_Line2'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_Street_Line2\" value=\"$NewInfo{'Ecom_ShipTo_Postal_Street_Line2'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_Street_Line2'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_City'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles City:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_City\" value=\"$NewInfo{'Ecom_ShipTo_Postal_City'}\" size=30></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_City'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_StateProv'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_preview_titles State - Province:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

		# Does state field use Drop Box
		# Does state field use Drop Box

	if ($use_state_list) {
	print "<select name=\"Ecom_ShipTo_Postal_StateProv\" onchange='inOhio(this.value)'> \n";
	foreach $itm_db (@state_list) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print " <input name=\"Ecom_ShipTo_Postal_StateProv\" value=\"$NewInfo{'Ecom_ShipTo_Postal_StateProv'}\" size=30>";
	}

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_StateProv'));
	print "</td><td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	
	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_County'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_preview_titles County (Ohio only):</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

		# Does county field use Drop Box
		# Does county field use Drop Box

	if ($use_county_list) {
	print "<select disabled='true' name=\"Ecom_ShipTo_Postal_County\"> \n";
	foreach $itm_db (@county_list) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print " <input disabled='true' name=\"Ecom_ShipTo_Postal_County\" value=\"$NewInfo{'Ecom_ShipTo_Postal_County'}\" size=30>";
	}

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_County'));
	print "</td><td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_PostalCode'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Zip  Code:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Postal_PostalCode\" value=\"$NewInfo{'Ecom_ShipTo_Postal_PostalCode'}\" size=30></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_PostalCode'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Postal_CountryCode'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>";
	print "$font_preview_titles Country:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";

		# Does country field use Drop Box
		# Does country field use Drop Box

	if ($use_country_list) {
	print "<select name=\"Ecom_ShipTo_Postal_CountryCode\"> \n";
	foreach $itm_db (@country_list) {print "$itm_db \n"}
	print "</select> \n";
	} else {
	print " <input name=\"Ecom_ShipTo_Postal_CountryCode\" value=\"$NewInfo{'Ecom_ShipTo_Postal_CountryCode'}\" size=30>";
	}

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Postal_CountryCode'));
	print "</td><td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}


	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Telecom_Phone_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Phone Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Telecom_Phone_Number\" value=\"$NewInfo{'Ecom_ShipTo_Telecom_Phone_Number'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Telecom_Phone_Number'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}
	
if (exists ($shipping_destination_fields{'Ecom_ShipTo_Telecom_Fax_Number'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles Fax Number:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Telecom_Fax_Number\" value=\"$NewInfo{'Ecom_ShipTo_Telecom_Fax_Number'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Telecom_Fax_Number'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}
	
	if (exists ($shipping_destination_fields{'Ecom_ShipTo_Online_Email'})) {
	print "<tr><td align=right bgcolor=$font_left_column nowrap>$font_preview_titles E-mail Address:</font></td> \n";
	print "<td bgcolor=$font_right_column> \n";
	print "<input name=\"Ecom_ShipTo_Online_Email\" value=\"$NewInfo{'Ecom_ShipTo_Online_Email'}\" size=36></td>";

	$msg_v = (&ValidatePreviewFields('Ecom_ShipTo_Online_Email'));
	print "<td bgcolor=$preview_message_bg nowrap>$msg_v </td></tr> \n";
	}

	print "</table>";
	print "</td></tr></table> \n";

	print "</td></tr>";
	print "<tr><td colspan=2><font size=1><br></font></td></tr>";
	print "</table> \n";

		# shipping method
		# shipping method

	if (scalar(keys(%use_method))) {
	$itm_n++;

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$preview_heading \n";
	print "<strong>Select The Shipping Method.</strong></font>";
	print "<font color=red size=1> EDITING</font>" if ($msg_function eq "EDITING");
	print "</td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$preview_text \n";
	print "Please select the shipping method to be used in shipping your order to the ";
	print "above location. </font></td></tr>\n";

	print "<tr><td colspan=2><font size=1><br></td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$preview_text \n";

		# Build options
		# Build options

	@MethodList = (sort keys(%use_method));

	if ($type_method_options =~ /\bdropbox\b/i) {
	print "<select name=\"Compute_Shipping_Method\"> \n";

	foreach $_ (@MethodList) {

	if ($NewInfo{'Compute_Shipping_Method'}) {

		if ($NewInfo{'Compute_Shipping_Method'} eq $_) {
		print "<option selected value=\"$_\"> $use_method{$_} \n";

		} else {
		print "<option value=\"$_\"> $use_method{$_} \n";
		}

	} else {
	
		if ($default_method eq $_) {
		print "<option selected value=\"$_\"> $use_method{$_} \n";

		} else {
		print "<option value=\"$_\"> $use_method{$_} \n";
		}

	}
	}
	print "</select> \n";

	} elsif ($type_method_options =~ /\bradio\b/i) {

	foreach $_ (@MethodList) {

	if ($NewInfo{'Compute_Shipping_Method'}) {

		if ($NewInfo{'Compute_Shipping_Method'} eq $_) {
		print "<input type=radio name=\"Compute_Shipping_Method\" value=\"$_\" checked=\"on\"> $use_method{$_} <br>\n";

		} else {
		print "<input type=radio name=\"Compute_Shipping_Method\" value=\"$_\"> $use_method{$_} <br>\n";
		}

	} else {
	
		if ($default_method eq $_) {
		print "<input type=radio name=\"Compute_Shipping_Method\" value=\"$_\" checked=\"on\"> $use_method{$_} <br>\n";

		} else {
		print "<input type=radio name=\"Compute_Shipping_Method\" value=\"$_\"> $use_method{$_} <br>\n";	
		}

	}
	}
	}

	print "</font></td></tr>\n";
	print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";
	print "</td></tr></table> \n";

	}


		# insurance options
		# insurance options

	if (scalar(keys(%use_insurance)) && $allow_shipping) {
	$itm_n++;

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$preview_heading \n";
	print "<strong>Do You Want To Insure The Package ?</font></strong>";
	print "<font color=red size=1> EDITING</font>" if ($msg_function eq "EDITING");
	print "</td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$preview_text \n";
	print "Please select the amount of insurance you want. </font></td></tr>\n";

	print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$preview_text \n";

		# Build options
		# Build options

	@InsuranceList = (sort values(%use_insurance));

	if ($type_insurance_options =~ /\bdropbox\b/i) {
	print "<select name=\"Compute_Insurance\"> \n";

	foreach $_ (@InsuranceList) {
		while (($key, $val) = each (%use_insurance)) {		
			if ($_ == $val) {

				if ($NewInfo{'Compute_Insurance'} == $val) {
				print "<option selected value=\"$val\">$key \n";
				} else {
				print "<option value=\"$val\">$key \n";
				}

			}

		}

	}
	print "</select> \n";

	} elsif ($type_insurance_options =~ /\bradio\b/i) {

	foreach $_ (@InsuranceList) {
		while (($key, $val) = each (%use_insurance)) {		
			if ($_ == $val) {
				if ($NewInfo{'Compute_Insurance'} == $val) {
				print "<input type=radio name=\"Compute_Insurance\" value=\"$val\" checked=\"on\"> $key <br>\n";
				} else {
				print "<input type=radio name=\"Compute_Insurance\" value=\"$val\"> $key <br>\n";
				}

			}

		}

	}

	}

	print "</font></td></tr>\n";
	print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";
	print "</td></tr></table> \n";

	} # End use_insurance
	} # End overall usage of tax, address, method, insurance


		# discount coupons
		# discount coupons

	if (scalar(@use_coupons)) {
	$itm_n++;

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%> \n";

	print "<tr><td width=5% nowrap><font size=3><strong>$itm_n.</strong></font></td> \n";
	print "<td  width=95%>$preview_heading \n";
	print "<strong>Do You Have Any Discount Coupons ?</font></strong>";
	print "<font color=red size=1> EDITING</font>" if ($msg_function eq "EDITING");
	print "</td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%>$preview_text \n";
	print "Please enter any discount coupon numbers or codes. <br>";
	print "Enter None or New Member if you don't have any. </font></td></tr>\n";

	print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";

	print "<tr><td width=5%><br></td> \n";
	print "<td width=95%> \n";

	if ( $NewInfo{'Compute_Coupons'} ) {
	print "<input name=\"Compute_Coupons\" value=\"$NewInfo{'Compute_Coupons'}\" size=30></font> \n";
	
	} else {
	print "<input name=\"Compute_Coupons\" value=\"$default_coupon\" size=30></font> \n";

	}

	$msg_v = (&ValidatePreviewFields('Compute_Coupons'));
	print " $msg_v";
	print "</td></tr>\n";
	print "<tr><td colspan=2><font size=1><br></font></td></tr> \n";
	print "</td></tr></table> \n";

	}


		# Submit Preview Information Menu
		# Submit Preview Information Menu

	print "<table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_home_bottom) {
	print "<td valign=top nowrap><a href=\"$menu_home_bottom_url\">$menu_home_bottom</a></td> \n";}

	if ($menu_previous_bottom) {
	print "<td valign=top nowrap><a href=\"$frm{'previouspage'}\">$menu_previous_bottom</a></td> \n";}

	if ($menu_editcart_bottom) {
	print "<td valign=top nowrap>";
	print "<a href=\"$programfile?viewcart&previouspage=$frm{'previouspage'}\"> ";
	print "$menu_editcart_bottom</a></td> \n";
	}


	# Submit Preview FORM ends here
	print "<td valign=top>$menu_preview_bottom</FORM></td> \n";

	if ($menu_help_bottom) {
	print "<td valign=top> \n";
	print "<a href=\"$menu_help_bottom_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_bottom_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_bottom</a></td> \n";}

	print "</tr></table>";



	# DEBUG PREVIEW INFO PAGE
	# DEBUG PREVIEW INFO PAGE
	# print "<br><hr><u><strong>\%MissingInfoFields</strong></u>";
	# while (($key, $val) = each (%MissingInfoFields)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "<br><hr><u><strong>\%NewInfo</strong> Global Array </u>";
   	# while (($key, $val) = each (%NewInfo)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "<hr><strong><u>\@UsingInfoFields</u></strong>";
	# foreach $_ (@UsingInfoFields) {print "<li>$_"}
	# print "<br><hr><u><strong>\%shipping_destination_fields</strong> CONFIG</u>";
   	# while (($key, $val) = each (%shipping_destination_fields)) { 
	# print "<li>$key, $val \n";
	# }
	# print "<br><hr><u><strong>All Global Vars</strong></u>";
	# print "<li>postmode = $frm{'postmode'}";
	# print "<li>submit_preview_info = $frm{'submit_preview_info'}";
	# print "<li>FRM-OrderID = $frm{'OrderID'}";
	# print "<li>OrderID = $OrderID";
	# print "<li>FRM-InfoID = $frm{'InfoID'}";
	# print "<li>InfoID = $InfoID";
	# print "<li>previouspage = $frm{'previouspage'}";
	# print "<li>msg_i = $msg_i";
	# print "<li>cookieOrderID = $cookieOrderID";
	# print "<li>cookieInfoID = $cookieInfoID";
	# TESTING ORDERS ARRAY
	# print "<font size=2><br><hr>\n";
	# print "<u><strong>\@orders</strong> Main List</u>";
	# foreach $line (@orders) {print "<li>$line";}
		

	print "$returntofont\n";
	print "@footer \n\n";

  }





	# PREVIEW INVOICE ORDER 
	# PREVIEW INVOICE ORDER 

sub PreviewOrder {

	@header = ();
	@footer = ();

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
	my ($FinalAmount) = CommifyMoney ($Computations{'Final_Amount'});
	my ($FinalProducts) = CommifyNumbers ($Computations{'Primary_Products'});

	my ($msg_tab);
	my ($msg_tab_ck) = 0;

	$msg_status = "$FinalProducts Products " if ($Computations{'Primary_Products'} > 1);
	$msg_status = "$FinalProducts Product " if ($Computations{'Primary_Products'} == 1);
	$msg_status = $msg_status . " $currency $FinalAmount ";

	# using shipping and/or tax flags
	$allow_shipping++ if (scalar(@use_shipping));
	$allow_shipping++ if (scalar(keys(%use_method)));
	$allow_tax++ if (scalar(keys(%use_city_tax)));
	$allow_tax++ if (scalar(keys(%use_county_tax)));
	$allow_tax++ if (scalar(keys(%use_zipcode_tax)));
	$allow_tax++ if (scalar(keys(%use_state_tax)));
	$allow_tax++ if (scalar(keys(%use_country_tax)));

	&GetTemplateFile($preview_template,"Preview Template File"); 

	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	
		# Insert MOF navigation at TOP
		# Insert MOF navigation at TOP

	$nav_top++ if ($menu_previous_top);
	$nav_top++ if ($menu_viewcart_top);
	$nav_top++ if ($menu_help_top);

	if ($nav_top) {
	print "<table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_previous_top) {
	print "<td nowrap><a href=\"$frm{'previouspage'}\">$menu_previous_top</a></td> \n";}

	if ($menu_viewcart_top) {
	print "<td nowrap>";
	print "<a href=\"$programfile?viewcart&previouspage=$frm{'previouspage'}\"> ";
	print "$menu_viewcart_top</a></td> \n";
	}

	if ($menu_help_top) {
	print "<td nowrap> \n";
	print "<a href=\"$menu_help_top_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_top_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_top</a></td> \n";}

	print "</tr></table><br> \n\n";
	}


		# Top information
		# Top information

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%><tr><td width=300> \n";
	print "<table $action_message_bg_preview border=0 cellpadding=0 cellspacing=0 width=300 height=100%> \n";

		# Display shipping info, etc.
		# Display shipping info, etc.

	print "<tr><td valign=bottom> \n";
	print "<table border=0 cellpadding=6 cellspacing=0 width=100% height=100%> ";
	print "<tr><td> \n";

	if ($allow_shipping) {
	$msg_tab = "<font size=1 color=black>SHIP TO: </font><br>" ;	

	} elsif ($allow_tax) {
	$msg_tab = "<font size=1 color=black>TAX AREA: </font><br>"
	
	} else {
	$msg_tab = "<font size=1 color=black>ORDER PREVIEW: </font><br>" ;	
	$msg_tab = $msg_tab . "$action_message_s $msg_status $action_message_e\n"
	}

	print "$msg_tab </font>\n";
	print "$action_message_s \n";
	$edit_check_top = 0;

	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Prefix'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Name_Prefix'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_Name_First'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Name_First'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Middle'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Name_Middle'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Last'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Name_Last'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_Name_Suffix'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Name_Suffix'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}

	print "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($NewInfo{'Ecom_ShipTo_Postal_Company'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Company'} <br>\n";
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_Street_Line1'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Street_Line1'} <br>\n";
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_Street_Line2'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_Street_Line2'} <br>\n";
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_City'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_City'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}

	if ($NewInfo{'Ecom_ShipTo_Postal_StateProv'}) {
	unless ($NewInfo{'Ecom_ShipTo_Postal_StateProv'} eq "NOTINLIST") {
	print "$NewInfo{'Ecom_ShipTo_Postal_StateProv'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	}
	if ($NewInfo{'Ecom_ShipTo_Postal_County'}) {
	unless ($NewInfo{'Ecom_ShipTo_Postal_County'} eq "NOTINLIST") {
	print "$NewInfo{'Ecom_ShipTo_Postal_County'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	}
	
	if ($NewInfo{'Ecom_ShipTo_Postal_PostalCode'}) {
	print "$NewInfo{'Ecom_ShipTo_Postal_PostalCode'} \n";
	$msg_tab_ck++;
	$edit_check_top++;
	}
	
	print "<br>" if ($msg_tab_ck);
	$msg_tab_ck = 0;

	if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'}) {
	my ($tc) = $NewInfo{'Ecom_ShipTo_Postal_CountryCode'};
	$tc =~ s/-/ /g;
	print "$tc \n";
	$edit_check_top++;
	}


	print "$action_message_e </td></tr></table> \n";
	print "</td> \n";
	print "</tr></table> \n";

		# Top Edit Button - Can't edit unless ship or tax
		# Top Edit Button - Can't edit unless ship or tax
	
	if ($allow_shipping || $allow_tax) {

	if ($menu_edit_preview_top) {
	print "</td><td valign=bottom> \n";
	print "<FORM method=POST action=\"$programfile\"> \n";
	print "<input type=hidden name=\"postmode\" value=\"PREVIEW\"> \n";
	print "<input type=hidden name=\"submit_preview_info\" value=\"EDITING\"> \n";
	print "<input type=hidden name=\"OrderID\" value=\"$frm{'OrderID'}\"> \n";
	print "<input type=hidden name=\"InfoID\" value=\"$InfoID\"> \n";
	print "<input type=hidden name=\"previouspage\" value=\"$frm{'previouspage'}\"> \n\n";
	foreach $line (@orders) {print "<input type=hidden name=\"order\" value=\"$line\"> \n"}
	print "$menu_edit_preview_top </FORM> \n";

	}
	}


		# Displaying OrderID Date
		# Displaying OrderID Date

	print "</td><td align=right valign=bottom> \n";
	print "<table border=0 cellpadding=0 cellspacing=0> \n";

	print "<tr><td align=right nowrap>$datetime_s Order ID: $OrderID $datetime_e </td></tr>\n";
	print "<tr><td align=right nowrap>$datetime_s $Date $ShortTime $datetime_e </td></tr> \n";

	print "</table> \n";
	print "</td></tr></table> \n";
	

		# printing orders in cart
		# printing orders in cart

	print "<table $tableborder_color cellpadding=1 cellspacing=0 width=90%> \n";
	print "<tr bgcolor=$tableheading> \n";
	print "<td align=center>$fontheading <strong>Qty</strong></font></td> \n";
	print "<td align=center nowrap>$fontheading <strong>Item Name</strong></font></td> \n";
	print "<td align=center>$fontheading <strong>Description</strong></font></td> \n";
	print "<td align=center>$fontheading <strong>Price</strong></font></td></tr> \n";

		# populate orders in table / store hidden input
		# populate orders in table / store hidden input

	foreach $line (@orders) {
  	($qty, $item, $desc, $price, $ship, $taxit) = split (/$delimit/, $line);

   	print "<tr bgcolor=$tableitem> \n";
	print "<td><center> $fontqnty $qty </center></font></td> \n";

	if ($Computations{'Tax_Amount'} > 0 && $identify_tax_items && $taxit) {
	print "<td>$fontitem $item </font> $identify_tax_items </td> \n";
	} else {
	print "<td>$fontitem $item </font></td> \n";
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
		
	print "<td>$desc </td> \n";

			# Print row for single item or multiple to sub totals
			# Print row for single item or multiple to sub totals

	if ($qty > 1) {
	print "<td align=right>$fontprice \&nbsp\; </font></td></tr>\n";

		$sub_price = ($qty * $price);
		$totalprice += $sub_price;
		$totalqnty += $qty;
      	$sub_price = sprintf "%.2f", $sub_price;
      	$sub_price = CommifyMoney ($sub_price);
		$price = CommifyMoney ($price);
		$qty = CommifyNumbers ($qty);

   		print "<tr bgcolor=$tablesub><td> \&nbsp\; </td>\n";
		print "<td colspan=2>$fontsubtext\n"; 
		print "Sub Total $qty of $item at ";
		print "$currency $price each </font></td>\n";
		print "<td align=right nowrap>$fontsub $currency $sub_price </font></td></tr>\n\n";

	} else {

		$totalprice += $price;
		$totalqnty += $qty;
		$price = CommifyMoney ($price);		
		print "<td valign=bottom align=right nowrap>$fontprice$currency $price </font></td></tr>\n\n";

	}

	}

   	print "</table> \n";
	print "$returntofont \n";


		# start edit link
		# start edit link

	print "<table border=0 cellpadding=0 cellspacing=0 width=90%><tr> \n";

	if ($menu_edit_preview_summary) {

	$edit_check = 0;
	$edit_check++ if ($Computations{'Shipping_Amount'} > 0 && $allow_shipping);
	$edit_check++ if ($Computations{'Tax_Amount'} > 0 && $allow_tax);
	$edit_check++ if ($Computations{'Insurance'} > 0);
	$edit_check++ if ($Computations{'Coupon_Discount'} > 0);

	if ($edit_check) {
	print "<td align=right> \n";
	print "<FORM method=POST action=\"$programfile\"> \n";
	print "<input type=hidden name=\"postmode\" value=\"PREVIEW\"> \n";
	print "<input type=hidden name=\"submit_preview_info\" value=\"EDITING\"> \n";
	print "<input type=hidden name=\"OrderID\" value=\"$frm{'OrderID'}\"> \n";
	print "<input type=hidden name=\"InfoID\" value=\"$InfoID\"> \n";
	print "<input type=hidden name=\"previouspage\" value=\"$frm{'previouspage'}\"> \n\n";
	foreach $line (@orders) {print "<input type=hidden name=\"order\" value=\"$line\"> \n"}
	print "$menu_edit_preview_summary </FORM>";
	print " </td> \n\n";
	}
	}



		# Right Summary tables
		# Right Summary tables

	print "<td align=right> ";


		# Display Summary Totals
		# Display Summary Totals

	if ($totalqnty > 1) {$pd = "Products"} else {$pd = "Product"}

	$totalprice = sprintf "%.2f", $totalprice;
	$totalprice = CommifyMoney ($totalprice);
	$totalqnty = CommifyNumbers ($totalqnty);

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext Subtotal <strong> \n";
	print "$totalqnty </strong> $pd ----> </font></td> \n";
	print "<td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency $totalprice </font></td></tr></table> \n";


		# Totals from %Computations ------------------>
		# Totals from %Computations ------------------>
		# CommifyMoney here, keep computations free of formatting


		# Display First Discount
		# Display First Discount

	if ($Computations{'Primary_Discount'} > 0) {
	$DiscountOne = CommifyMoney ($Computations{'Primary_Discount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "Discount $Computations{'Primary_Discount_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap><font color=red>-</font> $totalcolor $currency ";
	print " $DiscountOne </font></td></tr></table> \n";
	}


		# Display Coupon Discount
		# Display Coupon Discount
		
	if ($Computations{'Coupon_Discount'} > 0) {
	$DiscountTwo = CommifyMoney ($Computations{'Coupon_Discount'});
	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "Discount $Computations{'Coupon_Discount_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap><font color=red>-</font> $totalcolor $currency ";
	print "$DiscountTwo </font></td></tr></table> \n";
	}


		# Display Subtotal if discounts
		# Display Subtotal if discounts

	if ($Computations{'Combined_Discount'} > 0 ) {
	$SubDiscount = CommifyMoney ($Computations{'Sub_Final_Discount'});
	$CombinedDiscount = CommifyMoney ($Computations{'Combined_Discount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "Sub Total After $currency $CombinedDiscount Total Discount ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency <strong>$SubDiscount </strong></font></td></tr></table> \n";
	}


		# Tax Before
		# Tax Before

	if ($Computations{'Tax_Amount'} > 0 && $Computations{'Tax_Rule'} eq "BEFORE") {
	$TaxRate = ($Computations{'Tax_Rate'} * 100);
	$AdjustedTax = CommifyMoney ($Computations{'Adjusted_Tax_Amount_Before'});
	$Tax = CommifyMoney ($Computations{'Tax_Amount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "Sales tax $TaxRate\% \(on $currency $AdjustedTax taxable\) ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency $Tax </font></td></tr></table> \n";
	}


		# Handling Charges
		# Handling Charges

	if ($Computations{'Handling'} > 0) {
	$HandlingCharges = CommifyMoney ($Computations{'Handling'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "Handling $Computations{'Handling_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency $HandlingCharges </font></td></tr></table> \n";
	}


		# Insurance Charges
		# Insurance Charges

	if ($Computations{'Insurance'} > 0) {
	$InsuranceCharges = CommifyMoney ($Computations{'Insurance'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "Insurance $Computations{'Insurance_Status'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency $InsuranceCharges </font></td></tr></table> \n";
	}


		# Shipping Charges
		# Shipping Charges


	if ($Computations{'Shipping_Amount'} > 0 ) {
	$ShippingCharges = CommifyMoney ($Computations{'Shipping_Amount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "$Computations{'Shipping_Message'} ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency $ShippingCharges </font></td></tr></table> \n";
	}


		# Tax After
		# Tax After

	if ($Computations{'Tax_Amount'} > 0 && $Computations{'Tax_Rule'} eq "AFTER") {
	$TaxRate = ($Computations{'Tax_Rate'} * 100);
	$AdjustedTax = CommifyMoney ($Computations{'Adjusted_Tax_Amount_After'});
	$Tax = CommifyMoney ($Computations{'Tax_Amount'});

	print "<table border=0 cellpadding=1 cellspacing=0 width=100% width=90%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "Sales tax $TaxRate\% \(on $currency $AdjustedTax taxable\) ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency $Tax </font></td></tr></table> \n";
	}


		# Final Total
		# Final Total

	print "<table border=0 cellpadding=1 cellspacing=0 width=100%> \n";
	print "<tr><td align=right width=80% nowrap>$totaltext \n";
	print "<strong>Total Order Amount</strong> ----> </font>\n";
	print "</td><td bgcolor=$totalback align=right width=20% nowrap> ";
	print "$totalcolor $currency <strong> $FinalAmount </strong> </font></td></tr></table> \n";

		# overall table for edit link

	print "</td></tr></table> \n";


		# Bottom Navigation Menu
		# Bottom Navigation Menu

	print "<p><table border=0 cellpadding=0 cellspacing=0><tr> \n";

	if ($menu_home_bottom) {
	print "<td valign=top nowrap><a href=\"$menu_home_bottom_url\">$menu_home_bottom</a></td> \n";}

	if ($menu_previous_bottom) {
	print "<td valign=top nowrap><a href=\"$frm{'previouspage'}\">$menu_previous_bottom</a></td> \n";}

	if ($menu_editcart_bottom) {
	print "<td valign=top nowrap>";
	print "<a href=\"$programfile?viewcart&previouspage=$frm{'previouspage'}\"> ";
	print "$menu_editcart_bottom</a></td> \n";
	}


		# Edit Preview Information
		# Edit Preview Information

	if (scalar(@UsingInfoFields)) {

	if ($menu_edit_preview_bottom) {
	print "<td valign=top>";
	print "<FORM method=POST action=\"$programfile\"> \n";
	print "<input type=hidden name=\"postmode\" value=\"PREVIEW\"> \n";
	print "<input type=hidden name=\"submit_preview_info\" value=\"EDITING\"> \n";
	print "<input type=hidden name=\"OrderID\" value=\"$frm{'OrderID'}\"> \n";
	print "<input type=hidden name=\"InfoID\" value=\"$InfoID\"> \n";
	print "<input type=hidden name=\"previouspage\" value=\"$frm{'previouspage'}\"> \n\n";
	foreach $line (@orders) {print "<input type=hidden name=\"order\" value=\"$line\"> \n"}
	print "$menu_edit_preview_bottom</FORM></td> \n";
	}
	
	}


		# PAYMENT CENTER POST
		# PAYMENT CENTER POST

	print "<td valign=top>";
	print "<FORM method=\"post\" action=\"$paymentfile\"> \n";
	print "\n\n";

		# parse collected data ---------------->
		# parse collected data ---------------->

   	while (($key, $val) = each (%Computations)) { 
	print "<input type=\"hidden\" name=\"$key\" value=\"$val\"> \n";
	}

	foreach $_ (@orders) {
	print "<input type=\"hidden\" name=\"order\" value=\"$_\"> \n"
	}

   	while (($key, $val) = each (%NewInfo)) { 
	print "<input type=\"hidden\" name=\"$key\" value=\"$val\"> \n";
	}

	print "<input type=\"hidden\" name=\"Allow_Tax\" value=\"$allow_tax\"> \n";
	print "<input type=\"hidden\" name=\"Allow_Shipping\" value=\"$allow_shipping\"> \n";

	print "<input type=\"hidden\" name=\"OrderID\" value=\"$frm{'OrderID'}\"> \n";
	print "<input type=\"hidden\" name=\"InfoID\" value=\"$InfoID\"> \n";
	print "<input type=\"hidden\" name=\"previouspage\" value=\"$frm{'previouspage'}\"> \n\n";
	print "$menu_payment_bottom</FORM></td> \n";

	if ($menu_help_bottom) {
	print "<td valign=top> \n";
	print "<a href=\"$menu_help_bottom_url\" target=\"view\" \n";
	print "onClick=\"open(\'$menu_help_bottom_url\',\'view\',\'height=450,width=400,scrollbars\')\;\"> \n";
	print "$menu_help_bottom</a></td> \n";}

	print "</tr></table>";


	# DEBUG PREVIEW
	# DEBUG PREVIEW
	# print "<br><hr><u><strong>\%Computations</strong></u>";
   	# while (($key, $val) = each (%Computations)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "<br><hr><u><strong>\%MissingInfoFields</strong></u>";
   	# while (($key, $val) = each (%MissingInfoFields)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "<br><hr><u><strong>\%NewInfo</strong> Global Array </u>";
   	# while (($key, $val) = each (%NewInfo)) { 
	# print "<li>$key, <strong>$val</strong> \n";
	# }
	# print "<hr><strong><u>\@UsingInfoFields</u></strong>";
	# foreach $_ (@UsingInfoFields) {print "<li>$_"}
	# print "<br><hr><u><strong>\%shipping_destination_fields</strong> CONFIG</u>";
   	# while (($key, $val) = each (%shipping_destination_fields)) { 
	# print "<li>$key, $val \n";
	# }
	# print "<br><hr><u><strong>All Global Vars</strong></u>";
	# print "<li>postmode = $frm{'postmode'}";
	# print "<li>submit_preview_info = $frm{'submit_preview_info'}";
	# print "<li>FRM-OrderID = $frm{'OrderID'}";
	# print "<li>OrderID = $OrderID";
	# print "<li>FRM-InfoID = $frm{'InfoID'}";
	# print "<li>InfoID = $InfoID";
	# print "<li>previouspage = $frm{'previouspage'}";
	# print "<li>msg_i = $msg_i";
	# print "<li>cookieOrderID = $cookieOrderID";
	# print "<li>cookieInfoID = $cookieInfoID";
	# TESTING ORDERS ARRAY
	# print "<font size=2><br><hr>\n";
	# print "<u><strong>\@orders</strong> Main List</u>";
	# foreach $line (@orders) {print "<li>$line";}

			
	print "$returntofont\n";
	print "@footer \n\n";

  }












