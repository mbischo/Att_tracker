class AddIsManualToMemberParticipation < ActiveRecord::Migration
  def self.up
    add_column :member_participations, :is_manual, :boolean
  end

  def self.down
    remove_column :member_participations, :is_manual
  end
end
