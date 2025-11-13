require 'rails_helper'

RSpec.feature "Home Page", type: :feature do
  let!(:event1) do
    Event.create!(
      name: "For All Your Life",
      venue: "BAM Brooklyn Academy of Music",
      date: "December 3, 2025",
      time: "7:30 PM",
      style: "Ballet",
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
      style: "Avant Garde",
      location: "Manhattan",
      price: "$40",
      description: "A tap dance celebration of the holiday season featuring live jazz music.",
      tickets: "https://shop.joyce.org/holidaytap"
    )
  end

  background do
    # Visit the performances page directly since that's the home feed
    visit performances_path
  end
  

  scenario "Viewing the default home feed with no preferences" do
    expect(page).to have_content(event1.name)
    expect(page).to have_content(event2.name)
  end

  scenario "Viewing the personalized feed after setting preferences" do
    visit preferences_path

    check "$25–$50" 
    check "Ballet" 
    click_button "Save Preferences"

    expect(current_path).to eq(performances_path)
    expect(page).to have_content(event1.name)
    expect(page).not_to have_content(event2.name)
  end

  scenario "Filtering events by date" do
    visit performances_path

    select "Date", from: "sort_by"
    click_button "Filter"
    # Grab event titles in order
    titles = page.all('.card .card-title').map(&:text)

    # Filter only your two events
    event_cards = [event1, event2].map do |event|
      find(".card[data-event-id='#{event.id}'] .card-title").text
    end

    # Expect them to appear in ascending date order
    expect(event_cards).to eq([event1.name, event2.name])
  end
  scenario "Viewing an event’s details from the home page" do
    visit performances_path
    within(find(".card[data-event-id='#{event1.id}']")) do
      click_link "More Details"
    end

    expect(current_path).to eq(details_performance_path(event1))
    expect(page).to have_content(event1.description)
    expect(page).to have_link("Purchase Tickets", href: event1.tickets)
  end

  scenario "Viewing event information on the home feed" do
    visit performances_path

    within(find(".card[data-event-id='#{event1.id}']")) do
      expect(page).to have_content("December 3, 2025")
      expect(page).to have_content("7:30 PM")
      expect(page).to have_content("BAM Brooklyn Academy of Music")
      expect(page).to have_content("$35")
    end
  end
end
