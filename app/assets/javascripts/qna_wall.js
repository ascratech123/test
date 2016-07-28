(document).ready(function(){
  function show_menu(){
      var down = document.getElementById('down');
    var up = document.getElementById('up');
  
      if(down.style.display == 'block'){
          down.style.display = 'none';
      up.style.display = 'block';
      }else {
          down.style.display = 'block';                    
      up.style.display = 'none';                    
      }
  }
  function show_menu1(){
      var down1 = document.getElementById('down1');
    var up1 = document.getElementById('up1');
  
      if(down1.style.display == 'none'){
          down1.style.display = 'block';
      up1.style.display = 'none';
      }else {
          down1.style.display = 'none';                    
      up1.style.display = 'block';                    
      }
  }
  function show_menu2(){
      var down2 = document.getElementById('down2');
    var up2 = document.getElementById('up2');
  
      if(down2.style.display == 'none'){
          down2.style.display = 'block';
      up2.style.display = 'none';
      }else {
          down2.style.display = 'none';                    
      up2.style.display = 'block';                    
      }
  }
});