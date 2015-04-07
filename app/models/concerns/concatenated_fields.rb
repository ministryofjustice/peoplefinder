module Concerns::ConcatenatedFields
  extend ActiveSupport::Concern

  included do
    def self.concatenated_field(name, *fields, join_with: ' ')
      define_method name do
        fields.map { |f| send(f) }.select(&:present?).join(join_with)
      end
    end
  end
end
