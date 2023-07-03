shared_examples_for "session_person_creatable" do
  it { is_expected.to respond_to :person_from_oauth }
  it { is_expected.to respond_to :person_from_token }

  let(:valid_auth_hash) do
    {
      "info" => {
        "email" => "example.user@digital.justice.gov.uk",
        "first_name" => "John",
        "last_name" => "Doe",
        "name" => "John Doe",
      },
    }
  end

  let(:rogue_auth_hash) do
    valid_auth_hash.deep_merge(
      "info" => { "email" => "rogue.user@example.com" },
    )
  end

  shared_examples "existing person returned" do
    it "returns the matching person" do
      expect(subject).to eql(person)
    end
  end

  shared_examples "new person created" do
    it "returns a person model" do
      expect(subject).to be_a(Person)
    end

    describe "the person" do
      it "has correct e-mail address" do
        expect(subject.email).to eql(expected_email)
      end

      it "has correct name" do
        expect(subject.name).to eql(expected_name)
      end
    end
  end

  describe ".person_from_oauth" do
    subject do
      view = described_class.new
      view.person_from_oauth(auth_hash)
    end

    context "when an existing person" do
      let(:person) { create(:person_with_multiple_logins, email: valid_auth_hash["info"]["email"], surname: "Bob") }
      let(:auth_hash) { valid_auth_hash }

      before do
        person
      end

      it_behaves_like "existing person returned"

      it "extracts email from auth hash" do
        email_address = instance_double(EmailAddress, permitted_domain?: true)
        allow(EmailAddress).to receive(:new).with(valid_auth_hash["info"]["email"]).and_return email_address
        subject
      end
    end

    context "when invalid email" do
      let(:auth_hash) { rogue_auth_hash }

      it { is_expected.to be_nil }
    end

    context "when a new person" do
      let(:auth_hash) { valid_auth_hash }

      it_behaves_like "new person created" do
        let(:expected_email) { "example.user@digital.justice.gov.uk" }
        let(:expected_name) { "John Doe" }
      end
    end
  end

  describe ".person_from_token" do
    subject { described_class.new.person_from_token(token) }

    let(:token) { create(:token, user_email: "aled.jones@digital.justice.gov.uk") }

    context "when a new person" do
      it_behaves_like "new person created" do
        let(:expected_email) { token.user_email }
        let(:expected_name) { "Aled Jones" }
      end
    end

    context "when an existing person" do
      let(:person) { create(:person_with_multiple_logins, given_name: "aled", surname: "jones", email: "aled.jones@digital.justice.gov.uk") }

      before do
        person
      end

      it_behaves_like "existing person returned"
    end
  end
end
