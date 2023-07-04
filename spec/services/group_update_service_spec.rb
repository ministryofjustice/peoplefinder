require "rails_helper"

RSpec.describe GroupUpdateService, type: :service do
  include PermittedDomainHelper

  subject(:service) { described_class.new(group:, person_responsible:) }

  let(:group) { build(:group) }
  let(:person_responsible) { build(:person) }

  it "updates the group with the supplied parameters and returns the result" do
    params = instance_double(Hash)
    result = Object.new
    allow(group).to receive(:update).and_return(result)
    expect(service.update(params)).to eq(result)
  end

  it "sends an email to each subscriber to the group" do
    subscribers = create_list(:person, 2)
    allow(group).to receive(:subscribers).and_return(subscribers)
    email_1 = instance_double(ActionMailer::MessageDelivery)
    email_2 = instance_double(ActionMailer::MessageDelivery)

    allow(GroupUpdateMailer)
      .to receive(:inform_subscriber)
      .with(subscribers[0], group, person_responsible)
      .and_return(email_1)
    allow(GroupUpdateMailer)
      .to receive(:inform_subscriber)
      .with(subscribers[1], group, person_responsible)
      .and_return(email_2)
    expect(email_1).to receive(:deliver_later)
    expect(email_2).to receive(:deliver_later)

    service.update({}) # rubocop:disable Rails/SaveBang
  end
end
