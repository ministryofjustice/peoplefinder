class GroupSearch
  def initialize query
    @query = query
  end

  def perform_search
    return [] if @query.blank?

    exact_matches.push(*partial_matches).uniq
  end

  private

  def words query
    query.gsub(/\W/, ' ').split.select { |x| x.length > 1 }
  end

  def exact_matches
    results = Group.where('name = ? OR acronym = ?', @query, @query)
    hierarchy_ordered results
  end

  def partial_matches
    words = words(@query)
    results = words.inject(Group) do |search, word|
      search.where('name ILIKE ?', "%#{word}%")
    end
    hierarchy_ordered results
  end

  def hierarchy_ordered results
    results.sort_by(&:ancestry_depth)
  end

end
