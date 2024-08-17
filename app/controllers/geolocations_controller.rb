# frozen_string_literal: true

class GeolocationsController < ApplicationController # :nodoc:
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

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
  end

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
