# syntax=docker/dockerfile:1
FROM ruby:2.7.0
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle config set force_ruby_platform true
RUN bundle install
