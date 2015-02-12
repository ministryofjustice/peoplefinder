require 'peoplefinder/image_uploader'
require 'peoplefinder/person'
class DetoxifyYaml < ActiveRecord::Migration
  class Version < ActiveRecord::Base
  end

  def clean_yaml(yaml)
    yaml.gsub(/ !ruby\/object:Peoplefinder::ImageUploader::Uploader\d+/, '')
  end

  def extract_url(image)
    if image.respond_to?(:url)
      image.url && File.basename(image.url)
    else
      image
    end
  end

  def clean_object_changes(version)
    serialized = version.object_changes
    return if serialized.blank?

    hash = YAML.load(clean_yaml(serialized))
    if hash.key?('image')
      hash['image'].map! { |img| extract_url(img) }
      version.update! object_changes: YAML.dump(hash)
    end
  end

  def clean_object(version)
    serialized = version.object
    return if serialized.blank?

    hash = YAML.load(clean_yaml(serialized))
    if hash.key?('image')
      hash['image'] = extract_url(hash['image'])
      version.update! object: YAML.dump(hash)
    end
  end

  def up
    Version.all.each do |version|
      clean_object_changes version
      clean_object version
    end
  end
end
