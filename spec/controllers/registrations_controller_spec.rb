require 'rails_helper'

RSpec.describe RegistrationsController, :type => :controller do
  describe "GET new" do
    describe "with a valid token" do
      let(:user) { create(:user).tap { |u| u.set_password_reset_token! } }

      it "should assign the user" do
        get :new, { token: user.token } 
        expect(assigns(:user)).to eql(user)
      end
    end

    describe "with an invalid token" do
      it "should redirect to the login page" do
        get :new, { token: 'INVALID' } 
        expect(response).to redirect_to(new_sessions_path)
      end
    end
  end

  describe "PATCH update" do
    let(:password) { generate(:password) }

    describe "with an invalid token" do
      it "should redirect to the login page" do
        patch :update, {
          token: "INVALID",
          user: {
            password: password,
            password_confirmation: password
          }
        }

        expect(response).to redirect_to(new_sessions_path)
      end
    end

    describe "with a valid token" do
      let(:user) { create(:user).tap { |u| u.set_password_reset_token! } }

      describe "with a valid password" do
        before do
          patch :update, {
            token: user.token,
            user: {
              password: password,
              password_confirmation: password
            }
          }
        end

        it "should update the user's password" do
          user.reload
          expect(user.authenticate(password)).to eql(user)
        end

        it "should redirect to the login page" do
          expect(response).to redirect_to(new_sessions_path)
        end
      end

      describe "with a mismatching password confirmation" do
        before do
          patch :update, {
            token: user.token,
            user: {
              password: password,
              password_confirmation: generate(:password)
            }
          }
        end

        it "should not update the user's password" do
          user.reload
          expect(user.authenticate(password)).to be_falsey
        end

        it "should re-render the new template" do
          expect(response).to render_template('new')
        end
      end
    end
  end
end
