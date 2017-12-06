module Admin
  class ProfileExtractsController < ApplicationController
    require 'csv'
    before_action :authorize_user

    def show
      respond_to do |format|
        format.csv do
          send_data people_csv, filename: "profiles-#{Time.zone.today}.csv"
        end
      end
    end

    private

    def people_csv
      @people = Person.includes(memberships: [:group]).order(:given_name)

      CSV.generate(headers: true) do |csv|
        csv << profile_headers
        @people.each do |person|
          csv << person_row(person)
        end
      end
    end

    def profile_headers
      %w(
        Firstname Surname Email InternalAuthKey AddressLondonOffice
        AddressOtherUKRegional AddressOtherOverseas City Country JobTitle
      )
    end

    def person_row(person)
      [
        person.given_name, person.surname, person.email, person.internal_auth_key,
        person.formatted_buildings, person.other_uk, person.other_overseas,
        person.city, person.country_name, person.memberships.first.try(:role)
      ]
    end

    def authorize_user
      authorize 'Admin::Management'.to_sym, :csv_extract_report?
    end
  end
end
