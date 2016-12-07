require 'json'
class ChangesPresenter

  #
  # helper to format changes to a dirty model
  # for output in a human friendly format.
  # e.g.
  #
  #   person.email = 'new.email@address.com'
  #   person.primary_phone_number = nil
  #   changes = ChangesPresenter.new(person)
  #   changes.each_pair { |field, change| puts [field, change]}
  #

  extend Forwardable
  include Enumerable

  def_delegator :changes, :[]
  attr_reader :raw

  Change = Struct.new(:change) do
    def old_val
      change.first
    end

    def new_val
      change.second
    end

    def modification?
      old_val.present? && new_val.present?
    end

    def removal?
      old_val.present? && new_val.blank?
    end

    def addition?
      old_val.blank? && new_val.present?
    end
  end

  def initialize raw_changes
    @raw = raw_changes
    changes
  end

  def changes
    @changes ||= format raw
  end

  def serialize
    {
      'json_class' => self.class.name,
      'data' => { 'raw' => raw }
    }.to_json
  end

  def self.deserialize json
    new(JSON.parse(json)['data']['raw'])
  end

  def each
    @changes.each do |change|
      yield change
    end
  end

  def each_pair
    @changes.each_pair do |field, change|
      yield field, change[:message]
    end
  end

  private

  def format raw_changes
    h = {}
    raw_changes.each do |field, raw_change|
      h[field] = default_message(field, raw_change) if changed? raw_change
    end
    h.symbolize_keys
  end

  # TODO: need rules for:
  # - work days
  # - multiple roles
  # - multiple memberships
  # - team leader question
  # - subscription question

  def default_message field, raw_change
    { raw: raw_change, message: sentence(field, raw_change).humanize }
  end

  def sentence field, raw_change
    change = Change.new(raw_change)
    if change.addition?
      "added a #{field}"
    elsif change.removal?
      "removed the #{field}"
    elsif change.modification?
      "changed your #{field} from #{change.old_val} to #{change.new_val}"
    end
  end

  # ignore nil => empty string or vice versa changes
  def changed? change
    change.first&.gsub(/\s/, '').present? || change.second&.gsub(/\s/, '').present?
  rescue
    true
  end

end
