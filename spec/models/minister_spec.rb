require 'spec_helper'

describe Minister do
	let(:minister) {build(:minister)}

	it 'should pass factory build' do
		expect(minister).to be_valid
	end

	it 'should have a unique email' do
		minister = create(:minister, name: 'MP one', email: 'first.name@mp.com')
		duplicate = build(:minister, name: 'MP two', email: 'first.name@mp.com')
		expect(duplicate).to be_invalid
	end

	describe "associations" do
		it 'should have a collection of PQs' do
			@pqs = minister.should respond_to(:pqs)
		end
	end
end
