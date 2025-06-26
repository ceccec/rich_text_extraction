# frozen_string_literal: true

# Health check controller for monitoring application status
class HealthController < ApplicationController
  def show
    render json: { status: 'ok', time: Time.now.utc }, status: :ok
  end
end
