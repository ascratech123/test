$(document).ready(function(){
	
	$('.menuIcon.Open').click(function(){
		$(this).parent().next().css('right','0');
		$(this).hide();
		$(this).next().fadeIn();
	});
	
	$('.menuIcon.close').click(function(){
		$(this).parent().next().css('right','-18%');
		$(this).hide();
		$(this).prev().fadeIn();
	});
	
	$('.menuIcon').click(function(){
		
	});
	
});

