task :brakeman do
  system <<-SCRIPT
    echo "Running brakeman..."
    (brakeman --no-progress --quiet --output tmp/brakeman.out --exit-on-warn > /dev/null && \
    echo "No warnings or errors - see tmp/brakeman.out") || \
    (cat tmp/brakeman.out; exit 1)
  SCRIPT
end

if %w[development test].include? Rails.env
  task(:default).prerequisites << task(:brakeman)
end
