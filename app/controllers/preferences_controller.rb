class PreferencesController < ApplicationController
  def show
    @budget_options = [
      '$0–$25',
      '$25–$50',
      '$50–$100',
      '$100+',
      'No Preference'
    ]

    @distance_options = [
      'Within 2mi',
      'Within 5mi',
      'Within 10mi',
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
    @location_options << 'No Preference' unless @location_options.include?('No Preference')

    # Initialize preferences with "No Preference" defaults for first-time users
    if session[:preferences].nil?
      @preferences = {
        'budget' => ['No Preference'],
        'performance_type' => ['No Preference'],
        'borough' => ['No Preference'],
        'location' => ['No Preference']
      }
    else
      @preferences = session[:preferences]
    end
    
    #@preferences = session[:preferences] || {}
  end

  def create
    prefs = {
      'budget' => params[:budget] || [],
      'performance_type' => params[:performance_type] || [],
      'borough' => params[:borough] || [],
      'location' => params[:location] || []
    }

    prefs['budget'] = ['No Preference'] if prefs['budget'].include?('No Preference')
    prefs['performance_type'] = ['No Preference'] if prefs['performance_type'].include?('No Preference')
    prefs['borough'] = ['No Preference'] if prefs['borough'].include?('No Preference')
    prefs['location'] = ['No Preference'] if prefs['location'].include?('No Preference')

    if prefs['budget'].blank? && prefs['performance_type'].blank? && prefs['borough'].blank? && prefs['location'].blank?
      flash[:error] = 'Please select at least one preference before continuing'
      redirect_to preferences_path and return
    end

    if prefs['performance_type'].blank?
      flash[:alert] = 'Please select at least one performance type'
      redirect_to preferences_path and return
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

