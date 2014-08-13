/* global $ */
$(function(){
  var stashCoords = function(coords) {
    $('#person_crop_x').val(coords.x);
    $('#person_crop_y').val(coords.y);
    $('#person_crop_w').val(coords.w);
    $('#person_crop_h').val(coords.h);
  };

  $('#croppable').Jcrop({
    setSelect: [20, 20, 300, 300],
    onSelect: stashCoords,
    aspectRatio: 1
  });
});
