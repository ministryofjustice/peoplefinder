require "rails_helper"

RSpec.describe PersonUpload, type: :model do
  subject(:person_upload) { described_class.new(group_id: group.id, file:) }

  let(:group) { instance_double(Group, id: 42) }
  let(:file) { double(File, read: "contents", content_type: "text/csv") } # rubocop:disable RSpec/VerifiedDoubles

  before do
    allow(Group).to receive(:where).with(id: group.id).and_return([group])
    allow(PersonCsvImporter).to receive(:new).with("contents", groups: [group])
  end

  context "with a valid upload" do
    describe "save" do
      it "initialises a PersonCsvImporter with the file contents and groups" do
        expect(PersonCsvImporter).to receive(:new)
          .with("contents", groups: [group])
          .and_call_original
        person_upload.save # rubocop:disable Rails/SaveBang
      end

      it "returns falsy if upload failed" do
        importer = instance_double(PersonCsvImporter, import: nil, errors: [])
        allow(PersonCsvImporter).to receive(:new).and_return(importer)

        expect(person_upload.save).to be_falsy
      end

      it "returns truthy if upload succeeded" do
        importer = instance_double(PersonCsvImporter, import: 1, errors: [])
        allow(PersonCsvImporter).to receive(:new).and_return(importer)

        expect(person_upload.save).to be_truthy
      end
    end

    describe "import_count" do
      it "returns the number of items uploaded after save" do
        importer = instance_double(PersonCsvImporter, import: 1, errors: [])
        allow(PersonCsvImporter).to receive(:new).and_return(importer)

        person_upload.save # rubocop:disable Rails/SaveBang
        expect(person_upload.import_count).to eq(1)
      end

      it "returns 0 if no items were uploaded" do
        importer = instance_double(PersonCsvImporter, import: nil, errors: [])
        allow(PersonCsvImporter).to receive(:new).and_return(importer)

        person_upload.save # rubocop:disable Rails/SaveBang
        expect(person_upload.import_count).to eq(0)
      end
    end

    describe "csv_errors" do
      it "is empty after save" do
        importer = instance_double(PersonCsvImporter, import: 1, errors: [])
        allow(PersonCsvImporter).to receive(:new).and_return(importer)

        person_upload.save # rubocop:disable Rails/SaveBang
        expect(person_upload.csv_errors).to eq([])
      end

      it "returns the errors found during save" do
        error = instance_double(StandardError)
        importer = instance_double(PersonCsvImporter, import: nil, errors: [error])
        allow(PersonCsvImporter).to receive(:new).and_return(importer)

        person_upload.save # rubocop:disable Rails/SaveBang
        expect(person_upload.csv_errors).to eq([error])
      end
    end
  end

  context "with no file upload" do
    let(:file) { nil }

    it "is not valid" do
      expect(person_upload).not_to be_valid
    end

    it "has errors for invalid file" do
      person_upload.valid?
      expect(person_upload.errors).to have_key(:file)
    end

    describe "save" do
      it "returns nil" do
        expect(person_upload.save).to be_nil
      end
    end
  end

  context "with invalid file type" do
    let(:file) { double(File, read: "contents", content_type: "text/my-csv") } # rubocop:disable RSpec/VerifiedDoubles

    it "is not valid" do
      expect(person_upload).not_to be_valid
    end

    it "has errors for invalid file" do
      person_upload.valid?
      expect(person_upload.errors).to have_key(:file)
    end

    describe "save" do
      it "returns nil" do
        expect(person_upload.save).to be_nil
      end
    end
  end
end
