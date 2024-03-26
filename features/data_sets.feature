Feature: Managing data sets
  In order to provide place data for users
  I want to manage sets of data

  Background:
    Given I am an editor
    Given there are no frontend pages

  Scenario: Adding another data set to a service
    Given I have previously created the "Register Offices" service

    When I go to the page for the "Register Offices" service
      And I click on "Upload new dataset"
      And I upload a new data set

    Then I should be on the page for the latest data set for the "Register Offices" service
      And I should see that there are now 2 data sets

    When I go to the page for the "Register Offices" service
      And I click on "Datasets"
      And I should see 2 versions in the list

  Scenario: Uploading a new data set with a mis-labelled file
    Given I have previously created the "Register Offices" service

    When I go to the page for the "Register Offices" service
      And I click on "Upload new dataset"
      And I upload a new data set with a PNG claiming to be a CSV

    Then I should see an indication that my file was not accepted
      And there should still just be one data set

  Scenario: Activating a new data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set

    When I go to the page for the "Register Offices" service
      And I click on "Datasets"
      And I view the most recent data set
      And I make it active

    Then I should see that the second data set is active

  Scenario: Archiving place information belonging to an obsolete data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set
      And I have uploaded a third data set

    When I go to the page for the "Register Offices" service
      And I click on "Datasets"
      And I view the most recent data set
      And I make it active
      And I go to the page for the "Register Offices" service
      And I click on "Datasets"

    Then I should see an indication that the first data set is being archived

    When background processing has completed
      And I go to the page for the "Register Offices" service
      And I click on "Datasets"

    Then I should not see the first data set

  Scenario: Creating a new data set with a CSV file in the wrong format
    Given I have previously created the "Register Offices" service

    When I go to the page for the "Register Offices" service
      And I click on "Upload new dataset"
      And I upload a new data set with a CSV in the wrong format

    Then I should be on the page for the latest data set for the "Register Offices" service
      And I should see an indication that my data set is awaiting processing

    When background processing has completed
      And I reload the page

    Then I should see an indication that my data set is empty
      And I should see an indication that there was an import problem

  Scenario: Exporting a data set to CSV and uploading it again
    Given I have previously created the "Council tax valuation offices" service

    When I export the latest "Council tax valuation offices" data set to CSV
      And I upload the exported CSV to the "Council tax valuation offices" service

    Then the "Council tax valuation offices" service should have two data sets
      And the places should be identical between the datasets in the "Council tax valuation offices" service

  Scenario: Creating a new data set for a service with local authority lookup with a CSV file with GSS codes
    Given I have previously created a service with the following attributes:
        | name                | Register Offices |
        | location_match_type | Local authority  |

    When I go to the page for the "Register Offices" service
      And I click on "Upload new dataset"
      And I upload a new data set with a CSV with missing GSS codes

    When background processing has completed
      And I go to the page for the "Register Offices" service
      And I click on "Datasets"
      And I view the most recent data set
      And I make it active

    Then I should see that the current service has 2 missing GSS codes
