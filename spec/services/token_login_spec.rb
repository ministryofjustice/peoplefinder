require "rails_helper"

RSpec.describe TokenLogin, type: :service do
  include PermittedDomainHelper

  describe "#call" do
    subject(:service) { described_class.new(token.value) }

    let(:person) { create :person }
    let(:view) { double }
    let(:token) { create :token, user_email: person.email }

    it { is_expected.to respond_to :token }

    it "finds tokens securely" do
      expect_any_instance_of(described_class).to receive(:find_token_securely) # rubocop:disable RSpec/AnyInstance
      service
    end

    context "with active tokens" do
      context "when used in supported browsers" do
        let(:view) { double(supported_browser?: true) } # rubocop:disable RSpec/VerifiedDoubles

        it "logs in and renders view" do
          expect_any_instance_of(described_class).to receive(:login_and_render).with(view) # rubocop:disable RSpec/AnyInstance
          service.call view
        end

        context "when external user" do
          let(:person) { create :external_user }

          it "spends the token" do
            allow(view).to receive(:person_from_token).with(token).and_return person
            allow(view).to receive(:render_or_redirect_login).with(person).and_return nil
            expect_any_instance_of(Token).to receive(:spend!) # rubocop:disable RSpec/AnyInstance
            service.call view
          end
        end

        it "spends the token" do
          allow(view).to receive(:person_from_token).with(token).and_return person
          allow(view).to receive(:render_or_redirect_login).with(person).and_return nil
          expect_any_instance_of(Token).to receive(:spend!) # rubocop:disable RSpec/AnyInstance
          service.call view
        end
      end

      context "when used in unsupported browsers" do
        let(:view) { double(supported_browser?: false) } # rubocop:disable RSpec/VerifiedDoubles

        it "redirects to unsupported browser page" do
          expect(view).to receive(:redirect_to_unsupported_browser_warning)
          service.call view
        end
      end
    end

    context "with expired token" do
      let(:token) { create(:token, spent: true) }

      it "renders expired token message" do
        Timecop.travel(Time.zone.now + token.ttl) do
          expect(view).to receive(:render_new_sessions_path_with_expired_token_message)
          service.call view
        end
      end
    end
  end
end
