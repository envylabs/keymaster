class GateKeeperController < ApplicationController

  def index
    respond_to do |format|
      format.rb { render :text => Keymaster.gatekeeper_data }
    end
  end

end
