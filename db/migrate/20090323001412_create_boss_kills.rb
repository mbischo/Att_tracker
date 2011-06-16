class CreateBossKills < ActiveRecord::Migration
  def self.up
    create_table :boss_kills do |t|
      t.string :boss_name
      t.datetime :kill_date
      t.integer :raid_event_id

      t.timestamps
    end
  end

  def self.down
    drop_table :boss_kills
  end
end
