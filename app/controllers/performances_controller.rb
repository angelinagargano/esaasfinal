class PerformancesController < ApplicationController

  def index
    styles = Event.distinct.pluck(:style)
    @all_styles = styles.compact.sort
    @boroughs = Event.distinct.pluck(:borough).compact.reject(&:blank?).sort

    # Start with all events
    @events = Event.all

    # Apply saved preferences from session 
    prefs = session[:preferences] || {}

    # Filter by performance_type 
    if prefs['performance_type'].present? && !prefs['performance_type'].include?('No Preference')
      @events = @events.where(style: prefs['performance_type'])
    end

    # Filter by borough
    if prefs['borough'].present? && !prefs['borough'].include?('No Preference')
      @events = @events.where(borough: prefs['borough'])
    end

    # Filter by location
    if prefs['location'].present? && !prefs['location'].include?('No Preference')
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
      @events = @events.select do |e|
        begin
          event_date = Date.parse(e.date)
          
          # If both start and end dates are provided, filter by range
          if params[:date_filter_start].present? && params[:date_filter_end].present?
            start_date = Date.parse(params[:date_filter_start])
            end_date = Date.parse(params[:date_filter_end])
            event_date >= start_date && event_date <= end_date
          # If only start date is provided, filter for exact date
          elsif params[:date_filter_start].present?
            start_date = Date.parse(params[:date_filter_start])
            event_date == start_date
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

    # Convert to ActiveRecord relation if it's an array (from budget filtering)
    if @events.is_a?(Array)
      event_ids = @events.map(&:id)
      @events = event_ids.any? ? Event.where(id: event_ids) : Event.none
    end
    
    # Ensure @events is always set, even if empty
    @events ||= Event.none

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
      accepted_outgoing = current_user.friendships.where(status: true).includes(:friend).map(&:friend)
      accepted_incoming = current_user.inverse_friendships.where(status: true).includes(:user).map(&:user)
      friends = (accepted_outgoing + accepted_incoming).uniq
      
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

  private

  def event_params
    params.require(:event).permit(:name, :venue, :date, :time, :style, :location, :borough, :price, :description, :tickets)
  end

  def numeric_price(price_value)
    return 0 if price_value.nil?
    if price_value.is_a?(Numeric)
      price_value
    else
      price_value.to_s.gsub(/[^0-9\.]/, '').to_f
    end
  end
end
