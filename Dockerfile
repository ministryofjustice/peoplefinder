FROM ruby:2.7.2-alpine

# Note: .ruby-gemdeps libc-dev gcc libxml2-dev libxslt-dev make postgresql-dev build-base curl-dev with bundle install issues. 
RUN apk add --no-cache --virtual .ruby-gemdeps libc-dev gcc libxml2-dev libxslt-dev make postgresql-dev build-base curl-dev git nodejs zip postgresql-client runit imagemagick ffmpeg graphicsmagick

# set WORKDIR
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

RUN apk -U upgrade

# https://github.com/ministryofjustice/docker-templates/issues/37
# UTF 8 issue during bundle install
ENV LC_ALL C.UTF-8
ENV APPUSER moj
ENV PUMA_PORT 3000

COPY Gemfile* ./
RUN gem install bundler -v 2.2.14
RUN bundle config --global frozen 1 && \
    bundle config --path=vendor/bundle && \
    bundle config --global without test:development && \
    bundle install

RUN addgroup --gid 1000 --system appgroup && \
    adduser --uid 1000 --system appuser --ingroup appgroup

COPY . .

RUN RAILS_ENV=production GOVUK_APP_DOMAIN=not_real GOVUK_WEBSITE_ROOT=not_real SUPPORT_EMAIL=not_real bundle exec rake assets:clean assets:precompile SECRET_KEY_BASE=required_but_does_not_matter_for_assets 2> /dev/null

# RUN mkdir log tmp
RUN chown -R appuser:appgroup /usr/src/app/
USER appuser
USER 1000

RUN chown -R appuser:appgroup ./*
RUN chmod +x /usr/src/app/config/docker/*

EXPOSE $PUMA_PORT

# expect/add ping environment variables
ARG VERSION_NUMBER
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ENV VERSION_NUMBER=${VERSION_NUMBER}
ENV COMMIT_ID=${COMMIT_ID}
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_TAG=${BUILD_TAG}
