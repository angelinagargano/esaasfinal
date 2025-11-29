Feature: Initial preferences
  New users should be able to set their initial preferences for budget, distance, and performance type before viewing events.

  Background:
    Given the following events exist:
      | Name                                               | Venue               | Date       | Time   | Style         | Location  | Price    | Description                     | Tickets                           |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater  | 2025-11-11 | 7:30PM | Dance Theater | Chelsea   | $25–$50 | Well-known ...                  | https://shop.joyce.org/8129/8130  |
      | Wim Vandekeybus: Infamous Offspring                | NYU Skirball Center | 2025-11-13 | 7:30PM | Dance Theater | Greenwich Village | $52 | Myth collides with dazzling stagecraft in Wim Vandekeybus' Infamous Offspring, an explosive new dance-theater epic from Ultima Vez | https://tickets.nyu.edu/2026ultimavez/17233 |
      | A Very SW!NG OUT Holiday                          | The Joyce Theater   | 2025-12-09 | 7:30PM | Swing         | Chelsea   | $32 | Oh what fun it is to swing! This winter, director and choreographer Caleb Teicher and their all-star team of collaborators invite you to revel in the joy of social dance and festive cheer | https://shop.joyce.org/8163/8164 |
      | For All Your Life                                  | BAM Brooklyn Academy of Music | 2025-12-03 | 7:30PM | Contemporary | Fort Greene | $35 | For All Your Life is a performance, film, and social experiment that investigates the value of Black life and death, drawing on the life insurance industry for method and metaphor | https://tickets.bam.org/reserve/index.aspx?performanceNumber=48459&DisableSmartSeat=true |
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

  Scenario: Selecting "No Preference" with other options removes "No Preference"
    Given I am on the Preferences page
    When I select "$0–$25" for "Budget"
    And I select "No Preference" for "Budget"
    And I select "Ballet" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching "$0–$25" for Budget and "Ballet" for Performance Type on the Home feed

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

  Scenario: Filtering by $25–$50 budget range
    Given the following events exist:
      | Name      | Venue      | Date       | Time   | Style | Location | Price | Description | Tickets          |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater | 2025-11-11 | 7:30PM | Hip-hop | Manhattan | $32 | Well-known for painting rich tapestries of political, social, and economic history through movement, Rennie Harris weaves a vibrant blend of street and tap dance styles | https://shop.joyce.org/8129/8130 |
    And I am on the Preferences page
    When I select "$25–$50" for "Budget"
    And I select "Hip-hop" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching "$25–$50" for Budget and "Hip-hop" for Performance Type on the Home feed

  Scenario: Filtering by $50–$100 budget range
    Given the following events exist:
      | Name      | Venue      | Date       | Time   | Style | Location | Price | Description | Tickets          |
      | Wim Vandekeybus: Infamous Offspring | NYU Skirball Center | 2025-11-13 | 7:30PM | Dance Theater | Manhattan | $52 | Myth collides with dazzling stagecraft in Wim Vandekeybus' Infamous Offspring, an explosive new dance-theater epic from Ultima Vez | https://tickets.nyu.edu/2026ultimavez/17233 |
    And I am on the Preferences page
    When I select "$50–$100" for "Budget"
    And I select "Dance Theater" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching "$50–$100" for Budget and "Dance Theater" for Performance Type on the Home feed

  Scenario: Filtering by $100+ budget range
    Given the following events exist:
      | Name      | Venue      | Date       | Time   | Style | Location | Price | Description | Tickets          |
      | Masters At Work II | New York City Ballet | 2026-01-23 | 7:30PM | Ballet | Manhattan | $54 | Three contrasting Balanchine works are joined by the return of a lyrical Jerome Robbins ballet | https://tickets.nycballet.com/syos/performance/9077 |
    And I am on the Preferences page
    When I select "$100+" for "Budget"
    And I select "Ballet" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see events matching "$100+" for Budget and "Ballet" for Performance Type on the Home feed

  Scenario: Submitting preferences with empty borough defaults to No Preference
    Given I am on the Preferences page
    When I select "$0–$25" for "Budget"
    And I select "Ballet" for "Performance Type"
    And I submit preferences with empty borough
    Then I should be redirected to the Home page