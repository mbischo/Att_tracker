class ToonRollGuide < ActiveRecord::Base
  belongs_to :guide_request
  belongs_to :toon
end
