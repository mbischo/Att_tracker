require 'rexml/document'

class RaidEvent < ActiveRecord::Base
  belongs_to :dungeon
  has_many :memberParticipations, :dependent  => :delete_all
  has_many :bossKills, :dependent  => :delete_all
  has_many :lootEvents, :dependent  => :delete_all

  def process_source(event)
    RaidEvent.transaction do
      doc = REXML::Document.new(event.raid_tracker_source)
      event.begin_date = Time.at(Integer(doc.root.get_text('start').to_s))
      event.begin_number = doc.root.get_text('start').to_s # For dupe checking
      
      if !event.is_nonrun
        event.end_date = Time.at(Integer(doc.root.get_text('end').to_s)).localtime
      end
      
      event.reporter = doc.root.get_text('exporter').to_s
      event.description += ' -- ' + doc.root.get_text('note').to_s if doc.root.get_text('note') != nil
      
      event.instance = doc.root.get_text('instanceid').to_s
      
      currentDungeon = nil
      if doc.root.get_text('difficulty').to_s == '2' then
        # Attach to Heroic Dungeon here
        currentDungeon = Dungeon.getOrCreateDungeon(doc.root.get_text('zone').to_s, 'Heroic')
      else
        # Attach to Normal Dungeon here
        currentDungeon = Dungeon.getOrCreateDungeon(doc.root.get_text('zone').to_s, 'Normal')
      end
      currentDungeon.raidEvents << event

      if !event.is_nonrun # Pull time chinks from CTRT data if it's a real run , otherwise use passed in value from UI
        event.time_chunks = (((event.end_date - event.begin_date)/60)/currentDungeon.chunk_size_in_min).round
      end
      event.save
      
      # Clear out all Auto generated Participations for this raid event
      event.memberParticipations.each do |memPart|
        if !memPart.is_manual
          memPart.destroy
        end
      end
      
      # Clear out all Boss Kills for this raid event
      event.bossKills.each do |bKill|
        bKill.destroy
      end
      
      # Clear out all Loot Events for this raid event
      event.lootEvents.each do |lEvent|
        lEvent.destroy
      end
      
      # Scan Players in Raid, create Member/Toons if needed
      doc.elements.each('raidinfo/playerinfos/player') do |ele|
        currentToon = Toon.find_by_name(ele.get_text('name').to_s)
        
        if currentToon == nil 
          puts ele.get_text('name').to_s + ' not in system ... adding'
          currentToon = Toon.new
          currentToon.name = ele.get_text('name').to_s
          currentToon.level = ele.get_text('level').to_s
          currentToon.toonClass = ToonClass.find(ele.get_text('class').to_s)
          currentToon.guild = ele.get_text('guild').to_s
          
          currentMember = Member.find_by_name(ele.get_text('name').to_s)
          
          if currentMember == nil
            currentMember = Member.new
            currentMember.name = ele.get_text('name').to_s
            currentMember.main_toon = currentToon
            currentToon.is_main = true
          end
          
          currentMember.toons << currentToon
          
          currentMember.save
          currentToon.save
        end
        
        time_chunks_for_player = 0
        
        if !event.is_nonrun
          # Scan Joins and Leaves for each Player
          count = 0
          minutes_in_raid = 0
          
          leaveEvents = doc.root.get_elements('leaves/leave[player=\'' + currentToon.name + '\']')
          
          doc.elements.each('raidinfo/joins/join[player=\'' + currentToon.name + '\']') do |joinEvent|
            startTime = Time.at(Integer(joinEvent.get_text('time').to_s))
            endTime = Time.at(Integer(leaveEvents[count].get_text('time').to_s))
            minutes_in_raid += ((endTime - startTime)/60)
            count += 1
          end
          time_chunks_for_player = (minutes_in_raid/event.dungeon.chunk_size_in_min).round
        else
          # For a non-run, credit player with full value entered by hand
          time_chunks_for_player = event.time_chunks
        end
        
        # Create a Member Participation Record
        newPart = MemberParticipation.new
        newPart.time_chunks_played = time_chunks_for_player
        newPart.is_manual = false
        event.memberParticipations << newPart
        currentToon.member.memberParticipations << newPart
        currentToon.memberParticipations << newPart
        newPart.save
      end
      
      if !event.is_nonrun
        # Process Boss Kills
        doc.elements.each('raidinfo/bosskills/bosskill') do |bossKill|
          newBossKill = BossKill.new
          newBossKill.boss_name = bossKill.get_text('name').to_s
          newBossKill.kill_date = Time.at(Integer(bossKill.get_text('time').to_s))
          event.bossKills << newBossKill
          newBossKill.save
        end
        # Process Loot
        doc.elements.each('raidinfo/loots/loot') do |loot|
          if (loot.get_text('note') == nil || ( (loot.get_text('note') != nil) && (loot.get_text('note').to_s != 'de') ))  
            newLootEvent = LootEvent.new
            newLootEvent.item_name = loot.get_text('itemname').to_s
            newLootEvent.loot_date = Time.at(Integer(loot.get_text('time').to_s))
            
            Toon.find_by_name(loot.get_text('player').to_s).lootEvents << newLootEvent
            if loot.get_text('note').to_s =~ /[N,n]eed/
              newLootEvent.loot_type = 'need'
            elsif loot.get_text('note').to_s =~ /[G,g]reed/
              newLootEvent.loot_type = 'greed'
            end
            
            # Trash Mob handling
            curBoss = BossKill.find(:first,:conditions => { :boss_name => loot.get_text('boss').to_s, :raid_event_id => event.id });
            if curBoss == nil
              newBossKill = BossKill.new
              newBossKill.boss_name = loot.get_text('boss').to_s
              newBossKill.kill_date = newLootEvent.loot_date
              event.bossKills << newBossKill
              newBossKill.save
              curBoss = newBossKill
            end
            curBoss.lootEvents << newLootEvent
            
            event.lootEvents << newLootEvent
            newLootEvent.save
          end # end de text checking
        end
      
      end # end of nonrun check
      
      # Times might be updated , clear out Dungeon's Roll Guides
      currentDungeon.guideRequests.each do |request|
        request.destroy
      end
      
      currentDungeon.rollPools.each do |pool|
        pool.guideRequests.each do |request|
          request.destroy
        end
      end
    
    end # Transaction end

  end
  
end
