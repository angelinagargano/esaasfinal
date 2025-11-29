module SearchHelper
  # Returns a formatted message about search results
  def search_result_count(users, search_term = nil)
    count = users.count
    if count == 0
      "No users found#{search_term.present? ? " matching '#{search_term}'" : ''}."
    elsif count == 1
      "Found 1 user#{search_term.present? ? " matching '#{search_term}'" : ''}."
    else
      "Found #{count} users#{search_term.present? ? " matching '#{search_term}'" : ''}."
    end
  end

  # Highlights the search term in the given text
  def highlight_search_term(text, term)
    return text if term.blank? || text.blank?
    
    text.to_s.gsub(/(#{Regexp.escape(term)})/i) do |match|
      content_tag(:strong, match, class: 'highlight')
    end.html_safe
  end

  # Formats user display name for search results
  def format_user_display_name(user)
    "#{user.username} (#{user.name})"
  end

  # Checks if search has been performed
  def search_performed?(search_term)
    search_term.present?
  end

  # Returns appropriate message when no search term is provided
  def search_prompt_message
    "Enter a username to search for friends."
  end
end
