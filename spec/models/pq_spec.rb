require 'spec_helper'

describe PQ do
	describe 'validation' do

		let(:newQ) {build(:PQ)}

		it 'should pass onfactory build' do
			expect(newQ).to be_valid
		end
		it 'should have a PIN' do
			newQ.PIN=nil
			expect(newQ).to be_invalid
		end
		it 'should have a Raising MP ID' do
			newQ.RaisingMemberID=nil
			expect(newQ).to be_invalid
		end
		it 'should have text' do
			newQ.Question=nil
			expect(newQ).to be_invalid
		end
	end
end
