/* global $, _ */

var PhotoUpload = (function (){
  'use strict';

  var PhotoUpload = {

    enhance: function ( el ){
      var els = PhotoUpload.findElements(el);

      // els.$input.change(PhotoUpload.preview);
      els.$input.change(PhotoUpload.photoSelected);

      els.$uploadButton.click(PhotoUpload.uploadPhoto);
      els.$cropButton.click(PhotoUpload.cropDone);
    },

    photoSelected: function ( event ){
      var els = PhotoUpload.findElements(event.target);
      els.$uploadButton.removeClass('hidden');
    },

    uploadPhoto: function ( event ){
      event.preventDefault();
      var els = PhotoUpload.findElements(event.target);

      var iframeId = 'photo-upload-iframe-' + ~new Date();
      var iframe = $('<iframe id="' + iframeId + '" name="' + iframeId + '">');
      iframe.hide();
      iframe.load(PhotoUpload.photoUploaded);

      var form = $('<form target="' +
        iframeId +
        '" method="POST" action="/profile_photos" ' +
        'enctype="multipart/form-data">');

      form.append(els.$input);
      form.append($('input[name="authenticity_token"]').clone());
      $(els.$el).append(iframe);
      $(els.$el).append(form);
      PhotoUpload.togglePreviewUploading(els.$preview);
      form.submit();

      els.$label.after(els.$input);
      form.remove();

      els.$preview.data('jcrop').destroy();
    },

    photoUploaded: function ( event ){
      var $iframe = $(event.target);
      var uploadData = $.parseJSON($iframe.contents().text());

      var els = PhotoUpload.findElements($iframe);
      els.$preview.attr('src', uploadData.image.medium.url);
      PhotoUpload.togglePreviewUploading(els.$preview);
      els.$preview.addClass('uploaded-photo');
      PhotoUpload.setupCrop(els);

      console.log(uploadData.id);
      els.$photo_id.data('old-id', els.$photo_id.val());
      els.$photo_id.val(uploadData.id);

      $iframe.remove();
    },

    preview: function ( event ){
      if( !window.FileReader ) {
        return false;
      }

      var els = PhotoUpload.findElements(event.target);
      var file = els.$input[0].files[0];
      var reader = new FileReader();

      reader.onloadend = _.bind(function (){
        els.$preview[0].src = reader.result;
      }, this);

      reader.readAsDataURL(file);
    },

    togglePreviewUploading: function ( $preview, on ){
      var $parent = $preview.closest('.preview-box');

      on = on || !$parent.hasClass('upload-in-progress');
      $parent[on ? 'addClass' : 'removeClass']('upload-in-progress');
    },

    setupCrop: function ( els ){
      var imgw = els.$preview.width();
      // var imgh = els.$preview.height();

      els.$el.addClass('cropping');

      els.$preview.Jcrop({
        setSelect: [20, 20, imgw-20, imgw-20],
        boxWidth:  ($(window).width()*0.80),
        onSelect: function ( cropData ){
          els.$preview.data('new-crop-data', cropData);
        },
        aspectRatio: 1
      }, function (){
        els.$preview.data('jcrop', this);
      });

    },

    cropDone: function ( event ){
      event.preventDefault();

      var els = PhotoUpload.findElements(event.target);
      var cropData = els.$preview.data('new-crop-data');

      els.$crop_x.val(cropData.x);
      els.$crop_y.val(cropData.y);
      els.$crop_w.val(cropData.w);
      els.$crop_h.val(cropData.h);
    },

    findElements: _.memoize(function ( el ){
      var $el           = $(el).closest('.person-photo');
      var $label        = $el.find('label[for="person-image"]');
      var $input        = $el.find('#person-image');
      var $preview      = $el.find('.maginot > img.preview');

      if( !$el.hasClass('person-photo') &&
          $input.length   === 0 &&
          $preview.length === 0 ){
        return new Error('PhotoUpload needs a .person-photo block.');
      }

      return {
        $el:            $el,
        $input:         $input,
        $label:         $label,
        $preview:       $preview,

        $uploadButton:  $el.find('.upload-button-bar .initial-state button'),
        $cropButton:    $el.find('.upload-button-bar .crop-state button'),

        $photo_id     : $el.find('#person_profile_photo_id'),
        $crop_x       : $el.find('#person_crop_x'),
        $crop_y       : $el.find('#person_crop_y'),
        $crop_w       : $el.find('#person_crop_w'),
        $crop_h       : $el.find('#person_crop_h')
      };
    }),

  };

  return PhotoUpload;
})();


$(function (){
  var photoBlocks = $('.person-photo');
  if(photoBlocks.length > 0){
    _.each(photoBlocks, PhotoUpload.enhance);
  }
});
