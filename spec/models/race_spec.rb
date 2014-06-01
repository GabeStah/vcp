require 'spec_helper'

describe Race do
  before { @race = Race.new(name: "Tauren") }

  subject { @race }

  it { should respond_to(:name) }

  it { should be_valid }

  describe "when name is missing" do
    before { @race.name = "" }
    it { should_not be_valid }
  end

  describe "when name already exists" do
    before { @race.dup.save }

    it { should_not be_valid }
  end

  describe "when name is not CamelCase" do
    before { @race.name = "lowercase" }

    it { should_not be_valid }
  end
end
