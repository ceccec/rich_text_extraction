# frozen_string_literal: true

require 'redis'
# frozen_string_literal: true

RSpec.shared_examples 'CORS headers' do |path|
  it "sets CORS headers for #{path}" do
    get path
    expect(response.headers['Access-Control-Allow-Origin']).to be_present
    expect(response.headers['Access-Control-Allow-Methods']).to include('GET')
    expect(response.headers['Access-Control-Allow-Headers']).to include('Content-Type')
  end

  it "responds to OPTIONS preflight for #{path}" do
    options path, headers: { 'Origin' => 'https://myfrontend.com', 'Access-Control-Request-Method' => 'GET' }
    expect(response.status).to eq(204).or eq(200)
    expect(response.headers['Access-Control-Allow-Origin']).to be_present
    expect(response.headers['Access-Control-Allow-Methods']).to include('GET')
    expect(response.headers['Access-Control-Allow-Headers']).to include('Content-Type')
  end
end

RSpec.shared_examples 'rate limiting' do |path, limit_config|
  let(:ip) { '1.2.3.4' }
  before(:each) do
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(ip)
    Rails.cache.clear
  end

  it "enforces rate limit for #{path}" do
    limit = limit_config[:limit]
    limit.times { get path }
    get path # This should trigger the rate limit
    expect(response.status).to eq(429)
    expect(response.body).to include('Rate limit exceeded')
    # Subsequent requests should also be rate-limited
    get path
    expect(response.status).to eq(429)
  end
end
