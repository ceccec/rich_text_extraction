class HealthController < ApplicationController
  def show
    render json: { status: 'ok', time: Time.now.utc }, status: :ok
  end
end 