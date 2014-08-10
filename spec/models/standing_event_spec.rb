require 'spec_helper'

RSpec.describe StandingEvent, :type => :model do
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
    @participation = Participation.create!(
      character: @character,
      in_raid: true,
      online: true,
      raid: @raid,
      timestamp: @raid.started_at
    )
    @standing_event = StandingEvent.new(raid: @raid, change: 0.5, standing: @standing, type: :attendance)
  end
  after do
    Character.delete_all
    Raid.delete_all
    Participation.delete_all
  end

  subject { @standing_event }

  it { should respond_to(:change) }
  it { should respond_to(:raid) }
  it { should respond_to(:standing) }
  it { should respond_to(:type) }

  it { should be_valid }

  describe 'invalid Change' do
    before { @standing_event.change = 'foo' }
    it { should_not be_valid }
  end

  describe 'no Raid' do
    before { @standing_event.raid = nil }
    it { should_not be_valid }
  end

  describe 'no Standing' do
    before { @standing_event.standing = nil }
    it { should_not be_valid }
  end

  describe 'no Type' do
    before { @standing_event.type = nil }
    it { should_not be_valid }
  end

  describe 'after_create' do
    before do
      @standing_event.save
    end

    it ':change value should be applied to Standing points' do
      expect(Standing.find(@standing_event.standing).points).to eq @standing_event.change
    end
  end

  describe 'update' do
    before do
      @standing_event.save
      @standing_event.update(change: 0.75)
    end

    it ':change value should be reverted then updated on Standing points' do
      expect(Standing.find(@standing_event.standing).points).to eq 0.75
    end
  end

  describe 'destroy' do
    before do
      @standing_event.save
      @standing_event.destroy
    end
    it 'change value should be reverted on Standing points' do
      expect(Standing.find(@standing_event.standing).points).to eq 0
    end
  end

end
