require 'rails_helper'

RSpec.describe Agreement, :type => :model do
  let(:email) { generate(:email) }

  describe '.editable_by' do
    let(:staff_member) { create(:user) }
    let(:manager) { create(:user) }

    let(:staff_member_agreement) { create(:agreement, staff_member: staff_member) }
    let(:manager_agreement) { create(:agreement, manager: manager) }

    subject { Agreement.editable_by(user) }

    context 'when the user is a staff_member' do
      let(:user) { staff_member }

      it 'returns the agreements for that staff_member' do
        expect(subject).to include(staff_member_agreement)
      end

      it ' does not return the agreements for that manager' do
        expect(subject).not_to include(manager_agreement)
      end

      context 'and that user has agreements as a manager and a staff_member' do
        before do
          manager_agreement.update_attribute :staff_member, staff_member
        end

        it 'returns the agreements for that user as a staff_member' do
          expect(subject).to include(staff_member_agreement)
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

      it ' does not return the agreements for that staff_member' do
        expect(subject).not_to include(staff_member_agreement)
      end
    end
  end
end
