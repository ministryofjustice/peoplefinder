require 'csv'

class UsersImporter
  HEADERS = [:name, :email, :manager_email]

  def initialize(io)
    @io = io
  end

  def import
    User.connection.transaction do
      begin
        rows = CSV.new(@io, headers: HEADERS).to_a
        create_users rows
        create_management_relationships rows
      rescue
        raise ActiveRecord::Rollback
      end
    end
  end

private

  def create_users(csv)
    csv.each do |row|
      User.create!(name: row[:name], email: row[:email],
                   participant: true)
    end
  end

  def create_management_relationships(csv)
    csv.each do |row|
      next if row[:manager_email].blank?
      direct_report = lookup_user(row[:email])
      manager = lookup_user(row[:manager_email])
      direct_report.update_attributes(manager: manager)
    end
  end

  def lookup_user(email)
    User.where(email: email).first
  end
end
