require 'spec_helper'

describe "Race pages" do

  subject { page }

  describe "index" do
    let(:race) { FactoryGirl.create(:race) }
    before(:each) do
      visit races_path
    end

    it { should have_title('All races') }
    it { should have_content('All races') }
  end
end