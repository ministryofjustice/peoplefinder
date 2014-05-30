require 'spec_helper'

describe 'TokenService' do

  before(:each) do
    @token_service = TokenService.new()
  end

  describe '#generate_token' do
    it 'should generate a token and store the token digest in the database' do
      # Wed, 20 Jan 2026 10:00:00 +0000
      expire_on = DateTime.new(2026, 01, 20, 10, 0, 0)
      token_to_send = @token_service.generate_token('/path/one', 'entity_one', expire_on)

      token_to_send.should_not be nil

      token_entry = Token.find_by(path: '/path/one')

      token_entry.should_not be nil
      token_entry.expire.strftime("%Y-%m-%d %H:%M:%S").should eql(expire_on.strftime("%Y-%m-%d %H:%M:%S"))
      token_entry.token_digest.should_not be nil
      token_entry.entity.should eq('entity_one')

    end

    it 'should store only one token for the same path and entity' do
      expire_on = DateTime.new(2026, 01, 20, 10, 0, 0)

      @token_service.generate_token('/path/one', 'entity_one', expire_on)
      # call the service twice
      @token_service.generate_token('/path/one', 'entity_one', expire_on)

      tokens = Token.where(path: '/path/one',  entity: 'entity_one')

      # only one token in the database
      tokens.size.should eq(1)
    end

  end

  describe '#is_valid' do
    it 'should return true if valid token is provided' do
      expire_on = DateTime.new(2026, 01, 20, 10, 0, 0)
      token_to_send = @token_service.generate_token('/path/one', 'entity_one', expire_on)

      is_valid = @token_service.is_valid(token_to_send, '/path/one', 'entity_one')

      is_valid.should eq(true)
    end

    it 'should return false if the token is not correct' do
      expire_on = DateTime.new(2026, 01, 20, 10, 0, 0)
      @token_service.generate_token('/path/one', 'entity_one', expire_on)

      is_valid = @token_service.is_valid('invalid', '/path/one', 'entity_one')

      is_valid.should eq(false)
    end

    it 'should return false if the path is not correct' do
      expire_on = DateTime.new(2026, 01, 20, 10, 0, 0)
      token_to_send = @token_service.generate_token('/path/one', 'entity_one', expire_on)

      is_valid = @token_service.is_valid(token_to_send, '/invalid', 'entity_one')

      is_valid.should eq(false)
    end

    it 'should return false if the entity is not correct' do
      expire_on = DateTime.new(2026, 01, 20, 10, 0, 0)
      token_to_send = @token_service.generate_token('/path/one', 'entity_one', expire_on)

      is_valid = @token_service.is_valid(token_to_send, '/path/one', 'invalid')

      is_valid.should eq(false)
    end


    it 'should return false if token expired' do
      expire_on = DateTime.new(2013, 01, 20, 10, 0, 0)
      token_to_send = @token_service.generate_token('/path/one', 'entity_one', expire_on)

      is_valid = @token_service.is_valid(token_to_send, '/path/one', 'entity_one')

      is_valid.should eq(false)
    end


    it 'should be valid only the last token generated given a path, entity' do
      expire_on = DateTime.new(2026, 01, 20, 10, 0, 0)

      first_token = @token_service.generate_token('/path/one', 'entity_one', expire_on)
      second_token = @token_service.generate_token('/path/one', 'entity_one', expire_on)

      invalid = @token_service.is_valid(first_token, '/path/one', 'entity_one')
      valid = @token_service.is_valid(second_token, '/path/one', 'entity_one')

      invalid.should eq(false)
      valid.should eq(true)

    end

  end

  describe '#delete_expired' do
    it 'should delete expired tokens' do
      expire_on = DateTime.new(2013, 01, 20, 10, 0, 0)

      expire_on_future = DateTime.new(2026, 01, 20, 10, 0, 0)

      @token_service.generate_token('/path/one', 'entity_one', expire_on)
      @token_service.generate_token('/path/two', 'entity_one', expire_on)

      @token_service.generate_token('/path/three', 'entity_one', expire_on_future)

      tokens = Token.where(entity: 'entity_one')
      tokens.size.should eq(3)


      @token_service.delete_expired
      tokens = Token.where(entity: 'entity_one')
      tokens.size.should eq(1)

    end

  end

  end
