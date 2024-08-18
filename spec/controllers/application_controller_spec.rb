# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do # rubocop:disable Metrics/BlockLength
  controller do
    def index
      render plain: 'Success'
    end
  end

  let(:api_key) { SecureRandom.hex(20) }
  let!(:active_key) { ApiKey.create!(key: api_key, expired_at: 1.month.from_now, status: :active) }
  let!(:expired_key) { ApiKey.create!(key: SecureRandom.hex(20), expired_at: 1.day.ago, status: :active) }
  let!(:inactive_key) { ApiKey.create!(key: SecureRandom.hex(20), expired_at: 1.month.from_now, status: :inactive) }

  context 'with valid API key' do
    it 'allows access to the resource' do
      request.headers['X-Api-Key'] = active_key.key
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('Success')
    end
  end

  context 'with expired API key' do
    it 'denies access to the resource' do
      request.headers['X-Api-Key'] = expired_key.key
      get :index
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end
  end

  context 'with inactive API key' do
    it 'denies access to the resource' do
      request.headers['X-Api-Key'] = inactive_key.key
      get :index
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end
  end

  context 'without an API key' do
    it 'denies access to the resource' do
      get :index
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end
  end

  context 'with invalid API key' do
    it 'denies access to the resource' do
      request.headers['X-Api-Key'] = 'invalid_api_key'
      get :index
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
    end
  end
end
