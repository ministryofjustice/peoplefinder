
$(document).ready(function () {
    $('#datetimepicker').datetimepicker();
    $("#action_officers_pq_action_officer_id").select2({ width: '250px' });

    $('#allocation_response_response_accept').click(function (){
        $('#reason-textarea').addClass('hide');
    })
    $('#allocation_response_response_reject').click(function (){
        $('#reason-textarea').removeClass('hide');
    })
});

