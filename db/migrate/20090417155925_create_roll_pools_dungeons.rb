class CreateRollPoolsDungeons < ActiveRecord::Migration
  def self.up
    create_table :dungeons_roll_pools, :id => false do |t|
      t.integer   :roll_pool_id
      t.integer   :dungeon_id
    end
  end

  def self.down
    drop_table :dungeons_roll_pools
  end
end
