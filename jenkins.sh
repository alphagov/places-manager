#!/bin/bash -x
source '/usr/local/lib/rvm'
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment
bundle exec rake db:setup
bundle exec rake db:migrate
bundle exec rake stats
export DISPLAY=:99
bundle exec rake ci:setup:testunit test:units test:functionals test:integration 
RESULT=$?
exit $RESULT
