RSpec::Matchers.define :match_sql do |expected|
  def squish_sql(text)
    text.sub(/^\s*/, '').tr("\n", ' ').gsub(/\s+/, ' ').gsub(/\s+$/, '').gsub(/\(\s+/, '(').gsub(" ,", ',').downcase
  end

  match do |actual|
    squish_sql(actual) == squish_sql(expected)
  end
  failure_message do |actual|
    "Normalized SQL does not match.\nexpected SQL:\n   #{squish_sql(expected)}\nactual SQL:\n   #{squish_sql(actual)}\n"
  end
end
