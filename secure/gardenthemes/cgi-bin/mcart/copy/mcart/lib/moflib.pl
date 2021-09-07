# ==================== MOFcart v2.5.08.19.05 ====================== #
# === FRONT END LIBRARY ROUTINES ================================== #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# sub Routines for <mof.cgi> Cart Front End
# CHECK ALLOWED DOMAINS
sub CheckAllowedDomains {
	my ($domain_approved) = 0;
	my ($domain_referred) = $ENV{'HTTP_REFERER'};
	$domain_referred =~ tr/A-Z/a-z/;
  	foreach (@ALLOWED_DOMAINS) {if ($domain_referred =~ /$_/i) {$domain_approved++}}
	unless ($domain_approved) {
	$ErrMsg="<h4>POST is not from an Allowed Domain</h4>";
	$ErrMsg .= "You have enabled the ALLOWED_DOMAINS setting in MOF's Front End 
	Configuration file [mof.conf], however, the page that is attempting to POST
	to the cart is <b>not</b> listed in the Allowed Domains list.<p> Solution: Adjust the ALLOWED_DOMAINS
	setting to include all domains you will allow to POST to the cart.<p>";
	$ErrMsg .= "Documentation
	<a href=\"http://www.merchantorderform.com/Documentation/Configurations1.html\#AllowDomains\" target=\"_blank\">
	Configurations1.html</a>, How to allow only your domain to use the scripts.<p>";
	if ($ENV{'HTTP_REFERER'}) {
	$ErrMsg .= "Attempting POST from:<br><a href=\"$ENV{'HTTP_REFERER'}\"><b>$ENV{'HTTP_REFERER'}</b></a><p>";
	$ErrMsg .= "Your present ALLOWED_DOMAINS settings are:<br>";
	foreach (@ALLOWED_DOMAINS) {$ErrMsg .= "<a href=\"$_\"><li>$_</a>"}
	$ErrMsg .= "<p>";
	}
	$ErrMsg .= "<font color=red><b>CAUTION</b></font>: 
	We recommend that you <B>do not</b> disable the ALLOWED_DOMAINS feature. 
	You should be aware of the possible tampering with prices, etc. that can occur if you
	disable these safeguards. See the MOFcart 
	<a href=\"http://www.merchantorderform.com/support_pricefix.html\">support</a> notes 
	for more information on this security issue.<p>";
	unless ($ENV{'HTTP_REFERER'}) {
	$ErrMsg .= "<b>Note</b>: The only way you can make a direct call to this script is if you
	specify <b>?test</b> mode. Any other use of this script must have been submitted by
	an appropriate product page or dynamic page produced by this script, and not entered as a 
	direct url from your browser.  If you are getting this errror, and sure all settings are correct, 
	then you may have one of these problems:<p>
	<li>Your site's cgi environment has HTTP_REFERER disabled
	<li>Your site is behind a firewall (cgi environment HTTP_REFERER not available)
	<li>You have the <b>Edit Cart</b> button enabled on Back End with SSL";}
	&ErrorMessage($ErrMsg);
	}}

# QUERY STRING - PROCESS TO @NewOrder
sub ProcessQueryString {
	$view;
	$msg_i=0;
	@NewOrder=();
	my ($len);
	my ($qty, $item, $desc, $price, $ship, $taxit);
	$buffer = $ENV{'QUERY_STRING'};
  	@pairs = split(/&/, $buffer);
  	foreach $pair (@pairs) {
   	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
   	$qry{$name} = $value;
		if ($name eq "viewcart") {
		$len = length ($value);
		$view="SUBMITTED_VIEW $len" unless $len;
		}
   	push (@NewOrder, $value) if ($name eq "order");
	$msg_i++ if ($name eq "order");
	}

	unless ($view) {
	($qty, $item, $desc, $price, $ship, $taxit) = split(/$delimit/, $qry{'order'});
	$ErrMsg="<h4>Product Order Data Not Available</h4>";
	$ErrMsg .= "You are using the GET method, or Query String to submit a product to the cart;
	however, all of the necessary pieces are not present.<p>";
	$ErrMsg .= "Your product input looks like this:<br><b>$qry{'order'}</b><p>" if ($qry{'order'});
	$ErrMsg .= "Your product input should be in the format described in the Documentation 
	<a href=\"http://www.merchantorderform.com/Documentation/BuildingInputPages.html\#Mode1\" target=\"_blank\">
	BuildingInputPages.html</a> for the GET method.<p>
	../mof.cgi?order=Qty----Item----Description----Price----Ship----Tax<p>";
	if ($ENV{'HTTP_REFERER'}) {
	$ErrMsg .= "Check this input page for the problem:<br><a href=\"$ENV{'HTTP_REFERER'}\"> $ENV{'HTTP_REFERER'}</a><p>";}
	$ErrMsg .= "<font color=red><b>CAUTION</b></font>: 
	The GET method is not a secure way to submit products to MOFcart.  You should be aware
	of the possible tampering with prices, etc. that can occur using this method. See the 
	MOFcart <a href=\"http://www.merchantorderform.com/support_pricefix.html\">support</a> notes 
	for more information on this security issue.";

	&ErrorMessage($ErrMsg) unless ( int ($qty) > 0);
	&ErrorMessage($ErrMsg) unless ($item);
	&ErrorMessage($ErrMsg) unless ( $price > 0);

	$ErrMsg="<h4>GET method not allowed</h4>";
	$ErrMsg .= "You are using the GET method, or Query String to submit a product to the cart,
	yet you have enabled the POST_ONLY setting in the MOF Front End configurations [mof.conf].<p>";
	$ErrMsg .= "Solution: use one of the POST methods to submit your products to the cart.<p>";
	$ErrMsg .= "Applicable Documentation:<br>
	<a href=\"http://www.merchantorderform.com/Documentation/Configurations1.html\#AllowOnlyPost\" target=\"_blank\">
	Configurations1.html</a>, How to allow only post input <br>
	<a href=\"http://www.merchantorderform.com/Documentation/BuildingInputPages.html\#UnderstandingModes\" target=\"_blank\">
	BuildingInputPages.html</a>, Understanding MOF's input modes <p>";
	$ErrMsg .= "<font color=red><b>CAUTION</b></font>: 
	The GET method is not a secure way to submit products to MOFcart.  You should be aware
	of the possible tampering with prices, etc. that can occur using this method. See the 
	MOFcart <a href=\"http://www.merchantorderform.com/support_pricefix.html\">support</a> notes 
	for more information on this security issue.";
	&ErrorMessage($ErrMsg) if ($POST_ONLY);
	return @NewOrder;
	}}

# FORM INPUT - PROCESS TO @NewOrder
sub ProcessForm {
	# This process must return @NewOrder to <mof.cgi>
	# @NewOrder must be available to <mof.cgi> to direct other processes

	$msg_i=0;
	@NewOrder=();
	my ($msg_null);
	my ($fieldname);
	my ($id, $vid, $vname);
	my (@missingfields) = ();
	my ($pkey, $pval, $fkey, $fval, $key, $val);
	my ($line, $qty, $item, $desc, $price, $ship, $taxit);
	my ($adjprice, $adjdesc, $other, $leftother);
	my (%adjflds) = ();
	my (%adjpriceinput) = ();
	my (@sortdesc) = ();
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);
	foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/"/ /;
	$value =~ s/\r\n/[br]/g;
	$frm{$name} = $value;
    	}

	# UPDATING CART MODE
	if ($frm{'postmode'} eq "UPDATE") {
		my (@QtyList) = ();
		my ($num);

		# Build items submitted list
		foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ tr/"/ /;
			if ($name =~ /\bquantity_/) {
			$leftother = $value;
			$leftother =~ s/ //g;
			$leftother =~ s/[0-9.]//g;
			unless ($leftother) {
			push (@QtyList, substr ($name,9) ) if ($value > 0);
			}}
		}

		# Group associated input
		foreach $num (@QtyList) {
		$id = "quantity_" . $num;
			if ($allow_fractions) {
			$qty = $frm{$id};
			} else {
			$qty = int ($frm{$id});
			$qty = 1 if ($qty < 1);
			}

		$id = "product_" . $num;
		($item, $desc, $price, $ship, $taxit) = split(/$delimit/, $frm{$id});
			unless ($frm{$id}) {
			$ErrMsg="<h4>Product data not available</h4>";
			$ErrMsg .= "MOF cannot find product data for <b>$id</b>.
			You should never get this error unless you are
			reprogramming MOFcart and have made a mistake in the way that
			MOF matches Quantity with Product data.";
			&ErrorMessage($ErrMsg);
			}
		push (@NewOrder, "$qty$delimit$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit");
		$msg_i++;
		}

	# DELETING CART MODE
	} elsif ($frm{'postmode'} eq "DELETE") {
		@orders = ();
		@NewOrder = ();
		
	# PREVIEW CART MODE
	} elsif ($frm{'postmode'} eq "PREVIEW") {
		# CATCH Hidden POSTed ORDERs to NewOrder
		# That's all we need here
		# We probably want to use the actual cart contents
		# To prevent confusion if jumping to previous cached
		# version of cart, which would send cached POST to preview

  		foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ tr/"/ /;
		push (@NewOrder, $value) if ($name eq "order");
		$msg_i++ if ($name eq "order");
		}

	# PROCESSING SINGLEPOST MODE
	} elsif ($frm{'postmode'} eq "SINGLEPOST") {
		unless ($frm{'order'}) {
		$msg_null="Cannot Find Selected Order Information<br>";
		$msg_null=$msg_null . "Check To Make Sure an Item Was Selected";
		&ValidationMessage("$msg_null");
		}

		# set up any price adjustments
		foreach (@field_adjustments) {$adjflds{$_} = $frm{$_} if ($frm{$_})}

		# set up any price_input_adjustments present as extra fields
		foreach (@price_input_adjustments) {
		if (exists($frm{$_})) {
		$other = $frm{$_};
		$leftother = $other;
		$leftother =~ s/ //g;
		$leftother =~ s/[0-9.]//g;
		if ($leftother) {
		push (@missingfields, "Characters ( $leftother ) not allowed for $product_fields{$_}");
		} else {
		# populate the adj price input reference
		my ($len) = length($frm{$_});
		$frm{$_} = sprintf "%.2f", $frm{$_} if ($len);
		$adjpriceinput{$_} = $frm{$_};
		# validate that zeros are allowed
		my ($fname);
		foreach $fname (@field_validation) {
		if ($_ eq $fname) {
		unless ($allow_zeros) {
		push(@missingfields,"Cannot Have Zero Amount For $product_fields{$_}") unless ($frm{$_} > 0);
		}}}}}}

		# get the single order hidden input
		($item, $desc, $price, $ship, $taxit) = split(/$delimit/, $frm{'order'});

		# $price_input adjustment for primary price field
		if ($price_input) {
		if (exists($frm{$price_input})) {
		$other = $frm{$price_input};
		$leftother = $other;
		$leftother =~ s/ //g;
		$leftother =~ s/[0-9.]//g;
		if ($leftother) {
		push (@missingfields, "Characters ( $leftother ) not allowed for Input");
		} else {
		my ($len) = length($frm{$price_input});
		if ($len) {
		$frm{$price_input} = sprintf "%.2f", $frm{$price_input};
			if ($frm{$price_input} > 0 || $allow_zeros) {
			$price += $frm{$price_input};
			} else {
			push (@missingfields, "Cannot Have a Zero for Amount Input");
			}
		} else {
		push (@missingfields, "Amount Input is Missing");
		}}}}

		# validating user input required
   		while (($pkey, $pval) = each (%product_fields)) { 
   			while (($fkey, $fval) = each (%frm)) { 
				if ( $pkey eq $fkey ) {
					foreach $fieldname (@field_validation) {
						if ( $fieldname eq $pkey ) {
							unless ( $frm{$pkey} ) {
							$vname = $item . ": " . $pval;
							push (@missingfields, $vname);
							}
		}}}}}
		&ValidationMessage(@missingfields) if scalar(@missingfields);

		$leftother = $frm{'quantity'};
		$leftother =~ s/ //g;
		$leftother =~ s/[0-9.]//g;
		if ($leftother) { 
		$qty = 1; 
		} else {
			if ($allow_fractions) {
			$qty = $frm{'quantity'};
			} else {
			$qty = int ($frm{'quantity'});
			$qty = 1 if ($qty < 1);
		}}

		# combining user input - adjusting price
		if ($sortdescending) {@sortdesc = sort { lc($b) cmp lc($a) } (keys %product_fields)} 
		else {@sortdesc = sort { lc($a) cmp lc($b) } (keys %product_fields)}

		foreach (@sortdesc) {
		if  ( $frm{$_} ) {
		if ($adjflds{$_}) {
		($adjdesc, $adjprice) = split(/$delimit/, $adjflds{$_});
		$price += $adjprice;
			if ($adjprice) {
			$desc = $desc . "\|" . "$product_fields{$_}" . "::" . "$adjdesc $currency $adjprice";
			} else {
			$desc = $desc . "\|" . "$product_fields{$_}" . "::" . "$adjdesc";
			}
		} elsif ($adjpriceinput{$_}) {
			if ($adjpriceinput{$_} > 0 || $allow_zeros) {
			$price += $adjpriceinput{$_};
			$desc = $desc . "\|" . "$product_fields{$_}" . "::" . "$currency $adjpriceinput{$_}";
			}
		} else {
		$desc = $desc . "\|" . "$product_fields{$_}" . "::" . "$frm{$_}";
		}}}
		$price = sprintf "%.2f", $price;
		push (@NewOrder, "$qty$delimit$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit");
		$msg_i++;

	# PROCESSING CHECKBOXES MODE
	} elsif ($frm{'postmode'} eq "CHECKBOXES") {
		foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ tr/"/ /;

		if ($name eq "order") {
			unless ($value) {
			$msg_null="Cannot Find Selected Order Information<br>";
			$msg_null=$msg_null . "Check To Make Sure an Item Was Selected";
			&ValidationMessage("$msg_null");
			}
		push (@NewOrder, $value);
		$msg_i++;				
		}}

	# PROCESSING QUANTITYBOXES MODE
	} elsif ($frm{'postmode'} eq "QUANTITYBOXES") {
		my (@QtyList) = ();
		my ($num);

		# Build items submitted list
		foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$value =~ tr/"/ /;
		if ($name =~ /\bquantity/) {
		$leftother = $value;
		$leftother =~ s/ //g;
		$leftother =~ s/[0-9.]//g;
		if ($leftother) {
		push (@missingfields, "Characters ( $leftother ) Not Allowed As Input");
		} else {
		push (@QtyList, substr ($name,8)) if ($value > 0);
		}}}

		# set up any price adjustments
		foreach $num (@QtyList) {
		foreach (@field_adjustments) {
		$id = "$_" . $num;
		$adjflds{$id} = $frm{$id} if ($frm{$id});
		}}

		# set up any price_input_adjustments present as extra fields
		foreach $num (@QtyList) {
		foreach (@price_input_adjustments) {
		$id = "$_" . $num;
		if (exists($frm{$id})) {
		$other = $frm{$id};
		$leftother = $other;
		$leftother =~ s/ //g;
		$leftother =~ s/[0-9.]//g;
		if ($leftother) {
		push (@missingfields, "Characters ( $leftother ) not allowed for $product_fields{$_}");
		} else {
		# populate the adj price input reference
		my ($len) = length($frm{$id});
		$frm{$id} = sprintf "%.2f", $frm{$id} if ($len);
		$adjpriceinput{$id} = $frm{$id};
		# validate that zeros are allowed
		my ($fname);
		foreach $fname (@field_validation) {
		if ($_ eq $fname) {
		unless ($allow_zeros) {
		push(@missingfields,"Cannot Have Zero Amount For $product_fields{$_}") unless ($frm{$id} > 0);
		}}}}}}}

		# $price_input validation as primary price field
		if ($price_input) {
		foreach $num (@QtyList) {
		$id = "$price_input" . $num;
		if (exists($frm{$id})) {
		$other = $frm{$id};
		$leftother = $other;
		$leftother =~ s/ //g;
		$leftother =~ s/[0-9.]//g;
		if ($leftother) {
		push (@missingfields, "Characters ( $leftother ) not allowed for Input");
		} else {
		my ($len) = length($frm{$id});
		if ($len) {
		$frm{$id} = sprintf "%.2f", $frm{$id};
		push (@missingfields, "Cannot Have a Zero for Amount Input") unless ($frm{$id} > 0 || $allow_zeros);
		} else {
		push (@missingfields, "Amount Input is Missing");
		}}}}}

		# Validate user_input required
		foreach $num (@QtyList) {
		$id = "order" . $num;
   			while (($pkey, $pval) = each (%product_fields)) { 
			$vid = $pkey . $num;
   				while (($fkey, $fval) = each (%frm)) { 
					if ( $vid eq $fkey ) {
						foreach $fieldname (@field_validation) {
							if ( $fieldname eq $pkey ) {
			unless ( $frm{$vid} ) {
			($item, $desc, $price, $ship, $taxit) = split(/$delimit/, $frm{$id});
			$vname = $item . ": " . $pval;
			push (@missingfields, $vname);
			}
		}}}}}}
		&ValidationMessage(@missingfields) if scalar(@missingfields);

		# Group associated input
		if ($sortdescending) {
		@sortdesc = sort { lc($b) cmp lc($a) } (keys %product_fields);
		} else {
	 	@sortdesc = sort { lc($a) cmp lc($b) } (keys %product_fields);
		}

		foreach $num (@QtyList) {
		$id = "quantity" . $num;	
			if ($allow_fractions) {
			$qty = $frm{$id};
			} else {
			$qty = int ($frm{$id});
			$qty = 1 if ($qty < 1);
			}
		$id = "order" . $num;
		($item, $desc, $price, $ship, $taxit) = split(/$delimit/, $frm{$id});
			unless ($frm{$id}) {
			$msg_null="Cannot Find Selected Order Information<br>";
			$msg_null=$msg_null . "Check To Make Sure an Item Was Selected";
			&ValidationMessage("$msg_null");
			}
		$id = "$price_input" . $num;
		$price += $frm{$id} if (exists($frm{$id}));
		foreach $key (@sortdesc) {
		$id = $key . $num;
		if ($frm{$id}) {
		if ($adjflds{$id}) {
		($adjdesc, $adjprice) = split(/$delimit/, $adjflds{$id});
		$price += $adjprice;
			if ($adjprice) {
			$desc = $desc . "\|" . "$product_fields{$key}" . "::" . "$adjdesc $currency $adjprice";
			} else {
			$desc = $desc . "\|" . "$product_fields{$key}" . "::" . "$adjdesc";
			}
		} elsif ($adjpriceinput{$id}) {
			if ($adjpriceinput{$id} > 0 || $allow_zeros) {
			$price += $adjpriceinput{$id};
			$desc = $desc . "\|" . "$product_fields{$key}" . "::" . "$currency $adjpriceinput{$id}";
			}
		} else {
		$desc = $desc . "\|" . "$product_fields{$key}" . "::" . "$frm{$id}";
		}}}
		$price = sprintf "%.2f", $price;
		push (@NewOrder, "$qty$delimit$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit");
		$msg_i++;
		}

	# PROCESSING CUSTOM MODE
	} elsif ($frm{'postmode'} eq "CUSTOM") {
		# You Must Return @NewOrder with this process
		# @NewOrder must be in a 6 Field format
		# Then you can use <mof.cgi> to work any other processes needed
		# This section just needs to present <mof.cgi> with 6 Field @NewOrder

		$ErrMsg="<h4>You have specified CUSTOM postmode</h4>";
		$ErrMsg .= "The CUSTOM postmode is not available unless you program it.";
		&ErrorMessage($ErrMsg);	

	# MODE NOT RECOGNIZED
	} else {
	$ErrMsg="<h4>Unable to determine Input Mode</h4>";
	$ErrMsg .= "You have submitted a POST to the cart, but either not specified the
        input mode, or named the input mode incorrectly.<p>";
	$ErrMsg .= "Your Form input should contain a hidden field named <b>postmode</b> the 
	value should be one of the Modes outlined in 
	<a href=\"http://www.merchantorderform.com/Documentation/BuildingInputPages.html\#UnderstandingModes\" target=\"_blank\">
	BuildingInputPages.html</a>, <u>Understanding Mof's four input modes</u>.<p>";
	if ($ENV{'HTTP_REFERER'}) {
	$ErrMsg .= "Check this input page for the problem:<br><a href=\"$ENV{'HTTP_REFERER'}\"> $ENV{'HTTP_REFERER'}</a><p>";}
	$ErrMsg .= "<u>Other Troubleshooting Tips:</u><p>
	<li>The <b>postmode</b> name=value pair is case sensitive<p>
	<li>The FORM tags in the input page may not open, close, or surround the POST data correctly.
	Make sure that your Form is correct; that the postmode is inside the FORM opening and closing
	html tag, and that the FORM has *only* one Opening and Closing tag.<p>
	<li>If you have your FORMs embedded in complicated tables, then some browsers may not handle
	this correctly.  Even if all else is correct, some browsers have bugs in the way they
	handle FORMs embedded in tables. Simplify the tables.<p>";
	&ErrorMessage($ErrMsg);
	} 

	# Allow the AcceptOrders page if Update or Delete Cart is empty
	# Else trigger a No Items Selected validation message

	unless ($frm{'postmode'} eq "UPDATE" || $frm{'postmode'} eq "DELETE" || $frm{'postmode'} eq "PREVIEW" || $frm{'postmode'} eq "CUSTOM") {
	$msg_null="Cannot Find Item(s) Selected or Quantities<br>";
	$msg_null=$msg_null . "<ul><u>Suggestions</u>:";
	$msg_null=$msg_null . "<li>Make sure item was checked or selected";
	$msg_null=$msg_null . "<li>Make sure quantities were entered to select</ol>";
	&ValidationMessage("$msg_null") unless scalar(@NewOrder);
	}

	return @NewOrder;
	}
	# End Process Form


# SET DATE
sub SetDateVariable {
	my($sec,$min,$hour,$mday,$mon,$year,$wday);
	local (@months) = ('January','February','March','April','May','June','July',
			'August','September','October','November','December');
	local (@days) = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
	if ($gmtPlusMinus) {($sec,$min,$hour,$mday,$mon,$year,$wday) = (gmtime(time + $gmtPlusMinus))} 
	else {($sec,$min,$hour,$mday,$mon,$year,$wday) = (localtime(time))[0,1,2,3,4,5,6]}
	$year += 1900;	
 	$Date = "$days[$wday], $months[$mon] $mday, $year";
 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mon+1,'/',$mday,'/',$year);
 	$Time = sprintf("%02d%1s%02d%1s%02d",$hour,':',$min,':',$sec);
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour<12);
	$ShortTime="12:".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour==0);
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour==12);
	$ShortTime=($hour-12).":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour>12);
	# formatted date
	$MyDate = "";
	$MyDate = $Date if ($format_date==1);
	$MyDate = "$months[$mon] $mday, $year" if ($format_date==2);
	$MyDate = $ShortDate if ($format_date==3);
 	$MyDate = sprintf("%02d%1s%02d%1s%04d",$mday,'/',$mon+1,'/',$year) if ($format_date==4);
 	$MyDate = sprintf("%04d%1s%02d%1s%02d",$year,'/',$mon+1,'/',$mday) if ($format_date==5);
	# added eur format : August 04, 2003 8:18:50 PM
	if ($format_date==10) {
	 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mday,'.',$mon+1,'.',$year);	 
		$MyDate = $ShortDate;
		} elsif ($format_date==11) {
		# German
		@months = ('Januar','Februar','März','April','Mai','Juni','Juli','August',
			'September','November','Oktober','Dezember');
		@days = ('Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag');
	 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mday,'.',$mon+1,'.',$year);	 
		$Date = "$days[$wday], ";
 		$Date .= sprintf("%02d",$mday);
 		$Date .= ". $months[$mon] $year";
		$MyDate = $Date;
		} elsif ($format_date==12) {
		# German
		@months = ('Januar','Februar','März','April','Mai','Juni','Juli','August',
			'September','November','Oktober','Dezember');
		@days = ('Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag');
	 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mday,'.',$mon+1,'.',$year);	 
		$Date = "$days[$wday], den $mday. $months[$mon] $year";
		$MyDate = $Date;
		}
	# add time
	$MyDate .= " " . $ShortTime  if ($format_time==1);
	$MyDate .= " " . $Time  if ($format_time==2);
	 }

# MAKE GMT UNIX TIME
sub MakeUnixTime {
	local ($now) = time;
 	local ($expires) = @_;
 	$expires += $now;
 	local (@days) = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
 	local (@months) = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
 	local ($sec,$min,$hour,$mday,$mon,$year,$wday) = gmtime($expires); 
 	$sec = "0" . $sec if $sec < 10; 
 	$min = "0" . $min if $min < 10; 
 	$hour = "0" . $hour if $hour < 10; 
 	$year += 1900; 
  	$expires = "$days[$wday], $mday-$months[$mon]-$year $hour:$min:$sec GMT"; 
  	return $expires;
  	}

# CHECK FOR ARES COOKIE
sub CheckARESCookie {
	# Return the Affiliate's ARES ID
	# If one is found on the browser
	my ($cookiename) = @_;	
	my ($n, $v, $ARESID);
	$cookies = $ENV{'HTTP_COOKIE'};
	@cookie = split (/;/, $cookies);
    	foreach (@cookie) {
   	($n, $v) = split(/=/, $_);
	$ARESID = $v if ($n =~ /\b$cookiename\b/);
	}
  return ($ARESID);
  }

# CHECK FOR COOKIE
sub CheckCookie {
	# IDENTIFY MOF CART COOKIES
	# Positive Value is if $cookieOrderID has Value
	# Positive Value is if $cookieInfoID has Value
	$cookies = $ENV{'HTTP_COOKIE'};
	@cookie = split (/;/, $cookies);
    	foreach $line (@cookie) {
   	($name, $value) = split(/=/, $line);
	$cookieOrderID=$value if ($name =~ /\b$cookiename_OrderID\b/);
	$cookieInfoID=$value if ($name =~ /\b$cookiename_InfoID\b/);
	}
  return ($cookieOrderID, $cookieInfoID);
  }

# SET NEW COOKIE
sub MakeCookie {
	my ($name_for_cookie, $ID) = @_;
	# Always print the cookie before the Content-Type header
	if ($holdtime_data && $name_for_cookie eq $cookiename_OrderID) {
	# keep cookie specified hours
	$expirestime = &MakeUnixTime($holdtime_data * 3600);
	# alt cookie assumes default path=/
	# print "Set-Cookie: $name_for_cookie=$ID;expires=$expirestime\n";
	print "Set-Cookie: $name_for_cookie=$ID;path=/;expires=$expirestime\n";	
	} elsif ($holdtime_info && $name_for_cookie eq $cookiename_InfoID) {
	# keep cookie specified hours
	$expirestime = &MakeUnixTime($holdtime_info * 3600);
	print "Set-Cookie: $name_for_cookie=$ID;path=/;expires=$expirestime\n";	
	} else {
	# expire cookie when browser closed
	# alt cookie assumes default path=/
	# print "Set-Cookie: $name_for_cookie=$ID\n";
	print "Set-Cookie: $name_for_cookie=$ID;path=/\n";
	}
  }

# MAKE ORDER ID NUMBER
sub GenerateOrderID {
	# generates OrderID based on date, time, process number
    	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time());
	$OrderID = sprintf("%02d%02d%02d%02d%02d%02d%05d",$year+=1900,$mon+1,$mday,$hour,$min,$sec,$$);
  return $OrderID;
  }

# MAKE INFO ID NUMBER
sub GenerateInfoID {
	# generates InfoID based on date, time, process number
    	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time());
	$InfoID = sprintf("%02d%02d%02d%02d%02d%02d%05d",$year+=1900,$mon+1,$mday,$hour,$min,$sec,$$);
  return $InfoID;
  }

# READ DATA FILE
sub ReadDataFile {
	# The only time you'll be reading a data file is if cookieOrderID exists
	# Meaning there's an existing cookie for OrderID - Data file
	# Reading in the file chops the last line chr(10) in the file
	# It is the only chop in the routines
	# All other routines work with plain arrays with no chop
	@orders=();
	my($FileNumber) = @_;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;
	$path = $datadirectory . $FileNumber . "\.$data_extension";
		if (open (FILE, "$path") ) { 
		@orders = <FILE>;
		close(FILE);
		chop (@orders);
		return @orders;
		} else {
		unless (open (FILE, ">$path") ) { 
		$ErrMsg="<h4>Unable to read or create datafile: $FileNumber\.$data_extension</h4>";
		$ErrMsg .= "MOFcart is trying to access temporary files in the <b>orderdata</b> directory,
		but something is preventing file access. Here are typical causes of this problem, listed in
		order of probability:<p>
		<b>1.</b> Incorrect absolute pathway listed in [mof.conf] for orderdata DIR<br>
		This is your current <b>\$datadirectory</b> setting:<br><b>$datadirectory</b><br>
		This is your site's absolute ROOT path:<br><b>$ENV{DOCUMENT_ROOT}</b><p>
		Check with your server admin, or hosting help pages to insure that you have the
		absolute path leading to the <b>orderdata</b> DIR listed correctly. For unix-linux
		make sure all the forward slashes are present, including the beginning and ending <b>/</b>. For NT make
		sure all the backward slashes are present, including beginning drive letter. This path
		is case sensitive. It is <b>not</b> a url, and will never look like: <b>http://anything</b><p>
		<b>2.</b> The <b>orderdata</b> DIR does not have full read/write permissions. On 
		unix-linux you will probably need full 777 permissions. If you are on NT, you may 
		need to contact your server admin, or consult server help pages, on how to give the 
		orderdata DIR full write privilages.<p>
		<b>3.</b> You may have placed the <b>orderdata</b> DIR outside range of the public web areas,
		as we suggest in the installion instructions, but your server may not allow cgi scripts to 
		write files outside your public web area. Usually, if this is the case, you would not have
		been allowed to create the <b>orderdata</b> DIR in the first place.<p>";
		$ErrMsg .= "Applicable documentation:<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\#FindAbsolutePath\" target=\"_blank\">
		Installation.html</a>, What is the absolute path to your site?<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\#MakeDirectories\" target=\"_blank\">
		Installation.html</a>, Make directories on your server";
		&ErrorMessage($ErrMsg);
		}
		close(FILE);
		}
	}

# PROCESS DATA FILE
sub ProcessDataFile {
	# added Volume Price adjustments : 12-17-04
	# so this routine now restricts finding Dupes by Item , Desc, Ship, Tax only
	# Volume pricing may have adjusted price on last save
	# so we cannot use price to match on for Dupes
	# processes global @orders for dupes
	# retotals if dupes found
	# otherwise adds new item(s) to @orders
	$msg_i=0;
	$msg_d=0;
	my ($i);
	my ($match,$New,$Old);
	my ($NewStr,$OldStr,$NewQty);
	my ($n1,$n2,$n3,$n4,$n5,$n6);
	my ($o1,$o2,$o3,$o4,$o5,$o6);
    	foreach $New (@NewOrder) {
   	($n1,$n2,$n3,$n4,$n5,$n6) = split(/$delimit/,$New);
	$NewStr = $n2 . $n3 . $n5 . $n6;
		$i = 0;
		foreach $Old (@orders) {
   		($o1,$o2,$o3,$o4,$o5,$o6) = split(/$delimit/,$Old);
		$OldStr = $o2 . $o3 . $o5 . $o6;
			if ($NewStr eq $OldStr) {
			$match++;
			if ($item_no_increment) {
				$NewQty = $o1;
				} else {
				$msg_d++;
				$NewQty = ($n1 + $o1);
				}
			# now uses n4 (new price)
			$orders[$i] = "$NewQty$delimit$o2$delimit$o3$delimit$n4$delimit$o5$delimit$o6";
			}
			$i++;	
		}
		$i = 0;
 		push (@orders, "$New") unless ($match);
		$msg_i++ unless ($match);
		$match = 0;
	}
	return @orders;
  	}

# PROCESS VOLUME PRICE ADJUSTMENTS
sub ProcessVolumePricing {
	# added Volume Price adjustments : 12-17-04
	# examines @orders and makes Volume Price adjustments
	# returns @orders with any adjustments in pricing
	# or returns @orders unchanged if no adjustments needed
	my $f = 0;
	my ($n,$r,$k,$v);
	my %status = ();
	my %prices = ();
	my %group1 = ();
	my %group2 = ();
	my @table = ();
	my ($q,$i,$d,$p,$s,$t);

	# get file
	unless (open (MPL, "$mofPriceList") ) { 
		$ErrMsg="<h4>Unable to read file: $mofPriceList</h4>";
		&ErrorMessage($ErrMsg);
		}

		# load data
		my(@pricedata) = <MPL>;
		close(MPL);
		chop (@pricedata);

		# get identifiers
		my($mpl) = shift(@pricedata);

		# put identiriers in array
		my(@mrange) = split(/\t/,$mpl);
		shift (@mrange);

		# find m (range indicator)
		my($m) = 0;	
		foreach (@mrange) {
			last if ($_ eq '+');
			$m++;
			}

		# make reference lists
		foreach (@pricedata) {
		@table = split(/\t/,$_);
			$k = shift(@table);
			$v = splice(@table,($m+1));
			$status{$k} = $v;
			$prices{$k} = join("\t",@table);
			}

		# make group lists
		foreach (@orders) {
		($q,$i,$d,$p,$s,$t) = split(/$delimit/,$_);
		# remove pseudo html
		$n = $i;
		$n =~ s/\[/</g;
		$n =~ s/\]/>/g;
   		$n =~ s/<([^>]|\n)*>//g;
			# if exists in %status
			if (exists($status{$n})) {
			$group1{$n} += $q unless ($status{$n});
			$group2{$status{$n}} += $q if ($status{$n} > 0);		
			}
		}

		# examine @orders
		my $row=0;
		foreach $o (@orders) {
		($q,$i,$d,$p,$s,$t) = split(/$delimit/,$o);
		# save specific item quantity to reassemble string after qualifying quantities adjustments
		$qq = $q;
		# remove pseudo html
		$n = $i;
		$n =~ s/\[/</g;
		$n =~ s/\]/>/g;
   		$n =~ s/<([^>]|\n)*>//g;

			foreach $pd (@pricedata) {
			@table = split(/\t/,$pd);
			my $pt = shift(@table);

				# if you need match flexibility, remove white space
				# and set up regex non case sensitive, instead of exact match
				if ($pt eq $n) {
					$f = 0;
					$price= 0;

					# if item in %group1 use consolidated quantity
					$q = $group1{$n} if (exists($group1{$n}));

					# if yes, use the Total listed in group2 for that Group Num
					$q = $group2{$table[$m+1]} if (exists($group2{$table[$m+1]}));

					# what is price for qualifying quantity ?
					# quantity lies beyond last increment
					if ($q >= $mrange[($m-1)]) {
					$price = $table[$m]
					
					# quantity lies somewhere between 1 - last increment
					} else {
					while ($f < ($m)) {

						if ($q < $mrange[$f]) {
						$price = $table[$f];
						last;
						}
					$f++;
					}
					}
				# adjust price for all items in the Volume Price Table
				$orders[$row] = "$qq$delimit$i$delimit$d$delimit$price$delimit$s$delimit$t";
				}
			}
		$row++;
		}

	# rga : 08/18/05 12:15:31
	# @orders now has $price field set to Volume Pricing table

	# UNABLE to Recomupte @orders now looking for Price Adjusting input 	
	# in the same way that (moflib.pl) ProcessForm does with SINGLEPOST, QUANTITYBOXES
	# because the original (FieldName----0.00) Price Adjusting form is not preserved
	# past the original POST .. ProcessForm computes Price Adjustments and then stores
	# the Friendly Labels (not the root VAR names), also does not store the Price Adjust "----" delimiter

	# So, nothing as reliable as the original POST Price Adjusting can be done
	# what you can do is a sort of work around where you extract the numeric value from string $currency XX.xx
	# but for that to work you cannot list the very first original product DESC with a $currency XX.xx value
	
	# or you must use consistent RULEs to ensure reliability with the workaround.
	# * Always use a ROOT DESCRIPTION, and DO NOT include the Price Display for it
	# * If you omit the ROOT DESCRIPTION, then the second intended field will process as the ROOT DESC

	# Loop thru @orders now (as is since Volume Price was just done)
		# preserve the volume price p/item

	# Break out the DESC field into their Extra Optional Fields
	# You cannot match to the exact Price Adjust Field Names, but you can
	# extract the pattern for $ 00.00, and SUM all of those
	# then adjust the final stored price to that SUM (includes the initial Volume Price)	

	# sum from volume pricing + optional prices listed
	if ($sum_volume_optional) {
	my $amt;
	my $sum;
	my @list = ();
	my ($li,$lk,$lv) ;
	my ($q,$i,$d,$p,$s,$t);
	my $row=0;
	foreach (@orders) {
	($q,$i,$d,$p,$s,$t) = split(/$delimit/);
	$sum = $p;
	$n = $d;
	$n =~ s/\[/</g;
	$n =~ s/\]/>/g;
	$n =~ s/<([^>]|\n)*>//g;

	@list = split (/\|/,$n);
	$n = shift (@list);

		foreach $li (@list) {
		($lk,$lv) = split (/::/,$li);
		# extract the $ XX.xx += $sum
			if ($lv =~ /(\$.+)/g) {
				$amt = $1;
				$amt =~ s/\$//g;
				$amt =~ s/ //g;
				$sum += $amt;
				}
			}

     	$sum = sprintf "%.2f",$sum;
	$orders[$row] = "$q$delimit$i$delimit$d$delimit$sum$delimit$s$delimit$t";
	$row++;
	}
	}
	# end sum adjustments

	return @orders;
	}

# WRITE DATA FILE
sub WriteDataFile {

	# sort @orders
	my(%sortTemp) = ();
	foreach (@orders) {
	# Monday, March 04, 2002.  02:29:02 AM  Central Standard Time
	}

	# Writing out the data file adds chr(10) to each line
	# Also adds chr(10) to last line
	# Only the Write puts this, and only the Read chops it
	# All arrays work free of that last line chr(10)
	my ($FileNumber) = @_;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;
	my ($line);
	$path = $datadirectory . $FileNumber . "\.$data_extension";
	unless (open (FILE, ">$path") ) { 
		$ErrMsg="<h4>Unable to write to or create datafile: $FileNumber\.$data_extension</h4>";
		$ErrMsg .= "MOFcart is trying to access temporary files in the <b>orderdata</b> directory,
		but something is preventing file access. Here are typical causes of this problem, listed in
		order of probability:<p>
		<b>1.</b> Incorrect absolute pathway listed in [mof.conf] for orderdata DIR<br>
		This is your current <b>\$datadirectory</b> setting:<br><b>$datadirectory</b><br>
		This is your site's absolute ROOT path:<br><b>$ENV{DOCUMENT_ROOT}</b><p>
		Check with your server admin, or hosting help pages to insure that you have the
		absolute path leading to the <b>orderdata</b> DIR listed correctly. For unix-linux
		make sure all the forward slashes are present, including the beginning and ending <b>/</b>. For NT make
		sure all the backward slashes are present, including beginning drive letter. This path
		is case sensitive. It is <b>not</b> a url, and will never look like: <b>http://anything</b><p>
		<b>2.</b> The <b>orderdata</b> DIR does not have full read/write permissions. On 
		unix-linux you will probably need full 777 permissions. If you are on NT, you may 
		need to contact your server admin, or consult server help pages, on how to give the 
		orderdata DIR full write privilages.<p>
		<b>3.</b> You may have placed the <b>orderdata</b> DIR outside range of the public web areas,
		as we suggest in the installion instructions, but your server may not allow cgi scripts to 
		write files outside your public web area. Usually, if this is the case, you would not have
		been allowed to create the <b>orderdata</b> DIR in the first place.<p>";
		$ErrMsg .= "Applicable documentation:<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\#FindAbsolutePath\" target=\"_blank\">
		Installation.html</a>, What is the absolute path to your site?<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\#MakeDirectories\" target=\"_blank\">
		Installation.html</a>, Make directories on your server";
		&ErrorMessage($ErrMsg);
		}
		foreach $line (@orders) {
		print FILE "$line\n";
		}
	close(FILE);
	chmod (0777, $path) if ($set_ssl_chmod);
	}


# PREVIEW LIBRARIES
# PREVIEW LIBRARIES

# MAKE LIST OF FIELDS NEEDED
sub CheckFieldsNeeded {
	my ($allow_ship) = 0;
	$allow_ship++ if (scalar(@use_shipping));
	$allow_ship++ if (scalar(keys(%use_method)));
	# This is a simple config check to see if anything is being used
	# processes after the Preview branching will CheckUsingInfoFields
	# handling / discount / global_tax / default shipping do not require input
	# They are computed from config settings
	# Anything requiring user input must be declared in this list 
	# Even if it will not be validated
	# MOF uses this list to know what should be expected from the config settings

	# Any of the 15 shipping fields being used ?
	# Three of these are used for tax matching
	while (($key, $val) = each (%shipping_destination_fields)) {
	push (@UsingInfoFields, $key) if ($val);	
	}

	# Is Insurance being used ?
	if ($allow_ship) {
	push (@UsingInfoFields, "Compute_Insurance") if scalar(keys(%use_insurance));
	}

	# Is the Coupon Discount being used ?
	unless ($use_ARES) {
	push (@UsingInfoFields, "Compute_Coupons") if scalar(@use_coupons);
	}

	# Is Tax Exempt input enabled ?
	push (@UsingInfoFields, "Tax_Exempt_Status") if ($tax_exempt_status);

	# Are user selected shipping methods being used ?
	push (@UsingInfoFields, "Compute_Shipping_Method") if (scalar(keys(%use_method)));

	# FOR NEW FIELD(S) ---------------------------->
	# Push required new Field(s) to @UsingInfoFields

	return @UsingInfoFields;
	}

# MAKE NULL LIST FOR %NewInfo
sub MakeNullList {
	# Makes a global %NewInfo list with all possible Flags, Fields
	# This matches the MasterInfoList
	&GetMasterInfoList;
	foreach $_ (@MasterInfoList) {$NewInfo{$_} = ""}
	return %NewInfo;
	}

# MAKE MASTER LIST 
sub GetMasterInfoList {
	# Provides the MasterInfoList for All Functions
	# %NewInfo will always be a complete list
	# regardless of what fields, flags are used @UsingInfoFields
	# Therefore WriteInfoFile, ReadNewInfo, MakeNullList will always be 
	# a complete listing of all available Fields and Flags
	# If you add a new user input feature on Preview declare it's var here

	@MasterInfoList = (
	Ecom_ShipTo_Postal_Name_Suffix,
	Ecom_ShipTo_Telecom_Phone_Number,
	Ecom_ShipTo_Postal_StateProv,
	Ecom_ShipTo_Postal_Region,
	Ecom_ShipTo_Postal_Name_First,
	Ecom_ShipTo_Postal_City,
	Ecom_ShipTo_Online_Email,
	Ecom_ShipTo_Postal_PostalCode,
	Ecom_ShipTo_Postal_Name_Prefix,
	Ecom_ShipTo_Postal_CountryCode,
	Ecom_ShipTo_Postal_Name_Middle,
	Ecom_ShipTo_Postal_Street_Line1,
	Ecom_ShipTo_Postal_Street_Line2,
	Ecom_ShipTo_Postal_Company,
	Ecom_ShipTo_Postal_Name_Last,
	Ecom_ShipTo_Postal_Type,
	Compute_Shipping_Method,
	Compute_Insurance,
	Compute_Coupons,
	Tax_Exempt_Status
	);

} 
# End GetMasterList

# READ NEW INFO FROM PREVIEW INFORMATION PAGE POST
sub ReadNewInfo {
	&GetMasterInfoList;
	foreach $_ (@MasterInfoList) {
	$NewInfo{$_} = $frm{$_};
	}
	return %NewInfo;
	}

# WRITE PREVIEW INFO FILE
sub WriteInfoFile {
	# Only a Submit from the Preview Information Page can Write a file
	# Writing out the data file adds chr(10) to each line
	# Also adds chr(10) to last line
	# Only the Write puts this, and only the Read chops it
	# All arrays work free of that last line chr(10)
	my ($FileNumber) = @_;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;
	my ($line, $key, $val);
	$path = $infodirectory . $FileNumber . "\.$info_extension";
	unless (open (FILE, ">$path") ) { 
		$ErrMsg="<h4>Unable to write to or create datafile: $FileNumber\.$info_extension</h4>";
		$ErrMsg .= "MOFcart is trying to access temporary files in the <b>orderinfo</b> directory,
		but something is preventing file access. Here are typical causes of this problem, listed in
		order of probability:<p>
		<b>1.</b> Incorrect absolute pathway listed in [mof.conf] for orderinfo DIR<br>
		This is your current <b>\$infodirectory</b> setting:<br><b>$infodirectory</b><br>
		This is your site's absolute ROOT path:<br><b>$ENV{DOCUMENT_ROOT}</b><p>
		Check with your server admin, or hosting help pages to insure that you have the
		absolute path leading to the <b>orderinfo</b> DIR listed correctly. For unix-linux
		make sure all the forward slashes are present, including the beginning and ending <b>/</b>. For NT make
		sure all the backward slashes are present, including beginning drive letter. This path
		is case sensitive. It is <b>not</b> a url, and will never look like: <b>http://anything</b><p>
		<b>2.</b> The <b>orderinfo</b> DIR does not have full read/write permissions. On 
		unix-linux you will probably need full 777 permissions. If you are on NT, you may 
		need to contact your server admin, or consult server help pages, on how to give the 
		orderinfo DIR full write privilages.<p>
		<b>3.</b> You may have placed the <b>orderinfo</b> DIR outside range of the public web areas,
		as we suggest in the installion instructions, but your server may not allow cgi scripts to 
		write files outside your public web area. Usually, if this is the case, you would not have
		been allowed to create the <b>orderinfo</b> DIR in the first place.<p>";
		$ErrMsg .= "Applicable documentation:<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\#FindAbsolutePath\" target=\"_blank\">
		Installation.html</a>, What is the absolute path to your site?<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\#MakeDirectories\" target=\"_blank\">
		Installation.html</a>, Make directories on your server";
		&ErrorMessage($ErrMsg);
		}
		while (($key, $val) = each (%NewInfo)) {
		print FILE "$key\|$val\n";
		}
	close(FILE);
	}

# READ PREVIEW INFO FILE
sub ReadInfoFile {
	# Reading in the file chops the last line chr(10) in the file
	# It is the only chop in the routines
	# All other routines work with plain arrays with no chop
	%NewInfo=();
	my (@TempList) = ();
	my ($key, $val);
	my($FileNumber) = @_;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;
	$path = $infodirectory . $FileNumber . "\.$info_extension";
		if (open (FILE, "$path") ) { 
		@TempList = <FILE>;
		close(FILE);
		chop (@TempList);
  			foreach $_ (@TempList) {
   			($key, $val) = split(/\|/, $_);
			$NewInfo{$key} = $val; 
			}	
		} else {
		&MakeNullList;
		}
	}

# CHECK WHAT FIELDS ARE COMPLETE	
sub CheckUsingInfoFields {
	# This checks what info we actually have against what info is expected/needed
	# The list of what is expected is already created 

	# Checking required input	
	foreach (@UsingInfoFields) {

		# What shipping fields required ?
		if ($shipping_destination_fields{$_}) {
		unless (length($NewInfo{$_}) >= ($shipping_destination_fields{$_})) {
		$MissingInfoFields{$_} = "Missing" if (length($NewInfo{$_})==0);
		$MissingInfoFields{$_} = "Incomplete" if (length($NewInfo{$_})>0);
		}}

		# extra phone validation
		if ($_ eq "Ecom_ShipTo_Telecom_Phone_Number") {
			if ($NewInfo{$_}) {
			my ($chrs) = $frm{$_};
			$chrs =~ s/[ ()0-9.-]//g;
			$MissingInfoFields{$_} = "Incomplete" if ($chrs);
			}
		}

		# Is Coupon Input required ?
		if ($_ eq "Compute_Coupons") {
		unless (length($NewInfo{'Compute_Coupons'}) > 0 ) {
		$MissingInfoFields{'Compute_Coupons'} = "Incomplete";	
		}}

		# Tax Exempt validation ?
		if ($_ eq "Tax_Exempt_Status") {
		if (length($NewInfo{'Tax_Exempt_Status'}) > 0 ) {
		# You can code this pattern for ID or VAT string validation
			# This refuses any non alphanumeric or _- character or space
			$tes = $NewInfo{'Tax_Exempt_Status'};
			$tes =~ s/[A-Za-z0-9_-\s]//g;
		$MissingInfoFields{'Tax_Exempt_Status'} = "Incomplete" if ($tes);	
		}}

		# Is Insurance Input required ?
		if ($_ eq "Compute_Insurance") {
		unless (length($NewInfo{'Compute_Insurance'}) > 0 ) {
		$MissingInfoFields{'Compute_Insurance'} = "Incomplete";	
		}}

		# Are you using User Selected Shipping Method ?
		if ($_ eq "Compute_Shipping_Method") {
		unless (length($NewInfo{'Compute_Shipping_Method'}) > 0 ) {
		$MissingInfoFields{'Compute_Shipping_Method'} = "Incomplete";	
		}}

	} 
	# End foreach in @UsingInfoFields list

	# Adjust validation for UPS API
	# if UPS Country or Postal Code changed send flag
	# fields UPS..Country/Postal work for both UPS & USPS

	if ($frm{'UPS_Ecom_ShipTo_Postal_CountryCode'}) {
	unless ($frm{'Ecom_ShipTo_Postal_CountryCode'} eq $frm{'UPS_Ecom_ShipTo_Postal_CountryCode'}) {
      	$MissingInfoFields{'UPS_API_Country'} = "Changed";}	
	}

	if ($frm{'UPS_Ecom_ShipTo_Postal_PostalCode'}) {
	unless ($frm{'Ecom_ShipTo_Postal_PostalCode'} eq $frm{'UPS_Ecom_ShipTo_Postal_PostalCode'}) {
      	$MissingInfoFields{'UPS_API_Postal'} = "Changed";}	
	}

	# Adjust validation if Region being used
	if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'}) {
	if (exists($shipping_destination_fields{'Ecom_ShipTo_Postal_Region'})) {
	foreach (@force_state_select) {$UseStateProv++ if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'} eq $_)}
		if ($UseStateProv) {
		delete($MissingInfoFields{'Ecom_ShipTo_Postal_Region'});
		} else {
		delete($MissingInfoFields{'Ecom_ShipTo_Postal_StateProv'});
		$NewInfo{'Ecom_ShipTo_Postal_StateProv'} = "";	
		}
	}}

	# validate any Email addr whether required or not
	# to prevent sendmail from crashing script w/ bogus addr
	if ($NewInfo{'Ecom_ShipTo_Online_Email'}) {
	unless ($NewInfo{'Ecom_ShipTo_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w{1,}$/) {
      	$MissingInfoFields{'Ecom_ShipTo_Online_Email'} = "Incomplete";}	
	}

	return %MissingInfoFields;
	}

# VALIDATE PREVIEW INFO FIELDS
sub ValidatePreviewFields {
	my ($v) = @_;
	my ($mv);
	if ($MissingInfoFields{$v} eq "Missing") {
		if ($frm{'submit_preview_info'}) {
		$mv = $preview_missing;
		} else {
		$mv = $preview_required;
		}
	} elsif ($MissingInfoFields{$v} eq "Incomplete") {
	$mv = $preview_incomplete;
	} else {
		if ($shipping_destination_fields{$v}) {
		$mv = $preview_okay;
		} else {
		$mv = "<br>";
		}
	}
	return $mv;
	}

# POPULATE DROP BOX LIST
sub GetDropBoxList {
	# Processes a list file and returns <option> list to @array asking for the list
	# Only makes the <option> items between <select></select>
	# Preserves any default "selected" in file list
	# But re-assigns "selected" %NewInfo FieldName if stored data found in the list file
	# Capable of returning to default "selected" if data present but no match found in list file
	# The list ends up in the @array asking for it Passes: (filename, fieldname_with_possible_data)
	# IMPORTANT: Function requires list to have "value=some-name>" format as pattern
 	# IMPORTANT: Any "selected" must preceed this pattern.  The pattern must end with >
	my ($FilePath, $FieldName) = @_;
	my (@TempList) = ();
	my ($selected, $line, $match);
	my ($itm, $match_lock) = (0,0);
	unless (open (FILE, "$FilePath") ) { 
		$ErrMsg="<h4>Unable to read dropbox list: $FilePath</h4>";
		$ErrMsg .= "MOFcart is trying to read a support file that supplies the list for a
		dropbox on the Shipping Information page, but the file cannot be found as you have
		it defined in the [mof.conf] settings.<p>";
		$ErrMsg .= "MOFcart is looking for this file: <b>$FilePath</b>.<p>
		Make sure the needed file is in the same directory as the main scripts, 
		and make sure the [mof.conf] setting for <b>";
		if ($FieldName eq "Ecom_ShipTo_Postal_CountryCode") {$ErrMsg .= "\$use_country_list"}
		elsif ($FieldName eq "Ecom_ShipTo_Postal_StateProv") {$ErrMsg .= "\$use_state_list"}
		$ErrMsg .= "</b> defines <b>only</b> the file name. You do not need the full path. 
		It is not a url. If you are listing the full absolute path to the file, then make
		sure your absolute path is correct.<p>";
		$ErrMsg .= "Applicable documentation:<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Configurations1.html\#ShipInfoDropBoxes\" target=\"_blank\">
		Configurations1.html</a>, How to change the Drop Boxes<br>";
		&ErrorMessage($ErrMsg);
		}
		@TempList = <FILE>;
		close(FILE);
		chop (@TempList);
		if ($NewInfo{$FieldName}) {
		$match = "value=" . $NewInfo{$FieldName} . ">";
			# rga : 02/07/05 12:04:33
			# need to match the (parentheses) in usps_country.txt List
			$match =~ s/\(/\\\(/g;
			$match =~ s/\)/\\\)/g;
  			foreach (@TempList) {
				# if list has "selected" flag as default
				if ( $_ =~ /\bselected\b/i ) {
				($selected, $line) = ($_, $itm);
				$TempList[$itm] =~ ( s/\bselected\b//i );
				$TempList[$itm] =~ ( s/  / / );
				}
				if ($_ =~ /$match/i) {
				$match_lock++;
				$match_replace = $match;
				$match_replace =~ s/\\//g;
				$TempList[$itm] =~ ( s/$match/selected $match_replace/i );
				}
			$itm++;
			} 
			# return to default if there's a default
			if ($selected) {
				unless ($match_lock) {
				$TempList[$line] = $selected;
				}
			}
		} 
	return @TempList;
	}

# END PREVIEW LIBRARIES
# END PREVIEW LIBAARIES

# GET TEMPLATE FILE
sub GetTemplateFile {
	my ($FilePath, $Type, $Setting) = @_;
	my (@template) = ();
	my ($line, $switch) = ("",0);

	# javascript manipulation for Pop Up Alt Params
	# Friday, March 01, 2002.  10:47:12 PM  Central Standard Time
	# ALL successful add to cart POSTs use mofviewcart-pop.html FIRST
	# unless POP_TARGET="POPUP" and REDIRECT_URL present
	# then the ReDirect prints in the Pop Up window
	# at minimum, to load the JavaScript AutoClose / ReDirect to ALT window
	# if you set POP_AUTOCLOSE = 0, then it almost looks like a TARGET change
	# but it's actually a JavaScript open.window (REDIRECT_URL), close.window POPUP
	
    # POP_TARGET
    # REDIRECT_URL
	# POP_AUTOCLOSE
	# POP_VIEWCART

	my ($alt_params);
	if ($frm{'POP_AUTOCLOSE'} ne "") {

		# set up JavaScript startCountdown
		# must declare g_iCount to do checkUnload

		$alt_params .= "
		<SCRIPT LANGUAGE=\"JavaScript\">
		<!-- begin
		var g_iCount;
		var g_iCount = $frm{'POP_AUTOCLOSE'};

		function startCountdown(){
		if((g_iCount - 1) >= 0){
		g_iCount = g_iCount - 1;
		iText.innerText = 'Closing window in ' + g_iCount + ' seconds';
		setTimeout('startCountdown()',1000);
		} else {
		var win = '';
		";

			if ($frm{'REDIRECT_URL'}) {

			# Re direct via JavaScript to any Alternate window
			# if REDIRECT_URL present AND POP_TARGET="POPUP"
			# then <mof.cgi> will print location, don't need JavaScript to

			# close POPUP if redirecting away from POPUP
			# if redirecting TO POPUP then don't Close
			# you redirected there after the Auto Timer counted down

				unless ($frm{'POP_TARGET'} eq "POPUP") {

				$alt_params .= "
				win=window.open('$frm{'REDIRECT_URL'}', '$frm{'POP_TARGET'}')
				win.focus();
				window.close();	
				";

				}

			# redirect NULL, print default msg to Pop Up with AutoClose
			# you cannot print the default message to alternate window
			} else {
			$alt_params .= "window.close();";	

			}

		$alt_params .= "	
		}
		}
		";

		# AutoClose param sent, startCountdown on Pop Up onload	
		$alt_params .= "
		onload=startCountdown;
		focus();
		//  End -->
		</script>
		";

	# no Countdown, but use REDIRECT_URL, POP_TARGET
	# must declare g_iCount to do checkUnload
	} else {

		$alt_params .= "
		<SCRIPT LANGUAGE=\"JavaScript\">
		<!-- begin
		var win;
		var g_iCount;
		";

			if ($frm{'REDIRECT_URL'}) {

			# Re direct via JavaScript to any Alternate window
			# if REDIRECT_URL present AND POP_TARGET="POPUP"
			# then <mof.cgi> will print location, don't need JavaScript to
			# The POPUP window will not close, unless <mofviewcart-pop.html>
			# template contains directives for the POPUP window
			# you cannot print the default message to alternate window

				unless ($frm{'POP_TARGET'} eq "POPUP") {

				$alt_params .= "
				win=window.open('$frm{'REDIRECT_URL'}', '$frm{'POP_TARGET'}')
				win.focus();
				";

				}
			}

		# at minimum we focus the Pop Up
		$alt_params .= "	
		focus();
		//  End -->
		</script>
		";

	}
	# END: javascript manipulation for Pop Up Alt Params

	unless (open (FILE, "$FilePath") ) { 
		$ErrMsg="<h4>Unable to read template file: $Type</h4>";
		$ErrMsg .= "MOFcart is trying to read a template file, but the file 
		cannot be found as you have it defined in the [mof.conf] settings.<p>";
		$ErrMsg .= "MOFcart is looking for this file: <b>$FilePath</b>.<p>
		<li>Check the setting <b>\$$Setting</b> in [mof.conf]
		<li>You should have the full absolute path to the file, not a URL (http).
		<li>Check, double check, and triple check that your path is correct.
		<li>Check that the needed file is in the location you have defined above.
		<li>Check that the file is named as you have it listed in config settings.<p>";
		$ErrMsg .= "Applicable documentation:<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Configurations1.html\#WhereAreTemplates\" target=\"_blank\">
		Configurations1.html</a>, Where are the template file settings ?<br>";
		&ErrorMessage($ErrMsg);
		}
		@template = <FILE>;
		foreach $line (@template) {
		my ($alt_marker) = '<!-- POP-ALTERNATE-PARAMS -->';
		$switch=1 if ($line =~ /$insertion_marker/i);
		# link VarReplacer : August 11, 2003 12:07:56 AM
		$line = &VarReplacer($line);
			if ($switch) {
			push (@footer, $line);
			} else {
			push (@header, $line);
			push (@header, $alt_params) if ($line =~ /$alt_marker/i);
			}
		}
	}

# 07-28-03 : Message Var replacer
sub VarReplacer {
	my ($str) = @_;
	# find any {{STR}} and isolate name only, look for that in $frm{} if exists
	# you can also do variations of the @orders
	my $p;
   	my $rx = qr/\Q{{\E(.+?)\Q}}\E/;
	my @tmp = ( $str =~ /$rx/g );
	foreach $p (@tmp) {
		if (exists($frm{$p})) {
		$str =~ (s/{{$p}}/$frm{$p}/g);
		} else {
		$str =~ (s/{{$p}}//g);
		}
	}
	return $str;
	}

# PASS ERROR MESSAGE
sub ErrorMessage {
	my ($Err) = @_;
	my ($gmt) = &MakeUnixTime(0);	
	# return POPUP error messages
	if ($frm{'POP_TARGET'}) {
		if ($ERRORMODE == 2) {
		print "Location: $ErrMsgRedirectPop\n\n";
		} elsif ($ERRORMODE == 1) {
		print "Content-Type: text/html\n\n";
		print qq~
		<HTML><HEAD><TITLE>Shopping Cart Message</TITLE>
		<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
		<META name="ROBOTS" content="NOINDEX,NOFOLLOW">
		<SCRIPT LANGUAGE="JavaScript">
		var g_iCount = new Number();
		var g_iCount = 16;
		function startCountdown(){
    		if((g_iCount - 1) >= 0){
		g_iCount = g_iCount - 1;
		iText.innerText = 'Window closing in ' + g_iCount + ' seconds ..';
		setTimeout('startCountdown()',1000);
		} else {
		window.close();
		}}
		onload=startCountdown;
		focus();
		//  End -->
		</script>
		</HEAD>
		<BODY TOPMARGIN="0" LEFTMARGIN="0" RIGHTMARGIN="0" MARGINWIDTH="0" MARGINHEIGHT="0">
 		<table width="100%" border="0" cellspacing="0" cellpadding="10"><tr><td><p>
		<font face="Arial, Helvetica, sans-serif" size="2" color="#000000"><b>Shopping Cart Message</b></p>
		<p>We are currently experiencing technical difficulties with this request.</p>
		<font color="blue"><div align="center" id="iText"></div></font>
		<p align="center"><a href="javascript:;" onClick="window.close()">Close Window</font></a></p>
		</td></tr></table></BODY></HTML>~;
		} else {
		print "Content-Type: text/html\n\n";
		print "<html><head><title>MOF v2.4 Error</title></head><body bgcolor=#FFFFFF text=#000000>";
		print "<center><h4>TroubleShooting Mode</h4></center>";
		print "<center><table border=0 cellpadding=10 cellspacing=0 width=100\%><tr><td>";
		print "<p>$Err ";
		print "</td></tr></table></center>";
		print "</body></html>";
		}
	# return MAIN window error messages
	} else {
	if ($ERRORMODE == 2) {
	print "Location: $ErrMsgRedirect\n\n";
	} elsif ($ERRORMODE == 1) {
	print "Content-Type: text/html\n\n";
	print "<html><head><title>Error</title></head><body bgcolor=#FFFFE6 text=#000000>";
	print "<center><table bgcolor=#FFCE00 border=0 cellpadding=2 cellspacing=0 width=400> ";
	print "<tr><td align=center> ";
	print "$font <b> Shopping Cart Message </b></font> ";
	print "<table bgcolor=#FFFFE6 border=0 cellpadding=6 cellspacing=0 width=100%><tr><td> ";
	print "<font size=2 color=navy><br> ";
	print "<center><strong>We're sorry .. </strong></center><p> ";
	print "$font2 ";
	print "
	Our shopping cart has detected a problem with this request. <p>
	You may be attempting to load an <font color=red><b>expired cart page</b></font> 
	by using browser functions such as: PAGE BACK, PAGE FORWARD, BOOKMARKS, or the ADDRESS BAR.<p>
	Use the link below to return to the site, and then try navigating through
	the Shopping cart using <u>only</u> the buttons provided on the cart pages. <p>
	";
	if ($merchantmail) {
	print "If you are using all the cart buttons, and still getting this error, ";
	print "then please report the problem to ";
	print "<a href=\"mailto:$merchantmail\">$merchantmail</a>.<p>" ;
	}
	print "
	<center>
	<strong>
	<a href=\"$ErrMsgLink\">
	Click Here to return to the site</a></strong></center> <p>
	";
	print " </font> \n\n";
	print "</td></tr></table> \n\n";
	print "</td></tr></table></center><p> \n\n";
	print "</body></html>";
	} else {
	print "Content-Type: text/html\n\n";
	print "<html><head><title>MOF v2.4 Error</title></head><body bgcolor=#FFFFE6 text=#000000>";
	print "<center><h4>Merchant OrderForm v2.4 Error - TroubleShooting Mode</h4></center>";
	print "<center><table border=0 cellpadding=8 bgcolor=white cellspacing=0 width=600><tr><td>";
	print "<p>$Err ";
	print "</td></tr></table></center>";
	print "<p><center><table border=0 cellpadding=8 bgcolor=#FFFFE6 cellspacing=0 width=600><tr><td>";
	print "<li><u>Information Available</u><br>";
	print "<li>Local Time: $Date $Time<br>";
	print "<li>GMT Time: $gmt";
	if ($ENV{'HTTP_REFERER'}) {print "<li>Referring URL: $ENV{'HTTP_REFERER'}"}
	else {print "<li>Referring URL: <font color=red><b>Possible direct call to script</b></font>"}
	print "<li>Server Name: $ENV{'SERVER_NAME'}" if ($ENV{'SERVER_NAME'});
	print "<li>Server Protocol: $ENV{'SERVER_PROTOCOL'}" if ($ENV{'SERVER_PROTOCOL'});
	print "<li>Server Software: $ENV{'SERVER_SOFTWARE'}" if ($ENV{'SERVER_SOFTWARE'});
	print "<li>Gateway: $ENV{'GATEWAY_INTERFACE'}" if ($ENV{'GATEWAY_INTERFACE'});
	print "<li>Remote Host: $ENV{'REMOTE_HOST'}" if ($ENV{'REMOTE_HOST'});
	print "<li>Remote Addr: $ENV{'REMOTE_ADDR'}" if ($ENV{'REMOTE_ADDR'});
	print "<li>Remote User: $ENV{'REMOTE_USER'}" if ($ENV{'REMOTE_USER'});
	print "<p><font face=\"Arial,Helvetica\" size=1 color=gray>";
	print "<strong>Merchant OrderForm v2.4 \© Copyright ";
	print "<a href=\"http://www.merchantorderform.com\">RGA</a></strong>\n";
	print "</td></tr></table></center>";
	print "</body></html>";
	}
	}
	exit;	
	}

# VALIDATION MESSAGE
sub ValidationMessage {
	my (@MissingFields) = @_;
	my ($gmt) = &MakeUnixTime(0);	
	my ($field);
	# return POPUP validation
	if ($frm{'POP_TARGET'}) {
	&GetTemplateFile($validation_template_pop,"Product Input Validation Message Template","validation_template_pop"); 
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "<ol Class=\"ValidationLines\">\n";
	foreach $field (@MissingFields) {
	$field =~ s/\[/</g;
	$field =~ s/\]/>/g;
   	$field =~ s/<([^>]|\n)*>//g if ($strip_html_validation_msg);
		print "<li>$field  \n";
		}
	print "</ol><p>\n";
	print "@footer\n\n";
	# return MAIN window validation
	} else {
	&GetTemplateFile($validation_template,"Product Input Validation Message Template","validation_template"); 
	print "Content-Type: text/html\n\n";
	print "@header \n\n";
	print "<ol class=\"ValidationLines\">\n";
	foreach $field (@MissingFields) {
	$field =~ s/\[/</g;
	$field =~ s/\]/>/g;
   	$field =~ s/<([^>]|\n)*>//g if ($strip_html_validation_msg);
		print "<li>$field  \n";
		}
	print "</ol> <p><span class=\"ValidationFooter\">\n";
	unless ($STOPCART) {
	print "<a href=\"$ENV{'HTTP_REFERER'}\"><strong>Click Here</strong></a> \n";
	print "to return to the previous page.<p>";
	}
	print "Local Time: $Date $Time<br>\n";
	print "GMT Time: $gmt<p></span>\n";
	print "@footer \n\n";
	}
	exit;
	}

# COMPUTATION LIBRARIES 
# COMPUTATION LIBRARIES

# POPULATE %COMPUTATIONS WITH ANSWERS
sub MakeComputations {
	my ($total_discount) = 0;
	my ($allow_tax) = 0;
	$STOPCART = "";

	# (1) Find initial price all items
	# (2) Find total products
	foreach $line (@orders) {
  	($qty, $item, $desc, $price, $ship, $taxit) = split (/$delimit/, $line);
	$Computations{'Primary_Price'} += ($qty * $price);
	$Computations{'Primary_Products'} += $qty;
	}
	$Computations{'Primary_Price'} = sprintf "%.2f", $Computations{'Primary_Price'};

	# (3) Compute Primary Discount, sub total
	# (3) note: will not trigger if zero sub total
	$Computations{'Primary_Discount'} = &ComputeDiscount if (scalar(@use_discount) && $Computations{'Primary_Price'} > 0);
 	$Computations{'Sub_Primary_Discount'} = ($Computations{'Primary_Price'})-($Computations{'Primary_Discount'});
 	$Computations{'Sub_Primary_Discount'} = sprintf "%.2f", $Computations{'Sub_Primary_Discount'};

	# (4) Compute Coupon Discount, sub total
	# (4) note: will not trigger if zero sub total
		# if use_ARES find cookie
		# process with ARES Affiliate ID
		# elsif using conventional coupon box use 
		# $NewInfo{'Compute_Coupons'}
	if (scalar(@use_coupons) && $Computations{'Primary_Price'} > 0) {
	if ($use_ARES) {
	$ARESID = &CheckARESCookie($aresCookieID);
	$NewInfo{'Compute_Coupons'} = $ARESID;
	$Computations{'Coupon_Discount'} = &ComputeCouponDiscount($ARESID);
	} else {
	$Computations{'Coupon_Discount'} = &ComputeCouponDiscount($NewInfo{'Compute_Coupons'});
	}
	}
	$Computations{'Sub_Coupon_Discount'} = ($Computations{'Primary_Price'})-($Computations{'Coupon_Discount'});
 	$Computations{'Sub_Coupon_Discount'} = sprintf "%.2f", $Computations{'Sub_Coupon_Discount'};

	# (5) Compute Overall Sub total from both discounts, combined discount
	$total_discount = ($Computations{'Primary_Discount'})+($Computations{'Coupon_Discount'});
 	$Computations{'Sub_Final_Discount'} = ($Computations{'Primary_Price'}) - ($total_discount);
 	$Computations{'Sub_Final_Discount'} = sprintf "%.2f", $Computations{'Sub_Final_Discount'};
	$Computations{'Combined_Discount'} = sprintf "%.2f", $total_discount;

	# (6) Handling Charge, based on Sub_Final_Discount (final discounted price to work with)
	$Computations{'Handling'} = &ComputeHandling if scalar(@use_handling);
 	$Computations{'Handling'} = sprintf "%.2f", $Computations{'Handling'};

	# (7) Insurance Charges = selected amount from Preview Information or custom
	if (scalar(keys(%use_insurance))) {
	$Computations{'Insurance'} = &ComputeInsurance;
	$Computations{'Insurance'} = sprintf "%.2f", $Computations{'Insurance'};
	} else {
	$Computations{'Insurance_Status'} = "Not Available";
	}
	
	# (8) Default Shipping Charges
	# (8) Based on Sub_Final_Discount (final discounted price to work with)
	$Computations{'Shipping_Amount'} = &ComputeDefaultShipping if scalar(@use_shipping);
 	$Computations{'Shipping_Amount'} = sprintf "%.2f", $Computations{'Shipping_Amount'};

	# (9) User Input Shipping Methods Computations
	# (9) Based on Sub_Final_Discount (final discounted price to work with)
	# (9) This occurs in sequence after default shipping computations which 
	# (9) insures that Use input selection will preside over default shipping
	$Computations{'Shipping_Amount'} = &ComputeShippingMethod if scalar(keys(%use_method));
	$Computations{'Shipping_Amount'} = sprintf "%.2f", $Computations{'Shipping_Amount'};

	# (10) Find Combined/Sub Shipping-Handling-Insurance Amounts
	$Computations{'Combined_SHI'} += $Computations{'Handling'};
	$Computations{'Combined_SHI'} += $Computations{'Insurance'};
	$Computations{'Combined_SHI'} += $Computations{'Shipping_Amount'};
	$Computations{'Combined_SHI'} = sprintf "%.2f", $Computations{'Combined_SHI'};
	$Computations{'Sub_SHI'} = ($Computations{'Sub_Final_Discount'} + $Computations{'Combined_SHI'} );
	$Computations{'Sub_SHI'} = sprintf "%.2f", $Computations{'Sub_SHI'};

	# (11) Tax computations
	# (11) All %Computations{Variables} are produced in the ComputeTax routine
	# (11) note: will not trigger if zero sub total
	$allow_tax++ if ($use_global_tax);
	$allow_tax++ if ($use_custom_tax);
	$allow_tax++ if (scalar(keys(%use_city_tax)));
	$allow_tax++ if (scalar(keys(%use_zipcode_tax)));
	$allow_tax++ if (scalar(keys(%use_state_tax)));
	$allow_tax++ if (scalar(keys(%use_country_tax)));
	&ComputeTax if ($allow_tax && $Computations{'Primary_Price'} > 0);
	$Computations{'Adjusted_Tax_Amount_Before'} = sprintf "%.2f", $Computations{'Adjusted_Tax_Amount_Before'};
	$Computations{'Adjusted_Tax_Amount_After'} = sprintf "%.2f", $Computations{'Adjusted_Tax_Amount_After'};
	$Computations{'Tax_Amount'} = sprintf "%.2f", $Computations{'Tax_Amount'};

	# (12) Compute final amount
	$Computations{'Final_Amount'} = $Computations{'Sub_Final_Discount'};
	$Computations{'Final_Amount'} += $Computations{'Tax_Amount'};
	$Computations{'Final_Amount'} += $Computations{'Combined_SHI'};

	# (13) Compute alternate currency line : May 12, 2003 5:45:58 PM
	if ($currencyConvertRate > 0.00) {
	$Computations{'Final_ConvertAmount'} = ($Computations{'Final_Amount'} * $currencyConvertRate);
	$Computations{'Final_ConvertAmount'} = sprintf "%.2f", $Computations{'Final_ConvertAmount'};
	}

	# format final amt
	$Computations{'Final_Amount'} = sprintf "%.2f", $Computations{'Final_Amount'};

	# CUSTOMIZE HERE
	# you can customize a minimum purchase condition here
	# It is a final check and redirect if condition not met
	# You can use any of the computations to accomplish your condition
	# Example 'Primary_Price' is items before Discount, SHI, Tax, Totals
	# unless ($Computations{'Final_Amount'} > 50) {
	# $STOPCART = "Your Cart Items Total $currency $Computations{'Primary_Price'}<br>";
	# $STOPCART .= "A minimum purchase of $currency 50.00 is required<p>";
	# $STOPCART .= "<a href=\"$programfile?viewcart&previouspage=$ErrMsgViewCart\">Click here to Return to cart items</a><br>";
	# $STOPCART .= "<a href=\"$ErrMsgViewCart\">Click here to Return to the Store</a><br>";
	# &ValidationMessage("$STOPCART");
	# }

 } 

# COMPUTE DISCOUNT
sub ComputeDiscount {
	# use config settings (mode,rate,increment)
	# if increment not set, defaults to 1 dollar/product
	# use globals already from %Computations
	my ($msg_rate, $msg);
	my ($discount, $repeats) = (0,0);
	my ($mode) = $use_discount[0];
	my ($rate) = $use_discount[1];
	my ($increment) = $use_discount[2];
	my ($price) = $Computations{'Primary_Price'};
	my ($items) = $Computations{'Primary_Products'};

	if ($mode =~ /\bamount\b/i) {
		if ($increment) {
		$repeats = ( int ( $price / $increment ) );
      		$discount = ( $rate * $repeats ) unless ( $price < $increment );
		$msg_rate = (100 * ($rate / $increment));
		$msg = "$msg_rate\% each $currency $increment";
		$Computations{'Primary_Discount_Status'} = 'Discount ' . $msg;
		} else {
	      	$discount = ( $rate * $price);
		$msg_rate = (100 * $rate);
		$msg = "$msg_rate\% each $currency 1.00";
		$Computations{'Primary_Discount_Status'} = 'Discount ' . $msg;
		}
	} elsif ($mode =~ /\bquantity\b/i) {
		if ($increment) {
		$repeats = ( int ( $items / $increment ) );
      		$discount = ( $rate * $repeats ) unless ( $items < $increment );
		$Computations{'Primary_Discount_Status'} = "Discount $currency $rate each $increment item(s)";
		} else {
	      	$discount = ( $rate * $items );
		$Computations{'Primary_Discount_Status'} = "Discount $currency $rate each item";
		}
	} elsif ($mode =~ /\bcustom\b/i) {

	# =========================================================================== #
	#                CUSTOMIZE PRIMARY DISCOUNT COMPUTATION                       #
	# =========================================================================== #
	# These are the Variables Available to you at this point:                     #
	# $currency (the currency symbol)                                             #
	# $price (Price of all products before any computations)                      # 
	# $items (total number of products ordered)                                   #
	# Return: $discount                                                           #
	# Make: $Computations{'Primary_Discount_Status'} = "display message"          #
	# Option: $Computations{'Primary_Discount_Line_Override'} = 1;                #
	#         * will show line item even if zero discount (1) enable              #
	# Option: $Computations{'Primary_Discount_Line_Override_Backend'} = 1;        #
	#         * will show line item even if zero discount (1) enable              #
	#         * only non zero discount amts will trigger line item msg otherwise  #
	# Option: $Computations{'Primary_Discount_Amt_Override'}                      #
	#         * will show this msg where discount $ amt should be                 #
	#         * Note: will only show if discount is zero                          #
	#         * Note: if discount > $ 0.00 you want real $ amt to show            #
	# Both optional settings only work with custom mode                           #
	# Place optional settings just above the "return" to trigger otherwise        #
	# =========================================================================== #

	# Custom Discount Code Starts Here
	# Custom Discount Code Starts Here

	$Computations{'Primary_Discount_Line_Override_Backend'} = 10;

	if ( $price < 50 ) { 
	$discount = 0;
	$Computations{'Primary_Discount_Status'} = "We Discount Purchases Over \$ 50.00";
	$Computations{'Primary_Discount_Line_Override'} = 10;
	$Computations{'Primary_Discount_Amt_Override'} = "<font color=red size=1>SAVE BIG</font>";

	} elsif ( $price < 100 ) {
 	$discount = 6;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 6.00";
	} elsif ( $price < 200 ) { 
	$discount = 9.95;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 9.95";
	} elsif ( $price < 350 ) { 
	$discount = 12.50;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 12.50";
	} elsif ( $price < 500 ) { 
	$discount = 17;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 17.00";
	} elsif ( $price < 700 ) { 
	$discount = 19.95;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 19.95";
	} elsif ( $price < 850 ) { 
	$discount = 21.50;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 21.50";
	} elsif ( $price < 1100 ) { 
	$discount = 35;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 35.00";
	} elsif ( $price < 1500 ) { 
	$discount = 50;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 50.00";
	} else { 
	$discount = 75;
	$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 75.00";
	}

	# Custom Discount Code Ends Here
	# Custom Discount Code Ends Here

	}
	$discount = sprintf "%.2f", $discount;
  	return $discount;	
 	}

# COMPUTE COUPON DISCOUNT
sub ComputeCouponDiscount {
	my ($couponumber) = @_;
	my ($coupon_discount) = 0;
	my (@TempList) = ();
	my ($code, $rate, $msg, $msg_rate);
	my ($revoke, $used, $dateused, $invoice);
	my ($mode) = $use_coupons[0];
	my ($msg_rate, $msg);
	my ($aresDefaultRate, $aresDefaultAffrate) = (0,0);
	my ($price) = $Computations{'Primary_Price'};
	my ($items) = $Computations{'Primary_Products'};
	unless (open (FILE, "$coupon_file") ) { 
		$ErrMsg="<h4>Unable to read the Coupon data file</h4>";
		$ErrMsg .= "MOFcart is trying to read the coupon data file, but the file 
		cannot be found as you have it defined in the [mof.conf] settings.<p>";
		$ErrMsg .= "MOFcart is looking for this file: <b>$coupon_file</b>.<p>";
		if ($use_ARES) {
		$ErrMsg .= "You appear to have ARES enabled. Make sure the <b>\$coupon_file</b> setting 
		in [mof.conf] has the full absolute path to the ARES datafiles directory, 
		where the coupon data file should be located with the other ARES data files.<p>";}
		$ErrMsg .= "<li>Check the setting <b>\$coupon_file</b> in [mof.conf]
		<li>You should have the full absolute path to the file, not a URL (http).
		<li>Check, double check, and triple check that your path is correct.
		<li>Check that the needed file is in the location you have defined above.
		<li>Check that the file is named as you have it listed in config settings.<p>";
		$ErrMsg .= "Applicable documentation:<br>
		<a href=\"http://www.merchantorderform.com/Documentation/Configurations1.html\#UseCoupons\" target=\"_blank\">
		Configurations1.html</a>, How to use the Coupon feature ?<br>";
		&ErrorMessage($ErrMsg);
		}
		flock (FILE,2) if ($lockfiles);
		@TempList = <FILE>;
		close(FILE);
		chop (@TempList);
		foreach $_ (@TempList) {
		($code, $rate, $affrate, $revoke, $used, $dateused, $invoice) = split(/\|/, $_);
			if ($use_ARES_default_number && $use_ARES) {
			if ($use_ARES_default_number =~ /\b$code\b/i) {
			($aresDefaultRate, $aresDefaultAffrate) = ($rate, $affrate);
			}}
			if ($couponumber =~ /\b$code\b/i) {
				# add revoke fields 3-2-02, and line item override
				# $Computations{'Coupon_Discount_Override'} = "1";
				if ($revoke && $used >= $revoke) {
				my ($r) = $used . " time";
				$r .= "s" if ($used > 1);
				$msg = "Coupon $code Used $r";
				$Computations{'Coupon_Discount_Status'} = $msg;
				$Computations{'Coupon_Affiliate_Rate'} = 0;
				$Computations{'Coupon_Cust_Rate'} = 0;
				$coupon_discount = 0;
				$Computations{'Coupon_Discount_Override'} = "1";
				} elsif ($mode =~ /\bpercent\b/i) {
				$msg_rate = ($rate * 100);
				$msg = "Discount $msg_rate\% For $code Valid";
				$Computations{'Coupon_Discount_Status'} = $msg;
				$Computations{'Coupon_Affiliate_Rate'} = $affrate;
				$Computations{'Coupon_Cust_Rate'} = $rate;
				$coupon_discount = ( $rate * $price );
				} elsif ($mode =~ /\bdollar\b/i) {
				$msg = "Discount $currency $rate For $code Valid";
				$Computations{'Coupon_Discount_Status'} = $msg;
				$Computations{'Coupon_Affiliate_Rate'} = $affrate;
				$Computations{'Coupon_Cust_Rate'} = $rate;
				$coupon_discount = ( $rate );
				}
			}
		}

		# if coupon number was not found
		# attempt to use the ares_default_number
		unless ($msg) {
		if ($use_ARES_default_number && $use_ARES) {
		$msg_rate = ($aresDefaultRate * 100);
		$msg = "Discount $msg_rate\% For $use_ARES_default_number Valid";
		$Computations{'Coupon_Discount_Status'} = $msg;
		$Computations{'Coupon_Affiliate_Rate'} = $aresDefaultAffrate;
		$Computations{'Coupon_Cust_Rate'} = $aresDefaultRate;
		$coupon_discount = ( $aresDefaultRate * $price );
		$NewInfo{'Compute_Coupons'} = $use_ARES_default_number;
		}}

	$Computations{'Coupon_Discount_Status'} = "Discount For $couponumber Invalid" unless ($msg);
	$Computations{'Coupon_Discount_myNumber'} = "$couponumber";
	$coupon_discount = sprintf "%.2f", $coupon_discount;
	return $coupon_discount;
	}

# COMPUTE HANDLING
sub ComputeHandling {
	# use config settings (mode,rate,increment)
	# if increment not set, defaults to 1 dollar/product
	# This computation is dependent on $Computations{'Sub_Final_Discount'}
	# Which is the final price to work with after all discounts
	# or if using 'quantity' mode it uses total products ordered
	my ($msg_rate, $msg);
	my ($handling, $repeats) = (0,0);
	my ($mode) = $use_handling[0];
	my ($rate) = $use_handling[1];
	my ($increment) = $use_handling[2];
	my ($price) = $Computations{'Sub_Final_Discount'};
	my ($items) = $Computations{'Primary_Products'};

	if ($mode =~ /\bamount\b/i) {
		if ($increment) {
		$repeats = ( int ( $price / $increment ) );
      		$handling = ( $rate * $repeats ) unless ( $price < $increment );
		$msg_rate = (100 * ($rate / $increment));
		$msg = "$msg_rate \% each $currency $increment";
		$Computations{'Handling_Status'} = 'Handling Fee ' . $msg;
		} else {
	      	$handling = ( $rate * $price );
		$msg_rate = (100 * $rate);
		$msg = "$msg_rate \% each $currency 1.00";
		$Computations{'Handling_Status'} = 'Handling Fee ' . $msg;
		}
	} elsif ($mode =~ /\bquantity\b/i) {
		if ($increment) {
		$repeats = ( int ( $items / $increment ) );
      		$handling = ( $rate * $repeats ) unless ( $items < $increment );
		$Computations{'Handling_Status'} = "Handling Fee $currency $rate each $increment item(s)";
		} else {
	    	$handling = ($rate * $items);	
		$Computations{'Handling_Status'} = "Handling Fee $currency $rate each item";
		}
	} elsif ($mode =~ /\bcustom\b/i) {

	# =========================================================================== #
	#                     CUSTOMIZE HANDLING COMPUTATION                          #
	# =========================================================================== #
	# These are the Variables Available to you at this point:                     #
	# $currency (the currency symbol)                                             #
	# $price (Price of all products before any computations)                      # 
	# $items (total number of products ordered)                                   #
	# Return: $handling                                                           #
	# Make: $Computations{'Handling_Status'} = "display message"                  #
	# Option: $Computations{'Handling_Line_Override'} = 1;                        #
	#         * will show line item even if zero handling (1) enable              #
	# Option: $Computations{'Handling_Amt_Override'}                              #
	#         * will show this msg where handling $ amt should be                 #
	#         * Note: will only show if handling is zero                          #
	#         * Note: if handling > $ 0.00 you want real $ amt to show            #
	# Both optional settings only work with custom mode                           #
	# Place optional settings just above the "return" to trigger otherwise        #
	# =========================================================================== #

	# Custom Handling Code Starts Here
	# Custom Handling Code Starts Here

	if ( $items < 6 ) { 
	$handling = 2.50;
	$Computations{'Handling_Status'} = "Handling Fees $currency 2.50";
	} elsif ( $items < 11 ) { 
	$handling = 4.50;
	$Computations{'Handling_Status'} = "Handling Fees $currency 4.50";
	} else { 
	$handling = 0;
	$Computations{'Handling_Status'} = "No Handling Fees Over 10 Items";
	$Computations{'Handling_Line_Override'} = 10;
	$Computations{'Handling_Amt_Override'} = "<font size=1>FREE</font>";
	}

	# Custom Handling Code Ends Here
	# Custom Handling Code Ends Here
	
	}
	$handling = sprintf "%.2f", $handling;
  	return $handling;	
 	}

# COMPUTE INSURANCE
sub ComputeInsurance {
	# This computation is dependent on $Computations{'Sub_Final_Discount'}
	# Which is the final price to work with after all discounts - or -
	# dependent on $Computations{'Primary_Products'} for overall number of items ordered
	my ($insurance) = 0;
	my ($price) = $Computations{'Sub_Final_Discount'};
	my ($items) = $Computations{'Primary_Products'};

	# =========================================================================== #
	#                     CUSTOMIZE INSURANCE COMPUTATIONS                        #
	# =========================================================================== #
	# Insurance is computed using the selected %use_insurance value               #
	# - OR - it will be computed as custom by coding branches below based on the  #
	# selected %use_insurance value from <mof.conf> insurance settings.         #
	# Condition to match user selection: ($NewInfo{'Compute_Insurance'} == value) #
	# By customizing the entire branch you can make the Insurance line item       #
	# display just about anything you want, and based on user selection           #
	# =========================================================================== #
	# These are the Variables Available to you at this point:                     #
	# $currency (the currency symbol)                                             #
	# $price (Price of all products before any computations)                      # 
	# $items (total number of products ordered)                                   #
	# Return: $insurance                                                          #
	# Make: $Computations{'Insurance_Status'} = "display message"                 #
	# Option: $Computations{'Insurance_Line_Override'} = 1;                       #
	#         * will show line item even if zero insurance (1) enable             #
	# Option: $Computations{'Insurance_Amt_Override'}                             #
	#         * will show this msg where Insurance $ amt should be                #
	#         * Note: will only show if Insurance is zero                         #
	#         * Note: if Insurance > $ 0.00 you want real $ amt to show           #
	# Both optional settings only work with custom mode                           #
	# Place optional settings just above the "return" to trigger otherwise        #
	# =========================================================================== #
	# Note: You can also include any of the above Return, Make, Option VARS       #
	# Note: in any of your custom shipping code                                   #
	# =========================================================================== #

	# The packaged example uses these <mof.conf> settings

		# ------------------------------------ #
		# %use_insurance = (                   #
		# 'No Insurance',0,                    #
		# 'Up to $ 500.00 ($13.25)',13.25,     #
		# 'Up to $ 1000.00 ($18.98)',18.98,    # 
		# 'Up to $ 2500.00 ($26.00)',26.00,    #
		# 'FREE Standard Insurance','1000',    #
		# 'Compute Priority Insurance','2000'  #
 		# );                                   #
		# ------------------------------------ #
	
	# A simple NO/YES insurance would be akin to these settings
	# %use_insurance = ('No Insurance',0,'Yes Insurance','2000');
	# where you would adjust the branch 2000 below for your computation needs

	# Insurance Computation Starts Here
	# Insurance Computation Starts Here

	if ($NewInfo{'Compute_Insurance'} == 0) {
		$insurance = 0;
		$Computations{'Insurance_Status'} = "Insurance Not Requested";
		$Computations{'Insurance_Line_Override'} = 10;
		$Computations{'Insurance_Amt_Override'} = "<font color=navy size=1>Declined</font>";

	} elsif ($NewInfo{'Compute_Insurance'} == 1000) {
		$insurance = 0;
		$Computations{'Insurance_Status'} = "FREE Standard Insurance";
		$Computations{'Insurance_Line_Override'} = 1;
		$Computations{'Insurance_Amt_Override'} = "<font size=1>FREE</font>";

	} elsif ($NewInfo{'Compute_Insurance'} == 2000) {
		$insurance = ($items * 0.75);
		$Computations{'Insurance_Status'} = "Priority Insurance";

	# Do not delete this else statement
	} else {
		# Insurance amount = selected %use_insurance value 
		$insurance = $NewInfo{'Compute_Insurance'};
		while (($key, $val) = each (%use_insurance)) {
		$Computations{'Insurance_Status'} = "Insurance " . $key if ($NewInfo{'Compute_Insurance'} == $val);
		}
	}

	# Insurance Computation Ends Here
	# Insurance Computation Ends Here

	$insurance = sprintf "%.2f", $insurance;
  	return $insurance;	
  	}

# COMPUTE DEFAULT SHIPPING
sub ComputeDefaultShipping {
	# use config settings (mode,domestic-rate,foreign-rate,increment)
	# if increment not set, defaults to 1 dollar/pound(relative)
	# This computation is dependent on $Computations{'Sub_Final_Discount'}
	# Which is the final price to work with after all discounts
	# or if using 'weight' mode it uses sum of (weight * quantity) of all products ordered
	my ($msg_rate, $msg);
	my ($sub_price) = $Computations{'Sub_Final_Discount'};
	my ($items) = $Computations{'Primary_Products'};
	my ($qty, $item, $desc, $price, $ship, $taxit);
	my ($rate, $is_domestic, $use_domestic, $shipping, $repeats, $total_weight) = (0,0,0,0,0,0);
	my ($mode) = $use_shipping[0];
	my ($domestic_rate) = $use_shipping[1];
	my ($foreign_rate) = $use_shipping[2];
	my ($increment) = 0;

	if ($use_shipping[3]) {$increment = $use_shipping[3];
	} else {$increment = 1;}

	# compute total weight
	foreach (@orders) {
	($qty, $item, $desc, $price, $ship, $taxit) = split(/$delimit/);
	$total_weight += ( $qty * $ship );
	}
	$Computations{'Total_Weight'} = $total_weight;

	# Find domestic flag(s)
	# City, State, Country Order to find largest area last
	# City, State, Country listed in Computations only if found
	if (scalar(@domestic_city)) {
	$use_domestic++;
	foreach (@domestic_city) {
	if ($_ =~ /\b$NewInfo{'Ecom_ShipTo_Postal_City'}\b/i) {
	$Computations{'Domestic_City'} = $NewInfo{'Ecom_ShipTo_Postal_City'};
	$is_domestic++;
	}}}

	if (scalar(@domestic_state)) {
	$use_domestic++;
	foreach (@domestic_state) {
	if ($NewInfo{'Ecom_ShipTo_Postal_StateProv'} =~ /\b$_\b/i) {
	$Computations{'Domestic_State'} = $NewInfo{'Ecom_ShipTo_Postal_StateProv'};
	$is_domestic++;
	}}}

	if (scalar(@domestic_country)) {
	$use_domestic++;
	foreach (@domestic_country) {
	if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'} =~ /\b$_\b/i) {
	$Computations{'Domestic_Country'} = $NewInfo{'Ecom_ShipTo_Postal_CountryCode'};
	$is_domestic++;
	}}}

	$Computations{'Is_Domestic'} = $is_domestic;
	$Computations{'Use_Domestic'} = $use_domestic;

	# what rate to use
	if ($use_domestic) {
		if ($is_domestic) {
		$rate = $domestic_rate;
		$Computations{'Shipping_Status'} = "Domestic";
		} else {
		$rate = $foreign_rate;
		$Computations{'Shipping_Status'} = "Foreign";
		}		
	} else {
	$rate = $domestic_rate;
	$Computations{'Shipping_Status'} = "Standard";
	}	

	# Compute the rate
	if ($mode =~ /\bamount\b/i) {
		if ($rate) {
		$shipping = ( $rate * ( int ( $sub_price / $increment ) ) );
		$msg_rate = $rate;
		$msg = "$Computations{'Shipping_Status'} ";
		$msg .= "Shipping $currency $msg_rate each $currency $increment";
		$Computations{'Shipping_Message'} = $msg;
			if ($use_domestic && !$is_domestic) {
			if ($shipping < $minimum_foreign) {
			$shipping = $minimum_foreign;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Fee";
			}
			} else {
			if ($shipping < $minimum_domestic) {
			$shipping = $minimum_domestic;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Fee";
			}
			}
		} else {
		$shipping = 0;
		}

	} elsif ($mode =~ /\bweight\b/i) {
		if ($rate) {
		$shipping = ( $rate * ( int ( $total_weight / $increment ) ) );
		$msg_rate = $rate;
		$msg = "$Computations{'Shipping_Status'} ";
		$msg .=  "Shipping $currency $rate each $increment $weight ";
		$msg .=  "For $Computations{'Total_Weight'} $weight ";
		$Computations{'Shipping_Message'} = $msg;
			if ($use_domestic && !$is_domestic) {
			if ($shipping < $minimum_foreign) {
			$shipping = $minimum_foreign;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Fee";
			}
			} else {
			if ($shipping < $minimum_domestic) {
			$shipping = $minimum_domestic;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Fee";
			}
			}
		} else {
		$shipping =0;
		}

	} elsif ($mode =~ /\bcustom\b/i) {

	# =========================================================================== #
	#                  CUSTOMIZE DEFAULT SHIPPING COMPUTATION                     #
	# =========================================================================== #
	# These are the Variables Available to you at this point:                     #
	# $currency (the currency symbol)                                             #
	# Local: $sub_price (Sub Total after all discounts computed)                  #
	# Local: $items (total number of products ordered)                            #
	# Local: $total_weight (if using ship codes and 'weight' mode)                #
	# Local: $use_domestic (are there any domestic settings)                      #
	# Local: $is_domestic (are any domestic settings matched from <mof.conf>)     #
	#  Note: (this uses settings in default area for city,state,country           #
	#  Note: You can also use the minimum/maximum settings in <mof.conf>          #
	# Global: $Computations{'Total_Weight'}                                       #
	# Global: $Computations{'Use_Domestic'} positive if enabled                   #
	# Global: $Computations{'Is_Domestic'} if enabled and domestic match          #
	# Global: $Computations{'Domestic_City'} if found                             #
	# Global: $Computations{'Domestic_State'} if found                            #
	# Global: $Computations{'Domestic_Country'} if found                          #
	# Return: $shipping                                                           #
	# Make: $Computations{'Shipping_Message'} = "display message"                 #
	# Option: $Computations{'Shipping_Line_Override'} = 1;                        #
	#         * will show line item even if zero shipping (1) enable              #
	# Option: $Computations{'Shipping_Amt_Override'}                              #
	#         * will show this msg where Shipping $ amt should be                 #
	#         * Note: will only show if Shipping is zero                          #
	#         * Note: if Shipping > $ 0.00 you want real $ amt to show            #
	# Both optional settings only work with custom mode                           #
	# Place optional settings just above the "return" to trigger otherwise        #
	# =========================================================================== #

	# Custom Shipping Code Starts Here
	# Custom Shipping Code Starts Here

	# This example uses Domestic/Foreign and shows how to use the override switches
	# Domestic is as defined in @domestic_country = ()
	# Domestic shipping 12 or more items is FREE, and we use override settings to say that
	# Foreign uses override settings to say that shipping will be added

	if ($is_domestic) {
	$Computations{'Shipping_Message'} = "Domestic Shipping Fees";

		if ( $items < 6 ) {$shipping = 6.95}
		elsif ( $items < 12 ) {$shipping = 8.95}

		else {
		$shipping = 0.00;
		$Computations{'Shipping_Line_Override'} = 1;
		$Computations{'Shipping_Amt_Override'} = "<font size=1>FREE</font>";
		}

	} else {
	$shipping = 0;
	$Computations{'Shipping_Message'} = "International Shipping To Be Added";
	$Computations{'Shipping_Line_Override'} = 1;
	$Computations{'Shipping_Amt_Override'} = "<font color=red size=1>to be added</font>";
	}

	# Custom Shipping Code Ends Here
	# Custom Shipping Code Ends Here
	
	}
	$shipping = sprintf "%.2f", $shipping;
  	return $shipping;	
 	}

# COMPUTE USER SELECTED SHIPPING	
sub ComputeShippingMethod {
	my ($sub_price) = $Computations{'Sub_Final_Discount'};
	my ($items) = $Computations{'Primary_Products'};
	my ($qty, $item, $desc, $price, $ship, $taxit, $key, $val);
	my ($rate, $is_domestic, $use_domestic, $shipping, $repeats, $total_weight) = (0,0,0,0,0,0);
	my ($method, $mode, $domestic_rate, $foreign_rate, $increment);

	# zero out any custom default override messages
	# but keep an override because selected method needs to print 
	$Computations{'Shipping_Line_Override'} = 1;
	$Computations{'Shipping_Amt_Override'} = "";

	# Find selected info
	$method = $NewInfo{'Compute_Shipping_Method'}; 
	$Computations{'Shipping_Method_Name'} = $method;
	while (($key, $val) = each (%use_method)) {
	$Computations{'Shipping_Method_Description'} = $val if ($method eq $key);
	$Computations{'Shipping_Message'} = $val if ($method eq $key);
	}
	$mode = $method_mode{$method};
	$domestic_rate = $method_domestic{$method};
	$foreign_rate = $method_foreign{$method};

	if ($method_increment{$method}) {
	$increment = $method_increment{$method};
	} else {$increment = 1;}

	# compute total weight
	foreach (@orders) {
	($qty, $item, $desc, $price, $ship, $taxit) = split(/$delimit/);
	$total_weight += ( $qty * $ship );
	}
	$Computations{'Total_Weight'} = $total_weight;

	# Find domestic flag(s)
	# City, State, Country Order to find largest area last
	# City, State, Country listed in Computations only if found

	if (scalar(@domestic_city)) {
	$use_domestic++;
	foreach (@domestic_city) {
	if ($_ =~ /\b$NewInfo{'Ecom_ShipTo_Postal_City'}\b/i) {
	$Computations{'Domestic_City'} = $NewInfo{'Ecom_ShipTo_Postal_City'};
	$is_domestic++;
	}}}

	if (scalar(@domestic_state)) {
	$use_domestic++;
	foreach (@domestic_state) {
	if ($NewInfo{'Ecom_ShipTo_Postal_StateProv'} =~ /\b$_\b/i) {
	$Computations{'Domestic_State'} = $NewInfo{'Ecom_ShipTo_Postal_StateProv'};
	$is_domestic++;
	}}}

	if (scalar(@domestic_country)) {
	$use_domestic++;
	foreach (@domestic_country) {
	if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'} =~ /\b$_\b/i) {
	$Computations{'Domestic_Country'} = $NewInfo{'Ecom_ShipTo_Postal_CountryCode'};
	$is_domestic++;
	}}}

	$Computations{'Is_Domestic'} = $is_domestic;
	$Computations{'Use_Domestic'} = $use_domestic;

	# what rate to use
	if ($use_domestic) {
		if ($is_domestic) {
		$rate = $domestic_rate;
		$Computations{'Shipping_Status'} = "Domestic";
		} else {
		$rate = $foreign_rate;
		$Computations{'Shipping_Status'} = "Foreign";
		}		
	} else {
	$rate = $domestic_rate;
	$Computations{'Shipping_Status'} = "Standard";
	}	

	# Compute the rate
	if ($mode =~ /\bamount\b/i) {
		if ($rate) {
		$shipping = ( $rate * ( int ( $sub_price / $increment ) ) );
			if ($use_domestic && !$is_domestic) {
			$shipping = $method_min_foreign{$method} if ($shipping < $method_min_foreign{$method});
			} else {
			$shipping = $method_min_domestic{$method} if ($shipping < $method_min_domestic{$method});
			}
		} else {
		$shipping = 0;
		}

	} elsif ($mode =~ /\bweight\b/i) {
		if ($rate) {
		$shipping = ($rate * ( int ( $total_weight / $increment ) ) );
			if ($use_domestic && !$is_domestic) {
			$shipping = $method_min_foreign{$method} if ($shipping < $method_min_foreign{$method});
			} else {
			$shipping = $method_min_domestic{$method} if ($shipping < $method_min_domestic{$method});
			}
		} else {
		$shipping = 0;
		}

	} elsif ($mode =~ /\bcustom\b/i) {

	# =========================================================================== #
	#               CUSTOMIZE USER SELECTED SHIPPING COMPUTATION                  #
	# =========================================================================== #
	# You must ID Your Method Key name for each "custom" used in <mof.conf>       #
	# You must set up the [if.elsif] branch with the Key name in this cuatom area #
	# Each Method using "custom" computations must have it's own branch and code  #
	# =========================================================================== #
	# These are the Variables Available to you at this point:                     #
	# $currency (the currency symbol)                                             #
	# Local: $sub_price (Sub Total after all discounts computed)                  #
	# Local: $items (total number of products ordered)                            #
	# Local: $total_weight (if using ship codes and 'weight' mode)                #
	# Local: $use_domestic (are there any domestic settings)                      #
	# Local: $is_domestic (are any domestic settings matched from <mof.conf>)     #
	#  Note: (this uses settings in default area for city,state,country           #
	#  Note: You can also use the minimum/maximum settings in <mof.conf>          #
	# Global: $Computations{'Total_Weight'}                                       #
	# Global: $Computations{'Use_Domestic'} positive if enabled                   #
	# Global: $Computations{'Is_Domestic'} if enabled and domestic match          #
	# Global: $Computations{'Domestic_City'} if found                             #
	# Global: $Computations{'Domestic_State'} if found                            #
	# Global: $Computations{'Domestic_Country'} if found                          #
	# Global: $Computations{'Shipping_Status'} [Domestic,Foreign,Standard]        #
	# Return: $shipping                                                           #
	# Make: $Computations{'Shipping_Message'} = "display message"                 #
	# Option: $Computations{'Shipping_Line_Override'} = 1;                        #
	#         * will show line item even if zero shipping (1) enable              #
	# Option: $Computations{'Shipping_Amt_Override'}                              #
	#         * will show this msg where Shipping $ amt should be                 #
	#         * Note: will only show if Shipping is zero                          #
	#         * Note: if Shipping > $ 0.00 you want real $ amt to show            #
	# Both optional settings only work with custom mode                           #
	# Place optional settings just above the "return" to trigger otherwise        #
	# =========================================================================== #

	# Example of custom shipping branch
	# Example of custom shipping branch

	if ($method eq "Express_Delivery") {
	# This is where custom code goes for Express_Delivery method
	# Your computations should produce the $shipping variable
	# You can use any of the available variables above in your computation
			
	$shipping = 1.99;
	$Computations{'Shipping_Message'} = $Computations{'Shipping_Method_Description'};

	} elsif ($method eq "Another_Method_Name") {
	# Continue the branch for any other Method Names using "custom"
	# Continue the branch for any other Method Names using "custom"
	}

	# End example of custom shipping branch
	# End example of custom shipping branch

	}
	$shipping = sprintf "%.2f", $shipping;
  	return $shipping;	
	}

# COMPUTE TAX
sub ComputeTax {
	my ($i);
	my ($tax) = 0;
	my ($rate) = 0;
	my ($key, $val);
	my ($exceptions) = 0;
	my ($before_amount, $after_amount) = (0,0);
	my ($qty, $item, $desc, $price, $ship, $taxit);

	# initial taxable amount
	foreach (@orders) {
	($qty, $item, $desc, $price, $ship, $taxit) = split(/$delimit/);
	$Computations{'Initial_Taxable_Amount'} += ( $qty * $price ) if ($taxit);
	}
	$Computations{'Initial_Taxable_Amount'} = sprintf "%.2f", $Computations{'Initial_Taxable_Amount'};

	# Find percentage of taxable amount to Full amount
	# This allows for a weighted adjustment for discounts
	# if every item is taxable the ratio will be 1
	# if every item is non taxable the ratio will be 0
 	$_ = ($Computations{'Initial_Taxable_Amount'} / $Computations{'Primary_Price'});
	$Computations{'Tax_Discount_Ratio'} = $_;

	# adjusted taxable amount 
	# initial amount less taxable ratio of combined discounts
 	$_ = ($Computations{'Tax_Discount_Ratio'} * $Computations{'Combined_Discount'});
 	$i = ($Computations{'Initial_Taxable_Amount'} - $_);
	$Computations{'Adjusted_Tax_Amount'} = sprintf "%.2f", $i;

	# set before/after adjusted tax amounts
	$before_amount = $Computations{'Adjusted_Tax_Amount'};
	$after_amount = ($Computations{'Adjusted_Tax_Amount'} + $Computations{'Combined_SHI'});

	# Find rate
	if ($use_global_tax > 0) { 
	$rate = $use_global_tax;
	} else {

	# Find city matched rate
	if (scalar(keys(%use_city_tax))) {
	while (($key, $val) = each (%use_city_tax)) {
		if ( $key =~ /^$NewInfo{'Ecom_ShipTo_Postal_City'}$/i ) {
			if ($add_tax_rates) { $rate += $val;
			} else { $rate = $val if ($val > $rate);
			}
			last;
			}}}

	# Find zipcode matched rate
	if (scalar(keys(%use_zipcode_tax))) {
	while (($key, $val) = each (%use_zipcode_tax)) {
		if ( $NewInfo{'Ecom_ShipTo_Postal_PostalCode'} =~ /^$key/i ) {
			if ($add_tax_rates) { $rate += $val;
			} else { $rate = $val if ($val > $rate);
			}
			last;
			}}}

	# Find state matched rate
	if (scalar(keys(%use_state_tax))) {
	while (($key, $val) = each (%use_state_tax)) {
		if ( $key =~ /^$NewInfo{'Ecom_ShipTo_Postal_StateProv'}$/i ) {
			if ($add_tax_rates) { $rate += $val;
			} else { $rate = $val if ($val > $rate);
			}
			last;
			}}}

	# Find country matched rate
	if (scalar(keys(%use_country_tax))) {
	while (($key, $val) = each (%use_country_tax)) {
		if ( $key =~ /^$NewInfo{'Ecom_ShipTo_Postal_CountryCode'}$/i ) {
			if ($add_tax_rates) { $rate += $val;
			} else { $rate = $val if ($val > $rate);
			}
			last;
			}}}
	} 
	# End find rate

	# Find before-after exceptions
	foreach (@exceptions_city) { 
	$exceptions++ if ( $_ =~ /^$NewInfo{'Ecom_ShipTo_Postal_City'}$/i ) }
	foreach (@exceptions_zipcode) { $exceptions++ if ( 
	$NewInfo{'Ecom_ShipTo_Postal_PostalCode'} =~ /^$_/i ) }
	foreach (@exceptions_state) { 
	$exceptions++ if ( $_ =~ /^$NewInfo{'Ecom_ShipTo_Postal_StateProv'}$/i ) }
	foreach (@exceptions_country) { 
	$exceptions++ if ( $_ =~ /^$NewInfo{'Ecom_ShipTo_Postal_CountryCode'}$/i ) }

	# Compute rate before or after
	if ($rate) {
		if ($tax_before_SHI) {
			if ($exceptions) {
			$tax = ($rate * $after_amount);
			$Computations{'Tax_Rule'} = "AFTER";	
			} else {
			$tax = ($rate * $before_amount);
			$Computations{'Tax_Rule'} = "BEFORE";
			}
		} else {
			if ($exceptions) {
			$tax = ($rate * $before_amount);
			$Computations{'Tax_Rule'} = "BEFORE";
			} else {
			$tax = ($rate * $after_amount);
			$Computations{'Tax_Rule'} = "AFTER";
			}
		}
	} else {		
	$tax = 0;
	}

	$Computations{'Tax_Rate'} = $rate;
	$Computations{'Tax_Rule_Exceptions'} = $exceptions;
	$Computations{'Adjusted_Tax_Amount_Before'} = sprintf "%.2f", $before_amount;
	$Computations{'Adjusted_Tax_Amount_After'} = sprintf "%.2f", $after_amount;
	$Computations{'Tax_Amount'} = sprintf "%.2f", $tax;

	# zero out tax computations if Tax Exempt / VAT sensitive
	$forcevat = 0;
	foreach (@force_VAT) {
		$forcevat++ if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'} eq $_);
		}
	unless ($forcevat) {
		if ($NewInfo{'Tax_Exempt_Status'}) {
		$Computations{'Tax_Rate'} = 0;
		$Computations{'Tax_Amount'} = sprintf "%.2f",0;
		}}
	$Computations{'Tax_Line_Override'} = 1 if ($forcevat || $NewInfo{'Tax_Exempt_Status'});	

	# set up tax string
	my($TaxRate) = ($Computations{'Tax_Rate'} * 100);
	my($AdjustedTax) = 0;
	$AdjustedTax = $Computations{'Adjusted_Tax_Amount_After'} if ($Computations{'Tax_Rule'} eq "AFTER");
	$AdjustedTax = $Computations{'Adjusted_Tax_Amount_Before'} if ($Computations{'Tax_Rule'} eq "BEFORE");
	$AdjustedTax = CommifyMoney ($AdjustedTax);
	my($Tax) = CommifyMoney ($Computations{'Tax_Amount'});
	$Computations{'Tax_Message'} = "$taxstring ";
	if ($NewInfo{'Tax_Exempt_Status'}) {
		$Computations{'Tax_Message'} .= "exempt " unless ($forcevat);
		$Computations{'Tax_Message'} .= "($NewInfo{'Tax_Exempt_Status'}) ";
		}
	$Computations{'Tax_Message'} .= "$TaxRate\% ";
	$Computations{'Tax_Message'} .= "($currency $AdjustedTax taxable)";

	# =========================================================================== #
	#                        CUSTOMIZE TAX COMPUTATION                            #
	# =========================================================================== #
	# VERY IMPORTANT : Set the Before/After Rule or line won't print              #
	# $Computations{'Tax_Rule'} = "AFTER/BEFORE";                                 #
	# VERY IMPORTANT : Use the correct Adjusted order total in your computation   #
	# NOTE: the before/after amounts reflect nonZERO TaxCode items                #
 	# NOTE: if you need to change that then reDo "initial taxable amount" above   #
	# NOTE: you can reDo those "initial" amounts based on @orders TaxCode(s)      #
	# Example: Germany has 3 rates for items, TaxCode(s) = 1, 2, 3, etc.          #
	# $before_amount = Adjusted invoice amount less any discounts (format 0.00)   #
	# $after_amount =  Adjusted invoice amount less any discounts + SHI  (0.00)   #
	# These VARS are already set and used for mail explanations                   #
	# DO NOT CHANGE : $Computations{'Initial_Taxable_Amount'};                    #
	# DO NOT CHANGE : $Computations{'Tax_Discount_Ratio'};)                       #
	# IMPORTANT : The Adjusted Tax Amt (before/after) is determined * only * by   #
	# IMPORTANT : nonZero TaxCode(s) items, and as per the Ratio nonZero to Zero  #
	# =========================================================================== #
	# These are the Variables Available to you for custom tax computation         #
	# $currency (the currency symbol)                                             #
	# $rate = rate emerging from conf tax settings (or use custom rate)           #
	# $NewInfo{'Tax_Exempt_Status'} (Value of Tax Exempt Box, if any)             #
	# =========================================================================== #
	# RETURN VARS REQUIRED : You must make these vars in your computation         #
	# $Computations{'Tax_Rate'}    (format 0.0825 - default if not specified)     #
	# $Computations{'Tax_Amount'}  (Default conf tax amt if not specified)        #
	# $Computations{'Tax_Message'} (Line item message - default if not specified) #
	# $Computations{'Tax_Rule'} = "AFTER/BEFORE"; (default if not specified)      #
	# =========================================================================== #
	# OPTIONAL VARS :                                                             #
	# $Computations{'Tax_Line_Override'} = 1; (show zero Tax line item)           #
	# $Computations{'Tax_Amt_Override'} = "<font color=red size=1>text</font>";   #
	# =========================================================================== #
	if ($use_custom_tax) {

	# Custom Tax example
	# Custom Tax example

	$Computations{'Tax_Rule'} = "AFTER";
	$Computations{'Tax_Amount'} = 19.95;
	$Computations{'Tax_Message'} = "CUSTOM $taxstring LINE ($before_amount)($after_amount)";
	$Computations{'Tax_Message'} .= "($NewInfo{'Tax_Exempt_Status'})" if ($NewInfo{'Tax_Exempt_Status'});

	# End Custom Tax
	# End Custom Tax

	}}

# END COMPUTATIONS
# END COMPUTATIONS

# TEST MODE
sub RunTestMode {
	$ErrMsg="<h4>Merchant OrderForm v2.4 is Running [Front End - Cart Collection]</h4>";
	$ErrMsg .= "The core components for the MOFcart Front End are loaded, and the core 
	script package appears to be running on the server. For further installation instructions 
	consult the <b>Installation.html</b> in your Documentation, or the online
	<a href=\"http://www.merchantorderform.com/Documentation/Installation.html\" target=\"_blank\">
	Installation.html</a> document.<p>";
	$ErrMsg .= "<li><u>Absolute Path</u>: <strong>$ENV{DOCUMENT_ROOT}</strong>";
	if ( -w "$datadirectory" ) {
	$ErrMsg .= "<li><u>orderdata</u>: $datadirectory is Writeable, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>orderdata</u>: $datadirectory <b>NOT</b> Writeable or not Found, <font color=red>problem</font>";}
	if ( -w "$infodirectory" ) {
	$ErrMsg .= "<li><u>orderinfo</u>: $infodirectory is Writeable, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>orderinfo</u>: $infodirectory <b>NOT</b> Writeable or not Found, <font color=red>problem</font>";}
	if ( -r "$accept_order_template" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $accept_order_template, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $accept_order_template, <font color=red>problem</font>";}
	if ( -r "$validation_template" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $validation_template, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $validation_template, <font color=red>problem</font>";}
	if ( -r "$validation_template_pop" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $validation_template_pop, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $validation_template_pop, <font color=red>problem</font>";}
	if ( -r "$preview_template" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $preview_template, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $preview_template, <font color=red>problem</font>";}
	if ( -r "$preview_info_template" ) {
	$ErrMsg .= "<li><u>Template</u>: Found $preview_info_template, <font color=green>okay</font>";
	} else {
	$ErrMsg .= "<li><u>Template</u>: Cannot Read or Find $preview_info_template, <font color=red>problem</font>";}
	$ErrMsg .= "<li><font color=red>Security Warning</font>: Allowed Domains is disabled in [mof.conf]" unless scalar(@ALLOWED_DOMAINS);	
	$ErrMsg .= "<li><font color=red>Security Warning</font>: Post Only is disabled in [mof.conf]" unless ($POST_ONLY);	
	&ErrorMessage($ErrMsg);
 	}

# FORMAT NUMBERS
sub CommifyNumbers {
	local $_  = shift;
	if ($alt_numbers) {	
    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
	} else {
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
	}
    	return $_;
  	}

# FORMAT MONEY
sub CommifyMoney {
	local $_  = shift;
	if ($alt_currency) {	
	    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
		local ($str);
		$str = (length ($_) - 3);
		substr ($_,$str,1) = ',';
	} else {
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
	}
    	return $_;
  	}

# FORMAT ALTERNATE per request
sub FormatAltMoney {
	local $_  = shift;
	    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
		local ($str);
		$str = (length ($_) - 3);
		substr ($_,$str,1) = ',';
    	return $_;
  	}

# FORMAT ALTERNATE per request
sub FormatAltNumbers {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1.$2/;
    	return $_;
  	}



1;
# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003
