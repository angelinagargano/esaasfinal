require 'rails_helper'

RSpec.feature "Initial Preferences", type: :feature do
  scenario "User sees available preference options" do
    visit preferences_path

    expect(page).to have_select("Budget", options: ["$0–$25", "$25–$50", "$50–$100", "$100+", "No Preference"])
    expect(page).to have_select("Distance", options: ["Within 2mi", "Within 5mi", "Within 10mi", "No Preference"])
    expect(page).to have_select("Performance Type", options: ["Hip-hop", "Ballet", "Tap", "Modern", "No Preference"])
  end

  scenario "User sets initial preferences" do
    visit preferences_path

    select "$0–$25", from: "Budget"
    select "Within 2mi", from: "Distance"
    select "Ballet", from: "Performance Type"
    click_button "Save Preferences"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Events matching your preferences") 
  end

  scenario "User selects 'No Preference' for all categories" do
    visit preferences_path

    select "No Preference", from: "Budget"
    select "No Preference", from: "Distance"
    select "No Preference", from: "Performance Type"
    click_button "Save Preferences"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("All available events")
  end

  scenario "User selects 'No Preference' for one category" do
    visit preferences_path

    select "$25–$50", from: "Budget"
    select "Within 5mi", from: "Distance"
    select "No Preference", from: "Performance Type"
    click_button "Save Preferences"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Events matching your budget and distance preferences")
  end

  scenario "User selects multiple budgets and performance types" do
    visit preferences_path

    # Using multiple select for budgets
    budgets = ["$0–$25", "$25–$50"]
    budgets.each { |budget| select budget, from: "Budget" }

    # Using multiple select for performance types
    performance_types = ["Hip-hop", "Tap"]
    performance_types.each { |type| select type, from: "Performance Type" }

    select "Within 2mi", from: "Distance"
    click_button "Save Preferences"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Events matching any selected budget and performance type within 2 miles")
  end

  scenario "User attempts to save without selecting any preferences" do
    visit preferences_path

    click_button "Save Preferences"

    expect(page).to have_content("Please select at least one preference before continuing")
    expect(page).to have_current_path(preferences_path)
  end

  scenario "User saves without selecting a performance type" do
    visit preferences_path

    select "$25–$50", from: "Budget"
    select "Within 5mi", from: "Distance"
    click_button "Save Preferences"

    expect(page).to have_content("Please select at least one performance type")
    expect(page).to have_current_path(preferences_path)
  end
end
