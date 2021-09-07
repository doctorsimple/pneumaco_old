<?php require('wikiwalk.class.php');
$wikiwalk=new Wikiwalk;
if ($_REQUEST['phrase']) {
$got = $wikiwalk->getrandompage($_REQUEST['phrase']);
}
if ($_REQUEST['link']) {
$got= $wikiwalk->grabpage($_REQUEST['link']);
}
$line=$wikiwalk->getrandomline($got);
$newlink=$wikiwalk->getrandomlink($line);
$tit = $wikiwalk->getpagetitle($got) . "->".$newlink;
echo strip_tags($line) . "&*&" . $tit . "++|++" . $newlink;

?>