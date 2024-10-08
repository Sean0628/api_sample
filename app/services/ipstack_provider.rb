# frozen_string_literal: true

# This class is a provider for fetching geolocation data from the IPStack API.
class IpstackProvider < GeolocationProvider
  BASE_URL = 'http://api.ipstack.com/'

  def fetch(ip_address: nil)
    ip = ip_address
    return nil if ip.blank?

    ipstack_key = ENV['IPSTACK_API_KEY']
    uri = URI("#{BASE_URL}#{ip}?access_key=#{ipstack_key}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue StandardError => e
    raise "Failed to fetch geolocation data: #{e.message}"
  end
end
