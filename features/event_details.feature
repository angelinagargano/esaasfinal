Feature: View event details page
  Users should be able to view more detailed information about events and navigate to the ticket purchase page.

  Background:
    Given the following events exist:
      | Name                                                | Venue             | Date             | Time    | Style   | Location | Price | Description                                                                                                                              | Tickets                                    |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater | November 11, 2025 | 7:30 PM | Hip-hop | Chelsea  | $32  | Well-known for painting rich tapestries of political, philosophical, and spiritual ideas, Rennie Harris returns with American Street Dance Theater, blending hip-hop and storytelling. | https://shop.joyce.org/8129/8130 |
      | For All Your Life                                   | BAM Brooklyn Academy of Music | December 3, 2025 | 7:30 PM | Modern  | Brooklyn | $35  | A contemporary dance showcase blending live music and emotional storytelling. | https://bam.org/forallyourlife |
      | A Very SW!NG OUT Holiday                            | Joyce Theater      | December 17, 2025 | 8:00 PM | Tap     | Manhattan | $40  | A tap dance celebration of the holiday season featuring live jazz music. | https://shop.joyce.org/holidaytap |
      | Ogemdi Ude: MAJOR                                   | New York Live Arts    | January 7, 2026 | 7:30 PM | Dance Theater | Chelsea | $28 | MAJOR is a dance theater project exploring the physicality, history, sociopolitics, and interiority of majorette dance, a form that originated in the American South within Historically Black Colleges and Universities in the 1960s. These Black femme teams accompanied by marching bands created a movement style that requires master showmanship with allegiance to count, undulation, groove, and sensual yet strong performativity. In MAJOR, six Black femmes embrace majorette form – a fundamental relic of Black girlhood – to pursue the intimate journey of returning to bodies they thought lost. Experiments in improvised and verbatim language intertwine with a music score that integrates Southern rap, horns, drumlines, and melodic R&B and soul by Lambkin. The Chord Archive is showcased alongside performances, a physical and digital documentation of the creative process and personal historical accounts from former majorette dancers. A fierce investigation of physical memory, sexuality, sensuality, and community, MAJOR is a nuanced love letter to the folks who taught the team how to be proudly Black and proudly femme. | https://newyorklivearts.my.salesforce-sites.com/ticket/#/instances/a0FVt00000DafLXMAZ |

    And I am on the Home page
    Then at least 3 events should exist

  Scenario: Viewing more details about an event
    Given "Rennie Harris Puremovement American Street Dance Theater" exists
    When I click on its event card "Rennie Harris"
    Then I should be on its Event Details page
    And I should see:
      | Venue       | The Joyce Theater |
      | Date        | November 11, 2025 |
      | Time        | 7:30 PM |
      | Style       | Hip-hop |
      | Location    | Chelsea |
      | Price       | $32 |
      | Description | Well-known for painting rich tapestries of political, philosophical, and spiritual ideas, Rennie Harris returns with American Street Dance Theater, blending hip-hop and storytelling. |
    And I should see a "Purchase Tickets" link leading to "https://shop.joyce.org/8129/8130"

  Scenario: Navigating to the ticket purchase page
    Given I am on the Event Details page for "Rennie Harris Puremovement American Street Dance Theater"
    Then I should see the Purchase Tickets link
    When I click the Purchase Tickets link
    Then I should see a message: "You have viewed tickets for Rennie Harris Puremovement American Street Dance Theater"
  And the Purchase Tickets link should go to "https://shop.joyce.org/8129/8130"
