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
      @raid = Raid.find(@raid)
    end

    # SCENARIO: Online and in_raid at raid_start
    # EXPECT:
    # attendance_loss (Standard)
    it 'single event, attendance_loss' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: true,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      @standing_event = @standing_events.first
      expect(@standing_event.type).to eq :attendance.to_s
      expect(@standing_event.change).to eq -DEFAULT_SITE_SETTINGS[:attendance_cost]
    end

    # SCENARIO: Online at raid_start
    # EXPECT:
    # attendance_gain (Standard)
    it 'single event, attendance_gain' do
      # 1. timestamp: @raid.started_at, online: true, in_raid: false
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      @standing_event = @standing_events.first
      expect(@standing_event.type).to eq :attendance.to_s
      expect(@standing_event.change).to eq DEFAULT_SITE_SETTINGS[:attendance_gain]
    end

    # SCENARIO: Online, joins raid during cutoff
    # EXPECT:
    # attendance_loss (Standard)
    it 'multi-event: online, then joins raid during cutoff' do
      # 1. timestamp: @raid.started_at, online: true, in_raid: false
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: true,
                            in_raid: false)
      # 2. timestamp: @raid.started_at, online: true, in_raid: true
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 20.minutes).to_datetime,
                            online: true,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      @standing_event = @standing_events.first
      expect(@standing_event.type).to eq :attendance.to_s
      expect(@standing_event.change).to eq -DEFAULT_SITE_SETTINGS[:attendance_cost]
    end

    # SCENARIO:
    # Offline at raid_start
    # Online before cutoff
    # Invited before cutoff
    # EXPECT:
    # attendance_loss (Standard)
    # delinquent_loss (% of Standard from cutoff)
    it 'multi-event: online, then joins raid during cutoff' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 20.minutes).to_datetime,
                            online: true,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 25.minutes).to_datetime,
                            online: true,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq -DEFAULT_SITE_SETTINGS[:attendance_cost]
      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq -DEFAULT_SITE_SETTINGS[:attendance_cost]
    end
  end

end

