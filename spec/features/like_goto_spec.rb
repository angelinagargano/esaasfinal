require 'rails_helper'

RSpec.feature "Interacting with events", type: :feature do
  background do
    @alice = User.create!(name: "Alice", email: "alice@example.com", password: "password")

    Event.create!(
      name: "Rennie Harris Puremovement American Street Dance Theater",
      venue: "The Joyce Theater",
      date: Date.parse("November 11, 2025"),
      time: "7:30 PM",
      style: "Hip-hop",
      location: "Chelsea",
      price: 32,
      description: "Well-known for painting rich tapestries...",
      tickets: "https://shop.joyce.org/8129/8130"
    )

    Event.create!(
      name: "For All Your Life",
      venue: "BAM Brooklyn Academy of Music",
      date: Date.parse("December 3, 2025"),
      time: "7:30 PM",
      style: "Modern",
      location: "Brooklyn",
      price: 35,
      description: "A contemporary dance showcase...",
      tickets: "https://bam.org/forallyourlife"
    )

    Event.create!(
      name: "A Very SW!NG OUT Holiday",
      venue: "Joyce Theater",
      date: Date.parse("December 17, 2025"),
      time: "8:00 PM",
      style: "Tap",
      location: "Manhattan",
      price: 40,
      description: "A tap dance celebration...",
      tickets: "https://shop.joyce.org/holidaytap"
    )

    Event.create!(
      name: "Ogemdi Ude: MAJOR",
      venue: "New York Live Arts",
      date: Date.parse("January 7, 2026"),
      time: "7:30 PM",
      style: "Dance Theater",
      location: "Chelsea",
      price: 28,
      description: "MAJOR is a dance theater project...",
      tickets: "https://newyorklivearts.my.salesforce-sites.com/ticket/#/instances/a0FVt00000DafLXMAZ"
    )

    login_as(@alice, scope: :user)
  end

  scenario "Liking an event from the home page" do
    visit root_path

    within(".event-card", text: "For All Your Life") do
      click_button "Like"
    end

    visit liked_events_path

    expect(page).to have_content("For All Your Life")
  end

  scenario "Disliking an event from the home page" do
    visit root_path

    within(".event-card", text: "For All Your Life") do
      click_button "Dislike"
    end

    visit liked_events_path

    expect(page).not_to have_content("For All Your Life")
  end

  scenario "Marking an event as going to from the details page" do
    event = Event.find_by(name: "For All Your Life")

    visit event_path(event)
    click_button "Going to"

    # Assuming your app integrates with Google Calendar API
    expect(page).to have_content("Added to your Google Calendar")
  end
end

