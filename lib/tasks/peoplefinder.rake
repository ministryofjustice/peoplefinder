namespace :peoplefinder do

  def inadequate_profiles
    @inadequate_profiles = Peoplefinder::Person.inadequate_profiles
  end

  def inadequate_profiles_with_email
    inadequate_profiles.select { |person| person.email.present? }
  end

  desc 'list the email addresses of people with inadequate profiles'
  task inadequate_profiles: :environment do

    inadequate_profiles.each do |person|
      puts "#{ person.surname }, #{ person.given_name }: #{ person.email }"
    end
    puts "\n** There are #{ inadequate_profiles.count } inadequate profiles."
    puts "** #{ inadequate_profiles_with_email.count }
      inadequate profiles have email addresses."
    puts "\n"
  end

  desc 'email people with inadequate profiles'
  task inadequate_profile_reminders: :environment do
    recipients = inadequate_profiles_with_email

    puts "\nYou are about to email #{ recipients.count } people"
    puts 'Are you sure you want to do this? [Y/N]'

    if STDIN.gets.chomp == 'Y'
      recipients.each do |recipient|

        if Peoplefinder::EmailAddress.new(recipient.email).valid_address?
          Peoplefinder::ReminderMailer.inadequate_profile(recipient).deliver
          puts "Email sent to: #{ recipient.email }"

        else
          puts "Email *not* sent to: #{ recipient.email }"
        end
      end

    end
  end
end
