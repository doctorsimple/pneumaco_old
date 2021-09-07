<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<title>Etch a Check</title>
<script>
function flip(box) {
	if (box.checked==true) {box.checked=false;}
	else {box.checked=true;}
}



</script>
<style>
checkbox {
margin:0;
padding:0;
font-size:14px;
}
</style>
</head>
<body>

<script>
for (i=0;i<50;i++) {
	for (j=0;j<50;j++) {
	document.write("<input type='checkbox' onmouseover='flip(this)'>");
	}
document.writeln("<br>");
}	
</script>

</body>
</html>
