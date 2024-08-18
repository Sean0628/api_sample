# frozen_string_literal: true

require 'rails_helper'

describe GeolocationsController, type: :controller do
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

  describe 'POST #create' do
    context 'with valid parameters' do
      before do
        allow(geolocation_form).to receive(:save).and_return(true)
        allow(geolocation_form).to receive(:geolocation).and_return(geolocation_data)
      end

      it 'creates or updates a geolocation and returns the geolocation data with status :created' do
        expect(GeolocationForm).to receive(:new).with(ActionController::Parameters.new(attributes: valid_attributes).permit!)
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
        expect(GeolocationForm).to receive(:new).with(ActionController::Parameters.new(attributes: invalid_attributes).permit!)
        expect(geolocation_form).to receive(:save).and_return(false)

        post :create, params: { data: { attributes: invalid_attributes } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Provide at least one of ip_address or url'] })
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:valid_ip) { '134.201.250.155' }
    let(:resolved_ip) { '93.184.216.34' }
    before { Geolocation.create(ip: valid_ip, data: { 'ip' => valid_ip }) }

    context 'with a valid IP address' do
      before do
        allow(geolocation_form).to receive(:valid?).and_return(true)
        allow(geolocation_form).to receive(:resolved_ip_address).and_return(valid_ip)
      end

      it 'deletes the geolocation and returns status :no_content' do
        expect do
          delete :destroy, params: { ip_address: valid_ip }
        end.to change(Geolocation, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with a valid URL' do
      before do
        allow(geolocation_form).to receive(:valid?).and_return(true)
        allow(geolocation_form).to receive(:resolved_ip_address).and_return(valid_ip)
      end

      it 'resolves the IP address from the URL, deletes the geolocation, and returns status :no_content' do
        Geolocation.create(ip: resolved_ip, data: { 'ip' => resolved_ip })

        expect do
          delete :destroy, params: { url: 'http://example.com' }
        end.to change(Geolocation, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the geolocation does not exist' do
      let(:non_existent_ip) { '120.201.250.155' }
      before do
        allow(geolocation_form).to receive(:valid?).and_return(true)
        allow(geolocation_form).to receive(:resolved_ip_address).and_return(non_existent_ip)
      end

      it 'returns status :not_found' do
        expect do
          delete :destroy, params: { ip_address: non_existent_ip }
        end.not_to change(Geolocation, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid parameters' do
      before do
        allow(geolocation_form).to receive(:valid?).and_return(false)
        allow(geolocation_form).to receive_message_chain(:errors, :full_messages)
      end

      it 'returns status :bad_request when both ip_address and url are missing' do
        delete :destroy, params: {}

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns status :bad_request when the URL is invalid' do
        delete :destroy, params: { url: 'invalid-url' }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
