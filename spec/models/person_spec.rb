require 'rails_helper'

RSpec.describe Person, :type => :model do
  let(:person) { build(:person) }
  it { should validate_presence_of(:surname) }
  it { should have_many(:groups) }

  describe '.name' do
    before { person.surname = 'von Brown' }

    context 'with a given_name and surname' do
      it 'should concatenate given_name and surname' do
        person.given_name = 'Jon'
        expect(person.name).to eql('Jon von Brown')
      end
    end

    context 'with a surname only' do
      it 'should use thesurname' do
        expect(person.name).to eql('von Brown')
      end
    end
  end

  context "completion score" do
    it "should be 0 if all fields are empty" do
      person = Person.new
      expect(person.completion_score).to eql(0)
    end

    it "should be 50 if half the fields are filled" do
      person = Person.new(
        given_name: "Bobby",
        surname: "Tables",
        email: "user.example@digital.justice.gov.uk",
        phone: "020 7946 0123",
      )
      expect(person.completion_score).to eql(50)
    end

    it "should be 100 if all fields are filled" do
      person = Person.new(
        given_name: "Bobby",
        surname: "Tables",
        email: "user.example@digital.justice.gov.uk",
        phone: "020 7946 0123",
        mobile: "07700 900123",
        location: "London",
        keywords: "example",
        description: "I am a real person",
      )
      expect(person.completion_score).to eql(100)
    end
  end
end
