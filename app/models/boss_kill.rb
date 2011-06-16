class BossKill < ActiveRecord::Base
  belongs_to :raid_event
  has_many :lootEvents
end
