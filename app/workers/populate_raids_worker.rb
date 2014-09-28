class PopulateRaidsWorker
  include Sidekiq::Worker
  include Errors

  def perform
    # Create a few basic raids
    unless Zone.last.nil?
      raid_start_time = Time.zone.parse("1/1/2000 #{Settings.raid.start_time}")
      raid_end_time = Time.zone.parse("1/1/2000 #{Settings.raid.end_time}")
      start_date = Time.zone.now.change(
        hour: raid_start_time.hour,
        min: raid_start_time.min,
      ).strftime(DATETIME_FORMAT)
      end_date = Time.zone.now.change(
        hour: raid_end_time.hour,
        min: raid_end_time.min,
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