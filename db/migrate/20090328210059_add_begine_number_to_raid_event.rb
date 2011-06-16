class AddBegineNumberToRaidEvent < ActiveRecord::Migration
  def self.up
    add_column :raid_events, :begin_number, :string
  end

  def self.down
    remove_column :raid_events, :begin_number
  end
end
