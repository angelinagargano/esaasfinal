require 'rails_helper'

RSpec.describe PreferencesController, type: :controller do
  describe "GET #show" do
    it "renders the show template" do
      get :show
      expect(response).to have_http_status(:ok)
    end

    it "loads existing preferences from session" do
      existing_prefs = {
        'budget' => ['$25–$50'],
        'performance_type' => ['Ballet'],
        'borough' => ['Manhattan'],
        'location' => ['Lincoln Center']
      }
      session[:preferences] = existing_prefs
      get :show
      expect(assigns(:preferences)).to eq(existing_prefs)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE #clear" do
    it "clears preferences and redirects" do
      session[:preferences] = { 'budget' => ['$0–$25'] }
      delete :clear
      expect(session[:preferences]).to be_nil
      expect(response).to redirect_to(preferences_path)
      expect(flash[:notice]).to eq('Preferences cleared.')
    end
  end
end

