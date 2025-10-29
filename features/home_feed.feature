Feature: Home page
  The home page allows users to view and filter events, set preferences, and access event details.

  Background:
    Given the following events exist:
      | Name                                               | Venue               | Date       | Time   | Style         | Location | Price      | Description                     | Tickets                   |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater  | 2025-11-11 | 7:30PM | Dance Theater | Chelsea  | $25–$50   | Well-known ...                  | https://shop.joyce.org/8129/8130 |
      | Another Dance Event                                | Some Venue          | 2025-11-12 | 8:00PM | Dance Theater | Downtown | $30–$60   | Another description             | https://example.com/tickets |
      | Jazz Night                                         | Jazz Club           | 2025-11-13 | 9:00PM | Jazz          | Midtown  | $20–$40   | Smooth jazz evening             | https://example.com/tickets |


  Scenario: Viewing the default home feed with no preferences
    Given I am on the Home page
    And I have not set any preferences
    Then I should see all events

  Scenario: Viewing a personalized home feed after setting preferences
    Given I can select my preferences
    When I complete the mini quiz with my budget and performance type
    And I select my preferences: Price "$25", Style "Dance Theater"
    Then I should be taken to the Home page
    And I should see events filtered based on my preferences

  Scenario: Filtering events by date
    Given I am on the Home page
    When I select a specific date or date range
    Then I should see only events within that range

  Scenario: Viewing an event’s details
    Given I am on the Home page
    When I click on an event card
    Then I should be taken to the Event Details page
    And I should see the event name, date, time, location, price, description, and ticket link

  Scenario: Viewing event information on the home feed
    Given "For All Your Life" exists
    Then I should see the following details on its event card:
      | Date      | December 3, 2025                    |
      | Time      | 7:30 PM                             |
      | Location  | BAM Brooklyn Academy of Music      |
      | Price     | $35                                 |
