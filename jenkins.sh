#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:drop
bundle exec rake ci:setup:minitest default
