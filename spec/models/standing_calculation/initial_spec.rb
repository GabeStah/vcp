require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do
  describe 'initial calculations' do
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
    end

    # SCENARIO:
    # EXPECT:
    it 'create basic standings' do
      @standing_one = Standing.create!(active: true, character: @character_one)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq 0
      expect(Standing.find(@standing_one).points).to eq 0
    end

    # SCENARIO:
    # EXPECT:
    it 'with initial points' do
      @standing_one = Standing.create!(active: true, character: @character_one, points: 5)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq @standing_one.points
      expect(Standing.find(@standing_one).points).to eq @standing_one.points
    end

    it 'initial points for multiple users' do
      @standing_one = Standing.create!(active: true, character: @character_one, points: -2.5)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 2.5)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq @standing_one.points
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(Standing.find(@standing_two).points).to eq @standing_two.points
    end

    # SCENARIO
    # #1 created with -2 points
    # #2 created with 0 points
    # #3 created with 2 points and distribute true
    # EXPECTED
    # #1/#2 get second standing event with 2 / 2 * -1 change (inverse)
    it 'initial points for multiple users with distribe set' do
      @standing_one = Standing.create!(active: true, character: @character_one, points: -2)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, distribute: true, points: 2)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq @standing_one.points
      expect(@standing_events_one[1].type).to eq :initial.to_s
      expect(@standing_events_one[1].change).to eq @standing_three.points.to_f * -1 / 2
      expect(Standing.find(@standing_one).points).to eq @standing_one.points + (@standing_three.points.to_f * -1 / 2)

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :initial.to_s
      expect(@standing_events_two[1].change).to eq @standing_three.points.to_f * -1 / 2
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + (@standing_three.points.to_f * -1 / 2)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(Standing.find(@standing_three).points).to eq @standing_three.points
    end

    # SCENARIO
    # #1 created with -2 points
    # #2 created with 0 points
    # #3 created with 2 points and distribute true
    # #3 updated standing event value
    # EXPECTED
    # #1/#2 get second standing event with 2 / 2 * -1 change (inverse)
    it 'distribute then update' do
      @standing_one = Standing.create!(active: true, character: @character_one, points: -2)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, distribute: true, points: 2)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq @standing_one.points
      expect(@standing_events_one[1].type).to eq :initial.to_s
      expect(@standing_events_one[1].change).to eq @standing_three.points.to_f * -1 / 2
      expect(Standing.find(@standing_one).points).to eq @standing_one.points + (@standing_three.points.to_f * -1 / 2)

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :initial.to_s
      expect(@standing_events_two[1].change).to eq @standing_three.points.to_f * -1 / 2
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + (@standing_three.points.to_f * -1 / 2)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(Standing.find(@standing_three).points).to eq @standing_three.points

      @standing_events_three[0].update(change: 7)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq @standing_one.points
      expect(@standing_events_one[1].type).to eq :initial.to_s
      expect(@standing_events_one[1].change).to eq 7.to_f * -1 / 2
      expect(Standing.find(@standing_one).points).to eq @standing_one.points + (7.to_f * -1 / 2)

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :initial.to_s
      expect(@standing_events_two[1].change).to eq 7.to_f * -1 / 2
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + (7.to_f * -1 / 2)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq 7
      expect(Standing.find(@standing_three).points).to eq 7
    end

    # SCENARIO
    # #1 created with -2 points
    # #2 created with 0 points
    # #3 created with 2 points and distribute true
    # #3 updated standing event value
    # EXPECTED
    # #1/#2 get second standing event with 2 / 2 * -1 change (inverse)
    it 'distribute then update' do
      @standing_one = Standing.create!(active: true, character: @character_one, points: -2)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, distribute: true, points: 2)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq @standing_one.points
      expect(@standing_events_one[1].type).to eq :initial.to_s
      expect(@standing_events_one[1].change).to eq @standing_three.points.to_f * -1 / 2
      expect(Standing.find(@standing_one).points).to eq @standing_one.points + (@standing_three.points.to_f * -1 / 2)

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :initial.to_s
      expect(@standing_events_two[1].change).to eq @standing_three.points.to_f * -1 / 2
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + (@standing_three.points.to_f * -1 / 2)

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(Standing.find(@standing_three).points).to eq @standing_three.points

      @standing_events_three[0].destroy

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq @standing_one.points
      expect(Standing.find(@standing_one).points).to eq @standing_one.points

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(Standing.find(@standing_two).points).to eq @standing_two.points

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 0
      expect(Standing.find(@standing_three).points).to eq 0
    end
  end
end