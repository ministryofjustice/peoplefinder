module Concerns::ProfileFields
  extend ActiveSupport::Concern

  def formatted_buildings
    building.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.building_names')
    end.join(', ')
  end

  def formatted_key_skills
    items = key_skills.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.key_skill_names')
    end.join(', ')
    [items, other_key_skills].compact.reject(&:empty?).join(', ')
  end

  def formatted_learning_and_development
    items = learning_and_development.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.learning_and_development_names')
    end.join(', ')
    [items, other_learning_and_development].compact.reject(&:empty?).join(', ')
  end

  def formatted_networks
    networks.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.network_names')
    end.join(', ')
  end

  def formatted_professions
    professions.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.profession_names')
    end.join(', ')
  end

  def formatted_additional_responsibilities
    items = additional_responsibilities.reject(&:empty?).map do |x|
      I18n.t(x, scope: 'people.additional_responsibility_names')
    end.join(', ')
    [items, other_additional_responsibilities].compact.reject(&:empty?).join(', ')
  end
end
