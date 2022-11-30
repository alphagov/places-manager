#!/usr/bin/env groovy

library("govuk")

node('mongodb-2.4') {
  govuk.buildProject(
    brakeman: true,
    overrideTestTask: { sh("bundle exec rake rubocop cucumber test") }
  )
}
