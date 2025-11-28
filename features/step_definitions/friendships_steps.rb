# features/step_definitions/friendships_steps.rb

Given("I am on the Find Friends page") do
    visit find_friends_search_path
  end

  Given("I am on the User Profile page") do
    user = @logged_in_user || @user || User.find_by(username: "alice123")
    visit user_profile_path(user)
  end
  
  When("I search for username {string}") do |username|
    fill_in "username", with: username
    click_button "Search"
  end
  
  Then("I should see {string} in the search results") do |username|
    expect(page).to have_content(username)
  end
  
  Then("I should see an {string} button for {string}") do |button_text, username|
    within("div.card", text: username) do
      expect(page.has_button?(button_text) || page.has_link?(button_text)).to be true
    end
  end
  
  When("I click {string} for user {string}") do |button_text, username|
    within("div.card", text: username) do
      if page.has_link?(button_text)
        click_link(button_text)
      elsif page.has_button?(button_text)
        click_button(button_text)
      else
        raise "Could not find #{button_text} for #{username}"
      end
    end
  end
  
  Then("{string} should have a pending friend request from {string}") do |recipient_username, sender_username|
    recipient = User.find_by(username: recipient_username)
    sender = User.find_by(username: sender_username)
    
    friendship = Friendship.find_by(user: sender, friend: recipient, status: false)
    expect(friendship).to be_present
  end
  
  When("I try to add myself as a friend") do
    # Since search excludes current user, make a direct POST request
    current_user = @logged_in_user || User.find_by(username: "alice123")
    page.driver.submit :post, add_friend_path(current_user), {}
  end
  
  Given("I have sent a friend request to {string}") do |username|
    current_user = @logged_in_user || User.find_by(username: "alice123")
    friend = User.find_by(username: username)
    
    Friendship.create!(user: current_user, friend: friend, status: false)
  end
  
  When("I try to send another friend request to {string}") do |username|
    visit find_friends_search_path
    fill_in "username", with: username
    click_button "Search"
    
    within("div.card", text: username) do
      if page.has_link?("Add Friend")
        click_link("Add Friend")
      elsif page.has_button?("Add Friend")
        click_button("Add Friend")
      end
    end
  end
  
  Given("{string} has sent a friend request to {string}") do |sender_username, recipient_username|
    sender = User.find_by(username: sender_username)
    recipient = User.find_by(username: recipient_username)
    
    Friendship.create!(user: sender, friend: recipient, status: false)
  end
  
  When("I click {string} for friend request from {string}") do |action, username|
    within(".friend-requests-section") do
      within("div.card", text: username) do
        if page.has_link?(action)
          click_link(action)
        elsif page.has_button?(action)
          click_button(action)
        else
          raise "Could not find #{action} button for #{username}"
        end
      end
    end
  end
  
  Then("{string} and {string} should be friends") do |username1, username2|
    user1 = User.find_by(username: username1)
    user2 = User.find_by(username: username2)
    
 
    friendship1 = Friendship.find_by(user: user1, friend: user2, status: true)
    friendship2 = Friendship.find_by(user: user2, friend: user1, status: true)
    
    expect(friendship1 || friendship2).to be_present
  end
  
  Then("{string} and {string} should not be friends") do |username1, username2|
    user1 = User.find_by(username: username1)
    user2 = User.find_by(username: username2)
    
    friendship1 = Friendship.find_by(user: user1, friend: user2, status: true)
    friendship2 = Friendship.find_by(user: user2, friend: user1, status: true)
    
    expect(friendship1).to be_nil
    expect(friendship2).to be_nil
  end
  
  When("I click {string} for friend {string}") do |action, username|
    within(".friends-section") do
      within("div.card", text: username) do
        if page.has_link?(action)
          click_link(action)
        elsif page.has_button?(action)
          click_button(action)
        else
          raise "Could not find #{action} button for #{username}"
        end
      end
    end
  end
  
  Given("{string} and {string} are friends") do |username1, username2|
    user1 = User.find_by(username: username1)
    user2 = User.find_by(username: username2)
 
    Friendship.find_or_create_by!(user: user1, friend: user2) do |f|
      f.status = true
    end
  end
  
  Then("I should see {string} section") do |section_name|
    expect(page).to have_content(section_name)
  end
  
  Then("I should see {string} in pending requests") do |username|
    within(".friend-requests-section") do
      expect(page).to have_content(username)
    end
  end
  
  Then("I should see {string} in my friends list") do |username|
    within(".friends-section") do
      expect(page).to have_content(username)
    end
  end
  
  Then("I should see {string} in outgoing pending requests") do |username|
    within(".friends-section") do
      expect(page).to have_content(username)
      expect(page).to have_content("Friend request sent")
    end
  end
  
  Then("I should see {string} button for {string}") do |button_text, username|
    within(".friends-section") do
      within("div.card", text: username) do
        expect(page.has_content?(button_text) || page.has_button?(button_text)).to be true
      end
    end
  end
  
  When("I try to accept a non-existent friend request") do
   
    current_user = @logged_in_user || User.find_by(username: "alice123")
    other_user = User.find_by(username: "charlie789")
    Friendship.where(user: other_user, friend: current_user).destroy_all
    page.driver.submit :post, accept_friend_path(other_user), {}
  end
  
  When("I try to reject a non-existent friend request") do

    current_user = @logged_in_user || User.find_by(username: "alice123")
    other_user = User.find_by(username: "charlie789")
    Friendship.where(user: other_user, friend: current_user).destroy_all
    page.driver.submit :delete, reject_friend_path(other_user), {}
  end
  
  Given("{string} and {string} are not friends") do |username1, username2|
    user1 = User.find_by(username: username1)
    user2 = User.find_by(username: username2)
    
    # Ensure no friendship exists
    Friendship.where(user: user1, friend: user2).destroy_all
    Friendship.where(user: user2, friend: user1).destroy_all
  end
  
  When("I try to unfriend {string}") do |username|
    current_user = @logged_in_user || User.find_by(username: "alice123")
    friend = User.find_by(username: username)
    
    # If they're not friends, make a direct DELETE request to test the error case
    unless Friendship.exists?(user: current_user, friend: friend, status: true) ||
           Friendship.exists?(user: friend, friend: current_user, status: true)
      page.driver.submit :delete, unfriend_path(friend), {}
    else
      # If they are friends, visit the page and click the button
      visit user_profile_path(current_user)
      if page.has_content?(username)
        within(".friends-section") do
          if page.has_link?("Unfriend")
            within("div.card", text: username) do
              link = find_link("Unfriend")
              link.click
            end
          end
        end
      end
    end
  end

  Given("I stub Friendship to fail on save") do
    allow_any_instance_of(Friendship).to receive(:save).and_return(false)
  end

  Given("I stub Friendship to fail on update") do
    allow_any_instance_of(Friendship).to receive(:update).and_return(false)
  end

  Given("I am logged out") do
    if page.driver.respond_to?(:submit)
      begin
        page.driver.submit :delete, logout_path, {}
      rescue
        # If logout_path doesn't exist or fails, just clear session
        page.driver.clear_cookies
      end
    else
      page.driver.clear_cookies
    end
    # Ensure we're not on a page that requires login
    visit root_path
  end