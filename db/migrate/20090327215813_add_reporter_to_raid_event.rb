class AddReporterToRaidEvent < ActiveRecord::Migration
  def self.up
    add_column :raid_events, :reporter, :string
  end

  def self.down
    remove_column :raid_events, :reporter
  end
end
