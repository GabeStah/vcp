require 'spec_helper'

describe Race, type: :model do
  before { @race = Race.new(name: "Tauren", blizzard_id: 6, side: 'horde') }

  subject { @race }

  it { should respond_to(:blizzard_id) }
  it { should respond_to(:name) }
  it { should respond_to(:side) }

  it { should be_valid }

  it { should normalize_attribute(:name).from('  Blood    Elf  ').to('Blood Elf') }
  it { should normalize_attribute(:side).from('  horde  ').to('horde') }

  describe "when blizzard_id is missing" do
    before { @race.blizzard_id = "" }
    it { should_not be_valid }
  end

  describe "when blizzard_id already exists" do
    before { @race.dup.save }
    it { should_not be_valid }
  end

  describe "when name is missing" do
    before { @race.name = "" }
    it { should_not be_valid }
  end

  describe "when name plus blizzard_id already exists" do
    before { @race.dup.save }
    it { should_not be_valid }
  end

  describe "when name is not CamelCase" do
    before { @race.name = "lowercase" }
    it { should_not be_valid }
  end

  describe "when side is missing" do
    before { @race.side = "" }
    it { should_not be_valid }
  end

  describe "when side is not lowercase" do
    before { @race.side = "UPPERCASE" }
    it { should_not be_valid }
  end
end
