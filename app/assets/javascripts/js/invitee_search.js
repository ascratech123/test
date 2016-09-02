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