class PeopleLoggedInAtLeastOnceQuery < BaseQuery
  def call
    @relation.where("login_count > 0").ordered_by_name
  end
end
