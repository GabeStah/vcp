require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do

  describe 'raid alterations' do
    before do
      @kulldar = Character.create!(achievement_points: 1500,
                                   character_class: FactoryGirl.create(:character_class),
                                   gender: 0,
                                   guild: FactoryGirl.create(:guild),
                                   level: 90,
                                   region: 'us',
                                   name: "Kulldar",
                                   race: FactoryGirl.create(:race),
                                   rank: 9,
                                   realm: 'Hyjal',
                                   user: FactoryGirl.create(:user),
                                   verified: true)
      @mohx = Character.create!(achievement_points: 1500,
                                character_class: FactoryGirl.create(:character_class),
                                gender: 0,
                                guild: FactoryGirl.create(:guild),
                                level: 90,
                                region: 'us',
                                name: "Mohx",
                                race: FactoryGirl.create(:race),
                                rank: 9,
                                realm: 'Hyjal',
                                user: FactoryGirl.create(:user),
                                verified: true)
      @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: Time.zone.now, ended_at: 4.hours.from_now)
      # Create participation data
      @standing_kulldar = Standing.create!(active: true, character: @kulldar, created_at: Time.zone.now - 30.minutes, points: -0.5)
      @standing_mohx = Standing.create!(active: true, character: @mohx,  created_at: Time.zone.now - 30.minutes, points: 0.5)
      @raid = Raid.find(@raid)
    end
    before :each do
      @raid.update_column(:processed, false)
    end


    # SCENARIO:
    # Raid update
    # EXPECT:
    # #1 attendance_loss (Standard)
    # Raid update
    # #1 StandingEvents should be reverted
    # #1 attendance_loss (Standard)
    # #1 delinquent_loss (25% of Standard)
    # PURPOSE
    # Ensure raid.update causes recreation of appropriate StandingEvent records
    it 'update raid' do
      Participation.create!(character: @kulldar, raid: @raid,
                            timestamp: @raid.started_at,
                            online: true,
                            in_raid: true)
      Participation.create!(character: @mohx, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @mohx, raid: @raid,
                            timestamp: (@raid.started_at + 15.minutes),
                            online: true,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events_kulldar = StandingEvent.where(standing: @standing_kulldar, raid: @raid)
      expect(@standing_events_kulldar.size).to eq 2
      expect(@standing_events_kulldar[0].type).to eq :attendance.to_s
      expect(@standing_events_kulldar[0].change).to eq @raid.attendance_loss
      expect(@standing_events_kulldar[1].type).to eq :delinquent.to_s
      expect(@standing_events_kulldar[1].change).to eq Settings.standing.delinquent_loss * 0.25 * -1
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points + @raid.attendance_loss + Settings.standing.delinquent_loss * 0.25 * -1

      @standing_events_mohx = StandingEvent.where(standing: @standing_mohx, raid: @raid)
      expect(@standing_events_mohx.size).to eq 2
      expect(@standing_events_mohx[0].type).to eq :attendance.to_s
      expect(@standing_events_mohx[0].change).to eq @raid.attendance_loss
      expect(@standing_events_mohx[1].type).to eq :delinquent.to_s
      expect(@standing_events_mohx[1].change).to eq Settings.standing.delinquent_loss * 0.25
      expect(Standing.find(@standing_mohx).points).to eq @standing_mohx.points + @raid.attendance_loss + Settings.standing.delinquent_loss * 0.25

      # update raid
      @raid.update(started_at: (@raid.started_at - 15.minutes))

      @participations = Participation.where(character: @kulldar, raid: @raid)
      expect(@participations.size).to eq 1

      @standing_events_kulldar = StandingEvent.where(raid: @raid, standing: @standing_kulldar)
      expect(@standing_events_kulldar.size).to eq 3
      # Normal attendance
      expect(@standing_events_kulldar[0].type).to eq :attendance.to_s
      expect(@standing_events_kulldar[0].change).to eq @raid.attendance_loss
      # Personal 25% delinquency loss
      expect(@standing_events_kulldar[1].type).to eq :delinquent.to_s
      expect(@standing_events_kulldar[1].change).to eq Settings.standing.delinquent_loss * 0.25
      # 50% delinquency gain
      expect(@standing_events_kulldar[2].type).to eq :delinquent.to_s
      expect(@standing_events_kulldar[2].change).to eq Settings.standing.delinquent_loss * 0.5 * -1
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points +
                                                              @raid.attendance_loss +
                                                              Settings.standing.delinquent_loss * 0.25 +
                                                              Settings.standing.delinquent_loss * 0.5 * -1

      @standing_events_mohx = StandingEvent.where(standing: @standing_mohx, raid: @raid)
      expect(@standing_events_mohx.size).to eq 3
      # 25% delinquency gain
      expect(@standing_events_mohx[0].type).to eq :delinquent.to_s
      expect(@standing_events_mohx[0].change).to eq Settings.standing.delinquent_loss * 0.25 * -1
      # Normal attendance
      expect(@standing_events_mohx[1].type).to eq :attendance.to_s
      expect(@standing_events_mohx[1].change).to eq @raid.attendance_loss
      # Personal 50% delinquency loss
      expect(@standing_events_mohx[2].type).to eq :delinquent.to_s
      expect(@standing_events_mohx[2].change).to eq Settings.standing.delinquent_loss * 0.5
      expect(Standing.find(@standing_mohx).points).to eq @standing_mohx.points +
                                                           @raid.attendance_loss +
                                                           Settings.standing.delinquent_loss * 0.5 +
                                                           Settings.standing.delinquent_loss * 0.25 * -1

    end

    # SCENARIO:
    # Raid deleted
    # EXPECT:
    # #1 attendance_loss (Standard)
    # Raid deleted
    # #1 reversion
    it 'delete raid' do
      @participation = Participation.create!(character: @kulldar, raid: @raid,
                                             timestamp: @raid.started_at,
                                             online: true,
                                             in_raid: true)
      @raid.process_standing_events

      @standing_events_kulldar = StandingEvent.where(raid: @raid, standing: @standing_kulldar)
      expect(@standing_events_kulldar.size).to eq 1
      expect(@standing_events_kulldar[0].type).to eq :attendance.to_s
      expect(@standing_events_kulldar[0].change).to eq @raid.attendance_loss
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points + @raid.attendance_loss

      # delete raid
      @raid.destroy

      @standing_events_kulldar = StandingEvent.where(raid: @raid, standing: @standing_kulldar)
      expect(@standing_events_kulldar.size).to eq 0
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points

      expect(Participation.where(id: @participation)).to be_empty

    end
  end

end