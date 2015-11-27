/* global $, _ */

var TeamAutocomplete = (function (){
  var TeamAutocomplete = {
    transformations: [
      // replace Ministry of Justice with MoJ
      function (o){
        if($.trim(o.innerHTML) !== 'Ministry of Justice'){
          o.innerHTML = o.innerHTML.replace('Ministry of Justice', 'MOJ');
        }
      }
    ],

    formatResults: function ( o ){
      var name, path = '';
      if( o.text === 'Ministry of Justice' ){
        name = 'Ministry of Justice';
        path = '<span class="hidden">Ministry of Justice</span>';
      }else{
        name = o.text.substring(0, o.text.indexOf('[') - 1);
        path = o.text.substring(o.text.indexOf('['));
      }

      if( path.length > 70 ){
        var p = path.slice(1, -1).replace('MOJ > ', '');

        path = _.reduce(p.split(' > ').reverse(), function (str, x){
          var nstr = x + ' > ' + str;
          return nstr.length > 70 ? str : nstr;
        });

        path = '[' + path + ']';
      }

      return $( '<span class="team-name">' +
                  name + '</span> <span class="team-path">' +
                  path + '</span>' );
    },

    runTransformations: function (o){
      $(o).find('option').map(function (i2, o2){
        // run each transformation
        $.each(TeamAutocomplete.transformations, function(i3, t){ t(o2); });
      });
    },

    setTeamLedText: function(select, teamLed) {
      if (teamLed != null) {
        var team = select.find('option').filter(':selected');
        if (team != null) {
          teamLed.text(team.text() + ' team');
        }
      }
    },

    enhance: function ( o ){
      TeamAutocomplete.runTransformations(o);

      var teamSelect = $(o).select2({
        templateResult: TeamAutocomplete.formatResults
      });
      var teamLed = $('#team-led');

      teamSelect.addClass('team-select-enhanced');
      teamSelect.on('change', function (e) {
        TeamAutocomplete.setTeamLedText(teamSelect, teamLed);
      });
      TeamAutocomplete.setTeamLedText(teamSelect, teamLed);
    }
  };

  return TeamAutocomplete;
})();

$(function (){
  $('select.select-autocomplete').each(function (i, o){
    TeamAutocomplete.enhance(o);
  });
});
