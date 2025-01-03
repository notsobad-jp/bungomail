# syntax=docker/dockerfile:1
FROM ruby:3.4.1
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client vim
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
ENV BUNDLER_VERSION=2.4.12
RUN gem install bundler --no-document -v 2.4.12
RUN bundle install
