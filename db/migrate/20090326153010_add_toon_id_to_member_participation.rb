class AddToonIdToMemberParticipation < ActiveRecord::Migration
  def self.up
    add_column :member_participations, :toon_id, :integer
  end

  def self.down
    remove_column :member_participations, :toon_id
  end
end
