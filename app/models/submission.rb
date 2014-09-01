class Submission < Reply
  default_scope { where(status: [:accepted, :started, :submitted]) }
end
