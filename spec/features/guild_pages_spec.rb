require 'spec_helper'

describe 'Guild pages', type: :feature do

  subject { page }

  describe 'index' do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) do
      sign_in admin
      visit guilds_path
    end

    it { should have_title('All guilds') }
    it { should have_content('All guilds') }

    describe 'pagination' do
      before(:all) { 10.times { FactoryGirl.create(:guild) } }
      after(:all) do
        # Ensure all data is removed
        Guild.delete_all
      end

      it 'should list each character' do
        Guild.all.each do |guild|
          expect(page).to have_selector('li', text: guild.name)
        end
      end

      describe 'as admin user' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit guilds_path
        end

        describe 'delete links' do
          it { should have_link('delete', href: guild_path(Guild.first)) }
          it 'should be able to delete a guild' do
            expect do
              click_link('delete', match: :first)
            end.to change(Guild, :count).by(-1)
          end
        end
      end
    end
  end

  describe 'new page' do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) do
      sign_in admin
      visit new_guild_path
    end

    it { should have_title('Add Guild') }
    it { should have_content('Add Guild') }


    describe 'adding new guild' do
      before do
        fill_in 'Name',    with: 'Vox Immortalis'
        fill_in 'Realm',   with: 'Hyjal'
        select  'US',      from: 'Region'
      end

      it 'should increment the guild number' do
        expect do
          click_button('Add Guild', match: :first)
        end.to change(Guild, :count).by(1)
      end
    end

    describe 'updating existing guild' do
      # before do
      #   fill_in 'Name',    with: 'Kulldar'
      #   fill_in 'Realm',   with: 'Hyjal'
      #   fill_in 'Region',  with: 'US'
      # end
      #
      # it 'should not change character count' do
      #   expect do
      #     click_button('Add Character', match: :first)
      #   end.not_to change(Character, :count)
      # end
    end
  end
end