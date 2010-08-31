class GateKeeperController < ApplicationController

  def index
    respond_to do |format|
      format.rb { render :text => Keymaster.gatekeeper_data.gsub('%CURRENT_KEYMASTER_HOST%', request.host) }
    end
  end

end
