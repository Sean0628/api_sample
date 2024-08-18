# frozen_string_literal: true

# This class is responsible for handling the form object for creating a new geolocation record.
class GeolocationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :ip_address, :url, :provider, :geolocation

  validate :either_ip_or_url_present
  validate :valid_url_format, if: -> { ip_address.blank? && url.present? }

  def initialize(params = {}, provider = IpstackProvider.new)
    attributes = params[:attributes] || {}
    @url = attributes[:url]
    @ip_address = attributes[:ip_address]
    @provider = provider
  end

  def save
    return false unless valid?

    geolocation_data = provider.fetch(ip_address: ip_address || resolve_ip_from_url(url))
    return false if geolocation_data.blank?

    @geolocation = Geolocation.find_or_initialize_by(ip: geolocation_data['ip'])
    @geolocation.data = geolocation_data
    @geolocation.save
  end

  private

  def either_ip_or_url_present
    return unless ip_address.blank? && url.blank?

    errors.add(:base, 'Provide at least one of ip_address or url')
  end

  def valid_url_format
    uri = URI.parse(url)
    errors.add(:url, 'is not a valid HTTP/HTTPS URL') unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    errors.add(:url, 'is not a valid URL')
  end

  def resolve_ip_from_url(url)
    return nil if url.blank?

    uri = URI.parse(url)
    hostname = uri.host
    return nil if hostname.blank?

    Resolv.getaddress(hostname)
  rescue URI::InvalidURIError, Resolv::ResolvError
    nil
  end
end
