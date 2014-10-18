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
                                     name: "Kulldar",
                                     race: FactoryGirl.create(:race),
                                     rank: 9,
                                     realm: 'Hyjal',
                                     user: FactoryGirl.create(:user),
                                     verified: true)
      @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: Time.zone.now, ended_at: 4.hours.from_now)
      # Create participation data
      @standing = Standing.create!(active: true, character: @character)
      @raid = Raid.find(@raid)
    end
    before :each do
      @raid.update_column(:processed, false)
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
      expect(@standing_event.change).to eq @raid.attendance_loss
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
      expect(@standing_event.change).to eq Settings.standing.attendance_gain
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
                            timestamp: (@raid.started_at + 20.minutes),
                            online: true,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      @standing_event = @standing_events.first
      expect(@standing_event.type).to eq :attendance.to_s
      expect(@standing_event.change).to eq 0
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
                            timestamp: (@raid.started_at + 45.minutes),
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq Settings.standing.delinquent_loss * 0.75

      expect(@standing_events.absent?).to eq false
      expect(@standing_events.attended?(raid: @raid)).to eq false
      expect(@standing_events.unexcused_absence?).to eq false
      expect(@standing_events.sat?).to eq true
      expect(@standing_events.tardy?).to eq true
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
                            timestamp: (@raid.started_at + 15.minutes),
                            online: true,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at + 20.minutes),
                            online: true,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq @raid.attendance_loss
      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq Settings.standing.delinquent_loss * 0.25

      expect(@standing_events.absent?).to eq false
      expect(@standing_events.attended?(raid: @raid)).to eq true
      expect(@standing_events.unexcused_absence?).to eq false
      expect(@standing_events.sat?).to eq false
      expect(@standing_events.tardy?).to eq true
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
                            timestamp: (@raid.started_at + 90.minutes),
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      expect(@standing_events[0].type).to eq :delinquent.to_s
      expect(@standing_events[0].change).to eq Settings.standing.delinquent_loss

      expect(@standing_events.absent?).to eq true
      expect(@standing_events.attended?(raid: @raid)).to eq false
      expect(@standing_events.unexcused_absence?).to eq false
      expect(@standing_events.sat?).to eq false
      expect(@standing_events.tardy?).to eq false
    end

    # SCENARIO:
    # Offline at raid_start
    # Unexcused absence infraction
    # EXPECT:
    # delinquent_loss (100% of delinquent_loss)
    # infraction_loss (100% of unexcused_absence_loss)
    it 'unexcused absence' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      StandingEvent.create!(change: Settings.standing.unexcused_absence_loss,
                            raid: @raid,
                            standing: @standing,
                            type: :infraction)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :infraction.to_s
      expect(@standing_events[0].change).to eq Settings.standing.unexcused_absence_loss

      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq Settings.standing.delinquent_loss

      expect(@standing_events.absent?).to eq true
      expect(@standing_events.attended?(raid: @raid)).to eq false
      expect(@standing_events.unexcused_absence?).to eq true
      expect(@standing_events.sat?).to eq false
      expect(@standing_events.tardy?).to eq false
    end

    # SCENARIO:
    # Online before raid_start
    # Offline after raid_start
    # EXPECT:
    # delinquent_loss (100% of standard Standard)
    it 'multi-event: online before raid, then offline after raid start' do
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at - 5.minutes),
                            online: true,
                            in_raid: false)
      Participation.create!(character: @character, raid: @raid,
                            timestamp: (@raid.started_at + 15.minutes),
                            online: false,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      expect(@standing_events[0].type).to eq :delinquent.to_s
      expect(@standing_events[0].change).to eq Settings.standing.delinquent_loss
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
                            timestamp: (@raid.started_at + 25.minutes),
                            online: false,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 2
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq @raid.attendance_loss
      expect(@standing_events[1].type).to eq :delinquent.to_s
      expect(@standing_events[1].change).to eq BigDecimal.new(Settings.standing.delinquent_loss * 35/60, 8)
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
                            timestamp: (@raid.started_at + 35.minutes),
                            online: false,
                            in_raid: true)
      @raid.process_standing_events

      @standing_events = @raid.standing_events
      expect(@standing_events.size).to eq 1
      expect(@standing_events[0].type).to eq :attendance.to_s
      expect(@standing_events[0].change).to eq @raid.attendance_loss
    end
  end
end

