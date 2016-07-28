$(document).ready(function(){
  var start_date = $('.strdate').html().trim(' ');
  var end_date = $('.enddate').html().trim(' ');
  $("#agenda_speaker_id").change(function(){
    value = $("#agenda_speaker_id").val();
    if(value > 0){
      $("#agenda_speaker_name").parent().parent().hide();
    }else if(value == 0){
      $("#agenda_speaker_name").parent().parent().show();
    }
  });
  $("#agenda_agenda_type").click(function(){
    value = $("#agenda_agenda_type").val();
    if(value == "Add New Track")
      $("#agenda_new_category").parent().parent().show();
    else
      $("#agenda_new_category").parent().parent().hide();
    end
  });

  $(window).load(function(){
  $('#agenda_date-start1').bootstrapMaterialDatePicker
      ({
        weekStart: 0, 
        format: 'DD/MM/YYYY',
        time: false,
        minDate : start_date,
        maxDate : end_date
      }).on('change', function(e, date)
      {
        $('#date-end1').bootstrapMaterialDatePicker('setMinDate', date);
        time: false
      });
  $('#date-end1').bootstrapMaterialDatePicker
      ({
        weekStart: 0, 
        format: 'DD/MM/YYYY',
        time: false,
        minDate : start_date,
        maxDate : end_date
      }).on('change', function(e, date)
      {
        $('#agenda_date-start1').bootstrapMaterialDatePicker('setMaxDate', date);
        time: false
      });  
  flightTime();
  minutes();
  times();  
  })
 
// :javascript
//   $('#agenda_start_time_hour,#agenda_start_time_minute,#agenda_end_time_hour,#agenda_end_time_minute').keyup(function(){
//   var value = $(this).val();
//     $(this).toFixed(2);
//   }); 
});
