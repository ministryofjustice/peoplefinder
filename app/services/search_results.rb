require 'forwardable'

class SearchResults
  extend Forwardable
  def_delegators :set, :size, :each, :present?, :empty?

  attr_accessor :set, :contains_exact_match

  def initialize(set = [], contains_exact_match = false)
    @set = set
    @contains_exact_match = contains_exact_match
  end

  def each_with_hit(&block)
    if @set.is_a? Elasticsearch::Model::Response::Records
      @set.each_with_hit(&block)
    else
      @set.each(&block)
    end
  end

end
