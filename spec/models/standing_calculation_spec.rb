require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do

  describe 'phase 1 events' do
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
      @standing = Standing.create!(active: true, character: @character)
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
      expect(@standing_event.change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
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
      expect(@standing_event.change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
    end

    # SCENARIO:
    # Offline at raid_start
    # Online before cutoff
    # EXPECT:
    # attendance_gain (Standard)
    # delinquent_loss (% of Standard from cutoff)
    it 'multi-event: offline at raid start, online during cutoff' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 45.minutes).to_datetime,
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_gain]
      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.75
    end

    # SCENARIO:
    # Offline at raid_start
    # Online before cutoff
    # Invited before cutoff
    # EXPECT:
    # attendance_loss (Standard)
    # delinquent_loss (% of Standard from cutoff)
    it 'multi-event: offline, then online during cutoff, then joins raid during cutoff' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 15.minutes).to_datetime,
                            online: true,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 20.minutes).to_datetime,
                            online: true,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25
    end

    # SCENARIO:
    # Offline at raid_start
    # Online after cutoff
    # EXPECT:
    # delinquent_loss (100% of delinquent_loss)
    it 'multi-event: offline until after cutoff' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 90.minutes).to_datetime,
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      expect(@standing_events[0].type).to eq :delinquent.to_s
      expect(@standing_events[0].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss]
    end

    # SCENARIO:
    # Online before raid_start
    # Offline after raid_start
    # EXPECT:
    # delinquent_loss (100% of standard Standard)
    it 'multi-event: online before raid, then offline after raid start' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time - 5.minutes).to_datetime,
                            online: true,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 15.minutes).to_datetime,
                            online: false,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      expect(@standing_events[0].type).to eq :delinquent.to_s
      expect(@standing_events[0].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss]
    end

    # SCENARIO:
    # Online and invited at raid_start
    # Offline in raid after attendance cutoff time
    # EXPECT:
    # attendance_loss
    # delinquent_loss (% of unattended cutoff time)
    it 'multi-event: online at raid start, invited at raid start, offline and in raid during cutoff' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: true,
                            in_raid: true)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 25.minutes).to_datetime,
                            online: false,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq BigDecimal.new(DEFAULT_SITE_SETTINGS[:delinquent_loss] * 35/60, 6)
    end

    # SCENARIO:
    # Online and invited at raid_start
    # Offline in raid after attendance cutoff, but after deliquent_cutoff_time (30+ min)
    # EXPECT:
    # attendance_loss
    it 'multi-event: online at raid start, invited at raid start, offline and in raid during cutoff' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: true,
                            in_raid: true)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 35.minutes).to_datetime,
                            online: false,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
    end
  end

  describe 'raid alterations' do
    before do
      @kulldar = Character.create!(achievement_points: 1500,
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
      @mohx = Character.create!(achievement_points: 1500,
                                     character_class: FactoryGirl.create(:character_class),
                                     gender: 0,
                                     guild: FactoryGirl.create(:guild),
                                     level: 90,
                                     region: 'us',
                                     portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                     name: "Mohx",
                                     race: FactoryGirl.create(:race),
                                     rank: 9,
                                     realm: 'Hyjal',
                                     user: FactoryGirl.create(:user),
                                     verified: true)
      @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: DateTime.now, ended_at: 4.hours.from_now)
      # Create participation data
      @standing_kulldar = Standing.create!(active: true, character: @kulldar, created_at: DateTime.now - 30.minutes, points: -0.5)
      @standing_mohx = Standing.create!(active: true, character: @mohx,  created_at: DateTime.now - 30.minutes, points: 0.5)
      @raid = Raid.find(@raid)
    end

    # SCENARIO:
    # Raid update
    # EXPECT:
    # #1 attendance_loss (Standard)
    # Raid update
    # #1 StandingEvents should be reverted
    # #1 attendance_loss (Standard)
    # #1 delinquent_loss (25% of Standard)
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
                                       timestamp: (@raid.started_at + 15.minutes).to_datetime,
                                       online: true,
                                       in_raid: true)
      @raid.process_standing_events

      @standing_events_kulldar = StandingEvent.where(standing: @standing_kulldar, raid: @raid)
      expect(@standing_events_kulldar.size).to eq 2
      expect(@standing_events_kulldar[0].type).to eq :attendance.to_s
      expect(@standing_events_kulldar[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
      expect(@standing_events_kulldar[1].type).to eq :delinquent.to_s
      expect(@standing_events_kulldar[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25 * -1
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points + DEFAULT_SITE_SETTINGS[:attendance_loss] + DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25 * -1

      @standing_events_mohx = StandingEvent.where(standing: @standing_mohx, raid: @raid)
      expect(@standing_events_mohx.size).to eq 2
      expect(@standing_events_mohx[0].type).to eq :attendance.to_s
      expect(@standing_events_mohx[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
      expect(@standing_events_mohx[1].type).to eq :delinquent.to_s
      expect(@standing_events_mohx[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25
      expect(Standing.find(@standing_mohx).points).to eq @standing_mohx.points + DEFAULT_SITE_SETTINGS[:attendance_loss] + DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25

      # update raid
      @raid.update(started_at: (@raid.started_at - 15.minutes).to_datetime)

      @participations = Participation.where(character: @kulldar, raid: @raid)
      expect(@participations.size).to eq 1

      @standing_events_kulldar = StandingEvent.where(standing: @standing_kulldar)
      expect(@standing_events_kulldar.size).to eq 3
      # Normal attendance
      expect(@standing_events_kulldar[0].type).to eq :attendance.to_s
      expect(@standing_events_kulldar[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
      # Personal 25% delinquency loss
      expect(@standing_events_kulldar[1].type).to eq :delinquent.to_s
      expect(@standing_events_kulldar[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25
      # 50% delinquency gain
      expect(@standing_events_kulldar[2].type).to eq :delinquent.to_s
      expect(@standing_events_kulldar[2].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.5 * -1
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points +
                                                              DEFAULT_SITE_SETTINGS[:attendance_loss] +
                                                              DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25 +
                                                              DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.5 * -1

      @standing_events_mohx = StandingEvent.where(standing: @standing_mohx, raid: @raid)
      expect(@standing_events_mohx.size).to eq 3
      # Normal attendance
      expect(@standing_events_mohx[0].type).to eq :attendance.to_s
      expect(@standing_events_mohx[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
      # Personal 50% delinquency loss
      expect(@standing_events_mohx[1].type).to eq :delinquent.to_s
      expect(@standing_events_mohx[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.5
      # 25% delinquency gain
      expect(@standing_events_mohx[2].type).to eq :delinquent.to_s
      expect(@standing_events_mohx[2].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25 * -1
      expect(Standing.find(@standing_mohx).points).to eq @standing_mohx.points +
                                                           DEFAULT_SITE_SETTINGS[:attendance_loss] +
                                                           DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.5 +
                                                           DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.25 * -1

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

      @standing_events_kulldar = StandingEvent.where(standing: @standing_kulldar)
      expect(@standing_events_kulldar.size).to eq 1
      expect(@standing_events_kulldar[0].type).to eq :attendance.to_s
      expect(@standing_events_kulldar[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_loss]
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points + DEFAULT_SITE_SETTINGS[:attendance_loss]

      # delete raid
      @raid.destroy

      @standing_events_kulldar = StandingEvent.where(standing: @standing_kulldar)
      expect(@standing_events_kulldar.size).to eq 0
      expect(Standing.find(@standing_kulldar).points).to eq @standing_kulldar.points

      expect(Participation.where(id: @participation)).to be_empty

    end
  end

  describe 'phase 2 events' do
    before do
      @character_one = Character.create!(achievement_points: 1500,
                                       character_class: FactoryGirl.create(:character_class),
                                       gender: 0,
                                       guild: FactoryGirl.create(:guild),
                                       level: 90,
                                       region: 'us',
                                       portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                       name: "Kulldar1",
                                       race: FactoryGirl.create(:race),
                                       rank: 9,
                                       realm: 'Hyjal',
                                       user: FactoryGirl.create(:user),
                                       verified: true)
      @character_two = Character.create!(achievement_points: 1500,
                                         character_class: FactoryGirl.create(:character_class),
                                         gender: 0,
                                         guild: FactoryGirl.create(:guild),
                                         level: 90,
                                         region: 'us',
                                         portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                         name: "Kulldar2",
                                         race: FactoryGirl.create(:race),
                                         rank: 9,
                                         realm: 'Hyjal',
                                         user: FactoryGirl.create(:user),
                                         verified: true)
      @character_three = Character.create!(achievement_points: 1500,
                                         character_class: FactoryGirl.create(:character_class),
                                         gender: 0,
                                         guild: FactoryGirl.create(:guild),
                                         level: 90,
                                         region: 'us',
                                         portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                         name: "Kulldar3",
                                         race: FactoryGirl.create(:race),
                                         rank: 9,
                                         realm: 'Hyjal',
                                         user: FactoryGirl.create(:user),
                                         verified: true)
      @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: DateTime.now, ended_at: 4.hours.from_now)
      # Create participation data
      @standing_one = Standing.create!(active: true, character: @character_one, points: -1)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, points: 1)
      @standing_count = Standing.all.size
      @raid = Raid.find(@raid)
    end

    # SCENARIO:
    # #1 offline at raid_start
    # #1 Online before cutoff
    # EXPECT:
    # #1 attendance_gain (Standard)
    # #1 delinquent_loss (% of Standard from cutoff)
    # #2 deliquent_gain (% of Standard from cutoff / num_other_players)
    it 'multi-event: offline at raid start, online during cutoff' do
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 45.minutes).to_datetime,
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_gain]
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.75
      expect(Standing.find(@standing_one).points).to eq -1 + DEFAULT_SITE_SETTINGS[:attendance_gain] + DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.75

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_one[1].destroy

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_gain]
      expect(Standing.find(@standing_one).points).to eq -1 + DEFAULT_SITE_SETTINGS[:attendance_gain]

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 0
      expect(Standing.find(@standing_two).points).to eq 0

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 0
      expect(Standing.find(@standing_three).points).to eq 1
    end

    # SCENARIO:
    # #1 offline at raid_start
    # #1 Online before cutoff
    # #1 delinquent_loss.update
    # EXPECT:
    # #1 attendance_gain (Standard)
    # #1 delinquent_loss (% of Standard from cutoff)
    # #2/#3 deliquent_gain (% of Standard from cutoff / num_other_players)
    # delinquent_loss.update
    # #1 delinquent_loss (% of Standard from cutoff)
    # #2/#3 deliquent_gain (% of Standard from cutoff / num_other_players)
    it 'multi-event: offline at raid start, online during cutoff' do
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: (@raid.started_at.to_time + 45.minutes).to_datetime,
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_gain]
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.75
      expect(Standing.find(@standing_one).points).to eq -1 + DEFAULT_SITE_SETTINGS[:attendance_gain] + DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.75

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_one[1].update(change: DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.4)

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq DEFAULT_SITE_SETTINGS[:attendance_gain]
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.4
      expect(Standing.find(@standing_one).points).to eq -1 + DEFAULT_SITE_SETTINGS[:attendance_gain] + DEFAULT_SITE_SETTINGS[:delinquent_loss] * 0.4

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.4 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.4 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.4 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((DEFAULT_SITE_SETTINGS[:delinquent_loss].to_f * 0.4 * -1) / (@standing_count - 1), 6)
    end
  end

  describe 'retirement calculations' do
    before do
      @character_one = Character.create!(achievement_points: 1500,
                                         character_class: FactoryGirl.create(:character_class),
                                         gender: 0,
                                         guild: FactoryGirl.create(:guild),
                                         level: 90,
                                         region: 'us',
                                         portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                         name: "Kulldar1",
                                         race: FactoryGirl.create(:race),
                                         rank: 9,
                                         realm: 'Hyjal',
                                         user: FactoryGirl.create(:user),
                                         verified: true)
      @character_two = Character.create!(achievement_points: 1500,
                                         character_class: FactoryGirl.create(:character_class),
                                         gender: 0,
                                         guild: FactoryGirl.create(:guild),
                                         level: 90,
                                         region: 'us',
                                         portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                         name: "Kulldar2",
                                         race: FactoryGirl.create(:race),
                                         rank: 9,
                                         realm: 'Hyjal',
                                         user: FactoryGirl.create(:user),
                                         verified: true)
      @character_three = Character.create!(achievement_points: 1500,
                                           character_class: FactoryGirl.create(:character_class),
                                           gender: 0,
                                           guild: FactoryGirl.create(:guild),
                                           level: 90,
                                           region: 'us',
                                           portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                                           name: "Kulldar3",
                                           race: FactoryGirl.create(:race),
                                           rank: 9,
                                           realm: 'Hyjal',
                                           user: FactoryGirl.create(:user),
                                           verified: true)
      # Create participation data
      @standing_one = Standing.create!(active: true, character: @character_one, points: -1)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, points: 1)
      @standing_count = Standing.all.size
    end

    # SCENARIO:
    # #1 retirement
    # #2 resume
    # EXPECT:
    # #1 active = false
    # #1 retirement (zero points change)
    # #2 retirement_loss (#1.points / 2)
    # #3 retirement_loss (#1.points / 2)
    # total_points = 0
    # resume
    # #1 active = true
    # #1 resume (zero points change)
    # #2 resume_gain (#1.points * -1 / 2)
    # #3 resume_gain (#1.points * -1 / 2)
    it 'retirement with negative points then resume' do
      @standing_one.retire

      expect(@standing_one.active).to eq false

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :retirement.to_s
      expect(@standing_events_one[0].change).to eq 0
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :retirement.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :retirement.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      expect(Standing.total_points).to eq 0

      @standing_one.resume

      expect(@standing_one.active).to eq true

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[1].type).to eq :resume.to_s
      expect(@standing_events_one[1].change).to eq 0
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[1].type).to eq :resume.to_s
      expect(@standing_events_two[1].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq @standing_two.points

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[1].type).to eq :resume.to_s
      expect(@standing_events_three[1].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq @standing_three.points

      expect(Standing.total_points).to eq 0
    end

    # SCENARIO:
    # #1 retirement
    # #2 resume
    # EXPECT:
    # #1 active = false
    # #1 retirement (zero points change)
    # #2 retirement_gain (#1.points / 2)
    # #3 retirement_gain (#1.points / 2)
    # total_points = 0
    # resume
    # #1 active = true
    # #1 resume (zero points change)
    # #2 resume_loss (#1.points * -1 / 2)
    # #3 resume_loss (#1.points * -1 / 2)
    it 'retirement with positive points then resume' do
      @standing_one.update(points: 1)
      @standing_two.update(points: 0)
      @standing_three.update(points: -1)
      @standing_one.retire

      expect(@standing_one.active).to eq false

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :retirement.to_s
      expect(@standing_events_one[0].change).to eq 0

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :retirement.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :retirement.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      expect(Standing.total_points).to eq 0

      @standing_one.resume

      expect(@standing_one.active).to eq true

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[1].type).to eq :resume.to_s
      expect(@standing_events_one[1].change).to eq 0

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[1].type).to eq :resume.to_s
      expect(@standing_events_two[1].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[1].type).to eq :resume.to_s
      expect(@standing_events_three[1].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)

      expect(Standing.total_points).to eq 0
    end

    # SCENARIO:
    # #1 retirement
    # EXPECT:
    # #1 active = false
    # #1 retirement (zero points change)
    # #2 retirement_loss (#1.points / 2)
    # #3 retirement_loss (#1.points / 2)
    # delete
    # #2 resume_gain (#1.points * -1 / 2)
    # #3 resume_gain (#1.points * -1 / 2)
    it 'retirement with negative points then delete' do
      @standing_one.retire

      expect(@standing_one.active).to eq false

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :retirement.to_s
      expect(@standing_events_one[0].change).to eq 0
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :retirement.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :retirement.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      expect(Standing.total_points).to eq 0

      @standing_events_one[0].destroy

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 0

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 0
      expect(Standing.find(@standing_two).points).to eq @standing_two.points

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 0
      expect(Standing.find(@standing_three).points).to eq @standing_three.points

      expect(Standing.total_points).to eq @standing_two.points + @standing_three.points
    end
  end

end

