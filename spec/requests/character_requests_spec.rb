require 'spec_helper'

describe "Character request" do

  subject { page }

  describe "as non-admin User" do
    let(:user) { FactoryGirl.create(:user) }
    let(:character) { FactoryGirl.create(:character) }

    before { sign_in user, no_capybara: true }

    describe "DELETE to destroy" do
      before { delete character_path(character) }
      specify { expect(response).to redirect_to(root_url) }
    end
  end
end
