class CreateDungeons < ActiveRecord::Migration
  def self.up
    create_table :dungeons do |t|
      t.string :name
      t.string :mode
      t.integer :player_limit
      t.integer :chunk_size_in_min

      t.timestamps
    end
  end

  def self.down
    drop_table :dungeons
  end
end
