require 'spec_helper'

RSpec.describe Participation, :type => :model do
  before do
    @character = Character.create!(achievement_points: 1500,
                               character_class: FactoryGirl.create(:character_class),
                               gender: 0,
                               guild: FactoryGirl.create(:guild),
                               level: 90,
                               region: 'us',
                               portrait: 'internal-record-3661/66/115044674-avatar.jpg',
                               name: 'Kulldar',
                               race: FactoryGirl.create(:race),
                               rank: 9,
                               realm: 'Hyjal',
                               user: FactoryGirl.create(:user),
                               verified: true)
    @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: DateTime.now, ended_at: 4.hours.from_now)
    @participation = Participation.new(
        character: @character,
        in_raid: true,
        online: true,
        raid: @raid,
        timestamp: @raid.started_at
    )
  end
  after do
    @character.delete
    @raid.delete
  end

  subject { @participation }

  it { should respond_to(:character) }
  it { should respond_to(:in_raid) }
  it { should respond_to(:online) }
  it { should respond_to(:raid) }
  it { should respond_to(:timestamp) }

  it { should be_valid }

  describe 'no Character' do
    before { @participation.character = nil }
    it { should_not be_valid }
  end

  describe 'no Raid' do
    before { @participation.raid = nil }
    it { should_not be_valid }
  end

  describe 'no timestamp' do
    before { @participation.timestamp = nil }
    it { should_not be_valid }
  end

  describe 'Character + Raid + Timestamp already exists' do
    before do
      duplicated_participation = @participation.dup
      duplicated_participation.save
    end
    it { should_not be_valid }
  end

  describe 'Should be deleted if Raid is destroyed' do
    before do
      @participation.save!
      @raid.destroy
    end
    it { expect(Participation.exists?(@participation.id)).not_to be_truthy }
  end

  describe 'Should be deleted if Character is destroyed' do
    before do
      @participation.save!
      @character.destroy
    end
    it { expect(Participation.exists?(@participation.id)).not_to be_truthy }
  end



end
