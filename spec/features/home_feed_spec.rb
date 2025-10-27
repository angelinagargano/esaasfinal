require 'rails_helper'

RSpec.feature "Home Page", type: :feature do
  let!(:event1) do
    Event.create!(
      name: "For All Your Life",
      venue: "BAM Brooklyn Academy of Music",
      date: "December 3, 2025",
      time: "7:30 PM",
      style: "Modern",
      location: "Brooklyn",
      price: "$35",
      description: "A contemporary dance showcase blending live music and emotional storytelling.",
      tickets: "https://bam.org/forallyourlife"
    )
  end

  let!(:event2) do
    Event.create!(
      name: "A Very SW!NG OUT Holiday",
      venue: "Joyce Theater",
      date: "December 17, 2025",
      time: "8:00 PM",
      style: "Tap",
      location: "Manhattan",
      price: "$40",
      description: "A tap dance celebration of the holiday season featuring live jazz music.",
      tickets: "https://shop.joyce.org/holidaytap"
    )
  end

  background do
    visit root_path
  end

  scenario "Viewing the default home feed with no preferences" do
    expect(page).to have_content(event1.name)
    expect(page).to have_content(event2.name)
  end

  scenario "Viewing the personalized feed after setting preferences" do
    visit preferences_path

    select "$25–$50", from: "Budget"
    select "Brooklyn", from: "Location"
    select "Modern", from: "Performance Type"
    click_button "Save Preferences"

    expect(current_path).to eq(root_path)
    expect(page).to have_content(event1.name)
    expect(page).not_to have_content(event2.name)
  end

  scenario "Filtering events by date" do
    visit root_path

    fill_in "Start Date", with: "2025-12-01"
    fill_in "End Date", with: "2025-12-10"
    click_button "Apply Filters"

    expect(page).to have_content(event1.name)
    expect(page).not_to have_content(event2.name)
  end

  scenario "Viewing an event’s details from the home page" do
    visit root_path
    click_on event1.name

    expect(current_path).to eq(event_path(event1))
    expect(page).to have_content(event1.description)
    expect(page).to have_link("Get Tickets", href: event1.tickets)
  end

  scenario "Viewing event information on the home feed" do
    visit root_path

    within(find(".event-card", text: event1.name)) do
      expect(page).to have_content("December 3, 2025")
      expect(page).to have_content("7:30 PM")
      expect(page).to have_content("BAM Brooklyn Academy of Music")
      expect(page).to have_content("$35")
    end
  end
end
