class MemberParticipationsController < ApplicationController

  before_filter :find_member_participation, :only => [ :show, :edit, :update, :destroy ]

  # GET /member_participations
  # GET /member_participations.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_member_participations.to_ext_json(:class => MemberParticipation, :count => MemberParticipation.count(options_from_search(MemberParticipation))) }
    end
  end

  # GET /member_participations/1
  def show
    # show.html.erb
  end

  # GET /member_participations/new
  def new
    @member_participation = MemberParticipation.new(params[:member_participation])
    # new.html.erb
  end

  # GET /member_participations/1/edit
  def edit
    # edit.html.erb
  end

  # POST /member_participations
  def create
    @member_participation = MemberParticipation.new(params[:member_participation])

    respond_to do |format|
      if @member_participation.save
        flash[:notice] = 'MemberParticipation was successfully created.'
        format.ext_json { render :json => @member_participation.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @member_participation.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /member_participations/1
  def update
    respond_to do |format|
      if @member_participation.update_attributes(params[:member_participation])
        flash[:notice] = 'MemberParticipation was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to member_participations_path } }
      else
        format.ext_json { render :json => @member_participation.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /member_participations/1
  def destroy
    @member_participation.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_member_participation
      @member_participation = MemberParticipation.find(params[:id])
    end
    
    def find_member_participations
      pagination_state = update_pagination_state_with_params!(MemberParticipation)
      @member_participations = MemberParticipation.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(MemberParticipation)))
    end

end
