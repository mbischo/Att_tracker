require 'rexml/document'

class RaidEventsController < ApplicationController

  before_filter :find_raid_event, :only => [ :show, :edit, :update, :destroy, :boss_kills, :mem_participations, :loot_events ]
  before_filter :login_required, :except => [:index, :show, :boss_kills, :mem_participations, :loot_events]
  
  # GET /raid_events
  # GET /raid_events.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_raid_events.to_ext_json(:include => [:dungeon],:except => [:raid_tracker_source],:class => RaidEvent, :count => RaidEvent.count(options_from_search(RaidEvent))) }
    end
  end

  # GET /raid_events/1
  def show
    # show.html.erb
  end

  # GET /raid_events/new
  def new
    @raid_event = RaidEvent.new(params[:raid_event])
    @raid_event.is_scheduled = false
    @raid_event.is_nonrun = false
    # new.html.erb
  end
  
  def boss_kills
    respond_to do |format|
      format.ext_json { render :json => @raid_event.bossKills.to_ext_json } 
    end
  end
  
  def mem_participations
    respond_to do |format|
      format.ext_json { render :json => @raid_event.memberParticipations.to_ext_json(:include => {:toon => {:include => [:toonClass]}}) } 
    end
  end
  
  def loot_events
    respond_to do |format|
      format.ext_json { render :json => @raid_event.lootEvents.to_ext_json(:include => {:toon =>{}}) } 
    end
  end

  # GET /raid_events/1/edit
  def edit
    # edit.html.erb
  end

  # POST /raid_events
  def create
    run_process = false
    valid = true
    if params[:raid_event]['raid_tracker_source'] != nil
      run_process = true
      doc = REXML::Document.new(params[:raid_event]['raid_tracker_source'])
      if RaidEvent.find_all_by_begin_number(doc.root.get_text('start').to_s).length > 0
        flash[:notice] = 'RaidEvent already in system'
        valid = false
      end
    end
    @raid_event = RaidEvent.new(params[:raid_event])

    respond_to do |format|
     if valid
      if @raid_event.save
        # Process XML here
        @raid_event.process_source(@raid_event) if run_process
        flash[:notice] = 'RaidEvent was successfully created.'
        #format.ext_json { render :json => @raid_event.to_ext_json({:success => true, :except => [:raid_tracker_source]}) }
        #format.ext_json { render :json =>'{ success: true, errors: {} }' }
        format.ext_json { render(:update) {|page| page.redirect_to raid_events_path } }
      else
        puts 'Were getting here'
        format.ext_json { render :json => @raid_event.to_ext_json(:success => false) }
      end
    else
      format.ext_json { render :json => '{ success: false, errors: { "raid_event[raid_tracker_source]" : "Raid already in system" }}'}
     end
    end
  end

  # PUT /raid_events/1
  def update
    respond_to do |format|
      run_process = false
      valid = true
      if params[:raid_event]['raid_tracker_source'] != nil
        run_process = true
        doc = REXML::Document.new(params[:raid_event]['raid_tracker_source'])
        RaidEvent.find_all_by_begin_number(doc.root.get_text('start').to_s).each do |tempRaid|
          if tempRaid.id != @raid_event.id
            flash[:notice] = 'RaidEvent already in system'
            valid = false
          end
        end
      end
      if valid
        if @raid_event.update_attributes(params[:raid_event])
          # Process XML here
          @raid_event.process_source(@raid_event) if run_process
          
          flash[:notice] = 'RaidEvent was successfully updated.'
          format.ext_json { render(:update) {|page| page.redirect_to raid_events_path } }
        else
          format.ext_json { render :json => @raid_event.to_ext_json(:success => false) }
        end
      else
        format.ext_json { render :json => '{ success: false, errors: { "raid_event[raid_tracker_source]" : "Raid already in system" }}'}
      end
    end
  end

  # DELETE /raid_events/1
  def destroy
    # Remove the Raid's Dungeon's Roll Guides if the Raid was scheduled . To force regeneration
    if @raid_event.is_scheduled
      @raid_event.dungeon.guideRequests.each do |guideReq|
        guideReq.destroy
      end
    end
    @raid_event.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_raid_event
      @raid_event = RaidEvent.find(params[:id])
    end
    
    def find_raid_events
      pagination_state = update_pagination_state_with_params!(RaidEvent)
      @raid_events = RaidEvent.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(RaidEvent)))
  end
  
  def permission_denied
    flash[:notice] = "You don't have privileges to access this action"
    redirect_to :action => 'denied'
  end

  def permission_granted
    flash[:notice] = "Welcome to the secure area of foo.com!"
  end

end
