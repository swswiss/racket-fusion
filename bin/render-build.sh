#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
./bin/rails assets:precompile
./bin/rails assets:clean
bundle exec rails runner 'Blog.delete_all'
bundle exec rails runner 'Match.delete_all'
bundle exec rails runner 'Registration.delete_all'
bundle exec rails runner 'Tournament.delete_all'
bundle exec rails db:migrate
bundle exec rails db:seed