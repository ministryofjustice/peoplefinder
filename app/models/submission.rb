class Submission < Reply
  default_scope { where(status: [:accepted, :started, :submitted]) }

  REQUIRED_FIELDS =
    SECTION_1_RATING_FIELDS + SECTION_2_RATING_FIELDS +
    %i[ leadership_comments how_we_work_comments ]

  REQUIRED_FIELDS.each do |field|
    validates field, presence: true, if: ->(a) { a.status == :submitted }
  end
end
