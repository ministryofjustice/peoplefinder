/* global Track, $ */
/* jshint -W110 */


var reviewerInvites = function(){
    Track.btnEvent('add-reviewer-btn', 'reviewers', 'increment');
};

var invitationsAcceptedOrRejected = function(){
    $('#invitation-status-update-btn').click(function(){
        var selectedRadioBtn = $("input[name='invitation[status]']:checked")[0];

        if( typeof(selectedRadioBtn) !== 'undefined'){
            var selectedVal = selectedRadioBtn.value;
            var reason =
                $("textarea[name='invitation[reason_declined]']")[0].value;

            if(selectedVal !== 'declined') {
                Track.event('invitations', selectedVal);
            }else if(reason.length > 0){
                Track.event('invitations', selectedVal);
            }
        }
    });
};

var formTimings = function() {
    var feedbackForm = $('.submission-form')[0];
    if (typeof(feedbackForm) !== 'undefined') {
        var actionPathArray = feedbackForm.action.split('/');
        var feedbackId = actionPathArray[actionPathArray.length - 1];
        Track.eventDimensions('Feedback', 'Start', {feedbackSlot: feedbackId} );
        Track.startTimer();
        $('button').click(function () {
            Track.timerEvent('Feedback', 'Form completion', 'User input');
            Track.eventDimensions('Feedback', 'Complete',
                {feedbackSlot: feedbackId} );
        });
    }
};

var trackReminders = function(){
    $('.edit_review button').click(function(){
        Track.btnEvent('send-reminder-btn', 'reminders', 'send reminder');
    });

};


$(function(){
    reviewerInvites();
    invitationsAcceptedOrRejected();
    formTimings();
    trackReminders();
});