class AddTypeToLootEvent < ActiveRecord::Migration
  def self.up
     add_column :loot_events, :loot_type, :string
  end

  def self.down
    drop_column :loot_events, :loot_type
  end
end
