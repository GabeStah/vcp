require 'spec_helper'

describe 'Raid pages', type: :feature do
  before do
    @zone = create(:zone)
    @setting = create(:setting)
    @character_alice = create(:character, name: 'Alice')
    @character_dick = create(:character, name: 'Dick')
    @character_harry = create(:character, name: 'Harry')
    @character_tom = create(:character, name: 'Tom')
    @character_zack = create(:character, name: 'Zack')
    @standing_alice = create(:standing, character: @character_alice)
    @standing_dick = create(:standing, character: @character_dick)
    @standing_harry = create(:standing, character: @character_harry)
    @standing_tom = create(:standing, character: @character_tom)
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
      sign_in_test admin
      visit new_raid_path
    end

    it { should have_title('Add Raid') }
    it { should have_content('Add Raid') }

    describe 'adding new raid with all attending' do
      before do
        fill_in 'Start Date', with: TimeManagement.raid_start(format: DATETIME_FORMAT)
        fill_in 'End Date',   with: TimeManagement.raid_end(format: DATETIME_FORMAT)
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        check "online[#{@character_dick.slug}][1]"
        check "in_raid[#{@character_dick.slug}][1]"
        check "online[#{@character_harry.slug}][1]"
        check "in_raid[#{@character_harry.slug}][1]"
        check "online[#{@character_tom.slug}][1]"
        check "in_raid[#{@character_tom.slug}][1]"
        check "online[#{@character_zack.slug}][1]"
        check "in_raid[#{@character_zack.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 5
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 5' do
        expect(@raid.attendees.size).to eq 5
      end

      it 'StandingEvents count for all should be 2' do
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 2
        expect(StandingEvent.where(standing: @standing_dick).size).to eq 2
        expect(StandingEvent.where(standing: @standing_harry).size).to eq 2
        expect(StandingEvent.where(standing: @standing_tom).size).to eq 2
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 2
      end

      it 'All should have no point loss/gain, since roster size and raid size are equal' do
        expect(Standing.find(@standing_alice).points).to eq BigDecimal(0, 6)
        expect(Standing.find(@standing_dick).points).to eq BigDecimal(0, 6)
        expect(Standing.find(@standing_harry).points).to eq BigDecimal(0, 6)
        expect(Standing.find(@standing_tom).points).to eq BigDecimal(0, 6)
        expect(Standing.find(@standing_zack).points).to eq BigDecimal(0, 6)
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end

    describe 'adding new raid with 4 attending, 1 absent' do
      before do
        fill_in 'Start Date', with: "#{Time.zone.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{Time.zone.now.strftime('%m/%d/%Y')} 10:30 PM"
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        check "online[#{@character_dick.slug}][1]"
        check "in_raid[#{@character_dick.slug}][1]"
        check "online[#{@character_harry.slug}][1]"
        check "in_raid[#{@character_harry.slug}][1]"
        check "online[#{@character_tom.slug}][1]"
        check "in_raid[#{@character_tom.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 5
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 5' do
        expect(@raid.attendees.size).to eq 4
      end

      it 'StandingEvents count' do
        # Attendees 3: initial, attendance_loss, delinquent_gain
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 3
        expect(StandingEvent.where(standing: @standing_dick).size).to eq 3
        expect(StandingEvent.where(standing: @standing_harry).size).to eq 3
        expect(StandingEvent.where(standing: @standing_tom).size).to eq 3
        # Delinquent 2: initial, delinquent_loss
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 2
      end

      it 'Raid.attendance_loss' do
        # (roster_size - raid_size) * delinquent_loss / raid_size
        # (5 - 4) * -1 / 4 = -0.25
        expect(@raid.attendance_loss).to eq -25.0
        expect(@raid.attendance_loss).to eq (Standing.where(active: true).size - @raid.attendees.size) * Settings.standing.delinquent_loss / @raid.attendees.size.to_f
      end

      it 'Standing Points' do
        # Attendees: attendance_loss + (Settings.standing.delinquent_loss * 2 * -1 / (Standing.all.size - 1))
        attendee_points = BigDecimal(@raid.attendance_loss + (Settings.standing.delinquent_loss * 2 * -1 / (Standing.where(active: true).size - 1)), 6)
        expect(Standing.find(@standing_alice).points).to eq attendee_points
        expect(Standing.find(@standing_dick).points).to eq attendee_points
        expect(Standing.find(@standing_harry).points).to eq attendee_points
        expect(Standing.find(@standing_tom).points).to eq attendee_points
        # Delinquent: Settings.standing.delinquent_loss
        expect(Standing.find(@standing_zack).points).to eq BigDecimal(Settings.standing.delinquent_loss, 6)
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end

    describe 'adding new raid with 2 attending, 3 absent' do
      before do
        fill_in 'Start Date', with: "#{Time.zone.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{Time.zone.now.strftime('%m/%d/%Y')} 10:30 PM"
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        check "online[#{@character_dick.slug}][1]"
        check "in_raid[#{@character_dick.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 5
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 5' do
        expect(@raid.attendees.size).to eq 2
      end

      it 'StandingEvents count' do
        # Attendees 3: initial, attendance_loss, delinquent_gain * 3
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 5
        expect(StandingEvent.where(standing: @standing_dick).size).to eq 5
        # Delinquent 2: initial, delinquent_loss, delinquent_gain * 2
        expect(StandingEvent.where(standing: @standing_harry).size).to eq 4
        expect(StandingEvent.where(standing: @standing_tom).size).to eq 4
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 4
      end

      it 'Raid.attendance_loss' do
        # (roster_size - raid_size) * delinquent_loss / raid_size
        # (5 - 2) * -1 / 2 = -1.5
        expect(@raid.attendance_loss).to eq -150.0
        expect(@raid.attendance_loss).to eq (Standing.where(active: true).size - @raid.attendees.size) * Settings.standing.delinquent_loss / @raid.attendees.size.to_f
      end

      it 'Standing Points' do
        # Attendees: attendance_loss + (Settings.standing.delinquent_loss * 2 * -1 / (Standing.all.size - 1))
        # attendance_loss
        # delinquent_gain * # deliquents
        delinquent_gain_per = BigDecimal(Settings.standing.delinquent_loss * 2 * -1 / (Standing.where(active: true).size - 1), 6)
        attendee_points = BigDecimal(@raid.attendance_loss + delinquent_gain_per * 3, 6)
        expect(Standing.find(@standing_alice).points).to eq attendee_points
        expect(Standing.find(@standing_dick).points).to eq attendee_points
        # Delinquent:
        # delinquent_loss
        # delinquent_gain * # other deliquents
        delinquent_points = BigDecimal(Settings.standing.delinquent_loss, 6)
        expect(Standing.find(@standing_harry).points).to eq delinquent_points + delinquent_gain_per * 2
        expect(Standing.find(@standing_tom).points).to eq delinquent_points + delinquent_gain_per * 2
        expect(Standing.find(@standing_zack).points).to eq delinquent_points + delinquent_gain_per * 2
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end

    describe 'adding new raid with 2 attending, 2 absent, 1 unexcused' do
      before do
        fill_in 'Start Date', with: "#{Time.zone.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{Time.zone.now.strftime('%m/%d/%Y')} 10:30 PM"
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        check "online[#{@character_dick.slug}][1]"
        check "in_raid[#{@character_dick.slug}][1]"
        check "unexcused[#{@character_zack.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 5
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 5' do
        expect(@raid.attendees.size).to eq 2
      end

      it 'StandingEvents count' do
        # Attendees 3: initial, attendance_loss, delinquent_gain * 3
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 6
        expect(StandingEvent.where(standing: @standing_dick).size).to eq 6
        # Delinquent 2: initial, delinquent_loss, delinquent_gain * 2
        expect(StandingEvent.where(standing: @standing_harry).size).to eq 5
        expect(StandingEvent.where(standing: @standing_tom).size).to eq 5
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 5
      end

      it 'Raid.attendance_loss' do
        # (roster_size - raid_size) * delinquent_loss / raid_size
        # (5 - 2) * -1 / 2 = -1.5
        expect(@raid.attendance_loss).to eq -150.0
        expect(@raid.attendance_loss).to eq (Standing.where(active: true).size - @raid.attendees.size) * Settings.standing.delinquent_loss / @raid.attendees.size.to_f
      end

      it 'Standing Points' do
        # Attendees: attendance_loss + (Settings.standing.delinquent_loss * 2 * -1 / (Standing.all.size - 1))
        # attendance_loss
        # delinquent_gain * # deliquents
        delinquent_gain_per = BigDecimal(Settings.standing.delinquent_loss * 2 * -1 / (Standing.where(active: true).size - 1), 6)
        unexcused_absence_per = BigDecimal(Settings.standing.unexcused_absence_loss * -1 / (Standing.where(active: true).size - 1), 6)
        attendee_points = BigDecimal(@raid.attendance_loss + delinquent_gain_per * 3, 6)
        expect(Standing.find(@standing_alice).points).to eq attendee_points + unexcused_absence_per
        expect(Standing.find(@standing_dick).points).to eq attendee_points + unexcused_absence_per
        # Delinquent:
        # delinquent_loss
        # delinquent_gain * # other deliquents
        delinquent_points = BigDecimal(Settings.standing.delinquent_loss, 6)
        expect(Standing.find(@standing_harry).points).to eq delinquent_points + delinquent_gain_per * 2 + unexcused_absence_per
        expect(Standing.find(@standing_tom).points).to eq delinquent_points + delinquent_gain_per * 2 + unexcused_absence_per
        expect(Standing.find(@standing_zack).points).to eq delinquent_points + delinquent_gain_per * 2 + Settings.standing.unexcused_absence_loss
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end

    describe 'adding new raid with 4 attending, 1 sitting' do
      before do
        fill_in 'Start Date', with: "#{Time.zone.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{Time.zone.now.strftime('%m/%d/%Y')} 10:30 PM"
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        check "online[#{@character_dick.slug}][1]"
        check "in_raid[#{@character_dick.slug}][1]"
        check "online[#{@character_harry.slug}][1]"
        check "in_raid[#{@character_harry.slug}][1]"
        check "online[#{@character_tom.slug}][1]"
        check "in_raid[#{@character_tom.slug}][1]"
        check "online[#{@character_zack.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 5
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 4' do
        expect(@raid.attendees.size).to eq 4
      end

      it 'StandingEvents count' do
        # Attendees 2: initial, attendance_loss
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 2
        expect(StandingEvent.where(standing: @standing_dick).size).to eq 2
        expect(StandingEvent.where(standing: @standing_harry).size).to eq 2
        expect(StandingEvent.where(standing: @standing_tom).size).to eq 2
        # Delinquent 2: initial, attendance_gain
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 2
      end

      it 'Raid.attendance_loss' do
        # (roster_size - raid_size) * delinquent_loss / raid_size
        # (5 - 4) * -1 / 4 = -0.25
        expect(@raid.attendance_loss).to eq -25.0
        expect(@raid.attendance_loss).to eq (Standing.where(active: true).size - @raid.attendees.size) * Settings.standing.delinquent_loss / @raid.attendees.size.to_f
      end

      it 'Standing Points' do
        # Attendees: attendance_loss
        attendee_points = BigDecimal(@raid.attendance_loss, 6)
        expect(Standing.find(@standing_alice).points).to eq attendee_points
        expect(Standing.find(@standing_dick).points).to eq attendee_points
        expect(Standing.find(@standing_harry).points).to eq attendee_points
        expect(Standing.find(@standing_tom).points).to eq attendee_points
        # Delinquent: attendance_gain
        expect(Standing.find(@standing_zack).points).to eq BigDecimal(Settings.standing.attendance_gain, 6)
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end

    describe 'adding new raid with 3 attending, 2 sitting' do
      before do
        fill_in 'Start Date', with: "#{Time.zone.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{Time.zone.now.strftime('%m/%d/%Y')} 10:30 PM"
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        check "online[#{@character_dick.slug}][1]"
        check "in_raid[#{@character_dick.slug}][1]"
        check "online[#{@character_harry.slug}][1]"
        check "in_raid[#{@character_harry.slug}][1]"
        check "online[#{@character_tom.slug}][1]"
        check "online[#{@character_zack.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 5
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 3' do
        expect(@raid.attendees.size).to eq 3
      end

      it 'StandingEvents count' do
        # Attendees 2: initial, attendance_loss
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 2
        expect(StandingEvent.where(standing: @standing_dick).size).to eq 2
        expect(StandingEvent.where(standing: @standing_harry).size).to eq 2
        # Delinquent 2: initial, attendance_gain
        expect(StandingEvent.where(standing: @standing_tom).size).to eq 2
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 2
      end

      it 'Raid.attendance_loss' do
        # (roster_size - raid_size) * delinquent_loss / raid_size
        # (5 - 3) * -1 / 3 = -0.25
        expect(@raid.attendance_loss).to eq (-100 * 2 / 3.to_f).round(6)
        expect(@raid.attendance_loss).to eq ((Standing.where(active: true).size - @raid.attendees.size) * Settings.standing.delinquent_loss / @raid.attendees.size.to_f).round(6)
      end

      it 'Standing Points' do
        # Attendees: attendance_loss
        attendee_points = BigDecimal(@raid.attendance_loss, 6)
        expect(Standing.find(@standing_alice).points).to eq attendee_points
        expect(Standing.find(@standing_dick).points).to eq attendee_points
        expect(Standing.find(@standing_harry).points).to eq attendee_points
        # Delinquent: attendance_gain
        expect(Standing.find(@standing_tom).points).to eq BigDecimal(Settings.standing.attendance_gain, 6)
        expect(Standing.find(@standing_zack).points).to eq BigDecimal(Settings.standing.attendance_gain, 6)
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end

    describe 'adding new raid with 3 attending, one 15 minutes tardy, 1 sitting' do
      before do
        fill_in 'Start Date', with: "#{Time.zone.now.strftime('%m/%d/%Y')} 06:30 PM"
        fill_in 'End Date',   with: "#{Time.zone.now.strftime('%m/%d/%Y')} 10:30 PM"
        check "online[#{@character_alice.slug}][1]"
        check "in_raid[#{@character_alice.slug}][1]"
        check "online[#{@character_dick.slug}][1]"
        check "in_raid[#{@character_dick.slug}][1]"
        check "online[#{@character_harry.slug}][1]"
        check "in_raid[#{@character_harry.slug}][1]"

        check "online[#{@character_tom.slug}][1]"
        check "in_raid[#{@character_tom.slug}][1]"
        fill_in "timestamp[#{@character_tom.slug}][1]", with: "#{Time.zone.now.strftime('%m/%d/%Y')} 06:45 PM"

        check "online[#{@character_zack.slug}][1]"
        select 'Naxxramas', from: 'Zone'
        click_button 'Add Raid'
        @raid = Raid.first
      end

      it 'should increment the Participation' do
        expect(Participation.all.size).to eq 5
      end

      it 'should increment the Raid' do
        expect(Raid.all.size).to eq 1
      end

      it 'Attendees should be 4' do
        expect(@raid.attendees.size).to eq 4
      end

      it 'StandingEvents count' do
        # Attendees 3: initial, attendance_loss, delinquent_gain
        expect(StandingEvent.where(standing: @standing_alice).size).to eq 3
        expect(StandingEvent.where(standing: @standing_dick).size).to eq 3
        expect(StandingEvent.where(standing: @standing_harry).size).to eq 3
        # Tardy 3: initial, attendance_loss, delinquent_loss
        expect(StandingEvent.where(standing: @standing_tom).size).to eq 3
        # Delinquent 3: initial, attendance_gain, delinquent_gain
        expect(StandingEvent.where(standing: @standing_zack).size).to eq 3
      end

      it 'Raid.attendance_loss' do
        # (roster_size - raid_size) * delinquent_loss / raid_size
        # (5 - 4) * -1 / 4 = -0.25
        expect(@raid.attendance_loss).to eq -25.0
        expect(@raid.attendance_loss).to eq (Standing.where(active: true).size - @raid.attendees.size) * Settings.standing.delinquent_loss / @raid.attendees.size.to_f
      end

      it 'Standing Points' do
        delinquency_point_loss = Settings.standing.delinquent_loss * 0.25.to_f
        # Attendees: attendance_loss, delinquent_gain
        attendee_points = BigDecimal(@raid.attendance_loss + delinquency_point_loss * -1 / (Standing.where(active: true).size - 1), 6)
        expect(Standing.find(@standing_alice).points).to eq attendee_points
        expect(Standing.find(@standing_dick).points).to eq attendee_points
        expect(Standing.find(@standing_harry).points).to eq attendee_points
        # Tardy: attendance_loss, delinquency_point_loss
        expect(Standing.find(@standing_tom).points).to eq BigDecimal(@raid.attendance_loss + delinquency_point_loss, 6)
        # Delinquent: attendance_gain, deliquency_point_loss
        expect(Standing.find(@standing_zack).points).to eq BigDecimal(Settings.standing.attendance_gain + delinquency_point_loss * -1 / (Standing.where(active: true).size - 1), 6)
      end

      it 'should have total points of zero' do
        expect(Standing.total_points).to eq 0
      end
    end
  end
end