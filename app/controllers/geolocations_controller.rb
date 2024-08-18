# frozen_string_literal: true

class GeolocationsController < ApplicationController # :nodoc:
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found

  def create
    form = GeolocationForm.new(geolocation_params)

    if form.save
      render json: form.geolocation, status: :created
    else
      render json: { errors: form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    form = GeolocationForm.new(geolocation_params)

    if form.valid?
      geolocation = Geolocation.find_by(ip: form.resolved_ip_address)
      geolocation.destroy
      head :no_content
    else
      render json: { errors: form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def geolocation_params
    params.fetch(:data, {}).permit(attributes: %i[ip_address url])
  end

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def handle_not_found
    head :not_found
  end
end
