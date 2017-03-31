var teamSelector = function teamSelector(isPerson, obj) {

  this.isPerson = isPerson;
  this.selector = $(obj);
  this.orgBrowser = this.selector.find('.org-browser');
  this.editButton = this.selector.find('a.show-editable-fields');
  this.newTeam = this.selector.find('.new-team');
  this.newTeamInput = this.newTeam.find('.new-team-name');
  this.originalTeamLedQuestion = null;

  /* Listen for events */
  this.initEvents = function() {

    var self = this;

    var $buttons = $("label input[type='radio'], label input[type='checkbox']");
    var selectionButtons = new GOVUK.SelectionButtons($buttons);

    if (this.isPerson) {
      teamName = this.selector.find('.editable-summary ol li:last-child').text();
      self.setTeamName(teamName);
    }

    /* Clicking the 'Edit' link to show the team selector */
    this.selector.on('click', '.show-editable-fields, .editable-summary .title', function(e) {

      self.onClick(e);
      self.editButton.hide();
      self.selector.find('.editable-fields').show();
      self.init();
    });
    /* Clicking the 'Done' button to hide the team selector */
    this.selector.on('click', '.hide-editable-fields', function(e) {

      self.onClick(e);
      self.editButton.show();
      self.selector.find('.editable-fields').hide();
      self.selector.find('.team-leader label:first').focus();
    });
    /* Clicking on the 'Back' link */
    this.orgBrowser.on('click', '.team-back', function(e) {

      self.onClick(e);
      self.currentTarget = $(e.currentTarget);
      self.back();
    });
    /* Clicking on a team with subteams */
    this.orgBrowser.on('click', 'li:not(.disabled) .subteam-link', function(e) {

      self.onClick(e);
      self.currentTarget = $(e.currentTarget);
      self.forward();
    });
    /* Clicking on a team with no subteams */
    this.orgBrowser.on('click', '.team-link', function(e) {

      self.onClick(e);
      self.currentTarget = $(e.currentTarget);
      // if it's a form
      if (self.orgBrowser.hasClass('has-form')) {
        e.preventDefault();
        e.stopPropagation();
        self.currentTarget.closest('h3').children('input').prop('checked', 'checked').trigger('change');
      }
    });
    /* Clicking directly on a radio button */
    this.orgBrowser.on('change', 'input[type=radio]', function(e) {

      self.currentTarget = $(e.currentTarget);
      self.currentTarget.focus();
      self.setTeamName(self.getTeamName(self.currentTarget));
      var isSubTeam = self.currentTarget.next('a').hasClass('subteam-link') ? true : false;
      self.getBreadcrumb(isSubTeam);
    });

    this.orgBrowser.on('keypress, keydown', function(e) {
      var keyCode = e.keyCode || e.which || e.charCode,
        target = $(e.target),
        top = target.parent().prev().hasClass('team-back');
      switch (keyCode) {
        case 9: //Tab
        case 13: // Enter
          self.selector.find('.hide-editable-fields').focus();
          break;
        case 37: //Left
        case 38: // Up
          if (top) {
            self.currentTarget = target.parent().prev();
            self.back();
            return false;
          } else {
            var li = target.closest('li').prev('li');
            if (li.hasClass('has-subteams')) {
              li.find('> p > .subteam-link').focus();
              return false;
            } else if (li.hasClass('leaf-node')) {
              li.find('>p>input').prop('checked', 'checked').trigger('change').focus();
              return false;
            }
          }
          break;
        case 40: // Down
          if (top) {
            var subTeam = target.parent().next('ul');
            if (subTeam.length > 0) {
              var li = subTeam.find('li').first();
              if (li.hasClass('leaf-node')) {
                li.find('>p>input').prop('checked', 'checked').trigger('change').focus();
                return false;
              } else {
                li.find('> p > .subteam-link').focus();
              }
              return false;
            }
          } else {
            var li = target.closest('li').next('li');
            if (li.hasClass('leaf-node')) {
              li.find('>p>input').prop('checked', 'checked').trigger('change').focus();
              return false;
            } else {
              li.find('.subteam-link').focus();
              return false;
            }
          }
          break;
        case 39: // Right
          if (target.hasClass('subteam-link')) {
            self.currentTarget = target;
            self.forward();
          }
          return false;
          break;
        default:
          null;
      }
    });

    /* Add New Team */
    this.selector.on('click', '.button-add-team', function(e) {
      self.onClick(e);
      self.toggleTeamInput(true);
    });
    this.newTeam.on('click', '.button', function(e) {
      self.onClick(e);
      self.createNewTeam();
    });
    this.newTeamInput.on('keypress', function(e) {
      var keyCode = e.keyCode || e.which;
      if (keyCode === 13) {
        self.onClick(e);
        self.createNewTeam();
      }
    });
  };

  /* Handle clicks and preventDefault and stopPropagation */
  this.onClick = function(e) {

    e.preventDefault();
    e.stopPropagation();
  };

  /* Set the 'selected' class on the last visible team */
  this.init = function() {

    var self = this;
    this.orgBrowser.find('.team-back').first().remove();
    if (this.orgBrowser.hasClass('has-form')) {
      var $checked = this.orgBrowser.find('input:checked');
      if ($checked.length > 0) {
        $checked.parents('.team').addClass('visible');
        $checked.focus();
      }
    }
    this.setExpanded();
    // Hide all team headings (for testing purposes)
    this.orgBrowser.find('h3 > a').hide();
    this.removeSelected();
    var visible = this.getLastVisible().addClass('selected').find('> h3 > a').show();
    setTimeout(function() {
      self.animateScroll();
    }, 0);
  };

  /*
  Remove the 'expanded' class from current subteams
  Scroll backwards and wait before removing the 'visible' class
  */
  this.back = function() {

    var self = this,
      team = this.currentTarget.parent('.team');
    this.currentTarget.children('li').removeClass('expanded');
    this.animateScroll('left');
    // Wait for the scroll back to complete
    setTimeout(function() {
      self.orgBrowser.find('.visible > h3 > a').hide();
      team.removeClass('visible');
      self.selectCurrent();
    }, 400);
  };

  /* If the team has subteams, find the next team */
  this.forward = function() {

    if (this.currentTarget.closest('li').hasClass('has-subteams') === false) {
      if (this.orgBrowser.hasClass('has-form')) {
        var input = this.currentTarget.closest('p').children('input').prop('checked', 'checked').trigger('change');
        this.setTeamName(this.getTeamName(input));
      }
      // if this is a leaf-node, we let the link work as it normally would
      return;
    }
    var team = this.currentTarget.closest('p').siblings('.team');
    this.revealSubteam(team);
    this.selectCurrent();
    this.animateScroll('right');
  };

  this.getBreadcrumb = function(isSubTeam) {

    var arr = [],
      selector = isSubTeam ? '.team.visible' : '.team.visible:not(.selected)';
    this.orgBrowser.find(selector).each(function(i, obj) {
      var text = $(obj).find('>h3>a').text();
      arr.push(text);
    });
    arr.push(this.getTeamName(this.currentTarget));
    this.orgBrowser.closest('.editable-container').find('.editable-summary .title .breadcrumbs').html(this.createBreadcrumb(arr));
  };

  this.createBreadcrumb = function(arr) {
    var ol = $('<ol/>');
    $(arr).each(function(i, crumb) {
      var li = $('<li/>').addClass('breadcrumb-' + i).text($.trim(crumb));
      ol.append(li);
    });

    return $(ol);
  };

  /* Return the text of the given input element */
  this.getTeamName = function(input) {

    return input.next('a').text();
  };

  /* Set the Team leader heading and hint spans with the given team name */
  this.setTeamName = function(teamName) {

    if (this.isPerson) {
      if (this.originalTeamLedQuestion) {
        this.selector.find('.team-leader legend').html(this.originalTeamLedQuestion);
        this.originalTeamLedQuestion = null;
      }
      this.selector.find('.team-led').text(teamName + ' team');
      if (teamName === 'Ministry of Justice') {
        var legend = this.selector.find('.team-leader legend');
        this.originalTeamLedQuestion = legend.html();
        if (legend.text().indexOf('you')) {
          legend.text('Are you the Permanent Secretary?');
        } else {
          legend.text('Is this person the Permanent Secretary?');
        }
      }
    }
  };

  /* Remove the 'selected' class from all teams */
  this.removeSelected = function() {

    this.orgBrowser.find('.team').removeClass('selected');
  };

  /* Return the last 'visible' team element */
  this.getLastVisible = function() {

    return this.orgBrowser.find('.visible').last();
  };

  /* Set the last 'visible' elements parent li to have the 'expanded' class */
  this.setExpanded = function() {

    this.orgBrowser.find('.visible').parents('li').addClass('expanded');
  };

  /* When moving forward down the subteams */
  this.revealSubteam = function(team) {

    this.setExpanded();
    // Remove the 'visible' class from all teams
    this.orgBrowser.find('.team').removeClass('visible');
    team.children().parents('.team').addClass('visible');
  };

  /* Set the last 'visible' element to be 'selected' and check the radio button, then set the team name */
  this.selectCurrent = function() {

    var teamText, $current;
    this.removeSelected();
    var visible = this.getLastVisible();
    visible.addClass('selected').find('> h3 > input').prop('checked', 'checked').trigger('change');
    visible.find('> h3 > a').show();
  };

  /* Animate the team selector to scroll left or right */
  this.animateScroll = function(direction) {

    var visible = this.orgBrowser.find('.visible');
    var offset = direction === 'left' ? (visible.length - 2) * visible.width() : visible.length * visible.width();
    this.orgBrowser.animate({
      scrollLeft: offset
    }, 400);
  };

  this.toggleTeamInput = function(focus) {

    this.newTeam.toggle();
    if (focus)
      this.newTeamInput.val('').focus();
  };

  this.createNewTeam = function() {

    var self = this,
      input = this.orgBrowser.find('input:checked'),
      teamId = input.val(),
      teamName = input.next('a').text(),
      newTeamName = this.newTeamInput.val();
    if (teamId && newTeamName) {
      $.ajax({
        type: 'POST',
        dataType: 'json',
        url: '/teams',
        data: {
          group: {
            parent_id: teamId,
            name: newTeamName
          }
        },
        success: function(data) {
          data = {
            id: data.id,
            name: data.name,
            parentId: data.parent_id,
            parentName: teamName
          };
          self.addTeamToList(data);
        },
        error: function() {
          self.orgBrowser.before('<div id="flash-messages"><div class="flash-message error" role="alert">There was an error adding the team. Please try again later.</div></div>');
        }
      });
    }
  };

  this.createInput = function(i, id) {

    return '<input type="radio" value="' + id + '" name="person[memberships_attributes][' + i + '][group_id]" id="person_memberships_attributes_' + i + '_group_id_' + id + '">';
  };

  this.createTeamName = function(data) {

    return [
      '<a class="subteam-link" href="#" title="' + data.name + '">',
      '<span class="subteam-name">' + data.name + '</span>',
      '</a>'
    ].join('');
  };

  this.createTeamList = function(i, data) {
    return ['<div class="team">',
      '<a class="team-back" href="#">Back</a>',
      '<h3 class="">',
      this.createInput(i, data.parentId),
      '<a class="team-link" href="#" title="' + data.parentName + '" style="display: none;">' + data.parentName + '</a>',
      '</h3>',
      '<ul>',
      '<li class="leaf-node">',
      '<p>',
      '<input type="radio" value="' + data.id + '" name="person[memberships_attributes][' + i + '][group_id]" id="person_memberships_attributes_' + i + '_group_id_' + data.id + '">',
      this.createTeamName(data),
      '</p>',
      '</li>',
      '</ul>',
      '</div>'
    ].join('');
  };

  this.addTeamToList = function(data) {

    var self = this,
      isSubteam = this.orgBrowser.find('input:checked').next().hasClass('subteam-link') ? true : false,
      input = isSubteam ? $('input[value="' + data.parentId + '"]').closest('li') : $('input[value="' + data.parentId + '"]').parent('h3').next('ul');

    $.each(input, function(i, obj) {
      if (isSubteam) {
        self.currentTarget = self.orgBrowser.find('input:checked').next('.subteam-link');
        var el = self.createTeamList(i, data);
        $(obj).find('.subteam-link').append('<span class="subteam-count">1 sub-team</span>');
        $(obj).attr('class', 'has-subteams').append(el);
        self.forward();
      } else {
        var el = '<p>' +
          self.createInput(i, data.id) + self.createTeamName(data) + '</p>';
        var li = $('<li/>').addClass('leaf-node').html(el);
        $(obj).append(li);
      }
    });
    this.toggleTeamInput();
  };

};

$(function() {

  // Is this the person profile page?
  var isPerson = $('#memberships').length === 1 ? true : false;
  // Which element should we be targeting?
  var selector = isPerson ? '#memberships .membership' : '.editable-container';
  // For each element, set the team name on team leader text and create a new teamSelector
  $(selector).each(function(i, obj) {
    $(obj).addClass('index' + i);
    var team = new teamSelector(isPerson, obj);
    team.initEvents();
  });
});