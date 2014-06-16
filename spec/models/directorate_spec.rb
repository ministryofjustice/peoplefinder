require 'spec_helper'

describe Directorate do
  	let(:dir) {build(:directorate)}

  	it 'should pass factory build' do
  		expect(dir).to be_valid
  	end
  	
  describe "associations" do
     
    it "should have a divisions collection" do
      @divs = dir.should respond_to(:divisions)
    end
 
  end
end
