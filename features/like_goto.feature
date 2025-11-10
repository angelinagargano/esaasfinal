Feature: Interacting with events 
    As a user 
    I want to like and dislike events and mark them as going 
    So I can save my favourites and add them to my calender 
    
  Background:
    Given the following events exist:
      | Name                                                | Venue             | Date             | Time    | Style   | Location | Price | Description                                                                                                                              | Tickets                                    |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater | November 11, 2025 | 7:30 PM | Hip-hop | Chelsea  | $32  | Well-known for painting rich tapestries of political, philosophical, and spiritual ideas, Rennie Harris returns with American Street Dance Theater, blending hip-hop and storytelling. | https://shop.joyce.org/8129/8130 |
      | For All Your Life                                   | BAM Brooklyn Academy of Music | December 3, 2025 | 7:30 PM | Modern  | Brooklyn | $35  | A contemporary dance showcase blending live music and emotional storytelling. | https://bam.org/forallyourlife |
      | A Very SW!NG OUT Holiday                            | Joyce Theater      | December 17, 2025 | 8:00 PM | Tap     | Manhattan | $40  | A tap dance celebration of the holiday season featuring live jazz music. | https://shop.joyce.org/holidaytap |
      | Ogemdi Ude: MAJOR                                   | New York Live Arts    | January 7, 2026 | 7:30 PM | Dance Theater | Chelsea | $28 | MAJOR is a dance theater project exploring the physicality, history, sociopolitics, and interiority of majorette dance, a form that originated in the American South within Historically Black Colleges and Universities in the 1960s. These Black femme teams accompanied by marching bands created a movement style that requires master showmanship with allegiance to count, undulation, groove, and sensual yet strong performativity. In MAJOR, six Black femmes embrace majorette form – a fundamental relic of Black girlhood – to pursue the intimate journey of returning to bodies they thought lost. Experiments in improvised and verbatim language intertwine with a music score that integrates Southern rap, horns, drumlines, and melodic R&B and soul by Lambkin. The Chord Archive is showcased alongside performances, a physical and digital documentation of the creative process and personal historical accounts from former majorette dancers. A fierce investigation of physical memory, sexuality, sensuality, and community, MAJOR is a nuanced love letter to the folks who taught the team how to be proudly Black and proudly femme. | https://newyorklivearts.my.salesforce-sites.com/ticket/#/instances/a0FVt00000DafLXMAZ |

    And I am logged in as "Alice"

  Scenario: Liking an event from the home page 
    Given I am on the Home page
    When I click the "Like" button on the "For All Your Life" event card 
    Then "For All Your Life" should appear in my liked events list

  Scenario: disliking an event from the home page 
    Given I am on the Home page 
    When I click the "Dislike" button on the "For All Your Life" event card 
    Then "For All Your Life" should not be in my liked events list

  Scenario: Marking an event as "going to" from the details page
    Given I am on the Event Details page for "For All Your Life"
    When I click "Going to" button
    Then "For All Your Life" should be added to my Google Calendar
