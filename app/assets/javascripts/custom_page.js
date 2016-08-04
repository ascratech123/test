$(window).load(function(){
  $('input[type=radio]').attr('autocomplete','off');

  $("#url_page_type_custom1").click(function(){
    value = $("#url_page_type_custom1").val();
    if (value == "url"){
      $("#custom_page1_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
      $(".show_hide_custome_page1").show();
    }
  }); 

  $("#build_new_page_type_custom1").click(function(){
    value = $("#build_new_page_type_custom1").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page1_site_url").parent().parent().parent().hide();
      $(".show_hide_custome_page1").hide();
    }
  });

  $("#url_page_type_custom2").click(function(){
    value = $("#url_page_type_custom2").val();
    if (value == "url"){
      $("#custom_page2_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
      $(".show_hide_custome_page2").show();
    }
  }); 
  $("#build_new_page_type_custom2").click(function(){
    value = $("#build_new_page_type_custom2").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page2_site_url").parent().parent().parent().hide();
      $(".show_hide_custome_page2").hide();
    }
  });

  $("#url_page_type_custom3").click(function(){
    value = $("#url_page_type_custom3").val();
    if (value == "url"){
      $("#custom_page3_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
      $(".show_hide_custome_page3").show();
    }
  }); 
  $("#build_new_page_type_custom3").click(function(){
    value = $("#build_new_page_type_custom3").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page3_site_url").parent().parent().parent().hide();
      $(".show_hide_custome_page3").hide();
    }
  });

  $("#url_page_type_custom4").click(function(){
    value = $("#url_page_type_custom4").val();
    if (value == "url"){
      $("#custom_page4_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
      $(".show_hide_custome_page4").show();
    }
  }); 
  $("#build_new_page_type_custom4").click(function(){
    value = $("#build_new_page_type_custom4").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page4_site_url").parent().parent().parent().hide();
      $(".show_hide_custome_page4").hide();
    }
  });

  $("#url_page_type_custom5").click(function(){
    value = $("#url_page_type_custom5").val();
    if (value == "url"){
      $("#custom_page5_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
      $(".show_hide_custome_page5").show();
    }
  }); 
  $("#build_new_page_type_custom5").click(function(){
    value = $("#build_new_page_type_custom5").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page5_site_url").parent().parent().parent().hide();
      $(".show_hide_custome_page5").hide();
    }
  });
});