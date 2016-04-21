var TemplateEngine = function(html, options) {
    var re = /<%([^%>]+)?%>/g, reExp = /(^( )?(if|for|else|switch|case|break|{|}))(.*)?/g, code = 'var r=[];\n', cursor = 0, match;
    var add = function(line, js) {
        js? (code += line.match(reExp) ? line + '\n' : 'r.push(' + line + ');\n') :
            (code += line != '' ? 'r.push("' + line.replace(/"/g, '\\"') + '");\n' : '');
        return add;
    }
    while(match = re.exec(html)) {
        add(html.slice(cursor, match.index))(match[1], true);
        cursor = match.index + match[0].length;
    }
    add(html.substr(cursor, html.length - cursor));
    code += 'return r.join("");';
    return new Function(code.replace(/[\r\t\n]/g, '')).apply(options);
};

var template = 
'<div class="team-card team-card-small" data-id="<% this.slug %>">' +
  '<div class="team-card-inner">' +
    '<div class="team-card-name">' +
      '<a href="/teams/<% this.slug %>">' +
        '<%this.name%>' +
      '</a>' +
    '</div>' +
    '<%if(this.leaderships) {%>' +
      '<%for(var index in this.leaderships) {%>' + 
        '<div class="team-card-leader">' +
          '<div class="team-card-leader-image">' +
            '<div class="maginot">' +
              '<img alt="Current photo of Test User" src="<% this.leaderships[index].person.image %>">' +
              '<div class="barrier"></div>' +
            '</div>' +
          '</div>' +
          '<div class="team-card-leader-details">' +
            '<div><a href="/people/<% this.leaderships[index].person.slug %>"><% this.leaderships[index].person.given_name %></a></div>' +
            '<div><a href="mailto:<% this.leaderships[index].person.email %>"><% this.leaderships[index].person.email %></a></div>' +
            '<div class="tel"><% this.leaderships[index].person.primary_phone_number %></div>' +
          '</div>' +
        '</div>' +
      '<%}%>' +
    '<%}%>' +
    '<%if(this.leaderCount) {%>' +
      '<div class="team-card-more">' +
        '<%this.leaderCount%>' +
      '</div>' +
    '<%}%>' +
    '<div class="team-card-details">' +
      '<%if(this.children.length) {%>' +
        '<div class="team-card-subteams">' +
          '<a href="/teams/<%this.slug%>#teams"><%this.children.length%> teams</a>' +
        '</div>' +
      '<%}%>' +
      '<%if(this.all_people_count) {%>' +
        '<div class="team-card-people">' +
          '<a href="/teams/<%this.slug%>/people"><%this.all_people_count%> people</a>' +
        '</div>' +
      '<%}%>' +
      '<%if(this.children.length) {%>' +
        '<div class="team-card-link">' +
          '<a href="#"></a>' +
        '</div>' +
      '<%}%>' +
    '</div>' +
  '</div>' +
'</div>';

var selectTeam = (function (){
  
  var selectTeam = {
    enhance: function(){
      var self = this;
      $('.team-card-link a').on('click', function(e){
        e.preventDefault();
        e.stopPropagation();
        $(e.currentTarget).toggleClass('expand');
        self.selectParents(e);
      });
    },
    getData: function(){
      var self = this;
      $.getJSON('/teams/'+this.id, function(data){
        self.data = data;
        self.hideOtherTeams(self.teams);
        self.addTeams(data, self.teams);
        self.animate();
      });
    },
    selectParents: function(e){
      var $this = $(e.currentTarget);
      this.parent = $this.closest('.team-card');
      this.teams = this.parent.closest('.teams');
      this.id = this.parent.data('id');
      if($this.hasClass('expand')){
        this.expand();
      } else {
        this.collapse();
      }
    },
    expand: function(){
      this.getData();
    },
    collapse: function(){
      this.removeTeams();
      this.showOtherTeams();
      var parent = this.teams.parent();
      if(parent){
        $('html, body').animate({ scrollTop: $(parent).offset().top }, 'slow');
      }
    },
    showOtherTeams: function(){
      this.teams.removeClass('expanded').find('.team-card').removeClass('hide selected');
    },
    removeTeams: function(){
      this.teams.find('.teams').remove();
    },
    hideOtherTeams: function(teamEl){
      var self = this;
      $.each(teamEl.find('.team-card'), function(i,obj){
        var team = $(obj),
          hide = (team.data('id')===self.id)? false : true;
        team.toggleClass('hide', hide);
        team.toggleClass('selected', !hide);
      });

    },
    addTeams: function(data, teamEl){
      var self = this;
      var newTeams = $('<div/>').addClass('teams');
      teamEl.addClass('expanded').append(newTeams);

      $.each(data.children, function(i,team){
        if(team.leaderships.length > 2){
          var moreLeaders = team.leaderships.length - 2;
          var message = moreLeaders > 1? 'and '+moreLeaders+' more team leaders' : 'and '+moreLeaders+' more team leader';
          team.leaderCount = message;
          team.leaderships.splice(2,2);
        }
        if(team.leaderships.length){
          $.each(team.leaderships, function(i,leader){
            if(leader.person.profile_photo){
              leader.person.image = leader.person.profile_photo.image.url;
            } else {
              leader.person.image = '/assets/'+leader.person.legacy_image.medium.url;
            }
          });
        }
        var newTeam = TemplateEngine(template, team);
        newTeams.append(newTeam);
      });
      newTeams.on('click', '.team-card-link a', function(e){
        e.preventDefault();
        e.stopPropagation();
        $(e.currentTarget).toggleClass('expand');
        self.selectParents(e);
      });

    },
    animate: function(){
      $('html, body').animate({ scrollTop: $(this.teams).offset().top }, 'slow');
    }
  };
  return selectTeam;
})();


$(function(){
  if($('.structure-content').length > 0){
    selectTeam.enhance();
  }
});



