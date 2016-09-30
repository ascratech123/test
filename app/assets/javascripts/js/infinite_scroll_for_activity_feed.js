$(window).scroll(function(){
  if($("#load-more-posts").length > 0){
    if($("#load-more-posts").offset().top - 1500 <= $(window).scrollTop()){
        $("#loadingText").html("Loading ...");      
        $("#load-more-posts")[0].click();
        $("#load-more-posts").attr("id", "dont-load-more-posts")
    }
   }
});