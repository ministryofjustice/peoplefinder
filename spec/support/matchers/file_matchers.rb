require 'rspec/expectations'

RSpec::Matchers.define :have_file_content do |expected|
  def content file
    File.open(file).read
  end

  match do |actual|
    content(actual) == expected
  end

  failure_message do |actual|
    "expected file #{actual} to have content\n\texpected: #{expected}\n\tgot: #{content(actual)}"
  end

  failure_message_when_negated do |actual|
    "expected file #{actual} NOT to have content\n\tNOT expected: #{expected}\n\tgot: #{content(actual)}"
  end
end

RSpec::Matchers.define :have_created_file do |expected|
  def supports_block_expectations?
    true
  end

  match do |proc|
    File.exist?(expected).eql? false
    proc.call
    File.exist?(expected).eql? true
  end

  failure_message do
    "expected file #{expected} to have been created"
  end

  failure_message_when_negated do
    "expected file #{expected} to not have been created"
  end
end
