class ReviewAggregator
  def initialize(reviews)
    @reviews = reviews
  end

  def results(question)
    @reviews.
      map { |r| [r.author_name, r.send(question)] }.
      reject { |_, v| v == 0 || v.to_s.strip.empty? }
  end
end
