require 'rails_helper'

RSpec.describe PersonCsvImporter, type: :service do

  before do
    allow(PermittedDomain).to receive(:pluck).with(:domain).and_return(['valid.gov.uk'])
  end

  subject(:importer) { described_class.new(csv) }

  describe '#valid?' do
    subject { importer.valid? }

    before { subject }

    context 'when csv has valid format' do
      context 'when all people have surname and email' do
        let(:csv) do
          <<-CSV.strip_heredoc
            email,given_name,surname
            peter.bly@valid.gov.uk,Peter,Bly
            jon.o.carey@valid.gov.uk,Jon,O'Carey
          CSV
        end

        it { is_expected.to be true }

        it 'errors are empty' do
          expect(importer.errors).to be_empty
        end
      end

      context 'when some people have incorrect details' do
        let(:csv) do
          <<-CSV.strip_heredoc
            email,given_name,surname
            peter.bly@valid.gov.uk,Peter,Bly
            jon.o. carey@valid.gov.uk,Jon,O'Carey
            jack@invalid.gov.uk,Jack,
          CSV
        end

        it { is_expected.to be false }

        it 'errors contain missing columns' do
          expect(importer.errors).to match_array([
            PersonCsvImporter::ErrorRow.new(
              3, "jon.o. carey@valid.gov.uk,Jon,O'Carey",
              ['Main email isn’t valid']
            ),
            PersonCsvImporter::ErrorRow.new(
              4, "jack@invalid.gov.uk,Jack,",
              [
                'Surname is required',
                'Main email you have entered can’t be used to access People Finder'
              ]
            )
          ])
        end
      end
    end

    context 'when the csv has missing columns' do
      let(:csv) do
        <<-CSV.strip_heredoc
          email
          peter.bly@valid.gov.uk
        CSV
      end

      it { is_expected.to be false }

      it 'errors contain missing columns' do
        expect(importer.errors).to match_array([
          PersonCsvImporter::ErrorRow.new(
            1, "email", ['given_name column is missing']
          ),
          PersonCsvImporter::ErrorRow.new(
            1, "email", ['surname column is missing']
          )
        ])
      end
    end
  end

  describe '#import' do
    context 'for a valid csv' do
      let(:csv) do
        <<-CSV.strip_heredoc
          email,given_name,surname
          peter.bly2@valid.gov.uk,Peter,Bly2
          jon.con@valid.gov.uk,Jon,Con
        CSV
      end

      it 'creates new records' do
        subject.import
        created = Person.where(email: 'peter.bly2@valid.gov.uk').first
        expect(created).not_to be nil
        expect(created.name).to eq 'Peter Bly'
      end

      it 'uses the PersonCreator' do
        expect(PersonCreator).to receive(:new).
          with(instance_of(Person), nil).twice.and_call_original
        subject.import
      end

      it 'returns number of imported  records' do
        expect(subject.import).to eql 2
      end

      context 'with extra parameters' do
        subject { described_class.new(csv, extra_params) }
        let(:extra_params) { { groups: [group] } }
        let(:group) { create(:group) }

        it 'merges CSV fields into supplied parameters' do
          subject.import
          person = Person.find_by(email: 'peter.bly2@valid.gov.uk')
          expect(person.groups).to eq([group])
        end
      end
    end

    context 'for an invalid csv (including duplicates)' do
      let(:csv) do
        <<-CSV.strip_heredoc
          email,given_name,surname
          peter.bly@valid.gov.uk,,Bly
          jon.o.carey@valid.gov.uk,Jon,O'Carey
        CSV
      end

      before do
        create(:person, email: 'jon.o.carey@valid.gov.uk')
      end

      it 'returns nil on import' do
        expect(subject.import).to be_nil
      end
    end
  end

  describe '#import' do
    context 'for a CSV exported by Estates' do
      let(:csv) do
        <<-CSV.strip_heredoc
          First Name,Last Name,E-mail Display Name
          Reinhold,Denesik,"Denesik, Reinhold (Reinhold.Denesik@valid.gov.uk)"
          Lelah,Jerde,"Jerde, Lelah (Lelah.Jerde@valid.gov.uk)"
        CSV
      end

      it 'creates records' do
        subject.import
        expect(Person.where(
          given_name: 'Reinhold',
          surname: 'Denesik',
          email: 'reinhold.denesik@valid.gov.uk'
        ).count).to eq(1)
        expect(Person.where(
          given_name: 'Lelah',
          surname: 'Jerde',
          email: 'lelah.jerde@valid.gov.uk'
        ).count).to eq(1)
      end
    end
  end

  it 'renders errors as strings' do
    error_row = PersonCsvImporter::ErrorRow.new(
      4, "jack@invalid.gov.uk,Jack,", ['Something', 'Something else']
    )
    expect(error_row.to_s).to eq('line 4 "jack@invalid.gov.uk,Jack,": Something, Something else')
  end
end
