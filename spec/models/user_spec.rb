require 'rails_helper'

RSpec.describe User, type: :model do

  subject { build(:user) }

  context "to_s" do
    it "uses name if available" do
      subject.name = 'John Doe'
      expect(subject.to_s).to eql('John Doe')
    end

    it "uses email if name is unavailable" do
      subject.email = 'user@example.com'
      expect(subject.to_s).to eql('user@example.com')
    end
  end

  it 'normalises email on assignment' do
    subject.email = 'USER@Example.com'
    expect(subject.email).to eql('user@example.com')
  end

  it 'makes direct reports orphans if the manager is destroyed' do
    a = create(:user)
    b = create(:user, manager: a)

    a.destroy
    b.reload

    expect(b.manager_id).to be_nil
  end

  it 'ceases to exist on destroy' do
    a = create(:user)
    create(:user, manager: a)
    a.destroy
    expect {
      described_class.find(a.to_param)
    }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it 'includes only other people who are participants in the available managers' do
    a = create(:user)
    b = create(:user)
    create(:user, participant: false)
    expect(a.available_managers.to_a).to eql([b])
  end
end
