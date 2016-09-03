$(document).ready(function(){
  $('ul.tabs li').click(function(){
    var tab_id = $(this).attr('data-tab');

    $('ul.tabs li').removeClass('current');
    $('.tab-content').removeClass('current');

    $(this).addClass('current');
    $("#"+tab_id).addClass('current');
  });
});
  

$(document).ready(function(){
  if ($("#params_value").attr("params_value") == "attendee"){
    $("#attendee").trigger("click");
  }
});

$(document).ready(function(){
  if ($("#params_value").attr("params_value") == "printBadge"){
    $("#printBadge").trigger("click");
  }
});
$(document).ready(function(){
  if ($("#params_registration_value").attr("params_registration_value") == "onsite_registration"){
    $("#registration_tab").trigger("click");
  }
});

// $(document).ready(function(){
//   $('#printBadge').click(function(){
//     $('#get_page').attr( 'for', 'printBadge' )
//   })

//   $('#attendee').click(function(){
//     $('#get_page').attr( 'for', 'attendee' )
//   })  
// });

// $(document).on('click', '#printBadge', function(){
//   var value = $('#get_page').attr('for')
//   alert(value)
// });

// $(document).on('click', '#printBadge', function(){
//   var value = $('#get_page').attr('for')
//   alert(value)
// });

$(document).ready(function(){
  var value = $("#get_page").attr("page")
  if(value == 'attendees'){
    $("#attendee").trigger("click");
  }
  else if (value == 'printbadge')
  {
    $("#printBadge").trigger("click");
  }
});

// $(document).ready(function(){
//   var attr = ($("#params_invitee_page").attr("params_invitee_page") == "invitees_page"){
//     $("#printBadge").trigger("click");
//   }
// });