require 'rails_helper'

RSpec.describe GeckoboardPublisher::ProfilesChangedReport do
  include PermittedDomainHelper

  it_behaves_like 'geckoboard publishable report'

  describe '#fields' do
    subject { described_class.new.fields.map { |field| [field.class, field.id, field.name] } }

    let(:expected_fields) do
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:create, name: 'Added'),
        Geckoboard::NumberField.new(:update, name: 'Edited'),
        Geckoboard::NumberField.new(:destroy, name: 'Deleted')
      ].map { |field| [field.class, field.id, field.name] }
    end

    it { is_expected.to eq expected_fields }
  end

  describe '#items', versioning: true do
    subject { described_class.new.items }

    let(:expected_items) do
      [
        {
          date: "2015-02-28",
          create: 2,
          update: 0,
          destroy: 0
        },
        {
          date: "2015-03-01",
          create: 0,
          update: 2,
          destroy: 0
        },
        {
          date: "2015-03-02",
          create: 0,
          update: 1,
          destroy: 1
        },
        {
          date: "2016-06-30",
          create: 0,
          update: 0,
          destroy: 1
        }
      ]
    end

    before do
      Timecop.freeze(Date.parse('28-FEB-2015')) { create_list(:person, 2) }
      Timecop.freeze(Date.parse('01-MAR-2015')) do
        Person.all.each do |person|
          person.update(description: 'description added')
        end
      end
      Timecop.freeze(Date.parse('02-MAR-2015')) do
        Person.first.destroy
        Person.last.update(description: 'description changed')
      end
      Timecop.freeze(Date.parse('30-JUN-2016')) { Person.destroy_all }
    end

    before { Timecop.freeze Date.parse('01-SEP-2016') }
    after { Timecop.return }

    it { expect(PaperTrail).to be_enabled }

    include_examples 'returns valid items structure'

    it 'returns dates to day precision in ISO 8601 format - YYYY-MM-DD' do
      expect(subject.first[:date]).to match /^(\d{4}-(0[1-9]|1[12])-((0[1-9]|[12]\d)|3[01]))$/
    end

    it 'returns expected dataset items' do
      expect(subject.size).to eql 4
      expected_items.each do |item|
        is_expected.to include item
      end
    end
  end

end
