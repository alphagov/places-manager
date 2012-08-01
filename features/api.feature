Feature: Managing data sets
  In order to provide place data for users
  I want to manage sets of data

  Background:
    Given I have previously created the "Register Offices" service

  Scenario: Exporting a data set in full
    When I request the JSON for "Register Offices" without any parameters
    Then I should receive JSON with 174 data points

  Scenario: Retrieving the two nearest points in a data set
    When I request the 2 "Register Offices" points nearest to 51.501009611553926,-0.141587067110009
    Then I should receive JSON with 2 data points

  Scenario: Exporting a version of a data set
    Given I am an admin
      And I have uploaded a second data set
    When I request the JSON for "Register Offices" version 2
    Then I should receive JSON with 174 data points
