require 'spec_helper'

describe BattleNet do

  describe "should respond properly" do
    before { @battle_net = BattleNet.new }
    subject { @battle_net }

    it { should respond_to(:character_name) }
    it { should respond_to(:locale) }
    it { should respond_to(:guild) }
    it { should respond_to(:realm) }
    it { should respond_to(:type) }
  end

  describe "with no parameters" do
    before { @battle_net = BattleNet.new }
    subject { @battle_net }

    it { should_not be_valid }

    describe "should not be connected" do
      specify { expect(@battle_net.connected?).to be_false }
    end

    describe "should not have json" do
      specify { expect(@battle_net.json).to be_nil }
    end
  end

  describe "with guild parameters" do
    before { @battle_net = BattleNet.new(locale: "US", guild: "Vox Immortalis", realm: "Hyjal", auto_connect: true) }
    subject { @battle_net }

    it { should be_valid }

    describe "should be connected" do
      specify { expect(@battle_net.connected?).to be_true }
    end

    describe "should have json" do
      specify { expect(@battle_net.json).to_not be_nil }

      describe "should have valid json" do
        specify { expect(@battle_net.json['nok']).to be_nil }
      end

      describe "should have members in json" do
        specify { expect(@battle_net.json['members'].any?).to be_true }
      end
    end

    describe "with invalid realm" do
      before { @battle_net = BattleNet.new(locale: "US", guild: "Vox Immortalis", realm: "Hyjaaaaal", auto_connect: true) }

      specify { expect(@battle_net.errors[:battle_net_error].first).to eq "Realm not found." }
    end

    describe "with invalid guild" do
      before { @battle_net = BattleNet.new(locale: "US", guild: "Vooooooox Immmmmmmmortalis", realm: "Hyjal", auto_connect: true) }

      specify { expect(@battle_net.errors[:battle_net_error].first).to eq "Guild not found." }
    end

    describe "with invalid locale" do
      before { @battle_net = BattleNet.new(locale: "AZ", guild: "Vox Immortalis", realm: "Hyjal") }
      subject { @battle_net }

      it { should_not be_valid }
    end
  end

  describe "with character parameters" do
    before { @battle_net = BattleNet.new(locale: "US", character_name: "Kulldar", realm: "Hyjal", type: "character", auto_connect: true) }
    subject { @battle_net }

    it { should be_valid }

    describe "should be connected" do
      specify { expect(@battle_net.connected?).to be_true }
    end

    describe "should have json" do
      specify { expect(@battle_net.json).to_not be_nil }

      describe "should have valid json" do
        specify { expect(@battle_net.json['nok']).to be_nil }
      end

      describe "should have name and class in json" do
        specify { expect(@battle_net.json['name']).to_not be_nil }
        specify { expect(@battle_net.json['class']).to_not be_nil }
      end
    end

    describe "with invalid character name" do
      before { @battle_net = BattleNet.new(locale: "US", character_name: "Kulllllldar", realm: "Hyjal", type: "character", auto_connect: true) }

      specify { expect(@battle_net.errors[:battle_net_error].first).to eq "Character not found." }
    end
  end


end