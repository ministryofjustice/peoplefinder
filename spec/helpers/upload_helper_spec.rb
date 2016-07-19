require 'rails_helper'

RSpec.describe UploadHelper, type: :helper do
  describe 'required_headers' do
    let(:html) do
      '<code>given_name</code> ' \
      '<code>surname</code> ' \
      '<code>email</code>'
    end
    it "returns expected html wrapped list of optional columns" do
      expect(required_headers).to eql(html)
    end
  end

  describe 'optional_headers' do
    let(:html) do
      '<code>primary_phone_number</code> ' \
      '<code>pager_number</code> ' \
      '<code>building</code> ' \
      '<code>location_in_building</code> ' \
      '<code>city</code>'
    end
    it "returns expected html wrapped list of optional columns" do
      expect(optional_headers).to eql(html)
    end
  end
end
