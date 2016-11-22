require 'rails_helper'

RSpec.describe GeckoboardPublisher::ProfileDuplicatesReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::StringField.new(:full_name, name: 'Duplicate name'),
        Geckoboard::StringField.new(:emails, name: 'email list'),
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
          emails: 'sid.james@digital.justice.gov.uk, sid.james2@digital.justice.gov.uk'
        },
        {
          full_name: "Peter Smith",
          emails: 'peter.smith@digital.justice.gov.uk, peter.smith2@digital.justice.gov.uk'
        }
      ]
    end

    before do
      person = create :person, given_name: 'Sid', surname: 'James', email: 'sid.james@digital.justice.gov.uk'
      person = create :person, given_name: 'Sid', surname: 'James', email: 'sid.james2@digital.justice.gov.uk'
      person = create :person, given_name: 'Peter', surname: 'Smith', email: 'peter.smith@digital.justice.gov.uk'
      person = create :person, given_name: 'Peter', surname: 'Smith', email: 'peter.smith2@digital.justice.gov.uk'
      person = create :person, given_name: 'Sidney', surname: 'James', email: 'sidney.james@digital.justice.gov.uk'
    end

    include_examples 'returns valid items structure'

    it 'returns expected dataset items' do
      expect(subject.size).to eql 2
      expected_items.each do |item|
        is_expected.to include item
      end
    end

  end

end
