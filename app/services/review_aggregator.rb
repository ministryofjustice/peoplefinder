class ReviewAggregator
  def initialize(reviews)
    @reviews = reviews
  end

  def results(question)
    @reviews.
      map { |r| [r.author_name, r.send(question)] }.
      reject { |_, a| unanswered?(a) }
  end

private

  def unanswered?(answer)
    answer == 0 || answer.blank?
  end
end
