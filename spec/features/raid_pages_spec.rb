require 'spec_helper'

describe 'Raid pages', type: :feature do

  subject { page }

  describe 'index' do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) do
      sign_in admin
      visit raids_path
    end

    it { should have_title('Raids') }
    it { should have_content('Raids') }

    describe 'pagination' do
      before(:all) { 10.times { FactoryGirl.create(:raid) } }
      after(:all) do
        # Ensure all data is removed
        Raid.delete_all
      end

      it 'should list each character' do
        Raid.all.each do |raid|
          expect(page).to have_selector('li', text: raid.name)
        end
      end

      describe 'as admin user' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit raids_path
        end

        describe 'delete links' do
          it { should have_link('delete', href: raid_path(Raid.first)) }
          it 'should be able to delete a raid' do
            expect do
              click_link('delete', match: :first)
            end.to change(Raid, :count).by(-1)
          end
        end
      end
    end
  end

  describe 'new page' do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) do
      sign_in admin
      visit new_raid_path
    end

    it { should have_title('Add Raid') }
    it { should have_content('Add Raid') }


    describe 'adding new raid' do
      before do
        fill_in 'Name',    with: 'Vox Immortalis'
        fill_in 'Realm',   with: 'Hyjal'
        select  'US',      from: 'Region'
      end

      it 'should increment the raid number' do
        expect do
          click_button('Add Raid', match: :first)
        end.to change(Raid, :count).by(1)
      end
    end

  end
end