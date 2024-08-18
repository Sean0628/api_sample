# frozen_string_literal: true

class GeolocationsController < ApplicationController # :nodoc:
  CACHE_EXPIRATION = 1.day

  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found

  def create
    if form.save
      Rails.cache.write(geolocation_cache_key(form.resolved_ip_address), form.geolocation, expires_in: CACHE_EXPIRATION)
      render json: form.geolocation, status: :created
    else
      render_unprocessable_entity(form.errors.full_messages)
    end
  end

  def destroy
    if form.valid?
      geolocation = Geolocation.find_by(ip: form.resolved_ip_address)
      geolocation.destroy
      Rails.cache.delete(geolocation_cache_key(form.resolved_ip_address))
      head :no_content
    else
      render_unprocessable_entity(form.errors.full_messages)
    end
  end

  def provide # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return render_unprocessable_entity(form.errors.full_messages) unless form.valid?

    cached_geolocation =
      Rails.cache.fetch(geolocation_cache_key(form.resolved_ip_address), expires_in: CACHE_EXPIRATION) do
        Geolocation.find_by(ip: form.resolved_ip_address)
      end

    render json: cached_geolocation, status: :ok
  rescue Mongoid::Errors::DocumentNotFound
    if form.save
      Rails.cache.write(geolocation_cache_key(form.resolved_ip_address), form.geolocation, expires_in: CACHE_EXPIRATION)
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

  def geolocation_cache_key(ip_address)
    "geolocation:#{ip_address}"
  end
end
