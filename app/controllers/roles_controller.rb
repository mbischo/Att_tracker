class RolesController < ApplicationController

  before_filter :find_role, :only => [ :show, :edit, :update, :destroy ]
  before_filter :login_required
  
  # GET /roles
  # GET /roles.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_roles.to_ext_json(:class => Role, :count => Role.count(options_from_search(Role))) }
    end
  end

  # GET /roles/1
  def show
    # show.html.erb
  end

  # GET /roles/new
  def new
    @role = Role.new(params[:role])
    # new.html.erb
  end

  # GET /roles/1/edit
  def edit
    # edit.html.erb
  end

  # POST /roles
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to roles_path } }
      else
        format.ext_json { render :json => @role.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /roles/1
  def update
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to roles_path } }
      else
        format.ext_json { render :json => @role.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /roles/1
  def destroy
    @role.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_role
      @role = Role.find(params[:id])
    end
    
    def find_roles
      pagination_state = update_pagination_state_with_params!(Role)
      @roles = Role.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(Role)))
    end

end
