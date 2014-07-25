require 'rails_helper'

RSpec.describe Agreement, :type => :model do
  let(:email) { generate(:email) }

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
