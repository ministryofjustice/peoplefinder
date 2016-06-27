require 'rails_helper'

describe RailsHost do

  context 'staging' do
    before do
      @initial_env = ENV['ENV']
      ENV['ENV'] = 'staging'
    end

    after do
      ENV['ENV'] = @initial_env
    end

    it 'returns the rails environement host name' do
      expect(Rails.host.env).to eq 'staging'
    end

    it 'returns true for staging?' do
      expect(Rails.host.staging?).to be true
    end

    it 'returns false for production?' do
      expect(Rails.host.production?).to be false
    end

    it 'returns false for dev?' do
      expect(Rails.host.dev?).to be false
    end

  end

  context 'dev' do
    before do
      @initial_env = ENV['ENV']
      ENV['ENV'] = 'dev'
    end

    after do
      ENV['ENV'] = @initial_env
    end

    it 'returns the rails environement host name' do
      expect(Rails.host.env).to eq 'dev'
    end

    it 'returns true for staging?' do
      expect(Rails.host.staging?).to be false
    end

    it 'returns false for production?' do
      expect(Rails.host.production?).to be false
    end

    it 'returns false for dev?' do
      expect(Rails.host.dev?).to be true
    end

  end

end
