$(function(){
   $(document).on("click", "#add-another-budgetary-responsibility", function(e) {
     e.preventDefault();

     var cloneable = $('.budgetary-responsibility:first').clone();
     cloneable.insertAfter('.budgetary-responsibility:last');

     $('.budgetary-responsibility:last-of-type').find("input[type='text']").val("");
     toggle_remove_budget_responsibility_link();
   });

   $(document).on("click", "#remove-last-budgetary-responsibility", function(e) {
     e.preventDefault();

     $('.budgetary-responsibility:last').remove();
     toggle_remove_budget_responsibility_link()
   });

  function toggle_remove_budget_responsibility_link(){
    var visible = ($('.budgetary-responsibility').length < 2 )
    $('#remove-last-budgetary-responsibility').toggleClass('hidden', visible) ;
  }
});
