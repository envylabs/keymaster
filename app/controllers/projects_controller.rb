class ProjectsController < ApplicationController
  respond_to :yaml

  def show
    @project = Project.find(params[:id])
    respond_with(@project.attributes)
  end
end
