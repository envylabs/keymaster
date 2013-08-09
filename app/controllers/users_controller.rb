class UsersController < ApplicationController
  respond_to :yaml

  def index
    @project  = Project.find(params[:project_id])
    @users    = @project.users.includes(:ssh_keys)

    respond_with(@users.collect { |u| u.keymaster_data })
  end

  def show
    @parent   = params.has_key?(:project_id) ? Project.find(params[:project_id]).users : User
    @user     = @parent.where(:login => params[:id]).includes(:ssh_keys).first!

    respond_with(@user.keymaster_data)
  end
end
