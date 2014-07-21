require 'rails_helper'

RSpec.describe Agreement, :type => :model do
  let(:email) { generate(:email) }

  it "should assign an existing user via manager_email" do
    user = create(:user)
    agreement = create(:agreement, manager_email: user.email)
    agreement.reload
    expect(agreement.manager).to eql(user)
  end

  it "should create a new user and assign as manager" do
    agreement = create(:agreement, manager_email: email)
    agreement.reload
    expect(agreement.manager.email).to eql(email)
  end

  it "should assign an existing user via jobholder_email" do
    user = create(:user)
    agreement = create(:agreement, jobholder_email: user.email)
    agreement.reload
    expect(agreement.jobholder).to eql(user)
  end

  it "should create a new user and assign as jobholder" do
    email = generate(:email)
    agreement = create(:agreement, jobholder_email: email)
    agreement.reload
    expect(agreement.jobholder.email).to eql(email)
  end

  describe '.editable_by' do
    let(:jobholder) { create(:user) }
    let(:manager) { create(:user) }

    let(:jobholder_agreement) { create(:agreement, jobholder: jobholder) }
    let(:manager_agreement) { create(:agreement, manager: manager) }

    subject { Agreement.editable_by(user) }

    context 'when the user is a jobholder' do
      let(:user) { jobholder }

      it 'returns the agreements for that jobholder' do
        expect(subject).to include(jobholder_agreement)
      end

      it ' does not return the agreements for that manager' do
        expect(subject).not_to include(manager_agreement)
      end

      context 'and that user has agreements as a manager and a jobholder' do
        before do
          manager_agreement.update_attribute :jobholder, jobholder
        end

        it 'returns the agreements for that user as a jobholder' do
          expect(subject).to include(jobholder_agreement)
        end

        it 'returns the agreements for that user as a manager' do
          expect(subject).to include(manager_agreement)
        end
      end
    end

    context 'when the user is a manager' do
      let(:user) { manager }

      it 'returns the agreements for that manager' do
        expect(subject).to include(manager_agreement)
      end

      it ' does not return the agreements for that jobholder' do
        expect(subject).not_to include(jobholder_agreement)
      end
    end
  end
end
