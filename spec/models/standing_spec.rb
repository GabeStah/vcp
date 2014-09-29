require 'spec_helper'

RSpec.describe Standing, :type => :model do
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
    @standing = Standing.new(active: true, character: @character)
    #@zone = create(:zone)
    #@setting = create(:setting)
    @character_alice = create(:character, name: 'Alice')
    @character_dick = create(:character, name: 'Dick')
    @standing_alice = create(:standing, character: @character_alice)
  end

  subject { @standing }

  it { should respond_to(:active) }
  it { should respond_to(:character) }
  it { should respond_to(:points) }
  it { should respond_to(:standing_events) }

  it { should be_valid }

  describe 'active false' do
    before do
      @standing.active = false
    end
    it { should be_valid }
  end

  describe 'character nil' do
    before do
      @standing.character = nil
    end
    it { should_not be_valid }
  end

  describe 'duplicate should be invalid' do
    before do
      @standing_duplicate = @standing.dup
      @standing_duplicate.save
    end
    it { should_not be_valid }
  end

  describe 'transfer Standing record' do
    before do
      @standing.save
      @standing.transfer(@character_dick)
    end

    it 'should be transfered' do
      expect(Standing.last.character.name).to eq @character_dick.name
      expect(Standing.find_by(character: @character)).to eq nil
    end
  end

  describe 'transfer to existing standing character' do
    before do
      @standing.save
      @standing.transfer(@character_alice)
    end

    it 'should not be transfered' do
      expect(Standing.last.character.name).to eq @character.name
      expect(Standing.find_by(character: @character)).to eq @standing
    end
  end
end
