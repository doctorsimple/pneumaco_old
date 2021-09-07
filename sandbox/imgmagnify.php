<head>
<title>TEst image obscurantor</title>
<script src="jquery/jquery-1.2.6.min.js"></script>
  <script src="jquery/ui/ui.core.js"></script>
	 <script src="jquery/ui/ui.draggable.js"></script>



<script>
$(document).ready(function() {
//set some vars
		$("#thepic").width($("#thepic img").width());
		thmsrc=$("#pic1").attr("src");
		thmht=$("#pic1").height() *.33;
		thmwd=$("#pic1").width() *.33;
		thmtop=($("#pic1").height()-thmht) /2;
		thmlft=($("#pic1").width()-thmwd) /2;
		thm=new Image();  //create thumbnail
		$(thm).attr({src:thmsrc,height:thmht,width:thmwd});
		$(thm).load(function() {
// put thumbnail in middle of the hidden fullsize pic			
			$(thm).appendTo("#thepic");	
			$(thm).wrap(document.createElement('div'));
			$(thm).parent().attr("id","thmwrap");
			$("#thmwrap").css({position:"absolute",top:thmtop+"px",left:thmlft+"px"});
			});
	// Make Loupe draggable
		$("#loupe").draggable();		
	//Track Loupe	
		$("#loupe").mousemove( function () 
				{lenspos=$("#loupe").offset();
				$("#xpos").val(lenspos.left);
				$("#ypos").val(lenspos.top);
				
				});
		
		});
		 
</script>
<style>
.mainimage {visibility:hidden;}
#thepic {border:1px solid black;position:relative;}
#loupe {border:2px solid brown;height:25px;width:25px;}
</style>
</head>
<body>
<div id="pwrapper">
  <div id="thepic">
  <img src="DocWatsonFull.jpg" id="pic1" class="mainimage" />
  </div>
<div id="loupe">
</div> 	
</div>
<input id="xpos" name="xpos" size="3"><input id="ypos" name="xpos" size="3">
<input type="button" onclick='alert($("#loupe").offset().left);'>
</body>

