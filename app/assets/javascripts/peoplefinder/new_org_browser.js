/*
* @Author: dominichey
* @Date:   2014-11-27 11:42:20
* @Last Modified by:   dominichey
* @Last Modified time: 2014-12-02 18:22:43
*
* dummy/prototpye functionality for new org browser
*/

'use strict';

var newList = '<ul class="org-list">'+
  '<li class="org-list-item org-list-group-title">'+
    '<a title="Ministry of Justice" href="#" class="org-list-link">'+
      '<h4>Corporate Services</h4>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
  '<li class="org-list-item org-list-team">'+
    '<a title="Generic Team Name" href="#" class="org-list-link">'+
      '<p class="org-list-team-name">Generic Team Name</p>'+
    '</a>'+
  '</li>'+
'</ul>';

$(function() {

  $('.org-browser').on('click', '.org-list-link', function(e) {
    e.preventDefault();
    var $this = $(this);
    $this.parent().toggleClass( 'org-list-trail' );
    $this.parent().parent().parent().append( newList );
  });

});
