Feature: Initial preferences
  New users should be able to set their initial preferences for budget, distance, and performance type before viewing events.

  Background:
    Given the following events exist:
      | Name                                               | Venue               | Date       | Time   | Style         | Location  | Price    | Description                     | Tickets                           |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater  | 2025-11-11 | 7:30PM | Dance Theater | Chelsea   | $25–$50 | Well-known ...                  | https://shop.joyce.org/8129/8130  |
      | Another Dance Event                                | Some Venue          | 2025-11-12 | 8:00PM | Dance Theater | Downtown  | $30–$60 | Another description             | https://example.com/tickets       |
      | Jazz Night                                         | Jazz Club           | 2025-11-13 | 9:00PM | Jazz          | Midtown   | $20–$40 | Smooth jazz evening             | https://example.com/jazznight     |
      | Ballet in Brooklyn                                 | Brooklyn Theater    | 2025-12-03 | 7:30PM | Ballet        | Brooklyn  | $0–$25  | A local ballet performance near you | https://example.com/balletbrooklyn |
    Given I have opened the app for the first time
    Then I should be taken to the Preferences page

  Scenario: Viewing available preference options
    Given I am on the Preferences page
    Then I should see the following options for Budget:
      | $0–$25       |
      | $25–$50      |
      | $50–$100     |
      | $100+        |
      | No Preference |
    And I should see the following options for Performance Type:
      | Hip-hop       |
      | Ballet       |
      | Swing          |
      | Contemporary       |
      | Dance Theater |
      | No Preference |

  Scenario: Setting initial preferences
    Given I am on the Preferences page
    When I select "$0–$25" for "Budget"
    And I select "Ballet" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching "$0–$25" for Budget and "Ballet" for Performance Type on the Home feed

  Scenario: Selecting "No Preference" for all categories
    Given I am on the Preferences page
    When I select "No Preference" for "Budget"
    And I select "No Preference" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see all available events with no filtering applied

  Scenario: Selecting "No Preference" for one category
    Given I am on the Preferences page
    When I select "$0–$25" for "Budget"
    And I select "No Preference" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events that match a "$0–$25" budget
    And Performance Type should not filter events

  Scenario: Selecting multiple budgets and performance types
    Given I am on the Preferences page
    When I select multiple Budgets: "$0–$25" and "$25–$50"
    And I select multiple Performance Types: "Hip-hop" and "Contemporary"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching any selected budget
    And I should see events featuring any selected performance type

  Scenario: Attempting to save without selecting any preferences
    Given I am on the Preferences page
    When I do not select any options for Budget or Performance Type
    And I press "Save Preferences"
    Then I should see an error message: "Please select at least one preference before continuing"
    And I should remain on the Preferences page

  Scenario: Saving without selecting a performance type
    Given I am on the Preferences page
    When I select "$0–$25" for "Budget"
    And I do not select any options for "Performance Type"
    And I press "Save Preferences"
    Then I should see an alert saying "Please select at least one performance type"
    And I should remain on the Preferences page
