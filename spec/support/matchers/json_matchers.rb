RSpec::Matchers.define :be_json do
  match do |actual|
    begin
      JSON.parse(actual)
    rescue JSON::ParserError
      false
    end
  end

  failure_message do |actual|
    "\"#{actual}\" is not parsable by JSON.parse"
  end

  failure_message_when_negated do |actual|
    "\"#{actual}\" is parsable by JSON.parse"
  end

  description do
    "be JSON parsable String"
  end
end
