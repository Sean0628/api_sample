# frozen_string_literal: true

class ApplicationController < ActionController::API # :nodoc:
  before_action :authenticate_with_api_key

  private

  def authenticate_with_api_key
    api_key = request.headers['X-Api-Key']
    @current_api_key = ApiKey.find_by(key: api_key, status: :active)

    return if @current_api_key.present? && @current_api_key.expired_at > Time.current

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
