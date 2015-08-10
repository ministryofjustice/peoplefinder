FROM ministryofjustice/ruby:2-webapp-onbuild

ENV UNICORN_PORT 3000

EXPOSE $UNICORN_PORT

RUN bundle exec rake assets:precompile RAILS_ENV=assets

ENTRYPOINT ["./run.sh"]
