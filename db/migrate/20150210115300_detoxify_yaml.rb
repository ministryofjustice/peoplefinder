require 'peoplefinder/image_uploader'
require 'peoplefinder/person'
class DetoxifyYaml < ActiveRecord::Migration
  class Version < ActiveRecord::Base
  end

  def up
    Version.all.each do |version|
      serialized = version.object_changes
      serialized.gsub!(/ !ruby\/object:Peoplefinder::ImageUploader::Uploader\d+/, '')
      changes = YAML.load(serialized)
      if changes.key?('image')
        changes['image'].map! do |value|
          value.url && File.basename(value.url)
        end
      end
      version.update! object_changes: YAML.dump(changes)
    end
  end
end
