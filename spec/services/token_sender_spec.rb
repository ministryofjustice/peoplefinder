require "rails_helper"
require_relative "../../app/services/token_sender"

RSpec.describe TokenSender, type: :service do
  include PermittedDomainHelper

  subject(:token_sender) { described_class.new(email) }

  let(:email) { "user.name@digital.justice.gov.uk" }
  let(:view) { double }

  def assigned_token
    subject.instance_variable_get(:@token)
  end

  shared_examples "generates token" do
    before do
      allow(view).to receive(:render_create_view)
    end

    it "generates a new token" do
      expect { subject.call(view) }.to change(Token, :count).by 1
    end
  end

  describe "#obtain_token" do
    context "when active token exists for given user_email" do
      let!(:token) { instance_double(Token, active?: true, value: "xyz") }
      let!(:new_token) { instance_double(Token, save: true, valid?: true) }

      before do
        allow(Token).to receive(:find_unspent_by_user_email).and_return token
        allow(SecureRandom).to receive(:uuid).and_return "abc"
      end

      it "creates new token with same value as original" do
        allow(Token).to receive(:new).with(user_email: email, value: "xyz").and_return new_token
        allow(token).to receive(:update_attribute).with(:value, "abc")
        token_sender.obtain_token
        expect(assigned_token).to eql new_token
      end

      it "changes value of original token" do
        allow(Token).to receive(:new).with(user_email: email, value: "xyz").and_return new_token
        expect(token).to receive(:update_attribute).with(:value, "abc")
        token_sender.obtain_token
      end

      it "returns true" do
        allow(Token).to receive(:new).with(user_email: email, value: "xyz").and_return new_token
        allow(token).to receive(:update_attribute).with(:value, "abc")
        expect(token_sender.obtain_token).to eq true
      end
    end

    context "when inactive token exists for given user_email" do
      let!(:token) { instance_double(Token, active?: false) }

      before do
        allow(Token).to receive(:find_unspent_by_user_email).and_return token
      end

      include_examples "generates token"

      it "does not rebuild the existing token" do
        token_sender.obtain_token
        expect(assigned_token).not_to eql token
      end
    end

    context "when no token exists for given user_email" do
      include_examples "generates token"

      context "with an error when saving new token" do
        let(:error_message) { "Email address is not formatted correctly" }

        before do
          new_token = instance_double(Token, save: false, errors: { user_email: [error_message] })
          allow(Token).to receive(:new).with(user_email: email).and_return new_token
        end

        it "returns false" do
          expect(token_sender.obtain_token).to eq false
        end

        it "assigns token with errors" do
          token_sender.obtain_token
          expect(assigned_token.errors[:user_email]).to include error_message
        end
      end
    end
  end

  describe "#call with view" do
    context "when no token obtained" do
      let(:new_token) { instance_double(Token, save: false, valid?: false, errors: { user_email: ["my error"] }) }

      before do
        allow(Token).to receive(:new).with(user_email: email).and_return new_token
      end

      context "with a specific type of error is raised (email invalid or token limit exceeded)" do
        before do
          allow(token_sender).to receive(:user_email_error?).and_return true # rubocop:disable RSpec/SubjectStub
        end

        it "calls render_new_view_with_errors with erroneous token" do
          expect(view).to receive(:render_new_view_with_errors).with(token: new_token)
          token_sender.call(view)
        end
      end

      context "when an unexpected error is raised" do
        before do
          allow(token_sender).to receive(:user_email_error?).and_return false # rubocop:disable RSpec/SubjectStub
        end

        it "calls render_create_view with nil token" do
          expect(view).to receive(:render_create_view).with(token: nil)
          token_sender.call(view)
        end
      end
    end

    context "when token obtained" do
      let(:token) { instance_double(Token, save: true, valid?: true) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

      before do
        allow(Token).to receive(:new).with(user_email: email).and_return token
        allow(TokenMailer).to receive(:new_token_email).and_return mailer
        allow(mailer).to receive(:deliver_later)
        allow(view).to receive(:render_create_view)
      end

      it "calls render_create_view with token" do
        expect(view).to receive(:render_create_view).with(token:)
        token_sender.call(view)
      end

      it "sends token email" do
        allow(TokenMailer).to receive(:new_token_email).with(token).and_return mailer
        expect(mailer).to receive(:deliver_later).with(queue: :high_priority)
        token_sender.call(view)
      end
    end
  end
end
