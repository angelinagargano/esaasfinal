require 'rails_helper'

RSpec.feature "Interacting with events", type: :feature do

  background do
    # Create test user
    @alice = User.create!(
      name: "Alice",
      email: "alice@example.com",
      username: "Alice123",
      password: "password"
    )

    # Create events
    events = [
      {
        name: "Rennie Harris Puremovement American Street Dance Theater",
        venue: "The Joyce Theater",
        date: "2025-11-11",
        time: "7:30 PM",
        style: "Hip-hop",
        location: "Chelsea",
        price: 32,
        description: "Well-known for painting rich tapestries...",
        tickets: "https://shop.joyce.org/8129/8130"
      },
      {
        name: "For All Your Life",
        venue: "BAM Brooklyn Academy of Music",
        date: "2025-12-03",
        time: "7:30 PM",
        style: "Modern",
        location: "Brooklyn",
        price: 35,
        description: "A contemporary dance showcase...",
        tickets: "https://bam.org/forallyourlife"
      },
      {
        name: "A Very SW!NG OUT Holiday",
        venue: "Joyce Theater",
        date: "2025-12-17",
        time: "8:00 PM",
        style: "Tap",
        location: "Manhattan",
        price: 40,
        description: "A tap dance celebration...",
        tickets: "https://shop.joyce.org/holidaytap"
      },
      {
        name: "Ogemdi Ude: MAJOR",
        venue: "New York Live Arts",
        date: "2026-01-07",
        time: "7:30 PM",
        style: "Dance Theater",
        location: "Chelsea",
        price: 28,
        description: "MAJOR is a dance theater project...",
        tickets: "https://newyorklivearts.my.salesforce-sites.com/ticket/#/instances/a0FVt00000DafLXMAZ"
      }
    ]

    @events = events.map do |event|
      Event.find_or_create_by!(name: event[:name]) do |e|
        e.venue = event[:venue]
        e.date = Date.parse(event[:date])
        e.time = event[:time]
        e.style = event[:style]
        e.location = event[:location]
        e.price = event[:price]
        e.description = event[:description]
        e.tickets = event[:tickets]
      end
    end

    # Log in
    visit root_path
    fill_in "Username", with: @alice.username
    fill_in "Password", with: "password"
    click_button "Log in"
  end
  scenario "Viewing the list of events" do
    visit performances_path
    expect(page).to have_content("For All Your Life")
  end 
  scenario "Liking an event from the home page" do
    visit performances_path


    # Wait for the first card with specific text
    expect(page).to have_content("For All Your Life")
    card = first(".card", text: "For All Your Life", wait:10)

    #card = find(".card", text: "For All Your Life")
    within(card) do
      click_button "Like"
    end

    visit liked_events_performances_path
    expect(page).to have_content("For All Your Life")
  end

  scenario "Unliking an event from the home page" do
    # First, like the event
    visit performances_path
    expect(page).to have_content("For All Your Life")
    card = first(".card", text: "For All Your Life", wait:10)
    within(card) do
        click_button "Like"
    end
    visit liked_events_performances_path
    expect(page).to have_content("For All Your Life")
    # now unlike it 
    card = first(".card", text: "For All Your Life", wait:10)
    within(card) do
        click_button "Unlike"
    end
    expect(page).not_to have_content("For All Your Life")
  end

  scenario "Marking an event as going to from the details page" do
    event = Event.find_by(name: "For All Your Life")

    visit details_performance_path(event)
    expect(page).to have_link("Going to")

    click_link "Going to"
    expect(page).to have_content("Added to your Google Calendar")
  end
end