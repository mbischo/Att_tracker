class Dungeon < ActiveRecord::Base
  has_many :raidEvents, :dependent  => :delete_all
  has_many :guideRequests, :dependent  => :delete_all
  has_many :memberGuideRequests
  has_and_belongs_to_many :rollPools
  
  def Dungeon.getOrCreateDungeon(dungName, dungMode)
    dungeonList = Dungeon.find_by_name_and_mode(dungName,dungMode)
    
    if (dungeonList == nil)
      output = Dungeon.new
      output.name = dungName
      output.mode = dungMode
      output.chunk_size_in_min = 15
      output.save
    elsif (dungeonList != nil) 
      output = dungeonList
    end
    
    output
  end
  
  def Dungeon.getOrCreateGuideRequest(dungeon) 
    # Find a Guide Request from today, generate one if it doesn't exist
      now = DateTime.new(Time.now.year,Time.now.month,Time.now.day)
      window_start = now - 30
      
      currentRequest = GuideRequest.find_by_request_date_and_dungeon_id(now,dungeon.id)
      
      if currentRequest == nil
        
        # Clean out old Guide requests for this Dungeon
        GuideRequest.find_all_by_dungeon_id( dungeon.id).each do |oldGuideRequest|
          oldGuideRequest.destroy
        end
        
        currentRequest = GuideRequest.new
        currentRequest.request_date = now
        currentRequest.window_start_date = window_start
        currentRequest.dungeon = dungeon
        currentRequest.save
      
      
        scheduled_raids = RaidEvent.find(:all, :conditions => { :begin_date => window_start..(now + 1), :dungeon_id => dungeon.id, :is_scheduled => true})
        totalChunks = 0
        memberList = Hash.new
        toonList = Hash.new
        
        scheduled_raids.each do |currentRaid|
          totalChunks += currentRaid.time_chunks # Add up total time chunks for time period
          
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
          mem_guide.dungeon = dungeon
          mem_guide.roll_percentage = (value * 100) / totalChunks
          
          currentRequest.memberRollGuides << mem_guide
          
          mem_guide.save
        }
        
        # Persist toon-specific roll guides
        toonList.each_pair { |key, value|
          toon_guide = ToonRollGuide.new
          toon_guide.toon = key
          toon_guide.roll_percentage = (value * 100) / totalChunks
          
          currentRequest.toonRollGuides << toon_guide
          
          toon_guide.save
        }
        
      end # currentRequest != nil
      
      currentRequest
  end
  
end
