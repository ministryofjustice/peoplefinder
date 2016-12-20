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
      change&.first
    end

    def new_val
      change&.second
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

  # over-ride in subclasses requiring fields with special handling
  def format raw_changes
    h = {}
    raw_changes.each do |field, raw_change|
      h.merge!(default(field, raw_change)) if changed? raw_change
    end
    h.deep_symbolize_keys
  end

  protected

  # ignore nil => empty string or vice versa changes
  def changed? change
    change.first&.gsub(/\s/, '').present? || change.second&.gsub(/\s/, '').present?
  rescue
    true
  end

  def template field, &_block
    h = {
      field =>
        {
          raw: nil,
          message: nil
        }
    }
    yield h if block_given?
    h
  end

  def default field, raw_change
    template(field) do |h|
      h[field][:raw] = raw_change
      h[field][:message] = sentence(field, raw_change)&.humanize
    end
  end

  private

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

end
