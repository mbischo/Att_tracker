class CreateToonRollGuides < ActiveRecord::Migration
  def self.up
    create_table :toon_roll_guides do |t|
      t.integer :toon_id
      t.integer :guide_request_id
      t.integer :roll_percentage

      t.timestamps
    end
  end

  def self.down
    drop_table :toon_roll_guides
  end
end
