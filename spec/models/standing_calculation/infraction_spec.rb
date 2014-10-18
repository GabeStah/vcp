require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do
  describe 'infraction calculations' do
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
      @standing_one = Standing.create!(active: true, character: @character_one, points: -1)
      @standing_two = Standing.create!(active: true, character: @character_two, points: 0)
      @standing_three = Standing.create!(active: true, character: @character_three, points: 1)
      @standing_count = Standing.all.size
    end

    # SCENARIO:
    # EXPECT:
    it 'basic infraction' do
      StandingEvent.create!(change: 3,
                            standing: @standing_one,
                            type: :infraction)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq -1
      expect(@standing_events_one[1].type).to eq :infraction.to_s
      expect(@standing_events_one[1].change).to eq 3
      expect(Standing.find(@standing_one).points).to eq -1 + 3

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :infraction.to_s
      expect(@standing_events_two[1].change).to eq 3.to_f / 2 * -1
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + 3.to_f / 2 * -1

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(@standing_events_three[1].type).to eq :infraction.to_s
      expect(@standing_events_three[1].change).to eq 3.to_f / 2 * -1
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + 3.to_f / 2 * -1
    end

    # SCENARIO:
    # EXPECT:
    it 'update' do
      current_change = 3
      StandingEvent.create!(change: current_change,
                            standing: @standing_one,
                            type: :infraction)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq -1
      expect(@standing_events_one[1].type).to eq :infraction.to_s
      expect(@standing_events_one[1].change).to eq current_change
      expect(Standing.find(@standing_one).points).to eq -1 + current_change

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :infraction.to_s
      expect(@standing_events_two[1].change).to eq current_change.to_f / 2 * -1
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + current_change.to_f / 2 * -1

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(@standing_events_three[1].type).to eq :infraction.to_s
      expect(@standing_events_three[1].change).to eq current_change.to_f / 2 * -1
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + current_change.to_f / 2 * -1

      current_change = -7

      @standing_events_one[1].update(change: current_change)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq -1
      expect(@standing_events_one[1].type).to eq :infraction.to_s
      expect(@standing_events_one[1].change).to eq current_change
      expect(Standing.find(@standing_one).points).to eq -1 + current_change

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :infraction.to_s
      expect(@standing_events_two[1].change).to eq current_change.to_f / 2 * -1
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + current_change.to_f / 2 * -1

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(@standing_events_three[1].type).to eq :infraction.to_s
      expect(@standing_events_three[1].change).to eq current_change.to_f / 2 * -1
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + current_change.to_f / 2 * -1
    end

    # SCENARIO:
    # EXPECT:
    it 'destroy' do
      current_change = 3
      StandingEvent.create!(change: current_change,
                            standing: @standing_one,
                            type: :infraction)

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq -1
      expect(@standing_events_one[1].type).to eq :infraction.to_s
      expect(@standing_events_one[1].change).to eq current_change
      expect(Standing.find(@standing_one).points).to eq -1 + current_change

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 2
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(@standing_events_two[1].type).to eq :infraction.to_s
      expect(@standing_events_two[1].change).to eq current_change.to_f / 2 * -1
      expect(Standing.find(@standing_two).points).to eq @standing_two.points + current_change.to_f / 2 * -1

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 2
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(@standing_events_three[1].type).to eq :infraction.to_s
      expect(@standing_events_three[1].change).to eq current_change.to_f / 2 * -1
      expect(Standing.find(@standing_three).points).to eq @standing_three.points + current_change.to_f / 2 * -1

      @standing_events_one[1].destroy

      @standing_events_one = StandingEvent.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 1
      expect(@standing_events_one[0].type).to eq :initial.to_s
      expect(@standing_events_one[0].change).to eq -1
      expect(Standing.find(@standing_one).points).to eq -1

      @standing_events_two = StandingEvent.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :initial.to_s
      expect(@standing_events_two[0].change).to eq @standing_two.points
      expect(Standing.find(@standing_two).points).to eq @standing_two.points

      @standing_events_three = StandingEvent.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :initial.to_s
      expect(@standing_events_three[0].change).to eq @standing_three.points
      expect(Standing.find(@standing_three).points).to eq @standing_three.points
    end
  end
end