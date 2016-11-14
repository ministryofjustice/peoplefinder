RSpec::Matchers.define :be_defined do
  match do |actual|
    command = actual.split('.')
    command.first.constantize.public_methods.include?(command.last.to_sym) ||
      command.first.constantize.public_instance_methods.include?(command.last.to_sym)
  end
end
