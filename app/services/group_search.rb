class GroupSearch

  attr_reader :exact_match_found

  def initialize query
    @query = query
    @exact_match_found = false
  end

  def perform_search
    return [[], false] if @query.blank?

    [exact_matches.push(*partial_matches).uniq, exact_match_exists?]
  end

  private

  def words query
    query.gsub(/\W/, ' ').split.select(&:present?)
  end

  def exact_matches
    results = Group.where('name = ? OR acronym = ?', @query, @query)
    @exact_match_found = results.present?
    hierarchy_ordered results
  end

  def exact_match_exists?
    exact_match_found
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
