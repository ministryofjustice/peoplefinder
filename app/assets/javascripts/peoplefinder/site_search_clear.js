/* global $ */
$(function() {
  'use strict';

  var search_input = $('#site-search-input');
  if(search_input.val() !== '')
  	search_input.addClass('focus');

});
