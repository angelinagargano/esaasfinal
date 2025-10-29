class PreferencesController < ApplicationController
  def show
    # options for selects — use the exact strings expected by the feature specs
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

    # load existing session values if present
    @preferences = session[:preferences] || {}
  end

  def create
    prefs = {
      'budget' => params[:budget] || [],
      'performance_type' => params[:performance_type] || []
    }

    # Handle "No Preference" logic
    prefs['budget'] = ['No Preference'] if prefs['budget'].include?('No Preference')
    prefs['performance_type'] = ['No Preference'] if prefs['performance_type'].include?('No Preference')

    # Validation: ensure at least one preference is present
    if prefs['budget'].blank? && prefs['performance_type'].blank?
      flash[:error] = 'Please select at least one preference before continuing'
      redirect_to preferences_path and return
    end

    # Additional validation for performance_type
    if prefs['performance_type'].blank?
      flash[:alert] = 'Please select at least one performance type'
      redirect_to preferences_path and return
    end

    # Save valid preferences
    session[:preferences] = prefs
    flash[:notice] = 'Preferences saved.'
    redirect_to root_path
  end


  def clear
    session.delete(:preferences)
    flash[:notice] = 'Preferences cleared.'
    redirect_to preferences_path
  end
end