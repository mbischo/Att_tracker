class CreateMemberRollGuides < ActiveRecord::Migration
  def self.up
    create_table :member_roll_guides do |t|
      t.integer :member_id
      t.integer :dungeon_id
      t.integer :guide_request_id
      t.integer :roll_percentage

      t.timestamps
    end
  end

  def self.down
    drop_table :member_roll_guides
  end
end
