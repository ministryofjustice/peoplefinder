require 'spec_helper'
require 'person_csv_parser'
require 'active_support/core_ext/string/strip'

RSpec.describe PersonCsvParser, type: :service do

  subject {
    described_class.new(csv)
  }

  context 'with a clean CSV' do
    let(:csv) {
      <<-END.strip_heredoc
        email,given_name,surname
        peter.bly@valid.gov.uk,Peter,Bly
        jon.o.carey@valid.gov.uk,Jon,O'Carey
      END
    }

    subject {
      described_class.new(csv)
    }

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
      expect(subject.records.map(&:fields)).to eq(
        [
          { given_name: 'Peter', surname: 'Bly', email: 'peter.bly@valid.gov.uk' },
          { given_name: 'Jon', surname: 'O\'Carey', email: 'jon.o.carey@valid.gov.uk' }
        ]
      )
    end
  end

  context 'with dodgy headers' do
    let(:csv) {
      <<-END.strip_heredoc
        First Name,Last Name,E-mail Display Name
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
      END
    }

    it 'returns a hash of fields with cleaned keys' do
      expect(subject.records.map(&:fields)).to eq(
        [
          { given_name: 'Peter', surname: 'Bly', email: 'peter.bly@valid.gov.uk' },
          { given_name: 'Jon', surname: 'O\'Carey', email: 'jon.o.carey@valid.gov.uk' }
        ]
      )
    end
  end

  context 'with unidentifiable headers' do
    let(:csv) {
      <<-END.strip_heredoc
        Foo,bar,BAZ
        Peter,Bly,peter.bly@valid.gov.uk
        Jon,O'Carey,jon.o.carey@valid.gov.uk
      END
    }

    it 'returns an empty hash for the fields' do
      expect(subject.records.map(&:fields)).to eq([{}, {}])
    end
  end
end
