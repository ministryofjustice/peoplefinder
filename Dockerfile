FROM ministryofjustice/ruby:2-webapp-onbuild

ENV UNICORN_PORT 3000

EXPOSE $UNICORN_PORT

#CMD ./run.sh
ENTRYPOINT ["./run.sh"]
