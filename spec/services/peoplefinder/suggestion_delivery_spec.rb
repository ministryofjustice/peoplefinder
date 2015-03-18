require 'rails_helper'

RSpec.describe Peoplefinder::SuggestionDelivery do
  describe '.deliver' do
    let(:mailer) { Peoplefinder::SuggestionMailer }
    let(:mail)   { double('mail') }

    describe 'for person' do
      let(:person)     { double('person') }
      let(:suggester)  { double('suggester') }
      let(:suggestion) { double('suggestion', :'for_person?' => true, :'for_admin?' => false) }

      it 'is emailed to the person' do
        expect(mailer).to receive(:person_email).with(person, suggester, suggestion).and_return(mail)
        expect(mail).to receive(:deliver_later)
        described_class.deliver(person, suggester, suggestion)
      end
    end

    describe 'for team admin' do
      let(:admin1)     { double('admin1') }
      let(:admin2)     { double('admin2') }
      let(:admin3)     { double('admin3') }
      let(:admins)     { [admin1, admin2, admin3] }

      let(:groups)     { double('groups') }
      let(:person)     { double('person') }
      let(:suggester)  { double('suggester') }
      let(:suggestion) { double('suggestion', :'for_admin?' => true, :'for_person?' => false) }

      it 'is emailed to all relevant team admins' do
        expect(person).to receive(:groups).and_return(groups)
        expect(groups).to receive(:flat_map).and_return(admins)
        admins.each do |admin|
          expect(mailer).to receive(:team_admin_email).with(person, suggester, suggestion, admin).and_return(mail)
        end
        expect(mail).to receive(:deliver_later).exactly(3).times

        described_class.deliver(person, suggester, suggestion)
      end
    end
  end
end
