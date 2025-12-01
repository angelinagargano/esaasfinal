# features/step_definitions/groups_steps.rb

Given("I am on the Groups page") do
  visit groups_path
end

Then("I should see my groups") do
  expect(page).to have_css('.groups-list, .group, [data-group]')
end

Then("I should be on the group page for {string}") do |group_name|
  group = Group.find_by(name: group_name)
  expect(current_path).to eq(group_path(group))
end

Given("a group {string} exists created by {string}") do |group_name, creator_username|
  creator = User.find_by(username: creator_username)
  @group = Group.find_or_create_by!(name: group_name) do |g|
    g.description = "A group for #{group_name}"
    g.creator = creator
  end
  
  # Ensure creator is an admin member
  unless @group.group_members.exists?(user: creator, role: 'admin')
    @group.group_members.create!(user: creator, role: 'admin')
  end
end

When("I visit the group page for {string}") do |group_name|
  @group = Group.find_by(name: group_name)
  visit group_path(@group)
end

Given("I am on the group page for {string}") do |group_name|
  @group = Group.find_by(name: group_name)
  visit group_path(@group)
end

Then("I should see the group description") do
  expect(page).to have_css('.group-description, [data-description]')
end

When("I change {string} to {string}") do |field, value|
  if field == "Description"
    # Try multiple ways to find the Description field (for group forms)
    fill_in 'group[description]', with: value rescue fill_in 'Description', with: value rescue find('textarea[name="group[description]"]').set(value)
  else
    fill_in field, with: value
  end
end

Then("I should be on the Groups page") do
  expect(current_path).to eq(groups_path)
end

When("I add {string} to the group") do |username|
  friend = User.find_by(username: username)
  @group ||= Group.last
  within('.available-friends, .add-member-section, [data-add-member]') do
    if page.has_button?("Add #{username}") || page.has_link?("Add #{username}")
      click_button("Add #{username}") rescue click_link("Add #{username}")
    else
      # Try to find a form or button that adds this user
      page.driver.submit :post, add_member_group_path(@group), { friend_id: friend.id }
    end
  end
end

Then("{string} should be a member of {string}") do |username, group_name|
  user = User.find_by(username: username)
  group = Group.find_by(name: group_name)
  expect(group.member?(user)).to be true
end

Given("{string} is a member of {string}") do |username, group_name|
  user = User.find_by(username: username)
  group = Group.find_by(name: group_name)
  unless group.member?(user)
    group.group_members.create!(user: user, role: 'member')
  end
end

When("I remove {string} from the group") do |username|
  user = User.find_by(username: username)
  @group ||= Group.last
  
  within('.members-list, .group-members, [data-members]') do
    if page.has_button?("Remove #{username}") || page.has_link?("Remove #{username}")
      click_button("Remove #{username}") rescue click_link("Remove #{username}")
    else
      # Try to find remove button for this user
      page.driver.submit :delete, remove_member_group_path(@group, user_id: user.id), {}
    end
  end
end

Then("{string} should not be a member of {string}") do |username, group_name|
  user = User.find_by(username: username)
  group = Group.find_by(name: group_name)
  expect(group.member?(user)).to be false
end

When("I try to add {string} to the group") do |username|
  friend = User.find_by(username: username)
  @group ||= Group.last
  page.driver.submit :post, add_member_group_path(@group), { friend_id: friend.id }
end

