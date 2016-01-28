/* global $ */

$(function (){
  'use strict';

  var $content = $('#content');

  var findVisible = function($orgBrowser){
    var visible = $orgBrowser.find('.visible');
    return {
      el: visible,
      width: visible.width()
    }
  };

  var animateScroll = function ($orgBrowser, direction){
    var visible = findVisible($orgBrowser);
    var offset = direction === 'left'? (visible.el.length - 2) * visible.width : visible.el.length * visible.width;
    $orgBrowser.animate({ scrollLeft: offset }, 400);
  };

  var revealSubteam = function ( $orgBrowser, $target, $subteam ){
    $target.parents('li').addClass('expanded');
    $orgBrowser.find('.team').removeClass('visible');
    $subteam.children().parents('.team').addClass('visible');
  };

  var selectVisibleInput = function($orgBrowser){
    $orgBrowser.find('.visible > h3 > input').prop('checked', 'checked');
  };

  if( $('.org-browser.has-form').length > 0 ){
    var $checked = $('.org-browser.has-form').find('input:checked');
    if( $checked.length > 0 ){
      $checked.parents('.team').addClass('visible');
    }
  }

  $content.on('click', '.show-editable-fields', function (e){
    var $orgBrowser = $(e.target)
                        .closest('.editable-summary')
                        .siblings('.editable-fields')
                        .find('.org-browser');
    $orgBrowser.find('.visible').parents('li').addClass('expanded');
    setTimeout(function (){ animateScroll($orgBrowser); }, 0);
  });

  // title link
  $content.on('click', '.org-browser .team-link', function (e){
    var $target = $(e.target);
    var $orgBrowser = $(e.target).closest('.org-browser');

    // if it's a form
    if( $orgBrowser.hasClass('has-form') ){
        e.preventDefault();
        e.stopPropagation();

        $target.closest('h3').children('input').prop('checked', 'checked');
    }
  });

  $content.on('click', '.org-browser li:not(.disabled) .subteam-link', function(e){
    var $target = $(e.target);
    var $orgBrowser = $(e.target).closest('.org-browser');
    
    if($target.closest('li').hasClass('disabled')){
      console.log('DISABLED');
      return false;
    }

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
    selectVisibleInput($orgBrowser);
    animateScroll($orgBrowser, 'right');
  });

  // back link
  $content.on('click', '.org-browser .team-back', function(e){
    var $target = $(e.target);
    var $orgBrowser = $(e.target).closest('.org-browser');

    e.preventDefault();
    e.stopPropagation();

    var $subteam = $target.parent('.team');
    $target.children('li').removeClass('expanded');
    animateScroll($orgBrowser, 'left');

    // Wait for the scroll back to complete
    setTimeout(function (){
      $subteam.removeClass('visible');
      selectVisibleInput($orgBrowser);
    }, 400);

  });

});

