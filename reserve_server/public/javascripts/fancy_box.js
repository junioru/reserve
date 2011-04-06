$(document).ready(function() {

	/* This is basic - uses default settings */
	
	$("a#single_image").fancybox({
            'hideOnContentClick' : 'true'
        });
	
	/* Using custom settings */
	
	$("area#inline").fancybox({
		'hideOnContentClick': false
	});

	/* Apply fancybox to multiple items */
	
	$("a.group").fancybox({
		'transitionIn'	:	'elastic',
		'transitionOut'	:	'elastic',
		'speedIn'		:	600, 
		'speedOut'		:	200, 
		'overlayShow'	:	false
	});
	
});



