class QuestionsMockHttpClient

  def initialize(file = Rails.root.join('config/fixtures/questions.xml'))
    @file = file
  end

  def questions(options = {})
    f = File.open(@file)
    content = f.read
    f.close
    return content
  end
end