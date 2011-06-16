class AddRaidTrackerSourceToRaidEvent < ActiveRecord::Migration
  def self.up
    add_column :raid_events, :raid_tracker_source, :text
  end

  def self.down
    remove_column :raid_events, :raid_tracker_source
  end
end
