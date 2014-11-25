/* global Track, $ */
/* jshint -W110 */
$(function(){
    //Reviewer invites
    Track.btnEvent('add-reviewer-btn', 'reviewers', 'increment');

    //Invitations accepted/rejected
    $('#invitation-status-update-btn').click(function(){
        var selectedRadioBtn = $("input[name='invitation[status]']:checked")[0];

        if( typeof(selectedRadioBtn) !== 'undefined'){
            var selectedVal = selectedRadioBtn.value;
            var reason = $("textarea[name='invitation[reason_declined]']")[0].value;

            if(selectedVal !== 'declined') {
                Track.event('invitations', selectedVal);
            }else if(reason.length > 0){
                Track.event('invitations', selectedVal);
            }
        }
    });
});