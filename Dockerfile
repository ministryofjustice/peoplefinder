FROM ruby:3.2.2-alpine as base

WORKDIR /app

RUN apk add --no-cache \
    postgresql-client \
    nodejs \
    git

# Ensure latest rubygems is installed
RUN gem update --system

FROM base as builder

RUN apk add --no-cache \
    build-base \
    ruby-dev \
    postgresql-dev \
    imagemagick \
    ffmpeg \
    graphicsmagick

COPY Gemfile* .ruby-version ./

RUN bundle config deployment true && \
    bundle config without development test && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 GOVUK_APP_DOMAIN=not_real \
    GOVUK_WEBSITE_ROOT=not_real SUPPORT_EMAIL=not_real \
    bundle exec rake assets:precompile

# Cleanup to save space in the production image
RUN rm -rf node_modules log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache

FROM base

# Add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# Copy files generated in the builder image
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Create log and tmp
RUN mkdir -p log tmp
RUN chown -R appuser:appgroup ./*

# Set user
USER 1000

# expect/add ping environment variables
ARG APP_GIT_COMMIT
ARG APP_BUILD_DATE
ARG APP_BUILD_TAG
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}
ENV APP_BUILD_DATE=${APP_BUILD_DATE}
ENV APP_BUILD_TAG=${APP_BUILD_TAG}
