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
        fill_in "Guild", with: ''
        fill_in "Realm", with: 'Hyyyyjal'
        click_button "Save changes"
      end

      it { should have_content('error') }
    end

    describe "with valid information" do
      before do
        fill_in "Guild",  with: 'Vox Immortalis'
        fill_in "Realm",  with: 'Hyjal'
        select "US", from: 'Locale'
        click_button "Save changes"
      end

      it { should have_title('Settings') }
      it { should have_selector('div.alert.alert-success') }
    end
  end
end