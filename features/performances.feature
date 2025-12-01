Feature: Performance Actions
  Additional coverage for performance controller actions.

  Background:
    Given I am logged in as "alice123"
    And the following events exist:
      | Name | Venue | Date | Time | Style | Location | Price | Description | Tickets |
      | Test Event | Test Venue | 2025-12-01 | 7:30 PM | Hip-hop | Manhattan | $30 | Test | https://test.com |

  Scenario: Viewing liked events page with events
    Given I have liked the event "Test Event"
    When I visit the liked events page
    Then I should see "Test Event" in my liked events list

  Scenario: Sharing event from details page
    Given an existing user with username "bob456" and password "password123"
    And "alice123" and "bob456" are friends
    And I am on the Event Details page for "Test Event"
    When I share the event to "bob456"
    Then I should see "Event shared in message!"

