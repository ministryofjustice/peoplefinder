
require 'spec_helper'

describe 'AOTokenFilter' do

  before(:each) do
    @token_service = TokenService.new
  end

  it 'the filter should say no access if you dont have a valid token' do
    controller = double('ApplicationController')
    request = double('request')

    allow(request).to receive(:path) { '/test/this' }
    allow(controller).to receive(:params) { {token: 'mytoken', entity: 'test'} }
    allow(controller).to receive(:request) { request }

    has_access = AOTokenFilter.has_access(controller)

    has_access.should eq(false)
  end

  it 'the filter should pass if you have a valid token' do
    controller = double('ApplicationController')
    request = double('request')

    path = '/my/valid/path'
    entity = 'ao@justice.com'

    token = @token_service.generate_token(path, entity, DateTime.now.at_end_of_day)

    allow(request).to receive(:path) { path }
    allow(controller).to receive(:params) { {token: token, entity: entity} }
    allow(controller).to receive(:request) { request }

    has_access = AOTokenFilter.has_access(controller)
    has_access.should eq(true)

  end

  it 'the filter should say no access if you provide empty token' do
    controller = double('ApplicationController')
    request = double('request')

    allow(request).to receive(:path) { '/test/this' }
    allow(controller).to receive(:params) { { entity: 'test'} }
    allow(controller).to receive(:request) { request }

    has_access = AOTokenFilter.has_access(controller)

    has_access.should eq(false)
  end

  it 'the filter should say no access if you provide empty entity' do
    controller = double('ApplicationController')
    request = double('request')

    allow(request).to receive(:path) { '/test/this' }
    allow(controller).to receive(:params) { { token: 'test'} }
    allow(controller).to receive(:request) { request }

    has_access = AOTokenFilter.has_access(controller)

    has_access.should eq(false)
  end

  it 'the filter should say no access if you have a are in the wrong path' do
    controller = double('ApplicationController')
    request = double('request')

    path = '/my/valid/path'
    entity = 'ao@justice.com'

    token = @token_service.generate_token(path, entity, DateTime.now.at_end_of_day)

    allow(request).to receive(:path) { '/other' }
    allow(controller).to receive(:params) { {token: token, entity: entity} }
    allow(controller).to receive(:request) { request }

    has_access = AOTokenFilter.has_access(controller)
    has_access.should eq(false)

  end


end