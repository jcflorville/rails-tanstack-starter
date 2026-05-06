# Cross-Origin Resource Sharing configuration for the SPA frontend.
# Cookies are session-based, so credentials must be allowed and the origin
# must be explicit (no wildcards when credentials: true).

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("WEB_ORIGIN", "http://localhost:5173")

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true,
      expose: %w[]
  end
end
