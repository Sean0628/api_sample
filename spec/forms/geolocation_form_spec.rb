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
      form = GeolocationForm.new({ attributes: { ip_address: valid_ip } }, provider)
      expect(form).to be_valid

      form = GeolocationForm.new({ attributes: { url: 'http://example.com' } }, provider)
      expect(form).to be_valid
    end

    it 'is valid with both ip_address and url' do
      form = GeolocationForm.new({ attributes: { ip_address: valid_ip, url: 'http://example.com' } }, provider)
      expect(form).to be_valid
    end

    it 'is invalid with neither ip_address nor url' do
      form = GeolocationForm.new({ attributes: {} }, provider)
      form.valid?
      expect(form.errors[:base]).to include('Provide at least one of ip_address or url')
    end

    it 'is invalid with an improperly formatted URL' do
      form = GeolocationForm.new({ attributes: { url: 'invalid-url' } }, provider)
      form.valid?
      expect(form.errors[:url]).to include('is not a valid HTTP/HTTPS URL')

      form = GeolocationForm.new({ attributes: { url: 'ftp://example.com' } }, provider)
      form.valid?
      expect(form.errors[:url]).to include('is not a valid HTTP/HTTPS URL')
    end
  end

  describe '#save' do # rubocop:disable Metrics/BlockLength
    context 'when valid' do
      context 'when geolocation data does not exist in the database' do
        it 'saves the geolocation data to the database' do
          form = GeolocationForm.new({ attributes: { ip_address: valid_ip } }, provider)
          expect do
            form.save
          end.to change(Geolocation, :count).by(1)
        end
      end

      context 'when geolocation data already exists in the database' do
        it 'updates existing geolocation data in the database' do
          Geolocation.create(ip: valid_ip, data: { 'ip' => valid_ip })
          form = GeolocationForm.new({ attributes: { ip_address: valid_ip } }, provider)
          expect do
            form.save
          end.not_to change(Geolocation, :count)
          expect(Geolocation.find_by(ip: valid_ip).data).to eq(geolocation_data)
        end
      end
    end

    context 'when invalid' do
      it 'does not save geolocation data' do
        expect do
          form = GeolocationForm.new({ attributes: {} }, provider) # No ip_address or url
          form.save
        end.not_to change(Geolocation, :count)
      end
    end

    context 'when provider returns no data' do
      before { allow(provider).to receive(:fetch).and_return(nil) }

      it 'does not save geolocation data' do
        expect do
          form = GeolocationForm.new({ attributes: { ip_address: valid_ip } }, provider)
          form.save
        end.not_to change(Geolocation, :count)
      end
    end

    context 'when the URL is not HTTP or HTTPS' do
      it 'does not save geolocation data' do
        form = GeolocationForm.new({ attributes: { url: 'ftp://example.com' } }, provider)
        expect do
          form.save
        end.not_to change(Geolocation, :count)
        expect(form.errors[:url]).to include('is not a valid HTTP/HTTPS URL')
      end
    end
  end

  describe '#resolved_ip_address' do # rubocop:disable Metrics/BlockLength
    let(:form) { GeolocationForm.new({ attributes: { ip_address: ip_address, url: url } }, provider) }

    context 'when ip_address is provided' do
      let(:ip_address) { valid_ip }
      let(:url) { nil }

      it 'returns the ip_address' do
        expect(form.resolved_ip_address).to eq(valid_ip)
      end
    end

    context 'when ip_address is not provided but url is provided' do
      let(:ip_address) { nil }
      let(:url) { 'http://example.com' }
      let(:resolved_ip) { valid_ip }

      it 'resolves and returns the IP address from the URL' do
        allow(Resolv).to receive(:getaddress).with('example.com').and_return(resolved_ip)
        expect(form.resolved_ip_address).to eq(resolved_ip)
      end
    end

    context 'when neither ip_address nor url is provided' do
      let(:ip_address) { nil }
      let(:url) { nil }

      it 'returns nil' do
        expect(form.resolved_ip_address).to be_nil
      end
    end

    context 'when url is invalid' do
      let(:ip_address) { nil }
      let(:url) { 'invalid-url' }

      it 'returns nil' do
        expect(form.resolved_ip_address).to be_nil
      end
    end
  end
end
