class Invitation < Reply
  default_scope { where(status: %w[ no_response rejected ]) }
end
