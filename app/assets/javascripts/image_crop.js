$(function(){
  $('#croppable').Jcrop({
      onSelect: stashCoords,
      aspectRatio: 1
    });
  });

function stashCoords(coords) {
  $('#person_crop_x').val(coords.x);
  $('#person_crop_y').val(coords.y);
  $('#person_crop_w').val(coords.w);
  $('#person_crop_h').val(coords.h);
}
