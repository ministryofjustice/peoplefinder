require 'rails_helper'

RSpec.describe AuditVersionPresenter, type: :presenter do
  let(:whodunnit)  { 'Tom Smith' }
  let(:event)      { 'update' }
  let(:created_at) { DateTime.now }

  let(:previous_email) { 'f.smith@smithmeister.com' }
  let(:new_email)      { 'f.smith@digital.justice.gov.uk' }
  let(:new_given_name) { 'Fred' }
  let(:new_surname)    { 'Smith' }
  let(:object_changes) {
    "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
    email:
    - #{previous_email}
    - #{new_email}
    given_name:
    -
    - #{new_given_name}
    surname:
    -
    - #{new_surname}"
  }

  let(:version) {
    double('version',
      created_at: created_at,
      whodunnit: whodunnit,
      event: event,
      object_changes: object_changes
    )
  }
  let(:presenter)  { described_class.new(version) }
  let(:changes)    { presenter.changes }

  describe '#event' do
    it 'delegates to version' do
      expect(presenter.event).to eq event
    end
  end

  describe '#whodunnit' do
    it 'delegates to version' do
      expect(presenter.whodunnit).to eq whodunnit
    end
  end

  describe '#created_at' do
    it 'delegates to version' do
      expect(presenter.created_at).to eq created_at
    end
  end

  describe '#changes' do
    it 'contains expected strings' do
      expect(changes).to include("email => #{new_email}")
      expect(changes).to include("given_name => #{new_given_name}")
      expect(changes).to include("surname => #{new_surname}")
    end
  end

  describe ".wrap" do
    let(:object)           { Object.new }
    let(:presenter)        { double('presenter') }
    let(:object_array)     { [object, object, object] }
    let(:wrapped_array)    { described_class.wrap(object_array) }
    let(:presented_array)  { [presenter, presenter, presenter] }

    before do
      allow(described_class).to receive(:new).and_return presenter
    end

    it 'wraps an array of objects' do
      expect(wrapped_array).to eq presented_array
    end
  end
end
