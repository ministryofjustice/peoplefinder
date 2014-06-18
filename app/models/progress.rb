class Progress < ActiveRecord::Base
  has_many :pqs


  # status finders

  def self.find_by_status(status)
    Progress.find_by_name(status)
  end

  def self.allocated_accepted
    find_by_status(self.ALLOCATED_ACCEPTED)
  end

  def self.allocated_pending
    find_by_status(self.ALLOCATED_PENDING)
  end

  def self.unallocated
    find_by_status(self.UNALLOCATED)
  end


  # status constants

  def self.ALLOCATED_ACCEPTED
    'Allocated Accepted'
  end

  def self.ALLOCATED_PENDING
    'Allocated Pending'
  end

  def self.UNALLOCATED
    'Unallocated'
  end

end
