// This is a manifest file that'll be compiled into application.js, which will
// include all the files listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts,
// vendor/assets/javascripts, or vendor/assets/javascripts of plugins, if any,
// can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at
// the bottom of the compiled file.
//
// Read Sprockets README
// (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require select2/select2
//= require lodash
//= require_tree .
//= require bind
//= require selection-buttons

(function() {

  // Prevent form submission caused by pressing 'Enter' key in text fields
  // NOTE: we still want buttons and textareas to respond to CR/NL as expected
  $('input:text').on('keypress', function(e) {
    if (e.keyCode === 13) {
      return false;
    }
  });

}());
