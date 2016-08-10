require 'forwardable'

class SearchResults
  extend Forwardable
  def_delegators :set, :size, :each

  attr_accessor :set, :contains_exact_match

  def initialize set=[], contains_exact_match=false
    @set = set
    @contains_exact_match = contains_exact_match
  end

  def clear
    @set = []
    @contains_exact_match = false
    self
  end
end