/* exported Track */
/* global $, ga */
var Track = {
    timer: 0,
	btnEvent: function(btnID, category, action){
		$('#'+btnID).click(function() {
			ga('send', 'event', category, action);
		});
	},
    event: function(category, action){
        ga('send', 'event', category, action);
    },
    startTimer: function(){
        this.timer = new Date().getTime();
    },
    timeSinceStart: function(){
        return (new Date().getTime() - this.timer);
    },
    timerEvent: function(category, timingVar, label){
        var timeSpent = this.timeSinceStart();
        ga('send', 'timing', category, timingVar, timeSpent, label);
    }
};