require 'rails_helper'

RSpec.describe Suggestion, type: :model do
  let(:default_suggestion) { described_class.new }

  describe 'for_person?' do
    it 'returns false by default' do
      expect(default_suggestion.for_person?).to eq false
    end
    describe 'missing_fields true' do
      let(:missing_fields_suggested) { described_class.new(missing_fields: true) }
      it 'returns true' do
        expect(missing_fields_suggested.for_person?).to eq true
      end
    end

    describe 'incorrect_fields true' do
      let(:incorrect_fields_suggested) { described_class.new(incorrect_fields: true) }
      it 'returns true' do
        expect(incorrect_fields_suggested.for_person?).to eq true
      end
    end
  end

  describe 'for_admin?' do
    it 'returns false by default' do
      expect(default_suggestion.for_admin?).to eq false
    end

    describe 'duplicate_profile true' do
      let(:duplicate_profile_suggested) { described_class.new(duplicate_profile: true) }
      it 'returns true' do
        expect(duplicate_profile_suggested.for_admin?).to eq true
      end
    end

    describe 'inappropriate_content true' do
      let(:inappropriate_content_suggested) { described_class.new(inappropriate_content: true) }
      it 'returns true' do
        expect(inappropriate_content_suggested.for_admin?).to eq true
      end
    end

    describe 'person_left true' do
      let(:person_left_suggested) { described_class.new(person_left: true) }
      it 'returns true' do
        expect(person_left_suggested.for_admin?).to eq true
      end
    end
  end

  describe '#incorrect_fields_info' do
    let(:suggestion) do
      described_class.new(
        incorrect_first_name: true,
        incorrect_location_of_work: true
      )
    end

    let(:expected_incorrect_fields) { ['First name', 'Location of work'] }

    it 'lists names of incorrect fields' do
      expect(suggestion.incorrect_fields_info).to eql expected_incorrect_fields
    end
  end

  describe '#model_name' do
    it "responds" do
      expect(default_suggestion).to respond_to :model_name
    end
  end

  describe '#to_key' do
    it 'responds' do
      expect(default_suggestion).to respond_to :to_key
    end
  end

  describe '#persisted?' do
    it 'returns false' do
      expect(default_suggestion.persisted?).to eq false
    end
  end

  describe '#valid?' do
    describe 'all problem fields are false' do
      before do
        default_suggestion.valid?
      end

      let(:messages) { default_suggestion.errors.full_messages }

      it 'returns false' do
        expect(default_suggestion.valid?).to eq false
      end

      it 'sets expected error message' do
        expect(messages).to include 'a problem should be selected'
      end
    end

    describe 'missing_fields set to true' do
      describe 'empty missing_fields_info' do
        let(:suggestion) { described_class.new(missing_fields: true) }
        it 'returns false' do
          expect(suggestion.valid?).to eq false
        end
      end

      describe 'set missing_fields_info' do
        let(:missing_fields_info) { 'There were some missing fields' }
        let(:suggestion) { described_class.new(missing_fields: true, missing_fields_info: missing_fields_info) }

        it 'returns true' do
          expect(suggestion.valid?).to eq true
        end
      end
    end

    describe 'incorrect_fields set to true' do
      describe 'no incorrect fields selected' do
        let(:suggestion) { described_class.new(incorrect_fields: true) }
        let(:expected_message) { 'should specify at least one incorrect field' }
        let(:messages) { suggestion.errors.full_messages }

        before { suggestion.valid? }

        it 'returns false' do
          expect(suggestion.valid?).to eq false
        end

        it 'sets expected error message' do
          expect(messages).to include expected_message
        end
      end

      describe 'set at least one incorrect field' do
        let(:suggestion) do
          described_class.new(
            incorrect_fields: true,
            incorrect_first_name: true,
            incorrect_working_days: true
          )
        end

        it 'returns true' do
          expect(suggestion.valid?).to eq true
        end
      end
    end

    describe 'duplicate_profile set to true' do
      let(:suggestion) { described_class.new(duplicate_profile: true) }
      it 'returns true' do
        expect(suggestion.valid?).to eq true
      end
    end

    describe 'inappropriate_content set to true' do
      describe 'empty inappropriate_content_info' do
        let(:suggestion) { described_class.new(inappropriate_content: true) }

        it 'returns false' do
          expect(suggestion.valid?).to eq false
        end
      end

      describe 'set inappropriate_content_info' do
        let(:inappropriate_content_info) { 'Info re: inappropriate content' }
        let(:suggestion) { described_class.new(inappropriate_content: true, inappropriate_content_info: inappropriate_content_info) }

        it 'returns true' do
          expect(suggestion.valid?).to eq true
        end
      end
    end

    describe 'person_left set to true' do
      let(:suggestion) { described_class.new(person_left: true) }
      it 'returns true' do
        expect(suggestion.valid?).to eq true
      end
    end
  end
end
