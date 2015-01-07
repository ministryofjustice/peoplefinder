class MultiUserCSVRenderer
  def initialize(users)
    @users = users
  end

  def to_csv
    @users.map { |u| UserCSVRenderer.new(u).to_csv }.join("\n")
  end
end
