# frozen_string_literal: true

class GeolocationProvider # :nodoc:
  def fetch(ip_address: nil, url: nil)
    raise NotImplementedError, 'You must implement the fetch method'
  end

  protected

  def resolve_ip_from_url(url)
    return nil if url.blank?

    uri = URI.parse(url)
    hostname = uri.host

    Resolv.getaddress(hostname)
  rescue URI::InvalidURIError
    nil
  rescue Resolv::ResolvError
    nil
  end
end
