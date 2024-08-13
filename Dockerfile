# syntax=docker/dockerfile:1
FROM ruby:3.3.0
RUN apt-get update -qq && apt-get install -y nodejs vim
WORKDIR /api_sample
COPY Gemfile /api_sample/Gemfile
COPY Gemfile.lock /api_sample/Gemfile.lock
RUN bundle install

EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
