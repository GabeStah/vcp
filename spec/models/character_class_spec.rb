require 'spec_helper'

describe CharacterClass do
  before { @character_class = CharacterClass.new(name: "Warrior") }

  subject { @character_class }

  it { should respond_to(:name) }

  it { should be_valid }

  describe "when name is missing" do
    before { @character_class.name = "" }
    it { should_not be_valid }
  end

  describe "when name already exists" do
    before { @character_class.dup.save }

    it { should_not be_valid }
  end

  describe "when name is not CamelCase" do
    before { @character_class.name = "lowercase" }

    it { should_not be_valid }
  end
end