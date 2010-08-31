class ProjectsController < ApplicationController

  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.yaml { render :text => @project.attributes.to_yaml }
    end
  end

end
