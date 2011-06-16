class ToonClassesController < ApplicationController

  before_filter :find_toon_class, :only => [ :show, :edit, :update, :destroy ]
  before_filter :login_required, :except => [:index, :show]

  # GET /toon_classes
  # GET /toon_classes.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_toon_classes.to_ext_json(:class => ToonClass, :count => ToonClass.count(options_from_search(ToonClass))) }
    end
  end

  # GET /toon_classes/1
  def show
    # show.html.erb
  end

  # GET /toon_classes/new
  def new
    @toon_class = ToonClass.new(params[:toon_class])
    # new.html.erb
  end

  # GET /toon_classes/1/edit
  def edit
    # edit.html.erb
  end

  # POST /toon_classes
  def create
    @toon_class = ToonClass.new(params[:toon_class])

    respond_to do |format|
      if @toon_class.save
        flash[:notice] = 'ToonClass was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to toon_classes_path } }
      else
        format.ext_json { render :json => @toon_class.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /toon_classes/1
  def update
    respond_to do |format|
      if @toon_class.update_attributes(params[:toon_class])
        flash[:notice] = 'ToonClass was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to toon_classes_path } }
      else
        format.ext_json { render :json => @toon_class.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /toon_classes/1
  def destroy
    @toon_class.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
  def find_toon_class
    @toon_class = ToonClass.find(params[:id])
  end
  
  def find_toon_classes
    pagination_state = update_pagination_state_with_params!(ToonClass)
    @toon_classes = ToonClass.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(ToonClass)))
  end
  
  def permission_denied
    flash[:notice] = "You don't have privileges to access this action"
    return redirect_to :action => 'denied'
  end

  def permission_granted
    flash[:notice] = "Welcome to the secure area of foo.com!"
  end

end
