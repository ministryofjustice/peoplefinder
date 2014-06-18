class Progress < ActiveRecord::Base
  has_many :pqs


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
