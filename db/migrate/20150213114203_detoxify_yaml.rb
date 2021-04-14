require 'image_uploader'
require 'person'
class DetoxifyYaml < ActiveRecord::Migration[4.2]
  class Version < ActiveRecord::Base
  end

  def clean_yaml(yaml)
    yaml.gsub(/ !ruby\/object:(Peoplefinder::)?ImageUploader::Uploader\d+/, '')
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
    error_count = 0

    Version.all.each do |version|
      begin
        clean_object_changes version
        clean_object version
      rescue => e
        error_count += 1
        puts "There was a problem #{e} for version #{version.id}"
      end
    end
    puts "There were #{error_count} errors"
  end
end
