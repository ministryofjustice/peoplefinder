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
      '<a href="#">' +
        '<%this.name%>' +
      '</a>' +
    '</div>' +
    '<%if(this.leaderships) {%>' +
      '<%for(var index in this.leaderships) {%>' + 
        '<div class="team-card-leader">' +
          '<div class="team-card-leader-image">' +
            '<div class="maginot">' +
              '<img alt="Current photo of Test User" src="/uploads/peoplefinder/profile_photo/image/261/medium_medium_Caroline_Ajala.jpg">' +
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
        'and <%this.leaderCount%> more team leader' +
      '</div>' +
    '<%}%>' +
    '<div class="team-card-details">' +
      '<%if(this.children.length) {%>' +
        '<div class="team-card-subteams">' +
          '<a href="/teams/digital#teams"><%this.children.length%> teams</a>' +
        '</div>' +
      '<%}%>' +
      '<%if(this.all_people.length) {%>' +
        '<div class="team-card-people">' +
          '<a href="/teams/digital/people"><%this.all_people.length%> people</a>' +
        '</div>' +
      '<%}%>' +
      '<div class="team-card-link">' +
        '<a href="#"></a>' +
      '</div>' +
    '</div>' +
  '</div>' +
'</div>';

var data = {
  "name": "Digital",
  "teams": [
    {
      "id": 1,
      "name": "Books & Toys",
      "leaders": [
        {
          "name": "Test User",
          "email": "dsa@digital.justice.gov.uk",
          "role": "Programme Manager / Team Lead",
          "tel": "0207111222"
        }
      ],
      "leaderCount": 3,
      "people": 1,
      "teams": 0
    },
    {
      "id": 2,
      "name": "Hardbacks",
      "leaders": [
        {
          "name": "David Jones",
          "email": "dave@digital.justice.gov.uk",
          "role": "Another role"
        }
      ],
      "people": 1,
      "teams": 5
    },
    {
      "id": 3,
      "name": "Industrial, Clothing & Baby",
      "people": 0,
      "teams": 3
    },
    {
      "id": 4,
      "name": "Industrial, Jewelery & Grocery",
      "people": 0,
      "teams": 0
    },
    {
      "id": 5,
      "name": "Movies, Outdoors & Grocery",
      "people": 0,
      "teams": 0
    },
    {
      "id": 6,
      "name": "New Team",
      "people": 0,
      "teams": 2
    },
    {
      "id": 7,
      "name": "Paperbacks",
      "people": 0,
      "teams": 1
    }
  ]
};
var selectTeam = (function (){
  
  var selectTeam = {
    enhance: function(){
      var self = this;
      $('.team-card-link a').on('click', function(e){
        e.preventDefault();
        e.stopPropagation();
        $(e.currentTarget).addClass('expanded');
        self.selectParents(e);
      });
    },
    getData: function(){
      var self = this;
      $.getJSON('/teams/'+this.id, function(data){
        self.data = data;
        self.hideOtherTeams(self.teams);
      });
    },
    selectParents: function(e){
      this.parent = $(e.currentTarget).closest('.team-card');
      this.teams = this.parent.closest('.teams');
      this.id = this.parent.data('id');
      this.getData();
    },
    hideOtherTeams: function(teamEl){
      var self = this;
      $.each(teamEl.find('.team-card'), function(i,obj){
        var team = $(obj),
          hide = (team.data('id')===self.id)? false : true;
        team.toggleClass('hide', hide);
        team.toggleClass('selected', !hide);
      });
      this.addTeams();
    },
    addTeams: function(){
      var self = this;
      var newTeams = $('<div/>').addClass('teams');
      this.teams.addClass('expanded').append(newTeams);
      for(var i=0;i<this.data.children.length;i++){
        var newTeam = TemplateEngine(template, this.data.children[i]);
        newTeams.append(newTeam);
      }
      $('html, body').animate({ scrollTop: $(this.teams).offset().top }, 'slow');
      newTeams.on('click', '.team-card-link a', function(e){
        e.preventDefault();
        e.stopPropagation();
        self.selectParents(e);
      });
    }
  };
  return selectTeam;
})();


$(function(){
  if($('.structure-content').length > 0){
    selectTeam.enhance();
  }
});



