require 'rspec/expectations'
require 'byebug'

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

RSpec::Matchers.define :have_constant do |expected|
  match do |owner|
    result = owner.const_defined?(expected[:name])
    result = owner.const_get(expected[:name]) == expected[:value] if expected.key? :value
    result
  end

  description do
    string = "have constant named #{expected[:name]}"
    string += " with a value of #{expected[:value]}." if expected.key? :value
    string
  end

  failure_message do |owner|
    msg = "expected #{owner} to have a constant named #{expected[:name]} defined"
    msg += " with a value of #{expected[:value]}." if expected.key? :value
    msg
  end

  failure_message_when_negated do |owner|
    msg = "expected #{owner} not to have a constant named #{expected[:name]} defined "
    msg += "with a value of #{expected[:value]}." if expected.key? :value
    msg
  end
end
