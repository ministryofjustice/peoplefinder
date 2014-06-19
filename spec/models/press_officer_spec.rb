require 'spec_helper'

describe PressOfficer do
  	let(:pofficer) {build(:press_officer)}

  	it 'should pass factory build' do
  		expect(pofficer).to be_valid
  	end

  	it 'should have a unique email' do
		pofficer = create(:press_officer, name: 'PO one', email: 'first.name@po.com')
		duplicate = build(:press_officer, name: 'PO two', email: 'first.name@po.com')
		expect(duplicate).to be_invalid
  	end

  	it 'should have a press desk' do
  		pofficer.press_desk_id = nil
  		expect(pofficer).to be_invalid
	end

  describe "associations" do
     
    it "should have a press office attribute" do
      @depdir = pofficer.should respond_to(:press_desk)
    end
  end
end
