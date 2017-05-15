namespace :peoplefinder do
  namespace :s3 do

    desc 'apply private canned-acl to all images'
    task :privatise_images => :environment do
      bucket = S3::Bucket.new
      puts "<<<<<<<<<< Accessing #{bucket.name} >>>>>>>>>>>>>>>>>>"
      bucket.profile_images.each do |image|
        print '.'
        image.private!
        puts "FAILURE: #{image.key} is public" if image.public_read?
      end
    end

    desc 'apply public-read canned-acl to all images'
    task :publicise_images => :environment do
      bucket = S3::Bucket.new
      puts "<<<<<<<<<< Accessing #{bucket.name} >>>>>>>>>>>>>>>>>>"
      bucket.profile_images.each do |image|
        print '.'
        image.public_read!
        puts "FAILURE: #{image.key} is private" if image.private?
      end
    end

  end
end
