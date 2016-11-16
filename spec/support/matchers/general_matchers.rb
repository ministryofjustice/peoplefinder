require 'rspec/expectations'

RSpec::Matchers.define :include_hash_matching do |expected|
  match do |array_of_hashes|
    array_of_hashes.any? { |element| element.slice(*expected.keys) == expected }
  end

  failure_message do |array_of_hashes|
    "expected #{array_of_hashes} to include key-value pair #{expected.to_s.gsub(/\{|\}/, '')}."
  end

  failure_message_when_negated do |array_of_hashes|
    "expected #{array_of_hashes} not to include key-value pair #{expected.to_s.gsub(/\{|\}/, '')}."
  end
end
