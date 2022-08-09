#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("TEST_DATABASE_URL", "postgis://postgres@127.0.0.1:54414/imminence-test")
  govuk.buildProject(
    brakeman: true,
    // Run rake default tasks except for pact:verify as that is ran via
    // a separate GitHub action.
    overrideTestTask: { sh("bundle exec rake rubocop cucumber test") }
  )
}
