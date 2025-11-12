require 'rails_helper'

RSpec.describe PerformancesController, type: :controller do
  let!(:event1) { Event.create!(style: 'Ballet', borough: 'Manhattan', location: 'Lincoln Center', price: '$20', date: '2025-12-01') }
  let!(:event4) { Event.create!(style: 'Modern', borough: 'Brooklyn', location: 'Kings Theater', price: '$30', date: '2025-12-03') }
  let!(:event2) { Event.create!(style: 'Hip Hop', borough: 'Brooklyn', location: 'Barclays Center', price: '$60', date: '2025-12-05') }
  let!(:event3) { Event.create!(style: 'Jazz', borough: 'Queens', location: 'Flushing Town Hall', price: '$120', date: '2025-12-10') }

  describe 'GET #index' do
    it 'filters by borough' do
      session[:preferences] = { 'borough' => ['Manhattan'] }
      get :index
      expect(assigns(:events).pluck(:borough)).to eq(['Manhattan'])
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

    it 'filters by date range' do
      get :index, params: { date_filter_start: '2025-12-01', date_filter_end: '2025-12-05' }
      expect(assigns(:events).pluck(:date)).to include('2025-12-01', '2025-12-05')
      expect(assigns(:events).pluck(:date)).not_to include('2025-12-10')
    end

    it 'filters by single date' do
      get :index, params: { date_filter_start: '2025-12-05' }
      expect(assigns(:events).pluck(:date)).to eq(['2025-12-05'])
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
          date: 'not-a-valid-date'
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
    end
  end

  describe '#numeric_price' do
    it 'returns numeric inputs unchanged' do
      expect(controller.send(:numeric_price, 55)).to eq(55)
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
end
