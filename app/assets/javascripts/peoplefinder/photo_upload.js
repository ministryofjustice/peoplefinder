/* global $ */

var PhotoUpload = (function (){
  var PhotoUpload = {

    enhance: function (el){
      var $el = $(el);
      var input = $el.find('#person_image');
      var preview = $el.find('p > img.preview');

      if( !$el.hasClass('person-photo')
          && input.length   == 0
          && preview.length == 0 ){
        return new Error('PhotoUpload needs a person-photo block.');
      }

      input.change(function (event){
        PhotoUpload.preview(input, preview);
      });

    },

    preview: function ( input, preview ){
      if( !window.FileReader )
        return false;

      var file = input[0].files[0];
      var reader  = new FileReader();

      reader.onloadend = _.bind(function (){
        preview[0].src = reader.result;
      }, this);

      reader.readAsDataURL(file);
    }

  }

  return PhotoUpload;
})();


$(function (){
  var photoBlocks = $('.person-photo');
  if(photoBlocks.length > 0){
    _.each(photoBlocks, PhotoUpload.enhance);
  }
});
