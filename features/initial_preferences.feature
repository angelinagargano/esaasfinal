Feature: Initial preferences
  New users should be able to set their initial preferences for budget, distance, and performance type before viewing events.

  Background:
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
    And I should see the following options for Distance:
      | Within 2mi   |
      | Within 5mi   |
      | Within 10mi  |
      | No Preference |
    And I should see the following options for Performance Type:
      | Hip-Hop       |
      | Ballet       |
      | Swing          |
      | Contemporary       |
      | Dance Theater |
      | No Preference |

  Scenario: Setting initial preferences
    Given I am on the Preferences page
    When I select "$0–$25" for "Budget"
    And I select "Within 2mi" for "Distance"
    And I select "Ballet" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching "$0–$25" for Budget, "Within 2mi" for Distance, and "Ballet" for Performance Type on the Home feed

  Scenario: Selecting "No Preference" for all categories
    Given I am on the Preferences page
    When I select "No Preference" for "Budget"
    And I select "No Preference" for "Distance"
    And I select "No Preference" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see all available events with no filtering applied

  Scenario: Selecting "No Preference" for one category
    Given I am on the Preferences page
    When I select "$25–$50" for "Budget"
    And I select "Within 5mi" for "Distance"
    And I select "No Preference" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events that match a "$25–$50" budget and "Within 5mi" distance
    And Performance Type should not filter events

  Scenario: Selecting multiple budgets and performance types
    Given I am on the Preferences page
    When I select multiple Budgets: "$0–$25" and "$25–$50"
    And I select multiple Performance Types: "Hip-Hop" and "Contemporary"
    And I select "Within 2mi" for "Distance"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching any selected budget
    And I should see events featuring any selected performance type
    And all events should be within 2 miles

  Scenario: Attempting to save without selecting any preferences
    Given I am on the Preferences page
    When I do not select any options for Budget, Distance, or Performance Type
    And I press "Save Preferences"
    Then I should see an error message: "Please select at least one preference before continuing"
    And I should remain on the Preferences page

  Scenario: Saving without selecting a performance type
    Given I am on the Preferences page
    When I select "$25–$50" for "Budget"
    And I select "Within 5mi" for "Distance"
    And I do not select any options for "Performance Type"
    And I press "Save Preferences"
    Then I should see an alert saying "Please select at least one performance type"
    And I should remain on the Preferences page
