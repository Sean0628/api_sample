# frozen_string_literal: true

class GeolocationsController < ApplicationController # :nodoc:
  def create
    form = GeolocationForm.new(create_params)

    if form.save
      render json: form.geolocation, status: :created
    else
      render json: { errors: form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.fetch(:data, {}).permit(attributes: %i[ip_address url])
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  end
end
