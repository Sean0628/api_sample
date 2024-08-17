class GeolocationProvider
  def fetch(ip_address: nil, url: nil)
    raise NotImplementedError, "You must implement the fetch method"
  end

  protected

  def resolve_ip_from_url(url)
    Resolv.getaddress(url)
  rescue Resolv::ResolvError
    nil
  end
end
