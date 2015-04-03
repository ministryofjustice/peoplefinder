/* global $, ga */

$(function(){
  'use strict';

  var ifPage = function (klass, f){
    if( $(document.body).hasClass(klass) && f instanceof Function ){
      f();
    }
  };

  var sendEvent = function ( selector, ev, page, eventLabel, text ){
    $(selector)[ev](function (){
        if(ga && ga instanceof Function) {
          ga('send', 'event', page, eventLabel, text);
        }
    });
  };

  // Tracking breadcrumbs on all pages
  sendEvent('.breadcrumbs a', 'click', 'all-pages',
            'all-pages-breadcrumb-clicked',
            'Clicked on a breadcrumb in any page');


  ifPage('login-page', function (){
    sendEvent('input.button', 'click', 'login-page',
              'login-with-email', 'Clicked on "Log in with email" button.');
    sendEvent('a.login-button', 'click', 'login-page',
              'login-with-google', 'Clicked on "Log in with Google" button.');
  });


  ifPage('home-page', function (){
    ga('send', 'event', 'home-page',
       'looking-at-home-page', 'User is looking at the home page');

    sendEvent('form.search-box', 'submit', 'home-page',
              'home-page-search', 'User made a search from the home page');
    sendEvent('.leaf-node a.subteam-link', 'click', 'home-page',
              'home-page-used-the-org-browser',
              'User went to a team page from the org browser');
    sendEvent('.add-new-person', 'click', 'home-page',
              'home-page-add-new-profile', 'User clicked on add new profile');

    $('.new-org-browser').click(function (ev){
      var $self = $(ev.target).closest('.new-org-browser');
      if( !$self.hasClass('tracked-for-click') ){
        ga('send', 'event', 'home-page',
           'home-page-explored-the-org-browser',
           'User clicked on the org browser');
        $self.addClass('tracked-for-click');
      }
    });
  });


  ifPage('search-page', function (){
    ga('send', 'event', 'search-page',
       'looking-at-search-page', 'User is looking at the search page');

    var values = [
      { label: 'search-page-0-results', text: 'No results found for keyword' },
      { label: 'search-page-1-result',  text: '1 result found for keyword' },
      { label: 'search-page-2-results', text: '2 results found for keyword' }
    ];

    var multiValue = {
      label: 'search-page-multiple-results',
      text: 'More than two results found for keyword'
    };

    var resultCount = $('.search-result').length;

    if( resultCount < 3 ){
      ga('send', 'event', 'search-page',
         values[resultCount].label, values[resultCount].text);
    } else {
      ga('send', 'event', 'search-page',
         multiValue.label, multiValue.text);
    }


    var clickValues = [
      { label: 'search-page-click-first-item',
        text: 'User clicked on the first search result' },
      { label: 'search-page-click-second-item',
        text: 'User clicked on the second search result' },
      { label: 'search-page-click-third-item',
        text: 'User clicked on the third search result' },
      { label: 'search-page-click-past-third-item',
        text: 'User clicked on a search result past the third one' }
    ];

    $('.search-result a').click(function (ev){
      var $result = $(ev.target).closest('.search-result');
      var index = $('.search-result').index($result);

      if( index < 3 ){
        ga('send', 'event', 'search-page',
           clickValues[index].label, clickValues[index].text);
      } else {
        ga('send', 'event', 'search-page',
           clickValues[3].label, clickValues[3].text);
      }
    });
  });

  ifPage('team-page', function (){
      ga('send', 'event', 'team-page',
         'looking-at-team-page', 'User is looking at a team\'s page');

      sendEvent('.breadcrumbs a', 'click', 'team-page',
                'team-page-breadcrumb-clicked',
                'Clicked on a breadcrumb in a team\'s page');
  });

  ifPage('profile-page', function (){
    ga('send', 'event', 'profile-page',
       'looking-at-profile-page', 'User is looking at a profile page');

    sendEvent('.breadcrumbs a', 'click', 'profile-page',
              'profile-page-breadcrumb-clicked',
              'Clicked on a breadcrumb in a profile page');
  });

  ifPage('edit-profile-page', function() {
    $('.membership-subscribed-check-box').change(function(e) {
      if (e.target.checked) {
        ga('send', 'event', 'edit-profile-page',
           'check', 'Check team updates');
      } else {
        ga('send', 'event', 'edit-profile-page',
           'uncheck', 'Uncheck team updates');
      }
    });
  });
});
