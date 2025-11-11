Feature: User Profile
  Users can view their details, saved events, and upcoming events

  Background:
    Given the user has logged in and created an account

  Scenario: Viewing user information (username, name, email)
    Given I am on the User Profile page
    Then I should see my username, name, and email

  Scenario: Editing user information (username, name, email)
    Given I am on the User Profile page
    When I click "Edit my information"
    And I change Username to "alice777"
    And I press "Save changes"
    Then I should be redirected to the User Profile page

  Scenario: Editing password
    Given I am on the User Profile page
    When I click "Edit my information"
    And I change Password to "password1!"
    And I press "Save changes"
    Then I should be redirected to the User Profile page

  Scenario: Viewing liked events
    Given I am on the User Profile page
    Then I should see a list of my liked events in chronological order

  Scenario: Viewing more details about a liked event
    Given I am on the User Profile page
    And I click on an event card in the liked events list
    Then I should be redirected to the Event Details page for that event

  Scenario: Viewing going to events
    Given I am on the User Profile page
    Then I should see a list of events that I am going to in chronological order

  Scenario: Viewing more details about an event I am attending
    Given I am on the User Profile page
    And I click on an event card in the going to events list
    Then I should be redirected to the Event Details page for that event
