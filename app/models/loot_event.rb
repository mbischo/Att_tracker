class LootEvent < ActiveRecord::Base
  belongs_to :toon
  belongs_to :raidEvent
  belongs_to :bossKill, :foreign_key => 'boss_kill_id'
end
