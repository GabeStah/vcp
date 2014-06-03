require 'spec_helper'

describe "Class request" do

  subject { page }

  describe "as guest User" do
    let(:character_class) { FactoryGirl.create(:character_class) }

    describe "PATCH to update" do
      before { patch class_path(character_class) }
      specify { expect(response).to redirect_to(signin_path) }
    end
  end

  describe "as non-admin User" do
    let(:character_class) { FactoryGirl.create(:character_class) }
    let(:user) { FactoryGirl.create(:user) }

    before { sign_in user, no_capybara: true }

    describe "GET to index" do
      before { get classes_path }
      specify { expect(response).to redirect_to(root_url) }
    end

    describe "DELETE to destroy" do
      before { delete class_path(character_class) }
      specify { expect(response).to redirect_to(root_url) }
    end
  end
end