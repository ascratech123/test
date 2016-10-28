
$(document).ready(function(){
  // $("a[href$='.jpg'],a[href$='.png'],a[href$='.gif']").attr('rel', 'gallery')
  $(".fancybox").fancybox({
    openEffect  : 'none',
    closeEffect : 'none',
     helpers : {
            title : null            
        }  
  });
  bg_color_class = $("#theme_background_color").parent().parent().attr("class")
  bg_img_class = $("#1uploadBtn2").parent().parent().parent().parent().attr("class")
  if (bg_color_class == "form-group has-success"){
    $("#1uploadBtn2").parent().parent().parent().parent().removeClass("has-warning");
  }
  if (bg_img_class == "form-group has-success"){
    $("#theme_background_color").parent().parent().parent().removeClass("has-warning");
  }
});

$(document).ready(function(){
  
 $('.table tr').last().addClass('last-tr')
 $('.table tr:nth-last-child(2)').addClass('scndlast-tr')
 
 $('.quiz-checkbox input').change(function() {
    if($(this).is(":checked")) {
      $('.md-checkbox input').attr("disabled", true);
      $(this).attr("disabled", false);
        
    }
    else{
      $('.md-checkbox input').attr("disabled", false);
  
    }
               
  });

	$('.tabclick').click(function(){
	var el = $(this).attr('for');
	var DetailsEvent = $('.'+el).css('display');
		if(DetailsEvent == 'none'){
				$('.tabularlist').slideUp(500);
				$('.'+el).slideDown(500);
			}
			else{
				$('.'+el).slideUp(500);
				}
	});
  /*$('.closeclick').click(function() {
    $('.popup-overlay').hide();
    $('.ClientPopup-info').hide();
    
  })*/
$('.helpTag').click(function(){
section_id = $(this).parent().parent().parent().find(".HelpPopup").attr("id");
var helpPop = $('#' + section_id).css('display');
  if(helpPop == 'none'){
    $('#' + section_id).fadeIn();
    $('.help-popup-overlay').fadeIn();
    
  }
  else{
  $('#' + section_id).fadeOut();
    $('.help-popup-overlay').fadeOut();
  }

})
 $(document).on('focus', '.hours', function(){
      $(this).autocomplete({
        
        select: function(event, ui) {
          $(this).blur();
        }
      });
      $(this).autocomplete('search', ' ')
    });
    $(document).on('focus', '.minutes', function(){
      $(this).autocomplete({
        
        select: function(event, ui) {
          $(this).blur();
        }
      });
      $(this).autocomplete('search', ' ')
    });
$(document).on('focus', '.ampm', function(){
      $(this).autocomplete({
        
        select: function(event, ui) {
          $(this).blur();
        }
      });
      $(this).autocomplete('search', ' ')
    });

$('.HelpPopup').click(function(){

  $('.HelpPopup').fadeOut();
  $('.help-popup-overlay').fadeOut();
  
}).find('.HelpPopup-info').on('click', function (e) {
    e.stopPropagation();
});


$('.closeclick').click(function(){
$('.HelpPopup').fadeOut();
$('.help-popup-overlay').fadeOut();

})


	$('.menuclick').click(function(){
		var menudsp =$('.collapseHide').css('display');
		if(menudsp =='none'){
			$('.collapseHide').slideDown(500);
		}	
		else{

			$('.collapseHide').slideUp(500);
		}
	})
  $('.menuSubclick').click(function(){
    var menudsp =$('.SubMenucollapseHide').css('display');
    if(menudsp =='none'){
      $('.SubMenucollapseHide').slideDown(500);
    } 
    else{

      $('.SubMenucollapseHide').slideUp(500);
    }
  })
  
	$('.FeedBackHide').click(function(){
    var feed = $(this).parent().parent('.feed').next('.FeedBackComment').css('display');
      if(feed == 'none'){
      $('.FeedBackHide').html('show')
      $('.FeedBackComment').slideUp(500);
      $(this).parent().parent('.feed').next('.FeedBackComment').slideDown(500);
      $(this).html('hide')
      }
      else{
      $(this).parent().parent('.feed').next('.FeedBackComment').slideUp(500);
      $(this).html('show')
      }

    }) 

  $('.tabclick').click(function(){
    var el = $(this).attr('for');
    var DetailsEvent = $('.'+el).css('display');
      if(DetailsEvent == 'none'){
          $('.tabularlist').slideUp(500);
          $('.'+el).slideDown(500);
        }
        else{
          $('.'+el).slideUp(500);
          }
  });
  $('.toggleDiv').css("display","none");
		$('.viewMoreLink').click(function(){
			$('.viewMoreLink').html("<span>view less</span>")
			var dsp = $(".toggleDiv").css('display');
			if(dsp == 'flex'){
				$('.toggleDiv').slideUp(500)
				$('.viewMoreLink').html("<span>view more</span>")
			}
			else{
				$('.toggleDiv').slideDown(500)
				$('.viewMoreLink').html("<span>view less</span>")
			}
		})
     
  /*$('.datePicker').each(function() {
  	new Pikaday({
      field: $(this)[0]
    })
  })   
      
  $('.datePicker').trigger('click')*/


	$(".dropDownDiv").click(function(){
		$(this).children('.dropDownUl').slideToggle('fast');
		$('.dropDownDiv').not(this).children('.dropDownUl').slideUp("fast");
	});


	$(".dropDownUl li").click(function(){
       var selectedText = $(this).html();
        $(this).parent().prev().html(selectedText);
    })
	$('.headerdrop').click(function(){
		var droptxt = $(".dropDownUl").css('display');
		if(droptxt == 'none'){
			$('.dropDownUl').slideDown(500)
		}
		else{
			$('.dropDownUl').slideUp(500)
			}
	})

    $('.adminClick').click(function(){
       var selectedText = $('.HideSearchBlog').css('display');
       $('.HideTabularData').slideUp(500);
        if(selectedText == 'none'){
          $('.ml-card-holder.ml-card-holder-first').css('margin-top', '-45px');
          $('.ml-header').css('min-height', '90px');
          $('.HideTabularData').slideUp(500);
          $('.HideSearchBlog').slideDown(500);

        }
        else{

          $('.HideSearchBlog').slideUp(500);
          $('.HideTabularData').slideDown(500);
          $('.ml-card-holder.ml-card-holder-first').css('margin-top', '-84px');
          $('.ml-header').css('min-height', '140px');
        }
    }); 

   $('.collapseminus a').click(function(){
       var selectedText = $('.HideSearchBlog').css('display');
        if(selectedText == 'block'){
          $('.ml-card-holder.ml-card-holder-first').css('margin-top', '-84px');
          $('.ml-header').css('min-height', '140px');
          $('.HideTabularData').slideDown(500);
          $('.HideSearchBlog').slideUp(500);
          

        }
        else{

          $('.HideSearchBlog').slideUp(500);
          $('.HideTabularData').slideDown(500);
        }
    });

    

  $('#date').bootstrapMaterialDatePicker
      ({
        time: false
      });

      $('#time').bootstrapMaterialDatePicker
      ({
        date: false,
       
      });

      $('#date-format').bootstrapMaterialDatePicker
      ({
        format: 'dddd DD MMMM YYYY'
      });
      $('#date-fr').bootstrapMaterialDatePicker
      ({
        format: 'DD/MM/YYYY',
        lang: 'fr',
        weekStart: 1, 
        cancelText : 'ANNULER'
      });

      $('#date-end').bootstrapMaterialDatePicker
      ({
        weekStart: 0, format: 'DD/MM/YYYY',time: false
      });
      $('#date-start,#date-start1').bootstrapMaterialDatePicker
      ({
        weekStart: 0, format: 'DD/MM/YYYY',time: false
      }).on('change', function(e, date)
      {
        $('#date-end').bootstrapMaterialDatePicker('setMinDate', date);
        time: false
      });
        $('#date-end').bootstrapMaterialDatePicker
      ({
        weekStart: 0, format: 'DD/MM/YYYY',time: false
      }).on('change', function(e, date)
      {
        $('#date-start').bootstrapMaterialDatePicker('setMaxDate', date);
        time: false
      });

      $('#min-date').bootstrapMaterialDatePicker({ format : 'DD/MM/YYYY HH:mm',time: false, minDate : new Date() });


 
})

/*menu index when select upload your own*/  
$(window).load(function() {
  $("select").change(function(){
   value = $("#default_feature_icon").val();
    if (value == "owns"){
      $(".feature_icon_upload").show();
    }else{
      $(".feature_icon_upload").hide();
      $(".custom_page2s, .custom_page1s, .custom_page3s, .custom_page4s, .custom_page5s").show();
    }
  });
});

function flightTime() {
    var hours = [
      '01', 
      '02', 
      '03', 
      '04',
      '05', 
      '06', 
      '07', 
      '08', 
      '09', 
      '10',
      '11',
      '12'];
    $('.hours').autocomplete({
      source: hours,
      minLength: 0,
      scroll: false
      }).focus(function() {
        $(this).autocomplete("search", ""); 
      });
  }

  function minutes() {
    var minute = [
      '00',
      '05', 
      '10', 
      '15', 
      '20', 
      '25',
      '30', 
      '35', 
      '40', 
      '45', 
      '50', 
      '55'];
    $('.minutes').autocomplete({
      source: minute,
      minLength: 0,
      scroll: false
      }).focus(function() {
        $(this).autocomplete("search", "");
      });
  }

  function times() {
    var time = [
      'AM', 
      'PM'];
    $('.ampm').autocomplete({
      source: time,
      minLength: 0,
      scroll: false
      }).focus(function() {
        $(this).autocomplete("search", "");
      });
  }


  /* Event Feature and emergency exit form file upload name */
  $(window).load(function(){
    $('.gui-file').change(function(){
      filename = $(this)[0].files[0].name;
      file_id = $(this).attr("id")
      $("#1" + file_id).val(filename);
    });
  }) 
  
  /*telecaller show page */
    $(window).load(function(){
      flightTime();
      minutes();
      times(); 
   })
    
  /* EKit Form */

  $("#tag_select").click(function() {
    var value = $("#tag_select").val();
    if (value != "") {
      $(".tag_list_id").val(value); 
      $(".tag_list_div").addClass( "is-dirty");
    }else{
      $(".tag_list_id").val(value); 
      $(".tag_list_div").removeClass( "is-dirty");
    }  
  });

  /* Conversation index */

  $(window).load(function(){
    $('.headerDownimg').click(function(){
      var drpbox = $(this).hasClass('drpimg');
      if(drpbox == false){
        $(this).css({transform: 'rotateZ(180deg)',MozTransform: 'rotateZ(180deg)',WebkitTransform: 'rotateZ(180deg)',msTransform: 'rotateZ(180deg)'})
        $(this).addClass('drpimg');                                      
      }
      else{
        $(this).css({transform: 'rotateZ(0deg)',MozTransform: 'rotateZ(0deg)',WebkitTransform: 'rotateZ(0deg)',msTransform: 'rotateZ(0deg)'}) 
        $(this).removeClass('drpimg');
      }
    }) 
  });

/* menu index show hide on radio button*/
  $(window).load(function(){
    $(".menu_status_deactive,.menu_status_active").click(function(){
      value = $(this).val() 
      if (value == "active"){
        $(this).parent().parent().parent().parent().next().children().hide();
      }
      if(value == "deactive"){
        $(this).parent().parent().parent().parent().next().children().show();
      }
    });
  });

  /* agenda index page */
  $(window).load(function(){
    $('.newtab').click(function(){
      var el = $(this).attr('data-target');
      $('.agenda_timeline').fadeOut(1000);
      $('.newtab').removeClass('is-active');
      $(this).addClass('is-active');
      $('.'+el).fadeIn(1000);
    });

  $(document).on("click",".ClickPop", function(){
    $('.ClientPopup').hide();
    $('.popup-overlay').hide();
  })

  /* Telecaller show page */
  
  $('#invitee_datum_status').on('change', function() {
    val = $(this).val();
    if(val == "CALL BACK" || val == "FOLLOW UP"){
      $('#date-start,#date-start1').parent().parent().parent().show();
    }
    if(val != "CALL BACK" && val != "FOLLOW UP"){
      $('#date-start,#date-start1').parent().parent().parent().hide();
    }
  });

    /* js for events/invitee/speakers listing filter */ 
  $( document ).ready(function() {   
    $('#search_order_by').on('change', function(){        
      $(".event_index_category_filter_form").submit();            
    });
    $('#search_application_type_by').on('change', function(){  
      $(".event_index_category_filter_form_for_mobile_application").submit();            
    });
    $('#search_order_by_status').on('change', function(){        
      $(".event_index_status_filter_form").submit();            
    });
    $('#search_company_name').on('change', function(){        
      $("#search_invitee_by_cname").submit();            
    });
    $('#search_designation').on('change', function(){        
      $("#search_invitee_by_designation").submit();            
    });
    $('#search_invitee_status').on('change', function(){        
      $("#search_invitee_by_invitee_status").submit();            
    });
    $('#search_visible_status').on('change', function(){        
      $("#search_invitee_by_visible_status").submit();            
    });
    $('#search_login_status').on('change', function(){        
      $("#search_invitee_by_login_status").submit();            
    });
    $('#search_designation').on('change', function(){        
      $("#search_speakers_by_designation").submit();            
    });
    $('#search_company_name').on('change', function(){        
      $("#search_speakers_by_cname").submit();            
    });
  });

  /* Event _Form  start */
    // $('#selectAll').click(function() {
    //   $(':checkbox').each(function() {
    //     this.checked = true;                        
    //   });
    // });  

    // $('#unSelectAll').click(function() {
    //   $(':checkbox').each(function() {
    //     this.checked = false;                        
    //   });
    // });
  /* Event _Form  End */



    // $('.owl-carousel').owlCarousel({
    //   margin:10,
    //   responsiveClass:true,
    //   navigation : true,
    //   pagination: false,
    //   responsive:{
    //     0:{
    //       items:1,
    //       nav:true
    //     },
    //     600:{
    //       items:2,
    //       nav:false
    //     },
    //     1000:{
    //       items:5,
    //       nav:true,
    //       loop:false
    //     }
    //   }
    // })
  });
    
  // Azeem JS START
  

  // Azeem JS END


  /*function showSuccessToast() {
            $().toastmessage('showSuccessToast', "Success Dialog which is fading away ...");
        }
        function showStickySuccessToast() {
            $().toastmessage('showToast', {
                text: 'Success Dialog which is sticky',
                sticky: true,
                position: 'top-right',
                type: 'success',
                closeText: '',
                close: function () {
                    console.log("toast is closed ...");
                }
            });

        }
        function showNoticeToast() {
            $().toastmessage('showNoticeToast', "Notice  Dialog which is fading away ...");
        }
        function showStickyNoticeToast() {
            $().toastmessage('showToast', {
                text: 'Notice Dialog which is sticky',
                sticky: true,
                position: 'top-left',
                type: 'notice',
                closeText: '',
                close: function () { console.log("toast is closed ..."); }
            });
        }
        function showWarningToast() {
            $().toastmessage('showWarningToast', "Warning Dialog which is fading away ...");
        }
        function showStickyWarningToast() {
            $().toastmessage('showToast', {
                text: 'Warning Dialog which is sticky',
                sticky: true,
                position: 'middle-right',
                type: 'warning',
                closeText: '',
                close: function () {
                    console.log("toast is closed ...");
                }
            });
        }
        function showErrorToast() {
            $().toastmessage('showErrorToast', "Error Dialog which is fading away ...");
        }
        function showStickyErrorToast() {
            $().toastmessage('showToast', {
                text: 'Error Dialog which is sticky',
                sticky: true,
                position: 'center',
                type: 'error',
                closeText: '',
                close: function () {
                    console.log("toast is closed ...");
                }
            });
        }*/
  /*$(function () {
    $('#donutchart').highcharts({
        chart: {
            type: 'pie',
            options3d: {
                enabled: true,
                alpha: 45
            }
        },
        title: {
            text: 'Contents of Highsoft\'s weekly fruit delivery'
        },
        subtitle: {
            text: '3D donut in Highcharts'
        },
        plotOptions: {
            pie: {
                innerSize: 100,
                depth: 45
            }
        },
        series: [{
            name: 'Delivered amount',
            data: [
                ['Bananas', 8],
                ['Kiwi', 3],
                ['Mixed nuts', 1],
                ['Oranges', 6],
                ['Apples', 8],
                ['Pears', 4],
                ['Clementines', 4],
                ['Reddish (bag)', 1],
                ['Grapes (bunch)', 1]
            ]
        }]
    });
});

$(function () {
    $('#piechart').highcharts({
        chart: {
            type: 'pie',
            options3d: {
                enabled: true,
                alpha: 45,
                beta: 0
            }
        },
        title: {
            text: 'Browser market shares at a specific website, 2014'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                depth: 35,
                dataLabels: {
                    enabled: true,
                    format: '{point.name}'
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Browser share',
            data: [
                ['Firefox', 45.0],
                ['IE', 26.8],
                {
                    name: 'Chrome',
                    y: 12.8,
                    sliced: true,
                    selected: true
                },
                ['Safari', 8.5],
                ['Opera', 6.2],
                ['Others', 0.7]
            ]
        }]
    });
});      */
$(document).ready(function(){
  $('#event_country_name').on('change', function() {
    var start_date_time = $("#date-start").val();
    /*alert(start_date_time)*/
    if (start_date_time)  
    {  
      $(".overlayBg").show();
      city = $("#event_cities").val();
      country_name = $("#event_country_name").val();
      $.ajax({
        url: '/admin/time_zones',
        type: 'get',
        data: {'city_name' : city, 'country_name' : country_name, 'timestamp' :start_date_time},
        dataType: 'script',
        success: function(data){
          $(".overlayBg").hide();
        }
      });
    }
    else
    {
      alert("Please select event start date");
      $('select#event_country_name option:selected').prop("selected", false);
    }
  });
});

$(document).ready(function(){
  $('#event_cities').blur(function(){
    country_name = $("#event_country_name").val();
    var country = (country_name != "Please select the Time Zone" && country_name != "");
    if(country)
    {  
      var start_date_time = $("#date-start").val();
      if(start_date_time)
      {  
        $(".overlayBg").show();
        city = $("#event_cities").val();
        country_name = $("#event_country_name").val();
        $.ajax({
          url: '/admin/time_zones',
          type: 'get',
          data: {'city_name' : city, 'country_name' : country_name, 'timestamp' :start_date_time},
          dataType: 'script',
          success: function(data){
            $(".overlayBg").hide();
          },
          error: function(xhr, status, error) {
            $(".overlayBg").hide();
          }         
        });
      }
      else
      {
        alert("Please select event start date");
        $('select#event_country_name option:selected').prop("selected", false);
      }  
    }
  });
});

// $(function() {
//   var page = 0
//   if ($('#feed_data_social').size() > 0) {    
//     $(window).on('scroll', function() {
//       page += 1;
//       // if ($(window).scrollTop() > $(document).height() - $(window).height() - 60) {
//       if ($(window).scrollTop() > $(document).height()-2500)  {
//         // alert("scorll");
//         $.ajax({
//           type: "GET",
//           dataType: 'script',
//           url: "/api/v1/social_feeds",
//         });
//       }
//     });
//   }
// });
var load_page = 0
$(window).scroll(function() {
  console.log("scroll");
  if ($(window).scrollTop() > $(document).height()-1000)  {
    $("#loadingText_activity").html('<img src="/assets/spin.gif" width="60" />');     
    $(".load_products").trigger('click',load_page);
    $(".load_products").addClass("dont_load_products").removeClass("load_products");
    return false;
  }
});

$(document).on('click','.load_products',function(){
  load_page += 1;
  load_products(load_page);
});

function load_products(load_page){
  var event_id = $('#social_event_id').attr('for')
  $("#loadingText_activity").show();
  $.ajax({
    type: "GET",
    dataType: 'script',
    url: "/api/v1/events/"+event_id+"/social_feeds.js?page="+load_page,
    success: function(data){
      $("#loadingText_activity").hide();
    },
  });
  // return false;
}


$(document).ready(function(){
  $('.generateCodeBtn a').click(function(){
    $('#instagram_code_label').css('display','block');
    $('#event_instagram_code').css('display','block');
  });
});

$(document).ready(function(){
  $(document).on("click",".newWindow", function(){
    var client_id = $("#event_instagram_client_id").val()
    if(client_id){
      var link = "https://api.instagram.com/oauth/authorize/?client_id="+ client_id +"&redirect_uri=http://hobnobspace.com&response_type=code&scope=public_content"
        window.open(link, "_blank", "toolbar=yes,scrollbars=yes,resizable=yes");
      }  
    else
    {
      alert('Please enter Instagram Client Id.')
    }
  })        
});