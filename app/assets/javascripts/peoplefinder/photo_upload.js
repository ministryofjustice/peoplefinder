/* global $, _ */

var PhotoUpload = (function (){
  'use strict';

  var PhotoUpload = {

    defaultImage: '/assets/medium_no_photo.png',

    enhance: function ( el ){
      var els = PhotoUpload.findElements(el);

      els.$input.change(PhotoUpload.photoSelected);

      els.$uploadButton.click(PhotoUpload.uploadPhoto);
      els.$cropButton.click(PhotoUpload.cropDone);
      els.$cropAgainButton.click(PhotoUpload.cropAgain);
      els.$resetButton.click(PhotoUpload.resetImage);
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
      PhotoUpload.setState(els, 'uploading');
      form.submit();

      els.$label.after(els.$input);
      form.remove();

      if( els.$preview.data('jcrop') ) {
        els.$preview.data('jcrop').destroy();
      }
    },

    photoUploaded: function ( event ){
      var $iframe = $(event.target);
      var jsonText = $iframe.contents().text();
      var uploadData = $.parseJSON(jsonText);

      var els = PhotoUpload.findElements($iframe);
      els.$preview.attr('src', uploadData.image.croppable.url);
      els.$preview.css({clip: ''});
      PhotoUpload.setState(els, 'cropping');
      setTimeout(_.bind(function (){
        PhotoUpload.setupCrop(els);
      }, this), 1000);

      els.$photo_id.data('old-id', els.$photo_id.val());
      els.$photo_id.val(uploadData.id);

      els.$input.val('');
      els.$uploadButton.addClass('hidden');

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
      var $parent = $preview.closest('.maginot');

      on = on || !$parent.hasClass('upload-in-progress');
      $parent[on ? 'addClass' : 'removeClass']('upload-in-progress');
    },

    setupCrop: function ( els ){
      var imgw = els.$preview.width();
      var trueSize = [
        els.$preview.naturalWidth(),
        els.$preview.naturalHeight()
      ];

      els.$preview.Jcrop({
        setSelect: [20, 20, imgw-20, imgw-20],
        trueSize: trueSize,
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
      var previewBoxWidth  = els.$preview.closest('.preview-box').width();
      var naturalWidth  = els.$preview.naturalWidth();

      var xaspect = previewBoxWidth  / naturalWidth;

      els.$crop_x.val(cropData.x);
      els.$crop_y.val(cropData.y);
      els.$crop_w.val(cropData.w);
      els.$crop_h.val(cropData.h);

      var zoomRatio = previewBoxWidth / cropData.w / xaspect;

      els.$preview.data('jcrop').destroy();
      els.$preview.css({
        marginLeft: -1 * xaspect * cropData.x,
        marginTop:  -1 * xaspect * cropData.y,
        zoom: zoomRatio,
        '-moz-transform': 'scale('+ zoomRatio +')'
      });

      PhotoUpload.setState(els, 'cropped');
    },

    cropAgain: function ( event ){
      event.preventDefault();
      PhotoUpload.setupCrop(PhotoUpload.findElements(event.target));
    },

    setState: function ( els, state ){
      var states = ['initial', 'uploading', 'cropping', 'cropped'];

      if( _.contains(states, state) ){
        els.$el.removeClass(states.join(' '));
        els.$el.addClass(state);
      }
    },

    resetImage: function ( event ){
      event.preventDefault();

      var els = PhotoUpload.findElements(event.target);

      els.$preview.attr('src', PhotoUpload.defaultImage);
      els.$preview.attr('style', '');
      els.$photo_id.val('');

      els.$crop_x.val('');
      els.$crop_y.val('');
      els.$crop_w.val('');
      els.$crop_h.val('');

      PhotoUpload.setState(els, 'initial');
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
        $el:      $el,
        $input:   $input,
        $label:   $label,
        $preview: $preview,

        $uploadButton:    $el.find('.upload-button-bar .photo-upload-button'),
        $cropButton:      $el.find('.upload-button-bar .crop-finished-button'),
        $cropAgainButton: $el.find('.crop-again-button'),
        $resetButton:     $el.find('.reset-image-button'),

        $photo_id:  $el.find('#person_profile_photo_id'),
        $crop_x:    $el.find('#person_crop_x'),
        $crop_y:    $el.find('#person_crop_y'),
        $crop_w:    $el.find('#person_crop_w'),
        $crop_h:    $el.find('#person_crop_h')
      };
    }),

  };

  return PhotoUpload;
})();

(function(){
  var makeProp = function (natural, prop) {
    $.fn[natural] = (natural in new Image()) ?
    function () {
      return this[0][natural];
    } :
    function () {
      var
      node = this[0],
      img,
      value;

      if (node.tagName.toLowerCase() === 'img') {
        img = new Image();
        img.src = node.src,
        value = img[prop];
      }
      return value;
    };
  };
  makeProp('naturalWidth', 'width');
  makeProp('naturalHeight', 'height');
})();

$(function (){
  var photoBlocks = $('.person-photo');
  if(photoBlocks.length > 0){
    _.each(photoBlocks, PhotoUpload.enhance);
  }
});
