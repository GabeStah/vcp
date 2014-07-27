require 'spec_helper'

describe "Settings pages", type: :feature do

  subject { page }

  describe "index" do
    let(:admin) { FactoryGirl.create(:admin) }
    before do
      FactoryGirl.create(:setting)
      sign_in admin
      visit settings_path
    end

    describe "page" do
      it { should have_content("Settings") }
      it { should have_title("Settings") }
      it { should have_button('Save changes') }
    end

    describe "with invalid information" do
      before do
        fill_in "Raid start time", with: 'foo'
        fill_in "Raid end time", with: 'bar'
        click_button "Save changes"
      end

      it { should have_content('error') }
    end

    describe "with valid information" do
      before do
        fill_in "Raid start time", with: '7:45 PM'
        fill_in "Raid end time", with: '11:00 PM'
        click_button "Save changes"
      end

      it { should have_title('Settings') }
      it { should have_selector('div.alert.alert-success') }
    end
  end
end