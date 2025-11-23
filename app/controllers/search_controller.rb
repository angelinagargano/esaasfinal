class SearchController < ApplicationController
    def find_friends
        if params[:username].present?
            @users = User.where("username LIKE ?", "%#{params[:username]}%")
        else 
            @user = []
        end
        respond_to do |format|
            format.html # renders find_friends.html.erb
        end
    end
end
