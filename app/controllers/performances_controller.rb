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

    @events = Event.where(style: @styles_to_show)
    @events = @events.order(@sort_by) if @sort_by.present?
  end

  def new
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
