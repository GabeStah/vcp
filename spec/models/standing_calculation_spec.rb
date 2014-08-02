require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do

  describe 'joined raid and online at raid.start_at' do
    # 1. timestamp: @raid.started_at - 5.minutes, online: true, in_raid: false
    # 2. timestamp: @raid.started_at, online: true, in_raid: true
    before do
      @character = Character.create!(achievement_points: 1500,
                                     character_class: FactoryGirl.create(:character_class),
                                     gender: 0,
                                     guild: FactoryGirl.create(:guild),
                                     level: 90,
                                     region: 'us',
                                     portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                     name: "Kulldar",
                                     race: FactoryGirl.create(:race),
                                     rank: 9,
                                     realm: 'Hyjal',
                                     user: FactoryGirl.create(:user),
                                     verified: true)
      @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: DateTime.now, ended_at: 4.hours.from_now)
      # Create participation data
      @standing = Standing.create!(character: @character)
      # 1. timestamp: @raid.started_at - 5.minutes, online: true, in_raid: false
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time - 5.minutes).to_datetime,
                            online: true,
                            in_raid: true)
      # 2. timestamp: @raid.started_at, online: true, in_raid: true
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: true,
                            in_raid: true)
      @raid = Raid.find(@raid)
      @raid.process_standing_events
    end

    it 'single event, attendance_loss' do
      @raid = Raid.find(@raid)
      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      @standing_event = @standing_events.first
      expect(@standing_event.type).to eq :attendance
      expect(@standing_event.change).to eq -DEFAULT_SITE_SETTINGS[:attendance_cost]
    end
  end

end

