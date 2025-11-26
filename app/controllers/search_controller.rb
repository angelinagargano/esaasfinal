class SearchController < ApplicationController
    def find_friends
            if params[:username].present? && current_user.present?
        # Use where.not(id: current_user.id) to exclude the current user
        @users = User.where("username LIKE ?", "%#{params[:username]}%")
                    .where.not(id: current_user.id)
        elsif params[:username].present?
        # Handle case where user is not logged in but performing a search
        @users = User.where("username LIKE ?", "%#{params[:username]}%")
        else
        @users = [] # Or handle the empty search case as appropriate for your app
        end
        respond_to do |format|
            format.html # renders find_friends.html.erb
        end
    end
end
