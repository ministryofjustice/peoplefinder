require 'csv'

class UserImporter
  include EmailNormalization

  def initialize(io)
    @io = io
  end

  def import
    with_rollback do
      rows = read_and_normalize_csv(@io)
      rows.each do |row|
        create_or_update_user row
      end
      rows.each do |row|
        create_or_update_management_relationship row
      end
    end
  end

private

  def with_rollback
    User.connection.transaction do
      begin
        yield
      rescue ActiveRecord::RecordInvalid
        raise ActiveRecord::Rollback
      end
    end
  end

  def read_and_normalize_csv(io)
    CSV.new(io, headers: true).map { |row|
      row.to_hash.merge(
        'email' => normalize_email(row['email']),
        'manager_email' => normalize_email(row['manager_email'])
      )
    }
  end

  def create_or_update_user(row)
    user = User.find_or_initialize_by(email: row['email'])
    admin = row['admin'] == '1'
    user.update!(
      name: row['name'],
      email: row['email'],
      job_title: row['job_title'],
      participant: !admin,
      administrator: admin
    )
  end

  def create_or_update_management_relationship(row)
    return if row['manager_email'].blank?
    direct_report = lookup_user(row['email'])
    manager = lookup_user(row['manager_email'])
    direct_report.update manager: manager
  end

  def lookup_user(email)
    User.where(email: email).first
  end
end
