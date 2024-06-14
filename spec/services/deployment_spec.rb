require "rails_helper"

RSpec.describe Deployment, type: :service do
  subject(:deployment) { described_class.new(environment) }

  context "when all environment variables are available" do
    let(:environment) do
      {
        "APP_BUILD_DATE" => "2013-04-03",
        "APP_GIT_COMMIT" => "7cb26ffe8a2ead47837e28606743e4d31a31512d",
        "APP_BUILD_TAG" => "0.5.25",
      }
    end

    it "returns a hash of environment information" do
      expected = {
        build_date: "2013-04-03",
        commit_id: "7cb26ffe8a2ead47837e28606743e4d31a31512d",
        build_tag: "0.5.25",
      }
      expect(deployment.info).to eq(expected)
    end
  end

  context "when environment variables are missing" do
    let(:environment) { {} }

    it 'returns "unknown" for values' do
      expected = {
        build_date: "unknown",
        commit_id: "unknown",
        build_tag: "unknown",
      }
      expect(deployment.info).to eq(expected)
    end
  end

  it "provides a convenient class method" do
    hash = { foo: "bar" }
    allow_any_instance_of(described_class).to receive(:info) # rubocop:disable RSpec/AnyInstance
      .and_return(hash)
    expect(described_class.info).to eq(hash)
  end
end
