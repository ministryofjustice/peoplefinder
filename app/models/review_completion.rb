class ReviewCompletion
  def initialize(reviews)
    @reviews = reviews
  end

  def completed
    @reviews.select(&:complete?).length
  end

  def total
    @reviews.length
  end

  def description
    if completed == 0
      :none
    elsif completed == total
      :all
    else
      :some
    end
  end
end
