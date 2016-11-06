namespace :peoplefinder do
  namespace :data do
    require Rails.root.join('app','services','person_csv_importer')

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
      puts '...find/create department'
      moj = Group.where(ancestry_depth: 0).first_or_create!(name: 'Ministry of Justice', acronym: 'MoJ')

      puts '...find/create sub departments/groups/teams'
      csg = Group.find_or_create_by!(name: 'Corporate Services Group', acronym: 'CSG', parent: moj)
      tech = Group.find_or_create_by!(name: 'Technology', acronym: 'Tech', parent: csg)
      ds = Group.find_or_create_by!(name: 'Digital Services', acronym: 'DS', parent: csg)
      cn = Group.find_or_create_by!(name: 'Content', parent: ds)
      dev = Group.find_or_create_by!(name: 'Development', parent: ds)
      ops = Group.find_or_create_by!(name: 'Webops', parent: ds)

      DOMAIN = 'fake-moj.justice.gov.uk'.freeze
      puts '...creating fake members of subteams'
      group_membership = [[moj, 1], [csg, 1], [tech, 2], [ds, 2], [cn, 1], [dev, 3], [ops, 2]]
      group_membership.each do |group, member_count|
        RandomGenerator.new(group).generate_members(member_count, DOMAIN)
      end
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
      person = FactoryGirl.build(:person, :with_details)
      person.email.prepend(email_prefix) if email_prefix.present?
      record = []
      csv_header.each do |attribute|
        record += [person.__send__(attribute)]
      end
      record
    end

  end
end
