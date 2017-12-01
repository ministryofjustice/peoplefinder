namespace :peoplefinder do
  namespace :accounts do
    desc 'Reconcile the internal_auth_key with the ABC record'
    task :reconcile, [:path] => :environment do  |_, args|
      ARGV.each { |a| task a.to_sym do ; end }

      if ARGV[1].empty?
        puts 'Running in preview mode, no changes will be commited'
        puts 'To commit changes, run:'
        puts 'rake peoplefinder:accounts:reconcile commit_changes'
      end

      Person.all.each do |person|
        sleep 0.5
        auth_user_email = AuthUserLoader.find_auth_email(person.internal_auth_key)
        next unless auth_user_email

        puts '-----------------'
        puts "Current internal_auth_key: #{person.internal_auth_key}"
        puts "AuthUser email found: #{auth_user_email}"

        duplicates = Person.where(internal_auth_key: auth_user_email)

        if duplicates.empty?
          puts "No duplicates"

          if ARGV[1] == 'commit_changes'
            puts "Updating #{person.email}'s internal_auth_key to: #{auth_user_email}"
            person.update_column(internal_auth_key: immutable_email)
          else
            puts 'Running in preview mode, no changes made'
          end
        else
          puts 'Duplicates found for the following email addresses:'
          puts duplicates.map(&:email).join(', ')
          puts 'No updates will be performed'
        end
      end
    end
  end
end

