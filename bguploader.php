<?php
$uiq = uniqid();
$image_folder = "pictures/backgrounds/";
$uploaded = false;

if(isset($_POST['upload_image'])){
if($_FILES['userImage']['error'] == 0 ){
$up = move_uploaded_file($_FILES['userImage']['tmp_name'], $image_folder.$_FILES['userImage']['name']);
if($up){
$uploaded = true;
}
}
}
?>