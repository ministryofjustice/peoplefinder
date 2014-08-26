require 'rails_helper'

RSpec.describe User, type: :model do

  context "to_s" do
    it "should use name if available" do
      user = User.new
      user.name = 'John Doe'
      expect(user.to_s).to eql('John Doe')
    end

    it "should use email if name is unavailable" do
      user = User.new
      user.email = 'user@example.com'
      expect(user.to_s).to eql('user@example.com')
    end
  end
end
