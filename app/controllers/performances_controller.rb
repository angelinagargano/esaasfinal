class PerformancesController < ApplicationController

  def index
    styles = Event.distinct.pluck(:style)
    @all_styles = styles.compact.sort
    @boroughs = Event.distinct.pluck(:borough).compact.reject(&:blank?).sort

    # Start with all events
    @events = Event.all

    # Generate recommendations if user is logged in
    if logged_in?
      @recommended_events = generate_recommendations
    else
      @recommended_events = []
    end

    # Apply saved preferences from session 
    prefs = session[:preferences] || {}

    # Filter by performance_type 
    if prefs['performance_type'].present? && prefs['performance_type'].is_a?(Array) && !prefs['performance_type'].include?('No Preference')
      @events = @events.where(style: prefs['performance_type'])
    end

    # Filter by borough
    if prefs['borough'].present? && prefs['borough'].is_a?(Array) && !prefs['borough'].include?('No Preference')
      @events = @events.where(borough: prefs['borough'])
    end

    # Filter by location
    if prefs['location'].present? && prefs['location'].is_a?(Array) && !prefs['location'].include?('No Preference')
      @events = @events.where(location: prefs['location'])
    end

    # Filter by budget
    if prefs['budget'].present? && !prefs['budget'].include?('No Preference')
      @events = @events.select do |e|
        prefs['budget'].any? do |budget|
          case budget
          when '$0–$25'
            numeric_price(e.price) <= 25
          when '$25–$50'
            (25..50).cover?(numeric_price(e.price))
          when '$50–$100'
            (50..100).cover?(numeric_price(e.price))
          when '$100+'
            numeric_price(e.price) > 100
          end
        end
      end
    end

    # Filter by date range or specific date
    if params[:date_filter_start].present? || params[:date_filter_end].present?
      # Convert to array if it's still a relation
      events_array = @events.is_a?(Array) ? @events : @events.to_a
      
      @events = events_array.select do |e|
        begin
          event_date = Date.parse(e.date)
          
          # If both start and end dates are provided, filter by range
          if params[:date_filter_start].present? && params[:date_filter_end].present?
            start_date = Date.parse(params[:date_filter_start])
            end_date = Date.parse(params[:date_filter_end])
            event_date >= start_date && event_date <= end_date
          # If only start date is provided, filter for events from that date onwards
          elsif params[:date_filter_start].present?
            start_date = Date.parse(params[:date_filter_start])
            event_date >= start_date
          # If only end date is provided, filter for events up to that date
          elsif params[:date_filter_end].present?
            end_date = Date.parse(params[:date_filter_end])
            event_date <= end_date
          end
        rescue
          false
        end
      end
    end

    # Convert to ActiveRecord relation if it's an array (from budget or date filtering)
    if @events.is_a?(Array)
      event_ids = @events.map(&:id)
      @events = event_ids.any? ? Event.where(id: event_ids) : Event.none
    end

  # Apply sorting if requested
    if params[:sort_by].present?
      @sort_by = params[:sort_by]
      session[:sort_by] = @sort_by
    elsif session[:sort_by].present?
      @sort_by = session[:sort_by]
    end
    
    if @sort_by.present?
      if @sort_by == 'date'
        # Sort by date chronologically by parsing the date strings
        @events = @events.to_a.sort_by do |event|
          begin
            Date.parse(event.date)
          rescue
            Date.new(9999, 12, 31) # Put invalid dates at the end
          end
        end
      else
        @events = @events.order(@sort_by)
      end
    end
  end


  def new
  end

  def details
    @event = Event.find(params[:id])
    flash.now[:notice] = params[:viewed_tickets_message] if params[:viewed_tickets_message].present?
    
    # Load friends attending this event
    if logged_in?
      # Get all accepted friends (outgoing and incoming)
      friends = current_user.all_friends
      
      # Get friends who are going to this event
      @friends_going = friends.select { |friend| friend.going_events_list.include?(@event) }
    else
      @friends_going = []
    end
  end

  def like 
    @event = Event.find(params[:id])
    current_user.liked_events << @event unless current_user.liked_events.include?(@event)
    
    respond_to do |format|
      format.html { redirect_to request.referer.to_s.split('#').first + "#event-#{@event.id}", notice: "Event liked!" }
      format.js
    end
  end 
  
  def unlike
    @event = Event.find(params[:id])
    current_user.liked_events.delete(@event)
    respond_to do |format|
      format.html { redirect_to request.referer.to_s.split('#').first + "#event-#{@event.id}", notice: "Event unliked!" }
      format.js
    end
  end
  
  def liked_events
    @events = current_user.liked_events || []
  end 

  def going_and_calendar
    @event = Event.find(params[:id])

    # Track user as going
    GoingEvent.find_or_create_by(user: current_user, event: @event)

    redirect_to details_performance_path(@event, show_calendar_button: true), notice: "You're going!"
  end

  def share_to_message
    @event = Event.find(params[:id])
    friend_id = params[:friend_id]
    
    if friend_id.present?
      # Share to direct message
      friend = User.find(friend_id)
      
      # Verify they are friends
      unless current_user.all_friends.include?(friend)
        flash[:alert] = "You can only share events with friends."
        redirect_back(fallback_location: details_performance_path(@event)) and return
      end
      
      # Find or create conversation
      conversation = Conversation.find_or_create_by(
        user1: [current_user, friend].min_by(&:id),
        user2: [current_user, friend].max_by(&:id)
      )
      
      # Check if this event was already shared by current user in this conversation
      existing_message = conversation.messages
                                     .joins(:message_events)
                                     .where(sender: current_user)
                                     .where(message_events: { event_id: @event.id })
                                     .order(created_at: :desc)
                                     .first
      
      if existing_message
        # Update the existing message instead of creating a new one
        existing_message.update!(
          content: params[:message].presence || existing_message.content,
          created_at: Time.current
        )
        conversation.update_last_message_at!
        
        flash[:notice] = "Event share updated!"
        redirect_to conversation_path(conversation)
      else
        # Create message with event (first time sharing)
        message = conversation.messages.create!(
          sender: current_user,
          content: params[:message] || "Check out this event!"
        )
        message.message_events.create!(event: @event)
        
        flash[:notice] = "Event shared in message!"
        redirect_to conversation_path(conversation)
      end
    else
      flash[:alert] = "Please select a friend to share with."
      redirect_back(fallback_location: details_performance_path(@event))
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :venue, :date, :time, :style, :location, :borough, :price, :description, :tickets)
  end

  def numeric_price(price_value)
    return 0 if price_value.nil?
    price_value.to_s.gsub(/[^0-9\.]/, '').to_f
  end

  def generate_recommendations
    # Get user's liked and going events
    liked_events = current_user.liked_events
    going_events = current_user.going_events_list
    user_interested_events = (liked_events + going_events).uniq

    return [] if user_interested_events.empty?

    # Collect styles, boroughs, and locations from user's interested events
    preferred_styles = user_interested_events.map(&:style).compact.uniq
    preferred_boroughs = user_interested_events.map(&:borough).compact.uniq
    preferred_locations = user_interested_events.map(&:location).compact.uniq

    # Find events that match user preferences but aren't already liked or going
    all_recommendations = Event.where.not(id: user_interested_events.map(&:id))
                          .where('style IN (?) OR borough IN (?) OR location IN (?)', 
                                preferred_styles, preferred_boroughs, preferred_locations)
                          .to_a

    # If refresh_recommendations param is present, randomize the order
    if params[:refresh_recommendations].present?
      all_recommendations.shuffle.first(6)
    else
      # Otherwise show the first 6
      all_recommendations.first(6)
    end
  end
end