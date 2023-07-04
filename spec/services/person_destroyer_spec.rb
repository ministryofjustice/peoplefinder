require "rails_helper"

RSpec.describe PersonDestroyer, type: :service do
  subject(:destroyer) { described_class.new(person, current_user) }

  let(:person) do
    instance_double(Person,
                    destroy!: true,
                    new_record?: false,
                    notify_of_change?: false,
                    email: "user@example.com",
                    given_name: "Rupert")
  end
  let(:current_user) { instance_double(Person, email: "user@example.com") }

  describe "initialize" do
    it "raises an exception if person is a new record" do
      allow(person).to receive(:new_record?).and_return(true)
      expect { destroyer }.to raise_error(PersonDestroyer::NewRecordError)
    end
  end

  describe "valid?" do
    it "delegates valid? to the person" do
      validity = double
      allow(person).to receive(:valid?).and_return(validity)
      expect(destroyer.valid?).to eq(validity)
    end
  end

  describe "destroy!" do
    it "destroys the person record" do
      expect(person).to receive(:destroy!)
      destroyer.destroy!
    end

    it "sends no deleted profile email if not required" do
      allow(person)
        .to receive(:notify_of_change?)
        .with(current_user)
        .and_return(false)
      expect(class_double("UserUpdateMailer").as_stubbed_const)
        .not_to receive(:deleted_profile_email)
      destroyer.destroy!
    end

    it "sends a deleted profile email if required" do
      allow(person)
        .to receive(:notify_of_change?)
        .with(current_user)
        .and_return(true)
      mailer = instance_double(ActionMailer::MessageDelivery)
      allow(class_double("UserUpdateMailer").as_stubbed_const)
        .to receive(:deleted_profile_email)
        .with(person.email, person.given_name, current_user.email)
        .and_return(mailer)
      expect(mailer).to receive(:deliver_later)
      destroyer.destroy!
    end
  end
end
