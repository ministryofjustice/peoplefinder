class Submission < Reply
  default_scope { where(status: 'started') }
end
