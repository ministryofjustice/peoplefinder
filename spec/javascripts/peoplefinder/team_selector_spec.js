describe("Team Selector", function() {
  
  var ts,
    obj = $('<div/>'),
    input = $('<input value="123" /><a href="">Technology</a>'),
    teamName = $('<span class="team-led"></span>'),
    orgBrowser = $('<nav class="has-form org-browser"> \
      <div class="team visible"> \
        <h3><input type="radio" value="1" name="person[memberships_attributes][0][group_id]" id="person_memberships_attributes_0_group_id_1" /><a class="team-link" href="/teams/1" title="Ministry of Justice">Ministry of Justice</a></h3> \
        <ul> \
          <li class="has-subteams"> \
            <p> \
              <input type="radio" value="2" name="person[memberships_attributes][0][group_id]" id="person_memberships_attributes_0_group_id_2" /> \
              <a id="digitalLink" class="subteam-link" href="#" title="Digital"> \
                <span class="subteam-name">Digital</span> \
                <span class="subteam-count">1 sub-team</span> \
              </a> \
            </p> \
            <div class="team visible selected"> \
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

  describe("Basic functions", function(){
    it("should remove 'selected' class from all .team elements", function() {
      ts.removeSelected();
      expect(obj.find('.selected').length).toEqual(0);
    });
    it("should get the last '.visible' element", function(){
      var el = ts.getLastVisible().html(),
        last = obj.find('.visible').last().html();
      expect(el).toEqual(last);
    });
    describe("should set '.exapnded' class", function(){
      beforeEach(function(){
        ts.setExpanded();
      });
      setTimeout(function(){
        it("should just do it", function(){
          expect(obj.find('.expanded').length).toEqual(1);
          expect(obj.find('.org-browser > .team > li').hasClass('expanded')).toBe(true);
        });
      }, 500);
    });
    describe("Get and set the current team name", function(){
      it("should get the team name 'Technology'", function() {
        expect(ts.getTeamName(input)).toBe('Technology');
      });
      it("should set the team name to 'Digital'", function() {
        ts.setTeamName('Digital');
        expect(teamName.text()).toBe('Digital team');
      });
    });
  });


  describe("Selecting a subteam", function(){
    beforeEach(function(){
      obj.find('#digitalLink').trigger('click');
    });
    it("should select the Digital radio button", function(){
      expect(orgBrowser.find('input:checked').val()).toEqual('2');
    });
    setTimeout(function(){
      obj.find('#techLink').trigger('click');
      it("should select the Technology radio button", function(){
        expect(orgBrowser.find('input:checked').val()).toEqual('3');
      });
    }, 500);
  });

  describe("Create a new team", function(){
    var teamData = {id:4,name:'Content',parentId:2,parentName:'Digital'};
    describe("Clicking the add team link", function(){
      beforeEach(function(){
          obj.find('#addTeamLink').trigger('click');
      });
      setTimeout(function(){
        it("should display the new team input field", function(){
          expect(obj.find('.new-team').is(':visible')).toBe(true);
        });
      }, 100);
    });

    describe("Clicking the add team link", function(){
      beforeEach(function(){
        ts.addTeamToList(teamData);
      });

      setTimeout(function(){
        it("should create a new radio input", function(){
          expect(orgBrowser.find('input[value="4"]')).toExist();
        });
        it("should hide the new team input field", function(){
          expect(obj.find('.new-team').is(':visible')).toBe(false);
        });
      }, 500);
    });

  });

});