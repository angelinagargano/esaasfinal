class PerformancesController < ApplicationController

  def show
    id = params[:id]
    @event = Event.find(id)
  end

  def index
    @all_styles = Event.distinct.pluck(:style)

    # Start with all events
    @events = Event.all

    # Apply saved preferences from session (multi-select)
    prefs = session[:preferences] || {}

    # Filter by performance_type (style)
    if prefs['performance_type'].present? && !prefs['performance_type'].include?('No Preference')
      @events = @events.where(style: prefs['performance_type'])
    end

    # Filter by location/distance
    if prefs['location'].present? && !prefs['location'].include?('No Preference')
      # You might implement actual distance filtering here. For now, simple substring match:
      @events = @events.where('location LIKE ANY (array[?])', prefs['location'].map { |l| "%#{l}%" })
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

    # Convert back to ActiveRecord::Relation if needed
    @events = Event.where(id: @events.map(&:id)) if @events.is_a?(Array)

    # Apply sorting if requested
    if params[:sort_by].present?
      @sort_by = params[:sort_by]
      session[:sort_by] = @sort_by
      @events = @events.order(@sort_by)
    elsif session[:sort_by].present?
      @sort_by = session[:sort_by]
      @events = @events.order(@sort_by)
    end
  end


  def new
  end

  def details
    @event = Event.find(params[:id])
    flash.now[:notice] = params[:viewed_tickets_message] if params[:viewed_tickets_message].present?
  end

  private

  # helper to parse price values stored as strings like "$35" or numeric
  def numeric_price(price_value)
    return 0 if price_value.nil?
    if price_value.is_a?(Numeric)
      price_value
    else
      price_value.to_s.gsub(/[^0-9\.]/, '').to_f
    end
  end

  def event_params
    params.require(:event).permit(:name, :venue, :date, :time, :style, :location, :price, :description, :tickets)
  end
end
