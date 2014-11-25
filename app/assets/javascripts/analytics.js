/* exported Track */
/* global $, ga */
var Track = {
	btnEvent: function(btnID, category, action){
		$('#'+btnID).click(function() {
			ga('send', 'event', category, action);
		});
	},
    event: function(category, action){
        ga('send', 'event', category, action);
    }
};