require 'spec_helper'

describe "Race pages", type: :feature do

  subject { page }

  describe "index" do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) do
      sign_in admin
      visit races_path
    end

    it { should have_title('All races') }
    it { should have_content('All races') }

    before(:all) { 10.times { FactoryGirl.create(:race) } }
    after(:all)  { Race.delete_all }

    it "should list each race" do
      Race.all.each do |race|
        expect(page).to have_selector('li', text: race.name)
      end
    end

    describe "delete links" do

      it { should have_link('delete', href: race_path(Race.first)) }
      it "should be able to delete a race" do
        expect do
          click_link('delete', match: :first)
        end.to change(Race, :count).by(-1)
      end
    end
  end
end