class AddIsNonrunToRaidEvent < ActiveRecord::Migration
  def self.up
    add_column :raid_events, :is_nonrun, :boolean
  end

  def self.down
    remove_column :raid_events, :is_nonrun
  end
end
