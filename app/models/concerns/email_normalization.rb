module EmailNormalization
  def normalize_email(e)
    e && e.strip.downcase
  end
end
