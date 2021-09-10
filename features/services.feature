Feature: Managing services
  In order to provide place data for users
  I want to manage services

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

    When I visit the history tab

    Then the first version panel has the title "Version 1"

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

  Scenario: Creating a new service with local authority lookup with a file with missing snac codes
    When I go to the new service page
      And I fill out the form with the following attributes to create a service:
        | name                | Register Offices With Missing Snac Codes |
        | location_match_type | Local authority                          |
      Then I should be on the page for the "Register Offices With Missing Snac Codes" service

    When background processing has completed
      And I go to the page for the "Register Offices With Missing Snac Codes" service

    Then I should see that the current service has 2 missing SNAC codes

    When I visit the history tab

    Then the first version panel has the title "Version 1"
      And the first version panel has the text "2 places with missing SNAC codes"
      And the first version panel shows a warning about missing SNAC codes

  Scenario: Creating a new service with nearest lookup with a file with missing snac codes
    When I go to the new service page
      And I fill out the form with the following attributes to create a service:
        | name                | Register Offices With Missing Snac Codes |
        | location_match_type | Nearest                                  |

    When background processing has completed
      And I go to the page for the "Register Offices With Missing Snac Codes" service

    Then I should not see any text about missing SNAC codes
