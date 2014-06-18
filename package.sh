
VERSION=`echo "$1" | sed -e "s/.*release\///g"`

# Generate a self contained bundle
#cd build
bundle --quiet \
       --path vendor/bundle \
       --deployment \
       --standalone \
       --binstubs \
       --without build


bundle exec rake assets:precompile RAILS_ENV=production

# Notify hipchat in Jenkins

echo "Building Assets Container ($VERSION)"
./docker/assets/make.sh $VERSION

echo "Building Rails Container ($VERSION)"
./docker/rails/make.sh $VERSION

