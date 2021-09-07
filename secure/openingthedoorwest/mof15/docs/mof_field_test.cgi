#!/usr/local/bin/perl

	
	require 'mof15.conf';



	$font1 = '<font face="Arial, Verdana,Helvetica,Arial" size="1" color="#000000">';
	$font2 = '<font face="Arial, Verdana,Helvetica,Arial" size="2" color="#000000">';
	$font3 = '<font face="Arial, Verdana,Helvetica,Arial" size="3" color="#000000">';



	@TempSort = ();

	%RequiredFieldNames = ();
	@RequiredOrphans = ();

	%AdjustingFieldNames = ();
	@AdjustingOrphans = ();

	$primary_n;



			# SORT MAIN PRODUCT OPTIONS
			# SORT MAIN PRODUCT OPTIONS	


    		@TempSort = sort {uc($a) cmp uc($b)} (keys %product_fields);

		$primary_n = scalar(@TempSort);




			# FIND REQUIRED
			# FIND ORPHAN REQUIRED


		foreach (@field_validation) {

			$RequiredFieldNames{$_} = "Yes";		
	
			push (@RequiredOrphans, $_) unless (exists($product_fields{$_}));


		}


		


			# FIND ADJUSTING
			# FIND ORPHAN ADJUSTING


		foreach (@field_adjustments) {
		
			$AdjustingFieldNames{$_} = "Yes";		
	
			push (@AdjustingOrphans, $_) unless (exists($product_fields{$_}));


		}






		# PRINT
		# PRINT



	print "Content-Type: text/html\n\n";
	print "<html><head><title>Mof Test ..</title></head> ";
	print "<body bgcolor=#FFFFFF text=#000000>";

	print "<h3>These are your mof15.conf declared field names</h3>";

	print "$font2 ";
	print "This test script will show you how Mof sees your configurations for product input options. ";
	print "If you have a large site, you may find this chart handy.</font><p>";


	print "$font2 ";
	print "<li>Mof is configured to recognize $primary_n Field names as product option input ";
	print "<li>You can use any of these field names throughout your site or store front ";
	print "<li>You must use these exact names in your Forms, case sensitive ";
	print "<li>The description is used only by Mof in the cart product description section ";
	print "<li>You can use this chart to trouble shoot product options input, see notes below chart";
	print "<li>Note: These field names are product option input only and not main product input";
	print "<li>Note: Main product input is always <b>order</b> or <b>order<font color=red>N</font></b> ";

	print "</font>";

	print "<table border=0 cellpadding=2 cellspacing=4 width=100\%> \n";
	print "<tr bgcolor=#84B5CE><td>$font2 <strong>All declared Field Name(s) in use for product option input";
	print "</strong></font></td></tr></table>\n";

	print "<table border=0 cellpadding=2 cellspacing=2 width=100\%> \n";
	print "<tr bgcolor=#CCCCCC> ";
	
	print "<td align=center>$font2 <strong>#</strong></font></td> ";
	print "<td align=center>$font2 <strong>Exact Field Name</strong></font></td> ";
	print "<td align=center>$font2 <strong>Description (Mof use only)</strong></font></td> ";
	print "<td align=center>$font2 <strong>Required</strong></font></td> ";
	print "<td align=center>$font2 <strong>Price</strong></font></td> ";

	print "</tr>\n\n";


		$switch = 1;
		$count =1;
	
	foreach (@TempSort) {

	print "<tr bgcolor=#C9DCEE>" if ($switch);
	print "<tr bgcolor=#EEEEEE>" unless ($switch);

	print "<td align=center nowrap>$font2 $count</font></td> ";


	print "<td nowrap>$font2 <font color=#626262>name=\"</font><strong>$_</strong><font color=#626262>\" ";
	print "</font></font></td> ";


		if ($product_fields{$_}) {
		print "<td nowrap>$font2 $product_fields{$_}</font></td> ";
		} else {
		print "<td nowrap>$font2 <font color=red><b>Description Missing</b></strong></font></td> ";
		}


		if ($RequiredFieldNames{$_}) {
		print "<td align=center nowrap>$font2 $RequiredFieldNames{$_} </font></td> ";
		} else {
		print "<td align=center nowrap>$font2 <br> </font></td> ";
		}


		if ($AdjustingFieldNames{$_}) {
		print "<td align=center nowrap>$font2 $AdjustingFieldNames{$_} </font></td> ";
		} else {
		print "<td align=center nowrap>$font2 <br> </font></td> ";
		}



	print "</tr> \n";

		if ($switch) {
		$switch = 0;
	
		} else {
		$switch = 1;
	
		}

	$count++;

	}


	print "</table><p>";




		$showorphans += scalar(@RequiredOrphans);
		$showorphans += scalar(@AdjustingOrphans);

	if ($showorphans) {

		if (scalar(@RequiredOrphans)) {
		print "<strong>You have orphan field names in <font color=red>\@field_validation</font></strong> ";
		print "<ol> ";
		foreach (@RequiredOrphans) {print "<li>$_ "}
		print "</ol><p> ";
		}


		if (scalar(@AdjustingOrphans)) {
		print "<strong>You have orphan field names in <font color=red>\@field_adjustments</font></strong> ";
		print "<ol> ";
		foreach (@AdjustingOrphans) {print "<li>$_ "}
		print "</ol><p> ";
		}

	}




	print "<h3>If you are having trouble with product option input:</h3>";

	print qq~

	The documentation has directions on how to configure your <strong>mof15.conf</strong> 
      file to recognize any product options for products throughout your site product pages.<p>

	<ul>
	<li>Configurations1.html
	<ul>
	<li>Changing the cart's behavior
	<ul>
	<li>How to set up User Selected Input Options for your product(s) 
	<li>How to make User Select Input Options Price Adjusting Fields 
	</ul>	</ul>	</ul>


	<p>

	The short version: in <strong>mof15.conf </strong>:

	<ul>
	<li><strong>Declare all fields to be used </strong>
	<li>All fields you will be using must be declared in the <strong>\%product_fields</strong> array
	<li>This array must have the <b>FieldName</b> and <b>Description</b> for each field
	<br>Tip: you can use the same name for many products (color is color) whether Shirt Color or Car Color<p>
	
	<li><strong>List any fields that will be required </strong>
	<li>Any of the declared fields that will be required must be listed in <strong>\@field_validation</strong>

	<p><li><strong>List any fields that will be price adjusting </strong>
	<li>Any of the declared fields that will be price adjusting must be listed in <strong>\@field_adjustments</strong>

	</ul>



	Note: All fields you will be using for cart input must be declared in the 
	<strong>\%product_fields</strong> array; however, once declared, a field may either
	be <b>Required</b> or <b>Price Adjusting</b> or <b>both</b>.  Orphan fields don't 	
	cause a problem, they just won't be recognized as valid fields until you first declare
	the field name in the <strong>\%product_fields</strong> array.



	~;



	print "<p>Happy Ordering<br> ";
	print "Merchant OrderForm v1.53 \© Copyright <a href=\"http://www.io.com/~rga/scripts/\">RGA</a> \n";

	print "</body></html>";
	exit;

