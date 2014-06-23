class Person < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :id]
  acts_as_paranoid

  validates_presence_of :surname
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  default_scope { order(surname: :asc, given_name: :asc) }

  def name
    [given_name, surname].compact.join(' ').strip
  end

  def to_s
    name
  end

  def completion_score
    completed = [
      :given_name,
      :surname,
      :email,
      :phone,
      :mobile,
      :location,
      :keywords,
      :description,
    ].map { |f| self.send(f).present? }
    (100 * completed.select { |f| f }.length) / completed.length
  end
end
