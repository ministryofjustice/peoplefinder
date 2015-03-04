require 'faker'

module Peoplefinder
  class RandomGenerator
    def initialize(group)
      @group = group
    end

    def clear
      @group.descendants.each do |group|
        group.people.each(&:delete)
      end

      @group.descendants.each(&:delete)
    end

    def generate(groups_levels, groups_per_level, people_per_group, domain)
      @groups_levels = groups_levels
      @groups_per_level = groups_per_level
      @people_per_group = people_per_group
      @domain = domain

      generate_level(@group, 0)
    end

  private

    def generate_level(group, level)
      if level == @groups_levels
        @people_per_group.times do
          create_person(group)
        end
      else
        @groups_per_level.times do
          new_group = create_group(group)
          generate_level(new_group, level + 1)
        end
      end
    end

    def create_group(parent)
      parent.children.create(
        name: Faker::Commerce.department,
        description: Faker::Lorem.paragraph
      )
    end

    def create_person(group)
      group.people.create(
        person_attributes.merge(work_days_attributes).merge(location_attributes)
      )
    end

    def person_attributes
      given_name = Faker::Name.first_name
      surname = Faker::Name.last_name

      {
        given_name: given_name,
        surname: surname,
        email: "#{given_name}.#{surname}@#{@domain}",
        primary_phone_number: Faker::PhoneNumber.phone_number,
        secondary_phone_number: Faker::PhoneNumber.phone_number,
        description: Faker::Lorem.sentence
      }
    end

    def work_days_attributes
      {
        works_monday: [true, false].sample,
        works_tuesday: [true, false].sample,
        works_wednesday: [true, false].sample,
        works_thursday: [true, false].sample,
        works_friday: [true, false].sample,
        works_saturday: [true, false].sample,
        works_sunday: [true, false].sample
      }
    end

    def location_attributes
      {
        location_in_building: Faker::Address.secondary_address,
        building: Faker::Address.street_address,
        city: Faker::Address.city
      }
    end
  end
end
