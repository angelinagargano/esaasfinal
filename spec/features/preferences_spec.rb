_require 'rails_helper'

RSpec.feature "Event Details Page", type: :feature do
  before do
    @event = Event.create!(
      name: "Jazz Night",
      price: 25,
      date_time: Time.zone.parse("2025-11-15 20:00"),
      location: "Lincoln Center, NYC",
      more_details: "A cozy evening with live jazz and cocktails."
    )
  end

  scenario "User views details of an existing event" do
    visit events_path
    expect(page).to have_content("Jazz Night")

    click_link "Jazz Night"

    expect(page).to have_current_path(event_path(@event))
    expect(page).to have_content("Jazz Night")
    expect(page).to have_content("Lincoln Center")
    expect(page).to have_content("25")
    expect(page).to have_content("A cozy evening with live jazz and cocktails.")
  end

  scenario "User sees a ticket button on the event details page" do
    visit event_path(@event)
    expect(page).to have_button("Get Tickets")
  end

  scenario "Navigating back to events list" do
    visit event_path(@event)
    click_link "Back"
    expect(page).to have_current_path(events_path)
  end
end
