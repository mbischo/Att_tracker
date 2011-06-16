class GuideRequestsController < ApplicationController
  
  #before_filter :find_guide_request, :only => [ :show ]
  
  # GET /guide_request/1
  def show
    @guide_request = GuideRequest.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => @guide_request.toonRollGuides.to_json(:include => :toon)}
    end
    
  end

end