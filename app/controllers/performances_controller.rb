class PerformancesController < ApplicationController

  def show
    id = params[:id]
    @event = Event.find(id)
  end

  def index
    @all_styles = Event.distinct.pluck(:style)

    if params[:styles]
      @styles_to_show = params[:styles].keys || @all_styles
      session[:styles] = params[:styles]
    else
      @styles_to_show = session[:styles]&.keys || @all_styles
    end

    if params[:sort_by]
      @sort_by = params[:sort_by]
      session[:sort_by] = params[:sort_by]
    else
      @sort_by = session[:sort_by]
    end

    # Start with style-based filtering from existing UI (checkboxes)
    @events = Event.where(style: @styles_to_show)

    # Apply saved preferences (if any) from session
    prefs = session[:preferences] || {}

    if prefs['performance_type'].present? && prefs['performance_type'] != 'No Preference'
      # match performance_type to style field
      @events = @events.where(style: prefs['performance_type'])
    end

    if prefs['location'].present? && prefs['location'] != 'No Preference'
      # simple location match (exact or substring depending on stored data)
      @events = @events.where('location LIKE ?', "%#{prefs['location']}%")
    end

    if prefs['budget'].present? && prefs['budget'] != 'No Preference'
      # Map feature labels like "$0–$25" to numeric ranges
      case prefs['budget']
      when '$0–$25'
        @events = @events.select { |e| numeric_price(e.price) <= 25 }
      when '$25–$50'
        @events = @events.select { |e| (25..50).cover?(numeric_price(e.price)) }
      when '$50–$100'
        @events = @events.select { |e| (50..100).cover?(numeric_price(e.price)) }
      when '$100+'
        @events = @events.select { |e| numeric_price(e.price) > 100 }
      end

      # convert Enumerable back to ActiveRecord::Relation when possible
      @events = Event.where(id: @events.map(&:id)) if @events.respond_to?(:map)
    end

    @events = @events.order(@sort_by) if @sort_by.present?
  end

  def new
  end

  # helper to parse price values stored as strings like "$35" or numeric
  def numeric_price(price_value)
    return 0 if price_value.nil?
    if price_value.is_a?(Numeric)
      price_value
    else
      price_value.to_s.gsub(/[^0-9\.]/, '').to_f
    end
  end

  def create
    @event = Event.create!(event_params)
    flash[:notice] = "#{@event.name} was successfully created."
    redirect_to performances_path
  end

  def edit
    @event = Event.find params[:id]
  end

  def update
    @event = Event.find params[:id]
    @event.update!(event_params)
    flash[:notice] = "#{@event.name} was successfully updated."
    redirect_to performance_path(@event)
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    flash[:notice] = "Event '#{@event.name}' deleted."
    redirect_to performances_path
  end

  private

  def event_params
    params.require(:event).permit(:name, :venue, :date, :time, :style, :location, :price, :description, :tickets)
  end
end
