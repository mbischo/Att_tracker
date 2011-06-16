class CreateGuideRequests < ActiveRecord::Migration
  def self.up
    create_table :guide_requests do |t|
      t.datetime :request_date
      t.datetime :window_start_date
      t.integer :dungeon_id

      t.timestamps
    end
  end

  def self.down
    drop_table :guide_requests
  end
end
