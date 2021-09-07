# MOFcart v2.5.02.20.04 : QRY TO CREATE TABLE STRUCTURE
# ============================================== #
#   MERCHANT ORDERFORMcart ver 2.5 (PKG: May 20, 2003)            
#   All Rights Reserverd  © 2000-2003 rga@merchantpal.com          
#   http://www.merchantorderform.com/copyright.html                
# ============================================== #

# note August 03, 2003 12:17:51 PM
# note needs ability to encrypt the important fields
# note needs results tables for IPN, AuthNet, BOFA
# note needs ability to check existing dB and append any new tables/fields, including custom fields

# RGA : February 20, 2004 2:45:51 PM
# Added (2) new tables for Abuse mgmt : mofabuse, mofabusedeny

# SOME IMPORTANT CHECKS:
# These Money vars store data formatted with Commas (or alternate) and cannot be stored as decimal numbers
# All other Money vars store data non commified, but formatted to 2 decimals 000000000.00
# (1) global_Amount
# (2) Format_Deposit_Amount
# (3) Remaining_Balance

# The 'mofcustom' table is an example only and must mirror any new/old Custom Fields set
# in your <mofpay.conf> configs for custom field definition

# Visa-MC service agreements prohibit saving CVV/CID verification numbers
# Therefore the field : Ecom_Payment_Card_Verification is not saved

# Also if you will be using large TEXTAREA fields as optional input then you will want 
# to check the tinyblob settings, and extend to mediumblob or largeblob


# =======  MOF INVOICES & DATA TABLES =========== #
# PRIMARY KEY = recID auto_increment in main table (mofinvoices)

# ======= UNIQUE ONE TO ONE RELATIONS =========
# recID (mofinvoices) [one to one] -> recID (mofdata, unique key)
# recID (mofinvoices) [one to one] -> recID (mofcustom, unique key)
# recID (mofinvoices) [one to one] -> recID (mofupdates, unique key)

# ======= ONE TO MANY RELATIONS ===============
# recID (mofinvoices) [one to MANY] -> recID (moforders, index)

# ======= ONE TO ONE/MANY RELATIONS 
# ======= These are possible gateway data return tables
# ======= Their Table structure is under Development
# recID (mofinvoices) [one to one] -> recID (mofipn, index)
# recID (mofinvoices) [one to one] -> recID (mofbofa, index)
# recID (mofinvoices) [one to one] -> recID (mofauthnet, index)

# =======  AUTO_INCREMENT PRIMARY KEYS =========== #
# Table : mofinvoices : Primary Key : recID autoincrement (in use)
# Table : mofprofile    : Primary Key : usrID autoincrement (in use)

# Table : mofdata       : Primary Key : myID autoincrement (not used)
# Table : mofcustom  : Primary Key : myID autoincrement (not used)
# Table : moforders   : Primary Key : myID autoincrement (not used)
# Table : mofipn         : Primary Key : myID autoincrement (not used)
# Table : mofbofa       : Primary Key : myID autoincrement (not used)
# Table : mofauthnet  : Primary Key : myID autoincrement (not used)

# ======== ADMIN UPDATES TABLE  =============== #
# Table : mofupdates  : Primary Key : myID autoincrement (not used)

# ======== USER PROFILE & INFO TABLE =========== #
# the 'mofprofile' Table has a one to Many relation to all order activity tables
# PRIMARY KEY = usrID auto_increment in main table (mofprofile)
# usrID (mofprofile) [one to MANY] -> usrID (mofinvoices, index)
# usrID (mofprofile) [one to MANY] -> usrID (mofdata, index)
# usrID (mofprofile) [one to MANY] -> usrID (mofcustom, index)
# usrID (mofprofile) [one to MANY] -> usrID (moforders, index)
# usrID (mofprofile) [one to MANY] -> usrID (mofipn, index)
# usrID (mofprofile) [one to MANY] -> usrID (mofbofa, index)
# usrID (mofprofile) [one to MANY] -> usrID (mofauthnet, index)


CREATE TABLE IF NOT EXISTS `mofinvoices` (
`recID` int not null auto_increment,
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(50) default null,
`InfoID` varchar(50) default null,
`global_Amount` varchar(20) default null,
`global_CodCharges` decimal(10,2) default null,
`global_CreditAmount` decimal(10,2) default null,
`global_currency` varchar(4) default null,
`global_depmin` decimal(10,2) default null,
`global_mail_customer_addr` varchar(50) default null,
`global_MyDate` varchar(50) default null,
`global_PayType` varchar(50) default null,
`global_RemainingBalance` decimal(10,2) default null,
`global_RepAmt` decimal(10,2) default null,
`global_RepCode` varchar(20) default null,
`global_RepRate` double default null,
`global_save_url` varchar(255) default null, 
`global_Send_API_Amount` decimal(10,2) default null,
`global_ShortDate` date default null,
`global_Time` time default null, 
`Ecom_BillTo_Online_Email` varchar(50) default null,
`Ecom_BillTo_Postal_City` varchar(50) default null,
`Ecom_BillTo_Postal_Company` varchar(50) default null,
`Ecom_BillTo_Postal_CountryCode` varchar(50) default null,
`Ecom_BillTo_Postal_Name_First` varchar(50) default null,
`Ecom_BillTo_Postal_Name_Last` varchar(50) default null,
`Ecom_BillTo_Postal_Name_Middle` varchar(50) default null,
`Ecom_BillTo_Postal_Name_Prefix` varchar(50) default null,
`Ecom_BillTo_Postal_Name_Suffix` varchar(50) default null,
`Ecom_BillTo_Postal_PostalCode` varchar(50) default null,
`Ecom_BillTo_Postal_Region` varchar(50) default null,
`Ecom_BillTo_Postal_StateProv` varchar(50) default null,
`Ecom_BillTo_Postal_Street_Line1` varchar(50) default null,
`Ecom_BillTo_Postal_Street_Line2` varchar(50) default null,
`Ecom_BillTo_Telecom_Phone_Number` varchar(50) default null,
`Ecom_ShipTo_Online_Email` varchar(50) default null,
`Ecom_ShipTo_Postal_City` varchar(50) default null,
`Ecom_ShipTo_Postal_Company` varchar(50) default null,
`Ecom_ShipTo_Postal_CountryCode` varchar(50) default null,
`Ecom_ShipTo_Postal_Name_First` varchar(50) default null,
`Ecom_ShipTo_Postal_Name_Last` varchar(50) default null,
`Ecom_ShipTo_Postal_Name_Middle` varchar(50) default null,
`Ecom_ShipTo_Postal_Name_Prefix` varchar(50) default null,
`Ecom_ShipTo_Postal_Name_Suffix` varchar(50) default null,
`Ecom_ShipTo_Postal_PostalCode` varchar(50) default null,
`Ecom_ShipTo_Postal_Region` varchar(50) default null,
`Ecom_ShipTo_Postal_StateProv` varchar(50) default null,
`Ecom_ShipTo_Postal_Street_Line1` varchar(50) default null,
`Ecom_ShipTo_Postal_Street_Line2` varchar(50) default null,
`Ecom_ShipTo_Telecom_Phone_Number` varchar(50) default null,
`Ecom_ShipTo_Postal_Type` varchar(12) default null,
`Check_Account_Number` varchar(50) default null,
`Check_Account_Type` varchar(50) default null,
`Check_Bank_Address` varchar(50) default null,
`Check_Bank_Name` varchar(50) default null,
`Check_Customer_Organization_Type` varchar(50) default null,
`Check_Drivers_License_DOB` varchar(50) default null,
`Check_Drivers_License_Num` varchar(50) default null,
`Check_Drivers_License_ST` varchar(50) default null,
`Check_Fraction_Number` varchar(50) default null,
`Check_Holder_Name` varchar(50) default null,
`Check_Number` varchar(50) default null,
`Check_Routing_Number` varchar(50) default null,
`Check_Tax_ID` varchar(50) default null,
`Ecom_Payment_Card_ExpDate_Day` varchar(50) default null,
`Ecom_Payment_Card_ExpDate_Month` varchar(50) default null,
`Ecom_Payment_Card_ExpDate_Year` varchar(50) default null,
`Ecom_Payment_Card_FromDate_Month` varchar(50) default null,
`Ecom_Payment_Card_FromDate_Year` varchar(50) default null,
`Ecom_Payment_Card_IssueNumber` varchar(50) default null,
`Ecom_Payment_Card_Name` varchar(50) default null,
`Ecom_Payment_Card_Number` varchar(50) default null,
`Ecom_Payment_Card_Type` varchar(50) default null,
PRIMARY KEY(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) auto_increment = 1500 TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofdata` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(50) default null,
`InfoID` varchar(50) default null,
`Adjusted_Tax_Amount` decimal(10,2) default null,
`Adjusted_Tax_Amount_After` decimal(10,2) default null,
`Adjusted_Tax_Amount_Before` decimal(10,2) default null,
`Allow_Shipping` varchar(2) default null,
`Allow_Tax` varchar(2) default null,
`Combined_Discount` decimal(10,2) default null,
`Combined_SHI` decimal(10,2) default null,
`Compute_Coupons` varchar(50) default null,
`Compute_Insurance` decimal(10,2) default null,
`Compute_Shipping_Method` varchar(255) default null,
`Coupon_Affiliate_Rate` double default null,
`Coupon_Cust_Rate` double default null,
`Coupon_Discount` decimal(10,2) default null,
`Coupon_Discount_myNumber` varchar(50) default null,
`Coupon_Discount_Status` varchar(255) default null,
`Deposit_Amount` decimal(10,2) default null,
`Domestic_City` varchar(50) default null,
`Final_Amount` decimal(10,2) default null,
`Final_ConvertAmount` decimal(10,2) default null,
`Format_Deposit_Amount` varchar(20) default null,
`Handling` decimal(10,2) default null,
`Handling_Status` varchar(255) default null,
`Initial_Taxable_Amount` decimal(10,2) default null,
`input_cyber_permission` varchar(12) default null,
`input_payment_options` varchar(50) default null,
`input_shipping_info` varchar(10) default null,
`Insurance` decimal(10,2) default null,
`Insurance_Amt_Override` varchar(20) default null,
`Insurance_Line_Override` varchar(2) default null,
`Insurance_Status` varchar(255) default null,
`Is_Domestic` varchar(2) default null,
`previouspage` varchar(255) default null,
`Primary_Discount` decimal(10,2) default null,
`Primary_Discount_Line_Override_Backend` varchar(2) default null,
`Primary_Discount_Status` varchar(255) default null,
`Primary_Price` decimal(10,2) default null,
`Primary_Products` double default null,
`Remaining_Balance` varchar(20) default null,
`resubmit_info` varchar(10) default null,
`Shipping_Amount` decimal(10,2) default null,
`Shipping_Amt_Override` varchar(20) default null,
`Shipping_Line_Override` varchar(2) default null,
`Shipping_Message` varchar(255) default null,
`Shipping_Method_Description` varchar(255) default null,
`Shipping_Method_Name` varchar(50) default null,
`Shipping_Status` varchar(255) default null,
`Sub_Coupon_Discount` decimal(10,2) default null,
`Sub_Final_Discount` decimal(10,2) default null,
`Sub_Primary_Discount` decimal(10,2) default null,
`Sub_SHI` decimal(10,2) default null,
`Tax_Amount` decimal(10,2) default null,
`Tax_Discount_Ratio` double default null,
`Tax_Exempt_Status` varchar(50) default null,
`Tax_Line_Override` varchar(2) default null,
`Tax_Message` varchar(255) default null,
`Tax_Rate` double default null,
`Tax_Rule` varchar(10) default null,
`Tax_Rule_Exceptions` varchar(10) default null,
`Total_Weight` double default null,
`Use_Domestic` varchar(2) default null,
`Ecom_ReceiptTo_Online_Email` varchar(50) default null,
`Ecom_ReceiptTo_Postal_City` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Company` varchar(50) default null,
`Ecom_ReceiptTo_Postal_CountryCode` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Name_First` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Name_Last` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Name_Middle` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Name_Prefix` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Name_Suffix` varchar(50) default null,
`Ecom_ReceiptTo_Postal_PostalCode` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Region` varchar(50) default null,
`Ecom_ReceiptTo_Postal_StateProv` varchar(50) default null,
`Ecom_ReceiptTo_Postal_Street_Line1` varchar(150) default null,
`Ecom_ReceiptTo_Postal_Street_Line2` varchar(150) default null,
`Ecom_ReceiptTo_Telecom_Phone_Number` varchar(50) default null,
`special_instructions` mediumblob,
PRIMARY KEY(`myID`),
KEY(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofcustom` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(255) default null,
`InfoID` varchar(255) default null,
`customA_CompanyName` varchar(255) default null,
`customB_Address` varchar(255) default null,
`customC_City` varchar(255) default null,
`customD_State` varchar(255) default null,
`customE_Country` varchar(255) default null,
`customF_Zip` varchar(255) default null,
`customG_PhoneNumber` varchar(255) default null,
`customH_PhoneNumber` varchar(255) default null,
`customI_AddToMail` varchar(255) default null,
`customJ_StableEmail` varchar(255) default null,
`customK_ReferredBy` varchar(255) default null,
`customL_Other` varchar(255) default null,
`customM_AnotherList` varchar(255) default null,
`customN_OneMore` varchar(255) default null,
PRIMARY KEY(`myID`),
KEY(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `moforders` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(255) default null,
`InfoID` varchar(255) default null,
`Quantity` double default null,
`Item` tinyblob,
`ItemBlock` tinyblob,
`Description` tinyblob,
`DescBlock` mediumblob,
`Price` decimal(10,2) default null,
`Shipping` double default null,
`Tax` double default null,
`Option1` varchar(255) default null,
`Option2` varchar(255) default null,
`Option3` varchar(255) default null,
`Option4` varchar(255) default null,
`Option5` varchar(255) default null,
`Option6` varchar(255) default null,
`Option7` varchar(255) default null,
`Option8` varchar(255) default null,
`Option9` varchar(255) default null,
`Option10` varchar(255) default null,
`Option11` varchar(255) default null,
`Option12` varchar(255) default null,
`Option13` varchar(255) default null,
`Option14` varchar(255) default null,
`Option15` varchar(255) default null,
PRIMARY KEY(`myID`),
INDEX(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofipn` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(255) default null,
`InfoID` varchar(255) default null,
PRIMARY KEY(`myID`),
INDEX(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofauthnet` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(255) default null,
`InfoID` varchar(255) default null,
PRIMARY KEY(`myID`),
INDEX(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofbofa` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(255) default null,
`InfoID` varchar(255) default null,
PRIMARY KEY(`myID`),
INDEX(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) TYPE=MyISAM;


# ============================================== #
# usrID is Primary Key from (mofprofile) to all order activity tables
# provides user profile data w/ reference to order data
# provides initial usr : psw for new accounts
# ============================================== #

CREATE TABLE IF NOT EXISTS `mofprofile` (
`usrID` int not null auto_increment,
`myUsr` varchar(50) not null default 'USR',
`myPsw` varchar(50) not null default 'PSW',
`myDate` date default null,
`myTime` time default null, 
`myEmail` varchar(50) default null,
`myCity` varchar(50) default null,
`myCompany` varchar(50) default null,
`myCountryCode` varchar(50) default null,
`myName_First` varchar(50) default null,
`myName_Last` varchar(50) default null,
`myName_Middle` varchar(50) default null,
`myName_Prefix` varchar(50) default null,
`myName_Suffix` varchar(50) default null,
`myPostalCode` varchar(50) default null,
`myRegion` varchar(50) default null,
`myStateProv` varchar(50) default null,
`myStreet_Line1` varchar(50) default null,
`myStreet_Line2` varchar(50) default null,
`myPhone_Number` varchar(50) default null,
`myCard_ExpDate_Day` varchar(50) default null,
`myCard_ExpDate_Month` varchar(50) default null,
`myCard_ExpDate_Year` varchar(50) default null,
`myCard_FromDate_Month` varchar(50) default null,
`myCard_FromDate_Year` varchar(50) default null,
`myCard_IssueNumber` varchar(50) default null,
`myCard_Name` varchar(50) default null,
`myCard_Number` varchar(50) default null,
`myCard_Type` varchar(50) default null,
`myNotes` mediumblob,
PRIMARY KEY  (`usrID`)
) auto_increment = 24200 TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofupdates` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(255) default null,
`InfoID` varchar(255) default null,
`myLogin` varchar(50) not null default 'LOGIN',
`myPass` varchar(50) not null default 'PASS',
`myShip` varchar(255) default null,
`myShipStmp` timestamp(14),
`myTracking` varchar(255) default null,
`myStatus` varchar(255) default null,
`myDownload` varchar(255) default null,
`myReg` varchar(255) default null,
`myDate` date default null,
`myTime` time default null,
`myStmp1` timestamp(14),
`myStmp2` timestamp(14),
`myStmp3` timestamp(14),
`myRSA` varchar(255) default null,
`myNotes` tinyblob,
PRIMARY KEY(`myID`),
INDEX(`recID`),
INDEX(`usrID`),
INDEX(`global_InvoiceNumber`)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofabuse` (
`myID` int not null auto_increment,
`recID` int not null default '0',
`usrID` int not null default '0',
`global_InvoiceNumber` int not null default '0',
`OrderID` varchar(255) default null,
`InfoID` varchar(255) default null,
`REMOTE_ADDR` varchar(255) default null,
`REMOTE_HOST` varchar(255) default null,
`REMOTE_PORT` varchar(255) default null,
`HTTP_HOST` varchar(255) default null,
`SERVER_NAME` varchar(255) default null,
`SERVER_ADDR` varchar(255) default null,
`SERVER_PORT` varchar(255) default null,
`myTimeStamp` timestamp(14),
PRIMARY KEY(`myID`),
INDEX(`OrderID`),
INDEX(`REMOTE_ADDR`)
) TYPE=MyISAM;


CREATE TABLE IF NOT EXISTS `mofabusedeny` (
`myID` int not null auto_increment,
`OrderID` varchar(255) default null,
`REMOTE_ADDR` varchar(255) default null,
`REMOTE_HOST` varchar(255) default null,
`myTimeStamp` timestamp(14),
PRIMARY KEY(`myID`),
INDEX(`OrderID`),
INDEX(`REMOTE_ADDR`)
) TYPE=MyISAM;




