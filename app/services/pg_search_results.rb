require "forwardable"

class PgSearchResults
  extend Forwardable
  def_delegators :set, :size, :each, :present?, :empty?

  attr_accessor :set, :contains_exact_match, :hit_builder

  def initialize(set: [], contains_exact_match: false)
    @set = set
    @contains_exact_match = contains_exact_match
  end

  def each_with_hit
    return to_enum(:each_with_hit) unless block_given?

    set.each do |person|
      hit = hit_builder&.call(person)
      yield person, hit
    end
  end
end
