class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string :name
      t.integer :main_toon_id
      t.integer :epic_need_total
      t.integer :epic_greed_total

      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
