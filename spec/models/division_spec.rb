require 'spec_helper'

describe Division do
  	let(:div) {build(:division)}

  	it 'should pass factory build' do
  		expect(div).to be_valid
  	end
  	it 'should have a directorate' do
  		div.directorate_id = nil
  		expect(div).to be_invalid
	end

  describe "associations" do
     
    it "should have a directorate attribute" do
      @dir = div.should respond_to(:directorate)
    end
   	it 'should have a collection of Deputy directors' do
   		@deputies = div.should respond_to(:deputy_directors)
   	end
  end
end
