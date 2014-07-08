require 'spec_helper'

RSpec.describe Raid, :type => :model do
  before { @raid = Raid.new(zone: 'Naxxramas', started_at: DateTime.now, ended_at: 4.hours.from_now) }

  subject { @raid }

  it { should respond_to(:characters) }
  it { should respond_to(:ended_at) }
  it { should respond_to(:started_at) }
  it { should respond_to(:zone) }

  it { should be_valid }

end
