require 'spec_helper'

describe 'Character pages', type: :feature do

  subject { page }

  describe 'index' do
    before(:each) do
      visit characters_path
    end

    it { should have_title('All characters') }
    it { should have_content('All characters') }

    describe 'pagination' do
      before(:all)  do
        10.times { FactoryGirl.create(:character) }
      end
      after(:all) do
        # Ensure all data is removed
        CharacterClass.delete_all
        Character.delete_all
        Race.delete_all
      end

      it 'should list each character' do
        Character.all.each do |character|
          page.has_selector?('td', text: character.name)
        end
      end
    end
  end

  describe 'new page should deny guests' do
    before do
      visit new_character_path
    end

    it { should have_title('Sign in') }
    it { should have_content('Sign in') }
  end

  describe 'adding new character' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit new_character_path
      fill_in 'Name',    with: 'Kulldar'
      fill_in 'Realm',   with: 'Hyjal'
      select  'US',      from: 'Region'
    end

    it 'should increment the character number' do
      expect do
        click_button('Add Character', match: :first)
      end.to change(Character, :count).by(1)
    end
  end
end