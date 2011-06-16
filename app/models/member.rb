class Member < ActiveRecord::Base
  has_many :toons, :dependent  => :delete_all
  has_many :memberParticipations, :dependent  => :delete_all
  has_many :memberRollGuides, :dependent  => :delete_all
  belongs_to :main_toon, :class_name => "Toon", :foreign_key => "main_toon_id"
  
  has_many :lootEvents, :through => :toons
end