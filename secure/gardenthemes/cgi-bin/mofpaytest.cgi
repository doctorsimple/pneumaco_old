#!/usr/bin/perl

# Merchant OrderForm v1.53 Final Processing Testing
# Copyright © August 2000, All Rights Reserved
# Austin Contract Computing, Austin, Texas
# Russell Alexander - rga@io.com
# http://www.io.com/~rga/

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

# COPYRIGHT NOTICE__________________________________________
# The contents of this file is protected under the United States
# copyright laws as an unpublished work, and is confidential and
# proprietary to Austin Contract Computing, Inc. Its use or disclosure 
# in whole or in part without the expressed written permission of Austin
# Contract Computing, Inc. is prohibited.

# Note: This file is for programmers who want to develop
# Note: A final payment module from the MOF v1.53 Front end
# Note: This example file shows all the variable input from the MOF v1.53 Front End
# Note: The Front End does all product collection, shipping destination, 
# Note: Shipping options, Other options affecting Tax, Coupons, Discounts, etc.
# Note: The Front end produces a Completely Formatted, totally computated Invoice Preview
# Note: Where all necessary variables are present to begin asking for payment info
# Note: You can make your own API between the MOF v1.53 Front End and an Online Processing Service

 require 5.001;

 	# The names of the cookies being used:
	# If you need them

 $cookiename_OrderID = 'mof_v15_OrderID';
 $cookiename_InfoID = 'mof_v15_InfoID';


		# Get Input
		# Get Input
		# You need to build @orders from Parsed input

	@orders = ();
	my ($name, $value, $line);

	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);

	foreach $pair (@pairs) {

	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/"/ /;

	push (@orders, $value) if ($name eq "order");
	$frm{$name} = $value;
    	}

	delete ($frm{'order'});
	delete ($frm{'x'});
	delete ($frm{'y'});


		# Print Variables Available
		# Print Variables Available

	print "Content-Type: text/html\n\n";
	print "<html><head><title>MOF v1.53 Front End Variables Test</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";

	print "<h3>Merchant OrderForm v1.53 Front End Variables Available</h3>";


	print "For programmers who want to build their own payment processing 
		using the Merchant OrderForm v1.53 Front End. <p>\n\n";



		# What's in the Parsed Array
		# What's in the Parsed Array

	print "<strong><u>All Shipping Address Info is Available in %frm ?</u></strong><p>";

	print "<ol>";
	while (($key, $val) = each (%frm)) { 
	print "<li>$key, <strong>$val</strong> \n" if($key =~ /^Ecom_/);
	}
	print "</ol>";
	
	print "<strong><u>All Other Info in %frm ?</u></strong><p>";

	print "Here is a list of all the info in %frm outside the Shipping 
		Destination fields. The remaining data is a complete listing 
 		of all results from the computations routines when the preview
		is computed.  All info is listed here in no particular order.
		All of the %Computations array is POSTed to the next process
		(mofpayment.cgi) as listed here and will end up in that %frm array.\n\n";


	print "<ol>";
	while (($key, $val) = each (%frm)) { 
	print "<li>$key, <strong>$val</strong> \n" if($key !~ /^Ecom_/);
	}
	print "</ol>";



	print "Here's how the tabulations occur. You must follow this sequence if 
		you will be reproducing any itimized output of the invoice. The 
		computations are already done, the above variables hold the
   		results off all computations.\n\n";


	print "<ol>
		<li>Number of products and initial summed price

			<ul><strong>
			<li>Primary_Products
			<li>Primary_Price
			</strong>
			</ul>

		<li>Any Regular discountes applied

			<ul><strong>
			<li>Primary_Discount
			<li>Primary_Discount_Status </strong> Message <strong>
			</strong>
			</ul>

		<li>Any Coupon discounts applied

			<ul><strong>
			<li>Coupon_Discount
			<li>Coupon_Discount_Status </strong> Message <strong>	
			</strong>
			</ul>

		<li>Sub Total after any discounts

			<ul><strong>
			<li>Combined_Discount </strong> what it says <strong>
			<li>Sub_Final_Discount
			</strong>
			</ul>

		<li><font color=red>Tax Amount (if taxing Before SHI)<font color=black>

			<ul><strong>
			<li>Tax_Rule eq \"BEFORE\"
			<li>Adjusted_Tax_Amount_Before </strong>Amount to be taxed<strong>
			<li>Tax_Amount </strong>Actual tax<strong>
			<li>Tax_Rate
			</strong>
			</ul>

		<li>Handling charges

			<ul><strong>
			<li>Handling
			<li>Handling_Status </strong> Message <strong>	
			</strong>
			</ul>

		<li>Insurance charges

			<ul><strong>
			<li>Insurance
			<li>Insurance_Status </strong> Message <strong>	
			</strong>
			</ul>

		<li>Shipping charges

			<ul><strong>
			<li>Total_Weight </strong>if used <strong>
			<li>Shipping_Amount
			<li>Shipping_Message </strong> Message <strong>
			</strong>
			</ul>

		<li><font color=red>Tax Amount (if taxing After SHI)<font color=black>

			<ul><strong>
			<li>Tax_Rule eq \"AFTER\"
			<li>Adjusted_Tax_Amount_After </strong>Amount to be taxed<strong>
			<li>Tax_Amount </strong>Actual tax<strong>
			<li>Tax_Rate
			</strong>
			</ul>

		<li>Actual Total for Invoice All adjustments

			<ul><strong>
			<li>Final_Amount
			</strong>
			</ul>

		</ol> \n\n ";




		# Make sure you build a seperate array of orders
		# Make sure you build a seperate array of orders

	print "<strong><u>orders Array</u></strong> <p>\n";

	print "You must always build a seperate @orders array from the parsed input.
		MOF processes product information in this array and format. <p>\n\n";

	foreach $_ (@orders) {print "<li>$_ \n";}



	print "<p>Happy Ordering<br> ";
	print "Merchant OrderForm v1.53 \© Copyright <a href=\"http://www.io.com/~rga/scripts/\">RGA</a> \n";
	
	print "</body></html> \n\n";



