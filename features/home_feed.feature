Feature: Home page
  The home page allows users to view and filter events, set preferences, and access event details.

  Background:
    Given the following events exist:
      | Name                                               | Venue               | Date             | Time   | Style         | Location | Price      | Description                     | Tickets                          |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater  | 2025-11-11       | 7:30PM | Dance Theater | Chelsea  | $25–$50   | Well-known ...                  | https://shop.joyce.org/8129/8130 |
      | Another Dance Event                                | Some Venue          | 2025-11-12       | 8:00PM | Dance Theater | Downtown | $30–$60   | Another description             | https://example.com/tickets      |
      | Jazz Night                                         | Jazz Club           | 2025-11-13       | 9:00PM | Jazz          | Midtown  | $20–$40   | Smooth jazz evening             | https://example.com/tickets      |
      | For All Your Life                                  | BAM Brooklyn Academy of Music | December 3, 2025 | 7:30 PM | Dance Theater | Brooklyn | $35       | A captivating performance       | https://tickets.bam.org          |


  Scenario: Viewing the default home feed with no preferences
    Given I am on the Home page
    And I have not set any preferences
    Then I should see all events

  Scenario: Viewing a personalized home feed after setting preferences
    Given I can select my preferences
    When I complete the mini quiz with my budget and performance type
    Then I should be taken to the Home page
    And I should see events filtered based on my preferences

  Scenario: Filtering events by a specific date
    Given I am on the Home page
    When I select the date "2025-11-11"
    Then I should see only events on "2025-11-11"
    And I should see 1 event

  Scenario: Filtering events by date range
    Given I am on the Home page
    When I select the date range from "2025-11-11" to "2025-11-13"
    Then I should see only events between "2025-11-11" and "2025-11-13"
    And I should see 3 events

  Scenario: Filtering events by end date only
    Given I am on the Home page
    When I fill in "date_filter_end" with "2025-11-13"
    And I click "Apply Filter"
    Then I should see events on or before "2025-11-13"

  Scenario: User performs a specific search via the filter form
    Given I am logged in
    And the following events exist:
      | Style   | Borough     | Date       |
      | Opera   | Manhattan   | 2026-03-01 |
      | Ballet  | Brooklyn    | 2026-04-15 |
      | Jazz    | Queens      | 2026-05-20 |
    When I am on the Performances page
    
    And I fill in "date_filter_start" with "2026-04-01"
    And I fill in "date_filter_end" with "2026-05-31"
    And I select "Brooklyn" from "borough_filter"
    And I select "Ballet" from "style_filter"
    And I click "Apply Filter"
    
    Then I should only see the event with style "Ballet"
    And I should not see the event with style "Opera"
    And I should not see the event with style "Jazz"
    And I should not see the event with borough "Manhattan"
    And I should not see the event with borough "Queens"

  Scenario: Viewing an event’s details
    Given I am on the Home page
    When I click on an event card
    Then I should be taken to the Event Details page
    And I should see the event name, date, time, location, price, description, and ticket link

  Scenario: Viewing event information on the home feed
    Given I am on the Home page
    And I have not set any preferences
    Then I should see the following details on the event card for "For All Your Life":
      | Date      | December 3, 2025 |
      | Time      | 7:30 PM          |
      | Location  | Brooklyn         |
      | Price     | $35              |

  Scenario: Viewing empty results when no events match filters
    Given I am on the Home page
    When I fill in "date_filter_start" with "2030-01-01"
    And I click "Apply Filter"
    Then I should see "No events matching your preferences"

  Scenario: Sorting events by date
    Given I am on the Home page
    When I select "Date" from "sort_by"
    And I click "Apply Filter"
    Then events should be sorted chronologically by date

  Scenario: Sorting events by other field
    Given I am on the Home page
    When I select "Name" from "sort_by"
    And I click "Apply Filter"
    Then events should be sorted by name

  Scenario: Sorting persists in session
    Given I am on the Home page
    When I select "Date" from "sort_by"
    And I click "Apply Filter"
    And I visit the Home page again
    Then events should be sorted chronologically by date

  Scenario: Budget filter with no matching events results in empty list
    Given I am on the Preferences page
    When I select "$100+" for "Budget"
    And I select "Hip-hop" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see "No events matching your preferences"

  Scenario: Sorting handles events with invalid dates
    Given the following events exist:
      | Name        | Venue      | Date        | Time   | Style | Location | Price | Description | Tickets           |
      | Valid Event | Test Venue | 2025-11-11  | 7:30PM | Jazz  | Manhattan | $30  | Test desc   | https://test.com  |
      | Invalid Date Event | Test Venue | invalid-date | 7:30PM | Jazz | Manhattan | $30 | Test desc | https://test.com |
    And I am on the Home page
    When I select "Date" from "sort_by"
    And I click "Apply Filter"
    Then events should be sorted chronologically by date
    And events with invalid dates should be placed at the end

  Scenario: Budget filtering with numeric price values
    Given the following events exist:
      | Name      | Venue      | Date       | Time   | Style | Location | Price | Description | Tickets          |
      | Numeric Price Event | Test Venue | 2025-11-11 | 7:30PM | Contemporary | Manhattan | 25 | Test desc | https://test.com |
    And I am on the Preferences page
    When I select "$0–$25" for "Budget"
    And I select "Contemporary" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see "Numeric Price Event"
