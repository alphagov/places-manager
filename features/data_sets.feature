Feature: Managing data sets
  In order to provide place data for users
  I want to manage sets of data

  Background:
    Given I am an admin

  Scenario: Creating a new service
    When I go to the new service page
      And I fill in the form to create the "Register Offices" service

    Then I should be on the page for the "Register Offices" service
      And I should see an indication that my data set contained 174 items

  @wip
  Scenario: Adding another data set to a service
    Given I have previously created the "Register Offices" service
    When I go to the page for the "Register Offices" service
      And I upload a new data set

    Then I should be on the page for the "Register Offices" service
      And I should see that there are now two data sets

  @wip
  Scenario: Activating a new data set
    Given I have previously created the "Register Offices" service
      And I have uploaded a second data set

  