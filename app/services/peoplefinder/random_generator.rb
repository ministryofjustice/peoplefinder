require 'faker'

module Peoplefinder
  class RandomGenerator
    def initialize(group)
      @group = group
    end

    def clear
      @group.descendants.each do |group|
        group.people.each do |person|
          person.delete
        end
      end

      @group.descendants.each do |group|
        group.delete
      end
    end

    def generate(groups_levels, groups_per_level, people_per_group, domain)
      generate_level(@group, 0, groups_levels, groups_per_level, people_per_group, domain)
    end

    private

    def generate_level(group, level, groups_levels, groups_per_level, people_per_group, domain)
      if level == groups_levels
        people_per_group.times do
          create_person(group, domain)
        end
      else
        groups_per_level.times do
          new_group = create_group(group)
          generate_level(new_group, level + 1, groups_levels, groups_per_level, people_per_group, domain)
        end
      end
    end

    def create_group(parent)
      parent.children.create(
        name: Faker::Commerce.department,
        description: Faker::Lorem.paragraph
      )
    end

    def create_person(group, domain)
      given_name = Faker::Name.first_name
      surname = Faker::Name.last_name

      group.people.create(
        given_name: given_name,
        surname: surname,
        email: "#{given_name}.#{surname}@#{domain}",
        primary_phone_number: Faker::PhoneNumber.phone_number,
        secondary_phone_number: Faker::PhoneNumber.phone_number,
        description: Faker::Lorem.sentence,
        works_monday: [true, false].sample,
        works_tuesday: [true, false].sample,
        works_wednesday: [true, false].sample,
        works_thursday: [true, false].sample,
        works_friday: [true, false].sample,
        works_saturday: [true, false].sample,
        works_sunday: [true, false].sample,
        location_in_building: Faker::Address.secondary_address,
        building: Faker::Address.street_address,
        city: Faker::Address.city
      )
    end
  end
end