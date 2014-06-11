require 'spec_helper'

describe "Character pages" do

  subject { page }

  describe "index" do
    before(:each) do
      visit characters_path
    end

    it { should have_title('All characters') }
    it { should have_content('All characters') }

    describe "pagination" do
      before(:all) { 10.times { FactoryGirl.create(:character) } }
      after(:all) do
        # Ensure all data is removed
        CharacterClass.delete_all
        Character.delete_all
        Race.delete_all
      end

      it "should list each character" do
        Character.paginate(page: 1).each do |character|
          expect(page).to have_selector('li', text: character.name)
        end
      end

      it { should_not have_link('delete', href: character_path(Character.first)) }

      describe "as admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit characters_path
        end

        describe "delete links" do
          it { should have_link('delete', href: character_path(Character.first)) }
          it "should be able to delete a character" do
            expect do
              click_link('delete', match: :first)
            end.to change(Character, :count).by(-1)
          end
        end
      end
    end

  end
end