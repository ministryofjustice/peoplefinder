
var teamSelector = function teamSelector(isPerson, obj){
	this.isPerson = isPerson;
	this.selector = $(obj);
	this.orgBrowser = this.selector.find('.org-browser');
	this.editButton = this.selector.find('a.show-editable-fields');
	this.teamInput = $('<div/>').addClass('new-team');
	var input = $('<fieldset><input type="text class="form-control" id="newTeamName" /></fieldset>');
	var submit = $('<input type="button" name="addTeam" id="addTeam" value="Create" class="button">');
	this.teamInput.append(input).append(submit);

	this.enhance = function(){
		if( this.orgBrowser.hasClass('has-form') ){
	    var $checked = this.getCheckedInput();
	    if( $checked.length > 0 ){
	      $checked.parents('.team').addClass('visible');
	    }
	  }
	  this.initEvents();
	};

	/* Listen for events */
	this.initEvents = function(){
		var self = this;
		/* Clicking the 'Edit' link to show the team selector */
		this.selector.on('click', '.show-editable-fields, .editable-summary .title', function (e){
			e.preventDefault();
  		e.stopPropagation();
  		self.editButton.hide();
    	self.selector.find('.editable-fields').show();
			self.init();
		});
		/* Clicking the 'Done' button to hide the team selector */
		this.selector.on('click', '.hide-editable-fields', function (e){
			e.preventDefault();
  		e.stopPropagation();
  		self.editButton.show();
    	self.selector.find('.editable-fields').hide();
		});
		/* Clicking on the 'Back' link */
		this.orgBrowser.on('click', '.team-back', function (e){
			e.preventDefault();
  		e.stopPropagation();
			self.currentTarget = $(e.currentTarget);
			self.back();
		});
		/* Clicking on a team with subteams */
		this.orgBrowser.on('click', 'li:not(.disabled) .subteam-link', function (e){
			e.preventDefault();
  		e.stopPropagation();
			self.currentTarget = $(e.currentTarget);
			self.forward();
		});
		/* Clicking on a team with no subteams */
		this.orgBrowser.on('click', '.team-link', function (e){
			e.preventDefault();
  		e.stopPropagation();
			self.currentTarget = $(e.currentTarget);
			// if it's a form
	    if( self.orgBrowser.hasClass('has-form') ){
        e.preventDefault();
        e.stopPropagation();
        self.currentTarget.closest('h3').children('input').prop('checked', 'checked').trigger('change');
	    }
		});
		/* Clicking directly on a radio button */
		this.orgBrowser.on('change', 'input[type=radio]', function(e){
	    self.currentTarget = $(e.currentTarget);
	    self.setTeamName(self.getTeamName(self.currentTarget));
	    var isSubTeam = self.currentTarget.next('a').hasClass('subteam-link')? true : false;
  		self.getBreadcrumb(isSubTeam);
	  });

	  this.orgBrowser.on('click', '.add-team', function (e){
			e.preventDefault();
  		e.stopPropagation();
			self.currentTarget = $(e.currentTarget);
			self.showTeamInput();
	  });

	  this.orgBrowser.on('click', '#addTeam', function (e){
			e.preventDefault();
  		e.stopPropagation();
			self.currentTarget = $(e.currentTarget);
			self.createNewTeam();
	  });

	  this.orgBrowser.on('keypress', '#newTeamName', function(e){
  		if(e.keyCode === 13){
		  	e.preventDefault();
	  		e.stopPropagation();
  			self.createNewTeam();
  		}
	  });
	};

	/*
	Set the 'selected' class on the last visible team
	*/
	this.init = function(){
		var self = this;
	  this.setExpanded();
	  // Hide all team headings (for testing purposes)
	  this.orgBrowser.find('h3 > a').hide();
	  this.removeSelected();
	  var visible = this.getLastVisible().addClass('selected').find('> h3 > a').show();
	  setTimeout(function (){ self.animateScroll(); }, 0);
	};

	/* 
	Remove the 'expanded' class from current subteams
	Scroll backwards and wait before removing the 'visible' class
	*/ 
	this.back = function(){
		var self = this, 
			team = this.currentTarget.parent('.team');
    this.currentTarget.children('li').removeClass('expanded');
    this.animateScroll('left');
    // Wait for the scroll back to complete
    setTimeout(function (){
      self.orgBrowser.find('.visible > h3 > a').hide();
      team.removeClass('visible');
      self.selectCurrent();
    }, 400);
	};

	/* If the team has subteams, find the next team */
	this.forward = function(){
		if( this.currentTarget.closest('li').hasClass('has-subteams') === false ){
      if( this.orgBrowser.hasClass('has-form') ){
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

	this.getBreadcrumb = function(isSubTeam){
    var arr = [],
      selector = isSubTeam? '.team.visible' : '.team.visible:not(.selected)';
    this.orgBrowser.find(selector).each(function(i,obj){
      var text = $(obj).find('>h3>a').text();
      arr.push(text);
    });
    arr.push(this.getTeamName(this.currentTarget));
    this.orgBrowser.closest('.editable-container').find('.editable-summary .title').html(this.createBreadcrumb(arr));
  };

  this.createBreadcrumb = function(arr){
    var ol = $('<ol/>');
    $(arr).each(function(i, crumb){
      var li = $('<li/>').addClass('breadcrumb-'+i).text($.trim(crumb));
      ol.append(li);
    });
    return $(ol);
  };

	// Return the input element that is check
	this.getCheckedInput = function(){
		return this.orgBrowser.find('input:checked')
	};

	// Return the text of the given input element
	this.getTeamName = function(input){
    return input.next('a').text();
  };

  // Set the Team leader heading and hint spans with the given team name
	this.setTeamName = function(teamName){
    if(this.isPerson){
      this.selector.find('.team-led').text(teamName + ' team');
    }
  };

  // Remove the 'selected' class from all teams
  this.removeSelected = function(){
  	this.orgBrowser.find('.team').removeClass('selected');
  };

  // Return the last 'visible' team element
  this.getLastVisible = function(){
  	return this.orgBrowser.find('.visible').last();
  };

  // Set the last 'visible' elements parent li to have the 'expanded' class
  this.setExpanded = function(){
  	this.orgBrowser.find('.visible').parents('li').addClass('expanded');
  };

  // When moving forward down the subteams
  this.revealSubteam = function (team){
    this.setExpanded();
    // Remove the 'visible' class from all teams
    this.orgBrowser.find('.team').removeClass('visible');
    team.children().parents('.team').addClass('visible');
  };

  // Set the last 'visible' element to be 'selected' and check the radio button, then set the team name
  this.selectCurrent = function(){
    var teamText, $current;
    this.removeSelected();
    var visible = this.getLastVisible();
    visible.addClass('selected').find('> h3 > input').prop('checked', 'checked').trigger('change');
    visible.find('> h3 > a').show();
  };

  // Animate the team selector to scroll left or right
  this.animateScroll = function(direction){
    var visible = this.orgBrowser.find('.visible');
    var offset = direction === 'left'? (visible.length - 2) * visible.width() : visible.length * visible.width();
    this.orgBrowser.animate({ scrollLeft: offset }, 400);
    this.showTeamLink();
  };

  this.createNewTeamLink = function(){
  	this.orgBrowser.find('.team ul').each(function(i, obj){
	  	var link = $('<li/>').addClass('add-team').html('<a href="#">Create new team</>');
  		$(obj).append(link);
  	});
  };

  this.showTeamLink = function(){
  	this.teamInput.hide();
  	this.orgBrowser.find('.add-team').show();
  };

  this.showTeamInput= function(){
  	var el = this.currentTarget.hide().parent();
  	el.append(this.teamInput.show());
  	this.orgBrowser.find('#newTeamName').val('').focus();
  };

  this.createNewTeam = function(){
  	var self = this,
  		teamID = this.orgBrowser.find('.selected>h3>input').val(),
  		teamName = this.orgBrowser.find('#newTeamName').val();
  	$.ajax({
  		url: 'test',
  		data: {id: teamID, name: teamName},
  		success: function(data){
		  	data = {id:999,name:teamName,parentID:teamID};
		  	self.addTeamToList(data);
		  	
  		},
  		error: function(){
  			console.log('error');
  			data = {id:999,name:teamName,parentID:teamID};
  			self.addTeamToList(data);
  		}
  	});
  };

  this.addTeamToList = function(data){
  	var list = $('input[value="'+data.parentID+'"]').parent('h3').next('ul');
  	$.each(list, function(i, obj){
	  	var item = $('<p> \
	  			<input type="radio" value="'+data.id+'" name="person[memberships_attributes]['+i+'][group_id]" id="person_memberships_attributes_0_group_id_'+data.id+'"> \
	  			<a class="subteam-link" href="/teams/industrial-jewelery-grocery" title="'+data.name+'"> \
	  				<span class="subteam-name">'+data.name+'</span> \
	  			</a> \
	  		</p>');
	  	var li = $('<li/>').addClass('leaf-node').html(item);
	  	$(obj).find('>.add-team').before(li);
  	});
  	this.showTeamLink();
  };

};

$(function (){
  // Is this the person profile page?
  var isPerson = $('#memberships').length === 1? true : false;
  // Which element should we be targeting?
  var selector = isPerson? '#memberships .membership' : '.editable-container';
  // For each element, set the team name on team leader text and create a new teamSelector
  $('#memberships .membership').each(function (i, obj){
    $(obj).addClass('index'+i);
    if(isPerson){
    	teamName = $(obj).find('.editable-summary ol li:last-child').text();
    	$(obj).find('.team-led').text(teamName + ' team');
    }
    var team = new teamSelector(isPerson, obj);
    team.enhance();
    team.createNewTeamLink();
  });
});