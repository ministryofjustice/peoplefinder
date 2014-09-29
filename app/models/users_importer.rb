require 'csv'

class UsersImporter
  HEADERS = [:name, :email, :manager_email]

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
    CSV.new(io, headers: HEADERS).map { |row|
      row.to_hash.merge(
        email: maybe_downcase(row[:email]),
        manager_email: maybe_downcase(row[:manager_email])
      )
    }
  end

  def maybe_downcase(s)
    s && s.downcase
  end

  def create_or_update_users(csv)
    csv.each do |row|
      user = User.where(email: row[:email]).first || User.new
      user.update!(name: row[:name], email: row[:email], participant: true)
    end
  end

  def create_or_update_management_relationships(csv)
    csv.each do |row|
      next if row[:manager_email].blank?
      direct_report = lookup_user(row[:email])
      manager = lookup_user(row[:manager_email])
      direct_report.update manager: manager
    end
  end

  def lookup_user(email)
    User.where(email: email).first
  end
end
