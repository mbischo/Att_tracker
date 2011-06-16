class MemberRollGuide < ActiveRecord::Base
  belongs_to :guide_request
  belongs_to :dungeon
  belongs_to :member
end
