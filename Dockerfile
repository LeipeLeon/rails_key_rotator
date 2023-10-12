FROM ruby:3.2

RUN apt-get update && apt-get install -y \
  vim

ENV APP_HOME /app

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=8

ARG BUNDLER_VERSION=2.4.20
RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

WORKDIR $APP_HOME
