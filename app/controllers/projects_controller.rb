class ProjectsController < ApplicationController
  before_filter :ensure_signed_in
  before_filter :ensure_approved  
  include ProjectsHelper

  
  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @project }
    end
  end

  def graph
    @project = Project.find(params[:id])
    rv = risk_versions
    respond_to do |format|
      format.json  { render :json => { 
          :week_ticks => week_ticks(rv), 
          :month_ticks => month_ticks(rv), 
          :total_risk => total_risk(rv), 
          :accepted_risk => accepted_risk(rv) 
        } }
    end    
  end

  def risk_levels
    @project = Project.find(params[:id])
    @risk_configuration = @project.risk_configuration
    respond_to do |format|
      format.html # risk_levels.html.erb
    end
  end



  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.html { redirect_to(@project, :notice => 'Project was successfully created.') }
        format.json  { render :json => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to(@project, :notice => 'Project was successfully updated.') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.json  { head :ok }
    end
  end

  def tags
    @term = params[:term].downcase
    @tags = Project.find(params[:id]).risks.tag_counts.map{ |t| t.name }.select{ |t| t.downcase.start_with? @term }
    render :json => @tags
  end

  def export
    @project = Project.find(params[:id])    
    @include_comments = params[:include_comments]
    @tag = params[:tag]    
    if (@tag) then
      @risks = @project.risks.tagged_with(params[:tag])
    else 
      @risks = @project.risks
    end
    @date = Date.parse(params[:at]) rescue NIL
    if (@date) then
      @risks = @risks.collect{|r| r.version_at(@date)}.reject{|r| r == nil}
    end
    respond_to do |format|
      format.html { render :layout => 'export_layout' }
    end
  end


end
