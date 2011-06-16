class CreateToons < ActiveRecord::Migration
  def self.up
    create_table :toons do |t|
      t.integer :member_id
      t.string :name
      t.boolean :is_main
      t.string :spec_note
      t.integer :level
      t.string :guild
      t.string :armory_url
      t.string :heroes_url
      t.integer :toonClass_id

      t.timestamps
    end
  end

  def self.down
    drop_table :toons
  end
end
