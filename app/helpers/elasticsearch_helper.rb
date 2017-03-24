module ElasticsearchHelper

  HIGHLIGHTER_TAGS = (PersonSearch::PRE_TAGS + PersonSearch::POST_TAGS).freeze

  def es_highlighter hit, person, attribute
    hit.try(:highlight).try(attribute) ? sanitize_highlighter(hit, person, attribute) : person.__send__(attribute)
  end

  private

  def sanitize_highlighter hit, person, attribute
    unsanitized = hit.highlight.__send__(attribute).join.html_safe
    unhighlighted = strip_highlighting!(hit.highlight.__send__(attribute).join.html_safe)
    sanitized = sanitize person.__send__(attribute)

    unhighlighted == sanitized ? unsanitized : person.__send__(attribute)
  end

  def strip_highlighting! html
    HIGHLIGHTER_TAGS.each_with_object(html) do |tag, memo|
      memo.gsub!(tag, '')
    end
  end

end
