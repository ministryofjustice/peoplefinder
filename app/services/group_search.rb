class GroupSearch

  def initialize query, results
    @query = query
    @exact_match_found = false
    @results = results
  end

  def perform_search
    return @results.clear if @query.blank?
    @results.set = exact_matches.push(*partial_matches).uniq
    @results.contains_exact_match = @exact_match_found
    @results
  end

  private

  def words query
    query.gsub(/\W/, ' ').split.select(&:present?)
  end

  def exact_matches
    results = Group.where('lower(name) = :query OR lower(acronym) = :query', query: @query.downcase)
    @exact_match_found = results.present?
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
