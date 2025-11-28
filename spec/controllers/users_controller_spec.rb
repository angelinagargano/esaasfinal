require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    it "renders new with errors if user not saved" do
      post :create, params: { user: { email: "", name: "", username: "", password: "", password_confirmation: "" } }

      expect(response).to have_http_status(:ok)
      expect(flash[:alert]).to include("can't be blank")
    end

    it "creates user and redirects to preferences on success" do
      post :create, params: { 
        user: { 
          email: 'new@example.com', 
          name: 'New User', 
          username: 'newuser', 
          password: 'password123', 
          password_confirmation: 'password123' 
        } 
      }
      expect(response).to redirect_to(preferences_path)
      expect(flash[:notice]).to eq('Account created successfully! Please set your preferences.')
      expect(session[:user_id]).to be_present
    end
  end

  describe "GET #profile" do
    it "redirects to login when user is not logged in" do
      get :profile, params: { id: 123 }
      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("Please log in first")
    end

    let(:user) { User.create!(email: "a@x.com", name: "A", username: "alpha", password: "pw12345", password_confirmation: "pw12345") }

    context "when logged in" do
      before { allow(controller).to receive(:current_user).and_return(user) }

      it "renders profile template when logged in" do
        get :profile, params: { id: user.id }
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to eq(user)
      end

      it "loads liked events" do
        event = Event.create!(name: "Test", style: "Ballet", borough: "Manhattan", location: "Test", price: "$20", date: "2025-12-01")
        user.liked_events << event
        get :profile, params: { id: user.id }
        expect(assigns(:liked_events)).to include(event)
      end

      it "loads going events" do
        event = Event.create!(name: "Test", style: "Ballet", borough: "Manhattan", location: "Test", price: "$20", date: "2025-12-01")
        GoingEvent.create!(user: user, event: event)
        get :profile, params: { id: user.id }
        expect(assigns(:going_events)).to include(event)
      end

      it "loads friends" do
        friend = User.create!(email: "b@x.com", name: "B", username: "beta", password: "pw12345", password_confirmation: "pw12345")
        Friendship.create!(user: user, friend: friend, status: true)
        get :profile, params: { id: user.id }
        expect(assigns(:friends)).to include(friend)
      end
    end
  end

  describe "PATCH #update" do
    let(:user) { User.create!(email: "a@x.com", name: "A", username: "alpha", password: "pw12345", password_confirmation: "pw12345") }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "renders edit with errors if update fails" do
      patch :update, params: { id: user.id, user: { email: "" } }

      expect(response).to have_http_status(:ok)
      expect(flash[:alert]).to include("can't be blank")
    end

    it "updates user successfully" do
      patch :update, params: { id: user.id, user: { name: "Updated Name" } }
      expect(user.reload.name).to eq("Updated Name")
      expect(response).to redirect_to(user_profile_path(user))
      expect(flash[:notice]).to eq('Your information was successfully updated.')
    end

    it "allows updating without password" do
      patch :update, params: { id: user.id, user: { name: "New Name", password: "", password_confirmation: "" } }
      expect(user.reload.name).to eq("New Name")
    end

    it "updates password when provided" do
      patch :update, params: { id: user.id, user: { password: "newpassword123", password_confirmation: "newpassword123" } }
      expect(user.reload.authenticate("newpassword123")).to be_truthy
    end
  end

  describe "GET #edit" do
    let(:user) { User.create!(email: "a@x.com", name: "A", username: "alpha", password: "pw12345", password_confirmation: "pw12345") }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "renders edit template" do
      get :edit, params: { id: user.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "GET #show" do
    it "redirects to the user's profile path" do
      # Stub the path helper because route :show does not exist
      allow(controller).to receive(:user_profile_path).with("0").and_return("/users/0/profile")
      expect(controller).to receive(:redirect_to).with("/users/0/profile")
      # Directly call the action
      controller.params[:id] = "0"
      controller.show

     #expect(response).to redirect_to("/users/0/profile")
    end
  end
end
