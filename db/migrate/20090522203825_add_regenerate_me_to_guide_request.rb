class AddRegenerateMeToGuideRequest < ActiveRecord::Migration
  def self.up
    add_column :guide_requests, :regenerate_me, :boolean
  end

  def self.down
    drop_column :guide_requests, :regenerate_me
  end
end
