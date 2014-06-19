require 'spec_helper'

describe PressDesk do
	let(:pdesk) {build(:press_desk)}

  	it 'should pass factory build' do
  		expect(pdesk).to be_valid
  	end

    it 'should have a name' do
      pdesk.name = nil
      expect(pdesk).to be_invalid 
    end

    it 'should have a unique name' do
      pdesk = create(:press_desk, name: 'Finance desk')
      duplicate = build(:press_desk, name: 'Finance desk')
      expect(duplicate).to be_invalid
    end

    it 'should expose a merged list of email addresses' do

      pdesk.press_officers << build(:press_officer, name: 'PO one', email: 'po.one@po.com')
      pdesk.press_officers << build(:press_officer, name: 'PO two', email: 'po.two@po.com')

      expect(pdesk.email_output).to eql(';po.one@po.com;po.two@po.com')
    end

  describe "associations" do
     
    it "should have a collection of press officers" do
      @depdir = pdesk.should respond_to(:press_officers)
    end
    it 'should have a collection of action officers' do
      pdesk.should respond_to(:action_officers)
    end
  end
end
