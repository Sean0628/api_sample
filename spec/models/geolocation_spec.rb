# frozen_string_literal: true

require 'rails_helper'

describe Geolocation, type: :model do
  it { is_expected.to have_timestamps }

  it 'has a valid factory' do
    geolocation = Geolocation.new(ip: '127.0.0.1', data: { city: 'Test City' })
    expect(geolocation).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ip) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(ip: 1).with_options(unique: true) }
  end

  describe 'fields' do
    it { is_expected.to have_field(:ip).of_type(String) }
    it { is_expected.to have_field(:data).of_type(Hash) }
  end
end
