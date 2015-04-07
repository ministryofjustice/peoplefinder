require 'rails_helper'

RSpec.describe PingController, type: :controller do
  it 'renders deployment information as JSON' do
    expect(Deployment).to receive(:info).and_return(foo: 'bar')
    get :index
    expect(JSON.parse(response.body)).to eq('foo' => 'bar')
  end
end
