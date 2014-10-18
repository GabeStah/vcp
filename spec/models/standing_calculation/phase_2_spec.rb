require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do
  describe 'phase 2 events' do
    before do
      @character_one = Character.create!(achievement_points: 1500,
                                         character_class: FactoryGirl.create(:character_class),
                                         gender: 0,
                                         guild: FactoryGirl.create(:guild),
                                         level: 90,
                                         region: 'us',
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
                                           name: "Kulldar3",
                                           race: FactoryGirl.create(:race),
                                           rank: 9,
                                           realm: 'Hyjal',
                                           user: FactoryGirl.create(:user),
                                           verified: true)
      @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: Time.zone.now, ended_at: 4.hours.from_now)
      # Create participation data
      @standing_one = Standing.create!(active: true, character: @character_one, points: -1)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, points: 1)
      @standing_count = Standing.all.size
      @raid = Raid.find(@raid)
    end

    before :each do
      @raid.update_column(:processed, false)
    end

    # SCENARIO:
    # #1 offline at raid_start
    # #1 Online before cutoff
    # #1 destroy delinquency
    # EXPECT:
    # #1 attendance_gain (Standard)
    # #1 delinquent_loss (% of Standard from cutoff)
    # #2 deliquent_gain (% of Standard from cutoff / num_other_players)
    it 'offline at raid start, online during cutoff, destroy event' do
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: (@raid.started_at + 45.minutes),
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq Settings.standing.delinquent_loss * 0.75
      expect(Standing.find(@standing_one).points).to eq -1 + Settings.standing.attendance_gain + Settings.standing.delinquent_loss * 0.75

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      @standing_events_one[1].destroy

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(Standing.find(@standing_one).points).to eq -1 + Settings.standing.attendance_gain

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
    it 'offline at raid start, online during cutoff, update event' do
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: (@raid.started_at + 45.minutes),
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq Settings.standing.delinquent_loss * 0.75
      expect(Standing.find(@standing_one).points).to eq -1 + Settings.standing.attendance_gain + Settings.standing.delinquent_loss * 0.75

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      @standing_events_one[1].update(change: Settings.standing.delinquent_loss * 0.4)

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq Settings.standing.delinquent_loss * 0.4
      expect(Standing.find(@standing_one).points).to eq -1 + Settings.standing.attendance_gain + Settings.standing.delinquent_loss * 0.4

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.4 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.4 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.4 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.4 * -1) / (@standing_count - 1), 6)
    end

    # SCENARIO:
    # #1 offline at raid_start
    # #1 Online before cutoff
    # #1 participation.update from 45 minutes late to 10 minutes late
    # EXPECT:
    # #1 attendance_gain (Standard)
    # #1 delinquent_loss (% of Standard from cutoff)
    # #2/#3 deliquent_gain (% of Standard from cutoff / num_other_players)
    # participation.update
    # #1 attendance_gain
    # #1 delinquent_loss (% of Standard from cutoff for 15 min)
    # #2/#3 deliquent_gain (% of Standard from cutoff for 15 min / num_other_players)
    it 'offline at raid start, online during cutoff, participation update' do
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: (@raid.started_at + 45.minutes),
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq Settings.standing.delinquent_loss * 0.75
      expect(Standing.find(@standing_one).points).to eq -1 + Settings.standing.attendance_gain + Settings.standing.delinquent_loss * 0.75

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      # Get Participations
      participations = Participation.where(raid: @raid, character: @character_one)
      participations[1].update(timestamp:(@raid.started_at + 15.minutes))

      current_change = Settings.standing.delinquent_loss.to_f * 0.25 * 2

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq current_change / 2.to_f
      expect(Standing.find(@standing_one).points).to eq -1 + Settings.standing.attendance_gain + current_change.to_f / 2

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)
    end

    # SCENARIO:
    # #1 offline at raid_start
    # #1 Online before cutoff
    # #1 participation.destroy, never online
    # EXPECT:
    # #1 attendance_gain
    # #1 delinquent_loss (% of Standard from cutoff)
    # #2/#3 deliquent_gain (% of Standard from cutoff / num_other_players)
    # participation.update
    # #1 delinquent_loss (% of Standard from cutoff)
    # #2/#3 deliquent_gain (% of Standard from cutoff / num_other_players)
    it 'offline at raid start, online during cutoff, participation destroy' do
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: @raid.started_at,
                            online: false,
                            in_raid: false)
      Participation.create!(character: @character_one, raid: @raid,
                            timestamp: (@raid.started_at + 45.minutes),
                            online: true,
                            in_raid: false)
      @raid.process_standing_events

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq Settings.standing.delinquent_loss * 0.75
      expect(Standing.find(@standing_one).points).to eq -1 + Settings.standing.attendance_gain + Settings.standing.delinquent_loss * 0.75

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)

      # Get Participations
      participations = Participation.where(raid: @raid, character: @character_one)
      participations[1].destroy

      current_change = Settings.standing.delinquent_loss.to_f * 2

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :delinquent.to_s
      expect(@standing_events_one[0].change).to eq current_change.to_f / 2
      expect(Standing.find(@standing_one).points).to eq -1 + current_change.to_f / 2

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((current_change * -1) / (@standing_count - 1), 6)
    end
  end
end