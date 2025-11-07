require 'rails_helper'

RSpec.feature "Authentication", type: :feature do
  scenario "user can sign up with valid details" do
    # Start at root (login) and navigate to signup
    visit root_path
    click_link 'Sign up'

    fill_in 'email', with: 'alice@example.com'
    fill_in 'name', with: 'Alice Example'
    fill_in 'username', with: 'alice123'
    fill_in 'password', with: 'password123'
    click_button 'Sign up'

    # After signup the app redirects to the login page
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Account created. Please log in.')
  end

  scenario "user can log in with valid credentials" do
    User.create!(email: 'bob@example.com', name: 'Bob', username: 'bob', password: 'secret')

    visit '/login' rescue visit new_user_session_path if defined?(new_user_session_path)
    fill_in 'username', with: 'bob'
    fill_in 'password', with: 'secret'
    click_button 'Log in'

    expect(current_path).to eq(root_path)
    expect(page).to have_content('Logged in as bob')
  end
end
