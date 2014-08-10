require 'spec_helper'

describe Guild, type: :model do
  before { @guild = Guild.new(achievement_points: 2500,
                              battlegroup: 'Vengeance',
                              level: 20,
                              name: 'Vox Immortalis',
                              region: 'us',
                              realm: 'Hyjal',
                              side: 0)}

  subject { @guild }

  it { should respond_to :achievement_points,
                         :active,
                         :battlegroup,
                         :level,
                         :name,
                         :primary,
                         :region,
                         :realm,
                         :side,
                         :verified }

  it { should be_valid }

  it { should normalize_attribute(:battlegroup).from('  Vengeance  ').to('Vengeance') }
  it { should normalize_attribute(:name).from('  Vox    Immortalis  ').to('Vox Immortalis') }
  it { should normalize_attribute(:region).from('  us  ').to('us') }
  it { should normalize_attribute(:realm).from('  Realm   Name ').to('Realm Name') }

  describe 'valid' do

    describe 'battlegroup with UTF-8 characters' do
      before { @guild.battlegroup = 'Grünhilde' }
      it { should be_valid }
    end

    describe 'name with UTF-8 characters' do
      before { @guild.name = 'Grünhilde' }
      it { should be_valid }
    end

    describe 'realm with UTF-8 characters' do
      before { @guild.realm = 'Grünhilde' }
      it { should be_valid }
    end
  end

  describe 'invalid' do

    describe 'region, name, and realm should be unique' do
      before do
        duplicate_guild = @guild.dup
        duplicate_guild.name = @guild.name.upcase
        duplicate_guild.save
      end
      it { should_not be_valid }
    end

    describe 'achievement points' do
      describe 'as string' do
        before { @guild.achievement_points = '12345 blah' }
        it { should_not be_valid }
      end
    end

    describe 'battlegroup' do
      describe 'too short' do
        before { @guild.battlegroup = 'a' * 1 }
        it { should_not be_valid }
      end

      describe 'too long' do
        before { @guild.battlegroup = 'a' * 1000 }
        it { should_not be_valid }
      end
    end

    describe 'level' do
      describe 'as string' do
        before { @guild.level = 'three' }
        it { should_not be_valid }
      end
    end

    describe 'name' do
      describe 'as empty should be invalid' do
        before { @guild.name = nil }
        it { should_not be_valid }
      end

      describe 'too short' do
        before { @guild.name = 'a' * 1 }
        it { should_not be_valid }
      end

      describe 'too long' do
        before { @guild.name = 'a' * 1000 }
        it { should_not be_valid }
      end
    end

    describe 'realm' do
      describe 'as empty' do
        before { @guild.realm = nil }
        it { should_not be_valid }
      end
    end

    describe 'region' do
      describe 'as mixed string' do
        before { @guild.region = '12345 blah' }
        it { should_not be_valid }
      end

      describe 'as empty' do
        before { @guild.region = nil }
        it { should_not be_valid }
      end

      describe 'too short' do
        before { @guild.region = 'a' * 1 }
        it { should_not be_valid }
      end

      describe 'too long' do
        before { @guild.region = 'a' * 3 }
        it { should_not be_valid }
      end
    end

    describe 'side' do
      describe 'as string' do
        before { @guild.side = '5' }
        it { should_not be_valid }
      end
    end
  end

  describe 'setting primary should revoke other primary flags' do
    before do
      @primary_guild = Guild.create(name: 'Vox Immortalis',
                                    region: 'us',
                                    realm: 'Hyjal',
                                    primary: true)
      @secondary_guild = Guild.create(name: 'Vox Immortalis',
                                      region: 'us',
                                      realm: 'Stormrage')
    end

    specify 'primary guild count should be one' do
      expect(Guild.where(primary: true).all.count).to eq 1
    end
    specify 'primary guild should be first created' do
      expect(Guild.find_by(primary: true)).to eq @primary_guild
    end
    describe 'setting primary of secondary guild' do
      before do
        @secondary_guild.update(primary: true)
      end
      specify 'primary guild count should be one' do
        expect(Guild.where(primary: true).all.count).to eq 1
      end
      specify 'primary guild should be second created' do
        expect(Guild.find_by(primary: true)).to eq @secondary_guild
      end
      specify 'first guild should not be primary' do
        expect(Guild.find(@primary_guild).primary).to eq false
      end
    end
  end
end
