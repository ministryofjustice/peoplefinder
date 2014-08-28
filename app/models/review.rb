class Review < ActiveRecord::Base
  belongs_to :subject, class_name: 'User'
  belongs_to :author, class_name: 'User', foreign_key: 'author_email',
                      primary_key: 'email'

  has_many :tokens

  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_name, presence: true

  def send_feedback_request
    ReviewMailer.feedback_request(self, tokens.create).deliver
  end

  def accepted?
    status =~ /accept/
  end

  def declined?
    status =~ /decline/
  end
end
