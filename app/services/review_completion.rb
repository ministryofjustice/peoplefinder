class ReviewCompletion
  def initialize(reviews)
    @reviews = reviews.to_a
  end

  def completed
    @reviews.count(&:complete?)
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
