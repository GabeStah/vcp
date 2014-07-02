require 'spec_helper'

describe Character, type: :model do
  before { @character = Character.new(achievement_points: 1500,
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
                                      user: FactoryGirl.create(:user))}

  subject { @character }

  it { should respond_to :achievement_points,
                         :character_class,
                         :gender,
                         :guild,
                         :level,
                         :region,
                         :portrait,
                         :name,
                         :race,
                         :rank,
                         :realm,
                         :user,
                         :verified }

  it { should be_valid }

  it { should normalize_attribute(:achievement_points).from('  123  ').to(123) }
  it { should normalize_attribute(:gender).from('  0  ').to(0) }
  it { should normalize_attribute(:level).from('  90  ').to(90) }
  it { should normalize_attribute(:region).from('  us  ').to('us') }
  it { should normalize_attribute(:portrait).from('  internal-record-3661/66/115044674-avatar.jpg  ').to('internal-record-3661/66/115044674-avatar.jpg') }
  it { should normalize_attribute(:name).from('  Kulldar  ').to('Kulldar') }
  it { should normalize_attribute(:rank).from('  9  ').to(9) }
  it { should normalize_attribute(:realm).from('  Realm   Name  ').to('Realm Name') }

  describe 'name with UTF-8 characters' do
    before { @character.name = 'Grünhilde' }
    it { should be_valid }
  end

  describe 'region, name, and realm should be unique' do
    before do
      duplicate_character = @character.dup
      duplicate_character.save
    end
    it { should_not be_valid }
  end

  describe 'achievement points' do
    describe 'as string' do
      before { @character.achievement_points = '12345 blah' }
      it { should_not be_valid }
    end

    describe 'as empty' do
      before { @character.achievement_points = nil }
      it { should be_valid }
    end
  end

  describe 'character class' do
    describe 'as empty' do
      before { @character.character_class = nil }
      it { should be_valid }
    end
  end

  describe 'gender' do
    describe 'as string' do
      before { @character.gender = 'Male' }
      it { should_not be_valid }
    end

    describe 'as empty' do
      before { @character.gender = nil }
      it { should be_valid }
    end

    describe 'out of range' do
      before { @character.gender = 3 }
      it { should_not be_valid }
    end
  end

  describe 'guild' do
    describe 'as empty' do
      before { @character.guild = nil }
      it { should be_valid }
    end
  end

  describe 'level' do
    describe 'as string' do
      before { @character.level = '12345 blah' }
      it { should_not be_valid }
    end

    describe 'as empty' do
      before { @character.level = nil }
      it { should be_valid }
    end

    describe 'out of range' do
      before { @character.level = 150 }
      it { should_not be_valid }
    end
  end

  describe 'region' do
    describe 'as mixed string' do
      before { @character.region = '12345 blah' }
      it { should_not be_valid }
    end

    describe 'as empty' do
      before { @character.region = nil }
      it { should_not be_valid }
    end

    describe 'too short' do
      before { @character.region = 'a' * 1 }
      it { should_not be_valid }
    end

    describe 'too long' do
      before { @character.region = 'a' * 3 }
      it { should_not be_valid }
    end
  end

  describe 'portrait' do
    describe 'as empty' do
      before { @character.portrait = nil }
      it { should be_valid }
    end

    describe 'as incorrect URI format' do
      before { @character.portrait = 'internal-record-3661/extra/66/115044674-avatar.jpg' }
      it { should_not be_valid }
    end

    describe 'as non-URI' do
      before { @character.portrait = 'someplace' }
      it { should_not be_valid }
    end

    describe 'as number' do
      before { @character.portrait = 12345 }
      it { should_not be_valid }
    end
  end

  describe 'name' do
    describe 'as empty' do
      before { @character.name = nil }
      it { should_not be_valid }
    end
  end

  describe 'race' do
    describe 'as empty' do
      before { @character.race = nil }
      it { should be_valid }
    end
  end

  describe 'rank' do
    describe 'as string' do
      before { @character.rank = '12345 blah' }
      it { should_not be_valid }
    end

    describe 'out of range' do
      before { @character.rank = 15 }
      it { should_not be_valid }
    end

    describe 'as nil' do
      before { @character.rank = nil }
      it { should be_valid }
    end
  end

  describe 'realm' do
    describe 'as empty' do
      before { @character.realm = nil }
      it { should_not be_valid }
    end
  end

  describe 'user' do
    describe 'as empty' do
      before { @character.user = nil }
      it { should be_valid }
    end
  end
end
