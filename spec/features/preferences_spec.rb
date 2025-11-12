require 'rails_helper'

RSpec.feature "Preferences", type: :feature do
  before do
    @budget_options = ["$0–$25", "$25–$50", "$50–$100", "$100+", "No Preference"]
    @performance_type_options = ["Hip-hop", "Ballet", "Swing", "Contemporary", "Dance Theater", "No Preference"]
  end

  scenario "User sees all budget and performance type checkboxes" do
    visit preferences_path

    @budget_options.each do |b|
      expect(page).to have_unchecked_field("budget_#{b.parameterize}")
    end

    @performance_type_options.each do |t|
      expect(page).to have_unchecked_field("performance_type_#{t.parameterize}")
    end
  end

  scenario "User selects No Preference for both categories" do
    visit preferences_path

    check "budget_no-preference"
    check "performance_type_no-preference"
    click_button "Save Preferences"

    expect(page).to have_current_path(performances_path)
    #expect(page).to have_content("All available events")
  end

  scenario "User selects a single budget and a single performance type" do
    visit preferences_path

    check "budget_50-100"
    check "performance_type_ballet"

    click_button "Save Preferences"

    expect(page).to have_current_path(performances_path)
    end

  scenario "User selects multiple budgets and performance types" do
    visit preferences_path

    check "budget_0-25"
    check "budget_25-50"
    check "performance_type_hip-hop"
    check "performance_type_swing"
    click_button "Save Preferences"

    expect(page).to have_current_path(performances_path)
    #expect(page).to have_content("Events matching selected budgets and performance types")
  end

  scenario "No Preference overrides other selections" do
    visit preferences_path

    check "budget_0-25"
    check "budget_25-50"
    check "performance_type_ballet"
    check "performance_type_swing"

    # Check No Preference last
    check "budget_no-preference"
    check "performance_type_no-preference"

    click_button "Save Preferences"
    expect(page).to have_current_path(performances_path)
  end

  scenario "User clears preferences" do
    visit preferences_path

    check "budget_0-25"
    check "performance_type_ballet"
    click_button "clear_preferences"

    expect(page).to have_current_path(preferences_path)
    @budget_options.each do |b|
        expect(find_field("budget_#{b.parameterize}")).not_to be_checked
    end
    @performance_type_options.each do |t|
        expect(find_field("performance_type_#{t.parameterize}")).not_to be_checked
    end
  end

  scenario "User clears preferences with No Preference selected" do
    visit preferences_path
    check "budget_no-preference"
    check "performance_type_no-preference"
    click_button "clear_preferences"

    expect(page).to have_current_path(preferences_path)
    @budget_options.each do |b|
        expect(find_field("budget_#{b.parameterize}")).not_to be_checked
    end
    @performance_type_options.each do |t|
        expect(find_field("performance_type_#{t.parameterize}")).not_to be_checked
    end
  end

  scenario "User selects budget but no performance type" do
    visit preferences_path
    check "budget_25-50"
    click_button "Save Preferences"

    expect(page).to have_current_path(preferences_path)
    expect(page).to have_content("Please select at least one performance type")
    end


  scenario "User submits without selecting any options" do
    visit preferences_path
    click_button "Save Preferences"

    expect(page).to have_current_path(preferences_path)
    expect(page).to have_content("Please select at least one preference before continuing")
  end


end

