class GroupSearch
  def initialize query
    @query = query
  end

  def perform_search
    return [] if @query.blank?

    (exact_matches + partial_matches).uniq
  end

  private

  def words query
    query.gsub(/\W/, ' ').split.select { |x| x.length > 1 }
  end

  def exact_matches
    Group.where(name: @query).to_a
  end

  def partial_matches
    words = words(@query)
    search = Group
    words.each do |word|
      search = search.where('name ILIKE ?', "%#{word}%")
    end
    search
  end

end
