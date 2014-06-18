# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'Clear tables'
ActiveRecord::Base.connection.execute("TRUNCATE TABLE progresses RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE ministers RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE directorates RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE divisions RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE deputy_directors RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE action_officers RESTART IDENTITY;")

puts '-populate'
progresses = Progress.create([{name: Progress.UNALLOCATED},{name: Progress.ALLOCATED_PENDING},{name: Progress.ALLOCATED_ACCEPTED}])
ministers = Minister.create!([
	{name: 'Chris Grayling', email:'no-emails-1@please.com', title: 'Secretary of State and Lord High Chancellor of Great Britain', deleted: false},
	{name: 'Lord McNally', email:'no-emails-2@please.com', title: 'Minister of State', deleted: false},
	{name: 'Damian Green', email:'no-emails-3@please.com', title: 'Minister of State', deleted: false},
	{name: 'Helen Grant', email:'no-emails-4@please.com', title: 'Parliamentary Under-Secretary of State, Minister for Victims and the Courts (jointly with Government Equalities Office)', deleted: false},
	{name: 'Jeremy Wright', email:'no-emails-5@please.com', title: 'Parliamentary Under-Secretary of State; Minister for Prisons and Rehabilitation', deleted: false},
	{name: 'Ursula Brennan', email:'no-emails-6@please.com', title: 'Permanent Secretary', deleted: false},
	{name: 'Shailesh Vara', email:'no-emails-7@please.com', title: 'Parliamentary Under-Secretary of State', deleted: false},
	{name: 'Ministerial Correspondnece Unit', email:'no-emails-8@please.com', title: 'MCU', deleted: false},
	{name: 'Simon Hughes', email:'no-emails-9@please.com', title: 'Minister of State for Justice & Civil Liberties', deleted: false},
	{name: 'Lord Faulks', email:'no-emails-10@please.com', title: 'Lord Faulks QC, Minister of State', deleted: false}])

directorates = Directorate.create!([
	{name: 'Finanace Assurance and Commercial', deleted: false},
	{name: 'Criminal Justice', deleted: false},
	{name: 'Law and Access to Justice', deleted: false},
	{name: 'NOMS', deleted: false},
	{name: 'HMCTS', deleted: false},
	{name: 'LAA and Corporate Services', deleted: false},
	])

divisions = Division.create!([
	{directorate_id:  1, name: 'Corporate Finance', deleted: false},
	{directorate_id:  1, name: 'Analytical Services', deleted: false},
	{directorate_id:  1, name: 'Procurement', deleted: false},
	{directorate_id:  1, name: 'Change due diligence', deleted: false},
	{directorate_id:  2, name: 'Sentencing and Rehabilitation Policy', deleted: false},
	{directorate_id:  2, name: 'Justice Reform', deleted: false},
	{directorate_id:  2, name: 'Transforming Rehabilitation', deleted: false},
	{directorate_id:  2, name: 'MoJ Strategy', deleted: false},
	{directorate_id:  3, name: 'Law, Rights, International', deleted: false},
	{directorate_id:  3, name: 'Access to Justice', deleted: false},
	{directorate_id:  3, name: 'Judicial Reward and Pensions reform', deleted: false},
	{directorate_id:  3, name: 'Communications and Information', deleted: false},
	{directorate_id:  4, name: 'HR', deleted: false},
	{directorate_id:  4, name: 'Public Sector Prisons', deleted: false},
	{directorate_id:  5, name: 'Civil, Family and Tribunals', deleted: false},
	{directorate_id:  5, name: 'Crime', deleted: false},
	{directorate_id:  5, name: 'IT', deleted: false},
	{directorate_id:  6, name: 'Shared Services', deleted: false},
	{directorate_id:  6, name: 'MoJ Technology', deleted: false}
	])

deputy_directors = DeputyDirector.create!([
	{division_id: 1, name: 'Craig Watkins', deleted: false},
	{division_id: 2, name: 'Rebecca Endean', deleted: false},
	{division_id: 3, name: 'Procurement', deleted: false},
	{division_id: 4, name: 'Jonathon Sedgwick', deleted: false},
	{division_id: 5, name: 'Helen Judge', deleted: false},
	{division_id: 6, name: 'Paul Kett', deleted: false},
	{division_id: 7, name: 'Ian Poree', deleted: false},
	{division_id: 8, name: 'Darren Tierney', deleted: false},
	{division_id: 9, name: 'Mark Sweeney', deleted: false},
	{division_id: 10, name: 'Vacant', deleted: false},
	{division_id: 11, name: 'Pat Lloyd', deleted: false},
	{division_id: 12, name: 'Pam Teare', deleted: false},
	{division_id: 13, name: 'Carol Carpenter', deleted: false},
	{division_id: 14, name: 'Phil Copple', deleted: false},
	{division_id: 15, name: 'Kevin Sadler', deleted: false},
	{division_id: 16, name: 'Guy Tompkins', deleted: false},
	{division_id: 17, name: 'Paul Shipley', deleted: false},
	{division_id: 18, name: 'Gerry Smith', deleted: false},
	{division_id: 19, name: 'Nick Ramsey', deleted: false}
	])

action_officers = ActionOfficer.create!([
	{deputy_director_id: 17, name: 'Colin Bruce', email: 'colin.bruce@digital.justice.gov.uk', deleted: false},
	{deputy_director_id: 19, name: 'Daniel Penny', email: 'daniel.penny@digital.justice.gov.uk', deleted: false},
	{deputy_director_id: 6, name: 'David Hernandez', email: 'david.hernandez@digital.justice.gov.uk', deleted: false},
	{deputy_director_id: 7, name: 'Tehseen Udin', email: 'tehseen.udin@digital.justice.gov.uk', deleted: false},
	{deputy_director_id: 8, name: 'Tom Wynne-Morgan', email: 'tom.wynne-morgan@digital.justice.gov.uk', deleted: false},
	{deputy_director_id: 9, name: 'Tom Norman', email: 'tom.norman@digital.justice.gov.uk', deleted: false},
	{deputy_director_id: 10, name: 'Mary Henley', email: 'mary.henley@digital.justice.gov.uk', deleted: false}
	])
puts 'Done'
