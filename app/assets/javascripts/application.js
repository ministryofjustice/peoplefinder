/* global moj, $ */
//= require bind
//= require jquery
//= require jquery_ujs
//= require lodash
//= require govuk_toolkit
//= require moj
//= require_tree ./modules


// Eliminate console spam in test output
moj.log = function() {};

$(function() {
  console.log('yooo');
  moj.init();
});