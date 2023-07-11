require "rails_helper"

RSpec.describe SuggestionDelivery do
  describe ".deliver" do
    let(:mailer) { SuggestionMailer }
    let(:mail)   { instance_double(ActionMailer::MessageDelivery) }
    let(:suggestion_hash) { instance_double(Hash) }

    before do
      allow(Suggestion).to receive(:new)
        .with(suggestion_hash).and_return(suggestion)
    end

    describe "for person" do
      let(:person)     { instance_double(Person) }
      let(:suggester)  { instance_double(Person) }
      let(:suggestion) do
        instance_double(Suggestion, for_person?: true, for_admin?: false, to_hash: suggestion_hash)
      end

      it "is emailed to the person" do
        allow(mailer).to receive(:person_email)
          .with(person, suggester, suggestion_hash).and_return(mail)
        expect(mail).to receive(:deliver_later)
        described_class.deliver(person, suggester, suggestion)
      end

      it "returns an object with the number of recipients" do
        allow(mailer).to receive(:person_email).and_return(mail)
        allow(mail).to receive(:deliver_later)
        result = described_class.deliver(person, suggester, suggestion)
        expect(result.recipient_count).to eq(1)
      end
    end

    describe "for team admin" do
      let(:admins)     { [instance_double(Person), instance_double(Person), instance_double(Person)] }

      let(:groups)     { double("groups") } # rubocop:disable RSpec/VerifiedDoubles
      let(:person)     { instance_double(Person) }
      let(:suggester)  { instance_double(Person) }
      let(:suggestion) do
        instance_double(Suggestion, for_admin?: true, for_person?: false, to_hash: suggestion_hash)
      end

      it "is emailed to all relevant team admins" do
        allow(person).to receive(:groups).and_return(groups)
        allow(groups).to receive(:flat_map).and_return(admins)
        admins.each do |admin|
          allow(mailer).to receive(:team_admin_email)
            .with(person, suggester, suggestion_hash, admin).and_return(mail)
        end
        expect(mail).to receive(:deliver_later).exactly(3).times

        described_class.deliver(person, suggester, suggestion)
      end

      it "returns an object with the number of recipients" do
        allow(person).to receive(:groups).and_return(groups)
        allow(groups).to receive(:flat_map).and_return(admins)
        allow(mailer).to receive(:team_admin_email).and_return(mail)
        allow(mail).to receive(:deliver_later)

        result = described_class.deliver(person, suggester, suggestion)
        expect(result.recipient_count).to eq(3)
      end
    end
  end
end
