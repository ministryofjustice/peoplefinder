/* global $ */

var TeamAutocomplete = (function (){
  var TeamAutocomplete = {
    transformations: [
      // replace Ministry of Justice with MoJ
      function (o){
        o.innerHTML = o.innerHTML.replace('Ministry of Justice', 'MoJ');
      }
    ],

    formatResults: function ( o ){
      var name, path = '';
      if( o.text === 'MoJ' ){
        name = 'Ministry of Justice';
        path = '';
      }else{
        name = o.text.substring(0, o.text.indexOf('[') - 1);
        path = o.text.substring(o.text.indexOf('['));
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

    enhance: function ( o ){
      TeamAutocomplete.runTransformations(o);

      $(o).select2({
        templateResult: TeamAutocomplete.formatResults
      }).addClass('team-select-enhanced');
    }
  };

  return TeamAutocomplete;
})();

$(function (){
  $('select.select-autocomplete').each(function (i, o){
    TeamAutocomplete.enhance(o);
  });
});
