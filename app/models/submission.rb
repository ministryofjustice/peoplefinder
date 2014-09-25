class Submission < SimpleDelegator
  extend ActiveModel::Naming

  def to_model
    self
  end
end
