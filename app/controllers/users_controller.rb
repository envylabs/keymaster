class UsersController < ApplicationController

  def index
    @project  = Project.find(params[:project_id])
    @users    = @project.users.includes(:ssh_keys)

    respond_to do |format|
      format.yaml { render :text => @users.collect { |u| u.keymaster_data }.to_yaml }
    end
  end

  def show
    @parent   = params.has_key?(:project_id) ? Project.find(params[:project_id]).users : User
    @user     = @parent.where(:login => params[:id]).includes(:ssh_keys).first!

    respond_to do |format|
      format.yaml { render :text => @user.keymaster_data.to_yaml }
    end
  end

end
