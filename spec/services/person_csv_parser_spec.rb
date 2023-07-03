require "rails_helper"

RSpec.describe PersonCsvParser, type: :service do
  subject(:parser) { described_class.new(csv) }

  context "with a clean CSV, without optional headers" do
    subject do
      described_class.new(csv)
    end

    let(:csv) do
      <<-CSV.strip_heredoc
        email,given_name,surname
        peter.bly@valid.gov.uk,Peter,Bly
        jon.o.carey@valid.gov.uk,Jon,O'Carey
      CSV
    end

    let(:expected) do
      [
        { given_name: "Peter", surname: "Bly", email: "peter.bly@valid.gov.uk" },
        { given_name: "Jon", surname: "O'Carey", email: "jon.o.carey@valid.gov.uk" },
      ]
    end

    it "returns the line number of the header" do
      expect(parser.header.line_number).to eq(1)
    end

    it "returns the line number of each row" do
      expect(parser.records.map(&:line_number)).to eq([2, 3])
    end

    it "returns the original content of the header" do
      expect(parser.header.original).to eq("email,given_name,surname")
    end

    it "returns the original content of each row" do
      expect(parser.records.map(&:original)).to eq(
        [
          "peter.bly@valid.gov.uk,Peter,Bly",
          "jon.o.carey@valid.gov.uk,Jon,O'Carey",
        ],
      )
    end

    it "returns a hash of fields" do
      expect(parser.records.map(&:fields)).to eq(expected)
    end
  end

  context "with a clean CSV, with optional headers" do
    let(:csv) do
      <<-CSV.strip_heredoc
        email,given_name,surname,primary_phone_number,secondary_phone_number,pager_number,building,location_in_building,city,role,description
        peter.bly@valid.gov.uk,Peter,Bly
        jon.o.carey@valid.gov.uk,Jon,O'Carey
        tom.mason-buggs@valid.gov.uk,Tom,Mason-Buggs,020 7947 6743,07701 345 678,07600 123456,102 Petty France,Room 5.02 5th Floor Orange Core,London,My Cool Job Title,\"My extra information\"
      CSV
    end

    let(:expected) do
      [
        { given_name: "Peter", surname: "Bly", email: "peter.bly@valid.gov.uk" },
        { given_name: "Jon", surname: "O'Carey", email: "jon.o.carey@valid.gov.uk" },
        {
          given_name: "Tom",
          surname: "Mason-Buggs",
          email: "tom.mason-buggs@valid.gov.uk",
          primary_phone_number: "020 7947 6743",
          secondary_phone_number: "07701 345 678",
          pager_number: "07600 123456",
          building: "102 Petty France",
          location_in_building: "Room 5.02 5th Floor Orange Core",
          city: "London",
          role: "My Cool Job Title",
          description: "My extra information",
        },
      ]
    end

    it "returns a hash of fields including the optional fields" do
      parser.records.each_with_index do |record, index|
        %i[given_name surname email primary_phone_number secondary_phone_number pager_number building location_in_building city role description].each do |attribute|
          expect(record.fields[attribute]).to eql expected[index][attribute]
        end
      end
    end
  end

  context "with misordered and inferable headers" do
    let(:csv) do
      <<-CSV.strip_heredoc
        First Name,Last Name,E-mail Display Name,Address2,Address1,town,secondary_phone,primary_phone,pager,extra_information,job_title
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
        Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,Room 5.02 5th Floor Orange Core,102 Petty France,London,07701 001001,020 7947 6743,07600 123456,My extra information,The boss
      CSV
    end

    let(:expected) do
      [
        {
          given_name: "Peter",
          surname: "Bly",
          email: "peter.bly@valid.gov.uk",
          secondary_phone_number: nil,
          primary_phone_number: nil,
          pager_number: nil,
          building: nil,
          location_in_building: nil,
          city: nil,
          role: nil,
          description: nil,
        },
        {
          given_name: "Jon",
          surname: "O'Carey",
          email: "jon.o.carey@valid.gov.uk",
          secondary_phone_number: nil,
          primary_phone_number: nil,
          pager_number: nil,
          building: nil,
          location_in_building: nil,
          city: nil,
          role: nil,
          description: nil,
        },
        {
          given_name: "Tom",
          surname: "Mason-Buggs",
          email: "tom.mason-buggs@valid.gov.uk",
          primary_phone_number: "020 7947 6743",
          secondary_phone_number: "07701 001001",
          pager_number: "07600 123456",
          building: "102 Petty France",
          location_in_building: "Room 5.02 5th Floor Orange Core",
          city: "London",
          role: "The boss",
          description: "My extra information",
        },
      ]
    end

    it "returns a hash of fields with cleaned keys" do
      expect(parser.records.map(&:fields)).to eq(expected)
    end
  end

  context "with partial headers" do
    let(:csv) do
      <<-CSV.strip_heredoc
        given_name,surname,email,primary_phone_number,city
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
        Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,020 7947 6743,London
      CSV
    end

    let(:expected) do
      [
        { given_name: "Peter", surname: "Bly", email: "peter.bly@valid.gov.uk", primary_phone_number: nil, city: nil },
        { given_name: "Jon", surname: "O'Carey", email: "jon.o.carey@valid.gov.uk", primary_phone_number: nil, city: nil },
        { given_name: "Tom", surname: "Mason-Buggs", email: "tom.mason-buggs@valid.gov.uk", primary_phone_number: "020 7947 6743", city: "London" },
      ]
    end

    it "returns a hash of fields matching the partial header" do
      expect(parser.records.map(&:fields)).to eq(expected)
    end
  end

  context "with double-quoted comma'd values" do
    let(:csv) do
      <<-CSV.strip_heredoc
        given_name,surname,email,primary_phone_number,building,location_in_building,city
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
        Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,020 7947 6743,"102, Petty France","Room 5.02, 5th Floor, Orange Core","London, England"
      CSV
    end

    let(:expected) do
      [
        { given_name: "Peter", surname: "Bly", email: "peter.bly@valid.gov.uk", primary_phone_number: nil, building: nil, location_in_building: nil, city: nil },
        { given_name: "Jon", surname: "O'Carey", email: "jon.o.carey@valid.gov.uk", primary_phone_number: nil, building: nil, location_in_building: nil, city: nil },
        { given_name: "Tom", surname: "Mason-Buggs", email: "tom.mason-buggs@valid.gov.uk", primary_phone_number: "020 7947 6743", building: "102, Petty France", location_in_building: "Room 5.02, 5th Floor, Orange Core", city: "London, England" },
      ]
    end

    it "returns a hash of fields including comma separated values" do
      expect(parser.records.map(&:fields)).to eq(expected)
    end
  end

  context "with entirely unidentifiable headers" do
    let(:csv) do
      <<-CSV.strip_heredoc
        Foo,bar,BAZ
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
      CSV
    end

    it "returns an empty hash for the fields" do
      expect(parser.records.map(&:fields)).to eq([{}, {}])
    end
  end

  context "with some unrecognizable header columns" do
    let(:csv) do
      <<-CSV.strip_heredoc
        email,givesn_name,surname,primary_phone_number,building,locations_in_building,city
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
      CSV
    end

    it "populates @unrecognized_columns for use by importer" do
      expect(parser.header.unrecognized_columns).to match_array %w[givesn_name locations_in_building]
    end
  end
end
