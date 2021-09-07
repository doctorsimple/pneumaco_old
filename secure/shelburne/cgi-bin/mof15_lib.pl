# Merchant OrderForm v1.53 Cart Library, UPDATED 9/15/2000, UPDATED 10/01/2000
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

# THIS IS THE FRONT END LIBRARY FILE
# THIS IS THE FRONT END LIBRARY FILE

# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES
# IMPORTANT: YOU SHOULD ONLY BE MODIFYING THE CONFIGURATION FILES



	# CHECK ALLOWED DOMAINS
	# CHECK ALLOWED DOMAINS

sub CheckAllowedDomains {

	my ($domain_approved) = 0;
	my ($domain_referred) = $ENV{'HTTP_REFERER'};
	$domain_referred =~ tr/A-Z/a-z/;

  	foreach (@ALLOWED_DOMAINS) {
               
     		if ($domain_referred =~ /$_/) { 
		$domain_approved++;	
		}
	   	}

	unless ($domain_approved) {

		$ErrMsg="This is not an authorized input area <br>";
		$ErrMsg=$ErrMsg . "$ENV{'HTTP_REFERER'} <p>";

		$ErrMsg=$ErrMsg . "These are the only authorized input areas:<br>";

		foreach (@ALLOWED_DOMAINS) {
		$ErrMsg=$ErrMsg . "<a href=\"$_\">$_</a><br>";
		}

		$ErrMsg=$ErrMsg . "<p>Contact Web Site Developer about this Error <br>";

		&ErrorMessage($ErrMsg);
		}

	}




	# GET QUERY STRING INPUT - PROCESS TO @NewOrder
	# GET QUERY STRING INPUT - PROCESS TO @NewOrder

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

		$ErrMsg="Product Order Data Not Available<br>";
		$ErrMsg=$ErrMsg . "Contact Web Site Developer about this Error<br>";
		$ErrMsg=$ErrMsg . "String: $qry{'order'}<br>" if $qry{'order'};
		$ErrMsg=$ErrMsg . "Check the referring input page for accuracy<br>";
		$ErrMsg=$ErrMsg . $ENV{'HTTP_REFERER'};

		&ErrorMessage($ErrMsg) unless ( int ($qty) > 0);
		&ErrorMessage($ErrMsg) unless ($item);
		&ErrorMessage($ErrMsg) unless ( $price > 0);

		$ErrMsg="This Input Is Not Allowed<br>";
		$ErrMsg=$ErrMsg . "Contact Web Site Developer about this Error<br>";
		$ErrMsg=$ErrMsg . "Query String Input is Disabled in this Installation<br>";
		$ErrMsg=$ErrMsg . "Merchant OrderForm is accepting Post Input only<br>";

		&ErrorMessage($ErrMsg) if ($POST_ONLY);
		
		return @NewOrder;

		}

	}




	# GET FORM INPUT - PROCESS TO @NewOrder
	# GET FORM INPUT - PROCESS TO @NewOrder

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

	my ($fieldadjust, $adjprice, $adjdesc);
	my (%adjflds) = ();

	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);

	foreach $pair (@pairs) {

	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/"/ /;
	$value =~ tr/\r\n/ /s;
	$frm{$name} = $value;

    	}




		# UPDATING CART MODE
		# UPDATING CART MODE

		if ($frm{'postmode'} eq "UPDATE") {

			my (@QtyList) = ();
			my ($num);
		
			# Build items submitted list
			# Build items submitted list

			foreach $pair (@pairs) {

			($name, $value) = split(/=/, $pair);
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			$value =~ tr/"/ /;

				if ($name =~ /\bquantity_/) {
				push (@QtyList, substr ($name,9) ) if ( int ($value) > 0 );
				}

			}

			# Group associated input
			# Group associated input

		foreach $num (@QtyList) {

			$id = "quantity_" . $num;			
			$qty = int ($frm{$id});	

			$id = "product_" . $num;
			($item, $desc, $price, $ship, $taxit) = split(/$delimit/, $frm{$id});

			unless ($frm{$id}) {
			$ErrMsg="Product Order Data Not Available For: $id<br>";
			$ErrMsg=$ErrMsg . "Check the referring input page for accuracy<br>";
			$ErrMsg=$ErrMsg . $ENV{'HTTP_REFERER'};
			&ErrorMessage($ErrMsg);
			}
	
		push (@NewOrder, "$qty$delimit$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit");
		$msg_i++;

		}




		# DELETING CART MODE
		# DELETING CART MODE

		} elsif ($frm{'postmode'} eq "DELETE") {

			@orders = ();
			@NewOrder = ();



		
		# PREVIEW CART MODE
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
		# PROCESSING SINGLEPOST MODE

		} elsif ($frm{'postmode'} eq "SINGLEPOST") {

		unless ($frm{'order'}) {
		$msg_null="Cannot Find Selected Order Information<br>";
		$msg_null=$msg_null . "Check To Make Sure an Item Was Selected";
		&ValidationMessage("$msg_null");
		}

		# set up any price adjustments
		foreach $fieldadjust (@field_adjustments) {
		$adjflds{$fieldadjust} = $frm{$fieldadjust} if ($frm{$fieldadjust});
		}

		# get the single order hidden input
		($item, $desc, $price, $ship, $taxit) = split(/$delimit/, $frm{'order'});

			# validating user input required
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

						}
		
					}

				}

			}
	
		}

		&ValidationMessage(@missingfields) if scalar(@missingfields);

		if ($frm{'quantity'} > 0) {	$qty = int ($frm{'quantity'});
		} else { $qty = 1; }

	
			# combining user input - adjusting price
			# combining user input - adjusting price

   		while (($key, $val) = each (%product_fields)) { 

			if  ( $frm{$key} ) {

				if ($adjflds{$key}) {

				($adjdesc, $adjprice) = split(/$delimit/, $adjflds{$key});

				$price += $adjprice;

					if ($adjprice) {
					$desc = $desc . "\|" . "$val" . "::" . "$adjdesc $currency $adjprice";

					} else {
					$desc = $desc . "\|" . "$val" . "::" . "$adjdesc";

					}

				} else {
				$desc = $desc . "\|" . "$val" . "::" . "$frm{$key}";
		
				}
			
			}

		}

		$price = sprintf "%.2f", $price;
		push (@NewOrder, "$qty$delimit$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit");
		$msg_i++;




		# PROCESSING CHECKBOXES MODE
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

			}

			}



		# PROCESSING QUANTITYBOXES MODE
		# PROCESSING QUANTITYBOXES MODE

		} elsif ($frm{'postmode'} eq "QUANTITYBOXES") {

			my (@QtyList) = ();
			my ($num);
		
			# Build items submitted list
			# Build items submitted list

			foreach $pair (@pairs) {

			($name, $value) = split(/=/, $pair);
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			$value =~ tr/"/ /;

				if ($name =~ /\bquantity/) {
				push (@QtyList, substr ($name,8) ) if ( int ($value) > 0 );
				}

			}

			# set up any price adjustments
			# set up any price adjustments

			foreach $num (@QtyList) {

				foreach $fieldadjust (@field_adjustments) {

					$id = "$fieldadjust" . $num;
					$adjflds{$id} = $frm{$id} if ($frm{$id});
				}

			}

			# Validate user_input required
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

							}
		
						}

					}

				}
	
			}

			}

			&ValidationMessage(@missingfields) if scalar(@missingfields);

			# Group associated input - adjust price
			# Group associated input - adjust price

		foreach $num (@QtyList) {

			$id = "quantity" . $num;			
			$qty = int ($frm{$id});	

			$id = "order" . $num;
			($item, $desc, $price, $ship, $taxit) = split(/$delimit/, $frm{$id});

			unless ($frm{$id}) {

			$msg_null="Cannot Find Selected Order Information<br>";
			$msg_null=$msg_null . "Check To Make Sure an Item Was Selected";
			&ValidationMessage("$msg_null");
			}
	
			while (($key, $val) = each (%product_fields)) { 

				$id = $key . $num;

				if ($frm{$id}) {

					if ($adjflds{$id}) {

					($adjdesc, $adjprice) = split(/$delimit/, $adjflds{$id});

					$price += $adjprice;

						if ($adjprice) {
						$desc = $desc . "\|" . "$val" . "::" . "$adjdesc $currency $adjprice";

						} else {
						$desc = $desc . "\|" . "$val" . "::" . "$adjdesc";

						}

					} else {
					$desc = $desc . "\|" . "$val" . "::" . "$frm{$id}";
		
					}

			   	}

			}

		$price = sprintf "%.2f", $price;
		push (@NewOrder, "$qty$delimit$item$delimit$desc$delimit$price$delimit$ship$delimit$taxit");
		$msg_i++;

		}



		# PROCESSING CUSTOM MODE
		# PROCESSING CUSTOM MODE

		} elsif ($frm{'postmode'} eq "CUSTOM") {


			# Build Custom processes for input here
			# Build Custom processes for input here
			# You Must Return @NewOrder with this process
			# @NewOrder must be in a 6 Field format
			# Then you can use <mof.cgi> to work any other processes needed
			# This section just needs to present <mof.cgi> with 6 Field @NewOrder

			$ErrMsg="Designer has set a Custom Input Mode<br>";
			$ErrMsg=$ErrMsg . "Designer has set a Custom Input Mode<br>";
			$ErrMsg=$ErrMsg . "Designer has set a Custom Input Mode<br>";
			$ErrMsg=$ErrMsg . "Designer has set a Custom Input Mode";
			&ErrorMessage($ErrMsg);	

		
			# MODE NOT RECOGNIZED
			# MODE NOT RECOGNIZED

		} else {

		$ErrMsg="Unable to determine Input Mode<br>";
		$ErrMsg=$ErrMsg . "postmode: $frm{'postmode'}<br>";
		$ErrMsg=$ErrMsg . "Contact the Web Developer<br>";
		$ErrMsg=$ErrMsg . "Referring URL:<br> $ENV{'HTTP_REFERER'}";
		&ErrorMessage($ErrMsg);

		} 


	# Allow the AcceptOrders page if Update or Delete Cart is empty
	# Else trigger a No Items Selected validation message

	unless ($frm{'postmode'} eq "UPDATE" || $frm{'postmode'} eq "DELETE" || $frm{'postmode'} eq "PREVIEW") {
	$msg_null="Cannot Find Item(s) Selected or Quantities<br>";
	$msg_null=$msg_null . "<ul><u>Suggestions</u>:";
	$msg_null=$msg_null . "<li>Make sure item was checked or selected";
	$msg_null=$msg_null . "<li>Make sure quantities were entered to select</ol>";
	&ValidationMessage("$msg_null") unless scalar(@NewOrder);
	}

	return @NewOrder;

	}
	



	# SET DATE
	# SET DATE

sub SetDateVariable {

	local (@months) = ('January','February','March','April','May','June','July',
			'August','September','October','November','December');

	local (@days) = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
 	local ($sec,$min,$hour,$mday,$mon,$year,$wday) = (localtime(time))[0,1,2,3,4,5,6];
	$year += 1900;	

 	$Date = "$days[$wday], $months[$mon] $mday, $year";
 	$ShortDate = sprintf("%02d%1s%02d%1s%04d",$mon+1,'/',$mday,'/',$year);
 	$Time = sprintf("%02d%1s%02d%1s%02d",$hour,':',$min,':',$sec);

	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour<12);
	$ShortTime="12:".sprintf("%02d",$min).":".sprintf("%02d",$sec)." AM" if($hour==0);
	$ShortTime=$hour.":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour==12);
	$ShortTime=($hour-12).":".sprintf("%02d",$min).":".sprintf("%02d",$sec)." PM" if($hour>12);

	 }



	# MAKE GMT UNIX TIME
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




	# CHECK FOR COOKIE
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
	# SET NEW COOKIE

sub MakeCookie {

	my ($name_for_cookie, $ID) = @_;

	# Always print the cookie before the Content-Type header

	if ($holdtime_data && $name_for_cookie eq $cookiename_OrderID) {
				
	# keep cookie specified hours
	$expirestime = &MakeUnixTime($holdtime_data * 3600);
	print "Set-Cookie: $name_for_cookie=$ID;expires=$expirestime\n";	

	} elsif ($holdtime_info && $name_for_cookie eq $cookiename_InfoID) {
				
	# keep cookie specified hours
	$expirestime = &MakeUnixTime($holdtime_info * 3600);
	print "Set-Cookie: $name_for_cookie=$ID;expires=$expirestime\n";	

	} else {

	# expire cookie when browser closed
	print "Set-Cookie: $name_for_cookie=$ID\n";
			
	}


  }




	# MAKE ORDER ID NUMBER
	# MAKE ORDER ID NUMBER

sub GenerateOrderID {

	# generates OrderID based on date, time, process number

    	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time());
	$OrderID = sprintf("%02d%02d%02d%02d%02d%02d%05d",$year+=1900,$mon+1,$mday,$hour,$min,$sec,$$);

  return $OrderID;
  }



	# MAKE INFO ID NUMBER
	# MAKE INFO ID NUMBER

sub GenerateInfoID {

	# generates InfoID based on date, time, process number

    	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time());
	$InfoID = sprintf("%02d%02d%02d%02d%02d%02d%05d",$year+=1900,$mon+1,$mday,$hour,$min,$sec,$$);

  return $InfoID;
  }




	# READ DATA FILE
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
		$ErrMsg = "Unable to Locate-Make Data File: $FileNumber";
		&ErrorMessage($ErrMsg);
		}

		close(FILE);

		}

	}





	# PROCESS DATA FILE
	# PROCESS DATA FILE

sub ProcessDataFile {

	# processes global @orders for dupes
	# retotals if dupes found
	# otherwise adds new item(s) to @orders

	$msg_i=0;
	$msg_d=0;
	local ($i);
	local ($match, $New, $Old);
	local ($NewStr, $OldStr, $NewQty);
	local ($n1, $n2, $n3, $n4, $n5, $n6);
	local ($o1, $o2, $o3, $o4, $o5, $o6);

    	foreach $New (@NewOrder) {

   	($n1, $n2, $n3, $n4, $n5, $n6) = split(/$delimit/, $New);
	
	$NewStr = $n2 . $n3 . $n4 . $n5 . $n6;

		$i = 0;

		foreach $Old (@orders) {

   		($o1, $o2, $o3, $o4, $o5, $o6) = split(/$delimit/, $Old);

		$OldStr = $o2 . $o3 . $o4 . $o5 . $o6;
	
			if ($NewStr eq $OldStr) {
					
			$match++;

			$msg_d++;

			$NewQty = ($n1 + $o1);
					
			$orders[$i] = "$NewQty$delimit$o2$delimit$o3$delimit$o4$delimit$o5$delimit$o6";

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





	# WRITE DATA FILE
	# WRITE DATA FILE

sub WriteDataFile {

	# Writing out the data file adds chr(10) to each line
	# Also adds chr(10) to last line
	# Only the Write puts this, and only the Read chops it
	# All arrays work free of that last line chr(10)

	my ($FileNumber) = @_;
	$FileNumber =~ s/[^A-Za-z0-9._-]//g;
	my ($line);

	$path = $datadirectory . $FileNumber . "\.$data_extension";

	unless (open (FILE, ">$path") ) { 

		$ErrMsg = "Unable to Write To Orders Data File: $FileNumber";
		&ErrorMessage($ErrMsg);
		}

		foreach $line (@orders) {
		print FILE "$line\n";
		}
	
	close(FILE);
	chmod (0777, $path) if ($set_ssl_chmod);
	}




	# PREVIEW LIBRARIES -------->
	# PREVIEW LIBRARIES -------->

	# MAKE LIST OF FIELDS NEEDED
	# MAKE LIST OF FIELDS NEEDED

sub CheckFieldsNeeded {

	my ($allow_ship) = 0;
	$allow_ship++ if (scalar(@use_shipping));
	$allow_ship++ if (scalar(keys(%use_method)));

	# This is a simple config check to see if anything is being used
	# processes after the Preview branching will CheckUsingInfoFields
	# handling / discount / global_tax / default do not require input
	# They are computed from config settings
	# Anything requiring user input must be declared in this list 
	# Even if it will not be validated
	# MOF uses this list to know what should be expected from the config settings

	# Any of the 14 shipping fields being used ?
	# Three of these are used for tax matching
	
	while (($key, $val) = each (%shipping_destination_fields)) {
		push (@UsingInfoFields, $key) if ($val);	
		}


	if ($allow_ship) {

	# Is Insurance being used ?
	push (@UsingInfoFields, "Compute_Insurance") if scalar(keys(%use_insurance));

	}

	# Is the Coupon Discount being used ?
	push (@UsingInfoFields, "Compute_Coupons") if scalar(@use_coupons);

	# Are user selected shipping methods being used ?
	push (@UsingInfoFields, "Compute_Shipping_Method") if (scalar(keys(%use_method)));

	return @UsingInfoFields;
	}




	# MAKE NULL LIST FOR %NewInfo
	# MAKE NULL LIST FOR %NewInfo

sub MakeNullList {

	# Makes a global %NewInfo list with all possible Flags, Fields
	# This matches the MasterInfoList

	&GetMasterInfoList;
	foreach $_ (@MasterInfoList) {$NewInfo{$_} = ""}
	return %NewInfo;
	}




	# MAKE MASTER LIST 
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
	Ecom_ShipTo_Telecom_Fax_Number,
	Ecom_ShipTo_Postal_StateProv,
	Ecom_ShipTo_Postal_Name_First,
	Ecom_ShipTo_Postal_City,
	Ecom_ShipTo_Postal_County,
	Ecom_ShipTo_Online_Email,
	Ecom_ShipTo_Postal_PostalCode,
	Ecom_ShipTo_Postal_Name_Prefix,
	Ecom_ShipTo_Postal_CountryCode,
	Ecom_ShipTo_Postal_Name_Middle,
	Ecom_ShipTo_Postal_Street_Line1,
	Ecom_ShipTo_Postal_Street_Line2,
	Ecom_ShipTo_Postal_Company,
	Ecom_ShipTo_Postal_Name_Last,
	Compute_Shipping_Method,
	Compute_Insurance,
	Compute_Coupons
	)

	}




	# READ NEW INFO FROM PREVIEW INFORMATION PAGE POST
	# READ NEW INFO FROM PREVIEW INFORMATION PAGE POST
	
sub ReadNewInfo {

	&GetMasterInfoList;

	foreach $_ (@MasterInfoList) {
	$NewInfo{$_} = $frm{$_};
	}

	return %NewInfo;
	}




	# WRITE PREVIEW INFO FILE
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

		$ErrMsg = "Unable to Write To Preview Information File: $FileNumber";
		&ErrorMessage($ErrMsg);
		}

		while (($key, $val) = each (%NewInfo)) {
		print FILE "$key\|$val\n";
		}
	
	close(FILE);
	}




	# READ PREVIEW INFO FILE
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
	# CHECK WHAT FIELDS ARE COMPLETE	

sub CheckUsingInfoFields {

	# This checks what info we actually have against what info is expected/needed
	# The list of what is expected is already created 

		# Checking required input
		# Checking required input	


	foreach $_ (@UsingInfoFields) {

		# What shipping fields required ?
		if ($shipping_destination_fields{$_}) {
	
			unless (length($NewInfo{$_}) >= ($shipping_destination_fields{$_})) {
			$MissingInfoFields{$_} = "Missing" if (length($NewInfo{$_})==0);
			$MissingInfoFields{$_} = "Incomplete" if (length($NewInfo{$_})>0);

			}

		}


		# Is Coupon Input required ?
		if ($_ eq "Compute_Coupons") {

			unless (length($NewInfo{'Compute_Coupons'}) > 0 ) {
			$MissingInfoFields{'Compute_Coupons'} = "Incomplete";	
			}
		}


		# Is Insurance Input required ?
		if ($_ eq "Compute_Insurance") {

			unless (length($NewInfo{'Compute_Insurance'}) > 0 ) {
			$MissingInfoFields{'Compute_Insurance'} = "Incomplete";	
			}
		}


		# Are you using User Selected Shipping Method ?
		if ($_ eq "Compute_Shipping_Method") {

			unless (length($NewInfo{'Compute_Shipping_Method'}) > 0 ) {
			$MissingInfoFields{'Compute_Shipping_Method'} = "Incomplete";	
			}
		}


	} # End foreach in @UsingInfoFields list


	# validate any Email addr whether required or not
	# to prevent sendmail from crashing script w/ bogus addr

	if ($NewInfo{'Ecom_ShipTo_Online_Email'}) {
	unless ($NewInfo{'Ecom_ShipTo_Online_Email'} =~ /^[\w\-\.]+\@[\w\-]+\.[\w\-\.]+\w$/) {
      $MissingInfoFields{'Ecom_ShipTo_Online_Email'} = "Incomplete";}	
	}

	return %MissingInfoFields;
	}




	# VALIDATE PREVIEW INFO FIELDS
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

		$ErrMsg = "Unable to Read Drop Box List File: $FilePath";
		&ErrorMessage($ErrMsg);
		}

		@TempList = <FILE>;
		close(FILE);
		chop (@TempList);

		if ($NewInfo{$FieldName}) {

		$match = "value=" . $NewInfo{$FieldName} . ">";

  			foreach $_ (@TempList) {

				# if list has "selected" flag as default
				# if list has "selected" flag as default

				if ( $_ =~ /\bselected\b/i ) {
				
				($selected, $line) = ($_, $itm);

				$TempList[$itm] =~ ( s/\bselected\b//i );
				$TempList[$itm] =~ ( s/  / / );
				}

				if ($_ =~ /$match/i) {

				$match_lock++;
				$TempList[$itm] =~ ( s/$match/selected $match/i );
	
				}

			$itm++;

			} 

			# return to default if no match
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
	# GET TEMPLATE FILE

sub GetTemplateFile {

	my ($FilePath, $Type) = @_;
	my (@template) = ();
	my ($line, $switch) = ("",0);

	unless (open (FILE, "$FilePath") ) { 
 
		$ErrMsg = "Unable to Read Template File: $Type";
		&ErrorMessage($ErrMsg);
		}

	@template = <FILE>;

		foreach $line (@template) {

		$switch=1 if ($line =~ /$insertion_marker/i);
		
			if ($switch) {

			push (@footer, $line);

			} else {

			push (@header, $line);

			}

		}


	}





	# PASS ERROR MESSAGE
	# PASS ERROR MESSAGE

sub ErrorMessage {

	my ($Err) = @_;
	my ($gmt) = &MakeUnixTime(0);	

	print "Content-Type: text/html\n\n";
	print "<html><head><title>MOF v1.53 Error</title></head>
   		 <body bgcolor=#FFFFFF text=#000000>";

	print "<h3>Merchant OrderForm v1.53 Data Processing Error</h3>";
      print "<h4>$Err</h4>\n";

	print "Please Contact: <a href=\"mailto:$merchantmail\">$merchantmail</a><p>" if ($merchantmail);

	print "<u>Data Processing Information Available</u><br>";
	print "<li>Local Time: $Date $Time<br>";
	print "<li>GMT Time: $gmt";
	print "<li>Referring URL: $ENV{'HTTP_REFERER'}" if ($ENV{'HTTP_REFERER'});
	print "<li>Server Name: $ENV{'SERVER_NAME'}" if ($ENV{'SERVER_NAME'});
	print "<li>Server Protocol: $ENV{'SERVER_PROTOCOL'}" if ($ENV{'SERVER_PROTOCOL'});
	print "<li>Server Software: $ENV{'SERVER_SOFTWARE'}" if ($ENV{'SERVER_SOFTWARE'});
	print "<li>Gateway: $ENV{'GATEWAY_INTERFACE'}" if ($ENV{'GATEWAY_INTERFACE'});
	print "<li>Remote Host: $ENV{'REMOTE_HOST'}" if ($ENV{'REMOTE_HOST'});
	print "<li>Remote Addr: $ENV{'REMOTE_ADDR'}" if ($ENV{'REMOTE_ADDR'});
	print "<li>Remote User: $ENV{'REMOTE_USER'}" if ($ENV{'REMOTE_USER'});
	print "<p><font face=\"Arial,Helvetica\" size=1 color=gray>";
	print "<strong>Merchant OrderForm v1.53 \© Copyright ";
	print "<a href=\"http://www.io.com/~rga/scripts/\">RGA</a></strong>\n";
	print "</body></html>";
	exit;	
	}




	# VALIDATION MESSAGE
	# VALIDATION MESSAGE

sub ValidationMessage {

	my (@MissingFields) = @_;
	my ($gmt) = &MakeUnixTime(0);	
	my ($field);

	&GetTemplateFile($validation_template,"Validation File"); 

	print "Content-Type: text/html\n\n";
	print "@header \n\n";

	print "<ol>$validate_font_s \n";
	
	foreach $field (@MissingFields) {

		print "<li>$field  \n";

		}

	print "$validate_font_e </ol> <p> \n";

	unless ($STOPCART) {
	print "<a href=\"$ENV{'HTTP_REFERER'}\"><strong>Click Here</strong></a> \n";
	print "to return to the previous page.<p>";
	}
	
	print "<font size=2> \n";
	print "Local Time: $Date $Time<br> \n";
	print "GMT Time: $gmt<p> \n";

	print "@footer \n\n";
	exit;	
	}



	# COMPUTATION LIBRARIES ------------>
	# COMPUTATION LIBRARIES ------------>


	# POPULATE %COMPUTATIONS WITH ANSWERS
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

		# prevent zero amount previews from computing
		# prevent zero amount previews from computing

	unless ($Computations{'Primary_Price'} > 0) {
	$STOPCART = "Your Cart Items Total $currency $Computations{'Primary_Price'}<br>";
	$STOPCART = $STOPCART . "Cannot Process Zero Price Inovices<br>";
	$STOPCART = $STOPCART . "Put Something that Cost Money in your cart";
	&ValidationMessage("$STOPCART");
	}


		# (3) Compute Primary Discount, sub total

	$Computations{'Primary_Discount'} = &ComputeDiscount if scalar(@use_discount);
 	$Computations{'Sub_Primary_Discount'} = ($Computations{'Primary_Price'})-($Computations{'Primary_Discount'});
 	$Computations{'Sub_Primary_Discount'} = sprintf "%.2f", $Computations{'Sub_Primary_Discount'};


		# (4) Compute Coupon Discount, sub total

	$Computations{'Coupon_Discount'} = &ComputeCouponDiscount if scalar(@use_coupons);
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


		# (7) Insurance Charges = selected amount from Preview Information or custom (1000000)

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

		$allow_tax++ if ($use_global_tax);
		$allow_tax++ if (scalar(keys(%use_city_tax)));
		$allow_tax++ if (scalar(keys(%use_county_tax)));
		$allow_tax++ if (scalar(keys(%use_zipcode_tax)));
		$allow_tax++ if (scalar(keys(%use_state_tax)));
		$allow_tax++ if (scalar(keys(%use_country_tax)));
		&ComputeTax if ($allow_tax);


		# (12) Compute final amount
		# (12) Compute final amount

		$Computations{'Final_Amount'} = $Computations{'Sub_Final_Discount'};
		$Computations{'Final_Amount'} += $Computations{'Tax_Amount'};
		$Computations{'Final_Amount'} += $Computations{'Combined_SHI'};
		$Computations{'Final_Amount'} = sprintf "%.2f", $Computations{'Final_Amount'};

 } 

	


	# COMPUTE DISCOUNT
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
		$Computations{'Primary_Discount_Status'} = $msg;

		} else {
	      $discount = ( $rate * $price);
		$msg_rate = (100 * $rate);
		$msg = "$msg_rate\% each $currency 1.00";
		$Computations{'Primary_Discount_Status'} = $msg;

		}

	
	} elsif ($mode =~ /\bquantity\b/i) {

		if ($increment) {
		$repeats = ( int ( $items / $increment ) );
      	$discount = ( $rate * $repeats ) unless ( $items < $increment );
		$Computations{'Primary_Discount_Status'} = "$currency $rate each $increment item(s)";

		} else {
	      $discount = ( $rate * $items );
		$Computations{'Primary_Discount_Status'} = "$currency $rate each item";

		}

	} elsif ($mode =~ /\bcustom\b/i) {

	# CUSTOM DISCOUNT ------------>
	# Variables Available --------> 
	# $currency (the currency symbol)
	# $price (Price of all products before any computations)
	# $items (total number of products ordered)
	# Return: $discount
	# Make: $Computations{'Primary_Discount_Status'} = "display message"


		# Example of custom discount, uneven schema
		# Using discounts per amount of purchase

		# Custom Discount Code Starts Here
		# Custom Discount Code Starts Here
			foreach (@orders) {
				($thisqty, $thisitem, $desc, $thisprice, $ship, $taxit) = split(/$delimit/);
				if ($ship==2)
				 {$Discount_Eligible_Items+=$thisqty}
			}
		
		
		
		
		if ($Discount_Eligible_Items==2)
			{$discount=$price*.1;$Computations{'Primary_Discount_Status'}="for Quantity 10%";}
		elsif ($Discount_Eligible_Items==3)
			{$discount=$price*.15;$Computations{'Primary_Discount_Status'}="for Quantity  15%";}
		elsif ($Discount_Eligible_Items==4)
			{$discount=$price*.20;$Computations{'Primary_Discount_Status'}="for Quantity  20%";}
		elsif ($Discount_Eligible_Items==5)
			{$discount=$price*.25;$Computations{'Primary_Discount_Status'}="for Quantity  25%";}
		elsif ($Discount_Eligible_Items==6)
			{$discount=$price*.30;$Computations{'Primary_Discount_Status'}="for Quantity  30%";}
		elsif ($Discount_Eligible_Items==7)
			{$discount=$price*.33;$Computations{'Primary_Discount_Status'}="for Quantity  33%";}
		elsif ($Discount_Eligible_Items==8)
			{$discount=$price*.35;$Computations{'Primary_Discount_Status'}="for Quantity  35%";}
		elsif ($Discount_Eligible_Items==9)
			{$discount=$price*.37;$Computations{'Primary_Discount_Status'}="for Quantity  37%";}
		elsif ($Discount_Eligible_Items>=10)
			{$discount=$price*.4;$Computations{'Primary_Discount_Status'}="for Quantity  40%";}
		
		

		#} else { 
		#$discount = 75;
		#$Computations{'Primary_Discount_Status'} = "Quantity Discount $currency 75.00";



		# Custom Discount Code Ends Here
		# Custom Discount Code Ends Here
	

	}

	$discount = sprintf "%.2f", $discount;
  	return $discount;	
 	}



	# COMPUTE COUPON DISCOUNT
	# COMPUTE COUPON DISCOUNT

sub ComputeCouponDiscount {

	my ($coupon_discount) = 0;
	my (@TempList) = ();
	my ($code, $rate, $msg, $msg_rate);
	my ($mode) = $use_coupons[0];
	my ($msg_rate, $msg);

	my ($price) = $Computations{'Primary_Price'};
	my ($items) = $Computations{'Primary_Products'};

	unless (open (FILE, "$coupon_file") ) { 
		$ErrMsg = "Unable to Read Coupon File";
		&ErrorMessage($ErrMsg);
		}

		flock (FILE,2) if ($lockfiles);
		@TempList = <FILE>;
		close(FILE);
		chop (@TempList);

		foreach $_ (@TempList) {

		($code, $rate, $affrate) = split(/\|/, $_);

			if ($NewInfo{'Compute_Coupons'} =~ /\b$code\b/i) {

				if ($mode =~ /\bpercent\b/i) {
				
					$msg_rate = ($rate * 100);
					$msg = "$msg_rate\% For $code Valid";
					$Computations{'Coupon_Discount_Status'} = $msg;
					$Computations{'Coupon_Affiliate_Rate'} = $affrate;
					$Computations{'Coupon_Cust_Rate'} = $rate;
					$coupon_discount = ( $rate * $price );

				} elsif ($mode =~ /\bdollar\b/i) {

					$msg = "$currency $rate For $code Valid";
					$Computations{'Coupon_Discount_Status'} = $msg;
					$Computations{'Coupon_Affiliate_Rate'} = $affrate;
					$Computations{'Coupon_Cust_Rate'} = $rate;
					$coupon_discount = ( $rate * $price );
					$coupon_discount = ( $rate );
					
				}


			}


		}

	$Computations{'Coupon_Discount_Status'} = "Discount For $NewInfo{'Compute_Coupons'} Invalid" unless ($msg);
	$coupon_discount = sprintf "%.2f", $coupon_discount;
	return $coupon_discount;
	}



	# COMPUTE HANDLING
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
		$Computations{'Handling_Status'} = $msg;

		} else {
	      $handling = ( $rate * $price );
		$msg_rate = (100 * $rate);
		$msg = "$msg_rate \% each $currency 1.00";
		$Computations{'Handling_Status'} = $msg;
	

		}
	
	} elsif ($mode =~ /\bquantity\b/i) {

		if ($increment) {
		$repeats = ( int ( $items / $increment ) );
      	$handling = ( $rate * $repeats ) unless ( $items < $increment );
		$Computations{'Handling_Status'} = "$currency $rate each $increment item(s)";

		} else {
	      $handling = ($rate * $items);	
		$Computations{'Handling_Status'} = "$currency $rate each item";

		}

	} elsif ($mode =~ /\bcustom\b/i) {


	# CUSTOM HANDLING  ------------>
	# Variables Available ---------> 
	# $price (Sub Total after all discounts computed)
	# $items (total number of products ordered)
	# Return: $handling
	# Make: $Computations{'Handling_Status'} = "display message"

		# Example of custom handling, uneven schema
		# Using handling per number of products purchased

		# Custom Handling Code Starts Here
		# Custom Handling Code Starts Here

		if ( $items < 5 ) { 
		$handling = 2.5;
		$Computations{'Handling_Status'} = "Quantity $currency 2.50";

		} elsif ( $items < 10 ) { 
		$handling = 4.5;
		$Computations{'Handling_Status'} = "Quantity $currency 4.50";

		} else { 
		$handling = 0;
		$Computations{'Handling_Status'} = "No Handling Charges";

		}

		# Custom Handling Code Ends Here
		# Custom Handling Code Ends Here
	

	}

	$handling = sprintf "%.2f", $handling;
  	return $handling;	
 	}



	# COMPUTE INSURANCE
	# COMPUTE INSURANCE

sub ComputeInsurance {

	# This computation is dependent on $Computations{'Sub_Final_Discount'}
	# Which is the final price to work with after all discounts - or -
	# dependent on $Computations{'Primary_Products'} for overall number of items ordered
	# If you set up a No (0) Yes (1000000) then the Custom computation will trigger
	# Otherwise, any insurance settings will be computed based on face value of your array settings

	my ($insurance) = 0;
	my ($price) = $Computations{'Sub_Final_Discount'};
	my ($items) = $Computations{'Primary_Products'};

	if ($NewInfo{'Compute_Insurance'} == 1000000) {

	# CUSTOM INSURANCE  ------------>
	# Variables Available ---------> 
	# $price (Sub Total after all discounts computed)
	# $items (total number of products ordered)
	# Return: $insurance
	# Make: $Computations{'Insurance_Status'} = "display message"

	# Custom Insurance Code Starts Here
	# Custom Insurance Code Starts Here

		
	$insurance = 22.95;
	$Computations{'Insurance_Status'} = "Custom Insurance";


		# Custom Insurance Code Ends Here
		# Custom Insurance Code Ends Here


	} else {

	$insurance = $NewInfo{'Compute_Insurance'};

		while (($key, $val) = each (%use_insurance)) {
		$Computations{'Insurance_Status'} = $key if ($NewInfo{'Compute_Insurance'} == $val);
		}

	}

	$insurance = sprintf "%.2f", $insurance;
  	return $insurance;	
  	}





	# COMPUTE DEFAULT SHIPPING
	# COMPUTE DEFAULT SHIPPING

sub ComputeDefaultShipping {

	# use config settings (mode,domestic-rate,foreign-rate,increment)
	# if increment not set, defaults to 1 dollar/pound(relative)
	# This computation is dependent on $Computations{'Sub_Final_Discount'}
	# Which is the final price to work with after all discounts
	# or if using 'weight' mode it uses sum of (weight * quantity) of all products ordered
	# Shipping is based on Amount after all discounts

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
	}
	}	
	}

	if (scalar(@domestic_state)) {
	$use_domestic++;
		
	foreach (@domestic_state) {

	if ($NewInfo{'Ecom_ShipTo_Postal_StateProv'} =~ /\b$_\b/i) {
	$Computations{'Domestic_State'} = $NewInfo{'Ecom_ShipTo_Postal_StateProv'};
	$is_domestic++;
	}
	}	
	}

	if (scalar(@domestic_country)) {
	$use_domestic++;
		
	foreach (@domestic_country) {

	if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'} =~ /\b$_\b/i) {
	$Computations{'Domestic_Country'} = $NewInfo{'Ecom_ShipTo_Postal_CountryCode'};
	$is_domestic++;
	}
	}	
	}

	$Computations{'Is_Domestic'} = $is_domestic;
	$Computations{'Use_Domestic'} = $use_domestic;


		# what rate to use
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
		# Compute the rate

	if ($mode =~ /\bamount\b/i) {

		if ($rate) {

		$shipping = ( $rate * ( int ( $sub_price / $increment ) ) );

		$msg_rate = $rate;
		$msg = "$Computations{'Shipping_Status'} ";
		$msg = $msg . "Shipping $currency $msg_rate each $currency $increment";
		$Computations{'Shipping_Message'} = $msg;

			if ($use_domestic && !$is_domestic) {
				
			if ($shipping < $minimum_foreign) {
			$shipping = $minimum_foreign;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Charge";
			}

			} else {

			if ($shipping < $minimum_domestic) {
			$shipping = $minimum_domestic;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Charge";
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
		$msg = $msg . "Shipping $currency $rate each $increment $weight ";
		$msg = $msg . "For $Computations{'Total_Weight'} $weight ";
		$Computations{'Shipping_Message'} = $msg;

			if ($use_domestic && !$is_domestic) {

			if ($shipping < $minimum_foreign) {
			$shipping = $minimum_foreign;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Charge";
			}

			} else {

			if ($shipping < $minimum_domestic) {
			$shipping = $minimum_domestic;
			$Computations{'Shipping_Message'} = "Minimum $Computations{'Shipping_Status'} Shipping Charge";
			}

			}

		} else {
		$shipping =0;
		}




	} elsif ($mode =~ /\bcustom\b/i) {

	# CUSTOM DEFAULT SHIPPING ------------>
	# Variables Available (local) --------> 
	# $sub_price (Sub Total after all discounts computed)
	# $items (total number of products ordered)
	# $total_weight (if using ship codes and 'weight' mode)
	# $use_domestic (are there any domestic settings)
	# $is_domestic (if domestic/foreigh enabled is shipping domestic)

	# Global results: $Computations{'Total_Weight'}
	# Global results: $Computations{'Use_Domestic'} positive if enabled
	# Global results: $Computations{'Is_Domestic'} if enabled and matches domestic settings
	# Global results: $Computations{'Domestic_City'} if found
	# Global results: $Computations{'Domestic_State'} if found
	# Global results: $Computations{'Domestic_Country'} if found
	# Return: $shipping
	# Make: $Computations{'Shipping_Message'} = "display message"

		# Example of custom shipping, uneven schema
		# Using shipping per number of products purchased
		# Domestic/Foreign not used in this example

		# Custom Shipping Code Starts Here
		# Custom Shipping Code Starts Here

		$posters_ordered=0;$media_ordered=0;
		
		foreach (@orders) {
			($qty, $item, $desc, $price, $ship, $taxit) = split(/$delimit/);
			if ($ship==1) {$posters_ordered+=$qty}
			if ($ship==2) {$video_ordered+=$qty}
			if ($ship==3) {$music_ordered+=$qty}
			}

			$allthem = $posters_ordered+$video_ordered+$music_ordered;
			$shipping = 4.95 + ($allthem-1);
			
			
		#if ($posters_ordered>0) {$shipping+=3.95*$posters_ordered}
		#$media_ordered = $video_ordered+$music_ordered;
			#  $shipping+=3.95 * (1+int($media_ordered/5));
				#if ($posters_ordered>0) {$shipping-=3.95};
				#$Computations{'Shipping_Message'} = "Standard Shipping ($media_ordered - $posters_ordered)";
		

		
		
	#	if ( $items < 6 ) { 
	#	$shipping = 6.95;
	#	$Computations{'Shipping_Message'} = "$Computations{'Shipping_Status'} Shipping Under 6 Items";

	#	} elsif ( $items < 12 ) { 
	#	$shipping = 8.95;
		#$Computations{'Shipping_Message'} = "$Computations{'Shipping_Status'} Shipping Under 12 Items";

	#	} else { 
	#	$shipping = 12.95;
	#	$Computations{'Shipping_Message'} = "$Computations{'Shipping_Status'} Shipping 12 or More Items";

	#	}

		# Custom Shipping Code Ends Here
		# Custom Shipping Code Ends Here
	

	}

	$shipping = sprintf "%.2f", $shipping;
  	return $shipping;	
 	}

	# COMPUTE USER SELECTED SHIPPING
	# COMPUTE USER SELECTED SHIPPING	

sub ComputeShippingMethod {

	my ($sub_price) = $Computations{'Sub_Final_Discount'};
	my ($items) = $Computations{'Primary_Products'};
	my ($qty, $item, $desc, $price, $ship, $taxit, $key, $val);
	my ($rate, $is_domestic, $use_domestic, $shipping, $repeats, $total_weight) = (0,0,0,0,0,0);
	my ($method, $mode, $domestic_rate, $foreign_rate, $increment);


		# Find selected info
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
	}
	}	
	}

	if (scalar(@domestic_state)) {
	$use_domestic++;
		
	foreach (@domestic_state) {

	if ($NewInfo{'Ecom_ShipTo_Postal_StateProv'} =~ /\b$_\b/i) {
	$Computations{'Domestic_State'} = $NewInfo{'Ecom_ShipTo_Postal_StateProv'};
	$is_domestic++;
	}
	}	
	}

	if (scalar(@domestic_country)) {
	$use_domestic++;
		
	foreach (@domestic_country) {

	if ($NewInfo{'Ecom_ShipTo_Postal_CountryCode'} =~ /\b$_\b/i) {
	$Computations{'Domestic_Country'} = $NewInfo{'Ecom_ShipTo_Postal_CountryCode'};
	$is_domestic++;
	}
	}	
	}

	$Computations{'Is_Domestic'} = $is_domestic;
	$Computations{'Use_Domestic'} = $use_domestic;


		# what rate to use
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

	# CUSTOM USER SELECTED SHIPPING ---------------------->
	# IMPORTANT: You must ID Your Method Key name for each "custom" used
	# IMPORTANT: You must set up the [if.elsif] branch with the Key name
	# IMPORTANT: Each Method using "custom" computations must have it's own branch and code

	# Variables Available (local) ------------------------> 

	# $sub_price (Sub Total after all discounts computed)
	# $items (total number of products ordered)
	# $total_weight (if using ship codes and 'weight' mode)
	# $use_domestic (are there any domestic settings)
	# $is_domestic (if domestic/foreigh enabled is shipping domestic)

	# Global results: $Computations{'Total_Weight'}
	# Global results: $Computations{'Use_Domestic'} positive if enabled
	# Global results: $Computations{'Is_Domestic'} if enabled and matches domestic settings
	# Global results: $Computations{'Domestic_City'} if found
	# Global results: $Computations{'Domestic_State'} if found
	# Global results: $Computations{'Domestic_Country'} if found
	# Global results: $Computations{'Shipping_Status'} [Domestic,Foreign,Standard]
	# Return: $shipping
	# Make: $Computations{'Shipping_Message'} 


		# Example of custom shipping branch
		# Example of custom shipping branch


		if ($method eq "Express_Delivery") {

			# This is where custom code goes for Express_Delivery method
			# Your computations should produce the $shipping variable
			# You can use any of the available variables above in your computation
			
			$shipping = 1.99;
			$Computations{'Shipping_Message'} = $Computations{'Shipping_Method_Description'};


		} elsif ($method eq "air") {
				foreach (@orders) {
								($qty, $item, $desc, $price, $ship, $taxit) = split(/$delimit/);
								if ($ship == 3) {
										$shipping += (7.50 * $qty);}
								elsif ($ship == 2) {
										$shipping += (4.00 * $qty);}
								elsif ($ship == 1) {
										$shipping += (1.00 * $qty);}
								  }
						$shipping += 9.00;
					}
		elsif ($method eq "ground") {
				foreach (@orders) {
								($qty, $item, $desc, $price, $ship, $taxit) = split(/$delimit/);
								if ($ship == 3) {
										$shipping += (4.50 * $qty);}
								elsif ($ship == 2) {
										$shipping += (2.50 * $qty);}
								elsif ($ship == 1) {
										$shipping += (.50 * $qty);}
								  }
						$shipping += 8.00;
					}


		# End example of custom shipping branch
		# End example of custom shipping branch

	

	}

	$shipping = sprintf "%.2f", $shipping;
  	return $shipping;	
	}



		
	# COMPUTE TAX
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
		# set before/after adjusted tax amounts

	$before_amount = $Computations{'Adjusted_Tax_Amount'};
	$after_amount = ($Computations{'Adjusted_Tax_Amount'} + $Computations{'Combined_SHI'});


		# Find rate
		# Find rate
	
	if ($use_global_tax > 0) { 

		$rate = $use_global_tax;

	} else {

		# Find city matched rate
		# Find city matched rate

		if (scalar(keys(%use_city_tax))) {
		while (($key, $val) = each (%use_city_tax)) {

			if ( $key =~ /^$NewInfo{'Ecom_ShipTo_Postal_City'}$/i ) {
		
				if ($add_tax_rates) { $rate += $val;
				} else { $rate = $val if ($val > $rate);
				}
				last;
			}
		}
		}

				# Find county matched rate

		if (scalar(keys(%use_county_tax))) {
		while (($key, $val) = each (%use_county_tax)) {

			if ( $key =~ /^$NewInfo{'Ecom_ShipTo_Postal_County'}$/i ) {
		
				if ($add_tax_rates) { $rate += $val;
				} else { $rate = $val if ($val > $rate);
				}
				last;
			}
		}
		}
		
		
		# Find zipcode matched rate
		# Find zipcode matched rate

		if (scalar(keys(%use_zipcode_tax))) {
		while (($key, $val) = each (%use_zipcode_tax)) {

			if ( $NewInfo{'Ecom_ShipTo_Postal_PostalCode'} =~ /^$key/i ) {
		
				if ($add_tax_rates) { $rate += $val;
				} else { $rate = $val if ($val > $rate);
				}
				last;
			}
		}
		}

		# Find state matched rate
		# Find state matched rate

		if (scalar(keys(%use_state_tax))) {
		while (($key, $val) = each (%use_state_tax)) {

			if ( $key =~ /^$NewInfo{'Ecom_ShipTo_Postal_StateProv'}$/i ) {
		
				if ($add_tax_rates) { $rate += $val;
				} else { $rate = $val if ($val > $rate);
				}
				last;
			}
		}
		}

		# Find country matched rate
		# Find country matched rate

		if (scalar(keys(%use_country_tax))) {
		while (($key, $val) = each (%use_country_tax)) {

			if ( $key =~ /^$NewInfo{'Ecom_ShipTo_Postal_CountryCode'}$/i ) {
		
				if ($add_tax_rates) { $rate += $val;
				} else { $rate = $val if ($val > $rate);
				}
				last;
			}
		}
		}


	} 



		# Find before-after exceptions
		# Find before-after exceptions

	foreach (@exceptions_city) { 
	$exceptions++ if ( $_ =~ /^$NewInfo{'Ecom_ShipTo_Postal_City'}$/i ) }

	foreach (@exceptions_zipcode) { $exceptions++ if ( 
	$NewInfo{'Ecom_ShipTo_Postal_PostalCode'} =~ /^$_/i ) }

	foreach (@exceptions_state) { 
	$exceptions++ if ( $_ =~ /^$NewInfo{'Ecom_ShipTo_Postal_StateProv'}$/i ) }

	foreach (@exceptions_country) { 
	$exceptions++ if ( $_ =~ /^$NewInfo{'Ecom_ShipTo_Postal_CountryCode'}$/i ) }

	foreach (@exceptions_county) { 
	$exceptions++ if ( $_ =~ /^$NewInfo{'Ecom_ShipTo_Postal_StateProv'}$/i ) }


		# Compute rate before or after
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
	
	}




	# END COMPUTATIONS
	# END COMPUTATIONS






	# FORMAT NUMBERS
	# FORMAT NUMBERS

sub CommifyNumbers {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
    	return $_;
  	}



	# FORMAT MONEY
	# FORMAT MONEY
	# Change this to alter how money is formatted
	# The sprintf function throughout mof.cgi creates the 2 decimils


sub CommifyMoney {
	local $_  = shift;
    	1 while s/^(-?\d+)(\d{3})/$1,$2/;
    	return $_;
  	}




1;


