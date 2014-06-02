require 'spec_helper'

describe "Race request" do

  subject { page }

  describe "as guest User" do
    let(:race) { FactoryGirl.create(:race) }

    describe "PATCH to update" do
      before { patch race_path(race) }
      specify { expect(response).to redirect_to(signin_path) }
    end
  end

  describe "as non-admin User" do
    let(:race) { FactoryGirl.create(:race) }
    let(:user) { FactoryGirl.create(:user) }

    before { sign_in user, no_capybara: true }

    describe "GET to index" do
      before { get races_path }
      specify { expect(response).to redirect_to(root_url) }
    end

    describe "DELETE to destroy" do
      before { delete race_path(race) }
      specify { expect(response).to redirect_to(root_url) }
    end
  end
end