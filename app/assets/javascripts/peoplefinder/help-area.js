$('.help-content').hide()
$('.help-toggle').click(function(){
  $(this).toggleClass('open').next('.help-content').slideToggle('slow');
});