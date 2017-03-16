# A custom validator that validates the dimensions of an uploaded image file
#
# examples:
#   - validates :image, image_dimensions: { min_width: 648, min_height: 648 }
#

class ImageDimensionsValidator < ActiveModel::EachValidator

  attr_reader :record, :attribute, :message

  def validate_each(record, attribute, _value)
    options.assert_valid_keys :min_width, :min_height, :max_width, :max_height, :message
    @record = record
    @attribute = attribute
    @message = options[:message]
    validate_minimum_dimensions
    validate_maximum_dimensions
  end

  private

  def add_error(record, attribute, message)
    record.errors[attribute] << message
  end

  def validate_minimum_dimensions
    add_error(record, attribute, minimum_dimensions_message) unless minimum_dimensions_valid?
  end

  def validate_maximum_dimensions
    add_error(record, attribute, maximum_dimensions_message) unless maximum_dimensions_valid?
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

  def maximum_dimensions_required?
    [options[:max_width].present?, options[:max_height].present?].any?
  end

  def maximum_dimensions_valid?
    if maximum_dimensions_required? && record.upload_dimensions.present?
      [
        record.upload_dimensions[:width] <= options[:max_width],
        record.upload_dimensions[:height] <= options[:max_height]
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

  def humanize_maximum_dimensions
    "#{options[:max_width]}x#{options[:max_height]}"
  end

  def minimum_dimensions_message
    message ||
      I18n.t(
        :too_small,
        scope: [:errors, :validators, :image_dimensions_validator],
        actual_dimensions: humanize_dimensions,
        expected_dimensions: humanize_minimum_dimensions
      )
  end

  def maximum_dimensions_message
    message ||
      I18n.t(
        :too_big,
        scope: [:errors, :validators, :image_dimensions_validator],
        actual_dimensions: humanize_dimensions,
        expected_dimensions: humanize_maximum_dimensions
      )
  end

end
