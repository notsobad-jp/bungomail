# syntax=docker/dockerfile:1
FROM ruby:3.0.4
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client vim
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
