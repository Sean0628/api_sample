# frozen_string_literal: true

class GeolocationsController < ApplicationController # :nodoc:
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found

  def create
    if form.save
      render json: form.geolocation, status: :created
    else
      render_unprocessable_entity(form.errors.full_messages)
    end
  end

  def destroy
    if form.valid?
      geolocation = Geolocation.find_by(ip: form.resolved_ip_address)
      geolocation.destroy
      head :no_content
    else
      render_unprocessable_entity(form.errors.full_messages)
    end
  end

  def provide # rubocop:disable Metrics/AbcSize
    return render_unprocessable_entity(form.errors.full_messages) unless form.valid?

    geolocation = Geolocation.find_by(ip: form.resolved_ip_address)

    render json: geolocation
  rescue Mongoid::Errors::DocumentNotFound
    if form.save
      render json: form.geolocation, status: :created
    else
      render_unprocessable_entity(form.errors.full_messages)
    end
  end

  private

  def form
    @form ||= GeolocationForm.new(geolocation_params)
  end

  def geolocation_params
    params.fetch(:data, {}).permit(attributes: %i[ip_address url])
  end

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def handle_not_found
    head :not_found
  end

  def render_unprocessable_entity(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
