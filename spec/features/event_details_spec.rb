require 'rails_helper'

RSpec.feature "Event Details Page", type: :feature do
  before do
    # Simulate seeded events from the CSV file
    @event1 = Event.create!(
      name: "Rennie Harris Puremovement American Street Dance Theater",
      venue: "The Joyce Theater",
      date: Date.parse("2025-11-11"),
      time: "7:30 PM",
      style: "Hip-hop",
      location: "Chelsea",
      price: 32,
      description: "Well-known for painting rich tapestries of political, philosophical, and spiritual ideas, Rennie Harris returns with American Street Dance Theater, blending hip-hop and storytelling.",
      tickets: "https://shop.joyce.org/8129/8130"
    )

    @event2 = Event.create!(
      name: "A Very SW!NG OUT Holiday",
      venue: "The Joyce Theater",
      date: Date.parse("2025-12-17"),
      time: "8:00 PM",
      style: "Tap",
      location: "Manhattan",
      price: 40,
      description: "A tap dance celebration of the holiday season featuring live jazz music.",
      tickets: "https://shop.joyce.org/holidaytap"
    )
  end

  scenario "User sees list of events from CSV seed" do
    visit events_path

    expect(page).to have_content("Rennie Harris Puremovement American Street Dance Theater")
    expect(page).to have_content("A Very SW!NG OUT Holiday")
    expect(page).to have_content("The Joyce Theater")
    expect(page).to have_content("Chelsea")
    expect(page).to have_content("Manhattan")
  end

  scenario "User views details for 'Rennie Harris Puremovement American Street Dance Theater'" do
    visit events_path
    click_link "Rennie Harris Puremovement American Street Dance Theater"

    expect(page).to have_current_path(event_path(@event1))
    expect(page).to have_content("Rennie Harris Puremovement American Street Dance Theater")
    expect(page).to have_content("The Joyce Theater")
    expect(page).to have_content("November 11, 2025")
    expect(page).to have_content("7:30 PM")
    expect(page).to have_content("Hip-hop")
    expect(page).to have_content("Chelsea")
    expect(page).to have_content("$32")
    expect(page).to have_content("Well-known for painting rich tapestries of political, philosophical, and spiritual ideas")
    expect(page).to have_link("Get Tickets", href: "https://shop.joyce.org/8129/8130")
  end

  scenario "User views details for 'A Very SW!NG OUT Holiday'" do
    visit events_path
    click_link "A Very SW!NG OUT Holiday"

    expect(page).to have_current_path(event_path(@event2))
    expect(page).to have_content("A Very SW!NG OUT Holiday")
    expect(page).to have_content("The Joyce Theater")
    expect(page).to have_content("December 17, 2025")
    expect(page).to have_content("8:00 PM")
    expect(page).to have_content("Tap")
    expect(page).to have_content("Manhattan")
    expect(page).to have_content("$40")
    expect(page).to have_content("A tap dance celebration of the holiday season featuring live jazz music.")
    expect(page).to have_link("Get Tickets", href: "https://shop.joyce.org/holidaytap")
  end

  scenario "User can navigate back to event list" do
    visit event_path(@event2)
    click_link "Back"
    expect(page).to have_current_path(events_path)
  end
end
