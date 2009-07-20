# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_yavin_session',
  :secret      => 'c6f4055ad206bb3ffd52590e8807c0c3c4c476eb586d4d3135d6f80e1351ea3091d5b10d9b9688f26bc5e48d6bacd8bb9d35b97520c0cba107401eb267630e1c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
