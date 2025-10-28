class PreferencesController < ApplicationController
  def index
    # Add your preferences form display logic here
  end

  def update
    # Add your preferences update logic here
    redirect_to root_path, notice: 'Preferences updated successfully'
  end
end