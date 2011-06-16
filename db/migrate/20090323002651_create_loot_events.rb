class CreateLootEvents < ActiveRecord::Migration
  def self.up
    create_table :loot_events do |t|
      t.string :item_name
      t.datetime :loot_date
      t.integer :raid_event_id
      t.integer :boss_kill_id
      t.integer :toon_id

      t.timestamps
    end
  end

  def self.down
    drop_table :loot_events
  end
end
