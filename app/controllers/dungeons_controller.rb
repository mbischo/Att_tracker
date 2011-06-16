class DungeonsController < ApplicationController

  before_filter :find_dungeon, :only => [ :show, :edit, :update, :destroy, :roll_guide, :raids ]
  before_filter :login_required, :except => [:index, :show, :raids, :roll_guide]
  #access_control :new => 'admin & !blacklist'
  
  # GET /dungeons
  # GET /dungeons.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_dungeons.to_ext_json(:class => Dungeon, :count => Dungeon.count(options_from_search(Dungeon))) }
    end
  end

  # GET /dungeons/1/roll_guide.html
  def roll_guide
    @current_request = Dungeon.getOrCreateGuideRequest(@dungeon)
    respond_to do |format|
      format.html     # roll_guide.html.erb (no data required)
      format.lua { render :text => GuideRequest.to_lua(@current_request)}
    end
  end
  
  # GET /dungeons/1
  def show
    # show.html.erb
  end
  
  def raids
    respond_to do |format|
      format.ext_json { render :json => @dungeon.raidEvents.to_ext_json(:except => [:raid_tracker_source]) } 
    end
  end

  # GET /dungeons/new
  def new
    @dungeon = Dungeon.new(params[:dungeon])
    # new.html.erb
  end

  # GET /dungeons/1/edit
  def edit
    # edit.html.erb
  end

  # POST /dungeons
  def create
    @dungeon = Dungeon.new(params[:dungeon])

    respond_to do |format|
      if @dungeon.save
        flash[:notice] = 'Dungeon was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to dungeons_path } }
      else
        format.ext_json { render :json => @dungeon.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /dungeons/1
  def update
    respond_to do |format|
      if @dungeon.update_attributes(params[:dungeon])
        flash[:notice] = 'Dungeon was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to dungeons_path } }
      else
        format.ext_json { render :json => @dungeon.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /dungeons/1
  def destroy
    @dungeon.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
  def find_dungeon
    @dungeon = Dungeon.find(params[:id])
  end
  
  def find_dungeons
    pagination_state = update_pagination_state_with_params!(Dungeon)
    @dungeons = Dungeon.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(Dungeon)))
  end
  
  def permission_denied
    flash[:notice] = "You don't have privileges to access this action"
    return redirect_to :action => 'index'
  end

end
