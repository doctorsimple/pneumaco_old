<?PHP
class wikipedia
	{
	public function __construct($wiki)
		{
		$this->wiki = $wiki;
		}
	public function __destruct()
		{
		unset($this->wiki);
		}
	public function get_page($name, $header = false)
		{
		$file = file_get_contents($this->wiki.'/wiki/'.$name);
		$file = str_replace('href="/', 'href="'.$this->wiki.'/', $file);
		//$file = str_replace('href="#', 'href="'.$this->wiki.'/wiki/'.$name.'#', $file);
		preg_match_all('#<!-- start content -->(.*?)<!-- end content -->#es', $file, $ar);
		unset($file);
		IF(is_array($ar[1]))
			{
			IF($header == false)
				{
				return $ar[1][0];
				}
			else
				{
				return '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl" dir="ltr"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<link rel="stylesheet" type="text/css" href="'.$this->wiki.'/skins-1.5/monobook/main.css" /></head><body>'.$ar[1][0];
				}
			}
		else
			{
			return false;
			}
		}
	public function edit_page($name, $header = false)
		{
		$file = file_get_contents($this->wiki.'/w/index.php?title='.$name.'&action=edit');
		preg_match_all('#<textarea (.*?)ols=\'80\' >(.*?)</textarea>#es', $file, $ar);
		unset($file);
		IF(is_array($ar[2]))
			{
			ob_start();
			IF($header != false)
				{
				echo '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl" dir="ltr"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<link rel="stylesheet" type="text/css" href="'.$this->wiki.'/skins-1.5/monobook/main.css" /></head><body>';
				}
			
			$xname = 'wpTextbox1';
			echo '<Form action="'.$this->wiki.'/w/index.php?title='.$name.'&amp;action=submit" METHOD="POST" enctype="multipart/form-data" name="rk" id="editform"><center>
			<script language="JavaScript">
				function emoticon('.$xname.') {
				'.$xname.' = \'\' + '.$xname.' + \'\';
				if (document.rk.'.$xname.'.create'.$xname.'Range && document.rk.'.$xname.'.caretPos) {
				var caretPos = document.rk.'.$xname.'.caretPos;
				caretPos.'.$xname.' = caretPos.'.$xname.'.charAt(caretPos.'.$xname.'.length - 1) == \' \' ? '.$xname.' + \' \' : '.$xname.';
				document.rk.'.$xname.'.focus();
				} else {
				document.rk.'.$xname.'.value  += '.$xname.';
				document.rk.'.$xname.'.focus();
				}
				}
				</script>';
			
				echo '<center><textarea cols="75" rows="30" name="'.$xname.'">'.$ar[2][0].'</textarea><BR>
				<input type="button" value="Link to a wiki page" onClick="javascript:emoticon(\'[[wiki_page]]\')">
				<input type="button" value="Link" onClick="javascript:emoticon(\'[http://your_url.pl Page Title]\')">
				<input type="button" value="Graphic" onClick="javascript:emoticon(\'[[Grafika:filename]]\')">
				<input type="button" value="H1 - Big Title" onClick="javascript:emoticon(\'= Title =\')">
				<input type="button" value="H2 - Medium Title" onClick="javascript:emoticon(\'== Title ==\')">
				<input type="button" value="H3 - Small Title" onClick="javascript:emoticon(\'=== Title ===\')">
				<input type="button" value="LI - lists" onClick="javascript:emoticon(\'* Text here\')">
				<input type="button" value="LI - numeric lists" onClick="javascript:emoticon(\'# Text here\')">
				<input type="button" value="Definition" onClick="javascript:emoticon(\'; Definition name : Description\')">
				<input type="button" value="HR - line" onClick="javascript:emoticon(\'----\')"><BR><BR>';
			
			echo '<BR><input tabindex=\'5\' id=\'wpSave\' type=\'submit\' value="Save" name="wpSave" accesskey="s">
			<input tabindex=\'6\' id=\'wpPreview\' type=\'submit\'  value="Preview" name="wpPreview" accesskey="p">
			<input tabindex=\'7\' id=\'wpDiff\' type=\'submit\' value="Preview Changes" name="wpDiff" accesskey="v"></center></form>';
			$wynik = ob_get_contents();
			ob_end_clean();
			return $wynik;
			}
		else
			{
			return false;
			}
		}
	}
?>
