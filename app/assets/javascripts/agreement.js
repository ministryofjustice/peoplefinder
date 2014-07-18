$(function(){
   return $(document).on("click", "#add-another-budgetary-responsibility", function(e) {
     e.preventDefault();
     var cloneable = $('.budgetary-responsibility:first-of-type').clone();
     cloneable.appendTo('#budgetary-responsibilities');
     $('.budgetary-responsibility:last-of-type').find("input[type='text']").val("");
  });
});
