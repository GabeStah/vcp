require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:race) { FactoryGirl.create(:race) }
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end

      describe "in the Classes controller" do
        describe "visiting the classes index" do
          before { visit classes_path }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Races controller" do
        describe "visiting the race index" do
          before { visit races_path }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Settings controller" do
        describe "visiting the settings index" do
          before { visit settings_path }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('All users') }
        end
      end
    end

    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
        sign_in admin
        visit root_path
      end

      describe "header menu" do
        it { should have_link('Classes', href: classes_path) }
        it { should have_link('Races',   href: races_path) }
        it { should have_link('Settings',href: settings_path) }
      end
    end
  end

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error') }

      describe "after visiting another page" do
        before { click_link "Characters" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_title(user.name) }
      it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
      it { should_not have_link('Classes', href: '#') }
      it { should_not have_link('Races',   href: races_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end
end