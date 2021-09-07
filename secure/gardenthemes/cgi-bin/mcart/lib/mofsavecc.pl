# ==================== MOFcart v2.5.12.08.04 ====================== #
# === Save CC info ================================================ #
# === REMOVAL OF COPYRIGHT NOTICE IS PROHIBITED =================== #
# === MERCHANT ORDERFORMcart ver 2.5 (PKG: 10-21-03) ============== #
# === All Rights Reserverd  © 2000-2004 rga@merchantpal.com ======= #
# === This Software Package, either individually or together, ===== #
# === may not be sold, distributed, modified, or otherwise ======== #
# === used in anyway outside the License Agreement limitations ==== #
# === Consult the License Agreement with any questions: =========== #
# === LICENSE: http://www.merchantpal.com/license.html ============ #
# ================================================================= #

# CONFIGURATIONS
# key must match key in <mofcc.cgi>
my($key) = 'ejekendijendaidendiand';

sub SaveASCIIcc {
my ($save_url_db) = "Not Saved";
$save_url_db = $save_invoice_url . $$ . $InvoiceNumber . ".html" if ($save_invoice_html);
$_ = $InvoiceNumber;
$_ .=  "\|";
$_ .=  $frm{'OrderID'};
$_ .=  "\|";
$_ .=  $ShortDate;
$_ .=  "\|";
$_ .=  $Time;
$_ .=  "\|";
$_ .=  $frm{'Primary_Products'};
$_ .=  "\|";
if ($Send_API_Amount) {
$_ .=  $Send_API_Amount}
else {
$_ .=  $frm{'Final_Amount'}}
$_ .=  "\|";
$_ .=  $frm{'input_payment_options'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_Payment_Card_Name'};
$_ .=  "\|";
my ($code_cc_tr) = $frm{'Ecom_Payment_Card_Number'};
$code_cc_tr =~ tr/0-9//cd;
$_ .=  $code_cc_tr;
$_ .=  "\|";
$_ .=  $frm{'Ecom_Payment_Card_ExpDate_Month'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_Payment_Card_ExpDate_Year'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_Payment_Card_Verification'};
$_ .=  "\|";
$_ .=  $frm{'Check_Holder_Name'};
$_ .=  "\|";
$_ .=  $frm{'Check_Number'};
$_ .=  "\|";
my ($code_cc_ck) = $frm{'Check_Account_Number'};
$code_cc_ck =~ tr/A-Za-z0-9//cd;
$_ .=  $code_cc_ck;
$_ .=  "\|";
$_ .=  $frm{'Check_Routing_Number'};
$_ .=  "\|";
$_ .=  $frm{'Check_Fraction_Number'};
$_ .=  "\|";
$_ .=  $frm{'Check_Bank_Name'};
$_ .=  "\|";
$_ .=  $frm{'Check_Bank_Address'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Name_Prefix'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Name_First'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Name_Middle'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Name_Last'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Name_Suffix'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Company'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Street_Line1'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Street_Line2'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_City'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_StateProv'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_Region'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_CountryCode'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Postal_PostalCode'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Telecom_Phone_Number'};
$_ .=  "\|";
$_ .=  $frm{'Ecom_BillTo_Online_Email'};
$_ .=  "\|";
$_ .=  $save_url_db;
$_ .=  "\|";									###CHANGE###
$_ .=  $frm{'Ecom_Payment_Card_FromDate_Month'};###CHANGE###
$_ .=  "\|";									###CHANGE###
$_ .=  $frm{'Ecom_Payment_Card_FromDate_Year'}; ###CHANGE###
$_ .=  "\|";									###CHANGE###
$_ .=  $frm{'Ecom_Payment_Card_IssueNumber'};   ###CHANGE###
unless (open (DAT, ">>$MOFINFO") ) { 
$ErrMsg = "Unable to Access Data Files: 1";
&ErrorMessage($ErrMsg);}
flock (DAT,2) if ($lockfiles);
$_ = &Encrypt($_, $key);
print DAT "$_\n";
close(DAT);}
sub Encrypt {
my ($plaintext,$key) = @_;
my ($cr,$index,$char,$key_char,$encrypted);
$plaintext = &rot13($plaintext); 
$cr = '``';
$plaintext =~ s/[\n\f\t]//g;
$plaintext =~ s/[\r]/$cr/g;
while ( length($key) < length($plaintext) ) { $key .= $key }
$key=substr($key,0,length($plaintext));
$index=0;
while ($index < length($plaintext)) {
$char = substr($plaintext,$index,1);
$key_char = substr($key,$index,1);
$encrypted .= chr(ord($char) ^ ord($key_char));
$index++;}
$encrypted = encode_base64($encrypted);
$encrypted =~ s/[\n\r\t]//g;
$encrypted ;}
sub rot13{
my $source = shift (@_);
$source =~ tr /[a-m][n-z]/[n-z][a-m]/;
$source =~ tr /[A-M][N-Z]/[N-Z][A-M]/;
$source = reverse($source);
$source;}
sub encode_base64 {
my $res = "";
my $eol = $_[1];
$eol = "\n" unless defined $eol;
pos($_[0]) = 0;
while ($_[0] =~ /(.{1,45})/gs) {
$res .= substr(pack('u', $1), 1);
chop($res);}
$res =~ tr|` -_|AA-Za-z0-9+/|;
my $padding = (3 - length($_[0]) % 3) % 3;
$res =~ s/.{$padding}$/'=' x $padding/e if $padding;
if (length $eol) {
$res =~ s/(.{1,76})/$1$eol/g;}
$res;}
1;
# END MERCHANT ORDERFORM Cart ver 2.5
# Copyright by RGA 2000-2003


