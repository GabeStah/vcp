require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do
  describe 'retire calculations' do
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
      # Create participation data
      @standing_one = Standing.create!(active: true, character: @character_one, points: -1)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, points: 1)
      @standing_count = Standing.all.size
    end

    # SCENARIO:
    # #1 retire
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
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[1].type).to eq :retire.to_s
      expect(@standing_events_one[1].change).to eq 0
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[1].type).to eq :retire.to_s
      expect(@standing_events_two[1].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[1].type).to eq :retire.to_s
      expect(@standing_events_three[1].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      expect(Standing.total_points).to eq 0

      @standing_one.resume

      expect(@standing_one.active).to eq true

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 3
      expect(@standing_events_one[2].type).to eq :resume.to_s
      expect(@standing_events_one[2].change).to eq 0
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 3
      expect(@standing_events_two[2].type).to eq :resume.to_s
      expect(@standing_events_two[2].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq @standing_two.points

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 3
      expect(@standing_events_three[2].type).to eq :resume.to_s
      expect(@standing_events_three[2].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)
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
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[1].type).to eq :retire.to_s
      expect(@standing_events_one[1].change).to eq 0

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[1].type).to eq :retire.to_s
      expect(@standing_events_two[1].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[1].type).to eq :retire.to_s
      expect(@standing_events_three[1].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      expect(Standing.total_points).to eq 0

      @standing_one.resume

      expect(@standing_one.active).to eq true

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 3
      expect(@standing_events_one[2].type).to eq :resume.to_s
      expect(@standing_events_one[2].change).to eq 0

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 3
      expect(@standing_events_two[2].type).to eq :resume.to_s
      expect(@standing_events_two[2].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 3
      expect(@standing_events_three[2].type).to eq :resume.to_s
      expect(@standing_events_three[2].change).to eq BigDecimal.new((@standing_one.points) * -1 / (@standing_count - 1), 6)

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
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[1].type).to eq :retire.to_s
      expect(@standing_events_one[1].change).to eq 0
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[1].type).to eq :retire.to_s
      expect(@standing_events_two[1].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[1].type).to eq :retire.to_s
      expect(@standing_events_three[1].change).to eq BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + BigDecimal.new((@standing_one.points) / (@standing_count - 1), 6)

      expect(Standing.total_points).to eq 0

      @standing_events_one[1].destroy

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(Standing.find(@standing_two).points).to eq @standing_two.points

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(Standing.find(@standing_three).points).to eq @standing_three.points

      expect(Standing.total_points).to eq @standing_two.points + @standing_three.points
    end

    # SCENARIO:
    # EXPECT:
    it 'recent Character.joined_standing' do
      @character_one = Character.find(@character_one.id)

      @standing_one = @character_one.standing

      expect(@standing_one.active).to eq true
    end

    # SCENARIO:
    # EXPECT:
    it 'multiple retirement/resume' do
      # @character_one = Character.find(@character_one.id)
      #
      # @standing_one = @character_one.standing
      #
      # expect(@standing_one.active).to eq true
    end
  end
end