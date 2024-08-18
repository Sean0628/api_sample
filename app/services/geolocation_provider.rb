# frozen_string_literal: true

class GeolocationProvider # :nodoc:
  def fetch(ip_address: nil, url: nil)
    raise NotImplementedError, 'You must implement the fetch method'
  end
end
