require 'rails_helper'

RSpec.describe PersonUpload, type: :model do
  let(:group) { double(Group, id: 42) }
  let(:file) { double(File, read: 'contents') }
  subject { described_class.new(group_id: group.id, file: file) }

  before do
    allow(Group).to receive(:where).with(id: group.id).and_return([group])
    allow(CsvPeopleImporter).to receive(:new).with('contents', groups: [group])
  end

  context 'with a valid upload' do
    describe 'save' do
      it 'initialises a CsvPeopleImporter with the file contents and groups' do
        importer = double(CsvPeopleImporter, import: 1, errors: [])
        expect(CsvPeopleImporter).to receive(:new).
          with('contents', groups: [group]).
          and_return(importer)
        subject.save
      end

      it 'returns falsy if upload failed' do
        importer = double(CsvPeopleImporter, import: nil, errors: [])
        allow(CsvPeopleImporter).to receive(:new).and_return(importer)

        expect(subject.save).to be_falsy
      end

      it 'returns truthy if upload succeeded' do
        importer = double(CsvPeopleImporter, import: 1, errors: [])
        allow(CsvPeopleImporter).to receive(:new).and_return(importer)

        expect(subject.save).to be_truthy
      end
    end

    describe 'import_count' do
      it 'returns the number of items uploaded after save' do
        importer = double(CsvPeopleImporter, import: 1, errors: [])
        allow(CsvPeopleImporter).to receive(:new).and_return(importer)

        subject.save
        expect(subject.import_count).to eq(1)
      end

      it 'returns 0 if no items were uploaded' do
        importer = double(CsvPeopleImporter, import: nil, errors: [])
        allow(CsvPeopleImporter).to receive(:new).and_return(importer)

        subject.save
        expect(subject.import_count).to eq(0)
      end
    end

    describe 'csv_errors' do
      it 'is empty after save' do
        importer = double(CsvPeopleImporter, import: 1, errors: [])
        allow(CsvPeopleImporter).to receive(:new).and_return(importer)

        subject.save
        expect(subject.csv_errors).to eq([])
      end

      it 'returns the errors found during save' do
        error = double('error')
        importer = double(CsvPeopleImporter, import: nil, errors: [error])
        allow(CsvPeopleImporter).to receive(:new).and_return(importer)

        subject.save
        expect(subject.csv_errors).to eq([error])
      end
    end
  end

  context 'with an invalid upload' do
    it 'is not valid' do
      subject.file = nil
      expect(subject).not_to be_valid
    end

    it 'has errors for invalid fields' do
      subject.file = nil
      subject.valid?
      expect(subject.errors).to have_key(:file)
    end

    describe 'save' do
      it 'returns nil' do
        subject.file = nil
        expect(subject.save).to be_nil
      end
    end
  end
end
