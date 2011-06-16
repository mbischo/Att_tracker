class Toon < ActiveRecord::Base
  belongs_to :member
  belongs_to :toonClass
  has_many :lootEvents
  has_many :memberParticipations
end
