# frozen_string_literal: true

class GeolocationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :ip_address, :url, :provider, :geolocation

  validate :either_ip_or_url_present

  def initialize(params = {}, provider = IpstackProvider.new)
    attributes = params[:attributes] || {}
    @ip_address = attributes[:ip_address]
    @url = attributes[:url]
    @provider = provider
  end

  def save
    return false unless valid?

    geolocation_data = provider.fetch(ip_address:, url:)

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
end
