require 'spec_helper'
require 'email_extractor'

RSpec.describe EmailExtractor, type: :service do
  subject {
    described_class.new
  }

  it 'returns the original email when supplied with a valid email address' do
    expect(subject.extract("user.o'postrophe@example.com")).
      to eq("user.o'postrophe@example.com")
  end

  it 'returns an email address in <>' do
    expect(subject.extract("John <user.o'postrophe@example.com>")).
      to eq("user.o'postrophe@example.com")
  end

  it 'returns an email address in ()' do
    expect(subject.extract("John (user.o'postrophe@example.com)")).
      to eq("user.o'postrophe@example.com")
  end

  it 'returns nil if email is nil' do
    expect(subject.extract(nil)).to be_nil
  end

  it 'returns the original content if no email address is found' do
    expect(subject.extract('rubbish')).to eq('rubbish')
  end

  it 'finds the best email address amongst multiple sets of parentheses' do
    expect(subject.extract("(102 PF) (user.o'postrophe@example.com)")).
      to eq("user.o'postrophe@example.com")
  end

  it 'strips space around the email address' do
    expect(subject.extract("  user.o'postrophe@example.com  ")).
      to eq("user.o'postrophe@example.com")
  end
end
