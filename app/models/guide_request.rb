class GuideRequest < ActiveRecord::Base
  has_many :memberRollGuides, :dependent  => :delete_all
  has_many :toonRollGuides, :dependent  => :delete_all
  belongs_to :dungeon
  belongs_to :rollPool, :foreign_key => 'roll_pool_id'
  
  def GuideRequest.to_lua(guideReq) 
    output = "TrackerList = {\n" 
    output << '["ListSource"] = "';
    if guideReq.dungeon != nil
      output << guideReq.dungeon.mode + ' - ' + guideReq.dungeon.name
    else
      output << guideReq.rollPool.name
    end
    
    output << "\",\n"
    
    output << '["ListSourceId"] = ' + guideReq.id.to_s + ",\n"
    
#    guideReq.memberRollGuides.each do |memGuide|
#      memGuide.member.toons.each do |currentToon|
#        output << "  [\"" + currentToon.name + "\"] = " + memGuide.roll_percentage.to_s + ",\n"
#      end
#    end

    guideReq.toonRollGuides.each do |toonGuide|
      output << "  [\"" + toonGuide.toon.name + "\"] = " + toonGuide.roll_percentage.to_s + ",\n"
    end
    
    output << "  [\"Complete\"] = \"true\"\n"
    
    output << "}"
    output
  end
  
  def GuideRequest.recalculateRollGuides(member) 
#    puts 'Recalcing for Member: ' + member.name
    # Clean out old Member Roll Guides
    member.memberRollGuides.each do |memGuide|
#      puts 'Removing Mem Roll Guide: ' + memGuide.id.to_s
      memGuide.destroy
    end
    # Scan through GuideRequests and regenerate for member
    GuideRequest.find(:all).each do |guideReq|
      memberRollGuide = GuideRequest.generateRollGuideForMember(guideReq, member)
      if memberRollGuide != nil
        member.memberRollGuides << memberRollGuide
      end
    end
  end
  
  def GuideRequest.generateRollGuideForMember(guideReq, member)
    scheduled_raids = RaidEvent.find(:all, :conditions => { :begin_date => guideReq.window_start_date..guideReq.request_date,
      :dungeon_id => guideReq.dungeon_id, :is_scheduled => true})
      
#    puts 'Number of Raids: ' + scheduled_raids.length.to_s
    
    memberRunningTotal = 0
    dungeonTotalChunks = 0
    scheduled_raids.each do |currentRaid|
      dungeonTotalChunks += currentRaid.time_chunks
      currentRaid.memberParticipations.each do |currentPart|
        if currentPart.member == member
          memberRunningTotal += currentPart.time_chunks_played
        end
      end
      
    end
    mem_guide = nil
    if ( (dungeonTotalChunks > 0) and (memberRunningTotal > 0) )
#      puts 'Dungeon total: ' + dungeonTotalChunks.to_s
      
      mem_guide = MemberRollGuide.new
      mem_guide.dungeon = guideReq.dungeon
      mem_guide.roll_percentage = (memberRunningTotal * 100) / dungeonTotalChunks
      
      guideReq.memberRollGuides << mem_guide
      
      mem_guide.save
#    else
#      puts 'Guide not created for ' + member.name 
    end
    
    mem_guide
  end
end
