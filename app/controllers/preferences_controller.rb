class PreferencesController < ApplicationController
  def show
    @budget_options = [
      '$0–$25',
      '$25–$50',
      '$50–$100',
      '$100+',
      'No Preference'
    ]

    @performance_type_options = [
      'Hip-hop',
      'Ballet',
      'Swing',
      'Contemporary',
      'Dance Theater',
      'No Preference'
    ]

    @borough_options = [
      'Manhattan',
      'Brooklyn',
      'Queens',
      'Staten Island',
      'No Preference'
    ]

    @location_options = Event.distinct.pluck(:location).compact.sort
    @location_options << 'No Preference' if @location_options.exclude?('No Preference')

    if session[:preferences].nil?
      @preferences = {
        'budget' => [],
        'performance_type' => [],
        'borough' => [],
        'location' => []
      }
    else
      @preferences = session[:preferences]
    end
  end

  def create
    prefs = {
      'budget' => Array(params[:budget]).compact,
      'performance_type' => Array(params[:performance_type]).compact,
      'borough' => Array(params[:borough]).compact,
      'location' => Array(params[:location]).compact
    }

    if prefs['budget'].blank? && prefs['performance_type'].blank?
      flash[:alert] = 'Please select at least one preference before continuing'
      redirect_to preferences_path and return
    end

    if prefs['performance_type'].blank?
      flash[:alert] = 'Please select at least one performance type'
      redirect_to preferences_path and return
    end

    # If "No Preference" is selected, keep only "No Preference" and remove all other selections
    ['budget', 'performance_type', 'borough', 'location'].each do |key|
      if prefs[key].include?('No Preference')
        prefs[key] = ['No Preference']
      elsif prefs[key].blank?
        prefs[key] = ['No Preference']
      end
    end

    session[:preferences] = prefs
    flash[:notice] = 'Preferences saved.'
    redirect_to performances_path
  end


  def clear
    session.delete(:preferences)
    flash[:notice] = 'Preferences cleared.'
    redirect_to preferences_path
  end
end

