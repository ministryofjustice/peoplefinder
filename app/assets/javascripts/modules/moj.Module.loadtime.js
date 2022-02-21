// The following script sends the page load time per page to GA

moj.Modules.LoadTime = {

	labels: {
		excellent: 'Under 1 second (Excellent)',
		veryGood: '1 to 2 seconds (Very good)',
		acceptable: '2 to 3 seconds (Acceptable)',
		improve: '3 to 5 seconds (Try improving)',
		fix: 'More than 5 seconds (Needs fixing)'
	},
	category: 'Page load time',

	init: function() {
		window.onload = function() { setTimeout('moj.Modules.LoadTime.pageLoaded()',1000); }
	},

	pageLoaded: function() {
		if(typeof ga === 'undefined') return;
		
		var loadTime = this.getLoadTimeSeconds();
		if(!loadTime || isNaN(loadTime)) return;
		
		var pageName = this.getPageName();
		if(!pageName) return;		
		
		var label = this.labelLoadTime(loadTime);
		
		this.sendEventToGoogle(pageName, label, loadTime);
	},

	getLoadTimeSeconds: function() {
		if(typeof performance === 'undefined' || !performance || !performance.getEntriesByType 
			|| !performance.getEntriesByType('navigation')[0]) return false;

		return performance.getEntriesByType('navigation')[0].duration / 1000;
	},

	getPageName: function() {
		return document.title ? document.title.split('-')[0] : '';
	},

	labelLoadTime: function(loadTime) {
		with(this)
			return 	loadTime < 1 ? labels.excellent : 
						 	loadTime < 2 ? labels.veryGood : 
						 	loadTime < 3 ? labels.acceptable : 
						 	loadTime < 5 ? labels.improve : labels.fix;
	},

	sendEventToGoogle: function(pageName, label, loadTime) {
		ga('send', 'event', this.category, pageName, label, parseInt(loadTime));
	}
}