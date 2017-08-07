require 'rails_helper'

RSpec.describe PersonCsvParser, type: :service do

  subject do
    described_class.new(csv)
  end

  context 'clean CSV, without optional headers' do
    let(:csv) do
      <<-END.strip_heredoc
        email,given_name,surname
        peter.bly@valid.gov.uk,Peter,Bly
        jon.o.carey@valid.gov.uk,Jon,O'Carey
      END
    end

    let(:expected) do
      [
        { given_name: 'Peter', surname: 'Bly', email: 'peter.bly@valid.gov.uk' },
        { given_name: 'Jon', surname: 'O\'Carey', email: 'jon.o.carey@valid.gov.uk' }
      ]
    end

    subject do
      described_class.new(csv)
    end

    it 'returns the line number of the header' do
      expect(subject.header.line_number).to eq(1)
    end

    it 'returns the line number of each row' do
      expect(subject.records.map(&:line_number)).to eq([2, 3])
    end

    it 'returns the original content of the header' do
      expect(subject.header.original).to eq('email,given_name,surname')
    end

    it 'returns the original content of each row' do
      expect(subject.records.map(&:original)).to eq(
        [
          'peter.bly@valid.gov.uk,Peter,Bly',
          'jon.o.carey@valid.gov.uk,Jon,O\'Carey'
        ]
      )
    end

    it 'returns a hash of fields' do
      expect(subject.records.map(&:fields)).to eq(expected)
    end
  end

  context 'clean CSV, with optional headers' do
    let(:csv) do
      <<-END.strip_heredoc
        email,given_name,surname,primary_phone_number,secondary_phone_number,pager_number,building,location_in_building,city,description
        peter.bly@valid.gov.uk,Peter,Bly
        jon.o.carey@valid.gov.uk,Jon,O'Carey
        tom.mason-buggs@valid.gov.uk,Tom,Mason-Buggs,020 7947 6743,07701 345 678,07600 123456,102 Petty France,Room 5.02 5th Floor Orange Core,London,\"My extra information\"
      END
    end

    let(:expected) do
      [
        { given_name: 'Peter', surname: 'Bly', email: 'peter.bly@valid.gov.uk' },
        { given_name: 'Jon', surname: 'O\'Carey', email: 'jon.o.carey@valid.gov.uk' },
        { given_name: 'Tom',
          surname: 'Mason-Buggs',
          email: 'tom.mason-buggs@valid.gov.uk',
          primary_phone_number: '020 7947 6743',
          secondary_phone_number: '07701 345 678',
          pager_number: '07600 123456',
          building: '102 Petty France',
          location_in_building: 'Room 5.02 5th Floor Orange Core',
          city: 'London',
          description: "My extra information"
        }
      ]
    end

    it 'returns a hash of fields including the optional fields' do
      subject.records.each_with_index do |record, index|
        [:given_name, :surname, :email, :primary_phone_number, :secondary_phone_number, :pager_number, :building, :location_in_building, :city, :description].each do |attribute|
          expect(record.fields[attribute]).to eql expected[index][attribute]
        end
      end
    end
  end

  context 'with misordered and inferable headers' do
    let(:csv) do
      <<-END.strip_heredoc
        First Name,Last Name,E-mail Display Name,Address2,Address1,town,primary_phone,pager
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
        Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,Room 5.02 5th Floor Orange Core,102 Petty France,London,020 7947 6743,07600 123456
      END
    end

    let(:expected) do
      [
        { given_name: 'Peter', surname: 'Bly', email: 'peter.bly@valid.gov.uk', primary_phone_number: nil, pager_number: nil, building: nil, location_in_building: nil, city: nil },
        { given_name: 'Jon', surname: 'O\'Carey', email: 'jon.o.carey@valid.gov.uk', primary_phone_number: nil, pager_number: nil, building: nil, location_in_building: nil, city: nil },
        { given_name: 'Tom', surname: 'Mason-Buggs', email: 'tom.mason-buggs@valid.gov.uk', primary_phone_number: '020 7947 6743', pager_number: '07600 123456', building: '102 Petty France', location_in_building: 'Room 5.02 5th Floor Orange Core', city: 'London' }
      ]
    end

    it 'returns a hash of fields with cleaned keys' do
      expect(subject.records.map(&:fields)).to eq(expected)
    end
  end

  context 'with partial headers' do
    let(:csv) do
      <<-END.strip_heredoc
        given_name,surname,email,primary_phone_number,city
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
        Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,020 7947 6743,London
      END
    end

    let(:expected) do
      [
        { given_name: 'Peter', surname: 'Bly', email: 'peter.bly@valid.gov.uk', primary_phone_number: nil, city: nil },
        { given_name: 'Jon', surname: 'O\'Carey', email: 'jon.o.carey@valid.gov.uk', primary_phone_number: nil, city: nil },
        { given_name: 'Tom', surname: 'Mason-Buggs', email: 'tom.mason-buggs@valid.gov.uk', primary_phone_number: '020 7947 6743', city: 'London' }
      ]
    end

    it 'returns a hash of fields matching the partial header' do
      expect(subject.records.map(&:fields)).to eq(expected)
    end
  end

  context 'with double-quoted comma\'d values' do
    let(:csv) do
      <<-END.strip_heredoc
        given_name,surname,email,primary_phone_number,building,location_in_building,city
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
        Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,020 7947 6743,"102, Petty France","Room 5.02, 5th Floor, Orange Core","London, England"
      END
    end

    let(:expected) do
      [
        { given_name: 'Peter', surname: 'Bly', email: 'peter.bly@valid.gov.uk', primary_phone_number: nil, building: nil, location_in_building: nil, city: nil },
        { given_name: 'Jon', surname: 'O\'Carey', email: 'jon.o.carey@valid.gov.uk', primary_phone_number: nil, building: nil, location_in_building: nil, city: nil },
        { given_name: 'Tom', surname: 'Mason-Buggs', email: 'tom.mason-buggs@valid.gov.uk', primary_phone_number: '020 7947 6743', building: '102, Petty France', location_in_building: 'Room 5.02, 5th Floor, Orange Core', city: 'London, England' }
      ]
    end

    it 'returns a hash of fields including comma separated values' do
      expect(subject.records.map(&:fields)).to eq(expected)
    end
  end

  context 'with entirely unidentifiable headers' do
    let(:csv) do
      <<-END.strip_heredoc
        Foo,bar,BAZ
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
      END
    end

    it 'returns an empty hash for the fields' do
      expect(subject.records.map(&:fields)).to eq([{}, {}])
    end
  end

  context 'with some unrecognizable header columns' do
    let(:csv) do
      <<-END.strip_heredoc
        email,givesn_name,surname,primary_phone_number,building,locations_in_building,city
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
      END
    end

    it 'populates @unrecognized_columns for use by importer' do
      expect(subject.header.unrecognized_columns).to match_array %w(givesn_name locations_in_building)
    end
  end

end
