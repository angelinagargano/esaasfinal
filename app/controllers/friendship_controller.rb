class FriendshipController < ApplicationController
    def create 
        @friend = User.find(params[:id])
        # preventing duplicate friend request or befriending oneself
        if @friend == current_user || Friendship.exists?(user: current_user, friend: @friend) || Friendship.exists?(user: @friend, friend: current_user)
            flash[:alert] = "Unable to send friend request."
        end
        @friendship = Friendship.new(user: current_user, friend: @friend, status: false)
        if @friendship.save
            flash[:notice] = "Friend request sent."
        else
            flash[:alert] = "Unable to send friend request."
        end
        #redirect_back(fallback_location: find_friends_search_path)
    end
    #accepting friend request
    def accept 
        @friendship = current_user.inverse_friendships.find_by(user_id: params[:id])
        if @friendship
            @friendship.update(status: true)
            flash[:notice] = "Friend request accepted."
        else
            flash[:alert] = "Unable to accept friend request."
        end
    end 
    #rejecting friend request 
    def reject
        @friendship = current_user.inverse_friendships.find_by(user_id: params[:id])
        if @friendship
            @friendship.destroy
            flash[:notice] = "Friend request rejected."
        else
            flash[:alert] = "Unable to reject friend request."
        end
    end
    # unfriending a friend
    def unfriend
        @friendship = current_user.friendships.find_by(friend_id: params[:id]) || current_user.inverse_friendships.find_by(user_id: params[:id])
        if @friendship
            @friendship.destroy
            flash[:notice] = "Unfriended successfully."
        else
            flash[:alert] = "Unable to unfriend."
        end
    end

end