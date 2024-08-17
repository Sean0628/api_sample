class Geolocation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ip, type: String
  field :data, type: Hash

  index({ ip: 1 }, { unique: true })

  validates :ip, presence: true
end
