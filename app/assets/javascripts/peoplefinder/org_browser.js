// /* global $ */

// $(function (){
//   'use strict';

//   var $content = $('#content');

//   var $hasMemberships = $('#memberships').length === 1? true : false;

//   var animateScroll = function ($orgBrowser, direction){
//     var visible = $orgBrowser.find('.visible');
//     var offset = direction === 'left'? (visible.length - 2) * visible.width() : visible.length * visible.width();
//     $orgBrowser.animate({ scrollLeft: offset }, 400);
//   };

//   var revealSubteam = function ( $orgBrowser, $target, $subteam ){
//     $target.parents('li').addClass('expanded');
//     $orgBrowser.find('.team').removeClass('visible');
//     $subteam.children().parents('.team').addClass('visible');
//   };

//   var selectCurrent = function($orgBrowser){
//     var teamText, $current;
//     $orgBrowser.find('.team').removeClass('selected');
//     $current = $orgBrowser.find('.visible').last().addClass('selected');
//     $current.find('> h3 > input').prop('checked', 'checked').trigger('change');
//     $current.find('> h3 > a').show()
//   };

//   var getTeamName = function(input){
//     return input.next('a').text();
//   };

//   var setTeamName = function($orgBrowser, teamName){
//     if($hasMemberships){
//       var $teamLed = $orgBrowser.closest('.membership').find('.team-led').text(teamName + ' team');
//     }
//   };

//   var getBreadcrumb = function($orgBrowser, teamName, isSubTeam){
//     var arr = [],
//       selector = isSubTeam? '.team.visible' : '.team.visible:not(.selected)';
//     $orgBrowser.find(selector).each(function(i,obj){
//       var text = $(obj).find('>h3>a').text();
//       arr.push(text);
//     });
//     arr.push(teamName);
//     setBreadcrumb($orgBrowser, createBreadcrumb($orgBrowser, arr));
//   };

//   var createBreadcrumb = function($orgBrowser, arr){
//     var ol = $('<ol/>');
//     $(arr).each(function(i, crumb){
//       var li = $('<li/>').addClass('breadcrumb-'+i).text($.trim(crumb));
//       ol.append(li);
//     });
//     return $(ol);
//   };

//   var setBreadcrumb = function($orgBrowser, str){
//     $orgBrowser.closest('.editable-container').find('.editable-summary .title').html(str);
//   };

//   if( $('.org-browser.has-form').length > 0 ){
//     var $checked = $('.org-browser.has-form').find('input:checked');
//     if( $checked.length > 0 ){
//       $checked.parents('.team').addClass('visible');
//     }
//   }

//   $content.on('click', '.show-editable-fields, .editable-summary', function (e){
//     var $orgBrowser = $(e.target)
//                         .closest('.editable-summary')
//                         .siblings('.editable-fields')
//                         .find('.org-browser');
//     $orgBrowser.find('.visible').parents('li').addClass('expanded');
//     $orgBrowser.find('h3 > a').hide();
//     $orgBrowser.find('.team').removeClass('selected');
//     var $current = $orgBrowser.find('.visible').last().addClass('selected');
//     $current.find('> h3 > a').show()
//     setTimeout(function (){ animateScroll($orgBrowser); }, 0);
//   });

//   // radio input
//   $content.on('change', 'input[type=radio]', function(e){
//     var $target = $(e.target);
//     var $orgBrowser = $(e.target).closest('.org-browser');
//     if($target.is(':checked')){
//       setTeamName($orgBrowser, getTeamName($target));
//     }
//     var isSubTeam = $target.next('a').hasClass('subteam-link')? true : false;
//     getBreadcrumb($orgBrowser, getTeamName($target), isSubTeam);
//   });

//   // title link
//   $content.on('click', '.org-browser .team-link', function (e){
//     var $target = $(e.target);
//     var $orgBrowser = $(e.target).closest('.org-browser');

//     // if it's a form
//     if( $orgBrowser.hasClass('has-form') ){
//         e.preventDefault();
//         e.stopPropagation();

//         $target.closest('h3').children('input').prop('checked', 'checked').trigger('change');
//     }
//   });

//   $content.on('click', '.org-browser li:not(.disabled) .subteam-link', function(e){
//     var $target = $(e.target);
//     var $orgBrowser = $(e.target).closest('.org-browser');

//     if($target.closest('li').hasClass('disabled')){
//       return false;
//     }

//     if( $target.closest('li').hasClass('has-subteams') === false ){
//       if( $orgBrowser.hasClass('has-form') ){
//         // if we're in a form, the link click should select it's radio button
//         e.preventDefault();
//         e.stopPropagation();

//         var input = $target.closest('p').children('input').prop('checked', 'checked').trigger('change');
//       }

//       // if this is a leaf-node, we let the link work as it normally would
//       return;
//     }

//     e.preventDefault();
//     e.stopPropagation();

//     var $subteam = $target.closest('p').siblings('.team');
//     revealSubteam($orgBrowser, $target, $subteam);
//     selectCurrent($orgBrowser);
//     animateScroll($orgBrowser, 'right');
//   });

//   // back link
//   $content.on('click', '.org-browser .team-back', function(e){
//     var $target = $(e.target);
//     var $orgBrowser = $(e.target).closest('.org-browser');

//     e.preventDefault();
//     e.stopPropagation();

//     var $subteam = $target.parent('.team');
//     $target.children('li').removeClass('expanded');
//     animateScroll($orgBrowser, 'left');

//     // Wait for the scroll back to complete
//     setTimeout(function (){
//       $orgBrowser.find('.visible > h3 > a').hide();
//       $subteam.removeClass('visible');
//       selectCurrent($orgBrowser);
//     }, 400);

//   });

//   $('#memberships .membership').each(function(){
//     var _this = $(this),
//       teamName = _this.find('.editable-summary ol li:last-child').text();
//     _this.find('.team-led').text(teamName + ' team');
//   });

// });

