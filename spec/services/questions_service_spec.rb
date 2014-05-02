require 'spec_helper'

describe 'QuestionsService' do

  it 'questions should return a list with data' do

    true.should eq(sample_questions.read)
  end
end