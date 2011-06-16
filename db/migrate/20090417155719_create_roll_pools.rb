class CreateRollPools < ActiveRecord::Migration
  def self.up
    create_table :roll_pools do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :roll_pools
  end
end
