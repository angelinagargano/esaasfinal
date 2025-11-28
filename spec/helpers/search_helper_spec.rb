require 'rails_helper'

RSpec.describe SearchHelper, type: :helper do
  let(:user1) do
    User.create!(
      email: 'alice@example.com',
      name: 'Alice Smith',
      username: 'alice123',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:user2) do
    User.create!(
      email: 'bob@example.com',
      name: 'Bob Jones',
      username: 'bob456',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  describe '#search_result_count' do
    it 'returns message for no results without search term' do
      expect(helper.search_result_count([])).to eq("No users found.")
    end

    it 'returns message for no results with search term' do
      expect(helper.search_result_count([], 'alice')).to eq("No users found matching 'alice'.")
    end

    it 'returns singular message for one result' do
      expect(helper.search_result_count([user1])).to eq("Found 1 user.")
    end

    it 'returns singular message for one result with search term' do
      expect(helper.search_result_count([user1], 'alice')).to eq("Found 1 user matching 'alice'.")
    end

    it 'returns plural message for multiple results' do
      expect(helper.search_result_count([user1, user2])).to eq("Found 2 users.")
    end

    it 'returns plural message for multiple results with search term' do
      expect(helper.search_result_count([user1, user2], 'test')).to eq("Found 2 users matching 'test'.")
    end
  end

  describe '#highlight_search_term' do
    it 'returns original text when term is blank' do
      expect(helper.highlight_search_term('alice123', '')).to eq('alice123')
    end

    it 'returns original text when text is blank' do
      expect(helper.highlight_search_term('', 'alice')).to eq('')
    end

    it 'highlights the search term in text' do
      result = helper.highlight_search_term('alice123', 'alice')
      expect(result).to include('<strong')
      expect(result).to include('alice')
    end

    it 'is case insensitive' do
      result = helper.highlight_search_term('Alice123', 'alice')
      expect(result).to include('<strong')
      expect(result).to include('Alice')
    end

    it 'highlights multiple occurrences' do
      result = helper.highlight_search_term('alice alice', 'alice')
      expect(result.scan(/<strong/).count).to eq(2)
    end

    it 'escapes special regex characters in search term' do
      result = helper.highlight_search_term('user.test', '.')
      expect(result).to include('<strong')
    end
  end

  describe '#format_user_display_name' do
    it 'formats user display name with username and name' do
      expect(helper.format_user_display_name(user1)).to eq('alice123 (Alice Smith)')
    end

    it 'handles different user names correctly' do
      expect(helper.format_user_display_name(user2)).to eq('bob456 (Bob Jones)')
    end
  end

  describe '#search_performed?' do
    it 'returns true when search term is present' do
      expect(helper.search_performed?('alice')).to be true
    end

    it 'returns false when search term is blank' do
      expect(helper.search_performed?('')).to be false
    end

    it 'returns false when search term is nil' do
      expect(helper.search_performed?(nil)).to be false
    end

    it 'returns false when search term is only whitespace' do
      expect(helper.search_performed?('   ')).to be false
    end
  end

  describe '#search_prompt_message' do
    it 'returns the prompt message' do
      expect(helper.search_prompt_message).to eq("Enter a username to search for friends.")
    end
  end
end
