class UsersController < ApplicationController
  
  def index
    @project  = Project.find(params[:project_id])
    @users    = @project.users
    
    respond_to do |format|
      format.yaml { render :text => @users.collect { |u| u.attributes }.to_yaml }
    end
  end
  
  def show
    @parent   = params.has_key?(:project_id) ? Project.find(params[:project_id]).users : User
    @user     = @parent.find_by_login(params[:id]) || raise(ActiveRecord::RecordNotFound)
    
    respond_to do |format|
      format.yaml { render :text => @user.attributes.to_yaml }
    end
  end
  
end
