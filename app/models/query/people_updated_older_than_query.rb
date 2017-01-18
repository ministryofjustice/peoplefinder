module Query

  class PeopleUpdatedOlderThanQuery

    class << self
      delegate :call, to: :new
    end

    def initialize(within, relation = Person.all)
      @relation = relation
      @within = within
    end

    def call
      @relation.where('updated_at < ?', @within)
    end
  end
end
