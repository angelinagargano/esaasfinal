require 'rails_helper'

RSpec.describe User, type: :model do
  it 'validates presence of required fields' do
    user = User.new
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
    expect(user.errors[:name]).to include("can't be blank")
    expect(user.errors[:username]).to include("can't be blank")
    expect(user.errors[:password]).to include("can't be blank")
  end

  it 'enforces unique username' do
    User.create!(email: 'a@x.com', name: 'A', username: 'unique', password: 'pw')
    dup = User.new(email: 'b@x.com', name: 'B', username: 'unique', password: 'pw2')
    expect(dup).not_to be_valid
    expect(dup.errors[:username]).to include('has already been taken')
  end
end
