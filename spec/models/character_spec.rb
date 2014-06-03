require 'spec_helper'

describe Character do
  before { @character = Character.new(achievement_points: 1500,
                                      character_class: FactoryGirl.create(:character_class),
                                      gender: 0,
                                      guild: "Vox Immortalis",
                                      level: 90,
                                      portrait: "internal-record-3661/66/115044674-avatar.jpg",
                                      name: "Kulldar",
                                      race: FactoryGirl.create(:race),
                                      rank: 1,
                                      realm: "Hyjal") }

  subject { @character }

  it { should respond_to :achievement_points,
                         :character_class,
                         :gender,
                         :guild,
                         :level,
                         :portrait,
                         :name,
                         :race,
                         :rank,
                         :realm }

  it { should be_valid }

  describe "invalid" do

    describe "achievement points" do
      describe "as string" do
        before { @character.achievement_points = "12345 blah" }
        it { should_not be_valid }
      end

      describe "as empty" do
        before { @character.achievement_points = nil }
        it { should_not be_valid }
      end
    end

    describe "character class" do
      describe "as empty" do
        before { @character.character_class = nil }
        it { should_not be_valid }
      end
    end

    describe "gender" do
      describe "as string" do
        before { @character.gender = "Male" }
        it { should_not be_valid }
      end

      describe "as empty" do
        before { @character.gender = nil }
        it { should_not be_valid }
      end

      describe "out of range" do
        before { @character.gender = 3 }
        it { should_not be_valid }
      end
    end

    describe "guild" do
      describe "as empty should be valid" do
        before { @character.guild = nil }
        it { should be_valid }
      end

      describe "too short" do
        before { @character.guild = "a" * 1 }
        it { should_not be_valid }
      end

      describe "too long" do
        before { @character.guild = "a" * 1000 }
        it { should_not be_valid }
      end
    end

    describe "level" do
      describe "as string" do
        before { @character.level = "12345 blah" }
        it { should_not be_valid }
      end

      describe "as empty" do
        before { @character.level = nil }
        it { should_not be_valid }
      end

      describe "out of range" do
        before { @character.level = 150 }
        it { should_not be_valid }
      end
    end

    describe "portrait" do
      describe "as empty" do
        before { @character.portrait = nil }
        it { should_not be_valid }
      end

      describe "as incorrect URI format" do
        before { @character.portrait = "internal-record-3661/extra/66/115044674-avatar.jpg" }
        it { should_not be_valid }
      end

      describe "as non-URI" do
        before { @character.portrait = "someplace" }
        it { should_not be_valid }
      end

      describe "as number" do
        before { @character.portrait = 12345 }
        it { should_not be_valid }
      end
    end

    describe "name" do
      describe "as empty" do
        before { @character.name = nil }
        it { should_not be_valid }
      end

      describe "should be unique with realm" do
        before do
          duplicate_character = @character.dup
          duplicate_character.save
        end
        it { should_not be_valid }
      end
    end

    describe "race" do
      describe "as empty" do
        before { @character.race = nil }
        it { should_not be_valid }
      end
    end

    describe "rank" do
      describe "as string" do
        before { @character.rank = "12345 blah" }
        it { should_not be_valid }
      end

      describe "as empty" do
        before { @character.rank = nil }
        it { should_not be_valid }
      end

      describe "out of range" do
        before { @character.rank = 15 }
        it { should_not be_valid }
      end
    end

    describe "realm" do
      describe "as empty" do
        before { @character.realm = nil }
        it { should_not be_valid }
      end

      describe "should be unique with name" do
        before do
          duplicate_character = @character.dup
          duplicate_character.save
        end
        it { should_not be_valid }
      end
    end

  end

end
