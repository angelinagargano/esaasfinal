class FriendshipsController < ApplicationController
    def create 
        friend_id = params[:friend_id] || params[:id]
        @friend = User.find(friend_id)
        # preventing duplicate friend request or befriending oneself
        if @friend == current_user || Friendship.exists?(user: current_user, friend: @friend) || Friendship.exists?(user: @friend, friend: current_user)
            flash[:alert] = "Unable to send friend request."
        else
            @friendship = Friendship.new(user: current_user, friend: @friend, status: false)
            if @friendship.save
                flash[:notice] = "Friend request sent."
            else
                flash[:alert] = "Unable to send friend request."
            end
        end
        redirect_back(fallback_location: find_friends_search_path)
    end
    #accepting friend request
    def accept 
        friend_id = params[:friend_id] || params[:id]
        @friendship = current_user.inverse_friendships.find_by(user_id: friend_id)
        if @friendship
            if @friendship.update(status: true)
                flash[:notice] = "Friend request accepted."
            else
                flash[:alert] = "Unable to accept friend request."
            end
        else
            flash[:alert] = "Unable to accept friend request."
        end
        redirect_back(fallback_location: user_profile_path(current_user))
    end 
    #rejecting friend request 
    def reject
        friend_id = params[:friend_id] || params[:id]
        @friendship = current_user.inverse_friendships.find_by(user_id: friend_id)
        if @friendship
            @friendship.destroy
            flash[:notice] = "Friend request rejected."
        else
            flash[:alert] = "Unable to reject friend request."
        end
        redirect_back(fallback_location: user_profile_path(current_user))
    end
    # unfriending a friend
    def unfriend
        friend_id = params[:friend_id] || params[:id]
        @friendship = current_user.friendships.find_by(friend_id: friend_id) || current_user.inverse_friendships.find_by(user_id: friend_id)
        if @friendship
            @friendship.destroy
            flash[:notice] = "Unfriended successfully."
        else
            flash[:alert] = "Unable to unfriend."
        end
        redirect_back(fallback_location: user_profile_path(current_user))
    end

end