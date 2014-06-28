require 'spec_helper'

describe "User request", type: :request do

  subject { page }

  describe "as non-admin User" do
    let(:user) { FactoryGirl.create(:user) }

    before { sign_in user, no_capybara: true }

    describe "DELETE to destroy" do
      before { delete user_path(user) }
      specify { expect(response).to redirect_to(root_url) }
    end
  end

  describe "as guest User" do
    let(:user) { FactoryGirl.create(:user) }

    describe "PATCH to update" do
      before { patch user_path(user) }
      specify { expect(response).to redirect_to(signin_path) }
    end
  end

  describe "as wrong User" do
    let(:user) { FactoryGirl.create(:user) }
    let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
    before { sign_in user, no_capybara: true }

    describe "GET to edit" do
      before { get edit_user_path(wrong_user) }
      specify { expect(response.body).not_to match(full_title('Edit user')) }
      specify { expect(response).to redirect_to(root_url) }
    end

    describe "PATCH to update" do
      before { patch user_path(wrong_user) }
      specify { expect(response).to redirect_to(root_url) }
    end
  end
end