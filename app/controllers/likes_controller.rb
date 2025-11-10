# app/controllers/likes_controller.rb
class LikesController < ApplicationController
  before_action :require_login

  def create
    event = Event.find(params[:event_id])
    current_user.liked_events << event unless current_user.liked_events.include?(event)
    redirect_back fallback_location: performances_path
  end

  def destroy
    event = Event.find(params[:event_id])
    current_user.liked_events.delete(event)
    redirect_back fallback_location: performances_path
  end

  private

  def require_login
    unless current_user
      redirect_to root_path, alert: "You must be logged in to do that."
    end
  end
end
