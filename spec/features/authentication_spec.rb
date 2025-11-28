
require 'rails_helper'

RSpec.feature "Authentication", type: :feature do
  scenario "user can sign up with valid details" do
    visit root_path
    click_link 'Sign up'

    fill_in 'user[email]', with: 'alice@example.com'
    fill_in 'user[name]', with: 'Alice Example'
    fill_in 'user[username]', with: 'alice123'
    fill_in 'user[password]', with: 'password123'
    fill_in 'user[password_confirmation]', with: 'password123'

    click_button 'Sign up'

    expect(current_path).to eq('/preferences')
    expect(page).to have_content('Account created successfully! Please set your preferences.')
  end

  scenario "user can log in with valid credentials" do
    User.create!(email: 'bob@example.com', name: 'Bob', username: 'bob', password: 'secret', password_confirmation: 'secret')

    visit login_path
    fill_in 'username_or_email', with: 'bob'
    fill_in 'password', with: 'secret'
    click_button 'Log in'

    expect(current_path).to eq(performances_path)
    expect(page).to have_content('Logged in as bob')
  end

  scenario "login fails with invalid credentials" do
    visit login_path
    fill_in 'username_or_email', with: 'nonexistent'
    fill_in 'password', with: 'wrongpassword'
    click_button 'Log in'

    expect(current_path).to eq(login_path)
    expect(page).to have_content('Invalid username or password')
  end

  scenario "user can log out successfully" do
    user = User.create!(email: 'carol@example.com', name: 'Carol', username: 'carol', password: 'mypassword', password_confirmation: 'mypassword')

    visit login_path
    fill_in 'username_or_email', with: 'carol'
    fill_in 'password', with: 'mypassword'
    click_button 'Log in'

    # Assuming you have a logout link or button
    click_link 'Logout' # or click_button 'Logout' depending on your layout

    expect(current_path).to eq(root_path)
    expect(page).to have_content('Logged out')
  end
end
