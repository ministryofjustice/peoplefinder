class Objective < ActiveRecord::Base
  belongs_to :agreement
  validates :objective_type, presence: true
end
