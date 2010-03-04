class GateKeeperController < ApplicationController
  
  def index
    respond_to do |format|
      format.rb { render :text => File.read(File.join(Rails.root, 'lib/gatekeeper.rb')) }
    end
  end
  
end
