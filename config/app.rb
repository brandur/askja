class App < Configurable # :nodoc:
  # Settings in config/app/* take precedence over those specified here.
  
  config.name = Rails.application.class.parent.name

  config.title = "Mutelight"

  # Used for `rake top` to get top articles from Analytics
  config.analytics_id = "UA-6901854-1"

  # Used for `rake ping`, no trailing slash
  config.url = "http://mutelight.org"
end
