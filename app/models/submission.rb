class Submission < Reply
  default_scope { where(status: %w[ started submitted ]) }
end
