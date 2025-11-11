class PerformancesController < ApplicationController

  def show
    id = params[:id]
    @event = Event.find(id)
  end

  def index
    #render plain: "Hello, this is the Performances index page!"

    @all_styles = Event.distinct.pluck(:style)

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
  end

  def like 
    @event = Event.find(params[:id])
    current_user.liked_events << @event unless current_user.liked_events.include?(@event)
    redirect_back(fallback_location: performances_path, notice: "Event liked!")
  end 
  def unlike
    @event = Event.find(params[:id])
    current_user.liked_events.delete(@event)
    redirect_back(fallback_location: performances_path, notice: "Event unliked!")
    #redirect_to performances_path, notice: "Event unliked!"
  end
  def liked_events
    @events = current_user.liked_events
  end 
  def going_and_calendar
    @event = Event.find(params[:id])

    # Track user as going
    GoingEvent.find_or_create_by(user: current_user, event: @event)

    redirect_to details_performance_path(@event, show_calendar_button: true), notice: "You're going!"
  end

  private

  def numeric_price(price_value)
    return 0 if price_value.nil?
    if price_value.is_a?(Numeric)
      price_value
    else
      price_value.to_s.gsub(/[^0-9\.]/, '').to_f
    end
  end

  def event_params
    params.require(:event).permit(:name, :venue, :date, :time, :style, :location, :borough, :price, :description, :tickets)
  end
end
