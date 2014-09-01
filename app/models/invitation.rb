class Invitation < Reply
  default_scope { where(status: [:no_response, :rejected]) }
end
