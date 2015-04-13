# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# HEY YOU! YES YOU. This comment is important. Expect `rake db:seed` to be run
# in all environments at random. Along with being run as part of `rake
# db:setup`, it might be run on server restart, on building an environment,
# whenever Jupiter is in aphelion, when the wolf lies with the lamb, etc.
#
# This means anything it runs should be idempotent (i.e. running `rake db:seed`
# multiple times should have the same end result as running it once). See
# `permitted_domains.rb` for an example of this.

$:.unshift(Rails.root.join('db', 'seeds'))

require 'permitted_domains'
