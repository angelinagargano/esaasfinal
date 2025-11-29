Feature: Home page
  The home page allows users to view and filter events, set preferences, and access event details.

  Background:
    Given the following events exist:
      | Name                                               | Venue               | Date             | Time   | Style         | Location | Price      | Description                     | Tickets                          |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater  | 2025-11-11       | 7:30PM | Hip-hop       | Chelsea  | $32       | Well-known for painting rich tapestries of political, social, and economic history through movement, Rennie Harris weaves a vibrant blend of street and tap dance styles | https://shop.joyce.org/8129/8130 |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater  | 2025-11-12       | 7:30PM | Hip-hop       | Chelsea  | $32       | Well-known for painting rich tapestries of political, social, and economic history through movement, Rennie Harris weaves a vibrant blend of street and tap dance styles | https://shop.joyce.org/8129/8131 |
      | Wim Vandekeybus: Infamous Offspring                | NYU Skirball Center | 2025-11-13       | 7:30PM | Dance Theater | Greenwich Village | $52   | Myth collides with dazzling stagecraft in Wim Vandekeybus' Infamous Offspring, an explosive new dance-theater epic from Ultima Vez | https://tickets.nyu.edu/2026ultimavez/17233 |
      | A Very SW!NG OUT Holiday                          | The Joyce Theater   | 2025-12-09       | 7:30PM | Swing         | Chelsea  | $32   | Oh what fun it is to swing! This winter, director and choreographer Caleb Teicher and their all-star team of collaborators invite you to revel in the joy of social dance and festive cheer | https://shop.joyce.org/8163/8164 |
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

  Scenario: Sorting events by name after filtering
    Given I am on the Home page
    When I fill in "date_filter_start" with "2025-11-11"
    And I fill in "date_filter_end" with "2025-11-13"
    And I click "Apply Filter"
    And I select "Name" from "sort_by"
    And I click "Apply Filter"
    Then events should be sorted by name

  Scenario: Sorting persists in session
    Given I am on the Home page
    When I select "Date" from "sort_by"
    And I click "Apply Filter"
    And I visit the Home page again
    Then events should be sorted chronologically by date

  Scenario: Sorting uses session when parameter missing
    Given I am on the Home page
    When I visit the performances page with sort_by "name" in the URL
    And I visit the Home page again
    Then events should be sorted by name

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
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater | 2025-11-11  | 7:30PM | Hip-hop  | Manhattan | $32  | Well-known for painting rich tapestries of political, social, and economic history through movement, Rennie Harris weaves a vibrant blend of street and tap dance styles   | https://shop.joyce.org/8129/8130  |
      | Invalid Date Event | The Joyce Theater | invalid-date | 7:30PM | Hip-hop | Manhattan | $32 | Well-known for painting rich tapestries of political, social, and economic history through movement, Rennie Harris weaves a vibrant blend of street and tap dance styles | https://shop.joyce.org/8129/8130 |
    And I am on the Home page
    When I select "Date" from "sort_by"
    And I click "Apply Filter"
    Then events should be sorted chronologically by date
    And events with invalid dates should be placed at the end

  Scenario: Date filtering handles events with unparseable dates
    Given the following events exist:
      | Name              | Venue      | Date         | Time   | Style | Location  | Price | Description | Tickets          |
      | Rennie Harris Puremovement American Street Dance Theater       | The Joyce Theater | 2025-11-11   | 7:30PM | Hip-hop  | Manhattan | $32   | Well-known for painting rich tapestries of political, social, and economic history through movement, Rennie Harris weaves a vibrant blend of street and tap dance styles   | https://shop.joyce.org/8129/8130 |
      | Bad Date Event    | The Joyce Theater | not-a-date   | 7:30PM | Hip-hop  | Manhattan | $32   | Well-known for painting rich tapestries of political, social, and economic history through movement, Rennie Harris weaves a vibrant blend of street and tap dance styles | https://shop.joyce.org/8129/8130 |
    And I am on the Home page
    When I fill in "date_filter_start" with "2025-11-01"
    And I fill in "date_filter_end" with "2025-11-30"
    And I click "Apply Filter"
    Then I should see "Rennie Harris Puremovement American Street Dance Theater"
    And I should not see "Bad Date Event"