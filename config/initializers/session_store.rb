# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_keymaker_session',
  :secret      => 'a29128707789ffbd5327ada1a5ce0de5f96fd283c0cf81642f21b3873f33208490ad546ec70b3d6d59a481b4f9ad73a593605e24ac2d5af5b3a90c64fae7c346'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
