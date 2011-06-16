class AddInstanceToRaidEvent < ActiveRecord::Migration
  def self.up
    add_column :raid_events, :instance, :string
  end

  def self.down
    remove_column :raid_events, :instance
  end
end
