require 'rails_helper'

RSpec.describe GeckoboardPublisher::ProfileDuplicatesReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::StringField.new(:full_name, name: 'Duplicate name'),
        Geckoboard::NumberField.new(:count, name: 'No. of duplicates'),
        Geckoboard::StringField.new(:emails, name: 'email list (truncated)')
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items' do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          full_name: "Sid James",
          count: 2,
          emails: 'sid.james@digital.justice.gov.uk, sid.james2@digital.justice.gov.uk'
        },
        {
          full_name: "Peter Smith",
          count: 2,
          emails: 'peter.smith@digital.justice.gov.uk, peter.smith2@digital.justice.gov.uk'
        }
      ]
    end

    before do
      create :person, given_name: 'Sid', surname: 'James', email: 'sid.james@digital.justice.gov.uk'
      create :person, given_name: 'Sid', surname: 'James', email: 'sid.james2@digital.justice.gov.uk'
      create :person, given_name: 'Peter', surname: 'Smith', email: 'peter.smith@digital.justice.gov.uk'
      create :person, given_name: 'Peter', surname: 'Smith', email: 'peter.smith2@digital.justice.gov.uk'
      create :person, given_name: 'Sidney', surname: 'James', email: 'sidney.james@digital.justice.gov.uk'
    end

    include_examples 'returns valid items structure'

    it 'returns expected dataset items' do
      expect(subject.size).to eql 2
      expected_items.each do |item|
        is_expected.to include item
      end
    end

    describe 'truncation of string fields' do

      before do
        stub_const("#{described_class.superclass}::MAX_STRING_LENGTH", 10)
      end

      it 'test stubs max string length' do
        expect(described_class).to have_constant name: :MAX_STRING_LENGTH, value: 10
      end

      it 'truncates email list to geckoboard max string length' do
        expect(subject.first[:emails]).to eq subject.first[:emails][0..9]
      end

    end

  end

end
