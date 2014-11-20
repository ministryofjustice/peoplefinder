require 'csv'

class UserImporter
  include EmailNormalization

  def initialize(io)
    @io = io
  end

  def import
    User.connection.transaction do
      begin
        rows = read_and_normalize_csv(@io)
        create_or_update_users rows
        create_or_update_management_relationships rows
      rescue ActiveRecord::RecordInvalid
        raise ActiveRecord::Rollback
      end
    end
  end

private

  def read_and_normalize_csv(io)
    CSV.new(io, headers: true).map { |row|
      row.to_hash.merge(
        'email' => normalize_email(row['email']),
        'manager_email' => normalize_email(row['manager_email'])
      )
    }
  end

  def create_or_update_users(csv)
    csv.each do |row|
      user = User.find_or_initialize_by(email: row['email'])
      user.update!(
        name: row['name'],
        email: row['email'],
        job_title: row['job_title'],
        participant: true
      )
    end
  end

  def create_or_update_management_relationships(csv)
    csv.each do |row|
      next if row['manager_email'].blank?
      direct_report = lookup_user(row['email'])
      manager = lookup_user(row['manager_email'])
      direct_report.update manager: manager
    end
  end

  def lookup_user(email)
    User.where(email: email).first
  end
end
