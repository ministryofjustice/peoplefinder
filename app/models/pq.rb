class PQ < ActiveRecord::Base
	validates :uin , presence: true, uniqueness:true
	validates :raising_member_id, presence:true
	validates :question, presence:true
 	validates :press_interest, :inclusion => {:in => [true, false]}, if: :seen_by_press
    has_many :action_officers_pq
    has_many :action_officers, :through => :action_officers_pq
    belongs_to :minister #no link seems to be needed for policy_minister_id!?
    belongs_to :policy_minister, :class_name=>'Minister', :foreign_key=>'policy_minister_id'
 	#validates :finance_interest, :inclusion => {:in => [true, false]}, if: :seen_by_finance
  belongs_to :progress


  def self.new_questions()
    at_beginning_of_day = DateTime.now.at_beginning_of_day
    where('created_at >= ?', at_beginning_of_day)
  end

  def self.in_progress()
    at_beginning_of_day = DateTime.now.at_beginning_of_day
    where('created_at < ?', at_beginning_of_day)
  end


  # status queries
  def self.by_status(status_name)
    joins(:progress).where('progresses.name = :search', search: "#{status_name}")
  end

  def self.allocated_accepted()
    by_status(Progress.ALLOCATED_ACCEPTED)
  end
  def self.allocated_pending()
    by_status(Progress.ALLOCATED_PENDING)
  end
  def self.unallocated()
    by_status(Progress.UNALLOCATED)
  end

end
