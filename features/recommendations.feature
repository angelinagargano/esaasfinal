Feature: Event Recommendations
  As a logged-in user
  I want to see event recommendations based on my liked and going events
  So that I can discover new events that match my interests

  Background:
    Given the following users exist:
      | name          | email                | username  | password   |
      | Alice Johnson | alice@example.com    | alice123  | password123|
      | Bob Smith     | bob@example.com      | bob456    | password123|

    And the following events exist:
      | Name                                                      | Venue                          | Date              | Time    | Style         | Location      | Borough   | Price | Description                        | Tickets                     |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater              | November 11, 2025 | 7:30 PM | Hip-hop       | Chelsea       | Manhattan | $32   | Hip-hop dance performance          | https://shop.joyce.org/test |
      | For All Your Life                                         | BAM Brooklyn Academy of Music  | December 3, 2025  | 7:30 PM | Contemporary  | Fort Greene   | Brooklyn  | $35   | Contemporary dance showcase        | https://bam.org/test        |
      | A Very SW!NG OUT Holiday                                  | The Joyce Theater              | December 17, 2025 | 8:00 PM | Swing         | Chelsea       | Manhattan | $40   | Holiday swing dance celebration    | https://shop.joyce.org/test |
      | Ogemdi Ude: MAJOR                                         | New York Live Arts             | January 7, 2026   | 7:30 PM | Dance Theater | Chelsea       | Manhattan | $28   | Dance theater exploring majorettes | https://newyorklivearts.com |
      | Masters At Work II                                        | New York City Ballet           | January 23, 2026  | 7:30 PM | Ballet        | Lincoln Square| Manhattan | $54   | Ballet performance                 | https://nycballet.com       |
      | New Chamber Ballet: Azalea                                | Mark Morris Dance Group        | November 21, 2025 | 7:30 PM | Ballet        | Fort Greene   | Brooklyn  | $47   | Chamber ballet performance         | https://eventbrite.com      |
      | Momix: Alice                                              | The Joyce Theater              | December 16, 2025 | 7:30 PM | Acrobatic     | Chelsea       | Manhattan | $32   | Acrobatic dance theater            | https://shop.joyce.org/test |
      | No Excuses, No Limits                                     | The New Victory Theater        | March 7, 2026     | 12:00 PM| Hip-hop       | Times Square  | Manhattan | $25   | B-boy breaking performance         | https://newvictory.org      |

  Scenario: User sees recommendations based on liked events
    Given I am logged in as "alice123" with password "password123"
    And I have liked the event "A Very SW!NG OUT Holiday"
    And I have liked the event "For All Your Life"
    When I am on the performances page
    Then I should see "Recommended For You"
    And I should see "Based on events you've liked and plan to attend"
    And I should see recommended events with matching styles or locations
    And I should not see "A Very SW!NG OUT Holiday" in the recommendations
    And I should not see "For All Your Life" in the recommendations

  Scenario: User sees recommendations based on going events
    Given I am logged in as "alice123" with password "password123"
    And I am going to the event "Ogemdi Ude: MAJOR"
    When I am on the performances page
    Then I should see "Recommended For You"
    And I should see recommended events

  Scenario: User sees recommendations based on both liked and going events
    Given I am logged in as "alice123" with password "password123"
    And I have liked the event "A Very SW!NG OUT Holiday"
    And I am going to the event "Rennie Harris Puremovement American Street Dance Theater"
    When I am on the performances page
    Then I should see "Recommended For You"
    And the recommendations should include events matching "Swing" or "Hip-hop" or "Manhattan"

  Scenario: User with no liked or going events sees no recommendations
    Given I am logged in as "bob456" with password "password123"
    When I am on the performances page
    Then I should not see "Recommended For You"

  Scenario: Guest user does not see recommendations
    Given I am on the performances page
    Then I should not see "Recommended For You"

  Scenario: User can refresh recommendations to see different events
    Given I am logged in as "alice123" with password "password123"
    And I have liked the event "Ogemdi Ude: MAJOR"
    And I have liked the event "For All Your Life"
    When I am on the performances page
    Then I should see "Recommended For You"
    And I should see "Refresh Recommendations"
    When I follow "Refresh Recommendations"
    Then I should see "Recommended For You"
    And I should see different recommended events

  Scenario: Recommendations show correct event details
    Given I am logged in as "alice123" with password "password123"
    And I have liked the event "For All Your Life"
    When I am on the performances page
    Then I should see "Recommended For You"
    And the recommended events should display:
      | field    |
      | Date     |
      | Time     |
      | Location |
      | Borough  |
      | Venue    |
      | Price    |

  Scenario: Recommendations are limited to 3 events
    Given I am logged in as "alice123" with password "password123"
    And I have liked the event "A Very SW!NG OUT Holiday"
    When I am on the performances page
    Then I should see at most 3 recommended events

  Scenario: Recommendations match multiple criteria
    Given I am logged in as "alice123" with password "password123"
    And I have liked the event "A Very SW!NG OUT Holiday"
    When I am on the performances page
    Then recommended events should match "Swing" style or "Manhattan" borough