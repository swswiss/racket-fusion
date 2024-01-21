#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
chmod +x ./bin/rails
./bin/rails assets:precompile
./bin/rails assets:clean