# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  group_id   :integer          not null
#  person_id  :integer          not null
#  role       :text
#  created_at :datetime
#  updated_at :datetime
#  leader     :boolean          default(FALSE)
#  subscribed :boolean          default(TRUE), not null
#

class Membership < ApplicationRecord
  has_paper_trail class_name: 'Version',
                  ignore: [:updated_at, :created_at, :id]

  belongs_to :person, touch: true
  belongs_to :group, touch: true

  validates :person, presence: true, on: :update
  validates :group, presence: true, on: [:create, :update]
  validates_with PermanentSecretaryUniqueValidator

  delegate :name, to: :person, prefix: true
  delegate :image, to: :person, prefix: true
  delegate :name, to: :group, prefix: true, allow_nil: true
  delegate :path, to: :group

  include Concerns::ConcatenatedFields
  concatenated_field :to_s, :group_name, :role, join_with: ', '

  scope :subscribing, -> { where(subscribed: true) }

  before_destroy { |m| UpdateGroupMembersCompletionScoreJob.perform_later(m.group) }
end
