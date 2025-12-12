require 'rails_helper'

RSpec.describe PerformancesController, type: :controller do
  let!(:event1) { Event.create!(style: 'Ballet', borough: 'Manhattan', location: 'Lincoln Center', price: '$20', date: '2025-12-01', name: 'Ballet Show', venue: 'Venue 1', time: '19:00') }
  let!(:event4) { Event.create!(style: 'Modern', borough: 'Brooklyn', location: 'Kings Theater', price: '$30', date: '2025-12-03', name: 'Modern Dance', venue: 'Venue 4', time: '19:00') }
  let!(:event2) { Event.create!(style: 'Hip Hop', borough: 'Brooklyn', location: 'Barclays Center', price: '$60', date: '2025-12-05', name: 'Hip Hop Night', venue: 'Venue 2', time: '19:00') }
  let!(:event3) { Event.create!(style: 'Jazz', borough: 'Queens', location: 'Flushing Town Hall', price: '$120', date: '2025-12-10', name: 'Jazz Festival', venue: 'Venue 3', time: '19:00') }
  let!(:event5) { Event.create!(style: 'Hip Hop', borough: 'Manhattan', location: 'Apollo Theater', price: '$45', date: '2025-12-15', name: 'Hip Hop Showcase', venue: 'Venue 5', time: '20:00') }
  let!(:event6) { Event.create!(style: 'Ballet', borough: 'Brooklyn', location: 'BAM', price: '$55', date: '2025-12-20', name: 'Brooklyn Ballet', venue: 'Venue 6', time: '18:00') }

  describe 'GET #index' do
    it 'filters by borough' do
      session[:preferences] = { 'borough' => ['Manhattan'] }
      get :index
      expect(assigns(:events).pluck(:borough).uniq).to eq(['Manhattan'])
    end

    it 'filters by location' do
      session[:preferences] = { 'location' => ['Barclays Center'] }
      get :index
      expect(assigns(:events).pluck(:location)).to eq(['Barclays Center'])
    end

    it 'filters by budget $0–$25' do
      session[:preferences] = { 'budget' => ['$0–$25'] }
      get :index
      expect(assigns(:events).pluck(:price)).to include('$20')
      expect(assigns(:events).pluck(:price)).not_to include('$60', '$120')
    end

    it 'filters by budget $25–$50' do
      session[:preferences] = { 'budget' => ['$25–$50'] }
      get :index
      expect(assigns(:events).pluck(:price)).not_to include('$20') 
      expect(assigns(:events).pluck(:price)).to include('$30')
      expect(assigns(:events).pluck(:price)).not_to include('$120')
    end

    it 'filters by budget $50–$100' do
      session[:preferences] = { 'budget' => ['$50–$100'] }
      get :index
      expect(assigns(:events).pluck(:price)).to include('$60')
      expect(assigns(:events).pluck(:price)).not_to include('$20', '$120')
    end

    it 'filters by budget $100+' do
      session[:preferences] = { 'budget' => ['$100+'] }
      get :index
      expect(assigns(:events).pluck(:price)).to include('$120')
      expect(assigns(:events).pluck(:price)).not_to include('$20', '$60')
    end

    it 'returns Event.none when budget filter matches no events' do
      session[:preferences] = { 'budget' => ['$100+'] }
      # Delete all events with price > 100
      Event.where("CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS FLOAT) > 100").delete_all
      get :index
      expect(assigns(:events)).to be_empty
      expect(assigns(:events).to_a).to eq([])
    end

    it 'filters by date range' do
      get :index, params: { date_filter_start: '2025-12-01', date_filter_end: '2025-12-05' }
      expect(assigns(:events).pluck(:date)).to include('2025-12-01', '2025-12-05')
      expect(assigns(:events).pluck(:date)).not_to include('2025-12-10')
    end

    it 'filters by single date' do
      get :index, params: { date_filter_start: '2025-12-05' }
      expect(assigns(:events).pluck(:date)).to include('2025-12-05', '2025-12-10')
      expect(assigns(:events).pluck(:date)).not_to include('2025-12-01', '2025-12-03')
    end

    it 'filters by end date only' do
      get :index, params: { date_filter_end: '2025-12-05' }
      expect(assigns(:events).pluck(:date)).to include('2025-12-01', '2025-12-05')
      expect(assigns(:events).pluck(:date)).not_to include('2025-12-10')
    end

    it 'sorts by date' do
      get :index, params: { sort_by: 'date' }
      dates = assigns(:events).map(&:date)
      expect(dates).to eq(dates.sort)
    end

    it 'orders by arbitrary column when requested' do
      get :index, params: { sort_by: 'style' }
      expect(assigns(:events).pluck(:style)).to eq(Event.order(:style).pluck(:style))
    end

    it 'respects saved sort_by when the param is missing' do
      session[:sort_by] = 'location'
      get :index
      expect(assigns(:sort_by)).to eq('location')
      expect(assigns(:events).pluck(:location)).to eq(Event.order(:location).pluck(:location))
    end

    context 'when an event has an invalid date' do
      let!(:event_with_invalid_date) do
        Event.create!(
          name: 'Mystery Performance',
          style: 'Experimental',
          borough: 'Bronx',
          location: 'Bronx Theater',
          price: '$45',
          date: 'not-a-valid-date',
          venue: 'Bronx Venue',
          time: '19:00'
        )
      end

      it 'ignores invalid dates when filtering by a date range' do
        get :index, params: { date_filter_start: '2025-12-01', date_filter_end: '2025-12-05' }
        expect(assigns(:events)).not_to include(event_with_invalid_date)
      end

      it 'pushes invalid dates to the end when sorting by date' do
        get :index, params: { sort_by: 'date' }
        expect(assigns(:events).last).to eq(event_with_invalid_date)
      end

      it 'handles invalid date when filtering by end date only' do
        # Create a valid event that would match the filter
        valid_event = Event.create!(name: 'Valid Event', style: 'Ballet', borough: 'Manhattan', location: 'Test', price: '$20', date: '2025-12-01', venue: 'Test Venue', time: '19:00')
        get :index, params: { date_filter_end: '2025-12-05' }
        # The invalid date event should be excluded due to rescue returning false
        expect(assigns(:events)).not_to include(event_with_invalid_date)
        expect(assigns(:events)).to include(valid_event)
      end

      it 'handles invalid date when filtering by start date only' do
        # Create a valid event that would match the filter
        valid_event = Event.create!(name: 'Valid Event', style: 'Ballet', borough: 'Manhattan', location: 'Test', price: '$20', date: '2025-12-05', venue: 'Test Venue', time: '19:00')
        get :index, params: { date_filter_start: '2025-12-01' }
        # The invalid date event should be excluded due to rescue returning false
        expect(assigns(:events)).not_to include(event_with_invalid_date)
        expect(assigns(:events)).to include(valid_event)
      end

      it 'handles invalid date in date range filter' do
        # Create a valid event that would match the filter
        valid_event = Event.create!(name: 'Valid Event', style: 'Ballet', borough: 'Manhattan', location: 'Test', price: '$20', date: '2025-12-03', venue: 'Test Venue', time: '19:00')
        get :index, params: { date_filter_start: '2025-12-01', date_filter_end: '2025-12-05' }
        # The invalid date event should be excluded due to rescue returning false
        expect(assigns(:events)).not_to include(event_with_invalid_date)
        expect(assigns(:events)).to include(valid_event)
      end
    end

    # Recommendations tests
    context 'recommendations' do
      let(:user) { User.create!(email: 'test@example.com', name: 'Test User', username: 'testuser', password: 'password123', password_confirmation: 'password123') }

      context 'when user is logged in' do
        before do
          session[:user_id] = user.id
        end

        context 'with liked events' do
          before do
            user.liked_events << event1  # Ballet in Manhattan
            user.liked_events << event2  # Hip Hop in Brooklyn
          end

          it 'generates recommendations based on liked events' do
            get :index
            expect(assigns(:recommended_events)).not_to be_empty
          end

          it 'does not include already liked events in recommendations' do
            get :index
            recommended_ids = assigns(:recommended_events).map(&:id)
            expect(recommended_ids).not_to include(event1.id)
            expect(recommended_ids).not_to include(event2.id)
          end

          it 'recommends events with matching styles' do
            get :index
            recommended_styles = assigns(:recommended_events).map(&:style)
            expect(recommended_styles & ['Ballet', 'Hip Hop']).not_to be_empty
          end

          it 'recommends events with matching boroughs' do
            get :index
            recommended_boroughs = assigns(:recommended_events).map(&:borough)
            expect(recommended_boroughs & ['Manhattan', 'Brooklyn']).not_to be_empty
          end

          it 'limits recommendations to 6 events' do
            get :index
            expect(assigns(:recommended_events).count).to be <= 6
          end
        end

        context 'with going events' do
          before do
            GoingEvent.create!(user: user, event: event1)
          end

          it 'generates recommendations based on going events' do
            get :index
            expect(assigns(:recommended_events)).not_to be_empty
          end

          it 'does not include events user is already going to' do
            get :index
            recommended_ids = assigns(:recommended_events).map(&:id)
            expect(recommended_ids).not_to include(event1.id)
          end
        end

        context 'with both liked and going events' do
          before do
            user.liked_events << event1
            GoingEvent.create!(user: user, event: event2)
          end

          it 'generates recommendations based on both liked and going events' do
            get :index
            expect(assigns(:recommended_events)).not_to be_empty
          end

          it 'excludes both liked and going events from recommendations' do
            get :index
            recommended_ids = assigns(:recommended_events).map(&:id)
            expect(recommended_ids).not_to include(event1.id, event2.id)
          end
        end

        context 'with no liked or going events' do
          it 'returns empty recommendations' do
            get :index
            expect(assigns(:recommended_events)).to be_empty
          end
        end

        context 'with refresh_recommendations parameter' do
          before do
            user.liked_events << event1
          end

          it 'includes recommendations when refresh parameter is present' do
            get :index, params: { refresh_recommendations: true }
            expect(assigns(:recommended_events)).not_to be_empty
          end
        end
      end

      context 'when user is not logged in' do
        it 'returns empty recommendations' do
          get :index
          expect(assigns(:recommended_events)).to eq([])
        end
      end
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#numeric_price' do
    it 'returns numeric inputs unchanged' do
      expect(controller.send(:numeric_price, 55)).to eq(55)
    end

    it 'returns 0 for nil input' do
      expect(controller.send(:numeric_price, nil)).to eq(0)
    end

    it 'converts string price to float' do
      expect(controller.send(:numeric_price, '$99.50')).to eq(99.5)
    end
  end

  describe 'GET #details' do
    let(:user) { User.create!(email: 'test@example.com', name: 'Test', username: 'testuser', password: 'password123', password_confirmation: 'password123') }
    let(:event) { Event.create!(style: 'Ballet', borough: 'Manhattan', location: 'Lincoln Center', price: '$20', date: '2025-12-01', name: 'Test Event', venue: 'Test Venue', time: '19:00') }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it 'renders details template' do
      get :details, params: { id: event.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:event)).to eq(event)
    end

    it 'sets flash notice when viewed_tickets_message is present' do
      get :details, params: { id: event.id, viewed_tickets_message: 'Tickets viewed' }
      expect(flash.now[:notice]).to eq('Tickets viewed')
    end
  end

  describe 'GET #liked_events' do
    let(:user) { User.create!(email: 'test@example.com', name: 'Test', username: 'testuser', password: 'password123', password_confirmation: 'password123') }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it 'returns empty array when user has no liked events' do
      get :liked_events
      expect(assigns(:events)).to eq([])
    end
  end

  describe '#event_params' do
    it 'permits the expected event fields' do
      allowed = {
        name: 'Exciting Show',
        venue: 'Grand Stage',
        date: '2025-12-01',
        time: '19:00',
        style: 'Jazz',
        location: 'Tribeca',
        borough: 'Manhattan',
        price: '$99',
        description: 'Big night',
        tickets: 'http://tickets.example.com'
      }
      get :index, params: { event: allowed.merge(secret: 'nope') }
      permitted = controller.send(:event_params)
      expect(permitted.to_h).to eq(allowed.transform_keys(&:to_s))
      expect(permitted.keys).not_to include('secret')
    end
  end

  describe 'POST #share_to_message' do
    let(:user1) do
      User.create!(
        email: 'user1@example.com',
        name: 'User One',
        username: 'user1',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    let(:user2) do
      User.create!(
        email: 'user2@example.com',
        name: 'User Two',
        username: 'user2',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    let(:event) { Event.create!(name: "Test Event", date: "2024-01-01", time: "19:00", venue: "Test Venue", location: "Test Location") }

    before do
      session[:user_id] = user1.id
      Friendship.create!(user: user1, friend: user2, status: true)
    end

    it 'shares event to message' do
      expect {
        post :share_to_message, params: { id: event.id, friend_id: user2.id, message: "Check this out!" }
      }.to change(Message, :count).by(1)
    end

    it 'creates message event' do
      expect {
        post :share_to_message, params: { id: event.id, friend_id: user2.id }
      }.to change(MessageEvent, :count).by(1)
    end

    it 'prevents sharing with non-friends' do
      user3 = User.create!(email: 'user3@example.com', name: 'User Three', username: 'user3', password: 'password123', password_confirmation: 'password123')
      post :share_to_message, params: { id: event.id, friend_id: user3.id }
      expect(flash[:alert]).to eq("You can only share events with friends.")
    end

    it 'handles missing friend_id' do
      post :share_to_message, params: { id: event.id }
      expect(flash[:alert]).to eq("Please select a friend to share with.")
      expect(response).to redirect_to(details_performance_path(event))
    end
  end

  describe '#generate_recommendations' do
    let(:user) { User.create!(email: 'test@example.com', name: 'Test User', username: 'testuser', password: 'password123', password_confirmation: 'password123') }

    before do
      session[:user_id] = user.id
    end

    it 'returns recommendations based on style matches' do
      user.liked_events << event1  # Ballet in Manhattan
      get :index
      
      recommendations = assigns(:recommended_events)
      styles = recommendations.map(&:style)
      expect(styles).to include('Ballet')
    end

    it 'returns recommendations based on borough matches' do
      user.liked_events << event1  # Ballet in Manhattan
      get :index
      
      recommendations = assigns(:recommended_events)
      boroughs = recommendations.map(&:borough)
      expect(boroughs).to include('Manhattan')
    end

    it 'returns recommendations based on location matches' do
      user.liked_events << event1  # Lincoln Center location
      get :index
      
      recommendations = assigns(:recommended_events)
      expect(recommendations).not_to be_empty
    end

    it 'handles events with no matching recommendations' do
      # Create a unique event that won't match anything
      unique_event = Event.create!(
        name: 'Unique Event',
        style: 'Unique Style',
        borough: 'Unique Borough',
        location: 'Unique Location',
        date: '2025-03-01',
        time: '19:00',
        price: '$100',
        venue: 'Unique Venue'
      )
      user.liked_events << unique_event
      
      get :index
      # Should return empty since no other events match
      expect(assigns(:recommended_events)).to be_empty
    end
  end
end