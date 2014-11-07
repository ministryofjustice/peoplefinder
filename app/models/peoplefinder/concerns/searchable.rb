require 'peoplefinder'

module Peoplefinder::Concerns::Searchable
  extend ActiveSupport::Concern

  included do
    after_save ->(person) { SEARCH_INDEX.index(person) }, on: :update
    after_save ->(person) { SEARCH_INDEX.index(person) }, on: :create
    after_destroy ->(person) { SEARCH_INDEX.delete(person) }
  end
end
