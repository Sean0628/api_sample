# frozen_string_literal: true

require 'rails_helper'

describe IpstackProvider do # rubocop:disable Metrics/BlockLength
  let(:ipstack_key) { 'test_api_key' }
  let(:ip_address) { '134.201.250.155' }
  let(:geolocation_data) do
    {
      'ip' => ip_address,
      'type' => 'ipv4',
      'continent_code' => 'NA',
      'continent_name' => 'North America',
      'country_code' => 'US',
      'country_name' => 'United States',
      'region_code' => 'CA',
      'region_name' => 'California',
      'city' => 'Los Angeles',
      'zip' => '90013',
      'latitude' => 34.0655,
      'longitude' => -118.2405
    }
  end

  subject(:provider) { described_class.new }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('IPSTACK_API_KEY').and_return(ipstack_key)
  end

  describe '#fetch' do
    context 'when provided with an IP address' do
      it 'fetches geolocation data for the IP address' do
        stub_request(:get, "http://api.ipstack.com/#{ip_address}?access_key=#{ipstack_key}")
          .to_return(status: 200, body: geolocation_data.to_json)

        result = provider.fetch(ip_address:)

        expect(result).to eq(geolocation_data.stringify_keys)
      end
    end

    context 'when the IP address is blank' do
      it 'returns nil' do
        result = provider.fetch(ip_address: nil)

        expect(result).to be_nil
      end
    end

    context 'when an error occurs during the request' do
      it 'raises an error with a descriptive message' do
        stub_request(:get, "http://api.ipstack.com/#{ip_address}?access_key=#{ipstack_key}")
          .to_return(status: 500, body: 'Internal Server Error')

        expect do
          provider.fetch(ip_address:)
        end.to raise_error(RuntimeError, /Failed to fetch geolocation data/)
      end
    end
  end
end
