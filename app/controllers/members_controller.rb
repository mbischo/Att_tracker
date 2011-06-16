class MembersController < ApplicationController

  before_filter :find_member, :only => [ :show, :edit, :update, :destroy, :toons, :loots, :raids ]
  before_filter :login_required, :except => [:index, :show, :toons, :loots, :raids]

  # GET /members
  # GET /members.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_members.to_ext_json(:include => [:main_toon],:class => Member, :count => Member.count(options_from_search(Member))) }
      format.json { render :json => combo_members.to_json }
    end
  end
  
   # GET /members/1
  def show
    # show.html.erb
  end

  def toons
    respond_to do |format|
      format.ext_json { render :json => @member.toons.to_ext_json(:include => [:toonClass]) } 
    end
  end
  
  def loots
    respond_to do |format|
      format.ext_json { render :json => @member.lootEvents.to_ext_json(:include => [:toon,:bossKill]) } 
    end
  end
  
  def raids
    respond_to do |format|
      format.ext_json { render :json => @member.memberParticipations.to_ext_json(:include => {:toon => {:include => [:toonClass]}, :raidEvent => {:except => [:raid_tracker_source],:include => [:dungeon]}}) } 
    end
  end
  
  # GET /members/new
  def new
    @member = Member.new(params[:member])
    @toons = Toon.find(:all)
    # new.html.erb
  end

  # GET /members/1/edit
  def edit
    @toons = Toon.find(:all)
    # edit.html.erb
  end

  # POST /members
  def create
    @member = Member.new(params[:member])

    respond_to do |format|
      if @member.save
        flash[:notice] = 'Member was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to members_path } }
      else
        format.ext_json { render :json => @member.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /members/1
  def update
    respond_to do |format|
      if @member.update_attributes(params[:member])
        flash[:notice] = 'Member was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to members_path } }
      else
        format.ext_json { render :json => @member.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /members/1
  def destroy
    @member.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_member
      @member = Member.find(params[:id])
    end
    
    def find_members
      pagination_state = update_pagination_state_with_params!(Member)
      @members = Member.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(Member)))
  end
  
  def combo_members
    output = Hash.new
    Member.find(:all).each do |mem|
      output[mem.id.to_s] = mem.name.to_s
    end
    
    output
  end
  
  def permission_denied
    flash[:notice] = "You don't have privileges to access this action"
    return redirect_to :action => 'denied'
  end

  def permission_granted
    flash[:notice] = "Welcome to the secure area of foo.com!"
  end

end
