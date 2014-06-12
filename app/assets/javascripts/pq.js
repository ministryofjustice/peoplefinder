
$(document).ready(function () {
	$('#datetimepicker').datetimepicker();
	$(".multi-select-action-officers").select2({width:'250px'});

	$('#allocation_response_response_action_accept').click(function (){
		$('#reason-textarea').addClass('hide');
	});
	$('#allocation_response_response_action_reject').click(function (){
		$('#reason-textarea').removeClass('hide');
	});
	$(".form-commission")
	.on("ajax:success", function(e, data, status, xhr){
		var pqid = $(this).data('pqid');
		$('#commission'+pqid).click();
		//get the div to refresh
		var divToFill = "question_allocation_" + $(this).data('pqid');
		//put the dat returned into the div
		$('#'+divToFill).html(data);
		//clear select list
		$('#action_officers_pq_action_officer_id-'+pqid).select2('data', null);
	}).on("ajax:error", function(e, xhr, status, error) {
		alert('fail');
		//TODO how should ux handle error? Add it to the list, alert, flash, etc...

	});
});  
