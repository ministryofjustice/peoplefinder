# watch local config changes
# Spring.watch '.env.local'
%w(
  .ruby-version
  .rbenv-vars
  .env.local
  tmp/restart.txt
  tmp/caching-dev.txt
).each { |path| Spring.watch(path) }
