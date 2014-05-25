require 'spec_helper'

describe "Static Pages" do

  describe "About page" do
    it "should have the content 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end

    it "should have the proper title" do
      visit '/static_pages/about'
      expect(page).to have_title("VCP | About")
    end
  end

  describe "Contact page" do
    it "should have the content 'Contact'" do
      visit '/static_pages/contact'
      expect(page).to have_content('Contact')
    end

    it "should have the proper title" do
      visit '/static_pages/contact'
      expect(page).to have_title("VCP | Contact")
    end
  end

  describe "Help page" do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it "should have the proper title" do
      visit '/static_pages/help'
      expect(page).to have_title("VCP | Help")
    end
  end

  describe "Home page" do
    it "should have the content 'VCP'" do
      visit '/static_pages/home'
      expect(page).to have_content('VCP')
    end

    it "should have the proper title" do
      visit '/static_pages/home'
      expect(page).to have_title("VCP | Home")
    end
  end
end
