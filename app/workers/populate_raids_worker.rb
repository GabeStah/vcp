class PopulateRaidsWorker
  include Sidekiq::Worker
  include Errors

  def perform
    # Create a few basic raids
    setting = Setting.first
    unless setting.nil? || Zone.last.nil?
      unless setting.nil?
        raid_start_time = DateTime.parse("1/1/2000 #{setting.raid_start_time}")
        raid_end_time = DateTime.parse("1/1/2000 #{setting.raid_end_time}")
      end
      start_date = DateTime.now.change(
        hour: raid_start_time ? raid_start_time.hour : DEFAULT_RAID_START_TIME[:hour],
        min: raid_start_time ? raid_start_time.min : DEFAULT_RAID_START_TIME[:min],
      ).strftime(DATETIME_FORMAT)
      end_date = DateTime.now.change(
        hour: raid_end_time ? raid_end_time.hour : DEFAULT_RAID_END_TIME[:hour],
        min: raid_end_time ? raid_end_time.min : DEFAULT_RAID_END_TIME[:min],
      ).strftime(DATETIME_FORMAT)

      Raid.create(
        ended_at: end_date,
        started_at: start_date,
        zone: Zone.last
      )
    else
      raise StandardError.new('Unable to create Raid.')
    end
  end
end