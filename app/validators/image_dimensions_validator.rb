# A custom validator that validates the dimensions of an uploaded image file
#
# examples:
#   - validates :image, image_dimensions: { min_width: 648, min_height: 648 }
#

class ImageDimensionsValidator < ActiveModel::EachValidator

  attr_reader :record, :attribute, :message

  def validate_each(record, attribute, _value)
    options.assert_valid_keys :min_width, :min_height, :message
    @record = record
    @attribute = attribute
    @message = options[:message]
    validate_minimum_dimensions
  end

  private

  def add_error(record, attribute, message)
    record.errors[attribute] << message
  end

  def validate_minimum_dimensions
    add_error(record, attribute, minimum_dimensions_message) unless minimum_dimensions_valid?
  end

  def minimum_dimensions_required?
    [options[:min_width].present?, options[:min_height].present?].any?
  end

  def minimum_dimensions_valid?
    if minimum_dimensions_required? && record.upload_dimensions.present?
      [
        record.upload_dimensions[:width] >= options[:min_width],
        record.upload_dimensions[:height] >= options[:min_height]
      ].all?
    else
      true
    end
  end

  def humanize_dimensions
    "#{record.upload_dimensions[:width]}x#{record.upload_dimensions[:height]}"
  end

  def humanize_minimum_dimensions
    "#{options[:min_width]}x#{options[:min_height]}"
  end

  def minimum_dimensions_message
    message || "dimensions, #{humanize_dimensions}, must not be less than #{humanize_minimum_dimensions} pixels."
  end

end
