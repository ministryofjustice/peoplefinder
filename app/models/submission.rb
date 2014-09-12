class Submission < Reply
  default_scope { where(status: [:accepted, :started, :submitted]) }

  delegate :name, to: :subject, prefix: true
end
