# Be sure to restart your server when you modify this file.

Imminence::Application.config.session_store :cookie_store,
  :key => '_imminence_session',
  :secure => Rails.env.production?,
  :http_only => true
