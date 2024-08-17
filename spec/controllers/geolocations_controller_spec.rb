# frozen_string_literal: true

require 'rails_helper'

describe GeolocationsController, type: :controller do # rubocop:disable Metrics/BlockLength
  let(:valid_attributes) { { ip_address: '134.201.250.155' } }
  let(:invalid_attributes) { { ip_address: '', url: '' } }
  let(:geolocation_data) do
    {
      'ip' => '134.201.250.155',
      'city' => 'Los Angeles',
      'region_name' => 'California',
      'country_name' => 'United States',
      'latitude' => 34.0655,
      'longitude' => -118.2405
    }
  end

  let(:geolocation_form) { instance_double('GeolocationForm') }

  before do
    allow(GeolocationForm).to receive(:new).and_return(geolocation_form)
  end

  describe 'POST #create' do # rubocop:disable Metrics/BlockLength
    context 'with valid parameters' do
      before do
        allow(geolocation_form).to receive(:save).and_return(true)
        allow(geolocation_form).to receive(:geolocation).and_return(geolocation_data)
      end

      it 'creates or updates a geolocation and returns the geolocation data with status :created' do
        expect(GeolocationForm).to receive(:new).with(ActionController::Parameters.new(valid_attributes).permit!)
        expect(geolocation_form).to receive(:save).and_return(true)

        post :create, params: { data: { attributes: valid_attributes } }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq(geolocation_data.stringify_keys)
      end
    end

    context 'with invalid parameters' do
      before do
        allow(geolocation_form).to receive(:save).and_return(false)
        allow(geolocation_form).to receive_message_chain(:errors, :full_messages)
          .and_return(['Provide at least one of ip_address or url'])
      end

      it 'does not create or update a geolocation and returns errors with status :unprocessable_entity' do
        expect(GeolocationForm).to receive(:new).with(ActionController::Parameters.new(invalid_attributes).permit!)
        expect(geolocation_form).to receive(:save).and_return(false)

        post :create, params: { data: { attributes: invalid_attributes } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Provide at least one of ip_address or url'] })
      end
    end

    context 'with missing parameters' do
      it 'raises a ParameterMissing error' do
        expect do
          post :create, params: { data: {} }
        end.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
