require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "POST #create" do
    it "renders new with errors if user not saved" do
      post :create, params: { user: { email: "", name: "", username: "", password: "", password_confirmation: "" } }

      expect(response).to have_http_status(:ok)
      expect(flash[:alert]).to include("can't be blank")
    end
  end

  describe "GET #profile" do
    it "redirects to login when user is not logged in" do
      get :profile, params: { id: 123 }
      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("Please log in first")
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
