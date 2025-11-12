# RSpec Test Fixes - Detailed Explanation

## Summary of All Failures and Fixes

### 1. Authentication: Missing Logout Link
**File:** `spec/features/authentication_spec.rb:84`  
**Error:** `Unable to find link "Logout"`

**Problem:**
The test expects a "Logout" link to be available when a user is logged in, but the navbar in `application.html.erb` didn't have this link.

**Solution:**
Added logout link to the navbar in `app/views/layouts/application.html.erb`:
```erb
<% if logged_in? %>
  <li class="nav-item">
    <%= link_to "My Profile", user_profile_path(current_user), class: "nav-link" %>
  </li>
  <li class="nav-item">
    <%= link_to "Logout", logout_path, method: :delete, class: "nav-link" %>
  </li>
<% else %>
  <li class="nav-item">
    <%= link_to "Log in", login_path, class: "nav-link" %>
  </li>
  <li class="nav-item">
    <%= link_to "Sign up", signup_path, class: "nav-link" %>
  </li>
<% end %>
```

---

### 2-6. Home Feed Tests: Wrong Path Usage
**Files:** 
- `spec/features/home_feed_spec.rb:38` - Viewing default home feed
- `spec/features/home_feed_spec.rb:49` - Personalized feed redirect
- `spec/features/home_feed_spec.rb:58` - Filtering events
- `spec/features/home_feed_spec.rb:72` - Event details
- `spec/features/home_feed_spec.rb:84` - Event information

**Problems:**
1. Tests were visiting `root_path` expecting to see events, but `root_path` routes to the login page
2. Tests expected redirects to `root_path` after setting preferences, but the app redirects to `performances_path`
3. Test was looking for a "Refresh" button, but the actual button is "Apply Filter"

**Solutions:**

**a) Changed background setup from `root_path` to `performances_path`:**
```ruby
background do
  visit performances_path  # Changed from root_path
end
```

**b) Updated redirect expectations:**
```ruby
# Changed from:
expect(current_path).to eq(root_path)
# To:
expect(current_path).to eq(performances_path)
```

**c) Fixed button name:**
```ruby
# Changed from:
click_button "Refresh"
# To:
click_button "Apply Filter"
```

**d) Removed redundant `visit root_path` calls** since the background already visits the performances page.

---

### 7-10. Preferences Tests: Wrong Redirect Path
**Files:**
- `spec/features/preferences_spec.rb:28` - No Preference for both
- `spec/features/preferences_spec.rb:40` - Single budget and type
- `spec/features/preferences_spec.rb:52` - Multiple selections
- `spec/features/preferences_spec.rb:69` - No Preference override

**Problem:**
After saving preferences, `PreferencesController#create` redirects to `performances_path`, but tests expected `root_path`.

**Solution:**
Updated all test expectations from:
```ruby
expect(page).to have_current_path(root_path)
```
To:
```ruby
expect(page).to have_current_path(performances_path)
```

This aligns with the actual controller behavior in `app/controllers/preferences_controller.rb:57`:
```ruby
redirect_to performances_path
```

---

### 11. User Model: Password Validation
**File:** `spec/models/user_spec.rb:14`  
**Error:** `Validation failed: Password is too short (minimum is 6 characters)`

**Problem:**
The test was creating a user with password `'pw'` (2 characters), but the User model has this validation:
```ruby
validates :password, length: { minimum: 6 }, if: -> { password.present? }
```

**Solution:**
Changed the test to use valid passwords (6+ characters):
```ruby
# Changed from:
User.create!(email: 'a@x.com', name: 'A', username: 'unique', password: 'pw')
dup = User.new(email: 'b@x.com', name: 'B', username: 'unique', password: 'pw2')

# To:
User.create!(email: 'a@x.com', name: 'A', username: 'unique', password: 'password')
dup = User.new(email: 'b@x.com', name: 'B', username: 'unique', password: 'password2')
```

---

## Why These Errors Occurred

1. **Path Confusion**: Your app's `root_path` is the login page, but tests assumed it was the performances/home page
2. **Missing UI Elements**: Logout functionality existed in the controller but wasn't exposed in the UI
3. **Button Name Mismatch**: The view was updated but the test wasn't
4. **Validation Rules**: The User model has strict password requirements that tests didn't follow

---

## How to Verify All Tests Pass

Run the full test suite:
```bash
bundle exec rspec
```

Run specific test files:
```bash
bundle exec rspec spec/features/authentication_spec.rb
bundle exec rspec spec/features/home_feed_spec.rb
bundle exec rspec spec/features/preferences_spec.rb
bundle exec rspec spec/models/user_spec.rb
```

Check coverage:
```bash
COVERAGE=true bundle exec rspec
open coverage/index.html
```

---

## Expected Results

After these fixes, you should see:
- **30 examples, 0 failures, 2 pending**
- The 2 pending tests are in `going_event_spec.rb` and `like_spec.rb` which are placeholder tests
- Coverage should remain at ~73% or improve

All tests should now pass! ✅
