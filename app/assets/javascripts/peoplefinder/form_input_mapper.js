/* global $ */

function FormInputMapper(element) {
  this._hiddenInput = $(element).find('input[type="hidden"]');
  this.active = !!this._hiddenInput.length;
}

FormInputMapper.prototype.getId = function() {
  return parseInt(this._hiddenInput.attr('value'), 10);
};

FormInputMapper.prototype.setId = function(id) {
  if (!this.active) { return; }
  this._hiddenInput.attr('value', id);
};
