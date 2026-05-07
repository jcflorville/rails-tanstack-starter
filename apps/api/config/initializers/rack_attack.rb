class Rack::Attack
  # Use Rails.cache in production/development. In test, fall back to a memory
  # store because the test environment uses :null_store, which would prevent
  # rack-attack from counting hits.
  self.cache.store = if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
    ActiveSupport::Cache::MemoryStore.new
  else
    Rails.cache
  end

  # Throttle login attempts by IP — protects against brute-force on /api/v1/session.
  throttle("logins/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/session" && req.post?
  end

  # Throttle password reset requests by IP — reset emails are expensive and a
  # vector for spam/abuse.
  throttle("password_resets/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/api/v1/passwords" && req.post?
  end

  # Safety net — throttle absolutely everything per IP.
  throttle("req/ip", limit: 300, period: 5.minutes, &:ip)

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"] || {}
    retry_after = match_data[:period].to_s

    [
      429,
      { "Content-Type" => "application/json", "Retry-After" => retry_after },
      [ { error: "Too many requests. Please try again later." }.to_json ]
    ]
  end

  # Disable in test by default — individual specs opt in.
  self.enabled = !Rails.env.test?
end
