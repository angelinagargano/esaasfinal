# app/controllers/preferences_controller.rb (CORRECTED)

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
      'HipHop',
      'Ballet',
      'Tap',
      'Modern',
      'No Preference'
    ]

    # keep a location list matching common values used in tests
    @location_options = ['No Preference', 'Brooklyn', 'Manhattan', 'Queens', 'Bronx', 'Staten Island']

    # load existing session values if present
    @preferences = session[:preferences] || {}
  end

  def create
    prefs = {
      'budget' => params[:budget],
      'distance' => params[:distance],
      'performance_type' => params[:performance_type],
      'location' => params[:location]
    }

    # Validation: only treat truly blank (nil/empty) selections as missing.
    # If the user explicitly selects 'No Preference' for fields, that counts as a valid choice.
    primary_prefs = [prefs['budget'], prefs['distance'], prefs['performance_type']]

    all_blank = primary_prefs.all? { |v| v.blank? }

    if all_blank
      # Uses flash[:error] to match the BDD step "I should see an error message"
      flash[:error] = 'Please select at least one preference before continuing'
      redirect_to preferences_path and return
    end
    # --------------------------------------------------------------------------------------

    # --- FIX 2: Validation for "Saving without selecting a performance type" ---
    # Check if performance_type is blank (i.e., not selected) at all.
    # Note: If 'No Preference' is explicitly selected, this check is skipped.
    if prefs['performance_type'].blank?
      flash[:alert] = 'Please select at least one performance type'
      redirect_to preferences_path and return
    end
    # --------------------------------------------------------------------------------------

    # Valid preferences — save and redirect to home
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