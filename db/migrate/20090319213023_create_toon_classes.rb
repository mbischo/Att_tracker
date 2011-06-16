class CreateToonClasses < ActiveRecord::Migration
  def self.up
    create_table :toon_classes do |t|
      t.string :name
      t.string :icon

      t.timestamps
    end
  end

  def self.down
    drop_table :toon_classes
  end
end
