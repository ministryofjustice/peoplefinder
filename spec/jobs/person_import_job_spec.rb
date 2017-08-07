require 'rails_helper'

RSpec.describe PersonImportJob, type: :job do

  before(:each) do
    allow(PermittedDomain).to receive(:pluck).with(:domain).and_return(['valid.gov.uk'])
  end

  let!(:group) do
    group = create(:group)
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    group
  end

  let(:serialized_people) do
    <<-CSV.strip_heredoc
      email,given_name,surname
      peter.bly@valid.gov.uk,Peter,Bly
      jon.o.carey@valid.gov.uk,Jon,O'Carey
      "Jerde, Lelah (Lelah.Jerde@valid.gov.uk)",Lelah,Jerde
    CSV
  end

  let(:serialized_group_ids) { YAML.dump([group.id]) }

  subject(:perform_later) { described_class.perform_later(serialized_people, serialized_group_ids) }
  subject(:perform_now)   { described_class.perform_now(serialized_people, serialized_group_ids) }
  subject(:job) { described_class.new }

  it "enqueues with appropriate config settings" do
    expect(job.queue_name).to eq 'person_import'
    expect(job.max_run_time).to eq 10.minutes
    expect(job.max_attempts).to eq 3
    expect(job.destroy_failed_jobs?).to eq false
  end

  it 'enqueues job with expected arguments' do
    expect do
      perform_later
    end.to have_enqueued_job(described_class).with(serialized_people, serialized_group_ids)
  end

  it 'enqueues on named queue' do
    expect do
      perform_later
    end.to have_enqueued_job(described_class).on_queue('person_import')
  end

  context 'when performed' do

    context 'now' do

      it 'uses the PersonCreator' do
        expect(PersonCreator).to receive(:new).
          with(person: instance_of(Person), current_user: nil, state_cookie: instance_of(StateManagerCookie)).thrice.and_call_original
        perform_now
      end

      # to avoid job retry and multi-worker instance errors
      it 'double-checks person does not already exist' do
        expect(Person).to receive(:find_by).thrice
        perform_now
      end

      it 'creates new people from the serialized data' do
        perform_now
        expect(Person.pluck(:email)).to include('peter.bly@valid.gov.uk', 'jon.o.carey@valid.gov.uk')
      end

      it 'cleans people\'s email addresses' do
        perform_now
        expect(Person.pluck(:given_name, :surname, :email)).to include ['Lelah', 'Jerde', 'lelah.jerde@valid.gov.uk']
      end

      it 'creates people as members of a group' do
        perform_now
        expect(Person.first.groups.map(&:slug)).to include group.slug
      end

      it 'returns the number of imported records' do
        expect(perform_now).to eql 3
      end

      it 'enqeues group completion score updates job for the group, not for the individual people' do
        expect { perform_now }.to have_enqueued_job(UpdateGroupMembersCompletionScoreJob)
      end

      context 'with optional headers' do
        let(:serialized_people) do
          <<-END.strip_heredoc
            given_name,surname,email,primary_phone_number,secondary_phone_number,pager_number,building,location_in_building,city,description
            Tom,O'Carey,tom.o.carey@valid.gov.uk
            Tom,Mason-Buggs,tom.mason-buggs@valid.gov.uk,020 7947 6743,07701 234 567,07600 000 001,"102, Petty France","Room 5.02, 5th Floor, Orange Core","London, England","I work around here"
          END
        end
        it 'creates records with and without optional fields' do
          expect { perform_now }.to change(Person, :count).by 2
          expect(Person.pluck(:email)).to match_array ['tom.o.carey@valid.gov.uk', 'tom.mason-buggs@valid.gov.uk']
          expect(Person.pluck(:location_in_building)).to include 'Room 5.02, 5th Floor, Orange Core'
        end
      end
    end
  end

end
