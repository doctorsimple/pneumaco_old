<?

class dftGlobals {
private $global_include_dir;
//private $global_include_dir = "/";
private $MYSQL_SERVER = '192.168.34.9';
public $UPLOAD_SERVER = 'upload.digitalfuntown.net';
public $domain = '192.168.36.9';
public $udomain = 'upload.digitalfuntown.net';
public $incpath = "/dftdev/";

public function __construct() {
	$this->global_include_dir = $_SERVER['DOCUMENT_ROOT'] . $this->incpath;
}
public function __destruct() {
	$this->global_include_dir = null;
}

public function getIncludeDir() {
	return $this->global_include_dir;
}
public function getSQLSERVER() {
	return $this->MYSQL_SERVER;
}

public function dft_include($incfile) {
include_once ($this->getIncludeDir() . $incfile);
}

public function dft_cl_include($incfile) {
include_once ("/var/www/html" . $this->getIncludeDir() . $incfile);
}
public function initializePage() {
	$headers = '	<link rel="stylesheet" href="shared_libs/css-stylesheets/global.css" type="text/css" media="screen" title="Global Stylesheet" charset="utf-8" />
	<!--[if IE 7]>
	<link rel="stylesheet" href="shared_libs/css-stylesheets/globalIE7.css" type="text/css" media="screen" charset="utf-8" />
	<![endif]-->
	<!--[if lte IE 6]>
	<link rel="stylesheet" href="shared_libs/css-stylesheets/globalIE6.css" type="text/css" media="screen" charset="utf-8" />
	<![endif]-->
	<link rel="stylesheet" href="shared_libs/css-stylesheets/pagination.css" type="text/css" media="screen" charset="utf-8" />
	';
	
	$headers .= '<script src="shared_libs/js-bin/jquery.js"></script>';
	$headers .= '<script type="text/javascript" src="shared_libs/js-bin/thickbox.js"></script>';
	$headers .= '<script type="text/javascript" src="shared_libs/js-bin/utils.js"></script>';
	$headers .= '<script language="javascript">AC_FL_RunContent = 0;</script><script src="shared_libs/js-bin/AC_RunActiveContent.js"></script>';
    $headers .= '<script type="text/javascript" src="shared_libs/js-bin/characters.js"></script>';
    $headers .= '<script src="shared_libs/js-bin/jquery.pagination.js" type="text/javascript"></script>';
    $headers .= '<script src="shared_libs/js-bin/preloadCss.js" type="text/javascript"></script>';
include_once ('dft_globals.php');
$g = new dftGlobals();
$g->dft_include('shared_libs/php-bin/includes/classes/Browser.php');
$b = new Browser($_SERVER);
if ($b->b == "IE" && $b->v < 7){
echo $headers;
echo "</head><body>";
$g->dft_include('browserCheck/newbrowser.php');
echo "</body></html>";
die();
}





    return $headers;
}
public function drawNavigation() {
	$this->dft_include('navigation/component.php');
}
}
?>
