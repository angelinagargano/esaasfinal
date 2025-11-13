Feature: New Performance Page
  As a user
  I want to access the new performance page
  So that I can view the page (if needed in the future)

  Background:
    Given I am logged in

  Scenario: Visiting the new performance page
    When I visit the new performance page
    Then I should be on the new performance page

