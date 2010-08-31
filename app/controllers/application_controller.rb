class ApplicationController < ActionController::Base

  protect_from_forgery
  after_filter :set_version_header


  private


  def set_version_header
    response.headers['Api-Version'] = Keymaster.version
  end

end
