class NamesakesQuery < BaseQuery

  class << self
    delegate :call, to: :new
  end

  # remove the initializer if not different from BaseQuery
  def initialize(person)
    @relation = Person.all
    @person = person
  end

  def call
    @relation.where.not(id: @person.id).
      where(
        "(LOWER(surname) = :surname AND LOWER(given_name) = :given_name) OR #{email_prefix_sql} = :email_prefix",
        surname: @person.surname.downcase,
        given_name: @person.given_name.downcase,
        email_prefix: @person.email_prefix
      )
  end

  private

  def email_prefix_sql
    "REGEXP_REPLACE(SUBSTR(email, 0, position('@' in email)), '\\W|\\d', '', 'g')"
  end

end
