require 'rails_helper'

RSpec.describe 'BucketedCompletion' do # rubocop:disable RSpec/DescribeClass
  include PermittedDomainHelper

  context '.bucketed_completion' do
    def create_bucketed_people
      create(:person)
      2.times do
        create(:person, :with_details, city: nil, building: nil)
      end
      create(:person, :with_details, :with_photo)
    end

    before do
      create_bucketed_people
    end

    it 'counts the people in each bucket outputs specific format' do
      expect(Person.bucketed_completion).to eq(
        "[0,19]" => 0,
        "[20,49]" => 0,
        "[50,79]" => 2,
        "[80,100]" => 1
      )
    end
  end
end
