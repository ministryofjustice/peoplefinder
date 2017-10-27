module Concerns::ProfileFields
  extend ActiveSupport::Concern

  def formatted_buildings
    building.reject(&:empty?).map do |x|
      I18n.t(x, scope: "people.xuilding.#{x}")
    end.join(', ')
  end

  def formatted_key_skills
    key_skills.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.key_skill_names')
    end.join(', ')
  end

  def formatted_learning_and_development
    learning_and_development.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.learning_and_development_names')
    end.join(', ')
  end

  def formatted_networks
    networks.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.network_names')
    end.join(', ')
  end

  def formatted_key_responsibilities
    key_responsibilities.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.key_responsibility_names')
    end.join(', ')
  end

  def formatted_additional_responsibilities
    additional_responsibilities.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.additional_responsibility_names')
    end.join(', ')
  end
end
