describe("Team Selector", function() {
  
  var ts,
    obj = $('<div/>'),
    input = $('<input value="123" /><a href="">Technology</a>'),
    teamName = $('<span class="team-led"></span>'),
    orgBrowser = $('<nav class="has-form org-browser"> \
      <div class="team visible"> \
        <h3><input type="radio" value="1" name="person[memberships_attributes][0][group_id]" id="person_memberships_attributes_0_group_id_1" /><a class="team-link" href="/teams/1" title="Ministry of Justice">Ministry of Justice</a></h3> \
        <ul> \
          <li class="has-subteams expanded"> \
            <p> \
              <input type="radio" value="2" name="person[memberships_attributes][0][group_id]" id="person_memberships_attributes_0_group_id_2" /> \
              <a id="digitalLink" class="subteam-link" href="#" title="Digital"> \
                <span class="subteam-name">Digital</span> \
                <span class="subteam-count">1 sub-team</span> \
              </a> \
            </p> \
            <div class="team visible"> \
              <a class="team-back" href="#">Back</a> \
              <h3 class=""> \
                <input type="radio" value="2" name="person[memberships_attributes][0][group_id]" id="person_memberships_attributes_0_group_id_2"> \
                <a class="team-link" href="#" title="Digital">Digital</a> \
              </h3> \
              <ul> \
                <li class="leaf-node"> \
                  <p> \
                    <input type="radio" value="3" name="person[memberships_attributes][0][group_id]" id="person_memberships_attributes_0_group_id_3"> \
                    <a id="techLink" class="subteam-link" href="#" title="Technology"> \
                      <span class="subteam-name">Technology</span> \
                    </a> \
                  </p> \
                </li> \
              </ul> \
            </div> \
          </li> \
        </ul> \
      </div> \
    </nav>'),
    newTeam = $('<a id="addTeamLink" class="button-add-team" href="#">Add new sub-team to the <span class="team-led"></span></a> \
      <div class="new-team"> \
        <label class="form-label-bold" for="person_memberships_attributes_0_addteam">Add new sub-team to the <span class="team-led"></span></label> \
        <input class="form-control new-team-name" id="AddTeam"> \
        <a class="button" href="#">Create</a> \
      </div>');

  
  beforeEach(function(){
    obj.append(orgBrowser);
    obj.append(teamName);
    obj.append(newTeam);
    ts = new teamSelector(true, obj);
    ts.initEvents();
  });

  describe("Get the team name for an input", function(){
    it("should be 'Technology'", function() {
      expect(ts.getTeamName(input)).toBe('Technology');
    });
  });


  describe("Click on team with subteams", function(){
    beforeEach(function(){
      obj.find('#digitalLink').trigger('click');
    });
    it("should select the Digital radio button", function(){
      expect(orgBrowser.find('input:checked').val()).toEqual('2');
    });
    it("should set the team name to 'Digital team'", function() {
      expect(teamName.text()).toEqual('Digital team');
    });
  });

  describe("Select a subteam", function(){
    obj.find('#digitalLink').trigger('click');     
    setTimeout(function(){
      obj.find('#techLink').trigger('click');
      it("should select the Technology radio button", function(){
        expect(orgBrowser.find('input:checked').val()).toEqual('3');
      });
      it("should set the team name to 'Technology team'", function() {
        expect(teamName.text()).toEqual('Technology team');
      });
    }, 500);
  });

  describe("Create a new team", function(){
    var teamData = {id:4,name:'Content',parentId:2,parentName:'Digital'};

    describe("Clicking the add team link", function(){
      beforeEach(function(){
        obj.find('#addTeamLink').trigger('click');
      });
      // it("should display the new team input field", function(){
      //   expect(obj.find('.new-team').is(':visible')).toBe(true);
      // });
    });

    beforeEach(function(){
      ts.addTeamToList(teamData);
    });

    setTimeout(function(){
      it("should create a new radio input", function(){
        expect(orgBrowser.find('input[value="4"]')).toExist();
      });
    }, 500);

  });

});