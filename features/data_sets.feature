Feature: Managing data sets
  In order to provide place data for users
  I want to manage sets of data

  Background:
    Given I am an admin

  Scenario: Creating a new service
    When I go to the new service page
      And I fill out the form with the following attributes to create a service:
        | name                                 | Register Offices         |
        | slug                                 | all-new-register-offices |
        | source_of_data                       | Testing source of data   |
        | location_match_type                  | Local authority          |
        | local_authority_hierarchy_match_type | County                   |

    Then I should be on the page for the "Register Offices" service
      And I should see an indication that my data set is awaiting processing

    When I visit the details tab
    Then I should see the "Name" field filled with "Register Offices"
      And I should see the "Slug" field filled with "all-new-register-offices"
      And I should see the "Source of data" field filled with "Testing source of data"
      And I should see the "Location match type" select field set to "Local authority"
      And I should see the "Local authority hierarchy match type" select field set to "County"

    When background processing has completed
      And I go to the page for the "Register Offices" service

    Then I should see an indication that my data set contained 174 items

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

  Scenario: Creating a new service where the data doesn't import
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service with a bad CSV

    Then I should be on the page for the "Register Offices" service
      And I should see an indication that my data set is awaiting processing

    When background processing has completed
      And I go to the page for the "Register Offices" service

    Then I should see an indication that my file was not accepted

  Scenario: Creating a new service with a non-CSV file
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service with a PNG

    Then I should see an indication that my file was not accepted
      And there should not be a "Register Offices" service

  Scenario: Creating a new service with a mis-labelled file
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service with a PNG claiming to be a CSV

    Then I should see an indication that my file was not accepted
      And there should not be a "Register Offices" service

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
