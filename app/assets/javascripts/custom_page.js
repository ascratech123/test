$(window).load(function(){
  
  $("#url_page_type_custom1").click(function(){
    value = $("#url_page_type_custom1").val();
    if (value == "url"){
      $("#custom_page1_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
    }
  }); 
  $("#build_new_page_type_custom1").click(function(){
    value = $("#build_new_page_type_custom1").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page1_site_url").parent().parent().parent().hide();
    }
  });

  $("#url_page_type_custom2").click(function(){
    value = $("#url_page_type_custom2").val();
    if (value == "url"){
      $("#custom_page2_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
    }
  }); 
  $("#build_new_page_type_custom2").click(function(){
    value = $("#build_new_page_type_custom2").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page2_site_url").parent().parent().parent().hide();
    }
  });

  $("#url_page_type_custom3").click(function(){
    value = $("#url_page_type_custom3").val();
    if (value == "url"){
      $("#custom_page3_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
    }
  }); 
  $("#build_new_page_type_custom3").click(function(){
    value = $("#build_new_page_type_custom3").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page3_site_url").parent().parent().parent().hide();
    }
  });

  $("#url_page_type_custom4").click(function(){
    value = $("#url_page_type_custom4").val();
    if (value == "url"){
      $("#custom_page4_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
    }
  }); 
  $("#build_new_page_type_custom4").click(function(){
    value = $("#build_new_page_type_custom4").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page4_site_url").parent().parent().parent().hide();
    }
  });

  $("#url_page_type_custom5").click(function(){
    value = $("#url_page_type_custom5").val();
    if (value == "url"){
      $("#custom_page5_site_url").parent().parent().parent().show();
      $(".ckeditor_custom").hide();
    }
  }); 
  $("#build_new_page_type_custom5").click(function(){
    value = $("#build_new_page_type_custom5").val();
    if (value == "build_new"){
      $(".ckeditor_custom").show();
      $("#custom_page5_site_url").parent().parent().parent().hide();
    }
  });
  
});