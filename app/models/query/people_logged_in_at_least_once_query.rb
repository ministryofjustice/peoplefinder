module Query
  class PeopleLoggedInAtLeastOnceQuery
    class << self
      delegate :call, to: :new
    end

    def initialize(relation = Person.all)
      @relation = relation
    end

    def call
      @relation.where('login_count > 0')
    end
  end
end
