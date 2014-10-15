//= require moj
//= require modules/moj.cookie-message
/* global moj, $ */

// Eliminate console spam in test output
moj.log = function(){};

// Load the cookie message
$(function() {
  moj.init();
});
