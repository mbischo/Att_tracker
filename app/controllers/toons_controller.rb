class ToonsController < ApplicationController

  before_filter :find_toon, :only => [ :show, :edit, :update, :destroy, :loots, :raids ]
  before_filter :login_required, :except => [:index, :show, :loots, :raids]

  # GET /toons
  # GET /toons.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_toons.to_ext_json(:include => [:toonClass],:class => Toon, :count => Toon.count(options_from_search(Toon))) }
    end
  end

  # GET /toons/1
  def show
    # show.html.erb
  end
  
  def loots
    respond_to do |format|
      format.ext_json { render :json => @toon.lootEvents.to_ext_json(:include => [:bossKill]) } 
    end
  end
  
  def raids
    respond_to do |format|
      format.ext_json { render :json => @toon.memberParticipations.to_ext_json(:include => {:raidEvent => {:except => [:raid_tracker_source],:include => [:dungeon]}}) } 
    end
  end

  # GET /toons/new
  def new
    @toon = Toon.new(params[:toon])
    @toon.is_main = false
    @members = Member.find(:all)
    @class_list = ToonClass.find(:all)
    # new.html.erb
  end

  # GET /toons/1/edit
  def edit
    @members = Member.find(:all)
    @class_list = ToonClass.find(:all)
    # edit.html.erb
  end

  # POST /toons
  def create
    @toon = Toon.new(params[:toon])

    respond_to do |format|
      if @toon.save
        flash[:notice] = 'Toon was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to toons_path } }
      else
        format.ext_json { render :json => @toon.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /toons/1
  def update
    owningMemberChanged = (params[:toon]['member_id'] != @toon.member_id)
    oldMember = nil
    if owningMemberChanged
      oldMember = @toon.member
    end
    
    respond_to do |format|
      if @toon.update_attributes(params[:toon])
        if owningMemberChanged
          # Update member participations
          @toon.memberParticipations.each do |memPart|
            memPart.member_id = @toon.member_id
            memPart.save # otherwise some caching occurs in recalc
          end
          # Recalculate Roll guides for old and new member
          #GuideRequest.recalculateRollGuides(oldMember)
          #GuideRequest.recalculateRollGuides(Member.find(@toon.member_id))
        end
        flash[:notice] = 'Toon was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to toons_path } }
      else
        format.ext_json { render :json => @toon.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /toons/1
  def destroy
    @toon.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
  def find_toon
    @toon = Toon.find(params[:id])
  end
  
  def find_toons
    pagination_state = update_pagination_state_with_params!(Toon)
    @toons = Toon.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(Toon)))
  end
  
  def permission_denied
    flash[:notice] = "You don't have privileges to access this action"
    return redirect_to :action => 'denied'
  end

  def permission_granted
    flash[:notice] = "Welcome to the secure area of foo.com!"
  end

end