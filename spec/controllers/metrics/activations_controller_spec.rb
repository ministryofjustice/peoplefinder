require 'rails_helper'
RSpec.describe Metrics::ActivationsController, type: :controller do
  let(:date) { Date.parse("2015-11-11").to_s }
  let(:parsed_body) { JSON.parse(response.body).deep_symbolize_keys }

  describe 'GET index' do
    it 'returns geckoboard bullet graph JSON for acquisitions and activations' do
      allow(Person).to receive(:acquired_percentage).with(from: date).and_return(37)
      allow(Person).to receive(:acquired_percentage).with(before: date).and_return(80)
      allow(Person).to receive(:activated_percentage).with(from: date).and_return(20)
      allow(Person).to receive(:activated_percentage).with(before: date).and_return(10)
      expected = {
        orientation: "horizontal",
        item: [
          {
            label: "37% logged in at least once",
            sublabel: "users created from 2015-11-11",
            axis: {
              point: [0, 20, 40, 60, 80, 100]
            },
            range: {
              red:   { start: 0,  end: 20 },
              amber: { start: 21, end: 80 },
              green: { start: 81, end: 100 }
            },
            measure: {
              current:   { start: 0, end: 37 },
              projected: { start: 0, end: 0 }
            },
            comparative: { point: 80 }
          },
          {
            label: "20% of acquired users completed > 80%",
            sublabel: "users created from 2015-11-11",
            axis: {
              point: [0, 20, 40, 60, 80, 100]
            },
            range: {
              red:   { start: 0,  end: 20 },
              amber: { start: 21, end: 80 },
              green: { start: 81, end: 100 }
            },
            measure: {
              current:   { start: 0, end: 20 },
              projected: { start: 0, end: 0 }
            },
            comparative: { point: 10 }
          }
        ]
      }
      get :index, params: { cohort_split_date: date }
      expect(parsed_body).to eq(expected)
    end

    it 'returns 200 OK' do
      get :index, params: { cohort_split_date: date }
      expect(response).to be_ok
    end
  end
end
