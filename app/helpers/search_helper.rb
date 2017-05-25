module SearchHelper

  FILTERS = {
    people: 'people',
    teams: 'teams'
  }.freeze

  def people_count
    @people_results&.size || 0
  end

  def team_count
    @team_results&.size || 0
  end

  def result_count
    people_count + team_count
  end

  # sanitize before rendering query term
  #
  def result_summary
    options = { style: 'font-size: 25px;' }
    summary = if matches_exist?
                [bold_tag(pluralize(result_count, 'result'), options), 'found', filter_text]
              else
                [
                  bold_tag(@query, options),
                  'not found -',
                  pluralize(result_count, 'similar result'),
                  filter_text
                ]
              end
    safe_join(summary, ' ')
  end

  def teams_filter?
    filtered_on? FILTERS[:teams]
  end

  def people_filter?
    filtered_on? FILTERS[:people]
  end

  private

  def matches_exist?
    @team_results&.contains_exact_match || @people_results&.contains_exact_match
  end

  def filter_text(delimiter: 'and')
    if people_filter? && teams_filter?
      safe_join_filter [
        FILTERS[:people], count_as_string(people_count),
        delimiter,
        FILTERS[:teams], count_as_string(team_count)
      ]
    elsif teams_filter?
      safe_join_filter [FILTERS[:teams]]
    elsif people_filter?
      safe_join_filter [FILTERS[:people]]
    end&.squish
  end

  def count_as_string count
    count.positive? ? "(#{count})" : ''
  end

  def filtered_on? filter_name
    @search_filters&.include?(filter_name)
  end

  def safe_join_filter array, sep: ' ', preposition: 'from'
    array.unshift preposition
    safe_join(array, sep)
  end

end
