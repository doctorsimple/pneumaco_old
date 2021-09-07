var PNEU = PNEU || {} ;

PNEU.randomsorter = function(a,b) {
		return (Math.round(Math.random()));
	}
PNEU.boggleme = function(e,ui) {
		$(e.target).each( function() {
			contents = $(this).text();
			$(this).css({overflow:'hidden',maxHeight:$(this).height()+'px'});
			c =contents.split(' ');
			c.sort(PNEU.randomsorter);
			$(e.target).html(c.join(' '));
			$(e.target).css({overflow:'visible',maxheight:'none'});
			$('p.stanza').off('mouseover',PNEU.boggleme);
			setTimeout(function() {$('#thabg').css('cursor','default')}, 500);
			return this;
		});
	};
PNEU.boggleme.cleanup = function() {$('#forcefield').remove();} ;
PNEU.boggleme.prep = function() {$('#page').append('<div id="forcefield" style="position:absolute;top:0;left:0;height:1000px;width:100%;z-index:800;background:url(/pictures/spacer.png);"></div>');} ;
PNEU.imageselect = ['/pictures/cestusfist.png','/pictures/pcrest2.png','/pictures/pcrest7.png','/pictures/pcrest10.png','/pictures/pcrest13.png','/pictures/pcrest6.png'];
PNEU.imagenames = ['Fist','Transmission','Crossbow','Gears','Hurdy Gurdy','Psaltery'];



(function( $ ){

  $.fn.makeWordsGrabbable = function() {
 this.each( function() {
  var taggedlist='';
  var mytext = $(this).html();
  var mytextlist = mytext.split(' ');
  for (var i=0;i<mytextlist.length;i+=1) {
	if (mytextlist[i].indexOf('<') == -1) {
	  taggedlist += '<li class="dragtemp" style="display:inline;white-space:pre">'+mytextlist[i]+' </li>';
	  }
	else {
	  taggedlist += mytextlist[i];
	  }
	}
  $(this).html('<ul class="dragtemplist">'+taggedlist+'</ul>');
	});

  $('ul.dragtemplist').sortable({revert:140,connectWith:'ul.dragtemplist',placeholder:'dragplaceholder',scroll:true,tolerance:'pointer',
								 update:function(event,ui){$(ui.item).css({'font-weight':'bold'})}});
  $('ul.dragtemplist').disableSelection();
	  
  return this;
  };
})( jQuery );


$('document').ready(function() {
	var lsiurl='/pictures/pcrest'+Math.ceil(Math.random()*14)+'.png';
	$('#logo-second-img').attr('src',lsiurl);

	$('#sidebar-hide-button').click(function() {$('#content .section').css('padding-left','0');$('.region-sidebar-first .section').hide(75);$('.with-navigation #content').css('margin-top','30px');$('#navigation').css({'height':'30px','overflow':'visible'});});	
	$('#top-hide-button').click(function() {$('#content .section').css('padding-left','200px');$('.region-sidebar-first .section').show(75);$('.with-navigation #content').css('margin-top','0');$('#navigation').css({'height':'0','overflow':'hidden'});});
	$('#sidebar-hide-button').click(function() {});
	$('#top-hide-button').click(function() {});

	$('#jabberwockwrapper img').on('mousemove', function(e) {

		//$('#clientx').html(e.offsetX);
		//$('#clienty').html(e.offsetY);
		if  (e.offsetX > 165 && e.offsetX < 1220&& e.offsetY > 150 && e.offsetY < 230) {
			$('#thabg').css('cursor','url(/pictures/jabberwockhead.gif),auto');
			$('p.stanza').one('mouseover',PNEU.boggleme);
			$('#jabberwockwrapper img').off('mousemove');
		}
	});

	$('div.transientnotice').css({'border':'5px solid #cc0000','color':'#cc0000','background-color':'#ccc','padding':'12px','font-size':'16px'}).animate({'opacity': 0},4000, function() {$(this).hide();});

	  
//  if ($('#scrollingdemo').length > 0)  {
// 	// Initialize
// 	$('div#scrollingdemo').append(makeafist());
//
//
// 	var lastScrollPosition = $('#scrollingdemowrapper').scrollTop();
//
// 	//on scroll event
// 	$('div#scrollingdemowrapper').scroll(function(e) {
// 	//console.log($('#scrollingdemowrapper').scrollTop(), lastScrollPosition);
// 		if ($('#scrollingdemowrapper').scrollTop() > lastScrollPosition  )  {
// 			   $('#scrollingdemofakeout').height($('#scrollingdemofakeout').height()+10);
// 			   $('.afist').css('top',function() {return $(this).position().top - ($(this).width() / 25) +'px'});
// 				if (Math.random() > .85) {$('div#scrollingdemo').append(makeafist(100));}
// 			}
// 		else {
// 		//console.log('scrollup');
// 			   $('.afist').css('top',function() {return $(this).position().top + ($(this).width() / 25) +'px'});
// 			}
// 		lastScrollPosition = $('#scrollingdemowrapper').scrollTop();
// 		});
// 	}
//
// });

//Scrolling demo functions
// function makeafist(toppos) {
// if (toppos) {var ftop = toppos;}
// else {var ftop = Math.round(Math.random()*90);}
// var fleft = Math.round(Math.random()*80);
// var fsize = Math.round(Math.random()*200)+50;
// var imagetouse = PNEU.imageselect[$('#scrollimage').val()];
// return '<img class="afist" width="'+fsize+'" src="'+imagetouse+'" style="position:absolute;top:'+ftop+'%;left:'+fleft+'%;" />';
// }
//
// function autoscroll(divcss) {
//  $(divcss).height($(divcss).height()+10);
//  $(divcss).css('top',($(divcss).position().top +10)+'px');
// $('.afist').css('top',function() {return $(this).position().top - ($(this).width() / 25) +'px'});
// if (Math.random() > .85) {$('div#scrollingdemo').append(makeafist(100));}
//  }

