require "rails_helper"

RSpec.describe PersonCsvImporter, type: :service do
  subject(:importer) do
    described_class.new(csv, creation_options)
  end

  before do
    allow(PermittedDomain).to receive(:pluck).with(:domain).and_return(["valid.gov.uk"])
  end

  let(:group) { create(:group) }
  let(:creation_options) { { groups: [group] } }

  describe ".deserialize_group_ids" do
    let(:groups) do
      create_list(:group, 2)
    end

    let(:serialized_group_ids) do
      YAML.dump(groups.map(&:id))
    end

    it "returns an array of Group objects" do
      expect(groups.first.class).to eq Group
      expect(described_class.deserialize_group_ids(serialized_group_ids)).to eq groups
    end
  end

  describe "#valid?" do
    let(:csv_object) { CSV.new(csv, headers: true).read }
    let(:csv_headers) { csv_object.headers.map(&:strip).map(&:to_sym) }
    let(:all_headers) { described_class::REQUIRED_COLUMNS + described_class::OPTIONAL_COLUMNS }

    before { importer.valid? }

    context "when csv has valid format" do
      context "when all required and optional columns provided" do
        let(:csv) do
          <<-CSV.strip_heredoc
            given_name, surname, email, primary_phone_number, secondary_phone_number, pager_number, building, location_in_building, city, role, description
            Peter, Bly, peter.bly@valid.gov.uk, 0207 956 6457, 07701 432 754, 20343434, Building 1, Room 252, Birmingham, My Cool Job Title,"My extra info."
          CSV
        end

        it "ensure test csv has all expected column headers" do
          expect(csv_headers).to match_array all_headers
        end

        it { is_expected.to be_valid }

        it "errors are empty" do
          expect(importer.errors).to be_empty
        end
      end

      context "when all people have surname and email" do
        let(:csv) do
          <<-CSV.strip_heredoc
            email,given_name,surname
            peter.bly@valid.gov.uk,Peter,Bly
            jon.o.carey@valid.gov.uk,Jon,O'Carey
          CSV
        end

        it { is_expected.to be_valid }

        it "errors are empty" do
          expect(importer.errors).to be_empty
        end
      end

      context "when some people have incorrect details" do
        let(:csv) do
          <<-CSV.strip_heredoc
            email,given_name,surname
            peter.bly@valid.gov.uk,Peter,Bly
            jon.o. carey@valid.gov.uk,Jon,O'Carey
            jack@invalid.gov.uk,Jack,
          CSV
        end

        it { is_expected.not_to be_valid }

        it "errors contain missing columns" do
          expect(importer.errors).to match_array([
            PersonCsvImporter::ErrorRow.new(
              3, "jon.o. carey@valid.gov.uk,Jon,O'Carey",
              ["Main email isn’t valid"]
            ),
            PersonCsvImporter::ErrorRow.new(
              4, "jack@invalid.gov.uk,Jack,",
              [
                "Surname is required",
                "Main email you have entered can’t be used to access People Finder",
              ]
            ),
          ])
        end
      end
    end

    context "when the csv has missing columns" do
      let(:csv) do
        <<-CSV.strip_heredoc
          email
          peter.bly@valid.gov.uk
        CSV
      end

      let(:errors) do
        [
          PersonCsvImporter::ErrorRow.new(1, "email", ["given_name column is missing"]),
          PersonCsvImporter::ErrorRow.new(1, "email", ["surname column is missing"]),
        ]
      end

      it { is_expected.not_to be_valid }

      it "errors contain missing columns" do
        expect(importer.errors).to match_array errors
      end
    end

    context "when the csv has columns that cannot be infered" do
      context "with required columns" do
        let(:csv) do
          <<-CSV.strip_heredoc
            email,wrong_name,wrongname
            peter.bly@valid.gov.uk,Tom,Mason-Buggs
          CSV
        end

        let(:errors) do
          [
            PersonCsvImporter::ErrorRow.new(1, "email,wrong_name,wrongname", ["given_name column is missing"]),
            PersonCsvImporter::ErrorRow.new(1, "email,wrong_name,wrongname", ["surname column is missing"]),
            PersonCsvImporter::ErrorRow.new(1, "email,wrong_name,wrongname", ["wrong_name column is not recognized"]),
            PersonCsvImporter::ErrorRow.new(1, "email,wrong_name,wrongname", ["wrongname column is not recognized"]),
          ]
        end

        it { is_expected.not_to be_valid }

        it "errors contain missing columns" do
          expect(importer.errors).to match_array errors
        end
      end

      context "with optional columns" do
        let(:csv) do
          <<-CSV.strip_heredoc
            email,given_name,surname,primary_phome_number,builming location
            peter.bly@valid.gov.uk,Tom,Mason-Buggs,020 7947 6638,"102 Petty France"
          CSV
        end

        let(:errors) do
          [
            PersonCsvImporter::ErrorRow.new(1, "email,given_name,surname,primary_phome_number,builming location", ["primary_phome_number column is not recognized"]),
            PersonCsvImporter::ErrorRow.new(1, "email,given_name,surname,primary_phome_number,builming location", ["builming location column is not recognized"]),
          ]
        end

        it { is_expected.not_to be_valid }

        it "errors contain unrecognized columns" do
          expect(importer.errors).to match_array errors
        end
      end
    end

    context "when the CSV has too many header columns" do
      let(:csv) do
        <<-CSV.strip_heredoc
          #{all_headers.join(',')},city
          Jon,O'Carey,tom.o.carey@digital.justice.gov.uk
          Tom,Mason-Buggs,tom.mason-buggs@digital.justice.gov.uk,020 7947 76738,"102, Petty France","Room 5.02, 5th Floor, Blue Core",London
        CSV
      end

      let(:errors) do
        [
          PersonCsvImporter::ErrorRow.new(1, "#{all_headers.join(',')},city", ["There are more columns than expected"]),
        ]
      end

      it { is_expected.not_to be_valid }

      it "errors contain too many columns" do
        expect(importer.errors).to match_array errors
      end
    end

    context "when the CSV has too many rows" do
      subject(:importer_2) { described_class.new(csv, creation_options) }

      let(:csv) do
        <<-CSV.strip_heredoc
          given_name,surname,email,primary_phone_number,building,location_in_building,city
          Tom,O'Carey,tom.o.carey@valid.gov.uk
          Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,020 7947 6743,"102, Petty France","Room 5.02, 5th Floor, Orange Core","London, England"
        CSV
      end

      let(:errors) do
        [
          PersonCsvImporter::ErrorRow.new("-", "-", ["Too many rows - a maximum of 1 rows can be processed"]),
        ]
      end

      before do
        allow_any_instance_of(described_class).to receive(:max_row_upload).and_return 1 # rubocop:disable RSpec/AnyInstance
        importer_2.valid?
      end

      it { is_expected.not_to be_valid }

      it "errors contain missing columns" do
        expect(importer_2.errors).to match_array errors
      end
    end
  end

  describe "#import" do
    context "with a valid csv" do
      before { ActiveJob::Base.queue_adapter.enqueued_jobs.clear }

      let(:csv) do
        <<-CSV.strip_heredoc
          email,given_name,surname
          peter.bly2@valid.gov.uk,Peter,Bly2
          jon.con@valid.gov.uk,Jon,Con
        CSV
      end

      let(:serialized_group_ids) { YAML.dump([group.id]) }

      it "calls PersonImportJob" do
        expect(class_double("PersonImportJob").as_stubbed_const)
          .to receive(:perform_later)
          .with(csv, serialized_group_ids)
          .once
        importer.import
      end

      it "enqueues the person import job" do
        importer.import
        expect(PersonImportJob).to have_been_enqueued.once
      end
    end

    context "with an invalid csv (including duplicates)" do
      let(:csv) do
        <<-CSV.strip_heredoc
          email,given_name,surname
          peter.bly@valid.gov.uk,,Bly
          jon.o.carey@valid.gov.uk,Jon,O'Carey
        CSV
      end

      before do
        create(:person, email: "jon.o.carey@valid.gov.uk")
      end

      it "returns nil on import" do
        expect(importer.import).to be_nil
      end
    end
  end

  it "renders errors as strings" do
    error_row = PersonCsvImporter::ErrorRow.new(
      4, "jack@invalid.gov.uk,Jack,", ["Something", "Something else"]
    )
    expect(error_row.to_s).to eq('line 4 "jack@invalid.gov.uk,Jack,": Something, Something else')
  end
end
