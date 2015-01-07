class TabularReviewAggregator
  include Enumerable

  def initialize(reviews)
    @reviews = reviews
  end

  def each
    yield header
    Review::ALL_FIELDS.each do |question|
      yield [question] + @reviews.map { |r| answer(r, question) }
    end
  end

private

  def header
    [:question] + @reviews.map(&:author_name)
  end

  def answer(review, question)
    ans = review.send(question)
    ans == 0 ? nil : ans
  end
end
