$(function (){
  "use strict";

  var $orgBrowser = $('.new-org-browser');

  $orgBrowser.children('.team').first().addClass('root-node');

  $orgBrowser.on('click', '.subteam-link', function(e){
    var $target = $(e.target);

    if( $target.closest('li').hasClass('has-subteams') == false ){
      return;
    }

    e.preventDefault();
    e.stopPropagation();

    var $subteam = $target.closest('p').siblings('.team');

    $target.parents('li').addClass('expanded');
    $orgBrowser.find('.team').removeClass('visible');
    $subteam.children().parents('.team').addClass('visible');

    animateScroll();
  });

  var animateScroll = function (){
    $orgBrowser.animate({ scrollLeft: $orgBrowser.width() + 100 }, 400);
  }
});

