class RollPoolsController < ApplicationController

  before_filter :find_roll_pool, :only => [ :show, :edit, :update, :destroy, :dungeons, :dungeon_choices, :roll_guide ]
  before_filter :login_required, :except => [:index, :show, :dungeons, :dungeon_choices, :roll_guide ]

  # GET /roll_pools
  # GET /roll_pools.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_roll_pools.to_ext_json(:class => RollPool, :count => RollPool.count(options_from_search(RollPool))) }
    end
  end

  # GET /roll_pools/1
  def show
    # show.html.erb
  end

  # GET /roll_pools/new
  def new
    @roll_pool = RollPool.new(params[:roll_pool])
    # new.html.erb
  end
  
  def dungeons
    respond_to do |format|
      format.ext_json { render :json => @roll_pool.dungeons.to_ext_json() } 
    end
  end
  
  def dungeon_choices
    respond_to do |format|
      format.ext_json { render :json => (Dungeon.find(:all) - @roll_pool.dungeons).to_ext_json() } 
    end
  end
  
  def roll_guide
    @current_request = RollPool.getOrCreateGuideRequest(@roll_pool)
    respond_to do |format|
      format.html     # roll_guide.html.erb (no data required)
      format.lua { render :text => GuideRequest.to_lua(@current_request)}
    end
  end

  # GET /roll_pools/1/edit
  def edit
    # edit.html.erb
  end

  # POST /roll_pools
  def create
    @roll_pool = RollPool.new(params[:roll_pool])

    respond_to do |format|
      if @roll_pool.save
        # Clear Pool's dungeon list
        @roll_pool.dungeons.clear
        params['dungeons'].split(',').each do |dunId|
          @roll_pool.dungeons << Dungeon.find(dunId)
        end
        flash[:notice] = 'RollPool was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to roll_pools_path } }
      else
        format.ext_json { render :json => @roll_pool.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /roll_pools/1
  def update
    respond_to do |format|
      if @roll_pool.update_attributes(params[:roll_pool])
          # Clear Pool's dungeon list
          @roll_pool.dungeons.clear
          params['dungeons'].split(',').each do |dunId|
            @roll_pool.dungeons << Dungeon.find(dunId)
          end
        flash[:notice] = 'RollPool was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to roll_pools_path } }
      else
        format.ext_json { render :json => @roll_pool.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /roll_pools/1
  def destroy
    @roll_pool.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_roll_pool
      @roll_pool = RollPool.find(params[:id])
    end
    
    def find_roll_pools
      pagination_state = update_pagination_state_with_params!(RollPool)
      @roll_pools = RollPool.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(RollPool)))
    end

end
