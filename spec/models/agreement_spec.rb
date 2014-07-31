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

  context 'objectives have changed' do
    subject { build(:agreement) }

    it "should reset sign-off on update if an objective has been added" do
      subject.objectives_signed_off_by_manager = true
      subject.objectives_signed_off_by_staff_member = true
      subject.save!

      subject.objectives.build attributes_for(:objective)
      subject.save!

      subject.reload
      expect(subject.objectives_signed_off_by_manager).to eql(false)
      expect(subject.objectives_signed_off_by_staff_member).to eql(false)
    end

    it "should reset sign-off on update if an objective has been removed" do
      subject.save!
      create(:objective, agreement: subject)
      subject.reload

      subject.objectives_signed_off_by_manager = true
      subject.objectives_signed_off_by_staff_member = true
      subject.save!

      objective = subject.objectives[0]
      subject.objectives.destroy(objective)
      subject.save!

      subject.reload
      expect(subject.objectives_signed_off_by_manager).to eql(false)
      expect(subject.objectives_signed_off_by_staff_member).to eql(false)
    end

    it "should reset sign-off on update if an objective has been changed" do
      subject.save!
      create(:objective, agreement: subject)
      subject.reload

      subject.objectives_signed_off_by_manager = true
      subject.objectives_signed_off_by_staff_member = true
      subject.save!

      subject.objectives[0].description = "Changed"
      subject.save!

      subject.reload
      expect(subject.objectives_signed_off_by_manager).to eql(false)
      expect(subject.objectives_signed_off_by_staff_member).to eql(false)
    end

    it "should reset staff member sign-off if manager changed and signed off" do
      subject.objectives_signed_off_by_staff_member = true
      subject.save!

      subject.objectives.build attributes_for(:objective)
      subject.objectives_signed_off_by_manager = true
      subject.save!
      subject.reload

      expect(subject.objectives_signed_off_by_manager).to be true
      expect(subject.objectives_signed_off_by_staff_member).to be false
    end

    it "should reset staff member sign-off if staff_member changed and signed off" do
      subject.objectives_signed_off_by_manager = true
      subject.save!

      subject.objectives.build attributes_for(:objective)
      subject.objectives_signed_off_by_staff_member = true
      subject.save!
      subject.reload

      expect(subject.objectives_signed_off_by_staff_member).to be true
      expect(subject.objectives_signed_off_by_manager).to be false
    end

    it "should complete sign-off by manager" do
      subject.objectives_signed_off_by_staff_member = true
      subject.save!

      subject.update_attributes(
        objectives_signed_off_by_manager: true
      )
      subject.reload

      expect(subject.objectives_signed_off_by_manager).to be true
      expect(subject.objectives_signed_off_by_staff_member).to be true
    end

    it "should complete sign-off by staff_member" do
      subject.objectives_signed_off_by_manager = true
      subject.save!

      subject.update_attributes(
        objectives_signed_off_by_staff_member: true
      )
      subject.reload

      expect(subject.objectives_signed_off_by_staff_member).to be true
      expect(subject.objectives_signed_off_by_manager).to be true
    end
  end
end
