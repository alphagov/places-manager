Feature: Managing data sets
  In order to provide place data for users
  I want to manage sets of data

  Background:
    Given I am an admin

  Scenario: Adding another data set to a service
    Given I have previously created the "Register Offices" service

    When I go to the page for the "Register Offices" service
      And I upload a new data set

    Then I should be on the page for the latest data set for the "Register Offices" service
      And I should see that there are now two data sets

  Scenario: Uploading a new data set with a mis-labelled file
    Given I have previously created the "Register Offices" service

    When I go to the page for the "Register Offices" service
      And I upload a new data set with a PNG claiming to be a CSV

    Then I should see an indication that my file was not accepted
      And there should still just be one data set

  Scenario: Activating a new data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set

    When I go to the page for the "Register Offices" service
      And I visit the history tab
      And I activate the most recent data set

    Then I should see that the second data set is active

  Scenario: Duplicating an existing data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set

    When I go to the page for the "Register Offices" service
      And I visit the history tab
      And I duplicate the most recent data set

    Then I should be on the page for the latest data set for the "Register Offices" service
      And I should see that there are now three data sets

  Scenario: Editing an inactive data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set

    When I go to the page for the latest data set for the "Register Offices" service
      And I click "Edit" on a record
      And I update the name to be "Aviation House"

    Then I should be on the page for the latest data set for the "Register Offices" service
      And there should be a place named "Aviation House"

  Scenario: Attempting to edit an active data set
    Given I have previously created the "Register Offices" service

    When I go to the page for the active data set for the "Register Offices" service

    Then I should not see an "edit" action for a record

  Scenario: Attempting to edit an inactive data set which is not the latest version
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set
      And I have uploaded a third data set

    When I go to the page for the second data set for the "Register Offices" service

    Then I should not see an "edit" action for a record

  Scenario: Archiving place information belonging to an obsolete data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set
      And I have uploaded a third data set

    When I go to the page for the "Register Offices" service
      And I visit the history tab
      And I activate the most recent data set
      And I visit the history tab

    Then I should see an indication that the first data set is being archived

    When background processing has completed
      And I go to the page for the "Register Offices" service
      And I visit the history tab

    Then I should not see the first data set

  Scenario: Creating a new data set with a CSV file in the wrong format
    Given I have previously created the "Register Offices" service

    When I go to the page for the "Register Offices" service
      And I upload a new data set with a CSV in the wrong format

    Then I should be on the page for the latest data set for the "Register Offices" service
      And I should see an indication that my data set is awaiting processing

    When background processing has completed
      And I go to the page for the "Register Offices" service

    Then I should see an indication that my data set is empty

  Scenario: Exporting a data set to CSV and uploading it again
    Given I have previously created the "Council tax valuation offices" service

    When I export the latest "Council tax valuation offices" data set to CSV
      And I upload the exported CSV to the "Council tax valuation offices" service

    Then the "Council tax valuation offices" service should have two data sets
      And the places should be identical between the datasets in the "Council tax valuation offices" service

  Scenario: Creating a new data set for a service with local authority lookup with a CSV file with SNAC codes
    Given I have previously created a service with the following attributes:
        | name                | Register Offices |
        | location_match_type | Local authority  |

    When I go to the page for the "Register Offices" service
      And I upload a new data set with a CSV with missing SNAC codes

    When background processing has completed
      And I activate the most recent data set for the "Register Offices" service
      And I go to the page for the "Register Offices" service

    Then I should see that the current service has 2 missing SNAC codes
