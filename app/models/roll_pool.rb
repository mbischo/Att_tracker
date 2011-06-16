class RollPool < ActiveRecord::Base
  has_and_belongs_to_many :dungeons
  has_many :guideRequests, :dependent  => :delete_all
  
  def RollPool.getOrCreateGuideRequest(roll_pool) 
    # Find a Guide Request from today, generate one if it doesn't exist
      now = DateTime.new(Time.now.year,Time.now.month,Time.now.day)
      window_start = now - 30
      
      currentRequest = GuideRequest.find_by_request_date_and_roll_pool_id(now,roll_pool.id)
      
      if currentRequest == nil
        
        # Clean out old Guide requests for this Pool (now keeping them around for history charts)
#        GuideRequest.find_all_by_roll_pool_id( roll_pool.id).each do |oldGuideRequest|
#          oldGuideRequest.destroy
#        end
        
        currentRequest = GuideRequest.new
        currentRequest.request_date = now
        currentRequest.window_start_date = window_start
        currentRequest.rollPool = roll_pool
        currentRequest.save
      
        scheduled_raids = nil
        
        roll_pool.dungeons.each do |currentDungeon|
          if scheduled_raids == nil
            scheduled_raids = RaidEvent.find(:all, :conditions => { :begin_date => window_start..(now + 1), :dungeon_id => currentDungeon.id, :is_scheduled => true})
          else
            scheduled_raids.concat(RaidEvent.find(:all, :conditions => { :begin_date => window_start..(now + 1), :dungeon_id => currentDungeon.id, :is_scheduled => true}))
          end
          
        end
        totalChunks = 0
        memberList = Hash.new
        toonList = Hash.new
        
        scheduled_raids.each do |currentRaid|
          totalChunks += currentRaid.time_chunks # Add up total time chunks for time period
          
          # Accumulating times for member and toon specific roll guides
          currentRaid.memberParticipations.each do |currentPart|
            runningMemberTotal = memberList[currentPart.member]
            runningToonTotal = toonList[currentPart.toon]
            if runningMemberTotal == nil
              runningMemberTotal = 0
            end
            if runningToonTotal == nil
              runningToonTotal = 0
            end
            memberList[currentPart.member] = runningMemberTotal + currentPart.time_chunks_played
            toonList[currentPart.toon] = runningToonTotal + currentPart.time_chunks_played
          end
          
        end
        
        # Persist member-specific roll guides
        memberList.each_pair { |key, value|
          mem_guide = MemberRollGuide.new
          mem_guide.member = key
          #mem_guide.dungeon = dungeon
          mem_guide.roll_percentage = (value * 100) / totalChunks
          
          currentRequest.memberRollGuides << mem_guide
          
          mem_guide.save
        }
        
        # Persist toon-specific roll guides
        toonList.each_pair { |key, value|
          toon_guide = ToonRollGuide.new
          toon_guide.toon = key
          #mem_guide.dungeon = dungeon
          toon_guide.roll_percentage = (value * 100) / totalChunks
          
          currentRequest.toonRollGuides << toon_guide
          
          toon_guide.save
        }
        
      end # currentRequest != nil
      
      currentRequest
  end
end
