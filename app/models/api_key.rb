# frozen_string_literal: true

class ApiKey < ApplicationRecord # :nodoc:
  before_validation :generate_key, on: :create
  after_initialize :set_default_expiration, if: :new_record?

  enum status: { active: 0, inactive: 1, revoked: 2 }

  validates :key, presence: true, uniqueness: true
  validates :expired_at, presence: true

  private

  def generate_key
    self.key = SecureRandom.hex(20) unless key.present?
  end

  def set_default_expiration
    self.expired_at ||= 1.month.from_now
  end
end
