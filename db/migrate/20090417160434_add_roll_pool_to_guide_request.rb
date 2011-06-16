class AddRollPoolToGuideRequest < ActiveRecord::Migration
  def self.up
    add_column :guide_requests, :roll_pool_id, :integer
  end

  def self.down
    remove_column :guide_requests, :roll_pool_id
  end
end
