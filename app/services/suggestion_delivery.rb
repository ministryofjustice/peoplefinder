class SuggestionDelivery
  attr_reader :recipient_count

  def self.deliver(person, suggester, suggestion)
    new(person, suggester, suggestion).deliver
  end

  def initialize(person, suggester, suggestion)
    @person = person
    @suggester = suggester
    @suggestion = suggestion
    @recipient_count = 0
  end

  def deliver
    deliver_for_person
    deliver_for_admin
    self
  end

  private

  def deliver_for_person
    return unless @suggestion.for_person?
    SuggestionMailer.person_email(@person, @suggester, @suggestion.to_hash).
      deliver_later
    @recipient_count += 1
  end

  def deliver_for_admin
    return unless @suggestion.for_admin?
    @person.groups.flat_map(&:leaders).each do |leader|
      SuggestionMailer.
        team_admin_email(@person, @suggester, @suggestion.to_hash, leader).
        deliver_later
      @recipient_count += 1
    end
  end
end
