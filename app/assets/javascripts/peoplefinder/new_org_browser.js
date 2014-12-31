/* global $ */

$(function (){
  'use strict';

  var $content = $('#content');

  var animateScroll = function ($orgBrowser){
    var visibles = $orgBrowser.find('.visible');
    var offset = visibles.length * visibles.width();

    $orgBrowser.animate({ scrollLeft: offset }, 400);
  };

  var revealSubteam = function ( $orgBrowser, $target, $subteam ){
    $target.parents('li').addClass('expanded');
    $orgBrowser.find('.team').removeClass('visible');
    $subteam.children().parents('.team').addClass('visible');
  };

  if( $('.new-org-browser.has-form').length > 0 ){
    var $checked = $('.new-org-browser.has-form').find('input:checked');
    if( $checked.length > 0 ){
      $checked.parents('.team').addClass('visible');
    }
  }

  $content.on('click', '.show-editable-fields', function (e){
    var $orgBrowser = $(e.target)
                        .closest('.editable-summary')
                        .siblings('.editable-fields')
                        .find('.new-org-browser');
    setTimeout(function (){ animateScroll($orgBrowser); }, 0);
  });

  // title link
  $content.on('click', '.new-org-browser .team-link', function (e){
    var $target = $(e.target);
    var $orgBrowser = $(e.target).closest('.new-org-browser');

    // if it's a form
    if( $orgBrowser.hasClass('has-form') ){
        e.preventDefault();
        e.stopPropagation();

        $target.closest('h3').children('input').prop('checked', 'checked');
    }
  });

  $content.on('click', '.new-org-browser .subteam-link', function(e){
    var $target = $(e.target);
    var $orgBrowser = $(e.target).closest('.new-org-browser');


    if( $target.closest('li').hasClass('has-subteams') === false ){
      if( $orgBrowser.hasClass('has-form') ){
        // if we're in a form, the link click should select it's radio button
        e.preventDefault();
        e.stopPropagation();

        $target.closest('p').children('input').prop('checked', 'checked');
      }

      // if this is a leaf-node, we let the link work as it normally would
      return;
    }

    e.preventDefault();
    e.stopPropagation();

    var $subteam = $target.closest('p').siblings('.team');
    revealSubteam($orgBrowser, $target, $subteam);

    animateScroll($orgBrowser);
  });
});

