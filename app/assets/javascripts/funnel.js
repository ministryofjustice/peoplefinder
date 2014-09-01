//= require jquery

/*global ga*/
/*global jQuery*/

var Funnel = {
    attrScope: 'pf',
    source: null,
    init: function(scope, source){
        if(scope){
            this.attrScope = scope;
        }
        if(source){
            this.source = source;
        }
        return this;
    },
    splitDataArgs: function(locator){
       var argString =  jQuery(locator).data('funnel-event');
       var args = [];
       if((typeof(argString) !== 'undefined') && (argString.length > 0)){
            args = argString.replace(/ /g,'').split(',');
       }
       return args;
    },
    sendPageEvent: function(locator){
        var args = this.splitDataArgs(locator);
        ga.apply(['send', 'event'].concat(args));
    },
    sendPageView: function(locator){
        var val = null;
        if(this.source){
            val = jQuery(locator, this.source).data('pageview');
        }else{
            val = jQuery(locator).data('pageview');
        }
        ga('send', val);
    },
    update: function(){
        var locator = '.' + this.attrScope + '-' + 'funnel';
        if(typeof(jQuery(locator).data('pageview')) !== 'undefined'){
            this.sendPageView(locator);
        }
        if(typeof(jQuery(locator).data('funnel-event')) !== 'undefined'){
            this.sendPageEvent(locator);
        }
    }
};

window.Funnel = Funnel;