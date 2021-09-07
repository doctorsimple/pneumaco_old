<?php $x=imagecreatefromjpeg('DocWatsonFull.jpg');

header("Content-Type: image/jpeg");
imagejpeg($x);
?>