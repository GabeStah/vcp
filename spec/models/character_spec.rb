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

  describe 'deletion' do
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
      @raid = Raid.create!(zone: FactoryGirl.create(:zone), started_at: Time.zone.now, ended_at: 4.hours.from_now)
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
    # #1 destroy character
    # EXPECT:
    # Character cannot be deleted while Standing associated
    # No change
    it 'destroy character with Standing association' do
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
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)

      @character_one.destroy

      expect(@character_one.errors.size).to eq 1

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
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2  * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
    end

    # SCENARIO:
    # #1 offline at raid_start
    # #1 Online before cutoff
    # #1 Destroy standing
    # #1 destroy character
    # EXPECT:
    # Character deleted
    it 'destroy character without Standing association' do
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
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)

      standing_destroyed = @character_one.standing.destroy

      destroyed = Character.find_by(id: @character_one).destroy

      expect(@character_one.errors.size).to eq 0

      @standing_events_one = @raid.standing_events.where(standing: @standing_one)
      expect(@standing_events_one.size).to eq 2
      expect(@standing_events_one[0].type).to eq :attendance.to_s
      expect(@standing_events_one[0].change).to eq Settings.standing.attendance_gain
      expect(@standing_events_one[1].type).to eq :delinquent.to_s
      expect(@standing_events_one[1].change).to eq Settings.standing.delinquent_loss * 0.75
      @standing_one = Standing.find_by(id: @standing_one)
      expect(@standing_one).to eq nil

      @standing_events_two = @raid.standing_events.where(standing: @standing_two)
      expect(@standing_events_two.size).to eq 1
      expect(@standing_events_two[0].type).to eq :delinquent.to_s
      expect(@standing_events_two[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_two).points).to eq 0 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)

      @standing_events_three = @raid.standing_events.where(standing: @standing_three)
      expect(@standing_events_three.size).to eq 1
      expect(@standing_events_three[0].type).to eq :delinquent.to_s
      expect(@standing_events_three[0].change).to eq BigDecimal.new((Settings.standing.delinquent_loss.to_f * 0.75 * 2 * -1) / (@standing_count - 1), 6)
      expect(Standing.find(@standing_three).points).to eq 1 + BigDecimal.new((Settings.standing.delinquent_loss.to_f * 2 * 0.75 * -1) / (@standing_count - 1), 6)
    end
  end
end
