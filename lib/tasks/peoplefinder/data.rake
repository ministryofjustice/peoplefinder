namespace :peoplefinder do
  namespace :data do
    require Rails.root.join('app','services','person_csv_importer')

    DOMAIN = 'fake-moj.justice.gov.uk'.freeze

    class DemoGroupMemberships
      extend Forwardable

      attr_reader :group_membership
      def_delegators :group_membership, :each, :map, :[], :sample, :size

      def initialize
        create_groups
      end

      def create_groups
        moj = Group.where(ancestry_depth: 0).first_or_create!(name: 'Ministry of Justice', acronym: 'MoJ')
        csg = Group.find_or_create_by!(name: 'Corporate Services Group', acronym: 'CSG', parent: moj)
        tech = Group.find_or_create_by!(name: 'Technology', acronym: 'Tech', parent: csg)
        ds = Group.find_or_create_by!(name: 'Digital Services', acronym: 'DS', parent: csg)
        cn = Group.find_or_create_by!(name: 'Content', parent: ds)
        dev = Group.find_or_create_by!(name: 'Development', parent: ds)
        ops = Group.find_or_create_by!(name: 'Webops', parent: ds)
        @group_membership = [[moj, 1], [csg, 1], [tech, 2], [ds, 2], [cn, 1], [dev, 3], [ops, 2]]
      end
    end

    # peoplefinder:data:demo
    #
    # idempotent for groups but will add members
    # when run repeatedly.
    #
    # Group demo data structure is as below (left to right):
    #
    # moj > csg > digital services > content
    #           |                  |
    #           |                  |
    #           > technology       > development
    #                              |
    #                              |
    #                              > webops
    #
    desc 'create basic demonstration data'
    task :demo => :environment do
      DemoGroupMemberships.new.each do |group, member_count|
        RandomGenerator.new(group).generate_members(member_count, DOMAIN)
      end
      puts 'Generated random basic demonstration data'
      Rake::Task["peoplefinder:data:search_scenario_1"].invoke
      Rake::Task["peoplefinder:es:index_people"].invoke
    end

    desc 'generate data for steve\'s search scenario'
    task :search_scenario_1 => [:environment, :demo] do

      names = [
        'Steve Richards',
        'Steven Richards',
        'Stephen Richards',
        'Steve Richardson',
        'Steven Richardson',
        'Stephen Richardson',
        'John Richards',
        'Pauline Richards',
        'Steve Edmundson',
        'Steven Edmundson',
        'Stephen Edmundson',
        'John Richardson',
        'John Edmundson',
        'Personal Assistant'
      ]

      demo_groups = DemoGroupMemberships.new

      names.each do |name|
        given_name = name.split.first
        surname = name.split.second
        email = "#{given_name.downcase}.#{surname.downcase}@#{DOMAIN}"
        person = Person.find_or_create_by!(given_name: given_name, surname: surname, email: email)
        Membership.create(person_id: person.id, group_id: demo_groups.sample.first.id) if person.memberships.empty?
      end
      Person.find_by(email: "personal.assistant@#{DOMAIN}").update(description: 'PA to Steve Richards')

      puts 'Generated data for steve\'s search scenario'
    end

    desc 'create a valid csv for load testing, [count: number of records=500], [email_prefix: prefix for email addresses generated=nil], [file: path to file=spec/fixtures/]'
    task :demo_csv, [:count, :email_prefix, :file] => :environment do |_task, args|
      require 'csv'

      file = args[:file] || Rails.root.join('spec','fixtures','csv_load_tester.csv').to_path
      count = (args[:count] || '500').to_i
      CSV.open(file,'w') do |csv|
        csv << csv_header
        count.times do |i|
          csv << csv_record(args[:email_prefix])
        end
      end
    end

    def csv_header
      PersonCsvImporter::REQUIRED_COLUMNS + PersonCsvImporter::OPTIONAL_COLUMNS
    end

    def csv_record(email_prefix = nil)
      person = FactoryGirl.build(:person, :with_random_dets)
      person.email.prepend(email_prefix) if email_prefix.present?
      record = []
      csv_header.each do |attribute|
        record += [person.__send__(attribute)]
      end
      record
    end

  end
end
