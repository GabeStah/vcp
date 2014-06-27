require 'spec_helper'

describe 'Character pages' do

  subject { page }

  describe 'index' do
    before(:each) do
      visit characters_path
    end

    it { should have_title('All characters') }
    it { should have_content('All characters') }

    describe 'pagination' do
      before(:all) { 10.times { FactoryGirl.create(:character) } }
      after(:all) do
        # Ensure all data is removed
        CharacterClass.delete_all
        Character.delete_all
        Race.delete_all
      end

      it 'should list each character' do
        Character.paginate(page: 1).each do |character|
          expect(page).to have_selector('li', text: character.name)
        end
      end

      it { should_not have_link('delete', href: character_path(Character.first)) }

      describe 'as admin user' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit characters_path
        end

        describe 'delete links' do
          it { should have_link('delete', href: character_path(Character.first)) }
          it 'should be able to delete a character' do
            expect do
              click_link('delete', match: :first)
            end.to change(Character, :count).by(-1)
          end
        end
      end
    end
  end

  describe 'new page' do
    before do
      visit new_character_path
    end

    it { should have_title('Add Character') }
    it { should have_content('Add Character') }


    describe 'adding new character' do
      before do
        fill_in 'Name',    with: 'Kulldar'
        fill_in 'Realm',   with: 'Hyjal'
        fill_in 'Locale',  with: 'US'
      end

      it 'should increment the character number' do
        expect do
          click_button('Add Character', match: :first)
        end.to change(Character, :count).by(1)
      end
    end

    describe 'updating existing character' do
      before do
        battle_net = BattleNet.new(character_name: 'Kulldar',
                                   locale: 'US',
                                   realm: 'Hyjal',
                                   type: 'character',
                                   auto_connect: true)
        battle_net.update if battle_net.connected?
        fill_in 'Name',    with: 'Kulldar'
        fill_in 'Realm',   with: 'Hyjal'
        fill_in 'Locale',  with: 'US'
      end

      it 'should not change character count' do
        expect do
          click_button('Add Character', match: :first)
        end.not_to change(Character, :count)
      end
    end
  end
end