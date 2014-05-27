require 'spec_helper'

describe PQ do
	let(:newQ) {build(:PQ)}

	describe 'validation' do

		it 'should pass onfactory build' do
			expect(newQ).to be_valid
		end
		it 'should have a Uin' do
			newQ.uin=nil
			expect(newQ).to be_invalid
		end
		it 'should have a Raising MP ID' do
			newQ.raising_member_id=nil
			expect(newQ).to be_invalid
		end
		it 'should have text' do
			newQ.question=nil
			expect(newQ).to be_invalid
		end
		it 'should not allow press interest to be set if it has not been seen by press office' do
			newQ.seen_by_press=true
			expect(newQ).to be_invalid
			newQ.press_interest=true
			expect(newQ).to be_valid
			newQ.press_interest=false
			expect(newQ).to be_valid
		end
		xit 'should not allow finance interest to be set if it has not been seen by finance' do
			newQ.seen_by_finance=true
			expect(newQ).to be_invalid
			newQ.finance_interest=true
			expect(newQ).to be_valid
			newQ.finance_interest=false
			expect(newQ).to be_valid
		end
	end
	describe 'item' do
		it 'should allow press interest to be set' do
			newQ.seen_by_press=true
			newQ.press_interest=true
			expect(newQ).to be_valid
			newQ.press_interest=false
			expect(newQ).to be_valid
		end
		it 'should allow finance interest to be set' do
			newQ.finance_interest=true
			expect(newQ).to be_valid
			newQ.finance_interest=false
			expect(newQ).to be_valid
		end
	end
end
