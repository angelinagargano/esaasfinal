# spec/features/user_profile_spec.rb

require 'rails_helper'

RSpec.feature "User Profile", type: :feature do
  let!(:user) do
    User.create!(
      username: "testuser",
      email: "testuser@example.com",
      name: "Test User",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let!(:event1) do
    Event.create!(
      name: "Hip Hop Dance Night",
      venue: "The Joyce Theater",
      date: "November 15, 2025",
      time: "7:30 PM",
      style: "Hip-hop",
      location: "Chelsea",
      borough: "Manhattan",
      price: "$32",
      description: "Amazing hip hop performance",
      tickets: "https://example.com/tickets"
    )
  end

  let!(:event2) do
    Event.create!(
      name: "Ballet Showcase",
      venue: "BAM Brooklyn Academy of Music",
      date: "December 10, 2025",
      time: "8:00 PM",
      style: "Ballet",
      location: "Brooklyn",
      borough: "Brooklyn",
      price: "$45",
      description: "Classical ballet performance",
      tickets: "https://example.com/ballet"
    )
  end

  before do
    # Log in the user before each test
    visit login_path
    fill_in "Username", with: user.username
    fill_in "Password", with: "password123"
    click_button "Log in"
  end

  describe "Viewing user profile" do
    it "displays username, name, and email" do
      visit user_profile_path(user)
      
      expect(page).to have_content(user.username)
      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
    end
  end

  describe "Editing user information" do
    it "allows editing username, name, and email" do
      visit user_profile_path(user)
      click_link "Edit my information"
      
      expect(current_path).to eq(edit_user_path(user))
      
      find('input[name="user[username]"]').set("alice777")
      find('input[name="user[name]"]').set("Alice Updated")
      find('input[name="user[email]"]').set("alice.updated@example.com")
      
      click_button "Save changes"
      
      expect(current_path).to eq("/users/#{user.id}/profile")
      expect(page).to have_content("alice777")
      expect(page).to have_content("Alice Updated")
      expect(page).to have_content("alice.updated@example.com")
    end

    it "allows editing password" do
      visit user_profile_path(user)
      click_link "Edit my information"
      
      expect(current_path).to eq(edit_user_path(user))
      
      find('input[name="user[password]"]').set("newpassword123")
      find('input[name="user[password_confirmation]"]').set("newpassword123")
      
      click_button "Save changes"
      
      expect(current_path).to eq("/users/#{user.id}/profile")
      expect(page).to have_content("Your information was successfully updated")
    end

    it "allows canceling edit without saving" do
      visit user_profile_path(user)
      click_link "Edit my information"
      
      expect(current_path).to eq(edit_user_path(user))
      
      find('input[name="user[username]"]').set("temporary_username")
      click_link "Cancel"
      
      expect(current_path).to eq("/users/#{user.id}/profile")
      expect(page).not_to have_content("temporary_username")
    end
  end

  describe "Liked events" do
    context "when user has no liked events" do
      before do
        user.liked_events.clear
      end

      it "displays message when no events are liked" do
        visit user_profile_path(user)
        
        expect(page).to have_content("You haven't liked any events yet")
      end
    end

    context "when user has liked events" do
      before do
        user.liked_events << event1 unless user.liked_events.include?(event1)
        user.liked_events << event2 unless user.liked_events.include?(event2)
      end

      it "displays liked events" do
        visit user_profile_path(user)
        
        within(".liked-events") do
          expect(page).to have_content(event1.name)
          expect(page).to have_content(event2.name)
        end
      end

    
      it "allows viewing details of a liked event" do
        visit user_profile_path(user)
        
        within(".liked-events") do
          click_link("View Details", match: :first)
        end
        
        expect(page).to have_css('.event-details')
        expect(page).to have_content("Details about")
      end
    end
  end
end