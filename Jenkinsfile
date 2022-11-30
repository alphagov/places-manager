#!/usr/bin/env groovy

library("govuk")

node('mongodb-2.4') {
  govuk.buildProject(
    brakeman: true,
    // Run rake default tasks except for pact:verify as that is ran via
    // a separate GitHub action.
    overrideTestTask: { sh("bundle exec rake rubocop cucumber test") }
  )
}
