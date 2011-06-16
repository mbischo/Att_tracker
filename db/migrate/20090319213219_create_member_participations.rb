class CreateMemberParticipations < ActiveRecord::Migration
  def self.up
    create_table :member_participations do |t|
      t.integer :raid_event_id
      t.integer :member_id
      t.integer :time_chunks_played
      t.integer :epics_need
      t.integer :epics_greed
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :member_participations
  end
end
