require "rails_helper"
require_relative "../../app/services/metrics_publisher"

RSpec.describe MetricsPublisher, type: :service do
  subject(:publisher) { described_class.new(recipient) }

  let(:recipient) { class_double(Keen, publish: nil) }
  let!(:person_class) do
    pc = class_double(
      "Person",
      count: 0,
      overall_completion: 0,
      bucketed_completion: {},
    ).as_stubbed_const
    allow(pc).to receive(:where).and_return(pc)
    allow(pc).to receive(:never_logged_in).and_return double(count: 0) # rubocop:disable RSpec/VerifiedDoubles
    pc
  end

  it "sends overall completion details" do
    allow(person_class).to receive(:overall_completion).and_return(67)
    expect(recipient).to receive(:publish)
      .with(:completion, a_hash_including("mean" => 67))
    publisher.publish!
  end

  it "sends bucketed completion details" do
    allow(person_class).to receive(:bucketed_completion).and_return(
      "[0,19]" => 10,
      "[20,49]" => 20,
      "[50,79]" => 30,
      "[80,100]" => 5,
    )

    expect(recipient).to receive(:publish)
      .with(
        :completion,
        a_hash_including(
          "[0,19]" => 10,
          "[20,49]" => 20,
          "[50,79]" => 30,
          "[80,100]" => 5,
        ),
      )

    publisher.publish!
  end

  it "sends the number of profiles" do
    allow(person_class).to receive(:count).and_return(667)
    expect(recipient).to receive(:publish)
      .with(:profiles, a_hash_including("total" => 667))
    publisher.publish!
  end

  it "sends the number of profiles that have not logged in" do
    scope = double(count: 42) # rubocop:disable RSpec/VerifiedDoubles
    allow(person_class).to receive(:never_logged_in)
      .and_return(scope)
    expect(recipient).to receive(:publish)
      .with(:profiles, a_hash_including("not_logged_in" => 42))
    publisher.publish!
  end
end
