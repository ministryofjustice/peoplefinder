class Submission < Reply
  default_scope { where(status: %w[ accepted started submitted ]) }
end
