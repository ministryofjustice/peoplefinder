$(function (){
  "use strict";

  var $orgBrowser = $('.new-org-browser');

  $orgBrowser.children('.team').first().addClass('root-node');

  // title link
  $orgBrowser.on('click', '.team-link', function (e){
    // if it's a form
    if( $orgBrowser.hasClass('has-form') ){
        e.preventDefault();
        e.stopPropagation();

        $(e.target).closest('h3').children('input').prop('checked', 'checked');
    }
  });

  $orgBrowser.on('click', '.subteam-link', function(e){
    var $target = $(e.target);

    if( $target.closest('li').hasClass('has-subteams') == false ){
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
    revealSubteam($target, $subteam);

    animateScroll();
  });

  var revealSubteam = function ( $target, $subteam ){
    $target.parents('li').addClass('expanded');
    $orgBrowser.find('.team').removeClass('visible');
    $subteam.children().parents('.team').addClass('visible');
  }

  var animateScroll = function (){
    var visibles = $orgBrowser.find('.visible');
    var offset = visibles.length * visibles.width();

    $orgBrowser.animate({ scrollLeft: offset }, 400);
  }
});

