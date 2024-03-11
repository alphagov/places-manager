Feature: Service Permissions
  In order to ensure services can only be accessed by relevant editors
  I want to see only my department's services

  Scenario: Viewing My Department's Services
    Given I am an editor
    Given test-department exists
    Given a test-department editor has previously created the "Register Offices" service

    When I go to the service list page

    Then I should be able to see the Register Offices service

  Scenario: Viewing Other Department's Services
    Given I am an editor
    Given test-department exists
    Given an other-department editor has previously created the "Register Offices" service

    When I go to the service list page

    Then I should not be able to see the Register Offices service


  Scenario: Viewing Services
    Given I am a GDS editor
    Given an other-department editor has previously created the "Register Offices" service

    When I go to the service list page

    Then I should be able to see the Register Offices service
