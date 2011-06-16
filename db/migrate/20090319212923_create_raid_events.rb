class CreateRaidEvents < ActiveRecord::Migration
  def self.up
    create_table :raid_events do |t|
      t.string :name
      t.integer :dungeon_id
      t.datetime :begin_date
      t.datetime :end_date
      t.boolean :is_scheduled
      t.integer :time_chunks
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :raid_events
  end
end
