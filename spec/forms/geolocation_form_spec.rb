# frozen_string_literal: true

require 'rails_helper'

describe GeolocationForm, type: :model do # rubocop:disable Metrics/BlockLength
  let(:provider) { double('IpstackProvider') } # Mock the provider
  let(:valid_ip) { '134.201.250.155' }
  let(:geolocation_data) do
    {
      'ip' => valid_ip,
      'city' => 'Los Angeles',
      'region_name' => 'California',
      'country_name' => 'United States',
      'latitude' => 34.0655,
      'longitude' => -118.2405
    }
  end

  before do
    allow(provider).to receive(:fetch).and_return(geolocation_data)
  end

  describe 'validations' do
    it 'is valid with either ip_address or url' do
      form = GeolocationForm.new({ ip_address: valid_ip }, provider)
      expect(form).to be_valid

      form = GeolocationForm.new({ url: 'http://example.com' }, provider)
      expect(form).to be_valid
    end

    it 'is valid with both ip_address and url' do
      form = GeolocationForm.new({ ip_address: valid_ip, url: 'http://example.com' }, provider)
      expect(form).to be_valid
    end

    it 'is invalid with neither ip_address nor url' do
      form = GeolocationForm.new({}, provider)
      form.valid?
      expect(form.errors[:base]).to include('Provide at least one of ip_address or url')
    end
  end

  describe '#save' do
    context 'when valid' do
      let(:valid_ip) { '111.201.250.155' }

      it 'saves the geolocation data to the database' do
        form = GeolocationForm.new({ ip_address: valid_ip }, provider)
        expect do
          form.save
        end.to change(Geolocation, :count).by(1)
      end
    end

    context 'when invalid' do
      it 'does not save geolocation data' do
        expect do
          form = GeolocationForm.new({}, provider) # No ip_address or url
          form.save
        end.not_to change(Geolocation, :count)
      end
    end

    context 'when provider returns no data' do
      before { allow(provider).to receive(:fetch).and_return(nil) }

      it 'does not save geolocation data' do
        expect do
          form = GeolocationForm.new({ ip_address: valid_ip }, provider)
          form.save
        end.not_to change(Geolocation, :count)
      end
    end
  end
end
