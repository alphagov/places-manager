Feature: Managing data sets
  In order to provide place data for users
  I want to manage sets of data

  Background:
    Given I am an admin

  Scenario: Creating a new service
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service

    Then I should be on the page for the "Register Offices" service
      And I should see an indication that my data set is awaiting processing

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

    Then I should see an indication that my file wasn't accepted
      And there should still just be one data set

  Scenario: Activating a new data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set

    When I go to the page for the "Register Offices" service
      And I visit the history tab
      And I click "Activate"

    Then I should see that the second data set is active

  Scenario: Duplicating an existing data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set

    When I go to the page for the "Register Offices" service
      And I visit the history tab
      And I click "Duplicate"

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

  Scenario: Creating a new service where the data doesn't import
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service with a bad CSV

    Then I should be on the page for the "Register Offices" service
      And I should see an indication that my data set is awaiting processing

    When background processing has completed
      And I go to the page for the "Register Offices" service

    Then I should see an indication that my file wasn't accepted

  Scenario: Creating a new service with a non-CSV file
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service with a PNG

    Then I should see an indication that my file wasn't accepted
      And there shouldn't be a "Register Offices" service

  Scenario: Creating a new service with a mis-labelled file
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service with a PNG claiming to be a CSV

    Then I should see an indication that my file wasn't accepted
      And there shouldn't be a "Register Offices" service
