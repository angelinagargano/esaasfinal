require 'rails_helper'

RSpec.feature "Event Details Page", type: :feature do
  before do
    # Simulate the seeded events from the CSV used in Cucumber
    @event1 = Event.create!(
      name: "Rhythmic Beats",
      price: 20,
      date_time: Time.zone.parse("2025-11-10 19:00"),
      location: "NYC Music Hall",
      more_details: "A fun night of rhythmic performances"
    )

    @event2 = Event.create!(
      name: "Jazz Night",
      price: 25,
      date_time: Time.zone.parse("2025-11-15 20:00"),
      location: "Lincoln Center, NYC",
      more_details: "A cozy evening with live jazz and cocktails."
    )
  end

  scenario "User sees list of events from CSV seed" do
    visit events_path

    expect(page).to have_content("Rhythmic Beats")
    expect(page).to have_content("Jazz Night")
    expect(page).to have_content("NYC Music Hall")
    expect(page).to have_content("Lincoln Center, NYC")
  end

  scenario "User views details for 'Rhythmic Beats'" do
    visit events_path
    click_link "Rhythmic Beats"

    expect(page).to have_current_path(event_path(@event1))
    expect(page).to have_content("Rhythmic Beats")
    expect(page).to have_content("A fun night of rhythmic performances")
    expect(page).to have_content("20")
    expect(page).to have_content("NYC Music Hall")
  end

  scenario "User views details for 'Jazz Night'" do
    visit events_path
    click_link "Jazz Night"

    expect(page).to have_current_path(event_path(@event2))
    expect(page).to have_content("Jazz Night")
    expect(page).to have_content("Lincoln Center, NYC")
    expect(page).to have_content("25")
    expect(page).to have_content("A cozy evening with live jazz and cocktails.")
  end

  scenario "User can navigate back to event list" do
    visit event_path(@event2)
    click_link "Back"
    expect(page).to have_current_path(events_path)
  end
end
