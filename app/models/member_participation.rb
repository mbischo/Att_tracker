class MemberParticipation < ActiveRecord::Base
  belongs_to :raidEvent, :foreign_key => 'raid_event_id'
  belongs_to :member
  belongs_to :toon
end
