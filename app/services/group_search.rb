class GroupSearch
  def initialize query
    @query = query
  end

  def perform_search
    return [] if @query.blank?

    Group.where(name: @query).to_a
  end

end
