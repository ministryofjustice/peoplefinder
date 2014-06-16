require 'spec_helper'

describe ActionOfficer do
  	let(:officer) {build(:action_officer)}

  	it 'should pass factory build' do
  		expect(officer).to be_valid
  	end
  	it 'should have a deputy director' do
  		officer.deputy_director_id = nil
  		expect(officer).to be_invalid
	end

  describe "associations" do
     
    it "should have a deputy director attribute" do
      @depdir = officer.should respond_to(:deputy_director)
    end
    it 'should have a collection of assignments' do
      officer.should respond_to(:action_officers_pqs)
    end
  end
end
