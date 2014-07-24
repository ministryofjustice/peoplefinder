class BudgetaryResponsibility < ActiveRecord::Base
  belongs_to :agreement

  validates :budget_type, presence: true
  validates :value, presence: true
end
