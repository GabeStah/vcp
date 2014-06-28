require 'spec_helper'

describe "Guild request", type: :request do

  subject { page }

  describe "as guest User" do
    let(:guild) { FactoryGirl.create(:guild) }

    describe "GET to index" do
      before { get guilds_path }
      specify { expect(response).to redirect_to(signin_path) }
    end


    describe "PATCH to update" do
      before { patch guild_path(guild) }
      specify { expect(response).to redirect_to(signin_path) }
    end
  end

  describe "as non-admin User" do
    let(:guild) { FactoryGirl.create(:guild) }
    let(:user) { FactoryGirl.create(:user) }

    before { sign_in user, no_capybara: true }

    describe "GET to index" do
      before { get guilds_path }
      specify { expect(response).to redirect_to(root_url) }
    end

    describe "DELETE to destroy" do
      before { delete guild_path(guild) }
      specify { expect(response).to redirect_to(root_url) }
    end
  end
end