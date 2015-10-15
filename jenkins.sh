#!/bin/bash -x

# This removes rbenv shims from the PATH where there is no
# .ruby-version file. This is because certain gems call their
# respective tasks with ruby -S which causes the following error to
# appear: ruby: no Ruby script found in input (LoadError).
if [ ! -f .ruby-version ]; then
  export PATH=$(printf $PATH | awk 'BEGIN { RS=":"; ORS=":" } !/rbenv/' | sed 's/:$//')
fi

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:drop
# We only need one of the minitest or testunit setup tasks, but we'll fix it
# when we jump to rails 4.x and decide which one it is
bundle exec rake ci:setup:minitest ci:setup:testunit default
