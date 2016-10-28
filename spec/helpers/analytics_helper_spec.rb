require 'rails_helper'

RSpec.describe AnalyticsHelper, type: :helper do

  describe '#search_result_analytics_attributes' do
    it 'returns JSON including virtual pageview data expected by GA' do
      expect(search_result_analytics_attributes(1)).to include "virtual-pageview": "/search-result,/top-3-search-result"
      expect(search_result_analytics_attributes(5)).to include "virtual-pageview": "/search-result,/below-top-3-search-result"
    end

    it 'returns JSON event data for GA' do
      expect(search_result_analytics_attributes(3)).to include "event-category": 'Search result click', "event-action": "Click result 004"
    end
  end

  describe '#token_request_analytics_attributes' do
    it 'returns JSON including virtual pageview data expected by GA' do
      expect(token_request_analytics_attributes).to include "virtual-pageview": "/sessions/token-request"
    end
  end

  describe '#edit_profile_analytics_attributes' do
    it 'returns JSON including virtual pageview data expected by GA' do
      expect(edit_profile_analytics_attributes(1)).to include "virtual-pageview": "/people/edit-click"
    end

    it 'returns JSON event data for GA' do
      expect(edit_profile_analytics_attributes(3)).to include "event-category": 'Edit profile click', "event-action": "Click edit person 3"
    end
  end
end
