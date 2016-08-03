$(document).ready(function(){
  $('.newtab').click(function(){
   var el = $(this).attr('data-target');
   $('.agenda_timeline').fadeOut(1000);
   $('.newtab').removeClass('is-active');
   $(this).addClass('is-active');
   $('.'+el).fadeIn(1000);
  });
  $(document).ready(function(){
    $('.owl-carousel').owlCarousel({
      margin:10,
      responsiveClass:true,
       navigation : true,
       pagination: false,
      responsive:{
          0:{
              items:1,
              nav:true
          },
          600:{
              items:2,
              nav:false
          },
          1000:{
              items:5,
              nav:true,
              loop:false
          }
      }
    })
  })  
});