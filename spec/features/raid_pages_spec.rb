require 'spec_helper'

describe 'Raid pages', type: :feature do
  before do
    @zone = create(:zone)
    @setting = create(:setting)
    @character_alice = create(:character, name: 'Alice')
    @character_zack = create(:character, name: 'Zack')
    @standing_alice = create(:standing, character: @character_alice)
    @standing_zack = create(:standing, character: @character_zack)
  end

  subject { page }

  describe 'index' do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) do
      sign_in admin
      visit raids_path
    end

    it { should have_title('Raids') }
    it { should have_content('Raids') }
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
        fill_in 'Start Date', with: "#{DateTime.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{DateTime.now.strftime('%m/%d/%Y')} 10:30 PM"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 2
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'StandingEvents count for alice should be 3' do
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 3
      end

      it 'StandingEvents count for zack should be 3' do
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 3
      end

      it 'should change Standing points by :delinquent_loss' do
        expect(Standing.find(@standing_alice).points).to eq BigDecimal(DEFAULT_SITE_SETTINGS[:delinquent_loss] + DEFAULT_SITE_SETTINGS[:delinquent_loss] * -1, 6)
        expect(Standing.find(@standing_zack).points).to eq BigDecimal(DEFAULT_SITE_SETTINGS[:delinquent_loss] + DEFAULT_SITE_SETTINGS[:delinquent_loss] * -1, 6)
      end
    end

    describe 'adding new raid with one attending and one absent' do
      before do
        fill_in 'Start Date', with: "#{DateTime.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{DateTime.now.strftime('%m/%d/%Y')} 10:30 PM"
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 2
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 1' do
        expect(@raid.attendees.size).to eq 1
      end

      it 'StandingEvents count for alice should be 3' do
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 3
      end

      it 'StandingEvents count for zack should be 2' do
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 2
      end

      it 'alice should lose :attendance_loss and gain zack delinquent_loss' do
        expect(Standing.find(@standing_alice).points).to eq BigDecimal(DEFAULT_SITE_SETTINGS[:delinquent_loss] * 2 * -1 + -1, 6)
      end

      it 'zack should lose delinquent_loss' do
        expect(Standing.find(@standing_zack).points).to eq BigDecimal(DEFAULT_SITE_SETTINGS[:delinquent_loss] , 6)
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end
  end
end